*! svmatsv 1.0.0 NJC 20 Oct 1999   (STB-56: dm79)
program define svmatsv
        version 6.0
        tokenize "`0'", parse(" ,")
	
        if "`2'" == "" | "`2'" == "," {
                local type "float"
                local A    "`1'"
                mac shift
        }
        else {
                local type "`1'"
                local A    "`2'"
                mac shift 2
        }
	
        capture local nc = colsof(matrix(`A'))
        if _rc {
                di in red "matrix `A' not found"
                exit 111
        }
	local nr = rowsof(matrix(`A'))  
	
	local 0 "`*'" 
        syntax , Generate(string) [ LH PD UH ]
	
	confirm new variable `generate'
	
	if "`lh'`pd'`uh'" != "" & `nr' != `nc' { 
		di in r "matrix not square" 
		exit 498 
	}	

	/* 
	   lh = lower half           1
	   pd = principal diagonal   2 
	   uh = upper half           4
	*/    
	local which = ("`lh'" != "") + 2 * ("`pd'" != "") + 4 * ("`uh'" != "") 
	
	if `which' == 0 | `which' == 7 { /* whole matrix */ 
		local n = `nc' * `nr'  
	} 
	else if `which' == 1 | `which' == 4 { /* lh | uh */ 
		local n = `nc' * (`nc' - 1) / 2 
	} 
	else if `which' == 2 { /* principal diagonal only */ 
		local n = `nc' 
	} 
	else if `which' == 3 | `which' == 6 { /* lh + pd | pd + uh */ 
		local n = `nc' * (`nc' + 1) / 2 
	} 
	else if `which' == 5 { /* lh + uh */ 
		local n = `nc' * (`nc' - 1) 
	}
	
	if `n' > _N { 
		di in r "matrix too large to fit into single variable"
		exit 498 
	} 	

	qui gen `type' `generate' = . 

	local k = 1 
	local i = 1 
	qui while `i' <= `nr' { 
		if `which' == 0 | mod(`which',2)== 1 { /* 0 1 3 5 7 */ 
			local j1 = 1 
		} 
		else if `which' == 2 | `which' == 6 { 
			local j1 = `i' 
		} 
		else if `which' == 4 { 
			local j1 = `i' + 1 
		}
		
		if `which' == 0 | `which' >= 4 { /* 0 4 5 6 7 */ 
			local j2 = `nc' 
		}
		else if `which' == 1 { 
			local j2 = `i' - 1 
		} 
		else if `which' == 2 | `which' == 3 { 
			local j2 = `i' 
		} 
		
		local j = `j1' 
		while `j' <= `j2' { 
			local OK = !(`i' == `j' & `which' == 5) 
			if `OK' { 
				replace `generate' = `A'[`i',`j'] in `k' 
				local k = `k' + 1 
			}	
			local j = `j' + 1 
		} 	
		local i = `i' + 1 
	} 		
		
end

