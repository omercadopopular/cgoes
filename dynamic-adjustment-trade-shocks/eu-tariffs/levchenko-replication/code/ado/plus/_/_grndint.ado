*! NJC 1.0.0 21 January 2000
program define _grndint 
	version 6        
        gettoken type 0 : 0
        gettoken g 0 : 0
        gettoken eqs 0 : 0
        gettoken lparen 0 : 0, parse("(")
        gettoken rparen 0 : 0, parse(")")
        syntax [if] [in] , MAx(int) [ MIn(int 1) ] 
	
	if `max' <= `min' { 
		di in r "max(`max') does not exceed min(`min')" 
		exit 198 
	} 	
	
	tempvar touse   
	quietly {
		mark `touse' `if' `in'
		/* ignore user `type' */ 
		if `max' <= 126 & `min' >= -127 { 
			local type "byte" 
		} 
		else if `max' <= 32766 & `min' >= -32767 { 
			local type "int" 
		}
		else local type "long" 
		gen `type' `g' = /* 
		*/ `min' + int((`max' - `min' + 1) * uniform( )) if `touse'  		
	}
end
