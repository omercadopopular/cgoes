clear
capture log close
log using "logs\d09.smcl", replace  					// chooses logfile

/// 1. import RAIS dataset

use "data\rais\RAIS_data_1995_2021_by_municipality_and_CNAE95_5digits.dta", clear

rename cnae10 cnae10Code

tempfile temp
save `temp'

/// 2. merge with CNAE-ISIC concordance file

import excel "data\conc\CNAExISIC - EXPORT.xlsx", clear firstrow allstring

// check uniqueness
bysort cnae10Code: gen N = _N
qui sum N

if r(mean) > 1 {
	di "non-unique"
	break	
}

drop N

merge 1:m cnae10Code using `temp'

keep if _merge == 3
drop _merge

/// 3. rename variables and save processed rais database as a tempfile
	/// we erase this file at the end of this do-file

rename contador employment
rename sexo_1 female
rename ano year
rename Código_IBGE mun_code_ibge

/// adjust ibge_code

gen t_ufCode = substr(string(mun_code_ibge),1,2)
destring t_ufCode, gen(ufCode)
drop t_*

/// 4. save file in memory, load sectors environment classifications, and merge 1:m 

save `temp', replace

use "data\green variable\CNAE95_at_the_5_digit_with_green_classification_FEBRABAN.dta", clear

rename cnae cnae10Code

merge 1:m cnae10Code using `temp'

keep if _merge == 3
drop _merge

/// 5. calculate employment in each of these categories

rename alta_exposicao_clima exposicao
rename alto_risco risco
rename economia_verde everde

local group exposicao risco everde
foreach var of local group {
	gen emp_`var' = `var' * employment
}

collapse (sum) employment emp_*, by(year ufCode  mun_code_ibge)
gen emp_n_exposicao = employment - emp_exposicao
gen emp_n_risco = employment - emp_risco
gen emp_n_everde = employment - emp_everde

/// 6. merge with baseline database

merge 1:1 year mun_code_ibge using "data\temp\mun-master-dataset.dta"
keep if _merge == 3
drop _merge

/// 7. create LHS variables

xtset groupid year

local greenlhs emp_exposicao emp_n_exposicao emp_risco emp_n_risco emp_everde emp_n_everde

foreach var of local greenlhs {
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

// 8. save

compress 
save "data\temp\mun-master-green.dta", replace
