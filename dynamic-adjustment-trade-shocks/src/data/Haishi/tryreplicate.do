set more off                        /* tells Stata not to pause after each step of calculation */
clear                               /* clears current memory */
* replace this with the right path
global ROOT = "data/Haishi/share with marc"

global work_dir = "$ROOT/work folder"

global raw_dir = "$ROOT/raw data"

**********************************************************************************************
* "committee_formation_withtaxes_openingyear_all_countries_correct_ncm.dta" contains AD investigation level information
* i_iso: importing/investigating country
* e_iso: exporting/investigated country
* co_ano: year 
* co_ncm: product, defined by current HS code 
* nn_committe: number of investigating committee over the past 5 years on importer-exporter-product level (control for trade policy uncertainty)
* n_committe: number of investigating committee that ruled positive over the past 5 years on importer-exporter-product level (control for trade policy uncertainty)
* dumping_tariff: year 0 (investigation start year) AD tariff 
* date_opening_committee: date investigation is opened 
* REVOKE_DATE: date AD tariff is revoked. if this information is missing but a AD tariff is imposed, set it to 5 years after investigation beginning
**********************************************************************************************
use  "$raw_dir/committee_formation_withtaxes_openingyear_all_countries_correct_ncm.dta", clear

keep if co_ano >= 1995

duplicates drop
* get the first investigation on importer-exporter-product level to conduct event studies
bys e_iso i_iso co_ncm: egen min_year = min(co_ano)

keep if min_year == co_ano

rename co_ano year_treatment

save "$work_dir/tariff_product_allcountries.dta", replace

**********************************************************************************************
* "imports_open_committee_all_countries.dta": trade data for all investigated products among importing-exporting country pairs. Data is made a balanced panel.
* co_ncm_h0: HS88/92 6-digit product code
* v: trade value
* q: trade quantity/volume
* after: dummy that equals 1 if year (co_ano) is after the first AD investigation
**********************************************************************************************
use "$raw_dir/imports_open_committee_all_countries_v0.dta", replace
**********************************************************************************************
* merge witth tariff data
* committee_n_productlvl_openingyear_allcountries_correct_ncm.dta" contains importer-exporter-product level tariff information
* dumping_tariff: importer-exporter-product level tariff for the current year (rather than year 0)
**********************************************************************************************
merge m:1 e_iso i_iso co_ncm co_ano using   "$raw_dir/committee_n_productlvl_openingyear_allcountries_correct_ncm.dta", keepusing(dumping_tariff nn_committe)

drop _merge

rename dumping_tariff dumping_tariff_real

merge m:1 e_iso i_iso co_ncm using "$work_dir/tariff_product_allcountries.dta", keepusing(dumping_tariff n_committe *_treatment)

drop _merge

drop if v == .

gen ever_treated = n_committe>0

drop if (ever_treated == 1)&(mi(dumping_tariff))

* drop if (ever_treated == 1)&(dumping_tariff == 0)

replace dumping_tariff = 0 if (ever_treated == 0)

replace dumping_tariff = 0 if (dumping_tariff ==.)
sort co_ncm i_iso co_ano

gen date_id = .
local j = 0

forval year = 1989/2021 {

	local j = `j' + 1
	
	replace date_id = `j' if (co_ano == `year')

}

gen date_treatment = date_id if (co_ano == year_treatment)

bys co_ncm e_iso i_iso: egen temp = min(date_treatment)

replace date_treatment = temp

drop temp

bys co_ncm e_iso i_iso: egen temp = max(dumping_tariff)

replace dumping_tariff = temp

drop temp

* time distance to committee formation
gen dist_time_committee 	   = date_id - date_treatment  

* generate FEs
egen prod_ori_dest_FE = group(co_ncm_h0  e_iso i_iso)

egen prod_ori_time_FE = group(co_ncm_h0  co_ano e_iso )

egen prod_dest_time_FE = group(co_ncm_h0 co_ncm co_ano i_iso)

egen time_sector_FE = group(co_ano co_ncm_h0)

egen ori_dest_time_FE = group( i_iso e_iso co_ano)

egen ori_time_FE = group(i_iso co_ano)

egen dest_time_FE = group(e_iso co_ano)

egen prod_time_FE = group(co_ncm_h0 co_ano)

egen ori_dest_FE = group(i_iso e_iso)

egen prod_ori_FE = group(co_ncm_h0 e_iso )

egen prod_dest_FE = group(co_ncm_h0 i_iso )

rename v value

* select by number of observations
bys prod_ori_dest_FE: egen max_dist = max(dist)
bys prod_ori_dest_FE: egen min_dist = min(dist)
 
**********************************************************************************************
* Figures - Diff-in-DIff
**********************************************************************************************
* total imports
g log_vl_fob = log(1e-6 + value)

g log_q = log(1e-6 + q)

replace log_q = . if value > 0 & q == 0

g log_p = log_vl_fob - log_q

winsor2 value, cuts(0 95)  by(  ever_treated)

replace value = value_w if ever_treated == 0

drop value_w

winsor2 value, cuts(0 95)  by(  dist_time_committee)

replace value = value_w if after == 1

drop value_w

gen value_pre1				= value if (date_treatment == date_id - 1)
bys co_ncm_h0 co_ncm e_iso i_iso : egen temp = sum(value_pre1)
replace value_pre1		= temp
drop temp
gen log_value_pre1 		= log(value_pre1)

gen value_pre10			= value if (date_treatment == date_id - 10)
bys co_ncm_h0 co_ncm e_iso i_iso : egen temp = sum(value_pre10)
replace value_pre10		= temp
drop temp
gen log_value_pre10		= log(value_pre10)

gen value_pre5		= value if (date_treatment == date_id - 5)
bys co_ncm_h0 co_ncm e_iso i_iso : egen temp = sum(value_pre5)
replace value_pre5		= temp
drop temp
gen log_value_pre5		= log(value_pre5)

gen value_pre4		= value if (date_treatment == date_id - 4)
bys co_ncm_h0 co_ncm e_iso i_iso : egen temp = sum(value_pre4)
replace value_pre4	= temp
drop temp
gen log_value_pre4		= log(value_pre4)

g asinhv = asinh(value)

save "$work_dir/balanced_panel_did", replace


* compute tariff statistics
use "$work_dir/balanced_panel_did", replace

replace after = 0 if after == .

replace nn_committe = 0 if nn_committe == .

replace  dumping_tariff_real = 0 if  dumping_tariff_real == .

replace dumping_tariff_real = log(dumping_tariff_real + 1)

keep if max_dist > 1 & min_dist <-7

su dumping_tariff_real if dumping_tariff_real > 0, de

g large = (dumping_tariff_real > r(p90))

tab large 

su dumping_tariff_real if dumping_tariff_real > 0, de

g mediumlarge = (dumping_tariff_real > r(p75))

tab mediumlarge 

su dumping_tariff_real if dumping_tariff_real > 0, de

g verylarge = (dumping_tariff_real > r(p95))

tab verylarge 

egen p1 = pctile(dumping_tariff_real), p(90)

*replace dumping_tariff_real = p1 if (dumping_tariff_real > p1)

drop p1

drop if nn_committe == 0 & dist_time > 0

keep if dist_time == 0

keep e_iso i_iso co_ncm   dumping_tariff_real  large mediumlarge verylarge

rename dumping_tariff_real  dumping_tariff 

duplicates drop

save "$work_dir/tariff_product_allcountries_update.dta", replace



use "$work_dir/balanced_panel_did", replace

replace after = 0 if after == .

replace nn_committe = 0 if nn_committe == .

replace  dumping_tariff_real = 0 if  dumping_tariff_real == .

replace dumping_tariff_real = log(dumping_tariff_real + 1)
**********************************************************************************************
* keep the investigations that have more than 7 years in the pre-period and more than 1 year in the post period
**********************************************************************************************
keep if max_dist > 1 & min_dist <-7

egen p1 = pctile(dumping_tariff_real), p(90)

* replace dumping_tariff_real = p1 if (dumping_tariff_real > p1)

drop p1

drop if nn_committe == 0 & dist_time > 0

rename  dumping_tariff dumping_tariff_1

merge m:1 e_iso i_iso co_ncm using "$work_dir/tariff_product_allcountries_update.dta", keepusing(dumping_tariff large mediumlarge verylarge )
* create dummies for pre and post treatment
* use year 0 tariff as the event study tariff
forval i = 0/24 {

	cap gen I_comt_bfr_trt_`i' = 0
	replace I_comt_bfr_trt_`i' = dumping_tariff if (dist_time_committee == -`i')&(ever_treated == 1)

} 

forval i = 0/28 {

	cap gen I_comt_aft_trt_`i' = 0
	replace I_comt_aft_trt_`i' = dumping_tariff if (dist_time_committee == `i')&(ever_treated == 1)

}

cap gen I_comt_bfr_trt = 0

replace I_comt_bfr_trt = dumping_tariff if (dist_time_committee < -1)&(ever_treated == 1)
* short run: year 0-1
cap gen I_comt_aft_trt_sr = 0

replace I_comt_aft_trt_sr = dumping_tariff if (dist_time_committee >=0 & dist_time_committee<=1 )&(ever_treated == 1)
* long run: year 2-5. AD tariffs last at most 5 years before reevaluation
cap gen I_comt_aft_trt_lr = 0

replace I_comt_aft_trt_lr = dumping_tariff if (dist_time_committee >=2 )&(ever_treated == 1)

**********************************************************************************************
* merge HS6 products to OECD 2-digit sectors. The goal is to get sector-specific trade elasticities. see DHLM "Trade War and Peace"
**********************************************************************************************
joinby co_ncm_h0 using "$raw_dir/h0_2_i3"

joinby isic3 using "$raw_dir/i3_2_i31"

joinby isic31 using "$raw_dir/i31_2_i4"

g i_2d = substr(isic4,1,2)

destring i_2d, replace

g oecd_sector = 23

replace oecd_sector = 1 if i_2d >=1 & i_2d <=2

replace oecd_sector = 2 if i_2d == 3

replace oecd_sector = 3 if i_2d >=4 & i_2d <=6

replace oecd_sector = 4 if i_2d >=7 & i_2d <=8

replace oecd_sector = 5 if i_2d == 9

replace oecd_sector = 6 if i_2d >=10 & i_2d <=12

replace oecd_sector = 7 if i_2d >=13 & i_2d <=15

replace oecd_sector = 8 if i_2d >=16 & i_2d <=16

replace oecd_sector = 9 if i_2d >=17 & i_2d <=18

replace oecd_sector = 10 if i_2d >=19 & i_2d <=19

replace oecd_sector = 11 if i_2d >=20 & i_2d <=20

replace oecd_sector = 12 if i_2d >=21 & i_2d <=21

replace oecd_sector = 13 if i_2d >=22 & i_2d <=22

replace oecd_sector = 14 if i_2d >=23 & i_2d <=23

replace oecd_sector = 15 if i_2d >=24 & i_2d <=24

replace oecd_sector = 16 if i_2d >=25 & i_2d <=25

replace oecd_sector = 17 if i_2d >=26 & i_2d <=26

replace oecd_sector = 18 if i_2d >=27 & i_2d <=27

replace oecd_sector = 19 if i_2d >=28 & i_2d <=28

replace oecd_sector = 20 if i_2d >=29 & i_2d <=29

replace oecd_sector = 21 if i_2d >=30 & i_2d <=30

replace oecd_sector = 22 if i_2d >=31 & i_2d <=33

g oecd_broad = oecd_sector

replace oecd_broad = 2 if oecd_sector == 2 | oecd_sector == 7

replace oecd_broad = 3 if oecd_sector == 3 | oecd_sector == 4 | oecd_sector == 5 | oecd_sector ==10

* average effect
reghdfe log_vl_fob dumping_tariff_real, absorb(prod_time_FE prod_ori_FE prod_dest_FE ori_time_FE  dest_time_FE  dist_ )  vce(cluster prod_ori_dest_FE) nocons
* pre, short-run, long-run
capture noisily reghdfe log_vl_fob I_comt_bfr_trt I_comt_aft_trt_sr I_comt_aft_trt_lr, absorb(prod_time_FE prod_ori_FE prod_dest_FE ori_dest_time_FE nn_committe n_committe dist_ )  vce(cluster prod_ori_dest_FE) nocons
* sector-specific trade elasticities
capture noisily reghdfe log_vl_fob i.oecd_broad#c.dumping_tariff_real, absorb(prod_time_FE prod_ori_FE prod_dest_FE ori_time_FE  dest_time_FE nn_committe n_committe dist_ )  vce(cluster prod_ori_dest_FE) nocons

* sector-specific short-run/long-run trade elasticities
capture noisily reghdfe log_vl_fob i.oecd_broad#c.I_comt_bfr_trt i.oecd_broad#c.I_comt_aft_trt_sr i.oecd_broad#c.I_comt_aft_trt_lr, absorb(prod_time_FE prod_ori_FE prod_dest_FE ori_time_FE  dest_time_FE nn_committe n_committe dist_ )  vce(cluster prod_ori_dest_FE) nocons

* make event study figures
**********************************************************************************************
* AD tariffs last 5 years before reevaluation, so event study figures are plotted at most 5 years
**********************************************************************************************
* value
global var_interest = "log_vl_fob"
global ytitle 		= "log(Imports)"

save "$work_dir/replicate.dta", replace

timer clear
timer on 1
reghdfe $var_interest I_comt_bfr_trt_2-I_comt_bfr_trt_24 I_comt_aft_trt_0-I_comt_aft_trt_28 , absorb(prod_time_FE prod_ori_FE prod_dest_FE ori_time_FE  dest_time_FE dist_ ) vce(cluster prod_ori_dest_FE)
* 
timer off 1
timer list

/*
reghdfe $var_interest I_comt_bfr_trt_2-I_comt_bfr_trt_24 I_comt_aft_trt_0-I_comt_aft_trt_18 , absorb(prod_time_FE prod_ori_FE prod_dest_FE ori_time_FE  dest_time_FE dist_ ) vce(cluster prod_ori_dest_FE)
*/

reghdfe $var_interest I_comt_bfr_trt_2-I_comt_bfr_trt_24 I_comt_aft_trt_0-I_comt_aft_trt_28 if dumping_tariff<1, absorb(prod_time_FE prod_ori_FE prod_dest_FE ori_time_FE  dest_time_FE dist_ ) vce(cluster prod_ori_dest_FE)
