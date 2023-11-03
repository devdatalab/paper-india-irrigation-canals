/* generate the main results. */

/* open the analysis dataset */
use $cdata/canals_analysis_data, clear

/*******************/
/* Run Regressions */
/*******************/
/* remove csv files for coef plots */
cap !rm -f $out/rd_elev_results_$fnsuffix.csv
cap !rm -f $out/rd_elev_results_reference_$fnsuffix.csv
cap !rm -f $out/rd_comm_results_$fnsuffix.csv
cap !rm -f $out/rd_comm_results_reference_$fnsuffix.csv

/* add title row to reference csv */
append_to_file using $out/rd_elev_results_reference_$fnsuffix.csv, s(b,se,p,n)

/* cycle through all variables to produce outputs  */
foreach var in $ag_outcomes $ec_outcomes urban_marker pop_share_06 age70p_share p_sch m_sch s_sch p_sch_priv m_sch_priv s_sch_priv p_sch_gov m_sch_gov s_sch_gov {

  /* get label of variable */
  local title: var label `var'
    
  /* ELEVATION */
  /* rd for shrids with with elevation strategy - include donut */
  areg `var' elev_dummy rel_elev_below rel_elev_above $geo_controls [aw=area_laea] if ($sampelev == 1), absorb(subd_id) cluster(subd_id)     

  /* save results - program defined in canals_programs.do */
  save_main_reg_results, varname("`var'") id(elev) dummy(elev_dummy) sample($sampelev) tabfile($out/rd_elev_results_$fnsuffix.csv) coeffile($out/rd_elev_results_$fnsuffix.csv) reffile($out/rd_elev_results_reference_$fnsuffix.csv)

  /* make graph - commented out by default since it is slow, but uncomment if you want to see the RD plot for each outcome */
  // rd `var' rel_elev [aw=wt_area_elev] if ($sampelev == 1), control($geo_controls) xq(xbins_elev) start_line(-50) start(-50) end(50) end_line(50) cluster(subd_id) absorb(subd_id) ytitle("`title'") title("Relative elevation", size(medsmall)) name(elv_`var') xtitle("Difference in elevation between village and canal (m)", size(small)) ylabel(,labsize(vsmall)) xlabel(-50(10)50, labsize(vsmall)) note("Effect=`r(res_coef)'" "          (`r(res_se)')" "Control Mean=`r(res_mean)'", position(11) ring(0)) degree(1) xsc(reverse) fysize(50) bw
  // graphout rd_elev_`var'_$fnsuffix, pdf 

  /* COMMAND AREA */
  /* rd for shrids with command area strategy */
  areg `var' comm_dummy near_comm_dist_in near_comm_dist_out $geo_controls  [aw=area_laea] if ($sampcomm == 1), absorb(near_comm_seg_10km) cluster(near_comm_seg_10km)

  /* save results */
  save_main_reg_results, varname("`var'") id(comm) dummy(comm_dummy) sample($sampcomm) tabfile($out/rd_comm_results_$fnsuffix.csv) coeffile($out/rd_comm_results_$fnsuffix.csv) reffile($out/rd_comm_results_reference_$fnsuffix.csv)
  
  /* make graph - commented out by default since it is slow, but uncomment if you want to see the RD plot for each outcome */
  // rd `var' near_comm_dist [aw=wt_area_elev] if $sampcomm == 1, control($geo_controls) xq(xbins_comm) start_line(-25) end_line(25) absorb(near_comm_seg_10km) cluster(near_comm_seg_10km) title("Command area", size(medsmall)) name(cmd_`var') xtitle("Distance to command area boundary (km)",size(small)) ylabel(,labsize(vsmall)) xlabel(-25(5)25,labsize(vsmall)) note("Effect=`r(res_coef)'" "          (`r(res_se)')" "Control Mean=`r(res_mean)'", position(11) ring(0)) degree(1) xsc(reverse) fysize(50) bw
  // graphout rd_comm_`var'_$fnsuffix, png rescale(100)

  /* OUTPUTS */
  /* graphcombine the two - commented out by default, but uncomment for RD plots */
  // graph combine elv_`var' cmd_`var', ycommon col(2) graphregion(color(white)) imargin(1 1 0 -30)
  // graphout rd_`var'_elev_comm_$fnsuffix, pdf

}

/* export variable labels */
cap !rm -f $out/rd_elev_results_labels_$fnsuffix.csv
append_to_file using $out/rd_elev_results_labels_$fnsuffix.csv, s(var,label)

/* cycle through and append each variable and label to the csv */
foreach var in $ag_outcomes $ec_outcomes urban_marker {
  local label : variable label `var'
  append_to_file using $out/rd_elev_results_labels_$fnsuffix.csv, s(`var',`label')
}

/*****************/
/* Output Tables */
/*****************/
/* relative elevation table */
table_from_tpl, t($ddl/canals/a/rd_elev_results_tpl.tex) r($out/rd_elev_results_$fnsuffix.csv) o($out/rd_elev_results_$fnsuffix.tex)

/* each panel individually */
table_from_tpl, t($ddl/canals/a/rd_elev_results_irr_tpl.tex) r($out/rd_elev_results_$fnsuffix.csv) o($out/rd_elev_results_irr_$fnsuffix.tex)
table_from_tpl, t($ddl/canals/a/rd_elev_results_ag_tpl.tex) r($out/rd_elev_results_$fnsuffix.csv) o($out/rd_elev_results_ag_$fnsuffix.tex)
table_from_tpl, t($ddl/canals/a/rd_elev_results_ec_tpl.tex) r($out/rd_elev_results_$fnsuffix.csv) o($out/rd_elev_results_ec_$fnsuffix.tex)
table_from_tpl, t($ddl/canals/a/rd_elev_results_ed_tpl.tex) r($out/rd_elev_results_$fnsuffix.csv) o($out/rd_elev_results_ed_$fnsuffix.tex)

/* command area table */
table_from_tpl, t($ddl/canals/a/rd_comm_results_tpl.tex) r($out/rd_comm_results_$fnsuffix.csv) o($out/rd_comm_results_$fnsuffix.tex)

/* each panel individually */
table_from_tpl, t($ddl/canals/a/rd_comm_results_irr_tpl.tex) r($out/rd_comm_results_$fnsuffix.csv) o($out/rd_comm_results_irr_$fnsuffix.tex)
table_from_tpl, t($ddl/canals/a/rd_comm_results_ag_tpl.tex) r($out/rd_comm_results_$fnsuffix.csv) o($out/rd_comm_results_ag_$fnsuffix.tex)
table_from_tpl, t($ddl/canals/a/rd_comm_results_ec_tpl.tex) r($out/rd_comm_results_$fnsuffix.csv) o($out/rd_comm_results_ec_$fnsuffix.tex)
table_from_tpl, t($ddl/canals/a/rd_comm_results_ed_tpl.tex) r($out/rd_comm_results_$fnsuffix.csv) o($out/rd_comm_results_ed_$fnsuffix.tex)

/* output the additional outcomes appendix table */
table_from_tpl, t($ddl/canals/a/rd_additional_outcomes_tpl.tex) r($out/rd_elev_results_$fnsuffix.csv) o($out/rd_additional_outcomes_$fnsuffix.tex)

/* output the school types appendix table */
table_from_tpl, t($ddl/canals/a/rd_sch_outcomes_tpl.tex) r($out/rd_elev_results_$fnsuffix.csv) o($out/rd_sch_outcomes_$fnsuffix.tex)
