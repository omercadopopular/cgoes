*! version 2.9.0 28mar2017
* This is just a modified version of Statacorp's -egen-
program define fegen, byable(onecall) // sortpreserve
version 10
	Parse `0'
	local byopt "by(`_byvars')"
	cap noi `filename' `if' `in', type(`type') name(`name') args(`args') `byopt' `options'
	if (_rc) {
		cap drop `name'
		exit _rc
	}
	qui count if missing(`name')
	if (`r(N)') {
		local val = plural(r(N), "value")
		di as text "(" r(N) " missing `val' generated)"
	}

	* MINIMUM SYNTAX OF A "fegen_ABC" FILE:
	* syntax [if] [in], type(string) name(string) args(string) [by(varlist)]
end

program define Parse
	* SYNTAX: fegen [type] newvar = fcn(args) [if] [in] [, options]

	* [type] newvar
	gettoken type 0 : 0, parse(" =(")
	gettoken name 0 : 0, parse(" =(")
	if `"`name'"'=="=" {
		local name `"`type'"'
		local type : set type
	}
	else {
		gettoken eqsign 0 : 0, parse(" =(")
		if `"`eqsign'"' != "=" {
			error 198
		}
	}
	confirm new variable `name'

	* fcn(args)
	gettoken fcn 0 : 0, parse(" =(")
	gettoken args 0 : 0, parse(" ,") match(par)
	local filename fegen_`fcn'
	capture qui findfile `filename'.ado
	if (`"`r(fn)'"' == "") {
		di as error "unknown ado file `fcn'()"
		exit 133
	}
	if `"`par'"' != "(" { 
		exit 198 
	}
	if `"`args'"' == "_all" | `"`args'"' == "*" {
		unab args : _all
		local args : list args - _sortindex
	}

	* [if] [in] [, options]
	syntax [if] [in] [, *]

	* Return results
	local params type name fcn filename args in if options
	foreach x of local params {
		* di as text "[`x'] = [" as result "``x''" as text "]"
		c_local `x' "``x''"
	}
end


/*
	Note, the utility routine should not present unnecessary messages
	and must return nonzero if there is a problem.  The new variable 
	can be left created or not; it will be automatically dropped.
	If the return code is zero, a count of missing values is automatically
	presented.
*/

