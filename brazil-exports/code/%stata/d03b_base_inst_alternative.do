clear
capture log close
log using "logs\d02.smcl", replace  					// chooses logfile

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

save "data\temp\laborShrs.dta", replace

/// 2. import trade by sector

use "data/temp/panel-isic3-3d.dta", clear

// drop missing years for GDP
drop if year < 1995
drop if year > 2022

rename isic3_3d isic3code3d

/// 4. merge and collapse

merge 1:m year isic3code3d using "data\temp\laborShrs.dta"
drop if _merge < 3

egen groupid = group(uf microregion_code isic3code3d)
xtset groupid year

gen lforeigndemandus = log(foreigndemandus)


gen t_base_lfdus = lforeigndemandus if year == $baseyear
gen t_base_fdus = foreigndemandus if year == $baseyear
gen t_base_lfdus_e = lforeigndemandus if year == $endyear
gen t_base_fdus_e = foreigndemandus if year == $endyear
gen t_base_LaborShr = LaborShr if year == $baseyear
bysort groupid: egen base_lfdus = mean(t_base_lfdus)
bysort groupid: egen base_fdus = mean(t_base_fdus)
bysort groupid: egen base_lfdus_e = mean(t_base_lfdus_e)
bysort groupid: egen base_fdus_e = mean(t_base_fdus_e)
bysort groupid: egen base_LaborShr = mean(t_base_LaborShr)
drop t_*

gen gFD = base_lfdus_e - base_lfdus
gen g2FD = base_fdus_e / base_fdus - 1

gen givbase_comtrade = l.base_LaborShr * gFD 
gen g2ivbase_comtrade = l.base_LaborShr * g2FD 

// collapse and save new dataset

collapse (sum) givbase_comtrade g2ivbase_comtrade, by(year ufCode uf ufName microregion_name microregion_code)

// replace missing values

replace givbase_comtrade = . if givbase_comtrade == 0
replace g2ivbase_comtrade = . if g2ivbase_comtrade == 0

save "data\temp\microregion-alternative-instrument.dta", replace

merge 1:1 year ufCode uf ufName microregion_name microregion_code using "data\temp\microregion-trade-panel-inst-base.dta"
drop _merge


merge 1:1 year ufCode uf ufName microregion_name microregion_code using "data\temp\microregion-trade-panel-processed.dta"
drop _merge

save "data\temp\microregion-trade-panel-processed-base.dta", replace

*erase "data\temp\microregion-trade-panel-processed.dta", replace


log close