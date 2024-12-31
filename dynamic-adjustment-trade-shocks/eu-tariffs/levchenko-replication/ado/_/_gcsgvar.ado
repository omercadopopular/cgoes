*! v1.1 Corrects typo
* v1 Creates gvar-Cohort/group variable
*program drop _gcsgvar
program _gcsgvar, sortpreserve
	syntax newvarname =/exp [if] [in], tvar(varname) ivar(varname)
	local exp = subinstr("`exp'","(","",.)
	local exp = subinstr("`exp'",")","",.)
	tempvar touse
	qui:gen byte `touse'=0
	qui:replace `touse'=1 `if' `in'
	qui:replace `touse'=0 if `tvar'==. | `ivar'==. | `exp'==.
		
	tempvar vals
	bys `touse' `exp' : gen byte `vals' = (_n == 1) * `touse'
	su `vals' if `touse', meanonly
	if r(sum)>2 {
			display in r "display More than 2 values detected in `exp'."
			error 4444
	}
	qui: {
		tempvar aux
		bysort `touse' `ivar' `exp':egen `aux'=min(`tvar')
		replace `aux'=0 if `exp'==0
		by     `touse' `ivar':egen `varlist'=max(`aux')
		replace `varlist'=. if `exp'==. | !`touse'
	}
	
	label var `varlist' "Group Variable based on `exp'"
end
