/* generate the land ownership results.*/

/* open the analysis data */
use $cdata/canals_analysis_data, clear

/******************/
/* Land Ownership */
/******************/
/* list of land ownership X ed vars */
local landown_ed ed_p_young_land_own0 ed_m_young_land_own0 ed_s_young_land_own0 ed_p_full_land_own0 ed_m_full_land_own0 ed_s_full_land_own0 ed_p_old_land_own0 ed_m_old_land_own0 ed_s_old_land_own0 ed_p_young_land_own1 ed_m_young_land_own1 ed_s_young_land_own1 ed_p_full_land_own1 ed_m_full_land_own1 ed_s_full_land_own1 ed_p_old_land_own1 ed_m_old_land_own1 ed_s_old_land_own1

/* list of land ownerships aggregates of consumption */
local landown_agg cons_pc_lh_qrt251_log cons_pc_lh_qrt501_log cons_pc_lh_qrt751_log cons_pc_lh_qrt1001_log

/* remove results csv */
cap !rm -f $out/land_ownership_$fnsuffix.csv
cap !rm -f $out/rd_land_ownership_$fnsuffix.csv

/* cycle through outcomes to run rd regression */
foreach var in secc_cons_pc_log popdens_poly11_log land_own1 land_hold_land_own1_log land_hold_all_log cons_pc_land_own1_log cons_pc_land_own0_log `landown_agg' `landown_ed' {
  
  /* rd for shrids with with elevation strategy */
  areg `var' elev_dummy rel_elev_below rel_elev_above $geo_controls [aw=area_laea] if ($sampelev == 1), absorb(subd_id) cluster(subd_id)

  /* save results - program defined in canals_programs.do */
  save_main_reg_results, varname("`var'") id(elev) dummy(elev_dummy) sample($sampelev) tabfile($out/rd_land_ownership_$fnsuffix.csv) coeffile($out/land_ownership_$fnsuffix.csv) 

}

table_from_tpl, t($ddl/canals/a/land_ownership_results_tpl.tex) r($out/rd_land_ownership_$fnsuffix.csv) o($out/rd_land_ownership_results.tex)

