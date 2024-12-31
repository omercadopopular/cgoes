clear all
set more off

cap log close
log using "./output/logs/log_d01.smcl", append

////////////////////////
///Unzip source files///
////////////////////////

*Unzip files.
foreach h in "92" "96" "02" "07" "12" "17" {

	unzipfile "./data/BACI_2020/BACI_HS`h'_V202001.zip", replace 

}

*Convert files.
foreach h in "92" "96" "02" "07" "12" "17" {
	
	forvalues year=1995/2018 {
	
		capture confirm file "BACI_HS`h'_Y`year'_V202001.csv"
		
		if _rc==0 {
			import delimited "BACI_HS`h'_Y`year'_V202001.csv", clear
			compress
			save "./data/BACI_2020/baci`h'/baci`h'_`year'.dta", replace
			capture erase "BACI_HS`h'_Y`year'_V202001.csv"
		}
		else {
			display "The file BACI_HS`h'_Y`year'_V202001.csv does not exist"
		}
	
	}
	
}


////////////////////////////
///Generate country codes///
////////////////////////////

*Import country code database.
import delimited "./data/BACI_2020/country_codes_V202001.csv", clear  

*Drop variables.
keep country_code iso_3digit_alpha

*Rename variables.
rename country_code i
rename iso_3digit_alpha exporter

*Save database.
compress
save "./temp_files/expcode_baci.dta", replace 

*Rename variables.
rename i j
rename exporter importer

*Save database.
save "./temp_files/impcode_baci.dta", replace 

//////////////////////////////
///Generate clean databases///
//////////////////////////////

foreach h in "92" "96" "02" "07" "12" "17" {
	
	forvalues year=1995/2018 {
	
		capture confirm file "./data/BACI_2020/baci`h'/baci`h'_`year'.dta"
		
		if _rc==0 {
			
			*Open database.
			use "./data/BACI_2020/baci`h'/baci`h'_`year'.dta", clear

			*Merge with exporter country code names.
			merge m:1 i using "./temp_files/expcode_baci.dta"
			drop if _merge==2
			drop _merge

			*Merge with importer country code names.	
			merge m:1 j using "./temp_files/impcode_baci.dta"
			drop if _merge==2
			drop _merge

			*Drop NA.
			drop if exporter=="N/A" | importer=="N/A" //Europe EFTA, not elsewhere specified

			*Rename variables.
			rename t year
			rename v imports_baci
			rename q quantity_baci
			rename k hs6
			drop i j

			*Convert HS code to string (6-digits).
			tostring hs6, replace
			replace hs6="0"+hs6 if length(hs6)<6
			assert (length(hs6)==6)

			*Label variables.
			label variable imports_baci "FOB value, in 1000 USD"
			label variable quantity_baci "Quantity in tons"
			label variable hs6 "HS 6-digit code"

			*Generate HS version (nomenclature).
			gen temp="`h'"
			gen nomen=""
			replace nomen="H92" if temp=="92"
			replace nomen="H96" if temp=="96"
			replace nomen="H02" if temp=="02"
			replace nomen="H07" if temp=="07"
			replace nomen="H12" if temp=="12"
			replace nomen="H17" if temp=="17"
			drop temp

			*Order database.
			order importer exporter year hs6 imports_baci quantity_baci nomen

			*Save database.
			save "./temp_files/Bacitrade`year'_`h'.dta", replace
			
		}
		
		else {
			display "The file baci`h'_`year'.dta does not exist"
		}
	
	}
	
}

///////////////////////////////////
///Merge clean databases by year///
///////////////////////////////////

forvalues year=1995/2018 {

	*Append databases.
	clear
	foreach h in "92" "96" "02" "07" "12" "17" { 
	
		capture confirm file "./temp_files//Bacitrade`year'_`h'.dta" 
		if _rc==0 {
			append using "./temp_files//Bacitrade`year'_`h'.dta"
		}
		else {
			display "The file Bacitrade`year'_`h' does not exist"
		}	
		
	}
	
	*Drop observations with empty names.
	drop if exporter=="" | importer==""
	
	*Drop duplicates.
	*duplicates drop importer exporter nomen hs6 year, force
	duplicates tag importer exporter nomen hs6 year, gen(dup)
	drop if dup>0
	drop dup
	
	*Save database.
	compress
	save "./temp_files//Bacitrade`year'.dta", replace
	
}

*Erase files.
foreach h in "92" "96" "02" "07" "12" "17" {
	
	forvalues year=1995/2018 {
		
		capture erase "./data/BACI_2020/baci`h'/baci`h'_`year'.dta"
		capture erase "./temp_files/Bacitrade`year'_`h'.dta" 
	
	}
	
}
