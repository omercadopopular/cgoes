*! 1.0.0  NJC 21 January 2001
program define _gston
	version 6.0

	gettoken type 0 : 0
	gettoken g    0 : 0
	gettoken eqs  0 : 0

	syntax varlist(string min=1) [if] [in], From(str asis) To(numlist) 
	marksample touse, strok 
	
	local nfrom : word count `from' 
	local nto : word count `to' 
	if `nfrom' != `nto' { 
		di in r "from( ) and to( ) do not match one to one" 
		exit 198 
	} 

	quietly {
		gen `type' `g' = . 
          	tokenize `"`from'"'   
		local i = 1 
		while `i' <= `nfrom' {
			local toval : word `i' of `to' 
			replace `g' = `toval' /* 
			*/ if `varlist' == `"``i''"' & `touse' 
			local i = `i' + 1 
		}
	}
end
