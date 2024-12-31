capture program drop stnd_specialchar
program define stnd_specialchar 
version 9.2

//written by N Wasi: nwasi@umich.edu
//last modified July 21,2014

syntax varlist(max=1) [if] [in] , [EXCLude(str) TYPE(str) Patpath(str) WARNingmsg(str)	]	

if "`patpath'"~="" {
	local mypath "`patpath'"
}
else {
	local dir : sysdir PLUS
	local mypath "`dir'/p/"
}

marksample touse, strok


tempvar j
qui gen `j' =  trim(itrim(`varlist')) if `touse'
	
// " needs special treatment
qui replace `j' =subinstr(`j',`"""',"",.) 
	
//special actions for company names before removing/replacing with a whitespce
if upper("`type'")=="NAME" {
	capture qui findfile P21_spchar_namespecialcases.csv, path(`mypath')
	if _rc~=0 {
		if "`warningmsg'"!="off" {
			di as error "Warning: Could not find the pattern file P21_spchar_namespecialcases"
			di as error "         No name standardization prior to special-character standardization."
		}
	}		
	else {
	local mypattern21 "`mypath'/P21_spchar_namespecialcases.csv"
	capture close myfile
	file open myfile using "`mypattern21'", read
	file read myfile line
		while r(eof)==0 {
		tokenize `"`line'"', parse(,)		
		//1 = orig; 2 = parse character; 3 = standardized
		qui replace `j' =  subinstr(`j',"`1'","`3'",.) if `touse'
	
		file read myfile line
		}
	file close myfile
	}
}
qui replace `j' = subinstr(`j',"&"," & ",.) if `touse'
	
qui replace `varlist' = trim(itrim(`j')) if `touse'
	

capture qui findfile P22_spchar_remove.csv, path(`mypath')
local P22_rc = _rc
if `P22_rc'~=0 {
	if "`warningmsg'"!="off" {
		di as error "Warning: Could not find the pattern file P22_spchar_remove.csv"
		di as error "         Special characters are not removed."
		di as error "         Subsequent steps may not function properly."
	}	
}		
else {
	local mypattern22 "`mypath'/P22_spchar_remove.csv"
}

capture qui findfile P23_spchar_rplcwithspace.csv, path(`mypath')
local P23_rc = _rc
if `P23_rc'~=0 {
	if "`warningmsg'"!="off" {
	di as error "Warning: Could not find the pattern file P23_spchar_rplcwithspace.csv"
	di as error "         Special characters are not replaced with a whitespace."
	di as error "         Subsequent steps may not function properly."
	}
}		
else {
	local mypattern23 "`mypath'/P23_spchar_rplcwithspace.csv"
}

if `P22_rc'==0 | `P23_rc'==0 {
		
	//if some characters exist in the default pattern files should be excluded
	//for example, we remove # from names as they tend to be an error;
	//but # in address fields signal that it is a street number, or apt number
	if "`exclude'"~="" {
		if `P22_rc'==0 {
		capture file close myfile
		//read characters to remove
		file open myfile using "`mypattern22'", read
		file read myfile line
			while r(eof)==0 {
			qui	replace `j' =subinstr(`j',"`line'","",.) if strpos("`exclude'","`line'")==0 & `touse'
	
			file read myfile line
			}
		file close myfile
		}

		if `P23_rc'==0 {
		capture file close myfile
		//read characters to replace with a whitespace
		file open myfile using "`mypattern23'", read
		file read myfile line2
			while r(eof)==0 {
			qui replace `j' =subinstr(`j',"`line2'"," ",.) if strpos("`exclude'","`line2'")==0 & `touse'
			file read myfile line2
			}
		file close myfile
		}
	} 

	else {
		if `P22_rc'==0 {
		capture file close myfile
		//read characters to remove
		file open myfile using "`mypattern22'", read
		file read myfile line
			while r(eof)==0 {
			qui	replace `j' =subinstr(`j',"`line'","",.)  if `touse'
			file read myfile line
			}
		file close myfile
		}
		
		if `P23_rc'==0 {
		capture file close myfile
		//read characters to replace with a whitespace
		file open myfile using "`mypattern23'", read
		file read myfile line2
			while r(eof)==0 {
			qui replace `j' =subinstr(`j',"`line2'"," ",.)  if `touse'
			file read myfile line2
			}
		file close myfile
		}
	}
}	
qui replace `varlist' = trim(itrim(`j')) if `touse'

end


