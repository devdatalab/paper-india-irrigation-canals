/* generate balance table for 1951 census variables using only villages with canals built after 1951 */

/* remove old csv of results */
global f51bal $out/pc51_balance.csv
cap !rm -f $f51bal

/* load data */
use $cdata/pc51_balance_data, clear

/* run balance regs -- looping over pc51 outcomes */
foreach var in pc51_pca_tot_p pc51_sex_ratio pc51_pop_dens_ln pc51_hh_size pc51_lit_rate  {

  /* create temporary sample indicator: needed because save_main_reg_results only takes a binary 1/0 for sample indication */
  cap drop _tempsamp
  gen _tempsamp = ($sampelev == 1) & (`var' != 0) & (pc51_pca_tot_p < 5000) & inrange(year_completed, 1952, 2022)

  /* run regression */
  areg `var' elev_dummy rel_elev_below rel_elev_above $geo_controls [aw=area_laea] if _tempsamp==1, absorb(subd_id) cluster(subd_id)

  /* save results */
  save_main_reg_results, varname("`var'") id(elev) dummy(elev_dummy) sample(_tempsamp) tabfile($f51bal)
  cap drop _tempsamp
}

/* generate table */
table_from_tpl, t($ddl/canals/a/pc51_balance_tpl.tex) r($f51bal) o($out/pc51_balance.tex)
