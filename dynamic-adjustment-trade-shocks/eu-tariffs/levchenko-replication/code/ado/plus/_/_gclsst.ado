*! 1.0.0 NJC 11 January 2000 
program define _gclsst
        version 6.0
        gettoken type 0 : 0
        gettoken g 0 : 0
        gettoken eqs 0 : 0
        syntax varname(numeric) [if] [in], Values(numlist) [ Later ] 
	local eq = cond("`later'" != "", "=", "") 
        marksample touse 
        tokenize `values'
	tempvar gdiff ldiff 
        quietly {
		gen `gdiff' = . 
		gen `ldiff' = . 
                gen `g' = .    
                while "`1'" != "" { 
			replace `ldiff' = abs(`varlist' - `1') if `touse' 
			replace `g' = `1' if `ldiff' <`eq' `gdiff' 
			replace `gdiff' = min(`gdiff', `ldiff') 
                        mac shift 
                }
        }
        if length("`varlist': closest of `values'") > 80 {
                note `g' : `varlist' closest of `values'
                label var `g' "`varlist': see notes"
        }
        else label var `g' "`varlist' closest of `values'"
end
