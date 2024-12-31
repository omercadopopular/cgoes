capture log close 										// closes any open logs
clear 													// clears the memory
log using "logs\g02.smcl", replace  					// chooses logfile

/// 0. options

scalar confidence_interval = 1.96


// instrument
local iv giv_comtrade

foreach var of global lhs {
	di "`var'"
		use "results/temp/`iv'_results_`var'_alt.dta", clear
		
		gen low = b - confidence_interval * se
		gen high = b + confidence_interval * se
	
		export excel using "results/results_irf_comtrade.xlsx", firstrow(var) sheet("`var'", modify)

		twoway rcap high low horizon, color(gray%80) || ///
			scatter b horizon, mcolor(red) connect(l) lcolor(red) ///
			xtitle("Years after foreign demand shock") ///
			ytitle("Estimated Coefficient") ///
			yline(0, lcolor(black)) ///
			xline(0, lcolor(black)) ///
			xlabel(-$lags(1)$leads) ///
			ylabel(-0.1(.1)0.6) ///
			legend( lab(1 "95% Confidence interval") lab(2 "Coefficient")) ///
			lwidth(thin) name(`iv'_`var', replace)
			graph export "figs\\`iv'_`var'.pdf", as(pdf) replace
			graph export "figs\\`iv'_`var'.wmf", as(wmf) replace
		
}	

