*! 1.0.0 NJC 12 July 2000 
program define _gnss
	version 6.0

	gettoken type 0 : 0
	gettoken g    0 : 0
	gettoken eqs  0 : 0

	syntax varname(string) [if] [in], Find(str) [ Insensitive ]

	marksample touse, strok
	tempvar lower ndx rmndr 

	quietly {
		/* ignores type passed from -egen- */
		gen byte `g' = 0 if `touse' 
		local flen = length(`"`find'"') 
		local type : type `varlist' 

		if "`insensitive'" != "" { 
			gen `type' `lower' = lower(`varlist')
			local varlist `lower' 
			local find = lower(`"`find'"') 
			local flen2 = length(`"`find'"') 
			local dflen = `flen' - `flen2' 
			if `dflen' { 
				local spaces : di _dup(`dflen') " "
				local find `"`spaces'`find'"' 
			} 	
		}
		
	        gen byte `ndx' = index(`varlist', `"`find'"') * `touse' 
		count if `ndx'
        	if r(N) == 0 { exit 0 }

		gen `type' `rmndr' = `varlist' if `touse' 

	        while 1 {
			replace `g' = `g' + (`ndx' > 0) 
                	replace `rmndr' = /* 
			*/ cond(`ndx', substr(`rmndr', `ndx'+`flen', .),"") 
                        cap assert `rmndr' == "" 
	                if _rc != 0 { 
				replace `ndx' = index(`rmndr', `"`find'"') 
			}
	                else exit 0
        	}
	}
end

