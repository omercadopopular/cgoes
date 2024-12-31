*! xtivreg2_p version 1.0.3  5July2012
program define xtivreg2_p, sortpreserve
	version 8.2
	syntax newvarname [if] [in] , [E XB U UE XBU]

* Does not currently support previous estimation using fwl or partial
	if "`e(fwlcons)'" != ""  | (e(partial_ct)>0 & e(partial_ct)<.) {
di in r "predict not supported after xtivreg2 with partialling-out option"
		error 499
	}

* Uses [if] [in] as well as limiting to e(sample)
	tempname touse esample
	mark `touse' `if' `in'
	
* Sorting disturbs existing sort if xtset so sort only when actually needed
	qui xtset
	local notxtset = ("`r(panelvar)'" == "" | "`r(timevar)'" == "")
	
	if "`e(xtmodel)'"=="fd" {
		if `notxtset' {
			sort `e(ivar)' `e(tvar)'
		}

		if "`u'`ue'`xbu'" != "" {
			di as err "`u'`ue'`xbu' not supported for fd model"
			exit 198
		}
		if "`xb'" ~= "" {
			markout `touse'
			_predict `typlist' `varlist' if `touse'
		}
		else {
* Default to e
			tempname xb
			markout `touse'
			qui _predict double `xb' if `touse'
			gen `typlist' `varlist'=d.`e(depvar)'-`xb' if `touse'
		}
	}
	else if "`e(xtmodel)'"=="fe" {

		if "`xb'`u'`ue'`xbu'" != "" {
			di as err "`xb'`u'`ue'`xbu' not currently supported by -xtivreg2-"
			exit 198
		}
	
		qui if "`e'"!="" {
			gen byte `esample' = e(sample)
			markout `touse' `esample'
			if `notxtset' {
				sort `e(ivar)' `e(tvar)'
			}
* Need to strip out time series operators 
			local lhs "`e(depvar)'"
			tsrevar `lhs', substitute
			local lhs_t "`r(varlist)'"
			local rhs : colnames(e(b))
			tsrevar `rhs', substitute
			local rhs_t "`r(varlist)'"
	
			sort `e(ivar)' `esample'
			local allvars "`lhs_t' `rhs_t'"
* Demeaning block.  Uses entire estimatation sample
			foreach var of local allvars {
				tempname `var'_m `var'_dm
				by `e(ivar)' `esample' : gen double ``var'_m'=sum(`var')/_N if `esample'
				by `e(ivar)' `esample' : replace    ``var'_m'=``var'_m'[_N] if `esample' & _n<_N
				sum `var' if `esample', meanonly
				by `e(ivar)' `esample' : gen double ``var'_dm'=`var'-``var'_m'[_N] if `esample'
				local allvars_dm "`allvars_dm' ``var'_dm'"
			}
	
			tokenize `allvars_dm'
			local lhs_dm "`1'"
			mac shift
			local rhs_dm "`*'"
	
			sort `e(ivar)' `e(tvar)'
			tempname b
			mat `b'=e(b)
			mat colnames `b' = `rhs_dm'

			tempvar fitted
			mat score double `fitted' = `b' if `touse'
			gen `typlist' `varlist'= `lhs_dm' - `fitted'
		}
	}

end

* Version notes
* 1.0.1		Fixed sort bug - forcing sort would disturb ts operators if tsset
* 1.0.2		Changed trap for partialling-out so that fwl (old) or partial (new) are trapped
* 1.0.3		Changed calls from tsset to xtset to accommodate panels with no time-series dimension
