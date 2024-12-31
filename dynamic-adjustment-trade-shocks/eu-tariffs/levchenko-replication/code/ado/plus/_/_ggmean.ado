*! NJC 1.0.0  9 December 1999 
program define _ggmean
	version 6
	syntax newvarname =/exp [if] [in] [, BY(varlist)]

	tempvar touse 
	quietly {
		gen byte `touse' = 1 `if' `in'
		sort `touse' `by'
		by `touse' `by': gen `typlist' `varlist' = /*
		*/ sum(log(`exp')) / sum((log(`exp'))!=.) if `touse'==1
		by `touse' `by': replace `varlist' = exp(`varlist'[_N]) 
	}
end
