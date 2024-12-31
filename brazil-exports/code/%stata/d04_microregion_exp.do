clear
capture log close
log using "logs\d04.smcl", replace  					// chooses logfile

/// 1. import exports dataset at the microregion level

import delimited "data\trade-processed\microregionTradeExp19972023.csv", clear


// rename variables
rename co_ano year
rename no_mr microregion_name
rename co_mr microregion_code_ibge
rename pop pop2022

// set panel
egen groupid = group(microregion_name microregion_code_ibge)
xtset groupid year

// generate exports growth variable
gen lnvl_fobr =  log(vl_fobr)
gen gvl_fobr =  lnvl_fobr - l.lnvl_fobr
gen g2vl_fobr =  (vl_fobr - l.vl_fobr)/l.vl_fobr

// generate exports growth variable
gen lnvl_fob =  log(vl_fob)
gen gvl_fob =  lnvl_fob - l.lnvl_fob
gen g2vl_fob =  (vl_fob - l.vl_fob)/l.vl_fob

// generate exports growth variable, fixed period
gen t_vl_fob_base = vl_fob if year == $baseyear
gen t_vl_fobr_base = vl_fobr if year == $baseyear
gen t_lnvl_fob_base = lnvl_fob if year == $baseyear
gen t_lnvl_fobr_base = lnvl_fobr if year == $baseyear

gen t_vl_fobr_base_e = vl_fobr if year == $endyear
gen t_vl_fob_base_e = vl_fob if year == $endyear
gen t_lnvl_fobr_base_e = lnvl_fobr if year == $endyear
gen t_lnvl_fob_base_e = lnvl_fob if year == $endyear

bysort groupid: egen vl_fobr_base = mean(t_vl_fobr_base)
bysort groupid: egen lnvl_fobr_base = mean(t_lnvl_fobr_base)
bysort groupid: egen vl_fob_base = mean(t_vl_fob_base)
bysort groupid: egen lnvl_fob_base = mean(t_lnvl_fob_base)

bysort groupid: egen vl_fobr_base_e = mean(t_vl_fobr_base_e)
bysort groupid: egen lnvl_fobr_base_e = mean(t_lnvl_fobr_base_e)
bysort groupid: egen vl_fob_base_e = mean(t_vl_fob_base_e)
bysort groupid: egen lnvl_fob_base_e = mean(t_lnvl_fob_base_e)

gen gvl_fobr_base = lnvl_fobr_base_e - lnvl_fobr_base
gen g2vl_fobr_base = (vl_fobr_base_e - vl_fobr_base)/vl_fobr_base
gen gvl_fob_base = lnvl_fob_base_e - lnvl_fob_base
gen g2vl_fob_base = (vl_fob_base_e - vl_fob_base)/vl_fob_base

drop vl_fobr_base vl_fobr_base_e vl_fob_base vl_fob_base_e lnvl_fobr_base lnvl_fobr_base_e lnvl_fob_base lnvl_fob_base_e t_*



/// 2. merge with rais dataset
merge 1:1 year microregion_code_ibge using "data\temp\microregion-trade-panel-processed-base.dta"

// drop missing years
drop if year < 1997 | year > 2022

// input obs with zero exports
local vars = "vl_fobr vl_fob"
foreach var of local vars {
	replace `var' = 0 if missing(`var') | _merge == 2
}

// drop merge
drop _merge

// set panel

drop groupid
egen groupid = group(uf ufCode ufName microregion_name microregion_code_ibge)
keep if !missing(groupid)

xtset groupid year

// verify that all microregions are there

qui sum groupid

if `r(max)' != 558 {
	di "Missing microregions!"
	break
}

// winsorize

local group "gvl_fobr g2vl_fobr gvl_fob g2vl_fob"
foreach var of local group {
	winsor2 `var', cuts(1 99) suffix(_w) trim
}


/// 3. erase dataset and close log

save "data\temp\microregion-trade-panel-processed-exp.dta", replace 
*erase "data\temp\microregion-trade-panel-processed-base.dta"

log close
