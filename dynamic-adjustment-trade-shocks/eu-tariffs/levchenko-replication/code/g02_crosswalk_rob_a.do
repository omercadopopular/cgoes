clear all
set more off

mata
	mata mlib index
end

cap log close
log using "./output/logs/log_g02a.smcl", replace

//////////////
///Table B4///
//////////////

*Open database.
use "./temp_files/DataregW_did.dta",clear

*Declare panel.
xtset panel_id year

*Generate fixed effects.
egen long fe_imp_hs4 = group(importer hs4)
egen long fe_exp_hs4 = group(exporter hs4)

*Declare panel.
xtset panel_id year

	*Generate matrix to save results.
	matrix coefs = J(5,9,.)
	
	*Declare panel.
	xtset panel_id year

	*Log-levels, no FE.
	reg ln_trade_val ln_ahs_st, vce(cl fe_imp_exp_hs4) 
	gen sample_1 = e(sample)

	*Log-levels, multilateral FE.
	reghdfe ln_trade_val ln_ahs_st, ab(i.fe_imp_hs4_yr i.fe_exp_hs4_yr) cluster(fe_imp_exp_hs4)
	gen sample_2 = e(sample)
	
	*Log-levels, multilateral FE + bilateral FE.
	reghdfe ln_trade_val ln_ahs_st, ab(i.fe_imp_hs4_yr i.fe_exp_hs4_yr i.fe_imp_exp_hs4) cluster(fe_imp_exp_hs4)
	gen sample_3 = e(sample)
	
	*5-year log-differences, ``naive'' OLS.
	reghdfe D5ln_trade_val D5ln_tariff, ab(i.fe_imp_hs4_yr i.fe_exp_hs4_yr) cluster(fe_imp_exp_hs4)
	gen sample_4 = e(sample)
	
	*5-year local projection, initial tariffs, multilateral FE.
	ivreghdfe D5ln_trade_val (D5ln_tariff=D0ln_tariff), ab(i.fe_imp_hs4_yr i.fe_exp_hs4_yr) first cluster(fe_imp_exp_hs4)
	gen sample_5 = e(sample)
	
	*5-year log-differences, multilateral FE.
	ivreghdfe D5ln_trade_val (D5ln_tariff=iv_0_baseline), ab(i.fe_imp_hs4_yr i.fe_exp_hs4_yr) first cluster(fe_imp_exp_hs4)
	gen sample_6 = e(sample)
	
	*IV.
	ivreghdfe D5ln_trade_val (D5ln_tariff = iv_0_baseline), ab(i.fe_imp_hs4_yr i.fe_exp_hs4_yr i.fe_imp_exp_hs4) first cluster(fe_imp_exp_hs4) 
	gen sample_7 = e(sample)
	
	*IV.
	ivreghdfe D5ln_trade_val l1.D0ln_trade_val (D5ln_tariff l1.D0ln_tariff = iv_0_baseline l.iv_0_baseline), ab(i.fe_imp_hs4_yr i.fe_exp_hs4_yr i.fe_imp_exp_hs4) first cluster(fe_imp_exp_hs4) 
	gen sample_8 = e(sample)
	
	*10-year  log-differences, multilateral FE+bilateral FE.
	ivreghdfe D10ln_trade_val l1.D0ln_trade_val (D10ln_tariff l1.D0ln_tariff=iv_0_baseline l1.iv_0_baseline), ab(i.fe_imp_hs4_yr i.fe_exp_hs4_yr i.fe_imp_exp_hs4) first cluster(fe_imp_exp_hs4)
	gen sample_9 = e(sample)

*keep panel_id year ln_* D* iv* fe* sample_*
save "./temp_files/DataregW_did_sample.dta", replace



*Open database.
use "./temp_files/DataregW_did_sample.dta", clear

*Drop observations.
*keep if sample_1==1 & sample_2==1 & sample_3==1 & sample_4==1 & sample_5==1 & sample_6==1 & sample_7==1 & sample_8==1 & sample_9==1
gen sample=0
replace sample=1 if sample_1==1 & sample_2==1 & sample_3==1 & sample_4==1 & sample_5==1 & sample_6==1 & sample_7==1 & sample_8==1 & sample_9==1
save "./temp_files/DataregW_did_sample_.dta", replace

*Open database.
use "./temp_files/DataregW_did_sample_.dta", clear
xtset panel_id year

	*Generate matrix to save results.
	matrix coefs = J(5,9,.)
	
	*Declare panel.
	xtset panel_id year

	*Log-levels, no FE.
	reg ln_trade_val ln_ahs_st if sample==1, vce(cl fe_imp_exp_hs4) 
	matrix coefs[1,1]=_b[ln_ahs_st] 
	matrix coefs[2,1]=_se[ln_ahs_st] 
	matrix coefs[4,1]=e(r2) 
	matrix coefs[5,1]=e(N) 
	putexcel set "./output/tables/table_b4.xlsx", sheet("tableb4") modify 
	putexcel C4=matrix(coefs) 

	*Log-levels, multilateral FE.
	reghdfe ln_trade_val ln_ahs_st if sample==1, ab(i.fe_imp_hs4_yr i.fe_exp_hs4_yr) cluster(fe_imp_exp_hs4)
	matrix coefs[1,2]=_b[ln_ahs_st] 
	matrix coefs[2,2]=_se[ln_ahs_st] 
	matrix coefs[4,2]=e(r2) 
	matrix coefs[5,2]=e(N) 
	putexcel set "./output/tables/table_b4.xlsx", sheet("tableb4") modify 
	putexcel C4=matrix(coefs) 

	*Log-levels, multilateral FE + bilateral FE.
	reghdfe ln_trade_val ln_ahs_st if sample==1, ab(i.fe_imp_hs4_yr i.fe_exp_hs4_yr i.fe_imp_exp_hs4) cluster(fe_imp_exp_hs4)
	matrix coefs[1,3]=_b[ln_ahs_st] 
	matrix coefs[2,3]=_se[ln_ahs_st] 
	matrix coefs[4,3]=e(r2) 
	matrix coefs[5,3]=e(N) 
	putexcel set "./output/tables/table_b4.xlsx", sheet("tableb4") modify 
	putexcel C4=matrix(coefs) 
	
	*5-year log-differences, ``naive'' OLS.
	reghdfe D5ln_trade_val D5ln_tariff if sample==1, ab(i.fe_imp_hs4_yr i.fe_exp_hs4_yr) cluster(fe_imp_exp_hs4)
	matrix coefs[1,4]=_b[D5ln_tariff] 
	matrix coefs[2,4]=_se[D5ln_tariff] 
	matrix coefs[4,4]=e(r2) 
	matrix coefs[5,4]=e(N) 
	putexcel set "./output/tables/table_b4.xlsx", sheet("tableb4") modify 
	putexcel C4=matrix(coefs) 
	
	*5-year local projection, initial tariffs, multilateral FE.
	ivreghdfe D5ln_trade_val (D5ln_tariff=D0ln_tariff) if sample==1, ab(i.fe_imp_hs4_yr i.fe_exp_hs4_yr) first cluster(fe_imp_exp_hs4)
	matrix fstage=e(first)
	matrix coefs[1,5]=_b[D5ln_tariff] 
	matrix coefs[2,5]=_se[D5ln_tariff] 
	matrix coefs[3,5]=fstage[4,1]	
	matrix coefs[4,5]=e(r2) 
	matrix coefs[5,5]=e(N) 
	putexcel set "./output/tables/table_b4.xlsx", sheet("tableb4") modify 
	putexcel C4=matrix(coefs) 
	
	*5-year log-differences, multilateral FE.
	ivreghdfe D5ln_trade_val (D5ln_tariff=iv_0_baseline) if sample==1, ab(i.fe_imp_hs4_yr i.fe_exp_hs4_yr) first cluster(fe_imp_exp_hs4)
	matrix fstage=e(first)
	matrix coefs[1,6]=_b[D5ln_tariff] 
	matrix coefs[2,6]=_se[D5ln_tariff] 
	matrix coefs[3,6]=fstage[4,1]	
	matrix coefs[4,6]=e(r2) 
	matrix coefs[5,6]=e(N) 
	putexcel set "./output/tables/table_b4.xlsx", sheet("tableb4") modify 
	putexcel C4=matrix(coefs) 
	
	*IV.
	ivreghdfe D5ln_trade_val (D5ln_tariff = iv_0_baseline) if sample==1, ab(i.fe_imp_hs4_yr i.fe_exp_hs4_yr i.fe_imp_exp_hs4) first cluster(fe_imp_exp_hs4) 
	matrix fstage = e(first)
	matrix coefs[1,7] = _b[D5ln_tariff] 
	matrix coefs[2,7] = _se[D5ln_tariff] 
	matrix coefs[3,7] = fstage[4,1]
	matrix coefs[4,7] = e(r2) 
	matrix coefs[5,7] = e(N) 
	putexcel set "./output/tables/table_b4.xlsx", sheet("tableb4") modify 
	putexcel C4 = matrix(coefs)
	
	*IV.
	ivreghdfe D5ln_trade_val l1.D0ln_trade_val (D5ln_tariff l1.D0ln_tariff = iv_0_baseline l.iv_0_baseline) if sample==1, ab(i.fe_imp_hs4_yr i.fe_exp_hs4_yr i.fe_imp_exp_hs4) first cluster(fe_imp_exp_hs4) 
	matrix fstage = e(first)
	matrix coefs[1,8] = _b[D5ln_tariff] 
	matrix coefs[2,8] = _se[D5ln_tariff] 
	matrix coefs[3,8] = fstage[4,1]
	matrix coefs[4,8] = e(r2) 
	matrix coefs[5,8] = e(N) 
	putexcel set "./output/tables/table_b4.xlsx", sheet("tableb4") modify 
	putexcel C4 = matrix(coefs)
	
	*10-year  log-differences, multilateral FE+bilateral FE.
	ivreghdfe D10ln_trade_val l1.D0ln_trade_val (D10ln_tariff l1.D0ln_tariff=iv_0_baseline l1.iv_0_baseline) if sample==1, ab(i.fe_imp_hs4_yr i.fe_exp_hs4_yr i.fe_imp_exp_hs4) first cluster(fe_imp_exp_hs4)
	matrix fstage=e(first)
	matrix coefs[1,9]=_b[D10ln_tariff] 
	matrix coefs[2,9]=_se[D10ln_tariff] 
	matrix coefs[3,9]=fstage[4,1]
	matrix coefs[4,9]=e(r2) 
	matrix coefs[5,9]=e(N) 
	putexcel set "./output/tables/table_b4.xlsx", sheet("tableb4") modify 
	putexcel C4=matrix(coefs) 
	
log close
