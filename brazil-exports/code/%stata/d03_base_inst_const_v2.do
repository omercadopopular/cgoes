clear
capture log close
log using "logs\d03.smcl", replace  					// chooses logfile

/// 1. create region specific export shares

use "data\temp\rais-panel-processed.dta", clear

// generate isic 2 digit codes
gen isic3code2d = substr(isic3code3d,1,2)

// create export exposure

sort microregion_name isic3code2d year

// collapse data by microregion_name isic3code2d year
collapse (first) ufCode ufName uf microregion_code_ibge (sum) laborforce female less_than_primary primary secondary college_or_higher wage_mass wage_mass_sexo_1 wage_mass_less_than_pri wage_mass_secondary wage_mass_college, by( microregion_name isic3code2d year )

// create shares
egen groupid = group(uf microregion_code)
bysort year groupid: egen TotalLF = sum(laborforce)
gen LaborShr = laborforce / TotalLF

drop groupid

// save tempfile

save "data\temp\laborShrs.dta", replace

/// 2. import trade by partner, uf, and isic-section and perform necessary changes in data

import delimited "data\trade-processed\tradeDest19892023-2digit.csv", clear stringcols(2 3 4 5)

// drop missing years for GDP
drop if year < 1995
drop if year > 2022

// manual changes in country codes
replace iso3code = "GBR" if iso3code == "AIA" // anguilla -> UK
replace iso3code = "FIN" if iso3code == "ALA" // Aland Islands  -> Finland
replace iso3code = "NLD" if iso3code == "ANT" // Netherlands Antilles -> Netherlands
replace iso3code = "FRA" if iso3code == "ATF" // French Southern Lands  -> France
replace iso3code = "NLD" if iso3code == "BES" // Bonaire, Saint Eustatius and Saba -> Netherlands
replace iso3code = "FRA" if iso3code == "BLM" // Saint Barthelemy  -> France
replace iso3code = "GBR" if iso3code == "COK" // Cook Islands -> UK
replace iso3code = "FRA" if iso3code == "GLP" // Guadeloupe  -> France
replace iso3code = "FRA" if iso3code == "GUF" // French Guyana -> France
replace iso3code = "FRA" if iso3code == "MTQ" // Martinique -> France
replace iso3code = "FRA" if iso3code == "REU" // Reunion -> France

// collapse with new aggregation
collapse (sum) vl_fob vl_fobr (first) isic3code1d, by(uf year iso3code isic3code2d)

// drop if uf non-reported as state

drop if inlist(uf, "EX", "ZN", "CB", "MN", "RE", "ED", "ND")

save "data\temp\tradeDest.dta", replace

/// 3. Create Market-Specific Exposure to GDP growth, by ISIC sector

import excel "data\wdi\API_NY.GDP.MKTP.CD_DS2_en_excel_v2_93.xls", sheet("Data") firstrow cellrange(A4:BO270) clear
*import excel "${wdipath}\API_NY.GDP.PCAP.KD_DS2_en_excel_v2_4024802", sheet("Data") firstrow cellrange(A4:BM270) clear
local variables = "E F G H I J K L M N O P Q R S T U V W X Y Z AA AB AC AD AE AF AG AH AI AJ AK AL AM AN AO AP AQ AR AS AT AU AV AW AX AY AZ BA BB BC BD BE BF BG BH BI BJ BK BL BM BN BO"
foreach var of local variables {
    local x: variable label `var'
	rename `var' GDP`x'
}

forvalues x = 1960/1994 {
	drop GDP`x'
}

// to-do: incorporate taiwan?

// Reshape

reshape long GDP, i(CountryName CountryCode IndicatorName IndicatorCode)
*rename _j Year
*rename Y gdppercapita
rename CountryCode iso3code
rename CountryName iso3name
rename _j year
drop IndicatorName IndicatorCode

egen groupid = group(iso3code iso3name)

xtset groupid year

drop groupid

// merge

merge 1:m year iso3code using "data\temp\tradeDest.dta"
keep if _merge == 3
drop _merge

// transform dollar GDP to real values, using same deflator
gen GDPr = GDP // / adj
gen lGDPr = log(GDPr)

// create shares, dynamic
egen groupid = group(uf isic3code2d iso3code)

bysort year uf isic3code2d: egen TotalExp = sum(vl_fobr)
gen ExpShr = vl_fobr / TotalExp

xtset groupid year

// fixed year instrument

gen t_baseExpShr = ExpShr if year == $baseyear
gen t_baselGDP = lGDPr if year == $baseyear
gen t_baseGDP = GDPr if year == $baseyear
gen t_endlGDP = lGDPr if year == $endyear
gen t_endGDP = GDPr if year == $endyear
bysort groupid: egen baselGDP = mean(t_baselGDP)
bysort groupid: egen baseGDP = mean(t_baseGDP)
bysort groupid: egen baseExpShr = mean(t_baseExpShr)
bysort groupid: egen endlGDP = mean(t_endlGDP)
bysort groupid: egen endGDP = mean(t_endGDP)
drop t_*

gen gGDPbaser = endlGDP - baselGDP
gen dGDPbaser = endGDP - baseGDP
gen gGDPbasecont = baseExpShr * gGDPbaser
gen dGDPbasecont = baseExpShr * dGDPbaser


collapse (sum) gGDPbasecont dGDPbasecont, by(year uf isic3code2d)


// drop missing obs
drop if year < 1996
local vars gGDPbasecont dGDPbasecont
foreach var of local vars {
		replace `var' = . if `var' == 0
}

// rename
rename gGDPbasecont gGDPrExpbase
rename dGDPbasecont dGDPrExpbase

/// 4. merge and collapse

merge 1:m year uf isic3code2d using "data\temp\laborShrs.dta"
drop if _merge == 1

egen groupid = group(uf microregion_code isic3code2d)
xtset groupid year

// fixed year instrument
gen t_LaborShrbase = LaborShr if year == $baseyear
bysort groupid: egen LaborShrbase = mean(t_LaborShrbase)
drop t_*

gen givbase = LaborShrbase * gGDPrExpbase 
gen divbase = LaborShrbase * dGDPrExpbase 

replace LaborShrbase = . if givbase == 0


// collapse and save new dataset

collapse (sum) giv* div* LaborShrbase, by(year ufCode uf ufName microregion_name microregion_code)
rename LaborShrbase lshare_base

// drop missing obs
drop if year < 1996
local vars givbase divbase
foreach var of local vars {
		replace `var' = . if `var' == 0
}


merge 1:1 year ufCode uf ufName microregion_name microregion_code using "data\temp\microregion-trade-panel-processed.dta"
drop _merge

save "data\temp\microregion-trade-panel-processed.dta", replace

// erase tempfiles
erase "data\temp\tradeDest.dta"
*erase "data\temp\rais-panel-processed.dta"

log close