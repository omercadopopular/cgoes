clear all
set more off
set type double, permanently

cap log close
log using "./output/logs/log_c04.smcl", append

///////////////////
///Preliminaries///
///////////////////

*Open database.
use exporter importer hs6 hs_section ahs_st ln_ahs_st imports_baci ln_trade_val year using "./temp_files/DataregW_did.dta", clear

*Keep data from 2006.
keep if year==2006

*Save database.
save "./temp_files/DataregW_did_ahs_st_2006.dta", replace
