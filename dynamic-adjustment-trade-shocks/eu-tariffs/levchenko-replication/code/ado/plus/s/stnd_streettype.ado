capture program drop stnd_streettype
program define stnd_streettype
version 9.2
//last modified July 22, 2014

syntax varlist(max=1) [if] [in] [,Patpath(str) WARNingmsg(str)]


if "`patpath'"~="" {
	local mypath "`patpath'"
}
else {
	local dir : sysdir PLUS
	local mypath "`dir'/p/"
}

capture qui findfile  P110_std_streettypes.csv, path(`mypath')
marksample touse, strok

if _rc~=0 {
	if "`warningmsg'"!="off" {
	di as error "Warning: Could not find the pattern file P110_std_streettypes.csv"
	di as error "         Skip street type standardization."
	}
	qui replace `varlist' = trim(itrim(`varlist')) if `touse'
}		

else {

	local mypattern "`mypath'/P110_std_streettypes.csv"

	tempvar j
	qui gen `j' =  trim(itrim(`varlist')) if `touse'
	
	capture file close myfile
	file open myfile using "`mypattern'", read
	file read myfile line
		while r(eof)==0 {

		tokenize `"`line'"', parse(,)
		//1 = orig; 2 = parse character; 3 = standardized
		qui replace `j' =  subinword(`j',"`1'","`3'",.) if `touse'

		file read myfile line
		}

	file close myfile
	
qui replace `varlist' = trim(itrim(`j')) if `touse'
}

end
