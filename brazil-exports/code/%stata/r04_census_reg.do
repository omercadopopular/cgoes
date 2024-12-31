capture log close 										// closes any open logs
clear 													// clears the memory
log using "logs\r04.smcl", replace  					// chooses logfile

use "data\temp\master-dataset-census.dta", clear


local group worker_f worker_inf w_f w_inf

foreach var of local group {
	di "`var'"
	
	matrix results_`var' = J(4, 8,.)
	matrix colnames results_`var' = inst_version b se t_stat p_value F1 obs s_fe

	qui ivreghdfe g`var' (gvl_fob = giv_comtrade) LaborShr2000 base_l`var', absorb(uf) first
	mat results_`var'[1,1]= 1
	mat results_`var'[1,2]=_b[gvl_fob]
	mat results_`var'[1,3]=_se[gvl_fob]
	
	local t = _b[gvl_fob] / _se[gvl_fob]
	local p = 2*ttail(e(df_r),abs(`t'))
	
	mat results_`var'[1,4]= `t'
	mat results_`var'[1,5]= `p'
	
	mat temp=e(first)
	mat results_`var'[1,6]=temp[8,1]
	mat results_`var'[1,7]=e(N)
	mat results_`var'[1,8]=1

	qui ivreghdfe g`var' (gvl_fobr = giv) LaborShr2000 base_l`var', absorb(uf) first
	mat results_`var'[2,1]= 2
	mat results_`var'[2,2]=_b[gvl_fobr]
	mat results_`var'[2,3]=_se[gvl_fobr]
	
	local t = _b[gvl_fob] / _se[gvl_fob]
	local p = 2*ttail(e(df_r),abs(`t'))
	
	mat results_`var'[2,4]= `t'
	mat results_`var'[2,5]= `p'
	
	mat temp=e(first)
	mat results_`var'[2,6]=temp[8,1]
	mat results_`var'[2,7]=e(N)
	mat results_`var'[2,8]=1
	
	qui ivreghdfe g`var' (gvl_fob = giv_comtrade) LaborShr2000 base_l`var',  first
	mat results_`var'[3,1]= 1
	mat results_`var'[3,2]=_b[gvl_fob]
	mat results_`var'[3,3]=_se[gvl_fob]
	
	local t = _b[gvl_fob] / _se[gvl_fob]
	local p = 2*ttail(e(df_m),abs(`t'))
	
	mat results_`var'[3,4]= `t'
	mat results_`var'[3,5]= `p'
	
	mat temp=e(first)
	mat results_`var'[3,6]=temp[8,1]
	mat results_`var'[3,7]=e(N)
	mat results_`var'[3,8]=0

	qui ivreghdfe g`var' (gvl_fobr = giv) LaborShr2000 base_l`var', first
	mat results_`var'[4,1]= 2
	mat results_`var'[4,2]=_b[gvl_fobr]
	mat results_`var'[4,3]=_se[gvl_fobr]
	
	local t = _b[gvl_fob]/_se[gvl_fob]
	local p = 2*ttail(e(df_m),abs(`t'))
	
	mat results_`var'[4,4]= `t'
	mat results_`var'[4,5]= `p'
	
	mat temp=e(first)
	mat results_`var'[4,6]=temp[8,1]
	mat results_`var'[4,7]=e(N)
	mat results_`var'[4,8]=0	
	
	xsvmat results_`var', name(col) saving("results/temp/census_results_`var'.dta", replace)
	xsvmat results_`var', name(col) list(,)	
	
	preserve 
		clear 
		svmat results_`var', names(col)
		export excel using "results/census.xlsx", firstrow(var) sheet("`var'", modify)
	restore
}

