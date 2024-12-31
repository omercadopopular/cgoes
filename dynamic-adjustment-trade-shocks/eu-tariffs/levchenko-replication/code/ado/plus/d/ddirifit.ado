*! version 1.0.0 MLB 10Feb2010
program define ddirifit, rclas sortpreserve
	syntax [, at(string) ]
	if !inlist("`e(cmd)'", "dirifit", "fmlogit") {
		di as err "ddirifit and dfmlogit can only be used after dirifit or fmlogit"
		exit 198
	}
	if "`e(cmd)'" == "dirifit" & "`e(title)'" != "ML fit of Dirichlet (mu, phi)" {
		di as err "ddirifit is only possible with alternative parameterization"
		exit 198
	}
	
// to be filled in later	
	tempname atval meanx sdx minx maxx
	
// number of equations
	local k = e(k_eq) - cond("`e(cmd)'"=="dirifit", 1, 0)

// collect vars in each equation
	local cons "_cons"
	tempname b bb
	matrix `b' = e(b)
	local eqnames : coleq `b'
	local eqnames : list uniq eqnames
	forvalues i = 1/`k' {
		matrix `bb' = `b'[1,"`: word `i' of `eqnames'':"]
		local coln : colnames `bb'
		local coln : list uniq coln
		local vars`i' : list coln - cons
		local vars "`macval(vars)' `vars`i''"
	}
	matrix drop `b'
	

// g is matrix of derivatives 
// m = number of original coefficients
// n = number of transformed coefficients	
	local m : word count `vars'
	local m = `m' + `k' // adding the constants
	local vars : list uniq vars
	local n = (`k' + 1) * `: word count `vars''
	tempname g
	matrix `g' = J(`n',`m',.)
	
	forvalues i = 0/`k' {
		foreach var of varlist `vars' {
			local g_rown "`macval(g_rown)' p`i':`var'"
		}
	}
	forvalues i = 1/`k'{
		foreach var of varlist `vars`i'' {
			local g_coln "`macval(g_coln)' eq`i':`var'"
		}
		local g_coln "`macval(g_coln)' eq`i':_cons"
	}

	matrix rownames `g' = `g_rown'
	matrix colnames `g' = `g_coln'	
	
// collect variables not in equations	
	forvalues i = 1/`k' {
		local out`i' : list vars - vars`i'
	}
	
// collect info about variables and parse the at() option
	tempname partat atx
	if "`at'" != "" {
		tokenize `at'
		local end : word count `at'
		local length = `end'/2
				
		forvalues i = 1(2)`end' {
			capture unab `i' : ``i'', min(1) max(1)
			if _rc | !`: list `i' in vars' {
				di as err "every odd element in the at() option must be an explanatory variable"
				exit 198
			}
			local atvars "`atvars' ``i''"
		}
		local i = 1
		matrix `partat' = J(`length',5,0)
		foreach var of varlist `atvars' {
			local j = `i' *2
			if real("``j''") != . {
				quietly sum `var' if e(sample)
				matrix `partat'[`i',1] = ``j'', r(mean), r(sd), r(min), r(max)
			}
			else {
				quietly sum `var' if e(sample), detail 
				local stat = cond("``j''"=="median", "p50", "``j''")
				if !inlist("`stat'","mean", "min", "max", "p1", "p5", "p10") & ///
				   !inlist("`stat'", "p25", "p50", "p75", "p90", "p95", "p99") {
					di as err "every even element of the at() option must be either a number or"
					di as err "one statistic out of the following list:"
					di as err "mean, median, min, max, p1, p5, p10, p25, p50, p75, p90, p95, p99"
					exit 198
				}
				matrix `partat'[`i',1] = r(`stat'), /*
				   */ r(mean), r(sd), r(min), r(max)
			}
			local atvarlist "`atvarlist' `var'"
			local `++i'
		}
		matrix rownames `partat' = `atvarlist'
		matrix colnames `partat' = x mean sd min max
	}
	
	matrix `atx' = J(`: word count `vars'',5,0)
	local i = 1
	foreach var of local vars {
		if index("`atvarlist'", "`var'") != 0 {
			matrix `atx'[`i',1] = `partat'[rownumb(`partat',"`var'"),1..5]
		}
		else {
			quietly sum `var'
			matrix `atx'[`i',1] = r(mean), r(mean), r(sd), r(min), r(max)
		}
		local `++i'
	}
		
	matrix rownames `atx' = `vars'
	matrix colnames `atx' = x mean sd min max

// find dummy variables
	tempname mark touse
	qui gen byte `mark' = 0
	qui gen byte `touse' = e(sample)
	foreach var of varlist `vars' {
		qui replace `mark' = 0
		qui bys `touse' `var': replace `mark' = _n == 1 if `touse'
		sum `mark', meanonly
		if r(sum) == 2 {
			local dvars "`macval(dvars)' `var'"
		}
	}
	
// create xbs and denom		
	tempname denom xb
	scalar `denom' = 1
	matrix `xb' = J(`=`k'+1',1, 0)
	forvalues i = 1/`k' {
		tempname xb`i'
		scalar `xb`i'' = [#`i']_b[_cons]
		local rownum = `i'+1
		matrix `xb'[`rownum',1] = [#`i']_b[_cons]
		foreach var of varlist `vars`i'' {
			scalar `atval' = el(`atx',rownumb(`atx',"`var'"),1)
			scalar `xb`i'' = `xb`i'' + [#`i']_b[`var']*`atval'
			matrix `xb'[`rownum',1] = `xb'[`rownum',1] + [#`i']_b[`var']*`atval'
		}
		scalar `denom' = `denom' + exp(`xb`i'')
	}
	tempname xb0
	scalar `xb0' = 0

// create ps	
	tempname p
	matrix `p' = J(`=`k'+1',1,0)
	forvalues i = 0/`k' {
		local rownum = `i' + 1
		tempname p`i'
		scalar `p`i'' = exp(`xb`i'')/`denom'
		matrix `p'[`rownum',1] = exp(`xb'[`rownum',1])/`denom'
	}
	scalar drop `denom'
	
// mfx	

	tempname DpDb
	local end = (`: word count `vars''+1)*`k'
	matrix `DpDb' = J(`=`k'+1', `end', .)
	local end = (`: word count `vars''+1)
	forvalues i = 0/`k' {
		local rown_pr "`macval(rown_pr)' p`i'"
	}
	forvalues i = 1/`k' {
		foreach var in `vars' _cons {
			local coln_pr "`macval(coln_pr)' eq`i':`var'"
		}
	}
	matrix rowname `DpDb' = `rown_pr'
	matrix colname `DpDb' = `coln_pr'
	forvalues i = 0/`k'{
		local rownumi = `i'+1
		forvalues j = 1/`k'{
			local rownumj = `j' + 1
			matrix `DpDb'[`rownumi',`=`end'*`j''] = ///
			             -`p'[`rownumi',1]*`p'[`rownumj',1] + ///
			             (`i'==`j')*`p'[`rownumj',1]
			foreach var of varlist `vars`j'' {
				scalar `atval' = el(`atx',rownumb(`atx',"`var'"),1)
				matrix `DpDb'[`rownumi', colnumb(`DpDb',"eq`j':`var'")] = ///
				       `DpDb'[`rownumi', colnumb(`DpDb',"eq`j':_cons")] * `atval' 
			}
		}
	}
	tempname DvarbarDb
	local end = (`: word count `vars''+1)*`k'
	matrix `DvarbarDb' = J(`:word count `vars'', `end', 0)
	matrix colnames `DvarbarDb' = `coln_pr'
	matrix rownames `DvarbarDb'  = `vars'
	forvalues i = 1/`k' {
		foreach b in `vars`i'' _cons {
			foreach var of varlist `vars' {
				forvalues j = 1/`k'{
					if !`: list var in out`j'' {
						matrix `DvarbarDb'[rownumb(`DvarbarDb',"`var'"), colnumb(`DvarbarDb',"eq`i':`b'")] = ///
						       `DvarbarDb'[rownumb(`DvarbarDb',"`var'"), colnumb(`DvarbarDb',"eq`i':`b'")] + ///
							   [#`j']_b[`var']*`DpDb'[rownumb(`DpDb',"p`j'"),colnumb(`DpDb',"eq`i':`b'")] + ///
							   ("`var'"=="`b'" & `i'==`j')*`p'[`=`j'+1',1]
					}
				}
			}
		}
	}
	
	tempname varbar
	matrix `varbar' = J(`: word count `vars'',1,0)
	matrix rownames `varbar' = `vars'
	local rown = 1
	foreach var of varlist `vars' {
		forvalues i = 1/`k' {
			if !`:list var in out`i'' {
				matrix `varbar'[`rown',1] = `varbar'[`rown',1] + `p'[`=`i'+1',1]*[#`i']_b[`var']
			}
		}
		local `rown++'
	}
	
	local rownr = 1
	forvalues i = 0/`k'{
		foreach var of varlist `vars' {
			local colnr = 1
			forvalues j = 1/`k' {
				foreach b in `vars`j'' _cons {
					if `i' == 0 | `: list var in out`i'' {
						matrix `g'[`rownr', `colnr'] = 0 - `p'[`=`i'+1',1]*`DvarbarDb'[rownumb(`DvarbarDb',"`var'"), colnumb(`DvarbarDb',"eq`j':`b'")] - ///
						                              `varbar'[rownumb(`varbar',"`var'"),1]*`DpDb'[`=`i'+1',colnumb(`DpDb',"eq`j':`b'")]
					}
					else {
						matrix `g'[`rownr', `colnr'] =`DpDb'[`=`i'+1', colnumb(`DpDb',"eq`j':`b'")]*[#`i']_b[`var']  + ///
						                              (`i'==`j' & "`var'" == "`b'")*`p'[`=`i'+1', 1] ///
						                              - `p'[`=`i'+1',1]*`DvarbarDb'[rownumb(`DvarbarDb',"`var'"), colnumb(`DvarbarDb',"eq`j':`b'")] - ///
						                              `varbar'[rownumb(`varbar',"`var'"),1]*`DpDb'[`=`i'+1',colnumb(`DpDb',"eq`j':`b'")]
					}
					local `colnr++'
				}
			}
			local `rownr++'
		}
	}

	tempname V v semfx
	matrix `V' = e(V)
	matrix `V' = `V'[1 .. `m',1 .. `m']
	matrix `v' = `g'*`V'*`g''
	matrix `semfx' = vecdiag(cholesky(diag(vecdiag(`v'))))'
	
	tempname mfx
	matrix `mfx' = J(`n', 1, .)
	matrix rownames `mfx' = `g_rown'
	local j = 1
	forvalues i = 0/`k' {
		foreach var of varlist `vars' {
			if `i' == 0 | `:list var in out`i''{
				matrix `mfx'[`j++',1] = - `p'[`=`i'+1',1]*`varbar'[rownumb(`varbar', "`var'"),1]
			}
			else {
				matrix `mfx'[`j++',1] = `p'[`=`i'+1',1]*[#`i']_b[`var'] ///
				      - `p'[`=`i'+1',1]*`varbar'[rownumb(`varbar', "`var'"),1]
			}
		}
	}
	
// min --> max
	tempname xbmin xbmax
	matrix `xbmin' = J(`=`k'+1',`: word count `vars'',0)
	matrix `xbmax' = J(`=`k'+1',`: word count `vars'',0)
	forvalues i = 0/`k' {
		local rown_eq "`macval(rown_eq)' eq`i'"
	}
	matrix rowname `xbmin' = `rown_eq'
	matrix rowname `xbmax' = `rown_eq'
	matrix colname `xbmin' = `vars'
	matrix colname `xbmax' = `vars'
	
	forvalues i = 1/`k' {
		foreach var of varlist `vars' {
			if `: list var in out`i'' {
				matrix `xbmin'[`=`i'+1',colnumb(`xbmin',"`var'")] = `xb'[`=`i'+1', 1]
				matrix `xbmax'[`=`i'+1',colnumb(`xbmax',"`var'")] = `xb'[`=`i'+1', 1]
			}
			else {
				scalar `atval' = el(`atx',rownumb(`atx',"`var'"),1)
				scalar `minx' = el(`atx',rownumb(`atx',"`var'"),4)
				scalar `maxx' = el(`atx',rownumb(`atx',"`var'"),5)
				matrix `xbmin'[`=`i'+1',colnumb(`xbmin',"`var'")] = `xb'[`=`i'+1', 1] + [#`i']_b[`var']*(`minx' - `atval')
				matrix `xbmax'[`=`i'+1',colnumb(`xbmax',"`var'")] = `xb'[`=`i'+1', 1] + [#`i']_b[`var']*(`maxx' - `atval')
			}
		}
	}

	tempname denommin denommax
	matrix `denommin' = J(`: word count `vars'',1,1)
	matrix `denommax' = J(`: word count `vars'',1,1)
	matrix rownames `denommin' = `vars'
	matrix rownames `denommax' = `vars'
	local j = 1
	foreach var of varlist `vars' {
		forvalues i = 1/`k' {
			matrix `denommin'[`j',1] = `denommin'[`j',1] + exp(`xbmin'[`=`i'+1',colnumb(`xbmin',"`var'")])
			matrix `denommax'[`j',1] = `denommax'[`j',1] + exp(`xbmax'[`=`i'+1',colnumb(`xbmax',"`var'")])
		}
		local `j++'
	}

	tempname pmin pmax
	matrix `pmin' = J(`=`k'+1', `: word count `vars'', .)
	matrix `pmax' = J(`=`k'+1', `: word count `vars'', .)
	matrix rownames `pmin' = `rown_pr'
	matrix rownames `pmax' = `rown_pr'
	matrix colnames `pmin' = `vars'
	matrix colnames `pmax' = `vars'
	
	forvalues i = 0/`k' {
		foreach var of varlist `vars' {
			matrix `pmin'[`=`i'+1',colnumb(`pmin',"`var'")] = exp(`xbmin'[`=`i'+1',colnumb(`xbmin',"`var'") ])/`denommin'[rownumb(`denommin',"`var'"), 1]
			matrix `pmax'[`=`i'+1',colnumb(`pmax',"`var'")] = exp(`xbmax'[`=`i'+1',colnumb(`xbmax',"`var'") ])/`denommax'[rownumb(`denommax',"`var'"), 1]
		}
	}
	
	matrix `g' = J(`n',`m',.)
	matrix rownames `g' = `g_rown'
	matrix colnames `g' = `g_coln'	

	tempname DpminDb DpmaxDb
	matrix `DpminDb' = J(`=`=`k'+1'*`: word count `vars''', `=`=`:word count `vars'' + 1'*`k'',. )
	matrix `DpmaxDb' = J(`=`=`k'+1'*`: word count `vars''', `=`=`:word count `vars'' + 1'*`k'',. )
	forvalues i = 0 / `k' {
		foreach var of varlist `vars' {
			local rown_pvar "`macval(rown_pvar)' p`i':`var'" 
		}
	}
	matrix rownames `DpminDb' = `rown_pvar'
	matrix rownames `DpmaxDb' = `rown_pvar'
	matrix colnames `DpminDb' = `coln_pr'
	matrix colnames `DpmaxDb' = `coln_pr'

	forvalues i = 0/`k'{
		forvalues j = 1/`k'{
			foreach var of varlist `vars' {
				matrix `DpminDb'[rownumb(`DpminDb', "p`i':`var'"),colnumb(`DpminDb',"eq`j':_cons")] = ///
				       -`pmin'[`=`i'+1', colnumb(`pmin',"`var'")]*`pmin'[`=`j'+1', colnumb(`pmin',"`var'")] + ///
					   (`i'==`j')* `pmin'[`=`j'+1', colnumb(`pmin',"`var'")]
				matrix `DpmaxDb'[rownumb(`DpmaxDb', "p`i':`var'"),colnumb(`DpmaxDb',"eq`j':_cons")] = ///
				       -`pmax'[`=`i'+1', colnumb(`pmax',"`var'")]*`pmax'[`=`j'+1', colnumb(`pmax',"`var'")] + ///
					   (`i'==`j')* `pmax'[`=`j'+1', colnumb(`pmax',"`var'")]	
				foreach b of varlist `vars`j'' {
					scalar `atval' = el(`atx',rownumb(`atx',"`var'"),1)
					scalar `minx' = el(`atx',rownumb(`atx',"`var'"),4)
					scalar `maxx' = el(`atx',rownumb(`atx',"`var'"),5)
					matrix `DpminDb'[rownumb(`DpminDb', "p`i':`var'"),colnumb(`DpminDb',"eq`j':`b'")] = ///
					       `DpminDb'[rownumb(`DpminDb', "p`i':`var'"),colnumb(`DpminDb',"eq`j':_cons")] * cond("`var'"=="`b'", `minx' ,`atval')
					matrix `DpmaxDb'[rownumb(`DpmaxDb', "p`i':`var'"),colnumb(`DpmaxDb',"eq`j':`b'")] = ///
					       `DpmaxDb'[rownumb(`DpmaxDb', "p`i':`var'"),colnumb(`DpmaxDb',"eq`j':_cons")] * cond("`var'"=="`b'", `maxx' ,`atval')
				}
			}
		}
	}

	local rownr = 1
	forvalues i = 0/`k'{
		foreach var of varlist `vars' {
			local colnr = 1
			forvalues j = 1/`k' {
				foreach b in `vars`j'' _cons {
					matrix `g'[`rownr', `colnr'] = `DpmaxDb'[rownumb(`DpmaxDb',"p`i':`var'"),colnumb(`DpmaxDb',"eq`j':`b'")] - ///
					                               `DpminDb'[rownumb(`DpmaxDb',"p`i':`var'"),colnumb(`DpminDb',"eq`j':`b'")] 
					local `colnr++'
				}
			}
			local `rownr++'
		}
	}
	
	tempname seminmax
	matrix `v' = `g'*`V'*`g''
	matrix `seminmax' = vecdiag(cholesky(diag(vecdiag(`v'))))'
	
	tempname minmax
	matrix `minmax' = J(`n',1,.)
	matrix rownames `minmax' = `g_rown'
	local j = 1
	forvalues i = 0/`k' {
		foreach var of varlist `vars' {
			matrix `minmax'[`j',1] = `pmax'[`=`i'+1', colnumb(`pmax',"`var'")] - `pmin'[`=`i'+1',colnumb(`pmin',"`var'")]
			local `j++'
		}
	}
// +/- SD
	forvalues i = 1/`k' {
		foreach var of varlist `vars' {
			if `: list var in out`i'' {
				matrix `xbmin'[`=`i'+1',colnumb(`xbmin',"`var'")] = `xb'[`=`i'+1', 1]
				matrix `xbmax'[`=`i'+1',colnumb(`xbmax',"`var'")] = `xb'[`=`i'+1', 1]
			}
			else {
				scalar `sdx' = el(`atx',rownumb(`atx',"`var'"),3)
				matrix `xbmin'[`=`i'+1',colnumb(`xbmin',"`var'")] = `xb'[`=`i'+1', 1] - [#`i']_b[`var']*`sdx'/2
				matrix `xbmax'[`=`i'+1',colnumb(`xbmax',"`var'")] = `xb'[`=`i'+1', 1] + [#`i']_b[`var']*`sdx'/2
			}
		}
	}	
	
	matrix `denommin' = J(`: word count `vars'',1,1)
	matrix `denommax' = J(`: word count `vars'',1,1)
	matrix rownames `denommin' = `vars'
	matrix rownames `denommax' = `vars'
	local j = 1
	foreach var of varlist `vars' {
		forvalues i = 1/`k' {
			matrix `denommin'[`j',1] = `denommin'[`j',1] + exp(`xbmin'[`=`i'+1',colnumb(`xbmin',"`var'")])
			matrix `denommax'[`j',1] = `denommax'[`j',1] + exp(`xbmax'[`=`i'+1',colnumb(`xbmax',"`var'")])
		}
		local `j++'
	}
	
	forvalues i = 0/`k' {
		foreach var of varlist `vars' {
			matrix `pmin'[`=`i'+1',colnumb(`pmin',"`var'")] = exp(`xbmin'[`=`i'+1',colnumb(`xbmin',"`var'") ])/`denommin'[rownumb(`denommin',"`var'"), 1]
			matrix `pmax'[`=`i'+1',colnumb(`pmax',"`var'")] = exp(`xbmax'[`=`i'+1',colnumb(`xbmax',"`var'") ])/`denommax'[rownumb(`denommax',"`var'"), 1]
		}
	}
	
	matrix `g' = J(`n',`m',.)
	matrix rownames `g' = `g_rown'
	matrix colnames `g' = `g_coln'	

	forvalues i = 0/`k'{
		forvalues j = 1/`k'{
			foreach var of varlist `vars' {
				matrix `DpminDb'[rownumb(`DpminDb', "p`i':`var'"),colnumb(`DpminDb',"eq`j':_cons")] = ///
				       -`pmin'[`=`i'+1', colnumb(`pmin',"`var'")]*`pmin'[`=`j'+1', colnumb(`pmin',"`var'")] + ///
					   (`i'==`j')* `pmin'[`=`j'+1', colnumb(`pmin',"`var'")]
				matrix `DpmaxDb'[rownumb(`DpmaxDb', "p`i':`var'"),colnumb(`DpmaxDb',"eq`j':_cons")] = ///
				       -`pmax'[`=`i'+1', colnumb(`pmax',"`var'")]*`pmax'[`=`j'+1', colnumb(`pmax',"`var'")] + ///
					   (`i'==`j')* `pmax'[`=`j'+1', colnumb(`pmax',"`var'")]	
				foreach b of varlist `vars`j'' {
					scalar `atval' = el(`atx',rownumb(`atx',"`var'"),1)
					scalar `sdx' = el(`atx',rownumb(`atx',"`var'"),3)
					matrix `DpminDb'[rownumb(`DpminDb', "p`i':`var'"),colnumb(`DpminDb',"eq`j':`b'")] = ///
					       `DpminDb'[rownumb(`DpminDb', "p`i':`var'"),colnumb(`DpminDb',"eq`j':_cons")] * cond("`var'"=="`b'", `atval'-`sdx'/2  ,`atval')
					matrix `DpmaxDb'[rownumb(`DpmaxDb', "p`i':`var'"),colnumb(`DpmaxDb',"eq`j':`b'")] = ///
					       `DpmaxDb'[rownumb(`DpmaxDb', "p`i':`var'"),colnumb(`DpmaxDb',"eq`j':_cons")] * cond("`var'"=="`b'", `atval'+`sdx'/2  ,`atval')
				}
			}
		}
	}	
	local rownr = 1
	forvalues i = 0/`k'{
		foreach var of varlist `vars' {
			local colnr = 1
			forvalues j = 1/`k' {
				foreach b in `vars`j'' _cons {
					matrix `g'[`rownr', `colnr'] = `DpmaxDb'[rownumb(`DpmaxDb',"p`i':`var'"),colnumb(`DpmaxDb',"eq`j':`b'")] - ///
					                               `DpminDb'[rownumb(`DpmaxDb',"p`i':`var'"),colnumb(`DpminDb',"eq`j':`b'")] 
					local `colnr++'
				}
			}
			local `rownr++'
		}
	}

	tempname sesd
	matrix `v' = `g'*`V'*`g''
	matrix `sesd' = vecdiag(cholesky(diag(vecdiag(`v'))))'
	
	tempname sd
	matrix `sd' = J(`n',1,.)
	matrix rownames `sd' = `g_rown'
	local j = 1
	forvalues i = 0/`k' {
		foreach var of varlist `vars' {
			matrix `sd'[`j',1] = `pmax'[`=`i'+1', colnumb(`pmax',"`var'")] - `pmin'[`=`i'+1',colnumb(`pmin',"`var'")]
			local `j++'
		}
	}	
	// +/- one
	forvalues i = 1/`k' {
		foreach var of varlist `vars' {
			if `: list var in out`i'' {
				matrix `xbmin'[`=`i'+1',colnumb(`xbmin',"`var'")] = `xb'[`=`i'+1', 1]
				matrix `xbmax'[`=`i'+1',colnumb(`xbmax',"`var'")] = `xb'[`=`i'+1', 1]
			}
			else {
				matrix `xbmin'[`=`i'+1',colnumb(`xbmin',"`var'")] = `xb'[`=`i'+1', 1] - [#`i']_b[`var']*1/2
				matrix `xbmax'[`=`i'+1',colnumb(`xbmax',"`var'")] = `xb'[`=`i'+1', 1] + [#`i']_b[`var']*1/2
			}
		}
	}
	matrix `denommin' = J(`: word count `vars'',1,1)
	matrix `denommax' = J(`: word count `vars'',1,1)
	matrix rownames `denommin' = `vars'
	matrix rownames `denommax' = `vars'
	local j = 1
	foreach var of varlist `vars' {
		forvalues i = 1/`k' {
			matrix `denommin'[`j',1] = `denommin'[`j',1] + exp(`xbmin'[`=`i'+1',colnumb(`xbmin',"`var'")])
			matrix `denommax'[`j',1] = `denommax'[`j',1] + exp(`xbmax'[`=`i'+1',colnumb(`xbmax',"`var'")])
		}
		local `j++'
	}
	
	forvalues i = 0/`k' {
		foreach var of varlist `vars' {
			matrix `pmin'[`=`i'+1',colnumb(`pmin',"`var'")] = exp(`xbmin'[`=`i'+1',colnumb(`xbmin',"`var'") ])/`denommin'[rownumb(`denommin',"`var'"), 1]
			matrix `pmax'[`=`i'+1',colnumb(`pmax',"`var'")] = exp(`xbmax'[`=`i'+1',colnumb(`xbmax',"`var'") ])/`denommax'[rownumb(`denommax',"`var'"), 1]
		}
	}
	
	matrix `g' = J(`n',`m',.)
	matrix rownames `g' = `g_rown'
	matrix colnames `g' = `g_coln'	

	forvalues i = 0/`k'{
		forvalues j = 1/`k'{
			foreach var of varlist `vars' {
				matrix `DpminDb'[rownumb(`DpminDb', "p`i':`var'"),colnumb(`DpminDb',"eq`j':_cons")] = ///
				       -`pmin'[`=`i'+1', colnumb(`pmin',"`var'")]*`pmin'[`=`j'+1', colnumb(`pmin',"`var'")] + ///
					   (`i'==`j')* `pmin'[`=`j'+1', colnumb(`pmin',"`var'")]
				matrix `DpmaxDb'[rownumb(`DpmaxDb', "p`i':`var'"),colnumb(`DpmaxDb',"eq`j':_cons")] = ///
				       -`pmax'[`=`i'+1', colnumb(`pmax',"`var'")]*`pmax'[`=`j'+1', colnumb(`pmax',"`var'")] + ///
					   (`i'==`j')* `pmax'[`=`j'+1', colnumb(`pmax',"`var'")]	
				foreach b of varlist `vars`j'' {
					scalar `atval' = el(`atx',rownumb(`atx',"`var'"),1)
					matrix `DpminDb'[rownumb(`DpminDb', "p`i':`var'"),colnumb(`DpminDb',"eq`j':`b'")] = ///
					       `DpminDb'[rownumb(`DpminDb', "p`i':`var'"),colnumb(`DpminDb',"eq`j':_cons")] * cond("`var'"=="`b'", `atval'-1/2  ,`atval')
					matrix `DpmaxDb'[rownumb(`DpmaxDb', "p`i':`var'"),colnumb(`DpmaxDb',"eq`j':`b'")] = ///
					       `DpmaxDb'[rownumb(`DpmaxDb', "p`i':`var'"),colnumb(`DpmaxDb',"eq`j':_cons")] * cond("`var'"=="`b'", `atval'+1/2  ,`atval')
				}
			}
		}
	}	
	
	local rownr = 1
	forvalues i = 0/`k'{
		foreach var of varlist `vars' {
			local colnr = 1
			forvalues j = 1/`k' {
				foreach b in `vars`j'' _cons {
					matrix `g'[`rownr', `colnr'] = `DpmaxDb'[rownumb(`DpmaxDb',"p`i':`var'"),colnumb(`DpmaxDb',"eq`j':`b'")] - ///
					                               `DpminDb'[rownumb(`DpmaxDb',"p`i':`var'"),colnumb(`DpminDb',"eq`j':`b'")] 
					local `colnr++'
				}
			}
			local `rownr++'
		}
	}	
	
	tempname seone
	matrix `v' = `g'*`V'*`g''
	matrix `seone' = vecdiag(cholesky(diag(vecdiag(`v'))))'
	
	tempname one
	matrix `one' = J(`n',1,.)
	matrix rownames `one' = `g_rown'
	local j = 1
	forvalues i = 0/`k' {
		foreach var of varlist `vars' {
			matrix `one'[`j',1] = `pmax'[`=`i'+1', colnumb(`pmax',"`var'")] - `pmin'[`=`i'+1',colnumb(`pmin',"`var'")]
			local `j++'
		}
	}	

/* Display results */
	local dep "`e(depvars)'"
	di in text "{hline 14}{c TT}{hline 64}
	di in text "discrete" _col(15) "{c |}  Min --> Max                +-SD/2                  +-1/2" 
	di in text "change"   _col(15) "{c |}  coef.     se            coef.     se            coef.     se"
	di in text "{hline 14}{c +}{hline 64}
	local j = 1
	forvalues i = 1/`=`k'+1' {
		di as result %-13s abbrev("`: word `i' of `dep''",12) in text _col(15) "{c |}"
		foreach var of local vars{
			if `: list var in dvars' {
				output_line `var' `minmax'[`j',1] `seminmax'[`j',1] 
			}
			else{
				output_line `var' `minmax'[`j',1] `seminmax'[`j',1] `sd'[`j',1] `sesd'[`j',1]  /*
								*/ `one'[`j',1] `seone'[`j',1]
			}
			local `j++'
		}
		if `i' != `=`k'+1' di in text "{hline 14}{c +}{hline 64}
		else di in text "{hline 14}{c BT}{hline 64}
	}
	
	di _newline(1)
	
	di in text "{hline 14}{c TT}{hline 17}
	di in text "Marginal"  _col(15) "{c |}    MFX at x  " 
	di in text "Effects"   _col(15) "{c |}  coef.     se"
	di in text "{hline 14}{c +}{hline 17}
	
	local j = 1
	forvalues i = 1/`=`k'+1' {
		di as result %-13s abbrev("`: word `i' of `dep''",12) in text _col(15) "{c |}" 
		foreach var of local vars{
			if !`:list var in dvars' {
				output_line `var' `mfx'[`j',1] `semfx'[`j',1] 
			}
			local `j++'
		}
		if `i' != `=`k'+1' di in text "{hline 14}{c +}{hline 17}
		else di in text "{hline 14}{c BT}{hline 17}
	}
	
	di _newline(1)
	forvalues i = 0/`k' {
		di in text "E(" abbrev("`: word `=`i'+1' of `dep''",12) "|x) = " _col(21) as result %6.0g `p`i''
	}
	
	di _newline(1)
		
	matrix list `atx', noheader noblank format(%6.0g) 
	
	return matrix atx = `atx'
	return matrix mfx = `mfx'
	return matrix semfx = `semfx'
	return matrix one = `one'
	return matrix seone = `seone'
	return matrix sd = `sd'
	return matrix sesd = `sesd'
	return matrix minmax = `minmax'
	return matrix seminmax = `seminmax'
end

program output_line
	args var b1 se1 b2 se2 b3 se3
	noi di in text %13s abbrev("`var'",12) " {c |}" /*
	   */ as result /*
	   */          %6.0g `b1' _col(25) %6.0g `se1' /*
	   */ _col(39) %6.0g `b2' _col(49) %6.0g `se2' /*
	   */ _col(62) %6.0g `b3' _col(72) %6.0g `se3' 
end

