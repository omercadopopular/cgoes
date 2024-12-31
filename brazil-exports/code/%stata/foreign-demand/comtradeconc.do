clear

forval yr = $first_y / $last_y {	
	
	
	import delimited "${comtradepath}/`yr'-hs6.csv", clear stringcols(12) 
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
			import excel "${concpath}/CompleteCorrelationsOfHS-SITC-BEC_20170606-cg.xlsx", firstrow clear
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

	save "${comtradepath}/`yr'-hs6-h3.dta", replace 

	
}

