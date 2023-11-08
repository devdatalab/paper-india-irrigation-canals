/* generate the balance table.*/

/* open the analysis dataset */
use $cdata/canals_analysis_data, clear

/* remove csv files for coefficients */
cap !rm -f $out/balance_rd_$fnsuffix.csv

/*****************/
/* Balance Table */
/*****************/
/* cycle through each balance measure - note $geo_controls is defined in the config */
foreach var in $geo_controls {

  /* remove the variable we are testing from the controls list */
  global remove `var'
  global balance_controls : list global(geo_controls) - global(remove)
  di "$balance_controls"
  
  /* elevation regression: note $sampelev is defined in the config */
  areg `var' elev_dummy rel_elev_below rel_elev_above $balance_controls [aw=area_laea] if $sampelev == 1, absorb(subd_id) cluster(subd_id)

  /* save results - program defined in canals_programs.do */
  save_main_reg_results, varname("`var'") id(elev) dummy(elev_dummy) sample($sampelev) tabfile($out/balance_rd_$fnsuffix.csv) 

  /* command area regression */
  areg `var' comm_dummy near_comm_dist_in near_comm_dist_out $balance_controls [aw=area_laea] if $sampcomm == 1, absorb(near_comm_seg_10km) cluster(near_comm_seg_10km)

  /* save results */
  save_main_reg_results, varname("`var'") id(comm) dummy(comm_dummy) sample($sampcomm) tabfile($out/balance_rd_$fnsuffix.csv)

}

/* relative elevation - limited tables with only main results */
table_from_tpl, t($ccode/a/tpl/rd_elev_balance_tpl.tex) r($out/balance_rd_$fnsuffix.csv) o($out/rd_elev_balance.tex)
table_from_tpl, t($ccode/a/tpl/rd_comm_balance_tpl.tex) r($out/balance_rd_$fnsuffix.csv) o($out/rd_comm_balance.tex)
