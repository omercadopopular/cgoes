********************************************************************************
* RDWINSELECT: window selection for randomization inference in RD
* !version 1.0 2021-07-07
* Authors: Matias Cattaneo, Rocio Titiunik, Gonzalo Vazquez-Bare
********************************************************************************

version 13

capture program drop rdwinselect
program define rdwinselect, rclass sortpreserve

	syntax varlist (min=1 numeric) [if] [in] [, Cutoff(real 0)        ///
												obsmin(numlist max=1) ///												
												wmin(numlist max=2)   ///
												wobs(numlist max=1)   ///
												wstep(numlist max=1)  ///
												WASYMmetric           ///
												WMASSpoints           ///
												NWindows(real 10)     ///
												DROPMISSing           ///
												STATistic(string)     ///
												p(integer 0)          ///
												evalat(string)        ///
												kernel(string)        ///
												APPROXimate           ///
												level(real .15)       ///
												reps(integer 1000)    ///
												seed(integer 666)     ///
												plot                  ///
												graph_options(string) ///
												genvars               ///
												obsstep(numlist max=1) ]
	
	tokenize `varlist'
	local runv_aux "`1'"
	mac shift 1
	local covariates "`*'"
	marksample touse, novarlist
	marksample touse1
	
	if "`covariates'"!=""{
		capture assert `touse'==`touse1'
		if _rc!=0{
			di as text "Missing values detected in covariates"
			if "`dropmissing'"!=""{
				di as text "Missing values in covariates will be dropped"
			}
			else{
			    di as text "Consider dropmissing option to exclude missing values"
			}
		}
	}
	
	tempvar treated runvar Wid Wlength_left Wlength_right dups
		
	if "`dropmissing'"!="" & "`covariates'"!=""{
		qui gen double `runvar' = `runv_aux' - `cutoff' if `touse1'
	}
	else {
		qui gen double `runvar' = `runv_aux' - `cutoff' if `touse'
	}
		
	qui sum `runvar' if `touse'
	local runvar_max = r(max)
	local runvar_min = r(min)
	qui gen `treated' = `runvar' >= 0 if `runvar'!=. & `touse'
	sort `runvar', stable
	qui count if `treated'==0 & `touse'
	local N_control = r(N)
	qui count if `treated'==1 & `touse'
	local N_treated = r(N)
	
	qui sum `runv_aux' if `touse'
	
	if(`cutoff' <= r(min) | `cutoff' >= r(max)) {
		display as error "cutoff must be within the range of running variable"
		exit 125
	}
	
	if `p'>0 & "`approximate'"!=""&"`statistic'"!=""&"`statistic'"!="ttest"&"`statistic'"!="diffmeans"{
		di as error "approximate and p>1 can only be combined with diffmeans"
		exit 198
	}
	
	if "`evalat'"!=""&"`evalat'"!="means"&"`evalat'"!="cutoff"{
		di as error "evalat only admits means or cutoff"
		exit 198
	}
	
	if "`kernel'"!=""&"`kernel'"!="uniform"&"`kernel'"!="triangular"&"`kernel'"!="epan"{
		di as error "`kernel' not a valid kernel"
		exit 198
	}
	if "`kernel'"!="" & "`evalat'"!="" &"`evalat'"!="cutoff"{
		di as error "kernel can only be combined with evalat(cutoff)"
		exit 198
	}
	if "`statistic'"!="diffmeans"&"`statistic'"!="ttest"&"`statistic'"!=""{
		if "`kernel'"!=""&"`kernel'"!="uniform"{
			di as error "kernel only allowed for diffmeans"
			exit 198
		}
	}
	
	if `seed'==666{	
		set seed 666
	}
	else if `seed'>=0{
		set seed `seed'
	}
	else if `seed'!=-1{
		di as error "seed must be a positive integer (or -1 for system seed)"
		exit 198
	}
	else {
		local seed c(seed)
	}
	
	if "`obsmin'"!="" & "`wmin'"!= ""{
		di as error "cannot specify both obsmin and wmin"
		exit 198
	}
	if "`wobs'"!="" & "`wstep'"!=""{
		di as error "cannot specify both wobs and wstep"
		exit 198
	}
	if "`wmasspoints'"!="" & ("`obsmin'"!=""|"`wmin'"!=""|"`wobs'"!=""|"`wstep'"!=""){
		di as error "obsmin, wmin, wstep and wobs not allowed with wmasspoints"
		exit 198
	}

	qui bysort `runvar': gen `dups' = _N
	qui sum `dups'
	
	if "`wmasspoints'"!="" & r(max)==1 {
		di as error "No mass points detected, cannot set wmasspoints"
		exit 198
	}
	
	if r(max)>1{
		di as text "Mass points detected in running variable"
		di as text "You may use wmasspoints option for constructing windows at each mass point"
	}

	qui gen double `Wid' = .
	qui gen double `Wlength_left' = .
	qui gen double `Wlength_right' = .

	
********************************************************************************
** Define initial window
********************************************************************************

	if "`wmin'"==""{
		local posl = `N_control'
		local posr = `N_control' + 1

		if "`obsmin'"==""{
			local obsmin = 10
		}
		
		if "`wmasspoints'"!=""{
			local obsmin = 1
			local wasymmetric "wasymmetric"
		}
		
		if "`obsstep'"!=""{
		    qui mata: rdlocrand_findwobs_sym(`obsmin',1,`posl',`posr',"`runvar'","`dups'")
			local wmin = scalar(wlength)
		}
		
		if "`wasymmetric'"!=""{
			qui mata: rdlocrand_findwobs(`obsmin',1,`posl',`posr',"`runvar'","`dups'")
			local wmin_left = scalar(wlength_left)
			local posmin_left = poslist_left[1,1]
			local wmin_right = scalar(wlength_right)
			local posmin_right = poslist_right[1,1]
		}
		else{
		    qui mata: rdlocrand_findwobs_sym(`obsmin',1,`posl',`posr',"`runvar'","`dups'")
			local wmin_right = wlength
			local wmin_left = -wlength
		}
	}
	else {
		local wcount: word count `wmin' 
		if `wcount'==1{
			local wmin_right = `wmin'
			local wmin_left = -`wmin' 
			qui count if `runvar'>=0 & `runvar'<=`wmin'
			local posmin_right = `N_control' + r(N)
			qui count if `runvar'<0 & `runvar'>=-`wmin'
			local posmin_left = `N_control' - r(N) + 1
		}
		else if `wcount'==2{
			tokenize `wmin'
			local wmin_left = `1' - `cutoff'
			local wmin_right = `2' - `cutoff'
			qui count if `runvar'>=0 & `runvar'<=`wmin_right'
			local posmin_right = `N_control' + r(N)
			qui count if `runvar'<0 & `runvar'>=`wmin_left'
			local posmin_left = `N_control' - r(N) + 1
		}
		else{
			di as error "wmin option incorrectly specified"
			exit 125
		}
	}


********************************************************************************
** Define window list 
********************************************************************************	

	if "`obsstep'"!=""{
		di as error "Warning: obsstep included for backward compatibility only."
		di as error "The use of wstep and wobs is recommended."
		tempvar control 
		qui gen `control' = 1 - `treated'
		mata: rdlocrand_findstep(`obsmin',2,10,"`runvar'","`treated'","`control'")
		local wstep = scalar(step)
		local wmax = `wmin' + `wstep'*(`nwindows'-1)
		mata: W = range(`wmin',`wmax',`wstep')
		mata: st_matrix("wlist_right",W')
		mat wlist_left = J(1,colsof(wlist_right),.)
	}
	else if "`wstep'"!=""{
		local wmax_left = max(`wmin_left' - `wstep'*(`nwindows'-1),`runvar_min')
		local wmax_right = min(`wmin_right' + `wstep'*(`nwindows'-1),`runvar_max')
		mata: W_left = sort(range(`wmax_left',`wmin_left',`wstep'),-1)
		mata: W_right = range(`wmin_right',`wmax_right',`wstep')
		mata: st_matrix("wlist_left",W_left')
		mata: st_matrix("wlist_right",W_right')
		
	}
	else {
		if "`wobs'"=="" {
			local wobs = 5
		}
		if "`wmasspoints'"!=""{
			local wobs = 1
		}
		qui count if float(`runvar')>=float(`wmin_left') & `runvar'<0 & `touse'
		local posl = max(`N_control' - r(N),1)
		qui count if `runvar'>=0 & float(`runvar')<=float(`wmin_right') & `touse'
		local posr = min(`N_control' + 1 + r(N),_N)
		
		if "`wasymmetric'"!=""{
			mata: rdlocrand_findwobs(`wobs',`nwindows'-1,`posl',`posr',"`runvar'","`dups'")
			mat wlist_left = (`wmin_left',wlist_left)
			mat poslist_left = (`posmin_left',poslist_left)
			mat wlist_right = (`wmin_right',wlist_right)
			mat poslist_right = (`posmin_right',poslist_right)
		}
		else{
		    mata: rdlocrand_findwobs_sym(`wobs',`nwindows'-1,`posl',`posr',"`runvar'","`dups'")
			mat wlist_right = (`wmin_right',wlist)
			mat wlist_left =  (`wmin_left',wlist)
		}
	}

	local nmax = min(`nwindows',colsof(wlist_right))

	if `nmax'<`nwindows' {
		di as error "Warning: not enough observations to calculate `nwindows' windows."
		di as error "Consider changing wmin(), wobs() or wstep()."
	}
	
	
********************************************************************************
** Sample sizes
********************************************************************************
	
	tempvar treat_aux contr_aux rowmiss
	qui{
		
		gen `treat_aux' = `runvar' if `treated'==1
		_pctile `treat_aux' if `runvar'!=. & `touse', p(1 5 10 20)
		local p1t = round(r(r1),.00001)
		local p5t = round(r(r2),.00001)
		local p10t = round(r(r3),.00001)
		local p20t = round(r(r4),.00001)
		count if `treated'==1 & `runvar'<=`p1t' & `runvar'!=. & `touse'
		local nt1 = r(N)
		count if `treated'==1 & `runvar'<=`p5t' & `runvar'!=. & `touse'
		local nt5 = r(N)
		count if `treated'==1 & `runvar'<=`p10t' & `runvar'!=. & `touse'
		local nt10 = r(N)
		count if `treated'==1 & `runvar'<=`p20t' & `runvar'!=. & `touse'
		local nt20 = r(N)
		
		gen `contr_aux' = abs(`runvar') if `treated'==0
		_pctile `contr_aux' if `touse', p(1 5 10 20)
		local p1c = r(r1)
		local p5c = r(r2)
		local p10c = r(r3)
		local p20c = r(r4)
		count if `treated'==0 & `runvar'>=-`p1c' & `runvar'!=. & `touse'
		local nc1 = r(N)
		count if `treated'==0 & `runvar'>=-`p5c' & `runvar'!=. & `touse'
		local nc5 = r(N)
		count if `treated'==0 & `runvar'>=-`p10c' & `runvar'!=. & `touse'
		local nc10 = r(N)
		count if `treated'==0 & `runvar'>=-`p20c' & `runvar'!=. & `touse'
		local nc20 = r(N)		
		
	}

	
********************************************************************************	
** Define statistic
********************************************************************************

	if "`statistic'"=="" | "`statistic'"=="diffmeans" | "`statistic'"=="ttest"{
		local command "diffmeans"
		local stat_rdri "stat(diffmeans)"
	}
	else {
		if "`statistic'"=="ksmirnov"{
			local command "ksmirnov"
			local stat_rdri "stat(ksmirnov)"
		}
		else if "`statistic'"=="ranksum"{
			local command "ranksum"
			local stat_rdri "stat(ranksum)"
		}
		else if "`statistic'"=="hotelling"{
			local command "hotelling"
			if `p'>0{
				di as error "p()>0 not allowed for Hotelling statistic"
				exit 198
			}
		}
		else{
			di as error "`statistic' not a valid statistic"
			exit 198
		}
	}

	if "`approximate'"==""{
		local di_method "rdrandinf"
		local di_reps=`reps'
	}
	else {
		local di_method "approximate"
		local di_reps " ."
	}
	
	if `p'==0{
		local model "."
	}
	else if `p'==1{
		local model "linear"
	}
	else {
		local model "polynomial"
	}
	
	if "`kernel'"=="uniform"|"`kernel'"==""{
		local kernel_disp "uniform"
	}
	
	if "`kernel'"=="triangular" {
		local kernel_disp "triangular"
	}

	if "`kernel'"=="epan" {
		local kernel_disp "Epanechnikov"
	}
	
	
********************************************************************************
** Display upper panel
********************************************************************************

	di _newline
	di as text "Window selection for RD under local randomization"
	di _newline
	disp as text "Cutoff c = " as res %4.2f `cutoff'  	as text	_col(18) " {c |} " _col(19) 	 "Left of c"	_col(33) in gr "Right of c" 	      _col(51) 			"Number of obs  = " as res %13.0f `N_treated'+`N_control'
	disp as text "{hline 18}{c +}{hline 23}"                                                                                              		      _col(51) 			"Order of poly  = " as res %13.0f `p'
	disp as text "{ralign 17:Number of obs}"    				_col(18) " {c |} " _col(17) as res %9.0f `N_control'     _col(34) %9.0f  `N_treated'  _col(51) as text 	"Kernel type    = "	as res "{ralign 13: `kernel_disp'}"
	disp as text "{ralign 17:1st percentile}"   				_col(18) " {c |} " _col(17) as res %9.0f `nc1'    _col(34) %9.0f  `nt1' 	 	      _col(51) as text	"Reps           = " as res %13.0f `di_reps'
	disp as text "{ralign 17:5th percentile}"   				_col(18) " {c |} " _col(17) as res %9.0f `nc5'    _col(34) %9.0f  `nt5' 	 	      _col(51) as text	"Testing method = " as res "{ralign 13: `di_method'}"
	disp as text "{ralign 17:10th percentile}"  				_col(18) " {c |} " _col(17) as res %9.0f `nc10'   _col(34) %9.0f  `nt10' 		      _col(51) as text	"Balance test   = " as res "{ralign 13: `command'}"
	disp as text "{ralign 17:20th percentile}"  				_col(18) " {c |} " _col(17) as res %9.0f `nc20'   _col(34) %9.0f  `nt20' 


********************************************************************************
** Main results
********************************************************************************

	local matrows ""
	mat Results = J(`nmax',6,.)

	di _newline
	di as text 			_col(18) " {c |}" 			_col(23) "Bal. test " 	_col(41) "Var. name"				_col(54) "Bin. test "
	di as text _col(6) " Window" _col(19) "{c |}" 	_col(24) "p-value" 		_col(39) "(min p-value)" 		_col(55) "p-value" 	_col(66)" Obs<c " _col(74) " Obs>=c"
	di as text "{hline 18}{c +}{hline 61}"	
	
	forvalues j=1/`nmax' {	

		if "`wasymmetric'"!="" & "`wstep'"=="" & "`obsstep'"==""{
			local wlower = wlist_left[1,`j']
			local wupper = wlist_right[1,`j']

			local position_l = poslist_left[1,`j']
			local position_r = poslist_right[1,`j']

			local inwindow "`runvar' >= `runvar'[`position_l'] & `runvar' <= `runvar'[`position_r']"
		}
		else {
			local wupper = wlist_right[1,`j']
			local wlower = -`wupper'
			mat wlist_left[1,`j'] = `wlower'

			local inwindow "float(`runvar') >= float(`wlower') & float(`runvar') <= float(`wupper')"
		}

		qui replace `Wid' = (2*`treated'-1)*`j' if `inwindow' & `Wid'==. & `touse'
		qui replace `Wlength_left' = `wlower' if `inwindow' & `Wlength_left'==. & `touse'
		qui replace `Wlength_right' = `wupper' if `inwindow' & `Wlength_right'==. & `touse'

		preserve
		qui keep if `inwindow' & `runvar'!=. & `touse1'

		* Number of treated and controls 

		qui count if `treated'==1
		local nt = r(N)
		mat Results[`j',4] = `nt'
		qui count if `treated'==0
		local nc = r(N)
		mat Results[`j',3] = `nc'
		
		if `nt'==0 | `nc'==0{
			scalar minp = .
			local pbin = . 
			local xminp "-"
		}
		else{
		
			* Covariate balance test *

			if "`covariates'"!=""{
				local ncov: word count `covariates'

				* Model adjustment 

				tempvar Y_adj Y_adj_null kweights

				if "`kernel'"=="triangular" {
					local bwt = `wupper'
					local bwc = `wupper'
					qui gen `kweights' = 1-abs((`cutoff'-`runv_aux')/`bwt') if abs((`cutoff'-`runv_aux')/`bwt')<1 & `treated'==1
					qui replace `kweights' = 1-abs((`cutoff'-`runv_aux')/`bwc') if abs((`cutoff'-`runv_aux')/`bwc')<1 & `treated'==0
					local kweights_opt "[aw = `kweights']"
					local kwrd_opt "weights(`kweights')"
				}

				if "`kernel'"=="epan" {
					local bwt = `wupper'
					local bwc = `wupper'
					qui gen `kweights' = .75*(1-((`cutoff'-`runv_aux')/`bwt')^2) if abs((`cutoff'-`runv_aux')/`bwt')<1 & `treated'==1
					qui replace `kweights' = .75*(1-((`cutoff'-`runv_aux')/`bwc')^2) if abs((`cutoff'-`runv_aux')/`bwc')<1 & `treated'==0
					local kweights_opt "[aw = `kweights']"
					local kwrd_opt "weights(`kweights')"
				}

				if `p'>0{
					if "`evalat'"==""|"`evalat'"=="cutoff"{
						local evalr = `cutoff'
						local evall = `cutoff'
					}
					else {
						qui sum `runv_aux' if `treated'==1
						local evalr = r(mean)
						qui sum `runv_aux' if `treated'==0
						local evall = r(mean)
					}
					tempvar r_t r_c resid_l resid_r
					qui gen double `r_t' = `runv_aux'-`evalr'
					qui gen double `r_c' = `runv_aux'-`evall'

					foreach cov of varlist `covariates'{
						qui{

							forvalues k=1/`p'{
								gen _rpt_`cov'`k'=`r_t'^`k'
							}
							reg `cov' _rpt_`cov'* if `treated'==1 `kweights_opt'
							predict `resid_r' if e(sample), residuals
							gen double _adj_`cov' = `resid_r' + _b[_cons] if e(sample)

							forvalues k=1/`p'{
								gen _rpc_`cov'`k'=`r_c'^`k'
							}
							reg `cov' _rpc_`cov'* if `treated'==0 `kweights_opt'
							predict `resid_l' if e(sample), residuals
							replace _adj_`cov' = `resid_l' + _b[_cons] if e(sample)

							drop `resid_l' `resid_r'
						}
					}
				}

				* Balance test

				if "`statistic'"=="hotelling"{
					if "`approximate'"!=""{	
						qui hotelling `covariates', by(`treated')
						local pval_h = 1-F(r(k),r(N)-1-r(k),((r(N)-r(k)-1))/((r(N)-2)*r(k))*r(T2))
					}
					else{
						qui permute `treated' stat=r(T2), reps(`reps') nowarn nodots: ///
							hotelling `covariates', by(`treated')					
						mat Pvals = r(p)'
						if Pvals[1,1] ==. {
							mat Pvals = r(p_twosided)'
						}
						local pval_h = Pvals[1,1]
					}
					local xminp "-"
				}

				else{
					matrix Pvals = J(`ncov',1,.)
					local row = 1	

					if "`approximate'"!=""{	
						foreach cov of varlist `covariates'{
							local cov_`row' `cov'
							local dcov_`row' `cov'
							if "`statistic'"=="ttest"|"`statistic'"=="diffmeans"|"`statistic'"==""{
								if `p'==0{
									qui reg `cov' `treated' `kweights_opt', vce(hc2)
									local asy_p = 2*normal(-abs(_b[`treated']/_se[`treated']))
								}
								else {
									if "`evalat'"==""|"`evalat'"=="cutoff"{
										forvalues k=1/`p'{
											gen _rp_`cov'`k'=`runvar'^`k'
										}
										qui reg `cov' `treated'##c.(_rp_`cov'*) `kweights_opt', vce(hc2)	
										local asy_p = 2*normal(-abs(_b[1.`treated']/_se[1.`treated']))
									}
									else {
										qui reg `cov' _runpoly_t_* if `treated'==1
										local a_t = _b[_cons]
										local se_t = _se[_cons]
										qui reg `cov' _runpoly_c_* if `treated'==0
										local a_c = _b[_cons]
										local se_c = _se[_cons]
										local asy_p = 2*normal(-abs(`obs_stat'/sqrt(`se_t'^2+`se_c'^2)))
									}
								}
							}
							else {
								rdrandinf_model `cov' `treated', stat(`statistic') asy
								local asy_p = r(asy_pval)
							}

							mat Pvals[`row',1]=`asy_p'
							local ++row
						}
					}

					else {
						local stat_list ""
						if `p'==0{
							foreach cov in `covariates'{
								local cov_`row' `cov'
								local dcov_`row' `cov'
								local stat_list "`stat_list' stat_`row'=r(stat_`row')"
								local ++row
							}
							qui{
								permute `treated' `stat_list', reps(`reps') nowarn nodots: ///
									rdwinselect_allcovs `covariates', treat(`treated') runvar(`runvar') ///
									`stat_rdri' `kwrd_opt'
								mat Pvals = r(p)'
								if Pvals[1,1] ==. {
									mat Pvals = r(p_twosided)'
								}
							}
						}
						else {
							foreach cov in `covariates' {
								local cov_`row' _adj_`cov'
								local dcov_`row' `cov'
								local stat_list "`stat_list' stat_`row'=r(stat_`row')"
								local ++row
							}
							qui{
								permute `treated' `stat_list', reps(`reps') nowarn nodots: ///
									rdwinselect_allcovs _adj_*, treat(`treated') runvar(`runvar') ///
									`stat_rdri' `kwrd_opt'
								mat Pvals = r(p)'
								if Pvals[1,1] ==. {
									mat Pvals = r(p_twosided)'
								}
							}
						}
					}

					mata: minindex(st_matrix("Pvals"),1,minindpi=.,minindpj=.)
					mata: st_numscalar("minp",min(st_matrix("Pvals")))
					mata: st_numscalar("minindp",minindpi[1,1])
					local ind = scalar(minindp)
					local xminp "`dcov_`ind''"
				}

			}

			else {
				matrix Pvals = J(1,1,.)
				local xminp "-"
			}

			* Binomial test 

			qui bitest `treated' = 1/2
			mat Results[`j',2] = r(p)
			local pbin = r(p)

		
		}

		* Window length 
		
		mat Results[`j',5] = `wlower'
		mat Results[`j',6] = `wupper'
		
		* Display results
		
		if "`covariates'"!=""{
			if "`statistic'"!="hotelling"{
				mat Results[`j',1] = minp
				output_line `wlower'+`cutoff' `wupper'+`cutoff' scalar(minp) `xminp' `pbin' `nt' `nc'
			}
			else {
				mat Results[`j',1] = `pval_h'
				output_line `wlower'+`cutoff' `wupper'+`cutoff' `pval_h' `xminp' `pbin' `nt' `nc'
			}
		}
		else {
			mat Results[`j',1] = .
			output_line `wlower'+`cutoff' `wupper'+`cutoff' . `xminp' `pbin' `nt' `nc'
		}
		local matrows " `matrows' "`j'""
		
		restore
	}
	
	mat colnames Results = "Bal test" "Bin test" "Obs<c" "Obs>=c" "w_left" "w_right"
	mat rownames Results = `matrows'
	
	di _newline as text "Variable used in binomial test (running variable): " as res "`runv_aux'"
	if "`covariates'"!=""{
		local ls_prev = c(linesize)
		set linesize 80
		di as text "Covariates used in balance test: " as res "`covariates'"
		set linesize `ls_prev'
		if "`approximate'"!="" & `p'>0 & ("`statistic'"=="ranksum" | "`statistic'"=="ksmirnov"){
			di as error "warning: asymptotic p-values do not account for outcome model adjustment."
		}
	}
	else {
		di _newline as text "Note: no covariates specified."
	}
	

********************************************************************************
** Recommended window: largest window before first crossing
********************************************************************************

	if "`covariates'"!=""{		
		mata: Q = st_matrix("Results")
		mata: rdlocrand_reclength(Q[,1],`level')
		local rec_left = abs(Results[index,5])
		local rec_right = abs(Results[index,6])
		
		if index==.{
			di _newline as error "Smallest window doesn't pass covariate test. " ///
				_newline "Consider modifying smallest window or reducing the level."
			
			local Nr = .
			local Nl = .
			local Nw = .
			local minp = .
		}
		else {
			di _newline as text "Recommended window is" as res " [" %6.3f `cutoff'-`rec_left' "; " %6.3f `cutoff'+`rec_right' "]" ///
				 as text " with " as res Results[index,3]+Results[index,4] as text " observations (" as res Results[index,3] ///
				 as text " below, " as res Results[index,4] as text " above)."
			local Nw = Results[index,3]+Results[index,4]
			local Nl = Results[index,3]
			local Nr = Results[index,4]
			local minp = Results[index,1]
		}
	}
	else {
		di "Need to specify covariates to find recommended length."
	}	
	
	
********************************************************************************
** Generate plot (if specified)
********************************************************************************

	if "`plot'"!=""{
		if "`covariates'"==""{
			di as error "Cannot draw plot without covariates."
			exit 498
		}
		else {
			preserve
			capture drop _plotvars*
			qui svmat Results, names(_plotvars)
			local xlabels ""
			forvalues i=1(4)`nwindows'{
				local xlabel_`i': di %4.2f _plotvars6[`i']
				local xlabels "`xlabels' `xlabel_`i''"
			}
			if "`graph_options'"==""{
				twoway scatter _plotvars1 _plotvars6, title("Minimum p-value from covariate test") ///
					xtitle("window length (right of c)") ytitle(P-value) ///
					xlabel(`xlabels') yline(`level', lpattern(shortdash) lcolor(black)) ///
					ysc(r(0)) ///
					note(The dotted line corresponds to p-value=`level')
			}
			else {
				twoway scatter _plotvars1 _plotvars6, `graph_options'
			}
			drop _plotvars*
			restore
		}
	}
	
	
********************************************************************************
** Generate window variables
********************************************************************************

	if "`genvars'"!=""{
		qui gen double _wid = `Wid'
		qui gen double _wlength_left = `Wlength_left'
		qui gen double _wlength_right = `Wlength_right'
	}
	
	
********************************************************************************
** Return values
********************************************************************************

	return local seed = `seed'
	return matrix results = Results	
	return matrix wlist_right = wlist_right
	return matrix wlist_left = wlist_left
	
	return scalar nwindows = `nmax'
	capture return scalar wmin_left = `wmin_left' + `cutoff'
	capture return scalar wmin_right = `wmin_right' + `cutoff'
	capture return scalar wobs = `wobs'
	capture return scalar wstep = `wstep'
	
	if "`covariates'"!=""{
		return scalar w_left = `cutoff'-`rec_left'
		return scalar w_right = `cutoff'+`rec_right'
		return scalar N_right = `Nr'
		return scalar N_left = `Nl'
		return scalar N = `Nw'
		return scalar minp = `minp'
	}
	else {
		return scalar w_left = .
		return scalar w_right = .
	}
	
	
end


********************************************************************************
********************************************************************************
** Auxiliary function for output display
********************************************************************************
********************************************************************************

capture program drop output_line
program output_line
	args window_l window_r cov vname bin nt nc
	display as res %8.3f `window_l' as text "|" as res %8.3f `window_r'	_col(18) as text " {c |}" as result _col(26) %4.3f `cov' " " _col(38) %10s abbrev("`vname'",16)  _col(54) %8.3f `bin'  " " _col(64) %8.0f   `nc' " " _col(73) %8.0f `nt'
end

