
clear

tempfile temp
save `temp', emptyok

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
	
	append using `temp'
	save `temp', replace
	

}

local group ahs mfn prf
foreach var of local group {
	di "`var'"
	gen new_`var' = 1 if !missing(`var'_st) & missing(`var'_pre)
	di "Dataset changes"
	count if new_`var' == 1
	di "Total size"
	count
	di "Conditional changes"
	sum `var'_st, detail
	sum `var'_pre, detail
}

