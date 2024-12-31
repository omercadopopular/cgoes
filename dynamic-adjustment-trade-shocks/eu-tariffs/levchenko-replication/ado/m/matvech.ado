*! 1.0.0 NJC 26 Oct 1999 (STB-56: dm79)
program def matvech
* matrix (expression) to vech

    version 6.0
    args A B 
    if "`A'" == "" | "`B'" == "" | "`3'" != "" {
        di in r "invalid syntax"
        exit 198
    }
    
    tempname C 
    mat `C' = `A' /* this will fail if `A' does not define a matrix */
   
    local cols = colsof(`C') 
    local rows = rowsof(`C') 
    if `cols' != `rows' { 
    	di in r "matrix not square" 
	exit 498 
    }	
    
    local size = `cols' * (`cols' + 1) / 2 
    local matsize : set matsize 
    if `size' > `matsize' { 
    	di in r "vector of length " `size' " would be required" 
        error 908 
    }  

    mat `B' = `C'[1..., 1]
    local j = 2 
    while `j' <= `cols' { 
        mat `B' = `B' \ `C'[`j'..., `j']
	local j = `j' + 1 
    } 	

    mat colnames `B' = vech 
       
end
