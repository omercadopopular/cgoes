*! name changed from -ineqdeco- to -ineqdeco5-, August 2006
*! This version for versions 5 to 8.1 
*! Use -ineqdeco- with version 8.2 onwards
*! version 1.0.1 Stephen P. Jenkins, April 1998   STB-48 sg104
*! version 1.6 April 2001 (made compatible with Stata 7)
*! Inequality indices and decomposition by population subgroups
*! Syntax: ineqdeco <var> [[w=weight] if <exp> in <range>], 
*!		[by(<groupvar>) w s]

program define ineqdeco5
	version 5.0

	local varlist "req ex max(1)"
	local if "opt"
	local in "opt"
	local options "BYgroup(string) W Summ"
	local weight "aweight fweight"
	parse "`*'"
	parse "`varlist'", parse (" ")
	local inc "`1'"

	tempvar fi totaly py gini wgini im1 i0 i1 i2 /*
         */  nk vk fik meanyk varyk lambdak loglamk lgmeank  /*
         */  thetak im1k i0k i1k i2k  ginik pyk /*
         */  im1b i0b i1b i2bt i2b  wginik /*
         */  ahalf a1 a2 ahalfk a1k a2k mhalf m1 m2 mhalfk m1k m2k /*
         */  whalf w1 w2 whalfk w1k w2k      /*
         */  ahalfb a1b a2b mhalfb m1b m2b edehlfk ede1k ede2k /*
         */  edehalf ede1 ede2 withm1 with0 withh with1 with2 /*
	 */  touse wi badinc first

	if "`weight'" == "" {ge `wi' = 1}
	else {ge `wi' `exp'}

	mark `touse' `if' `in'
	markout `touse' `varlist' `bygroup'
	lab var `touse' "All obs"
	lab def `touse' 1 " "
	lab val `touse' `touse'
	
	set more 1
	
	quietly {

	count if `inc' < 0 & `touse'
	local ct = _result(1)
	if `ct' > 0 {
		noi di " "
		noi di in blue "Warning: `inc' has `ct' values < 0." _c
		noi di in blue " Not used in calculations"
		}
	count if `inc' == 0 & `touse'
	local ct = _result(1)
	if `ct' > 0 {
		noi di " "
		noi di in blue "Warning: `inc' has `ct' values = 0." _c
		noi di in blue " Not used in calculations"
		}
	ge `badinc' = 0
	replace `badinc' =. if `inc' <= 0
	markout `touse'  `badinc'

	noi di " "
	if "`summ'" ~= "" {
		noi di "Summary statistics for distribution of " _c
		noi di "`inc'" ": all valid cases"
		noi sum `inc' [w = `wi'] if `touse', de
	}
	else {sum `inc' [w = `wi'] if `touse', de }
	local p5  = _result(7)
	local p10 = _result(8)
	local p25 = _result(9)
	local p50 = _result(10)
	local p75 = _result(11)
	local p90 = _result(12)
	local p95 = _result(13)
	
	local sumwi = _result(2)
	local meany = _result(3)
	local vary = _result(4) 
	local sdy = sqrt(`vary') 

	ge `fi' = `wi'/`sumwi' if `touse'

	gsort -`touse' `inc' 
		/* Code was: sort `touse' `inc' */
		/* change in sort behaviour with -egen-
		in v.7 interacting with `touse' vble created 
		in if/in option. (I had relied on 'old' behaviour 
		in my use of -tabdisp-). */

* 	old code: now fixed to handle fweights properly
*	ge `py' = sum(`wi')/`sumwi' if `touse'
	ge `py' = (2*sum(`wi') - `wi' + 1)/(2 * `sumwi' ) if `touse'

	egen `gini' = sum(`fi'*(2/`meany')*`py'*(`inc'-`meany')) if `touse'


	egen `im1' = sum(`fi'*((`meany'/`inc')-1)/2) if `touse'
	egen `i0' = sum(`fi'*log(`meany'/`inc')) if `touse'
	egen `i1' = sum(`fi'*(`inc'/`meany')*log(`inc'/`meany')) if `touse'
*	ge `i2' = .5*`vary'/`meany'^2 if `touse'
	egen `i2' = sum(`fi'*(((`inc'/`meany')^2)-1)/2) if `touse'

	ge `wgini' = `meany'*(1-`gini') if `touse'

	lab var `gini' "Gini"
	lab var `im1' "GE(-1)"
	lab var `i0' "GE(0)"
	lab var `i1' "GE(1)"
	lab var `i2' "GE(2)"

	noi di " "
	noi di  "Percentile ratios for distribution of " "`inc'" _c
	noi di  ": all valid obs."
	noi di in gr _dup(60) "-"
	noi di in gr "p90/p10  p90/p50  p10/p50  p75/p25  p75/p50  p25/p50"
	noi di in gr _dup(60) "-"
	noi di  %7.3f `p90'/`p10' _col(10) %7.3f `p90'/`p50' _c
	noi di _col(3) %7.3f `p10'/`p50' _col(12) %7.3f `p75'/`p25' _c
	noi di _col(3) %7.3f `p75'/`p50' _col(12) %7.3f `p25'/`p50'

	global S_9010 = `p90'/`p10'
	global S_7525 = `p75'/`p25'

	noi di "              "
	noi di "Generalized Entropy indices GE(a), where a = income difference" 
	noi di " sensitivity parameter, and Gini coefficient"
	noi tabdisp `touse' in 1, c(`im1' `i0' `i1' `i2' `gini') f(%9.5f)

	global S_gini = `gini'[1]
	global S_im1 = `im1'[1]
	global S_i0 = `i0'[1]
	global S_i1 = `i1'[1]
	global S_i2 = `i2'[1]

	drop `gini' `im1' `i0' `i1' `i2' 

	egen `mhalf' = sum(`fi' * sqrt(`inc') )  if `touse'
	ge `edehalf' = (`mhalf')^2 if `touse'
	ge `ahalf' = 1 - `edehalf'/`meany'  if `touse'
	egen `m1' = sum(`fi' * log(`inc') ) if `touse'
	ge `ede1' = exp(`m1')  if `touse'
	ge `a1' = 1 - `ede1'/`meany'  if `touse'
	egen `m2' = sum(`fi'/ `inc' )  if `touse'
	ge `ede2' = 1/`m2' if `touse' 
	ge `a2' = 1 - `ede2'/`meany'  if `touse'

	lab var `ahalf' "A(0.5)"
	lab var `a1' "A(1)"
	lab var `a2' "A(2)"
	
	noisily di "   "
	noi di "Atkinson indices, A(e), where e > 0 is " _c
	noi di "the inequality aversion parameter"
	noi tabdisp `touse' if `touse', c(`ahalf' `a1' `a2') f(%9.5f)

	global S_ahalf = `ahalf'[1]
	global S_a1 = `a1'[1]
	global S_a2 = `a2'[1]

	drop `ahalf' `a1' `a2'  `mhalf' `m1' `m2' 

	/* results for Yede, welfare indices if requested: */

	if "`w'" == "w" {

	lab var `edehalf' "Yede(0.5)"
	lab var `ede1' "Yede(1)"
	lab var `ede2' "Yede(2)"

	noisily di "   "
	noi di "Equally-distributed-equivalent incomes, Yede(e)"
	noi tabdisp `touse' in 1, c(`edehalf' `ede1' `ede2') f(%9.5f)
	noisily di "   "

	/* Don't drop `edehalf' `ede1' `ede2' yet: needed in decomp */

	egen `whalf' = sum(`fi' * sqrt(`inc') * 2) if `touse'
	egen `w1' = sum(`fi' * log(`inc') ) if `touse'
	egen `w2' = sum(-`fi'/`inc') if `touse'
	lab var `whalf' "W(0.5)"
	lab var `w1' "W(1)"
	lab var `w2' "W(2)"
	lab var `wgini' "mean*(1-Gini)"

	noi di  "Social welfare indices, W(e), and Sen's welfare index"
	noi tabdisp `touse' in 1, c(`whalf' `w1' `w2' `wgini') f(%9.5f)

*	global S_whalf = `whalf'[1]
*	global S_w1 = `w1'[1]
*	global S_w2 = `w2'[1]

	drop `whalf' `w1' `w2'

	}

	*************************
	* SUBGROUP DECOMPOSITIONS
	*************************

	if "`bygroup'" ~= "" {	


	gsort `bygroup' -`touse' `inc'

	by `bygroup': ge `first' = (_n==1)


	/* CODE WAS:	sort `bygroup' `inc' */


	egen `nk' = sum(`wi') if `touse', by(`bygroup')
	ge `vk' = `nk'/`sumwi' if `touse'
	ge `fik' = `wi'/`nk' if `touse'
	egen `meanyk' = sum(`fik'*`inc') if `touse', by(`bygroup')
	egen `varyk' = sum(`fik'*(`inc'-`meanyk')^2) /*
		*/	if `touse', by(`bygroup')
	ge `loglamk' = log(`meanyk') if `touse'
	ge `lambdak' = `meanyk' / `meany' if `touse'
	ge `lgmeank' = log(`meanyk') if `touse'
	ge `thetak' = `vk' * `lambdak' if `touse'
	egen `im1k' = sum(`fik' * ((`meanyk'/`inc')-1)/2) if `touse', /*
		*/ by(`bygroup')
	egen `i0k' = sum(`fik'*log(`meanyk'/`inc')) if `touse', /*
		*/ by(`bygroup')
	egen `i1k' = sum(`fik'*(`inc'/`meanyk')*log(`inc'/`meanyk')) /*
		*/ if `touse', by(`bygroup')
*	ge `i2k' = .5*`varyk'/`meanyk'^2 if `touse'
	egen `i2k' = sum(`fik'*(((`inc'/`meanyk')^2)-1)/2) if `touse', /*
		*/ by(`bygroup')


	noi di "              "
	noi di "Subgroup summary statistics, for each subgroup k = 1,...,K:"

	if "`summ'" ~= "" {
		noi by `bygroup': sum `inc' [w = `wi'] if `touse', de
	}

	sort `bygroup' `inc'
*	by `bygroup' : ge `pyk' = sum(`wi')/`nk'  if `touse'
	by `bygroup': ge `pyk' = (2*sum(`wi') - `wi' + 1)/(2 * `nk' ) /*
		*/ if `touse'

	gsort `bygroup' -`touse' `inc'

	egen `ginik' = sum(`fik'*(2/`meanyk')*`pyk'*(`inc'-`meanyk')) /*
		*/ if `touse', by(`bygroup')

	ge `wginik' = `meanyk'*(1-`ginik') if `touse'

	lab var `vk' "Pop. share"
	lab var `meanyk' "Mean"
	lab var `lambdak' "Rel.mean"
	lab var `thetak' "Income share"
	lab var `lgmeank' "log(mean)"
	lab var `ginik' "Gini"
	lab var `im1k' "GE(-1)"
	lab var `i0k' "GE(0)"
	lab var `i1k' "GE(1)"
	lab var `i2k' "GE(2)"
	lab var `wginik' "mean*(1-Gini)"



	noi di "              "
	noi tabdisp `bygroup' if `first' /*
	  */ , c(`vk' `meanyk' `lambdak' `thetak' `lgmeank') f(%9.5f)

	noi di "              "
	noi di "Subgroup indices: GE_k(a) and Gini_k "
	noi tabdisp `bygroup' if `first' /*
	  */ , c(`im1k' `i0k' `i1k' `i2k' `ginik')  f(%9.5f)

	
	drop `lgmeank' `ginik' `thetak' `nk' `pyk' 

	egen `withm1' = sum(`fi'*`im1k'/`lambdak') if `touse'
	egen `with0' = sum(`fi'*`i0k') if `touse'
	egen `with1' = sum(`fi'*`i1k'*`lambdak') if `touse'
	egen `with2' = sum(`fi'*`i2k'*`lambdak'^2) if `touse'
	lab var `withm1' "GE(-1)"
	lab var `with0' "GE(0)"
	lab var `with1' "GE(1)"
	lab var `with2' "GE(2)"

	noi di "              "
	noi di "Within-group inequality, GE_W(a)"
	noi tabdisp `touse' in 1 if `touse', /*
	  */  c(`withm1' `with0' `with1' `with2')  f(%9.5f)

	drop `im1k' `i0k' `i1k' `i2k' `withm1' `with0' `with1' `with2' 

	** GE index between-group inequalities **

	egen `im1b' = sum(`fi'*((`meany'/`meanyk') - 1) / 2 ) if `touse'
	egen `i0b' = sum(`fi'*log(`meany'/`meanyk')) if `touse'
	egen `i1b' = sum(`fi'*(`meanyk'/`meany')*log(`meanyk'/`meany')) /*
		*/ if `touse'
	egen `i2bt' = sum(`fi'*(`meanyk'-`meany')^2) if `touse'
	ge `i2b' = .5 * `i2bt' / `meany'^2 if `touse'
	lab var `im1b' "GE(-1)"
	lab var `i0b' "GE(0)"
	lab var `i1b' "GE(1)"
	lab var `i2b' "GE(2)"
	noi di "              "
	noi di "Between-group inequality, GE_B(a):"
	noi tabdisp `touse' in 1 if `touse', /*
	  */ c(`im1b' `i0b' `i1b' `i2b')  f(%9.5f)

	drop `im1b' `i0b' `i1b' `i2b' `i2bt'

	** Subgroup Atkinson and welfare indices **

	egen `mhalfk' = sum(`fik' * sqrt(`inc') ) if `touse', by(`bygroup')
	ge `edehlfk' = (`mhalfk')^2 if `touse'
	ge `ahalfk' = 1 - `edehlfk'/`meanyk' if `touse'
	egen `m1k' = sum(`fik' * log(`inc') ) if `touse', by(`bygroup')
	ge `ede1k' = exp(`m1k') if `touse'
	ge `a1k' = 1 - `ede1k'/`meanyk' if `touse'
	egen `m2k' = sum(`fik' / `inc') if `touse', by(`bygroup')
	ge `ede2k' = 1/`m2k' if `touse'
	ge `a2k' = 1 - `ede2k'/`meanyk' if `touse'

	lab var `ahalfk' "A(0.5)"
	lab var `a1k' "A(1)"
	lab var `a2k' "A(2)"

	noi di "              "
	noi di "Subgroup Atkinson indices, A_k(e)"
	noi tabdisp `bygroup' if `first' /*
	  */ , c(`ahalfk' `a1k' `a2k')  f(%9.5f)


	drop `mhalfk' `m1k' `m2k'

	egen `withh' = sum(`fi'*`lambdak'*`ahalfk') if `touse'
	egen `with1' = sum(`fi'*`lambdak'*`a1k') if `touse'
	egen `with2' = sum(`fi'*`lambdak'*`a2k')  if `touse'
	lab var `withh' "A(0.5)"
	lab var `with1' "A(1)"
	lab var `with2' "A(2)"

	noi di "              "
	noi di  "Within-group inequality, A_W(e)"
	noi tabdisp `touse' if `touse', /*
		*/  c(`withh' `with1' `with2')  f(%9.5f)


	drop `ahalfk' `a1k' `a2k' `withh' `with1' `with2' `lambdak'

	* Atkinson between-group inequality (Blackorby et al., eqn (17))

	egen `mhalfb' = sum(`fi'*`edehlfk' )  if `touse'
	ge `ahalfb' = 1 - `edehalf'/ `mhalfb' if `touse'
	egen `m1b' = sum(`fi'*`ede1k' )  if `touse'
	ge `a1b' = 1 - `ede1'/`m1b' if `touse'
	egen `m2b' = sum(`fi'*`ede2k' )  if `touse'
	ge `a2b' = 1 - `ede2'/`m2b' if `touse'
	lab var `ahalfb' "A(0.5)"
	lab var `a1b' "A(1)"
	lab var `a2b' "A(2)"

	noi di "              "
	noi di "Between-group inequality, A_B(e)"
	noi tabdisp `touse' in 1 if `touse', /*
	  */ c(`ahalfb' `a1b' `a2b')  f(%9.5f)

	drop `ahalfb' `a1b' `a2b' `mhalfb' `m1b' `m2b' /*
           */ `edehalf' `ede1' `ede2'

	/* results for Yede, welfare indices if requested: */

	if "`w'" == "w" {

	lab var `edehlfk' "Yede(0.5)"
	lab var `ede1k' "Yede(1)"
	lab var `ede2k' "Yede(2)"

	noi di "              "
	noi di "Subgroup equally-distributed-equivalent income, Yede_k(e)"
	noi tabdisp `bygroup' if `first' /*
	  */ , c(`edehlfk' `ede1k' `ede2k')  f(%9.5f)


	drop `edehlfk' `ede1k' `ede2k' 

	egen `whalfk' = sum(`fik' * sqrt(`inc') * 2) if `touse', /*
		*/ by(`bygroup')
	egen `w1k' = sum(`fik' * log(`inc') ) if `touse', by(`bygroup')
	egen `w2k' = sum(-`fik'/`inc') if `touse', by(`bygroup')
	lab var `whalfk' "W(0.5)"
	lab var `w1k' "W(1)"
	lab var `w2k' "W(2)"

	noi di "              "
	noi di "Subgroup welfare indices: W_k(e) and Sen's index"
	noi tabdisp `bygroup' if `first' /*
	  */ , c(`whalfk' `w1k' `w2k' `wginik')  f(%9.5f)



	drop `whalfk' `w1k' `w2k'

	}

	drop `wginik' `fi'
	}

}


end
