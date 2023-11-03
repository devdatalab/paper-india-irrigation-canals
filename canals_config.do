/* CHANGE THESE: user-specific filepaths */
global ccode ~/ddl/canals
global cdata ~/iec/canals/clean
global cdata_all ~/iec/canals
global out ~/iec/output/canals
global tmp /scratch/acampion

/* DO NOT CHANGE ANY SETTINGS BELOW */
/* set the globals for lists of variables used in the analysis */
global ag_outcomes irr_share11 ag_share11 any_water_crop count_water_crop mech_farm_equip  evi_delta_r_ln_mean evi_delta_k_ln_mean irr_share_canal irr_share_tubewell irr_share_oth total_land_acre land_hold_land_own1 two_crop_acre
global ec_outcomes popdens_poly11 popdens_poly11_log ec13_emp_pc ec13_agro_pc ec13_emp_serv_pc ec13_emp_manuf_pc secc_cons_pc_rural secc_cons_pc_log  pc11_vd_tar_road pc11_pca_p_lit_pc pc11_vd_s_sch pc11_vd_m_sch pc11_vd_all_hosp pc11_vd_power_agr ed_primary_adult ed_middle_adult ed_secondary_adult cons_pc_land_own0_log cons_pc_land_own0 cons_pc_land_own1_log cons_pc_land_own1 high_inc1 land_own1 ed_p_full_land_own0 ed_m_full_land_own0 ed_s_full_land_own0 ed_p_full_land_own1 ed_m_full_land_own1 ed_s_full_land_own1
global age_structure age0_9_share age10_19_share age20_29_share age30_39_share age40_49_share age50_59_share age60_69_share age70_79_share age80_share pop_share_06
global geo_controls tri_mean dist_km_river rainfall_annual_mean dist_km_coast mean_wetlandrice_igf mean_wheat_igf mean_temp root_cond

/* define the filename suffix that will be used to refer to our main specification */
global fnsuffix bal

/* globals for elevation and command area strategy sample variables */
global sampelev rug_balance_elev
global sampcomm rug_balance_comm

/* load tools and programs */
do $ccode/canals_programs.do
do $ccode/canals-tools.do

