capture log close 										// closes any open logs
clear 													// clears the memory
log using "logs\r05b.smcl", replace  					// chooses logfile

use "data\temp\mun-master-green.dta", clear

/// 0. options


// instrument
local iv giv_comtrade

// instrumented
local instrumented gvl_fob

// lag-length
local lags = 6

keep if year >= 2000

// controls
gen t_LaborShr2000 = LaborShr if year == 2000
bysort mun_code_ibge: egen LaborShr2000 = mean(t_LaborShr2000)
gen t_wr2000 = wr if year == 2000
bysort mun_code_ibge: egen wr2000 = mean(t_wr2000)
drop t_*
local controls LaborShr2000 wr2000

// fixed effects
local fe 
*mun_code_ibge

// cluster
egen cl = group(uf_code)
local clustvar uf_code

// lhs 
*local greenlhs emp_exposicao emp_n_exposicao emp_risco emp_n_risco emp_everde emp_n_everde
local greenlhs employment 


gen r2 = emp_risco / employment
qui sum r2, detail
local p75 = r(p75)
local p25 = r(p25)
local median = r(p50)

xtset groupid year

foreach iv_iter of local iv {

	foreach var of local greenlhs {
				
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
			qui ivreghdfe dl`h'ln`var' l(1/`lags').dl`h'ln`var'  ( `instrumented' = `iv' ) l(1/`lags').`iv' `controls' if r2 >= `p75', absorb(`fe') first cluster(`clustvar')
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
			qui ivreghdfe df`h'ln`var'  l(1/`lags').df`h'ln`var' ( `instrumented' = `iv' ) l(1/`lags').`iv'  `controls'  if r2 >= `p75', absorb(`fe') first cluster(`clustvar')			

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
			xsvmat results_`var', name(col) saving("results/temp/mun_`iv'_results_`var'_p75.dta", replace)
			xsvmat results_`var', name(col) list(,)

	}	

}


foreach iv_iter of local iv {

	foreach var of local greenlhs {
				
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
			qui ivreghdfe dl`h'ln`var' l(1/`lags').dl`h'ln`var'  ( `instrumented' = `iv' ) l(1/`lags').`iv' `controls' if r2 <= `p25', absorb(`fe') first cluster(`clustvar')
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
			qui ivreghdfe df`h'ln`var'  l(1/`lags').df`h'ln`var' ( `instrumented' = `iv' ) l(1/`lags').`iv'  `controls'  if r2 <= `p25', absorb(`fe') first cluster(`clustvar')			

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
			xsvmat results_`var', name(col) saving("results/temp/mun_`iv'_results_`var'_p25.dta", replace)
			xsvmat results_`var', name(col) list(,)

	}	

}


foreach iv_iter of local iv {

	foreach var of local greenlhs {
				
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
			qui ivreghdfe dl`h'ln`var' l(1/`lags').dl`h'ln`var'  ( `instrumented' = `iv' ) l(1/`lags').`iv' `controls' if r2 >= `median', absorb(`fe') first cluster(`clustvar')
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
			qui ivreghdfe df`h'ln`var'  l(1/`lags').df`h'ln`var' ( `instrumented' = `iv' ) l(1/`lags').`iv'  `controls'  if r2 >= `median', absorb(`fe') first cluster(`clustvar')			

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
			xsvmat results_`var', name(col) saving("results/temp/mun_`iv'_results_`var'_medianup.dta", replace)
			xsvmat results_`var', name(col) list(,)

	}	

}


foreach iv_iter of local iv {

	foreach var of local greenlhs {
				
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
			qui ivreghdfe dl`h'ln`var' l(1/`lags').dl`h'ln`var'  ( `instrumented' = `iv' ) l(1/`lags').`iv' `controls' if r2 <= `median', absorb(`fe') first cluster(`clustvar')
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
			qui ivreghdfe df`h'ln`var'  l(1/`lags').df`h'ln`var' ( `instrumented' = `iv' ) l(1/`lags').`iv'  `controls'  if r2 <= `median', absorb(`fe') first cluster(`clustvar')			

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
			xsvmat results_`var', name(col) saving("results/temp/mun_`iv'_results_`var'_mediand.dta", replace)
			xsvmat results_`var', name(col) list(,)

	}	

}


