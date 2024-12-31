*! version 1.0.1  18dec1995
program define dlog_at
/*
   Utility program for dlogit2.ado, dmlogit2.ado, dprobit2.ado;
   program returns x vector based on at() option.

   Syntax:   dlog_at markvar indepvars [weight], x(matname)
						[ at(string) noConstant ]
*/
	version 5.0
	local varlist "req ex"
	local weight "fweight aweight"
	local options "x(string) at(string) noConstant"
	parse "`*'"
	parse "`varlist'", parse(" ")
	local doit "`1'"
	macro shift
	if "`constan'" == "" { local cons 1 }
	else local cons 0

	if "`at'" != "" {
		cap confirm integer number `at'
		if _rc == 0 { /* make x from obs # = `at' */
			obs_at `at' `x' `cons' `*'
			exit
		}
		cap di `at'[1,1]
		if _rc == 0 { /* order `x' to match indepvars */
			order_at `at' `x' `cons' `*'
			exit
		}
		cap count if `doit' & (`at')
		if _rc == 0 & _result(1) == 0 {
			di in red "at(expression) yields no observations" /*
			*/ " in the estimation sample"
			exit 2000
		}
		if _rc {
			di in red "syntax error in at() option"
			exit 198
		}
		local at "& (`at')"  /* valid expression */
	}

	if "`*'"!="" {
		qui mat vecaccum `x' = `doit' `*' [`weight'`exp'] /*
		*/	if `doit' `at', `constan'
		tempname s
		if "`weight'"=="fweight" { scalar `s' = 1/_result(2) }
		else scalar `s' = 1/_result(1)
		mat `x' = `s'*`x'
	}
	else {
		mat `x' = (1)
		mat colname `x' = _cons
	}
	mat rowname `x' = x
end

program define obs_at
	version 4.0
	local at   "`1'"
        if `at' < 1 | `at' > _N {
		di in red "obs. no. specified by at() out of range"
		exit 198
	}
	local x    "`2'"
	local cons "`3'"
	macro shift 3
	local nvars : word count `*'
	local xdim = `nvars' + `cons'
	mat `x' = J(1,`xdim',1)
	local i 1
	capture {
		while `i' <= `nvars' {
			mat `x'[1,`i'] = ``i''[`at']
			local i = `i' + 1
		}
	}
	if _rc == 504 {
		di in red "observation specified by at() has missing values"
		exit 504
	}
	if _rc != 0 { error _rc }

	if `cons' { mat colnames `x' = `*' _cons }
	else        mat colnames `x' = `*'
	mat rowname `x' = x
end

program define order_at
	version 4.0
	local at   "`1'"
	local x    "`2'"
	local cons "`3'"
	macro shift 3
	local nvars : word count `*'
	local xdim = `nvars' + `cons'
	mat `x' = J(1,`xdim',1)
	local i 1
	capture {
		while `i' <= `nvars' {
			mat `x'[1,`i'] = `at'[1,colnumb(matrix(`at'),"``i''")]
			local i = `i' + 1
		}
	}
	if _rc == 504 {
		di in red "matrix specified by at() does not match indepvars"
		exit 198
	}
	if _rc != 0 { error _rc }

	if `cons' {
		cap mat `x'[1,`xdim'] = `at'[1,colnumb(matrix(`at'),"_cons")]
		mat colnames `x' = `*' _cons
	}
	else mat colnames `x' = `*'
	mat rowname `x' = x
end
