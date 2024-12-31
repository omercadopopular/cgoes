*! NJC 1.2.0  9 March 2004 fix v.8 labelling problem                       
*! NJC 1.1.0  23 February 2000 after a WWG idea  
program define _gncyear
	version 6
	syntax newvarname =/exp [if] [in] , Month(int) [ Day(int 1)]

	if `month' == 1 & `day' == 1 { 
		di in r "calendar years requested" 
		exit 198 
	}	

	* test month and day 
	local test = mdy(`month',`day',2000) 
	if `test' == . { 
		di in r "invalid start date" 
		exit 198 
	}
	
	quietly {
		tempvar touse date
		gen byte `touse' = 1 `if' `in' 
		replace `touse' = 0 if `touse' == . 
		gen `date' = `exp' 
		
		* ignore any user-specified type
		gen int `varlist' = . 

		* version 8 handles labelling differently 
		if "$EGEN_Varname" != "" { 
			local vlabel "$EGEN_Varname" 
		} 	
		else tempname vlabel
		
		su `date' if `touse', meanonly 
		local ymin = year(r(min))
		local ymax = year(r(max)) 
	
		local y = `ymin' - 1  
		while `y' <= `ymax' { 
			local start = mdy(`month',`day',`y') 
			if `start' == . { /* 29 February */ 
				local start = mdy(3,1,`y') 
			} 
			local end = mdy(`month',`day',`y' + 1)  
			if `end' == . { /* 29 February */ 
				local end = mdy(28, 2, `y' + 1)  
			} 	
			local Yp1 = mod(`y' + 1,100) 
			replace `varlist' = `y' /* 
			*/ if `date' >= `start' & `date' < `end' & `touse' 
			label def `vlabel' `y' "`y'/`Yp1'", modify 
			local y = `y' + 1 
		}	
		label val `varlist' `vlabel' 
	}
end
