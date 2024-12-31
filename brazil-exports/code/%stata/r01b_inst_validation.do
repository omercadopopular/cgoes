capture log close 										// closes any open logs
clear 													// clears the memory
log using "logs\r01.smcl", replace  					// chooses logfile

use "data\temp\master-dataset.dta", clear

xtset groupid year

local group "giv g2iv gvl_fob g2vl_fob"
foreach var of local group {
	winsor2 `var', cuts(1 99) suffix(_w1) trim
	winsor2 `var', cuts(5 95) suffix(_w5) trim
}

reghdfe gvl_fob giv
outreg using "results\first-stage.doc", se sdec(3) ///
	summstat(r2 \ N) summdec(1,0) summtitles("R2" \ "N") ///
	starlevels(10 5 1) starloc(1) ///
	ctitles("", "Full Sample" \ "", "") ///
	keep(_cons giv) replace

reghdfe gvl_fob_w1 giv_w1
outreg using "results\first-stage.doc", se sdec(3) ///
	summstat(r2 \ N) summdec(1,0) summtitles("R2" \ "N") ///
	starlevels(10 5 1) starloc(1) ///
	ctitles("", "Winsorized 1%" \ "", "") ///
	keep(_cons giv_w1) merge replace

reghdfe g2vl_fob_w1 g2iv_w1
outreg using "results\first-stage-2.doc", se sdec(3) ///
	summstat(r2 \ N) summdec(1,0) summtitles("R2" \ "N") ///
	starlevels(10 5 1) starloc(1) ///
	ctitles("", "Winsorized 1%" \ "", "") ///
	keep(_cons g2iv_w1) merge replace

	
reghdfe gvl_fob_w5 giv_w5
outreg using "results\first-stage.doc", se sdec(3) ///
	summstat(r2 \ N) summdec(1,0) summtitles("R2" \ "N") ///
	starlevels(10 5 1) starloc(1) ///
	ctitles("", "Winsorized 5%" \ "", "") ///
	keep(_cons giv_w5) merge replace

binscatter gvl_fob giv, title(First Stage) ///
	ytitle("Observed Growth in Exports, by Microregion (residualized)") ///
	xtitle("Exposure to Foreign Demand Shocks, by Microregion (residualized)") ///
	yline(0, lcolor(black)) ///
	title("First Stage, Binscatter, Full Sample", margin(vsmall) position(11)) ///
	msymbol(oh) nquantiles(100) ///
	name(growth, replace) legend(off)
graph export "figs\first-stage.pdf", as(pdf) replace
graph export "figs\first-stage.wmf", as(wmf) replace

binscatter gvl_fob_w1 giv_w1,  ///
	ytitle("Observed Growth in Exports, by Microregion (residualized)") ///
	xtitle("Exposure to Foreign Demand Shocks, by Microregion (residualized)") ///
	yline(0, lcolor(black)) ///
	title("First Stage, Binscatter, winsorized at 1%", margin(vsmall) position(11)) ///
	msymbol(oh) nquantiles(100) ///
	name(growth, replace) legend(off)
graph export "figs\first-stage-w1.pdf", as(pdf) replace
graph export "figs\first-stage-w1.wmf", as(wmf) replace

binscatter g2vl_fob_w1 g2iv_w1,  ///
	ytitle("Observed Growth in Exports, by Microregion (residualized)") ///
	xtitle("Exposure to Foreign Demand Shocks, by Microregion (residualized)") ///
	yline(0, lcolor(black)) ///
	title("First Stage, Binscatter, winsorized at 1%", margin(vsmall) position(11)) ///
	msymbol(oh) nquantiles(100) ///
	name(growth, replace) legend(off)
graph export "figs\first-stage-w1-2.pdf", as(pdf) replace
graph export "figs\first-stage-w1-2.wmf", as(wmf) replace



binscatter gvl_fob_w5 giv_w5,  ///
	ytitle("Observed Growth in Exports, by Microregion (residualized)") ///
	xtitle("Exposure to Foreign Demand Shocks, by Microregion (residualized)") ///
	yline(0, lcolor(black)) ///
	title("First Stage, Binscatter, winsorized at 5%", margin(vsmall) position(11)) ///
	msymbol(oh) nquantiles(100) ///
	name(growth, replace) legend(off)
graph export "figs\first-stage-w5.pdf", as(pdf) replace
graph export "figs\first-stage-w5.wmf", as(wmf) replace


/*
binscatter gvl_fob_w5 giv_w5, title(First Stage) ///
	ytitle("Observed Growth in Exports, by Microregion (residualized)") ///
	xtitle("Exposure to Foreign Demand Shocks, by Microregion (residualized)") ///
	yline(0, lcolor(black)) ///
	title("Binscatter, Full Sample", margin(vsmall) position(11)) ///
	msymbol(oh) nquantiles(100) ///
	name(growth, replace) legend(off)
*/

qui sum giv, detail
	
hist giv, percent ///
	title("Distribution of Exposure to Foreign Demand Shocks, by Microregion") ///
	name(hist, replace) legend(off) ///
	xline(`=r(mean)', lcolor(red) lpattern(dash)) ///
	xtitle("") color(%50)
graph export "figs\iv-hist.pdf", as(pdf) replace
graph export "figs\iv-hist.wmf", as(wmf) replace