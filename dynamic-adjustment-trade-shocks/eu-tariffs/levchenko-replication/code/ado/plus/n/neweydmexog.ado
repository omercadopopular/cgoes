*! neweydmexog  V1.0   
* Slightly modified version of: dmexog by C F Baum and Steve Stillman with help from Mark Schaffer
* Changed to run after newey2
* Ref: Davidson & MacKinnon, Estimation and Inference in Econometrics, p.239

program define neweydmexog, rclass
	version 7.0
	syntax [anything]
	local xvarlist `anything'
	
	if "`e(cmd)'" ~= "ivreg" & "`e(cmd)'" ~= "ivreg2" & "`e(cmd)'" ~= "newey2" {
		di in r "neweydmexog only works after ivreg, ivreg2, or newey2; use dmexogxt after xtivreg"
		error 301
	}
	if "`e(cmd)'" == "ivreg" & "`e(version)'" < "05.00.04" {	
		di in red "neweydmexog requires version 5.0.4 or later of ivreg"	
		di in red "type -update query- and follow the instructions" /*	
			*/ " to update your Stata"	
		exit 198	
	}
	if "`e(model)'" != "iv"	& "`e(cmd)'"!="newey2" {
		di in red "not currently supported in GMM context: use hausman"
		exit 198
	}	
	if "`e(vcetype)'" == "Robust" {	
		local robust " robust"	
	}	
	if "`e(vcetype)'" == "Newey-West" {	
		local lag " lag(`e(lag)') force"	
	}	
	if "`e(clustvar)'" != "" {
		local cluster " cluster(`e(clustvar)')"
	}
	if "`e(wtype)'" == "aweight" | "`e(wtype)'" == "iweight" {	
		di in red "test not valid with aweights or iweights"	
		exit 198	
	}	

	tempname touse depvar inst incrhs nin b varlist i word regest weight
	tempname rhadd idvar
	
			/* mark sample */
	gen byte `touse' = e(sample)
			/* dependent variable */
	local depvar `e(depvar)'
   			/* instrument list */
	local inst `e(insts)'
			/* included RHS endog list */
	local incrhs `e(instd)'
	local nendog : word count `e(instd)'
			/* get regressorlist of original model; should check for
			collinearity between included/excluded exog */
    	mat `b' = e(b)
    	local varlist : colnames `b'
    	local varlist : subinstr local varlist "_cons" "", word count(local hascons)
* for ivreg, if no constant in original model, exclude from aux regr
        if `hascons' == 0 {local noc = "noc"}
			/* get weights setting of original model */
	local weight ""
	if "`e(wexp)'" != "" {
                local weight "[`e(wtype)'`e(wexp)']"
        }
* 1.3.7: check if xvarlist is populated, if so validate entries
	local ninc 0
	local rem 0
	if "`xvarlist'" ~= "" {
		local nexog : word count `xvarlist'
		local rem = `nendog' - `nexog'
		local nincrhs `incrhs'
			foreach v of local xvarlist {
* should make ts operators case-insensitive (per VLW)
				local nincrhs: subinstr local nincrhs "`v'" "", word count(local zap)
				if `zap' ~= 1 {
					di in r _n "Error: `v' is not an endogenous variable"
					exit 198
					}
				}
* remove nincrhs from varlist if rem>0 and load xvarlist in incrhs
			if `rem' > 0 {
				foreach v of local nincrhs {
				local varlist: subinstr local varlist "`v'" "", word
				}
			local incrhs `xvarlist'
			}
* incrhs now contains the pruned list of vars assumed exogenous
* nincrhs contains the remaining included endogenous
* varlist contains the included exogenous 
			local ninc : word count `incrhs'
			}

* deal with ts operators in endog list
		tsrevar `incrhs', sub
		local incrhs `r(varlist)'
		local rhadd ""
			estimates hold `regest'	
			foreach word of local incrhs {
		    	qui regress `word' `inst' `weight' if `touse'
				tempvar v_`word'
* 		as double
				qui predict double `v_`word'', res
				local rhadd "`rhadd' `v_`word''"
				}
* enable passthru of robust, cluster options
			if (`ninc' == 0  | `rem' == 0) {	
				qui regress `depvar' `varlist' `rhadd' `weight' if `touse', `noc' `robust' `cluster'
				}
			else {
				if e(cmd)=="newey2" {
					qui newey2 `depvar' `varlist' `rhadd' (`nincrhs' = `inst') `weight' /*
*/    			          if `touse', `noc' `lag'
				}
				else {
					qui ivreg `depvar' `varlist' `rhadd' (`nincrhs' = `inst') `weight' /*
*/          			    if `touse', `noc' `robust' `cluster'
				}
			}
			qui test `rhadd'
			return scalar df = r(df)
			return scalar df_r = r(df_r)
			return scalar dmexog = r(F)
			return scalar p = r(p)	
			di in gr _n
			if "`robust'`lag'" ~= "" {
				di in gr _col(52) "Robust"
			}
			di in gr "Wu-Hausman test of exogeneity: "   /*
		*/ 	in ye %9.0g return(dmexog) in gr            /* 
		*/ 	in gr "  F(" %2.0f in ye return(df) "," return(df_r) /*
		*/ 	in gr ")  P-value = " in ye %6.0g return(p)
			if "`e(clustvar)'" != "" {
				di in gr "Number of clusters (`e(clustvar)') = " in ye e(N_clust) in gr " "
			}					

		estimates unhold `regest'		
end
exit
