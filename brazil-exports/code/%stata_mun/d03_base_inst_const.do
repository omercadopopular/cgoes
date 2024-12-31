clear
capture log close
log using "logs\d03.smcl", replace  					// chooses logfile

/// 1. create region specific export shares

use "data\temp\rais-panel-processed-mun.dta", clear

// generate isic 2 digit codes
gen isic3code2d = substr(isic3code3d,1,2)

// create export exposure

sort isic3code3d year

// collapse data by isic3code2d year
collapse (first) ufCode (sum) employment, by( mun_code_ibge isic3code3d year )

// create shares
egen groupid = group(ufCode mun_code)
bysort year groupid: egen TotalLF = sum(employment)
gen LaborShr = employment / TotalLF

drop groupid

// save tempfile

save "data\temp\laborShrs.dta", replace

/// 2. import trade by partner, uf, and isic-section and perform necessary changes in data

import delimited "data\trade-processed\tradeDest19892023-3digit.csv", clear stringcols(1 4 5 6)

// add state codes

gen ufCode = .

replace ufCode = 12 if uf == "AC"
replace ufCode = 27 if uf == "AL"
replace ufCode = 16 if uf == "AP"
replace ufCode = 13 if uf == "AM"
replace ufCode = 29 if uf == "BA"
replace ufCode = 23 if uf == "CE"
replace ufCode = 53 if uf == "DF"
replace ufCode = 32 if uf == "ES"
replace ufCode = 52 if uf == "GO"
replace ufCode = 21 if uf == "MA"
replace ufCode = 51 if uf == "MT"
replace ufCode = 50 if uf == "MS"
replace ufCode = 31 if uf == "MG"
replace ufCode = 15 if uf == "PA"
replace ufCode = 25 if uf == "PB"
replace ufCode = 41 if uf == "PR"
replace ufCode = 26 if uf == "PE"
replace ufCode = 22 if uf == "PI"
replace ufCode = 24 if uf == "RN"
replace ufCode = 43 if uf == "RS"
replace ufCode = 33 if uf == "RJ"
replace ufCode = 11 if uf == "RO"
replace ufCode = 14 if uf == "RR"
replace ufCode = 42 if uf == "SC"
replace ufCode = 35 if uf == "SP"
replace ufCode = 28 if uf == "SE"
replace ufCode = 17 if uf == "TO"

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
collapse (sum) vl_fob vl_fobr (first) pce adj isic3code1d isic3code2d, by(ufCode uf year iso3code isic3code3d)

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
egen groupid = group(ufCode uf isic3code3d iso3code)

bysort year uf isic3code3d: egen TotalExp = sum(vl_fobr)
gen ExpShr = vl_fobr / TotalExp

xtset groupid year

// fixed year instrument

gen t_baseExpShr = ExpShr if year == $baseyear
gen t_baselGDP = lGDPr if year == $baseyear
gen t_baseGDP = GDPr if year == $baseyear
gen t_baselGDP_e = lGDPr if year == $endyear
gen t_baseGDP_e = GDPr if year == $endyear
bysort groupid: egen baselGDP = mean(t_baselGDP)
bysort groupid: egen baseGDP = mean(t_baseGDP)
bysort groupid: egen baseExpShr = mean(t_baseExpShr)
bysort groupid: egen baselGDP_e = mean(t_baselGDP_e)
bysort groupid: egen baseGDP_e = mean(t_baseGDP_e)
drop t_*

gen gGDPbaser = baselGDP_e - baselGDP
gen gGDPbasecont = baseExpShr * gGDPbaser

collapse (sum) gGDPbasecont, by(year ufCode isic3code3d)

// drop missing obs
drop if year < 1996
local vars gGDPbasecont
foreach var of local vars {
		replace `var' = . if `var' == 0
}

// rename
rename gGDPbasecont gGDPrExpbase

/// 4. merge and collapse

merge 1:m year ufCode isic3code3d using "data\temp\laborShrs.dta"
drop if _merge == 1

egen groupid = group(ufCode mun_code isic3code3d)
drop if missing(groupid)
xtset groupid year

// fixed year instrument
gen t_LaborShrbase = LaborShr if year == $baseyear
bysort groupid: egen LaborShrbase = mean(t_LaborShrbase)
drop t_*

gen givbase = LaborShrbase * gGDPrExpbase 

replace LaborShrbase = . if givbase == 0


// collapse and save new dataset

collapse (sum) giv* (first) LaborShrbase, by(year ufCode mun_code)

// drop missing obs
drop if year < 1996
local vars givbase
foreach var of local vars {
		replace `var' = . if `var' == 0
}

save "data\temp\mun-trade-panel-inst-base.dta", replace

// erase tempfiles
erase "data\temp\tradeDest.dta"
*erase "data\temp\rais-panel-processed.dta"

log close