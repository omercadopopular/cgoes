*! 1.0.0 NJC 12 March 2000
program define _ghmm
        version 6.0

        gettoken type 0 : 0
        gettoken g    0 : 0
        gettoken eqs  0 : 0

        syntax varname(numeric) [if] [in] [, Round(numlist >0 max=1) Trim ] 
        marksample touse, strok
        local type "str1" /* ignores type passed from -egen- */

        quietly {                
		gen `type' `g' = ""
		tempvar wrk 

		* minutes 
		gen `wrk' = int(`varlist'/ 60)
		replace `g' = string(`wrk') + ":" if `touse'

		* seconds
		replace `wrk' = mod(`varlist', 60)  
		if "`round'" != "" { replace `wrk' = round(`wrk', `round') } 
replace `g' = `g' + cond(`wrk' < 10, "0", "") + string(`wrk') if `touse' 
		if "`trim'" != "" { 
			local goon 1 
			while `goon' {
count if `touse' & (substr(`g',1,1) == "0" | substr(`g',1,1) == ":") & `g' != "0"   
				local goon = r(N)
				if `goon' { 
replace `g' = substr(`g',2,.) if `touse' & (substr(`g',1,1) == "0" | substr(`g',1,1) == ":") & `g' != "0" 
				} 	
			} 
			compress `g'  
		} 	
       }
end
