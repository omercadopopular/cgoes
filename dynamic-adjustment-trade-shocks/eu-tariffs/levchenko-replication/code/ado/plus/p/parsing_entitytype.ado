capture program drop parsing_entitytype
program define parsing_entitytype
version 9.2

//written by N Wasi: nwasi@umich.edu
//last modified July 21,2014

syntax varlist(max=1) [if] [in], Generate(str) [Patpath(str) WARNingmsg(str)]

if "`patpath'"~="" {
	local mypath "`patpath'"
}
else {
	local dir : sysdir PLUS
	local mypath "`dir'/p/"
}

capture qui findfile P90_entity_patterns.csv, path(`mypath')
marksample touse, strok

if _rc~=0 {
		if "`warningmsg'"!="off" {
		di as error "Warning: Could not find the pattern file P90_entity_patterns.csv"
		di as error "         Entity type is not parsed to into a different component."
		}
		tokenize `generate'
		qui gen `1' = trim(itrim(`varlist')) if `touse'
		qui gen `2' = "" if `touse'
		
}

else  {

local mypattern "`mypath'/P90_entity_patterns.csv"

confirm new var `generate'

tempvar n1 n3 tmp
qui gen `n1' = ""
qui gen `n3' = ""
qui gen `tmp'= 0
 
capture file close myfile
file open myfile using "`mypattern'", read
	file read myfile line
	while r(eof)==0 {
	tokenize `"`line'"', parse(,)	
	
		//1 = pattern to search for; 2 = parse character; 3 = exclude pattern
		if "`3'"~="" {
		qui replace `tmp' = 1 if regexm(`varlist',"`3'")==1 & `touse'
		qui replace `n1' = regexs(1) if regexm(`varlist', "`1'$") & `tmp'==0 & `n1'=="" & `touse'
		qui replace `n3' = regexs(3) if regexm(`varlist', "`1'$") & `tmp'==0 & `n3'=="" & `touse'
		qui replace `tmp' = 0 & `touse'
		}
		else {
		qui replace `n1' = regexs(1) if regexm(`varlist', "`1'$") & `n1' =="" & `touse'
		qui replace `n3' = regexs(3) if regexm(`varlist', "`1'$") & `n3' =="" & `touse'
		} 
	
	file read myfile line
	}
file close myfile

tokenize `generate'
qui gen `1' = `varlist' if `n1'=="" & `touse'
qui replace `1' = `n1' if `n1'~="" & `touse'
qui gen `2' = `n3' if `n1'~="" & `touse'

}

end
