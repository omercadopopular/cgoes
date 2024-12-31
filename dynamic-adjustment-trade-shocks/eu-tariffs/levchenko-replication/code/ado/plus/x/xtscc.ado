*! xtscc, version 1.4, Daniel Hoechle, 01dec2017
*
* This program largely is a translation of Driscoll and Kraay's procedure for GAUSS.
* Differences between Driscoll and Kraay's GAUSS-program and -xtscc-:
*
* 1) -xtscc- is able to handle missing values and unbalanced panels. 
* 2) -xtscc- can estimate fixed effects (within) regression models.
* 3) -xtscc- can estimate random effects regression models (GLS estimator only).
* 3) -xtscc- can estimate pooled OLS as well as fixed effects regression models
*     with analytic weights.
* 4) -xtscc- does not offer the opportunity to estimate two stage least squares (2SLS)
*    regression models as does Driscoll and Kraay's original GAUSS program.
*
*
* Syntax:
* =======
*
*   xtscc depvar [indepvar] [if] [in] [aweight=exp] [, FE RE POOLed LAG(nlags) Level(cilevel) NOConstant ASE]
*   xtscc is byable.
*
*
* Notes:
* ======
*
* (1) The dataset has to be tsset.
* (2) The procedure uses functions from Ben Jann's -moremata- package.
* (3) Version 1.2 of the program corrects an error in the computation of the df used for
*     computing statistical inference.
* (4) Version 1.3 of the program adds option -noconstant- for estimating
*     OLS regressions without intercept and for and option -ase- for estimating
*     Driscoll-Kraay SE without small sample adjustment.
* (5) Version 1.4 of the program allows -xtscc, fe- to also estimate
*     fixed effects regressions with analytical weights. Thereby, the
*     within transform works as in Stata's official -areg- command.
* (6) Version 1.4 of the program allows -xtscc- to estimate random effects models.
*     Thereby, the coefficient estimates match those from official Stata's 
*     -xtreg, re- command.
* (7) Thanks to Sergio Correia, version 1.4 of the program now also handles
*     factor variables as explanatory variables.
*
* ==============================================================
* Daniel Hoechle
* This version:  30. October 2017
* First version: 27. February 2007
* ==============================================================

  capture program drop xtscc
  capture mata: mata drop driscoll()
  capture mata: mata drop distinct()
  capture mata: mata drop _mm_panels()
  capture mata: mata drop _mm_colrunsum()
  capture mata: mata drop mm_colrunsum() 
  capture mata: mata drop mm_npanels()


program define xtscc , eclass sortpreserve byable(recall) prop(sw)
  version 9.2

  if !replay() {
      tempname b V
			tempname ratio sigma_e sigma_u rho 
			tempname r2 r2_w r2_b rmse
			tempname N_conseqTPeriods N_Tperiods NObs df_m sse N_g
      tempvar cons TransVar2
      ereturn clear
      syntax varlist(numeric fv ts) [if] [in] [aweight/] [, LAG(integer 9999) Level(cilevel) FE RE POOLed NOConstant ASE]
      marksample touse
      
      * Check if the dataset is tsset:
        qui tsset
        local panelvar "`r(panelvar)'"
        local timevar  "`r(timevar)'"
        
      * Check if the panel dataset's timevar is regularly spaced
        qui tab `timevar'
				scalar `N_Tperiods'=r(r)
				sum `timevar', meanonly
				scalar `N_conseqTPeriods'=r(max)-r(min)+1
				if `N_Tperiods'<`N_conseqTPeriods' {
					di as err "`timevar' is not regularly spaced: there are contemporaneous gap(s) across all subjects in `panelvar'"
					exit 101
				}
      
        
      * Generate a variable for the regression constant 
        local lag = abs(`lag')
        if "`noconstant'"=="" {
           qui gen double `cons'=1    // regression constant
        }

      * Split varlist into dependent and independent variables:
        fvexpand `varlist'
        loc expanded_varlist `r(varlist)'
        gettoken expanded_rhsvar expanded_rhsvars : expanded_varlist, bind

        fvrevar `expanded_varlist'
        loc varlist `r(varlist)'
        gettoken lhsvar rhsvars : varlist, bind
				if "`weight'"==""   qui gen double `TransVar2' = 1          // perform equal weighted estimation
				else                qui gen double `TransVar2' = `exp'      // perform weighted estimation
				

      * Estimate the consistent covariance matrix as described in Driscoll and Kraay (1998):
        if "`fe'"=="" & "`re'"=="" {  // Pooled OLS/WLS case
				          
					* WLS-transform:
          qui foreach var of local varlist {
              tempvar w`var'
              local tname "`w`var''"
              gen double `w`var'' = sqrt(`TransVar2') * `var' if `touse'
              if "`var'"=="`lhsvar'"    local lvar "`tname'"
              else                      local rvar "`rvar' `tname'"
          }
          if "`noconstant'"=="" {
             qui replace `cons' = sqrt(`TransVar2') * `cons'
          }
					
					
			* Use official Stata's -reg- command to obtain the R-squared and RMSE:
					if "`noconstant'"=="" {
						 qui reg `lhsvar' `rhsvars' [aweight=`TransVar2'] if `touse' 
					}
					else {
						 qui reg `lhsvar' `rhsvars' [aweight=`TransVar2'] if `touse', noconstant
					}
					scalar `r2' = e(r2)
					scalar `rmse' = e(rmse)
					local df_m = e(df_m)
					local rank = e(rank)
					ereturn clear
				
        }
        else if "`fe'"=="fe" | "`re'"=="re" {  // FE or GLS RE case
				           			
          if "`noconstant'"!="" {
            di as err "option `noconstant' not allowed with option `fe'`re'"
            exit 101
          }
					
          * Within-transformation of the data (FE and GLS RE estimation)
            sort `panelvar' `timevar'
            tempname TotMean
            tempvar ti
						qui {
							by `panelvar': egen double `ti' = total(`TransVar2') if `touse'
						}
            qui foreach var of local varlist {
						
							tempvar w`var' b`var'
							
							* Time average per subject
							local bname "`b`var''"
							by `panelvar': egen double `b`var'' = total(`var'*`TransVar2') if `touse'
							replace `b`var'' = `b`var''/`ti'
							if "`var'"=="`lhsvar'"    local blvar "`bname'"
							else                      local brvar "`brvar' `bname'"
							
							* Within-transform
							local wname "`w`var''"            
							sum `var' if `touse' [aweight=`TransVar2'], meanonly
							scalar `TotMean' = r(mean)
							gen double `w`var'' = `var' - `b`var'' + `TotMean' if `touse'
							if "`var'"=="`lhsvar'"    local lvar "`wname'"
							else                      local rvar "`rvar' `wname'"

						}
						
					* Count the number of subjects
						tempvar UseXS	
						sort `touse' `panelvar' `timevar'
						by `touse' `panelvar': gen `UseXS' = (_n==1)
						sum `UseXS' if `touse', meanonly
						scalar `N_g' = r(sum)
						
						
					* Use official Stata's -reg- command to obtain the R-squared and other stats:
						qui reg `lvar' `rvar' [aweight=`TransVar2'] if `touse' 
						scalar `r2_w' = e(r2)
						scalar `sse' = e(rss)
						scalar `NObs' = e(N)
						scalar `df_m' = e(df_m)
						scalar `sigma_e' = sqrt(`sse'/(`NObs' - `df_m' - `N_g'))
						local rank = e(rank)
						ereturn clear
						
					
					* Option RE
					if "`re'"=="re" {   // Implementation of the GLS transform
											
						* Number of observations per subject & dummy defining first obs per subject
						  tempvar Ti tmp
							//sort `touse' `panelvar' `timevar'				
							by `touse' `panelvar': gen `Ti' = _N
							by `touse' `panelvar': gen `tmp' = 1/_N
							sum `tmp' if `UseXS' & `touse', meanonly
							tempname Tbar
							scalar `Tbar' = 1/r(mean)
							drop `tmp'		
											
						* BE estimation and formation of key stats
							qui reg `blvar' `brvar' if `UseXS' & `touse'
							//qui reg `blvar' `brvar' [aweight=`ti'] if `UseXS' & `touse'
							scalar `sigma_u' = max(sqrt(e(rmse)^2 - `sigma_e'^2/`Tbar'), 0)
							scalar `r2_b' = e(r2)
							scalar `rho' = `sigma_u'^2/(`sigma_u'^2+`sigma_e'^2)		
							scalar `ratio' = `sigma_u'/`sigma_e'				
							tempvar ti theta_i
							gen double `theta_i' = 1 - 1 / sqrt(`Ti'*(`ratio')^2 + 1) if `touse'
							ereturn clear				
											
						* GLS transform
							qui tsset
							qui foreach var of local varlist {
									replace `w`var'' = `var' - `theta_i'*`b`var'' if `touse'
							}
							qui replace `cons' = 1 - `theta_i'

					}	
						
						
          * WLS-transform of the data
          qui foreach var of local varlist {
								replace `w`var'' = sqrt(`TransVar2') * `w`var'' if `touse'  
          }
					qui replace `cons' = sqrt(`TransVar2') * `cons' if `touse'
						
        } 
				
      
      * Sort the dataset for use in mata:
        sort `timevar' `panelvar'
        
      * Perform the estimation:
        if "`noconstant'"=="" {
           mata: driscoll("`lvar'", "`rvar' `cons'", "`touse'", "`panelvar'", "`timevar'", `lag')
        }
        else {
           mata: driscoll("`lvar'", "`rvar'", "`touse'", "`panelvar'", "`timevar'", `lag')        
        }

      * Next, we have to attach row and column names to the produced matrices:
        foreach Vector in "Beta" "se_beta" "t_beta" {
           if "`noconstant'"=="" {
              matrix rownames `Vector' = `expanded_rhsvars' _cons
           }
           else {
              matrix rownames `Vector' = `expanded_rhsvars'
           }
           matrix colnames `Vector' = y1
        }
        if "`noconstant'"=="" {
           matrix rownames VCV = `expanded_rhsvars' _cons
           matrix colnames VCV = `expanded_rhsvars' _cons
        }
        else {
           matrix rownames VCV = `expanded_rhsvars'
           matrix colnames VCV = `expanded_rhsvars'
        }

      * Then we prepare the matrices for upload into e() ...
        matrix `b' = Beta'
        if "`ase'"=="" {
						matrix `V' = (TT/(TT-1))*((nObs-1)/(nObs-`rank'))*VCV
        }
        else {
            matrix `V' = VCV
        }
				
			* Compute the overall R-squared in case of RE estimation
			  if "`re'"=="re" {
				    tempvar XB
				    tempname r2_o		
						qui gen double `XB' = `b'[1,_cons] if `touse'
						local j = 1
            qui foreach var of local rhsvars {
						   replace `XB' = `XB' + `b'[1, `j']*`var' if `touse'
               local j = `j' + 1
						}	
						qui corr `XB' `lhsvar' [aweight=`TransVar2'] if `touse'
						scalar `r2_o' = r(rho)^2
				}

      * ... post the results in e():
			  ereturn clear
        ereturn post `b' `V', esample(`touse') depname("`lhsvar'")
        ereturn scalar N = nObs
        ereturn scalar N_g = nGroups
        ereturn scalar df_m = `df_m'
        ereturn scalar df_r = TT - 1
				
				
			* Model fit test
 				qui if "`rhsvars'"!=""  test `expanded_rhsvars', min   // Perform the F-Test
			  if "`re'"=="" {
				  ereturn scalar F = r(F)
				}
				else {
					ereturn scalar chi2 = r(F) * `df_m'
				}
				

        * Post the R-squared and RMSE
          if "`fe'"=="" & "`re'"==""     ereturn scalar r2 = `r2'
          else if "`fe'"=="fe"           ereturn scalar r2_w = `r2_w'
					else if "`re'"=="re" 			     ereturn scalar r2_o = `r2_o'			
					if "`fe'"=="" & "`re'"==""     ereturn scalar rmse = `rmse'

				* Post the remaining results
					ereturn scalar lag = lag_f
					if "`re'"=="re" {
						ereturn scalar sigma_e = `sigma_e'
						ereturn scalar sigma_u = `sigma_u'
						ereturn scalar rho = `rho'
					}
					ereturn local groupvar "`panelvar'"
					ereturn local title "Regression with Driscoll-Kraay standard errors"
					ereturn local vcetype "Drisc/Kraay"
					ereturn local depvar "`lhsvar'"
					if "`fe'"=="" & "`re'"==""    ereturn local method "Pooled OLS"
					else if "`fe'"=="fe"          ereturn local method "Fixed-effects regression"
					else                          ereturn local method "Random-effects GLS regression"
					ereturn local predict "xtscc_p"
					ereturn local cmd "xtscc"
  }
  else {      // Replay of the estimation results
        if "`e(cmd)'"!="xtscc" error 301
        syntax [, Level(cilevel)]
  }
  
  * Display the results
	
        if "`e(method)'"=="Pooled OLS" {
            local R2text "R-squared         =    "
            local R2ret "e(r2)"
						local RMSE1 "_col(50) in green"
						local RMSE2 "Root MSE          =  "
						local RMSE3 "in yellow %8.4f e(rmse) _n"
        }
        else if "`e(method)'"=="Fixed-effects regression" {
            local R2text "within R-squared  =    "
            local R2ret "e(r2_w)"
        }
				else if "`e(method)'"=="Random-effects GLS regression" {
				    local R2text "overall R-squared =    "
            local R2ret "e(r2_o)"
						local re1 "in green"
						local re2 "corr(u_i, Xb) = "
						local re3 "in yellow "
						local re4 "0 " 
						local re5 "in green "
						local re6 "(assumed)"
				}
				
              
      * Header
			if "`re'"=="" {
			
        #delimit ;
        disp _n
          in green `"`e(title)'"'
          _col(50) in green `"Number of obs     ="' in yellow %10.0f e(N) _n
          in green `"Method: "' in yellow "`e(method)'"
          _col(50) in green `"Number of groups  ="' in yellow %10.0f e(N_g) _n
          in green `"Group variable (i): "' in yellow abbrev(`"`e(groupvar)'"',16)
          _col(50) in green `"F("' in yellow %3.0f e(df_m) in green `","' in yellow %6.0f e(df_r)
          in green `")"' _col(68) `"="' in yellow %10.2f e(F) _n
          in green `"maximum lag: "' in yellow e(lag)  
          _col(50) in green `"Prob > F          =    "' 
          in yellow %6.4f fprob(e(df_m),e(df_r),e(F)) _n 
          _col(50) in green `"`R2text'"' in yellow %5.4f `R2ret' _n
          `RMSE1' `"`RMSE2'"' `RMSE3'
          ;
        #delimit cr
				
			}
			else {

			  #delimit ;
        disp _n
          in green `"`e(title)'"'
          _col(50) in green `"Number of obs     ="' in yellow %10.0f e(N) _n
          in green `"Method: "' in yellow "`e(method)'"
          _col(50) in green `"Number of groups  ="' in yellow %10.0f e(N_g) _n
          in green `"Group variable (i): "' in yellow abbrev(`"`e(groupvar)'"',16)
          _col(50) in green `"Wald chi2("' in yellow e(df_m) in green `")"' 
					_col(68) `"="' in yellow %10.2f e(chi2) _n
          in green `"maximum lag: "' in yellow e(lag)   
          _col(50) in green `"Prob > chi2       =    "' 
          in yellow %6.4f chiprob(e(df_m),e(chi2)) _n 
					`re1' `"`re2'"' `re3' `"`re4'"' `re5' `"`re6'"'
          _col(50) in green `"`R2text'"' in yellow %5.4f `R2ret' _n
          `RMSE1' `"`RMSE2'"' `RMSE3'
          ;
        #delimit cr

			
			}
        
      * Display estimation results
			if "`re'"=="" {  
				ereturn display, level(`level')
				disp ""
			}
			else {  // With RE estimation, information on sigma_u and sigma_e is added
				ereturn display, level(`level') plus
				
				local c1 = `"`s(width_col1)'"'
				local w = `"`s(width)'"'
				if "`c1'"=="" {
					local c1 13
				}
				else {
					local c1 = int(`c1')
				}
				if "`w'"=="" {
					local w 78
				}
				else {
					local w = int(`w')
				}
				
				local c = `c1' - 1
				local rest = `w' - `c1' - 1
				local rho	: display %10.0g e(rho)
				local sigma_u	: display %10.0g e(sigma_u)
				local sigma_e	: display %10.0g e(sigma_e)
				di in smcl in gr %`c's "sigma_u" " {c |} " in ye %10s "`sigma_u'"
				di in smcl in gr %`c's "sigma_e" " {c |} " in ye %10s "`sigma_e'"
				di in smcl in gr %`c's "rho" " {c |} " in ye %10s "`rho'" /*
					*/ in gr "   (fraction of variance due to u_i)"
				di in smcl in gr "{hline `c1'}{c BT}{hline `rest'}"
				disp ""
			}
	
end



* ==============================================================
* This function performs the Driscoll and Kraay analysis
* ==============================================================
mata void driscoll(string scalar depvar,            ///
                   string scalar indepvar,          ///
                   string scalar touse,             ///
                   string scalar panvar,            ///
                   string scalar tvar,              ///
                   real scalar lag)
{
        // Declarations:
           real matrix    y, X, Panelmat
           real scalar    nObs, nVars
           real matrix    beta, resid, vcv, se_beta, t_beta
           real scalar    t, j, T
           real matrix    Nt, h, Omegaj, Shat
           
        
        // Build views to the data:
           pragma unset y
           st_view(y, ., depvar, touse)
           st_view(X=., ., tokens(indepvar), touse)
           st_view(Panelmat=., .,(tvar, panvar), touse)
           
        // Get the number of panels per time unit and the number of time periods:
           Nt = _mm_panels(Panelmat[.,1])
           T  = rows(Nt)
           if (lag==9999)   lag = floor(4*(T/100)^(2/9))    
           
        // Determine the start row of each time period (note that there is one row more
        // in t_start than in T. However, this row is required for the loops below to 
        // work!):
           t_start = (1 \ (mm_colrunsum(Nt):+1) )
           
        // Extract the total number of observations and the number of right hand side
        // variables (including the intercept):
           nVars = cols(X)
           nObs = rows(X)
           nGroups = distinct(Panelmat[.,2])
        
        // Obtain the OLS estimator beta, and the estimated residuals (resid):
           beta = invsym(cross(X,X))*cross(X,y)
           resid = y - X*beta
					 
        // Next, we form the TxnVars matrix h. The rows of matrix h are 1xnVars vectors
        // of cross-sectional averages of the moment conditions evaluated at
        // beta, ht(beta).
           h = J(T,nVars,.)
           for (t=1; t<=T; t++) {
                h[t,.] = (cross(X[(t_start[t]..(t_start[t+1]-1)),.],                    ///
                                      resid[(t_start[t]..(t_start[t+1]-1))]))'
           }
        // Next, Shat is constructed.
           Shat =  cross(h,h):/((nObs:^2):/T)    // Up to now: Shat = Omega0.
           for (j=1; j<=lag; j++) {
                Omegaj = cross(h[((j+1)..T),.],h[(1..(T-j)),.]):/((nObs:^2):/T)
                Shat = Shat + (1 - j/(lag+1)) * (Omegaj + Omegaj')
           }

        // Computation of the panel robust covariance matrix:
           // vcv = invsym(cross(X,X):/nObs)*Shat*invsym(cross(X,X):/nObs):/T
           vcv = invsym(cross(X,X))*Shat*invsym(cross(X,X)):*((nObs:^2):/T)
        
        // Compute additional statistics:
           se_beta =  (diagonal(vcv)):^0.5
           t_beta  =  beta :/ se_beta
        
        // Return the results to the xtscc.ado program
           st_numscalar("nVars", nVars)
           st_numscalar("nObs", nObs)
           st_numscalar("nGroups",nGroups)
           st_numscalar("TT",T)
           st_numscalar("lag_f", lag)
           st_matrix("Beta", beta)
           st_matrix("VCV", vcv)
           st_matrix("se_beta", se_beta)
           st_matrix("t_beta", t_beta)

}


* ==============================================================
* This function returns the number of distinct values in a vector.
* Note that -distinct- is slow because Stata's -select- function does not yet exist.
* ==============================================================
mata real scalar distinct(real vector x)
{
    real vector    y1, y2
    
    y1 = sort(x,1)
    y2 = _mm_panels(y1)
    return(rows(y2))
}


* ==============================================================
* These functions are taken from Ben Jann's -moremata- package.
* ==============================================================

mata real colvector _mm_panels(transmorphic vector X, | real scalar np)
{
        real scalar i, j, n
        real colvector res

        if (args()<2) np = mm_npanels(X)
        if (length(X)==0) return(J(0,1,.))
        res = J(np, 1, .)
        n = j = 1
        for (i=2; i<=length(X); i++) {
                if (X[i]!=X[i-1]) {
                        res[j++] = n
                        n = 1
                }
                else n++
        }
        res[j] = n
        return(res)
}

mata numeric matrix mm_colrunsum(numeric matrix A)
{
        numeric matrix B

        if (isfleeting(A)) {
                _mm_colrunsum(A)
                return(A)
        }
        _mm_colrunsum(B=A)
        return(B)
}

mata void _mm_colrunsum(numeric matrix Z)
{
        real scalar i

        _editmissing(Z, 0)
        for (i=2; i<=rows(Z); i++) Z[i,] = Z[i-1,] + Z[i,]
}

mata real scalar mm_npanels(vector X)
{
        real scalar i, np

        if (length(X)==0) return(0)
        np = 1
        for (i=2; i<=length(X); i++) {
                if (X[i]!=X[i-1]) np++
        }
        return(np)
}
