clear all
set more off

cap log close
log using "./output/logs/log_d02.smcl", append

////////////////////////////
///Generate country codes///
////////////////////////////

*Import country code database.
import excel "./data/TRAINS/AllCountries.xls", sheet("Sheet1") firstrow clear

*Drop variable.
drop CountryName

*Rename variable.
rename CountryCode exporter

*Save database.
compress
save "./temp_files/ExporterCode.dta", replace

*Rename variable.
rename exporter importer

*Save database.
save "./temp_files/ImporterCode.dta", replace

////////////////////////
///Unzip source files -- PLEASE SAVE YOUR SOURCE FILES in the folder data/TRAINS/TRAINS`year' where year is the year of the data///
////////////////////////

clear

forvalues year=1995/1995 {

	*Unzip file.
	unzipfile "./data/TRAINS/TRAINS`year'.zip", replace 

	*Find unzipped file (file has non-standarized name).
	local files : dir "`c(pwd)'" files "*TRAINS`year'*.dta"
	
	*Open database.
	use NativeNomen Partner Reporter ReporterName PartnerName Product TariffYear TradeYear DutyType SimpleAverage ImportsValuein1000USD StandardDeviation TradeSource SpecificDutyImportsin1000USD using `files', clear
	
	*Drop observations with NA.
	drop if Reporter=="NA"
	drop if Partner=="NA"
	
	*Keep observations with no specific duties.
	keep if SpecificDutyImportsin1000USD==0
	drop SpecificDutyImportsin1000USD
	
	*Drop duplicates.
	duplicates drop
	
	*Save database.
	save "./temp_files/TRAINS`year'.dta", replace
	
	*Erase files.
	erase `files'
	
}


///////////////////
///Process files///
///////////////////

forvalues year=1995/2018 {
	
	*Open database.	
	use "./temp_files/TRAINS`year'.dta", clear
	
	*Rename variables.
	rename TariffYear year
	rename TradeYear tradeyear
	rename NativeNomen nomen
	rename ImportsValuein1000USD imports
	rename SimpleAverage simple
	*rename WeightedAverage weighted
	rename Reporter importer
	rename Partner exporter
	rename ReporterName importerName
	rename PartnerName exporterName
	rename Product hs6
	rename StandardDeviation sd // for tariffs
	rename TradeSource tradesource

	*Drop unspecified names.
	drop if exporterName=="Unspecified" | importerName=="Unspecified"
	
	*Reshape database.
	reshape wide simple imports sd tradesource, i(importer hs6 exporter year) j(DutyType) string
	drop tradesourceBND importsBND tradesourceMFN  importsMFN  tradesourcePRF  importsPRF
	
	*Rename variables.
	rename importsAHS imports_trains 
	rename tradesourceAHS tradesource_trains
	
	*Drop others.
	drop if exporterName=="Other Asia, nes"
	
	*Add ISO codes for exporters.
	merge m:1 exporter using "./temp_files/ExporterCode.dta", keep(master matched)
	keep if _merge==3
	drop _merge
	drop exporter exporterName
	rename ISO exporter

	*Add ISO codes for importers.
	merge m:1 importer using "./temp_files/ImporterCode.dta", keep(master matched)
	keep if _merge==3
	drop _merge
	drop importer importerName
	rename ISO importer
	
	*Order variables.
	order exporter importer hs6 year nomen imports
	
	*Rename nomenclatures.
	replace nomen="H92" if nomen=="H0"
	replace nomen="H96" if nomen=="H1"
	replace nomen="H02" if nomen=="H2"
	replace nomen="H07" if nomen=="H3"
	replace nomen="H12" if nomen=="H4"
	replace nomen="H17" if nomen=="H5"
	
	*Drop missing reporter/partner information.
	drop if missing(exporter) | missing(importer)
	
	*Drop duplicates.
	duplicates drop importer exporter nomen hs6 year, force
	
	*Save database.
	compress
	save "./temp_files/T`year'.dta", replace
	
}
	
*Erase files.
forvalues year=1995/2018 {
	
	erase "./temp_files/TRAINS`year'.dta" /* unzipped raw files */

}

/////////////////////////
///European Union data///
/////////////////////////

*Import EU data.
import excel "./data/TRAINS/European_Union.xlsx", sheet("Sheet1") firstrow clear

*Save EU data.
compress
save "./temp_files/European_Union.dta", replace

*Generate intra-EU combinations.
forvalues year=1995/2018 {

	*Open database.
	use "./temp_files/European_Union.dta", clear

	*Drop and rename variables.
	keep country
	rename country importer

	*Save importer and exporter databases.
	gen to_join = 1
	save "./temp_files/eu_importers.dta", replace
	rename importer exporter
	save "./temp_files/eu_exporters.dta", replace

	*Join importer and exporter databases (all combinations).
	joinby to_join using "./temp_files/eu_importers.dta"
	drop to_join
	drop if importer==exporter

	*Generate year variable.
	gen year=`year'

	*Drop importers not belonging to the EU in given year.
	rename importer country
	merge m:1 country using "./temp_files/European_Union.dta"
	drop _merge
	drop if year<entry_year & !mi(entry_year)
	drop if year<=entry_year & mid_year=="yes" & !mi(entry_year)
	drop entry_year mid_year
	rename country importer

	*Drop exporters not belonging to the EU in given year.
	rename exporter country
	merge m:1 country using "./temp_files/European_Union.dta"
	drop _merge
	drop if year<entry_year & !mi(entry_year)
	drop if year<=entry_year & mid_year=="yes" & !mi(entry_year)
	drop entry_year mid_year
	rename country exporter

	*Save database.
	gen to_join=1
	save "./temp_files/eu_importer_exporter_`year'.dta", replace

}

*Generate database for EU importers.
forvalues year=1995/2018 {
	
	*Open TRAINS database.
	use "./temp_files/T`year'.dta", clear

	*Generate variable to keep imports from the EU.
	gen to_keep=0
	replace to_keep=1 if importer=="EUN"

	*Merge with EU data to keep only importers from the EU.
	rename importer country
	merge m:1 country using "./temp_files/European_Union.dta"
	replace to_keep=1 if _merge==3
	drop if _merge==2
	drop _merge
	drop if year<entry_year & !mi(entry_year)
	drop if year<=entry_year & mid_year=="yes" & !mi(entry_year)
	drop entry_year mid_year
	rename country importer

	*Keep only importers from the EU.
	keep if to_keep==1
	drop to_keep

	*Collapse database.
	collapse (firstnm) imports_trains tradesource_trains simpleAHS sdAHS simpleBND sdBND simpleMFN sdMFN simplePRF sdPRF tradeyear, by(hs6 year nomen)

	*Replace values.
	replace imports_trains=.
	replace tradesource_trains=""
	replace simpleAHS=0
	replace sdAHS=0
	replace simplePRF=0
	replace sdPRF=0 
	replace tradeyear=.

	*Drop duplicates.
	duplicates drop hs6 year, force

	*Join with EU importer and exporter database.
	gen to_join=1
	joinby to_join using "./temp_files/eu_importer_exporter_`year'.dta"
	drop to_join

	*Save database.
	order importer exporter hs6 nomen year
	save "./temp_files/intra_eu_trade_`year'.dta", replace
	
}

*Generate database for non-EU imports to the EU.
forvalues year=1995/2018 {
	
	*Open TRAINS database.
	use "./temp_files/T`year'.dta" if importer=="EUN", clear
	
	*Drop variable.
	drop importer

	*Join with EU importers database.
	gen to_join=1 
	joinby to_join using "./temp_files/eu_importers.dta"
	drop to_join

	*Merge with EU data.
	rename importer country
	merge m:1 country using "./temp_files/European_Union.dta"
	drop _merge
	drop if year<entry_year & !mi(entry_year)
	drop if year<=entry_year & mid_year=="yes" & !mi(entry_year)
	drop entry_year mid_year
	rename country importer

	*Order database.
	order importer exporter hs6 nomen year

	*Save database.
	gen via_EUN=1
	save "./temp_files/eu_imports_from_non_eu_`year'.dta", replace

}
	
///////////////////
///Final dataset///
///////////////////

forvalues year=1995/2018 {

	*Open TRAINS database (non-EU importers).
	use "./temp_files/T`year'.dta" if importer!="EUN", clear

	*Append EU observations.
	append using "./temp_files/intra_eu_trade_`year'.dta"
	append using "./temp_files/eu_imports_from_non_eu_`year'.dta"

	*Drop duplicates (after considering the EU appended observations).
	replace via_EUN=0 if mi(via_EUN)
	duplicates tag importer exporter hs6 nomen year, gen(dup)
	drop if dup==1 & via_EUN==0
	drop dup

	*Replace missing AHS for MFN and generate flag.
	gen flag_ahs_imp=0
	replace flag_ahs_imp=1 if missing(simpleAHS) & simpleMFN==0
	label var flag_ahs_imp "Indicator, 1 if ahs_st imputed: ahs_st = mfn_st if missing(ahs_st) & mfn_st == 0"
	replace simpleAHS=simpleMFN if missing(simpleAHS) & simpleMFN==0

	*Generate MFN binding variable.
	gen byte mfn_binding=0
	replace mfn_binding=1 if simpleAHS==simpleMFN
	label var mfn_binding "mfn_binding = 1 if ahs_st == mfn_st, otherwise 0"

	*Drop missings.
	drop if missing(exporter, importer, hs6, year, nomen, simpleAHS)

	*Drop duplicates.
	duplicates drop importer exporter hs6 nomen year, force

	*Save database.
	compress
	save "./temp_files/T`year'.dta", replace

}

*Erase files.
forvalues year=1995/2018 {
		
		erase "./temp_files/eu_importer_exporter_`year'.dta"
		erase "./temp_files/intra_eu_trade_`year'.dta"
		erase "./temp_files/eu_imports_from_non_eu_`year'.dta"
		
}
