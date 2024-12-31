* Version 1.5 - 7 Jan 2012
* By J.M.C. Santos Silva 
* Please email jmcss@essex.ac.uk for help and support

* The software is provided as is, without warranty of any kind, express or implied, including 
* but not limited to the warranties of merchantability, fitness for a particular purpose and 
* noninfringement. In no event shall the author be liable for any claim, damages or other 
* liability, whether in an action of contract, tort or otherwise, arising from, out of or in 
* connection with the software or the use or other dealings in the software.



program define scls, eclass                                                                                   
version 10.0  
 
syntax varlist [if] [in] [, ITERate(integer 16000)  TOLerance(real 1e-6) NOLog Powell Start(string)] 


marksample touse                                               
tempname _y _rhss b_w _fit _fitp _ofi  _us  _w _gv _bt  A B 
gettoken _y _rhs: varlist  

_rmcoll `_rhs' if `touse'
local _rhss "`r(varlist)'"

if ("`start'" == "clad")|("`start'" == ""){
	qui probit `_y' `_rhss' if (`touse')
	local rank1=e(df_m)+1
	local N=e(N)
	qui predict `_fit' if (`touse'), p
	qui qreg `_y' `_rhss' if (`touse')&(`_fit'>0.55)
	drop `_fit'
}
if ("`start'" == "ols"){
	qui reg `_y'  `_rhss' if (`touse'), robust
	local rank1=e(rank)
	local N=e(N)
}
if ("`start'" == "tobit"){
	qui tobit `_y'  `_rhss' if (`touse'), ll
	local rank1=e(rank)-1
	local N=e(N)
}
qui predict `_fit' if (`touse'), xb
mat `b_w'=e(b)
mat `b_w'=`b_w'[1,1..`rank1']
if ("`start'" == "ols")|("`start'" == "") mat `B'=(invsym(e(V)))
else mat `B'=I(`rank1')
qui g double `_ofi'= (((`_y'-max(0.5*`_y',`_fit'))^2)+(`_y'>2*`_fit')*((0.5*`_y')^2-(max(0,`_fit'))^2) )/`N' if (`touse')
qui su `_ofi' if (`touse')
local _objfn = r(mean)*r(N)
local _crit=exp(88)
qui g double `_w'=1
qui g double `_us'=0
local iter=0
local bk=0

if ("`nolog'" == "") di

while ((`_crit'>`tolerance')&(`iter'<`iterate')){
	local iter=`iter'+1
	local bk=0
	qui replace `_w'=1 
	if ("`powell'" == "") qui replace `_w'=sign(2*`_fit'-`_y') if (`touse')
	qui replace `_us'=(`_y'*(`_y'<2*`_fit')+2*`_fit'*(`_y'>=2*`_fit')-`_fit')*`_w' if (`touse')
	qui reg  `_us' `_rhss' if (`_fit'>0)&(`touse') [iw=`_w']
	qui predict `_fitp' if (`touse'), xb 
	mat `_bt'=e(b)
	local rank=e(rank)
	qui count if (`_fit'>0)&(`touse')
	local n=r(N)
	qui replace `_ofi'= (((`_y'-max(0.5*`_y',`_fit'+`_fitp'))^2)+(`_y'>2*(`_fit'+`_fitp'))*((0.5*`_y')^2-(max(0,`_fit'+`_fitp'))^2) )/`N' if (`touse')
	qui su `_ofi' if (`touse')
	

	if ("`powell'" == "")*((`_objfn'*(1+1e-8) < r(mean)*r(N))|(`rank' < `rank1')){
		local bk=1
		drop `_fitp'
		qui replace `_w'=1 
		qui replace `_us'=(`_y'*(`_y'<2*`_fit')+2*`_fit'*(`_y'>=2*`_fit')-`_fit')*`_w' if (`touse')
		qui reg  `_us' `_rhss' if (`_fit'>0)&(`touse') [iw=`_w']
		qui predict `_fitp' if (`touse'), xb 
		mat `_bt'=e(b)
		local rank=e(rank)
		qui count if (`_fit'>0)&(`touse')
		local n=r(N)
		qui replace `_ofi'= (((`_y'-max(0.5*`_y',`_fit'+`_fitp'))^2)+(`_y'>2*(`_fit'+`_fitp'))*((0.5*`_y')^2-(max(0,`_fit'+`_fitp'))^2) )/`N' if (`touse')
		qui su `_ofi' if (`touse')
	}
	local _objfn = r(mean)*r(N)
	mat `A'=e(b)*`B'*e(b)'
	local _crit = `A'[1,1]
	if ("`nolog'" == "") {
		di as txt "Iteration: " `iter' _continue
		di as txt  _column(17) "objective function = "  _continue
		di as result `_objfn'  _continue
		di as txt  _column(48) " crit = "  _continue
		di as result `_crit' _continue
		if `bk'==1 {
			di as txt _column(65) "  (backed up)" 
		}
		else di ""
	}
	mat `b_w'=`b_w'+`_bt'
	qui replace `_fit'=`_fit'+`_fitp' if (`touse')
	drop `_fitp'
}
di
local converged=1
if (`iter' >= `iterate')&(`_crit'>`tolerance'){ 
	di as error "WARNING: Convergence not achieved in " `iter' " iterations"
	di
	local converged=0
}
if (`rank1' > `rank') {
	 di as error "WARNING: Rank deficiency"
	 di
}	 
qui replace `_us'=(`_y'*(`_y'<2*`_fit')+2*`_fit'*(`_y'>=2*`_fit')-`_fit') if (`touse')
qui g `_gv'=_n if (`touse')
qui sort `_gv' 
qui matrix accum `A' = `_rhss' if (`_y'>0)&(`_y'<2*`_fit')&(`touse')
qui matrix opaccum `B' = `_rhss' if (`_fit'>0)&(`touse'), group(`_gv') opvar(`_us') 
qui mat `A'=(invsym(`A'))*`B'*(invsym(`A'))

ereturn post `b_w' `A', obs(`N') e(`touse') dep("`_y'")
ereturn scalar n=`n'
ereturn scalar obj_fn=`_objfn'
ereturn scalar crit=`_crit'
ereturn scalar rank=`rank'
ereturn scalar iter=`iter'
ereturn scalar converged=`converged'

ereturn local predict = "regres_p"
ereturn local cmd = "scls"
ereturn local marginsok= "XB default"
ereturn local title = "Symmetrically Censored Least Squares"
ereturn local vcetype = "Robust"

di as txt "Number of obs = " _continue
di as result `N' _continue
di as txt "    Number of used obs = " _continue 
di as result `n'
ereturn display
end

