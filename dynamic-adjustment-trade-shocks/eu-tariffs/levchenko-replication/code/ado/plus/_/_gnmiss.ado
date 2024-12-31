*! 1.1.0  NJC 7 January 2000
program define _gnmiss
	version 6
	syntax newvarname =/exp [if] [in] [, BY(varlist)]
	tempvar touse 
	quietly {
		mark `touse' `if' `in'
		sort `touse' `by'
		by `touse' `by': gen `typlist' `varlist' = /*
			*/ sum(missing(`exp')) if `touse' 
		by `touse' `by': replace `varlist' = `varlist'[_N]
	}
end
