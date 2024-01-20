/* Create the sensitvitiy table */

/* make empty csv that will be filled with table values */
cap !rm -f $out/sensitibity_table.csv

/* import results from a/sample_sensitivity.do */
import delimited using $out/sensitivity_results.csv, clear

/* clean up the percentages */
gen temp = rugbal_elev * 100
tostring temp, replace  force
gen rugbal_elev_str = substr(temp, 1, 2)
drop temp

gen temp = rugbal_comm * 100
tostring temp, replace  force
gen rugbal_comm_str = substr(temp, 1, 2)
drop temp

/*********************************/
/* Elevation, Panel A: Bandwidth */
/*********************************/
/* foreach bw */
foreach bw in 15 25 50 75 {

  /* output values for each variable */
  foreach var in irr_share11 evi_delta_r_ln_mean popdens_poly11_log ec13_emp_pc tri_mean {

    /* get the coefficient */
    sum coef if variable == "`var'" & bw_elev == `bw' & canal_dist == 10 &  rugbal_elev_str == "25" & spec == "elev"
    local `var'_coef_`bw': di %5.3f `r(mean)'

    /* get the stars */
    levelsof stars if variable == "`var'" & bw_elev == `bw' & canal_dist == 10 & rugbal_elev_str == "25" & spec == "elev", local(temp)
    tokenize `temp'
    local stars = "`1'"

    /* join the coefficient and the stars */
    local `var'_coef_`bw' = "``var'_coef_`bw''`stars'"

    /* get the SE */
    sum se if variable == "`var'" & bw_elev == `bw' & canal_dist == 10 & rugbal_elev_str == "25" & spec == "elev"
    local `var'_se_`bw': di %5.3f `r(mean)'

    /* if there are no stars, coef must be entered as a number, otherwise as a string */
    if "`stars'" == "" insert_into_file using $out/sensitivity_table.csv, key(`var'_elev_coef_`bw') value("``var'_coef_`bw''") format(%5.3f)
    else if "`stars'" != "" insert_into_file using $out/sensitivity_table.csv, key(`var'_elev_coef_`bw') value("``var'_coef_`bw''") format(%s)

    /* insert the standard error */
    insert_into_file using $out/sensitivity_table.csv, key(`var'_elev_se_`bw') value(``var'_se_`bw'') format(%5.3f)
  }

  /* get the sample size - use the one we have all ruggedness for */
  sum samp if variable == "tri_mean" & bw_elev == `bw' & canal_dist == 10 & rugbal_elev_str == "25" & spec == "elev"
  local samp_elev_`bw': di %7.0fc `r(mean)'
  
  /* insert sample size into table csv */
  insert_into_file using $out/sensitivity_table.csv, key(samp_elev_`bw') value("`samp_elev_`bw''") format(%s)
}


/********************************************************/
/* Elevation, Panel B: Percent difference in ruggedness */
/********************************************************/
/* foreach percent difference */
foreach r in 10 25 50 {

  /* output values for each variable */
  foreach var in irr_share11 evi_delta_r_ln_mean popdens_poly11_log ec13_emp_pc tri_mean {

    /* get the coefficient */
    sum coef if variable == "`var'" & bw_elev == 50 & canal_dist == 10 & rugbal_elev_str == "`r'" & spec == "elev"
    local `var'_coef_`r': di %5.3f `r(mean)'

    /* get the stars */
    levelsof stars if variable == "`var'" & bw_elev == 50  & canal_dist == 10 & rugbal_elev_str == "`r'" & spec == "elev", local(temp)
    tokenize `temp'
    local stars = "`1'"

    /* join the coefficient and the stars */
    local `var'_coef_`r' = "``var'_coef_`r''`stars'"

    /* get the SE */
    sum se if variable == "`var'" & bw_elev == 50 & canal_dist == 10 & rugbal_elev_str == "`r'" & spec == "elev"
    local `var'_se_`r': di %5.3f `r(mean)'

    /* if there are no stars, coef must be entered as a number, otherwise as a string */
    if "`stars'" == "" insert_into_file using $out/sensitivity_table.csv, key("`var'_elev_coef_r`r'") value("``var'_coef_`r''") format(%5.3f)
    else if "`stars'" != "" insert_into_file using $out/sensitivity_table.csv, key("`var'_elev_coef_r`r'") value("``var'_coef_`r''") format(%s)

    /* insert the standard error */
    insert_into_file using $out/sensitivity_table.csv, key(`var'_elev_se_r`r') value("``var'_se_`r''") format(%5.3f)
  }

  /* get the sample size - use the one we have all ruggedness for */
  sum samp if variable == "tri_mean" & bw_elev == 50 & canal_dist == 10 & rugbal_elev_str == "`r'" & spec == "elev"
  local samp_elev_`r': di %7.0fc `r(mean)'
  
  /* insert sample size into table csv */
  insert_into_file using $out/sensitivity_table.csv, key("samp_elev_r`r'") value("`samp_elev_`r''") format(%s)
}

/*****************************************/
/* Elevation, Panel C: Distance to canal */
/*****************************************/
/* foreach distance to canal */
foreach c in 5 10 15 {

  /* output values for each variable */
  foreach var in irr_share11 evi_delta_r_ln_mean popdens_poly11_log ec13_emp_pc tri_mean {

    /* get the coefficient */
    sum coef if variable == "`var'" & bw_elev == 50 & canal_dist == `c'  & rugbal_elev_str == "25" & spec == "elev"
    local `var'_coef_`c': di %5.3f `r(mean)'

    /* get the stars */
    levelsof stars if variable == "`var'" & bw_elev == 50  & canal_dist == `c' & rugbal_elev_str == "25" & spec == "elev", local(temp)
    tokenize `temp'
    local stars = "`1'"

    /* join the coefficient and the stars */
    local `var'_coef_`c' = "``var'_coef_`c''`stars'"

    /* get the SE */
    sum se if variable == "`var'" & bw_elev == 50 & canal_dist == `c' & rugbal_elev_str == "25" & spec == "elev"
    local `var'_se_`c': di %5.3f `r(mean)'

    /* if there are no stars, coef must be entered as a number, otherwise as a string */
    if "`stars'" == "" insert_into_file using $out/sensitivity_table.csv, key(`var'_elev_coef_c`c') value("``var'_coef_`c''") format(%5.3f)
    else if "`stars'" != "" insert_into_file using $out/sensitivity_table.csv, key(`var'_elev_coef_c`c') value("``var'_coef_`c''") format(%s)

    /* insert the standard error */
    insert_into_file using $out/sensitivity_table.csv, key(`var'_elev_se_c`c') value(``var'_se_`c'') format(%5.3f)
  }

  /* get the sample size - use the one we have all ruggedness for */
  sum samp if variable == "tri_mean" & bw_elev == 50 & canal_dist == `c' & rugbal_elev_str == "25" & spec == "elev"
  local samp_elev_`c': di %7.0fc `r(mean)'
  
  /* insert sample size into table csv */
  insert_into_file using $out/sensitivity_table.csv, key(samp_elev_c`c') value("`samp_elev_`c''") format(%s)
}


/* make the table */
table_from_tpl, t($ccode/a/tpl/sensitivity_table_tpl.tex) r($out/sensitivity_table.csv) o($out/sensitivity_table.tex)
