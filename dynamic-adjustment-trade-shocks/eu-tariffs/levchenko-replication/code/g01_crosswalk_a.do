clear all
set more off

mata
	mata mlib index
end

cap log close
log using "./output/logs/log_g01a.smcl", replace

/////////////
///Table 1///
/////////////

*Open database.
use "./temp_files/DataregW_did.dta",clear

*Declare panel.
xtset panel_id year

*Define differences.
local diff 5

*Generate matrix to store results.
matrix coefs=J(5,8,.)

*Log-levels, no FE.
reg ln_trade_val ln_ahs_st, vce(cl fe_imp_exp_hs4) 
matrix coefs[1,1]=_b[ln_ahs_st] 
matrix coefs[2,1]=_se[ln_ahs_st] 
matrix coefs[4,1]=e(r2) 
matrix coefs[5,1]=e(N) 
putexcel set "./output/tables/table_1.xlsx", sheet("table1") modify 
putexcel C4=matrix(coefs) 

*Log-levels, multilateral FE.
reghdfe ln_trade_val ln_ahs_st, ab(i.fe_imp_hs4_yr i.fe_exp_hs4_yr) cluster(fe_imp_exp_hs4)
matrix coefs[1,2]=_b[ln_ahs_st] 
matrix coefs[2,2]=_se[ln_ahs_st] 
matrix coefs[4,2]=e(r2) 
matrix coefs[5,2]=e(N) 
putexcel set "./output/tables/table_1.xlsx", sheet("table1") modify 
putexcel C4=matrix(coefs) 

*Log-levels, multilateral FE + bilateral FE.
reghdfe ln_trade_val ln_ahs_st, ab(i.fe_imp_hs4_yr i.fe_exp_hs4_yr i.fe_imp_exp_hs4) cluster(fe_imp_exp_hs4)
matrix coefs[1,3]=_b[ln_ahs_st] 
matrix coefs[2,3]=_se[ln_ahs_st] 
matrix coefs[4,3]=e(r2) 
matrix coefs[5,3]=e(N) 
putexcel set "./output/tables/table_1.xlsx", sheet("table1") modify 
putexcel C4=matrix(coefs) 

*5-year log-differences, ``naive'' OLS.
reghdfe D`diff'ln_trade_val D`diff'ln_tariff, ab(i.fe_imp_hs4_yr i.fe_exp_hs4_yr) cluster(fe_imp_exp_hs4)
matrix coefs[1,4]=_b[D`diff'ln_tariff] 
matrix coefs[2,4]=_se[D`diff'ln_tariff] 
matrix coefs[4,4]=e(r2) 
matrix coefs[5,4]=e(N) 
putexcel set "./output/tables/table_1.xlsx", sheet("table1") modify 
putexcel C4=matrix(coefs) 

*5-year local projection, initial tariffs, multilateral FE.
ivreghdfe D`diff'ln_trade_val (D`diff'ln_tariff=D0ln_tariff), ab(i.fe_imp_hs4_yr i.fe_exp_hs4_yr) first cluster(fe_imp_exp_hs4)
matrix fstage=e(first)
matrix coefs[1,5]=_b[D`diff'ln_tariff] 
matrix coefs[2,5]=_se[D`diff'ln_tariff] 
matrix coefs[3,5]=fstage[4,1]	
matrix coefs[4,5]=e(r2) 
matrix coefs[5,5]=e(N) 
putexcel set "./output/tables/table_1.xlsx", sheet("table1") modify 
putexcel C4=matrix(coefs) 

*5-year log-differences, multilateral FE.
ivreghdfe D`diff'ln_trade_val (D`diff'ln_tariff=iv_0_baseline), ab(i.fe_imp_hs4_yr i.fe_exp_hs4_yr) first cluster(fe_imp_exp_hs4)
matrix fstage=e(first)
matrix coefs[1,6]=_b[D`diff'ln_tariff] 
matrix coefs[2,6]=_se[D`diff'ln_tariff] 
matrix coefs[3,6]=fstage[4,1]	
matrix coefs[4,6]=e(r2) 
matrix coefs[5,6]=e(N) 
putexcel set "./output/tables/table_1.xlsx", sheet("table1") modify 
putexcel C4=matrix(coefs) 
	
*IV.
ivreghdfe D`diff'ln_trade_val l1.D0ln_trade_val (D`diff'ln_tariff l1.D0ln_tariff = iv_0_baseline l.iv_0_baseline), ab(i.fe_imp_hs4_yr i.fe_exp_hs4_yr i.fe_imp_exp_hs4) first cluster(fe_imp_exp_hs4) 
matrix fstage = e(first)
matrix coefs[1,7] = _b[D`diff'ln_tariff] 
matrix coefs[2,7] = _se[D`diff'ln_tariff] 
matrix coefs[3,7] = fstage[4,1]
matrix coefs[4,7] = e(r2) 
matrix coefs[5,7] = e(N) 
putexcel set "./output/tables/table_1.xlsx", sheet("table1") modify 
putexcel C4 = matrix(coefs)

*10-year  log-differences, multilateral FE+bilateral FE.
ivreghdfe D10ln_trade_val l1.D0ln_trade_val (D10ln_tariff l1.D0ln_tariff=iv_0_baseline l1.iv_0_baseline), ab(i.fe_imp_hs4_yr i.fe_exp_hs4_yr i.fe_imp_exp_hs4) first cluster(fe_imp_exp_hs4)
matrix fstage=e(first)
matrix coefs[1,8]=_b[D10ln_tariff] 
matrix coefs[2,8]=_se[D10ln_tariff] 
matrix coefs[3,8]=fstage[4,1]
matrix coefs[4,8]=e(r2) 
matrix coefs[5,8]=e(N) 
putexcel set "./output/tables/table_1.xlsx", sheet("table1") modify 
putexcel C4=matrix(coefs) 

log close
