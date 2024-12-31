*! 1.0.0 NJC 23 Sept 2002 
program define _gsieve 
	version 7.0

	gettoken type 0 : 0
	gettoken g    0 : 0
	gettoken eqs  0 : 0

	syntax varname(string) [if] [in] /* 
	*/ [, KEEP(str) CHAR(str asis) OMIT(str asis) ] 

	local nopts = ("`keep'" != "") + (`"`char'"' != "") + (`"`omit'"' != "")
	if `nopts' != 1 { 
		di as err "specify keep() or char() or omit()" 
		exit 198 
	} 
	if `"`omit'"' != "" { 
		local char `"`omit'"'
		local not "!" 
	} 	
	
	marksample touse, strok
	local type "str1" /* ignores type passed from -egen- */
	qui gen `type' `g' = ""
	local length : type `varlist' 
	local length = substr("`length'",4,.) 

	if "`keep'" != "" { 
		local a 0 
		local n 0 
		local o 0 
		local s 0 
	
		foreach w of local keep { 
			local l = length("`w'") 
			if substr("alphabetic",1,max(1,`l')) == "`w'" {
	                	local a 1     
		        }
        		else if substr("numeric",1,max(1,`l')) == "`w'" {
	        	        local n 1 
		        }
        		else if substr("other",1,max(1,`l')) == "`w'" {
				local o 1                 
			} 	       
        		else if substr("spaces",1,max(1,`l')) == "`w'" {
	        	        local s 1  
		        }
        		else {
				di as err "keep() invalid" 
				exit 198 
			}
		} 
       
		tempvar c  
	
		quietly {
			gen str1 `c' = "" 
			
			forval i = 1 / `length' {
				replace `c' = substr(`varlist',`i',1) 
		
				if `a' { 
					replace `g' = `g' + `c' /* 
					*/ if ((`c' >= "A" & `c' <= "Z") /* 
					*/ | (`c' >= "a" & `c' <= "z"))
				} 
				if `n' { 
					replace `g' = `g' + `c' /* 
					*/ if (`c' >= "0" & `c' <= "9")
				} 
				if `s' {  
					replace `g' = `g' + `c' if `c' == " " 
				} 
				if `o' { 
					replace `g' = `g' + `c' /* 
					*/ if !( (`c' >= "A" & `c' <= "Z") /* 
					*/ | (`c' >= "a" & `c' <= "z") /* 
					*/ | (`c' >= "0" & `c' <= "9")  /* 				
					*/ | (`c' == " ") ) 
				} 	
			}
		}	
	} 
	else { /* char() or omit() */ 
		forval i = 1 / `length' { 
			qui replace `g' = `g' + substr(`varlist',`i',1) /* 
			*/ if `not'index(`"`char'"', substr(`varlist',`i',1)) 
		} 
	} 

	qui { 
		replace `g' = "" if !`touse' 
		compress `g' 
	} 	
end

