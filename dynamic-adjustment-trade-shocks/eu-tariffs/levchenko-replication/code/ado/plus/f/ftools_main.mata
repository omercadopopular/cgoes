// Main class ---------------------------------------------------------------
mata:

class Factor
{
	`Integer'				num_levels			// Number of levels
	`Integer'				num_obs				// Number of levels
	`Varname'				touse				// Name of touse variable
	`Varlist'				varlist				// Variable names of keys
	`Varlist'				varformats, varlabels, varvaluelabels, vartypes
	`Dict'					vl
	`Vector'				levels				// levels that match the keys
	`DataRow'				keys				// Set of keys found
	`Vector'				counts				// Count of the levels/keys
	`Matrix'				info
	`Vector'				p
	`Vector'				inv_p				// inv_p = invorder(p)
	`String'				method				// Hash fn used
	//`Vector'				sorted_levels
	`Boolean'				is_sorted			// Is varlist==sorted(varlist)?
	`StringRowVector'		sortedby			// undocumented; save sort order of dataset
	`Boolean'				panel_is_setup
	`Boolean'				levels_as_keys		// when running F3=join_factors(F1, F2), use the levels of F1/F2 as keys for F3 (useful when F1.keys is missing)

	`Void'					new()
	`Void'					swap()
	virtual `Void'			panelsetup()		// aux. vectors
	`Void'					store_levels()		// Store levels in the dta
	`Void'					store_keys()		// Store keys & format/lbls
	`DataFrame'				sort()				// Initialize panel view
	`Void'					_sort()				// as above but in-place
	`DataFrame'				invsort()			// F.invsort(F.sort(x))==x

	`Boolean'				nested_within()		// True if nested within a var
	`Boolean'				equals()			// True if F1 == F2

	`Void'					__inner_drop()		// Adjust to dropping obs.
	virtual `Vector'		drop_singletons()	// Adjust to dropping obs.
	virtual `Void'			drop_obs()			// Adjust to dropping obs.
	`Void'					keep_obs()			// Adjust to dropping obs.
	`Void'					drop_if()			// Adjust to dropping obs.
	`Void'					keep_if()			// Adjust to dropping obs.
	`Boolean'				is_id()				// 1 if all(F.counts:==1)

	`Vector'				intersect()			// 1 if Y intersects with F.keys
	virtual `Void'			cleanup_before_saving() // set .vl and .extra to missing

	`Dict'					extra				// keep for compatibility with reghdfe v5
}


`Void' Factor::new()
{
	keys = J(0, 1, .)
	varlist = J(1, 0, "")
	info = J(0, 2, .)
	counts = J(0, 1, .)
	p = J(0, 1, .)
	inv_p = J(0, 1, .)
	touse = ""
	panel_is_setup = 0
	is_sorted = 0
	extra = asarray_create("string", 1, 20) // keep for compatibility with reghdfe v5
}


`Void' Factor::swap(`Factor' other)
{
	::swap(this.num_levels, other.num_levels)
	::swap(this.num_obs, other.num_obs)
	::swap(this.touse, other.touse)
	::swap(this.varlist, other.varlist)
	::swap(this.varformats, other.varformats)
	::swap(this.varlabels, other.varlabels)
	::swap(this.varvaluelabels, other.varvaluelabels)
	::swap(this.vartypes, other.vartypes)
	::swap(this.vl, other.vl)
	::swap(this.levels, other.levels)
	::swap(this.keys, other.keys)
	::swap(this.counts, other.counts)
	::swap(this.info, other.info)
	::swap(this.p, other.p)
	::swap(this.inv_p, other.inv_p)
	::swap(this.method, other.method)
	::swap(this.is_sorted, other.is_sorted)
	::swap(this.sortedby, other.sortedby)
	::swap(this.panel_is_setup, other.panel_is_setup)
}


`Void' Factor::panelsetup()
{
	// Fill out F.info and F.p
	`Integer'				level
	`Integer'				obs
	`Vector'				index

	if (panel_is_setup) return

	assert(is_sorted==0 | is_sorted==1)

	if (counts == J(0, 1, .)) {
		_error(123, "panelsetup() requires the -counts- vector")
	}

	if (num_levels == 1) {
		info = 1, num_obs
		p = 1::num_obs
		panel_is_setup = 1
		return
	}

	// Equivalent to -panelsetup()- but faster (doesn't require a prev sort)
	info = runningsum(counts)
	index = 0 \ info[|1 \ num_levels - 1|]
	info = index :+ 1 , info

	assert_msg(rows(info) == num_levels & cols(info) == 2, "invalid dim")
	assert_msg(rows(index) == num_levels & cols(index) == 1, "invalid dim")

	if (!is_sorted) {
		// Compute permutations. Notes:
		// - Uses a counting sort to achieve O(N) instead of O(N log N)
		//   See https://www.wikiwand.com/en/Counting_sort
		// - A better implementation can make this parallel for num_levels small

		p = J(num_obs, 1, .)
		for (obs = 1; obs <= num_obs; obs++) {
			level = levels[obs]
			p[index[level] = index[level] + 1] = obs
		}
	}
	panel_is_setup = 1
}


`DataFrame' Factor::sort(`DataFrame' data)
{
	assert_msg(rows(data) ==  num_obs, "invalid data rows")
	if (is_sorted) return(data)
	panelsetup()

	// For some reason, this is much faster that doing it in-place with collate
	return(cols(data)==1 ? data[p] : data[p, .])
}


`Void' Factor::_sort(`DataFrame' data)
{
	if (is_sorted) return(data)
	panelsetup()
	assert_msg(rows(data) ==  num_obs, "invalid data rows")
	_collate(data, p)
}


`DataFrame' Factor::invsort(`DataFrame' data)
{
	assert_msg(rows(data) ==  num_obs, "invalid data rows")
	if (is_sorted) return(data)
	panelsetup()
	if (inv_p == J(0, 1, .)) inv_p = invorder(p)

	// For some reason, this is much faster that doing it in-place with collate
	return(cols(data)==1 ? data[inv_p] : data[inv_p, .])
}


`Void' Factor::store_levels(`Varname' newvar)
{
	`String'				type
	type = (num_levels<=100 ? "byte" : (num_levels <= 32740 ? "int" : "long"))
	__fstore_data(levels, newvar, type, touse)
}


`Void' Factor::store_keys(| `Integer' sort_by_keys)
{
	`String'				lbl
	`Integer'				i
	`StringRowVector'		lbls
	`Vector'				vl_keys
	`StringVector'			vl_values
	if (sort_by_keys == .) sort_by_keys = 0
	if (st_nobs() != 0 & st_nobs() != num_levels) {
		_error(198, "cannot save keys in the original dataset")
	}
	if (st_nobs() == 0) {
		st_addobs(num_levels)
	}
	assert(st_nobs() == num_levels)

	// Add label definitions
	lbls = asarray_keys(vl)
	for (i = 1; i <= length(lbls); i++) {
		lbl = lbls[i]
		vl_keys = asarray(asarray(vl, lbl), "keys")
		vl_values = asarray(asarray(vl, lbl), "values")
		st_vlmodify(lbl, vl_keys, vl_values)
	}

	// Add variables
	if (substr(vartypes[1], 1, 3) == "str") {
		st_sstore(., st_addvar(vartypes, varlist, 1), keys)
	}
	else {
		st_store(., st_addvar(vartypes, varlist, 1), keys)
	}

	// Add formats, var labels, value labels
	for (i = 1; i <= length(varlist); i++) {
		st_varformat(varlist[i], varformats[i])
		st_varlabel(varlist[i], varlabels[i])
		if (st_isnumvar(varlist[i])) {
			st_varvaluelabel(varlist[i], varvaluelabels[i])
		}
	}

	// Sort
	if (sort_by_keys) {
		stata(sprintf("sort %s", invtokens(varlist)))
	}
}


`Boolean' Factor::nested_within(`DataCol' x)
{
	`Integer'				i, j
	`DataCell'				val, prev_val, mv
	`DataCol'				y

	mv = missingof(x)
	y = J(num_levels, 1, mv)
	assert(rows(x) == num_obs)
	
	assert(!anyof(x, mv))
	//assert(eltype(x)=="string" | eltype(x)=="real")
	//if (eltype(x)=="string") {
	//	assert_msg(!anyof(x, ""), "string vector has missing values")
	//}
	//else {
	//	assert_msg(!hasmissing(x), "real vector has missing values")
	//}

	for (i = 1; i <= num_obs; i++) {
		j = levels[i] // level of the factor associated with obs. i
		prev_val = y[j] // value of x the last time this level appeared
		if (prev_val == mv) {
			y[j] = x[i]
		}
		else if (prev_val != x[i]) {
			return(0)
		}
	}
	return(1)
}


`Boolean' Factor::equals(`Factor' F)
{
	if (num_obs != F.num_obs) return(0)
	if (num_levels != F.num_levels) return(0)
	if (keys != F.keys) return(0)
	if (counts != F.counts) return(0)
	if (levels != F.levels) return(0)
	return(1)
}


`Void' Factor::keep_if(`Vector' mask)
{
	drop_obs(`selectindex'(!mask))
}


`Void' Factor::drop_if(`Vector' mask)
{
	drop_obs(`selectindex'(mask))
}


`Void' Factor::keep_obs(`Vector' idx)
{
	`Vector'				tmp
	tmp = J(num_obs, 1, 1)
	tmp[idx] = J(rows(idx), 1, 0)
	drop_obs(`selectindex'(tmp))
}


`Void' Factor::drop_obs(`Vector' idx)
{
	`Integer'				i, j, num_dropped_obs
	`Vector'				offset

	// assert(all(idx :>0))
	// assert(all(idx :<=num_obs))

	if (counts == J(0, 1, .)) {
		_error(123, "drop_obs() requires the -counts- vector")
	}

	num_dropped_obs = rows(idx)
	if (num_dropped_obs==0) return

	// Decrement F.counts to reflect dropped observations
	offset = levels[idx] // warning: variable will be reused later
	assert(rows(offset)==num_dropped_obs)
	for (i = 1; i <= num_dropped_obs; i++) {
		j = offset[i]
		counts[j] = counts[j] - 1
	}
	// assert(all(counts :>= 0))
	
	// Update contents of F based on just idx and the updated F.counts
	__inner_drop(idx)
}


// This is an internal method that updates F based on 
// i) the list of dropped obs, ii) the *already updated* F.counts
`Void' Factor::__inner_drop(`Vector' idx)
{
	`Vector'				dropped_levels, offset
	`Integer'				num_dropped_obs, num_dropped_levels

	num_dropped_obs = rows(idx)

	// Levels that have a count of 0 are now dropped
	dropped_levels = `selectindex'(!counts) // select i where counts[i] == 0
	// if we use rows() instead of length(), dropped_levels would be J(1,0,.) instead of J(0,1,.)
	// and we get num_dropped_levels=1 instead of num_dropped_levels=0
	num_dropped_levels = length(dropped_levels)

	// Need to decrement F.levels to reflect that we have fewer levels
	// (This is the trickiest part)
	offset = J(num_levels, 1, 0)
	if (offset != 0) {
		offset[dropped_levels] = J(num_dropped_levels, 1, 1)
		offset = runningsum(offset)
		levels = levels - offset[levels]
	}

	// Remove the obs of F.levels that were dropped
	levels[idx] = J(num_dropped_obs, 1, .)
	levels = select(levels, levels :!= .)

	// Update the remaining properties
	num_obs = num_obs - num_dropped_obs
	num_levels = num_levels - num_dropped_levels
	if (keys != J(0, 1, .)) keys = select(keys, counts)
	counts = select(counts, counts) // must be at the end!

	// Clear these out to prevent mistakes
	p = J(0, 1, .)
	inv_p = J(0, 1, .)
	info = J(0, 2, .)
	panel_is_setup = 0
}


// KEPT ONLY FOR BACKWARDS COMPAT
`Vector' Factor::drop_singletons(| `Vector' fweight,
                                   `Boolean' zero_threshold)
{
	`Integer'				num_singletons
	`Vector'				mask, idx
	`Boolean'				has_fweight
	`Vector'				weighted_counts

	// - By default, this drops all singletons (obs where F.counts==1)
	// - If fweights are provided, we'll only drop those singletons with fweight of 1
	// - As a hack, if zero_threshold==1, we'll drop singletons AND all obs where 
	//   "weighted_counts" (actually depvar) is zero
	//   Also, we multiply by counts so we can track how many actual obs were dropped

	if (zero_threshold == .) zero_threshold = 0

	if (counts == J(0, 1, .)) {
		_error(123, "drop_singletons() requires the -counts- vector")
	}

	has_fweight = (args()>=1 & fweight != .)

	if (has_fweight) {
		assert(rows(fweight)==num_obs)
		this.panelsetup()
		weighted_counts = `panelsum'(this.sort(fweight), this.info)
		if (zero_threshold) {
			mask = (!weighted_counts :| (counts :== 1)) :* counts
		}
		else {
			mask = weighted_counts :== 1
		}
	}
	else {
		mask = (counts :== 1)
	}

	num_singletons = sum(mask)
	if (num_singletons == 0) return(J(0, 1, .))
	counts = counts - mask
	idx = `selectindex'(mask[levels, .])

	// Update and overwrite fweight
	if (has_fweight) {
		fweight = num_singletons == num_obs ? J(0, 1, .) : select(fweight, (!mask)[levels])
	}
	
	// Update contents of F based on just idx and the updated F.counts
	__inner_drop(idx)
	return(idx)
}


`Boolean' Factor::is_id()
{
	if (counts == J(0, 1, .)) {
		_error(123, "is_id() requires the -counts- vector")
	}
	return(allof(counts, 1))
}


`Vector' Factor::intersect(`Vector' y,
              			 | `Boolean' integers_only,
              			   `Boolean' verbose)
{
	`Factor'				F
	`Vector'				index, mask

	if (integers_only == .) integers_only = 0
	if (verbose == .) verbose = 0

	assert_msg(keys != J(0, 1, .), "must have set save_keys==1")
	F = _factor(keys \ y, integers_only, verbose, "", 0, 0, ., 0)
	// The code above does the same as _factor(keys\y) but faster

	// Create a mask equal to 1 where the value of Y is in F.keys
	mask = J(F.num_levels, 1, 0)
	index = F.levels[| 1 \ rows(keys) |] // levels to exclude
	mask[index] = J(rows(keys), 1, 1)
	
	index = F.levels[| rows(keys)+1 \ . |]
	mask = mask[index] // expand mask
	return(mask)
}


`Void' Factor::cleanup_before_saving()
{
	this.vl = this.extra = .
}


// Main functions -------------------------------------------------------------

`Factor' factor(`Varlist' varnames,
              | `DataCol' touse, // either string varname or a numeric index
                `Boolean' verbose,
                `String' method,
                `Boolean' sort_levels,
                `Boolean' count_levels,
                `Integer' hash_ratio,
                `Boolean' save_keys)
{
	`Factor'				F
	`Varlist'				vars
	`DataFrame'				data
	`Integer'				i, k
	`Boolean'				integers_only
	`Boolean'				touse_is_selectvar
	`String'				var, lbl
	`Dict'					map
	`Vector'				keys
	`StringVector'			values

	if (args()<2 | touse == "") touse = .

	if (strlen(invtokens(varnames))==0) {
		printf("{err}factor() requires a variable name: %s")
		exit(102)
	}

	vars = tokens(invtokens(varnames))
	k = cols(vars)

	// touse is a string with the -touse- variable (a 0/1 mask), unless
	// we use an undocumented feature where it is an observation index
	if (eltype(touse) == "string") {
		assert_msg(orgtype(touse) == "scalar", "touse must be a scalar string")
		assert_msg(st_isnumvar(touse), "touse " + touse + " must be a numeric variable")
		touse_is_selectvar = 1
	}
	else {
		touse_is_selectvar = 0
	}

	if (method=="gtools") {
		// Warning: touse can't be a vector
		if (eltype(touse)=="real") {
			assert_msg(touse == ., "touse must be a variable name")
			touse = ""
		}
		F = __factor_gtools(vars, touse, verbose,
		                    sort_levels, count_levels, save_keys)
	}
	else {
		data = __fload_data(vars, touse, touse_is_selectvar)
		integers_only = varlist_is_integers(vars, data) // Are the variables integers (so maybe we can use the fast hash)?
		F = _factor(data, integers_only, verbose, method,
		            sort_levels, count_levels, hash_ratio,
		            save_keys,
		            vars, touse)
	}

	F.sortedby = tokens(st_macroexpand("`" + ": sortedby" + "'"))
	
	if (!F.is_sorted & cols(F.sortedby)) {
		i = min((k, cols(F.sortedby)))
		F.is_sorted = vars == F.sortedby[1..i]
	}

	if (!F.is_sorted & integers_only & cols(data)==1 & rows(data)>1) {
		F.is_sorted = all( data :<= (data[| 2, 1 \ rows(data), 1 |] \ .) )
	}
	F.varlist = vars
	if (touse_is_selectvar & touse!=.) F.touse = touse
	F.varformats = F.varlabels = F.varvaluelabels = F.vartypes = J(1, cols(vars), "")
	F.vl = asarray_create("string", 1)
	
	for (i = 1; i <= k; i++) {
		var = vars[i]
		F.varformats[i] = st_varformat(var)
		F.varlabels[i] = st_varlabel(var)
		F.vartypes[i] = st_vartype(var)
		F.varvaluelabels[i] = lbl = st_varvaluelabel(var)
		if (lbl != "") {
			if (st_vlexists(lbl)) {
				pragma unset keys
				pragma unset values
				st_vlload(lbl, keys, values)
				map = asarray_create("string", 1)
				asarray(map, "keys", keys)
				asarray(map, "values", values)
				asarray(F.vl, lbl, map)
			}
		}
	}
	return(F)
}


`Factor' _factor(`DataFrame' data,
               | `Boolean' integers_only,
                 `Boolean' verbose,
                 `String' method,
                 `Boolean' sort_levels,
                 `Boolean' count_levels,
                 `Integer' hash_ratio,
                 `Boolean' save_keys,
                 `Varlist' vars, 			// hack
                 `DataCol' touse)		 	// hack
{
	`Factor'				F
	`Integer'				num_obs, num_vars
	`Integer'				i
	`Integer'				limit0
	`Integer'				size0, size1, dict_size, max_numkeys1
	`Matrix'				min_max
	`RowVector'				delta
	`String'				msg, base_method

	if (integers_only == .) integers_only = 0
	if (verbose == .) verbose = 0
	if (method == "") method = "mata"
	if (sort_levels == .) sort_levels = 1
	if (count_levels == .) count_levels = 1
	if (save_keys == .) save_keys = 1
	
	// Note: Pick a sensible hash ratio; smaller means more collisions
	// but faster lookups and less memory usage

	base_method = method
	msg = "invalid method: " + method
	assert_msg(anyof(("mata", "hash0", "hash1"), method), msg)

	num_obs = rows(data)
	num_vars = cols(data)
	assert_msg(num_obs > 0, "no observations")
	assert_msg(num_vars > 0, "no variables")
	assert_msg(count_levels == 0 | count_levels == 1, "count_levels")
	assert_msg(save_keys == 0 | save_keys == 1, "save_keys")

	// Compute upper bound for number of levels
	size0 = .
	if (integers_only) {
		// We must nest the conditions; else they will fail with strings
		if (all(data:<=.)) {
			min_max = colminmax(data)
			delta = 1 :+ min_max[2, .] - min_max[1, .] + (colmissing(data) :> 0)
			for (i = size0 = 1; i <= num_vars; i++) {
				size0 = size0 * delta[i]
			}
		}
	}

	max_numkeys1 = min((size0, num_obs))
	if (hash_ratio == .) {
		if (size0 < 2 ^ 16) hash_ratio = 5.0
		else if (size0 < 2 ^ 20) hash_ratio = 3.0
		else hash_ratio = 1.3 // Standard hash table load factor
	}
	msg = sprintf("invalid hash ratio %5.1f", hash_ratio)
	assert_msg(hash_ratio > 1.0, msg)
	size1 = ceil(hash_ratio * max_numkeys1)
	size1 = max((size1, 2 ^ 10)) // at least 

	if (size0 == .) {
		if (method == "hash0") {
			printf("{txt}method hash0 cannot be applied, using hash1\n")
		}
		method = "hash1"
	}
	else if (method == "mata") {
		limit0 = 2 ^ 26 // 2 ^ 28 is 1GB; be careful with memory!!!
		// Pick hash0 if it uses less space than hash1
		// (b/c it has no collisions and is sorted at no extra cost)
		method = (size0 < limit0) | (size0 <  size1) ? "hash0" : "hash1"
	}

	dict_size = (method == "hash0") ? size0 : size1
	// Mata hard coded limit! (2,147,483,647 rows)
	assert_msg(dict_size <= 2 ^ 31, "dict size exceeds Mata limits")

	// Hack: alternative approach
	// all(delta :< num_obs) --> otherwise we should just run hash1
	if (base_method == "mata" & method == "hash1" & integers_only & num_vars > 1 & cols(vars)==num_vars & num_obs > 1e5 & all(delta :< num_obs)) {
		F = _factor_alt(vars[1], vars[2..num_vars], touse, verbose, sort_levels, count_levels, save_keys)
		method = "join"
	}
	else if (method == "hash0") {
		F = __factor_hash0(data, verbose, dict_size, count_levels, min_max, save_keys)
	}
	else if (method == "hash1"){
		F = __factor_hash1(data, verbose, dict_size, sort_levels, max_numkeys1, save_keys)
		if (!count_levels) F.counts = J(0, 1, .)
	}
	else {
		assert(0)
	}
	
	F.method = method

	F.num_obs = num_obs
	assert_msg(rows(F.levels) == F.num_obs & cols(F.levels) == 1, "levels")
	if (save_keys==1) assert_msg(rows(F.keys) == F.num_levels, "keys")
	if (count_levels) {
		assert_msg(rows(F.counts)==F.num_levels & cols(F.counts)==1, "counts")
	}
	if (verbose) {
		msg = "{txt}(obs: {res}%s{txt}; levels: {res}%s{txt};"
		printf(msg, strofreal(num_obs, "%12.0gc"), strofreal(F.num_levels, "%12.0gc"))
		msg = "{txt} method: {res}%s{txt}; dict size: {res}%s{txt})\n"
		printf(msg, method, method == "join" ? "n/a" : strofreal(dict_size, "%12.0gc"))
	}
	F.is_sorted = F.num_levels == 1 // if there is only one level it is already sorted
	return(F)
}


`Factor' _factor_alt(`Varname' first_var,
					 `Varlist' other_vars,
					 `DataCol' touse,
					 `Boolean' verbose,
					 `Boolean' sort_levels,
					 `Boolean' count_levels,
					 `Boolean' save_keys)
{
	`Factor'				F, F1, F2
	F1 = factor(first_var, touse, verbose, "mata", sort_levels, 1, ., save_keys)
	F2 = factor(other_vars, touse, verbose, "mata", sort_levels, count_levels, ., save_keys)
	F = join_factors(F1, F2, count_levels, save_keys)
	return(F)
}


`Factor' join_factors(`Factor' F1,
                      `Factor' F2, 
                    | `Boolean' count_levels,
                      `Boolean' save_keys,
                      `Boolean' levels_as_keys)
{
	`Factor'				F
	`Varlist'				vars
	`Boolean'				is_sorted // is sorted by (F1.varlist F2.varlist)
	`Integer'				num_levels, old_num_levels, N, M, i, j
	`Integer'				levels_start, levels_end
	`Integer'				v, last_v, c
	`Integer'				num_keys1, num_keys2
	`RowVector'				key_idx
	`Vector'				Y, p, y, levels, counts, idx
	`DataFrame'				keys

	if (save_keys == .) save_keys = 1
	if (count_levels == .) count_levels = 1
	if (levels_as_keys == .) levels_as_keys = 0

	if (save_keys & !levels_as_keys & !( rows(F1.keys) & rows(F2.keys)) ) {
		_error(123, "join_factors() with save_keys==1 requires the -keys- vector")
	}

	is_sorted = 0
	if (F1.sortedby == F2.sortedby & cols(F1.sortedby) > 0) {
		vars = F1.varlist, F2.varlist
		i = min(( cols(vars) , cols(F1.sortedby) ))
		is_sorted = vars == F1.sortedby[1..i]
	}

	F1.panelsetup()
	Y = F1.sort(F2.levels)
	levels = J(F1.num_obs, 1, 0)
	if (count_levels | save_keys) counts = J(F1.num_obs, 1, 1)

	if (save_keys) {
		if (levels_as_keys) {
			keys = J(F1.num_obs, 2, .)
		}
		else {
			num_keys1 = cols(F1.keys)
			num_keys2 = cols(F2.keys)
			key_idx = (num_keys1 + 1)..(num_keys1 + num_keys2)
			keys = J(F1.num_obs, num_keys1 + num_keys2, missingof(F1.keys))
		}
	}
	N = F1.num_levels
	levels_end = num_levels = 0

    for (i = 1; i <= N; i++) {
    	y = panelsubmatrix(Y, i, F1.info)
    	M = rows(y)
    	old_num_levels = num_levels

    	if (M == 1) {
    		// Case where i matched with only one key of F2

    		levels[++levels_end] = ++num_levels
    		if (save_keys) {
    			if (levels_as_keys) {
    				keys[num_levels, .] = (i, y)
    			}
    			else {
    				keys[num_levels, .] = F1.keys[i, .] , F2.keys[y, .]
    			}
    		}
    		// no need to update counts as it's ==1
    	}
    	else {
    		// Case where i matched with more than one key of F2

    		// Compute F.levels
    		if (!is_sorted) {
		    	p = order(y, 1)
		    	y = y[p]
    		}
    		idx = runningsum(1 \ (y[2::M] :!= y[1::M-1]))
	    	levels_start = levels_end + 1
	    	levels_end = levels_end + M
	    	if (!is_sorted) {
	    		levels[|levels_start \ levels_end |] = num_levels :+ idx[invorder(p)]
	    	}
	    	else {
	    		levels[|levels_start \ levels_end |] = num_levels :+ idx
	    	}

	    	// Compute F.counts
	    	if (count_levels | save_keys) {
		    	last_v = y[1]
		    	c = 1
		    	for (j=2; j<=M; j++) {
		    		v = y[j]
		    		if (v==last_v) {
		    			c++
		    		}
		    		else {
		    			counts[++num_levels] = c
		    			c = 1

		    			if (save_keys) {
		    				if (levels_as_keys) {
		    					keys[num_levels, .] = (i, last_v)
		    				}
		    				else {
		    					keys[num_levels , key_idx] = F2.keys[last_v, .]
		    				}
		    			}
		    		}
		    		last_v = v // swap?
		    	}
		    	if (c) {
		    		counts[++num_levels] = c

		    		if (save_keys) {
		    			if (levels_as_keys) {
		    				keys[num_levels, .] = (i, y[M])
		    			}
		    			else {
		    				keys[num_levels , key_idx] = F2.keys[y[M], .]
		    			}
		    		}

		    	}
	    	}
	    	else {
	    		num_levels = num_levels + idx[M]
	    	}

	    	// F.keys: compute the keys for the first factor
	    	if (save_keys & !levels_as_keys) {
	    		keys[| old_num_levels + 1 , 1 \ num_levels , num_keys1 |] = J(idx[M], 1, F1.keys[i, .])
	    	}
    	} // end case where M>1
    } // end for

	F = Factor()
	F.num_obs = F1.num_obs
    F.num_levels = num_levels
    F.method = "join"
    F.sortedby = F1.sortedby
    F.varlist = vars
    F.levels_as_keys = levels_as_keys

    if (!is_sorted) levels = F1.invsort(levels)
    if (count_levels) counts = counts[| 1 \ num_levels |]
    swap(F.levels, levels)
    if (save_keys) {
    	keys = keys[| 1 , 1 \ num_levels , . |]
    	swap(F.keys, keys)
    }
    swap(F.counts, counts)

    // Extra stuff (labels, etc)
    F.is_sorted = is_sorted
    return(F)
}


`Factor' __factor_hash0(
	`Matrix' data,
	`Boolean' verbose,
	`Integer' dict_size,
	`Boolean' count_levels,
	`Matrix' min_max,
	`Boolean' save_keys)
{
	`Factor'				F
	`Integer'				K, i, num_levels, num_obs, j
	`Vector'				hashes, dict, levels
	`RowVector'				min_val, max_val, offsets, has_mv
	`Matrix'				keys
	`Vector'				counts

	// assert(all(data:<=.)) // no .a .b ...

	K = cols(data)
	num_obs = rows(data)
	has_mv = (colmissing(data) :> 0)
	min_val = min_max[1, .]
	max_val = min_max[2, .] + has_mv

	// Build the hash:
	// Example with K=2:
	// hash = (col1 - min(col1)) * (max_col2 - min_col2 + 1) + (col2 - min_col2) 
	
	offsets = J(1, K, 1)
	// 2x speedup when K = 1 wrt the formula with [., K]
	if (K == 1) {
		hashes = editmissing(data, max_val) :- (min_val - 1)
	}
	else {
		hashes = editmissing(data[., K], max_val[K]) :- (min_val[K] - 1)
		for (i = K - 1; i >= 1; i--) {
			offsets[i] = offsets[i+1] * (max_val[i+1] - min_val[i+1] + 1)
			hashes = hashes + (editmissing(data[., i], max_val[i]) :- min_val[i]) :* offsets[i]
		}
	}
	assert(offsets[1] * (max_val[1] - min_val[1] + 1) == dict_size)


	// Once we have the -hashes- vector, these are the steps:
	// 1) Create a -dict- vector with more obs. than unique values (our hash table)
	// 2) Mark the slots of dict that map to a hash "dict[hashes] = J..."
	// 3) Get the obs. of those slots "levels = selectindex(dict)"
	//    Note that "num_levels = rows(levels)"
	//	  Also, at this point -levels- is just the sorted unique values of -hashes-
	// 4) We can get the keys based on levels by undoing the hash
	// 5) To create new IDs, do this trick:
	//	  dict[levels] = 1::num_levels
	//    levels = dict[hashes]
	
	// Build the new keys
	dict = J(dict_size, 1, 0)
	// It's faster to do dict[hashes] than dict[hashes, .],
	// but that fails if dict is 1x1
	if (length(dict) > 1) {
		dict[hashes] = J(num_obs, 1, 1)
	}
	else {
		dict = 1
	}

	levels = `selectindex'(dict)

	num_levels = rows(levels)
	dict[levels] = 1::num_levels

	if (save_keys) {
		if (K == 1) {
			keys = levels :+ (min_val - 1)
			if (has_mv) keys[num_levels] = .
		}
		else {
			keys = J(num_levels, K, .)
			levels = levels :- 1
			for (i = 1; i <= K; i++) {
				keys[., i] = floor(levels :/ offsets[i])
				levels = levels - keys[., i] :* offsets[i]
				if (has_mv[i]) keys[., i] = editvalue(keys[., i], max_val[i] - min_val[i], .)
			}
			keys = keys :+ min_val
		}
	}

	// faster than "levels = dict[hashes, .]"
	levels = rows(dict) > 1 ? dict[hashes] : hashes

	hashes = dict = . // Save memory

	if (count_levels) {
		// We need a builtin function that does: increment(counts, levels)
		// Using decrement+while saves us 10% time wrt increment+for
		counts = J(num_levels, 1, 0)
		i = num_obs + 1
		while (--i) {
			j = levels[i]
			counts[j] = counts[j] + 1
		}
		// maybe replace this with a permutation of levels plus counts[j] = i-last_i
	}

	F = Factor()
	F.num_levels = num_levels
	if (save_keys) swap(F.keys, keys)
	swap(F.levels, levels)
	swap(F.counts, counts)
	return(F)
}


`Factor' __factor_hash1(
	`DataFrame' data,
	`Boolean' verbose,
	`Integer' dict_size,
	`Boolean' count_levels,
	`Integer' max_numkeys1,
	`Boolean' save_keys)
{
	if (cols(data)==1) {
		return(__factor_hash1_1(data, verbose, dict_size, count_levels, max_numkeys1, save_keys))
	}
	else {
		return(__factor_hash1_0(data, verbose, dict_size, count_levels, max_numkeys1, save_keys))
	}
}

end
