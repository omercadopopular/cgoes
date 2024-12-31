*! NJC 1.0.0  9 December 1999 
program define _ghmean
	version 6
	syntax newvarname =/exp [if] [in] [, BY(varlist)]

	tempvar touse 
	quietly {
		gen byte `touse' = 1 `if' `in'
		sort `touse' `by'
		by `touse' `by': gen `typlist' `varlist' = /*
		*/ cond((`exp') > 0, 1 / (`exp'), . ) if `touse' == 1
		by `touse' `by': replace `varlist' = /* 
		*/ sum(`varlist') / sum(`varlist' != .) 
		by `touse' `by': replace `varlist' = 1 / (`varlist'[_N]) 
	}
end
