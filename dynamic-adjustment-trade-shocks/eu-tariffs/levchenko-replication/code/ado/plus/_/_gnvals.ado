*! 1.0.1 NJC 20 November 2000 
*! 1.0.0 NJC 20 July 2000 
program define _gnvals
        version 6
        gettoken type 0 : 0 
        gettoken g 0 : 0
        gettoken eqs 0 : 0

        syntax varlist [if] [in] [, by(varlist) MISSing]
        tempvar touse
        quietly {
                mark `touse' `if' `in'
                if "`missing'" == "" {
                        markout `touse' `varlist', strok 
                }
                sort `touse' `by' `varlist' 
                by `touse' `by' `varlist': gen `type' `g' = _n == 1 if `touse' 
                by `touse' `by' : replace `g' = sum(`g') if `touse' 
                by `touse' `by' : replace `g' = `g'[_N] if `touse' 
		
        }
end

