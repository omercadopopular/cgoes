clear all
set more off
set type double, permanently

cap log close
log using "./output/logs/log_c02.smcl", append

*Open database.
use "./data/PWT/pwt91.dta", clear

*Keep 2006 observations.
keep if year==2006

*Generate total hours.
gen hours=avh*emp

*Save database.
save "./temp_files/pwt_calibration_int.dta", replace

/////////////////
///5 countries///
/////////////////

*Open database.
use "./temp_files/pwt_calibration_int.dta", clear

*Replace countries for EUR.
replace countrycode="EUR" if countrycode=="AUT" | countrycode=="BEL" | countrycode=="BGR" | countrycode=="CHE" | countrycode=="CYP" | countrycode=="CZE" | countrycode=="DEU" | countrycode=="DNK" | countrycode=="ESP" | countrycode=="EST" | countrycode=="FIN" | countrycode=="FRA" | countrycode=="GBR" | countrycode=="GRC" | countrycode=="HRV" | countrycode=="HUN" | countrycode=="IRL" | countrycode=="ITA" | countrycode=="LTU" | countrycode=="LUX" | countrycode=="LVA" | countrycode=="MLT" | countrycode=="NLD" | countrycode=="NOR" | countrycode=="POL" | countrycode=="PRT" | countrycode=="ROU" | countrycode=="SVK" | countrycode=="SVN"| countrycode=="SWE"

*Replace countries for ROW.
replace countrycode="ROW" if countrycode!="USA" & countrycode!="JPN" & countrycode!="CHN" & countrycode!="EUR" & countrycode!="CAN"

*Collapse database.
collapse (sum) emp hours rgdpe, by(countrycode)

*Normalize variables.
foreach var of varlist emp hours rgdpe{
	gen den_`var'=`var' if countrycode=="USA"
	qui sum den_`var'
	replace den_`var'=`r(max)' if den_`var'==.
	replace `var'=`var'/den_`var'
	drop den_`var'
}

replace countrycode="AUSA" if countrycode=="USA"
sort countrycode
replace countrycode="USA" if countrycode=="AUSA"

*Save database.
save "./temp_files/pwt_calibration.dta", replace
export delimited using "./temp_files/pwt_calibration.csv", replace

/////////////////
///2 countries///
/////////////////

*Open database.
use "./temp_files/pwt_calibration_int.dta", clear
drop country

*List countries.
rename countrycode country
levelsof country, local(countries)
local not ROW
local countries_: list countries - not

foreach c of local countries_ {
	
	preserve
	
		*Rename countries.
		replace country="ROW" if country!="`c'"
		
		*Collapse database.
		collapse (sum) emp hours rgdpe, by(country)

		*Normalize variables.
		foreach var of varlist emp hours rgdpe{
			gen den_`var'=`var' if country=="`c'"
			qui sum den_`var'
			replace den_`var'=`r(max)' if den_`var'==.
			replace `var'=`var'/den_`var'
			drop den_`var'
		}
		
		*Sort database.
		replace country="ZROW" if country=="ROW"
		sort country
		replace country="ROW" if country=="ZROW"
		
		*Save database.
		save "./temp_files/pwt_calibration_`c'.dta", replace
		export delimited using "./temp_files/pwt_calibration_`c'.csv", replace
	
	restore
	
}

*Generate list of countries.
keep country
duplicates drop country, force
gen pwt=1
save "./temp_files/pwt_list.dta", replace