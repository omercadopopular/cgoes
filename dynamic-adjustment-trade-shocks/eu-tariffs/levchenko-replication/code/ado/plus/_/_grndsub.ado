*! NJC 1.2.0 11 January 2000
* NJC 1.1.0 7 January 2000
* John Moran suggested -frac( )- 
program define _grndsub 
	version 6        
        gettoken type 0 : 0
        gettoken g 0 : 0
        gettoken eqs 0 : 0
        gettoken lparen 0 : 0, parse("(")
        gettoken rparen 0 : 0, parse(")")
        syntax [if] [in] [, by(varlist) NGroup(int 2) Frac(str) Percent(str)]

	if "`frac'" != "" | "`percent'" != "" { 
		if "`frac'" != "" & "`percent'" != "" { 
			di in r "may not combine frac( ) and percent( )" 
			exit 198 
		}	
		else { 
			local opt = cond("`frac'" != "", "frac", "percent")  
			if `ngroup' != 2 { 
				di in r "`opt'( ) allowed only with ngroup(2)" 
				exit 198 
			}
		}	
		
		if "`percent'" != "" { 
			confirm number `percent' 
			capture assert `percent' > 0 & `percent' < 100 
			if _rc { 
				di in r "percent( ) should be between 0 and 100"
				exit 198 
			}
			local frac = 100 / `percent' 
		} 
		else { 
			confirm number `frac' 
			capture assert `frac' > 0 
			if _rc { 
				di in r "frac( ) should be > 0" 
				exit 198 
			}	
		} 	
	} 	
	
	tempvar touse random  
	quietly {
		mark `touse' `if' `in'
		gen `random' = uniform( ) 		
		sort `touse' `by' `random' 
		if "`frac'" != "" { 
			by `touse' `by' : gen `type' `g' = /* 
			*/ 1 + (_n  > (_N / `frac')) if `touse' 
		} 	
		else { 
			by `touse' `by': gen `type' `g' = /*
			*/ group(`ngroup') if `touse' 
		} 	
	}
end
