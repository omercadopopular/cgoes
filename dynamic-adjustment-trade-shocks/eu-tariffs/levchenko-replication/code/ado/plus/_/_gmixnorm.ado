*! _gmixnorm   CFBaum  09may2005  function to generate mixture of normals 
*              with differing means and variances (invoke as mixnorm() ) 
*	       MU1, MU2: means of distributions 1 and 2 (default 0 0)
*              VAR1, VAR2 = variances of distributions 1 and 2 (default 1 1)
*              Frac: fraction of sample with Low variance (default 0.5)

capt program drop _gmixnorm
program _gmixnorm, rclass
	version 8

	gettoken type 0 : 0 
     	gettoken g 0 : 0 
     	gettoken eqs 0 : 0 
	syntax anything [, Frac(real 0.5) MU1(real 0) MU2(real 0) VAR1(real 1) VAR2(real 1) ]

	if `frac' < 0.01 | `frac' > 0.99 {
		di as err "frac must be in unit interval"
		error 198
		}
	if `var1' <= 0 | `var2' <= 0  {
		di as err "var1 and var2 must be > 0"
		error 198
		}
	tempname s1 s2
	scalar `s1' = sqrt(`var1')
	scalar `s2' = sqrt(`var2')
	qui g `type' `g' = cond(uniform() < `frac', ///
	    `s1'*invnorm(uniform()) + `mu1', /// 
	    `s2'*invnorm(uniform()) + `mu2')
end
