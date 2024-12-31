clear all
set more off

cap log close
log using "./output/logs/log_d03.smcl", append

////////////////////////
///Concordance tables///
////////////////////////

*Import files and prepare them for algorithm
foreach i in "92" "96" "02" "07" "12" { 
	
	foreach j in "96" "02" "07" "12" "17" { 
		
		*Check if file exists.
		capture confirm file "./data/HS_concordances/HS`j'HS`i'.xls"
		
		if _rc==0 {
			
			*Import database.
			import excel "./data/HS_concordances/HS`j'HS`i'.xls", firstrow allstring clear
			
			*Generate 1 to 1 relationship indicator.
			gen byte rel=(Relationship=="1 to 1")
			replace rel=1 if Relationship=="'1:1" 
			replace rel=1 if Relationship=="1:1" 
			
			*Keep only 1 to 1 relationships.
			keep if rel==1
			
			*Drop variable.
			drop Relationship rel
			
			*Rename variables.
			rename hs`j' hs6 	// most recent nomenclature
			rename hs`i' hs6_hs`i' 
			
			*Generate nomenclature variable.
			gen nomen="H`j'"
			
			*Save database.
			save "./temp_files/HS`j'toHS`i'_1to1.dta", replace		
		}	
		
		else {		
			display "The file HS`j'HS`i' does not exist"
		}	
	}
}

////////////
///TRAINS///
////////////

forvalues year=1995/2018 {
	
	*Open database.
	use "./temp_files/T`year'.dta", clear
	
	*Rename variables.
	rename simpleAHS ahs_st
	rename simpleBND bnd_st
	rename simpleMFN mfn_st
	rename simplePRF prf_st
	rename sdAHS sd_ahst
	rename sdMFN sd_mfnt
 	rename sdPRF sd_prft
 	rename sdBND sd_bndt  

	*Change nomenclatures.
	gen hs6_old=hs6
	gen nomen_old=nomen
	gen byte hs_change=0
	
	*Merge with concordance table.
	foreach i in "92" "96" "02" "07" "12" { 
		
		foreach j in "96" "02" "07" "12" "17"{ 
			
			*Check file exists.
			capture confirm file "./temp_files/HS`j'toHS`i'_1to1.dta" 
			
			if _rc==0 {
				
				*Merge.
				merge m:1 hs6 nomen using "./temp_files/HS`j'toHS`i'_1to1.dta", keep(master matched) 
				
				*Replace nomenclature.
				replace hs6=hs6_hs`i' if _merge==3
				replace nomen="H`i'" if _merge==3
				replace hs_change=1 if _merge==3
				drop _merge hs6_hs`i'
			
			}
			
			else {
				
				display "The file HS`j'toHS`i'_1to1.dta does not exist"
			
			}
		
		}
		
	}

	*Save database.
	save "./temp_files/fullT`year'.dta", replace
	export delimited "./temp_files/fullT`year'.csv", replace

}

*** Run Julia Code here

//////////
///BACI///
//////////



forvalues year=1995/2018 {
	
	*Open TRAINS database.
	use "./temp_files/out/TF`year'", clear 
	
	*Re-run flags for binding MFN
	*Replace missing AHS for MFN and generate flag.
	replace flag_ahs_imp=1 if missing(ahs_st) & mfn_st==0
	label var flag_ahs_imp "Indicator, 1 if ahs_st imputed: ahs_st = mfn_st if missing(ahs_st) & mfn_st == 0"
	replace ahs_st=mfn_st if missing(ahs_st) & mfn_st==0

	*Generate MFN binding variable.
	drop mfn_binding
	gen byte mfn_binding=0
	replace mfn_binding=1 if ahs_st==mfn_st
	label var mfn_binding "mfn_binding = 1 if ahs_st == mfn_st, otherwise 0"
	
	*Adjust old HS6
	tostring hs6_old, replace
	replace hs6_old = (6-length(hs6_old))*"0" + hs6_old
	
	*Merge with BACI database.
	merge 1:1 exporter importer hs6 nomen year using "./temp_files/Bacitrade`year'.dta", keep(master match)
	drop _merge
	
	*Drop missing importers and exporters.
	drop if exporter=="N/A" | importer=="N/A" //Europe EFTA, not elsewhere specified (from BACI)
	
	*Save database.
	compress
	save "./temp_files/filldata`year'_t.dta", replace

}


/*
*Erase files.
forvalues year=1995/2018 {
	
	capture erase "./temp_files/fullT`year'.dta"
	
}
*/
	
