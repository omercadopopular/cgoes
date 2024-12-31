capture program drop parsing_add_secondary
program define parsing_add_secondary
version 9.2

//written by N Wasi: nwasi@umich.edu
//last modified Aug 31,2014
syntax varlist(max=1) [if] [in], Generate(str) [Patpath(str) WARNingmsg(str)]

if "`patpath'"~="" {
	local mypath "`patpath'"
}
else {
	local dir : sysdir PLUS
	local mypath "`dir'/p/"
}

capture qui findfile P132_secondaryadd_patterns.csv, path(`mypath')
marksample touse, strok

if _rc~=0 {
		if "`warningmsg'"!="off" {
			di as error "Warning: Could not find the pattern file P132_secondaryadd_patterns.csv"
			di as error "         Secondary address (e.g., unit no or floor level) are not parsed into different components."
		}
		tokenize `generate'
		qui gen `1' = trim(itrim(`varlist'))
		qui gen `2' = ""
		qui gen `3' = ""
		qui gen `4' = ""	
}

else  {

	local mypattern "`mypath'/P132_secondaryadd_patterns.csv"

	confirm new var `generate'
	tempvar j jj case caseold streetinfo unitinfo bldginfo floorinfo othinfo a b c d1 done
	qui gen `j' = `varlist'
	qui gen `jj' = ""
	qui gen `case'=0
	qui gen `caseold'=0
	qui gen `streetinfo'=""
	qui gen `unitinfo'=""
	qui gen `bldginfo'=""
	qui gen `floorinfo'=""
	qui gen `othinfo'=""
	qui gen `a'=""
	qui gen `b'=""
	qui gen `c'=""
	qui gen `d1' = ""
    
	qui replace `j' = trim(itrim(`j')) if `touse'
	qui gen `done'=0 if `touse'
	qui replace `done'=1 if `touse' & `j'==""
		
	capture file close myfile

	file open myfile using "`mypattern'", read
	file read myfile line
 
	while r(eof)==0 {
	
		tokenize `"`line'"', parse(,)
		//1 = pattern  2 = "," 3 = type 4 = "," 5 = position
		quietly {

		replace `caseold' = `case' if `done'==0 & `case'~=0
		replace `case'=0 if  `done'==0
		
		//get remaining characters after extracting some patterns//
		replace `j'= trim(itrim(`jj')) if `caseold'~=0 & `done'==0	
		replace `case'=1 if regexm(`j', "^`1'$")==1 &  `done'==0			
			
		//for {street# street} only find exact and rule out and rule out
		if inlist("`3'","STNUM_ST") {
			replace `done'=1 if `case'==1 & regexm(`j',"^`1'$")==1
			replace `streetinfo' = `j' if regexm(`j',"^`1'$")==1				
		}
			
		else {
			replace `case'=2 if regexm(`j', "^`1' ")==1 &  `done'==0 & `case'==0
			replace `case'=3 if regexm(`j', " `1'$")==1 &  `done'==0 & `case'==0

			*unlikely at the end
			if inlist("`3'","STNUM_BLDG") 	replace `case'=0 if `case'==3 
			
			*unlikely to be at the beginning (but after many rounds, would it be possible?)			
			else if inlist("`3'","APT_BLDG","APT") 	replace `case'=0 if `case'==2 

			
			if inlist("`3'","STNUM_ST_APT","STNUM_ST_BLDG","BLDG_STNUM_ST","STNUM_ST_FL","STNUM_BLDG") {			
			
				//1 = pattern  2 = "," 3 = pattern 4 = "," 5 = position 			
				if inlist("`3'","STNUM_ST_APT") {
					//unitinfo: a = unit type e.g., room or apt; b = unit info e.g., 123
					replace `a' = regexs(`5') if regexm(`j',"^`1'") & (`case'==1|`case'==2) & `done'==0
					replace `b' = regexs(`5'+2) if regexm(`j',"^`1'") & (`case'==1|`case'==2) & `done'==0				
					replace `a' = regexs(`5'+2) if regexm(`j',"(.*)([ ])`1'") & (`case'==3|`case'==4) & `done'==0
					replace `b' = regexs(`5'+2+2) if regexm(`j',"(.*)([ ])`1'") & (`case'==3|`case'==4) & `done'==0
					*non-usual pattern if a or b is blank
					replace `case' = 0 if `a'=="" |`b'==""
					replace `unitinfo' = `a'+" "+`b' if  `case'>0 & `case'<. & `done'==0 & `unitinfo'==""
				}
				
				else if inlist("`3'","STNUM_ST_BLDG","BLDG_STNUM_ST","STNUM_BLDG") {
					replace `a' = regexs(`5') if regexm(`j',"^`1'") & (`case'==1|`case'==2) & `done'==0
					replace `a' = regexs(`5'+2) if regexm(`j',"(.*)([ ])`1'") & (`case'==3|`case'==4) & `done'==0	
					replace `case'=0 if inlist(`a',"STE","")| wordcount(`a')>3 
					replace `bldginfo' = "BLDG" +" "+ `a' if `case'>0 & `case'<. & `done'==0 & `bldginfo'==""			
				}
				
				else if inlist("`3'","STNUM_ST_FL") {
				    replace `a' = regexs(`5') if regexm(`j',"^`1'") & (`case'==1|`case'==2) &  `done'==0
					replace `a' = regexs(`5'+2) if regexm(`j',"(.*)([ ])`1'") & (`case'==3|`case'==4) &  `done'==0							
					replace `case'=0 if inlist(`a',"")| wordcount(`a')>1 
					replace `floorinfo' = "FL" +" "+ `a' if `case'>0 & `case'<.  & `done'==0 & `floorinfo'==""
				}
				
				//extract remaining info//
				if inlist("`3'","STNUM_ST_APT","STNUM_ST_BLDG","STNUM_ST_FL") {
					replace `streetinfo' = regexs(1) if regexm(`j',"^`1'") & (`case'==1|`case'==2) & `done'==0
					replace `streetinfo' = regexs(3) if regexm(`j',"(.*)([ ])`1'$") & (`case'==3|`case'==4) & `done'==0
				}
				else if inlist("`3'","BLDG_STNUM_ST")  {		
					replace `streetinfo' = regexs(5) if regexm(`j',"^`1'") & (`case'==1|`case'==2)& `done'==0
					replace `streetinfo' = regexs(5+2) if regexm(`j',"(.*)([ ])`1'") & (`case'==3|`case'==4) & `done'==0
				}
				
				// separate {street# building here} as the numeric info is more ambiguous				
				if inlist("`3'","STNUM_BLDG") {					
					replace `d1' = regexs(1) if regexm(`j',"^`1'") & (`case'==1|`case'==2) & `done'==0					
					replace `streetinfo' = `streetinfo'+" "+`d1' if `streetinfo'~=""
					replace `streetinfo' = `d1' if `streetinfo'==""					
					replace `jj' = regexs(7) if regexm(`j',"^`1'([ ])(.*)") & `case'==2 & `done'==0					
				}
				else {
					replace `jj' = regexs(8) if regexm(`j',"^`1'([ ])(.*)") & `case'==2 & `done'==0				
					replace `jj' = regexs(1) if regexm(`j',"(.*)([ ])`1'$") & `case'==3 & `done'==0
				}				
			} /*end if inlist involves STNUM_ST*/			
		
			else if inlist("`3'","BLDG_FL","FL_BLDG","BLDG_APT","APT_BLDG") {
				replace `a' = regexs(`5') if regexm(`j',"`1'") &(`case'==1|`case'==2)  & `done'==0
				replace `a' = regexs(`5'+2) if regexm(`j',"(.*)([ ])`1'") &(`case'==3|`case'==4)  & `done'==0				
				replace `b' = regexs(`7') if regexm(`j',"`1'") & (`case'==1|`case'==2)    & `done'==0
				replace `b' = regexs(`7'+2) if regexm(`j',"(.*)([ ])`1'") &(`case'==3|`case'==4)  & `done'==0
				
				if inlist("`3'","BLDG_FL") {
					replace `case'=0 if inlist(`a',"STE","")| wordcount(`a')>3
					replace `bldginfo' = "BLDG" +" "+ `a' if  `case'>0 & `case'<. & `done'==0	& `bldginfo'==""	
					replace `floorinfo' = "FL" +" "+ `b' if `case'>0 & `case'<.   & `done'==0 & `floorinfo'==""
				}
				else if inlist("`3'","FL_BLDG") {
					replace `case'=0 if inlist(`b',"STE","")| wordcount(`b')>3 
					replace `bldginfo' = "BLDG" +" "+ `b' if `case'>0 & `case'<.  & `done'==0	& `bldginfo'==""	
					replace `floorinfo' = "FL" +" "+ `a' if `case'>0 & `case'<.   & `done'==0 & `floorinfo'==""
				}
				else if inlist("`3'","BLDG_APT") {
					replace `c' = regexs(`7'+2) if regexm(`j',"^`1'") & (`case'==1|`case'==2)    & `done'==0
					replace `c' = regexs(`7'+2+2) if regexm(`j',"(.*)([ ])`1'") &(`case'==3|`case'==4)  & `done'==0
					replace `case'=0 if inlist(`a',"STE","")| wordcount(`a')>3 |`b'==""|`c'==""
					replace `bldginfo' = "BLDG" +" "+ `a' if `case'>0 & `case'<. & `done'==0 & `bldginfo'==""
					replace `unitinfo' = `b'+" "+`c' if `case'>0 & `case'<. & `done'==0 & `unitinfo'==""
				}
				
				else if inlist("`3'","APT_BLDG") {
				    
					replace `a' = regexs(`5') if regexm(`j',"^`1'") &(`case'==1|`case'==2)  & `done'==0
					replace `a' = regexs(`5'+2) if regexm(`j',"(.*)([ ])`1'") &(`case'==3|`case'==4)  & `done'==0					
					replace `b' = regexs(`5'+2) if regexm(`j',"^`1'") & (`case'==1|`case'==2)    & `done'==0
					replace `b' = regexs(`5'+2+2) if regexm(`j',"(.*)([ ])`1'") &(`case'==3|`case'==4)  & `done'==0
					replace `c' = regexs(`7') if regexm(`j',"`1'") & (`case'==1|`case'==2)    & `done'==0
					replace `c' = regexs(`7'+2) if regexm(`j',"(.*)([ ])`1'") &(`case'==3|`case'==4)  & `done'==0
					replace `case'=0 if inlist(`c',"STE","")| wordcount(`c')>3 |`a'=="" |`b'==""
					
					replace `bldginfo' = "BLDG" +" "+ `c' if `case'>0 & `case'<. & `done'==0 & `bldginfo'==""
					replace `unitinfo' = `a'+" "+`b' if `case'>0 & `case'<. & `done'==0 & `unitinfo'==""
					
				}
				
				replace `jj' = regexs(9) if regexm(`j',"^`1'([ ])(.*)") & `case'==2 & `done'==0
				replace `jj' = regexs(1) if regexm(`j',"(.*)([ ])`1'$") & `case'==3 & `done'==0
				
		
			} /*end if inlist two combo of BLDG,FL,APT*/
			
			else if inlist("`3'","APT","BLDG","FL") {
			
				replace `a' = regexs(`5') if regexm(`j',"^`1'") & (`case'==1|`case'==2) & `done'==0
				replace `a' = regexs(`5'+2) if regexm(`j',"(.*)([ ])`1'") & `case'==3 & `done'==0
			
				if inlist("`3'","APT") {					
					replace `b' = regexs(`5'+2) if regexm(`j',"^`1'") & (`case'==1|`case'==2) & `done'==0
					replace `b' = regexs(`5'+2+2) if regexm(`j',"(.*)([ ])`1'") & `case'==3 & `done'==0	
					replace `case'=0 if `a'=="" | `b'==""
					replace `unitinfo' = `a'+" "+`b' if  `case'>0 & `case'<. & `unitinfo'=="" & `done'==0				
				}
				else if inlist("`3'","BLDG") {
					replace `case'=0 if inlist(`a',"STE","")| wordcount(`a')>3 
					replace `bldginfo' = "BLDG" +" "+ `a' if `case'>0 & `case'<.  & `done'==0 & `bldginfo'==""
				}
				else if inlist("`3'","FL") {
					replace `case'=0 if inlist(`a',"")| wordcount(`a')>1 
					replace `floorinfo' = "FL" +" "+ `a' if `case'>0 & `case'<. & `done'==0 & `floorinfo'==""					
				}
				
				qui replace `jj' = regexs(5) if regexm(`j',"^`1'([ ])(.*)") & `case'==2  & `done'==0	
				qui replace `jj' = regexs(1) if regexm(`j',"(.*)([ ])`1'") & `case'==3  & `done'==0				
			}
		} //else STNUM_ST	
		replace `done'=1 if `case'==1 
		count if `done' ==0
			if r(N)>0 {
			file read myfile line
			replace `a'=""
			replace `b'=""
			replace `c'=""
			replace `d1'=""				
		}
			}
		} //end quietly block

	file close myfile
	
	tokenize `generate'

	qui replace `othinfo'=`streetinfo' if `streetinfo'~=""
	qui replace `othinfo'= `othinfo'+" "+`jj' if `done'==0
	qui replace `othinfo' = trim(itrim(`othinfo'))
	qui replace `othinfo' = trim(itrim(`varlist')) if `othinfo'==""&`unitinfo'==""&`bldginfo'==""&`floorinfo'==""  & `touse'
	
	qui replace `unitinfo' = subinword(`unitinfo',"UNIT#","NO",.)
	qui replace `unitinfo' = subinword(`unitinfo',"#","NO",.)
	qui replace `unitinfo' = subinword(`unitinfo',"UNIT","NO",.)

			
	qui gen `1' = trim(itrim(`othinfo')) if `touse'
	qui gen `2' = trim(itrim(`unitinfo')) if `touse'
	qui gen `3' = trim(itrim(`bldginfo')) if `touse'
	qui gen `4' = trim(itrim(`floorinfo')) if `touse'
	
}

end
