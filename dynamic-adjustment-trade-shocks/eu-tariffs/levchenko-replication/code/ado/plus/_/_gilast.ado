*! 1.0.0 NJC 8 Feb 2000
program define _gilast 
        version 6.0
        gettoken type 0 : 0
        gettoken g 0 : 0
        gettoken eqs 0 : 0
        syntax varname(numeric) [if] [in], Value(int) /* 
	*/ [ BY(varlist) BEfore After ]
	
	if ("`before'" != "") & ("`after'" != "") { 
		di in r "must choose between -before- and -after-" 
		exit 198 
	}	

	tempvar touse order neqval 
        mark `touse' `if' `in' 
	gen long `order' = _n 
	sort `touse' `by' `order' 
	
        quietly {	
                by `touse' `by' : gen `neqval' = /* 
		*/ sum(`varlist' == `value') if `touse'
		
		/* ignore user-supplied `type' */
		if "`before'`after'" == "" { 
			by `touse' `by': gen byte `g' = /* 
	*/ `neqval' == `neqval'[_N] & `neqval' != `neqval'[_n-1] if `touse' 
			by `touse' `by': replace `g' = 0 /* 
			*/ if `neqval'[_N] == 0 			
		}
		else if "`before'" != "" { 
			by `touse' `by': gen byte `g' = /* 
		*/ `neqval' < `neqval'[_N] | `neqval'[_N] == 0 
		} 	
		else if "`after'" != "" { 
			by `touse' `by': gen byte `g' = /* 
	*/ `neqval' == `neqval'[_N] & `neqval' == `neqval'[_n-1] if `touse' 
			by `touse' `by': replace `g' = 0 /* 
			*/ if `neqval'[_N] == 0 
		} 
	}	
end
