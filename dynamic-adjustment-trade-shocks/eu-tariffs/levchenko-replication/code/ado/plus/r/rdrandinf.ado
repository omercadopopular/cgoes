********************************************************************************
* RDRANDINF: randomization inference in RD designs
* !version 1.0 2021-07-07
* Authors: Matias Cattaneo, Rocio Titiunik, Gonzalo Vazquez-Bare
********************************************************************************

version 13

capture program drop rdrandinf
program define rdrandinf, rclass sortpreserve
	
	syntax varlist(min=2 max=2 numeric) [if] [in] [, Cutoff(real 0)              ///
													 wl(numlist max=1)           ///
													 wr(numlist max=1)           ///
													 STATistic(string)           ///
													 p(integer 0)                ///
													 evall(numlist max=1)        ///
													 evalr(numlist max=1)        ///
													 kernel(string)              ///
													 fuzzy(namelist min=1 max=2) ///
													 NULLtau(real 0)             ///
													 d(numlist max=1)            ///
													 dscale(numlist max=1)       ///
													 ci(string)                  ///
													 INTERFci(real 0)            ///
													 BErnoulli(string)           ///
													 reps(integer 1000)          ///
													 seed(integer 666)           ///
													 COVariates(namelist)        ///
													 obsmin(numlist max=1)       ///
													 wmin(numlist max=1)         ///
													 wobs(numlist max=1)         ///
													 wstep(numlist max=1)        ///
													 WASYMmetric                 ///
													 WMASSpoints                 ///
													 NWindows(real 10)           ///
													 rdwstat(string)             ///
													 DROPMISSing                 ///
													 APPROXimate                 ///
													 rdwreps(real 1000)          ///
													 level(real .15)             ///
													 plot                        ///
													 graph_options(string)       ///
													 obsstep(numlist max=1)      ///
													 QUIetly]
	
	tempvar tr
	tempvar runvar
	tempvar Y_adj
	tempfile permbase
	
	marksample touse, novarlist

		
	tokenize `varlist'
	local Y "`1'"
	local r "`2'"
	qui gen `tr' = `r' >= `cutoff' if `r'!=. & `touse'
	qui gen double `runvar' = `r' - `cutoff'
		
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
			
	quietly summarize `r' if `Y'!=. & `touse'
	local rmin = r(min)
	local rmax = r(max)
	if(`cutoff' <= `rmin' | `cutoff' >= `rmax') {
		display as error "cutoff must be within the range of running variable"
		exit 125
	}
	
	if `p'<0{
		di as error "p must be a positive number"
		exit 198
	}
	
	if "`kernel'"!="" {
		if "`kernel'"!="uniform"&"`kernel'"!="triangular"&"`kernel'"!="epan"{
			di as error "`kernel' not a valid kernel"
			exit 198
		}
		if "`evall'"!="" & "`evalr'"!=""{
			if `evall'!=`cutoff' | `evalr'!=`cutoff'{
				di as error "kernel only allowed when evall=evalr=cutoff"
				exit 198
			}
		}
		if "`statistic'"!="ttest"&"`statistic'"!=""&"`statistic'"!="diffmeans"{
			di as error "kernel only allowed for diffmeans"
			exit 198
		}
	}
	
	if "`ci'"!=""{
		gettoken ci_level ci_tlist: ci
		capture confirm number `ci_level'
		if _rc{
			di as error "ci level incorrectly specified"
			exit 198
		}
		if `ci_level'<0|`ci_level'>1{
			di as error "ci level must be in (0,1)"
			exit 198
		}
		if "`ci_tlist'"!=""{
			local tlist_opt "tlist(`ci_tlist')"
		}
	}
	
	if `interfci'<0|`interfci'>1{
		di as error "intertfci() must be in (0,1)"
		exit 198
	}
	else if `interfci'>0{
		if "`statistic'"!=""&"`statistic'"!="ttest"&"`statistic'"!="diffmeans"&"`statistic'"!="ksmirnov"&"`statistic'"!="ranksum"{
			di as error "only diffmeans, ksmirnov or ranksum allowed when interfci is specified"
			exit 198
		}
	}
	
	if "`bernoulli'"!=""{
		qui sum `bernoulli' `if' `in'
		if r(min)<0 | r(max)>1{
			di as error "bernoulli probabilities must be between 0 and 1"
			exit 198
		}
	}
	
	
********************************************************************************
*** Set window
********************************************************************************

	if "`wl'"!="" & "`wr'"!=""{
		if "`covariates'"!=""{
			di as error "Warning: window specified by the user; covariates ignored"
		}
		if `wl'>=`wr'{
			di as error "wl has to be smaller than wr"
			exit 198
		}
		else if `wl'>=`cutoff' | `wr'<=`cutoff'{
			di as error "specified window does not include cutoff"
			exit 198
		}
		local wselect "set by user"
	}
	
	else if "`wl'"=="" & "`wr'"==""{
		if "`covariates'"!=""{
			if "`obsmin'"!=""{
				local obsmin_opt "obsmin(`obsmin')"
			}
			if "`obsstep'"!=""{
				local obsstep_opt "obsstep(`obsstep')"
			}
			if "`wmin'"!=""{
				local wmin_opt "wmin(`wmin')"
			}
			if "`wstep'"!=""{
				local wstep_opt "wstep(`wstep')"
			}
			if "`wobs'"!=""{
				local wobs_opt "wobs(`wobs')"
			}
			if "`nwindows'"!=""{
				local nwindows_opt "nwindows(`nwindows')"
			}
			if "`rdwstat'"=="" | "`rdwstat'"=="diffmeans" | "`rdwstat'"=="ttest"{
				local rdwstat_opt "stat(diffmeans)"
			}
			else {
				if "`rdwstat'"=="ksmirnov"{
					local rdwstat_opt "stat(ksmirnov)"
				}
				else if "`rdwstat'"=="ranksum"{
					local rdwstat_opt "stat(ranksum)"
				}
				else{
					di as error "`rdwstat' not a valid statistic for rdwinselect"
					exit 198
				}
			}
			if "`approximate'"!=""{
				local approximate_opt "approximate"
			}

			if "`level'"!=""{
				local level_opt "level(`level')"
			}
			if "`plot'"!=""{
				local plot_opt "plot"
			}
			if "`graph_options'"!=""{
				local graph_opt `graph_options'
			}
			
			di as text "Calculating window..."
			
			if "`quietly'"==""{
				rdwinselect `r' `covariates' if `touse', c(`cutoff') `obsmin_opt' `obsstep_opt' `wmin_opt' `wstep_opt' `wasymmetric' `wmasspoints' ///
					`wobs_opt' `nwindows_opt' `rdwstat_opt' `approximate_opt' reps(`rdwreps') `level_opt' `dropmissing' `plot_opt' `graph_opt'
			}
			else {
				qui rdwinselect `r' `covariates' if `touse', c(`cutoff') `obsmin_opt' `obsstep_opt' `wmin_opt' `wstep_opt' `wasymmetric' `wmasspoints' ///
					`wobs_opt' `nwindows_opt' `approximate_opt' reps(`rdwreps') `level_opt' `dropmissing' `plot_opt' `graph_opt'
			}	
			if r(w_left)==. | r(w_right)==.{
				di as error "rdwinselect could not find a recommended window"
				exit 498
			}
			
			local wl = r(w_left)
			local wr = r(w_right)
			local wselect "rdwinselect"
		}
		else{
			local wl = `rmin'
			local wr = `rmax'
			local wselect = "runvar range"
		}
	}
	else if "`wl'"=="" & "`wr'"!=""{
		di as error "wl not specified"
		exit 198
	}
	else if "`wl'"!="" & "`wr'"==""{
		di as error "wr not specified"
		exit 198
	}
	
	local inwindow "float(`r') >= float(`wl') & float(`r') <= float(`wr')"
	
	if "`evall'"!="" & "`evalr'"=="" {
		di as error "evalr not specified"
		exit 198
	}
	else if "`evall'"=="" & "`evalr'"!="" {
		di as error "evall not specified"
		exit 198
	}
	else if "`evall'"!="" & "`evalr'"!="" {
		if `evall'<`wl' | `evalr'>`wr'{
			di as error "evall and evalr need to be inside window"
			exit 198
		}
	}
	
	di _newline as text "Selected window = " as res "[" `wl' " ; " `wr' "]"

	
********************************************************************************
*** Summary statistics
********************************************************************************

	qui count if `r'!=. & `Y'!=. & `touse'
	local n_tot = r(N)
	qui count if `tr'==1 & `r'!=. & `Y'!=. & `touse'
	local n_tot_right = r(N)
	qui count if `tr'==0 & `r'!=. & `Y'!=. & `touse'
	local n_tot_left = r(N)
	
	qui count if `inwindow' & `tr'==1 & `r'!=. & `Y'!=. & `touse'
	local n_right = r(N)
	qui count if `inwindow' & `tr'==0 & `r'!=. & `Y'!=. & `touse'
	local n_left = r(N)
	qui sum `Y' if `inwindow' & `tr'==1 & `r'!=. & `Y'!=. & `touse'
	local m_right = r(mean)
	local s_right = r(sd)
	qui sum `Y' if `inwindow' & `tr'==0 & `r'!=. & `Y'!=. & `touse'
	local m_left = r(mean)
	local s_left = r(sd)	
	
	if "`d'"!="" & "`dscale'"!=""{
		di as error "cannot specify both d and dscale"
		exit 198
	}
	if "`d'"=="" & "`dscale'"==""{
		local delta = `s_left'*.5
	}
	if "`d'"!="" & "`dscale'"==""{
		local delta = `d'
	}
	if "`d'"=="" & "`dscale'"!=""{
		local delta = `dscale'*`s_left'
	}
	


********************************************************************************
*** Results
********************************************************************************
	
	if "`fuzzy'"==""{
		if "`statistic'"=="ttest" | "`statistic'"=="diffmeans" | "`statistic'"==""{
			local stat_permute "diffmeans"
			local stat_list "stat=r(stat)"
			local statdisp "Diff. in means"
			local stat_opt_ci "stat(`statistic')"
		}
		else {
			local stat_permute "`statistic'"
			if "`statistic'"=="ksmirnov"{
				local statdisp "Kolmogorov-Smirnov"
				local stat_list "stat=r(stat)"
				local stat_opt_ci "stat(`statistic')"
			}
			else if "`statistic'"=="ranksum"{
				local statdisp "Rank sum z-stat"
				local stat_list "stat=r(stat)"
				local stat_opt_ci "stat(`statistic')"
			}
			else if "`statistic'"=="all"{
				local stat_list "stat1=abs(r(stat1)) stat2=r(stat2) stat3=abs(r(stat3))"
				local right "right"
				local stat_opt_ci "stat(`statistic')"
			}
			else {
				di as error "`statistic' not a valid statistic"
				exit 198
			}
		}
	}
	
	else {
		if "`statistic'"!=""{
			di as error "cannot specify statistic() for fuzzy designs"
			exit 198
		}
		else {
			tokenize `fuzzy'
			local fuzzy_treat "`1'"
			local fuzzy_stat "`2'"
			
			if "`fuzzy_stat'"=="ar"|"`fuzzy_stat'"==""|"`fuzzy_stat'"=="itt"{
				local stat_permute "ar"
				local stat_list "stat=r(stat)"
				local statdisp "ITT"
				local fuzzy_cond "endogtr(`fuzzy_treat')"
				local fuzzy_cond_ci "fuzzy(`fuzzy_treat')"

			}
			else if "`fuzzy_stat'"=="tsls"{
				local stat_permute "wald"
				local stat_list "stat=r(stat)"
				local statdisp "TSLS"
				local fuzzy_cond "endogtr(`fuzzy_treat')"
			}
			else {
				di as error "`fuzzy_stat' not a valid statistic"
				exit 198
			}
		}
	}	

	preserve
	qui keep if `inwindow' & `touse'
	qui drop if `Y'==. | `r' ==.
	if "`fuzzy'"!=""{
		qui drop if `fuzzy_treat'==.
	}
	
	** Adjustment of outcomes

	tempvar Y_adj Y_adj_null kweights
	
	if "`kernel'"=="uniform"|"`kernel'"==""{
		local kernel_disp "uniform"
	}
	
	if "`kernel'"=="triangular" {
		local bwt = `wr'-`cutoff'
		local bwc = `wl'-`cutoff'
		qui gen `kweights' = 1-abs((`cutoff'-`r')/`bwt') if abs((`cutoff'-`r')/`bwt')<1 & `tr'==1
		qui replace `kweights' = 1-abs((`cutoff'-`r')/`bwc') if abs((`cutoff'-`r')/`bwc')<1 & `tr'==0
		local kweights_opt "[aw = `kweights']"
		local kwrd_opt "weights(`kweights')"
		local kernel_disp "triangular"
	}

	if "`kernel'"=="epan" {
		local bwt = `wr'-`cutoff'
		local bwc = `wl'-`cutoff'
		qui gen `kweights' = .75*(1-((`cutoff'-`r')/`bwt')^2) if abs((`cutoff'-`r')/`bwt')<1 & `tr'==1
		qui replace `kweights' = .75*(1-((`cutoff'-`r')/`bwc')^2) if abs((`cutoff'-`r')/`bwc')<1 & `tr'==0
		local kweights_opt "[aw = `kweights']"
		local kwrd_opt "weights(`kweights')"
		local kernel_disp "Epanechnikov"
	}

	if `p'==0 {
		qui gen double `Y_adj' = `Y'
	}
	else {
		qui{
			if "`evall'"=="" & "`evalr'"==""{
				local evalr = `cutoff'
				local evall = `cutoff'
			}
			
			tempvar r_t r_c resid_l resid_r
			gen double `r_t' = `r'-`evalr'
			gen double `r_c' = `r'-`evall'
			
			forvalues k=1/`p'{
				gen _runpoly_t_`k'=`r_t'^`k'
			}
			reg `Y' _runpoly_t_* if `tr'==1 `kweights_opt'
			predict `resid_r' if e(sample), residuals
			gen double `Y_adj' = `resid_r' + _b[_cons] if e(sample)
			
			forvalues k=1/`p'{
				gen _runpoly_c_`k'=`r_c'^`k'
			}
			reg `Y' _runpoly_c_* if `tr'==0 `kweights_opt'
			predict `resid_l' if e(sample), residuals
			replace `Y_adj' = `resid_l' + _b[_cons] if e(sample)
		}
	}
	
	if "`fuzzy'"==""{
		qui gen double `Y_adj_null' = `Y_adj'-`nulltau'*`tr'
	}
	else {
		qui gen double `Y_adj_null' = `Y_adj'-`nulltau'*`fuzzy_treat'
	}

	** Observed values, asymptotic p-values and power

	tempvar Y_null

	qui{
		gen double `Y_null' = `Y'-`nulltau'*`tr'
		if "`statistic'"=="ttest"|"`statistic'"=="diffmeans"|"`statistic'"==""|"`statistic'"=="all"{
			if `p'==0{
				reg `Y_null' `tr' `kweights_opt', vce(hc2)
				if "`statistic'"=="all"{
					local obs_stat1 = _b[`tr']
					local asy_p1 = 2*normal(-abs(_b[`tr']/_se[`tr']))
					local power1 = 1-normal(1.96-`delta'/_se[`tr'])+normal(-1.96-`delta'/_se[`tr'])
				}
				else{
					local obs_stat = _b[`tr']
					local asy_p = 2*normal(-abs(_b[`tr']/_se[`tr']))
					local power = 1-normal(1.96-`delta'/_se[`tr'])+normal(-1.96-`delta'/_se[`tr'])
				}
			}
			else {
				if `evall'==`cutoff' & `evalr'==`cutoff'{
					forvalues k=1/`p'{
						gen _runpoly_all`k'=`runvar'^`k'
					}
					reg `Y_null' `tr'##c.(_runpoly_all*) `kweights_opt', vce(hc2)
					if "`statistic'"=="all"{
						local obs_stat1 = _b[1.`tr']
						local asy_p1 = 2*normal(-abs(_b[1.`tr']/_se[1.`tr']))
						local power1 = 1-normal(1.96-`delta'/_se[1.`tr'])+normal(-1.96-`delta'/_se[1.`tr'])					
					}
					else {
						local obs_stat = _b[1.`tr']
						local asy_p = 2*normal(-abs(_b[1.`tr']/_se[1.`tr']))
						local power = 1-normal(1.96-`delta'/_se[1.`tr'])+normal(-1.96-`delta'/_se[1.`tr'])
					}
				}
				else {
					reg `Y_null' _runpoly_t_* if `tr'==1
					local a_t = _b[_cons]
					local se_t = _se[_cons]
					reg `Y_null' _runpoly_c_* if `tr'==0
					local a_c = _b[_cons]
					local se_c = _se[_cons]
					if "`statistic'"=="all"{
						local obs_stat1 = `a_t'-`a_c'
						local asy_p1 = 2*normal(-abs(`obs_stat1'/sqrt(`se_t'^2+`se_c'^2)))
						local power1 = 1-normal(1.96-`delta'/sqrt(`se_t'^2+`se_c'^2))+normal(-1.96-`delta'/sqrt(`se_t'^2+`se_c'^2))
					}
					else {
						local obs_stat = `a_t'-`a_c'
						local asy_p = 2*normal(-abs(`obs_stat'/sqrt(`se_t'^2+`se_c'^2)))
						local power = 1-normal(1.96-`delta'/sqrt(`se_t'^2+`se_c'^2))+normal(-1.96-`delta'/sqrt(`se_t'^2+`se_c'^2))
					}
				}
			}
		}
		
		if "`statistic'"=="ksmirnov"|"`statistic'"=="all"{
			ksmirnov `Y_adj_null', by(`tr')
			if "`statistic'"=="all"{
				local obs_stat2 = r(D)
				if `p'==0{
					local asy_p2 = r(p)
					local power2 = "."
				}
				else {
					local asy_p2 "."
					local power2 "."
				}
			}
			else{
				local obs_stat = r(D)
				local power = "."
				if `p'==0{
					local asy_p = r(p)
				}
				else {
					local asy_p "."
				}
			}
		}
		
		if "`statistic'"=="ranksum"|"`statistic'"=="all"{
			ranksum `Y_adj_null', by(`tr')
			if "`statistic'"=="all"{
				local obs_stat3 = r(z)
				if `p'==0 {
					local asy_p3 = 2*normal(-abs(r(z)))
					qui count if `tr'==1
					local nt=r(N)
					qui count if `tr'==0
					local nc=r(N)
					qui sum `Y'
					local sd = r(sd)
					local power3 = normal(sqrt(3*`nc'*`nt'/((`nc'+`nt'+1)*_pi))*`delta'/`sd'-1.96)
				}
				else {
					local asy_p3 "."
					local power3 "."
				}
			}
			else {
				local obs_stat = r(z)
				if `p'==0 {
					local asy_p = 2*normal(-abs(r(z)))
					qui count if `tr'==1
					local nt=r(N)
					qui count if `tr'==0
					local nc=r(N)
					local power = normal(sqrt(3*`nc'*`nt'/((`nc'+`nt'+1)*_pi))*`delta'/`sd'-1.96)
				}
				else {
					local asy_p "."
				}
			}
		}
		
		if "`fuzzy'"!=""{
			tempvar Y_fuzzy
			gen double `Y_fuzzy' = `Y'-`nulltau'*`fuzzy_treat'
			
			if "`fuzzy_stat'"=="ar"|"`fuzzy_stat'"==""{
				if `p'==0{
					reg `Y_fuzzy' `tr' `kweights_opt', vce(hc2)
					local obs_stat = _b[`tr']
					local asy_p = 2*normal(-abs(_b[`tr']/_se[`tr']))
					local power = 1-normal(1.96-`delta'/_se[`tr'])+normal(-1.96-`delta'/_se[`tr'])
				}
				else {
					forvalues k=1/`p'{
						capture gen _runpoly_all`k'=`runvar'^`k'
					}
					reg `Y_fuzzy' `tr'##c.(_runpoly_all*) `kweights_opt', r
					local obs_stat = _b[1.`tr']
					local asy_p = 2*normal(-abs(_b[1.`tr']/_se[1.`tr']))
					local power = 1-normal(1.96-`delta'/_se[1.`tr'])+normal(-1.96-`delta'/_se[1.`tr'])
				}
			}
			else {
				if `p'==0{
					ivregress 2sls `Y_fuzzy' (`fuzzy_treat'=`tr') `kweights_opt', robust
					local obs_stat = _b[`fuzzy_treat']
					local asy_p = 2*normal(-abs(_b[`fuzzy_treat']/_se[`fuzzy_treat']))
					local power = 1-normal(1.96-`delta'/_se[`fuzzy_treat'])+normal(-1.96-`delta'/_se[`fuzzy_treat'])				
					local ci_lb = `obs_stat' - 1.96*_se[`fuzzy_treat']
					local ci_ub = `obs_stat' + 1.96*_se[`fuzzy_treat']
				}
				else {
					forvalues k=1/`p'{
						capture gen _runpoly_all`k'=`runvar'^`k'
						gen _interpoly_`k'=_runpoly_all`k'*`tr'
					}
					ivregress 2sls `Y_fuzzy' _runpoly_all* _interpoly_* (`fuzzy_treat'=`tr') `kweights_opt', robust
					local obs_stat = _b[`fuzzy_treat']
					local asy_p = 2*normal(-abs(_b[`fuzzy_treat']/_se[`fuzzy_treat']))
					local power = 1-normal(1.96-`delta'/_se[`fuzzy_treat'])+normal(-1.96-`delta'/_se[`fuzzy_treat'])
					local ci_lb = `obs_stat' - 1.96*_se[`fuzzy_treat']
					local ci_ub = `obs_stat' + 1.96*_se[`fuzzy_treat']
					drop _runpoly* _interpoly*
				}
			}
		}
	}

	
	** Randomization test
	
	if "`fuzzy_stat'"!="tsls"{
		di _newline as text "Running randomization-based test..."

		if "`bernoulli'"==""{
			local assimech "fixed margins"
			qui permute `tr' `stat_list', reps(`reps') nodots nowarn saving(`permbase'): ///
					rdrandinf_model `Y_adj_null' `tr', stat(`stat_permute') `kwrd_opt' `fuzzy_cond'
			
			di as text "Randomization-based test complete."

			if "`statistic'"=="all"{
				matrix aux1 = r(p)
				if aux1[1,1]==.{
					mat aux1 = r(p_twosided)
				}
				matrix aux2 = (`obs_stat1',`obs_stat2',`obs_stat3')
			}
			else {
				matrix aux = r(p)
				if aux[1,1]==.{
					mat aux = r(p_twosided)
				}
				mat aux2 = r(b)
				local randp = aux[1,1]
			}
		}	
		
		else {
			local assimech "    bernoulli"
			if "`statistic'"=="all"{
				mata: B = J(`reps',3,.)
				forv i=1/`reps'{
					qui gen _treat = runiform()<=`bernoulli'
					qui count if _treat==1 & _treat!=. & `Y_adj_null'!=.
					local nt = r(N)
					qui count if _treat==0 & _treat!=. & `Y_adj_null'!=.
					local nc = r(N)
					if `nt'>1 & `nc'>1{
						qui rdrandinf_model `Y_adj_null' _treat, stat(`stat_permute') `kwrd_opt' `fuzzy_cond'
						local beta1 = r(stat1)
						mata: B[`i',1] = `beta1'
						local beta2 = r(stat2)
						mata: B[`i',2] = `beta2'
						local beta3 = r(stat3)
						mata: B[`i',3] = `beta3'
					}
					else {
						mata: B[`i',1] = .
						mata: B[`i',2] = .
						mata: B[`i',3] = .
					}
					drop _treat
				}
				
				di as text "Randomization-based test complete."
				
				mata: st_numscalar("p1_mata",mean(abs(B[.,1]):>=abs(`obs_stat1')))
				mata: st_numscalar("p2_mata",mean(abs(B[.,2]):>=abs(`obs_stat2')))
				mata: st_numscalar("p3_mata",mean(abs(B[.,3]):>=abs(`obs_stat3')))
				matrix aux1 = (scalar(p1_mata),scalar(p2_mata),scalar(p3_mata))
				matrix aux2 = (`obs_stat1',`obs_stat2',`obs_stat3')

			}
			else {
				mata: B = J(`reps',1,.)
				forv i=1/`reps'{
					qui gen _treat = runiform()<=`bernoulli'
					qui count if _treat==1 & _treat!=. & `Y_adj_null'!=.
					local nt = r(N)
					qui count if _treat==0 & _treat!=. & `Y_adj_null'!=.
					local nc = r(N)
					if `nt'>1 & `nc'>1{
						qui rdrandinf_model `Y_adj_null' _treat, stat(`stat_permute') `kwrd_opt' `fuzzy_cond'
						local beta = r(stat)
						mata: B[`i',1] = `beta'
					}
					else {
						mata: B[`i',1] = .
					}
					drop _treat
				}
				
				di as text "Randomization-based test complete."
				
				mata: st_numscalar("p1_mata",mean(abs(B[.,1]):>=abs(`obs_stat')))
				local randp = scalar(p1_mata)
			}
		}
	} 
	else {
		local randp "."
	}

	restore
	
	if "`fuzzy_stat'"!="tsls"{
		if `interfci'>0{
			preserve
			qui use `permbase', clear
				local qlow = 100*`interfci'/2
				local qhigh = 100*(1-`interfci'/2)
				_pctile stat, p(`qlow' `qhigh')
				local k1=r(r1)
				local k2=r(r2)
			restore
		}
	}
	
********************************************************************************
*** Display results
********************************************************************************

	if `p'==0{
		local model "."
	}
	else if `p'==1{
		local model "linear"
	}
	else {
		local model "polynomial"
	}
	
	if "`fuzzy'"==""{
		local inference "sharp design"
	}
	else{
		local inference "fuzzy design"
	}
		
	di _newline
	di as text "Inference for `inference'"
	di _newline 
	di as text "Cutoff c = " as res %4.2f `cutoff' 	as text _col(19) "{c |}" 	_col(22) "Left of c" 				_col(33) "Right of c"			_col(51) 		 "Number of obs = " as res %14.0f `n_tot'
	di as text "{hline 18}{c +}{hline 23}"																											_col(51) 		 "Order of poly = "	as res %14.0f `p'
	di as text "{ralign 18:Number of obs}"					_col(19) "{c |}" 	_col(22) as res %9.0f `n_tot_left'	_col(33) %10.0f `n_tot_right'	_col(51) as text "Kernel type   = "	 as res "{ralign 14: `kernel_disp'}"
	di as text "{ralign 18:Eff. Number of obs}"				_col(19) "{c |}" 	_col(22) as res %9.0f `n_left'		_col(33) %10.0f `n_right'		_col(51) as text "Reps          = " as res %14.0f `reps'
	di as text "{ralign 18:Mean of outcome}"				_col(19) "{c |}" 	_col(22) as res %9.3f `m_left'		_col(33) %10.3f `m_right'		_col(51) as text "Window        = " as res "{ralign 14: `wselect'}"
	di as text "{ralign 18:S.D. of outcome}"				_col(19) "{c |}" 	_col(22) as res %9.3f `s_left'		_col(33) %10.3f `s_right'		_col(51) as text "H0:       tau = " as res %14.3f `nulltau'
	di as text "{ralign 18:Window}"							_col(19) "{c |}" 	_col(22) as res %9.3f `wl'			_col(33) %10.3f `wr'			_col(51) as text "Randomization = " as res "{ralign 12: `assimech'}"

	di as text _newline "Outcome: " as res "`Y'" as text ". Running variable: " as res "`r'" as text "."

	di as text "{hline 18}{c TT}{hline 61}"
	di as text									_col(19) "{c |}"		_col(34) "Finite sample"				_col(60) "Large sample"
	di as text 									_col(19) "{c |}"		_col(33) "{hline 15}"		_col(50) "{hline 31}"
	di as text "{ralign 18:Statistic}{c |}" 		_col(20) "      T" 		_col(36) "  P>|T|"		_col(50) "  P>|T|" 		_col(60) "Power vs d = " as res %8.2f `delta'
	di as text "{hline 18}{c +}{hline 61}"
	
	if "`statistic'"!="all"{
	
		di as text "{ralign 18:`statdisp'}{c |}" 	_col(22) as res %9.3f `obs_stat'	_col(36) %7.3f `randp'	_col(51) as res %7.3f `asy_p'	_col(74) %7.3f `power'
		di as text "{hline 18}{c BT}{hline 61}"
		
		return scalar randpval = `randp'
		return scalar asy_pval = `asy_p'
		return scalar obs_stat = `obs_stat'
	}
	
	if "`statistic'"=="all"{
	
		di as text "{ralign 18:Diff. in means}{c |}" 		_col(22) as res %9.3f `obs_stat1'		_col(36) %7.3f aux1[1,1]	_col(51) as res %7.3f `asy_p1'	_col(74) %7.3f `power1'
		di as text "{ralign 18:Kolmogorov-Smirnov}{c |}" 	_col(22) as res %9.3f `obs_stat2'		_col(36) %7.3f aux1[1,2]	_col(51) as res %7.3f `asy_p2'	_col(74) %7.3f `power2'
		di as text "{ralign 18:Rank sum z-stat}{c |}" 		_col(22) as res %9.3f `obs_stat3'		_col(36) %7.3f aux1[1,3]	_col(51) as res %7.3f `asy_p3'	_col(74) %7.3f `power3'
		di as text "{hline 18}{c BT}{hline 61}"

		mat aux3 = (`asy_p1',`asy_p2',`asy_p3')
		
		return matrix p_val = aux1
		return matrix asy_pval = aux3
		return matrix obs_stat = aux2
	}
	
	if "`ci'"!=""{
		if "`fuzzy_stat'"!="tsls"{	
			di "Calculating confidence interval..."
			local wlength_r = `wr' - `cutoff'
			local wlength_l = `wl' - `cutoff'
			qui rdsensitivity `Y' `runvar', p(`p') wlist(`wlength_r') wlist_left(`wlength_l') `stat_opt_ci' `fuzzy_cond_ci' `tlist_opt' ci(`wlength_l' `wlength_r') ci_alpha(`ci_level') nodraw reps(`reps') 
			mat CI = r(CI)
			di as text _newline "Confidence interval for w = [" as res %9.3f `wl' _c as text " , " as res %9.3f `wr' as text "]" _newline
			di as text "{hline 18}{c TT}{hline 23}"
			di as text "{ralign 18:Statistic}{c |}" 		_col(16) "   [" (1-`ci_level')*100 "% Conf. Interval]"
			di as text "{hline 18}{c +}{hline 23}"
			di as text "{ralign 18:`statdisp'}{c |}" 		_col(22) as res %9.3f CI[1,1] _col(34) as res %9.3f CI[1,2]
			if rowsof(CI)>1{
				local jmax = rowsof(CI)
				forvalues j = 2/`jmax'{
					di as text _col(19) "{c |}" _col(22) as res %9.3f CI[`j',1] _col(34) as res %9.3f CI[`j',2]
				}
			}
			di as text "{hline 18}{c BT}{hline 23}"
		}
		else{
			di as text _newline "Confidence interval for selected window"
			di as text "{hline 18}{c TT}{hline 23}"
			di as text "{ralign 18:Statistic}{c |}" 		_col(16) "   [" (1-`ci_level')*100 "% Conf. Interval]"
			di as text "{hline 18}{c +}{hline 23}"
			di as text "{ralign 18:`statdisp'}{c |}" 		_col(22) as res %9.3f `ci_lb' _col(34) as res %9.3f `ci_ub'
			di as text "{hline 18}{c BT}{hline 23}"
			di "CI based on asymptotic approximation"   
			mat CI = (`ci_lb',`ci_ub')
		}

	}
	
	if `interfci'>0{
		di as text _newline "Confidence interval under interference"
		di as text "{hline 18}{c TT}{hline 23}"
		di as text "{ralign 18:Statistic}{c |}" 		_col(16) "   [" (1-`interfci')*100 "% Conf. Interval]"
		di as text "{hline 18}{c +}{hline 23}"
		di as text "{ralign 18:`statdisp'}{c |}" 		_col(22) as res %9.3f `obs_stat'-`k2' _col(34) as res %9.3f `obs_stat'-`k1'
		di as text "{hline 18}{c BT}{hline 23}"
		return scalar int_ub = `obs_stat'-`k1'
		return scalar int_lb = `obs_stat'-`k2'
	}

	
********************************************************************************
** Return values
********************************************************************************

	return local seed = `seed'
	return scalar p = `p'
	return scalar N_right = `n_right'
	return scalar N_left = `n_left'
	return scalar N = `n_left'+`n_right'
	return scalar wr = `wr'
	return scalar wl = `wl'
	
	if "`ci'"!=""{
		return matrix CI = CI
	}
	
end

