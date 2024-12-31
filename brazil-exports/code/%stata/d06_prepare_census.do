clear
capture log close
log using "logs\d06.smcl", replace  					// chooses logfile

/// 1. import RAIS dataset

use "data\census\overall_formal_and_informal_2000_and_2010_census_microregion_CNAE95_v2.dta", clear

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

rename ano year
rename UF ufCode
rename uf_acronym uf
rename Nome_UF ufName
rename Microrregião_Geográfica microregion_code
rename Nome_Microrregião microregion_name

	/// adjust ibge_code
	
gen t_microregion_code_ibge = string(microregion_code,"%02.0f")
replace t_microregion_code_ibge  = string(ufCode) + t_microregion_code_ibge 
destring t_microregion_code_ibge, gen(microregion_code_ibge)
drop t_*

preserve
	collapse (mean) avg_wage_tot avg_wage_man_tot avg_wage_less_than_pri_tot avg_wage_primary_tot avg_wage_secondary_tot avg_wage_college_tot avg_wage_q1_tot avg_wage_q2_tot avg_wage_q3_tot avg_wage_q4_tot, by(year ufCode uf ufName microregion_name microregion_code_ibge isic3code3d )
	save "data\temp\means.dta", replace
restore

collapse (sum) worker_tot man_tot less_than_primary_tot primary_tot secondary_tot college_or_higher_tot wage_mass_tot wage_mass_man_tot wage_mass_less_than_pri_tot wage_mass_primary_tot wage_mass_secondary_tot wage_mass_college_tot worker_f worker_inf wage_mass_f  wage_mass_inf, by(year ufCode uf ufName microregion_name microregion_code_ibge isic3code3d )

merge year ufCode uf ufName microregion_name microregion_code_ibge isic3code3d using "data\temp\means.dta"
erase "data\temp\means.dta"
drop _merge

compress

/// 6. save tempfile and close log

save "data\temp\census-panel-processed.dta", replace

/// 7. calculate growth rates

collapse (sum) worker_tot man_tot less_than_primary_tot primary_tot secondary_tot college_or_higher_tot wage_mass_tot wage_mass_man_tot wage_mass_less_than_pri_tot wage_mass_primary_tot wage_mass_secondary_tot wage_mass_college_tot worker_f worker_inf wage_mass_f wage_mass_inf, by(year ufCode uf ufName microregion_name microregion_code_ibge )

egen groupid = group(ufCode uf ufName microregion_name microregion_code_ibge)
egen t = group(year)

xtset groupid t

gen w = wage_mass_tot / worker_tot
gen w_f = wage_mass_f / worker_f
gen w_inf = wage_mass_inf / worker_inf

local group worker_tot man_tot less_than_primary_tot primary_tot secondary_tot college_or_higher_tot worker_f worker_inf w w_f w_inf

foreach var of local group {
	gen l`var' = log(`var')
	gen base_l`var' = l.l`var'
	gen g`var' = l`var' - l.l`var'
	gen g2`var' = (`var'/l.`var') - 1
	drop l`var'
}

keep if year == 2010
keep ufCode uf ufName microregion_name microregion_code_ibge year g* base_*

drop groupid

save "data\temp\census-growth-rates.dta", replace


log close
