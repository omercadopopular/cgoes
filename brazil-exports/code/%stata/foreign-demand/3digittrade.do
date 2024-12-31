clear

use "${comtradepath}/panel-hs6-isic3.dta", clear

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

save "${comtradepath}/panel-isic3-3d.dta", replace
