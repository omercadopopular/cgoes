// FCOLLAPSE - Main routine
mata:
mata set matastrict on

void f_collapse(`Factor' F,
                `Dict' fun_dict,
                `Dict' query,
                `String' vars,
                `Boolean' merge,
                `Boolean' append,
                `Integer' pool,
              | `Varname' wvar,
                `String' wtype,
                `Boolean' compress)
{
	`Integer'			num_vars, num_targets, num_obs, niceness
	`Integer'			i, i_next, j, i_cstore, j_cstore, i_target
	`Real'				q
	`StringRowVector'	var_formats, var_types
	`StringRowVector'	targets, target_labels, target_types, target_formats
	`RowVector'			var_is_str, target_is_str
	`String'			var
	`Vector'			weights
	`Dict'				data_cstore, results_cstore
	`Dict'				var_positions // varname -> (column, start)
	`RowVector'			var_pos
	`Vector'			box
	`StringMatrix'		target_stat_raw
	`String'			target, stat
	`DataCol'			data
	`Boolean'			raw
	`Boolean'			nofill
	`Vector'			idx // used by APPEND to index the new obs.
	pointer(`DataCol')	scalar fp

	if (args() < 6) wvar = ""
	if (args() < 7) wtype = ""

	assert(anyof(("", "aweight", "iweight", "fweight", "pweight"), wtype))


	// Variable information
	vars = tokens(vars)
	assert(cols(vars) == cols(asarray_keys(query)'))
	num_vars = length(vars)
	var_formats = var_types = J(1, num_vars, "")
	var_is_str = J(1, num_vars, .)
	num_targets = 0
	for (i = 1; i <= num_vars; i++) {
		var = vars[i]
		var_formats[i] = st_varformat(var)
		var_types[i] = st_vartype(var)
		var_is_str[i] = st_isstrvar(var)
		num_targets = num_targets + rows(asarray(query, var))
	}

	// Compute permutation vector so we can sort the data
	F.panelsetup()
	if (!merge) {
		F.levels = . // save memory
	}

	// Weights
	if (wvar != "") {
		weights = F.sort(st_data(., wvar, F.touse))
	}
	else {
		weights = 1
	}

	// Load variables
	niceness = st_numscalar("c(niceness)") // requires stata 13+
	if (length(niceness) == 0) niceness = .
	stata("cap set niceness 10") // requires stata 13+
	data_cstore = asarray_create("real", 1)
	var_positions = asarray_create("string", 1)
	num_obs = F.num_obs
	if (!merge & !append) assert(num_obs == st_nobs())

	// i, i_next, j -> index variables
	// i_cstore -> index vectors in the cstore
	i_next = . // to avoid warning

	for (i = i_cstore = 1; i <= num_vars; i = i_next + 1) {
		i_next = min((i + pool - 1, num_vars))
		
		// Can't load strings and numbers together
		for (j = i; j <= i_next; j++) {
			if (var_is_str[j] != var_is_str[i]) {
				i_next = j - 1
				break
			}
		}

		// Load data
		if (var_is_str[i]) {
			asarray(data_cstore, i_cstore, st_sdata(., vars[i..i_next], F.touse))
		}
		else {
			asarray(data_cstore, i_cstore, st_data(., vars[i..i_next], F.touse))
		}

		// Keep pending vars
		if (!merge & !append) {
			if (i_next == num_vars) {
				stata("clear")
			}
			else {
				st_keepvar(vars[i_next+1..num_vars])
			}
		}

		// Store collated and vectorized data
		// cstore[i_cstore] = vec(sort(cstore[i_cstore]))
		asarray(data_cstore, i_cstore, 
		        vec(F.sort(asarray(data_cstore, i_cstore))))

		// Store the position of each variable in the cstore
		for (j = i; j <= i_next; j++) {
			var = vars[j]
			j_cstore = 1 + (j - i) * num_obs
			var_pos = (i_cstore, j_cstore)
			asarray(var_positions, var, var_pos)
		}
		i_cstore++
	}

	results_cstore = asarray_create("string", 1)
	targets = target_labels = target_types = target_formats = J(1, num_targets, "")
	target_is_str = J(1, num_targets, .)

	// Apply aggregations
	for (i = i_target = 1; i <= num_vars; i++) {
		var = vars[i]
		target_stat_raw = asarray(query, var)
		var_pos = asarray(var_positions, var)

		for (j = 1; j <= rows(target_stat_raw); j++) {

			i_cstore = var_pos[1]
			j_cstore = var_pos[2]
			box = j_cstore \ j_cstore + num_obs - 1
			data = asarray(data_cstore, i_cstore)[|box|]
			
			target = target_stat_raw[j, 1]
			stat = target_stat_raw[j, 2]
			raw = strtoreal(target_stat_raw[j, 3])
			fp = asarray(fun_dict, stat)
			targets[i_target] =  target
			target_labels[i_target] = sprintf("(%s) %s", stat, var)
			target_types[i_target] = infer_type(var_types[i], var_is_str[i], stat, data)
			target_formats[i_target] = stat=="count" ? "%8.0g" : var_formats[i]
			target_is_str[i_target] = var_is_str[i]
			
			if (stat == "median") {
				stat = "p50"
			}
			if (regexm(stat, "^p[0-9]+$")) {
				q = strtoreal(substr(stat, 2, .)) / 100
				fp = asarray(fun_dict, "quantile")
				asarray(results_cstore, target, (*fp)(F, data, weights, raw ? "" : wtype, q))
			}
			else {
				asarray(results_cstore, target, (*fp)(F, data, weights, raw ? "" : wtype))
			}
			++i_target
		} 
		// Clear vector if done with it
		if (box[2] == rows(asarray(data_cstore, i_cstore))) {
			asarray(data_cstore, i_cstore, .)
		}
	}

	if (append) {
		// 1) Add obs
		idx = ( st_nobs()) + 1 :: (st_nobs() + F.num_levels )
		st_addobs(F.num_levels)
		// 2) Fill out -by- variables
		if (substr(F.vartypes[1], 1, 3) == "str") {
			st_sstore(idx, F.varlist, F.keys)
		}
		else {
			st_store(idx, F.varlist, F.keys)
		}

		// Add data to bottom rows, adding variables or recasting if necessary
		for (i = 1; i <= length(targets); i++) {
			target = targets[i]
			data = asarray(results_cstore, target)

			if (target_is_str[i]) {
				if (missing(_st_varindex(target))) {
					(void) st_addvar(target_types[i], target)
				}
				st_sstore(idx, target, data)
			}
			else {
				if (compress) {
					target_types[i] = compress_type(target_types[i], data)
				}

				if (missing(_st_varindex(target))) {
					(void) st_addvar(target_types[i], target)
				}
				else if (st_vartype(target) != target_types[i]) {
					// Note that the recast attempt might fail if we ran this command with -if-
					// This is b/c observations not loaded into Mata might be outside the valid range
					stata(sprintf("qui recast %s %s", target_types[i], target))
				}

				// (sp. tricky with -merge-, but not so much otherwise, as touse will be always 1)
				st_store(idx, target, data)
			}
			asarray(results_cstore, target, .)
		}
	} // APPEND CASE
	else {

		// Store results
		if (!merge) {
			F.store_keys(1) // sort=1 will 'sort' by keys (faster now than later)
			assert(F.touse == "")
		}

		nofill = (merge == 0)

		for (i = 1; i <= length(targets); i++) {
			target = targets[i]
			data = asarray(results_cstore, target)
			if (merge) {
				data = rows(data) == 1 ? data[F.levels, .] : data[F.levels]
			}

			if (target_is_str[i]) {
				st_sstore(., st_addvar(target_types[i], target, nofill), F.touse, data)
			}
			else {
				if (compress) {
					target_types[i] = compress_type(target_types[i], data)
				}
				
				// note: we can't do -nofill- with addvar because that sets the values to 0 instead of missing
				// (sp. tricky with -merge-, but not so much otherwise, as touse will be always 1)
				st_store(., st_addvar(target_types[i], target, nofill), F.touse, data)
			}
			asarray(results_cstore, target, .)
		}

		// Label and format vars
		for (i = 1; i <= cols(targets); i++) {
			st_varlabel(targets[i], target_labels[i])
			st_varformat(targets[i], target_formats[i])
		}

	} // NOT APPEND

	stata(sprintf("cap set niceness %s", strofreal(niceness)))
}


// Try to pick a more compact type after the data has been created
`String' compress_type(`String' target_type,
                       `DataCol' data)
{
	`RowVector'					_
	`Integer'					min, max

	// We can't improve on byte
	if (target_type == "byte") {
		return(target_type)
	}

	// We shouldn't lose accuracy
	if (any( target_type :== ("float", "double") )) {
		if (trunc(data) != data)  {
			return(target_type)
		}
	}
	
	_ = minmax(data)
	min = _[1]
	max = _[2]

	if (-127 <= min & max <= 100) {
		return("byte")
	}
	else if (-32767 <= min & max <= 32740) {
		return("int")
	}
	else if (-2147483647 <= min & max <= 2147483620) {
		return("long")
	}
	else {
		return(target_type)
	}
}


// Infer type required for new variables after collapse
`String' infer_type(`String' var_type,
                    `Boolean' var_is_str,
                    `String' stat,
                    `DataCol' data)
{
	`String' 					ans
	`StringRowVector' 			fixed_stats

	fixed_stats = ("min", "max", "first", "last", "firstnm", "lastnm")

	if ( var_is_str | any(fixed_stats :== stat) ) {
		ans = var_type
	}
	else if (stat == "count") {
		ans = "long"
	}
	else {
		ans = "double"
	}

	return(ans)
}

end
