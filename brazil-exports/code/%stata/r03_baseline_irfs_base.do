capture log close 										// closes any open logs
clear 													// clears the memory
log using "logs\r03.smcl", replace  					// chooses logfile

use "data\temp\master-dataset.dta", clear

// instrument
local iv givbase_comtrade

// instrumented
local instrumented gvl_fob_base

// controls
gen ineqshr = avg_wage_q4r / avg_wage_q1r
local controls LaborShrbase

// fixed effects
local fe uf_code
*microregion_code_ibge

// cluster
egen cl = group(uf_code)
local clustvar uf_code

// years
local fyear = 2001
local lyear = 2020

foreach iv_iter of local iv {
	

	foreach var of global lhs {
				
		*Define matrix to store results.
		matrix results_`lhs'_base = J(1+`lyear'-`fyear', 5,.)
		matrix colnames results_`lhs'_base = year b se F1 obs
		
		local row = 0
		forvalues y = `fyear' (1) `lyear' {
			local row = `row' + 1
			
			if `y' == $baseyear {
				mat results_`lhs'_base[`row',1]= `y'
				mat results_`lhs'_base[`row',2]=0
				mat results_`lhs'_base[`row',3]=0
				mat results_`lhs'_base[`row',4]=0
				mat results_`lhs'_base[`row',5]=0									
			}
			
			else {
				qui ivreghdfe dlln`var'_base ( `instrumented' = `iv' ) `controls' if year == `y' , absorb(`fe') first cluster(`clustvar')
				mat results_`lhs'_base[`row',1]= `y'
				mat results_`lhs'_base[`row',2]=_b[`instrumented']
				mat results_`lhs'_base[`row',3]=_se[`instrumented']
				mat results_`lhs'_base[`row',4]=e(F)
				mat results_`lhs'_base[`row',5]=e(N)				
			}
			
		}
		
			*Save results.
			xsvmat results_`lhs'_base, name(col) saving("results/temp/`iv'_results_`var'_base.dta", replace)
			xsvmat results_`lhs'_base, name(col) list(,)

	}	

}
