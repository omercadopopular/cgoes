*! version 2.9.0 28mar2017
program ms_parse_vce, sclass
	sreturn clear
	syntax, [vce(string) weighttype(string)]
	loc 0 `vce'
	* need -anything- instead of -namelist- because clusters can be x#y
	syntax 	[anything(id="VCE type")] , [*]

	gettoken vcetype clustervars : anything

	* Expand variable abbreviations
	if ("`clustervars'" != "") {
		ms_fvunab clustervars : `clustervars', stringok
		loc clustervars : subinstr loc clustervars "i." "", all
		_assert !strpos("`clustervars'", "."), msg("unexpected dot in clustervars: `clustervars'")

		unopvarlist `clustervars'
		loc base_clustervars `r(varlist)'
	}

	* vcetype abbreviations:
	if (substr("`vcetype'",1,3)=="ols") loc vcetype unadjusted
	if (substr("`vcetype'",1,2)=="un") loc vcetype unadjusted
	if (substr("`vcetype'",1,1)=="r") loc vcetype robust
	if (substr("`vcetype'",1,2)=="cl") loc vcetype cluster
	if ("`vcetype'"=="conventional") loc vcetype unadjusted
	// Conventional is the name given in e.g. xtreg

	* Implicit defaults
	if ("`vcetype'"=="" & "`weighttype'"=="pweight") loc vcetype robust
	if ("`vcetype'"=="") loc vcetype unadjusted

	* Sanity checks on vcetype
	_assert inlist("`vcetype'", "unadjusted", "robust", "cluster"), ///
		msg("vcetype '`vcetype'' not allowed")

	_assert !("`vcetype'"=="unadjusted" & "`weighttype'"=="pweight"), ///
		msg("pweights do not work with vce(unadjusted), use a different vce()")
	* Recall that [pw] = [aw] + _robust
	* http://www.stata.com/statalist/archive/2007-04/msg00282.html
	
	* Also see: http://www.stata.com/statalist/archive/2004-11/msg00275.html
	* "aweights are for cell means data, i.e. data which have been collapsed
	* through averaging, and pweights are for sampling weights"

	* Cluster vars
	loc num_clusters : word count `clustervars'
	_assert inlist( (`num_clusters'>0) + ("`vcetype'"=="cluster") , 0 , 2), msg("Can't specify cluster without clustervars (and viceversa)") // XOR

	_assert "`options'" == "", msg("VCE options not supported: `options'")

	* Convert i.turn#i.trunk into turnk#trunk (so we can generate the new variable with the combination of both)


	sreturn loc vcetype `vcetype'
	sreturn loc num_clusters `num_clusters'
	sreturn loc clustervars `clustervars'
	sreturn loc base_clustervars `base_clustervars'
	sreturn loc vceextra `options'
end
