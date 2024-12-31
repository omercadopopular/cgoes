*! 1.0.0 NJC 26 Oct 1999 (STB-56: dm79)
program def matvec
* matrix (expression) to vec

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
    local size = `rows' * `cols' 
    local matsize : set matsize 
    if `size' > `matsize' { 
    	di in r "vector of length " `size' " would be required" 
        error 908 
    }  

    mat `B' = `C'[1..., 1]
    local j = 2 
    while `j' <= `cols' { 
        mat `B' = `B' \ `C'[1..., `j']
	local j = `j' + 1 
    } 

    mat colnames `B' = vec 
       
end
