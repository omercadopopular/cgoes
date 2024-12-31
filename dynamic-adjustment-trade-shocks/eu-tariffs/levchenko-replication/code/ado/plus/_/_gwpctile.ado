* 1.1.0 24 May 2007 
*! Uli Kohler 1.0.0 April 4, 2007 @ 18:47:24
*! egen function -pctile()- with weights and altdef
program _gwpctile
	version 8.2
	syntax newvarname =/exp [if] [in]  ///
	  [, Weights(string) p(real 50) ALTdef BY(varlist)  ]

	if `p'<=0 | `p'>=100 { 
		di as err "p(`p') must be between 0 and 100"
		exit 198
	}

	tempvar touse x

	if "`weights'" != "" { 
		local weights "[aweight=`weights']"
		if "`altdef'" != "" { 
			di as err "altdef not allowed with weights()"
			exit 198 
		}
	}	
	
	quietly {
		mark `touse' `if' `in'
		gen double `x' = `exp' if `touse'

		if "`by'"=="" {
			_pctile `x' `weights' if `touse', p(`p') `altdef' 
			gen `typlist' `varlist' = r(r1) if `touse'
			exit 0 
		}

		sort `touse' `by' `x'
		tempvar N
		by `touse' `by': gen long `N' = _n == 1 if `touse'
		by `touse': replace `N' = sum(`N') if `touse'
		sum `N', meanonly
		local maxby = r(max)

		gen `typlist' `varlist' = .
		forv i = 1/`maxby' {
			_pctile `x' `weights' ///
			  if `touse' & `N' == `i', p(`p') `altdef' 
			replace `varlist' = r(r1) if `touse' & `N' == `i'
		}
	}	
end
	
