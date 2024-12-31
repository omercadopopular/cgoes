clear all
set more off

cap log close
log using "./output/logs/log_d09.smcl", append

*Generate isocode file

import excel "./data/TRAINS/AllCountries.xls", firstrow clear
ren ISO3 wbcode 
ren CountryName country
drop CountryCode

set obs `= _N + 1'
replace wbcode = "IMY" if wbcode == ""
replace country = "Isle of Man" if wbcode == "IMY"

set obs `= _N + 1'
replace wbcode = "SRB" if wbcode == ""
replace country = "Serbia" if wbcode == "SRB"

set obs `= _N + 1'
replace wbcode = "WBG" if wbcode == ""
replace country = "West Bank and Gaza" if wbcode == "WBG"

set obs `= _N + 1'
replace wbcode = "CHI" if wbcode == ""
replace country = "Channel Islands" if wbcode == "CHI"

set obs `= _N + 1'
replace country = "British Virgin Islands" if country == ""

set obs `= _N + 1'
replace country = "Guernsey" if country == ""

set obs `= _N + 1'
replace country = "Turks and Caicos Islands" if country == ""

replace wbcode = "ADO" if wbcode == "AND"
replace wbcode = "GIBRA" if wbcode == "GIB"
replace wbcode = "MNE" if wbcode == "MNT"

replace country = "Anguilla" if country == "Anguila"
replace country = "Ethiopia" if country == "Ethiopia(excludes Eritrea)"
replace country = "French Guyana" if country == "French Guiana"
replace country = "Kosovo, Republic of" if country == "Kosovo"
replace country = "Macao, China" if country == "Macao"
replace country = "Timor-Leste" if country == "East Timor"
replace country = "Taiwan Province of China" if country == "Taiwan, China"
replace country = "Venezuela, RB" if country == "Venezuela"
replace country = "Yemen, Rep." if country == "Yemen"
replace country = "Serbia and Montenegro" if country == "Yugoslavia, FR (Serbia/Montene"

drop if inlist(wbcode,"ALI","ATA","ATF","BAT","BUN","BVT","CCK")
drop if inlist(wbcode,"CSK","CXR","DDR","ESH","ETF","EUN","FLK","FRE")
drop if inlist(wbcode,"GAZ","HMD","IOT","JTN","KN1","MID","NFK","NZE")
drop if inlist(wbcode,"PCE","PCN","PCZ","PMY","PSE","RYU","SBH","SER")
drop if inlist(wbcode,"SGS","SHN","SIK","SJM","SPE","SPM","SVR","SVU")
drop if inlist(wbcode,"SWK","TAN","TCA","TKL","UMI","UNS","USP","VAT")
drop if inlist(wbcode,"VDR","VGB","WAK","WLD","WLF","YDR","ZPM","ZW1")

save "./temp_files/isocodes.dta", replace


//////////////////////////////
///Temporary trade barriers///
//////////////////////////////

*Import master database.
import excel "./data/TTBD-2020/GSGD-WTO.xls", sheet("SG-Master") firstrow clear

*While the petition date is before the WTO_INIT_DATE by a few months, typically, it is missing in a lot of instances. 
*WTO initial date is available for all countries, is the earliest of the remaining date variables. Only missing for Venezuela in Turkey meat.

*Drop variables.
keep CASE SG_CTY_NAME PRODUCT WTO_INIT_DATE

*Drop missings.
drop if SG_CTY==""

*Generate year variable.
gen year=substr(WTO_INIT_DATE,-4,4)
destring year, replace

*Replace names.
replace SG_CTY_NAME="South Korea" if SG_CTY_NAME=="Korea"

*Drop years beyond dataset.
drop if year<1995

*Save master database.
save "./temp_files/main_SGD.dta", replace


*Import products database.
import excel "./data/TTBD-2020/GSGD-WTO.xls", sheet("SG-Products") firstrow clear

*Drop variables.
keep CASE_ID SG_CTY_NAME HS_CODE

*Drop missings.
drop if CASE_ID==""

*Replace names.
replace SG_CTY_NAME="Slovak Republic" if SG_CTY_NAME=="Slovakia"

*Merge with master database.
merge m:1 CASE_ID SG_CTY_NAME using "./temp_files/main_SGD.dta"
drop _merge

*Generate HS variable.
gen hs6=substr(HS_CODE,1,6)

*Drop variables.
drop HS_CODE CASE_ID WTO_INIT_DATE PROD

*Replace names.
rename SG_CTY_NAME country
replace country="United States" if country=="USA"
replace country="Egypt, Arab Rep." if country=="Egypt"
replace country="Russian Federation" if country=="Russia"
replace country="Korea, Rep." if country=="South Korea"		
replace country="Taiwan Province of China" if country=="Taiwan"
replace country="Venezuela, RB" if country=="Venezuela"

*Merge with isocodes database.
merge m:1 country using "./temp_files/isocodes.dta"
drop if _merge==2
drop _merge

*Manually assign codes for EU and GCC.
replace wbcode="EU" if country=="European Union"
replace wbcode="GCC" if country=="Gulf Cooperation Council"

*Rename code variable.
rename wbcode importer

*Drop years beyond database.
drop if year>2018

*Save database.
save "./temp_files/main_SGD.dta", replace


*Open ISO codes database to set up GCC countries.
use "./temp_files/isocodes.dta",clear

*GCC countries.
keep if country=="Bahrain"| country=="Kuwait" |country=="Oman" | country=="Qatar" | country=="Saudi Arabia" | country=="United Arab Emirates"
gen country_name=country
replace country="Gulf Cooperation Council"
save "./temp_files/GCC.dta", replace

*Merge GCC countries.
use "./temp_files/main_SGD.dta", clear
joinby country using "./temp_files/GCC.dta", unmatched(master)
replace importer=wbcode if country=="Gulf Cooperation Council"
keep country year hs6 importer
save "./temp_files/main_SGD.dta",replace

*Open ISO codes database to set up EU countries.
use "./temp_files/isocodes.dta",clear

*EU countries (pre-2003).
keep if country=="Austria"| country=="Belgium" | country=="Denmark"| country=="Finland" | country=="France" | country=="Germany" | country=="Greece" | country=="Ireland" | country=="Italy" | country=="Luxembourg" | country=="Netherlands" |country=="Portugal" | country=="Spain" | country=="Sweden" | country=="United Kingdom"
gen country_name=country
replace country="European Union"
save "./temp_files/eu_pre2003.dta", replace

*Open ISO codes database to set up EU countries.
use "./temp_files/isocodes.dta",clear

*EU countries (2004-2006).
keep if country=="Cyprus" | country=="Czech Republic" | country=="Estonia" | country=="Hungary" | country=="Latvia" | country=="Lithuania" | country=="Malta" | country=="Poland" | country=="Slovak Republic" | country=="Slovenia" 
gen country_name=country
replace country="European Union"
save "./temp_files/eu_2004-2006.dta", replace

*Open ISO codes database to set up EU countries.
use "./temp_files/isocodes.dta",clear

*EU countries (post-2007).
keep if country=="Romania"| country=="Bulgaria" | country=="Croatia"
gen eu_year=2007
replace eu_year=2013 if country=="Croatia"
gen country_name=country
replace country="European Union"
save "./temp_files/eu_post2007.dta",replace

*Merge EU countries (pre-2003).
use "./temp_files/main_SGD.dta",clear
joinby country using "./temp_files/eu_pre2003.dta"
replace country=country_name 
drop country_name
replace importer=wbcode
drop wbcode
save "./temp_files/eu_temp.dta", replace

*Merge EU countries (2004-2006).
use "./temp_files/main_SGD.dta",clear
joinby country using "./temp_files/eu_2004-2006.dta"
drop if year<2004
replace country=country_name 
drop country_name
replace importer=wbcode
drop wbcode
append using "./temp_files/eu_temp.dta"
save "./temp_files/eu_temp.dta", replace

*Merge EU countries (post-2007).
use "./temp_files/main_SGD.dta",clear
joinby country using "./temp_files/eu_post2007.dta"
drop if year<2007
drop if year<2013 & country_name=="Croatia"
replace country=country_name 
drop country_name
replace importer=wbcode
drop wbcode
drop eu_year
append using "./temp_files/eu_temp.dta"
save "./temp_files/eu_temp.dta", replace

*Merge EU.
use "./temp_files/main_SGD.dta",clear
drop if country=="European Union"
append using "./temp_files/eu_temp.dta"

*Generate TTB indicator.
gen TTB=1

*Save temporary trade barriers database.
save "./temp_files/main_SGD.dta",replace

////////////////////////////
///TTB country by country///
////////////////////////////

*** notes
*** for PERU in 2009, olive oil, init date is missing for some invoking countries (all in the EU). Manual fix with date available
*** for two other EU countries
*** in PERU in 2005 and 2007 (cotton), init date is missing for invoking country USA. notes say invocation was denied, decision was revoked.
*** actual invocation (presumably successful) is in 2009, available in data
*** For the US, some missing init_dates but not relevant for us as pre-1995

*Generate empty database.
clear
gen a=.
save "./temp_files/main_TTB.dta",replace

foreach iso in "ARG" "AUS" "BRA" "CAN" "CHL" "CHN" "CRI" "EUN" "IND" "JPN" "MEX" "PAK" "PER" "TUR" "USA" "VEN" "ZAF"{

	*Import countervailing duty database.
	import excel "./data/TTBD-2020/CVD (2020)/GCVD-`iso'.xls",firstrow sheet ("CVD-`iso'-Master") allst clear

	*Drop variables.
	keep CVD_CTY_NAME CASE_ID INV_CTY_NAME INV_CTY_CODE INIT_DATE
	
	*Drop missings.
	drop if CASE_ID==""

	*Rename variables.
	rename INV_CTY_CODE importer
	rename INV_CTY_NAME country
	rename CVD_CTY_NAME exporter_name

	*Generate exporter name.
	gen exporter="`iso'"

	*Generate year variable.
	gen year=substr(INIT_DATE,-4,4)
	drop INIT_DATE
	destring year, replace

	*Append database.
	append using "./temp_files/main_TTB.dta"
	
	*Save database.
	save "./temp_files/main_TTB.dta",replace

}

*Drop if years beyond analysis.
drop if year<1995 | year==.

*Save database.
drop a
save "./temp_files/main_TTB.dta",replace


*Generate empty database to merge with HS codes.
clear
gen a=.
save "./temp_files/TTB_hs6.dta",replace

foreach iso in "ARG" "AUS" "BRA" "CAN" "CHL" "CHN" "CRI" "EUN" "IND" "JPN" "MEX" "PAK" "PER" "TUR" "USA" "VEN" "ZAF"{

	*Import countervailing duty database. 
	import excel "./data/TTBD-2020/CVD (2020)/GCVD-`iso'.xls", firstrow sheet ("CVD-`iso'-Products") allst clear

	*Drop variables.
	keep CASE_ID HS_CODE
	
	*Generate HS code.
	gen hs6=substr(HS_CODE, 1,6)
	drop HS_CODE
	
	*Drop duplicates.
	duplicates drop
	
	*Drop missings.
	drop if CASE_ID==""

	*Append database.
	append using "./temp_files/TTB_hs6.dta"
	
	*Save database.
	save "./temp_files/TTB_hs6.dta",replace

}

*Save database.
drop a
save "./temp_files/TTB_hs6.dta",replace

*Open main database.
use "./temp_files/main_TTB.dta",clear

*Merge with HS codes database.
merge 1:m CASE_ID using "./temp_files/TTB_hs6.dta"
keep if _merge==3
drop _merge

*Drop variables.
drop CASE_ID

*Drop if missing HS code.
drop if hs6=="MI"

*Save database.
save "./temp_files/main_TTB.dta",replace


*Fix importers (EU cases).
use "./temp_files/main_TTB.dta",clear
joinby country using "./temp_files/eu_pre2003.dta"
replace country=country_name
replace importer=wbcode
drop wbcode country_name
save "./temp_files/eu_temp.dta",replace

use "./temp_files/main_TTB.dta",clear
joinby country using "./temp_files/eu_2004-2006.dta"
replace country=country_name
replace importer=wbcode
drop if year<2004
drop wbcode country_name
append using "./temp_files/eu_temp.dta"
save "./temp_files/eu_temp.dta",replace

use "./temp_files/main_TTB.dta",clear
joinby country using "./temp_files/eu_post2007.dta"
replace country=country_name
replace importer=wbcode
drop if year<2007
drop if year<2013 & country=="Croatia"
drop eu_year
drop wbcode country_name
append using "./temp_files/eu_temp.dta"
save "./temp_files/eu_temp.dta",replace

use "./temp_files/main_TTB.dta",clear
drop if country=="European Union"
append using "./temp_files/eu_temp.dta"

save "./temp_files/main_TTB.dta",replace



*Fix exporters (EU cases).
use "./temp_files/main_TTB.dta",clear
rename country importer_country
rename exporter_name country
joinby country using "./temp_files/eu_pre2003.dta"
replace country=country_name
replace exporter=wbcode
drop wbcode country_name
save "./temp_files/eu_temp.dta",replace

use "./temp_files/main_TTB.dta",clear
rename country importer_country
rename exporter_name country
joinby country using "./temp_files/eu_2004-2006.dta"
replace country=country_name
replace exporter=wbcode
drop if year<2004
drop wbcode country_name
append using "./temp_files/eu_temp.dta"
save "./temp_files/eu_temp.dta",replace

use "./temp_files/main_TTB.dta",clear
rename country importer_country
rename exporter_name country
joinby country using "./temp_files/eu_post2007.dta"
replace country=country_name
replace exporter=wbcode
drop if year<2007
drop if year<2013 & country=="Croatia"
drop eu_year
drop wbcode country_name
append using "./temp_files/eu_temp.dta"
rename country exporter_name 
rename importer_country country 
save "./temp_files/eu_temp.dta",replace

use "./temp_files/main_TTB.dta",clear
drop if exporter_name=="European Union"
append using "./temp_files/eu_temp.dta"
keep importer exporter hs6 year

*Generate TTB indicator.
gen TTB=1

*Save database.
compress
save "./temp_files/main_TTB.dta",replace


////////////////////////////
///GAD country by country///
////////////////////////////

*Generate empty database.
clear
gen a=.
save "./temp_files/main_AD.dta",replace

foreach iso in "ARG" "AUS" "BRA" "CAN" "CHL" "CHN" "COL" "CRI" "ECU" "EUN" "IDN" "IND" "ISR" "JAM" "JPN" "KOR" "MEX" "MYS" ///
"NZL" "PAK" "PER" "PHL" "PRY" "RUS" "THA" "TTO" "TUR" "TWN" "UKR" "URY" "USA" "VEN" "ZAF"{

	*Import antidumping database.
	import excel "./data/TTBD-2020/GAD (2020)/GAD-`iso'", firstrow sheet ("AD-`iso'-Master") allst clear
	
	*Drop variables.
	keep AD_CTY_NAME CASE_ID INV_CTY_NAME INV_CTY_CODE INIT_DATE
	
	*Drop missings.
	drop if CASE_ID==""

	*Rename variables.
	rename INV_CTY_CODE importer
	rename INV_CTY_NAME country
	rename AD_CTY_NAME exporter_name

	*Generate exporter code.
	gen exporter="`iso'"

	*Generate year variable.
	gen year=substr(INIT_DATE,-4,4)
	drop INIT_DATE
	destring year, replace

	*Append database.
	append using "./temp_files/main_AD.dta"
	
	*Save database.
	save "./temp_files/main_AD.dta",replace

}

*Drop if years beyond analysis.
drop if year<1995 

*Save database.
drop a
save "./temp_files/main_AD.dta",replace

*Drop pre-1995 observartions.
drop if importer=="CSV"|importer=="GDR"|importer=="YUG"
drop if exporter=="CSV"|exporter=="GDR"|exporter=="YUG"

*Fix: For Mexico, anything that is before 165 is before 1995.
gen case_number=substr(CASE_ID,-3,3)
replace case_number=subinstr(case_number,"-","",.)
replace case_number=subinstr(case_number,"D","",.)
replace case_number="" if year!=.
destring case_number, replace
drop if case_number<=165 & exporter=="MEX"
drop if case_number<=16 & exporter=="PER"

*Manual fixes.
replace year=2008 if year==. & exporter=="ARG"
replace year=2008 if year==. & exporter=="BRA"
replace year=2006 if year==. & exporter=="IDN"
replace year=1996 if year==. & CASE_ID=="KOR-AD-38"
drop if CASE_ID=="KOR-AD-57" | CASE_ID=="KOR-AD-58" | CASE_ID=="KOR-AD-59"
replace year=2000 if CASE_ID=="KOR-AD-70"
drop if year==. & exporter=="KOR"
drop if year==. & exporter=="MEX"
replace year=1996 if CASE_ID=="PER-AD-49"
replace year=1999 if CASE_ID=="PER-AD-65"
drop if CASE_ID=="PER-AD-67"|CASE_ID=="PER-AD-68"|CASE_ID=="PER-AD-89"|CASE_ID=="PER-AD-99"|CASE_ID=="PER-AD-119"
drop if year==. & exporter=="PHL"
drop if year==. & exporter=="TUR"
replace year=2002 if CASE_ID=="UKR-AD-1"|CASE_ID=="UKR-AD-2"
replace year=2006 if CASE_ID=="UKR-AD-3"|CASE_ID=="UKR-AD-4"|CASE_ID=="UKR-AD-5"
replace year=2007 if CASE_ID=="UKR-AD-7"
replace year=2009 if year==. & exporter=="ZAF"

*Drop if years beyond analysis.
drop if year>=2019

*Drop variables.
drop case_number

*Save database.
compress
save "./temp_files/main_AD.dta",replace


*Generate empty database to merge with HS codes.
clear
gen a=.
save "./temp_files/AD_prod.dta",replace

foreach iso in "ARG" "AUS" "BRA" "CAN" "CHL" "CHN" "COL" "CRI" "ECU" "EUN" "IDN" "IND" "ISR" "JAM" "JPN" "KOR" "MEX" "MYS" ///
"NZL" "PAK" "PER" "PHL" "PRY" "RUS" "THA" "TTO" "TUR" "TWN" "UKR" "URY" "USA" "VEN" "ZAF"{

	*Import antidumping database.
	import excel "./data/TTBD-2020/GAD (2020)/GAD-`iso'", firstrow sheet ("AD-`iso'-Products") allst clear
	
	*Drop variables.
	keep CASE_ID HS_CODE
	
	*Drop missings.
	drop if CASE_ID==""
	
	*Generate HS code.
	gen hs6=substr(HS_CODE,1,6)
	drop HS_CODE
	
	*Drop duplicates.
	duplicates drop
	
	*Append database.
	append using "./temp_files/AD_prod.dta"
	
	*Save database.
	save "./temp_files/AD_prod.dta",replace

}

*Save database.
drop a
save "./temp_files/AD_prod.dta",replace

*Open main database.
use "./temp_files/main_AD.dta",clear

*Merge with HS codes database.
merge 1:m CASE_ID using "./temp_files/AD_prod.dta"
keep if _merge==3
drop _merge

*Generate TTB indicator.
gen TTB=1

*Drop variables.
drop CASE_ID

*Save database.
save "./temp_files/main_AD.dta",replace


*Fix importers (EU cases).
use "./temp_files/main_AD.dta",clear
joinby country using "./temp_files/eu_pre2003.dta"
replace country=country_name
replace importer=wbcode
drop wbcode country_name
save "./temp_files/eu_temp.dta",replace

use "./temp_files/main_AD.dta",clear
joinby country using "./temp_files/eu_2004-2006.dta"
replace country=country_name
replace importer=wbcode
drop if year<2004
drop wbcode country_name
append using "./temp_files/eu_temp.dta"
save "./temp_files/eu_temp.dta",replace

use "./temp_files/main_AD.dta",clear
joinby country using "./temp_files/eu_post2007.dta"
replace country=country_name
replace importer=wbcode
drop if year<2007
drop if year<2013 & country=="Croatia"
drop eu_year
drop wbcode country_name
append using "./temp_files/eu_temp.dta"
save "./temp_files/eu_temp.dta",replace

use "./temp_files/main_AD.dta",clear
drop if country=="European Union"
append using "./temp_files/eu_temp.dta"
save "./temp_files/main_AD.dta",replace


*Fix exporters (EU cases).
use "./temp_files/main_AD.dta",clear
rename country importer_country
rename exporter_name country
joinby country using "./temp_files/eu_pre2003.dta"
replace country=country_name
replace exporter=wbcode
drop wbcode country_name
save "./temp_files/eu_temp.dta",replace

use "./temp_files/main_AD.dta",clear
rename country importer_country
rename exporter_name country
joinby country using "./temp_files/eu_2004-2006.dta"
replace country=country_name
replace exporter=wbcode
drop if year<2004
drop wbcode country_name
append using "./temp_files/eu_temp.dta"
save "./temp_files/eu_temp.dta",replace

use "./temp_files/main_AD.dta",clear
rename country importer_country
rename exporter_name country
joinby country using "./temp_files/eu_post2007.dta"
replace country=country_name
replace exporter=wbcode
drop if year<2007
drop if year<2013 & country=="Croatia"
drop eu_year
drop wbcode country_name
append using "./temp_files/eu_temp.dta"
rename country exporter_name 
rename importer_country country 
save "./temp_files/eu_temp.dta",replace

use "./temp_files/main_AD.dta",clear
drop if exporter_name=="European Union"
append using "./temp_files/eu_temp.dta"
keep importer exporter hs6 year

*Generate TTB indicator.
gen TTB=1

*Replace importer.
replace importer=trim(importer)

*Save database.
compress
save "./temp_files/main_AD.dta",replace

/////////////////////
///HS manual fixes///
/////////////////////

** HS vintages -- these data don't have information on this. We will assume the vintages are the same as other tariff data the country is reporting
*** to the WTO in that year
local namelist "AD TTB"

foreach data of local namelist{
	
	disp "`data'"
	
	*Open database.
	use "./temp_files/main_`data'.dta", clear

	*Generate vintage guess.
	gen hs_vintage_guess="H96" if year<=2001
	replace hs_vintage_guess="H02" if year<=2007 & year>=2002
	replace hs_vintage_guess="H07" if year<=2011 & year>=2007
	replace hs_vintage_guess="H12" if year<=2016 & year>=2012
	replace hs_vintage_guess="H17" if year>=2016

	*Generate old nomenclature variable. 
	gen nomen_old=hs_vintage_guess

	replace nomen_old="H17" if importer=="ALB" & year>=2017
	replace nomen_old="H12" if importer=="ALB" & year<=2016 & year>=2012
	replace nomen_old="H07" if importer=="ALB" & year<=2011 & year>=2009
	replace nomen_old="H02" if importer=="ALB" & year<=2008 & year>=2003
	replace nomen_old="H96" if importer=="ALB" & year<=2002 & year>=2000

	replace nomen_old="H17" if importer=="ARE" & year>=2019
	replace nomen_old="H12" if importer=="ARE" & year<=2016 & year>=2012
	replace nomen_old="H07" if importer=="ARE" & year<=2011 & year>=2007
	replace nomen_old="H02" if importer=="ARE" & year<=2006 & year>=2002

	replace nomen_old="H17" if importer=="ALB" & year>=2017
	replace nomen_old="H12" if importer=="ALB" & year<=2016 & year>=2012
	replace nomen_old="H07" if importer=="ALB" & year<=2011 & year>=2009
	replace nomen_old="H02" if importer=="ALB" & year<=2008 & year>=2003
	replace nomen_old="H96" if importer=="ALB" & year<=2002 & year>=2000

	replace nomen_old="H17" if importer=="ARG" & year<=2021 & year>=2019
	replace nomen_old="H12" if importer=="ARG" & year<=2017 & year>=2013
	replace nomen_old="H07" if importer=="ARG" & year<=2012 & year>=2007
	replace nomen_old="H02" if importer=="ARG" & year<=2006 & year>=2002
	replace nomen_old="H96" if importer=="ARG" & year<=2001 & year>=1996

	replace nomen_old="H17" if importer=="ARM" & year==2018
	replace nomen_old="H12" if importer=="ARM" & year<=2016 & year>=2013
	replace nomen_old="H07" if importer=="ARM" & year<=2012 & year>=2009
	replace nomen_old="H02" if importer=="ARM" & year<=2008 & year>=2006
	replace nomen_old="H96" if importer=="ARM" & year<=2005 & year>=2003

	replace nomen_old="H07" if importer=="ATG" & year<=2016 & year>=2012
	replace nomen_old="H02" if importer=="ATG" & year<=2011 & year>=2010
	replace nomen_old="H96" if importer=="ATG" & year<=2009 & year>=1996

	replace nomen_old="H17" if importer=="AUS" & year<=2021 & year>=2017
	replace nomen_old="H12" if importer=="AUS" & year<=2016 & year>=2012
	replace nomen_old="H07" if importer=="AUS" & year<=2011 & year>=2007
	replace nomen_old="H02" if importer=="AUS" & year<=2006 & year>=2002
	replace nomen_old="H96" if importer=="AUS" & year<=2001 & year>=1996

	replace nomen_old="H17" if importer=="BDI" & year<=2020 & year>=2017
	replace nomen_old="H12" if importer=="BDI" & year<=2016 & year>=2012
	replace nomen_old="H07" if importer=="BDI" & year<=2011 & year>=2009
	replace nomen_old="H02" if importer=="BDI" & year<=2008 & year>=2005
	replace nomen_old="H96" if importer=="BDI" & year==2003
	replace nomen_old="H92" if importer=="BDI" & year<=2002           ///!!!

	replace nomen_old="H17" if importer=="BEN" & year<=2020 & year>=2019
	replace nomen_old="H12" if importer=="BEN" & year<=2018 & year>=2015
	replace nomen_old="H07" if importer=="BEN" & year<=2014 & year>=2008
	replace nomen_old="H02" if importer=="BEN" & year<=2007 & year>=2003
	replace nomen_old="H96" if importer=="BEN" & year<=2002 & year>=2001

	replace nomen_old="H17" if importer=="BFA" & year<=2020 & year>=2017
	replace nomen_old="H12" if importer=="BFA" & year<=2016 & year>=2015
	replace nomen_old="H07" if importer=="BFA" & year<=2014 & year>=2008
	replace nomen_old="H02" if importer=="BFA" & year<=2007 & year>=2003
	replace nomen_old="H96" if importer=="BFA" & year<=2002 & year>=2001

	replace nomen_old="H17" if importer=="BGD" & year==2018
	replace nomen_old="H12" if importer=="BGD" & year<=2016 & year>=2012
	replace nomen_old="H07" if importer=="BGD" & year<=2011 & year>=2007
	replace nomen_old="H02" if importer=="BGD" & year<=2006 & year>=2002
	replace nomen_old="H96" if importer=="BGD" & year<=2001 & year>=1998

	replace nomen_old="H02" if importer=="BGR" & year<=2006 & year>=2002
	replace nomen_old="H96" if importer=="BGR" & year<=2001 & year>=1997

	replace nomen_old="H17" if importer=="BHR" & year<=2021 & year>=2018
	replace nomen_old="H12" if importer=="BHR" & year<=2016 & year>=2012
	replace nomen_old="H07" if importer=="BHR" & year<=2011 & year>=2007
	replace nomen_old="H02" if importer=="BHR" & year<=2006 & year>=2002
	replace nomen_old="H96" if importer=="BHR" & year==2001
	replace nomen_old="H92" if importer=="BHR" & year<=2000

	replace nomen_old="H17" if importer=="BLZ" & year<=2019 & year>=2018
	replace nomen_old="H12" if importer=="BLZ" & year<=2017 & year>=2017
	replace nomen_old="H07" if importer=="BLZ" & year<=2016 & year>=2015
	replace nomen_old="H12" if importer=="BLZ" & year<=2014 & year>=2014
	replace nomen_old="H07" if importer=="BLZ" & year<=2013 & year>=2012
	replace nomen_old="H02" if importer=="BLZ" & year<=2011 & year>=2011
	replace nomen_old="H07" if importer=="BLZ" & year<=2010 & year>=2009
	replace nomen_old="H02" if importer=="BLZ" & year<=2008 & year>=2006
	replace nomen_old="H96" if importer=="BLZ" & year<=2005 & year>=1999
	replace nomen_old="H92" if importer=="BLZ" & year<=1996 & year>=1996 ///!!!

	replace nomen_old="H17" if importer=="BOL" & year<=2020 & year>=2017
	replace nomen_old="H12" if importer=="BOL" & year<=2016 & year>=2012
	replace nomen_old="H07" if importer=="BOL" & year<=2011 & year>=2007
	replace nomen_old="H02" if importer=="BOL" & year<=2006 & year>=2002
	replace nomen_old="H96" if importer=="BOL" & year<=2001 & year>=1996

	replace nomen_old="H17" if importer=="BRA" & year<=2021 & year>=2017
	replace nomen_old="H12" if importer=="BRA" & year<=2015 & year>=2012
	replace nomen_old="H07" if importer=="BRA" & year<=2011 & year>=2007
	replace nomen_old="H02" if importer=="BRA" & year<=2006 & year>=2002
	replace nomen_old="H96" if importer=="BRA" & year<=2001 & year>=1996

	replace nomen_old="H07" if importer=="BRB" & year<=2014 & year>=2012
	replace nomen_old="H02" if importer=="BRB" & year<=2011 & year>=2005
	replace nomen_old="H96" if importer=="BRB" & year<=2004 & year>=2000
	replace nomen_old="H92" if importer=="BRB" & year<=1999               ///!!!

	replace nomen_old="H17" if importer=="BRN" & year<=2019 & year>=2017
	replace nomen_old="H12" if importer=="BRN" & year<=2015 & year>=2012
	replace nomen_old="H07" if importer=="BRN" & year<=2011 & year>=2009
	replace nomen_old="H02" if importer=="BRN" & year<=2008 & year>=2004
	replace nomen_old="H96" if importer=="BRN" & year<=2003 & year>=1996

	replace nomen_old="H17" if importer=="BWA" & year<=2020 & year>=2017
	replace nomen_old="H12" if importer=="BWA" & year<=2016 & year>=2012
	replace nomen_old="H07" if importer=="BWA" & year<=2011 & year>=2007
	replace nomen_old="H02" if importer=="BWA" & year<=2006 & year>=2002
	replace nomen_old="H96" if importer=="BWA" & year<=2001 & year>=1997
	replace nomen_old="H92" if importer=="BWA" & year<=1996

	replace nomen_old="H12" if importer=="CAF" & year<=2016 & year>=2015
	replace nomen_old="H07" if importer=="CAF" & year<=2013 & year>=2007
	replace nomen_old="H02" if importer=="CAF" & year<=2006 & year>=2002
	replace nomen_old="H96" if importer=="CAF" & year==2001
	replace nomen_old="H92" if importer=="CAF" & year<=1997               ///!!!

	replace nomen_old="H17" if importer=="CAN" & year<=2021 & year>=2017
	replace nomen_old="H12" if importer=="CAN" & year<=2016 & year>=2012
	replace nomen_old="H07" if importer=="CAN" & year<=2011 & year>=2007
	replace nomen_old="H02" if importer=="CAN" & year<=2006 & year>=2002
	replace nomen_old="H96" if importer=="CAN" & year<=2001 & year>=1996

	replace nomen_old="H17" if importer=="CHE" & year<=2021 & year>=2017
	replace nomen_old="H12" if importer=="CHE" & year<=2016 & year>=2012
	replace nomen_old="H07" if importer=="CHE" & year<=2011 & year>=2007
	replace nomen_old="H02" if importer=="CHE" & year<=2006 & year>=2002
	replace nomen_old="H96" if importer=="CHE" & year<=2001 & year>=1996

	replace nomen_old="H17" if importer=="CHL" & year<=2021 & year>=2017
	replace nomen_old="H12" if importer=="CHL" & year<=2016 & year>=2012
	replace nomen_old="H07" if importer=="CHL" & year<=2011 & year>=2007
	replace nomen_old="H02" if importer=="CHL" & year<=2006 & year>=2002
	replace nomen_old="H96" if importer=="CHL" & year<=2001 & year>=1996

	replace nomen_old="H17" if importer=="CHN" & year<=2021 & year>=2017
	replace nomen_old="H12" if importer=="CHN" & year<=2016 & year>=2012
	replace nomen_old="H07" if importer=="CHN" & year<=2011 & year>=2007
	replace nomen_old="H02" if importer=="CHN" & year<=2006 & year>=2002
	replace nomen_old="H96" if importer=="CHN" & year<=2001 & year>=1996

	replace nomen_old="H17" if importer=="CIV" & year<=2020 & year>=2019
	replace nomen_old="H12" if importer=="CIV" & year<=2017 & year>=2015
	replace nomen_old="H07" if importer=="CIV" & year<=2014 & year>=2008
	replace nomen_old="H02" if importer=="CIV" & year<=2007 & year>=2003
	replace nomen_old="H96" if importer=="CIV" & year<=2002 & year>=2001

	replace nomen_old="H17" if importer=="CMR" & year<=2019 & year>=2019
	replace nomen_old="H12" if importer=="CMR" & year<=2014 & year>=2013
	replace nomen_old="H07" if importer=="CMR" & year<=2012 & year>=2010
	replace nomen_old="H02" if importer=="CMR" & year<=2009 & year>=2009
	replace nomen_old="H07" if importer=="CMR" & year<=2008 & year>=2007
	replace nomen_old="H02" if importer=="CMR" & year<=2006 & year>=2002
	replace nomen_old="H96" if importer=="CMR" & year<=2001 & year>=1996 ///!!!

	replace nomen_old="H12" if importer=="COG" & year<=2014 & year>=2012
	replace nomen_old="H07" if importer=="COG" & year<=2011 & year>=2007
	replace nomen_old="H02" if importer=="COG" & year<=2006 & year>=2002
	replace nomen_old="H96" if importer=="COG" & year<=2001 & year>=2007

	replace nomen_old="H17" if importer=="CRI" & year<=2020 & year>=2017
	replace nomen_old="H12" if importer=="CRI" & year<=2016 & year>=2012
	replace nomen_old="H07" if importer=="CRI" & year<=2011 & year>=2007
	replace nomen_old="H02" if importer=="CRI" & year<=2006 & year>=2003
	replace nomen_old="H96" if importer=="CRI" & year<=2002 & year>=1997
	replace nomen_old="H92" if importer=="CRI" & year<=1996 & year>=1996

	replace nomen_old="H07" if importer=="DJI" & year<=2014 & year>=2011
	replace nomen_old="H02" if importer=="DJI" & year==2009
	replace nomen_old="H92" if importer=="DJI" & year<=2006               ///!!!

	replace nomen_old="H07" if importer=="DMA" & year<=2016 & year>=2012
	replace nomen_old="H02" if importer=="DMA" & year<=2011 & year>=2005
	replace nomen_old="H96" if importer=="DMA" & year<=2004                   ///!!!

	replace nomen_old="H17" if importer=="DOM" & year<=2019 & year>=2017
	replace nomen_old="H12" if importer=="DOM" & year<=2016 & year>=2012
	replace nomen_old="H07" if importer=="DOM" & year<=2011 & year>=2007
	replace nomen_old="H02" if importer=="DOM" & year<=2006 & year>=2003
	replace nomen_old="H96" if importer=="DOM" & year<=2002 & year>=1996

	replace nomen_old="H17" if importer=="ECU" & year<=2018 & year>=2018
	replace nomen_old="H12" if importer=="ECU" & year<=2017 & year>=2013
	replace nomen_old="H07" if importer=="ECU" & year<=2012 & year>=2008
	replace nomen_old="H02" if importer=="ECU" & year<=2007 & year>=2002
	replace nomen_old="H96" if importer=="ECU" & year<=2001 & year>=1996

	replace nomen_old="H17" if importer=="EGY" & year<=2019 & year>=2019
	replace nomen_old="H12" if importer=="EGY" & year<=2018 & year>=2013
	replace nomen_old="H07" if importer=="EGY" & year<=2012 & year>=2007
	replace nomen_old="H02" if importer=="EGY" & year<=2006 & year>=2004
	replace nomen_old="H96" if importer=="EGY" & year<=2003 & year>=1999
	replace nomen_old="H92" if importer=="EGY" & year<=1998

	replace nomen_old="H02" if importer=="EST" & year<=2003 & year>=2002
	replace nomen_old="H96" if importer=="EST" & year<=2001 & year>=1996 ///!!!

	replace nomen_old="H07" if importer=="GAB" & year<=2019 & year>=2008
	replace nomen_old="H02" if importer=="GAB" & year<=2007 & year>=2002
	replace nomen_old="H96" if importer=="GAB" & year<=2001 & year>=2000
	replace nomen_old="H92" if importer=="GAB" & year<=1998               ///!!!

	replace nomen_old="H12" if importer=="GEO" & year<=2020 & year>=2012
	replace nomen_old="H02" if importer=="GEO" & year<=2011 & year>=2006
	replace nomen_old="H96" if importer=="GEO" & year<=2005 & year>=2001

	replace nomen_old="H17" if importer=="EEC" & year<=2021 & year>=2017
	replace nomen_old="H12" if importer=="EEC" & year<=2016 & year>=2012
	replace nomen_old="H07" if importer=="EEC" & year<=2011 & year>=2007
	replace nomen_old="H02" if importer=="EEC" & year<=2006 & year>=2002
	replace nomen_old="H96" if importer=="EEC" & year<=2001 & year>=1996

	replace nomen_old="H17" if importer=="GHA" & year<=2020 & year>=2018
	replace nomen_old="H12" if importer=="GHA" & year<=2017 & year>=2013
	replace nomen_old="H07" if importer=="GHA" & year<=2012 & year>=2008
	replace nomen_old="H02" if importer=="GHA" & year<=2007 & year>=2004
	replace nomen_old="H96" if importer=="GHA" & year<=2003 & year>=2001

	replace nomen_old="H17" if importer=="GIN" & year<=2020 & year>=2017
	replace nomen_old="H02" if importer=="GIN" & year<=2013 & year>=2005
	replace nomen_old="H92" if importer=="GIN" & year<=2004               ///!!!

	replace nomen_old="H17" if importer=="GMB" & year<=2020 & year>=2019
	replace nomen_old="H12" if importer=="GMB" & year<=2017 & year>=2017
	replace nomen_old="H07" if importer=="GMB" & year<=2013 & year>=2010
	replace nomen_old="H92" if importer=="GMB" & year<=2009               ///!!!

	replace nomen_old="H17" if importer=="GNB" & year<=2020 & year>=2019
	replace nomen_old="H12" if importer=="GNB" & year<=2017 & year>=2017
	replace nomen_old="H07" if importer=="GNB" & year<=2014 & year>=2008
	replace nomen_old="H02" if importer=="GNB" & year<=2007 & year>=2003
	replace nomen_old="H96" if importer=="GNB" & year<=2002               ///!!!

	replace nomen_old="H12" if importer=="GRD" & year<=2016 & year>=2015
	replace nomen_old="H07" if importer=="GRD" & year<=2014 & year>=2012
	replace nomen_old="H02" if importer=="GRD" & year<=2011 & year>=2010
	replace nomen_old="H96" if importer=="GRD" & year<=2009 & year>=2000
	replace nomen_old="H92" if importer=="GRD" & year<=1996

	replace nomen_old="H12" if importer=="GTM" & year<=2012 & year>=2012
	replace nomen_old="H07" if importer=="GTM" & year<=2011 & year>=2007
	replace nomen_old="H02" if importer=="GTM" & year<=2006 & year>=2003
	replace nomen_old="H96" if importer=="GTM" & year<=2002 & year>=1997

	replace nomen_old="H07" if importer=="GUY" & year<=2016 & year>=2012
	replace nomen_old="H02" if importer=="GUY" & year<=2011 & year>=2010
	replace nomen_old="H07" if importer=="GUY" & year<=2009 & year>=2007
	replace nomen_old="H96" if importer=="GUY" & year<=2003 & year>=1999
	replace nomen_old="H92" if importer=="GUY" & year<=1996

	replace nomen_old="H17" if importer=="HND" & year<=2020 & year>=2017
	replace nomen_old="H12" if importer=="HND" & year<=2015 & year>=2012
	replace nomen_old="H07" if importer=="HND" & year<=2011 & year>=2007
	replace nomen_old="H02" if importer=="HND" & year<=2006 & year>=2003
	replace nomen_old="H96" if importer=="HND" & year<=2002 & year>=1996

	replace nomen_old="H12" if importer=="HRV" & year<=2013 & year>=2012
	replace nomen_old="H07" if importer=="HRV" & year<=2011 & year>=2007
	replace nomen_old="H02" if importer=="HRV" & year<=2006 & year>=2002
	replace nomen_old="H96" if importer=="HRV" & year<=2001

	replace nomen_old="H02" if importer=="HUN" & year<=2002 & year>=2002
	replace nomen_old="H96" if importer=="HUN" & year<=2001 & year>=1996

	replace nomen_old="H17" if importer=="IDN" & year<=2018 & year>=2017
	replace nomen_old="H12" if importer=="IDN" & year<=2015 & year>=2013
	replace nomen_old="H07" if importer=="IDN" & year<=2012 & year>=2007
	replace nomen_old="H02" if importer=="IDN" & year<=2006 & year>=2002
	replace nomen_old="H96" if importer=="IDN" & year<=2001 & year>=1998
	replace nomen_old="H92" if importer=="IDN" & year<=1997 & year>=1996

	replace nomen_old="H17" if importer=="IND" & year<=2020 & year>=2017
	replace nomen_old="H12" if importer=="IND" & year<=2016 & year>=2011
	replace nomen_old="H07" if importer=="IND" & year<=2010 & year>=2007
	replace nomen_old="H02" if importer=="IND" & year<=2006 & year>=2002
	replace nomen_old="H96" if importer=="IND" & year<=2001 & year>=1996

	replace nomen_old="H17" if importer=="ISL" & year<=2018 & year>=2017
	replace nomen_old="H12" if importer=="ISL" & year<=2016 & year>=2012
	replace nomen_old="H07" if importer=="ISL" & year<=2011 & year>=2007
	replace nomen_old="H02" if importer=="ISL" & year<=2006 & year>=2002
	replace nomen_old="H96" if importer=="ISL" & year<=2001 & year>=1996

	replace nomen_old="H17" if importer=="ISR" & year<=2020 & year>=2017
	replace nomen_old="H12" if importer=="ISR" & year<=2016 & year>=2012
	replace nomen_old="H07" if importer=="ISR" & year<=2011 & year>=2007
	replace nomen_old="H02" if importer=="ISR" & year<=2006 & year>=2002
	replace nomen_old="H96" if importer=="ISR" & year<=2001 & year>=1999

	replace nomen_old="H12" if importer=="JAM" & year<=2016 & year>=2014
	replace nomen_old="H07" if importer=="JAM" & year<=2013 & year>=2007
	replace nomen_old="H02" if importer=="JAM" & year<=2006 & year>=2004
	replace nomen_old="H96" if importer=="JAM" & year<=2003 & year>=1996

	replace nomen_old="H17" if importer=="JOR" & year<=2020 & year>=2017
	replace nomen_old="H12" if importer=="JOR" & year<=2016 & year>=2012
	replace nomen_old="H07" if importer=="JOR" & year<=2011 & year>=2007
	replace nomen_old="H02" if importer=="JOR" & year<=2006 & year>=2002
	replace nomen_old="H96" if importer=="JOR" & year<=2001 & year>=2000

	replace nomen_old="H17" if importer=="JPN" & year<=2020 & year>=2017
	replace nomen_old="H12" if importer=="JPN" & year<=2016 & year>=2012
	replace nomen_old="H07" if importer=="JPN" & year<=2011 & year>=2007
	replace nomen_old="H02" if importer=="JPN" & year<=2006 & year>=2002
	replace nomen_old="H96" if importer=="JPN" & year<=2001 & year>=1996

	replace nomen_old="H17" if importer=="KAZ" & year<=2018 & year>=2017
	replace nomen_old="H12" if importer=="KAZ" & year<=2016 & year>=2015

	replace nomen_old="H17" if importer=="KEN" & year<=2020 & year>=2017
	replace nomen_old="H12" if importer=="KEN" & year<=2016 & year>=2012
	replace nomen_old="H07" if importer=="KEN" & year<=2011 & year>=2007
	replace nomen_old="H02" if importer=="KEN" & year<=2006 & year>=2003
	replace nomen_old="H96" if importer=="KEN" & year<=2002 & year>=1998

	replace nomen_old="H17" if importer=="KGZ" & year<=2020 & year>=2017
	replace nomen_old="H12" if importer=="KGZ" & year<=2016 & year>=2015
	replace nomen_old="H07" if importer=="KGZ" & year<=2014 & year>=2008
	replace nomen_old="H02" if importer=="KGZ" & year<=2007 & year>=2003
	replace nomen_old="H96" if importer=="KGZ" & year<=2002 & year>=1999

	replace nomen_old="H17" if importer=="KHM" & year<=2020 & year>=2017
	replace nomen_old="H12" if importer=="KHM" & year<=2016 & year>=2014
	replace nomen_old="H07" if importer=="KHM" & year<=2012 & year>=2009
	replace nomen_old="H02" if importer=="KHM" & year<=2008 & year>=2005
	replace nomen_old="H96" if importer=="KHM" & year<=2003 & year>=2002

	replace nomen_old="H07" if importer=="KNA" & year<=2016 & year>=2012
	replace nomen_old="H02" if importer=="KNA" & year<=2011 & year>=2010
	replace nomen_old="H96" if importer=="KNA" & year<=2009 & year>=1999
	replace nomen_old="H92" if importer=="KNA" & year<=1996

	replace nomen_old="H17" if importer=="KOR" & year<=2021 & year>=2017
	replace nomen_old="H12" if importer=="KOR" & year<=2016 & year>=2012
	replace nomen_old="H07" if importer=="KOR" & year<=2011 & year>=2007
	replace nomen_old="H02" if importer=="KOR" & year<=2006 & year>=2002
	replace nomen_old="H96" if importer=="KOR" & year<=2001 & year>=1996

	replace nomen_old="H12" if importer=="KWT" & year<=2016 & year>=2012
	replace nomen_old="H07" if importer=="KWT" & year<=2011 & year>=2007
	replace nomen_old="H02" if importer=="KWT" & year<=2006 & year>=2003
	replace nomen_old="H92" if importer=="KWT" & year<=2002

	replace nomen_old="H12" if importer=="LAO" & year<=2018 & year>=2014
	replace nomen_old="H02" if importer=="LAO" & year<=2008 & year>=2008

	replace nomen_old="H17" if importer=="LBR" & year<=2020 & year>=2018
	replace nomen_old="H12" if importer=="LBR" & year<=2017 & year>=2012
	replace nomen_old="H96" if importer=="LBR" & year<=2011

	replace nomen_old="H12" if importer=="LCA" & year<=2021 & year>=2015
	replace nomen_old="H07" if importer=="LCA" & year<=2014 & year>=2012
	replace nomen_old="H02" if importer=="LCA" & year<=2011 & year>=2010
	replace nomen_old="H96" if importer=="LCA" & year<=2007 & year>=2000
	replace nomen_old="H92" if importer=="LCA" & year<=1996

	replace nomen_old="H12" if importer=="LKA" & year<=2017 & year>=2013
	replace nomen_old="H07" if importer=="LKA" & year<=2012 & year>=2007
	replace nomen_old="H02" if importer=="LKA" & year<=2006 & year>=2003
	replace nomen_old="H96" if importer=="LKA" & year<=2001 & year>=1998
	replace nomen_old="H92" if importer=="LKA" & year<=1997

	replace nomen_old="H17" if importer=="LSO" & year<=2020 & year>=2017
	replace nomen_old="H12" if importer=="LSO" & year<=2016 & year>=2012
	replace nomen_old="H07" if importer=="LSO" & year<=2011 & year>=2007
	replace nomen_old="H02" if importer=="LSO" & year<=2006 & year>=2002
	replace nomen_old="H96" if importer=="LSO" & year<=2001 & year>=1997
	replace nomen_old="H92" if importer=="LSO" & year<=1996

	replace nomen_old="H02" if importer=="LVA" & year<=2002 & year>=2002
	replace nomen_old="H96" if importer=="LVA" & year<=2001 & year>=1998

	replace nomen_old="H17" if importer=="MAR" & year<=2020 & year>=2017
	replace nomen_old="H12" if importer=="MAR" & year<=2016 & year>=2015
	replace nomen_old="H02" if importer=="MAR" & year<=2014 & year>=2003
	replace nomen_old="H96" if importer=="MAR" & year<=2002 & year>=1996

	replace nomen_old="H17" if importer=="MDG" & year<=2021 & year>=2017
	replace nomen_old="H12" if importer=="MDG" & year<=2016 & year>=2012
	replace nomen_old="H07" if importer=="MDG" & year<=2011 & year>=2007
	replace nomen_old="H02" if importer=="MDG" & year<=2006 & year>=2002
	replace nomen_old="H96" if importer=="MDG" & year<=2001 & year>=1996

	replace nomen_old="H17" if importer=="MDV" & year<=2019 & year>=2017
	replace nomen_old="H12" if importer=="MDV" & year<=2016 & year>=2012
	replace nomen_old="H07" if importer=="MDV" & year<=2011 & year>=2008
	replace nomen_old="H02" if importer=="MDV" & year<=2007 & year>=2003
	replace nomen_old="H96" if importer=="MDV" & year<=2002 & year>=2000

	replace nomen_old="H12" if importer=="MEX" & year<=2020 & year>=2013
	replace nomen_old="H07" if importer=="MEX" & year<=2012 & year>=2008
	replace nomen_old="H02" if importer=="MEX" & year<=2007 & year>=2003
	replace nomen_old="H96" if importer=="MEX" & year<=2002 & year>=1996

	replace nomen_old="H17" if importer=="MLI" & year<=2020 & year>=2018
	replace nomen_old="H12" if importer=="MLI" & year<=2017 & year>=2015
	replace nomen_old="H07" if importer=="MLI" & year<=2014 & year>=2008
	replace nomen_old="H02" if importer=="MLI" & year<=2007 & year>=2003
	replace nomen_old="H96" if importer=="MLI" & year<=2002 & year>=1996

	replace nomen_old="H17" if importer=="MMR" & year<=2021 & year>=2017
	replace nomen_old="H12" if importer=="MMR" & year<=2016 & year>=2012
	replace nomen_old="H07" if importer=="MMR" & year<=2011 & year>=2009
	replace nomen_old="H02" if importer=="MMR" & year<=2008 & year>=2005
	replace nomen_old="H96" if importer=="MMR" & year<=2004 & year>=2004
	replace nomen_old="H02" if importer=="MMR" & year<=2003 & year>=2003
	replace nomen_old="H96" if importer=="MMR" & year<=2002 & year>=1996

	replace nomen_old="H17" if importer=="MNE" & year<=2020 & year>=2017
	replace nomen_old="H12" if importer=="MNE" & year<=2016 & year>=2011

	replace nomen_old="H17" if importer=="MNG" & year<=2020 & year>=2017
	replace nomen_old="H12" if importer=="MNG" & year<=2016 & year>=2012
	replace nomen_old="H07" if importer=="MNG" & year<=2011 & year>=2008
	replace nomen_old="H02" if importer=="MNG" & year<=2007 & year>=2004
	replace nomen_old="H96" if importer=="MNG" & year<=2003 & year>=1997
	replace nomen_old="H92" if importer=="MNG" & year<=1996

	replace nomen_old="H17" if importer=="MOZ" & year<=2019 & year>=2018
	replace nomen_old="H07" if importer=="MOZ" & year<=2016 & year>=2010
	replace nomen_old="H02" if importer=="MOZ" & year<=2009 & year>=2009
	replace nomen_old="H07" if importer=="MOZ" & year<=2008 & year>=2008
	replace nomen_old="H02" if importer=="MOZ" & year<=2007 & year>=2002
	replace nomen_old="H96" if importer=="MOZ" & year<=2001 & year>=2000
	replace nomen_old="H92" if importer=="MOZ" & year<=1997

	replace nomen_old="H17" if importer=="MUS" & year<=2020 & year>=2017
	replace nomen_old="H12" if importer=="MUS" & year<=2016 & year>=2012
	replace nomen_old="H07" if importer=="MUS" & year<=2011 & year>=2007
	replace nomen_old="H02" if importer=="MUS" & year<=2006 & year>=2002
	replace nomen_old="H96" if importer=="MUS" & year<=2001 & year>=1996

	replace nomen_old="H12" if importer=="MWI" & year<=2017 & year>=2014
	replace nomen_old="H07" if importer=="MWI" & year<=2013 & year>=2008
	replace nomen_old="H02" if importer=="MWI" & year<=2007 & year>=2003
	replace nomen_old="H96" if importer=="MWI" & year<=2002 & year>=2000
	replace nomen_old="H92" if importer=="MWI" & year<=1998

	replace nomen_old="H17" if importer=="MYS" & year<=2020 & year>=2017
	replace nomen_old="H12" if importer=="MYS" & year<=2016 & year>=2013
	replace nomen_old="H07" if importer=="MYS" & year<=2012 & year>=2008
	replace nomen_old="H02" if importer=="MYS" & year<=2007 & year>=2002
	replace nomen_old="H96" if importer=="MYS" & year<=2001 & year>=1996

	replace nomen_old="H17" if importer=="NAM" & year<=2020 & year>=2017
	replace nomen_old="H12" if importer=="NAM" & year<=2016 & year>=2012
	replace nomen_old="H07" if importer=="NAM" & year<=2011 & year>=2007
	replace nomen_old="H02" if importer=="NAM" & year<=2006 & year>=2002
	replace nomen_old="H96" if importer=="NAM" & year<=2001 & year>=1997
	replace nomen_old="H96" if importer=="NAM" & year<=1996

	replace nomen_old="H17" if importer=="NER" & year<=2020 & year>=2019
	replace nomen_old="H12" if importer=="NER" & year<=2018 & year>=2015
	replace nomen_old="H07" if importer=="NER" & year<=2014 & year>=2008
	replace nomen_old="H02" if importer=="NER" & year<=2007 & year>=2003
	replace nomen_old="H96" if importer=="NER" & year<=2002 & year>=2001

	replace nomen_old="H17" if importer=="NGA" & year<=2020 & year>=2020
	replace nomen_old="H12" if importer=="NGA" & year<=2019 & year>=2015
	replace nomen_old="H07" if importer=="NGA" & year<=2014 & year>=2009
	replace nomen_old="H02" if importer=="NGA" & year<=2008 & year>=2005
	replace nomen_old="H96" if importer=="NGA" & year<=2003 & year>=1996

	replace nomen_old="H17" if importer=="NIC" & year<=2020 & year>=2017
	replace nomen_old="H12" if importer=="NIC" & year<=2016 & year>=2012
	replace nomen_old="H07" if importer=="NIC" & year<=2011 & year>=2007
	replace nomen_old="H02" if importer=="NIC" & year<=2006 & year>=2003
	replace nomen_old="H96" if importer=="NIC" & year<=2002 & year>=1997
	replace nomen_old="H92" if importer=="NIC" & year<=1996

	replace nomen_old="H17" if importer=="NOR" & year<=2020 & year>=2017
	replace nomen_old="H12" if importer=="NOR" & year<=2016 & year>=2012
	replace nomen_old="H07" if importer=="NOR" & year<=2011 & year>=2007
	replace nomen_old="H02" if importer=="NOR" & year<=2006 & year>=2002
	replace nomen_old="H96" if importer=="NOR" & year<=2001 & year>=1996

	replace nomen_old="H17" if importer=="NPL" & year<=2018 & year>=2017
	replace nomen_old="H12" if importer=="NPL" & year<=2016 & year>=2013
	replace nomen_old="H07" if importer=="NPL" & year<=2012 & year>=2007
	replace nomen_old="H02" if importer=="NPL" & year<=2006 & year>=2002

	replace nomen_old="H17" if importer=="NZL" & year<=2020 & year>=2017
	replace nomen_old="H12" if importer=="NZL" & year<=2016 & year>=2012
	replace nomen_old="H07" if importer=="NZL" & year<=2011 & year>=2007
	replace nomen_old="H02" if importer=="NZL" & year<=2006 & year>=2002
	replace nomen_old="H96" if importer=="NZL" & year<=2001 & year>=1996

	replace nomen_old="H17" if importer=="OMN" & year<=2017 & year>=2017
	replace nomen_old="H12" if importer=="OMN" & year<=2016 & year>=2012
	replace nomen_old="H07" if importer=="OMN" & year<=2009 & year>=2007
	replace nomen_old="H02" if importer=="OMN" & year<=2006 & year>=2002
	replace nomen_old="H96" if importer=="OMN" & year<=2001

	replace nomen_old="H17" if importer=="PAK" & year<=2018 & year>=2017
	replace nomen_old="H12" if importer=="PAK" & year<=2016 & year>=2012
	replace nomen_old="H07" if importer=="PAK" & year<=2011 & year>=2007
	replace nomen_old="H02" if importer=="PAK" & year<=2006 & year>=2002
	replace nomen_old="H96" if importer=="PAK" & year<=2001 & year>=1996

	replace nomen_old="H17" if importer=="PER" & year<=2018 & year>=2017
	replace nomen_old="H12" if importer=="PER" & year<=2016 & year>=2012
	replace nomen_old="H07" if importer=="PER" & year<=2011 & year>=2007
	replace nomen_old="H02" if importer=="PER" & year<=2006 & year>=2002
	replace nomen_old="H96" if importer=="PER" & year<=2001 & year>=1998
	replace nomen_old="H92" if importer=="PER" & year<=1997

	replace nomen_old="H17" if importer=="PHL" & year<=2020 & year>=2017
	replace nomen_old="H12" if importer=="PHL" & year<=2016 & year>=2013
	replace nomen_old="H07" if importer=="PHL" & year<=2012 & year>=2008
	replace nomen_old="H02" if importer=="PHL" & year<=2007 & year>=2004
	replace nomen_old="H96" if importer=="PHL" & year<=2003 & year>=1996

	replace nomen_old="H17" if importer=="QAT" & year<=2021 & year>=2017
	replace nomen_old="H12" if importer=="QAT" & year<=2016 & year>=2012
	replace nomen_old="H07" if importer=="QAT" & year<=2011 & year>=2005
	replace nomen_old="H02" if importer=="QAT" & year<=2004 & year>=2002

	replace nomen_old="H17" if importer=="RUS" & year<=2020 & year>=2019
	replace nomen_old="H12" if importer=="RUS" & year<=2016 & year>=2012
	replace nomen_old="H07" if importer=="RUS" & year<=2011 & year>=2010
	replace nomen_old="H96" if importer=="RUS" & year<=2001

	replace nomen_old="H17" if importer=="RWA" & year<=2020 & year>=2017
	replace nomen_old="H12" if importer=="RWA" & year<=2016 & year>=2012
	replace nomen_old="H07" if importer=="RWA" & year<=2011 & year>=2008
	replace nomen_old="H02" if importer=="RWA" & year<=2007 & year>=2005
	replace nomen_old="H96" if importer=="RWA" & year<=2004 & year>=2000

	replace nomen_old="H17" if importer=="SAU" & year<=2020 & year>=2020
	replace nomen_old="H07" if importer=="SAU" & year<=2018 & year>=2018
	replace nomen_old="H17" if importer=="SAU" & year<=2017 & year>=2017
	replace nomen_old="H07" if importer=="SAU" & year<=2016 & year>=2016
	replace nomen_old="H12" if importer=="SAU" & year<=2015 & year>=2012
	replace nomen_old="H07" if importer=="SAU" & year<=2011 & year>=2007
	replace nomen_old="H02" if importer=="SAU" & year<=2006 & year>=2002
	replace nomen_old="H96" if importer=="SAU" & year<=2001

	replace nomen_old="H17" if importer=="SEN" & year<=2020 & year>=2019
	replace nomen_old="H12" if importer=="SEN" & year<=2018 & year>=2015
	replace nomen_old="H07" if importer=="SEN" & year<=2014 & year>=2008
	replace nomen_old="H02" if importer=="SEN" & year<=2007 & year>=2003
	replace nomen_old="H96" if importer=="SEN" & year<=2002 & year>=2001

	replace nomen_old="H17" if importer=="SGP" & year<=2021 & year>=2019
	replace nomen_old="H12" if importer=="SGP" & year<=2018 & year>=2012
	replace nomen_old="H07" if importer=="SGP" & year<=2011 & year>=2008
	replace nomen_old="H02" if importer=="SGP" & year<=2007 & year>=2005
	replace nomen_old="H96" if importer=="SGP" & year<=2004 & year>=1996

	replace nomen_old="H12" if importer=="SLB" & year<=2016 & year>=2015
	replace nomen_old="H02" if importer=="SLB" & year<=2013 & year>=2007
	replace nomen_old="H92" if importer=="SLB" & year<=2006

	replace nomen_old="H12" if importer=="SLB" & year<=2016 & year>=2015
	replace nomen_old="H02" if importer=="SLB" & year<=2013 & year>=2007
	replace nomen_old="H92" if importer=="SLB" & year<=2006

	replace nomen_old="H17" if importer=="SLE" & year<=2020 & year>=2018
	replace nomen_old="H07" if importer=="SLE" & year<=2016 & year>=2010
	replace nomen_old="H02" if importer=="SLE" & year<=2006 & year>=2004

	replace nomen_old="H17" if importer=="SLV" & year<=2020 & year>=2017
	replace nomen_old="H12" if importer=="SLV" & year<=2016 & year>=2012
	replace nomen_old="H07" if importer=="SLV" & year<=2011 & year>=2007
	replace nomen_old="H02" if importer=="SLV" & year<=2006 & year>=2002
	replace nomen_old="H96" if importer=="SLV" & year<=2001 & year>=1996

	replace nomen_old="H07" if importer=="SRB" & year<=2010 & year>=2009
	replace nomen_old="H02" if importer=="SRB" & year<=2005 & year>=2005

	replace nomen_old="H02" if importer=="SVK" & year<=2003 & year>=2002
	replace nomen_old="H96" if importer=="SVK" & year<=2001 & year>=1998

	replace nomen_old="H17" if importer=="SWZ" & year<=2021 & year>=2017
	replace nomen_old="H12" if importer=="SWZ" & year<=2016 & year>=2012
	replace nomen_old="H07" if importer=="SWZ" & year<=2011 & year>=2007
	replace nomen_old="H02" if importer=="SWZ" & year<=2006 & year>=2002
	replace nomen_old="H96" if importer=="SWZ" & year<=2001 & year>=1996

	replace nomen_old="H17" if importer=="SYC" & year<=2020 & year>=2018
	replace nomen_old="H07" if importer=="SYC" & year<=2017 & year>=2015

	replace nomen_old="H07" if importer=="TCD" & year<=2016 & year>=2014
	replace nomen_old="H12" if importer=="TCD" & year<=2013 & year>=2013
	replace nomen_old="H07" if importer=="TCD" & year<=2012 & year>=2007
	replace nomen_old="H02" if importer=="TCD" & year<=2006 & year>=2002
	replace nomen_old="H96" if importer=="TCD" & year<=2001 & year>=2001
	replace nomen_old="H92" if importer=="TCD" & year<=1997

	replace nomen_old="H17" if importer=="TGO" & year<=2020 & year>=2018
	replace nomen_old="H12" if importer=="TGO" & year<=2017 & year>=2015
	replace nomen_old="H07" if importer=="TGO" & year<=2014 & year>=2008
	replace nomen_old="H02" if importer=="TGO" & year<=2007 & year>=2003
	replace nomen_old="H96" if importer=="TGO" & year<=2002 & year>=1998
	replace nomen_old="H92" if importer=="TGO" & year<=1997

	replace nomen_old="H17" if importer=="THA" & year<=2021 & year>=2017
	replace nomen_old="H12" if importer=="THA" & year<=2016 & year>=2012
	replace nomen_old="H07" if importer=="THA" & year<=2011 & year>=2007
	replace nomen_old="H02" if importer=="THA" & year<=2006 & year>=2002
	replace nomen_old="H96" if importer=="THA" & year<=2001 & year>=1999

	replace nomen_old="H07" if importer=="TJK" & year<=2017 & year>=2011

	replace nomen_old="H12" if importer=="TTO" & year<=2018 & year>=2018
	replace nomen_old="H07" if importer=="TTO" & year<=2013 & year>=2007
	replace nomen_old="H02" if importer=="TTO" & year<=2006 & year>=2004
	replace nomen_old="H96" if importer=="TTO" & year<=2003 & year>=1999
	replace nomen_old="H92" if importer=="TTO" & year<=1996

	replace nomen_old="H12" if importer=="TUN" & year<=2016 & year>=2012
	replace nomen_old="H07" if importer=="TUN" & year<=2011 & year>=2008
	replace nomen_old="H02" if importer=="TUN" & year<=2007 & year>=2002
	replace nomen_old="H96" if importer=="TUN" & year<=2001 & year>=1996

	replace nomen_old="H17" if importer=="TUR" & year<=2019 & year>=2019
	replace nomen_old="H12" if importer=="TUR" & year<=2016 & year>=2013
	replace nomen_old="H07" if importer=="TUR" & year<=2011 & year>=2007
	replace nomen_old="H02" if importer=="TUR" & year<=2006 & year>=2002
	replace nomen_old="H96" if importer=="TUR" & year<=2001 & year>=1996

	replace nomen_old="H17" if importer=="TWN" & year<=2020 & year>=2017
	replace nomen_old="H12" if importer=="TWN" & year<=2016 & year>=2014
	replace nomen_old="H07" if importer=="TWN" & year<=2013 & year>=2009
	replace nomen_old="H02" if importer=="TWN" & year<=2008 & year>=2004
	replace nomen_old="H96" if importer=="TWN" & year<=2003 & year>=1996

	replace nomen_old="H17" if importer=="TZA" & year<=2020 & year>=2017
	replace nomen_old="H12" if importer=="TZA" & year<=2016 & year>=2012
	replace nomen_old="H07" if importer=="TZA" & year<=2011 & year>=2008
	replace nomen_old="H02" if importer=="TZA" & year<=2007 & year>=2005
	replace nomen_old="H96" if importer=="TZA" & year<=2004 & year>=1998

	replace nomen_old="H17" if importer=="UGA" & year<=2020 & year>=2017
	replace nomen_old="H12" if importer=="UGA" & year<=2016 & year>=2012
	replace nomen_old="H07" if importer=="UGA" & year<=2011 & year>=2008
	replace nomen_old="H02" if importer=="UGA" & year<=2007 & year>=2002
	replace nomen_old="H96" if importer=="UGA" & year<=2001 & year>=2000

	replace nomen_old="H17" if importer=="URY" & year<=2020 & year>=2017
	replace nomen_old="H12" if importer=="URY" & year<=2016 & year>=2012
	replace nomen_old="H07" if importer=="URY" & year<=2011 & year>=2007
	replace nomen_old="H02" if importer=="URY" & year<=2006 & year>=2002
	replace nomen_old="H96" if importer=="URY" & year<=2001 & year>=1996

	replace nomen_old="H17" if importer=="USA" & year<=2020 & year>=2017
	replace nomen_old="H12" if importer=="USA" & year<=2016 & year>=2012
	replace nomen_old="H07" if importer=="USA" & year<=2011 & year>=2007
	replace nomen_old="H02" if importer=="USA" & year<=2006 & year>=2002
	replace nomen_old="H96" if importer=="USA" & year<=2001 & year>=1996

	replace nomen_old="H07" if importer=="VCT" & year<=2020 & year>=2012
	replace nomen_old="H02" if importer=="VCT" & year<=2011 & year>=2010
	replace nomen_old="H96" if importer=="VCT" & year<=2007 & year>=1999
	replace nomen_old="H92" if importer=="VCT" & year<=1996

	replace nomen_old="H12" if importer=="VEN" & year<=2016 & year>=2013
	replace nomen_old="H02" if importer=="VEN" & year<=2012 & year>=2005
	replace nomen_old="H96" if importer=="VEN" & year<=2004 & year>=1996

	replace nomen_old="H17" if importer=="VNM" & year<=2020 & year>=2018
	replace nomen_old="H12" if importer=="VNM" & year<=2017 & year>=2012
	replace nomen_old="H07" if importer=="VNM" & year<=2010 & year>=2008
	replace nomen_old="H02" if importer=="VNM" & year<=2007 & year>=2003
	replace nomen_old="H96" if importer=="VNM" & year<=2002 & year>=2002

	replace nomen_old="H17" if importer=="VUT" & year<=2020 & year>=2017
	replace nomen_old="H12" if importer=="VUT" & year<=2016 & year>=2015
	replace nomen_old="H07" if importer=="VUT" & year<=2012 & year>=2012
	replace nomen_old="H02" if importer=="VUT" & year<=2007 & year>=2002

	replace nomen_old="H12" if importer=="YEM" & year<=2016 & year>=2015
	replace nomen_old="H02" if importer=="YEM" & year<=2009 & year>=2009

	replace nomen_old="H17" if importer=="ZAF" & year<=2020 & year>=2017
	replace nomen_old="H12" if importer=="ZAF" & year<=2016 & year>=2012
	replace nomen_old="H07" if importer=="ZAF" & year<=2011 & year>=2007
	replace nomen_old="H02" if importer=="ZAF" & year<=2006 & year>=2002
	replace nomen_old="H96" if importer=="ZAF" & year<=2001 & year>=1997
	replace nomen_old="H92" if importer=="ZAF" & year<=1996 & year>=1996

	replace nomen_old="H12" if importer=="ZMB" & year<=2016 & year>=2012
	replace nomen_old="H07" if importer=="ZMB" & year<=2011 & year>=2007
	replace nomen_old="H02" if importer=="ZMB" & year<=2006 & year>=2002
	replace nomen_old="H96" if importer=="ZMB" & year<=2001 & year>=2001

	replace nomen_old="H17" if importer=="ZWE" & year<=2020 & year>=2017
	replace nomen_old="H12" if importer=="ZWE" & year<=2016 & year>=2013
	replace nomen_old="H07" if importer=="ZWE" & year<=2012 & year>=2007
	replace nomen_old="H02" if importer=="ZWE" & year<=2003 & year>=2002
	replace nomen_old="H96" if importer=="ZWE" & year<=2001 & year>=1997
	replace nomen_old="H92" if importer=="ZWE" & year<=1996

	compress
	
	*Change nomenclatures (for consistency).
	gen hs6_old=hs6
	gen nomen=nomen_old
	gen byte hs_change=0
		
	foreach i in "92" "96" "02" "07" "12" { 
		
		foreach j in "96" "02" "07" "12" "17"{ 
			
			capture confirm file "./temp_files/HS`j'toHS`i'_1to1.dta" 
			if _rc==0 {
			dis("HS`j' to HS`i'")
			merge m:1 hs6 nomen using "./temp_files/HS`j'toHS`i'_1to1.dta", keep(master matched) 
			replace hs6=hs6_hs`i' if _m==3
			replace nomen="H`i'" if _m==3
			replace hs_change=1 if _m==3
			drop _m hs6_hs`i'
			}
			else {
			display "The file HS`j'toHS`i'_1to1.dta does not exist"
			}
			
		}
		
	}

	*Drop variables.
	keep importer exporter year hs6* TTB nomen*
	
	*Drop duplicates.
	duplicates drop
	
	*Save database.
	save "./temp_files/main_`data'.dta", replace

}


* For broad safeguard duties, there is no exporter. So we have to assume that the exporter is reporting the SGD using the same codes as the exporter 
** reports if it imports something

*Open database.
use "./temp_files/main_SGD.dta",clear

*Generate vintage guess.
gen hs_vintage_guess="H96" if year<=2001
replace hs_vintage_guess="H02" if year<=2007 & year>=2002
replace hs_vintage_guess="H07" if year<=2011 & year>=2007
replace hs_vintage_guess="H12" if year<=2016 & year>=2012
replace hs_vintage_guess="H17" if year>=2016

*Generate old nomenclature variable. 
gen nomen_old=hs_vintage_guess

replace nomen_old="H17" if importer=="ALB" & year>=2017
replace nomen_old="H12" if importer=="ALB" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="ALB" & year<=2011 & year>=2009
replace nomen_old="H02" if importer=="ALB" & year<=2008 & year>=2003
replace nomen_old="H96" if importer=="ALB" & year<=2002 & year>=2000

replace nomen_old="H17" if importer=="ARE" & year>=2019
replace nomen_old="H12" if importer=="ARE" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="ARE" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="ARE" & year<=2006 & year>=2002

replace nomen_old="H17" if importer=="ALB" & year>=2017
replace nomen_old="H12" if importer=="ALB" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="ALB" & year<=2011 & year>=2009
replace nomen_old="H02" if importer=="ALB" & year<=2008 & year>=2003
replace nomen_old="H96" if importer=="ALB" & year<=2002 & year>=2000

replace nomen_old="H17" if importer=="ARG" & year<=2021 & year>=2019
replace nomen_old="H12" if importer=="ARG" & year<=2017 & year>=2013
replace nomen_old="H07" if importer=="ARG" & year<=2012 & year>=2007
replace nomen_old="H02" if importer=="ARG" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="ARG" & year<=2001 & year>=1996

replace nomen_old="H17" if importer=="ARM" & year==2018
replace nomen_old="H12" if importer=="ARM" & year<=2016 & year>=2013
replace nomen_old="H07" if importer=="ARM" & year<=2012 & year>=2009
replace nomen_old="H02" if importer=="ARM" & year<=2008 & year>=2006
replace nomen_old="H96" if importer=="ARM" & year<=2005 & year>=2003

replace nomen_old="H07" if importer=="ATG" & year<=2016 & year>=2012
replace nomen_old="H02" if importer=="ATG" & year<=2011 & year>=2010
replace nomen_old="H96" if importer=="ATG" & year<=2009 & year>=1996

replace nomen_old="H17" if importer=="AUS" & year<=2021 & year>=2017
replace nomen_old="H12" if importer=="AUS" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="AUS" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="AUS" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="AUS" & year<=2001 & year>=1996

replace nomen_old="H17" if importer=="BDI" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="BDI" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="BDI" & year<=2011 & year>=2009
replace nomen_old="H02" if importer=="BDI" & year<=2008 & year>=2005
replace nomen_old="H96" if importer=="BDI" & year==2003
replace nomen_old="H92" if importer=="BDI" & year<=2002           ///!!!

replace nomen_old="H17" if importer=="BEN" & year<=2020 & year>=2019
replace nomen_old="H12" if importer=="BEN" & year<=2018 & year>=2015
replace nomen_old="H07" if importer=="BEN" & year<=2014 & year>=2008
replace nomen_old="H02" if importer=="BEN" & year<=2007 & year>=2003
replace nomen_old="H96" if importer=="BEN" & year<=2002 & year>=2001

replace nomen_old="H17" if importer=="BFA" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="BFA" & year<=2016 & year>=2015
replace nomen_old="H07" if importer=="BFA" & year<=2014 & year>=2008
replace nomen_old="H02" if importer=="BFA" & year<=2007 & year>=2003
replace nomen_old="H96" if importer=="BFA" & year<=2002 & year>=2001

replace nomen_old="H17" if importer=="BGD" & year==2018
replace nomen_old="H12" if importer=="BGD" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="BGD" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="BGD" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="BGD" & year<=2001 & year>=1998

replace nomen_old="H02" if importer=="BGR" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="BGR" & year<=2001 & year>=1997

replace nomen_old="H17" if importer=="BHR" & year<=2021 & year>=2018
replace nomen_old="H12" if importer=="BHR" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="BHR" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="BHR" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="BHR" & year==2001
replace nomen_old="H92" if importer=="BHR" & year<=2000

replace nomen_old="H17" if importer=="BLZ" & year<=2019 & year>=2018
replace nomen_old="H12" if importer=="BLZ" & year<=2017 & year>=2017
replace nomen_old="H07" if importer=="BLZ" & year<=2016 & year>=2015
replace nomen_old="H12" if importer=="BLZ" & year<=2014 & year>=2014
replace nomen_old="H07" if importer=="BLZ" & year<=2013 & year>=2012
replace nomen_old="H02" if importer=="BLZ" & year<=2011 & year>=2011
replace nomen_old="H07" if importer=="BLZ" & year<=2010 & year>=2009
replace nomen_old="H02" if importer=="BLZ" & year<=2008 & year>=2006
replace nomen_old="H96" if importer=="BLZ" & year<=2005 & year>=1999
replace nomen_old="H92" if importer=="BLZ" & year<=1996 & year>=1996 ///!!!

replace nomen_old="H17" if importer=="BOL" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="BOL" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="BOL" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="BOL" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="BOL" & year<=2001 & year>=1996

replace nomen_old="H17" if importer=="BRA" & year<=2021 & year>=2017
replace nomen_old="H12" if importer=="BRA" & year<=2015 & year>=2012
replace nomen_old="H07" if importer=="BRA" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="BRA" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="BRA" & year<=2001 & year>=1996

replace nomen_old="H07" if importer=="BRB" & year<=2014 & year>=2012
replace nomen_old="H02" if importer=="BRB" & year<=2011 & year>=2005
replace nomen_old="H96" if importer=="BRB" & year<=2004 & year>=2000
replace nomen_old="H92" if importer=="BRB" & year<=1999               ///!!!

replace nomen_old="H17" if importer=="BRN" & year<=2019 & year>=2017
replace nomen_old="H12" if importer=="BRN" & year<=2015 & year>=2012
replace nomen_old="H07" if importer=="BRN" & year<=2011 & year>=2009
replace nomen_old="H02" if importer=="BRN" & year<=2008 & year>=2004
replace nomen_old="H96" if importer=="BRN" & year<=2003 & year>=1996

replace nomen_old="H17" if importer=="BWA" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="BWA" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="BWA" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="BWA" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="BWA" & year<=2001 & year>=1997
replace nomen_old="H92" if importer=="BWA" & year<=1996

replace nomen_old="H12" if importer=="CAF" & year<=2016 & year>=2015
replace nomen_old="H07" if importer=="CAF" & year<=2013 & year>=2007
replace nomen_old="H02" if importer=="CAF" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="CAF" & year==2001
replace nomen_old="H92" if importer=="CAF" & year<=1997               ///!!!

replace nomen_old="H17" if importer=="CAN" & year<=2021 & year>=2017
replace nomen_old="H12" if importer=="CAN" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="CAN" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="CAN" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="CAN" & year<=2001 & year>=1996

replace nomen_old="H17" if importer=="CHE" & year<=2021 & year>=2017
replace nomen_old="H12" if importer=="CHE" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="CHE" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="CHE" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="CHE" & year<=2001 & year>=1996

replace nomen_old="H17" if importer=="CHL" & year<=2021 & year>=2017
replace nomen_old="H12" if importer=="CHL" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="CHL" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="CHL" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="CHL" & year<=2001 & year>=1996

replace nomen_old="H17" if importer=="CHN" & year<=2021 & year>=2017
replace nomen_old="H12" if importer=="CHN" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="CHN" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="CHN" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="CHN" & year<=2001 & year>=1996

replace nomen_old="H17" if importer=="CIV" & year<=2020 & year>=2019
replace nomen_old="H12" if importer=="CIV" & year<=2017 & year>=2015
replace nomen_old="H07" if importer=="CIV" & year<=2014 & year>=2008
replace nomen_old="H02" if importer=="CIV" & year<=2007 & year>=2003
replace nomen_old="H96" if importer=="CIV" & year<=2002 & year>=2001

replace nomen_old="H17" if importer=="CMR" & year<=2019 & year>=2019
replace nomen_old="H12" if importer=="CMR" & year<=2014 & year>=2013
replace nomen_old="H07" if importer=="CMR" & year<=2012 & year>=2010
replace nomen_old="H02" if importer=="CMR" & year<=2009 & year>=2009
replace nomen_old="H07" if importer=="CMR" & year<=2008 & year>=2007
replace nomen_old="H02" if importer=="CMR" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="CMR" & year<=2001 & year>=1996 ///!!!

replace nomen_old="H12" if importer=="COG" & year<=2014 & year>=2012
replace nomen_old="H07" if importer=="COG" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="COG" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="COG" & year<=2001 & year>=2007

replace nomen_old="H17" if importer=="CRI" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="CRI" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="CRI" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="CRI" & year<=2006 & year>=2003
replace nomen_old="H96" if importer=="CRI" & year<=2002 & year>=1997
replace nomen_old="H92" if importer=="CRI" & year<=1996 & year>=1996

replace nomen_old="H07" if importer=="DJI" & year<=2014 & year>=2011
replace nomen_old="H02" if importer=="DJI" & year==2009
replace nomen_old="H92" if importer=="DJI" & year<=2006               ///!!!

replace nomen_old="H07" if importer=="DMA" & year<=2016 & year>=2012
replace nomen_old="H02" if importer=="DMA" & year<=2011 & year>=2005
replace nomen_old="H96" if importer=="DMA" & year<=2004                   ///!!!

replace nomen_old="H17" if importer=="DOM" & year<=2019 & year>=2017
replace nomen_old="H12" if importer=="DOM" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="DOM" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="DOM" & year<=2006 & year>=2003
replace nomen_old="H96" if importer=="DOM" & year<=2002 & year>=1996

replace nomen_old="H17" if importer=="ECU" & year<=2018 & year>=2018
replace nomen_old="H12" if importer=="ECU" & year<=2017 & year>=2013
replace nomen_old="H07" if importer=="ECU" & year<=2012 & year>=2008
replace nomen_old="H02" if importer=="ECU" & year<=2007 & year>=2002
replace nomen_old="H96" if importer=="ECU" & year<=2001 & year>=1996

replace nomen_old="H17" if importer=="EGY" & year<=2019 & year>=2019
replace nomen_old="H12" if importer=="EGY" & year<=2018 & year>=2013
replace nomen_old="H07" if importer=="EGY" & year<=2012 & year>=2007
replace nomen_old="H02" if importer=="EGY" & year<=2006 & year>=2004
replace nomen_old="H96" if importer=="EGY" & year<=2003 & year>=1999
replace nomen_old="H92" if importer=="EGY" & year<=1998

replace nomen_old="H02" if importer=="EST" & year<=2003 & year>=2002
replace nomen_old="H96" if importer=="EST" & year<=2001 & year>=1996 ///!!!

replace nomen_old="H07" if importer=="GAB" & year<=2019 & year>=2008
replace nomen_old="H02" if importer=="GAB" & year<=2007 & year>=2002
replace nomen_old="H96" if importer=="GAB" & year<=2001 & year>=2000
replace nomen_old="H92" if importer=="GAB" & year<=1998               ///!!!

replace nomen_old="H12" if importer=="GEO" & year<=2020 & year>=2012
replace nomen_old="H02" if importer=="GEO" & year<=2011 & year>=2006
replace nomen_old="H96" if importer=="GEO" & year<=2005 & year>=2001

replace nomen_old="H17" if importer=="EEC" & year<=2021 & year>=2017
replace nomen_old="H12" if importer=="EEC" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="EEC" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="EEC" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="EEC" & year<=2001 & year>=1996

replace nomen_old="H17" if importer=="GHA" & year<=2020 & year>=2018
replace nomen_old="H12" if importer=="GHA" & year<=2017 & year>=2013
replace nomen_old="H07" if importer=="GHA" & year<=2012 & year>=2008
replace nomen_old="H02" if importer=="GHA" & year<=2007 & year>=2004
replace nomen_old="H96" if importer=="GHA" & year<=2003 & year>=2001

replace nomen_old="H17" if importer=="GIN" & year<=2020 & year>=2017
replace nomen_old="H02" if importer=="GIN" & year<=2013 & year>=2005
replace nomen_old="H92" if importer=="GIN" & year<=2004               ///!!!

replace nomen_old="H17" if importer=="GMB" & year<=2020 & year>=2019
replace nomen_old="H12" if importer=="GMB" & year<=2017 & year>=2017
replace nomen_old="H07" if importer=="GMB" & year<=2013 & year>=2010
replace nomen_old="H92" if importer=="GMB" & year<=2009               ///!!!

replace nomen_old="H17" if importer=="GNB" & year<=2020 & year>=2019
replace nomen_old="H12" if importer=="GNB" & year<=2017 & year>=2017
replace nomen_old="H07" if importer=="GNB" & year<=2014 & year>=2008
replace nomen_old="H02" if importer=="GNB" & year<=2007 & year>=2003
replace nomen_old="H96" if importer=="GNB" & year<=2002               ///!!!

replace nomen_old="H12" if importer=="GRD" & year<=2016 & year>=2015
replace nomen_old="H07" if importer=="GRD" & year<=2014 & year>=2012
replace nomen_old="H02" if importer=="GRD" & year<=2011 & year>=2010
replace nomen_old="H96" if importer=="GRD" & year<=2009 & year>=2000
replace nomen_old="H92" if importer=="GRD" & year<=1996

replace nomen_old="H12" if importer=="GTM" & year<=2012 & year>=2012
replace nomen_old="H07" if importer=="GTM" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="GTM" & year<=2006 & year>=2003
replace nomen_old="H96" if importer=="GTM" & year<=2002 & year>=1997

replace nomen_old="H07" if importer=="GUY" & year<=2016 & year>=2012
replace nomen_old="H02" if importer=="GUY" & year<=2011 & year>=2010
replace nomen_old="H07" if importer=="GUY" & year<=2009 & year>=2007
replace nomen_old="H96" if importer=="GUY" & year<=2003 & year>=1999
replace nomen_old="H92" if importer=="GUY" & year<=1996

replace nomen_old="H17" if importer=="HND" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="HND" & year<=2015 & year>=2012
replace nomen_old="H07" if importer=="HND" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="HND" & year<=2006 & year>=2003
replace nomen_old="H96" if importer=="HND" & year<=2002 & year>=1996

replace nomen_old="H12" if importer=="HRV" & year<=2013 & year>=2012
replace nomen_old="H07" if importer=="HRV" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="HRV" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="HRV" & year<=2001

replace nomen_old="H02" if importer=="HUN" & year<=2002 & year>=2002
replace nomen_old="H96" if importer=="HUN" & year<=2001 & year>=1996

replace nomen_old="H17" if importer=="IDN" & year<=2018 & year>=2017
replace nomen_old="H12" if importer=="IDN" & year<=2015 & year>=2013
replace nomen_old="H07" if importer=="IDN" & year<=2012 & year>=2007
replace nomen_old="H02" if importer=="IDN" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="IDN" & year<=2001 & year>=1998
replace nomen_old="H92" if importer=="IDN" & year<=1997 & year>=1996

replace nomen_old="H17" if importer=="IND" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="IND" & year<=2016 & year>=2011
replace nomen_old="H07" if importer=="IND" & year<=2010 & year>=2007
replace nomen_old="H02" if importer=="IND" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="IND" & year<=2001 & year>=1996

replace nomen_old="H17" if importer=="ISL" & year<=2018 & year>=2017
replace nomen_old="H12" if importer=="ISL" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="ISL" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="ISL" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="ISL" & year<=2001 & year>=1996

replace nomen_old="H17" if importer=="ISR" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="ISR" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="ISR" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="ISR" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="ISR" & year<=2001 & year>=1999

replace nomen_old="H12" if importer=="JAM" & year<=2016 & year>=2014
replace nomen_old="H07" if importer=="JAM" & year<=2013 & year>=2007
replace nomen_old="H02" if importer=="JAM" & year<=2006 & year>=2004
replace nomen_old="H96" if importer=="JAM" & year<=2003 & year>=1996

replace nomen_old="H17" if importer=="JOR" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="JOR" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="JOR" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="JOR" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="JOR" & year<=2001 & year>=2000

replace nomen_old="H17" if importer=="JPN" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="JPN" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="JPN" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="JPN" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="JPN" & year<=2001 & year>=1996

replace nomen_old="H17" if importer=="KAZ" & year<=2018 & year>=2017
replace nomen_old="H12" if importer=="KAZ" & year<=2016 & year>=2015

replace nomen_old="H17" if importer=="KEN" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="KEN" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="KEN" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="KEN" & year<=2006 & year>=2003
replace nomen_old="H96" if importer=="KEN" & year<=2002 & year>=1998

replace nomen_old="H17" if importer=="KGZ" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="KGZ" & year<=2016 & year>=2015
replace nomen_old="H07" if importer=="KGZ" & year<=2014 & year>=2008
replace nomen_old="H02" if importer=="KGZ" & year<=2007 & year>=2003
replace nomen_old="H96" if importer=="KGZ" & year<=2002 & year>=1999

replace nomen_old="H17" if importer=="KHM" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="KHM" & year<=2016 & year>=2014
replace nomen_old="H07" if importer=="KHM" & year<=2012 & year>=2009
replace nomen_old="H02" if importer=="KHM" & year<=2008 & year>=2005
replace nomen_old="H96" if importer=="KHM" & year<=2003 & year>=2002

replace nomen_old="H07" if importer=="KNA" & year<=2016 & year>=2012
replace nomen_old="H02" if importer=="KNA" & year<=2011 & year>=2010
replace nomen_old="H96" if importer=="KNA" & year<=2009 & year>=1999
replace nomen_old="H92" if importer=="KNA" & year<=1996

replace nomen_old="H17" if importer=="KOR" & year<=2021 & year>=2017
replace nomen_old="H12" if importer=="KOR" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="KOR" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="KOR" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="KOR" & year<=2001 & year>=1996

replace nomen_old="H12" if importer=="KWT" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="KWT" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="KWT" & year<=2006 & year>=2003
replace nomen_old="H92" if importer=="KWT" & year<=2002

replace nomen_old="H12" if importer=="LAO" & year<=2018 & year>=2014
replace nomen_old="H02" if importer=="LAO" & year<=2008 & year>=2008

replace nomen_old="H17" if importer=="LBR" & year<=2020 & year>=2018
replace nomen_old="H12" if importer=="LBR" & year<=2017 & year>=2012
replace nomen_old="H96" if importer=="LBR" & year<=2011

replace nomen_old="H12" if importer=="LCA" & year<=2021 & year>=2015
replace nomen_old="H07" if importer=="LCA" & year<=2014 & year>=2012
replace nomen_old="H02" if importer=="LCA" & year<=2011 & year>=2010
replace nomen_old="H96" if importer=="LCA" & year<=2007 & year>=2000
replace nomen_old="H92" if importer=="LCA" & year<=1996

replace nomen_old="H12" if importer=="LKA" & year<=2017 & year>=2013
replace nomen_old="H07" if importer=="LKA" & year<=2012 & year>=2007
replace nomen_old="H02" if importer=="LKA" & year<=2006 & year>=2003
replace nomen_old="H96" if importer=="LKA" & year<=2001 & year>=1998
replace nomen_old="H92" if importer=="LKA" & year<=1997

replace nomen_old="H17" if importer=="LSO" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="LSO" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="LSO" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="LSO" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="LSO" & year<=2001 & year>=1997
replace nomen_old="H92" if importer=="LSO" & year<=1996


replace nomen_old="H02" if importer=="LVA" & year<=2002 & year>=2002
replace nomen_old="H96" if importer=="LVA" & year<=2001 & year>=1998

replace nomen_old="H17" if importer=="MAR" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="MAR" & year<=2016 & year>=2015
replace nomen_old="H02" if importer=="MAR" & year<=2014 & year>=2003
replace nomen_old="H96" if importer=="MAR" & year<=2002 & year>=1996

replace nomen_old="H17" if importer=="MDG" & year<=2021 & year>=2017
replace nomen_old="H12" if importer=="MDG" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="MDG" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="MDG" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="MDG" & year<=2001 & year>=1996

replace nomen_old="H17" if importer=="MDV" & year<=2019 & year>=2017
replace nomen_old="H12" if importer=="MDV" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="MDV" & year<=2011 & year>=2008
replace nomen_old="H02" if importer=="MDV" & year<=2007 & year>=2003
replace nomen_old="H96" if importer=="MDV" & year<=2002 & year>=2000

replace nomen_old="H12" if importer=="MEX" & year<=2020 & year>=2013
replace nomen_old="H07" if importer=="MEX" & year<=2012 & year>=2008
replace nomen_old="H02" if importer=="MEX" & year<=2007 & year>=2003
replace nomen_old="H96" if importer=="MEX" & year<=2002 & year>=1996

replace nomen_old="H17" if importer=="MLI" & year<=2020 & year>=2018
replace nomen_old="H12" if importer=="MLI" & year<=2017 & year>=2015
replace nomen_old="H07" if importer=="MLI" & year<=2014 & year>=2008
replace nomen_old="H02" if importer=="MLI" & year<=2007 & year>=2003
replace nomen_old="H96" if importer=="MLI" & year<=2002 & year>=1996

replace nomen_old="H17" if importer=="MMR" & year<=2021 & year>=2017
replace nomen_old="H12" if importer=="MMR" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="MMR" & year<=2011 & year>=2009
replace nomen_old="H02" if importer=="MMR" & year<=2008 & year>=2005
replace nomen_old="H96" if importer=="MMR" & year<=2004 & year>=2004
replace nomen_old="H02" if importer=="MMR" & year<=2003 & year>=2003
replace nomen_old="H96" if importer=="MMR" & year<=2002 & year>=1996

replace nomen_old="H17" if importer=="MNE" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="MNE" & year<=2016 & year>=2011

replace nomen_old="H17" if importer=="MNG" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="MNG" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="MNG" & year<=2011 & year>=2008
replace nomen_old="H02" if importer=="MNG" & year<=2007 & year>=2004
replace nomen_old="H96" if importer=="MNG" & year<=2003 & year>=1997
replace nomen_old="H92" if importer=="MNG" & year<=1996

replace nomen_old="H17" if importer=="MOZ" & year<=2019 & year>=2018
replace nomen_old="H07" if importer=="MOZ" & year<=2016 & year>=2010
replace nomen_old="H02" if importer=="MOZ" & year<=2009 & year>=2009
replace nomen_old="H07" if importer=="MOZ" & year<=2008 & year>=2008
replace nomen_old="H02" if importer=="MOZ" & year<=2007 & year>=2002
replace nomen_old="H96" if importer=="MOZ" & year<=2001 & year>=2000
replace nomen_old="H92" if importer=="MOZ" & year<=1997

replace nomen_old="H17" if importer=="MUS" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="MUS" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="MUS" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="MUS" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="MUS" & year<=2001 & year>=1996

replace nomen_old="H12" if importer=="MWI" & year<=2017 & year>=2014
replace nomen_old="H07" if importer=="MWI" & year<=2013 & year>=2008
replace nomen_old="H02" if importer=="MWI" & year<=2007 & year>=2003
replace nomen_old="H96" if importer=="MWI" & year<=2002 & year>=2000
replace nomen_old="H92" if importer=="MWI" & year<=1998

replace nomen_old="H17" if importer=="MYS" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="MYS" & year<=2016 & year>=2013
replace nomen_old="H07" if importer=="MYS" & year<=2012 & year>=2008
replace nomen_old="H02" if importer=="MYS" & year<=2007 & year>=2002
replace nomen_old="H96" if importer=="MYS" & year<=2001 & year>=1996

replace nomen_old="H17" if importer=="NAM" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="NAM" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="NAM" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="NAM" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="NAM" & year<=2001 & year>=1997
replace nomen_old="H96" if importer=="NAM" & year<=1996

replace nomen_old="H17" if importer=="NER" & year<=2020 & year>=2019
replace nomen_old="H12" if importer=="NER" & year<=2018 & year>=2015
replace nomen_old="H07" if importer=="NER" & year<=2014 & year>=2008
replace nomen_old="H02" if importer=="NER" & year<=2007 & year>=2003
replace nomen_old="H96" if importer=="NER" & year<=2002 & year>=2001

replace nomen_old="H17" if importer=="NGA" & year<=2020 & year>=2020
replace nomen_old="H12" if importer=="NGA" & year<=2019 & year>=2015
replace nomen_old="H07" if importer=="NGA" & year<=2014 & year>=2009
replace nomen_old="H02" if importer=="NGA" & year<=2008 & year>=2005
replace nomen_old="H96" if importer=="NGA" & year<=2003 & year>=1996

replace nomen_old="H17" if importer=="NIC" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="NIC" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="NIC" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="NIC" & year<=2006 & year>=2003
replace nomen_old="H96" if importer=="NIC" & year<=2002 & year>=1997
replace nomen_old="H92" if importer=="NIC" & year<=1996

replace nomen_old="H17" if importer=="NOR" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="NOR" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="NOR" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="NOR" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="NOR" & year<=2001 & year>=1996

replace nomen_old="H17" if importer=="NPL" & year<=2018 & year>=2017
replace nomen_old="H12" if importer=="NPL" & year<=2016 & year>=2013
replace nomen_old="H07" if importer=="NPL" & year<=2012 & year>=2007
replace nomen_old="H02" if importer=="NPL" & year<=2006 & year>=2002

replace nomen_old="H17" if importer=="NZL" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="NZL" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="NZL" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="NZL" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="NZL" & year<=2001 & year>=1996

replace nomen_old="H17" if importer=="OMN" & year<=2017 & year>=2017
replace nomen_old="H12" if importer=="OMN" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="OMN" & year<=2009 & year>=2007
replace nomen_old="H02" if importer=="OMN" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="OMN" & year<=2001

replace nomen_old="H17" if importer=="PAK" & year<=2018 & year>=2017
replace nomen_old="H12" if importer=="PAK" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="PAK" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="PAK" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="PAK" & year<=2001 & year>=1996

replace nomen_old="H17" if importer=="PER" & year<=2018 & year>=2017
replace nomen_old="H12" if importer=="PER" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="PER" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="PER" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="PER" & year<=2001 & year>=1998
replace nomen_old="H92" if importer=="PER" & year<=1997

replace nomen_old="H17" if importer=="PHL" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="PHL" & year<=2016 & year>=2013
replace nomen_old="H07" if importer=="PHL" & year<=2012 & year>=2008
replace nomen_old="H02" if importer=="PHL" & year<=2007 & year>=2004
replace nomen_old="H96" if importer=="PHL" & year<=2003 & year>=1996

replace nomen_old="H17" if importer=="QAT" & year<=2021 & year>=2017
replace nomen_old="H12" if importer=="QAT" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="QAT" & year<=2011 & year>=2005
replace nomen_old="H02" if importer=="QAT" & year<=2004 & year>=2002

replace nomen_old="H17" if importer=="RUS" & year<=2020 & year>=2019
replace nomen_old="H12" if importer=="RUS" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="RUS" & year<=2011 & year>=2010
replace nomen_old="H96" if importer=="RUS" & year<=2001

replace nomen_old="H17" if importer=="RWA" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="RWA" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="RWA" & year<=2011 & year>=2008
replace nomen_old="H02" if importer=="RWA" & year<=2007 & year>=2005
replace nomen_old="H96" if importer=="RWA" & year<=2004 & year>=2000

replace nomen_old="H17" if importer=="SAU" & year<=2020 & year>=2020
replace nomen_old="H07" if importer=="SAU" & year<=2018 & year>=2018
replace nomen_old="H17" if importer=="SAU" & year<=2017 & year>=2017
replace nomen_old="H07" if importer=="SAU" & year<=2016 & year>=2016
replace nomen_old="H12" if importer=="SAU" & year<=2015 & year>=2012
replace nomen_old="H07" if importer=="SAU" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="SAU" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="SAU" & year<=2001

replace nomen_old="H17" if importer=="SEN" & year<=2020 & year>=2019
replace nomen_old="H12" if importer=="SEN" & year<=2018 & year>=2015
replace nomen_old="H07" if importer=="SEN" & year<=2014 & year>=2008
replace nomen_old="H02" if importer=="SEN" & year<=2007 & year>=2003
replace nomen_old="H96" if importer=="SEN" & year<=2002 & year>=2001

replace nomen_old="H17" if importer=="SGP" & year<=2021 & year>=2019
replace nomen_old="H12" if importer=="SGP" & year<=2018 & year>=2012
replace nomen_old="H07" if importer=="SGP" & year<=2011 & year>=2008
replace nomen_old="H02" if importer=="SGP" & year<=2007 & year>=2005
replace nomen_old="H96" if importer=="SGP" & year<=2004 & year>=1996

replace nomen_old="H12" if importer=="SLB" & year<=2016 & year>=2015
replace nomen_old="H02" if importer=="SLB" & year<=2013 & year>=2007
replace nomen_old="H92" if importer=="SLB" & year<=2006

replace nomen_old="H12" if importer=="SLB" & year<=2016 & year>=2015
replace nomen_old="H02" if importer=="SLB" & year<=2013 & year>=2007
replace nomen_old="H92" if importer=="SLB" & year<=2006

replace nomen_old="H17" if importer=="SLE" & year<=2020 & year>=2018
replace nomen_old="H07" if importer=="SLE" & year<=2016 & year>=2010
replace nomen_old="H02" if importer=="SLE" & year<=2006 & year>=2004

replace nomen_old="H17" if importer=="SLV" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="SLV" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="SLV" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="SLV" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="SLV" & year<=2001 & year>=1996


replace nomen_old="H07" if importer=="SRB" & year<=2010 & year>=2009
replace nomen_old="H02" if importer=="SRB" & year<=2005 & year>=2005

replace nomen_old="H02" if importer=="SVK" & year<=2003 & year>=2002
replace nomen_old="H96" if importer=="SVK" & year<=2001 & year>=1998

replace nomen_old="H17" if importer=="SWZ" & year<=2021 & year>=2017
replace nomen_old="H12" if importer=="SWZ" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="SWZ" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="SWZ" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="SWZ" & year<=2001 & year>=1996

replace nomen_old="H17" if importer=="SYC" & year<=2020 & year>=2018
replace nomen_old="H07" if importer=="SYC" & year<=2017 & year>=2015

replace nomen_old="H07" if importer=="TCD" & year<=2016 & year>=2014
replace nomen_old="H12" if importer=="TCD" & year<=2013 & year>=2013
replace nomen_old="H07" if importer=="TCD" & year<=2012 & year>=2007
replace nomen_old="H02" if importer=="TCD" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="TCD" & year<=2001 & year>=2001
replace nomen_old="H92" if importer=="TCD" & year<=1997

replace nomen_old="H17" if importer=="TGO" & year<=2020 & year>=2018
replace nomen_old="H12" if importer=="TGO" & year<=2017 & year>=2015
replace nomen_old="H07" if importer=="TGO" & year<=2014 & year>=2008
replace nomen_old="H02" if importer=="TGO" & year<=2007 & year>=2003
replace nomen_old="H96" if importer=="TGO" & year<=2002 & year>=1998
replace nomen_old="H92" if importer=="TGO" & year<=1997

replace nomen_old="H17" if importer=="THA" & year<=2021 & year>=2017
replace nomen_old="H12" if importer=="THA" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="THA" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="THA" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="THA" & year<=2001 & year>=1999

replace nomen_old="H07" if importer=="TJK" & year<=2017 & year>=2011

replace nomen_old="H12" if importer=="TTO" & year<=2018 & year>=2018
replace nomen_old="H07" if importer=="TTO" & year<=2013 & year>=2007
replace nomen_old="H02" if importer=="TTO" & year<=2006 & year>=2004
replace nomen_old="H96" if importer=="TTO" & year<=2003 & year>=1999
replace nomen_old="H92" if importer=="TTO" & year<=1996

replace nomen_old="H12" if importer=="TUN" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="TUN" & year<=2011 & year>=2008
replace nomen_old="H02" if importer=="TUN" & year<=2007 & year>=2002
replace nomen_old="H96" if importer=="TUN" & year<=2001 & year>=1996

replace nomen_old="H17" if importer=="TUR" & year<=2019 & year>=2019
replace nomen_old="H12" if importer=="TUR" & year<=2016 & year>=2013
replace nomen_old="H07" if importer=="TUR" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="TUR" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="TUR" & year<=2001 & year>=1996

replace nomen_old="H17" if importer=="TWN" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="TWN" & year<=2016 & year>=2014
replace nomen_old="H07" if importer=="TWN" & year<=2013 & year>=2009
replace nomen_old="H02" if importer=="TWN" & year<=2008 & year>=2004
replace nomen_old="H96" if importer=="TWN" & year<=2003 & year>=1996

replace nomen_old="H17" if importer=="TZA" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="TZA" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="TZA" & year<=2011 & year>=2008
replace nomen_old="H02" if importer=="TZA" & year<=2007 & year>=2005
replace nomen_old="H96" if importer=="TZA" & year<=2004 & year>=1998

replace nomen_old="H17" if importer=="UGA" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="UGA" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="UGA" & year<=2011 & year>=2008
replace nomen_old="H02" if importer=="UGA" & year<=2007 & year>=2002
replace nomen_old="H96" if importer=="UGA" & year<=2001 & year>=2000

replace nomen_old="H17" if importer=="URY" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="URY" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="URY" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="URY" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="URY" & year<=2001 & year>=1996

replace nomen_old="H17" if importer=="USA" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="USA" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="USA" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="USA" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="USA" & year<=2001 & year>=1996

replace nomen_old="H07" if importer=="VCT" & year<=2020 & year>=2012
replace nomen_old="H02" if importer=="VCT" & year<=2011 & year>=2010
replace nomen_old="H96" if importer=="VCT" & year<=2007 & year>=1999
replace nomen_old="H92" if importer=="VCT" & year<=1996

replace nomen_old="H12" if importer=="VEN" & year<=2016 & year>=2013
replace nomen_old="H02" if importer=="VEN" & year<=2012 & year>=2005
replace nomen_old="H96" if importer=="VEN" & year<=2004 & year>=1996

replace nomen_old="H17" if importer=="VNM" & year<=2020 & year>=2018
replace nomen_old="H12" if importer=="VNM" & year<=2017 & year>=2012
replace nomen_old="H07" if importer=="VNM" & year<=2010 & year>=2008
replace nomen_old="H02" if importer=="VNM" & year<=2007 & year>=2003
replace nomen_old="H96" if importer=="VNM" & year<=2002 & year>=2002

replace nomen_old="H17" if importer=="VUT" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="VUT" & year<=2016 & year>=2015
replace nomen_old="H07" if importer=="VUT" & year<=2012 & year>=2012
replace nomen_old="H02" if importer=="VUT" & year<=2007 & year>=2002

replace nomen_old="H12" if importer=="YEM" & year<=2016 & year>=2015
replace nomen_old="H02" if importer=="YEM" & year<=2009 & year>=2009

replace nomen_old="H17" if importer=="ZAF" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="ZAF" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="ZAF" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="ZAF" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="ZAF" & year<=2001 & year>=1997
replace nomen_old="H92" if importer=="ZAF" & year<=1996 & year>=1996

replace nomen_old="H12" if importer=="ZMB" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="ZMB" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="ZMB" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="ZMB" & year<=2001 & year>=2001

replace nomen_old="H17" if importer=="ZWE" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="ZWE" & year<=2016 & year>=2013
replace nomen_old="H07" if importer=="ZWE" & year<=2012 & year>=2007
replace nomen_old="H02" if importer=="ZWE" & year<=2003 & year>=2002
replace nomen_old="H96" if importer=="ZWE" & year<=2001 & year>=1997
replace nomen_old="H92" if importer=="ZWE" & year<=1996

compress


*Change nomenclatures (for consistency).
gen hs6_old=hs6
gen nomen=nomen_old
gen byte hs_change=0
	
foreach i in "92" "96" "02" "07" "12" { 
	
	foreach j in "96" "02" "07" "12" "17"{ 
		
		capture confirm file "./temp_files/HS`j'toHS`i'_1to1.dta" 
		if _rc==0 {
		dis("HS`j' to HS`i'")
		merge m:1 hs6 nomen using "./temp_files/HS`j'toHS`i'_1to1.dta", keep(master matched) 
		replace hs6=hs6_hs`i' if _m==3
		replace nomen="H`i'" if _m==3
		replace hs_change=1 if _m==3
		drop _m hs6_hs`i'
		}
		else {
		display "The file HS`j'toHS`i'_1to1.dta does not exist"
		}
		
	}
	
}

*Drop duplicates.
duplicates drop

*Drop variables.
keep importer year hs6* nomen* TTB

*Save database.
save "./temp_files/main_SGD.dta",replace
