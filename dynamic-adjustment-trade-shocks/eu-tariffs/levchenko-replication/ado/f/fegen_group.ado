*! version 2.23.2 10nov2017
program define fegen_group
	syntax [if] [in] , [by(varlist) type(string)] /// -by- is ignored
		name(string) args(string) ///
		[Missing Label LName(name) Truncate(numlist max=1 int >= 1) ///
		Ratio(string) Verbose METhod(string) noSORT]

	* TODO: support label lname truncate

	loc verbose = ("`verbose'" != "")
	loc sort = ("`sort'" != "nosort")
	_assert inlist("`method'", "", "stata", "mata", "hash0", "hash1", "gtools")
	_assert ("`by'" == ""), msg("by() not supported")
	if ("`ratio'"=="") loc ratio .

	local 0 `args' `if' `in'
	syntax varlist [if] [in]

	loc is_sorted = ("`: sortedby'" == "`varlist'") | (strpos("`: sortedby'", "`varlist' ")==1)
	* Note: we need the space after `varlist' to prevent "id10" being matched with "id1"

	if ("`missing'" == "" & !`is_sorted') {
		marksample touse, strok
	}
	else if ("`if'`in'" != "") {
		marksample touse, strok novarlist
	}
	else if (`is_sorted' & inlist("`method'", "", "stata")) {
		* Shortcut if already sorted
		loc method stata_sorted
	}

	* Choose method if not provided
	if ("`method'" == "") {
		loc usemata = (c(N) > 5e5) | (c(k) * c(N) > 5e6) | ("`touse'" != "")
		loc method = cond(`usemata', "mata", "stata")
	}

	// ----------------

	* If varlist mixes strings and integers, use alternative strategy
	loc n1 0
	loc n2 0
	
	foreach var of local varlist {
		loc type : type `var'
		if (substr("`type'", 1, 3) == "str") {
			loc ++n1
		}
		else {
			loc ++n2
		}
	}
	
	// ----------------

	loc problem = (`n1' > 0) & (`n2' > 0)
	if (`problem') {
		loc method stata
	}

	// ----------------

	if ("`method'" == "stata") {
		Group_FirstPrinciples `varlist' , id(`name') ///
			touse(`touse') verbose(`verbose')
	}
	else if ("`method'" == "stata_sorted") {
		Group_FirstPrinciplesSorted `varlist' , id(`name') ///
			missing("`missing'") verbose(`verbose')
	}
	else {
		cap noi {
			mata: F = factor("`varlist'", "`touse'", `verbose', "`method'", `sort', 0, `ratio', 0)
			mata: F.store_levels("`name'")
		}
		loc rc = c(rc)
		cap mata: mata drop F
		error `rc'
	}
	la var `name' "group(`varlist')"
end


program define Group_FirstPrinciples, sortpreserve
	syntax varlist, id(name) [touse(string) Verbose(integer 0)]
	if (`verbose') {
		di as smcl "{txt}(method: {res}stata{txt})"
	}

	if ("`touse'" == "") {
		bys `varlist': gen long `id' = (_n == 1)
		qui replace `id' = sum(`id')
	}
	else {
		qui bys `touse' `varlist': gen long `id' = (_n == 1) if `touse'
		qui replace `id' = sum(`id')
		qui replace `id' = . if (`touse' != 1)
	}
	qui compress `id'
end


program define Group_FirstPrinciplesSorted
	syntax varlist, id(name) [missing(string) Verbose(integer 0)]
	if (`verbose') {
		di as smcl "{txt}(method: {res}stata_sorted{txt})"
	}

	if ("`missing'" == "") {
		by `varlist': gen long `id' = (_n == 1)
		qui replace `id' = sum(`id')
	}
	else {
		mata: st_local("exp", invtokens("mi(" :+ tokens("`varlist'") :+ ")", " | "))
		tempvar hasmv
		gen byte `hasmv' = `exp'

		qui bys `touse' `varlist': gen long `id' = (_n == 1) if !`hasmv'
		qui replace `id' = sum(`id')
		qui replace `id' = . if `hasmv'
	}
	qui compress `id'
end


findfile "ftools.mata"
include "`r(fn)'"
exit
