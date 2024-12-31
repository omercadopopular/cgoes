version 17

*set folder of this file here: CHANGE TO YOUR FOLDER
cd "C:\Users\wb592068\OneDrive - UC San Diego\UCSD\Research\dynamic-adjustment-trade-disruptions\levchenko-replication"

** install required packages (note version requirements)
cap ado uninstall reghdfe 
net install reghdfe, from(https://raw.githubusercontent.com/sergiocorreia/reghdfe/master/src) replace
cap ado uninstall ivreghdfe 
net install ivreghdfe, from(https://raw.githubusercontent.com/sergiocorreia/ivreghdfe/master/src) replace

cap ssc install xsvmat
cap ssc install ftools
cap ssc install ranktest
cap ssc install estout

******************GLOBAL PARAMETERS FOR PORTIONS OF CODE TO RUN*****************

*** Baseline trade elasticity estimates
global runbaseline no

*** Robustness checks, intensive margin
global runrobust_int_a no
global runrobust_int_b no
global runrobust_int_c no
global runrobust_int_d no
global runrobust_int_e no

*** Robustness checks, extensive margin

global runrobust_ext_a no
global runrobust_ext_b no


*** Robustness checks, local projections

global runrobust_lp_int_a no
global runrobust_lp_int_b no
global runrobust_lp_int_c no

*** Sectoral elasticity estimates

global runrobust_21sec no
global runrobust_21sec_agg no

*** Regression output for graphs

global runrobust_graphs_a no
global runrobust_graphs_b no
global runrobust_graphs_c no

*** Regressions for Tables 1 and 2 and robustness in appendix

global run_crosswalk_a no
global run_crosswalk_b no
global runrobust_crosswalk_a no
global runrobust_crosswalk_b no

********************************************************************************
*** (1) Run all code for the data construction
********************************************************************************

*** Trade data construction
di "$S_DATE $S_TIME"
do "./code/d01_BACI_clean_data.do"

*** Tariff data construction -- NB: Data cannot be publicly shared. This file
*** will take your downloaded version (see ReadMe for instructions) and name variables appropriately
*** for merging with our other data. 
di "$S_DATE $S_TIME"
do "./code/d02_TRAINS_clean_data.do"

*** Merge trade and tariff data, cleaning steps
di "$S_DATE $S_TIME"
do "./code/d03_Merge_data.do"
do "./code/d04_Create_partnerind.do"
do "./code/d05_Create_PTA_indicator.do"

*** Create final datasets for analysis
di "$S_DATE $S_TIME"
do "./code/d06_Create_datanalysis_dataset.do"
do "./code/d07_Create_datanalysis.do"
do "./code/d08_Create_datanalysis_all.do"

*** Create data for robustness checks
do "./code/d09_Create_PTA_indicator_robustness.do"
do "./code/d10_merge_ttb.do"
do "./code/d11_pwt.do"
do "./code/d12_convert_ossa_GTAP.do"
do "./code/d13_wiod_sectors.do"



********************************************************************************
*** (2) Run all code for main analysis -- NOTE PROCESSING TIME IF RUN SEQUENTIALLY IS nearly 500 hours
*** alternatively, choose parts of regression analysis by turning on globals to run
*** Can run figures/tables code in step (3) using regression output provided in output/Results/Reg_Output_Paper
********************************************************************************


if "$runbaseline" == "yes" {
** RUNTIME FOR THIS FILE IS 38HOURS 25MINUTES
	do "./code/r01_regressions_baseline_int.do"
** this will save the intermediate results of the paper provided by the authors to the relevant folder for graphs/tables
} 
else {
	use "./output/reg_output_paper/iv_0_baseline_elasticity_ln_trade_val.dta", clear
	save "./output/temp_files/iv_0_baseline_elasticity_ln_trade_val.dta", replace
	use "./output/reg_output_paper/iv_0_baseline_elasticity_ln_trade_val_l1.dta", clear
	save "./output/temp_files/iv_0_baseline_elasticity_ln_trade_val_l1.dta", replace
	use "./output/reg_output_paper/iv_0_baseline_elasticity_ln_trade_val_l5.dta", clear
	save "./output/temp_files/iv_0_baseline_elasticity_ln_trade_val_l5.dta", replace
}

*** Robustness checks, intensive margin

if "$runrobust_int_a" == "yes" {
** RUNTIME FOR THIS FILE IS 23HOURS 50MINUTES	
	do "./code/r02_regressions_robustness_int_a.do"
** this will save the intermediate results of the paper provided by the authors to the relevant folder for graphs/tables
} 
else {
	use "./output/reg_output_paper/iv_0_baseline_elasticity_ln_trade_val_FE50_lags1.dta", clear
	save "./output/temp_files/iv_0_baseline_elasticity_ln_trade_val_FE50_lags1.dta", replace
	use "./output/reg_output_paper/iv_0_baseline_elasticity_ln_trade_val_SE2_lags1.dta", clear
	save "./output/temp_files/iv_0_baseline_elasticity_ln_trade_val_SE2_lags1.dta", replace
}


if "$runrobust_int_b" == "yes" {
** RUNTIME FOR THIS FILE IS 51HOURS 40MINUTES		
	do "./code/r02_regressions_robustness_int_b.do"
** this will save the intermediate results of the paper provided by the authors to the relevant folder for graphs/tables
} 
else {
	use "./output/reg_output_paper/iv_0_did_elasticity_ln_trade_val_l1.dta", clear
	save "./output/temp_files/iv_0_did_elasticity_ln_trade_val_l1.dta", replace
	use "./output/reg_output_paper/iv_0_top5_elasticity_ln_trade_val_lags1.dta", clear
	save "./output/temp_files/iv_0_top5_elasticity_ln_trade_val_lags1.dta", replace
	use "./output/reg_output_paper/iv_0_baseline_elasticity_ln_quantity_l1.dta", clear
	save "./output/temp_files/iv_0_baseline_elasticity_ln_quantity_l1.dta", replace
	use "./output/reg_output_paper/iv_0_baseline_elasticity_ln_uv_l1.dta", clear
	save "./output/temp_files/iv_0_baseline_elasticity_ln_uv_l1.dta", replace
}


if "$runrobust_int_c" == "yes" {
** RUNTIME FOR THIS FILE IS 50HOURS 15MINUTES	
	do "./code/r02_regressions_robustness_int_c.do"
** this will save the intermediate results of the paper provided by the authors to the relevant folder for graphs/tables
} 
else {
	use "./output/reg_output_paper/iv_0_baseline_elasticity_ln_trade_val_lnwt_lags1.dta", clear
	save "./output/temp_files/iv_0_baseline_elasticity_ln_trade_val_lnwt_lags1.dta", replace
	use "./output/reg_output_paper/iv_0_baseline_elasticity_ln_trade_val_SD0_lags1.dta", clear
	save "./output/temp_files/iv_0_baseline_elasticity_ln_trade_val_SD0_lags1.dta", replace
	use "./output/reg_output_paper/iv_0_PTA_elasticity_ln_trade_val_PTA_lags1.dta", clear
	save "./output/temp_files/iv_0_PTA_elasticity_ln_trade_val_PTA_lags1.dta", replace
	use "./output/reg_output_paper/iv_0_baseline_TTB_elasticity_ln_trade_val_lags1.dta", clear
	save "./output/temp_files/iv_0_baseline_TTB_elasticity_ln_trade_val_lags1.dta", replace
}


if "$runrobust_int_d" == "yes" {
** RUNTIME FOR THIS FILE IS 30HOURS 40MINUTES	
	do "./code/r02_regressions_robustness_int_d.do"
** this will save the intermediate results of the paper provided by the authors to the relevant folder for graphs/tables
} 
else {
	use "./output/reg_output_paper/iv_0_baseline_dl_elasticity_ln_trade_val.dta", clear
	save "./output/temp_files/iv_0_baseline_dl_elasticity_ln_trade_val.dta", replace
	use "./output/reg_output_paper/iv_0_baseline_elasticity_ln_trade_val_lags1_MRT6_BIL0.dta", clear
	save "./output/temp_files/iv_0_baseline_elasticity_ln_trade_val_lags1_MRT6_BIL0.dta", replace
	use "./output/reg_output_paper/OLS_ln_trade_val_FE6_lags1.dta", clear
	save "./output/temp_files/OLS_ln_trade_val_FE6_lags1.dta", replace
	use "./output/reg_output_paper/iv_0_baseline_elasticity_ln_trade_val_ur_lags1.dta", clear
	save "./output/temp_files/iv_0_baseline_elasticity_ln_trade_val_ur_lags1.dta", replace
	use "./output/reg_output_paper/OLS_ln_trade_val_ur_lags1.dta", clear
	save "./output/temp_files/OLS_ln_trade_val_ur_lags1.dta", replace
}


if "$runrobust_int_e" == "yes" {
** RUNTIME FOR THIS FILE IS 10HOURS 40MINUTES	
	do "./code/r02_regressions_robustness_int_e.do"
** this will save the intermediate results of the paper provided by the authors to the relevant folder for graphs/tables
} 
else {
	use "./output/reg_output_paper/iv_0_baseline_elasticity_ln_trade_val_bp_lags1.dta", clear
	save "./output/temp_files/iv_0_baseline_elasticity_ln_trade_val_bp_lags1.dta", replace
	use "./output/reg_output_paper/iv_0_baseline_elasticity_ln_trade_val_Ctrl0_lags1.dta", clear
	save "./output/temp_files/iv_0_baseline_elasticity_ln_trade_val_Ctrl0_lags1.dta", replace
}


*** Robustness checks, extensive margin


if "$runrobust_ext_a" == "yes" {
** RUNTIME FOR THIS FILE IS 24HOURS 30MINUTES	
	do "./code/r03_regressions_baseline_ext_a.do"
** this will save the intermediate results of the paper provided by the authors to the relevant folder for graphs/tables
} 
else {
	use "./output/reg_output_paper/iv_0_baseline_elasticity_ln_trade_val_ext_lags0.dta", clear
	save "./output/temp_files/iv_0_baseline_elasticity_ln_trade_val_ext_lags0.dta", replace
}


if "$runrobust_ext_b" == "yes" {
** RUNTIME FOR THIS FILE IS 13HOURS 15MINUTES	
	do "./code/r03_regressions_baseline_ext_b.do"
** this will save the intermediate results of the paper provided by the authors to the relevant folder for graphs/tables
} 
else {
	use "./output/reg_output_paper/iv_0_baseline_elasticity_ln_trade_val_ext_sel_lags0.dta", clear
	save "./output/temp_files/iv_0_baseline_elasticity_ln_trade_val_ext_sel_lags0.dta", replace
}


*** Robustness checks, local projections


if "$runrobust_lp_int_a" == "yes" {
** RUNTIME FOR THIS FILE IS 30HOURS 30MINUTES	
	do "./code/r04_regressions_lp_int_a.do"
** this will save the intermediate results of the paper provided by the authors to the relevant folder for graphs/tables
} 
else {
	use "./output/reg_output_paper/iv_0_baseline_lp_tariffs_pre.dta", clear
	save "./output/temp_files/iv_0_baseline_lp_tariffs_pre.dta", replace
	use "./output/reg_output_paper/iv_0_baseline_lp_tariffs.dta", clear
	save "./output/temp_files/iv_0_baseline_lp_tariffs.dta", replace
	use "./output/reg_output_paper/iv_0_baseline_lp_ln_trade_val_pre.dta", clear
	save "./output/temp_files/iv_0_baseline_lp_ln_trade_val_pre.dta", replace
	use "./output/reg_output_paper/iv_0_baseline_lp_ln_trade_val.dta", clear
	save "./output/temp_files/iv_0_baseline_lp_ln_trade_val.dta", replace
}


if "$runrobust_lp_int_b" == "yes" {
** RUNTIME FOR THIS FILE IS 34HOURS 55MINUTES	
	do "./code/r04_regressions_lp_int_b.do"
** this will save the intermediate results of the paper provided by the authors to the relevant folder for graphs/tables
} 
else {
	use "./output/reg_output_paper/iv_0_baseline_lp_tariffs_pre_l1.dta", clear
	save "./output/temp_files/iv_0_baseline_lp_tariffs_pre_l1.dta", replace
	use "./output/reg_output_paper/iv_0_baseline_lp_tariffs_l1.dta", clear
	save "./output/temp_files/iv_0_baseline_lp_tariffs_l1.dta", replace
	use "./output/reg_output_paper/iv_0_baseline_lp_ln_trade_val_pre_l1.dta", clear
	save "./output/temp_files/iv_0_baseline_lp_ln_trade_val_pre_l1.dta", replace
	use "./output/reg_output_paper/iv_0_baseline_lp_ln_trade_val_l1.dta", clear
	save "./output/temp_files/iv_0_baseline_lp_ln_trade_val_l1.dta", replace
}

if "$runrobust_lp_int_c" == "yes" {
** RUNTIME FOR THIS FILE IS 30HOURS 30MINUTES	
	do "./code/r04_regressions_lp_int_c.do"
** this will save the intermediate results of the paper provided by the authors to the relevant folder for graphs/tables
} 
else {
	use "./output/reg_output_paper/iv_0_baseline_lp_tariffs_pre_l5.dta", clear
	save "./output/temp_files/iv_0_baseline_lp_tariffs_pre_l5.dta", replace
	use "./output/reg_output_paper/iv_0_baseline_lp_tariffs_l5.dta", clear
	save "./output/temp_files/iv_0_baseline_lp_tariffs_l5.dta", replace
	use "./output/reg_output_paper/iv_0_baseline_lp_ln_trade_val_pre_l5.dta", clear
	save "./output/temp_files/iv_0_baseline_lp_ln_trade_val_pre_l5.dta", replace
	use "./output/reg_output_paper/iv_0_baseline_lp_ln_trade_val_l5.dta", clear
	save "./output/temp_files/iv_0_baseline_lp_ln_trade_val_l5.dta", replace
}


*** Sectoral elasticity estimates


if "$runrobust_21sec" == "yes" {
** RUNTIME FOR THIS FILE IS 6HOURS 40MINUTES	
	do "./code/r05_regressions_robustness_21sec.do"
** this will save the intermediate results of the paper provided by the authors to the relevant folder for graphs/tables
} 
else {
	forvalues num = 1/21{
	use "./output/reg_output_paper/iv_0_baseline_section`num'_lags1.dta", clear
	save "./output/temp_files/iv_0_baseline_section`num'_lags1.dta", replace		
	}
}


if "$runrobust_21sec_agg" == "yes" {
** RUNTIME FOR THIS FILE IS 8HOURS 45MINUTES	
	do "./code/r06_regressions_robustness_21sec_agg_non.do"
** this will save the intermediate results of the paper provided by the authors to the relevant folder for graphs/tables
} 
else {
	use "./output/reg_output_paper/iv_0_baseline_section_agg_non_0.dta", clear
	save "./output/temp_files/iv_0_baseline_section_agg_non_0.dta", replace
	use "./output/reg_output_paper/iv_0_baseline_section_agg_non_1.dta", clear
	save "./output/temp_files/iv_0_baseline_section_agg_non_1.dta", replace
	use "./output/reg_output_paper/iv_0_baseline_section_agg_non_2.dta", clear
	save "./output/temp_files/iv_0_baseline_section_agg_non_2.dta", replace
}


*** Regression output for graphs


if "$runrobust_graphs_a" == "yes" {
** RUNTIME FOR THIS FILE IS 12HOURS 30MINUTES	
	do "./code/r07_regressions_graphs_a.do"
** this will save the intermediate results of the paper provided by the authors to the relevant folder for graphs/tables
} 
else {
	use "./output/reg_output_paper/OLS_ln_trade_val_lags1.dta", clear
	save "./output/temp_files/OLS_ln_trade_val_lags1.dta", replace
}


if "$runrobust_graphs_b" == "yes" {
** RUNTIME FOR THIS FILE IS 46HOURS 50MINUTES	
	do "./code/r07_regressions_graphs_b.do"
** this will save the intermediate results of the paper provided by the authors to the relevant folder for graphs/tables
} 
else {
	use "./output/reg_output_paper/iv_0_baseline_elasticity_ln_trade_val_l1_bfe_no.dta", clear
	save "./output/temp_files/iv_0_baseline_elasticity_ln_trade_val_l1_bfe_no.dta", replace
	use "./output/reg_output_paper/iv_0_baseline_elasticity_ln_trade_val_l1_bfe.dta", clear
	save "./output/temp_files/iv_0_baseline_elasticity_ln_trade_val_l1_bfe.dta", replace
	use "./output/reg_output_paper/iv_0_baseline_elasticity_ln_trade_val_l1_bfe_hs2.dta", clear
	save "./output/temp_files/iv_0_baseline_elasticity_ln_trade_val_l1_bfe_hs2.dta", replace
	use "./output/reg_output_paper/iv_0_baseline_elasticity_ln_trade_val_l1_bfe_hs3.dta", clear
	save "./output/temp_files/iv_0_baseline_elasticity_ln_trade_val_l1_bfe_hs3.dta", replace
}


if "$runrobust_graphs_c" == "yes" {
** RUNTIME FOR THIS FILE IS 42HOURS 15MINUTES	
	do "./code/r07_regressions_graphs_c.do"
** this will save the intermediate results of the paper provided by the authors to the relevant folder for graphs/tables
} 
else {
	use "./output/reg_output_paper/iv_0_baseline_elasticity_ln_trade_val_l1_mfe_no.dta", clear
	save "./output/temp_files/iv_0_baseline_elasticity_ln_trade_val_l1_mfe_no.dta", replace
	use "./output/reg_output_paper/iv_0_baseline_elasticity_ln_trade_val_l1_mfe.dta", clear
	save "./output/temp_files/iv_0_baseline_elasticity_ln_trade_val_l1_mfe.dta", replace
	use "./output/reg_output_paper/iv_0_baseline_elasticity_ln_trade_val_l1_mfe_hs2.dta", clear
	save "./output/temp_files/iv_0_baseline_elasticity_ln_trade_val_l1_mfe_hs2.dta", replace
	use "./output/reg_output_paper/iv_0_baseline_elasticity_ln_trade_val_l1_mfe_hs3.dta", clear
	save "./output/temp_files/iv_0_baseline_elasticity_ln_trade_val_l1_mfe_hs3.dta", replace
}


*** Regressions for Tables 1 and 2 and robustness in appendix


if "$run_crosswalk_a" == "yes" {
** RUNTIME FOR THIS FILE IS 6HOURS 10MINUTES	
	do "./code/g01_crosswalk_a.do"
** this will save the intermediate results of the paper provided by the authors to the relevant folder for graphs/tables
} 
else {
	import excel "./output/reg_output_paper/table_1.xlsx", clear
	export excel  "./output/tables/table_1.xlsx", replace
}


if "$run_crosswalk_b" == "yes" {
** RUNTIME FOR THIS FILE IS 5HOURS 55MINUTES	
	do "./code/g01_crosswalk_b.do"
** this will save the intermediate results of the paper provided by the authors to the relevant folder for graphs/tables
} 
else {
	import excel "./output/reg_output_paper/table_2.xlsx", clear
	export excel  "./output/tables/table_2.xlsx", replace
}


if "$runrobust_crosswalk_a" == "yes" {
** RUNTIME FOR THIS FILE IS 9HOURS 50MINUTES	
	do "./code/g02_crosswalk_rob_a.do"
** this will save the intermediate results of the paper provided by the authors to the relevant folder for graphs/tables
} 
else {
	import excel "./output/reg_output_paper/table_b4.xlsx", clear
	export excel  "./output/tables/table_b4.xlsx", replace
}


if "$runrobust_crosswalk_b" == "yes" {
** RUNTIME FOR THIS FILE IS 6HOURS 30MINUTES	
	do "./code/g02_crosswalk_rob_b.do"
** this will save the intermediate results of the paper provided by the authors to the relevant folder for graphs/tables
} 
else {
	import excel "./output/reg_output_paper/table_b5.xlsx", clear
	export excel  "./output/tables/table_b5.xlsx", replace
}



********************************************************************************
*** (3) Construct Tables and Figures
********************************************************************************
*** Create tables in paper Sections 1-5 and appendix A-C
do "./code/t01_tables_regs.do"
do "./code/t02_mapping.do"
do "./code/t03_Example_instrument_table.do" // RUNTIME FOR THIS FILE IS 5MINUTES	
do "./code/t04_gft_acr.do"

*** Create figures in paper Sections 1-5 and appendix A-C
do "./code/f01_Create_dataplots.do"
shell matlab -noFigureWindows -r "try; run('./code/f02_Plot_elasticities_pretrends.m'); catch; end; quit" -wait
do "./code/f03_figures.do" // RUNTIME FOR THIS FILE IS 10MINUTES	
do "./code/f04_Create_descriptive_analysis.do" // RUNTIME FOR THIS FILE IS 30MINUTES	
do "./code/f05_variance_afterFE2.do" // RUNTIME FOR THIS FILE IS 50MINUTES	

** Plot static gains from trade
shell matlab -noFigureWindows -r "try; run('./code/f06_Plot_GFT_sections.m'); catch; end; quit" -wait
shell matlab -noFigureWindows -r "try; run('./code/f07_Plot_GFT.m'); catch; end; quit" -wait



********************************************************************************
*** (4) Model in Section 6 and Appendix D
********************************************************************************
** RUNTIME FOR THIS SECTION IS 25MINUTES	

*** Create data for calibration
do "./code/c01_KLEMS.do"
do "./code/c02_PWT.do"
do "./code/c03_WIOD.do" 
do "./code/c04_tariffs_pre.do" 
do "./code/c05_tariffs.do"

*** Run model in MATLAB
shell matlab -noFigureWindows -r "try; run('./code/m01_linear_main.m'); catch; end; quit" -wait
shell matlab -noFigureWindows -r "try; run('./code/m02_nonlinear_main.m'); catch; end; quit" -wait

*** Create figures
do "./code/m03_nonlinear_scatter.do"

*** Run model in MATLAB
shell matlab -noFigureWindows -r "try; run('./code/m04_local_dist_costs.m'); catch; end; quit" -wait
