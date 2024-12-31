*! version 1.0.6  30Jan2011
*! author mes
* 1.0.1: 25apr2002 original version
* 1.0.2: 28jun2005 version 8.2
* 1.0.3: 1Aug2006 complete rewrite plus fwl option
* 1.0.4: 26Jan2007 eliminated double reporting of #MVs
* 1.0.5: 2Feb2007 small fix to allow fwl of just _cons
* 1.0.6: 30Jan2011 re-introduced stdp (had been removed with fwl)
*                  and added labelling of created residual variable

program define ivreg28_p
	version 8.2
	syntax newvarname [if] [in] , [XB Residuals stdp]
	marksample touse, novarlist

	local type "`xb'`residuals'`stdp'"

	if "`type'"=="" {
		local type "xb"
di in gr "(option xb assumed; fitted values)"
	}

	if "`e(fwlcons)'" != "" {
* fwl partial-out block
		if "`type'" == "residuals" {
	
			tempvar esample
			tempname ivres
			gen byte `esample' = e(sample)

* Need to strip out time series operators 
			local lhs "`e(depvar)'"
			tsrevar `lhs', substitute
			local lhs_t "`r(varlist)'"

			local rhs : colnames(e(b))
			tsrevar `rhs', substitute
			local rhs_t "`r(varlist)'"

			if "`e(fwl1)'" != "" {
				local fwl "`e(fwl1)'"
			}
			else {
				local fwl "`e(fwl)'"
			}
			tsrevar `fwl', substitute
			local fwl_t "`r(varlist)'"

			if ~e(fwlcons) {
				local noconstant "noconstant"
			}
	
			local allvars "`lhs_t' `rhs_t'"
* Partial-out block.  Uses estimatation sample to get coeffs, markout sample for predict
			_estimates hold `ivres', restore
			foreach var of local allvars {
				tempname `var'_fwl
				qui regress `var' `fwl' if `esample', `noconstant'
				qui predict double ``var'_fwl' if `touse', resid
				local allvars_fwl "`allvars_fwl' ``var'_fwl'"
			}
			_estimates unhold `ivres'

			tokenize `allvars_fwl'
			local lhs_fwl "`1'"
			mac shift
			local rhs_fwl "`*'"

			tempname b
			mat `b'=e(b)
			mat colnames `b' = `rhs_fwl'
* Use forcezero?
			tempvar xb
			mat score double `xb' = `b' if `touse'
			gen `typlist' `varlist' = `lhs_fwl' - `xb'
			label var `varlist' "Residuals"
		}
		else {
di in red "Option `type' not supported with -fwl- option"
			error 198
		}
	}
	else if "`type'" == "residuals" {
		tempname lhs lhs_t xb
		local lhs "`e(depvar)'"
		tsrevar `lhs', substitute
		local lhs_t "`r(varlist)'"
		qui _predict `typlist' `xb' if `touse'
		gen `typlist' `varlist'=`lhs_t'-`xb'
		label var `varlist' "Residuals"
	}
* Must be either xb or stdp
	else {
		_predict `typlist' `varlist' if `touse', `type'
	}

end
