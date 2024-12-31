* multiple occurrences of substrings 
*! 2.0.0 29apr2016 Robert Picard
*! 1.1.2 27mar2011 NJC
*! 1.1.1 25mar2011 NJC
*! 1.1.0 20mar2011 Robert Picard
* 1.0.0 14mar2011 NJC           
program moss

	version 9
	
	syntax varname(string) [if] [in] , ///
	Match(string) ///
	[ ///
	Regex ///
	Prefix(string) ///
	Suffix(string) ///
	MAXimum(string) ///
	Compact ///
	Unicode ///
	]
	
	
	if "`unicode'" != "" {
		if c(stata_version) < 14 {
			dis as err "Unicode support requires Stata version 14 or higher"
			exit 198
		}
		local u u
		local ustr ustr
		local matchlen : ustrlen local match
	}
	else local matchlen : length local match 
	
	if `matchlen' == 0 {
		dis as err "empty string found in match option: " ///
			"nothing to match"
		exit 198
	}
	
	
	if "`prefix'" != "" & "`suffix'" != "" {
		dis as err "prefix and suffix options cannot be combined"
		exit 198
	}
	if "`prefix'`suffix'" == "" local prefix _
	if "`prefix'" != "" {
		capture confirm name `prefix'
		if _rc {
			dis as err "prefix(`prefix') option will yield invalid variable names"
			exit _rc
		}
	}
	
	
	if "`maximum'" != "" {
		capture confirm integer number `maximum'
		if _rc {
			dis as err "integer expected for maximum option"
			exit _rc
		}
		capture assert `maximum' > 0
		if _rc {
			dis as err "maximum must be > 0"
			exit 198
		}
	}
	else local maximum .
	
	
	if "`regex'" != "" {
		// prior to version 13, regexs() trims leading spaces!
		// add a ? character while we parse the pattern
		local match0 `"`match'"'
		local match `"?`match0'"'
		
		// remove escaped parentheses to check the subexpression
		local checkit : subinstr local match "\)" "", all
		local checkit : subinstr local checkit "\(" "", all
		
		if !regexm(`"`checkit'"',"\(.*\)") {
			dis as err "regex option: " ///
				`"no subexpression in match(`match0')"'
			exit 198
		}
		if regexm(`"`checkit'"',"\((.*)\)") local subex = regexs(1)
		if regexm(`"`subex'"',"[()]") {
			dis as err "regex option: " ///
				`"match(`match0') can only contain one subexpression"'
			exit 198
		}
		
		// split match at the end of the subexpression
		if regexm(`"`match'"', "(.*[^\\]\))") local match1 = regexs(1)
		local match2 = regexr(`"`match'"', ".*[^\\]\)", "")
		
		// recombine the pattern with a second subexpression that will capture
		// what comes just after the matched subexpression
		local match `"`match1'(`match2'.*)"'
		
		// remove the leading ? character added because of bug in regexs()
		local match : subinstr local match "?" ""
	}
	

	quietly { 
	
		marksample touse, strok
		count if `touse'
		if r(N) == 0 error 2000 

		tempvar copy count varlen
		clonevar `copy' = `varlist' 
		gen long `count' = 0 if `touse'
		gen long `varlen' = `u'strlen(`copy')
		
		local j = 0 
		local more 1
		
		
		while `more' {
		
			local ++j
			tempvar pos`j'
			
			if "`regex'" != "" {
				tempvar match`j'
				gen `match`j'' = `ustr'regexs(1) if `touse' & ///
					`ustr'regexm(`copy',`"`match'"')
				replace `touse' = 0 if `match`j'' == ""
				replace `copy' = `ustr'regexs(2) if `touse' & ///
					`ustr'regexm(`copy',`"`match'"')
				gen long `pos`j'' = `varlen' - ///
					`u'strlen(`copy') - `u'strlen(`match`j'') + 1 if `touse'
			}
			else {
				capture gen long `pos`j'' = `u'strpos(`copy',`"`match'"') if `touse'
				if _rc { 
					gen long `pos`j'' = `u'strpos(`copy',"`match'") if `touse'
				}
				replace `touse' = 0 if `pos`j'' == 0
				replace `pos`j'' = . if `pos`j'' == 0
				replace `copy' = `u'substr(`copy', ///
					`pos`j''+`matchlen',.) if `touse'
				replace `pos`j'' = ///
					`varlen' - `u'strlen(`copy') - `matchlen' + 1 if `touse'
			}

			replace `count' = `count' + 1 if `touse'				
			compress `pos`j''
				
			count if `touse'
			if r(N) == 0 {
				local --j
				local more 0
			}
			else if `j' == `maximum' local more 0
			
		}

		
		compress `count'
		if "`prefix'" != "" {
			cap confirm new var `prefix'count
			if _rc {
				dis as err "variable `prefix'count already defined: " ///
					"change prefix(`prefix') option"
				error _rc
			}
			rename `count' `prefix'count
			forvalues i = 1/`j' {
				cap confirm new var `prefix'pos`i'
				if _rc {
					dis as err "variable `prefix'pos`i' already defined: " ///
						"change prefix(`prefix') option"
					error _rc
				}
				rename `pos`i'' `prefix'pos`i'
				if "`regex'" != "" rename `match`i'' `prefix'match`i'
			}
		}
		else {
			cap confirm new var count`suffix'
			if _rc {
				dis as err "variable count`suffix' already defined: " ///
					"change suffix(`suffix') option"
				error _rc
			}
			rename `count' count`suffix'
			forvalues i = 1/`j' {
				cap confirm new var pos`i'`suffix'
				if _rc {
					dis as err "variable pos`i'`suffix' already defined: " ///
						"change suffix(`suffix') option"
					error _rc
				}
				rename `pos`i'' pos`i'`suffix'
				if "`regex'" != "" rename `match`i'' match`i'`suffix'
			}
		}
	}
end  
