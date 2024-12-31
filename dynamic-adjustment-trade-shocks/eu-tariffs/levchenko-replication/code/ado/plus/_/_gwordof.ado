*! 1.0.0 NJC 17 July 2000 
program define _gwordof 
    version 6.0

    gettoken type 0 : 0
    gettoken g    0 : 0
    gettoken eqs  0 : 0

    syntax varlist(max=1 string) [if] [in] , Word(int) 

    marksample touse, strok
    local type "str1" /* ignores type passed from -egen- */

    quietly {
        gen `type' `g' = ""
        local i = 1
        while `i' <= _N  {
            if `touse'[`i'] {
                local value = `varlist'[`i']
                local nw : word count `value' 
		local which = cond(`word' < 0, `nw' + `word' + 1, `word')
		if `which' > 0 { 
		    local value : word `which' of `value'  
		    replace `g' = `"`value'"' in `i' 
		} 
            }
            local i = `i' + 1
        }
    }
end

