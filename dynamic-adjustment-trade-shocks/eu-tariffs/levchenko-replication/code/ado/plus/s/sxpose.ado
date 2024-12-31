*! NJC 1.0.0 14 October 2004 
program sxpose 
	version 8 
	syntax , clear [ force format(string) firstnames destring ] 

	if "`force'" == "" { 
		foreach v of var * { 
			capture confirm string var `v' 
			if _rc { 
				di as err ///
				"{p}dataset contains numeric variables; " ///
				"use {cmd:force} option if desired{p_end}" 
				exit 7 
			} 	
		}
	} 	

	local nobs = _N 
	qui d 
	local nvars = r(k) 

	if `nobs' > `c(max_k_theory)' { 
		di as err "{p}not possible; would exceed present limit on " ///
			  "number of variables{p_end}" 
		exit 498 
	} 	

	forval j = 1/`nobs' { 
		local new "`new' _var`j'" 
	} 	
	
	capture confirm new var `new' 
	
	if _rc { 
		di as err "{p}sxpose would create new variables " ///
		          "_var1-_var`nobs', but names already in use{p_end}" 
		exit 110 
	} 	

	if "`format'" != "" { 
		capture di `format' 1234.56789 
		if _rc { 
			di as err "invalid %format" 
			exit 120 
		}
	}	
	else local format "%12.0g" 
	
	if `nvars' > `nobs' set obs `nvars' 

	unab varlist: * 
	tokenize `varlist' 

	qui forval j = 1/`nobs' { 
		gen _var`j' = "" 
		forval i = 1/`nvars' { 
			cap replace _var`j' = ``i''[`j'] in `i' 
			if _rc { 
				replace _var`j' = ///
				string(``i''[`j'], "`format'") in `i' 
			} 	
		} 	
	} 

	drop `varlist' 
	if `nobs' > `nvars' qui keep in 1/`nvars' 

	qui if "`firstnames'" != "" { 
		forval j = 1/`nobs' { 
			capture rename _var`j' `= _var`j'[1]' 
		}
		drop in 1 
	} 	
		
	if "`destring'" != "" destring, replace 
end 

