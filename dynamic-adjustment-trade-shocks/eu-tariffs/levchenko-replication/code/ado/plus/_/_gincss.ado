*! 1.0.1 NJC 4 July 2000 
* 1.0.0 NJC 20 March 2000 
program define _gincss
        version 6.0
        gettoken type 0 : 0
        gettoken g 0 : 0
        gettoken eqs 0 : 0
        syntax varlist(string) [if] [in] , Substr(str) [ Insensitive ] 
	tempvar touse 
        mark `touse' `if' `in' 
	tokenize `varlist' 
	if "`insensitive'" != "" { 
		local substr = lower(`"`substr'"') 
		local lower "lower" 
	}
	quietly {
                gen byte `g' = 0    /* ignore user-supplied `type' */
                while "`1'" != "" {
       	                replace `g' = 1 /* 
			*/ if index(`lower'(`1'),`"`substr'"') & `touse'
                        mac shift
                }
        }
end
