*! ranktest11 1.4.01 based on ranktest 1.4.01 of 18aug2015
*! author mes, based on code by fk
*! see end of file for version comments

if c(version) < 12 {
* ranktest uses livreg2 Mata library.
* Ensure Mata library is indexed if new install.
* Not needed for Stata 12+ since ssc.ado does this when installing.
	capture mata: mata drop m_calckw()
	capture mata: mata drop m_omega()
	capture mata: mata drop ms_vcvorthog()
	capture mata: mata drop s_vkernel()
	mata: mata mlib index
}

program define ranktest11, rclass sortpreserve

	local lversion 01.4.01

	if _caller() < 11 {
		ranktest9 `0'
		return add						//  otherwise all the ranktest9 results are zapped
		return local ranktestcmd		ranktest9
		return local cmd				ranktest
		return local version			`lversion'
		exit
	}
	version 11.2

	if substr("`1'",1,1)== "," {
		if "`2'"=="version" {
			di in ye "`lversion'"
			return local version `lversion'
			exit
		}
		else {
di as err "invalid syntax"
			exit 198
		}
	}

* If varlist 1 or varlist 2 have a single element, parentheses optional

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
* Need to reinsert comma before options (if any) for -syntax- command to work
		local 0 `", `*'"'
	}

// Note that y or z could be a varlist, e.g., "y1-y3", so they need to be unab-ed.
	tsunab y : `y'
	local K : word count `y'
	tsunab z : `z'
	local L : word count `z'

* Option version ignored here if varlists were provided
	syntax [if] [in] [aw fw pw iw/]				///
		[,										///
		partial(varlist ts)						///
		fwl(varlist ts)							///
		NOConstant								///
		wald									///
		ALLrank									///
		NULLrank								///
		FULLrank								///
		ROBust									///
		cluster(varlist)						///
		BW(string)								///
		kernel(string)							///
		Tvar(varname)							///
		Ivar(varname)							///
		sw										///
		psd0									///
		psda									///
		version									///
		dofminus(integer 0)						///
		]

	local partial		"`partial' `fwl'"
	local partial		: list retokenize partial

	local cons		= ("`noconstant'"=="")

	if "`wald'"~="" {
		local LMWald "Wald"
	}
	else {
		local LMWald "LM"
	}
	
	local optct : word count `allrank' `nullrank' `fullrank'
	if `optct' > 1 {
di as err "Incompatible options: `allrank' `nullrank' `fullrank'"
		error 198
	}
	else if `optct' == 0 {
* Default
		local allrank "allrank"
	}

	local optct : word count `psd0' `psda'
	if `optct' > 1 {
di as err "Incompatible options: `psd0' `psda'"
		error 198
	}
	local psd	"`psd0' `psda'"
	local psd	: list retokenize psd

* Note that by tsrevar-ing here, subsequent disruption to the sort doesn't matter
* for TS operators.
	tsrevar `y'
	local vl1 `r(varlist)'
	tsrevar `z'
	local vl2 `r(varlist)'
	tsrevar `partial'
	local partial `r(varlist)'

	foreach vn of varlist `vl1' {
		tempvar tv
		qui gen double `tv' = .
		local tempvl1 "`tempvl1' `tv'"
	}
	foreach vn of varlist `vl2' {
		tempvar tv
		qui gen double `tv' = .
		local tempvl2 "`tempvl2' `tv'"
	}

	marksample touse
	markout `touse' `vl1' `vl2' `partial' `cluster', strok

* Stock-Watson and cluster imply robust.
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
* If no weights, define neutral weight variable
		qui gen byte `wvar'=1
	}


* Every time a weight is used, must multiply by scalar wf ("weight factor")
* wf=1 for no weights, fw and iw, wf = scalar that normalizes sum to be N if aw or pw
		sum `wvar' if `touse' `wtexp', meanonly
* Weight statement
		if "`weight'" ~= "" {
di in gr "(sum of wgt is " %14.4e `r(sum_w)' ")"
		}
		if "`weight'"=="" | "`weight'"=="fweight" | "`weight'"=="iweight" {
* If weight is "", weight var must be column of ones and N is number of rows.
* With fw and iw, effective number of observations is sum of weight variable.
			local wf=1
			local N=r(sum_w)
		}
		else if "`weight'"=="aweight" | "`weight'"=="pweight" {
* With aw and pw, N is number of obs, unadjusted.
			local wf=r(N)/r(sum_w)
			local N=r(N)
		}
		else {
* Should never reach here
di as err "ranktest error - misspecified weights"
			exit 198
		}

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
		tsreport if `touse', panel
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

************************************************************************************************

* Note that bw is passed as a value, not as a string
	mata: s_rkstat(						///
					"`vl1'",			///
					"`vl2'",			///
					"`partial'",		///
					"`wvar'",			///
					"`weight'",			///
					`wf',				///
					`N',				///
					`cons',				///
					"`touse'",			///
					"`LMWald'",			///
					"`allrank'",		///
					"`nullrank'",		///
					"`fullrank'",		///
					"`robust'",			///
					"`clusterid1'",		///
					"`clusterid2'",		///
					"`clusterid3'",		///
					`bw',				///
					"`tvar'",			///
					"`ivar'",			///
					"`tindex'",			///
					`tdelta',			///
					`dofminus',			///
					"`kernel'",			///
					"`sw'",				///
					"`psd'",			///
					"`tempvl1'",		///
					"`tempvl2'"			///
					)

	tempname rkmatrix chi2 df df_r p rank ccorr eval
	mat `rkmatrix'=r(rkmatrix)
	mat `ccorr'=r(ccorr)
	mat `eval'=r(eval)
	mat colnames `rkmatrix' = "rk" "df" "p" "rank" "eval" "ccorr"
	
di
di "Kleibergen-Paap rk `LMWald' test of rank of matrix"
	if "`robust'"~="" & "`kernel'"~= "" & "`cluster'"=="" {
di "  Test statistic robust to heteroskedasticity and autocorrelation"
di "  Kernel: `kernel'   Bandwidth: `bw'"
	}
	else if "`kernel'"~="" & "`cluster'"=="" {
di "  Test statistic robust to autocorrelation"
di "  Kernel: `kernel'   Bandwidth: `bw'"
	}
	else if "`cluster'"~="" {
di "  Test statistic robust to heteroskedasticity and clustering on `cluster'"
		if "`kernel'"~="" {
di "  and kernel-robust to common correlated disturbances"
di "  Kernel: `kernel'   Bandwidth: `bw'"
		}
	}
	else if "`robust'"~="" {
di "  Test statistic robust to heteroskedasticity"
	}
	else if "`LMWald'"=="LM" {
di "  Test assumes homoskedasticity (Anderson canonical correlations test)"
	}
	else {
di "  Test assumes homoskedasticity (Cragg-Donald test)"
	}
		
	local numtests = rowsof(`rkmatrix')
	forvalues i=1(1)`numtests' {
di "Test of rank=" %3.0f `rkmatrix'[`i',4] "  rk=" %8.2f `rkmatrix'[`i',1] /*
	*/	"  Chi-sq(" %3.0f `rkmatrix'[`i',2] ") pvalue=" %8.6f `rkmatrix'[`i',3]
	}
	scalar `chi2' = `rkmatrix'[`numtests',1]
	scalar `p' = `rkmatrix'[`numtests',3]
	scalar `df' = `rkmatrix'[`numtests',2]
	scalar `rank' = `rkmatrix'[`numtests',4]
	local N `r(N)'
	return scalar df = `df'
	return scalar chi2 = `chi2'
	return scalar p = `p'
	return scalar rank = `rank'
	if "`cluster'"~="" {
		return scalar N_clust = `N_clust'
	}
	if "`cluster2'"~="" {
		return scalar N_clust1 = `N_clust1'
		return scalar N_clust2 = `N_clust2'
	}
	return scalar N = `N'
	return matrix rkmatrix `rkmatrix'
	return matrix ccorr `ccorr'
	return matrix eval `eval'
	
	tempname S V Omega
	if `K' > 1 {
		foreach en of local y {
* Remove "." from equation name
			local en1 : subinstr local en "." "_", all
			foreach vn of local z {
				local cn "`cn' `en1':`vn'"
			}
		}
	}
	else {
		foreach vn of local z {
		local cn "`cn' `vn'"
		}
	}

	mat `V'=r(V)
	matrix colnames `V' = `cn'
	matrix rownames `V' = `cn'
	return matrix V `V'
	mat `S'=r(S)
	matrix colnames `S' = `cn'
	matrix rownames `S' = `cn'
	return matrix S `S'

	return local cmd		"ranktest11"
	return local version	`lversion'
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

********************* EXIT IF STATA VERSION < 11 ********************************

* When do file is loaded, exit here if Stata version calling program is < 11.
* Prevents loading of rest of program file (would cause e.g. Stata 10 to crash at Mata).

if c(stata_version) < 11 {
	exit
}

******************** END EXIT IF STATA VERSION < 9 *****************************

*******************************************************************************
*************************** BEGIN MATA CODE ***********************************
*******************************************************************************

version 11.2
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

void s_rkstat(	string scalar vl1,
				string scalar vl2,
				string scalar partial,
				string scalar wvarname,
				string scalar weight,
				scalar wf,
				scalar N,
				scalar cons,
				string scalar touse,
				string scalar LMWald,
				string scalar allrank,
				string scalar nullrank,
				string scalar fullrank,
				string scalar robust,
				string scalar clustvarname,
				string scalar clustvarname2,
				string scalar clustvarname3,
				bw,
				string scalar tvarname,
				string scalar ivarname,
				string scalar tindexname,
				tdelta,
				dofminus,
				string scalar kernel,
				string scalar sw,
				string scalar psd,
				string scalar tempvl1,
				string scalar tempvl2)
{

// iid flag used below
	iid = ((kernel=="") & (robust=="") & (clustvarname==""))

// tempx, tempy and tempz are the Stata names of temporary variables that will be changed by s_rkstat
	tempy=tokens(tempvl1)
	tempz=tokens(tempvl2)
	tempx=tokens(partial)

	st_view(y=.,.,tokens(vl1),touse)
	st_view(z=.,.,tokens(vl2),touse)
	st_view(yhat=.,.,tempy,touse)
	st_view(zhat=.,.,tempz,touse)
	if (partial~="") {
		st_view(x=.,.,tempx,touse)
	}
	st_view(mtouse=.,.,tokens(touse),touse)
	st_view(wvar=.,.,tokens(wvarname),touse)
	noweight=(st_vartype(wvarname)=="byte")

	K=cols(y)							//  count of vars in first varlist
	L=cols(z)							//  count of vars in second varlist
	P=cols(x)							//  count of vars to be partialled out (excluding constant)

// Note that we now use wf*wvar instead of wvar
// because wvar is raw weighting variable and
// wf*wvar normalizes so that sum(wf*wvar)=N.

// Partial out the X variables.
// Note that this includes demeaning if there is a constant,
//   i.e., variables are centered.
	if (cons & P>0) {					//  Vars to partial out including constant
		ymeans = mean(y,wf*wvar)
		zmeans = mean(z,wf*wvar)
		xmeans = mean(x,wf*wvar)
		xy = quadcrossdev(x, xmeans, wf*wvar, y, ymeans)
		xz = quadcrossdev(x, xmeans, wf*wvar, z, zmeans)
		xx = quadcrossdev(x, xmeans, wf*wvar, x, xmeans)
	}
	else if (!cons & P>0) {				//  Vars to partial out NOT including constant
		xy = quadcross(x, wf*wvar, y)
		xz = quadcross(x, wf*wvar, z)
		xx = quadcross(x, wf*wvar, x)
	}
	else {								//  Only constant to partial out = demean
		ymeans = mean(y,wf*wvar)
		zmeans = mean(z,wf*wvar)
	}
//	Partial-out coeffs. Default Cholesky; use QR if not full rank and collinearities present.
//	Not necessary if no vars other than constant
	if (P>0) {
		by = cholqrsolve(xx, xy)
		bz = cholqrsolve(xx, xz)
	}
//	Replace with residuals
	if (cons & P>0) {					//  Vars to partial out including constant
		yhat[.,.] = (y :- ymeans) - (x :- xmeans)*by
		zhat[.,.] = (z :- zmeans) - (x :- xmeans)*bz
	}
	else if (!cons & P>0) {				//  Vars to partial out NOT including constant
		yhat[.,.] = y - x*by
		zhat[.,.] = z - x*bz
	}
	else if (cons) {					//  Only constant to partial out = demean
		yhat[.,.] = (y :- ymeans)
		zhat[.,.] = (z :- zmeans)
	}
	else {								//  no transformations required
		yhat[.,.] = y
		zhat[.,.] = z
	}

	zhzh = quadcross(zhat, wf*wvar, zhat)
	zhyh = quadcross(zhat, wf*wvar, yhat)
	yhyh = quadcross(yhat, wf*wvar, yhat)

//	pihat = invsym(zhzh)*zhyh
	pihat = cholqrsolve(zhzh, zhyh)

// rzhat is F in paper (p. 103)
// iryhat is G in paper (p. 103)
	ryhat=cholesky(yhyh)
	rzhat=cholesky(zhzh)
	iryhat=luinv(ryhat')
	irzhat=luinv(rzhat')
	that=rzhat'*pihat*iryhat

// cc is canonical correlations.  Squared cc is eigenvalues.
	fullsvd(that, ut, cc, vt)
	vt=vt'
	vecth=vec(that)
	ev = cc:^2
// S matrix in paper (p. 100).  Not used in code below.
//	smat=fullsdiag(cc, rows(that)-cols(that))

	if (abs(1-cc[1,1])<1e-10) {
printf("\n{text:Warning: collinearities detected between (varlist1) and (varlist2)}\n")
	}
	if ((missing(ryhat)>0) | (missing(iryhat)>0) | (missing(rzhat)>0) | (missing(irzhat)>0)) {
printf("\n{error:Error: non-positive-definite matrix. May be caused by collinearities.}\n")
		exit(error(3351))
	}

// If Wald, yhat is residuals
	if (LMWald=="Wald") {
		yhat[.,.]=yhat-zhat*pihat
		yhyh = quadcross(yhat, wvar, yhat)
	}

// Covariance matrices
// vhat is W in paper (eqn below equation 17, p. 103)
// shat is V in paper (eqn below eqn 15, p. 103)

// ************************************************************************************* //
// shat calculated using struct and programs m_omega, m_calckw shared with ivreg2        //

	struct ms_vcvorthog scalar vcvo


	vcvo.ename			= tempy		// ivreg2 has = ename //
	vcvo.Znames			= tempz		// ivreg2 has = Znames //
	vcvo.touse			= touse
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
	vcvo.ZZ				= zhzh		// ivreg2 has = st_matrix(ZZmatrix) //
	
	vcvo.e		= &yhat				// ivreg2 has = &e	//
	vcvo.Z		= &zhat				// ivreg2 has = &Z //
	vcvo.wvar	= &wvar

	shat=m_omega(vcvo)

// ***************************************************************************************

// prepare to start collecting test stats
	if (allrank~="") {
		firstrank=1
		lastrank=min((K,L))
	}
	else if (nullrank~="") {
		firstrank=1
		lastrank=1
	}
	else if (fullrank~="") {
		firstrank=min((K,L))
		lastrank=min((K,L))
	}
	else {
// should never reach this point
printf("ranktest error\n")
		exit
	}

// where results will go
	rkmatrix=J(lastrank-firstrank+1,6,.)

// ***************************************************************************************
// Calculate vector of canonical correlations test statistics.
// All we need if iid case.
	rkvec = ev									//  Initialize vector with individual eigenvalues.
	if (LMWald~="LM") {							//  LM is sum of min evals, Wald is sum of eval/(1-eval)
		rkvec = rkvec :/ (1 :- rkvec)
	}
	for (i=(rows(rkvec)-1); i>=1; i--) {		//  Now loop through and sum the eigenvalues.
		rkvec[i,1] = rkvec[i+1,1] + rkvec[i,1]
	}
	rkvec = N*rkvec								//  Multiply by N to get the test statistics.

// ***************************************************************************************

// Finally, calcluate vhat	
	if ((LMWald=="LM") & (iid)) {
// Homoskedastic, iid LM case means vcv is identity matrix
// Generates canonical correlation stats.  Default.
		vhat=I(L*K,L*K)/N
	}
	else {
		vhat=(iryhat'#irzhat')*shat*(iryhat'#irzhat')' * N
		_makesymmetric(vhat)
// Homoskedastic iid Wald case means vcv has block-diag identity matrix structure.
// Enforce this by setting ~0 entries to 0.  If iid, vhat not used in calcs, for reporting only.
		if ((LMWald=="Wald") & (iid)) {
			vhat = vhat :* (J(K,K,1)#I(L))
		}
	}

// ***************************************************************************************
// Loop through ranks and collect test stats, dfs, p-values, ranks, evs and ev^2 (=ccs)

	for (i=firstrank; i<=lastrank; i++) {
		if (iid) {							//  iid case = canonical correlations test
			rk = rkvec[i,1]
			}
		else {								//  non-iid case
			if (i>1) {
				u12=ut[(1::i-1),(i..L)]
				v12=vt[(1::i-1),(i..K)]
			}
			u22=ut[(i::L),(i..L)]
			v22=vt[(i::K),(i..K)]
			
			symeigensystem(u22*u22', evec, eval)
			u22v=evec
			u22d=diag(eval)
			u22h=u22v*(u22d:^0.5)*u22v'
	
			symeigensystem(v22*v22', evec, eval)
			v22v=evec
			v22d=diag(eval)
			v22h=v22v*(v22d:^0.5)*v22v'
	
			if (i>1) {
				aq=(u12 \ u22)*luinv(u22)*u22h
				bq=v22h*luinv(v22')*(v12 \ v22)'
			}
			else {
				aq=u22*luinv(u22)*u22h
				bq=v22h*luinv(v22')*v22'
			}
	
// lab is lambda_q in paper (eqn below equation 21, p. 104)
// vlab is omega_q in paper (eqn 19 in paper, p. 104)
			lab=(bq#aq')*vecth
			vlab=(bq#aq')*vhat*(bq#aq')'
	
// Symmetrize if numerical inaccuracy means it isn't
			_makesymmetric(vlab)
			vlabinv=invsym(vlab)
// rk stat Assumption 2: vlab (omega_q in paper) is nonsingular.  Detected by a zero on the diagonal,
// since when returning a generalized inverse, Stata/Mata choose the generalized inverse that
// sets entire column(s)/row(s) to zeros.
			if (diag0cnt(vlabinv)>0) {
				rk = .
printf("\n{text:Warning: covariance matrix omega_%f}", i-1)
printf("{text: not full rank; test of rank %f}", i-1)
printf("{text: unavailable}\n")
			}
// Note not multiplying by N - already incorporated in vhat.
			else {
				rk=lab'*vlabinv*lab
			}
		}												//  end non-iid case
// at this point rk has value of test stat
// fill out rest of row of rkmatrix
// save df, rank, etc. even if test stat not available.
		df=(L-i+1)*(K-i+1)
		pvalue=chi2tail(df, rk)
		rkmatrix[i-firstrank+1,1]=rk
		rkmatrix[i-firstrank+1,2]=df
		rkmatrix[i-firstrank+1,3]=pvalue
		rkmatrix[i-firstrank+1,4]=i-1
		rkmatrix[i-firstrank+1,5]=ev[i-firstrank+1,1]
		rkmatrix[i-firstrank+1,6]=cc[i-firstrank+1,1]
// end of test loop
	}

// ***************************************************************************************
// Finish up and return results

	st_matrix("r(rkmatrix)", rkmatrix)
	st_matrix("r(ccorr)", cc')
	st_matrix("r(eval)",ev')
// Save V matrix as in paper, without factor of 1/N
	vhat=N*vhat*wf
	st_matrix("r(V)", vhat)
// Save S matrix as in ivreg2, with factor of 1/N
	st_matrix("r(S)", shat)
	st_numscalar("r(N)", N)
	if (clustvarname~="") {
		st_numscalar("r(N_clust)", N_clust)
	}
	if (clustvarname2~="") {
		st_numscalar("r(N_clust2)", N_clust2)
	}
// end of program
}

// Mata utility for sequential use of solvers
// Default is cholesky;
// if that fails, use QR;
// if overridden, use QR.

function cholqrsolve (	numeric matrix A,
						numeric matrix B,
						| real scalar useqr)
{
	if (args()==2) useqr = 0
	
	real matrix C

	if (!useqr) {
		C = cholsolve(A, B)
		if (C[1,1]==.) {
			C = qrsolve(A, B)
		}
	}
	else {
		C = qrsolve(A, B)
	}

	return(C)

}

end

* Version notes
* 1.0.00  First distributed version
* 1.0.01  With iweights, rkstat truncates N to mimic official Stata treatment of noninteger iweights
*         Added warning if shat/vhat/vlab not of full rank.
* 1.0.02  Added NULLrank option
*         Added eq names to saved V and S matrices
* 1.0.03  Added error catching for collinearities between varlists
*         Not saving S matrix; V matrix now as in paper (without 1/N factor)
*         Statistic, p-value etc set to missing if vcv not of full rank (Assumpt 2 in paper fails)
* 1.0.04  Fixed touse bug - was treating missings as touse-able
*         Change some cross-products in robust loops to quadcross
* 1.0.05  Fixed bug with col/row names and ts operators.  Added eval to saved matrices.
* 1.1.00  First ssc-ideas version.  Added version 9.2 prior to Mata compiled section.
* 1.1.01  Allow non-integer bandwidth
* 1.1.02  Changed calc of yhat, zhat and pihat to avoid needlessly large intermediate matrices
*         and to use more accurate qrsolve instead of inverted X'X.
* 1.1.03  Fixed touse bug that didn't catch missing cluster variable
*         Fixed cluster bug - data needed to be sorted by cluster for Mata panel functions to work properly
* 1.2.00  Changed reporting so that gaps between panels are not reported as such.
*         Added support for tdelta in tsset data.
*         Changed tvar and ivar setup so that data must be tsset or xtset.
*         Removed unnecessary loops through panel data with spectral kernels
*         shat vcv now also saved.
*         Added support for Thompson/Cameron-Gelbach-Miller 2-level cluster-robust vcvv
*         Added support for Stock-Watson vcv - but requires data to have FEs partialled out, & doesn't support fweights
*         Removed mimicking of Stata mistake of truncated N with iweights to nearest integer
*         Fixed small bug with quadratic kernel (wasn't using negative weights)
*         Optimised code dealing with time-series data
* 1.2.01  Fixed bug that always used Stock-Watson spectral decomp to create invertible shat
*         instead of only when (undocumented) spsd option is called.
* 1.2.02  Fixed bug that did not allow string cluster variables
* 1.2.03  Fixed bug in code for cluster+kernel robust (typo in imported code from ivreg2=>crash)
* 1.2.04  Replaced code for S with ivreg2 code modified to support e matrix (cols > 1)
*         Code block (m_omega, m_calckw, struct definition) now shared by ranktest and ivreg2.
*         Renamed spsd option to psd following ivreg2 3.0.07
*         Added wf ("weight factor") and statement about sum of weights, as in ivreg2
*         Added dofminus option, as in ivreg2
*         Fixed minor reporting bug - was reporting gaps in entire panel, not just touse-d portion
*         Recoded kernel & bw checks to use shared ivreg2 subroutine vkernel
* 1.2.05  Fixed weighting bug introduced in 1.2.04.  All weights were affected.
*         Was result of incompatibility of code shared with ivreg2.
* 1.3.01  First ranktest version with accompanying Mata library (shared with -ivreg2-).
*         Mata library includes struct ms_vcvorthog, m_omega, m_calckw, s_vkernel.
*         Fixed bug in 2-way cluster code (now in m_omega in Mata library) - would crash if K>1.
* 1.3.02  Improved partialling out and matrix inversion - switched from qrsolve to invsym.
*         Use _makesymmetric() instead of symmetrizing by hand.
* 1.3.03  01Jan14. Fixed reporting bug with 2-way clustering and kernel-robust that would give
*         wrong count for 2nd cluster variable.
* 1.3.04  24Aug14. Fixed bug in markout - would include obs where some vars were missing
* 1.3.05  22Jan15. Promotion to version 11.2; forks to ranktest9 if version<=10; requires
*         capture before "version 11.2" in Mata section since must load before forking.
*         Renamed subroutine rkstat to s_rkstat.
* 1.4.01  16Aug15.  Pass cons flag to Mata code.  Added cholqrsolve() utility (use qr if chol fails).
*         Partial code rewritten to use centering and cholqrsolve.  pihat uses cholqrsolve.
*         Separate code for iid and non-iid cases (faster, more accurate for iid case).
*         Fixed bug in naming rows/cols of saved V and S matrices (wasn't unab-ing the varlists).
*         Updated undocumented psd options psd0 and psda.  Tweaked cluster count code to match ivreg2.
*         Added r(version) and r(cmd) macros.
