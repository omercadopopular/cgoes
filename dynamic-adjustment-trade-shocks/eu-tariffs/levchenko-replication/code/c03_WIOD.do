clear all
set more off
set type double, permanently

cap log close
log using "./output/logs/log_c03.smcl", append

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

*Save intermediate database.
save "./temp_files/wiod_int.dta", replace

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

*Save database.
save "./temp_files/wiod_work.dta", replace

///////////////////////////////////////
///Spending by sector and by country///
///////////////////////////////////////

*Open database.
use "./temp_files/wiod_work.dta", clear

*Replace countries for EUR.
*replace source_c="EUR" if source_c=="AUT" | source_c=="BEL" | source_c=="BGR" | source_c=="CHE" | source_c=="CYP" | source_c=="CZE" | source_c=="DEU" | source_c=="DNK" | source_c=="ESP" | source_c=="EST" | source_c=="FIN" | source_c=="FRA" | source_c=="GBR" | source_c=="GRC" | source_c=="HRV" | source_c=="HUN" | source_c=="IRL" | source_c=="ITA" | source_c=="LTU" | source_c=="LUX" | source_c=="LVA" | source_c=="MLT" | source_c=="NLD" | source_c=="NOR" | source_c=="POL" | source_c=="PRT" | source_c=="ROU" | source_c=="SVK" | source_c=="SVN" | source_c=="SWE"
*replace dest_c="EUR" if dest_c=="AUT" | dest_c=="BEL" | dest_c=="BGR" | dest_c=="CHE" | dest_c=="CYP" | dest_c=="CZE" | dest_c=="DEU" | dest_c=="DNK" | dest_c=="ESP" | dest_c=="EST" | dest_c=="FIN" | dest_c=="FRA" | dest_c=="GBR" | dest_c=="GRC" | dest_c=="HRV" | dest_c=="HUN" | dest_c=="IRL" | dest_c=="ITA" | dest_c=="LTU" | dest_c=="LUX" | dest_c=="LVA" | dest_c=="MLT" | dest_c=="NLD" | dest_c=="NOR" | dest_c=="POL" | dest_c=="PRT" | dest_c=="ROU" | dest_c=="SVK" | dest_c=="SVN" | dest_c=="SWE"            

*List of countries.
levelsof source_c, local(countries)
local not ROW
local countries_: list countries - not

foreach c of local countries_{

	preserve

		*Replace countries for ROW.
		replace source_c="ROW" if source_c!="`c'"
		replace dest_c="ROW" if dest_c!="`c'"

		*Collapse spending by sector and country.
		collapse (sum) exports, by(dest_c sector)

		*Generate totals.
		egen total=sum(exports), by(dest_c)

		*Generate shares.
		gen share_sp=exports/total

		*Keep variables.
		keep dest_c sector share

		*Sort database.
		replace dest_c="ZROW" if dest_c=="ROW"
		sort sector dest_c
		replace dest_c="ROW" if dest_c=="ZROW"
		
		*Save database.
		encode sector, gen(sector_)
		drop sector
		rename sector_ sector
		save "./temp_files/wiod_spending_sector_`c'.dta", replace
		export delimited using "./temp_files/wiod_spending_sector_`c'.csv", replace
	
	restore
	
}

/////////////////////////////////////////
///Import shares by sector and country///
/////////////////////////////////////////

*Open database.
use "./temp_files/wiod_work.dta", clear

*Replace countries for EUR.
*replace source_c="EUR" if source_c=="AUT" | source_c=="BEL" | source_c=="BGR" | source_c=="CHE" | source_c=="CYP" | source_c=="CZE" | source_c=="DEU" | source_c=="DNK" | source_c=="ESP" | source_c=="EST" | source_c=="FIN" | source_c=="FRA" | source_c=="GBR" | source_c=="GRC" | source_c=="HRV" | source_c=="HUN" | source_c=="IRL" | source_c=="ITA" | source_c=="LTU" | source_c=="LUX" | source_c=="LVA" | source_c=="MLT" | source_c=="NLD" | source_c=="NOR" | source_c=="POL" | source_c=="PRT" | source_c=="ROU" | source_c=="SVK" | source_c=="SVN" | source_c=="SWE"
*replace dest_c="EUR" if dest_c=="AUT" | dest_c=="BEL" | dest_c=="BGR" | dest_c=="CHE" | dest_c=="CYP" | dest_c=="CZE" | dest_c=="DEU" | dest_c=="DNK" | dest_c=="ESP" | dest_c=="EST" | dest_c=="FIN" | dest_c=="FRA" | dest_c=="GBR" | dest_c=="GRC" | dest_c=="HRV" | dest_c=="HUN" | dest_c=="IRL" | dest_c=="ITA" | dest_c=="LTU" | dest_c=="LUX" | dest_c=="LVA" | dest_c=="MLT" | dest_c=="NLD" | dest_c=="NOR" | dest_c=="POL" | dest_c=="PRT" | dest_c=="ROU" | dest_c=="SVK" | dest_c=="SVN" | dest_c=="SWE"            

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
		collapse (sum) exports, by(source_c dest_c sector)
		
		*Generate totals.
		egen total=sum(exports), by(dest_c sector)
		
		*Generate shares -- now this is source_c's share in dest_c's imports in a sector
		gen share_im=exports/total
		
		*Keep variables.
		keep dest_c source_c sector share
		
		*Sort database.
		replace dest_c="ZROW" if dest_c=="ROW"
		replace source_c="ZROW" if source_c=="ROW"
		sort sector source_c dest_c 
		replace dest_c="ROW" if dest_c=="ZROW"
		replace source_c="ROW" if source_c=="ZROW"

		*Save database.
		encode sector, gen(sector_)
		drop sector
		rename sector_ sector
		save "./temp_files/wiod_import_sector_`c'.dta", replace
		export delimited using "./temp_files/wiod_import_sector_`c'.csv", replace
	
	restore
	
}

*Generate list of countries.
keep source_c
duplicates drop source_c, force
rename source_c country
gen wiod=1
save "./temp_files/wiod_list.dta", replace

//////////////////////////////
///Import shares by country///
//////////////////////////////

*Open database.
use "./temp_files/wiod_work.dta", clear

*Replace countries for EUR.
*replace source_c="EUR" if source_c=="AUT" | source_c=="BEL" | source_c=="BGR" | source_c=="CHE" | source_c=="CYP" | source_c=="CZE" | source_c=="DEU" | source_c=="DNK" | source_c=="ESP" | source_c=="EST" | source_c=="FIN" | source_c=="FRA" | source_c=="GBR" | source_c=="GRC" | source_c=="HRV" | source_c=="HUN" | source_c=="IRL" | source_c=="ITA" | source_c=="LTU" | source_c=="LUX" | source_c=="LVA" | source_c=="MLT" | source_c=="NLD" | source_c=="NOR" | source_c=="POL" | source_c=="PRT" | source_c=="ROU" | source_c=="SVK" | source_c=="SVN" | source_c=="SWE"
*replace dest_c="EUR" if dest_c=="AUT" | dest_c=="BEL" | dest_c=="BGR" | dest_c=="CHE" | dest_c=="CYP" | dest_c=="CZE" | dest_c=="DEU" | dest_c=="DNK" | dest_c=="ESP" | dest_c=="EST" | dest_c=="FIN" | dest_c=="FRA" | dest_c=="GBR" | dest_c=="GRC" | dest_c=="HRV" | dest_c=="HUN" | dest_c=="IRL" | dest_c=="ITA" | dest_c=="LTU" | dest_c=="LUX" | dest_c=="LVA" | dest_c=="MLT" | dest_c=="NLD" | dest_c=="NOR" | dest_c=="POL" | dest_c=="PRT" | dest_c=="ROU" | dest_c=="SVK" | dest_c=="SVN" | dest_c=="SWE"            

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
		export delimited using "./temp_files/wiod_import_`c'.csv", replace
	
	restore
	
}

////////////////////////////
///5 countries, 5 sectors///
////////////////////////////

*Open intermediate database.
use "./temp_files/wiod_int.dta", clear

*Collapse supply by sector.
gen sector=""
replace sector="A-B" if row_item>=1 & row_item<=4
replace sector="Non-durables" if row_item==5
replace sector="Upstream" if row_item>=6 & row_item<=16
replace sector="Machinery" if row_item>=17 & row_item<=23
replace sector="D-U" if row_item>=24 & row_item<=56
collapse (sum) _*_tot, by(source_c sector)

*Reshape database.
reshape long _, i(source_c sector) j(col, str)
gen dest_c=substr(col,1,3)
drop col
rename _ exports
order source dest sector exports

*Drop totals.
drop if source_c=="TOT" | dest_c=="TOT"

*Save database.
save "./temp_files/wiod_work_55.dta", replace

///////////////////////////////////////////////////////////////
///Spending by sector and by country, 5 countries, 5 sectors///
///////////////////////////////////////////////////////////////

*Open database.
use "./temp_files/wiod_work_55.dta", clear

*Replace countries for EUR.
replace source_c="EUR" if source_c=="AUT" | source_c=="BEL" | source_c=="BGR" | source_c=="CHE" | source_c=="CYP" | source_c=="CZE" | source_c=="DEU" | source_c=="DNK" | source_c=="ESP" | source_c=="EST" | source_c=="FIN" | source_c=="FRA" | source_c=="GBR" | source_c=="GRC" | source_c=="HRV" | source_c=="HUN" | source_c=="IRL" | source_c=="ITA" | source_c=="LTU" | source_c=="LUX" | source_c=="LVA" | source_c=="MLT" | source_c=="NLD" | source_c=="NOR" | source_c=="POL" | source_c=="PRT" | source_c=="ROU" | source_c=="SVK" | source_c=="SVN" | source_c=="SWE"
replace dest_c="EUR" if dest_c=="AUT" | dest_c=="BEL" | dest_c=="BGR" | dest_c=="CHE" | dest_c=="CYP" | dest_c=="CZE" | dest_c=="DEU" | dest_c=="DNK" | dest_c=="ESP" | dest_c=="EST" | dest_c=="FIN" | dest_c=="FRA" | dest_c=="GBR" | dest_c=="GRC" | dest_c=="HRV" | dest_c=="HUN" | dest_c=="IRL" | dest_c=="ITA" | dest_c=="LTU" | dest_c=="LUX" | dest_c=="LVA" | dest_c=="MLT" | dest_c=="NLD" | dest_c=="NOR" | dest_c=="POL" | dest_c=="PRT" | dest_c=="ROU" | dest_c=="SVK" | dest_c=="SVN" | dest_c=="SWE"                                    

*Replace countries for ROW.
replace source_c="ROW" if source_c!="USA" & source_c!="JPN" & source_c!="CHN" & source_c!="EUR" & source_c!="CAN"
replace dest_c="ROW" if dest_c!="USA" & dest_c!="JPN" & dest_c!="CHN" & dest_c!="EUR" & dest_c!="CAN"

*Collapse spending by sector and country.
collapse (sum) exports, by(dest_c sector)

*Generate totals.
egen total=sum(exports), by(dest_c)

*Generate shares.
gen share_sp=exports/total

*Keep variables.
keep dest_c sector share

replace dest_c="AUSA" if dest_c=="USA"
sort sector dest_c
replace dest_c="USA" if dest_c=="AUSA"

*Save database.
encode sector, gen(sector_)
drop sector
rename sector_ sector
save "./temp_files/wiod_spending_sector_55.dta", replace
export delimited using "./temp_files/wiod_spending_sector_55.csv", replace

/////////////////////////////////////////////////////////////////
///Import shares by sector and country, 5 countries, 5 sectors///
/////////////////////////////////////////////////////////////////

*Open database.
use "./temp_files/wiod_work_55.dta", clear

*Replace countries for EUR.
replace source_c="EUR" if source_c=="AUT" | source_c=="BEL" | source_c=="BGR" | source_c=="CHE" | source_c=="CYP" | source_c=="CZE" | source_c=="DEU" | source_c=="DNK" | source_c=="ESP" | source_c=="EST" | source_c=="FIN" | source_c=="FRA" | source_c=="GBR" | source_c=="GRC" | source_c=="HRV" | source_c=="HUN" | source_c=="IRL" | source_c=="ITA" | source_c=="LTU" | source_c=="LUX" | source_c=="LVA" | source_c=="MLT" | source_c=="NLD" | source_c=="NOR" | source_c=="POL" | source_c=="PRT" | source_c=="ROU" | source_c=="SVK" | source_c=="SVN" | source_c=="SWE"
replace dest_c="EUR" if dest_c=="AUT" | dest_c=="BEL" | dest_c=="BGR" | dest_c=="CHE" | dest_c=="CYP" | dest_c=="CZE" | dest_c=="DEU" | dest_c=="DNK" | dest_c=="ESP" | dest_c=="EST" | dest_c=="FIN" | dest_c=="FRA" | dest_c=="GBR" | dest_c=="GRC" | dest_c=="HRV" | dest_c=="HUN" | dest_c=="IRL" | dest_c=="ITA" | dest_c=="LTU" | dest_c=="LUX" | dest_c=="LVA" | dest_c=="MLT" | dest_c=="NLD" | dest_c=="NOR" | dest_c=="POL" | dest_c=="PRT" | dest_c=="ROU" | dest_c=="SVK" | dest_c=="SVN" | dest_c=="SWE"                            

*Replace countries for ROW.
replace source_c="ROW" if source_c!="USA" & source_c!="JPN" & source_c!="CHN" & source_c!="EUR" & source_c!="CAN"
replace dest_c="ROW" if dest_c!="USA" & dest_c!="JPN" & dest_c!="CHN" & dest_c!="EUR" & dest_c!="CAN"

*Collapse spending by sector and country-pair.
collapse (sum) exports, by(source_c dest_c sector)

*Generate totals.
egen total=sum(exports), by(sector dest_c)

*Generate shares -- now this is source_c's share in dest_c's imports in a sector
gen share_im=exports/total

*Keep variables.
keep dest_c source_c sector share

replace source_c="AUSA" if source_c=="USA"
replace dest_c="AUSA" if dest_c=="USA"
sort sector source_c dest_c 
replace source_c="USA" if source_c=="AUSA"
replace dest_c="USA" if dest_c=="AUSA"

*Save database.
encode sector, gen(sector_)
drop sector
rename sector_ sector
save "./temp_files/wiod_import_sector_55.dta", replace
export delimited using "./temp_files/wiod_import_sector_55.csv", replace