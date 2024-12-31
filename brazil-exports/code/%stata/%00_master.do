capture log close 										// closes any open logs
clear all													// clears the memory
clear matrix 											// clears matrix memory
clear mata 												// clears mata memory
cd "C:\Users\wb592068\OneDrive - WBG\Brazil" 				// sets working directory
set more off  											// most important command in STATA :)/
set maxvar 32000
set matsize 11000
set max_memory 5g

// 0. globals 

global comtrade = "data\comtrade"
global conc = "data\conc"
global temp = "data\temp"


global lhs = "employment female male less_than_college college_or_higher w w_male w_female avg_wage_h1 avg_wage_h2"
global leads = 6
global lags = 5
global first_y = 2000
global last_y = 2020

global baseyear = 2003
global endyear = 2010

timer on 1

do "code\%stata\d00_prepare_comtrade.do"

do "code\%stata\d01_prepare_rais.do"

do "code\%stata\d02_instrument_const.do"

do "code\%stata\d02b_instrument_alternative.do"

do "code\%stata\d03_base_inst_const.do"

do "code\%stata\d03b_base_inst_alternative.do"

do "code\%stata\d04_microregion_exp.do"

do "code\%stata\d05_lhs_const.do"

do "code\%stata\d06_prepare_census.do"

do "code\%stata\d07_census_instrument_const.do"

do "code\%stata\d07b_census_instrument_alternative.do"

do "code\%stata\d08_census_microregion_exp.do"

do "code\%stata\r01_inst_validation.do"

do "code\%stata\r02_baseline_irfs.do"

do "code\%stata\r02b_baseline_irfs.do"

do "code\%stata\r03_baseline_irfs_base.do"

do "code\%stata\r04_census_reg.do"

do "code\%stata\g01_plot_irfs.do"

do "code\%stata\g02_plot_irfs_comtrade.do"

do "code\%stata\g03_plot_irfs_comtrade_combined.do"

timer off 1
timer list