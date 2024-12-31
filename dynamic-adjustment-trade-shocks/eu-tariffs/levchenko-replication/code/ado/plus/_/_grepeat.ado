program _grepeat 
*! 1.0.0  NJC 21 July 2003 
	version 8.0
	gettoken type 0 : 0
	gettoken g 0 : 0
	gettoken eqs 0 : 0
	gettoken lparen 0 : 0, parse("(")
	gettoken rparen 0 : 0, parse(")")

	syntax [if] [in] , Values(str asis) [ by(varlist) Block(int 1) ]
	
	if `block' < 1 {
		di as err "block should be at least 1"
		exit 498
	}

	marksample touse
	tempvar order obs which  
	qui { 
		gen long `order' = _n 
		bysort `touse' `by' (`order') : /// 
			gen long `obs' = _n if `touse' 
	
		capture numlist "`values'"
		local isstr = _rc  
		// ignore user type 
		if `isstr' { 
			gen `g' = "" 
			local nvals : word count `values' 
			tokenize `"`values'"' 
		} 
		else { 
			gen double `g' = .
			local nvals : word count `r(numlist)' 
			tokenize "`r(numlist)'" 
		} 
		
		gen long `which' = 1 + int(mod((`obs' - 1) / `block', `nvals'))

		if `isstr' { 
			forval i = 1 / `nvals' { 
				replace `g' = "``i''" if `which' == `i'  
			}
		}	
		else { 	
			forval i = 1 / `nvals' { 
				replace `g' = ``i'' if `which' == `i' 
			} 	
			compress `g' 
		}
	}	
end 
