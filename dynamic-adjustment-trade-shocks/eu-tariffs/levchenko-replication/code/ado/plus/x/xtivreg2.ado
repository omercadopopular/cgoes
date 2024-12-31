*! xtivreg2 1.0.17 19Feb2015
*! author mes
* 01.0.02 - Wasn't rewriting collinear/dups macro lists for time-series operators
*           Fixed version bug.  Added cmd to saved locals.
* 01.0.03 - Update to match ivreg2 2.1.15 including endog option
* 01.0.04 - Fixed bug in reporting obs numbers with weights; now ob numbers weighted for fw and iw only
* 01.0.05 - Added support for ivreg28
* 01.0.06 - Fixed replay bug
* 01.0.07 - Added cmdline macro
* 01.0.08 - Tweaked checks for v8 vs >8, ivreg2 vs ivreg28
* 01.0.09 - Fixed annoying bug in FD that reversed order of variables
* 01.0.10 - Fixed bug that didn't allow partial() with FE and time series operators.
*           NB: FD and partial with TS operators not feasible; would require substantial rewrite of FD
*           block or rewrite of ivreg2 code
*           allowed 2-level clustering as supported by ivreg2
* 01.0.11 - Fixed bug in reporting of e(df_m) with cluster - counted FEs but shouldn't have (vcv, F etc. were OK)
* 01.0.12 - Added check for demeaning of time variable.
* 01.0.13 - Fixed bug that didn't allow saved/displayed first-stage results for endog vars with TS operator
*           Also made similar changes relating to RF results and to use of TS-prefixed var as dep var in main eq.
* 01.0.14 - Changed call to ivreg2 from qui to noi with nooutput option so that ivreg2 reports collinearities, errors, etc.
*           Added qui to gen of weight var to suppress msg about missings created.
*           Added nooutput option. Added check for ivreg210.  Consolidated code for checking which ivreg2 installed.
* 01.0.15 - Added version control to call to ivreg2 so that call is under original calling version
*           rather than version set locally by xtivreg2.
* 01.0.16 - Fixed bug in first-stage display connected to version control.
* 01.0.17 - Fixed bug (partial vs fwl) that would not allow running under Stata 8 or with ivreg28
*           Ensured correct support for 2-step GMM ("gmm" in ivreg28, "gmm2s" in ivreg29 onwards)

program define xtivreg2, eclass byable(recall)
	version 8.2
	local lversion 01.0.17

* Needed for call to ivreg2
	local ver = _caller()
	local ver : di %6.1f `ver'

* ivreg28 called option "fwl"; ivreg29 and onwards calls it "partial"
	if `ver' < 9 {
		local partialopt "fwl"
	}
	else {
		local partialopt "partial"
	}

* Before replay() or estimation blocks, set ivreg2 command
	tempname regest
	capture _estimates hold `regest', restore
* Look for latest installed version of ivreg2
* Start with ivreg2
	local ivreg2_cmd "ivreg2"
	capture `ivreg2_cmd', version
	if _rc != 0 {
* No ivreg2, check for ivreg210
		local ivreg2_cmd "ivreg210"
		capture `ivreg2_cmd', version
		if _rc != 0 {
* No ivreg210, check for ivreg29
			local ivreg2_cmd "ivreg29"
			capture `ivreg2_cmd', version
			if _rc != 0 {
* No ivreg29, check for ivreg28
				local ivreg2_cmd "ivreg28"
				capture `ivreg2_cmd', version
			}
		}
	}
* Done checking for an ivreg2, confirm found or not
	if _rc != 0 {
* 4 strikes and you're out.
di as err "Error - must have ivreg2/ivreg28/ivreg29/ivreg210 version 2.1.15 or greater installed"
		exit 601
	}
	local vernum "`e(version)'"
	capture _estimates unhold `regest'
	if ("`vernum'" < "02.1.15") | ("`vernum'" > "09.9.99") {
di as err "Error - must have ivreg2/ivreg28/ivreg29/ivreg210 version 2.1.15 or greater installed"
		exit 601
	}
* Macro `ivreg2_cmd' now set with appropriate ivreg2 command.

* replay() previous results
	if replay() {
		syntax [, FIRST FFIRST rf Level(integer $S_level) NOHEader NOFOoter NOOUTput /*
			*/ EForm(string) PLUS VERsion]

		if "`version'" != "" & "`first'`ffirst'`rf'`noheader'`nofooter'`eform'`plus'" != "" {
			di as err "option version not allowed"
			error 198
		}
		if "`version'" != "" {
			di in gr "`lversion'"
			ereturn clear
			ereturn local version `lversion'
			ereturn local cmd "xtivreg2"
			exit
		}
		if `"`e(cmd)'"' != "xtivreg2"  {
			error 301
		}
* End replay block
	}
	else {
* Start estimation block
		local cmdline "xtivreg2 `*'"

		syntax [anything(name=0)] [if] [in] [aw fw pw iw/] , [ fe fd /*
			*/	Ivar(varname) Tvar(varname) first ffirst rf /*
			*/	savefirst SAVEFPrefix(name) saverf SAVERFPrefix(name) CLuster(varlist) /*
			*/	orthog(string) ENDOGtest(string) REDundant(string) PARTIAL(string) /*
			*/	BW(string) SKIPCOLL NOHEader NOFOoter NOOUTput GMM GMM2s * ]

* Option called gmm in ivreg28, gmm2s in ivreg29 onwards
		if "`gmm'`gmm2s'" ~= "" {
			if `ver' < 9 {
				local gmm2s "gmm"
			}
			else {
				local gmm2s "gmm2s"
			}
		}

		if ("`fe'"=="" & "`fd'"=="") | ("`fe'"~="" & "`fd'"~="") {
di as err "error - must specify either fe or fd option"
			error 198
		}
		
		if "`bw'"=="auto" {
di as err "error - automatic bandwidth selection not supported by -xtivreg2-"
			error 198
		}

* Also catches inconsistencies between i/tvar and tsset variables
		xt_iis `ivar'
		local ivar "`s(ivar)'"

		capture tsset
		if "`tvar'" == "" {
			local tvar "`r(timevar)'"
		}
		else if "`tvar'"!="`r(timevar)'" {
di as err "invalid tvar() option - data already -tsset-"
			exit 5
		}
		if "`tvar'"!="" | "`fd'"!="" {
			xt_tis `tvar'
			local tvar "`s(timevar)'"
		}

		if "`skipcoll'"=="" {
			qui _rmcoll `varlist'
			local retlist `r(varlist)' `ivar'
			qui _rmcoll `retlist'
			if "`r(varlist)'" ~= "`retlist'" {
				di as err "independent variables " _c
				di as err "are collinear with the panel variable" _c
				di as err " `ivar'"
				exit 198
			}
		}		

		local n 0

		gettoken lhs 0 : 0, parse(" ,[") match(paren)
		IsStop `lhs'
		if `s(stop)' {
			error 198
		}
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
					local endo `endo' `p'
					gettoken p lhs : lhs, parse(" =")
				}
* To enable Cragg HOLS estimator, allow for empty endo list
				if "`endo'" != "" {
					tsunab endo : `endo'
				}
* To enable OLS estimator with (=) syntax, allow for empty exexog list
				if "`lhs'" != "" {
					tsunab exexog : `lhs'
				}
			}
			else {
				local inexog `inexog' `lhs'
			}
			gettoken lhs 0 : 0, parse(" ,[") match(paren)
			IsStop `lhs'
		}
		local 0 `"`lhs' `0'"'

		tsunab inexog : `inexog'
		tokenize `inexog'
		local lhs "`1'"
		local 1 " " 
		local inexog `*'

		if "`gmm'`gmm2s'" != "" & "`exexog'" == "" {
di as err "option -gmm- invalid: no excluded instruments specified"
			exit 102
		}

* If first requested, also needs to request savefirst or savefprefix and set drop flag
		if "`first'" != "" & "`savefirst'`savefprefix'" == "" {
			local savefirst "savefirst"
			local dropfirst "dropfirst"
		}
		if "`savefirst'" != "" & "`savefprefix'" == "" {
			local savefprefix "_xtivreg2_"
		}

* If rf requested, also needs to request saverf or saverfprefix and set drop flag
		if "`rf'" != "" & "`saverf'`saverfprefix'" == "" {
			local saverf "saverf"
			local droprf "droprf"
		}
		if "`saverf'" != "" & "`saverfprefix'" == "" {
			local saverfprefix "_xtivreg2_"
		}

		tempvar wvar
		if "`weight'" !="" {
			local wtexp `"[`weight'=`exp']"'
			qui gen double `wvar'=`exp'
		}
		else {
			qui gen long `wvar'=1
		}

* Begin estimation blocks
		if "`fd'" ~= "" {
			local lhs_fd "d.`lhs'"
			foreach vn of local inexog {
				local inexog_fd "`inexog_fd' d.`vn'"
			}
			foreach vn of local exexog {
				local exexog_fd "`exexog_fd' d.`vn'"
			}
			foreach vn of local endo {
				local endo_fd "`endo_fd' d.`vn'"
			}
			foreach vn of local orthog {
				local orthog_fd "`orthog_fd' d.`vn'"
			}
			foreach vn of local endogtest {
				local endogtest_fd "`endogtest_fd' d.`vn'"
			}
			foreach vn of local redundant {
				local redundant_fd "`redundant_fd' d.`vn'"
			}
* Do this even though ivreg2 currently won't accept TS operators with partial()
			foreach vn of local partial {
				local partial_fd "`partial_fd' d.`vn'"
			}

* Use nooutput option to get collinearity etc. messages
* Ensures that these are reported before any fatal ivreg2 error that might occur
* Called under version control using calling version
			version `ver' : `ivreg2_cmd' `lhs_fd' `inexog_fd' (`endo_fd' = `exexog_fd') `wtexp' `if', /*
				*/	`first' `ffirst' `rf' /*
				*/	savefprefix(`savefprefix') saverfprefix(`saverfprefix') /*
				*/	cluster(`cluster') orthog(`orthog_fd') endog(`endogtest_fd') /*
				*/	redundant(`redundant_fd') `partialopt'(`partial_fd') tvar(`tvar') bw(`bw') `options' /*
				*/	`gmm2s' nooutput
			preserve
			tempvar touse
			qui gen `touse'=e(sample)
			tempname T_i

			sort `ivar' `touse'
* Only iw and fw use weighted observation counts
				if "`weight'" == "iweight" | "`weight'" == "fweight" {
					qui by `ivar' `touse': gen long `T_i' = sum(`wvar') if `touse'
				}
				else {
					qui by `ivar' `touse': gen long `T_i' = _N if `touse'
				}
			qui by `ivar' `touse': replace  `T_i' = . if _n~=_N
			qui count if `T_i' < .
			ereturn scalar N_g=r(N)

			tempname g_min g_avg g_max
			qui by `ivar' `touse' : replace `T_i'=`T_i'[_N] if `touse' & _n<_N
* Only iw and fw report weighted observation counts
			if "`weight'" == "iweight" | "`weight'" == "fweight" {
					sum `T_i' `wtexp', meanonly
					ereturn scalar g_avg = r(sum_w)/e(N_g)
				}
				else {
					sum `T_i', meanonly
					ereturn scalar g_avg = r(N)/e(N_g)
				}

			ereturn scalar g_min = r(min)
			ereturn scalar g_max = r(max)

			ereturn scalar df_b=e(df_m)
			ereturn scalar sigma_e=e(rmse)
*			ereturn scalar singleton=`singleton'
			ereturn local xtmodel "fd"
			ereturn local version `lversion'
			ereturn local predict "xtivreg2_p"
			ereturn local ivar "`ivar'"
			ereturn local tvar "`tvar'"

			restore
* End FD block
		}
		else {
* Must be fixed effects
			marksample touse
			markout `touse' `lhs' `inexog' `exexog' `endo' `cluster' `tvar', strok

* Catch weird bug if ivar is used as a regressor
			local allvars "`lhs' `inexog' `endo' `exexog'"
			local allvars : subinstr local allvars "`ivar'" "`ivar'", all word count(local ivar_ct)
			if `ivar_ct'>0 {
di as err "Error - cannot use tsset panel variable `ivar' as dependent variable, regressor or IV."
				exit 198
			}
* Don't allow tvar to be used as a regressor either - too dangerous
			if "`tvar'"~="" {
				local allvars "`lhs' `inexog' `endo' `exexog'"
				local allvars : subinstr local allvars "`tvar'" "`tvar'", all word count(local tvar_ct)
				if `tvar_ct'>0 {
di as err "Error - cannot use tsset time variable `tvar' as dependent variable, regressor or IV."
di as err "Create a new variable equal to `tvar' and use it instead."
					exit 198
				}
			}

			tsrevar `lhs', substitute
			local lhs_t "`r(varlist)'"
			tsrevar `inexog', substitute
			local inexog_t "`r(varlist)'"
			tsrevar `endo', substitute
			local endo_t "`r(varlist)'"
			tsrevar `exexog', substitute
			local exexog_t "`r(varlist)'"
			tsrevar `orthog', substitute
			local orthog_t "`r(varlist)'"
			tsrevar `endogtest', substitute
			local endogtest_t "`r(varlist)'"
			tsrevar `redundant', substitute
			local redundant_t "`r(varlist)'"
			tsrevar `partial', substitute
			local partial_t "`r(varlist)'"

* preserve here, prior to first sort
			preserve

			tempvar T_i
			sort `ivar' `touse'
* Catch singletons.  Must use unweighted data
			qui by `ivar' `touse': gen long `T_i' = _N if _n==_N & `touse'
			qui count if `T_i' == 1
			local singleton=r(N)
			if `singleton' > 0 {
di in ye "Warning - singleton groups detected.  " `singleton' " observation(s) not used."
			}
			qui replace `touse'=0 if `T_i'==1
			drop `T_i'

* Catch clustvar-ivar inconsistencies
			if "`cluster'"!="" {
* Allow for 2-way clustering
				tokenize `cluster'
				local cluster1 "`1'"
				local cluster2 "`2'"
				if "`cluster1'" ~= "`ivar'" & "`cluster2'" ~= "`ivar'" {
					tempvar ic_ct
					sort `ivar' `cluster1' `touse'
					qui by `ivar' `cluster1' `touse': gen long `ic_ct' = 1 if _n==_N & `touse'
					sort `ivar' `touse'
					qui by `ivar' `touse': replace `ic_ct'=sum(`ic_ct') if `touse'
					qui count if `ic_ct' > 1 & `ic_ct' < .
					if r(N)>1 & r(N)<. & "`cluster2'"=="" {
di as err "cluster option not supported if a panel spans more than one cluster"
						exit 198
					}
					else if r(N)>1 & r(N)<. & "`cluster2'"~="" {
* Need to check second cluster var if it exists
						drop `ic_ct'
						sort `ivar' `cluster2' `touse'
						qui by `ivar' `cluster2' `touse': gen long `ic_ct' = 1 if _n==_N & `touse'
						sort `ivar' `touse'
						qui by `ivar' `touse': replace `ic_ct'=sum(`ic_ct') if `touse'
						qui count if `ic_ct' > 1 & `ic_ct' < .
						if r(N)>1 & r(N)<. {
di as err "cluster option not supported if a panel spans more than one cluster"
						exit 198
						}
					}
				}
			}

			sort `ivar' `touse'
* Only iw and fw use weighted observation counts
			if "`weight'" == "iweight" | "`weight'" == "fweight" {
				qui by `ivar' `touse': gen long `T_i' = sum(`wvar') if `touse'
			}
			else {
				qui by `ivar' `touse': gen long `T_i' = _N if `touse'
			}
			qui by `ivar' `touse': replace  `T_i' = . if _n~=_N
			qui count if `T_i' < .
			local N_g=r(N)
			local dofminus=`N_g'
			local allvars "`lhs_t' `inexog_t' `endo_t' `exexog_t'"
			foreach var of local allvars {
				tempvar `var'_m
* To get weighted means
				qui by `ivar' `touse' : gen double ``var'_m'=sum(`var'*`wvar')/sum(`wvar') if `touse'
				qui by `ivar' `touse' : replace    ``var'_m'=``var'_m'[_N] if `touse' & _n<_N
* This guarantees that the demeaned variables are doubles
				qui by `ivar' `touse' : replace ``var'_m'=`var'-``var'_m'[_N]           if `touse'
				drop `var'
				rename ``var'_m' `var'
			}
* Use nooutput option to get collinearity etc. messages
* Ensures that these are reported before any fatal ivreg2 error that might occur
			version `ver' : `ivreg2_cmd' `lhs_t' `inexog_t' (`endo_t' = `exexog_t') `wtexp' if `touse', /*
				*/	dofminus(`dofminus') nocons `first' `ffirst' `rf' /*
				*/	savefprefix(`savefprefix') saverfprefix(`saverfprefix') /*
				*/	cluster(`cluster') orthog(`orthog_t') endog(`endogtest_t') /*
				*/	redundant(`redundant_t') `partialopt'(`partial_t') tvar(`tvar') bw(`bw') `options' /*
				*/	`gmm2s' nooutput

			ereturn scalar N_g   = `N_g'
			qui by `ivar' `touse' : replace `T_i'=`T_i'[_N] if `touse' & _n<_N
* Only iw and fw report weighted observation counts
			if "`weight'" == "iweight" | "`weight'" == "fweight" {
				sum `T_i' `wtexp', meanonly
				ereturn scalar g_avg = r(sum_w)/e(N_g)
			}
			else {
				sum `T_i', meanonly
				ereturn scalar g_avg = r(N)/e(N_g)
			}
			ereturn scalar g_min = r(min)
			ereturn scalar g_max = r(max)
* Will need these for first/rf option
			tempname g_min g_avg g_max
			scalar `g_min'=e(g_min)
			scalar `g_avg'=e(g_avg)
			scalar `g_max'=e(g_max)
			restore

* Replace any time series locals with original time series names
			tempname b V S W firstmat

* First replace ts locals in saved first and/or rf results, if any
			if "`first'`savefirst'`rf'`saverf'" ~= "" {
				local eqlist "`e(rfeq)' `e(firsteqs)'"
* In case estimates names have changed, we will be saving under new names.
				local rrfeq "`e(rfeq)'"
				local rfirsteqs "`e(firsteqs)'"
				foreach eqname of local eqlist {
					_estimates hold `regest', restore
					capture estimates restore `eqname'
					if _rc == 0 {
* In case estimates name has changed, e.g., dep var of first-stage regression,
* we will want to re-save under a replace new name, reqname
						estimates drop `eqname'
						local reqname "`eqname'"
						mat `b' =e(b)
						mat `V' =e(V)
						mat `S' =e(S)
						local cnames  : colnames `b'
						local cnamesS : colnames `S'
						local vnames "`lhs'     `endo'   `inexog'   `exexog'"
						local vnames_t "`lhs_t' `endo_t' `inexog_t' `exexog_t'"
* Macros to be fixed
						local finsts  "`e(insts)'"
						local finexog "`e(inexog)'"
						local fdv     "`e(depvar)'"
						foreach vn of local vnames {
							tokenize `vnames_t'
							local vn_t `1'
							mac shift
							local vnames_t `*'
							local cnames  : subinstr local cnames   "`vn_t'" "`vn'"
							local cnamesS : subinstr local cnamesS  "`vn_t'" "`vn'"
* Macro varlists
							local finsts   : subinstr local finsts  "`vn_t'" "`vn'"
							local finexog  : subinstr local finexog "`vn_t'" "`vn'"
							local fdv      : subinstr local fdv     "`vn_t'" "`vn'"
* Titles. TS ops not allowed so change . to _
							local reqname  : subinstr local reqname  "`vn_t'" "`vn'"
							local reqname  : subinstr local reqname "."      "_"
						}
* Change in list of equation names
						local rrfeq     : subinstr local rrfeq     "`eqname'" "`reqname'"
						local rfirsteqs : subinstr local rfirsteqs "`eqname'" "`reqname'"
						mat colnames `b'       =`cnames'
						mat colnames `V'       =`cnames'
						mat rownames `V'       =`cnames'
						mat colnames `S'       =`cnamesS'
						mat rownames `S'       =`cnamesS'
						ereturn post `b' `V', depname(`fdv') noclear
						ereturn matrix S `S'
						ereturn local insts    `finsts'
						ereturn local inexog   `finexog'
						ereturn scalar N_g=`N_g'
						ereturn scalar df_a=`N_g'
						ereturn scalar df_b=e(df_m)
						if "`cluster'"=="" {
							ereturn scalar df_m=`N_g'+e(df_b)
						}
						else {
							ereturn scalar df_m=e(df_b)
						}
						ereturn scalar sigma_e=e(rmse)
						ereturn local xtmodel "fe"
						ereturn local version `lversion'
						ereturn local predict "xtivreg2_p"
						ereturn local ivar "`ivar'"
						ereturn local tvar "`tvar'"
						ereturn scalar g_min = `g_min'
						ereturn scalar g_avg = `g_avg'
						ereturn scalar g_max = `g_max'
						ereturn local cmd "xtivreg2"
						local eqtitle "`e(_estimates_title)'"
						capture est store `reqname', title(`eqtitle')
					}
					_estimates unhold `regest'
				}
			}
* Now fix main results
			mat `b'       =e(b)
			mat `V'       =e(V)
			mat `S'       =e(S)
			mat `W'       =e(W)
			mat `firstmat'=e(first)
* Matrix column names to be changed
			local cnames  : colnames `b'
			local cnamesS : colnames `S'
			local cnamesW : colnames `W'
			local cnamesf : colnames `firstmat'
* Full list of names to change
			local vnames   "`lhs'   `inexog'   `endo'   `exexog'"
			local vnames_t "`lhs_t' `inexog_t' `endo_t' `exexog_t'"
* Macros to be fixed
			local insts     "`e(insts)'"
			local inexog    "`e(inexog)'"
			local instd     "`e(instd)'"
			local exexog    "`e(exexog)'"
			local depvar    "`e(depvar)'"
			local clist     "`e(clist)'"
			local elist     "`e(elist)'"
			local redlist   "`e(redlist)'"
			local partial  "`e(partial)'"
* If any collinear or duplicates
			local collin    "`e(collin)'"
			local dups      "`e(dups)'"
			local insts1    "`e(insts1)'"
			local inexog1   "`e(inexog1)'"
			local instd1    "`e(instd1)'"
			local exexog1   "`e(exexog1)'"
			local partial1  "`e(partial1)'"
			foreach vn of local vnames {
				tokenize `vnames_t'
				local vn_t `1'
				mac shift
				local vnames_t `*'
				local cnames  : subinstr local cnames    "`vn_t'" "`vn'"
				local cnamesS : subinstr local cnamesS   "`vn_t'" "`vn'"
				local cnamesW : subinstr local cnamesW   "`vn_t'" "`vn'"
				local cnamesf : subinstr local cnamesf   "`vn_t'" "`vn'"
* Macro varlists
				local insts   : subinstr local insts     "`vn_t'" "`vn'"
				local inexog  : subinstr local inexog    "`vn_t'" "`vn'"
				local instd   : subinstr local instd     "`vn_t'" "`vn'"
				local exexog  : subinstr local exexog    "`vn_t'" "`vn'"
				local partial : subinstr local partial   "`vn_t'" "`vn'"
				local depvar  : subinstr local depvar    "`vn_t'" "`vn'"
				local clist   : subinstr local clist     "`vn_t'" "`vn'"
				local elist   : subinstr local elist     "`vn_t'" "`vn'"
				local redlist : subinstr local redlist   "`vn_t'" "`vn'"
				local collin  : subinstr local collin    "`vn_t'" "`vn'"
				local dups    : subinstr local dups      "`vn_t'" "`vn'"
				local insts1  : subinstr local insts1    "`vn_t'" "`vn'"
				local inexog1 : subinstr local inexog1   "`vn_t'" "`vn'"
				local instd1  : subinstr local instd1    "`vn_t'" "`vn'"
				local exexog1 : subinstr local exexog1   "`vn_t'" "`vn'"
				local partial1: subinstr local partial1  "`vn_t'" "`vn'"
			}
			mat colnames `b'       =`cnames'
			mat colnames `V'       =`cnames'
			mat rownames `V'       =`cnames'
			mat colnames `S'       =`cnamesS'
			mat rownames `S'       =`cnamesS'
			mat colnames `W'       =`cnamesW'
			mat rownames `W'       =`cnamesW'
			mat colnames `firstmat'=`cnamesf'

			ereturn post `b' `V', dep(`depvar') esample(`touse') noclear
			ereturn matrix S `S'
			if ~matmissing(`W') {
				ereturn matrix W `W'
			}
			if ~matmissing(`firstmat') {
				ereturn matrix first `firstmat'
			}
			ereturn local insts    `insts'
			ereturn local inexog   `inexog'
			ereturn local instd    `instd'
			ereturn local exexog   `exexog'
			ereturn local partial  `partial'
			ereturn local collin   `collin'
			ereturn local dups     `dups'
			ereturn local insts1   `insts1'
			ereturn local inexog1  `inexog1'
			ereturn local instd1   `instd1'
			ereturn local exexog1  `exexog1'
			ereturn local partial1 `partial1'
			ereturn local depvar   `depvar'
			ereturn local clist    `clist'
			ereturn local elist    `elist'
			ereturn local redlist  `redlist'
			ereturn scalar N_g=`N_g'
			ereturn scalar df_b=e(df_m)
			ereturn scalar df_a=e(N_g)
			if "`cluster'"=="" {
				ereturn scalar df_m=e(N_g)+e(df_b)
			}
			else {
* FEs with cluster don't use up degrees of freedom as incidental parameters
				ereturn scalar df_m=e(df_b)
			}
			ereturn scalar sigma_e=e(rmse)
			ereturn scalar singleton=`singleton'
			ereturn local xtmodel "fe"
			ereturn local version `lversion'
			ereturn local predict "xtivreg2_p"
			ereturn local ivar "`ivar'"
			ereturn local tvar "`tvar'"
			if "`first'`savefirst'`rf'`saverf'" ~= "" {
				ereturn local rfeq     `rrfeq'
				ereturn local firsteqs `rfirsteqs'
			}
* End fixed effects block
		}

* End estimation block
	}

	if "`noheader'`nooutput'"=="" {
		if "`e(xtmodel)'"=="fd" {
			di in gr _newline "FIRST DIFFERENCES ESTIMATION"
			di in gr "{hline 28}"
		}
		else {
			di in gr _newline "FIXED EFFECTS ESTIMATION"
			di in gr "{hline 24}"
		}
		di in gr "Number of groups = " in ye %9.0g e(N_g) /*
			*/  _col(49) in gr "Obs per group: min" _col(68) "=" /*
			*/	_col(70) in ye %9.0g e(g_min)
		di in gr _col(64) in gr "avg" _col(68) "=" /*
			*/	_col(70) in ye %9.1f e(g_avg)
		di in gr _col(64) in gr "max" _col(68) "=" /*
			*/	_col(70) in ye %9.0g e(g_max)
	}

	ereturn local cmd "`ivreg2_cmd'"
	ereturn local cmdline "`cmdline'"
	if "`eform'"!="" {
		local efopt "eform(`eform')"
	}
	if "`level'"!="" {
		local levopt "level(`level')"
	}
	if "`nooutput'"=="" {
		if "`e(xtmodel)'"=="fd" {
				version `ver' : `ivreg2_cmd', `first' `ffirst' `rf' `noheader' `nofooter' `plus' `levopt' `efopt' `dropfirst' `droprf'
		}
		else {
* ivreg2 F stat looks in df_m, not df_b, for F dof
			local temp_df_m = e(df_m)
			ereturn scalar df_m=e(df_b)
			version `ver' : `ivreg2_cmd', `first' `ffirst' `rf' `noheader' `nofooter' `plus' `levopt' `efopt' `dropfirst' `droprf'
			ereturn scalar df_m=`temp_df_m'
		}
	}
	if "`dropfirst'" != "" {
		local firsteqs "`e(firsteqs)'"
		foreach eqname of local firsteqs {
			capture estimates drop `eqname'
		}
		ereturn local firsteqs
	}
	if "`droprf'" != "" {
		local eqname "`e(rfeq)'"
		capture estimates drop `eqname'
		ereturn local rfeq
	}		
	ereturn local cmd "xtivreg2"
* End display block

end

**********************************************************************

* Taken from ivreg2
program define Disp 
	version 8.2
	syntax [anything] [, _col(integer 15) ]
	local len = 80-`_col'+1
	local piece : piece 1 `len' of `"`anything'"'
	local i 1
	while "`piece'" != "" {
		di in gr _col(`_col') "`first'`piece'"
		local i = `i' + 1
		local piece : piece `i' `len' of `"`anything'"'
	}
	if `i'==1 { 
		di 
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
* per official ivreg 5.1.3
	if substr(`"`0'"',1,3) == "if(" {
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

exit
