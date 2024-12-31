*! version 2.9.0 28mar2017

* Possible improvements: allow in, if, reverse sort (like gsort)
* This uses Andrew Maurer's trick to clear the sort order:
* http://www.statalist.org/forums/forum/general-stata-discussion/mata/172131-big-data-recalling-previous-sort-orders


program define fsort
	syntax varlist, [Verbose]

	loc sortvar : sortedby

	if ("`sortvar'" == "`varlist'") {
		exit
	}
	else if ("`sortvar'" != "") {
		* Andrew Maurer's trick to clear `: sortedby'
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

	fsort_inner `varlist', `verbose'
	sort `varlist' // dataset already sorted by `varlist' but flag `: sortedby' not set
end


program define fsort_inner, sortpreserve
	syntax varlist, [Verbose]
	loc verbose = ("`verbose'" != "")
	mata: fsort_inner("`varlist'", "`_sortindex'", `verbose')
end


mata:
void fsort_inner(string scalar vars, string scalar sortindex, real scalar verbose)
{
	class Factor scalar F
	F = factor(vars, "", verbose, "", ., ., ., 0)
	if (!F.is_sorted) {
		F.panelsetup()
		st_store(., sortindex, invorder(F.p))
	}
}
end


findfile "ftools.mata"
include "`r(fn)'"
exit
