capture program drop stnd_address
program define stnd_address
version 9.2

*!written by N Wasi: nwasi@umich.edu
*!last modified Aug 28, 2015: changed stnd_NESW to stnd_nesw (and in the pattern file as well)

syntax varlist(max=1) [if] [in], Generate(str) [Patpath(str)]
di "stnd_address version p1.3"
confirm new var `generate'

if "`patpath'"~="" {
	local mypath "`patpath'"
}
else {
	local dir : sysdir PLUS
	local mypath "`dir'p/"
}

checkpatternfiles, mypath(`mypath')
if `r(found)'==0 {
	di as error "No pattern file found in `mypath'"
	exit
}
else di "pattern files from `mypath'"



marksample touse, strok

//5 new variables `add11' `pobox' `unit' `bldg' `floor'
tempvar street_stn add1 add11 pobox unit bldg floor

qui gen `street_stn' = upper(`varlist') if `touse'
qui replace `street_stn' = trim(itrim(`street_stn')) if `touse'

local msg1 = "on"
//remove special characters
stnd_specialchar `street_stn' if `touse', exclude(#-) patpath(`mypath') warningmsg(`msg1')

stnd_streettype `street_stn' if `touse', patpath(`mypath') warningmsg(`msg1')
stnd_commonwrd_all `street_stn' if `touse', patpath(`mypath') warningmsg(`msg1')
stnd_nesw `street_stn' if `touse', patpath(`mypath') warningmsg(`msg1')
stnd_numbers `street_stn' if `touse', patpath(`mypath') warningmsg(`msg1')

// parse pobox (input 2 new variable names)
parsing_pobox `street_stn' if `touse', gen(`add1' `pobox') patpath(`mypath') warningmsg(`msg1')
qui drop `street_stn'

//standardize secondary add
stnd_secondaryadd `add1' if `touse' & `add1'~="", patpath(`mypath') warningmsg(`msg1')
//parse secondary
parsing_add_secondary `add1' if `touse' & `add1'~="", gen(`add11' `unit' `bldg' `floor')  patpath(`mypath') warningmsg(`msg1')
qui replace `add11' = `add1' if `add11' ==""& `unit'==""& `bldg'=="" & `floor'=="" & `add1'~=""

//small word
stnd_smallwords `add11' if `touse', patpath(`mypath') type(address) warningmsg(`msg1')

//remove {-,#} if it's left out at the end
qui replace `add11' = subinstr(`add11',"-","",.) if regexm(`add11',"-[ ]*$")==1 & regexm(`add11',"[0-9]\-[0-9]")==0 & `touse'
qui replace `add11' = subinstr(`add11',"#","",.) if `touse'
qui replace `add11' = trim(itrim(`add11')) if `touse'


tokenize `generate'
local num_output : word count `generate'

if `num_output' >=1 qui gen `1'=`add11'
if `num_output' >=2 qui gen `2'=`pobox'
if `num_output' >=3 qui gen `3'=`unit'
if `num_output' >=4 qui gen `4'=`bldg'
if `num_output' ==5 qui gen `5'=`floor'

label var `1' "street add"
capture label var `2' "PO Box"
capture label var `3' "unit/apt"
capture label var `4' "building"
capture label var `5' "floor/level"

end


*-----------------a helper to check pattern file-----------------*
capture program drop checkpatternfiles
program define checkpatternfiles, rclass

syntax , mypath(str)

//check if there is any pattern at all, exit if no pattern
local anypatternfile = 0
capture qui findfile P22_spchar_remove.csv, path(`mypath')
	if _rc==0 local anypatternfile = 1			
	else capture qui findfile P23_spchar_rplcwithspace.csv, path(`mypath')
		if _rc==0 local anypatternfile = 1			
		else capture qui findfile P50_std_commonwrd_all.csv, path(`mypath')
			if _rc==0 local anypatternfile = 1			
			else capture qui findfile P60_std_numbers.csv, path(`mypath')
				if _rc==0 local anypatternfile = 1			
				else capture qui findfile P70_std_nesw.csv, path(`mypath')
					if _rc==0 local anypatternfile = 1								
					else capture qui findfile P81_std_smallwords_all.csv, path(`mypath')
						if _rc==0 local anypatternfile = 1							
						else capture qui findfile P82_std_smallwords_address.csv, path(`mypath')
							if _rc==0 local anypatternfile = 1								
							else capture qui findfile P110_std_streettypes.csv, path(`mypath')
								if _rc==0 local anypatternfile = 1								
								else capture qui findfile P120_pobox_patterns.csv, path(`mypath')
									if _rc==0 local anypatternfile = 1								
									else capture qui findfile P130_secondaryadd_patterns.csv, path(`mypath')
	
return scalar found = `anypatternfile'

end


