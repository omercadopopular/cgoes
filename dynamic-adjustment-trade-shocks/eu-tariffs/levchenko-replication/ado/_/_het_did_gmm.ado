*! version 1.0.0  17may2021

program define _het_did_gmm, rclass sortpreserve
        syntax varlist(numeric fv ts) [if] [in]                 ///
                        [fweight iweight pweight aweight],      ///
                        [                               		///
                            groupvar(string)					///
							psvars(string)						///
							estimator(string)					///
							treatvar(string)					///
							timevar(string)						///
							probit								///
							csdid								///
							noCONstant                     		///
							ITERate(integer 5)					///
							vce(passthru)						///
							touse2(string)						///
							pscore(string)						///
							treatname(string)					///
							gvar(string)						///
							t0(string)							///
							repeated							///
							*									///
                        ]

	// !! constant per equation 
	// !! make parmlist a separate program 
	// !! handling weights ?? verify Fernando vs GMM 
	// !! conditioning on t==0 ?? robust vs cluster cond t=0 
	// !! unbalanced samples 

	marksample touse 

	tempname init b V kappa
	
	// Getting weights 
	
	if "`weight'" != "" {
		local wgt [`weight' `exp']
	}

	// depvar and varlist 
	
	gettoken lhs rhs : varlist
    _fv_check_depvar `lhs'
	
	fvexpand `rhs'
	local xvars "`r(varlist)'"
	
	// Parse pscore()
	
	_Parse_pscore, `pscore'
	
	if ("`estimator'"=="imp") {
		local pscore imp 
	}
	
	// Getting initial values for gmm 
	
	if ("`repeated'"=="") {
		quietly _Init_Values if `touse' `wgt', 					///
				  estimator(`estimator') 						///
				  pscore(`pscore')								///
				  xvars(`xvars') 								///
				  treatvar(`treatvar')							///
				  groupvar(`groupvar')							///
				  lhs(`lhs') 									///
				  timevar(`timevar')							///
				  `csdid'										///
				  gvar(`gvar')									///
				  t0(`t0') 
	}
	else {
		quietly _Init_Values_R if `touse' `wgt',					///
				  estimator(`estimator') 							///
				  pscore(`pscore')									///
				  xvars(`xvars') 									///
				  treatvar(`treatvar')								///
				  lhs(`lhs') 										///
				  timevar(`timevar')								///
				  `csdid'											///
				  t0(`t0') 		
	}


	local condall "`r(condall)'"

	if ("`csdid'"!="") {
		matrix `kappa' = r(kappa)
		local  keq     = r(keq)
		local keqopt "keq(`keq')"
	}
	matrix `init'  = r(init)
	local glev "`r(glev)'"
	
	// Defining which estimator, parameters, instruments, and equations
	
	if ("`repeated'"=="") {
		_Eq_List_gmm, xvars(`xvars') `constant'	///
				  estimator(`estimator') 		///
				  `csdid' `keqopt' 		
	}
	else {
		_Eq_List_gmm_R, xvars(`xvars') `constant'	///
				  estimator(`estimator') 			///
				  `csdid' `keqopt' 			
	}
				  
	local parms "`s(parms)'"
	local eqlist "`s(eqlist)'"
	
	if ("`repeated'"=="") {
		_Instrument_names, `csdid'					///
						`keqopt' 					///
						estimator(`estimator') 		///
						xvars(`xvars')				
	}
	else {
		_Instrument_names_R, `csdid'				///
						`keqopt' 					///
						estimator(`estimator') 		///
						xvars(`xvars')			
	}
	
	local gmmest "`s(gmmest)'"
	local reg "`s(reg)'"
	local eqtwo "`s(eqtwo)'" 

	if ("`vce'"=="" & "`repeated'"=="") {
		local vce vce(cluster `groupvar')
	}

	di ""
	gmm _gmm_`gmmest' if `touse' `wgt',								///
					    ty(`treatvar')								///
					    y(`lhs')									///
						groupvar(`groupvar')						///
						timevar(`timevar')							///
					    from(`init')								///
						equations(`eqlist')							///
						parameters(`parms')							///
						`eqtwo'										///
                        quickderivatives							///
                        winit(unadjusted, independent) 				///
						onestep										///
						conv_maxiter(`iterate') 					///
						`vce' 										///
						valueid("EE criterion")						///
						pscore(`pscore')							///	
						iterlogonly									///
						reg(`reg') 									///
						nn(`nn') 									///
						nnt(`nnt')									///
						condall(`"`condall'"')						///
						`csdid'										///
						kappa(`kappa')								///
						`keqopt' 
						
		matrix `b' = e(b)
		matrix `V' = e(V)		

		_Re_Stripe, treatvar(`treatname')
		local stripe "`s(stripe)'"
		matrix colname `b' =  `stripe'
		matrix colname `V' = `stripe'
		matrix rowname `V' = `stripe'
		quietly replace `touse2' = e(sample)
		local N = e(N)
        return local vcetype "`e(vcetype)'"
		if ("`e(vce)'"=="cluster") {
			local N_clust = e(N_clust)
			return scalar N_clust = `N_clust'
			return local vce "`e(vce)'"
			return local clustvar "`e(clustvar)'"
		}
		return matrix b = `b'
		return matrix V = `V'
		return scalar N = `N'
end

program define _Re_Stripe, sclass
	syntax [anything], [treatvar(string)]
	local cols: colfullnames e(b)
	local uno: word 1 of `cols'
	local stripe0: list cols - uno
	local stripe "ATET:r1vs0.`treatvar' `stripe0'"
	sreturn local stripe "`stripe'"
end 

program define _Param_list, sclass
	syntax [anything], [vars(string) pnom(string) noCONstant] 
	local k: list sizeof vars
	local parmlist ""
	forvalues i=1/`k' {
	    local x: word `i' of `vars'
	    local parmlist "`parmlist' `pnom':`x'"
	}
	if ("`constant'"=="") {
		local parmlist "`parmlist' `pnom':_cons"
	}
	sreturn local parmlist "`parmlist'"
end 

program define Stri_PE_S, sclass
	syntax [anything], [ tvars(string) xvars(string) tr(string)]
	
	local kx: list sizeof xvars
	local kt: list sizeof tvars 
	local stripe "ATET:r1vs0.`tr'"
	
	forvalues i=1/`kt' {
			local tv: word `i' of tvars 
			local stripe "`stripe' treatment:`tv'"
	}
	forvalues i=1/`kx' {
			local xv: word `i' of xvars 
			local stripe "`stripe' treatment:`xv'"
	}
	sreturn local stripe "`stripe'"
end

program define _Init_Values, rclass sortpreserve
	syntax [anything] [if][in]								///
					  [fweight iweight pweight aweight], 	///
					  [										///
					  estimator(string) 					///
					  pscore(string) 						///
					  xvars(string) 						///
					  treatvar(string)						///
					  groupvar(string)						///
					  lhs(string)							///
					  timevar(string)						///
					  gvar(string)							///
					  csdid									///
					  t0(string)							///
					  ]

	marksample touse 
	tempname init grupo init0 pesos atetmat kappa wfin
	
	_get_diopts diopts, `options'

	if "`weight'" != "" {
		local wgt [`weight' `exp']
	}

	if ("`csdid'"=="") {
		quietly _Init_Values0 `0'
		matrix `init' = r(init)
	}
	else {
		tempvar beforevar gcount 
		quietly egen double `gcount' = group(`groupvar') if `touse'
		quietly summarize `gcount' if `touse'
		local ng = r(max)
		quietly generate double `beforevar' = 0 if `touse'
		_Before_Var, time(`timevar')			///
					 gvar(`groupvar') 			///
					 first(`gvar') 				///
					 before(`beforevar')
		matrix `kappa' = r(kappa)	
		local condall "`r(condall)'"
		local k = r(kparm)
		local glev = r(glev)
		forvalues i=1/`k' {
			local cond`i' "`r(cond`i')'" 
		}
		forvalues i=1/`k' {
				quietly _Init_Values0 if `touse' `wgt',			///
					estimator(`estimator') 						///
					pscore(`pscore')							///
					xvars(`xvars') 								///
					treatvar(`treatvar')						///
					groupvar(`groupvar')						///
					lhs(`lhs') timevar(`timevar')				///
  					condt(`cond`i'') indice(`i')
			local sume       = r(gk)/`ng'
			matrix `init'    = nullmat(`init'), r(init)
			matrix `pesos'   = nullmat(`pesos'), `sume'
			local suma       = `suma' + `sume'
			matrix `atetmat' = nullmat(`atetmat'), r(muatt)
			return local cond`i' "`cond`i''" 
		}
		matrix `pesos' = `pesos'/`suma'
		matrix `wfin' = . 
		mata: st_matrix("`wfin'", sum((st_matrix("`pesos'")'):* 	///
			 (st_matrix("`kappa'")'):*(st_matrix("`atetmat'")'))/	///
			 sum((st_matrix("`pesos'")'):*(st_matrix("`kappa'")')))		
		matrix colnames `wfin' = "WATET"
		matrix `init' = `wfin',`init', `pesos'
		return scalar keq   = `k'
		return matrix kappa = `kappa'
		return local condall "`condall'"
	}

	return matrix init  = `init' 
	return local glev "`glev'"
end

program define _Init_Values0, rclass sortpreserve
	syntax [anything] [if][in]								///
					  [fweight iweight pweight aweight], 	///
					  [										///
					  estimator(string) 					///
					  pscore(string) 						///
					  xvars(string) 						///
					  treatvar(string)						///
					  groupvar(string)						///
					  lhs(string)							///
					  timevar(string)						///
					  csdid									///
					  gvar(string)							///
					  t0(string)							///
					  condt(string)							///
					  indice(integer 100)					///
					  ]

	marksample touse 

	if "`weight'" != "" {
		local wgt [`weight' `exp']
	}
	
	tempvar dy pscore wgt0 dyhat att pscore2 ynew consnew dyhat1 dyhat0	///
			sample0 sample1 samplet samplef timenew touse4 touse3
	tempname bps by init muw muatt b V by0 by1 bipw1 bipw0

	quietly generate double `touse3' = . 
	if ("`condt'"=="") {
	    local condt "`touse'"
	}
	quietly replace `touse3' = `touse' if `condt'
	quietly generate double `timenew' = `timevar' if `touse3'==1
	quietly summarize `timenew' if `touse'
	local time0 = r(min)
	bysort `groupvar' (`timenew'): egen `touse4' = min(`touse3')
	quietly replace `touse3' = `touse4'*`touse3'

	quietly bysort `groupvar' (`timenew'): ///
		generate double `dy'=`lhs'[2]-`lhs'[1] if `touse3'==1
		
	markout `touse' `dy' 	
	
	local pest logit 
	if ("`pscore'"=="probit") {
	    local pest probit
	}
	if ("`pscore'"=="imp"|"`estimator'"=="imp") {	
	    tempvar treatnew 
		generate double `treatnew' = `treatvar' 
		replace `treatnew' = 1 if `treatvar'>0 & `treatvar'!=.
		quietly mlexp ((`treatnew'>0)*{xb:`xvars' _cons}- ///
			(`treatnew'==0)*exp({xb:}) ) if `touse' & `timenew'==`time0' `wgt'			
		matrix `bps' = e(b)	
	}
	
	if ("`estimator'"=="dripw") {
		tempvar treatnew 
		generate double `treatnew' = `treatvar'
		replace `treatnew' = 1 if `treatvar'>0 & `treatvar'!=.
		quietly `pest' `treatnew' `xvars' if `touse' & `timenew'==`time0' `wgt'
		matrix `bps' = e(b)
		quietly predict double `pscore' if `touse', pr 
		quietly reg `dy' `xvars' if `treatvar'==0 & `touse' &	///
			`timenew'==`time0' `wgt'
		matrix `by' = e(b)
		quietly predict double `dyhat' if `touse'		
		quietly gen double `wgt0' = `pscore' * (1 - `treatnew')/(1 - `pscore')
		quietly mean `wgt0' `treatnew' if `touse' & `timenew'==`time0' `wgt'
		matrix `muw' = e(b)
		
		quietly generate double `att'= ///
			(`treatnew'/`muw'[1,2]-`wgt0'/`muw'[1,1])*(`dy'-`dyhat') ///
				if `touse' 

		quietly mean `att' if `touse' & `timenew'==`time0' `wgt'
		matrix `muatt' = e(b)
		
		matrix `init' = `muatt', `bps', `by', `muw'
	}
	if ("`estimator'"=="imp") {	
		quietly predictnl double `pscore2'=logistic(xb()) if `touse'
		quietly generate double `wgt0'=	///
			((`pscore2'*(1-`treatnew')))/(1-`pscore2')	if ///
				`touse' & `timenew'==`time0'
		quietly mean `wgt0' `treatnew' if `touse' `wgt'
		matrix `muw' = e(b)
		local k: list sizeof xvars
		local k = `k'
		quietly generate double `ynew'    = `dy'*sqrt(`wgt0')
		quietly generate double `consnew' = sqrt(`wgt0')
		forvalues i=1/`k' {
			local x: word `i' of `xvars'
			tempvar xvar`i' 
			quietly generate double `xvar`i'' = sqrt(`wgt0')*`x'
			local newvars "`newvars' `xvar`i''"
			local stripes "`stripes' `x'"
		}
		local newvars "`newvars' `consnew'"
		local stripes "`stripes' _cons"

		quietly regress `ynew' `newvars' 				///
			if (`treatvar'==0 & `timenew'==`time0' & `touse')	///
			`wgt', nocons

		matrix `by' = e(b)
		matrix colnames `by' = `stripes'
		quietly matrix score double `dyhat' = `by' if `touse'
		quietly generate double `att' =	///
			(`treatnew'/`muw'[1,2]-`wgt0'/`muw'[1,1])*(`dy'-`dyhat') if `touse'
		quietly mean `att' if `touse' & `timenew'==`time0' `wgt'
		matrix `muatt' = e(b)
		matrix `init' = `muatt', `bps', `by', `muw'	
	}
	if ("`estimator'"=="reg") {	
		quietly reg `dy' `xvars' if ///
			(`treatvar'==0 &`touse' & `timenew'==`time0')
		matrix `by0' = e(b)	
		quietly predict double `dyhat0' if `touse'
		quietly reg `dy' `xvars' if ///
			(`treatvar' & `touse' & `timenew'==`time0') `wgt'
		matrix `by1' = e(b)	
		quietly predict double `dyhat1' if `touse'
		quietly count if `touse' 
		local N = r(N)

		quietly count if `treatvar' & `touse'
		local tn = r(N)

		quietly generate double `att' =	///
			(`treatvar'>0)*(`dyhat1' - `dyhat0')*(`N'/`tn') if ///
				(`touse' & `timenew'==`time0')
		quietly mean `att' if `touse' `wgt'
		matrix `muatt' = e(b)
		matrix colnames `muatt' = ATET
 		matrix `init' = `muatt', `by1', `by0'	
	}
	if ("`estimator'"=="stdipw"|"`estimator'"=="aipw") {
	    tempvar treatnew tmean dynew
		generate double `treatnew' = `treatvar' 
		replace `treatnew' = 1 if `treatvar'>0 & `treatvar'!=.
		if ("`pscore'"!="imp") {
			quietly `pest' `treatnew' `xvars' if ///
				`touse' & `timenew'==`time0' `wgt'
			matrix `bps' = e(b)
			quietly predict double `pscore' if `touse', pr 			
		}
		else {
			quietly predictnl double `pscore'=logistic(xb()) if `touse'
		}
		if ("`estimator'"=="stdipw") {
				local tmd = 1 
		}
		else {
			summarize `treatnew' if `touse' & `timenew'==`time0', meanonly 
			local tmd = r(mean)
		}
		qui generate double `wgt0'    =	///
			((1-`treatnew')*`pscore'/((1-`pscore')*`tmd'))
		qui generate double `ynew'    = `dy'*sqrt(`wgt0')
		qui generate double `consnew' = sqrt(`wgt0')
		quietly regress `ynew' `consnew' if `touse'  & ///
			`timenew'==`time0' `wgt', nocons
		local stripes "_cons"
		matrix `by0' = e(b)
		matrix colnames `by0' = `stripes'
		quietly regress `dy' if (`treatnew' & `touse') `wgt'
		matrix `by1' = e(b)
		generate double `att' = . 
		scalar `bipw0' = `by0'[1,1]
		scalar `bipw1' = `by1'[1,1]
		if ("`estimator'"=="aipw") {
			replace `att'   = (`treatnew'/`tmd' -`wgt0')*`dy' if `touse'
			summarize `att' if `touse' & `timenew'==`time0', meanonly
			matrix `muatt'  = r(mean)
			matrix `init'   = `muatt', `bps', `tmd'
		}
		else {
			replace `att'   = `bipw1' - `bipw0' if `touse'
			matrix `muatt'  = `by1' - `by0'
			matrix `init'   = `muatt', `bps', `by1', `by0'
		}
	}
	if ("`estimator'"=="sipwra") {	
		tempvar cons 
	    tempvar treatnew 
		generate double `treatnew' = `treatvar' 
		replace `treatnew' = 1 if `treatvar'>0 & `treatvar'!=.
		if ("`pscore'"!="imp") {
			quietly `pest' `treatnew' `xvars' if	///
				`touse' & `timenew'==`time0' `wgt'
			matrix `bps' = e(b)
			quietly predict double `pscore' if `touse', pr 			
		}
		else {
			quietly predictnl double `pscore'=logistic(xb()) if `touse'
		}
		quietly generate double `wgt0' = 1.`treatnew' +	///
								 0.`treatnew'*`pscore'/(1-`pscore') if `touse'
		
		quietly fvexpand `xvars' if `touse'
		local xnew "`r(varlist)'"
		quietly generate double `cons' = sqrt(`wgt0')
		quietly generate double `ynew' = sqrt(`wgt0')*`dy'
		local k: list sizeof xnew
		forvalues i=1/`k' {
			tempvar wx`i'
			local x: word `i' of `xnew'
			quietly generate double `wx`i'' = `cons'*`x' if `touse'
			local newxvars "`newxvars' `wx`i''"
			local stripes "`stripes' `x'"
		}
		local stripes "`stripes' _cons"
		local newxvars "`newxvars' `cons'"
		quietly regress `ynew' `newxvars'	///
			if (`touse' & `treatnew'==0 & `timenew'==`time0') `wgt', nocons 
		matrix `by0' = e(b)
		quietly predict double `dyhat0' if `touse'
		quietly regress `ynew' `newxvars'	///
			if (`touse' & `treatnew'==1 & `timenew'==`time0') `wgt', nocons
		matrix `by1' = e(b)
		matrix colnames `by0' = `stripes'
		matrix colnames `by1' = `stripes'
		quietly predict double `dyhat1' if `touse'
		quietly generate double `att' = `dyhat1' - `dyhat0'
		quietly mean `att' 		///
			if (`touse' & `treatnew'==1 & `timenew'==`time0') `wgt'
		matrix `muatt' = e(b)
		matrix `init'   = `muatt', `bps', `by1', `by0'
	}
	
	quietly count if (`treatvar'>0 & `att'!=. & `touse')
	local gk = r(N)
	
	return matrix muatt = `muatt'
	return matrix init  = `init' 
	return scalar gk    = `gk'
end

program define _Eq_List_gmm, sclass 
	syntax [anything], [					///
					   xvars(string)		///
					   estimator(string) 	///
					   noCONstant 			///
					   csdid 				///
					   keq(integer 1)		///
					   ]	
	
	if ("`csdid'"=="") {
		if ("`estimator'"=="dripw"|"`estimator'"=="imp") {
			local eqlist "atet treatment outcome w0 w1"
			_Param_list, vars(`xvars') pnom(treatment) `constant'
			local parmt "`s(parmlist)'"
			_Param_list, vars(`xvars') pnom(outcome) `constant'
			local parmy "`s(parmlist)'"
			local parms "atet:_cons `parmt' `parmy' w0:_cons w1:_cons"
		}
		if ("`estimator'"=="reg") {
			local eqlist "atet outcome1 outcome0"
			_Param_list, vars(`xvars') pnom(outcome1) `constant'
			local parmy1 "`s(parmlist)'"
			_Param_list, vars(`xvars') pnom(outcome0) `constant'
			local parmy2 "`s(parmlist)'"
			local parmy "`parmy2'"
			local parms "atet:_cons `parmy1' `parmy2'"		
		}
		if ("`estimator'"=="stdipw") {
			local eqlist "atet treatment outcome1 outcome0"
			_Param_list, vars(`xvars') pnom(treatment) `constant'
			local parmy1 "`s(parmlist)'"
			_Param_list, vars(`xvars') pnom(outcome0) `constant'
			local parmy2 "`s(parmlist)'"
			local parmy "`parmy2'"
			local parms "atet:_cons `parmy1' outcome1:_cons outcome0:_cons "		
		}
		if ("`estimator'"=="sipwra") {
			local eqlist "atet treatment outcome1 outcome0"
			_Param_list, vars(`xvars') pnom(treatment) `constant'
			local parmy0 "`s(parmlist)'"
			_Param_list, vars(`xvars') pnom(outcome1) `constant'
			local parmy1 "`s(parmlist)'"
			_Param_list, vars(`xvars') pnom(outcome0) `constant'
			local parmy2 "`s(parmlist)'"
			local parmy "`parmy2'"
			local parms "atet:_cons `parmy0' `parmy1' `parmy2'"		
		}
		if ("`estimator'"=="aipw") {
			local eqlist "atet treatment meantreat"
			_Param_list, vars(`xvars') pnom(treatment) `constant'
			local parmy1 "`s(parmlist)'"
			if ("`repeated'"!="") {
				local eqlist "atet treatment meantreat meanttime"
			local parms ///
				"atet:_cons `parmy1'  meantreat:_cons meanttime:_cons"	
			}
			else {
				local parms "atet:_cons `parmy1'  meantreat:_cons"					
			}
		}
	}
	else {
		if ("`estimator'"=="reg") {
			forvalues i=1/`keq' {
			local eqlist`i' "atet`i' outcome1`i' outcome0`i'"
			_Param_list, vars(`xvars') pnom(outcome1`i') `constant'
			local parmy1`i' "`s(parmlist)'"
			_Param_list, vars(`xvars') pnom(outcome0`i') `constant'
			local parmy2`i' "`s(parmlist)'"
			local parmy`i' "`parmy2`i''"
			local parms`i' "atet`i':_cons `parmy1`i'' `parmy2`i''"
			local eqlist "`eqlist' `eqlist`i''"
			local parms "`parms' `parms`i''"
			local wtp  "`wtp' w`i':_cons"
			local wteq "`wteq' w`i'"
			}
			local eqlist "`eqlist' `wteq'"
			local parms  "`parms' `wtp'"
		}
		if ("`estimator'"=="dripw"|"`estimator'"=="imp") {
			forvalues i=1/`keq' {
				local eqlist`i' "atet`i' treatment`i' outcome`i' w0`i' w1`i'"
				_Param_list, vars(`xvars') pnom(treatment`i') `constant'
				local parmy1`i' "`s(parmlist)'"
				_Param_list, vars(`xvars') pnom(outcome`i') `constant'
				local parmy2`i' "`s(parmlist)'"
				local pparm `"`parmy1`i'' `parmy2`i'' w0`i':_cons w1`i':_cons"'
				local parms`i' "atet`i':_cons `pparm'"
				local eqlist "`eqlist' `eqlist`i''"
				local parms "`parms' `parms`i''"
				local wtp  "`wtp' wg`i':_cons"
				local wteq "`wteq' wg`i'"
			}
			local eqlist "`eqlist' `wteq'"
			local parms  "`parms' `wtp'"
		}
		local eqlist "watet `eqlist'"
		local parms "watet:_cons `parms'"
	}
	
	sreturn local parms "`parms'"
	sreturn local parmy "`parmy'"
	sreturn local parmt "`parmt'"
	sreturn local eqlist "`eqlist'"
end

program define _Eq_List_gmm_R, sclass 
	syntax [anything], [					///
					   xvars(string)		///
					   estimator(string) 	///
					   noCONstant 			///
					   csdid 				///
					   keq(integer 1)		///
					   ]	
	
	if ("`estimator'"=="aipw") {
		local eqlist "atet treatment meantreat meanttime"	
		_Param_list, vars(`xvars') pnom(treatment) `constant'
		local parmy1 "`s(parmlist)'"
		local parms "atet:_cons `parmy1'  meantreat:_cons meanttime:_cons"	
	}
	if ("`estimator'"=="dripw"|"`estimator'"=="imp") {
			local eqlist0 "atet treatment outcome00 outcome01 outcome10"
			local eqlist1 "outcome11 wt00 wt01 wt10 wt11 wt1"
			local eqlist "`eqlist0' `eqlist1'"
			_Param_list, vars(`xvars') pnom(treatment) `constant'
			local parmt "`s(parmlist)'"
			_Param_list, vars(`xvars') pnom(outcome00) `constant'
			local parmy00 "`s(parmlist)'"
			_Param_list, vars(`xvars') pnom(outcome01) `constant'
			local parmy01 "`s(parmlist)'"
			_Param_list, vars(`xvars') pnom(outcome10) `constant'
			local parmy10 "`s(parmlist)'"
			_Param_list, vars(`xvars') pnom(outcome11) `constant'
			local parmy11 "`s(parmlist)'"
			local parmsy "`parmy00' `parmy01' `parmy10' `parmy11'"
			local wts "wt00:_cons wt01:_cons wt10:_cons wt11:_cons wt1:_cons"
			local parms "atet:_cons `parmt' `parmsy' `wts'"		
	}
	if ("`estimator'"=="reg") {
			local eqlist "atet outcome00 outcome01 wt10 wt11 wt1"
			_Param_list, vars(`xvars') pnom(outcome00) `constant'
			local parmy00 "`s(parmlist)'"
			_Param_list, vars(`xvars') pnom(outcome01) `constant'
			local parmy11 "`s(parmlist)'"
			local parms ///
			  "atet:_cons `parmy00' `parmy11' wt10:_cons wt11:_cons wt1:_cons"	
	}	
	if ("`estimator'"=="stdipw") {
			local eqlist "atet treatment wt00 wt01 wt10 wt11"
			_Param_list, vars(`xvars') pnom(treatment) `constant'
			local parmt "`s(parmlist)'"
			local wts "wt00:_cons wt01:_cons wt10:_cons wt11:_cons"
			local parms "atet:_cons `parmt' `wts'"		
	}
	sreturn local parms "`parms'"
	sreturn local parmy "`parmy'"
	sreturn local parmt "`parmt'"
	sreturn local eqlist "`eqlist'"
end

program define _Parse_pscore
	capture syntax [anything], [probit logit imp]
	local rc = _rc
	if (`rc') {
		display as error "invalid {bf:pscore()}"
		display as txt "{p 4 4 2}"                           
		display as smcl as err ///
			"{bf:pscore()} should be one of {bf:probit}, "       ///
			"{bf:logit}, or {bf:imp}"      
			di as smcl as err  "{p_end}"
		exit `rc'
	}
	local muchos "`probit' `logit' `imp'"
	local k: list sizeof muchos
	if (`k'>1) {
		display as error ///
			"only one of {bf:probit}, {bf:logit}, or {bf:imp} is allowed"
		exit 198
	}
end

program define _Before_Var, rclass sortpreserve
	syntax [anything] [if] [in],				///
								[				///
								time(string) 	///
								gvar(string) 	///
								first(string) 	///
								before(string)]
	
	marksample touse 
	tempvar test test1
	tempname kappa 
	
	quietly {
		bysort `gvar' `time': generate double `test' = `time'[_n]	///
				if	(`touse' & `time'[_n]<`first'[_n])
		bysort `gvar': egen double `test1' = max(`test') if `touse' 
		replace	`before' = `test1' if `test1'!=. 
		levelsof `first' if `first'>0  & `touse', local(glev)
		local k = r(r)
	}
	forvalues i = 1/`k' {
	    local x: word `i' of `glev'
		quietly levelsof `time' if `time'<`x', local(tvar0)
		quietly levelsof `time' if `time'>`x', local(tvar1)
		summarize `before' if `first'==`x', meanonly 
		local antes`i' "`r(mean)'"
		local tvarf`i' "`tvar0' `tvar1'"
	}
	local kparm = 0 
	forvalues i=1/`k' {
		local x: word `i' of `glev'
		local w: list sizeof tvarf`i'
		local cond "inlist(`first', 0, `x')"
			forvalues j=1/`w' {
				local y: word `j' of `tvarf`i''
				local j2 = `j' + 1 
				local y2 = 0 
				local y0: word `j2' of `tvarf`i''
				if ("`y0'"!="") {
				    local y2 = `y0'
				}
				if (`y'<`x' & `y2'<`x' & `y2'!=0) {
					local cond`i'`j' "inlist(`time', `y', `y2') & `cond'"
					local colnames `"`colnames' `x':"ATET(`y',`y2')""'
					matrix `kappa' = nullmat(`kappa'), 0
				}
				if (`y'<`x' & (`y2' >`x'|`y2'==0)) {
					local cond`i'`j' "inlist(`time', `y', `x') & `cond'"
					local colnames `"`colnames' `x':"ATET(`y',`x')""'
					matrix `kappa' = nullmat(`kappa'), 1
				}
				if (`y'>`x') {
					matrix `kappa' = nullmat(`kappa'), 1
					local cond`i'`j' "inlist(`time', `y', `antes`i'') & `cond'"
					local colnames `"`colnames' `x':"ATET(`antes`i'',`y')""'
				}		
				local kparm = `kparm' + 1 
				local condall `"`condall' "`cond`i'`j''""'
				return local cond`kparm' "`cond`i'`j''"				
			}
	}
	return local condall "`condall'"
	return scalar kparm = `kparm'
	return matrix kappa = `kappa'
	return local glev "`glev'"
    return local colnames "`colnames'"
end 

program define _Instrument_names, sclass 
	syntax [anything], [csdid					///
						keq(integer 1)			///
						estimator(string) 		///
						xvars(string)			///
						repeated]
	
	if ("`estimator'"=="imp"|"`estimator'"=="dripw") {
		local gmmest "dripw"
		if ("`estimator'"=="imp") {
			local pscore "imp"
		}
		if ("`csdid'"=="") {
			local eq1 "treatment"
			local eq2 "outcome"
		}
		else {
			forvalues i=1/`keq' {
				local eq1`i' "treatment`i'"
				local eq2`i' "outcome`i'"
				local equno `"instruments(`eq1`i'':`xvars', `constant')"'
				local eqdos `"instruments(`eq2`i'':`xvars', `constant')"'
				local eqtwo `"`eqtwo' `equno' `eqdos'"'				
			}
		}
	}
	if ("`estimator'"=="reg") {
		local reg "reg"
		local gmmest regipw	
		if ("`csdid'"=="") {
			local eq1 "outcome1"
			local eq2 "outcome0"
		}
		else {
			forvalues i=1/`keq' {
				local eq1`i' "outcome1`i'"
				local eq2`i' "outcome0`i'"
				local equno `"instruments(`eq1`i'':`xvars', `constant')"'
				local eqdos `"instruments(`eq2`i'':`xvars', `constant')"'
				local eqtwo `"`eqtwo' `equno' `eqdos'"'
			}
		}
	}	
	if ("`csdid'"=="") {
		local eqzero `"instruments(`eq1':`xvars', `constant')"'	
		local eqtwo `"`eqzero' instruments(`eq2': `xvars', `constant')"'					
	}
						
	if ("`estimator'"=="stdipw") {
		local reg "stdipw"
		local gmmest regipw		
		local eq1 "treatment"
		local eqtwo instruments(`eq1':`xvars', `constant')
	}
	
	if ("`estimator'"=="aipw") {
		local reg "aipw"
		if ("`repeated'"=="") {
			local gmmest dripw	
		}
		else {
			local gmmest repeated
		}
		local eq1 "treatment"
		local eqtwo instruments(`eq1':`xvars', `constant')
	}
	
	if ("`estimator'"=="sipwra") {
		local reg "ipwra"
		local gmmest regipw
		local eq1 "treatment"
		local eq2 "outcome1"
		local eq3 "outcome0"
		local eqtwo 		instruments(`eq1':`xvars', `constant')		///
							instruments(`eq2': `xvars', `constant')		///
							instruments(`eq3': `xvars', `constant')
	}
	sreturn local gmmest "`gmmest'"
	sreturn local reg "`reg'"
	sreturn local eqtwo "`eqtwo'"
end 

program define _Instrument_names_R, sclass 
	syntax [anything], [csdid					///
						keq(integer 1)			///
						estimator(string) 		///
						xvars(string)			///
						repeated]
	
	local reg "`estimator'"
	if ("`estimator'"=="imp"|"`estimator'"=="dripw") {
		local gmmest "repeated"
		if ("`estimator'"=="imp") {
			local pscore "imp"
		}
			local eq1 "treatment"
			local eq2 "outcome00"
			local eq3 "outcome01"
			local eq4 "outcome10"
			local eq5 "outcome11"
			local eqtwo 	instruments(`eq1':`xvars', `constant')		///
							instruments(`eq2': `xvars', `constant')		///
							instruments(`eq3': `xvars', `constant')		///
							instruments(`eq4': `xvars', `constant')		///
							instruments(`eq5': `xvars', `constant')				
	}	
					
	if ("`estimator'"=="aipw") {
		local reg "aipw"
		local gmmest repeated
		local eq1 "treatment"
		local eqtwo instruments(`eq1':`xvars', `constant')
	}
	
	if ("`estimator'"=="reg") {
		local reg "reg"
		local gmmest repeated
			local eq1 "outcome00"
			local eq2 "outcome01"
			local eqtwo 	instruments(`eq1':`xvars', `constant')		///
							instruments(`eq2': `xvars', `constant')		
	}
	if ("`estimator'"=="stdipw") {
		local reg "stdipw"
		local gmmest repeated
		local eq1 "treatment"
		local eqtwo instruments(`eq1':`xvars', `constant')		
	}
	
	sreturn local gmmest "`gmmest'"
	sreturn local reg "`reg'"
	sreturn local eqtwo "`eqtwo'"
end 

program _Init_Values_R, rclass sortpreserve
	syntax [anything] [if][in]								///
					  [fweight iweight pweight aweight], 	///
					  [										///
					  estimator(string) 					///
					  pscore(string) 						///
					  xvars(string) 						///
					  treatvar(string)						///
					  lhs(string)							///
					  timevar(string)						///
					  gvar(string)							///
					  csdid									///
					  t0(string)							///
					  *										///
					  ]
	marksample touse 

	tempvar  psc w11 w10 w01 w00 treatnew touse3 tmt y11 y10 y00 y01	///
			 timenew att yh11 yh10 yh00 yh01 yh0 y_1c y11c y_0c y10c w1	///
			 w0 
	tempname pi lambda atet bt init

	generate double `treatnew' = `treatvar' 
	replace `treatnew' = 1 if `treatvar'>0 & `treatvar'!=.
	
	quietly generate double `touse3' = . 
	
	if ("`condt'"=="") {
	    local condt "`touse'"
	}
	quietly replace `touse3' = `touse' if `condt'
	quietly generate double `timenew' = `timevar' if `touse3'==1
	
	quietly summarize `timenew' if `touse'
	local time0 = r(max)
	
	generate double `tmt'=`timenew'==`time0' if `touse'
	
	if "`weight'" != "" {
		local wgt [`weight' `exp']
	}
	
	if ("`pscore'"!="imp" & "`estimator'"!="reg") {
		if ("`pscore'"=="") {
			logit `treatnew' `xvars' if `touse' `wgt'
		}
		else {
			probit `treatnew' `xvars' if `touse' `wgt'			
		}
		predict double `psc' if `touse'
		matrix `bt' = e(b)
	}
	
	if ("`pscore'"=="imp"|"`estimator'"=="imp") {	
		quietly mlexp ((`treatnew'>0)*{xb:`xvars' _cons}- ///
			(`treatnew'==0)*exp({xb:}) ) if `touse' `wgt'	
		quietly predictnl double `psc'=logistic(xb()) if `touse'
		matrix `bt' = e(b)	
	}
	
	if ("`estimator'"=="aipw") {
		generate double `w11' = `treatnew'*(`tmt')
		generate double `w10' = `treatnew'*(1-`tmt')
		generate double `w01' = `psc'*(1-`treatnew')*(`tmt')/(1-`psc')
		generate double `w00' = `psc'*(1-`treatnew')*(1-`tmt')/(1-`psc')

		mean   `treatnew' if `touse' `wgt'
		scalar `pi'         =  e(b)[1,1]
		mean   `tmt' if `touse' `wgt'
		scalar `lambda'		=  e(b)[1,1]

		generate double `y11' = `w11'*`lhs'/(`pi'*`lambda')
		generate double `y10' = `w10'*`lhs'/(`pi'* (1-`lambda') )
		generate double `y01' = `w01'*`lhs'/(`pi'*`lambda' )
		generate double `y00' = `w00'*`lhs'/(`pi'* (1-`lambda') )
		
		generate double `att' = (`y11'-`y10')-(`y01'-`y00')
		mean `att' if `touse' `wgt'
		scalar `atet' = e(b)[1,1]
		matrix `init' = `atet', `bt', `pi', `lambda'
	}
	
	if ("`estimator'"=="dripw") {
		tempname b00 b01 b10 b11 
		
		reg `lhs' `xvars' if `treatnew'==0 & `tmt'==0 & `touse' `wgt'
		predict double `yh00' if `touse'
		matrix `b00' = e(b)
	 
		reg `lhs' `xvars' if `treatnew'==0 & `tmt'==1 & `touse' `wgt'
		predict double `yh01' if `touse'
		matrix `b01' = e(b)
	 
		reg `lhs' `xvars' if `treatnew'==1 & `tmt'==0 & `touse' `wgt'
		predict double `yh10' if `touse'
		matrix `b10' = e(b)
	 
		reg `lhs' `xvars' if `treatnew'==1 & `tmt'==1 & `touse' `wgt'
		predict double `yh11' if `touse'
		matrix `b11' = e(b)
		
		generate double `yh0' = `yh00'*(1-`tmt')+ `yh01'*`tmt'
		
		generate double `w11'= `treatnew'*(`tmt')
		generate double `w10'= `treatnew'*(1-`tmt')
		generate double `w01'= `psc'*(1-`treatnew')*(`tmt')/(1-`psc')
		generate double `w00'= `psc'*(1-`treatnew')*(1-`tmt')/(1-`psc')
		generate double `w1' = `treatnew'
		
		foreach i in `w00' `w01' `w10' `w11' `w1' {
			tempname b`i'
			summarize `i', meanonly 
			replace `i'=`i'/r(mean)
			matrix `b`i'' = r(mean)
		}
		
		generate double `y10' = `w10'*(`lhs' - `yh0')
		generate double `y11' = `w11'*(`lhs' - `yh0')
		generate double `y00' = `w00'*(`lhs' - `yh0')
		generate double `y01' = `w01'*(`lhs' - `yh0')
		
		generate double `y_1c' = `w1'*(`yh11' - `yh01')
		generate double `y11c' = `w11'*(`yh11' - `yh01')
		generate double `y_0c' = `w1'*(`yh10' - `yh00')
		generate double `y10c' = `w10'*(`yh10' - `yh00')
		
		generate double `att'   =  (`y11' - `y10')  - (`y01' - `y00')		///
								 + (`y_1c' - `y11c') - (`y_0c' - `y10c') 
					
		mean `att' if `touse' `wgt'
		scalar `atet' = e(b)[1,1]	
		matrix `init' = `atet', `bt', `b00', `b01', `b10', `b11', ///
						`b`w00'', `b`w01'', `b`w10'', `b`w11'', `b`w1''
	}
	
	if ("`estimator'"=="imp") {
		tempname b00 b01 b10 b11 ynew consnew
		
		generate double `w11'= `treatnew'*(`tmt')
		generate double `w10'= `treatnew'*(1-`tmt')
		generate double `w01'= `psc'*(1-`treatnew')*(`tmt')/(1-`psc')
		generate double `w00'= `psc'*(1-`treatnew')*(1-`tmt')/(1-`psc')
		generate double `w1' = `treatnew'
		generate double `w0' = `psc' * (1-`treatnew') / (1-`psc')
		
		local k: list sizeof xvars
		local k = `k'
		quietly generate double `ynew'    = `lhs'*sqrt(`w0')
		quietly generate double `consnew' = sqrt(`w0')
		forvalues i=1/`k' {
			local x: word `i' of `xvars'
			tempvar xvar`i' 
			quietly generate double `xvar`i'' = sqrt(`w0')*`x'
			local newvars "`newvars' `xvar`i''"
			local stripes "`stripes' `x'"
		}
		local newvars "`newvars' `consnew'"
		local stripes "`stripes' _cons"
		reg `ynew' `newvars' if 	///
			`treatnew'==0 & `tmt'==0 & `touse' `wgt', nocons  
		matrix `b00' = e(b)
		matrix colnames `b00' = `stripes'
		matrix score double `yh00' = `b00' if `touse'
		
		reg `ynew' `newvars' if 	///
			`treatnew'==0 & `tmt'==1 & `touse' `wgt', nocons
		matrix `b01' = e(b)
		matrix colnames `b01' = `stripes'
		matrix score double `yh01' = `b01' if `touse'
	 
		reg `lhs' `xvars' if `treatnew'==1 & `tmt'==0 & `touse' `wgt'
		predict double `yh10' if `touse'
		matrix `b10' = e(b)
	 
		reg `lhs' `xvars' if `treatnew'==1 & `tmt'==1 & `touse' `wgt'
		predict double `yh11' if `touse'
		matrix `b11' = e(b)
		
		generate double `yh0' = `yh00'*(1-`tmt')+ `yh01'*`tmt'
		
		foreach i in `w00' `w01' `w10' `w11' `w1' {
			tempname b`i'
			summarize `i', meanonly 
			replace `i'=`i'/r(mean)
			matrix `b`i'' = r(mean)
		}
		
		generate double `y10' = `w10'*(`lhs' - `yh0')
		generate double `y11' = `w11'*(`lhs' - `yh0')
		generate double `y00' = `w00'*(`lhs' - `yh0')
		generate double `y01' = `w01'*(`lhs' - `yh0')
		
		generate double `y_1c' = `w1'*(`yh11' - `yh01')
		generate double `y11c' = `w11'*(`yh11' - `yh01')
		generate double `y_0c' = `w1'*(`yh10' - `yh00')
		generate double `y10c' = `w10'*(`yh10' - `yh00')
		
		generate double `att'   =  (`y11' - `y10')  - (`y01' - `y00')		///
								 + (`y_1c' - `y11c') - (`y_0c' - `y10c') 
					
		mean `att' if `touse' `wgt'
		scalar `atet' = e(b)[1,1]	
		matrix `init' = `atet', `bt', `b00', `b01', `b10', `b11', ///
						`b`w00'', `b`w01'', `b`w10'', `b`w11'', `b`w1''
	}
	
	if ("`estimator'"=="reg") {
		tempname b00 b01 		
		reg `lhs' `xvars' if `treatnew'==0 & `tmt'==0 & `touse' `wgt'
		predict double `yh00' if `touse'
		matrix `b00' = e(b)
	 
		reg `lhs' `xvars' if `treatnew'==0 & `tmt'==1 & `touse' `wgt'
		predict double `yh01' if `touse'
		matrix `b01' = e(b)		
		
		generate double `w10'= `treatnew'*(1-`tmt')
		generate double `w11'= `treatnew'*(`tmt')
		generate double `w1' = `treatnew'
		
		foreach i in  `w10' `w11' `w1' {
			tempname b`i'
			summarize `i', meanonly 
			replace `i'=`i'/r(mean)
			matrix `b`i'' = r(mean)
		}
		
		generate double `y11' = `w11'*(`lhs')
		generate double `y10' = `w10'*(`lhs')
		generate double `y01' = `w1'*(`yh01')
		generate double `y00' = `w1'*(`yh00')
		generate double `att'   =  (`y11' - `y10')  - (`y01' - `y00')	
		mean `att' if `touse' `wgt'
		scalar `atet' = e(b)[1,1]	
		matrix `init' = `atet', `b00', `b01', `b`w10'', `b`w11'', `b`w1''
	}
	
	if ("`estimator'"=="stdipw") {
		generate double `w11'= `treatnew'*(`tmt')
		generate double `w10'= `treatnew'*(1-`tmt')
		generate double `w01'= `psc'*(1-`treatnew')*(`tmt')/(1-`psc')
		generate double `w00'= `psc'*(1-`treatnew')*(1-`tmt')/(1-`psc')
		generate double `w1' = `treatnew'
		
		foreach i in `w00' `w01' `w10' `w11' {
			tempname b`i'
			summarize `i', meanonly 
			replace `i'=`i'/r(mean)
			matrix `b`i'' = r(mean)
		}
		generate double `att' = (`w11'*`lhs' - `w10'*`lhs')	-	///
								(`w01'*`lhs' - `w00'*`lhs')
		mean `att' if `touse' `wgt'
		scalar `atet' = e(b)[1,1]	
		matrix `init' = `atet', `bt', `b`w00'', `b`w01'', `b`w10'',	`b`w11''
	}
	
	return matrix init = `init'
end
