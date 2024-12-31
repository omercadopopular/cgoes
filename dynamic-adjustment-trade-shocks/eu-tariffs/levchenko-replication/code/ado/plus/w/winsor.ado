*! 1.3.0 NJC 20 Feb 2002 
* 1.2.0 NJC 9 Feb 2001 
* 1.1.0 NJC 23 Nov 1998
* works with strings: not obviously useful, but the generalisation is cheap
* bug fix if p small implies h of 0
* 1.0.0 NJC 18 Nov 1998
program def winsor, sortpreserve 
        version 7.0
        syntax varname [if] [in] /* 
	*/ , Generate(str) [ H(int 0) P(real 0) LOWonly HIGHonly ] 

        capture confirm new variable `generate'
	if _rc { 
		di as err "generate() should give new variable name"
		exit _rc
	}	
		
	if `h' == 0 & `p' == 0 {
                di as err "h() or p() option required, h( ) or p() > 0"
                exit 198
        }
        else if `h' > 0 & `p' > 0 {
                di as err "use either h() option or p() option"
                exit 198
        }
        else if `h' < 0 | `p' < 0 {
                di as err "invalid negative value"
                exit 198
        }

        if `p' >= 0.5 {
                di as err "p() too high"
                exit 198
        }
	
	marksample touse, strok
	qui count if `touse'
	if r(N) == 0 { error 2000 } 
        local use = r(N)
        local notuse = _N - `use'

	if "`lowonly'`highonly'" != "" { 
		local text = /*
		*/ cond("`lowonly'" != "", ", low only", ", high only")
	} 	
	
        if `p' > 0  {
                local h = int(`p' * `use')
                if `h' == 0 {
                        di as err "0 values to be Winsorized"
                        exit 198
                }
                local which "Winsorized fraction `p'`text'"
        }
        else local which "Winsorized extreme `h'`text'"

        if `h' >= (`use' / 2) {
                di as err "`h' values to be Winsorized, `use' in data"
                exit 198
        }

        sort `touse' `varlist'
        local type : type `varlist'
        qui gen `type' `generate' = `varlist' if `touse'

        if "`lowonly'" == "" { 
		* replace upper tail by highest acceptable value
		local hiacc = _N - `h'
		local hiaccp1 = `hiacc' + 1
		qui replace `generate' = `generate'[`hiacc'] in `hiaccp1'/l
	}

	if "`highonly'" == "" { 
	        * replace lower tail by lowest acceptable value
        	local loacc = `notuse' + `h' + 1
	        local loaccm1 = `loacc' - 1
        	local lowest = `notuse' + 1
	        qui replace `generate' = /* 
		*/ `generate'[`loacc'] in `lowest'/`loaccm1'
	}	

        local fmt : format `varlist'
        format `generate' `fmt'

        label var `generate' "`varlist', `which'"
end
