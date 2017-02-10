/*

/// Do-file written by Rania Papageorgiou and Carlos Goes
/// for use at Dr Prakash Loungani's Macroeconometrics course
/// at Johns Hopkins SAIS

Please import excel file: oil.xls

*/



 /*Tell STATA we are working with time series data*/

import excel "U:\Macroeconometrics\Stata\Forecasting\Oil.xls", sheet("Sheet1") firstrow
 
generate date = m(1986m1) +_n-1
format date %tm
tsset date

/*Give variables full names*/
label var oil "WTI Spot Price, FOB (USD/Barrel)"


/*Graph data*/
line oil date, ///
  title("WTI Spot Price", position(20) margin(vsmall)) ///
  subtitle("End of Month Data, 1998m1-2014m3",  position(11) margin(vsmall) size(small))
 
 /* AR Model
Begin with Dickey Fuller test to determine whether the spot price of oil is stationary or not*/
dfuller oil
dfuller oil, lags (2) 
dfuller oil, lags (4)

/*Look at correlograms to determine lag length*/
ac oil
pac oil

regress D.oil LD.oil, vce(robust) //This is equivalent to 'arima US10YR, arima (1,1,0)

regress D.oil LD(1/2).oil, vce(robust) // arima US10YR, arima (2,1,0)

/*Forecast AR data*/
tsappend, add(12) //Add 12 more time slots to variable 'date'

predict p if date>tm(2014m3) //Out of sample 1 period ahead forecast

gen forecastAR = oil

replace forecastAR = l.forecastAR + _b[_cons] + _b[LD.oil] * LD.forecastAR + _b[LD2.oil] * LD2.forecastAR ///
	if date > tm(2014m3)
	
tsline forecastAR oil if date > tm(2008m1), ///
  title(" AR Forecast - WTI Spot Price", position(20) margin(vsmall)) ///
  subtitle("End of Month Data, 2008m1-2014m3",  position(11) margin(vsmall) size(small))
  
  
/*ARMA Model*/

arima oil, ar(1/2) ma(1/12) // this could also be written as arima D.US10YR, arima (2,0,12) [format = arima(p,d,q)]

predict pq if date>tm(2014m4) // Out of sample 1 period ahead forecast
predict pq2, dynamic(tm(2014m2)) // Preduct using forecasts beginning in 2014m3

line pq date if date > tm(2008m1), ///
	|| line pq2 date, ///
	title(" One Step Ahead vs. Dynamic Forecasting", position(20) margin(vsmall)) ///
    subtitle("Forecasts: 2014m3 - 2015m3",  position(11) margin(vsmall) size(small))

predict pq3
predict pq4, dynamic(tm(1986m3))

line pq3 date if date > tm(2008m1), ///
	|| line pq4 date, ///
	title(" One Step Ahead vs. Dynamic Forecasting", position(20) margin(vsmall)) ///
    subtitle("End of Month Data, 1998m1-2014m3",  position(11) margin(vsmall) size(small))
