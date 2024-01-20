/************/
/* Settings */
/************/
/* load analysis data */
use $cdata/canals_analysis_data, clear

/* keep only what we need */
keep shrid $ag_outcomes $ec_outcomes $geo_controls elev_dummy* rel_elev* *near_comm* comm_dummy* dist_km_canal rural_marker subd_id near_comm_seg_10km* elev_above* comm_out* area_laea pc11_pca_tot_p_r pc11_pca_tot_p id_canal*

/* ensure rug is set to tri_mean */
gen rug = tri_mean

/* save a tmp file we will use to speed up i/o  */
save $tmp/canals_working_sample, replace

/*********************/
/* Calculate Results */
/*********************/
/* clear a file to store sensitivity results */
cap erase $out/sensitivity_results.csv
append_to_file using $out/sensitivity_results.csv, s(bw_elev,bw_comm,canal_dist,river_dist,rugbal_elev,rugbal_comm,spec,variable,coef,pvalue,stars,se,mean,samp,r2)

/* clear a file to store sensitivity results just for a coefplot */
cap erase $out/sensitivity_results_coefplot.csv
append_to_file using $out/sensitivity_results_coefplot.csv, s(bw_elev,bw_comm,canal_dist,river_dist,rugbal_elev,rugbal_comm,spec,variable,coef,up95,low95)

/* cycle through bandwidth on elevation options */
disp_nice "START: $S_TIME"
foreach bwe in 15 25 50 75 100 {

  /* generate the cwe- this cycles through the same number of steps as bwe but starts at 12.5 and uses 2.5 increments */
  local bwc = (`bwe' - 20)/2 + 12.5

  /* cycle through options on distance to canal */
  foreach c in 5 10 15 {

    /* cycle through options on distance to river */
    foreach r in 0 {

      /* cycle through options on percent difference in ruggedness */
      foreach pdiff in 0.1 0.25 0.5 {

        /* get sample for these parameters */        
        qui define_canals_sample, sample_flg_elev(bal_elev) sample_flg_comm(bal_comm) bw_elev(`bwe') bw_comm(`bwc') canal_dist(`c') river_dist(0) rugbal_elev(`pdiff') rugbal_comm(`pdiff') donut_elev(2.5) donut_comm(2.5) full("")

        /***********/
        /* Balance */
        /***********/
        foreach var in tri_mean rainfall_annual_mean {

          /* remove the variable we are testing from the controls list */
          global remove `var'
          global balance_controls : list global(geo_controls) - global(remove)

          /* elevation regression */
          areg `var' elev_dummy rel_elev_below rel_elev_above $balance_controls [aw=area_laea] if bal_elev == 1, absorb(subd_id) cluster(subd_id)

          /* get coefficient, standard error variable, and pvalue of interest */
          matrix row=r(table)
          local elev_`var'_coef = row[1,1]
          local elev_`var'_coef: di %5.3f `elev_`var'_coef'
          local elev_`var'_se = row[2,1]
          local elev_`var'_se: di %5.3f `elev_`var'_se'
          local elev_`var'_p = row[4,1]
          local elev_`var'_p: di %5.3f `elev_`var'_p'

          /* record R2 and sample size */
          local elev_`var'_r2 = e(r2_a)
          local elev_`var'_r2: di %5.2f `elev_`var'_r2'
          local elev_`var'_samp = e(N)

          /* get pvalue stars - stored as `star' */
          count_stars, p(`elev_`var'_p')
          local stars_elev = "`r(stars)'"

          /* get control group mean */
          sum `var' if (bal_elev == 1) & (elev_dummy == 0) [aw=area_laea]
          local mean_elev = r(mean)
          local elev_`var'_mean: di %5.3f `mean_elev'

          /* command area regression */
          areg `var' comm_dummy near_comm_dist_in near_comm_dist_out $balance_controls [aw=area_laea] if bal_comm == 1, absorb(near_comm_seg_10km) cluster(near_comm_seg_10km)

          /* get coefficient and standard error variable of interest */
          matrix row=r(table)
          local comm_`var'_coef = row[1,1]
          local comm_`var'_coef: di %5.3f `comm_`var'_coef'
          local comm_`var'_se = row[2,1]
          local comm_`var'_se: di %5.3f `comm_`var'_se'
          local comm_`var'_p = row[4,1]
          local comm_`var'_p: di %5.3f `comm_`var'_p'
  
          /* record R2 and sample size */
          local comm_`var'_r2 = e(r2_a)
          local comm_`var'_r2: di %5.2f `comm_`var'_r2'
          local comm_`var'_samp = e(N)

          /* get pvalue stars - stored as `star' */
          count_stars, p(`comm_`var'_p')
          local stars_comm = "`r(stars)'"

          /* get control group mean */
          sum `var' if (bal_comm == 1) & (comm_dummy == 0) [aw=area_laea]
          local mean_comm = r(mean)
          local comm_`var'_mean: di %5.3f `mean_comm'

          /* insert everything into one csv - for table*/
          append_to_file using $out/sensitivity_results.csv, s(`bwe',`bwc',`c',`r',`pdiff',`pdiff',elev,`var',`elev_`var'_coef',`elev_`var'_p',`stars_elev',`elev_`var'_se',`elev_`var'_mean',`elev_`var'_samp',`elev_`var'_r2')
          append_to_file using $out/sensitivity_results.csv, s(`bwe',`bwc',`c',`r',`pdiff',`pdiff',comm,`var',`comm_`var'_coef',`comm_`var'_p',`stars_comm',`comm_`var'_se',`comm_`var'_mean',`comm_`var'_samp',`comm_`var'_r2')
        }

        /**************/
        /* RD Results */
        /**************/
        /* loop over variables to run rd */
        foreach var in irr_share11 evi_delta_r_ln_mean popdens_poly11_log ec13_emp_pc {
  
          /* get label of variable */
          local title: var label `var'
  
          /* ELEVATION */
          /* rd for shrids with with elevation strategy - include donut */
          areg `var' elev_dummy rel_elev_below rel_elev_above $geo_controls [aw=area_laea] if (bal_elev == 1), absorb(subd_id) cluster(subd_id)

          /* get coefficient and standard error variable of interest */
          matrix row=r(table)
          local elev_`var'_coef = row[1,1]
          local elev_`var'_coef: di %5.3f `elev_`var'_coef'
          local elev_`var'_se = row[2,1]
          local elev_`var'_se: di %5.3f `elev_`var'_se'
          local elev_`var'_p = row[4,1]
          local elev_`var'_p: di %5.3f `elev_`var'_p'

          /* get coefficient and error bounds for coefplot */
          local elev_low95 =row[5,1]
          local elev_up95 =row[6,1]
          local elev_coef = _coef[elev_dummy]

          /* get control group mean */
          qui sum `var' if (bal_elev == 1)  & (elev_dummy == 0) [aw=area_laea]
          local mean_elev = r(mean)
          local elev_`var'_mean: di %5.3f `mean_elev'

          /* record R2 and sample size */
          local elev_`var'_r2 = e(r2_a)
          local elev_`var'_r2: di %5.2f `elev_`var'_r2'
          local elev_`var'_samp = e(N)

          /* get stanard deviation */
          qui sum `var' if (bal_elev == 1) & (elev_dummy == 0) [aw=area_laea]
          local sd = `r(sd)'
  
          /* normalize coefficients by standard deviation */
          local elev_coef = `elev_coef' / `sd'
          local elev_low95 = `elev_low95' / `sd'
          local elev_up95 = `elev_up95' / `sd'

          /* get pvalue stars - stored as `star' */
          count_stars, p(`elev_`var'_p')
          local stars_elev = "`r(stars)'"

          /* COMMAND AREA */
          areg `var' comm_dummy near_comm_dist_in near_comm_dist_out $geo_controls [aw=area_laea] if (bal_comm == 1), absorb(near_comm_seg_10km) cluster(near_comm_seg_10km)

          /* get coefficient and standard error variable of interest */
          matrix row=r(table)
          local comm_`var'_coef = row[1,1]
          local comm_`var'_coef: di %5.3f `comm_`var'_coef'
          local comm_`var'_se = row[2,1]
          local comm_`var'_se: di %5.3f `comm_`var'_se'
          local comm_`var'_p = row[4,1]
          local comm_`var'_p: di %5.3f `comm_`var'_p'

          /* get coefficient and error bounds for coefplot */
          local comm_low95 = row[5,1]
          local comm_up95 = row[6,1]
          local comm_coef = _coef[comm_dummy]

          /* get control group mean */
          qui sum `var' if (bal_comm == 1) & (comm_dummy == 0) [aw=area_laea]
          local mean_comm = r(mean)
          local comm_`var'_mean: di %5.3f `mean_comm'
          
          /* record R2 and sample size */
          local comm_`var'_r2 = e(r2_a)
          local comm_`var'_r2: di %5.2f `comm_`var'_r2'
          local comm_`var'_samp = e(N)

          /* get stanard deviation */
          qui sum `var' if (bal_comm == 1) & (comm_dummy == 0) [aw=area_laea]
          local sd = `r(sd)'
  
          /* normalize coefficients by standard devation */
          local comm_coef = `comm_coef' / `sd'
          local comm_low95 = `comm_low95' / `sd'
          local comm_up95 = `comm_up95' / `sd'

          /* get pvalue stars - stored as `star' */
          count_stars, p(`comm_`var'_p')
          local stars_comm = "`r(stars)'"

          /* insert everything into one csv - for table*/
          append_to_file using $out/sensitivity_results.csv, s(`bwe',`bwc',`c',`r',`pdiff',`pdiff',elev,`var',`elev_`var'_coef',`elev_`var'_p',`stars_elev',`elev_`var'_se',`elev_`var'_mean',`elev_`var'_samp',`elev_`var'_r2')
          append_to_file using $out/sensitivity_results.csv, s(`bwe',`bwc',`c',`r',`pdiff',`pdiff',comm,`var',`comm_`var'_coef',`comm_`var'_p',`stars_comm',`comm_`var'_se',`comm_`var'_mean',`comm_`var'_samp',`comm_`var'_r2')

          /* insert values just for the coefplots*/
          append_to_file using $out/sensitivity_results_coefplot.csv, s(`bwe',`bwc',`c',`r',`pdiff',`pdiff',elev,`var',`elev_`var'_coef',`elev_up95',`elev_low95')
          append_to_file using $out/sensitivity_results_coefplot.csv, s(`bwe',`bwc',`c',`r',`pdiff',`pdiff',comm,`var',`comm_`var'_coef',`comm_up95',`comm_low95')
        }
      }
    }
  }

disp_nice "END: $S_TIME"        
