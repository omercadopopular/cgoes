*! 1.0.0 NJC 20 February 2001   
program define _gewma   
        version 6.0
	qui tsset /* error if not set as time series */ 
	
	gettoken type 0 : 0 
	gettoken g 0 : 0 
	gettoken eqs 0 : 0 
	syntax varname [if] [in] , a(real) 
	
	marksample touse

	qui { 
		gen `type' `g' = `varlist' if `touse'
		replace `g' = /*
		*/ `a' * `varlist' + (1 - `a') * L.`g' if L.`g' < . 
	} 

end
