clear all
set more off

cap log close
log using "./output/logs/log_t01.smcl", append

/////////////
///Table 3///
/////////////

*Define horizon.
local num_horizon=6

	*Column 1.

	*Open results.
	use "./output/temp_files/iv_0_baseline_elasticity_ln_trade_val_l1.dta", clear

	*Keep selected horizons.
	keep if inlist(horizon, 0, 1, 3, 5, 7, 10)

	*Generate p-value.
	gen pval=2*normal(-abs(b/se))

	*Generate observations in millions.
	replace obs=obs/1000000
	
	*Generate stars vector.
	gen star=""
	replace star="***" if pval<=0.01
	replace star="**" if pval>0.01 & pval<=0.05
	replace star="*" if pval>0.05 & pval<=0.1
	
	*Generate coefficient and stars string vector.
	tostring b, replace force format(%9.2f)
	gen b_star=b+star
	
	*Convert variables to strings.
	tostring se, replace force format(%9.2f)
	replace se="("+se+")"
	tostring obs, replace force format(%9.1f)
	
	*Keep variables.
	keep b_star se obs
	order b_star se obs
	
	*Generate results vector.
	gen results=""
	local maxobs=`num_horizon'*3
	set obs `maxobs'
	forvalues rrr=1(1)`num_horizon'{
		
		replace results=b_star[`rrr'] if _n==3*(`rrr'-1)+1
		replace results=se[`rrr'] if _n==3*(`rrr'-1)+2
		replace results=obs[`rrr'] if _n==3*(`rrr'-1)+3
		
	}
	
	*Rename results vector.
	keep results
	rename results col1
	
	*Save results.
	gen n=_n
	save "./output/tables/table_aux_col1.dta", replace
	
	*Column 2.

	*Open results.
	use "./output/temp_files/iv_0_baseline_elasticity_ln_trade_val.dta", clear

	*Keep selected horizons.
	keep if inlist(horizon, 0, 1, 3, 5, 7, 10)

	*Generate p-value.
	gen pval=2*normal(-abs(b/se))

	*Generate observations in millions.
	replace obs=obs/1000000
	
	*Generate stars vector.
	gen star=""
	replace star="***" if pval<=0.01
	replace star="**" if pval>0.01 & pval<=0.05
	replace star="*" if pval>0.05 & pval<=0.1
	
	*Generate coefficient and stars string vector.
	tostring b, replace force format(%9.2f)
	gen b_star=b+star
	
	*Convert variables to strings.
	tostring se, replace force format(%9.2f)
	replace se="("+se+")"
	tostring obs, replace force format(%9.1f)
	
	*Keep variables.
	keep b_star se obs
	order b_star se obs
	
	*Generate results vector.
	gen results=""
	local maxobs=`num_horizon'*3
	set obs `maxobs'
	forvalues rrr=1(1)`num_horizon'{
		
		replace results=b_star[`rrr'] if _n==3*(`rrr'-1)+1
		replace results=se[`rrr'] if _n==3*(`rrr'-1)+2
		replace results=obs[`rrr'] if _n==3*(`rrr'-1)+3
		
	}
	
	*Rename results vector.
	keep results
	rename results col2
	
	*Save results.
	gen n=_n
	save "./output/tables/table_aux_col2.dta", replace
	
	*Column 3.

	*Open results.
	use "./output/temp_files/iv_0_baseline_elasticity_ln_trade_val_l5.dta", clear

	*Keep selected horizons.
	keep if inlist(horizon, 0, 1, 3, 5, 7, 10)

	*Generate p-value.
	gen pval=2*normal(-abs(b/se))

	*Generate observations in millions.
	replace obs=obs/1000000
	
	*Generate stars vector.
	gen star=""
	replace star="***" if pval<=0.01
	replace star="**" if pval>0.01 & pval<=0.05
	replace star="*" if pval>0.05 & pval<=0.1
	
	*Generate coefficient and stars string vector.
	tostring b, replace force format(%9.2f)
	gen b_star=b+star
	
	*Convert variables to strings.
	tostring se, replace force format(%9.2f)
	replace se="("+se+")"
	tostring obs, replace force format(%9.1f)
	
	*Keep variables.
	keep b_star se obs
	order b_star se obs
	
	*Generate results vector.
	gen results=""
	local maxobs=`num_horizon'*3
	set obs `maxobs'
	forvalues rrr=1(1)`num_horizon'{
		
		replace results=b_star[`rrr'] if _n==3*(`rrr'-1)+1
		replace results=se[`rrr'] if _n==3*(`rrr'-1)+2
		replace results=obs[`rrr'] if _n==3*(`rrr'-1)+3
		
	}
	
	*Rename results vector.
	keep results
	rename results col3
	
	*Save results.
	gen n=_n
	save "./output/tables/table_aux_col3.dta", replace
	
	*Column 4.

	*Open results.
	use "./output/temp_files/iv_0_baseline_elasticity_ln_trade_val_FE50_lags1.dta", clear

	*Keep selected horizons.
	keep if inlist(horizon, 0, 1, 3, 5, 7, 10)

	*Generate p-value.
	gen pval=2*normal(-abs(b/se))

	*Generate observations in millions.
	replace obs=obs/1000000
	
	*Generate stars vector.
	gen star=""
	replace star="***" if pval<=0.01
	replace star="**" if pval>0.01 & pval<=0.05
	replace star="*" if pval>0.05 & pval<=0.1
	
	*Generate coefficient and stars string vector.
	tostring b, replace force format(%9.2f)
	gen b_star=b+star
	
	*Convert variables to strings.
	tostring se, replace force format(%9.2f)
	replace se="("+se+")"
	tostring obs, replace force format(%9.1f)
	
	*Keep variables.
	keep b_star se obs
	order b_star se obs
	
	*Generate results vector.
	gen results=""
	local maxobs=`num_horizon'*3
	set obs `maxobs'
	forvalues rrr=1(1)`num_horizon'{
		
		replace results=b_star[`rrr'] if _n==3*(`rrr'-1)+1
		replace results=se[`rrr'] if _n==3*(`rrr'-1)+2
		replace results=obs[`rrr'] if _n==3*(`rrr'-1)+3
		
	}
	
	*Rename results vector.
	keep results
	rename results col4
	
	*Save results.
	gen n=_n
	save "./output/tables/table_aux_col4.dta", replace
	
	*Column 5.

	*Open results.
	use "./output/temp_files/iv_0_baseline_elasticity_ln_trade_val_SE2_lags1.dta", clear

	*Keep selected horizons.
	keep if inlist(horizon, 0, 1, 3, 5, 7, 10)

	*Generate p-value.
	gen pval=2*normal(-abs(b/se))

	*Generate observations in millions.
	replace obs=obs/1000000
	
	*Generate stars vector.
	gen star=""
	replace star="***" if pval<=0.01
	replace star="**" if pval>0.01 & pval<=0.05
	replace star="*" if pval>0.05 & pval<=0.1
	
	*Generate coefficient and stars string vector.
	tostring b, replace force format(%9.2f)
	gen b_star=b+star
	
	*Convert variables to strings.
	tostring se, replace force format(%9.2f)
	replace se="("+se+")"
	tostring obs, replace force format(%9.1f)
	
	*Keep variables.
	keep b_star se obs
	order b_star se obs
	
	*Generate results vector.
	gen results=""
	local maxobs=`num_horizon'*3
	set obs `maxobs'
	forvalues rrr=1(1)`num_horizon'{
		
		replace results=b_star[`rrr'] if _n==3*(`rrr'-1)+1
		replace results=se[`rrr'] if _n==3*(`rrr'-1)+2
		replace results=obs[`rrr'] if _n==3*(`rrr'-1)+3
		
	}
	
	*Rename results vector.
	keep results
	rename results col5
	
	*Save results.
	gen n=_n
	save "./output/tables/table_aux_col5.dta", replace
	
	*Column 6.

	*Open results.
	use "./output/temp_files/iv_0_baseline_elasticity_ln_trade_val_bp_lags1.dta", clear

	*Keep selected horizons.
	keep if inlist(horizon, 0, 1, 3, 5, 7, 10)

	*Generate p-value.
	gen pval=2*normal(-abs(b/se))

	*Generate observations in millions.
	replace obs=obs/1000000
	
	*Generate stars vector.
	gen star=""
	replace star="***" if pval<=0.01
	replace star="**" if pval>0.01 & pval<=0.05
	replace star="*" if pval>0.05 & pval<=0.1
	
	*Generate coefficient and stars string vector.
	tostring b, replace force format(%9.2f)
	gen b_star=b+star
	
	*Convert variables to strings.
	tostring se, replace force format(%9.2f)
	replace se="("+se+")"
	tostring obs, replace force format(%9.1f)
	
	*Keep variables.
	keep b_star se obs
	order b_star se obs
	
	*Generate results vector.
	gen results=""
	local maxobs=`num_horizon'*3
	set obs `maxobs'
	forvalues rrr=1(1)`num_horizon'{
		
		replace results=b_star[`rrr'] if _n==3*(`rrr'-1)+1
		replace results=se[`rrr'] if _n==3*(`rrr'-1)+2
		replace results=obs[`rrr'] if _n==3*(`rrr'-1)+3
		
	}
	
	*Rename results vector.
	keep results
	rename results col6
	
	*Save results.
	gen n=_n
	save "./output/tables/table_aux_col6.dta", replace
	
	*Column 7.

	*Open results.
	use "./output/temp_files/iv_0_baseline_elasticity_ln_trade_val_ext_lags0.dta", clear

	*Keep selected horizons.
	keep if inlist(horizon, 0, 1, 3, 5, 7, 10)

	*Generate p-value.
	gen pval=2*normal(-abs(b/se))

	*Generate observations in millions.
	replace obs=obs/1000000
	
	*Generate stars vector.
	gen star=""
	replace star="***" if pval<=0.01
	replace star="**" if pval>0.01 & pval<=0.05
	replace star="*" if pval>0.05 & pval<=0.1
	
	*Generate coefficient and stars string vector.
	tostring b, replace force format(%9.2f)
	gen b_star=b+star
	
	*Convert variables to strings.
	tostring se, replace force format(%9.2f)
	replace se="("+se+")"
	tostring obs, replace force format(%9.1f)
	
	*Keep variables.
	keep b_star se obs
	order b_star se obs
	
	*Generate results vector.
	gen results=""
	local maxobs=`num_horizon'*3
	set obs `maxobs'
	forvalues rrr=1(1)`num_horizon'{
		
		replace results=b_star[`rrr'] if _n==3*(`rrr'-1)+1
		replace results=se[`rrr'] if _n==3*(`rrr'-1)+2
		replace results=obs[`rrr'] if _n==3*(`rrr'-1)+3
		
	}
	
	*Rename results vector.
	keep results
	rename results col7
	
	*Save results.
	gen n=_n
	save "./output/tables/table_aux_col7.dta", replace
	
	*Column 8.

	*Open results.
	use "./output/temp_files/iv_0_baseline_elasticity_ln_trade_val_ext_sel_lags0.dta", clear

	*Keep selected horizons.
	keep if inlist(horizon, 0, 1, 3, 5, 7, 10)

	*Generate p-value.
	gen pval=2*normal(-abs(b/se))

	*Generate observations in millions.
	replace obs=obs/1000000
	
	*Generate stars vector.
	gen star=""
	replace star="***" if pval<=0.01
	replace star="**" if pval>0.01 & pval<=0.05
	replace star="*" if pval>0.05 & pval<=0.1
	
	*Generate coefficient and stars string vector.
	tostring b, replace force format(%9.2f)
	gen b_star=b+star
	
	*Convert variables to strings.
	tostring se, replace force format(%9.2f)
	replace se="("+se+")"
	tostring obs, replace force format(%9.1f)
	
	*Keep variables.
	keep b_star se obs
	order b_star se obs
	
	*Generate results vector.
	gen results=""
	local maxobs=`num_horizon'*3
	set obs `maxobs'
	forvalues rrr=1(1)`num_horizon'{
		
		replace results=b_star[`rrr'] if _n==3*(`rrr'-1)+1
		replace results=se[`rrr'] if _n==3*(`rrr'-1)+2
		replace results=obs[`rrr'] if _n==3*(`rrr'-1)+3
		
	}
	
	*Rename results vector.
	keep results
	rename results col8
	
	*Save results.
	gen n=_n
	save "./output/tables/table_aux_col8.dta", replace
	
	
*Merge results.
use "./output/tables/table_aux_col1.dta", clear
merge 1:1 n using "./output/tables/table_aux_col2.dta", nogen
merge 1:1 n using "./output/tables/table_aux_col3.dta", nogen
merge 1:1 n using "./output/tables/table_aux_col4.dta", nogen
merge 1:1 n using "./output/tables/table_aux_col5.dta", nogen
merge 1:1 n using "./output/tables/table_aux_col6.dta", nogen
merge 1:1 n using "./output/tables/table_aux_col7.dta", nogen
merge 1:1 n using "./output/tables/table_aux_col8.dta", nogen
drop n

*Define row names.
gen row_names=""
replace row_names="$ t$" 	in 1
replace row_names="" in 2
replace row_names="obs" 	in 3
replace row_names="$ t+1$" in 4
replace row_names="" in 5
replace row_names="obs" 	in 6
replace row_names="$ t+3$" in 7
replace row_names="" in 8
replace row_names="obs" 	in 9
replace row_names="$ t+5$" in 10
replace row_names="" in 11
replace row_names="obs" 	in 12
replace row_names="$ t+7$" in 13
replace row_names="" in 14
replace row_names="obs" 	in 15
replace row_names="$ t+10$" in 16
replace row_names="" in 17
replace row_names="obs" 	in 18
order row_names col*

*Define column names.
label var row_names ""
label var col1 "Baseline"
label var col2 "Zero Lags"
label var col3 "Five Lags"
label var col4 "FE50"
label var col5 "Two-way Clustering"
label var col6 "Constant Sample"
label var col7 "Extensive"
label var col8 "Extensive Sel."

*Export table.
texsave row_names col1 col2 col3 col4 col5 col6 col7 col8 using "./output/tables/table_3.tex", varlabels nofix noendash replace preamble("/usepackage{adjustbox}") geometry("a4paper, total={5.5in, 7.5in}") width("18cm")

/////////////
///Table 4///
/////////////

*Define horizon.
local num_horizon=6

	*Column 1.

	*Open results.
	use "./output/temp_files/iv_0_baseline_elasticity_ln_trade_val_l1.dta", clear

	*Keep selected horizons.
	keep if inlist(horizon, 0, 1, 3, 5, 7, 10)

	*Generate p-value.
	gen pval=2*normal(-abs(b/se))

	*Generate observations in millions.
	replace obs=obs/1000000
	
	*Generate stars vector.
	gen star=""
	replace star="***" if pval<=0.01
	replace star="**" if pval>0.01 & pval<=0.05
	replace star="*" if pval>0.05 & pval<=0.1
	
	*Generate coefficient and stars string vector.
	tostring b, replace force format(%9.2f)
	gen b_star=b+star
	
	*Convert variables to strings.
	tostring se, replace force format(%9.2f)
	replace se="("+se+")"
	tostring obs, replace force format(%9.1f)
	
	*Keep variables.
	keep b_star se obs
	order b_star se obs
	
	*Generate results vector.
	gen results=""
	local maxobs=`num_horizon'*3
	set obs `maxobs'
	forvalues rrr=1(1)`num_horizon'{
		
		replace results=b_star[`rrr'] if _n==3*(`rrr'-1)+1
		replace results=se[`rrr'] if _n==3*(`rrr'-1)+2
		replace results=obs[`rrr'] if _n==3*(`rrr'-1)+3
		
	}
	
	*Rename results vector.
	keep results
	rename results col1
	
	*Save results.
	gen n=_n
	save "./output/tables/table_aux_col1.dta", replace
	
	*Column 2.

	*Open results.
	use "./output/temp_files/iv_0_did_elasticity_ln_trade_val_l1.dta", clear

	*Keep selected horizons.
	keep if inlist(horizon, 0, 1, 3, 5, 7, 10)

	*Generate p-value.
	gen pval=2*normal(-abs(b/se))

	*Generate observations in millions.
	replace obs=obs/1000000
	
	*Generate stars vector.
	gen star=""
	replace star="***" if pval<=0.01
	replace star="**" if pval>0.01 & pval<=0.05
	replace star="*" if pval>0.05 & pval<=0.1
	
	*Generate coefficient and stars string vector.
	tostring b, replace force format(%9.2f)
	gen b_star=b+star
	
	*Convert variables to strings.
	tostring se, replace force format(%9.2f)
	replace se="("+se+")"
	tostring obs, replace force format(%9.1f)
	
	*Keep variables.
	keep b_star se obs
	order b_star se obs
	
	*Generate results vector.
	gen results=""
	local maxobs=`num_horizon'*3
	set obs `maxobs'
	forvalues rrr=1(1)`num_horizon'{
		
		replace results=b_star[`rrr'] if _n==3*(`rrr'-1)+1
		replace results=se[`rrr'] if _n==3*(`rrr'-1)+2
		replace results=obs[`rrr'] if _n==3*(`rrr'-1)+3
		
	}
	
	*Rename results vector.
	keep results
	rename results col2
	
	*Save results.
	gen n=_n
	save "./output/tables/table_aux_col2.dta", replace
	
	*Column 3.

	*Open results.
	use "./output/temp_files/iv_0_top5_elasticity_ln_trade_val_lags1.dta", clear

	*Keep selected horizons.
	keep if inlist(horizon, 0, 1, 3, 5, 7, 10)

	*Generate p-value.
	gen pval=2*normal(-abs(b/se))

	*Generate observations in millions.
	replace obs=obs/1000000
	
	*Generate stars vector.
	gen star=""
	replace star="***" if pval<=0.01
	replace star="**" if pval>0.01 & pval<=0.05
	replace star="*" if pval>0.05 & pval<=0.1
	
	*Generate coefficient and stars string vector.
	tostring b, replace force format(%9.2f)
	gen b_star=b+star
	
	*Convert variables to strings.
	tostring se, replace force format(%9.2f)
	replace se="("+se+")"
	tostring obs, replace force format(%9.1f)
	
	*Keep variables.
	keep b_star se obs
	order b_star se obs
	
	*Generate results vector.
	gen results=""
	local maxobs=`num_horizon'*3
	set obs `maxobs'
	forvalues rrr=1(1)`num_horizon'{
		
		replace results=b_star[`rrr'] if _n==3*(`rrr'-1)+1
		replace results=se[`rrr'] if _n==3*(`rrr'-1)+2
		replace results=obs[`rrr'] if _n==3*(`rrr'-1)+3
		
	}
	
	*Rename results vector.
	keep results
	rename results col3
	
	*Save results.
	gen n=_n
	save "./output/tables/table_aux_col3.dta", replace
	
	*Column 4.

	*Open results.
	use "./output/temp_files/iv_0_baseline_elasticity_ln_quantity_l1.dta", clear

	*Keep selected horizons.
	keep if inlist(horizon, 0, 1, 3, 5, 7, 10)

	*Generate p-value.
	gen pval=2*normal(-abs(b/se))

	*Generate observations in millions.
	replace obs=obs/1000000
	
	*Generate stars vector.
	gen star=""
	replace star="***" if pval<=0.01
	replace star="**" if pval>0.01 & pval<=0.05
	replace star="*" if pval>0.05 & pval<=0.1
	
	*Generate coefficient and stars string vector.
	tostring b, replace force format(%9.2f)
	gen b_star=b+star
	
	*Convert variables to strings.
	tostring se, replace force format(%9.2f)
	replace se="("+se+")"
	tostring obs, replace force format(%9.1f)
	
	*Keep variables.
	keep b_star se obs
	order b_star se obs
	
	*Generate results vector.
	gen results=""
	local maxobs=`num_horizon'*3
	set obs `maxobs'
	forvalues rrr=1(1)`num_horizon'{
		
		replace results=b_star[`rrr'] if _n==3*(`rrr'-1)+1
		replace results=se[`rrr'] if _n==3*(`rrr'-1)+2
		replace results=obs[`rrr'] if _n==3*(`rrr'-1)+3
		
	}
	
	*Rename results vector.
	keep results
	rename results col4
	
	*Save results.
	gen n=_n
	save "./output/tables/table_aux_col4.dta", replace
	
	*Column 5.

	*Open results.
	use "./output/temp_files/iv_0_baseline_elasticity_ln_uv_l1.dta", clear

	*Keep selected horizons.
	keep if inlist(horizon, 0, 1, 3, 5, 7, 10)

	*Generate p-value.
	gen pval=2*normal(-abs(b/se))

	*Generate observations in millions.
	replace obs=obs/1000000
	
	*Generate stars vector.
	gen star=""
	replace star="***" if pval<=0.01
	replace star="**" if pval>0.01 & pval<=0.05
	replace star="*" if pval>0.05 & pval<=0.1
	
	*Generate coefficient and stars string vector.
	tostring b, replace force format(%9.2f)
	gen b_star=b+star
	
	*Convert variables to strings.
	tostring se, replace force format(%9.2f)
	replace se="("+se+")"
	tostring obs, replace force format(%9.1f)
	
	*Keep variables.
	keep b_star se obs
	order b_star se obs
	
	*Generate results vector.
	gen results=""
	local maxobs=`num_horizon'*3
	set obs `maxobs'
	forvalues rrr=1(1)`num_horizon'{
		
		replace results=b_star[`rrr'] if _n==3*(`rrr'-1)+1
		replace results=se[`rrr'] if _n==3*(`rrr'-1)+2
		replace results=obs[`rrr'] if _n==3*(`rrr'-1)+3
		
	}
	
	*Rename results vector.
	keep results
	rename results col5
	
	*Save results.
	gen n=_n
	save "./output/tables/table_aux_col5.dta", replace
	
	*Column 6.

	*Open results.
	use "./output/temp_files/iv_0_baseline_elasticity_ln_trade_val_lnwt_lags1.dta", clear

	*Keep selected horizons.
	keep if inlist(horizon, 0, 1, 3, 5, 7, 10)

	*Generate p-value.
	gen pval=2*normal(-abs(b/se))

	*Generate observations in millions.
	replace obs=obs/1000000
	
	*Generate stars vector.
	gen star=""
	replace star="***" if pval<=0.01
	replace star="**" if pval>0.01 & pval<=0.05
	replace star="*" if pval>0.05 & pval<=0.1
	
	*Generate coefficient and stars string vector.
	tostring b, replace force format(%9.2f)
	gen b_star=b+star
	
	*Convert variables to strings.
	tostring se, replace force format(%9.2f)
	replace se="("+se+")"
	tostring obs, replace force format(%9.1f)
	
	*Keep variables.
	keep b_star se obs
	order b_star se obs
	
	*Generate results vector.
	gen results=""
	local maxobs=`num_horizon'*3
	set obs `maxobs'
	forvalues rrr=1(1)`num_horizon'{
		
		replace results=b_star[`rrr'] if _n==3*(`rrr'-1)+1
		replace results=se[`rrr'] if _n==3*(`rrr'-1)+2
		replace results=obs[`rrr'] if _n==3*(`rrr'-1)+3
		
	}
	
	*Rename results vector.
	keep results
	rename results col6
	
	*Save results.
	gen n=_n
	save "./output/tables/table_aux_col6.dta", replace
	
	*Column 7.

	*Open results.
	use "./output/temp_files/iv_0_baseline_elasticity_ln_trade_val_SD0_lags1.dta", clear

	*Keep selected horizons.
	keep if inlist(horizon, 0, 1, 3, 5, 7, 10)

	*Generate p-value.
	gen pval=2*normal(-abs(b/se))

	*Generate observations in millions.
	replace obs=obs/1000000
	
	*Generate stars vector.
	gen star=""
	replace star="***" if pval<=0.01
	replace star="**" if pval>0.01 & pval<=0.05
	replace star="*" if pval>0.05 & pval<=0.1
	
	*Generate coefficient and stars string vector.
	tostring b, replace force format(%9.2f)
	gen b_star=b+star
	
	*Convert variables to strings.
	tostring se, replace force format(%9.2f)
	replace se="("+se+")"
	tostring obs, replace force format(%9.1f)
	
	*Keep variables.
	keep b_star se obs
	order b_star se obs
	
	*Generate results vector.
	gen results=""
	local maxobs=`num_horizon'*3
	set obs `maxobs'
	forvalues rrr=1(1)`num_horizon'{
		
		replace results=b_star[`rrr'] if _n==3*(`rrr'-1)+1
		replace results=se[`rrr'] if _n==3*(`rrr'-1)+2
		replace results=obs[`rrr'] if _n==3*(`rrr'-1)+3
		
	}
	
	*Rename results vector.
	keep results
	rename results col7
	
	*Save results.
	gen n=_n
	save "./output/tables/table_aux_col7.dta", replace
	
	*Column 8.

	*Open results.
	use "./output/temp_files/iv_0_PTA_elasticity_ln_trade_val_PTA_lags1.dta", clear

	*Keep selected horizons.
	keep if inlist(horizon, 0, 1, 3, 5, 7, 10)

	*Generate p-value.
	gen pval=2*normal(-abs(b/se))

	*Generate observations in millions.
	replace obs=obs/1000000
	
	*Generate stars vector.
	gen star=""
	replace star="***" if pval<=0.01
	replace star="**" if pval>0.01 & pval<=0.05
	replace star="*" if pval>0.05 & pval<=0.1
	
	*Generate coefficient and stars string vector.
	tostring b, replace force format(%9.2f)
	gen b_star=b+star
	
	*Convert variables to strings.
	tostring se, replace force format(%9.2f)
	replace se="("+se+")"
	tostring obs, replace force format(%9.1f)
	
	*Keep variables.
	keep b_star se obs
	order b_star se obs
	
	*Generate results vector.
	gen results=""
	local maxobs=`num_horizon'*3
	set obs `maxobs'
	forvalues rrr=1(1)`num_horizon'{
		
		replace results=b_star[`rrr'] if _n==3*(`rrr'-1)+1
		replace results=se[`rrr'] if _n==3*(`rrr'-1)+2
		replace results=obs[`rrr'] if _n==3*(`rrr'-1)+3
		
	}
	
	*Rename results vector.
	keep results
	rename results col8
	
	*Save results.
	gen n=_n
	save "./output/tables/table_aux_col8.dta", replace
	
	
*Merge results.
use "./output/tables/table_aux_col1.dta", clear
merge 1:1 n using "./output/tables/table_aux_col2.dta", nogen
merge 1:1 n using "./output/tables/table_aux_col3.dta", nogen
merge 1:1 n using "./output/tables/table_aux_col4.dta", nogen
merge 1:1 n using "./output/tables/table_aux_col5.dta", nogen
merge 1:1 n using "./output/tables/table_aux_col6.dta", nogen
merge 1:1 n using "./output/tables/table_aux_col7.dta", nogen
merge 1:1 n using "./output/tables/table_aux_col8.dta", nogen
drop n

*Define row names.
gen row_names=""
replace row_names="$ t$" 	in 1
replace row_names="" in 2
replace row_names="obs" 	in 3
replace row_names="$ t+1$" in 4
replace row_names="" in 5
replace row_names="obs" 	in 6
replace row_names="$ t+3$" in 7
replace row_names="" in 8
replace row_names="obs" 	in 9
replace row_names="$ t+5$" in 10
replace row_names="" in 11
replace row_names="obs" 	in 12
replace row_names="$ t+7$" in 13
replace row_names="" in 14
replace row_names="obs" 	in 15
replace row_names="$ t+10$" in 16
replace row_names="" in 17
replace row_names="obs" 	in 18
order row_names col*

*Define column names.
label var row_names ""
label var col1 "Baseline"
label var col2 "All Data / MFN Tariffs"
label var col3 "Top 5 Major Partners"
label var col4 "Quantities"
label var col5 "Unit Values"
label var col6 "Weighted"
label var col7 "SD1"
label var col8 "PTA"

*Export table.
texsave row_names col1 col2 col3 col4 col5 col6 col7 col8 using "./output/tables/table_4.tex", varlabels nofix noendash replace preamble("/usepackage{adjustbox}") geometry("a4paper, total={5.5in, 7.5in}") width("18cm")

//////////////
///Table B1///
//////////////

*Define horizon.
local num_horizon=17
	
	*Column 1.
	
	*Open results.
	use "./output/temp_files/iv_0_baseline_lp_tariffs_pre_l1.dta", clear
	gsort+horizon
	set obs 7
	append using "./output/temp_files/iv_0_baseline_lp_tariffs_l1.dta"

	*Generate p-value.
	gen pval=2*normal(-abs(b/se))
	
	*Generate stars vector.
	gen star=""
	replace star="***" if pval<=0.01
	replace star="**" if pval>0.01 & pval<=0.05
	replace star="*" if pval>0.05 & pval<=0.1
	
	*Generate coefficient and stars string vector.
	tostring b, replace force format(%9.2f)
	gen b_star=b+star
	
	*Convert variables to strings.
	tostring se, replace force format(%9.2f)
	replace se="("+se+")"
	
	*Keep variables.
	keep b_star se
	order b_star se
	replace se="." if b=="."
	
	*Generate results vector.
	gen results=""
	local maxobs=`num_horizon'*2
	set obs `maxobs'
	forvalues rrr=1(1)`num_horizon'{
		
		replace results=b_star[`rrr'] if _n==2*(`rrr'-1)+1
		replace results=se[`rrr'] if _n==2*(`rrr'-1)+2
		
	}
	
	*Rename results vector.
	keep results
	rename results col1
	
	*Save results.
	gen n=_n
	save "./output/tables/table_aux_col1.dta", replace
	
	*Column 2.
	
	*Open results.
	use "./output/temp_files/iv_0_baseline_lp_tariffs_pre.dta", clear
	gsort+horizon
	set obs 7
	append using "./output/temp_files/iv_0_baseline_lp_tariffs.dta"

	*Generate p-value.
	gen pval=2*normal(-abs(b/se))
	
	*Generate stars vector.
	gen star=""
	replace star="***" if pval<=0.01
	replace star="**" if pval>0.01 & pval<=0.05
	replace star="*" if pval>0.05 & pval<=0.1
	
	*Generate coefficient and stars string vector.
	tostring b, replace force format(%9.2f)
	gen b_star=b+star
	
	*Convert variables to strings.
	tostring se, replace force format(%9.2f)
	replace se="("+se+")"
	
	*Keep variables.
	keep b_star se
	order b_star se
	replace se="." if b=="."
	
	*Generate results vector.
	gen results=""
	local maxobs=`num_horizon'*2
	set obs `maxobs'
	forvalues rrr=1(1)`num_horizon'{
		
		replace results=b_star[`rrr'] if _n==2*(`rrr'-1)+1
		replace results=se[`rrr'] if _n==2*(`rrr'-1)+2
		
	}
	
	*Rename results vector.
	keep results
	rename results col2
	
	*Save results.
	gen n=_n
	save "./output/tables/table_aux_col2.dta", replace
	
	*Column 3.
	
	*Open results.
	use "./output/temp_files/iv_0_baseline_lp_tariffs_pre_l5.dta", clear
	gsort+horizon
	set obs 7
	append using "./output/temp_files/iv_0_baseline_lp_tariffs_l5.dta"

	*Generate p-value.
	gen pval=2*normal(-abs(b/se))
	
	*Generate stars vector.
	gen star=""
	replace star="***" if pval<=0.01
	replace star="**" if pval>0.01 & pval<=0.05
	replace star="*" if pval>0.05 & pval<=0.1
	
	*Generate coefficient and stars string vector.
	tostring b, replace force format(%9.2f)
	gen b_star=b+star
	
	*Convert variables to strings.
	tostring se, replace force format(%9.2f)
	replace se="("+se+")"
	
	*Keep variables.
	keep b_star se
	order b_star se
	replace se="." if b=="."
	
	*Generate results vector.
	gen results=""
	local maxobs=`num_horizon'*2
	set obs `maxobs'
	forvalues rrr=1(1)`num_horizon'{
		
		replace results=b_star[`rrr'] if _n==2*(`rrr'-1)+1
		replace results=se[`rrr'] if _n==2*(`rrr'-1)+2
		
	}
	
	*Rename results vector.
	keep results
	rename results col3
	
	*Save results.
	gen n=_n
	save "./output/tables/table_aux_col3.dta", replace
	
	*Column 4.
	
	*Open results.
	use "./output/temp_files/iv_0_baseline_lp_ln_trade_val_pre_l1.dta", clear
	gsort+horizon
	set obs 6
	append using "./output/temp_files/iv_0_baseline_lp_ln_trade_val_l1.dta"

	*Generate p-value.
	gen pval=2*normal(-abs(b/se))
	
	*Generate stars vector.
	gen star=""
	replace star="***" if pval<=0.01
	replace star="**" if pval>0.01 & pval<=0.05
	replace star="*" if pval>0.05 & pval<=0.1
	
	*Generate coefficient and stars string vector.
	tostring b, replace force format(%9.2f)
	gen b_star=b+star
	
	*Convert variables to strings.
	tostring se, replace force format(%9.2f)
	replace se="("+se+")"
	
	*Keep variables.
	keep b_star se
	order b_star se
	replace se="." if b=="."
	
	*Generate results vector.
	gen results=""
	local maxobs=`num_horizon'*2
	set obs `maxobs'
	forvalues rrr=1(1)`num_horizon'{
		
		replace results=b_star[`rrr'] if _n==2*(`rrr'-1)+1
		replace results=se[`rrr'] if _n==2*(`rrr'-1)+2
		
	}
	
	*Rename results vector.
	keep results
	rename results col4
	
	*Save results.
	gen n=_n
	save "./output/tables/table_aux_col4.dta", replace
	
	*Column 5.
	
	*Open results.
	use "./output/temp_files/iv_0_baseline_lp_ln_trade_val_pre.dta", clear
	gsort+horizon
	set obs 6
	append using "./output/temp_files/iv_0_baseline_lp_ln_trade_val.dta"

	*Generate p-value.
	gen pval=2*normal(-abs(b/se))
	
	*Generate stars vector.
	gen star=""
	replace star="***" if pval<=0.01
	replace star="**" if pval>0.01 & pval<=0.05
	replace star="*" if pval>0.05 & pval<=0.1
	
	*Generate coefficient and stars string vector.
	tostring b, replace force format(%9.2f)
	gen b_star=b+star
	
	*Convert variables to strings.
	tostring se, replace force format(%9.2f)
	replace se="("+se+")"
	
	*Keep variables.
	keep b_star se
	order b_star se
	replace se="." if b=="."
	
	*Generate results vector.
	gen results=""
	local maxobs=`num_horizon'*2
	set obs `maxobs'
	forvalues rrr=1(1)`num_horizon'{
		
		replace results=b_star[`rrr'] if _n==2*(`rrr'-1)+1
		replace results=se[`rrr'] if _n==2*(`rrr'-1)+2
		
	}
	
	*Rename results vector.
	keep results
	rename results col5
	
	*Save results.
	gen n=_n
	save "./output/tables/table_aux_col5.dta", replace
	
	*Column 6.
	
	*Open results.
	use "./output/temp_files/iv_0_baseline_lp_ln_trade_val_pre_l5.dta", clear
	gsort+horizon
	set obs 6
	append using "./output/temp_files/iv_0_baseline_lp_ln_trade_val_l5.dta"

	*Generate p-value.
	gen pval=2*normal(-abs(b/se))
	
	*Generate stars vector.
	gen star=""
	replace star="***" if pval<=0.01
	replace star="**" if pval>0.01 & pval<=0.05
	replace star="*" if pval>0.05 & pval<=0.1
	
	*Generate coefficient and stars string vector.
	tostring b, replace force format(%9.2f)
	gen b_star=b+star
	
	*Convert variables to strings.
	tostring se, replace force format(%9.2f)
	replace se="("+se+")"
	
	*Keep variables.
	keep b_star se
	order b_star se
	replace se="." if b=="."
	
	*Generate results vector.
	gen results=""
	local maxobs=`num_horizon'*2
	set obs `maxobs'
	forvalues rrr=1(1)`num_horizon'{
		
		replace results=b_star[`rrr'] if _n==2*(`rrr'-1)+1
		replace results=se[`rrr'] if _n==2*(`rrr'-1)+2
		
	}
	
	*Rename results vector.
	keep results
	rename results col6
	
	*Save results.
	gen n=_n
	save "./output/tables/table_aux_col6.dta", replace
	
*Merge results.
use "./output/tables/table_aux_col1.dta", clear
merge 1:1 n using "./output/tables/table_aux_col2.dta", nogen
merge 1:1 n using "./output/tables/table_aux_col3.dta", nogen
merge 1:1 n using "./output/tables/table_aux_col4.dta", nogen
merge 1:1 n using "./output/tables/table_aux_col5.dta", nogen
merge 1:1 n using "./output/tables/table_aux_col6.dta", nogen
drop n

*Define row names.
gen row_names=""
replace row_names="$ t-6$" in 1
replace row_names="" 	in 2
replace row_names="$ t-5$" in 3
replace row_names="" 	in 4
replace row_names="$ t-4$" in 5
replace row_names="" 	in 6
replace row_names="$ t-3$" in 7
replace row_names="" 	in 8
replace row_names="$ t-2$" in 9
replace row_names="" 	in 10
replace row_names="$ t-1$" in 11
replace row_names="" 	in 12
replace row_names="$ t$" 	in 13
replace row_names="" 	in 14
replace row_names="$ t+1$" in 15
replace row_names="" 	in 16
replace row_names="$ t+2$" in 17
replace row_names="" 	in 18
replace row_names="$ t+3$" in 19
replace row_names="" 	in 20
replace row_names="$ t+4$" in 21
replace row_names="" 	in 22
replace row_names="$ t+5$" in 23
replace row_names="" 	in 24
replace row_names="$ t+6$" in 25
replace row_names="" 	in 26
replace row_names="$ t+7$" in 27
replace row_names="" 	in 28
replace row_names="$ t+8$" in 29
replace row_names="" 	in 30
replace row_names="$ t+9$" in 31
replace row_names="" 	in 32
replace row_names="$ t+10$" in 33
replace row_names="" 	in 34

*Generate empty column
gen col_e=""

order row_names col1 col2 col3 col_e col4 col5 col6

*Define column names.
label var row_names ""
label var col1 "Baseline"
label var col2 "Zero Lags"
label var col3 "Five Lags"
label var col4 "Baseline"
label var col5 "Zero Lags"
label var col6 "Five Lags"

*Export table.
texsave row_names col1 col2 col3 col_e col4 col5 col6 using "./output/tables/table_b1.tex", varlabels nofix noendash replace preamble("/usepackage{adjustbox}") geometry("a4paper, total={5.5in, 7.5in}") width("18cm")

//////////////
///Table B2///
//////////////

*Define horizon.
local num_horizon=11

	*Column 1.

	*Open results.
	use "./output/temp_files/iv_0_baseline_elasticity_ln_trade_val_l1.dta", clear

	*Generate p-value.
	gen pval=2*normal(-abs(b/se))
	
	*Generate stars vector.
	gen star=""
	replace star="***" if pval<=0.01
	replace star="**" if pval>0.01 & pval<=0.05
	replace star="*" if pval>0.05 & pval<=0.1
	
	*Generate coefficient and stars string vector.
	tostring b, replace force format(%9.2f)
	gen b_star=b+star
	
	*Convert variables to strings.
	tostring se, replace force format(%9.2f)
	replace se="("+se+")"
	tostring F1, replace force format(%9.0f)
	
	*Keep variables.
	keep b_star se F1
	order b_star se F1
	
	*Generate results vector.
	gen results=""
	local maxobs=`num_horizon'*2
	set obs `maxobs'
	forvalues rrr=1(1)`num_horizon'{
		
		replace results=b_star[`rrr'] if _n==2*(`rrr'-1)+1
		replace results=se[`rrr'] if _n==2*(`rrr'-1)+2
		
	}
	
	*Generate F-value vector.
	gen F=""
	local maxobs=`num_horizon'*2
	set obs `maxobs'
	forvalues rrr=1(1)`num_horizon'{
		
		replace F=F1[`rrr'] if _n==2*(`rrr'-1)+1
		
	}
	
	*Rename results vector.
	keep results F
	rename (results F) (col1 F1)
	
	*Save results.
	gen n=_n
	save "./output/tables/table_aux_col1.dta", replace
	
	*Column 2.

	*Open results.
	use "./output/temp_files/iv_0_baseline_dl_elasticity_ln_trade_val.dta", clear
	drop b se
	rename (bcum secum) (b se)

	*Generate p-value.
	gen pval=2*normal(-abs(b/se))
	
	*Generate stars vector.
	gen star=""
	replace star="***" if pval<=0.01
	replace star="**" if pval>0.01 & pval<=0.05
	replace star="*" if pval>0.05 & pval<=0.1
	
	*Generate coefficient and stars string vector.
	tostring b, replace force format(%9.2f)
	gen b_star=b+star
	
	*Convert variables to strings.
	tostring se, replace force format(%9.2f)
	replace se="("+se+")"
	tostring SWF, replace force format(%9.0f)
	
	*Keep variables.
	keep b_star se SWF
	order b_star se SWF
	
	*Generate results vector.
	gen results=""
	local maxobs=`num_horizon'*2
	set obs `maxobs'
	forvalues rrr=1(1)`num_horizon'{
		
		replace results=b_star[`rrr'] if _n==2*(`rrr'-1)+1
		replace results=se[`rrr'] if _n==2*(`rrr'-1)+2
		
	}
	
	*Generate F-value vector.
	gen F=""
	local maxobs=`num_horizon'*2
	set obs `maxobs'
	forvalues rrr=1(1)`num_horizon'{
		
		replace F=SWF[`rrr'] if _n==2*(`rrr'-1)+1
		
	}
	
	*Rename results vector.
	keep results F
	rename (results F) (col2 F2)
	
	*Save results.
	gen n=_n
	save "./output/tables/table_aux_col2.dta", replace

*Merge results.
use "./output/tables/table_aux_col1.dta", clear
merge 1:1 n using "./output/tables/table_aux_col2.dta", nogen
drop n

*Define row names.
gen row_names=""
replace row_names="$ t$" 	in 1
replace row_names="" 	in 2
replace row_names="$ t+1$" in 3
replace row_names="" 	in 4
replace row_names="$ t+2$" in 5
replace row_names="" 	in 6
replace row_names="$ t+3$" in 7
replace row_names="" 	in 8
replace row_names="$ t+4$" in 9
replace row_names="" 	in 10
replace row_names="$ t+5$" in 11
replace row_names="" 	in 12
replace row_names="$ t+6$" in 13
replace row_names="" 	in 14
replace row_names="$ t+7$" in 15
replace row_names="" 	in 16
replace row_names="$ t+8$" in 17
replace row_names="" 	in 18
replace row_names="$ t+9$" in 19
replace row_names="" 	in 20
replace row_names="$ t+10$" in 21
replace row_names="" 	in 22

order row_names col1 F1 col2 F2

*Define column names.
label var row_names ""
label var col1 "Baseline IV"
label var F1 "F-stat"
label var col2 "Distributed Lag"
label var F2 "SW F-stat"

*Export table.
texsave row_names col1 F1 col2 F2 using "./output/tables/table_b2.tex", varlabels nofix noendash replace preamble("/usepackage{adjustbox}") geometry("a4paper, total={5.5in, 7.5in}") width("18cm")
	
//////////////
///Table B6///
//////////////

*Define horizon.
local num_horizon=11

	*Column 1.

	*Open results.
	use "./output/temp_files/iv_0_baseline_elasticity_ln_trade_val_l1.dta", clear

	*Keep selected horizons.
	keep if inlist(horizon, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10)

	*Generate p-value.
	gen pval=2*normal(-abs(b/se))

	*Generate observations in millions.
	replace obs=obs/1000000
	
	*Generate stars vector.
	gen star=""
	replace star="***" if pval<=0.01
	replace star="**" if pval>0.01 & pval<=0.05
	replace star="*" if pval>0.05 & pval<=0.1
	
	*Generate coefficient and stars string vector.
	tostring b, replace force format(%9.2f)
	gen b_star=b+star
	
	*Convert variables to strings.
	tostring se, replace force format(%9.2f)
	replace se="("+se+")"
	tostring obs, replace force format(%9.1f)
	
	*Keep variables.
	keep b_star se obs
	order b_star se obs
	
	*Generate results vector.
	gen results=""
	local maxobs=`num_horizon'*3
	set obs `maxobs'
	forvalues rrr=1(1)`num_horizon'{
		
		replace results=b_star[`rrr'] if _n==3*(`rrr'-1)+1
		replace results=se[`rrr'] if _n==3*(`rrr'-1)+2
		replace results=obs[`rrr'] if _n==3*(`rrr'-1)+3
		
	}
	
	*Rename results vector.
	keep results
	rename results col1
	
	*Save results.
	gen n=_n
	save "./output/tables/table_aux_col1.dta", replace
	
	*Column 2.

	*Open results.
	use "./output/temp_files/iv_0_baseline_elasticity_ln_trade_val.dta", clear

	*Keep selected horizons.
	keep if inlist(horizon, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10)

	*Generate p-value.
	gen pval=2*normal(-abs(b/se))

	*Generate observations in millions.
	replace obs=obs/1000000
	
	*Generate stars vector.
	gen star=""
	replace star="***" if pval<=0.01
	replace star="**" if pval>0.01 & pval<=0.05
	replace star="*" if pval>0.05 & pval<=0.1
	
	*Generate coefficient and stars string vector.
	tostring b, replace force format(%9.2f)
	gen b_star=b+star
	
	*Convert variables to strings.
	tostring se, replace force format(%9.2f)
	replace se="("+se+")"
	tostring obs, replace force format(%9.1f)
	
	*Keep variables.
	keep b_star se obs
	order b_star se obs
	
	*Generate results vector.
	gen results=""
	local maxobs=`num_horizon'*3
	set obs `maxobs'
	forvalues rrr=1(1)`num_horizon'{
		
		replace results=b_star[`rrr'] if _n==3*(`rrr'-1)+1
		replace results=se[`rrr'] if _n==3*(`rrr'-1)+2
		replace results=obs[`rrr'] if _n==3*(`rrr'-1)+3
		
	}
	
	*Rename results vector.
	keep results
	rename results col2
	
	*Save results.
	gen n=_n
	save "./output/tables/table_aux_col2.dta", replace
	
	*Column 3.

	*Open results.
	use "./output/temp_files/iv_0_baseline_elasticity_ln_trade_val_l5.dta", clear

	*Keep selected horizons.
	keep if inlist(horizon, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10)

	*Generate p-value.
	gen pval=2*normal(-abs(b/se))

	*Generate observations in millions.
	replace obs=obs/1000000
	
	*Generate stars vector.
	gen star=""
	replace star="***" if pval<=0.01
	replace star="**" if pval>0.01 & pval<=0.05
	replace star="*" if pval>0.05 & pval<=0.1
	
	*Generate coefficient and stars string vector.
	tostring b, replace force format(%9.2f)
	gen b_star=b+star
	
	*Convert variables to strings.
	tostring se, replace force format(%9.2f)
	replace se="("+se+")"
	tostring obs, replace force format(%9.1f)
	
	*Keep variables.
	keep b_star se obs
	order b_star se obs
	
	*Generate results vector.
	gen results=""
	local maxobs=`num_horizon'*3
	set obs `maxobs'
	forvalues rrr=1(1)`num_horizon'{
		
		replace results=b_star[`rrr'] if _n==3*(`rrr'-1)+1
		replace results=se[`rrr'] if _n==3*(`rrr'-1)+2
		replace results=obs[`rrr'] if _n==3*(`rrr'-1)+3
		
	}
	
	*Rename results vector.
	keep results
	rename results col3
	
	*Save results.
	gen n=_n
	save "./output/tables/table_aux_col3.dta", replace
	
	*Column 4.

	*Open results.
	use "./output/temp_files/iv_0_baseline_elasticity_ln_trade_val_FE50_lags1.dta", clear

	*Keep selected horizons.
	keep if inlist(horizon, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10)

	*Generate p-value.
	gen pval=2*normal(-abs(b/se))

	*Generate observations in millions.
	replace obs=obs/1000000
	
	*Generate stars vector.
	gen star=""
	replace star="***" if pval<=0.01
	replace star="**" if pval>0.01 & pval<=0.05
	replace star="*" if pval>0.05 & pval<=0.1
	
	*Generate coefficient and stars string vector.
	tostring b, replace force format(%9.2f)
	gen b_star=b+star
	
	*Convert variables to strings.
	tostring se, replace force format(%9.2f)
	replace se="("+se+")"
	tostring obs, replace force format(%9.1f)
	
	*Keep variables.
	keep b_star se obs
	order b_star se obs
	
	*Generate results vector.
	gen results=""
	local maxobs=`num_horizon'*3
	set obs `maxobs'
	forvalues rrr=1(1)`num_horizon'{
		
		replace results=b_star[`rrr'] if _n==3*(`rrr'-1)+1
		replace results=se[`rrr'] if _n==3*(`rrr'-1)+2
		replace results=obs[`rrr'] if _n==3*(`rrr'-1)+3
		
	}
	
	*Rename results vector.
	keep results
	rename results col4
	
	*Save results.
	gen n=_n
	save "./output/tables/table_aux_col4.dta", replace
	
	*Column 5.

	*Open results.
	use "./output/temp_files/iv_0_baseline_elasticity_ln_trade_val_SE2_lags1.dta", clear

	*Keep selected horizons.
	keep if inlist(horizon, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10)

	*Generate p-value.
	gen pval=2*normal(-abs(b/se))

	*Generate observations in millions.
	replace obs=obs/1000000
	
	*Generate stars vector.
	gen star=""
	replace star="***" if pval<=0.01
	replace star="**" if pval>0.01 & pval<=0.05
	replace star="*" if pval>0.05 & pval<=0.1
	
	*Generate coefficient and stars string vector.
	tostring b, replace force format(%9.2f)
	gen b_star=b+star
	
	*Convert variables to strings.
	tostring se, replace force format(%9.2f)
	replace se="("+se+")"
	tostring obs, replace force format(%9.1f)
	
	*Keep variables.
	keep b_star se obs
	order b_star se obs
	
	*Generate results vector.
	gen results=""
	local maxobs=`num_horizon'*3
	set obs `maxobs'
	forvalues rrr=1(1)`num_horizon'{
		
		replace results=b_star[`rrr'] if _n==3*(`rrr'-1)+1
		replace results=se[`rrr'] if _n==3*(`rrr'-1)+2
		replace results=obs[`rrr'] if _n==3*(`rrr'-1)+3
		
	}
	
	*Rename results vector.
	keep results
	rename results col5
	
	*Save results.
	gen n=_n
	save "./output/tables/table_aux_col5.dta", replace
	
	*Column 6.

	*Open results.
	use "./output/temp_files/iv_0_baseline_elasticity_ln_trade_val_bp_lags1.dta", clear

	*Keep selected horizons.
	keep if inlist(horizon, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10)

	*Generate p-value.
	gen pval=2*normal(-abs(b/se))

	*Generate observations in millions.
	replace obs=obs/1000000
	
	*Generate stars vector.
	gen star=""
	replace star="***" if pval<=0.01
	replace star="**" if pval>0.01 & pval<=0.05
	replace star="*" if pval>0.05 & pval<=0.1
	
	*Generate coefficient and stars string vector.
	tostring b, replace force format(%9.2f)
	gen b_star=b+star
	
	*Convert variables to strings.
	tostring se, replace force format(%9.2f)
	replace se="("+se+")"
	tostring obs, replace force format(%9.1f)
	
	*Keep variables.
	keep b_star se obs
	order b_star se obs
	
	*Generate results vector.
	gen results=""
	local maxobs=`num_horizon'*3
	set obs `maxobs'
	forvalues rrr=1(1)`num_horizon'{
		
		replace results=b_star[`rrr'] if _n==3*(`rrr'-1)+1
		replace results=se[`rrr'] if _n==3*(`rrr'-1)+2
		replace results=obs[`rrr'] if _n==3*(`rrr'-1)+3
		
	}
	
	*Rename results vector.
	keep results
	rename results col6
	
	*Save results.
	gen n=_n
	save "./output/tables/table_aux_col6.dta", replace
	
	*Column 7.

	*Open results.
	use "./output/temp_files/iv_0_baseline_elasticity_ln_trade_val_Ctrl0_lags1.dta", clear

	*Keep selected horizons.
	keep if inlist(horizon, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10)

	*Generate p-value.
	gen pval=2*normal(-abs(b/se))

	*Generate observations in millions.
	replace obs=obs/1000000
	
	*Generate stars vector.
	gen star=""
	replace star="***" if pval<=0.01
	replace star="**" if pval>0.01 & pval<=0.05
	replace star="*" if pval>0.05 & pval<=0.1
	
	*Generate coefficient and stars string vector.
	tostring b, replace force format(%9.2f)
	gen b_star=b+star
	
	*Convert variables to strings.
	tostring se, replace force format(%9.2f)
	replace se="("+se+")"
	tostring obs, replace force format(%9.1f)
	
	*Keep variables.
	keep b_star se obs
	order b_star se obs
	
	*Generate results vector.
	gen results=""
	local maxobs=`num_horizon'*3
	set obs `maxobs'
	forvalues rrr=1(1)`num_horizon'{
		
		replace results=b_star[`rrr'] if _n==3*(`rrr'-1)+1
		replace results=se[`rrr'] if _n==3*(`rrr'-1)+2
		replace results=obs[`rrr'] if _n==3*(`rrr'-1)+3
		
	}
	
	*Rename results vector.
	keep results
	rename results col7
	
	*Save results.
	gen n=_n
	save "./output/tables/table_aux_col7.dta", replace
	
	*Column 8.

	*Open results.
	use "./output/temp_files/iv_0_baseline_elasticity_ln_trade_val_ext_lags0.dta", clear

	*Keep selected horizons.
	keep if inlist(horizon, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10)

	*Generate p-value.
	gen pval=2*normal(-abs(b/se))

	*Generate observations in millions.
	replace obs=obs/1000000
	
	*Generate stars vector.
	gen star=""
	replace star="***" if pval<=0.01
	replace star="**" if pval>0.01 & pval<=0.05
	replace star="*" if pval>0.05 & pval<=0.1
	
	*Generate coefficient and stars string vector.
	tostring b, replace force format(%9.2f)
	gen b_star=b+star
	
	*Convert variables to strings.
	tostring se, replace force format(%9.2f)
	replace se="("+se+")"
	tostring obs, replace force format(%9.1f)
	
	*Keep variables.
	keep b_star se obs
	order b_star se obs
	
	*Generate results vector.
	gen results=""
	local maxobs=`num_horizon'*3
	set obs `maxobs'
	forvalues rrr=1(1)`num_horizon'{
		
		replace results=b_star[`rrr'] if _n==3*(`rrr'-1)+1
		replace results=se[`rrr'] if _n==3*(`rrr'-1)+2
		replace results=obs[`rrr'] if _n==3*(`rrr'-1)+3
		
	}
	
	*Rename results vector.
	keep results
	rename results col8
	
	*Save results.
	gen n=_n
	save "./output/tables/table_aux_col8.dta", replace
	
	*Column 9.

	*Open results.
	use "./output/temp_files/iv_0_baseline_elasticity_ln_trade_val_ext_sel_lags0.dta", clear

	*Keep selected horizons.
	keep if inlist(horizon, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10)

	*Generate p-value.
	gen pval=2*normal(-abs(b/se))

	*Generate observations in millions.
	replace obs=obs/1000000
	
	*Generate stars vector.
	gen star=""
	replace star="***" if pval<=0.01
	replace star="**" if pval>0.01 & pval<=0.05
	replace star="*" if pval>0.05 & pval<=0.1
	
	*Generate coefficient and stars string vector.
	tostring b, replace force format(%9.2f)
	gen b_star=b+star
	
	*Convert variables to strings.
	tostring se, replace force format(%9.2f)
	replace se="("+se+")"
	tostring obs, replace force format(%9.1f)
	
	*Keep variables.
	keep b_star se obs
	order b_star se obs
	
	*Generate results vector.
	gen results=""
	local maxobs=`num_horizon'*3
	set obs `maxobs'
	forvalues rrr=1(1)`num_horizon'{
		
		replace results=b_star[`rrr'] if _n==3*(`rrr'-1)+1
		replace results=se[`rrr'] if _n==3*(`rrr'-1)+2
		replace results=obs[`rrr'] if _n==3*(`rrr'-1)+3
		
	}
	
	*Rename results vector.
	keep results
	rename results col9
	
	*Save results.
	gen n=_n
	save "./output/tables/table_aux_col9.dta", replace
	
*Merge results.
use "./output/tables/table_aux_col1.dta", clear
merge 1:1 n using "./output/tables/table_aux_col2.dta", nogen
merge 1:1 n using "./output/tables/table_aux_col3.dta", nogen
merge 1:1 n using "./output/tables/table_aux_col4.dta", nogen
merge 1:1 n using "./output/tables/table_aux_col5.dta", nogen
merge 1:1 n using "./output/tables/table_aux_col6.dta", nogen
merge 1:1 n using "./output/tables/table_aux_col7.dta", nogen
merge 1:1 n using "./output/tables/table_aux_col8.dta", nogen
merge 1:1 n using "./output/tables/table_aux_col9.dta", nogen
drop n

*Define row names.
gen row_names=""
replace row_names="$ t$" 	in 1
replace row_names="" in 2
replace row_names="obs" 	in 3
replace row_names="$ t+1$" in 4
replace row_names="" in 5
replace row_names="obs" 	in 6
replace row_names="$ t+2$" in 7
replace row_names="" in 8
replace row_names="obs" 	in 9
replace row_names="$ t+3$" in 10
replace row_names="" in 11
replace row_names="obs" 	in 12
replace row_names="$ t+4$" in 13
replace row_names="" in 14
replace row_names="obs" 	in 15
replace row_names="$ t+5$" in 16
replace row_names="" in 17
replace row_names="obs" 	in 18
replace row_names="$ t+6$" in 19
replace row_names="" in 20
replace row_names="obs" 	in 21
replace row_names="$ t+7$" in 22
replace row_names="" in 23
replace row_names="obs" 	in 24
replace row_names="$ t+8$" in 25
replace row_names="" in 26
replace row_names="obs" 	in 27
replace row_names="$ t+9$" in 28
replace row_names="" in 29
replace row_names="obs" 	in 30
replace row_names="$ t+10$" in 31
replace row_names="" in 32
replace row_names="obs" 	in 33

order row_names col*

*Define column names.
label var row_names ""
label var col1 "Baseline"
label var col2 "Zero Lags"
label var col3 "Five Lags"
label var col4 "FE50"
label var col5 "Two-way Clustering"
label var col6 "Constant Sample"
label var col7 "Alternative Control Group"
label var col8 "Extensive"
label var col9 "Extensive Sel."

*Export table.
texsave row_names col1 col2 col3 col4 col5 col6 col7 col8 col9 using "./output/tables/table_b6.tex", varlabels nofix noendash replace preamble("/usepackage{adjustbox}") geometry("a4paper, total={5.5in, 7.5in}") width("18cm")

///////////////
///Table B7///
///////////////

*Define horizon.
local num_horizon=11

	*Column 1.

	*Open results.
	use "./output/temp_files/iv_0_baseline_elasticity_ln_trade_val_l1.dta", clear

	*Keep selected horizons.
	keep if inlist(horizon, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10)

	*Generate p-value.
	gen pval=2*normal(-abs(b/se))

	*Generate observations in millions.
	replace obs=obs/1000000
	
	*Generate stars vector.
	gen star=""
	replace star="***" if pval<=0.01
	replace star="**" if pval>0.01 & pval<=0.05
	replace star="*" if pval>0.05 & pval<=0.1
	
	*Generate coefficient and stars string vector.
	tostring b, replace force format(%9.2f)
	gen b_star=b+star
	
	*Convert variables to strings.
	tostring se, replace force format(%9.2f)
	replace se="("+se+")"
	tostring obs, replace force format(%9.1f)
	
	*Keep variables.
	keep b_star se obs
	order b_star se obs
	
	*Generate results vector.
	gen results=""
	local maxobs=`num_horizon'*3
	set obs `maxobs'
	forvalues rrr=1(1)`num_horizon'{
		
		replace results=b_star[`rrr'] if _n==3*(`rrr'-1)+1
		replace results=se[`rrr'] if _n==3*(`rrr'-1)+2
		replace results=obs[`rrr'] if _n==3*(`rrr'-1)+3
		
	}
	
	*Rename results vector.
	keep results
	rename results col1
	
	*Save results.
	gen n=_n
	save "./output/tables/table_aux_col1.dta", replace
	
	*Column 2.

	*Open results.
	use "./output/temp_files/iv_0_did_elasticity_ln_trade_val_l1.dta", clear

	*Keep selected horizons.
	keep if inlist(horizon, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10)

	*Generate p-value.
	gen pval=2*normal(-abs(b/se))

	*Generate observations in millions.
	replace obs=obs/1000000
	
	*Generate stars vector.
	gen star=""
	replace star="***" if pval<=0.01
	replace star="**" if pval>0.01 & pval<=0.05
	replace star="*" if pval>0.05 & pval<=0.1
	
	*Generate coefficient and stars string vector.
	tostring b, replace force format(%9.2f)
	gen b_star=b+star
	
	*Convert variables to strings.
	tostring se, replace force format(%9.2f)
	replace se="("+se+")"
	tostring obs, replace force format(%9.1f)
	
	*Keep variables.
	keep b_star se obs
	order b_star se obs
	
	*Generate results vector.
	gen results=""
	local maxobs=`num_horizon'*3
	set obs `maxobs'
	forvalues rrr=1(1)`num_horizon'{
		
		replace results=b_star[`rrr'] if _n==3*(`rrr'-1)+1
		replace results=se[`rrr'] if _n==3*(`rrr'-1)+2
		replace results=obs[`rrr'] if _n==3*(`rrr'-1)+3
		
	}
	
	*Rename results vector.
	keep results
	rename results col2
	
	*Save results.
	gen n=_n
	save "./output/tables/table_aux_col2.dta", replace
	
	*Column 3.

	*Open results.
	use "./output/temp_files/iv_0_top5_elasticity_ln_trade_val_lags1.dta", clear

	*Keep selected horizons.
	keep if inlist(horizon, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10)

	*Generate p-value.
	gen pval=2*normal(-abs(b/se))

	*Generate observations in millions.
	replace obs=obs/1000000
	
	*Generate stars vector.
	gen star=""
	replace star="***" if pval<=0.01
	replace star="**" if pval>0.01 & pval<=0.05
	replace star="*" if pval>0.05 & pval<=0.1
	
	*Generate coefficient and stars string vector.
	tostring b, replace force format(%9.2f)
	gen b_star=b+star
	
	*Convert variables to strings.
	tostring se, replace force format(%9.2f)
	replace se="("+se+")"
	tostring obs, replace force format(%9.1f)
	
	*Keep variables.
	keep b_star se obs
	order b_star se obs
	
	*Generate results vector.
	gen results=""
	local maxobs=`num_horizon'*3
	set obs `maxobs'
	forvalues rrr=1(1)`num_horizon'{
		
		replace results=b_star[`rrr'] if _n==3*(`rrr'-1)+1
		replace results=se[`rrr'] if _n==3*(`rrr'-1)+2
		replace results=obs[`rrr'] if _n==3*(`rrr'-1)+3
		
	}
	
	*Rename results vector.
	keep results
	rename results col3
	
	*Save results.
	gen n=_n
	save "./output/tables/table_aux_col3.dta", replace
	
	*Column 4.

	*Open results.
	use "./output/temp_files/iv_0_baseline_elasticity_ln_quantity_l1.dta", clear

	*Keep selected horizons.
	keep if inlist(horizon, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10)

	*Generate p-value.
	gen pval=2*normal(-abs(b/se))

	*Generate observations in millions.
	replace obs=obs/1000000
	
	*Generate stars vector.
	gen star=""
	replace star="***" if pval<=0.01
	replace star="**" if pval>0.01 & pval<=0.05
	replace star="*" if pval>0.05 & pval<=0.1
	
	*Generate coefficient and stars string vector.
	tostring b, replace force format(%9.2f)
	gen b_star=b+star
	
	*Convert variables to strings.
	tostring se, replace force format(%9.2f)
	replace se="("+se+")"
	tostring obs, replace force format(%9.1f)
	
	*Keep variables.
	keep b_star se obs
	order b_star se obs
	
	*Generate results vector.
	gen results=""
	local maxobs=`num_horizon'*3
	set obs `maxobs'
	forvalues rrr=1(1)`num_horizon'{
		
		replace results=b_star[`rrr'] if _n==3*(`rrr'-1)+1
		replace results=se[`rrr'] if _n==3*(`rrr'-1)+2
		replace results=obs[`rrr'] if _n==3*(`rrr'-1)+3
		
	}
	
	*Rename results vector.
	keep results
	rename results col4
	
	*Save results.
	gen n=_n
	save "./output/tables/table_aux_col4.dta", replace
	
	*Column 5.

	*Open results.
	use "./output/temp_files/iv_0_baseline_elasticity_ln_uv_l1.dta", clear

	*Keep selected horizons.
	keep if inlist(horizon, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10)

	*Generate p-value.
	gen pval=2*normal(-abs(b/se))

	*Generate observations in millions.
	replace obs=obs/1000000
	
	*Generate stars vector.
	gen star=""
	replace star="***" if pval<=0.01
	replace star="**" if pval>0.01 & pval<=0.05
	replace star="*" if pval>0.05 & pval<=0.1
	
	*Generate coefficient and stars string vector.
	tostring b, replace force format(%9.2f)
	gen b_star=b+star
	
	*Convert variables to strings.
	tostring se, replace force format(%9.2f)
	replace se="("+se+")"
	tostring obs, replace force format(%9.1f)
	
	*Keep variables.
	keep b_star se obs
	order b_star se obs
	
	*Generate results vector.
	gen results=""
	local maxobs=`num_horizon'*3
	set obs `maxobs'
	forvalues rrr=1(1)`num_horizon'{
		
		replace results=b_star[`rrr'] if _n==3*(`rrr'-1)+1
		replace results=se[`rrr'] if _n==3*(`rrr'-1)+2
		replace results=obs[`rrr'] if _n==3*(`rrr'-1)+3
		
	}
	
	*Rename results vector.
	keep results
	rename results col5
	
	*Save results.
	gen n=_n
	save "./output/tables/table_aux_col5.dta", replace
	
	*Column 6.

	*Open results.
	use "./output/temp_files/iv_0_baseline_elasticity_ln_trade_val_lnwt_lags1.dta", clear

	*Keep selected horizons.
	keep if inlist(horizon, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10)

	*Generate p-value.
	gen pval=2*normal(-abs(b/se))

	*Generate observations in millions.
	replace obs=obs/1000000
	
	*Generate stars vector.
	gen star=""
	replace star="***" if pval<=0.01
	replace star="**" if pval>0.01 & pval<=0.05
	replace star="*" if pval>0.05 & pval<=0.1
	
	*Generate coefficient and stars string vector.
	tostring b, replace force format(%9.2f)
	gen b_star=b+star
	
	*Convert variables to strings.
	tostring se, replace force format(%9.2f)
	replace se="("+se+")"
	tostring obs, replace force format(%9.1f)
	
	*Keep variables.
	keep b_star se obs
	order b_star se obs
	
	*Generate results vector.
	gen results=""
	local maxobs=`num_horizon'*3
	set obs `maxobs'
	forvalues rrr=1(1)`num_horizon'{
		
		replace results=b_star[`rrr'] if _n==3*(`rrr'-1)+1
		replace results=se[`rrr'] if _n==3*(`rrr'-1)+2
		replace results=obs[`rrr'] if _n==3*(`rrr'-1)+3
		
	}
	
	*Rename results vector.
	keep results
	rename results col6
	
	*Save results.
	gen n=_n
	save "./output/tables/table_aux_col6.dta", replace
	
	*Column 7.

	*Open results.
	use "./output/temp_files/iv_0_baseline_elasticity_ln_trade_val_SD0_lags1.dta", clear

	*Keep selected horizons.
	keep if inlist(horizon, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10)

	*Generate p-value.
	gen pval=2*normal(-abs(b/se))

	*Generate observations in millions.
	replace obs=obs/1000000
	
	*Generate stars vector.
	gen star=""
	replace star="***" if pval<=0.01
	replace star="**" if pval>0.01 & pval<=0.05
	replace star="*" if pval>0.05 & pval<=0.1
	
	*Generate coefficient and stars string vector.
	tostring b, replace force format(%9.2f)
	gen b_star=b+star
	
	*Convert variables to strings.
	tostring se, replace force format(%9.2f)
	replace se="("+se+")"
	tostring obs, replace force format(%9.1f)
	
	*Keep variables.
	keep b_star se obs
	order b_star se obs
	
	*Generate results vector.
	gen results=""
	local maxobs=`num_horizon'*3
	set obs `maxobs'
	forvalues rrr=1(1)`num_horizon'{
		
		replace results=b_star[`rrr'] if _n==3*(`rrr'-1)+1
		replace results=se[`rrr'] if _n==3*(`rrr'-1)+2
		replace results=obs[`rrr'] if _n==3*(`rrr'-1)+3
		
	}
	
	*Rename results vector.
	keep results
	rename results col7
	
	*Save results.
	gen n=_n
	save "./output/tables/table_aux_col7.dta", replace
	
	*Column 8.

	*Open results.
	use "./output/temp_files/iv_0_PTA_elasticity_ln_trade_val_PTA_lags1.dta", clear

	*Keep selected horizons.
	keep if inlist(horizon, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10)

	*Generate p-value.
	gen pval=2*normal(-abs(b/se))

	*Generate observations in millions.
	replace obs=obs/1000000
	
	*Generate stars vector.
	gen star=""
	replace star="***" if pval<=0.01
	replace star="**" if pval>0.01 & pval<=0.05
	replace star="*" if pval>0.05 & pval<=0.1
	
	*Generate coefficient and stars string vector.
	tostring b, replace force format(%9.2f)
	gen b_star=b+star
	
	*Convert variables to strings.
	tostring se, replace force format(%9.2f)
	replace se="("+se+")"
	tostring obs, replace force format(%9.1f)
	
	*Keep variables.
	keep b_star se obs
	order b_star se obs
	
	*Generate results vector.
	gen results=""
	local maxobs=`num_horizon'*3
	set obs `maxobs'
	forvalues rrr=1(1)`num_horizon'{
		
		replace results=b_star[`rrr'] if _n==3*(`rrr'-1)+1
		replace results=se[`rrr'] if _n==3*(`rrr'-1)+2
		replace results=obs[`rrr'] if _n==3*(`rrr'-1)+3
		
	}
	
	*Rename results vector.
	keep results
	rename results col8
	
	*Save results.
	gen n=_n
	save "./output/tables/table_aux_col8.dta", replace
	
	*Column 9.

	*Open results.
	use "./output/temp_files/iv_0_baseline_TTB_elasticity_ln_trade_val_lags1.dta", clear

	*Keep selected horizons.
	keep if inlist(horizon, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10)

	*Generate p-value.
	gen pval=2*normal(-abs(b/se))

	*Generate observations in millions.
	replace obs=obs/1000000
	
	*Generate stars vector.
	gen star=""
	replace star="***" if pval<=0.01
	replace star="**" if pval>0.01 & pval<=0.05
	replace star="*" if pval>0.05 & pval<=0.1
	
	*Generate coefficient and stars string vector.
	tostring b, replace force format(%9.2f)
	gen b_star=b+star
	
	*Convert variables to strings.
	tostring se, replace force format(%9.2f)
	replace se="("+se+")"
	tostring obs, replace force format(%9.1f)
	
	*Keep variables.
	keep b_star se obs
	order b_star se obs
	
	*Generate results vector.
	gen results=""
	local maxobs=`num_horizon'*3
	set obs `maxobs'
	forvalues rrr=1(1)`num_horizon'{
		
		replace results=b_star[`rrr'] if _n==3*(`rrr'-1)+1
		replace results=se[`rrr'] if _n==3*(`rrr'-1)+2
		replace results=obs[`rrr'] if _n==3*(`rrr'-1)+3
		
	}
	
	*Rename results vector.
	keep results
	rename results col9
	
	*Save results.
	gen n=_n
	save "./output/tables/table_aux_col9.dta", replace
	
*Merge results.
use "./output/tables/table_aux_col1.dta", clear
merge 1:1 n using "./output/tables/table_aux_col2.dta", nogen
merge 1:1 n using "./output/tables/table_aux_col3.dta", nogen
merge 1:1 n using "./output/tables/table_aux_col4.dta", nogen
merge 1:1 n using "./output/tables/table_aux_col5.dta", nogen
merge 1:1 n using "./output/tables/table_aux_col6.dta", nogen
merge 1:1 n using "./output/tables/table_aux_col7.dta", nogen
merge 1:1 n using "./output/tables/table_aux_col8.dta", nogen
merge 1:1 n using "./output/tables/table_aux_col9.dta", nogen
drop n

*Define row names.
gen row_names=""
replace row_names="$ t$" 	in 1
replace row_names="" in 2
replace row_names="obs" 	in 3
replace row_names="$ t+1$" in 4
replace row_names="" in 5
replace row_names="obs" 	in 6
replace row_names="$ t+2$" in 7
replace row_names="" in 8
replace row_names="obs" 	in 9
replace row_names="$ t+3$" in 10
replace row_names="" in 11
replace row_names="obs" 	in 12
replace row_names="$ t+4$" in 13
replace row_names="" in 14
replace row_names="obs" 	in 15
replace row_names="$ t+5$" in 16
replace row_names="" in 17
replace row_names="obs" 	in 18
replace row_names="$ t+6$" in 19
replace row_names="" in 20
replace row_names="obs" 	in 21
replace row_names="$ t+7$" in 22
replace row_names="" in 23
replace row_names="obs" 	in 24
replace row_names="$ t+8$" in 25
replace row_names="" in 26
replace row_names="obs" 	in 27
replace row_names="$ t+9$" in 28
replace row_names="" in 29
replace row_names="obs" 	in 30
replace row_names="$ t+10$" in 31
replace row_names="" in 32
replace row_names="obs" 	in 33

order row_names col*

*Define column names.
label var row_names ""
label var col1 "Baseline"
label var col2 "All Data / MFN Tariffs"
label var col3 "Top 5 Major Partners"
label var col4 "Quantities"
label var col5 "Unit Values"
label var col6 "Weighted"
label var col7 "SD1"
label var col8 "PTA"
label var col9 "TTB"

*Export table.
texsave row_names col1 col2 col3 col4 col5 col6 col7 col8 col9 using "./output/tables/table_b7.tex", varlabels nofix noendash replace preamble("/usepackage{adjustbox}") geometry("a4paper, total={5.5in, 7.5in}") width("18cm")

///////////////
///Table B8///
///////////////


*Define horizon.
local num_horizon=11

	*Column 1.

	*Open results.
	use "./output/temp_files/OLS_ln_trade_val_ur_lags1.dta", clear

	*Keep selected horizons.
	keep if inlist(horizon, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10)

	*Generate p-value.
	gen pval=2*normal(-abs(b/se))

	*Generate observations in millions.
	replace obs=obs/1000000
	
	*Generate stars vector.
	gen star=""
	replace star="***" if pval<=0.01
	replace star="**" if pval>0.01 & pval<=0.05
	replace star="*" if pval>0.05 & pval<=0.1
	
	*Generate coefficient and stars string vector.
	tostring b, replace force format(%9.2f)
	gen b_star=b+star
	
	*Convert variables to strings.
	tostring se, replace force format(%9.2f)
	replace se="("+se+")"
	tostring obs, replace force format(%9.1f)
	
	*Keep variables.
	keep b_star se obs
	order b_star se obs
	
	*Generate results vector.
	gen results=""
	local maxobs=`num_horizon'*3
	set obs `maxobs'
	forvalues rrr=1(1)`num_horizon'{
		
		replace results=b_star[`rrr'] if _n==3*(`rrr'-1)+1
		replace results=se[`rrr'] if _n==3*(`rrr'-1)+2
		replace results=obs[`rrr'] if _n==3*(`rrr'-1)+3
		
	}
	
	*Rename results vector.
	keep results
	rename results col1
	
	*Save results.
	gen n=_n
	save "./output/tables/table_aux_col1.dta", replace
	
	*Column 2.

	*Open results.
	use "./output/temp_files/iv_0_baseline_elasticity_ln_trade_val_ur_lags1.dta", clear

	*Keep selected horizons.
	keep if inlist(horizon, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10)

	*Generate p-value.
	gen pval=2*normal(-abs(b/se))

	*Generate observations in millions.
	replace obs=obs/1000000
	
	*Generate stars vector.
	gen star=""
	replace star="***" if pval<=0.01
	replace star="**" if pval>0.01 & pval<=0.05
	replace star="*" if pval>0.05 & pval<=0.1
	
	*Generate coefficient and stars string vector.
	tostring b, replace force format(%9.2f)
	gen b_star=b+star
	
	*Convert variables to strings.
	tostring se, replace force format(%9.2f)
	replace se="("+se+")"
	tostring obs, replace force format(%9.1f)
	
	*Keep variables.
	keep b_star se obs
	order b_star se obs
	
	*Generate results vector.
	gen results=""
	local maxobs=`num_horizon'*3
	set obs `maxobs'
	forvalues rrr=1(1)`num_horizon'{
		
		replace results=b_star[`rrr'] if _n==3*(`rrr'-1)+1
		replace results=se[`rrr'] if _n==3*(`rrr'-1)+2
		replace results=obs[`rrr'] if _n==3*(`rrr'-1)+3
		
	}
	
	*Rename results vector.
	keep results
	rename results col2
	
	*Save results.
	gen n=_n
	save "./output/tables/table_aux_col2.dta", replace
	
	*Column 3.

	*Open results.
	use "./output/temp_files/OLS_ln_trade_val_FE6_lags1.dta", clear

	*Keep selected horizons.
	keep if inlist(horizon, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10)

	*Generate p-value.
	gen pval=2*normal(-abs(b/se))

	*Generate observations in millions.
	replace obs=obs/1000000
	
	*Generate stars vector.
	gen star=""
	replace star="***" if pval<=0.01
	replace star="**" if pval>0.01 & pval<=0.05
	replace star="*" if pval>0.05 & pval<=0.1
	
	*Generate coefficient and stars string vector.
	tostring b, replace force format(%9.2f)
	gen b_star=b+star
	
	*Convert variables to strings.
	tostring se, replace force format(%9.2f)
	replace se="("+se+")"
	tostring obs, replace force format(%9.1f)
	
	*Keep variables.
	keep b_star se obs
	order b_star se obs
	
	*Generate results vector.
	gen results=""
	local maxobs=`num_horizon'*3
	set obs `maxobs'
	forvalues rrr=1(1)`num_horizon'{
		
		replace results=b_star[`rrr'] if _n==3*(`rrr'-1)+1
		replace results=se[`rrr'] if _n==3*(`rrr'-1)+2
		replace results=obs[`rrr'] if _n==3*(`rrr'-1)+3
		
	}
	
	*Rename results vector.
	keep results
	rename results col3
	
	*Save results.
	gen n=_n
	save "./output/tables/table_aux_col3.dta", replace
	
	*Column 4.

	*Open results.
	use "./output/temp_files/iv_0_baseline_elasticity_ln_trade_val_lags1_MRT6_BIL0.dta", clear

	*Keep selected horizons.
	keep if inlist(horizon, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10)

	*Generate p-value.
	gen pval=2*normal(-abs(b/se))

	*Generate observations in millions.
	replace obs=obs/1000000
	
	*Generate stars vector.
	gen star=""
	replace star="***" if pval<=0.01
	replace star="**" if pval>0.01 & pval<=0.05
	replace star="*" if pval>0.05 & pval<=0.1
	
	*Generate coefficient and stars string vector.
	tostring b, replace force format(%9.2f)
	gen b_star=b+star
	
	*Convert variables to strings.
	tostring se, replace force format(%9.2f)
	replace se="("+se+")"
	tostring obs, replace force format(%9.1f)
	
	*Keep variables.
	keep b_star se obs
	order b_star se obs
	
	*Generate results vector.
	gen results=""
	local maxobs=`num_horizon'*3
	set obs `maxobs'
	forvalues rrr=1(1)`num_horizon'{
		
		replace results=b_star[`rrr'] if _n==3*(`rrr'-1)+1
		replace results=se[`rrr'] if _n==3*(`rrr'-1)+2
		replace results=obs[`rrr'] if _n==3*(`rrr'-1)+3
		
	}
	
	*Rename results vector.
	keep results
	rename results col4
	
	*Save results.
	gen n=_n
	save "./output/tables/table_aux_col4.dta", replace
	
	*Column 5.

	*Open results.
	use "./output/temp_files/iv_0_baseline_dl_elasticity_ln_trade_val.dta", clear
	drop b se
	rename (bcum secum) (b se)

	*Generate p-value.
	gen pval=2*normal(-abs(b/se))

	*Generate observations in millions.
	qui sum obs
	replace obs=`r(mean)' if obs==.
	replace obs=obs/1000000
	
	*Generate stars vector.
	gen star=""
	replace star="***" if pval<=0.01
	replace star="**" if pval>0.01 & pval<=0.05
	replace star="*" if pval>0.05 & pval<=0.1
	
	*Generate coefficient and stars string vector.
	tostring b, replace force format(%9.2f)
	gen b_star=b+star
	
	*Convert variables to strings.
	tostring se, replace force format(%9.2f)
	replace se="("+se+")"
	tostring obs, replace force format(%9.1f)
	
	*Keep variables.
	keep b_star se obs
	order b_star se obs
	
	*Generate results vector.
	gen results=""
	local maxobs=`num_horizon'*3
	set obs `maxobs'
	forvalues rrr=1(1)`num_horizon'{
		
		replace results=b_star[`rrr'] if _n==3*(`rrr'-1)+1
		replace results=se[`rrr'] if _n==3*(`rrr'-1)+2
		replace results=obs[`rrr'] if _n==3*(`rrr'-1)+3
		
	}
	
	*Rename results vector.
	keep results
	rename results col5
	
	*Save results.
	gen n=_n
	save "./output/tables/table_aux_col5.dta", replace
	
*Merge results.
use "./output/tables/table_aux_col1.dta", clear
merge 1:1 n using "./output/tables/table_aux_col2.dta", nogen
merge 1:1 n using "./output/tables/table_aux_col3.dta", nogen
merge 1:1 n using "./output/tables/table_aux_col4.dta", nogen
merge 1:1 n using "./output/tables/table_aux_col5.dta", nogen
drop n

*Define row names.
gen row_names=""
replace row_names="$ t$" 	in 1
replace row_names="" in 2
replace row_names="obs" 	in 3
replace row_names="$ t+1$" in 4
replace row_names="" in 5
replace row_names="obs" 	in 6
replace row_names="$ t+2$" in 7
replace row_names="" in 8
replace row_names="obs" 	in 9
replace row_names="$ t+3$" in 10
replace row_names="" in 11
replace row_names="obs" 	in 12
replace row_names="$ t+4$" in 13
replace row_names="" in 14
replace row_names="obs" 	in 15
replace row_names="$ t+5$" in 16
replace row_names="" in 17
replace row_names="obs" 	in 18
replace row_names="$ t+6$" in 19
replace row_names="" in 20
replace row_names="obs" 	in 21
replace row_names="$ t+7$" in 22
replace row_names="" in 23
replace row_names="obs" 	in 24
replace row_names="$ t+8$" in 25
replace row_names="" in 26
replace row_names="obs" 	in 27
replace row_names="$ t+9$" in 28
replace row_names="" in 29
replace row_names="obs" 	in 30
replace row_names="$ t+10$" in 31
replace row_names="" in 32
replace row_names="obs" 	in 33

order row_names col*

*Define column names.
label var row_names ""
label var col1 "All Data / All Tariffs 2SLS"
label var col2 "Baseline IV"
label var col3 "All Data / All Tariffs 2SLS"
label var col4 "Baseline IV"
label var col5 "Baseline IV"

*Export table.
texsave row_names col1 col2 col3 col4 col5 using "./output/tables/table_b8.tex", varlabels nofix noendash replace preamble("/usepackage{adjustbox}") geometry("a4paper, total={5.5in, 7.5in}") width("18cm")