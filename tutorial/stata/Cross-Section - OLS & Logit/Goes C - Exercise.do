///////////////////////////////////////////////////////////////////////////////
/////////////////////////////////// CODED BY //////////////////////////////////
///////////////////////////////// CARLOS GOES /////////////////////////////////
///////////////////////////// andregoes@gmail.com /////////////////////////////
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
////////////////////////////////// READ ME ////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

/*

Purpose: Understand drivers of graduation rates and ACT scores in Schooland

Methods: Linear Regression and Logistic Regression 

	Make sure you have the outreg2 command installed. If you dont:
     -> net search outreg2
 
 */
 
///////////////////////////////////////////////////////////////////////////////
//////////////////////////////// USER INTERFACE ///////////////////////////////
/////////// CHANGE THE VALUES IN THIS SECTION FOLLOWING INSTRUCTIONS //////////
///////////////////////////////////////////////////////////////////////////////
 
// I. Insert GPA equivalence for letter grades. If necessary add another line.
	
	local gradelist = "A B C D F"
	local A_GPA = 4
	local B_GPA = 3
	local C_GPA = 2
	local D_GPA = 1
	local F_GPA = 0

// II. Specify how you want to label the different variables (this will be
		//	important for the charts the code will automatically generate)
		
	local l_studentid "Student ID #"
	local l_gpa "Student's Grade Point Average"
	local l_testscore "Student's ACT score"
	local l_athletics "Participation in Athletics Program"
	local l_ap "Participation in Advanced Program"
	local l_age "Age"
	local l_householdincome "Household income, $000"
	local l_gradelevel "Grade Level"
	local l_performanceindex "Performance Index"
	local l_specialed "Participation in Special Education Program"
	local l_female "Female Students"
	local l_male "Male Students"
	local l_black "African American Students"
	local l_asian "Asian Students"
	local l_otherrace  "Other Minority Students"
	local l_white "White Students"
	local l_attempts "Numer of Times Student's Taken ACT"
	
	local labels "studentid gpa athletics ap age householdincome gradelevel performanceindex specialed female black asian otherrace white testscore attempts male"
	
// III. Determine types of analysis you want to perform. If yes, local should be equal to 1
		
	// Summarize descriptive statistics? Yes = 1, No = 0	
		local descriptive = 1

		// Perform logistic regression on graduation rate? Yes = 1, No = 0	
		local logit = 1
		
	// Perform linear regression on SAT scores? Yes = 1, No = 0	
		local linear = 1
 
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
cd "U:\Hanover" 										// sets working directory
set more off  											// most important command in STATA :)/
set maxvar 32000
set matsize 11000
*set max_memory 5g
log using Goes_Hanover.log, replace  					// chooses logfile

///////////////////////////////////////////////////////////////////////////////
//////////////////////////// 2. DATASET PREPARATION ///////////////////////////
///////////////////////////////////////////////////////////////////////////////

// 2.1 Import demographics data (unique identifier = studentid)
	
	import delimited "demographics.csv", varnames(1)
	
	// 2.1.2 Create dummy for Females and Males
				
		gen female = 1 if gender == "F"
		replace female = 0 if missing(female)
		gen male = 1 if gender == "M"
		replace male = 0 if missing(male)

	// 2.1.3 Create dummy for Special Education
				
		rename specialed t_specialed 
		gen specialed = 1 if t_specialed == "Y"
		replace specialed  = 0 if missing(specialed)
		drop t_*
				
	// 2.1.4 Create dummies for Ethnicities
				
		gen black = 1 if ethnicity == "African American"
		replace black  = 0 if missing(black)
		replace ethnicity = "AA" if ethnicity == "African American"
		gen asian = 1 if ethnicity == "Asian"
		replace asian = 0 if missing(asian)
		gen otherrace = 1 if ethnicity == "Other"
		replace otherrace = 0 if missing(otherrace)
		gen white = 1 if ethnicity == "White"
		replace white = 0 if missing(white)
				
	// 2.1.5 Adjust household income
			
		replace householdincome = householdincome / 1000	
		xtile income_q = householdincome, nq(4)
			
	// 2.1.6 Save file
	
		tempfile merge1
		save "`merge1'"

// 2.2 Import ACT (unique identifier = studentid)
		
	import delimited "act.csv", varnames(1) clear

	// 2.2.1 Covert dates
		gen tdate = date(testdate, "MDY")
		format tdate %td
		drop testdate
		
	// 2.2.2 Identify most recent test
	
		bysort studentid: egen testdate = max(tdate)
		format testdate %td

	// 2.2.3 Calculate attempts	
	
		tempvar n
		bysort studentid: gen `n' = [_n]	
		bysort studentid: egen attempts = max(`n')

	// 2.2.4 Keep last attempt only
	
		keep if testdate == tdate
		drop tdate

	// 2.2.5 Create dummy for Females and Males
				
		gen female = 1 if gender == "F"
		replace female = 0 if missing(female)
		gen male = 1 if gender == "M"
		replace male = 0 if missing(male)
						
	// 2.2.6 Create dummies for Ethnicities
				
		gen black = 1 if ethnicity == "African American"
		replace black  = 0 if missing(black)
		replace ethnicity = "AA" if ethnicity == "African American"
		gen asian = 1 if ethnicity == "Asian"
		replace asian = 0 if missing(asian)
		gen otherrace = 1 if ethnicity == "Other"
		replace otherrace = 0 if missing(otherrace)
		gen white = 1 if ethnicity == "White"
		replace white = 0 if missing(white)
			
	tempfile merge2
	save "`merge2'"

// 2.3 Import courses, calculate GPA and collapse to unique identifier
				
	import delimited "courses.csv", varnames(1) clear
		
	// 2.3.1 Create dummy for Athletics
				
		tempvar t_athletics
		gen `t_athletics' = 1 if course == "Athletics"
		bysort studentid: egen athletics = max(`t_athletics')
		replace athletics = 0 if missing(athletics)
		drop if course == "Athletics"
				
	// 2.3.2 Create dummy for AP
				
		tempvar t_ap
		gen `t_ap' = 1 if apclass == "Y"
		bysort studentid: egen ap = max(`t_ap')
		replace ap = 0 if missing(ap)
			
	// 2.3.3 Calculate GPA
			
		gen gpa = 0	
		foreach x in `gradelist' {
			replace gpa = ``x'_GPA' if lettergrade == "`x'"
		}
				
	// 2.3.4 Collapse student information
			
		drop course
		drop lettergrade
		collapse (mean) gpa athletics ap, by(studentid)
		
		gen apclass = "N"
		replace apclass = "Y" if ap == 1

// 2.4 Merge files
		
	merge 1:m studentid using `merge1', gen(match1)
	merge 1:m studentid using `merge2', gen(match2)
			
// 2.5 Label variables
		
	foreach z in `labels' {
		label var `z' "`l_`z''"
	}

// 2.6 Randomly correct incorrectly populated age
	// n of incorrect age info = 20

	forval k = 1/4 {
		tempvar t_age`k'
	}
		
	egen `t_age1' = mean(age) if age != 99
	egen `t_age2' = max(`t_age1')
	egen `t_age3' = sd(age) if age != 99
	egen `t_age4' = max(`t_age3')

	replace age = round( rnormal(`t_age2',`t_age4') , 1 ) if age == 99

// 2.7 Generate log transformed variables

foreach var in testscore gpa householdincome {
	gen l`var' = ln(`var')
	label var l`var' "Natural log of `l_`var''"
}

// 2.8 Generate dummy for having taken test

	gen test = 1
	replace test = 0 if missing(testscore)
	label var test "Students who have taken the ACT"
	
	
///////////////////////////////////////////////////////////////////////////////
////////////////////////// 3.  DESCRIPTIVE STATISTICS /////////////////////////
///////////////////////////////////////////////////////////////////////////////

if (`descriptive' == 1) {
// 3.1 Summarize all variables

	sum `labels'

// 3.2 Scatterplots

	// 3.2.1 ACT Scores vs. GPA

	twoway lfit testscore gpa || scatter testscore gpa, ///
		title("GPA", position(11) margin(vsmall)) ///
		ytitle("") ///
		msymbol(oh) mcolor(orange) mlwidth(thin) legend(off) ///
		scheme(economist) name(scatter1, replace) nodraw
		
	// 3.2.2 ACT Scores vs. HH income

	twoway lfit testscore householdincome || scatter testscore householdincome, ///
		title("Household Income", position(11) margin(vsmall)) ///
		ytitle("`l_testscore'") ///
		msymbol(oh) mcolor(orange) mlwidth(thin) legend(off) ///
		scheme(economist) name(scatter2, replace) nodraw

	graph combine scatter1 scatter2, scheme(economist) cols(3) ///
		title("ACT Scores", position(11) margin(vsmall)) ///
		subtitle("is correlated to GPA but uncorrelated to household income",  position(11) margin(vsmall) size(small)) ///
		caption("Source: Hanover Research")  ///
		name(scatters1, replace)
		
	graph export scatters1.pdf, as(pdf) replace
	graph export scatters1.wmf, as(wmf) replace
		
// 3.3 Bar Charts

	graph bar testscore, over(apclass) ///
		title("AP Class Enrollment", position(11) margin(vsmall)) ///
		ytitle("") ///
		scheme(economist) name(bar1, replace) nodraw
		
	graph bar testscore, over(ethnicity) ///
		title("Race", position(11) margin(vsmall)) ///
		ytitle("`l_testscore'") ///
		scheme(economist) name(bar2, replace)  nodraw 

	graph bar testscore, over(gender) ///
		title("Gender", position(11) margin(vsmall)) ///
		ytitle("") ///
		scheme(economist) name(bar3, replace) nodraw

	graph bar testscore, over(income_q) ///
		title("Income Quartile", position(11) margin(vsmall)) ///
		ytitle("`l_testscore'") ///
		scheme(economist) name(bar4, replace)  nodraw
		
	graph combine bar1 bar2 bar3 bar4, scheme(economist) ///
		title("ACT Scores", position(11) margin(vsmall)) ///
		subtitle("for different demographics",  position(11) margin(vsmall)) ///
		caption("Source: Hanover Research")  ///
		name(bars1, replace)

	graph export bars1.pdf, as(pdf) replace
	graph export bars1.wmf, as(wmf) replace

// 3.4 Pie Chart

	graph pie, over(graduated) ///
		title("Graduation rate in Schooland", position(11) margin(vsmall)) ///
		subtitle("in percent of total student body",  position(11) margin(vsmall)) ///
		plabel(_all percent) ///
		plabel(1 "Did not", gap(9)) ///
		plabel(1 "graduate", gap(5)) ///
		plabel(2 "Graduated", gap(5)) ///
		pie(2, explode) legend(off) ///
		caption("Source: Hanover Research")  ///
		scheme(economist) name(pie1, replace)   

	graph export pie1.pdf, as(pdf) replace
	graph export pie1.wmf, as(wmf) replace
	
// 3.5 Perform a couple t-tests to see if Test Scores are statistically different
	// according to demographics. Information to be added to the written report.

	foreach var in gender white specialed athletics ap {
		di "`var'"
		ttest testscore, by(`var')
	}

}

///////////////////////////////////////////////////////////////////////////////
////////////////////////////////// 4.  MODELS /////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

// 4.1 Models to predict ACT scores, using log-transformation

if (`linear' == 1) {

	// 4.1.1 Model 1 - Linear model to predict ACT scores, logs

		di "Model 1"

		reg ltestscore lgpa lhouseholdincome ap graduated specialed athletics ///
			female black asian otherrace attempts, r
			
		outreg2 ltestscore lgpa lhouseholdincome ap graduated specialed athletics ///
			female black asian otherrace attempts ///
			using linearmodel.xls, replace cttop("Natural log of test score") lab dec(3)
			
		tempvar ltestscore_hat1
		tempvar e_hat1
		predict `ltestscore_hat1'
		predict `e_hat1', r

		// 4.1.1.2 Residual and f-values diagnostics
		
		
		pnorm `e_hat1', ///
			title("Normal vs Empirical", position(11) margin(vsmall)) ///
			msymbol(oh) mlwidth(thin) ///
			scheme(economist) name(e_chart1, replace) nodraw
		
		rvfplot, yline(0) ///
			title("Residuals vs Fitted", position(11) margin(vsmall)) ///
			msymbol(oh) mlwidth(thin) ///
			legend(off) ///
			scheme(economist) name(e_chart2, replace) nodraw
		
		graph combine e_chart1 e_chart2, scheme(economist) ///
			title("Residual Diagnostics, Model 1", position(11) margin(vsmall)) ///
			subtitle("ln(testscore) = \alpha + X'\beta + e",  position(11) margin(vsmall)) ///
			caption("Source: Hanover Research")  ///
			name(res1, replace)

	// 4.1.2 Model 2 - Linear model to predict ACT scores, Levels

		di "Model 2"

		reg testscore gpa householdincome ap graduated specialed athletics ///
			female black asian otherrace attempts, r
			
		outreg2 gpa householdincome ap graduated specialed athletics ///
			female black asian otherrace attempts ///
			using linearmodel.xls, cttop("Test score") lab dec(3)
			
		tempvar ltestscore_hat2
		tempvar e_hat2
		predict `ltestscore_hat2'
		predict `e_hat2', r

		// 4.1.1.2 Residual and f-values diagnostics
		
		
		pnorm `e_hat2', ///
			title("Normal vs Empirical", position(11) margin(vsmall)) ///
			msymbol(oh) mlwidth(thin) ///
			scheme(economist) name(e_chart3, replace) nodraw
		
		rvfplot, yline(0) ///
			title("Residuals vs Fitted", position(11) margin(vsmall)) ///
			msymbol(oh) mlwidth(thin) ///
			legend(off) ///
			scheme(economist) name(e_chart4, replace) nodraw
		
		graph combine e_chart3 e_chart4, scheme(economist) ///
			title("Residual Diagnostics, Model 2", position(11) margin(vsmall)) ///
			subtitle("testscore = \alpha + X'\beta + e",  position(11) margin(vsmall)) ///
			caption("Source: Hanover Research")  ///
			name(res2, replace)
			
	//4.1.3 Robustness: dropping undeclared gender
		
		preserve
		
			drop if missing(gender)
		
			reg ltestscore lgpa lhouseholdincome ap graduated specialed athletics ///
				female black asian otherrace attempts, r
				
			outreg2 ltestscore lgpa lhouseholdincome ap graduated specialed athletics ///
				female black asian otherrace attempts ///
				using linearmodel.xls, cttop("Natural log of test score") lab dec(3)

			reg testscore gpa householdincome ap graduated specialed athletics ///
				female black asian otherrace attempts, r
				
			outreg2 gpa householdincome ap graduated specialed athletics ///
				female black asian otherrace attempts ///
				using linearmodel.xls, cttop("Test score") lab dec(3)

		restore

		// 4.1.4 Model 3 - Sample selection bias? Logit on taking ACT
	
		logit test gpa
		
		tempvar test_hat
		predict `test_hat'
		
		margins, dydx(*) post
				
		line `test_hat' gpa, sort ///
			title("Probability of Taking ACT", position(11) margin(vsmall)) ///
			subtitle("and Student GPA¹",  position(11) margin(vsmall)) ///
			ytitle("Probability of Taking ACT") ylabel(.7 "70%" .75 "75%" .8 "80%" .85 "85%")  ///
			caption("1/ From univariate logistic regression P(Taking test=1) = 1 / 1 + 1/e^(.7 + .28 * GPA)", size(vsmall))  ///
			scheme(economist) name(test_hat, replace)

		graph export test_hat.pdf, as(pdf) replace
		graph export test_hat.wmf, as(wmf) replace
}

if (`logit' == 1) {
	
// 4.2 Models to predict graduation rates

	// 4.2.1 Univariate models
	
		// 4.2.1.1 Graduation and GPA
		
				logit graduate gpa
		
				tempvar graduate_hat1
				predict `graduate_hat1'
				
				margins, dydx(*) post
				
				outreg2 gpa ///
					using margins.xls, replace cttop("Marginal Effect on Probability of Graduating") ///
					lab dec(3)
						
				line `graduate_hat1' gpa, sort ///
					title("and GPA¹", position(11) margin(vsmall)) ///
					ytitle("") ylabel(.6 "60%" .65 "65%" .7 "70%" .75 "75%" ///
					.8 "80%" .85 "85%" .9 "90%" .95 "95%" 1 "100%")  ///
					caption("1/ From univariate logistic regression" /// 
					"P(Taking test=1) = 1 / 1 + 1/e^(.97 + .3 * GPA)", size(vsmall))  ///
					scheme(economist) name(graduate_hat1, replace) nodraw

			
		// 4.2.1.2 Graduation and ACT score
		
				logit graduate testscore
		
				tempvar graduate_hat2
				predict `graduate_hat2'
				
				margins, dydx(*) post

				outreg2 testscore ///
					using margins.xls, cttop("Marginal Effect on Probability of Graduating") ///
					lab dec(3)
					
				line `graduate_hat2' testscore, sort ///
					title("and ACT score²", position(11) margin(vsmall)) ///
					ytitle("Probability of Graduating") ylabel(.6 "60%" .65 "65%" .7 "70%" .75 "75%" ///
					.8 "80%" .85 "85%" .9 "90%" .95 "95%" 1 "100%")  ///
					caption("2/ From univariate logistic regression" /// 
					"P(Taking test=1) = 1 / 1 + 1/e^(-2.27 + .18 * ACT Score)", size(vsmall))  ///
					scheme(economist) name(graduate_hat2, replace)  nodraw

				graph combine graduate_hat1 graduate_hat2, cols(2) scheme(economist) ///
					title("Probability of Graduating",  position(11) margin(vsmall)) ///
					caption("Source: Hanover Research")  ///
					name(graduate_hat, replace) 
					
				graph export graduate_hat.pdf, as(pdf) replace
				graph export graduate_hat.wmf, as(wmf) replace

	// 4.2.2 Full fledged model
	
		logit graduate gpa testscore householdincome ap specialed athletics ///
			female black asian otherrace attempts, or
			
		margins, dydx(*) at(ap=0 specialed=0 athletics=0 female=0 black=0 asian=0 otherrace=0 ///
			(mean) gpa testscore householdincome attempts)  post

		outreg2 graduate gpa testscore householdincome ap specialed athletics ///
			female black asian otherrace attempts ///
			using margins.xls, cttop("Marginal Effect on Probability of Graduating") ///
			lab dec(3)

		logit graduate gpa householdincome ap specialed athletics ///
			female black asian otherrace attempts, or
			
		margins, dydx(*) at(ap=0 specialed=0 athletics=0 female=0 black=0 asian=0 otherrace=0 ///
			(mean) gpa householdincome attempts)  post

		outreg2 graduate gpa  householdincome ap specialed athletics ///
			female black asian otherrace attempts ///
			using margins.xls, cttop("Marginal Effect on Probability of Graduating") ///
			lab dec(3)
}


	window manage close graph _all
