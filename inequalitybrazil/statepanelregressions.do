///////////////////////////////////////////////////////////////////////////////
/////////////////////////////////// CODED BY //////////////////////////////////
///////////////////////////////// CARLOS GOES /////////////////////////////////
///////////////////////////// andregoes@gmail.com /////////////////////////////
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
////////////////////////////////// READ ME ////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

/*

Purpose: 
 
 */
 
///////////////////////////////////////////////////////////////////////////////
//////////////////////////////// USER INTERFACE ///////////////////////////////
/////////// CHANGE THE VALUES IN THIS SECTION FOLLOWING INSTRUCTIONS //////////
///////////////////////////////////////////////////////////////////////////////

	global workingfolder = "Q:\DATA\S1\BRA\Inequality\Econometrics\StatePanel"
	global resultsfolder = "${workingfolder}\results"
	global imagefolder = "${workingfolder}\images"
	global datafolder = "Q:\DATA\S1\BRA\Inequality\PNAD\results"
	global first = 2004
	global last = 2014 	// Last PNAD being used
	global exception = 2010 // Year when there is no PNAD
	global archives
	
	global uflist = "11	12	13	14	15	16	17	21	22	23	24	25	26	27	28	29	31	32	33	35	41	42	43	50	51	52	53"
	global regressors1 = "lr_income lr_income_cs lr_pbfcapita formalworker employmentrate schooling_q1 schooling_q4 taxgdpdemean"  
	global regressors2 = "lr_income lr_income_q4 lr_income_cs lr_pbfcapita formalworker employmentrate schooling_q1 schooling_q4 taxgdpdemean" 
	global income = "lr_income lr_income_cs" 	
	global incomebf = "lr_income lr_income_cs lr_pbfcapita taxgdpdemean" 	

///////////////////////////////////////////////////////////////////////////////
////////////////////////// 1. WORKSPACE ORGANIZATION //////////////////////////
///////////////////////////////////////////////////////////////////////////////
	
	
capture log close 										// closes any open logs
clear 													// clears the memory
clear matrix 											// clears matrix memory
clear mata 												// clears mata memory
cd $workingfolder 				// sets working directory
set more off  											// most important command in STATA :)/
set maxvar 32000
set matsize 11000
log using .log, replace  					// chooses logfile

///////////////////////////////////////////////////////////////////////////////
////////////////////////// 2. IMPORT DATASETS //////////////////////////
///////////////////////////////////////////////////////////////////////////////

// Overall Variables

forvalues tyear = $first / $last {
	if `tyear' == $exception  {
		di "No PNAD in `tyear'"
	}
	else {
		import excel ${datafolder}\variables.xlsx, firstrow sheet("`tyear'") clear
		rename B state
		generate year = `tyear'
		tempfile tfile_`tyear'
		save `tfile_`tyear''
		}
}

forvalues tyear = $first / $last {
	if `tyear' == $exception  {
		di "No PNAD in `tyear'"
	}
	else if `tyear' == $last {
		di "Already imported"
	}
	else {
		merge m:m state year using `tfile_`tyear''
		drop _merge
	}
}

tempfile tfile_var
save `tfile_var', replace

// Gini 

import excel ${datafolder}\giniresults.xlsx, firstrow sheet("index") clear
merge m:m state year using `tfile_var'
drop _merge
save `tfile_var', replace

// Education Gini 

import excel ${datafolder}\educationgini.xlsx, firstrow sheet("index") clear
merge m:m state year using `tfile_var'
drop _merge
save `tfile_var', replace

// Spatial-Price Differerences

import excel ${datafolder}\ppp.xlsx, firstrow sheet("index") clear
merge m:m state year using `tfile_var'
drop _merge
save `tfile_var', replace

// PBF

import excel ${datafolder}\pbfdata.xlsx, firstrow sheet("index") clear
merge m:m state year using `tfile_var'
drop _merge
save `tfile_var', replace

// Taxes

import excel ${datafolder}\stategdp.xlsx, firstrow sheet("index") clear
merge m:m state year using `tfile_var'
drop _merge
save `tfile_var', replace

// State-GDP

import excel ${datafolder}\fedtaxrev.xlsx, firstrow sheet("index") clear
merge m:m state year using `tfile_var'
drop _merge
save `tfile_var', replace


// CPI

import excel ${datafolder}\cpi.xlsx, firstrow sheet("index") clear
merge 1:m year using `tfile_var'
drop _merge
save `tfile_var', replace

// Regions

gen region = ""
replace region = "N" if uf >= 10 & uf  < 20 
replace region = "NE" if uf  >= 20 & uf  < 30
replace region = "SE" if uf  >= 30 & uf  < 40
replace region = "S" if uf  >= 40 & uf  < 50
replace region = "CO" if uf  >= 50 & uf < 60

drop if year == 2015

xtset uf year

///////////////////////////////////////////////////////////////////////////////
////////////////////////// 3. ÀDJUST DATA //////////////////////////
///////////////////////////////////////////////////////////////////////////////

// Create Dyanmic PPP Index

gen dynamicppp = pppindex * cpi

// Interpolate missing 2010 variables

local list = "income wage civilservant migrant white formalworker schooling highskilled universityprivate universitypublic retiree pensioneer income_cs schooling_cs highskilled_cs population income_q1 income_q2 income_q3 income_q4 schooling_q1 schooling_q2  schooling_q3 schooling_q4 employmentrate retiredincome pensionincome"

foreach x of local list {
	bysort uf: ipolate `x' year, gen(`x'_temp) 
	drop `x'
	rename `x'_temp `x'
}

// Calculate PBF per capita

gen pbfcapita = pbfexpenditure / population

// Generate Federal Tax Revenues over GDP

gen taxgdp = (taxrev / stategdp) * 100
bysort uf: egen taxgdpbar = mean(taxgdp)
gen taxgdpdemean = taxgdp - taxgdpbar

// Deflate and ajust for spatial price differences

local list = "income wage income_cs pbfcapita income_q1 income_q2 income_q3 income_q4 retiredincome pensionincome"

foreach x of local list {
	generate r_`x' = `x' / dynamicppp
	generate lr_`x' = ln(r_`x')
}

// Adjust scale

local list = "civilservant migrant white formalworker highskilled universityprivate universitypublic retiree pensioneer highskilled_cs employmentrate"

foreach x of local list {
	replace `x' = `x' * 100
}

// Adjust Gini

local list = "gini edgini"

foreach gini of local list {
	generate l`gini' = ln(`gini')
	generate dl`gini' = (l`gini' - l.l`gini') * 100
	replace l`gini' = . if dl`gini' > 15 & dl`gini' != . | dl`gini' < -15 & dl`gini' != .
	bysort uf: ipolate l`gini'  year, gen(l`gini'_temp) 
	replace l`gini' = l`gini'_temp
	drop l`gini'_temp
	drop dl`gini'
	replace `gini' = exp(l`gini')
}


///////////////////////////////////////////////////////////////////////////////
////////////////////////// 4. RUN REGRESSIONS //////////////////////////
///////////////////////////////////////////////////////////////////////////////


xtreg gini $income, vce(cluster uf)
	outreg2 $income ///
		using $resultsfolder\panelregressions.xls, cttop(Random Effects) ///
		lab dec(3) adds(R2 Overall, e(r2_o), R2 Within, e(r2_w), R2 Between, e(r2_b)) replace

xtreg gini $incomebf, vce(cluster uf)
	outreg2 $incomebf ///
		using $resultsfolder\panelregressions.xls, cttop(Random Effects) ///
		lab dec(3) adds(R2 Overall, e(r2_o), R2 Within, e(r2_w), R2 Between, e(r2_b)) 

xtreg gini $regressors1, vce(cluster uf)
	outreg2 $regressors2 ///
		using $resultsfolder\panelregressions.xls, cttop(Random Effects) ///
		lab dec(3) adds(R2 Overall, e(r2_o), R2 Within, e(r2_w), R2 Between, e(r2_b)) 
		
xtreg gini $regressors2, vce(cluster uf)
	outreg2 $regressors2 ///
		using $resultsfolder\panelregressions.xls, cttop(Random Effects) ///
		lab dec(3) adds(R2 Overall, e(r2_o), R2 Within, e(r2_w), R2 Between, e(r2_b)) 
			
xtreg gini $income i.uf, vce(cluster uf)
	outreg2 $income ///
		using $resultsfolder\panelregressions.xls, cttop(Fixed Effects) ///
		lab dec(3) adds(R2 Overall, e(r2_o), R2 Within, e(r2_w), R2 Between, e(r2_b)) 

xtreg gini $incomebf  i.uf, vce(cluster uf)
	outreg2 $incomebf ///
		using $resultsfolder\panelregressions.xls, cttop(Fixed Effects) ///
		lab dec(3) adds(R2 Overall, e(r2_o), R2 Within, e(r2_w), R2 Between, e(r2_b)) 		

xtreg gini $regressors1 i.uf, vce(cluster uf)
	outreg2 $regressors1 ///
		using $resultsfolder\panelregressions.xls, cttop(Fixed Effects) ///
		lab dec(3) adds(R2 Overall, e(r2_o), R2 Within, e(r2_w), R2 Between, e(r2_b)) 

xtreg gini $regressors2 i.uf, vce(cluster uf)
	outreg2 $regressors2 ///
		using $resultsfolder\panelregressions.xls, cttop(Fixed Effects) ///
		lab dec(3) adds(R2 Overall, e(r2_o), R2 Within, e(r2_w), R2 Between, e(r2_b)) 
		
		
///////////////////////////////////////////////////////////////////////////////
////////////////////////// 5. RUN BASELINE REGRESSION AND ESTIMATE CHANGES //////////////////////////
///////////////////////////////////////////////////////////////////////////////

forval z = 2 {

	preserve

		xtreg gini ${regressors`z'} i.uf

		// Store Results

		matrix A = e(b)'

		// Create predicted values

		local list = "${regressors`z'} $uflist _cons"

		local counter = 0

		foreach x of local list  {
			local counter = `counter' + 1
			
			if regexm("$uflist", "`x'") == 1 {
				gen hat_`x' = A[`counter',1]
			}
			else {
				gen hat_`x' = `x' * A[`counter',1]
			}
		}

		foreach x of global uflist {
			replace hat_`x' = . if uf != `x'
		}

		egen gini_hat = rowtotal(hat_*)

		keep if year == $first | year == $last
		gen t = .
		replace t = 1 if year == $first
		replace t = 2 if year == $last

		xtset uf t

		local list = "${regressors`z'} $uflist _cons"

		foreach x of local list  {
			gen dhat_`x' = d.hat_`x'
		}


		 gen dgini_hat = d.gini_hat
		 gen dgini = d.gini

		 keep if year == 2014
		 
		 export excel using "$resultsfolder\decompm`z'.xlsx", sheet("decomp") sheetmodify first(var)

 restore

 }
