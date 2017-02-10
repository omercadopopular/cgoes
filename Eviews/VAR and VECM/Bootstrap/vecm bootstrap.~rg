''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''					  US Tapering Effects on Emerging Markets Local Bond Yields				    ''
''																														    ''
'' 		    Cointegration Analysis, Variance Decomposition, and Counterfactual Analysis	    ''
''								using a Vector Autocorrection Model (VECM)								    ''
''					  																									    ''
''													  Spring 2014													    ''
''					  																									    ''
'' 												 	  Prepared by													    ''
''			 	Shaun Roache (sroache@imf.org) and Carlos Goes (cgoes@imf.org)       	    ''
''					  																									    ''
''								Boothstrapping algorithm perfected by									    ''
''							   Robert Blotevogel, Yi Liu and Carlos Góes	  	    							    ''
''					  																									    ''
''	Papers that  used this code or some derivation thereof:											    ''
''					  																									    ''
''    Kamil, Góes et al (2014). "The Effects of US Monetary Normalization on Emerging		    ''
''	Markets' Sovereign Bond Yields: the Cases of Brazil and Mexico"								    ''
''    Perreli and Góes (2014, forthcoming). ""Tapering Talks and Local Currency Sovereign   " 
''		Bond Yields: How South Africa Performed Relative to Its Emerging Market Peers,"      " 
'' 	Perrelli, Roache, & Góes, (2014, forthcoming) “The Impact of the Tapering Tantrum	    ''
''		on the Slope of the Yield Curve of Emerging Market Economies”							    ''
''					  																									    ''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

'' 1. Prepare workspace

	close VECM_1Y.wf1
	wfcreate(wf=VECM_1Y,page=weekly) w 1/7/2005 4/18/2014
	%data = @runpath + "brazil.txt"
	read(t=txt) %data 14

	series spread = embigcountry - embigglobal
	series t10vix = t10 * vix 
	series f10vix = f10 * vix 
	%cholesky = "t10 vix cds spread policy imvol f10"
	
	'1.2 Create scalars

		%t0 = "7/27/2010"
		%T = "10/4/2013"
		!T1 = 26
		!reps = 1000

		smpl %t0 %T
		
		group all {%cholesky}

'' 2. Run VECM

	'2.1 Run VAR to identify cointegrating relationships

		equation coint
		coint.cointreg(method=fmols) f10 t10 vix cds spread policy imvol 
		coint.makeresid cresid
		freeze(ucresid) cresid.uroot(adf)
		freeze(uf10gls) f10.uroot(dfgls)
 
		var var1
		var1.ls 1 1 {%cholesky}

		var1.laglen(12,VNAME = lags)
		!lag1 = 3

		var var2
		var2.ls 1 !lag1 {%cholesky}

		var var3
		var3.ls 1 !lag1 d(t10) d(vix) d(cds) d(spread) d(policy) d(imvol) d(f10)

		freeze(cointegration) var2.coint(f,!lag1)

		freeze(granger) all.cause(1)

		for %a {%cholesky}
			freeze(u{%a}) {%a}.uroot(adf)
		next

	'2.2 Run VECM with beta restrictions imposed on stationary variables
	
		var vecm1
		vecm1.append(coint) b(1,7) = 1
		vecm1.append(coint) b(1,2) = 0 
		vecm1.append(coint) b(1,6) = 0 
		vecm1.ec(restrict,1) 1 !lag1 {%cholesky}


			'2.2.1 Obtain residuals for Boothstrapping
			group grp_res1 
			vecm1.makeresid(n=grp_res1) t10_r vix_r cds_r spread_r policy_r imvol_r f10_r 
	
			'2.2.2 Calculate predicted values
			for %a  t10 vix cds spread policy f10 imvol 
				series {%a}_hat = {%a} - {%a}_r
			next

			group ghat t10_hat vix_hat  cds_hat  spread_hat  policy imvol_hat  f10_hat  

	'2.3 Save irf and variance decomposition
	
		freeze(impulsef10) vecm1.impulse(!T1,t,smat=impulsef10mat) {%cholesky} @ {%cholesky} @ {%cholesky}
		freeze(decompf10)  vecm1.decomp(!T1,mg) f10

'' 3. Store dynamic fit and build counterfactuals

	'3.1 Store historical data

		for %c cds spread  vix policy t10 imvol
	 		genr {%c}_hist = {%c}
		next

	'3.2 Store dynamic fit for the local 10Y,
		'using actual values for other variables
		'and fitted lags for the local 10Y

		vecm1.makemodel(whole)
			smpl 9/1/2010 %T
			whole.scenario(n,a=_w) "Fitted Values"
			whole.solveopt(s=b, d=d, m=1000000)
			whole.exclude cds t10 vix policy imvol spread 
			whole.solve

	'3.3 Set up model for counterfactuals post May 21st

		vecm1.makemodel(compare)
		smpl 5/21/2013 %T

		'3.3.1	Solve baseline cenario
			'stochastic dynamic solution
			'using actual values for other variables
			'and fitted lags for the local 10Y

			compare.scenario(n,a=_fit)  "Fitted"
			compare.solveopt(s=b,d=d,m=1000000)
			compare.exclude cds t10 vix policy imvol spread 
			compare.solve

		'3.3.2	Solve Fixed US 10Y counterfactual
			'stochastic dynamic solution
			'hold US 10Y fixed as of May 21st
			'using actual values for other variables
			'and fitted lags for the local 10Y

			compare.scenario(n,a=_t10)  "Fixed T10"
			compare.solveopt(s=b,d=d,m=1000000)

			for %c  5/18/2013 5/25/2013 6/01/2013 6/08/2013 6/15/2013 6/22/2013 6/29/2013 _
				7/06/2013 7/13/2013 7/20/2013 7/27/2013 8/03/2013 8/10/2013 8/17/2013 _
				8/24/2013 8/31/2013 9/07/2013 9/14/2013 9/21/2013 9/28/2013 10/05/2013 _
				10/12/2013 10/19/2013 10/25/2013 11/01/2013 11/08/2013  11/15/2013 _
				11/22/2013 11/29/2013 12/06/2013 12/13/2013 12/20/2013 12/27/2013 _
				1/03/2014 1/10/2014 1/17/2014 1/24/2014 1/31/2014 2/07/2014 2/14/2014 _
				2/21/2014 2/28/2014 3/07/2014 3/14/2014 3/21/2014 3/28/2014 4/04/2014 _
				4/11/2014 4/18/2014
					t10(@dtoo(%c)) = 1.9506
			next

			compare.exclude cds t10 vix policy imvol spread 
			compare.solve

			smpl @all
			genr t10_alt = t10
			t10 = t10_hist
			smpl 5/18/2013 %T

		'3.3.2	Solve Fixed country risk counterfactual
			'stochastic dynamic solution
			'holding CDS fixed as of May 21st
			'using actual values for other variables
			'and fitted lags for the local 10Y

			compare.scenario(n,a=_fc)  "Fixed CDS"
			compare.solveopt(s=b,d=d,m=1000000)

			for %c  5/18/2013 5/25/2013 6/01/2013 6/08/2013 6/15/2013 6/22/2013 6/29/2013 _
				7/06/2013 7/13/2013 7/20/2013 7/27/2013 8/03/2013 8/10/2013 8/17/2013 _
				8/24/2013 8/31/2013 9/07/2013 9/14/2013 9/21/2013 9/28/2013 10/05/2013 _
				10/12/2013 10/19/2013 10/25/2013 11/01/2013 11/08/2013  11/15/2013 _
				11/22/2013 11/29/2013 12/06/2013 12/13/2013 12/20/2013 12/27/2013 _
				1/03/2014 1/10/2014 1/17/2014 1/24/2014 1/31/2014 2/07/2014 2/14/2014 _
				2/21/2014 2/28/2014 3/07/2014 3/14/2014 3/21/2014 3/28/2014 4/04/2014 _
				4/11/2014 4/18/2014
					spread(@dtoo(%c)) = -99.589
					cds(@dtoo(%c)) = 127.125
			next

			compare.exclude cds t10 vix policy imvol spread 
			compare.solve

			smpl @all
			genr spread_alt = spread
			spread = spread_hist
			smpl 5/18/2013 %T

		'3.3.3	Solve all fixed counterfactual
			'stochastic dynamic solution
			'holding all variables fixed as of May 21st
			'and fitted lags for the local 10Y

			compare.scenario(n,a=_fd)  "All Constant"
			compare.solveopt(s=b,d=d,m=1000000)

			for %c  5/18/2013 5/25/2013 6/01/2013 6/08/2013 6/15/2013 6/22/2013 6/29/2013 _
				7/06/2013 7/13/2013 7/20/2013 7/27/2013 8/03/2013 8/10/2013 8/17/2013 _
				8/24/2013 8/31/2013 9/07/2013 9/14/2013 9/21/2013 9/28/2013 10/05/2013 _
				10/12/2013 10/19/2013 10/25/2013 11/01/2013 11/08/2013  11/15/2013 _
				11/22/2013 11/29/2013 12/06/2013 12/13/2013 12/20/2013 12/27/2013 _
				1/03/2014 1/10/2014 1/17/2014 1/24/2014 1/31/2014 2/07/2014 2/14/2014 _
				2/21/2014 2/28/2014 3/07/2014 3/14/2014 3/21/2014 3/28/2014 4/04/2014 _
				4/11/2014 4/18/2014
					spread(@dtoo(%c)) = -99.589
					cds(@dtoo(%c)) = 127.125
					vix(@dtoo(%c)) = 12.45
					policy(@dtoo(%c)) = 7.22
					t10(@dtoo(%c)) = 1.9506
					imvol(@dtoo(%c)) = 8.7825
			next

			compare.exclude cds t10 vix policy imvol spread 
			compare.solve
			smpl @all

			for %d cds spread vix policy t10 imvol
 				genr {%d}_alt = {%d}
 				{%d} = {%d}_hist
			next

			smpl 5/21/2013 %T

	'3.4 Group and Plot Results

		group g1 f10 f10_fitm f10_t10m f10_fcm f10_fdm
		group g2 t10_alt t10
		group g3 cds_alt cds
		group g4 spread_alt spread
		group g5 f10 f10_wm

		smpl 1/1/2013 %T

		for !a=1 to 4
			freeze(graph!a) g!a.plot 
		next

		smpl 7/1/2010 %T
		freeze(graph5) g5.plot 

		for !a=1 to 5
			show graph!a
		next

'4. Run boothstrapping procedure to calculate standard-errors

	'4.1 Save sigma matrix and get the inverse of the Cholesky decomposition

		sym residcov = vecm1.@residcov 
		matrix lower= @cholesky(residcov)
		matrix upper= @inverse(lower)

	'4.2 Create loop with 1000 repetitions to calculate standard errors through simulation

		for !a=1 to !reps
			smpl @all if t10_r<>na
			
			'4.2.1 Transform original reduced-form errors into structural errors
					'Multiply transposed reduce-form errors by inverse of cholesky lower triangular to get structural errors
					'We use structural errors in order to preserve the matrix covariance matrix

			stom(grp_res1, resid_r)
			matrix resid_r_trans = @transpose(resid_r)
			matrix resid_s_trans= upper* resid_r_trans
			matrix resid_s=@transpose(resid_s_trans)

			'4.2.2 Resample with replace from the structural errors
				'Resampling the rows of structural errors will add randomness into the process	

			matrix resid_s_res=@resample(resid_s)
			mtos(resid_s_res, grp_res2)
			grp_res2.resample t10_a vix_a cds_a spread_a policy_a f10_a imvol_a 
			group grp_a t10_a vix_a cds_a spread_a policy_a f10_a imvol_a 
			stom(grp_a, resid_s_resmpl_trans)

			'4.2.3 Transform the new structural errors back into reduced-form errors

  			matrix resid_s_resmpl=@transpose(resid_s_resmpl_trans)
	 		matrix resid_r_resmpl_trans= lower*resid_s_resmpl 
	 		matrix resid_r_resmpl=@transpose(resid_r_resmpl_trans)
	 		mtos(resid_r_resmpl, grp_res2)

			'4.2.4 Use original predicted values and resampled residuals to generate pseudo-series for simulation

	 		genr t10_0 = t10_hat + SER01
	 		genr vix_0 = vix_hat + SER02
	 		genr cds_0 = cds_hat + SER03
	 		genr spread_0 = spread_hat + SER04
	 		genr policy_0 = policy_hat + SER05
	 		genr imvol_0 = imvol_hat + SER06
	 		genr f10_0 = f10_hat + SER07

			'4.2.5 Create VECM with pseudo-series

	 		vecm1.append(coint) b(1,1) = 1
	 		vecm1.append(coint) b(1,2) = 0 
	 		vecm1.append(coint) b(1,6) = 0 
   	 		var vecm_rs!a.ec(c,1) 1 !lag1  t10_0 vix_0 cds_0 spread_0 policy_0 imvol_0 f10_0 

			'4.2.6 Collect 1000 IRFs to calculate standard errors

				'4.2.6.1 Generate matrices to store simulated IRFs
			
	 				for %b f10 t10 policy cds
	 					for !b = 1 to 4 
	 						matrix(!T1,!reps) m!b_{%b}
	 					next
	 				next

				'4.2.6.2 Run IRFs with the local 10Y as the impulse variable	
				
	 				for %a f10 t10 policy cds
	 					vecm_rs!a.impulse(!T1,t,smat=v_ir{%a}!a) {%a}_0 @  f10_0 @ t10_0 vix_0 _
							cds_0 spread_0 policy_0 f10_0 imvol_0 
	 					colplace(m1_{%a},v_ir{%a}!a,!a)
	 					delete v_ir{%a}!a
	 					close vecm_rs!a
	 				next
 
				'4.2.6.3 Run IRFs with the US 10Y as the impulse variable	
	
 					for %a f10 t10 policy cds
 						vecm_rs!a.impulse(!T1,t,smat=v_ir{%a}!a) {%a}_0 @  t10_0 @ t10_0 vix_0 _
							cds_0 spread_0 policy_0 f10_0 imvol_0 
 						colplace(m2_{%a},v_ir{%a}!a,!a)
 						delete v_ir{%a}!a
 						close vecm_rs!a
 					next
	
				'4.2.6.4 Run IRFs with the policy rate as the impulse variable	
	
 					for %a f10 t10 policy cds
 						vecm_rs!a.impulse(!T1,t,smat=v_ir{%a}!a) {%a}_0 @  policy_0 @ t10_0 vix_0 _
							cds_0 spread_0 policy_0 f10_0 imvol_0 
						colplace(m3_{%a},v_ir{%a}!a,!a)
						delete v_ir{%a}!a
						close vecm_rs!a
					next
	
				'4.2.6.5 Run IRFs with the CDS as the impulse variable	
					
					for %a f10 t10 policy cds
						vecm_rs!a.impulse(!T1,t,smat=v_ir{%a}!a) {%a}_0 @  cds_0 @ t10_0 vix_0 _
							cds_0 spread_0 policy_0 f10_0 imvol_0 
						colplace(m4_{%a},v_ir{%a}!a,!a)
						delete v_ir{%a}!a
						close vecm_rs!a
					next

			close vecm_rs!a
	     		delete vecm_rs!a
		next
		

		'4.2.7 Calculate standard errors by calculating standard deviation for each period of each IRFs simulation

			'4.2.7.1 Store IRFs that have the local 10Y as impulse variables into vectors
							
				for %c f10 t10 policy cds
				
					vector(!T1) vf10_ir{%c}_sigma
				
					for !a = 1 to !T1
						vf10_ir{%c}_sigma(!a) = @stdev(@rowextract(m1_{%c},!a))
					next
				
				next

			'4.2.7.2 Store IRFs that have the US 10Y as impulse variables into vectors
										
				for %c f10 t10 policy cds
				
					vector(!T1) vt10_ir{%c}_sigma
				
					for !a = 1 to !T1
						vt10_ir{%c}_sigma(!a) = @stdev(@rowextract(m2_{%c},!a))
					next
				
				next
				
			'4.2.7.3 Store IRFs that have the policy rate as impulse variables into vectors
							
				for %c f10 t10 policy cds
				
					vector(!T1) vpolicy_ir{%c}_sigma
				
					for !a = 1 to !T1
						vpolicy_ir{%c}_sigma(!a) = @stdev(@rowextract(m3_{%c},!a))
					next
				
				next
				
			'4.2.7.4 Store IRFs that have the CDS as impulse variables into vectors
							
				for %c f10 t10 policy cds
				
					vector(!T1) vcds_ir{%c}_sigma
				
					for !a = 1 to !T1
						vcds_ir{%c}_sigma(!a) = @stdev(@rowextract(m4_{%c},!a))
					next
				
				next
	
save BRAZIL_DATASTREAM_SMALLSAMPLE(3lags).wf1

stop

''''''''''''''''''''''''''' END OF CODE '''''''''''''''''''''''''''
