*! 2.4.0  22aug2005  njc
*! 2.3.0  01feb2001  njc/jw  STB-60 dm88
program renvars
 	version 8 

	// "/" is allowed, but not documented
 	gettoken oldvars 0 : 0 , parse("\/,")
 	if `"`oldvars'"' == "\" | `"`oldvars'"' == "/" | `"`oldvars'"' == "," {
 		local 0 `"`oldvars' `0'"'
 		local oldvars "_all"
 	}
 	unab oldvars : `oldvars'
 	local nold : word count `oldvars'
 	tokenize `oldvars'

 	gettoken punct 0 : 0, parse("\/,")

 	if `"`punct'"' != "\" & `"`punct'"' != "/" & `"`punct'"' != "," {
 		di as err "illegal syntax: "  ///
			`""\ varlist" or transformation option expected"'
 		exit 198
 	}

 	if `"`punct'"' == "\" | `"`punct'"' == "/" {  /* one-to-one mapping */

 		syntax newvarlist [, Display TEST ]
 		local nnew : word count `varlist'
 		if `nold' != `nnew' {
 			di as err ///
				"lists of old and new varnames unequal in length"
 			exit 198
 		}
 		local newvars `varlist'
 	}

 	else if `"`punct'"' == "," {                  /* transformation */

 		local 0 ", `0'"
 		syntax , [ Upper Lower PREFix(str) POSTFix(str)      ///
 		SUFFix(str) PRESub(str) POSTSub(str) SUBst(str)      /// 
 		PREDrop(str) POSTDrop(str) Trim(str) TRIMEnd(str)    ///
 		Map(str asis) SYmbol(str) Display TEST ]

		if `"`symbol'"' == "" local symbol "@"
		
		if `"`map'"' != "" & !index(`"`map'"',`"`symbol'"') {
			di as err `"map() does not contain `symbol'"'
			exit 198
		}

		// suffix is a synonym for postfix; issuing both
		// is not an error, so long as they agree
		if `"`suffix'"' != "" {
			if `"`postfix'"' != "" & `"`postfix'"' != `"`suffix'"' {
				di as err "postfix() and suffix() differ"
				exit 198
			}
			local postfix `"`suffix'"'
			local suffix
		}

 		local nopt : word count `upper' `lower' `prefix' ///
 		`postfix' `suffix' `predrop' `postdrop' `trim' `trimend'
		local nopt = ///
			`nopt' + (`"`map'"' != "") + (`"`presub'"' != "") ///
			+ (`"`postsub'"' != "") + (`"`subst'"' != "")
 		if `nopt' != 1 {
 			di as err ///
				"exactly one transformation option should be specified"
 			exit 198
 		}

 		if `"`subst'"' != "" {
 			local srch : word 1 of `subst'
 			local repl : word 2 of `subst'
 		}
 		if `"`presub'"' != "" {
 			local srch : word 1 of `presub'
 			local repl : word 2 of `presub'
 			local nsrch = length(`"`srch'"')
 		}
 		if `"`postsub'"' != "" {
 			local srch : word 1 of `postsub'
 			local repl : word 2 of `postsub'
 			local nsrch = length(`"`srch'"')
 		}

 		// varlist is already tokenized
		local i 1
		local oldvars
		local newvars
 		while "``i''" != "" {
 			if "`upper'" != "" {
				local newname = upper("``i''")
			}	
 			else if "`lower'" != "" {
				local newname = lower("``i''")
			}	
 			else if `"`prefix'"' != "" {
				local newname `"`prefix'``i''"'
			}	
 			else if `"`postfix'"'  != "" {
				local newname `"``i''`postfix'"'
			}	
 			else if `"`subst'"' != "" {
 				local newname : ///
 					subinstr local `i' `"`srch'"' `"`repl'"', all
 			}
 			else if `"`presub'"' != "" {
 				if "`srch'" == substr("``i''",1,`nsrch') {
					local newname = /// 
 						`"`repl'"' + substr("``i''", `nsrch' + 1, .)
 				}
 				else local newname ``i''
 			}
 			else if `"`postsub'"' != "" {
 				if `"`srch'"' == substr("``i''",-`nsrch',.) {
 					local newname = ///
						substr("``i''",1,length("``i''")-`nsrch') + `"`repl'"'
				}
 				else local newname ``i''
 			}
 			else if `"`predrop'"' != "" {
 				confirm integer number `predrop'
 				local newname = substr("``i''", 1 + `predrop', .)
 			}
 			else if `"`postdrop'"' != "" {
 				confirm integer number `postdrop'
 				local newname = /// 
					substr("``i''", 1, length("``i''") - `postdrop')
 			}
 			else if `"`trim'"' != "" {
 				confirm integer number `trim'
 				local newname = substr("``i''", 1, `trim')
 			}
 			else if `"`trimend'"' != "" {
 				confirm integer number `trimend'
				if `trimend' <= length("``i''") { 
	 				local newname = substr("``i''", -`trimend', .)
				}
				else local newname "``i''" 
 			}
 			else if `"`map'"' != "" {
				// build expression
				local newname : ///
					subinstr local map "`symbol'" "``i''", all
				// evaluate expression
				capture local newname = `newname'
				if _rc {
					di as err "inappropriate map?"
					exit _rc
				}
			}
			if "``i''" != "`newname'" {
				local oldvars `oldvars' ``i''
				local newvars `newvars' `newname'
			}
 			local ++i 
 		}

		// check whether newlist consists of all new names
		if `"`newvars'"' != "" {
			confirm new var `newvars'
			tokenize `oldvars'
		}
		else {
			di as txt "no renames necessary"
			exit 0
		}
 	} /* end of syntax processing for transformation */

	if "`test'" == "" {
		nobreak {
			local nold : word count `oldvars'
	 		forv i = 1 / `nold' {
 				local newname : word `i' of `newvars'
 				if "`display'" != "" {
 					di as txt "  {ralign 32:``i''} -> `newname'"
	 			}
	 			rename ``i'' `newname'
			}
		}
	}
	else {
		di as txt ///
			"specification would result in the following renames:"
		local nold : word count `oldvars'
		forv i = 1 / `nold' {
 			local newname : word `i' of `newvars'
 			di as txt "  {ralign 32:``i''} -> `newname'"
		}
	}
end
exit

