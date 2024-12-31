*! ivreg28 2.1.22  6July2007
*! authors cfb & mes
*! cloned from official ivreg version 5.0.9  19Dec2001
*! see end of file for version comments

*  Variable naming:
*  lhs = LHS endogenous
*  endo = RHS endogenous (instrumented)
*  inexog = included exogenous (instruments)
*  exexog = excluded exogenous (instruments)
*  iv = {inexog exexog} = all instruments
*  rhs = {endo inexog} = RHS regressors
*  1 at the end of the name means the varlist after duplicates and collinearities removed
*  ..1_ct at the end means a straight count of the list
*  .._ct at the end means ..1_ct with any additional detected cnts removed

program define ivreg28, eclass byable(recall) sortpreserve
	version 8.2
	local lversion 02.1.22
	local ivreg2_cmd "ivreg28"

	if replay() {
		syntax [, FIRST FFIRST RF Level(integer $S_level) NOHEader NOFOoter dropfirst droprf /*
			*/ EForm(string) PLUS VERsion]
		if "`version'" != "" & "`first'`ffirst'`rf'`noheader'`nofooter'`dropfirst'`droprf'`eform'`plus'" != "" {
			di as err "option version not allowed"
			error 198
		}
		if "`version'" != "" {
			di in gr "`lversion'"
			ereturn clear
			ereturn local version `lversion'
			exit
		}
		if `"`e(cmd)'"' != "`ivreg2_cmd'"  {
			error 301
		}
		if "`e(firsteqs)'" != "" & "`dropfirst'" == "" {
* On replay, set flag so saved eqns aren't dropped
			local savefirst "savefirst"
		}
		if "`e(rfeq)'" != "" & "`droprf'" == "" {
* On replay, set flag so saved eqns aren't dropped
			local saverf "saverf"
		}
	}
	else {

		syntax [anything(name=0)] [if] [in] [aw fw pw iw/] [, /*
			*/ FIRST FFIRST NOID NOCOLLIN SAVEFIRST SAVEFPrefix(name) SMall Robust CLuster(varname) /*
			*/ GMM CUE CUEINIT(string) CUEOPTions(string) ORTHOG(string) ENDOGtest(string) FWL(string) /*
			*/ NOConstant Level(integer $S_level) Beta hc2 hc3 /*
			*/ NOHEader NOFOoter NOOUTput title(string) subtitle(string) /*
			*/ DEPname(string) EForm(string) PLUS /*
			*/ BW(string) kernel(string) Tvar(varname) Ivar(varname)/*
			*/ LIML COVIV FULLER(real 0) Kclass(string) /*
			*/ REDundant(string) RF SAVERF SAVERFPrefix(name) /*
			*/ B0(string) SMATRIX(string) WMATRIX(string) EWMATRIX(string) sw swpsd dofminus(integer 0) ]

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
				local temp_ct  : word count `endo'
				if `temp_ct' > 0 {
					tsunab endo : `endo'
				}
* To enable OLS estimator with (=) syntax, allow for empty exexog list
				local temp_ct  : word count `lhs'
				if `temp_ct' > 0 {
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

		if "`gmm'`cue'" != "" & "`exexog'" == "" {
			di in red "option `gmm'`cue' invalid: no excluded instruments specified"
			exit 102
		}

* Process options

* Fuller implies LIML
		if "`liml'" == "" & `fuller' != 0 {
			local liml "liml"
			}

* b0 implies nooutput and noid
		if "`b0'" ~= "" {
			local nooutput "nooutput"
			local noid "noid"
			}

		if "`gmm'" != "" & "`cue'" != "" {
di as err "incompatible options: 2-step efficient gmm and cue gmm"
			exit 198
		}

		if "`b0'" != "" & "`wmatrix'" != "" {
di as err "incompatible options: -b0- and -wmatrix-"
			exit 198
		}

		if "`ewmatrix'" != "" {
			if "`gmm'" != "" {
di as err "incompatible options: -ewmatrix- and 2-step efficient gmm"
			exit 198
			}
			local wmatrix "`ewmatrix'"
		}

* savefprefix implies savefirst
		if "`savefprefix'" != "" & "`savefirst'" == "" {
			local savefirst "savefirst"
		}

* default savefprefix is _ivreg2_
		if "`savefprefix'" == "" {
			local savefprefix "_`ivreg2_cmd'_"
		}

* saverfprefix implies saverf
		if "`saverfprefix'" != "" & "`saverf'" == "" {
			local saverf "saverf"
		}

* default saverfprefix is _ivreg2_
		if "`saverfprefix'" == "" {
			local saverfprefix "_`ivreg2_cmd'_"
		}

* LIML/kclass incompatibilities
		if "`liml'`kclass'" != "" {
			if "`gmm'`cue'" != "" {
di as err "GMM estimation not available with LIML or k-class estimators"
			exit 198
			}
			if `fuller' < 0 {
di as err "invalid Fuller option"
			exit 198
			}
			if "`liml'" != "" & "`kclass'" != "" {
di as err "cannot use liml and kclass options together"
			exit 198
			}
* Process kclass string
			tempname kclass2
			scalar `kclass2'=real("`kclass'")
			if "`kclass'" != "" & (`kclass2' == . | `kclass2' < 0 ) {
di as err "invalid k-class option"
				exit 198
				}			
		}

* HAC estimation.
* If bw is omitted, default `bw' is empty string.
* If bw or kernel supplied, check/set `kernel'.
* Macro `kernel' is also used for indicating HAC in use.
		if "`bw'" != "" | "`kernel'" != "" {
* Need tvar only for markout with time-series stuff
* but data must be tsset for time-series operators in code to work
			if "`tvar'" == "" {
				local tvar "`_dta[_TStvar]'"
			}
			else if "`tvar'"!="`_dta[_TStvar]'" {
di as err "invalid tvar() option - data already tsset"
				exit 5
			}
			if "`ivar'" == "" {
				local ivar "`_dta[_TSpanel]'"
			}
			else if "`ivar'"!="`_dta[_TSpanel]'" {
di as err "invalid ivar() option - data already tsset"
				exit 5
			}
			if "`tvar'" == "" & "`ivar'" != "" {
di as err "missing tvar() option with ivar() option"
				exit 5
			}
			if "`ivar'`tvar'"=="" {
				capture tsset
			}
			else {
				capture tsset `ivar' `tvar'
			}
			capture local tvar "`r(timevar)'"
			capture local ivar "`r(panelvar)'"
			
			if "`tvar'" == "" {
di as err "must tsset data and specify timevar"
				exit 5
			}
			tsreport if `tvar' != .
			if `r(N_gaps)' != 0 & "`ivar'"=="" {
di in gr "Warning: time variable " in ye "`tvar'" in gr " has " /*
	*/ in ye "`r(N_gaps)'" in gr " gap(s) in relevant range"
			}

			if "`bw'" == "" {
di as err "bandwidth option bw() required for HAC-robust estimation"
				exit 102
			}
			local bw real("`bw'")
* Check it's a valid bandwidth
			if   `bw' != int(`bw') | /*
			*/   `bw' == .  | /*
			*/   `bw' <= 0 {
di as err "invalid bandwidth in option bw() - must be integer > 0"
				exit 198
			}
* Convert bw macro to simple integer
			local bw=`bw'

* Check it's a valid kernel
			local validkernel 0
			if lower(substr("`kernel'", 1, 3)) == "bar" | "`kernel'" == "" {
* Default kernel
				local kernel "Bartlett"
				local window "lag"
				local validkernel 1
				if `bw'==1 {
di in ye "Note: kernel=Bartlett and bw=1 implies zero lags used.  Standard errors and"
di in ye "      test statistics are not autocorrelation-consistent."
				}
			}
			if lower(substr("`kernel'", 1, 3)) == "par" {
				local kernel "Parzen"
				local window "lag"
				local validkernel 1
				if `bw'==1 {
di in ye "Note: kernel=Parzen and bw=1 implies zero lags used.  Standard errors and"
di in ye "      test statistics are not autocorrelation-consistent."
				}
			}
			if lower(substr("`kernel'", 1, 3)) == "tru" {
				local kernel "Truncated"
				local window "lag"
				local validkernel 1
			}
			if lower(substr("`kernel'", 1, 9)) == "tukey-han" | lower("`kernel'") == "thann" {
				local kernel "Tukey-Hanning"
				local window "lag"
				local validkernel 1
				if `bw'==1 {
di in ye "Note: kernel=Tukey-Hanning and bw=1 implies zero lags.  Standard errors and"
di in ye "      test statistics are not autocorrelation-consistent."
				}
			}
			if lower(substr("`kernel'", 1, 9)) == "tukey-ham" | lower("`kernel'") == "thamm" {
				local kernel "Tukey-Hamming"
				local window "lag"
				local validkernel 1
				if `bw'==1 {
di in ye "Note: kernel=Tukey-Hamming and bw=1 implies zero lags.  Standard errors and"
di in ye "      test statistics are not autocorrelation-consistent."
				}
			}
			if lower(substr("`kernel'", 1, 3)) == "qua" | lower("`kernel'") == "qs" {
				local kernel "Quadratic spectral"
				local window "spectral"
				local validkernel 1
			}
			if lower(substr("`kernel'", 1, 3)) == "dan" {
				local kernel "Daniell"
				local window "spectral"
				local validkernel 1
			}
			if lower(substr("`kernel'", 1, 3)) == "ten" {
				local kernel "Tent"
				local window "spectral"
				local validkernel 1
			}
			if ~`validkernel' {
				di in red "invalid kernel"
				exit 198
			}
		}

		if "`kernel'" != "" & "`cluster'" != "" {
di as err "cannot use HAC kernel estimator with -cluster- option"
				exit 198
		}

* changed below from `endog' to `endogtest' 2Aug06 MES
		if "`orthog'`endogtest'`redundant'`fwl'" != "" {
			capture tsunab orthog    : `orthog'
			capture tsunab endogtest : `endogtest'
			capture tsunab redundant : `redundant'
			capture tsunab fwl       : `fwl'
		}

		if "`hc2'`hc3'" != "" {
			if "`hc2'"!="" {
				di in red "option `hc2' invalid"
			}
			else	di in red "option `hc3' invalid"
			exit 198
		}

		if "`beta'" != "" {
			di in red "option `beta' invalid"
			exit 198
		}

* Weights
* fweight and aweight accepted as is
* iweight not allowed with robust or gmm and requires a trap below when used with summarize
* pweight is equivalent to aweight + robust
*   but in HAC case, robust implied by `kernel' rather than `robust'

		tempvar wvar
		if "`weight'" == "fweight" | "`weight'"=="aweight" {
			local wtexp `"[`weight'=`exp']"'
			gen double `wvar'=`exp'
		}
		if "`weight'" == "fweight" & "`kernel'" !="" {
			di in red "fweights not allowed (data are -tsset-)"
			exit 101
		}
		if "`weight'" == "iweight" {
			if "`robust'`cluster'`gmm'`kernel'" !="" {
				di in red "iweights not allowed with robust or gmm"
				exit 101
			}
			else {
				local wtexp `"[`weight'=`exp']"'
				gen double `wvar'=`exp'
			}
		}
		if "`weight'" == "pweight" {
			local wtexp `"[aweight=`exp']"'
			gen double `wvar'=`exp'
			local robust "robust"
		}
		if "`weight'" == "" {
* If no weights, define neutral weight variable
			qui gen byte `wvar'=1
		}

* If no kernel (=no HAC) then gmm implies (heteroskedastic-) robust
		if "`kernel'" == "" & "`gmm'" != "" {
			local robust "robust"
		}
		if `dofminus' > 0 {
			local dofmopt "dofminus(`dofminus')"
		}
* Stock-Watson robust SEs.
		if "`sw'`swpsd'" ~= "" {
			if "`kernel'" ~= "" {
di as err "Stock-Watson robust SEs not supported with -kernel- option"
				exit 198
			}
			if "`cue'" ~= "" {
di as err "Stock-Watson robust SEs not supported with -cue- option"
				exit 198
			}
			if "`ivar'"=="" {
di as err "Must specify -ivar- with -sw- option"
				exit 198
			}
		}

		marksample touse
		markout `touse' `lhs' `inexog' `exexog' `endo' `cluster' `tvar', strok

* Weight statement
		if "`weight'" ~= "" {
			sum `wvar' if `touse' `wtexp', meanonly
di in gr "(sum of wgt is " %14.4e `r(sum_w)' ")"
		}

* Set local macro T and check that bw < T
* Also make sure only used sample is checked
		if "`bw'" != "" {
			sum `tvar' if `touse', meanonly
			local T = r(max)-r(min)+1
			if `bw' > `T' {
di as err "invalid bandwidth in option bw() - cannot exceed timespan of data"
				exit 198
			}
		}

************* Collinearities and duplicates block *****************

		if "`noconstant'" != "" {
			local rmcnocons "nocons"
		}

* Check for duplicates of variables
* To mimic official ivreg, in the case of duplicates,
* (1)  inexog > endo
* (2)  inexog > exexog
* (3)  endo + exexog = inexog, as if it were "perfectly predicted"
		local dupsen1 : list dups endo
		local endo1   : list uniq endo
		local dupsex1 : list dups exexog
		local exexog1 : list uniq exexog
		local dupsin1 : list dups inexog
		local inexog1 : list uniq inexog
* Remove inexog from endo
		local dupsen2 : list endo1 & inexog1
		local endo1   : list endo1 - inexog1
* Remove inexog from exexog
		local dupsex2 : list exexog1 & inexog1
		local exexog1 : list exexog1 - inexog1
* Remove endo from exexog
		local dupsex3 : list exexog1 & endo1
		local exexog1 : list exexog1 - endo1
		local dups "`dupsen1' `dupsex1' `dupsin1' `dupsen2' `dupsex2' `dupsex3'"
		local dups    : list uniq dups

		if "`nocollin'" == "" {
* First, collinearities check using canonical correlations approach
* Eigenvalue=1 => included endog is really included exogenous
* Eigenvalue=0 => included endog collinear with another included endog
* Corresponding column names give name of variable
* Code block stolen from below, so some repetition
			local insts1 `inexog1' `exexog1'
			local rhs1   `endo1'   `inexog1'
			local iv1_ct       : word count `insts1'
			local rhs1_ct      : word count `rhs1'
			local endo1_ct     : word count `endo1'
			local exex1_ct     : word count `exexog1'
			local endoexex1_ct : word count `endo1' `exexog1'
			local inexog1_ct   : word count `inexog1'
			if `endo1_ct' > 0 {
				tempname ccmat ccrealev ccimagev cc A XX XXinv ZZ ZZinv XZ XPZX
				qui mat accum `A' = `endo1' `insts1' if `touse' `wtexp', `rmcnocons'
				mat `XX' = `A'[1..`endo1_ct',1..`endo1_ct']
				mat `XXinv'=syminv(`XX')
				mat `ZZ' = `A'[`endo1_ct'+1...,`endo1_ct'+1...]
				mat `ZZinv'=syminv(`ZZ')
				mat `XZ' = `A'[1..`endo1_ct',`endo1_ct'+1...]
				mat `XPZX'=`XZ'*`ZZinv'*`XZ''
				mat `ccmat' = `XXinv'*`XPZX'
				mat eigenvalues `ccrealev' `ccimagev' = `ccmat'
				foreach vn of varlist `endo1' {
					local i=colnumb(`ccmat',"`vn'")
					if round(`ccmat'[`i',`i'],10e-7)==0 {
* Collinear with another endog, so remove from endog list
						local endo1 : list endo1-vn
					}
					if round(`ccmat'[`i',`i'],10e-7)==1 {
* Collinear with exogenous, so remove from endog and add to inexog
						local endo1 : list endo1-vn
						local inexog1 "`inexog1' `vn'"
						local ecollin "`ecollin' `vn'"
					}
				}
* Loop through endo1 to find Eigenvalues=0 or 1
			}

* Remove collinearities.  Use _rmcollright to enforce same priority as above.
			capture version 9.2
			if _rc==0 {
* _rmcollright crashes if no arguments supplied
				capture _rmcollright `inexog1' `exexog1' if `touse' `wtexp', `rmcnocons'
			}
			else {
				qui _rmcoll `inexog1' `exexog1' if `touse' `wtexp', `rmcnocons'
			}
			version 8.2

* endo1 has had within-endo collinear removed, so non-colllinear list is _rmcoll result + endo1
			local ncvars `r(varlist)' `endo1'
			local allvars1 `endo1' `inexog1' `exexog1'
* collin gets collinear variables to be removed
			local collin  : list allvars1-ncvars
* Remove collin from exexog1
			local exexog1 : list exexog1-collin
* Remove collin from inexog1
			local inexog1 : list inexog1-collin		

* Collinearity and duplicates warning messages, if necessary
			if "`dups'" != "" {
di in gr "Warning - duplicate variables detected"
di in gr "Duplicates:" _c
				Disp `dups', _col(21)
			}
			if "`ecollin'" != "" {
di in gr "Warning - endogenous variable(s) collinear with instruments"
di in gr "Vars now exogenous:" _c
				Disp `ecollin', _col(21)
			}
			if "`collin'" != "" {
di in gr "Warning - collinearities detected"
di in gr "Vars dropped:" _c
				Disp `collin', _col(21)
			}
		}

**** End of collinearities block ************

**** Partial-out FWL block ******************

		if "`fwl'" != "" {
			preserve
			local fwl : subinstr local fwl "_cons" "", all count(local fwlcons)
			if `fwlcons' > 0 & "`noconstant'"~="" {
di in r "Error: _cons listed in fwl() but equation specifies -noconstant-." 
				error 198
			}
			else if "`noconstant'"~="" {
				local fwlcons 0
			}
			else {
* Just in case of multiple _cons
				local fwlcons 1
			}
			local fwldrop   : list inexog - inexog1
			local fwl1      : list fwl - fwldrop
			local fwlcheck  : list fwl1 - inexog1
			if ("`fwlcheck'"~="") {
di in r "Error: `fwlcheck' listed in fwl() but not in list of regressors." 
				error 198
			}
			local inexog1   : list inexog1 - fwl1
			if "`cluster'"~="" {
* Check that cluster var won't be transformed
				local allvars "`lhs' `inexog' `endo' `exexog'"
				local clustvarcheck : list cluster in allvars
				if `clustvarcheck' {
di in r "Error: cannot use cluster variable `cluster' as dependent variable, regressor or IV"
di in r "       in combination with -fwl- option." 
				error 198
				}
			}
* Constant is partialled out, unless nocons already specified in the first place
			tempname fwl_resid
			foreach var of varlist `lhs' `inexog1' `endo1' `exexog1' {
				qui regress `var' `fwl1' if `touse' `wtexp', `noconstant'
				qui predict double `fwl_resid' if `touse', resid
				qui replace `var' = `fwl_resid'
				drop `fwl_resid'
			}
			local fwl_ct    : word count `fwl1'
			if "`noconstant'" == "" {
* fwl_ct used for small-sample adjustment to regression F-stat
				local fwl_ct = `fwl_ct' + 1
				local noconstant "noconstant"
			}
		}
		else {
* Set count of fwl vars to zero if option not used
			local fwl_ct 0
		}

*********************************************

		local insts1 `inexog1' `exexog1'
		local rhs1   `endo1'   `inexog1'
		local iv1_ct       : word count `insts1'
		local rhs1_ct      : word count `rhs1'
		local endo1_ct     : word count `endo1'
		local exex1_ct     : word count `exexog1'
		local endoexex1_ct : word count `endo1' `exexog1'
		local inexog1_ct   : word count `inexog1'

		if "`noconstant'" == "" {
			local cons_ct 1
		}
		else {
			local cons_ct 0
		}

		if `rhs1_ct' > `iv1_ct' {
			di in red "equation not identified; must have at " /*
			*/ "least as many instruments not in"
			di in red "the regression as there are "           /*
			*/ "instrumented variables"
			exit 481
		}

		if `rhs1_ct' + `cons_ct' == 0 {
			di in red "error: no regressors specified"
			exit 102
		}

		if "`cluster'"!="" {
			local clopt "cluster(`cluster')"
			if "`robust'"=="" {
				local robust "robust"
			}
		}
		if "`bw'"!="" {
			local bwopt "bw(`bw')"
		}
		if "`kernel'"!="" {
			local kernopt "kernel(`kernel')"
		}
* If depname not provided (default) name is lhs variable
		if "`depname'"=="" {
			local depname `lhs'
		}

************************************************************************************************
* Cross-products and basic IV coeffs, residuals and moment conditions
		tempvar iota y2 yhat ivresid ivresid2 gresid gresid2 lresid lresid2 b0resid b0resid2 s1resid
		tempname Nprec ysum yy yyc r2u r2c B V ivB gmmB wB lB gmmV ivest
		tempname r2 r2_a ivrss lrss wbrss b0rss rss mss rmse sigmasq iv_s2 l_s2 wb_s2 b0_s2 F Fp Fdf2
		tempname S Sinv W s1Zu s2Zu b0Zu wbZu wbresid wbresid2 s1sigmasq
		tempname A XZ XZa XZb Zy ZZ ZZinv XPZX XPZXinv XPZy
		tempname YY Z2Z2 ZY Z2Y XXa XXb XX Xy Z2Z2inv XXinv
		tempname XZWZX XZWZXinv XZWZy XZW
		tempname B V B1 uZSinvZu j jp arubin arubinp tempmat

* Generate cross-products of y, X, Z
		qui matrix accum `A' = `lhs' `endo1' `exexog1' `inexog1' /*
			*/ if `touse' `wtexp', `noconstant'
		if "`noconstant'"=="" {
			matrix rownames `A' = `lhs' `endo1' `exexog1' /*
				*/ `inexog1' _cons
			matrix colnames `A' = `lhs' `endo1' `exexog1' /*
				*/ `inexog1' _cons
		}
		else {
			matrix rownames `A' = `lhs' `endo1' `exexog1' `inexog1'
			matrix colnames `A' = `lhs' `endo1' `exexog1' `inexog1'
		}
		if `endo1_ct' > 0 {
* X'Z is [endo1 inexog1]'[exexog1 inexog1]
			mat `XZ'=`A'[2..`endo1_ct'+1,`endo1_ct'+2...]
* Append portion corresponding to included exog if they (incl constant) exist
			if 2+`endo1_ct'+`iv1_ct'-(`rhs1_ct'-`endo1_ct') /*
					*/ <= rowsof(`A') {
				mat `XZ'=`XZ' \ /*
					*/ `A'[2+`endo1_ct'+`iv1_ct'- /*
					*/ (`rhs1_ct'-`endo1_ct')..., /*
					*/ `endo1_ct'+2...]
			}
* If included exog (incl const) exist, create XX matrix in 3 steps
			if `inexog1_ct' + `cons_ct' > 0 {
				mat `XXa'  = `A'[2..`endo1_ct'+1, 2..`endo1_ct'+1], /*
					*/ `A'[2..`endo1_ct'+1, `endoexex1_ct'+2...]
				mat `XXb'  = `A'[`endoexex1_ct'+2..., 2..`endo1_ct'+1], /*
					*/ `A'[`endoexex1_ct'+2..., `endoexex1_ct'+2...]
				mat `XX'   = `XXa' \ `XXb'
				mat `Xy'  = `A'[2..`endo1_ct'+1, 1] \ `A'[`endoexex1_ct'+2..., 1]
			}
			else {
				mat `XX'   = `A'[2..`endo1_ct'+1, 2..`endo1_ct'+1]
				mat `Xy'  = `A'[2..`endo1_ct'+1, 1]
			}
		}
		else {
* Cragg HOLS estimator with no endogenous variables
			mat `XZ'= `A'[2+`iv1_ct'-(`rhs1_ct'-`endo1_ct')..., /*
					*/ 2...]
			mat `XX'   = `A'[`endoexex1_ct'+2..., `endoexex1_ct'+2...]
			mat `Xy'  = `A'[`endoexex1_ct'+2..., 1]
		}

		mat `XX'=(`XX'+`XX'')/2
		mat `XXinv'=syminv(`XX')
		mat `Zy'=`A'[`endo1_ct'+2...,1]
		mat `ZZ'=`A'[`endo1_ct'+2...,`endo1_ct'+2...]
		mat `ZZ'=(`ZZ'+`ZZ'')/2
		mat `ZZinv'=syminv(`ZZ')
* diag0cnt probably superfluous since collinearity checks will catch this unless disabled
		local iv_ct = rowsof(`ZZ') - diag0cnt(`ZZinv')
		mat `YY'=`A'[1..`endo1_ct'+1, 1..`endo1_ct'+1]
		mat `ZY' = `A'[`endo1_ct'+2..., 1..`endo1_ct'+1]
		mat `XPZX'=`XZ'*`ZZinv'*`XZ''
		mat `XPZX'=(`XPZX'+`XPZX'')/2
		mat `XPZXinv'=syminv(`XPZX')
		mat `XPZy'=`XZ'*`ZZinv'*`Zy'
******************************
		qui gen byte `iota'=1
		qui gen double `y2'=`lhs'^2
* Stata summarize won't work with iweights, so must use matrix cross-product
		qui matrix vecaccum `ysum' = `iota' `y2' `lhs' `wtexp' if `touse'
* Nprec is ob count from mat accum.  Use this rather than `N' in calculations
* here and below because in official -regress- `N' is rounded if iweights are used.
		scalar `Nprec'=`ysum'[1,3]
		if "`weight'" == "iweight" {
			scalar `Nprec'=round(`Nprec')
		}
		local N=round(`Nprec')
		scalar `yy'=`ysum'[1,1]
		scalar `yyc'=`yy'-`ysum'[1,2]^2/`Nprec'

*******************************************************************************************
* First-step estimators: b0, wmatrix, LIML-kclass, IV.
* Generate residuals s1resid for used in 2SFEGMM and robust.
* User-supplied b0 provides value of CUE obj fn.
		if "`b0'" != "" {
			capture drop `yhat'
			qui mat score double `yhat' = `b0' if `touse'
			qui gen double `b0resid'=`lhs'-`yhat'
			qui gen double `b0resid2'=`b0resid'^2
			capture drop `ysum'
			qui matrix vecaccum `ysum' = `iota' `b0resid2' /*
				*/ `wtexp' if `touse', `noconstant'
			scalar `b0rss'= `ysum'[1,1]
* Adjust sigma-squared for dofminus
			scalar `b0_s2'=`b0rss'/(`Nprec'-`dofminus')
			scalar `s1sigmasq'=`b0_s2'
			qui gen double `s1resid'=`b0resid'
		}
		else if "`wmatrix'" != "" {
* GMM with arbitrary weighting matrix provides first-step estimates
			local cn : colnames(`ZZ')
			matrix `W'=`wmatrix'
* Rearrange/select columns to mat IV matrix
			capture matsort `W' "`cn'"
			local wrows = rowsof(`W')
			local wcols = colsof(`W')
			local zcols = colsof(`ZZ')
			if _rc ~= 0 | (`wrows'~=`zcols') | (`wcols'~=`zcols') {
di as err "-wmatrix- option error: supplied matrix columns/rows do not match IV list"
exit 198
			}
			mat `XZWZX'=`XZ'*`W'*`XZ''
			mat `XZWZy'=`XZ'*`W'*`Zy'
			mat `XZWZX'=(`XZWZX'+`XZWZX'')/2
			mat `XZWZXinv'=syminv(`XZWZX')
			mat `XZW'=`XZ'*`W'
			mat `wB'=`XZWZy''*`XZWZXinv''

			capture drop `yhat'
			qui mat score double `yhat' = `wB' if `touse'
			qui gen double `wbresid'=`lhs'-`yhat'
			qui gen double `wbresid2'=`wbresid'^2
			capture drop `ysum'
			qui matrix vecaccum `ysum' = `iota' `wbresid2' /*
				*/ `wtexp' if `touse', `noconstant'
			scalar `wbrss'= `ysum'[1,1]
* Adjust sigma-squared for dofminus
			scalar `wb_s2'=`wbrss'/(`Nprec'-`dofminus')
			scalar `s1sigmasq'=`wb_s2'
			qui gen double `s1resid'=`wbresid'
		}
		else if "`liml'`kclass'" != "" {
* LIML and kclass code
			tempname WW WW1 Evec Eval Evaldiag target lambda lambda2 khs XhXh XhXhinv ll
			if "`kclass'" == "" {
* LIML block
				matrix `WW'  = `YY' - `ZY''*`ZZinv'*`ZY'
				if `inexog1_ct' + `cons_ct' > 0 {
					mat `Z2Y'  = `A'[`endoexex1_ct'+2..., 1..`endo1_ct'+1]
					mat `Z2Z2' = `A'[`endoexex1_ct'+2..., `endoexex1_ct'+2...]
					mat `Z2Z2'=(`Z2Z2'+`Z2Z2'')/2
					mat `Z2Z2inv' = syminv(`Z2Z2')
					matrix `WW1' = `YY' - `Z2Y''*`Z2Z2inv'*`Z2Y'
				}
				else {
* Special case of no included exogenous (incl constant)
					matrix `WW1' = `YY'
				}
				matrix `WW'=(`WW'+`WW'')/2
				matrix symeigen `Evec' `Eval' = `WW'
				matrix `Evaldiag' = diag(`Eval')
* Replace diagonal elements of Evaldiag with the element raised to the power (-1/2)
				local i 1
				while `i' <= rowsof(`Evaldiag') {
* Need to use capture because with collinearities, diag may be virtually zero
* ... but actually negative
					capture matrix `Evaldiag'[`i',`i'] = /*
						*/ `Evaldiag'[`i',`i']^(-0.5)
					local i = `i'+1
				}
				matrix `target' = (`Evec'*`Evaldiag'*`Evec'') * `WW1' /*
					*/ * (`Evec'*`Evaldiag'*`Evec'')
* Re-use macro names
				matrix `target'=(`target'+`target'')/2
				matrix symeigen `Evec' `Eval' = `target'
* Get smallest eigenvalue
* Note that collinearities can yield a nonsense eigenvalue appx = 0
* and just-identified will yield an eigenvalue that is ALMOST exactly = 1
* so require it to be >= 0.9999999999.
				local i 1
				scalar `lambda'=.
				scalar `lambda2'=.
				while `i' <= colsof(`Eval') {
					if (`lambda' > `Eval'[1,`i']) & (`Eval'[1,`i'] >=0.9999999999) {
						scalar `lambda2' = `lambda'
						scalar `lambda' = `Eval'[1,`i']
					}
					local i = `i'+1
				}
				if `fuller'==0 {
* Basic LIML.  Macro kclass2 is the scalar.
					scalar `kclass2'=`lambda'
				}
				else {
* Fuller LIML
					if `fuller' > (`N'-`iv_ct') {
di as err "error: invalid choice of Fuller LIML parameter"
						exit 198
					}
					scalar `kclass2' = `lambda' - `fuller'/(`N'-`iv_ct')
				}
* End of LIML block
			}
			mat `XhXh'=(1-`kclass2')*`XX'+`kclass2'*`XPZX'
			mat `XhXh'=(`XhXh'+`XhXh'')/2
			mat `XhXhinv'=syminv(`XhXh')
			mat `lB'=`Xy''*`XhXhinv'*(1-`kclass2') + `kclass2'*`Zy''*`ZZinv'*`XZ''*`XhXhinv'
			capture drop `yhat'
			qui mat score double `yhat'=`lB' if `touse'
			qui gen double `lresid'=`lhs' - `yhat'
			qui gen double `lresid2'=`lresid'^2
			capture drop `ysum'
			qui matrix vecaccum `ysum' = `iota' `lresid2' /*
				*/ `wtexp' if `touse', `noconstant'
			scalar `lrss'= `ysum'[1,1]
* Adjust sigma-squared for dofminus
			scalar `l_s2'=`lrss'/(`Nprec'-`dofminus')
			scalar `s1sigmasq'=`l_s2'
			qui gen double `s1resid'=`lresid'
		}
		else {
* IV resids are 1st-step GMM resids
* In these expressions, ignore scaling of W
			mat `ivB' = `XPZy''*`XPZXinv''
			mat `XZWZX'=`XPZX'
			mat `XZWZXinv'=`XPZXinv'
			mat `XZW'=`XZ'*`ZZinv'
			capture drop `yhat'
			qui mat score double `yhat' = `ivB' if `touse'
			qui gen double `ivresid'=`lhs'-`yhat'
			qui gen double `ivresid2'=`ivresid'^2
			capture drop `ysum'
			qui matrix vecaccum `ysum' = `iota' `ivresid2' /*
				*/ `wtexp' if `touse', `noconstant'
			scalar `ivrss'=`ysum'[1,1]
			scalar `iv_s2'=`ivrss'/(`Nprec'-`dofminus')
			scalar `s1sigmasq'=`iv_s2'
			qui gen double `s1resid'=`ivresid'
		}
* Orthogonality conditions using step 1 residuals
		qui mat vecaccum `s1Zu'=`s1resid' `exexog1' `inexog1' /*
			*/ `wtexp' if `touse', `noconstant'

*******************************************************************************************
* S covariance matrix of orthogonality conditions
*******************************************************************************************
* If user-supplied S matrix is used, use it
		if "`smatrix'" != "" {
			local cn : colnames(`ZZ')
			matrix `S'=`smatrix'
* Rearrange/select columns to mat IV matrix
			capture matsort `S' "`cn'"
			local srows = rowsof(`S')
			local scols = colsof(`S')
			local zcols = colsof(`ZZ')
			if _rc ~= 0 | (`srows'~=`zcols') | (`scols'~=`zcols') {
di as err "-smatrix- option error: supplied matrix columns/rows do not match IV list"
exit 198
			}
			mat `S' = (`S' + `S'') / 2
			mat `Sinv'=syminv(`S')
			local rankS = rowsof(`Sinv') - diag0cnt(`Sinv')
		}

*******************************************************************************************
* Start robust block for robust-HAC S and Sinv
* Do not enter if user supplies smatrix or if CUE
		if "`robust'`cluster'" != "" & "`cue'"=="" & "`smatrix'"=="" {
* Optimal weighting matrix
* Block calculates S_0 robust matrix
* _robust has same results as
* mat accum `S'=`exexog1' `inexog1' [iweight=`ivresid'^2] if `touse'
* mat `S' = `S'*1/`Nprec'
* _robust doesn't work properly with TS variables, so must first tsrevar
			tsrevar `exexog1' `inexog1'
			local TSinsts1 `r(varlist)'
* Create identity matrix with matching col/row names
			mat `S'=I(colsof(`s1Zu'))
			if "`noconstant'"=="" {
				mat colnames `S' = `TSinsts1' "_cons"
				mat rownames `S' = `TSinsts1' "_cons"
			}
			else {
				mat colnames `S' = `TSinsts1'
				mat rownames `S' = `TSinsts1'
			}
			_robust `s1resid' `wtexp' if `touse', variance(`S') `clopt' minus(0)
			if "`cluster'"!="" {
				local N_clust=r(N_clust)
			}
			mat `S' = `S'*1/`Nprec'
* Above doesn't work properly with iweights (i.e. yield same matrix as fw),
*   hence iweight trap at start
			if "`kernel'" != "" {
* HAC block for S_1 onwards matrices
				tempvar vt1
				qui gen double `vt1' = .
				tempname tt tx kw karg ow
* Use insts with TS ops removed and with iota (constant) column
				if "`noconstant'"=="" {
					local insts1c "`TSinsts1' `iota'"
				}
				else {
					local insts1c "`TSinsts1'"
				}
				local iv1c_ct   : word count `insts1c'
* "tau=0 loop" is S_0 block above for all robust code
				local tau 1
* Spectral windows require looping through all T-1 autocovariances
				if "`window'" == "spectral" {
					local TAU `T'-1
di in ye "Computing kernel ..."
				}
				else {
					local TAU `bw'
				}
				if "`weight'" == "" {
* If no weights specified, define neutral ow variable and weight expression for code below
					qui gen byte `ow'=1
					local wtexp `"[fweight=`wvar']"'
				}
				else {
* pweights and aweights
					summ `wvar' if `touse', meanonly
					qui gen double `ow' = `wvar'/r(mean)
				}
				while `tau' <= `TAU' {
					capture mat drop `tt' 
					local i 1
					while `i' <= `iv1c_ct' {
						local x : word `i' of `insts1c'
* Add lags defined with TS operators
						local Lx "L`tau'.`x'"
						local Ls1resid "L`tau'.`s1resid'"
						local Low "L`tau'.`ow'"
						qui replace `vt1' = `Lx'*`s1resid'* /*
							*/ `Ls1resid'*`Low'*`ow' if `touse'
* Use capture here because there may be insufficient observations, e.g., if
*   the IVs include lags and tau=N-1.  _rc will be 2000 in this case.
						capture mat vecaccum `tx' = `vt1' `insts1c' /*
							*/ if `touse', nocons
						if _rc == 0 {
							mat `tt' = nullmat(`tt') \ `tx'
						}
						local i = `i'+1
					}
* bw = bandwidth, karg is argument to kernel function, kw is kernel function (weight)
					scalar `karg' = `tau'/(`bw')
					if "`kernel'" == "Truncated" {
						scalar `kw'=1
					}
					if "`kernel'" == "Bartlett" {
						scalar `kw'=(1-`karg')
					}
					if "`kernel'" == "Parzen" {
						if `karg' <= 0.5 {
							scalar `kw' = 1-6*`karg'^2+6*`karg'^3
						}
						else {
							scalar `kw' = 2*(1-`karg')^3
						}
					}
					if "`kernel'" == "Tukey-Hanning" {
						scalar `kw'=0.5+0.5*cos(_pi*`karg')
					}
					if "`kernel'" == "Tukey-Hamming" {
						scalar `kw'=0.54+0.46*cos(_pi*`karg')
					}
					if "`kernel'" == "Tent" {
						scalar `kw'=2*(1-cos(`tau'*`karg')) / (`karg'^2)
					}
					if "`kernel'" == "Daniell" {
						scalar `kw'=sin(_pi*`karg') / (_pi*`karg')
					}
					if "`kernel'" == "Quadratic spectral" {
						scalar `kw'=25/(12*_pi^2*`karg'^2) /*
							*/ * ( sin(6*_pi*`karg'/5)/(6*_pi*`karg'/5) /*
							*/     - cos(6*_pi*`karg'/5) )
					}
* Need -capture-s here because tt may not exist (because of insufficient observations/lags)
					capture mat `tt' = (`tt'+`tt'')*`kw'*1/`Nprec'
					if _rc == 0 {
						mat `S' = `S' + `tt'
					}
					local tau = `tau'+1
				}
				if "`weight'" == "" {
* If no weights specified, remove neutral weight variables
					local wtexp ""
				}
			}
* To give S the right col/row names
			mat `S'=`S'+0*diag(`s1Zu')
* Right approach is to adjust S by N/(N-dofminus) if NOT cluster
* because clustered S is already "adjusted"
			if "`cluster'"=="" {
				mat `S'=`S'*`Nprec'/(`Nprec'-`dofminus')
			}
* Stock-Watson robust SEs.  Requires `wvar' to be defined above.
* Correspondence between S-W (2006) and code below assumes ivreg2 is called on demeaned data.
* Variable ivar identifies the observational unit.
* wvar will simply be 1 for all observations unless weights are used.
* T_i is number of observations for an observational unit, extended to unbalanced data.
*   SW consider only balanced data and denote this as T (constant acros units).
* s1resid is (fixed effects) residuals.  SW denote this as u_tilda_hat (p. 2, eqn 4).
* s2 is, for an observational unit i, 1/(T-1) * sum of squared (fixed effects) residuals.
* This is the second term in () in the expression for B_hat in SW eqn 6, p. 3.
* mat opaccum calculates a cross-prod of the form  A = X1'e1e1'X1 + X2'e2e2'X2 + ... + Xk'ekek'Xk
* ei is s from above.  eiei' is a T_i x T_i matrix filled with s_i2s.  Thus the cross-prod becomes
* A = s_1^2*X1'X1 + s_2^2*X2'e2e2'X2 + ... + s_k^2*Xk'Xk
* which is the form of B_hat in SW eqn 6 p. 3, except for the missing 1/N and 1/T
* In unbalanced case, 1/T isn't constant, so must incorporate the 1/T that weights the Xi'Xi into the s,
*   hence the second division of s2 by T_i.
* S is SW's Sigma_hat_HR-FE, which is the fixed effects S (=Sigma_hat_HR-XS) minus 1/(T-1)*B)hat
* and then multiplied by (T-1)/(T-2).  In SW, T is constant because they cover only the balanced case.
* Here, T varies across units, so we use the harmonic mean of T for T_bar.
* PSD code by CFB based on SW point 10 on p. 6.  Guarantees S will be PSD.
			if "`sw'`swpsd'" ~= "" {
				tempname B s s2 T_i T_inv T_bar s1resid2
				qui gen double `s1resid2'=`s1resid'^2
				sort `ivar' `touse'
				qui by `ivar' `touse': gen long `T_i' = sum(`wvar') if `touse'
				qui by `ivar' `touse': replace  `T_i' = `T_i'[_N] if `touse' & _n<_N
				qui gen `T_inv' = 1/`T_i'
				sum `T_inv' if `touse', meanonly
				scalar `T_bar' = 1/r(mean)
				qui by `ivar' `touse': gen double `s2'=sum(`s1resid2'*`wvar') if `touse'
				qui by `ivar' `touse': replace    `s2'=`s2'[_N] if `touse' & _n<_N
				qui replace `s2' = `s2'/(`T_i'-1)
				qui replace `s2' = `s2'/`T_i'
				qui gen double `s' = sqrt(`s2')
				qui mat opaccum `B'=`exexog1' `inexog1' `wtexp' if `touse', /*
					*/	group(`ivar') opvar(`s') `noconstant'
				mat `B' = `B' * 1/`Nprec'
				mat `S' = (`T_bar'-1)/(`T_bar'-2)*(`S' - `B'*1/(`T_bar'-1))
				if "`swpsd'" ~= "" {
					mat `S'=(`S'+`S'')/2
					tempname X v
					mat symeigen `X' `v' = `S'
					local ncol = colsof(`S')
					forv i=1/`ncol' {
						mat `v'[1,`i']= abs(`v'[1,`i'])
					}
					mat `S' = `X' * diag(`v') * `X''
				}
			}
			mat `S'=(`S'+`S'')/2
			mat `Sinv'=syminv(`S')
			local rankS = rowsof(`Sinv') - diag0cnt(`Sinv')
		}

* End robust-HAC S and Sinv block
************************************************************************************
* Block for non-robust S and Sinv, including autocorrelation-consistent (AC).
* Do not enter if user supplies smatrix or if cue

		if "`robust'`cluster'`cue'`smatrix'"=="" {
* First do with S_0 (=S for simple IV)
* Step 1 sigma^2 is IV sigma^2 unless b0 or wmatrix provided
			mat `S' = `s1sigmasq'*`ZZ'*(1/`Nprec')

			if "`kernel'" != "" {
* AC code for S_1 onwards matrices
				tempvar vt1
				qui gen double `vt1' = .
				tempname tt tx kw karg ow sigttj
* Use insts with TS ops removed and with iota (constant) column
				tsrevar `exexog1' `inexog1'
				local TSinsts1 `r(varlist)'
				if "`noconstant'"=="" {
					local insts1c "`TSinsts1' `iota'"
				}
				else {
					local insts1c "`TSinsts1'"
				}
				local iv1c_ct   : word count `insts1c'
* "tau=0 loop" is S_0 block above
				local tau 1
* Spectral windows require looping through all T-1 autocovariances
				if "`window'" == "spectral" {
					local TAU `T'-1
di in ye "Computing kernel ..."
				}
				else {
					local TAU `bw'
				}
				if "`weight'" == "" {
* If no weights specified, define neutral ow variable and wtexp for code below
					qui gen byte `ow'=1
					local wtexp `"[fweight=`wvar']"'
				}
				else {
* pweights and aweights
					summ `wvar' if `touse', meanonly
					qui gen double `ow' = `wvar'/r(mean)
				}
				while `tau' <= `TAU' {
					capture mat drop `tt' 
					local i 1
* errflag signals problems that make this loop's tt invalid
					local errflag 0
* Additional marksample/markout required so that treatment of MVs is consistent across all IVs
					marksample touse2
					markout `touse2' `insts1c' L`tau'.(`insts1c')
					local Low "L`tau'.`ow'"
					while `i' <= `iv1c_ct' {
						local x : word `i' of `insts1c'
* Add lags defined with TS operators
						local Lx "L`tau'.`x'"
						qui replace `vt1'=.
						qui replace `vt1' = `Lx'*`Low'*`ow' if `touse' & `touse2'
* Use capture here because there may be insufficient observations, e.g., if
*   the IVs include lags and tau=N-1.  _rc will be 2000 in this case.
						capture mat vecaccum `tx' = `vt1' `insts1c' /*
							*/ if `touse', nocons
						if _rc == 0 {
							mat `tt' = nullmat(`tt') \ `tx'
						}
						local i = `i'+1
					}
					capture mat `tt' = 1/`Nprec' * `tt'
					if _rc != 0 {
						local errflag = 1
					}
					local Ls1resid "L`tau'.`s1resid'"
* Weights belong here as well
					tempvar ivLiv
					qui gen double `ivLiv' = `s1resid'*`Ls1resid'*`ow'*`Low' if `touse'
					qui sum `ivLiv' if `touse', meanonly
					scalar `sigttj' = r(sum)/`Nprec'

					capture mat `tt' = `sigttj' * `tt'
* bw = bandwidth, karg is argument to kernel function, kw is kernel function (weight)
					scalar `karg' = `tau'/(`bw')
					if "`kernel'" == "Truncated" {
						scalar `kw'=1
					}
					if "`kernel'" == "Bartlett" {
						scalar `kw'=(1-`karg')
					}
					if "`kernel'" == "Parzen" {
						if `karg' <= 0.5 {
							scalar `kw' = 1-6*`karg'^2+6*`karg'^3
						}
						else {
							scalar `kw' = 2*(1-`karg')^3
						}
					}
					if "`kernel'" == "Tukey-Hanning" {
						scalar `kw'=0.5+0.5*cos(_pi*`karg')
					}
					if "`kernel'" == "Tukey-Hamming" {
						scalar `kw'=0.54+0.46*cos(_pi*`karg')
					}
					if "`kernel'" == "Tent" {
						scalar `kw'=2*(1-cos(`tau'*`karg')) / (`karg'^2)
					}
					if "`kernel'" == "Daniell" {
						scalar `kw'=sin(_pi*`karg') / (_pi*`karg')
					}
					if "`kernel'" == "Quadratic spectral" {
						scalar `kw'=25/(12*_pi^2*`karg'^2) /*
							*/ * ( sin(6*_pi*`karg'/5)/(6*_pi*`karg'/5) /*
							*/     - cos(6*_pi*`karg'/5) )
					}

* Need -capture-s here because tt may not exist (because of insufficient observations/lags)
					capture mat `tt' = (`tt'+`tt'')*`kw'
					if _rc != 0 {
						local errflag = 1
					}
* Accumulate if tt is valid
					if `errflag' == 0 {
						capture mat `S' = `S' + `tt'
					}
					local tau = `tau'+1
				}
				if "`weight'" == "" {
* If no weights specified, remove neutral weight variables
					local wtexp ""
				}
			}
* End of AC code
* To give S the right col/row names
			mat `S'=`S'+0*diag(`s1Zu')
			mat `S'=(`S'+`S'')/2
			mat `Sinv'=syminv(`S')
			local rankS = rowsof(`Sinv') - diag0cnt(`Sinv')
		}

* End of non-robust S and Sinv code (including AC)
*******************************************************************************************
* 2nd step and final coefficients
*******************************************************************************************
* User-supplied b0.  CUE objective function.
		if "`b0'" ~= "" {
			mat `B' = `b0'
			scalar `rss'=`b0rss'
			scalar `sigmasq'=`b0_s2'
			mat `W' = `Sinv'
		}
*******************************************************************************************
* Block for gmm 2nd step to get coefficients and 2nd step residuals

* Non-robust IV, LIML, k-class, CUE do not enter
		if "`gmm'`robust'`cluster'`kernel'`wmatrix'" != "" & "`cue'"==""  & "`ewmatrix'"=="" {
			mat `tempmat'=`XZ'*`Sinv'*`XZ''
			mat `tempmat'=(`tempmat'+`tempmat'')/2
			mat `B1'=syminv(`tempmat')
			mat `B1'=(`B1'+`B1'')/2
			mat `gmmB'=(`B1'*`XZ'*`Sinv'*`Zy')'
			
			capture drop `yhat'
			qui mat score double `yhat'=`gmmB' if `touse'
			qui gen double `gresid'=`lhs'-`yhat'
			qui gen double `gresid2'=`gresid'^2
			qui mat vecaccum `s2Zu'=`gresid' `exexog1' `inexog1' /*
				*/ `wtexp' if `touse', `noconstant'
		}
*******************************************************************************************
* GMM with arbitrary weighting matrix
		if ("`wmatrix'"~="") & ("`gmm'"=="") & ("`liml'`kclass'`cue'"=="") & "`b0'"=="" {
			mat `B'=`wB'
			scalar `rss'=`wbrss'
			scalar `sigmasq'=`wb_s2'
* Weighting matrix wmatrix already checked and assigned to macro W
		}
*******************************************************************************************
* IV coefficients
		if ("`wmatrix'"=="") & ("`gmm'"=="") & ("`liml'`kclass'`cue'"=="") & "`b0'"=="" {
			mat `B'=`ivB'
			scalar `rss'=`ivrss'
			scalar `sigmasq'=`iv_s2'
* IV weighting matrix.  By convention, no small-sample adjustment (consistent with S)
			mat `W' = `ZZinv'*(`Nprec'-`dofminus')/`iv_s2'
		}
*******************************************************************************************
* LIML, k-class coefficients
		if "`liml'`kclass'" ~= "" {
			mat `B'=`lB'
			scalar `rss'=`lrss'
			scalar `sigmasq'=`l_s2'
* No weighting matrix.
		}
*******************************************************************************************
* Efficient GMM coefficients
		if "`gmm'"!=""  & ("`liml'`kclass'`cue'"=="") & "`b0'"=="" {
			mat `B'=`gmmB'
			capture drop `ysum'
			qui matrix vecaccum `ysum' = `iota' `gresid2' /*
				*/ `wtexp' if `touse', `noconstant'
			scalar `rss'= `ysum'[1,1]
* Adjust sigma-squared for dofminus
			scalar `sigmasq'=`rss'/(`Nprec'-`dofminus')
			mat `W'=`Sinv'
		}
*******************************************************************************************
* Var-cov matrix
*******************************************************************************************
* Expressions below multipy by N because we are working with cross-products (XZ) not vcvs (Qxz)
* Efficient GMM: homoskedastic IV, 2-step FEGMM.  LIML, k-class, CUE handled separately.
* No robust, cluster, kernel => must be efficient GMM
* GMM option => must be efficient GMM
* b0 => must be efficient GMM
* ewmatrix => must be efficient GMM
		tempname rankV
		if ("`robust'`cluster'`kernel'`liml'`kclass'`cue'`wmatrix'"=="")	/*
				*/	| ("`gmm'"~="")					/*
				*/	| ("`b0'"~="")					/*
				*/	| ("`ewmatrix'"~="")		{
			mat `tempmat'=`XZ'*`Sinv'*`XZ''
			mat `tempmat'=(`tempmat'+`tempmat'')/2
			mat `V' = syminv(`tempmat')*`Nprec'
			mat `V'=(`V'+`V'')/2
			scalar `rankV'=rowsof(`tempmat') - diag0cnt(`tempmat')
		}
* Possibly inefficient GMM: robust of all sorts with no 2nd step.  LIML, k-class, CUE handled separately.
		else if ("`liml'`kclass'`cue'"=="") {
			mat `V'=`XZWZXinv'*`XZW'*`S'*  /*
				*/ `XZW''*`XZWZXinv'*`Nprec'
			mat `V'=(`V'+`V'')/2
			mat `tempmat'=syminv(`V')
			scalar `rankV'=rowsof(`tempmat') - diag0cnt(`tempmat')
		}
* LIML and k-class non-robust
		else if ("`liml'`kclass'" ~= "") & ("`robust'`cluster'" == "") {
			if "`coviv'"== "" {
* LIML or k-class cov matrix
				mat `V'=`sigmasq'*`XhXhinv'
				scalar `rankV'=rowsof(`XhXh') - diag0cnt(`XhXh')
			}
			else {
* IV cov matrix
				mat `V'=`sigmasq'*`XPZXinv'
				scalar `rankV'=rowsof(`XPZXinv') - diag0cnt(`XPZXinv')
			}
			mat `V'=(`V'+`V'')/2
		}
* LIML and k-class robust
		else if ("`liml'`kclass'" ~= "") & ("`robust'`cluster'" ~= "") {
			if "`coviv'"== "" {
* Use LIML or k-class cov matrix
				mat `V'=`XhXhinv'*`XZ'*`ZZinv'*`S'*`Nprec'*  /*
					*/ `ZZinv'*`XZ''*`XhXhinv'
			}
			else {
* Use IV cov matrix
				mat `V'=`XPZXinv'*`XZ'*`ZZinv'*`S'*`Nprec'*  /*
					*/ `ZZinv'*`XZ''*`XPZXinv'
			}
			mat `V'=(`V'+`V'')/2
			mat `tempmat'=syminv(`V')
			scalar `rankV'=rowsof(`tempmat') - diag0cnt(`tempmat')
		}
* Model df handled here since it depends on rank of V
* CUE handled separately
		if "`cue'"=="" {
			if "`noconstant'"=="" {
				local df_m = `rankV' - 1
			}
			else {
				local df_m = `rankV'
			}
		}
* End of VCV block
********************************************************************************
* Sargan-Hansen-Anderson-Rubin statistics
*******************************************************************************************
* Robust requires using gmm residuals; otherwise use iv residuals. CUE handled separately.
* b0 => return value of CUE objective function.  b0 is efficient GMM.
		if ("`robust'`cluster'`kernel'" == "")	& ("`cue'"=="") & ("`b0'`ewmatrix'"=="") {
			mat `uZSinvZu'= (`s1Zu'/`Nprec')*`Sinv'*(`s1Zu''/`Nprec')
			scalar `j' = `Nprec'*`uZSinvZu'[1,1]
		}
		if ("`robust'`cluster'`kernel'" ~= "")	& ("`cue'"=="") & ("`b0'`ewmatrix'"=="") {
			mat `uZSinvZu'= (`s2Zu'/`Nprec')*`Sinv'*(`s2Zu''/`Nprec')
			scalar `j' = `Nprec'*`uZSinvZu'[1,1]
		}
		if "`b0'`ewmatrix'"~="" {
			mat `uZSinvZu'= (`s1Zu'/`Nprec')*`Sinv'*(`s1Zu''/`Nprec')
			scalar `j' = `Nprec'*`uZSinvZu'[1,1]
		}
		if "`liml'" != "" {
* Also save Anderson-Rubin overid stat if LIML
* Note dofminus is required because unlike Sargan and 2-step GMM J, doesn't derive from S
			scalar `arubin'=(`Nprec'-`dofminus')*ln(`lambda')
		}

***************************************************************************************
* Block for cue gmm
*******************************************************************************************
		if "`cue'" != "" {
* Set up variables and options as globals
			global IV_lhs "`lhs'"
			global IV_inexog "`inexog1'"
			global IV_endog "`endo1'"
			global IV_exexog "`exexog1'"
			global IV_wt "`wtexp'"
			global IV_opt "`noconstant' `robust' `clopt' `bwopt' `kernopt' `dofmopt'"
* `gmm' not in IV_opt because cue+gmm not allowed
* Initial values use 2-step GMM if robust
			if "`robust'`cluster'"~="" {
				local init_opt "gmm"
			}
			tempname b_init temphold
			capture _estimates hold `temphold', restore
			if _rc==1000 {
di as err "ivreg2 internal error - no room to save temporary estimation results"
di as err "Please drop one or more estimation results using -estimates drop-"
				exit 1000
			}
			qui `ivreg2_cmd' $IV_lhs $IV_inexog ($IV_endog=$IV_exexog) $IV_wt /*
				*/ if `touse', $IV_opt `init_opt' noid
* Trap here if just-identified
			if e(rankzz)>e(rankxx) {
				if "`cueinit'"== "" {
					mat `b_init'=e(b)
				}
				else {
					mat `b_init'=`cueinit'
				}
* Use ML for numerical optimization
				ml model d0 `ivreg2_cmd'_cue ($IV_lhs = $IV_endog $IV_inexog, `noconstant') $IV_wt /*
					*/ if `touse', maximize init(`b_init') `cueoptions' /*
					*/ crittype(neg GMM obj function -J) /*
					*/ collinear nooutput nopreserve missing noscvars
			}
			else {
di in ye "Equation exactly-identified: CUE and 2-step GMM coincide"
			}
* Remove equation number from column names
			mat `B'=e(b)
			mat colnames `B' = _:
* Last call to get vcv, j, Sinv etc.
			qui `ivreg2_cmd' $IV_lhs $IV_inexog ($IV_endog=$IV_exexog) $IV_wt /*
				*/ if `touse', $IV_opt b0(`B') noid
* Save all results
			mat `V'=e(V)
			mat `S'=e(S)
			mat `Sinv'=syminv(`S')
			mat `W'=`Sinv'

			local rankS = e(rankS)
			scalar `j'=e(j)
			local df_m = e(df_m)
			scalar `rankV'=e(rankV)

			if "`cluster'" != "" {
				local N_clust=e(N_clust)
			}
			capture drop `yhat'
			qui mat score double `yhat'=`B' if `touse'
			qui gen double `gresid'=`lhs'-`yhat'
			qui gen double `gresid2'=`gresid'^2
			capture drop `ysum'
			qui matrix vecaccum `ysum' = `iota' `gresid2' /*
				*/ `wtexp' if `touse', `noconstant'
			scalar `rss'= `ysum'[1,1]
* Adjust sigma-squared for dofminus
			scalar `sigmasq'=`rss'/(`Nprec'-`dofminus')

			macro drop IV_lhs IV_inexog IV_endog IV_exexog IV_wt IV_opt
			capture _estimates unhold `temphold'
		}

*******************************************************************************************
* RSS, counts, dofs, F-stat, small-sample corrections
*******************************************************************************************
		scalar `rmse'=sqrt(`sigmasq')
		if "`noconstant'"=="" {
			scalar `mss'=`yyc' - `rss'
		}
		else {
			scalar `mss'=`yy' - `rss'
		}

* Counts modified to include constant if appropriate
		if "`noconstant'"=="" {
			local iv1_ct  = `iv1_ct' + 1
			local rhs1_ct = `rhs1_ct' + 1
		}
* Correct count of rhs variables accounting for dropped collinear vars
* Count includes constant

		local rhs_ct = rowsof(`XX') - diag0cnt(`XXinv')

		if "`cluster'"=="" {
* Residual dof adjusted for dofminus
			local df_r = `N' - `rhs_ct' - `dofminus'
		}
		else {
* To match Stata, subtract 1 (why 1 and not `rhs_ct' is a mystery)
			local df_r = `N_clust' - 1
		}

* Sargan-Hansen J dof and p-value
* df=0 doesn't guarantee j=0 since can be call to get value of CUE obj fn
		local jdf = `iv_ct' - `rhs_ct'
		if `jdf' == 0 & "`b0'"=="" {
			scalar `j' = 0
		}
		else {
			scalar `jp' = chiprob(`jdf',`j')
		}
		if "`liml'"~="" {
			scalar `arubinp' = chiprob(`jdf',`arubin')
		}

* Small sample corrections for var-cov matrix.
* If robust, the finite sample correction is N/(N-K), and with no small
* we change this to 1 (a la Davidson & MacKinnon 1993, p. 554, HC0).
* If cluster, the finite sample correction is (N-1)/(N-K)*M/(M-1), and with no small
* we change this to 1 (a la Wooldridge 2002, p. 193), where M=number of clusters.
* In the adj of the V matrix for non-small, we use Nprec instead of N because
* iweights rounds off N.  Note that iweights are not allowed with robust
* but we use Nprec anyway to maintain consistency of code.

		if "`small'" != "" {
			if "`cluster'"=="" {
				matrix `V'=`V'*(`Nprec'-`dofminus')/(`Nprec'-`rhs_ct'-`dofminus')
			}
			else {
				matrix `V'=`V'*(`Nprec'-1)/(`Nprec'-`rhs_ct') /*
					*/		* `N_clust'/(`N_clust'-1)
			}
			scalar `sigmasq'=`rss'/(`Nprec'-`rhs_ct'-`dofminus')
			scalar `rmse'=sqrt(`sigmasq')
		}

		scalar `r2u'=1-`rss'/`yy'
		scalar `r2c'=1-`rss'/`yyc'
		if "`noconstant'"=="" {
			scalar `r2'=`r2c'
			scalar `r2_a'=1-(1-`r2')*(`Nprec'-1)/(`Nprec'-`rhs_ct'-`dofminus')
		}
		else {
			scalar `r2'=`r2u'
			scalar `r2_a'=1-(1-`r2')*`Nprec'/(`Nprec'-`rhs_ct'-`dofminus')
		}

* Fstat
* To get it to match Stata's, must post separately with dofs and then do F stat by hand
*   in case weights generate non-integer obs and dofs
* Create copies so they can be posted
		tempname FB FV
		mat `FB'=`B'
		mat `FV'=`V'
		capture ereturn post `FB' `FV'
* If the cov matrix wasn't positive definite, the post fails with error code 506
		local rc = _rc
		if `rc' != 506 {
			local Frhs1 `rhs1'
			capture test `Frhs1'
			if "`small'" == "" {
				if "`cluster'"=="" {
					capture scalar `F' = r(chi2)/`df_m' * `df_r'/(`Nprec'-`dofminus')
				}
				else {
					capture scalar `F' = r(chi2)/`df_m' * /*
* fwl_ct used here so that F-stat matches test stat from regression with no FWL and small
						*/ (`N_clust'-1)/`N_clust' * (`Nprec'-`rhs_ct'-`fwl_ct')/(`Nprec'-1)
				}
			}
			else {
				capture scalar `F' = r(chi2)/`df_m'
			}
			capture scalar `Fp'=Ftail(`df_m',`df_r',`F')
			capture scalar `Fdf2'=`df_r'
		}

* If j==. or vcv wasn't full rank, then vcv problems and F is meaningless
		if `j' == . | `rc'==506 {
			scalar `F' = .
			scalar `Fp' = .
		}

* End of counts, dofs, F-stat, small sample corrections
*******************************************************************************************
* orthog option: C statistic (difference of Sargan statistics)
*******************************************************************************************
* Requires j dof from above
		if "`orthog'"!="" {
			tempname cj cstat cstatp
* Initialize cstat
			scalar `cstat' = 0
* Each variable listed must be in instrument list.
* To avoid overwriting, use cendo, cinexog1, cexexog, cendo_ct, cex_ct
			local cendo1   "`endo1'"
			local cinexog1 "`inexog1'"
			local cexexog1 "`exexog1'"
			local cinsts1  "`insts1'"
			local crhs1    "`rhs1'"
			local clist1   "`orthog'"
			local clist_ct  : word count `clist1'

* Check to see if c-stat vars are in original list of all ivs
* cinexog1 and cexexog1 are after c-stat exog list vars have been removed
* cendo1 is endo1 after included exog being tested has been added
			foreach x of local clist1 {
				local llex_ct : word count `cexexog1'
				Subtract cexexog1 : "`cexexog1'" "`x'"
				local cex1_ct : word count `cexexog1'
				local ok = `llex_ct' - `cex1_ct'
				if (`ok'==0) {
* Not in excluded, check included and add to endog list if it appears
					local llin_ct : word count `cinexog1'
					Subtract cinexog1 : "`cinexog1'" "`x'"
					local cin1_ct : word count `cinexog1'
					local ok = `llin_ct' - `cin1_ct'
					if (`ok'==0) {
* Not in either list
di in r "Error: `x' listed in orthog() but does not appear as exogenous." 
						error 198
					}
					else {
						local cendo1 "`cendo1' `x'"
					}
				}
			}

* If robust, HAC/AC or GMM (but not LIML or IV), create optimal weighting matrix to pass to ivreg2
*   by extracting the submatrix from the full S and then inverting.
*   This guarantees the C stat will be non-negative.  See Hayashi (2000), p. 220. 
* Calculate C statistic with recursive call to ivreg2
* Collinearities may cause problems, hence -capture-.
* smatrix works generally, including homoskedastic case with Sargan stat
			capture {
				capture _estimates hold `ivest', restore
				if _rc==1000 {
di as err "ivreg2 internal error - no room to save temporary estimation results"
di as err "Please drop one or more estimation results using -estimates drop-"
					exit 1000
				}
				if "`kernel'" != "" {
					local bwopt "bw(`bw')"
					local kernopt "kernel(`kernel')"
				}
* clopt is omitted because it requires calculation of numbers of clusters, which is done
* only when S matrix is calculated
				capture `ivreg2_cmd' `lhs' `cinexog1' /*
					*/ (`cendo1'=`cexexog1') /*
					*/ if `touse' `wtexp', `noconstant' /*
					*/ `options' `small' `robust' /*
					*/ `gmm' `bwopt' `kernopt' `dofmopt' `sw' `swpsd' /*
					*/ smatrix("`S'") noid
				local rc = _rc
				if `rc' == 481 {
					scalar `cstat' = 0
					local cstatdf = 0
				}
				else {
					scalar `cj'=e(j)
					local cjdf=e(jdf)
				}
				scalar `cstat' = `j' - `cj'
				local cstatdf  = `jdf' - `cjdf'
				_estimates unhold `ivest'
				scalar `cstatp'= chiprob(`cstatdf',`cstat')
* Collinearities may cause C-stat dof to differ from the number of variables in orthog()
* If so, set cstat=0
				if `cstatdf' != `clist_ct' {
					scalar `cstat' = 0
				}
			}
		}
* End of orthog block

*******************************************************************************************
* Endog option
*******************************************************************************************
* Uses recursive call with orthog
		if "`endogtest'"!="" {
			tempname estat estatp
* Initialize estat
			scalar `estat' = 0
* Each variable to test must be in endo list.
* To avoid overwriting, use eendo, einexog1, etc.
			local eendo1   "`endo1'"
			local einexog1 "`inexog1'"
			local einsts1  "`insts1'"
			local elist1   "`endogtest'"
			local elist_ct  : word count `elist1'
* Check to see if endog test vars are in original endo1 list of endogeneous variables
* eendo1 and einexog1 are after endog test vars have been removed from endo and added to inexog
			foreach x of local elist1 {
				local llendo_ct : word count `eendo1'
				local eendo1    : list eendo1 - x
				local eendo1_ct : word count `eendo1'
				local ok = `llendo_ct' - `eendo1_ct'
				if (`ok'==0) {
* Not in endogenous list
di in r "Error: `x' listed in endog() but does not appear as endogenous." 
						error 198
				}
				else {
					local einexog1 "`einexog1' `x'"
				}
			}
* Recursive call to ivreg2 using orthog option to obtain endogeneity test statistic
* Collinearities may cause problems, hence -capture-.
			capture {
				capture _estimates hold `ivest', restore
				if _rc==1000 {
di as err "ivreg2 internal error - no room to save temporary estimation results"
di as err "Please drop one or more estimation results using -estimates drop-"
					exit 1000
				}
				capture `ivreg2_cmd' `lhs' `einexog1' /*
					*/ (`eendo1'=`exexog1') if `touse' /*
					*/ `wtexp', `noconstant' `robust' `clopt' /*
					*/ `gmm' `liml' `bwopt' `kernopt' /*
					*/ `small' `dofmopt' `sw' `swpsd' `options' /*
					*/ orthog(`elist1') noid
				local rc = _rc
				if `rc' == 481 {
					scalar `estat' = 0
					local estatdf = 0
					}
				else {
					scalar `estat'=e(cstat)
					local  estatdf=e(cstatdf)
					scalar `estatp'=e(cstatp)
				}
				_estimates unhold `ivest'
* Collinearities may cause endog stat dof to differ from the number of variables in endog()
* If so, set estat=0
				if `estatdf' != `elist_ct' {
					scalar `estat' = 0
				}
			}
* End of endogeneity test block
		}

*******************************************************************************************
* Rank identification and redundancy block
*******************************************************************************************
		if `endo1_ct' > 0 & "`noid'"=="" {
			tempname ccmat ccrealev ccimagev cc idstat iddf idp
			tempname cdchi2 cdchi2p ccf cdf cdeval cd
			mat `ccmat' = `XXinv'*`XPZX'
* Need only upper LHS block, which corresponds to included endogenous
			mat `ccmat' = `ccmat'[1..`endo1_ct',1..`endo1_ct']
			mat eigenvalues `ccrealev' `ccimagev' = `ccmat'
* Real eigenvalues are the squared canonical correlations
* The first reported cc is NOT necessarily the smallest (with mat symeigen the smallest is last).
* Sort so smallest is first.
			vecsort `ccrealev'
			scalar `cc'=`ccrealev'[1,1]
* dof adjustment needed because it doesn't use the adjusted S
			scalar `idstat' = -(`Nprec'-`dofminus')*ln(1-`cc')
			local iddf = `iv_ct' - (`rhs_ct'-1)
			scalar `idp' = chiprob(`iddf',`idstat')
* Cragg-Donald, Anderson etc.
			scalar `cd'=`cc'/(1-`cc')
* dofminus used because it doesn't use adjusted S
			local ddf = `Nprec'-`iv_ct'-`dofminus'
			local ndf = `exex1_ct'
			scalar `cdchi2'=`cd'*(`Nprec'-`dofminus')
			scalar `cdchi2p' = chiprob(`iddf',`cdchi2')
			scalar `cdf' =`cd'*`ddf'/`ndf'
			scalar `ccf' =`cc'*`ddf'/`ndf'
* Save evs in CD style
			local evcols = colsof(`ccrealev')
			mat `cdeval' = J(1,`evcols',.)
			forval i=1/`evcols' {
				mat `cdeval'[1,`i'] = `ccrealev'[1,`i'] / (1 - `ccrealev'[1,`i'])
			}
		}

* LR redundancy test
		if `endo1_ct' > 0 & "`redundant'" ~= "" & "`noid'"=="" {
* Obtain Anderson zero rank (totally unidentified) statistic for full set of instruments
			tempname unidstat
			scalar `unidstat'=0
			forvalues thiscol=1(1)`endo1_ct' {
* dof adjustment needed because it doesn't use the adjusted S
				scalar `unidstat'=`unidstat'-(`Nprec'-`dofminus')*ln(1-`ccrealev'[1,`thiscol'])
			}
* Diff between this and the stat using the irrelevant excl IVs is chi2 with dof=#endog*#tested
			local redlist1   "`redundant'"
* XZcols are the Z columns, so can use for ZZ too
			local rXZcols : colnames `XZ'
			foreach x of local redlist1 {
				local riv_ct_a : word count `rXZcols'
				Subtract rXZcols : "`rXZcols'" "`x'"
				local riv_ct_b : word count `rXZcols'
				if `riv_ct_a' == `riv_ct_b' {
* Not in list
di in r "Error: `x' listed in redundant() but does not appear as excluded instrument." 
						error 198
					}
			}
			tempname rXZ rZZ rZZtemp rZZinv rXPZX rccmat rccrealev rccimagev runidmat runidstat
			foreach cn of local rXZcols {
				mat `rXZ' = nullmat(`rXZ') , `XZ'[1...,"`cn'"]
				mat `rZZtemp' = nullmat(`rZZtemp') , `ZZ'[1...,"`cn'"]
			}
			foreach cn of local rXZcols {
				mat `rZZ' = nullmat(`rZZ') \ `rZZtemp'["`cn'",1...]
			}
			mat `rZZ'=(`rZZ'+`rZZ'')/2
			mat `rZZinv' = syminv(`rZZ')
			mat `rXPZX' = `rXZ'*`rZZinv'*`rXZ''
			mat `rccmat' = `XXinv'*`rXPZX'
			mat `rccmat' = `rccmat'[1..`endo1_ct',1..`endo1_ct']
			mat eigenvalues `rccrealev' `rccimagev' = `rccmat'
			scalar `runidstat'=0
			forvalues thiscol=1(1)`endo1_ct' {
* dof adjustment needed because it doesn't use the adjusted S
				scalar `runidstat'=`runidstat'-(`Nprec'-`dofminus')*ln(1-`rccrealev'[1,`thiscol'])
			}
			tempname redstat redp
			local riv_ct = rowsof(`rZZ') - diag0cnt(`rZZinv')
			if `riv_ct' < `rhs_ct' {
* Not in list
di in r "Error: specification with redundant() option is unidentified (fails rank condition)" 
				error 198
			}
			local redlist_ct=`iv_ct'-`riv_ct'
			scalar `redstat' = `unidstat' - `runidstat'
			local reddf = `endo1_ct'*`redlist_ct'
			scalar `redp' = chiprob(`reddf',`redstat')
		}

* End of identification stats block

*******************************************************************************************
* Error-checking block
*******************************************************************************************

* Check if adequate number of observations
		if `N' <= `iv_ct' {
di in r "Error: number of observations must be greater than number of instruments"
di in r "       including constant."
			error 2001
		}

* Check if robust VCV matrix is of full rank
		if "`gmm'`robust'`cluster'`kernel'" != "" {
* Robust covariance matrix not of full rank means either a singleton dummy  or too few
*    clusters (in which case the indiv SEs are OK but no F stat or 2-step GMM is possible),
*   or there are too many AC/HAC-lags, or the HAC covariance estimator
*   isn't positive definite (possible with truncated and Tukey-Hanning kernels)
			if `rankS' < `iv_ct' {
* If two-step GMM then exit with error ...
				if "`gmm'" != "" {
di in r "Error: estimated covariance matrix of moment conditions not of full rank;"
di in r "       cannot calculate optimal weighting matrix for GMM estimation."
di in r "Possible causes:"
					if "`cluster'" != "" {
di in r "       number of clusters insufficient to calculate optimal weighting matrix"
					}
					if "`kernel'" != "" {
di in r "       covariance matrix of moment conditions not positive definite"
di in r "       covariance matrix uses too many lags"
					}
di in r "       singleton dummy variable (dummy with one 1 and N-1 0s or vice versa)"
di in r "-fwl- option may address problem.  See help " _c
di in smcl "{help ivreg2}".
					error 498
				}
* Estimation isn't two-step GMM so continue but J, F, and C stat (if present) all meaningless
* Must set Sargan-Hansen j = missing so that problem can be reported in output
				else {
					scalar `j' = .
					if "`orthog'"!="" {
						scalar `cstat' = .
					}
					if "`endogtest'"!="" {
						scalar `estat' = .
					}
				}
			}
		}

* End of error-checking block
********************************************************************************************
* Reduced form and first stage regression options
*******************************************************************************************
* Relies on proper count of (non-collinear) IVs generated earlier.
* Note that nocons option + constant in instrument list means first-stage
* regressions are reported with nocons option.  First-stage F-stat therefore
* correctly includes the constant as an explanatory variable.

		if "`rf'`saverf'`first'`ffirst'`savefirst'" != "" & (`endo1_ct' > 0) & "`noid'"=="" {
* Reduced form needed for AR first-stage test stat.  Also estimated if requested.
				tempname archi2 archi2p arf arfp ardf ardf_r sstat sstatp sstatdf
				doRF "`lhs'" "`inexog1'" "`exexog1'" /*
					*/ `touse' `"`wtexp'"' `"`noconstant'"' `"`robust'"' /*
					*/ `"`clopt'"' `"`bwopt'"' `"`kernopt'"' /*
					*/ `"`saverfprefix'"' /*
					*/ "`dofminus'" `"`sw'"' `"`swpsd'"' "`ivreg2_cmd'"
				scalar `archi2'=r(archi2)
				scalar `archi2p'=r(archi2p)
				scalar `arf'=r(arf)
				scalar `arfp'=r(arfp)
				scalar `ardf'=r(ardf)
				scalar `ardf_r'=r(ardf_r)
				local rfeq "`r(rfeq)'"
* Drop saved rf results if needed only for first-stage estimations
				if "`rf'`saverf'" == "" {
					capture estimates drop `rfeq'
				}
* Stock-Wright S statistic. Equiv to J LM test of exexog.
* First block handles all cases except no exog regressors; second block uses GMM obj function,
* which works without fwl because b0 is only endog regressors.

				if `inexog1_ct' + `cons_ct' > 0 {
					qui `ivreg2_cmd' `lhs' `inexog' (=`exexog') `wtexp' if `touse', /*
						*/	`noconstant' dofminus(`dofminus') /*
						*/	`robust' `clopt' `bwopt' `kernopt' `sw' `swpsd'
				}
				else {
					tempname b1
					mat `b1'=J(1,`endo1_ct',0)
					matrix colnames `b1' = `endo1'
					qui `ivreg2_cmd' `lhs' (`endo1'=`exexog') `wtexp' if `touse', /*
						*/	b0(`b1') noconstant dofminus(`dofminus') /*
						*/	`robust' `clopt' `bwopt' `kernopt' `sw' `swpsd'
				}
				scalar `sstat'=e(j)
				scalar `sstatdf'=`ardf'
				scalar `sstatp'=chiprob(`sstatdf',`sstat')
		}

		if "`first'`ffirst'`savefirst'" != ""  & (`endo1_ct' > 0) {

* Godfrey method of Shea partial R2 uses IV and OLS estimates without robust vcvs:
* Partial R2 = OLS V[d,d] / IV V[d,d] * IV s2 / OLS s2
* where d,d is the diagonal element corresponding to the endog regressor
* ... but this simplifies to matrices that have already been calculated:
*            = XXinv[d,d] / XPZXinv[d,d]
			tempname godfrey sols siv
			tempname firstmat sheapr2 pr2 pr2F pr2p
			mat `godfrey' = J(1,`endo1_ct',0)
			mat colnames `godfrey' = `endo1'
			mat rownames `godfrey' = "sheapr2"
			local i 1
			foreach var of local endo1 {
				mat `sols'=`XXinv'["`var'","`var'"]
				mat `siv'=`XPZXinv'["`var'","`var'"]
				mat `godfrey'[1,`i'] = `sols'[1,1]/`siv'[1,1]
				local i = `i'+1
			}

			if `iv1_ct' > `iv_ct' {
di
di in gr "Warning: collinearities detected among instruments"
di in gr "1st stage tests of excluded exogenous variables may be incorrect"
			}

			doFirst "`endo1'" "`inexog1'" "`exexog1'" /*
				*/ `touse' `"`wtexp'"' `"`noconstant'"' `"`robust'"' /*
				*/ `"`clopt'"' `"`bwopt'"' `"`kernopt'"' /*
				*/ `"`savefprefix'"' /*
				*/ `"`dofmopt'"' `"`sw'"' `"`swpsd'"' "`ivreg2_cmd'"

			local firsteqs "`r(firsteqs)'"
			capture mat `firstmat'=`godfrey' \ r(firstmat)
			if _rc != 0 {
di in ye "Warning: missing values encountered; first stage regression results not saved"
			}
		}
* End of first-stage regression code
**********************************************************************************************
* Post and display results.
*******************************************************************************************

* restore data if preserved for fwl option
		if "`fwl'" != "" {
			restore
		}

* NB: Would like to use -Nprec- in obs() in case weights generate non-integer obs
*     but Stata complains.  Using -Nprec- with dof() makes no difference - seems to round it
		if "`small'"!="" {
			local NminusK = `N'-`rhs_ct'
			capture ereturn post `B' `V', dep(`depname') obs(`N') esample(`touse') /*
				*/ dof(`NminusK')
		}
		else {
			capture ereturn post `B' `V', dep(`depname') obs(`N') esample(`touse')
		}
		local rc = _rc
		if `rc' == 504 {
di in red "Error: estimated variance-covariance matrix has missing values"
			exit 504
		}
		if `rc' == 506 {
di in red "Error: estimated variance-covariance matrix not positive-definite"
			exit 506
		}
		if `rc' > 0 {
di in red "Error: estimation failed - could not post estimation results"
			exit `rc'
		}

* changed next from `endo1' to `endo' 2Aug06 MES
		ereturn local instd `endo'
		local insts : colnames `S'
		local insts : subinstr local insts "_cons" ""
		ereturn local insts  `insts'
		ereturn local inexog `inexog'
		ereturn local exexog `exexog'
		ereturn local fwl    `fwl'
		ereturn scalar inexog_ct=`inexog1_ct'
		ereturn scalar exexog_ct=`exex1_ct'
		ereturn scalar endog_ct =`endo1_ct'
		if "`collin'`ecollin'`dups'`fwlcons'" != "" {
			ereturn local collin  `collin'
			ereturn local ecollin `ecollin'
			ereturn local dups    `dups'
			ereturn local instd1  `endo1'
			ereturn local inexog1 `inexog1'
			ereturn local exexog1 `exexog1'
			ereturn local fwl1    `fwl1'
		}

		if "`smatrix'" == "" {
			ereturn matrix S `S'
		}
		else {
* Create a copy so posting doesn't zap the original
			tempname Scopy
			mat `Scopy'=`smatrix'
			ereturn matrix S `Scopy'
		}

* No weighting matrix defined for LIML and kclass
		if "`wmatrix'"=="" & "`liml'`kclass'"=="" {
			ereturn matrix W `W'
		}
		else if "`liml'`kclass'"=="" {
* Create a copy so posting doesn't zap the original
			tempname Wcopy
			mat `Wcopy'=`wmatrix'
			ereturn matrix W `Wcopy'
		}

		if "`kernel'"!="" {
			ereturn local kernel "`kernel'"
			ereturn scalar bw=`bw'
			ereturn local tvar "`tvar'"
			if "`ivar'" ~= "" {
				ereturn local ivar "`ivar'"
			}
		}

		if "`small'"!="" {
			ereturn scalar df_r=`df_r'
			ereturn local small "small"
		}

		if "`cluster'"!="" {
			ereturn scalar N_clust=`N_clust'
			ereturn local clustvar `cluster'
		}

		if "`robust'`cluster'" != "" {
			ereturn local vcetype "Robust"
		}

		ereturn scalar df_m=`df_m'
		ereturn scalar r2=`r2'
		ereturn scalar rmse=`rmse'
		ereturn scalar rss=`rss'
		ereturn scalar mss=`mss'
		ereturn scalar r2_a=`r2_a'
		ereturn scalar F=`F'
		ereturn scalar Fp=`Fp'
		ereturn scalar Fdf2=`Fdf2'
		ereturn scalar yy=`yy'
		ereturn scalar yyc=`yyc'
		ereturn scalar r2u=`r2u'
		ereturn scalar r2c=`r2c'
		ereturn scalar rankzz=`iv_ct'
		ereturn scalar rankxx=`rhs_ct'
		if "`gmm'`robust'`cluster'`kernel'" != "" {
			ereturn scalar rankS=`rankS'
		}
		ereturn scalar rankV=`rankV'
		ereturn scalar ll = -0.5 * (`Nprec'*ln(2*_pi) + `Nprec'*ln(`rss'/`Nprec') + `Nprec')

* Always save J.  Also save as Sargan if homoskedastic; save A-R if LIML.
		ereturn scalar j=`j'
		ereturn scalar jdf=`jdf'
		if `j' != 0 & `j' != . {
			ereturn scalar jp=`jp'
		}
		if ("`robust'`cluster'"=="") {
			ereturn scalar sargan=`j'
			ereturn scalar sargandf=`jdf'
			if `j' != 0  & `j' != . {
				ereturn scalar sarganp=`jp'
			}
		}
		if "`liml'"!="" {
			ereturn scalar arubin=`arubin'
			ereturn scalar arubindf=`jdf'
			if `j' != 0  & `j' != . {
				ereturn scalar arubinp=`arubinp'
			}
		}

		if "`orthog'"!="" {
			ereturn scalar cstat=`cstat'
			if `cstat'!=0  & `cstat' != . {
				ereturn scalar cstatp=`cstatp'
				ereturn scalar cstatdf=`cstatdf'
				ereturn local clist `clist1'
			}
		}

		if "`endogtest'"!="" {
			ereturn scalar estat=`estat'
			if `estat'!=0  & `estat' != . {
				ereturn scalar estatp=`estatp'
				ereturn scalar estatdf=`estatdf'
				ereturn local elist `elist1'
			}
		}

		if `endo1_ct' > 0 & "`noid'"=="" {
			ereturn scalar idstat=`idstat'
			ereturn scalar iddf=`iddf'
			ereturn scalar idp=`idp'
			ereturn scalar cd=`cd'
			ereturn scalar cdf=`cdf'
			ereturn matrix ccev=`ccrealev'
			capture ereturn matrix cdev `cdeval'
		}

		if "`redundant'"!="" & "`noid'"=="" {
			ereturn scalar redstat=`redstat'
			ereturn scalar redp=`redp'
			ereturn scalar reddf=`reddf'
			ereturn local  redlist `redlist1'
		}
		
		if "`first'`ffirst'`savefirst'" != "" & `endo1_ct'>0 & "`noid'"=="" {
* Capture here because firstmat empty if mvs encountered in 1st stage regressions
			capture ereturn matrix first `firstmat'
			ereturn scalar  cdchi2=`cdchi2'
			ereturn scalar  cdchi2p=`cdchi2p'
			ereturn scalar  arf=`arf'
			ereturn scalar  arfp=`arfp'
			ereturn scalar  archi2=`archi2'
			ereturn scalar  archi2p=`archi2p'
			ereturn scalar  ardf=`ardf'
			ereturn scalar  ardf_r=`ardf_r'
			ereturn scalar  sstat=`sstat'
			ereturn scalar  sstatp=`sstatp'
			ereturn scalar  sstatdf=`sstatdf'
			ereturn local   firsteqs `firsteqs'
		}
		if "`rf'`saverf'" != "" & `endo1_ct'>0 {
			ereturn local   rfeq `rfeq'
		}

		ereturn local depvar `lhs'

		if "`liml'"!="" {
			ereturn local model "liml"
			ereturn scalar kclass=`kclass2'
			ereturn scalar lambda=`lambda'
			if `fuller' > 0 & `fuller' < . {
				ereturn scalar fuller=`fuller'
			}
		}
		else if "`kclass'" != "" {
			ereturn local model "kclass"
			ereturn scalar kclass=`kclass2'
		}
		else if "`gmm'`cue'`wmatrix'"=="" {
			if "`endo1'" == "" {
				ereturn local model "ols"
			}
			else {
				ereturn local model "iv"
			}
		}
		else if "`cue'"~="" {
				ereturn local model "cue"
			}
		else if "`wmatrix'"~="" {
				ereturn local model "gmm"
		}
		else if "`gmm'"~="" {
			ereturn local model "gmm2s"
		}
		else {
* Should never enter here
			ereturn local model "unknown"
		}

		if "`weight'" != "" { 
			ereturn local wexp "=`exp'"
			ereturn local wtype `weight'
		}
		ereturn local cmd `ivreg2_cmd'
		ereturn local version `lversion'
		if "`noconstant'"!="" {
			ereturn scalar cons=0
		}
		else {
			ereturn scalar cons=1
		}
		if `fwl_ct'>0 {
			ereturn scalar fwlcons=`fwlcons'
		}
		ereturn local predict "`ivreg2_cmd'_p"

		if "`e(model)'"=="gmm2s" {
			local title2 "2-Step GMM estimation"
		}
		if "`e(model)'"=="gmm" {
			local title2 "GMM estimation with user-supplied weighting matrix"
		}
		if "`e(model)'"=="cue" {
			local title2 "CUE estimation"
		}
		if "`e(model)'"=="ols" {
			local title2 "OLS estimation"
		}
		if "`e(model)'"=="iv" {
			local title2 "IV (2SLS) estimation"
		}
		if "`e(model)'"=="liml" {
			local title2 "LIML estimation"
		}
		if "`e(model)'"=="kclass" {
			local title2 "k-class estimation"
		}
		if "`e(vcetype)'" == "Robust" {
			local hacsubtitle1 "heteroskedasticity"
		}
		if "`e(kernel)'"!="" {
			local hacsubtitle3 "autocorrelation"
		}
		if "`e(clustvar)'"!="" {
			local hacsubtitle3 "clustering on `e(clustvar)'"
		}
		if "`hacsubtitle1'"~="" & "`hacsubtitle3'" ~= "" {
			local hacsubtitle2 " and "
		}
		if "`title'"=="" {
			ereturn local title "`title1'`title2'"
		}
		else {
			ereturn local title "`title'"
		}
		if "`subtitle'"~="" {
			ereturn local subtitle "`subtitle'"
		}
		local hacsubtitle "`hacsubtitle1'`hacsubtitle2'`hacsubtitle3'"
		if "`hacsubtitle'"~="" {
			ereturn local hacsubtitle "Statistics robust to `hacsubtitle'"
		}
		if "`sw'"~=""  & "`swpsd'"=="" {
			ereturn local hacsubtitle "Stock-Watson heteroskedastic-robust statistics (BETA VERSION)"
		}
		if "`swpsd'"~="" {
			ereturn local hacsubtitle "Stock-Watson psd heteroskedastic-robust statistics (BETA VERSION)"
		}
	}
	
*******************************************************************************************
* Display results unless ivreg2 called just to generate stats or nooutput option

	if "`nooutput'" == "" {
		if "`savefirst'`saverf'" != "" {
			DispStored `"`saverf'"' `"`savefirst'"' `"`ivreg2_cmd'"'
		}
		if "`rf'" != "" {
			DispRF
		}
		if "`first'" != "" {
			DispFirst `"`ivreg2_cmd'"'
		}
		if "`first'`ffirst'" != "" {
			DispFFirst `"`ivreg2_cmd'"'
		}
		if "`eform'"!="" {
			local efopt "eform(`eform')"
		}
		DispMain `"`noheader'"' `"`plus'"' `"`efopt'"' `"`level'"' `"`nofooter'"' `"`ivreg2_cmd'"'
	}

* Drop first stage estimations unless explicitly saved or if replay
	if "`savefirst'" == "" {
		local firsteqs "`e(firsteqs)'"
		foreach eqname of local firsteqs {
			capture estimates drop `eqname'
		}
		ereturn local firsteqs
	}
	
* Drop reduced form estimation unless explicitly saved or if replay
	if "`saverf'" == "" {
		local eqname "`e(rfeq)'"
		capture estimates drop `eqname'
		ereturn local rfeq
	}

end

*******************************************************************************************
* SUBROUTINES
*******************************************************************************************

program define DispMain, eclass
	args noheader plus efopt level nofooter helpfile
	version 8.2
* Prepare for problem resulting from rank(S) being insufficient
* Results from insuff number of clusters, too many lags in HAC,
*   to calculate robust S matrix, HAC matrix not PD, singleton dummy,
*   and indicated by missing value for j stat
* Macro `rprob' is either 1 (problem) or 0 (no problem)
	capture local rprob ("`e(j)'"==".")

	if "`noheader'"=="" {
		if "`e(title)'" ~= "" {
di in gr _n "`e(title)'"
			local tlen=length("`e(title)'")
di in gr "{hline `tlen'}"
		}
		if "`e(subtitle)'" ~= "" {
di in gr "`e(subtitle)'"
		}
		if "`e(model)'"=="liml" | "`e(model)'"=="kclass" {
di in gr "k               =" %7.5f `e(kclass)'
		}
		if "`e(model)'"=="liml" {
di in gr "lambda          =" %7.5f `e(lambda)'
		}
		if e(fuller) > 0 & e(fuller) < . {
di in gr "Fuller parameter=" %-5.0f `e(fuller)'
		}
		if "`e(hacsubtitle)'" ~= "" {
di in gr _n "`e(hacsubtitle)'"
		}
		if "`e(kernel)'"!="" {
di in gr "  kernel=`e(kernel)'; bandwidth=`e(bw)'"
di in gr "  time variable (t):  " in ye e(tvar)
			if "`e(ivar)'" != "" {
di in gr "  group variable (i): " in ye e(ivar)
			}
		}
		di
		if "`e(clustvar)'"!="" {
di in gr "Number of clusters (" "`e(clustvar)'" ") = " in ye %-4.0f e(N_clust) _continue
		}
		else {
di in gr "                                   " _continue
		}
di in gr _col(55) "Number of obs = " in ye %8.0f e(N)

		if "`e(clustvar)'"=="" {
			local Fdf2=e(N)-e(rankxx)
		}
		else {
			local Fdf2=e(N_clust)-1
		}

di in gr _c _col(55) "F(" %3.0f e(df_m) "," %6.0f e(Fdf2) ") = "
		if e(F) < 99999 {
di in ye %8.2f e(F)
		}
		else {
di in ye %8.2e e(F)
		}
di in gr _col(55) "Prob > F      = " in ye %8.4f e(Fp)

di in gr "Total (centered) SS     = " in ye %12.0g e(yyc) _continue
di in gr _col(55) "Centered R2   = " in ye %8.4f e(r2c)
di in gr "Total (uncentered) SS   = " in ye %12.0g e(yy) _continue
di in gr _col(55) "Uncentered R2 = " in ye %8.4f e(r2u)
di in gr "Residual SS             = " in ye %12.0g e(rss) _continue
di in gr _col(55) "Root MSE      = " in ye %8.4g e(rmse)
di
	}

* Display coefficients etc.
* Unfortunate but necessary hack here: to suppress message about cluster adjustment of
*   standard error, clear e(clustvar) and then reset it after display
	local cluster `e(clustvar)'
	ereturn local clustvar
	ereturn display, `plus' `efopt' level(`level')
	ereturn local clustvar `cluster'

* Display 1st footer with identification stats
* Footer not displayed if -nofooter- option or if pure OLS, i.e., model="ols" and Sargan-Hansen=0
	if ~("`nofooter'"~="" | (e(model)=="ols" & (e(sargan)==0 | e(j)==0))) {

* Report Anderson rank ID test
		if "`e(instd)'"~="" & "`e(idstat)'"~="" {
di in smcl _c "{help `helpfile'##cancortest:Anderson canon. corr. LR statistic}"
di in gr _c " (underidentification test):"
di in ye _col(71) %8.3f e(idstat)
di in gr _col(52) "Chi-sq(" in ye e(iddf) /* 
	       			*/  in gr ") P-val =  " in ye _col(73) %6.4f e(idp)
* LR IV redundancy statistic
			if "`e(redlist)'"!="" {
di in gr "-redundant- option:"
di in smcl _c "{help `helpfile'##redtest:LR IV redundancy test}"
di in gr _c " (redundancy of specified instruments):"
di in ye _col(71) %8.3f e(redstat)
di in gr _col(52) "Chi-sq(" in ye e(reddf) /* 
	       			*/  in gr ") P-val =  " in ye _col(73) %6.4f e(redp)
di in gr "Instruments tested: " _c
					Disp `e(redlist)', _col(23)
			}
			if "`e(vcetype)'"=="Robust" | "`e(kernel)'"~="" {
di in gr "Test statistic(s) not robust"
			}
di in smcl in gr "{hline 78}"
		}
* Report Cragg-Donald statistic
		if "`e(instd)'"~="" & "`e(idstat)'"~="" {
di in smcl _c "{help `helpfile'##cdtest:Cragg-Donald F statistic}"
di in gr _c " (weak identification test):"
di in ye _col(71) %8.3f e(cdf)
di in gr _c "Stock-Yogo weak ID test critical values:"
			local cdmissing=1
			if "`e(model)'"=="iv" | "`e(model)'"=="gmm2s" | "`e(model)'"=="gmm" {
				cdsy, type(ivbias5) k2(`e(exexog_ct)') nendog(`e(endog_ct)')
				if "`r(cv)'"~="." {
					di in gr _col(43) "5% maximal IV relative bias" in ye _col(73) %6.2f r(cv)
					local cdmissing=0
				}
				cdsy, type(ivbias10) k2(`e(exexog_ct)') nendog(`e(endog_ct)')
				if "`r(cv)'"~="." {
					di in gr _col(42) "10% maximal IV relative bias" in ye _col(73) %6.2f r(cv)
					local cdmissing=0
				}
				cdsy, type(ivbias20) k2(`e(exexog_ct)') nendog(`e(endog_ct)')
				if "`r(cv)'"~="." {
					di in gr _col(42) "20% maximal IV relative bias" in ye _col(73) %6.2f r(cv)
					local cdmissing=0
				}
				cdsy, type(ivbias30) k2(`e(exexog_ct)') nendog(`e(endog_ct)')
				if "`r(cv)'"~="." {
					di in gr _col(42) "30% maximal IV relative bias" in ye _col(73) %6.2f r(cv)
					local cdmissing=0
				}
				cdsy, type(ivsize10) k2(`e(exexog_ct)') nendog(`e(endog_ct)')
				if "`r(cv)'"~="." {
					di in gr _col(42) "10% maximal IV size" in ye _col(73) %6.2f r(cv)
					local cdmissing=0
				}
				cdsy, type(ivsize15) k2(`e(exexog_ct)') nendog(`e(endog_ct)')
				if "`r(cv)'"~="." {
					di in gr _col(42) "15% maximal IV size" in ye _col(73) %6.2f r(cv)
					local cdmissing=0
				}
				cdsy, type(ivsize20) k2(`e(exexog_ct)') nendog(`e(endog_ct)')
				if "`r(cv)'"~="." {
					di in gr _col(42) "20% maximal IV size" in ye _col(73) %6.2f r(cv)
					local cdmissing=0
				}
				cdsy, type(ivsize25) k2(`e(exexog_ct)') nendog(`e(endog_ct)')
				if "`r(cv)'"~="." {
					di in gr _col(42) "25% maximal IV size" in ye _col(73) %6.2f r(cv)
					local cdmissing=0
				}
			}
			else if ("`e(model)'"=="liml" & e(fuller)==.) | "`e(model)'"=="cue" {
				cdsy, type(limlsize10) k2(`e(exexog_ct)') nendog(`e(endog_ct)')
				if "`r(cv)'"~="." {
					di in gr _col(42) "10% maximal LIML size" in ye _col(73) %6.2f r(cv)
					local cdmissing=0
				}
				cdsy, type(limlsize15) k2(`e(exexog_ct)') nendog(`e(endog_ct)')
				if "`r(cv)'"~="." {
					di in gr _col(42) "15% maximal LIML size" in ye _col(73) %6.2f r(cv)
					local cdmissing=0
				}
				cdsy, type(limlsize20) k2(`e(exexog_ct)') nendog(`e(endog_ct)')
				if "`r(cv)'"~="." {
					di in gr _col(42) "20% maximal LIML size" in ye _col(73) %6.2f r(cv)
					local cdmissing=0
				}
				cdsy, type(limlsize25) k2(`e(exexog_ct)') nendog(`e(endog_ct)')
				if "`r(cv)'"~="." {
					di in gr _col(42) "25% maximal LIML size" in ye _col(73) %6.2f r(cv)
					local cdmissing=0
				}
			}
			else if ("`e(model)'"=="liml" & e(fuller)<.) {
				cdsy, type(fullrel5) k2(`e(exexog_ct)') nendog(`e(endog_ct)')
				if "`r(cv)'"~="." {
					di in gr _col(43) "5% maximal Fuller rel. bias" in ye _col(73) %6.2f r(cv)
					local cdmissing=0
				}
				cdsy, type(fullrel10) k2(`e(exexog_ct)') nendog(`e(endog_ct)')
				if "`r(cv)'"~="." {
					di in gr _col(42) "10% maximal Fuller rel. bias" in ye _col(73) %6.2f r(cv)
					local cdmissing=0
				}
				cdsy, type(fullrel20) k2(`e(exexog_ct)') nendog(`e(endog_ct)')
				if "`r(cv)'"~="." {
					di in gr _col(42) "20% maximal Fuller rel. bias" in ye _col(73) %6.2f r(cv)
					local cdmissing=0
				}
				cdsy, type(fullrel30) k2(`e(exexog_ct)') nendog(`e(endog_ct)')
				if "`r(cv)'"~="." {
					di in gr _col(42) "30% maximal Fuller rel. bias" in ye _col(73) %6.2f r(cv)
					local cdmissing=0
				}
				cdsy, type(fullmax5) k2(`e(exexog_ct)') nendog(`e(endog_ct)')
				if "`r(cv)'"~="." {
					di in gr _col(43) "5% Fuller maximum bias" in ye _col(73) %6.2f r(cv)
					local cdmissing=0
				}
				cdsy, type(fullmax10) k2(`e(exexog_ct)') nendog(`e(endog_ct)')
				if "`r(cv)'"~="." {
					di in gr _col(42) "10% Fuller maximum bias" in ye _col(73) %6.2f r(cv)
					local cdmissing=0
				}
				cdsy, type(fullmax20) k2(`e(exexog_ct)') nendog(`e(endog_ct)')
				if "`r(cv)'"~="." {
					di in gr _col(42) "20% Fuller maximum bias" in ye _col(73) %6.2f r(cv)
					local cdmissing=0
				}
				cdsy, type(fullmax30) k2(`e(exexog_ct)') nendog(`e(endog_ct)')
				if "`r(cv)'"~="." {
					di in gr _col(42) "30% Fuller maximum bias" in ye _col(73) %6.2f r(cv)
					local cdmissing=0
				}
				di in gr "NB: Critical values based on Fuller parameter=1"
			}
			if `cdmissing' {
				di in gr _col(64) "<not available>"
			}
			else {
				if "`e(vcetype)'"=="Robust" | "`e(kernel)'"~="" {
di in gr "Test statistic(s) not robust"
				}
				di in gr "Source: Stock-Yogo (2005).  Reproduced by permission."
			}
			di in smcl in gr "{hline 78}"
		}

* Report either (a) Sargan-Hansen-C stats, or (b) robust covariance matrix problem
		if `rprob' == 0 {
* Display overid statistic
			if "`e(vcetype)'" == "Robust" {
				if "`e(instd)'" != "" {
di in smcl _c "{help `helpfile'##overidtests:Hansen J statistic}"
di in gr _c " (overidentification test of all instruments):"
				}
				else {
di in smcl _c "{help `helpfile'##overidtests:Hansen J statistic}"
di in gr _c " (Lagrange multiplier test of excluded instruments):"
				}
			}
			else {
				if "`e(instd)'" != "" {
di in smcl _c "{help `helpfile'##overidtests:Sargan statistic}"
di in gr _c " (overidentification test of all instruments):"
				}
				else {
di in smcl _c "{help `helpfile'##overidtests:Sargan statistic}"
di in gr _c " (Lagrange multiplier test of excluded instruments):"
				}
			}
di in ye _col(71) %8.3f e(j)
			if e(rankxx) < e(rankzz) {
di in gr _col(52) "Chi-sq(" in ye e(jdf) /* 
	       			*/  in gr ") P-val =  " in ye _col(73) %6.4f e(jp)
			}
			else {
di in gr _col(50) "(equation exactly identified)"
			}

* Display orthog option: C statistic (difference of Sargan statistics)
			if e(cstat) != . {
* If C-stat = 0 then warn, otherwise output
				if e(cstat) > 0  {
di in gr "-orthog- option:"
					if "`e(vcetype)'" == "Robust" {
di in gr _c "Hansen J statistic (eqn. excluding suspect orthog. conditions): "
					}
					else {
di in gr _c "Sargan statistic (eqn. excluding suspect orthogonality conditions):"
					}
di in ye _col(71) %8.3f e(j)-e(cstat)
di in gr _col(52) "Chi-sq(" in ye e(jdf)-e(cstatdf) in gr ") P-val =  " /*
				*/ in ye _col(73) %6.4f chiprob(e(jdf)-e(cstatdf),e(j)-e(cstat))
di in smcl _c "{help `helpfile'##ctest:C statistic}"
di in gr _c " (exogeneity/orthogonality of suspect instruments): "
di in ye _col(71) %8.3f e(cstat)
di in gr _col(52) "Chi-sq(" in ye e(cstatdf) in gr ") P-val =  " /*
				*/ in ye _col(73) %6.4f e(cstatp)
di in gr "Instruments tested:  " _c
					Disp `e(clist)', _col(23)
				}
				if e(cstat) == 0 {
di in gr _n "Collinearity/identification problems in eqn. excl. suspect orthog. conditions:"
di in gr "  C statistic not calculated for -orthog- option"
				}
			}
		}
		else {
* Problem exists with robust VCV - notify and list possible causes
di in r "Error: estimated covariance matrix of moment conditions not of full rank;"
di in r "       overidentification statistic not reported, and standard errors and"
di in r "       model tests should be interpreted with caution."
di in r "Possible causes:"
			if e(N_clust) < e(rankzz) {
di in r "       number of clusters insufficient to calculate robust covariance matrix"
			}
			if "`e(kernel)'" != "" {
di in r "       covariance matrix of moment conditions not positive definite"
di in r "       covariance matrix uses too many lags"
			}
di in r "       singleton dummy variable (dummy with one 1 and N-1 0s or vice versa)"
di in smcl _c "{help `helpfile'##fwl:fwl}"
di in r " option may address problem."
		}

* Display endog option: endogeneity test statistic
		if e(estat) != . {
* If stat = 0 then warn, otherwise output
			if e(estat) > 0  {
di in gr "-endog- option:"
di in smcl _c "{help `helpfile'##endogtest:Endogeneity test}"
di in gr _c " of endogenous regressors: "
di in ye _col(71) %8.3f e(estat)
di in gr _col(52) "Chi-sq(" in ye e(estatdf) /* 
       			*/  in gr ") P-val =  " in ye _col(73) %6.4f e(estatp)
di in gr "Regressors tested:  " _c
				Disp `e(elist)', _col(23)
			}
			if e(estat) == 0 {
di in gr _n "Collinearity/identification problems in restricted equation:"
di in gr "  Endogeneity test statistic not calculated for -endog- option"
			}
		}

		di in smcl in gr "{hline 78}"
* Display AR overid statistic if LIML and not robust
		if "`e(model)'" == "liml" & "`e(vcetype)'" ~= "Robust" & "`e(kernel)'" == "" {
			if "`e(instd)'" != "" {
di in smcl _c "{help `helpfile'##liml:Anderson-Rubin statistic}"
di in gr _c " (overidentification test of all instruments):"
				}
				else {
di in smcl _c "{help `helpfile'##liml:Anderson-Rubin statistic}"
di in gr _c " (LR test of excluded instruments):"
				}
di in ye _col(72) %7.3f e(arubin)
			if e(rankxx) < e(rankzz) {
di in gr _col(52) "Chi-sq(" in ye e(arubindf) /* 
	       			*/  in gr ") P-val =  " in ye _col(73) %6.4f e(arubinp)
			}
			else {
di in gr _col(50) "(equation exactly identified)"
			}
			di in smcl in gr "{hline 78}"
		}
	}

* Display 2nd footer with variable lists
	if "`nofooter'"=="" {

* Warn about dropped instruments if any
* (Re-)calculate number of user-supplied instruments
		local iv1_ct : word count `e(insts)'
		local iv1_ct = `iv1_ct' + `e(cons)'

		if `iv1_ct' > e(rankzz) {
di in gr "Collinearities detected among instruments: " _c
di in gr `iv1_ct'-e(rankzz) " instrument(s) dropped"
		}

		if "`e(collin)'`e(dups)'`e(fwlcons)'" != "" {
* If collinearities, duplicates or fwl, abbreviated varlists saved with a 1 at the end
			local one "1"
		}
		if "`e(instd)'" != "" {
			di in gr "Instrumented:" _c
			Disp `e(instd`one')', _col(23)
		}
		if "`e(inexog)'" != "" {
			di in gr "Included instruments:" _c
			Disp `e(inexog`one')', _col(23)
		}
		if "`e(exexog)'" != "" {
			di in gr "Excluded instruments:" _c
			Disp `e(exexog`one')', _col(23)
		}
		if "`e(fwlcons)'" != "" {
			if e(fwlcons) {
				local fwl "`e(fwl`one')' _cons"
			}
			else {
				local fwl "`e(fwl`one')'"
			}
di in smcl _c "{help `helpfile'##fwl:Partialled-out (FWL)}"
			di in gr ":" _c
			Disp `fwl', _col(23)
di in gr _col(23) "nb: variable counts and small-sample adjustments"
di in gr _col(23) "do not include partialled-out variables."
		}
		if "`e(dups)'" != "" {
			di in gr "Duplicates:" _c
			Disp `e(dups)', _col(23)
		}
		if "`e(collin)'" != "" {
			di in gr "Dropped collinear:" _c
			Disp `e(collin)', _col(23)
		}
		if "`e(ecollin)'" != "" {
			di in gr "Reclassified as exog:" _c
			Disp `e(ecollin)', _col(23)
		}
		di in smcl in gr "{hline 78}"
	}
end

**************************************************************************************

program define DispRF
	version 8.2
	local eqname "`e(rfeq)'"
	local depvar "`e(depvar)'"
	local strlen : length local depvar
	local strlen = `strlen'+25
di
di in gr "Reduced-form regression: `e(depvar)'"
di in smcl in gr "{hline `strlen'}"
	capture estimates replay `eqname'
	if "`eqname'"=="" | _rc != 0 {
di in ye "Unable to display reduced-form regression of `e(depvar)'."
di in ye "There may be insufficient room to store results using -estimates store-."
di in ye "Try dropping one or more estimation results using -estimates drop-."
di
	}
	else {
		estimates replay `eqname', noheader
di
	}
end

program define DispFirst
	version 8.2
	args helpfile
	tempname firstmat ivest sheapr2 pr2 F df df_r pvalue

	mat `firstmat'=e(first)
	if `firstmat'[1,1] == . {
di
di in ye "Unable to display first-stage estimates; macro e(first) is missing"
		exit
	}
di in gr _newline "First-stage regressions"
di in smcl in gr "{hline 23}"
di
	local endo1 : colnames(`firstmat')
	local nrvars : word count `endo1'
	local firsteqs "`e(firsteqs)'"
	local nreqs : word count `firsteqs'
	if `nreqs' < `nrvars' {
di in ye "Unable to display all first-stage regressions."
di in ye "There may be insufficient room to store results using -estimates store-."
di in ye "Try dropping one or more estimation results using -estimates drop-."
di
	}
	local robust "`e(vcetype)'"
	local cluster "`e(clustvar)'"
	local kernel "`e(kernel)'"
	foreach eqname of local firsteqs {
		_estimates hold `ivest'
		capture estimates restore `eqname'
		if _rc != 0 {
di
di in ye "Unable to list stored estimation `eqname'."
di in ye "There may be insufficient room to store results using -estimates store-."
di in ye "Try dropping one or more estimation results using -estimates drop-."
di
		}
		else {
			local vn "`e(depvar)'"
di in gr "First-stage regression of `vn':"
			estimates replay `eqname', noheader
			mat `sheapr2' =`firstmat'["sheapr2","`vn'"]
			mat `pr2'     =`firstmat'["pr2","`vn'"]
			mat `F'       =`firstmat'["F","`vn'"]
			mat `df'      =`firstmat'["df","`vn'"]
			mat `df_r'    =`firstmat'["df_r","`vn'"]
			mat `pvalue'  =`firstmat'["pvalue","`vn'"]
di in smcl _c "{help `helpfile'##partialr2:Partial R-squared}"
di in gr " of excluded instruments: " _c
di in ye %8.4f `pr2'[1,1]
di in gr "Test of excluded instruments:"
di in gr "  F(" %3.0f `df'[1,1] "," %6.0f `df_r'[1,1] ") = " in ye %8.2f `F'[1,1]
di in gr "  Prob > F      = " in ye %8.4f `pvalue'[1,1]
di
		}
		_estimates unhold `ivest'
	}
end

program define DispStored
	args saverf savefirst helpfile
	version 8.2
	if "`saverf'" != "" {
		local eqlist "`e(rfeq)'"
	}
	if "`savefirst'" != "" {
		local eqlist "`eqlist' `e(firsteqs)'"
	}
	local eqlist : list retokenize eqlist
di in gr _newline "Stored estimation results"
di in smcl in gr "{hline 25}" _c
	capture estimates dir `eqlist'
	if "`eqlist'" != "" & _rc == 0 {
* Estimates exist and can be listed
		estimates dir `eqlist'
	}
	else if "`eqlist'" != "" & _rc != 0 {
di
di in ye "Unable to list stored estimations."
di in ye "There may be insufficient room to store results using -estimates store-."
di in ye "Try dropping one or more estimation results using -estimates drop-."
di
	}
end

program define DispFFirst
	version 8.2
	args helpfile
	tempname firstmat sheapr2 pr2 pr2F pr2p
	mat `firstmat'=e(first)
	if `firstmat'[1,1] == . {
di
di in ye "Unable to display summary of first-stage estimates; macro e(first) is missing"
		exit
	}
	local endo   : colnames(`firstmat')
	local nrvars : word count `endo'
	local robust   "`e(vcetype)'"
	local cluster  "`e(clustvar)'"
	local kernel   "`e(kernel)'"
	local efirsteqs  "`e(firsteqs)'"
di
di in gr _newline "Summary results for first-stage regressions"
di in smcl in gr "{hline 43}"
di

di in gr _c "Variable    |"
di in smcl _c _col(15) "{help `helpfile'##partialr2:Shea Partial R2}"
di in gr _c _col(31) "|"
di in smcl _c _col(35) "{help `helpfile'##partialr2:Partial R2}"
di in gr _c _col(49) "|"
di in smcl _c _col(52) "{help `helpfile'##partialr2:F}"
di in gr _c _col(53) "("
di in ye _col(54) %3.0f `firstmat'[4,1] in gr "," in ye %6.0f `firstmat'[5,1] in gr ")    P-value"
	local i = 1
	while `i' <= `nrvars' {
		local vn : word `i' of `endo'
		local vnlen : length local vn
		if `vnlen' > 12 {
			local vn : piece 1 12 of "`vn'"
		}
		scalar `sheapr2'=`firstmat'[1,`i']
		scalar `pr2'=`firstmat'[2,`i']
		scalar `pr2F'=`firstmat'[3,`i']
		scalar `pr2p'=`firstmat'[6,`i']
di in y %-12s "`vn'" _col(13) in gr "|" _col(17) in y %8.4f `sheapr2' _col(31) in gr "|" /*
			*/ _col(35) in y %8.4f `pr2' _col(49) in gr "|" /*
			*/ _col(53) in y %8.2f `pr2F' _col(67) %8.4f `pr2p'
		local i = `i' + 1
	}
di
	if "`robust'`cluster'" != "" {
		if "`cluster'" != "" {
			local rtype "cluster-robust"
		}
		else if "`kernel'" != "" {
			local rtype "heteroskedasticity and autocorrelation-robust"
		}
		else {
			local rtype "heteroskedasticity-robust"
		}
	}
	else if "`kernel'" != "" {
			local rtype "autocorrelation-robust"
	}
	if "`robust'`cluster'`kernel'" != "" {
di in gr "NB: first-stage F-stat `rtype'"
di
	}
	
	tempname iddf idstat idp cdchi2 cdchi2p cdf
	scalar `iddf'=e(iddf)
	scalar `idstat'=e(idstat)
	scalar `idp'=e(idp)
	scalar `cdchi2'=e(cdchi2)
	scalar `cdchi2p'=e(cdchi2p)
	scalar `cdf'=e(cdf)
di in smcl "{help `helpfile'##s_first:Underidentification tests}"
di in gr "Ho: matrix of reduced form coefficients has rank=K-1 (underidentified)"
di in gr "Ha: matrix has rank=K (identified)"
di in gr _col(50) "Chi-sq(" in ye `iddf' in gr ")" _col(65) "P-value"
di in ye "Anderson canon. corr. -N*ln(1-CCEV) LR stat." _col(49) %8.2f `idstat' _col(65) %7.4f `idp'
di in ye "Cragg-Donald N*CDEV statistic" _col(49) %8.2f `cdchi2' _col(65) %7.4f `cdchi2p'
	if "`robust'`cluster'`kernel'" != "" & e(endog_ct)==1 {
		tempname rchi2 rchi2p
* Robust chi2 recreated from robust F and dofs of non-robust C-D chi2 and F
		scalar `rchi2'=`pr2F'*`cdchi2'/`cdf'
		scalar `rchi2p'=chiprob(`iddf',`rchi2')
di in ye "Robust chi-square statistic" _col(49) %8.2f `rchi2' _col(65) %7.4f `rchi2p'
	}
di
di in smcl "{help `helpfile'##s_first:Weak identification tests}"
di in gr "Ho: equation is weakly identified"
di in ye "Cragg-Donald (N-L)*CDEV/L1 F-statistic" _col(49) %8.2f `cdf'
	if "`robust'`cluster'`kernel'" != "" & e(endog_ct)==1 {
di in ye "Robust F-statistic" _col(49) %8.2f `pr2F'
	}
di in gr "See main output for Cragg-Donald weak id test critical values"
di
	if "`robust'`cluster'`kernel'" != "" {
di in gr "NB: Anderson and Cragg-Donald under- and weak identification stats not robust"
		if "`robust'`cluster'`kernel'" != "" & e(endog_ct)==1 {
di in gr "    Robust identification stats `rtype'"
		}
	}
di
	tempname arf arfp archi2 archi2p ardf ardf_r
	tempname sstat sstatp sstatdf
di in smcl "{help `helpfile'##wirobust:Weak-instrument-robust inference}"
di in gr "Tests of joint significance of endogenous regressors B1 in main equation"
di in gr "Ho: B1=0 and overidentifying restrictions are valid"
* Needs to be small so that adjusted dof is reflected in F stat
	scalar `arf'=e(arf)
	scalar `arfp'=e(arfp)
	scalar `archi2'=e(archi2)
	scalar `archi2p'=e(archi2p)
	scalar `ardf'=e(ardf)
	scalar `ardf_r'=e(ardf_r)
	scalar `sstat'=e(sstat)
	scalar `sstatp'=e(sstatp)
	scalar `sstatdf'=e(sstatdf)
di in ye _c "Anderson-Rubin test"
di in gr _col(30) "F(" in ye `ardf' in gr "," in ye `ardf_r' in gr ")=" /*
		*/	_col(40) in ye %-7.2f `arf'    _col(50) in gr "P-val=" in ye %6.4f `arfp'
di in ye _c "Anderson-Rubin test"
di in gr _col(30) "Chi-sq(" in ye `ardf' in gr ")=" /*
		*/	_col(40) in ye %-7.2f `archi2' _col(50) in gr "P-val=" in ye %6.4f `archi2p'
di in ye _c "Stock-Wright S statistic"
di in gr _col(30) "Chi-sq(" in ye `sstatdf' in gr ")=" /*
		*/	_col(40) in ye %-7.2f `sstat' _col(50) in gr "P-val=" in ye %6.4f `sstatp'
	if "`robust'`cluster'`kernel'" != "" {
di in gr "NB: Test statistics `rtype'"
	}
di
	if "`cluster'" != "" {
di in gr "Number of clusters     N_clust     = " in ye %10.0f e(N_clust)
	}
di in gr "Number of observations N           = " in ye %10.0f e(N)
di in gr "Number of regressors   K           = " in ye %10.0f e(rankxx)
di in gr "Number of instruments  L           = " in ye %10.0f e(rankzz)
di in gr "Number of excluded instruments L1  = " in ye %10.0f e(ardf)
di

end

* Performs first-stage regressions

program define doFirst, rclass
	version 8.2
	args    endog		/*  variable list  (including depvar)
		*/  inexog	/*  list of included exogenous
		*/  exexog	/*  list of excluded exogenous
		*/  touse	/*  touse sample
		*/  weight	/*  full weight expression w/ []
		*/  nocons	/*
		*/  robust	/*
		*/  clopt	/*
		*/  bwopt	/*
		*/  kernopt	/*
		*/  savefprefix /*
		*/  dofmopt	/*
		*/  sw		/*
		*/  swpsd	/*
		*/  ivreg2_cmd

	tokenize `endog'
	tempname statmat statmat1
	local i 1
	while "``i''" != "" {
		capture `ivreg2_cmd' ``i'' `inexog' `exexog' `weight' /*
				*/ if `touse', `nocons' `robust' `clopt' `bwopt' `kernopt' `dofmopt' `sw' `swpsd' small
		if _rc ~= 0 {
* First-stage regression failed
di in ye "Unable to estimate first-stage regression of ``i''"
			if _rc == 506 {
di in ye "  var-cov matrix of first-stage regression of ``i'' not positive-definite"
			}
		}
		else {
* First-stage regression successful
* Check if there is enough room to save results; leave one free.  Allow for overwriting.
* Max is 20-1=19 for Stata 9.0 and earlier, 300-1=299 for Stata 9.1+
			if c(stata_version) < 9.1 {
				local maxest=19
			}
			else {
				local maxest=299
			}
			local vn "``i''"
			local plen : length local savefprefix
			local vlen : length local vn
			if `plen'+`vlen' > 27 {
				local vlen=27-`plen'
				local vn : permname `vn', length(`vlen')
* Must create a variable so that permname doesn't reuse it
				gen `vn'=0
				local dropvn "`dropvn' `vn'"
			}
			local eqname "`savefprefix'`vn'"
			local eqname : subinstr local eqname "." "_"
			qui estimates dir
			local est_list  "`r(names)'"
			Subtract est_list : "`est_list'" "`eqname'"
			local est_ct : word count `est_list'
			if `est_ct' < `maxest' {
				capture est store `eqname', title("First-stage regression: ``i''")
				if _rc == 0 {
					local firsteqs "`firsteqs' `eqname'"
				}
			}
			else {
di
di in ye "Unable to store first-stage regression of ``i''."
di in ye "There may be insufficient room to store results using -estimates store-."
di in ye "Try dropping one or more estimation results using -estimates drop-."
di
			}
			tempname rssall rssinc pr2 F p
			scalar `rssall'=e(rss)
			quietly test `exexog'
			scalar `F'=r(F)
			scalar `p'=r(p)
			local df=r(df)
			local df_r=r(df_r)
* 1st stage regression without excluded exogenous
* Use regress since need only RSS and handles all cases, including perverse ones (e.g. no regressors)
			qui regress ``i'' `inexog' `weight' /*
				*/ if `touse', `nocons'
			*/ if `touse', `nocons' `robust' `clopt' `bwopt' `kernopt' `dofmopt' `sw' `swpsd' small
			scalar `rssinc'=e(rss)
* NB: uncentered R2 for main regression is 1-rssall/yy; for restricted is 1-rssinc/yy;
*     squared semipartial correlation=(rssinc-rssall)/yy=diff of 2 R2s
* Squared partial correlation (="partialled-out R2")
			scalar `pr2'=(`rssinc'-`rssall')/`rssinc'
* End of first-stage successful block
		}
		capture {
			mat `statmat1' = (`pr2' \ `F' \ `df' \ `df_r' \ `p')
			mat colname `statmat1' = ``i''
			if `i'==1 {
				mat `statmat'=`statmat1'
			}
			else {
				mat `statmat' = `statmat' , `statmat1'
			}
		}
		local i = `i' + 1
	}
* Drop any temporarily-created permname variables
	if trim("`dropvn'")~="" {
		foreach vn of varlist `dropvn' {
			capture drop `vn'
		}
	}
	capture mat rowname `statmat' = pr2 F df df_r pvalue
	if _rc==0 {
		return matrix firstmat `statmat'
	}
	return local firsteqs "`firsteqs'"
end

program define doRF, rclass
	version 8.2
	args    lhs		/*
		*/  inexog	/*  list of included exogenous
		*/  exexog	/*  list of excluded exogenous
		*/  touse	/*  touse sample
		*/  weight	/*  full weight expression w/ []
		*/  nocons	/*
		*/  robust	/*
		*/  clopt	/*
		*/  bwopt	/*
		*/  kernopt	/*
		*/  saverfprefix /*
		*/  dofminus	/*
		*/  sw		/*
		*/  swpsd	/*
		*/  ivreg2_cmd

* Anderson-Rubin test of signif of endog regressors (Bo=0)
* In case ivreg2 called with adjusted dof, first stage should adjust dof as well
	tempname arf arfp archi2 archi2p ardf ardf_r tempest
	capture _estimates hold `tempest'
	if _rc==1000 {
di as err "ivreg2 internal error - no room to save temporary estimation results"
di as err "Please drop one or more estimation results using -estimates drop-"
		exit 1000
	}
* Needs to be small so that adjusted dof is reflected in F stat
	qui `ivreg2_cmd' `lhs' `inexog' `exexog' `weight' if `touse', /*
		*/	small `nocons' dofminus(`dofminus') `robust' `clopt' `bwopt' `kernopt' `sw' `swpsd'
	qui test `exexog'
	scalar `arf'=r(F)
	scalar `arfp'=r(p)
	scalar `ardf'=r(df)
	scalar `ardf_r'=r(df_r)
	if "`clopt'"=="" {
		scalar `archi2'=`arf'*`ardf'*(e(N)-`dofminus')/(e(N)-e(rankxx)-`dofminus')
	}
	else {
		scalar `archi2'=`arf'*`ardf'*e(N_clust)/r(df_r)*(e(N)-1)/(e(N)-e(rankxx))
	}
	scalar `archi2p'=chiprob(`ardf',`archi2')

* Check if there is enough room to save results; leave one free.  Allow for overwriting.
* Max is 20-1=19 for Stata 9.0 and earlier, 300-1=299 for Stata 9.1+
	if c(stata_version) < 9.1 {
		local maxest=19
	}
	else {
		local maxest=299
	}
	local vn "`lhs'"
	local plen : length local saverfprefix
	local vlen : length local lhs
	if `plen'+`vlen' > 27 {
		local vlen=27-`plen'
		local vn : permname `vn', length(`vlen')
	}
	local eqname "`saverfprefix'`vn'"
	local eqname : subinstr local eqname "." "_"
	qui estimates dir
	local est_list  "`r(names)'"
	Subtract est_list : "`est_list'" "`eqname'"
	local est_ct : word count `est_list'
	if `est_ct' < `maxest' {
		capture est store `eqname', title("Reduced-form regression: `lhs'")
		return local rfeq "`eqname'"
	}
	else {
di
di in ye "Unable to store reduced-form regression of `lhs'."
di in ye "There may be insufficient room to store results using -estimates store-."
di in ye "Try dropping one or more estimation results using -estimates drop-."
di
	}
	_estimates unhold `tempest'
	return scalar arf=`arf'
	return scalar arfp=`arfp'
	return scalar ardf=`ardf'
	return scalar ardf_r=`ardf_r'
	return scalar archi2=`archi2'
	return scalar archi2p=`archi2p'
end

**************************************************************************************
program define IsStop, sclass
				/* sic, must do tests one-at-a-time, 
				 * 0, may be very large */
	version 8.2
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



*  Remove all tokens in dirt from full
*  Returns "cleaned" full list in cleaned

program define Subtract		/* <cleaned> : <full> <dirt> */
	version 8.2
	args	    cleaned     /*  macro name to hold cleaned list
			*/  colon		/*  ":"
			*/  full		/*  list to be cleaned 
			*/  dirt		/*  tokens to be cleaned from full */
	
	tokenize `dirt'
	local i 1
	while "``i''" != "" {
		local full : subinstr local full "``i''" "", word all
		local i = `i' + 1
	}

	tokenize `full'			/* cleans up extra spaces */
	c_local `cleaned' `*'       
end

program define vecsort		/* Also clears col/row names */
	version 8.2
	args vmat
	tempname hold
	mat `vmat'=`vmat'+J(rowsof(`vmat'),colsof(`vmat'),0)
	local lastcol = colsof(`vmat')
	local i 1
	while `i' < `lastcol' {
		if `vmat'[1,`i'] > `vmat'[1,`i'+1] {
			scalar `hold' = `vmat'[1,`i']
			mat `vmat'[1,`i'] = `vmat'[1,`i'+1]
			mat `vmat'[1,`i'+1] = `hold'
			local i = 1
		}
		else {
			local i = `i' + 1
		}
	}
end

program define matsort
	version 8.2
	args vmat names
	tempname hold
	foreach vn in `names' {
		mat `hold'=nullmat(`hold'), `vmat'[1...,"`vn'"]
	}
	mat `vmat'=`hold'
	mat drop `hold'
	foreach vn in `names' {
		mat `hold'=nullmat(`hold') \ `vmat'["`vn'",1...]
	}
	mat `vmat'=`hold'
end

program define cdsy, rclass
	version 8.2
	syntax , type(string) k2(integer) nendog(integer)

* type() can be ivbias5   (k2<=100, nendog<=3)
*               ivbias10  (ditto)
*               ivbias20  (ditto)
*               ivbias30  (ditto)
*               ivsize10  (k2<=100, nendog<=2)
*               ivsize15  (ditto)
*               ivsize20  (ditto)
*               ivsize25  (ditto)
*               fullrel5  (ditto)
*               fullrel10 (ditto)
*               fullrel20 (ditto)
*               fullrel30 (ditto)
*               fullmax5  (ditto)
*               fullmax10 (ditto)
*               fullmax20 (ditto)
*               fullmax30 (ditto)
*               limlsize10 (ditto)
*               limlsize15 (ditto)
*               limlsize20 (ditto)
*               limlsize25 (ditto)

	tempname temp cv

* Initialize critical value as MV
	scalar `cv'=.

	if "`type'"=="ivbias5" {
		matrix input `temp' = (	/*
	*/	.	,	.	,	.	\ /*
	*/	.	,	.	,	.	\ /*
	*/	13.91	,	.	,	.	\ /*
	*/	16.85	,	11.04	,	.	\ /*
	*/	18.37	,	13.97	,	9.53	\ /*
	*/	19.28	,	15.72	,	12.20	\ /*
	*/	19.86	,	16.88	,	13.95	\ /*
	*/	20.25	,	17.70	,	15.18	\ /*
	*/	20.53	,	18.30	,	16.10	\ /*
	*/	20.74	,	18.76	,	16.80	\ /*
	*/	20.90	,	19.12	,	17.35	\ /*
	*/	21.01	,	19.40	,	17.80	\ /*
	*/	21.10	,	19.64	,	18.17	\ /*
	*/	21.18	,	19.83	,	18.47	\ /*
	*/	21.23	,	19.98	,	18.73	\ /*
	*/	21.28	,	20.12	,	18.94	\ /*
	*/	21.31	,	20.23	,	19.13	\ /*
	*/	21.34	,	20.33	,	19.29	\ /*
	*/	21.36	,	20.41	,	19.44	\ /*
	*/	21.38	,	20.48	,	19.56	\ /*
	*/	21.39	,	20.54	,	19.67	\ /*
	*/	21.40	,	20.60	,	19.77	\ /*
	*/	21.41	,	20.65	,	19.86	\ /*
	*/	21.41	,	20.69	,	19.94	\ /*
	*/	21.42	,	20.73	,	20.01	\ /*
	*/	21.42	,	20.76	,	20.07	\ /*
	*/	21.42	,	20.79	,	20.13	\ /*
	*/	21.42	,	20.82	,	20.18	\ /*
	*/	21.42	,	20.84	,	20.23	\ /*
	*/	21.42	,	20.86	,	20.27	\ /*
	*/	21.41	,	20.88	,	20.31	\ /*
	*/	21.41	,	20.90	,	20.35	\ /*
	*/	21.41	,	20.91	,	20.38	\ /*
	*/	21.40	,	20.93	,	20.41	\ /*
	*/	21.40	,	20.94	,	20.44	\ /*
	*/	21.39	,	20.95	,	20.47	\ /*
	*/	21.39	,	20.96	,	20.49	\ /*
	*/	21.38	,	20.97	,	20.51	\ /*
	*/	21.38	,	20.98	,	20.54	\ /*
	*/	21.37	,	20.99	,	20.56	\ /*
	*/	21.37	,	20.99	,	20.57	\ /*
	*/	21.36	,	21.00	,	20.59	\ /*
	*/	21.35	,	21.00	,	20.61	\ /*
	*/	21.35	,	21.01	,	20.62	\ /*
	*/	21.34	,	21.01	,	20.64	\ /*
	*/	21.34	,	21.02	,	20.65	\ /*
	*/	21.33	,	21.02	,	20.66	\ /*
	*/	21.32	,	21.02	,	20.67	\ /*
	*/	21.32	,	21.03	,	20.68	\ /*
	*/	21.31	,	21.03	,	20.69	\ /*
	*/	21.31	,	21.03	,	20.70	\ /*
	*/	21.30	,	21.03	,	20.71	\ /*
	*/	21.30	,	21.03	,	20.72	\ /*
	*/	21.29	,	21.03	,	20.73	\ /*
	*/	21.28	,	21.03	,	20.73	\ /*
	*/	21.28	,	21.04	,	20.74	\ /*
	*/	21.27	,	21.04	,	20.75	\ /*
	*/	21.27	,	21.04	,	20.75	\ /*
	*/	21.26	,	21.04	,	20.76	\ /*
	*/	21.26	,	21.04	,	20.76	\ /*
	*/	21.25	,	21.04	,	20.77	\ /*
	*/	21.24	,	21.04	,	20.77	\ /*
	*/	21.24	,	21.04	,	20.78	\ /*
	*/	21.23	,	21.04	,	20.78	\ /*
	*/	21.23	,	21.03	,	20.79	\ /*
	*/	21.22	,	21.03	,	20.79	\ /*
	*/	21.22	,	21.03	,	20.79	\ /*
	*/	21.21	,	21.03	,	20.80	\ /*
	*/	21.21	,	21.03	,	20.80	\ /*
	*/	21.20	,	21.03	,	20.80	\ /*
	*/	21.20	,	21.03	,	20.80	\ /*
	*/	21.19	,	21.03	,	20.81	\ /*
	*/	21.19	,	21.03	,	20.81	\ /*
	*/	21.18	,	21.03	,	20.81	\ /*
	*/	21.18	,	21.02	,	20.81	\ /*
	*/	21.17	,	21.02	,	20.82	\ /*
	*/	21.17	,	21.02	,	20.82	\ /*
	*/	21.16	,	21.02	,	20.82	\ /*
	*/	21.16	,	21.02	,	20.82	\ /*
	*/	21.15	,	21.02	,	20.82	\ /*
	*/	21.15	,	21.02	,	20.82	\ /*
	*/	21.15	,	21.02	,	20.83	\ /*
	*/	21.14	,	21.01	,	20.83	\ /*
	*/	21.14	,	21.01	,	20.83	\ /*
	*/	21.13	,	21.01	,	20.83	\ /*
	*/	21.13	,	21.01	,	20.83	\ /*
	*/	21.12	,	21.01	,	20.84	\ /*
	*/	21.12	,	21.01	,	20.84	\ /*
	*/	21.11	,	21.01	,	20.84	\ /*
	*/	21.11	,	21.01	,	20.84	\ /*
	*/	21.10	,	21.00	,	20.84	\ /*
	*/	21.10	,	21.00	,	20.84	\ /*
	*/	21.09	,	21.00	,	20.85	\ /*
	*/	21.09	,	21.00	,	20.85	\ /*
	*/	21.08	,	21.00	,	20.85	\ /*
	*/	21.08	,	21.00	,	20.85	\ /*
	*/	21.07	,	21.00	,	20.85	\ /*
	*/	21.07	,	20.99	,	20.86	\ /*
	*/	21.06	,	20.99	,	20.86	\ /*
	*/	21.06	,	20.99	,	20.86	)

		if `k2'<=100 & `nendog'<=3 {
			scalar `cv'=`temp'[`k2',`nendog']
		}
	}
 

 

 	if "`type'"=="ivbias10" {
		matrix input `temp' = 	/*
	*/	(.,.,.			\	/*
	*/	.,.,.			\	/*
	*/	9.08,.,.		\	/*
	*/	10.27,7.56,.		\	/*
	*/	10.83,8.78,6.61		\	/*
	*/	11.12,9.48,7.77		\	/*
	*/	11.29,9.92,8.5		\	/*
	*/	11.39,10.22,9.01	\	/*
	*/	11.46,10.43,9.37	\	/*
	*/	11.49,10.58,9.64	\	/*
	*/	11.51,10.69,9.85	\	/*
	*/	11.52,10.78,10.01	\	/*
	*/	11.52,10.84,10.14	\	/*
	*/	11.52,10.89,10.25	\	/*
	*/	11.51,10.93,10.33	\	/*
	*/	11.5,10.96,10.41	\	/*
	*/	11.49,10.99,10.47	\	/*
	*/	11.48,11,10.52		\	/*
	*/	11.46,11.02,10.56	\	/*
	*/	11.45,11.03,10.6	\	/*
	*/	11.44,11.04,10.63	\	/*
	*/	11.42,11.05,10.65	\	/*
	*/	11.41,11.05,10.68	\	/*
	*/	11.4,11.05,10.7		\	/*
	*/	11.38,11.06,10.71	\	/*
	*/	11.37,11.06,10.73	\	/*
	*/	11.36,11.06,10.74	\	/*
	*/	11.34,11.05,10.75	\	/*
	*/	11.33,11.05,10.76	\	/*
	*/	11.32,11.05,10.77	\	/*
	*/	11.3,11.05,10.78	\	/*
	*/	11.29,11.05,10.79	\	/*
	*/	11.28,11.04,10.79	\	/*
	*/	11.27,11.04,10.8	\	/*
	*/	11.26,11.04,10.8	\	/*
	*/	11.25,11.03,10.8	\	/*
	*/	11.24,11.03,10.81	\	/*
	*/	11.23,11.02,10.81	\	/*
	*/	11.22,11.02,10.81	\	/*
	*/	11.21,11.02,10.81	\	/*
	*/	11.2,11.01,10.81	\	/*
	*/	11.19,11.01,10.81	\	/*
	*/	11.18,11,10.81		\	/*
	*/	11.17,11,10.81		\	/*
	*/	11.16,10.99,10.81	\	/*
	*/	11.15,10.99,10.81	\	/*
	*/	11.14,10.98,10.81	\	/*
	*/	11.13,10.98,10.81	\	/*
	*/	11.13,10.98,10.81	\	/*
	*/	11.12,10.97,10.81	\	/*
	*/	11.11,10.97,10.81	\	/*
	*/	11.1,10.96,10.81	\	/*
	*/	11.1,10.96,10.81	\	/*
	*/	11.09,10.95,10.81	\	/*
	*/	11.08,10.95,10.81	\	/*
	*/	11.07,10.94,10.8	\	/*
	*/	11.07,10.94,10.8	\	/*
	*/	11.06,10.94,10.8	\	/*
	*/	11.05,10.93,10.8	\	/*
	*/	11.05,10.93,10.8	\	/*
	*/	11.04,10.92,10.8	\	/*
	*/	11.03,10.92,10.79	\	/*
	*/	11.03,10.92,10.79	\	/*
	*/	11.02,10.91,10.79	\	/*
	*/	11.02,10.91,10.79	\	/*
	*/	11.01,10.9,10.79	\	/*
	*/	11,10.9,10.79		\	/*
	*/	11,10.9,10.78		\	/*
	*/	10.99,10.89,10.78	\	/*
	*/	10.99,10.89,10.78	\	/*
	*/	10.98,10.89,10.78	\	/*
	*/	10.98,10.88,10.78	\	/*
	*/	10.97,10.88,10.77	\	/*
	*/	10.97,10.88,10.77	\	/*
	*/	10.96,10.87,10.77	\	/*
	*/	10.96,10.87,10.77	\	/*
	*/	10.95,10.86,10.77	\	/*
	*/	10.95,10.86,10.76	\	/*
	*/	10.94,10.86,10.76	\	/*
	*/	10.94,10.85,10.76	\	/*
	*/	10.93,10.85,10.76	\	/*
	*/	10.93,10.85,10.76	\	/*
	*/	10.92,10.84,10.75	\	/*
	*/	10.92,10.84,10.75	\	/*
	*/	10.91,10.84,10.75	\	/*
	*/	10.91,10.84,10.75	\	/*
	*/	10.91,10.83,10.75	\	/*
	*/	10.9,10.83,10.74	\	/*
	*/	10.9,10.83,10.74	\	/*
	*/	10.89,10.82,10.74	\	/*
	*/	10.89,10.82,10.74	\	/*
	*/	10.89,10.82,10.74	\	/*
	*/	10.88,10.81,10.74	\	/*
	*/	10.88,10.81,10.73	\	/*
	*/	10.87,10.81,10.73	\	/*
	*/	10.87,10.81,10.73	\	/*
	*/	10.87,10.8,10.73	\	/*
	*/	10.86,10.8,10.73	\	/*
	*/	10.86,10.8,10.72	\	/*
	*/	10.86,10.8,10.72)

		if `k2'<=100 & `nendog'<=3 {
			scalar `cv'=`temp'[`k2',`nendog']
		}
	}


	if "`type'"=="ivbias20" {
		matrix input `temp' = (	/*
	*/	.	,	.	,	.	\ /*
	*/	.	,	.	,	.	\ /*
	*/	6.46	,	.	,	.	\ /*
	*/	6.71	,	5.57	,	.	\ /*
	*/	6.77	,	5.91	,	4.99	\ /*
	*/	6.76	,	6.08	,	5.35	\ /*
	*/	6.73	,	6.16	,	5.56	\ /*
	*/	6.69	,	6.20	,	5.69	\ /*
	*/	6.65	,	6.22	,	5.78	\ /*
	*/	6.61	,	6.23	,	5.83	\ /*
	*/	6.56	,	6.23	,	5.87	\ /*
	*/	6.53	,	6.22	,	5.90	\ /*
	*/	6.49	,	6.21	,	5.92	\ /*
	*/	6.45	,	6.20	,	5.93	\ /*
	*/	6.42	,	6.19	,	5.94	\ /*
	*/	6.39	,	6.17	,	5.94	\ /*
	*/	6.36	,	6.16	,	5.94	\ /*
	*/	6.33	,	6.14	,	5.94	\ /*
	*/	6.31	,	6.13	,	5.94	\ /*
	*/	6.28	,	6.11	,	5.93	\ /*
	*/	6.26	,	6.10	,	5.93	\ /*
	*/	6.24	,	6.08	,	5.92	\ /*
	*/	6.22	,	6.07	,	5.92	\ /*
	*/	6.20	,	6.06	,	5.91	\ /*
	*/	6.18	,	6.05	,	5.90	\ /*
	*/	6.16	,	6.03	,	5.90	\ /*
	*/	6.14	,	6.02	,	5.89	\ /*
	*/	6.13	,	6.01	,	5.88	\ /*
	*/	6.11	,	6.00	,	5.88	\ /*
	*/	6.09	,	5.99	,	5.87	\ /*
	*/	6.08	,	5.98	,	5.87	\ /*
	*/	6.07	,	5.97	,	5.86	\ /*
	*/	6.05	,	5.96	,	5.85	\ /*
	*/	6.04	,	5.95	,	5.85	\ /*
	*/	6.03	,	5.94	,	5.84	\ /*
	*/	6.01	,	5.93	,	5.83	\ /*
	*/	6.00	,	5.92	,	5.83	\ /*
	*/	5.99	,	5.91	,	5.82	\ /*
	*/	5.98	,	5.90	,	5.82	\ /*
	*/	5.97	,	5.89	,	5.81	\ /*
	*/	5.96	,	5.89	,	5.80	\ /*
	*/	5.95	,	5.88	,	5.80	\ /*
	*/	5.94	,	5.87	,	5.79	\ /*
	*/	5.93	,	5.86	,	5.79	\ /*
	*/	5.92	,	5.86	,	5.78	\ /*
	*/	5.91	,	5.85	,	5.78	\ /*
	*/	5.91	,	5.84	,	5.77	\ /*
	*/	5.90	,	5.83	,	5.77	\ /*
	*/	5.89	,	5.83	,	5.76	\ /*
	*/	5.88	,	5.82	,	5.76	\ /*
	*/	5.87	,	5.82	,	5.75	\ /*
	*/	5.87	,	5.81	,	5.75	\ /*
	*/	5.86	,	5.80	,	5.74	\ /*
	*/	5.85	,	5.80	,	5.74	\ /*
	*/	5.85	,	5.79	,	5.73	\ /*
	*/	5.84	,	5.79	,	5.73	\ /*
	*/	5.83	,	5.78	,	5.72	\ /*
	*/	5.83	,	5.78	,	5.72	\ /*
	*/	5.82	,	5.77	,	5.72	\ /*
	*/	5.81	,	5.77	,	5.71	\ /*
	*/	5.81	,	5.76	,	5.71	\ /*
	*/	5.80	,	5.76	,	5.70	\ /*
	*/	5.80	,	5.75	,	5.70	\ /*
	*/	5.79	,	5.75	,	5.70	\ /*
	*/	5.78	,	5.74	,	5.69	\ /*
	*/	5.78	,	5.74	,	5.69	\ /*
	*/	5.77	,	5.73	,	5.68	\ /*
	*/	5.77	,	5.73	,	5.68	\ /*
	*/	5.76	,	5.72	,	5.68	\ /*
	*/	5.76	,	5.72	,	5.67	\ /*
	*/	5.75	,	5.72	,	5.67	\ /*
	*/	5.75	,	5.71	,	5.67	\ /*
	*/	5.75	,	5.71	,	5.66	\ /*
	*/	5.74	,	5.70	,	5.66	\ /*
	*/	5.74	,	5.70	,	5.66	\ /*
	*/	5.73	,	5.70	,	5.65	\ /*
	*/	5.73	,	5.69	,	5.65	\ /*
	*/	5.72	,	5.69	,	5.65	\ /*
	*/	5.72	,	5.68	,	5.65	\ /*
	*/	5.71	,	5.68	,	5.64	\ /*
	*/	5.71	,	5.68	,	5.64	\ /*
	*/	5.71	,	5.67	,	5.64	\ /*
	*/	5.70	,	5.67	,	5.63	\ /*
	*/	5.70	,	5.67	,	5.63	\ /*
	*/	5.70	,	5.66	,	5.63	\ /*
	*/	5.69	,	5.66	,	5.62	\ /*
	*/	5.69	,	5.66	,	5.62	\ /*
	*/	5.68	,	5.65	,	5.62	\ /*
	*/	5.68	,	5.65	,	5.62	\ /*
	*/	5.68	,	5.65	,	5.61	\ /*
	*/	5.67	,	5.65	,	5.61	\ /*
	*/	5.67	,	5.64	,	5.61	\ /*
	*/	5.67	,	5.64	,	5.61	\ /*
	*/	5.66	,	5.64	,	5.60	\ /*
	*/	5.66	,	5.63	,	5.60	\ /*
	*/	5.66	,	5.63	,	5.60	\ /*
	*/	5.65	,	5.63	,	5.60	\ /*
	*/	5.65	,	5.63	,	5.59	\ /*
	*/	5.65	,	5.62	,	5.59	\ /*
	*/	5.65	,	5.62	,	5.59	)

		if `k2'<=100 & `nendog'<=3 {
			scalar `cv'=`temp'[`k2',`nendog']
		}
	}

	if "`type'"=="ivbias30" {
		matrix input `temp' = (	/*
	*/	.	,	.	,	.	\ /*
	*/	.	,	.	,	.	\ /*
	*/	5.39	,	.	,	.	\ /*
	*/	5.34	,	4.73	,	.	\ /*
	*/	5.25	,	4.79	,	4.30	\ /*
	*/	5.15	,	4.78	,	4.40	\ /*
	*/	5.07	,	4.76	,	4.44	\ /*
	*/	4.99	,	4.73	,	4.46	\ /*
	*/	4.92	,	4.69	,	4.46	\ /*
	*/	4.86	,	4.66	,	4.45	\ /*
	*/	4.80	,	4.62	,	4.44	\ /*
	*/	4.75	,	4.59	,	4.42	\ /*
	*/	4.71	,	4.56	,	4.41	\ /*
	*/	4.67	,	4.53	,	4.39	\ /*
	*/	4.63	,	4.50	,	4.37	\ /*
	*/	4.59	,	4.48	,	4.36	\ /*
	*/	4.56	,	4.45	,	4.34	\ /*
	*/	4.53	,	4.43	,	4.32	\ /*
	*/	4.51	,	4.41	,	4.31	\ /*
	*/	4.48	,	4.39	,	4.29	\ /*
	*/	4.46	,	4.37	,	4.28	\ /*
	*/	4.43	,	4.35	,	4.27	\ /*
	*/	4.41	,	4.33	,	4.25	\ /*
	*/	4.39	,	4.32	,	4.24	\ /*
	*/	4.37	,	4.30	,	4.23	\ /*
	*/	4.35	,	4.29	,	4.21	\ /*
	*/	4.34	,	4.27	,	4.20	\ /*
	*/	4.32	,	4.26	,	4.19	\ /*
	*/	4.31	,	4.24	,	4.18	\ /*
	*/	4.29	,	4.23	,	4.17	\ /*
	*/	4.28	,	4.22	,	4.16	\ /*
	*/	4.26	,	4.21	,	4.15	\ /*
	*/	4.25	,	4.20	,	4.14	\ /*
	*/	4.24	,	4.19	,	4.13	\ /*
	*/	4.23	,	4.18	,	4.13	\ /*
	*/	4.22	,	4.17	,	4.12	\ /*
	*/	4.20	,	4.16	,	4.11	\ /*
	*/	4.19	,	4.15	,	4.10	\ /*
	*/	4.18	,	4.14	,	4.09	\ /*
	*/	4.17	,	4.13	,	4.09	\ /*
	*/	4.16	,	4.12	,	4.08	\ /*
	*/	4.15	,	4.11	,	4.07	\ /*
	*/	4.15	,	4.11	,	4.07	\ /*
	*/	4.14	,	4.10	,	4.06	\ /*
	*/	4.13	,	4.09	,	4.05	\ /*
	*/	4.12	,	4.08	,	4.05	\ /*
	*/	4.11	,	4.08	,	4.04	\ /*
	*/	4.11	,	4.07	,	4.03	\ /*
	*/	4.10	,	4.06	,	4.03	\ /*
	*/	4.09	,	4.06	,	4.02	\ /*
	*/	4.08	,	4.05	,	4.02	\ /*
	*/	4.08	,	4.05	,	4.01	\ /*
	*/	4.07	,	4.04	,	4.01	\ /*
	*/	4.06	,	4.03	,	4.00	\ /*
	*/	4.06	,	4.03	,	4.00	\ /*
	*/	4.05	,	4.02	,	3.99	\ /*
	*/	4.05	,	4.02	,	3.99	\ /*
	*/	4.04	,	4.01	,	3.98	\ /*
	*/	4.04	,	4.01	,	3.98	\ /*
	*/	4.03	,	4.00	,	3.97	\ /*
	*/	4.02	,	4.00	,	3.97	\ /*
	*/	4.02	,	3.99	,	3.96	\ /*
	*/	4.01	,	3.99	,	3.96	\ /*
	*/	4.01	,	3.98	,	3.96	\ /*
	*/	4.00	,	3.98	,	3.95	\ /*
	*/	4.00	,	3.97	,	3.95	\ /*
	*/	3.99	,	3.97	,	3.94	\ /*
	*/	3.99	,	3.97	,	3.94	\ /*
	*/	3.99	,	3.96	,	3.94	\ /*
	*/	3.98	,	3.96	,	3.93	\ /*
	*/	3.98	,	3.95	,	3.93	\ /*
	*/	3.97	,	3.95	,	3.93	\ /*
	*/	3.97	,	3.95	,	3.92	\ /*
	*/	3.96	,	3.94	,	3.92	\ /*
	*/	3.96	,	3.94	,	3.92	\ /*
	*/	3.96	,	3.93	,	3.91	\ /*
	*/	3.95	,	3.93	,	3.91	\ /*
	*/	3.95	,	3.93	,	3.91	\ /*
	*/	3.95	,	3.92	,	3.90	\ /*
	*/	3.94	,	3.92	,	3.90	\ /*
	*/	3.94	,	3.92	,	3.90	\ /*
	*/	3.93	,	3.91	,	3.89	\ /*
	*/	3.93	,	3.91	,	3.89	\ /*
	*/	3.93	,	3.91	,	3.89	\ /*
	*/	3.92	,	3.91	,	3.89	\ /*
	*/	3.92	,	3.90	,	3.88	\ /*
	*/	3.92	,	3.90	,	3.88	\ /*
	*/	3.91	,	3.90	,	3.88	\ /*
	*/	3.91	,	3.89	,	3.87	\ /*
	*/	3.91	,	3.89	,	3.87	\ /*
	*/	3.91	,	3.89	,	3.87	\ /*
	*/	3.90	,	3.89	,	3.87	\ /*
	*/	3.90	,	3.88	,	3.86	\ /*
	*/	3.90	,	3.88	,	3.86	\ /*
	*/	3.89	,	3.88	,	3.86	\ /*
	*/	3.89	,	3.87	,	3.86	\ /*
	*/	3.89	,	3.87	,	3.85	\ /*
	*/	3.89	,	3.87	,	3.85	\ /*
	*/	3.88	,	3.87	,	3.85	\ /*
	*/	3.88	,	3.86	,	3.85	)
	
		if `k2'<=100 & `nendog'<=3 {
			scalar `cv'=`temp'[`k2',`nendog']
		}
	}


	if "`type'"=="ivsize10" {
		matrix input `temp' = /*
	*/	(16.38,.	\	/*
	*/	19.93,7.03	\	/*
	*/	22.3,13.43	\	/*
	*/	24.58,16.87	\	/*
	*/	26.87,19.45	\	/*
	*/	29.18,21.68	\	/*
	*/	31.5,23.72	\	/*
	*/	33.84,25.64	\	/*
	*/	36.19,27.51	\	/*
	*/	38.54,29.32	\	/*
	*/	40.9,31.11	\	/*
	*/	43.27,32.88	\	/*
	*/	45.64,34.62	\	/*
	*/	48.01,36.36	\	/*
	*/	50.39,38.08	\	/*
	*/	52.77,39.8	\	/*
	*/	55.15,41.51	\	/*
	*/	57.53,43.22	\	/*
	*/	59.92,44.92	\	/*
	*/	62.3,46.62	\	/*
	*/	64.69,48.31	\	/*
	*/	67.07,50.01	\	/*
	*/	69.46,51.7	\	/*
	*/	71.85,53.39	\	/*
	*/	74.24,55.07	\	/*
	*/	76.62,56.76	\	/*
	*/	79.01,58.45	\	/*
	*/	81.4,60.13	\	/*
	*/	83.79,61.82	\	/*
	*/	86.17,63.51	\	/*
	*/	88.56,65.19	\	/*
	*/	90.95,66.88	\	/*
	*/	93.33,68.56	\	/*
	*/	95.72,70.25	\	/*
	*/	98.11,71.94	\	/*
	*/	100.5,73.62	\	/*
	*/	102.88,75.31	\	/*
	*/	105.27,76.99	\	/*
	*/	107.66,78.68	\	/*
	*/	110.04,80.37	\	/*
	*/	112.43,82.05	\	/*
	*/	114.82,83.74	\	/*
	*/	117.21,85.42	\	/*
	*/	119.59,87.11	\	/*
	*/	121.98,88.8	\	/*
	*/	124.37,90.48	\	/*
	*/	126.75,92.17	\	/*
	*/	129.14,93.85	\	/*
	*/	131.53,95.54	\	/*
	*/	133.92,97.23	\	/*
	*/	136.3,98.91	\	/*
	*/	138.69,100.6	\	/*
	*/	141.08,102.29	\	/*
	*/	143.47,103.97	\	/*
	*/	145.85,105.66	\	/*
	*/	148.24,107.34	\	/*
	*/	150.63,109.03	\	/*
	*/	153.01,110.72	\	/*
	*/	155.4,112.4	\	/*
	*/	157.79,114.09	\	/*
	*/	160.18,115.77	\	/*
	*/	162.56,117.46	\	/*
	*/	164.95,119.15	\	/*
	*/	167.34,120.83	\	/*
	*/	169.72,122.52	\	/*
	*/	172.11,124.2	\	/*
	*/	174.5,125.89	\	/*
	*/	176.89,127.58	\	/*
	*/	179.27,129.26	\	/*
	*/	181.66,130.95	\	/*
	*/	184.05,132.63	\	/*
	*/	186.44,134.32	\	/*
	*/	188.82,136.01	\	/*
	*/	191.21,137.69	\	/*
	*/	193.6,139.38	\	/*
	*/	195.98,141.07	\	/*
	*/	198.37,142.75	\	/*
	*/	200.76,144.44	\	/*
	*/	203.15,146.12	\	/*
	*/	205.53,147.81	\	/*
	*/	207.92,149.5	\	/*
	*/	210.31,151.18	\	/*
	*/	212.69,152.87	\	/*
	*/	215.08,154.55	\	/*
	*/	217.47,156.24	\	/*
	*/	219.86,157.93	\	/*
	*/	222.24,159.61	\	/*
	*/	224.63,161.3	\	/*
	*/	227.02,162.98	\	/*
	*/	229.41,164.67	\	/*
	*/	231.79,166.36	\	/*
	*/	234.18,168.04	\	/*
	*/	236.57,169.73	\	/*
	*/	238.95,171.41	\	/*
	*/	241.34,173.1	\	/*
	*/	243.73,174.79	\	/*
	*/	246.12,176.47	\	/*
	*/	248.5,178.16	\	/*
	*/	250.89,179.84	\	/*
	*/	253.28,181.53)

		if `k2'<=100 & `nendog'<=2 {
			scalar `cv'=`temp'[`k2',`nendog']
		}
	}

	if "`type'"=="ivsize15" {
		matrix input `temp' = ( /*
	*/	8.96	,	.	\ /*
	*/	11.59	,	4.58	\ /*
	*/	12.83	,	8.18	\ /*
	*/	13.96	,	9.93	\ /*
	*/	15.09	,	11.22	\ /*
	*/	16.23	,	12.33	\ /*
	*/	17.38	,	13.34	\ /*
	*/	18.54	,	14.31	\ /*
	*/	19.71	,	15.24	\ /*
	*/	20.88	,	16.16	\ /*
	*/	22.06	,	17.06	\ /*
	*/	23.24	,	17.95	\ /*
	*/	24.42	,	18.84	\ /*
	*/	25.61	,	19.72	\ /*
	*/	26.80	,	20.60	\ /*
	*/	27.99	,	21.48	\ /*
	*/	29.19	,	22.35	\ /*
	*/	30.38	,	23.22	\ /*
	*/	31.58	,	24.09	\ /*
	*/	32.77	,	24.96	\ /*
	*/	33.97	,	25.82	\ /*
	*/	35.17	,	26.69	\ /*
	*/	36.37	,	27.56	\ /*
	*/	37.57	,	28.42	\ /*
	*/	38.77	,	29.29	\ /*
	*/	39.97	,	30.15	\ /*
	*/	41.17	,	31.02	\ /*
	*/	42.37	,	31.88	\ /*
	*/	43.57	,	32.74	\ /*
	*/	44.78	,	33.61	\ /*
	*/	45.98	,	34.47	\ /*
	*/	47.18	,	35.33	\ /*
	*/	48.38	,	36.19	\ /*
	*/	49.59	,	37.06	\ /*
	*/	50.79	,	37.92	\ /*
	*/	51.99	,	38.78	\ /*
	*/	53.19	,	39.64	\ /*
	*/	54.40	,	40.50	\ /*
	*/	55.60	,	41.37	\ /*
	*/	56.80	,	42.23	\ /*
	*/	58.01	,	43.09	\ /*
	*/	59.21	,	43.95	\ /*
	*/	60.41	,	44.81	\ /*
	*/	61.61	,	45.68	\ /*
	*/	62.82	,	46.54	\ /*
	*/	64.02	,	47.40	\ /*
	*/	65.22	,	48.26	\ /*
	*/	66.42	,	49.12	\ /*
	*/	67.63	,	49.99	\ /*
	*/	68.83	,	50.85	\ /*
	*/	70.03	,	51.71	\ /*
	*/	71.24	,	52.57	\ /*
	*/	72.44	,	53.43	\ /*
	*/	73.64	,	54.30	\ /*
	*/	74.84	,	55.16	\ /*
	*/	76.05	,	56.02	\ /*
	*/	77.25	,	56.88	\ /*
	*/	78.45	,	57.74	\ /*
	*/	79.66	,	58.61	\ /*
	*/	80.86	,	59.47	\ /*
	*/	82.06	,	60.33	\ /*
	*/	83.26	,	61.19	\ /*
	*/	84.47	,	62.05	\ /*
	*/	85.67	,	62.92	\ /*
	*/	86.87	,	63.78	\ /*
	*/	88.07	,	64.64	\ /*
	*/	89.28	,	65.50	\ /*
	*/	90.48	,	66.36	\ /*
	*/	91.68	,	67.22	\ /*
	*/	92.89	,	68.09	\ /*
	*/	94.09	,	68.95	\ /*
	*/	95.29	,	69.81	\ /*
	*/	96.49	,	70.67	\ /*
	*/	97.70	,	71.53	\ /*
	*/	98.90	,	72.40	\ /*
	*/	100.10	,	73.26	\ /*
	*/	101.30	,	74.12	\ /*
	*/	102.51	,	74.98	\ /*
	*/	103.71	,	75.84	\ /*
	*/	104.91	,	76.71	\ /*
	*/	106.12	,	77.57	\ /*
	*/	107.32	,	78.43	\ /*
	*/	108.52	,	79.29	\ /*
	*/	109.72	,	80.15	\ /*
	*/	110.93	,	81.02	\ /*
	*/	112.13	,	81.88	\ /*
	*/	113.33	,	82.74	\ /*
	*/	114.53	,	83.60	\ /*
	*/	115.74	,	84.46	\ /*
	*/	116.94	,	85.33	\ /*
	*/	118.14	,	86.19	\ /*
	*/	119.35	,	87.05	\ /*
	*/	120.55	,	87.91	\ /*
	*/	121.75	,	88.77	\ /*
	*/	122.95	,	89.64	\ /*
	*/	124.16	,	90.50	\ /*
	*/	125.36	,	91.36	\ /*
	*/	126.56	,	92.22	\ /*
	*/	127.76	,	93.08	\ /*
	*/	128.97	,	93.95	)
	
		if `k2'<=100 & `nendog'<=2 {
			scalar `cv'=`temp'[`k2',`nendog']
		}
	}

	if "`type'"=="ivsize20" {
		matrix input `temp' = ( /*
	*/	6.66	,	.	\ /*
	*/	8.75	,	3.95	\ /*
	*/	9.54	,	6.40	\ /*
	*/	10.26	,	7.54	\ /*
	*/	10.98	,	8.38	\ /*
	*/	11.72	,	9.10	\ /*
	*/	12.48	,	9.77	\ /*
	*/	13.24	,	10.41	\ /*
	*/	14.01	,	11.03	\ /*
	*/	14.78	,	11.65	\ /*
	*/	15.56	,	12.25	\ /*
	*/	16.35	,	12.86	\ /*
	*/	17.14	,	13.45	\ /*
	*/	17.93	,	14.05	\ /*
	*/	18.72	,	14.65	\ /*
	*/	19.51	,	15.24	\ /*
	*/	20.31	,	15.83	\ /*
	*/	21.10	,	16.42	\ /*
	*/	21.90	,	17.02	\ /*
	*/	22.70	,	17.61	\ /*
	*/	23.50	,	18.20	\ /*
	*/	24.30	,	18.79	\ /*
	*/	25.10	,	19.38	\ /*
	*/	25.90	,	19.97	\ /*
	*/	26.71	,	20.56	\ /*
	*/	27.51	,	21.15	\ /*
	*/	28.31	,	21.74	\ /*
	*/	29.12	,	22.33	\ /*
	*/	29.92	,	22.92	\ /*
	*/	30.72	,	23.51	\ /*
	*/	31.53	,	24.10	\ /*
	*/	32.33	,	24.69	\ /*
	*/	33.14	,	25.28	\ /*
	*/	33.94	,	25.87	\ /*
	*/	34.75	,	26.46	\ /*
	*/	35.55	,	27.05	\ /*
	*/	36.36	,	27.64	\ /*
	*/	37.17	,	28.23	\ /*
	*/	37.97	,	28.82	\ /*
	*/	38.78	,	29.41	\ /*
	*/	39.58	,	30.00	\ /*
	*/	40.39	,	30.59	\ /*
	*/	41.20	,	31.18	\ /*
	*/	42.00	,	31.77	\ /*
	*/	42.81	,	32.36	\ /*
	*/	43.62	,	32.95	\ /*
	*/	44.42	,	33.54	\ /*
	*/	45.23	,	34.13	\ /*
	*/	46.03	,	34.72	\ /*
	*/	46.84	,	35.31	\ /*
	*/	47.65	,	35.90	\ /*
	*/	48.45	,	36.49	\ /*
	*/	49.26	,	37.08	\ /*
	*/	50.06	,	37.67	\ /*
	*/	50.87	,	38.26	\ /*
	*/	51.68	,	38.85	\ /*
	*/	52.48	,	39.44	\ /*
	*/	53.29	,	40.02	\ /*
	*/	54.09	,	40.61	\ /*
	*/	54.90	,	41.20	\ /*
	*/	55.71	,	41.79	\ /*
	*/	56.51	,	42.38	\ /*
	*/	57.32	,	42.97	\ /*
	*/	58.13	,	43.56	\ /*
	*/	58.93	,	44.15	\ /*
	*/	59.74	,	44.74	\ /*
	*/	60.54	,	45.33	\ /*
	*/	61.35	,	45.92	\ /*
	*/	62.16	,	46.51	\ /*
	*/	62.96	,	47.10	\ /*
	*/	63.77	,	47.69	\ /*
	*/	64.57	,	48.28	\ /*
	*/	65.38	,	48.87	\ /*
	*/	66.19	,	49.46	\ /*
	*/	66.99	,	50.05	\ /*
	*/	67.80	,	50.64	\ /*
	*/	68.60	,	51.23	\ /*
	*/	69.41	,	51.82	\ /*
	*/	70.22	,	52.41	\ /*
	*/	71.02	,	53.00	\ /*
	*/	71.83	,	53.59	\ /*
	*/	72.64	,	54.18	\ /*
	*/	73.44	,	54.77	\ /*
	*/	74.25	,	55.36	\ /*
	*/	75.05	,	55.95	\ /*
	*/	75.86	,	56.54	\ /*
	*/	76.67	,	57.13	\ /*
	*/	77.47	,	57.72	\ /*
	*/	78.28	,	58.31	\ /*
	*/	79.08	,	58.90	\ /*
	*/	79.89	,	59.49	\ /*
	*/	80.70	,	60.08	\ /*
	*/	81.50	,	60.67	\ /*
	*/	82.31	,	61.26	\ /*
	*/	83.12	,	61.85	\ /*
	*/	83.92	,	62.44	\ /*
	*/	84.73	,	63.03	\ /*
	*/	85.53	,	63.62	\ /*
	*/	86.34	,	64.21	\ /*
	*/	87.15	,	64.80	)

		if `k2'<=100 & `nendog'<=2 {
			scalar `cv'=`temp'[`k2',`nendog']
		}
	}

	if "`type'"=="ivsize25" {
		matrix input `temp' = ( /*
	*/	5.53	,	.	\ /*
	*/	7.25	,	3.63	\ /*
	*/	7.80	,	5.45	\ /*
	*/	8.31	,	6.28	\ /*
	*/	8.84	,	6.89	\ /*
	*/	9.38	,	7.42	\ /*
	*/	9.93	,	7.91	\ /*
	*/	10.50	,	8.39	\ /*
	*/	11.07	,	8.85	\ /*
	*/	11.65	,	9.31	\ /*
	*/	12.23	,	9.77	\ /*
	*/	12.82	,	10.22	\ /*
	*/	13.41	,	10.68	\ /*
	*/	14.00	,	11.13	\ /*
	*/	14.60	,	11.58	\ /*
	*/	15.19	,	12.03	\ /*
	*/	15.79	,	12.49	\ /*
	*/	16.39	,	12.94	\ /*
	*/	16.99	,	13.39	\ /*
	*/	17.60	,	13.84	\ /*
	*/	18.20	,	14.29	\ /*
	*/	18.80	,	14.74	\ /*
	*/	19.41	,	15.19	\ /*
	*/	20.01	,	15.64	\ /*
	*/	20.61	,	16.10	\ /*
	*/	21.22	,	16.55	\ /*
	*/	21.83	,	17.00	\ /*
	*/	22.43	,	17.45	\ /*
	*/	23.04	,	17.90	\ /*
	*/	23.65	,	18.35	\ /*
	*/	24.25	,	18.81	\ /*
	*/	24.86	,	19.26	\ /*
	*/	25.47	,	19.71	\ /*
	*/	26.08	,	20.16	\ /*
	*/	26.68	,	20.61	\ /*
	*/	27.29	,	21.06	\ /*
	*/	27.90	,	21.52	\ /*
	*/	28.51	,	21.97	\ /*
	*/	29.12	,	22.42	\ /*
	*/	29.73	,	22.87	\ /*
	*/	30.33	,	23.32	\ /*
	*/	30.94	,	23.78	\ /*
	*/	31.55	,	24.23	\ /*
	*/	32.16	,	24.68	\ /*
	*/	32.77	,	25.13	\ /*
	*/	33.38	,	25.58	\ /*
	*/	33.99	,	26.04	\ /*
	*/	34.60	,	26.49	\ /*
	*/	35.21	,	26.94	\ /*
	*/	35.82	,	27.39	\ /*
	*/	36.43	,	27.85	\ /*
	*/	37.04	,	28.30	\ /*
	*/	37.65	,	28.75	\ /*
	*/	38.25	,	29.20	\ /*
	*/	38.86	,	29.66	\ /*
	*/	39.47	,	30.11	\ /*
	*/	40.08	,	30.56	\ /*
	*/	40.69	,	31.01	\ /*
	*/	41.30	,	31.47	\ /*
	*/	41.91	,	31.92	\ /*
	*/	42.52	,	32.37	\ /*
	*/	43.13	,	32.82	\ /*
	*/	43.74	,	33.27	\ /*
	*/	44.35	,	33.73	\ /*
	*/	44.96	,	34.18	\ /*
	*/	45.57	,	34.63	\ /*
	*/	46.18	,	35.08	\ /*
	*/	46.78	,	35.54	\ /*
	*/	47.39	,	35.99	\ /*
	*/	48.00	,	36.44	\ /*
	*/	48.61	,	36.89	\ /*
	*/	49.22	,	37.35	\ /*
	*/	49.83	,	37.80	\ /*
	*/	50.44	,	38.25	\ /*
	*/	51.05	,	38.70	\ /*
	*/	51.66	,	39.16	\ /*
	*/	52.27	,	39.61	\ /*
	*/	52.88	,	40.06	\ /*
	*/	53.49	,	40.51	\ /*
	*/	54.10	,	40.96	\ /*
	*/	54.71	,	41.42	\ /*
	*/	55.32	,	41.87	\ /*
	*/	55.92	,	42.32	\ /*
	*/	56.53	,	42.77	\ /*
	*/	57.14	,	43.23	\ /*
	*/	57.75	,	43.68	\ /*
	*/	58.36	,	44.13	\ /*
	*/	58.97	,	44.58	\ /*
	*/	59.58	,	45.04	\ /*
	*/	60.19	,	45.49	\ /*
	*/	60.80	,	45.94	\ /*
	*/	61.41	,	46.39	\ /*
	*/	62.02	,	46.85	\ /*
	*/	62.63	,	47.30	\ /*
	*/	63.24	,	47.75	\ /*
	*/	63.85	,	48.20	\ /*
	*/	64.45	,	48.65	\ /*
	*/	65.06	,	49.11	\ /*
	*/	65.67	,	49.56	\ /*
	*/	66.28	,	50.01	)

		if `k2'<=100 & `nendog'<=2 {
			scalar `cv'=`temp'[`k2',`nendog']
		}
	}
	
	if "`type'"=="fullrel5" {
		matrix input `temp' = ( /*
	*/	24.09	,	.	\ /*
	*/	13.46	,	15.50	\ /*
	*/	9.61	,	10.83	\ /*
	*/	7.63	,	8.53	\ /*
	*/	6.42	,	7.16	\ /*
	*/	5.61	,	6.24	\ /*
	*/	5.02	,	5.59	\ /*
	*/	4.58	,	5.10	\ /*
	*/	4.23	,	4.71	\ /*
	*/	3.96	,	4.41	\ /*
	*/	3.73	,	4.15	\ /*
	*/	3.54	,	3.94	\ /*
	*/	3.38	,	3.76	\ /*
	*/	3.24	,	3.60	\ /*
	*/	3.12	,	3.47	\ /*
	*/	3.01	,	3.35	\ /*
	*/	2.92	,	3.24	\ /*
	*/	2.84	,	3.15	\ /*
	*/	2.76	,	3.06	\ /*
	*/	2.69	,	2.98	\ /*
	*/	2.63	,	2.91	\ /*
	*/	2.58	,	2.85	\ /*
	*/	2.52	,	2.79	\ /*
	*/	2.48	,	2.73	\ /*
	*/	2.43	,	2.68	\ /*
	*/	2.39	,	2.63	\ /*
	*/	2.36	,	2.59	\ /*
	*/	2.32	,	2.55	\ /*
	*/	2.29	,	2.51	\ /*
	*/	2.26	,	2.47	\ /*
	*/	2.23	,	2.44	\ /*
	*/	2.20	,	2.41	\ /*
	*/	2.18	,	2.37	\ /*
	*/	2.16	,	2.35	\ /*
	*/	2.13	,	2.32	\ /*
	*/	2.11	,	2.29	\ /*
	*/	2.09	,	2.27	\ /*
	*/	2.07	,	2.24	\ /*
	*/	2.05	,	2.22	\ /*
	*/	2.04	,	2.20	\ /*
	*/	2.02	,	2.18	\ /*
	*/	2.00	,	2.16	\ /*
	*/	1.99	,	2.14	\ /*
	*/	1.97	,	2.12	\ /*
	*/	1.96	,	2.10	\ /*
	*/	1.94	,	2.09	\ /*
	*/	1.93	,	2.07	\ /*
	*/	1.92	,	2.05	\ /*
	*/	1.91	,	2.04	\ /*
	*/	1.89	,	2.02	\ /*
	*/	1.88	,	2.01	\ /*
	*/	1.87	,	2.00	\ /*
	*/	1.86	,	1.98	\ /*
	*/	1.85	,	1.97	\ /*
	*/	1.84	,	1.96	\ /*
	*/	1.83	,	1.95	\ /*
	*/	1.82	,	1.94	\ /*
	*/	1.81	,	1.92	\ /*
	*/	1.80	,	1.91	\ /*
	*/	1.79	,	1.90	\ /*
	*/	1.79	,	1.89	\ /*
	*/	1.78	,	1.88	\ /*
	*/	1.77	,	1.87	\ /*
	*/	1.76	,	1.87	\ /*
	*/	1.75	,	1.86	\ /*
	*/	1.75	,	1.85	\ /*
	*/	1.74	,	1.84	\ /*
	*/	1.73	,	1.83	\ /*
	*/	1.72	,	1.83	\ /*
	*/	1.72	,	1.82	\ /*
	*/	1.71	,	1.81	\ /*
	*/	1.70	,	1.80	\ /*
	*/	1.70	,	1.80	\ /*
	*/	1.69	,	1.79	\ /*
	*/	1.68	,	1.79	\ /*
	*/	1.68	,	1.78	\ /*
	*/	1.67	,	1.77	\ /*
	*/	1.67	,	1.77	\ /*
	*/	1.66	,	1.76	\ /*
	*/	1.65	,	1.76	\ /*
	*/	1.65	,	1.75	\ /*
	*/	1.64	,	1.75	\ /*
	*/	1.64	,	1.74	\ /*
	*/	1.63	,	1.74	\ /*
	*/	1.63	,	1.73	\ /*
	*/	1.62	,	1.73	\ /*
	*/	1.61	,	1.73	\ /*
	*/	1.61	,	1.72	\ /*
	*/	1.60	,	1.72	\ /*
	*/	1.60	,	1.71	\ /*
	*/	1.59	,	1.71	\ /*
	*/	1.59	,	1.71	\ /*
	*/	1.58	,	1.71	\ /*
	*/	1.58	,	1.70	\ /*
	*/	1.57	,	1.70	\ /*
	*/	1.57	,	1.70	\ /*
	*/	1.56	,	1.69	\ /*
	*/	1.56	,	1.69	\ /*
	*/	1.55	,	1.69	\ /*
	*/	1.55	,	1.69	)

		if `k2'<=100 & `nendog'<=2 {
			scalar `cv'=`temp'[`k2',`nendog']
		}
	}
	
	if "`type'"=="fullrel10" {
		matrix input `temp' = ( /*
	*/	19.36	,	.	\ /*
	*/	10.89	,	12.55	\ /*
	*/	7.90	,	8.96	\ /*
	*/	6.37	,	7.15	\ /*
	*/	5.44	,	6.07	\ /*
	*/	4.81	,	5.34	\ /*
	*/	4.35	,	4.82	\ /*
	*/	4.01	,	4.43	\ /*
	*/	3.74	,	4.12	\ /*
	*/	3.52	,	3.87	\ /*
	*/	3.34	,	3.67	\ /*
	*/	3.19	,	3.49	\ /*
	*/	3.06	,	3.35	\ /*
	*/	2.95	,	3.22	\ /*
	*/	2.85	,	3.11	\ /*
	*/	2.76	,	3.01	\ /*
	*/	2.69	,	2.92	\ /*
	*/	2.62	,	2.84	\ /*
	*/	2.56	,	2.77	\ /*
	*/	2.50	,	2.71	\ /*
	*/	2.45	,	2.65	\ /*
	*/	2.40	,	2.60	\ /*
	*/	2.36	,	2.55	\ /*
	*/	2.32	,	2.50	\ /*
	*/	2.28	,	2.46	\ /*
	*/	2.24	,	2.42	\ /*
	*/	2.21	,	2.38	\ /*
	*/	2.18	,	2.35	\ /*
	*/	2.15	,	2.31	\ /*
	*/	2.12	,	2.28	\ /*
	*/	2.10	,	2.25	\ /*
	*/	2.07	,	2.23	\ /*
	*/	2.05	,	2.20	\ /*
	*/	2.03	,	2.17	\ /*
	*/	2.01	,	2.15	\ /*
	*/	1.99	,	2.13	\ /*
	*/	1.97	,	2.11	\ /*
	*/	1.95	,	2.09	\ /*
	*/	1.93	,	2.07	\ /*
	*/	1.92	,	2.05	\ /*
	*/	1.90	,	2.03	\ /*
	*/	1.88	,	2.01	\ /*
	*/	1.87	,	2.00	\ /*
	*/	1.86	,	1.98	\ /*
	*/	1.84	,	1.96	\ /*
	*/	1.83	,	1.95	\ /*
	*/	1.82	,	1.93	\ /*
	*/	1.81	,	1.92	\ /*
	*/	1.79	,	1.91	\ /*
	*/	1.78	,	1.89	\ /*
	*/	1.77	,	1.88	\ /*
	*/	1.76	,	1.87	\ /*
	*/	1.75	,	1.86	\ /*
	*/	1.74	,	1.85	\ /*
	*/	1.73	,	1.84	\ /*
	*/	1.72	,	1.83	\ /*
	*/	1.71	,	1.82	\ /*
	*/	1.70	,	1.81	\ /*
	*/	1.70	,	1.80	\ /*
	*/	1.69	,	1.79	\ /*
	*/	1.68	,	1.78	\ /*
	*/	1.67	,	1.77	\ /*
	*/	1.67	,	1.76	\ /*
	*/	1.66	,	1.75	\ /*
	*/	1.65	,	1.75	\ /*
	*/	1.64	,	1.74	\ /*
	*/	1.64	,	1.73	\ /*
	*/	1.63	,	1.72	\ /*
	*/	1.63	,	1.72	\ /*
	*/	1.62	,	1.71	\ /*
	*/	1.61	,	1.70	\ /*
	*/	1.61	,	1.70	\ /*
	*/	1.60	,	1.69	\ /*
	*/	1.60	,	1.68	\ /*
	*/	1.59	,	1.68	\ /*
	*/	1.59	,	1.67	\ /*
	*/	1.58	,	1.67	\ /*
	*/	1.58	,	1.66	\ /*
	*/	1.57	,	1.66	\ /*
	*/	1.57	,	1.65	\ /*
	*/	1.56	,	1.65	\ /*
	*/	1.56	,	1.64	\ /*
	*/	1.56	,	1.64	\ /*
	*/	1.55	,	1.63	\ /*
	*/	1.55	,	1.63	\ /*
	*/	1.54	,	1.62	\ /*
	*/	1.54	,	1.62	\ /*
	*/	1.54	,	1.62	\ /*
	*/	1.53	,	1.61	\ /*
	*/	1.53	,	1.61	\ /*
	*/	1.53	,	1.61	\ /*
	*/	1.52	,	1.60	\ /*
	*/	1.52	,	1.60	\ /*
	*/	1.52	,	1.60	\ /*
	*/	1.52	,	1.59	\ /*
	*/	1.51	,	1.59	\ /*
	*/	1.51	,	1.59	\ /*
	*/	1.51	,	1.59	\ /*
	*/	1.51	,	1.58	\ /*
	*/	1.50	,	1.58	)
		if `k2'<=100 & `nendog'<=2 {
			scalar `cv'=`temp'[`k2',`nendog']
		}
	}
	
	if "`type'"=="fullrel20" {
		matrix input `temp' = ( /*
	*/	15.64	,	.	\ /*
	*/	9.00	,	9.72	\ /*
	*/	6.61	,	7.18	\ /*
	*/	5.38	,	5.85	\ /*
	*/	4.62	,	5.04	\ /*
	*/	4.11	,	4.48	\ /*
	*/	3.75	,	4.08	\ /*
	*/	3.47	,	3.77	\ /*
	*/	3.25	,	3.53	\ /*
	*/	3.07	,	3.33	\ /*
	*/	2.92	,	3.17	\ /*
	*/	2.80	,	3.04	\ /*
	*/	2.70	,	2.92	\ /*
	*/	2.61	,	2.82	\ /*
	*/	2.53	,	2.73	\ /*
	*/	2.46	,	2.65	\ /*
	*/	2.39	,	2.58	\ /*
	*/	2.34	,	2.52	\ /*
	*/	2.29	,	2.46	\ /*
	*/	2.24	,	2.41	\ /*
	*/	2.20	,	2.36	\ /*
	*/	2.16	,	2.32	\ /*
	*/	2.13	,	2.28	\ /*
	*/	2.10	,	2.24	\ /*
	*/	2.06	,	2.21	\ /*
	*/	2.04	,	2.18	\ /*
	*/	2.01	,	2.15	\ /*
	*/	1.99	,	2.12	\ /*
	*/	1.96	,	2.09	\ /*
	*/	1.94	,	2.07	\ /*
	*/	1.92	,	2.04	\ /*
	*/	1.90	,	2.02	\ /*
	*/	1.88	,	2.00	\ /*
	*/	1.87	,	1.98	\ /*
	*/	1.85	,	1.96	\ /*
	*/	1.83	,	1.94	\ /*
	*/	1.82	,	1.93	\ /*
	*/	1.80	,	1.91	\ /*
	*/	1.79	,	1.89	\ /*
	*/	1.78	,	1.88	\ /*
	*/	1.76	,	1.86	\ /*
	*/	1.75	,	1.85	\ /*
	*/	1.74	,	1.84	\ /*
	*/	1.73	,	1.82	\ /*
	*/	1.72	,	1.81	\ /*
	*/	1.71	,	1.80	\ /*
	*/	1.70	,	1.79	\ /*
	*/	1.69	,	1.78	\ /*
	*/	1.68	,	1.77	\ /*
	*/	1.67	,	1.76	\ /*
	*/	1.66	,	1.75	\ /*
	*/	1.65	,	1.74	\ /*
	*/	1.65	,	1.73	\ /*
	*/	1.64	,	1.72	\ /*
	*/	1.63	,	1.71	\ /*
	*/	1.62	,	1.70	\ /*
	*/	1.62	,	1.69	\ /*
	*/	1.61	,	1.68	\ /*
	*/	1.60	,	1.68	\ /*
	*/	1.60	,	1.67	\ /*
	*/	1.59	,	1.66	\ /*
	*/	1.58	,	1.65	\ /*
	*/	1.58	,	1.65	\ /*
	*/	1.57	,	1.64	\ /*
	*/	1.57	,	1.63	\ /*
	*/	1.56	,	1.63	\ /*
	*/	1.56	,	1.62	\ /*
	*/	1.55	,	1.62	\ /*
	*/	1.55	,	1.61	\ /*
	*/	1.54	,	1.60	\ /*
	*/	1.54	,	1.60	\ /*
	*/	1.53	,	1.59	\ /*
	*/	1.53	,	1.59	\ /*
	*/	1.52	,	1.58	\ /*
	*/	1.52	,	1.58	\ /*
	*/	1.51	,	1.57	\ /*
	*/	1.51	,	1.57	\ /*
	*/	1.51	,	1.56	\ /*
	*/	1.50	,	1.56	\ /*
	*/	1.50	,	1.56	\ /*
	*/	1.49	,	1.55	\ /*
	*/	1.49	,	1.55	\ /*
	*/	1.49	,	1.54	\ /*
	*/	1.48	,	1.54	\ /*
	*/	1.48	,	1.54	\ /*
	*/	1.48	,	1.53	\ /*
	*/	1.47	,	1.53	\ /*
	*/	1.47	,	1.53	\ /*
	*/	1.47	,	1.52	\ /*
	*/	1.46	,	1.52	\ /*
	*/	1.46	,	1.52	\ /*
	*/	1.46	,	1.51	\ /*
	*/	1.46	,	1.51	\ /*
	*/	1.45	,	1.51	\ /*
	*/	1.45	,	1.50	\ /*
	*/	1.45	,	1.50	\ /*
	*/	1.45	,	1.50	\ /*
	*/	1.44	,	1.50	\ /*
	*/	1.44	,	1.49	\ /*
	*/	1.44	,	1.49	)
		if `k2'<=100 & `nendog'<=2 {
			scalar `cv'=`temp'[`k2',`nendog']
		}
	}

	if "`type'"=="fullrel30" {
		matrix input `temp' = ( /*
	*/	12.71	,	.	\ /*
	*/	7.49	,	8.03	\ /*
	*/	5.60	,	6.15	\ /*
	*/	4.63	,	5.10	\ /*
	*/	4.03	,	4.44	\ /*
	*/	3.63	,	3.98	\ /*
	*/	3.33	,	3.65	\ /*
	*/	3.11	,	3.39	\ /*
	*/	2.93	,	3.19	\ /*
	*/	2.79	,	3.02	\ /*
	*/	2.67	,	2.88	\ /*
	*/	2.57	,	2.77	\ /*
	*/	2.48	,	2.67	\ /*
	*/	2.41	,	2.58	\ /*
	*/	2.34	,	2.51	\ /*
	*/	2.28	,	2.44	\ /*
	*/	2.23	,	2.38	\ /*
	*/	2.18	,	2.33	\ /*
	*/	2.14	,	2.28	\ /*
	*/	2.10	,	2.23	\ /*
	*/	2.07	,	2.19	\ /*
	*/	2.04	,	2.16	\ /*
	*/	2.01	,	2.12	\ /*
	*/	1.98	,	2.09	\ /*
	*/	1.95	,	2.06	\ /*
	*/	1.93	,	2.03	\ /*
	*/	1.90	,	2.01	\ /*
	*/	1.88	,	1.98	\ /*
	*/	1.86	,	1.96	\ /*
	*/	1.84	,	1.94	\ /*
	*/	1.83	,	1.92	\ /*
	*/	1.81	,	1.90	\ /*
	*/	1.79	,	1.88	\ /*
	*/	1.78	,	1.87	\ /*
	*/	1.76	,	1.85	\ /*
	*/	1.75	,	1.83	\ /*
	*/	1.74	,	1.82	\ /*
	*/	1.72	,	1.80	\ /*
	*/	1.71	,	1.79	\ /*
	*/	1.70	,	1.78	\ /*
	*/	1.69	,	1.77	\ /*
	*/	1.68	,	1.75	\ /*
	*/	1.67	,	1.74	\ /*
	*/	1.66	,	1.73	\ /*
	*/	1.65	,	1.72	\ /*
	*/	1.64	,	1.71	\ /*
	*/	1.63	,	1.70	\ /*
	*/	1.62	,	1.69	\ /*
	*/	1.61	,	1.68	\ /*
	*/	1.60	,	1.67	\ /*
	*/	1.60	,	1.66	\ /*
	*/	1.59	,	1.66	\ /*
	*/	1.58	,	1.65	\ /*
	*/	1.57	,	1.64	\ /*
	*/	1.57	,	1.63	\ /*
	*/	1.56	,	1.63	\ /*
	*/	1.55	,	1.62	\ /*
	*/	1.55	,	1.61	\ /*
	*/	1.54	,	1.61	\ /*
	*/	1.54	,	1.60	\ /*
	*/	1.53	,	1.59	\ /*
	*/	1.53	,	1.59	\ /*
	*/	1.52	,	1.58	\ /*
	*/	1.51	,	1.57	\ /*
	*/	1.51	,	1.57	\ /*
	*/	1.50	,	1.56	\ /*
	*/	1.50	,	1.56	\ /*
	*/	1.50	,	1.55	\ /*
	*/	1.49	,	1.55	\ /*
	*/	1.49	,	1.54	\ /*
	*/	1.48	,	1.54	\ /*
	*/	1.48	,	1.53	\ /*
	*/	1.47	,	1.53	\ /*
	*/	1.47	,	1.52	\ /*
	*/	1.47	,	1.52	\ /*
	*/	1.46	,	1.52	\ /*
	*/	1.46	,	1.51	\ /*
	*/	1.46	,	1.51	\ /*
	*/	1.45	,	1.50	\ /*
	*/	1.45	,	1.50	\ /*
	*/	1.45	,	1.50	\ /*
	*/	1.44	,	1.49	\ /*
	*/	1.44	,	1.49	\ /*
	*/	1.44	,	1.48	\ /*
	*/	1.43	,	1.48	\ /*
	*/	1.43	,	1.48	\ /*
	*/	1.43	,	1.47	\ /*
	*/	1.43	,	1.47	\ /*
	*/	1.42	,	1.47	\ /*
	*/	1.42	,	1.47	\ /*
	*/	1.42	,	1.46	\ /*
	*/	1.42	,	1.46	\ /*
	*/	1.41	,	1.46	\ /*
	*/	1.41	,	1.45	\ /*
	*/	1.41	,	1.45	\ /*
	*/	1.41	,	1.45	\ /*
	*/	1.41	,	1.45	\ /*
	*/	1.40	,	1.44	\ /*
	*/	1.40	,	1.44	\ /*
	*/	1.40	,	1.44	)

		if `k2'<=100 & `nendog'<=2 {
			scalar `cv'=`temp'[`k2',`nendog']
		}
	}

	if "`type'"=="fullmax5" {
		matrix input `temp' = ( /*
	*/	23.81	,	.	\ /*
	*/	12.38	,	14.19	\ /*
	*/	8.66	,	10.00	\ /*
	*/	6.81	,	7.88	\ /*
	*/	5.71	,	6.60	\ /*
	*/	4.98	,	5.74	\ /*
	*/	4.45	,	5.13	\ /*
	*/	4.06	,	4.66	\ /*
	*/	3.76	,	4.30	\ /*
	*/	3.51	,	4.01	\ /*
	*/	3.31	,	3.77	\ /*
	*/	3.15	,	3.57	\ /*
	*/	3.00	,	3.41	\ /*
	*/	2.88	,	3.26	\ /*
	*/	2.78	,	3.13	\ /*
	*/	2.69	,	3.02	\ /*
	*/	2.61	,	2.92	\ /*
	*/	2.53	,	2.84	\ /*
	*/	2.47	,	2.76	\ /*
	*/	2.41	,	2.69	\ /*
	*/	2.36	,	2.62	\ /*
	*/	2.31	,	2.56	\ /*
	*/	2.27	,	2.51	\ /*
	*/	2.23	,	2.46	\ /*
	*/	2.19	,	2.42	\ /*
	*/	2.15	,	2.37	\ /*
	*/	2.12	,	2.33	\ /*
	*/	2.09	,	2.30	\ /*
	*/	2.07	,	2.26	\ /*
	*/	2.04	,	2.23	\ /*
	*/	2.02	,	2.20	\ /*
	*/	1.99	,	2.17	\ /*
	*/	1.97	,	2.14	\ /*
	*/	1.95	,	2.12	\ /*
	*/	1.93	,	2.10	\ /*
	*/	1.91	,	2.07	\ /*
	*/	1.90	,	2.05	\ /*
	*/	1.88	,	2.03	\ /*
	*/	1.87	,	2.01	\ /*
	*/	1.85	,	1.99	\ /*
	*/	1.84	,	1.98	\ /*
	*/	1.82	,	1.96	\ /*
	*/	1.81	,	1.94	\ /*
	*/	1.80	,	1.93	\ /*
	*/	1.79	,	1.91	\ /*
	*/	1.78	,	1.90	\ /*
	*/	1.76	,	1.88	\ /*
	*/	1.75	,	1.87	\ /*
	*/	1.74	,	1.86	\ /*
	*/	1.73	,	1.85	\ /*
	*/	1.73	,	1.83	\ /*
	*/	1.72	,	1.82	\ /*
	*/	1.71	,	1.81	\ /*
	*/	1.70	,	1.80	\ /*
	*/	1.69	,	1.79	\ /*
	*/	1.68	,	1.78	\ /*
	*/	1.68	,	1.77	\ /*
	*/	1.67	,	1.76	\ /*
	*/	1.66	,	1.75	\ /*
	*/	1.65	,	1.74	\ /*
	*/	1.65	,	1.74	\ /*
	*/	1.64	,	1.73	\ /*
	*/	1.63	,	1.72	\ /*
	*/	1.63	,	1.71	\ /*
	*/	1.62	,	1.70	\ /*
	*/	1.62	,	1.70	\ /*
	*/	1.61	,	1.69	\ /*
	*/	1.60	,	1.68	\ /*
	*/	1.60	,	1.68	\ /*
	*/	1.59	,	1.67	\ /*
	*/	1.59	,	1.66	\ /*
	*/	1.58	,	1.66	\ /*
	*/	1.58	,	1.65	\ /*
	*/	1.57	,	1.64	\ /*
	*/	1.57	,	1.64	\ /*
	*/	1.56	,	1.63	\ /*
	*/	1.56	,	1.63	\ /*
	*/	1.55	,	1.62	\ /*
	*/	1.55	,	1.62	\ /*
	*/	1.54	,	1.61	\ /*
	*/	1.54	,	1.61	\ /*
	*/	1.53	,	1.60	\ /*
	*/	1.53	,	1.60	\ /*
	*/	1.53	,	1.59	\ /*
	*/	1.52	,	1.59	\ /*
	*/	1.52	,	1.58	\ /*
	*/	1.51	,	1.58	\ /*
	*/	1.51	,	1.57	\ /*
	*/	1.50	,	1.57	\ /*
	*/	1.50	,	1.57	\ /*
	*/	1.50	,	1.56	\ /*
	*/	1.49	,	1.56	\ /*
	*/	1.49	,	1.55	\ /*
	*/	1.49	,	1.55	\ /*
	*/	1.48	,	1.55	\ /*
	*/	1.48	,	1.54	\ /*
	*/	1.47	,	1.54	\ /*
	*/	1.47	,	1.54	\ /*
	*/	1.47	,	1.53	\ /*
	*/	1.46	,	1.53	)

		if `k2'<=100 & `nendog'<=2 {
			scalar `cv'=`temp'[`k2',`nendog']
		}
	}
	
	if "`type'"=="fullmax10" {
		matrix input `temp' = ( /*
	*/	19.40	,	.	\ /*
	*/	10.14	,	11.92	\ /*
	*/	7.18	,	8.39	\ /*
	*/	5.72	,	6.64	\ /*
	*/	4.85	,	5.60	\ /*
	*/	4.27	,	4.90	\ /*
	*/	3.86	,	4.40	\ /*
	*/	3.55	,	4.03	\ /*
	*/	3.31	,	3.73	\ /*
	*/	3.12	,	3.50	\ /*
	*/	2.96	,	3.31	\ /*
	*/	2.83	,	3.15	\ /*
	*/	2.71	,	3.01	\ /*
	*/	2.62	,	2.89	\ /*
	*/	2.53	,	2.79	\ /*
	*/	2.46	,	2.70	\ /*
	*/	2.39	,	2.62	\ /*
	*/	2.33	,	2.55	\ /*
	*/	2.28	,	2.49	\ /*
	*/	2.23	,	2.43	\ /*
	*/	2.19	,	2.38	\ /*
	*/	2.15	,	2.33	\ /*
	*/	2.11	,	2.29	\ /*
	*/	2.08	,	2.25	\ /*
	*/	2.05	,	2.21	\ /*
	*/	2.02	,	2.18	\ /*
	*/	1.99	,	2.14	\ /*
	*/	1.97	,	2.11	\ /*
	*/	1.94	,	2.08	\ /*
	*/	1.92	,	2.06	\ /*
	*/	1.90	,	2.03	\ /*
	*/	1.88	,	2.01	\ /*
	*/	1.86	,	1.99	\ /*
	*/	1.85	,	1.97	\ /*
	*/	1.83	,	1.95	\ /*
	*/	1.81	,	1.93	\ /*
	*/	1.80	,	1.91	\ /*
	*/	1.79	,	1.89	\ /*
	*/	1.77	,	1.88	\ /*
	*/	1.76	,	1.86	\ /*
	*/	1.75	,	1.85	\ /*
	*/	1.74	,	1.83	\ /*
	*/	1.72	,	1.82	\ /*
	*/	1.71	,	1.81	\ /*
	*/	1.70	,	1.80	\ /*
	*/	1.69	,	1.78	\ /*
	*/	1.68	,	1.77	\ /*
	*/	1.67	,	1.76	\ /*
	*/	1.66	,	1.75	\ /*
	*/	1.66	,	1.74	\ /*
	*/	1.65	,	1.73	\ /*
	*/	1.64	,	1.72	\ /*
	*/	1.63	,	1.71	\ /*
	*/	1.62	,	1.70	\ /*
	*/	1.62	,	1.69	\ /*
	*/	1.61	,	1.69	\ /*
	*/	1.60	,	1.68	\ /*
	*/	1.60	,	1.67	\ /*
	*/	1.59	,	1.66	\ /*
	*/	1.58	,	1.65	\ /*
	*/	1.58	,	1.65	\ /*
	*/	1.57	,	1.64	\ /*
	*/	1.57	,	1.63	\ /*
	*/	1.56	,	1.63	\ /*
	*/	1.55	,	1.62	\ /*
	*/	1.55	,	1.61	\ /*
	*/	1.54	,	1.61	\ /*
	*/	1.54	,	1.60	\ /*
	*/	1.53	,	1.60	\ /*
	*/	1.53	,	1.59	\ /*
	*/	1.52	,	1.59	\ /*
	*/	1.52	,	1.58	\ /*
	*/	1.52	,	1.58	\ /*
	*/	1.51	,	1.57	\ /*
	*/	1.51	,	1.57	\ /*
	*/	1.50	,	1.56	\ /*
	*/	1.50	,	1.56	\ /*
	*/	1.49	,	1.55	\ /*
	*/	1.49	,	1.55	\ /*
	*/	1.49	,	1.54	\ /*
	*/	1.48	,	1.54	\ /*
	*/	1.48	,	1.53	\ /*
	*/	1.48	,	1.53	\ /*
	*/	1.47	,	1.53	\ /*
	*/	1.47	,	1.52	\ /*
	*/	1.46	,	1.52	\ /*
	*/	1.46	,	1.51	\ /*
	*/	1.46	,	1.51	\ /*
	*/	1.45	,	1.51	\ /*
	*/	1.45	,	1.50	\ /*
	*/	1.45	,	1.50	\ /*
	*/	1.44	,	1.50	\ /*
	*/	1.44	,	1.49	\ /*
	*/	1.44	,	1.49	\ /*
	*/	1.44	,	1.49	\ /*
	*/	1.43	,	1.48	\ /*
	*/	1.43	,	1.48	\ /*
	*/	1.43	,	1.48	\ /*
	*/	1.42	,	1.48	\ /*
	*/	1.42	,	1.47	)

		if `k2'<=100 & `nendog'<=2 {
			scalar `cv'=`temp'[`k2',`nendog']
		}
	}
	
	if "`type'"=="fullmax20" {
		matrix input `temp' = ( /*
	*/	15.39	,	.	\ /*
	*/	8.16	,	9.41	\ /*
	*/	5.87	,	6.79	\ /*
	*/	4.75	,	5.47	\ /*
	*/	4.08	,	4.66	\ /*
	*/	3.64	,	4.13	\ /*
	*/	3.32	,	3.74	\ /*
	*/	3.08	,	3.45	\ /*
	*/	2.89	,	3.22	\ /*
	*/	2.74	,	3.03	\ /*
	*/	2.62	,	2.88	\ /*
	*/	2.51	,	2.76	\ /*
	*/	2.42	,	2.65	\ /*
	*/	2.35	,	2.56	\ /*
	*/	2.28	,	2.48	\ /*
	*/	2.22	,	2.40	\ /*
	*/	2.17	,	2.34	\ /*
	*/	2.12	,	2.28	\ /*
	*/	2.08	,	2.23	\ /*
	*/	2.04	,	2.19	\ /*
	*/	2.01	,	2.15	\ /*
	*/	1.98	,	2.11	\ /*
	*/	1.95	,	2.07	\ /*
	*/	1.92	,	2.04	\ /*
	*/	1.89	,	2.01	\ /*
	*/	1.87	,	1.98	\ /*
	*/	1.85	,	1.96	\ /*
	*/	1.83	,	1.93	\ /*
	*/	1.81	,	1.91	\ /*
	*/	1.79	,	1.89	\ /*
	*/	1.77	,	1.87	\ /*
	*/	1.76	,	1.85	\ /*
	*/	1.74	,	1.83	\ /*
	*/	1.73	,	1.82	\ /*
	*/	1.72	,	1.80	\ /*
	*/	1.70	,	1.79	\ /*
	*/	1.69	,	1.77	\ /*
	*/	1.68	,	1.76	\ /*
	*/	1.67	,	1.74	\ /*
	*/	1.66	,	1.73	\ /*
	*/	1.65	,	1.72	\ /*
	*/	1.64	,	1.71	\ /*
	*/	1.63	,	1.70	\ /*
	*/	1.62	,	1.69	\ /*
	*/	1.61	,	1.68	\ /*
	*/	1.60	,	1.67	\ /*
	*/	1.59	,	1.66	\ /*
	*/	1.58	,	1.65	\ /*
	*/	1.58	,	1.64	\ /*
	*/	1.57	,	1.63	\ /*
	*/	1.56	,	1.62	\ /*
	*/	1.56	,	1.62	\ /*
	*/	1.55	,	1.61	\ /*
	*/	1.54	,	1.60	\ /*
	*/	1.54	,	1.59	\ /*
	*/	1.53	,	1.59	\ /*
	*/	1.52	,	1.58	\ /*
	*/	1.52	,	1.57	\ /*
	*/	1.51	,	1.57	\ /*
	*/	1.51	,	1.56	\ /*
	*/	1.50	,	1.56	\ /*
	*/	1.50	,	1.55	\ /*
	*/	1.49	,	1.54	\ /*
	*/	1.49	,	1.54	\ /*
	*/	1.48	,	1.53	\ /*
	*/	1.48	,	1.53	\ /*
	*/	1.47	,	1.52	\ /*
	*/	1.47	,	1.52	\ /*
	*/	1.47	,	1.51	\ /*
	*/	1.46	,	1.51	\ /*
	*/	1.46	,	1.51	\ /*
	*/	1.45	,	1.50	\ /*
	*/	1.45	,	1.50	\ /*
	*/	1.45	,	1.49	\ /*
	*/	1.44	,	1.49	\ /*
	*/	1.44	,	1.48	\ /*
	*/	1.44	,	1.48	\ /*
	*/	1.43	,	1.48	\ /*
	*/	1.43	,	1.47	\ /*
	*/	1.43	,	1.47	\ /*
	*/	1.42	,	1.46	\ /*
	*/	1.42	,	1.46	\ /*
	*/	1.42	,	1.46	\ /*
	*/	1.41	,	1.45	\ /*
	*/	1.41	,	1.45	\ /*
	*/	1.41	,	1.45	\ /*
	*/	1.40	,	1.44	\ /*
	*/	1.40	,	1.44	\ /*
	*/	1.40	,	1.44	\ /*
	*/	1.40	,	1.44	\ /*
	*/	1.39	,	1.43	\ /*
	*/	1.39	,	1.43	\ /*
	*/	1.39	,	1.43	\ /*
	*/	1.39	,	1.42	\ /*
	*/	1.38	,	1.42	\ /*
	*/	1.38	,	1.42	\ /*
	*/	1.38	,	1.42	\ /*
	*/	1.38	,	1.41	\ /*
	*/	1.37	,	1.41	\ /*
	*/	1.37	,	1.41	)

		if `k2'<=100 & `nendog'<=2 {
			scalar `cv'=`temp'[`k2',`nendog']
		}
	}

	if "`type'"=="fullmax30" {
		matrix input `temp' = ( /*
	*/	12.76	,	.	\ /*
	*/	6.97	,	8.01	\ /*
	*/	5.11	,	5.88	\ /*
	*/	4.19	,	4.78	\ /*
	*/	3.64	,	4.12	\ /*
	*/	3.27	,	3.67	\ /*
	*/	3.00	,	3.35	\ /*
	*/	2.80	,	3.10	\ /*
	*/	2.64	,	2.91	\ /*
	*/	2.52	,	2.76	\ /*
	*/	2.41	,	2.63	\ /*
	*/	2.33	,	2.52	\ /*
	*/	2.25	,	2.43	\ /*
	*/	2.19	,	2.35	\ /*
	*/	2.13	,	2.29	\ /*
	*/	2.08	,	2.22	\ /*
	*/	2.04	,	2.17	\ /*
	*/	2.00	,	2.12	\ /*
	*/	1.96	,	2.08	\ /*
	*/	1.93	,	2.04	\ /*
	*/	1.90	,	2.01	\ /*
	*/	1.87	,	1.97	\ /*
	*/	1.84	,	1.94	\ /*
	*/	1.82	,	1.92	\ /*
	*/	1.80	,	1.89	\ /*
	*/	1.78	,	1.87	\ /*
	*/	1.76	,	1.84	\ /*
	*/	1.74	,	1.82	\ /*
	*/	1.73	,	1.80	\ /*
	*/	1.71	,	1.79	\ /*
	*/	1.70	,	1.77	\ /*
	*/	1.68	,	1.75	\ /*
	*/	1.67	,	1.74	\ /*
	*/	1.66	,	1.72	\ /*
	*/	1.64	,	1.71	\ /*
	*/	1.63	,	1.70	\ /*
	*/	1.62	,	1.68	\ /*
	*/	1.61	,	1.67	\ /*
	*/	1.60	,	1.66	\ /*
	*/	1.59	,	1.65	\ /*
	*/	1.58	,	1.64	\ /*
	*/	1.57	,	1.63	\ /*
	*/	1.57	,	1.62	\ /*
	*/	1.56	,	1.61	\ /*
	*/	1.55	,	1.60	\ /*
	*/	1.54	,	1.59	\ /*
	*/	1.54	,	1.59	\ /*
	*/	1.53	,	1.58	\ /*
	*/	1.52	,	1.57	\ /*
	*/	1.52	,	1.56	\ /*
	*/	1.51	,	1.56	\ /*
	*/	1.50	,	1.55	\ /*
	*/	1.50	,	1.54	\ /*
	*/	1.49	,	1.54	\ /*
	*/	1.49	,	1.53	\ /*
	*/	1.48	,	1.53	\ /*
	*/	1.48	,	1.52	\ /*
	*/	1.47	,	1.51	\ /*
	*/	1.47	,	1.51	\ /*
	*/	1.46	,	1.50	\ /*
	*/	1.46	,	1.50	\ /*
	*/	1.45	,	1.49	\ /*
	*/	1.45	,	1.49	\ /*
	*/	1.44	,	1.48	\ /*
	*/	1.44	,	1.48	\ /*
	*/	1.44	,	1.47	\ /*
	*/	1.43	,	1.47	\ /*
	*/	1.43	,	1.47	\ /*
	*/	1.42	,	1.46	\ /*
	*/	1.42	,	1.46	\ /*
	*/	1.42	,	1.45	\ /*
	*/	1.41	,	1.45	\ /*
	*/	1.41	,	1.45	\ /*
	*/	1.41	,	1.44	\ /*
	*/	1.40	,	1.44	\ /*
	*/	1.40	,	1.44	\ /*
	*/	1.40	,	1.43	\ /*
	*/	1.39	,	1.43	\ /*
	*/	1.39	,	1.43	\ /*
	*/	1.39	,	1.42	\ /*
	*/	1.39	,	1.42	\ /*
	*/	1.38	,	1.42	\ /*
	*/	1.38	,	1.41	\ /*
	*/	1.38	,	1.41	\ /*
	*/	1.37	,	1.41	\ /*
	*/	1.37	,	1.40	\ /*
	*/	1.37	,	1.40	\ /*
	*/	1.37	,	1.40	\ /*
	*/	1.36	,	1.40	\ /*
	*/	1.36	,	1.39	\ /*
	*/	1.36	,	1.39	\ /*
	*/	1.36	,	1.39	\ /*
	*/	1.36	,	1.38	\ /*
	*/	1.35	,	1.38	\ /*
	*/	1.35	,	1.38	\ /*
	*/	1.35	,	1.38	\ /*
	*/	1.35	,	1.37	\ /*
	*/	1.34	,	1.37	\ /*
	*/	1.34	,	1.37	\ /*
	*/	1.34	,	1.37	)

		if `k2'<=100 & `nendog'<=2 {
			scalar `cv'=`temp'[`k2',`nendog']
		}
	}

	if "`type'"=="limlsize10" {
		matrix input `temp' = ( /*
	*/	16.38	,	.	\ /*
	*/	8.68	,	7.03	\ /*
	*/	6.46	,	5.44	\ /*
	*/	5.44	,	4.72	\ /*
	*/	4.84	,	4.32	\ /*
	*/	4.45	,	4.06	\ /*
	*/	4.18	,	3.90	\ /*
	*/	3.97	,	3.78	\ /*
	*/	3.81	,	3.70	\ /*
	*/	3.68	,	3.64	\ /*
	*/	3.58	,	3.60	\ /*
	*/	3.50	,	3.58	\ /*
	*/	3.42	,	3.56	\ /*
	*/	3.36	,	3.55	\ /*
	*/	3.31	,	3.54	\ /*
	*/	3.27	,	3.55	\ /*
	*/	3.24	,	3.55	\ /*
	*/	3.20	,	3.56	\ /*
	*/	3.18	,	3.57	\ /*
	*/	3.21	,	3.58	\ /*
	*/	3.39	,	3.59	\ /*
	*/	3.57	,	3.60	\ /*
	*/	3.68	,	3.62	\ /*
	*/	3.75	,	3.64	\ /*
	*/	3.79	,	3.65	\ /*
	*/	3.82	,	3.67	\ /*
	*/	3.85	,	3.74	\ /*
	*/	3.86	,	3.87	\ /*
	*/	3.87	,	4.02	\ /*
	*/	3.88	,	4.12	\ /*
	*/	3.89	,	4.19	\ /*
	*/	3.89	,	4.24	\ /*
	*/	3.90	,	4.27	\ /*
	*/	3.90	,	4.31	\ /*
	*/	3.90	,	4.33	\ /*
	*/	3.90	,	4.36	\ /*
	*/	3.90	,	4.38	\ /*
	*/	3.90	,	4.39	\ /*
	*/	3.90	,	4.41	\ /*
	*/	3.90	,	4.43	\ /*
	*/	3.90	,	4.44	\ /*
	*/	3.90	,	4.45	\ /*
	*/	3.90	,	4.47	\ /*
	*/	3.90	,	4.48	\ /*
	*/	3.90	,	4.49	\ /*
	*/	3.90	,	4.50	\ /*
	*/	3.90	,	4.51	\ /*
	*/	3.90	,	4.52	\ /*
	*/	3.90	,	4.53	\ /*
	*/	3.90	,	4.54	\ /*
	*/	3.90	,	4.55	\ /*
	*/	3.90	,	4.56	\ /*
	*/	3.90	,	4.56	\ /*
	*/	3.90	,	4.57	\ /*
	*/	3.90	,	4.58	\ /*
	*/	3.90	,	4.59	\ /*
	*/	3.90	,	4.59	\ /*
	*/	3.90	,	4.60	\ /*
	*/	3.90	,	4.61	\ /*
	*/	3.90	,	4.61	\ /*
	*/	3.90	,	4.62	\ /*
	*/	3.90	,	4.62	\ /*
	*/	3.90	,	4.63	\ /*
	*/	3.90	,	4.63	\ /*
	*/	3.89	,	4.64	\ /*
	*/	3.89	,	4.64	\ /*
	*/	3.89	,	4.64	\ /*
	*/	3.89	,	4.65	\ /*
	*/	3.89	,	4.65	\ /*
	*/	3.89	,	4.65	\ /*
	*/	3.89	,	4.66	\ /*
	*/	3.89	,	4.66	\ /*
	*/	3.89	,	4.66	\ /*
	*/	3.89	,	4.66	\ /*
	*/	3.88	,	4.66	\ /*
	*/	3.88	,	4.66	\ /*
	*/	3.88	,	4.66	\ /*
	*/	3.88	,	4.66	\ /*
	*/	3.88	,	4.66	\ /*
	*/	3.88	,	4.66	\ /*
	*/	3.88	,	4.66	\ /*
	*/	3.87	,	4.66	\ /*
	*/	3.87	,	4.66	\ /*
	*/	3.87	,	4.66	\ /*
	*/	3.87	,	4.66	\ /*
	*/	3.87	,	4.66	\ /*
	*/	3.86	,	4.65	\ /*
	*/	3.86	,	4.65	\ /*
	*/	3.86	,	4.65	\ /*
	*/	3.86	,	4.64	\ /*
	*/	3.85	,	4.64	\ /*
	*/	3.85	,	4.64	\ /*
	*/	3.85	,	4.63	\ /*
	*/	3.85	,	4.63	\ /*
	*/	3.84	,	4.62	\ /*
	*/	3.84	,	4.62	\ /*
	*/	3.84	,	4.61	\ /*
	*/	3.84	,	4.60	\ /*
	*/	3.83	,	4.60	\ /*
	*/	3.83	,	4.59	)

		if `k2'<=100 & `nendog'<=2 {
			scalar `cv'=`temp'[`k2',`nendog']
		}
	}

	if "`type'"=="limlsize15" {
		matrix input `temp' = ( /*
	*/	8.96	,	.	\ /*
	*/	5.33	,	4.58	\ /*
	*/	4.36	,	3.81	\ /*
	*/	3.87	,	3.39	\ /*
	*/	3.56	,	3.13	\ /*
	*/	3.34	,	2.95	\ /*
	*/	3.18	,	2.83	\ /*
	*/	3.04	,	2.73	\ /*
	*/	2.93	,	2.66	\ /*
	*/	2.84	,	2.60	\ /*
	*/	2.76	,	2.55	\ /*
	*/	2.69	,	2.52	\ /*
	*/	2.63	,	2.48	\ /*
	*/	2.57	,	2.46	\ /*
	*/	2.52	,	2.44	\ /*
	*/	2.48	,	2.42	\ /*
	*/	2.44	,	2.41	\ /*
	*/	2.41	,	2.40	\ /*
	*/	2.37	,	2.39	\ /*
	*/	2.34	,	2.38	\ /*
	*/	2.32	,	2.38	\ /*
	*/	2.29	,	2.37	\ /*
	*/	2.27	,	2.37	\ /*
	*/	2.25	,	2.37	\ /*
	*/	2.24	,	2.37	\ /*
	*/	2.22	,	2.38	\ /*
	*/	2.21	,	2.38	\ /*
	*/	2.20	,	2.38	\ /*
	*/	2.19	,	2.39	\ /*
	*/	2.18	,	2.39	\ /*
	*/	2.19	,	2.40	\ /*
	*/	2.22	,	2.41	\ /*
	*/	2.33	,	2.42	\ /*
	*/	2.40	,	2.42	\ /*
	*/	2.45	,	2.43	\ /*
	*/	2.48	,	2.44	\ /*
	*/	2.50	,	2.45	\ /*
	*/	2.52	,	2.54	\ /*
	*/	2.53	,	2.55	\ /*
	*/	2.54	,	2.66	\ /*
	*/	2.55	,	2.73	\ /*
	*/	2.56	,	2.78	\ /*
	*/	2.57	,	2.82	\ /*
	*/	2.57	,	2.85	\ /*
	*/	2.58	,	2.87	\ /*
	*/	2.58	,	2.89	\ /*
	*/	2.58	,	2.91	\ /*
	*/	2.59	,	2.92	\ /*
	*/	2.59	,	2.93	\ /*
	*/	2.59	,	2.94	\ /*
	*/	2.59	,	2.95	\ /*
	*/	2.59	,	2.96	\ /*
	*/	2.60	,	2.97	\ /*
	*/	2.60	,	2.98	\ /*
	*/	2.60	,	2.98	\ /*
	*/	2.60	,	2.99	\ /*
	*/	2.60	,	2.99	\ /*
	*/	2.60	,	3.00	\ /*
	*/	2.60	,	3.00	\ /*
	*/	2.60	,	3.01	\ /*
	*/	2.60	,	3.01	\ /*
	*/	2.60	,	3.02	\ /*
	*/	2.61	,	3.02	\ /*
	*/	2.61	,	3.02	\ /*
	*/	2.61	,	3.03	\ /*
	*/	2.61	,	3.03	\ /*
	*/	2.61	,	3.03	\ /*
	*/	2.61	,	3.03	\ /*
	*/	2.61	,	3.04	\ /*
	*/	2.61	,	3.04	\ /*
	*/	2.61	,	3.04	\ /*
	*/	2.60	,	3.04	\ /*
	*/	2.60	,	3.04	\ /*
	*/	2.60	,	3.05	\ /*
	*/	2.60	,	3.05	\ /*
	*/	2.60	,	3.05	\ /*
	*/	2.60	,	3.05	\ /*
	*/	2.60	,	3.05	\ /*
	*/	2.60	,	3.05	\ /*
	*/	2.60	,	3.05	\ /*
	*/	2.60	,	3.05	\ /*
	*/	2.60	,	3.05	\ /*
	*/	2.60	,	3.05	\ /*
	*/	2.59	,	3.05	\ /*
	*/	2.59	,	3.05	\ /*
	*/	2.59	,	3.05	\ /*
	*/	2.59	,	3.05	\ /*
	*/	2.59	,	3.05	\ /*
	*/	2.59	,	3.04	\ /*
	*/	2.58	,	3.04	\ /*
	*/	2.58	,	3.04	\ /*
	*/	2.58	,	3.04	\ /*
	*/	2.58	,	3.04	\ /*
	*/	2.58	,	3.03	\ /*
	*/	2.57	,	3.03	\ /*
	*/	2.57	,	3.03	\ /*
	*/	2.57	,	3.03	\ /*
	*/	2.57	,	3.02	\ /*
	*/	2.56	,	3.02	\ /*
	*/	2.56	,	3.02	)
	
		if `k2'<=100 & `nendog'<=2 {
			scalar `cv'=`temp'[`k2',`nendog']
		}
	}

	if "`type'"=="limlsize20" {
		matrix input `temp' = ( /*
	*/	6.66	,	.	\ /*
	*/	4.42	,	3.95	\ /*
	*/	3.69	,	3.32	\ /*
	*/	3.30	,	2.99	\ /*
	*/	3.05	,	2.78	\ /*
	*/	2.87	,	2.63	\ /*
	*/	2.73	,	2.52	\ /*
	*/	2.63	,	2.43	\ /*
	*/	2.54	,	2.36	\ /*
	*/	2.46	,	2.30	\ /*
	*/	2.40	,	2.25	\ /*
	*/	2.34	,	2.21	\ /*
	*/	2.29	,	2.17	\ /*
	*/	2.25	,	2.14	\ /*
	*/	2.21	,	2.11	\ /*
	*/	2.18	,	2.09	\ /*
	*/	2.14	,	2.07	\ /*
	*/	2.11	,	2.05	\ /*
	*/	2.09	,	2.03	\ /*
	*/	2.06	,	2.02	\ /*
	*/	2.04	,	2.01	\ /*
	*/	2.02	,	1.99	\ /*
	*/	2.00	,	1.98	\ /*
	*/	1.98	,	1.98	\ /*
	*/	1.96	,	1.97	\ /*
	*/	1.95	,	1.96	\ /*
	*/	1.93	,	1.96	\ /*
	*/	1.92	,	1.95	\ /*
	*/	1.90	,	1.95	\ /*
	*/	1.89	,	1.95	\ /*
	*/	1.88	,	1.94	\ /*
	*/	1.87	,	1.94	\ /*
	*/	1.86	,	1.94	\ /*
	*/	1.85	,	1.94	\ /*
	*/	1.84	,	1.94	\ /*
	*/	1.83	,	1.94	\ /*
	*/	1.82	,	1.94	\ /*
	*/	1.81	,	1.95	\ /*
	*/	1.81	,	1.95	\ /*
	*/	1.80	,	1.95	\ /*
	*/	1.79	,	1.95	\ /*
	*/	1.79	,	1.96	\ /*
	*/	1.78	,	1.96	\ /*
	*/	1.78	,	1.97	\ /*
	*/	1.80	,	1.97	\ /*
	*/	1.87	,	1.98	\ /*
	*/	1.92	,	1.98	\ /*
	*/	1.95	,	1.99	\ /*
	*/	1.97	,	2.00	\ /*
	*/	1.99	,	2.00	\ /*
	*/	2.00	,	2.01	\ /*
	*/	2.01	,	2.09	\ /*
	*/	2.02	,	2.11	\ /*
	*/	2.03	,	2.18	\ /*
	*/	2.04	,	2.23	\ /*
	*/	2.04	,	2.27	\ /*
	*/	2.05	,	2.29	\ /*
	*/	2.05	,	2.31	\ /*
	*/	2.06	,	2.33	\ /*
	*/	2.06	,	2.34	\ /*
	*/	2.07	,	2.35	\ /*
	*/	2.07	,	2.36	\ /*
	*/	2.07	,	2.37	\ /*
	*/	2.08	,	2.38	\ /*
	*/	2.08	,	2.39	\ /*
	*/	2.08	,	2.39	\ /*
	*/	2.08	,	2.40	\ /*
	*/	2.09	,	2.40	\ /*
	*/	2.09	,	2.41	\ /*
	*/	2.09	,	2.41	\ /*
	*/	2.09	,	2.41	\ /*
	*/	2.09	,	2.42	\ /*
	*/	2.09	,	2.42	\ /*
	*/	2.09	,	2.42	\ /*
	*/	2.09	,	2.43	\ /*
	*/	2.10	,	2.43	\ /*
	*/	2.10	,	2.43	\ /*
	*/	2.10	,	2.43	\ /*
	*/	2.10	,	2.44	\ /*
	*/	2.10	,	2.44	\ /*
	*/	2.10	,	2.44	\ /*
	*/	2.10	,	2.44	\ /*
	*/	2.10	,	2.44	\ /*
	*/	2.09	,	2.44	\ /*
	*/	2.09	,	2.44	\ /*
	*/	2.09	,	2.45	\ /*
	*/	2.09	,	2.45	\ /*
	*/	2.09	,	2.45	\ /*
	*/	2.09	,	2.45	\ /*
	*/	2.09	,	2.45	\ /*
	*/	2.09	,	2.45	\ /*
	*/	2.09	,	2.45	\ /*
	*/	2.08	,	2.45	\ /*
	*/	2.08	,	2.45	\ /*
	*/	2.08	,	2.45	\ /*
	*/	2.08	,	2.45	\ /*
	*/	2.08	,	2.45	\ /*
	*/	2.07	,	2.44	\ /*
	*/	2.07	,	2.44	\ /*
	*/	2.07	,	2.44	)

		if `k2'<=100 & `nendog'<=2 {
			scalar `cv'=`temp'[`k2',`nendog']
		}
	}

	if "`type'"=="limlsize25" {
		matrix input `temp' = ( /*
	*/	5.53	,	.	\ /*
	*/	3.92	,	3.63	\ /*
	*/	3.32	,	3.09	\ /*
	*/	2.98	,	2.79	\ /*
	*/	2.77	,	2.60	\ /*
	*/	2.61	,	2.46	\ /*
	*/	2.49	,	2.35	\ /*
	*/	2.39	,	2.27	\ /*
	*/	2.32	,	2.20	\ /*
	*/	2.25	,	2.14	\ /*
	*/	2.19	,	2.09	\ /*
	*/	2.14	,	2.05	\ /*
	*/	2.10	,	2.02	\ /*
	*/	2.06	,	1.99	\ /*
	*/	2.03	,	1.96	\ /*
	*/	2.00	,	1.93	\ /*
	*/	1.97	,	1.91	\ /*
	*/	1.94	,	1.89	\ /*
	*/	1.92	,	1.87	\ /*
	*/	1.90	,	1.86	\ /*
	*/	1.88	,	1.84	\ /*
	*/	1.86	,	1.83	\ /*
	*/	1.84	,	1.81	\ /*
	*/	1.83	,	1.80	\ /*
	*/	1.81	,	1.79	\ /*
	*/	1.80	,	1.78	\ /*
	*/	1.78	,	1.77	\ /*
	*/	1.77	,	1.77	\ /*
	*/	1.76	,	1.76	\ /*
	*/	1.75	,	1.75	\ /*
	*/	1.74	,	1.75	\ /*
	*/	1.73	,	1.74	\ /*
	*/	1.72	,	1.73	\ /*
	*/	1.71	,	1.73	\ /*
	*/	1.70	,	1.73	\ /*
	*/	1.69	,	1.72	\ /*
	*/	1.68	,	1.72	\ /*
	*/	1.67	,	1.71	\ /*
	*/	1.67	,	1.71	\ /*
	*/	1.66	,	1.71	\ /*
	*/	1.65	,	1.71	\ /*
	*/	1.65	,	1.71	\ /*
	*/	1.64	,	1.70	\ /*
	*/	1.63	,	1.70	\ /*
	*/	1.63	,	1.70	\ /*
	*/	1.62	,	1.70	\ /*
	*/	1.62	,	1.70	\ /*
	*/	1.61	,	1.70	\ /*
	*/	1.61	,	1.70	\ /*
	*/	1.61	,	1.70	\ /*
	*/	1.60	,	1.70	\ /*
	*/	1.60	,	1.70	\ /*
	*/	1.59	,	1.70	\ /*
	*/	1.59	,	1.70	\ /*
	*/	1.59	,	1.70	\ /*
	*/	1.58	,	1.70	\ /*
	*/	1.58	,	1.71	\ /*
	*/	1.58	,	1.71	\ /*
	*/	1.57	,	1.71	\ /*
	*/	1.59	,	1.71	\ /*
	*/	1.60	,	1.71	\ /*
	*/	1.63	,	1.72	\ /*
	*/	1.65	,	1.72	\ /*
	*/	1.67	,	1.72	\ /*
	*/	1.69	,	1.72	\ /*
	*/	1.70	,	1.76	\ /*
	*/	1.71	,	1.81	\ /*
	*/	1.72	,	1.87	\ /*
	*/	1.73	,	1.91	\ /*
	*/	1.74	,	1.94	\ /*
	*/	1.74	,	1.96	\ /*
	*/	1.75	,	1.98	\ /*
	*/	1.75	,	1.99	\ /*
	*/	1.76	,	2.01	\ /*
	*/	1.76	,	2.02	\ /*
	*/	1.77	,	2.03	\ /*
	*/	1.77	,	2.04	\ /*
	*/	1.78	,	2.04	\ /*
	*/	1.78	,	2.05	\ /*
	*/	1.78	,	2.06	\ /*
	*/	1.79	,	2.06	\ /*
	*/	1.79	,	2.07	\ /*
	*/	1.79	,	2.07	\ /*
	*/	1.79	,	2.08	\ /*
	*/	1.80	,	2.08	\ /*
	*/	1.80	,	2.09	\ /*
	*/	1.80	,	2.09	\ /*
	*/	1.80	,	2.09	\ /*
	*/	1.80	,	2.09	\ /*
	*/	1.80	,	2.10	\ /*
	*/	1.80	,	2.10	\ /*
	*/	1.80	,	2.10	\ /*
	*/	1.80	,	2.10	\ /*
	*/	1.80	,	2.10	\ /*
	*/	1.80	,	2.11	\ /*
	*/	1.80	,	2.11	\ /*
	*/	1.80	,	2.11	\ /*
	*/	1.80	,	2.11	\ /*
	*/	1.80	,	2.11	\ /*
	*/	1.80	,	2.11	)

		if `k2'<=100 & `nendog'<=2 {
			scalar `cv'=`temp'[`k2',`nendog']
		}
	}


	return scalar cv=`cv'
end

exit

********************************** VERSION COMMENTS **********************************
*  1.0.2:  add logic for reg3. Sargan test
*  1.0.3:  add prunelist to ensure that count of excluded exogeneous is correct 
*  1.0.4:  revise option to exog(), allow included exog to be specified as well
*  1.0.5:  switch from reg3 to regress, many options and output changes
*  1.0.6:  fixed treatment of nocons in Sargan and C-stat, and corrected problems
*          relating to use of nocons combined with a constant as an IV
*  1.0.7:  first option reports F-test of excluded exogenous; prunelist bug fix
*  1.0.8:  dropped prunelist and switched to housekeeping of variable lists
*  1.0.9:  added collinearity checks; C-stat calculated with recursive call;
*          added ffirst option to report only F-test of excluded exogenous
*          from 1st stage regressions
*  1.0.10: 1st stage regressions also report partial R2 of excluded exogenous
*  1.0.11: complete rewrite of collinearity approach - no longer uses calls to
*          _rmcoll, does not track specific variables dropped; prunelist removed
*  1.0.12: reorganised display code and saved results to enable -replay()-
*  1.0.13: -robust- and -cluster- now imply -small-
*  1.0.14: fixed hascons bug; removed ivreg predict fn (it didn't work); allowed
*          robust and cluster with z stats and correct dofs
*  1.0.15: implemented robust Sargan stat; changed to only F-stat, removed chi-sq;
*          removed exog option (only orthog works)
*  1.0.16: added clusterised Sargan stat; robust Sargan handles collinearities;
*          predict now works with standard SE options plus resids; fixed orthog()
*          so it accepts time series operators etc.
*  1.0.17: fixed handling of weights.  fw, aw, pw & iw all accepted.
*  1.0.18: fixed bug in robust Sargan code relating to time series variables.
*  1.0.19: fixed bugs in reporting ranks of X'X and Z'Z
*          fixed bug in reporting presence of constant
*  1.0.20: added GMM option and replaced robust Sargan with (equivalent) J;
*          added saved statistics of 1st stage regressions
*  1.0.21: added Cragg HOLS estimator, including allowing empty endog list;
*          -regress- syntax now not allowed; revised code searching for "_cons"
*  1.0.22: modified cluster output message; fixed bug in replay for Sargan/Hansen stat;
*          exactly identified Sargan/Hansen now exactly zero and p-value not saved as e();
*          cluster multiplier changed to 1 (from buggy multiplier), in keeping with
*          eg Wooldridge 2002 p. 193.
*  1.0.23: fixed orthog option to prevent abort when restricted equation is underid.
*  1.0.24: fixed bug if 1st stage regressions yielded missing values for saving in e().
*  1.0.25: Added Shea version of partial R2
*  1.0.26: Replaced Shea algorithm with Godfrey algorithm
*  1.0.27: Main call to regress is OLS form if OLS or HOLS is specified; error variance
*          in Sargan and C statistics use small-sample adjustment if -small- option is
*          specified; dfn of S matrix now correctly divided by sample size
*  1.0.28: HAC covariance estimation implemented
*          Symmetrize all matrices before calling syminv
*          Added hack to catch F stats that ought to be missing but actually have a
*          huge-but-not-missing value
*          Fixed dof of F-stat - was using rank of ZZ, should have used rank of XX (couldn't use df_r
*          because it isn't always saved.  This is because saving df_r triggers small stats
*          (t and F) even when -post- is called without dof() option, hence df_r saved only
*          with -small- option and hence a separate saved macro Fdf2 is needed.
*          Added rankS to saved macros
*          Fixed trap for "no regressors specified"
*          Added trap to catch gmm option with no excluded instruments
*          Allow OLS syntax (no endog or excluded IVs specified)
*          Fixed error messages and traps for rank-deficient robust cov matrix; includes
*          singleton dummy possibility
*          Capture error if posting estimated VCV that isn't pos def and report slightly
*          more informative error message
*          Checks 3 variable lists (endo, inexog, exexog) separately for collinearities
*          Added AC (autocorrelation-consistent but conditionally-homoskedastic) option
*          Sargan no longer has small-sample correction if -small- option
*          robust, cluster, AC, HAC all passed on to first-stage F-stat
*          bw must be < T
*  1.0.29  -orthog- also displays Hansen-Sargan of unrestricted equation
*          Fixed collinearity check to include nocons as well as hascons
*          Fixed small bug in Godfrey-Shea code - macros were global rather than local
*          Fixed larger bug in Godfrey-Shea code - was using mixture of sigma-squares from IV and OLS
*            with and without small-sample corrections
*          Added liml and kclass
*  1.0.30  Changed order of insts macro to match saved matrices S and W
*  2.0.00  Collinearities no longer -qui-
*          List of instruments tested in -orthog- option prettified
*  2.0.01  Fixed handling of nocons with no included exogenous, including LIML code
*  2.0.02  Allow C-test if unrestricted equation is just-identified.  Implemented by
*          saving Hansen-Sargan dof as = 0 in e() if just-identified.
*  2.0.03  Added score() option per latest revision to official ivreg
*  2.0.04  Changed score() option to pscore() per new official ivreg
*  2.0.05  Fixed est hold bug in first-stage regressions
*          Fixed F-stat finite sample adjustment with cluster option to match official Stata
*          Fixed F-stat so that it works with hascons (collinearity with constant is removed)
*          Fixed bug in F-stat code - wasn't handling failed posting of vcv
*          No longer allows/ignores nonsense options
*  2.0.06  Modified lsStop to sync with official ivreg 5.1.3
*  2.0.07a Working version of CUE option
*          Added sortpreserve, ivar and tvar options
*          Fixed smalls bug in calculation of T for AC/HAC - wasn't using the last ob
*          in QS kernel, and didn't take account of possible dropped observations
*  2.0.07b Fixed macro bug that truncated long varlists
*  2.0.07c Added dof option.
*          Changed display of RMSE so that more digits are displayed (was %8.1g)
*          Fixed small bug where cstat was local macro and should have been scalar
*          Fixed bug where C stat failed with cluster.  NB: wmatrix option and cluster are not compatible!
*  2.0.7d  Fixed bug in dof option
*  2.1.0   Added first-stage identification, weak instruments, and redundancy stats
*  2.1.01  Tidying up cue option checks, reporting of cue in output header, etc.
*  2.1.02  Used Poskitt-Skeels (2002) result that C-D eval = cceval / (1-cceval)
*  2.1.03  Added saved lists of separate included and excluded exogenous IVs
*  2.1.04  Added Anderson-Rubin test of signif of endog regressors
*  2.1.05  Fix minor bugs relating to cluster and new first-stage stats
*  2.1.06  Fix bug in cue: capture estimates hold without corresponding capture on estimates unhold
*  2.1.07  Minor fix to ereturn local wexp, promote to version 8.2
*  2.1.08  Added dofminus option, removed dof option.  Added A-R test p-values to e().
*          Minor bug fix to A-R chi2 test - was N chi2, should have been N-L chi2.
*          Changed output to remove potentially misleading refs to N-L etc.
*          Bug fix to rhs count - sometimes regressors could have exact zero coeffs
*          Bug fix related to cluster - if user omitted -robust-, orthog would use Sargan and not J
*          Changed output of Shea R2 to make clearer that F and p-values do not refer to it
*          Improved handling of collinearites to check across inexog, exexog and endo lists
*          Total weight statement moved to follow summ command
*          Added traps to catch errors if no room to save temporary estimations with _est hold
*          Added -savefirst- option. Removed -hascons-, now synonymous with -nocons-.
*  2.1.09  Fixes to dof option with cluster so it no longer mimics incorrect areg behavior
*          Local ivreg2_cmd to allow testing under name ivreg2
*          If wmatrix supplied, used (previously not used if non-robust sargan stat generated)
*          Allowed OLS using (=) syntax (empty endo and exexog lists)
*          Clarified error message when S matrix is not of full rank
*          cdchi2p, ardf, ardf_r added to saved macros
*          first and ffirst replay() options; DispFirst and DispFFirst separately codes 1st stage output
*          Added savefprefix, macro with saved first-stage equation names.
*          Added version option.
*          Added check for duplicate variables to collinearity checks
*          Rewrote/simplified Godfrey-Shea partial r2 code
* 2.1.10   Added NOOUTput option
*          Fixed rf bug so that first does not trigger unnecessary saved rf
*          Fixed cue bug - was not starting with robust 2-step gmm if robust/cluster
* 2.1.11   Dropped incorrect/misleading dofminus adjustments in first-stage output summary
* 2.1.12   Collinearity check now checks across inexog/exexog/endog simultaneously
* 2.1.13   Added check to catch failed first-stage regressions
*          Fixed misleading failed C-stat message
* 2.1.14   Fixed mishandling of missing values in AC (non-robust) block
* 2.1.15   Fixed bug in RF - was ignoring weights
*          Added -endog- option
*          Save W matrix for all cases; ensured copy is posted with wmatrix option so original isn't zapped
*          Fixed cue bug - with robust, was entering IV block and overwriting correct VCV
* 2.1.16   Added -fwl- option
*          Saved S is now robust cov matrix of orthog conditions if robust, whereas W is possibly non-robust
*          weighting matrix used by estmator.  inv(S)=W if estimator is efficient GMM.
*          Removed pscore option (dropped by official ivreg).
*          Fixed bug where -post- would fail because of missing values in vcv
*          Remove hascons as synonym for nocons
*          OLS now outputs 2nd footer with variable lists
* 2.1.17   Reorganization of code
*          Added ll() macro
*          Fixed N bug where weights meant a non-integer ob count that was rounded down
*          Fixed -fwl- option so it correctly handles weights (must include when partialling-out)
*          smatrix option takes over from wmatrix option.  Consistent treatment of both.
*          Saved smatrix and wmatrix now differ in case of inefficient GMM.
*          Added title() and subtitle() options.
*          b0 option returns a value for the Sargan/J stat even if exactly id'd.
*          (Useful for S-stat = value of GMM objective function.)
*          HAC and AC now allowed with LIML and k-class.
*          Collinearity improvements: bug fixed because collinearity was mistakenly checked across
*          inexog/exexog/endog simultaneously; endog predicted exactly by IVs => reclassified as inexog;
*          _rmcollright enforces inexog>endo>exexog priority for collinearities, if Stata 9.2 or later.
*          K-class, LIML now report Sargan and J.  C-stat based on Sargan/J.  LIML reports AR if homosked.
*          nb: can always easily get a C-stat for LIML based on diff of two AR stats.
*          Always save Sargan-Hansen as e(j); also save as e(sargan) if homoskedastic.
*          Added Stock-Watson robust SEs options sw()
* 2.1.18   Added Cragg-Donald-Stock-Yogo weak ID statistic critical values to main output
*          Save exexog_ct, inexog_ct and endog_ct as macros
*          Stock-Watson robust SEs now assume ivar is group variable
*          Option -sw- is standard SW.  Option -swpsd- is PSD version a la page 6 point 10.
*          Added -noid- option.  Suppresses all first-stage and identification statistics.
*          Internal calls to ivreg2 use noid option.
*          Added hyperlinks to ivreg2.hlp and helpfile argument to display routines to enable this.
* 2.1.19   Added matrix rearrangement and checks for smatrix and wmatrix options
*          Recursive calls to cstat simplified - no matrix rearrangement or separate robust/nonrobust needed
*          Reintroduced weak ID stats to ffirst output
*          Added robust ID stats to ffirst output for case of single endogenous regressor
*          Fixed obscure bug in reporting 1st stage partial r2 - would report zero if no included exogenous vars
*          Removed "HOLS" in main output (misleading if, e.g., estimation is AC but not HAC)
*          Removed "ML" in main output if no endogenous regressors - now all ML is labelled LIML
*          model=gmm is now model=gmm2s; wmatrix estimation is model=gmm
*          wmatrix relates to gmm estimator; smatrix relates to gmm var-cov matrix; b0 behavior equiv to wmatrix
*          b0 option implies nooutput and noid options
*          Added nocollin option to skip collinearity checks
*          Fixed minor display bug in ffirst output for endog vars with varnames > 12 characters
*          Fixed bug in saved rf and first-stage results for vars with long varnames; uses permname
*          Fixed bug in model df - had counted RHS, now calculates rank(V) since latter may be rank-deficient
*          Rank of V now saved as macro rankV
*          fwl() now allows partialling-out of just constant with _cons
*          Added Stock-Wright S statistic (but adds overhead - calls preserve)
*          Properties now include svyj.
*          Noted only: fwl bug doesn't allow time-series operators.
* 2.1.20   Fixed Stock-Wright S stat bug - didn't allow time-series operators
* 2.1.21   Fixed Stock-Wright S stat to allow for no exog regressors cases
* 2.1.22   Misc fixes.  Fixed bug in AC with aweights; was weighting zi'zi but not ei'ei.
*          Fixed bug in AC; need to clear variable vt1 at start of loop
*          If iweights, Nprec (#obs with precision) rounded to nearest integer to mimic official Stata treatment
