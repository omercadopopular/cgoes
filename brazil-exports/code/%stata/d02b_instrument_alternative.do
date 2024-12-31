clear
capture log close
log using "logs\d02b.smcl", replace  					// chooses logfile

/// 1. create region specific export shares

use "data\temp\rais-panel-processed.dta", clear

// create export exposure

sort microregion_name isic3code3d year

egen groupid = group(uf microregion_code)

// create shares

bysort year groupid: egen TotalLF = sum(employment)
gen LaborShr = employment / TotalLF

drop groupid

// save tempfile

tempfile laborShrs
save `laborShrs', replace

/// 2. import trade by sector

use "data/temp/panel-isic3-3d.dta", clear

// drop missing years for GDP
drop if year < 1995
drop if year > 2022

rename isic3_3d isic3code3d

/// 4. merge and collapse

merge 1:m year isic3code3d using `laborShrs'
drop if _merge < 3

egen groupid = group(uf microregion_code isic3code3d)
xtset groupid year

gen lforeigndemandus = log(foreigndemandus)
gen gFD = lforeigndemandus - l.lforeigndemandus
gen g2FD = foreigndemandus / l.foreigndemandus - 1


gen giv_comtrade = l.LaborShr * gFD 
gen g2iv_comtrade = l.LaborShr * g2FD 

// collapse and save new dataset

collapse (sum) giv_comtrade g2iv_comtrade LaborShr, by(year ufCode uf ufName microregion_name microregion_code)

// replace missing values

replace giv_comtrade = . if giv == 0
replace g2iv_comtrade = . if g2iv == 0

local group "giv_comtrade g2iv_comtrade"
foreach var of local group {
	winsor2 `var', cuts(1 99) suffix(_w) trim
}

save "data\temp\microregion-alternative-instrument.dta", replace

merge 1:1 year ufCode uf ufName microregion_name microregion_code using "data\temp\microregion-trade-panel-inst.dta"

drop _merge

save "data\temp\microregion-trade-panel-processed.dta", replace

log close