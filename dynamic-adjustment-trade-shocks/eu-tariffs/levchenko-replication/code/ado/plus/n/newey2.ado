*! Version 1.11 6/11/09 David Roodman droodman@cgdev.org
*
* Version 1.11: Made nocons work for first stage too. Thanks to James Feyrer for spotting. 
* Version 1.10: For instrumented regressions fixed serious problem where X was used instead of Z in calculating 
* 		    the inner part of the Newey-West sandwich. 
* Version 1.01: Changed "Noconstant" in syntax command to "noCONStant". 
* 
* This is based on ivreg version 5.0.9  and newey version 1.2.9. It can work with 
* panel data and time series. It can work with or without instruments. In the panel 
* case, in computing the Newey-West sum,
* it zeroes out interaction terms involving different groups. It handles missing 
* data differently in the cases of panels and of time series. If panels are 
* unbalanced, FORCE causes interaction terms in the Newey-West sum involving
* missing observations to be zeroed out. But in the case of pure time series ivnewey 
* imitates newey: FORCE causes ivnewey to treat available observations as a 
* complete, evenly spaced series. 

program define newey2, eclass sortpreserve
	version 7.0
	local version 05.00.9

	if !replay() {
		local n 0

		gettoken lhs 0 : 0, parse(" ,[") match(paren)
		IsStop `lhs'
		if `s(stop)' { error 198 }
		while `s(stop)'==0 { 
			if "`paren'"=="(" {
				local n = `n' + 1
				if `n'>1 { 
capture noi error 198 
di in red `"syntax is "(all instrumented variables = instrument variables)""'
exit 198
				}
				gettoken p lhs : lhs, parse(" =")
				while "`p'"!="=" {
					if "`p'"=="" {
capture noi error 198 
di in red `"syntax is "(all instrumented variables = instrument variables)""'
di in red `"the equal sign "=" is required"'
exit 198 
					}
					local end`n' `end`n'' `p'
					gettoken p lhs : lhs, parse(" =")
				}
				tsunab end`n' : `end`n''
				tsunab exog`n' : `lhs'
			}
			else {
				local exog `exog' `lhs'
			}
			gettoken lhs 0 : 0, parse(" ,[") match(paren)
			IsStop `lhs'
		}
		local 0 `"`lhs' `0'"'

		tsunab exog : `exog'
		tokenize `exog'
		local lhs "`1'"
		local 1 " " 
		local exog `*'

		syntax [if] [in] [aw/], LAG(integer) [FIRST hc2 hc3 noCONstant T(string) I(string) FORCE Level(integer $S_level)]

		if `lag'<0 { 
			di in red `"lag(`lag') invalid"'
			exit 198
		}

		if "`hc2'`hc3'" != "" {
			if "`hc2'"!="" {
				di in red "option `hc2' invalid"
			}
			else	di in red "option `hc3' invalid"
			exit 198
		}

		marksample touse

		quietly {
			xt_tis `t'
			local tvar `"`s(timevar)'"'
			capture xt_iis `i'
			local ists = (_rc==198)
			if `ists' {
				noi display "No panel variable found. Time series assumed."
				markout `touse' `tvar' `lhs' `exog' `exog1' `end1'
				Checkt `tvar' `touse'
			}
			else {
				local ivar `"`s(ivar)'"'
				markout `touse' `tvar' `ivar' `lhs' `exog' `exog1' `end1'
				xt_Checkt `tvar' `ivar' `touse'
			}
			if r(tflag)==2 {
				noi di in red /*
					*/ `"`tvar' has duplicate values"'
					exit 198
			}
			if r(tflag)==1 & `lag' > 0 & `"`force'"' == "" {
				noi di in red /*
*/ `"`tvar' is not regularly spaced -- use the force option to override"'
				exit 198
			}

			local depv `lhs'
			local indv `end1' `exog' 
 			if `"`constant'"'==`""' {
				tempvar CONS
				gen byte `CONS' = 1
				local carg `""'
			}
			else {
				local CONS `""'
				local carg `"nocons"'
				if `"`indv'"'==`""' {
					di in red /*
			*/ `"may not specify noconstant without regressors"'
					exit 198
				}
			}
			local indc `"`indv' `CONS'"'

			tempvar wvar
			if `"`exp'"'==`""' {
				gen byte `wvar'=1
				local weight `"fweight"'
			}
			else {
				gen double `wvar' = `exp'
				summ `wvar' if `touse'
				replace `wvar' = `wvar'/r(mean) if `touse'
			}
			local wtexp `"[`weight'=`wvar']"'
		}

		Subtract newexog : "`exog1'" "`exog'"

/* now check for perfect collinearity in instrument list */
		_rmcoll `newexog'
		local newexog "`r(varlist)'"

		local endo_ct : word count `end1'
		local ex_ct : word count `newexog'
		if `endo_ct' > `ex_ct' {
			di in red "equation not identified; must have at " /*
			*/ "least as many instruments not in"
			di in red "the regression as there are "           /*
			*/ "instrumented variables"
			exit 481
		}

		if "`first'"!="" {
			di in gr _newline "First-stage regressions"
			di in smcl in gr     "{hline 23}"
		}	

		preserve

		tokenize `end1'

		forvalues i = 1/`endo_ct' {
			if "`first'"!="" {
				regress ``i'' `exog' `newexog' `wtexp' if `touse', `constant'
			}
			else {
				quietly regress ``i'' `exog' `newexog' `wtexp' if `touse', `constant'
			}
			tempvar `i'b
			ren ``i'' ``i'b'
			quietly predict double ``i'' if `touse'
		}
		display

		quietly {
			reg `depv' `indv' if `touse' `wtexp', `carg'
			if e(N)==0 | e(N)==. { 
				di in red `"no observations"'
				exit 2000
			}
			local nobs=e(N)
			local mdf=e(df_m)
			local tdf=e(df_r)
			*local rmse=e(rmse)
			global S_4 `"`indv'"' 
			noi fixnames
			local xv `"$S_1"'
			local indc `"$S_2 `CONS'"'
			local nx $S_3
			tempname beta /* scale */
			mat `beta' = e(b)

			forvalues i = 1/`endo_ct' {
				tempvar `i'i
				ren ``i'' ``i'i'
				ren ``i'b' ``i''
			}
			tempvar e 
			predict double `e' if `touse', resid
			forvalues i = 1/`endo_ct' {
				ren ``i'' ``i'b'
				ren ``i'i' ``i''
			}

			*	scalar `scale' = sqrt(`rmse')

			tempvar vt1 vt2
			gen double `vt1' = .
			gen double `vt2' = .
			tempname ztz tt tx tx2 xtix tp2 tx3 xtiy

			if `"`weight'"'=="aweight" {
				local ow `"`wvar'"'
			}
			else 	local ow 1

			if !`ists' {
				tsfill, full
				sort `ivar' `tvar'
				tempvar lagflag
				gen `lagflag' = .
			}
			local zv `exog' `exog1'
			forvalues j = 0/`lag' {
				if `ists' {
					local lagflag 1
				}
				else {
					replace `lagflag' = (`ivar'==`ivar'[_n-`j'])* `touse'[_n-`j']
				}
				local i 1
				foreach z of varlist `zv' `CONS' {
					replace `vt1' = `z'[_n-`j']*`e'* /*
					*/ `e'[_n-`j']*`wvar'[_n-`j']* /*
					*/ `ow' * `lagflag' if `touse'
					mat vecaccum `tx' = `vt1' `zv' if `touse', `carg'
					mat `tt' = nullmat(`tt') \ `tx'
				}
				mat `tt' = (`tt'+`tt'')*(1-`j'/(1+`lag'))
				if `j' > 0 {
					mat `ztz' = `ztz' + `tt'
				}
				else {
					mat `ztz' = `tt' * 0.5
				}
				mat drop `tt' 
			}
			tempname XZ ZZ V tmp
			foreach z of varlist `zv' `CONS' {
				mat vecaccum `tmp' = `z' `indv' if `touse' `wtexp', `carg'
				mat `XZ' = nullmat(`XZ') , `tmp''
				mat vecaccum `tmp' = `z' `zv' if `touse' `wtexp', `carg'
				mat `ZZ' = nullmat(`ZZ') , `tmp''
			}
			mat `ZZ' = syminv((`ZZ' + `ZZ'')/2)
			mat `V' = `XZ' * `ZZ' * `XZ''
			mat `V' = syminv((`V' + `V'')/2) * `XZ' * `ZZ'
			mat `V' = `V' * `ztz' * `V''
			mat `V' = (`V' + `V'')/2 * `nobs'/`tdf'
			restore

			est post `beta' `V', dof(`tdf') obs(`nobs') depname(`depv') esample(`touse')

			if `"`indv'"'==`""' {
				est scalar df_m = 0
				est scalar df_r = `tdf'
				est scalar F = .
			}
			else {
				qui test `indv', min
				est scalar df_m = r(df)
				est scalar df_r = r(df_r)
				est scalar F = r(F)
			}


			/* Double saves */
			global S_E_mdf = e(df_m)
			global S_E_tdf = e(df_r)
			global S_E_f = e(F)


			est local depvar `"`depv'"'
			est scalar N =  `nobs'
			est scalar lag =  `lag'
			if `lag'==0 {
				est local vcetype `"Robust"'
			}
			else {
				est local vcetype `"Newey-West"'
			}

			est local predict newey2_p
			if "`weight'"!="" {
				est local wtype "`weight'"
				est local wexp `"`exp'"'
			}

			est local cmd 
			est local version `version'
			est local instd `end1'
			if "`end1'" != "" {
				est local insts `exog' `newexog'
				est local model iv
			}
			else {
				est local model ols
			}
			est local cmd newey2

			/* Double saves */
			global S_E_depv `"`e(depvar)'"'
			global S_E_nobs `"`e(N)'"'
			global S_E_lag  `"`e(lag)'"'
			global S_E_vce  `"`e(vcetype)'"'
			global S_E_cmd  `"`e(newey2)'"'
		}
	}
	else {
		if `"`e(cmd)'"' != "newey2"  { error 301 }
		if _by() { error 190 } 

		syntax [, Level(integer $S_level)]

		if `level' < 10 {
			local level = 10
		}
		if `level' > 99 {
			local level = 99
		}
	}

	if e(lag)>0 {
		local errtype ="Newey-West"
	}
	else {
		local errtype = "robust"
	}
	if `"`e(instd)'"'==""  {
		local regtype ="Regression"
	}
	else {
		local regtype ="IV(2SLS) regression"
	}		

	#delimit ;
	di _n in gr 		"`regtype' with `errtype' standard errors"
		_col(53)
		`"Number of obs  ="' in yel %10.0f e(N) _n
		in gr `"maximum lag : "' in ye e(lag)   
		_col(53) 
		in gr 
		`"F("' in gr %3.0f e(df_m) in gr `","' in gr %6.0f e(df_r) 	
		in gr `")"' _col(68) `"="' in ye %10.2f e(F) _n
	        /* in gr `"coefficients: "' /*
		*/ in ye `"`e(vcetype)' least squares"' */
		_col(53) in gr `"Prob > F       =    "' 
		in ye %6.4f fprob(e(df_m),e(df_r),e(F)) _n ;
		
	#delimit cr
	est display, level(`level')

	if `"`e(instd)'"'!="" {
		di in gr "Instrumented:  " _c
		Disp `e(instd)'
		di in gr "Instruments:   " _c
		Disp `e(insts)'
		di in smcl in gr "{hline 78}"
	}
end


program define IsStop, sclass
				/* sic, must do tests one-at-a-time, 
				 * 0, may be very large */
	if `"`0'"' == "[" {		
		sret local stop 1
		exit
	}
	if `"`0'"' == "," {
		sret local stop 1
		exit
	}
	if `"`0'"' == "if" {
		sret local stop 1
		exit
	}
	if `"`0'"' == "in" {
		sret local stop 1
		exit
	}
	if `"`0'"' == "" {
		sret local stop 1
		exit
	}
	else	sret local stop 0
end


program define Disp 
	local first ""
	local piece : piece 1 64 of `"`0'"'
	local i 1
	while "`piece'" != "" {
		di in gr "`first'`piece'"
		local first "               "
		local i = `i' + 1
		local piece : piece `i' 64 of `"`0'"'
	}
	if `i'==1 { di }
end

/*  Remove all tokens in dirt from full */
 *  Returns "cleaned" full list in cleaned */

program define Subtract   /* <cleaned> : <full> <dirt> */
	args	    cleaned     /*  macro name to hold cleaned list
		*/  colon	/*  ":"
		*/  full	/*  list to be cleaned 
		*/  dirt	/*  tokens to be cleaned from full */
	
	tokenize `dirt'
	local i 1
	while "``i''" != "" {
		local full : subinstr local full "``i''" "", word all
		local i = `i' + 1
	}

	tokenize `full'			/* cleans up extra spaces */
	c_local `cleaned' `*'       
end


program define fixnames
	tempname b v
	mat `b' = e(b)
	mat `v' = e(V)

	local xnam : colnames(`b')
	local nx : word count `xnam'

	tokenize `"`xnam'"'
	local i 1
	while `i' <= `nx' {
		if `b'[1,`i'] == 0 & `v'[`i',`i'] == 0 {
			local vnam : word `i' of `xnam'
			/*noi di in gr _n `"`vnam' "' in blue */ /*
			*/ /*`"dropped due to collinearity"' */
			local ``i'' `" "'
			global S_5 = 1
		}
		local i = `i'+1
	}
	local xnam `"`*'"'
	local nx : word count `xnam'
	tokenize `"`xnam'"'
	if `"``nx''"' == `"_cons"' {
		local `nx' `""'
	}
	global S_1 `"`xnam'"'
	global S_2 `"`*'"'
	global S_3 = `nx'
end
	
program define Checkt, rclass
	args tvar touse 

	replace `touse'=. if `touse'==0
	ret scalar tflag = 0 
	sort `touse' `tvar'
	tempvar tt
	gen `tt' = `tvar'-`tvar'[_n-1] if `touse'!=.	
	summ `tt', meanonly
	if r(min) != r(max) {
		ret scalar tflag = 1
	}
	if r(min) == 0 {
		ret scalar tflag = 2
	}
	replace `touse'=0 if `touse'==.
	sort `touse' `tvar'
end

program define xt_Checkt, rclass
	args tvar ivar touse 

	replace `touse'=. if `touse'==0
	ret scalar tflag = 0 
	sort `touse' `ivar' `tvar'
	tempvar tt
	gen `tt' = `tvar'-`tvar'[_n-1] if `touse'!=. & `ivar'==`ivar'[_n-1]	
	summ `tt', meanonly
	if r(min) != r(max) {
		ret scalar tflag = 1
	}
	if r(min) == 0 {
		ret scalar tflag = 2
	}
	replace `touse'=0 if `touse'==.
	sort `touse' `ivar' `tvar'
end
exit
