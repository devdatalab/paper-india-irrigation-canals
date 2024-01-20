/* generate the 3x3 grid of RD plot results */

/* open the analysis dataset */
use $cdata/canals_analysis_data, clear

/* relable variabels to  match the label used throughout the paper */
lab var secc_cons_pc_log "Consumption pc (log)"
lab var evi_delta_k_ln_mean "Kharif (monsoon) agricultural production (log)"
lab var evi_delta_r_ln_mean "Rabi (winter) agricultural production (log)"

/******************/
/* RD Result Grid */
/******************/
/* loop over variables to run rd */
foreach var in ag_share11 irr_share11 irr_share_canal irr_share_tubewell evi_delta_k_ln_mean evi_delta_r_ln_mean popdens_poly11_log ec13_emp_serv_pc ec13_emp_manuf_pc secc_cons_pc_log ed_middle_adult pc11_pca_p_lit_pc {
  
  /* get label of variable */
  local title: var label `var'
  
  /* ELEVATION */
  /* rd for shrids with with elevation strategy */
  areg `var' elev_dummy rel_elev_below rel_elev_above $geo_controls [aw=area_laea] if ($sampelev == 1), absorb(subd_id) cluster(subd_id)

  /* get control group mean */
  sum `var' if ($sampelev == 1) & (elev_dummy == 0) [aw=area_laea]
  local mean_elev = r(mean)
  local mean_elev: di %5.3f `mean_elev'

  /* get coefficient and standard error variable of interest */
  local elev_coef = _coef[elev_dummy]
  local elev_coef: di %5.3f `elev_coef'
  local elev_se = _se[elev_dummy]
  local elev_se: di %5.3f `elev_se'
  
  /* get pvalue stars - stored as `star' */
  test elev_dummy = 0
  local pvalue = `r(p)'
  count_stars, p(`pvalue')
  local stars = "`r(stars)'"

  /* set position of note */
  if ("`var'" == "evi_delta_k_ln_mean" | "`var'" === "ag_share11" | "`var'" == "irr_share_tubewell") local pos 8
  else if "`var'" == "ec13_emp_manuf_pc" local pos 2
  else local pos 11

  /* set spacing for standard deviation */
  if `elev_coef' < 0  local se_note "          (`elev_se')"
  else local se_note "        (`elev_se')"

  /* make graph */
  rd `var' rel_elev [aw=wt_area_elev] if ($sampelev == 1), control($geo_controls) xq(xbins_elev) start(-47.5) end(47.5) start_line(-47.5) end_line(47.5) absorb(subd_id) cluster(subd_id) title("`title'", size(medsmall)) name(elev_`var') xtitle("Relative elevation (m)", size(small)) ylabel(,labsize(vsmall)) xlabel(-50(10)50, labsize(vsmall)) note("Coef=`elev_coef'`stars'" "`se_note'" "{&mu}{sub:c}=`mean_elev'", position(`pos') ring(0) size("small")) degree(1) xsc(reverse) fysize(50) bw 
}

/* Paper Outputs */
/* grid of relative elevation specification results */
graph combine elev_irr_share11 elev_irr_share_canal elev_irr_share_tubewell elev_ag_share11 elev_evi_delta_k_ln_mean elev_evi_delta_r_ln_mean elev_popdens_poly11_log elev_ec13_emp_serv_pc elev_ec13_emp_manuf_pc elev_secc_cons_pc_log elev_ed_middle_adult elev_pc11_pca_p_lit_pc, col(3) row(3) graphregion(color(white))
graphout rel_elev_results_$fnsuffix, pdf
