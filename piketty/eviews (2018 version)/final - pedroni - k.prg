
''''''  	PANEL STRUCTURAL VAR WITH HETEROGENEOUS DYNAMICS AND CONFIDENCE INTERVALS FOR MEDIANS	            
'''''' 
''''''		Coded by Carlos Góes (andregoes@gmail.com), International Monetary Fund
'''''' 		
''''''		This code implements the model developed for
''''''		Góes, C (2016) "Testing Piketty: Evidence from Structural Panel VARs with Heterogeneous Dynamics." IMF Working Paper
''''''		with the structural Panel VAR technique described in
''''''		Pedroni, Peter (2013). 'Structural Panel VARs". Econometrics 1, pp. 180-206
''''''
''''''		Please cite both papers if you use this code
''''''
''''''		This file has been tested and is compatible with Eviews 7.2 and Eviews 9.5

				
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''' SECTION 1: USER INPUTS '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

''''' DIRECTORY SETTINGS

	%dir = "U:\Research\Inequality\"									'Working directory
	%wfname = "klevels_test"													'Workfile name
	%filename = "fkdatabasetax.csv"										'CSV source file
	%save = "klevels_test"

''''' PANEL SETTINGS

	%panelid = "country"														'Panel cross section identifier
	%date = "year"																'Panel date identifier
	%sample = "1 = 1"														'Sample boundaries ("1 = 1" for full range)
	
''''' DATA ADJUSTMENTS SETTINGS

	%group = "rg2 kshare"													'Raw data to be transformed
	!fixedeffects = 1															'Demean for fixed effects? YES =1 (will set {variable_name} to f{variable_name})
	!logtransformation = 0													'Do log transformation? YES = 1 (resulting variable will be l{variable_name})
	!logdiftransformation = 0												'Do log difference transformation? YES = 1 (resulting variable will be ld{variable_name})
	!diftransformation = 0													'Do log difference transformation? YES = 1 (resulting variable will be d{variable_name})
	!delete = 0																	'Delete all the calculation objects? YES = 1 
	
'''' VAR SETTINGS

	!endogenous = 2 														'Number of endogenous variables
	%cholesky	= "frg2 fkshare"												'List of endogenous VARIABLES (if needed, use log transformed data)
	%cholesky_0	= "frg2_0 fkshare_0"									'Same as above, but with '_0' after variable
	%resid	= "r_frg2 r_fkshare"												'List of residuals
	%resid1	= "r_frg2 <> na"														'List just the first residual (this is used for bootstrapping
	!maxlags = 3															'Number of lags in VAR
	!ic = 2																		'Lag-length information criteria (2 for LR)
	!horizon = 11													'Horizon of IRF reponses

'''' CHARTS SETTINGS

	!marginal =1																' Plot marginal IRFs? YES = 1
	!cummulative = 0															' Plot cummulative IRFs? YES = 1
	
'''' BOOTSTRAP SEETINGS

	!boot = 1 																	'Perform bootstrapping procedure? YES = 1
	!ci = 1.96																	'Confidence interval (in standard deviations)
	!reps = 500	 																'Number of repetitions for bootstrap	

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''' SECTION 2: WORKSPACE ORGANIZATION AND DATA TRANSFORMATION  ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

'''' CREATE WORKFILE

	cd {%dir}																	'Sets working director
	close {%wfname}.wf1													'Closes workfile (if open)
	wfopen(wf={%wfname},page=Pedroni,typ) {%filename}			'Creates new workfile

'''' SET PANEL
	
	pagestruct {%panelid} @datevar({%date})						'Structures panel data
	series crossid = @crossid											'Creates cross section identifiers
	scalar maxcross = @max(crossid)									'Stores number of cross sections
	scalar periods = @max(year) - @min(year) + 1
	

'''' PROCEEDS WITH DATA TRANSFORMATION

	for %z {%group}
		smpl @all if {%z} <> NA
		
		if !fixedeffects = 1 then
			''''LOG TRANSFORMATION
				if !logtransformation = 1 then
	  			  series lf{%z} = log({%z})	
				  series bar{%z} = @meansby(lf{%z},crossid,"@all")	
				  series fl{%z} = l{%z} - bar{%z}
				endif

			''''LOG DIFFERENCE TRANSFORMATION
				if !logdiftransformation = 1 then
	  			  series lf{%z} = log({%z})	
				  series bar{%z} = @meansby(lf{%z},crossid,"@all")	
				  series fl{%z} = lf{%z} - bar{%z}
				  series dlf{%z} = d(lf{%z})
				endif			
	
			''''DIFFERENCE TRANSFORMATION
				if !diftransformation = 1 then
				    series bar{%z} = @meansby({%z},crossid,"@all")	
				    series f{%z} = {%z} - bar{%z}
				   series df{%z} = d(f{%z})
				endif				

				    series bar{%z} = @meansby({%z},crossid,"@all")	
				    series f{%z} = {%z} - bar{%z}
		else 
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
		endif
	next

	group endogenous
		for %z {%cholesky}
			endogenous.add {%z}
		next

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''' SECTION 3: RUN INDIVIDUAL REGRESSIONS AND ORGANIZE MATRICES OF COEFFICIENTS '''''''''''''''''''''''''''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''' CALCULATE TIME EFFECTS

group time

for %z {%cholesky}
		series c{%z} = @meansby({%z},@cellid,"@all")	
		series dc{%z} = d(c{%z})	
		time.add dc{%z}
next

'' CREATE MATRIX OF RESPONSES

	for !ss = 1 to !endogenous
		for !dd = 1 to !endogenous
			matrix(!horizon,maxcross) mirf_ind_{!ss}{!dd} = 0
			matrix(!horizon,maxcross) mirfa_ind_{!ss}{!dd} = 0
			matrix(!horizon,maxcross) mirf_id_{!ss}{!dd} = 0
			matrix(!horizon,maxcross) mirfa_id_{!ss}{!dd} = 0
			matrix(!horizon,maxcross) mirf_c_{!ss}{!dd} = 0
			matrix(!horizon,maxcross) mirfa_c_{!ss}{!dd} = 0
		next
	next

''RUN COMMON SHOCKS REGRESSION (TIME EFFECTS)

	'' DETERMINE LAG LENGTH

		var common.ls 1 1 time
		common.laglen(!maxlags, vname = lags)
		!laglen = lags(!ic)
		delete lags

		if !laglen = 0 then
			!laglen = 1
		endif

		var common.ls 1 !laglen time
		common.impulse(!horizon,matbys=irf_common, t) 
		common.impulse(!horizon,matbys=irfa_common, t,a) 
		close common
		
		!counter = 1
		for !kk = 1 to !endogenous
			for !zz = 1 to !endogenous
				vector(!horizon) irf_c_{!kk}{!zz} = 	@columnextract(irf_common,!counter)
				!counter = !counter + 1
			next
		next

		common.makeresid {%resid}
		group resid_g {%resid}
		stomna(resid_g,resid_t)
		sym varcov = common.@residcov
		matrix structural = @cholesky(varcov)
		resid_t = resid_t * structural

		matrix(periods,!endogenous) resid_c
		while !kk < periods + 1
			 matplace(resid_c,@rowextract(resid_t,{!kk}),{!kk},1)
			!kk = !kk + 1
		wend

		for !zz = 1 to !endogenous
			vector(!horizon) resid_vc_{!zz} = @columnextract(resid_c,{!zz})
			mtos(resid_vc_{!zz}, resid_c_{!zz})
			resid_c_{!zz} = @meansby(resid_c_{!zz},@cellid,"@all")	
			resid_c_{!zz} = resid_c_{!zz}  / @stdev(resid_c_{!zz})
		next

'''' RUN INDIVIDUAL REGRESSIONS

for !ind = 1 to maxcross 

		smpl @all if crossid = !ind and {%sample}

	 	'' DETERMINE LAG LENGTH

	 	var individual_{!ind}.ls 1 1 {%cholesky}
		individual_{!ind}.laglen(!maxlags, vname = lags)
		!laglen = lags(!ic)
		delete lags

		if !laglen = 0 then
			!laglen = 1
		endif

		''  ESTIMATE REDUCED FORM-VAR

		var individual_{!ind}.ls 1 !laglen {%cholesky}
		individual_{!ind}.impulse(!horizon,matbys=irf_{!ind}, t) 
		individual_{!ind}.impulse(!horizon,matbys=irfa_{!ind}, t,a) 
		close individual_{!ind}

		'' COLLECT IRF AND SCALE THEM TO UNIT

		!counter = 1
		for !ss = 1 to !endogenous
			for !dd = 1 to !endogenous
				vector(!horizon) irf_ind_{!ind}_{!ss}{!dd} = @columnextract(irf_{!ind},!counter)
				vector(!horizon) irfa_ind_{!ind}_{!ss}{!dd} = @columnextract(irfa_{!ind},!counter)
				!counter = {!counter} + 1
			next
		next

		for !ss = 1 to !endogenous
			for !dd = 1 to !endogenous
				irf_ind_{!ind}_{!ss}{!dd} = irf_ind_{!ind}_{!ss}{!dd} / irf_ind_{!ind}_{!ss}{!ss}(1)
				irfa_ind_{!ind}_{!ss}{!dd} = irfa_ind_{!ind}_{!ss}{!dd} / irfa_ind_{!ind}_{!ss}{!ss}(1)
				colplace(mirf_ind_{!ss}{!dd},irf_ind_{!ind}_{!ss}{!dd},{!ind})
				colplace(mirfa_ind_{!ss}{!dd},irfa_ind_{!ind}_{!ss}{!dd},{!ind})
			next
		next

		'' COLLECT RESIDUALS AND STRUCTURAL MATRIX, TRANSFORM RESIDUALS INTO STRUCTURAL
		
		individual_{!ind}.makeresid {%resid}
		group resid_g{!ind} {%resid}
		stomna(resid_g{!ind},resid_m_{!ind})
		sym varcov = individual_{!ind}.@residcov
		matrix structural = @inverse(@cholesky(varcov))
		resid_m_{!ind} = resid_m_{!ind} * structural

	'' RUN OLS REGRESSIONS (W/O CONSTANT) BETWEEN COMMON AND INDIVIDUAL RESIDUALS
		'AND CREATE LOADING MATRICES
		
		matrix(!endogenous,!endogenous) mloading_{!ind} = 0
		for !zz = 1 to !endogenous
			vector(!horizon) resid_v{!ind}_{!zz} = @columnextract(resid_m_{!ind},{!zz})
			mtos(resid_v{!ind}_{!zz}, resid_{!ind}_{!zz})
			resid_{!ind}_{!zz} = resid_{!ind}_{!zz} / @stdev(resid_{!ind}_{!zz})
			equation loading{!zz}.ls resid_{!ind}_{!zz} resid_c_{!zz}
			mloading_{!ind}({!zz},{!zz}) = loading{!zz}.@coefs(1)
		next

	'' DECOMPOSE IRFs USING LOADING MATRICES

		matrix mloadingt_{!ind} = @sqrt(@identity(!endogenous) - mloading_{!ind} * @transpose(mloading_{!ind}))
	
		for !ss = 1 to !endogenous
			for !dd = 1 to !endogenous
				vector(!horizon) irf_c_{!ind}_{!ss}{!dd} = mloading_{!ind}(!ss,!ss) * irf_ind_{!ind}_{!ss}{!dd}
				vector(!horizon) irf_id_{!ind}_{!ss}{!dd} = irf_ind_{!ind}_{!ss}{!dd} - irf_c_{!ind}_{!ss}{!dd}
				vector(!horizon) irfa_c_{!ind}_{!ss}{!dd} = mloading_{!ind}(!ss,!ss) * irfa_ind_{!ind}_{!ss}{!dd}
				vector(!horizon) irfa_id_{!ind}_{!ss}{!dd} = irfa_ind_{!ind}_{!ss}{!dd} - irfa_c_{!ind}_{!ss}{!dd}
				colplace(mirf_id_{!ss}{!dd},irf_id_{!ind}_{!ss}{!dd},{!ind})
				colplace(mirf_c_{!ss}{!dd},irf_c_{!ind}_{!ss}{!dd},{!ind})
				colplace(mirfa_id_{!ss}{!dd},irfa_id_{!ind}_{!ss}{!dd},{!ind})
				colplace(mirfa_c_{!ss}{!dd},irfa_c_{!ind}_{!ss}{!dd},{!ind})
			next
		next

next

''' CALCULATE MEDIAN AND QUARTILES, PLOT CHARTS

close @objects

	''' MARGINAL RESPONSES

if !marginal = 1 then

	for %z ind id c
		for !ss = 1 to !endogenous
			for !dd = 1 to !endogenous
				vector(!horizon) gupper_{%z}_{!ss}{!dd}
				vector(!horizon) gmid_{%z}_{!ss}{!dd}
				vector(!horizon) glower_{%z}_{!ss}{!dd}
				vector(!horizon) gaverage_{%z}_{!ss}{!dd}
				for !i = 1 to !horizon 
					gupper_{%z}_{!ss}{!dd}(!i) = @quantile(@rowextract(mirf_{%z}_{!ss}{!dd},(!i)),0.75)
					gmid_{%z}_{!ss}{!dd}(!i)= @quantile(@rowextract(mirf_{%z}_{!ss}{!dd},(!i)),0.5)
					glower_{%z}_{!ss}{!dd}(!i) = @quantile(@rowextract(mirf_{%z}_{!ss}{!dd},(!i)),0.25)
					gaverage_{%z}_{!ss}{!dd}(!i) = @mean(@rowextract(mirf_{%z}_{!ss}{!dd},(!i)))
				next
			next
		next			
	next

		string namelist = ""
			
		for !ss = 1 to !endogenous
			for !dd = 1 to !endogenous
				matrix(!horizon,4) gind{!ss}{!dd}
				matplace(gind{!ss}{!dd} , gupper_ind_{!ss}{!dd},1,1)
				matplace(gind{!ss}{!dd} , gmid_ind_{!ss}{!dd},1,2)
				matplace(gind{!ss}{!dd} , glower_ind_{!ss}{!dd},1,3)
				matplace(gind{!ss}{!dd} , gaverage_ind_{!ss}{!dd},1,4)
				freeze(temp_chartind{!ss}{!dd}) gind{!ss}{!dd}.line
				temp_chartind{!ss}{!dd}.option linepat	' need to set linepat
				temp_chartind{!ss}{!dd}.elem(1) lcolor(red) lpat(dash1)
				temp_chartind{!ss}{!dd}.elem(2) lcolor(blue) lpat(solid)
				temp_chartind{!ss}{!dd}.elem(3) lcolor(red) lpat(dash1)
				temp_chartind{!ss}{!dd}.elem(4) lcolor(black) lpat(solid)
				temp_chartind{!ss}{!dd}.setelem(1) legend("75% percentile")
				temp_chartind{!ss}{!dd}.setelem(2) legend("Median")
				temp_chartind{!ss}{!dd}.setelem(3) legend("25% percentile")
				temp_chartind{!ss}{!dd}.setelem(4) legend("Average")
				string title{!ss}{!dd} = "Composite response of " + endogenous.@seriesname({!dd}) + " to " + endogenous.@seriesname({!ss})
				temp_chartind{!ss}{!dd}.addtext(t,font(Arial,16pt)) {title{!ss}{!dd}}
				temp_chartind{!ss}{!dd}.draw(line,left.rgb(0,0,0)) 0
				string namelist = namelist + "temp_chartind" + @str({!ss}{!dd}) + " "
			next
		next

		freeze(chart_composite) {namelist}
		show chart_composite

		string namelist = ""

		for !ss = 1 to !endogenous
			for !dd = 1 to !endogenous
				matrix(!horizon,4) gc{!ss}{!dd}
				matplace(gc{!ss}{!dd} , gupper_c_{!ss}{!dd},1,1)
				matplace(gc{!ss}{!dd} , gmid_c_{!ss}{!dd},1,2)
				matplace(gc{!ss}{!dd} , glower_c_{!ss}{!dd},1,3)
				matplace(gc{!ss}{!dd} , gaverage_c_{!ss}{!dd},1,4)
				freeze(temp_chartc{!ss}{!dd}) gc{!ss}{!dd}.line
				temp_chartc{!ss}{!dd}.option linepat	' need to set linepat
				temp_chartc{!ss}{!dd}.elem(1) lcolor(red) lpat(dash1)
				temp_chartc{!ss}{!dd}.elem(2) lcolor(blue) lpat(solid)
				temp_chartc{!ss}{!dd}.elem(3) lcolor(red) lpat(dash1)
				temp_chartc{!ss}{!dd}.elem(4) lcolor(black) lpat(solid)
				temp_chartc{!ss}{!dd}.setelem(1) legend("75% percentile")
				temp_chartc{!ss}{!dd}.setelem(2) legend("Median")
				temp_chartc{!ss}{!dd}.setelem(3) legend("25% percentile")
				temp_chartc{!ss}{!dd}.setelem(4) legend("Average")
				string title{!ss}{!dd} = "Common response of " + endogenous.@seriesname({!dd}) + " to " + endogenous.@seriesname({!ss})
				temp_chartc{!ss}{!dd}.addtext(t,font(Arial,16pt)) {title{!ss}{!dd}}
				temp_chartc{!ss}{!dd}.draw(line,left.rgb(0,0,0)) 0
				string namelist = namelist + "temp_chartc" + @str({!ss}{!dd}) + " "
			next
		next

		freeze(chart_comm) {namelist}
		show chart_comm

		string namelist = ""

		for !ss = 1 to !endogenous
			for !dd = 1 to !endogenous
				matrix(!horizon,4) gid{!ss}{!dd}
				matplace(gid{!ss}{!dd} , gupper_id_{!ss}{!dd},1,1)
				matplace(gid{!ss}{!dd} , gmid_id_{!ss}{!dd},1,2)
				matplace(gid{!ss}{!dd} , glower_id_{!ss}{!dd},1,3)
				matplace(gid{!ss}{!dd} , gaverage_id_{!ss}{!dd},1,4)
				freeze(temp_chartid{!ss}{!dd}) gid{!ss}{!dd}.line
				temp_chartid{!ss}{!dd}.option linepat	' need to set linepat
				temp_chartid{!ss}{!dd}.elem(1) lcolor(red) lpat(dash1)
				temp_chartid{!ss}{!dd}.elem(2) lcolor(blue) lpat(solid)
				temp_chartid{!ss}{!dd}.elem(3) lcolor(red) lpat(dash1)
				temp_chartid{!ss}{!dd}.elem(4) lcolor(black) lpat(solid)
				temp_chartid{!ss}{!dd}.setelem(1) legend("75% percentile")
				temp_chartid{!ss}{!dd}.setelem(2) legend("Median")
				temp_chartid{!ss}{!dd}.setelem(3) legend("25% percentile")
				temp_chartid{!ss}{!dd}.setelem(4) legend("Average")
				string title{!ss}{!dd} = "Idiosyncratic response of " + endogenous.@seriesname({!dd}) + " to " + endogenous.@seriesname({!ss})
				temp_chartid{!ss}{!dd}.addtext(t,font(Arial,16pt)) {title{!ss}{!dd}}
				temp_chartid{!ss}{!dd}.draw(line,left.rgb(0,0,0)) 0
				string namelist = namelist + "temp_chartid" + @str({!ss}{!dd}) + " "
			next
		next

		freeze(chart_idio) {namelist}
		show chart_idio

endif

	''' ACCUMULATED RESPONSES

if !cummulative = 1 then

	for %z ind id c
		for !ss = 1 to !endogenous
			for !dd = 1 to !endogenous
				vector(!horizon) guppera_{%z}_{!ss}{!dd}
				vector(!horizon) gmida_{%z}_{!ss}{!dd}
				vector(!horizon) glowera_{%z}_{!ss}{!dd}
				vector(!horizon) gaveragea_{%z}_{!ss}{!dd}
				for !i = 1 to !horizon 
					guppera_{%z}_{!ss}{!dd}(!i) = @quantile(@rowextract(mirfa_{%z}_{!ss}{!dd},(!i)),0.75)
					gmida_{%z}_{!ss}{!dd}(!i)= @quantile(@rowextract(mirfa_{%z}_{!ss}{!dd},(!i)),0.5)
					glowera_{%z}_{!ss}{!dd}(!i) = @quantile(@rowextract(mirfa_{%z}_{!ss}{!dd},(!i)),0.25)
					gaveragea_{%z}_{!ss}{!dd}(!i) = @mean(@rowextract(mirfa_{%z}_{!ss}{!dd},(!i)))
				next
			next
		next			
	next

		string namelist = ""
			
		for !ss = 1 to !endogenous
			for !dd = 1 to !endogenous
				matrix(!horizon,4) gind{!ss}{!dd}
				matplace(gind{!ss}{!dd} , guppera_ind_{!ss}{!dd},1,1)
				matplace(gind{!ss}{!dd} , gmida_ind_{!ss}{!dd},1,2)
				matplace(gind{!ss}{!dd} , glowera_ind_{!ss}{!dd},1,3)
				matplace(gind{!ss}{!dd} , gaveragea_ind_{!ss}{!dd},1,4)
				freeze(temp_chartaind{!ss}{!dd}) gind{!ss}{!dd}.line
				temp_chartaind{!ss}{!dd}.option linepat	' need to set linepat
				temp_chartaind{!ss}{!dd}.elem(1) lcolor(red) lpat(dash1)
				temp_chartaind{!ss}{!dd}.elem(2) lcolor(blue) lpat(solid)
				temp_chartaind{!ss}{!dd}.elem(3) lcolor(red) lpat(dash1)
				temp_chartaind{!ss}{!dd}.elem(4) lcolor(black) lpat(solid)
				temp_chartaind{!ss}{!dd}.setelem(1) legend("75% percentile")
				temp_chartaind{!ss}{!dd}.setelem(2) legend("Median")
				temp_chartaind{!ss}{!dd}.setelem(3) legend("25% percentile")
				temp_chartaind{!ss}{!dd}.setelem(4) legend("Average")
				string title{!ss}{!dd} = "Accumulated composite response of " + endogenous.@seriesname({!dd}) + " to " + endogenous.@seriesname({!ss})
				temp_chartaind{!ss}{!dd}.addtext(t,font(Arial,16pt)) {title{!ss}{!dd}}
				temp_chartaind{!ss}{!dd}.draw(line,left.rgb(0,0,0)) 0
				string namelist = namelist + "temp_chartaind" + @str({!ss}{!dd}) + " "
			next
		next

		freeze(charta_composite) {namelist}
		show charta_composite

		string namelist = ""

		for !ss = 1 to !endogenous
			for !dd = 1 to !endogenous
				matrix(!horizon,4) gc{!ss}{!dd}
				matplace(gc{!ss}{!dd} , guppera_c_{!ss}{!dd},1,1)
				matplace(gc{!ss}{!dd} , gmida_c_{!ss}{!dd},1,2)
				matplace(gc{!ss}{!dd} , glowera_c_{!ss}{!dd},1,3)
				matplace(gc{!ss}{!dd} , gaveragea_c_{!ss}{!dd},1,4)
				freeze(temp_chartac{!ss}{!dd}) gc{!ss}{!dd}.line
				temp_chartac{!ss}{!dd}.option linepat	' need to set linepat
				temp_chartac{!ss}{!dd}.elem(1) lcolor(red) lpat(dash1)
				temp_chartac{!ss}{!dd}.elem(2) lcolor(blue) lpat(solid)
				temp_chartac{!ss}{!dd}.elem(3) lcolor(red) lpat(dash1)
				temp_chartac{!ss}{!dd}.elem(4) lcolor(black) lpat(solid)
				temp_chartac{!ss}{!dd}.setelem(1) legend("75% percentile")
				temp_chartac{!ss}{!dd}.setelem(2) legend("Median")
				temp_chartac{!ss}{!dd}.setelem(3) legend("25% percentile")
				temp_chartac{!ss}{!dd}.setelem(4) legend("Average")
				string title{!ss}{!dd} = "Accumulated common response of " + endogenous.@seriesname({!dd}) + " to " + endogenous.@seriesname({!ss})
				temp_chartac{!ss}{!dd}.addtext(t,font(Arial,16pt)) {title{!ss}{!dd}}
				temp_chartac{!ss}{!dd}.draw(line,left.rgb(0,0,0)) 0
				string namelist = namelist + "temp_chartac" + @str({!ss}{!dd}) + " "
			next
		next

		freeze(charta_comm) {namelist}
		show charta_comm

		string namelist = ""

		for !ss = 1 to !endogenous
			for !dd = 1 to !endogenous
				matrix(!horizon,4) gid{!ss}{!dd}
				matplace(gid{!ss}{!dd} , guppera_id_{!ss}{!dd},1,1)
				matplace(gid{!ss}{!dd} , gmida_id_{!ss}{!dd},1,2)
				matplace(gid{!ss}{!dd} , glowera_id_{!ss}{!dd},1,3)
				matplace(gid{!ss}{!dd} , gaveragea_id_{!ss}{!dd},1,4)
				freeze(temp_chartaid{!ss}{!dd}) gid{!ss}{!dd}.line
				temp_chartaid{!ss}{!dd}.option linepat	' need to set linepat
				temp_chartaid{!ss}{!dd}.elem(1) lcolor(red) lpat(dash1)
				temp_chartaid{!ss}{!dd}.elem(2) lcolor(blue) lpat(solid)
				temp_chartaid{!ss}{!dd}.elem(3) lcolor(red) lpat(dash1)
				temp_chartaid{!ss}{!dd}.elem(4) lcolor(black) lpat(solid)
				temp_chartaid{!ss}{!dd}.setelem(1) legend("75% percentile")
				temp_chartaid{!ss}{!dd}.setelem(2) legend("Median")
				temp_chartaid{!ss}{!dd}.setelem(3) legend("25% percentile")
				temp_chartaid{!ss}{!dd}.setelem(4) legend("Average")
				string title{!ss}{!dd} = "Accumulated idiosyncratic response of " + endogenous.@seriesname({!dd}) + " to " + endogenous.@seriesname({!ss})
				temp_chartaid{!ss}{!dd}.addtext(t,font(Arial,16pt)) {title{!ss}{!dd}}
				temp_chartaid{!ss}{!dd}.draw(line,left.rgb(0,0,0)) 0
				string namelist = namelist + "temp_chartaid" + @str({!ss}{!dd}) + " "
			next
		next

		freeze(charta_idio) {namelist}
		show charta_idio

endif

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''' SECTION 4: BOOTSTRAPPING ALGORITHM '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

if !boot = 1 then

'' Create models and strings for new variables

'calculate predicted values

smpl @all
for %a {%cholesky}
	series {%a}_hat = {%a} - r_{%a}
	series {%a}_0 = {%a}_hat 
next

for !ind = 1 to maxcross 
	smpl @all if crossid = !ind and {%sample}
	individual_{!ind}.makemodel(mod{!ind})
next

string residuals = ""
string solve = ""

for !k=1 to !endogenous
	string residuals = residuals + endogenous.@seriesname({!k}) + "_a "
	string solve = residuals + endogenous.@seriesname({!k}) + "_0m "
next

for %z ind id c
	for !ss = 1 to !endogenous
		for !dd = 1 to !endogenous
			matrix(!horizon,!reps) b_gupper_{%z}_{!ss}{!dd}
			matrix(!horizon,!reps) b_gmid_{%z}_{!ss}{!dd}
			matrix(!horizon,!reps) b_glower_{%z}_{!ss}{!dd}
			matrix(!horizon,!reps) b_gaverage_{%z}_{!ss}{!dd}
			matrix(!horizon,!reps) b_guppera_{%z}_{!ss}{!dd}
			matrix(!horizon,!reps) b_gmida_{%z}_{!ss}{!dd}
			matrix(!horizon,!reps) b_glowera_{%z}_{!ss}{!dd}
			matrix(!horizon,!reps) b_gaveragea_{%z}_{!ss}{!dd}
		next
	next			
next

for !rep=1 to !reps

	'' CREATE MATRIX OF RESPONSES
	
		for !ss = 1 to !endogenous
			for !dd = 1 to !endogenous
				matrix(!horizon,maxcross) b{!rep}_mirf_ind_{!ss}{!dd} = 0
				matrix(!horizon,maxcross) b{!rep}_mirfa_ind_{!ss}{!dd} = 0
				matrix(!horizon,maxcross) b{!rep}_mirf_id_{!ss}{!dd} = 0
				matrix(!horizon,maxcross) b{!rep}_mirfa_id_{!ss}{!dd} = 0
				matrix(!horizon,maxcross) b{!rep}_mirf_c_{!ss}{!dd} = 0
				matrix(!horizon,maxcross) b{!rep}_mirfa_c_{!ss}{!dd} = 0
			next
		next
	
	''RUN COMMON SHOCKS REGRESSION (TIME EFFECTS)
	
		'' DETERMINE LAG LENGTH
	
			var b{!rep}_common.ls 1 1 time
			b{!rep}_common.laglen(!maxlags, vname = lags)
			!laglen = lags(!ic)
			delete lags

			if !laglen = 0 then
				!laglen = 1
			endif
	
			var b{!rep}_common.ls 1 !laglen time
			b{!rep}_common.impulse(!horizon,matbys=b{!rep}_irf_common, t) 
			b{!rep}_common.impulse(!horizon,matbys=b{!rep}_irfa_common, t,a) 
			close b{!rep}_common

			!counter = 1
			for !kk = 1 to !endogenous
				for !zz = 1 to !endogenous
					vector(!horizon) b{!rep}_irf_c_{!kk}{!zz} = 	@columnextract(b{!rep}_irf_common,!counter)
					!counter = !counter + 1
				next
			next
	
			b{!rep}_common.makeresid {%resid}
			group b{!rep}_resid_g {%resid}
			stomna(b{!rep}_resid_g,b{!rep}_resid_t)
			sym b{!rep}_varcov = b{!rep}_common.@residcov
			matrix b{!rep}_structural = @cholesky(b{!rep}_varcov)
			b{!rep}_resid_t = b{!rep}_resid_t * b{!rep}_structural
	
			matrix(periods-1,!endogenous) b{!rep}_resid_c

			!kk = 1
			while !kk < periods-1
			 	matplace(b{!rep}_resid_c,@rowextract(b{!rep}_resid_t,{!kk}),{!kk},1)
				!kk = !kk + 1
			wend

			smpl @all 
	
			for !zz = 1 to !endogenous
				vector(!horizon) b{!rep}_resid_vc_{!zz} = @columnextract(b{!rep}_resid_c,{!zz})
				mtos(b{!rep}_resid_vc_{!zz}, b{!rep}_resid_c_{!zz})
				b{!rep}_resid_c_{!zz} = @meansby(b{!rep}_resid_c_{!zz},@cellid,"@all")	
				b{!rep}_resid_c_{!zz} = b{!rep}_resid_c_{!zz}  / @stdev(b{!rep}_resid_c_{!zz})
			next

	'''' RUN INDIVIDUAL REGRESSIONS
	
	for !ind = 1 to maxcross 

			smpl @all if crossid = !ind and {%resid1}
			resid_g{!ind}.resample {residuals}

' 			smpl @all if crossid = !ind ' and {%resid1}
' 			mod{!ind}.solve
' 			smpl @all if crossid = !ind and {%sample}

			for %a {%cholesky}
				{%a}_0 = {%a}_hat + {%a}_a
			next

	 		'' DETERMINE LAG LENGTH
	
	 		var b{!rep}_individual_{!ind}.ls 1 1 {%cholesky_0}
			b{!rep}_individual_{!ind}.laglen(!maxlags, vname = lags)
			!laglen = lags(!ic)
			delete lags

			if !laglen = 0 then
				!laglen = 1
			endif
	
			''  ESTIMATE REDUCED FORM-VAR
	
			var b{!rep}_individual_{!ind}.ls 1 !laglen {%cholesky_0}
			b{!rep}_individual_{!ind}.impulse(!horizon,matbys=b{!rep}_irf_{!ind}, t) 
			b{!rep}_individual_{!ind}.impulse(!horizon,matbys=b{!rep}_irfa_{!ind}, t,a) 
			close b{!rep}_individual_{!ind}
	
			'' COLLECT IRF AND SCALE THEM TO UNIT
	
			!counter = 1
			for !ss = 1 to !endogenous
				for !dd = 1 to !endogenous
					vector(!horizon) b{!rep}_irf_ind_{!ind}_{!ss}{!dd} = @columnextract(b{!rep}_irf_{!ind},!counter)
					vector(!horizon) b{!rep}_irfa_ind_{!ind}_{!ss}{!dd} = @columnextract(b{!rep}_irfa_{!ind},!counter)
					!counter = {!counter} + 1
				next
			next

			for !ss = 1 to !endogenous
				for !dd = 1 to !endogenous
					b{!rep}_irf_ind_{!ind}_{!ss}{!dd} = b{!rep}_irf_ind_{!ind}_{!ss}{!dd} / b{!rep}_irf_ind_{!ind}_{!ss}{!ss}(1)
					b{!rep}_irfa_ind_{!ind}_{!ss}{!dd} = b{!rep}_irfa_ind_{!ind}_{!ss}{!dd} / b{!rep}_irfa_ind_{!ind}_{!ss}{!ss}(1)
					colplace(b{!rep}_mirf_ind_{!ss}{!dd},b{!rep}_irf_ind_{!ind}_{!ss}{!dd},{!ind})
					colplace(b{!rep}_mirfa_ind_{!ss}{!dd},b{!rep}_irfa_ind_{!ind}_{!ss}{!dd},{!ind})
				next
			next
		
			'' COLLECT RESIDUALS AND STRUCTURAL MATRIX, TRANSFORM RESIDUALS INTO STRUCTURAL
			
			b{!rep}_individual_{!ind}.makeresid {%resid}
			group b{!rep}_resid_g{!ind} {%resid}
			stomna(b{!rep}_resid_g{!ind},b{!rep}_resid_m_{!ind})
			sym b{!rep}_varcov = b{!rep}_individual_{!ind}.@residcov
			matrix b{!rep}_structural = @inverse(@cholesky(varcov))
			b{!rep}_resid_m_{!ind} = b{!rep}_resid_m_{!ind} * b{!rep}_structural
	
		'' RUN OLS REGRESSIONS (W/O CONSTANT) BETWEEN COMMON AND INDIVIDUAL RESIDUALS
			'AND CREATE LOADING MATRICES
			
			matrix(!endogenous,!endogenous) b{!rep}_mloading_{!ind} = 0
			for !zz = 1 to !endogenous
				vector(!horizon) b{!rep}_resid_v{!ind}_{!zz} = @columnextract(b{!rep}_resid_m_{!ind},{!zz})
				mtos(b{!rep}_resid_v{!ind}_{!zz}, b{!rep}_resid_{!ind}_{!zz})
				b{!rep}_resid_{!ind}_{!zz} = b{!rep}_resid_{!ind}_{!zz} / @stdev(b{!rep}_resid_{!ind}_{!zz})
				equation loading{!zz}.ls b{!rep}_resid_{!ind}_{!zz} resid_c_{!zz}
				b{!rep}_mloading_{!ind}({!zz},{!zz}) = loading{!zz}.@coefs(1)
			next
	
		'' DECOMPOSE IRFs USING LOADING MATRICES
	
			matrix b{!rep}_mloadingt_{!ind} = @sqrt(@abs(@identity(!endogenous) - b{!rep}_mloading_{!ind} * @transpose(b{!rep}_mloading_{!ind})))
		
			for !ss = 1 to !endogenous
				for !dd = 1 to !endogenous
					vector(!horizon) b{!rep}_irf_c_{!ind}_{!ss}{!dd} = b{!rep}_mloading_{!ind}(!ss,!ss) * b{!rep}_irf_ind_{!ind}_{!ss}{!dd}
					vector(!horizon) b{!rep}_irf_id_{!ind}_{!ss}{!dd} = b{!rep}_irf_ind_{!ind}_{!ss}{!dd} - b{!rep}_irf_c_{!ind}_{!ss}{!dd}
					vector(!horizon) b{!rep}_irfa_c_{!ind}_{!ss}{!dd} = b{!rep}_mloading_{!ind}(!ss,!ss) * b{!rep}_irfa_ind_{!ind}_{!ss}{!dd}
					vector(!horizon) b{!rep}_irfa_id_{!ind}_{!ss}{!dd} = b{!rep}_irfa_ind_{!ind}_{!ss}{!dd} - b{!rep}_irfa_c_{!ind}_{!ss}{!dd}
					colplace(b{!rep}_mirf_id_{!ss}{!dd},b{!rep}_irf_id_{!ind}_{!ss}{!dd},{!ind})
					colplace(b{!rep}_mirf_c_{!ss}{!dd},b{!rep}_irf_c_{!ind}_{!ss}{!dd},{!ind})
					colplace(b{!rep}_mirfa_id_{!ss}{!dd},b{!rep}_irfa_id_{!ind}_{!ss}{!dd},{!ind})
					colplace(b{!rep}_mirfa_c_{!ss}{!dd},b{!rep}_irfa_c_{!ind}_{!ss}{!dd},{!ind})
				next
			next

		next
		
	''' CALCULATE MEDIAN AND QUARTILES
	
		''' MARGINAL RESPONSES
	
		for %z ind id c
			for !ss = 1 to !endogenous
				for !dd = 1 to !endogenous
					vector(!horizon) b{!rep}_gupper_{%z}_{!ss}{!dd}
					vector(!horizon) b{!rep}_gmid_{%z}_{!ss}{!dd}
					vector(!horizon) b{!rep}_glower_{%z}_{!ss}{!dd}
					vector(!horizon) b{!rep}_gaverage_{%z}_{!ss}{!dd}
					for !i = 1 to !horizon 
						b{!rep}_gupper_{%z}_{!ss}{!dd}(!i) = @quantile(@rowextract(b{!rep}_mirf_{%z}_{!ss}{!dd},(!i)),0.75)
						b{!rep}_gmid_{%z}_{!ss}{!dd}(!i)= @quantile(@rowextract(b{!rep}_mirf_{%z}_{!ss}{!dd},(!i)),0.5)
						b{!rep}_glower_{%z}_{!ss}{!dd}(!i) = @quantile(@rowextract(b{!rep}_mirf_{%z}_{!ss}{!dd},(!i)),0.25)
						b{!rep}_gaverage_{%z}_{!ss}{!dd}(!i) = @mean(@rowextract(b{!rep}_mirf_{%z}_{!ss}{!dd},(!i)))
					next
					matplace(b_gupper_{%z}_{!ss}{!dd},b{!rep}_gupper_{%z}_{!ss}{!dd},1,{!rep})
					matplace(b_gmid_{%z}_{!ss}{!dd},b{!rep}_gmid_{%z}_{!ss}{!dd},1,{!rep})
					matplace(b_glower_{%z}_{!ss}{!dd},b{!rep}_glower_{%z}_{!ss}{!dd},1,{!rep})
					matplace(b_gaverage_{%z}_{!ss}{!dd},b{!rep}_gaverage_{%z}_{!ss}{!dd},1,{!rep})
				next
			next			
		next

		''' ACCUMULATED RESPONSES
		for %z ind id c
			for !ss = 1 to !endogenous
				for !dd = 1 to !endogenous
					vector(!horizon) b{!rep}_guppera_{%z}_{!ss}{!dd}
					vector(!horizon) b{!rep}_gmida_{%z}_{!ss}{!dd}
					vector(!horizon) b{!rep}_glowera_{%z}_{!ss}{!dd}
					vector(!horizon) b{!rep}_gaveragea_{%z}_{!ss}{!dd}
					for !i = 1 to !horizon 
						b{!rep}_guppera_{%z}_{!ss}{!dd}(!i) = @quantile(@rowextract(b{!rep}_mirfa_{%z}_{!ss}{!dd},(!i)),0.75)
						b{!rep}_gmida_{%z}_{!ss}{!dd}(!i)= @quantile(@rowextract(b{!rep}_mirfa_{%z}_{!ss}{!dd},(!i)),0.5)
						b{!rep}_glowera_{%z}_{!ss}{!dd}(!i) = @quantile(@rowextract(b{!rep}_mirfa_{%z}_{!ss}{!dd},(!i)),0.25)
						b{!rep}_gaveragea_{%z}_{!ss}{!dd}(!i) = @mean(@rowextract(b{!rep}_mirfa_{%z}_{!ss}{!dd},(!i)))
					next
					matplace(b_guppera_{%z}_{!ss}{!dd},b{!rep}_guppera_{%z}_{!ss}{!dd},1,{!rep})
					matplace(b_gmida_{%z}_{!ss}{!dd},b{!rep}_gmida_{%z}_{!ss}{!dd},1,{!rep})
					matplace(b_glowera_{%z}_{!ss}{!dd},b{!rep}_glowera_{%z}_{!ss}{!dd},1,{!rep})
					matplace(b_gaveragea_{%z}_{!ss}{!dd},b{!rep}_gaveragea_{%z}_{!ss}{!dd},1,{!rep})
				next
			next			
		next

	delete b{!rep}_*

next

	''' CALCULATE STANDARD ERRORS

if !marginal = 1 then

		for %z ind id c
			for !ss = 1 to !endogenous
				for !dd = 1 to !endogenous
					vector(!horizon) sd_gupper_{%z}_{!ss}{!dd}
					vector(!horizon) sd_gmid_{%z}_{!ss}{!dd}
					vector(!horizon) sd_glower_{%z}_{!ss}{!dd}
					vector(!horizon) sd_gaverage_{%z}_{!ss}{!dd}
					for !i = 1 to !horizon 
						sd_gupper_{%z}_{!ss}{!dd}(!i) = @stdev(@rowextract(b_gupper_{%z}_{!ss}{!dd},(!i)))
						sd_gmid_{%z}_{!ss}{!dd}(!i)= @stdev(@rowextract(b_gmid_{%z}_{!ss}{!dd},(!i)))
						sd_glower_{%z}_{!ss}{!dd}(!i) = @stdev(@rowextract(b_glower_{%z}_{!ss}{!dd},(!i)))
						sd_gaverage_{%z}_{!ss}{!dd}(!i) = @stdev(@rowextract(b_gaverage_{%z}_{!ss}{!dd},(!i)))
					next
						vector(!horizon) gmidh_{%z}_{!ss}{!dd} = gmid_{%z}_{!ss}{!dd}  + {!ci} * sd_gmid_{%z}_{!ss}{!dd}
						vector(!horizon) gmidl_{%z}_{!ss}{!dd} = gmid_{%z}_{!ss}{!dd}  - {!ci} * sd_gmid_{%z}_{!ss}{!dd}
				next
			next			
		next

endif

if !cummulative = 1 then

		for %z ind id c
			for !ss = 1 to !endogenous
				for !dd = 1 to !endogenous
					vector(!horizon) sd_guppera_{%z}_{!ss}{!dd}
					vector(!horizon) sd_gmida_{%z}_{!ss}{!dd}
					vector(!horizon) sd_glowera_{%z}_{!ss}{!dd}
					vector(!horizon) sd_gaveragea_{%z}_{!ss}{!dd}
					for !i = 1 to !horizon 
						sd_guppera_{%z}_{!ss}{!dd}(!i) = @stdev(@rowextract(b_guppera_{%z}_{!ss}{!dd},(!i)))
						sd_gmida_{%z}_{!ss}{!dd}(!i)= @stdev(@rowextract(b_gmida_{%z}_{!ss}{!dd},(!i)))
						sd_glowera_{%z}_{!ss}{!dd}(!i) = @stdev(@rowextract(b_glowera_{%z}_{!ss}{!dd},(!i)))
						sd_gaveragea_{%z}_{!ss}{!dd}(!i) = @stdev(@rowextract(b_gaveragea_{%z}_{!ss}{!dd},(!i)))
					next
						vector(!horizon) gmidah_{%z}_{!ss}{!dd} = gmida_{%z}_{!ss}{!dd}  + {!ci} * sd_gmida_{%z}_{!ss}{!dd}
						vector(!horizon) gmidal_{%z}_{!ss}{!dd} = gmida_{%z}_{!ss}{!dd}  - {!ci} * sd_gmida_{%z}_{!ss}{!dd}
				next
			next			
		next

endif

' 	delete b_*

		string namelist = ""

if !marginal = 1 then

		for !ss = 1 to !endogenous
			for !dd = 1 to !endogenous
				matrix(!horizon,3) gci_ind{!ss}{!dd}
				matplace(gci_ind{!ss}{!dd} , gmidh_ind_{!ss}{!dd},1,1)
				matplace(gci_ind{!ss}{!dd} , gmid_ind_{!ss}{!dd},1,2)
				matplace(gci_ind{!ss}{!dd} , gmidl_ind_{!ss}{!dd},1,3)
				freeze(temp_chartcigind{!ss}{!dd}) gci_ind{!ss}{!dd}.line
				temp_chartcigind{!ss}{!dd}.option linepat	' need to set linepat
				temp_chartcigind{!ss}{!dd}.elem(1) lcolor(red) lpat(dash1)
				temp_chartcigind{!ss}{!dd}.elem(2) lcolor(blue) lpat(solid)
				temp_chartcigind{!ss}{!dd}.elem(3) lcolor(red) lpat(dash1)
				temp_chartcigind{!ss}{!dd}.legend(off)
				string title{!ss}{!dd} = "Median composite response of " + endogenous.@seriesname({!dd}) + " to " + endogenous.@seriesname({!ss})
				temp_chartcigind{!ss}{!dd}.addtext(t,font(Arial,16pt)) {title{!ss}{!dd}}
				temp_chartcigind{!ss}{!dd}.draw(line,left.rgb(0,0,0)) 0
				string namelist = namelist + "temp_chartcigind" + @str({!ss}{!dd}) + " "
			next
		next

		freeze(chartci_composite) {namelist}
		show chartci_composite

endif

if !cummulative = 1 then

		string namelist = ""

		for !ss = 1 to !endogenous
			for !dd = 1 to !endogenous
				matrix(!horizon,3) gcia_ind{!ss}{!dd}
				matplace(gcia_ind{!ss}{!dd} , gmidah_ind_{!ss}{!dd},1,1)
				matplace(gcia_ind{!ss}{!dd} , gmida_ind_{!ss}{!dd},1,2)
				matplace(gcia_ind{!ss}{!dd} , gmidal_ind_{!ss}{!dd},1,3)
				freeze(temp_chartcigaind{!ss}{!dd}) gcia_ind{!ss}{!dd}.line
				temp_chartcigaind{!ss}{!dd}.option linepat	' need to set linepat
				temp_chartcigaind{!ss}{!dd}.elem(1) lcolor(red) lpat(dash1)
				temp_chartcigaind{!ss}{!dd}.elem(2) lcolor(blue) lpat(solid)
				temp_chartcigaind{!ss}{!dd}.elem(3) lcolor(red) lpat(dash1)
				temp_chartcigaind{!ss}{!dd}.legend(off)
				string title{!ss}{!dd} = "Median accumulated composite response of " + endogenous.@seriesname({!dd}) + " to " + endogenous.@seriesname({!ss})
				temp_chartcigaind{!ss}{!dd}.addtext(t,font(Arial,16pt)) {title{!ss}{!dd}}
				temp_chartcigaind{!ss}{!dd}.draw(line,left.rgb(0,0,0)) 0
				string namelist = namelist + "temp_chartcigaind" + @str({!ss}{!dd}) + " "
			next
		next

		freeze(chartaci_composite) {namelist}
		show chartaci_composite

endif

endif

save {%save}
