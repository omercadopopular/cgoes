// FCOLLAPSE - Aggregate Functions
// -data- vector must be already sorted by F: F.sort(data)
// Same for -weights- vector

mata:
mata set matastrict on

`Dict' aggregate_get_funs()
{
	`Dict'					funs
	funs = asarray_create("string", 1)
	asarray_notfound(funs, NULL)
	asarray(funs, "count", &aggregate_count())
	asarray(funs, "mean", &aggregate_mean())
	asarray(funs, "sum", &aggregate_sum())
	asarray(funs, "min", &aggregate_min())
	asarray(funs, "max", &aggregate_max())
	asarray(funs, "first", &aggregate_first())
	asarray(funs, "last", &aggregate_last())
	asarray(funs, "firstnm", &aggregate_firstnm())
	asarray(funs, "lastnm", &aggregate_lastnm())
	asarray(funs, "percent", &aggregate_percent())
	asarray(funs, "quantile", &aggregate_quantile())
	asarray(funs, "iqr", &aggregate_iqr())
	asarray(funs, "sd", &aggregate_sd())
	asarray(funs, "nansum", &aggregate_nansum())
	// ...
	return(funs)
}


`Matrix' select_nm_num(`Vector' data) {
	// Return matrix in case the answer is 0x0
	return(select(data, data :< .))
}


`StringMatrix' select_nm_str(`StringVector' data) {
	return(select(data, data :!= ""))
}


`DataCol' aggregate_count(`Factor' F, `DataCol' data, `Vector' weights, `String' wtype)
{
	if (wtype == "" | wtype == "aweight") {
		return( `panelsum'(data :<., 1, F.info) )
	}
	else {
		return( `panelsum'(data :<., weights, F.info) )
	}
	// Older:
	//`Integer'	            i
	//`DataCol'	            results
	//results = J(F.num_levels, 1, missingof(data))
	//for (i = 1; i <= F.num_levels; i++) {
    //    results[i] = nonmissing(panelsubmatrix(data, i, F.info))
	//}
	//return(results)
}


`Vector' aggregate_sum(`Factor' F, `Vector' data, `Vector' weights, `String' wtype)
{
	if (wtype == "") {
		return( `panelsum'(editmissing(data, 0), 1, F.info) )
	}
	else if (wtype == "aweight") {
		`Vector' sum_weights
		// normalize weights so they add up to number of obs. in the subgroup
		sum_weights = `panelsum'(weights :* (data :< .), F.info) :/ `panelsum'(data :< ., F.info)
		return( `panelsum'(editmissing(data, 0), weights, F.info) :/ sum_weights )
	}
	else {
		return( `panelsum'(editmissing(data, 0), weights, F.info) )
	}
}


`Vector' aggregate_nansum(`Factor' F, `Vector' data, `Vector' weights, `String' wtype)
{
	assert(wtype == "")
	return( `panelsum'(editmissing(data, 0), 1, F.info) :/ (`panelsum'(data :<., 1, F.info) :> 0) )
}


`Vector' aggregate_mean(`Factor' F, `Vector' data, `Vector' weights, `String' wtype)
{
	if (wtype == "") {
		return( aggregate_sum(F, data, 1, "") :/ aggregate_count(F, data, 1, "") )
	}
	else {
		// http://www.statalist.org/forums/forum/general-stata-discussion/general/289901-collapse-and-weights
		return( aggregate_sum(F, data, weights, "iweight") :/ aggregate_count(F, data, weights, "iweight") )
	}

	// Older:
	//`Integer'	            i
	//`Vector'	            results
	//results = J(F.num_levels, 1, .)
	//for (i = 1; i <= F.num_levels; i++) {
    //    results[i] = mean(panelsubmatrix(data, i, F.info), weights)
	//}
	//return(results)
}


`Vector' aggregate_min(`Factor' F, `Vector' data, `Vector' weights, `String' wtype)
{
	`Integer'	            i
	`Vector'	            results
	results = J(F.num_levels, 1, .)
	for (i = 1; i <= F.num_levels; i++) {
        results[i] = colmin(panelsubmatrix(data, i, F.info))
	}
	return(results)
}


`Vector' aggregate_max(`Factor' F, `Vector' data, `Vector' weights, `String' wtype)
{
	`Integer'	            i
	`Vector'	            results
	results = J(F.num_levels, 1, .)
	for (i = 1; i <= F.num_levels; i++) {
        results[i] = colmax(panelsubmatrix(data, i, F.info))
	}
	return(results)
}


`DataCol' aggregate_first(`Factor' F, `DataCol' data, `Vector' weights, `String' wtype)
{
	`Integer'	            i
	`DataCol'	            results
	results = J(F.num_levels, 1, missingof(data))
	for (i = 1; i <= F.num_levels; i++) {
        results[i] = data[F.info[i, 1]]
	}
	return(results)
}


`DataCol' aggregate_last(`Factor' F, `DataCol' data, `Vector' weights, `String' wtype)
{
	`Integer'	            i
	`DataCol'	            results
	results = J(F.num_levels, 1, missingof(data))
	for (i = 1; i <= F.num_levels; i++) {
        results[i] = data[F.info[i, 2]]
	}
	return(results)
}


`DataCol' aggregate_firstnm(`Factor' F, `DataCol' data, `Vector' weights, `String' wtype)
{
	`Integer'	            i
	`DataCol'	            results, tmp
	pointer(`Vector')		fp
	results = J(F.num_levels, 1, missingof(data))
	fp = isstring(data) ? &select_nm_str() : &select_nm_num()
	for (i = 1; i <= F.num_levels; i++) {
		tmp = (*fp)(panelsubmatrix(data, i, F.info))
		if (rows(tmp) == 0) continue
        results[i] = tmp[1]
	}
	return(results)
}


`DataCol' aggregate_lastnm(`Factor' F, `DataCol' data, `Vector' weights, `String' wtype)
{
	`Integer'	            i
	`DataCol'	            results, tmp
	pointer(`Vector')		fp
	results = J(F.num_levels, 1, missingof(data))
	fp = isstring(data) ? &select_nm_str() : &select_nm_num()
	for (i = 1; i <= F.num_levels; i++) {
		tmp = (*fp)(panelsubmatrix(data, i, F.info))
		if (rows(tmp) == 0) continue
        results[i] = tmp[rows(tmp)]
	}
	return(results)
}


`Vector' aggregate_percent(`Factor' F, `DataCol' data, `Vector' weights, `String' wtype)
{
	`Vector'	            results
	results = aggregate_count(F, data, weights, wtype)
	return(results :/ (quadsum(results) / 100))
}


`Vector' aggregate_quantile(`Factor' F, `Vector' data, `Vector' weights, `String' wtype, 
                            `Integer' P)
{
	`Integer'	            i
	`Vector'	            results, tmp_data, tmp_weights
	
	results = J(F.num_levels, 1, .)
	
	if (wtype == "") {
		for (i = 1; i <= F.num_levels; i++) {
	        // SYNTAX: _mm_quantile(data, weights, quantiles, altdef)
	        // SYNTAX: mm_quantile(data, | w, P, altdef)
	        tmp_data = panelsubmatrix(data, i, F.info)
	        tmp_data = select(tmp_data, tmp_data :< .)
	        if (rows(tmp_data) == 0) continue
	        results[i] = _mm_quantile(tmp_data, 1, P, 0)
		}
	}
	else {
		for (i = 1; i <= F.num_levels; i++) {
	        tmp_data = panelsubmatrix(data, i, F.info)
	        tmp_weights = panelsubmatrix(weights, i, F.info)
	        tmp_weights = select(tmp_weights, tmp_data :< .)
	        tmp_data = select(tmp_data, tmp_data :< .)
	        if (rows(tmp_data) == 0) continue
	        results[i] = _mm_quantile(tmp_data, tmp_weights, P, 0)
		}
	}

	return(results)
}


`Vector' aggregate_iqr(`Factor' F, `Vector' data, `Vector' weights, `String' wtype)
{
	`Integer'	            i
	`Vector'	            results, tmp_data, tmp_weights, P
	`RowVector'				tmp_iqr

	results = J(F.num_levels, 1, .)
	P = (0.25\0.75)
	
	if (wtype == "") {
		for (i = 1; i <= F.num_levels; i++) {
	        // SYNTAX: _mm_quantile(data, weights, quantiles, altdef)
	        // SYNTAX: mm_quantile(data, | w, P, altdef)
	        tmp_data = panelsubmatrix(data, i, F.info)
	        tmp_data = select(tmp_data, tmp_data :< .)
	        if (rows(tmp_data) == 1) results[i] = 0
	        if (rows(tmp_data) <= 1) continue
	        tmp_iqr = _mm_quantile(tmp_data, 1, P, 0)
	        results[i] = tmp_iqr[2] - tmp_iqr[1]
		}
	}
	else {
		for (i = 1; i <= F.num_levels; i++) {
	        tmp_data = panelsubmatrix(data, i, F.info)
	        tmp_weights = panelsubmatrix(weights, i, F.info)
	        tmp_weights = select(tmp_weights, tmp_data :< .)
	        tmp_data = select(tmp_data, tmp_data :< .)
	        if (rows(tmp_data) == 1) results[i] = 0
	        if (rows(tmp_data) <= 1) continue
	        tmp_iqr = _mm_quantile(tmp_data, tmp_weights, P, 0)
	        results[i] = tmp_iqr[2] - tmp_iqr[1]
		}
	}

	return(results)
}


`Vector' aggregate_sd(`Factor' F, `Vector' data, `Vector' weights, `String' wtype)
{
	`Integer'	            i
	`Vector'	            results, adjustment, tmp_weights
	if (wtype == "pweight") {
		_error("sd not allowed with pweights")
	}
	results = J(F.num_levels, 1, .)

	if (wtype == "") {
		for (i = 1; i <= F.num_levels; i++) {
	        results[i] = sqrt(quadvariance(panelsubmatrix(data, i, F.info)))
		}
	}
	else {
		printf("{err}warning: option sd has not been properly tested with weights!!!!")
		for (i = 1; i <= F.num_levels; i++) {
			tmp_weights = panelsubmatrix(weights, i, F.info)
			tmp_weights = tmp_weights :/ quadsum(tmp_weights) * 1000000000 // why? bugbug
	        results[i] = sqrt(quadvariance(panelsubmatrix(data, i, F.info), tmp_weights))
		}
		adjustment = aggregate_count(F, data, 1, "")
		adjustment = sqrt(adjustment :/ (adjustment :- 1))
		results =  results :* adjustment
	}
	return(results)
}
end
