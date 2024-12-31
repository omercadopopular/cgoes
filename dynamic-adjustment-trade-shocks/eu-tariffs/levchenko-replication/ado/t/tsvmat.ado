*! V1 Creates Temporary new variables

*capture program drop tsvmat
program define tsvmat, return
        syntax anything, name(string)
        version 7
		 
        local nx = rowsof(matrix(`anything'))
        local nc = colsof(matrix(`anything'))
        ***************************************
        // here is where the safegards will be done.
        if _N<`nx' {
            display as result "Expanding observations to `nx'"
                set obs `nx'
        }
        // here we create all variables
        foreach i in `name' {
			local j = `j'+1
			qui:gen `type' `i'=matrix(`anything'[_n,`j'])			
        }
        // here is where they are renamed.

end
