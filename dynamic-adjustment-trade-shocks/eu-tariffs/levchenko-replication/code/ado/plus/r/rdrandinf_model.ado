********************************************************************************
* rdrandinf_model: auxiliary program to permute statistics
* !version 1.0 2021-07-07
* Authors: Matias Cattaneo, Rocio Titiunik, Gonzalo Vazquez-Bare
* NOTE: runvar must be recentered at the cutoff before running
********************************************************************************

capture program drop rdrandinf_model
program define rdrandinf_model, rclass

	syntax varlist (min=2 max=2) [if] [in], stat(string) [runvar(string) endogtr(string) asy weights(string)]

	tokenize `varlist'
	local outvar "`1'"
	local treatment "`2'"
	marksample touse
	
	qui {

		if "`stat'"=="diffmeans" & "`weights'"=="" & "`asy'"==""{
			qui sum `outvar' if `treatment'==1 & `touse'
			local m1 = r(mean)
			qui sum `outvar' if `treatment'==0 & `touse'
			local m0 = r(mean)
			return scalar stat = `m1'-`m0'
		}
		
		if "`stat'"=="diffmeans" & "`weights'"!="" & "`asy'"==""{
			reg `outvar' `treatment' if  `touse' [aw=`weights'], vce(hc2)
			ret scalar stat = _b[`treatment']
		}

		if "`stat'"=="diffmeans" & "`weights'"=="" & "`asy'"!=""{
			reg `outvar' `treatment'  if `touse', vce(hc2)
			ret scalar stat = _b[`treatment']
			ret scalar asy_pval = 2*normal(-abs(_b[`treatment']/_se[`treatment']))
		}
		
		if "`stat'"=="diffmeans" & "`weights'"!="" & "`asy'"!=""{
			local weight_opt "[aw=`weights']"
			reg `outvar' `treatment'  if `touse' `weight_opt', vce(hc2)
			ret scalar stat = _b[`treatment']
			ret scalar asy_pval = 2*normal(-abs(_b[`treatment']/_se[`treatment']))
		}
		
		if "`stat'"=="ksmirnov"{
			ksmirnov `outvar' if `touse', by(`treatment')
			return scalar stat = r(D)
			ret scalar asy_pval = r(p)
		}
		
		if "`stat'"=="ranksum"{
			ranksum `outvar' if `touse', by(`treatment')
			return scalar stat = r(z)
			ret scalar asy_pval = 2*normal(-abs(r(z)))
		}
		
		if "`stat'"=="all"{
			ranksum `outvar' if `touse', by(`treatment')
			ret scalar stat3 = r(z)
			ksmirnov `outvar' if `touse', by(`treatment')
			return scalar stat2 = r(D)
			if "`weights'"==""{
				qui sum `outvar' if `treatment'==1 & `touse'
				local m1 = r(mean)
				qui sum `outvar' if `treatment'==0 & `touse'
				local m0 = r(mean)
				return scalar stat1 = `m1'-`m0'
			}
			else {
				reg `outvar' `treatment' if `touse' [aw=`weights'], vce(hc2)
				ret scalar stat1 = _b[`treatment']
			}
		}
		
		if "`stat'"=="ar"{
			if "`weights'"==""{
				qui sum `outvar' if `treatment'==1 & `touse'
				local m1 = r(mean)
				qui sum `outvar' if `treatment'==0 & `touse'
				local m0 = r(mean)
				return scalar stat = `m1'-`m0'
			}
			else {
				reg `outvar' `treatment' if `touse' [aw=`weights'], vce(hc2)
				ret scalar stat = _b[`treatment']
			}
		}
		
		if "`stat'"=="wald"{
			if "`weights'"==""{
				ivregress 2sls `outvar' (`endogtr'=`treatment')
			}
			else {
				ivregress 2sls `outvar' (`endogtr'=`treatment') [aw=`weights']
			}
			ret scalar stat = _b[`endogtr']
		}
		
		capture drop _runpoly_*
	
	}

end
