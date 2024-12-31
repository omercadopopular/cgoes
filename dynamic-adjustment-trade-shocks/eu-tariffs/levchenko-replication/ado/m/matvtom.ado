*! matvtom 1.0.0 NJC 13 December 1999  (STB-56: dm79)
program define matvtom
        version 6.0
	
	gettoken A 0 : 0, parse(" ,") 
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

	local isrow = `nr' == 1 
	
        gettoken B 0 : 0, parse(" ,")  
	if "`B'" == "" | "`B'" == "," { 
		di in r "must specify matrix for output" 
		exit 498 
	} 
	
	syntax , Row(integer) Col(integer) Order(str) 
	
	local init = substr("`order'",1,1) 
	if "`init'" != "r" & "`init'" != "c" { 
		di in r "order( ) must be by rows (r) or columns (c)" 
		exit 498 
	} 	
	local byrow = "`init'" == "r" 

	if (`row' * `col') != (`nr' * `nc') { 
		di in r /* 
		*/ "`row' X `col' matrix not possible from `nr' X `nc' vector"
		exit 498 
	} 	
	
	tempname C 
	matrix `C' = J(`row', `col', 0) 

	local k = 1 
	local I = cond(`byrow', "i", "j")
	local J = cond(`byrow', "j", "i") 
	local Ilast = cond(`byrow', `row', `col') 
	local Jlast = cond(`byrow', `col', `row') 
	local `I' = 1
	while ``I'' <= `Ilast' { 
		local `J' = 1 
		while ``J'' <= `Jlast' { 
			matrix `C'[`i',`j'] = /* 
			*/ cond(`isrow', `A'[1,`k'], `A'[`k',1]) 
			local `J' = ``J'' + 1 
			local k = `k' + 1 
		} 
		local `I' = ``I'' + 1 
	} 

	matrix `B' = `C' 
end

