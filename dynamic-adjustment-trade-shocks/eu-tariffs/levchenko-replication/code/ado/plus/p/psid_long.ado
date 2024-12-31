*! version 1.0.0 Dezember 18, 2014 @ 17:49:46
*! Reshape data created with psid use to long 
program psid_long
version 13
	syntax [anything]

	capture rename x11102_* x11102*
	capture rename xsqnr_* xsqnr*
	
	* 1 Find panel vars
	foreach var of varlist _all {
		if regexm("`var'","[12][019][0-9][0-9]$") {
			local stubs `stubs' `=regexr("`var'","[12][019][0-9][0-9]$","")'
		}
		local stubs: list uniq stubs
	}

	* 2 Collect variable labels and chars
	foreach stub of local stubs {
		macro drop _lab
		macro drop _char
		foreach var of varlist `stub'???? {
			capture local char `char' `: char `var'[items1]'
			if "`lab'" == "" {  
				capture local lab: var lab `var'
			}
		}
		local lb`stub' `lab'
		local char`stub' `char'
	} 
	
	* 2 Reshape
	reshape long `stubs', i(x11101ll) j(wave)

	* 3 Label variables
	foreach var of varlist `stubs' {
		label var `var' `"`lb`var''"'
		char define `var'[items1] `char`var''
	}

	
end
