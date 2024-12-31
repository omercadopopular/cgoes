*! 1.0.0 NJC 17 July 2000 
program define _gnwords
    version 6.0

    gettoken type 0 : 0
    gettoken g    0 : 0
    gettoken eqs  0 : 0

    syntax varlist(max=1 string) [if] [in]

    marksample touse, strok
    local type "byte" /* ignores type passed from -egen- */

    quietly {
        gen `type' `g' = . 
        local i = 1
        while `i' <= _N  {
            if `touse'[`i'] {
                local value = `varlist'[`i']
                local nw : word count `value'
                replace `g' = `nw' in `i'
            }
            local i = `i' + 1
        }
    }
end

