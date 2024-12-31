*! version 2011-Nov-23
* sapath "d:\seasonal adjustment/y1.out" "e:/pbc tj/y2.udg"
program sapath, rclass
version 11.0
syntax [anything]
if `"`anything'"' != `""' {
	tokenize `"`anything'"'
	local k=1
	while `"``k''"' != `""' {
		//dis "`k'; ``k''"
		local k=`k'+1
	}
	local k = `k'-1

	global prefmta ""
	forvalues i=1/`k' {
		local sk: word `i' of `anything'
		// dis "`sk'"
		tokenize `sk', parse("\/")
		local j=1
		while "``j''" != "" {
			//dis "`j'; ``j''"
			local j=`j'+1
		}
		local j = `j'-1
		local file "``j''"
		local len = length("`sk'")
		local lenf = length("`file'")
		local path = substr("`sk'", 1, `=`len'-`lenf'-1') // drop the last directory sepator
		if "`path'"=="" local path = "."
		tokenize `file', parse(".")
		global prefmta "$prefmta `1'"
		forvalues i=1/`k' {
			return local path`i' `"`path'"'
			return local file`i' `"`file'"'
		}
		return scalar nf = `k'
	}
}
end
