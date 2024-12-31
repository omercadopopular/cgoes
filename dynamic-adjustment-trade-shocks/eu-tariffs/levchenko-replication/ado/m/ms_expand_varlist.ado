*! version 2.30.1 18jul2018
program ms_expand_varlist, rclass
	syntax [varlist(ts fv numeric default=none)] if
	fvexpand `varlist' `if'
	loc varlist  `r(varlist)'`'

	foreach part of local varlist {
		_ms_parse_parts `part'
		loc ok = r(omit) == 0
		loc mask `mask' `ok'
		if (`ok') {
			// If we don't run this, st_data will load some columns as vectors of ZEROES (!)
			// EG:
			// set obs 5
			// gen id = _n
			// mata: st_data(., "1.id 2.id") // The 1st column is empty!
			// mata: st_data(., "1bn.id 2.id 3.id") // correct result
			AddBN `part'
			//di as error "AFTER=[`part']"
			loc selected_vars `selected_vars' `part'
		}
		//else {
		//	di as error "OMITTED/BASE: `part'"
		//}
	}

	return local fullvarlist	`varlist'
	return local varlist		`selected_vars'
	return local not_omitted	`mask'
end

capture program drop AddBN
program define AddBN
	loc part `0'

	loc re "^([0-9]+)b?([.LFSD])"
	loc match = regexm("`part'", `"`re'"')
	if (`match') {
		loc part = regexr("`part'", "`re'", regexs(1) + "bn" + regexs(2))
	}

	loc re "#([0-9]+)b?([.LFSD])"
	loc loop = strpos("`part'", "#")
	loc old `part'

	while (`loop') {	
		loc match = regexm("`part'", `"`re'"')
		if (`match') {
			loc part = regexr("`part'", "`re'", "#" + regexs(1) + "bn" + regexs(2))
		}
		loc loop = "`old'" != "`part'"
		loc old `part'
	}

	c_local part `part'
end
