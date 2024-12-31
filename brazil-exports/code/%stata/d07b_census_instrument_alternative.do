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

gen t_LaborShr2000 = LaborShr if year == 2000
bysort microregion_name isic3code3d: egen LaborShr2000 = mean(t_LaborShr2000)

// save tempfile

save "data\temp\census-laborShrs.dta", replace

/// 2. import trade by sector


use "data/temp/panel-isic3-3d.dta", clear

// keep only 2000, 2010

keep if year == 2000 | year == 2010

// reshape 
reshape wide foreigndemandus, i(isic3_3d) j(year)

rename isic3_3d isic3code3d

save "data\temp\tradeIsic.dta", replace


merge 1:m isic3code3d using "data\temp\census-laborShrs.dta"

// calculate missing workers

cap qui total worker_tot if missing(foreigndemandus2000) & missing(foreigndemandus2010)
local missing = _b[worker_tot]
qui total worker_tot
local total = _b[worker_tot]
display "`=`missing' / `total''"

keep if _merge == 3

// gen exposures

gen lforeigndemandus2010 = log(foreigndemandus2010)
gen lforeigndemandus2000 = log(foreigndemandus2000)
gen gFD = lforeigndemandus2010 - lforeigndemandus2000
gen g2FD = foreigndemandus2010 / foreigndemandus2000 - 1

gen giv_comtrade = LaborShr2000 * gFD 
gen g2iv_comtrade = LaborShr2000 * g2FD 

// collapse and save new dataset

keep if year == 2010

collapse (sum) LaborShr2000 giv_comtrade g2iv_comtrade, by(year ufCode uf ufName microregion_name microregion_code)

// replace missing values

replace giv_comtrade = . if giv == 0
replace g2iv_comtrade = . if g2iv == 0

local group "giv_comtrade g2iv_comtrade"
foreach var of local group {
	winsor2 `var', cuts(1 99) suffix(_w) trim
}

// merge with growth rates dataset

merge 1:1 year ufCode uf ufName microregion_name microregion_code using "data\temp\census-growth-rates.dta"
drop _merge

merge 1:1 year ufCode uf ufName microregion_name microregion_code using "data\temp\census-microregion-trade-panel-processed.dta"
drop _merge

save "data\temp\census-microregion-trade-panel-processed.dta", replace

// erase tempfiles

erase "data\temp\tradeIsic.dta"
*erase "data\temp\rais-panel-processed.dta"

log close