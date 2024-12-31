*! version 2.48.0 29mar2021
program define join

// Parse --------------------------------------------------------------------

	syntax ///
		[anything]  /// Variables that will be added (default is _all unless keepnone is used)
		, ///
		[from(string asis) into(string asis)] /// -using- dataset
		[by(string)] /// Primary and foreign keys
		[KEEP(string)] /// 1 master 2 using 3 match
		[ASSERT(string)] /// 1 master 2 using 3 match
		[GENerate(name) NOGENerate] /// _merge variable
		[UNIQuemaster] /// Assert that -by- is an id in the master dataset
		[noLabel] ///
		[KEEPNone] ///
		[noNOTEs] ///
		[noREPort] ///
		[Verbose] ///
		[METHOD(string)] // empty, or hash0, hash1, etc.

	* Parse details of using dataset
	_assert (`"`from'"' != "") + (`"`into'"' != "") == 1, ///
		msg("specify either from() or into()")
	ParseUsing `from'`into' // Return -filename- and -if-

	* Parse _merge indicator
	_assert ("`generate'" != "") + ("`nogenerate'" != "") < 2, ///
		msg("generate() and nogenerate are mutually exclusive")
	if ("`nogenerate'" == "") {
		if ("`generate'" == "") loc generate _merge
		confirm new variable `generate'
	}
	else {
		tempvar generate
	}

	* Parse booleans
	loc is_from = (`"`from'"' != "")
	loc uniquemaster = ("`uniquemaster'" != "")
	loc label = ("`label'" == "")
	loc notes = ("`notes'" == "")
	loc report = ("`report'" == "")
	loc verbose = ("`verbose'" != "")

	* Parse keep() and assert() requirements
	ParseMerge, keep(`keep') assert(`assert')
	/* Return locals
		keep_using: 1 if we will keep using-only obs
		assert_not_using: 1 to check that there are no using-only obs.
		keep_nums: {1, 3, 1 3} depending on whether we keep master/match
		assert_nums: as above but to assert only these exist (besides using)
		keep_words assert_words: as above but with words instead of nums
	*/

	* Parse -key- variables
	ParseBy `is_from' `by' /// Return -master_keys- and -using_keys-


// Load using  dataset -------------------------------------------------------

	* Load -using- dataset
	if (`is_from') {
		preserve
        if (substr("`filename'", -8, 8) == ".parquet") {
            if ("`anything'" != "" | "`keepnone'" != "") {
                loc vars "`using_keys' `anything' using"
        	}
            cap noi parquet use `vars' "`filename'", clear
            if (_rc != 0) {
				di as err "Parquet reading failed"
                di as err "Try reading parquet file directly to see full error:"
				di as err "    parquet use `vars' `filename'"
                exit _rc
            }
        }
        else {
            use "`filename'", clear
            unab using_keys : `using_keys' // continuation of ParseBy
        }
		if (`"`if'"' != "") qui keep `if'

		loc cmd restore
	}
	else {
		loc cmd `"qui use `if' using "`filename'", clear"'
	}

	if ("`anything'" != "" | "`keepnone'" != "") {
		keep `using_keys' `anything'
	}
	else {
		qui ds `using_keys', not
		loc anything `r(varlist)'
	}
	unab anything : `anything', min(0)


// Join ---------------------------------------------------------------------

	mata: join("`using_keys'", "`master_keys'", "`anything'", ///
	    `"`cmd'"', "`generate'", `uniquemaster', ///
	    `keep_using', `assert_not_using', ///
	    `label', `notes', ///
	    `verbose', "`method'")


// Apply requirements on _merge variable ------------------------------------

	cap la def _merge ///
		1 "master only (1)" 2 "using only (2)" 3 "matched (3)" /// Used
		4 "missing updated (4)" 5 "nonmissing conflict (5)" // Unused
	la val `generate' _merge

	loc msg "merge:  after merge, not all observations from <`assert_words'>"
	if ("`assert_nums'" == "") _assert !inlist(`generate', 1, 3), msg("`msg'")
	if ("`assert_nums'" == "1") _assert !inlist(`generate', 3), msg("`msg'")
	if ("`assert_nums'" == "3") _assert !inlist(`generate', 1), msg("`msg'")

	if ("`keep_nums'" == "") qui drop if inlist(`generate', 1, 3)
	if ("`keep_nums'" == "1") qui drop if inlist(`generate', 3)
	if ("`keep_nums'" == "3") qui drop if inlist(`generate', 1)

	* Adding data should clear the sort order of the master dataset
	if (`keep_using') {
		ClearSortOrder
	}

	if (`report') {
		Table `generate'
	}

	if ("`nogenerate'" != "") {
		label drop _merge
	}
end


program define ParseUsing
	* SAMPLE INPUT: somefile.dta if foreign==true
	gettoken filename if : 0,
	c_local filename `"`filename'"'
	loc if `if' // remove leading/trailing spaces
	c_local if `"`if'"'
end


program define ParseMerge
	syntax, [keep(string) assert(string)]
	if ("`keep'" == "") loc keep "master match using"
	if ("`assert'" == "") loc assert "master match using"
	loc keep_using 0
	loc assert_not_using 1

	loc match_valid `""3", "match", "mat", "matc", "matches", "matched""'

	foreach cat in keep assert {
		loc nums
		loc words
		foreach word of local `cat' {
			if ("`word'"=="1" | substr("`word'", 1, 3) == "mas") {
				loc nums `nums' 1
				loc words `words' master
			}
			else if ("`word'"=="2" | substr("`word'", 1, 2) == "us") {
				if ("`cat'" == "keep") loc keep_using 1
				if ("`cat'" == "assert") loc assert_not_using 0
			}
			else if (inlist("`word'", `match_valid')) {
				loc nums `nums' 3
				loc words `words' match
			}
			else {
				di as error "invalid category: <`word'>"
				error 117
			}
		}
		loc words : list sort words
		loc nums : list sort nums

		if ("`cat'"=="assert" & !`assert_not_using') loc words `words' using

		c_local `cat'_words `words'
		c_local `cat'_nums `nums'
	}
	c_local keep_using `keep_using'
	c_local assert_not_using `assert_not_using'
end


program define ParseBy
	* SAMPLE INPUT: 1 turn trunk
	* SAMPLE INPUT: 0 year=time country=cou
	gettoken is_from 0 : 0 // 1 if used from() , 0 if used into()
	assert inlist(`is_from', 0, 1)
	while ("`0'" != "") {
		gettoken right 0 : 0
		gettoken left right : right, parse("=")
		if ("`right'" != "") {
			gettoken eqsign right : right, parse("=")
			assert "`eqsign'" == "="
		}
		else {
			loc right `left'
		}
		loc master_keys `master_keys' `left'
		loc using_keys `using_keys' `right'
	}
	* Mata functions such as st_vartype() don't play well with abbreviations
	if (`is_from') unab master_keys : `master_keys'
	if (!`is_from') unab using_keys : `using_keys'
	c_local master_keys `master_keys'
	c_local using_keys `using_keys'
end


program define ClearSortOrder
	* Andrew Maurer's trick to clear `: sortedby'
	* copied from fsort.ado
	* see https://github.com/sergiocorreia/ftools/issues/32

	loc sortvar : sortedby
	if ("`sortvar'" != "") {
		loc sortvar : word 1 of `sortvar'
		loc sortvar_type : type `sortvar'
		loc sortvar_is_str = strpos("`sortvar_type'", "str") == 1
		loc val = `sortvar'[1]

		if (`sortvar_is_str') {
			qui replace `sortvar' = cond(mi(`"`val'"'), ".", "") in 1
			qui replace `sortvar' = `"`val'"' in 1
		}
		else {
			qui replace `sortvar' = cond(mi(`val'), 0, .) in 1
			qui replace `sortvar' = `val' in 1
		}
		assert "`: sortedby'" == ""
	}
end


program define Table
	syntax varname

	* Initialize defaults
	loc N 0
	forval i = 1/3 {
		loc m`i' 0
	}

	if (c(N)) {
		tempname freqs values
		tab `varlist', nolabel nofreq matcell(`freqs') matrow(`values')
		loc N = rowsof(`freqs')
		loc is_temp = substr("`varlist'", 1, 2) == "__"
	}

	* Fill actual values
	forval i = 1/`N' {
		loc j = `values'[`i', 1]
		loc m`j' = `freqs'[`i', 1]
		if (!`is_temp') loc v`j' "(`varlist'==`j')"
	}

	* This chunk is based on merge.ado
	di
	di as smcl as txt _col(5) "Result" _col(38) "# of obs."
	di as smcl as txt _col(5) "{hline 41}"
	di as smcl as txt _col(5) "not matched" ///
	        _col(30) as res %16.0fc (`m1'+`m2')
	if (`m1'|`m2') {
	        di as smcl as txt _col(9) "from master" ///
	                _col(30) as res %16.0fc `m1' as txt "  `v1'"
	        di as smcl as txt _col(9) "from using" ///
	                _col(30) as res %16.0fc `m2' as txt "  `v2'"
	        di
	}
    di as smcl as txt _col(5) "matched" ///
    _col(30) as res %16.0fc `m3' as txt "  `v3'"
	di as smcl as txt _col(5) "{hline 41}"
end


findfile "ftools.mata"
include "`r(fn)'"


mata:
mata set matastrict on
//mata set matalnum on

void join(`String' using_keys,
               `String' master_keys,
               `String' varlist,
               `String' cmd,
               `Varname' generate,
               `Boolean' uniquemaster,
               `Boolean' keep_using,
               `Boolean' assert_not_using,
               `Boolean' join_labels,
               `Boolean' join_chars,
               `Boolean' verbose,
               `String' method)
{
	`Varlist'				pk_names, fk_names, varformats
	`Varlist'				varnames_num, varnames_str, deck
	`Varlist'				vartypes_num, vartypes_str
	`Variables'				pk, fk
	`Integer'				N, i, val, j, k
	`Factor'				F
	`DataFrame'				data_num, reshaped_num, data_str, reshaped_str
	`Vector'				index, range, mask

	`Boolean'				integers_only
	`Boolean'				has_using
	`Varname'				var
	`String'				msg

	`StringVector'			varlabels, varvaluelabels, pk_varvaluelabels
	`Dict'					label_values, label_text
	`Vector'				values
	`StringVector'			text
	`String'				label

	`Integer'				old_width, new_width

	`Integer'				num_chars
	`StringMatrix'			chars
	`StringVector'			charnames
	`String'				char_name, char_val

	// Note:
	// - On the -using- dataset the keys will be unique, hence why they are the PKs (primary keys)
	// - On the -master- dataset we allow duplicates (unless -uniquemaster- is set), hence whey they are FKs (foreign keys)

	// Using
	pk_names = tokens(using_keys)
	pk = __fload_data(pk_names)
	N = rows(pk)

	// Assert keys are unique IDs in using
	integers_only = is_integers_only(pk_names, pk)
	F = _factor(pk, integers_only, verbose, method, 0)
	assert_is_id(F, using_keys, "using")

	varnames_num = varnames_str = deck = tokens(varlist)
	vartypes_num = vartypes_str = J(1, cols(deck), "")

	varformats = J(1, cols(deck), "")
	varlabels = J(1, cols(deck), "")
	varvaluelabels = J(1, cols(deck), "")
	pk_varvaluelabels = J(1, cols(pk_names), "")
	label_values = asarray_create("string", 1)
	label_text = asarray_create("string", 1)
	text = ""
	values = .

	if (join_chars) {
		num_chars = rows(st_dir("char", "_dta", "*"))
	}


	for (i=1; i<=cols(deck); i++) {
		var = deck[i]

		// Assert vars are not strings (could allow for it, but not useful)
		if (st_isstrvar(var)) {
			varnames_num[i] = ""
			vartypes_str[i] = st_vartype(var)
		}
		else {
			varnames_str[i] = ""
			vartypes_num[i] = st_vartype(var)
		}


		// Add variable labels, value labels, and assignments
		varformats[i] = st_varformat(var)
		varlabels[i] = st_varlabel(var)
		varvaluelabels[i] = label = st_varvaluelabel(var)
		if (join_labels) {
			if (label != "" ? st_vlexists(label) : 0) {
				st_vlload(label, values, text)
				asarray(label_values, label, values)
				asarray(label_text, label, text)
			}
		}

		if (join_chars) {
			num_chars = num_chars + rows(st_dir("char", var, "*"))
		}
	}

	// Save value labels from the by() variables
	if (join_labels) {
		for (i=1; i<=cols(pk_names); i++) {
			var = pk_names[i]
			label = st_varvaluelabel(var)
			if (label != "" ? st_vlexists(label) : 0) {
				pk_varvaluelabels[i] = label
				st_vlload(label, values, text)
				asarray(label_values, label, values)
				asarray(label_text, label, text)
			}
		}
	}

	// Save chars
	// Note: we are NOT saving chars from the by() variables
	if (join_chars) {
		chars = J(num_chars, 3, "")
		j = 0
		for (k=0; k<=cols(deck); k++) {
			var = k ? deck[k] : "_dta"
			charnames = st_dir("char", var, "*")
			for (i=1 ; i<=rows(charnames); i++) {
				++j
				chars[j, 1] = var
				chars[j, 2] = charnames[i]
				chars[j, 3] = st_global(sprintf("%s[%s]", var, charnames[i]))
			}
		}
	}

	varnames_num = tokens(invtokens(varnames_num))
	varnames_str = tokens(invtokens(varnames_str))
	vartypes_num = tokens(invtokens(vartypes_num))
	vartypes_str = tokens(invtokens(vartypes_str))

	if (cols(varnames_num) > 0) {
		data_num = st_data(., varnames_num) , J(st_nobs(), 1, 3) // _merge==3
	}
	else {
		data_num = J(st_nobs(), 1, 3) // _merge==3
	}

	if (cols(varnames_str) > 0)  {
		data_str = st_sdata(., varnames_str)
	}

	// Master
	stata(cmd) // load (either -restore- or -use-)
	if (cmd != "restore") {
		stata("unab master_keys : " + master_keys) // continuation of ParseBy
		master_keys = st_local("master_keys")
	}

	// Check that variables don't exist yet
	msg = "{err}merge:  variable %s already exists in master dataset\n"
	for (i=1; i<=cols(deck); i++) {
		var = deck[i]
		if (_st_varindex(var) != .) {
			printf(msg, var)
			exit(108)
		}
	}
	if (verbose) printf("{txt}variables added: {res}%s{txt}\n", invtokens(deck))

	fk_names = tokens(master_keys)
	fk = __fload_data(fk_names)
	if (integers_only) {
		integers_only = is_integers_only(fk_names, fk)
	}

	if (verbose) {
		printf("{txt}(integers only? {res}%s{txt})\n", integers_only ? "true" : "false")
	}
	F = _factor(pk \ fk, integers_only, verbose, method, 0)

	// Fill -reshaped_num- matrix with data from -using-
	// 1. Start with the matrix full of MVs, for levels that appear only in -master- (_merge==1)
	reshaped_num = J(F.num_levels, cols(data_num)-1, .) , J(F.num_levels, 1, 1) // _merge==1
	// 2. Get the levels that also appear in -using-
	index = F.levels[| 1 \ N |] // Note that F.levels is unique in 1..N only because the keys are unique in -using-
	// 3. Populate the rows that are also in -using- with the data from using
	reshaped_num[index, .] = data_num
	if (cols(varnames_str) > 0) {
		reshaped_str = J(F.num_levels, cols(data_str), "")
		reshaped_str[index, .] = data_str
	}
	// 4. Rearrange and optionally expand the matrix to conform to the -master- dataset
	index = F.levels[| N+1 \ . |]
	reshaped_num = reshaped_num[index , .]
	if (cols(varnames_str) > 0) {
		reshaped_str = reshaped_str[index , .]
	}

	index = . // conserve memory
	assert(st_nobs() == rows(reshaped_num))
	vartypes_num = vartypes_num, "byte"
	varnames_num = varnames_num, generate
	val = setbreakintr(0)

	st_store(., st_addvar(vartypes_num, varnames_num, 1), reshaped_num)
	if (cols(varnames_str) > 0) {
		st_sstore(., st_addvar(vartypes_str, varnames_str, 1), reshaped_str)
	}

	reshaped_num = reshaped_str = . // conserve memory
	(void) setbreakintr(val)

	// Add labels of new variables
	msg = "{err}(warning: value label %s already exists; values overwritten)"
	for (i=1; i<=cols(deck); i++) {
		var = deck[i]

		// label variable <var> <text>
		if (varlabels[i] != "") {
			st_varlabel(var, varlabels[i])
		}

		st_varformat(var, varformats[i])

		label = varvaluelabels[i]

		if (label != "") {
			// label values <varlist> <label>
			st_varvaluelabel(var, label)

			if (join_labels) {
				// Warn if value label gets overwritten
				if (st_vlexists(label)) {
					printf(msg, label)
				}
				// label define <label> <#> <text> <...>
				st_vlmodify(label,
				            asarray(label_values, label),
				            asarray(label_text, label))
			}
		}
	}

	// Add value labels of by variables
	if (join_labels) {
		for (i=1; i<=cols(pk_names); i++) {
			var = pk_names[i]
			label = pk_varvaluelabels[i]
			if (label == "") continue // Continue if no value label
			if (st_vlexists(label)) printf(msg, label) // Warn
			st_vlmodify(label,
			            asarray(label_values, label),
			            asarray(label_text, label))
			st_varvaluelabel(var, label)
		}
	}

	// Add chars and notes
	if (join_chars) {
		for (i=1; i<=num_chars; i++) {
			var = chars[i, 1]
			char_name = chars[i, 2]
			char_val = chars[i, 3]
			if (anyof(("note0", "iis", "tis", "_TSpanel", "_TStvar", "_TSitrvl", "_TSdelta"), char_name)) {
				continue
			}
			else if (strpos(char_name, "note")==1) {
				stata(sprintf("note %s: %s", var, char_val))
			}
			else {
				st_global(sprintf("%s[%s]", var, char_name), char_val)
			}
		}
	}

	// Add using-only data
	// status_using = 1 (assert not) 2 (drop it) 3 (keep it)
	if (keep_using | assert_not_using) {
		mask = (F.counts[F.levels[| 1 \ N |]] :== 1)
		has_using = any(mask)

		if (assert_not_using & has_using) {
			_error("merge found observations from using")
		}

		if (keep_using & has_using) {

			// Store keys (numeric or string)
			pk = select(pk, mask)
			range = st_nobs() + 1 :: st_nobs() + rows(pk)
			st_addobs(rows(pk))

			if (eltype(pk)=="string") {
				// We might need to recast the variables
				for (i=1; i<=cols(pk); i++) {
					new_width = max(strlen(pk[., i]))
					old_width = strtoreal(substr(st_vartype(fk_names[i]), 4, .))
					if (old_width < new_width) {
						// Recast fails; perhaps there is a bug in recast.ado
						// or a conflict with this program
						// Thus, we resort to a hack
						stata(sprintf("assert mi(%s) in -1", fk_names[i]))
						stata(sprintf(`"replace %s = "%s" in -1"', fk_names[i], " " * new_width))
					}
				}
				st_sstore(range, fk_names, pk)
			}
			else {
				st_store(range, fk_names, pk)
			}

			// Store numeric vars
			data_num = select(data_num, mask)
			data_num[., cols(data_num)] = J(rows(data_num), 1, 2) // _merge==2
			st_store(range, varnames_num, data_num)

			// Store string vars
			if (cols(varnames_str) > 0) {
				data_str = select(data_str, mask)
				st_sstore(range, varnames_str, data_str)
				// Move _merge to the end
				stata("order " + generate + ", last")
			}
		}
	}

	// Ensure that the keys are unique in master
	// (This changes F so must be run at the end)
	if (uniquemaster) {
		F.drop_obs(1 :: N)
		assert_is_id(F, master_keys, "master")
	}

}


`Boolean' is_integers_only(`Varlist' vars, `DataFrame' data)
{
	`Boolean'				integers_only
	`Integer'				i
	`String'				type

	// First look at the variable types
	for (i = integers_only = 1; i <= cols(vars); i++) {
		type = st_vartype(vars[i])
		if (!anyof(("byte", "int", "long"), type)) {
			integers_only = 0
			break
		}
	}

	// However, long IDs can be doubles.
	// If there is only one ID and it's a double, verify if it's an integer
	if (!integers_only & cols(vars)==1 & st_vartype(vars[1]) == "double") {
		integers_only = !any(mod(data, 1)) // all(data :== floor(data))
	}

	return(integers_only)
}


void assert_is_id(`Factor' F, `String' keys, `String' dta)
{
	`String'				msg
	`Boolean'				plural
	plural = length(tokens(keys)) > 1
	msg = sprintf("variable%s %s do%s not uniquely identify observations in the %s data",
	              plural ? "s" : "", keys, plural ? "" : "es", dta)
	if (!F.is_id()) {
		// Graceful error handling, as in The Mata Book (Appendix A.4)
		errprintf(msg)
		exit(459)
		// NotReached
	}
}

end


exit
