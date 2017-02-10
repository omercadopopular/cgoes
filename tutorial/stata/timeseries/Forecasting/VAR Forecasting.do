/*

/// Do-file written by Rania Papageorgiou and Carlos Goes
/// for use at Dr Prakash Loungani's Macroeconometrics course
/// at Johns Hopkins SAIS

/// Please import 
 */


 /*Tell STATA we are working with time series data*/
generate date = m(1998m1) +_n-1
format date %tm
tsset date

/*Give variables full names*/
label var CPI "Core CPI, YoY"
label var VIX "Dow Jones Industrial Average VIX"
label var US10YR "US 10 Year Treasury, Yield"
label var PMI "Production Managers Index"
label var LIBOR "3 Month USD LIBOR"

/*Graph data*/
line CPI date, ///
  title("Consumer Price Index", position(20) margin(vsmall)) ///
  subtitle("End of Month Data, 1998m1-2014m3",  position(11) margin(vsmall) size(small))
  
line VIX date, ///
  title("CBOE Volatility Index", position(20) margin(vsmall)) ///
  subtitle("End of Month Data, 1998m1-2014m3",  position(11) margin(vsmall) size(small))
 
line US10YR date, ///
  title("U.S 10 Year Treasury Yield", position(20) margin(vsmall)) ///
  subtitle("End of Month Data, 1998m1-2014m3",  position(11) margin(vsmall) size(small))
 
line PMI date, ///
  title("ISM Production Managers Index", position(20) margin(vsmall)) ///
  subtitle("End of Month Data, 1998m1-2014m3",  position(11) margin(vsmall) size(small))
 
 line LIBOR date, ///
  title("LIBOR - 3 Month USD", position(20) margin(vsmall)) ///
  subtitle("End of Month Data, 1998m1-2014m3",  position(11) margin(vsmall) size(small))
  
gen LUS10YR = log(US10YR)

line LUS10YR date, ///
  title("U.S 10 Year Treasury Yield", position(20) margin(vsmall)) ///
  subtitle("End of Month Data, 1998m1-2014m3",  position(11) margin(vsmall) size(small))

  
line D.US10YR date, ///
  title("U.S 10 Year Treasury Yield", position(20) margin(vsmall)) ///
  subtitle("End of Month Data, 1998m1-2014m3",  position(11) margin(vsmall) size(small))
  
set more off

var D.PMI D.CPI D.US10YR D.VIX D.LIBOR, lags (1/12)

varlmar, mlag(12)
varsoc

var D.PMI D.CPI D.US10YR D.VIX D.LIBOR, lags (1/5)

irf set results //set IRF file
irf create results, step(24) //create IRF file


irf graph oirf, impulse (D.PMI) response (D.US10YR)
irf graph oirf, impulse (D.CPI) response (D.US10YR)
irf graph oirf, impulse (D.VIX) response (D.US10YR)
irf graph oirf, impulse (D.LIBOR) response (D.US10YR)

fcast compute est_, step(12) //forecast 12 periods ahead
fcast graph est_US10YR, observed // graph dynamic forecasts for US10YR
