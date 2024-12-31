*! ms_fvstrip 1.02 ms 24march2015
*! updated by Sergio Correia on 10Oct2017

*! updated by Sergio Correia on 07jun2018: added r(nobase) and r(fullvarlist) options
*! (So we can report base vars)

// takes varlist with possible FVs and strips out b/n/o notation
// returns results in r(varlist)
// optionally also omits omittable FVs
// options:
//   expand calls fvexpand on full varlist
//   onebyone + expand calls fvexpand on elements of varlist
//   dropomit omits omitted variables from stripped r(varlist)
//   noisily displays the stripped r(varlist)
// _ms_parse_parts (notes):
// type = variable, error, factor, interaction, product
// k_names = #names if interaction or product, otherwise missing (=1)

program define ms_fvstrip, rclass
	version 11
	syntax [anything] [if] , [ dropomit expand onebyone NOIsily addbn]

	if "`expand'"~="" {							//  force call to fvexpand
		if "`onebyone'"=="" {
			// fvexpand is *VERY* slow as it does a -tabulate- internally; avoid it if possible
			if (strpos("`anything'", ".")) {
				fvexpand `anything' `if'				//  single call to fvexpand
				local anything `r(varlist)'
			}
			else {
				unab anything : `anything'
			}
		}
		else {

			// Workaround for i(1 2).x
			while ("`anything'" != "") {
				gettoken vn anything : anything, bind
				if (strpos("`vn'", ".")) {
					fvexpand `vn' `if' //  call fvexpand on items one-by-one
					local newlist `newlist' `r(varlist)'
				}
				else {
					unab vn : `vn'
					local newlist `newlist' `vn'
				}
			}
			local anything	: list clean newlist
		}
	}
	foreach vn of local anything {						//  loop through varnames
		if "`dropomit'"~="" {						//  check & include only if
			_ms_parse_parts `vn'					//  not omitted (b. or o.)

			* Detect omitted variables that are actually base variables
			* Need to be careful because they can be 0b.foreign (simple)
			* or 0b.foreign#1.turn (more complex)
			loc omit_var = `r(omit)'
			loc is_omitted_base 0

			if (`omit_var') {
				if ("`r(type)'" == "factor") {
					loc is_omitted_base = "`r(base)'" == "1"
				}
				else if ("`r(type)'" == "interaction") {
					loc k = r(k_names)
					_assert !mi(`k')
					forval i = 1/`k' {
						if ("`r(base`i')'" == "1") loc is_omitted_base 1
					}
				}
				else {
					return list
					_assert 0, msg("Invalid var. type: `r(type)'")
				}
			}

			if (`is_omitted_base') {
				loc omit_var 0
				loc vn "@`vn'" // HACK: Prefix name by "@"
			}

			if !`omit_var' {
				local unstripped	`unstripped' `vn'	//  add to list only if not omitted
			}


		}
		else {								//  add varname to list even if
			local unstripped		`unstripped' `vn'	//  could be omitted (b. or o.)
		}
	}

// Now create list with b/n/o stripped out

	foreach vn of local unstripped {

		if strpos("`vn'", "@") == 1 {
			loc svn : subinstr loc vn "@" ""
			local fullstripped `fullstripped' `svn'
			loc nobase `nobase' 0
			continue
		}

		local svn ""							//  initialize
		_ms_parse_parts `vn'
		if "`r(type)'"=="variable" & "`r(op)'"=="" {			//  simplest case - no change
			local svn	`vn'
		}
		else if "`r(type)'"=="variable" & "`r(op)'"=="o" {		//  next simplest case - o.varname => varname
			local svn	`r(name)'
		}
		else if "`r(type)'"=="variable" {				//  has other operators so strip o but leave .
			local op	`r(op)'
			local op	: subinstr local op "o" "", all
			if ("`addbn'"!="") ExpandBN `op'
			local svn	`op'`bn'.`r(name)'
		}
		else if "`r(type)'"=="factor" {					//  simple factor variable
			local op	`r(op)'
			local op	: subinstr local op "b" "", all
			local op	: subinstr local op "n" "", all
			local op	: subinstr local op "o" "", all
			if ("`addbn'"!="") ExpandBN `op'
			local svn	`op'`bn'.`r(name)'				//  operator + . + varname
		}
		else if "`r(type)'"=="interaction" {				//  multiple variables
			forvalues i=1/`=r(k_names)' {
				local op	`r(op`i')'
				local op	: subinstr local op "b" "", all
				local op	: subinstr local op "n" "", all
				local op	: subinstr local op "o" "", all
				if ("`addbn'"!="") ExpandBN `op'
				local opv	`op'`bn'.`r(name`i')'		//  operator + . + varname
				if `i'==1 {
					local svn	`opv'
				}
				else {
					local svn	`svn'#`opv'
				}
			}
		}
		else if "`r(type)'"=="product" {
			di as err "ms_fvstrip error - type=product for `vn'"
			exit 198
		}
		else if "`r(type)'"=="error" {
			di as err "ms_fvstrip error - type=error for `vn'"
			exit 198
		}
		else {
			di as err "ms_fvstrip error - unknown type for `vn'"
			exit 198
		}
		local stripped `stripped' `svn'
		local fullstripped `fullstripped' `svn'
		loc nobase `nobase' 1
	}
	
	local stripped	: list retokenize stripped				//  clean any extra spaces
	local fullstripped	: list retokenize fullstripped		//  clean any extra spaces

	
	if "`noisily'"~="" {							//  for debugging etc.
		di as result "varlist=`stripped'"
		di as result "fullvarlist=`fullstripped'"
		di as result "nobase=`nobase'"
	}

	return local varlist	`stripped'					//  return results in r(varnames)
	return local nobase	`nobase'
	return local fullvarlist	`fullstripped'
end

cap pr drop ExpandBN
program ExpandBN
	args op
	// Return -bn- if op is 1/2/3/etc but not if it is F/L/c
	if (!mi(real("`op'"))) loc bn "bn"
	c_local bn `bn'
end
