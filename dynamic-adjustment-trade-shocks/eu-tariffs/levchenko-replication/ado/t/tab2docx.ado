*! version 1.0.1  17may2018
*! version 1.0.2  20jun2018
*! version 1.0.3  28aug2019

* version 1.0.1 : Initial release
* version 1.0.2 : Added summarize option support
* version 1.0.3 : Added compound quotes for filename and value labels. Added -marksample touse-


program tab2docx
	version 15.0
	
	syntax varname [if] [in] [fweight aweight iweight], 		///
		[filename(string) missing summarize(varname)]
		
	marksample touse, novarlist

	if "`weight'" != "" & "`exp'" != "" {
		local weight "[`weight'`exp']"
	}
	if ("`filename'" != "") {
		fileparse `filename'
		local name "`s(name)'"
		local replace "`s(replace)'"
	}
	local vl : variable label `varlist'
	if `"`vl'"' != "" {
		local varlabel = `"`vl'"'
	}
	else {
		local varlabel = "`varlist'"
	}
	if "`replace'" == "" {
		local replace = "append"
	}
	
	* Branch if user is tabulating a string variable
	capture confirm string variable `varlist'
	if "`summarize'" != "" {
		capture confirm string variable `summarize'
		if !_rc {
			* Throw error, can't summarize a string.
			di as error "Cannot summarize a string variable"
			exit 109
		}
		doSumTab "`varlist'" "`touse'" "`weight'" "`missing'" "`filename'" "`varlabel'" "`summarize'"
	}
	else if !_rc {
		* Call to string tabulate subprogram
		doStrTab "`varlist'" "`touse'" "`weight'" "`missing'" "`filename'" "`varlabel'"
	}
	else {
		* Call to numeric tabulate subprogram
		doNumTab "`varlist'" "`touse'" "`weight'" "`missing'" "`filename'" "`varlabel'" "`vl'"
	}
	local rc = `r(rc)'
	local r2 = `r(r2)'
	
	* Formatting
	formatTab `r2' `summarize'
	
	* If filename is specified, save and close the file. Else rely on the user manually saving when ready.
	if "`filename'" != "" {
		putdocx save "`name'", `replace'
	}
	
	if `rc' != 0 {
		exit `rc'
	}
end

program define fileparse, sclass
	syntax anything[, replace]
	sreturn local name = "`anything'"
	sreturn local replace = "`replace'"
end

program define formatTab
	args r2 sum
	forvalues i = 1/`r2' {
		forvalues j = 1/4 {
			if `i' == 1 {
				if "`sum'" != "" {
					putdocx table t1(`i', `j'), bold halign(center) border(bottom, thick)
				}
				else {
					putdocx table t1(`i', `j'), bold halign(right) border(bottom, thick)
				}
			}
			else if `i' == `r2' {
				if `j' < 4 {
					putdocx table t1(`i', `j'), bold halign(right) border(top, thick)
				}
				else {
					if "`sum'" != "" {
						* summarize is used, format differently
						putdocx table t1(`i', `j'), bold halign(right) border(top, thick)
					}
					else {
						putdocx table t1(`i', `j'), border(top, thick)
					}
				}
			}
			else {
				if "`sum'" != "" & `i' == 2 {
					putdocx table t1(`i', `j'), bold halign(right) border(bottom, thick)
				}
				putdocx table t1(`i', `j'), halign(right)
			}
			if `j' == 1 {
				putdocx table t1(`i', `j'), border(right, thick)
			}
		}
	}
end

program define doStrTab, rclass
	* Do string tab
	args varlist touse weight missing filename varlabel
	capture noisily {
		preserve
		if "`missing'" == "" {
			drop if `varlist' == ""
		}
		gen freq = 1
		local total = _N
		collapse (count) freq if `touse' `weight', by(`varlist')
		local rows = _N
		local r2 = `rows'+2
		
		* If filename is specified, open the file. Else rely on the file being open already.
		if "`filename'" != "" {
			putdocx begin
		}
		
		putdocx table t1 = (`r2', 4)
		sort `varlist'
		
		* Header
		putdocx table t1(1, 1) = (`"`varlabel'"')
		putdocx table t1(1, 2) = ("Frequency")
		putdocx table t1(1, 3) = ("Percentage (%)")
		putdocx table t1(1, 4) = ("Cum. (%)")
		
		gen freqsum = sum(freq)
		gen percent = freq/freqsum[`rows']*100
		gen cumulativePercent = sum(percent)
		
		* Body
		forvalues i = 1/`rows' {
			local i1 = `i' + 1
			putdocx table t1(`i1', 1) = (`varlist'[`i'])
			local x : display %10.0g freq[`i']
			putdocx table t1(`i1', 2) = (`x')
			local x : display %10.2f percent[`i']
			putdocx table t1(`i1', 3) = (`x')
			local x : display %10.2f cumulativePercent[`i']
			putdocx table t1(`i1', 4) = (`x')
		}
		
		* Footer
		putdocx table t1(`r2', 1) = ("Total:")
		putdocx table t1(`r2', 2) = (freqsum[`rows'])
		putdocx table t1(`r2', 3) = (100)
		drop freqsum
		return local rc = _rc
		return local r2 = `r2'
	}
end

program define doNumTab, rclass
	* Do normal, numeric tab (Utilizes matrices, while strings cannot)
	args varlist touse weight missing filename varlabel vl
	qui tab `varlist' if `touse' `weight', matcell(tmpfreq) matrow(tmpnames) `missing'
	
	local total = r(N)
	local rows = r(r)
	local r1 = `rows'+1
	local r2 = `rows'+2
	
	if `r1' >= 10 & `r1' <= 11000 {
		set matsize `r1'
	}
	
	tempname nMat
	tempname fMat
	tempname pMat
	tempname cMat
	tempname tmpPer
	tempvar tmpCum
	
	matrix `nMat' = tmpnames
	matrix `fMat' = tmpfreq
	matrix `pMat' = `fMat'/`total'*100
	svmat `pMat', names(`tmpPer')
	gen `tmpCum' = sum(`tmpPer')
	matrix `cMat' = `tmpCum'[1]
	forvalues i = 2/`rows' {
		matrix `cMat' = `cMat' \ `tmpCum'[`i']
	}
	
	capture {
		drop `tmpPer'
		drop `tmpCum'
		drop tmpnames
		drop tmpfreq
	}
	
	* If filename is specified, open the file. Else rely on the file being open already.
	if "`filename'" != "" {
		putdocx begin
	}
	capture noisily {
	
		* Insert each item individually to format the text as we go
		putdocx table t1 = (`r2', 4)
		forvalues i = 1/`r2' {
			forvalues j = 1/4 {
				local i1 = `i'-1
				local i2 = `i'-2
				if `i' == 1 {
					if `j' == 1 {
						putdocx table t1(`i', `j') = (`"`varlabel'"')
					}
					else if `j' == 2 {
						putdocx table t1(`i', `j') = ("Frequency")
					}
					else if `j' == 3 {
						putdocx table t1(`i', `j') = ("Percentage (%)")
					}
					else {
						putdocx table t1(`i', `j') = ("Cum. (%)")
					}
				}
				else if `i' == `r2' {
					if `j' == 1 {
						putdocx table t1(`i', `j') = ("Total:")
					}
					else if `j' == 2 {
						putdocx table t1(`i', `j') = (`total')
					}
					else if `j' == 3 {
						putdocx table t1(`i', `j') = (100)
					}
				}
				else {
					if `j' == 1 {
						local tmp = `nMat'[`i1', 1]
						local vl : label (`varlist') `tmp'
						putdocx table t1(`i', `j') = (`"`vl'"')
					}
					else if `j' == 2 {
						local x : display %10.0g `fMat'[`i1', 1]
						putdocx table t1(`i', `j') = ("`x'")					
					}
					else if `j' == 3 {
						local x : display %10.2f `pMat'[`i1', 1]
						putdocx table t1(`i', `j') = ("`x'")
					}
					else {
						local x : display %10.2f `cMat'[`i1', 1]
						putdocx table t1(`i', `j') = ("`x'")
					}
				}
			}
		}
	return local r2 = `r2'
	return local rc = _rc
	}
end

program define doSumTab, rclass
	args varlist touse weight missing filename varlabel summarize
	preserve
	capture noisily {
		local cols = 4
		local firstVarLabel : var label `varlist'
		local firstVarValueLabel : value label `varlist'
			
		if "`firstVarLabel'" != "" {
			local col1_header = `"`firstVarLabel'"'
		}
		else {
			local col1_header = "`firstVar'"
		}
		
		local sumLabel : var label `summarize'
		if `"`sumLabel'"' == "" {
			local sumLabel = `summarize'
		}
		
		if "`missing'" != "" {
			di "    The {cmd:summarize} option removes missing values. Using this option will not change the result."
		}
		
		* Drop all missing values in all vars
		capture drop if `varlist' >= .
		capture drop if `varlist' == ""
		capture drop if `summarize' >= .
		capture drop if `summarize' == ""
		
		qui sum `summarize' if `touse' `weight'
		
		local mean = `r(mean)'
		local sd = `r(sd)'
		local total = `r(N)'
		
		if "`summarize'" == "`varlist'" {
			gen tmp_var_sum = `summarize'
			collapse (count) c=tmp_var_sum (sd) s=tmp_var_sum (mean) m=tmp_var_sum if `touse' `weight', by(`varlist')
		}
		else {
			collapse (count) c=`summarize' (sd) s=`summarize' (mean) m=`summarize' if `touse' `weight', by(`varlist')
		}
		
		local rows = _N
		local r3 = `rows'+3
		
		* If filename is specified, open the file. Else rely on the file being open already.
		if "`filename'" != "" {
			putdocx begin
		}
			
		putdocx table t1 = (`r3', 4)
		sort `varlist'
		
		* Header
		putdocx table t1(1, 2) = (`"Summary of `sumLabel'"')
		putdocx table t1(1, 2), colspan(3)
		
		putdocx table t1(2, 1) = (`"`varlabel'"')
		putdocx table t1(2, 2) = ("Mean")
		putdocx table t1(2, 3) = ("Std. Dev.")
		putdocx table t1(2, 4) = ("Freq.")

		qui replace s = 0 if s == .
		qui replace m = 0 if m == .
		
		* Body
		forvalues i = 1/`rows' {
			local i2 = `i' + 2
			if `"`firstVarValueLabel'"' != "" {
				local vl : label (`varlist') `i'
				putdocx table t1(`i2', 1) = (`"`vl'"')
			}
			else {
				putdocx table t1(`i2', 1) = (`varlist'[`i'])
			}
			local x : display %8.0g m[`i']
			putdocx table t1(`i2', 2) = (`x')
			local x : display %8.0g s[`i']
			putdocx table t1(`i2', 3) = (`x')
			local x : display %8.0g c[`i']
			putdocx table t1(`i2', 4) = (`x')
		}

		* Footer
		putdocx table t1(`r3', 1) = ("Total:")
		putdocx table t1(`r3', 2) = (`mean')
		putdocx table t1(`r3', 3) = (`sd')
		putdocx table t1(`r3', 4) = (`total')
		
		return local r2 = `r3'
	}
	return local rc = _rc
end
