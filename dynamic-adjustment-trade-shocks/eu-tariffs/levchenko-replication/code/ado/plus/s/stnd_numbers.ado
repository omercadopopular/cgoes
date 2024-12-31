capture program drop stnd_numbers
program define stnd_numbers
version 9.2

//written by N Wasi: nwasi@umich.edu
//last modified July 21,2014

syntax varlist(max=1) [if] [in] [,Patpath(str) WARNingmsg(str)]

if "`patpath'"~="" {
	local mypath "`patpath'"
}
else {
	local dir : sysdir PLUS
	local mypath "`dir'/p/"
}


capture qui findfile  P60_std_numbers.csv, path(`mypath')
marksample touse, strok

if _rc~=0 {
	if "`warningmsg'"!="off" {
	di as error "Warning: Could not find the pattern file P60_std_numbers.csv"
	di as error "         Skip numeral standardization"
	}
	qui replace `varlist' = trim(itrim(`varlist')) if `touse'
}
		
else {
	
local mypattern "`mypath'/P60_std_numbers.csv"

tempvar j
qui gen `j' =  trim(itrim(`varlist'))
	
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

	
