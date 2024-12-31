clear
capture log close
log using "logs\d08.smcl", replace  					// chooses logfile

/// 1. import exports dataset at the microregion level

import delimited "data\trade-processed\microregionTradeExp19972023.csv", clear


// rename variables
rename co_ano year
rename no_mr microregion_name
rename co_mr microregion_code_ibge
rename pop pop2022

// keep only 2000, 2010
keep if year == 2000 | year == 2010

// reshape 
drop pop2022
reshape wide vl_fob vl_fobr, i(uf microregion_name microregion_code_ibge) j(year)

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
merge 1:1 microregion_code_ibge using "data\temp\census-microregion-trade-panel-processed.dta"

save "data\temp\master-dataset-census.dta", replace
log close
