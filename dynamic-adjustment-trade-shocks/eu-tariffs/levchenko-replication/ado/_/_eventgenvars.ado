version 11.2

cap program drop _eventgenvars
program define _eventgenvars, rclass

	#d;

	syntax [anything] [if] [in], 
	Panelvar(varname) /* Panel variable */	
	Timevar(varname) /* Time variable */
	POLicyvar(varname) /* Policy variable */
	[
	LWindow(real 0)
	RWindow(integer 0) /* Estimation window. Need to set a default, but it has to be based on the dataset */
	/* since lwindow and rwindow are now optional, a default value must be provided*/
	norm(numlist) /* Coefficients to normalize */
	
	impute(string) /*impute policyvar. There are three options: */
	/*nuchange  imputes outer missing values of policyvar without verifying staggered adoption*/
	/*stag  imputes outer missing values of policyvar verifying staggered adoption*/
	/*instag  imputes outer and inner missing values verifying staggered adoption*/
	STatic /* Estimate static model */
	rr(name) /*return imputed policyvar as temporary variable. For use of _eventiv*/
	trcoef(real 0) /*inferior limit to start the trend*/
	methodt(string) /* method for the trend computation*/
	

	
	]	
	;
	#d cr	
	
	tempvar mz kg
	
	marksample touse
	
	* mz maximum of policy outside window
	* kg grouped event time variable, grouping dummies outside window
	
	loc z = "`policyvar'"

	if "`static'"==""{
		* Get span of calendar time
		qui su `timevar' if `touse', d
		loc tmin=r(min)
		loc tmax=r(max)
		loc tdiff = `tmax'-`tmin'
		
		* Using notation from latest draft: https://jorgeperezperez.com/files/EventStudy.pdf 
		
		* Endpoints are left: G+L+1
		* Right: M+1
		
		* Left window is G+L
		* Right window is M 
		
		* If you have t=-3 -2 -1 0 1 2 3, tdiff=6 then the maximum window size you can have is 2 on each side
		* If you have t=-3 -2 -1 0 1 2 3 4, tdiff=7 then the maximum window size you can have is 2 left, 3 right
			
		
		* Error check for window outside event time range
		if abs(`lwindow') > `=abs(`tdiff')-1' | abs(`rwindow') > `=abs(`tdiff')-1' {
			di as err _n "Window outside event-time range."
			exit 301
		}
		
		* Error check for trend event time range
		if "`trcoef'"=="." loc trcoef ""
		if "`trcoef'"!="" {
			if abs(`trcoef') > `=abs(`tdiff')-1' {
				di as err _n "Trend outside time range."
				exit 301
			}
					
			* Error check for trend outside window
			if abs(`trcoef')>abs(`lwindow') {
				di as err _n "Trend outside window range."
				exit 301
			}
		}
		
		* Check for vars named _k
		cap unab oldkvars : _k*
		if !_rc {
			di as err _n "You have variable names with the _k prefix. _k is reserved for internal -xtevent- variables."
			di as err _n "Please rename these variables before proceeding."
			exit 110
		}
		
	}
	
	*parse impute option
	if "`impute'"!=""{
		parseimpute `impute'
		loc impute = r(impute)
		loc saveimp = r(saveimp)
		if "`saveimp'"=="." loc saveimp ""
	}
	
	* Check for a variable named as the imputed policyvar
	if "`saveimp'"!="" {
		cap unab oldkvars : `policyvar'_imputed
		if !_rc {
			di as err _n "You have a variable named `policyvar'_imputed. This name is reserved for the imputed policy variable."
			di as err _n "Please drop or rename this variable before proceeding."
			exit 110
		}
	}
	
	* Check for a valid option in impute
	if "`impute'"!=""{
		cap assert "`impute'"=="nuchange" | "`impute'"=="stag" | "`impute'"=="instag"
		if _rc {
			di as err _n "{bf:`impute'} not allowed in option {bf:impute}."
			exit 110
		}
	}

	********************* find first and last observed values *********************

	*find minimum valid time (time where there is a no-missing observation)
	tempvar zmint zmint2 zminv zminv2 zmaxt zmaxt2 zmaxv zmaxv2
	qui{
		by `panelvar' (`timevar'): egen long `zmint'=min(`timevar') if !missing(`z') & `touse'	
		by `panelvar' (`timevar'): egen long `zmint2'=min(`zmint')
		*find the corresponding minimum valid value
		by `panelvar' (`timevar'): gen double `zminv'=`z' if `timevar'==`zmint2' 
		by `panelvar' (`timevar'): egen double `zminv2'=min(`zminv')

		*find maximum valid time
		by `panelvar' (`timevar'): egen long `zmaxt'=max(`timevar') if !missing(`z') & `touse'
		by `panelvar' (`timevar'): egen long `zmaxt2'=max(`zmaxt')
		*find the corresponding maximum valid value
		by `panelvar' (`timevar'): gen double `zmaxv'=`z' if `timevar'==`zmaxt2' 
		by `panelvar' (`timevar'): egen double `zmaxv2'=max(`zmaxv')
	}
	*create a copy of z. If imputation happens, it will be on this copy
	tempvar zn2  
	qui gen double `zn2'=`z'
	

	********** Verify consistency with staggered adoption *******************
	 
	loc bin 0
	loc norever 0
	loc bounds 0
	* show a warning message if we don't know treatment time for some units due to missing values in policyvar 
	if ("`impute'"=="stag" | "`impute'"=="instag") {
	
		tempvar zwd zwu seq
		qui gen double `zwd'=`z' if `touse'
		qui by `panelvar' (`timevar'): replace `zwd'=`zwd'[_n-1] if missing(`z') & `timevar'>=`zmint2' & `timevar'<=`zmaxt2' & `touse'
		qui gen double `zwu'=`z' if `touse'
		sort `panelvar' `timevar'
		qui by `panelvar': gen int `seq' = -_n
		sort `panelvar' `seq'
		qui by `panelvar': replace `zwu'=`zwu'[_n-1] if missing(`z') & `timevar'>=`zmint2' & `timevar'<=`zmaxt2' & `touse'
		sort `panelvar' `timevar'
		cap assert `zwd'==`zwu' if missing(`z') & `timevar'>=`zmint2' & `timevar'<=`zmaxt2' & `touse'
		if _rc{
			di "Event time is unknown for some units due to missing values in policyvar."
		}
	}
	
	***************** verify whether policyvar is binary *******************
	
	****** Check if z is binary
	cap assert inlist(`z',0,1,.) if `touse'
	if _rc {
		qui su `z' if `touse'
		loc rminz=`=r(min)'
		loc rmaxz=`=r(max)'
		cap assert inlist(`z',`rminz',`rmaxz',.)
		if !_rc {
			if ("`impute'"=="stag" | "`impute'"=="instag"){
				di "Policyvar is binary, but its values are different from 0 and 1. Assuming `=r(min)' as the unadopted policy state and `=r(max)' as the adopted policy state."
			}
			loc bin 1
		}
		else loc bin 0
	}
	else {
		loc rminz=0
		loc rmaxz=1
		loc bin 1
	}

	* If not binary, return to default 
	if `bin'==0 & ("`impute'"=="stag" | "`impute'"=="instag") {
			
		di "The policy variable is not binary. Assuming non-staggered adoption (no imputation)."
		di "If event dummies and variables are saved, event-time will be missing."	
		loc impute =""
	}
		
	*********** verify no reversion  ****************************
	*(e.g. if binary 0 and 1, once reached 1, never returns to zero)
	
		tempvar zr zn l1
		qui gen double `zr'=`z'
		*where there are missings, impute the previous value
		qui by `panelvar' (`timevar'): replace `zr'=`zr'[_n-1] if missing(`zr') & `timevar'>=`zmint2' & `timevar'<=`zmaxt2' 
		
		qui by `panelvar' (`timevar'): gen byte `l1'= (F1.`zr'>=`zr') if !missing(`zr') & !missing(F1.`zr') & `touse'
		cap assert `l1'==1 if !missing(`l1')
		if ! _rc{
			loc norever 1
		}
	
	
		if `norever'==0 & ("`impute'"=="stag" | "`impute'"=="instag") {
			di "Policyvar changes more than once for some units. Assuming non-staggered adoption (no imputation)."
			loc impute=""
		}

		****** if no-reversion holds, verify "bounds" condition: e.g. if binary 0 and 1, verify 0 as the first observed value and 1 as the last observed value
	if ("`impute'"=="stag" | "`impute'"=="instag") {
		tempvar notmiss zt minzt maxzt
		qui{
			gen byte `notmiss'=!missing(`z')
			
			by `panelvar' (`timevar'): gen long `zt'=`timevar' if `notmiss'==1 
			by `panelvar' (`timevar'): egen long `maxzt'=max(`zt') 
			by `panelvar' (`timevar'): egen long `minzt'=min(`zt')
		}
		*first filter: all units satisfy the bounds condition? 
		if `bin'==1 & `norever'==1 {
			*verify the lower-bound value
			cap assert `z'==`rminz' if `minzt'==`timevar' & `touse'
			* if the lower-bound value is zero, then test the upper-bound
			if !_rc{
				cap assert `z'==`rmaxz' if `maxzt'==`timevar' & `touse'
				if !_rc loc bounds 1
			} 
		}
		
		*second filter: if some units didn't satisfy the first filter, then allow those units to have only adopted policy or only unadopted policy (and no missing values inside the observed range)
		if `bin'==1 & `norever'==1 & `bounds'==0 {
		
		tempvar ilb iub sb sbmin
		qui{
			by `panelvar' (`timevar'): gen byte `ilb'=(`z'==`rminz') if `minzt'==`timevar' & `touse'
			by `panelvar' (`timevar'): gen byte `iub'=(`z'==`rmaxz') if `maxzt'==`timevar' & `touse'
			egen byte `sb'=rowtotal(`ilb' `iub') if (`minzt'==`timevar' | `maxzt'==`timevar')
		
			*sbmin is an indicator of the units that satisfied the first filter 
			by `panelvar' (`timevar'): egen byte `sbmin'=min(`sb') if `timevar'>=`zmint2' & `timevar'<=`zmaxt2' & `touse'
		}
		cap assert inlist(`z',`rminz',`rmaxz') if `sbmin'==0
		if !_rc loc bounds 1
		}
	
	
		if `bounds'==0 & ("`impute'"=="stag" | "`impute'"=="instag") {
				di "For some units, the changes in policyvar are not consistent with no-unobserved-change. Reverting to default (no imputation)."
				loc impute =""	
		}
	}
	
	***************** apply no unobserved change ***************************

	if "`impute'"!="" {
		qui replace `zn2'=`zminv2' if `timevar'<`zmint2'
		qui replace `zn2'=`zmaxv2' if `timevar'>`zmaxt2'
	}

	************** impute inner missing values ***********************
	if "`impute'"=="instag" {
		
		tempvar zdown zup seq2
		qui gen double `zdown'=`z'
		sort `panelvar' `timevar'
		qui replace `zdown'=`zdown'[_n-1] if missing(`zdown')
		qui gen double `zup'=`z'
		sort `panelvar' `timevar'
		qui by `panelvar': gen int `seq2' = -_n
		sort `panelvar' `seq2'
		qui replace `zup'=`zup'[_n-1] if missing(`zup')
		sort `panelvar' `timevar'
		
		qui replace `zn2'=`zdown' if `timevar'>=`zmint2' & `timevar'<=`zmaxt2' & missing(`z') & `zdown'==`zup'
		
	}

****************************** event-time dummies ***********************
	if "`static'"==""{
		qui xtset `panelvar' `timevar', noquery
		
		qui sort `panelvar' `timevar', stable
			
		* Generate event time dummies 
		
		*create z delta
		tempvar zd 
		qui gen double `zd'=`zn2'- L1.`zn2'
		
		*observed data range
		tempvar minz maxz minz2 maxz2 
		qui by `panelvar' (`timevar'): egen long `minz'=min(`timevar') if !missing(`zn2')
		qui by `panelvar' (`timevar'): egen long `minz2'=min(`minz')
				
		qui by `panelvar' (`timevar'): egen long `maxz'=max(`timevar') if !missing(`zn2')
		qui by `panelvar' (`timevar'): egen long `maxz2'=max(`maxz')
		
		qui forv klevel=`lwindow'(1)`rwindow' {
			loc absk = abs(`klevel')
			
			if `klevel'<0 { 
				loc plus = "m"
				qui {
					by `panelvar' (`timevar'): gen double _k_eq_`plus'`absk'=F`absk'.`zd' if ((`timevar'>=`minz2') & (`timevar'<=`maxz2')) & `touse'
					la var _k_eq_`plus'`absk' "Event-time = - `absk'"
					*this to impute zeros and complete the observed range
					tempvar minp minp2 maxp maxp2
					if "`impute'"!=""{
						by `panelvar' (`timevar'): egen long `minp'=min(`timevar') if !missing(_k_eq_`plus'`absk')
						by `panelvar' (`timevar'): egen long `minp2'=min(`minp')
						by `panelvar' (`timevar'): egen long `maxp'=max(`timevar') if !missing(_k_eq_`plus'`absk')
						by `panelvar' (`timevar'): egen long `maxp2'=max(`maxp')
						by `panelvar' (`timevar'): replace _k_eq_`plus'`absk'=0 if missing(_k_eq_`plus'`absk') & ((`timevar' < `minp2') & (`timevar' >= `minz2')) | ((`timevar' > `maxp2') & (`timevar' <= `maxz2')) &  `touse'
					}
				}
			}		
			else {
				loc plus "p" 
				qui {
					by `panelvar' (`timevar'): gen double _k_eq_`plus'`absk'=L`absk'.`zd' if ((`timevar'>=`minz2') & (`timevar'<=`maxz2')) & `touse'
					la var _k_eq_`plus'`absk' "Event-time = + `absk'"
					*this to impute zeros and complete the observed range 
					cap drop `minp' `minp2' `maxp' `maxp2' 
					if "`impute'"!=""{
						by `panelvar' (`timevar'): egen long `minp'=min(`timevar') if !missing(_k_eq_`plus'`absk')
						by `panelvar' (`timevar'): egen long `minp2'=min(`minp')
						by `panelvar' (`timevar'): egen long `maxp'=max(`timevar') if !missing(_k_eq_`plus'`absk')
						by `panelvar' (`timevar'): egen long `maxp2'=max(`maxp')
						by `panelvar' (`timevar'): replace _k_eq_`plus'`absk'=0 if missing(_k_eq_`plus'`absk') & ((`timevar' < `minp2') & (`timevar' >= `minz2')) | ((`timevar' > `maxp2') & (`timevar' <= `maxz2')) &  `touse'
					}
				}
			}
			
		}

		
		* Generate event time
		* To fix: If multiple events, should generate all.
		qui {
			if (`bin'==1 & `norever'==1) {
				tempvar __kmax p0mink
				gen long __k=.
				by `panelvar' (`timevar'): egen long `p0mink'=min(`timevar') if _k_eq_p0!=0 & !missing(_k_eq_p0)
				by `panelvar' (`timevar'): egen long `__kmax'=max(`p0mink') 
				replace __k = `timevar' - `__kmax'
				order _k* __k, after(`zd')
				/* we only create the event time variable when we only have one event per unit. */
			}
			else {
				qui gen byte __k=.
			}
		}
		
					
		* Error check for window outside event time range
		qui sum __k if `touse'
		if `=-`lwindow'+1' > abs(r(min)) | `=`rwindow'+1' > abs(r(max)) {
			di as err _n "Window outside event-time range"
			qui drop _k*
			qui drop __k
			exit 301
		}
			
		
		* Generate endpoint dummies
		* Left
		* -6 : z lead 6
		* +5 : z lag 5
		
		* Absorbing version
		if "`impute'"!="" { 
			qui {
				* Left
				gen double _k_eq_m`=-`lwindow'+1' = (1-f`=-`lwindow''.`zn2') if ((`timevar'>=`minz2') & (`timevar'<=`maxz2')) & `touse' 
				*find maximum valid time for left endpoint
				tempvar maxl maxl2
				by `panelvar' (`timevar'): egen long `maxl'=max(`timevar') if !missing(_k_eq_m`=-`lwindow'+1')
				by `panelvar' (`timevar'): egen long `maxl2'=max(`maxl')
				*replace with zeros (the last observed for the endpoint)
				replace _k_eq_m`=-`lwindow'+1' = _k_eq_m`=-`lwindow'+1'[_n-1] if _k_eq_m`=-`lwindow'+1' == . & (`timevar'>`maxl2') & (`timevar'<=`maxz2') & `touse'
				order _k_eq_m`=-`lwindow'+1', before(_k_eq_m`=-`lwindow'')
				
				* Right
				tempvar seq3
				gen double _k_eq_p`=`rwindow'+1'= l`=`rwindow'+1'.`zn2' if ((`timevar'>=`minz2') & (`timevar'<=`maxz2')) & `touse'
				*find minimun valid time for right endpoint 
				tempvar minr minr2 
				by `panelvar' (`timevar'): egen long `minr'=min(`timevar') if !missing(_k_eq_p`=`rwindow'+1') & `touse'
				by `panelvar' (`timevar'): egen long `minr2'=min(`minr')
				*replace missing values in the upper-right corner			
				sort `panelvar' `timevar'
				by `panelvar': gen int `seq3' = -_n
				sort `panelvar' `seq3'
				by `panelvar': replace _k_eq_p`=`rwindow'+1'=_k_eq_p`=`rwindow'+1'[_n-1] if (`timevar'>=`minz2') & (`timevar'<`minr2') & `touse'
				sort `panelvar' `timevar'
				order __k, after(_k_eq_p`=`rwindow'+1')			
			}	
		}
		* Not absorbing version
		else {
			qui {
				* Left
				gen double _k_eq_m`=-`lwindow'+1' = (1-f`=-`lwindow''.`zn2') if ((`timevar'>=`minz2') & (`timevar'<=`maxz2')) & `touse'
				order _k_eq_m`=-`lwindow'+1', before(_k_eq_m`=-`lwindow'')
				* Right
				gen double _k_eq_p`=`rwindow'+1'= l`=`rwindow'+1'.`zn2' if ((`timevar'>=`minz2') & (`timevar'<=`maxz2')) & `touse'			
				order __k, after(_k_eq_p`=`rwindow'+1')
			}
		}
		
		
		la var _k_eq_m`=-`lwindow'+1' "Event time <= - `=-`lwindow'+1'"
		la var _k_eq_p`=`rwindow'+1' "Event time >= + `=`rwindow'+1'"
		
		* Drop units where treatment can not be timed
		
		* If z is binary, check if event-time is missing
		if `bin' & `norever' {
			cap assert __k !=. if `touse'
			* If it is, check for which units
			if _rc {
				tempvar etmis etmismax minz
				qui {
					gen byte `etmis' = (__k==.) & `touse'
					by `panelvar' : egen byte `etmismax' = max(`etmis') if `touse'
					by `panelvar' : egen double `mz' = max(`z') if `touse'
					by `panelvar' : egen double `minz' = min(`z') if `touse'
				}
				* Exclude units with missing event-time
				foreach x of varlist _k_eq* {
					qui replace `x' = . if `etmismax'==1 & `mz'>0 & `minz'==0 & `touse'
				}
				qui replace __k = . if `etmismax'==1 & `touse'
				qui levelsof `panelvar' if `etmismax'==1 & `mz'>0 & `minz'==0 & `touse', loc(mis)
				foreach j in `mis' {
					di as txt _n "Unit `j' not used because of ambiguous event-time due to missing values in policyvar."
				}
				qui replace `touse' = 0 if `etmismax'==1 & `mz'>0 & `minz'==0 & `touse'			
			}
		}	
		
			
		* Set omitted variable.
		unab included : _k*
		loc toexc ""
		foreach j in `norm' {
			loc abs = abs(`j')
			if `j'<0 loc toexc "`toexc' _k_eq_m`abs'"
			else if `j'>=0 loc toexc "`toexc' _k_eq_p`abs'"
		}
		loc included: list local included - toexc
		
		* Group k
		qui gen long `kg' = __k if `touse'
		* Group if outside window
		qui replace `kg' = `=`lwindow'-1' if __k < `=`lwindow'' & `touse'
		qui replace `kg' = `=`rwindow'+1' if __k >= `rwindow' & `touse'
		qui levelsof `kg', loc(kgs)
		
		* If extrapolating a linear trend, exclude some of the event time dummies
		loc komittrend ""
		* di "`included'"
		if "`methodt'" == "ols" {
			if `bin'!=1 | `norever'!=1 {
				di as err _n "Method ols cannot extrapolate linear trend using a policyvar that is not binary or has multiple events. Use GMM instead."
				exit 301
			}
		
			* Generate the trend		
			qui gen int _ttrend = __k  if `touse'	
			qui replace _ttrend = 0 if !inrange(_ttrend,`lwindow',`=`rwindow'') & `touse'
			* qui replace _ttrend = 0 if _ttrend<`=`trend'' & `touse'
			qui replace _ttrend = 0 if mi(_ttrend) & `touse'
			la var _ttrend trend
			
			
			* Exclude the coefficients that are restricted: Those on the negative values of the trend range, plus the endpoints
			loc komittrend ""	
			
			foreach klevel in `kgs' {
				if (inrange(`klevel',`trcoef',-1) & `klevel' != -1) {
					loc absk = abs(`klevel')
					if `klevel'<0 loc plus = "m"
					else loc plus "p"
					loc l`plus'`absk' "`plus'`absk'"
					loc toexc "_k_eq_`l`plus'`absk''"
					loc included: list included - toexc
					loc komittrend = "`komittrend' `klevel'"				
				}
			*noi di "***"
			*noi di "`included'"
			}
			* loc toexc: word 1 of `included'
			*loc included: list local included - toexc
			*loc total: word count `included'
			*loc toexc: word `total' of `included'
			*loc included: list local included - toexc
			* di "`included'"
		}	
		
		* Save the names of included reg vars to extract these coefficients from the overall matrix later
		
		loc j=1
		loc names ""
		foreach var in `included' {
			if `j'==1 loc names `""`var'""'
			else loc names `"`names'.."`var'""'
			loc ++ j
		}	
		return local included = "`included'"
		return local names = `"`names'"'
		return local komittrend= "`komittrend'" 
		
	}
	******* add the imputed policyvar to the database 

	if "`impute'"!="" & "`saveimp'"!="" {
		qui gen float `policyvar'_imputed=`zn2' 
		lab var `policyvar'_imputed "policyvar after imputation"
		order `policyvar'_imputed, after(`z')
	}
	*say if imputation succeeded
	return local impute= "`impute'"	
	return local saveimp= "`saveimp'"
	*temporary variable equal to imputed policyvar (for _eventiv.ado)
	if "`rr'"!="" qui replace `rr'=`zn2'
end



* Program to parse impute 
cap program drop parseimpute
program define parseimpute, rclass

	syntax [anything] , [saveimp]
		
	return local impute "`anything'"
	return local saveimp "`saveimp'"
end	


	
	
