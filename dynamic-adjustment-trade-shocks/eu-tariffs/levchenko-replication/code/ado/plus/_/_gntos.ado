*! 1.0.0  NJC 21 January 2001
program define _gntos
	version 6.0

	gettoken type 0 : 0
	gettoken g    0 : 0
	gettoken eqs  0 : 0

	syntax varlist(numeric min=1) [if] [in], From(numlist) To(str asis)
	marksample touse
	
	local nfrom : word count `from' 
	local nto : word count `to' 
	if `nfrom' != `nto' { 
		di in r "from( ) and to( ) do not match one to one" 
		exit 198 
	} 
	
	quietly {
		/* ignore `type' passed from -egen- */ 
		gen str1 `g' = ""
          	tokenize `"`to'"'   
		local i = 1 
		while `i' <= `nfrom' {
			local fval : word `i' of `from' 
			replace `g' = `"``i''"' /* 
			*/ if `varlist' == `fval' & `touse' 
			local i = `i' + 1 
		}
	}
end
