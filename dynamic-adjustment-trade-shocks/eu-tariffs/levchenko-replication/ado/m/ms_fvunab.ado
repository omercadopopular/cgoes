*! version 2.9.0 28mar2017
program ms_fvunab
	* Parse macro name where results are saved
	_on_colon_parse `0'
	local 0 `"`s(before)'"'
	syntax name(local name=user id="macro name")
	local 0 `"`s(after)'"'

	* Parse options
	syntax anything [, NOIsily STRingok]
	if ("`stringok'"=="") loc numeric numeric
	loc 0 `anything'

	* Unab. varlist and expand parenthesis loc without expanding ## interactions
	loc _ : subinstr loc 0 "##" "##", all count(loc n)
	forval i = 1/`n' {
		tempvar hackvar`i'
		gen byte `hackvar`i'' = 0
		loc 0 : subinstr loc 0 "##" "#i.`hackvar`i''#"
		loc hackvars `hackvars' `hackvar`i''
	}

	if ("`noisily'"!="") {
		di as text "- Altered input: `0'"
	}

	syntax varlist(ts fv `numeric')
	if (`n') drop `hackvars'

	forval i = 1/`n' {
		loc varlist : subinstr loc varlist "#i.`hackvar`i''#" "##", all
	}


	if ("`noisily'"!="") {
		di as text "- Number of ## found: {res}`n'"
		loc n : word count `varlist'
		di as text "- Number of variables after expanding parenthesis: {res}`n'"
		di as text "- Output varlist:"
		foreach var of local varlist {
			di as res "    `var'"
		}
	}

	c_local `user' `varlist'
end
