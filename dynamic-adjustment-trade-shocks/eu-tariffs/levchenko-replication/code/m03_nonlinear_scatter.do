clear all
set more off

cap log close
log using "./output/logs/log_m03.smcl", replace

forvalues i=1(1)2{

	*Import welfare results.
	import delimited "./temp_files/w_`i'.csv", clear

	*List of countries.
	levelsof country, local(countries)
	local not ROW
	local countries_: list countries - not

	*Merge with domestic shares.
	foreach c of local countries_{
		merge 1:1 country using "./temp_files/wiod_import_`c'.dta", nogen update
	}

	*Save database.
	keep country w_dif share_im
	rename (w_dif share_im) (w_dif_`i' share_im_`i')
	replace w_dif_`i'=(w_dif_`i')
	save "./temp_files/aux_w_`i'.dta", replace

}

*Merge.
use "./temp_files/aux_w_1.dta", clear
merge 1:1 country using "./temp_files/aux_w_2.dta", nogen

*Scatterplot.
twoway (scatter w_dif_1 share_im_1, mlabel(country) mlabcolor(blue) msymbol(circle_hollow) mcolor(blue)) (fpfit w_dif_1 share_im_1, lcolor(blue)) (scatter w_dif_2 share_im_2, mlabel(country) mlabcolor(red) msymbol(circle_hollow) mcolor(red)) (fpfit w_dif_2 share_im_2, lcolor(red) lpattern("--")), xscale(range(0.74 0.97)) xtitle("{&lambda}{sub:jj}") ytitle("Gains from trade") graphregion(color(white)) bgcolor(white) legend( pos(2) ring(0) col(1)  label(2 "Baseline") label(4 "High elasticity") order(2 4)) 
graph export "./output/graphs/final_files/scatter_gft_gamma.png", replace
graph export "./output/graphs/final_files/scatter_gft_gamma.eps", replace

erase "./temp_files/aux_w_1.dta"
erase "./temp_files/aux_w_2.dta"

log close