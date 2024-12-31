clear
capture log close
log using "logs\d08.smcl", replace  					// chooses logfile

/// 1. import exports dataset at the microregion level

import delimited "data\trade-processed\munTradeExp19972023.csv", clear



// rename variables
rename co_ano year
rename no_mun mun_name
rename pop pop2022

gen t_mun_code_ibge = substr(string(co_mun),1,6)
destring t_mun_code_ibge, gen(mun_code_ibge)
drop t_*

// keep only 2000, 2010
keep if year == 2000 | year == 2010

// reshape 
drop pop2022
reshape wide vl_fob vl_fobr pce adj, i(uf mun_code_ibge) j(year)

// generate exports growth variable
gen lnvl_fob2000 =  log(vl_fob2000)
gen lnvl_fob2010 =  log(vl_fob2010)
gen gvl_fob =  lnvl_fob2010 - lnvl_fob2000
gen g2vl_fob =  (vl_fob2010 - vl_fob2000)/vl_fob2000

// generate exports growth variable
gen lnvl_fobr2000 =  log(vl_fobr2000)
gen lnvl_fobr2010 =  log(vl_fobr2010)
gen gvl_fobr =  lnvl_fobr2010 - lnvl_fobr2000
gen g2vl_fobr =  (vl_fobr2010 - vl_fobr2000)/vl_fobr2000


/// 2. merge with census dataset
merge 1:1 mun_code_ibge using "data\temp\mun-census-microregion-trade-panel-processed.dta"

save "data\temp\mun-master-dataset-census.dta", replace
log close
