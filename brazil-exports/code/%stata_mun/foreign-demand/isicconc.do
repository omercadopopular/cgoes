clear

///// Stack annual data

forval yr = $first_y / $last_y {
	di "Merging year `yr'"
	use "${comtradepath}/`yr'-hs6-h3.dta", clear

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

import delimited "${concpath}/JobID-48_Concordance_H3_to_I3.CSV", clear

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

save "${comtradepath}/panel-hs6-isic3.dta", replace 
