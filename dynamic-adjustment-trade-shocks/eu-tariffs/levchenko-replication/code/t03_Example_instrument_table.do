clear all
set more off

cap log close
log using "./output/logs/log_t03.smcl", append

/////////////
///Example///
/////////////

********************************************
*LISTS OF COUNTRIES

** DESTINATIONS -- USA, GERMANY, JAPAN
** Year -- 2006
** Product -- Footwear; with outer soles of rubber, plastics, leather or composition leather and uppers of leather

*************************************

*Open database.
use if (year==2006|year==2005)  & (importer=="USA"| importer=="DEU" | importer=="JPN") & nomen=="H92" using "./temp_files/DataregW_did.dta", clear

*Declare panel.
xtset panel_id year

*Generate lagged variables.
g Lminor_partner_agg= L.minor_partner_agg
g Lminor_partner_prod4= L.minor_partner_prod4
g lmfn_binding  = L.mfn_binding

*Generate treatment group indicator.
g treat_group = minor_partner_agg*Lminor_partner_agg*minor_partner_prod4*Lminor_partner_prod4*mfn_binding*lmfn_binding

*Replace iv tariff with missing for partners where the MFN is the applied tariff but we think they are endogenous because of size.
gen temp = minor_partner_agg*Lminor_partner_agg*minor_partner_prod4*Lminor_partner_prod4
replace treat_group = 2 if (mfn_binding==1) & (lmfn_binding==1) &(temp ==0)
drop temp

*treat_group==1 is potential to treat, treat_group ==0 is control, treat_group==2 is excluded, treat_group==. is where some indicator is missing (lag product 4)

*Drop 2005 observations.
drop if year==2005

///////////////////
///Minor partner///
///////////////////

preserve
keep importer year exporter minor_partner_agg imports_baci 
keep if minor_partner_agg==0

collapse (sum) imports_baci (firstnm) minor_partner_agg, by(importer year exporter)

gsort importer year -imports_baci
drop year
rename exporter agg_06
by importer: gen rank = _n
keep importer rank agg_06
save "./output/tables/illustrative_table.dta", replace

restore

preserve
keep importer year exporter Lminor_partner_agg imports_baci 
keep if Lminor_partner_agg==0

collapse (sum) imports_baci (firstnm) Lminor_partner_agg, by(importer year exporter)

gsort importer year -imports_baci
drop year

rename exporter agg_05
by importer: gen rank = _n
keep importer rank agg_05

merge 1:1 importer rank  using "./output/tables/illustrative_table.dta"
drop _m

save "./output/tables/illustrative_table.dta", replace

restore

/////////////////
///MFN binding///
/////////////////

preserve
keep importer year exporter mfn_binding imports_baci ahs_st
keep if mfn_binding==1 & ahs_st!=0

collapse (sum) imports_baci (firstnm) mfn_binding, by(importer year exporter)

gsort importer year -imports_baci
drop year
rename exporter mfn_06
by importer: gen rank = _n
keep if rank<=10
keep importer rank mfn_06
merge 1:1 importer rank  using "./output/tables/illustrative_table.dta"
drop _m
save "./output/tables/illustrative_table.dta", replace

restore

preserve
keep importer year exporter lmfn_binding imports_baci ahs_st
keep if lmfn_binding==1 & ahs_st!=0

collapse (sum) imports_baci (firstnm) lmfn_binding, by(importer year exporter)

gsort importer year -imports_baci
drop year

rename exporter mfn_05
by importer: gen rank = _n
keep if rank<=10
keep importer rank mfn_05

merge 1:1 importer rank  using "./output/tables/illustrative_table.dta"
drop _m

save "./output/tables/illustrative_table.dta", replace

restore

//////////////////////////////////
///Motor vehicles trade partner///
//////////////////////////////////

preserve
keep if hs4=="6403"
keep importer year exporter minor_partner_prod4 imports_baci 
keep if minor_partner_prod4==0

collapse (sum) imports_baci, by(importer year exporter)

gsort importer year -imports_baci
drop year
rename exporter partner_06
by importer: gen rank = _n
keep importer rank partner_06
merge 1:1 importer rank  using "./output/tables/illustrative_table.dta"
drop _m
save "./output/tables/illustrative_table.dta", replace

restore

preserve
keep if hs4=="6403"
keep importer year exporter Lminor_partner_prod4 imports_baci 
keep if Lminor_partner_prod4==0

collapse (sum) imports_baci, by(importer year exporter)

gsort importer year -imports_baci
drop year
rename exporter partner_05
by importer: gen rank = _n
keep importer rank partner_05
merge 1:1 importer rank  using "./output/tables/illustrative_table.dta"
drop _m
save "./output/tables/illustrative_table.dta", replace

restore

//////////////////////////////////
///Treatment, control, excluded///
//////////////////////////////////

preserve
keep if treat_group==1 & hs4=="6403"
keep importer year exporter imports_baci 

collapse (sum) imports_baci, by(importer year exporter)

gsort importer year -imports_baci
drop year
rename exporter treated
by importer: gen rank = _n
keep importer rank treated
drop if rank>10
merge 1:1 importer rank  using "./output/tables/illustrative_table.dta"
drop _m
save "./output/tables/illustrative_table.dta", replace

restore

preserve
keep if treat_group==0  & hs4=="6403"
keep importer year exporter imports_baci 

collapse (sum) imports_baci, by(importer year exporter)

gsort importer year -imports_baci
drop year
rename exporter control
by importer: gen rank = _n
keep importer rank control
drop if rank>10
merge 1:1 importer rank  using "./output/tables/illustrative_table.dta"
drop _m
save "./output/tables/illustrative_table.dta", replace

restore

preserve
keep if treat_group==2  & hs4=="6403"
keep importer year exporter imports_baci 

collapse (sum) imports_baci, by(importer year exporter)

gsort importer year -imports_baci
drop year
rename exporter excluded
by importer: gen rank = _n
drop if rank>10
keep importer rank excluded
merge 1:1 importer rank  using "./output/tables/illustrative_table.dta"
drop _m
save "./output/tables/illustrative_table.dta", replace

restore

use "./output/tables/illustrative_table.dta", clear
order rank importer mfn_05 mfn_06 agg_05 agg_06 partner_05 partner_06 treated control excluded
sort importer rank
save "./output/tables/illustrative_table.dta", replace
