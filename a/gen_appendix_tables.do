/* WARNING: careful running this file as it clears all results before re-running every specification.
In particular running the Conley standard errors takes ~8 hours, which this file runs by calling
a/spatial_correlation.do. These results are saved separately, so you can manually add them back to the 
main csv results file, but be aware that running this file will clear that results file.  */

/****************************/
/* Generate Appendix Tables */
/****************************/
/* run the full set of results for each sample */
use $cdata/canals_analysis_data, clear

/* remove csv file with regression table results */
cap !rm -f $out/rd_coef_results_all_appendix.csv

/* remove csv file for coefplot */
cap !rm -f $out/rd_coef_results_all_coefplot_appendix.csv

/* loop over each sample */
foreach fn in bal full donut hole control {

  /* initiate an empty added control, this will only be used in the "control" sample */
  local added_control
  
  /* set the sample */
  if "`fn'" == "full" {
    local sample_flg full_sample_elev
  }
  else if "`fn'" == "donut" {
    local sample_flg donut_sample_elev
  }
  else if "`fn'" == "hole" {
    local sample_flg hole_sample_elev
  }
  else if "`fn'" == "control" {
    local sample_flg rug_balance_elev
    local added_control dist_km_canal
  }
  else if "`fn'" == "bal" {
    local sample_flg rug_balance_elev
  }

  /* loop over variables to run rd */
  foreach var in irr_share11 ag_share11 any_water_crop  mech_farm_equip evi_delta_r_ln_mean evi_delta_k_ln_mean irr_share_canal irr_share_tubewell irr_share_oth total_land_acre popdens_poly11_log ec13_emp_pc ec13_agro_pc ec13_emp_serv_pc ec13_emp_manuf_pc secc_cons_pc_log  pc11_pca_p_lit_pc ed_primary_adult ed_middle_adult ed_secondary_adult cons_pc_land_own1_log cons_pc_land_own0_log $age_structure {
  
    /* rd for shrids with with elevation strategy - include donut */
    areg `var' elev_dummy rel_elev_below rel_elev_above $geo_controls `added_control' [aw=area_laea] if (`sample_flg' == 1), absorb(subd_id) cluster(subd_id) 

    /* save results */
    save_main_reg_results, varname("`var'") id(elev) dummy(elev_dummy) sample(`sample_flg')  tabfile($out/rd_coef_results_all_appendix.csv) coeffile($out/rd_coef_results_all_coefplot_appendix.csv) prefix(`fn')

  }
}

/* COMMAND AREA */
/* loop over variables to run rd */
foreach var in irr_share11 ag_share11 any_water_crop count_water_crop mech_farm_equip evi_delta_r_ln_mean evi_delta_k_ln_mean irr_share_canal irr_share_tubewell irr_share_oth total_land_acre popdens_poly11_log ec13_emp_pc ec13_agro_pc ec13_emp_serv_pc ec13_emp_manuf_pc secc_cons_pc_log  pc11_pca_p_lit_pc ed_primary_adult ed_middle_adult ed_secondary_adult cons_pc_land_own1_log cons_pc_land_own0_log {

  local sample_flg rug_balance_comm
  local fn bal

  /* rd for shrids with command area strategy */
  areg `var' comm_dummy near_comm_dist_in near_comm_dist_out $geo_controls [aw=area_laea] if (`sample_flg' == 1), absorb(subd_id) cluster(subd_id) 

  /* save results */
  save_main_reg_results, varname("`var'") id(comm) dummy(comm_dummy) sample(`sample_flg')  tabfile($out/rd_coef_results_all_appendix.csv) coeffile($out/rd_coef_results_all_coefplot_appendix.csv)

}


/* ELEVATION: Median and p25 measures */
foreach fn in median p25 {

 /* set the sample */
  if "`fn'" == "median" {
    local sample_flg median_sample_elev
  }
  else if "`fn'" == "p25" {
    local sample_flg p25_sample_elev
  }
  
  /* loop over variables to run rd */
  foreach var in irr_share11 ag_share11 any_water_crop  mech_farm_equip evi_delta_r_ln_mean evi_delta_k_ln_mean irr_share_canal irr_share_tubewell irr_share_oth total_land_acre popdens_poly11_log ec13_emp_pc ec13_agro_pc ec13_emp_serv_pc ec13_emp_manuf_pc secc_cons_pc_log  pc11_pca_p_lit_pc ed_primary_adult ed_middle_adult ed_secondary_adult cons_pc_land_own1_log cons_pc_land_own0_log {
  
    /* rd for shrids with with elevation strategy - include donut */
    areg `var' elev_dummy_`fn' rel_elev_below_`fn' rel_elev_above_`fn' $geo_controls [aw=area_laea] if (`sample_flg' == 1), absorb(subd_id) cluster(subd_id) 

    /* save results */
    save_main_reg_results, varname("`var'") id(elev) dummy(elev_dummy) sample(`sample_flg')  tabfile($out/rd_coef_results_all_appendix.csv) coeffile($out/rd_coef_results_all_coefplot_appendix.csv) prefix(`fn')
  }
}


/* SINUOSITY */
foreach s in 1 2 5 {
  foreach l in 2 5 10 {

    local sin = 0.1*`s' + 1
    
    foreach var in irr_share11 ag_share11 any_water_crop  mech_farm_equip evi_delta_r_ln_mean evi_delta_k_ln_mean irr_share_canal irr_share_tubewell irr_share_oth total_land_acre popdens_poly11_log ec13_emp_pc ec13_agro_pc ec13_emp_serv_pc ec13_emp_manuf_pc secc_cons_pc_log  pc11_pca_p_lit_pc ed_primary_adult ed_middle_adult ed_secondary_adult cons_pc_land_own1_log cons_pc_land_own0_log $age_structure {
    
      /* rd for shrids with specific length and sinuosity */
      areg `var' elev_dummy rel_elev_below rel_elev_above $geo_controls [aw=area_laea] if ($sampelev == 1) & (sin<`sin') & (length_km>`l'), absorb(subd_id) cluster(subd_id)
      save_main_reg_results, varname("`var'") id(elev) dummy(elev_dummy) sample($sampelev)  tabfile($out/rd_coef_results_all_appendix.csv) coeffile($out/rd_coef_results_all_coefplot_appendix.csv) prefix(s`s'_l`l')

      /* run with segment fixed effects  */
      areg `var' elev_dummy rel_elev_below rel_elev_above $geo_controls [aw=area_laea] if ($sampelev == 1) & (sin<`sin') & (length_km>`l'), absorb(id_canal_seg) cluster(id_canal_seg)
      save_main_reg_results, varname("`var'") id(seg) dummy(elev_dummy) sample($sampelev)  tabfile($out/rd_coef_results_all_appendix.csv) coeffile($out/rd_coef_results_all_coefplot_appendix.csv) prefix(s`s'l`l')

      /* run balance */
      global remove tri_mean
      global balance_controls : list global(geo_controls) - global(remove)
      di "$balance_controls"

      areg tri_mean elev_dummy rel_elev_below rel_elev_above $balance_controls [aw=area_laea] if ($sampelev == 1) & (sin<`sin') & (length_km>`l'), absorb(id_canal_seg) cluster(id_canal_seg)
      save_main_reg_results, varname(tri_mean) id(seg) dummy(elev_dummy) sample($sampelev)  tabfile($out/rd_coef_results_all_appendix.csv) prefix(s`s'l`l')

    }
  }
}


/* UNWEIGHTED */
/* main results and sample but unweighted */
foreach var in $ag_outcomes $ec_outcomes urban_marker pop_share_06 age70p_share p_sch m_sch s_sch p_sch_priv m_sch_priv s_sch_priv p_sch_gov m_sch_gov s_sch_gov {
    
  /* ELEVATION */
  /* rd for shrids with with elevation strategy - include donut */
  areg `var' elev_dummy rel_elev_below rel_elev_above $geo_controls if ($sampelev == 1), absorb(subd_id) cluster(subd_id) 

  /* save results - program defined in canals_programs.do */
  save_main_reg_results, varname("`var'") id(elev) dummy(elev_dummy) sample($sampelev) tabfile($out/rd_coef_results_all_appendix.csv) prefix(nowt)

}

/* make all the tables by category - used in the paper */
table_from_tpl, t($ddl/canals/a/appendix_irr_tpl.tex) r($out/rd_coef_results_all_appendix.csv) o($out/appendix_irr.tex)
table_from_tpl, t($ddl/canals/a/appendix_ag_tpl.tex) r($out/rd_coef_results_all_appendix.csv) o($out/appendix_ag.tex)
table_from_tpl, t($ddl/canals/a/appendix_ec_tpl.tex) r($out/rd_coef_results_all_appendix.csv) o($out/appendix_ec.tex)
table_from_tpl, t($ddl/canals/a/appendix_ed_tpl.tex) r($out/rd_coef_results_all_appendix.csv) o($out/appendix_ed.tex)

/* make sinuosity table */
table_from_tpl, t($ddl/canals/a/sinuosity_table_tpl.tex) r($out/rd_coef_results_all_appendix.csv) o($out/sinuosity_table.tex)

/* make the main results table but with the unweighted results (additional robustness) - 04/28/23: now included in the main table as a panel, not as an individual table */
table_from_tpl, t($ddl/canals/a/appendix_nowt_irr_tpl.tex) r($out/rd_coef_results_all_appendix.csv) o($out/appendix_nowt_irr.tex)
table_from_tpl, t($ddl/canals/a/appendix_nowt_ag_tpl.tex) r($out/rd_coef_results_all_appendix.csv) o($out/appendix_nowt_ag.tex)
table_from_tpl, t($ddl/canals/a/appendix_nowt_ec_tpl.tex) r($out/rd_coef_results_all_appendix.csv) o($out/appendix_nowt_ec.tex)
table_from_tpl, t($ddl/canals/a/appendix_nowt_ed_tpl.tex) r($out/rd_coef_results_all_appendix.csv) o($out/appendix_nowt_ed.tex)

/* make all the tables by sample - used in the presentation */
table_from_tpl, t($ddl/canals/a/rd_elev_results_bal_tpl.tex) r($out/rd_coef_results_all_appendix.csv) o($out/app_rd_elev_results_bal.tex)
table_from_tpl, t($ddl/canals/a/rd_elev_results_full_tpl.tex) r($out/rd_coef_results_all_appendix.csv) o($out/app_rd_elev_results_full.tex)
table_from_tpl, t($ddl/canals/a/rd_elev_results_donut_tpl.tex) r($out/rd_coef_results_all_appendix.csv) o($out/app_rd_elev_results_donut.tex)
table_from_tpl, t($ddl/canals/a/rd_elev_results_hole_tpl.tex) r($out/rd_coef_results_all_appendix.csv) o($out/app_rd_elev_results_hole.tex)
table_from_tpl, t($ddl/canals/a/rd_elev_results_control_tpl.tex) r($out/rd_coef_results_all_appendix.csv) o($out/app_rd_elev_results_control.tex)
table_from_tpl, t($ddl/canals/a/rd_elev_results_median_tpl.tex) r($out/rd_coef_results_all_appendix.csv) o($out/app_rd_elev_results_median.tex)
table_from_tpl, t($ddl/canals/a/rd_elev_results_p25_tpl.tex) r($out/rd_coef_results_all_appendix.csv) o($out/app_rd_elev_results_p25.tex)
table_from_tpl, t($ddl/canals/a/rd_comm_results_bal_tpl.tex) r($out/rd_coef_results_all_appendix.csv) o($out/app_rd_comm_results_bal.tex)
table_from_tpl, t($ddl/canals/a/rd_elev_results_full_tpl.tex) r($out/rd_coef_results_all_appendix.csv) o($out/app_rd_elev_results_full.tex)
table_from_tpl, t($ddl/canals/a/rd_elev_results_sin_tpl.tex) r($out/rd_coef_results_all_appendix.csv) o($out/app_rd_elev_results_sin.tex)
table_from_tpl, t($ddl/canals/a/rd_elev_results_seg_tpl.tex) r($out/rd_coef_results_all_appendix.csv) o($out/app_rd_elev_results_seg.tex)
