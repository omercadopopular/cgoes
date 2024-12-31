capture program drop parsing_namefield
program define parsing_namefield
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
confirm new var `generate'

capture qui findfile P10_namecomp_patterns.csv, path(`mypath')
marksample touse, strok

if _rc~=0 {
		if "`warningmsg'"!="off" {
			di as error "Warning: Could not find the pattern file P10_namecomp_patterns.csv"
			di as error "         Company name is not parsed to different components."
		}
		tokenize `generate'
		qui gen `1' = trim(itrim(`varlist')) if `touse'
		qui gen `2' = ""
		qui gen `3' = ""
		qui gen `4' = ""	
}

else  {

local mypattern "`mypath'/P10_namecomp_patterns.csv"

tempvar n1 n5_dba n5_fka n5_attn
qui gen `n1' = "" if `touse'
qui gen `n5_dba' = "" if `touse'
qui gen `n5_fka' = "" if `touse'
qui gen `n5_attn' = "" if `touse'
 
capture file close myfile
file open myfile using "`mypattern'", read
	file read myfile line
	while r(eof)==0 {
	tokenize `"`line'"', parse(,)
	//1=pattern; 2 =, ; 3 = type DBA,FKA or ATTN
	qui replace `n1' = regexs(1) if regexm(`varlist', "(.*)([ ])(`1')([ ])(.*)") & `n1'==""  & `touse'
	qui replace `n5_dba' = regexs(5) if regexm(`varlist', "(.*)([ ])(`1')([ ])(.*)") & `n5_dba'==""  & "`3'"=="DBA"  & `touse'
	qui replace `n5_fka' = regexs(5) if regexm(`varlist', "(.*)([ ])(`1')([ ])(.*)") & `n5_fka'==""  & "`3'"=="FKA"  & `touse'
	qui replace `n5_attn' = regexs(5) if regexm(`varlist', "(.*)([ ])(`1')([ ])(.*)") & `n5_attn'==""  & "`3'"=="ATTN"	 & `touse'
	file read myfile line
	}
file close myfile

tokenize `generate'
qui gen `1' = trim(itrim(`n1')) if `n1'~="" & `touse'
qui replace `1' = `varlist' if `n1'=="" & `touse'
qui gen `2' = trim(itrim(`n5_dba')) if `n5_dba'~="" & `touse'
qui gen `3' = trim(itrim(`n5_fka')) if `n5_fka'~="" & `touse'
qui gen `4' = trim(itrim(`n5_attn')) if `n5_attn'~="" & `touse'
}

end
