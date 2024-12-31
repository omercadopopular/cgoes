* _gmllabvpos version 1.0.1 NJC 19 March 2006
*! _gmllabvpos version 1.0 UK 19 Feb 04
* Generates Clock-Positions for scatter-option mlabvpos() as proposed by Cleveland
program _gmlabvpos
	version 8.2
        gettoken type 0 : 0
        gettoken h    0 : 0 
        gettoken eqs  0 : 0

	syntax varlist(min=2 max=2) [if] [in] [, POLYnomial(int 1) LOG MATrix(string)]
	gettoken yvar varlist: varlist
	gettoken xvar: varlist

        quietly {
        	// Clock-Position Matrix
        	if "`matrix'" == "" {
	               	matrix input clock = (11 12 12 12  1 \\ ///
        	       		              10 11 12  1  2 \\ ///
               			               9  9 12  3  3 \\ ///
               			               8  7  6  5  4 \\ ///
               		        	       7  6  6  6  5 )
               	}
               	if "`matrix'" ~= "" {
               		matrix input clock = (`matrix')
               	}
               	    
               	// Log-Option
		if "`log'" != "" {
			tempvar log
			gen `log' = log(`xvar')
		}

		// Polynomials
		local indep = cond("`log'" == "","`xvar'","`log'")
               	if `polynomial' > 1 {
               		forv i = 1/`polynomial' {
               			tempvar poly`i'
               			gen `poly`i'' = `xvar'^`i'
               			local polyterm `polyterm' `poly`i''
               		}
               	}

               	// Calculate Residuals
               	tempvar yhat resid leverage
		regress `yvar' `indep' `polyterm' `if' `in'
		predict `yhat'
		predict `resid', resid

        	// Categorize xvar into 5 groups
		tempvar `xvar'g
		sum `xvar' `if' `in', meanonly
		local urange = r(max) - r(mean)
		local lrange = r(mean) - r(min)
		gen ``xvar'g' = 1 ///
		  if inrange(`xvar',r(min),r(mean)-`lrange'/5 * 3)
		replace ``xvar'g' = 2 ///
		  if inrange(`xvar',r(mean)-`lrange'/5*3,r(mean)-`lrange'/5)
		replace ``xvar'g' = 3 ///
		  if inrange(`xvar',r(mean)-`lrange'/5,r(mean)+`urange'/5)
		replace ``xvar'g' = 4 ///
		  if inrange(`xvar',r(mean)+`urange'/5,r(mean)+`urange'/5*3)
		replace ``xvar'g' = 5 ///
		  if inrange(`xvar',r(mean)+`urange'/5*3,r(max))

        	// Categorize yvar into 5 groups, according to reg-residuals
		tempvar `yvar'g        	
		sum `resid', meanonly
		local urange = r(max) - r(mean)
		local lrange = r(mean) - r(min)
		gen ``yvar'g' = 1 ///
		  if inrange(`resid',r(min),r(mean)-`lrange'/5 * 3)
		replace ``yvar'g' = 2 ///
		  if inrange(`resid',r(mean)-`lrange'/5*3,r(mean)-`lrange'/5)
		replace ``yvar'g' = 3 ///
		  if inrange(`resid',r(mean)-`lrange'/5,r(mean)+`urange'/5)
		replace ``yvar'g' = 4 ///
		  if inrange(`resid',r(mean)+`urange'/5,r(mean)+`urange'/5*3)
		replace ``yvar'g' = 5 ///
		  if inrange(`resid',r(mean)+`urange'/5*3,r(max))
                
               // generate clock-position according to Matrix               
               gen `type' `h' = .
               forv i=1/5 {
                	forv j=1/5 {
                		replace `h' = clock[`i',`j'] ///
                		  if (5 -``yvar'g') +1  == `i' & ``xvar'g' == `j'
                	}
                }
	}
end
