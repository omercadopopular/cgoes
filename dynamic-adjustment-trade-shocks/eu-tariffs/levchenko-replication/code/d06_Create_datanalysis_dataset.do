clear all
set more off

cap log close
log using "./output/logs/log_d06.smcl", append

////////////////////////////////
///Merge datasets BACI-TRAINS///
////////////////////////////////

*Append databases.
clear
forvalues year=1995/2018 {

	append using "./temp_files/data`year'_t.dta"	

}

* Croatia joined the EU in June 2013. At the moment, the tariff for Croatia in 2013 is the EU tariff. 
* Since this is inaccurate, and there is no better alternative, we drop Croatia in 2013
* See https://europa.eu/european-union/about-eu/countries_en#tab-0-1
drop if importer=="HRV" & year==2013
drop if exporter=="HRV" & year==2013 

* Cyprus
drop if importer=="CYP" & year==2004
drop if exporter=="CYP" & year==2004 

* Czech Republic
drop if importer=="CZE" & year==2004
drop if exporter=="CZE" & year==2004

* Estonia
drop if importer=="EST" & year==2004
drop if exporter=="EST" & year==2004 

* Hungary
drop if importer=="HUN" & year==2004
drop if exporter=="HUN" & year==2004 

* Latvia
drop if importer=="LVA" & year==2004
drop if exporter=="LVA" & year==2004 

* Lithuania
drop if importer=="LTU" & year==2004
drop if exporter=="LTU" & year==2004 

* Malta
drop if importer=="MLT" & year==2004
drop if exporter=="MLT" & year==2004 

* Poland
drop if importer=="POL" & year==2004
drop if exporter=="POL" & year==2004 

* Slovakia
drop if importer=="SVK" & year==2004
drop if exporter=="SVK" & year==2004 

* Slovenia
drop if importer=="SVN" & year==2004
drop if exporter=="SVN" & year==2004 

*Save database.
compress
save "./temp_files/FinalMergedData.dta", replace
