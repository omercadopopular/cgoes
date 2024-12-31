*! version 1.0 by David Roodman 21Oct2002
* slightly modified version of vif, version 1.4.9  05sep2001
program define neweyvif, rclass sort
	version 6.0

/*	_isfit cons */
	if "`e(model)'" != "ols" { exit 301 }

	if `"`0'"' != "" { 
		error 198 
	}

	tempvar touse
	qui gen byte `touse' = e(sample)

	_getrhs varlist
	local if	"if `touse'"
	local wgt	`"`e(wtype)'"'
	local exp	`"`e(wexp)'"'

	local wtexp = `""'
	if `"`wgt'"' != `""' & `"`exp'"' != `""' {
		local wtexp = `"[`wgt'`exp']"'
	}

	tokenize `varlist'
	local ovars `""'
	local i 1 
	while `"``i''"' != `""' {
		local found 0
		foreach item of local ovars {
			if "`item'" == "``i''" {
				local found 1
			}
		}
		if !`found' & _b[``i''] {
			local ovars `"`ovars' ``i'' "'
		}
		local i = `i'+1
	}
	local nvif : word count `ovars'

	tempname ehold vif mvif 
	scalar `mvif' = 0.0
	quietly {
		noi di
		noi di in smcl in gr /*
		*/ "    Variable {c |}       VIF       1/VIF  "
		noi di in smcl in gr "{hline 13}{c +}{hline 22}"
		local i 1
		local nv 0
		estimate hold `ehold'

		tempname nms vvv
		gen str8 `nms' = `""'
		gen `vvv' = .
		capture {
			while `i' <= `nvif' {
				tokenize `ovars'
				local ind
				local vc 1
				while `vc' < `i' {
					local ind `"`ind' ``vc''"'
					local vc = `vc'+1
				}
				local vc = `i'+1
				while `vc' <= `nvif' {
					local ind `"`ind' ``vc''"'
					local vc = `vc'+1
				}
				local dep `"``i''"'
			
				regress `dep' `ind' `if' `in' `wtexp'
				replace `vvv' = 1/(1-e(r2)) in `i'
				replace `nms' = `"`dep'"' in `i'
				scalar `mvif' = `mvif'+`vvv'[`i']
				local nv = `nv'+1
				local i = `i'+1
				if _rc {
					estimate unhold `ehold'
					error _rc
				}
			}
			* preserve
			gsort -`vvv' `nms'
			local i 1
			while `i' <= `nv' {
				noi di in smcl in gr /*
				*/ %12s abbrev(`nms'[`i'],12) /*
				*/ `" {c |} "' in ye %9.2f `vvv'[`i'] /*
				*/ `"    "' in ye %8.6f 1/`vvv'[`i']
				global S_`i' = `vvv'[`i']
				ret local name_`i' = `nms'[`i']
				ret scalar vif_`i' = `vvv'[`i'] 
				local i = `i'+1
			}
			noi di in smcl in gr "{hline 13}{c +}{hline 22}"
			noi di in smcl in gr `"    Mean VIF {c |} "' /*
			*/ in ye %9.2f `mvif'/`nv'
			* restore
		}
		estimate unhold `ehold'
	}
	error _rc
end
