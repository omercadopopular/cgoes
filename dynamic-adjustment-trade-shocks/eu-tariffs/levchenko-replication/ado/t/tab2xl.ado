*! version 1.0.1  12dec2013
*! version 1.0.2  16may2018
*! version 1.0.3  20jun2018
*! version 1.0.4  12jul2018
*! version 1.0.5  28aug2019
* updated command so that it always retains a cells format when writing data
* row, col = start row/col
* rows, cols = number of rows/cols
* 1.0.3 : Added one/two way string tabulates, one/two way summarize tabulates, updated version number to reflect the open option being released in 15.1
* 1.0.4 : Added the percentage option to emulate both (row/col) options from two-way tabulate, various minor bug fixes
* 1.0.5 : fixed compound quotes around sheet name, file name, and variable value labels. Also added -marksample- instead of dealing with 'if' and 'in'.
program tab2xl

	version 15.1
	syntax varlist(min=1 max=2) using/ [if] [in] [fweight aweight iweight], row(integer) col(integer) [replace sheet(string) missing summarize(varname numeric) PERCentage]
	
	marksample touse, novarlist
		
	if ("`sheet'" != "") {
		sheetparse `sheet'
		local sheetName `s(name)'
		local sheetReplace `s(replace)'
		if ("`sheetReplace'" != "") {
			local sheet "sheet(`sheetName', replace)"
		}
		else {
			local sheet "sheet(`sheetName')"
		}
	}
	
	if `c(stata_version)' < 14 {
		local keepCellFormat "keepcellformat"
	}

	if "`replace'" == "" {
		local replace = "modify"
	}
	
	if "`weight'" != "" & "`exp'" != "" {
		local weight "[`weight'`exp']"
	}

	if wordcount("`varlist'") == 1 {
	
		if "`percentage'" != "" {
			if wordcount("`varlist'") == 1 {
				* Throw error, can't use these options on a one-way tab.
				di as error "option percentage not allowed with one-way tab"
				error 198
			}
		}
	
		capture confirm string variable `varlist'
		if "`summarize'" != "" {
			doOneWaySum "`varlist'" "`touse'" "`weight'" "`keepCellFormat'" "`missing'" "`using'" "`sheet'" "`replace'" "`row'" "`col'" "`summarize'"
		}
		else if !_rc {
			doOneWayString "`varlist'" "`touse'" "`weight'" "`keepCellFormat'" "`missing'" "`using'" "`sheet'" "`replace'" "`row'" "`col'" "`summarize'"
		}
		else {
			doOneWayNumeric "`varlist'" "`touse'" "`weight'" "`keepCellFormat'" "`missing'" "`using'" "`sheet'" "`replace'" "`row'" "`col'" "`summarize'"
		}
	}
	else {
		* Throw error if one or more variables is a string (Done this way to allow for a descriptive message before the return code)
		capture confirm numeric variable `varlist'
		if "`summarize'" != "" {
			if "`percentage'" != "" {
				* Throw error, can't use these options on summarize option.
				di as error "option percentage not allowed in conjunction with the summarize option"
				error 198
			}
			doTwoWaySum "`varlist'" "`touse'" "`weight'" "`keepCellFormat'" "`missing'" "`using'" "`sheet'" "`replace'" "`row'" "`col'" "`summarize'"
		}
		else if "`percentage'" != "" {
			if "`weight'" != "" {
				* Throw error, can't use weights with percentage option.
				di as error "option percentage does not allow weights"
				error 198
			}
			doTwoWayPercentage "`varlist'" "`touse'" "`keepCellFormat'" "`missing'" "`using'" "`sheet'" "`replace'" "`row'" "`col'" "`percentage'"
		}
		else if _rc {
			doTwoWayString "`varlist'" "`touse'" "`weight'" "`keepCellFormat'" "`missing'" "`using'" "`sheet'" "`replace'" "`row'" "`col'" "`summarize'"
		}
		else {
			doTwoWayNumeric "`varlist'" "`touse'" "`weight'" "`keepCellFormat'" "`missing'" "`using'" "`sheet'" "`replace'" "`row'" "`col'" "`summarize'"
		}
	}
end

program num2base26, rclass
	args num

	mata: my_col = strtoreal(st_local("num"))
	mata: col = numtobase26(my_col)
	mata: st_local("col_let", col)
	return local col_letter = "`col_let'"
end

program define sheetparse, sclass
	syntax anything[, replace]
	sreturn local name = "`anything'"
	sreturn local replace = "`replace'"
end

program define formatSummarizeCells
	args col cols row rows firstVarValueLabel secondVarValueLabel firstVar secondVar twoWay
	
	if "`twoWay'" != "" {
		* Two way
		local rightCol = `cols' + `col' - 1
		num2base26 `rightCol'
		local rightColLetter = "`r(col_letter)'"
		local rightColSubOne = `rightCol'-1
		num2base26 `rightColSubOne'
		local rightColSubOneLetter = "`r(col_letter)'"
		local leftCol = `col'
		num2base26 `leftCol'
		local leftColLetter = "`r(col_letter)'"
		local lastRow = `rows' + `row' - 1
		
		qui levelsof(`firstVar')
		local firstVarList = `"`r(levels)'"'
		
		qui levelsof(`secondVar')
		local secondVarList = `"`r(levels)'"'
		
		qui putexcel `leftColLetter'`row':`leftColLetter'`lastRow', border(right, thick)
		qui putexcel `rightColLetter'`row':`rightColLetter'`lastRow', bold border(left, thick)
		
		local rowCopy = `row'
		local row = `row' + 1
		local tmp = `lastRow' - 2
		
		qui putexcel `leftColLetter'`row':`rightColLetter'`row', bold border(bottom, thick)
		qui putexcel `leftColLetter'`tmp':`rightColLetter'`lastRow', bold
		qui putexcel `leftColLetter'`row':`leftColLetter'`lastRow', bold
		qui putexcel `leftColLetter'`tmp':`rightColLetter'`tmp', border(top, thick)
		qui putexcel `leftColLetter'`row':`rightColLetter'`lastRow', right
		
		local row = `row' + 1
		
		foreach i of local firstVarList {
			qui putexcel `leftColLetter'`row':`rightColLetter'`row', border(top, thick)
			local row = `row' + 3
		}
		local row = `rowCopy' + 2
		local tmp = `rows' - 6 + `row'
		
		local bold "bold"	
		if "`firstVarValueLabel'" == "" {
			local bold = "no`bold'"
		}
		qui putexcel `leftColLetter'`row':`leftColLetter'`tmp', `bold'

		local row = `row' - 1
		local tmp = `col' + 1
		num2base26 `tmp'
		local tmp = "`r(col_letter)'"
		local bold "bold"	
		if "`secondVarValueLabel'" == "" {
			local bold = "no`bold'"
		}
		qui putexcel `tmp'`row':`rightColSubOneLetter'`row', `bold'
	}
	else {
		local rightCol = `cols' + `col' - 1
		num2base26 `rightCol'
		local rightColLetter = "`r(col_letter)'"
		local rightColSubOne = `rightCol'-1
		num2base26 `rightColSubOne'
		local rightColSubOneLetter = "`r(col_letter)'"
		local leftCol = `col'
		num2base26 `leftCol'
		local leftColLetter = "`r(col_letter)'"
		
		local lastRow = `rows'+`row'+2
		qui putexcel `leftColLetter'`row':`rightColLetter'`row', hcenter bold
		
		local r1 = `row' + 1
		qui putexcel `leftColLetter'`row':`rightColLetter'`lastRow', right
		qui putexcel `leftColLetter'`r1':`rightColLetter'`r1', bold border(bottom, thick)
		qui putexcel `leftColLetter'`r1':`leftColLetter'`lastRow', bold border(right, thick)
		qui putexcel `leftColLetter'`lastRow':`rightColLetter'`lastRow', bold border(top, thick)
		qui putexcel `rightColLetter'`r1':`rightColLetter'`lastRow', nformat(number)
	}
end

program define formatCells
	args col cols row rows firstVarValueLabel secondVarValueLabel twoWay
	local rightCol = `cols' + `col' - 1
	num2base26 `rightCol'
	local rightColLetter = "`r(col_letter)'"
	local rightColSubOne = `rightCol'-1
	num2base26 `rightColSubOne'
	local rightColSubOneLetter = "`r(col_letter)'"
	local leftCol = `col'
	num2base26 `leftCol'
	local leftColLetter = "`r(col_letter)'"
	
	local lastRow = `rows'+`row'+1
	if "`twoWay'" == "" {
		qui putexcel `leftColLetter'`row':`rightColLetter'`lastRow', right
		qui putexcel `leftColLetter'`row':`rightColLetter'`row', bold border(bottom, thick)
		qui putexcel `leftColLetter'`row':`leftColLetter'`lastRow', bold border(right, thick)
		qui putexcel `leftColLetter'`lastRow':`rightColLetter'`lastRow', bold border(top, thick)
		qui putexcel `rightColSubOneLetter'`row':`rightColLetter'`lastRow', nformat(number_d2)
	}
	else {
		qui putexcel `leftColLetter'`row':`rightColLetter'`lastRow', right
		qui putexcel `leftColLetter'`row':`rightColLetter'`row', bold border(bottom, thick)
		qui putexcel `leftColLetter'`row':`leftColLetter'`lastRow', bold border(right, thick)
		qui putexcel `leftColLetter'`lastRow':`rightColLetter'`lastRow', bold border(top, thick)
		qui putexcel `rightColLetter'`row':`rightColLetter'`lastRow', bold border(left, thick)
		
		local tmp = `row' + 1
		local tmp2 = `lastRow' - 1
		local tmp3 = `leftCol' + 1
		num2base26 `tmp3'
		local tmp3 = "`r(col_letter)'"
		
		local bold "bold"	
		if "`firstVarValueLabel'" == "" {
			local bold = "no`bold'"
		}
		qui putexcel `leftColLetter'`tmp':`leftColLetter'`tmp2', `bold'

		local bold "bold"	
		if "`secondVarValueLabel'" == "" {
			local bold = "no`bold'"
		}
		qui putexcel `tmp3'`row':`rightColSubOneLetter'`row', `bold'
	}
end

program doOneWayNumeric
	args varlist touse weight keepCellFormat missing using sheet replace row col summarize
	qui tabulate `varlist' if `touse' `weight', matcell(freq) matrow(rowMat) `keepCellFormat' `missing'
	local cols = 4
	local firstVar = word("`varlist'", 1)
	local firstVarLabel : var label `firstVar'
	local firstVarValueLabel : value label `firstVar'
	
	local total = r(N)
	
	if `"`firstVarLabel'"' != "" {
		local col1_header = `"`firstVarLabel'"'
	}
	else {
		local col1_header = "`firstVar'"
	}

	qui putexcel set "`using'", `sheet' `replace' `keepCellFormat' open
	local colCopy = `col'
	
	* Use hardcoded 4-column tabulate header
	local col1 = `col'
	local col2 = `col' + 1
	local col3 = `col' + 2
	local col4 = `col' + 3
	num2base26 `col'
	local col1_letter "`r(col_letter)'"
	num2base26 `col2'
	local col2_letter "`r(col_letter)'"
	num2base26 `col3'
	local col3_letter "`r(col_letter)'"
	num2base26 `col4'
	local col4_letter "`r(col_letter)'"
	
	qui putexcel	`col1_letter'`row'=(`"`col1_header'"')		///
			`col2_letter'`row'=("Freq.")			///
			`col3_letter'`row'=("Percent")			///
			`col4_letter'`row'=("Cum.")
			
	local col = `colCopy'

	local rows = rowsof(rowMat)
	
	* Call to formatting program
	formatCells "`col'" "`cols'" "`row'" "`rows'" `"`firstVarValueLabel'"' `"`secondVarValueLabel'"' "`twoWay'"

	local row = `row' + 1
	local cum_percent = 0
	local t = 0
	
	* Fill in main portion of the cells
	forvalues i = 1/`rows' {
		local val = rowMat[`i',1]
		local vl : label (`firstVar') `val'
		if `"`firstVarValueLabel'"' == "" {
			local vl : display %9.0g `vl'
		}

		local freq_val = freq[`i',1]

		local percent_val = `freq_val'/`total'*100
		local percent_val : display %9.2f `percent_val'

		local cum_percent : display %9.2f (`cum_percent' + `percent_val')

		qui putexcel `col1_letter'`row'=(`"`vl'"')		///
				`col2_letter'`row'=(`freq_val')		///
				`col3_letter'`row'=(`percent_val')	///
				`col4_letter'`row'=(`cum_percent')
				
		sleep 10
		local row = `row' + 1
		local col = `colCopy'
		local t = 0	
	}
	sleep 10

	qui putexcel `col1_letter'`row'=("Total")		///
			`col2_letter'`row'=(`total') 		///
			`col3_letter'`row'=(100.00)
	putexcel close
end

program doTwoWayNumeric
	args varlist touse weight keepCellFormat missing using sheet replace row col summarize
	qui tabulate `varlist' if `touse' `weight', matcell(freq) matrow(rowMat) matcol(colMat) `keepCellFormat' `missing'
	local twoWay = colsof(colMat)
	local cols = `twoWay'+2
	local firstVar = word("`varlist'", 1)
	local firstVarLabel : var label `firstVar'
	local firstVarValueLabel : value label `firstVar'
	local secondVar = word("`varlist'", 2)
	local secondVarLabel : var label `secondVar'
	local secondVarValueLabel : value label `secondVar'
	
	local total = r(N)
	
	if `"`firstVarLabel'"' != "" {
		local col1_header = `"`firstVarLabel'"'
	}
	else {
		local col1_header = "`firstVar'"
	}

	qui putexcel set "`using'", `sheet' `replace' `keepCellFormat' open
	local colCopy = `col'
	
	* Fill in the first row / header
	* Two-way tabulate header format
	if `"`secondVarLabel'"' != "" {
		local midCol = ((`twoWay'+1)/2)
		local tmp = ceil(`midCol')
		local tmp = `col' + `tmp'
		local midCol = `col' + `midCol'
		num2base26 `tmp'
		local tmp = "`r(col_letter)'"
		num2base26 `midCol'
		local midCol = "`r(col_letter)'"
		if "`midCol'" == "`tmp'" {
			* Column number was odd, just do the header in the middle.
			qui putexcel `midCol'`row'=(`"`secondVarLabel'"')
			qui putexcel `midCol'`row':`midCol'`row', shrink hcenter bold
		}
		else {
			* Column number was even, put header in ciel and ciel - 1
			qui putexcel `midCol'`row'=(`"`secondVarLabel'"')
			qui putexcel `midCol'`row':`tmp'`row', merge shrink hcenter bold
		}
		local row = `row' + 1
	}
	forvalues i = 1/`cols' {
		local i1 = `i'-1
		local i2 = `i'-2
		if `i' == 1 {
			num2base26 `col'
			local colLetter "`r(col_letter)'"
			qui putexcel `colLetter'`row'=(`"`col1_header'"')
		}
		else if `i' > 1 & `i' < `cols' {
			* Check for string labels, otherwise use the numeric data
			local tmp = `col'+`i1'
			num2base26 `tmp'
			local colLetter "`r(col_letter)'"
			local val = colMat[1, `i1']
			local vl : label (`secondVar') `val'
			if `"`secondVarValueLabel'"' == "" {
				qui putexcel `colLetter'`row'=(`vl')
			}
			else {
				qui putexcel `colLetter'`row'=(`"`vl'"')
			}
		}
		else {
			local col = `col'+`cols'-1
			num2base26 `col'
			local colLetter "`r(col_letter)'"
			qui putexcel `colLetter'`row'=("Total")
		}
	}

	local col = `colCopy'

	local rows = rowsof(rowMat)
	
	* Call to formatting program
	formatCells "`col'" "`cols'" "`row'" "`rows'" `"`firstVarValueLabel'"' `"`secondVarValueLabel'"' "`twoWay'"
	
	local row = `row' + 1
	local cum_percent = 0
	local t = 0

	* Fill in main portion of the cells
	forvalues i = 1/`rows' {
		forvalues j = 1/`cols' {
			num2base26 `col'
			local colLetter = "`r(col_letter)'"
			if `j' == 1 {
				* Use rowMat's values
				local val = rowMat[`i', `j']
				local vl : label (`firstVar') `val'
				if `"`firstVarValueLabel'"' == "" {
					qui putexcel `colLetter'`row'=(`vl')
				}
				else {
					qui putexcel `colLetter'`row'=(`"`vl'"')
				}
			}
			else if `j' > 1 & `j' < `cols' {
				* Use freq's values
				local tmp = `j' - 1
				qui putexcel `colLetter'`row'=(freq[`i', `tmp'])
				local t = `t' + freq[`i', `tmp']
			}
			else {
				* Use the value of `total'
				qui putexcel `colLetter'`row'=(`t')
			}
			local col = `col' + 1
		}		
		sleep 10
		local row = `row' + 1
		local col = `colCopy'
		local t = 0
	}
		
	sleep 10

	* Fill in the last row / footer
	forvalues j = 1/`cols' {
		num2base26 `col'
		local colLetter = "`r(col_letter)'"
		if `j' == 1 {
			qui putexcel `colLetter'`row'=("Total")
		}
		else if `j' > 1 & `j' < `cols' {
			local tmp = `j' - 1
			local t = 0
			forvalues i = 1/`rows' {
				local t = `t' + freq[`i', `tmp']
			}
			qui putexcel `colLetter'`row'=(`t')
		}
		else {
			qui putexcel `colLetter'`row'=(`total')
		}
		local col = `col' + 1
	}
	putexcel close
end

program doOneWayString
	args varlist touse weight keepCellFormat missing using sheet replace row col summarize
	capture noisily {
		preserve
		
		local cols = 4
		local firstVarLabel : var label `varlist'
		local firstVarValueLabel : value label `varlist'
			
		if `"`firstVarLabel'"' != "" {
			local col1_header = `"`firstVarLabel'"'
		}
		else {
			local col1_header = "`firstVar'"
		}
		
		if "`missing'" == "" {
			drop if `varlist' == ""
		}
		gen freq = 1
		local total = _N
		collapse (count) freq if `touse' `weight', by(`varlist')
		local rows = _N
		local r2 = `rows'+2
		
		qui putexcel set "`using'", `sheet' `replace' `keepCellFormat' open
		formatCells "`col'" "`cols'" "`row'" "`rows'" `"`firstVarValueLabel'"' `"`secondVarValueLabel'"' "`twoWay'"
		
		sort `varlist'
		
		* Use hardcoded 4-column tabulate header
		local col1 = `col'
		local col2 = `col' + 1
		local col3 = `col' + 2
		local col4 = `col' + 3
		num2base26 `col'
		local col1_letter "`r(col_letter)'"
		num2base26 `col2'
		local col2_letter "`r(col_letter)'"
		num2base26 `col3'
		local col3_letter "`r(col_letter)'"
		num2base26 `col4'
		local col4_letter "`r(col_letter)'"
		
		qui putexcel	`col1_letter'`row'=(`"`col1_header'"')		///
				`col2_letter'`row'=("Freq.")			///
				`col3_letter'`row'=("Percent")			///
				`col4_letter'`row'=("Cum.")
		
		gen freqsum = sum(freq)
		gen percent = freq/freqsum[`rows']*100
		gen cumulativePercent = sum(percent)
		
		* Body
		forvalues i = 1/`rows' {
			local i1 = `row' + `i'
			putexcel `col1_letter'`i1'=(`varlist'[`i'])
			local x : display %10.0g freq[`i']
			putexcel `col2_letter'`i1'=(`x')
			local x : display %10.2f percent[`i']
			putexcel `col3_letter'`i1'=(`x')
			local x : display %10.2f cumulativePercent[`i']
			putexcel `col4_letter'`i1'=(`x')
		}
		
		* Footer
		local lastRow = `row' + `rows' + 1
		putexcel `col1_letter'`lastRow'=("Total")
		putexcel `col2_letter'`lastRow'=(freqsum[`rows'])
		putexcel `col3_letter'`lastRow'=(100)
		drop freqsum
		
		putexcel close
	}
end

program define doOneWaySum
	args varlist touse weight keepCellFormat missing using sheet replace row col summarize
	preserve
	local cols = 4
	local firstVarLabel : var label `varlist'
	local firstVarValueLabel : value label `varlist'
	local sumLabel : var label `summarize'
		
	if "`firstVarLabel'" != "" {
		local col1_header = `"`firstVarLabel'"'
	}
	else {
		local col1_header = "`firstVar'"
	}
	if "`sumLabel'" == "" {
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
	local r2 = `rows'+3
	
	qui putexcel set "`using'", `sheet' `replace' `keepCellFormat' open
	formatSummarizeCells "`col'" "`cols'" "`row'" "`rows'" `"`firstVarValueLabel'"' `"`secondVarValueLabel'"' "`varlist'" "" ""
	
	sort `varlist'
	
	* Use hardcoded 4-column tabulate header
	local col1 = `col'
	local col2 = `col' + 1
	local col3 = `col' + 2
	local col4 = `col' + 3
	num2base26 `col'
	local col1_letter "`r(col_letter)'"
	num2base26 `col2'
	local col2_letter "`r(col_letter)'"
	num2base26 `col3'
	local col3_letter "`r(col_letter)'"
	num2base26 `col4'
	local col4_letter "`r(col_letter)'"
	
	qui putexcel `col2_letter'`row':`col4_letter'`row', merge hcenter
	qui putexcel `col2_letter'`row'=("Summary of `sumLabel'")
	
	local row = `row' + 1
	
	qui putexcel	`col1_letter'`row'=(`"`col1_header'"')		///
			`col2_letter'`row'=("Mean")			///
			`col3_letter'`row'=("Std. Dev.")		///
			`col4_letter'`row'=("Freq.")

	* Body
	qui replace s = 0 if s == .
	qui replace m = 0 if m == .
	forvalues i = 1/`rows' {
		local i1 = `row' + `i'
		if `"`firstVarValueLabel'"' != "" {
			local vl : label (`varlist') `i'
			qui putexcel `col1_letter'`i1'=(`"`vl'"')
		}
		else {
			qui putexcel `col1_letter'`i1'=(`varlist'[`i'])
		}
		local x : display %8.0g m[`i']
		qui putexcel `col2_letter'`i1'=(`x')
		local x : display %8.0g s[`i']
		qui putexcel `col3_letter'`i1'=(`x')
		local x : display %8.0g c[`i']
		qui putexcel `col4_letter'`i1'=(`x')
	}
	
	* Footer
	local lastRow = `row' + `rows' + 1
	qui putexcel `col1_letter'`lastRow'=("Total")
	qui putexcel `col2_letter'`lastRow'=(`mean')
	qui putexcel `col3_letter'`lastRow'=(`sd')
	qui putexcel `col4_letter'`lastRow'=(`total')
	
	putexcel close
	restore
end

program define doTwoWaySum
	args varlist touse weight keepCellFormat missing using sheet replace row col summarize
	preserve

	local firstVar = word("`varlist'", 1)
	local firstVarLabel : var label `firstVar'
	local firstVarValueLabel : value label `firstVar'
	local secondVar = word("`varlist'", 2)
	local secondVarLabel : var label `secondVar'
	local secondVarValueLabel : value label `secondVar'
	capture confirm string variable `firstVar'
	if !_rc {
		local v1Type "str"
	}
	capture confirm string variable `secondVar'
	if !_rc {
		local v2Type "str"
	}
	
	capture keep if `touse'
	
	* Drop all missing values in all vars
	capture drop if `firstVar' >= .
	capture drop if `firstVar' == ""
	capture drop if `secondVar' >= .
	capture drop if `secondVar' == ""
	capture drop if `summarize' >= .
	capture drop if `summarize' == ""
	
	qui levelsof(`firstVar')
	local firstVarList = `"`r(levels)'"'
	local rows = 3*(`r(r)'+1) + 2
	
	qui levelsof(`secondVar')
	local secondVarList = `"`r(levels)'"'
	local cols = `r(r)' + 2
	local twoWay = `cols'
	
	if "`firstVarLabel'" != "" {
		local col1_header = `"`firstVarLabel'"'
	}
	else {
		local col1_header = "`firstVar'"
	}
	
	if "`missing'" != "" {
		di "    The {cmd:summarize} option removes missing values. Using this option will not change the result."
	}
	
	qui putexcel set "`using'", `sheet' `replace' `keepCellFormat' open
	local colCopy = `col'
	
	formatSummarizeCells "`col'" "`cols'" "`row'" "`rows'" `"`firstVarValueLabel'"' `"`secondVarValueLabel'"' "`firstVar'" "`secondVar'" "twoWay"


	
	* Display v2 label
	local midCol = ((`cols'-1)/2)
	local tmp = ceil(`midCol')
	local tmp = `col' + `tmp'
	local midCol = `col' + `midCol'
	num2base26 `tmp'
	local tmp = "`r(col_letter)'"
	num2base26 `midCol'
	local midCol = "`r(col_letter)'"
	if "`midCol'" == "`tmp'" {
		* Column number was odd, just do the header in the middle.
		qui putexcel `midCol'`row'=(`"`secondVarLabel'"')
		qui putexcel `midCol'`row':`midCol'`row', shrink hcenter bold
	}
	else {
		* Column number was even, put header in ciel and ciel - 1
		qui putexcel `midCol'`row'=(`"`secondVarLabel'"')
		qui putexcel `midCol'`row':`tmp'`row', merge shrink hcenter bold
	}
	local row = `row' + 1
	
	* Header
	num2base26 `col'
	local colLetter = "`r(col_letter)'"
	qui putexcel `colLetter'`row'=(`"`firstVarLabel'"')
	local col = `col' + 1
	num2base26 `col'
	local colLetter = "`r(col_letter)'"
	foreach i of local secondVarList {
		if `"`secondVarValueLabel'"' != "" {
			local vl : label (`secondVar') `i'
			qui putexcel `colLetter'`row'=(`"`vl'"')
		}
		else {
			if "`v2Type'" == "str" {
				qui putexcel `colLetter'`row'=("`i'")
			}
			else {
				qui putexcel `colLetter'`row'=(`i')
			}
		}
		local col = `col' + 1
		num2base26 `col'
		local colLetter = "`r(col_letter)'"
	}
	qui putexcel `colLetter'`row'=("Total")
	local row = `row' + 1
	local col = `colCopy'
	local colCopy = `col'
	num2base26 `col'
	local colLetter = "`r(col_letter)'"
	
	* Body
	foreach i of local firstVarList {
		if `"`firstVarValueLabel'"' != "" {
			local vl : label (`firstVar') `i'
			qui putexcel `colLetter'`row'=(`"`vl'"')
		}
		else {
			if "`v1Type'" == "str" {
				qui putexcel `colLetter'`row'=("`i'")
			}
			else {
				qui putexcel `colLetter'`row'=(`i')
			}
		}
		local col = `col' + 1
		num2base26 `col'
		local colLetter = "`r(col_letter)'"
		
		foreach j of local secondVarList {
			if "`v1Type'" == "str" {
				if "`v2Type'" == "str" {
					qui sum `summarize' if `firstVar' == "`i'" & `secondVar' == "`j'" `weight'
				}
				else {
					qui sum `summarize' if `firstVar' == "`i'" & `secondVar' == `j' `weight'
				}
			}
			else {
				if "`v2Type'" == "str" {
					qui sum `summarize' if `firstVar' == `i' & `secondVar' == "`j'" `weight'
				}
				else {
					qui sum `summarize' if `firstVar' == `i' & `secondVar' == `j' `weight'
				}
			}
			
			local count = 0
			capture local count = `r(N)'
			local sd = 0
			capture local sd = `r(sd)'
			local mean = 0
			capture local mean = `r(mean)'
			
			if "`mean'" == "." | "`mean'" == "" {
				local mean = 0
			}
			if "`sd'" == "." | "`sd'" == "" {
				local sd = 0
			}
			
			qui putexcel `colLetter'`row'=(`mean')
			local row = `row' + 1
			qui putexcel `colLetter'`row'=(`sd')
			local row = `row' + 1
			qui putexcel `colLetter'`row'=(`count')
			local row = `row' - 2
			local col = `col' + 1
			num2base26 `col'
			local colLetter = "`r(col_letter)'"
		}
		
		if "`v1Type'" == "str" {
			qui sum `summarize' if `firstVar' == "`i'" `weight'
		}
		else {
			qui sum `summarize' if `firstVar' == `i' `weight'
		}
		
		local count = 0
		capture local count = `r(N)'
		local sd = 0
		capture local sd = `r(sd)'
		local mean = 0
		capture local mean = `r(mean)'
		
		if "`mean'" == "." | "`mean'" == "" {
			local mean = 0
		}
		if "`sd'" == "." | "`sd'" == "" {
			local sd = 0
		}
		
		qui putexcel `colLetter'`row'=(`mean')
		local row = `row' + 1
		qui putexcel `colLetter'`row'=(`sd')
		local row = `row' + 1
		qui putexcel `colLetter'`row'=(`count')
		local row = `row' + 1
		local col = `colCopy'
		num2base26 `col'
		local colLetter = "`r(col_letter)'"
	}
	
	* Footer
	qui putexcel `colLetter'`row'=("Total")
	local col = `col' + 1
	num2base26 `col'
	local colLetter = "`r(col_letter)'"
	
	foreach i of local secondVarList {
		if "`v2Type'" == "str" {
			qui sum `summarize' if `secondVar' == "`i'" `weight'
		}
		else {
			qui sum `summarize' if `secondVar' == `i' `weight'
		}
		
		local count = 0
		capture local count = `r(N)'
		local sd = 0
		capture local sd = `r(sd)'
		local mean = 0
		capture local mean = `r(mean)'
		
		if "`mean'" == "." | "`mean'" == "" {
			local mean = 0
		}
		if "`sd'" == "." | "`sd'" == "" {
			local sd = 0
		}
		
		qui putexcel `colLetter'`row'=(`mean')
		local row = `row' + 1
		qui putexcel `colLetter'`row'=(`sd')
		local row = `row' + 1
		qui putexcel `colLetter'`row'=(`count')
		local row = `row' - 2
		local col = `col' + 1
		num2base26 `col'
		local colLetter = "`r(col_letter)'"
	}
	
	qui sum `summarize' `weight'
	
	local count = 0
	capture local count = `r(N)'
	local sd = 0
	capture local sd = `r(sd)'
	local mean = 0
	capture local mean = `r(mean)'

	qui putexcel `colLetter'`row'=(`mean')
	local row = `row' + 1
	qui putexcel `colLetter'`row'=(`sd')
	local row = `row' + 1
	qui putexcel `colLetter'`row'=(`count')
		
	putexcel close
	restore
end

program define doTwoWayString
	* Basically the same code at doTwoWaySum, but I separated it purely to not
	* have to branch formatting in either subprograms
	args varlist touse weight keepCellFormat missing using sheet replace row col summarize
	preserve

	local firstVar = word("`varlist'", 1)
	local firstVarLabel : var label `firstVar'
	local firstVarValueLabel : value label `firstVar'
	local secondVar = word("`varlist'", 2)
	local secondVarLabel : var label `secondVar'
	local secondVarValueLabel : value label `secondVar'
	capture confirm string variable `firstVar'
	if !_rc {
		local v1Type "str"
	}
	capture confirm string variable `secondVar'
	if !_rc {
		local v2Type "str"
	}
	
	capture keep if `touse'
	
	qui levelsof(`firstVar')
	local firstVarList = `"`r(levels)'"'
	local rows = `r(r)' + 3
	
	qui levelsof(`secondVar')
	local secondVarList = `"`r(levels)'"'
	local cols = `r(r)' + 2
	local twoWay = `cols'
	
	if `"`firstVarLabel'"' != "" {
		local col1_header = `"`firstVarLabel'"'
	}
	else {
		local col1_header = "`firstVar'"
	}
	
	* See what variables have missing values to add it to the excel file
	if "`missing'" != "" {
		if "`v1Type'" == "str" {
			qui count if `firstVar' == ""
			local ct = `r(N)'
			if `ct' > 0 {
				local rows = `rows' + 1
				local v1Missing = "missing"
			}
		}
		else {
			qui count if `firstVar' == .
			local ct = `r(N)'
			if `ct' > 0 {
				local rows = `rows' + 1
				local v1Missing = "missing"
			}
		}
		if "`v2Type'" == "str" {
			qui count if `secondVar' == ""
			local ct = `r(N)'
			if `ct' > 0 {
				local cols = `cols' + 1
				local v2Missing = "missing"
			}
		}
		else {
			qui count if `secondVar' == .
			local ct = `r(N)'
			if `ct' > 0 {
				local cols = `cols' + 1
				local v2Missing = "missing"
			}
		}
	}
	else {
		capture drop if `firstVar' == ""
		capture drop if `firstVar' == .
		capture drop if `secondVar' == ""
		capture drop if `secondVar' == .
	}
	
	qui putexcel set "`using'", `sheet' `replace' `keepCellFormat' open
	local colCopy = `col'
	
	local formatRows = `rows' - 3
	local formatRow = `row' + 1
	formatCells "`col'" "`cols'" "`formatRow'" "`formatRows'" `"`firstVarValueLabel'"' `"`secondVarValueLabel'"' "`firstVar'" "`secondVar'" "twoWay"


	
	* Display v2 label
	local midCol = ((`cols'-1)/2)
	local tmp = ceil(`midCol')
	local tmp = `col' + `tmp'
	local midCol = `col' + `midCol'
	num2base26 `tmp'
	local tmp = "`r(col_letter)'"
	num2base26 `midCol'
	local midCol = "`r(col_letter)'"
	if "`midCol'" == "`tmp'" {
		* Column number was odd, just do the header in the middle.
		qui putexcel `midCol'`row'=(`"`secondVarLabel'"')
		qui putexcel `midCol'`row':`midCol'`row', shrink hcenter bold
	}
	else {
		* Column number was even, put header in ciel and ciel - 1
		qui putexcel `midCol'`row'=(`"`secondVarLabel'"')
		qui putexcel `midCol'`row':`tmp'`row', merge shrink hcenter bold
	}
	local row = `row' + 1
	
	* Header
	num2base26 `col'
	local colLetter = "`r(col_letter)'"
	qui putexcel `colLetter'`row'=(`"`firstVarLabel'"')
	local col = `col' + 1
	num2base26 `col'
	local colLetter = "`r(col_letter)'"
	foreach i of local secondVarList {
		if `"`secondVarValueLabel'"' != "" {
			local vl : label (`secondVar') `i'
			qui putexcel `colLetter'`row'=(`"`vl'"')
		}
		else {
			if "`v2Type'" == "str" {
				qui putexcel `colLetter'`row'=("`i'")
			}
			else {
				qui putexcel `colLetter'`row'=(`i')
			}
		}
		local col = `col' + 1
		num2base26 `col'
		local colLetter = "`r(col_letter)'"
	}
	
	* Adds potential missing column header
	if "`v2Missing'" != "" {
		if "`v2Type'" == "str" {
			qui putexcel `colLetter'`row'=(" ")
		}
		else {
			qui putexcel `colLetter'`row'=(".")
		}
		local col = `col' + 1
		num2base26 `col'
		local colLetter = "`r(col_letter)'"
	}
	
	qui putexcel `colLetter'`row'=("Total")
	local row = `row' + 1
	local col = `colCopy'
	local colCopy = `col'
	num2base26 `col'
	local colLetter = "`r(col_letter)'"
	
	* Body
	foreach i of local firstVarList {
		if `"`firstVarValueLabel'"' != "" {
			local vl : label (`firstVar') `i'
			qui putexcel `colLetter'`row'=(`"`vl'"')
		}
		else {
			if "`v1Type'" == "str" {
				qui putexcel `colLetter'`row'=("`i'")
			}
			else {
				qui putexcel `colLetter'`row'=(`i')
			}
		}
		local col = `col' + 1
		num2base26 `col'
		local colLetter = "`r(col_letter)'"
		
		foreach j of local secondVarList {
			if "`v1Type'" == "str" {
				if "`v2Type'" == "str" {
					qui sum if `firstVar' == "`i'" & `secondVar' == "`j'" `weight'
				}
				else {
					qui sum if `firstVar' == "`i'" & `secondVar' == `j' `weight'
				}
			}
			else {
				if "`v2Type'" == "str" {
					qui sum if `firstVar' == `i' & `secondVar' == "`j'" `weight'
				}
				else {
					qui sum if `firstVar' == `i' & `secondVar' == `j' `weight'
				}
			}
			
			local count = 0
			capture local count = `r(N)'
			
			qui putexcel `colLetter'`row'=(`count')
			local col = `col' + 1
			num2base26 `col'
			local colLetter = "`r(col_letter)'"
		}
		
		* Fills potential missing column
		if "`v2Missing'" != "" {
			if "`v2Type'" == "str" {
				if "`v1Type'" == "str" {
					qui sum if `secondVar' == "" & `firstVar' == "`i'" `weight'
				}
				else {
					qui sum if `secondVar' == "" & `firstVar' == `i' `weight'
				}
				local count = 0
				capture local count = `r(N)'	
				qui putexcel `colLetter'`row'=(`count')
			}
			else {
				if "`v1Type'" == "str" {
					qui sum if `secondVar' == . & `firstVar' == "`i'" `weight'
				}
				else {
					qui sum if `secondVar' == . & `firstVar' == `i' `weight'
				}
				local count = 0
				capture local count = `r(N)'	
				qui putexcel `colLetter'`row'=(`count')
			}
			local col = `col' + 1
			num2base26 `col'
			local colLetter = "`r(col_letter)'"
		}
		
		if "`v1Type'" == "str" {
			qui sum if `firstVar' == "`i'" `weight'
		}
		else {
			qui sum if `firstVar' == `i' `weight'
		}
		
		local count = 0
		capture local count = `r(N)'
		
		qui putexcel `colLetter'`row'=(`count')
		local row = `row' + 1
		local col = `colCopy'
		num2base26 `col'
		local colLetter = "`r(col_letter)'"
	}
	
	* Potential missing row variable
	if "`v1Missing'" != "" {
		if "`v1Type'" == "str" {
			qui putexcel `colLetter'`row'=(" ")
			local col = `col' + 1
			num2base26 `col'
			local colLetter = "`r(col_letter)'"
			
			foreach j of local secondVarList {
				if "`v2Type'" == "str" {
					qui sum if `firstVar' == "" & `secondVar' == "`j'" `weight'
				}
				else {
					qui sum if `firstVar' == "" & `secondVar' == `j' `weight'
				}
				local count = 0
				capture local count = `r(N)'
				qui putexcel `colLetter'`row'=(`count')
				local col = `col' + 1
				num2base26 `col'
				local colLetter = "`r(col_letter)'"
			}
			
			qui sum if `firstVar' == ""
			local count = 0
			capture local count = `r(N)'	
			qui putexcel `colLetter'`row'=(`count')
		}
		else {
			qui putexcel `colLetter'`row'=(".")
			local col = `col' + 1
			num2base26 `col'
			local colLetter = "`r(col_letter)'"
			
			foreach j of local secondVarList {
				if "`v2Type'" == "str" {
					qui sum if `firstVar' == . & `secondVar' == "`j'" `weight'
				}
				else {
					qui sum if `firstVar' == . & `secondVar' == `j' `weight'
				}
				local count = 0
				capture local count = `r(N)'
				qui putexcel `colLetter'`row'=(`count')
				local col = `col' + 1
				num2base26 `col'
				local colLetter = "`r(col_letter)'"
			}
			
			qui sum if `firstVar' == .
			local count = 0
			capture local count = `r(N)'	
			qui putexcel `colLetter'`row'=(`count')
		}
		local row = `row' + 1
		local col = `colCopy'
		num2base26 `col'
		local colLetter = "`r(col_letter)'"
	}
	
	* Footer
	qui putexcel `colLetter'`row'=("Total")
	local col = `col' + 1
	num2base26 `col'
	local colLetter = "`r(col_letter)'"
	
	foreach i of local secondVarList {
		if "`v2Type'" == "str" {
			qui sum if `secondVar' == "`i'" `weight'
		}
		else {
			qui sum if `secondVar' == `i' `weight'
		}
		
		local count = 0
		capture local count = `r(N)'
		
		qui putexcel `colLetter'`row'=(`count')
		local col = `col' + 1
		num2base26 `col'
		local colLetter = "`r(col_letter)'"
	}
	
	if "`v2Missing'" != "" {
		if "`v2Type'" == "str" {
			qui sum if `secondVar' == "" `weight'
		}
		else {
			qui sum if `secondVar' == . `weight'
		}
		
		local count = 0
		capture local count = `r(N)'
		
		qui putexcel `colLetter'`row'=(`count')
		local col = `col' + 1
		num2base26 `col'
		local colLetter = "`r(col_letter)'"
	}
	
	qui sum `summarize' `weight'
	
	local count = 0
	capture local count = `r(N)'
	qui putexcel `colLetter'`row'=(`count')
		
	putexcel close
	restore
end

program define doTwoWayPercentage
	args varlist touse keepCellFormat missing using sheet replace row col percentage
	preserve
		
	local firstVar = word("`varlist'", 1)
	local firstVarLabel : var label `firstVar'
	local firstVarValueLabel : value label `firstVar'
	local secondVar = word("`varlist'", 2)
	local secondVarLabel : var label `secondVar'
	local secondVarValueLabel : value label `secondVar'
	capture confirm string variable `firstVar'
	if !_rc {
		local v1Type "str"
	}
	capture confirm string variable `secondVar'
	if !_rc {
		local v2Type "str"
	}
	
	capture keep if `touse'
	
	* Drop all missing values in all vars
	capture drop if `firstVar' >= .
	capture drop if `firstVar' == ""
	capture drop if `secondVar' >= .
	capture drop if `secondVar' == ""
	
	qui levelsof(`firstVar')
	local firstVarList = `"`r(levels)'"'
	local rows = 3*(`r(r)'+1) + 2
	
	qui levelsof(`secondVar')
	local secondVarList = `"`r(levels)'"'
	local cols = `r(r)' + 2
	local twoWay = `cols'
	
	if `"`firstVarLabel'"' != "" {
		local col1_header = `"`firstVarLabel'"'
	}
	else {
		local col1_header = "`firstVar'"
	}
	
	if "`missing'" != "" {
		di "    The {cmd:percentage} option removes missing values. Using this option will not change the result."
	}
	
	qui putexcel set "`using'", `sheet' `replace' `keepCellFormat' open
	local colCopy = `col'
	
	// Same formatting as the summarize option. Simple reuse of the function call
	formatSummarizeCells "`col'" "`cols'" "`row'" "`rows'" `"`firstVarValueLabel'"' `"`secondVarValueLabel'"' "`firstVar'" "`secondVar'" "twoWay"


	
	* Display v2 label
	local midCol = ((`cols'-1)/2)
	local tmp = ceil(`midCol')
	local tmp = `col' + `tmp'
	local midCol = `col' + `midCol'
	num2base26 `tmp'
	local tmp = "`r(col_letter)'"
	num2base26 `midCol'
	local midCol = "`r(col_letter)'"
	if "`midCol'" == "`tmp'" {
		* Column number was odd, just do the header in the middle.
		qui putexcel `midCol'`row'=(`"`secondVarLabel'"')
		qui putexcel `midCol'`row':`midCol'`row', shrink hcenter bold
	}
	else {
		* Column number was even, put header in ciel and ciel - 1
		qui putexcel `midCol'`row'=(`"`secondVarLabel'"')
		qui putexcel `midCol'`row':`tmp'`row', merge shrink hcenter bold
	}
	local row = `row' + 1
	
	* Header
	num2base26 `col'
	local colLetter = "`r(col_letter)'"
	qui putexcel `colLetter'`row'=(`"`firstVarLabel'"')
	local col = `col' + 1
	num2base26 `col'
	local colLetter = "`r(col_letter)'"
	foreach i of local secondVarList {
		if `"`secondVarValueLabel'"' != "" {
			local vl : label (`secondVar') `i'
			qui putexcel `colLetter'`row'=(`"`vl'"')
		}
		else {
			if "`v2Type'" == "str" {
				qui putexcel `colLetter'`row'=("`i'")
			}
			else {
				qui putexcel `colLetter'`row'=(`i')
			}
		}
		local col = `col' + 1
		num2base26 `col'
		local colLetter = "`r(col_letter)'"
	}
	qui putexcel `colLetter'`row'=("Total")
	local row = `row' + 1
	local col = `colCopy'
	local colCopy = `col'
	num2base26 `col'
	local colLetter = "`r(col_letter)'"
	
	* Body
	foreach i of local firstVarList {
		if `"`firstVarValueLabel'"' != "" {
			local vl : label (`firstVar') `i'
			qui putexcel `colLetter'`row'=(`"`vl'"')
		}
		else {
			if "`v1Type'" == "str" {
				qui putexcel `colLetter'`row'=("`i'")
			}
			else {
				qui putexcel `colLetter'`row'=(`i')
			}
		}
		local col = `col' + 1
		num2base26 `col'
		local colLetter = "`r(col_letter)'"
		
		foreach j of local secondVarList {
			if "`v1Type'" == "str" {
				if "`v2Type'" == "str" {
					qui count if `firstVar' == "`i'" & `secondVar' == "`j'"
				}
				else {
					qui count if `firstVar' == "`i'" & `secondVar' == `j'
				}
			}
			else {
				if "`v2Type'" == "str" {
					qui count if `firstVar' == `i' & `secondVar' == "`j'"
				}
				else {
					qui count if `firstVar' == `i' & `secondVar' == `j'
				}
			}
			
			local count = 0
			capture local count = `r(N)'
			local rowPercent = `count'
			local colPercent = `count'
			// Calculate row and column percentage per iteration using count
			if "`v1Type'" == "str" {
				qui count if `firstVar' == "`i'"
				local rowPercent = `rowPercent'/`r(N)'*100
			}
			else {
				qui count if `firstVar' == `i'
				local rowPercent = `rowPercent'/`r(N)'*100
			}
			
			if "`v2Type'" == "str" {
				qui count if `secondVar' == "`j'"
				local colPercent = `colPercent'/`r(N)'*100
			}
			else {
				qui count if `secondVar' == `j'
				local colPercent = `colPercent'/`r(N)'*100
			}
			
			/*
			if "`mean'" == "." | "`mean'" == "" {
				local mean = 0
			}
			if "`sd'" == "." | "`sd'" == "" {
				local sd = 0
			}
			*/
			
			/* 
			 Merge formatting calls with setting cell contents because it's easier
			 to do it in this looping structure than inside of the format subroutine
				*/
			qui putexcel `colLetter'`row'=(`count')
			local row = `row' + 1
			qui putexcel `colLetter'`row'=(`rowPercent')
			qui putexcel `colLetter'`row':`colLetter'`row', nformat(number_d2)
			local row = `row' + 1
			qui putexcel `colLetter'`row'=(`colPercent')
			qui putexcel `colLetter'`row':`colLetter'`row', nformat(number_d2)
			local row = `row' - 2
			local col = `col' + 1
			num2base26 `col'
			local colLetter = "`r(col_letter)'"
		}
		
		if "`v1Type'" == "str" {
			qui count if `firstVar' == "`i'"
		}
		else {
			qui count if `firstVar' == `i'
		}
		
		local count = 0
		capture local count = `r(N)'
		local rowPercent = 100
		local colPercent = `count'
		if "`v2Type'" == "str" {
			qui count
			local colPercent = `colPercent'/`r(N)'*100
		}
		else {
			qui count
			local colPercent = `colPercent'/`r(N)'*100
		}
		/* 
		 Merge formatting calls with setting cell contents because it's easier
		 to do it in this looping structure than inside of the format subroutine
			*/	
		qui putexcel `colLetter'`row'=(`count')
		local row = `row' + 1
		qui putexcel `colLetter'`row'=(`rowPercent')
		qui putexcel `colLetter'`row':`colLetter'`row', nformat(number_d2)
		local row = `row' + 1
		qui putexcel `colLetter'`row'=(`colPercent')
		qui putexcel `colLetter'`row':`colLetter'`row', nformat(number_d2)
		local row = `row' + 1
		local col = `colCopy'
		num2base26 `col'
		local colLetter = "`r(col_letter)'"
	}
	
	* Footer
	qui putexcel `colLetter'`row'=("Total")
	local col = `col' + 1
	num2base26 `col'
	local colLetter = "`r(col_letter)'"
	
	foreach i of local secondVarList {
		if "`v2Type'" == "str" {
			qui count if `secondVar' == "`i'"
		}
		else {
			qui count if `secondVar' == `i'
		}
		
		local count = 0
		capture local count = `r(N)'
		local rowPercent = `count'
		local colPercent = 100
		if "`v1Type'" == "str" {
			qui count
			local rowPercent = `rowPercent'/`r(N)'*100
		}
		else {
			qui count
			local rowPercent = `rowPercent'/`r(N)'*100
		}
		/* 
		 Merge formatting calls with setting cell contents because it's easier
		 to do it in this looping structure than inside of the format subroutine
			*/
		qui putexcel `colLetter'`row'=(`count')
		local row = `row' + 1
		qui putexcel `colLetter'`row'=(`rowPercent')
		qui putexcel `colLetter'`row':`colLetter'`row', nformat(number_d2)
		local row = `row' + 1
		qui putexcel `colLetter'`row'=(`colPercent')
		qui putexcel `colLetter'`row':`colLetter'`row', nformat(number_d2)
		local row = `row' - 2
		local col = `col' + 1
		num2base26 `col'
		local colLetter = "`r(col_letter)'"
	}
	
	qui count
	capture local count = `r(N)'
	local rowPercent = 100
	local colPercent = 100

	/* 
	 Merge formatting calls with setting cell contents because it's easier
	 to do it in this looping structure than inside of the format subroutine
		*/
	qui putexcel `colLetter'`row'=(`count')
	local row = `row' + 1
	qui putexcel `colLetter'`row'=(`rowPercent')
	qui putexcel `colLetter'`row':`colLetter'`row', nformat(number_d2)
	local row = `row' + 1
	qui putexcel `colLetter'`row'=(`colPercent')
	qui putexcel `colLetter'`row':`colLetter'`row', nformat(number_d2)
		
	restore
	putexcel close
end
