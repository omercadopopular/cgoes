*! 1.0.0 CFB 29 Sep 2002 
* 1.1.0 NJC 7 December 2000 _gbom
* 1.0.0  NJC 12 July 2000
program define _gelap
	version 6
	
	gettoken type 0 : 0
	gettoken g 0 : 0
	gettoken eqs 0 : 0			/* "=" */
	gettoken paren 0 : 0, parse("() ")	/* "(" */

	gettoken time 0 : 0, parse("() ") 

	gettoken paren 0 : 0, parse("(), ")	/* ")" */
	if `"`paren'"' != ")" { 
		error 198
	}

	syntax [if] [in] [ , Format(str) ]

	quietly {
		tempvar touse dd tyme hh mm ss
		mark `touse' `if' `in'

		capture assert `time' >= 0  if `touse' 
		if _rc { 
			di in r "`time' contains non time-of-day value(s)" 
			exit 198 
		} 

		capture assert `time' == int(`time') if `touse' 
		if _rc { 
			di in r "`time' contains non-integer value(s)" 
			exit 410 
		} 	
		
		gen int `dd' = int(`time'/86400) if `touse'
		gen long `tyme' = `time' - 86400*`dd' if `touse'
		gen int `hh' = int(`tyme'/3600) if `touse'
		gen int `mm' = int((`tyme' - `hh'*3600)/60) if `touse'
		gen int `ss' = int(`tyme' - `hh'*3600 - `mm'*60) if `touse'
		gen str15 `g' = string(`dd',"%6.0f") + ":"+ string(`hh',"%02.0f") /*
		*/ + ":" + string(`mm',"%02.0f") + /*
		*/ ":" + string(`ss',"%02.0f") if `touse' 	
	
		if "`format'" != "" { 
			capture format `g' `format' 
			if _rc { 
				noi di in bl "`format' invalid format" 
			} 
		} 	
	}
end

