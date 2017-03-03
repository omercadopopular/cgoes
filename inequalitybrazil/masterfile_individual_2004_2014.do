///////////////////////////////////////////////////////////////////////////////
/////////////////////////////////// CODED BY //////////////////////////////////
///////////////////////////////// CARLOS GOES /////////////////////////////////
///////////////////////////// andregoes@gmail.com /////////////////////////////
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
////////////////////////////////// READ ME ////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

/*

Purpose: Imports individual PNAD data, creates dummies for important characteristics
(race, gender, state, etc.), runs mincerian regressions predicting income, calculates
wage premium for public sector.

Attention: To make sure that the file runs through all PNADS, the variable
	names have to be the same for all of them (if there was a change in name,
	you can standardize via dictionaries). You have to store the different
	survey waves in /year folders. 
	
Timing: If you don't need to import raw data from the TXT files, running this
	code for 14 vintages of the survey takes about 30 minutes. If you import raw
	data, it takes about 120 minutes.
 
 */
 
///////////////////////////////////////////////////////////////////////////////
//////////////////////////////// USER INTERFACE ///////////////////////////////
/////////// CHANGE THE VALUES IN THIS SECTION FOLLOWING INSTRUCTIONS //////////
///////////////////////////////////////////////////////////////////////////////

	global folder = "Q:\DATA\S1\BRA\Inequality\PNAD"
	global resultsfolder = "Q:\DATA\S1\BRA\Inequality\PNAD\results"
	global imagefolder = "Q:\DATA\S1\BRA\Inequality\PNAD\images"
	global first = 2014	// First PNAD being used
	global last = 2014 	// Last PNAD being used
	global exception = 2010 // Year when there is no PNAD

///////////////////////////////////////////////////////////////////////////////
//////////////////////////// CODE (ADVANCED USERS) ////////////////////////////
///////////////////////////////////////////////////////////////////////////////

	
	forvalues tyear = $first / $last {

		global year = `tyear'
		global workingfolder = "$folder\\$year"

		if ( `tyear' == $exception ) {
			di "No PNAD this year"
		}
		
		else {
		
		 // I. Do you need to import the raw data in this run or will you use a saved dta file?
			// Set import = 1 for importing raw data
				
			scalar import = 0
		 
		 // II. Input the survey weighting variables
		 
			global psu = "V0102"
			global strat = "UF"
			global weight = "V4729"
			
		// III. Control variables for merging

			local control = "V0102"
			local serial = "V0103"
			local order = "V0104"
			local interview = "V0104"
			local state = "UF"
			
		// IV. Merge with HH surveys?

			scalar merge = 0
			
			
		// V. List variables to create

			// A. Demographics

				local gender = "V0302"
				local male = 2
				local female = 4

				local age = "V8005"

				local race = "V0404"
					local white = 2
					local black = 4
					local brown = 8
					local asian = 6
					local native = 0
				
				global races = "white black brown asian native"

			// B. Migration

				local migrant = "V0502"
				local migrantv = 4
				
			// C. Education

				if $year > 2006 {
					local schooling = "V4803" // overstates by one year, 17 = not available
				}
				else {
					local schooling = "V4703" // overstates by one year, 17 = not available
				}
			
				local highskilledthreshold = 11
				
				// University Level

				if $year > 2008 {	
					local edlevel = "V6003"
					local university = 5
					local ednetwork = "V6002"
					local edpublic = 2
					local edprivate = 4
					local edpubtype = "V6020"
					local federal = 6					
					}
				else if $year > 2006 {
					local edlevel = "V6003"
					local university = 5
					local ednetwork = "V6002"
					local edpublic = 2
					local edprivate = 4
					local edpubtype = "V6002"
					local federal = 2
				}
				else {
					local edlevel = "V0603"
					local university = 5
					local ednetwork = "V6002"
					local edpublic = 2
					local edprivate = 4
					local edpubtype = "V6002"
					local federal = 2
				}
				
			// D. Occupation


				local occupation = "V4715"				
					local formalworker = 1
					local military = 2	
					local civilservant = 3	
					local informalworker = 4
					local domesticformal = 6
					local domesticinformal = 7	
					local selfemployed = 9
					local employer = 10
					local voluntary = 11
					local servicesown = 12
					local constructionown = 13

				global occupationlist = "formalworker military civilservant informalworker domesticformal domesticinformal selfemployed employer voluntary servicesown constructionown"
					
			// E. Activity Group
			
				local activity = "V4816"
					local agriculture = 1
					local industry = 2
					local manufacturing = 3
					local construction = 4
					local commerce = 5
					local lodgingfood = 6
					local transport = 7
					local publicadm = 8
					local education = 9
					local domesticserv = 10
					local otherserv = 11
					local otheract = 12
					local unspecifiedac = 13
					
				global activitylist "agriculture industry manufacturing construction commerce lodgingfood transport publicadm education domesticserv otherserv otheract unspecifiedac"
					
			// F. Administrative Class

				local class = "V4817"
					local director = 1
					local artist = 2
					local middlemgt = 3
					local admin = 4
					local servicework = 5
					local sales = 6
					local peasants = 7
					local repair = 8
					local armedservices = 9
					local unespecifiedclass = 10
				
				global classlist = "director artist middlemgt admin servicework sales peasants repair armedservices unespecifiedclass"
				
			// G. Income
			
				local income = "V4742" // Income per capita
				local wage = "V4718" // Income per capita

			// H. Labor Force
			
				local laborforce = "V4704" 
				local laborforceactive = 1
				
				
				if $year > 2006 {
					local employmentrate = "V4805" 
					local employed = 1
					local unemployed = 2
					}
				else {
					local employmentrate = "V4705" 
					local employed = 1
					local unemployed = 2
					}
				
			// I. Experience - how to calculate labor market experience?
			
				local experience = "age - schooling - 6" 
				
				local retired = "V9122"
					local retiree = 2
					local nonretiree = 4
					local retiredincome = "V1252"
				
				local pension = "V9123"
					local pensioneer = 1
					local nonpensioneer = 3
					local pensionincome = "V1255"
				
 
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
			log using pes$year.log, replace  					// chooses logfile

			///////////////////////////////////////////////////////////////////////////////
			//////////////////////////// 2. DATASET PREPARATION ///////////////////////////
			///////////////////////////////////////////////////////////////////////////////

			// Import data

				if (import == 1) {
					clear
					infile using PES$year.dct
					export delimited using PES$year, replace
					save pes$year, replace
				}


				if (merge == 1) {
					use p$year, clear
					keep `control' `serial' `interview' `state'
					
					tempfile merging
					save `merging'
					
					use pes$year, clear
					merge m:m `control' using `merging'
				}
				else {
					use pes$year, clear	
				}
					egen strata = group($strat)
					local strat = "strat"
					svyset $psu [weight=$weight], strat($strat)
				
			// Label regions
				
				local counter1 = 0
				foreach x in region_N region_NE region_SE region_S region_CO {	
					local counter1 = `counter1' + 10
					local counter2 = `counter1' + 10
					gen `x' = 0 if UF != .
					replace `x' = 1 if UF >= `counter1' & UF < `counter2'
				}
							
			// Generate variables

					quietly {
					
					// A. Demographics
						
						// Gender
					
						generate male = .
						replace male = 1 if `gender' == `male'
						replace male = 0 if `gender' == `female'
								
						// Age
						
						generate age = `age'
						
						// Race
						
						foreach x of global races {
							generate `x' = .
							replace `x' = 1 if `race' == ``x''
							replace `x' = 0 if `race' != ``x'' & `race' != .
						}


					// B. Migration
					
						generate migrant = .
						replace migrant = 1 if `migrant' == 4
						replace migrant = 0 if `migrant' != 4 &  `migrant' != .
						
					// C. Education
					
						generate schooling = `schooling' - 1
						replace schooling = . if `schooling' == 17
						
						generate highskilled = .
						replace  highskilled = 1 if schooling >= `highskilledthreshold' 
						replace  highskilled = 0 if schooling < `highskilledthreshold' 
						
						generate universitypublic = 0
						replace  universitypublic = 1 if `edlevel' == `university' & `ednetwork' == `edpublic' & `edpubtype' == `federal' 
						generate universityprivate = 0
						replace  universityprivate = 1 if `edlevel' == `university' & `ednetwork' == `edprivate' 
						
					
					// D. Occupation
					
						foreach x of global occupationlist {
							generate `x' = .
							replace `x' = 1 if `occupation' == ``x''
							replace `x' = 0 if `occupation' != ``x'' & `occupation' != .
						}

						generate publicsector = military + civilservant

					// E. Occupation
					
						foreach x of global activitylist {
							generate `x' = .
							replace `x' = 1 if `activity' == ``x''
							replace `x' = 0 if `activity' != ``x'' & `activity' != .
						}

					// F. Class
					
						foreach x of global classlist {
							generate `x' = .
							replace `x' = 1 if `class' == ``x''
							replace `x' = 0 if `class' != ``x'' & `class' != .
						}
						
					// G. Formal Sector

						generate formalsector = .
						replace formalsector = 1 if formalworker == 1 | publicsector == 1 | employer == 1 | domesticformal == 1 | selfemployed == 1 & director == 1 | selfemployed == 1  & artist == 1 | voluntary == 1
						replace formalsector = 0 if informalworker == 1 | domesticinformal == 1 | selfemployed == 1 & director != 1 & artist != 1  | servicesown == 1  | constructionown == 1

					// H. Economic Activity
					
						generate income = `income'
						replace income = . if income > 1.00e+11

						generate wage = `wage'
						replace wage = . if wage > 1.00e+11
						
						generate laborforce = .
						replace laborforce = 1 if `laborforce' == `laborforceactive' 
						replace laborforce = 0 if `laborforce' != `laborforceactive' & `laborforce' != .

						generate employmentrate = .
						replace employmentrate = 1 if `employmentrate' == `employed' & laborforce == 1
						replace employmentrate = 0 if `employmentrate' == `unemployed' & laborforce == 1
						
						generate retiree = . 
						replace retiree = 1 if `retired' == `retiree'
						replace retiree = 0 if `retired' == `nonretiree'
						
						generate retiredincome = `retiredincome' 
						replace retiredincome = . if retiredincome > 1.00e+11

						generate pensioneer = . 
						replace pensioneer = 1 if `pension' == `pensioneer'
						replace pensioneer = 0 if `pension' == `nonpensioneer'
						
						generate pensionincome = `pensionincome'
						replace pensionincome = . if pensionincome > 1.00e+11

				}
					
			///////////////////////////////////////////////////////////////////////////////
			////////////////////////// 3. CALCULATE TIME SERIES ///////////////////////////
			///////////////////////////////////////////////////////////////////////////////

				// General Variables
				
				local general = "income wage civilservant migrant white formalworker highskilled universityprivate universitypublic retiree pensioneer employmentrate retiredincome pensionincome"  
				
				foreach x of local general {
					qui svy: mean `x', over(UF)
					qui matrix `x' = e(b)
					qui matrix colnames `x' = `x'
				}
				
				// Education

				qui svy: mean schooling if age > 16, over(UF) 
				qui matrix schooling = e(b)
				qui matrix colnames schooling = schooling
							
				local students = "universityprivate universitypublic"  
				
				foreach x of local students {
					qui svy: mean `x' if age > 16 & age < 31, over(UF)
					qui matrix `x' = e(b)
					qui matrix colnames `x' = `x'
				}
				
				// Civil Servant
				
				local ps = "income schooling highskilled" 

				foreach x of local ps {
					qui svy: mean `x' if civilservant == 1, over(UF)
					qui matrix `x'_cs = e(b)
					qui matrix colnames `x'_cs = `x'_cs
				}
				
				// Income and Education by Quartile
				
				sum income [aweight=$weight], detail

				forval x = 25(25)75 {
						local p`x' = r(p`x')
						}
						
				gen q1 = 1 if income < `p25'
				replace q1 = 0 if income >= `p25'
				gen q2 = 1 if income >= `p25' & income < `p50'
				replace q2 = 0 if income < `p25' | income >= `p50'
				gen q3 = 1 if income >= `p50' & income < `p75'
				replace q3 = 0 if income < `p50' | income >= `p75'
				gen q4 = 1 if income >= `p75'
				replace q4 = 0 if income < `p75'	
				
				local quartilelist = "income schooling"

				foreach z of local quartilelist {
					forval x = 1/4 {
						qui svy: mean `z' if q`x' == 1, over(UF)
						qui matrix `z'_q`x' = e(b)
						}
					}
				
				drop q1-q4
					
				// Aggregate and export resulting matrix, with respective weights
				
					preserve
						matrix A = [income', income_q1', income_q2', income_q3', income_q4', wage', civilservant', migrant', white', formalworker', schooling', schooling_q1', schooling_q2', schooling_q3', schooling_q4', highskilled', universityprivate', universitypublic', retiree', pensioneer', employmentrate', income_cs', schooling_cs', highskilled_cs', retiredincome', pensionincome']
						matrix colnames A = income income_q1 income_q2 income_q3 income_q4 wage civilservant migrant white formalworker schooling schooling_q1 schooling_q2 schooling_q3 schooling_q4 highskilled universityprivate universitypublic retiree pensioneer employmentrate income_cs schooling_cs highskilled_cs retiredincome pensionincome
						matrix rownames A = RO	AC	AM	RR	PA	AP	TO	MA	PI	CE	RN	PB	PE	AL	SE	BA	MG	ES	RJ	SP	PR	SC	RS	MS	MT	GO	DF
						collapse (sum) $weight, by(UF)
						mkmat $weight, matrix(labor)
						matrix colname labor = population
						matrix A = [A, labor]
						putexcel A1=matrix(A, names) using $resultsfolder\variables.xlsx, modify sheet("$year")
					restore
							
			///////////////////////////////////////////////////////////////////////////////
			///////////////////////// 4. RUN MINCERIAN REGRESSIONS ////////////////////////
			///////////////////////////////////////////////////////////////////////////////

				gen lwage = ln(wage)
				gen schoolingsq = schooling^2
				gen exp = `experience'
				gen expsq = exp^2
				
				// Overall
				
				svy: reg lwage ///
					schooling ///
					exp expsq ///
					male ///
					$races $occupationlist $activitylist $classlist ///
					i.UF
					outreg2 schooling exp expsq male $races $occupationlist $activitylist $classlist  /// 
						using $resultsfolder\mincerian_${year}.xls, cttop(Overall)  ///
						lab dec(3) replace				
						
				// Private Sector
				
				svy: reg lwage ///
					schooling schoolingsq ///
					exp expsq ///
					male ///
					$races $occupationlist $activitylist $classlist ///
					i.UF if publicsector == 0
					outreg2 schooling exp expsq male $races $occupationlist $activitylist $classlist  /// 
						using $resultsfolder\mincerian_${year}.xls, cttop(Private) ///
						lab dec(3) 				
					
				predict lwagehat_private
				
				// Public Sector
				
				svy: reg lwage ///
					schooling ///
					exp expsq ///
					male ///
					$races $occupationlist $activitylist $classlist ///
					i.UF if civilservant == 1
					outreg2 schooling exp expsq male $races $occupationlist $activitylist $classlist  /// 
						using $resultsfolder\mincerian_${year}.xls, cttop(Public) ///
						lab dec(3) 				
					
				predict lwagehat_public
				
				// Difference Public - Private
				
				gen wagepremium = (lwagehat_public - lwagehat_private) * 100
				
				// Plot charts
				
				graph box lwagehat_private lwagehat_public, over(schooling) noout ///
					ytitle("Log of predicted wage given 50+ controls") ///
					title("Brazil: Predicted Returns on Schooling", margin(vsmall) position(11)) ///
					subtitle("Per years of education", margin(vsmall) position(11)) ///
					legend( lab(1 "Private Sector") lab(2 "Public Sector") ) ///
					caption("Source: Staff estimates with PNAD microdata.", size(small)) ///
					scheme(s2color) name(schoolingbox, replace)  
					graph export $imagefolder\\${year}_schoolingbox.pdf, as(pdf) replace
				
				
				twoway lfit lwagehat_private schooling || ///
					 lfit lwagehat_public schooling,  ///
					ytitle("Log of predicted wage given 50+ controls") ///
					xtitle("Years of schooling") ///
					title("Brazil: Predicted Returns on Schooling", margin(vsmall) position(11)) ///
					subtitle("Public and Private Sectors", margin(vsmall) position(11)) ///
					legend( lab(1 "Private Sector") lab(2 "Public Sector") ) ///
					lwidth(thin) scheme(s2color) name(schoolinglines, replace)  
					graph export $imagefolder\\${year}_schoolinglines.pdf, as(pdf) replace
				
				graph box wagepremium, over(schooling) noout ///
					ytitle("Pct difference in predicted wage given 50+ controls") ///
					yline(0, lcolor(black)) ///
					title("Brazil: Wage Premium of Public Sector", margin(vsmall) position(11)) ///
					subtitle("Per years of education", margin(vsmall) position(11)) ///
					caption("Source: Staff estimates with PNAD microdata.", size(small)) ///
					scheme(s2color) name(wagepremium, replace) 
					graph export $imagefolder\\${year}_wagepremium.pdf, as(pdf) replace
					
				graph close _all

				/// Calculate percentiles
				
					local listwages = "lwagehat_private lwagehat_public wagepremium"
					
					foreach x of local listwages {
						forval y = 0/15 {
							local line = `y' + 2
							qui sum `x' if schooling == `y' [aweight=$weight], detail
							qui putexcel A1=("Schooling") A`line'=(`y') using $resultsfolder\\`x'.xlsx, modify sheet("$year")		
							qui putexcel B1=("P10") B`line'=(r(p10)) using $resultsfolder\\`x'.xlsx, modify sheet("$year")
							qui putexcel C1=("P25") C`line'=(r(p25)) using $resultsfolder\\`x'.xlsx, modify sheet("$year")
							qui putexcel D1=("P50") D`line'=(r(p50)) using $resultsfolder\\`x'.xlsx, modify sheet("$year")
							qui putexcel E1=("P75") E`line'=(r(p75)) using $resultsfolder\\`x'.xlsx, modify sheet("$year")
							qui putexcel F1=("P90") F`line'=(r(p90)) using $resultsfolder\\`x'.xlsx, modify sheet("$year")
							}
						}
					
			///////////////////////////////////////////////////////////////////////////////
			///////////////////////// 5. CALCULATE EDUCATION THRESHOLDS //////////////////
			///////////////////////////////////////////////////////////////////////////////

			sum income [aweight=$weight] if age > 16 & age < 31, detail
				forval x = 25(25)75 {
					local p`x' = r(p`x')
					}
			
			gen q1 = 1 if income < `p25'
			replace q1 = 0 if income >= `p25'
			gen q2 = 1 if income >= `p25' & income < `p50'
			replace q2 = 0 if income < `p25' | income >= `p50'
			gen q3 = 1 if income >= `p50' & income < `p75'
			replace q3 = 0 if income < `p50' | income >= `p75'
			gen q4 = 1 if income >= `p75'
			replace q4 = 0 if income < `p75'
			
			foreach x in universitypublic universityprivate highskilled  {
				forval y = 1/4 {
				qui svy: mean q`y' if `x' == 1
				qui matrix `x'`y' = e(b)			
				}
				matrix `x' = [`x'1', `x'2', `x'3', `x'4']
			}
			
			drop q1-q4
							
			matrix compare = [universitypublic', universityprivate',  highskilled']
			matrix colnames compare = universitypublic universityprivate highskilled
			putexcel A1=matrix(compare, names) using $resultsfolder\university.xlsx, modify sheet("$year")

			qui ineqdeco schooling [aweight=$weight] , by(UF)
			putexcel A1=rscalarnames using  $resultsfolder\educationgini.xlsx, modify sheet("$year")
			putexcel B1=rscalars using $resultsfolder\educationgini.xlsx, modify sheet("$year")
			
			///////////////////////////////////////////////////////////////////////////////
			///////////////////////// 6. LOGIT FOR UNIVERSITY //////////////////
			///////////////////////////////////////////////////////////////////////////////		
	

				
				gen lincome = ln(income)
	
				preserve
				
					// Run Univariate Model

							logit universitypublic lincome if age > 16 & age < 25 & universityprivate != 1
					
					// Fit Values
					
							predict univ_hat
							replace univ_hat = univ_hat * 100
							
					// Calculate Marginal Values
					
							margins, dydx(*) at( (median) lincome) post
								outreg2 lincome  /// 
									using $resultsfolder\univlogitreg_${year}.xls, cttop(Correlacao) ///
									lab dec(3) replace

							logit universitypublic lincome if age > 16 & age < 25 & universityprivate != 1
							margins, dydx(*) at(lincome=(3.5(0.5)9)) post
							marginsplot
					
					// Adjust Scale for Chart

					drop if income > 20000
					drop if income < 100
							
					line univ_hat income, sort  ///
						title("Probability", position(11) margin(vsmall)) ///
						subtitle("of Being in University",  position(11) margin(vsmall)) ///
						scheme(economist) name(test_hat, replace)
						
					keep income univ_hat 
											
					export delimited using "$resultsfolder\univlogitfitchart1_${year}.csv", replace
						
				restore			

							
				// Multivariabe Logit
				
						// Run Model 

						
							logit universitypublic lincome age male black brown asian native region_N region_NE region_S region_CO if age > 16 & age < 25 & universityprivate != 1


								predict univ_hat2 if age > 16 & age < 25 
								replace univ_hat2 = univ_hat2 * 100
								
							preserve
								keep income univ_hat2 
								drop if missing(univ_hat2)
								export delimited using "$resultsfolder\univlogitfitchart2_${year}.csv", replace
								
							restore

						// Calculate Marginal Values
							
							margins, dydx(*) at(male=0 black=0 brown=0 asian=0 region_N = 0 region_NE = 0 region_S = 0 region_CO = 0 (median) lincome age ) post
							outreg2 lincome age male black brown asian native region_N region_NE region_S region_CO /// 
									using $resultsfolder\univlogitreg_${year}.xls, cttop(Completo) ///
									lab dec(3)  		

				
		}
}


