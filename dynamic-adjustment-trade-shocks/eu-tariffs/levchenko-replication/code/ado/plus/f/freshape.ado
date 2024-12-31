* Proof of concept of reshape wide
* Missing items:
	* Allow strings in varlist
	* Allow strings in by1 and by2
	* Check that all variables that are not by1/by2/vars are constant within by1
	* Flexible stubs; stu@b
	* Output table; store chars

* reshape long should be easier

loc by1 turn
loc by2 foreign
loc vars "price gear"

sysuse auto, clear
keep `by1' `by2' `vars'
bys `by1' `by2': keep if _n==1

loc verbose 1
gen byte touse = 1

mata:
	F1 = factor("`by1'", "`touse'", `verbose', "", 1, 1)
	F2 = factor("`by2'", "`touse'", `verbose', "", 1, 1)
	
	// by1 by2 must be unique identifiers
	F12 = join_factors(F1, F2, 1, 0, 1)
	F12.is_id()
	mata drop F12

	vars = tokens("`vars'")
	K = cols(vars)
	ans = J(F1.num_levels * F2.num_levels, K, .)
	idx = F1.levels :* F2.num_levels + F2.levels :- 2
	y = st_data(., vars)
	ans[idx, .] = y

	ans = colshape(ans, K * F2.num_levels)

	header = J(F2.num_levels, 1, vars') + strofreal(F2.keys # J(2,1,1))
	mm_matlist(ans, "%8.4g", 1, strofreal(F1.keys), header)

	//ans = colshape(ans, K)
	//ok = rownonmissing(ans)
	//ans = select(ans, ok)
	
	//header = F2.keys
	//colheader1 = select(F1.keys # J(F2.num_levels, 1, 1), ok)
	//colheader2 = select(F2.keys # J(F1.num_levels, 1, 1), ok)
	
	//colheader1, colheader2, ans
	//ans
	//mm_matlist(ans, "%8.4g", 1, "", strofreal(header))
end

li
tab `by1' `by2'
reshape wide `vars', i(`by1') j(`by2')
br

// reshape long price gear_ratio, i(`by1') j(`by2')

exit
