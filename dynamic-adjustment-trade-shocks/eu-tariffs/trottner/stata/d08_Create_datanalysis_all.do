clear all
set more off

cap log close
log using "./output/logs/log_d08.smcl", append

//////////////////
///Process data///
//////////////////

*Open database.
use "./temp_files/FillFinalMergedData.dta", clear

*Generate product code and product years.
egen long product=group(hs6 nomen)
bys product: egen prod_init_year=min(year) 
bys product: egen prod_last_year=max(year)

*Drop variables.
keep importer exporter year hs6 nomen ahs_st imports_baci mfn_binding quantity_baci prod_init_year prod_last_year

*Replace 0s where they are meaningful, missings otherwise. 
foreach var of varlist imports_baci quantity_baci{
	
	replace `var'=0 if year>=prod_init_year & year<=prod_last_year & `var'==.

}

*Tariffs are replaced with missing in years outside of the initial and last years.
replace ahs_st=. if year<prod_init_year | year>prod_last_year
drop if ahs_st==.
drop prod_init_year prod_last_year

*Divide tariffs by 100.
replace ahs_st=ahs_st/100
label variable ahs_st "Simple Average tariff (TRAINS)"
gen ln_ahs_st=log(1+ahs_st)

*Replace logs with inverse hyperbolic sine for trade only.
gen ln_trade_val=asinh(imports_baci)
gen ln_quantity=asinh(quantity_baci)

*Generate 2, 3 and 4 digit HS codes.
gen hs2=substr(hs6,1,2)
gen hs3=substr(hs6,1,3)
gen hs4=substr(hs6,1,4)

*Generate ID variable.
egen long panel_id=group(importer exporter hs6)

////////////////////////
///HS4 manual patches///
////////////////////////

*Generate patch variable.
gen hs4_patch=hs4

**2621 -- different code before and after 96 revision
replace hs4_patch="2621_92" if hs4=="2621" & (nomen=="H92" | nomen=="H96")

** aggregate 2852 and 2853 to 2851
replace hs4_patch="2851" if hs4=="2852" | hs4=="2853"

** 3823, 3824, 3825, 3826 aggregate to 3823
replace hs4_patch="3823" if hs4=="3824" | hs4=="3825" | hs4=="3826"

** everything after 4104 gets a patch in code 41 before nomen 02
replace hs4_patch=hs4_patch+"_92" if hs2=="41" & (nomen=="H92"|nomen=="H96") & (hs4!="4101") & (hs4!="4102") & (hs4!="4103")

** 6002 NES in 92 gets split into many codes
replace hs4_patch="6002" if hs4=="6003" | hs4=="6004" | hs4=="6005" | hs4=="6006"

**8508 -- different code before and after 07 revision (missing in 02 but on the safe side"
replace hs4_patch="8508_92" if hs4=="8508" & (nomen=="H92" | nomen=="H96" | nomen=="H02")

** aggregate 8519 and 8520 to 8519
replace hs4_patch="8519" if hs4=="8520"

** aggregate 8524 and 8523 to 8523
replace hs4_patch="8523" if hs4=="8524"

**8528 -- different code before and after 96 revision
replace hs4_patch="8528_02" if hs4=="2621" & (nomen=="H92" | nomen=="H96" | nomen=="H02")

**8548 -- different code before and after 92 revision
replace hs4_patch="8548_92" if hs4=="8548" & nomen=="H92"

** aggregate 9203 and 9204 to 9205
replace hs4_patch="9205" if hs4=="9203" | hs4=="9204"
** aggregate 9501 and 9502 to 9503
replace hs4_patch="9503" if hs4=="9501" | hs4=="9502"

////////////////////////
///HS6 manual patches///
////////////////////////

*Generate patch variable.
gen hs6_patch=hs6

replace hs6_patch="020741_92" if hs6=="020741" & nomen=="H92"
replace hs6_patch="020742_92" if hs6=="020742" & nomen=="H92"
replace hs6_patch="020743_92" if hs6=="020743" & nomen=="H92"

replace hs6_patch="121292_92" if hs6=="121292" & (nomen=="H92"|nomen=="H96")
replace hs6_patch="130214_17" if hs6=="130214" & (nomen=="H17")
replace hs6_patch="291817_17" if hs6=="291817" & (nomen=="H17")
replace hs6_patch="292112_17" if hs6=="292112" & (nomen=="H17")

replace hs6_patch="440721_92" if hs6=="440721" & (nomen=="H92")
replace hs6_patch="440722_92" if hs6=="440722" & (nomen=="H92")

replace hs6_patch="441011_96" if hs6=="441011" & (nomen=="H96")
replace hs6_patch="441019_96" if hs6=="441019" & (nomen=="H96")

replace hs6_patch="845690_92" if hs6=="845690" & (nomen=="H92")

*Save database.
save "./temp_files/data_int_all.dta", replace

///////////
///Panel///
///////////

*Open database.
use "./temp_files/data_int_all.dta", clear

*Declare panel.
xtset panel_id year

*Generate fixed effects.
egen long fe_imp_hs3_yr=group(importer hs3 year)
egen long fe_exp_hs3_yr=group(exporter hs3 year)
egen long fe_imp_hs3=group(importer hs3)
egen long fe_exp_hs3=group(exporter hs3)
egen long fe_imp_exp_hs3=group(importer exporter hs3)
egen long fe_imp_exp=group(importer exporter)
label variable fe_imp_hs3_yr "Destination-HS3-Year FE"
label variable fe_exp_hs3_yr "Source-HS3-Year FE"
label variable fe_imp_hs3 "Destination-HS3 FE"
label variable fe_exp_hs3 "Source-HS3 FE"
label variable fe_imp_exp_hs3 "Source-Destination-HS3 FE"
label variable fe_imp_exp "Source-Destination FE"
label variable panel_id "ID for bilateral hs6-nomenclature-level transaction"

egen long fe_imp_hs2_yr=group(importer hs2 year)
egen long fe_exp_hs2_yr=group(exporter hs2 year)
egen long fe_imp_exp_hs2=group(importer exporter hs2)
label variable fe_imp_hs2_yr "Destination-HS2-Year FE"
label variable fe_exp_hs2_yr "Source-HS2-Year FE"
label variable fe_imp_exp_hs2 "Source-Destination-HS2 FE"

egen long fe_imp_hs4_yr=group(importer hs4_patch year)
egen long fe_exp_hs4_yr=group(exporter hs4_patch year)
egen long fe_imp_exp_hs4=group(importer exporter hs4_patch)
label variable fe_imp_hs4_yr "Destination-HS4patch-Year FE"
label variable fe_exp_hs4_yr "Source-HS4patch-Year FE"
label variable fe_imp_exp_hs4 "Source-Destination-HS4patch FE"

egen long fe_imp_hs6_yr=group(importer hs6_patch year)
egen long fe_exp_hs6_yr=group(exporter hs6_patch year)
egen long fe_imp_exp_hs6=group(importer exporter hs6_patch)
label variable fe_imp_hs6_yr "Destination-HS6patch-Year FE"
label variable fe_exp_hs6_yr "Source-HS6patch-Year FE"
label variable fe_imp_exp_hs6 "Source-Destination-HS6patch FE"

egen long fe_imp=group(importer)
egen long fe_imp_yr=group(importer year)
label variable fe_imp "Destination FE"
label variable fe_imp_yr "Destination-Year FE"

*Create trade differences (using leading values).
foreach h of numlist 0 1 2 3 4 5 6 7 8 9 10 {

	qui gen D`h'ln_trade_val=F`h'.ln_trade_val-L.ln_trade_val 
	qui gen D`h'ln_quantity=F`h'.ln_quantity-L.ln_quantity 
	qui gen D`h'ln_tariff=F`h'.ln_ahs_st-L.ln_ahs_st 
	compress

}

*Merge with minor partner database.
merge 1:1 exporter importer hs6 nomen year using "./temp_files/partnerind.dta", keep(master matched)
drop _merge

*Replace values for minor partner classification.
replace minor_partner_agg=1 if minor_partner_agg==.
replace minor_partner_prod3=1 if minor_partner_prod3==.
replace minor_partner_prod4=1 if minor_partner_prod4==.
replace minor5_partner_agg=1 if minor5_partner_agg==.
replace minor5_partner_prod3=1 if minor5_partner_prod3==.
replace minor5_partner_prod4=1 if minor5_partner_prod4==.

*Save database.
save "./temp_files/data_int_all.dta", replace

/////////////////
///Winsorizing///
/////////////////

*Open database.
use "./temp_files/data_int_all.dta", clear

*Declare panel.
xtset panel_id year 

*Winsorize variables.
foreach h of numlist 0 1 2 3 4 5 6 7 8 9 10 {

	sum D`h'ln_trade_val, det
	local r99=r(p99)
	local r1=r(p1)
	replace D`h'ln_trade_val=`r99' if (D`h'ln_trade_val>`r99' & !missing(D`h'ln_trade_val))
	replace D`h'ln_trade_val=`r1' if (D`h'ln_trade_val<`r1' & !missing(D`h'ln_trade_val))

	sum D`h'ln_quantity, det
	local r99=r(p99)
	local r1=r(p1)
	replace D`h'ln_quantity=`r99' if (D`h'ln_quantity>`r99' & !missing(D`h'ln_quantity))
	replace D`h'ln_quantity=`r1' if (D`h'ln_quantity<`r1' & !missing(D`h'ln_quantity))

	sum D`h'ln_tariff if D`h'ln_tariff !=0, det
	local r99=r(p99)
	local r1=r(p1)
	replace D`h'ln_tariff=`r99' if (D`h'ln_tariff>`r99' & !missing(D`h'ln_tariff))
	replace D`h'ln_tariff=`r1' if (D`h'ln_tariff<`r1' & !missing(D`h'ln_tariff))

}
*Save database.
compress
save "./temp_files/data_int_all.dta", replace

/////////////////
///Instruments///
/////////////////

*Open database.
use "./temp_files/data_int_all.dta", clear

*Declare panel.
xtset panel_id year 

*Generate lags.
gen Lminor_partner_agg=L.minor_partner_agg
gen Lminor_partner_prod3=L.minor_partner_prod3
gen Lminor_partner_prod4=L.minor_partner_prod4
gen lmfn_binding =L.mfn_binding

*Baseline IV.

*Tariff change from period -1 to 0 for a non major trading partner in both -1 and 0 in terms of total trade and product value, when MFN is binding in both cases. 
gen iv_0_baseline=D0ln_tariff*minor_partner_agg*Lminor_partner_agg*minor_partner_prod4*Lminor_partner_prod4*mfn_binding*lmfn_binding

*Replace IV tariff with missing for partners where the MFN is the applied tariff but we think they are endogenous because of size.
gen temp=minor_partner_agg*Lminor_partner_agg*minor_partner_prod4*Lminor_partner_prod4
replace iv_0_baseline=. if (mfn_binding==1) & (lmfn_binding==1) & (temp==0)
drop temp

*Baseline IV with HS3 product partner.
gen iv_0_base_prod3=D0ln_tariff*minor_partner_agg*Lminor_partner_agg*minor_partner_prod3*Lminor_partner_prod3*mfn_binding*lmfn_binding

*Replace IV tariff with missing for partners where the MFN is the applied tariff but we think they are endogenous because of size.
gen temp=minor_partner_agg*Lminor_partner_agg*minor_partner_prod3*Lminor_partner_prod3
replace iv_0_base_prod3=. if (mfn_binding==1) & (lmfn_binding==1) & (temp==0)

*Drop variables.
drop temp Lminor_partner_agg Lminor_partner_prod3  Lminor_partner_prod4

*Robustness IV.

*Replace missing values.
replace minor5_partner_agg=0 if minor5_partner_agg==.
replace minor5_partner_prod3=0 if minor5_partner_prod3==.
replace minor5_partner_prod4=0 if minor5_partner_prod4==.

*Generate lags.
gen Lminor5_partner_agg=L.minor5_partner_agg
gen Lminor5_partner_prod3=L.minor5_partner_prod3
gen Lminor5_partner_prod4=L.minor5_partner_prod4

*Tariff change from period -1 to 0 for a non major top 5 trading partner in both -1 and 0 in terms of total trade and product value, when MFN is binding in both cases. 
gen iv_0_top5_prod3=D0ln_tariff*minor5_partner_agg*Lminor5_partner_agg*minor5_partner_prod3*Lminor5_partner_prod3*mfn_binding*lmfn_binding

*Replace IV tariff with missing for partners HS3 where the MFN is the applied tariff but we think they are endogenous because of size.
gen temp=minor5_partner_agg*Lminor5_partner_agg*minor5_partner_prod3*Lminor5_partner_prod3
replace iv_0_top5=. if (mfn_binding==1) & (lmfn_binding==1) & (temp==0)
drop temp

*Replace IV tariff with missing for partners HS4 where the MFN is the applied tariff but we think they are endogenous because of size.
gen iv_0_top5=D0ln_tariff*minor5_partner_agg*Lminor5_partner_agg*minor5_partner_prod4*Lminor5_partner_prod4*mfn_binding*lmfn_binding

*Replace IV tariff with missing for partners where the MFN is the applied tariff but we think they are endogenous because of size.
gen temp=minor5_partner_agg*Lminor5_partner_agg*minor5_partner_prod4*Lminor5_partner_prod4
replace iv_0_top5=. if (mfn_binding==1) & (lmfn_binding==1) & (temp==0)

*Drop variables.
drop temp Lminor5_partner_agg Lminor5_partner_prod3 Lminor5_partner_prod4 lmfn_binding

*Generate DiD instrument.
foreach h of numlist 0  {

	gen iv_`h'_did=D`h'ln_tariff*F`h'.mfn_binding*L.mfn_binding

}

*Save database.
compress
save "./temp_files/FillDataregW_all.dta", replace

*Erase files.
	erase "./temp_files/data_int_all.dta"
