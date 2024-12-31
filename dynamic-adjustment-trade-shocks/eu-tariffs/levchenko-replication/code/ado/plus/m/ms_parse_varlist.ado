*! version 2.30.0 17jul2018
program ms_parse_varlist, rclass
	gettoken depvar 0 : 0, bind	
	fvexpand `depvar'
	loc depvar `r(varlist)'
	loc n : word count `depvar'
	_assert (`n'==1), msg("more than one depvar specified: `depvar'")
	_assert (!strpos("`depvar'", "o.")), msg("the values of depvar are omitted: `depvar'")

	* Extract format of depvar so we can format FEs the same way
	fvrevar `depvar', list
	loc fe_format : format `r(varlist)' // The format of the FEs that will be saved

	* Extract base variables (in case we want to run preserve+keep)
	fvrevar `depvar' `0', list
	loc basevars `r(varlist)'

	return loc depvar `depvar'
	return loc fe_format `fe_format'
	return loc indepvars `0'
	return loc basevars `basevars'
end
