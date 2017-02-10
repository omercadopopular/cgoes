
/*

/// Do-file written by Carlos Goes and Rania Papageorgiou
/// for use at Dr Prakash Loungani's Macroeconometrics course
/// at Johns Hopkins SAIS

*** This do file aims at
**** (a) practicing time-series commands in STATA
**** (b) creating 15 random walk series
**** (c) provide examples of spurious regressions

 
 */
 
capture log close 												// close any open logs
clear 															// clear the memory
set more off   													// makes sure STATA won't ask you to click "more" to continue running the code
*log using randomwalk, replace  								// chooses logfile

set obs 1500   													// sets up the number of observations to 1500

gen t = _n   													// generates a continuous time variable
tsset t   				

// I(1) and I(0)

gen i0 = 0
replace i0 = 0.9 * l.i0 + rnormal(0,1) if t > 1
gen i1 = 0
replace i1 = l.i1 + rnormal(0,1) if t > 1 
  
line i0 i1 t if t < 150, ///
  scheme(s2manual)  ///
  title("I(0) and I(1) series", position(11) margin(vsmall)) ///
  subtitle("Yt = b*Y_t-1 + e_t", position(11) margin(vsmall)) ///
  yline(0,lcolor(black)) lwidth(thin) ylabel(,nogrid) ///
  name(i0, replace) 

// AR(1) with different coefficients

gen ar19 = 0
replace ar19 = 0.9 * l.ar19 + rnormal(0,1) if t > 1
gen ar16 = 0
replace ar16 = 0.6 * l.ar16 + rnormal(0,1) if t > 1
gen ar13 = 0
replace ar13 = 0.3 * l.ar13 + rnormal(0,1) if t > 1


line ar19 ar13 t if t < 200, ///
  scheme(s2manual)  ///
  title("Simulated AR(1) processes", position(11) margin(vsmall)) ///
  subtitle("Yt = b*Y_t-1 + e_t", position(11) margin(vsmall)) ///
  yline(0,lcolor(black)) lwidth(vthin) ylabel(,nogrid) ///
  legend( label(1 "b = 0.9") label(2 "b = 0.3") ) ///
  name(ar1, replace)
  
ac ar19, ///
  scheme(s2manual)  ///
  title("ACF of AR(1) Process", position(11) margin(vsmall)) ///
  yline(0,lcolor(black)) lwidth(vthin) ylabel(,nogrid) ///
  name(acar19, replace) nodraw

pac ar19, ///
  scheme(s2manual)  ///
  title("PACF of AR(1) Process", position(11) margin(vsmall)) ///
  yline(0,lcolor(black)) lwidth(vthin) ylabel(,nogrid) ///
  name(pacar19, replace) nodraw

graph combine acar19 pacar19, ///
  scheme(s2manual)  ///
  name(ar19, replace)

  
// MA(1)

gen random = rnormal(0,1)
gen ma1 = 10 + random
replace ma1 = 10 + 0.8 * l.random + random if t >1

tsline ma1 if t < 300, yline(0,lcolor(black))  ///
  scheme(s2manual)  ///
  title("Simulated Moving Average Process", position(11) margin(vsmall)) ///
  subtitle("MA(1)", position(11) margin(vsmall)) ///
  lwidth(thin) ylabel(,nogrid) yline(10,lcolor(black)) ///
  name(ma, replace) 

ac ma1, ///
  scheme(s2manual)  ///
  title("ACF of MA(1) Process", position(11) margin(vsmall)) ///
  yline(0,lcolor(black)) lwidth(vthin) ylabel(,nogrid) ///
  name(acma1, replace) nodraw
    
pac ma1, ///
  scheme(s2manual)  ///
  title("PACF of MA(1) Process", position(11) margin(vsmall)) ///
  yline(0,lcolor(black)) lwidth(vthin) ylabel(,nogrid) ///
  name(pacma1, replace) nodraw

graph combine acma1 pacma1, ///
  scheme(s2manual)  ///
  name(ma1, replace)
  
