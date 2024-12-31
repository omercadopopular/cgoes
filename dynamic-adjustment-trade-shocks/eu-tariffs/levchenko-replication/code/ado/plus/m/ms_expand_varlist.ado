*! version 2.47.0 17mar2021
program ms_expand_varlist, rclass
	syntax [varlist(ts fv numeric default=none)] [if]
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
			//di as error "AFTER=[`part']"
			AddBN `part'
			loc all_vars `all_vars' `part'
			loc selected_vars `selected_vars' `part'
		}
		else {
			loc all_vars `all_vars' `part'
			*di as error "OMITTED/BASE: `part'"
		}
	}

	return local fullvarlist	`varlist'			// i.rep78 -> 1b.rep78   2.rep78   3.rep78
	return local fullvarlist_bn	`all_vars'			// i.rep78 -> 1b.rep78 2bn.rep78 3bn.rep78
	return local varlist		`selected_vars'		// i.rep78 ->          2bn.rep78 3bn.rep78
	return local not_omitted	`mask'				// i.rep78 ->    0        1			1
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
