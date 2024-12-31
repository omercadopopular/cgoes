*! NJC 1.0.0 6 February 2004 
program _gaxis
	version 8
	gettoken type 0 : 0
	gettoken g    0 : 0
	gettoken eqs  0 : 0

	syntax varlist [if] [in] ///
	[, gap Missing BY(string) REVerse label(varlist)]

	if `"`by'"' != "" {
		_egennoby egroup() `"`by'"'
		/* NOTREACHED */
	}

	tempvar touse order 
	quietly {
		mark `touse' `if' `in'
		if "`missing'" == "" markout `touse' `varlist', strok
		
		sort `touse' `varlist'
		gen long `order' = _n 
		
		if "`label'" == "" local label "`varlist'" 

		if "`gap'" != "" { 
			local nvars : word count `varlist' 
			gen `type' `g' = 1 - `nvars'  if `touse'
			foreach v of local varlist { 
				replace `g' = `g' + sum(`v' != `v'[_n-1]) if `touse' 
			}	
		} 
		else { 
			by `touse' `varlist' : gen `type' `g' = _n == 1 if `touse'  
			replace `g' = sum(`g') if `touse'  
		} 	

		su `g', meanonly 
		if "`reverse'" != "" { 
			replace `g' = `r(max)' - `g' + 1 
			su `g', meanonly 
		} 	
		
		if "`label'" == "" local label "`varlist'" 
	
		forval i = 1/`r(max)' { 
			su `order' if `g' == `i', meanonly 
			if r(N) > 0 { 
				local value 
				local first = `r(min)' 
				local prev = `first' - 1 
		
// offset so that it is readable 
foreach v of local label { 
	if (`v'[`first'] != `v'[`prev']) | !`touse'[`prev']  {
		if "`: value label `v''" != "" { 
			local value `"`value' `: label (`v') `=`v'[`first']''"'
		} 	
		else local value `"`value' `=`v'[`first']'"' 
	}
} 
// end offset 
				label def $EGEN_Varname `i' `"`value'"', modify 
			}
		}
		 	
		label val `g' $EGEN_Varname
		label var `g' "`varlist'" 
	} 
end
