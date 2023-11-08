/* generate sample description table. */

/* open the analysis dataset */
use $cdata/canals_analysis_data, clear

/* define list of vars used in paper */
global papervars irr_share11 irr_share_canal irr_share_tubewell irr_share_oth ag_share11 evi_delta_k_ln_mean evi_delta_r_ln_mean any_water_crop mech_farm_equip popdens_poly11_log ec13_emp_pc ec13_emp_serv_pc ec13_emp_manuf_pc secc_cons_pc_log ed_primary_adult ed_middle_adult ed_secondary_adult pc11_pca_p_lit_pc pc11_vd_tar_road 

/**********************/
/* Sample Description */
/**********************/
cap !rm -f $out/sample_description.csv

/* FULL SAMPLE  */
/* line used in the build to create this sample (don't need to run this, it's here for reference) */
// define_canals_sample, sample_flg_elev(full_sample_elev) sample_flg_comm(full_sample_comm) bw_elev(50) bw_comm(25) donut_elev(0) donut_comm(0) canal_dist(10) river_dist(0) rugbal_elev(1) rugbal_comm(1)

/* full sample, elevation */
get_descriptive_stats $papervars if full_sample_elev == 1, treatvar(elev_dummy) csvfile($out/sample_description.csv) suffix(elev_full)

/* full sample, command area */
get_descriptive_stats $papervars if full_sample_comm == 1, treatvar(comm_dummy) csvfile($out/sample_description.csv) suffix(comm_full)


/* DONUT HOLE */
/* line used in the build to create this sample: remove donut hole */
// define_canals_sample, sample_flg_elev(donut_sample_elev) sample_flg_comm(donut_sample_comm) bw_elev(50) bw_comm(25) donut_elev(2.5) donut_comm(2.5) canal_dist(10) river_dist(0) rugbal_elev(1) rugbal_comm(1)

/* donut hole, elevation */
get_descriptive_stats $papervars if donut_sample_elev == 1, treatvar(elev_dummy) csvfile($out/sample_description.csv) suffix(elev_donut)

/* donut hole, command area */
get_descriptive_stats $papervars if donut_sample_comm == 1 & !inrange(near_comm_dist, -2.5, 2.5), treatvar(comm_dummy) csvfile($out/sample_description.csv) suffix(comm_donut)


/* RUGGEDNESS BALANCE */
/* line used in the build to create this sample: balance on ruggedness and remove shrids with canals inside */
// define_canals_sample, sample_flg_elev(bal_sample_elev) sample_flg_comm(bal_sample_comm) bw_elev(50) bw_comm(25) donut_elev(2.5) donut_comm(2.5) canal_dist(10) river_dist(0) rugbal_elev(0.25) rugbal_comm(0.25)

/* balanced sample, elevation */
get_descriptive_stats $papervars if rug_balance_elev == 1, treatvar(elev_dummy) csvfile($out/sample_description.csv) suffix(elev_bal)

/* balanced sample, command area */
get_descriptive_stats $papervars if rug_balance_comm == 1, treatvar(comm_dummy) csvfile($out/sample_description.csv) suffix(comm_bal)

/* ALL INDIA */
/* this fills in 1 for all observations */
gen all_india = 1 if !mi(pc11_pca_tot_p)
replace all_india = 0 if mi(all_india)

/* get descriptive stats for all of India */
get_descriptive_stats $papervars if all_india == 1, treatvar(all_india) csvfile($out/sample_description.csv) suffix(all_india)

/* create table */
table_from_tpl, t($ccode/a/sample_description_tpl.tex) r($out/sample_description.csv) o($out/sample_description.tex)


