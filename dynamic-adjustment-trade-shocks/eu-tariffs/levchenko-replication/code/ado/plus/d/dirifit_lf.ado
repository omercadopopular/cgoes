*! MLB 1.0.0 23 Mar 2006 
program dirifit_lf
	version 8.2

	local alpha_k "ln_alpha1"
	forvalues i = 2/$S_k {
		local alpha_k "`alpha_k' ln_alpha`i'"
	}

	args lnf `alpha_k'
	local num "exp(`ln_alpha1')"
	local denom "-lngamma(exp(`ln_alpha1'))"
	local prop "(exp(`ln_alpha1')-1)*ln($S_MLy1)"
	forvalues i = 2/$S_k {
		local num  "`num' + exp(`ln_alpha`i'')"
		local denom  "`denom' -lngamma(exp(`ln_alpha`i''))"
		local y = "S_MLy`i'"
		local prop "`prop' + (exp(`ln_alpha`i'')-1)*ln($`y')"
	}
	qui replace `lnf' = ///
	lngamma(`num') +`denom' + `prop'
end 		


