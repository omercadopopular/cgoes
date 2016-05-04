/*
/// Do-file written by Carlos Goes and Rania Papageorgiou
/// for use at Dr Prakash Loungani's Macroeconometrics course
/// at Johns Hopkins SAIS

*** This do file aims at
**** (a) practicing time-series commands in STATA
**** (b) simulating cumulative and non-cumulative Impulse Response Functions
*/
 
// 1. Organize your workspace

clear
set more off
set matsize 800

set obs 100																						// sets the observation number to 100
gen t = _n - 1																					// generates a variable that reports the observation number

tsset t																							// sets time series mode on

// 2. Calculate IRFs

// We assume a simple AR(3) process:
	** Y = 1.5*L(Y) - 1*L2(Y) + 0.4*L3(Y)

gen IRF = 1																						// generates a new variable, representing a one unit innovation
replace IRF = l.IRF * 1.5 if t == 1																// replaces the IRF, based on AR(3) process, for period 2
replace IRF = l.IRF * 1.5 - l2.IRF * 1 if t == 2												// replaces the IRF, based on AR(3) process, for period 3
replace IRF = l.IRF * 1.5 - l2.IRF * 1 + l3.IRF * 0.4 if t > 2									// replaces the IRF, based on AR(3) process, for following periods

gen cIRF = 1																					// generates a new variable for the cumulative IRF
forvalues x = 1/99 {
   replace cIRF = sum(IRF) if t <= `x'
} 																								// creates loop for cumulative sum


gen y = 1
replace y = 1.1 * l.y if t > 0


// 3. Plot graphs

tsline IRF if t < 50, yline(0) title("Impulse Response Function", position(11) margin(vsmall)) ///
  subtitle("Non-cumulative",  position(11) margin(vsmall) size(small)) ///
  caption("Y = 1.5 * L(Y) - 1 * L2(Y) + 0.4 * L3(Y)", size(vsmall)) ///
  scheme(s2manual) ///
  saving(irf, replace) name(irf, replace) nodraw
  
tsline cIRF if t < 50, yline(10) title("Impulse Response Function", position(11) margin(vsmall)) ///
  subtitle("Cumulative",  position(11) margin(vsmall) size(small)) ///
  caption("Y = 1.5 * L(Y) - 1 * L2(Y) + 0.4 * L3(Y)", size(vsmall)) ///
  scheme(s2manual) ///
  saving(cirf, replace) name(cirf, replace) nodraw

graph combine irf cirf irf cirf, cols(2) ///
  scheme(s2manual)
  
  
tsline y if t < 50, yline(0) title("Theoretical Impulse Response Function", position(11) margin(vsmall)) ///
  subtitle("of non-stationary data",  position(11) margin(vsmall) size(small)) ///
  caption("Y = 1.1 * L(Y)", size(vsmall)) ///
  scheme(s2manual) ///
  saving(ynon, replace) name(ynon, replace) 


// 4. Simulate VARs

	** Y1 = 0.8 * L(Y1) + 0 * L(Y2) + 0 * L(Y3)
	** Y2 = 0.4 * L(Y1) + 0.8 * L(Y2) + 0 * L(Y3)
	** Y3 = 0.2 * L(Y1) + 0.2 * L(Y2) + 0.8 * L(Y3)

gen y1 = 1
replace y1 = .8 * l.y1 if t > 0

gen y2 = .4 * l.y1
replace y2 = .4 * l.y1 + .8 * l.y2 if t > 1

gen y3 = .2 * l.y1 
replace y3 = .2 * l.y1 if t == 1
replace y3 = .2 * l.y1 + .2 * l.y2 if t > 1
replace y3 = .2 * l.y1 + .2 * l.y2 + .8 * l.y3 if t > 2
	
tsline y1 if t < 50, yline(0) title("Response of Y1 to Y1", position(11) margin(vsmall)) ///
  subtitle("Non-cumulative",  position(11) margin(vsmall) size(small)) ///
  caption("Y1 = 0.8 * L(Y1) + 0 * L(Y2) + 0 * L(Y3)", size(vsmall)) ///
  scheme(s2manual) legend(off) ylabel(0(.2)1)  ///
  saving(y1, replace) name(y1, replace) nodraw
  	
tsline y2 if t < 50, yline(0) title("Response of Y2 to Y1", position(11) margin(vsmall)) ///
  subtitle("Non-cumulative",  position(11) margin(vsmall) size(small)) ///
  caption("Y2 = 0.4 * L(Y1) + 0.8 * L(Y2) + 0 * L(Y3)", size(vsmall)) ///
  scheme(s2manual) legend(off) ylabel(0(.2)1)  ///
  saving(y2, replace) name(y2, replace) nodraw
  
tsline y3 if t < 50, yline(0) title("Response of Y3 to Y1", position(11) margin(vsmall)) ///
  subtitle("Non-cumulative",  position(11) margin(vsmall) size(small)) ///
  caption("Y3 = 0.2 * L(Y1) + 0.2 * L(Y2) + 0.8 * L(Y3)", size(vsmall)) ///
  scheme(s2manual) legend(off) ylabel(0(.2)1)  ///
  saving(y3, replace) name(y3, replace) nodraw
   
tsline y1-y3 if t < 50, yline(0) title("All IRFs", position(11) margin(vsmall)) ///
  subtitle("Non-cumulative",  position(11) margin(vsmall) size(small)) ///
  scheme(s2manual) ylabel(0(.2)1)  ///
  saving(y4, replace) name(y4, replace) nodraw


graph combine y1 y2 y3 y4, cols(2) scheme(s2manual) 
