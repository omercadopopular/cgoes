*! version 7.02  24nov2013  Michael Stepner, stepner@mit.edu

/* CC0 license information:
To the extent possible under law, the author has dedicated all copyright and related and neighboring rights
to this software to the public domain worldwide. This software is distributed without any warranty.

This code is licensed under the CC0 1.0 Universal license.  The full legal text as well as a
human-readable summary can be accessed at http://creativecommons.org/publicdomain/zero/1.0/
*/

* Why did I include a formal license? Jeff Atwood gives good reasons: http://www.codinghorror.com/blog/2007/04/pick-a-license-any-license.html


program define binscatter, eclass sortpreserve
	version 12.1
	
	syntax varlist(min=2 numeric) [if] [in] [aweight fweight], [by(varname) ///
		Nquantiles(integer 20) GENxq(name) discrete xq(varname numeric) MEDians ///
		CONTROLs(varlist numeric ts fv) absorb(varname) noAddmean ///
		LINEtype(string) rd(numlist ascending) reportreg ///
		COLors(string) MColors(string) LColors(string) Msymbols(string) ///
		savegraph(string) savedata(string) replace ///
		nofastxtile randvar(varname numeric) randcut(real 1) randn(integer -1) ///
		/* LEGACY OPTIONS */ nbins(integer 20) create_xq x_q(varname numeric) symbols(string) method(string) unique(string) ///
		*]

	set more off

	* Create convenient weight local
	if ("`weight'"!="") local wt [`weight'`exp']
	
	***** Begin legacy option compatibility code
	
	if (`nbins'!=20) {
		if (`nquantiles'!=20) {
			di as error "Cannot specify both nquantiles() and nbins(): both are the same option, nbins is supported only for backward compatibility."
			exit
		}
		di as text "NOTE: legacy option nbins() has been renamed nquantiles(), and is supported only for backward compatibility."
		local nquantiles=`nbins'
	}
	
	if ("`create_xq'"!="") {
		if ("`genxq'"!="") {
			di as error "Cannot specify both genxq() and create_xq: both are the same option, create_xq is supported only for backward compatibility."
			exit
		}
		di as text "NOTE: legacy option create_xq has been renamed genxq(), and is supported only for backward compatibility."
		local genxq="q_"+word("`varlist'",-1)
	}
	
	if ("`x_q'"!="") {
		if ("`xq'"!="") {
			di as error "Cannot specify both xq() and x_q(): both are the same option, x_q() is supported only for backward compatibility."
			exit
		}
		di as text "NOTE: legacy option x_q() has been renamed xq(), and is supported only for backward compatibility."
		local xq `x_q'
	}
	
	if ("`symbols'"!="") {
		if ("`msymbols'"!="") {
			di as error "Cannot specify both msymbols() and symbols(): both are the same option, symbols() is supported only for backward compatibility."
			exit
		}
		di as text "NOTE: legacy option symbols() has been renamed msymbols(), and is supported only for backward compatibility."
		local msymbols `symbols'
	}
	
	if ("`linetype'"=="noline") {
		di as text "NOTE: legacy line type 'noline' has been renamed 'none', and is supported only for backward compatibility."
		local linetype none
	}
	
	if ("`method'"!="") {
		di as text "NOTE: method() is no longer a recognized option, and will be ignored. binscatter now always uses the fastest method without a need for two instances"
	}
	
	if ("`unique'"!="") {
		di as text "NOTE: unique() is no longer a recognized option, and will be ignored. binscatter now considers the x-variable discrete if it has fewer unique values than nquantiles()"
	}
		
	***** End legacy option capatibility code

	*** Perform checks

	* Set default linetype and check valid
	if ("`linetype'"=="") local linetype lfit
	else if !inlist("`linetype'","connect","lfit","qfit","none") {
		di as error "linetype() must either be connect, lfit, qfit, or none"
		exit
	}
	
	* Check that nofastxtile isn't combined with fastxtile-only options
	if "`fastxtile'"=="nofastxtile" & ("`randvar'"!="" | `randcut'!=1 | `randn'!=-1) {
		di as error "Cannot combine randvar, randcut or randn with nofastxtile"
		exit
	}

	* Misc checks
	if ("`genxq'"!="" & ("`xq'"!="" | "`discrete'"!="")) | ("`xq'"!="" & "`discrete'"!="") {
		di as error "Cannot specify more than one of genxq(), xq(), and discrete simultaneously."
		exit
	}
	if ("`genxq'"!="") confirm new variable `genxq'
	if ("`xq'"!="") {
		capture assert `xq'==int(`xq') & `xq'>0
		if _rc!=0 {
			di as error "xq() must contain only positive integers."
			exit
		}
		
		if ("`controls'`absorb'"!="") di as text "warning: xq() is specified in combination with controls() or absorb(). note that binning takes places after residualization, so the xq variable should contain bins of the residuals."
	}
	if `nquantiles'!=20 & ("`xq'"!="" | "`discrete'"!="") {
		di as error "Cannot specify nquantiles in combination with discrete or an xq variable."
		exit
	}
	if "`reportreg'"!="" & !inlist("`linetype'","lfit","qfit") {
		di as error "Cannot specify 'reportreg' when no fit line is being created."
		exit
	}
	if "`replace'"=="" {
		if `"`savegraph'"'!="" {
			if regexm(`"`savegraph'"',"\.[a-zA-Z0-9]+$") confirm new file `"`savegraph'"'
			else confirm new file `"`savegraph'.gph"'
		}
		if `"`savedata'"'!="" {
			confirm new file `"`savedata'.csv"'
			confirm new file `"`savedata'.do"'
		}
	}

	* Mark sample (reflects the if/in conditions, and includes only nonmissing observations)
	marksample touse
	markout `touse' `by' `xq' `controls' `absorb', strok
	qui count if `touse'
	local samplesize=r(N)
	local touse_first=_N-`samplesize'+1
	local touse_last=_N

	* Parse varlist into y-vars and x-var
	local x_var=word("`varlist'",-1)
	local y_vars=regexr("`varlist'"," `x_var'$","")
	local ynum=wordcount("`y_vars'")

	* Check number of unique byvals & create local storing byvals
	if "`by'"!="" {
		local byvarname `by'
	
		capture confirm numeric variable `by'
		if _rc {
			* by-variable is string => generate a numeric version
			tempvar by
			tempname bylabel
			egen `by'=group(`byvarname'), lname(`bylabel')
		}
		
		local bylabel `:value label `by'' /*catch value labels for numeric by-vars too*/ 
		
		tempname byvalmatrix
		qui tab `by' if `touse', nofreq matrow(`byvalmatrix')
		
		local bynum=r(r)
		forvalues i=1/`bynum' {
			local byvals `byvals' `=`byvalmatrix'[`i',1]'
		}
	}
	else local bynum=1
	

	****** Create residuals  ******
	
	if (`"`controls'`absorb'"'!="") quietly {
	
		* Parse absorb to define the type of regression to be used
		if `"`absorb'"'!="" {
			local regtype "areg"
			local absorb "absorb(`absorb')"
		}
		else {
			local regtype "reg"
		}
	
		* Generate residuals
		
		local firstloop=1
		foreach var of varlist `x_var' `y_vars' {
			tempvar residvar
			`regtype' `var' `controls' `wt' if `touse', `absorb'
			predict `residvar' if e(sample), residuals
			if ("`addmean'"!="noaddmean") {
				summarize `var' `wt' if `touse', meanonly
				replace `residvar'=`residvar'+r(mean)
			}
			
			label variable `residvar' "`var'"
			if `firstloop'==1 {
				local x_r `residvar'
				local firstloop=0
			}
			else local y_vars_r `y_vars_r' `residvar'
		}
		
	}
	else { 	/*absorb and controls both empty, no need for regression*/
		local x_r `x_var'
		local y_vars_r `y_vars'
	}


	****** Regressions for fit lines ******
	
	if ("`reportreg'"=="") local reg_verbosity "quietly"

	if inlist("`linetype'","lfit","qfit") `reg_verbosity' {

		* If doing a quadratic fit, generate a quadratic term in x
		if "`linetype'"=="qfit" {
			tempvar x_r2
			gen `x_r2'=`x_r'^2
		}
		
		* Create matrices to hold regression results
		tempname e_b_temp
		forvalues i=1/`ynum' {
			tempname y`i'_coefs
		}
		
		* LOOP over by-vars
		local counter_by=1
		if ("`by'"=="") local noby="noby"
		foreach byval in `byvals' `noby' {
		
			* LOOP over rd intervals
			tokenize  "`rd'"
			local counter_rd=1	
				
			while ("`1'"!="" | `counter_rd'==1) {
			
				* display text headers
				if "`reportreg'"!="" {
					di "{txt}{hline}"
					if ("`by'"!="") {
						if ("`bylabel'"=="") di "-> `byvarname' = `byval'"
						else {
							di "-> `byvarname' = `: label `bylabel' `byval''"
						}
					}
					if ("`rd'"!="") {
						if (`counter_rd'==1) di "RD: `x_var'<=`1'"
						else if ("`2'"!="") di "RD: `x_var'>`1' & `x_var'<=`2'"
						else di "RD: `x_var'>`1'"
					}
				}
				
				* set conditions on reg
				local conds `touse'
				
				if ("`by'"!="" ) local conds `conds' & `by'==`byval'
				
				if ("`rd'"!="") {
					if (`counter_rd'==1) local conds `conds' & `x_r'<=`1'
					else if ("`2'"!="") local conds `conds' & `x_r'>`1' & `x_r'<=`2'
					else local conds `conds' & `x_r'>`1'
				}

				* LOOP over y-vars
				local counter_depvar=1
				foreach depvar of varlist `y_vars_r' {
				
					* display text headers
					if (`ynum'>1) {
						if ("`controls'`absorb'"!="") local depvar_name : var label `depvar'
						else local depvar_name `depvar'
						di as text "{bf:y_var = `depvar_name'}"
					}
					
					* perform regression
					if ("`reg_verbosity'"=="quietly") capture reg `depvar' `x_r2' `x_r' `wt' if `conds'
					else capture noisily reg `depvar' `x_r2' `x_r' `wt' if `conds'
					
					* store results
					if (_rc==0) matrix e_b_temp=e(b)
					else if (_rc==2000) {
						if ("`reg_verbosity'"=="quietly") di as error "no observations for one of the fit lines. add 'reportreg' for more info."
						
						if ("`linetype'"=="lfit") matrix e_b_temp=.,.
						else /*("`linetype'"=="qfit")*/ matrix e_b_temp=.,.,.
					}
					else {
						error _rc
						exit _rc
					}
					
					* relabel matrix row			
					if ("`by'"!="") matrix roweq e_b_temp = "by`counter_by'"
					if ("`rd'"!="") matrix rownames e_b_temp = "rd`counter_rd'"
					else matrix rownames e_b_temp = "="
					
					* save to y_var matrix
					if (`counter_by'==1 & `counter_rd'==1) matrix `y`counter_depvar'_coefs'=e_b_temp
					else matrix `y`counter_depvar'_coefs'=`y`counter_depvar'_coefs' \ e_b_temp
					
					* increment depvar counter
					local ++counter_depvar
				}
			
				* increment rd counter
				if (`counter_rd'!=1) mac shift
				local ++counter_rd
				
			}
			
			* increment by counter
			local ++counter_by
			
		}
	
		* relabel matrix column names
		forvalues i=1/`ynum' {
			if ("`linetype'"=="lfit") matrix colnames `y`i'_coefs' = "`x_var'" "_cons"
			else if ("`linetype'"=="qfit") matrix colnames `y`i'_coefs' = "`x_var'^2" "`x_var'" "_cons"
		}
	
	}

	******* Define the bins *******
	
	* Specify and/or create the xq var, as necessary
	if "`xq'"=="" {

		if !(`touse_first'==1 & word("`:sortedby'",1)=="`x_r'") sort `touse' `x_r'
	
		if "`discrete'"=="" { /* xq() and discrete are not specified */
			
			* Check whether the number of unique values > nquantiles, or <= nquantiles
			capture mata: characterize_unique_vals_sorted("`x_r'",`touse_first',`touse_last',`nquantiles')
			
			if (_rc==0) { /* number of unique values <= nquantiles, set to discrete */
				local discrete discrete
				if ("`genxq'"!="") di as text `"note: the x-variable has fewer unique values than the number of bins specified (`nquantiles').  It will therefore be treated as discrete, and genxq() will be ignored"'

				local xq `x_r'
				local nquantiles=r(r)
				if ("`by'"=="") {
					tempname xq_boundaries xq_values
					matrix `xq_boundaries'=r(boundaries)		
					matrix `xq_values'=r(values)
				}
			}
			else if (_rc==134) { /* number of unique values > nquantiles, perform binning */
				if ("`genxq'"!="") local xq `genxq'
				else tempvar xq
	
				if ("`fastxtile'"!="nofastxtile") fastxtile `xq' = `x_r' `wt' in `touse_first'/`touse_last', nq(`nquantiles') randvar(`randvar') randcut(`randcut') randn(`randn')
				else xtile `xq' = `x_r' `wt' in `touse_first'/`touse_last', nq(`nquantiles')

				if ("`by'"=="") {
					mata: characterize_unique_vals_sorted("`xq'",`touse_first',`touse_last',`nquantiles')

					if (r(r)!=`nquantiles') {
						di as text "warning: nquantiles(`nquantiles') was specified, but only `r(r)' were generated. see help file under nquantiles() for explanation."
						local nquantiles=r(r)
					}

					tempname xq_boundaries xq_values
					matrix `xq_boundaries'=r(boundaries)		
					matrix `xq_values'=r(values)
				}
			}
			else {
				error _rc
			}

		}
		
		else { /* discrete is specified, xq() & genxq() are not */
		
			if ("`controls'`absorb'"!="") di as text "warning: discrete is specified in combination with controls() or absorb(). note that binning takes places after residualization, so the residualized x-variable may contain many more unique values."

			capture mata: characterize_unique_vals_sorted("`x_r'",`touse_first',`touse_last',`=`samplesize'/2')
		
			if (_rc==0) {
				local xq `x_r'
				local nquantiles=r(r)
				if ("`by'"=="") {
					tempname xq_boundaries xq_values
					matrix `xq_boundaries'=r(boundaries)		
					matrix `xq_values'=r(values)
				}
			}
			else if (_rc==134) {
				di as error "discrete specified, but number of unique values is > (sample size/2)"
				exit 134
			}
			else {
				error _rc
			}
		}
	}
	else {

		if !(`touse_first'==1 & word("`:sortedby'",1)=="`xq'") sort `touse' `xq'
		
		* set nquantiles & boundaries
		mata: characterize_unique_vals_sorted("`xq'",`touse_first',`touse_last',`=`samplesize'/2')
		
		if (_rc==0) {
			local nquantiles=r(r)
			if ("`by'"=="") {
				tempname xq_boundaries xq_values
				matrix `xq_boundaries'=r(boundaries)		
				matrix `xq_values'=r(values)
			}
		}
		else if (_rc==134) {
			di as error "discrete specified, but number of unique values is > (sample size/2)"
			exit 134
		}
		else {
			error _rc
		}
	}

	********** Compute scatter points **********

	if ("`by'"!="") {
		sort `touse' `by' `xq'
		tempname by_boundaries
		mata: characterize_unique_vals_sorted("`by'",`touse_first',`touse_last',`bynum')
		matrix `by_boundaries'=r(boundaries)
	}

	forvalues b=1/`bynum' {
		if ("`by'"!="") {
			mata: characterize_unique_vals_sorted("`xq'",`=`by_boundaries'[`b',1]',`=`by_boundaries'[`b',2]',`nquantiles')
			tempname xq_boundaries xq_values
			matrix `xq_boundaries'=r(boundaries)
			matrix `xq_values'=r(values)
		}
		/* otherwise xq_boundaries and xq_values are defined above in the binning code block */

		* Define x-means
		tempname xbin_means
		if ("`discrete'"=="discrete") {
			matrix `xbin_means'=`xq_values'
		}
		else {
			means_in_boundaries `x_r' `wt', bounds(`xq_boundaries') `medians'
			matrix `xbin_means'=r(means)
		}

		* LOOP over y-vars to define y-means
		local counter_depvar=0
		foreach depvar of varlist `y_vars_r' {
			local ++counter_depvar

			means_in_boundaries `depvar' `wt', bounds(`xq_boundaries') `medians'

			* store to matrix
			if (`b'==1) {
				tempname y`counter_depvar'_scatterpts
				matrix `y`counter_depvar'_scatterpts' = `xbin_means',r(means)
			}
			else {
				* make matrices conformable before right appending			
				local rowdiff=rowsof(`y`counter_depvar'_scatterpts')-rowsof(`xbin_means')
				if (`rowdiff'==0) matrix `y`counter_depvar'_scatterpts' = `y`counter_depvar'_scatterpts',`xbin_means',r(means)
				else if (`rowdiff'>0)  matrix `y`counter_depvar'_scatterpts' = `y`counter_depvar'_scatterpts', ( (`xbin_means',r(means)) \ J(`rowdiff',2,.) )
				else /*(`rowdiff'<0)*/ matrix `y`counter_depvar'_scatterpts' = ( `y`counter_depvar'_scatterpts' \ J(-`rowdiff',colsof(`y`counter_depvar'_scatterpts'),.) ) ,`xbin_means',r(means)
			}
		}
	}

	*********** Perform Graphing ***********

	* If rd is specified, prepare xline parameters
	if "`rd'"!="" {
		foreach xval in "`rd'" {
			local xlines `xlines' xline(`xval', lpattern(dash) lcolor(gs8))
		}
	}

	* Fill colors if missing
	if `"`colors'"'=="" local colors ///
		navy maroon forest_green dkorange teal cranberry lavender ///
		khaki sienna emidblue emerald brown erose gold bluishgray ///
		/* lime magenta cyan pink blue */
	if `"`mcolors'"'=="" {
		if (`ynum'==1 & `bynum'==1 & "`linetype'"!="connect") local mcolors `: word 1 of `colors''
		else local mcolors `colors'
	}
	if `"`lcolors'"'=="" {
		if (`ynum'==1 & `bynum'==1 & "`linetype'"!="connect") local lcolors `: word 2 of `colors''
		else local lcolors `colors'
	}
	local num_mcolor=wordcount(`"`mcolors'"')
	local num_lcolor=wordcount(`"`lcolors'"')


	* Prepare connect & msymbol options
	if ("`linetype'"=="connect") local connect "c(l)"
	if "`msymbols'"!="" {
		local symbol_prefix "msymbol("
		local symbol_suffix ")"
	}
	
	*** Prepare scatters
	
	* c indexes which color is to be used
	local c=0
	
	local counter_series=0
	
	* LOOP over by-vars
	local counter_by=0
	if ("`by'"=="") local noby="noby"
	foreach byval in `byvals' `noby' {
		local ++counter_by
		
		local xind=`counter_by'*2-1
		local yind=`counter_by'*2

		* LOOP over y-vars
		local counter_depvar=0
		foreach depvar of varlist `y_vars' {
			local ++counter_depvar
			local ++c
			
			* LOOP over rows (each row contains a coordinate pair)
			local row=1
			local xval=`y`counter_depvar'_scatterpts'[`row',`xind']
			local yval=`y`counter_depvar'_scatterpts'[`row',`yind']
			
			if !missing(`xval',`yval') {
				local ++counter_series
				local scatters `scatters' (scatteri
				if ("`savedata'"!="") {
					if ("`by'"=="") local savedata_scatters `savedata_scatters' (scatter `depvar' `x_var'
					else local savedata_scatters `savedata_scatters' (scatter `depvar'_by`counter_by' `x_var'_by`counter_by'
				}
			}
			else {
				* skip the rest of this loop iteration
				continue
			}
			
			while (`xval'!=. & `yval'!=.) {
				local scatters `scatters' `yval' `xval'
			
				local ++row
				local xval=`y`counter_depvar'_scatterpts'[`row',`xind']
				local yval=`y`counter_depvar'_scatterpts'[`row',`yind']
			}
			
			* Add options
			local scatter_options `connect' mcolor(`: word `c' of `mcolors'') lcolor(`: word `c' of `lcolors'') `symbol_prefix'`: word `c' of `msymbols''`symbol_suffix'
			local scatters `scatters', `scatter_options')
			if ("`savedata'"!="") local savedata_scatters `savedata_scatters', `scatter_options')
		

			* Add legend
			if "`by'"=="" {
				if (`ynum'==1) local legend_labels off
				else local legend_labels `legend_labels' lab(`counter_series' `depvar')
			}
			else {
				if ("`bylabel'"=="") local byvalname=`byval'
				else {
					local byvalname `: label `bylabel' `byval''
				}
			
				if (`ynum'==1) local legend_labels `legend_labels' lab(`counter_series' `byvarname'=`byvalname')
				else local legend_labels `legend_labels' lab(`counter_series' `depvar': `byvarname'=`byvalname')
			}
			if ("`by'"!="" | `ynum'>1) local order `order' `counter_series'
			
		}
		
	}
	
	*** Fit lines
		
	if inlist(`"`linetype'"',"lfit","qfit") {
	
		* c indexes which color is to be used
		local c=0
		
		local rdnum=wordcount("`rd'")+1
		
		tempname fitline_bounds
		if ("`rd'"=="") matrix `fitline_bounds'=.,.
		else matrix `fitline_bounds'=.,`=subinstr("`rd'"," ",",",.)',.

		* LOOP over by-vars
		local counter_by=0
		if ("`by'"=="") local noby="noby"
		foreach byval in `byvals' `noby' {
			local ++counter_by
			
			** Set the column for the x-coords in the scatterpts matrix
			local xind=`counter_by'*2-1
			
			* Set the row to start seeking from
			*     note: each time we seek a coeff, it should be from row (rd_num)(counter_by-1)+counter_rd
			local row0=( `rdnum' ) * (`counter_by' - 1)
			
			
			* LOOP over y-vars
			local counter_depvar=0
			foreach depvar of varlist `y_vars_r' {
				local ++counter_depvar
				local ++c
				
				* Find lower and upper bounds for the fit line
				matrix `fitline_bounds'[1,1]=`y`counter_depvar'_scatterpts'[1,`xind']
				
				local fitline_ub_rindex=`nquantiles'
				local fitline_ub=.
				while `fitline_ub'==. {
					local fitline_ub=`y`counter_depvar'_scatterpts'[`fitline_ub_rindex',`xind']
					local --fitline_ub_rindex
				}
				matrix `fitline_bounds'[1,`rdnum'+1]=`fitline_ub'
		
				* LOOP over rd intervals
				forvalues counter_rd=1/`rdnum' {
					
					if (`"`linetype'"'=="lfit") {
						local coef_quad=0
						local coef_lin=`y`counter_depvar'_coefs'[`row0'+`counter_rd',1]
						local coef_cons=`y`counter_depvar'_coefs'[`row0'+`counter_rd',2]
					}
					else if (`"`linetype'"'=="qfit") {
						local coef_quad=`y`counter_depvar'_coefs'[`row0'+`counter_rd',1]
						local coef_lin=`y`counter_depvar'_coefs'[`row0'+`counter_rd',2]
						local coef_cons=`y`counter_depvar'_coefs'[`row0'+`counter_rd',3]
					}
					
					if !missing(`coef_quad',`coef_lin',`coef_cons') {
						local leftbound=`fitline_bounds'[1,`counter_rd']
						local rightbound=`fitline_bounds'[1,`counter_rd'+1]
					
						local fits `fits' (function `coef_quad'*x^2+`coef_lin'*x+`coef_cons', range(`leftbound' `rightbound') lcolor(`: word `c' of `lcolors''))
					}
				}
			}
		}
	}
	
	* Prepare y-axis title
	if (`ynum'==1) local ytitle `y_vars'
	else if (`ynum'==2) local ytitle : subinstr local y_vars " " " and "
	else local ytitle : subinstr local y_vars " " "; ", all

	* Display graph
	local graphcmd twoway `scatters' `fits', graphregion(fcolor(white)) `xlines' xtitle(`x_var') ytitle(`ytitle') legend(`legend_labels' order(`order')) `options'
	if ("`savedata'"!="") local savedata_graphcmd twoway `savedata_scatters' `fits', graphregion(fcolor(white)) `xlines' xtitle(`x_var') ytitle(`ytitle') legend(`legend_labels' order(`order')) `options'
	`graphcmd'
	
	****** Save results ******
	
	* Save graph
	if `"`savegraph'"'!="" {
		* check file extension using a regular expression
		if regexm(`"`savegraph'"',"\.[a-zA-Z0-9]+$") local graphextension=regexs(0)
		
		if inlist(`"`graphextension'"',".gph","") graph save `"`savegraph'"', `replace'
		else graph export `"`savegraph'"', `replace'
	}

	* Save data
	if ("`savedata'"!="") {
	
		*** Save a CSV containing the scatter points
		tempname savedatafile
		file open `savedatafile' using `"`savedata'.csv"', write text `replace'
		
		* LOOP over rows
		forvalues row=0/`nquantiles' {
		
			*** Put the x-variable at the left
			* LOOP over by-vals
			forvalues counter_by=1/`bynum' {
			
				if (`row'==0) { /* write variable names */
					if "`by'"!="" local bynlabel _by`counter_by'
					file write `savedatafile' "`x_var'`bynlabel',"
				}
				else { /* write data values */
					if (`row'<=`=rowsof(`y1_scatterpts')') file write `savedatafile' (`y1_scatterpts'[`row',`counter_by'*2-1]) ","
					else file write `savedatafile' ".,"
				}
			}
			
			*** Now y-variables at the right
			
			* LOOP over y-vars
			local counter_depvar=0
			foreach depvar of varlist `y_vars' {
				local ++counter_depvar

				* LOOP over by-vals
				forvalues counter_by=1/`bynum' {
				
				
					if (`row'==0) { /* write variable names */
						if "`by'"!="" local bynlabel _by`counter_by'
						file write `savedatafile' "`depvar'`bynlabel'"
					}
					else { /* write data values */
						if (`row'<=`=rowsof(`y`counter_depvar'_scatterpts')') file write `savedatafile' (`y`counter_depvar'_scatterpts'[`row',`counter_by'*2])
						else file write `savedatafile' "."
					}
					
					* unless this is the last variable in the dataset, add a comma
					if !(`counter_depvar'==`ynum' & `counter_by'==`bynum') file write `savedatafile' ","
					
				} /* end by-val loop */
				
			} /* end y-var loop */
			
			file write `savedatafile' _n
			
		} /* end row loop */

		file close `savedatafile'
		di as text `"(file `savedata'.csv written containing saved data)"'
		
		
		
		*** Save a do-file with the commands to generate a nicely labeled dataset and re-create the binscatter graph
		
		file open `savedatafile' using `"`savedata'.do"', write text `replace'
		
		file write `savedatafile' `"insheet using `savedata'.csv"' _n _n
		
		if "`by'"!="" {
			foreach var of varlist `x_var' `y_vars' {
				local counter_by=0
				foreach byval in `byvals' {
					local ++counter_by
					if ("`bylabel'"=="") local byvalname=`byval'
					else {
						local byvalname `: label `bylabel' `byval''
					}
					file write `savedatafile' `"label variable `var'_by`counter_by' "`var'; `byvarname'==`byvalname'""' _n
				}
			}
			file write `savedatafile' _n
		}
		
		file write `savedatafile' `"`savedata_graphcmd'"' _n
		
		file close `savedatafile'
		di as text `"(file `savedata'.do written containing commands to process saved data)"'
		
	}

	*** Return items
	ereturn post, esample(`touse')
	
	ereturn scalar N = `samplesize'
	
	ereturn local graphcmd `"`graphcmd'"'
	if inlist("`linetype'","lfit","qfit") {
		forvalues yi=`ynum'(-1)1 {
			ereturn matrix y`yi'_coefs=`y`yi'_coefs'
		}
	}
	
	if ("`rd'"!="") {
		tempname rdintervals
		matrix `rdintervals' = (. \ `=subinstr("`rd'"," ","\",.)' ) , ( `=subinstr("`rd'"," ","\",.)' \ .)

		forvalues i=1/`=rowsof(`rdintervals')' {
			local rdintervals_labels `rdintervals_labels' rd`i'
		}
		matrix rownames `rdintervals' = `rdintervals_labels'
		matrix colnames `rdintervals' = gt lt_eq
		ereturn matrix rdintervals=`rdintervals'
	}
	
	if ("`by'"!="" & "`by'"=="`byvarname'") { /* if a numeric by-variable was specified */
		forvalues i=1/`=rowsof(`byvalmatrix')' {
			local byvalmatrix_labels `byvalmatrix_labels' by`i'
		}
		matrix rownames `byvalmatrix' = `byvalmatrix_labels'
		matrix colnames `byvalmatrix' = `by'
		ereturn matrix byvalues=`byvalmatrix'
	}
	
end


**********************************

* Helper programs

program define means_in_boundaries, rclass
	version 12.1

	syntax varname(numeric) [aweight fweight], BOUNDsmat(name) [MEDians]
	
	* Create convenient weight local
	if ("`weight'"!="") local wt [`weight'`exp']
	
	local r=rowsof(`boundsmat')
	matrix means=J(`r',1,.)
	
	if ("`medians'"!="medians") {
		forvalues i=1/`r' {
			sum `varlist' in `=`boundsmat'[`i',1]'/`=`boundsmat'[`i',2]' `wt', meanonly
			matrix means[`i',1]=r(mean)
		}
	}
	else {
		forvalues i=1/`r' {
			_pctile `varlist' in `=`boundsmat'[`i',1]'/`=`boundsmat'[`i',2]' `wt', percentiles(50)
			matrix means[`i',1]=r(r1)
		}
	}
	
	return clear
	return matrix means=means

end

*** copy of: version 1.21  8oct2013  Michael Stepner, stepner@mit.edu
program define fastxtile, rclass
	version 11

	* Parse weights, if any
	_parsewt "aweight fweight pweight" `0' 
	local 0  "`s(newcmd)'" /* command minus weight statement */
	local wt "`s(weight)'"  /* contains [weight=exp] or nothing */

	* Extract parameters
	syntax newvarname=/exp [if] [in] [,Nquantiles(integer 2) Cutpoints(varname numeric) ALTdef ///
		CUTValues(numlist ascending) randvar(varname numeric) randcut(real 1) randn(integer -1)]

	* Mark observations which will be placed in quantiles
	marksample touse, novarlist
	markout `touse' `exp'
	qui count if `touse'
	local popsize=r(N)

	if "`cutpoints'"=="" & "`cutvalues'"=="" { /***** NQUANTILES *****/
		if `"`wt'"'!="" & "`altdef'"!="" {
			di as error "altdef option cannot be used with weights"
			exit 198
		}
		
		if `randn'!=-1 {
			if `randcut'!=1 {
				di as error "cannot specify both randcut() and randn()"
				exit 198
			}
			else if `randn'<1 {
				di as error "randn() must be a positive integer"
				exit 198
			}
			else if `randn'>`popsize' {
				di as text "randn() is larger than the population. using the full population."
				local randvar=""
			}
			else {
				local randcut=`randn'/`popsize'
				
				if "`randvar'"!="" {
					qui sum `randvar', meanonly
					if r(min)<0 | r(max)>1 {
						di as error "with randn(), the randvar specified must be in [0,1] and ought to be uniformly distributed"
						exit 198
					}
				}
			}
		}

		* Check if need to gen a temporary uniform random var
		if "`randvar'"=="" {
			if (`randcut'<1 & `randcut'>0) { 
				tempvar randvar
				gen `randvar'=runiform()
			}
			* randcut sanity check
			else if `randcut'!=1 {
				di as error "if randcut() is specified without randvar(), a uniform r.v. will be generated and randcut() must be in (0,1)"
				exit 198
			}
		}

		* Mark observations used to calculate quantile boundaries
		if ("`randvar'"!="") {
			tempvar randsample
			mark `randsample' `wt' if `touse' & `randvar'<=`randcut'
		}
		else {
			local randsample `touse'
		}

		* Error checks
		qui count if `randsample'
		local samplesize=r(N)
		if (`nquantiles' > r(N) + 1) {
			if ("`randvar'"=="") di as error "nquantiles() must be less than or equal to the number of observations [`r(N)'] plus one"
			else di as error "nquantiles() must be less than or equal to the number of sampled observations [`r(N)'] plus one"
			exit 198
		}
		else if (`nquantiles' < 2) {
			di as error "nquantiles() must be greater than or equal to 2"
			exit 198
		}

		* Compute quantile boundaries
		_pctile `exp' if `randsample' `wt', nq(`nquantiles') `altdef'

		* Store quantile boundaries in list
		forvalues i=1/`=`nquantiles'-1' {
			local cutvallist `cutvallist' r(r`i')
		}
	}
	else if "`cutpoints'"!="" { /***** CUTPOINTS *****/
	
		* Parameter checks
		if "`cutvalues'"!="" {
			di as error "cannot specify both cutpoints() and cutvalues()"
			exit 198
		}		
		if "`wt'"!="" | "`randvar'"!="" | "`ALTdef'"!="" | `randcut'!=1 | `nquantiles'!=2 | `randn'!=-1 {
			di as error "cutpoints() cannot be used with nquantiles(), altdef, randvar(), randcut(), randn() or weights"
			exit 198
		}

		tempname cutvals
		qui tab `cutpoints', matrow(`cutvals')
		
		if r(r)==0 {
			di as error "cutpoints() all missing"
			exit 2000
		}
		else {
			local nquantiles = r(r) + 1
			
			forvalues i=1/`r(r)' {
				local cutvallist `cutvallist' `cutvals'[`i',1]
			}
		}
	}
	else { /***** CUTVALUES *****/
		if "`wt'"!="" | "`randvar'"!="" | "`ALTdef'"!="" | `randcut'!=1 | `nquantiles'!=2 | `randn'!=-1 {
			di as error "cutvalues() cannot be used with nquantiles(), altdef, randvar(), randcut(), randn() or weights"
			exit 198
		}
		
		* parse numlist
		numlist "`cutvalues'"
		local cutvallist `"`r(numlist)'"'
		local nquantiles=wordcount(`"`r(numlist)'"')+1
	}

	* Pick data type for quantile variable
	if (`nquantiles'<=100) local qtype byte
	else if (`nquantiles'<=32,740) local qtype int
	else local qtype long

	* Create quantile variable
	local cutvalcommalist : subinstr local cutvallist " " ",", all
	qui gen `qtype' `varlist'=1+irecode(`exp',`cutvalcommalist') if `touse'
	label var `varlist' "`nquantiles' quantiles of `exp'"
	
	* Return values
	if ("`samplesize'"!="") return scalar n = `samplesize'
	else return scalar n = .
	
	return scalar N = `popsize'
	
	tokenize `"`cutvallist'"'
	forvalues i=`=`nquantiles'-1'(-1)1 {
		return scalar r`i' = ``i''
	}

end


version 12.1
set matastrict on

mata:

void characterize_unique_vals_sorted(string scalar var, real scalar first, real scalar last, real scalar maxuq) {
	// Inputs: a numeric variable, a starting & ending obs #, and a maximum number of unique values
	// Requires: the data to be sorted on the specified variable within the observation boundaries given
	//				(no check is made that this requirement is satisfied)
	// Returns: the number of unique values found
	//			the unique values found
	//			the observation boundaries of each unique value in the dataset
	
	
	// initialize returned results
	real scalar Nunique
	Nunique=0

	real matrix values
	values=J(maxuq,1,.)
	
	real matrix boundaries
	boundaries=J(maxuq,2,.)

	// initialize computations
	real scalar var_index
	var_index=st_varindex(var)
	
	real scalar curvalue
	real scalar prevvalue
	
	// perform computations
	real scalar obs
	for (obs=first; obs<=last; obs++) {
		curvalue=_st_data(obs,var_index)
		
		if (curvalue!=prevvalue) {
			Nunique++
			if (Nunique<=maxuq) {
				prevvalue=curvalue
				values[Nunique,1]=curvalue
				boundaries[Nunique,1]=obs
				if (Nunique>1) boundaries[Nunique-1,2]=obs-1
			}
			else {
				exit(error(134))
			}
			
		}
	}
	boundaries[Nunique,2]=last
	
	// return results
	stata("return clear")
	
	st_numscalar("r(r)",Nunique)
	st_matrix("r(values)",values[1..Nunique,.])
	st_matrix("r(boundaries)",boundaries[1..Nunique,.])

}

end
