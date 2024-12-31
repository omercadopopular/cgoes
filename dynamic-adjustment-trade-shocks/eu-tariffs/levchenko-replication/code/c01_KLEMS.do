clear all
set more off
set type double, permanently

cap log close
log using "./output/logs/log_c01.smcl", append

/////////////////
///EUR+USA+JPN///
/////////////////

*Open database.
use "./data/KLEMS/national accounts.dta", clear

*Keep observations from 2006.
keep if year==2006

*Drop aggregates.
drop if geo_code=="EA19" | geo_code=="EU11" | geo_code=="EU12" | geo_code=="EU15" | geo_code=="EU19" | geo_code=="EU20" | geo_code=="EU27_2020" | geo_code=="EU28"

*Keep relevant variables.
keep nace_r2_code geo_code year H_EMP H_EMPE VA_CP GO_CP
rename (nace_r2_code geo_code) (code country)
rename (*_CP) (*)

*Rename countries.
replace country="AUT" if country=="AT"
replace country="BEL" if country=="BE"
replace country="BGR" if country=="BG"
replace country="CYP" if country=="CY"
replace country="CZE" if country=="CZ"
replace country="DEU" if country=="DE"
replace country="DNK" if country=="DK"
replace country="EST" if country=="EE"
replace country="GRC" if country=="EL"
replace country="ESP" if country=="ES"
replace country="FIN" if country=="FI"
replace country="FRA" if country=="FR"
replace country="HRV" if country=="HR"
replace country="HUN" if country=="HU"
replace country="IRL" if country=="IE"
replace country="ITA" if country=="IT"
replace country="JPN" if country=="JP"
replace country="LTU" if country=="LT"
replace country="LUX" if country=="LU"
replace country="LVA" if country=="LV"
replace country="MLT" if country=="MT"
replace country="NLD" if country=="NL"
replace country="POL" if country=="PL"
replace country="PRT" if country=="PT"
replace country="ROU" if country=="RO"
replace country="SWE" if country=="SE"
replace country="SVN" if country=="SI"
replace country="SVK" if country=="SK"
replace country="GBR" if country=="UK"
replace country="USA" if country=="US"

*Generate sector.
gen sector=""
replace sector="A-B" if code=="A" | code=="B"
replace sector="Non-durables" if code=="C10-C12"
replace sector="Upstream" if code=="C13-C15" | code=="C16-C18" | code=="C19" | code=="C20-C21" | code=="C22-C23" | code=="C24-C25"
replace sector="Machinery" if code=="C26-C27" | code=="C28" | code=="C29-C30" | code=="C31-C33"
replace sector="D-U" if code=="D-E" | code=="F" | code=="G" | code=="H" | code=="I" | code=="J" | code=="K" | code=="L" | code=="M-N" | code=="O-Q" | code=="R-S" | code=="T" | code=="U"
drop if sector==""
drop code
drop year

*Collapse by sector.
collapse (sum) H_EMP H_EMPE VA, by(country sector)

*Replace units.
replace H_EMP=1000*H_EMP
replace H_EMPE=1000*H_EMPE
replace VA=1000000*VA

*Save database.
save "./temp_files/EUR_USA_JPN.dta", replace

/*
/////////////
///EUR+USA///
/////////////

*Import database.
import delimited "ALL_output_17ii.txt", clear

*Reshape database.
reshape long _, i(country var code) j(year, str)

*Keep observations from 2006.
destring year, replace force
keep if year==2006

*Keep relevant variables.
keep if var=="H_EMP" | var=="H_EMPE" | var=="VA" | var=="VA_QI" | var=="L_QI" | var=="LAB_QI"

*Reshape database.
reshape wide _, i(country code) j(var, str)
rename _* *

*Rename countries.
replace country="AUT" if country=="AT"
replace country="BEL" if country=="BE"
replace country="BGR" if country=="BG"
replace country="CYP" if country=="CY"
replace country="CZE" if country=="CZ"
replace country="DEU" if country=="DE"
replace country="DNK" if country=="DK"
replace country="EST" if country=="EE"
replace country="GRC" if country=="EL"
replace country="ESP" if country=="ES"
replace country="FIN" if country=="FI"
replace country="FRA" if country=="FR"
replace country="HRV" if country=="HR"
replace country="HUN" if country=="HU"
replace country="IRL" if country=="IE"
replace country="ITA" if country=="IT"
replace country="JPN" if country=="JP"
replace country="LTU" if country=="LT"
replace country="LUX" if country=="LU"
replace country="LVA" if country=="LV"
replace country="MLT" if country=="MT"
replace country="NLD" if country=="NL"
replace country="POL" if country=="PL"
replace country="PRT" if country=="PT"
replace country="ROU" if country=="RO"
replace country="SWE" if country=="SE"
replace country="SVN" if country=="SI"
replace country="SVK" if country=="SK"
replace country="GBR" if country=="UK"
replace country="USA" if country=="US"

*Generate sector.
gen sector=""
replace sector="A-B" if code=="A" | code=="B"
replace sector="Non-durables" if code=="10-12"
replace sector="Upstream" if code=="13-15" | code=="16-18" | code=="19" | code=="20-21" | code=="22-23" | code=="24-25"
replace sector="Machinery" if code=="26-27" | code=="28" | code=="29-30" | code=="31-33"
replace sector="D-U" if code=="D-E" | code=="F" | code=="G" | code=="H" | code=="I" | code=="J" | code=="K" | code=="L" | code=="M-N" | code=="O-U"
drop if sector==""
drop code
drop year

*****Collapse by sector.
collapse (sum) H_EMP H_EMPE VA, by(country sector)

*Replace units.
replace H_EMP=1000*H_EMP
replace H_EMPE=1000*H_EMPE
replace VA=1000000*VA

*Save database.
save "./temp_files/EUR_USA.dta", replace

/////////
///JPN///
/////////
//Different classification

*Open database.
import excel "JPN_wk_may_2013", sheet("DATA") firstrow clear
rename Variable var
drop if var==""

*Reshape database.
drop desc
reshape long _, i(var code) j(year, str)

*Keep observations from 2006.
destring year, replace force
keep if year==2006

*Keep relevant variables.
keep if var=="H_EMP" | var=="H_EMPE" | var=="VA" | var=="VA_QI" | var=="L_QI"

*Reshape database.
reshape wide _, i(code) j(var, str)
rename _* *

*Generate country name.
gen country="JPN"

*Generate sector.
gen sector=""
replace sector="A-B" if code=="A" | code=="B" | code=="C"
replace sector="Non-durables" if code=="15t16"
replace sector="Upstream" if code=="17t19" | code=="20" | code=="21t22" | code=="23t25" | code=="26" | code=="27t28"
replace sector="Machinery" if code=="29" | code=="30t33" | code=="34" | code=="35" | code=="36t37"
replace sector="D-U" if code=="E" | code=="F" | code=="G" | code=="H" | code=="I" | code=="J" | code=="K" | code=="LtQ"
drop if sector==""
drop code
drop year

*****Collapse by sector.
collapse (sum) H_EMP VA, by(country sector)

*Replace units.
replace H_EMP=1000000*H_EMP
replace VA=1000000*VA

*Save database.
save "./temp_files/JPN.dta", replace
*/
/////////
///CAN///
/////////
//Different classification

*Open database.
import excel "./data/KLEMS/CAN_WK_07_2012.xlsx", sheet("DATA") firstrow clear
rename Variable var
drop if var==""

*Reshape database.
drop desc
reshape long _, i(var code) j(year, str)

*Keep observations from 2006.
destring year, replace force
keep if year==2006

*Keep relevant variables.
keep if var=="H_EMP" | var=="H_EMPE" | var=="VA" | var=="VA_QI" | var=="L_QI"

*Reshape database.
reshape wide _, i(code) j(var, str)
rename _* *

*Generate country name.
gen country="CAN"

*Generate sector.
gen sector=""
replace sector="A-B" if code=="AtB" | code=="C"
replace sector="Non-durables" if code=="15t16"
replace sector="Upstream" if code=="17t19" | code=="20" | code=="21t22" | code=="23" | code=="24" | code=="25" | code=="26" | code=="27t28"
replace sector="Machinery" if code=="29" | code=="30t33" | code=="34t35" | code=="36t37"
replace sector="D-U" if code=="E" | code=="F" | code=="50" | code=="51" | code=="52" | code=="H" | code=="60t63" | code=="64" | code=="J" | code=="70" | code=="71t74" | code=="L" | code=="M" | code=="N" | code=="O" | code=="P"
drop if sector==""
drop code
drop year

*****Collapse by sector.
collapse (sum) H_EMP H_EMPE VA, by(country sector)

*Replace units.
replace H_EMP=1000000*H_EMP
replace H_EMPE=1000000*H_EMPE
replace VA=1000000*VA

*Save database.
save "./temp_files/CAN.dta", replace

/////////
///CHN///
/////////
//Different classification

*Import database.
import excel "./data/KLEMS/CIP_3.0_(2015)_1.01.xlsx", sheet("Output (nominal)") firstrow clear
drop in 1/2
rename (CIP AB) (code GO)

*Drop variables.
keep code GO

*Save auxiliary database.
save "./temp_files/aux_CHN_GO.dta", replace

*Import database.
import excel "./data/KLEMS/CIP_3.0_(2015)_1.05.xlsx", sheet("Consumption of fixed capital") firstrow clear
drop in 1/3
rename (CIP J K) (code VA_1_2005 VA_1_2007)

*Drop variables.
keep code VA_1_2005 VA_1_2007

*Save auxiliary database.
save "./temp_files/aux_CHN_VA_1.dta", replace

*Import database.
import excel "./data/KLEMS/CIP_3.0_(2015)_1.05.xlsx", sheet("Compensation of employees") firstrow clear
drop in 1/3
rename (CIP J K) (code VA_2_2005 VA_2_2007)

*Drop variables.
keep code VA_2_2005 VA_2_2007

*Save auxiliary database.
save "./temp_files/aux_CHN_VA_2.dta", replace

*Import database.
import excel "./data/KLEMS/CIP_3.0_(2015)_1.05.xlsx", sheet("Operating surplus") firstrow clear
drop in 1/3
rename (CIP J K) (code VA_3_2005 VA_3_2007)

*Drop variables.
keep code VA_3_2005 VA_3_2007

*Save auxiliary database.
save "./temp_files/aux_CHN_VA_3.dta", replace

*Import database.
import excel "./data/KLEMS/CIP_3.0_(2015)_1.05.xlsx", sheet("Net production tax") firstrow clear
drop in 1/3
rename (CIP J K) (code VA_4_2005 VA_4_2007)

*Drop variables.
keep code VA_4_2005 VA_4_2007

*Save auxiliary database.
save "./temp_files/aux_CHN_VA_4.dta", replace

*Merge databases.
use "./temp_files/aux_CHN_VA_1.dta", clear
merge 1:1 code using "./temp_files/aux_CHN_VA_2.dta", nogen
merge 1:1 code using "./temp_files/aux_CHN_VA_3.dta", nogen
merge 1:1 code using "./temp_files/aux_CHN_VA_4.dta", nogen

*Generate totals.
egen VA_2005=rowtotal(VA_*_2005)
egen VA_2007=rowtotal(VA_*_2007)

*Generate average.
egen VA=rowmean(VA_2005 VA_2007)

*Drop variables.
keep code VA

*Save auxiliary database.
save "./temp_files/aux_CHN_VA.dta", replace

*Import database.
import excel "./data/KLEMS/CIP_3.0_(2015)_3.02.xlsx", sheet("Sheet1") firstrow clear
drop in 1/2
rename (CIP AC) (code H_EMP)

*Drop variables.
keep code H_EMP

*Save auxiliary database.
save "./temp_files/aux_CHN_H_EMP.dta", replace

*Merge databases.
use "./temp_files/aux_CHN_GO.dta", clear
merge 1:1 code using "./temp_files/aux_CHN_VA.dta", nogen
merge 1:1 code using "./temp_files/aux_CHN_H_EMP.dta", nogen
drop if code==""

*Generate country name.
gen country="CHN"

*Generate sector.
destring code, force replace
gen sector=""
replace sector="A-B" if code>=1 & code<=5
replace sector="Non-durables" if code>=6 & code<=7
replace sector="Upstream" if code>=8 & code<=18
replace sector="Machinery" if code>=19 & code<=24
replace sector="D-U" if code>=25 & code<=37
drop if sector==""
drop code

*****Collapse by sector.
collapse (sum) H_EMP VA, by(country sector)

*Replace units.
replace H_EMP=1000000*H_EMP
replace VA=1000000*VA

*Save database.
save "./temp_files/CHN.dta", replace

/////////
///RUS///
/////////
//Different classification

*Open database.
import excel "./data/KLEMS/RUS_wk_march_2017.xlsx", sheet("DATA") firstrow clear
rename Variable var
drop if var==""

*Reshape database.
drop desc
reshape long _, i(var code) j(year, str)

*Keep observations from 2006.
destring year, replace force
keep if year==2006

*Keep relevant variables.
keep if var=="H_EMP" | var=="H_EMPE" | var=="VA" | var=="VA_QI" | var=="L_QI"

*Reshape database.
reshape wide _, i(code) j(var, str)
rename _* *

*Generate country name.
gen country="RUS"

*Generate sector.
gen sector=""
replace sector="A-B" if code=="AtB" | code=="C"
replace sector="Non-durables" if code=="15t16"
replace sector="Upstream" if code=="17t19" | code=="20" | code=="21t22" | code=="23t25" | code=="26" | code=="27t28"
replace sector="Machinery" if code=="29" | code=="30t33" | code=="34t35" | code=="36t37"
replace sector="D-U" if code=="E" | code=="F" | code=="G" | code=="H" | code=="I" | code=="J" | code=="K" | code=="LtQ"
drop if sector==""
drop code
drop year

*****Collapse by sector.
collapse (sum) H_EMP VA, by(country sector)

*Replace units.
replace H_EMP=1000000*H_EMP
replace VA=1000000*VA

*Save database.
save "./temp_files/RUS.dta", replace

/////////
///TWN///
/////////

foreach var in VA VA_QI H_EMP H_EMPE{
	
	*Import database.
	import excel "./data/KLEMS/TAIWAN-Basic File_2013.xlsx", sheet("`var'") firstrow clear
	rename (Industry AC) (code `var')

	*Drop variables.
	keep code `var'
	
	*Destring variables.
	cap destring `var', force replace

	*Save auxiliary database.
	save "./temp_files/aux_twn_`var'.dta", replace

}

*Merge databases.
use "./temp_files/aux_twn_VA.dta", clear
*merge 1:1 code using "./temp_files/aux_twn_GO.dta", nogen
merge 1:1 code using "./temp_files/aux_twn_H_EMP.dta", nogen
merge 1:1 code using "./temp_files/aux_twn_H_EMPE.dta", nogen

*Generate country name.
gen country="TWN"

*Generate sector.
gen sector=""
replace sector="A-B" if code>=1 & code<=2
replace sector="Non-durables" if code==3
replace sector="Upstream" if code>=4 & code<=11
replace sector="Machinery" if code>=12 & code<=15
replace sector="D-U" if code>=16 & code<=32
drop if sector==""
drop code

*****Collapse by sector.
collapse (sum) H_EMP H_EMPE VA, by(country sector)

*Replace units.
replace H_EMP=1000000*H_EMP
replace H_EMPE=1000000*H_EMPE
replace VA=1000000*VA

*Save database.
save "./temp_files/TWN.dta", replace

///////////
///LATAM///
///////////

foreach country in CHI COL CRI ELS HON MEX PER RDO{

	foreach var in VA GO H_EMP H_EMPE{
		
		*Import database.
		import excel "./data/KLEMS/`country'_AB_2021-07_ESP.xlsx", sheet("`var'") firstrow clear
		rename (S) (`var')

		*Drop variables.
		keep code `var'
		drop if code==""
		collapse (sum) `var', by(code)

		*Save auxiliary database.
		save "./temp_files/aux_`country'_`var'.dta", replace

	}

	*Merge databases.
	use "./temp_files/aux_`country'_VA.dta", clear
	merge 1:1 code using "./temp_files/aux_`country'_GO.dta", nogen
	merge 1:1 code using "./temp_files/aux_`country'_H_EMP.dta", nogen
	merge 1:1 code using "./temp_files/aux_`country'_H_EMPE.dta", nogen

	*Generate country name.
	gen country="`country'"
	
	*Generate sector.
	gen sector=""
	replace sector="A-B" if code=="AtB" | code=="C"
	replace sector="Non-durables" if code=="15t16"
	replace sector="Upstream" if code=="17t19" | code=="20" | code=="21t22" | code=="23t25" | code=="26" | code=="27t28"
	replace sector="Machinery" if code=="29" | code=="30t33" | code=="34t35" | code=="36t37"
	replace sector="D-U" if code=="E" | code=="F" | code=="G" | code=="H" | code=="I" | code=="J" | code=="K" | code=="LtQ"
	drop if sector==""
	drop code

	*****Collapse by sector.
	collapse (sum) H_EMP H_EMPE VA, by(country sector)
	
	*Replace units.
	replace H_EMP=1*H_EMP			//Dataset says hours, but I believe it should be millions of hours
	replace H_EMPE=1*H_EMPE			//Dataset says hours, but I believe it should be millions of hours
	replace VA=1000000*VA

	*Save database.
	save "./temp_files/`country'.dta", replace

}

/////////
///KOR///
/////////

foreach var in VA GO H_EMP H_EMPE{

	*Import database.
	import excel "./data/KLEMS/KOR_WK_2015_YL.xlsx", sheet("`var'") firstrow clear
	rename (EUKLEMScode _2006) (code `var')

	*Drop variables.
	keep code `var'

	*Save auxiliary database.
	save "./temp_files/aux_kor_`var'.dta", replace
	
}

*Merge databases.
use "./temp_files/aux_kor_VA.dta", clear
merge 1:1 code using "./temp_files/aux_kor_GO.dta", nogen
merge 1:1 code using "./temp_files/aux_kor_H_EMP.dta", nogen
merge 1:1 code using "./temp_files/aux_kor_H_EMPE.dta", nogen

*Generate country name.
gen country="KOR"

*Generate sector.
gen sector=""
replace sector="A-B" if code=="_1" | code=="_2" | code=="_B" | code=="_10" | code=="_11" | code=="_12" | code=="_13" | code=="_14"
replace sector="Non-durables" if code=="_15" | code=="_16"
replace sector="Upstream" if code=="_17" | code=="_18" | code=="_19" | code=="_20" | code=="_21" | code=="_221" | code=="_22x" | code=="_23" | code=="_244" | code=="_24x" | code=="_25" | code=="_26" | code=="_27" | code=="_28"
replace sector="Machinery" if code=="_29" | code=="_30" | code=="_313" | code=="_31x" | code=="_321" | code=="_322" | code=="_323" | code=="_331t3" | code=="_334t5" | code=="_34" | code=="_351" | code=="_353" | code=="_35x" | code=="_36" | code=="_37"
replace sector="D-U" if code=="_40x" | code=="_402" | code=="_41" | code=="_F" | code=="_50" | code=="_51" | code=="_52" | code=="_H" | code=="_60" | code=="_61" | code=="_62" | code=="_63" | code=="_64" | code=="_65" | code=="_66" | code=="_67" | code=="_70imp" | code=="_70x" | code=="_71" | code=="_72" | code=="_73" | code=="_741t4" | code=="_745t8" | code=="_L" | code=="_M" | code=="_N" | code=="_90" | code=="_91" | code=="_921t2" | code=="_923t7" | code=="_93" | code=="_P" | code=="_Q"
drop if sector==""
drop code

*****Collapse by sector.
collapse (sum) H_EMP H_EMPE VA, by(country sector)

*Replace units.
replace H_EMP=1000000*H_EMP
replace H_EMPE=1000000*H_EMPE
replace VA=1000000*VA

*Save database.
save "./temp_files/KOR.dta", replace

////////////////////
///Exchange rates///
////////////////////

*Import database.
import excel "./data/KLEMS/fx_lcu.xlsx", sheet("Data") firstrow clear

*Drop missings.
drop if CountryCode==""

*Drop variables.
keep CountryCode E

*Rename variable.
rename E gdp_lcu

*Destring variable.
destring gdp_lcu, force replace

*Save database.
save "./temp_files/aux_gdp_lcu.dta", replace

*Import database.
import excel "./data/KLEMS/fx_usd.xlsx", sheet("Data") firstrow clear

*Drop missings.
drop if CountryCode==""

*Drop variables.
keep CountryCode E

*Rename variable.
rename E gdp_usd

*Destring variable.
destring gdp_usd, force replace

*Save database.
save "./temp_files/aux_gdp_usd.dta", replace

*Merge databases.
merge 1:1 CountryCode using "./temp_files/aux_gdp_lcu.dta", nogen

*Generate exchange rate.
gen fx=gdp_usd/gdp_lcu

*Keep countries with exchange rate.
drop if fx==.

*Rename variable.
rename CountryCode country

*Save database.
keep country fx
save "./temp_files/fx.dta", replace

///////////
///Merge///
///////////

*Append databases.
clear
foreach c in EUR_USA_JPN CAN CHN RUS KOR TWN CHI COL CRI ELS HON MEX PER RDO{
    append using "./temp_files/`c'.dta"
}
replace country="SLV" if country=="ELS"
replace country="DOM" if country=="RDO"
replace country="CHL" if country=="CHI"

*Keep countries with all sectors.
drop if H_EMP==0
duplicates tag country, gen(dup)
replace dup=dup+1
drop if dup<5
drop dup

*Merge with exchange rates.
merge m:1 country using "./temp_files/fx.dta"
keep if _merge==3
drop _merge

*Manual cleaning.
drop if country=="MEX"						//Weird values

*Transform variables into USD.
gen VA_usd=VA*fx

*Save database.
save "./temp_files/klems.dta", replace

////////////////////////////
///5 countries, 5 sectors///
////////////////////////////

*Open database.
use "./temp_files/klems.dta", clear

*Generate aggregates.
replace country="EUR" if country=="AUT" | country=="BEL" | country=="BGR" | country=="CHE" | country=="CYP" | country=="CZE" | country=="DEU" | country=="DNK" | country=="ESP" | country=="EST" | country=="FIN" | country=="FRA" | country=="GBR" | country=="GRC" | country=="HRV" | country=="HUN" | country=="IRL" | country=="ITA" | country=="LTU" | country=="LUX" | country=="LVA" | country=="MLT" | country=="NLD" | country=="NOR" | country=="POL" | country=="PRT" | country=="ROU" | country=="SVK" | country=="SVN"
replace country="ROW" if country!="USA" & country!="JPN" & country!="CHN" & country!="EUR" & country!="CAN"

*Generate totals.
collapse (sum) H_EMP VA_usd, by(country sector)

*Generate value added per hour.
gen double VA_H_EMP=VA_usd/H_EMP

replace country="AUSA" if country=="USA"
sort sector country
replace country="USA" if country=="AUSA"

*Save database.
save "./temp_files/klems_sector_55.dta", replace
export delimited using "./temp_files/klems_sector_55.csv", replace

*Normalize values.
gen den=VA_H_EMP if country=="USA" & sector=="Machinery"
qui sum den
replace den=`r(max)' if den==.
gen VA_H_EMP_n=VA_H_EMP/den
drop VA_H_EMP den
rename VA_H_EMP_n VA_H_EMP

*Save database.
save "./temp_files/klems_sector_norm_55.dta", replace
export delimited using "./temp_files/klems_sector_norm_55.csv", replace

///////////////
///2 sectors///
///////////////

*Open database.
use "./temp_files/klems.dta", clear

*Generate aggregates.
*replace country="EUR" if country=="AUT" | country=="BEL" | country=="BGR" | country=="CHE" | country=="CYP" | country=="CZE" | country=="DEU" | country=="DNK" | country=="ESP" | country=="EST" | country=="FIN" | country=="FRA" | country=="GBR" | country=="GRC" | country=="HRV" | country=="HUN" | country=="IRL" | country=="ITA" | country=="LTU" | country=="LUX" | country=="LVA" | country=="MLT" | country=="NLD" | country=="NOR" | country=="POL" | country=="PRT" | country=="ROU" | country=="SVK" | country=="SVN"
*replace country="ROW" if country!="USA" & country!="JPN" & country!="CHN" & country!="EUR" & country!="CAN"

*Generate new sectors.
gen sector_=""
replace sector_="Goods" if sector=="A-B" | sector=="Non-durables" | sector=="Upstream" | sector=="Machinery"
replace sector_="Services" if sector=="D-U"

*Collapse database.
collapse (sum) H_EMP VA_usd, by(country sector_)
rename sector_ sector

*List countries.
levelsof country, local(countries)
local not ROW
local countries_: list countries - not

foreach c of local countries_ {
	
	preserve
	
		*Rename countries.
		replace country="ROW" if country!="`c'"
		
		*Collapse database.
		collapse (sum) H_EMP VA_usd, by(country sector)
		
		*Generate value added per hour.
		gen double VA_H_EMP=VA_usd/H_EMP
		
		*Drop variables.
		keep country sector VA_H_EMP
		
		*Normalize variables.
		gen den=VA_H_EMP if country=="`c'" & sector=="Goods"
		qui sum den
		replace den=`r(max)' if den==.
		gen double VA_H_EMP_norm=VA_H_EMP/den
		drop den VA_H_EMP
		rename VA_H_EMP_norm VA_H_EMP
		
		*Sort database.
		replace country="ZROW" if country=="ROW"
		sort sector country
		replace country="ROW" if country=="ZROW"
		
		*Save database.
		save "./temp_files/klems_sector_`c'.dta", replace
		export delimited using "./temp_files/klems_sector_`c'.csv", replace
	
	restore
	
}

*Generate list of countries.
keep country
duplicates drop country, force
gen klems=1
save "./temp_files/klems_list.dta", replace