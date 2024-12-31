*! 1.0.0  NJC 31 Dec 2002 
* _gsd version 3.1.0  30jun1998
program define _gvar
	version 6
	syntax newvarname =/exp [if] [in] [, BY(varlist)]
	tempvar touse mean
	quietly {
		gen byte `touse'=1 `if' `in'
		sort `touse' `by'
		by `touse' `by': gen double `mean' = /*
			*/ sum(`exp')/sum((`exp')!=.) if `touse'==1
		by `touse' `by': gen `typlist' `varlist' = /*
		*/ sum(((`exp')-`mean'[_N])^2)/(sum((`exp')!=.)-1) /*
		*/ if `touse'==1 & sum(`exp'!=.)
		by `touse' `by': replace `varlist' = `varlist'[_N]
	}
end
