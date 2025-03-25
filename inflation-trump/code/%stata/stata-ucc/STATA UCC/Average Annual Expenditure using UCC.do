clear
set more off
********************************************************************************
********************************************************************************
*     PROGRAM NAME:   STATA SAMPLE CODE FOR COMPUTING CALENDAR YEAR ESTIMATES, *
*					  STANDARD ERRORS, AND COEFFICIENTS OF VARIATION.          *
*                                                                              *
*     WRITTEN BY:             Taylor J. Wilson - 11 JANUARY 2018               *
*     VERSION :               SE/15  (FOR STATA VERSION 11 OR HIGHER)          *
*                                                                              *
*     The results of this program are intended to outline the procedures       *
*     for computing PUMD weighted estimates. Any errors are mine alone.        *
*     wilson.taylor@bls.gov | 202-691-6550									   *
*                                                                              *
********************************************************************************
********************************************************************************

* Set the working directory to the location of the files. 

cd "C:\Users\andre\OneDrive\UCSD\Research\cgoes\inflation-trump\data\cex\2019"

* Set your time parameters
global yr1 = 19
global yr2 = 20 
global year = 2019

* Interview, Diary, or Integrated?
global var1 = "Integrated"

* List of universal classification codes (EXAMPLE UCCs PROVIDED)
global iucclist = "210110, 800710"
global ducclist = "610310, 620420"
*"610320, 620410, 620420, 610110, 610140, 610120"


if "$var1" == "Interview" {

	use fmli${yr1}1x.dta
		append using fmli${yr1}2.dta
		append using fmli${yr1}3.dta
		append using fmli${yr1}4.dta
		append using fmli${yr2}1.dta
	
	keep newid finlwt21 wtrep01-wtrep44 qintrvyr qintrvmo
	
	gen month = real(qintrvmo)
	gen quarter = 3 
		replace quarter = 1 if (qintrvmo == "01" | qintrvmo == "02" | ///
								qintrvmo == "03") & qintrvyr == "20${yr1}" 
		replace quarter = 5 if (qintrvmo == "01" | qintrvmo == "02" | ///
								qintrvmo == "03") & qintrvyr == "20${yr2}" 
								
	gen popwt = finlwt21*(((month-1)/3)/4) if quarter == 1 
		replace popwt = finlwt21*(((4-month)/3)/4) if quarter == 5 
		replace popwt = finlwt21/4 if quarter == 3 
		
	egen aggpop = sum(popwt)
		
	save "fmli${yr1}.dta", replace
		clear
	
	use mtbi${yr1}1x.dta
		append using mtbi${yr1}2.dta
		append using mtbi${yr1}3.dta
		append using mtbi${yr1}4.dta
		append using mtbi${yr2}1.dta
	
	keep newid ucc cost ref_yr pubflag
	
	destring(ucc), replace
	
	keep if inlist(ucc, $iucclist)
	keep if ref_yr == "$year"
	collapse(sum) cost, by(ucc newid)
	
	save "mtbi${yr1}.dta", replace
		clear
********************************************************************************	

	use "fmli${yr1}.dta"
	merge 1:m newid using "mtbi${yr1}.dta"
		drop _merge
		replace cost = 0 if cost == .
		
	gen wtexp = finlwt21*cost
	foreach var of varlist wtrep01-wtrep44 {
		gen c`var' = cost*`var'
		}
	
	drop wtrep01-wtrep44

	collapse (sum) aggexp = wtexp cwtrep01-cwtrep44 (mean) aggpop, by(ucc)
	
	gen mexp = aggexp/aggpop
	
	foreach var of varlist cwtrep01-cwtrep44 {
		gen m`var' = `var'/aggpop
		}
	drop cwtrep01-cwtrep44
	
	collapse (sum) mcwtrep01-mcwtrep44 mexp
	
	foreach var of varlist mcwtrep01-mcwtrep44 {
		gen s`var' = (mexp - `var')^2
		}
	drop mcwtrep01-mcwtrep44 
	
	egen totmsdiff = rowtotal(smcwtrep01-smcwtrep44)
	drop smcwtrep01-smcwtrep44
	
	gen se = sqrt(totmsdiff)/sqrt(44)
	drop totmsdiff
	
	gen cv = (se/mexp)*100
}
********************************************************************************	

 if "$var1" == "Diary" {

 	use fmld${yr1}1.dta
		append using fmld${yr1}2.dta
		append using fmld${yr1}3.dta
		append using fmld${yr1}4.dta
		
	keep newid finlwt21 wtrep01-wtrep44
	
	gen popwt = finlwt21/4
	egen aggpop = sum(popwt)
		
	save "fmld${yr1}.dta", replace
		clear
	
	use expd${yr1}1.dta
		append using expd${yr1}2.dta
		append using expd${yr1}3.dta
		append using expd${yr1}4.dta
		
	keep newid ucc cost pub_flag
		
	destring(ucc), replace
	
	keep if inlist(ucc, $ducclist)
	collapse(sum) cost, by(ucc newid)
	
	save "expd${yr1}.dta", replace
		clear
********************************************************************************	

	use "fmld${yr1}.dta"
	merge 1:m newid using "expd${yr1}.dta"
		drop _merge
		replace cost = 0 if cost == .
		
	gen wtexp = finlwt21*cost
	foreach var of varlist wtrep01-wtrep44 {
		gen c`var' = cost*`var'
		}
	
	drop wtrep01-wtrep44
	collapse (sum) aggexp = wtexp cwtrep01-cwtrep44 (mean) aggpop, by(ucc)
	
	gen mexp = (aggexp/aggpop)
	
	foreach var of varlist cwtrep01-cwtrep44 {
		gen m`var' = `var'/aggpop
		}
	drop cwtrep01-cwtrep44
	
	collapse (sum) mcwtrep01-mcwtrep44 mexp
	
	foreach var of varlist mcwtrep01-mcwtrep44 {
		gen s`var' = (mexp - `var')^2
		}
	drop mcwtrep01-mcwtrep44 
	
	egen totmsdiff = rowtotal(smcwtrep01-smcwtrep44)
	drop smcwtrep01-smcwtrep44
	
	gen se = sqrt(totmsdiff)/sqrt(44)
	drop totmsdiff
	
	replace mexp = mexp*13
	replace se = se*13
	
	gen cv = (se/mexp)*100
}
********************************************************************************	

if "$var1" == "Integrated" {
clear
use fmld${yr1}1.dta
		append using fmld${yr1}2.dta
		append using fmld${yr1}3.dta
		append using fmld${yr1}4.dta
*		append using fmli${yr2}1.dta
	
	keep newid finlwt21 wtrep01-wtrep44 qintrvyr qintrvmo
	
	gen month = real(qintrvmo)
	gen quarter = 3 
		replace quarter = 1 if (qintrvmo == "01" | qintrvmo == "02" | ///
								qintrvmo == "03") & qintrvyr == "20${yr1}" 
		replace quarter = 5 if (qintrvmo == "01" | qintrvmo == "02" | ///
								qintrvmo == "03") & qintrvyr == "20${yr2}" 
								
	gen popwt = finlwt21*(((month-1)/3)/4) if quarter == 1 
		replace popwt = finlwt21*(((4-month)/3)/4) if quarter == 5 
		replace popwt = finlwt21/4 if quarter == 3 
		
	egen aggpop = sum(popwt)
		
	save "fmli${yr1}.dta", replace
		clear
		
	use mtbi${yr1}1x.dta
		append using mtbi${yr1}2.dta
		append using mtbi${yr1}3.dta
		append using mtbi${yr1}4.dta
		append using mtbi${yr2}1.dta
	
	keep newid ucc cost ref_yr pubflag
		keep if pubflag == "2"
		drop pubflag
	
	destring(ucc), replace
	
	keep if inlist(ucc, $iucclist)
	keep if ref_yr == "2016"
	collapse(sum) cost, by(ucc newid)
	
	save "mtbi${yr1}.dta", replace
		clear
		
	use "fmli${yr1}.dta"
	merge 1:m newid using "mtbi${yr1}.dta"
		drop _merge
		replace cost = 0 if cost == .
		gen survey = 1
	save "int_i${yr1}.dta", replace
********************************************************************************
	
	 	use fmld${yr1}1.dta
		append using fmld${yr1}2.dta
		append using fmld${yr1}3.dta
		append using fmld${yr1}4.dta
		
	keep newid finlwt21 wtrep01-wtrep44
	
	gen popwt = finlwt21/4
	egen aggpop = sum(popwt)
		
	save "fmld${yr1}.dta", replace
		clear
		
	use expd${yr1}1.dta
		append using expd${yr1}2.dta
		append using expd${yr1}3.dta
		append using expd${yr1}4.dta
		
	keep newid ucc cost pub_flag
		keep if pub_flag == "2"
		drop pub_flag
		
	destring(ucc), replace
	
	keep if inlist(ucc, $ducclist)
	collapse(sum) cost, by(ucc newid)
	
	save "expd${yr1}.dta", replace
		clear
	
	use "fmld${yr1}.dta"
	merge 1:m newid using "expd${yr1}.dta"
		drop _merge
		replace cost = 0 if cost == .
		gen survey = 2
	save "int_d${yr1}.dta", replace
	
	append using "int_i${yr1}.dta"
	drop qintrvmo qintrvyr month quarter
	egen aggpop2 = sum(popwt)
********************************************************************************
	
	gen wtexp = finlwt21*cost
	foreach var of varlist wtrep01-wtrep44 {
		gen c`var' = cost*`var' if survey == 1
		replace c`var' = cost*`var'*13 if survey == 2 
		}

	drop wtrep01-wtrep44
	collapse (sum) aggexp = wtexp cwtrep01-cwtrep44 (mean) aggpop aggpop2 ///
				   survey, by(ucc)
	
	gen mexp = (aggexp/aggpop) if survey == 1
	replace mexp = (aggexp/aggpop)*13 if survey == 2 
	
	*gen semexp = (aggexp/aggpop2) if survey == 1
	*	replace semexp = (aggexp/aggpop2)*13 if survey == 2 
	
	foreach var of varlist cwtrep01-cwtrep44 {
		gen m`var' = `var'/aggpop
		}
	drop cwtrep01-cwtrep44
	
	collapse (sum) mcwtrep01-mcwtrep44 mexp
	
	foreach var of varlist mcwtrep01-mcwtrep44 {
		gen s`var' = (mexp - `var')^2
		}
	drop mcwtrep01-mcwtrep44 
	
	egen totmsdiff = rowtotal(smcwtrep01-smcwtrep44)
	drop smcwtrep01-smcwtrep44
	
	gen se = sqrt(totmsdiff)/sqrt(44)
	drop totmsdiff
	
	gen cv = (se/mexp)*100
}
