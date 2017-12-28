
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''''''																																			            ''''''
'''''' 												PANEL VAR, IMPULSE RESPONSES AND CONFIDENCE INTERVALS			            '''''' 
'''''' 														USING GMM/IV ARELLANO BOND FOR SHORT PANELS			            ''''''
''''''																																			            ''''''
''''''																						  CODED BY									            ''''''
''''''																					    CARLOS GOES								            ''''''
'''''''																	        (andregoes@gmail.com)								            ''''''
''''''																																			            ''''''
''''''														If you use this code, please quote the following paper:				            ''''''
''''''				Góes, C. 2016. “Institutions and Growth: A GMM/ IV Panel VAR Approach.” Economics Letters 138: 85–9.                           ''''''
''''''																																			            ''''''
''''''														  This version of the code accomodates up to six lags				            ''''''
''''''																																			            ''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''							

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''' SECTION 1: USER INPUTS '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

''''' DIRECTORY SETTINGS

		%dir = "U:\Research\institutions\"									'Working directory
		%wfname = "institutions"												'Workfile name
		%filename = "varbase.csv"											'CSV source file
	
''''' PANEL SETTINGS

	%panelid = "code"														'Panel cross section identifier
	%date = "year"																'Panel date identifier
	%sample = "@all"														'Sample boundaries (= "@all" for full range)
	
''''' DATA ADJUSTMENTS SETTINGS

	%group = "gdppercapita index"										'Raw data to be transformed
	!logtransformation = 1													'Do log transformation? YES = 1 (resulting variable will be l{variable_name})
	!logdiftransformation = 1												'Do log difference transformation? YES = 1 (resulting variable will be ld{variable_name})
	!diftransformation = 0													'Do log difference transformation? YES = 1 (resulting variable will be d{variable_name})
	!delete = 0																	'Delete all the calculation objects? YES = 1 
	%sampler = "1 = 1"														'Additional restrictions in the sample, for full sample: 1 = 1
	
'''' VAR SETTINGS

	%cholesky	= "dlgdppercapita dlindex"								'List of endogenous VARIABLES (if needed, use log transformed data)
	%levels	= "lgdppercapita lindex"									'List of endogenous VARIABLES (if needed, use log transformed data)
	!endogenous = 2 														'Number of endogenous variables
	!lags = 1																	'Number of lags in VAR
	!reps = 1000 																'Number of repetitions for bootstrap
	!horizon = 10 																'Horizon of IRF reponses
	!initialshock = 1															'Set the user specified initial shock for IRFs
	!usesd = 1 																	'Use standard deviation of variables as initial shock? YES = 1 (overrides previous line)
	!ci = 1.645																	'Confidence intervals for bootstrapping (in standard errors)
	!drops = 10																	'How many cross-sections to drop in the bootstrapping each time
	!seed = 123456
	
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''' SECTION 2: WORKSPACE ORGANIZATION AND DATA TRANSFORMATION  ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

'''' CREATE WORKFILE

	cd {%dir}																	'Sets working director
	close {%wfname}.wf1													'Closes workfile (if open)
	wfopen(wf={%wfname},page=GMM,typ) {%filename}			'Creates new workfile

'''' SET PANEL
	
	pagestruct {%panelid} @datevar({%date})						'Structures panel data
	series crossid = @crossid											'Creates cross section identifiers
	scalar maxcross = @max(crossid)									'Stores number of cross sections

	
'''' PROCEEDS WITH DATA TRANSFORMATION

	for %z {%group}
		smpl @all if {%z} <> NA and {%z} > 0

		''''LOG TRANSFORMATION
			if !logtransformation = 1 then
				series l{%z} = log({%z})	
			endif		

		''''LOG DIFFERENCE TRANSFORMATION
			if !logdiftransformation = 1 then
				series dl{%z} = dlog({%z})
			endif				
		''''LOG DIFFERENCE TRANSFORMATION
			if !diftransformation = 1 then
				series d{%z} = d({%z})
			endif				
	next

'''' ORGANIZE GROUPS FOR EQUATIONS

	group endogenous
		for %z {%cholesky}
			endogenous.add {%z}
		next

		for !i=1 to endogenous.@count
			%lefthand{!i} = endogenous.@seriesname(!i)
			group eq_{%lefthand{!i}}
 		  		for !j=1 to !lags
						for !k=1 to endogenous.@count
							%righthand{!k} = endogenous.@seriesname(!k)
				   			eq_{%lefthand{!i}}.add {%righthand{!k}}(-{!j})
						next
		   		next
		next

'''' ORGANIZE INSTRUMENTS

		for !i=1 to endogenous.@count
			%lefthand{!i} = endogenous.@seriesname(!i)
			group inst_{%lefthand{!i}}
 		  		for !j=!lags+1 to (!lags+!lags+!lags-1)
						for !k=1 to endogenous.@count
							if !k <> !i then
								%righthand{!k} = endogenous.@seriesname(!k)
				   				inst_{%lefthand{!i}}.add {%righthand{!k}}(-{!j})
							endif
						next
		   		next
		next
	
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''' SECTION 3: RUN INDIVIDUAL REGRESSIONS AND ORGANIZE MATRICES OF COEFFICIENTS '''''''''''''''''''''''''''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

'''' BUILD UP EQUATIONS AND COLLECT COEFFICIENTS AND RESIDUALS

		rndseed !seed

		smpl @all if {%sampler} 

		group residuals

		for %k {%cholesky}
			equation gmm_{%k}.gmm(gmm=2sls) {%k} eq_{%k} @ @dyn({%k},-!lags-1) inst_{%k}
			matrix gamma_{%k} = gmm_{%k}.@coefs
			gmm_{%k}.makeresid r_{%k}
			residuals.add r_{%k}
		next

'''' CALCULATE VARIANCE COVARIANCE MATRIX

	stom(residuals, residuals_matrix)
	residuals_matrix = @transpose(residuals_matrix)
	sym varcov =  residuals_matrix * @transpose(residuals_matrix)

'''' CREATE VAR MATRICES, ONE PER LAG

		for !i = 1 to !lags
			matrix(!endogenous,!endogenous) gamma_{!i} = 0
			!z = 0
				for  %k {%cholesky}
					!z = !z + 1
					for !a = 1 to !endogenous 
						gamma_{!i}(!a,!z) = gamma_{%k}(!a+(!i-1)*!endogenous,1)
					next
				next
			gamma_{!i} = @transpose(gamma_{!i})
		next

'''' CREATE MODEL AND ALGORITHM AND SOLVE FOR STRUCTURAL MATRIX 

		scalar coefficients = !endogenous^2 - (!endogenous^2 - !endogenous)/2
		matrix structural = @cholesky(varcov)
		matrix structural_inv = @inverse(structural)
		matrix due_dilligence = structural * @transpose(structural)

'''' TRACE IMPULSE REPONSE FUNCTION

		''' SET INITIAL MATRICES (D0 and D1)

			matrix d0 = @identity(!endogenous,!endogenous)
			matrix d1 = gamma_1
			%irfloop = "d{!i} = d{!i1} * gamma_1"

		'' SET RECURSIVE PARAMETERS BASED ON LAGS
		
			if !lags > 1 then
				matrix d2 = d1 * gamma_1 + d0 * gamma_2
				%irfloop = "d{!i} = d{!i1} * gamma_1 + d{!i2} * gamma_2"
			endif 
	
			if !lags > 2 then
				matrix d3 = d2 * gamma_1 + d1 * gamma_2 + d0 * gamma_3
				%irfloop = "d{!i} = d{!i1} * gamma_1 + d{!i2} * gamma_2 + d{!i3} * gamma_3"
			endif 
	
			if !lags > 3 then
				matrix d4 = d3 * gamma_1 + d2 * gamma_2 + d1 * gamma_3 + d0 * gamma_4
				%irfloop = "d{!i} = d{!i1} * gamma_1 + d{!i2} * gamma_2 + d{!i3} * gamma_3 + d{!i4} * gamma_4"
			endif 
	
			if !lags > 4 then
				matrix d5 = d4 * gamma_1 + d3 * gamma_2 + d2 * gamma_3 + d1 * gamma_4 + d0 * gamma_5
				%irfloop = "d{!i} = d{!i1} * gamma_1 + d{!i2} * gamma_2 + d{!i3} * gamma_3 + d{!i4} * gamma_4 + d{!i5} * gamma_5"
			endif 
	
			if !lags > 5 then
				matrix d6 = d5 * gamma_1 + d4 * gamma_2 + d3 * gamma_3 + d2 * gamma_4 + d1 * gamma_5 + d1 * gamma_6
				%irfloop = "d{!i} = d{!i1} * gamma_1 + d{!i2} * gamma_2 + d{!i3} * gamma_3 + d{!i4} * gamma_4 + d{!i5} * gamma_5 + d{!i6} * gamma_6"
			endif 

		''' LOOP FOR REMAINING RECURSIVE SOLVING

			for !i = !lags+1 to !horizon
				for !k = 1 to !lags
					!i{!k} = !i - !k
				next
				matrix(!endogenous,!endogenous) {%irfloop}
			next

		'' TRANSFORM REDUCE-FORM MATRICES INTO STRUCTURAL MATRICES

			for !i = 0 to !horizon
				matrix(!endogenous,!endogenous) ce{!i} = d{!i} * structural
			next

''' SET SHOCKS FOR IMPULSE RESPONSES

		''' USER SELECTED SHOCK

			for !ss = 1 to !endogenous
				scalar shock{!ss} = {!initialshock}
			next

		'' STANDARD DEVIATION SHOCK

			if !usesd = 1 then
			!counter = 1
 				for %a {%cholesky}
					scalar shock{!counter} = @stdev({%a})
					!counter = !counter + 1
				next
			!counter = 0
			endif

		''' CREATE VECTOR OF SHOCKS

			for !ss = 1 to !endogenous
				vector(!endogenous) vshock{!ss} = 0
				vshock{!ss}({!ss}) = shock{!ss}
			next

		''' CREATE MATRIX OF RESPONSES TO SHOCK
			'' MUTIPLY STRUCTURAL MATRICES TO VECTOR
			'' SHOCKS

			for !ss = 1 to !endogenous
				for !dd = 0 to !horizon
					matrix x{!ss}{!dd} =  ce{!dd} * vshock{!ss}
				next
			next

		''' COLLECT RESPONSES IN A VECTOR

			for !ss = 1 to !endogenous
				matrix({!endogenous},!horizon+1) res{!ss}
				for !d = 0 to !horizon
					colplace(res{!ss},x{!ss}{!d}, !d+1)
				next
				res{!ss} = @transpose(res{!ss})
			next	

		''  STORE RESPONSES INTO VECTORS

			for !ss = 1 to !endogenous
				for !dd = 1 to !endogenous
					vector resv{!ss}{!dd} = @columnextract(res{!ss},{!dd})
				next
			next

	' RESCALE VECTORS WITH SET SHOCKS

		!rows = !horizon + 1

			for !ss = 1 to !endogenous
				for !dd = 1 to !endogenous
					vector(!rows) resvr{!ss}{!dd}
					for !kk = 1 to !rows
						resvr{!ss}{!dd}(!kk) = resv{!ss}{!dd}(!kk) / resv{!ss}{!ss}(1) * {!initialshock}			
					next
				next
			next
	
		matrix(!horizon+1,!endogenous*!endogenous) resp = 0
		
		!counter = 0
		for !ss = 1 to !endogenous
			for !dd = 1 to !endogenous
				!counter = !counter + 1
				matplace(resp,resvr{!ss}{!dd},1,{!counter})
			next
		next

	show resp.line(m)

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''' SECTION 4: STANDARD ERROR SIMULATION  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

for !b = 1 to !reps

'''' DROP 10% OF THE CROSS SECTIONS

		for !kk = 1 to !drops
			scalar rnd{!kk} = @round(@runif(@min(crossid),@max(crossid)))
				if !kk = 1 then
					string randomize = "crossid <> " + @str(rnd{!kk})
				else
					randomize = randomize + " and crossid <> " + @str(rnd{!kk})
				endif
		next
		
		smpl @all if {randomize} and {%sampler}

'''' BUILD UP EQUATIONS AND COLLECT COEFFICIENTS AND RESIDUALS


		group s_residuals

		for %k {%cholesky}
			equation s_gmm_{%k}.gmm(gmm=2sls) {%k} eq_{%k} @ @dyn({%k},-!lags-1) inst_{%k}
			matrix s_gamma_{%k} = s_gmm_{%k}.@coefs
			s_gmm_{%k}.makeresid s_res_{%k}
			s_residuals.add s_res_{%k}
		next

'''' CALCULATE VARIANCE COVARIANCE MATRIX

	stom(s_residuals, s_residuals_matrix)
	s_residuals_matrix = @transpose(s_residuals_matrix)
	sym s_varcov =  s_residuals_matrix * @transpose(s_residuals_matrix)

'''' CREATE VAR MATRICES, ONE PER LAG

		for !i = 1 to !lags
			matrix(!endogenous,!endogenous) s_gamma_{!i} = 0
			!z = 0
				for  %k {%cholesky}
					!z = !z + 1
					for !a = 1 to !endogenous 
						s_gamma_{!i}(!a,!z) = s_gamma_{%k}(!a+(!i-1)*!endogenous,1)
					next
				next
			s_gamma_{!i} = @transpose(s_gamma_{!i})
		next

'''' CREATE MODEL AND ALGORITHM AND SOLVE FOR STRUCTURAL MATRIX 

		matrix s_structural = @cholesky(s_varcov)
		matrix s_structural_inv = @inverse(s_structural)

'''' TRACE IMPULSE REPONSE FUNCTION

		''' SET INITIAL MATRICES (D0 and D1)

			matrix s_d0 = @identity(!endogenous,!endogenous)
			matrix s_d1 = s_gamma_1
			%irfloop = "s_d{!i} = s_d{!i1} * s_gamma_1"

		'' SET RECURSIVE PARAMETERS BASED ON LAGS
		
			if !lags > 1 then
				matrix s_d2 = s_d1 * s_gamma_1 + s_d0 * s_gamma_2
				%irfloop = "s_d{!i} = s_d{!i1} * s_gamma_1 + s_d{!i2} * s_gamma_2"
			endif 
	
			if !lags > 2 then
				matrix s_d3 = s_d2 * s_gamma_1 + s_d1 * s_gamma_2 + s_d0 * s_gamma_3
				%irfloop = "s_d{!i} = s_d{!i1} * s_gamma_1 + s_d{!i2} * s_gamma_2 + s_d{!i3} * s_gamma_3"
			endif 
	
			if !lags > 3 then
				matrix s_d4 = s_d3 * s_gamma_1 + s_d2 * s_gamma_2 + s_d1 * s_gamma_3 + s_d0 * s_gamma_4
				%irfloop = "s_d{!i} = s_d{!i1} * s_gamma_1 + s_d{!i2} * s_gamma_2 + s_d{!i3} * s_gamma_3 + s_d{!i4} * s_gamma_4"
			endif 
	
			if !lags > 4 then
				matrix s_d5 = s_d4 * s_gamma_1 + s_d3 * s_gamma_2 + s_d2 * s_gamma_3 + s_d1 * s_gamma_4 + s_d0 * s_gamma_5
				%irfloop = "s_d{!i} = s_d{!i1} * s_gamma_1 + s_d{!i2} * s_gamma_2 + s_d{!i3} * s_gamma_3 + s_d{!i4} * s_gamma_4 + s_d{!i5} * s_gamma_5"
			endif 
	
			if !lags > 5 then
				matrix s_d6 = s_d5 * s_gamma_1 + s_d4 * s_gamma_2 + s_d3 * s_gamma_3 + s_d2 * s_gamma_4 + s_d1 * s_gamma_5 + s_d1 * s_gamma_6
				%irfloop = "s_d{!i} = s_d{!i1} * s_gamma_1 + s_d{!i2} * s_gamma_2 + s_d{!i3} * s_gamma_3 + s_d{!i4} * s_gamma_4 + s_d{!i5} * s_gamma_5 + s_d{!i6} * s_gamma_6"
			endif 

		''' LOOP FOR REMAINING RECURSIVE SOLVING

			for !i = !lags+1 to !horizon
				for !k = 1 to !lags
					!i{!k} = !i - !k
				next
				matrix(!endogenous,!endogenous) {%irfloop}
			next

		'' TRANSFORM REDUCE-FORM MATRICES INTO STRUCTURAL MATRICES

			for !i = 0 to !horizon
				matrix(!endogenous,!endogenous) s_ce{!i} = s_d{!i} * s_structural
			next

''' SET SHOCKS FOR IMPULSE RESPONSES

		''' USER SELECTED SHOCK

			for !ss = 1 to !endogenous
				scalar s_shock{!ss} = {!initialshock}
			next

		'' STANDARD DEVIATION SHOCK

			if !usesd = 1 then
			!counter = 1
 				for %a {%cholesky}
					scalar s_shock{!counter} = @stdev({%a})
					!counter = !counter + 1
				next
			!counter = 0
			endif

		''' CREATE VECTOR OF SHOCKS

			for !ss = 1 to !endogenous
				vector(!endogenous) s_vshock{!ss} = 0
				s_vshock{!ss}({!ss}) = s_shock{!ss}
			next

		''' CREATE MATRIX OF RESPONSES TO SHOCK
			'' MUTIPLY STRUCTURAL MATRICES TO VECTOR
			'' SHOCKS

			for !ss = 1 to !endogenous
				for !dd = 0 to !horizon
					matrix s_x{!ss}{!dd} =  s_ce{!dd} * s_vshock{!ss}
				next
			next

		''' COLLECT RESPONSES IN A VECTOR

			for !ss = 1 to !endogenous
				matrix({!endogenous},!horizon+1) s_res{!ss}
				for !d = 0 to !horizon
					colplace(s_res{!ss},s_x{!ss}{!d}, !d+1)
				next
				s_res{!ss} = @transpose(s_res{!ss})
			next	

		''  STORE RESPONSES INTO VECTORS

			for !ss = 1 to !endogenous
				for !dd = 1 to !endogenous
					vector s_resv{!ss}{!dd} = @columnextract(s_res{!ss},{!dd})
				next
			next

	' RESCALE VECTORS WITH SET SHOCKS

		!rows = !horizon + 1

			for !ss = 1 to !endogenous
				for !dd = 1 to !endogenous
					vector(!rows) s_resvr{!ss}{!dd}
					for !kk = 1 to !rows
						s_resvr{!ss}{!dd}(!kk) = s_resv{!ss}{!dd}(!kk) / s_resv{!ss}{!ss}(1) * {!initialshock}			
					next
				next
			next
	
		matrix(!horizon+1,!endogenous*!endogenous) s_resp = 0
		
		!counter = 0
		for !ss = 1 to !endogenous
			for !dd = 1 to !endogenous
				!counter = !counter + 1
				matplace(s_resp,s_resvr{!ss}{!dd},1,{!counter})
			next
		next

'''' STORE COLLECTED RESPONSES IN SIMULATION MATRIX
							
	for !ss = 1 to !endogenous
		for !dd = 1 to !endogenous
			if !b = 1 then
			 	matrix(!rows,!reps) resvr{!ss}{!dd}_dist = 0
			endif
			matplace(resvr{!ss}{!dd}_dist, s_resvr{!ss}{!dd},1,!b)
		next
	next

next

''' CALCULATE STANDARD ERRORS AND PLOT CHART

	for !ss = 1 to !endogenous
		for !dd = 1 to !endogenous
			vector(!rows) resv{!ss}{!dd}_upper
			vector(!rows) resv{!ss}{!dd}_mid
			vector(!rows) resv{!ss}{!dd}_lower
			vector(!rows) resvr{!ss}{!dd}_upper
			vector(!rows) resvr{!ss}{!dd}_lower
			vector(!rows) sd{!ss}{!dd}
			for !i = 1 to !rows 
				sd{!ss}{!dd} = @abs(@stdev(@rowextract(resvr{!ss}{!dd}_dist,!i)))
				resvr{!ss}{!dd}_upper(!i) = resvr{!ss}{!dd}(!i) + !ci * sd{!ss}{!dd}(!i)
				resvr{!ss}{!dd}_lower(!i) = resvr{!ss}{!dd}(!i) - !ci * sd{!ss}{!dd}(!i) 
'				resv{!ss}{!dd}_mid(!i)= @quantile(@rowextract(resvr{%z}_b_dist,!i),0.5)
			next
		next
	next			

	string namelist = ""
		
	for !ss = 1 to !endogenous
		for !dd = 1 to !endogenous
			matrix(!rows,3) g{!ss}{!dd}
			matplace(g{!ss}{!dd} , resvr{!ss}{!dd},1,1)
			matplace(g{!ss}{!dd} , resvr{!ss}{!dd}_upper,1,2)
			matplace(g{!ss}{!dd} , resvr{!ss}{!dd}_lower,1,3)
			freeze(temp_chart{!ss}{!dd}) g{!ss}{!dd}.line
			temp_chart{!ss}{!dd}.option linepat	' need to set linepat
			temp_chart{!ss}{!dd}.elem(1) lcolor(blue) lpat(solid)
			temp_chart{!ss}{!dd}.elem(2) lcolor(red) lpat(dash1)
			temp_chart{!ss}{!dd}.elem(3) lcolor(red) lpat(dash1)
			temp_chart{!ss}{!dd}.legend(off)
			string title{!ss}{!dd} = "Response of " + endogenous.@seriesname({!dd}) + " to " + endogenous.@seriesname({!ss})
			temp_chart{!ss}{!dd}.addtext(t,font(Arial,16pt)) {title{!ss}{!dd}}
			temp_chart{!ss}{!dd}.draw(line,left.rgb(0,0,0)) 0
			string namelist = namelist + "temp_chart" + @str({!ss}{!dd}) + " "
		next
	next

		freeze(charts) {namelist}
		show charts

''' DELETE TEMPORARY VARIABLES

	if !delete = 1 then

		for !kk = 0 to !horizon
			delete d{!kk}
			delete ce{!kk}
			for !mm = 1 to !endogenous
				delete x{!mm}{!kk}
			next			
		next

		for !qq = 1 to !endogenous
			delete res{!qq}
			delete vshock{!qq}
			delete shock{!qq}
			for !ss = 1 to !endogenous
				delete resv{!qq}{!ss}
				delete resv{!qq}{!ss}_lower
				delete resv{!qq}{!ss}_mid
				delete resv{!qq}{!ss}_upper
				delete resvr{!qq}{!ss}
				delete resvr{!qq}{!ss}_dist
				delete resvr{!qq}{!ss}_lower
				delete resvr{!qq}{!ss}_upper
				delete g{!qq}{!ss}
			 next
		next

		for !xx = 1 to !lags
			delete gamma_{!xx}
		next

 		for %kk {%cholesky}
			delete r_{%kk}
			delete gamma_{%kk}
			delete eq_{%kk}
			delete inst_{%kk}
		next

		delete maxcross
		delete title*
		delete sd*
		delete rnd*
		delete structural
		delete structural_inv
		delete endogenous
		delete due_dilligence
		delete varcov
		delete temp_*
		delete s_*
	endif

stop
