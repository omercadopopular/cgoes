capture log close 										// closes any open logs
clear 													// clears the memory
log using "logs\g01.smcl", replace  					// chooses logfile

/// 0. options

scalar confidence_interval = 1.96


// instrument
local iv giv

foreach var of global lhs {
		use "results/temp/mun_`iv'_results_`var'.dta", clear
		
		gen low = b - confidence_interval * se
		gen high = b + confidence_interval * se
	
		export excel using "results/mun_results_irf_gdp.xlsx", firstrow(var) sheet("`var'", modify)

		twoway rcap high low horizon, color(gray%80) || ///
			scatter b horizon, mcolor(red) connect(l) lcolor(red) ///
			xtitle("Years after foreign demand shock") ///
			ytitle("Estimated Coefficient") ///
			yline(0, lcolor(black)) ///
			xline(0, lcolor(black)) ///
			xlabel(-$lags(1)$leads) ///
			ylabel(-0.1(.1)0.6) ///
			legend( order(2 "BLP" 4 "New data")) ///
			lwidth(thin) name(irf_`iv'_`var', replace)
			graph export "figs\mirf_`iv'_`var'.pdf", as(pdf) replace
			graph export "figs\mirf_`iv'_`var'.wmf", as(wmf) replace
		
}	

