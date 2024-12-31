*****************************************************************************************
** CSVCONVERT: Stata module to append a set of .csv files in one Stata file  
*! Version 3 - 18Jan2014		  		 
** 													 
*****************************************************************************************								
*! Author: Alberto A. Gaggero (University of Pavia)				         
** mail: alberto.gaggero@unipv.it          										
*****************************************************************************************
** Acknowledgement: I am grateful to Violeta Carrion, Emanuele Forlani, Edna Solomon and 
* one anonymous referee of Stata Journal for helpful comments.

program define csvconvert
version 11
syntax anything (name=input_dir id="Input directory") , replace [input_file(string) output_file(string) output_dir(string)]
if ("`replace'"=="") {
       display in red "Warning - output file will be replaced, add option replace" 
       quit
       } 

display "_________________________________________________"
if "`output_dir'"=="" &  "`output_file'"=="" & "`input_file'"=="" {  // no options specified - CASE 1
qui cd "`input_dir'"
*If you wish to have a log, turn this option on
*qui log using csvconvert.log, name("Log file of csvconvert") replace

local i=0
local csv=0
capture erase output.dta
local files : dir . files "*.csv"

foreach f of local files {
drop _all
display "The csv file `f'"
insheet using "`f'", names
qui gen _csvfile=""
qui replace _csvfile="`f'"
qui label var _csvfile "csv file from which observation originates"
  
if `i'>0 append using output, force
local csv=`csv'+1
label data "Stata file created from `csv' csv files using csvconvert"
qui note: File  included on TS : "`f'"  
qui save output, replace
display "has been successfully included in output.dta"
display "_________________________________________________"
local i=1
}
*qui log close _all
} // end of CASE 1
 
else {

if "`output_dir'"!="" &  "`output_file'"=="" & "`input_file'"=="" { // output_dir specified only - CASE 2
qui cd "`input_dir'"
*If you wish to have a log, turn this option on
*qui log using csvconvert.log, name("Log file of csvconvert") replace
local i=0
local csv=0
qui cd "`output_dir'"
capture erase output.dta
qui cd "`input_dir'"
local files : dir . files "*.csv"

foreach f of local files {
qui cd "`input_dir'"
drop _all
display "The csv file `f'"
insheet using "`f'", names
qui gen _csvfile=""
qui replace _csvfile="`f'"
qui label var _csvfile "csv file from which observation originates"

qui cd "`output_dir'"  
if `i'>0 append using output, force
local csv=`csv'+1
label data "Stata file created from `csv' csv files using csvconvert"
qui note: File included on TS :"`f'"
qui save output, replace
display "has been successfully included in output.dta"
display "_________________________________________________"
local i=1
} // end of "foreach"
} // end of CASE 2
*qui log close _all
}  
else {
if "`output_dir'"=="" &  "`output_file'"!="" & "`input_file'"=="" { // output_file specified only - CASE 3
qui cd "`input_dir'"
*If you wish to have a log, turn this option on
*qui log using csvconvert.log, name("Log file of csvconvert") replace
local i=0
local csv=0
capture erase `output_file'.dta
local files : dir . files "*.csv"

foreach f of local files {
drop _all
display "The csv file `f'"
insheet using "`f'", names
qui gen _csvfile=""
qui replace _csvfile="`f'"
qui label var _csvfile "csv file from which observation originates"

if `i'>0 append using `output_file', force
local csv=`csv'+1
label data "Stata file created from `csv' csv files using csvconvert"
qui note: File  included on TS : "`f'"  
qui save `output_file', replace
display "has been successfully included in `output_file'.dta"
display "_________________________________________________"
local i=1
} // end of "foreach"
} // /// end of CASE 3
}
else {
if "`output_dir'"=="" &  "`output_file'"=="" & "`input_file'"!="" { // input_file specified only - CASE 4
qui cd "`input_dir'"
*If you wish to have a log, turn this option on
*qui log using csvconvert.log, name("Log file of csvconvert") replace

local i=0
local csv=0
capture erase output.dta

foreach f of local input_file {
drop _all
display "The csv file `f'"
insheet using "`f'", names
qui gen _csvfile=""
qui replace _csvfile="`f'"
qui label var _csvfile "csv file from which observation originates"
  
if `i'>0 append using output, force
local csv=`csv'+1
label data "Stata file created from `csv' csv files using csvconvert"
qui note: File  included on TS : "`f'"  
qui save output, replace
display "has been successfully included in output.dta"
display "_________________________________________________"
  
local i=1
} // end of "foreach"
*duplicate issue
qui duplicates tag, gen(_duplicates)
qui label var _duplicates "=1 if dupplicate, =0 otherwise"
qui egen _tot_duplicates=total(_duplicates)
} // end of CASE 4
} 
*qui log close _all
else {
if "`output_dir'"!="" &  "`output_file'"!="" & "`input_file'"=="" { // output_dir & output_file specified - CASE 5
qui cd "`input_dir'"
local i=0
local csv=0
qui cd "`output_dir'"
*If you wish to have a log, turn this option on
*qui log using csvconvert.log, name("Log file of csvconvert") replace
* capture erase `output_file'.dta
qui cd "`input_dir'"
local files : dir . files "*.csv"

foreach f of local files {
qui cd "`input_dir'"
drop _all
display "The csv file `f'"
insheet using "`f'", names
qui gen _csvfile=""
qui replace _csvfile="`f'"
qui label var _csvfile "csv file from which observation originates"

qui cd "`output_dir'"  
if `i'>0 append using `output_file', force
local csv=`csv'+1
label data "Stata file created from `csv' csv files using csvconvert"
qui save `output_file', replace
display "has been successfully included in `output_file'.dta"
display "_________________________________________________"
local i=1
} // end of "foreach"
} // end of CASE 5

*qui log close _all
}
else {
if "`output_dir'"!="" &  "`output_file'"=="" & "`input_file'"!="" { // output_dir & input_file specified only - CASE 6
qui cd "`input_dir'"
*If you wish to have a log, turn this option on
*qui log using csvconvert.log, name("Log file of csvconvert") replace
local i=0
local csv=0
qui cd "`output_dir'"
capture erase output.dta
qui cd "`input_dir'"

foreach f of local input_file {
qui cd "`input_dir'"
drop _all
display "The csv file `f'"
insheet using "`f'", names
qui gen _csvfile=""
qui replace _csvfile="`f'"
qui label var _csvfile "csv file from which observation originates"

qui cd "`output_dir'"  
if `i'>0 append using output, force
local csv=`csv'+1
label data "Stata file created from `csv' csv files using csvconvert"
qui note: File  included on TS : "`f'"  
qui save output, replace
display "has been successfully included in output.dta"
display "_________________________________________________"
local i=1
} // end of "foreach"
*duplicate issue
qui duplicates tag, gen(_duplicates)
qui label var _duplicates "=1 if dupplicate, =0 otherwise"
qui egen _tot_duplicates=total(_duplicates)
} // end of CASE 6
*qui log close _all
}
else {
if "`output_dir'"=="" &  "`output_file'"!="" & "`input_file'"!="" { // output_file & input_file specified only - CASE 7
qui cd "`input_dir'"
*If you wish to have a log, turn this option on
*qui log using csvconvert.log, name("Log file of csvconvert") replace
local i=0
local csv=0
capture erase `output_file'.dta
local files : dir . files "*.csv"

foreach f of local input_file {
drop _all
display "The csv file `f'"
insheet using "`f'", names
qui gen _csvfile=""
qui replace _csvfile="`f'"
qui label var _csvfile "csv file from which observation originates"
  
if `i'>0 append using `output_file', force
local csv=`csv'+1
label data "Stata file created from `csv' csv files using csvconvert"
qui note: File  included on TS : "`f'"  
qui save `output_file', replace
display "has been successfully included in `output_file'.dta"
display "_________________________________________________"
local i=1
} // end of "foreach"
qui duplicates tag, gen(_duplicates)
qui label var _duplicates "=1 if dupplicate, =0 otherwise"
qui egen _tot_duplicates=total(_duplicates)
} // end of CASE 7
}
else {
if "`output_dir'"!="" &  "`output_file'"!="" & "`input_file'"!="" { // output_dir, output_file & input_file specified (all options specified) - CASE 8
qui cd "`input_dir'"
local i=0
local csv=0
qui cd "`output_dir'"
*If you wish to have a log, turn this option on
*qui log using csvconvert.log, name("Log file of csvconvert") replace
capture erase `output_file'.dta
qui cd "`input_dir'"

foreach f of local input_file {
qui cd "`input_dir'"
drop _all
display "The csv file `f'"
insheet using "`f'", names
qui gen _csvfile=""
qui replace _csvfile="`f'"
qui label var _csvfile "csv file from which observation originates"

qui cd "`output_dir'"  
if `i'>0 append using `output_file', force
local csv=`csv'+1
label data "Stata file created from `csv' csv files using csvconvert"
qui note: File  included on TS : "`f'"  
qui save `output_file', replace
display "has been successfully included in `output_file'.dta"
display "_________________________________________________"
local i=1
} // end of "foreach"
qui duplicates tag, gen(_duplicates)
qui label var _duplicates "=1 if dupplicate, =0 otherwise"
qui egen _tot_duplicates=total(_duplicates)
} // end of CASE 8
*qui log close _all
}

display ""
display "****************************************************************"
display " You have successfully converted `csv' csv files in one Stata file "
display "****************************************************************"

*Duplicate issue
if "`output_dir'"=="" &  "`output_file'"=="" & "`input_file'"!="" { // input_file specified only - CASE 4
if _tot_duplicates>0 display in red "Warning - output.dta has " _tot_duplicates/2 " duplicate observations:" ///
" you might have entered a .csv file name twice in the input_file() option, or your orginal dataset may contain duplicates." ///
" Check if this is what you wanted: variable '_duplicates' = 1 in case of duplicate and = 0 otherwise may help."
qui if _tot_duplicates==0 drop _duplicates
qui drop _tot_duplicates
}
else {
if "`output_dir'"!="" &  "`output_file'"=="" & "`input_file'"!="" { // output_dir & input_file specified only - CASE 6
if _tot_duplicates>0 display in red "Warning - output.dta has " _tot_duplicates/2 " duplicate observations:" ///
" you might have entered a .csv file name twice in the input_file() option, or your orginal dataset may contain duplicates." ///
" Check if this is what you wanted: variable '_duplicates' = 1 in case of duplicate and = 0 otherwise may help."
qui if _tot_duplicates==0 drop _duplicates
qui drop _tot_duplicates
}
else {
if "`output_dir'"=="" &  "`output_file'"!="" & "`input_file'"!="" { // output_file & input_file specified only - CASE 7
if _tot_duplicates>0 display in red "Warning - `output_file'.dta has " _tot_duplicates/2 " duplicate observations:" ///
" you might have entered a .csv file name twice in the input_file() option, or your orginal dataset may contain duplicates." ///
" Check if this is what you wanted: variable '_duplicates' = 1 in case of duplicate and = 0 otherwise may help."
qui if _tot_duplicates==0 drop _duplicates
qui drop _tot_duplicates
}
else
if "`output_dir'"!="" &  "`output_file'"!="" & "`input_file'"!="" { // output_dir, output_file & input_file specified (all options specified) - CASE 8
if _tot_duplicates>0 display in red "Warning - `output_file'.dta has " _tot_duplicates/2 " duplicate observations:" ///
" you might have entered a .csv file name twice in the input_file() option, or your orginal dataset may contain duplicates." ///
" Check if this is what you wanted: variable '_duplicates' = 1 in case of duplicate and = 0 otherwise may help."
qui if _tot_duplicates==0 drop _duplicates
qui drop _tot_duplicates
}
}
}
end
exit
