
/*

/// Do-file written by Carlos Goes (andregoes@gmail.com)

*** This do file organizes regional CPI for Brazil for the following paper
GÓES, CARLOS; MATHESON, TROY. Domestic market integration and the law of one price in Brazil. Applied Economics Letters (Print), v. 23, p. 1-5, 2016.
Please quote the paper if you use it.

ATTN:
	Make sure you have the outreg2 command installed. If you dont:
     -> net search outreg2
 
 */
 
 
// 1. Organize your workspace
 
capture log close 																				// closes any open logs
clear 																							// clears the memory
clear matrix
clear mata
cd "Q:\DATA\S1\BRA\Research\Regional Price Indices\IBGE\" 
set more off  																					// makes sure STATA won't ask you to click "more" to continue running the code
set maxvar 32000
set matsize 11000
*set max_memory 5g
log using IPCA.log, replace  																// chooses logfile


// Import data and merge

	// Import 1999 to 2006

		import delimited "sa19992006.csv", varnames(1)

		local date = tm(1999m8)
		forv x=4/86 {
			rename v`x' d`=`date'-4+`x''
		}

		reshape long d, i(area code description) j(month)

		sort month area code

		format month %tm

		save d1999_2006.dta, replace
		
	// Import 2006 - 2011

		import delimited "sa20062011.csv", varnames(1) clear

		local date = tm(2006m7)
		forv x=4/69 {
			rename v`x' d`=`date'-4+`x''
		}

		reshape long d, i(area code description) j(month)

		sort month area code

		format month %tm

		save d2006_2011.dta, replace
		
	// Import 2012 - 2014

		import delimited "sa20112014.csv", varnames(1) clear

		local date = tm(2012m1)
		forv x=4/34 {
			rename v`x' d`=`date'-4+`x''
		}

		reshape long d, i(area code description) j(month)

		sort month area code

		format month %tm

		save d2012_2014.dta, replace

	// Merge
	
		use d1999_2006.dta
	
		merge 1:1 * using d2006_2011.dta, nogen
		
		merge 1:1 * using d2012_2014.dta, nogen			
		
		egen panelid = group(area code)
		
		rename d inf_mom
		
		gen eng_description = ""
		
		tempfile merge_file
		save `merge_file'
		
		import delimited "eng_description.csv", varnames(1) clear
		egen group = group(code)
		bysort group: gen n = _n
		drop if n > 1
		drop n group
		
		merge 1:m code using `merge_file', nogen
		
		rename month date
		
		save IPCA.dta, replace
		
		
	// Export
		
		xtset panelid date, m
		
		// Generate indices
		
			gen index = 100
		
			replace index = 100 * 1 + inf_mom/100 if date == tm(1999m8)
			replace index = l.index * (1 + inf_mom/100) if date > tm(1999m8)
			
         // Label and export to excel

			label var area "Geographical Area"
			label var code "Code"
			label var description "Description"
			label var date "Date"
			label var inf_mom "Inflation, month-on-month, in pct"
			label var index "CPI, per item, July 1999 = 100"
			
			/*

			preserve
				drop index
				reshape wide inf_mom, i(area code description panelid) j(date)
				export delimited using "inf_mom", replace	
			restore

			preserve
				drop inf_mom
				reshape wide index, i(area code description panelid) j(date)
				export delimited using "index", replace	
			restore
			
			*/

	
	// Start panel
	
		// Generate logs
		
			drop if missing(index)
			gen lindex = ln(index)
						
		
		// Generate time fixed effects
		
			bysort code date:  egen time_effects = mean(lindex)	
			gen lindex_time = lindex - time_effects 
					
			sort area code date				
			drop if area == "Brasil"
			
			label var lindex "Log of CPI, per item and city, July 1999 = 100"
			label var lindex_time "Log of CPI, per item and city, minus time effects"
		
			export delimited using "CPI_panel", replace
			
			save IPCA_workfile, replace


		// Create loop for specific panels /  
		
		
			drop if code < 1101 | code > 9101
			
			levelsof code, local(ids)
			
			di `ids'
			
			matrix define A = ( 0 , 0 , 0 , 0 , 0 , 0 , 0 )
			matrix colnames A = "Code" "Average lag" "N of obs" "N of periods" "N of groups" "P-value" "W-t-bar"
			
			foreach id of local ids {
				preserve
					cd "Q:\DATA\S1\BRA\Research\Regional Price Indices\IBGE\panels"

					qui keep if code == `id'

					qui gen n = _n	
						if (n == 1) {
						   local title = eng_description
						 }
						 
					qui line lindex_time date, by(area) yline(0) ///
						scheme(s2manual) name(g`id', replace) nodraw
					qui graph combine g`id', ///
						title("`id' - `title'", position(11) margin(vsmall)) ///
						saving(panel_`id', replace) name(panel_`id', replace) ///
						cols(1) scheme(s2manual)
						
					graph export panel_`id'.pdf, replace name(panel_`id')
					
					graph drop _all
					
					*egen temp_panelid = group(panelid)
					*drop panelid
					*rename temp_panelid panelid
					
					*qui export delimited using "panel_`x'", replace
					
					di `id'
					
					xtunitroot ips lindex_time, lags(aic)
					matrix A = A \ `id' , r(lagm) , r(N) , r(N_t) , r(N_g) , r(p_wtbar) , r(wtbar)
				restore
			}
			
			
			cd "Q:\DATA\S1\BRA\Research\Regional Price Indices\IBGE\
			
			preserve 
					
				drop *
				svmat A
			
				tempfile export_file
				save `export_file'
				
				import delimited "eng_description.csv", varnames(1) clear
				egen group = group(code)
				bysort group: gen n = _n
				drop if n > 1
				drop n group
				rename code A1
				
				merge 1:m A1 using `export_file', nogen
				
				drop if missing(A7)
				
				qui export delimited using "uroottests", replace

				
			restore
			
