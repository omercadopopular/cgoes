capture program drop agg_acronym
program define agg_acronym
version 9.2

*!written by N Wasi, A Flaaen and A Rodgers
*!contact N Wasi: nwasi@umich.edu
*!last modified Sep 16,2014

syntax varlist(max=1) [if] [in], Generate(str) 


confirm new var `generate'
marksample touse, strok

qui gen `generate' = "" if `touse'

tempvar str1

qui gen `str1' = `varlist' if `touse'
qui replace `str1' = subinstr(`str1',"&"," & ",.) if `touse'
qui replace `str1' = trim(itrim(`str1')) if `touse'

*if all obs is blank, exit
qui count if "`str1'" !="" & `touse'
if r(N)==0 exit

tempvar nwords 
qui gen `nwords' = wordcount(`str1') if `touse'

capture qui split `str1' if `touse' & `nwords'>1
*if no observation, exit
if _rc ==2000 {
	qui replace `generate'=`str1' if `touse'
	exit
}
else {

	local maxwords = `r(nvars)'
	//count number of two consecutive one letter words
	tempvar n_oneletter
	qui gen `n_oneletter' = 0 if `touse' & `nwords'>1

	local j = 1

	foreach v in `r(varlist)' {
		tempvar length_w`j' word`j'
		qui gen `word`j'' = `v' if `touse'  & `nwords'>1
		qui gen `length_w`j'' = length(`v') if `touse'  & `nwords'>1
		//exception: don't count & as one-letter word
		qui replace `length_w`j'' = 0 if inlist(`v',"&")==1 & `touse'  & `nwords'>1

		local j_before = `j'-1
		if `j'>=2 {
			qui replace `n_oneletter' = `n_oneletter'+1 if `length_w`j_before''==1 & `length_w`j''==1 & `touse'
		}
		local j = `j'+1
	}

	tempvar dtodo newword

	qui gen `dtodo' = 1 if `n_oneletter'>=1 & `n_oneletter'<. & `touse'
	qui count if `dtodo'==1

	if r(N)!=0 {
		qui gen `newword' = `word1' if `dtodo'==1
		foreach j of numlist 2(1)`maxwords' {
			local j_before = `j'-1 
			qui replace `newword' = `newword' + " " + `word`j'' if `dtodo'==1 & (`length_w`j_before''!=1 | `length_w`j''!=1) & `j'<= `nwords' 
			qui replace `newword' = `newword' + `word`j'' if `dtodo'==1 & `length_w`j_before''==1 & `length_w`j''==1 & `j'<= `nwords' 
		}
		qui replace `newword' = `str1' if `touse' & `newword'==""
	}
	else qui gen `newword' = `str1' if `dtodo'!=1 & `touse'

	qui replace `generate' = subinstr(`newword',"&"," & ",.)
	qui replace `generate' = trim(itrim(`generate'))
}

end

