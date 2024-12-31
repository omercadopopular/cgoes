program define ppml_panel_sg, eclass

*! PPML (Panel) Structural Gravity Estimation, by Tom Zylkin
*! Department of Economics, University of Richmond, Richmond, Virginia USA.
*! Options for multi-way clustering are thanks to Joschka Wanner and Mario Larch.
*! This version: v1.11, July 2018
*!
*! Suggested citation: Larch, Wanner, Yotov, & Zylkin (2017): 
*! "The Currency Union Effect: A PPML Re-assessment with High-dimensional Fixed Effects"
*! Drexel University School of Economics Working Paper 2017-07

// requires: reghdfe (if "olsguess" option used), hdfe

// v1.11  - added "dropsingletons" option

// v1.1   - now uses hdfe for faster computation of standard errors
//        - now supports multi-way clustering (with thanks to Joschka Wanner & Mario Larch)
//		  - fixed issue with stored pair FEs varying over time in unbalanced panels
//    	  - industry-level regressions now default to clustering on "pair", not "pair-industry"
//        - New / updated options:
//             * "multiway": automatically cluster by <exporter, importer, year>
//             * "cluster_id" now allows multiple cluster vars for multi-way clustering
//             * "nocheck": skip "check for existence" step
//             * "strict": use stricter condition when determining which variables to drop when checking for existence; mimics "strict" from ppml.
//             * "keep": mimic ppml option "keep".
//             * "noaccel": turn off acceleration during iteration loops

// v1.08  - fixed scaling issue with S, M, and D values
//		  - added "predict" option

// v1.07  - fixed selectidx13() bug; fixed year bug
//        - added checks for if hdfe, reghdfe are installed
//		  - added support for e(sample), e(r2)

// v1.06  - fixed selectindex() backwards compatibility

// v1.05  - added check for existence and check to make sure user-provided IDs uniquely describe data.

// v1.04: - switched to IRLS, made year optional

// v1.03: - fixed display of #obs, loglikelihood 

// v1.02: - updated collinearity warning to address cases where standard errors are computed to be missing.
//		  - also fixed "variable trade not found" bug.

// v1.01: - fixed 3 typos and addressed bug with industry-by-pair time trends


tempvar exclude X_ij Y_w y_i e_j D tt phi fta_effect OMR IMR ///
				ind_id yr_id exp_id imp_id S M panel_id ///
				X_ij_hat temp time lhs exp_time imp_time esample 
tempname beta v1 v1_help n_iter N_obs N_dropped center which id_flag vers ok_flag genfes

scalar `vers' = c(version)

version 11
syntax varlist [if] [in],      ///
   EXporter(varname)           /// 
   IMporter(varname)           /// 
   [                           ///
    Year(varname numeric)      /// 
	INDustry(varname)          ///                          
    guessD(varname numeric)    /// These are useful for nested loops, bootstraps, etc.
	guessO(varname numeric)    /// Defaults: D = O = I = 1; TT = 0.
	guessI(varname numeric)    ///
	guessS(varname numeric)    ///
	guessM(varname numeric)    ///
	guessTT(varname numeric)   ///
	guessB(string)             ///
    genD(name)                 ///
	genTT(name)                ///
    genO(name)                 ///
    genI(name)                 ///
	genS(name)                 ///
	genM(name)                 ///
	PREDict(name)			   ///
	NOsterr                    /// Do not compute standard errors
	RObust					   /// Options for robust SEs and clustered SEs; default is cluster(pair)
	MULTiway			  	   /// automatic multi-way clustering, default is cluster(exporter importer year)
	CLUSter_id(varlist)        /// supports multi-way clustering
	NOPAIR                     /// These options will change the fixed effects structure. "Nopair" = no pair fixed effects
	SYMmetric                  /// Symmetric pair fixed effects (ignored if nopair)
	TREND					   /// use pair-specific linear time trends (ignored if nopair)
	NOCHeck					   /// will skip the check for existence
	DROPSINGletons			   /// Will drop singletons beforehand
	STRICT					   /// will mimic ppml "strict" option
	KEEP					   /// will mimic ppml "keep" option
	OLSguess                   /// use reghfe to guess betas upfront
	OFFset(name)			   /// a user-specified offset, for if, e.g., you wish to impose constraints on coefficients
	NOACCel					   /// Turn off acceleration
	VERBose(int 0)  		   /// 
	TOLerance(real 1e-12)      ///
	MAXiter(int 10000)         ///
	]	

** Ex: ppml_panel_sg trade fta1 fta2 ..., exp(exp_id) imp(imp_id) y(year_id) ind(industry_id)  
**     guessO(<init OMR>) guessO(<init IMR>) guessD(<init D_ij's>) guessB(<init betas>)
**     genD(<output Dij's>) genO(<output OMRs>) genI(<output IMRs>) genS(ex by yr FEs) genM(im by yr FEs) 

	
/** 0.  parse syntax, create temp vars  **/
cap which hdfe
if _rc == 111 {
	di in red "You will need to install -hdfe- in order to use this command."
	di
	di in red "To install, type -ssc install hdfe-".
	exit 111
}

tokenize `varlist'
local trade `1'
macro shift
local policyvars `*'
unab policyvars: `*'

if "`industry'" == "" {
	tempvar industry
	gen `industry' = 1
}
else {
	local dash_ind = "-`industry'"
}

if "`year'" == "" {
	if "`nopair'" == "" {
		di in red "Error: Year ID required if -nopair- option not specified"
		exit 111
	}
	else
	{
		tempvar year
		gen `year' =1
	}
}
					   
local nvars :  word count `policyvars'
*di `nvars'

local rest = "`policyvars'"
forvalues n = 1(1)`nvars' {
	gettoken policyvar_`n' rest: rest
}


/** I. Initialization: flags missing values, checks user inputs for errors, and sets up group IDs, sets initial values for OMR, IMR, D, beta **/
di "Initializing..."

* exclusion catcher
qui gen `exclude' = missing(`trade')

qui sum `trade'
if `r(min)' < 0 {
	di as error "Error: Dependent variable cannot contain negative values"
	exit 111
}

qui forvalues n = 1(1)`nvars' {
	qui replace `exclude' = 1 if missing(`policyvar_`n'')
}

qui marksample touse
qui replace `touse' = 0 if `exclude' 
*marks those specified by [if] or [in] as 1, zero otherwise

if "`offset'" == "" {	//user-defined offset to be passed as an option to sg_ppml_iter algorithm.
	tempvar offset
	cap gen `offset' = 0 if `touse'  
}
else {
	qui replace `touse' = 0 if missing(`offset')   
}

qui gen `X_ij' = `trade' * (1-`exclude') * (`touse') 

// set up IDs 
qui egen `ind_id' = group(`industry') if `touse'
qui egen `yr_id'  = group(`year')     if `touse'
qui egen `exp_id' = group(`exporter') if `touse'
qui egen `imp_id' = group(`importer') if `touse'

qui sum `year' if `touse'
qui gen     `time' = `year' - `r(min)' if `touse'
qui replace `time' = 0 if "`trend'" == ""

if (r(sd) == 0) {
	if "`nopair'" == "" {
		di in red "Error: More than 1 time period required if -nopair- option not specified"
		exit 111
	}
	local one_yr_only = "one year only"
}
else {
	local dash_year = "-`year'"
}

local id_flag = 0
local check_ids = "`exp_id' `imp_id' `ind_id' `yr_id'"							// Check to make sure each obs. is uniquely ID'd by a single 
mata: id_check("`check_ids'",  "`touse'")										// origin, destination, industry, and time						
if `id_flag' != 0 {
	di in red "Error: the set of origin, destination, industry, and time IDs do not uniquely describe the data"
	di in red "If this is not a mistake, try collapsing the data first using collapse (sum)" 
	exit 111
}

mata: country_ids("`exporter'", "`importer'", "`exp_id'", "`imp_id'", "`vers'","`touse'")  //creates unique country IDs, for cases where the set of exporters is not the 
																				           //same as the set of importers
																					   
																				  
// II. Set up fixed effects structure and check for collinearity and possible non-existence of estimates
if "`nocheck'" == "" {
di "Checking for possible non-existence issues..."	
}

qui egen `exp_time' = group(`yr_id' `ind_id' `exp_id') if `touse'
qui egen `imp_time' = group(`yr_id' `ind_id' `imp_id') if `touse' 
if "`nopair'" != "" {
	scalar `which' = 2
	if "`symmetric'" != "" {
		di in red "Option -symmetric- ignored, since -nopair- enabled"
	}
	if "`trend'" != "" {
		di in red "Option -trend' ignored, since -nopair- enabled"
	}
	qui gen `panel_id' = 1 if `touse'
	local _fes = "`exp_time' `imp_time'"
}
else if "`symmetric'" != "" {
	tempvar pair_id symm_id
	gen `pair_id' = `exporter' + `importer'
	qui replace `pair_id' = `importer' + `exporter' if (`importer' < `exporter')
	qui egen `panel_id' = group(`industry' `exporter' `importer') if `touse'
	qui egen `symm_id' = group(`industry' `pair_id') if `touse'
	
	if "`trend'" != "" {
		scalar `which' = 4
		local _fes = "`exp_time' `imp_time' `symm_id'##c.`time'"
	}
	else {
		scalar `which' = 1
		local _fes = "`exp_time' `imp_time' `symm_id'"
	}
}
else {
	qui egen `panel_id' = group(`industry' `exporter' `importer') if `touse'
	if "`trend'" != "" {
		scalar `which' = 3
		local _fes = "`exp_time' `imp_time' `panel_id'##c.`time'"
	}
	else {
		scalar `which' = 0
		local _fes = "`exp_time' `imp_time' `panel_id'"
	}
}

if "`dropsingletons'" != "" {
	* drop singletons
	tempvar ln_LHS 
	qui gen `ln_LHS' = ln(`X_ij'+1) - `offset'
	qui reghdfe `ln_LHS' `policyvars' if `touse', absorb(`_fes')                // See Correia (2015): Singletons, Cluster-robust Standard Errors & Fixed Effects: A Bad Mix
	qui sum `X_ij' if e(sample)==0 &`touse'
	di "Number of singleton observations dropped = " as result r(N)
	qui replace `exclude'=1 if e(sample)==0
	qui replace `touse' = 0 if `exclude' 
	qui replace `X_ij' = `trade' * (1-`exclude') * (`touse')
}

//EnsureExist borrows concepts from "RemoveCollinear" by Sergio Correia, originally from -reghdfe-
if "`nocheck'" == "" {
	EnsureExist if `touse', dep(`X_ij') indep(`policyvars') off(`offset') fes(`_fes') flag(`ok_flag') `strict' `keep'	
	local policyvars `r(okvars)'
	local nvars :  word count `policyvars'	
	local rest = "`policyvars'"
	if "`policyvars'" == "" {
		di
		di in red "Error: all main covariates appear to be collinear with the implied set of fixed effects"
		exit 111
	}
	if ("`keep'"== "") {
		qui cap replace `touse' = `ok_flag'
	}
	forvalues n = 1(1)`nvars' {
		gettoken policyvar_`n' rest: rest
	}
}

qui sum `X_ij'
scalar `center' = `r(mean)'
qui replace `X_ij' = `X_ij' / `center' 	//otherwise, the algorithm for computing s.e.s will be sensitive to the scale of the dep. var.

cap gen `Y_w' = .
cap gen `y_i' = .
cap gen `e_j' = .

// The default is that initial `trade' is "frictionless": D=1, ln_phi = 0 ==> IMR = OMR = 1
// The option "olsguess" uses -reghdfe- to initialize betas based on OLS.
if "`olsguess'"!="" {
	cap which reghdfe
	if _rc == 111 {
		di in red "You will need to install -reghdfe- in order to use the -olsguess- option."
		di
		di in red "To install, type -ssc install reghdfe-".
		exit 111
	}
	tempvar ln_LHS
	qui gen `ln_LHS' = ln(`X_ij') - `offset'
	qui reghdfe `ln_LHS' `policyvars' if `touse', absorb(`_fes')
	qui gen `OMR' = 1 if `touse'
	qui gen `IMR' = 1 if `touse'
	qui gen `D'   = 1 if `touse'
	qui gen `tt'  = 0 if `touse' 
	matrix `beta' = J(1, `nvars',0)
	forvalues n = 1(1)`nvars' {
		matrix `beta'[1, `n'] = _b[`policyvar_`n'']
	}
	matrix colnames `beta' = `policyvars'
}
else {
	//else: either use user-specified guesses
	//or: default guess is "frictionless trade: D=1, ln_phi = 0 ==> IMR = OMR = 1
	qui gen `D'   = 1 if `touse'
	qui gen `tt'  = 0 if `touse'
	qui gen `OMR' = 1 if `touse'
	qui gen `IMR' = 1 if `touse'
	if `which' != 2 {
		qui cap replace `D'  = `guessD'  if "`guessD'"  != "" & `touse'
		if (`which' == 3 | `which' == 4) {
			qui cap replace `tt' = `guessTT' if "`guessTT'" != "" & `touse'
		}
	}
	if "`guessO'" != "" {
		qui cap replace `OMR' =  `guessO' if `touse'
	}
	else if "`guessS'" != "" {
		qui cap replace `OMR' = -`guessS' if `touse' // use negative sign to flag as S, not OMR
	}
	if "`guessI'" != "" {
		qui cap replace `IMR' =  `guessI' if `touse'
	}
	else if "`guessM'" != "" {
		qui cap replace `IMR' = -`guessM' if `touse' // use negative sign to flag as M, not IMR
	}
	
	matrix `beta' = J(1, `nvars',0)
	if "`guessB'" != "" {
		local nguesses = min(`nvars',colsof(`guessB')) 
		qui forvalues n = 1(1)`nguesses' {
			cap matrix `beta'[1, `n'] = `guessB'[1,`n']  * (rowsof(`guessB') != .) 
		}
	}
	matrix colnames `beta' = `policyvars'
}

scalar `genfes' = 1
if "`genD'`genTT'`genO'`genO'`genI'`genS'`genM'" != "" {
	scalar `genfes' = 1   // if user wants to store fes
}


/** III. Iterate on fixed effects using structural gravity and compute Poisson estimates **/
di "Iterating..."
local mata_varlist_iter = "`ind_id' `yr_id' `exp_id' `imp_id' `X_ij' `D' `OMR' `IMR' `tt' `time' `offset'"  //"offset" is the user-specified offset

// compute beta iteratively:
mata: sg_ppml_iter("`policyvars'", "`mata_varlist_iter'", "`beta'", ///
                     "`Y_w'", "`y_i'", "`e_j'", "`which'", ///
					 "`n_iter'", "`N_obs'", "`N_dropped'", "`tolerance'", "`maxiter'",   /// 
					 "`genfes'", "`noaccel'", "`verbose'", "`vers'", "`touse'" )  
				 
qui gen `temp' = log((`y_i' * `e_j' * `Y_w') * (`D' / (`OMR' * `IMR')))+(`tt'*`time')+`offset'+log(`center')

matrix colnames `beta' = `policyvars'
qui gen `lhs' = `X_ij' * `center'
qui poisson `lhs' `policyvars' if `touse', offset(`temp') from(`beta') noconst	 // computes e() statistics		 
qui drop `temp' `lhs'
	
matrix colnames `beta' = `policyvars'
matrix rownames `beta' = coeff						 
estimates table, keep(`policyvars')			    //note that the constant is absorbed by `temp'
di "iterations: " `n_iter'
di "tolerance: "   `tolerance'					
					  
if `n_iter' == `maxiter' {
	di in red "Max number of iterations reached before estimates converged. Consider adjusting the maxiter() option"
	di
}

qui gen `esample'  = e(sample)
local ll =e(ll)	

		
/** IV. Compute standard errors (if option enabled) and set up for posting. **/
if "`nosterr'"=="" {
	di as text "Computing standard errors"
	
	if "`multiway'" != "" & `which' != 2 {
		local display_ses = "Multi-way clustered SEs, clustered by `exporter', `importer', `year'"
	}
	else if "`multiway'" != "" {
		if "`one_yr_only'"=="" {
			local display_ses = "Multi-way clustered SEs, clustered by `exporter', `importer', `year'"
		}
		else {
			local display_ses = "Multi-way clustered SEs, clustered by `exporter', `importer'"
		}
	}
	else if "`cluster_id'" != "" {
	
		// check cluster vars input by user for errors
		local ncvars :  word count `cluster_id'
		if (`ncvars' > 4) {
			local ncvars = 4
			tokenize `cluster_id'
			local cluster_id `1' `2' `3' `4'
			di
			di in red "Max allowed cluster vars is 4. Only <`cluster_id'> will be used."
		}

		local ncvars :  word count `cluster_id'
		tokenize `cluster_id'
		local cluster_id = ""
		forvalues i = 1(1)`ncvars'{
			qui sum ``i'' if `touse'
			if r(sd) != 0 {
				local cluster_id `cluster_id' ``i''
			}
			else {
				di in red "Cluster var ``i'' does not vary over the sample and will be ignored"
			}	
		}
		
		if "`cluster_id'" != "" {
			local display_ses = "Clustered standard errors, clustered by `cluster_id' (user-specified)"
		}
		else if `which'==2 {
			local display_ses = "Robust standard errors (default)"
		}
		else {
			local display_ses = "Clustered standard errors, clustered by `exporter'-`importer' (default)"
		}
	}
	else if "`robust'" != ""{
		local display_ses = "Robust standard errors"
	}
	else if `which'==2 {
		local display_ses = "Robust standard errors (default)"
	}
	else {
		local display_ses = "Clustered standard errors, clustered by `exporter'-`importer' (default)"
	}
	
	* update "phi" one last time
	qui gen `fta_effect' = 0
	forvalues n = 1(1)`nvars' {
		matrix `beta'[1, `n'] = _b[`policyvar_`n'']
		qui replace `fta_effect' = `fta_effect' + `beta'[1, `n']  * `policyvar_`n''
	}
	qui gen `phi' = `D' * exp(`tt'*`time') * exp(`fta_effect') * exp(`offset')
	qui replace `phi' = 0 if missing(`phi') | `exclude' | !`touse'
	
	*** 1. fit X_ij directly using structural gravity
	qui gen `X_ij_hat' = (`y_i' * `e_j' * `Y_w') * (`phi' / (`OMR' * `IMR'))
	qui gen `temp'=sqrt(`X_ij_hat')
	
	
	*** 2. "expurgate" the fixed effects from each policyvar:
	cap drop _s_*
	cap drop _r_*
	qui hdfe `policyvars' if `touse' [pw=`X_ij_hat'], absorb(`_fes') gen(_r_) keepsingletons 
	
	foreach var of varlist `policyvars' {
		qui replace _r_`var' = _r_`var' * sqrt(`X_ij_hat')
		qui replace `touse' = 0 if missing(_r_`var') 
		
		// What you are getting out of this is the residual associated with each policy var after netting out the FEs via weighted linear regression.
		// You weight by each residual by the square root of the conditional mean because this is the weight that is implicitly
		// used by the PPML estimator. See: Figuereido, Guimaraes, and Woodward JUE 2015.
	}
	
	
	*** 3. Regress the original dep var on resulting weighted residuals of the policy vars after "expurgating" the influence of the fixed effects.
	qui _regress `X_ij' _r_* if `touse', nocons      

	// The VCV of the betas from this regression is proportional to the VCV you would have obtained from
    // a Poisson regression with the fixed effects included.
	// This is an application of the Frisch-Waugh-Lovell theorem. See: Figueiredo, Guimaeraes, & Woodward JUE 2015

	local s2=e(rmse)*e(rmse)
	matrix `v1'=e(V)/`s2'
	local N=e(N)
	

	*** 4. Adjust standard errors for clustering using _robust. Default is clustered SEs, clustered by country-pair.
	
	*** 4a. Compute standard errors
	
	// I would like to thank Joschka Wanner and Mario Larch for contributing the majority of the code used for the 
	// case of "multi-way" clustering. For a reference on multi-way clustering, see Cameron, Gelbach, and Miller JBES 2011.
	
	qui replace `temp'=(`X_ij'-`temp'*`temp')/`temp'                            // multiple use of "temp" may be confusing. "temp" here initially is sqrt(Xij_hat),
																			    // then becomes the reidual divided by sqrt(Xij_hat).
		
	if "`multiway'" != "" {                                 					// apply default multi-way clustering (i.e., exporter, importer, year)
		
		tempname v_exp v_imp v_yr v_pair v_expyr v_impyr v_expimpyr expimpyr
		
		if ("`dash_ind'" != "") {
			drop `exp_time'
			drop `imp_time'
			drop `panel_id'
			qui egen `exp_time' = group(`yr_id' `exp_id') if `touse'
			qui egen `imp_time' = group(`yr_id' `imp_id') if `touse'
			qui egen `panel_id' = group(`exp_id' `imp_id') if `touse'
		}
		if ("`one_yr_only'" == "") {
			matrix `v_exp' = `v1'
			_robust `temp' if `touse', v(`v_exp') cluster(`exp_id') 
			matrix `v_imp'  =`v1'
			_robust `temp' if `touse', v(`v_imp') cluster(`imp_id')
			matrix `v_yr'=`v1'
			_robust `temp' if `touse', v(`v_yr') cluster(`yr_id')
			matrix `v_expyr'=`v1'			
			_robust `temp' if `touse', v(`v_expyr') cluster(`exp_time')		
			matrix `v_impyr'=`v1'				
			_robust `temp' if `touse', v(`v_impyr') cluster(`imp_time')
			matrix `v_pair'=`v1'
			_robust `temp' if `touse', v(`v_pair') cluster(`panel_id')
			matrix `v_expimpyr'=`v1'		
			qui egen `expimpyr'=group(`exp_id' `imp_id' `yr_id') if `touse'
			_robust `temp' if `touse', v(`v_expimpyr') cluster(`expimpyr')
			matrix `v1'=`v_exp'+`v_imp'+`v_yr'-`v_expyr'-`v_impyr'-`v_pair'+`v_expimpyr'
		}
		else {
			matrix `v_exp' = `v1'
			_robust `temp' if `touse', v(`v_exp') cluster(`exp_id') 
			matrix `v_imp'  =`v1'
			_robust `temp' if `touse', v(`v_imp') cluster(`imp_id')
			matrix `v_pair'=`v1'
			_robust `temp' if `touse', v(`v_pair') cluster(`panel_id')
			matrix `v1'=`v_exp'+`v_imp'-`v_pair'
		}
	}
	else if "`cluster_id'" != "" {											    // "cluster_id" is a varname or varlist input by user. THe max # of vars allowed for multi-way clustering is 4.
		
		local ncvars :  word count `cluster_id'
		local rest = "`cluster_id'"
		forvalues n = 1(1)`ncvars' {
			gettoken clusvar_`n' rest: rest
		}
		if (`ncvars' == 1) {
			_robust `temp' if `touse', v(`v1') cluster(`clusvar_1')
		}
		else if (`ncvars' == 2) {
			forvalues i = 1(1)`ncvars'{
				tempname v1_`i' id`i'
				qui egen `id`i'' = group(`clusvar_`i'') if `touse'
				matrix `v1_`i'' = `v1'
				_robust `temp' if `touse', v(`v1_`i'') cluster(`id`i'')
			}
			tempname v1_12 id12
			qui egen `id12' = group(`clusvar_1' `clusvar_2') if `touse'
			matrix `v1_12' = `v1'
			_robust `temp' if `touse', v(`v1_12') cluster(`id12')
			
			matrix `v1' = `v1_1' + `v1_2' - `v1_12'
		}
		
		else if (`ncvars' == 3) {
			forvalues i = 1(1)`ncvars'{
				tempname v1_`i' id`i'
				qui egen `id`i'' = group(`clusvar_`i'') if `touse'
				matrix `v1_`i'' = `v1'
				_robust `temp' if `touse', v(`v1_`i'') cluster(`id`i'')
				local ip1 = `i'+1
				forvalues j = `ip1'(1)`ncvars'{
					tempname v1_`i'`j' id`i'`j'
					qui egen `id`i'`j'' = group(`clusvar_`i'' `clusvar_`j'') if `touse'
					matrix `v1_`i'`j'' = `v1'
					_robust `temp' if `touse', v(`v1_`i'`j'') cluster(`id`i'`j'')
				}
			}
			tempname v1_123 id123
			qui egen `id123' = group(`clusvar_1' `clusvar_2' `clusvar_3') if `touse'		
			matrix  `v1_123' = `v1'
			_robust `temp' if `touse', v(`v1_123') cluster(`id123')
			
			matrix `v1' = `v1_1' + `v1_2' + `v1_3' - `v1_12' - `v1_13' - `v1_23' + `v1_123'
		}
		else if (`ncvars' == 4) {
			forvalues i = 1(1)`ncvars'{
				tempname v1_`i' id`i'
				qui egen `id`i'' = group(`clusvar_`i'') if `touse'
				matrix `v1_`i'' = `v1'
				_robust `temp' if `touse', v(`v1_`i'') cluster(`id`i'') 
				local ip1 = `i'+1
				forvalues j = `ip1'(1)`ncvars'{
					tempname v1_`i'`j' id`i'`j'
					qui egen `id`i'`j'' = group(`clusvar_`i'' `clusvar_`j'') if `touse'
					matrix `v1_`i'`j'' = `v1'
					_robust `temp' if `touse', v(`v1_`i'`j'') cluster(`id`i'`j'')
					local jp1 = `j'+1
					forvalues k = `jp1'(1)`ncvars'{
						tempname v1_`i'`j'`k' id`i'`j'`k'
						qui egen `id`i'`j'`k'' = group(`clusvar_`i'' `clusvar_`j'' `clusvar_`k'') if `touse'
						matrix `v1_`i'`j'`k'' = `v1'
						_robust `temp' if `touse', v(`v1_`i'`j'`k'') cluster(`id`i'`j'`k'')
					}
				}
			}			
			matrix `v1' =  `v1_1'+`v1_2'+`v1_3'+`v1_4'-`v1_12'-`v1_13'-`v1_14'-`v1_23'-`v1_24'-`v1_34'+`v1_123'+`v1_124'+`v1_234'
		}
	}
	else if "`robust'"!="" {
		_robust `temp' if `touse', v(`v1')
	}
	else if `which'==2 {														// these are the defaults if user does not specify any particular options.
		_robust `temp' if `touse', v(`v1')
	}
	else {
		if ("`dash_ind'" != "") {
			drop `panel_id'
			egen `panel_id' = group(`exp_id' `imp_id')
		}
		_robust `temp' if `touse', v(`v1') cluster(`panel_id')
	}
	
	*** 4b. Replace eigenvalues with zeros for cases where multiple clustering leads to negative variances 
	
	//      References: Politis, Econometric Theory 2011; Cameron, Gelbach and Miller JBES 2011 
	
	if "`cluster_id'" != "" | "`multiway'" != "" {
		tempname Eigenvec lambda lambdaN lambdap lambdapdiag v1N detv1
	
		local v1N = colsof(`v1')
	
		scalar Indnegvar = 0
	
		forvalues l=1(1)`v1N' {
			if `v1'[`l',`l']<0 {
				scalar Indnegvar = 1
			}
		}
		
		matrix `detv1'=det(`v1')
		scalar Inddet = 0
		if `detv1'[1,1]<1e-10 {
			scalar Inddet = 1
		}
	
		if (Indnegvar==1 | Inddet==1) {
			matrix symeigen `Eigenvec' `lambda' = `v1'
			local lambdaN = colsof(`lambda')
			matrix `lambdap' = `lambda'
			forvalues l=1(1)`lambdaN' {
				if `lambda'[1,`l']>0 {
					matrix `lambdap'[1,`l'] = `lambda'[1,`l']
				}
				else {
					matrix `lambdap'[1,`l'] = 0
				}
			}
			matrix `lambdapdiag' = diag(`lambdap')
			matrix `v1'=`Eigenvec'*`lambdapdiag'*(`Eigenvec')'
		}	
	}
	
	*** 5. Post estimation results to Stata
	ereturn clear	
	matrix colnames `beta' = `policyvars'
	matrix colnames `beta' = `trade':
	
	matrix rownames `v1' = `policyvars' 
	matrix rownames `v1' = `trade':
	matrix colnames `v1' = `policyvars'
	matrix colnames `v1' = `trade':
	
	//qui sum(`X_ij')
	//local N = r(N)
	ereturn post `beta' `v1', depname(`trade') obs(`N') esample(`esample')
	qui corr `X_ij_hat' `X_ij' if `touse'
	ereturn scalar r2 = r(rho)^2 
	
	cap drop _s_*
	cap drop _r_*  //make these temp vars
}


else {
	di "You have opted not to compute standard errors."
	if "`predict'" != "" {
		qui gen `fta_effect' = 0		
		forvalues n = 1(1)`nvars' {
			matrix `beta'[1, `n'] = _b[`policyvar_`n'']
			qui replace `fta_effect' = `fta_effect' + `beta'[1, `n']  * `policyvar_`n''
		}	
		qui gen `phi' = `D' * exp(`tt'*`time') * exp(`fta_effect') * exp(`offset')
		qui replace `phi' = 0 if missing(`phi') | `exclude' | !`touse'		
		qui gen `X_ij_hat' = (`y_i' * `e_j' * `Y_w') * (`phi' / (`OMR' * `IMR'))
	}
	ereturn clear
	local N=`N_obs'	
	//qui sum(`X_ij')
	//local N = r(N)	
	eret post `beta', depname(`trade') obs(`N') esample(`esample')
} 

// store fixed effects in memory if requested by user
cap drop `genO'
cap drop `genI'
cap drop `genD'
cap drop `genTT'
cap drop `genS'
cap drop `genM'
cap drop `predict'
cap gen  `genS' = `y_i' * sqrt(`Y_w'*`center') / `OMR'
cap gen  `genM' = `e_j' * sqrt(`Y_w'*`center') / `IMR'
cap gen  `predict' = `X_ij_hat' * `center'
cap rename `OMR' `genO'
cap rename `IMR' `genI'
cap rename `D'   `genD'
cap rename `tt'  `genTT'

ereturn scalar ll=`ll'
ereturn local cmdline "ppml_panel_sg `0'"
ereturn local cmd "ppml_panel_sg"
ereturn local crittype "log likelihood"


// V. Display final regression table and notes
Display

if (`which' == 0 | `which' == 3){
	local pair = "`exporter'-`importer'`dash_ind'"
	di "Fixed Effects included: `exporter'`dash_ind'`dash_year', `importer'`dash_ind'`dash_year', `pair'" 
	if `which' == 3 {
		di "Also includes `pair' time trends"
	}
} 
else if (`which' == 1 | `which' == 4){
	local pair = "`exporter'-`importer'`dash_ind'"
	di "Fixed Effects included: `exporter'`dash_ind'`dash_year', `importer'`dash_ind'`dash_year', `pair' (symmetric)"
	if `which' == 4 {
		di "Also includes (symmetric) `pair' time trends"
	}
}
else if  (`which' == 2) {
	di "Fixed Effects included: `exporter'`dash_ind'`dash_year', `importer'`dash_ind'`dash_year'"
}

if "`nosterr'"=="" {
	di "`display_ses'"
	if (`N_dropped' > 0) {
		local `N_dropped' = `N_dropped'
		di "``N_dropped'' obs. dropped because they belong to groups with all zeros or missing values"
	} 
	di 
	foreach var of varlist `policyvars' {
		if (abs(_b[`var']) / _se[`var'] < .001) | (abs(_b[`var']) / _se[`var'] == .) {
			di in red "`var' appears to be collinear with your set of fixed effects"
			di as text
		}
	}
}
else {
	if (`N_dropped' > 0) {
		local `N_dropped' = `N_dropped'
		di "``N_dropped'' obs. dropped because they belong to groups with all zeros or missing values"
	} 
	di
}

end


/***************************************************************************************/
/*   ENSUREEXIST (adapted  from "RemoveCollinear", by Sergio Correia. see: -reghdfe-) */
/***************************************************************************************/

// -  In general, a covariate "x" should be dropped if, after netting out FEs and the other covariates,
//    there is no residual variation in x within the subsample where lhs > 0.
// -  Also serves as generalized check for collinearity of covariates
// -  Requires using -hdfe- first to partial out FEs from each covariate
// -  Reference: Santos Silva & Tenreyro EL 2010 "On the Existence of MLE Estimates for Poisson Regression" 

*EnsureExist if `touse', dep(`X_ij') indep(`policyvars') off(`offset') resid(`resid_')
program define EnsureExist, rclass
	syntax [if] [in], 			///
	DEPvar(varname numeric) 	///
	INDEPvars(varlist numeric)	///
	OFFset_weight(string)		///
	FEs(string)					///
	flag(name)					///
	[ STRICT					/// 
	  KEEP	]				    ///
	
	qui marksample touse
	tempname resid1
	tempvar  zeros
	qui hdfe `indepvars' if `touse'&`depvar'>0, absorb(`fes') gen(`resid1')
		
	qui _rmcoll `offset_weight' `resid1'* if `touse' & `depvar'>0, forcedrop  // check simple collinearity across `policyvars'
	local okvars = r(varlist)
	if ("`okvars'"==".") local okvars
	local df_m : list sizeof okvars
	
	foreach var of local indepvars {
		local resid_var = "`resid1'`var'"
		local ok1 : list resid_var in okvars
		qui sum `resid1'`var' if `touse' & `depvar'>0
		local _mean_r = r(mean)
		local ok2 = (`r(sd)'>1e-9)												 // residuals are net of FEs; ~0 residual variation implies
																				 // collinearity with one or more of the FEs.
		local ok  = (`ok1'&`ok2')
		if (`ok' == 0) {
						
			qui sum `var' if `touse'&`depvar'==0
			local min = r(min)
			local max = r(max)
			if (`min'<`_mean_r')&(`max'>`_mean_r'&"`strict'"=="") {
				local ok = 1												// this is an analogue of the "reasonable overlap" condition used in -ppml- which determines whether	
			}																// it is still possible to include x
			else {
				qui sum `var' if `touse' & `depvar'>0
				local _mean = r(mean)				
				if ("`keep'" == "" & (`min'>=`_mean')|(`max'<=`_mean')) {
					local drop = "drop"
					cap gen `zeros'=1
					qui sum `var' if `touse', d
					local _mad=r(p50)
					qui inspect `var'     if `touse'
					qui replace `zeros'=0 if (`var'!=`_mad')&(r(N_unique)==2)&(`touse')       // Mark observations to drop (if "keep" not enabled)
				}
			}
		}
		local prefix = cond(`ok', "", "o.")
		local label : char `var'[name]
		if (!`ok') di in red "note: `var' omitted because of collinearity over lhs>0 (creates possible existence issue)"
		local varlist `varlist' `prefix'`var'
		if (`ok') local okvarlist `okvarlist' `var'
	}
	
	if ("`keep'" == "" & "`drop'" != "") {
		qui su `touse' if `touse', mean
		local _enne=r(sum)
		qui replace `touse'=0 if (`zeros'==0)&(`depvar'==0)&(`touse')
		qui su `touse' if `touse', mean
		local _enne = `_enne' - r(sum) 
		if (`_enne' > 0) {
			di in red "note: `_enne' observations dropped because they are perfectly predicted by excluded regressors"
			di in red "      (you may use the -keep- option if you would prefer to keep these observations)"
		}
		qui gen `flag' = `touse'
	}	
	mata: st_local("vars", strtrim(stritrim( "`varlist'" )) )
	mata: st_local("okvars", strtrim(stritrim( "`okvarlist'" )) )
	return local vars "`vars'"
	return local okvars "`okvars'"
	return scalar df_m = `df_m'
end


/*************************************************************************/
/* DISPLAY (adopted from "Display", by Paulo Guimaraes. see: -poi2hdfe-) */
/*************************************************************************/
program define Display
_coef_table_header, title( ******* PPML Panel Structural Gravity Estimation ********** )
_coef_table, level(95)
end


					/*** mata code starts here ***/
					
/*************************************************************/
/* CHECK_ID (checks whether ID vars uniquely describe data)  */
/*************************************************************/

// Sometimes users may make a mistake in providing duplicate observations for the same trade flow.
// This will generate a error letting them know. If this is not done by accident,
// an equivalent specification can be performed by collapsing the data first.

mata:
void id_check(string scalar idvars,| string scalar touse)
{
	
	st_view(id_vars,.,tokens(idvars), touse)
	uniq_ids = uniqrows(id_vars)
	if (rows(id_vars) != rows(uniq_ids)) {
		st_local("id_flag", "1")
	}	
}
					
/*******************************************************************/
/* COUNTRY_IDS (sets up unique numerical exporter and importer IDs) */
/*******************************************************************/
					
// This code only comes into play if the set of exporters differs from the set of
// importers.

mata:
void country_ids(string scalar exp_name, string scalar imp_name, string scalar exp_id_var, 
                 string scalar imp_id_var, string scalar vers,| string scalar touse)
{
	EXP_NAMES = st_sdata(.,tokens(exp_name), touse)
	IMP_NAMES = st_sdata(.,tokens(imp_name), touse)
	
	st_view(exp_id,.,tokens(exp_id_var), touse)
	st_view(imp_id,.,tokens(imp_id_var), touse)
	
	vers = st_numscalar(tokens(vers))
	
	exp_uniq = uniqrows(EXP_NAMES)
	imp_uniq = uniqrows(IMP_NAMES)
	
	NN_ex = rows(exp_uniq)
	NN_im = rows(imp_uniq)
	NN_c  = min((NN_ex, NN_im))
	
	exp_id_uniq = (1..NN_ex)'
	imp_id_uniq = (1..NN_im)'

	//Constructing country ids requires tracking countries which only appear as 
	//exporters, but not as importers, and vice versa.
	for (c=1; c<=NN_c-1; c++) {
		if (select(exp_uniq,exp_id_uniq:==c) != select(imp_uniq,imp_id_uniq:==c)) {  
			if (select(exp_uniq,exp_id_uniq:==c) < select(imp_uniq,imp_id_uniq:==c)) {
				imp_id_uniq[selectidx(imp_id_uniq:>=c,vers), 1]=imp_id_uniq[selectidx(imp_id_uniq:>=c,vers), 1] :+1
				imp_id[selectidx(imp_id :>= c,vers),.] = imp_id[selectidx(imp_id :>= c,vers),.] :+ 1
				NN_im = NN_im + 1
			} 
		   else {
				exp_id_uniq[selectidx(exp_id_uniq:>=c,vers), 1]=exp_id_uniq[selectidx(exp_id_uniq:>=c,vers), 1] :+1
				exp_id[selectidx(exp_id :>= c,vers),1] = exp_id[selectidx(exp_id :>= c,vers),1] :+1
				NN_ex = NN_ex + 1
		   }
		NN_c  = min((NN_ex, NN_im))
		}
	}
	/*
	uniq_names = uniqrows(EXP_NAMES \ IMP_NAMES)
	NN_c = rows(uniq_names)
	for (c=1; c<=NN_c; c++) {		
		exp_id = (EXP_NAMES:!=uniq_names[c]) :* exp_id + (EXP_NAMES:==uniq_names[c]) :* c
		imp_id = (IMP_NAMES:!=uniq_names[c]) :* exp_id + (IMP_NAMES:==uniq_names[c]) :* c
	}
	*/  // ^ a more concise way to do the same thing, but slower.
}
end

/***************************************************/
/* SG_PPML_ITER (computes PPML estimates for beta) */
/***************************************************/

// This algorithm works by iterating on the system of multilateral resistances in each period, as well as the 
// pair fixed effects and time trend terms which apply across periods, computing a new estimate for
// beta each time through the loop, until betas converge.

mata:
void sg_ppml_iter(string scalar pvars, string scalar mata_varlist_iter, string scalar b, 
				  string scalar Y_w, string scalar y_i, string scalar e_j, string scalar branch, 
				  string scalar n_iter, string scalar N_obs, string scalar N_dropped, string scalar tolerance, string scalar maxiter,
				  string scalar keepfes, string scalar noacc, string scalar verbose,string scalar vers,| string scalar touse)
{
	real matrix M, pv, X, phi, sumXhat, sumX
	real scalar NN_i, NN_y, NN_n
	real colvector check, P, Pi, y, e, Yw, Pi0, P0, Pi1, P1, D, tt
	
	which = st_numscalar(branch)   // governs which specification to be used (e.g. symmetric vs. asymmetric pair FEs, time trends vs. not, etc)
	
	beta = st_matrix(b)'           // guesses for betas (if specified)
	
	st_view(pv, ., tokens(pvars),touse)
	st_view(M, ., tokens(mata_varlist_iter),touse)
	
	ind_id = M[.,1]   // industry id, year id, exporter and importer ids.
	yr_id  = M[.,2]   
	exp_id = M[.,3]   
	imp_id = M[.,4]   
	
	lhs = M[.,5]      // dependent variable  
		
	NN_i  = max(ind_id)   // total #s of included industries, years, and countries, for use in loops
	NN_y  = max(yr_id)
	NN_n = max((max(exp_id), max(imp_id)))
	
	tol  = strtoreal(tolerance)
	max  = strtoreal(maxiter)
	verb = strtoreal(verbose)

	storefes = st_numscalar(keepfes) 
	
	accel_ok = (noacc!="noaccel")
		
	vers = st_numscalar(tokens(vers))
	
	//"X_index" used for passing (unsorted) data to and from (sorted) matrix form.
 	X_index = ( (yr_id:-1) :* NN_i :* NN_n^2 :+ (ind_id:-1) * NN_n^2 :+ (exp_id:-1):* NN_n :+ imp_id)
	
	BIG_N = NN_y*NN_i*NN_n*NN_n
	
	X=D=tt=timevar=user_offset = J(BIG_N,1,0) 	//Note: imposing phi=X=0 is consistent with treating an observation as missing.
		
	X[X_index,1]       = M[.,5] // M[.,5] is trade
	D[X_index,1]       = M[.,6] // M[.,6] is "D"
	tt[X_index,1]      = M[.,9]  // M[.,9] is the set of linear trend coefficients (if trend specified)
	timevar[X_index,1] = M[.,10] // time intervals for use with trends
	
	user_offset[X_index,1] = M[.,11] // user-specified offset, for constraints, etc.
	
	X = colshape(X,NN_n)  // matricizes X as a (sorted) (NN_t * NN_i * NN_n) x (NN_n) matrix
	
	//set up initial, sorted MR terms 
	Pi0 = P0 = P1 = Pi1 =  J(NN_i * NN_y * NN_n, 1, 0)
	P_index1        = (yr_id:-1) :* NN_i :* NN_n :+  (ind_id:-1) :* NN_n :+ imp_id
	Pi_index1       = (yr_id:-1) :* NN_i :* NN_n :+  (ind_id:-1) :* NN_n :+ exp_id
	P_index2        = uniqrows(P_index1)
	Pi_index2       = uniqrows(Pi_index1)
	Pi0[Pi_index2,1] = Pi1[Pi_index2,1] = uniqrows( (Pi_index1, M[.,7]) )[.,2]
	P0[P_index2,1]   = P1[P_index2,1]   = uniqrows( (P_index1, M[.,8]) )[.,2] 

	// simple time vector, with one entry per year, sorted from first to last
	time = uniqrows(timevar)
	
	//set up matrices for output and expenditure shares (y and e), sum of trade over time (sumX)
	y = e = Yw =  J(NN_i * NN_y * NN_n, 1, 0)
	
	if (which == 2) {
		sumX   = J(NN_i * NN_n , NN_n, 1)   //which = 2: no pair fixed effects 
	}
	else {
		sumX   = J(NN_i * NN_n , NN_n, 0)
	}
	if (which == 3 | which == 4) {
		Xtrend = countX = J(NN_i * NN_n , NN_n, 0)	//which = 3 or 4: include time trends
	}
	else {
		Xtrend = countX = J(NN_i * NN_n , NN_n, 1)
	}
	
	// construct Y, E, and Yw, as well as sum of X over time.
	for (t=1; t<=NN_y; t++) {
		for (i=1; i <= NN_i; i++) {
			long_index = ((t-1) * NN_i * NN_n + (i-1)*NN_n + 1, 1 \ (t-1) * NN_i* NN_n + (i-1)*NN_n + NN_n, 1)
			wide_index = ((t-1) * NN_i * NN_n +(i-1)*NN_n + 1, 1 \ (t-1) * NN_i * NN_n +(i-1)*NN_n +NN_n,NN_n)

			Yw[|long_index|] = J(NN_n, 1, 1) # sum(X[|wide_index|])
			y[|long_index|] = rowsum(X[|wide_index |]) :/ Yw[|long_index|]
			e[|long_index|] = rowsum(X[|wide_index|]') :/ Yw[|long_index|]	
						
			//sum actual trade values within pairs over time
			//also sum actual trade * t over within pairs over time (for time trends) 
			if (which == 0 | which == 3) {
				sumX[|(i-1)* NN_n + 1, 1 \ (i-1) * NN_n +NN_n,NN_n|] = 
				sumX[|(i-1)* NN_n + 1, 1 \ (i-1) * NN_n +NN_n,NN_n|] +
				X[|wide_index|]
			}
			else if (which == 1 | which == 4) {      //which = 1 or 4: pair fixed effects are symmetric
				sumX[|(i-1)* NN_n + 1, 1 \ (i-1) * NN_n +NN_n,NN_n|] = 
				sumX[|(i-1)* NN_n + 1, 1 \ (i-1) * NN_n +NN_n,NN_n|] +
				X[|wide_index|]+
				X[|wide_index|]'
			}
			if (which == 3) {						//which = 3 or 4: include linear time trends
				Xtrend[|(i-1)* NN_n + 1, 1 \ (i-1) * NN_n +NN_n,NN_n|] = 
				Xtrend[|(i-1)* NN_n + 1, 1 \ (i-1) * NN_n +NN_n,NN_n|] +
				time[t]*X[|wide_index|]
					
				countX[|(i-1)* NN_n + 1, 1 \ (i-1) * NN_n +NN_n,NN_n|] = 
				countX[|(i-1)* NN_n + 1, 1 \ (i-1) * NN_n +NN_n,NN_n|] +
				(X[|wide_index|] :> 0)
			}
			if (which == 4) {
				Xtrend[|(i-1)* NN_n + 1, 1 \ (i-1) * NN_n +NN_n,NN_n|] = 
				Xtrend[|(i-1)* NN_n + 1, 1 \ (i-1) * NN_n +NN_n,NN_n|] +
				time[t]*X[|wide_index|]+
				time[t]*X[|wide_index|]'
					
				countX[|(i-1)* NN_n + 1, 1 \ (i-1) * NN_n +NN_n,NN_n|] = 
				countX[|(i-1)* NN_n + 1, 1 \ (i-1) * NN_n +NN_n,NN_n|] +
				(X[|wide_index|]+X[|wide_index|]' :> 0)
			}
		}
	}
	
	D = D :* colshape( J(NN_y,1,1)#(editmissing(sumX:!=0,0)) ,1)
	
	if (which == 3 | which == 4){
		free_trend = colshape( J(NN_y,1,1)#editmissing(countX :>= 2,0) ,1)		// time trends cannot be ID'd for pairs that do not trade at least twice
		tt = tt :* free_trend
	}
	
	if (min(Pi0)<0) {
		Pi0 = Pi1 = -y:/Pi0  // I set things up so Pi0 < 0 implies user specified "guessS" option, rather than "guessO".
	} 
	if (min(P0)<0) {
		P0  = P1 = -e:/P0    // Likewise for P0 < 0 if user specified "guessM" rather than "guessI".
	} 
	
	YE_Yw  = (y[Pi_index1,.] :* e[P_index1,.] :* Yw[Pi_index1,.])   // = (Y_i * E_j / Y_w), sorted to match the data	(which need not be sorted)
	
	offset =  log((YE_Yw) :/ (Pi1[Pi_index1,.] :* P1[P_index1,.]) :* D[X_index,.] ) + (timevar[X_index,.]:* tt[X_index,.]) + user_offset[X_index,.]
	
	// set up iteration loop
	last_change = change1 = 1
	store_iters = J(rows(beta), rows(beta)+2,.)
	accel_iter1  = accel_iter2 = iter1 = hits = 0 
	even_iter = 1
	if (which == 3 | which == 4) { 
		accel_interval = 250
	}
	else if (which == 2) {
		accel_interval = 50
	}
	else {
		accel_interval = 100
	}
	do {
		phi = J(BIG_N,1,0)
		
		phi[X_index,.] = D[X_index,.] :* exp(timevar[X_index,.]:* tt[X_index,.]) :* exp(pv*beta) :* exp(user_offset[X_index,.])  // "phi" can be thought of as "t^(1-sigma)" from Anderson and van Wincoop (2003) 
		
		phi = colshape(phi,NN_n)
		
		Pi0 = Pi1
		P0  = P1
		if (which == 2) {
			sumXhat = J(NN_i * NN_n , NN_n, 1)
		}
		else {
			sumXhat = J(NN_i * NN_n , NN_n, 0)
		}
		if (which == 3 | which == 4) {
			Xhattrend = J(NN_i * NN_n , NN_n, 0)
			Xhattrend2 = J(NN_i * NN_n , NN_n, 0)
		}
		else {
			Xhattrend = J(NN_i * NN_n , NN_n, 1)
			Xhattrend2 = J(NN_i * NN_n , NN_n, 1)
		}
		for (t=1; t<=NN_y; t++) {
			for (i=1; i<=NN_i; i++) {
				long_index = ((t-1) * NN_i * NN_n + (i-1)*NN_n + 1, 1 \ (t-1) * NN_i* NN_n + (i-1)*NN_n + NN_n, 1)
				wide_index = ((t-1) * NN_i * NN_n +(i-1)*NN_n + 1, 1 \ (t-1) * NN_i * NN_n +(i-1)*NN_n +NN_n,NN_n)
			
				// iterate P0 -> P1 , Pi0 -> Pi1, using P = sum(y*phi/Pi); Pi = sum(e*phi/P)
				P1[|long_index|]  = cross(phi[|wide_index|],  (y[|long_index|] :/ Pi0[|long_index|]))
				Pi1[|long_index|] = cross(phi[|wide_index|]', (e[|long_index |] :/ P1[|long_index|]))
				
				// I normalize MRs by imposing them to be the same magnitude.
				adj = sqrt(sum(Pi1[|long_index|]) :/ sum(P1[|long_index|]))	 
				Pi1[|long_index|] = Pi1[|long_index|] :/ adj
				P1[|long_index|]  = P1[|long_index|]  :* adj
				
				// Sum fitted trade values ("Xhat") over time, using structural gravity: Xhat = (Y*E/Yw) *(phi/(P*Pi)) 
				Xhat = editmissing(
					phi[|wide_index|] :*
					y[|long_index|]  :*
					e[|long_index|]' :*
					Yw[|long_index|] :/
					Pi1[|long_index|] :/
					(P1[|long_index|]'# J(NN_n,1,1)),0)
			
				if (which == 0 | which == 3) {
					sumXhat[|(i-1)* NN_n + 1, 1 \ (i-1) * NN_n +NN_n,NN_n|] = 
					sumXhat[|(i-1)* NN_n + 1, 1 \ (i-1) * NN_n +NN_n,NN_n|] + Xhat
				}

				else if (which == 1 | which == 4) {	//which = 1: symmetric pair fixed effects
					sumXhat[|(i-1)* NN_n + 1, 1 \ (i-1) * NN_n +NN_n,NN_n|] = 
					sumXhat[|(i-1)* NN_n + 1, 1 \ (i-1) * NN_n +NN_n,NN_n|] + Xhat + Xhat'
				}
		
				// For each ij time trend coeff, the Poisson FOC implies: sum_t{t*X_ij}=sum_t{t*X_ij_hat} 
				if (which == 3) {
					Xhattrend[|(i-1)* NN_n + 1, 1 \ (i-1) * NN_n +NN_n,NN_n|] = 
					Xhattrend[|(i-1)* NN_n + 1, 1 \ (i-1) * NN_n +NN_n,NN_n|] +
					time[t]*Xhat
					
					Xhattrend2[|(i-1)* NN_n + 1, 1 \ (i-1) * NN_n +NN_n,NN_n|] =   // the sum_t{t^2*X_ij_hat} term comes from the Taylor Series approx of the FOC (used below)
					Xhattrend2[|(i-1)* NN_n + 1, 1 \ (i-1) * NN_n +NN_n,NN_n|] +
					time[t]^2*Xhat
				}	
				if (which == 4) {
					Xhattrend[|(i-1)* NN_n + 1, 1 \ (i-1) * NN_n +NN_n,NN_n|] = 
					Xhattrend[|(i-1)* NN_n + 1, 1 \ (i-1) * NN_n +NN_n,NN_n|] +
					time[t]*Xhat + time[t]*Xhat' 
					
					Xhattrend2[|(i-1)* NN_n + 1, 1 \ (i-1) * NN_n +NN_n,NN_n|] = 
					Xhattrend2[|(i-1)* NN_n + 1, 1 \ (i-1) * NN_n +NN_n,NN_n|] +
					time[t]^2*Xhat + time[t]^2*Xhat' 
				}
			}
		}
		
		// update pair fixed effect (D) and time trends (tt)
		if (which == 0 | which == 1){
			D  = D  :*  colshape( J(NN_y,1,1)#(editmissing(sumX :/ sumXhat,0)) ,1)
			offset =  log((YE_Yw) :/ (Pi1[Pi_index1,.] :* P1[P_index1,.]) :* D[X_index,.]) + user_offset[X_index,.]
		}
		if (which == 3 | which == 4){
			D   = D  :*  colshape( J(NN_y,1,1)#(editmissing(sumX :/ sumXhat,0)) ,1) 
			dtt = colshape( J(NN_y,1,1)#(editmissing( (Xtrend-Xhattrend)  :/ Xhattrend2,0)) ,1) :* free_trend   // this comes from 1st-order Taylor Series approx. around dtt = 0
			tt  = tt +   min((iter1/50,.99))*dtt
			offset =  log((YE_Yw) :/ (Pi1[Pi_index1,.] :* P1[P_index1,.]) :* D[X_index,.]) +(timevar[X_index,.]:* tt[X_index,.]) + user_offset[X_index,.]
		}
		if (which == 2) {
			offset =  log((YE_Yw) :/ (Pi1[Pi_index1,.] :* P1[P_index1,.])) + user_offset[X_index,.]
		}
		
		if (max(exp(timevar:*tt)) >= 1000) {
			temp = max(exp(timevar:*tt))  
			temp = (ln(100)-ln(temp)):/max(timevar)
			tt   = (tt :+ temp) //:* free_trend
			P1   = P1  :* sqrt(exp(temp:* (time#J(NN_n*NN_i,1,1)) ))
			Pi1  = Pi1 :* sqrt(exp(temp:* (time#J(NN_n*NN_i,1,1)) )) 
		}
		if (max(D) >= 1000) {
			temp = max(D)
			D   = D  :*  (100 / temp)
			P1  = P1 :*  sqrt(100 / temp)
			Pi1 = Pi1 :* sqrt(100 / temp) 
		}

		// Iteratively re-weighted least squares		
		change2 = 1
		iter2   = 0
		if (which == 3 | which == 4){
			even_iter = (mod(iter1,4)==0)
		}
		beta_old1=beta
		
		notmiss = selectidx(offset :!= .,vers) // ensures loop will handle missing values without blowing up.
		
		//IRLS loop: 
		eta  = pv[notmiss,.]*beta 
		mu   = exp(eta + offset[notmiss,.])
		z    = eta + ((lhs[notmiss,.]-mu) :/ mu) 
		XWX  = cross( pv[notmiss,.], mu, pv[notmiss,.])
		XWz  = cross( pv[notmiss,.], mu, z)
		beta = invsym(XWX)*XWz
		// beta = invsym(pv[notmiss,.]'diag(mu)*pv[notmiss,.])*pv[notmiss,.]'diag(mu)'z
		
		/*  // newton-raphson loop (old); see: http://cameron.econ.ucdavis.edu/stata/cameronwcsug2008.pdf
		do {
			mu        = exp(pv[notmiss,.]*beta + offset[notmiss,.])
			grad      = (pv[notmiss,.])'(lhs[notmiss,.]-mu)                     // k x 1 gradient vector
			hes       = makesymmetric( (pv[notmiss,.] :* mu)' pv[notmiss,.])
			beta_old2 = beta
			beta      = beta_old2 + cholinv(hes)*(grad)                         // for future: add an irls option
			change2   = (beta_old2 - beta)'(beta_old2-beta) / (beta' beta)
			iter2     = iter2+1
		} while (change2 > 1e-16 & iter2 < 25)
		*/
		
		//This uses a Steffenson acceleration technique to accelerate guesses after a certain # of iterations
		//Reference: http://link.springer.com/article/10.1007%2FBF01385782
		accel_iter2 = accel_iter2+1
		if ((accel_iter2 > accel_interval | change1 < tol*5000) & even_iter & accel_ok  ){  
			if (change1 <= last_change) {
				accel_iter1 = accel_iter1 +1
				store_iters[.,accel_iter1] = beta
				if (accel_iter1 == rows(beta)+2) {
					if (verb != 0) {
						printf("acceleration\n")
					}
					step1  = store_iters[|.,2 \.,rows(beta)+1|] - store_iters[|.,1 \.,rows(beta)|]
					step2  = store_iters[|.,3 \.,rows(beta)+2|] - store_iters[|.,2 \.,rows(beta)+1|]	
					Lambda = step2 * luinv(step1)
					beta_old1 = store_iters[.,1]
					beta   = store_iters[.,1] + luinv(I(rows(beta)) - Lambda) * step1[.,1]
					
					// protect against overshooting the solution. 
					if (change1 < tol*5000) {
						if (max(abs(beta - store_iters[.,rows(beta)+2])) > .01) {
								beta = store_iters[.,rows(beta)+2]
						}
						else if (change1 < tol*1000) {
							if (max(abs(beta - store_iters[.,rows(beta)+2])) > .005) {
								beta = store_iters[.,rows(beta)+2]
							}
							else if (change1 < tol*100) { 
								if (max(abs(beta - store_iters[.,rows(beta)+2])) > .0025) {
									beta = store_iters[.,rows(beta)+2]
								}
								else if (change1 < 10*tol) {
									if (max(abs(beta - store_iters[.,rows(beta)+2])) > .001) {
										beta = store_iters[.,rows(beta)+2]
									}
									else if (change1 < 5*tol) {
										if (max(abs(beta - store_iters[.,rows(beta)+2])) > .0005) {
											beta = store_iters[.,rows(beta)+2]
										}
									}
								}	
							}
						}
					}
					
					if (missing(beta) != 0) {
						beta = store_iters[.,accel_iter1]
						if (verb != 0) {
							printf("acceleration failed. switching to more conservative method.\n")
						}
						accel_ok=0
					}
					
					// reset acceleration loop
					store_iters = J(rows(beta), rows(beta)+2,.)
					accel_iter1  = accel_iter2 =  0 
				}
			}
			else {
				store_iters = J(rows(beta), rows(beta)+2,.)
				accel_iter1  = accel_iter2 =  0 
			}
		}
		
		last_change = change1
		
		change1 = editmissing( (beta_old1 - beta)'(beta_old1-beta) / (beta'beta), 0)

		iter1 = iter1 + 1	

		if ((change1 > .5) & (iter1 > accel_interval)) {
			beta = beta_old1
			change1 = last_change
		}
		
		//display results
		if (verb > 0) {
			kk = min((rows(beta),6))
			if ((mod(iter1,verb)==0) | iter1 == 1) {
				printf("iteration %f:	diff = %12.0g	", iter1, change1)
				printf("coeffs =")
				for (k = 1; k<=kk; k++) {
					printf(" %12.0g", beta[k,.])
				}
				printf("\n")
			}
		}
		
		// require 2 consecutive "hits" for convergence
		if (change1 > tol) {
			hits = 0
		}
		else {
			hits = hits + 1
		}
	//(beta', change1, iter1, max(sumX :/ sumXhat), max(Xtrend :/ Xhattrend))
	} while ((hits < 2) & (iter1 < max)) 
	
	st_numscalar(n_iter, iter1)
	st_numscalar(N_obs, rows(lhs[notmiss,.]))
	st_numscalar(N_dropped, rows(lhs) - rows(lhs[notmiss,.]))
	
	// apply normalizations - each country's largest D (lowest trade cost) normalized to 1, for both exports and imports
	if (storefes) {
		if (which != 2) {			
			D      = colshape(D, NN_n)
			D_temp = J(NN_n * NN_i, NN_n, 0)
			for (t=1; t<=NN_y; t++) {
				for (i=1; i<=NN_i; i++) {
					long_index = ((t-1) * NN_i * NN_n + (i-1)*NN_n + 1, 1 \ (t-1) * NN_i* NN_n + (i-1)*NN_n + NN_n, 1)
					wide_index = ((t-1) * NN_i * NN_n + (i-1)*NN_n + 1, 1 \ (t-1) * NN_i* NN_n +(i-1)*NN_n +NN_n,NN_n)
					temp_index = ((i-1)*NN_n + 1, 1 \ (i-1)*NN_n +NN_n,NN_n)
					missing = (D[|wide_index|]:==0)
					D_temp[|temp_index|] = missing:*D_temp[|temp_index|] + !missing:*D[|wide_index|]			
				}
			}
			
			//unbalanced_warning = 0
			//years_affected =.
			for (t=1; t<=NN_y; t++) {
				test = 0
				for (i=1; i<=NN_i; i++) {
					long_index = ((t-1) * NN_i * NN_n + (i-1)*NN_n + 1, 1 \ (t-1) * NN_i* NN_n + (i-1)*NN_n + NN_n, 1)
					wide_index = ((t-1) * NN_i * NN_n + (i-1)*NN_n + 1, 1 \ (t-1) * NN_i * NN_n +(i-1)*NN_n +NN_n,NN_n)
					temp_index = ((i-1)*NN_n + 1, 1 \ (i-1)*NN_n +NN_n,NN_n)
					
					Pi1[|long_index|] = Pi1[|long_index|] :/ rowmax(D_temp[|temp_index|])
					D[|wide_index|]   = D[|wide_index|]   :/ rowmax(D_temp[|temp_index|])
				
					P1[|long_index|] = P1[|long_index|] :/ colmax(D_temp[|temp_index|]:/ rowmax(D_temp[|temp_index|]))'
					D[|wide_index|] = D[|wide_index|]   :/ colmax(D_temp[|temp_index|]:/ rowmax(D_temp[|temp_index|])) 
					
					// Normalize MRs by imposing them to be the same magnitude.
					adj = sqrt(sum(Pi1[|long_index|]) :/ sum(P1[|long_index|]))	 
					Pi1[|long_index|] = Pi1[|long_index|] :/ adj
					P1[|long_index|]  = P1[|long_index|]  :* adj
					//test = test + (rowmax(D[|wide_index|]) != rowmax(D_temp[|temp_index|]))
					//test = test + (colmax(D[|wide_index|]) != colmax(D_temp[|temp_index|]))
				}
				/*
				if (test > 0) {
					unbalanced_warning = 1
					if (cols(years_affected)==1) {
						years_affected = time[t]
					}
					else {
						years_affected = years_affected, time[t]
					}
				}
				*/
			}
			D = colshape(D,1)
		}
	}
	// Future: allow user to specify a numeraire country to normalize P's and Pi's
	
	// post results to Stata
	M[.,6]  = D[X_index,.]
	M[.,7]  = Pi1[Pi_index1,.]
	M[.,8]  = P1[P_index1,.]
	M[.,9]  = tt[X_index,.]
	
	st_store(., Y_w, touse, Yw[Pi_index1,.])
	st_store(., y_i, touse, y[Pi_index1,.])
	st_store(., e_j, touse, e[P_index1,.])	
	st_matrix(b, beta')
}
end


mata:
real vector selectidx(real vector x, real scalar vers)
{
	if (vers >= 13) {
		return(selectidx13(x))
	}
	else {
		return(selectidx11(x))
	}
}
end


mata:
real vector selectidx13(real vector x)
{
    return(selectindex(x))
}
end

// This workaround for selectindex originally created by Hua Peng
// http://www.statalist.org/forums/forum/general-stata-discussion/general/1305770-outreg-error
mata:
real vector selectidx11(real vector x)
{
    real scalar row, cnt, i
    vector res
	
    row = rows(x)
    
    cnt = 1
    res = J(1, row, 0)
    for(i=1; i<=row; i++) {
        if(x[i] != 0) {
            res[cnt] = i ;
            cnt++ ;
        }
    }
    
    if(cnt>1) {
        res = res[1, 1..cnt-1]
    }
    else {
        res = J(1, 0, 0)
    }
    
    if(row>1) {
        res = res'
    }
    
    return(res)
}

end
