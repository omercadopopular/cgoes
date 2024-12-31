// Helper functions ----------------------------------------------------------
mata:

`Void' _assert_abort(`Integer' rc, `String' msg, `Boolean' traceback) {
	if (traceback) {
		_error(rc, msg)
	}
	else {
		printf("{err}%s\n", msg)
		exit(rc) // exit(error(rc))
	}
}


`Void' assert_msg(`Boolean' t, | `String' msg, `Integer' rc, `Boolean' traceback)
{
	if (args()<2 | msg=="") msg = "assertion is false"
	if (args()<3 | rc==.) rc = 3498
	if (args()<4 | rc==.) traceback = 1
	if (t==0) _assert_abort(rc, msg, traceback)
}


`Void' assert_in(`DataCell' value, `DataRow' valid_values, | string scalar msg)
{
	if (args()<2 | msg=="") msg = "assertion is false; value not in list"
	// "anyof(valid_values, value)"  <==> "value in valid_values" [Python]
	if (!anyof(valid_values, value)) _error(msg)
}


`Void' assert_boolean(`DataCell' value, | string scalar msg)
{
	if (args()<2 | msg=="") msg = "assertion is false; value not boolean"
	assert_in(value, (0,1), msg)
}


// mask: a dummy variable indicating selection (like -touse-)
// Example usage:
// mata: idx = (1,2,5,9)'
// mata: m = create_mask(12, 0, idx, 1)
// mata: update_mask(m, idx, 2)
// mata: update_mask(m, (1,3)', 10)

`Void' update_mask(`Variable' mask, `Vector' index, `Real' value)
{
	if (!length(index)) return

	// Allow for vector and rowvector masks
	if (is_rowvector(index)) {
		mask[index] = J(1, cols(index), value)
	}
	else {
		mask[index] = J(rows(index), 1, value)
	}
}


`Variable' create_mask(`Integer' obs, `Real' default_value, `Vector' index, `Real' value)
{
	`Variable'		mask
	// Allow for vector and rowvector masks
	if (is_rowvector(index)) {
		mask = J(1, obs, default_value)
	}
	else {
		mask = J(obs, 1, default_value)
	}
	update_mask(mask, index, value)
	return(mask)
}


`Real' clip(`Real' x, `Real' min_x, `Real' max_x) {
	return(x < min_x ? min_x : (x > max_x ? max_x : x))
}


`Matrix' inrange(`Matrix' x, `Matrix' lb, `Matrix' ub)
{
	return(lb :<= x :& x :<= ub)
}


`Boolean' is_rowvector(`DataFrame' x) {
	return(orgtype(x) == "rowvector")
}


// Return 1 if all the variables are integers 
`Boolean' varlist_is_integers(`Varlist' varlist, `DataFrame' data)
{
	`Integer' 				i
	`Integer' 				num_vars
	`String'				type

	if (eltype(data) == "string") {
		return(0)
	}

	num_vars = cols(varlist)
	for (i = 1; i <= num_vars; i++) {
		type = st_vartype(varlist[i])
		if (anyof(("byte", "int", "long"), type)) {
			continue
		}
		if (round(data[., i])==data[., i]) {
				continue
		}
		return(0)
	}
	return(1)
}


// Return 1 if the varlist has string and numeric types
`Boolean' varlist_is_hybrid(`Varlist' varlist)
{
	`Boolean' 				first_is_num
	`Integer' 				i
	`Integer' 				num_vars

	num_vars = cols(varlist)
	first_is_num = st_isnumvar(varlist[1])
	for (i = 2; i <= num_vars; i++) {
		if (first_is_num != st_isnumvar(varlist[i])) {
			return(1)
			//_error(999, "variables must be all numeric or all strings")
		}
	}
	return(0)
}


`DataFrame' __fload_data(`Varlist' varlist,
                       | `DataCol' touse,
                         `Boolean' touse_is_selectvar)
{
	`Integer'				num_vars
	`Boolean'				is_num
	`Integer'				i
	`DataFrame'				data

	if (args()<2) touse = .
	if (args()<3) touse_is_selectvar = 1 // can be selectvar (a 0/1 mask) or an index vector

	varlist = tokens(invtokens(varlist)) // accept both types
	assert_msg(!varlist_is_hybrid(varlist), "variables must be all numeric or all strings", 999)
	is_num = st_isnumvar(varlist[1])

	//     idx   = touse_is_selectvar ?   .   : touse
	// selectvar = touse_is_selectvar ? touse :   .
	if (is_num) {
		data =  st_data(touse_is_selectvar ? . : touse , varlist, touse_is_selectvar ? touse : .)
	}
	else {
		data = st_sdata(touse_is_selectvar ? . : touse , varlist, touse_is_selectvar ? touse : .)
	}
	return(data)
}


`Void' __fstore_data(`DataFrame' data,
                     `Varname' newvar,
                     `String' type,
                   | `String' touse)
{
	`RowVector'				idx
	idx = st_addvar(type, newvar)
	if (substr(type, 1, 3) == "str") {
		if (touse == "") st_sstore(., idx, data)
		else st_sstore(., idx, touse, data)
	}
	else {
		if (touse == "") st_store(., idx, data)
		else st_store(., idx, touse, data)
	}
}


// Based on Nick Cox's example
// https://www.statalist.org/forums/forum/general-stata-discussion/general/1330558-product-of-row-elements?p=1330561#post1330561
`Matrix' rowproduct(`Matrix' X)
{
	`Integer' i, k
	`Matrix' prod
	k = cols(X)
	if (k==1) return(X)
	prod = X[,1]
	for(i = 2; i<=k; i++) {
		prod = prod :* X[,i]
	}
	return(prod)
}



`Void' unlink_folder(`String' path, `Boolean' verbose)
{
	// We are SUPER careful in only removing certain files... so if there are other files this function will fail
	`StringVector'			fns, patterns
	`Integer'				i, j, num_dropped
	
	if (!direxists(path)) exit()
	if (verbose) printf("{txt}Removing folder and its contents: {res}%s{txt}\n", path)
	
	num_dropped = 0
	patterns = ("*.tmp" \ "*.log" \ "parallel_code.do")

	for (j=1; j<=rows(patterns); j++){
		fns = dir(path, "files", patterns[j], 1)
		for (i=1; i<=rows(fns); i++) {
			unlink(fns[i])
			++num_dropped
		}
	}

	if (verbose) printf("{txt} - %f files removed\n", num_dropped)
	
	rmdir(path)
	if (verbose) printf("{txt} - Folder removed\n")
}


end
