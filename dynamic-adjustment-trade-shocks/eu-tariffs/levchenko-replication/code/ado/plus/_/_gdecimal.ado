*! 1.0.0 NJC 26 Oct 2001
program define _gdecimal 
	version 7.0

	gettoken type 0 : 0
	gettoken g    0 : 0
	gettoken eqs  0 : 0

	syntax varlist(numeric min=1) [if] [in] [, Base(numlist max=1 int >1) ] 
	
	marksample touse
	* ignores type passed from -egen- 
	local type "long" 
	if "`base'" == "" { local base = 2 } 

	foreach v of varlist `varlist' { 
		capture assert `v' == int(`v') if `touse' 
		if _rc == 0 { 
			capture assert `v' >= 0 & `v' < `base' if `touse' 
		} 	
		if _rc { 
			di as err "invalid syntax: `v' not base `base'" 
			exit 198 
		}
	} 

	local nvars : word count `varlist'  
	tokenize `varlist' 

	quietly {
		gen `type' `g' = 0 if `touse' 
		forval i = 1/`nvars' { 
			local power = `nvars' - `i'  
			replace `g' = `g' + ``i'' * `base'^`power' 
		} 	
		compress `g' 
	}
end
