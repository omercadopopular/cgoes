*! Ver 1.7 adds version for easier update
* Ver 1.68 Bug with drimp
* Ver 1.67 Bug with IPW 
* Ver 1.66 Bug with binit, skip fixed
* Ver 1.65 Bug with binit. Fixed
* Ver 1.64 added binit for faster csdid (if slighly)
* Ver 1.63 added Dryrun
* Ver 1.63 Bug with option all and RC estimator
* Ver 1.62 Added level
* Ver 1.61 Change sample for drimp
* Ver 1.6 Change in check for 2x2 data. And updated site!
* added correction to teffects for ALL
* Ver 1.5   New output, with panel GMM estimators. Also WB standard errors with cluster
* Ver 1.38  Adding Cluster Stantandard errors
* version 1.37 2jun2021 Add extra messages of 2x2 balance. Checks that you indeed have panel data
* version 1.36 17may2021 Changes with EP display options
** Goal. Make the estimator modular. That way other options can be added
* v1.35 DRDID for Stata 
* Added by AN and adapted by FRA
* Added Version control (v14), Variables are no longer left after DRDID. But option stub is added 
* for later, as CSDID will use those
* v1.31 DRDID for Stata by FRA. Adding program for Bootstrap multiplier
* v1.3 DRDID for Stata by FRA Changing ATT RIF creation
* v1.2 DRDID for Stata by FRA All Estimators are ready For panel and RC
* Next help!
* v1.0 DRDID for Stata by FRA All Estimators but IPWRA have are available for panel
* Need to add weights. 
* v0.8 DRDID for Stata by FRA Other estimators are available. Onlyone missing iwp panel
* v0.7 DRDID for Stata by FRA IPW estimator for panel (Asjad original Rep)
* v0.5 DRDID for Stata by FRA Incorporates RC1 and RC2 estimators
* v0.2 DRDID for Stata by FRA Fixes typo with tag
* v0.2 DRDID for Stata by FRA Allows for Factor notation
* v0.1 DRDID for Stata by FRA Typo with ID TIME
/* !! epg: added method gmm . Also added parsing routing _Vce_Parse
      gmm and vce(...)                     
*/ 
/* !! epg: what to do with bootstrap csboot(csboot_opts)
				csboot_opts -- reps() 
				            -- rseed()
							-- wbtype()
							-- ...
							Perfecto ya todo fue integrado
  !! Crear la tabla Funciona
  !! Necesitamos regresar e(V) o solamente e(b)?
     Creo que ya esta. 
  !! Deberia cambiar el t estadistico?
	 
*/
/*
csdid loop over 
*/

program define drdid, eclass byable(onecall)
        version 14
        if _by() {
                local BY `"by `_byvars'`_byrc0':"'
        }

        `BY' _vce_parserun drdid, noeqlist jkopts(eclass): `0'
        
        if "`s(exit)'" != "" {
                ereturn local cmdline `"drdid `0'"'
                exit
        }
		
		syntax [anything(everything)], [* version]
		/**Version**/
		if   "`version'"!="" {
			display "version: 1.7"
			addr scalar version = 1.7
			exit
		}
		
        if replay() {
                if `"`e(cmd)'"' != "drdid" { 
                        error 301
                }
                else if _by() { 
                        error 190 
                }
                else {
                        Display `0'
                }
                exit
        }
		if runiform()<.001 {
			easter_egg
		}
        `vv' ///
        `BY' drdid_wh `0'
        ereturn local cmdline `"drdid `0'"'
		
end

mata
void is_2x2(string scalar time, treat, touse, isok){ 
    real matrix dta
 	
	dta=st_data(.,time,touse),st_data(.,treat,touse)
	dta=uniqrows(dta)
	if ((rows(dta)==4) & (rows(uniqrows(dta[,1]))==2) & (rows(uniqrows(dta[,2]))==2)) st_numscalar(isok,1)
	else st_numscalar(isok,0)
}
	

void is_balp(string scalar ivar, touse, balp){ 
    real matrix dta
 	dta=st_data(.,ivar,touse)
	st_numscalar(balp,mean(uniqrows(dta,2)[,2]))
} 
end

program define drdid_wh, eclass sortpreserve byable(recall)
	syntax varlist(fv numeric) [if] [in] [iw],			///
							[Ivar(varname)] 			///
							Time(varname) 				///
							TReatment(varname) 			///
							[noisily 					///
							drimp 						///
							dripw 						///
							reg 						///
							stdipw 						///
							ipw 						///
							ipwra 						///
							all  						///
							rc1 						///
							WBOOT(string) 				///
							WBOOT1						///
							*reps(int 999) 				///
							*wbtype(int 1)  			/// Hidden option
							rseed(str)					/// set seed
							Level(int 95)				/// CI level
							stub(name) replace 			/// to avoid overwritting
							cluster(varname)			/// For Cluster
							vce(string)					///
							gmm							///
							pscore(string)				///
							csdid						///
							binit(string)				///
							dryrun						///
							*							///
							]  
    * so it returns Nothing								
	if "`dryrun'"!="" error 1111
	
	_get_diopts diopts other, `options' 
	quietly capture Display, `diopts' `other' level(`level')	
	if _rc==198 {
		Display, `diopts' `other'  level(`level')     
	}


	marksample touse
	markout `touse' `ivar' `time' `treatment'  `cluster'
	
	_Vce_Parse if `touse',  `gmm' `wboot1' wboot(`wboot') vce(`vce')
** Move this into VCE_parse
	*if "`binit'"!="" 	local  binit `binit', skip
	local semethod "`r(semethod)'"
	
	if ("`semethod'"=="wildboot") {
	    local wboot "wboot"
		local reps = r(reps)
		local wbtype = r(wbtype)
	}
	
	 ** Verify 2x2 data
	tempname isok
	mata:is_2x2("`time'","`treatment'","`touse'","`isok'")
	if scalar(`isok')==0 {
	    display in red "You do not have a 2x2 design."
		error 555
	}	
			
			
	if "`cluster'"==""  local cluster "`r(cluster)'"
		
	if "`cluster'"!=""  {
		tempvar clvar
		qui:egen double `clvar' = group(`cluster') if `touse'
		local ocluster `cluster'
		local cluster `clvar'
	}
	
	if "`rseed'"=="" 	local rseed    "`r(seed)'"
	
	capture:set seed `rseed'
	
 	**# Verifies if data is panel data when "ivar" is declared
	if "`ivar'"!="" {
		capture xtset
		if _rc!=0 {
			qui:xtset `ivar' `time'
			qui:xtset ,  clear
		}
		if "`cluster'"!="" {
			_xtreg_chk_cl2 `cluster' `ivar'
		}
		
		**# verify ALL data is locally balanced
		tempname balp
 		*mata:is_balp("`ivar'", "`touse'", "`balp'")
		qui:bysort `touse' `ivar':gen `balp'=_N if `touse'
		sum `balp', meanonly
		if r(mean)<2 {
			display in red "{p}Some panel units are observed only once.{p_end}" _n ///
						   "{p}Those observations will be excluded from the sample. " ///
						   "If you want to keep them, do not use `ivar' as the panel id -ivar-, " ///
						   "which will request repeated crossection estimators {p_end}"
			quietly replace `touse' = 0 if `balp'==1
		}
	}
	
**# Verifies If variable exists. For CSDID
		
	cap unab allnew: `stub'att* 
	if "`stub'"!="" & "`replace'"=="" & "`allnew'"!="" {
		foreach v of var `allnew' {
			conf new var `v'
		}
	}
	
	*** Add Char to variables. They will be ours. Perhaps for CSDID
**# Verifies REPS is a number
	

	** Which option 
	if "`drimp'`dripw'`reg'`stdipw'`ipw'`ipwra'`all'"=="" {
	    display "No estimator selected. Using default {bf:drimp}"
		local drimp drimp
	}
	else {
	    if `:word count `drimp' `dripw' `reg' `stdipw' `ipw' `ipwra' `all' '!=1 {
		    display "Only one option allowed, more than 1 selected."
			error 1
		}
	}

	_S__est, `drimp' `dripw' `reg' `stdipw' `ipw' `ipwra' `all'
	local estimator "`s(estimator)'"

	** First determine outcome and xvars
	gettoken y xvar:varlist
	** Sanity Checks for Time. Only 2 values
	** just in case for xvar not be empty
	*local xvar `xvar'
	tempvar vals vals2 vals3
 
	
	tempvar tmt
	qui:egen byte `tmt'=group(`time') if `touse'
	qui:replace `tmt'=`tmt'-1	    
	tempvar trt
	qui:egen byte `trt'=group(`treatment') if `touse'
	qui:replace `trt'=`trt'-1
	
	** Sanity Check Weights
	** Weights
	if "`exp'"=="" {
	    tempname wgt
		gen byte `wgt'=1
	}
	else {
		tempvar wgt
		qui:gen double `wgt'`exp'
		qui:sum `wgt' if `touse' & `tmt'==0, meanonly
		qui:replace `wgt'=`wgt'/r(mean)
	}
	
	
	**# Here we collect all options
	** This are all the options send to DRDID 
	
	local 01 touse(`touse') tmt(`tmt') trt(`trt') y(`y') 	///
			 xvar(`xvar') `isily' ivar(`ivar') 	///
			 weight(`wgt') stub(`stub') ///
			  treatvar(`treatment') `rc1' cluster(`cluster') ///
			 `wboot' reps(`reps')  wbtype(`wbtype') level(`level')  binit(`binit')
			 *seed(`seed') 
		
	** Default will be IPT 
 	if "`estimator'"!="all" {
		if ("`semethod'"!="gmm") {
			drdid_`estimator', `01' `diopts' 
			ereturn local semethod `semethod'
			ereturn local clustvar `ocluster'
			ereturn local seed     `rseed'
			if "`ivar'"!="" ereturn local datatype "panel"
			else            ereturn local datatype "rcs"
			Display, bmatrix(e(b)) vmatrix(e(V)) `diopts' level(`level')
			exit 
		}
		else {
			tempvar touse2
			tempname b V 
			
			if ("`ivar'"=="") {
				local repeated repeated
				if ("`estimator'"=="sipwra") {
					display as error ///
					"{bf:ipwra} not allowed with {bf:gmm} and repeated"	///
					" cross-sectional data"	
					exit 198
				}
			}
			
			if "`weight'" != "" {
				local wgtgmm [`weight' `exp']
			}
			quietly generate byte `touse2' = . if `touse'

			_het_did_gmm `y' `xvar' if `touse' `wgtgmm', 				///
						  estimator(`estimator') groupvar(`ivar')		///
						  psvars(`xvar') treatvar(`trt')				///
						  timevar(`time') vce(`vce') touse2(`touse2')	///
						  t0(`tmt') pscore(`pscore') `repeated'			///
						  treatname(`treatment')

			matrix `b' = r(b)
			matrix `V' = r(V)
			local vce "`r(vce)'"
			local vcetype "`r(vcetype)'"
			local N = e(N)
			if ("`vce'"=="cluster") {
				local N_clust = r(N_clust)
				local clustvar "`r(clustvar)'"
			}
			ereturn post `b' `V', buildfvinfo esample(`touse2') obs(`N')
			ereturn local cmd drdid
			ereturn local method  `drimp'`dripw'`reg'`stdipw'`aipw'`ipwra'`all'
			ereturn local semethod `semethod'
			
			if ("`vce'"=="cluster") {
				ereturn scalar N_clust = `N_clust'
				ereturn local clustvar "`clustvar'"
			}
			ereturn local vce "`vce'"
			ereturn local vcetype "`vcetype'"
			ereturn local policy "`treatment'"
			ereturn hidden local method2 ///
				`drimp'`dripw'`reg'`stdipw'`aipw'`ipwra'`all'	
			Display, bmatrix(e(b)) vmatrix(e(V)) `diopts' 
			exit 
		}
	
	
	}
	 
	if "`estimator'"=="all" {
	** DR
	tempvar ttouse
	    qui:clonevar `ttouse'=`touse'
		tempname bb VV
		qui:drdid_dripw , `01'
 		matrix `bb' = nullmat(`bb')\e(b)
		matrix `VV' = nullmat(`VV')\e(V)
		local clname ATET:dripw	
		**capture drop `stub'att_dripw
		*ren `stub'att  `stub'att_dripw
		if "`ivar'"=="" {
			qui:capture gen byte `touse'=`ttouse'
			qui:drdid_dripw , `01' rc1 
			matrix `bb' = nullmat(`bb')\e(b)
			matrix `VV' = nullmat(`VV')\e(V)
			local clname `clname' ATET:dripw_rc1
			**capture drop `stub'att_dripwrc
			*clonevar `stub'att_dripwrc=`stub'att
		}
	** DRIMP	
		qui:capture gen byte `touse'=`ttouse'
 	    qui:drdid_imp , `01'
		matrix `bb' = nullmat(`bb')\e(b)
		matrix `VV' = nullmat(`VV')\e(V)
		local clname `clname' ATET:drimp
		**capture drop `stub'att_drimp
		*ren `stub'att  `stub'att_drimp
		
		if "`ivar'"=="" {
			qui:capture gen byte `touse'=`ttouse'
		    qui:drdid_imp , `01' rc1 
			matrix `bb' = nullmat(`bb')\e(b)
			matrix `VV' = nullmat(`VV')\e(V)
			local clname `clname' ATET:drimp_rc1
			**capture drop `stub'att_drimprc
			*ren `stub'att  `stub'att_drimprc
		}
	** REG
		qui:capture gen byte `touse'=`ttouse'
		qui:drdid_reg , `01'
		matrix `bb' = nullmat(`bb')\e(b)
		matrix `VV' = nullmat(`VV')\e(V)
		local clname `clname' ATET:reg
		**capture drop `stub'att_reg
		*ren `stub'att  `stub'att_reg
	** TRAD_IPW	
		qui:capture gen byte `touse'=`ttouse'
	    qui:drdid_aipw , `01'
		matrix `bb' = nullmat(`bb')\e(b)
		matrix `VV' = nullmat(`VV')\e(V)
		local clname `clname' ATET:ipw
		**capture drop `stub'att_ipw
		*ren `stub'att  `stub'att_ipw
	** STD IPW	
		qui:capture gen byte `touse'=`ttouse'
		qui:drdid_stdipw , `01'
		matrix `bb' = nullmat(`bb')\e(b)
		matrix `VV' = nullmat(`VV')\e(V)
		**capture drop `stub'att_stdipw
		*ren `stub'att  `stub'att_stdipw
		local clname `clname' ATET:stdipw
		if "`ivar'"!="" {
			qui:capture gen byte `touse'=`ttouse'
			qui:drdid_sipwra , `01'
			matrix `bb' = nullmat(`bb')\e(b)
			matrix `VV' = nullmat(`VV')\e(V)
			local clname `clname' ATET:sipwra
		}
		matrix `bb'=`bb''
		matrix colname `bb' = `clname'
		matrix `VV'=diag(`VV')
		matrix colname `VV' = `clname'		
		matrix rowname `VV' = `clname'
		ereturn post `bb' `VV'
		*ereturn display
	}
	
	ereturn local cmd drdid
	ereturn local policy "`treatment'"
	ereturn local method         `drimp'`dripw'`reg'`stdipw'`aipw'`ipwra'`all'
	ereturn hidden local method2 `drimp'`dripw'`reg'`stdipw'`aipw'`ipwra'`all'	

    Display, bmatrix(e(b)) vmatrix(e(V)) `diopts' level(`level')
end

program define _Vce_Parse, rclass
	syntax [anything] [if] [in], [gmm WBOOT1 vce(string) WBOOT(string)]
	
	marksample touse 
	
	local semethod standard
	if (("`wboot'"!=""|"`wboot1'"!="") & "`vce'"!="") {
			opts_exclusive "vce wboot"    
	}
	if ("`gmm'"!="" & ("`wboot'"!=""|"`wboot1'"!="")) {
		opts_exclusive "gmm wboot"
		local semethod gmm 
	}
	else if ("`gmm'"!="") {
		local semethod "gmm"
	}
	else if (("`wboot'"!=""|"`wboot1'"!="")) {
		if ("`wboot'"!="" & "`wboot1'"!="") {
			display as error "incorrect wildbootstrap specification"
			di as txt "{p 4 4 2}"                           
			di as smcl as err ///
			"You may specify {bf:wboot} or "        			///
			"{bf:wboot()} with arguments but not both."      
			di as smcl as err  "{p_end}"
			exit 198
		}
		local semethod "wildboot"   
		_Parse_Wildboot if `touse', `wboot1' `wboot'
		local seed   "`r(seed)'"
		local reps   = r(reps)
		local wbtype = r(wbtype)
		local cluster "`r(cluster)'"
		if ("`cluster'"!="") {
		    local wncl = r(wncl)
			return scalar wncl = r(wncl)
		}
		return local cluster "`cluster'"
		return local seed "`seed'"
		return local reps = `reps'
		return local wbtype = `wbtype'
	}
	if ("`vce'"!="") {
			_Vce_Parse_Clust, vce(`vce') `gmm'
			return local cluster "`s(cluster)'"
	}
	return local semethod "`semethod'"
end

program _Parse_Wildboot, rclass 
	syntax [anything] [if] [in], [			///
					   WBOOT1				///
					   reps(integer 999) 	///
					   rseed(string) 		///
					   wbtype(string)		///
					   cluster(string)		///
					   ]

	marksample touse 
	
	if ("`wboot1'"=="") {
		return local reps = `reps'
		return local seed "`rseed'"
		if ("`wbtype'"=="") {
		    local wbtypen = 1
		}
		else if ("`wbtype'"=="mammen") {
		    local wbtypen = 1
		}
		else if ("`wbtype'"=="rademacher") {
		    local wbtypen = 2
		}
		else if ("`wbtype'"!="rademacher" & "`wbtype'"!="mammen") {
		    display as error "invalid {bf:wbtype()}"
			di as txt "{p 4 4 2}"                           
			di as smcl as err ///
			"{bf:wbtype()} should be one of {bf:mammen} or " ///
			"{bf:rademacher}."      
			di as smcl as err  "{p_end}"
			exit 198 
		}
		return local wbtype = `wbtypen' 
		if ("`cluster'"!="") {
		    tempvar nclust wncl0
			capture confirm numeric variable `cluster'
			local rc = _rc
			if (`rc') {
				capture destring `rest', generate(`nclust')
				local rc = _rc 
				if (`rc') {
					display in red "option {bf:cluster()} incorrectly specified"
					exit 198
				}
				capture confirm numeric variable `nclust'
				local rc = _rc 
				if (`rc') {
					display in red "option {bf:cluster()} incorrectly specified"
					exit 198
				}
			}
			*quietly egen `wncl0' = group(`cluster') if `touse'
			*summarize `wncl0', meanonly
			*local wncl = r(max)
			*return scalar wncl = `wncl'
		}
		return local cluster "`cluster'"
	}
	else {
	    return local reps = `reps'
		return local seed "`rseed'"
		return local wbtype = 1 
	}
end 


program define _Vce_Parse_Clust, sclass
	syntax [anything], [vce(string) gmm *]
	gettoken key rest : vce, parse(", ")
	local lkey = length(`"`key'"')
	local nvce: list sizeof vce
	local iscluster = 0 
	if (`"`key'"' == bsubstr("cluster",1,max(2,`lkey'))) {
	    local iscluster = 1 
	}
	if (`nvce'>1 & `iscluster'==0 & "`gmm'"=="") {
		display as error "{bf:vce()} option {bf:`key'} not allowed"
		exit 198
	}
	if (`nvce'==1 & "`vce'"!="if" & "`gmm'"=="") {
		display as error "{bf:vce()} option {bf:`key'} not allowed"
		exit 198	    
	}
	if ("`vce'"=="if" & "`gmm'"!="") {
		display as error "{bf:vce()} option {bf:if} not allowed"
		exit 198	    
	}
	if (`nvce'>1) {
		gettoken key rest : vce, parse(", ")
		local lkey = length(`"`key'"')
		local voy = 0 
		if `"`key'"' == bsubstr("cluster",1,max(2,`lkey')) {
			capture confirm numeric variable `rest'
			local rc = _rc
			if (`rc') {
				tempname nclust
				capture destring `rest', generate(`nclust')
				local rc = _rc 
				if (`rc') {
					display in red "option {bf:vce()} incorrectly specified"
					exit 198
				}
				capture confirm numeric variable `nclust'
				local rc = _rc 
				if (`rc') {
					display in red "option {bf:vce()} incorrectly specified"
					exit 198
				}
			}
			local voy = 1
		}
		if ("`key'"=="hac" & "`gmm'"!="") {
			local nvce: list sizeof rest
			local voy = 1
		}
		if ("`key'"=="hac" & "`gmm'"=="") {
			display as error ///
				"{bf:vce()} option {bf:`key'} not allowed with"	///
				" estimator {bf:gmm}"
			exit 198
		}		
		if (`voy'==0) {
				display in red "option {bf:vce()} incorrectly specified"
				exit 198	    
		} 
	}
	if (`iscluster'==1) {
	    local cluster: word 2 of `vce'
	    sreturn local cluster "`cluster'"
	}
end

program define _S_Me_thod, sclass
	if ("`e(method)'"=="drimp") {
		local tmodel "inverse probability tilting"
		local omodel "weighted least squares"
	}
	if ("`e(method)'"=="aipw") {
		local tmodel "inverse probability"
		local omodel "weighted mean"
	}
	if ("`e(method)'"=="dripw") {
		local tmodel "inverse probability"
		local omodel "least squares"
	}
	if ("`e(method)'"=="reg") {
		local tmodel "none"
		local omodel "regression adjustment"
	}
	if ("`e(method)'"=="stdipw") {
		local tmodel "stabilized inverse probability"
		local omodel "weighted mean"
	}
	if ("`e(method)'"=="sipwra") {
		local tmodel "inverse probability"
		local omodel "regression adjustment"
	}

	sreturn local omodel "`omodel'"
	sreturn local tmodel "`tmodel'"
end

program define Display
		syntax [, bmatrix(passthru) vmatrix(passthru) COEFLegend *]
		
        _get_diopts diopts rest, `options'
        local myopts `bmatrix' `vmatrix' 	
		if ("`rest'"!="") {
				display in red "option {bf:`rest'} not allowed"
				exit 198
		}
		
		_S_Me_thod
		local omodel "`s(omodel)'"
		local tmodel "`s(tmodel)'"
		
		if ("`e(method)'"!="all") {
			_coef_table_header, title(Doubly robust difference-in-differences) 
			noi display as text "Outcome model  : {res:`omodel'}"
			noi display as text "Treatment model: {res:`tmodel'}"
			
		}
		else {
			_coef_table_header, ///
				title(Doubly robust difference-in-differences estimator summary) 
		}
		
		if ("`e(policy)'"!="" & "`e(semethod)'"=="wildboot") {
		    if "`e(clustvar)'"!="" {
			    display as text "(Std. err. adjusted for" ///
				as result %9.0gc e(N_clust) ///
				as text " clusters in " as result e(clustvar) as text ")"
			}
			_my_tab_drdid, `diopts'
		}
		if ("`e(semethod)'"!="wildboot") {
		    _coef_table,  `diopts' `myopts' `coeflegend' neq(1)
		}
		
		if ("`e(method)'"=="all") {
			local reg Outcome regression or Regression augmented estimator
			display "{p}Note: This table is provided for comparison" 	///
			" across estimations only. You cannot use it to compare"	///
			" estimates across different estimators{p_end}"
			display "{cmd:dripw} :Doubly Robust IPW"
			display "{cmd:drimp} :Doubly Robust Improved estimator"
			display "{cmd:reg}   :`reg'"
			display "{cmd:ipw}   :Abadie(2005) IPW estimator"
			display "{cmd:stdipw}:Standardized IPW estimator"
			display "{cmd:sipwra}:IPW and Regression adjustment estimator."
		}

end

program _my_tab_drdid, rclass 
	syntax [, level(int `c(level)') noci cformat(string) sformat(string) *]

	_get_diopts diopts rest, `options'

	local cf %9.0g  
	local pf %5.3f
	local sf %7.2f

	if ("`cformat'"!="") {
			local cf `cformat'
	}
	if ("`sformat'"!="") {
			local sf `sformat'
	}

	tempname mytab z t ll ul cimat rtab 
	local policy "`e(policy)'"
	local labn: value label `policy'
	local largo = strlen("`policy'")
	local newvs = 0 
	local novstab  = 0

	if ("`labn'"!="") {
			local uno:  label `labn' 1
			local zero: label `labn' 0 
			local vs "(`uno' vs `zero')"
			local widet = strlen("`vs'")
			local widet0 = `widet'
			local widet = max(`widet', `largo')     
			if (`largo'>`widet0' & `widet'>16) {
					local policy = abbrev("`policy'", 20)
					local widet  = 21 
			}
			if (`widet0'>24) {
					local kn1: list sizeof uno
					local kn0: list sizeof zero
					local kvs0 = max(max(max(`kn1', `kn0'), `largo'), 13)
					local policy = abbrev("`policy'", `kvs0')
					local uno0  = abbrev("`uno'", `kvs0')
					local zero0 = abbrev("`zero'", `kvs0')
					local vs1 "(`uno0' "
					local vs2 "vs"
					local vs3 "`zero0')"
					local newvs = 1 
					local widet = `kvs0' + 2
			}
	}
	else {
			local vs "(1 vs 0)"
			local widet = 13 
			local widet0 = `widet'
			local widet = max(`widet', `largo')
			if (`largo'>`widet0' & `widet'>21) {
					local policy = abbrev("`policy'", 20)
					local widet = 21
			}
	}

	.`mytab' = ._tab.new, col(6) lmargin(0)
	.`mytab'.width    `widet'   |12   12    8     12    12
	.`mytab'.titlefmt  .     .   . %6s    %24s     .
	.`mytab'.pad       .     2   1   0     3     3
	.`mytab'.numfmt    . `cf' `cf' `sf' `cf' `cf'
	
	local stat t 
	/*if "`e(df_r)'" != "" {
			local stat t
			scalar `z' = invttail(e(df_r),(100-`level')/200)
	}
	else {
			local stat z
			scalar `z' = invnorm((100+`level')/200)
	}*/
	local namelist : colname e(b)
	local eqlist : coleq e(b)
	local k : word count `namelist'
	local name : word 1 of `namelist'
	
	matrix `cimat'= e(ciband)
	scalar `ll'   = `cimat'[1,1]
	scalar `ul'   = `cimat'[1,2]
	scalar `t' = `beq'_b[`name']/`beq'_se[`name']
	matrix `rtab' = _b[`name']  \ 	///
	                _se[`name'] \ 	///
					`t'         \ 	///
					.           \	///
					`ll'        \	///
					`ul'        \	///
					.	        \	///
					.	        \	///
					0
	matrix colnames `rtab' = ATET:r1vs0.`policy'
	matrix rownames `rtab' = b se t pvalue ll ul df crit eform
				
	.`mytab'.sep, top
	if `:word count `e(depvar)'' == 1 {
			local depvar "`e(depvar)'"
			local depvar = abbrev("`depvar'", 12)
	}
	.`mytab'.titles "`depvar'"                      /// 1
					" Coefficient"                  /// 2
					"Std. err."						/// 3
					"`stat'"                        /// 4
					"[`level'% conf. interval]" ""  //  5 6

	
	local eq   : word 1 of `eqlist'
	forvalues i = 1/3 {
			if "`eq'" != "_" {
					if "`eq'" != "`eq0'" {
                        .`mytab'.strcolor result  .  .  .  .  .  
                        .`mytab'.strfmt    %-12s  .  .  .  .  .
                        if (`i'==1) {
                                .`mytab'.sep
                                .`mytab'.row      "`eq'" "" "" "" "" ""
                        }
                        .`mytab'.strcolor   text  .  .  .  .  .
                        .`mytab'.strfmt     %12s  .  .  .  .  .

					}
					local beq "[`eq']"
			}
			if (`i'==3) {
			.`mytab'.row    "`vs'"                	///
							`beq'_b[`name']         ///
							`beq'_se[`name']        ///
							`t'                     ///
							`ll' `ul'
			}
			if (`i'==2) {
				.`mytab'.row  "`policy'" "" "" "" "" ""  
			}
	}
	.`mytab'.sep, bottom
	 return matrix table = `rtab'
end

program define easter_egg
		display "{p}This is just for fun. Its my attempt to an Easter Egg within my program. {p_end}" _n /// 
		"{p} Also, if you are reading this, it means you are lucky," ///
		"only 0.1% of people using this program will see this message. {p_end}" _n ///
		"{p} This program was inspired by challenge post by Scott Cunningham. Unforunately, I arrived late due to " ///
		"lack of understanding. I tried to do CSDID (RUN) before learning DRDID (walk). {p_end} " _n  ///
		"{p} Asjad, was the first person who started to properly implement the code in Stata. I got inspired on his work that, " ///
		"Reread the paper, and voala. Everything fit in the form of the first version of this code. {p_end} " _n ///
		"{p} Many thanks go to Pedro, who spend a lot of time explaining details that would otherwise would remain confusing (he is the author fo the original paper after all; {p_end} " _n ///
		"{p} to Miklos, who pushed us to mantain a Github repository for this program. He is taking the side of the user {p_end}" ///
		"{p} To Enrique Pinzon, who helped from the shadows, for a smooth transition from R to Stata (Yay Stata) {p_end}" _n ///
		"{p} and Austin, who was working in parallel when Asjad and I took the lead on this. {p_end}"
end
////////////////////////////////////////////////////////////////////////////////
*** FIRST
**# Abadies
program define drdid_aipw, eclass
	syntax, [						///
			 touse(str) 			///
			 trt(str) 				///		
			 y(str) 				///
			 xvar(str) 				///
			 noisily 				///
			 ivar(str) 				///
			 tmt(str) 				///
			 weight(str) 			///
			 stub(name) 			///	
			 treatvar(string)		///
			 wboot 					///
			 reps(int 999) 			///
			 level(int 95) 			///
			 wbtype(int 1) 			///
			 seed(string)			///
			 cluster(str)			///
			 binit(str)            ///
			 *						///
			 ] 
	** PS
	*set trace on
	_get_diopts diopts other, `options' 
	quietly capture Display, `diopts' `other' 
	
	if _rc==198 {
			Display, `diopts' `other'       
	}
	
	tempvar att psxb __dy__ xb touse2
	tempname psb psV
	
	qui:gen double `att'=.
	if "`ivar'"!="" {
	    *display "Estimating IPW logit"
		qui {		
			`isily' logit `trt' `xvar' if `touse' & `tmt'==0 [iw = `weight']
			predict double `psxb', xb
			
			matrix `psb'=e(b)
			matrix `psV'=e(V)
			** _delta
			bysort `touse' `ivar' (`tmt'):gen double `__dy__'=`y'[2]-`y'[1] if `touse' 
			gen byte `touse2'=`touse'*(`tmt'==0)
  			replace `touse'=0 if `__dy__'==.
 		    tempname b V ciband ncl
			mata:ipw_abadie_panel("`__dy__'","`xvar' ","`xb'","`psb' ","`psV' ","`psxb'","`trt'","`tmt'","`touse2'","`att'","`weight'")
			local ci = `level'/100
			mata:make_tbl("`att'","`cluster' ", "`touse2'", "`b'","`V'","`ciband' ","`ncl'","`wboot' ", `reps', `wbtype', `ci')
			
			matrix colname `b'= ATET:r1vs0.`treatvar'
			matrix colname `V'= ATET:r1vs0.`treatvar' 
			matrix rowname `V'= ATET:r1vs0.`treatvar'
			quietly count if `touse'
			local N = r(N)
			ereturn post `b' `V', buildfvinfo esample(`touse') obs(`N')
			local att1    =`=_b[r1vs0.`treatvar']'
			local attvar1 =`=_se[r1vs0.`treatvar']'^2
			ereturn scalar att1    =`att1'
			ereturn scalar attvar1 =`attvar1'
			ereturn matrix ipwb `psb'
			ereturn matrix ipwV `psV'
			
		}
		*display "DiD with IPW"
		*display "Abadie (2005) inverse probability weighting DiD estimator"
		*ereturn display
	}
	else if "`ivar'"=="" {
	    qui {
			`isily' logit `trt' `xvar' if `touse' [iw = `weight']
			tempvar psxb
			predict double `psxb', xb
			tempname psb psV
			matrix `psb'=e(b)
			matrix `psV'=e(V)
		    tempname b V ciband ncl
 
			mata:ipw_abadie_rc("`y'","`xvar' ","`tmt'","`trt'","`psV'","`psxb'","`weight'","`touse'","`att'")
			** Wbootstrap Multipler
			local ci = `level'/100
			local touse2 `touse'
			mata:make_tbl("`att'","`cluster' ", "`touse2'", "`b'","`V'","`ciband' ","`ncl'","`wboot' ", `reps', `wbtype', `ci')
			
			matrix colname `b' = ATET:r1vs0.`treatvar'
			matrix colname `V' = ATET:r1vs0.`treatvar'
			matrix rowname `V' = ATET:r1vs0.`treatvar'
		}
		
		quietly count if `touse'
		local N = r(N)
		tempvar touse2
		clonevar `touse2'=`touse'
		ereturn post `b' `V', buildfvinfo esample(`touse2') obs(`N')
		local att1    =`=_b[r1vs0.`treatvar']'
		local attvar1 =`=_se[r1vs0.`treatvar']'^2
		ereturn scalar att1    =`att1'
		ereturn scalar attvar1 =`attvar1'
		*ereturn display
		ereturn matrix ipwb `psb'
		ereturn matrix ipwV `psV'
		
	}
	
	
** if STUB is used, then RIF is saved		
	if "`stub'"!="" {
		qui:capture drop `stub'att
		qui:gen double `stub'att=`att'
	}	
	
	if "`cluster'"!="" {
		    ereturn scalar N_clust =`=scalar(`ncl')'
			ereturn local clustvar `cluster'
	}
	if ("`wboot'"=="wboot") {			
		ereturn matrix ciband = `ciband'
		ereturn local semethod "wildboot"
		ereturn local vcetype  "Wboot"
	}
 	ereturn local cmd drdid
	ereturn local method  aipw
	ereturn hidden local method2 aipw
	ereturn local policy "`treatvar'"
	*Display, bmatrix(e(b)) vmatrix(e(V)) `diopts' 
end

** can be more efficient
**#drdid_dripw
program define drdid_dripw, eclass
		syntax, [							///
				touse(str) 					///
				trt(str) 					///
				y(str) 						///
				xvar(str) 					///
				noisily 					///
				ivar(str) 					///
				tmt(str) 					///
				weight(str) 				///
				rc1 						///
				stub(name) 					///
				treatvar(string)			///
				wboot 						///
				level(int 95) 				///
				reps(int 999)				///
				wbtype(int 1) 				///
				seed(string)				///
				cluster(str)				///
				binit(str)            ///
				*							///
				]
	** PS
	tempvar att psxb __dy__ xb touse2
	tempname psb psV regb regV  b V ciband ncl 
	qui:gen double `att'=.
	if "`ivar'"!="" {
	    *display "Estimating IPW logit"
		qui {		
			`isily' logit `trt' `xvar' if `touse' & `tmt'==0 [iw = `weight']
			predict double `psxb', xb			
			matrix `psb'=e(b)
			matrix `psV'=e(V)
			** _delta
			bysort `touse' `ivar' (`tmt'):gen double `__dy__'=`y'[2]-`y'[1] if `touse'
			** Reg for outcome 
 
			`isily' reg `__dy__' `xvar' if `touse' & `trt'==0  & `tmt'==0 [iw = `weight']
			matrix `regb'=e(b)
			matrix `regV'=e(V)
			predict double `xb'
			*capture drop `stub'att
			*gen double `stub'att=. 
			gen byte `touse2'=`touse'*(`tmt'==0)
			replace `touse'=0 if `__dy__'==.
			mata:drdid_panel("`__dy__'","`xvar' ","`xb'","`psb'","`psV'","`psxb'","`trt'","`tmt'","`touse2'","`att'","`weight'")
			**replace `stub'att=. if `tmt'==1
			local ci = `level'/100
			mata:make_tbl("`att'","`cluster' ", "`touse2'", "`b'","`V'","`ciband' ","`ncl'","`wboot' ", `reps', `wbtype', `ci')
			
			matrix colname `b'= ATET:r1vs0.`treatvar'
			matrix colname `V'= ATET:r1vs0.`treatvar'
			matrix rowname `V'= ATET:r1vs0.`treatvar'
			quietly count if `touse'
			local N = r(N)
			ereturn post `b' `V', buildfvinfo esample(`touse') obs(`N')
			local att1    =`=_b[r1vs0.`treatvar']'
			local attvar1 =`=_se[r1vs0.`treatvar']'^2
			ereturn scalar att1    =`att1'
			ereturn scalar attvar1 =`attvar1'
			ereturn matrix ipwb `psb'
			ereturn matrix ipwV `psV'
			ereturn matrix regb `regb'
			ereturn matrix regV `regV'
		}
/*		display "DR DiD with IPW and OLS"
		display "Sant'Anna and Zhao (2020)" _n "{p}Doubly robust DiD estimator based on stabilized inverse probability weighting and ordinary least squares{p_end}"
		ereturn display*/
	}
	else if "`ivar'"=="" {
	    qui {	
			`isily' logit `trt' `xvar' if `touse' [iw = `weight']
			tempvar psxb
			predict double `psxb', xb
			tempname psb psV
			matrix `psb'=e(b)
			matrix `psV'=e(V)
		    tempname b V ciband ncl
			*capture drop `stub'att
			*gen double `stub'att=.
			**ols 
			tempvar y00 y01 y10 y11
			tempname regb00 regb01 regb10 regb11 
			tempname regV00 regV01 regV10 regV11
			`isily' reg `y' `xvar' if `trt'==0 & `tmt' ==0 [iw = `weight']
			predict double `y00'
			matrix `regb00'=e(b)
			matrix `regV00'=e(V)
			`isily' reg `y' `xvar' if `trt'==0 & `tmt' ==1 [iw = `weight']
			predict double `y01'
			matrix `regb01'=e(b)
			matrix `regV01'=e(V)
			`isily' reg `y' `xvar' if `trt'==1 & `tmt' ==0 [iw = `weight']
			predict double `y10'
			matrix `regb10'=e(b)
			matrix `regV10'=e(V)
			`isily' reg `y' `xvar' if `trt'==1 & `tmt' ==1 [iw = `weight']
			predict double `y11'
			matrix `regb11'=e(b)
			matrix `regV11'=e(V)
			if "`rc1'"=="" {
				mata:drdid_rc("`y'","`y00' `y01' `y10' `y11'","`xvar' ","`tmt'","`trt'","`psV'","`psxb'","`weight'","`touse'","`att'")
			}
			else {
			    mata:drdid_rc1("`y'","`y00' `y01' `y10' `y11'","`xvar' ","`tmt'","`trt'","`psV'","`psxb'","`weight'","`touse'","`att'")
				local nle "Not Locally efficient"
			}
			////
			local touse2 `touse'
			local ci = `level'/100
			mata:make_tbl("`att'","`cluster' ", "`touse2'", "`b'","`V'","`ciband' ","`ncl'","`wboot' ", `reps', `wbtype', `ci')			
			matrix colname `b' = ATET:r1vs0.`treatvar'
			matrix colname `V' = ATET:r1vs0.`treatvar'
			matrix rowname `V' = ATET:r1vs0.`treatvar'			
		}
		*display "DR DiD with IPW and OLS for Repeated Crossection: `nle'"
		*display "Sant'Anna and Zhao (2020)" _n "{p}Doubly robust DiD estimator based on stabilized inverse probability weighting and ordinary least squares{p_end}"
		quietly count if `touse'
		local N = r(N)
		tempvar touse2	
		clonevar `touse2'=`touse'
		ereturn post `b' `V', buildfvinfo esample(`touse2') obs(`N')
		*ereturn post `b' `V'
		*ereturn display
		local att1    =`=_b[r1vs0.`treatvar']'
		local attvar1 =`=_se[r1vs0.`treatvar']'^2
		ereturn scalar att1    =`att1'
		ereturn scalar attvar1 =`attvar1'
 		ereturn matrix ipwb `psb'
		ereturn matrix ipwV `psV'
		
		ereturn matrix regb00 `regb00'
		ereturn matrix regV00 `regV00'
		ereturn matrix regb01 `regb01'
		ereturn matrix regV01 `regV01'
		ereturn matrix regb10 `regb10'
		ereturn matrix regV10 `regV10'
		ereturn matrix regb11 `regb11'
		ereturn matrix regV11 `regV11'
 
	}
	if "`stub'"!="" {
		qui:capture drop `stub'att
		qui:gen double `stub'att=`att'
	}
	
	if "`cluster'"!="" {
		    ereturn scalar N_clust =`=scalar(`ncl')'
			ereturn local clustvar `cluster'
	}
 
	if ("`wboot'"=="wboot") {
		ereturn matrix ciband = `ciband'
		ereturn local semethod "wildboot"
	}
	
	ereturn local cmd drdid
	ereturn local method  dripw
	ereturn hidden local method2 dripw
	ereturn local policy "`treatvar'"
	*Display, bmatrix(e(b)) vmatrix(e(V)) `diopts' 
end

**#drdid_reg
program define drdid_reg, eclass
	syntax, [						///
			touse(str) 				///
			trt(str) 				///
			y(str) 					///
			xvar(str) 				///
			noisily 				///
			ivar(str) 				///
			tmt(str) 				///
			weight(str) 			///
			stub(name) 				///
			treatvar(string) 		///
			wboot 					///
			level(int 95) 			///
			reps(int 999) 			///
			wbtype(int 1) 			///
			seed(string)			///
			 cluster(str)			///
			 binit(str)            ///
			*						///
			] 
** Simple application. But right now without RIF
	tempvar att
	qui:gen double `att'=.
	if "`ivar'"!="" {
		qui {
			tempvar __dy__ xb touse2
			tempname regb regV b V ciband ncl
			bysort `touse' `ivar' (`tmt'):gen double	///
				`__dy__'=`y'[2]-`y'[1] if `touse' 
				`isily' reg `__dy__' `xvar' if `touse' & `trt'==0	///
				& `tmt'==0  [iw = `weight']
			predict double `xb'
			//////////////////////		
			matrix `regb'=e(b)
			matrix `regV'=e(V)
			gen byte `touse2'=`touse'*(`tmt'==0)
			replace `touse'=0 if `__dy__'==.
			mata:reg_panel("`__dy__'", "`xvar' ", "`xb' " , "`trt'",	///
				"`tmt'" , "`touse2'","`att'","`weight'") 
			local ci = `level'/100
			mata:make_tbl("`att'","`cluster' ", "`touse2'", "`b'","`V'","`ciband' ","`ncl'","`wboot' ", `reps', `wbtype', `ci')			
			matrix colname `b' = ATET:r1vs0.`treatvar'
			matrix colname `V' = ATET:r1vs0.`treatvar'
			matrix rowname `V' = ATET:r1vs0.`treatvar'
			quietly count if `touse'
			local N = r(N)
			ereturn post `b' `V', buildfvinfo esample(`touse') obs(`N')
			local att1    =`=_b[r1vs0.`treatvar']'
			local attvar1 =`=_se[r1vs0.`treatvar']'^2
			ereturn scalar att1    =`att1'
			ereturn scalar attvar1 =`attvar1'
			ereturn matrix regb `regb'
			ereturn matrix regV `regV' 
		}
		*display "DiD with OR" _n "Outcome regression DiD estimator based on ordinary least squares"
		*ereturn display
	}	
	else if "`ivar'"=="" {
		qui {
		    tempvar y00 y01
			tempname regb00 regb01 regV00 regV01
		    `isily' reg `y' `xvar' if `trt'==0 & `tmt' ==0 [iw = `weight']
			predict double `y00'
			matrix `regb00' = e(b)
			matrix `regV00' = e(V)
			`isily' reg `y' `xvar' if `trt'==0 & `tmt' ==1 [iw = `weight']
			predict double `y01'
			matrix `regb01' = e(b)
			matrix `regV01' = e(V)
			tempname b V ciband ncl
			*capture drop `stub'att
			*gen double `stub'att=.
			mata:reg_rc("`y'","`y00' `y01'","`xvar' ",	///
				"`tmt'","`trt'","`weight'","`touse'","`att'")
			local ci = `level'/100
			local touse2 `touse'
			mata:make_tbl("`att'","`cluster' ", "`touse2'", "`b'","`V'","`ciband' ","`ncl'","`wboot' ", `reps', `wbtype', `ci')			
			matrix colname `b' = ATET:r1vs0.`treatvar'
			matrix colname `V' = ATET:r1vs0.`treatvar'
			matrix rowname `V' = ATET:r1vs0.`treatvar'
			quietly count if `touse'
			local N = r(N)
			tempvar touse2
			clonevar `touse2'=`touse'
			ereturn post `b' `V', buildfvinfo esample(`touse2') obs(`N')
			ereturn matrix regb00 `regb00'
			ereturn matrix regV00 `regV00' 
			ereturn matrix regb01 `regb01'
			ereturn matrix regV01 `regV01'
			local att1    =`=_b[r1vs0.`treatvar']'
			local attvar1 =`=_se[r1vs0.`treatvar']'^2
			ereturn scalar att1    =`att1'
			ereturn scalar attvar1 =`attvar1'
		}
		*display "DiD with OR for RC" _n "Outcome regression DiD estimator based on ordinary least squares"
		*ereturn display
	}
	
	if "`stub'"!="" {
		qui:capture drop `stub'att
		qui:gen double `stub'att=`att'
	}
	if "`cluster'"!="" {
		    ereturn scalar N_clust =`=scalar(`ncl')'
			ereturn local clustvar `cluster'
		}
		
	if ("`wboot'"=="wboot") {			
		ereturn matrix ciband = `ciband'
		ereturn local semethod "wildboot"
	}
	ereturn local cmd drdid
	ereturn local method  reg
	ereturn hidden local method2 reg
	ereturn local policy "`treatvar'"
	*Display, bmatrix(e(b)) vmatrix(e(V)) `diopts' 
	
end

**#drdid_sipw
program define drdid_stdipw, eclass
	syntax, [						///
			touse(str) 				///
			trt(str) 				///
			y(str) 					///
			xvar(str) 				///
			noisily 				///
			ivar(str) 				///
			tmt(str) 				///
			weight(str) 			///
			stub(name) 				///
			treatvar(string) 		///
			wboot 					///
			level(int 95) 			///
			reps(int 999) 			///
			wbtype(int 1) 			///
			seed(string)			///
			 cluster(str)			///
			 binit(str)            ///
			*						///
			] 
			
	tempvar att
	qui:gen double `att'=.
** Simple application. But right now without RIF
	if "`ivar'"!="" {
	    *display "Estimating IPW logit"
		qui {		
			`isily' logit `trt' `xvar' if `touse' & `tmt'==0 [iw = `weight']
			tempvar psxb __dy__ xb touse2
			tempname psb psV b V ciband ncl
			predict double `psxb', xb		
			matrix `psb'=e(b)
			matrix `psV'=e(V)
			** _delta
			bysort `touse' `ivar' (`tmt'):gen double `__dy__'=`y'[2]-`y'[1]	///
				if `touse'
			** Reg for outcome 
		}
		*display "Estimating Counterfactual Outcome"	
		qui {
			*`isily' reg `__dy__' `xvar' if `trt'==0 
			*gen double `stub'att=.		
			gen byte `touse2'=`touse'*(`tmt'==0)
			replace `touse'=0 if `__dy__'==.
			mata:std_ipw_panel("`__dy__'","`xvar' ","`xb'",		///
				"`psb'","`psV'","`psxb'","`trt'","`tmt'","`touse2'",	///
				"`att'","`weight'")
			local ci = `level'/100
			mata:make_tbl("`att'","`cluster' ", "`touse2'", "`b'","`V'","`ciband' ","`ncl'","`wboot' ", `reps', `wbtype', `ci')			
			matrix colname `b'= ATET:r1vs0.`treatvar'
			matrix colname `V'= ATET:r1vs0.`treatvar'
			matrix rowname `V'= ATET:r1vs0.`treatvar'

		}
		*display "DiD with stabilized IPW" _n "{p}Abadie (2005) inverse probability weighting DiD estimator with stabilized weights{p_end}" 
		quietly count if `touse'
		local N = r(N)
		ereturn post `b' `V', buildfvinfo esample(`touse') obs(`N')
		*ereturn display
		local att1    =`=_b[r1vs0.`treatvar']'
		local attvar1 =`=_se[r1vs0.`treatvar']'^2
		ereturn scalar att1    =`att1'
		ereturn scalar attvar1 =`attvar1'
		ereturn matrix ipwb `psb'
		ereturn matrix ipwV `psV'
	}	
	else if "`ivar'"=="" {
	    qui {
		    `isily' logit `trt' `xvar' if `touse' [iw = `weight']
			tempvar psxb
			predict double `psxb', xb
			tempname psb psV
			matrix `psb'=e(b)
			matrix `psV'=e(V)
			tempname b V ciband ncl
			*capture drop `stub'att
			*gen `stub'att=.
			mata:std_ipw_rc("`y'","`xvar' ","`tmt'","`trt'","`psV'","`psxb'","`weight'","`touse'","`att'")
			local ci = `level'/100
			local touse2 `touse'
			mata:make_tbl("`att'","`cluster' ", "`touse2'", "`b'","`V'","`ciband' ","`ncl'","`wboot' ", `reps', `wbtype', `ci')			
			matrix colname `b' = ATET:r1vs0.`treatvar'
			matrix colname `V' = ATET:r1vs0.`treatvar'
			matrix rowname `V' = ATET:r1vs0.`treatvar'
		}
		
		quietly count if `touse'
		local N = r(N)
		tempvar touse2
		clonevar `touse2'=`touse'
		ereturn post `b' `V', buildfvinfo esample(`touse2') obs(`N') 
		local att1    =`=_b[r1vs0.`treatvar']'
		local attvar1 =`=_se[r1vs0.`treatvar']'^2
		ereturn scalar att1    =`att1'
		ereturn scalar attvar1 =`attvar1'
		ereturn matrix ipwb `psb'
		ereturn matrix ipwV `psV'
		if "`cluster'"!="" {
		    ereturn scalar N_clust =`=scalar(`ncl')'
			ereturn local clustvar `cluster'
		}
	}
	
	if "`stub'"!="" {
		qui:capture drop `stub'att
		qui:gen double `stub'att=`att'
	}
	if "`cluster'"!="" {
		    ereturn scalar N_clust =`=scalar(`ncl')'
			ereturn local clustvar `cluster'
		}
	if ("`wboot'"=="wboot") {			
		ereturn matrix ciband = `ciband'
		ereturn local semethod "wildboot"
	}
	ereturn local cmd drdid
	ereturn local method stdipw 
	ereturn hidden local method2 stdipw 
	ereturn local policy "`treatvar'"
	*Display, bmatrix(e(b)) vmatrix(e(V)) `diopts' 
	
end

// only one without Mata writting. Consider working on it
**#drdid_sipwra
program define drdid_sipwra, eclass
	syntax, [						///
			touse(str) 				///
			trt(str) 				///
			y(str) 					///
			xvar(str) 				///
			noisily 				///
			ivar(str) 				///
			tmt(str) 				///
			weight(str) 			///
			stub(name) 				///
			treatvar(string)		///
			reps(int 999) 			/// Notused here
			wbtype(int 1) 			/// not used here
			seed(string)			///
			level(int 95) 			/// not used here
			cluster(str)			///
			*						///
			] 
	tempvar att
	qui:gen double `att'=.
** Simple application. But right now without RIF
	if "`cluster'"!="" {
		local clopt vce(cluster `cluster')
	}
   if "`ivar'"=="" {
       display "Estimator not implemented for RC"
	   exit 198 
   }
   else {
	qui {
		tempvar __dy__ sy
		bysort `touse' `ivar' (`tmt'):gen double `__dy__'=`y'[2]-`y'[1] if `touse'
		sum `__dy__' if  `touse'
		local scl = r(mean)
		gen double `sy'= `__dy__'/`scl'		
		qui:teffects ipwra (`sy' `xvar') (`trt' `xvar', logit)	///
			if `touse' & `tmt'==0 [iw = `weight'] , atet `clopt' iter(5)
		tempname b V ciband ncl aux
		matrix `aux'=e(b)*`scl'
		matrix `b'=`aux'[1,1]
		matrix `aux'=e(V)*`scl'^2
		matrix `V'=`aux'[1,1]
		matrix colname `b' = ATET:r1vs0.`treatvar'
		matrix colname `V' = ATET:r1vs0.`treatvar'
		matrix rowname `V' = ATET:r1vs0.`treatvar'
		quietly count if `touse'
		local N = r(N)
		ereturn post `b' `V', buildfvinfo esample(`touse') obs(`N')
	}
		*ereturn display	
   }

	if "`stub'"!="" {
		qui:capture drop `stub'att
		qui:gen double `stub'att=`att'
	}   
	ereturn local cmd drdid
	ereturn local method sipwra
	ereturn hidden local method2 sipwra
	ereturn local policy "`treatvar'"
	*Display, bmatrix(e(b)) vmatrix(e(V)) `diopts' 
end
 
**#drdid_dript
program define drdid_imp, eclass  
	syntax, [					///
			touse(str)			///
			trt(str)			///
			y(str) 				///
			xvar(str) 			///
			noisily 			///
			ivar(str) 			///
			tmt(str) 			///
			weight(str) 		///
			rc1 stub(name)		///
			treatvar(string)	///
            wboot 				///
			level(int 95) 		///
			reps(int 999) 		///
			wbtype(int 1) 		///
			seed(string)			///
			cluster(str)			///
			binit(str)            ///
		*						///
		] 
 
	_get_diopts diopts other, `options' 
	quietly capture Display, `diopts' `other' 
	
	if _rc==198 {
			Display, `diopts' `other'       
	}
	
	tempvar att  psxb __dy__ w0 xb
	tempname iptb iptV regb regV b V ciband ncl

	qui:gen double `att'=.
	
	if "`ivar'"!="" {
		qui {
			
			`isily'  mlexp (`trt'*{xb:`xvar' _cons}-(`trt'==0)*exp({xb:}))  ///
					if `touse' & `tmt'==0 [iw = `weight'],  from(`binit') ///
					 derivative(/xb=`trt'-(`trt'==0)*exp({xb:}))
			*vce(robust)
			matrix `iptb'=e(b)
			matrix `iptV'=e(V)
			predict double `psxb',xb
			
			** Determine dy and dyhat
			bysort `touse' `ivar' (`tmt'):gen double `__dy__'=`y'[2]-`y'[1] if `touse'

			** determine weights
			gen double `w0' = ((logistic(`psxb')*(1-`trt')))/(1-logistic(`psxb'))*`weight'
			sum `w0' if `touse' , meanonly
			replace `w0'=`w0'/r(mean)
			
			** estimating dy_hat for a counterfactual
			`isily' reg `__dy__' `xvar' [w=`w0'] if `trt'==0 & `tmt'==0,
			matrix `regb' =e(b)
			matrix `regV' =e(V)
			qui:predict double `xb'
			tempvar touse2
			gen byte `touse2'=`touse'*(`tmt'==0)
			replace `touse'=0 if `__dy__'==.
			mata:drdid_imp_panel("`__dy__'","`xvar' ","`xb'",	///
				"`psb'","`psV'","`psxb'","`trt'","`tmt'","`touse2'",	///
				"`att'","`weight'")	
********************************************************************************				
********************************************************************************
			
			local ci = `level'/100
			mata:make_tbl("`att'","`cluster' ", "`touse2'", "`b'","`V'","`ciband' ","`ncl'","`wboot' ", `reps', `wbtype', `ci')
			
 			matrix colname `b'= ATET:r1vs0.`treatvar'
			matrix colname `V'= ATET:r1vs0.`treatvar'
			matrix rowname `V'= ATET:r1vs0.`treatvar'
			quietly count if `touse'
			local N = r(N)
			ereturn post `b' `V', buildfvinfo esample(`touse') obs(`N')
			local att1    =`=_b[r1vs0.`treatvar']'
			local attvar1 =`=_se[r1vs0.`treatvar']'^2
			ereturn scalar att1    =`att1'
			ereturn scalar attvar1 =`attvar1'
			ereturn matrix iptb `iptb'
			ereturn matrix iptV `iptV'
			ereturn matrix regb `regb'
			ereturn matrix regV `regV'
			ereturn local cmd drdid
			ereturn local method drimp
 
			if ("`wboot'"=="wboot") {			
				ereturn matrix ciband = `ciband'
				ereturn local semethod "wildboot"
			}
		}
		*display "DR DiD with IPT and WLS" _n "{p}Sant'Anna and Zhao (2020) Improved doubly robust DiD estimator based on inverse probability of tilting and weighted least squares{p_end}"
		*ereturn display
	}
	else {
	**# for Crossection estimator				

		qui {

			/*`isily' gmm ((`trt'==1)-(`trt'==0)*exp({b:`xvar' _cons})) if `touse'  [iw = `weight'], ///
			instrument(`xvar' ) derivative(/b=-(`trt'==0)*exp({b:})) ///
			onestep winit(identity) */
			
			`isily'  mlexp (`trt'*{xb:`xvar' _cons}-(`trt'==0)*exp({xb:}))  ///
					if `touse' [iw = `weight'], vce(robust) from(`binit') ///
					 derivative(/xb=`trt'-(`trt'==0)*exp({xb:}))

			//& `tmt'==0 
			tempname iptb iptV regb00 regV00 regb01 regV01 regb10	///
					 regV10 regb11 regV11
			tempvar psxb w1 w0 y01 y00 y10 y11
			
			matrix `iptb'=e(b)
			matrix `iptV'=e(V)
			predict double `psxb', xb
			** outcomes
			gen double `w0' = (1-`trt')*logistic(`psxb')/(1-logistic(`psxb'))
			`isily' reg `y' `xvar' [w=`w0'] if `trt'==0 & `tmt'==0,
			predict double `y00'
			matrix `regb00' =e(b)
			matrix `regV00' =e(V)
			`isily' reg `y' `xvar' [w=`w0'] if `trt'==0 & `tmt'==1,
			predict double `y01'
			matrix `regb01' =e(b)
			matrix `regV01' =e(V)
			`isily' reg `y' `xvar'  		   if `trt'==1 & `tmt'==0,
			predict double `y10'
			matrix `regb10' =e(b)
			matrix `regV10' =e(V)
			`isily' reg `y' `xvar'  		   if `trt'==1 & `tmt'==1,
			predict double `y11'
			matrix `regb11' =e(b)
			matrix `regV11' =e(V)
			tempname b V ciband ncl
			if "`rc1'"=="" {
				mata:drdid_imp_rc("`y'","`y00' `y01' `y10' `y11'",	///
					"`xvar' ","`tmt'","`trt'","`iptV'","`psxb'",	///
					"`weight'","`touse'","`att'")
			}
			else {
			    mata:drdid_imp_rc1("`y'","`y00' `y01' `y10' `y11'",	///
					"`xvar' ","`tmt'","`trt'","`iptV'","`psxb'",	///
					"`weight'","`touse'","`att'")
				local nle "Not Locally efficient"
			}
			local ci = `level'/100
			local touse2 `touse'
			mata:make_tbl("`att'","`cluster' ", "`touse2'", "`b'","`V'","`ciband' ","`ncl'","`wboot' ", `reps', `wbtype', `ci')
			  			
			matrix colname `b'=ATET:r1vs0.`treatvar'
			matrix colname `V'=ATET:r1vs0.`treatvar'
			matrix rowname `V'=ATET:r1vs0.`treatvar'
			quietly count if `touse'
			local N = r(N)
			tempvar touse2	
			clonevar `touse2'=`touse'
			ereturn post `b' `V', buildfvinfo esample(`touse2') obs(`N')
			ereturn local cmd drdid
			ereturn local method drimp
			
			if ("`wboot'"=="wboot") {			
				ereturn matrix ciband = `ciband'
				ereturn local semethod "wildboot"
			}
		}
		
		*display "{p}DR DiD with IPT and WLS for OLS `nle'{p_end}" _n "{p}Sant'Anna and Zhao (2020) Improved doubly robust DiD estimator based on inverse probability of tilting and weighted least squares{p_end}"
		*ereturn display
		local att1    =`=_b[r1vs0.`treatvar']'
		local attvar1 =`=_se[r1vs0.`treatvar']'^2
		ereturn scalar att1    =`att1'
		ereturn scalar attvar1 =`attvar1'
		ereturn matrix iptb `iptb'
		ereturn matrix iptV `iptV'
		ereturn matrix regb00 `regb00'
		ereturn matrix regV00 `regV00'
		ereturn matrix regb01 `regb01'
		ereturn matrix regV01 `regV01'
		ereturn matrix regb10 `regb10'
		ereturn matrix regV10 `regV10'
		ereturn matrix regb11 `regb11'
		ereturn matrix regV11 `regV11'
	}
	if "`stub'"!="" {
		qui:capture drop `stub'att
		qui:gen double `stub'att=`att'
	}
	if "`cluster'"!="" {
		    ereturn scalar N_clust =`=scalar(`ncl')'
			ereturn local clustvar `cluster'
	}
	ereturn local policy "`treatvar'"
	*Display, bmatrix(e(b)) vmatrix(e(V)) `diopts' 
end

program define _S__est, sclass
	syntax [anything], [drimp dripw reg stdipw ipw ipwra all * ]
	
	if ("`drimp'"!="") {
		local drimp imp 
	}
	if ("`ipw'"!="") {
		local ipw "aipw"
	}
	if ("`ipwra'"!="") {
		local ipwra "sipwra"
	}
	sreturn local estimator ///
		"`drimp'`dripw'`reg'`stdipw'`ipw'`ipwra'`all'"
end 

mata 
	////////////////////////////////////////////////////////////////////////////////////////////////
// dript
	void drdid_imp_panel(string scalar dy_, xvar_, xb_ , psb_,psV_,psxb_,trt_,tmt_,touse,rif,ww) {
	    real matrix dy, xvar, xb, psb, psv, psxb, trt, tmt
		// This code is based on Asjad Replication
		// Gather all data
		real scalar nn
		dy  =st_data(.,dy_  ,touse)
		nn=rows(dy)
		//st_view(xvar=.,xvar_,touse)
		xb=st_data(.,xb_,touse)
		psxb=st_data(.,psxb_,touse)
		real matrix psc
		psc=logistic(psxb)
		trt =st_data(.,trt_ ,touse)
		real matrix w
		w=st_data(.,ww,touse)
		real matrix w_1 , w_0, att, att_inf_func
		w_1 = w :* trt
		w_0 = w :* psc :* (1:-trt):/(1:-psc)
		w_1 = w_1:/mean(w_1)
		w_0 = w_0:/mean(w_0)
		att=(dy:-xb):*(w_1:-w_0)
		att_inf_func = mean(att) :+ att :- w_1:*mean(att)
		st_store(.,rif,touse, att_inf_func)	
		// Variance should be divided by n not n-1
		
		
	}
 
	// standard IPW
  	void std_ipw_panel(string scalar dy_, xvar_, xb_ , psb_,psV_,psxb_,trt_,tmt_,touse,rif,ww) {
	    real matrix dy, xvar, xb, psb, psv, psxb, trt, tmt
 		// Gather all data
		real scalar nn
		dy  =st_data(.,dy_  ,touse)
		nn=rows(dy)
		// verify xvar
		if (xvar_==" ") {
			xvar=J(rows(dy),1,1)	
		}
		else xvar=st_data(.,xvar_,touse),J(rows(dy),1,1)	
		
		//xb=st_data(.,xb_,touse)
		psxb=st_data(.,psxb_,touse)
		real matrix psc
		psc=logistic(psxb)
		trt =st_data(.,trt_ ,touse)
		tmt =st_data(.,tmt_ ,touse)
		// and matrices
		//psb =st_matrix(psb_ )
		psv =st_matrix(psV_ )
		// for now assume weights = 1
		real matrix w
		w=st_data(.,ww,touse)
		
		real matrix w_1, w_0, att_cont, att_treat,
					eta_treat, eta_cont, 
					lin_ps,  att_inf_func
			
		w_1= w :* trt
		w_0= w :* psc :* (1 :- trt):/(1 :- psc)
		att_treat = w_1:* dy
		att_cont  = w_0:* dy
		eta_treat = mean(att_treat)/mean(w_1)
		eta_cont  = mean(att_cont)/mean(w_0)
		ipw_att   = eta_treat :- eta_cont
		
		inf_treat = (att_treat :- w_1 :* eta_treat)/mean(w_1)
		inf_cont_1 = (att_cont :- (w_0 :* eta_cont))
		lin_ps = (w:* (trt :- psc) :* xvar)*(psv * nn)
		//M2 =
		inf_cont_2 = lin_ps * mean(w_0 :* (dy :- eta_cont) :* xvar)'
		inf_control = (inf_cont_1 :+ inf_cont_2)/mean(w_0)
		att_inf_func = mean(ipw_att):+inf_treat :- inf_control
 
		st_store(.,rif,touse, att_inf_func)	

	}
  
	void reg_panel(string scalar dy_, xvar_, xb_ , trt_,tmt_,touse,rif,ww) {
	    real matrix dy, xvar, xb, trt, tmt
		// This code is based on Asjad Replication
		// Gather all data
		real scalar nn
		dy  =st_data(.,dy_  ,touse)
		nn=rows(dy)
		
		// verify xvar
		if (xvar_==" ") {
			xvar=J(rows(dy),1,1)	
		}
		else xvar=st_data(.,xvar_,touse),J(rows(dy),1,1)	
		
		xb=st_data(.,xb_,touse)
		// psxb=st_data(.,psxb_,touse)
		// real matrix psc
		// psc=logistic(psxb)
		trt =st_data(.,trt_ ,touse)
		tmt =st_data(.,tmt_ ,touse)
		// and matrices
		// psb =st_matrix(psb_ )
		// psv =st_matrix(psV_ )
		// for now assume weights = 1
		real matrix w
		w=st_data(.,ww,touse)
		real matrix w_1, w_0, att_cont, att_treat,
					eta_treat, eta_cont, wols_x, wols_eX,
					lin_ols, att_inf_func
		
		w_1 = w :* trt
		w_0 = w :* trt
		att_treat = w_1:* dy
		att_cont  = w_0:* xb
		eta_treat = mean(att_treat):/mean(w_1)
		eta_cont  = mean(att_cont)  :/mean(w_0)
		reg_att = eta_treat :- eta_cont
		wols    = w :* (1 :- trt)
		wols_x  = wols :* xvar
		wols_eX = wols :* (dy:-xb) :* xvar
		
		XpX_inv = invsym(quadcross(wols_x, xvar))*nn
		lin_ols = wols_eX * XpX_inv
		inf_treat    = (att_treat :- w_1 * eta_treat):/mean(w_1)
		inf_cont_1   = (att_cont :- w_0 * eta_cont)
		inf_cont_2   = lin_ols * mean(w_0 :* xvar )'
		inf_control  = (inf_cont_1 :+ inf_cont_2):/mean(w_0)
		att_inf_func = mean(reg_att):+(inf_treat :- inf_control)
			
		st_store(.,rif,touse, att_inf_func)	

				
	}
	
 
/////////////////////////////////////////////////////////////////////////////////////////////////	
// TIPW drdid_tipw
 	void ipw_abadie_panel(string scalar dy_, xvar_, xb_ , psb_,psV_,psxb_,trt_,tmt_,touse,rif,ww) {
	    real matrix dy, xvar, xb, psb, psv, psxb, trt, tmt
 		// Gather all data
		real scalar nn
		dy  =st_data(.,dy_  ,touse)
		nn=rows(dy)
		// verify xvar
		if (xvar_==" ") {
			xvar=J(rows(dy),1,1)	
		}
		else xvar=st_data(.,xvar_,touse),J(rows(dy),1,1)	
		
		//xb=st_data(.,xb_,touse)
		psxb=st_data(.,psxb_,touse)
		real matrix psc
		psc=logistic(psxb)
		trt =st_data(.,trt_ ,touse)
		tmt =st_data(.,tmt_ ,touse)
		// and matrices
		psb =st_matrix(psb_ )
		psv =st_matrix(psV_ )
		// for now assume weights = 1
		real matrix w
		w=st_data(.,ww,touse)
		real matrix w_1, w_0, att_cont, att_treat,
					eta_treat, eta_cont, ipw_att,
					lin_ps, att_lin1, mom_logit, att_lin2, att_inf_func
					
		w_1= w :* trt
		w_0= w :* psc :* (1 :- trt):/(1 :- psc)
		att_treat = w_1:* dy
		att_cont  = w_0:* dy
		eta_treat = mean(att_treat)/mean(w_1)
		eta_cont  = mean(att_cont)/mean(w_1)
		ipw_att   = eta_treat - eta_cont
		lin_ps = (w:* (trt :- psc) :* xvar)*(psv * nn)
		att_lin1  = att_treat :- att_cont
		mom_logit = mean(att_cont  :* xvar)
		att_lin2  = lin_ps * mom_logit'
		att_inf_func = mean(ipw_att):+(att_lin1 :- att_lin2 :- w_1 :* ipw_att)/mean(w_1)
 		st_store(.,rif,touse, att_inf_func)	
		// Variance should be divided by n not n-1

		
	}
	
	
/// drdid_ipw	
 	void drdid_panel(string scalar dy_, xvar_, xb_ , psb_,psV_,psxb_,trt_,tmt_,touse,rif,ww) {
	    real matrix dy, xvar, xb, psb, psv, psxb, trt, tmt
		// This code is based on Asjad Replication
		// Gather all data
		real scalar nn
		dy  =st_data(.,dy_  ,touse)
		nn=rows(dy)
		// verify xvar
		if (xvar_==" ") {
			xvar=J(rows(dy),1,1)	
		}
		else xvar=st_data(.,xvar_,touse),J(rows(dy),1,1)			
		//xvar=st_data(.,xvar_,touse),J(rows(dy),1,1)
		xb=st_data(.,xb_,touse)
		psxb=st_data(.,psxb_,touse)
		real matrix psc
		psc=logistic(psxb)
		trt =st_data(.,trt_ ,touse)
		tmt =st_data(.,tmt_ ,touse)
		// and matrices
		psb =st_matrix(psb_ )
		psv =st_matrix(psV_ )
		// for now assume weights = 1
		real matrix w
		w=st_data(.,ww,touse)
		
		// TRAD DRDID
		real matrix w_1, w_0 
		w_1 = (w:*trt)
		w_1 = w_1 /mean(w_1)
		w_0 = (w:*psc:*(-trt:+1):/(-psc:+1))
		w_0 = w_0 /mean(w_0 ) 
		// ATT
		real matrix dy_xb, att, w_ols, wols_eX,
					XpX_inv, lin_wols, lin_ps, 
					n1, n0, nest, a, att_inf_func
					
		dy_xb=dy:-xb
		att = mean((w_1:-w_0):*(dy_xb))
		
		// influence functions OLS
		w_ols 	 =    w :* (1 :- trt)
		wols_eX  = w_ols:* (dy_xb):* xvar
		XpX_inv  = invsym(quadcross(xvar,w_ols,xvar))*nn 
		lin_wols =  wols_eX * XpX_inv   
		// IF for logit
		lin_ps 	   = (w :* (trt:-psc) :* xvar) * (psv * nn)
		// Components for RIF
		n1   = w_1:*((dy_xb):-mean(dy_xb,w_1))
		n0   = w_0:*((dy_xb):-mean(dy_xb,w_0))
		
		a    = ((1:-trt):/(1:-psc):^2)/ mean(psc:*(1:-trt):/(1:-psc))
		// This only works because w_1 and w_0 are mutually exclusive
		nest = lin_wols * (mean(xvar,w_1):-mean(xvar,w_0))' :+
		       lin_ps   * mean( a :* (dy_xb :- mean(dy_xb,w_0)) :* exp(psxb):/(1:+exp(psxb)):^2:*xvar)'			   
		// RIF att_inf_func = inf_treat' :- inf_control
		att_inf_func = att:+n1:-n0:-nest
		st_store(.,rif,touse, att_inf_func)	
		// Variance should be divided by n not n-1
	
	}
	//// standard IPW

//# RC
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	 void std_ipw_rc(string scalar y_, xvar_ , tmt_, trt_, psv_, pxb_, wgt_ ,  touse, rif){
    // main Loading variables
    real matrix y, 	xvar, tmt, trt, psv, psc, wgt
				
	y    = st_data(.,y_, touse)
		// verify xvar
		if (xvar_==" ") {
			xvar=J(rows(y),1,1)	
		}
		else xvar=st_data(.,xvar_,touse),J(rows(y),1,1)		
	//xvar = st_data(.,xvar_, touse), J(rows(y),1,1)
	tmt  = st_data(.,tmt_, touse)
	trt  = st_data(.,trt_, touse)
	psc  = logistic(st_data(.,pxb_, touse))
	wgt  = st_data(.,wgt_, touse)
	psv  = st_matrix(psv_)
	real scalar nn
 	nn = rows(y)
	
	real matrix w10, w11, w00, w01
	
    w10 = wgt :* trt :* (1 :- tmt)
    w11 = wgt :* trt :* tmt
    w00 = wgt :* psc :* (1 :- trt) :* (1 :- tmt):/(1 :- psc)
    w01 = wgt :* psc :* (1 :- trt) :* tmt:/(1 :- psc)
	
	w00 = w00:/mean(w00 )
	w01 = w01:/mean(w01 )
	w10 = w10:/mean(w10 )
	w11 = w11:/mean(w11 )
	
	real matrix att_treat_pre, att_treat_post, att_cont_pre, att_cont_post,
				eta_treat_pre, eta_treat_post, eta_cont_pre, eta_cont_post
	att_treat_pre  	= w10 :* y
    att_treat_post 	= w11 :* y
    att_cont_pre   	= w00 :* y
    att_cont_post  	= w01 :* y
    eta_treat_pre  	= mean(att_treat_pre)
    eta_treat_post 	= mean(att_treat_post)
    eta_cont_pre   	= mean(att_cont_pre)
    eta_cont_post  	= mean(att_cont_post)
	
	real matrix ipw_att, lin_rep_ps
    ipw_att 		= (eta_treat_post :- eta_treat_pre) :- (eta_cont_post :- eta_cont_pre)
    //score_ps 		= wgt :* (trt :- psc) :* xvar
    //Hessian_ps 		= psv :* nn
    lin_rep_ps 		= (wgt :* (trt :- psc) :* xvar) * (psv :* nn)
    
	real matrix inf_treat, inf_cont, M2_pre, M2_post, inf_cont_ps, att_inf_func
	
	inf_treat 		= (att_treat_post :- w11 :* eta_treat_post) :- (att_treat_pre :- w10 :* eta_treat_pre)
    inf_cont 		= (att_cont_post :- w01 :* eta_cont_post) :- (att_cont_pre :- w00 :* eta_cont_pre)
    M2_pre 			= mean(w00 :* (y :- eta_cont_pre) :* xvar)
    M2_post 		= mean(w01 :* (y :- eta_cont_post) :* xvar)
    inf_cont_ps 	= lin_rep_ps * (M2_post :- M2_pre)'
    inf_cont 		= inf_cont :+ inf_cont_ps
    
	att_inf_func 	= ipw_att :+ inf_treat :- inf_cont

	st_store(.,rif,touse,att_inf_func)

	
 //  -15.80330618	
 //  9.087929526
 }
 
// Regression approach
  void reg_rc(string scalar y_, yy_, xvar_ , tmt_, trt_, wgt_ ,  touse, rif) {
    // main Loading variables
    real matrix y,  y00, y01,
				xvar, tmt, trt,   wgt
 	y    = st_data(.,y_, touse)
	yy   = st_data(.,yy_, touse)
	y00  = yy[,1]
	y01  = yy[,2]
		// verify xvar
 		if (xvar_==" ") {
			xvar=J(rows(y),1,1)	
		}
		else xvar=st_data(.,xvar_,touse),J(rows(y),1,1)
		
 	//xvar = st_data(.,xvar_, touse), J(rows(y),1,1)
	tmt  = st_data(.,tmt_, touse)
	trt  = st_data(.,trt_, touse)
	//psc  = logistic(st_data(.,pxb_, touse))
	//psv  = st_matrix(psv_)
	wgt  = st_data(.,wgt_, touse)
	
	real scalar nn
	nn = rows(y)
	
	real matrix w10, w11, w0
	
	w10 			= wgt :* trt :* (1 :- tmt)
    w11 			= wgt :* trt :* tmt
    w0 				= wgt :* trt
	
	w10				= w10:/mean(w10 )
	w11				= w11:/mean(w11 )
	w0				= w0:/mean(w0 )
	
	real matrix att_treat_pre, att_treat_post, att_cont,
				eta_treat_pre, eta_treat_post, eta_cont, reg_att
    att_treat_pre 	= w10 :* y
    att_treat_post 	= w11 :* y
    att_cont 		= w0 :* (y01 :- y00)
    eta_treat_pre 	= mean(att_treat_pre)
    eta_treat_post 	= mean(att_treat_post)
    eta_cont 		= mean(att_cont)
    reg_att 		= (eta_treat_post :- eta_treat_pre) :- eta_cont
	
	real matrix w_ols_pre, wols_eX_pre, XpX_inv_pre, lin_rep_ols_pre
    w_ols_pre 		= wgt :* (1 :- trt) :* (1 :- tmt)
    //wols_x_pre 	= w_ols_pre :* xvar
    wols_eX_pre 	= w_ols_pre :* (y :- y00) :* xvar
    XpX_inv_pre 	= invsym(quadcross(xvar,w_ols_pre, xvar)):*nn
    lin_rep_ols_pre = wols_eX_pre * XpX_inv_pre
	
	real matrix w_ols_post, wols_eX_post, XpX_inv_post, lin_rep_ols_post
    w_ols_post 		= wgt :* (1 :- trt) :* tmt
    //wols_x_post 	= w_ols_post :* xvar
    wols_eX_post 	= w_ols_post :* (y :- y01) :* xvar
    XpX_inv_post 	= invsym(quadcross(xvar, w_ols_post, xvar)):*nn
    lin_rep_ols_post = wols_eX_post * XpX_inv_post
    
	real matrix inf_treat, inf_cont_1, inf_cont_2_post, inf_cont_2_pre, inf_control
	//inf_treat_pre 	= (att_treat_pre :- w10 :* eta_treat_pre)
    //inf_treat_post 	= (att_treat_post :- w11 :* eta_treat_post)
    inf_treat 		= (att_treat_post :- w11 :* eta_treat_post) :- (att_treat_pre :- w10 :* eta_treat_pre)
    inf_cont_1 		= (att_cont :- w0 :* eta_cont)
    //M1 				= mean(w0 :* xvar)
    inf_cont_2_post = lin_rep_ols_post * mean(w0 :* xvar)'
    inf_cont_2_pre 	= lin_rep_ols_pre  * mean(w0 :* xvar)'
    inf_control 	= (inf_cont_1 :+ inf_cont_2_post :- inf_cont_2_pre)
    
	real matrix att_inf_func
	att_inf_func 	= reg_att :+ (inf_treat :- inf_control)

	st_store(.,rif,touse,att_inf_func)
	// Variance should be divided by n not n-1
	
 }

 /// Abadies IPW
 
  void ipw_abadie_rc(string scalar y_, xvar_ , tmt_, trt_, psv_, pxb_, wgt_ ,  touse, rif){
    // main Loading variables
    real matrix y, 	xvar, tmt, trt, psv, psc, wgt
				
		y    = st_data(.,y_, touse)
		// verify xvar
		if (xvar_==" ") {
			xvar=J(rows(y),1,1)	
		}
		else xvar=st_data(.,xvar_,touse),J(rows(y),1,1)			
		//xvar = st_data(.,xvar_, touse), J(rows(y),1,1)
		tmt  = st_data(.,tmt_, touse)
		trt  = st_data(.,trt_, touse)
		psc  = logistic(st_data(.,pxb_, touse))
		wgt  = st_data(.,wgt_, touse)
		psv  = st_matrix(psv_)
		real scalar nn
		nn = rows(y)
	
	real matrix w10, w11, w00, w01
    w10 				= wgt :* trt :* (1 :- tmt)
    w11 				= wgt :* trt :* tmt
    w00 				= wgt :* psc :* (1 :- trt) :* (1 :- tmt):/(1 :- psc)
    w01 				= wgt :* psc :* (1 :- trt) :* tmt:/(1 :- psc)
	
	real matrix pi_hat, lambda_hat, one_lambda_hat
	pi_hat       		= mean(wgt :* trt)
    lambda_hat 			= mean(wgt :* tmt)
    one_lambda_hat 		= mean(wgt :* (1 :- tmt))
	
	real matrix att_treat_pre, att_treat_post, att_cont_pre, att_cont_post,
				eta_treat_pre, eta_treat_post, eta_cont_pre, eta_cont_post
				
    att_treat_pre 		= w10 :* y:/(pi_hat :* one_lambda_hat)
    att_treat_post 		= w11 :* y:/(pi_hat :* lambda_hat)
    att_cont_pre 		= w00 :* y:/(pi_hat :* one_lambda_hat)
    att_cont_post 		= w01 :* y:/(pi_hat :* lambda_hat)
    eta_treat_pre 		= mean(att_treat_pre)
    eta_treat_post 		= mean(att_treat_post)
    eta_cont_pre 		= mean(att_cont_pre)
    eta_cont_post 		= mean(att_cont_post)
	
	real matrix ipw_att
    ipw_att 			= (eta_treat_post - eta_treat_pre) - (eta_cont_post - eta_cont_pre)
	
	real matrix lin_rep_ps, inf_treat_post, inf_treat_pret, inf_cont_post, inf_cont_pret
    //score_ps 			= wgt :* (trt :- psc) :* xvar
    //Hessian_ps 			= psv :* nn
    lin_rep_ps 			= (wgt :* (trt :- psc) :* xvar) * (psv :* nn)
	
	inf_treat_post 		=(att_treat_post :- eta_treat_post) :-
						((wgt :* trt :- pi_hat)     :* eta_treat_post:/pi_hat) :-
						((wgt :* tmt :- lambda_hat) :* eta_treat_post:/lambda_hat)
    ///inf_treat_post 		= inf_treat_post1 :+ inf_treat_post2 :+ inf_treat_post3
	
    inf_treat_pret 		= att_treat_pre :- eta_treat_pre :-
						 (wgt :*       trt  :- pi_hat) :* eta_treat_pre:/pi_hat :-
						 (wgt :* (1 :- tmt) :- one_lambda_hat) :* eta_treat_pre:/one_lambda_hat
    // inf_treat_pret 		= inf_treat_pre1 :+ inf_treat_pre2 :+ inf_treat_pre3
	
    inf_cont_post		= att_cont_post :- eta_cont_post :-
						  (wgt :* trt :- pi_hat) :* eta_cont_post:/pi_hat :-
						  (wgt :* tmt :- lambda_hat) :* eta_cont_post:/lambda_hat
    ///inf_cont_post = inf_cont_post1 :+ inf_cont_post2 :+ inf_cont_post3
    inf_cont_pret       = att_cont_pre :- eta_cont_pre :-
						  (wgt :* trt :- pi_hat) :* eta_cont_pre:/pi_hat :-
						  (wgt :* (1 :- tmt) :- one_lambda_hat) :* eta_cont_pre:/one_lambda_hat
     		
	//inf_cont_pret= inf_cont_pre1 :+ inf_cont_pre2 :+ inf_cont_pre3
	real matrix inf_logit, att_inf_func
    //mom_logit_pre 		= mean(-att_cont_pre :* xvar)
    //mom_logit_pre 		= mean(mom_logit_pre)
    //mom_logit_post 		= mean(-att_cont_post :* xvar)
    //mom_logit_post 		= mean(mom_logit_post)
    inf_logit 			= lin_rep_ps * (mean(-att_cont_post :* xvar) :-
										mean(-att_cont_pre :* xvar))'
	
    att_inf_func 		= ipw_att :+ (inf_treat_post :- inf_treat_pret) :- (inf_cont_post :- inf_cont_pret) :+ inf_logit
	
	st_store(.,rif,touse,att_inf_func)
		
//  -19.89330192
//  53.86822411
 }
 
/// DRDID_RC
 void drdid_rc(string scalar y_, yy_, xvar_ , tmt_, trt_, psv_, pxb_, wgt_ ,  touse, rif){
    // main Loading variables
    real matrix y,  y00, y01, y10, y11,
				xvar, tmt, trt, psv, psc, wgt
				
	y    = st_data(.,y_, touse)
	yy   = st_data(.,yy_, touse)
	y00  = yy[,1]
	y01  = yy[,2]
	y10  = yy[,3]
	y11  = yy[,4]
		// verify xvar
		if (xvar_==" ") {
			xvar=J(rows(y),1,1)	
		}
		else {
		    xvar=st_data(.,xvar_,touse),J(rows(y),1,1)	
		}
		
	//xvar = st_data(.,xvar_, touse), J(rows(y),1,1)
	tmt  = st_data(.,tmt_, touse)
	trt  = st_data(.,trt_, touse)
	psc  = logistic(st_data(.,pxb_, touse))
	wgt  = st_data(.,wgt_, touse)
	psv  = st_matrix(psv_)
	
	real matrix y0
	real scalar nn
	y0   = y00:*(-tmt:+1) + y01:*tmt
	nn = rows(y)
	
	real matrix w10, w11, w00, w01, w1
    w10 = wgt :* trt :* (1 :- tmt)
    w11 = wgt :* trt :* tmt
    w00 = wgt :* psc :* (1 :- trt) :* (1 :- tmt):/(1 :- psc)
    w01 = wgt :* psc :* (1 :- trt) :* tmt:/(1 :- psc)
	w1  = wgt :* trt
	
	w00 = w00:/mean(w00 )
	w01 = w01:/mean(w01 )
	w10 = w10:/mean(w10 )
	w11 = w11:/mean(w11 )
	w1 = w1:/mean(w1 )
	
	real matrix att_treat_pre, att_treat_post,  att_cont_pre, att_cont_post,
				att_trt_post, att_trtt1_post, att_trt_pre, att_trtt0_pre,
				eta_treat_pre, eta_treat_post,  eta_cont_pre, eta_cont_post,
				eta_trt_post, eta_trtt1_post, eta_trt_pre, eta_trtt0_pre
				
    att_treat_pre 		= w10 :* (y :- y0)
    att_treat_post 		= w11 :* (y :- y0)
    att_cont_pre  		= w00 :* (y :- y0)
    att_cont_post  		= w01 :* (y :- y0)
	
    att_trt_post   		= w1  :* (y11 :- y01)
    att_trtt1_post 		= w11 :* (y11 :- y01)
    att_trt_pre   		= w1  :* (y10 :- y00)
    att_trtt0_pre 		= w10 :* (y10 :- y00)
	
    eta_treat_pre 		= mean(att_treat_pre)
    eta_treat_post 		= mean(att_treat_post)
    eta_cont_pre  		= mean(att_cont_pre)
    eta_cont_post  		= mean(att_cont_post)
    eta_trt_post   		= mean(att_trt_post)
    eta_trtt1_post 		= mean(att_trtt1_post)
    eta_trt_pre   		= mean(att_trt_pre)
    eta_trtt0_pre 		= mean(att_trtt0_pre)
	
	real matrix trtr_att
    trtr_att      		= (eta_treat_post :- eta_treat_pre) :- (eta_cont_post :- eta_cont_pre) :+ (eta_trt_post :- eta_trtt1_post) :- (eta_trt_pre :- eta_trtt0_pre)
	
	real matrix wgt_ols_pre, XpX_inv_pre, lin_ols_pre, 
				wgt_ols_post, XpX_inv_post, lin_ols_post,
				XpX_inv_pre_treat, lin_ols_pre_treat,
				XpX_inv_post_treat, lin_ols_post_treat
	wgt_ols_pre     	= wgt :* (1 :- trt) :* (1 :- tmt)
    //wols_x_pre          = wgt_ols_pre :* xvar
    //wols_eX_pre         = wgt_ols_pre :* (y :- y00) :* xvar
    XpX_inv_pre         = invsym(quadcross(xvar,wgt_ols_pre, xvar)):*nn
    lin_ols_pre 		= ( wgt_ols_pre :* (y :- y00) :* xvar) * XpX_inv_pre
    
	wgt_ols_post     	= wgt :* (1 :- trt) :* tmt
    //wols_x_post         = wgt_ols_post :* xvar
    //wols_eX_post        = wgt_ols_post :* (y :- y01) :* xvar
    XpX_inv_post 		= invsym(quadcross(xvar,wgt_ols_post, xvar)):*nn
	lin_ols_post 		= (wgt_ols_post :* (y :- y01) :* xvar) * XpX_inv_post
	    
    //wols_x_pre_treat 	= w10 :* xvar
    //wols_eX_pre_treat 	= w10 :* (y :- y10) :* xvar
    XpX_inv_pre_treat 	= invsym(quadcross(xvar, w10, xvar)):*nn
	lin_ols_pre_treat 	= ( w10 :* (y :- y10) :* xvar) * XpX_inv_pre_treat
	
	//wols_x_post_treat   = w11 :* xvar
    //wols_eX_post_treat  = w11 :* (y :- y11) :* xvar
    XpX_inv_post_treat  = invsym(quadcross(xvar, w11, xvar)):*nn
    lin_ols_post_treat 	= (w11 :* (y :- y11) :* xvar) * XpX_inv_post_treat
	
	real matrix lin_rep_ps, inf_treat_pre, inf_treat_post
    // check psv for probit
	//score_ps 			= wgt :* (trt :- psc) :* xvar
    //Hessian_ps 			= psv :* nn
    lin_rep_ps 			= (wgt :* (trt :- psc) :* xvar) * (psv :* nn)
    inf_treat_pre 		= att_treat_pre  :- w10 :* eta_treat_pre 
    inf_treat_post 		= att_treat_post :- w11 :* eta_treat_post
	
	real matrix M1_post, M1_pre, inf_treat_or_post, inf_treat_or_pre
	
    M1_post 			= -mean(w11 :* tmt :* xvar)
    M1_pre 				= -mean(w10 :* (1 :- tmt) :* xvar)
	inf_treat_or_post 	= lin_ols_post * M1_post'
    inf_treat_or_pre 	= lin_ols_pre * M1_pre'
	
	real matrix inf_treat_or, inf_treat, inf_cont_pre, inf_cont_post
	
    inf_treat_or 		= inf_treat_or_post :+ inf_treat_or_pre
    inf_treat 			= inf_treat_post :- inf_treat_pre :+ inf_treat_or
    inf_cont_pre 		= att_cont_pre  :- w00 :* eta_cont_pre 
    inf_cont_post 		= att_cont_post :- w01 :* eta_cont_post 
    
	real matrix M2_pre, M2_post, inf_cont_ps, M3_post, M3_pre, inf_cont_or_post, inf_cont_or_pre
	M2_pre 				= mean(w00 :* (y :- y0 :- eta_cont_pre) :* xvar)
    M2_post 			= mean(w01 :* (y :- y0 :- eta_cont_post) :* xvar)
    inf_cont_ps 		= lin_rep_ps * (M2_post :- M2_pre)'
	
    M3_post 			= -mean(w01 :* tmt :* xvar)
    M3_pre 				= -mean(w00 :* (1 :- tmt) :* xvar)
    inf_cont_or_post 	= lin_ols_post * M3_post'
    inf_cont_or_pre 	= lin_ols_pre  * M3_pre'
	
	real matrix inf_cont_or, inf_cont, trtr_eta_inf_func1
	
    inf_cont_or 		= inf_cont_or_post :+ inf_cont_or_pre
    inf_cont 			= inf_cont_post    :- inf_cont_pre :+ inf_cont_ps :+ inf_cont_or
    trtr_eta_inf_func1 	= inf_treat :- inf_cont
	
	real matrix inf_eff, mom_post, mom_pre, inf_or
    //inf_eff1 			= att_trt_post   :- w1  :* eta_trt_post   
    //inf_eff2 			= att_trtt1_post :- w11 :* eta_trtt1_post 
    //inf_eff3 			= att_trt_pre    :- w1  :* eta_trt_pre   
    //inf_eff4 			= att_trtt0_pre  :- w10 :* eta_trtt0_pre 
    inf_eff 			= ((att_trt_post   :- w1  :* eta_trt_post)    :- 
						   (att_trtt1_post :- w11 :* eta_trtt1_post)) :-
						  ((att_trt_pre    :- w1  :* eta_trt_pre)     :- 
						   (att_trtt0_pre :- w10 :* eta_trtt0_pre))
    mom_post 			= mean((w1 :- w11) :* xvar)
    mom_pre 			= mean((w1 :- w10) :* xvar)
	// check this
    //inf_or_post 		= ((lin_ols_post_treat :- lin_ols_post) * mom_post')
    //inf_or_pre 		= 
    inf_or 				= ((lin_ols_post_treat :- lin_ols_post) * mom_post') :- ((lin_ols_pre_treat :- lin_ols_pre) * mom_pre')
	
	att_inf_func	 	= trtr_att :+ trtr_eta_inf_func1 :+ inf_eff :+ inf_or
	
	st_store(.,rif,touse,att_inf_func)
	// Variance should be divided by n not n-1
 	
//  -.1677954483	
// .2008991705	
 }

/// DRDID_RC1
void drdid_rc1(string scalar y_, yy_, xvar_ , tmt_, trt_, psv_, pxb_, wgt_ ,  touse, rif){
    // main Loading variables
    real matrix y,  y00, y01, y10, y11,
				xvar, tmt, trt, psv, psc, wgt
				
	y    = st_data(.,y_, touse)
	yy   = st_data(.,yy_, touse)
	y00  = yy[,1]
	y01  = yy[,2]
	y10  = yy[,3]
	y11  = yy[,4]
		// verify xvar
		if (xvar_==" ") {
			xvar=J(rows(y),1,1)	
		}
		else xvar=st_data(.,xvar_,touse),J(rows(y),1,1)		
	//xvar = st_data(.,xvar_, touse), J(rows(y),1,1)
	
	tmt  = st_data(.,tmt_, touse)
	trt  = st_data(.,trt_, touse)
	psc  = logistic(st_data(.,pxb_, touse))
	wgt  = st_data(.,wgt_, touse)
	psv  = st_matrix(psv_)
	
	real matrix y0
	real scalar nn
	y0   = y00:*(-tmt:+1) + y01:*tmt
	nn = rows(y)
    
	real matrix w10, w11, w00, w01
    w10 		= wgt :* trt :* (1 :- tmt)
    w11 		= wgt :* trt :* tmt
    w00 		= wgt :* psc :* (1 :- trt) :* (1 :- tmt):/(1 :- psc)
    w01 		= wgt :* psc :* (1 :- trt) :* tmt:/(1 :- psc)
	
	w00 = w00:/mean(w00 )
	w01 = w01:/mean(w01 )
	w10 = w10:/mean(w10 )
	w11 = w11:/mean(w11 )
	
	real matrix eta_trt_pre, eta_trt_post, eta_cont_pre, eta_cont_post,
				att_trt_pre, att_trt_post, att_cont_pre, att_cont_post
				
    eta_trt_pre 	= w10 :* (y :- y0)
    eta_trt_post 	= w11 :* (y :- y0)
    eta_cont_pre 	= w00 :* (y :- y0)
    eta_cont_post 	= w01 :* (y :- y0)
    att_trt_pre 	= mean(eta_trt_pre)
    att_trt_post 	= mean(eta_trt_post)
    att_cont_pre 	= mean(eta_cont_pre)
    att_cont_post 	= mean(eta_cont_post)
	
	real matrix trtr_att, w_ols_pre, wols_eX_pre, lin_rep_ols_pre,
						  w_ols_post, wols_eX_post, lin_rep_ols_post
    trtr_att 		= (att_trt_post :- att_trt_pre) :- (att_cont_post :- att_cont_pre)
	
    w_ols_pre 		= wgt :* (1 :- trt) :* (1 :- tmt)
    wols_eX_pre 	= w_ols_pre :* (y :- y00) :* xvar
 
    lin_rep_ols_pre = wols_eX_pre * invsym(quadcross(xvar, w_ols_pre, xvar)):*nn
	
    w_ols_post  	= wgt :* (1 :- trt) :* tmt
    wols_eX_post 	= w_ols_post  :* (y :- y01) :* xvar
    lin_rep_ols_post = wols_eX_post * invsym(quadcross( xvar,w_ols_post, xvar)):*nn
	
	real matrix lin_rep_ps, inf_trt_pre, inf_trt_post, M1_post, M1_pre
    //score_ps 		= wgt :* (trt :- psc) :* xvar
    //Hessian_ps 		= psv :* nn
    lin_rep_ps 		= (wgt :* (trt :- psc) :* xvar) * (psv :* nn)
    inf_trt_pre 	= eta_trt_pre :- w10 :* att_trt_pre
    inf_trt_post 	= eta_trt_post :- w11 :* att_trt_post
	M1_post 		= -mean(w11 :* tmt :* xvar)
    M1_pre 			= -mean(w10 :* (1 :- tmt) :* xvar)
    
	real matrix inf_trt_or, inf_trt
    inf_trt_or 		= (lin_rep_ols_post * M1_post') :+ (lin_rep_ols_pre * M1_pre')
    inf_trt 		= inf_trt_post :- inf_trt_pre :+ inf_trt_or
    
	real matrix inf_cont_pre , inf_cont_post, M2_pre,  M2_post, inf_cont_ps, M3_post, M3_pre

	inf_cont_pre 	= eta_cont_pre :- w00 :* att_cont_pre
    inf_cont_post 	= eta_cont_post :- w01 :* att_cont_post
    M2_pre 			= mean(w00 :* (y :- y0 :- att_cont_pre) :* xvar)
    M2_post 		= mean(w01 :* (y :- y0 :- att_cont_post) :* xvar)
    inf_cont_ps 	= lin_rep_ps * (M2_post :- M2_pre)'
    M3_post 		= -mean(w01 :* tmt :* xvar)
    M3_pre 			= -mean(w00 :* (1 :- tmt) :* xvar)

	real matrix inf_cont_or, inf_cont, att_inf_func
    inf_cont_or 	= (lin_rep_ols_post * M3_post') :+ (lin_rep_ols_pre * M3_pre')
    inf_cont 		= inf_cont_post :- inf_cont_pre :+ inf_cont_ps :+ inf_cont_or
    att_inf_func 	= trtr_att :+ inf_trt :- inf_cont
	
	st_store(.,rif,touse,att_inf_func)
	// Variance should be divided by n not n-1
 	
 // -3.633433441	
//3.107123089
}
 
/// drdid_imp_rc
void drdid_imp_rc(string scalar y_, yy_, xvar_ , tmt_, trt_, psv_, pxb_, wgt_ ,  touse, rif){
    // main Loading variables
    real matrix y,  y00, y01, y10, y11,
				xvar, tmt, trt, psv, psc, wgt
				
	y    = st_data(.,y_, touse)
	yy   = st_data(.,yy_, touse)
	y00  = yy[,1]
	y01  = yy[,2]
	y10  = yy[,3]
	y11  = yy[,4]
		// verify xvar
		if (xvar_==" ") {
			xvar=J(rows(y),1,1)	
		}
		else xvar=st_data(.,xvar_,touse),J(rows(y),1,1)		
//	xvar = st_data(.,xvar_, touse), J(rows(y),1,1)
	tmt  = st_data(.,tmt_, touse)
	trt  = st_data(.,trt_, touse)
	psc  = logistic(st_data(.,pxb_, touse))
	wgt  = st_data(.,wgt_, touse)
	psv  = st_matrix(psv_)
	
	real matrix y0
	real scalar nn
	y0   = y00:*(-tmt:+1) + y01:*tmt
	nn = rows(y)

	real matrix w10, w11, w00, w01, w1
    w10 = wgt :* trt :* (1 :- tmt)
    w11 = wgt :* trt :* tmt
    w00 = wgt :* psc :* (1 :- trt) :* (1 :- tmt):/(1 :-  psc)
    w01 = wgt :* psc :* (1 :- trt) :* tmt:/(1 :- psc)
    w1  = wgt :* trt

	w00 = w00:/mean(w00 )
	w01 = w01:/mean(w01 )
	w10 = w10:/mean(w10 )
	w11 = w11:/mean(w11 )
	w1 = w1:/mean(w1 )
	
	real matrix att_treat_pre, att_treat_post, att_cont_pre, att_cont_post, att_trt_post, att_trtt1_post,
				att_trt_pre, att_trtt0_pre
	
    att_treat_pre  = w10 :* (y :- y0)
    att_treat_post = w11 :* (y :- y0)
    att_cont_pre   = w00 :* (y :- y0)
    att_cont_post  = w01 :* (y :- y0)
    att_trt_post   = w1  :* (y11 :- y01)
    att_trtt1_post = w11 :* (y11 :- y01)
    att_trt_pre    = w1  :* (y10 :- y00)
    att_trtt0_pre  = w10 :* (y10 :- y00)
	
	real matrix eta_treat_pre, eta_treat_post, eta_cont_pre, eta_cont_post, eta_trt_post, eta_trtt1_post,
				eta_trt_pre, eta_trtt0_pre
				
    eta_treat_pre  = mean(att_treat_pre)
    eta_treat_post = mean(att_treat_post)
    eta_cont_pre   = mean(att_cont_pre)
    eta_cont_post  = mean(att_cont_post)
    eta_trt_post   = mean(att_trt_post)
    eta_trtt1_post = mean(att_trtt1_post)
    eta_trt_pre    = mean(att_trt_pre)
    eta_trtt0_pre  = mean(att_trtt0_pre)
	
	real matrix trtr_att
	
    trtr_att       = (eta_treat_post :- eta_treat_pre) :- (eta_cont_post :- eta_cont_pre) :+ (eta_trt_post :- eta_trtt1_post) :- (eta_trt_pre :- eta_trtt0_pre)
	
	real matrix inf_treat,  inf_cont,  att_inf_func1,  inf_eff, att_inf_func

	
	inf_treat      = (att_treat_post :- w11 :* eta_treat_post) :- (att_treat_pre  :- w10 :* eta_treat_pre)
    inf_cont       = (att_cont_post  :- w01 :* eta_cont_post)  :- (att_cont_pre   :- w00 :* eta_cont_pre)
	att_inf_func1  = inf_treat :- inf_cont
    inf_eff        =  ((att_trt_post   :- w1  :* eta_trt_post) :- 
					   (att_trtt1_post :- w11 :* eta_trtt1_post)) :- 
					  ((att_trt_pre    :- w1  :* eta_trt_pre) :- 
					   (att_trtt0_pre  :- w10 :* eta_trtt0_pre))
	
    att_inf_func  = trtr_att :+ att_inf_func1 :+ inf_eff
	
	st_store(.,rif,touse,att_inf_func)
	// Variance should be divided by n not n-1
 	
//-.2088586355	
//.2003375215	
}

/// drdid_imp_rc1
void drdid_imp_rc1(string scalar y_, yy_, xvar_ , tmt_, trt_, psv_, pxb_, wgt_ ,  touse, rif){
    // main Loading variables
    real matrix y,  y00, y01, y10, y11,
				xvar, tmt, trt, psv, psc, wgt
	y    = st_data(.,y_, touse)
	yy   = st_data(.,yy_, touse)
	y00  = yy[,1]
	y01  = yy[,2]
	y10  = yy[,3]
	y11  = yy[,4]
		// verify xvar
		if (xvar_==" ") {
			xvar=J(rows(y),1,1)	
		}
		else xvar=st_data(.,xvar_,touse),J(rows(y),1,1)		
	//xvar = st_data(.,xvar_, touse), J(rows(y),1,1)
	tmt  = st_data(.,tmt_, touse)
	trt  = st_data(.,trt_, touse)
	psc  = logistic(st_data(.,pxb_, touse))
	wgt  = st_data(.,wgt_, touse)
	psv  = st_matrix(psv_)
	
	real matrix y0
	real scalar nn
	y0   = y00:*(-tmt:+1) + y01:*tmt
	nn = rows(y)
	
	real matrix w10, w11, w00, w01, 
				eta_treat_pre, eta_treat_post, eta_cont_pre, eta_cont_post,
				att_treat_pre, att_treat_post, att_cont_pre, att_cont_post
				
    w10 			= wgt :* trt :* (1 :- tmt)
    w11 			= wgt :* trt :* tmt
    w00 			= wgt :* psc:* (1 :- trt) :* (1 :- tmt):/(1 :-  psc)
	w01 			= wgt :* psc:* (1 :- trt) :* tmt:/(1 :- psc)
    
	eta_treat_pre 	= w10 :* (y :- y0):/mean(w10)
    eta_treat_post 	= w11 :* (y :- y0):/mean(w11)
    eta_cont_pre 	= w00 :* (y :- y0):/mean(w00)
    eta_cont_post 	= w01 :* (y :- y0):/mean(w01)
    
	att_treat_pre 	= mean(eta_treat_pre)
    att_treat_post 	= mean(eta_treat_post)
    att_cont_pre 	= mean(eta_cont_pre)
    att_cont_post 	= mean(eta_cont_post)
    
	real matrix trtr_att, inf_treat, inf_cont, att_inf_func
	trtr_att 		= (att_treat_post :- att_treat_pre) :- (att_cont_post :-  att_cont_pre)
    inf_treat 		= (eta_treat_post :- w11 :* att_treat_post:/mean(w11) ):- (eta_treat_pre :- w10 :* att_treat_pre:/mean(w10))
    inf_cont 		= (eta_cont_post :- w01 :* att_cont_post:/mean(w01)) :- ( eta_cont_pre :- w00 :* att_cont_pre:/mean(w00))
    att_inf_func 	= trtr_att :+ inf_treat :- inf_cont
	
	// Wrapping up
	st_store(.,rif,touse,att_inf_func)
	// Variance should be divided by n not n-1
 	
//  -3.683728719	
//	 3.114495585
}

// Clustered Standard errors

void clusterse(real matrix iiff, cl, V, real scalar cln){
    /// estimates Clustered Standard errors
    real matrix ord, xcros, ifp, info, vv 

	ord  = order(cl,1)
	iiff = iiff[ord,]
	cl   = cl[ord,]
	// check how I cleaned data!
	info  = panelsetup(cl,1)
	// faster Cluster? Need to do this for mmqreg
	ifp   = panelsum(iiff,info)
	xcros = quadcross(ifp,ifp)
	real scalar nt, nc
	nt=rows(iiff)
	nc=rows(info)
	V =	xcros/(nt^2)
	cln=nc
	// Esto es para ver como hacer clusters.
	//*nc/(nc-1)
	//st_matrix(V,    vv)
	//st_numscalar(ncl, nc)
	//        ^     ^
	//        |     |
	//      stata   mata
}
//** Simple Bootstrap.
 
real matrix mboot_did(real matrix rif, mean_rif, real scalar reps, wbtype) {
	real matrix yy, bsmean
	yy=rif:-mean_rif
 	bsmean=J(reps,cols(yy),0)
	real scalar i,n, k1, k2
	n=rows(yy)
	k1=((1+sqrt(5))/(2*sqrt(5)))
	k2=0.5*(1+sqrt(5)) 
	// WBootstrap:Mammen 
	if (wbtype==1) {			
		for(i=1;i<=reps;i++){
			bsmean[i,]=mean(yy:*(k2:-sqrt(5)*(rbinomial(n,1,1,k1))) )	
		}
	}
	
	else if (wbtype==2) {
		for(i=1;i<=reps;i++){
			bsmean[i,]=mean(yy:*(1:-2*rbinomial(n,1,1,0.5) ) )	
		}
	}
	
	return(bsmean)
}

real matrix mboot_didc(real matrix rif, mean_rif, clv , real scalar reps, wbtype, nc) {
	real matrix yy, bsmean
	real matrix sclv, wmult
	real scalar i,n, k1, k2, nn
	yy=rif:-mean_rif
 	bsmean=J(reps,cols(yy),0)
	
	nn=rows(uniqrows(clv))
	nc=nn
	k1=((1+sqrt(5))/(2*sqrt(5)))
	k2=0.5*(1+sqrt(5))
	if (wbtype==1) {		
 
		for(i=1;i<=reps;i++){
		    wmult=rbinomial(nn,1,1,k1)
			bsmean[i,]=mean(yy:*(k2:-sqrt(5)*wmult[clv] ) )	
			
		}
	}
	
	else if (wbtype==2) {
		for(i=1;i<=reps;i++){
		    wmult=(rbinomial(nn,1,1,0.5))
			bsmean[i,]=mean(yy:*(1:-2* wmult[clv] ) )	
		}
	}
	return(bsmean)
	
}

///clust("`att'","`cluster'","`touse'", "`V'",
///mboot("`att'", "`touse'", "`V'","`ciband'","`cluster'", `reps', `wbtype', `ci')
void make_tbl(string scalar iiff, clv, touse, // RIF, Cluster variable, and sample
			  bb_ , VV_, ccbb, cln,                   // WHere to save bb and VV. Also #clv
			  wboot,                          // options for Wbootstrap. Reps, wbtype and CI
			  real scalar reps, wbtype, ci ){
			      
	real matrix rif, clvar , bb, VV, ord, info, ifp
	real matrix cband
	real scalar nobs, nc
	
	// nc number of clusters
	rif = st_data(.,iiff,touse)
	  
	// real scalar cln
	bb  = mean(rif)
	nobs     = rows(rif)
	// simple
 
	if ((clv==" ") & (wboot==" ")) {	
		VV=quadcrossdev(rif,bb,rif,bb):/ (nobs^2) 
	}
	
	// cluster std
	if ((clv!=" ") & (wboot==" ")) {
		clvar=st_data(.,clv,touse)
		ord   = order(clvar,1)
		rif   = rif[ord,]
		clvar = clvar[ord,]
		
		info  = panelsetup(clvar,1)
 		ifp   = panelsum((rif:-bb),info)
 		VV    = quadcross(ifp,ifp)/nobs:^2
		nc=rows(info)		
	}
	
	// wboot no cluster
	
	if (wboot!=" ") {
	    
		mboot(rif,bb, VV, cband, clv, touse ,reps, wbtype, ci, nc )
	}
	
	st_matrix(bb_,bb)
	st_matrix(VV_,VV)
	st_matrix(ccbb,cband)
	st_numscalar(cln, nc)
	 
	
 } 
 
real matrix iqrse(real matrix y) {
    real scalar q25,q75
	q25=ceil((rows(y)+1)*.25)
	q75=ceil((rows(y)+1)*.75)
	real scalar j
	real matrix iqrs
	iqrs=J(1,cols(y),0)
	for(j=1;j<=cols(y);j++){
	    y=sort(y,j)
		iqrs[,j]=(y[q75,j]-y[q25,j]):/(invnormal(.75)-invnormal(.25) )
	}
	return(iqrs)
}

real vector qtp(real matrix y, real scalar p) {
    real scalar k, i, q
	real matrix yy, qq
	qq=J(1,0,.)
	k = cols(y)
	for(i=1;i<=k;i++){
		yy=sort(y[,i],1)
		q=ceil((rows(yy)+1)*p)    
		qq=qq,yy[q,]
	}
    
	return(qq)
}

void mboot(real matrix rif,mean_rif, vv, cband, string scalar clv, touse,  real scalar reps, wbtype, ci , nc ) {
    //, real scalar reps, wbtype, ci 
    real matrix fr, qt
	//real scalar reps, wbtype
 
	real matrix ifse  
	// this gets the Bootstraped values
	if (clv ==" ") {
		fr=mboot_did(rif,mean_rif      , reps, wbtype)
		ifse = iqrse(fr)
		qt = qtp(abs(fr :/ ifse),ci)
		cband=( mean_rif':-qt':* ifse' ,  
				mean_rif':+qt':* ifse' , mean_rif, ifse, qt' )
	}
	else {
 		clvar=st_data(.,clv, touse)
		fr=mboot_didc(rif,mean_rif, clvar, reps, wbtype, nc )
		ifse = iqrse(fr)
		qt = qtp(abs(fr :/ ifse),ci)
		cband=( mean_rif':-qt':* ifse' ,  
				mean_rif':+qt':* ifse' , mean_rif, ifse, qt' )
	}
	vv=quadcross(ifse,ifse):*I(cols(ifse))

}
 
 
/// qtp(abs(xx/ iqrse(xx)),.95) 
end

program addr, rclass
	return `0'
end 
