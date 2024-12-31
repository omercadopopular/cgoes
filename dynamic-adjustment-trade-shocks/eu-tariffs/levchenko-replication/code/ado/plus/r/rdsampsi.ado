********************************************************************************
* RDSAMPSI: sample size calculation for Regression Discontinuity Designs
* !version 2.0 05-Jul-2021
* Authors: Matias Cattaneo, Rocio Titiunik, Gonzalo Vazquez-Bare
********************************************************************************

version 13

capture program drop rdsampsi
program define rdsampsi, rclass

	syntax [anything] [if] [in] [, c(real 0) tau(numlist max=1) alpha(real .05) beta(real 0.8) samph(string) NSamples(string) all ///
											 bias(string) VARiance(string) nratio(numlist max=1) init_cond(numlist max=1) ///
											 plot graph_range(string) graph_step(numlist max=1) graph_options(string) ///
											 covs(string) covs_drop(string) deriv(real 0) p(real 1) q(numlist max=1) h(string) b(string) rho(real 0) ///
											 kernel(string) bwselect(string) vce(string) weights(string) ///
											 scalepar(real 1) scaleregul(real 1) fuzzy(string) level(real 95) ///
											 masspoints(string) bwcheck(real 0) bwrestrict(string) stdvars]

											  
	****************************************************************************
	** Options, default values and error checking
	
	marksample touse, novarlist


	local nodata = 0
	if "`anything'" != ""{
		local w: word count `anything'
		if `w'!=2{
			di as error "too few variables specified"
			exit 102
		}
		else {
			tokenize `anything'
			local y `1' 
			local x `2'
		}
	}
	else {
		if "`samph'" != "" & "`nsamples'" != "" & "`bias'" != "" & "`variance'" != "" & "`init_cond'" != "" & "`tau'" != ""{
			local nodata = 1
		}
		else {
			di as error "not enough information specified to calculate sample size without data"
			exit 102
		}
	}
	
	if "`nsamples'" != ""{
		if "`anything'" != "" {
			di as result "nsamples is ignored when varlist specified"
		}
		else {
			tokenize `nsamples'
			local w: word count `nsamples'
			if `w'==4{
				local nminus = `1'
				local n_hnew_l = `2'
				local nplus = `3'
				local n_hnew_r = `4'
			}
			else {
				di as error "insufficient arguments in nsamples"
				exit 198
			}
			capture confirm integer number `nminus'
			if _rc>0{
				di as error "sample sizes have to be integers"
				exit 198
			}
			capture confirm integer number `n_hnew_l'
			if _rc>0{
				di as error "sample sizes have to be integers"
				exit 198
			}
			capture confirm integer number `nplus'
			if _rc>0{
				di as error "sample sizes have to be integers"
				exit 198
			}
			capture confirm integer number `n_hnew_r'
			if _rc>0{
				di as error "sample sizes have to be integers"
				exit 198
			}
			
			if `nplus'<=0 | `n_hnew_l'<=0 | `nminus'<=0 | `n_hnew_r'<=0 {
				di as error "sample sizes have to be >0"
				exit 198
			}
		}
	}

	if "`samph'" != "" {
		tokenize `samph'
		local w: word count `samph'
		if `w'==1{
			local hnew_l = `1'
			local hnew_r = `1'
		}
		if `w'==2{
			local hnew_l = `1'
			local hnew_r = `2'
		}
		if `w'>=3{
			di as error "samph option incorrectly specified"
			exit 125
		}
	}
	
	if "`bias'" != ""{
		tokenize `bias'
		local w: word count `bias'
		if `w'==1{
			di as error "need to specify both Bl and Br"
			exit 125
		}
		if `w'==2{
			local bias_l = `1'
			local bias_r = `2'
		}
		if `w'>=3{
			di as error "bias incorrectly specified"
			exit 125
		}
	}
	
	if "`variance'" != ""{
		tokenize `variance'
		local w: word count `variance'
		if `w'==1{
			di as error "need to specify both Vl and Vr"
			exit 125
		}
		if `w'==2{
			local vl = `1'
			local vr = `2'
		}
		if `w'>=3{
			di as error "variance incorrectly specified"
			exit 125
		}
		if `vl'<=0 | `vr'<=0{
			di as error "variances have to be >0"
			exit 198
		}
		if `nodata' == 1{
			local vl_cl = `vl'
			local vr_cl = `vr'
		}
	}

	if "`covs'" != ""{
		local covs_opt "covs(`covs')"
		local ncovs: word count `covs'
	}
	
	if "`q'"==""{
		local q = `p'+1
	}
	
	if "`h'" != ""{
		local h_opt "h(`h')"
	}
	
	if "`b'" != ""{
		local b_opt "b(`b')"
	}
	
	if "`kernel'" != ""{
		local kernel_opt "kernel(`kernel')"
	}
	
	if "`bwselect'" != ""{
		local bwselect_opt "bwselect(`bwselect')"
	}
	
	if "`vce'" != ""{
		local vce_opt "vce(`vce')"
		local vce1 "`vce'"
		tokenize `vce1'
		local clust_opt `1'
		local clustvar `2'

	}
	
	if "`fuzzy'" != ""{
		local fuzzy_opt "fuzzy(`fuzzy')"
	}
	
	if "`variance'" != "" & "`samph'" == ""{
		di as error "need to set samph when variance is specified"
		exit 198
	}
	
	if "`nratio'" != ""{
		local nratio_cl = `nratio'
		if `nratio'>=1 | `nratio'<=0{
			di as error "nratio has to be in (0,1)"
			exit 198
		}
	}
	
	if "`covs_drop'" != ""{
		local covs_drop_opt "covs_drop(`covs_drop')"
	}
	
	if "`masspoints'" != ""{
		local masspoints_opt "masspoints(`masspoints')"
	}
	
	if "`bwcheck'" != ""{
		local bwcheck_opt "bwcheck(`bwcheck')"
	}
	
	if "`bwrestrict'" != ""{
		local bwrestrict_opt "bwrestrict(`bwrestrict')"
	}
	
	if "`weights'" != ""{
		local weights_opt "weights(`weights')"
	}

	
	****************************************************************************
	** Bias and variance
	
	if `nodata' == 0 {
		
		** Variance

		if "`bias'" == "" | "`variance'" == ""{
			qui rdrobust `y' `x' if `touse', c(`c') all `covs_opt' deriv(`deriv') 	 ///
												p(`p') q(`q') `h_opt' `b_opt' rho(`rho') ///
												`kernel_opt' `bwselect_opt' `vce_opt' 	 ///
												scalepar(`scalepar') scaleregul(`scaleregul') ///
												`fuzzy_opt' level(`level') `covs_drop_opt' ///
												 `masspoints_opt' `bwcheck_opt' `bwrestrict_opt' `stdvars' `weights_opt'
												 
			local hl = e(h_l)
			local hr = e(h_r)
			local n_l = e(N_h_l)
			local n_r = e(N_h_r)
					
			if "`bias'" == ""{
				local bias_l = e(bias_l)/(`hl'^(1+`p'-`deriv'))
				local bias_r = e(bias_r)/(`hr'^(1+`p'-`deriv'))
			}
			
			if "`variance'" == ""{
				mat VL_RB = e(V_rb_l)
				mat VR_RB = e(V_rb_r)
				mat VL_CL = e(V_cl_l)
				mat VR_CL = e(V_cl_r)
				
				if "`clust_opt'"=="cluster" | "`clust_opt'"=="nncluster"{
					qui tab `clustvar' if `x'!=. & `y'!=. & `touse'
					local N = r(r)
				}
				else {
					qui count if `x'!=. & `y'!=. & `touse'
					local N = r(N)
				}
			
				local pos = 1+`deriv'
				local vl = `N'*(`hl'^(1+2*`deriv'))*VL_RB[`pos',`pos']
				local vr = `N'*(`hr'^(1+2*`deriv'))*VR_RB[`pos',`pos']
				local vl_cl = `N'*(`hl'^(1+2*`deriv'))*VL_CL[`pos',`pos']
				local vr_cl = `N'*(`hr'^(1+2*`deriv'))*VR_CL[`pos',`pos']
			}
				
			if "`samph'" == ""{
				local hnew_l= `hl'
				local hnew_r = `hr'
			}
		}
		
		if "`vl_cl'" == "" | "`vr_cl'" == ""{
			local vl_cl = `vl'
			local vr_cl = `vr'
		}
	
	}
	
	** Bias adjustment
	
	local bias = `bias_r'*`hnew_r'^(1+`p'-`deriv') + `bias_l'*`hnew_l'^(1+`p'-`deriv')
	
	** Variance adjustment
	
	local stilde = sqrt(`vl'/(`hnew_l'^(1+2*`deriv'))+ `vr'/(`hnew_r'^(1+2*`deriv')))
	local stilde_cl = sqrt(`vl_cl'/(`hnew_l'^(1+2*`deriv'))+ `vr_cl'/(`hnew_r'^(1+2*`deriv')))


	****************************************************************************
	** Sample size calculation
	
	* Critical value

	local z = invnormal(1-`alpha'/2)
	
	* Set default value of tau
	
	if "`tau'" == ""{
		qui sum `y' if `c'-`hnew_l'<=`x' & `x'<`c' & `touse'
		local sd0 = r(sd)
		local tau = 0.5*`sd0'
	}	
	
	* Set initial value for Newton-Raphson
	
	if "`init_cond'" == ""{
		qui count if `x'!=. & `y'!=. & `touse'
		local N0 = r(N)
	}
	else {
		local N0 = `init_cond'
	}

	* Find m
	
	di as text "Calculating sample size..."
	mata: rdpower_powerNR(`N0',`tau',`stilde',`z',`beta')
	local m = m_rdpower
	
	*** if all!=""?
	mata: rdpower_powerNR(`N0',`tau'+`bias',`stilde_cl',`z',`beta')
	local m_cl = m_rdpower
	di as text "Sample size obtained."

	
	* Adjust m to find sample sizes

	if "`nratio'" == ""{
		local nratio = sqrt(`vr')/(sqrt(`vr')+sqrt(`vl'))
		local nratio_cl = sqrt(`vr_cl')/(sqrt(`vr_cl')+sqrt(`vl_cl'))
	}

	if `nodata' == 0 {
		if "`clust_opt'"=="cluster" | "`clust_opt'"=="nncluster"{
		
			qui tab `clustvar' if `x'!=. & `y'!=. & `touse'
			local N = r(r)
			
			qui tab `clustvar' if `x'>=`c' & `x'!=. & `y'!=. & `touse'
			local nplus = r(r)
			
			qui tab `clustvar' if `x'<`c' & `x'!=. & `y'!=. & `touse'
			local nminus = r(r)
			
			qui tab `clustvar' if `x'>=`c'&`x'<=`c'+`hnew_r'  & `x'!=. & `y'!=. & `touse'
			local n_hnew_r = r(r)
			
			qui tab `clustvar' if `x'<`c'&`x'>=`c'-`hnew_l'  & `x'!=. & `y'!=. & `touse'
			local n_hnew_l = r(r)	
			
		}
		else {
			qui count if `x'!=. & `y'!=. & `touse'
			local N = r(N)
			
			qui count if `x'>=`c' & `x'!=. & `y'!=. & `touse'
			local nplus = r(N)
			
			qui count if `x'<`c' & `x'!=. & `y'!=. & `touse'
			local nminus = r(N)
			
			qui count if `x'>=`c'&`x'<=`c'+`hnew_r'  & `x'!=. & `y'!=. & `touse'
			local n_hnew_r = r(N)
			
			qui count if `x'<`c'&`x'>=`c'-`hnew_l'  & `x'!=. & `y'!=. & `touse'
			local n_hnew_l = r(N)	
		}
	}
	
	local denom = `nratio'*`nplus'/`n_hnew_r' + (1-`nratio')*`nminus'/`n_hnew_l'
	local denom_cl = `nratio_cl'*`nplus'/`n_hnew_r' + (1-`nratio_cl')*`nminus'/`n_hnew_l'	
	
	local M = `m'/`denom'
	local Mr = ceil(`M'*`nratio')
	local Ml = ceil(`M'*(1-`nratio'))
	local M = `Ml' + `Mr'
	
	local M_cl = `m_cl'/`denom_cl'
	local Mr_cl = ceil(`M_cl'*`nratio_cl')
	local Ml_cl = ceil(`M_cl'*(1-`nratio_cl'))
	local M_cl = `Ml_cl' + `Mr_cl'
	

	****************************************************************************
	** Descriptive statistics for display
	
	if `nodata'== 0 {
		* Left panel
		
		if "`clust_opt'"=="cluster" | "`clust_opt'"=="nncluster"{
			qui tab `clustvar' if `x'>=`c' & `x'!=. & `y'!=. & `touse'
			local gplus = r(r)
			
			qui tab `clustvar' if `x'<`c' & `x'!=. & `y'!=. & `touse'
			local gminus = r(r)
		}

		qui count if `x'>=`c' & `x'!=. & `y'!=. & `touse'
		local nplus_disp = r(N)
		
		qui count if `x'<`c' & `x'!=. & `y'!=. & `touse'
		local nminus_disp = r(N)
		
		if "`hl'" == "" | "`hr'" == ""{
			local hl = `hnew_l'
			local hr = `hnew_r'
		}
		
		qui count if `x'>=`c'&`x'<=`c'+`hr'  & `x'!=. & `y'!=. & `touse'
		local n_hnew_r_disp = r(N)
		
		qui count if `x'<`c'&`x'>=`c'-`hl'  & `x'!=. & `y'!=. & `touse'
		local n_hnew_l_disp = r(N)	
		
		* Right panel
		
		qui count if `x'!=. & `y'!=. & `touse'
		local N_disp = r(N)
		
		if "`bias'" == "" | "`variance'" == ""{
			local bwselect = e(bwselect)
			local kernel_type = e(kernel)
			local vce_type = e(vce_select)
		}
		else {
			local bwselect = .
			local kernel_type = .
			local vce_type = .
		}
	}
	
	if `nodata' == 1{
		
		* Left panel
		
		if "`clust_opt'"=="cluster" | "`clust_opt'"=="nncluster"{
			local gplus = .
			local gminus = .
		}
		
		local nplus_disp = .
		local nminus_disp = .
		local n_hnew_r_disp = .
		local n_hnew_l_disp = .
		
		local hl = .
		local hr = .
		local p = .
		
		* Right panel
		
		local N_disp = .
		
		local bwselect = .
		local kernel_type = .
		local vce_type = .

	}
	
	* Size distortion
	
	local se_cl_aux = `stilde_cl'/sqrt(`m_cl')
	local size_dist = 1 - normal(`bias'/`se_cl_aux'+`z') ///
						+ normal(`bias'/`se_cl_aux'-`z')
	
	
	
	****************************************************************************
	** Display output
	
	disp ""
	disp as text "{ralign 21: Cutoff c = `c'}"      _col(22) " {c |} " _col(23) in gr "Left of " in yellow "c"  _col(36) in gr "Right of " in yellow "c"  _col(54) as text "Number of obs = "  in yellow %10.0f `N_disp'
	disp as text "{hline 22}{c +}{hline 22}"                                                                                                              _col(54) as text "BW type       = "  in yellow "{ralign 10:`bwselect'}" 
	disp as text "{ralign 21:Number of obs}"        _col(22) " {c |} " _col(23) as result %9.0f `nminus_disp'   _col(37) %9.0f  `nplus_disp'              _col(54) as text "Kernel        = "  in yellow "{ralign 10:`kernel_type'}" 
	disp as text "{ralign 21:Eff. Number of obs}"   _col(22) " {c |} " _col(23) as result %9.0f `n_hnew_l_disp' _col(37) %9.0f  `n_hnew_r_disp'           _col(54) as text "VCE method    = "  in yellow "{ralign 10:`vce_type'}" 
	disp as text "{ralign 21:BW loc. poly. (h)}"	_col(22) " {c |} " _col(23) as result %9.3f `hl'     	    _col(37) %9.3f  `hr'					  _col(54) as text "Derivative    = "  in yellow %10.0f `deriv'
	disp as text "{ralign 21:Order loc. poly. (p)}"	_col(22) " {c |} " _col(23) as result %9.0f `p'     	    _col(37) %9.0f  `p'					      _col(54) as text "HA:       tau = "  in yellow %10.3f `tau'
	disp as text "{hline 22}{c +}{hline 22}"																											  _col(54) as text "Power         = "  in yellow %10.3f `beta'
	if "`all'" != ""{
		disp as text "{ralign 21:Sampling BW}"			_col(22) " {c |} " _col(23) as result %9.3f `hnew_l'    	_col(37) %9.3f  `hnew_r'			  _col(54) as text "Size dist.    = "  in yellow %10.3f `size_dist' 
	}
	else {
		disp as text "{ralign 21:Sampling BW}"			_col(22) " {c |} " _col(23) as result %9.3f `hnew_l'    	_col(37) %9.3f  `hnew_r'
	}
	if "`clust_opt'"=="cluster" | "`clust_opt'"=="nncluster" {
			disp in smcl in gr "{ralign 21:Number of clusters}"   _col(22) " {c |} " _col(23) as result %9.0f `gplus'   _col(37) %9.0f  `gminus' 
	}
	
	di ""
	if `nodata' == 0{
		if "`covs'" == ""{
			di as text _newline "Outcome: " as res "`y'" as text ". Running variable: " as res "`x'" as text "."
		}
		else {
			di as text _newline "Outcome: " as res "`y'" as text ". Running variable: " as res "`x'" as text ". Number of covariates: " as res "`ncovs'" as text"."
		}
	}
	
	di as text "{hline 22}{c TT}{hline 56}"
	di as text "Chosen sample sizes" 				_col(22) " {c |}"	  _col(35) "Sample size in window"										_col(70) "Proportion"
	di as text 						 				_col(22) " {c |}"	  _col(27) "[c-h,c)"			_col(41) "[c,c+h]"	_col(56) "Total"	_col(72) "[c,c+h]"
	di as text "{hline 22}{c +}{hline 56}"

	di as text "{ralign 21:Robust bias-corrected}"	_col(22) " {c |} " 	_col(27) as result  %7.0f `Ml'   	_col(41) %7.0f `Mr'  	_col(54) %7.0f `M'    	 _col(75) %5.3f `nratio'
	if "`all'" !="" {
			di as text "{ralign 21:Conventional}"	_col(22) " {c |} "  _col(27) as result  %7.0f `Ml_cl'   _col(41) %7.0f `Mr_cl'  _col(54) %7.0f `M_cl'    _col(75) %5.3f `nratio_cl'
	}
	di as text "{hline 22}{c BT}{hline 56}"

	if "`clust_opt'"=="cluster" | "`clust_opt'"=="nncluster" {
			disp as text "Standard errors clustered by " as res "`clustvar'" as text "."
	}
	
	
	****************************************************************************
	** Power function plot

	if "`plot'" != "" {
	
		qui count if `x'!=. & `y'!=.
		local N_plot = r(N)
	
		local tau_round = round(`tau',.01)
		
		if "`graph_range'" != ""{
			tokenize `graph_range'
			local left `1'
			local right `2'
		}
		else {
			local left = 0
			local right = `N_plot'
		}
		if "`graph_step'" != ""{
			local step `graph_step'
		}
		else {
			local step = ceil(`N_plot'/10)
		}
		if "`graph_options'" == "" {
		
			if "`all'" != ""{
				twoway (function y = 1 - normal(sqrt(x*`denom')*`tau'/`stilde'+`z') ///
									 + normal(sqrt(x*`denom')*`tau'/`stilde'-`z'), ///
							range(`left' `right')) ///				   
						(function y = 1 - normal(sqrt(x*`denom_cl')*(`tau'+`bias')/`stilde_cl'+`z') ///
									 + normal(sqrt(x*`denom_cl')*(`tau'+`bias')/`stilde_cl'-`z'), ///
							range(`left' `right')), ///
				   yline(`beta', lpattern(shortdash) lcolor(black)) ///
				   xline(`M', lcolor(eltgreen) lpattern(shortdash) lwidth(vthin)) ///
				   xline(`M_cl', lcolor(eltgreen) lpattern(shortdash) lwidth(vthin)) ///
				   legend(label(1 "robust bias corrected") label(2 "conventional"))	///
				   ytitle("power") xtitle("total sample size in window") xlabel(`left'(`step')`right') ///
				   note("Power function for tau = `tau_round', alpha = `alpha', beta = `beta' (horizontal dashed line).")
			}
			else {
				twoway (function y = 1 - normal(sqrt(x*`denom')*`tau'/`stilde'+`z') ///
									 + normal(sqrt(x*`denom')*`tau'/`stilde'-`z'), ///
							range(`left' `right')), ///	
				   yline(`beta', lpattern(shortdash) lcolor(black) lwidth(thin)) ///
				   xline(`M', lcolor(eltgreen) lpattern(shortdash) lwidth(vthin)) ///
				   legend(label(1 "robust bias corrected"))	///
				   ytitle("power") xtitle("total sample size in window") xlabel(`left'(`step')`right') ///
				   note("Power function for tau = `tau_round', alpha = `alpha', beta = `beta' (horizontal dashed line).")
			}
		}
		else {
			if "`all'" != "" {
				twoway (function y = 1 - normal(sqrt(x*`denom')*`tau'/`stilde'+`z') ///
									 + normal(sqrt(x*`denom')*`tau'/`stilde'-`z'), ///
							range(`left' `right')) ///				   
						(function y = 1 - normal(sqrt(x*`denom_cl')*(`tau'+`bias')/`stilde_cl'+`z') ///
									 + normal(sqrt(x*`denom_cl')*(`tau'+`bias')/`stilde_cl'-`z'), ///
							range(`left' `right')), ///
				    legend(label(1 "robust bias corrected") label(2 "conventional"))	///
					xlabel(`left'(`step')`right') `graph_options'
			}
			else {
				twoway (function y = 1 - normal(sqrt(x*`denom')*`tau'/`stilde'+`z') ///
									 + normal(sqrt(x*`denom')*`tau'/`stilde'-`z'), ///
							range(`left' `right')), ///	
				    legend(label(1 "robust bias corrected"))	///
					xlabel(`left'(`step')`right') `graph_options'
			}
		}
	}
	
	
	
	****************************************************************************
	** Return values

	return scalar init_cond = `N0'
	return scalar no_iter = iter_rdpower
	if "`all'" != ""{
		return scalar sampsi_h_tot_cl = `M_cl'
		return scalar sampsi_h_r_cl = `Mr_cl'
		return scalar sampsi_h_l_cl = `Ml_cl'
		return scalar sampsi_tot_cl = `m_cl'
		return scalar var_r_cl = `vr_cl'
		return scalar var_l_cl = `vl_cl'
	}
	return scalar sampsi_h_tot = `M'
	return scalar sampsi_h_r = `Mr'
	return scalar sampsi_h_l = `Ml'
	return scalar sampsi_tot = `m'
	return scalar N_r = `nplus'
	return scalar N_l = `nminus'
	return scalar N_h_r = `n_hnew_r'
	return scalar N_h_l = `n_hnew_l'
	return scalar bias_r = `bias_r'
	return scalar bias_l = `bias_l'
	return scalar var_r = `vr'
	return scalar var_l = `vl'
	return scalar samph_r = `hnew_r'
	return scalar samph_l = `hnew_l'
	return scalar tau = `tau'
	return scalar beta = `beta'
	return scalar alpha = `alpha'

end

