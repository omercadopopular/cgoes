*! 1.1.1 MLB 19 Apr 2010
*! 1.0.4 MLB 31 Aug 2008
*! 1.1.0 MLB 11 Feb 2010
*! 1.0.3 MLB 05 Sep 2006
*! 1.0.2 MLB 01 Jun 2006
*! 1.0.1 NJC 17 Apr 2006
*! 1.0.0 MLB 08 Apr 2006
* Fit dirichlet distribution by ML in either of two parameterizations
* Based on -betafit- by NJC & SPJ & MLB

/*------------------------------------------------ playback request */
program dirifit, eclass byable(onecall)
	version 8.2
	if replay() {
		if "`e(cmd)'" != "dirifit" {
			di as err "results for dirifit not found"
			exit 301
		}
		if _by() error 190 
		Display `0'
		exit `rc'
	}
	syntax varlist [if] [in] [fw aw], *
	macro drop S_*
	global S_k: word count `varlist'
	forvalues i = 1/$S_k {
		global S_alpha "$S_alpha ALPHA`i'(varlist numeric)"
		global S_mu "$S_mu MU`i'(varlist numeric)"
	}
	if _by() by `_byvars'`_byrc0': Estimate `0'
	else Estimate `0'
end

/*------------------------------------------------ estimation */
program Estimate, eclass byable(recall)
	syntax varlist [if] [in] [fw aw] [,  ///
		ALTernative ALPHAvar(varlist numeric) $S_alpha  ///
		MUvar(varlist numeric) $S_mu PHIvar(varlist numeric) ///
		Baseoutcome(varname) ///
		Robust Cluster(varname) Level(integer $S_level) noLOG * ]

	forvalues i = 1/$S_k {
		local alphalist  "`alpha' `alpha`i''"
		local mulist "`mulist' `mu`i''"
	}
	local alphalist : list retokenize alphalist
	local mulist : list retokenize mulist

	if "`alphavar'`alphalist'" != "" & "`alternative'`muvar'`phivar'`mulist'`baseoutcome'" != "" {
		di as err "must choose one parameterization"
		exit 198 
	}	
	if !`: list baseoutcome in varlist' {
		di as err "varlist must contain baseoutcome"
		exit 198
	}
	
	marksample touse 
	markout `touse' `varlist' `alphavar' `alphalist' `muvar' `mulist' `phivar' `cluster'
	
	foreach var of varlist `varlist' {
		local test "`test' | `var' <= 0 | `var' >= 1"
	}
	tempname tot
	
	qui gen double `tot' = 0 if `touse'
	qui foreach v of local varlist {
		replace `tot' = `tot' + cond(missing(`v'),0,`v') if `touse'
	}
	qui count if (`tot' < .99 | `tot' > 1.01 `test') & `touse'
	if r(N) {
		noi di " "
		noi di as txt ///
		"{p}warning: {res:`varlist'} has `r(N)' values <= 0 or >= 1" 
		noi di as txt ///
		" or rowtotal(`varlist') != 1; not used in calculations{p_end}"
	}
	qui replace `touse' = 0 if `tot' < .99 | `tot' > 1.01 `test' 

	qui count if `touse' 
	if r(N) == 0 error 2000 

	local param = cond("`alternative'`phivar'`muvar'`mulist'`baseoutcome'" != "", "mu, phi", "alpha_k") 
	local title "ML fit of Dirichlet (`param')"
	
	local wtype `weight'
	local wtexp `"`exp'"'
	if "`weight'" != "" local wgt `"[`weight'`exp']"'  
	
	if "`cluster'" != "" { 
		local robust "robust"
		local clopt "cluster(`cluster')" 
	}

	if "`level'" != "" local level "level(`level')"
        local log = cond("`log'" == "", "noisily", "quietly") 
	
	mlopts mlopts, `options'
		
	if "`param'" == "mu, phi" {
		if "baseoutcome" != "" {
			local varlist2 "`baseoutcome'"
			foreach var of local varlist {
				if "`var'" != "`baseoutcome'" local varlist2 = "`varlist2' `var'"
			}
			local varlist "`varlist2'"
		}
		
		local i = 1
		foreach var of varlist `varlist' {
			global S_MLy`i++' "`var'"
		}

		tokenize `varlist'
		global S_ref "`1'"

		forvalues i = 2/$S_k {
			local y "S_MLy`i'"
			local muvar`i' `muvar' `mu`i''
			local mu "`mu' (mu`i': `muvar`i'')"
			local nmu`i' : word count `muvar`i''
		}
		local nphi : word count `phivar'
		`log' ml model lf dirireg_lf `mu' (ln_phi: `phivar')                ///
			`wgt' if `touse' , maximize 				 ///
			collinear title(`title') `robust'       		 ///
			search(on) `clopt' `level' `mlopts' `stdopts' `modopts' ///
			waldtest($S_k)

		eret local cmd "dirifit"
		eret local depvars "`varlist'"

		tempname b bphi
		mat `b' = e(b)
		mat `bphi' = `b'[1,"ln_phi:"]
		eret matrix b_phi = `bphi'
		eret scalar length_b_phi = 1 + `nphi'
		if `nphi' == 0 eret scalar k_aux = 1
		
		forvalues i = 2/$S_k{
			tempname bmu`i'
			mat `bmu`i'' = `b'[1,"mu`i':"]
			eret matrix b_mu`i' = `bmu`i''
			eret scalar length_b_mu`i' = 1 + `nmu`i''
		}
          	Display_reg, `level' `diopts'
	}
	else { 
		local i = 1
		foreach var of varlist `varlist' {
			global S_MLy`i++' "`var'"
		}
		forvalues i = 1/$S_k {
			local alpha`i' "`alphavar' `alpha`i''"
			local nalpha`i' : word count `alpha`i''
			local alpha "`alpha' (ln_alpha`i': `alpha`i'' )"
		}
		`log' ml model lf dirifit_lf `alpha'                             ///
			`wgt' if `touse' , maximize 				 ///
			collinear title(`title') `robust'       		 ///
			search(on) `clopt' `level' `mlopts' `stdopts' `modopts'

		eret local cmd "dirifit"
		eret local depvars "`varlist'"

		tempname b bbeta balpha
		mat `b' = e(b)
		forvalues i = 1/$S_k {
			tempname balpha`i'
			mat `balpha`i'' = `b'[1,"ln_alpha`i':"]
			eret matrix b_alpha`i' = `balpha`i''
			eret scalar length_b_alpha`i' = 1 + `nalpha`i''
		}
		
		Display, `level' `diopts'
        }
		ereturn local predict "dirifit_p"
end

program Display
	syntax [, Level(int $S_level) *]
	local diopts "`options'"
	if `level' < 10 | `level' > 99 local level = 95
	ml display, level(`level') `diopts'
end


program Display_reg
	syntax [, Level(int $S_level) *]
	local diopts "`options'"
	if `level' < 10 | `level' > 99 local level = 95
	if e(length_b_phi) == 1 local plus "plus"
	ml display, level(`level') `diopts' `plus'
	if e(length_b_phi) == 1 {
		_diparm ln_phi, exp label(phi)
		di in text "{hline 13}{c BT}{hline 64}
	}
	local vars = e(depvars)
	tokenize `vars'
	forvalues i = 2/$S_k {
		di in text "mu`i' = ``i''"
	}
	di _newline(1)
	di in text "base outcome = `1'"
end

