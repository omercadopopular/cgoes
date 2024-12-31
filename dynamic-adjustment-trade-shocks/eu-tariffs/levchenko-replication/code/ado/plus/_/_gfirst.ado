*! 1.0.0 NJC 31 May 2000 
program define _gfirst 
        version 6.0
        gettoken type 0 : 0
        gettoken g 0 : 0
        gettoken eqs 0 : 0
        syntax varname [if] [in] [, BY(varlist) ] 
	marksample touse, strok
	tempvar order 
	gen long `order' = _n 
	sort `touse' `by' `order' 
	* ignore user-supplied `type' 
	local type : type `varlist' 
        qui by `touse' `by' : gen `type' `g' = `varlist'[1] if `touse'
end
