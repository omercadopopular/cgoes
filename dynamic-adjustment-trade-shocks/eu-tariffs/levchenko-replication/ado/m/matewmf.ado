*! 1.0.0  NJC 25 January 2000  (STB-56: dm79)
program define matewmf 
	version 6.0
	gettoken A 0 : 0
	gettoken B 0 : 0, parse(" ,") 
	syntax , Function(str) 
	
	local nr = rowsof(matrix(`A'))
	local nc = colsof(matrix(`A'))
	
	tempname C 
	mat `C' = `A'  

	local i 1
	while `i' <= `nr' {
        	local j 1
		while `j' <= `nc' {
			local val = `function'(`A'[`i',`j'])
			if `val' == . {
				di in r "matrix would have missing values"
				exit 504
		        }
			mat `C'[`i',`j'] = `val' 
		        local j = `j' + 1
	        }
	        local i = `i' + 1
	}

	mat `B' = `C' /* allows overwriting of either `A' or `B' */
end
