*! 1.0.0 MLB 11 Feb 2010

program define dirifit_p
        version 8.2

	syntax [anything] [if] [in] [,  ///
		PR              	        ///
	    XB							///
		STDP						///
		SCores                  	///
		EQuation(passthru)      	///
		OUTcome(varname)        	///
		*                       	///  
		]
	/*Parsing new variables*/
	sreturn clear
	local depvars "`e(depvars)'"
	local k : word count `depvars'
	
	if "`xb'`stdp'`scores'" != "" {
		local ncat = `k' - 1
	}
	else {
		local ncat = `k'
	}
	if c(stata_version) < 9 {
		if "`pr'" != "" {
			di as err "the pr option is only available from Stata 9 and higher"
			exit 198
		}
		_predict `0'
		exit
	}
	_stubstar2names `anything', nvars(`ncat') singleok
	local varlist    "`s(varlist)'"
	local typelist   "`s(typelist)'"

	if "`xb'`stdp'`scores'" != "" & "`outcome'" != "" {
		di as err "option outcome() may not be combined with option `xb'`stdp'`scores'"
		exit 198
	}
	if ("`xb'`stdp'`scores'`pr'" == "" | "`pr'" != "") & "`equation'" != "" {
		di as err "option equation() may not be combined with option pr"
		exit 198
	}

* scores */
	if "`score'" != "" {
		GenScores `varlist' `if' `in', `eqn'
		sret clear
		exit
	}
/* XB, or STDP. */
	if "`xb'"!= "" | "`stdp'" != "" {
		_predict `typlist' `varlist' `if' `in', `xb' `stdp' `equation'
		if "`xb'" != ""  {
			label var `varlist' /*
			*/ "Linear prediction for equation `eq'"
		}
		else { /* stdp */
			label var `varlist' /*
			*/ "S.E. of linear prediction for equation `eq'"
		}
		exit
	}

/* single pr*/
	if ("`pr'" != "" | "`pr'`xb'`stdp'`scores'" == "") & `: word count `varlist'' == 1 {
		gettoken ref rest : depvars
		if "`outcome'" == "" {
			// the default outcome is the first depvar, i.e. the reference category
			local outcome "`ref'"
		}
		if !`: list outcome in depvars' {
			di as err ///
			"variable specified in outcome() must be one of `depvars'"
			exit 198
		}
		if "`e(title)'" == "ML fit of Dirichlet (mu, phi)" { 
			local i = 1
			tempvar denom
			qui gen double `denom' = 1
			foreach eq of local rest {
				tempvar xb`i'
				qui _predict double `xb`i'', xb equation(#`i')
				qui replace `denom' = `denom' + exp(`xb`i'')
				local `i++'
			}
			local k : list posof "`outcome'" in depvars
			if `k' == 1 {
				gen `typelist' `varlist' = 1/`denom'
				label variable `varlist' "predicted proportion for outcome `outcome'"
			}
			else {
				gen `typelist' `varlist' = exp(`xb`=`k'-1'')/`denom'
				label variable `varlist' "predicted proportion for outcome `outcome'"
			}
		}
		else {
			tempvar denom
			qui gen double `denom' = 0
			forvalues i = 1/`: word count `depvars'' {
				tempvar xb`i'
				qui _predict double `xb`i'', xb equation(#`i')
				qui replace `denom' = `denom' + exp(`xb`i'')
			}
			local k : list posof "`outcome'" in depvars
			gen `typlist' `varlist' = exp(`xb`k'')/`denom'
			label variable `varlist' "predicted proportion for outcome `outcome'"
		}
		exit
	}
/* multiple pr*/
	if ("`pr'" != "" | "`pr'`xb'`stdp'`scores'" == "") & `: word count `varlist'' > 1 {
		if "`e(title)'" == "ML fit of Dirichlet (mu, phi)" {
			gettoken ref rest : depvars
			local i = 1
			tempvar denom
			qui gen double `denom' = 1
			foreach eq of local rest {
				tempvar xb`i'
				qui _predict double `xb`i'', xb equation(#`i')
				qui replace `denom' = `denom' + exp(`xb`i'')
				local `i++'
			}
			tokenize `typelist'
			local j = 1
			foreach var of local varlist {
				if `j' == 1 {
					gen ``j'' `var' = 1/`denom'
					label variable `var' "predicted proportion for outcome `: word `j' of `depvars''"
				}
				else {
					gen ``j'' `var' = exp(`xb`=`j'- 1'')/`denom'
					label variable `var' "predicted proportion for outcome `: word `j' of `depvars''"
				}
				local `j++'
			}
		}
		else {
			tempvar denom
			qui gen double `denom' = 0
			forvalues i = 1/`: word count `depvars'' {
				tempvar xb`i'
				qui _predict double `xb`i'', xb equation(#`i')
				qui replace `denom' = `denom' + exp(`xb`i'')
			}
			local j = 1
			tokenize `typelist'
			foreach var of local varlist {
				gen ``j'' `var' = exp(`xb`j'')/`denom'
				label variable `var' "predicted proportion for outcome `: word `j' of `depvars''"
			}
		}
		exit
	}

	exit 198
end

program GenScores
        version 8.2
        syntax [newvarlist] [if] [in] [, equation(passthru) ]
        marksample touse, novarlist
        
        ml score `varlist' if `touse', `equation'
end
