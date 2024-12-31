*! version 3.1.4 CFBaum 25mar2006 from 3.1.1 _gsum
program define _gtotal0
version 8.2 
syntax newvarname =/exp [if] [in] [, BY(varlist)] 
tempvar touse temp1 
quietly { 
	gen byte `touse'=1 `if' `in' 
	bys `touse' `by': gen `typlist' `varlist' = sum(`exp') if `touse'==1 
	by `touse' `by': gen `temp1' = sum((`exp')<.) 
	by `touse' `by': replace `varlist' = cond(`temp1'[_N]==_N,`varlist'[_N],.) 
	} 
end



