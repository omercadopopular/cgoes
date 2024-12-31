! 1.0.6 13Nov2009
* 1.0.1 cfb updated to v8.2
* 1.0.2 mes fixed col and row names mismatch
* 1.0.3 added noid option to supress unnecessary identification stats
* 1.0.4 added local `ivreg2_cmd'.  ref only to e(j); e(sargan) no longer needed.
* 1.0.5 added nocollin option to supress unnecessary checks for collinearity
* 1.0.6 slight rewrite of ivreg2_cue to ivreg29_cue

program define ivreg29_cue
	version 8.2
	args todo b lnf
	local ivreg2_cmd "ivreg29"
	tempname b1 J
* Need to make col and rownames match
	mat `b1'=`b'
* Remove equation number from col names
	local vn : colfullnames `b1'
	local vn : subinstr local vn "eq1" "", all
	mat colnames `b1' = `vn'
* Standard row name
	mat rownames `b1' = y1
	qui `ivreg2_cmd' $IV_lhs $IV_inexog ($IV_endog=$IV_exexog) $IV_wt if $ML_samp==1, b0(`b1') $IV_opt noid nocollin
	scalar `J'=e(j)
	scalar `lnf' = -`J'
end

