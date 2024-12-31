capture log close 										// closes any open logs
log using "logs\g03.smcl", replace  					// chooses logfile

/// 0. options

scalar confidence_interval = 1.96


// instrument
local iv giv_comtrade

// first group
local group male female

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
		use "results/temp/`iv'_results_`var'_alt.dta", clear
		
		rename b b_`var'
		
		gen low_`var' = b_`var' - confidence_interval * se
		gen high_`var' = b_`var' + confidence_interval * se
		
		keep horizon b_* low_* high_*
		
		merge 1:1 horizon using `chart'
		drop _merge
		save `chart', replace
}	


		twoway rcap high_male low_male horizon, color(red%50) || ///
			scatter b_male horizon, mcolor(red) connect(l) lcolor(red) || ///
			rcap high_female low_female horizon, color(navy%50) || ///
			scatter b_female horizon, mcolor(navy) connect(l) lcolor(navy) ///
			xtitle("Years after foreign demand shock") ///
			ytitle("Estimated Coefficient") ///
			yline(0, lcolor(black)) ///
			xline(0, lcolor(black)) ///
			xlabel(-$lags(1)$leads) ///
			ylabel(-0.1(.1)0.6) ///
			legend( order(2 "Male employment" 4 "Female employment")) ///
			lwidth(thin) name(male_female, replace)
			graph export "figs\\`iv'_male_female.pdf", as(pdf) replace
			graph export "figs\\`iv'_male_female.wmf", as(wmf) replace


// second group
local group less_than_college college_or_higher

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
		use "results/temp/`iv'_results_`var'_alt.dta", clear
		
		rename b b_`var'
		
		gen low_`var' = b_`var' - confidence_interval * se
		gen high_`var' = b_`var' + confidence_interval * se
		
		keep horizon b_* low_* high_*
		
		merge 1:1 horizon using `chart'
		drop _merge
		save `chart', replace
}	


		twoway rcap high_less_than_college low_less_than_college horizon, color(red%50) || ///
			scatter b_less_than_college horizon, mcolor(red) connect(l) lcolor(red) || ///
			rcap high_college_or_higher low_college_or_higher horizon, color(navy%50) || ///
			scatter b_college_or_higher horizon, mcolor(navy) connect(l) lcolor(navy) ///
			xtitle("Years after foreign demand shock") ///
			ytitle("Estimated Coefficient") ///
			yline(0, lcolor(black)) ///
			xline(0, lcolor(black)) ///
			xlabel(-$lags(1)$leads) ///
			ylabel(-0.1(.1)0.6) ///
			legend( order(2 "Less than College" 4 "College or higher")) ///
			lwidth(thin) name(college, replace)
			graph export "figs\\`iv'_college.pdf", as(pdf) replace
			graph export "figs\\`iv'_college.wmf", as(wmf) replace

			
// third group
local group w_male w_female

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
		use "results/temp/`iv'_results_`var'_alt.dta", clear
		
		rename b b_`var'
		
		gen low_`var' = b_`var' - confidence_interval * se
		gen high_`var' = b_`var' + confidence_interval * se
		
		keep horizon b_* low_* high_*
		
		merge 1:1 horizon using `chart'
		drop _merge
		save `chart', replace
}	


		twoway rcap high_w_male low_w_male horizon, color(red%50) || ///
			scatter b_w_male horizon, mcolor(red) connect(l) lcolor(red) || ///
			rcap high_w_female low_w_female horizon, color(navy%50) || ///
			scatter b_w_female horizon, mcolor(navy) connect(l) lcolor(navy) ///
			xtitle("Years after foreign demand shock") ///
			ytitle("Estimated Coefficient") ///
			yline(0, lcolor(black)) ///
			xline(0, lcolor(black)) ///
			xlabel(-$lags(1)$leads) ///
			ylabel(-0.1(.1)0.6) ///
			legend( order(2 "Male wages" 4 "Female wages")) ///
			lwidth(thin) name(male_female_w, replace)
			graph export "figs\\`iv'_male_female_w.pdf", as(pdf) replace
			graph export "figs\\`iv'_male_female_w.wmf", as(wmf) replace



			