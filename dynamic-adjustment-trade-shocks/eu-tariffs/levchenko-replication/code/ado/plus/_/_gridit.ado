*! NJC 1.0.0 19 Oct 2000                  
program define _gridit 
        version 6.0
	gettoken type 0 : 0 
	gettoken g 0 : 0 
	gettoken eqs 0 : 0 
	syntax varname [if] [in] [, by(varlist) MISSing REVerse PERCent]
	marksample touse
	if "`missing'" == "" & "`by'" != "" { markout `touse' `by', strok } 
	sort `touse' `by' `varlist' 
	tempvar total pr    
	qui by `touse' `by': gen `total' = _N     
	qui by `touse' `by' `varlist': gen `pr' = _N / `total' 
        qui by `touse' `by': gen `type' `g' = 0.5 * `pr' if `touse' 
	qui by `touse' `by' `varlist': replace `pr' = `pr' * (_n == _N) 
	qui by `touse' `by': replace `g' = `g' + sum(`pr'[_n-1])   
	if "`reverse'" != "" { replace `g' = 1 - `g' } 
	if "`percent'" != "" { replace `g' = 100 * `g' } 
end
