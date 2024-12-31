clear all
set more off

cap log close
log using "./output/logs/log_d04.smcl", append

//////////////////////////////
///Minor partner indicators///
//////////////////////////////

forvalues year=1995/2018 {
	
	*Open BACI database.
	use "./temp_files/Bacitrade`year'.dta", clear
	
	*Drop missing names.
	drop if exporter=="N/A" | importer=="N/A"
	
	*Indicator for Minor Trade Partner (Aggregate) 
		
		*Generate total.
		bys exporter importer year nomen: egen double btrade=total(imports_baci)
		
		*Sort variables.
		gsort importer year nomen -btrade
		
		*Generate rank.
		by importer year nomen: gen rank=sum(btrade!= btrade[_n-1]) 
		
		*Generate minor partner indicator.
		gen minor_partner_agg=(rank>10)
		label var minor_partner_agg "1 if minor partner in aggregate trade flows in the year, 0 otherwise"
		gen minor5_partner_agg=(rank>5)
		label var minor5_partner_agg "1 if minor (Not major top5) partner in aggregate trade flows in the year, 0 otherwise"	

	*Indicator for Minor Trade Partner -Not Top 10 (Product 3-digit code -FE level)
		
		*Generate HS code at 3-digit level.
		gen hs3 = substr(hs6,1,3)
		
		*Generate total.
		bys exporter importer year nomen hs3: egen double btrade_hs3=total(imports_baci)
		
		*Sort variables.
		gsort importer year nomen hs3 -btrade_hs3
		
		*Generate rank.
		by importer year nomen hs3: gen rankp=sum(btrade_hs3!=btrade_hs3[_n-1]) 
		
		*Generate minor partner indicator.
		gen minor_partner_prod3=(rankp>10)
		label var minor_partner_prod3 "1 if minor partner in hs3 trade flows in the year, 0 otherwise"
		gen minor5_partner_prod3=(rankp>5)
		label var minor5_partner_prod3 "1 if minor (Not major top5) partner  in hs3 trade flows in the year, 0 otherwise"
		
		*Drop rank variable.
		drop rankp
	
	*Indicator for Minor Trade Partner -Not Top 10 (Product 4-digit code -FE level)
	
		*Generate HS code at 4-digit level.
		gen hs4 = substr(hs6,1,4)
		
		**Generate total.
		bys exporter importer year nomen hs4: egen double btrade_hs4=total(imports_baci)
		
		*Sort variables.
		gsort importer year nomen hs4 -btrade_hs4
		
		*Generate rank.
		by importer year nomen hs4: gen rankp=sum(btrade_hs4!=btrade_hs4[_n-1]) 
		
		*Generate minor partner indicator.
		gen minor_partner_prod4=(rankp>10)
		label var minor_partner_prod4 "1 if minor partner in hs4 trade flows in the year, 0 otherwise"
		gen minor5_partner_prod4=(rankp>5)
		label var minor5_partner_prod4 "1 if minor (Not major top5) partner  in hs4 trade flows in the year, 0 otherwise"
	
		*Drop rank variable.
		drop rankp
	
	*Keep variables.
	keep importer exporter year hs6 nomen minor_partner_agg minor_partner_prod3 minor_partner_prod4 minor5_partner_agg  minor5_partner_prod3 minor5_partner_prod4
	
	*Save database.
	compress
	save "./temp_files/partnerind`year'.dta", replace

}

*Append files (all years).
clear
forvalues year=1995/2018 {

	append using "./temp_files/partnerind`year'.dta"

}

*Save database.
save "./temp_files/partnerind.dta", replace

*Erase files.
forvalues year=1995/2018 {

	erase "./temp_files/partnerind`year'.dta"

}
