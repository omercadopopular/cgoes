* xtevent.ado 2.1.0 Aug 1 2022

version 11.2

cap program drop xtevent
program define xtevent, eclass

	* Replay routine
	if replay() {
		if "`e(cmd2)'"!="xtevent" exit 301
		else {
			loc rep = e(cmd)
			`rep'
		}
		exit
	}

	#d;
	syntax varlist(fv ts numeric) [aw fw pw] [if] [in] , /* Proxy for eta and covariates go in varlist. Can add fv ts later */	
	POLicyvar(varname) /* Policy variable */	
	[
	Window(numlist min=1 max=2 integer) /* Estimation window */
	pre(numlist >=0 min=1 max=1 integer) /* Pre-event time periods where anticipation effects are allowed */
	post(numlist >=0 min=1 max=1 integer) /* Post-event time periods where dynamic effects are allowed */
	overidpre(numlist >=0 min=1 max=1 integer) /* Pre-event time periods for overidentification */
	overidpost(numlist >=0 min=1 max=1 integer) /* Post-event time periods for overidentification */
	Panelvar(varname) /* Panel variable */
	Timevar(varname) /* Time variable */
	proxyiv(string) /* Instruments. For FHS set ins equal to leads of the policy */
	proxy (varlist numeric) /* Proxy variable */		
	TRend(string) /*trend(a -1) Include a linear trend from time a to -1. Method can be either GMM or OLS*/
	SAVek(string) /* Generate the time-to-event dummies, trend and keep them in the dataset */
	STatic /* Estimate static model */			
	reghdfe /* Estimate with reghdfe */
	addabsorb(string) /* Absorb additional variables in reghdfe */
	norm(integer -1) /* Normalization */
	plot /* Produce plot */
	*
	/*
	These options passed to subcommands
	
	nofe /* No fixed effects */
	note /* No time effects */
	Kvars(string) /* Use previously generated dummies */
	impute(string) /* impute policyvar */
		
	*/
	]
	;
	#d cr

	
	
	* Capture errors
	
	if "`addabsorb'"!="" & "`reghdfe'"=="" {
		di as err "option {bf:addabsorb} only allowed with option {bf:reghdfe}"
		exit 198
	}	

	if "`proxy'" == "" & "`proxyiv'" != "" {
		di as err _n "With instruments, you must specify a proxy variable"
		exit 198
	}
	
	* If xtset, don't need panelvar and timevar	
	cap xtset
	if _rc==459 {
		if "`panelvar'"=="" & "`timevar'"!="" | "`panelvar'"!="" & "`timevar'"=="" | "`panelvar'"=="" & "`timevar'"=="" {
			di as err _n "If data have not been xtset, you must specify options {bf:panelvar} and {bf:timevar}"
			exit 198
		}
	}
	else if ("`panelvar'"!="" & "`panelvar'"!=r(panelvar)) | ("`timevar'"!="" & "`timevar'"!=r(timevar)) {
		di as err _n "Data have been xtset, and you specified options {bf:panelvar} or {bf:timevar} with variables different from those previously set. Run {cmd:xtset,clear}  or {cmd:xtset} your data again"
		exit 198
	}
	else if ("`panelvar'"=="" & "`timevar'"=="") | ("`panelvar'"!="" & "`timevar'"=="") | ("`panelvar'"=="" & "`timevar'"!="")  {
		di as txt _n "Using options {bf:panelvar} and {bf:timevar} from {cmd:xtset}"
		loc panelvar=r(panelvar)
		loc timevar=r(timevar)
	}

	if "`trend'"!="" & "`proxy'"!="" {
		di as err _n "options {bf:proxy} and {bf:trend} not allowed simultaneously"
		exit 198
	}
	
	if "`trend'"!="" & "`static'"!="" {
		di as err _n "options {bf:static} and {bf:trend} not allowed simultaneously"
		exit 198
	}
		
	* Always need window unless static is specified
	if "`window'"=="" & ("`static'"=="" & ("`pre'"=="" | "`post'"=="" | "`overidpre'"=="" | "`overidpost'"=="")) {
		di as err _n "option {bf:window} is required unless option {bf:static}, or options {bf:pre},{bf:post},{bf:overidpre}, and {bf:overidpost} are specified"
		exit 198
	}
	if "`window'"!="" & "`static'"!="" {
		di as err _n "option {bf:window} not allowed with option {bf:static}"
		exit 198
	}
	if "`window'"!="" & ("`static'"!="" | ("`pre'"!="" | "`post'"!="" | "`overidpre'"!="" | "`overidpost'"!="")) {
		di as err _n "option {bf:window} not allowed with options {bf:static},{bf:pre},{bf:post},{bf:overidpre}, or {bf:overidpost}"
		exit 198
	}
	if ("`static'"!="" & ("`pre'"!="" | "`post'"!="" | "`overidpre'"!="" | "`overidpost'"!="")) {
		di as err _n "option {bf:static} not allowed with options {bf:static},{bf:pre},{bf:post},{bf:overidpre}, or {bf:overidpost}"
		exit 198
	}
			
	if "`savek'"=="_k" {
		di as err _n "_k reserved for internal variables. Please choose a different stub"
		exit 198
	}
	
	if "`reghdfe'" != "" {
		foreach p in reghdfe ftools {
			cap which `p'
			if _rc {
				di as err _n "option {bf:reghdfe} requires {cmd: `p'} to be installed"
				exit 199
			}
		}
		if "`proxy'"!="" {
			foreach p in ivreghdfe ivreg2 {
				cap which `p'
				if _rc {
					di as err _n "option {bf:reghdfe} and IV estimation requires {cmd: `p'} to be installed"
					exit 199
				}
			}
		}
	}
	
	
		
	
	
	marksample touse
	
	tempvar sample
	
	loc flagerr=0
				
	if "`static'"=="" {
		if "`window'"!="" {
			* Parse window
			loc nw : word count `window'
			if `nw'==1 {
				loc lwindow = -`window'
				loc rwindow = `window'
			}
			else if `nw'==2 {
				loc lwindow : word 1 of `window'
				loc rwindow : word 2 of `window'
			}
			
			if -`lwindow'<0 | `rwindow'<0 {
				di as err _n "Window can not be negative"
				exit 198
			}
		}
		else if "`window'"=="" & ("`pre'"!="" & "`post'"!="" & "`overidpre'"!="" & "`overidpost'"!="") {
			loc lwindow = `pre' + `overidpre'
			loc lwindow = -`lwindow'
			loc rwindow = `post' + `overidpost' -1 
		}
		
		* If allowing for anticipation effects, change the normalization if norm is missing, or warn the user
		if ("`pre'"!="0" & "`pre'"!="") {
			if `norm'==-1 {
				loc norm = -`pre'-1
				di as text _n "You allowed for anticipation effects `pre' periods before the event, so the coefficients were normalized to `norm'. Use options {bf:norm} and {bf:window} to override this"
			}
		}
		
		* Check that normalization is in window
		if `norm' < `=`lwindow'-1' | `norm' > `rwindow' {
			di as err _n "The coefficient to be normalized to 0 is outside of the estimation window"
			exit 498
		}
		
		* Do not allow norm and trend 
		if "`norm'" !="-1" & "`trend'" != "" {
			di as err _n "Option {bf:trend} not allowed with a value for option {bf:norm} different from -1."
			exit 198
		}
		*user			
		*if "`trend'"!="" loc trend "trend(`trend')"
		*else loc trend ""

		* Estimate
	
		if "`proxy'" == "" & "`proxyiv'" == "" {
			di as txt _n "No proxy or instruments provided. Implementing OLS estimator"
			cap noi _eventols `varlist' [`weight'`exp'] if `touse', panelvar(`panelvar') timevar(`timevar') policyvar(`policyvar') lwindow(`lwindow') rwindow(`rwindow') trend(`trend') savek(`savek') norm(`norm') `reghdfe' addabsorb(`addabsorb') `options' 
			if _rc {
				errpostest
			}
		}
		else {
			di as txt _n "Proxy for the confound specified. Implementing FHS estimator"
			cap noi _eventiv `varlist' [`weight'`exp'] if `touse', panelvar(`panelvar') timevar(`timevar') policyvar(`policyvar') lwindow(`lwindow') rwindow(`rwindow') proxyiv(`proxyiv') proxy (`proxy') savek(`savek')    norm(`norm') `reghdfe' addabsorb(`addabsorb') `options' 		
			if _rc {
				errpostest
			}
		}		
	}
	else if "`static'"=="static" {
		loc lwindow=.
		loc rwindow=.
		di as txt _n "option {bf:static} specified. Estimating static model"
		di as txt _n "Plotting options ignored"
		if "`proxy'" == "" & "`proxyiv'" == "" {
			di as txt _n "No proxy or instruments provided. Implementing OLS estimator"
			cap noi _eventolsstatic `varlist' [`weight'`exp'] if `touse', panelvar(`panelvar') timevar(`timevar') policyvar(`policyvar') `reghdfe' addabsorb(`addabsorb') `options' `static'
			if _rc {
				errpostest
			}
		}
		
		else {
			di as txt _n "Proxy for the confound specified. Implementing FHS estimator"
			
			cap noi _eventivstatic `varlist' [`weight'`exp'] if `touse', panelvar(`panelvar') timevar(`timevar') policyvar(`policyvar') proxyiv(`proxyiv') proxy (`proxy') `reghdfe' addabsorb(`addabsorb') `options' `static'
			if _rc {
				errpostest
			}
		}
	}
	
	if `=r(flagerr)'!=1  {
		mat delta=r(delta)
		mat Vdelta=r(Vdelta)
		mat b = r(b)
		mat V = r(V)
		gen byte `sample' = e(sample)
		ereturn repost b=b V=V, esample(`sample')		
		ereturn matrix delta = delta
		ereturn matrix Vdelta = Vdelta
		if "`=r(method)'"=="iv" {
			mat deltaxsc = r(deltaxsc)
			mat deltaov = r(deltaov)
			mat Vdeltaov = r(Vdeltaov)
			mat deltax = r(deltax)
			mat Vdeltax = r(Vdeltax)
			ereturn matrix deltaxsc = deltaxsc
			ereturn matrix deltaov = deltaov
			ereturn matrix Vdeltaov = Vdeltaov
			ereturn matrix deltax = deltax
			ereturn matrix Vdeltax = Vdeltax
			if `=r(x1)'!=. ereturn local x1 = r(x1)
			
		}
		
		loc saveov = r(saveov)
		if "`saveov'"=="." loc saveov ""
		if "`saveov'"!="" {

			mat mattrendy = r(mattrendy)
			mat mattrendx = r(mattrendx)
			mat deltaov = r(deltaov)			
			mat Vdeltaov = r(Vdeltaov)
			ereturn matrix mattrendy = mattrendy
			ereturn matrix mattrendx = mattrendx
			ereturn matrix deltaov = deltaov
			ereturn matrix Vdeltaov = Vdeltaov
			ereturn local trend = r(trend)
		}
		ereturn scalar lwindow= `lwindow'
		ereturn scalar rwindow=`rwindow'
		if "`pre'"!="" {
			ereturn scalar pre = `pre'
			ereturn scalar post = `post'
			ereturn scalar overidpre = `overidpre'
			ereturn scalar overidpost = `overidpost'
		}
		ereturn local names=r(names)
		ereturn local cmdline `"xtevent `0'"' /*"*/
		loc cmd = r(cmd)
		ereturn local cmd = r(cmd)
		ereturn local df = r(df)
		ereturn local komit = r(komit)
		ereturn local kmiss = r(kmiss)
		ereturn local y1 = r(y1)
		ereturn local method = r(method)
		ereturn local cmd2 "xtevent"
		ereturn local depvar = r(depvar)
		
		if "`savek'"!="" ereturn local stub="`savek'"
	}
	else {
		exit 198
	}
	
	if "`plot'"!="" xteventplot

end

cap program drop cleanup
program define cleanup
	cap drop _k_eq*
	cap drop _ttrend
	cap drop __k	
	cap drop _f*
	cap _estimates clear
end

cap program drop errpostest
program define errpostest, rclass
	cleanup _rc	
	return local flagerr=1
end



