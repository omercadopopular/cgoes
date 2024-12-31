*! seeout version 1.2.3 21oct2009 by roywada@hotmail.com
*! (to accompany -outreg2-)

program define seeout
version 7.0

syntax [using] [,LABel LABelA(passthru) ]

if `"`using'"'~="" {
	*** clean up file name, attach .txt if no file type is specified
	local rest "`using'"
	* strip off "using"
	gettoken part rest: rest, parse(" ")
	* strip off quotes
	gettoken first second: rest, parse(" ")
	cap local rest: list clean local(rest)
	
	local rabbit `"""'
	if index(`"`using'"', ".")==0 {
		local file = `"`rabbit'`first'.txt`rabbit'"'
		local using = `"using `file'"'
	}
	else {
		local file = `"`rabbit'`first'`rabbit'"'
		local using = `"using `file'"'
	}
	
	*** seeout the output
	*local cl `"{stata `"seeout `pref'"':  seeout `pref'}"'
	*di as txt `"`cl'"'
	seeing `using', `label'
}

else {
	*** read the set preference if not out of date
	
	* NOTE: `0' is written over below
	cap quietly findfile outreg2.pref
	tempname myfile
	cap file open `myfile' using `"`r(fn)'"', read text
	cap file read `myfile' date
	cap file read `myfile' pref
	cap file read `myfile' options
	cap file close `myfile'
	
	if "`date'"== "`c(current_date)'" {
		*** seeout the output
		
		if index(`"`options'"', "label")~=1 & index(`"`options'"', `"label("')==0 {
			tokenize `"`options'"'
			local count: word count `options'
			if `count'~=0 {
				local test 0
				forval num=1/`count' {
					if `"``num''"'=="label" {
						local label label
					}
				}			
			}
		}
	} /* ? */
	gettoken first file: pref
	
	*** codes recycled from outreg2:
	* strip off quotes and extension
	gettoken first second: file, parse(" ")
	local temp = `"`first'"'
	
	local next_dot = index(`"`temp'"',".")
	local next_strip = substr(`"`temp'"',1,`=`next_dot'-1')
	local strippedname = substr(`"`temp'"',1,`=`next_dot'-1')
	
	* check for more dots
	local change 0
	while `change'==0 {
		local temp = substr(`"`temp'"',`=`next_dot'+1',.)
		if index(`"`temp'"', ".")~=0 {
			local next_dot = index(`"`temp'"',".")
			local next_strip = substr(`"`temp'"',1,`=`next_dot'-1')
			local strippedname = `"`strippedname'.`next_strip'"'
		}
		else {
			* no change
			local last_strip = `"`temp'"'
			local change 1
		}
	}
	
	*** check for manual rtf doc xlm xls csv extensions
	if `"`last_strip'"'=="rtf" | `"`last_strip'"'=="doc" {
		local word "word"
		
		local file = `"`rabbit'`strippedname'.txt`rabbit'"'
		local using = `"using `file'"'
		local wordFile "`last_strip'"
	}
	if `"`last_strip'"'=="xls" | `"`last_strip'"'=="xml" | `"`last_strip'"'=="xlm" | `"`last_strip'"'=="csv" {
		local excel "excel"
		
		local file = `"`rabbit'`strippedname'.txt`rabbit'"'
		local using = `"using `file'"'
		local excelFile "`last_strip'"
	}
	if `"`last_strip'"'=="tex" {
		if `"`tex1'"'=="" {
			local tex "tex"
		}
		
		local file = `"`rabbit'`strippedname'.txt`rabbit'"'
		local using = `"using `file'"'
		local texFile "`last_strip'"
	}
	
		
	if `"`last_strip'"'=="txt" {
		seeing `pref', `label'
	}
	else {
		if "`using'"=="" {
			di in red "must specify using file"
			exit 198
		}
		seeing using `using', `label'
		* similar to the other one except the clickable text
		*local cl `"{stata `"seeout `pref'"':  seeout `pref'}"'
		*di as txt `"`cl'"'
	}
	else {
		di in red "must specify the filename (the last preference has expired)"
		exit 100
	}
}
end



***********************


program define seeing
version 7.0

* invisible to Stata 7
local Version7 ""
cap local Version7 `c(stata_version)'

if "`Version7'"=="" {
	* it is version 7
	*noi di in yel "limited functions under Stata 7"
}
else if `Version7'>=8.2 {
	version 8.2
}

quietly{
	* syntax using/[, Clear]
	syntax using [, LABel LABelA(string) ]
	
	preserve
	
	insheet `using', nonames clear
	describe, short
	
	
	* number of columns
	local numcol = `r(k)'
	
	tempvar blanks rowmiss
	count if v1=="EQUATION"
	if `r(N)'~=0 {
		local eqPlace 1
		local varPlace 2
		count if v3=="LABELS"
		if `r(N)'~=0 {
			local labPlace 3
			local num=4
		}
		else {
			local labPlace 0
			local num=3
		}
	}
	else {
		local eqPlace 0
		local varPlace 1
		
		count if v2=="LABELS"
		if `r(N)'~=0 {
			local labPlace 2
			local num=3
		}
		else {
			local labPlace 0
			local num=2
		}
	}
	
	gen int `blanks' = (trim(v`num')=="")
	forvalues col = `num'/`numcol' {
		replace `blanks' = `blanks' & (trim(v`col')=="")
	}
	
	
	* title rows
	local titleWide = 0
	if v1[1]~="" | v2[1]~="" {
		* there may be a title
		if `labPlace'==0 & `varPlace'==1 {
		      while v1[`=`titleWide'+1']~="" &  v2[`=`titleWide'+1']=="" {
				local titleWide = `titleWide'+1
		}
			}
		if `labPlace'==0 & `varPlace'==2 {
		      while v2[`=`titleWide'+1']~="" &  v3[`=`titleWide'+1']=="" {
				local titleWide = `titleWide'+1
			}
		}
		if `labPlace'~=0 & `varPlace'==1 {
		      while v1[`=`titleWide'+1']~="" &  v3[`=`titleWide'+1']=="" {
				local titleWide = `titleWide'+1
			}
		}
		if `labPlace'~=0 & `varPlace'==2 {
	      while v2[`=`titleWide'+1']~="" &  v4[`=`titleWide'+1']=="" {
				local titleWide = `titleWide'+1
			}
		}
	}
	
	*local VARIABLES "VARIABLES"
	* first name AFTER titles is the VARIABLES
	local content
	local num=`titleWide'+1
	local N=_N
	while `"`content'"'=="" & `num'<=`N' {
		local content=v`varPlace'[`num']
		local num=`num'+1
	}
	local VARIABLES `"`content'"'
	
	replace `blanks'=0 if  v1==`"`VARIABLES'"' | v1[_n-1]==`"`VARIABLES'"' | v2==`"`VARIABLES'"' | v2[_n-1]==`"`VARIABLES'"'
	
		
	* getting bottomBorder (the bottom border), count up
	gen rowmiss=0
	foreach var of varlist v* {
		replace rowmiss=rowmiss+1 if `var'~=""
	}
	local N=_N
	local content 1
	local num 0
	while `content'==1 & `num'<`N' {
		local content rowmiss[`=`N'-`num'']
		local num=`num'+1
	}
	* do not have to add to titleWide
	local bottomRow = `N'-`num'+1
	local bottomBorder=`bottomRow'
	
	* getting halfway to headBorder (the top border), count down
	local content
	local num=`titleWide'+1
	local N=_N
	while `"`content'"'=="" & `num'<=`N' {
		local content=v`varPlace'[`num']
		local num=`num'+1
	}
	* do not have to add to titleWide
	local headRow `num'
	local headBorder=`headRow'
	
	drop rowmiss
	
	
	* avoid counting space within each statistics row as missing
	replace `blanks'=0 if `blanks'[_n+1]==0 & `blanks'==1 & _n >`titleWide'
	
	
	* statistics rows
	*count if `blanks'==0
	*local bottomBorder = `r(N)'+`titleWide'
	
	
	* move the notes and titles to the top of a new column
	gen str5 Notes_Titles=""
	format Notes_Titles %-20s 
	count if v1=="EQUATION"
	if `r(N)'==0 {
		* EQUATION column does not exist
		if `titleWide'>0 {
			forval num=1/`titleWide' {
				replace Notes_Titles=v1[`num'] in `num'
				replace v1="" in `num'
			}
		}
		
		local one = 1
		local legend = v1[`bottomBorder'+`one']
		
		
		local place 1
		*while "`legend'"~="" {
		local N=_N
		while `place' <= `N' {
			local place=`bottomBorder'+`one'
			local legend = v1[`place']
			replace Notes_Titles="`legend'" in `=`one'+`titleWide'+1'
			if "`legend'"~="" {
				replace v1="" in `place'
			}
			local one = `one'+1
		}
		
		* insert label changes here, minus 2 from c(k) for `blanks' & Notes_Titles column
		if "`label'"=="label" {
				*if ("`long'"~="long" & "`onecol'"~="onecol") | ("`long'"=="long" & "`onecol'"=="onecol") {
					replace v2=v1 if v2==""
					drop v1
					describe, short
					forval num=1/`=`r(k)'-2' {
						ren v`=`num'+1' v`num'
					}
					
					* change LABELS to VARIABLES
					replace v1=`"`VARIABLES'"' if v1=="LABELS"
				*}
				local label_adjust "-1"
		}
		
		* change the string length
		gen str5 temp=""
		replace temp=v1
		drop v1
		ren temp v1
		order v1
		* format
		foreach var of varlist v1 {
			local _format= "`: format `var''"
			local _widths=substr("`_format'",2,length(trim("`_format'"))-2)
			format `var' %-`_widths's
		}
	}
	else {
		* equation column exists
		if `titleWide'>0 {
			forval num=1/`titleWide' {
				replace Notes_Titles=v2[`num'] in `num'
				replace v2="" in `num'
			}
		}
		
		local one = 1
		local legend = v2[`bottomBorder'+`one']
		while "`legend'"~="" {
			local place=`bottomBorder'+`one'
			local legend = v2[`place']
			replace Notes_Titles="`legend'" in `=`one'+`titleWide'+1'
			if "`legend'"~="" {
				replace v2="" in `place'
			}
			local one = `one'+1
		}
		
		* insert label changes here, minus 2 from c(k) for `blanks' & Notes_Titles column
		if "`label'"=="label" {
				*else if "`long'"~="long" & "`onecol'"=="onecol" {
					replace v3=v2 if v3==""
					drop v2
					describe, short
					forval num=2/`=`r(k)'-2' {
						ren v`=`num'+1' v`num'
					}
					
					* change LABELS to VARIABLES
					replace v2=`"`VARIABLES'"' if v2=="LABELS"
				*}
				local label_adjust "-1"
		}
		
		
		* change the string length
		gen str5 temp=""
		replace temp=v2
		drop v2
		ren temp v2
		order v1 v2
		* format
		foreach var of varlist v1 v2 {
			local _format= "`: format `var''"
			local _widths=substr("`_format'",2,length(trim("`_format'"))-2)
			format `var' %-`_widths's
		}
	}
	
	* clean up
	*egen `rowmiss'=rowmiss(_all)
	* rowmiss option not available in 8.2 or 8.0, do it by hand
	
	gen `rowmiss'=0
	foreach var of varlist _all {
		if "`var'"~="`rowmiss'" & "`var'"~="`blanks'" {
			replace `rowmiss'=1+`rowmiss' if `var'==""
		}
	}
	
	*drop if `rowmiss'==`numcol'+1
	
	* adjust to handle label column droppings
	*drop if `rowmiss'==`numcol'+1 & `blanks'==1
	
	* fix blanks==1 for groupvar( )
	count if `blanks'==1
	local rN=`r(N)'+1
	forval num=1/`rN' {
		replace `blanks'=0 if `blanks'[_n+1]==0 & `blanks'==1
	}
	
	drop if `rowmiss'==`numcol'+1 `label_adjust' & `blanks'==1
	drop `blanks' `rowmiss'
	
	browse
	
	if "`Version7'"=="" {
		* it is version 7
	}
	else if `Version7'>=11.0 {
		noi di in yel "Hit Enter to continue" _request(junk)
	}
	
	*restore, preserve
}
end  /* end of seeing */

exit



* versions
1.1	replaced rowmiss option in egen, which is not available in 8.2
1.1.1	disabled -restore, preserve- as redundant waste of time
	fixed seeing/seeout: handles blank space in stat(aster)
	label does not show
	no longer produces a seeout blue text whenever a seeout blue text was clicked
1.1.2	the shorthand form of seeout hides label
1.1.3	the shorthand form of seeout hides label: `label' is actually read from outreg2_pref.ado
1.2.0	down to version 7.0; -describe, short- instead of c(k)
	if `"`using'"'~="": needed the compound quotes
	VARIABLES is flexibly named
1.2.1 Apr2009 handles xls, doc, etc, that was left attached to file names in pref_ado
1.2.2 04Aug2009 a fix for asynchronoous data browser in -seeing- for version 11
1.2.3 21oct2009 outreg2_pref should have been replaced with outreg2.pref earlier

