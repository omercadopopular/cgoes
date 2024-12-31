*! 1.1.0 NJC 7 December 2000 
* 1.0.0  NJC 12 July 2000
program define _gbom 
	version 6
	
	gettoken type 0 : 0
	gettoken g 0 : 0
	gettoken eqs 0 : 0			/* "=" */
	gettoken paren 0 : 0, parse("(), ")	/* "(" */

	gettoken month 0 : 0, parse("(), ")
	gettoken year  0 : 0, parse("(), ")
	if `"`year'"' == "," { 
		gettoken year  0 : 0, parse("(), ")
	}
	gettoken paren 0 : 0, parse("(), ")	/* ")" */
	if `"`paren'"' != ")" { 
		error 198
	}

	syntax [if] [in] [ , Format(str) Lag(str) Work ] 

	quietly {
		tempvar touse 
		mark `touse' `if' `in'
		
		if "`lag'" == "" { local lag = 0 } 
		else { 
			capture assert `lag' == int(`lag') 
			if _rc { 
				di in r "`lag' contains non-integer value(s)" 
				exit 410 
			} 
		} 

		capture assert `month' > 0 & `month' < 13 if `touse' 
		if _rc { 
			di in r "`month' contains value(s) not 1 to 12" 
			exit 198 
		} 

		capture assert `month' == int(`month') if `touse' 
		if _rc { 
			di in r "`month' contains non-integer value(s)" 
			exit 410 
		} 	
		
		capture assert `year' == int(`year') if `touse' 
		if _rc { 
			di in r "`year' contains non-integer value(s)" 
			exit 410 
		} 	

		gen long `g' = dofm(ym(`year', `month') - `lag') if `touse' 

		* Sunday? add 1; Saturday? add 2 
		if "`work'" != "" { 
			replace `g' = `g' + 1 if dow(`g') == 0 
			replace `g' = `g' + 2 if dow(`g') == 6
		} 	
		
		if "`format'" != "" { 
			capture format `g' `format' 
			if _rc { 
				noi di in bl "`format' invalid format" 
			} 
		} 	
	}
end

