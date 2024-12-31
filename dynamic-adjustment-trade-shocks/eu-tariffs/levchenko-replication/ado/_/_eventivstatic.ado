version 11.2

cap program drop _eventivstatic
program define _eventivstatic, rclass
	#d;
	syntax varlist(fv ts numeric) [aw fw pw] [if] [in], /* Covariates go in varlist. Can add fv ts later */
	Panelvar(varname) /* Panel variable */
	Timevar(varname) /* Time variable */
	POLicyvar(varname) /* Policy variable */	
	proxy (varlist numeric) /* Proxy variable(s) */
	[
	proxyiv(string) /* Instruments. Either numlist with lags or varlist with names of instrumental variables */
	nofe /* No fixed effects */
	note /* No time effects */	
	reghdfe /* Use reghdfe for estimation */
	addabsorb(string) /* Absorb additional variables in reghdfe */ 
	impute(string)
	STatic
	*
	]
	;
	#d cr
	
	marksample touse
	
	tempvar kg
	* kg grouped event time, grouping outside window
	
	tempname delta Vdelta bb VV bb2 VV2 delta2 Vdelta2 deltay Vdeltay deltax Vdeltax deltaxsc bby bbx VVy VVx 
	* bb delta coefficients
	* VV variance of delta coefficients
	* bb2 delta coefficients for overlay plot
	* VV2 variance of delta coefficients for overlay plot
	* delta2 included cefficientes in overlaty plot
	* VVdelta2 variance of included delta coefficients in overlay plot
	
	loc i = "`panelvar'"
	loc t = "`timevar'"
	loc z = "`policyvar'"
	
	*call _eventgenvars to impute z
	if "`impute'"!="" {
		*tempvar to be imputed
		tempvar rr
		qui gen double `rr'=.
		
	_eventgenvars if `touse', panelvar(`panelvar') timevar(`timevar') policyvar(`policyvar') impute(`impute') `static' rr(`rr')
		
		loc impute=r(impute)
		if "`impute'"=="." loc impute = ""
		loc saveimp=r(saveimp)
		if "`saveimp'"=="." loc saveimp = ""
		*if imputation succeeded:
		if "`impute'"!="" {
			if "`saveimp'"=="" {
				tempvar zimp
				qui gen double `zimp'=`rr'
				lab var `zimp' "`policyvar'_imputed"
				loc z "`zimp'"
			}
			else loc z = "`policyvar'_imputed"
		}
		else loc z = "`policyvar'"
	}

	loc leads : word count `proxy'
	if "`proxyiv'"=="" & `leads'==1 loc proxyiv "select"
	
	* If proxy specified but no proxyiv, assume numlist for leads of policyvar
	if "`proxyiv'"=="" {
		di _n "No proxy instruments specified. Using leads of policy variables as instruments."
		loc leads : word count `proxy'		
		forv j=1(1)`leads' {
			loc proxyiv "`proxyiv' `j'"
		}
	}
	
	* IV selection if proxyiv = selection
	else if "`proxyiv'"=="select" {
		* Only for one proxy case 		
		if `leads'>1 {
			di as err "Proxy instrument selection only available for the one proxy - one instrument case"
			exit 301
		}
		else {
			di as text _n "proxyiv=select. Selecting lead order of differenced policy variable to use as instrument."
			loc Fstart = 0
			* Here I test up to 5
			forv v=1(1)5 {
				tempvar _fd`v'`z'
				qui gen double `_fd`v'`z'' = f`v'.d.`z' if `touse'
				cap qui reg `proxy' `_fd`v'`z'' [`weight'`exp'] if `touse'
				if !_rc loc Floop = e(F)
				if `Floop' > `Fstart' {
					loc Fstart = `Floop'
					loc proxyiv "`v'"				
				}			
			}
			di as text _n "Lead `proxyiv' selected."
		}
		
	}
	
	* Parse proxyiv and generate leads if neccesary
	loc rc=0
	foreach v in `proxyiv' {
		cap confirm integer number `v'
		loc rc = `rc' + _rc
	}
	* If numlist take as leads of z
	if `rc' == 0 {
		loc insvars ""
		foreach v in `proxyiv' {
			qui gen double _f`v'`z' = f`v'.`z' if `touse'			
			loc insvars "`insvars' _f`v'`z'"
		}
		loc instype = "numlist"
	}
	else {
		foreach v in `proxyiv' {
			confirm numeric variable `v'
		}
		loc insvars = "`proxyiv'"
	}

	if "`te'" == "note" loc tte ""
	else loc tte "i.`t'"
		
	* Main regression
	
	if "`reghdfe'"=="" {
		if "`fe'" == "nofe" {
		loc cmd "ivregress 2sls"
		loc ffe ""
		}
		else {
			loc cmd "xtivreg"
			loc ffe "fe"
		}		
		`cmd' `varlist' (`proxy' = `insvars') `z' `tte' [`weight'`exp'] if `touse' , `ffe' `options'
	}
	else {
		loc noabsorb "" 
		*absorb nothing
		if "`fe'" == "nofe" & "`tte'"=="" & "`addabsorb'"=="" {
			*loc noabsorb "noabsorb"
			/*the only option ivreghdfe inherits from reghdfe is absorb, therefore it doesn't support noabsorb. In contrast with reghdfe, ivreghdfe doesn't require noabsorb when absorb is not specified*/ 
			loc abs ""
		}
		*absorb only one
		else if "`fe'" == "nofe" & "`tte'"=="" & "`addabsorb'"!="" {
			loc abs "absorb(`addabsorb')"
		}
		else if "`fe'" == "nofe" & "`tte'"!="" & "`addabsorb'"=="" {						
			loc abs "absorb(`t')"
		}
		else if "`fe'" != "nofe" & "`tte'"=="" & "`addabsorb'"=="" {						
			loc abs "absorb(`i')"
		}
		*absorb two
		else if "`fe'" == "nofe" & "`tte'"!="" & "`addabsorb'"!="" {						
			loc abs "absorb(`t' `addabsorb')"
		}
		else if "`fe'" != "nofe" & "`tte'"=="" & "`addabsorb'"!="" {						
			loc abs "absorb(`i' `addabsorb')"
		}
		else if "`fe'" != "nofe" & "`tte'"!="" & "`addabsorb'"=="" {						
			loc abs "absorb(`i' `t')"
		}
		*absorb three
		else if "`fe'" != "nofe" & "`tte'"!="" & "`addabsorb'"!="" {						
			loc abs "absorb(`i' `t' `addabsorb')"
		}
		*
		else {
			loc abs "absorb(`i' `t' `addabsorb')"	
		}
		
		*analyze inclusion of vce in options
		loc vce_y= strmatch("`options'","*vce(*)*")
		
		*if user did not specify vce option 
		if "`vce_y'"=="0" { 
		ivreghdfe `varlist' (`proxy' = `insvars') `z' [`weight'`exp'] if `touse', `abs' `noabsorb' `options'
		}
		*if user did specify vce option
		else {  
			*find start and end of vce text 
			loc vces=strpos("`options'","vce(")
			loc vcef=0
			loc ocopy="`options'"
			while `vcef'<`vces' {
				loc vcef=strpos("`ocopy'", ")")
				loc ocopy=subinstr("`ocopy'",")", " ",1)
			}
			*substrac vce words
			loc svce_or=substr("`options'",`vces',`vcef')
			loc vce_len=strlen("`svce_or'")
			loc svce=substr("`svce_or'",5,`vce_len'-5)
			loc svce=strltrim("`svce'")
			loc svce=strrtrim("`svce'")
			*inspect whether vce contains bootstrap or jackknife
			loc vce_bt= strmatch("`svce'","*boot*")
			loc vce_jk= strmatch("`svce'","*jack*")
			if `vce_bt'==1 | `vce_jk'==1 {
				di as err "Options {bf:bootstrap} and {bf:jackknife} are not allowed"
				exit 301
			}
			
			*if vce contains valid options, parse those options
			*erase vce from original options
			loc options_wcve=subinstr("`options'","`svce_or'"," ",1)
			*** parse vce(*) ****
			loc vce_wc=wordcount("`svce'")
			tokenize `svce'
			*extract vce arguments 
			*robust 
			loc vce_r= strmatch("`svce'","*robust*")
			loc vce_r2=0
			forv i=1/`vce_wc'{
				loc zz= strmatch("``i''","r")
				loc vce_r2=`vce_r2'+`zz'
			}
			if `vce_r'==1 | `vce_r2'==1 {
				loc vceop_r="robust"
			}
			*cluster
			loc vce_c= strmatch("`svce'","*cluster*")
			loc vce_c2= strmatch("`svce'","*cl*")
			if `vce_c'==1 | `vce_c2'==1 {
				forv i=1/`vce_wc'{
					loc vce_r2= strmatch("``i''","*cl*")
					if `vce_r2'==1 {
						loc j=`i'+1
						}
				}
				loc vceop_c="cluster(``j'')"
			}
			ivreghdfe `varlist' (`proxy' = `insvars') `z' [`weight'`exp'] if `touse', `abs' `noabsorb' `options_wcve' `vceop_r' `vceop_c'
		}

	}	
	
	
	mat `bb' = e(b)
	mat `VV' = e(V)
	mat `delta'=e(b)
	mat `Vdelta'=e(V)	
	
	* Drop variables
	
	if "`instype'"=="numlist" {
		foreach v in `proxyiv' {
			drop _f`v'`z' 
		}
	}
	
	tokenize `varlist'
	loc depvar "`1'"
	
	return matrix b = `bb'
	return matrix V = `VV'
	return matrix delta = `delta'
	return matrix Vdelta = `Vdelta'
	loc names: subinstr global names ".." " ", all
	loc names: subinstr local names `"""' "", all
	return local names = "`names'"	
	return local cmd = "`cmd'"
	return local depvar = "`depvar'"
		
end
