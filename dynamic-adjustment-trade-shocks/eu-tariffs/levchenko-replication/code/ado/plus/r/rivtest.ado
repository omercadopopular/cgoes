*! rivtest v1.0.7 15mar2011
*! authors Keith Finlay, Leandro M. Magnusson

* version history
* 1.0.0 - 8aug2008	: first release
* 1.0.1 - 23aug2008 : added support for ivreg2 (except under AC or HAC VCE) and 
*					  added small-sample adjustment option
* 1.0.2 - 28oct2008 : fixed small-sample adjustment constant in computeivtests_iid_robust
*					  rescale F-stat as Wald chi-sq if test.ado reports F-stat
* 1.0.3 - 25jan2009 : fixed exit error if there is more than one endogenous variable
*					  broke up regressor/instrument list parsing according to estimation command used
*					  used _dots to clean up confidence set estimation progress report
*					  simplified grid search (no longer requires matrix to store results)
*					  created retmat option to return confidence set matrix to user (requires memory)
*					  redesigned linear robust/cluster algorithm using suest to save time (4 times faster)
*					  after this robust/cluster change, any type of weights are allowed, so I removed
*					       weight normalization code
*					  put most matrix calculations in mata; use solvers to improve precision when some
*						   matrices are not of full rank/not positive definite
*					  removed redundant regression commands during CI estimation
* 1.0.4 - 5mar2009  : fixed f to chi2 conversion for wald test
* 1.0.5 - 9sep2009  : renamed command: ivtest to rivtest
* 1.0.6 - 10aug2010 : removed use of suest because it was incompatible with pweight
* 1.0.7 - 15mar2011 : for Stata 11, removed omitted vars and base groups for compatability with factor vars

program rivtest, rclass sortpreserve
		if c(stata_version)>=11.1	version 11.1
		else 						version 10.1
		local version 1.0.7
	* syntax
		syntax [ , null(real 0) lmwt(numlist max=1 >0 <1) small ci usegrid grid(numlist ascending) points(integer 100) gridmult(real 2) retmat Level(cilevel) exportmats]
		* null: null hypothesis for the coefficient on the endogenous variable (default is zero)
		* lmwt: weight on LM test in LM-J test (default is 80%)
		* small: use small sample adjustments (default is given by IV command)
		* ci: estimate confidence interals (default is not to estimate them)
			* usegrid: force grid-based estimation even under iid linear model
			* grid: numlist to specify grid
			* points: specify number of points in grid
			* gridmult: specify grid as a multiple of Wald confidence interval
			* (default grid is twice the Wald confidence interval with 100 points)
			* retmat: save confidence set results in matrix (default is not to; requires more memory)
		* level: confidence level, or level of significance for LM-J test
		* exportmats is a programmer option for bootstrapping
	* verify estimation model: test can only run after ivregress, ivtobit, and ivprobit
		if "`e(cmd)'" ~= "ivregress" & "`e(cmd)'" ~= "ivreg2" & "`e(cmd)'" ~= "ivprobit" & "`e(cmd)'" ~= "ivtobit" {
			di in r "rivtest not supported for command `e(cmd)'"
			error 301
		}
		local ivcmd "`e(cmd)'"
		local robust=0
		local cluster=0
		local alpha=1-`level'/100
		tempname notposdef
		scalar `notposdef'=0
		tempvar touse
		qui gen byte `touse'=e(sample)
		local einsts "`e(insts)'"
	* ivtobit parsing block
		if "`e(cmd)'" == "ivtobit" {
			* verify that robust or cluster covariance estimation not used
				if "`e(vce)'" == "robust" | "`e(vce)'" == "cluster" {
					di in red "with ivtobit, rivtest requires an assumption of homoskedasticity (no robust or cluster)"	
					exit 198
				}
			* parse ivtobit options
				if "`e(llopt)'" ~= ""		local llopt "ll(`e(llopt)')"
				if "`e(ulopt)'" ~= ""		local ulopt "ul(`e(ulopt)')"
			local ivtitle "IV Tobit"
			* get instrument lists
				local cmdline "`e(cmdline)'"
				gettoken lhs 0 : cmdline , parse("=")
				gettoken 0 rhs : 0 , parse(")")
				local 0 : subinstr local 0 "=" ""
				unab rawinst : `0'
				local exexog ""
				local insts "`e(insts)'"
				foreach v of local rawinst {
					local insts : subinstr local insts "`v'" "", all word count(local subct)
					if `subct'>0			local exexog "`exexog' `v'"
				}
				local inexog "`insts'"
			}
	* ivprobit parsing block
		if "`e(cmd)'" == "ivprobit" {
			* verify that robust or cluster covariance estimation not used
				if "`e(vce)'" == "robust" | "`e(vce)'" == "cluster" {
					di in red "with ivprobit, rivtest requires an assumption of homoskedasticity (no robust or cluster)"	
					exit 198
				}
			* parse ivprobit options
				local asis "`e(asis)'"
			local ivtitle "IV probit"
			* get instrument lists
				local cmdline "`e(cmdline)'"
				gettoken lhs 0 : cmdline , parse("=")
				gettoken 0 rhs : 0 , parse(")")
				local 0 : subinstr local 0 "=" ""
				unab rawinst : `0'
				local exexog ""
				local insts "`e(insts)'"
				foreach v of local rawinst {
					local insts : subinstr local insts "`v'" "", all word count(local subct)
					if `subct'>0			local exexog "`exexog' `v'"
				}
				local inexog "`insts'"
		}
	* ivregress parsing block
		if "`e(cmd)'" == "ivregress" {
			* verify that hac covariance estimation not used
				if "`e(vce)'" == "hac" {
					di in red "with 2sls, rivtest not yet valid with autocorrelation variance-coveriance estimation"	
					exit 198
				}
				if "`e(vce)'" == "cluster" {
					local cluster=1
					local clustervar "`e(clustvar)'"
					local N_clust=`e(N_clust)'
					local ivtitle "linear IV with cluster VCE"
				}
				else if "`e(vce)'" == "robust" {
					local robust=1
					local ivtitle "linear IV with robust VCE"
				}
				else	local ivtitle "linear IV"
				* other options are unadjusted, the default, etc.
			* parse ivregress options
				local consopt "`e(constant)'"
			* get instrument lists
				local inexog "`e(exogr)'"
				local exexog "`e(insts)'"
		}
	* ivreg2 parsing block
		if "`e(cmd)'" == "ivreg2" {
			* verify that hac covariance estimation not used
				else if "`e(kernel)'" != "" {
					di in red "with 2sls, rivtest not yet valid with autocorrelation variance-coveriance estimation"	
					exit 198
				}
				if "`e(clustvar)'" != "" {
					local cluster=1
					local clustervar "`e(clustvar)'"
					local N_clust=`e(N_clust)'
					local ivtitle "linear IV with cluster VCE"
				}
				else if "`e(vcetype)'" == "Robust" {
					local robust=1
					local ivtitle "linear IV with robust VCE"
				}
				else	local ivtitle "linear IV"
				* other options are unadjusted, the default, etc.
			* parse ivregress options
				local consopt "`e(constant)'"
			* now let rivtest use the same options as if command was ivregress
				local ivcmd "ivregress"
			* get instrument lists
				local inexog "`e(inexog)'"
				local exexog "`e(exexog)'"
		}	
	* common parsing block
		* clean inst lists again
			local exexog : list exexog - inexog
			local notinsts : list exexog - einsts
			local exexog : list exexog - notinsts
			local notinsts : list inexog - einsts
			local inexog : list inexog - notinsts
		* Stata 11: remove omitted variables or base levels of factor variables 
			if `c(stata_version)'>=11 {
				foreach var in `exexog' `inexog' {
					_ms_parse_parts `var'
					if `r(omit)' {
						local remove "`var'"
						local inexog : list inexog - remove
						local exexog : list exexog - remove
					}	
				}
			}
		local endo "`e(instd)'"
		local nendog : word count `endo'
		if `nendog'!=1 {
			di in red "Test can only handle one endogenous variable"
			exit 198
		}
		local depvar=trim(subinword("`e(depvar)'","`endo'","",.))
		local nexexog : word count `exexog'
		* for degree of freedom calculation, the number of RHS variables includes the vector of ones
			local ninexog : word count `inexog'
			if "`consopt'"==""			local ninexog=`ninexog'+1
		* should we make small sample adjustments?
			if "`small'"=="small"										local small=1
			else if "`e(small)'"=="small"								local small=1
			else if "`ivcmd'"=="ivprobit" | "`ivcmd'"=="ivtobit"		local small=1
			else														local small=0
		* weight processing code and number of observations
			local weight "`e(wtype)'"
			local exp=subinstr("`e(wexp)'","=","",1)
			* fweight and aweight accepted as is
			* iweight not allowed with robust or gmm and requires a trap below when used with summarize
			* pweight is equivalent to aweight + robust
				tempvar wvar
				if "`weight'"=="fweight" | "`weight'"=="aweight" | "`weight'" == "iweight" {
					qui gen double `wvar'=`exp'
				}
				if "`weight'" == "pweight" {
					qui gen double `wvar'=`exp'
					local robust=1
				}
				if "`weight'" == "" {
					* If no weights, define neutral weight variable
					qui gen byte `wvar'=1
				}
				if "`weight'"=="fweight" | "`weight'"=="aweight" | "`weight'" == "iweight" {
					local wtexp `"[`weight'=`exp']"'
				}
				else if "`weight'" == "pweight" {
					local wtexp `"[aweight=`exp']"'
				}
				else {
					local wtexp ""
				}
				* Every time a weight is used, must multiply by scalar wf ("weight factor")
				* wf=1 for no weights, fw and iw, wf = scalar that normalizes sum to be N if aw or pw
				sum `wvar' if `touse' `wtexp', meanonly
				if "`weight'"=="" | "`weight'"=="fweight" | "`weight'"=="iweight" {
					* Effective number of observations is sum of weight variable.
					* If weight is "", weight var must be column of ones and N is number of rows
					local wf=1
					local n=r(sum_w)
				}
				else if "`weight'"=="aweight" | "`weight'"=="pweight" {
					local wf=r(N)/r(sum_w)
					local n=r(N)
				}
	* save estimate and se from iv and hold original estimates to restore
		local ivbetahat=_b[`endo']
		local ivbetahatse=_se[`endo']
		tempname estimates
		_estimates hold `estimates', restore
********************************************
*** Run reduced form regressions and get ***
*** matrices to calculate tests.         ***
********************************************
	* run single-equation models for non-robust and robust cases and make matrices for test stats
		if "`ivcmd'" == "ivregress" & (`robust'==1 | `cluster'==1) {
			* define vce
				local vce "vce(robust)"
				if `cluster'==1	{
					local vce "vce(cluster `clustervar')"
					if c(version)<10			local vce "cluster(`clustervar')"
					local survce "cluster(`clustervar')"
				}
			* regs and sur estimation
				tempname depvareqn endoeqn
				qui reg `depvar' `exexog' `inexog' if `touse' `wtexp', `consopt'
				estimates store `depvareqn'
				qui reg `endo' `exexog' `inexog' if `touse' `wtexp', `consopt'
				estimates store `endoeqn'
				* sur estimation stacking the above two models
				local names `depvareqn' `endoeqn'
				tempname hcurrent V Vi b bi
				tempvar esamplei esample
				local i 0
				foreach name of local names {
					local ++i
					nobreak {
						if "`name'" != "."		est_unhold `name' `esample'
						else					_est unhold `hcurrent'
						capture noisily break {
							GetMat `name' `bi' `Vi'
							capture drop `esamplei'
							gen byte `esamplei' = e(sample)
							// fix some irregularities in -regress-
							tempvar sc`i'_1 sc`i'_2
							quietly Fix_regress `bi' `Vi' `sc`i'_1' `sc`i'_2'
							local scoresi `sc`i'_1' `sc`i'_2'
						} // capture noisily break
						local rc = _rc
						if "`name'" != "." 		est_hold `name' `esample'
						else					_est hold `hcurrent' , restore nullok estsystem
					} // nobreak
					if (`rc') exit `rc'
					// modifies equation names into name_eq or name#
					FixEquationNames `name' `bi' `Vi'
					local neq`i' `r(neq)'
					local eqnames`i' `"`r(eqnames)'"'
					local newfullnames `"`newfullnames' `:colfullnames `bi''"'
					if `i' == 1 {
						matrix `b' = `bi'
						matrix `V' = `Vi'
					}
					else {
						// append the bi and Vi
						matrix `b' = `b' , `bi'
						local nv  = colsof(`V')
						local nvi = colsof(`Vi')
						matrix `V' = (`V', J(`nv',`nvi',0) \ J(`nvi',`nv',0), `Vi')
					}
					// score vars all models
					local scores `scores' `scoresi'
				} // loop over models
				local Stata11 = cond(c(stata_version)>=11, "version 11:", "")
				`Stata11' matrix colnames `b' = `newfullnames'
				`Stata11' matrix colnames `V' = `newfullnames'
				`Stata11' matrix rownames `V' = `newfullnames'
				qui _robust `scores' if `touse' `wtexp', var(`V') `survce' minus(0)
			* calculate small sample adjustments (note that local ninexog accounts for the constant vector)
				if `small'==1&`cluster'==1		local ssa=(`N_clust')/(`N_clust'-1) * (`n'-1)/(`n'-(`nexexog'+`ninexog'))
				else if `small'==1&`robust'==1	local ssa=(`n')/(`n'-(`nexexog'+`ninexog'))
				else 							local ssa=1
			* break up vecs and mats for test components (and make small sample adjustments
				tempname btemp vtemp del_z vardel pi_z var_pi_z var_pidel_z
				mata `btemp' = st_matrix("`b'")
				mata `vtemp' = st_matrix("`V'")
				mata `del_z' = `btemp'[| 1,1 \ .,`nexexog' |]
				mata `vardel' = `ssa' * `vtemp'[| 1,1 \ `nexexog',`nexexog' |]
				mata `pi_z' = `btemp'[| 1,`nexexog'+`ninexog'+2 \ .,`nexexog'+`ninexog'+`nexexog'+1 |]
				mata `var_pi_z' = `ssa' * `vtemp'[| `nexexog'+`ninexog'+2,`nexexog'+`ninexog'+2 \ `nexexog'+`ninexog'+`nexexog'+1,`nexexog'+`ninexog'+`nexexog'+1 |]
				mata `var_pidel_z' = `ssa' * `vtemp'[| `nexexog'+`ninexog'+2,1 \ `nexexog'+`ninexog'+`nexexog'+1,`nexexog' |]
		}
		else if `robust'==0 & `cluster'==0 {
			tempvar vhat
			tempname var_pi_z bhat pi_z vardel del_z del_v
			* run single-equation models - model-specific
				if "`ivcmd'" == "ivtobit"		qui reg `endo' `exexog' `inexog' if `touse' `wtexp'
				if "`ivcmd'" == "ivprobit"		qui reg `endo' `exexog' `inexog' if `touse' `wtexp'
				if "`ivcmd'" == "ivregress"		qui reg `endo' `exexog' `inexog' if `touse' `wtexp', `consopt'
				qui predict double `vhat' if `touse', residuals
				mat `var_pi_z'=e(V)
				mat `var_pi_z' = `var_pi_z'[1..`nexexog',1..`nexexog']
				mat `var_pi_z' = [`e(df_r)'/`n']*`var_pi_z'
				local dfr=`e(df_r)'
				* pi_z is big pi_z in paper
				mat `pi_z'=e(b)
				mat `pi_z'=`pi_z'[1...,1..`nexexog']
				if "`ivcmd'" == "ivtobit"		qui tobit `depvar' `exexog' `vhat' `inexog' if `touse' `wtexp', `llopt' `ulopt'
				if "`ivcmd'" == "ivprobit"		qui probit `depvar' `exexog' `vhat' `inexog' if `touse' `wtexp', `asis'
				if "`ivcmd'" == "ivregress"		qui reg `depvar' `exexog' `vhat' `inexog' if `touse' `wtexp', `consopt'
				mat `vardel'=e(V)
				mat `vardel'= `vardel'[1..`nexexog',1..`nexexog']
				mat `vardel' = [(`dfr'-1)/`n']*`vardel'
				mat `bhat'=e(b)
				* del_z is little pi_z in paper
				mat `del_z'=`bhat'[1...,1..`nexexog']
				mat `del_v'=`bhat'[1...,`nexexog'+1..`nexexog'+1]
			* small sample adjustment
				if `small'==1 {
					mat `var_pi_z' = `n'/`dfr'*`var_pi_z'
					mat `vardel' = `n'/`dfr'*`vardel'
				}
		}
********************************************
*** This confidence interval code must   ***
*** run before the main test code, since ***
*** it would overwrite test results.	 ***
********************************************
	* construct confidence intervals if requested
		if "`ci'"=="ci" {
			* has user specified grid or numerical estimation of confidence sets? (numerical estimation only for homoskedastic 2sls)
				local gridin1 : length local usegrid
				if `gridin1'==0 & "`ivcmd'"=="ivregress" & `robust'==0 & `cluster'==0	local usegrid=0
				else																	local usegrid=1
			if `usegrid'==1 {
				* figure out grid for grid-based test inversion if user has requested it
					if `usegrid'==1 {
						* has user supplied numlist for grid?
						* otherwise create grid based on 2 * wald confidence interval and user-entered or default grid points
						local gridinput : length local grid
						if `gridinput'==0 {
							* default grid radius is twice that of the confidence interval from the original estimation
								local gridradius = abs(`gridmult') * `ivbetahatse' * invnormal(1-`alpha'/2)
							* create grid for confidence sets
								local gridmin = `ivbetahat' - `gridradius'
								local gridmax = `ivbetahat' + `gridradius'
								local gridinterval = .999999999*(`gridmax'-`gridmin')/(`points'-1)
								local grid "`gridmin'(`gridinterval')`gridmax'"
								local gridbegin : di %8.0g `gridmin'
								local gridend : di %8.0g `gridmax'
						}
						numlist "`grid'"
						local gridlist "`r(numlist)'"
						local points : word count `gridlist'
						if `gridinput'>0 {
							local gridbegin : word 1 of `gridlist'
							local gridend : word `points' of `gridlist'
						}
						local grid_description "[`gridbegin',`gridend']"
						return scalar points=`points'
						return local grid `grid_description'
					}
				* create a matrix to store test results for confidence interval on user request
					if "`retmat'"=="retmat" {
						tempname citable
						if `nexexog'>`nendog' {
							mat `citable' = J(`points',12,0)
							mat colnames `citable' = null ar_chi2 lm_chi2 clr_stat ar_p lm_p clr_p ar_r lm_r lmj_r clr_r rk
						}
						else {
							mat `citable' = J(`points',5,0)
							mat colnames `citable' = null ar_chi2 ar_p ar_r rk
						}
					}
				* create macros for storing confidence sets
					if `nexexog'>`nendog' 	local testlist "ar lm lmj clr"
					else 					local testlist "ar"
					foreach testname in `testlist' {
						local `testname'_cset ""
						local `testname'_rbegin=0
						local `testname'_rend=0
						local `testname'_rbegin_null=0
						local `testname'_rend_null=0
					}
				local counter = 0
				_dots `counter' 0, title(Estimating confidence sets over grid points)
				foreach gridnull in `gridlist' {
					local ++counter
					_dots `counter' 0
					tempname rk ar_p ar_chi2 ar_df lm_p lm_chi2 lm_df j_p j_chi2 j_df lmj_p lmj_chi2 ///
						clr_p clr_stat clr_df ar_r lm_r j_r lmj_dnr lmj_r clr_r
					* calculate test stats
						if "`ivcmd'" == "ivregress" & (`robust'==1 | `cluster'==1) {
							mata computeivtests_robust(`del_z', `vardel', `pi_z', `var_pi_z', `var_pidel_z', `gridnull')
							scalar `notposdef'=max(`notposdef',r(notposdef))
						}
						else if `robust'==0 & `cluster'==0 {
							computeivtests_iid, var_pi_z(`var_pi_z') pi_z(`pi_z') vardel(`vardel') del_z(`del_z') del_v(`del_v') null(`gridnull')
						}
						scalar `ar_chi2'=r(ar_chi2)
						scalar `lm_chi2'=r(lm_chi2)
						scalar `j_chi2'=r(j_chi2)
						scalar `clr_stat'=r(clr_stat)
						scalar `rk'=r(rk)
					* calculate test statistics, p-values, and rejection indicators from above matrices
						compute_pvals, null(`gridnull') rk(`rk') nexexog(`nexexog') nendog(`nendog') ///
							level(`level') ar_p(`ar_p') ar_chi2(`ar_chi2') lm_p(`lm_p') lm_chi2( `lm_chi2' ) ///
							j_p(`j_p') j_chi2(`j_chi2') lmj_p(`lmj_p') lmj_chi2(`lmj_chi2') clr_p(`clr_p') ///
							clr_stat(`clr_stat') ar_df(`ar_df') lm_df(`lm_df') j_df(`j_df') clr_df(`clr_df') ///
							ar_r(`ar_r') lm_r(`lm_r') j_r(`j_r') lmj_dnr(`lmj_dnr') lmj_r(`lmj_r') clr_r(`clr_r') ///
							lmwt(`lmwt')
					* store results in matrix on user request
						if "`retmat'"=="retmat" {
							tempname civec
							if `nexexog'>`nendog' {
								mat `civec' = (`gridnull',`ar_chi2',`lm_chi2',`clr_stat',`ar_p',`lm_p',`clr_p',`ar_r',`lm_r',`lmj_r',`clr_r',`rk')
								mat `citable'[`counter',1] = `civec'
							}
							else {
								mat `civec' = (`gridnull',`ar_chi2',`ar_p',`ar_r',`rk')
								mat `citable'[`counter',1] = `civec'
							}
						}
					* write out confidence sets from rejection indicators
						if `clr_stat'==.								local clr_cset "."
						foreach testname in `testlist' {
							if "``testname'_cset'"!="." { 
								if ``testname'_r'==0 {
									if ``testname'_rbegin'==0 {
										local `testname'_rbegin=`counter'
										local `testname'_rbegin_null=`gridnull'
									}
									local `testname'_rend=`counter'
									local `testname'_rend_null=`gridnull'
								}
								if ``testname'_r'==1 | (``testname'_r'==0 & `counter'==`points') {
									if ``testname'_rbegin'>0 & ``testname'_rend'>0 & ``testname'_rbegin'==``testname'_rend' {
										local rnull : di %8.0g ``testname'_rbegin_null'
										if length("``testname'_cset'")==0	local `testname'_cset "`rnull'"
										else								local `testname'_cset "``testname'_cset' U `rnull'"
										local `testname'_rbegin=0
										local `testname'_rend=0
									}
									else if ``testname'_rbegin'>0 & ``testname'_rend'>0 & ``testname'_rbegin'<``testname'_rend' {
										local rnull1 : di %8.0g ``testname'_rbegin_null'
										local rnull2 : di %8.0g ``testname'_rend_null'
										if length("``testname'_cset'")==0	local `testname'_cset "[`rnull1',`rnull2']"
										else								local `testname'_cset "``testname'_cset' U [`rnull1',`rnull2']"
										local `testname'_rbegin=0
										local `testname'_rend=0
									}
								}
							}
						}
				}
				foreach testname in `testlist' {
					if length("``testname'_cset'")==0 		local `testname'_cset "null set"
				}
				* only return matrix on user request
					if "`retmat'"=="retmat"					return matrix citable=`citable'
			}
			else if `usegrid'==0 {
				invertivtests_closedform , ry1(`depvar') ry2(`endo') rinst(`exexog') exog(`inexog') touse(`touse') ///
					wtexp(`wtexp') consopt(`consopt') df(`nexexog') level(`level') n(`n')
				local clr_cset "`r(clr_cset)'"
				local lm_cset "`r(lm_cset)'"
				local ar_cset "`r(ar_cset)'"
			}
		}
********************************************
*** Test code must run after confidence  ***
*** interval code, since CI results will ***
*** overwrite test results.				 ***
********************************************
	tempname rk ar_p ar_chi2 ar_df lm_p lm_chi2 lm_df j_p j_chi2 j_df lmj_p lmj_chi2 ///
		clr_p clr_stat clr_df ar_r lm_r j_r lmj_dnr lmj_r clr_r
	* calculate test stats
		if "`ivcmd'" == "ivregress" & (`robust'==1 | `cluster'==1) {
			mata computeivtests_robust(`del_z', `vardel', `pi_z', `var_pi_z', `var_pidel_z', `null')
			scalar `notposdef'=max(`notposdef',r(notposdef))
		}
		else if `robust'==0 & `cluster'==0 {
			computeivtests_iid, var_pi_z(`var_pi_z') pi_z(`pi_z') vardel(`vardel') del_z(`del_z') del_v(`del_v') null(`null')
		}
		scalar `ar_chi2'=r(ar_chi2)
		scalar `lm_chi2'=r(lm_chi2)
		scalar `j_chi2'=r(j_chi2)
		scalar `clr_stat'=r(clr_stat)
		scalar `rk'=r(rk)
	* calculate test statistics, p-values, and rejection indicators from above matrices
		compute_pvals, null(`null') rk(`rk') nexexog(`nexexog') nendog(`nendog') ///
			level(`level') ar_p(`ar_p') ar_chi2(`ar_chi2') lm_p(`lm_p') lm_chi2( `lm_chi2' ) ///
			j_p(`j_p') j_chi2(`j_chi2') lmj_p(`lmj_p') lmj_chi2(`lmj_chi2') clr_p(`clr_p') ///
			clr_stat(`clr_stat') ar_df(`ar_df') lm_df(`lm_df') j_df(`j_df') clr_df(`clr_df') ///
			ar_r(`ar_r') lm_r(`lm_r') j_r(`j_r') lmj_dnr(`lmj_dnr') lmj_r(`lmj_r') clr_r(`clr_r') ///
			lmwt(`lmwt')
	* restore original iv estimation results
		_estimates unhold `estimates'
	* calculate wald test and confidence interval from original iv estimates
		tempname wald_p wald_chi2 wald_df wald_r
		qui test `endo'=`null'
		scalar `wald_p'=r(p)
		if "`r(chi2)'"==""			scalar `wald_chi2'=r(F)*r(df)
		else						scalar `wald_chi2'=r(chi2)
		scalar `wald_df'=r(df)
		scalar `wald_r' = cond(`wald_p'<=1-`level'/100,1,0)
		if "`ci'"=="ci"{
			local wald_x1=_b[`endo']-_se[`endo']*invnormal((100+`level')/200)
			local wald_x2=_b[`endo']+_se[`endo']*invnormal((100+`level')/200)
			local wald_cset : di "["  %8.0g `wald_x1' "," %8.0g `wald_x2' "]"
		}
	* return results from five tests: wald, s, k, j, kj tests
		return local endo="`endo'"
		return local exexog="`exexog'"
		return local inexog="`inexog'"
		return scalar wald_chi2=`wald_chi2'
		return scalar wald_p=`wald_p'
		return scalar rk=`rk'
		if `nexexog'>`nendog' {
			return scalar lmj_r=`lmj_r'
			return scalar j_chi2=`j_chi2'
			return scalar j_p=`j_p'
			return scalar lm_chi2=`lm_chi2'
			return scalar lm_p=`lm_p'
		}
		return scalar ar_chi2=`ar_chi2'
		return scalar ar_p=`ar_p'
		if `nexexog'>`nendog' {
			return scalar clr_stat=`clr_stat'
			return scalar clr_p=`clr_p'
		}
		return scalar N=`n'
		return scalar null=`null'
	* return confidence sets from five tests: wald, ar, lm, lmj, and clr
		if "`ci'"=="ci" {
			return local wald_cset="`wald_cset'"
			return local lmj_cset="`lmj_cset'"
			return local lm_cset="`lm_cset'"
			return local ar_cset="`ar_cset'"
			return local clr_cset="`clr_cset'"
		}
	* print combined test and confidence set results
		* column specs
			local testnamelen = 5
			local testcollen = 1 + `testnamelen' + 1
			local pvalcol = 38
			local csetcol = 58
			local nociline = 45
		* testnames
			local name_clr : di "{txt}{ralign `testnamelen':CLR}"
			local name_ar : di "{txt}{ralign `testnamelen':AR}"
			local name_lm : di "{txt}{ralign `testnamelen':LM}"
			local name_j : di "{txt}{ralign `testnamelen':J}"
			local name_lmj : di "{txt}{ralign `testnamelen':LM-J}"
			local name_wald : di "{txt}{ralign `testnamelen':Wald}"
		* calculate length of result parts
			if `nexexog'>`nendog'		local testlist "ar lm j clr wald"
			else						local testlist "ar wald"
			foreach testname in `testlist' {
				if "`testname'"=="clr" {
					local dist_`testname' "stat"
					local stattxt_`testname' : di "{txt}{lalign 8:`dist_`testname''({res:`=``testname'_df''})} = {res}" ///
			   			%8.2f ``testname'_stat'
				}
				else {
					local dist_`testname' "chi2"
					local stattxt_`testname' : di "{txt}{lalign 8:`dist_`testname''({res:`=``testname'_df''})} = {res}" ///
			   			%8.2f ``testname'_chi2'
				}
			   	local pvaltxt_`testname' : di "{txt}{ralign 14:Prob > `dist_`testname''} = {res}" %8.4f ``testname'_p'
			   	local testtxt_`testname' "`stattxt_`testname''`pvaltxt_`testname''"
			}
			if `nexexog'>`nendog' {
				local testtxtlen : length local testtxt_ar
				local lmjsigtxt=100-`level'
				if `lmj_r'==1			local testtxt_lmj : di "{res}{center 44:H0 rejected at `lmjsigtxt'% level}"
				else if `lmj_r'==0		local testtxt_lmj : di "{res}{center 44:H0 not rejected at `lmjsigtxt'% level}"
			}
		* print
			* title of output
				di
				if "`ci'"=="ci"		di as txt "{p}Weak instrument robust tests and confidence sets for `ivtitle'{p_end}"
				else				di as txt "{p}Weak instrument robust tests for `ivtitle'{p_end}"
				di in yellow "H0: beta[`depvar':`endo'] = `null'"
				di
			if "`ci'"=="ci" {
				di as txt "{hline `testnamelen'}{hline 1}{c TT}{hline}"
				di as txt "{ralign `testnamelen':Test} {c |} {center 20:Statistic}{center 25:p-value}{center :`level'% Confidence Set}"
				di as txt "{hline `testnamelen'}{hline 1}{c +}{hline}"
				if `nexexog'>`nendog'		di "`name_clr' {c |} `testtxt_clr'{res}{center :`clr_cset'}"
				di "`name_ar' {c |} `testtxt_ar'{res}{center :`ar_cset'}"
				if `nexexog'>`nendog' {
					di "`name_lm' {c |} `testtxt_lm'{res}{center :`lm_cset'}"
					di "`name_j' {c |} `testtxt_j'"
					di "`name_lmj' {c |} `testtxt_lmj'{res}{center :`lmj_cset'}"
				}
				di as txt "{hline `testnamelen'}{hline 1}{c +}{hline}"
				di "`name_wald' {c |} `testtxt_wald'{res}{center :`wald_cset'}"
				di as txt "{hline `testnamelen'}{hline 1}{c BT}{hline}"
				di as txt "{p}Note: Wald test not robust to weak instruments. " _continue
				if "`ivcmd'"=="ivprobit" & "`e(vce)'" ~= "twostep" {
					di as txt "For endogenous probit, Wald statistics are only comparable with weak instrument robust statistics when the Newey two-step estimator is used. " _continue
				}
				if `usegrid'==1 {
					di as txt "Confidence sets estimated for `points' points in `grid_description'. " _continue
				}
				else if `nexexog'>`nendog' {
					di as txt "LM-J confidence set not available with closed-form estimation (use usegrid option). " _continue				
				}
			}
			else {
				di as txt "{hline `testnamelen'}{hline 1}{c TT}{hline `nociline'}"
				di as txt "{ralign `testnamelen':Test} {c |} {center 20:Statistic}{center 25:p-value}"
				di as txt "{hline `testnamelen'}{hline 1}{c +}{hline `nociline'}"
				if `nexexog'>`nendog' & `clr_stat'!=. {
					di "`name_clr' {c |} `testtxt_clr'"
				}
				di "`name_ar' {c |} `testtxt_ar'"
				if `nexexog'>`nendog' {
					di "`name_lm' {c |} `testtxt_lm'"
					di "`name_j' {c |} `testtxt_j'"
					di "`name_lmj' {c |} `testtxt_lmj'"
				}
				di as txt "{hline `testnamelen'}{hline 1}{c +}{hline `nociline'}"
				di "`name_wald' {c |} `testtxt_wald'"
				di as txt "{hline `testnamelen'}{hline 1}{c BT}{hline `nociline'}"
				di "{p}Note: Wald test not robust to weak instruments. " _continue
				if "`ivcmd'"=="ivprobit" & "`e(vce)'" ~= "twostep" {
					di as txt "For endogenous probit, Wald statistics are only comparable with weak instrument robust statistics when the Newey two-step estimator is used. " _continue
				}
			}
			if `small'==1 & "`ivcmd'"!="ivtobit" & "`ivcmd'"!="ivprobit" {
				di as txt "Small-sample adjustments were used. " _continue
			}
			if (`clr_stat'==.)+(`notposdef')+("`clr_cset'"==".") {
				di in red "Some matrices are not positive definite, so reported tests should be treated with caution. " _continue
				if cluster==1		di in red "(There may not be enough clusters.)" _continue
			}
			di as txt "{p_end}"
	* export matrices if requested for bootstrapping
		if "`exportmats'"=="exportmats" {
			if "`ivcmd'" == "ivregress" & (`robust'==1 | `cluster'==1) {
				* note: these matrices are in mata format
			 	return matrix bhat=`btemp'
				return matrix vhat=`vtemp'
				return matrix del_z=`del_z'
				return matrix vardel=`vardel'
				return matrix pi_z=`pi_z'
				return matrix var_pi_z=`var_pi_z'
				return matrix var_pidel_z=`var_pidel_z'
			}
			else if `robust'==0 & `cluster'==0 {
				* note: these matrices are in Stata matrix format
				return matrix var_pi_z=`var_pi_z'
				return matrix pi_z=`pi_z'
				return matrix vardel=`vardel'
			 	return matrix bhat=`bhat'
				return matrix del_z=`del_z'
			}
		}
end

************************************************************************************
*** Subroutines by Finlay and Magnusson:										 ***
*** 	computeivtests_iid, computeivtests_robust (mata), compute_pvals,		 ***
*** Subroutines from Mikusheva and Poi's condivreg:								 ***
*** 	invertivtests_closedform (adaptation), new_try, mat_inv_sqrt, inversefun ***
*** Subroutines from Stata's suest command:										 ***
***		Fix_regress, GetMat, FixEquationNames									 ***
************************************************************************************

program computeivtests_iid, rclass
	syntax [, var_pi_z(name) pi_z(name) vardel(name) del_z(name) del_v(name) null(string) *]
	tempname r invpsi pi_beta rk ar_chi2 lm_chi2 j_chi2 clr_stat
	* matrices for test stats
		mat `r' = `del_z' - `pi_z' * (`null')
		mat `invpsi' = invsym(`vardel' + (`del_v'[1,1] - (`null'))^2 * `var_pi_z')
		mat `pi_beta' = `pi_z'' - `var_pi_z'*`invpsi'*`r''*(`del_v'[1,1] - (`null'))
		mat `rk' = `pi_beta''*inv(`var_pi_z'-(`del_v'[1,1]-(`null'))^2 * `var_pi_z'*`invpsi'*`var_pi_z')*`pi_beta'
		scalar `rk' = `rk'[1,1]
		mat `ar_chi2' = `r'*`invpsi'*`r''
		scalar `ar_chi2' = `ar_chi2'[1,1]
		mat `lm_chi2' = `r'*`invpsi'*`pi_beta'*inv(`pi_beta''*`invpsi'*`pi_beta')*`pi_beta''*`invpsi'*`r''
		scalar `lm_chi2' = `lm_chi2'[1,1]
		mat `j_chi2' = `ar_chi2' - `lm_chi2'
		scalar `j_chi2' = `j_chi2'[1,1]
		mat `clr_stat' = .5*(`ar_chi2'-`rk'+sqrt((`ar_chi2'+`rk')^2 - 4*`j_chi2'*`rk'))
		scalar `clr_stat' = `clr_stat'[1,1]
	* return tests in r()
		return scalar rk=`rk'
		return scalar ar_chi2=`ar_chi2'
		return scalar lm_chi2=`lm_chi2'
		return scalar j_chi2=`j_chi2'
		return scalar clr_stat=`clr_stat'
end

mata:
void computeivtests_robust(real matrix del_z, real matrix vardel, real matrix pi_z, real matrix var_pi_z, real matrix var_pidel_z, real scalar null)
{
	// calculate matrices for test stats
		notposdef=0
		r=del_z - pi_z * (null)
		psi=vardel-(null)*var_pidel_z-(null)*var_pidel_z'+((null)^2)*var_pi_z
		aux1 = cholsolve(psi,r')
		if (aux1[1,1]==.) {
			notposdef = 1
			aux1 = qrsolve(psi,r')
		}
		pi_beta = pi_z' - (var_pidel_z-(null)*var_pi_z)*aux1
		aux2 = var_pidel_z - (null)*var_pi_z
		aux3 = cholsolve(psi,aux2')
		if (aux3[1,1]==.) {
			notposdef = 1
			aux3 = qrsolve(psi,aux2')
		}
		aux4 = var_pi_z - aux2 * aux3
		rk = cholsolve(aux4, pi_beta)
		if (rk[1,1]==.) {
			notposdef = 1
			rk = qrsolve(aux3,pi_beta)
		}
		rk = pi_beta' * rk
		aux5 = cholsolve(psi,pi_beta)
		if (aux5[1,1]==.) {
			notposdef = 1
			aux5 = qrsolve(psi,pi_beta)
		}
		aux6 = cholsolve(pi_beta'*aux5,pi_beta')
		if (aux6[1,1]==.) {
			notposdef = 1
			aux6 = qrsolve(pi_beta'*aux5,pi_beta')
		}
	// calculate test stats
		ar_chi2 = r * aux1
		lm_chi2 = r * aux5 * aux6 * aux1
		j_chi2 = ar_chi2 - lm_chi2
		clr_stat = .5*(ar_chi2-rk+sqrt((ar_chi2+rk)^2 - 4*j_chi2*rk))
		if (rk[1,1]<=0)			clr_stat=.		
	// return test stats in r()
		st_numscalar("r(ar_chi2)", ar_chi2[1,1])
		st_numscalar("r(lm_chi2)", lm_chi2[1,1])
		st_numscalar("r(j_chi2)", j_chi2[1,1])
		st_numscalar("r(clr_stat)", clr_stat[1,1])
		st_numscalar("r(rk)", rk[1,1])
		st_numscalar("r(notposdef)", notposdef)
}
end

program compute_pvals
	syntax [, null(string) rk(name) nexexog(string) nendog(string) level(string) ///
		ar_p(name) ar_chi2(name) lm_p(name) lm_chi2(name) j_p(name) j_chi2(name) lmj_p(name) lmj_chi2(name) ///
		clr_p(name) clr_stat(name) ar_df(name) lm_df(name) j_df(name) clr_df(name) ar_r(name) lm_r(name) ///
		j_r(name) lmj_dnr(name) lmj_r(name) clr_r(name) lmwt(string) *]
	scalar `ar_df' = `nexexog'
	scalar `ar_p'= chi2tail(`ar_df',`ar_chi2')
	if `nexexog'>`nendog' {
		scalar `lm_df' = `nendog'
		scalar `lm_p'= chi2tail(`lm_df',`lm_chi2')
		scalar `j_df' = `nexexog'-`nendog'
		scalar `j_p'= chi2tail(`j_df',`j_chi2')
		scalar `clr_df' = .
	}
	* Poi and Mikusheva's method of estimating CLR p-value (subprogram below-taken directly from Mikusheva and Poi's code)
		if `nexexog'>`nendog' {
			if `clr_stat'==.		scalar `clr_p'=.
			else {
				new_try `nexexog' `rk' `clr_stat' `clr_p'
				* fix negative p-value approximations that occur because of rounding near zero 
					if `clr_p'<=-0.00001 & `clr_p'>-9999999		n di in red "error when approximating CLR p-value for null = `null'"	
					if `clr_p'<0								scalar `clr_p'=0.000000
			}
		}
	* compute reject/dn reject binary
		scalar `ar_r' = cond(`ar_p'<=1-`level'/100,1,0)
		if `nexexog'>`nendog' {
			scalar `lm_r' = cond(`lm_p'<=1-`level'/100,1,0)
			scalar `j_r' = cond(`j_p'<=1-`level'/100,1,0)
			if "`lmwt'"==""		local lmwt=0.8
			scalar `lmj_dnr' = cond((`lm_p'>=(1-`level'/100)*`lmwt')&(`j_p'>=(1-`level'/100)*(1-`lmwt')),1,0)			
			scalar `lmj_r' = cond(`lmj_dnr'==0,1,0)
			if `clr_stat'==.		scalar `clr_r' = .
			else					scalar `clr_r' = cond(`clr_p'<=1-`level'/100,1,0)
		}
end

/* The following is an adaptation of the inversion code in Mikusheva and Poi's condivreg program */
program invertivtests_closedform, rclass
	syntax [, ry1(varname) ry2(varname) rinst(varlist) exog(varlist) touse(varname) wtexp(string) ///
		consopt(string) df(string) level(string) n(string) *]
	tempvar y1 y2
	* generate projections
		if ("`exog'" != "") {
				foreach v in y1 y2 {
					qui reg `r`v'' `exog' if `touse' `wtexp', `consopt'
					qui predict double ``v'' if `touse', residuals
				}
			}
			else {
				qui gen double `y1' = `ry1' if `touse'
				qui gen double `y2' = `ry2' if `touse'
			}
	* regress instruments on exogenous 
		tempname ehold
		local inst = ""
		local j = 1
		foreach v in `rinst' {
			tempvar inst`j'
			if ("`exog'" != "") {
				qui reg `v' `exog' if `touse' `wtexp', `consopt'
				qui predict double `inst`j'' if `touse', residuals
			}
			else {
				qui gen double `inst`j'' = `v' if `touse'
			}
			local inst "`inst' `inst`j''"
		}
	* compute omega
		tempname mzy1 mzy2 n omega
		qui reg `y1' `inst' if `touse' `wtexp', `consopt'
		qui predict `mzy1' if `touse', residuals
		qui reg `y2' `inst' if `touse' `wtexp', `consopt'
		qui predict `mzy2' if `touse', residuals
		qui mat accum `omega' = `mzy1' `mzy2' if `touse' `wtexp', noconstant
		local k : word count `inst'
		local p : word count `exog'
		if "`consopt'"==""		mat `omega' = `omega' / (`n'-`k'-`p'-1)
		else					mat `omega' = `omega' / (`n'-`k'-`p')
	*make stuff
		tempname cross zpz sqrtzpzi zpy MM ypz sqrtomegai v d M N alpha C A D aa x1 x2 g type
		local k=`df'
		qui mat accum `cross' = `inst' `y1' `y2' if `touse' `wtexp'
		mat `zpz' = `cross'[1..`k', 1..`k']
		mat `zpy' = `cross'[1..`k', (`k'+1)..(`k'+2)]
		mat_inv_sqrt `zpz' `sqrtzpzi'
		mat_inv_sqrt `omega' `sqrtomegai'
		mat `ypz'=`zpy''
		mat `MM' = `sqrtomegai'*`ypz'*inv(`zpz')*`zpy'*`sqrtomegai'
		mat symeigen `v' `d' = `MM'
		sca `M' = `d'[1,1]
		sca `N' =`d'[1,2]
		sca `alpha' = 1-`level'/100
	* inversion of CLR
		inversefun `M' `df' `alpha' `C'
		mat `A' =inv(`omega')*`ypz'*inv(`zpz')*`zpy'*inv(`omega')- `C'*inv(`omega')
		sca `D' = -det(`A')
		sca `aa' = `A'[1,1]
		if (`aa'<0) {
	 		if (`D' <0) {
				sca `type'=1
				local clr_cset "null set"
			}
	 		else{
				sca `type'=2
				sca `x1'= (-`A'[1,2] + sqrt(`D'))/`aa'
				sca `x2' = (-`A'[1,2] - sqrt(`D'))/`aa'
				mat `g'=(`x1'\ `x2')
				local clr_cset : di "[" %8.0g `x1' "," %8.0g `x2' "]"
 			}
 		}
		else{
			if (`D'<0) {
		  		sca `type'=3
				local clr_cset : di "(    -inf,     inf)"
			}
	 		else {
		  		sca `type'=4
		  		sca `x1'= (-`A'[1,2]-sqrt(`D'))/`aa'
		  		sca `x2'= (-`A'[1,2]+sqrt(`D'))/`aa'
		  		mat `g'=(`x1' \ `x2')
				local clr_cset : di "(    -inf," %8.0g `x1' "] U [" %8.0g `x2' ",     inf)"
 			}
	 	}
	 	*ereturn local LR_type `"`=`type''"'
	 	if `type' == 2 | `type' == 4 {
	 		*eret scalar LR_x1 = `x1'
	 		*eret scalar LR_x2 = `x2'
	 	}
	* inversion of LM
		tempname lmcv q1 q2 A1 A2 D1 D2 y1 y2 y3 y4 type1
		sca `lmcv' = invchi2tail(1, (1-`level'/100))
		if (`df'==1) {
			sca `q1' = `M'-`lmcv'
			mat `A1' =inv(`omega')*`ypz'*inv(`zpz')*`zpy'*inv(`omega')-`q1'*inv(`omega')
			sca `D1' = -4*det(`A1')
			sca `y1'= (-2*`A1'[1,2]+sqrt(`D1'))/2/`A1'[1,1]
			sca `y2'= (-2*`A1'[1,2]-sqrt(`D1'))/2/`A1'[1,1]
			if (`A1'[1,1]>0) { 
				if (`D1'>0) {
					sca `type1'=4 
						/* two infinite intervals*/
					*eret scalar LM_x1 = `y2'
					*eret scalar LM_x2 = `y1'
					local lm_cset : di "(    -inf," %8.0g `y2' "] U [" %8.0g `y1' ",     inf)"
				}
				else {
					sca `type1'=3
					local lm_cset : di "(    -inf,     inf)"
				}
			}
			else{
				if (`D1'>0) {
					sca `type1'=2 /*one interval */
					*eret scalar LM_x1 = `y1'
					*eret scalar LM_x2 = `y2'
					local lm_cset : di "[" %8.0g `y1' "," %8.0g `y2' "]"
				}
				else {
					sca `type1'=3
					local lm_cset : di "(    -inf,     inf)"
				}
			}
		}
		else {
			if ((`M' +`N' - `lmcv')^2-4*`M'*`N'<0) { 
		 		sca `type1' = 3
				local lm_cset : di "(    -inf,     inf)"
		 	}
			else {
			    sca `q1' = (`M'+ `N' - `lmcv' - sqrt((`M'+`N' - `lmcv')^2 -	4*`M'*`N'))/2
	 		    sca `q2' = (`M'+`N' - `lmcv' + sqrt((`M'+`N'-`lmcv')^2 - 4*`M'*`N'))/2
	 		    if ((`q1' < `N') | (`q2' > `M')) {
	 				sca `type1' = 3
					local lm_cset : di "(    -inf,     inf)"
	 		    }
	 		    else { 		
				mat `A1' = inv(`omega')*`ypz'*inv(`zpz')*`zpy'*inv(`omega')-`q1'*inv(`omega')
				mat `A2' = inv(`omega')*`ypz'*inv(`zpz')*`zpy'*inv(`omega')-`q2'*inv(`omega')
		 		sca `D1' = -4*det(`A1')
				sca `D2' = -4*det(`A2')
	 			if (`A1'[1,1]>0) { 
		  			if (`A2'[1,1]>0) { 
						sca `type1' = 5
						sca `y1' = (-2*`A1'[1,2] + sqrt(`D1'))/2/`A1'[1,1]
						sca `y2' = (-2*`A1'[1,2] - sqrt(`D1'))/2/`A1'[1,1]
						sca `y3' = (-2*`A2'[1,2] + sqrt(`D2'))/2/`A2'[1,1]
						sca `y4' = (-2*`A2'[1,2] - sqrt(`D2'))/2/`A2'[1,1]
						*eret scalar LM_x1 = `y4'
						*eret scalar LM_x2 = `y2'
						*eret scalar LM_x3 = `y1'
						*eret scalar LM_x4 = `y3'
						local lm_cset : di "(-inf," %9.0g `y1' "] U [" %9.0g `y3' "," %9.0g `y4' "] U [" %9.0g `y2' ",inf)"
					}
		  			else {
						sca `type1' = 6
						sca `y1' = (-2*`A1'[1,2] + sqrt(`D1'))/2/`A1'[1,1]
						sca `y2' = (-2*`A1'[1,2] - sqrt(`D1'))/2/`A1'[1,1]
						sca `y3' = (-2*`A2'[1,2] + sqrt(`D2'))/2/`A2'[1,1]
						sca `y4' = (-2*`A2'[1,2] - sqrt(`D2'))/2/`A2'[1,1]
						*eret scalar LM_x1 = `y3'
						*eret scalar LM_x2 = `y4'
						*eret scalar LM_x3 = `y2'
						*eret scalar LM_x4 = `y1'
						if `y1'<`y3' {
							local lm_cset : di "[" %9.0g `y2' "," %9.0g `y1' "] U [" %9.0g `y3' "," %9.0g `y4' "]"
						}
						else {
							local lm_cset : di "[" %9.0g `y3' "," %9.0g `y4' "] U [" %9.0g `y2' "," %9.0g `y1' "]"						
						}
			  		}
			  	}
				if (`A1'[1,1]<=0) {
					sca `type1' =5
			  		sca `y1' = (-2*`A1'[1,2] + sqrt(`D1'))/2/`A1'[1,1]
					sca `y2' = (-2*`A1'[1,2] - sqrt(`D1'))/2/`A1'[1,1]
					sca `y3' = (-2*`A2'[1,2] + sqrt(`D2'))/2/`A2'[1,1]
					sca `y4' = (-2*`A2'[1,2] - sqrt(`D2'))/2/`A2'[1,1]
					*eret scalar LM_x1 = `y1'
					*eret scalar LM_x2 = `y3'
					*eret scalar LM_x3 = `y4'
					*eret scalar LM_x4 = `y2'
					local lm_cset : di "(-inf," %9.0g `y1' "] U [" %9.0g `y3' "," %9.0g `y4' "] U [" %9.0g `y2' ",inf)"
		  		}
			    }
			}
		}
		*eret local LM_type `"`=`type1''"'
	* inversion of AR
		tempname lmcv1  AAA type2 xx1 xx2 DDD aaa
		sca `lmcv1' = invchi2tail(`df', (1-`level'/100))
		mat `AAA' =`ypz'*inv(`zpz')*`zpy'-`lmcv1'*`omega'
		sca `DDD' = -det(`AAA')
		sca `aaa' = `AAA'[2,2]
		if (`aaa'<0) {
	 		if (`DDD' <0) {
				sca `type2'=3
				local ar_cset : di "(    -inf,     inf)"
			}
	 		else{
				sca `type2'=4
		 		sca `xx1'= (`AAA'[1,2] + sqrt(`DDD'))/`aaa'
		 		sca `xx2' = (`AAA'[1,2] - sqrt(`DDD'))/`aaa'
				*eret scalar AR_x1 = `xx1'
				*eret scalar AR_x2 = `xx2'
				local ar_cset : di "(    -inf," %9.0g `xx1' "] U [" %9.0g `xx2' ",     inf)"
 			 }
		}
		else {
			if (`DDD'<0) {
				sca `type2'=1
				local ar_cset "null set"
			}
	 		else {
		  		sca `type2'=2
		  		sca `xx1'= (`AAA'[1,2]-sqrt(`DDD'))/`aaa'
		  		sca `xx2'= (`AAA'[1,2]+sqrt(`DDD'))/`aaa'
				*eret scalar AR_x1 = `xx1'
				*eret scalar AR_x2 = `xx2'
				local ar_cset : di "[" %9.0g `xx1' "," %9.0g `xx2' "]"
 			}
	 	}
		*eret local AR_type `"`=`type2''"'
	/* formatting for confidence sets
		Test		Result type		Interval
		-----------------------------------------------------------------------
		CLR		1			Empty set
				2			[x1, x2]
				3			(-infty, +infty)
				4		    (-infty, x1] U [x2, infty)
				
		AR		1			Empty set
				2			[x1, x2]
				3			(-infty, +infty)
				4		    (-infty, x1] U [x2, infty)
				
		LM		1			Not used (not possible)
						2			[x1, x2]                                
				3			(-infty, +infty)
				4		(-infty, x1] U [x2, infty)
				5		(-infty, x1] U [x2, x3] U [x4, infty)
				6		    [x1, x2] U [x3, x4]
		
		-----------------------------------------------------------------------
	*/
	* format and return confidence intervals
		return local clr_cset="`clr_cset'"
		return local lm_cset="`lm_cset'"
		return local ar_cset="`ar_cset'"
end

/* Program from Moreira, Mikusheva, and Poi's condivreg program--for finding CLR p-value */
program new_try
	args k qt lrstat pval_new
	tempname gamma pval  u s2 qs farg1 farg2 farg wt
	sca `gamma' = 2*exp(lngamma(`k'/2)) / sqrt(_pi) / exp(lngamma((`k'-1)/2))
	if("`k'" == "1") {
		sca `pval' = 1 - chi2(`k', `lrstat')
	}
	else if ("`k'"== "2") {
		local ni 20
		mat `u' = J(`ni'+1,1,0)
		mat `s2' = J(`ni'+1,1,0)
		mat `qs' = J(`ni'+1,1,0)
		mat `wt' = J(1,`ni'+1,2)
		mat `farg1' = J(`ni'+1,1,0)
		mat `qs'[1,1] = (`qt'+`lrstat')
		mat `farg1'[1,1] = `gamma'*chi2(`k',`qs'[1,1])
		forv i =1(1)`ni'{
			mat `u'[`i'+1,1] = `i'*_pi/2/`ni'
			mat `s2'[`i'+1,1] = sin(`u'[`i'+1,1])
			mat `qs'[`i'+1,1] = (`qt'+`lrstat') / (1+(`qt'/`lrstat')*`s2'[`i'+1,1]*`s2'[`i'+1,1])
			mat `farg1'[`i'+1,1] = `gamma'*chi2(`k',`qs'[`i'+1,1])
		}
		mat `wt'[1,1] = 1
		mat `wt'[1,`ni'+1] = 1
		local ni = `ni'/2
		forv i =1(1)`ni'{
			mat `wt'[1,`i'*2] = 4
		}
		local ni = `ni'*2
		mat `wt' = `wt'*_pi/2/3/`ni'
		mat `pval' = `wt'*`farg1'
		sca `pval' = 1-trace(`pval')
	}
	else if ("`k'"== "3") {
		local ni 20
		mat `s2' = J(`ni'+1,1,0)
		mat `qs' = J(`ni'+1,1,0)
		mat `wt' = J(1,`ni'+1,2)
		mat `farg1' = J(`ni'+1,1,0)
		mat `qs'[1,1] = (`qt'+`lrstat')
		mat `farg1'[1,1] = `gamma'*chi2(`k',`qs'[1,1])
		forv i =1(1)`ni'{
			mat `s2'[`i'+1,1] = `i'/`ni'
			mat `qs'[`i'+1,1] = (`qt'+`lrstat') / (1+(`qt'/`lrstat')*`s2'[`i'+1,1]*`s2'[`i'+1,1])
			mat `farg1'[`i'+1,1] = `gamma'*chi2(`k',`qs'[`i'+1,1])
		}
		mat `wt'[1,1] = 1
		mat `wt'[1,`ni'+1] = 1
		local ni = `ni'/2
		forv i =1(1)`ni'{
			mat `wt'[1,`i'*2] = 4
		}
		local ni = `ni'*2
		mat `wt' = `wt'/3/`ni'
		mat `pval' = `wt'*`farg1'
		sca `pval' = 1-trace(`pval')
	}
	else if ("`k'"== "4") {
		local eps .02
		local ni 50
		mat `s2' = J(`ni'+1,1,0)
		mat `qs' = J(`ni'+1,1,0)
		mat `wt' = J(1,`ni'+1,2)
		mat `farg' = J(`ni'+1,1,0)
		mat `farg1' = J(`ni'+1,1,0)
		mat `farg2' = J(`ni'+1,1,1)
		mat `qs'[1,1] = (`qt'+`lrstat')
		mat `farg1'[1,1] = `gamma'*chi2(`k',`qs'[1,1])
		mat `farg'[1,1] = `farg1'[1,1]*`farg2'[1,1]
		forv i = 1(1)`ni'{
			mat `s2'[`i'+1,1] = `i'/`ni'*(1-`eps')
			mat `qs'[`i'+1,1] = (`qt'+`lrstat') / (1+(`qt'/`lrstat')*`s2'[`i'+1,1]*`s2'[`i'+1,1])
			mat `farg1'[`i'+1,1] = `gamma'*chi2(`k',`qs'[`i'+1,1])
			mat `farg2'[`i'+1,1] = sqrt(1-`s2'[`i'+1,1]*`s2'[`i'+1,1])
			mat `farg'[`i'+1,1] = `farg1'[`i'+1,1]*`farg2'[`i'+1,1]
		}
		mat `wt'[1,1] = 1
		mat `wt'[1,`ni'+1] = 1
		local ni = `ni'/2
		forv i = 1(1)`ni'{
			mat `wt'[1,`i'*2] = 4
		}
		local ni = `ni'*2
		mat `wt' = `wt'/3/`ni'*(1-`eps')
		mat `pval' = `wt'*`farg'
		sca `pval' = 1-trace(`pval')
		sca `s2' = 1-`eps'/2
		sca `qs' = (`qt'+`lrstat')/(1+(`qt'/`lrstat')*`s2'*`s2')
		sca `farg1' = `gamma'*chi2(`k',`qs')
		sca `farg2' = 0.5*(asin(1)-asin(1-`eps'))-(1-`eps') / 2*sqrt(1-(1-`eps')*(1-`eps'))
		sca `pval' = `pval'-`farg1'*`farg2'
	}
	else {
		local ni 20
		mat `s2' = J(`ni'+1,1,0)
		mat `qs' = J(`ni'+1,1,0)
		mat `wt' = J(1,`ni'+1,2)
		mat `farg' = J(`ni'+1,1,0)
		mat `farg1' = J(`ni'+1,1,0)
		mat `farg2' = J(`ni'+1,1,1)
		mat `qs'[1,1] = (`qt'+`lrstat')
		mat `farg1'[1,1] = `gamma'*chi2(`k',`qs'[1,1])
		mat `farg'[1,1] = `farg1'[1,1]*`farg2'[1,1]
		forv i =1(1)`ni'{
			mat `s2'[`i'+1,1] = `i'/`ni'
			mat `qs'[`i'+1,1] = (`qt'+`lrstat') / (1+(`qt'/`lrstat')*`s2'[`i'+1,1]*`s2'[`i'+1,1])
			mat `farg1'[`i'+1,1] = `gamma'*chi2(`k',`qs'[`i'+1,1])
			if "`i'" == "`ni'"			mat `farg2'[`i'+1,1] = 0
			else						mat `farg2'[`i'+1,1] = (1-`s2'[`i'+1,1]*`s2'[`i'+1,1])^((`k'-3)/2)
			mat `farg'[`i'+1,1] = `farg1'[`i'+1,1]*`farg2'[`i'+1,1]
		}
		mat `wt'[1,1] = 1
		mat `wt'[1,`ni'+1] = 1
		local ni = `ni'/2
		forv i = 1(1)`ni'{
			mat `wt'[1,`i'*2] = 4
		}
		local ni = `ni'*2
		mat `wt' = `wt'/3/`ni'
		mat `pval' = `wt'*`farg'
		sca `pval' = 1-trace(`pval')
	}
	sca `pval_new' = `pval'
end 

/* Other programs from Mikusheva and Poi's condivreg */
program mat_inv_sqrt
	args in out
	tempname v vpri lam srlam
	local k = rowsof(`in')
	mat symeigen `v' `lam' = `in'
	mat `vpri' = `v''
	/* Get sqrt(lam)	  */
	mat `srlam' = diag(`lam')
	forv i = 1/`k' {
		mat `srlam'[`i', `i'] = 1/sqrt(`srlam'[`i', `i'])
	}
	mat `out' = `v'*`srlam'*`vpri'
end

program inversefun
	args M k alpha C
	tempname eps a  b x fa fb lrstat fx
	sca `eps' = 0.000001
	sca `a' = `eps' 
	sca `b' = `M' - `eps'
	sca `lrstat'= `M' - `a'
	new_try `k' `a' `lrstat' `fa'
	sca `lrstat' = `M' - `b'
	new_try `k' `b' `lrstat' `fb'
	if(`fa' > `alpha')			sca `C' = `a'
	else  if ( `fb' <`alpha')	sca `C' = `b'
	else {
		while (`b'-`a'>`eps') {
			sca `x' = (`b'-`a')/2+`a'
			sca `lrstat'= `M'-`x'
			new_try `k' `x' `lrstat' `fx'
			if (`fx' >`alpha')		sca `b' = `x'
			else					sca `a' = `x'
		}
		sca `C' = `x'
	}
end

/* Programs borrowed from Stata's suest command */

program Fix_regress
/* - adds equation name "mean" to existing coefficients
   - adds an equation named "lnvar" for the log(variance)
   - returns in the two vars sc1 and sc2 the score variables
*/
	args  b V sc1 sc2
	confirm matrix `b'
	confirm matrix `V'
	tempname b0 var
	// REML estimate of variance
	scalar `var' = e(rmse)^2
	matrix `b0' = log(`var')
	matrix coln `b0' = lnvar:_cons
	local n = colsof(`b')
	matrix coleq `b' = mean
	matrix `b'  = `b', `b0'
	local names : colfullnames `b'
	matrix `V' = (`V', J(`n',1,0) \ J(1,`n',0) , 2/e(N))
	local Stata11 = cond(c(stata_version)>=11, "version 11:", "")
	`Stata11' matrix colnames `V' = `names'
	`Stata11' matrix rownames `V' = `names'
	tempvar res
	predict double `res' if e(sample), res
	gen double `sc1' = `res' / `var'		if e(sample)
	gen double `sc2' = 0.5*(`res'*`sc1' - 1)	if e(sample)
end	

program GetMat
	args name b V
	local ev e(V)
	capture {
		confirm matrix e(b)
		confirm matrix `ev'
		matrix `b' = e(b)
		matrix `V' = `ev'
	}
	if _rc {
		dis as err ///
		"impossible to retrieve e(b) and e(V) in `name'"
		exit 198
	}
	if "`e(cmd)'" == "cnsreg" {
		if !missing(e(rmse)) & e(rmse) != 0 {
			matrix `V' = `V'/(e(rmse)*e(rmse))
		}
	}
end

program FixEquationNames, rclass
/* rename the equations to "name" in case of 1/0 equation, otherwise it
   prefixes "name" to equations if this yields unique equation names,
   and numbers the equations "name"_nnn otherwise.
*/
	args name b V
	if "`name'" == "." {
		local name _LAST
	}
	local qeq : coleq `b', quote
	local qeq : list clean qeq
	local eqnames : coleq `b'
	if `:length local qeq' != `:length local eqnames' {
		foreach el of local qeq {
			local new : subinstr local el " " "_", all
			local new : subinstr local new "." ",", all
			local neweq `"`neweq' `new'"'
		}
		matrix coleq `b' = `neweq'
		matrix coleq `V' = `neweq'
		matrix roweq `V' = `neweq'
		local eqnames `"`neweq'"'
	}
	local eq : list uniq eqnames
	local neq : word count `eq'
	if "`eq'" == "_" {
		local eqnames `name'
	}
	else {
		// modify equation names
		foreach e of local eq {
			local newname = substr("`name'_`e'",1,32)
			local meq `meq' `newname'
		}

		local eqmod : list uniq meq
		local neqmod : word count `eqmod'
		if `neq' == `neqmod' {
			// modified equation names are unique
			forvalues i = 1/`neq' {
				local oldname : word `i' of `eq'
				local newname : word `i' of `eqmod'
				local eqnames : subinstr local eqnames "`oldname'" "`newname'", word all
			}
		}
		else {
			// truncated modified equations not unique
			// use name_1, name_2, ...
			tokenize `eq'
			forvalues i = 1/`neq' {
				local eqnames : subinstr local eqnames "``i''" "`name'_`i'", word all
			}
		}
	}
	matrix coleq `b' = `eqnames'
	matrix roweq `V' = `eqnames'
	matrix coleq `V' = `eqnames'
	return local neq `neq'
	return local eqnames	`eq'
	return local neweqnames `eqmod'
end	
	
