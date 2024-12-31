*! Nick Winter 1.0.2 10 Oct 2002
program define _gnoccur
	version 7

	gettoken type 0 : 0
	gettoken g    0 : 0
	gettoken eqs  0 : 0

	syntax varname(string) [if] [in] , String(string)

	local size = length(`"`string'"')
	tempvar new pos count
	qui {
		gen str1 `new' = ""
		replace `new' = `varlist'
		gen int `count' = 0 
		gen int `pos' = index(`new',`"`string'"') 
		capture assert `pos' == 0 `if' `in'
		
		while _rc {
			replace `count' = `count' + (`pos' != 0) 
			replace `new' = substr(`new',`pos'+`size',.)
			replace `pos' = index(`new',`"`string'"') 
			capture assert `pos' == 0 `if' `in'
		}

		* ignore user-specified type; a byte will often be enough
		gen int `g' = `count' `if' `in'
		compress `g'
	}
end

/* 
There is a trade-off on `if' `in': 
0. We only to generate `if' `in' 
1. We don't want to loop if there is nothing left to count 
2. We suspect that `if' can slow things down 
*/ 
