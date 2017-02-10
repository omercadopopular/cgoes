/*

/// Do-file written by Carlos Goes (andregoes@gmail.com)
/// for use at Dr Prakash Loungani's Macroeconometrics course
/// at Johns Hopkins SAIS

*** This do file aims at
**** (a) practicing VARs and VECMs in STATA
**** (b) understanding cointegration and error correction
**** (c) choosing appropriate lag lenght and cointegration relationships
**** (d) contrasting VARs and VECMs impulse response functions
**** (e) using matrix operators in STATA
**** (f) collapsing daily observations into weekly observations

*/
 
 
// 1. Organize your workspace
 
	set matsize 10000																				// expands matsize
	capture log close 																				// closes any open logs
	clear 																							// clears the memory
	set more off  		

	cd "U:\Research\Macroeconometrics\Stata\VAR and VECMs\"
	import excel using "U:\Research\Macroeconometrics\Stata\VAR and VECMs\mexico daily.xlsx", firstrow	

// 2. Collapse daily observations into weekly observations and label data

	gen daily = mdy(month,day,year)
	gen date = wofd(daily)																				// generates week of the month from daily data
	format date %tw																						// formats weekly variable
	collapse (mean) f10 t10 cds imvol spread vix policy month day year, by(date)						// collapses data into weekly averages
	gen obs = _n																						// generates observation counter
	drop if obs < 250																					// drops part of the sample
	replace obs = _n																					// renumbers observation
	
	tsset date, w																						// tells STATA whats the time variable
	
	label var f10 "Mexico LCU 10Y bond yields"
	label var t10 "US 10Y Treasury yields"
	label var vix "VIX index"
	label var cds "Mexico 5Y USD CDS Spread"
	label var spread "Mexico EMBIG Spreads"
	label var policy "Mexico CB policy rate"
	label var policy "MXN/USD 1 week Implied Volatility"
	
// 3. Single-equation error correction model

	// Testing for cointegration between Mexicos's yields and US yields
	
	// Eye-ball both series: They seem to share a common trend.
	
	tsline f10 t10, scheme(s2color) ///															
	  title("US and Mexico 10Y bond yields", position(11) margin(vsmall) size(small)) ///
	  subtitle("Weekly averages, 2010-2014, in percentage",  position(11) margin(vsmall) size(vsmall)) ///
	  caption("Source: Bloomberg", size(vsmall)) ///
	  ytitle("%", box fcolor(white)) xtitle(,box fcolor(white)) ///
	  legend(rows(2)) ///
	  saving(mexico_and_us, replace) name(mexico_and_us, replace) nodraw
	    
	// The difference between them, albeit weekly, seems to revert to the trend.
	 
	gen yield_diff = f10 - t10
	egen diffmean_t = mean(yield_diff)
	local diffmean = diffmean_t
	drop diffmean_t 
	
	tsline yield_diff, scheme(s2color) ///
	  title("Spread between Mexico and US Yields", position(11) margin(vsmall) size(small)) ///
	  subtitle("Weekly averages, 2010-2014, in percentage",  position(11) margin(vsmall) size(vsmall)) ///
	  caption("Source: Author's Calculations, with Bloomberg", size(vsmall)) ///
	  ytitle("%", box fcolor(white)) xtitle(,box fcolor(white)) ///
	  yline(`diffmean', lcolor(black)) ///
	  saving(difference, replace) name(difference, replace) nodraw
	  
	graph combine mexico_and_us difference, cols(2) ///													// combines graphs
	  name(panel1, replace) scheme(s2color)
	
	// Regress level on level to test for cointegration using Engle-Granger 2-step procedures
		// After regression, collect residuals
		// and run a unit-root test on the residuals to see if they are stationary
	
	reg f10 t10 cds spread policy, vce(robust)															// regresses f10 on vector of regressors
	predict coint_res, r																				// collects residuals
	dfuller coint_res, lags(10)																			// performs unit root test on residuals
	
	// Run error correction model
		// It should be in differences, using lagged differences in the right-hand side
		// and adding the lagged error correction term.

	reg d.f10 dl.t10 dl.f10 dl.cds dl.spread dl.policy l.coint_res, vce(robust)							// d(F10)_t = a*d(T10)_t-1 + b*d(F10)_t-1 + c*(ECT)_t-1
	
	// Create a fitted series using coefficients
	
	gen f10_fit = l.f10 + _b[_cons] + _b[dl.t10] * dl.t10 +  ///										// creates fitted values using coefficients from
		_b[dl.f10] * dl.f10 + _b[dl.cds] * dl.cds + _b[dl.spread] * dl.spread + ///
		_b[dl.policy] * dl.policy + _b[l.coint_res] * l.coint_res
	
	label var f10_fit "'Static' fitted values"
		
	// Create a "dynamic" fitted series
	
	qui reg d.f10 dl.t10 dl.f10 dl.cds dl.spread dl.policy l.coint_res, vce(robust)							// creates a "dynamic" fit, using past predicted values
	gen f10_dfit = l.f10 + _b[_cons] + _b[dl.t10] * dl.t10 +  ///										// into future predicted values
		_b[dl.f10] * dl.f10 + _b[dl.cds] * dl.cds + _b[dl.spread] * dl.spread + ///
		_b[dl.policy] * dl.policy + _b[l.coint_res] * l.coint_res
		
	qui reg d.f10 dl.t10 dl.f10 dl.cds dl.spread dl.policy l.coint_res, vce(robust)
	replace f10_dfit = l.f10_dfit + _b[_cons] + _b[dl.t10] * dl.t10 +  ///										
		_b[dl.f10] * dl.f10_dfit + _b[dl.cds] * dl.cds + _b[dl.spread] * dl.spread + ///
		_b[dl.policy] * dl.policy + _b[l.coint_res] * l.coint_res if obs > 5
		
	label var f10_dfit "'Dynamic' fitted values"
		
	// Plot your fitted series
		
	tsline f10 f10_fit f10_dfit, scheme(s2color) ///
	  title("Actual and Fitted Values of Mexico Bond Yields", position(11) margin(vsmall)) ///
	  subtitle("Weekly averages, 2010-2014, in percentage",  position(11) margin(vsmall) size(small)) ///
	  caption("Source: Author's Calculations, with Bloomberg", size(vsmall)) ///
	  ytitle("%", box fcolor(white)) xtitle(,box fcolor(white)) ///
	  saving(fitted, replace) name(fitted, replace)
	
// 4. Vector Error Correction Model

	drop if date < tw(2010w32)																				// shorts the sample
	
	// Test for the appropriate lag length
				
	varsoc t10 vix cds spread policy imvol f10, maxlag(8) 													// checks appropriate lag lenght	
		matrix LL = r(stats)																				// creates a matrix with results
		svmat LL, name(col)																					// transforms matrix into series
		egen minAIC = min(AIC)																				// gets the row that minimizes AIC
		gen optimal_lag = lag if minAIC == AIC																// gets the appropriate lag length
		mkmat optimal_lag, matrix(L) nomissing																// generates a 1x1 vector with that value
		local lag = L[1,1] + 1																				// creates scalar out of that vector
		
		*matrix dir																							// lists matrices stored in memory
		*matrix list LL																						// shows matrix "LL"
		*matrix list L																						// shows matrix "L"
				
		matrix drop LL L																					// deletes matrices "LL" and "L"
		drop LL LR df p FPE AIC HQIC SBIC optimal_lag minAIC lag											// drops variables

	// Test for cointegration, with the appropriate lag length
	
	vecrank t10 vix cds spread policy imvol f10, lags(`lag') 						
	
	// Add constrainst to beta and alpha
		// We do that do normalize f10's coefficient at 1
		// and to set the stationary variables coefficients to zero
				
	constraint define 1 [_ce1]f10 = 1
	constraint define 2 [_ce1]vix = 0
	constraint define 3 [_ce1]imvol = 0	
	constraint define 4 [D_vix]L1._ce1 = 0
	constraint define 5 [D_imvol]L1._ce1 = 0		
	
	// Run VECM
							
	vec t10 vix cds spread policy imvol f10, lags(`lag') bconstraints(1/3) aconstraints(4/5) trend(t)
	
	// Plot IRFs graphs and print IRF tables
	
	irf create IRF, set (f10) replace step(26) 
	irf graph oirf, impulse(t10) response (f10 t10) name(mexicovecm, replace)
	irf ctable (IRF t10 f10 oirf) (IRF t10 t10 oirf)
	
	// Plot FEVD graphs and print FEVD tables
		
	irf graph fevd, impulse(t10 vix cds spread policy imvol f10) response (f10) name(mexicovefd, replace)
	irf ctable (IRF t10 f10 fevd) (IRF vix f10 fevd) (IRF cds f10 fevd) ///
		(IRF spread f10 fevd) (IRF policy f10 fevd) (IRF imvol f10 fevd) ///
		(IRF f10 f10 fevd)

	// Compare with badly specified VAR
	
	local lag = `lag' - 1
	
	var t10 vix cds spread policy imvol f10, lags(`lag')
	
	// Plot IRFs graphs and print IRF tables
	
	irf create IRF2, set (f10) replace step(26) 
	irf graph oirf, impulse(t10) response (f10 t10) name(mexicovar, replace)
	irf ctable (IRF2 t10 f10 oirf) (IRF2 t10 t10 oirf)
	
	// Plot FEVD graphs and print FEVD tables
		
	irf graph fevd, impulse(t10 vix cds spread policy imvol f10) response (f10) name(mexicovar, replace)
 
