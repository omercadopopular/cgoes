clear
capture log close
log using "logs\d00.smcl", replace 

///////////////////
/// Harmonize comtrade vintages
//////////////////

clear

forval yr = $first_y / $last_y {	
	
	
	import delimited "data/comtrade/`yr'-hs6.csv", clear stringcols(12) 
	tempfile merge
	save `merge'

	/// Add H3 equivalent codes

	levelsof classification, local(vintages)

	gen ProductHS = ""
	foreach vintage of local vintages {
		di "Processing vintage `vintage', year `yr'"
		
		if ("`vintage'" == "H3") {
			replace ProductHS = commoditycode if classification == "`vintage'"
			save `merge', replace
		}
		else {
			import excel "data/conc/CompleteCorrelationsOfHS-SITC-BEC_20170606-cg.xlsx", firstrow clear
			keep H3 `vintage'
			collapse (first) H3, by(`vintage')

			rename H3 ProductHS
			rename `vintage' commoditycode
			gen classification = "`vintage'"
				
			merge 1:m classification commoditycode using `merge'
			
			tab _merge if classification == "`vintage'"
	*		drop if (_merge == 2)
			drop _merge
			
			save `merge', replace
		}
	}

	collapse (sum) tradevalueus (first) commodity, by(ProductHS year period perioddesc aggregatelevel isleafcode tradeflowcode tradeflow partnercode partner partneriso)

	rename ProductHS commoditycode


	// missing rate
	cap qui total tradevalueus if commoditycode == ""
	cap scalar missing = _b[tradevalueus]
	cap qui total tradevalueus 
	cap scalar total = _b[tradevalueus]
	cap display missing / total


	drop if missing(year)

	save "data/temp/`yr'-hs6-h3.dta", replace 

	
}


///////////////////
/// Match H3 ISIC 3
//////////////////

///// Stack annual data
clear

forval yr = $first_y / $last_y {
	di "Merging year `yr'"
	use "data/temp/`yr'-hs6-h3.dta", clear

	if `yr' == ${first_y} {
		tempfile long
		save `long', replace
	}
	else {
		append using `long'
		
		save `long', replace 
	}
}


///// HS TO ISIC 3 MAP

import delimited "data/conc/JobID-48_Concordance_H3_to_I3.CSV", clear

rename isicrevision3productcode isic3
rename hs2007productcode commoditycode

// Add missing "0" string digits
tostring isic3, gen(t_rev3)
gen t_0 = "0" if length(t_rev3) < 4
drop isic3
egen isic3 = concat(t_0 t_rev3)
drop t_* 

tostring commoditycode, gen(t_h03)
gen t_0 = "0" if length(t_h03) < 6
drop commoditycode
egen commoditycode = concat(t_0 t_h03)
drop t_* 

// Merge

merge 1:m commoditycode using `long'

forval yr = $first_y / $last_y {
	cap qui total tradevalueus if isic3 == "" & year == `yr'
	if _rc {
		display "Year `yr', no errors"
	}
	else {
	local missing = _b[tradevalueus]
	qui total tradevalueus if year == `yr'
	local total = _b[tradevalueus]
	display "Year `yr', `=`missing' / `total''"
	}

}

di "Dropping unclassified"

drop if commoditycode == "999999"

forval yr = $first_y / $last_y {
	cap qui total tradevalueus if isic3 == "" & year == `yr'
	if _rc {
		display "Year `yr', no errors"
	}
	else {
	local missing = _b[tradevalueus]
	qui total tradevalueus if year == `yr'
	local total = _b[tradevalueus]
	display "Year `yr', `=`missing' / `total''"
	}

}

drop _merge

save "data/temp/panel-hs6-isic3.dta", replace 

///////////////////
/// Match H3 ISIC 3
//////////////////

use "data/temp/panel-hs6-isic3.dta", clear

gen isic3_3d = substr(isic3,1,3)

collapse (sum) tradevalueus, by(year isic3_3d)

keep if !missing(isic3_3d) & !missing(year)

/*

check to see if complete balanced panel

tempfile values
save `values', replace

levelsof isic3_3d, local(set)
local obs `r(r)'


forval yr = $first_y / $last_y {

	clear
	set obs `obs'
	gen year = `yr'
	gen n = _n
	gen isic3_3d = ""

	local counter = 0
	foreach code of local set {
		local counter = `counter' + 1
		qui replace isic3_3d = "`code'" if n == `counter'
	}
	
	drop n
	
	if `yr' == $first_y {
		tempfile list
		save `list'
	}
	
	else {
		qui merge 1:1 isic3_3d year using `list'
		drop _merge
		save `list', replace
	}
}

use `values', clear
merge 1:1 isic3_3d year using `list'
*/

rename tradevalueus foreigndemandus

save "data/temp/panel-isic3-3d.dta", replace
