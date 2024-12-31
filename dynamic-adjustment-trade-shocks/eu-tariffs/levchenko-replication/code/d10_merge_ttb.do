clear all
set more off

cap log close
log using "./output/logs/log_d10.smcl", append

*Open database.
use "./temp_files/DataregW_did.dta",clear

*Merge TTB databases.
merge 1:1 importer exporter hs6 nomen year using "./temp_files/main_AD.dta"
drop if _merge==2
drop _merge
rename TTB TTB_AD
merge 1:1 importer exporter hs6 nomen year using "./temp_files/main_TTB.dta"
drop if _merge==2
drop _merge
rename TTB TTB_TTB
merge m:1 importer hs6 nomen year using "./temp_files/main_SGD.dta"
drop if _merge==2
drop _merge

*Replace values.
replace TTB=1 if TTB_TTB==1
drop TTB_TTB
replace TTB=1 if TTB_AD ==1
drop TTB_AD

*Save database.
save "./temp_files/DataregW_did.dta", replace
