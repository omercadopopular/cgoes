*! survgini v1.0.0 Long Hong 11jul2015
capture program drop survgini
program survgini, rclass
version 12
syntax varlist(numeric min=3 max=3) [if] [in] ///
	[, noLASTevent noLINearrank noASymptotic noPERMutation M(integer 500) ]

tokenize `varlist'
	local time `1'
	local status `2'
	local x `3'

marksample touse
	qui count if `touse'
	if `r(N)' == 0 {
		display "No observations"
		}

tempname N2 N1 N Tmaxnum Tmax2 Tmax1 LRstat Wstat teststatGiniAs /// 
	teststatGiniOrig  Ginis2Orig Ginis1Orig VarasintGini2 VarasintGini1 ///
	M teststatGiniPerm Tmax1Perm Tmax2Perm TmaxnumPerm Ginis2Perm Ginis1Perm ///
	pGiniAs pGiniPerm pLR pW Table statGiniPerm
tempvar A1 A2 A1Perm A2Perm count countsum statGiniPerm_sum

tempfile origdata
qui save `origdata', replace
	
	qui count if `time' == 0 & `touse'
	if `r(N)' > 0 {
		qui replace `time' = 1/1000000 if `time' == 0 & `touse'
	}
	
	qui count if `time' != . & `touse'
	qui scalar `N' = r(N)
	qui count if `x' == 1 & `touse'
	scalar `N1' = r(N)
	qui count if `x' == 2 & `touse'
	scalar `N2' = r(N)
	if "`lastevent'" != "nolastevent" {
		qui gen `A1' = `time'*1*(`status' ==1) if `x' == 1 & `touse'
		qui gen `A2' = `time'*1*(`status' ==1) if `x' == 2 & `touse'
	}
	else {
		qui gen `A1' = `time' if `x' == 1 & `touse'
		qui gen `A2' = `time' if `x' == 2 & `touse'
	}
	qui sum `A1' if `touse'
	scalar `Tmax1' = r(max) + 0.001  
	qui sum `A2' if `touse'
	scalar `Tmax2' = r(max) + 0.001
	scalar `Tmaxnum' = `Tmax1'*1*(`N1'>=`N2')+`Tmax2'*1*(`N2'>`N1')
	preserve 
	qui keep if `x' == 1 & `touse'
	qui gcensor2 `time' `status' `Tmaxnum'
	qui return list
	scalar `Ginis1Orig' = r(GTmax)
	restore
	preserve
	qui keep if `x' == 2 & `touse'
	qui gcensor2 `time' `status' `Tmaxnum'
	qui return list
	scalar `Ginis2Orig' = r(GTmax)
	restore
	scalar `teststatGiniOrig' = (`Ginis1Orig' - `Ginis2Orig')^2
	
	if "`linearrank'" != "nolinearrank" {
	qui stset `time', fail(`status')
	*** pGT  
	qui sts test `x' if `touse', fh(0 0)
	scalar `LRstat' = r(chi2)   
	scalar `pLR' = 1-chi2(1, `LRstat')
	qui sts test `x' if `touse', fh(1,0)
	scalar `Wstat' = r(chi2)
	scalar `pW' = 1-chi2(1, `Wstat')
	return scalar pLR = `pLR'
	return scalar statLR = `LRstat'
	return scalar pW = `pW'
	return scalar statW = `Wstat'
	drop _st _d _t _t0
	}

	if "`permutation'" != "nopermutation" {
	scalar `M' = `m'
	set matsize `m'
	matrix `count' = J(`m', 1, 0)
	local i = 1
	while `i' <= `M' {
		tempfile sample
		qui keep if `touse'
		qui save `sample', replace
		use `sample', clear
		qui bsample `N1'
			if "`lastevent'" != "nolastevent" {
				qui gen `A1Perm' = `time'*1*(`status'==1) 	
				}
			else {
				qui gen `A1Perm' = `time' 
				}
		qui sum `A1Perm'
		scalar `Tmax1Perm' = r(max) + 0.001 	
		tempfile sample1
		qui save `sample1', replace
		use `sample', clear
		qui bsample `N2'
			if "`lastevent'" != "nolastevent" {
				qui gen `A2Perm' = `time'*1*(`status'==1) 	
				}
			else {
				qui gen `A2Perm' = `time' 
				}
		qui sum `A2Perm'
		scalar `Tmax2Perm' = r(max) + 0.001	
		tempfile sample2
		qui save `sample2', replace
		scalar `TmaxnumPerm' = `Tmax1Perm'*1*(`N1'>=`N2')+`Tmax2Perm'*1*(`N2'>`N1')
		use `sample1', clear
		qui gcensor2 `time' `status' `TmaxnumPerm'
		qui return list
		scalar `Ginis1Perm' = r(GTmax)
		use `sample2', clear
		qui gcensor2 `time' `status' `TmaxnumPerm'
		qui return list
		scalar `Ginis2Perm' = r(GTmax)		
		use `sample', clear
		scalar `teststatGiniPerm' = (`Ginis1Perm'-`Ginis2Perm')^2
		tempname count`i'
		scalar `count`i'' = 1*(`teststatGiniPerm' > `teststatGiniOrig')
		matrix `count'[`i', 1] = `count`i''
		local i = `i' + 1
		}
		mata : st_matrix("`countsum'", colsum(st_matrix("`count'")))
		scalar `pGiniPerm' = `countsum'[1,1]/`M' 
		scalar `countsum' = `countsum'[1,1]
		return scalar pGiniPerm = `pGiniPerm'
	}	

	if "`asymptotic'" != "noasymptotic" {
		preserve
		qui keep if `x' == 1 & `touse'
		qui varginicensor `time' `status' `Tmax1'
		qui return list
		scalar `VarasintGini1' = r(variance)
        restore
		preserve
		qui keep if `x' == 2 & `touse'
		qui varginicensor `time' `status' `Tmax2'
		qui return list
		scalar `VarasintGini2' = r(variance)
        restore
		scalar `teststatGiniAs' = (`Ginis1Orig' - `Ginis2Orig')^2/(`VarasintGini1' + `VarasintGini2')
        scalar `pGiniAs' = 1-chi2(1, (`teststatGiniAs')) 
        return scalar pGiniAs = `pGiniAs'
		return scalar statGiniAs = `teststatGiniAs'     
	}
	
	capture return scalar statGiniPerm = `teststatGiniOrig'
	capture return scalar statW = `Wstat'
	capture return scalar statLR = `LRstat'	
	capture return scalar statGiniAs = `teststatGiniAs'
	
	capture return scalar pGiniPerm = `pGiniPerm'
	capture return scalar pW = `pW'
	capture return scalar pLR = `pLR'
	capture return scalar pGiniAs = `pGiniAs'	
	
	capture scalar `pGiniAs' = round(`pGiniAs', .00001)
	capture scalar `pGiniPerm' = round(`pGiniPerm', .00001)
	capture scalar `pLR' = round(`pLR', .00001)	
	capture scalar `pW' = round(`pW', .00001)
	
	capture scalar `LRstat' = round(`LRstat', .0001)
	capture scalar `Wstat' = round(`Wstat', .0001)
	capture scalar `teststatGiniAs' = round(`teststatGiniAs', .0001)
	capture scalar `teststatGiniOrig' = round(`teststatGiniOrig', .0001)

	
	if "`asymptotic'" != "noasymptotic" & "`permutation'" != "nopermutation" ///
	& "`linearrank'" != "nolinearrank" {
	matrix Table = (`pGiniAs', `pLR', `pW', `pGiniPerm' \ `teststatGiniAs', `LRstat', `Wstat', `teststatGiniOrig' )
	matrix rownames Table = pval stat
	matrix colnames Table = pGiniAs pLR pW pGiniPerm
	matlist Table, title("Comparison among GiniAs Log-rank Wilcoxon and GiniPerm tests")
	}
	if "`asymptotic'" != "noasymptotic" & "`permutation'" == "nopermutation" ///
	& "`linearrank'" != "nolinearrank" {
	matrix Table = (`pGiniAs', `pLR', `pW' \ `teststatGiniAs', `LRstat', `Wstat')
	matrix rownames Table = pval stat 
	matrix colnames Table = pGiniAs pLR pW
	matlist  Table, title("Comparison among GiniAs Log-rank and Wilcoxon tests")
	}
	if "`asymptotic'" == "noasymptotic" & "`permutation'" != "nopermutation" ///
	& "`linearrank'" != "nolinearrank" {
	matrix Table = (`pLR', `pW', `pGiniPerm' \ `LRstat', `Wstat', `teststatGiniOrig')
	matrix rownames Table = pval stat
	matrix colnames Table = pLR pW pGiniPerm
	matlist  Table, title("Comparison among Log-rank Wilcoxon and pGiniPerm tests")
	}
	if "`asymptotic'" != "noasymptotic" & "`permutation'" != "nopermutation" ///
	& "`linearrank'" == "nolinearrank" {
	matrix Table = (`pGiniAs', `pGiniPerm' \ `teststatGiniAs', `teststatGiniOrig')
	matrix rownames Table = pval stat
	matrix colnames Table = pGiniAs pGiniPerm 
	matlist  Table, title("Comparison between GiniAs and pGiniPerm tests")
	}
	if "`asymptotic'" == "noasymptotic" & "`permutation'" == "nopermutation" ///
	& "`linearrank'" != "nolinearrank" {
	matrix Table = (`pLR', `pW' \ `LRstat', `Wstat')
	matrix rownames Table = pval stat
	matrix colnames Table = pLR pW
	matlist  Table, title("Comparison between Log-rank and Wilcoxon tests")
	}
	if "`asymptotic'" != "noasymptotic" & "`permutation'" == "nopermutation" ///
	& "`linearrank'" == "nolinearrank" {
	matrix Table = (`pGiniAs' \ `teststatGiniAs')
	matrix rownames Table = pval stat
	matrix colnames Table = pGiniAs
	matlist  Table, title("Gini Asympototic Test")
	}	
	if "`asymptotic'" == "noasymptotic" & "`permutation'" != "nopermutation" ///
	& "`linearrank'" == "nolinearrank" {
	matrix Table = (`pGiniPerm' \ `teststatGiniOrig')
	matrix rownames Table = pval stat
	matrix colnames Table = pGiniPerm 
	matlist  Table, title("Gini Permutation Test")
	}
	if "`asymptotic'" == "noasymptotic" & "`permutation'" == "nopermutation" ///
	& "`linearrank'" == "nolinearrank" {
	display "No test is chosen"
	}

use `origdata', clear
end


*** varginicensor
capture program drop varginicensor
program varginicensor, rclass
version 12
args time status tmax

tempvar S T indexvar Vt Wt mu2 mu1 risk atrisk event dsigma varistant var
tempname Wtmax Vtmax Tmax N variance
preserve

	scalar `Tmax' = `tmax'
	qui stset `time', fail(`status')
	qui sts gen `S' = s 
	qui gen `T' = `time'
	drop _st _d _t _t0
	sort `T' `S', stable
	qui count if `time' != . 
	scalar `N' = r(N)
	qui gen `atrisk' = .   
	local i = 1
	while `i' <= `N' {
		qui gen `risk' = sum(1*(`T'>=`T'[`i']))
		qui sum `risk'
		tempname risk`i'
		scalar `risk`i'' = r(max)
		qui replace `atrisk' = `risk`i'' in `i'
		drop `risk'
		scalar drop `risk`i''
		local i = `i' + 1
		}
	qui bysort `time': egen `event' = sum(`status') 
	qui replace `event' = . if `atrisk' == .
	qui duplicates drop `T', force
	qui gen `indexvar' = sum(1*(`T'<=`Tmax')) 
	qui sum `indexvar'
	local index = r(max)
	qui gen `Vt' = `T' in 1/1
	qui replace `Vt' = `Vt'[_n-1] + ((`S'[_n-1]^2)*(`T'[_n]-`T'[_n-1])) in 2/`index'
	qui gen `Wt' = `T' in 1/1
	qui replace `Wt' = `Wt'[_n-1] + `S'[_n-1]*(`T'[_n]-`T'[_n-1]) in 2/`index'	
	scalar `Vtmax' = `Vt'[`index'] + ((`S'[`index']^2)*(`Tmax'-`T'[`index']))
	scalar `Wtmax' = `Wt'[`index'] + (`S'[`index']*(`Tmax'-`T'[`index']))
	qui gen `mu2' = `Vtmax' - `Vt' in 1/`index'
	qui gen `mu1' = `Wtmax' - `Wt' if 1/`index'
	qui replace `mu1' = 0.001 if `mu1' == 0
	qui replace `mu2' = 0.001 if `mu2' == 0
	qui gen `dsigma' = (`N'*`event')/(`atrisk'^2) if `atrisk' > 0
	qui gen `varistant' = (4*exp(2*log(`mu2')-2*log(`Wtmax'))+exp(2*log(`mu1')+  ///
			2*log(`Vtmax')-4*log(`Wtmax'))-4*exp(log(`mu1')+log(`mu2')+log(`Vtmax')  ///
			-3*log(`Wtmax')))*`dsigma'
			qui gen `var' = `varistant' in 1/1
	qui replace `var' = `var'[_n-1]+`varistant'[_n] in 2/`index'
	qui replace `var' = `var'/`N'
	local lastvar = `var' in `index'
	scalar `variance' = `lastvar'
	display as txt "Variance = " `variance'
	return scalar variance = `variance'
		
restore 
end	 


*** gcensor2
capture program drop gcensor2
program gcensor2, rclass
version 12
args time status tmax

tempvar S T num den indexvar G
tempname lastden lastnum K Tmax GTmax

	scalar `Tmax' = `tmax' 
	qui stset `time', fail(`status')
	qui sts gen `S' = s
	drop _st _d _t _t0
	qui gen `T' = `time'
	sort `T' `S', stable
	qui duplicates drop `T', force
	qui gen `num' = 1*`T' if _n == 1
	qui replace `num' = `num'[_n-1]+((`S'[_n-1])^2)*(`T'[_n]-`T'[_n-1]) if _n != 1
	qui gen `den' = 1*`T' if _n == 1
	qui replace `den' = `den'[_n-1]+(`S'[_n-1])*(`T'[_n]-`T'[_n-1]) if _n != 1
	qui gen `indexvar' = sum(1*(`T'<=`Tmax')) 
	qui sum `indexvar'
	local index = r(max)
	qui gen `G '= 1-(`num'/`den')
	scalar `lastnum' = ((`S'[`index'])^2)*(`Tmax'-`T'[`index'])
	scalar `lastden' = (`S'[`index'])*(`Tmax'-`T'[`index'])
	scalar `GTmax' = 1 - (`num'[`index']+`lastnum')/(`den'[`index']+`lastden')
	display as text "GTmax =" `GTmax'
	return scalar GTmax = `GTmax'
	
end 

