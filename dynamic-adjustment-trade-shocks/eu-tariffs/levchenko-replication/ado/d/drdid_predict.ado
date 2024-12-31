 *! v0.2 fixed minibug with varname anything
 * v0.1 fixed minibug with time treatment (TR and T)
 program drdid_predict
	syntax newvarname [if] [in], [weight pscore]  
	if !inlist("`e(method)'","drimp","dripw","aipw","ipw","stdipw") {
		display as error "IPW/IPT Weights cannot be estimated"
		exit
	}
	if "`weight'`pscore'"==""  {
		local weight weight
	}
	
	if "`e(datatype)'"=="panel" {
		_parser_drdid `e(cmdline)'
		local tvr `s(tvr)'
		local trvr `s(trvr)'
		local mint `s(mint)'
		local maxtr `s(maxtr)'
		capture confirm matrix e(ipwb)
		tempvar scr pr wgt
		tempname tempscore
		if _rc!=0 	matrix `tempscore'=e(iptb) 
			else    matrix `tempscore'=e(ipwb) 
		matrix score `scr'=`tempscore' if e(sample) & `tvr'==`mint'
		qui: gen double `pr'=logistic(`scr')

		qui: gen double `wgt'=`pr'/(1-`pr') if e(sample) & `tvr'==`mint' 
		qui: replace    `wgt'= 1 		   if `wgt'!=. & `trvr'==`maxtr'
	}
	else {
		_parser_drdid `e(cmdline)'
		local tvr `s(tvr)'
		local trvr `s(trvr)'
		local mint `s(mint)'
		local maxtr `s(maxtr)'
		capture confirm matrix e(ipwb)
		tempvar scr pr wgt
		tempname tempscore
		if _rc!=0 	matrix `tempscore'=e(iptb) 
			else    matrix `tempscore'=e(ipwb) 
		matrix score `scr'=`tempscore' if e(sample) 
		qui: gen double `pr'=logistic(`scr')
 
		qui: gen  double   `wgt'=`pr'/(1-`pr') if e(sample) 
		qui: replace       `wgt'= 1    if `wgt'!=. & `trvr'==`maxtr'
	}

	if "`weight'"!="" {
		syntax newvarname [if] [in] [, * ]
		qui:gen `typelist' `anything' = `wgt'
		label var `anything' "IPW/IPT weights"
	}
	else {
		qui:gen `typelist' `varlist' = `pr'
		label var `varlist' "Propensity score"
	}
end

 
program _parser_drdid , sclass
	syntax anything(everything) , [* Time(str) TReatment(str)]
	sum `time' if e(sample)==1, meanonly
	sreturn local mint = r(min)
	sreturn local tvr   `time'
	sum `treatment'   if e(sample)==1, meanonly
	sreturn local maxtr = r(max)
	sreturn local trvr   `treatment'
	
end
