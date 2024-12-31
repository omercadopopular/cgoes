clear all
set more off

mata
	mata mlib index
end

cap log close
log using "./output/logs/log_g01b.smcl", replace

*Open database.
use "./temp_files/DataregW_did.dta",clear

*Define differences.
local diff 5

/////////////
///Table 2///
/////////////

*Generate matrix to store results.
matrix coefs=J(5,6,.)

*No bilateral.
reghdfe ln_trade_val ln_ahs_st, ab(i.fe_imp_hs4_yr i.fe_exp_hs4_yr) cluster(fe_imp_exp_hs4)
matrix coefs[1,1]=_b[ln_ahs_st] 
matrix coefs[2,1]=_se[ln_ahs_st] 
matrix coefs[4,1]=e(r2) 
matrix coefs[5,1]=e(N) 
putexcel set "./output/tables/table_2.xlsx", sheet("table2") modify 
putexcel C4=matrix(coefs) 

*Gravity variables.
gen ln_dist=ln(dist)
reghdfe ln_trade_val ln_ahs_st ln_dist i.contig i.comlang_off i.colony, ab(i.fe_imp_hs4_yr i.fe_exp_hs4_yr) cluster(fe_imp_exp_hs4)
matrix coefs[1,2]=_b[ln_ahs_st] 
matrix coefs[2,2]=_se[ln_ahs_st] 
matrix coefs[4,2]=e(r2) 
matrix coefs[5,2]=e(N) 
putexcel set "./output/tables/table_2.xlsx", sheet("table2") modify 
putexcel C4=matrix(coefs) 

*Country-pair.
reghdfe ln_trade_val ln_ahs_st, ab(i.fe_imp_hs4_yr i.fe_exp_hs4_yr i.fe_imp_exp) cluster(fe_imp_exp_hs4)
matrix coefs[1,3]=_b[ln_ahs_st] 
matrix coefs[2,3]=_se[ln_ahs_st] 
matrix coefs[4,3]=e(r2) 
matrix coefs[5,3]=e(N) 
putexcel set "./output/tables/table_2.xlsx", sheet("table2") modify 
putexcel C4=matrix(coefs) 

*Country-pair x HS2.
reghdfe ln_trade_val ln_ahs_st, ab(i.fe_imp_hs4_yr i.fe_exp_hs4_yr i.fe_imp_exp_hs2) cluster(fe_imp_exp_hs2)
matrix coefs[1,4]=_b[ln_ahs_st] 
matrix coefs[2,4]=_se[ln_ahs_st] 
matrix coefs[4,4]=e(r2) 
matrix coefs[5,4]=e(N) 
putexcel set "./output/tables/table_2.xlsx", sheet("table2") modify 
putexcel C4=matrix(coefs) 

*Country-pair x HS3.
reghdfe ln_trade_val ln_ahs_st, ab(i.fe_imp_hs4_yr i.fe_exp_hs4_yr i.fe_imp_exp_hs3) cluster(fe_imp_exp_hs3)
matrix coefs[1,5]=_b[ln_ahs_st] 
matrix coefs[2,5]=_se[ln_ahs_st] 
matrix coefs[4,5]=e(r2) 
matrix coefs[5,5]=e(N) 
putexcel set "./output/tables/table_2.xlsx", sheet("table2") modify 
putexcel C4=matrix(coefs) 

*Country-pair x HS4.
reghdfe ln_trade_val ln_ahs_st, ab(i.fe_imp_hs4_yr i.fe_exp_hs4_yr i.fe_imp_exp_hs4) cluster(fe_imp_exp_hs4)
matrix coefs[1,6]=_b[ln_ahs_st] 
matrix coefs[2,6]=_se[ln_ahs_st] 
matrix coefs[4,6]=e(r2) 
matrix coefs[5,6]=e(N) 
putexcel set "./output/tables/table_2.xlsx", sheet("table2") modify 
putexcel C4=matrix(coefs) 

log close
