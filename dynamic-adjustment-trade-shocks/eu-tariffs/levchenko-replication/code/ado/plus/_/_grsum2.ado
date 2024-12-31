*! 1.0.1 16jul2002 Steven Stillman 
* NJC minor edits 16 July 2002 
* version 1.0    12jul2002   Steven Stillman
* created as an extension to version 2.1.3  26jun2000 of _grsum
* adds options to exclude observations with missing values on 
* either any or all of the variables chosen
program define _grsum2
	version 6
 
	gettoken type 0 : 0
	gettoken g    0 : 0
	gettoken eqs  0 : 0
 
	syntax varlist(numeric) [if] [in] [, BY(string) ANYMiss ALLMiss ]
	if `"`by'"' != "" {
		_egennoby rsum() `"`by'"'
		/* NOTREACHED */
	}
 
	if "`anymiss'" != "" & "`allmiss'" != "" {
		di as err "cannot use anymiss and allmiss options together"
		exit 198
	} 
 
	quietly { 
		tempvar nmiss
		local nvar: word count `varlist'
		tokenize `varlist'
		gen `nmiss' = `1' == . `if' `in'
		gen `type' `g' = cond(`1' == . , 0, `1') `if' `in'
                mac shift 
		
                while "`1'" != "" {
			replace `nmiss' = `nmiss' + (`1' == .) `if' `in'
			replace `g' = `g' + cond(`1' == ., 0, `1') `if' `in'
			mac shift 
		}
			
 		if "`anymiss'" != "" { 
			replace `g' = . if `nmiss' > 0
		} 
		else if "`allmiss'" != "" { 
			replace `g' = . if `nmiss' == `nvar' 
		} 
	}	
end

