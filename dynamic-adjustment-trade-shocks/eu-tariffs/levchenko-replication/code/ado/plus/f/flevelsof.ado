*! version 2.20.0 10oct2017
program define flevelsof, rclass
	syntax varname [if] [in] , [ ///
	/// 1) Options inherited from levelsof
		Clean /// returns <IBM Doe Run> instead of <`"IBM"' `"Doe Run"'>
		LOCal(str) /// also stores result in a given local
		MIssing /// include missing values of varname
		Separate(str) /// token separator (default is space)
	/// 2) Options specific to ftools
		FORCEmata ///
		Verbose ///
		METHOD(string) ///
	]

	* Use -levelsof- for small datasets
	if (c(N)<1e6) & ("`forcemata'"=="") {
		// TODO: replace this with a call to -tab `varlist',nol m- but only for numeric values
		levelsof `varlist' `if' `in', separate(`separate') `missing' local(vals) `clean'
	}
	else {
		_assert (c(N)), msg("no observations") rc(2000)
	
		* Only create `touse' if needed
		if (`"`if'`in'"' != "") {
			marksample touse, novarlist
			// faster alternative to -count if `touse'-
			if (`touse'[1]==0) {
				timer on 11
				su `touse', mean
				timer off 11
				if (!`r(max)') {
					di as txt "(no observations)"
					return local levels = ""
					return scalar num_levels = 0
					if ("`local'" != "") c_local `local' `"`vals'"'
					exit
				}
			}
		}

		/*
		if (`"`if'`in'"' != "" | "`missing'" == "") {
			if ("`missing'" != "") loc novarlist "novarlist"
			timer on 10
			marksample touse, strok `novarlist'
			timer off 10
			// faster alternative to -count if `touse'-
			if (`touse'[1]==0) {
				timer on 11
				su touse, mean
				timer off 11
				if (`r(max)') {
					di as txt "(no observations)"
					exit
				}
			}
		}
		*/
		
		loc clean = ("`clean'"!="")
		loc verbose = ("`verbose'" != "")
		loc keepmissing = ("`missing'" != "")
		if ("`separate'" == "") loc separate " "
		loc isnum = strpos("`: type `varlist''", "str")==0

		mata: flevelsof("`varlist'", "`touse'", `verbose', "`method'", ///
		                `keepmissing', `isnum', `clean', "`separate'", ///
		                `c(max_macrolen)')
		return add
		di as txt `"`vals'"'
		return local levels `"`vals'"'
	}

	if ("`local'" != "") {
		c_local `local' `"`vals'"'
	}
end

findfile "ftools.mata"
include "`r(fn)'"

mata:
mata set matastrict on

void flevelsof(`String' varlist,
               `String' touse,
               `Boolean' verbose,
               `String' method,
               `Boolean' keepmissing,
               `Boolean' isnum,
               `Boolean' clean,
               `String' sep,
               `Integer' maxlen)
{
	`Factor'				F
	`DataRow'				keys
	`String'				ans

	F = factor(varlist, touse, verbose, method, 1, 0, ., 1)
	keys = keepmissing ? F.keys' : filter_missing(F.keys)'
	st_numscalar("r(num_levels)", cols(keys))

	if (!cols(keys)) exit()

	if (isnum) {
		keys = strofreal(keys, "%40.10g")
	}
	else if (!clean) {
		keys = (char(96) + char(34)) :+ keys :+ (char(34) + char(39))
	}

	ans = invtokens(keys, sep)
	if (strlen(ans)>maxlen) {
		printf("{err}macro length exceeded\n")
		exit(1000)
	}
	st_local("vals", ans)
}


`DataFrame' filter_missing(`DataCol' x)
{
	`Vector' v
	assert(cols(x)==1)
	v = eltype(x)=="string" ? (x :!= missingof(x)) : rownonmissing(x)
	return(select(x, v))
}

end

exit
