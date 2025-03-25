capture log close 										// closes any open logs
clear all													// clears the memory
clear matrix 											// clears matrix memory
clear mata 												// clears mata memory
*cd "C:\Users\andre\OneDrive\UCSD\Research\cgoes\brazil-exports" 				// sets working directory
cd "C:\Users\andre\OneDrive\UCSD\Research\cgoes\brazil-exports" 				// sets working directory
set more off  											// most important command in STATA :)/
set maxvar 32000
set matsize 11000
set max_memory 5g

// 0. globals 

global comtrade = "data\comtrade"
global conc = "data\conc"
global temp = "data\temp"


global lhs = "employment female male less_than_college college_or_higher w w_male w_female w_less_than_college w_college_or_higher emp_ntrade"
global leads = 6
global lags = 5
global first_y = 2000
global last_y = 2020

global baseyear = 2003
global endyear = 2010

timer on 1

*do "code\%stata_mun\d00_prepare_comtrade.do"

do "code\%stata_mun\d01_prepare_rais.do"

do "code\%stata_mun\d02_instrument_const.do"

do "code\%stata_mun\d02b_instrument_alternative.do"

do "code\%stata_mun\d03_tradable_group.do"

do "code\%stata_mun\d04_microregion_exp.do"

do "code\%stata_mun\d05_lhs_const.do"

do "code\%stata_mun\d06_prepare_census.do"

do "code\%stata_mun\d07_census_instrument_const.do"

do "code\%stata_mun\d07b_census_instrument_alternative.do"

do "code\%stata_mun\d08_census_microregion_exp.do"

do "code\%stata_mun\r01_inst_validation.do"

do "code\%stata_mun\r02_baseline_irfs.do"

do "code\%stata_mun\r02b_baseline_irfs.do"

*do "code\%stata_mun\r03_baseline_irfs_base.do"

do "code\%stata_mun\r04_census_reg.do"

do "code\%stata_mun\g01_plot_irfs.do"

do "code\%stata_mun\g02_plot_irfs_comtrade.do"

do "code\%stata_mun\g03_plot_irfs_comtrade_combined.do"

timer off 1
timer list