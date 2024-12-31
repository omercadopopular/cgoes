*! version 2.2.2  03sep2019
*! Sebastian Kripfganz, www.kripfganz.de

*==================================================*
****** GMM linear dynamic panel data estimation ******

*** version history at the end of the file ***

program define xtdpdgmm, eclass prop(xt)
	version 13.0
	if replay() {
		if "`e(cmd)'" != "xtdpdgmm" {
			error 301
		}
		xtdpdgmm_parse_display `0'
		if `"`s(options)'"' != "" {
			di as err `"`s(options)' invalid"'
			exit 198
		}
		xtdpdgmm_display `0'
	}
	else {
		_xt, treq
		syntax varlist(num ts fv) [if] [in] [, *]
		xtdpdgmm_parse_display , `options'
		loc diopts			"`s(diopts)'"
		xtdpdgmm_init , `s(options)'
		loc mopt			"`s(mopt)'"
		xtdpdgmm_gmm `varlist' `if' `in', mopt(`mopt') `s(options)'

		eret loc predict	"xtdpdgmm_p"
		eret loc estat_cmd	"xtdpdgmm_estat"
		eret loc tvar		"`_dta[_TStvar]'"
		eret loc ivar		"`_dta[_TSpanel]'"
		eret loc cmdline 	`"xtdpdgmm `0'"'
		eret loc cmd		"xtdpdgmm"
		eret hidden loc mopt	"`mopt'"			// undocumented
		xtdpdgmm_display , `diopts'
	}
end

program define xtdpdgmm_gmm, eclass
	version 13.0
	syntax varlist(num ts fv) [if] [in] , MOPT(name) [	noCONStant			///
														TEffects			///
														NL(str)				///
														Collapse			///
														noREScale			///
														Model(string)		///
														ONEstep				///
														TWOstep				///
														IGMM				///
														Wmatrix(str)		///
														OVERid				///
														FROM(passthru)		///
														VCE(passthru)		///
														SMall				///
														AUXiliary			///
														noSERial			/// historical since version 2.0.0
														IID					/// historical since version 2.0.0
														*]					// GMMIV() IV() parsed separately
	loc fv				= ("`s(fvops)'" == "true")
	if `fv' {
		fvexpand `varlist'
		loc varlist			"`r(varlist)'"
	}
	marksample touse
	gettoken depvar indepvars : varlist
	if "`indepvars'" == "" & "`constant'" != "" {
		error 102
	}
	sum `touse', mean
	if r(sum) == 0 {
		error 2000
	}
	if `fv' {
		_fv_check_depvar `depvar'
		fvrevar `indepvars'
		loc dindepvars		"D.(`r(varlist)')"
	}
	else {
		loc dindepvars		"D.(`indepvars')"
	}
	tempvar dtouse
	qui gen byte `dtouse' = `touse'
	markout `dtouse' D.`depvar' `dindepvars'
	qui replace `dtouse' = 0 if !(L.`touse')
	mata: xtdpdgmm_init_touse(`mopt', "", "`touse'")			// marker variable
	mata: xtdpdgmm_init_touse(`mopt', "diff", "`dtouse'")		// marker variable for first-differenced model
	mata: xtdpdgmm_init_by(`mopt', "`_dta[_TSpanel]'")			// panel identifier
	mata: xtdpdgmm_init_time(`mopt', "`_dta[_TStvar]'")			// time identifier
	tsrevar `depvar'
	mata: xtdpdgmm_init_depvar(`mopt', "`r(varlist)'")			// dependent variable
	if "`constant'" != "" {
		mata: xtdpdgmm_init_cons(`mopt', "off")			// constant term
	}

	*--------------------------------------------------*
	*** time effects ***
	loc tdelta			= `_dta[_TSdelta]'
	sum `_dta[_TStvar]' if `touse', mean
	loc tmin			= r(min)
	loc tmax			= r(max)
	if "`teffects'" != "" {
		cap _rmcoll i(`= `tmin'+`tdelta'*("`constant'" == "")'(`tdelta')`= `tmax'')bn.`_dta[_TStvar]' if `touse', exp `constant'
		if _rc != 0 {
			error 451
		}
		loc teffects		"`r(varlist)'"
		loc indepvars		"`indepvars' `teffects'"
	}
	mata: xtdpdgmm_init_indepvars(`mopt', "`indepvars'")		// independent variables

	*--------------------------------------------------*
	*** type of weighting matrix ***
	xtdpdgmm_parse_wmatrix `wmatrix'
	loc wmatrix			"`s(wmatrix)'"
	loc ratio			= `s(ratio)'
	if "`wmatrix'" == "unadjusted" {
		mata: xtdpdgmm_init_wmatrix(`mopt', "", `ratio')
	}
	else {
		mata: xtdpdgmm_init_wmatrix(`mopt', "independent", `ratio')
	}

	*--------------------------------------------------*
	*** syntax parsing of options for instruments ***
	if "`overid'" != "" {
		mata: xtdpdgmm_init_overid(`mopt', "on")
	}
	if "`serial'" != "" & "`iid'" != "" {
		di as err "options noserial and iid may not be combined"
		exit 184
	}
	if "`serial'`iid'" != "" {
		if "`nl'" != "" {
			di as err "options `serial'`iid' and nl() may not be combined"
			exit 184
		}
		loc nl				"`serial'`iid', norescale"
	}
	if "`nl'" != "" {
		loc nlsyntax		= cond("`collapse'" == "", "Collapse", "noCollapse")
		loc nlsyntax		= cond("`rescale'" == "", "`nlsyntax' noREScale", "`nlsyntax' REScale")
		xtdpdgmm_parse_nl `nlsyntax' `nl'
		loc nl				"`s(nl)'"
		if "`nl'" == "iid" {
			loc options			`"gmmiv(L.`depvar', iid `s(collapse)') `options'"'
		}
		mata: xtdpdgmm_init_nl(`mopt', "`nl'")
		if "`s(collapse)'" != "" {
			mata: xtdpdgmm_init_nl_collapse(`mopt', "yes")
		}
		if "`s(rescale)'" == "" {
			mata: xtdpdgmm_init_nl_rescale(`mopt', "no")
		}
		mata: xtdpdgmm_init_nl_weight(`mopt', `s(weight)')
	}
	tempvar obs
	qui by `_dta[_TSpanel]': gen `obs' = _n
	sum `obs', mean
	loc maxlag			= r(max) - r(min)
	drop `obs'
	loc ivnum			= 0
	if "`model'" == "" {
		loc model			"level"
	}
	else {
		xtdpdgmm_parse_model level , todo(2) `model'
		loc model			"`s(model)'"
	}
	while `"`options'"' != "" {
		xtdpdgmm_parse_options , maxlag(`maxlag') `options' `collapse' `rescale' model(`model')
		loc options			`"`s(options)'"'
		loc ivnames			"`s(varlist)'"
		loc transform		"`s(transform)'"
		if "`s(fvops)'" == "true" & "`s(transform)'" != "" {
			fvrevar `s(varlist)'
			xtdpdgmm_parse_options , maxlag(`maxlag') `s(ivtype)'iv(`r(varlist)', l(`s(lag1)' `s(lag2)') `s(transform)' m(`s(model)') `s(rescale)') `collapse' `rescale' model(`model')
		}
		if "`s(model)'" == "iid" {
			if "`s(ivtype)'" == "gmm" {
				loc ecgmmivvars		"`ecgmmivvars' `s(ivlist)'"
			}
			else {
				loc ecivvars		"`ecivvars' `s(ivlist)'"
			}
		}
		else if "`s(model)'" == "diff" {
			if "`s(ivtype)'" == "gmm" {
				loc dgmmivvars		"`dgmmivvars' `s(ivlist)'"
			}
			else {
				loc divvars			"`divvars' `s(ivlist)'"
			}
		}
		else if "`s(model)'" == "mdev" {
			if "`s(ivtype)'" == "gmm" {
				loc mdgmmivvars		"`mdgmmivvars' `s(ivlist)'"
			}
			else {
				loc mdivvars		"`mdivvars' `s(ivlist)'"
			}
		}
		else if "`s(model)'" == "fodev" {
			if "`s(transform)'" == "bodev" {
				loc bodvarlist0		""
				loc bodvarlist1		""
				forv v = 1 / `: word count `s(varnames)'' {
					loc bodvarname		: word `v' of `s(varnames)'
					loc bodvarlist0		"`bodvarlist0' B.`bodvarname'"
					tempvar bodvar
					tsrevar `: word `v' of `s(varnames)'', l
					qui gen `: type `r(varlist)'' `bodvar' = `bodvarname' if `touse'
					loc bodvarlist1		"`bodvarlist1' `bodvar'"
				}
				mata: xtdpdgmm_bodev("`bodvarlist1'", "`_dta[_TSpanel]'", "`touse'", ("`s(rescale)'" != ""))
				if "`s(ivtype)'" == "gmm" | "`s(collapse)'" != "" {
					xtdpdgmm_parse_options , maxlag(`maxlag') gmmiv(`bodvarlist1', lagrange(`s(lag1)' `s(lag2)') `s(collapse)' `s(rescale)' model(fodev)) model(`model')
				}
				else {
					xtdpdgmm_parse_options , maxlag(`maxlag') iv(`bodvarlist1', lagrange(`s(lag1)' `s(lag2)') `s(rescale)' model(fodev)) model(`model')
				}
				if "`s(ivtype)'" == "gmm" {
					loc bodgmmivvars	"`bodgmmivvars' `bodvarlist1'"
					forv v = 1 / `: word count `bodvarlist0'' {
						loc bodvarname		: word `v' of `bodvarlist0'
						loc fodgmmivnames	"`fodgmmivnames' `s(lagrange)'`bodvarname'"
					}
					loc fodgmmivvars	"`fodgmmivvars' `s(ivlist)'"
				}
				else {
					loc bodivvars		"`bodivvars' `bodvarlist1'"
					forv v = 1 / `: word count `bodvarlist0'' {
						loc bodvarname		: word `v' of `bodvarlist0'
						loc fodivnames	"`fodivnames' `s(lagrange)'`bodvarname'"
					}
					loc fodivvars		"`fodivvars' `s(ivlist)'"
				}
			}
			else if "`s(ivtype)'" == "gmm" {
				loc fodgmmivnames	"`fodgmmivnames' `s(ivlist)'"
				loc fodgmmivvars	"`fodgmmivvars' `s(ivlist)'"
			}
			else {
				loc fodivnames		"`fodivnames' `s(ivlist)'"
				loc fodivvars		"`fodivvars' `s(ivlist)'"
			}
		}
		else if "`s(ivtype)'" == "gmm" {
			loc gmmivvars		"`gmmivvars' `s(ivlist)'"
		}
		else {
			loc ivvars			"`ivvars' `s(ivlist)'"
		}
		loc ++ivnum
		loc ivnames_`ivnum'	"`ivnames'"
		loc ivmodel_`ivnum'	"`s(model)'"
		loc ivtransform_`ivnum'	"`transform'"
		loc ivtype_`ivnum'	"`s(ivtype)'"
		loc ivlag1_`ivnum'	"`s(lag1)'"
		loc ivlag2_`ivnum'	"`s(lag2)'"
		mata: xtdpdgmm_init_ivvars(`mopt', `ivnum', "`s(ivlist)'")
		mata: xtdpdgmm_init_ivvars_model(`mopt', `ivnum', "`ivmodel_`ivnum''")
		if "`s(rescale)'" == "" {
			mata: xtdpdgmm_init_ivvars_rescale(`mopt', `ivnum', "no")
		}
		if "`wmatrix'" == "separate" {
			mata: xtdpdgmm_init_ivvars_separate(`mopt', `ivnum', "yes")
		}
		mata: xtdpdgmm_init_ivvars_type(`mopt', `ivnum', "`s(ivtype)'")
	}
	if "`teffects'" != "" {
		loc ivvars "`ivvars' `teffects'"
		loc ++ivnum
		loc ivnames_`ivnum'	"`teffects'"
		loc ivmodel_`ivnum'	"level"
		loc ivlag1_`ivnum'	= 0
		loc ivlag2_`ivnum'	= 0
		mata: xtdpdgmm_init_ivvars(`mopt', `ivnum', "`teffects'")
	}
	loc gmmivvars		: list retok gmmivvars
	loc ivvars			: list retok ivvars
	foreach m in d ec md fod {
		loc `m'gmmivvars	: list retok `m'gmmivvars
		loc `m'ivvars		: list retok `m'ivvars
	}

	*--------------------------------------------------*
	*** type of variance-covariance matrices ***
	if `"`vce'"' != "" {
		xtdpdgmm_parse_vce , `vce' `twostep'`igmm' model(`model')
		loc vce				"`s(vce)'"
		loc vcem			"`s(model)'"
		loc clustvar		"`s(clustvar)'"
		if "`vce'" == "robust" {
			mata: xtdpdgmm_init_vcetype(`mopt', "robust")
		}
		if "`clustvar'" != "" {
			mata: xtdpdgmm_init_cluster(`mopt', "`clustvar'")
		}
	}
	else {
		loc vce				"conventional"
	}
	if "`vcem'" == "" {
		loc vcem			"`model'"
	}
	mata: xtdpdgmm_init_vce_model(`mopt', "`vcem'")
	if "`vce'" == "conventional" {
		if ("`twostep'`igmm'" != "" | "`nl'" != "") {
			di as txt "note: standard errors can be severely biased in finite samples"
		}
		else {
			di as txt "note: standard errors may not be valid"
		}
	}

	*--------------------------------------------------*
	*** initial estimates ***
	if "`constant'" == "" {
		loc regnames		"`indepvars' _cons"
	}
	else {
		loc regnames		"`indepvars'"
	}
	if `"`from'"' != "" {
		tempname b0
		_mkvec `b0', `from' col(`regnames') first err("from()")
		mata: xtdpdgmm_init_coefs(`mopt', st_matrix("`b0'"))
	}

	*--------------------------------------------------*
	*** estimation ***
	di _n as txt "Generalized method of moments estimation"
	mata: xtdpdgmm(`mopt')

	mata: st_numscalar("r(N)", xtdpdgmm_result_N(`mopt'))
	mata: st_numscalar("r(rank)", xtdpdgmm_result_rank(`mopt'))
	mata: st_numscalar("r(zrank_nl)", xtdpdgmm_result_zrank(`mopt', "nonlinear"))
	mata: st_matrix("r(b)", xtdpdgmm_result_coefs(`mopt'))
	mata: st_matrix("r(V)", xtdpdgmm_result_V(`mopt'))
	mata: st_matrix("r(V_modelbased)", xtdpdgmm_result_V_oim(`mopt'))
	mata: st_matrix("r(W)", xtdpdgmm_result_wmatrix(`mopt'))
	loc N				= r(N)
	loc rank			= r(rank)
	loc zrank_nl		= r(zrank_nl)
	tempname b V W
	mat `b'				= r(b)
	mat `V'				= r(V)
	mat `W'				= r(W)
	if !("`vce'" != "robust" & "`twostep'`igmm'" != "") {
		tempname V0
		mat `V0'			= r(V_modelbased)
	}
	if "`twostep'`igmm'" != "" & "`vce'" == "robust" {
		mata: st_matrix("r(b)", xtdpdgmm_result_coefs(`mopt', 1))
		mata: st_matrix("r(V_modelbased)", xtdpdgmm_result_V_oim(`mopt', 1))
		mata: st_matrix("r(W)", xtdpdgmm_result_wmatrix(`mopt', 1))
		tempname b1 W1 V01
		mat `b1'			= r(b)
		mat `V01'			= r(V_modelbased)
		mat `W1'			= r(W)
	}
	if "`vce'" == "robust" {
		mata: st_numscalar("r(N_clust)", xtdpdgmm_result_Nclust(`mopt'))
		loc N_clust			= r(N_clust)
		if "`small'" != "" {
			mat `V'				= `N_clust' / (`N_clust' - 1) * (`N' - 1) / (`N' - `rank') * `V'
			loc df				= `N_clust' - 1
		}
	}
	else if "`small'" != "" {
		mat `V'				= `N' / (`N' - `rank') * `V'
		loc df				= `N' - `rank'
	}
	if "`auxiliary'" != "" {
		loc k_aux			: word count `regnames'
		mat coleq `b'		= `regnames'
		mat roweq `V'		= `regnames'
		mat coleq `V'		= `regnames'
		if !("`vce'" != "robust" & "`twostep'`igmm'" != "") {
			mat roweq `V0'		= `regnames'
			mat coleq `V0'		= `regnames'
		}
		if "`twostep'`igmm'" != "" & "`vce'" == "robust" {
			mat coleq `b1'		= `regnames'
			mat roweq `V01'		= `regnames'
			mat coleq `V01'		= `regnames'
		}
		loc regnames		""
		forv e = 1/`k_aux' {
			loc regnames		"`regnames' _cons"
		}
	}
	mat coln `b'		= `regnames'
	mat rown `V'		= `regnames'
	mat coln `V'		= `regnames'
	if !("`vce'" != "robust" & "`twostep'`igmm'" != "") {
		mat rown `V0'		= `regnames'
		mat coln `V0'		= `regnames'
	}
	if "`twostep'`igmm'" != "" & "`vce'" == "robust" {
		mat coln `b1'		= `regnames'
		mat rown `V01'		= `regnames'
		mat coln `V01'		= `regnames'
	}
	if "`constant'" == "" {
		loc ivvars			"`ivvars' _cons"
		loc ivvars			: list retok ivvars
	}
	if "`bodgmmivvars'" != "" {
		loc fodgmmivvars	: list retok fodgmmivnames
	}
	if "`bodivvars'" != "" {
		loc fodivvars		: list retok fodivnames
	}
	loc ivnames			""
	forv j = 1 / `ivnum' {
		tempname nocol
		mata: st_matrix("`nocol'", xtdpdgmm_result_ivvars_nocol(`mopt', `j'))
		loc k				= 1
		loc l				= `ivlag1_`j''
		loc lags			= `ivlag2_`j'' - `ivlag1_`j'' + 1
		forv i = 1 / `= colsof(`nocol')' {
			loc n				= el(`nocol', 1, `i')
			if "`ivtype_`j''" == "gmm" {
				loc t				= `tmin' + `tdelta' * (cond(mod(`n', `maxlag'), mod(`n', `maxlag'), `maxlag') - 1)
				while `n' > ((`k' - 1) * `lags' + `l' - `ivlag1_`j'' + 1) * `maxlag' {
					if `l' < `ivlag2_`j'' {
						loc ++l
					}
					else {
						loc l				= `ivlag1_`j''
						loc ++k
					}
				}
				loc lag				= cond(`l' < 0, "F`= abs(`l')'", "L`l'")
				loc ivname			: word `k' of `ivnames_`j''
				if "`ivtransform_`j''" == "difference" {
					loc iveqnames		`"`iveqnames' "`j' `ivmodel_`j'' `t' `lag'.D""'
				}
				else if "`ivtransform_`j''" == "bodev" {
					loc iveqnames		`"`iveqnames' "`j' `ivmodel_`j'' `t' `lag'.B""'
				}
				else {
					loc iveqnames		`"`iveqnames' "`j' `ivmodel_`j'' `t' `lag'""'
				}
			}
			else {
				while `n' > (`k' - 1) * `lags' + `l' - `ivlag1_`j'' + 1 {
					if `l' < `ivlag2_`j'' {
						loc ++l
					}
					else {
						loc l				= `ivlag1_`j''
						loc ++k
					}
				}
				loc lag				= cond(`l' < 0, "F`= abs(`l')'", "L`l'")
				loc ivname			: word `k' of `ivnames_`j''
				if "`ivtransform_`j''" == "difference" {
					loc iveqnames		`"`iveqnames' "`j' `ivmodel_`j'' . `lag'.D""'
				}
				else if "`ivtransform_`j''" == "bodev" {
					loc iveqnames		`"`iveqnames' "`j' `ivmodel_`j'' . `lag'.B""'
				}
				else {
					loc iveqnames		`"`iveqnames' "`j' `ivmodel_`j'' . `lag'""'
				}
			}
			loc ivnames			"`ivnames' `ivname'"
		}
	}
	if "`constant'" == "" {
		loc iveqnames		`"`iveqnames' "`=`ivnum'+1' level . L0""'
		loc ivnames			"`ivnames' _cons"
	}
	if `zrank_nl' == 1 {
		loc iveqnames		`"`iveqnames' "nl `nl' . L0""'
		loc ivnames			"`ivnames' _cons"
	}
	else if `zrank_nl' > 1 {
		forv i = 1 / `zrank_nl' {
			loc t				= `tmin' + `tdelta' * `i'
			loc iveqnames		`"`iveqnames' "nl `nl' `t' L0""'
			loc ivnames			"`ivnames' _cons"
		}
	}
	mat rown `W'		= `ivnames'
	mat coln `W'		= `ivnames'
	mat rowe `W'		= `iveqnames'
	mat cole `W'		= `iveqnames'

	*--------------------------------------------------*
	*** current estimation results ***
	if "`small'" != "" {
		loc small			"dof(`df')"
	}
	if `fv' {
		loc fvopt			"buildfv "
	}
	eret post `b' `V', dep(`depvar') o(`N') `small' e(`touse') `fvopt' findomitted
	mata: st_numscalar("e(N_g)", xtdpdgmm_result_Ng(`mopt'))
	if "`vce'" == "robust" {
		eret sca N_clust	= `N_clust'
	}
	mata: st_numscalar("e(g_min)", xtdpdgmm_result_Tmin(`mopt'))
	eret sca g_avg		= e(N) / e(N_g)
	mata: st_numscalar("e(g_max)", xtdpdgmm_result_Tmax(`mopt'))
	mata: st_numscalar("e(f)", xtdpdgmm_result_value(`mopt'))
	mata: st_numscalar("e(chi2_J)", xtdpdgmm_result_overid(`mopt', 1))
	mata: st_numscalar("e(chi2_J_u)", xtdpdgmm_result_overid(`mopt', 2))
	eret sca rank		= `rank'
	mata: st_numscalar("e(zrank)", xtdpdgmm_result_zrank(`mopt', "linear"))
	eret sca zrank_nl	= `zrank_nl'
	if "`vce'" == "conventional" & "`twostep'`igmm'" == "" & "`nl'" == "" {
		mata: st_numscalar("e(sigma2e)", xtdpdgmm_result_sigma2(`mopt'))
	}
	mata: st_numscalar("e(steps)", xtdpdgmm_result_steps(`mopt'))
	mata: st_numscalar("e(ic)", xtdpdgmm_result_iterations(`mopt'))
	mata: st_numscalar("e(converged)", xtdpdgmm_result_converged(`mopt'))
	if "`auxiliary'" == "" {
		if "`vce'" == "robust" {
			if "`twostep'`igmm'" != "" | "`nl'" != "" {
				eret loc vcetype	"WC-Robust"
			}
			else {
				eret loc vcetype	"Robust"
			}
		}
		else if "`twostep'`igmm'" == "" & "`nl'" != "" {
			eret loc vcetype	"Robust"
		}
		if "`clustvar'" == "" {
			eret loc vce		"`vce'"
		}
		else {
			eret loc vce		"cluster"
			eret loc clustvar	"`clustvar'"
		}
	}
	eret loc estimator	"`onestep'`twostep'`igmm'"
	eret loc wmatrix	"`wmatrix', ratio(`ratio')"
	eret loc teffects	"`teffects'"
	mata: st_matrix("e(ilog)", xtdpdgmm_result_iterationlog(`mopt'))
	eret mat W			= `W'
	if !("`vce'" != "robust" & "`twostep'`igmm'" != "") {
		eret mat V_modelbased	= `V0'
	}

	*--------------------------------------------------*
	*** hidden estimation results ***					// undocumented
	if "`auxiliary'" != "" {
		eret hidden sca k_aux	= `k_aux'
	}
	if "`overid'" != "" {
		tempname J
		mata: st_matrix("`J'", xtdpdgmm_result_overid(`mopt', 0))
		eret hidden mat J	= `J'
	}

	*--------------------------------------------------*
	*** historical estimation results ***				// undocumented since version 2.0.0
	eret historical sca twostep		= (e(steps) == 2)
	eret historical loc nonlinear	"`nl'"
	foreach m in fod md ec d {
		eret historical loc `m'gmmivvars	"``m'gmmivvars'"
		eret historical loc `m'ivvars		"``m'ivvars'"
	}
	eret historical loc gmmivvars	"`gmmivvars'"
	eret historical loc ivvars		"`ivvars'"
	if "`twostep'" != "" & "`vce'" == "robust" {
		eret historical mat W_onestep	= `W1'
		eret historical mat V_onestep	= `V01'
		eret historical mat b_onestep	= `b1'
	}
end

*==================================================*
**** display of estimation results ****
program define xtdpdgmm_display
	version 13.0
	syntax [, noOMITted noHEader noTABle noFOOTnote *]

	if "`header'" == "" {
		di _n as txt "Group variable: " as res abbrev("`e(ivar)'", 12) _col(46) as txt "Number of obs" _col(68) "=" _col(70) as res %9.0f e(N)
		di as txt "Time variable: " as res abbrev("`e(tvar)'", 12) _col(46) as txt "Number of groups" _col(68) "=" _col(70) as res %9.0f e(N_g)
		di _n as txt "Moment conditions:" _col(24) "linear =" _col(33) as res %7.0f e(zrank) _col(46) as txt "Obs per group:" _col(64) "min =" _col(70) as res %9.0g e(g_min)
		di _col(21) as txt "nonlinear =" _col(33) as res %7.0f e(zrank_nl) _col(64) as txt "avg =" _col(70) as res %9.0g e(g_avg)
		di _col(25) as txt "total =" _col(33) as res %7.0f e(zrank) + e(zrank_nl) _col(64) as txt "max =" _col(70) as res %9.0g e(g_max)
	}
	if "`table'" == "" {
		di ""
		_coef_table, `options'
	}
	if "`footnote'" == "" {
		di as txt "Instruments corresponding to the linear moment conditions:"
		predict , iv nogenerate
	}
end

*==================================================*
**** syntax parsing of additional display options ****
program define xtdpdgmm_parse_display, sclass
	version 13.0
	sret clear
	syntax , [noHEader noTABle noFOOTnote PLus *]
	_get_diopts diopts options, `options'

	sret loc diopts		`"`header' `table' `footnote' `plus' `diopts'"'
	sret loc options	`"`options'"'
end

*==================================================*
**** syntax parsing of the optimization options ****
program define xtdpdgmm_init, sclass
	version 13.0
	sret clear
	loc maxiter			= c(maxiter)
	syntax [,	NL(passthru)						///
				ONEstep								///
				TWOstep								///
				IGMM								///
				noANalytic							///
				METHOD(string)						///
				ITERate(integer `maxiter')			///
				noLOg								///
				NODOTs								///
				DOTs								///
				SHOWSTEP							///
				SHOWTOLerance						///
				TOLerance(real 1e-6)				///
				LTOLerance(real 1e-7)				///
				NRTOLerance(real 1e-5)				///
				NONRTOLerance						///
				IGMMITerate(integer `maxiter')		///
				IGMMEPS(real 1e-6)					///
				IGMMWEPS(real 1e-6)					///
				*]

	tempname isinit
	sca `isinit'		= 1
	loc j				= 1
	while `isinit' {
		mata: st_numscalar("`isinit'", findexternal("xtdpdgmm_opt_`j'") != J(1, 1, NULL))
		if `isinit' {
			loc ++j
		}
		else {
			loc mopt			"xtdpdgmm_opt_`j'"
			mata: `mopt' = xtdpdgmm_init()
		}
	}
	if `"`method'"' == "" {
		loc method			"q1"
	}
	else {
		loc method			: subinstr loc method "quadratic" "q", all
		loc methods			"q0 q1 q1debug"
		if `: word count `method'' > 1 | !`: list method in methods' {
			di as err "option method() incorrectly specified -- invalid evaluator type"
			exit 198
		}
	}
	if "`onestep'" != "" & "`twostep'" != "" {
		di as err "options onestep and twostep may not be combined"
		exit 184
	}
	if "`onestep'`twostep'" != "" & "`igmm'" != "" {
		di as err "options `onestep'`twostep' and igmm may not be combined"
		exit 184
	}
	if "`onestep'`twostep'`igmm'" == "" {
		if "`nl'" == "" {
			loc onestep			"onestep"
		}
		else {
			loc twostep			"twostep"
		}
	}
	if "`dots'" != "" & "`nodots'" != "" {
		di as err "options dots and nodots may not be combined"
		exit 184
	}
	if "`igmm'" == "" {
		mata: xtdpdgmm_init_steps(`mopt', 1 + ("`twostep'" != ""))
	}
	else {
		if "`nodots'" == "" {
			loc dots			"dots"
		}
		mata: xtdpdgmm_init_steps(`mopt', `igmmiterate')
		mata: xtdpdgmm_init_igmm_eps(`mopt', `igmmeps')
		mata: xtdpdgmm_init_igmm_weps(`mopt', `igmmweps')
	}
	mata: xtdpdgmm_init_evaluatortype(`mopt', "`method'")
	if "`analytic'" == "" & "`nl'" == "" {
		mata: xtdpdgmm_init_technique(`mopt', "")
	}
	mata: xtdpdgmm_init_conv_maxiter(`mopt', `iterate')
	mata: xtdpdgmm_init_conv_ptol(`mopt', `tolerance')
	mata: xtdpdgmm_init_conv_vtol(`mopt', `ltolerance')
	if "`nonrtolerance'" == "" {
		mata: xtdpdgmm_init_conv_nrtol(`mopt', `nrtolerance')
	}
	else {
		mata: xtdpdgmm_init_conv_ignorenrtol(`mopt', "on")
	}
	if "`log'" != "" {
		mata: xtdpdgmm_init_tracelevel(`mopt', "none")
	}
	if "`dots'" != "" {
		mata: xtdpdgmm_init_igmm_dots(`mopt', "on")
	}
	if "`showstep'" != "" {
		mata: xtdpdgmm_init_trace_step(`mopt', "on")
	}
	if "`showtolerance'" != "" {
		mata: xtdpdgmm_init_trace_tol(`mopt', "on")
	}

	sret loc mopt		"`mopt'"
	sret loc method		`"`method'"'
	sret loc options	`"`nl' `onestep'`twostep'`igmm' `options'"'
end

*==================================================*
**** syntax parsing for nonlinear moment conditions ****
program define xtdpdgmm_parse_nl, sclass
	version 13.0
	gettoken csyntax 0 : 0
	gettoken rsyntax 0 : 0
	syntax anything [, `csyntax' `rsyntax' Weight(real 1)]

	loc collapse		= cond(("`csyntax'" == "noCollapse" & "`collapse'" == "") | ("`csyntax'" == "Collapse" & "`collapse'" != ""), "collapse", "")
	loc rescale			= cond(("`rsyntax'" == "noREScale" & "`rescale'" == "") | ("`rsyntax'" == "REScale" & "`rescale'" != ""), "rescale", "")
	loc length			: length loc anything
	if `"`anything'"' == substr("noserial", 1, max(5, `length')) {
		loc anything		"noserial"
	}
	else if `"`anything'"' != "iid" {
		di as err "option nl() incorrectly specified"
		exit 198
	}
	if `weight' < 0 {
		di as err "weight() invalid -- outside of allowed range"
		exit 198
	}

	sret loc weight		= `weight'
	sret loc rescale	"`rescale'"
	sret loc collapse	"`collapse'"
	sret loc nl			"`anything'"
end

*==================================================*
**** syntax parsing of options for instruments ****
program define xtdpdgmm_parse_options, sclass
	version 13.0
	sret clear
	syntax , MAXLAG(integer) [GMMiv(string) IV(string) Collapse noREScale Model(string) *]

	*--------------------------------------------------*
	*** GMM instruments ***
	loc collapse		= cond("`collapse'" == "", "Collapse", "noCollapse")
	loc rescale			= cond("`rescale'" == "", "noREScale", "REScale")
	if `"`gmmiv'"' != "" {
		gettoken gmmivvars gmmiv : gmmiv, p(",")
		if "`gmmiv'" == "" {
			loc gmmiv			","
		}
		xtdpdgmm_parse_gmmiv `collapse' `rescale' `model' `gmmivvars' `gmmiv' maxlag(`maxlag')
	}

	*--------------------------------------------------*
	*** standard instruments ***
	if "`gmmivvars'" == "" {
		if `"`iv'"' != "" {
			gettoken ivvars iv : iv, p(",")
			if "`iv'" == "" {
				loc iv				","
			}
			xtdpdgmm_parse_iv `rescale' `model' `ivvars' `iv' maxlag(`maxlag')
		}
		else if `"`options'"' == "" {
			error 198
		}
		else {
			di as err `"`options' invalid"'
			exit 198
		}
	}
	else if `"`iv'"' != "" {
		loc options			`"iv(`iv') `options'"'
	}

	sret loc options		`"`options'"'
end

*==================================================*
**** syntax parsing for GMM instruments ****
program define xtdpdgmm_parse_gmmiv, sclass
	version 13.0
	gettoken csyntax 0 : 0
	gettoken rsyntax 0 : 0
	gettoken mdefault 0 : 0
	syntax varlist(num ts fv), MAXLag(integer) [Lagrange(numlist max=2 int miss) Difference BODev `csyntax' `rsyntax' IID Model(string)		///
												EC]																							// historical since version 2.0.0

	if "`s(fvops)'" == "true" {
		fvexpand `varlist'
		loc varlist			"`r(varlist)'"
	}
	loc collapse		= cond(("`csyntax'" == "noCollapse" & "`collapse'" == "") | ("`csyntax'" == "Collapse" & "`collapse'" != ""), "collapse", "")
	loc rescale			= cond(("`rsyntax'" == "noREScale" & "`rescale'" == "") | ("`rsyntax'" == "REScale" & "`rescale'" != ""), "rescale", "")
	xtdpdgmm_parse_model `mdefault' , todo(`= ("`bodev'" != "")') `model' `iid' `ec'
	loc model			"`s(model)'"
	if "`bodev'" != "" & "`difference'" != "" {
		di as err "options difference and bodev may not be combined"
		exit 184
	}
	if "`iid'`ec'" == "" {
		if "`lagrange'" == "" {
			loc lagrange		= ("`model'" == substr("difference", 1, max(1, `: length loc model')))
		}
		xtdpdgmm_parse_lagrange , maxlag(`maxlag') lagrange(`lagrange') `difference' `bodev' model(`model') gmmiv
		foreach var of loc varlist {
			if "`difference'" == "" {
				loc gmmivvars		"`gmmivvars' `s(lagrange)'`var'"
				loc varnames		"`varnames' `var'"
			}
			else {
				loc gmmivvars		"`gmmivvars' `s(lagrange)'D.`var'"
				loc varnames		"`varnames' D.`var'"
			}
		}
	}
	else if "`lagrange'" != "" {
			di as err "options `iid'`ec' and lagrange() may not be combined"
			exit 184
	}
	else {
		if "`difference'" == "" {
			loc gmmivvars		"`varlist'"
		}
		else {
			foreach var of loc varlist {
				loc gmmivvars		"`gmmivvars' D.`var'"
			}
		}
		sret loc lag1		= 0
		sret loc lag2		= 0
		loc varnames		"`varlist'"
	}

	sret loc transform	"`difference'`bodev'"
	sret loc ivlist		"`gmmivvars'"
	sret loc rescale	"`rescale'"
	sret loc collapse	"`collapse'"
	if "`collapse'" == "" {
		sret loc ivtype		"gmm"
	}
	sret loc varnames	"`varnames'"
	sret loc varlist	"`varlist'"
end

*==================================================*
**** syntax parsing for standard instruments ****
program define xtdpdgmm_parse_iv, sclass
	version 13.0
	gettoken rsyntax 0 : 0
	gettoken mdefault 0 : 0
	syntax varlist(num ts fv), MAXLag(integer) [Lagrange(numlist max=2 int) Difference BODev `rsyntax' Model(string)]

	if "`s(fvops)'" == "true" {
		fvexpand `varlist'
		loc varlist			"`r(varlist)'"
	}
	loc rescale			= cond(("`rsyntax'" == "noREScale" & "`rescale'" == "") | ("`rsyntax'" == "REScale" & "`rescale'" != ""), "rescale", "")
	xtdpdgmm_parse_model `mdefault' , todo(`= ("`bodev'" != "")') `model'
	loc model			"`s(model)'"
	if "`bodev'" != "" & "`difference'" != "" {
		di as err "options difference and bodev may not be combined"
		exit 184
	}
	if "`lagrange'" == "" {
		loc lagrange		= 0
	}
	xtdpdgmm_parse_lagrange , maxlag(`maxlag') lagrange(`lagrange') `difference' `bodev' model(`model')
	foreach var of loc varlist {
		if "`difference'" == "" {
			loc ivvars			"`ivvars' `s(lagrange)'`var'"
			loc varnames		"`varnames' `var'"
		}
		else {
			loc ivvars			"`ivvars' `s(lagrange)'D.`var'"
			loc varnames		"`varnames' D.`var'"
		}
	}
	
	sret loc transform	"`difference'`bodev'"
	sret loc ivlist		"`ivvars'"
	sret loc rescale	"`rescale'"
	sret loc varnames	"`varnames'"
	sret loc varlist	"`varlist'"
end

*==================================================*
**** syntax parsing for the model equations ****
program define xtdpdgmm_parse_model, sclass
	version 13.0
	syntax anything , TODO(integer) [	Level Difference MDev FODev IID		///
										EC]									// historical since version 2.0.0

	if `: word count `level' `difference' `mdev' `fodev'' > 1 | (`todo' == 2 & "`iid'`ec'" != "") {
		di as err "option model() incorrectly specified"
		exit 198
	}
	if "`level'`difference'`mdev'`fodev'`iid'`ec'" == "" {
		if "`anything'" == "diff" {
			loc difference			"difference"
		}
		else {
			loc `anything'			"`anything'"
		}
	}
	if `todo' == 1 & "`fodev'" == "" {
		di as err "options bodev and model(`level'`difference'`mdev') may not be combined"
		exit 184
	}
	if "`difference'" != "" {
		loc difference		"diff"
	}
	if "`iid'`ec'" != "" {
		if "`level'`mdev'`fodev'" != "" {
			di as err "options `iid'`ec' and model(`level'`mdev'`fodev') may not be combined"
			exit 184
		}
		loc model			"iid"
	}
	else {
		loc model			"`level'`difference'`mdev'`fodev'"
	}

	sret loc model		"`model'"
end

*==================================================*
**** syntax parsing for the instrument lag range ****
program define xtdpdgmm_parse_lagrange, sclass
	version 13.0
	syntax , MAXLag(integer) [Lagrange(numlist max=2 int miss) Difference BODev Model(string) GMMiv]

	loc minlag			= - `maxlag'
	if "`difference'" != "" | "`bodev'" != "" {
		loc --maxlag
	}
	if "`model'" == "fodev" {
		loc --maxlag
	}
	if "`model'" == "diff" {
		loc ++minlag
	}
	gettoken lag1 lag2 : lagrange
	if "`gmmiv'" != "" {
		if `lag1' == . {
			loc lag1			= `minlag'
		}
		if "`lag2'" == "" {
			loc lag2			= `maxlag'
		}
		else if `lag2' == . {
			loc lag2			= `maxlag'
		}
	}
	else if "`lag2'" == "" {
		loc lag2			= `lag1'
	}
	if `lag1' < `minlag' | `lag2' > `maxlag' {
		di as err "lagrange() invalid -- invalid numlist has elements outside of allowed range"
		exit 125
	}
	else if `lag1' > `lag2' {
		di as err "lagrange() invalid -- invalid numlist has elements out of order"
		exit 124
	}
	loc lag2				: list retok lag2
	if `lag1' == `lag2' {
		if `lag1' == 0 {
			loc lagrange		""
		}
		else if `lag1' < 0 {
			loc lagrange		"L(`lag1')."
		}
		else if `lag1' > 0 {
			loc lagrange		"L`lag1'."
		}
	}
	else {
		loc lagrange		"L(`lag1'/`lag2')."
	}

	sret loc lag1		= `lag1'
	sret loc lag2		= `lag2'
	sret loc lagrange	"`lagrange'"
end

*==================================================*
**** syntax parsing for weighting matrix ****
program define xtdpdgmm_parse_wmatrix, sclass
	version 13.0
	syntax [anything] , [Ratio(numlist max=1 >=0)]

	loc length			: length loc anything
	if `"`anything'"' == "" | `"`anything'"' == substr("unadjusted", 1, max(2, `length')) {
		loc anything		"unadjusted"
	}
	else if `"`anything'"' == substr("independent", 1, max(3, `length')) {
		loc anything		"independent"
	}
	else if `"`anything'"' == substr("separate", 1, max(3, `length')) {
		loc anything		"separate"
	}
	else {
		di as err "option wmatrix() incorrectly specified"
		exit 198
	}
	if "`ratio'" == "" {
		loc ratio			= 0
	}

	sret loc wmatrix	"`anything'"
	sret loc ratio		= `ratio'
end

*==================================================*
**** syntax parsing for variance-covariance matrix ****
program define xtdpdgmm_parse_vce, sclass
	version 13.0
	sret clear
	syntax , [VCE(passthru) TWOstep IGMM Model(string)]

	cap _vce_parse , opt(CONVENTIONAL Robust) argopt(CLuster) : , `vce'
	if "`r(vce)'" == "" {
		cap _vce_parse , : , `vce'
	}
	if _rc != 0 {
		cap _vce_parse , argopt(CONVENTIONAL Robust CLuster) : , `vce'
		if _rc != 0 {
			if "`r(vce)'" == "cluster" {
				di as err "option vce(cluster) incorrectly specified"
				exit 198
			}
			_vce_parse , : , `vce'
		}
		loc vceargs			"`r(vceargs)'"
		loc vceargs			: subinstr loc vceargs "," ""
		loc vceargs			: list retokenize vceargs
		if "`vceargs'" != "" {
			xtdpdgmm_parse_vce_model `model' , `vceargs'
			loc model			"`s(model)'"
		}
	}
	loc vce				"`r(vce)'"
	if "`vce'" == "cluster" {
		if `: word count `r(cluster)'' > 1 {
			di as err "option vce(cluster) incorrectly specified -- too many arguments"
			exit 198
		}
		loc clustvar		"`r(cluster)'"
		if "`clustvar'" != "`_dta[_TSpanel]'" {
			xtdpdgmm_cluster `clustvar' `if' `in'
		}
	}

	if "`vce'" == "" {
		sret loc vce		"conventional"
	}
	else if "`vce'" == "cluster" {
		sret loc vce		"robust"
		sret loc clustvar	"`clustvar'"
	}
	else {
		sret loc vce		"`vce'"
	}
	sret loc model		"`model'"
end

*==================================================*
**** syntax parsing for standard instruments ****
program define xtdpdgmm_parse_vce_model, sclass
	version 13.0
	syntax anything , [	Model(string)						///
						Difference]							// historical since version 2.0.3

	if "`difference'" == "" {
		xtdpdgmm_parse_model `anything' , todo(2) `model'
	}
	else {
		if "`model'" != "" {
			di as err "options difference and model() may not be combined"
			exit 198
		}
		sret loc model		"diff"
	}
end

*==================================================*
**** check if panel identifier is nested within cluster identifier ****
// (inspired by _xtreg_chk_cl2.ado)
program define xtdpdgmm_cluster, rclass sort
	version 13.0
	syntax varname [if] [in]
	marksample touse
	sort `varlist'

	tempname aux aux2
	qui by `varlist': gen long `aux' = cond(_n == 1, 1, 0) if `touse'
	qui replace `aux' = sum(`aux')
	sort `_dta[_TSpanel]' `varlist'
	qui by `_dta[_TSpanel]': gen long `aux2' = `aux'[1] - `aux'[_N]
	qui count if `aux2' != 0 & `touse'
	if r(N) > 0 {
		di as err "panels are not nested within clusters"
		exit 498
	}
end
	
*==================================================*
*** version history ***
* version 2.2.2  03sep2019  bug with default of suboption lagrange() fixed; bug with labels of generated instruments fixed
* version 2.2.1  20aug2019  bug with option difference of estat overid fixed
* version 2.2.0  07aug2019  factor variables supported; bug with option overid fixed
* version 2.1.1  20jul2019  option small added; bug with if-condition fixed
* version 2.1.0  19jun2019  option overid added together with option difference for postestimation command estat overid
* version 2.0.4  23apr2019  bug with option vce(cluster) fixed that was introduced in version 2.0.0
* version 2.0.3  20mar2019  suboptions model(mdev) and model(fodev) added for option vce(); option norescale added; option noanalytic replaces option analytic; option model() added
* version 2.0.2  17mar2019  bug with option from() fixed that was introduced in version 2.0.0
* version 2.0.1  11mar2019  bug with time series operators in indepvars fixed that was introduced in version 2.0.0 under Stata versions prior to 08mar2018
* version 2.0.0  10mar2019  Stata 13 required; option nl() replaces options noserial and iid; option igmm and related options added; estat overid reports two versions of the test; collinearity check on instruments performed; labels attached to generated instruments
* version 1.1.3  24sep2018  bug fixed if some groups have no first-differenced observations
* version 1.1.2  15sep2018  bug fixed with option lagrange()
* version 1.1.1  07sep2018  bug fixed with option lagrange(); option iv added to predict
* version 1.1.0  29aug2018  options iid, collapse, analytic, and vce(cluster) added; suboptions model(mdev), model(fodev), and bodev added; suboption lagrange() improved
* version 1.0.2  04may2018  option teffects added; postestimation command estat mmsc added
* version 1.0.1  21aug2017  improved help files
* version 1.0.0  31may2017  available online at www.kripfganz.de
* version 0.1.0  25may2017
* version 0.0.3  21may2017
* version 0.0.2  03may2017
* version 0.0.1  03apr2017
