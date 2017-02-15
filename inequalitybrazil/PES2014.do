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

Methods: 

 
 */
 
///////////////////////////////////////////////////////////////////////////////
//////////////////////////////// USER INTERFACE ///////////////////////////////
/////////// CHANGE THE VALUES IN THIS SECTION FOLLOWING INSTRUCTIONS //////////
///////////////////////////////////////////////////////////////////////////////

	local year = 2014
 

 // I. Do you need to import the raw data in this run or will you use a saved dta file?
	// Set import = 1 for importing raw data
		
	scalar import = 0
 
 // II. Input the survey weighting variables
 
	local psu = "V0102"
	local strat = "UF"
	local weight = "V4729"
	
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
		
		local races = "white black brown asian native"

	// B. Migration

		local migrant = "V0502"
		local migrantv = 4
		
	// C. Education

		local schooling = "V4803"	// overstates by one year
		
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

		local occupationlist = "formalworker military civilservant informalworker domesticformal domesticinformal selfemployed employer voluntary servicesown constructionown"
			
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
			
		local activitylist "agriculture industry manufacturing construction commerce lodgingfood transport publicadm education domesticserv otherserv otheract unspecifiedac"
			
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
		
		local classlist = "director artist middlemgt admin servicework sales peasants repair armedservices unespecifiedclass"
		
	// G. Income
	
		local income = "V4742" // Income per capita
		local wage = "V4718" // Income per capita

	// H. Labor Force
	
		local laborforce = "V4704" 
		local laborforceactive = 1
		
///////////////////////////////////////////////////////////////////////////////
//////////////////////////// CODE (ADVANCED USERS) ////////////////////////////
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
////////////////////////// 1. WORKSPACE ORGANIZATION //////////////////////////
///////////////////////////////////////////////////////////////////////////////
 
capture log close 										// closes any open logs
clear 													// clears the memory
clear matrix 											// clears matrix memory
clear mata 												// clears mata memory
cd "Q:\DATA\S1\BRA\Inequality\PNAD\2014" 				// sets working directory
set more off  											// most important command in STATA :)/
set maxvar 32000
set matsize 11000
*set max_memory 5g
log using pes`year'.log, replace  					// chooses logfile

///////////////////////////////////////////////////////////////////////////////
//////////////////////////// 2. DATASET PREPARATION ///////////////////////////
///////////////////////////////////////////////////////////////////////////////

// Import data

	if (import == 1) {
		clear
		infile using PES`year'.dct
		export delimited using PES"`year'", replace
		save pes`year', replace
	}


// Create group id by state

	if (merge == 1) {
		use p`year', clear
		keep `control' `serial' `interview' `state'
		
		tempfile merging
		save `merging'
		
		use pes`year', clear
		merge m:m `control' using `merging'
	}
	else {
		use pes`year', clear	
	}
		egen strata = group(`strat')
		local strat = "strat"
		svyset `psu' [weight=`weight'], strat(`strat')
	
// Label regions

	gen region = ""
	replace region = "N" if UF >= 10 & UF < 20 
	replace region = "NE" if UF >= 20 & UF < 30
	replace region = "SE" if UF >= 30 & UF < 40
	replace region = "S" if UF >= 40 & UF < 50
	replace region = "CO" if UF >= 50 & UF < 60
		
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
			
			foreach x of local races {
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

		// D. Occupation
		
			foreach x of local occupationlist {
				generate `x' = .
				replace `x' = 1 if `occupation' == ``x''
				replace `x' = 0 if `occupation' != ``x'' & `occupation' != .
			}

			generate publicsector = military + civilservant

		// E. Occupation
		
			foreach x of local activitylist {
				generate `x' = .
				replace `x' = 1 if `activity' == ``x''
				replace `x' = 0 if `activity' != ``x'' & `activity' != .
			}

		// F. Class
		
			foreach x of local classlist {
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
	}
		
///////////////////////////////////////////////////////////////////////////////
////////////////////////// 3. CALCULATE TIME SERIES ///////////////////////////
///////////////////////////////////////////////////////////////////////////////

	local general = "income civilservant migrant white formalworker schooling" 
	
	foreach x of local general {
		qui svy: mean `x', over(UF)
		qui matrix `x' = e(b)
		qui matrix colnames `x' = `x'
	}
	
	local ps = "income schooling" 

	foreach x of local ps {
		qui svy: mean `x' if civilservant == 1, over(UF)
		qui matrix `x'_cs = e(b)
		qui matrix colnames `x'_cs = `x'_cs
	}			
		
	// Aggregate and export resulting matrix, with respective weights
	
		preserve
			matrix A = [income', civilservant', migrant', formalworker', schooling', income_cs', schooling_cs']
			matrix colnames A = income civilservant migrant formalworker schooling income_cs schooling_cs
			matrix rownames A = RO	AC	AP	RR	PA	AM	TO	MA	PI	CE	RN	PB	PE	AL	SE	BA	MG	ES	RJ	SP	PR	SC	RS	MS	MT	GO	DF
			matrix list A
		
			keep if laborforce == 1
			collapse (sum) `weight', by(UF)
			mkmat `weight', matrix(labor)
			matrix colname labor = laborforce

			matrix A = [A, labor]
			putexcel A1=matrix(A, names) using ../variables.xlsx, modify sheet("`year'")
		restore
				
///////////////////////////////////////////////////////////////////////////////
///////////////////////// 4. RUN MINCERIAN REGRESSIONS ////////////////////////
///////////////////////////////////////////////////////////////////////////////

	gen lwage = ln(wage)
	gen schoolingsq = schooling^2
	gen agesq = age^2
	
	// Overall
	
	svy: reg lwage ///
		schooling ///
		age agesq ///
		male ///
		`races' `occupationlist' `activitylist' `classlist' ///
		i.UF
	
	// Private Sector
	
	svy: reg lwage ///
		schooling schoolingsq ///
		age agesq ///
		male ///
		`races' `occupationlist' `activitylist' `classlist' ///
		i.UF if publicsector == 0
		
	predict lwagehat_private
	
	// Public Sector
	
	svy: reg lwage ///
		schooling ///
		age agesq ///
		male ///
		`races' `occupationlist' `activitylist' `classlist' ///
		i.UF if civilservant == 1
		
	predict lwagehat_public
	
	// Difference Public - Private
	
	gen wagepremium = (lwagehat_public - lwagehat_private) * 100
	

	
	graph box lwagehat_private lwagehat_public, over(schooling) noout ///
		ytitle("Log of predicted wage given 50+ controls") ///
		title("Brazil: Predicted Returns on Schooling", margin(vsmall) position(11)) ///
		subtitle("Per years of education", margin(vsmall) position(11)) ///
		legend( lab(1 "Private Sector") lab(2 "Public Sector") ) ///
		caption("Source: Staff estimates with PNAD microdata.", size(small)) ///
		scheme(s2color) name(schoolingbox, replace)
		graph export schoolingbox.pdf, as(pdf) replace
	
	
	twoway lfit lwagehat_private schooling || ///
		 lfit lwagehat_public schooling,  ///
		ytitle("Log of predicted wage given 50+ controls") ///
		xtitle("Years of schooling") ///
		title("Brazil: Predicted Returns on Schooling", margin(vsmall) position(11)) ///
		subtitle("Public and Private Sectors", margin(vsmall) position(11)) ///
		legend( lab(1 "Private Sector") lab(2 "Public Sector") ) ///
		lwidth(thin) scheme(s2color) name(schoolinglines, replace)
		graph export schoolinglines.pdf, as(pdf) replace
	
	graph box wagepremium, over(schooling) noout ///
		ytitle("Pct difference in predicted wage given 50+ controls") ///
		yline(0, lcolor(black)) ///
		title("Brazil: Wage Premium of Public Sector", margin(vsmall) position(11)) ///
		subtitle("Per years of education", margin(vsmall) position(11)) ///
		caption("Source: Staff estimates with PNAD microdata.", size(small)) ///
		scheme(s2color) name(wagepremium, replace)
		graph export wagepremium.pdf, as(pdf) replace


