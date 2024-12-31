*! 1.1.1 NJC 19 March 2006 
*! 1.1.0 NJC 5 December 2003 
* 1.0.1 NJC 26 June 2001 
* promoted to 7 to avoid problems with -normali?e- 
* 1.0.0 NJC 25 January 2000 aided and abetted by CFB  
program _gfilter
        version 8   
	qui tsset /* error if not set as time series */ 
	
	gettoken type 0 : 0 
	gettoken g 0 : 0 
	gettoken eqs 0 : 0 
	syntax varname(ts) [if] [in] , Lags(numlist int min=1) ///
	[ Coef(numlist min=1) Normalise Normalize ]

	local nlags : word count `lags' 
	local ncoef : word count `coef'

	if `ncoef' == 0 { 
		local coef : di _dup(`nlags') "1 " 
		local ncoef `nlags'
	} 	
	else if `nlags' != `ncoef' { 
		di as err "lags() and coef() not consistent" 
		exit 198 
	}	

	marksample touse
	tokenize `coef'
	
	if "`normalise'`normalize'" != "" { 
		local total = 0 
		forval i = 1/`ncoef' { 
			local total = `total' + (``i'')  
		} 
		forval i = 1/`ncoef' { 
			local `i' = ``i'' / `total' 
		} 
	} 	
	
	local rhs "0" 

	forval i = 1/`nlags' { 
		local l : word `i' of `lags' 
		local L = -`l'
		local op = cond(`l' < 0, "F`L'", "L`l'") 
		local rhs "`rhs' + (``i'') * `op'.`varlist'" 
	} 	
	
	qui gen `type' `g' = `rhs' if `touse' 
end
