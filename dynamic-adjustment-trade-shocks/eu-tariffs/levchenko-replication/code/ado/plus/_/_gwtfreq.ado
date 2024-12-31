*! NJC 1.0.0  31 Dec 2002 
program define _gwtfreq 
	version 6
	syntax newvarname =/exp [if] [in] [, BY(varlist)]
	quietly {
		marksample touse, novarlist 
		tempvar wt  
		gen double `wt' = `exp'
		sort `touse' `by'
		by `touse' `by': gen `typlist' `varlist' = sum(`wt') /*
					*/ if `touse'
		by `touse' `by': replace `varlist' = `varlist'[_N]
		su `wt' if `touse', meanonly
		replace `varlist' = `varlist' / r(mean) 
	}
end
