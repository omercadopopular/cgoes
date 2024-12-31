clear all
set more off

cap log close
log using "./output/logs/log_d11.smcl", append

use "./data/PWT/pwt91.dta", clear

keep countrycode year rgdpo
rename countrycode importer
drop if year<1995
save "./temp_files/pwt_importer.dta", replace
rename importer exporter

save "./temp_files/pwt_exporter.dta", replace
