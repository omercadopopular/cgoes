*! MLB 1.0.1 05 Sep 2006
*! MLB 1.0.0 08 Apr 2006
program dirireg_lf
	version 8.2
	
	forvalues i = 2/$S_k {
		local mu_k "`mu_k' mu`i'"
	}
	
	args lnf `mu_k' ln_phi
	
	local ldenom 0
	forvalues i = 2/$S_k {
		local ldenom "`ldenom' + exp(`mu`i'')"
	}
	
	local denom " lngamma(1/(1 + `ldenom')*exp(`ln_phi'))"
	local prop "(1/(1 + `ldenom') * exp(`ln_phi') - 1)*ln($S_MLy1)"
	
	forvalues i = 2/$S_k {
		local y = "S_MLy`i'"
		local denom "`denom' - lngamma(exp(`mu`i'')/(1 + `ldenom')*exp(`ln_phi'))"
		local prop "`prop' + (exp(`mu`i'')/(1 + `ldenom')*exp(`ln_phi') - 1)*ln($`y')"
	}

	qui replace `lnf' = ///
	lngamma(exp(`ln_phi')) - `denom' + `prop' 
	
end

/*in dirifit.ado the varlist was reordered so that the first variable 
  is the baseoutcome if the baseoutcome option was used.*/
