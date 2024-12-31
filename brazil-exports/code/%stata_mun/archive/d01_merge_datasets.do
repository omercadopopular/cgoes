log using "logs\d01.smcl", replace  					// chooses logfile

/// 1. import RAIS dataset

use "data\rais\combined_1995_2021_by_microregion_and_CNAE95_5digits_v3.dta", clear

rename cnae10 cnae10Code

tempfile temp
save `temp'

/// 2. merge with CNAE-ISIC concordance file

import excel "conc\CNAExISIC - EXPORT.xlsx", clear firstrow allstring

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

rename contador laborforce
rename sexo_1 female
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

collapse (sum) laborforce female less_than_primary primary secondary college_or_higher wage_mass wage_mass_sexo_1 wage_mass_less_than_pri wage_mass_secondary wage_mass_college, by(year ufCode uf ufName microregion_name microregion_code_ibge isic3code2d )

compress

save "data\temp\rais-panel-processed.dta", replace


/// 6. erase tempfiles and close log

erase "data\temp\rais-panel-processed.dta"

log close
