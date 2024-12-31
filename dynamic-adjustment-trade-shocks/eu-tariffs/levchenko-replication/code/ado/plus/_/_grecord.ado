*! 1.2.1 CFB/NJC 8 Oct 2001 
* 1.2.0 CFB/NJC 8 Oct 2001
* 1.1.0 CFB 06 Oct 2001
program define _grecord
        version 6.0
        syntax newvarname =/exp [if] [in] [, BY(varlist) ORDER(varlist) MIN ]
	tempvar touse obsno
	local op = cond("`min'" == "min", "min", "max") 
        quietly {
        	mark `touse' `if' `in'
		gen `typlist' `varlist' = `exp' if `touse'
		gen long `obsno' = _n
		sort `touse' `by' `order' `obsno'
		by `touse' `by': /*
	*/ replace `varlist' = `op'(`varlist',`varlist'[_n-1]) if `touse'
	}
end

