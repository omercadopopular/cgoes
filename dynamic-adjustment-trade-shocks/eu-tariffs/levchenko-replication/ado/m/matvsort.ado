*! 1.1.0 NJC 20 April 2000  (STB-56: dm79)
* 1.0.0 NJC 13 April 2000 
program define matvsort
        version 6.0
	gettoken A 0 : 0, parse(" ") 
	gettoken B 0 : 0, parse(" ,") 
	syntax [ , Decrease ] 
	
	capture local nc = colsof(matrix(`A'))
        if _rc {
                di in r "matrix `A' not found"
                exit 111
        }
	
	local nr = rowsof(matrix(`A'))  

	if `nc' > 1 & `nr' > 1 { 
		di in r "`A' not a vector"
		exit 498 
	}

	local nvals = max(`nr', `nc') 

	if `nvals' > _N { 
		di in r "number of observations too small" 
		exit 198 
	}	

	tempvar values names 	
	tempname C val 

	qui { 
		gen double `values' = . 
		gen str1 `names' = "" 
		mat `C' = J(`nr', `nc', 0)

		if `nr' == 1 { 
			local Names : colfullnames(`A')
			local Row : rowfullnames(`A') 
			local i = 1 
			while `i' <= `nc' { 
				replace `values' = `A'[1, `i'] in `i' 
				local Name : word `i' of `Names'
	                        replace `names' = "`Name'" in `i'
        	                local i = `i' + 1
			} 
		} 	
		else { 
			local Names : rowfullnames(`A') 
			local Col : colfullnames(`A') 
			local i = 1 
			while `i' <= `nr' { 
				replace `values' = `A'[`i', 1] in `i' 
				local Name : word `i' of `Names'
	                        replace `names' = "`Name'" in `i'
        	                local i = `i' + 1
			} 
		}
	 
	 	if "`decrease'" != "" { replace `values' = -`values' } 
		sort `values' 
	 	if "`decrease'" != "" { replace `values' = -`values' }
		
		local Names
		local i = 1 
		while `i' <= `nvals' { 
			local Name = `names'[`i'] 
			local Names "`Names' `Name'" 
			local i = `i' + 1 
		}
			
		if `nr' == 1 { 
			local i = 1 
			while `i' <= `nc' {
				scalar `val' = `values'[`i'] 
				mat `C'[1, `i'] = `val'  
			        local i = `i' + 1
			} 
		} 	
		else { 
			local i = 1 
			while `i' <= `nr' {
				scalar `val' = `values'[`i'] 
				mat `C'[`i', 1] = `val'  
			        local i = `i' + 1
			} 
		} 	
	} 
	
	mat `B' = `C'

	if `nr' == 1 { 
		mat colnames `B' = `Names' 
		mat rownames `B' = `Row' 
	}
	else {
		mat rownames `B' = `Names'
		mat colnames `B' = `Col' 
	}	
end

