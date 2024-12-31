clear
capture log close
log using "logs\d05.smcl", replace  					// chooses logfile

use "data\temp\microregion-trade-panel-processed-exp.dta", clear


// 1. create missing variables

// rename variables
rename wage_mass_sexo_1 wage_mass_female
rename wage_mass_college wage_mass_college_or_higher
rename less_than_primary less_than_pri
rename ufCode uf_code
rename ufName uf_name
gen male = employment - female
gen wage_mass_male = wage_mass - wage_mass_female 
gen less_than_college = employment - college_or_higher

// adjust for inflation

// Save before importing PCE
tempfile trade
save `trade'

// import PCE file and merge/
import excel "data/ibge/tabela1737.xlsx", clear firstrow sheet("INDEX")

drop if missing(year)

gen t_reference = IPCA if year == 2002
egen reference = mean(t_reference)
drop t_* 

gen adj_ipca = 1 / (IPCA / reference)

keep year adj

merge 1:m year using `trade'
keep if _merge == 3
drop _merge

foreach var of varlist wage_* avg_wage_* {
	gen `var'r = `var' * adj_ipca
}

drop adj_ipca

// wages

gen avg_wage_h1r = (avg_wage_q1r + avg_wage_q2r)/2
gen avg_wage_h2r = (avg_wage_q3r + avg_wage_q4r)/2
gen avg_wage_h1 = (avg_wage_q1 + avg_wage_q2)/2
gen avg_wage_h2 = (avg_wage_q3 + avg_wage_q4)/2

gen w = wage_mass / employment
gen wr = wage_massr / employment

local subscript "male female"

foreach var of local subscript {
	gen w_`var' = wage_mass_`var' / `var'
	gen w_`var'r = wage_mass_`var'r / `var'
}

// windorize

foreach var of global lhs {
	winsor2 `var', cuts(1 99) suffix(_w) trim
}





/// 2. label 

order year uf uf_name uf_code microregion_name microregion_code_ibge pop employment female male less_than_pri primary secondary college_or_higher w* vl_fob vl_fobr avg_wage_* gvl_fobr* giv*  

// indices
label var year "Year"
label var uf "State, acronym"
label var uf_code "State, IBGE code"
label var uf_name "State, name"
label var microregion_name "Microregion, name"
label var microregion_code "Microregion, IBGE code"

// ibge
label var pop2022 "2022 Population, IBGE"

// rais 

label var employment "Number of workers, RAIS"
label var female "Number of female workers, RAIS"
label var male "Number of male workers, RAIS"
label var less_than_pri "Number of workers with less than primary education, RAIS"
label var primary "Number of workers with primary education, RAIS"
label var secondary "Number of workers with secondary education, RAIS"
label var college_or_higher "Number of workers with college or higher education, RAIS"

label var wage_mass "Wage mass, nominal, RAIS"
label var wage_mass_female "Wage mass, female workers, nominal, RAIS"
label var wage_mass_male "Wage mass, male workers, nominal, RAIS"
label var wage_mass_less_than_pri "Wage mass, less than primary education, nominal, RAIS"
label var wage_mass_secondary "Wage mass, secondary education, nominal, RAIS"
label var wage_mass_college_or_higher "Wage mass, college or higher education, nominal, RAIS"

label var wage_massr "Wage mass, constant R$2022, RAIS"
label var wage_mass_femaler "Wage mass, female workers, constant R$2022, RAIS"
label var wage_mass_maler "Wage mass, male workers, constant R$2022, RAIS"
label var wage_mass_less_than_prir "Wage mass, less than primary education, constant R$2022, RAIS"
label var wage_mass_secondaryr "Wage mass, secondary education, constant R$2022, RAIS"
label var wage_mass_college_or_higherr "Wage mass, college or higher education, constant R$2022, RAIS"

label var wr "Average wage, constant R$2022, RAIS"
label var w_femaler "Average wage, female workers, constant R$2022, RAIS"
label var w_maler "Average wage, male workers, constant R$2022, RAIS"

label var w "Average wage, current R$, RAIS"
label var w_female "Average wage, female workers, current R$, RAIS"
label var w_male "Average wage, male workers, current R$, RAIS"

label var avg_wage_q1r "Average real wage, microregion quartile 1"
label var avg_wage_q2r "Average real wage, microregion quartile 2"
label var avg_wage_q3r "Average real wage, microregion quartile 3"
label var avg_wage_q4r "Average real wage, microregion quartile 4"

label var avg_wage_q1 "Average wage, microregion quartile 1"
label var avg_wage_q2 "Average wage, microregion quartile 2"
label var avg_wage_q3 "Average wage, microregion quartile 3"
label var avg_wage_q4 "Average wage, microregion quartile 4"

label var avg_wage_h1r "Average real wage, microregion half 1"
label var avg_wage_h2r "Average real wage, microregion half 2"

label var avg_wage_h1 "Average wage, microregion half 1"
label var avg_wage_h2 "Average wage, microregion half 2"

// mdic
label var vl_fob "Exports by Microregion, nominal $, MDIC"
label var vl_fobr "Exports by Microregion, constant $2022, MDIC (Deflated with PCE, FRED)"
label var gvl_fobr "Pct Change in Exports by Microregion, constant $2022, MDIC (Deflated with PCE, FRED)"

// ivs
label var giv "Log Difference, Exposure Foreign Demand Shocks (GDP trade partners)"
label var g2iv "Pct Change, Exposure Foreign Demand Shocks (GDP trade partners)"
label var giv_comtrade "Log Difference, Exposure Foreign Demand Shocks (global sector export)"
label var g2iv_comtrade "Pct Change, Exposure Foreign Demand Shocks (global sector export)"

// groupid
label var groupid "Panel ID"

// data
label data "Master file, Brazil exports and labor market"

xtset groupid year

// 3. create changes

foreach var of global lhs {
	gen ln`var' = log(`var')
	
	local lags = $lags +1
	forvalues i = 1/`lags' {
		gen dl`i'ln`var' = l`i'.ln`var' - l.ln`var'
		label var dl`i'ln`var' "Cumulative Pct Change in `var' from t-1 to h=t-`i'"
	}
	
	
	forvalues i = 0/$leads  {
		gen df`i'ln`var' = f`i'.ln`var' - l.ln`var'
		label var df`i'ln`var' "Cumulative Pct Change in `var' from t-1 to h=t+`i'"
	}
	
}

foreach var of global lhs {
	gen ln`var'_w = log(`var'_w)
	
	local lags = $lags +1
	forvalues i = 1/`lags' {
		gen dl`i'ln`var'_w = l`i'.ln`var'_w - l.ln`var'_w
		label var dl`i'ln`var'_w "Cumulative Pct Change in `var'_w from t-1 to h=t-`i'"
	}
	
	
	forvalues i = 0/$leads  {
		gen df`i'ln`var'_w = f`i'.ln`var'_w - l.ln`var'_w
		label var df`i'ln`var'_w "Cumulative Pct Change in `var'_w from t-1 to h=t+`i'"
	}
	
}

// 3. create changes with base year

foreach var of global lhs {
	gen t_`var' = log(`var') if year == $baseyear
	bysort groupid: egen ln`var'_base = mean(t_`var')
	drop t_*
	gen dlln`var'_base = ln`var' - ln`var'_base
	drop ln`var'_base
}


// 4. save and erase files 

compress 
save "data\temp\master-dataset.dta", replace
*erase "data\temp\microregion-trade-panel-processed-exp.dta"
