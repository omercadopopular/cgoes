clear all
set more off
set type double, permanently

cap log close
log using "./output/logs/log_c05.smcl", append

////////////////
///HS section///
////////////////

*Open database.
use "./temp_files/DataregW_did_ahs_st_2006.dta", clear

*Generate trade weights.
egen total_imports=sum(imports_baci), by(importer hs_section)
gen w=imports_baci/total_imports

*Generate weighted tariffs.
gen ahs_st_w=w*ahs_st

*Collapse database.
collapse (mean) mean_ahs_st=ahs_st (sum) mean_ahs_st_w=ahs_st_w, by(importer hs_section)

*Save database.
save "./temp_files/mean_ahs_st.dta", replace

///////////////
///5 sectors///
///////////////

*Open database.
use "./temp_files/DataregW_did_ahs_st_2006.dta", clear

*Generate countries.
replace importer="EUR" if importer=="AUT" | importer=="BEL" | importer=="BGR" | importer=="CHE" | importer=="CYP" | importer=="CZE" | importer=="DEU" | importer=="DNK" | importer=="ESP" | importer=="EST" | importer=="FIN" | importer=="FRA" | importer=="GBR" | importer=="GRC" | importer=="HRV" | importer=="HUN" | importer=="IRL" | importer=="ITA" | importer=="LTU" | importer=="LUX" | importer=="LVA" | importer=="MLT" | importer=="NLD" | importer=="NOR" | importer=="POL" | importer=="PRT" | importer=="ROU" | importer=="SVK" | importer=="SVN"
replace exporter="EUR" if exporter=="AUT" | exporter=="BEL" | exporter=="BGR" | exporter=="CHE" | exporter=="CYP" | exporter=="CZE" | exporter=="DEU" | exporter=="DNK" | exporter=="ESP" | exporter=="EST" | exporter=="FIN" | exporter=="FRA" | exporter=="GBR" | exporter=="GRC" | exporter=="HRV" | exporter=="HUN" | exporter=="IRL" | exporter=="ITA" | exporter=="LTU" | exporter=="LUX" | exporter=="LVA" | exporter=="MLT" | exporter=="NLD" | exporter=="NOR" | exporter=="POL" | exporter=="PRT" | exporter=="ROU" | exporter=="SVK" | exporter=="SVN"
*No LUX, ROU
replace importer="ROW" if importer!="USA" & importer!="JPN" & importer!="CHN" & importer!="EUR" & importer!="CAN"
replace exporter="ROW" if exporter!="USA" & exporter!="JPN" & exporter!="CHN" & exporter!="EUR" & exporter!="CAN"

*Drop flows from a country to same country.
drop if importer==exporter

*Generate 5 sectors.
gen sector=""
replace sector="A-B" if hs_section==1 | hs_section==2 | hs_section==3 | hs_section==5
replace sector="Non-durables" if hs_section==4
replace sector="Upstream" if hs_section==6 | hs_section==7 | hs_section==8 | hs_section==9 | hs_section==10 | hs_section==11 | hs_section==12 | hs_section==13 | hs_section==14 | hs_section==15 | hs_section==21
replace sector="Machinery" if hs_section==16 | hs_section==17 | hs_section==18 | hs_section==19 | hs_section==20
*Art goes into upstream.

*Generate trade weights.
egen total_imports=sum(imports_baci), by(importer sector)
gen w=imports_baci/total_imports

*Generate weighted tariffs.
gen ahs_st_w=w*ahs_st

*Collapse database.
collapse (mean) mean_ahs_st=ahs_st (sum) mean_ahs_st_w=ahs_st_w, by(importer exporter sector)

*Generate gross tariffs.
gen mean_ahs_st_g=1+mean_ahs_st
gen mean_ahs_st_w_g=1+mean_ahs_st_w
drop mean_ahs_st mean_ahs_st_w
rename (mean_ahs_st_g mean_ahs_st_w_g) (mean_ahs_st mean_ahs_st_w)

*Generate D-U sector.
levelsof importer, local(c)
foreach cc of local c{
	foreach ccc of local c{
		qui count
		local NN=`r(N)'+1
		set obs `NN'
		replace importer="`cc'" if importer==""
		replace exporter="`ccc'" if exporter==""
		replace sector="D-U" if sector==""
	}
}
drop if importer==exporter
replace mean_ahs_st=1 if sector=="D-U"
replace mean_ahs_st_w=1 if sector=="D-U"

*Generate flows from country to same country.
levelsof importer, local(c)
levelsof sector, local(s)
foreach cc of local c{
	foreach ss of local s{
		qui count
		local NN=`r(N)'+1
		set obs `NN'
		replace importer="`cc'" if importer==""
		replace exporter="`cc'" if exporter==""
		replace sector="`ss'" if sector==""
	}
}
replace mean_ahs_st=1 if importer==exporter
replace mean_ahs_st_w=1 if importer==exporter

*Order countries.
replace importer="AUSA" if importer=="USA"
replace exporter="AUSA" if exporter=="USA"
sort sector exporter importer 
replace importer="USA" if importer=="AUSA"
replace exporter="USA" if exporter=="AUSA"

*Sort variables.
rename exporter source_c
rename importer dest_c
order source_c dest_c sector mean_ahs_st mean_ahs_st_w

*Save database.
save "./temp_files/tariffs_55.dta", replace
export delimited using "./temp_files/tariffs_55.csv", replace

////////////////////////////
///2 countries, 2 sectors///
////////////////////////////

*Open database.
use "./temp_files/DataregW_did_ahs_st_2006.dta", clear

*List countries.
levelsof exporter, local(list_c)

foreach country of local list_c{

	preserve
	
		display "`country'"

		*Generate ROW.
		replace exporter="ROW" if exporter!="`country'"
		replace importer="ROW" if importer!="`country'"

		*Drop flows from a country to same country.
		drop if importer==exporter

		*Generate sector.
		gen sector="Goods"

		*Generate trade weights.
		egen total_imports=sum(imports_baci), by(importer sector)
		gen w=imports_baci/total_imports

		*Generate weighted tariffs.
		gen ahs_st_w=w*ahs_st

		*Collapse database.
		collapse (mean) mean_ahs_st=ahs_st (sum) mean_ahs_st_w=ahs_st_w, by(importer exporter sector)

		*Generate gross tariffs.
		gen mean_ahs_st_g=1+mean_ahs_st
		gen mean_ahs_st_w_g=1+mean_ahs_st_w
		drop mean_ahs_st mean_ahs_st_w
		rename (mean_ahs_st_g mean_ahs_st_w_g) (mean_ahs_st mean_ahs_st_w)

		*Generate services sector.
		levelsof importer, local(c)
		foreach cc of local c{
			foreach ccc of local c{
				qui count
				local NN=`r(N)'+1
				set obs `NN'
				replace importer="`cc'" if importer==""
				replace exporter="`ccc'" if exporter==""
				replace sector="Services" if sector==""
			}
		}
		drop if importer==exporter
		replace mean_ahs_st=1 if sector=="Services"
		replace mean_ahs_st_w=1 if sector=="Services"

		*Generate flows from country to same country.
		levelsof importer, local(c)
		levelsof sector, local(s)
		foreach cc of local c{
			foreach ss of local s{
				qui count
				local NN=`r(N)'+1
				set obs `NN'
				replace importer="`cc'" if importer==""
				replace exporter="`cc'" if exporter==""
				replace sector="`ss'" if sector==""
			}
		}
		replace mean_ahs_st=1 if importer==exporter
		replace mean_ahs_st_w=1 if importer==exporter

		*Order countries.
		replace importer="A`country'" if importer=="`country'"
		replace exporter="A`country'" if exporter=="`country'"
		sort sector exporter importer 
		replace importer="`country'" if importer=="A`country'"
		replace exporter="`country'" if exporter=="A`country'"

		*Sort variables.
		rename exporter source_c
		rename importer dest_c
		order source_c dest_c sector mean_ahs_st mean_ahs_st_w

		*Save database.
		save "./temp_files/tariffs_`country'.dta", replace
		export delimited using "./temp_files/tariffs_`country'.csv", replace
		
	restore
	
}
