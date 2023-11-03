global estout_params       cells(b(fmt(3) star) se(par fmt(3))) starlevels(* .1 ** .05 *** .01) varlabels(_cons Constant) label stats(N r2, fmt(0 2)) collabels(none) style(tex) replace prehead("\setlength{\linewidth}{.1cm} \begin{center}" "\newcommand{\contents}{\begin{tabular}{l*{@M}{c}}" "\hline\hline") posthead(\hline) prefoot(\hline) postfoot("\hline" "\multicolumn{@span}{p{\linewidth}}{\$^{*}p<0.10, ^{**}p<0.05, ^{***}p<0.01\$} \\" "\multicolumn{@span}{p{\linewidth}}{\footnotesize \tablenote}" "\end{tabular} }" "\setbox0=\hbox{\contents}" "\setlength{\linewidth}{\wd0-2\tabcolsep-.25em} \contents \end{center}")
global estout_params_no_p  cells(b(fmt(3) star) se(par fmt(3))) starlevels(* .1 ** .05 *** .01) varlabels(_cons Constant) label stats(N r2, fmt(0 2)) collabels(none) style(tex) replace prehead("\setlength{\linewidth}{.1cm} \begin{center}" "\newcommand{\contents}{\begin{tabular}{l*{@M}{c}}" "\hline\hline") posthead(\hline) prefoot(\hline) postfoot("\hline" "\multicolumn{@span}{p{\linewidth}}{}" "\end{tabular} }" "\setbox0=\hbox{\contents}" "\setlength{\linewidth}{\wd0-2\tabcolsep-.25em} \contents \end{center}")
global estout_params_np    cells(b(fmt(3) star) se(par fmt(3))) starlevels(* .1 ** .05 *** .01) varlabels(_cons Constant) label stats(N r2, fmt(0 2)) collabels(none) style(tex) replace prehead("\setlength{\linewidth}{.1cm} \begin{center}" "\newcommand{\contents}{\begin{tabular}{l*{@M}{c}}" "\hline\hline") posthead(\hline)                 postfoot("\hline" "\multicolumn{@span}{p{\linewidth}}{\$^{*}p<0.10, ^{**}p<0.05, ^{***}p<0.01\$} \\" "\multicolumn{@span}{p{\linewidth}}{\footnotesize \tablenote}" "\end{tabular} }" "\setbox0=\hbox{\contents}" "\setlength{\linewidth}{\wd0-2\tabcolsep-.25em} \contents \end{center}")
global estout_params_scr   cells(b(fmt(3) star) se(par fmt(3))) starlevels(* .1 ** .05 *** .01) varlabels(_cons Constant) label stats(N r2, fmt(0 2)) collabels(none)
global estout_params_txt   cells(b(fmt(3) star) se(par fmt(3))) starlevels(* .1 ** .05 *** .01) varlabels(_cons Constant) label stats(N r2, fmt(0 2)) collabels(none) replace
global ep_txt $estout_params_txt
global estout_params_excel cells(b(fmt(3) star) se(par fmt(3))) starlevels(* .1 ** .05 *** .01) varlabels(_cons Constant) label stats(N r2, fmt(0 2)) collabels(none) style(tab)  replace
global estout_params_html  cells(b(fmt(3) star) se(par fmt(3))) starlevels(* .1 ** .05 *** .01) varlabels(_cons Constant) label stats(N r2, fmt(0 2)) collabels(none) style(html) replace prehead("<html><body><table style='border-collapse:collapse;' border=1") postfoot("</table></body></html>")
global estout_params_fstat cells(b(fmt(3) star) se(par fmt(3))) starlevels(* .1 ** .05 *** .01) varlabels(_cons Constant) label stats(f_stat N r2, labels("F Statistic" "N" "R2" suffix(\hline)) fmt(%9.4g)) collabels(none) style(tex) replace prehead("\setlength{\linewidth}{.1cm} \begin{center}" "\newcommand{\contents}{\begin{tabular}{l*{@M}{c}}" "\hline\hline") posthead(\hline) prefoot(\hline) postfoot("\hline" "\multicolumn{@span}{p{\linewidth}}{$^{*}p<0.10, ^{**}p<0.05, ^{***}p<0.01$} \\" "\multicolumn{@span}{p{\linewidth}}{\footnotesize \tablenote}" "\end{tabular} }" "\setbox0=\hbox{\contents}" "\setlength{\linewidth}{\wd0-2\tabcolsep-.25em} \contents \end{center}")
global tex_p_value_line "\multicolumn{@span}{p{\linewidth}}{\$^{*}p<0.10, ^{**}p<0.05,^{***}p<0.01\$} \\"
global esttab_params       prehead("\setlength{\linewidth}{.1cm} \begin{center}" "\newcommand{\contents}{\begin{tabular}{l*{@M}{c}}" "\hline\hline") posthead(\hline) prefoot(\hline) postfoot("\hline" "\multicolumn{@span}{p{\linewidth}}{\footnotesize \tablenote}" "\end{tabular} }" "\setbox0=\hbox{\contents}" "\setlength{\linewidth}{\wd0-2\tabcolsep-.25em} \contents \end{center}")
  /*********************************************************************************************************/
  /* program ddrop : drop any observations that are duplicated - not to be confused with "duplicates drop" */
  /*********************************************************************************************************/
  cap prog drop ddrop
  cap prog def ddrop
  {
    syntax varlist(min=1) [if]

    /* do nothing if no observations */
    if _N == 0 exit

    /* `0' contains the `if', so don't need to do anything special here */
    duplicates tag `0', gen(ddrop_dups)
    drop if ddrop_dups > 0 & !mi(ddrop_dups)
    drop ddrop_dups
  }
end
/* *********** END program ddrop ***************************************** */


/**********************************************************************************/
/* program estout_default : Run default estout command with (1), (2), etc. column headers.
Generates a .tex and .html file. "using" should not have an extension.
*/
/***********************************************************************************/
cap prog drop estout_default
prog def estout_default
  {
    syntax [anything] using/ , [KEEP(passthru) MLABEL(passthru) ORDER(passthru) TITLE(passthru) HTMLonly PREFOOT(passthru) EPARAMS(string)]

    /* if mlabel is not specified, generate it as "(1)" "(2)" */
    if mi(`"`mlabel'"') {

      /* run script to get right number of column headers that look like (1) (2) (3) etc. */
      get_ecol_header_string

      /* store in a macro since estout is rclass and blows away r(col_headers) */
      local mlabel `"mlabel(`r(col_headers)')"'
    }

    /* if keep not specified, set to the same as order */
    if mi("`keep'") & !mi("`order'") {
      local keep = subinstr("`order'", "order", "keep", .)
    }

    /* set eparams string if not specified */
    //   if mi(`"`eparams'"') {
      //     local eparams `"$estout_params"'
      //   }

    /* if prefoot() is specified, pull it out of estout_params */
    if !mi("`"prefoot"'") {
      local eparams = subinstr(`"$estout_params"', "prefoot(\hline)", `"`prefoot'"', .)
    }

    //  if !mi("`prefoot'") {
      //    local eparams = subinstr(`"`eparams'"', "prefoot(\hline)", `"`prefoot'"', .)
      // }
    //  di `"`eparams'"'

    /* output tex file */
    if mi("`htmlonly'") {
      // di `" estout using "`using'.tex", `mlabel' `keep' `order' `title' `eparams' "'
      estout `anything' using "`using'.tex", `mlabel' `keep' `order' `title' `eparams'
    }

    /* output html file for easy reading */
    estout `anything' using "`using'.html", `mlabel' `keep' `order' `title' $estout_params_html

    /* if HTMLVIEW is on, copy the html file to caligari/ */
    if ("$HTMLVIEW" == "1") {

      /* make sure output folder exists */
      cap confirm file ~/public_html/html/
      if _rc shell mkdir ~/public_html/html/

      /* copy the file to HTML folder */
      shell cp  `using'.html ~/public_html/html/

      /* strip path component from the link */
      local filepart = regexr("`using'", ".*/", "")
      if !strpos("`using'", "/") local filepart `using'
      local linkpath "http://caligari.dartmouth.edu/~`c(username)'/html/`filepart'.html"
      di "View table at `linkpath'"
    }
  }
end

/* *********** END program estout_default ***************************************** */


  /**********************************************************************************/
  /* program append_est_to_file : Appends a regression estimate to a csv file       */
  /**********************************************************************************/
  cap prog drop append_est_to_file
  prog def append_est_to_file
  {
    syntax using/, b(string) Suffix(string)

    /* get number of observations */
    qui count if e(sample)
    local n: di %15.0f (`r(N)')

    /* get b and se from estimate */
    local beta = _b["`b'"]
    local se   = _se["`b'"]

    /* get p value */
    qui test `b' = 0
    local p = `r(p)'
    if "`p'" == "." {
      local p = 1
      local beta = 0
      local se = 0
    }
    append_to_file using `using', s("`beta',`se',`p',`n',`suffix'")
  }
  end
  /* *********** END program append_est_to_file ***************************************** */


  /*****************************************************************/
  /* program collapse_save_labels: Save var labels before collapse */
  /*****************************************************************/

  /* save var labels before collapse, saving varname if no label */
  cap prog drop collapse_save_labels
  prog def collapse_save_labels
  {
    foreach v of var * {
      local l`v' : variable label `v'
      global l`v'__ `"`l`v''"'
      if `"`l`v''"' == "" {
        global l`v'__ "`v'"
      }
    }
  }
  end
  /* **** END program collapse_save_labels *********************** */


/**********************************************************************************/
/* program estmod_header : add a header row to an estout set */
/***********************************************************************************/
cap prog drop estmod_header
prog def estmod_header
  syntax using/, cstring(string)

  /* add .tex suffix to using if not there */
  if !regexm("`using'", "\.tex$") local using `using'.tex

  shell python ~/ddl/tools/py/scripts/est_modify.py -c header -i `using' -o `using' --cstring "`cstring'"
end
/* *********** END program estmod_header ***************************************** */


  /**********************************************************************************/
  /* program append_to_file : Append a passed in string to a file                   */
  /**********************************************************************************/
  cap prog drop append_to_file
  prog def append_to_file
  {
    syntax using/, String(string) [format(string) erase]

    tempname fh

    cap file close `fh'

    if !mi("`erase'") cap erase `using'

    file open `fh' using `using', write append
    file write `fh'  `"`string'"'  _n
    file close `fh'
  }
  end
  /* *********** END program append_to_file ***************************************** */


  /************************************************************************/
  /* program collapse_apply_labels: Apply saved var labels after collapse */
  /************************************************************************/

  /* apply retained variable labels after collapse */
  cap prog drop collapse_apply_labels
  prog def collapse_apply_labels
  {
    foreach v of var * {
      label var `v' "${l`v'__}"
      macro drop l`v'__
    }
  }
  end
  /* **** END program collapse_apply_labels ***************************** */


  /******************************************************************************************************/
  /* program pyfunc: Run externally defined python function without silent failures.   */
  /******************************************************************************************************/
  /* note: pyfunc exists in ~/ddl/tools/do/ado/, which is auto-loaded on polaris */
  /****** END program pyfunc ****************/



cap pr drop graphout
pr def graphout
  syntax anything, [pdf QUIetly]
  tokenize `anything'
  graph export $out/`1'.pdf, replace
end


  /**********************************************************************************/
  /* program capdrop : Drop a bunch of variables without errors if they don't exist */
  /**********************************************************************************/
  cap prog drop capdrop
  prog def capdrop
  {
    syntax anything
    foreach v in `anything' {
      cap drop `v'
    }
  }
  end
  /* *********** END program capdrop ***************************************** */


  /**********************************************************************************/
  /* program tag : Fast way to run egen tag(), using first letter of var for tag    */
  /**********************************************************************************/
  cap prog drop tag
  prog def tag
  {
    syntax anything [if]

    tokenize "`anything'"

    local x = ""
    while !mi("`1'") {

      if regexm("`1'", "pc[0-9][0-9][ru]?_") {
        local x = "`x'" + substr("`1'", strpos("`1'", "_") + 1, 1)
      }
      else {
        local x = "`x'" + substr("`1'", 1, 1)
      }
      mac shift
    }

    display `"RUNNING: egen `x'tag = tag(`anything') `if'"'
    egen `x'tag = tag(`anything') `if'
  }
  end
  /* *********** END program tag ***************************************** */


  /**********************************************************************************************/
  /* program quireg : display a name, beta coefficient and p value from a regression in one line */
  /***********************************************************************************************/
  cap prog drop quireg
  prog def quireg, rclass
  {
    syntax varlist(fv ts) [pweight aweight] [if], [cluster(varlist) title(string) vce(passthru) noconstant s(real 40) absorb(varlist) disponly robust]
    tokenize `varlist'
    local depvar = "`1'"
    local xvar = subinstr("`2'", ",", "", .)

    if "`cluster'" != "" {
      local cluster_string = "cluster(`cluster')"
    }

    if mi("`disponly'") {
      if mi("`absorb'") {
        cap qui reg `varlist' [`weight' `exp'] `if',  `cluster_string' `vce' `constant' robust
        if _rc == 1 {
          di "User pressed break."
        }
        else if _rc {
          display "`title': Reg failed"
          exit
        }
      }
      else {
        /* if absorb has a space (i.e. more than one var), use reghdfe */
        if strpos("`absorb'", " ") {
          cap qui reghdfe `varlist' [`weight' `exp'] `if',  `cluster_string' `vce' absorb(`absorb') `constant'
        }
        else {
          cap qui areg `varlist' [`weight' `exp'] `if',  `cluster_string' `vce' absorb(`absorb') `constant' robust
        }
        if _rc == 1 {
          di "User pressed break."
        }
        else if _rc {
          display "`title': Reg failed"
          exit
        }
      }
    }
    local n = `e(N)'
    local b = _b[`xvar']
    local se = _se[`xvar']

    quietly test `xvar' = 0
    local star = ""
    if r(p) < 0.10 {
      local star = "*"
    }
    if r(p) < 0.05 {
      local star = "**"
    }
    if r(p) < 0.01 {
      local star = "***"
    }
    di %`s's "`title' `xvar': " %10.5f `b' " (" %10.5f `se' ")  (p=" %5.2f r(p) ") (n=" %6.0f `n' ")`star'"
    return local b = `b'
    return local se = `se'
    return local n = `n'
    return local p = r(p)
  }
  end
  /* *********** END program quireg **********************************************************************************************/


  /**********************************************************************************/
  /* program disp_nice : Insert a nice title in stata window */
  /***********************************************************************************/
  cap prog drop disp_nice
  prog def disp_nice
  {
    di _n "+--------------------------------------------------------------------------------------" _n `"| `1'"' _n  "+--------------------------------------------------------------------------------------"
  }
  end
  /* *********** END program disp_nice ***************************************** */


  /**************************************************************************************************/
  /* program rd : produce a nice RD graph, using polynomial (quartic default) for fits         */
  /**************************************************************************************************/
  global rd_start -250
  global rd_end 250
  cap prog drop rd
  prog def rd
  {
    syntax varlist(min=2 max=2) [aweight pweight] [if], [degree(real 4) name(string) Bins(real 100) Start(real -9999) End(real -9999) start_line(real -9999) end_line(real -9999) MSize(string) YLabel(string) NODRAW bw xtitle(passthru) title(passthru) ytitle(passthru) xlabel(passthru) xline(passthru) absorb(string) control(string) xq(varname) cluster(passthru) xsc(passthru) yscale(passthru) fysize(passthru) fxsize(passthru) note(passthru) nofit]

    tokenize `varlist'
    local xvar `2'

    preserve

    /* Create convenient weight local */
    if ("`weight'"!="") local wt [`weight'`exp']

    /* get the weight variable itself by removing other elements of the expression */
    local wtvar "`wt'"
    foreach i in "=" "aweight" "pweight" "]" "[" " " {
      local wtvar = subinstr("`wtvar'", "`i'", "", .)
    }

    /* set start/end to global defaults (from include) if unspecified */
    if `start' == -9999 & `end' == -9999 {
      local start $rd_start
      local end   $rd_end
    }

    /* set the start and endline points to be the same as the scatter plot if not specified */
    //if `start_line' == -9999 {
    //  local start_line = `start'
    //}
    //if `end_line' == -9999 {
    //  local end_line = `end'
    //}

    if "`msize'" == "" {
      local msize small
    }

    if "`ylabel'" == "" {
      local ylabel ""
    }
    else {
      local ylabel "ylabel(`ylabel') "
    }

    if "`name'" == "" {
      local name `1'_rd
    }

    /* set colors */
    if mi("`bw'") {
      local color_b "red"
      local color_se "blue"
    }
    else {
      local color_b "black"
      local color_se "gs8"
    }

    if "`se'" == "nose" {
      local color_se "white"
    }

    capdrop pos_rank neg_rank xvar_index xvar_group_mean rd_bin_mean rd_tag mm2 mm3 mm4 l_hat r_hat l_se l_up l_down r_se r_up r_down total_weight rd_resid tot_mean
    qui {

      /* restrict sample to specified range */
      if !mi("`if'") {
        keep `if'
      }
      keep if inrange(`xvar', `start', `end')

      /* get residuals of yvar on absorbed variables */
      if !mi("`absorb'")  | !mi("`control'") {
        if !mi("`absorb'") {
        reghdfe `1' `control' `wt' `if', absorb(`absorb') resid
        }
        else {
          reg `1' `control' `wt' `if'
        }
        predict rd_resid, resid
        local 1 rd_resid
      }

      /* GOAL: cut into `bins' equally sized groups, with no groups crossing zero, to create the data points in the graph */
      if mi("`xq'") {

        /* count the number of observations with margin and dependent var, to know how to cut into 100 */
        count if !mi(`xvar') & !mi(`1')
        local group_size = floor(`r(N)' / `bins')

        /* create ranked list of margins on + and - side of zero */
        egen pos_rank = rank(`xvar') if `xvar' > 0 & !mi(`xvar'), unique
        egen neg_rank = rank(-`xvar') if `xvar' < 0 & !mi(`xvar'), unique

        /* hack: multiply bins by two so this works */
        local bins = `bins' * 2

        /* index `bins' margin groups of size `group_size' */
        /* note this conservatively creates too many groups since 0 may not lie in the middle of the distribution */
        gen xvar_index = .
        forval i = 0/`bins' {
          local cut_start = `i' * `group_size'
          local cut_end = (`i' + 1) * `group_size'

          replace xvar_index = (`i' + 1) if inrange(pos_rank, `cut_start', `cut_end')
          replace xvar_index = -(`i' + 1) if inrange(neg_rank, `cut_start', `cut_end')
        }
      }
      /* on the other hand, if xq was specified, just use xq for bins */
      else {
        gen xvar_index = `xq'
      }

      /* generate mean value in each margin group */
      bys xvar_index: egen xvar_group_mean = mean(`xvar') if !mi(xvar_index)

      /* generate value of depvar in each X variable group */
      if mi("`weight'") {
        bys xvar_index: egen rd_bin_mean = mean(`1')
      }

      if "`weight'" != "" {
        bys xvar_index: egen total_weight = total(`wtvar')
        bys xvar_index: egen rd_bin_mean = total(`wtvar' * `1')
        replace rd_bin_mean = (rd_bin_mean / total_weight)
      }

      /* generate a tag to plot one observation per bin */
      egen rd_tag = tag(xvar_index)

      /* run polynomial regression for each side of plot */
      gen mm2 = `xvar' ^ 2
      gen mm3 = `xvar' ^ 3
      gen mm4 = `xvar' ^ 4

      /* set covariates according to degree specified */
      if "`degree'" == "4" {
        local mpoly mm2 mm3 mm4
      }
      if "`degree'" == "3" {
        local mpoly mm2 mm3
      }
      if "`degree'" == "2" {
        local mpoly mm2
      }
      if "`degree'" == "1" {
        local mpoly
      }

      reg `1' `xvar' `mpoly' `wt' if `xvar' < 0, `cluster'
      predict l_hat
      predict l_se, stdp
      gen l_up = l_hat + 1.65 * l_se
      gen l_down = l_hat - 1.65 * l_se

      reg `1' `xvar' `mpoly' `wt' if `xvar' > 0, `cluster'
      predict r_hat
      predict r_se, stdp
      gen r_up = r_hat + 1.65 * r_se
      gen r_down = r_hat - 1.65 * r_se
    }

    if "`fit'" == "nofit" {
      local color_b white
      local color_se white
    }

    /* fit polynomial to the full data, but draw the points at the mean of each bin */
    sort `xvar'

    twoway ///
      (line r_hat  `xvar' if inrange(`xvar', 0, `end') & !mi(`1'), color(`color_b') msize(vtiny)) ///
      (line l_hat  `xvar' if inrange(`xvar', `start', 0) & !mi(`1'), color(`color_b') msize(vtiny)) ///
      (line l_up   `xvar' if inrange(`xvar', `start', 0) & !mi(`1'), color(`color_se') msize(vtiny)) ///
      (line l_down `xvar' if inrange(`xvar', `start', 0) & !mi(`1'), color(`color_se') msize(vtiny)) ///
      (line r_up   `xvar' if inrange(`xvar', 0, `end') & !mi(`1'), color(`color_se') msize(vtiny)) ///
      (line r_down `xvar' if inrange(`xvar', 0, `end') & !mi(`1'), color(`color_se') msize(vtiny)) ///
      (scatter rd_bin_mean xvar_group_mean if rd_tag == 1 & inrange(`xvar', `start', `end'), xline(0, lcolor(black)) msize(`msize') color(black)),  `ylabel'  name(`name', replace) legend(off) `title' `xline' `xlabel' `ytitle' `xtitle' `nodraw' `xsc' `yscale' `fysize' `fxsize' `note' graphregion(color(white))
    restore
  }
  end
  /* *********** END program rd ***************************************** */


  /**********************************************************************************/
  /* program group : Fast way to use egen group()                  */
  /**********************************************************************************/
  cap prog drop regroup
  prog def regroup
    syntax anything [if]
    group `anything' `if', drop
  end

  cap prog drop group
  prog def group
  {
    syntax anything [if], [drop, varname(string)]

    tokenize "`anything'"

    local x = ""
    while !mi("`1'") {

      if regexm("`1'", "pc[0-9][0-9][ru]?_") {
        local x = "`x'" + substr("`1'", strpos("`1'", "_") + 1, 1)
      }
      else {
        local x = "`x'" + substr("`1'", 1, 1)
      }
      mac shift
    }

   /* define new variable name */
   if "`varname'" == "" {
     local varname `x'group
   }

    if ~mi("`drop'") cap drop `varxname'

    display `"RUNNING: egen int `varname' = group(`anything')" `if''
    egen int `varname' = group(`anything') `if'


  }
  end
  /* *********** END program group ***************************************** */


/**********************************************************************************/
/* program estmod_footer : add a footer row to an estout set */
/***********************************************************************************/
cap prog drop estmod_footer
prog def estmod_footer
  syntax using/, cstring(string)

  /* add .tex suffix to using if not there */
  if !regexm("`using'", "\.tex$") local using `using'.tex

  shell python ~/ddl/tools/py/scripts/est_modify.py -c footer -i `using' -o `using' --cstring "`cstring'"
end
/* *********** END program estmod_footer ***************************************** */


  /**********************************************************************************/
  /* program insert_est_into_file : *Inserts* a regression estimate to a csv file   */
  /* example: insert_est_into_file using $tmp/foo.csv, spec(main) b(treatment)

     - will add/replace the following four lines to foo.csv:
        "main_beta, 0.123"
        "main_starbeta, 0.123**"
        "main_p, 0.01"
        "main_se, 0.061"
    */
  /* alternately numbers can be suppled directly (no additional formatting will be done):
    insert_est_into_file using $tmp/foo.csv, spec(main) b(0.123) se(0.061) p(0.02) t(2.43)

    If you supply t(), then p() will be ignored and calculated with 1000 degrees of freedom.

    */

  /**********************************************************************************/
  cap prog drop insert_est_into_file
  prog def insert_est_into_file
  {
    syntax using/, b(string) spec(string) [se(string) p(string) t(string) n(string) r2(string)]

    /* validate what was passed in */
    if (!mi("`se'") & ((mi("`p'") & mi("`t'")) | mi("`n'"))) | (mi("`se'") & (!mi("`p'") | !mi("`t'") | !mi("`n'"))) {
        di "If you pass se() into insert_est_into_file(), you also need to pass n() and p() / t(), and vice versa"
        error 789
    }

    /* if se() is missing, we need to get these estimates from the last regression */
    if mi("`se'") {

      /* get number of observations */
      qui count if e(sample)
      local n: di %15.0f (`r(N)')

      /* get b and se from estimate */
      local beta: di %6.3f (_b["`b'"])
      local se: di %6.3f (_se["`b'"])
        local r2: di %5.2f (`e(r2)')

      /* get p value */
      qui test `b' = 0
      local p: di %5.2f (`r(p)')
      if "`p'" == "." {
        local p = 1
        local beta = 0
        local se = 0
      }
    }

    /* else, se() is not missing, and all parameters are already passed in */
    else {

      /* if p value is not passed in, calculate it from t stat */
      if mi("`p'") {
          local p: di %5.3f (ttail(1000, `t'))
      }
      local beta `b'

      /* make sure n is in right format */
      local n: di %1.0f (`n')
    }
    /* calculate starbeta from `p' */
    count_stars, p(`p')
    local starbeta "`beta'`r(stars)'"

    /* insert the estimates into the file given by `using' */
    insert_into_file using `using', key(`spec'_beta) value(`beta')
    insert_into_file using `using', key(`spec'_se) value(`se')
    insert_into_file using `using', key(`spec'_starbeta) value(`starbeta')
    insert_into_file using `using', key(`spec'_p) value(`p')
    insert_into_file using `using', key(`spec'_n) value(`n') format("%15.0f")

    /* r2 can be missing, so only insert if we got it */
    if !mi("`r2'") insert_into_file using `using', key(`spec'_r2) value(`r2')
  }
  end
  /* *********** END program insert_est_into_file ***************************************** */


  /**********************************************************************************/
  /* program grep : Runs grep in the OS */
  /***********************************************************************************/
  cap prog drop grep
  prog def grep
  {
    syntax anything
    shell grep -s `anything'
  }
  end
  /* *********** END program grep ***************************************** */


/**********************************************************************************/
/* program write_data_dict : Writes a data dictionary file from a data file       */
/**********************************************************************************/
cap prog drop write_data_dict
prog def write_data_dict
  {
    syntax using, [REPLACE]

    /* open data dictionary csv file with the file handle "fh" */
    cap file close fh
    file open fh `using', write `replace'

    /* Write the column labels */
    file write fh `"Variable Name,"'
    file write fh `"Variable Label,"'
    file write fh `"Variable Type,"'
    file write fh `"No. Non-Missing Obs.,"'
    file write fh `"No. Unique Values,"'
    file write fh `"Min,"'
    file write fh `"Max,"'
    file write fh `"Mean,"'
    file write fh `"Standard Dev.,"'
    file write fh `"10 %-ile,"'
    file write fh `"25 %-ile,"'
    file write fh `"50 %-ile,"'
    file write fh `"75 %-ile,"'
    file write fh `"90 %-ile,"'
    file write fh `"Mean strlen,"'
    file write fh `"Max strlen"'
    file write fh _n

    /* loop over all variables */
    foreach v of varlist * {

      /* write the variable name to the file */
      file write fh `""`v'","'

      /* get the variable's label into the local macro v_label */
      local v_label : variable label `v'

      /*If there are commas in the label, remove them*/
      /*replace v_label = subinstr(v_label, ",", "", .)*/

      /* write the variable label to the output file */
      file write fh `""`v_label'","'

      /* write the variable's type into the local macro v_type */
      local v_type : type `v'

      /* write the variable type into the output file */
      file write fh `""`v_type'","'

      /* write number of observations to output file */
      count if !mi(`v')
      file write fh "`r(N)',"

      /* write number of unique values. requires installation of stata command: distinct. (ssc install distinct) */
      capture distinct `v'
      file write fh "`r(ndistinct)',"

      /* write min, max, mean, sd for numeric variables */
      sum `v'
      file write fh "`r(min)',"
      file write fh "`r(max)',"
      file write fh "`r(mean)',"
      file write fh "`r(sd)',"

      /* write percentiles for numeric variables */
      centile `v', centile(10 25 50 76 90)
      file write fh "`r(c_1)',"
      file write fh "`r(c_2)',"
      file write fh "`r(c_3)',"
      file write fh "`r(c_4)',"
      file write fh "`r(c_5)',"

      /* if the variable is a string, count the number of characters */
      capture confirm string variable `v'
      if !_rc {
        tempvar length
        gen `length' = length(`v')
        sum `length' if !mi(`v')
        file write fh "`r(mean)',`r(max)'"
        drop `length'
      }
      else {
        file write fh ","
      }

      /* write a newline (otherwise all these values will be on one line) */
      file write fh _n
    }

    file close fh

  }
end
/* *********** END program write_data_dict ***************************************** */


  /*********************************************************************************/
  /* program winsorize: replace variables outside of a range(min,max) with min,max */
  /*********************************************************************************/
  cap prog drop winsorize
  prog def winsorize
  {
    syntax anything,  [REPLace GENerate(name) centile]

    tokenize "`anything'"

    /* require generate or replace [sum of existence must equal 1] */
    if (!mi("`generate'") + !mi("`replace'") != 1) {
      display as error "winsorize: generate or replace must be specified, not both"
      exit 1
    }

    if ("`1'" == "" | "`2'" == "" | "`3'" == "" | "`4'" != "") {
      di "syntax: winsorize varname [minvalue] [maxvalue], [replace generate] [centile]"
      exit
    }
    if !mi("`replace'") {
      local generate = "`1'"
    }
    tempvar x
    gen `x' = `1'


    /* reset bounds to centiles if requested */
    if !mi("`centile'") {

      centile `x', c(`2')
      local 2 `r(c_1)'

      centile `x', c(`3')
      local 3 `r(c_1)'
    }

    di "replace `generate' = `2' if `1' < `2'  "
    replace `x' = `2' if `x' < `2'
    di "replace `generate' = `3' if `1' > `3' & !mi(`1')"
    replace `x' = `3' if `x' > `3' & !mi(`x')

    if !mi("`replace'") {
      replace `1' = `x'
    }
    else {
      generate `generate' = `x'
    }
  }
  end
  /* *********** END program winsorize ***************************************** */


