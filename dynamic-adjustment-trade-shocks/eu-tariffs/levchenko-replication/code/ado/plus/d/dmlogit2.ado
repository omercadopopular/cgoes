*! version 1.0.3  31jan1996
program define dmlogit2
	version 5.0
	local options "Level(integer $S_level) noDISPat"
	if substr("`1'",1,1)=="," | "`*'"=="" {
		if "$S_E_cmd"!="dmlogit2" {
			error 301
		}
		parse "`*'"
	}
	else {
		local varlist "req ex"
		local weight "fweight aweight"
		local if "opt"
		local in "opt"
		local options "`options' AT(string) LOG noConstant *"
		parse "`*'"
		if "`log'"=="" {
			local log "quietly"
		}
		else local log
		tempname b V x
		tempvar doit
		mark `doit' [`weight'`exp'] `if' `in'
		markout `doit' `varlist'
		parse "`varlist'", parse(" ")
		local y "`1'"

	/* Run mlogit. */

		`log' mlogit `varlist' [`weight'`exp'] if `doit', /*
		*/	`options' `constan'
		mat `b'  = get(_b)
		mat `V'  = get(VCE)
		local nobs = _result(1)
		local ll   = _result(2)
		local pr2  = _result(7)

	/* Use colnames for indepvars since some may have been dropped. */

		local colname : colnames(`b')
		parse "`colname'", parse(" ")
		local dim = colsof(`b')
		if "``dim''"=="_cons" { local `dim' /* erase "_cons" */ }

	/* Get x. */

		if "`at'"!="" { local at "at(`at')" }

		dlog_at `doit' `*' [`weight'`exp'], x(`x') `at' `constan'

	/* Compute dP/dx and its covariance. */

		dPdx `x' `b' `V'  /* new b and V returned */

		local sing "$S_1"

	/* Post results. */

		mat post `b' `V', depn(`y') obs(`nobs')

	/* Compute test of indepvars = 0. */

		if "`constan'"=="" & "`*'"!="" & "`sing'"=="" {
			qui test `*'
			global S_E_mdf  = _result(3)
			global S_E_chi2 = _result(6)
		}
		else if "`sing'"!="" {
			global S_E_mdf  "."
			global S_E_chi2 "."
		}

		matrix S_E_x    = `x'
		global S_E_nobs "`nobs'"
		global S_E_ll   "`ll'"
		global S_E_pr2  "`pr2'"
		global S_E_depv "`y'"
		global S_E_cmd  "dmlogit2"
	}

/* Display results. */

	#delimit ;
	di _n in gr "Marginal effects from multinomial regression" _col(54)
	   "Number of obs   = " in ye %7.0g $S_E_nobs ;
	if "$S_E_mdf"!="" { ;
		di _col(54) in gr "chi2(" in ye $S_E_mdf in gr ")"
		   _col(70) "= " in ye %7.2f $S_E_chi2 _n
		   _col(54) in gr "Prob > chi2     = "
		   in ye %7.4f chiprob($S_E_mdf, $S_E_chi2) _c ;
	} ;
	di _n in gr "Log Likelihood = " in ye %10.0g $S_E_ll _col(54)
	      in gr "Pseudo R2       = " in ye %7.4f $S_E_pr2 _n ;
	#delimit cr

	mat mlout, level(`level')

	if "`dispat'"=="" {
		di in gr "Marginal effects evaluated at"
		mat list S_E_x, noheader format(%9.0g)
	}
end

program define dPdx
	version 4.0
	local x  "`1'" /* Input:  row vector (1 x k) of x values      */
	local b  "`2'" /* Input:  beta (m x k) from mlogit            */
		       /* Output: dP/dx marginal effects row vector   */
	local V  "`3'" /* Input:  covariance matrix (mk x mk) of beta */
		       /* Output: covariance of dP/dx                 */
	tempname A P s sum I r D C E
	local m = rowsof(`b')
	local k = colsof(`b')
	mat `A' = `b'*`x''
	mat `P' = J(`m',`m',0)
	scalar `sum' = 1
	local i 1
	while `i' <= `m' {
		scalar `s' = exp(`A'[`i',1])
		scalar `sum' = `sum' + `s'
		mat `P'[`i',`i'] = `s'
		local i = `i' + 1
	}
	scalar `sum' = 1/`sum'
	mat `P' = `sum'*`P'
	mat `A' = J(`m',`m',1)
	mat `A' = `A'*`P'
	mat `A' = `A'*`b'
	mat `A' = `b' - `A'

	mat `I' = I(`k')
	mat `r' = J(1,`m',0)
	local mk = `m'*`k'
	mat `D' = J(`mk',`mk',0)
	local i 1
	while `i' <= `m' {
		local ki = `k'*(`i'-1) + 1

	/* Make new b a row vector. */

		mat `C' = `A'[`i',.]
		scalar `s' = `P'[`i',`i']
		mat `C' = `s'*`C'
		if `i' == 1 { mat `b' = `C' }
		else mat `b' = `b' , `C'

	/* Do j = i. */
		mat `C' = `A'[`i',.]
		scalar `s' = 1 - 2*`P'[`i',`i']
		mat `C' = `s'*`C'
		mat `C' = `C''*`x'
		scalar `s' = 1 - `P'[`i',`i']
		mat `E' = `s'*`I'
		mat `C' = `E' + `C'
		scalar `s' = `P'[`i',`i']
		mat `C' = `s'*`C'
		mat sub `D'[`ki',`ki'] = `C'

	/* Do j < i. */
		mat `r'[1,`i'] = 1
		local j 1
		while `j' < `i' {
			mat `r'[1,`j'] = 1
			mat `C' = `r'*`A'
			mat `C' = `C''*`x'
			mat `C' = `I' + `C'
			scalar `s' = -`P'[`i',`i']*`P'[`j',`j']
			mat `C' = `s'*`C'
			local kj = `k'*(`j'-1) + 1
			mat sub `D'[`ki',`kj'] = `C'
			mat sub `D'[`kj',`ki'] = `C'
			mat `r'[1,`j'] = 0
			local j = `j' + 1
		}
		mat `r'[1,`i'] = 0
		local i = `i' + 1
	}

/* If `V' is singular, zero corresponding row of D. */

	mat `r' = J(1, `mk', 0)
	global S_1  /* erase macro */
	local i 1
	while `i' <= `mk' {
		if `V'[`i',`i'] == 0 {
			mat sub `D'[`i',1] = `r'
			global S_1 "singular"
		}
		local i = `i' + 1
	}

/* Make new V. */

	mat `E' = `V'
	mat `V' = `D'*`V'
	mat `V' = `V'*`D''

/* Symmetrize V (it may be slightly off due to numerical error). */

	mat `D' = `V''
	mat `V' = `V' + `D'
	scalar `s' = 0.5
	mat `V' = `s'*`V'

/* Label new b and V.  We do it in this strange fashion in case equation
   names contain spaces (which is possible since names can come from value
   labels).
*/
	mat `r' = `E'[1,.]
	scalar `s' = 0
	mat `r' = `s'*`r'
	mat `E' = `s'*`E'
	mat `b' = `b' + `r'
	mat `V' = `V' + `E'
end
