*! 1.2.1 NJC 1 March 2012         
*! 1.2.0 NJC 15 September 2008
* 1.1.1 GML NJC 26 February 2002
* 1.1.0 GML NJC 25 February 2002
* 1.0.0 21 November 2001
program distinct, rclass sortpreserve byable(recall)
	version 8.0
	syntax [varlist] [if] [in] [, MISSing Abbrev(int -1) Joint ///
	MINimum(int 0) MAXimum(int -1) ]

	if `maximum' == -1 local maximum . 

	if `minimum' > `maximum' { 
		local swap `minimum' 
		local minimum `maximum' 
		local maximum `swap' 
		di as txt "min(`maximum') max(`minimum') interpreted as min(`minimum') max(`maximum')" 
	}

	if "`joint'" != "" { 
		di 
		di in text "        Observations" 
		di in text "      total   distinct"

		if "`missing'" != "" marksample touse, novarlist 
		else marksample touse, strok  
		tempvar vals 
		bysort `touse' `varlist': gen byte `vals' = (_n == 1) * `touse'
		su `vals' if `touse', meanonly 

		if r(sum) >= `minimum' & r(sum) <= `maximum' { 
			di as res %11.0g r(N) "  " %9.0g r(sum)  
		}
	} 

	else { 
		if `abbrev' == -1 { 
			foreach v of local varlist { 
				local abbrev = max(`abbrev', length("`v'")) 
			}
		}

		local abbrev = max(`abbrev', 5) 
		local abbp2 = `abbrev' + 2 
		local abbp3 = `abbrev' + 3 

		di
		di as txt _col(`abbp3') "{c |}        Observations"
		di as txt _col(`abbp3') "{c |}      total   distinct"
		di as txt "{hline `abbp2'}{c +}{hline 22}"

		foreach v of local varlist {
        		tempvar touse vals
		        mark `touse' `if' `in'
        		// markout separately for each variable in varlist
		        if "`missing'" == "" markout `touse' `v', strok 
        		bys `touse' `v' : gen byte `vals' = (_n == 1) * `touse'
	        	su `vals' if `touse', meanonly
			if r(sum) >= `minimum' & r(sum) <= `maximum' { 
				di " " as txt %`abbrev's abbrev("`v'", `abbrev') ///
				" {c |}  " as res %9.0g r(N) "  " %9.0g r(sum)
			} 
	        	drop `touse' `vals'
		} 
	}

	return scalar N = r(N)
	return scalar ndistinct = r(sum)
end
