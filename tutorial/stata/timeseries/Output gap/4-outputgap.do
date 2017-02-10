/*

/// Do-file written by Carlos Goes and Rania Papageorgiou
/// for use at Dr Prakash Loungani's Macroeconometrics course
/// at Johns Hopkins SAIS

*** This do file aims at
**** (a) practicing time-series commands in STATA
**** (b) calculating potential Output and Output Gap with the Hodrick-Prescott filter
**** (c) calculating Okun's law

ATTN: Make sure you have the hprescott command installed. If you dont:
     -> net search hprescott
 
 */
 
 
capture log close 												// close any open logs
clear 															// clear the memory
set more off   													// makes sure STATA won't ask you to click "more" to continue running the code
use "U:\Research\Macroeconometrics\Stata\Output gap\outputgap.dta"
log using outputgap.log, replace  								// chooses logfile

// 1. Prepare the data

// 1a. Take logs of the output and calculate first differences

gen ly = log(y)
gen dly = ( ly - l1.ly ) * 100  								// you can take first differences using the lag operator (l.)
gen du = d1.u * 100  											// or directly through the difference operator (d.)

// 1b. Remember to properly label your variables, it will make it easier for you to build your graphs

label var date "Year"
label var y "Actual Output"
label var u "Unemployment rate"
label var ly "Natural log of actual GDP"
label var dly "Annual GDP Growth"
label var du "Change in employment"

tsset date, y 													// tells STATA you are dealing with a time series

// 2. Use Hodrick-Prescott filter of the log of GDP

hprescott ly, stub(yhp) smooth(6.25) 

// 3. Exponentiate calculated trend to obtain the trend in levels

rename yhp_ly_sm_1 yp 
label var yp "Potential Output"
replace yp = exp(yp)

// 4. Calculate Output Gap

gen ygap = ( y / yp - 1 ) * 100
label var ygap "Output Gap"

// 5. Do the same to calculate the natural rate of unemployment and the employment gap

hprescott u, stub(uhp) smooth(6.25)

rename uhp_u_sm_1 uhp
label var uhp "Natural rate of unemployment"

gen ugap = ( u / uhp - 1 ) * 100

// 6. Draw graphs

line yp date || line y date, ///
  title("Potential Output and Actual Output in Brazil", position(11) margin(vsmall)) ///
  subtitle("(in percent)",  position(11) margin(vsmall) size(small)) ///
  caption("Source: Author's calculations, with IMF Data; Trend calculated using Hodrick-Prescott Filter", size(vsmall)) ///
  saving(output_and_potential, replace) name(output_and_potential, replace)

tw bar ygap date, yline(0, lcolor(black)) ///
  title("Output Gap in Brazil", position(11) margin(vsmall)) ///
  subtitle("(in percent of potential GDP)",  position(11) margin(vsmall) size(small)) ///
  caption("Source: Author's calculations, with IMF Data; Trend calculated using Hodrick-Prescott Filter", size(vsmall)) ///
  ytitle("Output gap") xtitle("Year") ylabel(-6 0 6 12) || ///
  line dly date, yaxis(2) ylabel(-5 0 5 10, axis(2)) ///
  saving(ygap, replace) name(ygap, replace)
    
  
// 6. Calculate relationship between unemployment and output and plot Okun's law scatterplot

reg ygap ugap, robust 												// regresses the unemployment gap on the output gap
estimates store ygap 												// stores the results with the label "ygap"
reg dly du, robust 													// regresses the change in unemployment on GDP growth
estimates store dly 												// stores the results with the label "dly"
estimates table ygap dly, star stats(r2) b(%9.3f) 					// presents the results labelled ygap and dly

twoway lfitci du dly || scatter du dly, ///
  msymbol(oh) yline(0, lcolor(black) lstyle(grid)) xline(0, lcolor(black) lstyle(grid)) mlabel(date) mlabsize(vsmall) ///
  title("Okun's law in Brazil", position(11) margin(vsmall)) ///
  subtitle("(GDP growth and unemployment, in percent)", position(11) margin(vsmall) size(small)) ///
  caption("Source: Author's calculations, with IMF Data; Trends calculated using Hodrick-Prescott Filter", size(vsmall)) ///
  ytitle("Change in unemployment") xtitle("GDP growth") legend(off) ///
  saving(okun, replace) name(okun, replace)
