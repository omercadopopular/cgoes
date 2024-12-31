*! version 2.2.2  03sep2019
*! Sebastian Kripfganz, www.kripfganz.de

*==================================================*
***** predictions and residuals after xtdpdgmm *****

program define xtdpdgmm_p, sort
	version 13.0
	syntax [anything] [if] [in] [, IV SCores *]

	tempvar smpl
	qui gen byte `smpl' = e(sample)
	sum `smpl', mean
	if r(mean) == 0 {
		error 301
	}
	if "`scores'" != "" {
		loc predict			"scores"
	}
	else if "`iv'" != "" {
		loc predict			"iv"
	}
	else {
		loc predict			"predict"
	}
	if e(k_aux) > 0 & e(k_aux) < . {
		tempname xtdpdgmm_e
		est sto `xtdpdgmm_e'
		xtdpdgmm_p_noaux
		cap noi xtdpdgmm_p_`predict' `0'
		loc error			= _rc
		qui est res `xtdpdgmm_e'
		est drop `xtdpdgmm_e'
		if `error' != 0 {
			exit `error'
		}
	}
	else {
		xtdpdgmm_p_`predict' `0'
	}
end

*==================================================*
**** computation of predictions and residuals ****
program define xtdpdgmm_p_predict
	version 13.0
	syntax [anything] [if] [in] [, XB *]
	loc 0				`"`anything' `if' `in' , `options'"'
	loc options			"UE E U XBU"
	_pred_se "`options'" `0'
	if `s(done)' {
		exit
	}
	loc vtype			"`s(typ)'"
	loc varn			"`s(varn)'"
	loc 0				`"`s(rest)'"'
	syntax [if] [in] [, `options']
	marksample touse

	loc prediction		"`ue'`e'`u'`xbu'"
	if "`prediction'" == "" {						// linear prediction excluding unit-specific error component (default)
		if "`xb'" == "" {
			di as txt "(option xb assumed; fitted values)"
		}
		_predict `vtype' `varn' if `touse', xb
		exit
	}
	if "`prediction'" == "ue" {						// combined residual
		tempvar xb
		qui predict double `xb' if `touse', xb
		gen `vtype' `varn' = `e(depvar)' - `xb' if `touse'
		lab var `varn' "u[`e(ivar)'] + e[`e(ivar)',`e(tvar)']"
		exit
	}
	qui replace `touse' = 0 if !e(sample)
	if "`prediction'" == "e" {						// idiosyncratic error component
		tempvar xb u
		qui predict double `xb' if `touse', xb
		qui predict double `u' if `touse', u
		gen `vtype' `varn' = `e(depvar)' - `xb' - `u' if `touse'
		lab var `varn' "e[`e(ivar)',`e(tvar)']"
		exit
	}
	tempvar smpl
	qui gen byte `smpl' = e(sample)
	if "`prediction'" == "u" | "`prediction'" == "xbu" {
		tempvar xb u y_bar xb_bar
		qui predict double `xb' if `smpl', xb
		qui by `e(ivar)': egen double `y_bar' = mean(`e(depvar)') if `smpl'
		qui by `e(ivar)': egen double `xb_bar' = mean(`xb') if `smpl'
		qui gen double `u' = `y_bar' - `xb_bar' if `smpl'
		if "`prediction'" == "u" {					// unit-specific error component
			gen `vtype' `varn' = `u' if `touse'
			lab var `varn' "u[`e(ivar)']"
		}
		else {										// linear prediction including unit-specific error component
			gen `vtype' `varn' = `xb' + `u' if `touse'
			lab var `varn' "Xb + u[`e(ivar)']"
		}
		exit
	}
	error 198
end


*==================================================*
**** generation of instrumental variables ****
program define xtdpdgmm_p_iv, rclass
	version 13.0
	syntax [anything] [if] [in] , IV [noGENerate]
	marksample touse

	tempname isinit
	mata: st_numscalar("`isinit'", findexternal("`e(mopt)'") != J(1, 1, NULL))
	if !`isinit' {
		error 301
	}
	tempname b
	mat `b'				= e(b)
	loc indepvars		: coln `b'
	loc indepvars		: subinstr loc indepvars "_cons" "", w c(loc constant)
	loc znum			= e(zrank) - `constant'
	if "`generate'" == "" {
		tempvar smpl
		qui gen byte `smpl' = e(sample)
		_stubstar2names `anything', nvars(`znum') noverify
		loc vtyp			"`s(typlist)'"
		loc varn			"`s(varlist)'"
		if `: word count `varn'' != `znum' {
			error 102
		}
		foreach var of loc varn {
			tempvar gen`var'
			qui gen double `gen`var'' = .
			loc ivvars			"`ivvars' `gen`var''"
		}
	}
	loc iveqnames		: cole e(W), q
	loc ivnames			: coln e(W)
	loc j				= 0
	forv k = 1 / `znum' {
		loc iveqname		: word `k' of `iveqnames'
		gettoken ivset iveqname : iveqname
		if `ivset' > `j' {
			if "`ivlabellist'" != "" {
				di as txt " `ivlabel1'"
				loc p				= 1
				loc piece			: piece 1 75 of "`ivlabellist'", nobreak
				while "`piece'" != "" {
					di _col(4) "`piece'"
					loc ++p
					loc piece			: piece `p' 75 of "`ivlabellist'", nobreak
				}
				if "`generate'" == "" {
					mata: xtdpdgmm_iv(`e(mopt)', `j', "`ivsetvars'", "`smpl'")
				}
			}
			loc j				= `ivset'
			loc ivsetvars		""
			loc ivlabellist		""
		}
		loc ivname			: word `k' of `ivnames'
		gettoken ivmodel iveqname : iveqname
		loc ivlabel1		"`ivset', model(`ivmodel'):"
		gettoken ivtime ivlag : iveqname
		if "`ivtime'" != "." {
			loc ivtime			"`ivtime':"
		}
		else {
			loc ivtime			""
		}
		loc ivlag			: list retok ivlag
		if "`ivlag'" == "L0" {
			loc ivlag			""
		}
		else if "`ivlag'" == "L0.D" {
			loc ivlag			"D."
		}
		else if "`ivlag'" == "L0.B" {
			loc ivlag			"B."
		}
		else if "`ivlag'" != "" {
			loc ivlag			"`ivlag'."
		}
		loc ivlabel2		"`ivtime'`ivlag'`ivname'"
		loc ivlabellist		"`ivlabellist' `ivlabel2'"
		if "`generate'" == "" {
			loc ivvar			: word `k' of `ivvars'
			loc ivsetvars		"`ivsetvars' `ivvar'"
			loc ivlabel_`k'		"`ivlabel1' `ivlabel2'"
		}
	}
	di as txt " `ivlabel1'"
	loc p				= 1
	loc piece			: piece 1 75 of "`ivlabellist'", nobreak
	while "`piece'" != "" {
		di _col(4) "`piece'"
		loc ++p
		loc piece			: piece `p' 75 of "`ivlabellist'", nobreak
	}
	if `constant' {
		loc iveqname		: word `= `znum' + 1' of `iveqnames'
		gettoken ivset iveqname : iveqname
		di " `ivset', model(level):"
		di _col(4) "_cons"
	}
	if "`generate'" == "" {
		mata: xtdpdgmm_iv(`e(mopt)', `j', "`ivsetvars'", "`smpl'")
		forv k = 1 / `znum' {
			loc var				: word `k' of `varn'
			qui gen `vtyp' `var' = `gen`var'' if `touse'
			la var `var' "`ivlabel_`k''"
		}

		ret loc iv			"`varn'"
	}
end

*==================================================*
**** computation of parameter-level scores ****
program define xtdpdgmm_p_scores, rclass
	version 13.0
	syntax anything [if] [in] , SCores
	marksample touse

	tempname isinit
	mata: st_numscalar("`isinit'", findexternal("`e(mopt)'") != J(1, 1, NULL))
	if !`isinit' {
		error 301
	}
	tempvar smpl
	qui gen byte `smpl' = e(sample)
	tempname b
	mat `b'				= e(b)
	loc indepvars		: coln `b'
	loc K				: word count `indepvars'
	_stubstar2names `anything', nvars(`K') noverify
	loc vtyp			"`s(typlist)'"
	loc varn			"`s(varlist)'"
	if `: word count `varn'' != `K' {
		error 102
	}
	loc indepvars		: subinstr loc indepvars "_cons" "", w c(loc constant)
	tempvar dsmpl
	qui gen byte `dsmpl' = `smpl'
	fvrevar `indepvars'
	markout `dsmpl' D.`e(depvar)' D.(`r(varlist)')
	mata: xtdpdgmm_init_touse(`e(mopt)', "", "`smpl'")			// marker variable
	mata: xtdpdgmm_init_touse(`e(mopt)', "diff", "`dsmpl'")		// marker variable for first-differenced model
	foreach var of loc varn {
		tempvar gen`var'
		qui gen double `gen`var'' = .
		loc scorevars		"`scorevars' `gen`var''"
	}
	loc wc				= (e(steps) > 1 & "`e(vcetype)'" == "WC-Robust")
	mata: xtdpdgmm_score(`e(mopt)', "`scorevars'", "`smpl'", `wc')
	if e(df_r) < . {
		if e(N_clust) < . {
			loc q				= sqrt(e(N_clust) / (e(N_clust) - 1) * (e(N) - 1) / (e(N) - e(rank)))
		}
		else {
			loc q				= sqrt(e(N) / (e(N) - e(rank)))
		}
	}
	else {
		loc q				= 1
	}
	foreach var of loc varn {
		qui gen `vtyp' `var' = `q' * `gen`var'' if `touse'
		lab var `var' "parameter-level score from `e(cmd)'"
	}

	ret loc scorevars `varn'
end

*==================================================*
**** repost estimates not in auxiliary form ****
program define xtdpdgmm_p_noaux, eclass
	version 13.0

	tempname b
	mat `b'				= e(b)
	loc regnames		: coleq `b'
	mat coleq `b'		= ""
	mat coln `b'		= `regnames'
	eret repost b = `b', rename
	eret sca k_aux		= 0
	cap conf mat e(V_modelbased)
	if _rc == 0 {
		tempname V0
		mat `V0'			= e(V_modelbased)
		mat roweq `V0'		= ""
		mat coleq `V0'		= ""
		mat rown `V0'		= `regnames'
		mat coln `V0'		= `regnames'
		eret mat V_modelbased = `V0'
	}
end
