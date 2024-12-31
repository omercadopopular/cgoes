mata:

// Call gtools plugin
`Factor' __factor_gtools(
	`Varlist' vars,
	`String' touse,
	`Boolean' verbose,
	`Boolean' sort_levels,
	`Boolean' count_levels,
	`Boolean' save_keys)
{
	`Factor'				F
	`Integer'				num_vars, num_levels, num_obs
	`String'				levels_var, tag_var, counts_var, cmd, if_cmd, counts_cmd
	`Vector'				levels, counts, idx
	`Matrix'				keys

	// Options
	if (verbose == .) verbose = 0
	if (sort_levels == .) sort_levels = 1
	if (count_levels == .) count_levels = 1
	if (save_keys == .) save_keys = 1

	assert_msg(count_levels == 0 | count_levels == 1, "count_levels")
	assert_msg(save_keys == 0 | save_keys == 1, "save_keys")

	// Load data, based on output from -gegen group-
	levels_var = st_tempname()
	counts_var = st_tempname()

	// Run gegen group() from Stata
	if_cmd = touse == "" ? "" : " if " + touse
	counts_cmd = count_levels ? sprintf("counts(%s) fill(data)", counts_var) : ""
	cmd = "gegen long %s = group(%s)%s, missing %s"
	cmd = sprintf(cmd, levels_var, invtokens(vars), if_cmd, counts_cmd)
	if (verbose) printf(cmd + "\n")
	stata(cmd)

	num_levels = st_numscalar("r(J)")
	num_obs = st_numscalar("r(N)")
	num_vars = cols(vars)
	levels = st_data(., levels_var, touse)
	

	if (count_levels) {
		counts = st_data( (1,num_levels) , counts_var, .)
	}

	if (save_keys) {
		idx = J(num_levels, 1, .)
		idx[levels] = 1::num_obs
		keys = st_data(idx, vars, touse)
	}

	if (count_levels) assert_msg(num_levels == rows(counts), "num_levels")
	assert_msg(num_obs == rows(levels), "num_obs")
	assert_msg(num_obs > 0, "no observations")
	assert_msg(num_vars > 0, "no variables")

	F = Factor()
	F.num_levels = num_levels
	F.num_obs = num_obs
	if (save_keys) swap(F.keys, keys)
	swap(F.levels, levels)
	swap(F.counts, counts)
	F.method = "gtools"
	assert_msg(rows(F.levels) == F.num_obs & cols(F.levels) == 1, "levels")
	if (save_keys==1) assert_msg(rows(F.keys) == F.num_levels, "keys")
	if (count_levels) assert_msg(rows(F.counts)==F.num_levels & cols(F.counts)==1, "counts")
	F.is_sorted = 0
	return(F)
}

end
