capture log close 										// closes any open logs
clear 													// clears the memory
clear matrix 											// clears matrix memory
clear mata 												// clears mata memory
cd "C:\Users\wb592068\OneDrive - WBG\Brazil" 				// sets working directory
set more off  											// most important command in STATA :)/
set maxvar 32000
set matsize 11000
set max_memory 5g
log using "logs\s01.smcl", replace  					// chooses logfile

import delimited "data\trade-processed\microregionTradeExp19972023.csv", clear

rename co_ano year
rename no_mr microregion_name
rename co_mr microregion_code_ibge

egen groupid = group(microregion_code_ibge)

xtset groupid year

gen lnvl_fobr = log(vl_fobr)
gen gExpObs =  lnvl_fobr - l.lnvl_fobr

merge 1:1 year microregion_code_ibge using "data\temp\microregion-trade-panel-processed.dta"


keep if _merge == 3

xtset groupid year

gen dvl_fobr = d.vl_fobr

local group "giv div gExpObs dvl_fobr"
foreach var of local group {
	winsor2 `var', cuts(1 99) suffix(_w1) trim
	winsor2 `var', cuts(5 95) suffix(_w5) trim
}

xtreg gExpObs giv
xtreg gExpObs_w1 giv_w1
xtreg gExpObs_w5 giv_w5

xtreg dvl_fobr div
xtreg dvl_fobr_w1 div_w1
xtreg dvl_fobr_w5 div_w5

qui reg dvl_fobr_w5 i.microregion_code_ibge
predict dvl_fobr_w5_r, r

qui reg div_w5 i.microregion_code_ibge
predict div_w5_r, r

binscatter dvl_fobr_w5_r div_w5_r

qui reg gExpObs_w i.microregion_code_ibge
predict gExpObs_w_r, r

qui reg gExpTotalLF_w i.microregion_code_ibge
predict gExpTotalLF_w_r, r

binscatter gExpObs_w_r gExpTotalLF_w_r


