! 1.0.4 4feb2007
* 1.0.1 cfb updated to v8.2
* 1.0.2 mes fixed col and row names mismatch
* 1.0.3 added noid option to supress unnecessary identification stats
* 1.0.4 added local `ivreg2_cmd'.  ref only to e(j); e(sargan) no longer needed.

program define ivreg28_cue
	version 8.2
	args todo b lnf
	local ivreg2_cmd "ivreg28"
	tempname b1 J
* Need to make col and rownames match
	mat `b1'=`b'
* Remove equation number from col names
	local vn : colfullnames `b1'
	local vn : subinstr local vn "eq1" "", all
	mat colnames `b1' = `vn'
* Standard row name
	mat rownames `b1' = y1
	qui `ivreg2_cmd' $IV_lhs $IV_inexog ($IV_endog=$IV_exexog) $IV_wt if $ML_samp==1, b0(`b1') $IV_opt noid
	scalar `J'=e(j)
	scalar `lnf' = -`J'
end

