*! 1.1.1 NJC 13 October 2002 
* 1.1.0 NJC 7 December 2000 
* 1.0.0  NJC 12 July 2000
program define _geomd
	version 6
	
	gettoken type 0 : 0
	gettoken g 0 : 0
	gettoken eqs 0 : 0			

	syntax varname(numeric) [if] [in] [ , Format(str) Lag(str) Work ]
	local d "`varlist'" 

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
		
		gen long `g' = dofm(ym(year(`d'),month(`d'))- `lag' + 1) - 1 /* 
		*/ if `touse'
		
		* Sunday? subtract 2; Saturday? subtract 1
		if "`work'" != "" { 
			replace `g' = `g' - 2 if dow(`g') == 0 
			replace `g' = `g' - 1 if dow(`g') == 6
		} 	

		if "`format'" != "" { 
			capture format `g' `format' 
			if _rc { 
				noi di in bl "`format' invalid format" 
			} 
		} 	
	}
end

