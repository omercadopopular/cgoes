********************************************************************************
* RDMDE: minimum detectable effect calculation for Regression Discontinuity Designs
* !version 2.0 05-Jul-2021
* Authors: Matias Cattaneo, Rocio Titiunik, Gonzalo Vazquez-Bare
********************************************************************************

version 13

capture program drop rdmde
program define rdmde, rclass

	syntax [anything] [if] [in] [, c(real 0) alpha(real .05) beta(real 0.8) samph(string) NSamples(string) sampsi(string) all ///
											 bias(string) VARiance(string) nratio(numlist max=1) init_cond(numlist max=1) ///
											 covs(string) covs_drop(string) deriv(real 0) p(real 1) q(numlist max=1) h(string) b(string) rho(real 0) ///
											 kernel(string) bwselect(string) vce(string) weights(string) ///
											 scalepar(real 1) scaleregul(real 1) fuzzy(string) level(real 95) ///
											 masspoints(string) bwcheck(real 0) bwrestrict(string) stdvars]

											  
	****************************************************************************
	** Options, default values and error checking
	
	marksample touse, novarlist

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
	
	local nodata = 0
	if "`nsamples'" != ""{
		if "`anything'" != "" {
			di as result "nsamples is ignored when varlist specified"
		}
		else {
			if "`bias'" != "" & "`variance'" != "" & "`samph'" != "" & "`init_cond'" != ""{
				local nodata = 1
			}
			else {
				di as error "not enough information specified to calculate power without data"
				exit 102
			}
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
	
	if "`sampsi'" != ""{
		tokenize `sampsi'
		local w: word count `sampsi'
		if `w'==1{
			local ntilde_l = `1'
			local ntilde_r = `1'
		}
		if `w'==2{
			local ntilde_l = `1'
			local ntilde_r = `2'
		}
		if `w'>=3{
			di as error "sampsi incorrectly specified"
			exit 125
		}
		
		capture confirm integer number `ntilde_l'
		if _rc>0{
			di as error "sample sizes in sampsi have to be integers"
			exit 198
		}
		capture confirm integer number `ntilde_r'
		if _rc>0{
			di as error "sample sizes in sampsi have to be integers"
			exit 198
		}
		
		if `ntilde_l'<=0 | `ntilde_r'<=0{
			di as error "sample sizes in sampsi have to be >0"
			exit 198
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
			local Vl_rb = `1'
			local Vr_rb = `2'
		}
		if `w'>=3{
			di as error "variance incorrectly specified"
			exit 125
		}
		if `Vl_rb'<=0 | `Vr_rb'<=0{
			di as error "variances have to be >0"
			exit 198
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

		if "`bias'" == "" | "`variance'" == ""{
			qui rdrobust `y' `x' if `touse', c(`c') all `covs_opt' deriv(`deriv') 	 ///
				p(`p') q(`q') `h_opt' `b_opt' rho(`rho') ///
				`kernel_opt' `bwselect_opt' `vce_opt' 	 ///
				scalepar(`scalepar') scaleregul(`scaleregul') ///
				level(`level') `fuzzy_opt' `covs_drop_opt' ///
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
				mat VL_CL = e(V_cl_l)
				mat VR_CL = e(V_cl_r)
				mat VL_RB = e(V_rb_l)
				mat VR_RB = e(V_rb_r)

				if "`clust_opt'" == "cluster" | "`clust_opt'" == "nncluster"{
					qui tab `clustvar' if `x'!=. & `y'!=. & `touse'
					local N = r(r)
				}
				else {
					qui count if `x'!=. & `y'!=. & `touse'
					local N = r(N)
				}

				local pos = 1+`deriv'
				local Vl_cl = `N'*(`hl'^(1+2*`deriv'))*VL_CL[`pos',`pos']
				local Vr_cl = `N'*(`hr'^(1+2*`deriv'))*VR_CL[`pos',`pos']
				local Vl_rb = `N'*(`hl'^(1+2*`deriv'))*VL_RB[`pos',`pos']
				local Vr_rb = `N'*(`hr'^(1+2*`deriv'))*VR_RB[`pos',`pos']

			}

		}

		** set default new bandwidth

		if "`samph'" == ""{
			local hnew_l = `hl'
			local hnew_r = `hr'
		}


		** Calculate sample sizes

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
			qui count if `x'!=. & `y'!=. `ifcond1' `in'
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

	if "`sampsi'" == ""{
			local ntilde_l = `n_hnew_l'
			local ntilde_r = `n_hnew_r'
	}
	
	local ntilde = `nplus'*`ntilde_r'/`n_hnew_r' + `nminus'*`ntilde_l'/`n_hnew_l'

	****************************************************************************
	** Variance and bias adjustment
	
	** Variance adjustment
	
	local V_rbc = `Vl_rb'/(`hnew_l'^(1+2*`deriv')) + `Vr_rb'/(`hnew_r'^(1+2*`deriv'))
	local stilde = sqrt(`V_rbc')
	
	if "`all'" != "" {
		local V_conv =  `Vl_cl'/(`hnew_l'^(1+2*`deriv')) + `Vr_cl'/(`hnew_r'^(1+2*`deriv'))
		local stilde_conv = sqrt(`V_conv')
	}
	else {
		local V_conv = `V_rbc'
		local stilde_conv = `stilde'
	}
	
	** Bias adjustment 
			
	local bias = `bias_r'*`hnew_r'^(1+`p'-`deriv') + `bias_l'*`hnew_l'^(1+`p'-`deriv')
	
	****************************************************************************
	** MDE calculation
	
	* Critical value

	local z = invnormal(1-`alpha'/2)
	
	* Set initial value for Newton-Raphson
	
	if "`init_cond'" == ""{
		qui sum `y' if `x'<`c' & `touse'
		local tau0 = 0.2*r(sd)
	}
	else {
		local tau0 = `init_cond'
	}

	* Find MDE
	
	di as text "Calculating MDE..."
	mata: rdpower_powerNR_mde(`ntilde',`tau0',`stilde',`z',`beta')
	local mde = mde_rdpower
	
	local count = 1
	foreach r of numlist -0.125 -0.0625 0.0625 0.125{
		local b_aux = `beta'*(1+`r')
		if `b_aux'<1{
			mata: rdpower_powerNR_mde(`ntilde',`tau0',`stilde',`z',`b_aux')
			local mde_`count' = mde_rdpower
		}
		local ++count
	}

	if "`all'"!=""{
		local count = 1
		mata: rdpower_powerNR_mde(`ntilde',`tau0'+`bias',`stilde_conv',`z',`beta')
		local mde_cl = mde_rdpower
		foreach r of numlist -0.125 -0.0625 0.0625 0.125{
			local b_aux = `beta'*(1+`r')
			if `b_aux'<1{
				mata: rdpower_powerNR_mde(`ntilde',`tau0'+`bias',`stilde_conv',`z',`b_aux')
				local mde_cl_`count' = mde_rdpower
			}
			local ++count
		}
	}
	di as text "MDE obtained."
	

	** Descriptive statistics for display
	
		
	if `nodata' == 0 {
	
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
		local n_h_r_disp = r(N)
		
		qui count if `x'<`c'&`x'>=`c'-`hl'  & `x'!=. & `y'!=. & `touse'
		local n_h_l_disp = r(N)
		
		if "`hl'" == "" | "`hr'" == ""{
			local hl = .
			local hr = .
		}
		
		* Right panel

		qui count if `x'!=. & `y'!=. `ifcond1' `in'
		local N_disp = r(N)

		if "`bias_cond'" != "" & "`variance'" != ""{
			local bwselect = .
			local kernel_type = .
			local vce_type = .	
		}
		else {
			local bwselect = e(bwselect)
			local kernel_type = e(kernel)
			local vce_type = e(vce_select)
		}
	}
	
	if `nodata' == 1 {
		
		* Left panel
		
		if "`clust_opt'"=="cluster" | "`clust_opt'"=="nncluster"{
			local gplus = `nplus'
			local gminus = `nminus'
		}

		local nplus_disp = .
		local nminus_disp = .
		local n_h_r_disp = .
		local n_h_l_disp = .
		
		local hl = .
		local hr = .
		local p = .
		
		* Right panel

		local N_disp = .

		local bwselect = .
		local kernel_type = .
		local vce_type = .	
		
	}
	
	
	****************************************************************************
	** Display output

		disp ""
		disp as text "{ralign 21: Cutoff c = `c'}"      _col(22) " {c |} " _col(23) in gr "Left of " in yellow "c"  _col(36) in gr "Right of " in yellow "c"  _col(54) as text "Number of obs = "  in yellow %10.0f `N_disp'
		disp as text "{hline 22}{c +}{hline 22}"                                                                                                              _col(54) as text "BW type       = "  in yellow "{ralign 10:`bwselect'}" 
		disp as text "{ralign 21:Number of obs}"        _col(22) " {c |} " _col(23) as result %9.0f `nminus_disp'        _col(37) %9.0f  `nplus_disp'         _col(54) as text "Kernel        = "  in yellow "{ralign 10:`kernel_type'}" 
		disp as text "{ralign 21:Eff. Number of obs}"   _col(22) " {c |} " _col(23) as result %9.0f `n_h_l_disp'      	 _col(37) %9.0f  `n_h_r_disp'      _col(54) as text "VCE method    = "  in yellow "{ralign 10:`vce_type'}" 
		disp as text "{ralign 21:BW loc. poly. (h)}"	_col(22) " {c |} " _col(23) as result %9.3f `hl'     	    	 _col(37) %9.3f  `hr'				  _col(54) as text "Derivative    = "  in yellow %10.0f `deriv'
		disp as text "{ralign 21:Order loc. poly. (p)}"	_col(22) " {c |} " _col(23) as result %9.0f `p'     	    	 _col(37) %9.0f  `p'				 // _col(54) as text "HA:       tau = "  in yellow %10.3f `tau'

		disp as text "{hline 22}{c +}{hline 22}"

		disp as text "{ralign 21:Sampling BW}"		    _col(22) " {c |} " _col(23) as result %9.3f `hnew_l'    	_col(37) %9.3f  `hnew_r'				  	  
		disp as text "{ralign 21:New sample}"			_col(22) " {c |} " _col(23) as result %9.0f `ntilde_l'  	_col(37) %9.0f  `ntilde_r'
		if "`clust_opt'"=="cluster" | "`clust_opt'"=="nncluster" {
			disp in smcl in gr "{ralign 21:Number of clusters}"   _col(22) " {c |} " _col(23) as result %9.0f `gplus'   _col(37) %9.0f  `gminus' 
		}
		disp ""

		if `nodata' == 0{
			if "`covs'" == ""{
				di as text _newline "Outcome: " as res "`y'" as text ". Running variable: " as res "`x'" as text "."
			}
			else {
				di as text _newline "Outcome: " as res "`y'" as text ". Running variable: " as res "`x'" as text ". Number of covariates: " as res "`ncovs'" as text"."
			}
		}
		
		di as text "{hline 22}{c TT}{hline 56}"
		di as text "MDE for power = " _col(22) " {c |}"	 				   _col(30) as text "beta = "  			        _col(41) "beta = " 		           _col(52) "beta = " 	   _col(63) "beta = " 		                 _col(74) "beta = "
		di 							  _col(22) " {c |}"	 				   _col(29) as result %7.3f  `beta'*(1-0.125)	_col(40) %7.3f `beta'*(1-0.0625)   _col(51) %7.3f `beta'   _col(62) %7.3f min(`beta'*(1+0.0625),1)   _col(73) %7.3f min(`beta'*(1+0.125),1)

		di as text "{hline 22}{c +}{hline 56}"
		di as text "{ralign 21:Robust bias-corrected}"	_col(22) " {c |} " _col(31) as result  %5.3f `mde_1'            _col(42) %5.3f `mde_2'             _col(53) %5.3f `mde'    _col(64) %5.3f `mde_3'  _col(75) %5.3f `mde_4'
		if "`all'" !="" {
			di as text "{ralign 21:Conventional}"		_col(22) " {c |} " _col(31) as result  %5.3f `mde_cl_1'         _col(42) %5.3f `mde_cl_2'          _col(53) %5.3f `mde_cl' _col(64) %5.3f `mde_cl_3' _col(75) %5.3f `mde_cl_4'
		}
		di as text "{hline 22}{c BT}{hline 56}"
		
		if "`clust_opt'"=="cluster" | "`clust_opt'"=="nncluster" {
			disp as text "Standard errors clustered by " as res "`clustvar'" as text "."
		}
	
	****************************************************************************
	** Return values

	return scalar init_cond = `tau0'
	return scalar no_iter = iter_rdpower
	return scalar bias_r = `bias_r'
	return scalar bias_l = `bias_l'
	return scalar Vr_rb = `Vr_rb'
	return scalar Vl_rb = `Vl_rb'
	return scalar beta = `beta'
	return scalar se_rbc = `stilde'
	return scalar sampsi_r = `ntilde_r'
	return scalar sampsi_l = `ntilde_l'
	return scalar samph_r = `hnew_r'
	return scalar samph_l = `hnew_l'
	return scalar N_r = `nplus'
	return scalar N_l = `nminus'
	return scalar N_h_r = `n_hnew_r'
	return scalar N_h_l = `n_hnew_l'
	return scalar mde = `mde'
	return scalar alpha = `alpha'
end

