*! 1.0.0 NJC 12 February 2001 
program define _grany 
	version 6
	gettoken type 0 : 0
	gettoken g    0 : 0
	gettoken eqs  0 : 0

	syntax varlist [if] [in] , Cond(string asis) [ SYmbol(str) ]

	if "`symbol'" == "" { local symbol "@" } 
	if index(`"`cond'"',"`symbol'") == 0 { 
		di in r `"`cond' does not contain `symbol'"' 
		exit 198 
	} 	

	tempvar touse
	mark `touse' `if' `in'
	
	quietly {
		* ignore user-supplied `type' 
		gen int `g' = 0 if `touse' 
		tokenize `varlist'
		while "`1'" != "" {
			local Cond : subinstr local cond "`symbol'" "`1'", all  
			replace `g' = `g' + (`Cond') 
			mac shift
		}
		replace `g' = `g' > 0 if `touse' 
		compress `g' 
	}
end
