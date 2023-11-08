/* load programs for running regression with Conley standard errors */
do $ccode/ado/ols_spatial_HAC.do
do $ccode/ado/reg2hdfespatial.do
/* need to install this package that reg2hdfespatial.do relies on  */
/* ssc install hdfe */

/* open the data */
use $cdata/canals_analysis_data, clear
cap drop _merge

/* spatial correlation */
gen time = 1

/* output to the same csv as the other appendix tables */
global fout $out/rd_coef_results_all_appendix.csv

/* cycle through all variables to produce outputs  */
foreach var in irr_share11 irr_share_canal irr_share_tubewell irr_share_oth ag_share11 evi_delta_k_ln_mean evi_delta_r_ln_mean any_water_crop mech_farm_equip popdens_poly11_log ec13_emp_pc ec13_emp_serv_pc ec13_emp_manuf_pc ed_primary_adult ed_middle_adult ed_secondary_adult pc11_pca_p_lit_pc secc_cons_pc_log cons_pc_land_own1_log cons_pc_land_own0_log {

  /* rd for shrids with with elevation strategy - include donut */
  reg2hdfespatial `var' elev_dummy rel_elev_below rel_elev_above $geo_controls if $sampelev == 1 [aw=area_laea], lat(shrid_lat) lon(shrid_lon) t(time) p(subd_id) dist(100) 
  
  /* save results for appendix table - program defined in canals_programs.do */
  save_main_reg_results, varname("`var'") id(elev) dummy(elev_dummy) sample($sampelev) tabfile($fout) prefix("conley")

  /* save results again in a conley-onlye file (because these take so long to run we don't want to blow-away results if we re-run the other appendix table results */
  save_main_reg_results, varname("`var'") id(elev) dummy(elev_dummy) sample($sampelev) tabfile($out/rd_elev_results_conley.csv) 
  
}

/* each panel individually for a standalone table (04/28/23- this table isn't currently used in the paper, instead these results
are included as Panel G of the robustness tables in the appendix. That panel is output from a/gen_appendix_tables.do. */
table_from_tpl, t($ccode/a/tpl/rd_elev_results_irr_tpl.tex) r($out/rd_elev_results_conley.csv) o($out/rd_elev_results_irr_conley.tex)
table_from_tpl, t($ccode/a/tpl/rd_elev_results_ag_tpl.tex) r($out/rd_elev_results_conley.csv) o($out/rd_elev_results_ag_conley.tex)
table_from_tpl, t($ccode/a/tpl/rd_elev_results_ec_tpl.tex) r($out/rd_elev_results_conley.csv) o($out/rd_elev_results_ec_conley.tex)
table_from_tpl, t($ccode/a/tpl/rd_elev_results_ed_tpl.tex) r($out/rd_elev_results_conley.csv) o($out/rd_elev_results_ed_conley.tex)

