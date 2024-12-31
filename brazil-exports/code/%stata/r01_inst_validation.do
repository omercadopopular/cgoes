capture log close 										// closes any open logs
clear 													// clears the memory
log using "logs\r01.smcl", replace  					// chooses logfile

use "data\temp\master-dataset.dta", clear

xtset groupid year

local group "giv g2iv gvl_fobr g2vl_fobr giv_comtrade g2iv_comtrade gvl_fob g2vl_fob"
foreach var of local group {
	winsor2 `var', cuts(1 99) suffix(_w1) trim
	winsor2 `var', cuts(5 95) suffix(_w5) trim
}

reghdfe gvl_fobr giv
outreg using "results\first-stage.doc", se sdec(3) ///
	summstat(r2 \ N) summdec(1,0) summtitles("R2" \ "N") ///
	starlevels(10 5 1) starloc(1) ///
	ctitles("", "Full Sample" \ "", "") ///
	keep(_cons giv) replace

reghdfe gvl_fobr_w1 giv_w1
outreg using "results\first-stage.doc", se sdec(3) ///
	summstat(r2 \ N) summdec(1,0) summtitles("R2" \ "N") ///
	starlevels(10 5 1) starloc(1) ///
	ctitles("", "Winsorized 1%" \ "", "") ///
	keep(_cons giv_w1) merge replace

reghdfe gvl_fobr_w5 giv_w5
outreg using "results\first-stage.doc", se sdec(3) ///
	summstat(r2 \ N) summdec(1,0) summtitles("R2" \ "N") ///
	starlevels(10 5 1) starloc(1) ///
	ctitles("", "Winsorized 5%" \ "", "") ///
	keep(_cons giv_w5) merge replace

binscatter gvl_fobr giv, title(First Stage) ///
	ytitle("Observed Growth in Exports, by Microregion") ///
	xtitle("Exposure to Foreign Demand Shocks, by Microregion") ///
	yline(0, lcolor(black)) ///
	title("First Stage, Binscatter, Full Sample", margin(vsmall) position(11)) ///
	msymbol(oh) nquantiles(100) ///
	name(growth, replace) legend(off)
graph export "figs\first-stage.pdf", as(pdf) replace
graph export "figs\first-stage.wmf", as(wmf) replace

reghdfe gvl_fob giv_comtrade
outreg using "results\first-stage-comtrade.doc", se sdec(3) ///
	summstat(r2 \ N) summdec(1,0) summtitles("R2" \ "N") ///
	starlevels(10 5 1) starloc(1) ///
	ctitles("", "Full Sample" \ "", "") ///
	keep(_cons giv_comtrade) replace

reghdfe gvl_fob giv_comtrade_w1
outreg using "results\first-stage-comtrade.doc", se sdec(3) ///
	summstat(r2 \ N) summdec(1,0) summtitles("R2" \ "N") ///
	starlevels(10 5 1) starloc(1) ///
	ctitles("", "Winsorized 1%" \ "", "") ///
	keep(_cons giv_comtrade_w1) merge replace

reghdfe gvl_fob giv_comtrade_w5
outreg using "results\first-stage-comtrade.doc", se sdec(3) ///
	summstat(r2 \ N) summdec(1,0) summtitles("R2" \ "N") ///
	starlevels(10 5 1) starloc(1) ///
	ctitles("", "Winsorized 5%" \ "", "") ///
	keep(_cons giv_comtrade_w5) merge replace

binscatter gvl_fob giv_comtrade, title(First Stage) ///
	ytitle("Observed Growth in Exports, by Microregion") ///
	xtitle("Exposure to Foreign Demand Shocks, by Microregion") ///
	yline(0, lcolor(black)) ///
	title("First Stage, Binscatter, Full Sample", margin(vsmall) position(11)) ///
	msymbol(oh) nquantiles(100) ///
	name(growth_comtrade, replace) legend(off)
graph export "figs\first-stage-comtrade.pdf", as(pdf) replace
graph export "figs\first-stage-comtrade.wmf", as(wmf) replace

twoway (hist giv, color(red%50) percent) (hist giv_comtrade, color(blue%50) percent), ///
	title("Distribution of Exposure to Foreign Demand Shocks, by Microregion") ///
	name(hist, replace) legend( label(1 "IV = trade partners GDP growth") label(2 "IV = global sectoral exports growth") ) ///
	xline(0, lcolor(black) lpattern(dash)) ///
	xtitle("") 
graph export "figs\iv-hist.pdf", as(pdf) replace
graph export "figs\iv-hist.wmf", as(wmf) replace

binscatter giv giv_comtrade, ///
	ytitle("Exposure to Foreign Demand Shocks (Trade Partners GDP)") ///
	xtitle("Exposure to Foreign Demand Shocks (Global Sector Exports)") ///
	yline(0, lcolor(black)) ///
	title("Alternative IV", margin(vsmall) position(11)) ///
	msymbol(oh) nquantiles(100) ///
	name(iv, replace) legend(off)
graph export "figs\first-stage-ivs.pdf", as(pdf) replace
graph export "figs\first-stage-ivs.wmf", as(wmf) replace

lowess giv giv_comtrade,  ///
	ytitle("Exposure to Foreign Demand Shocks (Trade Partners GDP)") ///
	xtitle("Exposure to Foreign Demand Shocks (Global Sector Exports)") ///
	yline(0, lcolor(black)) ///
	title("Alternative IV", margin(vsmall) position(11)) ///
	msymbol(oh) ///
	name(iv, replace) legend(off)
graph export "figs\first-stage-ivs-lowess.pdf", as(pdf) replace
graph export "figs\first-stage-ivs-lowess.wmf", as(wmf) replace


reg giv giv_comtrade

log close