********************************************************************************
* RDSENSITIVITY: sensitivity analysis for randomization inference in RD designs
* !version 1.0 2021-07-07
* Authors: Matias Cattaneo, Rocio Titiunik, Gonzalo Vazquez-Bare
********************************************************************************

version 13

capture program drop rdsensitivity
program define rdsensitivity, rclass sortpreserve
	
	syntax varlist (min=2 max=2 numeric) [if] [in] [, Cutoff(real 0)              ///
	                                                  wlist(numlist)              ///
													  wlist_left(numlist)         ///
													  tlist(numlist min=1)        ///
													  STATistic(string)           ///
													  p(integer 0)                ///
													  evalat(string)              ///
													  kernel(string)              ///
													  fuzzy(namelist min=1 max=1) ///
													  ci(numlist min=1 max=2)     ///
													  ci_alpha(real 0.05)         ///
													  reps(integer 1000)          ///
													  seed(integer 666)           ///
													  saving(string)              ///
													  noDOTS                      ///
													  noDRAW                      ///
													  verbose ]

	tokenize `varlist'
	local outvar "`1'"
	local runv_aux "`2'"
	marksample touse, novarlist

	quietly summarize `runv_aux' if `touse'
	if(`cutoff' <= r(min) | `cutoff' >= r(max)) {
		display as error "cutoff must be within the range of running variable"
		exit 125
	}
	
	tempvar runvar
	qui gen double `runvar' = `runv_aux' - `cutoff'
	
	if "`statistic'"==""|"`statistic'"=="diffmeans"|"`statistic'"=="ttest"{
		local statdisp "Diff. in means"
	}
	else if "`statistic'"=="ksmirnov" {
		local statdisp "Kolmogorov-Smirnov"
	}
	else if "`statistic'"=="ranksum"{
		local statdisp "Rank sum z-stat"
	}
	else {
		di "`statistic' not a valid statistic"
		exit 198
	}
	
	local stat_opt "stat(`statistic')"
	
	if "`evalat'"!=""&"`evalat'"!="means"&"`evalat'"!="cutoff"{
		di as error "evalat only admits means or cutoff"
		exit 198
	}

	if "`kernel'"!=""{
		local kernel_opt "kernel(`kernel')"
	}
	
	if "`fuzzy'"!=""{
		local fuzzy_opt "fuzzy(`fuzzy')"
		local statdisp "Anderson-Rubin"
	}
	
	if "`tlist'"=="" & `p'!=0{
		di as error "need to specify tlist when p>0"
		exit 198
	}
	
	if "`wlist_left'"!=""{
		if "`wlist'"==""{
			di as error "need to specify wlist when wlist_left is specified"
			exit 198
		}
		else{
			numlist "`wlist'"
			local nw: word count `r(numlist)'
			numlist "`wlist_left'"
			local nw_left: word count `r(numlist)'
			if `nw'!=`nw_left'{
				di as error "lengths of wlist and wlist_left need to coincide"
				exit 198
			}
		}
	}
	
	if "`ci'"!=""{
		local ci_count: word count `ci'
		if `ci_count'!=2{
			di as error "need to specify wl and wr in ci option"
			exit 198
		}
	}
	
	if "`evalat'"=="cutoff"{
		local evalr = `cutoff'
		local evall = `cutoff'
		local eval_opt "evall(`evall') evalr(`evalr')"
	}

	
********************************************************************************
** Default wlist
********************************************************************************
	
	if "`wlist'"==""{
		qui rdwinselect `runvar', wobs(5)
		local nw = r(nwindows)
		mat Waux = r(results)
		mat wlist_mat = (Waux[1...,5]' \ Waux[1...,6]')
	}
	else{
		numlist "`wlist'"
		local nw: word count `r(numlist)'
		mat wlist_mat = J(2,`nw',.)
		forvalues w = 1/`nw'{
			numlist "`wlist'"
			tokenize `r(numlist)'
			mat wlist_mat[2,`w'] = ``w'' - `cutoff'		
			if "`wlist_left'"==""{
				mat wlist_mat[1,`w'] = -wlist_mat[2,`w']
			}
			else{
				numlist "`wlist_left'"
				tokenize `r(numlist)'
				mat wlist_mat[1,`w'] = ``w'' - `cutoff'
			}
		}
	}


********************************************************************************
** Default tlist
********************************************************************************

	if "`tlist'"==""{		
		local wfirst = max(abs(wlist_mat[1,1]),wlist_mat[2,1])
		qui {
			tempvar treated
			gen double `treated' = `runvar'>=0
		
			if "`fuzzy'"==""{
				reg `outvar' `treated' if abs(`runvar')<=`wfirst'
				local ci_r = round(_b[`treated']+1.96*_se[`treated'],.01)
				local ci_l = round(_b[`treated']-1.96*_se[`treated'],.01)
			}
			else {
				ivregress 2sls `outvar' (`fuzzy'=`treated') if abs(`runvar')<=`wfirst'
				local ci_r = round(_b[`fuzzy']+1.96*_se[`fuzzy'],.01)
				local ci_l = round(_b[`fuzzy']-1.96*_se[`fuzzy'],.01)			
			}

			local w_step = round((`ci_r'-`ci_l')/10,.01)
			numlist "`ci_l'(`w_step')`ci_r'"
			local tlist `r(numlist)'
		}
	}
	
	local nt: word count `tlist'
	

********************************************************************************
** CI check
********************************************************************************	
	
	if "`ci'"!=""{
		tokenize `ci'
		local ci_left "`1'"
		local ci_right "`2'"
		local ci_left_c = `ci_left' - `cutoff'
		local ci_right_c = `ci_right' - `cutoff'
		if "`ci_alpha'"==""{
			local ci_alpha = .05
		}
		else if `ci_alpha'>=1|`ci_alpha'<=0{
			di as error "ci_alpha has to be between 0 and 1"
			exit 198
		}
		mata: wlist_mat = st_matrix("wlist_mat")		
		mata: rdlocrand_confint_check(wlist_mat,`ci_left_c',`ci_right_c')
		if (scalar(CI_position)==-1){
			di as error "window specified in ci not in wlist"
			exit 198
		}
		else if (scalar(CI_position)==-2){
			di as error "window specified in ci not in wlist_left"
			exit 198
		}		
	}
	
	
********************************************************************************
** Results
********************************************************************************

	mat Res = J(`nt',`nw',.)
	mat Rows = J(`nt',1,.)
	mat Cols = J(`nw',1,.)
	mat tlist_vec = J(1,`nt',.)
	local matrows ""
	local matcols ""

	di _newline as text "Running randomization-based test..."
	
	local count = 1	
	forvalues w = 1/`nw'{
		
		local w_left = wlist_mat[1,`w']
		local w_right = wlist_mat[2,`w']
		
		mat Cols[`w',1] = `w_right'
		local wname = round(`w_right',.001)
		local matcols " `matcols' `""`wname'""'"	
		
		if "`dots'"==""{
			di as text "w = [" as res %9.3f `w_left'+`cutoff' _c as text " , " as res %9.3f `w_right'+`cutoff' as text "]" _newline
		}
		
		if "`evalat'"=="means"{
			qui sum `runv_aux' if `treated'==1 & `runvar'<=`w_right' & `runvar'>=`w_left' & `touse'
			local evalr = r(mean)
			qui sum `runv_aux' if `treated'==0 & `runvar'<=`w_right' & `runvar'>=`w_left' & `touse'
			local evall = r(mean)
			local eval_opt "evall(`evall') evalr(`evalr')"
		}
		
		local row = 1		
		foreach t of numlist `tlist'{
			mat tlist_vec[1,`row'] = `t' 
			qui rdrandinf `outvar' `runvar' if `touse', wl(`w_left') wr(`w_right') p(`p') reps(`reps') nulltau(`t') ///
				`stat_opt' `eval_opt' `kernel_opt' `fuzzy_opt' seed(`seed')
			mat Res[`row',`w'] = r(randpval)
			
			if "`dots'"==""{
				*if mod(`count',`nt')!=0{
				if mod(`count',50)!=0{
					di as text "." _cont
				}
				else{
					di as text ". `count'"
				}
			}
			
			local ++row
			local ++count
		}

	}
	
	di _newline as text "Randomization-based test complete."

	local row = 1
	foreach t of numlist `tlist'{
		mat Rows[`row',1]=`t'
		local matrows " `matrows' `""`t'""'"
		local ++row
	}

	mat colnames Res = `matcols'
	mat rownames Res = `matrows'

	if "`verbose'"!=""{
		if colsof(Res)>=10{
			matlist Res[1...,1..10]
		}
		else {
			matlist Res
		}
	}
	
	
********************************************************************************
** Confidence interval
********************************************************************************

	if "`ci'"!=""{
		mat pvals = Res[1...,scalar(CI_position)]'
		mata: pvals = st_matrix("pvals")
		mata: tlist_vec = st_matrix("tlist_vec")
		mata: rdlocrand_confint(pvals,`ci_alpha',tlist_vec)
		local waux_left = wlist_mat[1,scalar(CI_position)]+`cutoff'
		local waux_right = wlist_mat[2,scalar(CI_position)]+`cutoff'

		di as text _newline "Confidence interval for w = [" as res %9.3f `waux_left' _c as text " , " as res %9.3f `waux_right' as text "]" _newline
		di as text "{hline 18}{c TT}{hline 23}"
		di as text "{ralign 18:Statistic}{c |}" 		_col(16) "   [" (1-`ci_alpha')*100 "% Conf. Interval]"
		di as text "{hline 18}{c +}{hline 23}"
		di as text "{ralign 18:`statdisp'}{c |}" 		_col(22) as res %9.3f CI[1,1] _col(34) as res %9.3f CI[1,2]
		if rowsof(CI)>1{
			local jmax = rowsof(CI)
			forvalues j = 2/`jmax'{
				di as text _col(19) "{c |}" _col(22) as res %9.3f CI[`j',1] _col(34) as res %9.3f CI[`j',2]
			}
		}
		di as text "{hline 18}{c BT}{hline 23}"
		
		return matrix CI = CI
	}
	
********************************************************************************
** Plot
********************************************************************************
	
	preserve
	clear
	qui {
		svmat Rows, name(T)
		expand `nw'
		sort T, stable
		svmat Cols, name(W)
		replace W = W[_n-`nw'] if W == .

		gen pvalue = .

		local n = 1

		forv r=1/`nt'{
			forv c=1/`nw'{
				qui replace pvalue = Res[`r',`c'] in `n'
				local ++n
			}
		}

		rename W1 w
		rename T1 t
		
		if "`draw'"==""{
			twoway contour pvalue t w, ccuts(0(0.05)1)
		}
		
		if "`saving'"!=""{
			save "`saving'", replace
		}
	}
	restore
	
	
********************************************************************************
** Return values
********************************************************************************
	
	return matrix results = Res

end
