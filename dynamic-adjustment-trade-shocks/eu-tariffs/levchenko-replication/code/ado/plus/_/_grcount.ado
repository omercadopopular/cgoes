*! 1.0.0 NJC 12 February 2001 
program define _grcount 
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
		* just in case someone tries something like -cond(@^2)- 
		gen `type' `g' = 0 if `touse' 
		tokenize `varlist'
		while "`1'" != "" {
			local Cond : subinstr local cond "`symbol'" "`1'", all  
			replace `g' = `g' + (`Cond') 
			mac shift
		}
		compress `g' 
	}
end
