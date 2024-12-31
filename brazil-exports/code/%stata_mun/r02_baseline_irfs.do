capture log close 										// closes any open logs
clear 													// clears the memory
log using "logs\r02.smcl", replace  					// chooses logfile

use "data\temp\mun-master-dataset.dta", clear

/// 0. options


// instrument
local iv giv

// instrumented
local instrumented gvl_fob

// controls
gen ineqshr = avg_wage_q4r / avg_wage_q1r
gen t_LaborShr2000 = LaborShr if year == 2000
bysort mun_code_ibge: egen LaborShr2000 = mean(t_LaborShr2000)
gen t_wr2000 = wr if year == 2000
bysort mun_code_ibge: egen wr2000 = mean(t_wr2000)
drop t_*
local controls l.LaborShr l.wr

// fixed effects
local fe // uf_code
*mun_code_ibge

// cluster
egen cl = group(uf_code)
local clustvar uf_code

// lag-length
local lags = 4

xtset groupid year


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
			qui ivreghdfe dl`h'ln`var' l(1/`lags').dl`h'ln`var'  ( `instrumented' = `iv' ) l(1/`lags').`iv' `controls', absorb(`fe') first cluster(`clustvar')
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
			qui ivreghdfe df`h'ln`var'  l(1/`lags').df`h'ln`var' ( `instrumented' = `iv' ) l(1/`lags').`iv'  `controls', absorb(`fe') first cluster(`clustvar')			

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
			xsvmat results_`var', name(col) saving("results/temp/mun_`iv'_results_`var'.dta", replace)
			xsvmat results_`var', name(col) list(,)

	}	

}

