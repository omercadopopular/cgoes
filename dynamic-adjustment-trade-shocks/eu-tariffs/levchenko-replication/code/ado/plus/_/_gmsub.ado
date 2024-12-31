*! 1.0.0 NJC 11 December 2000 
program define _gmsub
	version 6.0
    	
	gettoken type 0 : 0
	gettoken g    0 : 0
	gettoken eqs  0 : 0

	syntax varlist(max=1 string) [if] [in], /* 
	*/ Find(str asis) [ Replace(str asis) N(int -1) Word ]

       	local fcn = cond("`word'" != "", "subinword", "subinstr") 
	
	* doesn't work => user needs to update Stata	
	capture local bar = `fcn'("foo","foo","bar",.) 
	if _rc { 
		di in r "Your version of Stata doesn't recognise `fcn'( )." 
		di in r "I guess that you need to update."
		exit 198 
	}	

	local nfind : word count `find' 
	local nrepl : word count `replace' 
	
	if `nrepl' == 0 { /* no replacement => delete */ 
		local nrepl = `nfind' 
	} 	
	else if `nrepl' == 1 { /* many to one replacements allowed */ 
    		local nrepl = `nfind' 
		local replace : di _dup(`nfind') `"`replace' "'   
	} 
	else if `nfind' != `nrepl' { 
    		di in r "number of find and replace arguments not equal" 
		exit 198 
	} 
	
	marksample touse, strok
	local type "str1" /* ignores type passed from -egen- */
	local n = cond(`n' == -1, ., `n') 

	quietly {
        	gen `type' `g' = ""
	        replace `g' = `varlist' if `touse' 
		
        	local i = 1
		while `i' <= `nfind' {
			local f : word `i' of `find' 
			local r : word `i' of `replace' 
        	        replace `g' = `fcn'(`g', `"`f'"', `"`r'"', `n') 
            		local i = `i' + 1
		}	
        }
end
