capture program drop stnd_smallwords
program define stnd_smallwords
version 9.2

//written by N Wasi: nwasi@umich.edu
//last modified Aug 29,2014

syntax varlist(max=1) [if] [in] [,Patpath(str) Type(str) WARNingmsg(str)]

if "`patpath'"~="" {
	local mypath "`patpath'"
}
else {
	local dir : sysdir PLUS
	local mypath "`dir'/p/"
}

capture qui findfile  P81_std_smallwords_all.csv, path(`mypath')
marksample touse, strok

if _rc~=0 {
	if "`warningmsg'"!="off" {
	di as error "Warning: Could not find the pattern file P81_std_smallwords_all.csv"
	di as error "         Skip small words standardization"
	}
	qui replace `varlist' = trim(itrim(`varlist')) if `touse'
}		

else {

	local mypattern "`mypath'/P81_std_smallwords_all.csv"
	tempvar j
qui gen `j' =  trim(itrim(`varlist'))

capture file close myfile
file open myfile using "`mypattern'", read
	file read myfile line
	while r(eof)==0 {
	tokenize `"`line'"', parse(,)
	//1 = orig; 2 = parse character; 3 = standardized
	qui replace `j' =  subinword(`j',"`1'","`3'",.) if `j'~="`1'" & `touse'
	
	file read myfile line		
	}
	file close myfile
	qui replace `varlist' = trim(itrim(`j')) if `touse'
}

if "`type'"=="address" {
	capture qui findfile  P82_std_smallwords_address.csv, path(`mypath')
	if _rc~=0 {
		if "`warningmsg'"!="off" {
		di as error "Warning: Could not find the pattern file P82_std_smallwords_address.csv"
		di as error "         Skip small words standardization"
		}
		qui replace `varlist' = trim(itrim(`varlist')) if `touse'
	}		

	else {
	
	local mypattern2 "`mypath'/P82_std_smallwords_address.csv"

	tempvar j
	qui gen `j' =  trim(itrim(`varlist'))

	capture file close myfile
	file open myfile using "`mypattern2'", read
	file read myfile line
		while r(eof)==0 {
		tokenize `"`line'"', parse(,)
		//1 = orig; 2 = parse character; 3 = standardized
		qui replace `j' =  subinword(`j',"`1'","`3'",.) if `j'~="`1'" & regexm(`j',"`1'[ ]&")==0 & `touse'
		//remove the first word if it appears to be something like ("AT AT & T")
		qui replace `j' =  subinword(`j',"`1'","`3'",1) if `j'~="`1'" & regexm(`j',"`1'[ ]`1'[ ]&")==1 & `touse'		
		
		file read myfile line		
	}
	file close myfile
	qui replace `varlist' = trim(itrim(`j')) if `touse'
	}
}
	
end
