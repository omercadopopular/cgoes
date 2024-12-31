capture program drop parsing_pobox
program define parsing_pobox
version 9.2

//written by N Wasi: nwasi@umich.edu
//last modified Aug 8,2014

syntax varlist(max=1) [if] [in], Generate(str) [Patpath(str) WARNingmsg(str)]

if "`patpath'"~="" {
	local mypath "`patpath'"
}
else {
	local dir : sysdir PLUS
	local mypath "`dir'/p/"
}


capture qui findfile P120_pobox_patterns.csv, path(`mypath')
marksample touse, strok

if _rc~=0 {
		if "`warningmsg'"!="off" {
		di as error "Warning: Could not find the pattern file P120_pobox_patterns.csv"
		di as error "         PO Box is not parsed to into a different component."
		}
		tokenize `generate'
		qui gen `1' = trim(itrim(`varlist')) if `touse'
		qui gen `2' = ""		if `touse'
}

else  {

	local mypattern "`mypath'/P120_pobox_patterns.csv"

	confirm new var `generate'

	tempvar j case a3 b3 b5 c1 c5 boxinfo othinfo
	qui gen `j' = `varlist'
	qui gen `a3' = ""
	qui gen `b3'= ""
	qui gen `b5'= ""
	qui gen `c1'= ""
	qui gen `c5'= ""
	qui gen `boxinfo' = ""
	qui gen `othinfo' = ""
	qui gen `case'=0

	tokenize `generate'
	qui gen `1' = "" if `touse'
	qui gen `2' = "" if `touse'

	qui replace `j' = trim(itrim(`j')) if `touse'
	tempvar done
	qui gen `done'=0 if `touse'
	
	capture file close myfile

	file open myfile using "`mypattern'", read
	
	file read myfile line
	while r(eof)==0 {
		qui replace `case'=0 if `touse'
	
		//3 possible places in the string: stand alone PO Box, PO Box at the beginning +oth info, or oth info + PO Box at the end
		quietly {
		replace `case'=1 if regexm(`j', "^`line'$")==1 & `boxinfo'=="" & `othinfo'=="" & `touse' & `done'==0
		replace `case'=2 if regexm(`j', "^`line' ")==1 & `boxinfo'=="" & `othinfo'=="" & `touse' & `done'==0
		replace `case'=3 if regexm(`j', " `line'$")==1 & `boxinfo'=="" & `othinfo'=="" & `touse' & `done'==0
		replace `done' = 1 if inlist(`case',1,2,3)==1 & `touse'
	
		replace `a3' = regexs(3) if regexm(`j', "`line'")& `case'==1 & `touse'									
		replace `boxinfo' = "BOX"+" "+`a3' if `case'==1 & `touse'
	
		replace `b3' = regexs(3) if regexm(`j', "^`line'([ ])(.*)")  & `case'==2 & `touse'
		replace `b5' = regexs(5) if regexm(`j', "^`line'([ ])(.*)")  & `case'==2 & `touse'
		replace `boxinfo' = "BOX"+" "+`b3' if `case'==2 & `touse'
		replace `othinfo' = `b5' if `case'==2 & `touse'
		
		replace `c1' = regexs(1) if regexm(`j', "(.*)([ ])`line'$") & `case'==3 & `touse'
		replace `c5' = regexs(5) if regexm(`j', "(.*)([ ])`line'$") & `case'==3 & `touse'
		replace `boxinfo' = "BOX"+" "+`c5' if `case'==3 & `touse'
		replace `othinfo' = `c1' if `case'==3 & `touse'
	
		count if `done'==0
		if r(N)>0 file read myfile line
		}
	}
	file close myfile
	
	qui replace `1' = trim(trim(`othinfo')) if `touse' 
	qui replace `2' = trim(trim(`boxinfo')) if `touse' 
	qui replace `1' = trim(trim(`j')) if `boxinfo'=="" & `othinfo'=="" & `touse' 
}
	
end
