capture log close 										// closes any open logs
clear 													// clears the memory
log using "logs\r03.smcl", replace  					// chooses logfile

use "data\temp\master-dataset.dta", clear

xtset groupid year

/// 0. options


// instrument
local iv giv_w

// instrumented
local instrumented gvl_fobr_w

// controls
gen ineqshr = avg_wage_q4r / avg_wage_q1r
local controls l.ineqshr

// fixed effects
local fe uf_code
*microregion_code_ibge

// cluster
egen cl = group(uf_code)
local clustvar uf_code

// lag-length
local lags = 4


foreach iv_iter of local iv {

	foreach var of global lhs {
				
		*Define matrix to store results.
		matrix results_`var' = J(1+$leads+$lags, 5,.)
		matrix colnames results_`var' = horizon b se F1 obs
		
		forvalues h = 1 (1) $lags {
		
			*Display step.
			dis("IRF of `var', h=-`h'") as text
			
			*Run regression.
			
			if `h' == 1 {
				local row = $lags-`h'+1
				mat results_`var'[`row',1]= -`h'
				mat results_`var'[`row',2]=0
				mat results_`var'[`row',3]=0
			}
			else {
*			qui ivreghdfe dl`h'ln`var' l(1/`lags').dl`h'ln`var' ( `instrumented' = `iv' ) l(1/`lags').`iv', absorb(`fe') first cluster(`clustvar')
			qui ivreghdfe dl`h'ln`var'_w l(1/`lags').dl`h'ln`var'_w  ( `instrumented' = `iv' ) l(1/`lags').`iv' `controls', absorb(`fe') first cluster(`clustvar')
				local row = $lags-`h'+1
				mat results_`var'[`row',1]= -`h'
				mat results_`var'[`row',2]=_b[`instrumented']
				mat results_`var'[`row',3]=_se[`instrumented']
				mat temp=e(first)
				mat results_`var'[`row',4]=temp[8,1]
				mat results_`var'[`row',5]=e(N)
			}
		} 
		
		forvalues h = 0 (1) $leads {
				
			*Display step.
			dis("IRF of `var', h=`h'") as text
			
			*Run regression.
*			qui ivreghdfe df`h'ln`var' l(1/`lags').df`h'ln`var' ( `instrumented' = `iv' ) l(1/`lags').`iv', absorb(`fe') first cluster(`clustvar')
			qui ivreghdfe df`h'ln`var'_w  l(1/`lags').df`h'ln`var'_w ( `instrumented' = `iv' ) l(1/`lags').`iv'  `controls', absorb(`fe') first cluster(`clustvar')			

			*Store results.
			local row = $lags+`h'+1
			mat results_`var'[`row',1]= `h'
			mat results_`var'[`row',2]=_b[`instrumented']
			mat results_`var'[`row',3]=_se[`instrumented']
			mat temp=e(first)
			mat results_`var'[`row',4]=temp[8,1]
			mat results_`var'[`row',5]=e(N)			

		} 

			*Save results.
			xsvmat results_`var', name(col) saving("results/temp/`iv'_results_`var'.dta", replace)
			xsvmat results_`var', name(col) list(,)

	}	

}
