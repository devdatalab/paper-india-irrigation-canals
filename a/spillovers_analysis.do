/* Spillover analysis */

/* create the list of controls referring to the correct globals calculated in calculate_spillover_weights.do */
foreach id in b0 b0a b0b b1 b2 {
  global geo_controls_`id'
  foreach var in $geo_controls elev_p5 {
    global geo_controls_`id' ${geo_controls_`id'} `var'_`id'
  }
}

/* open the analysis dataset */
use $cdata/canals_analysis_data, clear

/* merge in the entropy balance weights */
merge 1:1 shrid using $cdata/canals_spillovers, keep(match master) nogen

/* create band dummies for distant group */
gen spill_b15_50 = (elev_dummy == 0 & inrange(dist_km_canal, 15, 50) & dist_km_canal != 15 & !inrange(rel_elev, -2.5, 2.5))
gen spill_b25_50 = (elev_dummy == 0 & inrange(dist_km_canal, 25, 50) & dist_km_canal != 25 & !inrange(rel_elev, -2.5, 2.5)) 

/* clear the output csv */
global f $out/spillovers_entropy_balance.csv 
cap !rm -f $f

/* append column headers - this just helps the csv be read into python for the coefplots because 
when the sample size is output with a comma pandas gets confused with the number of columns */
append_to_file using $f, s(1,2,3)

/* spillover results */
foreach var in irr_share11 irr_share_canal irr_share_tubewell irr_share_oth ag_share11 evi_delta_k_ln_mean evi_delta_r_ln_mean any_water_crop mech_farm_equip popdens_poly11_log ec13_emp_pc ec13_emp_serv_pc ec13_emp_manuf_pc secc_cons_pc_log  cons_pc_land_own0_log cons_pc_land_own1_log ed_m_full_land_own0 ed_m_full_land_own1 pc11_pca_p_lit_pc urban_marker {

  foreach i in webal {
    /* control=0-10km, distant=15-50km, rugbalance, 2.5% outliers  */
    areg `var' below_b0 spill_b15_50 $geo_controls_b0 [aw=_`i'_rug_b0], absorb(dist_id) cluster(dist_id)
    save_spillover_reg_results, var(`var') key(`i'_b0) wvar(_`i'_rug_b0) fout($f) numbands(2) above(above_b0)

    /* control=0-10km, distant=15-50km, rugbalance, 0% outliers  */
    areg `var' below_b0a spill_b15_50 $geo_controls [aw=_`i'_rug_b0a], absorb(dist_id) cluster(dist_id)
    save_spillover_reg_results, var(`var') key(`i'_b0a) wvar(_`i'_rug_b0a) fout($f) numbands(2) above(above_b0a)

    /* control=0-10km, distant=15-50km, rugbalance, 5% outliers  */
    areg `var' below_b0b spill_b15_50 $geo_controls_b0b [aw=_`i'_rug_b0b], absorb(dist_id) cluster(dist_id)
    save_spillover_reg_results, var(`var') key(`i'_b0b) wvar(_`i'_rug_b0b) fout($f) numbands(2) above(above_b0b)

    /* control=0-20km, distant=15-50km, rugbalance, 2.5% outliers  */
    areg `var' below_b1 spill_b25_50 $geo_controls_b1 [aw=_`i'_rug_b1], absorb(dist_id) cluster(dist_id)
    save_spillover_reg_results, var(`var') key(`i'_b1) wvar(_`i'_rug_b1) fout($f) numbands(2) above(above_b1)

    /* control=0-5km, distant=15-50km, rugbalance, 2.5% outliers  */
    areg `var' below_b2 spill_b15_50 $geo_controls_b2 [aw=_`i'_rug_b2], absorb(dist_id) cluster(dist_id)
    save_spillover_reg_results, var(`var') key(`i'_b2) wvar(_`i'_rug_b2) fout($f) numbands(2) above(above_b2)

  }
}

/* Main paper tables, by outcome group */
table_from_tpl, t($ccode/a/tpl/spillovers_table_irr_tpl.tex) r($f) o($out/spillovers_table_irr.tex)
table_from_tpl, t($ccode/a/tpl/spillovers_table_ag_tpl.tex) r($f) o($out/spillovers_table_ag.tex)
table_from_tpl, t($ccode/a/tpl/spillovers_table_ec_tpl.tex) r($f) o($out/spillovers_table_ec.tex)
table_from_tpl, t($ccode/a/tpl/spillovers_table_ls_tpl.tex) r($f) o($out/spillovers_table_ls.tex)

/* Presentation table */
table_from_tpl, t($ccode/a/tpl/spillovers_table_pres1_tpl.tex) r($f) o($out/spillovers_table_pres1.tex)
table_from_tpl, t($ccode/a/tpl/spillovers_table_pres2_tpl.tex) r($f) o($out/spillovers_table_pres2.tex)

/* Appendix tables */
table_from_tpl, t($ccode/a/tpl/spillovers_table_irr_ebal_app_tpl.tex) r($f) o($out/spillovers_table_irr_ebal_app.tex)
table_from_tpl, t($ccode/a/tpl/spillovers_table_ag_ebal_app_tpl.tex) r($f) o($out/spillovers_table_ag_ebal_app.tex)
table_from_tpl, t($ccode/a/tpl/spillovers_table_ec_ebal_app_tpl.tex) r($f) o($out/spillovers_table_ec_ebal_app.tex)
table_from_tpl, t($ccode/a/tpl/spillovers_table_ls_ebal_app_tpl.tex) r($f) o($out/spillovers_table_ls_ebal_app.tex)
