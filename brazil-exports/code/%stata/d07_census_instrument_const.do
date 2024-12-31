clear
capture log close
log using "logs\d07.smcl", replace  					// chooses logfile

/// 1. create region specific export shares

use "data\temp\census-panel-processed.dta", clear

// create export exposure

sort microregion_name isic3code3d year

egen groupid = group(uf microregion_code)

// create shares

bysort year groupid: egen TotalLF = sum(worker_tot)
gen LaborShr = worker_tot / TotalLF

drop groupid


gen t_LaborShr2000 = LaborShr if year == 2000
bysort microregion_name isic3code3d: egen LaborShr2000 = mean(t_LaborShr2000)

// save tempfile

save "data\temp\census-laborShrs.dta", replace

/// 2. import trade by partner, uf, and isic-section and perform necessary changes in data

import delimited "data\trade-processed\tradeDest19892023-3digit.csv", clear stringcols(1 4 5 6)

// keep only 2000, 2010

keep if year == 2000 | year == 2010
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
collapse (sum) vl_fob vl_fobr (first) pce adj isic3code1d isic3code2d, by(uf year iso3code isic3code3d)

// drop if uf non-reported as state

drop if inlist(uf, "EX", "ZN", "CB", "MN", "RE", "ED", "ND")

// reshape 
reshape wide vl_fob vl_fobr pce adj, i(iso3code isic3code3d uf) j(year)

// create shares
bysort uf isic3code3d: egen TotalExp2000 = sum(vl_fobr2000)
gen ExpShr2000 = vl_fobr2000 / TotalExp2000

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


// Reshape

reshape long GDP, i(CountryName CountryCode IndicatorName IndicatorCode)
*rename _j Year
*rename Y gdppercapita
rename CountryCode iso3code
rename CountryName iso3name
rename _j year
drop IndicatorName IndicatorCode

// keep only 2000, 2010

keep if year == 2000 | year == 2010

// reshape
reshape wide GDP, i(iso3name iso3code) j(year)

// merge

merge 1:m iso3code using "data\temp\tradeDest.dta"
keep if _merge == 3
drop _merge

// adjust deflators

gen t_adj2000 = adj2000
gen t_adj2010 = adj2010
drop adj2000 adj2010
qui sum t_adj2000
gen adj2000 = r(mean)
qui sum t_adj2010
gen adj2010 = r(mean)
drop t_*

// transform dollar GDP to real values, using same deflator
local group 2000 2010
foreach yr of local group {
	gen GDP`yr'r = GDP`yr' / adj`yr'
	gen lGDP`yr'r = log(GDP`yr'r)

}

gen gGDPr = lGDP2010r - lGDP2000r
gen g2GDPr = (GDP2010r - GDP2000r)/GDP2000r
gen dGDPr = GDP2010r - GDP2000r

gen gGDPcont = ExpShr2000 * gGDPr
gen g2GDPcont = ExpShr2000 * g2GDPr
gen dGDPcont = ExpShr2000 * dGDPr

collapse (sum) gGDPcont g2GDPcont dGDPcont, by(uf isic3code3d)

// drop missing obs
drop if gGDPcont == 0

// rename
rename gGDPcont gGDPrExp
rename g2GDPcont g2GDPrExp
rename dGDPcont dGDPrExp

/// 4. merge and collapse

merge 1:m uf isic3code3d using "data\temp\census-laborShrs.dta"
drop if _merge == 1

gen giv = LaborShr2000 * gGDPrExp 
gen g2iv = LaborShr2000 * g2GDPrExp 

// collapse and save new dataset

keep if year == 2010

collapse (sum) giv g2iv, by(year ufCode uf ufName microregion_name microregion_code)

// replace missing values

replace giv = . if giv == 0
replace g2iv = . if g2iv == 0

local group "giv g2iv"
foreach var of local group {
	winsor2 `var', cuts(1 99) suffix(_w) trim
}

save "data\temp\census-microregion-trade-panel-processed.dta", replace

// erase tempfiles

erase "data\temp\tradeDest.dta"
*erase "data\temp\rais-panel-processed.dta"

log close