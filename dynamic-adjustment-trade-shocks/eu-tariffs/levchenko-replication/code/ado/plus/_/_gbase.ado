*! 1.0.1 NJC 2 Oct 2002 
* 1.0.0 NJC 29 Oct 2001
program define _gbase 
	version 6.0

	gettoken type 0 : 0
	gettoken g    0 : 0
	gettoken eqs  0 : 0
	
	syntax varname(numeric) [if] [in] [ , Base(numlist max=1 int <=9 >1) ] 
	
	marksample touse
	* ignores type passed from -egen- 
	local type "str1" 
	if "`base'" == "" { local base = 2 } 

	capture assert `varlist' == int(`varlist') if `touse' 
	if _rc { 
		di in r "`varlist' invalid: not integer" 
		exit 459 
	} 
	capture assert `varlist' >= 0 if `touse' 
	local sign = _rc != 0 	

	quietly {
		tempvar work digit 
		gen `type' `g' = ""
		gen long `work' = `varlist' if `touse' 
		gen int `digit' = . 
		su `work', meanonly 
		local max = max(`r(max)',-`r(min)') 
		local power = 0 
		while `max' >= (`base'^(`power' + 1)) { 
			local power = `power' + 1 
		} 	
		if `sign' { 
			replace `g' = `g' + cond(`work' < 0, "-","+") if `touse'
			replace `work' = abs(`work') 
		} 
		while `power' >= 0 { 
			replace `digit' = int(`work' / `base'^`power') 
			replace `work' = mod(`work', `base'^`power')   
			replace `g' = `g' + string(`digit') if `touse'
			local power = `power' - 1 
		}
	}
end
