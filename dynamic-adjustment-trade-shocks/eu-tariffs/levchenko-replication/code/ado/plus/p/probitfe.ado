


*******************************************************************************
*type probitfe.ado
*! probitfe v3.0.3 mgonza 24Feb2017

*capture program drop probitfe
program probitfe, eclass byable(recall) sortpreserve
	version 11.2, missing
	local version : di "version " string(_caller()) ", missing:"
	local probitfe_cmd "probitfe"
	local cmdline "`probitfe_cmd' `*'"
	syntax varlist(min=2 fv ts) [if] [in] [,				/*
		*/ NOCorrection										/*
		*/ ANalytical										/*
		*/ 		LAGS(integer 0)								/*
		*/ JACKknife 										/*
		*/		SS1 										/*
		*/		SS2 										/*
		*/			MULtiple(integer 0) Individuals Time	/*
		*/ 		JS 											/*
		*/		SJ											/*
		*/		JJ											/*
		*/		DOUBLE										/*
		*/ IEFFECTS(string)									/*
		*/ TEFFECTS(string)									/*
		*/ IBIAS(string)									/*
		*/ TBIAS(string)									/*
		*/ POPulation(integer 0)]

	gettoken depvar indepvar : varlist
	_fv_check_depvar `depvar'

*******************************************************************************
*Validate ieffects, teffects, ibias and tbias options
	if "`ieffects'" != "" {
		local ans Y N
		local ansnames yes no
		local ans1 : list posof "`ieffects'" in ansnames
		
		if !`ans1' {
di as err "Error: -ieffects- must be chosen from -`ansnames'-."
			exit 198
		}
		
	}
	
	if "`teffects'" != "" {
		local ans Y N
		local ansnames yes no
		local ans1 : list posof "`teffects'" in ansnames
		
		if !`ans1' {
di as err "Error: -teffects- must be chosen from -`ansnames'-."
			exit 198
		}
		
	}

	if "`ibias'" != "" {
		local ans Y N
		local ansnames yes no
		local ans1 : list posof "`ibias'" in ansnames
		
		if !`ans1' {
di as err "Error: -ibias- must be chosen from -`ansnames'-."
			exit 198
		}
		
	}
	
	if "`tbias'" != "" {
		local ans Y N
		local ansnames yes no
		local ans1 : list posof "`tbias'" in ansnames
		
		if !`ans1' {
di as err "Error: -tbias- must be chosen from -`ansnames'-."
			exit 198
		}
		
	}

*******************************************************************************
*Fixed effects and bias corrections incompatibilities
	if "`ieffects'" == "no" & "`ibias'" == "yes" {
	
		if "`teffects'" != "no" {
di as err "Incompatible options: -ieffects(`ieffects')- and -ibias(`ibias')-."
			exit 198
		}
		
		if "`teffects'" == "no" {
		
			if "`tbias'" == "yes" {
di as err "Incompatible options: -ieffects(`ieffects'), ibias(`ibias'), teffects(`teffects') and tbias(`tbias')-."			
				exit 198
			}
			
			else {
di as err "Incompatible options: -ieffects(`ieffects')- and -ibias(`ibias')-."			
				exit 198
			}
		
		}
		
	}

	if "`teffects'" == "no" & "`tbias'" == "yes" {
	
		if "`ieffects'" != "no" {
di as err "Incompatible options: -teffects(`teffects')- and -tbias(`tbias')-."
			exit 198
		}
		
		if "`ieffects'" == "no" {
		
			if "`ibias'" == "yes" {
di as err "Incompatible options: -ieffects(`ieffects'), ibias(`ibias'), teffects(`teffects') and tbias(`tbias')-."			
				exit 198
			}
			
			else {
di as err "Incompatible options: -teffects(`teffects')- and -tbias(`tbias')-."			
				exit 198
			}
		
		}
		
	}
	
	if "`ieffects'" == "no" & "`teffects'" == "no" {
di as err "-ieffects(`ieffects') teffects(`teffects')- is an invalid option."			
				exit 198	
	}
	
*******************************************************************************
*Fixed effects and bias correction parameters
*******************************************************************************

	if ("`ieffects'" == "" | "`ieffects'" == "yes") {
		
		if "`teffects'" == "no" {
			local fe = 1
			local te = 0
			local tebias = 0
			
			if ("`ibias'" == "" | "`ibias'" == "yes") {
				local febias = 1
				local lags = `lags'
			}
			
			else {
				local febias = 0
				local lags = 0
			}
		}
		
		else {
			local fe = 1
			local te = 1
			
			if ("`ibias'" == "" | "`ibias'" == "yes") {
				local febias = 1
				local lags = `lags'
			}
			
			else {
				local febias = 0
				local lags = 0
			}
			
			if ("`tbias'" == "" | "`tbias'" == "yes") {
				local tebias = 1
			}
			
			else {
				local tebias = 0
			}		
		}
	}
		
	if ("`teffects'" == "" | "`teffects'" == "yes") {
		
		if "`ieffects'" == "no" {
			local fe = 0
			local te = 1
			local febias = 0
			local lags = 0
			
			if ("`tbias'" == "" | "`tbias'" == "yes") {
				local tebias = 1
			}
			
			else {
				local tebias = 0
			}
		}
		
		else {
			local fe = 1
			local te = 1
			
			if ("`ibias'" == "" | "`ibias'" == "yes") {
				local febias = 1
				local lags = `lags'
			}
			
			else {
				local febias = 0
				local lags = 0
			}
			
			if ("`tbias'" == "" | "`tbias'" == "yes") {
				local tebias = 1
			}
			
			else {
				local tebias = 0
			}
		}
	}
	
*******************************************************************************
*No correction incompatibilities
	if "`nocorrection'" != "" {
		local copts "`analytical'`jackknife'`ss1'`ss2'`individuals'`time'`js'`sj'`jj'`double'"
		
		if "`copts'" != "" {
			local copts "`analytical' `jackknife' `ss1' `ss2' `individuals' `time' `js' `sj' `jj' `double'"
			local copts : list retokenize copts
di as err "Incompatible options: -nocorrection- and -`copts'-."
			exit 198
		}
		
		if `lags' != 0 {
di as err "Incompatible options: -lags(`lags')- is an -analytical- option."
			exit 198
		}
		
		if `multiple' != 0 {
di as err "Incompatible options: -multiple(`multiple')- is a -jackknife ss1/ss2- option."
			exit 198
		}
		
		if "`ibias'" == "yes" & "`tbias'" != "yes" {
di as err "Incompatible options: -nocorrection- and -ibias(`ibias')-."
			exit 198
		}
		
		if "`tbias'" == "yes" & "`ibias'" != "yes"{
di as err "Incompatible options: -nocorrection- and -tbias(`tbias')-."
			exit 198
		}
		
		if "`ibias'" == "yes" & "`tbias'" == "yes"{
di as err "Incompatible options: -nocorrection- and -ibias(`ibias') tbias(`tbias')-."
			exit 198
		}
		
	}

*******************************************************************************
*Validate analytical option
	if "`analytical'" != "" | ("`nocorrection'" == "" & "`analytical'" == "" & "`jackknife'" == "") {
		local copts "`ss1'`ss2'`individuals'`time'`js'`sj'`jj'`double'"
		
		if "`copts'" != "" {
			local copts "`ss1' `ss2' `individuals' `time' `js' `sj' `jj' `double'"
			local copts : list retokenize copts
di as err "Incompatible options: -analytical (the default)- and -`copts'-."
			exit 198
		}
		
		if "`ibias'" == "no" & "`tbias'" == "no" {
di as err "Incompatible options: -analytical (the default)- and -ibias(`ibias') tbias(`tbias')-."
di as err "Use the -nocorrection- option instead"
			exit 198			
		}
		
		if `multiple' != 0 {
di as err "Incompatible options: -multiple(`multiple')- is a -jackknife ss1/ss2- option."
			exit 198
		}
		
		if `lags' < 0 {

di as err "Invalid option: number of lags must be higher or equal than 0"
			exit 198
		}
		
	}
		
*******************************************************************************
*Validate spjackknife option
	if "`jackknife'" != "" {
		local copts "`analytical'"
		
		if "`copts'" != "" {
			local copts "`analytical'"
			local copts : list retokenize copts
di as err "Incompatible options: -jackknife- and -`copts'-."
			exit 198
		}
		
		if `lags' != 0 {
di as err "Incompatible options: -lags(`lags')- is an -analytical- option."
			exit 198
		}
		
		if "`ibias'" == "no" & "`tbias'" == "no" {
di as err "Incompatible options: -jackknife- and -ibias(`ibias') tbias(`tbias')-."
di as err "Use the -nocorrection- option instead"
			exit 198			
		}
		
		if "`ss1'" != "" {
			local copts "`ss2'`js'`sj'`jj'`double'"
			
			if "`copts'" != "" {
				local copts "`ss2' `js' `sj' `jj' `double'"
				local copts : list retokenize copts
di as err "Incompatible options: -ss1- and -`copts'-."
			exit 198
			}
			
			if `multiple' < 0 {

di as err "Invalid multiple option"
			exit 198
			}
			
			if `multiple' > 0 {
			capt mata mata which mm_sample()
			
				if _rc {
di as error "mm_panels() from -moremata- is required; type -ssc install moremata- to obtain it"
					exit 499
				}
				
			}
			
		}
		
		if "`ss2'" != "" {
			local copts "`ss1'`js'`sj'`jj'`double'"
			
			if "`copts'" != "" {
				local copts "`ss1' `js' `sj' `jj' `double'"
				local copts : list retokenize copts
di as err "Incompatible options: -ss2- and -`copts'-."
				exit 198
			}
			
			if `multiple' < 0 {
di as err "Invalid multiple option"
				exit 198
			}
			
			if `multiple' > 0 {
			capt mata mata which mm_sample()
			
				if _rc {
di as error "mm_panels() from -moremata- is required; type -ssc install moremata- to obtain it"
					exit 499
				}
				
			}
			
		}
		
		if "`js'" != "" {
			local copts "`ss1'`ss2'`individuals'`time'`sj'`jj'`double'"
			
			if "`copts'" != "" {
				local copts "`ss1' `ss2' `individuals' `time' `sj' `jj' `double'"
				local copts : list retokenize copts
di as err "Incompatible options: -js1- and -`copts'-."
			exit 198
			}
			
			if `multiple' != 0 {
di as err "Incompatible options: -multiple(`multiple')- is a -jackknife ss1/ss2- option."
			exit 198
			}
			
		}
		
		if "`sj'" != "" {
			local copts "`ss1'`ss2'`individuals'`time'`js'`jj'`double'"
			
			if "`copts'" != "" {
				local copts "`ss1' `ss2' `individuals' `time' `js' `jj' `double'"
				local copts : list retokenize copts
di as err "Incompatible options: -js1- and -`copts'-."
			exit 198
			}
			
			if `multiple' != 0 {
di as err "Incompatible options: -multiple(`multiple')- is a -jackknife ss1/ss2- option."
			exit 198
			}
			
		}
		
		if "`jj'" != "" {
			local copts "`ss1'`ss2'`individuals'`time'`js'`sj'`double'"
			
			if "`copts'" != "" {
				local copts "`ss1' `ss2' `individuals' `time' `js' `sj' `double'"
				local copts : list retokenize copts
di as err "Incompatible options: -js2- and -`copts'-."
			exit 198
			}
			
			if `multiple' != 0 {
di as err "Incompatible options: -multiple(`multiple')- is a -jackknife ss1/ss2- option."
			exit 198
			}
			
		}
		
		if "`double'" != "" {
			local copts "`ss1'`ss2'`individuals'`time'`js'`sj'`jj'"
			
			if "`copts'" != "" {
				local copts "`ss1' `ss2' `individuals' `time' `js' `sj' `jj'"
				local copts : list retokenize copts
di as err "Incompatible options: -double- and -`copts'-."
			exit 198
			}
			
			if `multiple' != 0 {
di as err "Incompatible options: -multiple(`multiple')- is a -jackknife ss1/ss2- option."
			exit 198
			}
			
		}
		
	}

*******************************************************************************
*Validate data are tsset
	
	capture tsset
	local pvar "`r(panelvar)'"
	local tvar "`r(timevar)'"

	if "`pvar'" == "" & "`tvar'" != ""{
di as err "Error: must -tsset- data and specify panelvar"
		exit 5
	}

	if "`tvar'" == "" & "`pvar'" != ""{
di as err "Error: must -tsset- data and specify timevar"
		exit 5
	}
	
	if "`pvar'" == "" & "`tvar'" == ""{
di as err "Error: must -tsset- data and specify panelvar and timevar"
		exit 5
	}

*******************************************************************************
*Estimation sample
	
	marksample touse
	markout `touse' `pvar' `tvar' `depvar' `indepvar', strok
	tsreport if `touse', panel
	
	if `r(N_gaps)' != 0 {
display in gr "Warning: time variable " in ye "`tvar'" in gr " has " /*
     */ in ye "`r(N_gaps)'" in gr " gap(s) in relevant range"
	}
	
*******************************************************************************
*Validate (binary) depvar

	quietly tabulate `depvar' if `touse'
	
	if r(r) != 2 {
		display as error "Error: `depvar' is not a 0/1 variable"
		exit 198
	}
	
	quietly summarize `depvar' if `touse'
	
	if (r(min)!=0 & r(max)!=1) {
		display as error "Error: `depvar' is not a 0/1 variable"
		exit 198
	}
	
*******************************************************************************
*Check for collinearities

	local fvops = "`s(fvops)'" == "true" | _caller() >= 11
	if `fvops' {
		local rmcoll "version 11: _rmcoll"
		local fvexp expand
	}
	
	else {
		local rmcoll _rmcoll
	}
	
	di
	di in ye "Computing uncorrected fixed effects estimator"
	`rmcoll' `varlist' if `touse', `fvexp' probit touse(`touse')
	tempvar tousesample
	qui gen byte `tousesample' = `touse'
	local varlist1 `"`r(varlist)'"'
	gettoken depvar indepvar : varlist1
	
*******************************************************************************
*Identifying individuals with all 0's or all 1's in depvar
*Identifying indepvars in which outcome does not vary
*******************************************************************************

	cap noi CheckGroups `touse' `pvar' `tvar' `depvar' `indepvar', teffects(`teffects') ieffects(`ieffects')
	local 		indepvar 	`e(varlist)'
	local 		n 			`e(n)'
	local 		ng 			`e(ng)'
	local		nt			`e(nt)'
	local 		n_orig 		`e(n_orig)'
	local 		ng_orig 	`e(ng_orig)'
	local		nt_orig		`e(nt_orig)'
	cap local 	n_drop 		`e(n_drop)'
	cap local 	ng_drop 	`e(ng_drop)'
	cap local 	nt_drop 	`e(nt_drop)'
	
*******************************************************************************
* Validate Finite population correction parameter
*******************************************************************************

	if `population' != 0 {
		
		if `population' < 0 {
di as err "Invalid population option: population must be a finite positive integer"
			exit 198
		}
		
		if `population' < `n_orig' {
di as err "Invalid population option: population must be a finite positive integer"
di as err "        higher or equal than the number of original observations (`n_orig')."
			exit 198
		}
		
	}
	
	if `population' == 0 {
		local fpc = 1
	}
	
	else {
		local fpc = (`population' - `n')/(`population' - 1)
	}

*******************************************************************************
* Validate double option
*******************************************************************************

	if "`double'" != "" {
		tempvar sumi indexdouble
		mata: checkdouble(	"`pvar'",			/*
			*/				"`tvar'",			/*
			*/				"`tousesample'"	)
		mat `indexdouble'	= r(index)
		scalar `sumi'		= r(sum)
		local Jdouble		= rowsof(`indexdouble')
		
		if `sumi' == 0 {
			di as err "Invalid -double- option: no observations with the same index for `pvar' and `tvar'"
			exit 198
		}
	}

*******************************************************************************
*Estimation Block
*******************************************************************************

	tempvar b V bapes Vapes
	tempname k df_m r2_p chi2 p rankV rankV2 N_drop N_group_drop N_group
	tempname T_min T_max T_avg ll ll_0
	local depname `depvar'
	local indepnames "`indepvar'"

*******************************************************************************
*Uncorrected Logit Model (Necessary for any option)
*******************************************************************************
	
	tempvar grouppvar grouptvar
	qui egen `grouppvar' = group(`pvar') if `touse'
	qui egen `grouptvar' = group(`tvar') if `touse'
	
	mata: probit(	"`depvar'",		/*
		*/			"`indepvar'",	/*
		*/			"`grouppvar'",	/*
		*/			"`grouptvar'",	/*
		*/			`n_orig',		/*
		*/			`fe',			/*
		*/			`te',			/*
		*/			`fpc',			/*
		*/			"`touse'"		)
		
	mat `V'			= r(V)
	mat `Vapes'		= r(Vmfx)
	scalar `k'		= r(k)
	scalar `df_m'	= r(df_m)
	scalar `ll'		= r(ll)
	scalar `rankV'	= r(rank)
	scalar `T_min'	= r(T_min)
	scalar `T_max'	= r(T_max)
	scalar `T_avg'	= r(T_avg)
	
*******************************************************************************
*Without correction
*******************************************************************************

	if "`nocorrection'" != "" {
		mat `b'			= r(b)
		mat `bapes'		= r(bmfx)
	}
		
*******************************************************************************
*Analytical correction
*******************************************************************************

	if "`analytical'" != ""  | ("`nocorrection'" == "" & "`analytical'" == "" & "`jackknife'" == "") {
	
		if `lags' > 0 {
		
			if `T_min' - 1 < `lags' {
				di
				di in gr "Maximum possible lags for at least one group within" in ye " `pvar' " in gr "are (" `T_min' - 1 ")."
				di in red "Number of lags (`lags') exceeds maximum possible lags."
				exit 198
			}
			
		}
		
		di
		di in ye "Computing analytical correction"
		
		tempvar betafe allobs
		tempname NT
		mat `betafe'	= r(beta)
		qui g `allobs' 	= _n
		scalar `NT' 	= _N
		
		if `lags' > 0 {
			
			forvalues i = 1(1)`lags' {
				tempvar l`i'touse touse`i'
				qui g `l`i'touse' = L`i'.`touse'
				qui g byte `touse`i'' = `touse' == 1 & `l`i'touse' == 1
				qui drop `l`i'touse'
				local lagstouse `lagstouse' `touse`i''
			}
			
		}
		
		else {
			local lagstouse
		}
		
		mata: analytical(		"`depvar'",			/*
		*/						"`indepvar'",		/*
		*/						"`grouppvar'",		/*
		*/						"`grouptvar'",		/*
		*/						"`allobs'",			/*
		*/						"`lagstouse'",		/*
		*/						"`betafe'",			/*
		*/						`lags',				/*
		*/						"`NT'",				/*
		*/						`n_orig',			/*
		*/						`fe',				/*
		*/						`te',				/*
		*/						`febias',			/*
		*/						`tebias',			/*
		*/						"`touse'")
		
		mat `b'     = r(b)
		mat `bapes' = r(bmfx)
	}

*******************************************************************************
*Split Jackknife in 4 subpanels
*******************************************************************************

	if "`jackknife'" != "" {
		tempvar bfe bfemfx
		mat `bfe'		= r(b)
		mat `bfemfx'	= r(bmfx)
		
		if "`ss1'" != "" {
			tempvar betas betasmfx
			
			if `febias' == 1 & `tebias' == 0 {
			
				if `multiple' == 0 | (`multiple' != 0 & "`individuals'" != "" & "`time'" == "") {
				
					if `multiple' != 0 & "`individuals'" != "" & "`time'" == "" {
						di
						di in ye "note:" in gr " multiple partitions only in the cross-section without"
						di in gr "correction for time fixed-effects delivers the same"
						di in gr "estimator wihtout multiple partitions."
						local multiple = 0
					}
					
					mat `betas'		= J(2, `k', .)
					mat `betasmfx'	= J(2, `k', .)
					tempvar touse1 touse2 grouppvar grouptvar
					qui gen byte `touse1' = `tousesample'
					qui gen byte `touse2' = `tousesample'
					qui egen `grouppvar' = group(`pvar') if `tousesample'
					qui egen `grouptvar' = group(`tvar') if `tousesample'
					cap noi sstousei `tousesample' `touse1' `touse2' `grouppvar' `grouptvar'
					local varlist2 `touse1' `touse2'
					
					foreach v of local varlist2 {
						local i : list posof `"`v'"' in varlist2
						qui `rmcoll' `varlist' if `v', `fvexp' probit touse(`v')
						local varlisttemp `"`r(varlist)'"'
						local singular : list varlist1 - varlisttemp
						di
						di in ye "Computing fixed-effects estimator in subpanel `i' of 2"
				
						if "`singular'" != "" {
							di in gr "Warning: collinear variable(s) not in the original sample detected"
							di in gr "Collinear variables: " in ye "`singular'"
						}
				
						cap qui CheckGroups `v' `pvar' `tvar' `varlisttemp', teffects(`teffects') ieffects(`ieffects')
						local 		indepvar2 		`e(varlist)'
						local 		ntemp 			`e(n)'
						local 		ngtemp 			`e(ng)'
						local 		n_origtemp 		`e(n_orig)'
						local 		ng_origtemp 	`e(ng_orig)'
						
						mata: probit_no_sd(	"`depvar'",			/*
							*/				"`indepvar2'",		/*
							*/				"`pvar'",			/*
							*/				"`tvar'",			/*
							*/				`n_origtemp',		/*
							*/				`fe',				/*
							*/				`te',				/*
							*/				"`v'"	)

						mat `betas'   [`i',1]	= r(b)
						mat `betasmfx'[`i',1]	= r(bmfx)
					}
				}
				
				else {
					mat `betas'    = J(`multiple', `k' , .)
					mat `betasmfx' = J(`multiple', `k' , .)
					set seed 13579
				
					forvalues j = 1/`multiple' {
						di
						di in ye "Computing fixed-effects estimator in multiple partition `j' of `multiple'"
						tempvar touse1 touse2 btemp bmfxtemp
						mat `btemp'		= J(2, `k', .)
						mat `bmfxtemp'	= J(2, `k', .)
						
						if "`individuals'" == "" & "`time'" != "" {
							qui sort `tvar'
							qui mata: multipletvar("`tvar'")
							qui egen pvar2 = group(`pvar')
						}
						
						else {
							qui sort `pvar'
							qui mata: multiplepvar("`pvar'")
							qui sort `tvar'
							qui mata: multipletvar("`tvar'")
						}
					
						qui gen byte `touse1' = `tousesample'
						qui gen byte `touse2' = `tousesample'
						cap noi sstousei `tousesample' `touse1' `touse2' pvar2 tvar2
						local varlist2 `touse1' `touse2'
					
						foreach v of local varlist2 {
							local i : list posof `"`v'"' in varlist2
							qui `rmcoll' `varlist' if `v', `fvexp' probit touse(`v')
							local varlisttemp `"`r(varlist)'"'
				
							cap qui CheckGroups `v' pvar2 tvar2 `varlisttemp', teffects(`teffects') ieffects(`ieffects')
							local 		indepvar2 		`e(varlist)'
							local 		ntemp 			`e(n)'
							local 		ngtemp 			`e(ng)'
							local 		n_origtemp 		`e(n_orig)'
							local 		ng_origtemp 	`e(ng_orig)'
						
							qui mata: probit_no_sd(	"`depvar'",			/*
									*/				"`indepvar2'",		/*
									*/				"pvar2",			/*
									*/				"tvar2",			/*
									*/				`n_origtemp',		/*
									*/				`fe',				/*
									*/				`te',				/*
									*/				"`v'"				)

							mat `btemp'[`i',1]	= r(b)
							mat `bmfxtemp'[`i',1]	= r(bmfx)
						}
					
						mata: betas_ss1("`bfe'",		/*
						*/				"`bfemfx'",		/*
						*/				"`btemp'",		/*
						*/				"`bmfxtemp'",	/*
						*/				0				)
					
						mat `betas'[`j', 1]		= r(b)
						mat `betasmfx'[`j', 1]	= r(bmfx)
						mat drop `btemp' `bmfxtemp'
						qui drop `touse1' `touse2' pvar2 tvar2
					}
				
				}
				
			}
				
			else if `febias' == 0 & `tebias' == 1 {
			
				if `multiple' == 0 | (`multiple' != 0 & "`individuals'" == "" & "`time'" != "") {
				
					if `multiple' != 0 & "`individuals'" == "" & "`time'" != "" {
						di
						di in ye "note:" in gr " multiple partitions only in the time-dimension without"
						di in gr "correction for individual fixed-effects delivers the same"
						di in gr "estimator wihtout multiple partitions."
						local multiple = 0
					}
				
					mat `betas'		= J(2, `k', .)
					mat `betasmfx'	= J(2, `k', .)
					tempvar touse1 touse2 grouppvar grouptvar
					qui gen byte `touse1' = `tousesample'
					qui gen byte `touse2' = `tousesample'
					qui egen `grouppvar' = group(`pvar') if `tousesample'
					qui egen `grouptvar' = group(`tvar') if `tousesample'
					cap noi sstouset `tousesample' `touse1' `touse2' `grouppvar' `grouptvar'
					local varlist2 `touse1' `touse2'
					
					foreach v of local varlist2 {
						local i : list posof `"`v'"' in varlist2
						qui `rmcoll' `varlist' if `v', `fvexp' probit touse(`v')
						local varlisttemp `"`r(varlist)'"'
						local singular : list varlist1 - varlisttemp
						di
						di in ye "Computing fixed-effects estimator in subpanel `i' of 2"
				
						if "`singular'" != "" {
							di in gr "Warning: collinear variable(s) not in the original sample detected"
							di in gr "Collinear variables: " in ye "`singular'"
						}
				
						cap qui CheckGroups `v' `pvar' `tvar' `varlisttemp', teffects(`teffects') ieffects(`ieffects')
						local 		indepvar2 		`e(varlist)'
						local 		ntemp 			`e(n)'
						local 		ngtemp 			`e(ng)'
						local 		n_origtemp 		`e(n_orig)'
						local 		ng_origtemp 	`e(ng_orig)'
						
						mata: probit_no_sd(	"`depvar'",			/*
							*/				"`indepvar2'",		/*
							*/				"`pvar'",			/*
							*/				"`tvar'",			/*
							*/				`n_origtemp',		/*
							*/				`fe',				/*
							*/				`te',				/*
							*/				"`v'"	)

						mat `betas'   [`i',1]	= r(b)
						mat `betasmfx'[`i',1]	= r(bmfx)
					}
				}
				
				else {
					mat `betas'    = J(`multiple', `k' , .)
					mat `betasmfx' = J(`multiple', `k' , .)
					set seed 13579
				
					forvalues j = 1/`multiple' {
						di
						di in ye "Computing fixed-effects estimator in multiple partition `j' of `multiple'"	
						tempvar touse1 touse2 btemp bmfxtemp
						mat `btemp'		= J(2, `k', .)
						mat `bmfxtemp'	= J(2, `k', .)
						
						if "`individuals'" != "" & "`time'" == "" {
							qui sort `pvar'
							qui mata: multiplepvar("`pvar'")
							qui egen tvar2 = group(`tvar')
						}
						
						else {
							qui sort `pvar'
							qui mata: multiplepvar("`pvar'")
							qui sort `tvar'
							qui mata: multipletvar("`tvar'")
						}
					
						qui gen byte `touse1' = `tousesample'
						qui gen byte `touse2' = `tousesample'
						cap noi sstouset `tousesample' `touse1' `touse2' pvar2 tvar2
						local varlist2 `touse1' `touse2'
					
						foreach v of local varlist2 {
							local i : list posof `"`v'"' in varlist2
							qui `rmcoll' `varlist' if `v', `fvexp' probit touse(`v')
							local varlisttemp `"`r(varlist)'"'
				
							cap qui CheckGroups `v' pvar2 tvar2 `varlisttemp', teffects(`teffects') ieffects(`ieffects')
							local 		indepvar2 		`e(varlist)'
							local 		ntemp 			`e(n)'
							local 		ngtemp 			`e(ng)'
							local 		n_origtemp 		`e(n_orig)'
							local 		ng_origtemp 	`e(ng_orig)'
						
							qui mata: probit_no_sd(	"`depvar'",			/*
									*/				"`indepvar2'",		/*
									*/				"pvar2",			/*
									*/				"tvar2",			/*
									*/				`n_origtemp',		/*
									*/				`fe',				/*
									*/				`te',				/*
									*/				"`v'"				)

							mat `btemp'[`i',1]	= r(b)
							mat `bmfxtemp'[`i',1]	= r(bmfx)
						}
					
						mata: betas_ss1("`bfe'",		/*
						*/				"`bfemfx'",		/*
						*/				"`btemp'",		/*
						*/				"`bmfxtemp'",	/*
						*/				0				)
					
						mat `betas'[`j', 1]		= r(b)
						mat `betasmfx'[`j', 1]	= r(bmfx)
						mat drop `btemp' `bmfxtemp'
						qui drop `touse1' `touse2' pvar2 tvar2
					}
				}
			}
				
			else {
			
				if `multiple' == 0 {
					mat `betas'		= J(4, `k', .)
					mat `betasmfx'	= J(4, `k', .)
					tempvar touse1 touse2 touse3 touse4 grouppvar grouptvar
					qui gen byte `touse1' = `tousesample'
					qui gen byte `touse2' = `tousesample'
					qui gen byte `touse3' = `tousesample'
					qui gen byte `touse4' = `tousesample'
					qui egen `grouppvar' = group(`pvar') if `tousesample'
					qui egen `grouptvar' = group(`tvar') if `tousesample'
					cap noi ss1touse `tousesample' `touse1' `touse2' `touse3' `touse4' `grouppvar' `grouptvar'
					local varlist2 `touse1' `touse2' `touse3' `touse4'
					
					foreach v of local varlist2 {
						local i : list posof `"`v'"' in varlist2
						qui `rmcoll' `varlist' if `v', `fvexp' probit touse(`v')
						local varlisttemp `"`r(varlist)'"'
						local singular : list varlist1 - varlisttemp
						di
						di in ye "Computing fixed-effects estimator in subpanel `i' of 4"
				
						if "`singular'" != "" {
							di in gr "Warning: collinear variable(s) not in the original sample detected"
							di in gr "Collinear variables: " in ye "`singular'"
						}
				
						cap qui CheckGroups `v' `pvar' `tvar' `varlisttemp', teffects(`teffects') ieffects(`ieffects')
						local 		indepvar2 		`e(varlist)'
						local 		ntemp 			`e(n)'
						local 		ngtemp 			`e(ng)'
						local 		n_origtemp 		`e(n_orig)'
						local 		ng_origtemp 	`e(ng_orig)'
						
						mata: probit_no_sd(	"`depvar'",			/*
							*/				"`indepvar2'",		/*
							*/				"`pvar'",			/*
							*/				"`tvar'",			/*
							*/				`n_origtemp',		/*
							*/				`fe',				/*
							*/				`te',				/*
							*/				"`v'"				)

						mat `betas'[`i',1]	= r(b)
						mat `betasmfx'[`i',1]	= r(bmfx)
					}
				
				}
				
				else {
					mat `betas'    = J(`multiple', `k' , .)
					mat `betasmfx' = J(`multiple', `k' , .)
					set seed 13579
				
					forvalues j = 1/`multiple' {
						di
						di in ye "Computing fixed-effects estimator in multiple partition `j' of `multiple'"
					
						tempvar touse1 touse2 touse3 touse4 btemp bmfxtemp
						mat `btemp'		= J(4, `k', .)
						mat `bmfxtemp'	= J(4, `k', .)
						
						if "`individuals'" != "" & "`time'" == "" {
							qui sort `pvar'
							qui mata: multiplepvar("`pvar'")
							qui egen tvar2 = group(`tvar')
						}
						
						else if "`individuals'" == "" & "`time'" != "" {
							qui sort `tvar'
							qui mata: multipletvar("`tvar'")
							qui egen pvar2 = group(`pvar')
						}
						
						else {
							qui sort `pvar'
							qui mata: multiplepvar("`pvar'")
							qui sort `tvar'
							qui mata: multipletvar("`tvar'")
						}
					
						qui gen byte `touse1' = `tousesample'
						qui gen byte `touse2' = `tousesample'
						qui gen byte `touse3' = `tousesample'
						qui gen byte `touse4' = `tousesample'
						cap noi ss1touse `tousesample' `touse1' `touse2' `touse3' `touse4' pvar2 tvar2
						local varlist2 `touse1' `touse2' `touse3' `touse4'
					
						foreach v of local varlist2 {
							local i : list posof `"`v'"' in varlist2
							qui `rmcoll' `varlist' if `v', `fvexp' probit touse(`v')
							local varlisttemp `"`r(varlist)'"'
				
							cap qui CheckGroups `v' pvar2 tvar2 `varlisttemp', teffects(`teffects') ieffects(`ieffects')
							local 		indepvar2 		`e(varlist)'
							local 		ntemp 			`e(n)'
							local 		ngtemp 			`e(ng)'
							local 		n_origtemp 		`e(n_orig)'
							local 		ng_origtemp 	`e(ng_orig)'
						
							qui mata: probit_no_sd(	"`depvar'",			/*
									*/				"`indepvar2'",		/*
									*/				"pvar2",			/*
									*/				"tvar2",			/*
									*/				`n_origtemp',		/*
									*/				`fe',				/*
									*/				`te',				/*
									*/				"`v'"				)

							mat `btemp'[`i',1]	= r(b)
							mat `bmfxtemp'[`i',1]	= r(bmfx)
						}
					
						mata: betas_ss1("`bfe'",		/*
						*/				"`bfemfx'",		/*
						*/				"`btemp'",		/*
						*/				"`bmfxtemp'",	/*
						*/				0				)
					
						mat `betas'[`j', 1]		= r(b)
						mat `betasmfx'[`j', 1]	= r(bmfx)
						mat drop `btemp' `bmfxtemp'
						qui drop `touse1' `touse2' pvar2 tvar2
					}
				}
			}
			
			mata: betas_ss1(	"`bfe'",		/*
				*/				"`bfemfx'",		/*
				*/				"`betas'",		/*
				*/				"`betasmfx'",	/*
				*/				`multiple'		)
				
			mat `b'		= r(b)
			mat `bapes'	= r(bmfx)
		}

*******************************************************************************
*Split Jackknife in both dimensions: half panel out and either all T or all N
*******************************************************************************

		if "`ss2'" != "" | ("`ss1'" == "" & "`ss2'" == "" & "`js'" == "" & "`sj'" == "" & "`jj'" == "" & "`double'" == "") {
			tempvar betas betasmfx
			
			if `febias' == 1 & `tebias' == 0 {
			
				if `multiple' == 0 | (`multiple' != 0 & "`individuals'" != "" & "`time'" == "") {
				
					if `multiple' != 0 & "`individuals'" != "" & "`time'" == "" {
						di
						di in ye "note:" in gr " multiple partitions only in the cross-section without"
						di in gr "correction for time fixed-effects delivers the same"
						di in gr "estimator wihtout multiple partitions."
						local multiple = 0
					}
				
					mat `betas'		= J(2, `k', .)
					mat `betasmfx'	= J(2, `k', .)
					tempvar touse1 touse2 grouppvar grouptvar
					qui gen byte `touse1' = `tousesample'
					qui gen byte `touse2' = `tousesample'
					qui egen `grouppvar' = group(`pvar') if `tousesample'
					qui egen `grouptvar' = group(`tvar') if `tousesample'
					cap noi sstousei `tousesample' `touse1' `touse2' `grouppvar' `grouptvar'
					local varlist2 `touse1' `touse2'
					
					foreach v of local varlist2 {
						local i : list posof `"`v'"' in varlist2
						qui `rmcoll' `varlist' if `v', `fvexp' probit touse(`v')
						local varlisttemp `"`r(varlist)'"'
						local singular : list varlist1 - varlisttemp
						di
						di in ye "Computing fixed-effects estimator in subpanel `i' of 2"
				
						if "`singular'" != "" {
							di in gr "Warning: collinear variable(s) not in the original sample detected"
							di in gr "Collinear variables: " in ye "`singular'"
						}
				
						cap qui CheckGroups `v' `pvar' `tvar' `varlisttemp', teffects(`teffects') ieffects(`ieffects')
						local 		indepvar2 		`e(varlist)'
						local 		ntemp 			`e(n)'
						local 		ngtemp 			`e(ng)'
						local 		n_origtemp 		`e(n_orig)'
						local 		ng_origtemp 	`e(ng_orig)'
						
						mata: logit_no_sd(	"`depvar'",			/*
							*/				"`indepvar2'",		/*
							*/				"`pvar'",			/*
							*/				"`tvar'",			/*
							*/				`n_origtemp',		/*
							*/				`fe',				/*
							*/				`te',				/*
							*/				"`v'"	)

						mat `betas'   [`i',1]	= r(b)
						mat `betasmfx'[`i',1]	= r(bmfx)
					}
				}
				
				else {
					mat `betas'    = J(`multiple', `k' , .)
					mat `betasmfx' = J(`multiple', `k' , .)
					set seed 13579
				
					forvalues j = 1/`multiple' {
						di
						di in ye "Computing fixed-effects estimator in multiple partition `j' of `multiple'"
						tempvar touse1 touse2 btemp bmfxtemp
						mat `btemp'		= J(2, `k', .)
						mat `bmfxtemp'	= J(2, `k', .)
						
						if "`individuals'" == "" & "`time'" != "" {
							qui sort `tvar'
							qui mata: multipletvar("`tvar'")
							qui egen pvar2 = group(`pvar')
						}
						
						else {
							qui sort `pvar'
							qui mata: multiplepvar("`pvar'")
							qui sort `tvar'
							qui mata: multipletvar("`tvar'")
						}
					
						qui gen byte `touse1' = `tousesample'
						qui gen byte `touse2' = `tousesample'
						cap noi sstousei `tousesample' `touse1' `touse2' pvar2 tvar2
						local varlist2 `touse1' `touse2'
					
						foreach v of local varlist2 {
							local i : list posof `"`v'"' in varlist2
							qui `rmcoll' `varlist' if `v', `fvexp' probit touse(`v')
							local varlisttemp `"`r(varlist)'"'
				
							cap qui CheckGroups `v' pvar2 tvar2 `varlisttemp', teffects(`teffects') ieffects(`ieffects')
							local 		indepvar2 		`e(varlist)'
							local 		ntemp 			`e(n)'
							local 		ngtemp 			`e(ng)'
							local 		n_origtemp 		`e(n_orig)'
							local 		ng_origtemp 	`e(ng_orig)'
						
							qui mata: probit_no_sd(	"`depvar'",			/*
									*/				"`indepvar2'",		/*
									*/				"pvar2",			/*
									*/				"tvar2",			/*
									*/				`n_origtemp',		/*
									*/				`fe',				/*
									*/				`te',				/*
									*/				"`v'"				)

							mat `btemp'[`i',1]	= r(b)
							mat `bmfxtemp'[`i',1]	= r(bmfx)
						}
					
						mata: betas_ss1("`bfe'",		/*
						*/				"`bfemfx'",		/*
						*/				"`btemp'",		/*
						*/				"`bmfxtemp'",	/*
						*/				0				)
					
						mat `betas'[`j', 1]		= r(b)
						mat `betasmfx'[`j', 1]	= r(bmfx)
						mat drop `btemp' `bmfxtemp'
						qui drop `touse1' `touse2' pvar2 tvar2
					}
				}
			}
				
			else if `febias' == 0 & `tebias' == 1 {
			
				if `multiple' == 0 | (`multiple' != 0 & "`individuals'" == "" & "`time'" != "") {
				
					if `multiple' != 0 & "`individuals'" == "" & "`time'" != "" {
						di
						di in ye "note:" in gr " multiple partitions only in the time-dimension without"
						di in gr "correction for individual fixed-effects delivers the same"
						di in gr "estimator wihtout multiple partitions."
						local multiple = 0
					}
				
					mat `betas'		= J(2, `k', .)
					mat `betasmfx'	= J(2, `k', .)
					tempvar touse1 touse2 grouppvar grouptvar
					qui gen byte `touse1' = `tousesample'
					qui gen byte `touse2' = `tousesample'
					qui egen `grouppvar' = group(`pvar') if `tousesample'
					qui egen `grouptvar' = group(`tvar') if `tousesample'
					cap noi sstouset `tousesample' `touse1' `touse2' `grouppvar' `grouptvar'
					local varlist2 `touse1' `touse2'
					
					foreach v of local varlist2 {
						local i : list posof `"`v'"' in varlist2
						qui `rmcoll' `varlist' if `v', `fvexp' probit touse(`v')
						local varlisttemp `"`r(varlist)'"'
						local singular : list varlist1 - varlisttemp
						di
						di in ye "Computing fixed-effects estimator in subpanel `i' of 2"
				
						if "`singular'" != "" {
							di in gr "Warning: collinear variable(s) not in the original sample detected"
							di in gr "Collinear variables: " in ye "`singular'"
						}
				
						cap qui CheckGroups `v' `pvar' `tvar' `varlisttemp', teffects(`teffects') ieffects(`ieffects')
						local 		indepvar2 		`e(varlist)'
						local 		ntemp 			`e(n)'
						local 		ngtemp 			`e(ng)'
						local 		n_origtemp 		`e(n_orig)'
						local 		ng_origtemp 	`e(ng_orig)'
						
						mata: probit_no_sd(	"`depvar'",			/*
							*/				"`indepvar2'",		/*
							*/				"`pvar'",			/*
							*/				"`tvar'",			/*
							*/				`n_origtemp',		/*
							*/				`fe',				/*
							*/				`te',				/*
							*/				"`v'"	)

						mat `betas'   [`i',1]	= r(b)
						mat `betasmfx'[`i',1]	= r(bmfx)
					}
				}
				
				else {
					mat `betas'    = J(`multiple', `k' , .)
					mat `betasmfx' = J(`multiple', `k' , .)
					set seed 13579
				
					forvalues j = 1/`multiple' {
						di
						di in ye "Computing fixed-effects estimator in multiple partition `j' of `multiple'"
						tempvar touse1 touse2 btemp bmfxtemp
						mat `btemp'		= J(2, `k', .)
						mat `bmfxtemp'	= J(2, `k', .)
						
						if "`individuals'" != "" & "`time'" == "" {
							qui sort `pvar'
							qui mata: multiplepvar("`pvar'")
							qui egen tvar2 = group(`tvar')
						}
						
						else {
							qui sort `pvar'
							qui mata: multiplepvar("`pvar'")
							qui sort `tvar'
							qui mata: multipletvar("`tvar'")
						}
					
						qui gen byte `touse1' = `tousesample'
						qui gen byte `touse2' = `tousesample'
						cap noi sstouset `tousesample' `touse1' `touse2' pvar2 tvar2
						local varlist2 `touse1' `touse2'
					
						foreach v of local varlist2 {
							local i : list posof `"`v'"' in varlist2
							qui `rmcoll' `varlist' if `v', `fvexp' probit touse(`v')
							local varlisttemp `"`r(varlist)'"'
				
							cap qui CheckGroups `v' pvar2 tvar2 `varlisttemp', teffects(`teffects') ieffects(`ieffects')
							local 		indepvar2 		`e(varlist)'
							local 		ntemp 			`e(n)'
							local 		ngtemp 			`e(ng)'
							local 		n_origtemp 		`e(n_orig)'
							local 		ng_origtemp 	`e(ng_orig)'
						
							qui mata: probit_no_sd(	"`depvar'",			/*
									*/				"`indepvar2'",		/*
									*/				"pvar2",			/*
									*/				"tvar2",			/*
									*/				`n_origtemp',		/*
									*/				`fe',				/*
									*/				`te',				/*
									*/				"`v'"				)

							mat `btemp'[`i',1]	= r(b)
							mat `bmfxtemp'[`i',1]	= r(bmfx)
						}
					
						mata: betas_ss1("`bfe'",		/*
						*/				"`bfemfx'",		/*
						*/				"`btemp'",		/*
						*/				"`bmfxtemp'",	/*
						*/				0				)
					
						mat `betas'[`j', 1]		= r(b)
						mat `betasmfx'[`j', 1]	= r(bmfx)
						mat drop `btemp' `bmfxtemp'
						qui drop `touse1' `touse2' pvar2 tvar2
					}
				}
			}
				
			else {
			
				if `multiple' == 0 {
					mat `betas'		= J(4, `k', .)
					mat `betasmfx'	= J(4, `k', .)
					tempvar touse1 touse2 touse3 touse4 grouppvar grouptvar
					qui gen byte `touse1' = `tousesample'
					qui gen byte `touse2' = `tousesample'
					qui gen byte `touse3' = `tousesample'
					qui gen byte `touse4' = `tousesample'
					qui egen `grouppvar' = group(`pvar') if `tousesample'
					qui egen `grouptvar' = group(`tvar') if `tousesample'
					cap noi ss2touse `tousesample' `touse1' `touse2' `touse3' `touse4' `grouppvar' `grouptvar'
					local varlist2 `touse1' `touse2' `touse3' `touse4'
					
					foreach v of local varlist2 {
						local i : list posof `"`v'"' in varlist2
						qui `rmcoll' `varlist' if `v', `fvexp' probit touse(`v')
						local varlisttemp `"`r(varlist)'"'
						local singular : list varlist1 - varlisttemp
						di
						di in ye "Computing fixed-effects estimator in subpanel `i' of 4"
				
						if "`singular'" != "" {
							di in gr "Warning: collinear variable(s) not in the original sample detected"
							di in gr "Collinear variables: " in ye "`singular'"
						}
				
						cap qui CheckGroups `v' `pvar' `tvar' `varlisttemp', teffects(`teffects') ieffects(`ieffects')
						local 		indepvar2 		`e(varlist)'
						local 		ntemp 			`e(n)'
						local 		ngtemp 			`e(ng)'
						local 		n_origtemp 		`e(n_orig)'
						local 		ng_origtemp 	`e(ng_orig)'
						
						mata: probit_no_sd(	"`depvar'",			/*
							*/				"`indepvar2'",		/*
							*/				"`pvar'",			/*
							*/				"`tvar'",			/*
							*/				`n_origtemp',		/*
							*/				`fe',				/*
							*/				`te',				/*
							*/				"`v'"				)

						mat `betas'[`i',1]	= r(b)
						mat `betasmfx'[`i',1]	= r(bmfx)
					}
				
				}
			
				else {
					mat `betas'    = J(`multiple', `k' , .)
					mat `betasmfx' = J(`multiple', `k' , .)
					set seed 13579
				
					forvalues j = 1/`multiple' {
						di
						di in ye "Computing fixed-effects estimator in multiple partition `j' of `multiple'"
						tempvar touse1 touse2 touse3 touse4 btemp bmfxtemp
						mat `btemp'		= J(4, `k', .)
						mat `bmfxtemp'	= J(4, `k', .)
						
						if "`individuals'" != "" & "`time'" == "" {
							qui sort `pvar'
							qui mata: multiplepvar("`pvar'")
							qui egen tvar2 = group(`tvar')
						}
						
						else if "`individuals'" == "" & "`time'" != "" {
							qui sort `tvar'
							qui mata: multipletvar("`tvar'")
							qui egen pvar2 = group(`pvar')
						}
						
						else {
							qui sort `pvar'
							qui mata: multiplepvar("`pvar'")
							qui sort `tvar'
							qui mata: multipletvar("`tvar'")
						}
					
						qui gen byte `touse1' = `tousesample'
						qui gen byte `touse2' = `tousesample'
						qui gen byte `touse3' = `tousesample'
						qui gen byte `touse4' = `tousesample'
						cap noi ss2touse `tousesample' `touse1' `touse2' `touse3' `touse4' pvar2 tvar2
						local varlist2 `touse1' `touse2' `touse3' `touse4'
					
						foreach v of local varlist2 {
							local i : list posof `"`v'"' in varlist2
							qui `rmcoll' `varlist' if `v', `fvexp' probit touse(`v')
							local varlisttemp `"`r(varlist)'"'
				
							cap qui CheckGroups `v' pvar2 tvar2 `varlisttemp', teffects(`teffects') ieffects(`ieffects')
							local 		indepvar2 		`e(varlist)'
							local 		ntemp 			`e(n)'
							local 		ngtemp 			`e(ng)'
							local 		n_origtemp 		`e(n_orig)'
							local 		ng_origtemp 	`e(ng_orig)'
						
							qui mata: probit_no_sd(	"`depvar'",			/*
									*/				"`indepvar2'",		/*
									*/				"pvar2",			/*
									*/				"tvar2",			/*
									*/				`n_origtemp',		/*
									*/				`fe',				/*
									*/				`te',				/*
									*/				"`v'"				)

							mat `btemp'[`i',1]	= r(b)
							mat `bmfxtemp'[`i',1]	= r(bmfx)
						}
					
						mata: betas_ss2("`bfe'",		/*
						*/				"`bfemfx'",		/*
						*/				"`btemp'",		/*
						*/				"`bmfxtemp'",	/*
						*/				0			,	/*
						*/				1			,	/*
						*/				1				)
					
						mat `betas'[`j', 1]		= r(b)
						mat `betasmfx'[`j', 1]	= r(bmfx)
						mat drop `btemp' `bmfxtemp'
						qui drop `touse1' `touse2' pvar2 tvar2
					}
					
				}
			
			}
			
			mata: betas_ss2(	"`bfe'",		/*
				*/				"`bfemfx'",		/*
				*/				"`betas'",		/*
				*/				"`betasmfx'",	/*
				*/				`multiple',		/*
				*/				`febias',		/*
				*/				`tebias'		)
				
			mat `b'		= r(b)
			mat `bapes'	= r(bmfx)
		}

*******************************************************************************
*Delete-one Jackknife in cross-section, split-panel jackknife in time-series
*******************************************************************************

		if "`js'" != "" {
			tempvar betas betasmfx
			
			if `febias' == 1 & `tebias' == 0 {
				qui sort `pvar' `tvar' `tousesample' 
				tempvar group
				qui egen `group' = group(`pvar') if `tousesample'
				qui sum `group' if `tousesample'
				local J = r(max)
				mat `betas'    = J(`J', `k', .)
				mat `betasmfx' = J(`J', `k', .)
			
				forvalues i = 1/`J' {
					tempvar index
					qui gen byte `index' = `group' != `i' & `tousesample'
				
					qui `rmcoll' `varlist' if `index', `fvexp' probit touse(`index')
					local varlisttemp `"`r(varlist)'"'
					local singular : list varlist1 - varlisttemp
					di
					di in ye "Computing fixed-effects estimator in subpanel `i' of `J'"
				
					if "`singular'" != "" {
						di in gr "Warning: collinear variable(s) not in the original sample detected"
						di in gr "Collinear variables: " in ye "`singular'"
					}
				
					cap qui CheckGroups `index' `pvar' `tvar' `varlisttemp', teffects(`teffects') ieffects(`ieffects')
					local 		indepvar2 		`e(varlist)'
					local 		ntemp 			`e(n)'
					local 		ngtemp 			`e(ng)'
					local 		n_origtemp 		`e(n_orig)'
					local 		ng_origtemp 	`e(ng_orig)'
						
					mata: probit_no_sd(	"`depvar'",			/*
						*/				"`indepvar2'",		/*
						*/				"`pvar'",			/*
						*/				"`tvar'",			/*
						*/				`n_origtemp',		/*
						*/				`fe',				/*
						*/				`te',				/*
						*/				"`index'"			)
						
					mat `betas'   [`i',1]	= r(b)
					mat `betasmfx'[`i',1]	= r(bmfx)
				}
			
			}
			
			else if `febias' == 0 & `tebias' == 1 {
				mat `betas'		= J(2, `k', .)
				mat `betasmfx'	= J(2, `k', .)
				local J = 2
				tempvar touse1 touse2 grouppvar grouptvar
				qui gen byte `touse1' = `tousesample'
				qui gen byte `touse2' = `tousesample'
				qui egen `grouppvar' = group(`pvar') if `tousesample'
				qui egen `grouptvar' = group(`tvar') if `tousesample'
				cap noi sstouset `tousesample' `touse1' `touse2' `grouppvar' `grouptvar'
				local varlist2 `touse1' `touse2'
					
				foreach v of local varlist2 {
					local i : list posof `"`v'"' in varlist2
					qui `rmcoll' `varlist' if `v', `fvexp' probit touse(`v')
					local varlisttemp `"`r(varlist)'"'
					local singular : list varlist1 - varlisttemp
					di
					di in ye "Computing fixed-effects estimator in subpanel `i' of 2"
				
					if "`singular'" != "" {
						di in gr "Warning: collinear variable(s) not in the original sample detected"
						di in gr "Collinear variables: " in ye "`singular'"
					}
				
					cap qui CheckGroups `v' `pvar' `tvar' `varlisttemp', teffects(`teffects') ieffects(`ieffects')
					local 		indepvar2 		`e(varlist)'
					local 		ntemp 			`e(n)'
					local 		ngtemp 			`e(ng)'
					local 		n_origtemp 		`e(n_orig)'
					local 		ng_origtemp 	`e(ng_orig)'
						
					mata: probit_no_sd(	"`depvar'",			/*
						*/				"`indepvar2'",		/*
						*/				"`pvar'",			/*
						*/				"`tvar'",			/*
						*/				`n_origtemp',		/*
						*/				`fe',				/*
						*/				`te',				/*
						*/				"`v'"	)

					mat `betas'   [`i',1]	= r(b)
					mat `betasmfx'[`i',1]	= r(bmfx)
				}
				
			}
			
			else {
				qui sort `pvar' `tvar' `tousesample' 
				tempvar group
				qui egen `group' = group(`pvar') if `tousesample'
				qui sum `group' if `tousesample'
				local J = r(max)
				mat `betas'    = J(`J'+2, `k', .)
				mat `betasmfx' = J(`J'+2, `k', .)
			
				forvalues i = 1/`J' {
					tempvar index
					qui gen byte `index' = `group' != `i' & `tousesample'
				
					qui `rmcoll' `varlist' if `index', `fvexp' probit touse(`index')
					local varlisttemp `"`r(varlist)'"'
					local singular : list varlist1 - varlisttemp
					di
					di in ye "Computing fixed-effects estimator in subpanel " `i' " of " `J'+2
				
					if "`singular'" != "" {
						di in gr "Warning: collinear variable(s) not in the original sample detected"
						di in gr "Collinear variables: " in ye "`singular'"
					}
				
					cap qui CheckGroups `index' `pvar' `tvar' `varlisttemp', teffects(`teffects') ieffects(`ieffects')
					local 		indepvar2 		`e(varlist)'
					local 		ntemp 			`e(n)'
					local 		ngtemp 			`e(ng)'
					local 		n_origtemp 		`e(n_orig)'
					local 		ng_origtemp 	`e(ng_orig)'
						
					mata: probit_no_sd(	"`depvar'",			/*
						*/				"`indepvar2'",		/*
						*/				"`pvar'",			/*
						*/				"`tvar'",			/*
						*/				`n_origtemp',		/*
						*/				`fe',				/*
						*/				`te',				/*
						*/				"`index'"			)
					mat `betas'   [`i',1]	= r(b)
					mat `betasmfx'[`i',1]	= r(bmfx)
				}
			
				tempvar touse1 touse2 grouppvar grouptvar
				qui gen byte `touse1' = `tousesample'
				qui gen byte `touse2' = `tousesample'
				qui egen `grouppvar' = group(`pvar') if `tousesample'
				qui egen `grouptvar' = group(`tvar') if `tousesample'
				cap qui sstouset `tousesample' `touse1' `touse2' `grouppvar' `grouptvar'
				local varlist2 `touse1' `touse2'
					
				foreach v of local varlist2 {
					local i : list posof `"`v'"' in varlist2
				
					qui `rmcoll' `varlist' if `v', `fvexp' probit touse(`v')
					local varlisttemp `"`r(varlist)'"'
					local singular : list varlist1 - varlisttemp
					di
					di in ye "Computing fixed-effects estimator in subpanel " `i'+`J' " of " `J'+2
				
					if "`singular'" != "" {
						di in gr "Warning: collinear variable(s) not in the original sample detected"
						di in gr "Collinear variables: " in ye "`singular'"
					}
				
					cap qui CheckGroups `v' `pvar' `tvar' `varlisttemp', teffects(`teffects') ieffects(`ieffects')
					local 		indepvar2 		`e(varlist)'
					local 		ntemp 			`e(n)'
					local 		ngtemp 			`e(ng)'
					local 		n_origtemp 		`e(n_orig)'
					local 		ng_origtemp 	`e(ng_orig)'
						
					mata: probit_no_sd(	"`depvar'",		/*
						*/				"`indepvar2'",	/*
						*/				"`pvar'",		/*
						*/				"`tvar'",		/*
						*/				`n_origtemp',	/*
						*/				`fe',			/*
						*/				`te',			/*
						*/				"`v'"			)

					mat `betas'   [`i'+`J',1]	= r(b)
					mat `betasmfx'[`i'+`J',1]	= r(bmfx)
				}
			
			}
			
			mata: betas_js(	"`bfe'",		/*
					*/		"`bfemfx'",		/*
					*/		"`betas'",		/*
					*/		"`betasmfx'",	/*
					*/		`febias',		/*
					*/		`tebias',		/*
					*/		`J'				)
					
			mat `b'		= r(b)
			mat `bapes'	= r(bmfx)
		}
		
*******************************************************************************
*Split-panel jackknife in cross-section, delete-one jackknife in time-series
*******************************************************************************
		
		if "`sj'" != "" {
			tempvar betas betasmfx
			
			if `febias' == 1 & `tebias' == 0 {
				mat `betas'		= J(2, `k', .)
				mat `betasmfx'	= J(2, `k', .)
				local J = 2
				tempvar touse1 touse2 grouppvar grouptvar
				qui gen byte `touse1' = `tousesample'
				qui gen byte `touse2' = `tousesample'
				qui egen `grouppvar' = group(`pvar') if `tousesample'
				qui egen `grouptvar' = group(`tvar') if `tousesample'
				cap noi sstousei `tousesample' `touse1' `touse2' `grouppvar' `grouptvar'
				local varlist2 `touse1' `touse2'
					
				foreach v of local varlist2 {
					local i : list posof `"`v'"' in varlist2
					qui `rmcoll' `varlist' if `v', `fvexp' probit touse(`v')
					local varlisttemp `"`r(varlist)'"'
					local singular : list varlist1 - varlisttemp
					di
					di in ye "Computing fixed-effects estimator in subpanel `i' of 2"
				
					if "`singular'" != "" {
						di in gr "Warning: collinear variable(s) not in the original sample detected"
						di in gr "Collinear variables: " in ye "`singular'"
					}
				
					cap qui CheckGroups `v' `pvar' `tvar' `varlisttemp', teffects(`teffects') ieffects(`ieffects')
					local 		indepvar2 		`e(varlist)'
					local 		ntemp 			`e(n)'
					local 		ngtemp 			`e(ng)'
					local 		n_origtemp 		`e(n_orig)'
					local 		ng_origtemp 	`e(ng_orig)'
						
					mata: probit_no_sd(	"`depvar'",			/*
						*/				"`indepvar2'",		/*
						*/				"`pvar'",			/*
						*/				"`tvar'",			/*
						*/				`n_origtemp',		/*
						*/				`fe',				/*
						*/				`te',				/*
						*/				"`v'"	)

					mat `betas'   [`i',1]	= r(b)
					mat `betasmfx'[`i',1]	= r(bmfx)
				}
				
			}
			
			else if `febias' == 0 & `tebias' == 1 {
				qui sort `pvar' `tvar' `tousesample' 
				tempvar group
				qui egen `group' = group(`tvar') if `tousesample'
				qui sum `group' if `tousesample'
				local J = r(max)
				mat `betas'    = J(`J', `k', .)
				mat `betasmfx' = J(`J', `k', .)
			
				forvalues i = 1/`J' {
					tempvar index
					qui gen byte `index' = `group' != `i' & `tousesample'
				
					qui `rmcoll' `varlist' if `index', `fvexp' probit touse(`index')
					local varlisttemp `"`r(varlist)'"'
					local singular : list varlist1 - varlisttemp
					di
					di in ye "Computing fixed-effects estimator in subpanel `i' of `J'"
				
					if "`singular'" != "" {
						di in gr "Warning: collinear variable(s) not in the original sample detected"
						di in gr "Collinear variables: " in ye "`singular'"
					}
				
					cap qui CheckGroups `index' `pvar' `tvar' `varlisttemp', teffects(`teffects') ieffects(`ieffects')
					local 		indepvar2 		`e(varlist)'
					local 		ntemp 			`e(n)'
					local 		ngtemp 			`e(ng)'
					local 		n_origtemp 		`e(n_orig)'
					local 		ng_origtemp 	`e(ng_orig)'
						
					mata: probit_no_sd(	"`depvar'",			/*
						*/				"`indepvar2'",		/*
						*/				"`pvar'",			/*
						*/				"`tvar'",			/*
						*/				`n_origtemp',		/*
						*/				`fe',				/*
						*/				`te',				/*
						*/				"`index'"			)
						
					mat `betas'   [`i',1]	= r(b)
					mat `betasmfx'[`i',1]	= r(bmfx)
				}
			
			}
			
			else {
				qui sort `pvar' `tvar' `tousesample' 
				tempvar group
				qui egen `group' = group(`tvar') if `tousesample'
				qui sum `group' if `tousesample'
				local J = r(max)
				mat `betas'    = J(`J'+2, `k', .)
				mat `betasmfx' = J(`J'+2, `k', .)
			
				forvalues i = 1/`J' {
					tempvar index
					qui gen byte `index' = `group' != `i' & `tousesample'
				
					qui `rmcoll' `varlist' if `index', `fvexp' probit touse(`index')
					local varlisttemp `"`r(varlist)'"'
					local singular : list varlist1 - varlisttemp
					di
					di in ye "Computing fixed-effects estimator in subpanel " `i' " of " `J'+2
				
					if "`singular'" != "" {
						di in gr "Warning: collinear variable(s) not in the original sample detected"
						di in gr "Collinear variables: " in ye "`singular'"
					}
				
					cap qui CheckGroups `index' `pvar' `tvar' `varlisttemp', teffects(`teffects') ieffects(`ieffects')
					local 		indepvar2 		`e(varlist)'
					local 		ntemp 			`e(n)'
					local 		ngtemp 			`e(ng)'
					local 		n_origtemp 		`e(n_orig)'
					local 		ng_origtemp 	`e(ng_orig)'
						
					mata: probit_no_sd(	"`depvar'",			/*
						*/				"`indepvar2'",		/*
						*/				"`pvar'",			/*
						*/				"`tvar'",			/*
						*/				`n_origtemp',		/*
						*/				`fe',				/*
						*/				`te',				/*
						*/				"`index'"			)
					mat `betas'   [`i',1]	= r(b)
					mat `betasmfx'[`i',1]	= r(bmfx)
				}
			
				tempvar touse1 touse2 grouppvar grouptvar
				qui gen byte `touse1' = `tousesample'
				qui gen byte `touse2' = `tousesample'
				qui egen `grouppvar' = group(`pvar') if `tousesample'
				qui egen `grouptvar' = group(`tvar') if `tousesample'
				cap qui sstousei `tousesample' `touse1' `touse2' `grouppvar' `grouptvar'
				local varlist2 `touse1' `touse2'
					
				foreach v of local varlist2 {
					local i : list posof `"`v'"' in varlist2
				
					qui `rmcoll' `varlist' if `v', `fvexp' probit touse(`v')
					local varlisttemp `"`r(varlist)'"'
					local singular : list varlist1 - varlisttemp
					di
					di in ye "Computing fixed-effects estimator in subpanel " `i'+`J' " of " `J'+2
				
					if "`singular'" != "" {
						di in gr "Warning: collinear variable(s) not in the original sample detected"
						di in gr "Collinear variables: " in ye "`singular'"
					}
				
					cap qui CheckGroups `v' `pvar' `tvar' `varlisttemp', teffects(`teffects') ieffects(`ieffects')
					local 		indepvar2 		`e(varlist)'
					local 		ntemp 			`e(n)'
					local 		ngtemp 			`e(ng)'
					local 		n_origtemp 		`e(n_orig)'
					local 		ng_origtemp 	`e(ng_orig)'
						
					mata: probit_no_sd(	"`depvar'",		/*
						*/				"`indepvar2'",	/*
						*/				"`pvar'",		/*
						*/				"`tvar'",		/*
						*/				`n_origtemp',	/*
						*/				`fe',			/*
						*/				`te',			/*
						*/				"`v'"			)

					mat `betas'   [`i'+`J',1]	= r(b)
					mat `betasmfx'[`i'+`J',1]	= r(bmfx)
				}
			
			}
			
			mata: betas_sj(	"`bfe'",		/*
					*/		"`bfemfx'",		/*
					*/		"`betas'",		/*
					*/		"`betasmfx'",	/*
					*/		`febias',		/*
					*/		`tebias',		/*
					*/		`J'				)
					
			mat `b'		= r(b)
			mat `bapes'	= r(bmfx)
		}
		
*******************************************************************************
*Delete-one Jackknife in cross-section and time-series
*******************************************************************************
		
		if "`jj'" != "" {
			tempvar groupp groupt betas betasmfx
			qui sort `pvar' `tvar' `tousesample'
			qui egen `groupp' = group(`pvar') if `tousesample'
			qui sum `groupp' if `tousesample'
			local Jp = r(max)
			qui sort `pvar' `tvar' `tousesample'
			qui egen `groupt' = group(`tvar') if `tousesample'
			qui sum `groupt' if `tousesample'
			local Jt = r(max)
			
			if `febias' == 1 & `tebias' == 0 {
				mat `betas'    = J(`Jp', `k', .)
				mat `betasmfx' = J(`Jp', `k', .)
			
				forvalues i = 1/`Jp' {
					tempvar index
					qui gen byte `index' = `groupp' != `i' & `tousesample'
				
					qui `rmcoll' `varlist' if `index', `fvexp' probit touse(`index')
					local varlisttemp `"`r(varlist)'"'
					local singular : list varlist1 - varlisttemp
					di
					di in ye "Computing fixed-effects estimator in subpanel `i' of `Jp'"
				
					if "`singular'" != "" {
						di in gr "Warning: collinear variable(s) not in the original sample detected"
						di in gr "Collinear variables: " in ye "`singular'"
					}
				
					cap qui CheckGroups `index' `pvar' `tvar' `varlisttemp', teffects(`teffects') ieffects(`ieffects')
					local 		indepvar2 		`e(varlist)'
					local 		ntemp 			`e(n)'
					local 		ngtemp 			`e(ng)'
					local 		n_origtemp 		`e(n_orig)'
					local 		ng_origtemp 	`e(ng_orig)'
						
					mata: probit_no_sd(	"`depvar'",			/*
						*/				"`indepvar2'",		/*
						*/				"`pvar'",			/*
						*/				"`tvar'",			/*
						*/				`n_origtemp',		/*
						*/				`fe',				/*
						*/				`te',				/*
						*/				"`index'"			)

					mat `betas'		[`i',1]	= r(b)
					mat `betasmfx'	[`i',1]	= r(bmfx)
					qui drop `index'
				}
				
			}
			
			else if `febias' == 0 & `tebias' == 1 {
				mat `betas'    = J(`Jt', `k', .)
				mat `betasmfx' = J(`Jt', `k', .)
			
				forvalues i = 1/`Jt' {
					tempvar index
					qui gen byte `index' = `groupt' != `i' & `tousesample'
				
					qui `rmcoll' `varlist' if `index', `fvexp' probit touse(`index')
					local varlisttemp `"`r(varlist)'"'
					local singular : list varlist1 - varlisttemp
					di
					di in ye "Computing fixed-effects estimator in subpanel `i' of `Jt'"
				
					if "`singular'" != "" {
						di in gr "Warning: collinear variable(s) not in the original sample detected"
						di in gr "Collinear variables: " in ye "`singular'"
					}
				
					cap qui CheckGroups `index' `pvar' `tvar' `varlisttemp', teffects(`teffects') ieffects(`ieffects')
					local 		indepvar2 		`e(varlist)'
					local 		ntemp 			`e(n)'
					local 		ngtemp 			`e(ng)'
					local 		n_origtemp 		`e(n_orig)'
					local 		ng_origtemp 	`e(ng_orig)'
						
					mata: probit_no_sd(	"`depvar'",			/*
						*/				"`indepvar2'",		/*
						*/				"`pvar'",			/*
						*/				"`tvar'",			/*
						*/				`n_origtemp',		/*
						*/				`fe',				/*
						*/				`te',				/*
						*/				"`index'"			)

					mat `betas'   [`i',1]	= r(b)
					mat `betasmfx'[`i',1]	= r(bmfx)
					qui drop `index'
				}
				
			}
			
			else {
				mat `betas'    = J(`Jp'+`Jt', `k', .)
				mat `betasmfx' = J(`Jp'+`Jt', `k', .)
			
				forvalues i = 1/`Jp' {
					tempvar index
					qui gen byte `index' = `groupp' != `i' & `tousesample'
				
					qui `rmcoll' `varlist' if `index', `fvexp' probit touse(`index')
					local varlisttemp `"`r(varlist)'"'
					local singular : list varlist1 - varlisttemp
					di
					di in ye "Computing fixed-effects estimator in subpanel " `i' " of " `Jp'+`Jt'
				
					if "`singular'" != "" {
						di in gr "Warning: collinear variable(s) not in the original sample detected"
						di in gr "Collinear variables: " in ye "`singular'"
					}
				
					cap qui CheckGroups `index' `pvar' `tvar' `varlisttemp', teffects(`teffects') ieffects(`ieffects')
					local 		indepvar2 		`e(varlist)'
					local 		ntemp 			`e(n)'
					local 		ngtemp 			`e(ng)'
					local 		n_origtemp 		`e(n_orig)'
					local 		ng_origtemp 	`e(ng_orig)'
						
					mata: probit_no_sd(	"`depvar'",			/*
						*/				"`indepvar2'",		/*
						*/				"`pvar'",			/*
						*/				"`tvar'",			/*
						*/				`n_origtemp',		/*
						*/				`fe',				/*
						*/				`te',				/*
						*/				"`index'"			)

					mat `betas'		[`i',1]	= r(b)
					mat `betasmfx'	[`i',1]	= r(bmfx)
					qui drop `index'
				}
				
				forvalues i = 1/`Jt' {
					tempvar index
					qui gen byte `index' = `groupt' != `i' & `tousesample'
				
					qui `rmcoll' `varlist' if `index', `fvexp' probit touse(`index')
					local varlisttemp `"`r(varlist)'"'
					local singular : list varlist1 - varlisttemp
					di
					di in ye "Computing fixed-effects estimator in subpanel " `i'+`Jp' " of " `Jt'+`Jp'
				
					if "`singular'" != "" {
						di in gr "Warning: collinear variable(s) not in the original sample detected"
						di in gr "Collinear variables: " in ye "`singular'"
					}
				
					cap qui CheckGroups `index' `pvar' `tvar' `varlisttemp', teffects(`teffects') ieffects(`ieffects')
					local 		indepvar2 		`e(varlist)'
					local 		ntemp 			`e(n)'
					local 		ngtemp 			`e(ng)'
					local 		n_origtemp 		`e(n_orig)'
					local 		ng_origtemp 	`e(ng_orig)'
						
					mata: probit_no_sd(	"`depvar'",			/*
						*/				"`indepvar2'",		/*
						*/				"`pvar'",			/*
						*/				"`tvar'",			/*
						*/				`n_origtemp',		/*
						*/				`fe',				/*
						*/				`te',				/*
						*/				"`index'"			)

					mat `betas'   [`Jp'+`i',1]	= r(b)
					mat `betasmfx'[`Jp'+`i',1]	= r(bmfx)
					qui drop `index'
				}
			
			}
			
			mata: betas_jj(	"`bfe'",		/*
					*/		"`bfemfx'",		/*
					*/		"`betas'",		/*
					*/		"`betasmfx'",	/*
					*/		`febias',		/*
					*/		`tebias',		/*
					*/		`Jp',			/*
					*/		`Jt'			)

			mat `b'		= r(b)
			mat `bapes'	= r(bmfx)
		}
		
*******************************************************************************
*Double Panel Jackknife: delete i = t
*******************************************************************************

		if "`double'" != "" {
			tempvar betas betasmfx

			if `febias' == 1 & `tebias' == 0 {
				qui sort `pvar' `tvar' `tousesample' 
				tempvar group
				qui egen `group' = group(`pvar') if `tousesample'
				qui sum `group' if `tousesample'
				local J = r(max)
				mat `betas'    = J(`J', `k', .)
				mat `betasmfx' = J(`J', `k', .)
			
				forvalues i = 1/`J' {
					tempvar index
					qui gen byte `index' = `group' != `i' & `tousesample'
				
					qui `rmcoll' `varlist' if `index', `fvexp' probit touse(`index')
					local varlisttemp `"`r(varlist)'"'
					local singular : list varlist1 - varlisttemp
					di
					di in ye "Computing fixed-effects estimator in subpanel `i' of `J'"
				
					if "`singular'" != "" {
						di in gr "Warning: collinear variable(s) not in the original sample detected"
						di in gr "Collinear variables: " in ye "`singular'"
					}
				
					cap qui CheckGroups `index' `pvar' `tvar' `varlisttemp', teffects(`teffects') ieffects(`ieffects')
					local 		indepvar2 		`e(varlist)'
					local 		ntemp 			`e(n)'
					local 		ngtemp 			`e(ng)'
					local 		n_origtemp 		`e(n_orig)'
					local 		ng_origtemp 	`e(ng_orig)'
						
					mata: probit_no_sd(	"`depvar'",			/*
						*/				"`indepvar2'",		/*
						*/				"`pvar'",			/*
						*/				"`tvar'",			/*
						*/				`n_origtemp',		/*
						*/				`fe',				/*
						*/				`te',				/*
						*/				"`index'"			)
						
					mat `betas'   [`i',1]	= r(b)
					mat `betasmfx'[`i',1]	= r(bmfx)
					qui drop `index'
				}
			
			}
			
			else if `febias' == 0 & `tebias' == 1 {
				qui sort `pvar' `tvar' `tousesample' 
				tempvar group
				qui egen `group' = group(`tvar') if `tousesample'
				qui sum `group' if `tousesample'
				local J = r(max)
				mat `betas'    = J(`J', `k', .)
				mat `betasmfx' = J(`J', `k', .)
			
				forvalues i = 1/`J' {
					tempvar index
					qui gen byte `index' = `group' != `i' & `tousesample'
				
					qui `rmcoll' `varlist' if `index', `fvexp' probit touse(`index')
					local varlisttemp `"`r(varlist)'"'
					local singular : list varlist1 - varlisttemp
					di
					di in ye "Computing fixed-effects estimator in subpanel `i' of `J'"
				
					if "`singular'" != "" {
						di in gr "Warning: collinear variable(s) not in the original sample detected"
						di in gr "Collinear variables: " in ye "`singular'"
					}
				
					cap qui CheckGroups `index' `pvar' `tvar' `varlisttemp', teffects(`teffects') ieffects(`ieffects')
					local 		indepvar2 		`e(varlist)'
					local 		ntemp 			`e(n)'
					local 		ngtemp 			`e(ng)'
					local 		n_origtemp 		`e(n_orig)'
					local 		ng_origtemp 	`e(ng_orig)'
						
					mata: probit_no_sd(	"`depvar'",			/*
						*/				"`indepvar2'",		/*
						*/				"`pvar'",			/*
						*/				"`tvar'",			/*
						*/				`n_origtemp',		/*
						*/				`fe',				/*
						*/				`te',				/*
						*/				"`index'"			)
						
					mat `betas'   [`i',1]	= r(b)
					mat `betasmfx'[`i',1]	= r(bmfx)
					qui drop `index'
				}
			
			}
			
			else {
				local J = `Jdouble'
				mat `betas'    = J(`J', `k', .)
				mat `betasmfx' = J(`J', `k', .)
				
				forvalues i = 1/`J' {
					tempvar index
					qui gen byte `index' = (`pvar' != `indexdouble'[`i', 1] & `tvar' != `indexdouble'[`i', 1] & `tousesample')
				
					qui `rmcoll' `varlist' if `index', `fvexp' probit touse(`index')
					local varlisttemp `"`r(varlist)'"'
					local singular : list varlist1 - varlisttemp
					di
					di in ye "Computing fixed-effects estimator in subpanel `i' of `J'"
				
					if "`singular'" != "" {
						di in gr "Warning: collinear variable(s) not in the original sample detected"
						di in gr "Collinear variables: " in ye "`singular'"
					}
				
					cap qui CheckGroups `index' `pvar' `tvar' `varlisttemp', teffects(`teffects') ieffects(`ieffects')
					local 		indepvar2 		`e(varlist)'
					local 		ntemp 			`e(n)'
					local 		ngtemp 			`e(ng)'
					local 		n_origtemp 		`e(n_orig)'
					local 		ng_origtemp 	`e(ng_orig)'
						
					mata: probit_no_sd(	"`depvar'",		/*
						*/				"`indepvar2'",	/*
						*/				"`pvar'",		/*
						*/				"`tvar'",		/*
						*/				`n_origtemp',	/*
						*/				`fe',			/*
						*/				`te',			/*
						*/				"`index'"		)

					mat `betas'   [`i',1]	= r(b)
					mat `betasmfx'[`i',1]	= r(bmfx)
					qui drop `index'
				}
				
			}
			
			mata: betas_double(	"`bfe'",		/*
					*/			"`bfemfx'",		/*
					*/			"`betas'",		/*
					*/			"`betasmfx'",	/*
					*/			`J'				)
					
			mat `b'		= r(b)
			mat `bapes'	= r(bmfx)
	
		}
	}

********************************************************************************
* Done with estimation block
********************************************************************************

	mat colnames `b' = `indepnames'
	mat colnames `V' = `indepnames'
	mat rownames `V' = `indepnames'
	mat colnames `bapes' = `indepnames'
	mat colnames `Vapes' = `indepnames'
	mat rownames `Vapes' = `indepnames'
	
********************************************************************************
* r2_p, chi2, p
********************************************************************************

	qui mata: probitconstantonly(	"`depvar'",		/*
			*/						"`touse'"	)
	scalar `ll_0'	= r(ll_0)
	scalar `r2_p'	= 1 - `ll'/`ll_0'
	scalar `chi2'	= 2 * (`ll' - `ll_0')
	scalar `p'		= chiprob(`df_m', `chi2')

*********************************************************************************
* Post and display results
*********************************************************************************
	
	tempname btemp Vtemp bapestemp Vapestemp
	mat `btemp' 			= `b'
	mat `Vtemp' 			= `V'
	mat `bapestemp' 		= `bapes'
	mat `Vapestemp' 		= `Vapes'
	qui count if `touse'
	local N 				= r(N)
	capture ereturn post `b' `V', dep(`depname') obs(`N') esample(`touse')
	ereturn matrix	b2 		`bapes'
	ereturn matrix	V2 		`Vapes'
	ereturn local	cmd 	`probitfe_cmd'
	ereturn local 	cmdline `cmdline'
	ereturn local 	chi2type "LR"
	ereturn local 	id 		`pvar'
	ereturn local 	time 	`tvar'
	ereturn scalar 	k		= `k'
	ereturn scalar 	df_m	= `df_m'
	ereturn scalar 	ll		= `ll'
	ereturn scalar 	rankV	= `rankV'
	ereturn scalar 	rankV2	= `rankV'
	ereturn scalar 	ll_0	= `ll_0'
	ereturn scalar 	r2_p	= `r2_p'
	ereturn scalar 	chi2	= `chi2'
	ereturn scalar 	p		= `p'
	
	if `n' < `n_orig' {
	
		if (`ng_orig' - `ng' > 1) | (`nt_orig' - `nt' > 1) {
			ereturn scalar N_drop = `n_orig' - `n'
			ereturn scalar N_group_drop = `ng_orig' - `ng'
			ereturn scalar N_time_drop = `nt_orig' - `nt'
		}
	}
	ereturn scalar N_group	= `ng'
	ereturn scalar T_min	= `T_min'
	ereturn scalar T_max	= `T_max'
	ereturn scalar T_avg	= `T_avg'
	ereturn scalar fpc		= `fpc'
	
	if `fe' ==1 & `te' == 0 {
		local title1 "Type of included effects: individual effects only"
	}
		
	else if `fe' == 0 & `te' == 1 {
		local title1 "Type of included effects: time effects only"
	}
		
	else {
		local title1 "Type of included effects: individual and time effects"
	}
	
	if `febias' == 1 & `tebias' == 0 {
		local title2 "Type of bias correction: individual effects only"
	}
		
	else if `febias' == 0 & `tebias' == 1 {
		local title2 "Type of bias correction: time effects only"
	}
		
	else {
		local title2 "Type of bias correction: individual and time effects"
	}
	
	if "`nocorrection'" != "" {
		local title "Uncorrected fixed-effects estimates"
		local title2 "Type of bias correction: none"
	}
	
	if "`analytical'" != "" | ("`nocorrection'" == "" & "`analytical'" == "" & "`jackknife'" == "") {
		local title "Analytical bias-correction"
		local title3 "Triming parameter = `lags'"
	}
	
	if "`jackknife'" != "" {
	
		if "`ss1'" != "" {
			local title "Split-panel jackknife in four subpanels"
			
			if `multiple' > 0 {
			
				if "`individuals'" != "" & "`time'" == "" {
					local title3 "`multiple' multiple partitions in the cross-section dimension"
				}
				
				else if "`individuals'" == "" & "`time'" != "" {
					local title3 "`multiple' multiple partitions in the time dimension"
				}
				
				else {
					local title3 "`multiple' multiple partitions in both the cross-section and the time dimension"
				}
			}
			
		}
		
		if "`ss2'" != "" | ("`ss1'" == "" & "`ss2'" == "" & "`js'" == "" & "`sj'" == "" & "`jj'" == "" & "`double'" == "") {
			local title "Split-panel jackknife in both dimensions"

			if `multiple' > 0 {
			
				if "`individuals'" != "" & "`time'" == "" {
					local title3 "`multiple' multiple partitions in the cross-section dimension"
				}
				
				else if "`individuals'" == "" & "`time'" != "" {
					local title3 "`multiple' multiple partitions in the time dimension"
				}
				
				else {
					local title3 "`multiple' multiple partitions in both the cross-section and the time dimension"
				}
			}
		}
		
		if "`js'" != "" {
			local title "Delete-one jackknife in cross-section, split-panel in time series"
		}
		
		if "`sj'" != "" {
			local title "Split-panel jackknife in cross-section, delete-one jackknife in time series"
		}
		
		if "`jj'" != "" {
			local title "Delete-one jackknife in cross-section and time series"
		}
		
		if "`double'" != "" {
			local title "Double-panel jackknife"
		}
		
	}
	
	local title4 "Average Partial Effects"
	
	capture ereturn local title3 `title3'
	ereturn local title2 `title2'
	ereturn local title1 `title1'
	ereturn local title `title'
		
di in gr _n "`e(title)'"
di in gr  "`e(title1)'"
di in gr  "`e(title2)'"
	local tlen=length("`e(title2)'")
di in gr "{hline `tlen'}"
	if "`e(title3)'" != "" {
di in gr "`e(title3)'"
	}
di in gr "ID variable    = " in ye e(id) _continue
di in gr _col(48) "Number of obs.       = " in ye %8.0f e(N)
di in gr "Time variable  = " in ye e(time) _continue
di in gr _col(48) "Number of groups     = " in ye %8.0f e(N_group)
di in gr _col(48) "Obs. per group: min  = " in ye %8.0f e(T_min)
di in gr _col(48) "                avg  = " in ye %8.1f e(T_avg)
di in gr _col(48) "                max  = " in ye %8.0f e(T_max)
di in gr _col(48) "LR chi2(" in ye %4.0f e(df_m) in gr ")        = " in ye %8.2f e(chi2)
di in gr _col(48) "Prob > chi2          = " in ye %8.4f e(p)
di in gr "Log-likelihood = " in ye %12.0g e(ll) _continue
di in gr _col(48) "Pseudo R2            = " in ye %8.4f e(r2_p)
di
	ereturn display, noempty
	ereturn repost b = `bapestemp' V = `Vapestemp'
di in ye "`title4'"
	if e(fpc) != 1 {
di in gr "Variance adjusted by the finite population parameter " in ye %8.4f e(fpc)
	}
	ereturn display, noempty
	ereturn repost b = `btemp' V = `Vtemp'
end

*******************************************************************************
*Subroutines
*******************************************************************************

capture program drop Disp
program define Disp 
	version 8.2
	syntax [anything] [, _col(integer 15) ]
	local len = 80-`_col'+1
	local piece : piece 1 `len' of `"`anything'"'
	local i 1
	while "`piece'" != "" {
		di in gr _col(`_col') "`first'`piece'"
		local i = `i' + 1
		local piece : piece `i' `len' of `"`anything'"'
	}
	if `i'==1 {
		di
	}
end

capture program drop sstousei
program define sstousei, eclass byable(recall) sortpreserve
	version 11.2, missing
	syntax varlist
	gettoken touse  varlist : varlist
	gettoken touse1 varlist : varlist
	gettoken touse2 varlist : varlist
	gettoken pvar   tvar    : varlist
	tempvar t1 t2 i1 i2
	qui sum `tvar' if `touse'
	qui gen byte `t1' = cond(`tvar' <= ceil(r(max)/2), 1, 0) if `touse'
	qui gen byte `t2' = cond(ceil(r(max)/2) == floor(r(max)/2), /*
		*/ cond(`tvar' > ceil(r(max)/2), 1, 0), cond(`tvar' >= ceil(r(max)/2), 1, 0)) if `touse'
	
**All individuals, first half of time periods
	qui gen byte `i1' = (`t1' & `touse')
	qui replace `touse1' = `i1'
**All individuals, second half of time periods
	qui gen byte `i2' = (`t2' & `touse')
	qui replace `touse2' = `i2'

end

capture program drop sstouset
program define sstouset, eclass byable(recall) sortpreserve
	version 11.2, missing
	syntax varlist
	gettoken touse  varlist : varlist
	gettoken touse1 varlist : varlist
	gettoken touse2 varlist : varlist
	gettoken pvar   tvar    : varlist
	tempvar N t1 t2 i1 i2
	qui egen `N' = group(`pvar') if `touse'
	qui sum `N' if `touse'
	qui gen byte `t1' = cond(`N' <= ceil(r(max)/2), 1, 0) if `touse'
	qui gen byte `t2' = cond(ceil(r(max)/2) == floor(r(max)/2), /*
		*/ cond(`N' > ceil(r(max)/2), 1, 0), cond(`N' >= ceil(r(max)/2), 1, 0)) if `touse'
	
**Bottom half panel out, all time periods
	qui gen byte `i1' = (`t1' & `touse')
	qui replace `touse1' = `i1'
**Top half panel out, all time periods
	qui gen byte `i2' = (`t2' & `touse')
	qui replace `touse2' = `i2'

end

capture program drop ss1touse
program define ss1touse, eclass byable(recall) sortpreserve
	version 11.2, missing
	syntax varlist
	gettoken touse  varlist : varlist
	gettoken touse1 varlist : varlist
	gettoken touse2 varlist : varlist
	gettoken touse3 varlist : varlist
	gettoken touse4 varlist : varlist
	gettoken pvar   tvar    : varlist
	tempvar N t1 t2 h1 h2 i1 i2 i3 i4
	qui sum `tvar' if `touse'
	qui gen byte `t1' = cond(`tvar' <= ceil(r(max)/2), 1, 0) if `touse'
	qui gen byte `t2' = cond(ceil(r(max)/2) == floor(r(max)/2), /*
		*/ cond(`tvar' > ceil(r(max)/2), 1, 0), cond(`tvar' >= ceil(r(max)/2), 1, 0)) if `touse'
	qui egen `N' = group(`pvar') if `touse'
	qui sum `N' if `touse'
	qui gen byte `h1' = cond(`N' <= ceil(r(max)/2), 1, 0) if `touse'
	qui gen byte `h2' = cond(ceil(r(max)/2) == floor(r(max)/2), /*
		*/ cond(`N' > ceil(r(max)/2), 1, 0), cond(`N' >= ceil(r(max)/2), 1, 0)) if `touse'
	
**Bottom half panel out, first half of time periods
	qui gen byte `i1' = (`t1' & `h1' & `touse')
	qui replace `touse1' = `i1'
**Bottom half panel out, second half of time periods
	qui gen byte `i2' = (`t2' & `h1' & `touse')
	qui replace `touse2' = `i2'
**Top half panel out, first half of time periods
	qui gen byte `i3' = (`t1' & `h2' & `touse')
	qui replace `touse3' = `i3'
**Top half panel out, second half of time periods
	qui gen byte `i4' = (`t2' & `h2' & `touse')
	qui replace `touse4' = `i4'
	
end

capture program drop ss2touse
program define ss2touse, eclass byable(recall) sortpreserve
	version 11.2, missing
	syntax varlist
	gettoken touse  varlist : varlist
	gettoken touse1 varlist : varlist
	gettoken touse2 varlist : varlist
	gettoken touse3 varlist : varlist
	gettoken touse4 varlist : varlist
	gettoken pvar   tvar    : varlist
	tempvar N t1 t2 h1 h2 i1 i2 i3 i4
	qui sort `touse' `pvar' `tvar'
	qui by `touse' `pvar' : gen byte `t1' = cond(_n <= ceil(_N/2), 1, 0) if `touse'
	qui by `touse' `pvar' : gen byte `t2' = cond(ceil(_N/2) == floor(_N/2), /*
		*/ cond(_n > ceil(_N/2), 1, 0), cond(_n >= ceil(_N/2), 1, 0)) if `touse'
	qui egen `N' = group(`pvar') if `touse'
	qui sum `N' if `touse'
	qui sort `touse' `pvar' `tvar'
	qui by `touse' `pvar' : gen byte `h1' = cond(`N' <= ceil(r(max)/2), 1, 0) if `touse'
	qui by `touse' `pvar' : gen byte `h2' = cond(ceil(r(max)/2) == floor(r(max)/2), /*
		*/ cond(`N' > ceil(r(max)/2), 1, 0), cond(`N' >= ceil(r(max)/2), 1, 0)) if `touse'
	
**Bottom half panel out, all time periods
	qui gen byte `i1' = (`h1' & `touse')
	qui replace `touse1' = `i1'
**Top half panel out, all time periods
	qui gen byte `i2' = (`h2' & `touse')
	qui replace `touse2' = `i2'
**All individuals, first half of time periods
	qui gen byte `i3' = (`t1' & `touse')
	qui replace `touse3' = `i3'
**All individuals, second half of time periods
	qui gen byte `i4' = (`t2' & `touse')
	qui replace `touse4' = `i4'

end
	
capture program drop CheckGroups
program define CheckGroups, eclass byable(recall) sortpreserve
	version 11.2, missing
	syntax varlist(fv ts)[, IEFFects(string) TEFFects(string)]
	gettoken touse varlist     : varlist
	gettoken pvar  varlist     : varlist
	gettoken tvar  varlist     : varlist
	gettoken depvar1 indepvar1 : varlist
	
*******************************************************************************
* Only individual effects
*******************************************************************************

if ("`ieffects'" == "" | "`ieffects'" == "yes") & "`teffects'" == "no" {
	sort `touse' `pvar'
	
*Check outcome varies for at least one individual

	cap by `touse' `pvar' : assert `depvar1' == `depvar1'[1] if `touse' 
	
	if !_rc {
		di as err "Outcome does not vary for any group"
		exit 2000 
	}

*Check for multiple positive outcomes accross individuals
	
	tempvar sumdep
	qui by `touse' `pvar' : gen double `sumdep' = cond(_n == _N, sum(`depvar1'), .) if `touse'
	qui count if `sumdep' > 1 & `sumdep' < .
	
	if `r(N)' {
		di as txt "note: multiple positive outcomes within " _c
		di as txt "groups encountered"
		local multiple multiple
	}

*Delete groups where outcome doesn't vary.

	CountObsGroups `touse' `pvar'
	local n_orig = r(n)
	local ng_orig = r(ng)
	sort `touse' `tvar'
	CountObsGroups `touse' `tvar'
	local nt_orig = r(ng)
	local nt = `nt_orig'
	sort `touse' `pvar'
	tempvar varies rtouse
	qui by `touse' `pvar': gen byte `varies' = cond(_n==_N, sum(`depvar1'!=`depvar1'[1]), .) if `touse'
	qui by `touse' `pvar': gen byte `rtouse' = (`varies'[_N]>0) & `touse'
	qui replace `touse' = `rtouse'
	sort `touse' `pvar'

	CountObsGroups `touse' `pvar'
	local n = r(n)
	local ng = r(ng)
	
	if `n' < `n_orig' {
	
		if `ng_orig'-`ng' > 1 {
			local s s
		}
		
		di as txt "note: " `ng_orig'-`ng' " group`s' (" _c
		di as txt `n_orig'-`n' _c 
		di as txt " obs) dropped because of all positive or"
		di as txt "      all zero outcomes"
		local ng_drop	= `ng_orig' - `ng'
		local n_drop	= `n_orig' - `n'
	}

*Check that each depvar varies in at least 1 group.

		capture tsset
		local pvar "`r(panelvar)'"
		local tvar "`r(timevar)'"
		markout `touse' `pvar' `tvar' `depvar1' `indepvar1', strok
		sort `pvar' `tvar' `touse' 
		
		if `"`indepvar1'"' != "" {
			fvexpand `indepvar1'
			local indepvar1 "`r(varlist)'"
			
			foreach v of local indepvar1 {
				_ms_parse_parts `v'
				
				if r(type) == "variable" & !r(omit) {
					cap bysort `touse' `pvar': assert `v' == `v'[1] if `touse'
					
					if !_rc {
						di as txt "note: `v' omitted because of no "_c
						di as txt "within-group variance"		

						if _caller() < 11 {
							local v
					}
					
						else local v o.`v'
					}
				}
				
				local xs `xs' `v'
			}
		}
		
		local indepvar1 `xs'
}

*******************************************************************************
* Only time effects
*******************************************************************************

else if ("`teffects'" == "" | "`teffects'" == "yes") & "`ieffects'" == "no" {
	sort `touse' `tvar'

*Check outcome varies for at least one individual

	cap by `touse' `tvar' : assert `depvar1' == `depvar1'[1] if `touse' 
	
	if !_rc {
			di as err "outcome does not vary for any time period"
			exit 2000 
	}

*Check for multiple positive outcomes accross individuals

	tempvar sumdep
	qui by `touse' `tvar' : gen double `sumdep' = cond(_n == _N, sum(`depvar1'), .) if `touse'
	qui count if `sumdep' > 1 & `sumdep' < .
	
	if `r(N)' {
		di as txt "note: multiple positive outcomes within " _c
		di as txt "time periods encountered"
		local multiple multiple
	}

*Delete groups where outcome doesn't vary.

	CountObsGroups `touse' `tvar'
	local n_orig = r(n)
	local nt_orig = r(ng)
	sort `touse' `pvar'
	CountObsGroups `touse' `pvar'
	local ng_orig = r(ng)
	local ng = `ng_orig'
	sort `touse' `tvar'
	tempvar varies rtouse
	qui by `touse' `tvar' : gen byte `varies' = cond(_n == _N, sum(`depvar1' != `depvar1'[1]), .) if `touse'
	qui by `touse' `tvar' : gen byte `rtouse' = (`varies'[_N] > 0 & `touse')
	qui replace `touse' = `rtouse'
	sort `touse' `tvar'

	CountObsGroups `touse' `tvar'
	local n = r(n)
	local nt = r(ng)

	if `n' < `n_orig' {
	
		if `nt_orig'-`nt' > 1 {
			local s s
		}
		
		di as txt "note: " `nt_orig'-`nt' " time period`s' (" _c
		di as txt `n_orig'-`n' _c 
		di as txt " obs) dropped because of all positive or"
		di as txt "      all zero outcomes"
		local nt_drop	= `nt_orig' - `nt'
		local n_drop	= `n_orig' - `n'
	}

*Check that each depvar varies in at least 1 group.

		capture tsset
		local pvar "`r(panelvar)'"
		local tvar "`r(timevar)'"
		markout `touse' `pvar' `tvar' `depvar1' `indepvar1', strok
		sort `pvar' `tvar' `touse' 

		if `"`indepvar1'"' != "" {
			fvexpand `indepvar1'
			local indepvar1 "`r(varlist)'"
			
			foreach v of local indepvar1 {
				_ms_parse_parts `v'
				
				if r(type) == "variable" & !r(omit) {
					cap bysort `touse' `tvar': assert `v' == `v'[1] if `touse'
					
					if !_rc {
						di as txt "note: `v' omitted because of no "_c
						di as txt "within-time variance"

						if _caller() < 11 {
							local v
						}
						
						else local v o.`v'
					}
				}
				
				local xs `xs' `v'
			}
		}
		
		local indepvar1 `xs'
}

*******************************************************************************
* Both individual and time effects
*******************************************************************************

else {
	sort `touse' `pvar'
	
*Check outcome varies for at least one individual

	cap by `touse' `pvar' : assert `depvar1' == `depvar1'[1] if `touse'
	
	if !_rc {
		di as err "Outcome does not vary for any group"
		exit 2000 
	}
	
	sort `touse' `tvar'
	cap by `touse' `tvar' : assert `depvar1' == `depvar1'[1] if `touse' 
	
	if !_rc {
		di as err "Outcome does not vary for any time period"
		exit 2000 
	}
	
*Check for multiple positive outcomes accross individuals
	
	tempvar sumdep
	sort `touse' `pvar'
	qui by `touse' `pvar' : gen double `sumdep' = cond(_n == _N, sum(`depvar1'), .) if `touse'
	qui count if `sumdep' > 1 & `sumdep' < .
	
	if `r(N)' {
		di as txt "note: multiple positive outcomes within " _c
		di as txt "groups encountered"
		local multiple multiple
	}
	
	tempvar sumdept
	sort `touse' `tvar'
	qui by `touse' `tvar' : gen double `sumdept' = cond(_n == _N, sum(`depvar1'), .) if `touse'
	qui count if `sumdept' > 1 & `sumdept' < .
	
	if `r(N)' {
		di as txt "note: multiple positive outcomes within " _c
		di as txt "time periods encountered"
		local multiple multiple
	}

*Delete groups where outcome doesn't vary.

	sort `touse' `pvar'
	CountObsGroups `touse' `pvar'
	local n_orig = r(n)
	local ng_orig = r(ng)
	sort `touse' `tvar'
	CountObsGroups `touse' `tvar'
	local nt_orig = r(ng)
	sort `touse' `pvar'
	tempvar varies rtouse
	qui by `touse' `pvar' : gen byte `varies' = cond(_n == _N, sum(`depvar1' != `depvar1'[1]), .) if `touse'
	qui by `touse' `pvar' : gen byte `rtouse' = (`varies'[_N] > 0 & `touse')
	qui replace `touse' = `rtouse'
	sort `touse' `tvar'
	tempvar variest rtouset
	qui by `touse' `tvar' : gen byte `variest' = cond(_n == _N, sum(`depvar1' != `depvar1'[1]), .) if `touse'
	qui by `touse' `tvar' : gen byte `rtouset' = (`variest'[_N] > 0 & `touse')
	qui replace `touse' = `rtouset'
	sort `touse' `pvar'
	
	CountObsGroups `touse' `pvar'
	local n = r(n)
	local ng = r(ng)
	sort `touse' `tvar'
	
	CountObsGroups `touse' `tvar'
	local nt = r(ng)

	if `n' < `n_orig' {
		
		if `ng_orig'-`ng' > 1 {
			local sp s
		}
		
		if `nt_orig'-`nt' > 1 {
			local st s
		}
	
		if `ng_orig'-`ng' > 0  & `nt_orig'-`nt' == 0 {
			di as txt "note: " `ng_orig'-`ng' " group`sp' (" _c
			di as txt `n_orig'-`n' _c 
			di as txt " obs) dropped because of all positive or"
			di as txt "      all zero outcomes"
		}
		
		else if `ng_orig'-`ng' == 0  & `nt_orig'-`nt' > 0 {
			di as txt "note: " `nt_orig'-`nt' " time period`st' (" _c
			di as txt `n_orig'-`n' _c 
			di as txt " obs) dropped because of all positive or"
			di as txt "      all zero outcomes"
		}
		
		else {
			di as txt "note: " `ng_orig'-`ng' " group`sp' and " _c
			di as txt `nt_orig'-`nt' " time period`st' (" _c
			di as txt `n_orig'-`n' _c 
			di as txt " obs) dropped because"
			di as txt "      of all positive or all zero outcomes"
		}
		
		local ng_drop	= `ng_orig' - `ng'
		local nt_drop	= `nt_orig' - `nt'
		local n_drop	= `n_orig' - `n'
	}

*Check that each depvar varies in at least 1 group.
		capture tsset
		local pvar "`r(panelvar)'"
		local tvar "`r(timevar)'"
		markout `touse' `pvar' `tvar' `depvar1' `indepvar1', strok
		sort `pvar' `tvar' `touse' 
		
		if `"`indepvar1'"' != "" {
			fvexpand `indepvar1'
			local indepvar1 "`r(varlist)'"
			
			foreach v of local indepvar1 {
				_ms_parse_parts `v'
				
				if r(type) == "variable" & !r(omit) {
					cap bysort `touse' `pvar': assert `v' == `v'[1] if `touse'
					
					if !_rc {
						di as txt "note: `v' omitted because of no "_c
						di as txt "within-group variance"

						if _caller() < 11 {
							local v
						}
						
						else local v o.`v'
					}
				}
				
				local xs `xs' `v'
			}
		}
		
		local indepvar1 `xs'
		sort `pvar' `tvar' `touse' 
		
		if `"`indepvar1'"' != "" {
		
			fvexpand `indepvar1'
			local indepvar1 "`r(varlist)'"

			foreach v of local indepvar1 {
				_ms_parse_parts `v'
				
				if r(type) == "variable" & !r(omit) {
					cap bysort `touse' `tvar': assert `v' == `v'[1] if `touse'
					
					if !_rc {
						di as txt "note: `v' omitted because of no "_c
						di as txt "within-time variance"

						if _caller() < 11 {
							local v
						}
						
						else local v o.`v'
					}
				}
				
				local ts `ts' `v'
			}
		}
		
		local indepvar1 `ts'
}

	ereturn local varlist `indepvar1'
	ereturn scalar n = `n'
	ereturn scalar ng = `ng'
	ereturn scalar nt = `nt'
	ereturn scalar n_orig = `n_orig'
	ereturn scalar ng_orig = `ng_orig'
	ereturn scalar nt_orig = `nt_orig'
	
	if `:length local n_drop' {
		ereturn scalar n_drop = `n_drop'
		cap ereturn scalar ng_drop = `ng_drop'
		cap ereturn scalar nt_drop = `nt_drop'
	}
	
end

capture program drop CountObsGroups
program CountObsGroups, rclass 
	args touse group

	tempvar i
	qui count if `touse'
	return scalar n = r(N)
	qui by `touse' `group': gen byte `i' = _n==1 & `touse'
	qui count if `i'
	return scalar ng = r(N)

end
	
*******************************************************************************
*MATA functions
*******************************************************************************
mata: mata clear
mata: mata set matastrict off
mata:

void probitconstantonly(	string	scalar yvar,
							string	scalar touse	)
{
external Y, X

st_view(Y	=., ., yvar,	touse)

X		= J(rows(Y), 1, 1)
XX		= quadcross(X, X)
Xy		= quadcross(X, Y)
XXinv	= invsym(XX)
delta	= XXinv * Xy
delta	= delta'

S 		= optimize_init()
optimize_init_evaluator(S, &llnprobit())
optimize_init_which(S, "max")
optimize_init_evaluatortype(S, "v2")
optimize_init_params(S, delta)
beta	= optimize(S)
ll_0	= optimize_result_value(S)

st_numscalar("r(ll_0)", ll_0)
}

void probit(	string	scalar yvar,
				string	scalar Xvars,
				string	scalar pvar,
				string	scalar tvar,
				real	scalar n_orig,
				real	scalar fe,
				real	scalar te,
				real	scalar fpc,
				string	scalar touse	)

{
external Y, X
st_view(Y			= ., ., yvar	, touse)
st_view(x2p			= ., ., Xvars	, touse)
st_view(panelvar	= ., ., pvar	, touse)
st_view(timevar		= ., ., tvar	, touse)

k					= cols(x2p)
N					= rows(Y)
info				= panelsetup(panelvar, 1)
T_min				= panelstats(info)[3]
T_max				= panelstats(info)[4]
T_avg				= panelstats(info)[2]/panelstats(info)[1]
info				= uniqrows(panelvar)
ng					= rows(info)

if (fe == 1 & te == 0) {
	FE				= J(N, ng, .)

	for (i = 1; i<=ng; i ++) {
		FE[., i]	= (panelvar :== info[i])
	}
	
	X				= x2p, FE[., 2::cols(FE)], J(N, 1, 1)
	
}

else if (fe == 0 & te == 1) {
	info			= uniqrows(timevar)
	TE				= J(N, rows(info), .)

	for (i=1; i<=rows(info); i++) {
		TE[., i]	= (timevar :== info[i])
	}
	
	X				= x2p, TE[., 2::cols(TE)], J(N, 1, 1)
	
}

else {
	FE				= J(N, ng, .)

	for (i = 1; i<=ng; i ++) {
		FE[., i]	= (panelvar :== info[i])
	}
	
	info			= uniqrows(timevar)
	TE				= J(N, rows(info), .)

	for (i=1; i<=rows(info); i++) {
		TE[., i]	= (timevar :== info[i])
	}
	
	X				= x2p, FE[., 2::cols(FE)], TE[., 2::cols(TE)], J(N, 1, 1)
}

/*X					= x2p, fe*FE[., 2::cols(FE)], te*TE[., 2::cols(TE)], J(N, 1, 1)*/
XX					= quadcross(X, X)
XXinv				= invsym(XX)
XXinvdiag			= diagonal(XXinv)

//Check for additional collinearities between fixed-effects and regressors
for (i=1; i<=rows(XXinvdiag); i++) {
	if (XXinvdiag[i]== 0) {
		X[., i]		= J(rows(X), 1, 0)
	}
}

df_m				= rank(X) - 1
dfs					= N - df_m
XX					= quadcross(X, X)
Xy					= quadcross(X, Y)
XXinv				= invsym(XX)
delta				= XXinv * Xy
delta				= delta'

S 					= optimize_init()
optimize_init_evaluator(S, &llnprobit())
optimize_init_which(S, "max")
optimize_init_evaluatortype(S, "v2")
optimize_init_params(S, delta)
beta				= optimize(S)
H					= optimize_result_V(S)
ll					= optimize_result_value(S)
rank				= rank(H)
index 				= X * beta'
bmfx				= J(1, k, .)
vate				= J(k, 1, .)
temp				= J(cols(X), k, .)
temp1				= J(rows(uniqrows(panelvar)), 1, uniqrows(timevar))
temp2				= J(rows(uniqrows(timevar)), 1, uniqrows(panelvar))
temp2				= sort(temp2, 1)
info1				= panelsetup(temp2, 1)
info2				= panelsetup(panelvar, 1)

for (i=1; i<=k; i++) {

	if ((min(x2p[.,i]) == 0 & max(x2p[.,i]) == 1) & rows(uniqrows(x2p[.,i])) == 2) {
		X1			= X
		X0			= X
		X1[., i]	= J(rows(X1), 1, 1)
		X0[., i]	= J(rows(X0), 1, 0)
		bmfx[i]		= sum(normal(X1 * beta') - normal(X0 * beta'))/n_orig
		index0		= index - beta[i] * X[., i]
		index1		= index + beta[i] * (1 :- X[., i])
		ates		= normal(index1) - normal(index0)
	}
	
	else {
		bmfx[i]		= beta[i] * sum(normalden(X * beta'))/n_orig
		ates		= beta[i] * normalden(index)
	}
	
	X1temp			= J(rows(temp1), 1, .)
	X2temp			= timevar, ates
	
	for (p=1; p<=ng; p++) {
		X11temp		= panelsubmatrix(X1temp, p, info1)
		X22temp		= panelsubmatrix(X2temp, p, info2)
		X11temp[X22temp[., 1]] = X22temp[., 2]
		X1temp[info1[p,1]::info1[p,2], .]	= X11temp
	
	}
	
	ates			= X1temp'
	ates			= rowshape(ates, ng)'
	ates2			= ates'
	
	if ((min(x2p[.,i]) == 0 & max(x2p[.,i]) == 1) & rows(uniqrows(x2p[.,i])) == 2) {
		x			= colsum(ates') :/ colnonmissing(ates')
		ate			= sum(x)/cols(x)
		temp[.,i]	= colsum(normalden(index1) :* X1 - normalden(index0) :* X0)'/n_orig
	}
	
	else {
		ate			= bmfx[i]
		select		= J(cols(X), 1, 0)
		select[i]	= 1
		if (beta[i] != 0) {
			temp[., i]	= -beta[i] * colsum(index :* normalden(index) :* X)'/n_orig + ate * select / beta[i]
		}
		else {
			temp[., i]	= J(cols(X), 1, 0)
		}
	}
	
	vate[i]			= fpc * (sum(rowsum(ates :- ate) :^ 2) + sum(rowsum(ates2 :- ate) :^ 2) - sum((ates :- ate) :^ 2))/dfs^2
}

Vmfx				= temp' * H * temp :+ vate
b					= beta[1..k]
V					= H[1..k, 1..k]

_makesymmetric(V)
_makesymmetric(Vmfx)
st_matrix("r(b)", b)
st_matrix("r(V)", V)
st_matrix("r(bmfx)", bmfx)
st_matrix("r(Vmfx)", Vmfx)
st_matrix("r(beta)", beta)
st_numscalar("r(k)", k)
st_numscalar("r(df_m)", df_m)
st_numscalar("r(ll)", ll)
st_numscalar("r(rank)", rank)
st_numscalar("r(N)", N)
st_numscalar("r(T_min)", T_min)
st_numscalar("r(T_max)", T_max)
st_numscalar("r(T_avg)", T_avg)
}

void probit_no_sd(	string	scalar yvar,
					string	scalar Xvars,
					string	scalar pvar,
					string	scalar tvar,
					real	scalar n_orig,
					real	scalar fe,
					real	scalar te,
					string	scalar touse	)
{
external Y, X
st_view(Y			= ., ., yvar,	touse)
st_view(x2p			= ., ., Xvars,	touse)
st_view(panelvar	= ., ., pvar,	touse)
st_view(timevar		= ., ., tvar,	touse)

k					= cols(x2p)
N					= rows(Y)
info				= uniqrows(panelvar)
FE					= J(N, rows(info), 0)

if (fe == 1 & te == 0) {

	for (i = 1; i<=rows(info); i ++) {
		FE[., i]	= (panelvar :== info[i])
	}

	X				= x2p, FE[., 2::cols(FE)], J(N, 1, 1)
}

else if (fe == 0 & te == 1) {
	info			= uniqrows(timevar)
	TE				= J(N, rows(info), 0)

	for (i=1; i<=rows(info); i++) {
		TE[., i]	= (timevar :== info[i])
	}
	
	X				= x2p, TE[., 2::cols(TE)], J(N, 1, 1)
}

else {

	for (i = 1; i<=rows(info); i ++) {
		FE[., i]	= (panelvar :== info[i])
	}
	
	info			= uniqrows(timevar)
	TE				= J(N, rows(info), 0)

	for (i=1; i<=rows(info); i++) {
		TE[., i]	= (timevar :== info[i])
	}
	
	X				= x2p, FE[., 2::cols(FE)], TE[., 2::cols(TE)], J(N, 1, 1)
}

XX					= quadcross(X, X)
XXinv				= invsym(XX)
XXinvdiag			= diagonal(XXinv)

//Check for additional collinearities between fixed-effects and regressors
for (i=1; i<=rows(XXinvdiag); i++) {

	if (XXinvdiag[i]== 0) {
		X[., i]		= J(rows(X), 1, 0)
	}
	
}

XX					= quadcross(X, X)
Xy					= quadcross(X, Y)
XXinv				= invsym(XX)
delta				= XXinv * Xy
delta				= delta'

S 					= optimize_init()
optimize_init_evaluator(S, &llnprobit())
optimize_init_which(S, "max")
optimize_init_evaluatortype(S, "v2")
optimize_init_params(S, delta)
beta				= optimize(S)
bmfx				= J(1, k, .)

for (i=1; i<=k; i++) {

	if ((min(x2p[.,i]) == 0 & max(x2p[.,i]) == 1) & rows(uniqrows(x2p[.,i])) == 2) {
		X1			= X
		X0			= X
		X1[., i]	= J(rows(X1), 1, 1)
		X0[., i]	= J(rows(X0), 1, 0)
		bmfx[i]		= sum(normal(X1 * beta') - normal(X0 * beta'))/n_orig
	}
	
	else {
		bmfx[i]		= beta[i] * sum(normalden(X * beta'))/n_orig
	}
	
}

b					= beta[1..k]
st_matrix("r(b)", b)
st_matrix("r(bmfx)", bmfx)
}

void analytical(	string	scalar yvar,
					string	scalar Xvars,
					string	scalar pvar,
					string 	scalar tvar, 
					string	scalar obs,
					string	scalar ltouse,
					string	scalar beta1,
					real	scalar lags,
					string	scalar NT1,
					real	scalar n_orig,
					real	scalar fe,
					real	scalar te,
					real	scalar febias,
					real	scalar tebias,
					string	scalar touse)
{
external Y, X
beta				= st_matrix(beta1)
NT					= st_numscalar(NT1)
st_view(Y			= ., ., yvar	, touse)
st_view(x2p			= ., ., Xvars	, touse)
st_view(panelvar	= ., ., pvar	, touse)
st_view(timevar		= ., ., tvar	, touse)
st_view(lagstouse	= ., ., ltouse	, touse)
st_view(allobs		= ., ., obs		, touse)
st_view(esample		= ., ., touse)

k					= cols(x2p)
N					= rows(Y)
ng					= rows(uniqrows(panelvar))
FE					= J(N, ng, .)
TNp					= J(ng, 1, .)
info				= panelsetup(panelvar, 1)
info1				= uniqrows(panelvar)

for (i = 1; i <= rows(info); i ++) {
	TNp[i]			= rows(panelsubmatrix(panelvar, i, info))
}

if (lags>0) {

	TNplags			= J(ng, lags, .)

	for (j=1; j<=lags; j++) {

		for (i=1; i<=rows(info); i++) {
			TNplags[i,j]= sum(panelsubmatrix(lagstouse[.,j], i, info))
		}
	
	}

}

if (fe == 1 & te == 0) {

	for (i = 1; i <= rows(info); i ++) {
		FE[., i]	= (panelvar :== info1[i])
	}
	
	X				= x2p, FE[., 2..cols(FE)], J(N, 1, 1)
	X1				= FE[., 2..cols(FE)], J(N, 1, 1)
}

else if (fe == 0 & te == 1) {
	info			= uniqrows(timevar)
	TE				= J(N, rows(info), .)
	
	for (i=1; i<=rows(info); i++) {
		TE[., i]	= (timevar :== info[i])
	}
	
	X				= x2p, TE[., 2..cols(TE)], J(N, 1, 1)
	X1				= TE[., 2..cols(TE)], J(N, 1, 1)
}

else {

	for (i = 1; i <= rows(info); i ++) {
		FE[., i]	= (panelvar :== info1[i])
	}
	
	info			= uniqrows(timevar)
	TE				= J(N, rows(info), .)
	
	for (i=1; i<=rows(info); i++) {
		TE[., i]	= (timevar :== info[i])
	}
	
	X				= x2p, FE[., 2..cols(FE)], TE[., 2..cols(TE)], J(N, 1, 1)
	X1				= FE[., 2..cols(FE)], TE[., 2..cols(TE)], J(N, 1, 1)
}

/*X					= x2p, fe*FE[., 2..cols(FE)], te*TE[., 2..cols(TE)], J(N, 1, 1)*/
index				= X * beta'
/*X1					= fe*FE[., 2..cols(FE)], te*TE[., 2..cols(TE)], J(N, 1, 1)*/
ws					= (normalden(index):^2) :/ (normal(index) :* normal(-index))
XX					= quadcross(X1, ws, X1)
Xy					= quadcross(X1, ws, x2p)
delta				= invsym(XX) * Xy
resx				= x2p - X1 * delta

if (lags>0) {
	psi				= (ws :* (Y - normal(index))) :/ normalden(index)
	psiNT			= J(NT,1,0)
	psiNT[allobs]	= psi
	lagspsiNT		= J(NT,lags,0)
	
	for (j=1; j<=lags; j++) {
		lagspsiNT[select(allobs, lagstouse[.,j]), j] = psiNT[select((allobs:-1), lagstouse[.,j])]
	}
	
	lagspsiNT		= select(lagspsiNT, esample)
	
}

if (febias == 0) {
	B				= J(1, k, 0)
}

else {
	B				= (((index :* ws :* resx)' * FE) :/ (ws' * FE))' :/ TNp

	if (lags>0) {

		for (i=1; i<=lags; i++) {
			B		= B - ((((2 * lagspsiNT[.,i] :* lagstouse[.,i] :* ws :* resx)' * FE) :/ (ws' * FE))' :/ TNplags[.,i])
		}
	
	}
	
	B				= (1/2) * mean(B)

}

if (tebias == 0) {
	D				= J(1, k, 0)
}

else {
	D				= (1/2) * mean((((index :* ws :* resx)' * TE) :/ (ws' * TE))')
}

W					= (resx' * (ws :* resx)) / N
bias				= (febias * B + tebias * D/ng) * invsym(W)
b					= beta[1..k] - bias
offset				= x2p * b'

if (fe == 1 & te == 0) {
	X				= FE[., 2..cols(FE)], J(N, 1, 1), offset
}

else if (fe == 0 & te == 1) {
	X				= TE[., 2..cols(TE)], J(N, 1, 1), offset
}

else {
	X				= FE[., 2..cols(FE)], TE[., 2..cols(TE)], J(N, 1, 1), offset
}

XX					= quadcross(X, X)
XXinv				= invsym(XX)
XXinvdiag			= diagonal(XXinv)

//Check for additional collinearities between fixed-effects and regressors
for (i=1; i<=rows(XXinvdiag); i++) {
	if (XXinvdiag[i]== 0) {
		X[., i]		= J(rows(X), 1, 0)
	}
}

XX					= quadcross(X, X)
Xy					= quadcross(X, Y)
XXinv				= invsym(XX)
delta				= XXinv * Xy
delta				= delta'
C					= J(1, cols(X), 0)
k1					= cols(X)
C[k1]				= 1
c					= 1
Cc					= C, c

S 					= optimize_init()
optimize_init_evaluator(S, &llnprobit())
optimize_init_which(S, "max")
optimize_init_evaluatortype(S, "v2")
optimize_init_params(S, delta)
optimize_init_constraints(S, Cc)
beta				= optimize(S)
index				= X * beta'
ws					= (normalden(index):^2) :/ (normal(index) :* normal(-index))
date				= -index :* normalden(index)
ddate				= (index:^2 :- 1) :* normalden(index)
XX					= quadcross(X1, ws, X1)
Xy					= quadcross(X1, ws, index)
delta				= invsym(XX) * Xy
pindex				= X1 * delta

if (febias == 0) {
	B				= 0
}

else {

	B				= (((date :* pindex + ddate)' * FE) :/ (ws' * FE))' :/ TNp

	if (lags>0) {
		Xy			= quadcross(X1, ws, (date :/ ws))
		delta		= invsym(XX) * Xy
		rdate		= (date :/ ws) - X1 * delta
		psi			= (ws :* (Y - normal(index))) :/ normalden(index)
		psiNT		= J(NT,1,0)
		psiNT[allobs]= psi
		lagspsiNT	= J(NT,lags,0)
	
		for (j=1; j<=lags; j++) {
			lagspsiNT[select(allobs, lagstouse[.,j]), j] = psiNT[select((allobs:-1), lagstouse[.,j])]
		}
	
		lagspsiNT	= select(lagspsiNT, esample)
	
		for (i=1; i<=lags; i++) {
			B		= B + ((((2 * lagspsiNT[.,i] :* lagstouse[.,i] :* ws :* rdate)' * FE) :/ (ws' * FE))' :/ TNplags[.,i])
		}
	}

	B				= (1/2) * mean(B)
}

if (tebias == 0) {
	D				= 0
}

else {
	D				= (1/2) * mean((((date :* pindex + ddate)' * TE) :/ (ws' * TE))')
}

bias				= febias*B + tebias*D/ng
bmfx				= b * (sum(normalden(index))/n_orig - bias)

for (i = 1; i <= k; i ++) {

	if ((min(x2p[.,i]) == 0 :& max(x2p[.,i]) == 1) :& rows(uniqrows(x2p[.,i])) == 2) {
		index0		= index - b[i] * x2p[., i]
		index1		= index + b[i] * (1 :- x2p[., i])
		date		= normalden(index1) - normalden(index0)
		ddate		= -(index1 :* normalden(index1) - index0 :* normalden(index0))
		XX			= quadcross(X1, ws, X1)
		Xy			= quadcross(X1, ws, index)
		delta		= invsym(XX) * Xy
		pindex		= X1 * delta
		
		if (febias == 0) {
			B		= 0
		}
		
		else {
			B		= (((date :* pindex + ddate)' * FE) :/ (ws' * FE))' :/ TNp
		
			if (lags>0) {
				Xy	= quadcross(X1, ws, (date :/ ws))
				delta= invsym(XX) * Xy
				rdate= (date :/ ws) - X1 * delta
			
				for (j=1; j<=lags; j++) {
					B	= B + ((((2 * lagspsiNT[.,j] :* lagstouse[.,j] :* ws :* rdate)' * FE) :/ (ws' * FE))' :/ TNplags[.,j])
				}
			
			}
					  
			B			= (1/2) * mean (B)
		}
		
		if (tebias == 0) {
			D		= 0
		}
		
		else {
			D			= (1/2) * mean((((date :* pindex + ddate)' * TE) :/ (ws' * TE))')
		}
		bias		= febias*B + tebias*D/ng
		bmfx[i]		= sum(normal(index1) - normal(index0))/n_orig - bias
	}
	
	else {
		bmfx[i]		= bmfx[i]
	}
}

st_matrix("r(b)", b)
st_matrix("r(bmfx)", bmfx)
}

void multiplepvar(	string scalar pvar	)
{
st_view(panelvar	= ., ., pvar)

/*rseed(13579)*/
info				= panelsetup(panelvar, 1)
mm_panels(panelvar, Sinfo=.)
ng					= rows(uniqrows(panelvar))
p					= mm_sample(ng, ng, ., ., 1)
panelvar2			= J(rows(panelvar), 1, .)

for (i=1; i<=rows(info); i++) {
	panelvar2[info[i,1]::info[i,2]]	= J(Sinfo[i], 1, p[i])
}


st_addvar("double", "pvar2")
st_store(., "pvar2", panelvar2)
}

void multipletvar(	string scalar tvar	)
{
st_view(timevar		= ., ., tvar)

/*rseed(02468)*/
info				= panelsetup(timevar, 1)
mm_panels(timevar, Sinfo=.)
ng					= rows(uniqrows(timevar))
p					= mm_sample(ng, ng, ., ., 1)
timevar2			= J(rows(timevar), 1, .)

for (i=1; i<=rows(info); i++) {
	timevar2[info[i,1]::info[i,2]]	= J(Sinfo[i], 1, p[i])
}

st_addvar("double", "tvar2")
st_store(., "tvar2", timevar2)
}

void betas_ss1(	string	scalar beta_fe,
				string	scalar betamfx_fe,
				string	scalar betas_fe,
				string	scalar betasmfx_fe,
				real	scalar multiple	)
{
bfe					= st_matrix(beta_fe)
bfemfx				= st_matrix(betamfx_fe)
betas				= st_matrix(betas_fe)
betasmfx			= st_matrix(betasmfx_fe)

if (multiple == 0) {
	b				= 2*bfe - mean(betas)
	bmfx			= 2*bfemfx - mean(betasmfx)
}

else {
	b				= mean(betas)
	bmfx			= mean(betasmfx)
}

st_matrix("r(b)", b)
st_matrix("r(bmfx)", bmfx)
}

void betas_ss2(	string	scalar	beta_fe,
				string	scalar	betamfx_fe,
				string	scalar	betas_fe,
				string	scalar	betasmfx_fe,
				real	scalar	multiple,
				real	scalar	febias,
				real	scalar	tebias	)
{
bfe					= st_matrix(beta_fe)
bfemfx				= st_matrix(betamfx_fe)
betas				= st_matrix(betas_fe)
betasmfx			= st_matrix(betasmfx_fe)

if (multiple == 0) {
	
	if (febias == 0 | tebias == 0) {
		b			= 2*bfe		- mean(betas)
		bmfx		= 2*bfemfx	- mean(betasmfx)
	}
	
	else {
		b			= 3*bfe		- 2 * mean(betas)
		bmfx		= 3*bfemfx	- 2 * mean(betasmfx)
	}
}

else {
	b				= mean(betas)
	bmfx			= mean(betasmfx)
}

st_matrix("r(b)", b)
st_matrix("r(bmfx)", bmfx)
}

void betas_js(	string	scalar beta_fe,
				string	scalar betamfx_fe,
				string	scalar betas_fe,
				string	scalar betasmfx_fe,	
				real	scalar febias,
				real	scalar tebias,
				real	scalar J			)
{
bfe					= st_matrix(beta_fe)
bfemfx				= st_matrix(betamfx_fe)
betas				= st_matrix(betas_fe)
betasmfx			= st_matrix(betasmfx_fe)

if (febias == 1 & tebias == 0) {
	b				= J * bfe    - (J - 1) * mean(betas)
	bmfx			= J * bfemfx - (J - 1) * mean(betasmfx)
}

else if (febias == 0 & tebias == 1) {
	b				= 2 * bfe    - mean(betas)
	bmfx			= 2 * bfemfx - mean(betasmfx)
}

else {
	b				= (J + 1) * bfe    - (J - 1) * mean(betas		[1::J, .]) - mean(betas		[(J+1)::(J+2), .])
	bmfx			= (J + 1) * bfemfx - (J - 1) * mean(betasmfx	[1::J, .]) - mean(betasmfx	[(J+1)::(J+2), .])
}

st_matrix("r(b)", b)
st_matrix("r(bmfx)", bmfx)
}

void betas_sj(	string	scalar beta_fe,
				string	scalar betamfx_fe,
				string	scalar betas_fe,
				string	scalar betasmfx_fe,	
				real	scalar febias,
				real	scalar tebias,
				real	scalar J			)
{
bfe					= st_matrix(beta_fe)
bfemfx				= st_matrix(betamfx_fe)
betas				= st_matrix(betas_fe)
betasmfx			= st_matrix(betasmfx_fe)

if (febias == 1 & tebias == 0) {
	b				= 2 * bfe    - mean(betas)
	bmfx			= 2 * bfemfx - mean(betasmfx)
}

else if (febias == 0 & tebias == 1) {
	b				= J * bfe    - (J - 1) * mean(betas)
	bmfx			= J * bfemfx - (J - 1) * mean(betasmfx)
}

else {
	b				= (J + 1) * bfe    - (J - 1) * mean(betas		[1::J, .]) - mean(betas		[(J+1)::(J+2), .])
	bmfx			= (J + 1) * bfemfx - (J - 1) * mean(betasmfx	[1::J, .]) - mean(betasmfx	[(J+1)::(J+2), .])
}

st_matrix("r(b)", b)
st_matrix("r(bmfx)", bmfx)
}

void betas_jj(	string	scalar beta_fe,
				string	scalar betamfx_fe,
				string	scalar betas_fe,
				string	scalar betasmfx_fe,	
				real	scalar febias,
				real	scalar tebias,
				real	scalar Jp,
				real	scalar Jt	)
{
bfe					= st_matrix(beta_fe)
bfemfx				= st_matrix(betamfx_fe)
betas				= st_matrix(betas_fe)
betasmfx			= st_matrix(betasmfx_fe)

if (febias == 1 & tebias == 0) {
	b				= Jp * bfe		- (Jp - 1) * mean(betas)
	bmfx			= Jp * bfemfx	- (Jp - 1) * mean(betasmfx)
}

else if (febias == 0 & tebias == 1) {
	b				= Jt * bfe		- (Jt - 1) * mean(betas)
	bmfx			= Jt * bfemfx	- (Jt - 1) * mean(betasmfx)
}

else {
	b				= (Jp + Jt - 1) * bfe    - (Jp - 1) * mean(betas	[1::Jp, .]) - (Jt - 1) * mean(betas		[(Jp+1)::(Jp+Jt), .])
	bmfx			= (Jp + Jt - 1) * bfemfx - (Jp - 1) * mean(betasmfx	[1::Jp, .]) - (Jt - 1) * mean(betasmfx	[(Jp+1)::(Jp+Jt), .])
}

st_matrix("r(b)", b)
st_matrix("r(bmfx)", bmfx)
}

void checkdouble(	string	scalar pvar,
					string 	scalar tvar,
					string	scalar touse	)
{
st_view(panelvar	= ., ., pvar	, touse)
st_view(timevar		= ., ., tvar	, touse)

info				= panelsetup(panelvar, 1)
info1				= uniqrows(panelvar)
info2				= uniqrows(timevar)

// Check there is at least one i = t, i = 1,...,N, t = 1,...,T
index				= J(rows(info), 1, .)

for (i=1; i<=rows(info); i++) {
	A				= info1[i] :- info2
	A				= select(A, A :== 0)
	index[i]		= (rows(A) > 0 ? 1 : 0)
}

st_numscalar("r(sum)", sum(index))
st_matrix("r(index)", select(info1, index))
}

void betas_double(	string	scalar beta_fe,
					string	scalar betamfx_fe,
					string	scalar betas_fe,
					string	scalar betasmfx_fe,
					real	scalar J	)
{
bfe					= st_matrix(beta_fe)
bfemfx				= st_matrix(betamfx_fe)
betas				= st_matrix(betas_fe)
betasmfx			= st_matrix(betasmfx_fe)

b					= J * bfe    - (J - 1) * mean(betas)
bmfx				= J * bfemfx - (J - 1) * mean(betasmfx)

st_matrix("r(b)", b)
st_matrix("r(bmfx)", bmfx)
}

void llnprobit(todo, b, llj, g, H)
{
external Y, X
real colvector	pm
real colvector	xb
real colvector	lj
real colvector	dllj
real colvector	d2llj
real scalar	dim
real scalar	nobs

nobs	= rows(Y)
dim		= cols(X)

if (nobs != rows(X) | dim != cols(b)) {
	_error(3200)
}

pm		= 2 * (Y :!= 0) :- 1
xb		= X * b'
lj		= normal(pm :* xb)
llj		= ln(lj)

if (todo == 0 | missing(llj)) return

dllj	= pm :* normalden(xb) :/ lj

if (missing(dllj)) {
	llj = .
	return
}

g		= dllj :* X

if (todo == 1) return

d2llj	= dllj :* (dllj + xb)

if (missing(d2llj)) {
	llj = .
	return
}

H		= -cross(X, d2llj, X)
}
end
