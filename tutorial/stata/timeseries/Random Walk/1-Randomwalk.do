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
tsset t   													    // sets up time series mode

// 1. Generate 15 random walk series with a loop

local x = 0   													// creates a temporary coumter that will be used in our loop
while `x' < 16 {   												// sets up the loop

	local x = `x' + 1    										// makes the counter add one everytime the loop restarts
	gen r_`x' = 0    											// generates a new series starting with 0
	replace r_`x' = l.r_`x' + rnormal(0,1) if t > 1				// sets r_it = r_it-1 + [random value with normal distribution, mean=0 & sd=1]

}

// 2. Generate stationary series

gen stationary = rnormal(0,1)

// 3. Plot the random series over time

line stationary t, ///
  title("Stationary Series", position(11) margin(vsmall)) ///
  subtitle("random numbers with mean zero", position(11) margin(vsmall)) ///
  caption("Source: what SOURCEry is this?") ///  
  legend(off) name(stationary1, replace) 

line stationary r_1-r_3 t, ///
  title("Stationary and Random Walk Series", position(11) margin(vsmall)) ///
  subtitle("aren't they cool?", position(11) margin(vsmall)) ///
  caption("Source: what SOURCEry is this?") ///  
  legend(off) name(stationary2, replace) 

line r_1-r_15 t, ///
  title("15 Random Walk Series", position(11) margin(vsmall)) ///
  subtitle("aren't they cool?", position(11) margin(vsmall)) ///
  caption("Source: what SOURCEry is this?") ///  
  legend(off) name(rwalk, replace) 

// 4. Regress the random series on each other

reg r_13 r_1
reg r_8 r_4
reg r_2 r_11
reg r_14 r_3

/*

Note that the coefficients will be statistically significant even though the series are random,

That's called a SPURIOUS REGRESSION!

*/
