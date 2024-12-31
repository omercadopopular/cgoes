capture log close 										// closes any open logs
log using "logs\g04.smcl", replace  					// chooses logfile

/// 0. options

scalar confidence_interval = 1.96


// instrument
local iv giv_comtrade

// first group
local group emp_exposicao emp_n_exposicao 


clear
local N = $leads + $lags + 1
set obs `N'
gen n = _n
gen horizon = -$lags + n - 1
drop n
tempfile chart
save `chart', emptyok

foreach var of local group {
	di "`var'"
		use "results/temp/mun_`iv'_results_`var'_alt.dta", clear
		
		rename b b_`var'
		
		gen low_`var' = b_`var' - confidence_interval * se
		gen high_`var' = b_`var' + confidence_interval * se
		
		keep horizon b_* low_* high_*
		
		merge 1:1 horizon using `chart'
		drop _merge
		save `chart', replace
}	


		twoway rcap high_emp_exposicao low_emp_exposicao horizon, color(red%50) || ///
			scatter b_emp_exposicao horizon, mcolor(red) connect(l) lcolor(red) || ///
			rcap high_emp_n_exposicao low_emp_n_exposicao horizon, color(navy%50) || ///
			scatter b_emp_n_exposicao horizon, mcolor(navy) connect(l) lcolor(navy) ///
			xtitle("Years after foreign demand shock") ///
			ytitle("Estimated Coefficient") ///
			yline(0, lcolor(black)) ///
			xline(0, lcolor(black)) ///
			xlabel(-$lags(1)$leads) ///
			ylabel(-0.1(.1)0.6) ///
			legend( order(2 "Exposed" 4 "Non-Exposed")) ///
			lwidth(thin) name(exposed, replace)
			graph export "figs\\m`iv'_green_exp.pdf", as(pdf) replace
			graph export "figs\\m`iv'_green_exp.wmf", as(wmf) replace


// second group
local group emp_risco emp_n_risco

clear
local N = $leads + $lags + 1
set obs `N'
gen n = _n
gen horizon = -$lags + n - 1
drop n
tempfile chart
save `chart', emptyok

foreach var of local group {
	di "`var'"
		use "results/temp/mun_`iv'_results_`var'_alt.dta", clear
		
		rename b b_`var'
		
		gen low_`var' = b_`var' - confidence_interval * se
		gen high_`var' = b_`var' + confidence_interval * se
		
		keep horizon b_* low_* high_*
		
		merge 1:1 horizon using `chart'
		drop _merge
		save `chart', replace
}	


		twoway rcap high_emp_risco low_emp_risco horizon, color(red%50) || ///
			scatter b_emp_risco horizon, mcolor(red) connect(l) lcolor(red) || ///
			rcap high_emp_n_risco low_emp_n_risco horizon, color(navy%50) || ///
			scatter b_emp_n_risco horizon, mcolor(navy) connect(l) lcolor(navy) ///
			xtitle("Years after foreign demand shock") ///
			ytitle("Estimated Coefficient") ///
			yline(0, lcolor(black)) ///
			xline(0, lcolor(black)) ///
			xlabel(-$lags(1)$leads) ///
			ylabel(-0.1(.1)0.6) ///
			legend( order(2 "Risk" 4 "No Risk")) ///
			lwidth(thin) name(risk, replace)
			graph export "figs\\m`iv'_green_risk.pdf", as(pdf) replace
			graph export "figs\\m`iv'_green_risk.wmf", as(wmf) replace

			
// third group
local group emp_everde emp_n_everde

clear
local N = $leads + $lags + 1
set obs `N'
gen n = _n
gen horizon = -$lags + n - 1
drop n
tempfile chart
save `chart', emptyok

foreach var of local group {
	di "`var'"
		use "results/temp/mun_`iv'_results_`var'_alt.dta", clear
		
		rename b b_`var'
		
		gen low_`var' = b_`var' - confidence_interval * se
		gen high_`var' = b_`var' + confidence_interval * se
		
		keep horizon b_* low_* high_*
		
		merge 1:1 horizon using `chart'
		drop _merge
		save `chart', replace
}	


		twoway rcap high_emp_everde low_emp_everde horizon, color(red%50) || ///
			scatter b_emp_everde horizon, mcolor(red) connect(l) lcolor(red) || ///
			rcap high_emp_n_everde low_emp_n_everde horizon, color(navy%50) || ///
			scatter b_emp_n_everde horizon, mcolor(navy) connect(l) lcolor(navy) ///
			xtitle("Years after foreign demand shock") ///
			ytitle("Estimated Coefficient") ///
			yline(0, lcolor(black)) ///
			xline(0, lcolor(black)) ///
			xlabel(-$lags(1)$leads) ///
			ylabel(-0.1(.1)0.6) ///
			legend( order(2 "Green" 4 "Not green")) ///
			lwidth(thin) name(green, replace)
			graph export "figs\\m`iv'_green_green.pdf", as(pdf) replace
			graph export "figs\\`miv'_green_green.wmf", as(wmf) replace



			