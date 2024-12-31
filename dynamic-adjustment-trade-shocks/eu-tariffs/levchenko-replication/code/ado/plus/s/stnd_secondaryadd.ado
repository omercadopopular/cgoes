capture program drop stnd_secondaryadd
program define stnd_secondaryadd
version 9.2

//written by N Wasi: nwasi@umich.edu
//last modified Aug 18, 2014

syntax varlist(max=1) [if] [in] [,Patpath(str) WARNingmsg(str)]


if "`patpath'"~="" {
	local mypath "`patpath'"
}
else {
	local dir : sysdir PLUS
	local mypath "`dir'/p/"
}

capture qui findfile  P131_std_secondaryadd.csv, path(`mypath')
marksample touse, strok

if _rc~=0 {
	if "`warningmsg'"!="off" {
	di as error "Warning: Could not find the pattern file P131_std_secondaryadd.csv"
	di as error "         Skip secondary address standardization."
	}
	qui replace `varlist' = trim(itrim(`varlist')) if `touse'
}		

else {

	local mypattern "`mypath'/P131_std_secondaryadd.csv"

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
