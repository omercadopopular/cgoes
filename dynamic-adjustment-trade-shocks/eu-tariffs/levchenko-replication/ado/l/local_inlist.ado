*! version 2.11.1 08jun2017
program define local_inlist
	syntax anything(name=0 everything) [, LABels]
	loc labels = ("`labels'"!="")
	gettoken 0 values : 0
	syntax varname
	loc isnum = strpos("`: type `varlist''", "str")==0
	if (`labels') {
		_assert "`: val lab `varlist''"!= "", msg("variable `varlist' has no label") rc(182)
	}

	mata: build_inlist("`varlist'", `"`values'"', `isnum', `labels')
	c_local inlist `"`inlist'"'
end

findfile "ftools_type_aliases.mata"
include "`r(fn)'"

mata:
mata set matastrict on

void build_inlist(`String' varname,
               `String' data,
               `Boolean' isnum,
               `Boolean' islabel)
{
	`Integer'				maxlen, i, n, k
	`String'				ans
	`Dict'					map
	`Vector'				keys
	`StringVector'			values

	// Create map from labels to values
	if (islabel) {
		st_vlload(st_varvaluelabel(varname), keys=., values="")
		map = asarray_create("string", 1)
		for (i=1; i<=rows(keys); i++) {
			asarray(map, values[i], keys[i])
		}
	}
	
	ans = tokens(data)
	maxlen = isnum ? 254 : 9
	n = cols(ans)

	// Add quotes
	if (!isnum) ans = char(34) :+ ans :+ char(34)
	
	// Convert labels to values
	if (islabel) for (i=1; i<=n; i++) if (length(asarray(map, ans[i]))==0) exit(_error(182, `"Label ""' + ans[i] + `"" not found"'))
	if (islabel) for (i=1; i<=n; i++) ans[i] = strofreal(asarray(map, ans[i]), "%30.10g")

	// Format inlist() expressions
	for (i=1; i<=n; i=i+maxlen) {
		k = min((i+maxlen-1, n))
		if (i < k) ans[i..k-1] = ans[i..k-1] :+ ","
		ans[i] = (i>1 ? "| " : "") + "inlist(" + varname + ", " + ans[i]
		ans[k] = ans[k] + ")"
	}
	ans = invtokens(ans)
	if (n > maxlen) ans = "(" + ans + ")"
	st_local("inlist", ans)
}
end
