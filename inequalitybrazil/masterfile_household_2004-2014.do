///////////////////////////////////////////////////////////////////////////////
/////////////////////////////////// CODED BY //////////////////////////////////
///////////////////////////////// CARLOS GOES /////////////////////////////////
///////////////////////////// andregoes@gmail.com /////////////////////////////
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
////////////////////////////////// READ ME ////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

/*

Purpose: Importing PNAD data, adjusting income per capita data for purchasing
	power differences, creating state-wide and nation-wide percentiles
	of PPP ajusted family income per capita, using such percentiles to plot 
	regional income inequality patterns, and consumption-based inequality.
	
Output: Several excel files with time series for spatial-price differences adjusted
	income percentiles for each state, as well as how those percentiles fit in the national
	income distribution; time series for consumption patterns at different percentiles;
	Gini, QE, and other inequality coefficients for each state.
	
Attention: To make sure that the file runs through all PNADS, the variable
	names have to be the same for all of them (if there was a change in name,
	you can standardize via dictionaries). You have to store the different
	survey waves in /year folders. 
	
Timing: If you don't need to import raw data from the TXT files, running this
	code for 14 vintages of the survey takes about 15 minutes. If you import raw
	data, it takes about 25 minutes.

 */
 
///////////////////////////////////////////////////////////////////////////////
//////////////////////////////// USER INTERFACE ///////////////////////////////
/////////// CHANGE THE VALUES IN THIS SECTION FOLLOWING INSTRUCTIONS //////////
///////////////////////////////////////////////////////////////////////////////

  // Preamble

	global folder = "Q:\DATA\S1\BRA\Inequality\PNAD"
	global resultsfolder = "Q:\DATA\S1\BRA\Inequality\PNAD\results"
	global imagefolder = "Q:\DATA\S1\BRA\Inequality\PNAD\images"
	global first = 2014	// First PNAD being used
	global last = 2014 	// Last PNAD being used
	global exception = 2010 // Year when there is no PNAD

 // I. Do you need to import the raw data in this run or will you use a saved dta file?
	// Set import = 1 for importing raw data
		
	scalar import = 0
 
 // II. Input the survey weighting variables
 
	global psu = "V4618"
	global strat = "V4617" 
	global weight = "V4611" 
	
// III. Set parameters for PPP adjustment
	// 0 = no adjustment
	// 1 = adjustment

	scalar pppadjustment = 1
	scalar litcoeff = 0.5554
	
	// Housing variables
	
	local rentvar = "V0208"
	local roomvar = "V0205"	
	local ruralvar = "V4105"

// IV. Set ntiles

	local ntiles = "20"
	

///////////////////////////////////////////////////////////////////////////////
//////////////////////////// CODE (ADVANCED USERS) ////////////////////////////
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
////////////////////////////////// MASTER LOOP ////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

forvalues tyear = $first / $last {

	if ( `tyear' == $exception ) {
		di "No PNAD this year"
	}
	
	else {

		global year = `tyear'
		global workingfolder = "$folder\\$year"
	 

		///////////////////////////////////////////////////////////////////////////////
		////////////////////////// 1. WORKSPACE ORGANIZATION //////////////////////////
		///////////////////////////////////////////////////////////////////////////////
		 
		capture log close 										// closes any open logs
		clear 													// clears the memory
		clear matrix 											// clears matrix memory
		clear mata 												// clears mata memory
		cd $workingfolder 				// sets working directory
		set more off  											// most important command in STATA :)/
		set maxvar 32000
		set matsize 11000
		*set max_memory 5g
		log using ${year}_household.log, replace  					// chooses logfile

		///////////////////////////////////////////////////////////////////////////////
		//////////////////////////// 2. DATASET PREPARATION ///////////////////////////
		///////////////////////////////////////////////////////////////////////////////

		// Import data

			if (import == 1) {
				clear
				infile using $year.dct
				export delimited using "$year", replace
				save p$year, replace
			}

		// Load dataset

			use p$year, clear
			svyset $psu [weight=$weight], strat($strat)

		// Create group id by state

			egen id = group(UF)
			
		// Label regions

			gen region = ""
			replace region = "N" if UF >= 10 & UF < 20 
			replace region = "NE" if UF >= 20 & UF < 30
			replace region = "SE" if UF >= 30 & UF < 40
			replace region = "S" if UF >= 40 & UF < 50
			replace region = "CO" if UF >= 50 & UF < 60
			
		///////////////////////////////////////////////////////////////////////////////
		//////////////////////////// 3. PPP ADJUSTMENTS ///////////////////////////
		///////////////////////////////////////////////////////////////////////////////

		if (pppadjustment == 1) {


			// 1. Estimate cost of living adjustments by state and rural area


				** 1.1 Generate dummy for rural areas

					gen rural = 0
					replace rural = 1 if `ruralvar' > 3

				** 1.2. Create rent averages

					** 1.2.1 Adjust data
					
					replace `rentvar' = . if `rentvar' > 1.000e+11
					replace `rentvar'  = . if `rentvar' < 1
					
					** 1.2.2 Calculate state averages

					bysort id `ruralvar': egen rentstate = mean(`rentvar')
					
					** 1.2.3 Calculate national averages

					egen rentnation = mean(`rentvar')

				** 1.3. Create room per household averages

					** 1.3.1 Calculate state averages
					
					tempvar t_roomv1
					bysort id `ruralvar': egen `t_roomv1' = mean(`roomvar') if `roomvar' != .
					bysort id `ruralvar': egen roomstate = max(`t_roomv1') 
					
					** 1.3.2 Calculate national averages

					tempvar t_roomv2
					egen `t_roomv2' = mean(`roomvar') if `roomvar' != .
					egen roomnation = max(`t_roomv2') 

				** 1.4. Create PPP index
					gen rentindex = ( ( rentstate / roomstate ) / ( rentnation / roomnation ) ) - 1
					gen pppindex =  ( litcoeff * rentindex ) + 1

				
			// 2. Adjust income data

				replace V4621 = . if V4621 > 1.000e+11
				replace V4621 = . if V4621 < 1
				gen income = V4621 / pppindex
				gen lincome = ln(income)
		}


		///////////////////////////////////////////////////////////////////////////////
		////////////////////////// 4. CREATE & EXPORT XTILES //////////////////////////
		///////////////////////////////////////////////////////////////////////////////


			xtile pctile = income [aweight=$weight], n(`ntiles')


			forval x = 1/27 {
				xtile pctileUF`x' = income [aweight=$weight] if id == `x', n(`ntiles')
			}

			egen pctilestate = rowtotal(pctileUF*)
			drop pctileUF*
			
			preserve
				collapse (mean) UF pctile, by(id pctilestate)
				drop id
				reshape wide pctile, i(UF) j(pctilestate)
				export excel using $resultsfolder\percentiles.xlsx, firstrow(variables) sheet("$year") sheetmodify
			restore

			preserve
				collapse (mean) UF income, by(id pctilestate)
				drop id
				reshape wide income, i(UF) j(pctilestate)
				export excel using $resultsfolder\incomepercentiles.xlsx, firstrow(variables) sheet("$year") sheetmodify
			restore

			preserve
				collapse (mean) income, by(pctilestate)
				export excel using $resultsfolder\incomepercentilestotal.xlsx, firstrow(variables) sheet("$year") sheetmodify
			restore	

			preserve
				collapse (mean) pppindex, by(UF)
				export excel using $resultsfolder\ppp.xlsx, firstrow(variables) sheet("$year") sheetmodify
			restore	

			
		///////////////////////////////////////////////////////////////////////////////
		//////////////////////////// 5. PLOT XTILES CHARTS ///////////////////////////
		///////////////////////////////////////////////////////////////////////////////


		preserve

			collapse (mean) UF pctile, by(id pctilestate)


			// df vs ma

			twoway scatter pctile pctilestate if UF == 53, msymbol(t) || ///
				scatter pctile pctilestate if UF == 25, msymbol(t) || ///	scatter pctile pctilestate if UF == 25, msymbol(s)  || ///
				scatter pctile pctile if UF == 53, msymbol(none) connect(l) ///
				ytitle("Percentile of national income distribution") ///
				xtitle("Percentile of state income distribution") ///
				title("Brazil: HH Income per Capita Distribution, $year", margin(vsmall) position(11)) ///
				subtitle("(Percentiles of state-wide and nation-wide distributions, PPP adjusted)", margin(vsmall) position(11)) ///
				legend( lab(1 "DF") lab(2 "MA") lab(3 "45 degree")) ///
				lwidth(thin) scheme(s2color) name(scatters1, replace)
				graph export $imagefolder\\${year}_scatters1.pdf, as(pdf) replace

			// north
				 
			twoway scatter pctile pctilestate if UF == 11, msize(small)  || ///
				scatter pctile pctilestate if UF == 12, msize(small)  || ///
				scatter pctile pctilestate if UF == 13, msize(small)  || ///
				scatter pctile pctilestate if UF == 14, msize(small)  || ///
				scatter pctile pctilestate if UF == 15, msize(small)  || ///
				scatter pctile pctilestate if UF == 16, msize(small)  || ///
				scatter pctile pctilestate if UF == 17, msize(small)  || ///
				scatter pctile pctile if UF == 53, msymbol(none) connect(l) ///
				ytitle("Percentile of national income distribution") ///
				xtitle("Percentile of state income distribution") ///
				title("BR North: HH Income per Capita Distribution, $year", margin(vsmall) position(11)) ///
				subtitle("(Percentiles of state-wide and nation-wide distributions, PPP adjusted)", margin(vsmall) position(11)) ///
				legend( lab(1 "RO") lab(2 "AC") lab(3 "AM")  lab(4 "RR") lab(5 "PA")  lab(6 "AP")  lab(7 "TO")  lab(8 "45 degree")) ///
				lwidth(thin) scheme(s2color) name(north, replace)
				graph export $imagefolder\\${year}_north.pdf, as(pdf) replace		
				
			// ne
				 
			twoway scatter pctile pctilestate if UF == 21, msize(small)  || ///
				scatter pctile pctilestate if UF == 22, msize(small)  || ///
				scatter pctile pctilestate if UF == 23, msize(small)  || ///
				scatter pctile pctilestate if UF == 24, msize(small)  || ///
				scatter pctile pctilestate if UF == 25, msize(small)  || ///
				scatter pctile pctilestate if UF == 26, msize(small)  || ///
				scatter pctile pctilestate if UF == 27, msize(small)  || ///
				scatter pctile pctilestate if UF == 28, msize(small)  || ///
				scatter pctile pctilestate if UF == 29, msize(small)  || ///
				scatter pctile pctile if UF == 53, msymbol(none) connect(l) ///
				ytitle("Percentile of national income distribution") ///
				xtitle("Percentile of state income distribution") ///
				title("BR Northeast: HH Income per Capita Distribution, $year", margin(vsmall) position(11)) ///
				subtitle("(Percentiles of state-wide and nation-wide distributions, PPP adjusted)", margin(vsmall) position(11)) ///
				legend( lab(1 "MA") lab(2 "PI") lab(3 "CE")  lab(4 "RN") lab(5 "PB")  lab(6 "PE")  lab(7 "AL")  lab(8 "SE")  lab(9 "BA")  lab(10 "45 degree")) ///
				lwidth(thin) scheme(s2color) name(northeast, replace)
				graph export $imagefolder\\${year}_northeast.pdf, as(pdf) replace		
				
			// se
				 
			twoway scatter pctile pctilestate if UF == 31, msize(small)  || ///
				scatter pctile pctilestate if UF == 32, msize(small)  || ///
				scatter pctile pctilestate if UF == 33, msize(small)  || ///
				scatter pctile pctilestate if UF == 35, msize(small)  || ///
				scatter pctile pctile if UF == 53, msymbol(none) connect(l) ///
				ytitle("Percentile of national income distribution") ///
				xtitle("Percentile of state income distribution") ///
				title("BR Southeast: HH Income per Capita Distribution, $year", margin(vsmall) position(11)) ///
				subtitle("(Percentiles of state-wide and nation-wide distributions, PPP adjusted)", margin(vsmall) position(11)) ///
				legend( lab(1 "MG") lab(2 "ES") lab(3 "RJ")  lab(4 "SP") lab(5 "45 degree")) ///
				lwidth(thin) scheme(s2color) name(southeast, replace)
				graph export $imagefolder\\${year}_southeast.pdf, as(pdf) replace		
					
			// S
				 
			twoway scatter pctile pctilestate if UF == 41, msize(small)  || ///
				scatter pctile pctilestate if UF == 42, msize(small)  || ///
				scatter pctile pctilestate if UF == 43, msize(small)  || ///
				scatter pctile pctile if UF == 53, msymbol(none) connect(l) ///
				ytitle("Percentile of national income distribution") ///
				xtitle("Percentile of state income distribution") ///
				title("BR South: HH Income per Capita Distribution, $year", margin(vsmall) position(11)) ///
				subtitle("(Percentiles of state-wide and nation-wide distributions, PPP adjusted)", margin(vsmall) position(11)) ///
				legend( lab(1 "PR") lab(2 "SC") lab(3 "RS") lab(4 "45 degree")) ///
				lwidth(thin) scheme(s2color) name(south, replace)
				graph export $imagefolder\\${year}_south.pdf, as(pdf) replace		
				
			// CO
				 
			twoway scatter pctile pctilestate if UF == 50, msize(small)  || ///
				scatter pctile pctilestate if UF == 51, msize(small)  || ///
				scatter pctile pctilestate if UF == 52, msize(small)  || ///
				scatter pctile pctilestate if UF == 53, msize(small)  || ///
				scatter pctile pctile if UF == 53, msymbol(none) connect(l) ///
				ytitle("Percentile of national income distribution") ///
				xtitle("Percentile of state income distribution") ///
				title("BR Midwest: HH Income per Capita Distribution, $year", margin(vsmall) position(11)) ///
				subtitle("(Percentiles of state-wide and nation-wide distributions, PPP adjusted)", margin(vsmall) position(11)) ///
				legend( lab(1 "MS") lab(2 "MT") lab(3 "GO")  lab(4 "DF") lab(5 "45 degree")) ///
				lwidth(thin) scheme(s2color) name(midwest, replace)
				graph export $imagefolder\\${year}_midwest.pdf, as(pdf) replace		
				
			// full
				 
			twoway scatter pctile pctilestate if UF == 50, msize(small) mcolor(red)  || ///
				scatter pctile pctilestate if UF == 51, msize(small)  mcolor(red)  || ///
				scatter pctile pctilestate if UF == 52, msize(small)  mcolor(red)  || ///
				scatter pctile pctilestate if UF == 53, msize(small)  mcolor(red)  || ///
				scatter pctile pctilestate if UF == 41, msize(small)  mcolor(blue)  || ///
				scatter pctile pctilestate if UF == 42, msize(small)  mcolor(blue)  || ///
				scatter pctile pctilestate if UF == 43, msize(small)  mcolor(blue)  || ///
				scatter pctile pctilestate if UF == 31, msize(small)  mcolor(orange)  || ///
				scatter pctile pctilestate if UF == 32, msize(small)  mcolor(orange)  || ///
				scatter pctile pctilestate if UF == 33, msize(small)  mcolor(orange)  || ///
				scatter pctile pctilestate if UF == 35, msize(small)  mcolor(orange)  || ///
				scatter pctile pctilestate if UF == 21, msize(small)  mcolor(grey)  || ///
				scatter pctile pctilestate if UF == 22, msize(small)  mcolor(grey)   || ///
				scatter pctile pctilestate if UF == 23, msize(small)  mcolor(grey)   || ///
				scatter pctile pctilestate if UF == 24, msize(small)  mcolor(grey)   || ///
				scatter pctile pctilestate if UF == 25, msize(small)  mcolor(grey)   || ///
				scatter pctile pctilestate if UF == 26, msize(small)  mcolor(grey)   || ///
				scatter pctile pctilestate if UF == 27, msize(small)  mcolor(grey)   || ///
				scatter pctile pctilestate if UF == 28, msize(small)  mcolor(grey)   || ///
				scatter pctile pctilestate if UF == 29, msize(small)  mcolor(grey)   || ///
				scatter pctile pctilestate if UF == 11, msize(small)  mcolor(green)   || ///
				scatter pctile pctilestate if UF == 12, msize(small)  mcolor(green)  || ///
				scatter pctile pctilestate if UF == 13, msize(small)  mcolor(green)  || ///
				scatter pctile pctilestate if UF == 14, msize(small)  mcolor(green)  || ///
				scatter pctile pctilestate if UF == 15, msize(small)  mcolor(green)  || ///
				scatter pctile pctilestate if UF == 16, msize(small)  mcolor(green)  || ///
				scatter pctile pctilestate if UF == 17, msize(small)  mcolor(green)  || ///
				scatter pctile pctile if UF == 53, msymbol(none) connect(l) lcolor(black) lwidth(vthick) ///
				ytitle("Percentile of national income distribution") ///
				xtitle("Percentile of state income distribution") ///
				title("Brazil: HH Income per Capita Distribution, by state, $year", margin(vsmall) position(11)) ///
				subtitle("(Percentiles of state-wide and nation-wide distributions, PPP adjusted)", margin(vsmall) position(11)) ///
				legend( off ) ///
				lwidth(thin) scheme(s2color) name(full, replace)
				graph export $imagefolder\\${year}_full.pdf, as(pdf) replace		

		restore


		///////////////////////////////////////////////////////////////////////////////
		//////////////////////////// 6. COLLAPSE CONSUMPTION PATTERNS ///////////////////////////
		///////////////////////////////////////////////////////////////////////////////

		preserve

			// Fixed telephone

				gen fixedphone = .
				replace fixedphone = 1 if V2020 == 2
				replace fixedphone = 0 if V2020 == 4

			// Mobile telephone

				gen mobilephone = .
				replace mobilephone = 1 if V0220 == 2
				replace mobilephone = 0 if V0220 == 4


			// Color TV

				gen tv = .
				replace tv = 1 if V0226 == 2
				replace tv = 0 if V0226 == 4

				
			// Fridges

				gen fridge = .
				replace fridge = 1 if V0228 == 2 | V0228 == 4 
				replace fridge = 0 if V0228 == 6
				
			// Freezer

				gen freezer = .
				replace freezer = 1 if V0229 == 1
				replace freezer = 0 if V0229 == 3

			// Washing Machine

				gen washingmachine = .
				replace washingmachine = 1 if V0230 == 2
				replace washingmachine = 0 if V0230 == 4


			// Computer

				gen computer = .
				replace computer = 1 if V0231 == 1
				replace computer = 0 if V0231 == 3


			// Electricity

				gen electricity = .
				replace electricity = 1 if V0219 == 1
				replace electricity = 0 if V0219 == 3 | V0219 == 5 


			// Stove

				gen stove = .
				replace stove = 1 if V0222 == 1 | V0221 == 1 
				replace stove = 0 if  V0222 == 4 | V0221 == 3
				
					collapse (mean) fixedphone mobilephone tv fridge freezer washingmachine computer electricity stove, by(pctile)
					export excel using $resultsfolder\consumption.xlsx, firstrow(variables) sheet("$year") sheetmodify

		restore


		///////////////////////////////////////////////////////////////////////////////
		///////////////// 7. CALCULATE AND DECOMPOSE INCOME INEQUALITY ////////////////
		///////////////////////////////////////////////////////////////////////////////

		// Export csvs for density functions

		preserve
			bysort pctile region: gen N = _n
			collapse (max) N, by(pctile region)
			export excel using $resultsfolder\incomedensity.xlsx, firstrow(variables) sheet("$year") sheetmodify
		restore

		// Calculate inequality indices

			qui ineqdeco income [aweight=$weight] , by(UF)
			putexcel A1=rscalarnames using  $resultsfolder\giniresults.xlsx, modify sheet("$year")
			putexcel B1=rscalars using $resultsfolder\giniresults.xlsx, modify sheet("$year")
						
	}
}
