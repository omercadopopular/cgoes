*! 1.1.0 NJC 27 Feb 2006 
* 1.0.0 CFB 29 Sep 2002 
* 1.1.0 NJC 7 December 2000 _gbom
* 1.0.0  NJC 12 July 2000
program define _ghms
	version 6
	
	gettoken type 0 : 0
	gettoken g 0 : 0
	gettoken eqs 0 : 0			/* "=" */
	gettoken paren 0 : 0, parse("() ")	/* "(" */

	gettoken hour 0 : 0, parse("() ")
	gettoken min  0 : 0, parse("() ")
	gettoken sec  0 : 0, parse("() ")

	gettoken paren 0 : 0, parse("(), ")	/* ")" */
	if `"`paren'"' != ")" { 
		error 198
	}

	syntax [if] [in] [ , Format(str) ]

	quietly {
		tempvar touse 
		mark `touse' `if' `in'
		replace `touse' = 0 if missing(`hour', `min', `sec') 

		capture assert `hour' >= 0 & `hour' < 24 if `touse' 
		if _rc { 
			di in r "`hour' contains value(s) not 0 to 23" 
			exit 198 
		} 

		capture assert `hour' == int(`hour') if `touse' 
		if _rc { 
			di in r "`hour' contains non-integer value(s)" 
			exit 410 
		} 	
		
		capture assert `min' >= 0 & `min' < 60 if `touse' 
		if _rc { 
			di in r "`min' contains value(s) not 0 to 59" 
			exit 198 
		} 

		capture assert `min' == int(`min') if `touse' 
		if _rc { 
			di in r "`min' contains non-integer value(s)" 
			exit 410 
		}
		
		capture assert `sec' >= 0 & `sec' < 60 if `touse' 
		if _rc { 
			di in r "`sec' contains value(s) not 0 to 59" 
			exit 198 
		} 

		capture assert `sec' == int(`sec') if `touse' 
		if _rc { 
			di in r "`sec' contains non-integer value(s)" 
			exit 410 
		}	

		gen long `g' = `sec' + `min'*60 + `hour'*3600 if `touse' 	
		
		if "`format'" != "" { 
			capture format `g' `format' 
			if _rc { 
				noi di in bl "`format' invalid format" 
			} 
		} 	
	}
end

