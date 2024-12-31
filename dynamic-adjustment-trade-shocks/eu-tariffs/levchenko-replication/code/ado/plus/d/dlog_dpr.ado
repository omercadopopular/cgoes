*! version 1.0.1  10jan1996
program define dlog_dpr
	version 5.0
	local cmd "`1'"
	macro shift
	local options "Level(integer $S_level) noDISPat"
	if substr("`1'",1,1)=="," | "`*'"=="" {
		if "$S_E_cmd"!="d`cmd'2" {
			error 301
		}
		parse "`*'"
	}
	else {
		local varlist "req ex"
		local weight "aweight fweight"
		local if "opt"
		local in "opt"
		local options "`options' AT(string) LOG noCONstant *"
		parse "`*'"
		tempname b V x
		tempvar doit z
		mark `doit' [`weight'`exp'] `if' `in'
		markout `doit' `varlist'
		parse "`varlist'", parse(" ")
		local y "`1'"

	/* Run `cmd'. */

		if "`log'"=="" {
			`cmd' `varlist' [`weight'`exp'] if `doit', /*
			*/	`options' `constan' nocoef nolog
		}
		else {
			`cmd' `varlist' [`weight'`exp'] if `doit', /*
			*/	`options' `constan'
		}
		mat `b' = get(_b)
		mat `V' = get(VCE)
		local nobs = _result(1)
		local ll   = _result(2)
		local pr2  = _result(7)

	/* Use colnames for indepvars since some may have been dropped. */

		local colname : colnames(`b')
		parse "`colname'", parse(" ")
		local dim = colsof(`b')
		if "``dim''"=="_cons" { local `dim' /* erase "_cons" */ }

	/* Check for dropped observations. */

		qui predict `z' if `doit'
		markout `doit' `z'

	/* Get x. */

		if "`at'"!="" { local at "at(`at')" }

		dlog_at `doit' `*' [`weight'`exp'], x(`x') `at' `constan'

	/* Compute dF/dx and its covariance */

		dFdx `cmd' `x' `b' `V'  /* new b and V returned */

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
		global S_E_cmd  "d`cmd'2"
	}

/* Display results. */

	#delimit ;
	di _n in gr "Marginal effects from `cmd'" _col(54)
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

program define dFdx
	version 4.0
	local cmd "`1'" /* Input:  "probit" or "logit"       */
	local x   "`2'" /* Input:  row vector of x values    */
	local b   "`3'" /* Input:  beta                      */
		        /* Output: dF/dx marginal effects    */
	local V   "`4'" /* Input:  covariance matrix of beta */
		        /* Output: covariance of dF/dx       */
	tempname z df f p D I

	mat `z' = `b'*`x''

	if "`cmd'"=="probit" {
		scalar `df' = -`z'[1,1]
		scalar `f'  = exp(-`z'[1,1]*`z'[1,1]/2)/sqrt(2*_pi)
	}
	else { /* "logit" */
		scalar `p'  = exp(`z'[1,1])/(1 + exp(`z'[1,1]))
		scalar `df' = 1 - 2*`p'
		scalar `f'  = `p'*(1 - `p')
	}
	mat `D' = `b''*`x'
	mat `D' = `df'*`D'
	local dim = colsof(`b')
	mat `I' = I(`dim')
	mat `D' = `I' + `D'
	mat `D' = `f'*`D'
	mat `b' = `f'*`b'

/* If `V' is singular, zero corresponding row of D. */

	mat `z' = J(1, `dim', 0)
	global S_1  /* erase macro */
	local i 1
	while `i' <= `dim' {
		if `V'[`i',`i'] == 0 {
			mat sub `D'[`i',1] = `z'
			global S_1 "singular"
		}
		local i = `i' + 1
	}
	local colname : colnames(`V')
	mat `V' = `D'*`V'
	mat `V' = `V'*`D''
	mat colnames `b' = `colname'
	mat colnames `V' = `colname'
	mat rownames `V' = `colname'
end
