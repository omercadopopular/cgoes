*! NJGW 09jun2005
*! syntax:  [by varlist:] egen newvar = var1 var2 [if exp] [in exp] 
*!           [ , covariance spearman taua taub ]
*! computes correlation (or covariance, or spearman correlation) between var1 and var2, optionally by: varlist
*!    and stores the result in newvar.
program define _gcorr
	version 8

	gettoken type 0 : 0
	gettoken g    0 : 0
	gettoken eqs  0 : 0
	syntax varlist(min=2 max=2) [if] [in] [, BY(string) Covariance Spearman taua taub ]

	if "`taua'`taub'`spearman'"!="" & "`covariance'"!="" {
		di as error "`taua'`taub'`spearman' and covariance are mutually exclusive"
		exit 198
	}

	local x : word count `taua' `taub' `spearman'
	if `x'> 1 {
		di as error "may only specify one of `taua' `taub' `spearman'"
		exit 198
	}

	if `"`by'"'!="" {
		local by `"by `by':"'
	}

	quietly { 
		gen `type' `g' = .
		`by' GenCorr `varlist' `if' `in', thevar(`g') `covariance' `spearman' `taua' `taub'
	}
	
	if "`spearman'"!="" {
		local lab "Spearman Correlation"
	}
	else if "`taua'"!="" {
		local lab "Tau-A Correlation"
	}
	else if "`taub'"!="" {
		local lab "Tau-B Correlation"
	}
	else if "`covariance'" != "" {
		local lab "Covariance"
	}
	else {
		local lab "Correlation"
	}
	
	capture label var `g' "`lab' of `varlist'"
end

program define GenCorr, byable(recall)
	syntax varlist [if] [in] , thevar(string) [ covariance spearman taua taub ]
	marksample touse
	if "`covariance'"!="" {
		local stat "r(cov_12)"
	}
	else if "`taua'"!="" {
		local stat "r(tau_a)"
	}
	else if "`taub'"!="" {
		local stat "r(tau_b)"
	}
	else {					/* correlation and spearman */
		local stat "r(rho)"
	}
	
	if "`spearman'"!="" {		
		local cmd spearman
	}
	else if "`taua'`taub'"!="" {
		local cmd ktau
	}
	else {
		local cmd corr			/* correlation and covariance */
	}

	cap `cmd' `varlist' if `touse' , `covariance'
	if !_rc {
		qui replace `thevar'=``stat'' if `touse'
	}
end
