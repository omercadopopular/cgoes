clear all
set more off

cap log close
log using "./output/logs/log_t04.smcl", append

///////////////////
///Preliminaries///
///////////////////

*Import dataset.
import delimited "./data/WIOD/WIOT2006_Nov16_ROW.csv", clear 

*Drop rows and variables.
drop in 1/4
drop v1 v2 v4

*Rename variables.
replace v3="v3" if v3==""
replace v5="v5" if v5==""
replace v6="v6" if v6==""
foreach v of varlist _all {
    local newname = "_" + `v'[1] + "_" + `v'[2]
    rename `v' `newname'
}
drop in 1/2

*Generate source country and sector.
rename _v3_v3 source_sw  //this is "row_name"
rename _v5_v5 source_c
gen row_item = substr(_v6_v6,2,3)  //this is "row_item" (which is just a sector number)
drop _v6_v6
order source_sw source_c row_item
drop source_sw

*Rename total.
*rename _TOT_c62 TOT

*Destring variables.
foreach var of varlist _all{
	qui destring `var',replace
}

*Only keep final goods.
forvalues c=1(1)56{
    drop _*_c`c'
}

*Generate total consumption by country. NP -- this is total consumption by the column country of the source_c (row country)'s output in the row sector
levelsof source_c, local(country)
foreach c of local country{
	egen _`c'_tot=rowtotal(_`c'_c*)
	drop _`c'_c*
}

*Collapse supply by sector.
gen sector=""
replace sector="Goods" if row_item>=1 & row_item<=23
replace sector="Services" if row_item>=24 & row_item<=56
collapse (sum) _*_tot, by(source_c sector)

*Reshape database.
reshape long _, i(source_c sector) j(col, str)
gen dest_c=substr(col,1,3)
drop col
rename _ exports
order source dest sector exports

*Drop totals.
drop if source_c=="TOT" | dest_c=="TOT"

*List of countries.
levelsof source_c, local(countries)
local not ROW
local countries_: list countries - not

foreach c of local countries_{

	preserve

		*Replace countries for ROW.
		replace source_c="ROW" if source_c!="`c'"
		replace dest_c="ROW" if dest_c!="`c'"

		*Collapse spending by sector and country-pair.
		collapse (sum) exports, by(source_c dest_c)
		
		*Generate totals.
		egen total=sum(exports), by(dest_c)
		
		*Generate shares -- now this is source_c's share in dest_c's imports in a sector
		gen share_im=exports/total
		
		*Drop observations.
		keep if source_c==dest_c
		keep source_c share_im
		rename source_c country
		keep if country=="`c'"

		*Save database.
		save "./temp_files/wiod_import_`c'.dta", replace
	
	restore
	
}


/////////////////////////
///ACR formula (table)///
/////////////////////////

clear all
set obs 1

*Generate list of countries.
local countries AUS AUT BEL BGR BRA CAN CHE CHN CYP CZE DEU DNK ESP EST FIN FRA GBR GRC HRV HUN IDN IND IRL ITA JPN KOR LTU LUX LVA MEX MLT NLD NOR POL PRT ROU RUS SVK SVN SWE TUR TWN USA

gen country=""
foreach c of local countries{
	replace country="`c'" if country==""
	qui count
	local NN=`r(N)'+1
	set obs `NN'
}

*Merge with domestic shares.
foreach c of local countries{
	merge 1:1 country using "./temp_files/wiod_import_`c'.dta", nogen update
}

*Generate median.
replace country="MEDIAN" if country==""
qui sum share_im, d
replace share_im=`r(p50)' if country=="MEDIAN"

*Calculate welfare gains.
local epsilon=2
gen w_acr_t_1=((share_im^(-1/(`epsilon'-1)))-1)*100
local epsilon=6
gen w_acr_t_2=((share_im^(-1/(`epsilon'-1)))-1)*100
local epsilon=11
gen w_acr_t_3=((share_im^(-1/(`epsilon'-1)))-1)*100

*Table.
gen order=.
replace order=1 if country=="CAN"
replace order=2 if country=="FRA"
replace order=3 if country=="DEU"
replace order=4 if country=="ITA"
replace order=5 if country=="JPN"
replace order=6 if country=="GBR"
replace order=7 if country=="USA"
replace order=8 if country=="BRA"
replace order=9 if country=="CHN"
replace order=10 if country=="IND"
replace order=11 if country=="MEX"
replace order=12 if country=="RUS"
replace order=13 if country=="MEDIAN"
sort order
format w_acr_t_1 w_acr_t_2 w_acr_t_3 %9.2f

save "./output/tables/gft_acr_table", replace

* erase
local countries AUS AUT BEL BGR BRA CAN CHE CHN CYP CZE DEU DNK ESP EST FIN FRA GBR GRC HRV HUN IDN IND IRL ITA JPN KOR LTU LUX LVA MEX MLT NLD NOR POL PRT ROU RUS SVK SVN SWE TUR TWN USA
foreach c of local countries{
	erase "./temp_files/wiod_import_`c'.dta"
}
