				
				
				
				
				
							
				varsoc yield_us log_oil_price vix cds_bhr yield_bhr, maxlag(12)
				
				matrix A = r(stats)
				svmat A, name(col)
				matrix drop A
				egen minAIC = min(AIC)
				gen optimal_lag = lag if minAIC == AIC
				mkmat optimal_lag, nomissing
				local lag = optimal_lag[1,1]
		
				vecrank yield_us embig_price cds_bhr yield_bhr, lags(`lag') 
				estadd scalar co_int_vec=e(k_ce95)

				var yield_us log_oil_price vix cds_bhr yield_bhr , lags(1/`lag') 
				irf create BAHRAIN_var_oil, set (BHR_yield) replace step(26) 
				
				
				**** Model with constraints ****
				constraint define 1 [_ce1]yield_us = 1
				constraint define 2 [D_yield_us]L1._ce1 = 0
				constraint define 3 [D_cds_bhr]L1._ce1 = 0
				
							
				vec yield_us embig_price cds_bhr yield_bhr , lags(`lag') bconstraints(1) aconstraints(2/3) 
				_eststo
				
				matrix tmp = e(beta)
				scalar co_int_yield_us = tmp[1,1]
				scalar co_int_embig_price = tmp[1,2]
				scalar co_int_cds_bhr = tmp[1,3]
				scalar co_int_yield_bhr = -tmp[1,4]
				scalar co_int_yield_cons = tmp[1,5]
				
				gen equlbrm_oil_yield_bhr = co_int_yield_us/co_int_yield_bhr*yield_us + co_int_embig_price/co_int_yield_bhr*embig_price ///
							+ co_int_cds_bhr/co_int_yield_bhr*cds_bhr + co_int_yield_cons/co_int_yield_bhr 
								
				
				irf create BAHRAIN, set (BHR_yield) replace step(26) 
						
				irf graph oirf, impulse(yield_us) response (yield_us yield_bhr) level(95) name(vecm)
								
				drop lag LL LR df p FPE AIC HQIC SBIC minAIC optimal_lag

				
				*** To generate dynamic forecasts from May 2013 (tapering speech) ***
				vec yield_us embig_price cds_bhr yield_bhr if date<19499, lags(3)
				fcast compute prdctd_, step(34)
				fcast graph prdctd_yield_bhr, observed scheme(w2mono)
							
				
				/*
				
				**** Create CHARTS ****
				twoway (tsline yield_bhr , lwidth(medthick)) (tsline equlbrm_yield_bhr , lwidth(medthick))
				twoway (tsline yield_bhr) (tsline bhr_yield_hat)
				twoway (tsline yield_bhr) (tsline yield_us)

				
