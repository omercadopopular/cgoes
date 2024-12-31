*! version 2.9.0 28mar2017
program define fisid
	syntax varlist [if] [in], [Missok Show]
	loc show = ("`show'" != "")
	loc missok = ("`missok'" != "")

	marksample touse, novar

	if (!`missok') {
		qui cou if `touse'
		loc N = r(N)
		markout `touse' `varlist', strok
		qui cou if `touse'
		if r(N) < `N' {
			local n : word count `varlist'
			local var = cond(`n'==1, "variable", "variables")
			di as err "`var' `varlist' should never be missing"
			exit 459
		}
	}

	mata: fisid("`varlist'", "`touse'", `missok')

	if (!`ok') {
	        loc n : word count `varlist'
	        loc var  = cond(`n'==1, "variable", "variables")
	        loc does = cond(`n'==1, "does", "do")
	        loc msg `var' `varlist' `does' not ///
	        	uniquely identify the observations
	        di as err "`msg'"
	        exit 459
	}
end

mata:
void fisid(string rowvector varnames,
         | string scalar touse,
           real scalar show)
{
	class Factor scalar		F
	real scalar				ok

	F = factor(varnames, touse, 0, "", 0, 1, ., 0)
	ok = F.is_id()
	st_local("ok", strofreal(ok))
}
end


findfile "ftools.mata"
include "`r(fn)'"
exit
