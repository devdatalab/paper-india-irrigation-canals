/* must install before running: ssc install did_multiplegt, replace */

/*************************************************************************************/
/* program show_results: print dechaisemartin average and placebo effects to screen  */
/*************************************************************************************/
cap prog drop show_results
prog def show_results
    local ab: di %5.3f `e(effect_average)'
    local as: di %5.3f `e(se_effect_average)'
    local pb: di %5.3f `e(jointplacebo)'
    local pp: di %4.2f `e(p_jointplacebo)'
  
    di "Average effect: `ab' (`as'), Joint Placebo: `pb' p = `pp'."
end
/** END program show_results ***********************************************/

/* set globals for estimates storage */
global estfile $out/did_estimates.csv

/********************************/
/* Prepare the analysis dataset */
/********************************/
use $cdata/town_panel_equal_area, clear

/* drop confusing extraneous "treated" variable */
drop treated

/* create treatment indicators for 0-10km and 0-30km */
gen treated_10 = comm_per_100km > .2 if !mi(comm_per_100km)
gen treated_20 = comm_per_400km > .2 if !mi(comm_per_400km)
gen treated_30 = comm_per_900km > .2 if !mi(comm_per_900km)

/* reset the group variables */
capdrop sgroup ygroup sdsgroup sygroup sdygroup
group shrid
group year
egen sdsgroup = group(pc11_state_id pc11_district_id pc11_subdistrict_id)
egen state = group(pc11_state_id)
egen district = group(pc11_state_id pc11_district_id)
egen sygroup = group(pc11_state_id year)
egen sdygroup = group(pc11_state_id pc11_district_id year)

/* calculate appeared100k and appeared500k */
foreach p in 100000 500000 {
  bys shrid: egen tmp = min(year) if pop > `p' & !mi(pop)
  gen appeared`p' = 0 if mi(tmp)
  replace appeared`p' = 1 if !mi(tmp)
  drop tmp
}

/* store the treatment year */
bys shrid: egen treatment_year = min(ytreat_400_20)

/* tag shrids with first canal in 1991 or later --- we'll drop these for robustness */
gen late_canal = inlist(treatment_year, 10, 11, 12)

/* save town panel analysis file */
save $tmp/town_panel, replace


/*****************************/
/* Run diff-in-diff analysis */
/*****************************/

use $tmp/town_panel, clear
global fast 0
global veryfast 0
global yvars appeared5000 appeared10000 appeared50000 appeared100000 appeared500000 ln_pop_fill growth

/* loop over all outcome variables of interest */
foreach y in $yvars  {
  disp_nice "`y'"
  
  foreach d in 10 20 30 {

    /* calculate area (used for cts regression vars, but not dechaisemartin dids) */
    /* note by "area" we mean "radius squared", correlated with area but not area -- it's just a variable label */
    local a = `d'^2
      
    /* run the continuous regression (even in fast mode, they are fast) */
    quireg `y' comm_per_`a'km if (first_treated_`a' != 0), absorb(shrid year) cluster(sdsgroup)

    /* store estimate in the output file */
    insert_est_into_file using $estfile, spec(cts_`y'_`d') b(comm_per_`a'km)

    /* cts regression with state-year fixed effects */
    quireg `y' comm_per_`a'km if (first_treated_`a' != 0), absorb(shrid sygroup) cluster(sdsgroup)
    insert_est_into_file using $estfile, spec(cts_sfe_`y'_`d') b(comm_per_`a'km)

    /* cts regression with district-year fixed effects */
    quireg `y' comm_per_`a'km if (first_treated_`a' != 0), absorb(shrid sdygroup) cluster(sdsgroup)
    insert_est_into_file using $estfile, spec(cts_dfe_`y'_`d') b(comm_per_`a'km)
    
    /* run dechaisemartin and hautefoeille (2020) diff-in-diff */
    
    /* 1. main spec */
    cap confirm file $out/did/did_main_`y'_`d'.dta
    if (!($veryfast)) | (_rc) {
      di "Running main_`y'_`d'..."
      did_multiplegt `y' sgroup ygroup treated_`d', robust_dynamic cluster(district) dynamic(5) placebo(5) breps(50) jointtestplacebo longdiff_placebo seed(1) covariances average_effect save_results($out/did/did_main_`y'_`d') graphoptions(legend(off) xline(-1, lcolor(black) lpattern(solid)) yline(0, lcolor(black) lpattern(solid)) name(main_`y'_`d', replace))
      show_results
      graphout did_main_`y'_`d', pdf
    }
    else di "Skipping main_`y'_`d'..."
    
    /* 2. state fixed effect spec  */
    cap confirm file $out/did/did_sfe_`y'_`d'.dta
    if (!($fast)) | (_rc) {
      di "Running sfe_`y'_`d'..."
      did_multiplegt `y' sgroup ygroup treated_`d', robust_dynamic cluster(district) dynamic(5) placebo(5) breps(50) jointtestplacebo longdiff_placebo seed(1) covariances average_effect save_results($out/did/did_sfe_`y'_`d') trends_nonparam(state) graphoptions(legend(off) xline(-1, lcolor(black) lpattern(solid)) yline(0, lcolor(black) lpattern(solid)) name(sfe_`y'_`d', replace))
      show_results
      graphout did_sfe_`y'_`d', pdf
    }
    else di "Skipping sfe_`y'_`d'..."
    
    /* 3. district fixed effect spec  */
    cap confirm file $out/did/did_dfe_`y'_`d'.dta
    if (!($fast)) | (_rc) {
      di "Running dfe_`y'_`d'..."
      did_multiplegt `y' sgroup ygroup treated_`d', robust_dynamic cluster(district) dynamic(5) placebo(5) breps(50) jointtestplacebo longdiff_placebo seed(1) covariances average_effect save_results($out/did/did_dfe_`y'_`d') trends_nonparam(district) graphoptions(legend(off) xline(-1, lcolor(black) lpattern(solid)) yline(0, lcolor(black) lpattern(solid)) name(dfe_`y'_`d', replace))
      show_results
      graphout did_dfe_`y'_`d', pdf
    }
    else di "Skipping dfe_`y'_`d'..."

  }

  /* Robustness: 20km regression, dropping last two decades */
  /* 4. main spec, dropping late canals  */
  quireg `y' comm_per_400km if (first_treated_400 != 0) & late_canal == 0, absorb(shrid year) cluster(sdsgroup)
  insert_est_into_file using $estfile, spec(cts_cut_`y') b(comm_per_400km)
  
  cap confirm file $out/did/did_cut_`y'_20.dta
  if (!($fast)) | (_rc) {
    di "Running cut_`y'..."
    did_multiplegt `y' sgroup ygroup treated_20 if late_canal == 0, robust_dynamic cluster(district) dynamic(5) placebo(5) breps(50) jointtestplacebo longdiff_placebo seed(1) covariances average_effect save_results($out/did/did_cut_`y'_20) trends_nonparam(district) graphoptions(legend(off) xline(-1, lcolor(black) lpattern(solid)) yline(0, lcolor(black) lpattern(solid)) name(cut_`y'_20, replace))
    show_results
    graphout did_cut_`y'_20, pdf
  }
  else di "Skipping cut_`y'..."
}

/* open all the dechaisemartin results files and store their results in our standard format in foo.csv */
foreach d in 10 20 30 {
  foreach spec in main sfe dfe cut {
    foreach y in $yvars {
      cap use $out/did/did_`spec'_`y'_`d', clear
      if _rc continue

      /* calculate the t statistic */
      gen t = treatment_effect / se_treatment_effect if mi(time)
      
      /* get the number of stars for this t statistic (assume lots of degrees of freedom) */
      qui sum t
      local t `r(mean)'
      
      /* get average treatment effect */
      qui sum treatment_effect if mi(time)
      local b: di %5.3f `r(mean)' "`stars'"
      
      /* get average effect semean */
      qui sum se_treatment_effect if mi(time)
      local se: di %5.3f `r(mean)'
      
      /* get obs count */
      qui sum N_treatment_effect if mi(time)
      local n: di %5.0f `r(mean)'
      
      /* write the estimate into a file */
      insert_est_into_file using $estfile, spec(`spec'_`y'_`d') b(`b') se(`se') t(`t') n(`n')
    }
  }
}

/* generate main outcome table from these estimates */
table_from_tpl, t($ccode/a/town_did_dechaise_tpl.tex) r($estfile) o($out/town_did.tex)

/* generate appendix table from these estimates */
table_from_tpl, t($ccode/a/town_did_robust_tpl.tex) r($estfile) o($out/town_did_robust.tex)
shell cp $out/town_did_robust.tex ~/ddl/canals-overleaf/exhibits

/* generate appendix table from these estimates */
table_from_tpl, t($ccode/a/town_did_appearance.tpl) r($estfile) o($out/town_did_appear.tex)
shell cp $out/town_did_appear.tex ~/ddl/canals-overleaf/exhibits

/* generate new tables, split by appearance and pop/growth */
table_from_tpl, t($ccode/a/town_did_pop_growth.tpl) r($estfile) o($out/town_did_growth.tex)
shell cp $out/town_did_growth.tex ~/ddl/canals-overleaf/exhibits

