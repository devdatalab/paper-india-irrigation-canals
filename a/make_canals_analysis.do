/*****************/
/* Configuration */
/*****************/
// Before you run this file, open canals_config.do. Set your global 
// filepaths for your system and run the file.

/****************/
/* Main Results */
/****************/
/* generate main balance table */
do $ccode/a/gen_balance_table.do

/* generate pc51 balance table */
do $ccode/a/gen_pc51_balance_table.do

/* generate main results */
do $ccode/a/gen_main_results.do

/* generate rd figure grid */
do $ccode/a/gen_rd_result_grid.do

/* generate landownership results */
do $ccode/a/gen_landownership.do

/**************/
/* Spillovers */
/**************/
/* run the spillovers analysise */
do $ccode/a/spillovers_analysis.do

/*****************/
/* Town Analysis */
/*****************/
/* run the town analysis - takes 60 hours to run */
do $ccode/a/analyze_town_diff_in_diff.do

/* **********/
/* Appendix */
/* **********/
/* generate the sample description and appendix tables */
do $ccode/a/gen_sample_description.do

/* run analyses with spatial clustering */
do $ccode/a/spatial_correlation.do

/* generate the sample description and appendix tables */
do $ccode/a/gen_appendix_tables.do

/* generate the sensitivity analysis table */
do $ccode/a/sample_sensitivity.do
do $ccode/a/make_sensitivity_table.do

/* generate NSS migration table */
do $ccode/a/migration_nss.do

/***********/
/* Figures */
/***********/
cd $ccode
shell python $ccode/a/make_all_coefplots.py
shell python $ccode/a/land_ownership_coefplot.py
shell python $ccode/a/did_coefplot.py
shell python $ccode/a/plot_canal_completion_time.py

