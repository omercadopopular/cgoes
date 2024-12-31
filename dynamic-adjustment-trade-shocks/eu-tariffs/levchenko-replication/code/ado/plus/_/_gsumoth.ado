*! 1.0.0 NJC 16 Oct 2001 
program define _gsumoth 
	version 6
	syntax newvarname =/exp [if] [in] [, BY(varlist)]
	tempvar touse 
	quietly {
		gen byte `touse'=1 `if' `in'
		sort `touse' `by'
		by `touse' `by': gen `typlist' `varlist' = sum(`exp') /*
					*/ if `touse'==1
		by `touse' `by': replace `varlist' = `varlist'[_N]
		replace `varlist' = `varlist' - `exp' 
	}
end
