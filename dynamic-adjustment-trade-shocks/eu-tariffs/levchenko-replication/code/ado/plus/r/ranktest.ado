*! ranktest 2.0.04  21sept2020
*! authors mes & fw; KP stat based on code by fk
*! see end of file for version comments

program define ranktest, rclass sortpreserve

	local lversion 02.0.04

	if _caller() < 11 {
		ranktest9 `0'
		return add						//  otherwise all the ranktest9 results are zapped
		return local ranktestcmd		ranktest9
		return local cmd				ranktest
		return local version			`lversion'
		exit
	}
	else if _caller() < 13 {
		ranktest11 `0'
		return add						//  otherwise all the ranktest11 results are zapped
		return local ranktestcmd		ranktest11
		return local cmd				ranktest
		return local version			`lversion'
		exit
	}

	version 13.1

	if substr("`1'",1,1)== "," {
		if "`2'"=="version" {
			di in ye "`lversion'"
			return local version `lversion'
			exit
		}
		else {
			di as err "ranktest error: invalid syntax"
			exit 198
		}
	}

	// If varlist 1 or varlist 2 have a single element, parentheses optional

	if substr("`1'",1,1)=="(" {
		GetVarlist `0'
		local y `s(varlist)'
		local 0 `"`s(rest)'"'
		sret clear
	}
	else {
		local y `1'
		mac shift 1
		local 0 `"`*'"'
	}

	if substr("`1'",1,1)=="(" {
		GetVarlist `0'
		local z `s(varlist)'
		local 0 `"`s(rest)'"'
		sret clear
	}
	else {
		local z `1'
		mac shift 1
		// Need to reinsert comma before options (if any) for -syntax- command to work
		local 0 `", `*'"'
	}

	// y and z macros created, now ready to parse options
	
	// Option version ignored here if varlists were provided
	syntax [if] [in] [aw fw pw iw/]				///
		[,										///
		partial(varlist ts fv)					///
		NOConstant								///
		center									///
		wald									///
		KP										/// default
		NOSVD									/// override default use of SVD algorithm with KP
		JGMM2s									///
		Jcue									///
		j2lr									///
		j2l										///
		LR										/// for iid case only
		small									/// small-sample adjustment
		jtol(real 1e-10)						/// tolerance for change in J; Mata's default for vtol=1e-7
		btol(real 1e-5)							/// tolerance for change in beta; Mata's default for ptol=1e-6
		binit(string)							///
		NODOTS									/// no dots for iterated cue; interchangable with notrace
		tracelevel(string)						/// trace level for numerical cue; "nodots" >= "none"
		NOITERate								///
		NOCOMBiter								///
		NOCOLLIN								///
		NOIID									/// force use of robust code
		ALLrank									/// default
		NULLrank								///
		FULLrank								///
		rr(integer 0)							/// rank reduction
		NOEVORDER								/// overrides default of evorder for jcue and j2lr
		NOSTD									/// override default behaviour to standardize
		kc(real 1e-08)							/// adj if var(pihat) singular
		maxiter(integer 100)					///
		ROBust									///
		cluster(varlist)						///
		BW(string)								///
		kernel(string)							///
		Tvar(varname)							///
		Ivar(varname)							///
		h(name)									/// xtabond2-related
		hvar(varname)							/// xtabond2-related
		NOHMAT									/// xtabond2-related - force ignore of h
		sw										///
		psd0									///
		psda									///
		version									///
		dofminus(integer 0)						///
		]

	
	******************** options ***********************	
	
	// allow lower-case for string options
	foreach opt in binit {
		local `opt'		=strlower("``opt''")
	}
	
	// set flags based on options
	local jflag			="`jcue'`j2l'`j2lr'`jgmm2s'"~=""
	local jcueflag		="`jcue'"~=""
	local j2lflag		="`j2l'"~=""
	local j2lrflag		="`j2lr'"~=""
	local jgmm2sflag	="`jgmm2s'"~=""
	local kpflag		="`kp'"~="" | "`jcue'`j2l'`j2lr'`jgmm2s'"==""
	// h(.) is matrix used for first-step in xtabond2 estimation; relevant only for jgmm2s
	local hflag			="`h'`hvar'"~="" & "`nohmat'"==""
	// use SVD for KP unless user specifies nosvd
	local svdflag		="`nosvd'"=="" & `kpflag'
	local consflag		="`noconstant'"==""
	local evorderflag	="`noevorder'"==""
	// non-invariant tests do not reorder
	// nb: j2l and j2lr are invariant for fullrank (rr=1)
	if `jgmm2sflag' {
		local evorderflag	= 0
	}
	local stdflag		="`nostd'"==""
	local dotsflag		=("`nodots'"=="")
	if (`dotsflag'==0) & "`tracelevel'"=="" {
		local tracelevel "none"
	}	
	local allrankflag	="`allrank'"~=""
	local nullrankflag	="`nullrank'"~=""
	local fullrankflag	="`fullrank'"~=""
	local iterateflag	="`noiterate'"==""
	local combiterflag	="`nocombiter'"==""
	local collinflag	="`nocollin'"==""
	local centerflag	="`center'"~=""
	local smallflag		="`small'"~=""
	local LMflag		="`wald'"==""
	local LRflag		="`lr'"~=""
	// flag=1 if LIML as EV problem is ever required
	local limlflag		= `j2lflag' | `j2lrflag' | `svdflag' | "`binit'"=="liml"

	if "`nullrank'`fullrank'`allrank'" == "" {
		// default
		local allrankflag 1
	}

	// check options
	// only 1 stat allowed
	local statcount = `kpflag' + `jcueflag' + `j2lflag' + `j2lrflag' + `jgmm2sflag'
	if `statcount'>1 {
		di as err "ranktest error: incompatible options - `kp' `jcue' `j2l' `j2lr' `jgmm2s'"
		exit 198
	}
	// incompatible stats
	if `LRflag' & ~`LMflag' {
		di as err "ranktest error: incompatible options - wald and lr"
		exit 198
	}
	if "`binit'"~="" & "`binit'"~="liml" & "`binit'"~="2sls" {
		di as err "ranktest error: unrecognized option binit(`binit')"
		exit 198
	}
	if `limlflag' & `hflag' {
		di as err "ranktest error: H matrix option h(.) not supported when LIML obtained as an EV solution"
		exit 198
	}
	
	local optct : word count `allrank' `nullrank' `fullrank'
	if `optct' > 1 {
		di as err "ranktest error: incompatible options `allrank' `nullrank' `fullrank'"
		error 198
	}
	else if `optct' == 0 {
		// Default
		local allrank "allrank"
	}

	local optct : word count `psd0' `psda'
	if `optct' > 1 {
		di as err "ranktest error: incompatible options `psd0' `psda'"
		error 198
	}
	local psd	"`psd0' `psda'"
	local psd	: list retokenize psd

	*********************** end options section ************************
	
	marksample touse
	markout `touse' `y' `z' `partial' `cluster', strok
	
	// Note that y or z could be e.g. "y1-y3", so they need to be unab-ed.
	// fvunab ylist		: `y'
	fvexpand `y' if `touse'
	local ylist			`r(varlist)'
	// fvunab zlist		: `z'
	fvexpand `z' if `touse'
	local zlist			`r(varlist)'
	if "`ylist'"=="" | "`zlist'"=="" {
		di as err "ranktest error: missing varlist"
		exit 100
	}
	if "`partial'"~="" {
		// fvunab xlist	: `partial'
		fvexpand `partial' if `touse'
		local xlist			`r(varlist)'
	}
	
	// Create tempvars; "rv" for "revar".  Note that by revar-ing here,
	// subsequent disruption to the sort doesn't matter for TS operators.
	fvrevar					`ylist'
	local rvylist			`r(varlist)'
	fvrevar					`zlist'
	local rvzlist			`r(varlist)'
	fvrevar					`xlist'
	local rvxlist			`r(varlist)'

	// Having created fvrevar tempvars, now remove factor variable base vars from y and z lists.
	// Means they won't be reported as dropped collinear variables later.
	cap _fv_check_depvar `ylist'
	if _rc>0 {
		fvstrip `ylist' if `touse', dropomit
		local newylist	`r(varlist)'
		matchnames "`newylist'" "`ylist'" "`rvylist'"
		// now replace
		local rvylist	`r(names)'
		local ylist		`newylist'
	}
	cap _fv_check_depvar `zlist'
	if _rc>0 {
		fvstrip `zlist' if `touse', dropomit
		local newzlist	`r(varlist)'
		matchnames "`newzlist'" "`zlist'" "`rvzlist'"
		// now replace
		local rvzlist	`r(names)'
		local zlist		`newzlist'
	}

	// Stock-Watson and cluster imply robust.
	if "`sw'`cluster'" ~= "" {
		local robust "robust"
	}

	tempvar wvar
	if "`weight'" == "fweight" | "`weight'"=="aweight" {
		local wtexp `"[`weight'=`exp']"'
		gen double `wvar'=`exp'
	}
	if "`fsqrt(wf)*(wvar^0.5):*'" == "fweight" & "`kernel'" !="" {
		di in red "fweights not allowed (data are -tsset-)"
		exit 101
	}
	if "`weight'" == "fweight" & "`sw'" != "" {
		di in red "fweights currently not supported with -sw- option"
		exit 101
	}
	if "`weight'" == "iweight" {
		if "`robust'`cluster'`bw'" !="" {
			di in red "iweights not allowed with robust, cluster, AC or HAC"
			exit 101
		}
		else {
			local wtexp `"[`weight'=`exp']"'
			gen double `wvar'=`exp'
		}
	}
	if "`weight'" == "pweight" {
		local wtexp `"[aweight=`exp']"'
		gen double `wvar'=`exp'
		local robust "robust"
	}
	if "`weight'" == "" {
		// If no weights, define neutral weight variable
		qui gen byte `wvar'=1
	}

	// Every time a weight is used, must multiply by scalar wf ("weight factor")
	// wf=1 for no weights, fw and iw, wf = scalar that normalizes sum to be N if aw or pw
	sum `wvar' if `touse' `wtexp', meanonly
	// Weight statement
	if "`weight'" ~= "" {
		di in gr "(sum of wgt is " %14.4e `r(sum_w)' ")"
	}
	if "`weight'"=="" | "`weight'"=="fweight" | "`weight'"=="iweight" {
		// If weight is "", weight var must be column of ones and N is number of rows.
		// With fw and iw, effective number of observations is sum of weight variable.
		local wf=1
		local N=r(sum_w)
	}
	else if "`weight'"=="aweight" | "`weight'"=="pweight" {
		// With aw and pw, N is number of obs, unadjusted.
		local wf=r(N)/r(sum_w)
		local N=r(N)
	}
	else {
		// Should never reach here
		di as err "ranktest error: misspecified weights"
		exit 198
	}
****************************** last flag set here *******************************************************
	// ... since robust macro can be changed by weights
	local iidflag		= "`robust'`cluster'`kernel'`bw'"=="" & "`noiid'"==""
	
	// update other flags based on iidflag
	// unchanged: jgmm2sflag, LMflag, LRflag
	if `iidflag' {
		local svdflag		= 0
		local kpflag		= 0
		local jcueflag		= 0
		local j2lrflag		= 0
		local j2lflag		= 0
	}		
	
	if `LRflag' & ~`iidflag' {
		di as err "LR option not available for robust tests"
		exit 198
	}
****************************** last flag set here *******************************************************

* HAC estimation.
* If bw is omitted, default `bw' is empty string.
* If bw or kernel supplied, check/set `kernel'.
* Macro `kernel' is also used for indicating HAC in use.
	if "`bw'" == "" & "`kernel'" == "" {
		local bw=0
	}
	else {
* Need tvar for markout with time-series stuff
* Data must be tsset for time-series operators in code to work
* User-supplied tvar checked if consistent with tsset
		capture tsset
		if "`r(timevar)'" == "" {
di as err "must tsset data and specify timevar"
			exit 5
		}
		if "`tvar'" == "" {
			local tvar "`r(timevar)'"
		}
		else if "`tvar'"!="`r(timevar)'" {
di as err "invalid tvar() option - data already -tsset-"
			exit 5
		}
* If no panel data, ivar will still be empty
		if "`ivar'" == "" {
			local ivar "`r(panelvar)'"
		}
		else if "`ivar'"!="`r(panelvar)'" {
di as err "invalid ivar() option - data already -tsset-"
			exit 5
		}
		local tdelta `r(tdelta)'
		if "`ivar'"=="" {
			qui tsreport if `touse'
		}
		else {
			qui tsreport if `touse', panel
		}
		if `r(N_gaps)' != 0 {
di in gr "Warning: time variable " in ye "`tvar'" in gr " has " /*
	*/ in ye "`r(N_gaps)'" in gr " gap(s) in relevant range"
		}

* Check it's a valid kernel and replace with unabbreviated kernel name; check bw.
* Automatic kernel selection allowed by ivreg2 but not ranktest so must trap.
* s_vkernel is in livreg2 mlib.
		if "`bw'"=="auto" {
di as err "invalid bandwidth in option bw() - must be real > 0"
			exit 198
		}
		mata: s_vkernel("`kernel'", "`bw'", "`ivar'")
		local kernel `r(kernel)'
		local bw = `r(bw)'
	}

* tdelta missing if version 9 or if not tsset			
	if "`tdelta'"=="" {
		local tdelta=1
	}

	if "`sw'"~="" {
		capture xtset
		if "`ivar'" == "" {
			local ivar "`r(panelvar)'"
		}
		else if "`ivar'"!="`r(panelvar)'" {
di as err "invalid ivar() option - data already tsset or xtset"
			exit 5
		}
* Exit with error if ivar is neither supplied nor tsset nor xtset
		if "`ivar'"=="" {
di as err "Must -xtset- or -tsset- data or specify -ivar- with -sw- option"
			exit 198
		}
		qui describe, short varlist
		local sortlist "`r(sortlist)'"
		tokenize `sortlist'
		if "`ivar'"~="`1'" {
di as err "Error - dataset must be sorted on panel var with -sw- option"
			exit 198
		}
	}

* Create variable used for getting lags etc. in Mata
	tempvar tindex
	qui gen `tindex'=1 if `touse'
	qui replace `tindex'=sum(`tindex') if `touse'

********** CLUSTER SETUP **********************************************

* Mata code requires data are sorted on (1) the first var cluster if there
* is only one cluster var; (2) on the 3rd and then 1st if two-way clustering,
* unless (3) two-way clustering is combined with kernel option, in which case
* the data are tsset and sorted on panel id (first cluster variable) and time
* id (second cluster variable).
* Second cluster var is optional and requires an identifier numbered 1..N_clust2,
* unless combined with kernel option, in which case it's the time variable.
* Third cluster var is the intersection of 1 and 2, unless combined with kernel
* opt, in which case it's unnecessary.
* Sorting on "cluster3 cluster1" means that in Mata, panelsetup works for
* both, since cluster1 nests cluster3.
* Note that it is possible to cluster on time but not panel, in which case
* cluster1 is time, cluster2 is empty and data are sorted on panel-time.
* Note also that if data are sorted here but happen to be tsset, will need
* to be re-tsset after estimation code concludes.


// No cluster options or only 1-way clustering
// but for Mata and other purposes, set N_clust vars =0
	local N_clust=0
	local N_clust1=0
	local N_clust2=0
	if "`cluster'"!="" {
		local clopt "cluster(`cluster')"
		tokenize `cluster'
		local cluster1 "`1'"
		local cluster2 "`2'"
		if "`kernel'"~="" {
* kernel requires either that cluster1 is time var and cluster2 is empty
* or that cluster1 is panel var and cluster2 is time var.
* Either way, data must be tsset and sorted for panel data.
			if "`cluster2'"~="" {
* Allow backwards order
				if "`cluster1'"=="`tvar'" & "`cluster2'"=="`ivar'" {
					local cluster1 "`2'"
					local cluster2 "`1'"
				}
				if "`cluster1'"~="`ivar'" | "`cluster2'"~="`tvar'" {
di as err "Error: cluster kernel-robust requires clustering on tsset panel & time vars."
di as err "       tsset panel var=`ivar'; tsset time var=`tvar'; cluster vars=`cluster1',`cluster2'"
					exit 198
				}
			}
			else {
				if "`cluster1'"~="`tvar'" {
di as err "Error: cluster kernel-robust requires clustering on tsset time variable."
di as err "       tsset time var=`tvar'; cluster var=`cluster1'"
					exit 198
				}
			}
		}
* Simple way to get quick count of 1st cluster variable without disrupting sort
* clusterid1 is numbered 1.._Nclust1.
		tempvar clusterid1
		qui egen `clusterid1'=group(`cluster1') if `touse'
		sum `clusterid1' if `touse', meanonly
		if "`cluster2'"=="" {
			local N_clust=r(max)
			local N_clust1=`N_clust'
			if "`kernel'"=="" {
* Single level of clustering and no kernel-robust, so sort on single cluster var.
* kernel-robust already sorted via tsset.
				sort `cluster1'
			}
		}
		else {
			local N_clust1=r(max)
			if "`kernel'"=="" {
				tempvar clusterid2 clusterid3
* New cluster id vars are numbered 1..N_clust2 and 1..N_clust3
				qui egen `clusterid2'=group(`cluster2') if `touse'
				qui egen `clusterid3'=group(`cluster1' `cluster2') if `touse'
* Two levels of clustering and no kernel-robust, so sort on cluster3/nested in/cluster1
* kernel-robust already sorted via tsset.
				sort `clusterid3' `cluster1'
				sum `clusterid2' if `touse', meanonly
				local N_clust2=r(max)
			}
			else {
* Need to create this only to count the number of clusters
				tempvar clusterid2
				qui egen `clusterid2'=group(`cluster2') if `touse'
				sum `clusterid2' if `touse', meanonly
				local N_clust2=r(max)
* Now replace with original variable
				local clusterid2 `cluster2'
			}

			local N_clust=min(`N_clust1',`N_clust2')

		}		// end 2-way cluster block
	}		// end cluster block

****************************** TEST SUBROUTINE **********************************************************
* Note that bw is passed as a value, not as a string

	mata: s_jstat(						///
					"`ylist'",			///  original varnames
					"`zlist'",			///
					"`xlist'",			///
					"`rvylist'",		///  tempvars for FV or TS operators
					"`rvzlist'",		///  created using fvrevar
					"`rvxlist'",		///
					"`wvar'",			///
					"`weight'",			///
					`wf',				///
					`N',				///
					`consflag',			///
					"`touse'",			///
					`iidflag',			///
					`LMflag',			///
					`LRflag',			///
					`kpflag',			///
					`svdflag',			///
					`jcueflag',			///
					`jgmm2sflag',		///
					`j2lrflag',			///
					`j2lflag',			///
					`evorderflag',		///
					`stdflag',			///
					`dotsflag',			///
					"`tracelevel'",		///
					`jtol',				///
					`btol',				///
					"`binit'",			///
					`maxiter',			///
					`iterateflag',		///
					`combiterflag',		///
					`collinflag',		///
					`kc',				///
					"`allrank'",		///
					"`nullrank'",		///
					"`fullrank'",		///
					`rr',				///
					"`robust'",			///
					"`clusterid1'",		///
					"`clusterid2'",		///
					"`clusterid3'",		///
					`bw',				///
					"`tvar'",			///
					"`ivar'",			///
					"`tindex'",			///
					`tdelta',			///
					`centerflag',		///
					`smallflag',		///
					`dofminus',			///
					"`kernel'",			///
					"`sw'",				///
					"`psd'",			///
					`hflag',			///
					"`h'",				///
					"`hvar'"			///
					)

	tempname rkmatrix chi2 df df_r p rank ccorr eval b b0 K1 K2 K3 V S
	mat `rkmatrix'			= r(rkmatrix)
	mat `ccorr'				= r(ccorr)
	mat `eval'				= r(eval)
	mat colnames `rkmatrix' = "rk" "df" "p" "rank" "eval" "ccorr"
	local ynocollin			`r(ynocollin)'
	local znocollin			`r(znocollin)'
	local ycollin			`r(ycollin)'
	local zcollin			`r(zcollin)'
	mat `b'					= r(b)
	mat `b0'				= r(b0)
	mat `V'					= r(V)
	mat `S'					= r(S)
	local depvar			`r(depvar)'
	local endog				`r(endog)'
	local exexog			`r(exexog)'
	scalar `K3'				= r(K3)
	scalar `K2'				= r(K2)
	scalar `K1'				= r(K1)

*************************** REPORT RESULTS ****************************

	// report output
	di

	// messages saved for later posting in r(.) macros
	
	// LM (default) or Wald
	if `LRflag' {
		local testtype "LR"
	}
	else if `LMflag' {
		local testtype "LM"
	}
	else {
		local testtype "Wald"
	}
	
	// iid cases
	if `iidflag' {
		if `jgmm2sflag' {
			local testdesc "2SLS-based (`testtype' version)"
			di as text _c "`testdesc'"
		}
		else if `LRflag' {
			local testdesc "Anderson canonical correlations LR"
			di in smcl _c "{help ranktest##CCiid:`testdesc'}"
		}
		else if `LMflag' {
			local testdesc "Anderson canonical correlations LM"
			di in smcl _c "{help ranktest##CCiid:`testdesc'}"
		}
		else {
			local testdesc "Cragg-Donald Wald"
			di in smcl _c "{help ranktest##CDiid:`testdesc'}"
		}
	}
	// non-iid cases
	else {
		if `kpflag' {
			local testdesc "Kleibergen-Paap robust LIML-based (`testtype' version)"
			di in smcl _c "{help ranktest##KProbust:`testdesc'}"
		}
		else if `jcueflag' {
			local testdesc "Cragg-Donald robust CUE-based (`testtype' version)"
			di in smcl _c "{help ranktest##CDrobust:`testdesc'}"
		}
		else if `j2lrflag' {
			local testdesc "Windmeijer robust J2LR LIML-based (`testtype' version)"
			di in smcl _c "{help ranktest##CDrobust:`testdesc'}"
		}
		else if `j2lflag' {
			local testdesc "Windmeijer robust J2L LIML-based (`testtype' version)"
			di in smcl _c "{help ranktest##CDrobust:`testdesc'}"
		}
		else if `jgmm2sflag' {
			local testdesc "2-step-GMM-based (`testtype' version)"
			di in smcl _c "{help ranktest##CDrobust:`testdesc'}"
		}
		else {
			local testdesc "(internal ranktest error - test name not indicated)"
		}
	}
	// complete the sentence
	di as text " test of rank of matrix"

	if "`robust'"~="" & "`kernel'"~= "" & "`cluster'"=="" {
		local vcedesc1 "  Test statistic robust to heteroskedasticity and autocorrelation"
		local vcedesc2 "  Kernel: `kernel'   Bandwidth: `bw'"
	}
	else if "`kernel'"~="" & "`cluster'"=="" {
		local vcedesc1 "  Test statistic robust to autocorrelation"
		local vcedesc2 "  Kernel: `kernel'   Bandwidth: `bw'"
	}
	else if "`cluster'"~="" {
		local vcedesc1 "  Test statistic robust to heteroskedasticity and clustering on `cluster'"
		if "`kernel'"~="" {
			local vcedesc2 "  and kernel-robust to common correlated disturbances"
			local vcedesc3 "  Kernel: `kernel'   Bandwidth: `bw'"
		}
	}
	else if "`robust'"~="" {
		local vcedesc1 "  Test statistic robust to heteroskedasticity"
	}
	else {
		local vcedesc1 "  Test consistent for homoskedasticity only"
	}

	di as text "`vcedesc1'"
	if "`vcedesc2'"~="" {
		di as text "`vcedesc2'"
	}
	if "`vcedesc3'"~="" {
		di as text "`vcedesc3'"
	}

	local numtests = rowsof(`rkmatrix')
	forvalues i=1(1)`numtests' {
		di as text "Test of rank=" as res %3.0f `rkmatrix'[`i',4] as text "  rk=" as res %8.2f `rkmatrix'[`i',1] /*
			*/	as text "  Chi-sq(" as res %3.0f `rkmatrix'[`i',2] as text ") p-value=" as res %6.4f `rkmatrix'[`i',3]
	}
	scalar `chi2'		= `rkmatrix'[`numtests',1]
	scalar `p'			= `rkmatrix'[`numtests',3]
	scalar `df'			= `rkmatrix'[`numtests',2]
	scalar `rank'		= `rkmatrix'[`numtests',4]
	local N				`r(N)'
	return scalar cons	= `consflag'
	return scalar df	= `df'
	return scalar chi2	= `chi2'
	return scalar p		= `p'
	return scalar rank	= `rank'
	return scalar K3	= `K3'
	return scalar K1	= `K1'
	return scalar K2	= `K2'
	if "`cluster'"~="" {
		return scalar N_clust = `N_clust'
	}
	if "`cluster2'"~="" {
		return scalar N_clust1 = `N_clust1'
		return scalar N_clust2 = `N_clust2'
	}
	return scalar N			= `N'
	return matrix rkmatrix	`rkmatrix'
	return matrix ccorr		`ccorr'
	return matrix eval		`eval'
	if `rr' {
		return scalar rr	= `rr'
	}
	
	tempname Omega
	if `K1' > 1 {
		// use ynocollin and znocollin (instead of y and z), in case any collinearities dropped
		foreach en of local ynocollin {
			// Remove "." from equation name
			local en1 : subinstr local en "." "_", all
			foreach vn of local znocollin {
				local cn "`cn' `en1':`vn'"
			}
		}
	}
	else {
		foreach vn of local znocollin {
		local cn "`cn' `vn'"
		}
	}

	if `b'[1,1] ~= . {
		return matrix b0		`b0'
		return matrix b			`b'
		return matrix V			`V'
		return matrix S			`S'
		return local depvar		`depvar'
		return local endog		`endog'
		return local exexog		`exexog'
	}
	else if `kpflag' | `iidflag' {
		return matrix V			`V'
		return matrix S			`S'
	}
	else {
		return matrix S			`S'
	}
	return local collin		`ycollin' `zcollin'
	return local partial	`xlist'
	// return local varlist3	`xlist'
	return local varlist2	`zlist'
	return local varlist1	`ylist'

	return local vcedesc3		`vcedesc3'
	return local vcedesc2		`vcedesc2'
	return local vcedesc1		`vcedesc1'
	return local testdesc		`testdesc'

	local method 	`kp' `jcue' `j2l' `j2lr' `jgmm2s'
	local method	: list clean method
	
	return local small			`small'
	return local testtype		`testtype'
	return local method			`method'
	return local ranktestcmd	ranktest
	return local cmd			ranktest
	return local version		`lversion'
end


// internal version of fvstrip 1.01 ms 24march2015
// takes varlist with possible FVs and strips out b/n/o notation
// returns results in r(varnames)
// optionally also omits omittable FVs
// expand calls fvexpand either on full varlist
// or (with onebyone option) on elements of varlist
program define fvstrip, rclass
	version 11.2
	syntax [anything] [if] , [ dropomit expand onebyone NOIsily ]
	if "`expand'"~="" {												//  force call to fvexpand
		if "`onebyone'"=="" {
			fvexpand `anything' `if'								//  single call to fvexpand
			local anything `r(varlist)'
		}
		else {
			foreach vn of local anything {
				fvexpand `vn' `if'									//  call fvexpand on items one-by-one
				local newlist	`newlist' `r(varlist)'
			}
			local anything	: list clean newlist
		}
	}
	foreach vn of local anything {									//  loop through varnames
		if "`dropomit'"~="" {										//  check & include only if
			_ms_parse_parts `vn'									//  not omitted (b. or o.)
			if ~`r(omit)' {
				local unstripped	`unstripped' `vn'				//  add to list only if not omitted
			}
		}
		else {														//  add varname to list even if
			local unstripped		`unstripped' `vn'				//  could be omitted (b. or o.)
		}
	}
// Now create list with b/n/o stripped out
	foreach vn of local unstripped {
		local svn ""											//  initialize
		_ms_parse_parts `vn'
		if "`r(type)'"=="variable" & "`r(op)'"=="" {			//  simplest case - no change
			local svn	`vn'
		}
		else if "`r(type)'"=="variable" & "`r(op)'"=="o" {		//  next simplest case - o.varname => varname
			local svn	`r(name)'
		}
		else if "`r(type)'"=="variable" {						//  has other operators so strip o but leave .
			local op	`r(op)'
			local op	: subinstr local op "o" "", all
			local svn	`op'.`r(name)'
		}
		else if "`r(type)'"=="factor" {							//  simple factor variable
			local op	`r(op)'
			local op	: subinstr local op "b" "", all
			local op	: subinstr local op "n" "", all
			local op	: subinstr local op "o" "", all
			local svn	`op'.`r(name)'							//  operator + . + varname
		}
		else if"`r(type)'"=="interaction" {						//  multiple variables
			forvalues i=1/`r(k_names)' {
				local op	`r(op`i')'
				local op	: subinstr local op "b" "", all
				local op	: subinstr local op "n" "", all
				local op	: subinstr local op "o" "", all
				local opv	`op'.`r(name`i')'					//  operator + . + varname
				if `i'==1 {
					local svn	`opv'
				}
				else {
					local svn	`svn'#`opv'
				}
			}
		}
		else if "`r(type)'"=="product" {
			di as err "fvstrip error - type=product for `vn'"
			exit 198
		}
		else if "`r(type)'"=="error" {
			di as err "fvstrip error - type=error for `vn'"
			exit 198
		}
		else {
			di as err "fvstrip error - unknown type for `vn'"
			exit 198
		}
		local stripped `stripped' `svn'
	}
	local stripped	: list retokenize stripped						//  clean any extra spaces
	
	if "`noisily'"~="" {											//  for debugging etc.
di as result "`stripped'"
	}

	return local varlist	`stripped'								//  return results in r(varlist)
end


// Internal version of matchnames
// Sample syntax:
// matchnames "`varlist'" "`list1'" "`list2'"
// takes list in `varlist', looks up in `list1', returns entries in `list2', called r(names)
program define matchnames, rclass
	version 11.2
	args	varnames namelist1 namelist2

	local k1 : word count `namelist1'
	local k2 : word count `namelist2'

	if `k1' ~= `k2' {
		di as err "namelist error"
		exit 198
	}
	foreach vn in `varnames' {
		local i : list posof `"`vn'"' in namelist1
		if `i' > 0 {
			local newname : word `i' of `namelist2'
		}
		else {
* Keep old name if not found in list
			local newname "`vn'"
		}
		local names "`names' `newname'"
	}
	local names	: list clean names
	return local names "`names'"
end

* Adopted from -canon-
program define GetVarlist, sclass 
	version 11.2
	sret clear
	gettoken open 0 : 0, parse("(") 
	if `"`open'"' != "(" {
		error 198
	}
	gettoken next 0 : 0, parse(")")
	while `"`next'"' != ")" {
		if `"`next'"'=="" { 
			error 198
		}
		local list `list'`next'
		gettoken next 0 : 0, parse(")")
	}
	sret local rest `"`0'"'
	tokenize `list'
	local 0 `*'
	sret local varlist "`0'"
end

********************* EXIT IF STATA VERSION < 13 ********************************

* When do file is loaded, exit here if Stata version calling program is < 12.
* Prevents loading of rest of program file (would cause e.g. Stata 10 to crash at Mata).

if c(stata_version) < 13 {
	exit
}

******************** END EXIT IF STATA VERSION < 13 *****************************

*******************************************************************************
*************************** BEGIN MATA CODE ***********************************
*******************************************************************************

version 13.1
mata:

// ********* MATA CODE SHARED BY ivreg2 AND ranktest       *************** //
// ********* 1. struct ms_vcvorthog                        *************** //
// ********* 2. m_omega                                    *************** //
// ********* 3. m_calckw                                   *************** //
// ********* 4. s_vkernel                                  *************** //
// *********************************************************************** //

// For reference:
// struct ms_vcvorthog {
// 	string scalar	ename, Znames, touse, weight, wvarname
// 	string scalar	robust, clustvarname, clustvarname2, clustvarname3, kernel
// 	string scalar	sw, psd, ivarname, tvarname, tindexname
// 	real scalar		wf, N, bw, tdelta, dofminus
//  real scalar		center
// 	real matrix		ZZ
// 	pointer matrix	e
// 	pointer matrix	Z
// 	pointer matrix	wvar
// }

struct ms_jresult {
	real scalar		j
	real matrix		beta
	real matrix		beta0
	real scalar		pvalue
	real scalar		df
	real matrix		V
	real matrix		S
}

struct ms_jargs {
	pointer matrix pvy1
	pointer matrix pvy2
	pointer matrix py1
	pointer matrix py2
	pointer matrix pz
	pointer matrix pz_kron
	real scalar K1
	real scalar K2
	real scalar ii
	real scalar kk
	real matrix Qzz
	real matrix Qzz_kron
	real matrix Qzy1
	real matrix Qzy2
	real scalar N
	real scalar Nminus
	real scalar hflag
	real matrix Hmat
	real matrix hvar
	real matrix info
	real matrix sigma2
	real scalar btol
	real scalar jtol
	real scalar maxiter
	string scalar tracelevel
	real scalar dotsflag
}

void s_jstat(
				string scalar ylist,		// tokens with original varnames
				string scalar zlist,		// can include TS or FV operators
				string scalar xlist,		// X = to be partialled-out
				string scalar rvylist,		// TS or FV vars replaced with temps
				string scalar rvzlist,		// using fvrevar
				string scalar rvxlist,
				string scalar wvarname,
				string scalar weight,
				scalar wf,
				scalar N,
				scalar cons,
				string scalar touse,
				scalar iidflag,
				scalar LMflag,
				scalar LRflag,
				scalar kpflag,
				scalar svdflag,
				scalar jcueflag,
				scalar jgmm2sflag,
				scalar j2lrflag,
				scalar j2lflag,
				scalar evorderflag,
				scalar stdflag,
				scalar dotsflag,
				string scalar tracelevel,
				scalar jtol,
				scalar btol,
				string scalar binit,
				scalar maxiter,
				scalar iterateflag,
				scalar combiterflag,
				scalar collinflag,
				scalar kc,
				string scalar allrank,
				string scalar nullrank,
				string scalar fullrank,
				scalar rr,
				string scalar robust,
				string scalar clustvarname,
				string scalar clustvarname2,
				string scalar clustvarname3,
				bw,
				string scalar tvarname,
				string scalar ivarname,
				string scalar tindexname,
				tdelta,
				scalar centerflag,
				scalar smallflag,
				dofminus,
				string scalar kernel,
				string scalar sw,
				string scalar psd,
				scalar hflag,
				string scalar hname,
				string scalar hvarname
				)
{

	// tokens with original variable names
	ytokens=tokens(ylist)
	ztokens=tokens(zlist)
	xtokens=tokens(xlist)

	// tokens with names of variables to use
	// TS or FV variables replaced with temps using fvrevar
	rvytokens=tokens(rvylist)
	rvztokens=tokens(rvzlist)
	rvxtokens=tokens(rvxlist)

	// create views on original data for Y, Z and X, as well as touse and weight var
	st_view(ynopartial=.,.,rvytokens,touse)
	st_view(znopartial=.,.,rvztokens,touse)
	if (partial~="") {
		st_view(x=.,.,rvxtokens,touse)
	}
	st_view(mtouse=.,.,tokens(touse),touse)
	st_view(wvar=.,.,tokens(wvarname),touse)
	noweight=(st_vartype(wvarname)=="byte")

	// Partial out the X variables.
	// Result is y and z after transformation.
	// y and z are data matrices created in Mata, not views on Stata data.
	// Note that this includes demeaning if there is a constant,
	//   i.e., variables are centered.
	// Note that we use wf*wvar instead of wvar
	// because wvar is raw weighting variable and
	// wf*wvar normalizes so that sum(wf*wvar)=N.
	P	= cols(x)						//  count of vars to be partialled out (excluding constant)
	if (cons & P>0) {					//  Vars to partial out including constant
		ymeans = mean(ynopartial,wf*wvar)
		zmeans = mean(znopartial,wf*wvar)
		xmeans = mean(x,wf*wvar)
		Qxy	= quadcrossdev(x, xmeans, wf*wvar, ynopartial, ymeans)*1/N
		Qxz = quadcrossdev(x, xmeans, wf*wvar, znopartial, zmeans)*1/N
		Qxx = quadcrossdev(x, xmeans, wf*wvar, x, xmeans)*1/N
	}
	else if (!cons & P>0) {				//  Vars to partial out NOT including constant
		Qxy = quadcross(x, wf*wvar, ynopartial)*1/N
		Qxz = quadcross(x, wf*wvar, znopartial)*1/N
		Qxx = quadcross(x, wf*wvar, x)*1/N
	}
	else {								//  Only constant to partial out = demean
		ymeans = mean(ynopartial,wf*wvar)
		zmeans = mean(znopartial,wf*wvar)
	}
	//	Partial-out coeffs. Default Cholesky; use QR if not full rank and collinearities present.
	//	Not necessary if no vars other than constant.
	rankxx = 0
	if (P>0) {
		by	= cholqrsolve(Qxx, Qxy, rankxx)	// also updates rankxx with rank of (demeaned) X'X
		bz	= cholqrsolve(Qxx, Qxz)
	}
	//	Replace with residuals
	if (cons & P>0) {					//  Vars to partial out including constant
		y	= (ynopartial :- ymeans) - (x :- xmeans)*by
		z	= (znopartial :- zmeans) - (x :- xmeans)*bz
	}
	else if (!cons & P>0) {				//  Vars to partial out NOT including constant
		y	= ynopartial - x*by
		z	= znopartial - x*bz
	}
	else if (cons) {					//  Only constant to partial out = demean
		y	= (ynopartial :- ymeans)
		z	= (znopartial :- zmeans)
	}
	else {								//  no transformations required
		y	= ynopartial
		z	= znopartial
	}

	// standardize here
	// nb - variance formula uses N-1
	if (stdflag) {
		sy = sqrt(diagonal(quadvariance(y)))
		sy = sy+(sy:==0)
		sz = sqrt(diagonal(quadvariance(z)))
		sz = sz+(sz:==0)
		
		y	= y :/ (sy')
		z	= z :/ (sz')
	}

	yy		= quadcross(y, wf*wvar, y)	// may need this for vcvo
	Qyy		= yy * 1/N
	iQyy	= invsym(Qyy)

	// check for collinearities and adjust if necessary
	if (diag0cnt(iQyy) & collinflag) {
		yvarkeep	= selectindex(diagonal(iQyy)')
		yvardrop 	= selectindex(diagonal(iQyy)':==0)
		ykeeptokens	= ytokens[yvarkeep]
		ydroptokens	= ytokens[yvardrop]
		printf("collinearities detected - dropping %s\n",invtokens(ydroptokens))
		y			= y[.,yvarkeep]
		Qyy			= Qyy[yvarkeep',yvarkeep]
		iQyy		= iQyy[yvarkeep',yvarkeep]
		if (stdflag) {
			sy		= sy[yvarkeep']
		}
	}
	else {
		ykeeptokens	= ytokens
	}
	zz		= quadcross(z, wf*wvar, z)	// need this for vcvo
	Qzz		= zz * 1/N
	iQzz	= invsym(Qzz)
	// check for collinearities and adjust if necessary
	if (diag0cnt(iQzz) & collinflag) {
		zvarkeep	= selectindex(diagonal(iQzz)')
		zvardrop 	= selectindex(diagonal(iQzz)':==0)
		zkeeptokens	= ztokens[zvarkeep]
		zdroptokens	= ztokens[zvardrop]
		printf("collinearities detected - dropping %s\n",invtokens(zdroptokens))
		z			= z[.,zvarkeep]
		zz			= zz[zvarkeep',zvarkeep]
		Qzz			= Qzz[zvarkeep',zvarkeep]
		iQzz		= iQzz[zvarkeep',zvarkeep]
		if (stdflag) {
			sz		= sz[zvarkeep']
		}
	}
	else {
		zkeeptokens	= ztokens
	}
	
	// Check for collinearities within [Y Z].
	// Allowed if e.g. Y includes exogenous vars and therefore they appear in Z as well.
	// Minimum rank is #zeros in the inverse of the combined cross-product matrix.
	// If no collinearities, minrank = 0.
	if (collinflag) {
		yzzy			= quadcross((y,z), wf*wvar, (y,z))
		Qyzzy			= yzzy * 1/N
		iQyzzy			= invsym(Qyzzy)
		minrank			= diag0cnt(iQyzzy)
		if (minrank>0) {
			yzvarcollin		= selectindex(diagonal(iQyzzy)':==0)
			yzexogtokens	= (ykeeptokens, zkeeptokens)[yzvarcollin]
			printf("{txt}collinearities detected between varlists, including: %s\n",invtokens(yzexogtokens))
			printf("{txt}implies minimum matrix rank = %f\n",minrank)
		}
	}
	else {
		minrank		= 0
	}

	// minrank > 0 supported for iid, jcue, jgmm2s, and kp+svd
	//             not supported for non-iid case with j2l, j2lr and kp+nosvd
	if ((minrank>0) & !(iidflag)) {
		if (							///
			(j2lflag)	|				///
			(j2lrflag)	|				///
			((kpflag) & !(svdflag))		///
			) {
				printf("{err}exogenous variables in matrix not supported with options j2l, j2lr and kp+nosvd\n")
				exit(198)
			}
	}
	
	// Now that collinearities are removed, check if cols(Y)>cols(Z) and switch if yes.
	// switchflag = 1 if z and y are switched, =0 otherwise
	if (cols(z) >= cols(y)) {
		// standard case
		switchflag=0
		py=&y
		pz=&z
	}
	else {
		// switch y and z
		switchflag=1
		py=&z
		pz=&y
		// memory reqs small so no need to use pointers
		y_zz			= zz
		y_Qzz			= Qzz
		y_iQzz			= iQzz
		y_sz			= sz
		y_zkeeptokens	= zkeeptokens
		y_zdroptokens	= zdroptokens
		zz				= yy
		Qzz				= Qyy
		iQzz			= iQyy
		sz				= sy
		zkeeptokens		= ykeeptokens
		zdroptokens		= ydroptokens
		yy				= y_zz
		Qyy				= y_Qzz
		iQyy			= y_iQzz
		sy				= y_sz
		ykeeptokens		= y_zkeeptokens
		ydroptokens		= y_zdroptokens
	}
	K1=cols(*py)				//  count of vars in first varlist
	K2=cols(*pz)				//  count of vars in second varlist
	
	maxrank=min((K1,K2))		//  max possible rank (should be K1)
	if (maxrank!=K1) {
		printf("{err}internal ranktest error: maxrank does not match K1\n")
		exit(3000)
	}
	if (minrank==maxrank) {
		printf("{err}internal ranktest error: minrank=maxrank; may be caused by collinearities\n")
		exit(3000)
	}
	K3=rankxx+cons				//  number of partialled-out vars including constant

	//  Now that Z and Y are decided...
	Qzy		= quadcross(*pz, wf*wvar, *py) * 1/N
	// Initialize ehat column vector for later use; don't use N since that may be fweighted.
	ehat = J(rows(y),K1,0)

	// special treatment for xtabond2-type first-step H matrix
	// first check if special treatment is necessary - if H is identity matrix, can ignore
	if (hflag) {
		Hmat = st_matrix(hname)
		if (Hmat==I(rows(Hmat))) {
			// reset hflag since special treatment no longer needed
			hflag=0
		}
	}

	if (hflag) {
		// ivar is panel identifier
		// hvar has row/col index for Hmat matrix
		// note that data should be sorted on ivar but need not be sorted on tvar
		st_view(ivar=.,.,ivarname,touse)
		st_view(hvar=.,.,hvarname,touse)
		info = panelsetup(ivar, 1)
		zHz		= makesymmetric(hcross(*pz,*pz,Hmat,hvar,wvar,info))
		QzHz	= zHz * 1/N
		iQzHz	= invsym(QzHz)
		// "G" is inverse of H
		// not in use until SVD/LIML/KP support is added for hmat option
		// yGy		= makesymmetric(hcross(*py,*py,Hmat,hvar,wvar,info,"invert"))
		// QyGy	= yGy * 1/N
		// iQyGy	= invsym(QyGy)
	}

	// Needed for KP or for reporting canonical corr
	if ((kpflag) | (iidflag)) {
		rQyy		= cholesky(Qyy)
		rQzz		= cholesky(Qzz)
		irQyy		= luinv(rQyy')
		irQzz		= luinv(rQzz')
	}
	// not in use until SVD/LIML/KP support is added for hmat option
	// else if ((svdflag) & (hflag)) {
	//	zHz			= makesymmetric(hcross(*pz,*pz,Hmat,hvar,wvar,info))
	//	yGy			= makesymmetric(hcross(*py,*py,Hmat,hvar,wvar,info,"invert"))
	//	rQyy		= cholesky(yGy*1/N)
	//	rQzz		= cholesky(zHz*1/N)
	//	irQyy		= luinv(rQyy')
	//	irQzz		= luinv(rQzz')
	//}

	// eigenvalues and reordering
	// If iid and canonical correlations, no reordering needed. Use m_evorder to get eigenvalues.
	// If iid and jgmm2s, no reordering needed. Use m_evorder to get eigenvalues.
	// If SVD (KP, robust), no reordering. Use SVD to get eigenvalues.
	// In all other cases, reorder. Use m_evorder.
	if (iidflag & !jgmm2sflag) {
		// override evorder setting
		evorderflag	= 0
	}
	if (svdflag) {
		// override evorder setting
		evorderflag	= 0
	}
	
	if (svdflag==0) {
		// KP using SVD handled separately
		// note that currently hflag=1 implies svdflag=0 and KP enters here
		// need phil to get liml coefs
		// also need canonical correlations and/or for ordering by eigenvalue
		// m_evorder uses symeigensystem(.) and places values in args
		// ind has the ordering
		eval		= .
		ccorr		= .
		ind			= .
		phil		= .
		if (hflag) {
			m_evorder(Qyy,iQyy,QzHz,iQzHz,Qzy,eval,ccorr,ind,phil)
		}
		else {
			m_evorder(Qyy,iQyy,Qzz,iQzz,Qzy,eval,ccorr,ind,phil)
		}

		// order all objects with y by eigenvalue
		if (evorderflag) {
			(*py)[.,.]	= (*py)[.,ind]
			Qzy[.,.]	= Qzy[.,ind]
			Qyy[.,.]	= Qyy[ind,ind]
			iQyy[.,.]	= iQyy[ind,ind]
			phil		= phil[ind,.]
			if (stdflag) {
				sy		= sy[ind,1]
			}
		}
	}
	else {
		// default ind = (1, 2, 3) so selection does nothing
		ind				= runningsum(J(rows(Qyy),1,1))'
	}

	// initialize struct used for getting vcv of moment conditions
	// only thing that changes in each use is vcvo.e, the NxK matrix for resids
	struct ms_vcvorthog scalar vcvo
	vcvo.touse			= touse
	vcvo.center			= centerflag
	vcvo.weight			= weight
	vcvo.wvarname		= wvarname
	vcvo.robust			= robust
	vcvo.clustvarname	= clustvarname
	vcvo.clustvarname2	= clustvarname2
	vcvo.clustvarname3	= clustvarname3
	vcvo.kernel			= kernel
	vcvo.sw				= sw
	vcvo.psd			= psd
	vcvo.ivarname		= ivarname
	vcvo.tvarname		= tvarname
	vcvo.tindexname		= tindexname
	vcvo.wf				= wf
	vcvo.N				= N
	vcvo.bw				= bw
	vcvo.tdelta			= tdelta
	vcvo.dofminus		= dofminus
	vcvo.ZZ				= zz	
	vcvo.Z				= pz				// pz is pointer to z
	vcvo.wvar			= &wvar

	// what if pihat is rank-deficient?
	// below uses QR if Cholesky fails
	pihat		= cholqrsolve(Qzz, Qzy)
    if (LMflag) {
    	vhat	= *py
    }
    else {
		vhat	= *py-(*pz)*pihat
    }
	vecpi		= vec(pihat)
	zz_kron		= I(K1) # zz
	Qzz_kron	= I(K1) # Qzz
	
	// small-sample correction in final calculation of statistic
	if ((!smallflag) | (LRflag)) {
		// never any small-sample correction for LR
		Nminus = N
	}
	else if ((smallflag) & (LMflag)) {
		// LM subtracts number of exogenous regressors
		Nminus	= N - K3
	}
	else if ((smallflag) & (!LMflag)) {
		// Wald subtracts number of instruments including exogenous regressors
		Nminus = N - K3 - max((K2,K1))
	}
	else {
		printf("{err}internal ranktest error in small-sample adjustment\n")
		exit(3000)
	}

	// obtain VCV y matrix as "residuals"
	vcvo.e		= &vhat
	shat0		= m_omega(vcvo)		// called ome0 in FW code; FW does not normalise by N.
	ishat0		= invsym(shat0)

	// needed only for cue and j2lr
	if ((jcueflag) | (j2lrflag)) {
		ivarpi0		= makesymmetric(Qzz_kron*ishat0*Qzz_kron)
		if (diag0cnt(ishat0) & (jcueflag) & (iterateflag)) {
			// not full rank, add kc*I; default kc=1e-08
			printf("{txt}\nwarning - var(pihat) singular; adjusting by %-7.1e*I(K2)\n",kc)
			ishat0kc	= cholinv(shat0+kc*I(cols(shat0)))
			// use adjusted shat0 to get ivarpi0
			ivarpi0kc	= makesymmetric(Qzz_kron*ishat0kc*Qzz_kron)
		}
		else {
			// no adjustment to shat0 needed
			// note that by using z'z/N, ivarpi0 doesn't explode as N gets big
			ivarpi0kc	= ivarpi0
		}
	}

	// needed only for KP statistic using SVD
	// eigenvalues and canonical correlations also obtained here
	if (svdflag) {
		kpthat		= rQzz' * pihat * irQyy
		// note that fullsvd inserts vt = v' into the 4th argument
		fullsvd(kpthat, kpu, kpcc, kpvt)
		ccorr		= kpcc'
		eval		= ccorr:^2
	}
	
	if ((kpflag) | (iidflag)) {
		// KP variance
		kpvar		= (irQyy'#irQzz')*shat0*(irQyy'#irQzz')'
		_makesymmetric(kpvar)
		if ((LMflag==0) & (iidflag)) {
			// Homoskedastic iid Wald case means vcv has block-diag identity matrix structure.
			// Enforce this by setting ~0 entries to 0.
			kpvar	= kpvar :* (J(K1,K1,1)#I(K2))
		}
		else if (iidflag) {
			// Homoskedastic iid LM case means vcv is identity matrix.
			kpvar	= I(rows(kpvar))
		}
	}

	// for collecting test stats
	if (rr>0) {
		firstrank=maxrank-rr
		lastrank=maxrank-rr
		// check that rr is legal; must be >=1 and <= min(K1,K2). minrank is > 0 if Y and Z share (exogenous) variables
		if ( (rr<1) | (rr>maxrank) ) {
			printf("{err}error: rank reduction rr(.) option must lie in range 1 <= rr <= min(K1,K2)\n")
			exit(198)
		}
		if (minrank>firstrank) {
			printf("{err}error: rank reduction rr(.) option inconsistent with specified included exogenous variables\n")
			exit(198)
		}
	}
	else if (allrank~="") {
		firstrank=minrank
		lastrank=maxrank-1
	}
	else if (nullrank~="") {
		firstrank=minrank
		lastrank=0
	}
	else if (fullrank~="") {
		firstrank=maxrank-1
		lastrank=maxrank-1
	}
	else {
		// should never reach this point
		printf("ranktest error\n")
		exit
	}
	// set rr if rr not supplied (so rr=0) and if a single rank reduction test is in effect requested
	if (rr==0) {
		if (firstrank==lastrank) {
			rr = maxrank-firstrank
		}
	}
	// where results will go; rkrow tracks the row
	rkmatrix=J(lastrank-firstrank+1,6,.)
	rkrow = 1
	struct ms_jresult scalar r
	// save beta if (1) using J and not SVD or canonical correlations;
	//              (2) only one rank reduction being tested;
	//              (3) beta is calculated in the non-iid code
	betaflag = 0
	if ((jcueflag==1) | (jgmm2sflag==1) | ((kpflag) & !(svdflag))) {
		if ((firstrank==lastrank) & (firstrank>0)) {
			betaflag = 1
		}
	}

	//************ BEGIN TESTS *****************//

	if (iidflag & !jgmm2sflag) {
		// block for iid case and canonical-correlations-based tests
		// requires only eigenvalues to get LM, Wald and LR versions
		// works for Anderson LM and LR, CD Wald, LIML-based but not IV-based tests

		// transformed eigenvalues
		evalt = eval :/ (1 :- eval)
		// test is based on sum of minimum EVs or sum of log(1-EV)
		// so create a single complete vector of running sums and from that a vector of test stats
		// note that dofminus also needs to be used (since m_omega and shat are not used)
		if (LRflag) {
			// LR uses original EVs
			lrsum = -runningsum(ln(1:-sort(eval',1)'))
			jrow = (Nminus-dofminus)*lrsum
		}
		else if (LMflag) {
			// LM uses original EVs
			jrow = (Nminus-dofminus)*runningsum(sort(eval',1)')
		}
		else {
			// Wald uses transformed EVs
			jrow = (Nminus-dofminus)*runningsum(sort(evalt',1)')
		}
		jrow = sort(jrow',-1)'

		for (ii=firstrank+1; ii<=lastrank+1; ii++) {

			rrank					= diag0cnt(iQzz)*(K1-ii+1)
			if (rrank) {
				printf("{txt}warning - rank reduction=%f in test of rank=%f; adjusting df of test\n",rrank,ii-1)
			}

			j					= jrow[ii]
			df					= (K2-ii+1)*(K1-ii+1)
			pvalue				= chi2tail(df,j)
			rkmatrix[rkrow,1]	= j
			rkmatrix[rkrow,2]	= df
			rkmatrix[rkrow,3]	= pvalue
			rkmatrix[rkrow,4]	= ii-1
			rkmatrix[rkrow,5]	= eval[ii]
			rkmatrix[rkrow,6]	= ccorr[ii]
			rkrow++
		}
	}

	else {
		// block for robust and jgmm2s-based tests

		// initialize struct with arguments for j subroutines		
		struct ms_jargs scalar jargs
		jargs.K1			= K1
		jargs.K2			= K2
		jargs.Qzz			= Qzz
		jargs.pz			= pz
		jargs.N				= N
		jargs.Nminus		= Nminus
		jargs.btol			= btol
		jargs.jtol			= jtol
		jargs.tracelevel	= tracelevel
		jargs.maxiter		= maxiter
		jargs.dotsflag		= dotsflag
		jargs.hflag			= hflag
		if (hflag) {
			jargs.Hmat		= Hmat
			jargs.hvar		= hvar
			jargs.info		= info
		}
		
		// test H0:rank=0; works for all stats
		if (firstrank==0) {
			
			// get J
			eit					= vec(Y=*py)
			z_kron				= I(K1) # (*pz)
			// need to stack weights
			// need W=wvar to avoid "view found where array required" error
			gbar				= quadcross(z_kron, wf*(J(K1,1,1) # (W=wvar)), eit) * 1/N
			j					= gbar' * ishat0 * gbar * Nminus
	
			rrank				= diag0cnt(ishat0)
			if (rrank) {
				printf("{txt}\nwarning - avar rank reduction=%f in test of rank=0; adjusting df of test\n",rrank)
			}
			
			// store results in row 1 of rkmatrix
			df					= K2*K1 - rrank
			pvalue				= chi2tail(df,j)
			rkmatrix[rkrow,1]	= j
			rkmatrix[rkrow,2]	= df
			rkmatrix[rkrow,3]	= pvalue
			rkmatrix[rkrow,4]	= 0			// H0:rank=0
			rkmatrix[rkrow,5]	= eval[rkrow]
			rkmatrix[rkrow,6]	= ccorr[rkrow]
			rkrow++							// increment row counter for next time through the loop
	
			firstrank=1						// increment firstrank so loops below starts in the right place
	
		}

		// test ranks in reverse order
		// blocks for: iid, iterated CUE, numeric CUE, j2lr, j2l and 2-step GMM
		for (kk=firstrank; kk<=lastrank; kk++) {
			// loops through endogenous variables including dep var; index called rr in FW code
			// loops in reverse, collecting tests of rank=1 up to rank=K1-1
			// naming:
			// y is all endog after partialling; doesn't change; #cols=K1; called xx in FW code
			// z is all IVs after partialling; doesn't change; #cols=K2; called z in FW code
			// y1 is cols 1 to ii of y; loop through; called y in FW code
			// y2 is cols ii+1 to K1 of y; loop through; called x in FW code
			// ii is cols of y1; called rr in FW code
			// kk is cols of y2; called kx in FW code

			ii			= K1 - kk
			// submatrices
			vy1			= vhat[.,(1..ii)]
			vy2			= vhat[|1,(ii+1) \ .,.|]
			y1			= (*py)[.,(1..ii)]
			y2			= (*py)[|1,(ii+1) \ .,.|]
			Qzy1		= Qzy[|1,1 \ .,ii|]
			Qzy2		= Qzy[|1,(ii+1) \ .,.|]
			// z_kron called zz in FW code
			z_kron		= I(ii) # (*pz)
			// zz_kron = quadcross(z_kron, z_kron)
			// expression for zz_kron is zz'zz in FW code
			Qzz_kron	= I(ii) # Qzz
	
			// prepare pointers; pointer to z already exists
			pvy1		= &vy1
			pvy2		= &vy2
			py1			= &y1
			py2			= &y2
			pz_kron		= &z_kron

			// don't need to initialize e, just need to make conformable
			vcvo.e		= &ehat[.,(1..ii)]
			
			// update struct with args for j subroutines
			jargs.pvy1		= pvy1
			jargs.pvy2		= pvy2
			jargs.py1		= py1
			jargs.py2		= py2
			jargs.pz_kron	= pz_kron
			jargs.Qzz_kron	= Qzz_kron
			jargs.Qzy1		= Qzy1
			jargs.Qzy2		= Qzy2
			jargs.ii		= ii
			jargs.kk		= kk
	
			if (iidflag) {									// iid J stat is LIML or Sargan/IV
				if (binit=="liml") {
					b0		= -phil[ii+1::K1,1::ii]*luinv(phil[1::ii,1::ii])
				}
				else {
					// initial b0 = 2sls
					b0		= invsym(Qzy2' * iQzz * Qzy2) * Qzy2' * iQzz * Qzy1
				}
				r			= m_jiid(jargs,vcvo,b0)
			}
			else if ((kpflag) & (svdflag)) {				// KP and SVD algorithm
				// note we call with kpv = kpvt'
				// nb: SVD not yet supported with Hmat
				r			= m_svd(jargs,kpthat,kpu,kpvt',kpvar)
			}
			else if (kpflag) {								// KP using J-type algorithm
				// nb: LIML not yet supported with Hmat
				bliml		= -phil[ii+1::K1,1::ii]*luinv(phil[1::ii,1::ii])
				r			= m_kp(jargs,vcvo,bliml)
			}
			else if ((jcueflag) & (iterateflag)) {			// J CUE using iterative algorithm
				if (binit=="liml") {
					// initial b0 = liml
					b0		= -phil[ii+1::K1,1::ii]*luinv(phil[1::ii,1::ii])
				}
				else if (hflag) {
					// initial b0 = 2sls with Hmat matrix
					b0		= invsym(Qzy2' * iQzHz * Qzy2) * Qzy2' * iQzHz * Qzy1
				}
				else {
					// initial b0 = 2sls
					b0		= invsym(Qzy2' * iQzz * Qzy2) * Qzy2' * iQzz * Qzy1
				}
				// iterated CUE uses possibly-adjusted ivarpi0kc
				r			= m_jcueiter(jargs,vcvo,ivarpi0kc,vecpi,b0)
				// finish off with call to numerical maximizer
				if (combiterflag) {
					printf("{txt}Switching to numerical maximization...")
					b0		= r.beta			
					r		= m_jcuenum(jargs,vcvo,b0)
				}
			}
			else if (jcueflag) {							// J CUE using numerical maximization
				if (binit=="liml") {
					// initial b0 = liml
					b0		= -phil[ii+1::K1,1::ii]*luinv(phil[1::ii,1::ii])
				}
				else if (hflag) {
					// initial b0 = 2sls with Hmat matrix
					b0		= invsym(Qzy2' * iQzHz * Qzy2) * Qzy2' * iQzHz * Qzy1
				}
				else {
					// initial b0 = 2sls
					b0		= invsym(Qzy2' * iQzz * Qzy2) * Qzy2' * iQzz * Qzy1
				}
				r			= m_jcuenum(jargs,vcvo,b0)
			}
			else if (j2lflag) {								// J2L
				bliml		= -phil[ii+1::K1,1::ii]*luinv(phil[1::ii,1::ii])
				r			= m_j2l(jargs,vcvo,bliml)
			}
			else if (j2lrflag) {							// J2LR = iterated cue with b0=liml and maxiter=1
				bliml		= -phil[ii+1::K1,1::ii]*luinv(phil[1::ii,1::ii])
				jargs.maxiter = 1
				r			= m_jcueiter(jargs,vcvo,ivarpi0kc,vecpi,bliml)
			}
			else {											// J from 2-step GMM
				if (hflag) {
					biv		= invsym(Qzy2' * iQzHz * Qzy2) * Qzy2' * iQzHz * Qzy1
				}
				else {
					biv 	= invsym(Qzy2' * iQzz * Qzy2) * Qzy2' * iQzz * Qzy1
				}
				r			= m_jgmm2s(jargs,vcvo,biv)
			}

			// store stats in appropriate row of rkmatrix
			rkmatrix[rkrow,1]	= r.j
			rkmatrix[rkrow,2]	= r.df
			rkmatrix[rkrow,3]	= r.pvalue
			rkmatrix[rkrow,4]	= kk		// H0:rank=kk
			rkmatrix[rkrow,5]	= eval[kk+1]
			rkmatrix[rkrow,6]	= ccorr[kk+1]
			rkrow++							// increment row counter for next time through the loop
	
		}

	}

	// single test of rank reduction and using J so beta exists
	if (betaflag) {

		// betas from last test of rank
		beta0	= r.beta0
		beta	= r.beta
		V		= r.V
		S		= r.S

		// if standardization is used, need to unstandardize coefs, V and S
		if (stdflag) {
			sy1			= (J(rr,K1-rr,1) :* sy[1..rr,1])'
			sy2			= J(K1-rr,rr,1) :* sy[(rr+1)..K1,1]
			sy1_sy2		= sy1 :/ sy2
			beta0		= beta0 :* sy1_sy2
			beta		= beta  :* sy1_sy2
			V			= V :* (vec(sy1_sy2) * vec(sy1_sy2)')
			_makesymmetric(V)
			S			= S :* (((sy[1..rr,1]) # sz)*((sy[1..rr,1]) # sz)')
			_makesymmetric(S)
		}

		// for labelling beta if EV ordering has been used
		if (evorderflag) {
			// selection indexes (row vectors)
			ind1 = ind[1,1..rr]
			ind2 = ind[1,(rr+1)..K1]
		}
		else {
			// selection indexes (row vectors): e.g. (1, 2, 3) and (4, 5, 6)
			ind1 = runningsum(J(rr,1,1))'
			ind2 = runningsum(J(K1-rr,1,1))' :+ rr
		}

		// label beta vector/matrix
		// here, depvar and endog are vectors
		depvar		= ykeeptokens[.,ind1]
		endog		= ykeeptokens[.,ind2]
		// Stata standard is coef vectors (will transpose below)
		beta		= vec(beta)
		beta0		= vec(beta0)
		if (cols(depvar)==1) {
			// single equation, no eqn stripe needed
			bstripe	= J(cols(endog),1,""), endog'
			sstripe = J(cols(zkeeptokens),1,""), zkeeptokens'
		}
		else {
			bstripe = J(0,2,"")
			sstripe = J(0,2,"")
			for (kk=1;kk<=cols(depvar);kk++) {
				for (ll=1;ll<=cols(endog);ll++) {
					bstripe = bstripe \ ( invtokens(depvar[1,kk]), invtokens(endog[1,ll]))
				}
				for (ll=1;ll<=cols(zkeeptokens);ll++) {
					sstripe = sstripe \ ( invtokens(depvar[1,kk]), invtokens(zkeeptokens[1,ll]))
				}
			}
		}
		// now make them into tokens so they can be saved as Stata macros
		depvar		= invtokens(depvar)
		endog		= invtokens(endog)
		exexog		= invtokens(zkeeptokens)
	}
	else if ((kpflag) | (iidflag)) {
		V			= kpvar
		S			= shat0
		if (stdflag) {
			S		= S :* ((sy # sz)*(sy # sz)')
			_makesymmetric(S)
		}
		// evorder may have changed order of y
		ylist		= ykeeptokens[.,ind]
		if (cols(depvar)==1) {
			// single equation, no eqn stripe needed
			sstripe = J(cols(zkeeptokens),1,""), zkeeptokens'
		}
		else {
			sstripe = J(0,2,"")
			for (kk=1;kk<=cols(ylist);kk++) {
				for (ll=1;ll<=cols(zkeeptokens);ll++) {
					sstripe = sstripe \ ( invtokens(ylist[1,kk]), invtokens(zkeeptokens[1,ll]))
				}
			}
		}
	}

	
	// return results to Stata
	st_matrix("r(rkmatrix)", rkmatrix)
	st_matrix("r(ccorr)", ccorr)
	st_matrix("r(eval)", eval)
	st_numscalar("r(N)", N)
	if (clustvarname~="") {
		st_numscalar("r(N_clust)", N_clust)
	}
	if (clustvarname2~="") {
		st_numscalar("r(N_clust2)", N_clust2)
	}

	// beta vector/matrix
	// return as Stata-style row vector if vector, and transpose if matrix
	if (betaflag) {
		st_matrix("r(b0)", beta0')
		st_matrix("r(b)", beta')
		st_matrix("r(V)", V)
		st_matrix("r(S)", S)
		st_matrixcolstripe("r(b0)", bstripe)
		st_matrixcolstripe("r(b)", bstripe)
		st_matrixrowstripe("r(b0)", ("", "y1"))
		st_matrixrowstripe("r(b)", ("", "y1"))
		st_matrixrowstripe("r(V)", bstripe)
		st_matrixcolstripe("r(V)", bstripe)
		st_matrixrowstripe("r(S)", sstripe)
		st_matrixcolstripe("r(S)", sstripe)
		st_global("r(depvar)", depvar)
		st_global("r(endog)", endog)
		st_global("r(exexog)", exexog)
	}
	else if ((kpflag) | (iidflag)) {
		st_matrix("r(V)", V)
		st_matrix("r(S)", S)
		st_matrixrowstripe("r(V)", sstripe)
		st_matrixcolstripe("r(V)", sstripe)
		st_matrixrowstripe("r(S)", sstripe)
		st_matrixcolstripe("r(S)", sstripe)
	}
//	else {
//		st_matrix("r(S)", S)
//		st_matrixrowstripe("r(S)", sstripe)
//		st_matrixcolstripe("r(S)", sstripe)
//	}
	st_numscalar("r(K3)",K3)
	if (switchflag) {
		// rank(varlist1) > rank(varlist2) so we switched them to z and y above.
		st_numscalar("r(K1)",K2)
		st_numscalar("r(K2)",K1)
		// these have had any collinearities removed
		st_global("r(ynocollin)",invtokens(zkeeptokens))
		st_global("r(znocollin)",invtokens(ykeeptokens))
		// dropped because of collinearities
		if (cols(zdroptokens)>0) {
			st_global("r(ycollin)",invtokens(zdroptokens))
		}
		if (cols(ydroptokens)>0) {
			st_global("r(zcollin)",invtokens(ydroptokens))
		}
	}
	else {
		st_numscalar("r(K1)",K1)
		st_numscalar("r(K2)",K2)
		// these have had any collinearities removed
		st_global("r(ynocollin)",invtokens(ykeeptokens))
		st_global("r(znocollin)",invtokens(zkeeptokens))
		// dropped because of collinearities
		if (cols(ydroptokens)>0) {
			st_global("r(ycollin)",invtokens(ydroptokens))
		}
		if (cols(zdroptokens)>0) {
			st_global("r(zcollin)",invtokens(zdroptokens))
		}
	}


}	// end of s_jstat program


// ordering by eigenvalues
function m_evorder(
						numeric matrix Qyy,
						numeric matrix iQyy,
						numeric matrix Qzz,
						numeric matrix iQzz,
						numeric matrix Qzy,
						numeric matrix eval,	// result placed in var
						numeric matrix ccorr,	// result placed in var
						numeric matrix ind,		// result placed in var
						numeric matrix phil		// result placed in var
					)
{

	K1		=cols(Qyy)
	irQyy	= matpowersym(Qyy,-0.5)

	if (irQyy[1,1]==.) {
		printf("{err}error - missings in matrix square root - may be caused by collinearities\n")
		exit(error(3351))
	}
	
	matl	= irQyy*Qzy'*iQzz*Qzy*irQyy
 	vl		= .								// need to create var first
	symeigensystem(matl,vl,eval)
	phil	= irQyy*vl
	ccorr	= eval:^(0.5)

	// reorder
	phil	= phil[.,K1::1]
	phils	= abs(phil)

	ii		= .
	ww		= .
	ind		= J(1,K1,0)

	for (jj=1;jj<=K1;jj++) {
		maxindex(phils[.,jj],1,ii,ww)
		ind[1,jj]	= ii
		phils[ii,.]	= J(1,K1,0)
	}

}


// returns structure with 2-step GMM results
struct ms_jresult scalar m_jgmm2s(		struct ms_jargs scalar jargs,
										struct ms_vcvorthog scalar vcvo,
										numeric matrix biv)
{

	struct ms_jresult scalar r

	r.beta0					= biv				// in saved results

	// ishat based on IV residuals
	(*vcvo.e)[.,(1..jargs.ii)]	= (*jargs.pvy1) - (*jargs.pvy2)*biv
	shat					= m_omega(vcvo)
	ishat					= invsym(shat)

	Qzy2_kron				= I(jargs.ii) # jargs.Qzy2

	bgmm					= invsym(Qzy2_kron'*ishat*Qzy2_kron) * Qzy2_kron'*ishat*vec(jargs.Qzy1)
	bgmm					= rowshape(bgmm',rows(biv'))'

	// j based on 2-step GMM beta and first-step (IV) shat
	(*vcvo.e)[.,(1..jargs.ii)]	= (*jargs.pvy1) - (*jargs.pvy2)*bgmm
	eit						= vec((*jargs.py1) - (*jargs.py2)*bgmm)
	// need to stack weights
	gbar					= quadcross(*jargs.pz_kron, vcvo.wf*(J(jargs.ii,1,1) # (W=(*vcvo.wvar))), eit) * 1/jargs.N
	j						= gbar' * ishat * gbar * jargs.Nminus
	rrank					= diag0cnt(ishat)
	if (rrank) {
		printf("{txt}warning - avar rank reduction=%f in test of rank=%f; adjusting df of test\n",rrank,jargs.kk)
	}
		
	df						= (jargs.K2-jargs.kk)*jargs.ii - rrank
	pvalue					= chi2tail(df,j)
	
	r.j				 		= j
	r.beta					= bgmm
	r.pvalue				= pvalue
	r.df					= df
	tkron					= I(jargs.ii) # jargs.Qzy2
	r.V						= invsym(tkron' * invsym(shat) * tkron) * 1/jargs.N
	r.S						= shat

	return(r)
}

// returns structure with kp-liml results
struct ms_jresult scalar m_kp(		struct ms_jargs scalar jargs,
									struct ms_vcvorthog scalar vcvo,
									numeric matrix bliml
									)
{

	struct ms_jresult scalar r
	struct ms_vcvorthog scalar vcvo_kp
	
	r.beta0						= bliml				// in saved results


	// ul are liml residuals
	ul							= (*jargs.py1) - (*jargs.py2)*bliml
	aux1						= cholinv(quadcross(ul,vcvo.wf*(*vcvo.wvar),ul))
	aux2						= quadcross(ul,vcvo.wf*(*vcvo.wvar),*jargs.pz)
	muz							= (*jargs.pz)-ul*aux1*aux2
	y2l							= (*jargs.pz)*cholsolve(quadcross(muz,vcvo.wf*(*vcvo.wvar),muz),quadcross(muz,vcvo.wf*(*vcvo.wvar),(*jargs.py2)))
	aux3						= quadcross(y2l,vcvo.wf*(*vcvo.wvar),(*jargs.pz)[.,jargs.kk+1::jargs.K2])
	my2lz2						= (*jargs.pz)[.,jargs.kk+1::jargs.K2]-y2l*cholinv(quadcross(y2l,vcvo.wf*(*vcvo.wvar),y2l))*aux3
	my2lz2_kron					= I(jargs.ii) # my2lz2
	
	
	// shat based on liml residuals for VCV
	(*vcvo.e)[.,(1..jargs.ii)]	= ul
	shat_liml					= m_omega(vcvo)

	// shat based on liml residuals for KP-J; Z and ZZ are overwritten so need to create new ms_vcvorthog
	vcvo_kp						= vcvo
	(*vcvo_kp.e)[.,(1..jargs.ii)]	= (*jargs.pvy1) - (*jargs.pvy2)*bliml
	vcvo_kp.Z					= &my2lz2
	vcvo_kp.ZZ					= quadcross(my2lz2, vcvo_kp.wf*(*vcvo_kp.wvar), my2lz2)
	shat						= m_omega(vcvo_kp)
	ishat						= invsym(shat)
	eit							= vec(ul)
	gbar						= quadcross(my2lz2_kron, vcvo_kp.wf*(J(jargs.ii,1,1) # (W=(*vcvo_kp.wvar))), eit) * 1/jargs.N
	j							= gbar' * ishat * gbar * jargs.Nminus
	rrank						= diag0cnt(ishat)
	if (rrank) {
		printf("{txt}warning - avar rank reduction=%f in test of rank=%f; adjusting df of test\n",rrank,jargs.kk)
	}
		
	df							= (jargs.K2-jargs.kk)*jargs.ii - rrank
	pvalue						= chi2tail(df,j)

	r.j					 		= j
	r.beta						= bliml
	r.pvalue					= pvalue
	r.df						= df

	tkron						= I(jargs.ii) # jargs.Qzy2
	r.V							= invsym(tkron' * invsym(shat_liml) * tkron) * 1/jargs.N
	r.S							= shat_liml

	return(r)
}

// returns structure with kp using SVD; no beta returned
struct ms_jresult scalar m_svd(			struct ms_jargs scalar jargs,
										matrix that,
										matrix u,
										matrix v,
										matrix vhat)
{
	struct ms_jresult scalar r

	vecthat		= vec(that)

	u12			= u[(1::jargs.kk),(jargs.kk+1..jargs.K2)]
	v12			= v[(1::jargs.kk),(jargs.kk+1..jargs.K1)]
	u22			= u[(jargs.kk+1::jargs.K2),(jargs.kk+1..jargs.K2)]
	v22			= v[(jargs.kk+1::jargs.K1),(jargs.kk+1..jargs.K1)]

	symeigensystem(u22*u22', evec, eval)
	// if rank deficiency probs, evals can be negative, so zero out
	if (sum(eval :< 0)>0) {
		printf("{txt}warning - negative eigenvalues encountered in SVD algorithm in test of rank=%f\n",jargs.kk)
		eval	= (eval :>= 0) :* eval
	}
	u22v		= evec
	u22d		= diag(eval)
	u22h		= u22v*(u22d:^0.5)*u22v'

	symeigensystem(v22*v22', evec, eval)
	// if rank deficiency probs, evals can be negative, so zero out
	if (sum(eval :< 0)>0) {
		printf("{txt}warning - negative eigenvalues encountered in SVD algorithm in test of rank=%f\n",jargs.kk)
		eval	= (eval :>= 0) :* eval
	}
	v22v		= evec
	v22d		= diag(eval)
	v22h		= v22v*(v22d:^0.5)*v22v'

	// luqrinv - use LU inversion; if fails because singular, use QR
	aq			= (u12 \ u22)*luqrinv(u22)*u22h
	bq			= v22h*luqrinv(v22')*(v12 \ v22)'

	lab			= (bq#aq')*vecthat
	vlab		= (bq#aq')*vhat*(bq#aq')'
	_makesymmetric(vlab)
	vlabinv		= invsym(vlab)

	rrank		= diag0cnt(vlabinv)
	if (rrank) {
		printf("{txt}warning - avar rank reduction=%f in test of rank=%f; adjusting df of test\n",rrank,jargs.kk)
	}
	
	r.j			= lab'*vlabinv*lab*jargs.Nminus
	r.df		= (jargs.K2-jargs.kk)*jargs.ii - rrank
	r.pvalue	= chi2tail(r.df,r.j)
	
	return(r)
}

// returns structure with j2l results
struct ms_jresult scalar m_j2l(			struct ms_jargs scalar jargs,
										struct ms_vcvorthog scalar vcvo,
										numeric matrix bliml)
{

	struct ms_jresult scalar r

	r.beta0					= bliml				// in saved results

	// ul are liml residuals
	ul						= (*jargs.py1) - (*jargs.py2)*bliml
	// can cause numerical problems...?
	aux1					= cholinv(quadcross(ul,vcvo.wf*(*vcvo.wvar),ul))
	aux2					= quadcross(ul,vcvo.wf*(*vcvo.wvar),*jargs.pz)
	muz						= (*jargs.pz)-ul*aux1*aux2
	y2l						= (*jargs.pz)*cholsolve(quadcross(muz,vcvo.wf*(*vcvo.wvar),muz),quadcross(muz,vcvo.wf*(*vcvo.wvar),(*jargs.py2)))
	Qzy2l					= quadcross(*jargs.pz,vcvo.wf*(*vcvo.wvar),y2l) * 1/jargs.N
	Qzy2l_kron				= I(jargs.ii) # Qzy2l
	y2_kron					= I(jargs.ii) # (*jargs.py2)

	// ishat based on liml residuals
	(*vcvo.e)[.,(1..jargs.ii)]	= (*jargs.pvy1) - (*jargs.pvy2)*bliml
	shat					= m_omega(vcvo)
	ishat					= invsym(shat)

	// calc b2l; note shat is based on liml residuals
	inst					= (*jargs.pz_kron)*ishat*Qzy2l_kron
	// need to stack weights
	aux3					= quadcross(inst,vcvo.wf*(J(jargs.ii,1,1) # (W=(*vcvo.wvar))),y2_kron)
	aux4					= quadcross(inst,vcvo.wf*(J(jargs.ii,1,1) # (W=(*vcvo.wvar))),vec(*jargs.py1))
	b2l						= luinv(aux3)*aux4
	b2l						= rowshape(b2l,jargs.ii)
	b2l						= b2l'

	// resids, ishat and j based on b2l
	(*vcvo.e)[.,(1..jargs.ii)]	= (*jargs.pvy1) - (*jargs.pvy2)*b2l
	shat					= m_omega(vcvo)
	ishat					= invsym(shat)
	eit						= vec((*jargs.py1) - (*jargs.py2)*b2l)
	// need to stack weights
	gbar					= quadcross(*jargs.pz_kron, vcvo.wf*(J(jargs.ii,1,1) # (W=(*vcvo.wvar))), eit) * 1/jargs.N
	j						= gbar' * ishat * gbar * jargs.Nminus

	rrank					= diag0cnt(ishat)
	if (rrank) {
		printf("{txt}warning - avar rank reduction=%f in test of rank=%f; adjusting df of test\n",rrank,jargs.kk)
	}
		
	df						= (jargs.K2-jargs.kk)*jargs.ii - rrank
	pvalue					= chi2tail(df,j)
	
	r.j				 		= j
	r.beta					= b2l
	r.pvalue				= pvalue
	r.df					= df
	return(r)
}


// returns structure with iid results
struct ms_jresult scalar m_jiid(	struct ms_jargs scalar jargs,
									struct ms_vcvorthog scalar vcvo,
									real matrix b0
									)
{

	struct ms_jresult scalar r

	// b0 is expected to be the 2SLS beta
	// b0 = LIML yields same results as canonical correlations etc.
	
	(*vcvo.e)[.,(1..jargs.ii)]	= (*jargs.pvy1) - (*jargs.pvy2) * b0
	shat						= m_omega(vcvo)
	ishat						= invsym(shat)
	eit							= vec((*jargs.py1) - (*jargs.py2) * b0)
	// need to stack weights
	gbar						= quadcross(	*jargs.pz_kron,									///
												vcvo.wf*(J(jargs.ii,1,1) # (W=(*vcvo.wvar))),	///
												eit)											///
												* 1/jargs.N
	j							= gbar' * ishat * gbar * jargs.Nminus

	rrank						= diag0cnt(ishat)
	if (rrank) {
		printf("{txt}warning - avar rank reduction=%f in test of rank=%f; adjusting df of test\n",rrank,jargs.kk)
	}
		
	df							= (jargs.K2-jargs.kk)*jargs.ii - rrank
	pvalue						= chi2tail(df,j)
	
	r.j					 		= j
	r.beta0						= b0
	r.beta						= b0
	r.pvalue					= pvalue
	r.df						= df

	tkron						= I(jargs.ii) # jargs.Qzy2
	r.V							= invsym(tkron' * invsym(shat) * tkron) * 1/jargs.N
	r.S							= shat

	return(r)
}


// returns structure with iterated J CUE results
struct ms_jresult scalar m_jcueiter(	struct ms_jargs scalar jargs,
										struct ms_vcvorthog scalar vcvo,
										real matrix ivarpi0,
										real matrix vecpi,
										numeric matrix binit)
{

	struct ms_jresult scalar r

	// iterated CUE message, but only if we are iterating
	if ((jargs.dotsflag) & (jargs.maxiter>1)) {
		printf("\n")
		dotscmd = "_dots 0 0, title(Calculating iterated CUE J for test of rank=" + strofreal(jargs.kk) + ")"
		stata(dotscmd)
	}
	else if (jargs.maxiter>1) {
		printf("\n{txt}Calculating CUE J for test of rank=%f",jargs.kk)
	}

	// initialize
	bit						= binit
	r.beta0					= binit				// in saved results
	(*vcvo.e)[.,(1..jargs.ii)]	= (*jargs.pvy1) - (*jargs.pvy2) * bit
	shat					= m_omega(vcvo)		// FW doesn't normalise by N (equiv to multiplies by N)
	ishat					= invsym(shat)		// w2 in FW code
	eit						= vec((*jargs.py1) - (*jargs.py2) * bit)
	gbar					= quadcross(*jargs.pz_kron, vcvo.wf*(J(jargs.ii,1,1) # (W=(*vcvo.wvar))), eit) * 1/jargs.N
	jcue					= gbar' * ishat * gbar * jargs.Nminus

	i=0

	// do...while
	do {

		jprev=jcue
		bprev=bit

		i=i+1		

		// output dots only if we are iterating
		if ((jargs.dotsflag) & (jargs.maxiter>1)) {
			dotscmd = "_dots " + strofreal(i) + " 0"
			stata(dotscmd)
		}

		// get new bit for next time through loop
		dd					= (bit' \ I(jargs.kk)) # I(jargs.K2)
		// pih				= invsym(dd'*ivarpi0*dd)*dd'*ivarpi0*vecpi
		pih					= cholinv(dd'*ivarpi0*dd)*dd'*ivarpi0*vecpi
		// equivalent is rowshape(pih,(K1-ii))
		pih					= colshape(pih,jargs.K2)
		pih					= pih'
		inst				= (*jargs.pz_kron)*ishat*jargs.Qzz_kron*(I(jargs.ii)#pih)
		insty1				= quadcross(inst,vec((*jargs.py1):*(vcvo.wf*(*vcvo.wvar))))
		// equivalent to
		//					= quadcross(inst,vcvo.wf*(J(jargs.ii,1,1) # (W=(*vcvo.wvar))),vec((*jargs.py1)))
		insty2				= quadcross(inst,I(jargs.ii)#((*jargs.py2):*(vcvo.wf*(*vcvo.wvar))))
		// nonsymmetric matrix so can't use cholinv or invsym
		// is rank deficiency a potential issue? if so, use qrinv or pinv?
		// bit					= luinv(insty2)*insty1
		bit					= qrinv(insty2)*insty1
		bit					= rowshape(bit,jargs.ii)
		bit					= bit'

		// ishat and jcue based on resids from current bit
		// at first iteration, will be resids from binit (2sls or liml)
		// note that jcue=N*gbar(ehat)'ishat(ehat)gbar(ehat) uses same resid throughout
		// usual 2-step GMM uses initial resids in ishat(ehat)
		// ehat[.,(1..ii)]		= y1 - y2*bit
		// vcvo.e				= &ehat[.,(1..ii)]

		(*vcvo.e)[.,(1..jargs.ii)]	= (*jargs.pvy1) - (*jargs.pvy2) * bit
		shat					= m_omega(vcvo)		// FW doesn't normalise by N (equiv to multiplies by N)
		ishat					= invsym(shat)		// w2 in FW code
		eit						= vec((*jargs.py1) - (*jargs.py2) * bit)
		// need to stack weights
		gbar					= quadcross(*jargs.pz_kron, vcvo.wf*(J(jargs.ii,1,1) # (W=(*vcvo.wvar))), eit) * 1/jargs.N
		jcue					= gbar' * ishat * gbar * jargs.N

		// change in jcue; should be negative unless algo is starting to veer off
		jcha				= jcue-jprev
		// can hit problem if shat rank deficient, bit has missings, veers off, etc.
		// if jcha >=0 or jcha==., algo will exit
		if (jcha>0) {
			jcue			= jprev
			bit				= bprev
		}
		if (jcue==.) {
			jcue			= jprev
			jcha			= .
		}
		if (jcue==0) {
			jcue			= .
		}

		// printf("{txt}iteration %f, jcha=%f, J=%f\n",i,jcha,jcue)

	} while ((jcha < -jargs.jtol) & (i < jargs.maxiter))

	// message output only if we are iterating
	if ((i<jargs.maxiter) & (jargs.maxiter>1)) {
		printf("\n{txt}convergence after %f iterations\n",i)
	}
	else if (jargs.maxiter>1) {
		printf("\n{txt}no convergence after max %f iterations; del(jcue)=%g\n",i,jcha)
	}
	
	// used as diagnostic at end of loop
	// note that this is based on the updated bit; works better as a diagnostic that way
	bcha = vec(bit-bprev)'vec(bit-bprev)

	// warning messages only if we are iterating
	if ((jargs.maxiter>1) & ((bcha>jargs.btol) | (jcha>0))) {
		printf("warning: possible convergence failure\n")
		if (bcha>1e-10) {
			printf("         del(b)'del(b)=%g\n",bcha)
		}
		if (jcha>0) {
			printf("         del(jcue)=%g; positive at last iteration\n",jcha)
		}
		else {
			printf("         del(jcue)=%g\n",jcha)
		}
		if (hasmissing(bit)) {
			printf("         last iteration of b has missing values\n")
		}
		if (diag0cnt(ishat)) {
			printf("         last iteration of avar of moments not full rank\n")
		}
	}
	// behavior if we are not iterating: j missing if obj fn increased
	if ((maxiter==1) & (jcha>0)) {
		printf("warning: del(jcue)=%g; positive after single iteration\n",jcha)
		jcue				= .
	}

	rrank					= diag0cnt(ishat)
	if (rrank) {
		printf("{txt}warning - avar rank reduction=%f in test of rank=%f; adjusting df of test\n",rrank,jargs.kk)
	}
		
	df						= (jargs.K2-jargs.kk)*jargs.ii - rrank
	pvalue					= chi2tail(df,jcue)

	r.j 					= jcue
	r.beta					= bit
	r.pvalue				= pvalue
	r.df					= df
	r.S						= shat
	tkron					= I(jargs.ii) # jargs.Qzy2
	r.V						= invsym(tkron' * invsym(shat) * tkron) * 1/jargs.N
	r.S						= shat

	return(r)
}


// returns structure with numerical J CUE results
struct ms_jresult scalar m_jcuenum(		struct ms_jargs scalar jargs,
										struct ms_vcvorthog scalar vcvo,
										numeric matrix binit)
{

	struct ms_jresult scalar r

	r.beta0			= binit				// in saved results
	
	b0				= rowshape(binit,1)

	// What follows is how to set out an optimization in Stata.  First, initialize
	// the optimization structure in the variable S.  Then tell Mata where the
	// objective function is, that it's a minimization, that it's a "d0" type of
	// objective function (no analytical derivatives or Hessians), and that the
	// initial values for the parameter vector are in b0.  Finally, optimize.

	S = optimize_init()

	// see later in file for m_cuecrit(.) function
	optimize_init_evaluator(S, &m_cuecrit())
	optimize_init_which(S, "min")
	optimize_init_evaluatortype(S, "d0")
	optimize_init_params(S, b0)
	optimize_init_conv_maxiter(S, jargs.maxiter)
	if (jargs.tracelevel~="") {
		optimize_init_tracelevel(S, jargs.tracelevel)
	}
	optimize_init_conv_ptol(S,jargs.btol)
	optimize_init_conv_vtol(S,jargs.jtol)
	// CUE objective function takes 2 extra arguments = struct with args and struct with vcvo
	optimize_init_argument(S, 1, jargs)
	optimize_init_argument(S, 2, vcvo)

	printf("\n{txt}Calculating CUE J using numerical maximization for test of rank=%f\n",jargs.kk)
	
	beta					= optimize(S)	// Stata convention is row vector orientation
	
	// the last evaluation of the GMM objective function is J.
	jcue					= optimize_result_value(S)

	shat					= m_omega(vcvo)
	ishat					= invsym(shat)
	rrank					= diag0cnt(ishat)
	if (rrank) {
		printf("{txt}warning - avar rank reduction=%f in test of rank=%f; adjusting df of test\n",rrank,jargs.kk)
	}
		
	df						= (jargs.K2-jargs.kk)*jargs.ii - rrank
	pvalue					= chi2tail(df,jcue)

	r.j				 		= jcue
	r.beta					= rowshape(beta,rows(binit))	// put into correct r x c dim
	r.pvalue				= pvalue
	r.df					= df
	r.S						= shat

	tkron					= I(jargs.ii) # jargs.Qzy2
	r.V						= invsym(tkron' * invsym(shat) * tkron) * 1/jargs.N
	r.S						= shat

	return(r)
}

// CUE evaluator function.
// Handles only d0-type optimization; todo, g and H are just ignored.
// beta is the parameter set over which we optimize, and 
// J is the objective function to minimize.

void m_cuecrit(todo, beta, struct ms_jargs scalar jargs, struct ms_vcvorthog scalar vcvo, j, g, H)
{

	ii				= cols(*jargs.py1)

	// beta arrives as a rowvector so must reshape it first
	b				= rowshape(beta, cols(*jargs.py2))
	
	*vcvo.e[.,.]	= (*jargs.pvy1) - (*jargs.pvy2) * b

	shat			= m_omega(vcvo)
	ishat			= invsym(shat)

	eit				= vec((*jargs.py1) - (*jargs.py2) * b)
	// need to stack weights
	gbar			= quadcross(*jargs.pz_kron, vcvo.wf*(J(ii,1,1) # (W=(*vcvo.wvar))), eit) * 1/vcvo.N
	j				= gbar' * ishat * gbar * jargs.Nminus

} // end program CUE criterion function


// returns structure with numerical J LIML results
// not currently in use
struct ms_jresult scalar m_jlimlnum(	struct ms_jargs scalar jargs,
										struct ms_vcvorthog scalar vcvo,
										numeric matrix binit)
{

	struct ms_jresult scalar r

	r.beta0			= binit				// in saved results
	
	b0				= rowshape(binit,1)

	S = optimize_init()

	optimize_init_evaluator(S, &m_limlcrit())
	optimize_init_which(S, "min")
	optimize_init_evaluatortype(S, "d0")
	optimize_init_params(S, b0)
	optimize_init_conv_maxiter(S, jargs.maxiter)
	if (jargs.tracelevel~="") {
		optimize_init_tracelevel(S, jargs.tracelevel)
	}
	optimize_init_conv_ptol(S,jargs.btol)
	optimize_init_conv_vtol(S,jargs.jtol)
	// LIML objective function takes 2 extra arguments
	optimize_init_argument(S, 1, jargs)
	optimize_init_argument(S, 2, vcvo)

	printf("\n{txt}Calculating LIML J using numerical maximization for test of rank=%f\n",jargs.kk)
	
	beta					= optimize(S)	// Stata convention is row vector orientation

	// the last evaluation of the GMM objective function is J.
	jliml					= optimize_result_value(S)

	shat					= m_omega(vcvo)
	ishat					= invsym(shat)
	rrank					= diag0cnt(ishat)
	if (rrank) {
		printf("{txt}warning - avar rank reduction=%f in test of rank=%f; adjusting df of test\n",rrank,jargs.kk)
	}
		
	df						= (jargs.K2-jargs.kk)*jargs.ii - rrank
	pvalue					= chi2tail(df,jliml)
	
	r.j				 		= jliml
	r.beta					= beta'			// our convention is column vector orientation
	r.pvalue				= pvalue
	r.df					= df
	return(r)
}

void m_limlcrit(todo, beta, struct ms_jargs scalar jargs, struct ms_vcvorthog scalar vcvo, j, g, H)
{
	ii				= cols(*jargs.py1)

	// beta arrives as a rowvector so must reshape it first
	b				= rowshape(beta, cols(*jargs.py2))

	*vcvo.e[.,.]	= (*jargs.pvy1) - (*jargs.pvy2) * b

	// LIML support for H-mat not yet available
	// if (jargs.hflag) {
	//	sigma2		= hcross(*vcvo.e[.,.],*vcvo.e[.,.],jargs.Hmat,jargs.hvar,*vcvo.wvar,jargs.info,"invert")
	// }
	sigma2			= quadcross(*vcvo.e[.,.], vcvo.wf*(*vcvo.wvar), *vcvo.e[.,.]) * 1/vcvo.N
	jargs.sigma2	= sigma2

	_makesymmetric(sigma2)
	shat			= sigma2#(jargs.Qzz)
	ishat			= invsym(shat)
	eit				= vec((*jargs.py1) - (*jargs.py2) * b)
	// need to stack weights
	gbar			= quadcross(*jargs.pz_kron, vcvo.wf*(J(ii,1,1) # (W=(*vcvo.wvar))), eit) * 1/vcvo.N

	j				= gbar' * ishat * gbar * jargs.Nminus


} // end program CUE criterion function

function hcross(		numeric matrix A,
						numeric matrix B,
						numeric matrix Hmat,
						numeric matrix hvar,
						numeric matrix wvar,
						numeric matrix info,
						| string scalar invertH)
{

		if (args()==6) {
			invertflag=0
		}
		else if (invertH=="invert") {
			invertflag=1
		}
		else {
			printf("{err}internal ranktest error - invalid argument provided to hcross(.)\n")
			exit(3000)
		}

		npanel = rows(info)
		AHB = J(cols(A),cols(B),0)
		for (i=1; i<=npanel; i++) {
			Apanel	= panelsubmatrix(A,i,info)
			Bpanel	= panelsubmatrix(B,i,info)
			hpanel	= panelsubmatrix(hvar,i,info)
			wpanel	= panelsubmatrix(wvar,i,info)
			H		= Hmat[hpanel,hpanel]
			if (invertflag) {
				H	= invsym(H)
			}
			AHB		= AHB + Apanel' * H * diag(wpanel) * Bpanel
		}
		
		return(AHB)
}
						


// Mata utility for sequential use of inverters of square matrices
// Default is LU;
// if that fails, use QR.
function luqrinv (	numeric matrix A,
					| real scalar r)
{
	return_rank = (args()==2)
	
	real matrix C

	C = luinv(A)
	if ((C[1,1]==.) & (return_rank)) {
		C = qrinv(A, r)
	}
	else if (C[1,1]==.) {
		C = qrinv(A)
	}
	else if (return_rank) {
		r = cols(A)
	}

	return(C)

}

// Mata utility for sequential use of solvers
// Default is cholesky;
// if that fails, use QR.
function cholqrsolve (	numeric matrix A,
						numeric matrix B,
						| real scalar r)
{
	return_rank = (args()==3)
	
	real matrix C

	C = cholsolve(A, B)
	if ((C[1,1]==.) & (return_rank)) {
		C = qrsolve(A, B, r)
	}
	else if (C[1,1]==.) {
		C = qrsolve(A, B)
	}
	else if (return_rank) {
		r = cols(A)
	}

	return(C)

}

end

* Version notes
* 2.0.01  Complete rewrite. See version notes for ranktest11 for notes on previous versions.
*         Main new feature: Cragg-Donald GMM CUE-based J statistic and iterative algorithm.
*         Misc new options: rr(.) for test of H0: rank=(K1-rr)
*                           small for small-sample statistics
*                           added standardization; override with nostd option
*                           lr for LR version of Anderson canonical correlations test
* 2.0.02  (21 Nov 2019) Added e(ranktestcmd) = ranktest for main program.
* 2.0.03  (14 Jun 2020) Final version for v2 release.
*                       Branches to ranktest11 if _caller is version 12 or 11.
* 2.0.04  (21 Sep 2020) Added check for perverse case where minrank=maxrank.
