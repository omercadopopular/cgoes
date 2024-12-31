clear all
set more off

mata
	mata mlib index
end

cap log close
log using "./output/logs/log_f04.smcl", append

///////////////////
///Preliminaries///
///////////////////

*Open database.
use "./temp_files/DataregW_did.dta", clear

*Declare panel.
xtset panel_id year

*Generate treatment group with minor partner indicators.
gen treatgroup=.
replace treatgroup=0 if !missing(iv_0_baseline)
replace treatgroup=1 if iv_0_baseline!=0 & !missing(iv_0_baseline)

*Generate DID treatment group.
gen lmfn_binding=L.mfn_binding
gen treatgroup_did=mfn_binding*lmfn_binding
replace treatgroup_did=0 if D0ln_tariff==0
drop lmfn_binding

*Generate ranking of importers.
bys importer year nomen: egen agg_trade=total(imports_baci)
gsort year nomen -agg_trade
by year nomen: gen int rank_full=sum(agg_trade!=agg_trade[_n-1]) 
drop agg_trade 

*Generate ranking of exporters for each importer and treatment by trade.
bys exporter importer year nomen: egen double btrade=total(imports_baci)
gsort importer year nomen treatgroup -btrade
by importer year nomen treatgroup: gen rank_exp=sum(btrade!=btrade[_n-1]) 
drop btrade
compress

*Generate ranking of exporters for each importer and treatment by frequency
bys exporter importer year nomen: egen double bfreq=count(imports_baci)
gsort importer year nomen treatgroup -bfreq
by importer year nomen treatgroup: gen rank_freq=sum(bfreq!=bfreq[_n-1]) 
drop bfreq
compress

*Save database.
compress
save "./temp_files/Data_analysis_full.dta", replace

*Keep relevant observations and save database.
drop if missing(treatgroup) & missing(treatgroup_did)
compress
save "./temp_files/Data_analysis.dta", replace

////////////////
///Histograms///
////////////////

*Open database.
use "./temp_files/Data_analysis.dta", clear
xtset panel_id year

*Set scheme.
set scheme s1mono

*Unconditional, full.
histogram D0ln_tariff if !missing(treatgroup), bin(40) fraction xtitle(Tariff Change (t,t-1))
graph export "./output/graphs/final_files/hist_tariff_0_uncond.png", as(png) name("Graph") width(1200) height(900) replace
graph export "./output/graphs/final_files/hist_tariff_0_uncond.eps", as(eps) name("Graph") replace
graph export "./output/graphs/final_files/hist_tariff_0_uncond.pdf", as(pdf) name("Graph") replace

*Unconditional, non-zero changes.
histogram D0ln_tariff if D0ln_tariff!=0 & !missing(treatgroup), bin(40) fraction xtitle(Tariff Change (t,t-1))
graph export "./output/graphs/final_files/hist_tariff_0_uncondnz.png", as(png) name("Graph")  width(1200) height(900) replace
graph export "./output/graphs/final_files/hist_tariff_0_uncondnz.eps", as(eps) name("Graph") replace
graph export "./output/graphs/final_files/hist_tariff_0_uncondnz.pdf", as(pdf) name("Graph") replace

*Treatment, full.
twoway (histogram D0ln_tariff if treatgroup==1, width(0.01) fraction color(red%31)) || (histogram D0ln_tariff if treatgroup==0, width(0.01) fraction color(green%30)), xtitle("Tariff Change (t,t-1)") legend(order(1 "Treatment" 2 "Control" ))
graph export "./output/graphs/final_files/hist_tariff_0_treatcontrol.png", as(png)  width(1200) height(900) replace
graph export "./output/graphs/final_files/hist_tariff_0_treatcontrol.eps", as(eps) replace
graph export "./output/graphs/final_files/hist_tariff_0_treatcontrol.pdf", as(pdf) replace

*Treatment, non-zero changes.
twoway (histogram D0ln_tariff if treatgroup==1 & D0ln_tariff!=0, width(0.01) fraction color(red%30)) || (histogram D0ln_tariff if treatgroup==0 & D0ln_tariff!=0, width(0.01) fraction color(green%30)), xtitle("Tariff Change (t,t-1)") legend(order(1 "Treatment" 2 "Control" ))
graph export "./output/graphs/final_files/hist_tariff_0_treatcontrolnz.png",  as(png)  width(1200) height(900) replace
graph export "./output/graphs/final_files/hist_tariff_0_treatcontrolnz.eps",  as(eps) replace
graph export "./output/graphs/final_files/hist_tariff_0_treatcontrolnz.pdf",  as(pdf) replace

//////////////////////
///Autocorrelations///
//////////////////////

*Generate autocorrelations.
gen unc_auto=.
local lags 10 
gen byte horizon=_n-1 if _n<=`lags'+1
forval h=0/`lags' {

	dis(`h')
	gen temp=D0ln_tariff if !missing(treatgroup)
	corr temp L`h'.temp 
	replace unc_auto=`r(rho)' if _n==`h'+1
	drop temp*

}

*Unconditional.
twoway (bar unc_auto horizon, barwidth(.04)) (scatter unc_auto horizon, msymbol(circle)) , ytitle("Autocorrelations of Tariff Change")  yline(0) legend(off) xtitle("Lag")
graph export "./output/graphs/final_files/autocorr_uncond.png", as(png) name("Graph") replace
graph export "./output/graphs/final_files/autocorr_uncond.eps", as(eps) name("Graph") replace
graph export "./output/graphs/final_files/autocorr_uncond.pdf", as(pdf) name("Graph") replace

log close


