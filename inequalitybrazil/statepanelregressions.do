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
	global resultsfolder = "${folder}\results"
	global imagefolder = "${folder}\images"
	global datafolder = "Q:\DATA\S1\BRA\Inequality\PNAD\results"
	global first = 2004
	global last = 2014 	// Last PNAD being used
	global exception = 2010 // Year when there is no PNAD
	global archives
	
	global uflist = "11	12	13	14	15	16	17	21	22	23	24	25	26	27	28	29	31	32	33	35	41	42	43	50	51	52	53"
	global regressors = "lr_income lr_income_cs lr_pbfcapita retiree formalworker schooling white migrant" 

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
		import excel ${datafolder}\variables.xlsx, firstrow cellrange(B1:R28) sheet("`tyear'") clear
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

// CPI

import excel ${datafolder}\cpi.xlsx, firstrow sheet("index") clear
merge 1:m year using `tfile_var'
drop _merge
save `tfile_var', replace

drop if year == 2015

xtset uf year

///////////////////////////////////////////////////////////////////////////////
////////////////////////// 3. ÀDJUST DATA //////////////////////////
///////////////////////////////////////////////////////////////////////////////

// Create Dyanmic PPP Index

gen dynamicppp = pppindex * cpi

// Interpolate missing 2010 variables

local list = "income wage civilservant migrant white formalworker schooling highskilled universityprivate universitypublic retiree pensioneer income_cs schooling_cs highskilled_cs population"

foreach x of local list {
	bysort uf: ipolate `x' year, gen(`x'_temp) 
	drop `x'
	rename `x'_temp `x'
}

// Calculate PBF per capita

gen pbfcapita = pbfexpenditure / population

// Deflate and ajust for spatial price differences

local list = "income wage income_cs pbfcapita"

foreach x of local list {
	generate r_`x' = `x' / dynamicppp
	generate lr_`x' = ln(r_`x')
}

// Adjust scale

local list = "civilservant migrant white formalworker highskilled universityprivate universitypublic retiree pensioneer highskilled_cs "

foreach x of local list {
	replace `x' = `x' * 100
}

// Adjust Gini

generate lgini = ln(gini)
generate dlgini = (lgini - l.lgini) * 100
replace lgini = . if dlgini > 15 & dlgini != . | dlgini < -15 & dlgini != .
bysort uf: ipolate lgini  year, gen(lgini_temp) 
replace lgini = lgini_temp
drop lgini_temp
drop dlgini
replace gini = exp(lgini)


///////////////////////////////////////////////////////////////////////////////
////////////////////////// 4. RUN REGRESSIONS //////////////////////////
///////////////////////////////////////////////////////////////////////////////


reg lgini $regressors i.uf

// Store Results

matrix A = e(b)'

// Create predicted values

local list = "$regressors $uflist _cons"

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

egen lgini_hat = rowtotal(hat_*)

keep if year == $first | year == $last
gen t = .
replace t = 1 if year == $first
replace t = 2 if year == $last

xtset uf t

local list = "$regressors $uflist _cons"

foreach x of local list  {
	gen dhat_`x' = d.hat_`x'
}


 gen dlgini_hat = d.lgini_hat
 gen dlgini = d.lgini
