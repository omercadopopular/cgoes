********************************************************************************
* RDRBOUNDS: Rosenbum bounds for randomization inference in RDD
* !version 1.0 2021-07-07
* Authors: Matias Cattaneo, Rocio Titiunik, Gonzalo Vazquez-Bare
********************************************************************************

version 13

capture program drop rdrbounds
program define rdrbounds, rclass sortpreserve

	syntax varlist(min=2 max=2 numeric) [if] [in] [, Cutoff(real 0)              ///
													 ulist(numlist)              ///
													 wlist(numlist)              ///
													 GAMMAlist(numlist)          ///
													 expgamma(numlist)           ///
													 bound(string)               ///
													 STATistic(string)           ///
													 p(integer 0)                ///
													 evalat(string)              ///
													 kernel(string)              ///
													 fuzzy(namelist min=1 max=1) ///
													 NULLtau(real 0)             ///
													 prob(string)                ///
													 FMpval                      ///
													 reps(integer 500)           ///
													 seed(integer 666) ]

	tokenize `varlist'
	
	local outvar "`1'"
	local runv_aux "`2'"
	marksample touse, novarlist


	quietly summarize `runv_aux' if `touse'
	if(`cutoff' <= r(min) | `cutoff' >= r(max)) {
		display as error "cutoff must be within the range of running variable"
		exit 125
	}
	
	if "`statistic'"==""|"`statistic'"=="ranksum"{
		local stat "ranksum"
		local stat_opt "stat(ranksum)"
	}
	else if "`statistic'"=="ksmirnov"|"`statistic'"=="ttest"|"`statistic'"=="diffmeans"{
		local stat "`statistic'"
		local stat_opt "stat(`statistic')"
	}
	else {
		di "`statistic' not a valid statistic"
		exit 198
	}
	
	if "`evalat'"!=""&"`evalat'"!="means"&"`evalat'"!="cutoff"{
		di as error "evalat only admits means or cutoff"
		exit 198
	}
	
	if "`kernel'"!=""{
		local kernel_opt "kernel(`kernel')"
	}

	if "`fuzzy'"!=""{
		local fuzzy_opt "fuzzy(`fuzzy')"
		local stat_opt ""
	}
	
	tempvar runvar
	tempvar treatvar
	tempvar probs prob_h prob_l
	tempvar unobs_l 
	tempvar unobs_h

	qui gen double `runvar' = `runv_aux' - `cutoff'
	qui gen double `treatvar' = `runvar' >= 0 if `runvar'!=.
	
	if "`prob'"!=""{
		if `prob'>1 | `prob'<0{
			di as error "prob has to be between 0 and 1"
			exit 198
		}
		else {
			qui gen double `probs' = `prob'
		}
	}
	
	
********************************************************************************
*** Default values	
********************************************************************************
	
	if "`wlist'"==""{
		qui rdwinselect `runvar', wobs(5)
		mat Waux = r(results)
		mat Wvec = Waux[,5]
		forv i=1/10{
			local wnext = Wvec[`i',1]
			local wlist "`wlist' `wnext'"
		}
	}
	
	if "`gammalist'"=="" & "`expgamma'"==""{
		local gamma_list "1.5 2 2.5 3"
	}
	if "`gammalist'"=="" & "`expgamma'"!=""{
		local gamma_list "`expgamma'"
	}
	if "`gammalist'"!="" & "`expgamma'"==""{
		foreach num of numlist `gammalist' {
			local tmp = round(exp(`num'),.01)
			local aux "`aux' `tmp'"
		}
		local gamma_list "`aux'"
	}
	if "`gammalist'"!="" & "`expgamma'"!=""{
		di as error "gammalist and expgamma cannot be specified simultaneously"
		exit 198
	}
		
	numlist "`gamma_list'"
	local num_gamma: word count `r(numlist)'
	numlist "`wlist'"
	local num_w: word count `r(numlist)'
	
	local col_step = 11									// for output display
	local line_length = 10 + `col_step'*(`num_w'-1)		// for output display

	local gamma_count = 1
	
	if "`evalat'"=="cutoff"|"`evalat'"==""{
		local evalr = 0
		local evall = 0
		local eval_opt "evall(`evall') evalr(`evalr')"
	}

	
********************************************************************************
** Randomization p-value
********************************************************************************

	di _newline as text "Calculating randomization p-values..."
	
	local w_count = 1
	mata: Q = J(2,`num_w',.)
	
	if "`fmpval'"==""{
		foreach w of numlist `wlist'{
			
			if "`prob'"==""{
				qui sum `treatvar' if `runvar'>=-`w' & `runvar'<=`w' & `outvar'!=. & `runv_aux'!=. & `touse'
				qui gen `probs' = r(mean)
			}
			
			if "`evalat'"=="means"{
				qui sum `runv_aux' if `treatvar'==1 & abs(`runvar')<=`w' & `outvar'!=. & `runv_aux'!=. & `touse'
				local evalr = r(mean)
				qui sum `runv_aux' if `treatvar'==0 & abs(`runvar')<=`w' & `outvar'!=. & `runv_aux'!=. & `touse'
				local evall = r(mean)
				local eval_opt "evall(`evall') evalr(`evalr')"
			}
		
			qui rdrandinf `outvar' `runvar' if `touse', wl(-`w') wr(`w') bernoulli(`probs') reps(`reps') /*
				*/ p(`p') nulltau(`nulltau') `stat_opt' `eval_opt' `kernel_opt' `fuzzy_opt'
				
			local pval = r(randpval)
			mata: Q[1,`w_count']=`pval'
			local ++w_count
			if "`prob'"==""{
				drop `probs'
			}
		}
		
		forv i=1/`num_w'{
			mata: st_numscalar("g",Q[1,`i'])
			local g = g
			local numlist "`numlist' `g'"
		}
		output_line, gamma(0) c0(25) step(`col_step') numlist(`wlist') line(header) omitg
		di as text "{hline 29}{c TT}{hline `line_length'}"
		output_line, gamma(0) c0(25) step(`col_step') numlist(`numlist') line(middle)
		di as text "{hline 29}{c BT}{hline `line_length'}"
	}
	else {
		foreach w of numlist `wlist'{
		
			if "`prob'"==""{
				qui sum `treatvar' if `runvar'>=-`w' & `runvar'<=`w' & `outvar'!=. & `runv_aux'!=. & `touse'
				qui gen `probs' = r(mean)
			}
			
			if "`evalat'"=="means"{
				qui sum `runv_aux' if `treatvar'==1 & abs(`runvar')<=`w' & `outvar'!=. & `runv_aux'!=. & `touse'
				local evalr = r(mean)
				qui sum `runv_aux' if `treatvar'==0 & abs(`runvar')<=`w' & `outvar'!=. & `runv_aux'!=. & `touse'
				local evall = r(mean)
				local eval_opt "evall(`evall') evalr(`evalr')"
			}
			
			qui rdrandinf `outvar' `runvar' if `touse', wl(-`w') wr(`w') bernoulli(`probs') reps(`reps') ///
				p(`p') nulltau(`nulltau') `stat_opt' `eval_opt' `kernel_opt' `fuzzy_opt'
			local pval = r(randpval)
			mata: Q[1,`w_count']=`pval'
			
			qui rdrandinf `outvar' `runvar' if `touse', wl(-`w') wr(`w') reps(`reps') ///
				p(`p') nulltau(`nulltau') `stat_opt' `eval_opt' `kernel_opt' `fuzzy_opt'
			local pval = r(randpval)
			mata: Q[2,`w_count']=`pval'
			local ++w_count
			if "`prob'"==""{
				drop `probs'
			}
		}
		
		forv i=1/`num_w'{
			mata: st_numscalar("g",Q[1,`i'])
			local g = g
			local numlist "`numlist' `g'"
			mata: st_numscalar("g",Q[2,`i'])
			local g = g
			local numlistfm "`numlistfm' `g'"
		}
		output_line, gamma(0) c0(25) step(`col_step') numlist(`wlist') line(header) omitg
		di as text "{hline 29}{c TT}{hline `line_length'}"
		output_line, gamma(0) c0(25) step(`col_step') numlist(`numlist') line(middle)
		output_line, gamma(0) c0(25) step(`col_step') numlist(`numlistfm') line(middle) fm
		di as text "{hline 29}{c BT}{hline `line_length'}"
	}
	
	
********************************************************************************
** Sensitivity analysis
********************************************************************************	
	
	di _newline as text "Running sensitivity analysis..."
	
	mata: LB = J(1,`num_w',.)
	mata: UB = J(1,`num_w',.)
	foreach gamma of numlist `gamma_list'{
		
		local pl = 1/(1+`gamma')
		local ph = `gamma'/(1+`gamma')
		
		local w_count = 1
		mata: G`gamma_count' = J(3,`num_w',.)
		
		foreach w of numlist `wlist'{
		
			if "`evalat'"=="means"{
				qui sum `runv_aux' if `treatvar'==1 & abs(`runvar')<=`w' & `outvar'!=. & `runv_aux'!=. & `touse'
				local evalr = r(mean)
				qui sum `runv_aux' if `treatvar'==0 & abs(`runvar')<=`w' & `outvar'!=. & `runv_aux'!=. & `touse'
				local evall = r(mean)
				local eval_opt "evall(`evall') evalr(`evalr')"
			}
				
			if "`ulist'"==""{
				local min = 0
				local step = 1
				qui count if abs(`runvar')<=`w' & `outvar'!=. & `runv_aux'!=. & `touse'
				local max = r(N)
				local ulist `min'(`step')`max'
			}
			
			if "`prob'"==""{
				qui sum `treatvar' if `runvar'>=-`w' & `runvar'<=`w' & `outvar'!=. & `runv_aux'!=. & `touse'
				local prob = r(mean)
			}
				
			if "`bound'"==""|"`bound'"=="both"{

				** Search over U vectors

				local nrowsP = (`max'-`min')/`step'+1
				mata: P = J(`nrowsP',2,.)
				
				preserve
				qui keep if `runvar'>=-`w' & `runvar'<=`w' & `outvar'!=. & `runv_aux'!=. & `touse'
				
				local count_u = 1
				foreach nu of numlist `ulist'{

					qui {					
						gsort -`outvar'
						gen `unobs_h' = _n<=`nu'
						sort `outvar'
						gen `unobs_l' = _n<=`nu'
						
						gen `prob_h' = `ph'*`unobs_h' + `pl'*(1-`unobs_h')
						gen `prob_l' = `ph'*`unobs_l' + `pl'*(1-`unobs_l')
						
						rdrandinf `outvar' `runvar', wl(-`w') wr(`w') bernoulli(`prob_l') reps(`reps') ///
							p(`p') nulltau(`nulltau') `stat_opt' `eval_opt' `kernel_opt' `fuzzy_opt' seed(`seed')
						local pval_l = r(randpval)
						rdrandinf `outvar' `runvar', wl(-`w') wr(`w') bernoulli(`prob_h') reps(`reps') ///
							p(`p') nulltau(`nulltau') `stat_opt' `eval_opt' `kernel_opt' `fuzzy_opt'  seed(`seed')
						local pval_h = r(randpval)
					}

					mata: P[`count_u',1]=`pval_l'
					mata: P[`count_u',2]=`pval_h'
					drop `unobs_l' `unobs_h' `prob_h' `prob_l'
					
					local ++count_u
				}
				
				restore

				** bounds
				
				mata: P=(Q[1,`w_count'],Q[1,`w_count']\P) 				// include p-values when ul=uh=0 in the matrix
				mata: G`gamma_count'[1,`w_count']=min(P[.,1])
				mata: G`gamma_count'[3,`w_count']=max(P[.,2])
			}
			
			else if "`bound'"=="upper"{
				
				** Search over U vectors
				
				local nrowsP = (`max'-`min')/`step'+1
				mata: P = J(`nrowsP',2,.)
				
				preserve
				qui keep if `runvar'>=-`w' & `runvar'<=`w' `ifcond' `in'
				
				local count_u = 1
				foreach nu of numlist `ulist'{

					qui {
						gsort -`outvar'
						gen `unobs_h' = _n<=`nu'

						gen `prob_h' = `ph'*`unobs_h' + `pl'*(1-`unobs_h')
						
						rdrandinf `outvar' `runvar', wl(-`w') wr(`w') bernoulli(`prob_h') reps(`reps') ///
							p(`p') nulltau(`nulltau') `stat_opt' `eval_opt' `kernel_opt' `fuzzy_opt'
						local pval_h = r(randpval)
					}

					mata: P[`count_u',2]=`pval_h'
					drop `unobs_h' `prob_h'
					
					local ++count_u
				}
				
				restore

				** bounds
				
				mata: P=(Q[1,`w_count'],Q[1,`w_count']\P) 				// include p-values when ul=uh=0 in the matrix
				mata: G`gamma_count'[3,`w_count']=max(P[.,2])
			}
			
			else if "`bound'"=="lower"{
				
				** Search over U vectors

				local nrowsP = (`max'-`min')/`step'+1
				mata: P = J(`nrowsP',2,.)
				
				preserve
				qui keep if `runvar'>=-`w' & `runvar'<=`w' `ifcond' `in'
				
				local count_u = 1
				foreach nu of numlist `ulist'{

					qui {
						sort `outvar'
						gen `unobs_l' = _n<=`nu'

						gen `prob_l' = `ph'*`unobs_l' + `pl'*(1-`unobs_l')
						
						rdrandinf `outvar' `runvar', wl(-`w') wr(`w') bernoulli(`prob_l') reps(`reps') ///
							p(`p') nulltau(`nulltau') `stat_opt' `eval_opt' `kernel_opt' `fuzzy_opt'
						local pval_l = r(randpval)
					}

					mata: P[`count_u',1]=`pval_l'
					drop `unobs_l' `prob_l'
					local ++count_u
				}
				
				restore

				** bounds
				
				mata: P=(Q[1,`w_count'],Q[1,`w_count']\P) 				// include p-values when ul=uh=0 in the matrix
				mata: G`gamma_count'[1,`w_count']=min(P[.,1])
			}
			
			else {
				di as error "bound option incorrectly specified"
				exit 198
			}
			local ++w_count
		}
		
		mata: LB=LB\G`gamma_count'[1,.]
		mata: UB=UB\G`gamma_count'[3,.]
		
		
		** Display output
		
		local numlist1 ""
		local numlist2 ""
		local numlist3 ""
		capture scalar drop g
		
		if "`bound'"==""|"`bound'"=="both"{
			forv i=1/3{
				forv j=1/`num_w'{
					mata: st_numscalar("g",G`gamma_count'[`i',`j'])
					local g = g
					local numlist`i' "`numlist`i'' `g'"
				}
			}

			if `gamma_count'==1{
				output_line, gamma(0) c0(25) step(`col_step') numlist(`wlist') line(header)
				di as text "{hline 29}{c TT}{hline `line_length'}"
			}
			output_line, gamma(`gamma') c0(25) step(`col_step') numlist(`numlist1') line(top)
			output_line, gamma(`gamma') c0(25) step(`col_step') numlist(`numlist3') line(bottom) omitg
			if `gamma_count'==`num_gamma'{
				di as text "{hline 29}{c BT}{hline `line_length'}"	
			}
			else {
				di as text "{hline 29}{c +}{hline `line_length'}"	
			}
		}
		else if "`bound'"=="lower"{
			forv i=1/2{
				forv j=1/`num_w'{
					mata: st_numscalar("g",G`gamma_count'[`i',`j'])
					local g = g
					local numlist`i' "`numlist`i'' `g'"
				}
			}
			if `gamma_count'==1{
				output_line, gamma(0) c0(25) step(`col_step') numlist(`wlist') line(header)
				di as text "{hline 29}{c TT}{hline `line_length'}"
			}
			output_line, gamma(`gamma') c0(25) step(`col_step') numlist(`numlist1') line(top)
			if `gamma_count'==`num_gamma'{
				di as text "{hline 29}{c BT}{hline `line_length'}"	
			}
			else {
				di as text "{hline 29}{c +}{hline `line_length'}"	
			}
		}
		else if "`bound'"=="upper"{
			forv i=2/3{
				forv j=1/`num_w'{
					mata: st_numscalar("g",G`gamma_count'[`i',`j'])
					local g = g
					local numlist`i' "`numlist`i'' `g'"
				}
			}
			if `gamma_count'==1{
				output_line, gamma(0) c0(25) step(`col_step') numlist(`wlist') line(header)
				di as text "{hline 29}{c TT}{hline `line_length'}"
			}
			output_line, gamma(`gamma') c0(25) step(`col_step') numlist(`numlist3') line(bottom)
			if `gamma_count'==`num_gamma'{
				di as text "{hline 29}{c BT}{hline `line_length'}"	
			}
			else {
				di as text "{hline 29}{c +}{hline `line_length'}"	
			}
		}
		local ++gamma_count
	}

********************************************************************************
** Return values
********************************************************************************

	mata: st_matrix("pvals",Q)
	if "`fmpval'"==""{
		mat pvals = pvals[1,1...]
		return matrix pvals = pvals
	}
	else {
		return matrix pvals = pvals
	}

	if "`bound'"==""|"`bound'"=="both"{
		mata: st_matrix("ubound",UB[2::rows(UB),.])
		mata: st_matrix("lbound",LB[2::rows(LB),.])
		return matrix ubound = ubound
		return matrix lbound = lbound
	}
	else if "`bound'"=="upper"{
		mata: st_matrix("ubound",UB[2::rows(UB),.])
		return matrix ubound = ubound
	}
	else if "`bound'"=="lower"{
		mata: st_matrix("lbound",LB[2::rows(LB),.])
		return matrix lbound = lbound
	}
end




********************************************************************************
********************************************************************************
** Auxiliary functions
********************************************************************************
********************************************************************************

********************************************************************************
** Output display
********************************************************************************


capture program drop output_line
program define output_line
	syntax, gamma(real) c0(real) step(real) line(string) numlist(numlist) [omitg fm]
	
	local count=0
	local c = `c0'
	
	foreach num of numlist `numlist'{
			
		if "`line'"!="header"{
			local c1 = `c'+`step'
			local numdisp "`numdisp' _col(`c1') %4.3f `num'"
		}
		else {
			local c1 = `c'+`step'-1
			local numdisp "`numdisp' _col(`c1') %6.3f `num'"
		}
		local c=`c'+`step'
		local ++count
	}

	if "`omitg'"==""{
		if "`line'"=="header"{			
				di as text "gamma" _col(8) "exp(gamma)" _col(28) "w = " `numdisp'
		}
		if "`line'"=="top"{
			di as text %5.2f log(`gamma') _col(10) %5.2f `gamma' _col(12) as text "{ralign 15: lower bound}" as text "{c |}" as res `numdisp'
		}
		else if "`line'"=="middle"{
			if "`fm'"==""{
				di as text _col(12) "{ralign 16: Bernoulli p-value}" as text "{c |}" as res `numdisp'
			}
			else {
				di as text _col(8) "{ralign 12: Fixed margins p-value}" as text "{c |}" as res `numdisp'
			}
		}
		else if "`line'"=="bottom"{
			di as text %5.2f log(`gamma') _col(10) %5.2f `gamma' _col(12) "{ralign 15: upper bound}" as text "{c |}" as res `numdisp'
		}
	}
	
	else{
		if "`line'"=="header"{	
			di _col(28) as text "w = " `numdisp'
			}
		if "`line'"=="top"{
			di as text _col(12) as text "{ralign 15: lower bound}" as text "{c |}" as res `numdisp'
		}
		else if "`line'"=="middle"{
			if "`fm'"==""{
				di as text _col(12) "{ralign 16: Bernoulli p-value}" as text "{c |}" as res `numdisp'
			}
			else {
				di as text _col(8) "{ralign 12: Fixed margins p-value}" as text "{c |}" as res `numdisp'
			}
		}
		else if "`line'"=="bottom"{
			di _col(15) as text "{ralign 15: upper bound}" as text "{c |}" as res `numdisp'
		}
	}
end

