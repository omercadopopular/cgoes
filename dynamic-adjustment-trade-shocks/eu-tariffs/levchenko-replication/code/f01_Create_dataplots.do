clear all
set more off

//////////////
///Figure 1///
//////////////

*Tariffs, no pretrend controls.
clear
set obs 17
seq horizon, f(-6) t(10)
merge 1:1 horizon using "./output/temp_files/iv_0_baseline_lp_tariffs_pre.dta", nogen update
merge 1:1 horizon using "./output/temp_files/iv_0_baseline_lp_tariffs.dta", nogen update
sort horizon
gen ci=1.96*se
replace b=1 if horizon==0
export excel using "./output/graphs/temp_files/fig_1.xls", firstrow(variables) sheet("tariffs_nopre", modify)

*Tariffs, pretrend controls.
clear
set obs 17
seq horizon, f(-6) t(10)
merge 1:1 horizon using "./output/temp_files/iv_0_baseline_lp_tariffs_pre_l1.dta", nogen update
merge 1:1 horizon using "./output/temp_files/iv_0_baseline_lp_tariffs_l1.dta", nogen update
sort horizon
gen ci=1.96*se
replace b=1 if horizon==0
export excel using "./output/graphs/temp_files/fig_1.xls", firstrow(variables) sheet("tariffs_pre", modify)

*Trade, no pretrend controls.
clear
set obs 17
seq horizon, f(-6) t(10)
merge 1:1 horizon using "./output/temp_files/iv_0_baseline_lp_ln_trade_val_pre.dta", nogen update
merge 1:1 horizon using "./output/temp_files/iv_0_baseline_lp_ln_trade_val.dta", nogen update
sort horizon
gen ci=1.96*se
export excel using "./output/graphs/temp_files/fig_1.xls", firstrow(variables) sheet("ln_trade_val_nopre", modify)

*Trade, pretrend controls.
clear
set obs 17
seq horizon, f(-6) t(10)
merge 1:1 horizon using "./output/temp_files/iv_0_baseline_lp_ln_trade_val_pre_l1.dta", nogen update
merge 1:1 horizon using "./output/temp_files/iv_0_baseline_lp_ln_trade_val_l1.dta", nogen update
sort horizon
gen ci=1.96*se
export excel using "./output/graphs/temp_files/fig_1.xls", firstrow(variables) sheet("ln_trade_val_pre", modify)

//////////////
///Figure 2///
//////////////

*Baseline.
clear
set obs 11
seq horizon, f(0) t(10)
merge 1:1 horizon using "./output/temp_files/iv_0_baseline_elasticity_ln_trade_val_l1.dta", nogen update
sort horizon
gen ci=1.96*se
export excel using "./output/graphs/temp_files/fig_2.xls", firstrow(variables) sheet("baseline", modify)

*All data / all tariffs.
clear
set obs 11
seq horizon, f(0) t(10)
merge 1:1 horizon using "./output/temp_files/OLS_ln_trade_val_lags1.dta", nogen update
sort horizon
gen ci=1.96*se
export excel using "./output/graphs/temp_files/fig_2.xls", firstrow(variables) sheet("all", modify)

//////////////
///Figure 3///
//////////////

*Section 1.
clear
set obs 11
seq horizon, f(0) t(10)
merge 1:1 horizon using "./output/temp_files/iv_0_baseline_section1_lags1.dta", nogen update
sort horizon
gen ci=1.96*se
export excel using "./output/graphs/temp_files/fig_3.xls", firstrow(variables) sheet("iv_0_baseline_section1l1", modify)

*Section 2.
clear
set obs 11
seq horizon, f(0) t(10)
merge 1:1 horizon using "./output/temp_files/iv_0_baseline_section2_lags1.dta", nogen update
sort horizon
gen ci=1.96*se
export excel using "./output/graphs/temp_files/fig_3.xls", firstrow(variables) sheet("iv_0_baseline_section2l1", modify)

*Section 3.
clear
set obs 11
seq horizon, f(0) t(10)
merge 1:1 horizon using "./output/temp_files/iv_0_baseline_section3_lags1.dta", nogen update
sort horizon
gen ci=1.96*se
export excel using "./output/graphs/temp_files/fig_3.xls", firstrow(variables) sheet("iv_0_baseline_section3l1", modify)

*Section 4.
clear
set obs 11
seq horizon, f(0) t(10)
merge 1:1 horizon using "./output/temp_files/iv_0_baseline_section4_lags1.dta", nogen update
sort horizon
gen ci=1.96*se
export excel using "./output/graphs/temp_files/fig_3.xls", firstrow(variables) sheet("iv_0_baseline_section4l1", modify)

*Section 5.
clear
set obs 11
seq horizon, f(0) t(10)
merge 1:1 horizon using "./output/temp_files/iv_0_baseline_section5_lags1.dta", nogen update
sort horizon
gen ci=1.96*se
export excel using "./output/graphs/temp_files/fig_3.xls", firstrow(variables) sheet("iv_0_baseline_section5l1", modify)

*Section 6.
clear
set obs 11
seq horizon, f(0) t(10)
merge 1:1 horizon using "./output/temp_files/iv_0_baseline_section6_lags1.dta", nogen update
sort horizon
gen ci=1.96*se
export excel using "./output/graphs/temp_files/fig_3.xls", firstrow(variables) sheet("iv_0_baseline_section6l1", modify)

*Section 7.
clear
set obs 11
seq horizon, f(0) t(10)
merge 1:1 horizon using "./output/temp_files/iv_0_baseline_section7_lags1.dta", nogen update
sort horizon
gen ci=1.96*se
export excel using "./output/graphs/temp_files/fig_3.xls", firstrow(variables) sheet("iv_0_baseline_section7l1", modify)

*Section 8.
clear
set obs 11
seq horizon, f(0) t(10)
merge 1:1 horizon using "./output/temp_files/iv_0_baseline_section8_lags1.dta", nogen update
sort horizon
gen ci=1.96*se
export excel using "./output/graphs/temp_files/fig_3.xls", firstrow(variables) sheet("iv_0_baseline_section8l1", modify)

*Section 9.
clear
set obs 11
seq horizon, f(0) t(10)
merge 1:1 horizon using "./output/temp_files/iv_0_baseline_section9_lags1.dta", nogen update
sort horizon
gen ci=1.96*se
export excel using "./output/graphs/temp_files/fig_3.xls", firstrow(variables) sheet("iv_0_baseline_section9l1", modify)

*Section 10.
clear
set obs 11
seq horizon, f(0) t(10)
merge 1:1 horizon using "./output/temp_files/iv_0_baseline_section10_lags1.dta", nogen update
sort horizon
gen ci=1.96*se
export excel using "./output/graphs/temp_files/fig_3.xls", firstrow(variables) sheet("iv_0_baseline_section10l1", modify)

*Section 11.
clear
set obs 11
seq horizon, f(0) t(10)
merge 1:1 horizon using "./output/temp_files/iv_0_baseline_section11_lags1.dta", nogen update
sort horizon
gen ci=1.96*se
export excel using "./output/graphs/temp_files/fig_3.xls", firstrow(variables) sheet("iv_0_baseline_section11l1", modify)

*Section 12.
clear
set obs 11
seq horizon, f(0) t(10)
merge 1:1 horizon using "./output/temp_files/iv_0_baseline_section12_lags1.dta", nogen update
sort horizon
gen ci=1.96*se
export excel using "./output/graphs/temp_files/fig_3.xls", firstrow(variables) sheet("iv_0_baseline_section12l1", modify)

*Section 13.
clear
set obs 11
seq horizon, f(0) t(10)
merge 1:1 horizon using "./output/temp_files/iv_0_baseline_section13_lags1.dta", nogen update
sort horizon
gen ci=1.96*se
export excel using "./output/graphs/temp_files/fig_3.xls", firstrow(variables) sheet("iv_0_baseline_section13l1", modify)

*Section 14.
clear
set obs 11
seq horizon, f(0) t(10)
merge 1:1 horizon using "./output/temp_files/iv_0_baseline_section14_lags1.dta", nogen update
sort horizon
gen ci=1.96*se
export excel using "./output/graphs/temp_files/fig_3.xls", firstrow(variables) sheet("iv_0_baseline_section14l1", modify)

*Section 15.
clear
set obs 11
seq horizon, f(0) t(10)
merge 1:1 horizon using "./output/temp_files/iv_0_baseline_section15_lags1.dta", nogen update
sort horizon
gen ci=1.96*se
export excel using "./output/graphs/temp_files/fig_3.xls", firstrow(variables) sheet("iv_0_baseline_section15l1", modify)

*Section 16.
clear
set obs 11
seq horizon, f(0) t(10)
merge 1:1 horizon using "./output/temp_files/iv_0_baseline_section16_lags1.dta", nogen update
sort horizon
gen ci=1.96*se
export excel using "./output/graphs/temp_files/fig_3.xls", firstrow(variables) sheet("iv_0_baseline_section16l1", modify)

*Section 17.
clear
set obs 11
seq horizon, f(0) t(10)
merge 1:1 horizon using "./output/temp_files/iv_0_baseline_section17_lags1.dta", nogen update
sort horizon
gen ci=1.96*se
export excel using "./output/graphs/temp_files/fig_3.xls", firstrow(variables) sheet("iv_0_baseline_section17l1", modify)

*Section 18.
clear
set obs 11
seq horizon, f(0) t(10)
merge 1:1 horizon using "./output/temp_files/iv_0_baseline_section18_lags1.dta", nogen update
sort horizon
gen ci=1.96*se
export excel using "./output/graphs/temp_files/fig_3.xls", firstrow(variables) sheet("iv_0_baseline_section18l1", modify)

*Section 19.
clear
set obs 11
seq horizon, f(0) t(10)
merge 1:1 horizon using "./output/temp_files/iv_0_baseline_section19_lags1.dta", nogen update
sort horizon
gen ci=1.96*se
export excel using "./output/graphs/temp_files/fig_3.xls", firstrow(variables) sheet("iv_0_baseline_section19l1", modify)

*Section 20.
clear
set obs 11
seq horizon, f(0) t(10)
merge 1:1 horizon using "./output/temp_files/iv_0_baseline_section20_lags1.dta", nogen update
sort horizon
gen ci=1.96*se
export excel using "./output/graphs/temp_files/fig_3.xls", firstrow(variables) sheet("iv_0_baseline_section20l1", modify)

*Section 21.
clear
set obs 11
seq horizon, f(0) t(10)
merge 1:1 horizon using "./output/temp_files/iv_0_baseline_section21_lags1.dta", nogen update
sort horizon
gen ci=1.96*se
export excel using "./output/graphs/temp_files/fig_3.xls", firstrow(variables) sheet("iv_0_baseline_section21l1", modify)

*Aggregate.
clear
set obs 11
seq horizon, f(0) t(10)
merge 1:1 horizon using "./output/temp_files/iv_0_baseline_section_agg_non_1.dta", nogen update
sort horizon
gen ci=1.96*se
export excel using "./output/graphs/temp_files/fig_3.xls", firstrow(variables) sheet("iv_0_baseline_section_aggnonl1", modify)

///////////////
///Figure B4///
///////////////

*Baseline.
clear
set obs 11
seq horizon, f(0) t(10)
merge 1:1 horizon using "./output/temp_files/iv_0_baseline_elasticity_ln_trade_val_l1.dta", nogen update
sort horizon
gen ci=1.96*se
export excel using "./output/graphs/temp_files/fig_b4.xls", firstrow(variables) sheet("baseline", modify)

*No FE.
clear
set obs 11
seq horizon, f(0) t(10)
merge 1:1 horizon using "./output/temp_files/iv_0_baseline_elasticity_ln_trade_val_l1_bfe_no.dta", nogen update
sort horizon
gen ci=1.96*se
export excel using "./output/graphs/temp_files/fig_b4.xls", firstrow(variables) sheet("bfe_no", modify)

*Imp/Exp FE.
clear
set obs 11
seq horizon, f(0) t(10)
merge 1:1 horizon using "./output/temp_files/iv_0_baseline_elasticity_ln_trade_val_l1_bfe.dta", nogen update
sort horizon
gen ci=1.96*se
export excel using "./output/graphs/temp_files/fig_b4.xls", firstrow(variables) sheet("bfe", modify)

*Imp/Exp HS2 FE.
clear
set obs 11
seq horizon, f(0) t(10)
merge 1:1 horizon using "./output/temp_files/iv_0_baseline_elasticity_ln_trade_val_l1_bfe_hs2.dta", nogen update
sort horizon
gen ci=1.96*se
export excel using "./output/graphs/temp_files/fig_b4.xls", firstrow(variables) sheet("bfe_hs2", modify)

*Imp/Exp HS3 FE.
clear
set obs 11
seq horizon, f(0) t(10)
merge 1:1 horizon using "./output/temp_files/iv_0_baseline_elasticity_ln_trade_val_l1_bfe_hs3.dta", nogen update
sort horizon
gen ci=1.96*se
export excel using "./output/graphs/temp_files/fig_b4.xls", firstrow(variables) sheet("bfe_hs3", modify)

////////////////
///Figure B5///
////////////////

*Baseline.
clear
set obs 11
seq horizon, f(0) t(10)
merge 1:1 horizon using "./output/temp_files/iv_0_baseline_elasticity_ln_trade_val_l1.dta", nogen update
sort horizon
gen ci=1.96*se
export excel using "./output/graphs/temp_files/fig_b5.xls", firstrow(variables) sheet("baseline", modify)

*No FE.
clear
set obs 11
seq horizon, f(0) t(10)
merge 1:1 horizon using "./output/temp_files/iv_0_baseline_elasticity_ln_trade_val_l1_mfe_no.dta", nogen update
sort horizon
gen ci=1.96*se
export excel using "./output/graphs/temp_files/fig_b5.xls", firstrow(variables) sheet("mfe_no", modify)

*Imp/Exp FE.
clear
set obs 11
seq horizon, f(0) t(10)
merge 1:1 horizon using "./output/temp_files/iv_0_baseline_elasticity_ln_trade_val_l1_mfe.dta", nogen update
sort horizon
gen ci=1.96*se
export excel using "./output/graphs/temp_files/fig_b5.xls", firstrow(variables) sheet("mfe", modify)

*Imp/Exp HS2 FE.
clear
set obs 11
seq horizon, f(0) t(10)
merge 1:1 horizon using "./output/temp_files/iv_0_baseline_elasticity_ln_trade_val_l1_mfe_hs2.dta", nogen update
sort horizon
gen ci=1.96*se
export excel using "./output/graphs/temp_files/fig_b5.xls", firstrow(variables) sheet("mfe_hs2", modify)

*Imp/Exp HS3 FE.
clear
set obs 11
seq horizon, f(0) t(10)
merge 1:1 horizon using "./output/temp_files/iv_0_baseline_elasticity_ln_trade_val_l1_mfe_hs3.dta", nogen update
sort horizon
gen ci=1.96*se
export excel using "./output/graphs/temp_files/fig_b5.xls", firstrow(variables) sheet("mfe_hs3", modify)

//////////////
///Figure 5///
//////////////

*Tariffs, pretrend controls.
use horizon b using "./output/temp_files/iv_0_baseline_lp_tariffs_l1.dta", clear

*Add one more period.
set obs 11
replace horizon=0 if horizon==.
replace b=1 if horizon==0
rename b tariffs

*Trade.
merge 1:1 horizon using "./output/temp_files/iv_0_baseline_lp_ln_trade_val_l1.dta", keepusing(b) nogen
rename b trade

*Baseline.
merge 1:1 horizon using "./output/temp_files/iv_0_baseline_elasticity_ln_trade_val_l1.dta", keepusing(b) nogen
rename b elasticity_implied
gen elasticity_estimated=elasticity_implied

*Sort database.
sort horizon

*Save.
export excel using "./output/graphs/temp_files/fig_5.xls", firstrow(variables) sheet("new", modify)
