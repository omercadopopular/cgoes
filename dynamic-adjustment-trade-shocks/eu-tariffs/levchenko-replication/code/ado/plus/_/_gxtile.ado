*! 2.1 UK/NJC 14 Jan 2019 
*! _gxtile version 2.0 UK 28 AUG 2016
*! Categorizes exp by its quantiles - byable

* Version history 
// 2.0: Use levelsof instead of levels
// 1.2: Bug: Opt percentiles were treated incorrectely after implement. of option nq
//	   Allows By-Variables that are strings
// 1.1: Bug: weights are treated incorectelly in version 1.0. -> fixed
//     New option nquantiles() implemented	         
// 1.0: initial version

* Main program
program _gxtile, byable(onecall) sortpreserve
	version 8.2
	
** Syntax
	gettoken type 0 : 0
	gettoken h    0 : 0 
	gettoken eqs  0 : 0
	
	syntax varname(numeric) [if] [in] [, ///
	  Percentiles(string) ///
	  Nquantiles(string) ///
	  Weights(string) ALTdef by(varlist) ]
	
	marksample touse 
	
** Error Checks
	
	if "`altdef'" ~= "" & "`weights'" ~= "" {
		di as error "weights are not allowed with altdef"
		exit 111
	}
	
	if "`percentiles'" != "" & "`nquantiles'" != "" {
		di as error "do not specify percentiles and nquantiles"
		exit 198
	}
	
** Default Settings etc.
	
	if "`weights'" ~= "" {
		local weight "[aw = `weights']"
	}
	
	if "`percentiles'" != "" {
		local pctopt percentiles(`percentiles')
		local pct "`percentiles'"
	}
	
	else if "`nquantiles'" != "" 	{
		local pctopt nquantiles(`nquantiles')
		local pct "1/`=`nquantiles'-1'"
	}
	
	else if "`nquantiles'" == "" & "`percentiles'" == "" 	{
		local pctoption percentiles(50)
		local pct "1/2"
	}
	
	quietly {
		
		gen `type' `h' = .
		
*** Without by
		
		if "`by'"=="" {
			
			local i 1
			_pctile `varlist' `weight' if `touse', `pctopt' `altdef'
			foreach p of numlist `pct' {
				if `i' == 1 {
					replace `h' = `i' if `varlist' <= r(r`i') & `touse'
				}
				replace `h' = `++i' if `varlist' > r(r`--i')  & `touse'
				local i = `i' + 1
			}
			exit
		}
		
*** With by
	
		tempvar byvar
		by `touse' `by', sort: gen `byvar' = 1 if _n==1 & `touse'
		by `touse' (`by'): replace `byvar' = sum(`byvar')
		
		sum `byvar', meanonly 
		forval k = 1/`r(max)' {
			local i 1
			_pctile `varlist' `weight' if `byvar' == `k' & `touse' , `pctopt' `altdef'
			foreach p of numlist `pct'  {
				if `i' == 1 {
					replace `h' = `i' if `varlist' <= r(r`i') & `byvar' == `k' & `touse'
				}
				replace `h' = `++i' if `varlist' > r(r`--i')  & `byvar' == `k' & `touse'
				local i = `i' + 1
				}
		}
	}
	
end
exit

