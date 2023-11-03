/**********************************************************************************/
/* program get_descriptive_stats : get descriptive stats for a given sample

varlist: list of variables to report weighted means of
treatvar: the treatment variable, to get the percent treatment
csv: csv file to write out means to
suffix: the suffix for this sample to be added to variable names in the csv

reports out: sample size, percent treatment, and mean of each variable
*/
/***********************************************************************************/
cap prog drop get_descriptive_stats
prog def get_descriptive_stats

  syntax varlist [if], treatvar(string) csvfile(string) suffix(string)

  preserve

  /* keep only the sample */
  if !mi("`if'") {
    keep `if'
  }

  /* loop through variables and calculate means */
  foreach var in `varlist' {

    /* get weighted mean */
    qui sum `var' [aw=area_laea]
    local meanvar = `r(mean)'
    
    /* insert into the file */
    insert_into_file using `csvfile', key(`var'_`suffix') value(`meanvar') format(%5.3f)
    local mean
  }

  /* get the full sample count */
  qui count
  local N = `r(N)'

  /* get the percent treatment */
  qui count if `treatvar' == 1
  local per_t = int((`r(N)' / `N') * 100)

  /* write out sample size and percent treatment */
  insert_into_file using `csvfile', key(N_`suffix') value(`N') format(%15.0fc)
  insert_into_file using `csvfile', key(per_t_`suffix') value(`per_t') format(%3.0f)

  restore

end
/* *********** END program get_descriptive_stats ***************************************** */

/**********************************************************************************/
/* program save_main_reg_results : save regression results for tables and coefplots
of the main results. 

varname: dependent variable for this regression result
id: unique name added to the beginning of every variable to identify it in the csv
dummy: the treatment dummy (elev_dummy or comm_dummy)
sample: the sample used for this regression ($sampcomm or $sampelev)
reffile: filename for csv where results are saved as a reference
tabfile: filename for csv where results are saved to be pulled into a table 
coeffile: filename for csv where results are saved to be used for coefplot  */
/***********************************************************************************/
cap prog drop save_main_reg_results
prog def save_main_reg_results, rclass

  syntax, varname(string) id(string) dummy(string) sample(string) tabfile(string) [coeffile(string) reffile(string) prefix(string)]

  /* get coefficient and standard error variable of interest */
  matrix row=r(table)
  local coef = row[1,1]
  local coef: di %5.3f `coef'
  local se = row[2,1]
  local se: di %5.3f `se'

  /* get coefficient and error bounds for coefplot */
  local low95 =row[5,1]
  local up95 =row[6,1]

  /* get control group mean */
  qui sum `varname' if (`sample'== 1) & (`dummy' == 0) [aw=area_laea]
  local mean = r(mean)
  local mean: di %5.3f `mean'

  /* record R2 and sample size */
  local r2 = e(r2_a)
  local r2: di %5.2f `r2'
  local samp = e(N)
  local samp: di %7.0fc `samp'

  /* get standard deviation */
  qui sum `varname' if (`sample' == 1) & (`dummy' == 0) [aw=area_laea]
  local sd = `r(sd)'
  
  /* normalize coefficients by standard deviation */
  local coef_norm = `coef' / `sd'
  local low95_norm = `low95' / `sd'
  local up95_norm = `up95' / `sd'

  /* get pvalue stars - stored as `star' */
  local pvalue = row[4,1]
  count_stars, p(`pvalue')
  local stars = "`r(stars)'"

  /* append stars to the coef */
  local coef_str = "`coef'`stars'"

  /* output to reference file if specified */
  if "`reffile'" != "" {
    append_est_to_file using `reffile', s("`varname'") b(`dummy')
  }

  /* make a varname with prefix if it's specified */
  if "`prefix'" != "" {
    local varname `prefix'_`varname'
  }

  /* insert coefficients into csv if there is a file specified - for coefplot */
  if "`coeffile'" != "" {
    foreach v in coef up95 low95 {
      insert_into_file using `coeffile', key(`varname'_`id'__`v') value(``v'') format(%5.4f)
    }
  }

  /* insert everything into one csv - for table*/
  /* the coef needs to be string format if there are stars */
  if "`stars'" != "" insert_into_file using `tabfile', key(`varname'_`id'_coef) value(`coef_str') format(%s)
  else if "`stars'" == "" insert_into_file using `tabfile', key(`varname'_`id'_coef) value(`coef') format(%5.3f)

  /* sample size has 0 significant digits */
  insert_into_file using `tabfile', key(`varname'_`id'_samp) value(`samp') format(%15.0fc)

  /* standard error and mean should have 3 significant digits*/
  foreach v in se mean {
    insert_into_file using `tabfile', key(`varname'_`id'_`v') value(``v'') format(%5.3f)
  }

  /* r2 just has 2 significant digits */
  insert_into_file using `tabfile', key(`varname'_`id'_r2) value(`r2') format(%5.2f)

  return local res_coef `"`coef_str'"'
  return local res_se `"`se'"'
  return local res_mean `"`mean'"'  
  
end
/* *********** END program save_main_reg_results ***************************************** */


/**********************************************************************************/
/* program save_nss_migration_results : save regression results for nss migration 

varname: dependent variable for this regression result
id: unique name added to the beginning of every variable to identify it in the csv
dummy: the treatment dummy (elev_dummy or comm_dummy)
samp: the sample used for this regression ($sampcomm or $sampelev)
tabfile: filename for csv where results are saved to be pulled into a table */
/***********************************************************************************/
cap prog drop save_nss_migration_results
prog def save_nss_migration_results

  syntax, varname(string) id(string) tabfile(string) [prefix(string) sector(real 0)]

  /* check for sector subsample. if there is no subsample, include all observations */
  cap drop _subsamp
  if `sector' == 0 {
    gen _subsamp = 1
    local sector 1
  }

  /* otherwise set the subsample variable to be the same as sector */
  else {
    gen _subsamp = sector
    local sector = int(`sector')
  }

  /* get coefficient and standard error variable of interest */
  matrix row=r(table)
  local coef = row[1,1]
  local coef: di %5.3f `coef'
  local se = row[2,1]
  local se: di %5.3f `se'

  /* get coefficient and standard error variable of base year */
  matrix row=r(table)
  local coef2 = row[1,2]
  local coef2: di %5.3f `coef2'
  local se2 = row[2,2]
  local se2: di %5.3f `se2'

  /* get control group mean */
  qui sum `varname' if _subsamp == `sector'
  local mean = r(mean)
  local mean: di %5.3f `mean'

  /* record R2 and sample size */
  local r2 = e(r2_a)
  local r2: di %5.2f `r2'
  local samp = e(N)
  local samp: di %7.0fc `samp'

  /* get pvalue stars - stored as `star' */
  local pvalue = row[4,1]
  count_stars, p(`pvalue')
  local stars = "`r(stars)'"

  /* append stars to the coef */
  local coef_str = "`coef'`stars'"

  /* get pvalue stars - stored as `star' */
  local pvalue2 = row[4,2]
  count_stars, p(`pvalue')
  local stars2 = "`r(stars)'"

  /* append stars to the coef */
  local coef2_str = "`coef2'`stars2'"

  /* make a varname with prefix if it's specified */
  if "`prefix'" != "" {
    local varname `prefix'_`varname'
  }

  /* insert everything into one csv - for table*/
  /* the coef needs to be string format if there are stars */
  if "`stars'" != "" insert_into_file using `tabfile', key(gain_`id'_coef) value(`coef_str') format(%s)
  else if "`stars'" == "" insert_into_file using `tabfile', key(gain_`id'_coef) value(`coef') format(%5.3f)
  insert_into_file using `tabfile', key(gain_`id'_se) value(`se') format(%5.3f)

  if "`stars2'" != "" insert_into_file using `tabfile', key(base_`id'_coef) value(`coef2_str') format(%s)
  else if "`stars2'" == "" insert_into_file using `tabfile', key(base_`id'_coef) value(`coef2') format(%5.3f)
  insert_into_file using `tabfile', key(base_`id'_se) value(`se2') format(%5.3f)

  /* sample size has 0 significant digits */
  insert_into_file using `tabfile', key(`id'_samp) value(`samp') format(%15.0fc)

  /* standard error and mean have 3 significant digits */
  foreach v in se mean {
    insert_into_file using `tabfile', key(`id'_`v') value(``v'') format(%5.3f)
  }

  /* r2 just has 2 significant digits */
  insert_into_file using `tabfile', key(`id'_r2) value(`r2') format(%5.2f)

  /* drop subsamp variable */
  drop _subsamp

end
/* *********** END program save_nss_migration_results ***************************************** */


/**********************************************************************************/
/* program create_balanced_groups : create balanced groups of shrids for canals analysis

varlist: variable identifying the group
distvar: variable containing distance measure (shrid to command area boundary)
INTDummy: variable identifying if the shrid is interior to the command area
DList: list of distances from command area boundary
NList: lits of the number of shrids to require at each distance threshold
 */
/***********************************************************************************/
cap prog drop create_balanced_groups
prog def create_balanced_groups

  syntax varlist, distvar(string) INTdummy(string) DList(string) NList(string) [MAXband(real 20.0)]


  /* replace the 0/1 dummy with int and ext to make variable names clearer */
  tostring `intdummy', replace
  replace `intdummy' = "int" if `intdummy' == "1"
  replace `intdummy' = "ext" if `intdummy' == "0"
  
  /* add 0 to beginning of dlist */
  local _dlist 0

  /* create _dlist with added 0 at beginning */
  foreach i in `dlist' {
    local _dlist `_dlist' `i'
  }

  /* get count of elements in dlist */
  local numel : word count `dlist'

  /* tokenize _dlist */
  tokenize "`_dlist'"

  /* create an empty list to store the variables we create */
  local distance_bands

  /* loop over number of elements in dlist to count shrids within distance bands 
     we add 0 to the beginning of the list so that we count wihtin bands 0-x1, 
     x1-x2 for distances x1, x2, etc. in dlist.*/
  forvalues i = 1/`numel' {
    local d0 = `: word `i' of `_dlist''
    local i1 = `i' + 1
    local d1 = `: word `i1' of `_dlist''

    /* mark if the shrid is d1 km away from the command area boundary 
       and the shrid is less than the maximum bandwidth from the boundary */
    gen _dist_`d1'km = 1 if inrange(`distvar', `d0', `d1') & (`distvar' <= `maxband')
    replace _dist_`d1'km = 0 if mi(_dist_`d1'km)

    /* add this variable to our list of distance bands */
    local distance_bands `distance_bands' _dist_`d1'km
  }

  /* count the number of interior and exterior shrids in each distance band
     for each grouping */
  collapse (sum) `distance_bands' , by(`varlist' `intdummy')

  /* rehsape to wide to make the data have 1 row per group, and columns
     for interior and exterior counts */
  reshape wide `distance_bands', i(`varlist') j(`intdummy') s

  /* cycle through our dlist and corresponding numlist to check if 
     each shrid has the appropriate  */
  forvalues i = 1/`numel' {

    /* define the distance and number variables */
    local d = `: word `i' of `dlist''
    local n = `: word `i' of `nlist''

    /* make sure missings are filled with 0 */
    replace _dist_`d'kmext = 0 if mi(_dist_`d'kmext)
    replace _dist_`d'kmint = 0 if mi(_dist_`d'kmint)

    /* there is balance for this distance band if there are enough shrids in
       both the exterior and interior band at this distance */
    gen _bal_`d'km = 1 if (_dist_`d'kmext >= `n') & (_dist_`d'kmint >= `n')
    replace _bal_`d'km = 0 if mi(_bal_`d'km) 
  }

  /* get the sum of the balance indicators for each distance band */
  egen balance = rowtotal(_bal_*)

  /* in order for each shrid to be balanced across all groups, it needed a "1"
     in each balance category,unless that balance category had a 0 requirement.
     so the rowtotal should be the number of elements in nlist, minus any 0's. */
  local _nlist

  /* get the list of the required number, dropping any zeros */
  foreach i in `nlist' {
    if `i' != 0 {
      local _nlist `_nlist' `i'
    }
  }
  
  /* get the required number of observationsto define a balanced group by counting all the elements */
  local required_obs : word count `_nlist'  

  /* assign the shrid as not balanced if it doesn't meet the required score, 
     otherwise mark it as balanced if it does meet that score. */
  replace balance = 0 if balance != `required_obs'
  replace balance = 1 if balance == `required_obs'

end
/* *********** END program create_balanced_groups ***************************************** */



/**********************************************************************************/
/* program apply_balance_criterion : Insert description here */
/***********************************************************************************/
cap prog drop apply_balance_criterion
prog def apply_balance_criterion
  syntax varlist, id(string) commd(string) distvar(string) [dist(real 1.0) wt(string) thresh(real 0.5)]
  preserve
  
  /* keep only those a certain distance from the boundary */
  keep if `distvar' < `dist'

  /* if no weight is specified, make an equal dummy */
  if "`wt'" == "" {
    local wt wt
    gen wt = 1
  }

  /* get the average value on either side of the boundary */
  collapse (mean) avg=`varlist' [aw=`wt'], by(`id' `commd')

  /* reshape to get the internal and external averages as columns */
  reshape wide avg, i(`id') j(`commd')

  /* get the mean of internal and external averages */
  egen avg_mean = rmean(avg0 avg1)

  /* get the percent difference between the two */
  gen avg_diff = abs(avg0 - avg1) / avg_mean

  /* kep if the percent difference is less than 50% */
  keep if avg_diff < `thresh'

  /* keep only the group id's that qualify */
  keep `id'

  /* create balance indicator */
  gen balance_`varlist' = 1

  /* save as a temp file */
  save $tmp/balance_id_`varlist', replace
  
  /* return original dataset */
  restore
end
/* *********** END program apply_balance_criterion ***************************************** */


/**********************************************************************************/
/* program create_weights : given a sample and weighting variable, calculate weights

varlist: the variable for weighting
if: define the sample
wtvar: the name of the calculated weighting variable
 */
/***********************************************************************************/
cap prog drop create_weights
prog def create_weights

  syntax varlist [if], wtvar(string)

  /* drop a total weight variable if it exists */
  cap drop total_wt

  /* drop the variable to be calculated if it exists */
  cap drop `wtvar'

  /* calculate the total weight */
  egen total_wt = sum(`varlist') `if'

  /* calculate the weights*/
  gen `wtvar' = (`varlist' / total_wt) `if'
  
end
/* *********** END program create_weights ***************************************** */


/**********************************************************************************/
/* program record_sample_description : Insert description here */
/***********************************************************************************/
cap prog drop record_sample_description
prog def record_sample_description

  syntax, template(string) OUTfile(string)
  
  /* insert most important details about regression into csv to be included in slides  */
  insert_into_file using $ddl/canals/a/sample_description.csv, key(controls_elev) value("Ruggedness, Distance to canal") format(%s)
  insert_into_file using $ddl/canals/a/sample_description.csv, key(controls_comm) value("Ruggedness, Relative elevation to canal") format(%s)

  /* fixed effects */
  insert_into_file using $ddl/canals/a/sample_description.csv, key(FE) value("canal-subdistrict") format(%s)

  /* Elevation: get sample size and save in csv */
  qui count if $sampelev == 1
  local N_elev = `r(N)'
  insert_into_file using $ddl/canals/a/sample_description.csv, key(N_elev) value(`N_elev') format(%15.0fc)

  /* Command Area: get sample size and save in csv */
  qui count if $sampcomm == 1
  local N_comm = `r(N)'
  insert_into_file using $ddl/canals/a/sample_description.csv, key(N_comm) value(`N_comm') format(%15.0fc)

  /* Elevation: get percent treatment */
  qui count if $sampelev == 1 & elev_dummy == 1
  local per_t_elev = int((`r(N)' / `N_elev') * 100)
  insert_into_file using $ddl/canals/a/sample_description.csv, key(per_t_elev) value(`per_t_elev') format(%3.0f)

  /* Command Area: get percent treatment */
  qui count if $sampcomm == 1 & comm_dummy == 1
  local per_t_comm = int((`r(N)' / `N_comm') * 100)
  insert_into_file using $ddl/canals/a/sample_description.csv, key(per_t_comm) value(`per_t_comm') format(%3.0f)

  /* save the sample description note  */
  table_from_tpl, t($ddl/canals/assets/fignotes/regress_desc_note_tpl.tex) r($ddl/canals/a/sample_description.csv) o($out/sample_description_$fnsuffix.tex)

end
/* *********** END program record_sample_description ***************************************** */



/**********************************************************************************/
/* program get_pvalue_stars : Insert description here */
/***********************************************************************************/
cap prog drop get_pvalue_stars
prog def get_pvalue_stars
  syntax, variable(string)

  /* reset stars global to nothing */
  global stars ""

  /* get t value */
  local t = _b[`variable']/_se[`variable']
  
  /* calculate pvalue */
  local p = 2*ttail(e(df_r),abs(`t'))

  /* convert to stars */
  if `p' <= 0.1 & `p' > 0.05 {
    global stars "*"
  }

  if `p' <= 0.05 & `p' > 0.001 {
    global stars "**"
  }

  if `p' <= 0.001 & `p' >= 0 {
    global stars "***"
  }

  else {
    global stars ""
  }

end
/* *********** END program get_pvalue_stars ***************************************** */

/**********************************************************************************/
/* program save_town_event_reg : Insert description here */
/***********************************************************************************/
cap prog drop save_town_event_reg
prog def save_town_event_reg

  syntax, coefs(string) csv(string) name(string) omit(string)
  
  /* cycle through coefficnets and save to the csv */
  foreach i in `coefs' {
    local temp = _coef[`i']

    /* get stars from pvalue */
    test `i' = 0
    local pvalue = `r(p)'
    count_stars, p(`pvalue')
    local stars = r(stars)

    /* if there are significance stars, add them to the coefficient */
    if "`stars'" != "" {
       local temp: di %5.3f `temp'
       local temp = "      `temp'`stars'"
       insert_into_file using `csv', key(`name'_`i'_coef) value("`temp'") format(%s)
    }

    /* otherwise export just the coefficient */
    else {
        insert_into_file using `csv', key(`name'_`i'_coef) value(`temp') format(%5.3f)
    }
    
    /* get significance of the coefficient */
    local se = _se[`i']
    insert_into_file using `csv', key(`name'_`i'_se) value(`se') format(%5.3f)
  }

  /* get the total number of observations */
  local n = `e(N)'
  insert_into_file using `csv', key(`name'_N) value(`n') format(%5.0f)
  
  /* get the total number of towns */
  local grp = `e(df_a)' + 1
  insert_into_file using `csv', key(`name'_grp) value(`grp') format(%5.0f)
  
  /* save the omitted coefficient */
  insert_into_file using `csv', key(`name'_omit) value(`omit') format(%s)

end
/* *********** END program save_town_event_reg ***************************************** */

/**********************************************************************************/
/* program get_periods : Insert description here */
/***********************************************************************************/
cap prog drop get_periods
prog def get_periods
  syntax, p0(string) p1(string)

  /* if p0 is negative, make it positive */
  if `p0' < 0 {
    local p0 = `p0' * -1
  }

  /* increment p0 down 1, we omit the first period */
  // local p0 = `p0' - 1

  /* create empty periodlist */
  global plist
  
  /* cycle through negative periods */
  forvalues i =`p0'(-1) 1 {
  
    /* skip p(-1), we always omit that */
    if `i' != 1 {
      global plist $plist p_n`i'
    }
  }

  /* cycle through positive periods */
  forvalues i = 0/`p1' {
    global plist $plist p_`i'
  }
  
end
/* *********** END program get_periods ***************************************** */


/**********************************************************************************/
/* program define_canals_sample : Input all parameters needed to define the balanced
sample used in analysis for the canals paper. This function is meant to help evaluate 
sensitivity to different choices made in creating the sample.

sample_flg_elev: new column name that the elevation sample flag will be saved in 
sample_flg_comm: new column name that the command area sample flag will be saved in 

bw_elev: bandwidth of RD in elevation. default has been 50m
bw_comm: bandwidth of RD in distance. default has been 25km
canal_dist: maximum distance to a canal allowed
river_dist: minimum distance to a river allowed
donut_elev: the distance to drop around 0 along the RD path
            for the elevation specification (2.5m will drop +/-2.5m around 0)
donut_comm: the distance to drop around 0 along the RD path for
            the command area specification
rugbal_elev: the percent difference in ruggedness above/below the canal in a subdistrict.
             this ensures we get balance on ruggedness.
rugbal_comm: the percent difference in ruggedness inside/outside the command area in 
             a 10km segment FE group. this ensures we get balance on rugedness
full: if not specified, analysis sample of canals (pre-2012) are used. if specieifed
      as "`full", then the full set of canals is used. (for placebo test)
elev: describes which percentage point to use for elevation. the default is to use the 
      2nd percentile to define shrid-elevation, but you can use the 25th or median
      percentile as well (for robustness checks)
calc_weights: calculate the explicit weights required by the rd plotting function.
*/
/***********************************************************************************/
cap prog drop define_canals_sample
prog def define_canals_sample

  syntax, sample_flg_elev(string) sample_flg_comm(string) bw_elev(real) bw_comm(real) donut_elev(real) donut_comm(real) canal_dist(real) river_dist(real) [rugbal_elev(real 0.10) rugbal_comm(real 0.10) full(string) elev(string) canals_in_shrid(string) nourban calc_weights(string)]

  /* set urbmakr local. nourban means only rural, so we require rural_marker to be > 0.
     otherwise we incldue urban (0) and rural (1) so rural_marker can be > - 1 */
  if "`urban'" == "nourban" local urbmark = 0
  else local urbmark = -1

  /* add underscore to full */
  if "`full'" == "full" local full "_full"

  /*************/
  /* ELEVATION */
  /*************/

  /* add underscores to elev measure */
  if "`elev'" == "median" local elev "_median"
  if "`elev'" == "p25" local elev "_p25"
  if "`elev'" == "full" local elev "_full"

  /* make bins for elevation */
  cap drop xbins_elev
  egen xbins_elev = cut(rel_elev`elev'), at(-`bw_elev'(5)`bw_elev')

  /* create preferred sample variable using all inputs */
  cap drop samp_pref_elev
  gen samp_pref_elev = 1 if inrange(rel_elev`elev', -`bw_elev', `bw_elev') & !inrange(rel_elev`elev', -`donut_elev', `donut_elev') & inrange(dist_km_canal`full', -`canal_dist', `canal_dist') & !inrange(dist_km_river, -`river_dist', `river_dist') & (rural_marker > `urbmark' & !mi(rural_marker))
  replace samp_pref_elev = 0 if mi(samp_pref_elev)

  /* if specified to exclude shrids that contain a canal, drop those shrids  */
  if "`canals_in_shrid'" != "" {
    replace samp_pref_elev = 0 if canal_pt_in_shrid_full == 1
  }

  /* when using the pre-2012 canals, drop shrids that may have been treated later */
  if "`full'" == "" {

    /* drop any shrid that is mapped to a new canal once we add the full set  */
    replace samp_pref_elev = 0 if id_canal_full != id_canal

   /* drop any shrids from the sample that are control with a pre-2012 canal but 
     treated once you consider the full set of canals */
    replace samp_pref_elev = 0 if elev_dummy_full == 1 & elev_dummy == 0 

  }
  
  /* count shrids below canal */
  cap drop subd_below
  bys subd_id: egen subd_below = total(elev_dummy`elev') if samp_pref_elev == 1
  lab var subd_below "num. shrids below canal in subd_id, using elev"
  
  /* count shrids above canal */
  cap drop subd_above
  bys subd_id: egen subd_above = total(elev_above`elev') if samp_pref_elev == 1
  lab var subd_above "num. shrids above canal in subd_id, using elev"

  /* add the condition that there is at least one shrid in treatment and control groups
    if the subdistrict has no settlements above or below, drop it from the sample. */
  qui count if (subd_above == 0) | (subd_below == 0)
  local subd_drop `r(N)'
  replace samp_pref_elev = 0 if (subd_above == 0) | (subd_below == 0)

  /* get the average ruggedness above the canal for only shrids in this sample */
  cap drop subd_above_rug subd_above_rug_wt
  
  /* calculate the mean ruggedness of above-canal shrids in the subdistrict */
  bys subd_id: egen _temp = mean(rug) if samp_pref_elev == 1 & elev_above`elev' == 1
  bys subd_id: egen _temp2= wtmean(rug) if samp_pref_elev == 1 & elev_above`elev' == 1, weight(area_laea)
  
  /* fill in any missing values by taking the max (this assigns the above-canal ruggedness 
   average in the subdistrict to every shrid in the subdistrict) */
  bys subd_id: egen subd_above_rug = max(_temp)
  bys subd_id: egen subd_above_rug_wt = max(_temp2)
  lab var subd_above_rug "avg ruggedness above canal in subd_id, using elev"
  drop _temp _temp2

  /* get the average ruggedness below the canal */
  cap drop subd_below_rug subd_below_rug_wt
  
  /* calculate the mean ruggedness of below-canal shrids in the subdistrict */
  bys subd_id: egen _temp = mean(rug) if samp_pref_elev == 1 &  elev_dummy`elev' == 1
  bys subd_id: egen _temp2 = wtmean(rug) if samp_pref_elev == 1 & elev_dummy`elev' == 1, weight(area_laea)
  
  /* fill in any missing values by taking the max (this assigns the below-canal ruggedness 
     average in the subdistrict to every shrid in the subdistrict) */
  bys subd_id: egen subd_below_rug = max(_temp)
  bys subd_id: egen subd_below_rug_wt = max(_temp2)
  lab var subd_below_rug "avg ruggedness below canal in subd_id, using elev"
  drop _temp _temp2

  /* RUGGEDNESS BALANCE */
  /* check the relative difference between ruggedness in treatment vs. control for elevation*/
  /* BC: I think _temp is miscalculated. subd_above_rug and subd_below_rug will be equally weighted
  in the mean, even if there are only 2 shrids above and 1000 shrids below. */
  /* AC: Becky raises a good point here that we aren't area-weighting the ruggedness balance.
  even the mean taken above should perhaps be area-weighted. something to check. */
  cap drop per_diff_rug_elev per_diff_rug_elev_wt

  /* get total unweighted mean */
  egen _temp = rmean(subd_above_rug subd_below_rug)

  /* claculate the unweighted percent difference */
  gen per_diff_rug_elev = abs(subd_above_rug - subd_below_rug) / _temp
  
  /* get total weighted mean */
  egen _temp2 = wtmean(rug) if samp_pref_elev == 1, weight(area_laea)

  /* calculate the weighted percent difference */
  gen per_diff_rug_elev_wt = abs(subd_above_rug_wt - subd_below_rug_wt) / _temp2
  drop _temp _temp2

  /* create sample balanced on ruggedness */
  cap drop `sample_flg_elev'
  qui count if samp_pref_elev == 1 & !mi(per_diff_rug_elev)
  local pre_rugbal_drop = `r(N)'
  gen `sample_flg_elev' = 1 if (samp_pref_elev == 1) & per_diff_rug_elev <= `rugbal_elev' & !mi(per_diff_rug_elev)
  qui count if `sample_flg_elev' == 1  & !mi(per_diff_rug_elev)
  di "Dropped N shrids bc treatment and control were unbalanced in ruggedness: " `pre_rugbal_drop' - `r(N)'
  di "Dropped `subd_drop' shrids due to imbalanced treatement/control in the subdistrict"
  replace `sample_flg_elev' = 0 if mi(`sample_flg_elev')

  /****************/
  /* COMMAND AREA */
  /****************/

  /* make bins for command area */
  cap drop xbins_comm
  egen xbins_comm = cut(near_comm_dist`full'), at(-`bw_comm'(2.5)`bw_comm')

  /* create preferred sample variable */
  cap drop samp_pref_comm
  gen samp_pref_comm = 1 if inrange(near_comm_dist`full', -`bw_comm', `bw_comm') & !inrange(near_comm_dist`full', -`donut_comm', `donut_comm')  & (rural_marker > `urbmark' & !mi(rural_marker)) & !inrange(dist_km_river, -`river_dist', `river_dist')
  replace samp_pref_comm = 0 if mi(samp_pref_comm)

  /* if the shrids canont have a canal in them, drop them out */
  if "`canal_in_shrid'" != "" {
   replace samp_pref_comm = 0 if canal_pt_in_shrid == 1
  }

  /* drop villages that are treatment and full and control in the limited set
     if this is being calculated for the limited set  */
  if "`full'" == "" {
    replace samp_pref_comm = 0 if comm_dummy_full == 1 & comm_dummy == 0 
  }

  /* count shrids inside command area - here we use 10km segments along the
  command area boundary as the fixed effects groups instead of subdistricts*/
  cap drop seg_10km_in
  bys near_comm_seg_10km`full': egen seg_10km_in = total(comm_dummy`full') if samp_pref_comm == 1
  lab var seg_10km_in "num. shrids in command area in near_comm_seg_10km"

  /* count shrids outside command area */
  cap drop seg_10km_out
  bys near_comm_seg_10km`full': egen seg_10km_out = total(comm_out`full') if samp_pref_comm == 1
  lab var seg_10km_out "num. shrids out of command area in near_comm_seg_10km"

  /* add the condition that there is at least one shrid in treatment and control */
  replace samp_pref_comm = 0 if (seg_10km_in == 0) | (seg_10km_out == 0)

  /* create ruggedness variable for inside and outside command area */
  cap drop rug_out
  gen rug_out = rug if comm_dummy`full' == 0 & samp_pref_comm == 1
  cap drop rug_in
  gen rug_in = rug if comm_dummy`full' == 1 & samp_pref_comm == 1
  
  /* get the average ruggedness inside the command area */
  cap drop seg_10km_in_rug
  bys near_comm_seg_10km`full': egen seg_10km_in_rug = mean(rug_in) if samp_pref_comm == 1
  lab var seg_10km_in_rug "avg ruggedness in comm area in near_comm_seg_10km"

  /* get the average ruggedness outside the command area */
  cap drop seg_10km_out_rug
  bys near_comm_seg_10km`full': egen seg_10km_out_rug = mean(rug_out) if samp_pref_comm == 1 
  lab var seg_10km_out_rug "avg ruggedness out of comm area in near_comm_seg_10km"

  /* RUGGEDNESS BALANCE */
  /* check the relative difference between ruggedness in treatment vs. control for command area */
  cap drop per_diff_rug_comm
  egen _temp = rmean(seg_10km_out_rug seg_10km_in_rug)
  gen per_diff_rug_comm = abs(seg_10km_out_rug - seg_10km_in_rug) / _temp
  drop _temp

  /* create sample balanced on ruggedness */
  cap drop `sample_flg_comm'
  gen `sample_flg_comm' = 1 if (samp_pref_comm == 1) & per_diff_rug_comm <= `rugbal_comm'
  replace `sample_flg_comm' = 0 if mi(`sample_flg_comm')

  /**************/
  /* weightings */
  /**************/
  /* these weightings are only used for the rd plots, where you need to explicitly calculate the weights 
  for your sample, rather than passing a general weighting variable */

  if ("`calc_weights'" != "") & ("`calc_weights'" != "no") {
    /* elevation strategy, area-weighted */
    create_weights area_laea if `sample_flg_elev' == 1, wtvar(wt_area_elev)

    /* elevation strategy, population-weighted */
    create_weights pc11_pca_tot_p if `sample_flg_elev' == 1, wtvar(wt_pop_elev)

    /* command area strategy, area-weighted */
    create_weights area_laea if `sample_flg_comm' == 1, wtvar(wt_area_comm)

    /* command area strategy, population-weighted */
    create_weights pc11_pca_tot_p if `sample_flg_comm'  == 1, wtvar(wt_pop_comm)
  }

end
/* *********** END program define_canals_sample ***************************************** */


/**********************************************************************************/
/* program save_spillover_reg_results : Create a program to seasily save the 
regression results from each spillover analysis to a csv for stata-tex. 

var: dependent variable in the regression 
key: string to identify how these values should be saved to the csv to be called by the template
wvar: name of weighting variable
fout: csv file to write out to
numbands: number of bands excluding the above-canal group which is omitted. should 
          be one band for below-canal and then however many distant bands 
above: variable name for above-canal binary group assignment*/
/***********************************************************************************/
cap prog drop save_spillover_reg_results
prog def save_spillover_reg_results

  syntax, var(string) key(string) wvar(string) fout(string) numbands(real) above(string)

  matrix row=r(table)

  /* cycle through the number of bands (should be treatment plus all distant bands) */
  forvalues num=1(1)`numbands' {

    /* coefficient */
    local coef = row[1,`num']

    /* error bounds for coefplot */
    local low95 =row[5,`num']

    /* get the absolute difference between the two */
    local confdiff = abs(`coef' -`low95')

    /* flip the sign of the coefficient and the lower bound for the distant band */
    if `num' > 1 {
      local coef = `coef' * -1
      local low95 = `coef' - `confdiff'
    }
    
    /* format the number */
    local coef: di %5.3f `coef'

    /* standard error */
    local se = row[2,`num']
    local se: di %5.3f `se'

    /* p-value and significance stars*/
    local pval = row[4,`num']
    count_stars, p(`pval')
    local stars = "`r(stars)'"
    local coef = "`coef'`stars'"

    /* output coefficients and stars */
    if "`stars'" != "" insert_into_file using `fout', key(`var'__coef_n`num'_`key') value(`coef') format(%s)
    else if "`stars'" == "" insert_into_file using `fout', key(`var'__coef_n`num'_`key') value(`coef') format(%5.3f)

    /* output the standard error and lower 95%  */
    insert_into_file using `fout', key(`var'__se_n`num'_`key') value(`se') format(%5.3f)
    insert_into_file using `fout', key(`var'__low95_n`num'_`key') value(`low95') format(%5.3f)

  }
  /* r-squared */
  local r2 = e(r2_a)
  local r2: di %5.2f `r2'

  /* sample size */
  local samp = e(N)
  local samp: di %7.0fc `samp'
  
  /* control group mean */
  sum `var' if (`wvar' != 0) & !mi(`wvar') & `above' == 0
  local contr_mean = r(mean)
  local contr_mean: di %5.3f `contr_mean'

  /* output the values that don't change */
  insert_into_file using `fout', key(`var'__r2_`key') value(`r2') format(%5.2f)
  insert_into_file using `fout', key(`var'__samp_`key') value(`samp') format(%7.0fc)
  insert_into_file using `fout', key(`var'__mean_`key') value(`contr_mean') format(%5.3f)

end
/* *********** END program save_spillover_reg_results ***************************************** */
