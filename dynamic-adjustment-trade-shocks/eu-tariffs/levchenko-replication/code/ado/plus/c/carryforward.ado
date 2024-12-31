/*
carryforward.ado  7-29-2004

David Kantor
Institute for Policy Studies; Johns Hopkins University


Given a series of data in long shape, make an alternative version that
carries-forward values to fill in for missings.

This was originally in ..\psid003\prep264.do (with some hard-codings).

It would be nice to be able to enforce either stability or uniquness in the
sort.  But presently, we can't.  I've sent messages to Stata about this
(7-21- & 7-29-2004).  For now, we let the calling routine pre-sort it, or
just know that varlist2 (which is presumably used in the invocation) makes
a key with varlist1.

I have asked for a -unique- and/or -stable- option -- as well as access to
varlist2.  As soon as these become availble, use them in the calls to this.

Same for gen_tail, from which some code was borrowed.

4-6-2005: adding -if- and -in-.

2013feb6 attempting to make this handle multiple vars -- as requested from a
user several years ago.
2013feb15: adding the -strict- option.

2013apr19: adding dynamic_condition option.
2013apr24: just editing "*! version"

2013may4: change from @val to @.
2013july25: use clonevar; changed the use of notes and labelling; cleaned out unnecessary code (gen_orig);

2014may16: nonotes option.
2016jan15: ~~attempting to implement an extmiss option 

*/

*! version 4.5 2016jan15
* previous 4.4 2014may16
* previous 4.3 2013july25
* previous 4.2 2013apr24
* previous 4.1 2013feb15
* previous 3.2; 4-6-2005
* previous  3; 8-11-2004




program def carryforward, byable(onecall)
version 8.2

syntax varlist [if] [in], [gen(namelist) replace cfindic(namelist) back carryalong(varlist) strict ///
	dynamic_condition(string) debug nonotes extmiss]
marksample touse, novarlist

/*
cfindic is an indicator -- that a value is carried-forward (or back).

-back- is just some info affecting for the var label -- in case the actual
direction is backward instead of forward.  It does not control which direction
the carry operation goes; that always goes forward.  But there may be times
that you go backwards by giving it a sort variable that is the negative of
another.  For example,
 gen int negyear = -year
 bysort id (negyear): carryforward m, gen(m2) back

dynamic_condition allows you to put conditions on what gets carried, based on
values that evolve in the process of carrying the data.
e.g. dynamic_condition(var1[_n-1] < var2).
You can use @ to represent the value being carried. It represents `ggg'[_n-1]
where `ggg' is the variable being carried.

extmiss: treat extended missing values as legitimate; carry values into . only,
and potentially carry extended missing values.

*/




if "`gen'"=="" & "`replace'" =="" {
 disp as err "you must specify either gen or replace"
 exit 198
}
if "`gen'"~="" & "`replace'" ~="" {
 disp as err "you may not specify both gen and replace"
 exit 198
}


local fwdback
if "`back'" ~= "" {
 local fwdback " (backward)"
}


local numvars: list sizeof varlist
local numgens: list sizeof gen
local numcfindic: list sizeof cfindic

if "`carryalong'" ~= "" & `numvars' >1 {
	disp as err "carryalong may not be specified if varlist has more than one variable"
	exit 198
} 

if `numgens' >0 {
	confirm new var `gen'
	if `numgens' ~= `numvars' {
		disp as err "there must be as many variables in gen as in varlist"
		exit 198
	} 
}

if `numcfindic' >0 {
	confirm new var `cfindic'
	if `numcfindic' ~= `numvars' {
		disp as err "there must be as many variables in cfindic as in varlist"
		exit 198
	} 
	local overlap: list cfindic & gen
	if "`overlap'" ~= "" {
		disp as err "cfindic and gen may not have elements in common"
		exit 198
	}
}


if _by() {
	local by "by `_byvars' :"
}

if "`strict'" ~= "" {
	local strictcondition " & `touse'[_n-1]"
}

local jj = 1
foreach v of local varlist {

	local type1: type `v'

	local ggg: word `jj' of `gen'
	local ggo "`ggg'"
	local ccc: word `jj' of `cfindic'

	if "`ggg'"~="" {
		quietly clonevar `ggg' = `v'
	}
	else { // must be -replace-
		local ggg "`v'" // and operate directly in `v' under the name ggg.
		if "`ccc'" ~= "" | "`carryalong'" ~= "" {
			tempvar origvalues
			quietly gen `type1' `origvalues' = `v'
		}
	}

	disp "`ggg': ", _continue

	local dynamic_condition2
	if "`dynamic_condition'" ~= "" {
		local dynamic_condition2 " & (`=subinstr("`dynamic_condition'", "@", "`ggg'[_n-1]", .)')"
	}
	local numeric 0
	capture confirm numeric var `ggg'
	if ~_rc {
		local numeric 1
	}
	local misvalcondition
	if "`extmiss'" == "" | ~`numeric' {
		local misvalcondition "mi(`ggg') & ~mi(`ggg'[_n-1])"
	}
	else {
		local misvalcondition "(`ggg'==.) & (`ggg'[_n-1]~=.)"
	}

	if "`debug'" ~= "" {
		disp "~~~~"
		disp "`by' replace `ggg' = `ggg'[_n-1] if _n>1 & `touse' & `misvalcondition' `strictcondition' `dynamic_condition2'"
	}

	`by' replace `ggg' = `ggg'[_n-1] if _n>1 & `touse' & `misvalcondition' ///
		`strictcondition' `dynamic_condition2'

	if "`ccc'" =="" & "`carryalong'" ~= "" {
			/* Need ccc, but make it a temp */
			tempvar ccc
		}

	if "`ccc'" ~= "" {
		if "`ggo'"~="" {
			gen byte `ccc' = `ggg' ~= `v'
		}
		else { // must be -replace-
			gen byte `ccc' = `ggg' ~= `origvalues'
		}
		label var `ccc' "`ggg' has a carryforward`fwdback' value"
		assert ~mi(`ggg') if `ccc'
	}
	if "`notes'" == "" {
		notes `ggg': subjected to a carryforward`fwdback' operation
	}
	if "`carryalong'" ~= "" {
		tempvar t002
		foreach var of local carryalong {
			local type2: type `var'
			quietly gen `type2' `t002' = `var'
			quietly `by' replace `var' = `var'[_n-1] if _n>1 & `ccc'
			quietly count if `var' ~= `t002'
			local nchanges = r(N)
			disp as txt "(`var': `nchanges' changes made)"
			if "`notes'" == "" {
				notes `var': subjected to a carryforward`fwdback' operation as a carryalong variable, along with `v'
			}
			drop `t002'
		}
	}

	local ++jj
} /* end main loop */
	
end // carryforward
