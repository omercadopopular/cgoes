*! 1.1.0 NJC 24 May 2007 
*! 1.0.0 NJC 5 December 2000 
program define _gsemean 
	version 6
	syntax newvarname =/exp [if] [in] [, BY(varlist)]
	tempvar touse mean n 
	quietly {
		gen byte `touse' = 1 `if' `in'
		sort `touse' `by'
		by `touse' `by': gen double `mean' = /*
			*/ sum(`exp')/sum((`exp') < .) if `touse' == 1
		by `touse' `by': gen long `n' = sum((`exp') < .) if `touse' == 1 
		by `touse' `by': replace `n' = `n'[_N] 
		by `touse' `by': gen `typlist' `varlist' = /*
		*/ sqrt(sum(((`exp')-`mean'[_N])^2)/(sum((`exp') < .) - 1)) /*
		*/ if `touse'==1 & sum(`exp' < .)
		by `touse' `by': replace `varlist' = `varlist'[_N] / sqrt(`n') 
	}
end
