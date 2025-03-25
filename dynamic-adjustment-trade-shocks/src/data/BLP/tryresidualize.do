global work "data/work/BLP"

adopath + "/u/main/tradeadj/muendler-estimation/ado/"

use $work/data_horz1.dta, clear
merge 1:1 panel_id year using $work/data_lag.dta, nogen

local fe fe_imp_hs4_yr fe_exp_hs4_yr fe_imp_exp_hs4

timer clear
timer on 1
reghdfe D1ln_trade_val,  a(`fe') residuals(rD1ln_trade_val)
reghdfe D1ln_tariff,  a(`fe') residuals(rD1ln_tariff)
timer off 1

timer list
