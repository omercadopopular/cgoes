*! 1.1.1			09may2017
*! 1.1.0			16apr2017
*! 1.0.0            29mar2016 
*! Robert Picard    picard@netbox.com
*! Nicholas J. Cox  n.j.cox@durham.ac.uk 
*! Roberto Ferrer   refp16@gmail.com
program define rangestat, sortpreserve rclass

	version 11
	
	return local rangestat_version 1.1.1

	syntax anything(name=slist id=slist equalok) 	///
		[if] [in] ///
		, 	///
		Interval(string)	///	
		[					///
		EXCLudeself			///
		BY(varlist)			///
		CASEWise			///  
		Describe			/// 
		local(name)			/// 
		noCHeck				///
		]


	cap unab curvars : *
	if _rc {
		dis as err "no variables defined"
		exit 111
	}

	local interval : subinstr local interval "," " ", all 
	tokenize `"`interval'"'
	
	if "`4'" != "" {
		dis as err "extra argument in interval() option: `4'"
		exit 198
	}
	
	args vkey low high 
	
	// the key variable must be numeric
	confirm numeric var `vkey'
	
	// the lower interval bound
	tempvar klow
	cap confirm numeric var `low'
	if _rc {
		cap confirm number `low'
		if _rc & "`low'" != "." {
			dis as err "was expecting a numeric variable, a number, or a system missing value for the interval low: `low'"
			exit 198
		}
		qui gen double `klow' = `vkey' + `low'
	}
	else qui gen double `klow' = cond(`low' > ., ., `low')	// no extended missing
	
	// the higher interval bound
	tempvar khigh
	cap confirm numeric var `high'
	if _rc {
		cap confirm number `high'
		if _rc & "`high'" != "." {
			dis as err "was expecting a numeric variable, a number, or a system missing value for the interval high: `high'"
			exit 198
		}
		qui gen double `khigh' = `vkey' + `high'
	}
	else qui gen double `khigh' = cond(`high' > ., ., `high')	// no extended missing
	
	// inrange(z,a,b) returns 1 if mi(a) & !mi(z)
	qui replace `klow' = c(mindouble) if mi(`klow')


	marksample touse
	markout `touse' `vkey'
	qui count if `touse'
	if r(N) == 0 error 2000


	local single_stats mean sd variance min max count median ///
		sum missing obs first last firstnm lastnm skewness kurtosis 
		
	local flexible_stats cov corr reg

	gettoken what : slist, parse("() ") match(p)
	if "`p'" == "" local slist (mean) `slist'
		

	local n 0
	while "`slist'" != "" {

		gettoken what slist : slist, parse("()-= ") match(parens)

		if "`parens'" != "" {
		
			// (<statword>) must be a single Stata name
			cap confirm name `what'
			local bad = _rc
			if `:word count `what'' != 1 | `bad' {
				dis as err `""(`what')" is not a valid stat"'
				exit 198
			}
			
			local statword `what'
			local ++n
			local stat`n' `statword'
			
			gettoken what slist : slist, parse("-= ")
			
		}

		gettoken eqdash next : slist, parse("-= ")
		
		if "`eqdash'" == "=" {
		
			if !`: list statword in single_stats' {
				dis as error "new_varname=varname syntax is restricted to built-in single stats"
				exit 198
			}
		
			// <newvarname>[ ]=[ ]<varname>
			
			confirm name `what'
			local vres`n' `vres`n'' `what'
			gettoken v slist: next
			unab v : `v'
			confirm numeric var `v'
			local vuse`n' `vuse`n'' `v'

		}
		else {
		
			if "`eqdash'" == "-" {
			
				// <varname>[ ]-[ ]<varname>
				gettoken v slist: next
				local what `what'-`v'
			}
			
			// unabbreviate and expand varlist; use <statword> as suffix to hold results
			foreach v of varlist `what' {
				local vuse`n' `vuse`n'' `v'
				confirm numeric var `v'
				local vres`n' `vres`n'' `v'_`stat`n''
				confirm name `v'_`stat`n''
			}
			
		}

	}

	// before calculating anything, check for variable name conflicts
	// for results we control
	forvalues i = 1/`n' {
	
		if `: list stat`i' in single_stats' {	
		
			local isbad : list curvars & vres`i'
			local curvars `curvars' `vres`i''
			
		}
		else if `: list stat`i' in flexible_stats' {
			
				`stat`i''_handler, vin(`vuse`i'') setup
				local to_add `s(newnames)'
				local isbad : list curvars & to_add
				local curvars `curvars' `to_add'
				
		}
		
		if "`isbad'" != "" {
			dis as err "cannot create -`isbad'-; variable(s) already defined"
			exit 110
		}
			
	}
	
	
	if "`by'" == "" {
		tempvar by
		gen byte `by' = 1
	}


	tempvar obs tag group repeat
	gen long `obs' = _n
	
	// assign a lower bound of .z to repeats with identical interval bounds;
	// since low > high, they will not pick up any observation
	if "`excludeself'" == "" & "`check'" == "" {
		sort `by' `klow' `khigh' `touse' `vkey' `obs'
		by `by' `klow' `khigh': gen byte `repeat' = _n < _N
		// skip calculating results for repeats using a missing lower bound
		qui count if `repeat'
		if r(N) {
			tempvar klow2use
			qui gen double `klow2use' = cond(`repeat', .z, `klow')
		}
	}
	if "`klow2use'" == ""  local klow2use `klow'


	sort `by' `vkey' `obs'
	by `by': gen byte `tag' = _n == 1
	gen long `group' = sum(`tag')
	drop `tag'


	// for each observation, get the indices of the first and last obs
	// that falls in the interval (on the reduced `touse' sample)
	mata: indices = get_indices("`group'", "`vkey'", "`klow2use'", "`khigh'", "`touse'")


	forvalues i = 1/`n' {
	
		if `: list stat`i' in single_stats' {
		
			local rs_stat rs_`stat`i''
		
			mata: do_stats(indices, "`vuse`i''", "`vres`i''", "`casewise'", ///
				"`excludeself'", "`touse'", &`rs_stat'())

			local newvars `newvars' `vres`i'' 
			
			local k : word count `vuse`i''
			forvalues j = 1/`k' {
				local from : word `j' of `vuse`i''
				local to : word `j' of `vres`i''
				label variable `to' "`stat`i'' of `from'"
			}
			
		}
		else if `: list stat`i' in flexible_stats' {
		
			local rs_stat rs_`stat`i''
		
			// all built-in flexible_stats require casewise deletion
			mata: vnew = do_flex_stats(indices, "`vuse`i''", ///
				"casewise", "`excludeself'", "`touse'", &`rs_stat'())

			mata: st_local("flex_vars", vnew)
			mata: mata drop vnew
			
			`stat`i''_handler , vin(`vuse`i'') vout(`flex_vars')
			local newvars `newvars' `s(renvars)'
			
		}
		else {
		
			mata: vnew = do_flex_stats(indices, "`vuse`i''", ///
				"`casewise'", "`excludeself'", "`touse'", &`stat`i''())

			mata: st_local("flex_vars", vnew)
			mata: mata drop vnew
						
			local j 0
			foreach v of varlist `flex_vars' {
				local newname `stat`i''`++j'
				rename `v' `newname'
				label variable `newname' "`stat`i'' of `vuse`i''"
				local newvars `newvars' `newname'
			}
			
			
		}

	}

	mata: mata drop indices
	
	if "`describe'" != "" {
		if "`newvars'" != "" describe `newvars' 
	}

	if "`local'" != "" { 
		c_local `local' `newvars'
	}
	
	return local newvars `newvars'
	
	// for intervals with repeats, copy results from first observation
	qui if "`excludeself'" == ""  & "`check'" == "" {
		count if `repeat'
		if r(N) {
			sort `group' `klow' `khigh' `touse' `vkey' `obs'
			foreach v of varlist `newvars' {
				by `group' `klow' `khigh': replace `v' = `v'[_N] if `touse'
			}
		}
	}
	
end


program cov_handler, sclass

	syntax , [vin(varlist) vout(string) setup]

	if "`setup'" != "" {
		if `:word count `vin'' != 2 {
			dis as err "cov stat requires exactly 2 variables; you included: `vin'"
			exit 198
		}
		confirm new var cov_nobs
		confirm new var cov_x
		sreturn local newnames cov_nobs cov_x
	}
	else {
		tokenize `vin'
		local pw `1' `2'
		
		if `:word count `vout'' != 2 {
			dis as err "no result for all obs: cov `vin'"
			drop `vout'
			sreturn local renvars
		}
		else {
			tokenize `vout'
			rename `1' cov_nobs
			label var cov_nobs "number of observations - cov"
		
			rename `2' cov_x
			label var cov_x "covariance of `pw'"
		
			sreturn local renvars cov_nobs cov_x
		}
	}
	
end


program corr_handler, sclass

	syntax , [vin(varlist) vout(string) setup]

	if "`setup'" != "" {
		if `:word count `vin'' != 2 {
			dis as err "corr stat requires exactly 2 variables; you included: `vin'"
			exit 198
		}
		confirm new var corr_nobs
		confirm new var corr_x
		sreturn local newnames corr_nobs corr_x
	}
	else {
		tokenize `vin'
		local pw `1' `2'
		
		if `:word count `vout'' != 2 {
			dis as err "no result for all obs: corr `vin'"
			drop `vout'
			sreturn local renvars
		}
		else {
			tokenize `vout'
			rename `1' corr_nobs
			label var corr_nobs "number of observations - corr `pw'"
		
			rename `2' corr_x
			label var corr_x "correlation of `pw'"
		
			sreturn local renvars corr_nobs corr_x
		}
	}
	
end


program reg_handler, sclass

	syntax , [vin(varlist) vout(string) setup]

	if "`setup'" != "" {
		gettoken depvar indvar : vin
		if "`depvar'" == "" | "`indvar'" == "" {
			dis as err "reg requires a depvar and at least one indepvar; you included: `vin'"
			exit 198
		}
		local vlist reg_nobs reg_r2 reg_adj_r2 b_cons se_cons
		foreach v of varlist `indvar' {
			local vlist `vlist' b_`v'
			local vlist `vlist' se_`v'
		}
		foreach v of local vlist {
			confirm new var `v'
		}
		sreturn local newnames `vlist'
	}
	else {
	
		local reg regress `vin'
		if `:length local reg' > 50 {
			local reg =  substr("`reg'",1,50) + "..."
		}
			
		gettoken depvar indvar : vin
		
		local rvars `indvar' cons
		local nrvars : word count `rvars'
		local nrvars = `nrvars' * 2 + 3
		
		if `:word count `vout'' != `nrvars' {
			dis as err "no result for all obs: reg `vin'"
			drop `vout'
			sreturn local renvars
		}
		else {		
			tokenize `vout'
		
			rename `1' reg_nobs
			label var reg_nobs "number of obs - regress `reg'"
			rename `2' reg_r2
			label var reg_r2 "R-squared - `reg'"
			rename `3' reg_adj_r2
			label var reg_adj_r2 "adj. R-squared - `reg'"
			local vlist reg_nobs reg_r2 reg_adj_r2

			local i 4
			foreach v of local rvars {
				rename ``i++'' b_`v'
				label var b_`v' "coef - `reg'"
				local vlist `vlist' b_`v'
			}
			foreach v of local rvars {
				rename ``i++'' se_`v'
				label var se_`v' "std err - `reg'"
				local vlist `vlist' se_`v'
			}
		
			sreturn local renvars `vlist'
		}
	}
	
end



	

version 11
mata:
mata set matastrict on

real matrix get_indices(

	string scalar vgroup,	// group identifier variable
	string scalar vkey,		// key variable (with a value for each obs)
	string scalar vkeylow,	// low end of values to look for in vkey
	string scalar vkeyhigh,	// high end of values to look for in vkey
	string scalar touse
)
{

	real matrix		///
		ginfo,		// group start and end indices
		ZAB,		// group data for range variables
		indices     // indices of obs in touse sample that are in range

	real colvector ///
		group,		// group identifiers
		Z,			// key value
		A,			// low range to match in Z
		B,			// high range to match in Z
		gi			// index of observations in group
				
	real scalar ///
		g, i, 		// looping indices
		iz,			// index to current observation in the touse sample
		g1, 
		gN
		

	// get the data in the touse sample
	group = st_data(., vgroup, touse)
	Z     = st_data(., vkey, touse)
	A     = st_data(., vkeylow, touse)
	B     = st_data(., vkeyhigh, touse)
	
	
	// initialize the results
	indices = J(rows(group),2,.)
	
	// identify the indices of the first and last obs in each group
	ginfo = panelsetup(group,1)

	// loop over each group
	iz = 0
	for (g=1; g<=rows(ginfo); g++) {
	
		g1 = ginfo[g,1]
		gN  = ginfo[g,2]
		
		gi = range(g1,gN,1)
		
		// combine key data with range data
		ZAB = ( Z[|g1,1 \ gN,1|], gi, J(rows(gi),1,2) \ ///
				A[|g1,1 \ gN,1|], gi, J(rows(gi),1,1) \ ///
				B[|g1,1 \ gN,1|], gi, J(rows(gi),1,3) )
				
		// order by key value; for ties, put A first, then Z, then B
		ZAB = sort(ZAB,(1,3,2))
				
		// Cycle through all key values. We use iz to track the current
		// obs in the group. 
		for (i=1; i<=rows(ZAB); i++) {
			
			if (ZAB[i,3] == 1) indices[ZAB[i,2],1] = iz + 1
			else if (ZAB[i,3] == 3) indices[ZAB[i,2],2] = iz
			else iz = ++iz

		}
		
	}
	
	return(indices)

}


void do_stats(

	real matrix indices,		// index to start and last matching obs
	string scalar vx,			// variable names to use
	string scalar vstat,		// variable names to store stats
	string scalar cw,			// casewide deletion
	string scalar exself,		// exclude self
	string scalar touse,
	pointer(function) scalar p	// pointer to the function that calculates the stat

)
{

	real matrix X,	// input data from the touse sample
		Xsub,		// input data that are within the range of the obs
		Xstat		// holds the computed statistics
	
	real scalar i, ix
	
	
	// data from the touse sample, multiple variables allowed
	X = st_data(., vx, touse)
	
	// initialize the results
	Xstat = J(rows(X),cols(X),.)
	
	// compute statistic by obs
	for (i=1; i<=rows(X); i++) {
		
		// proceed only if there's at least 1 obs within specified range
		if (indices[i,2] - indices[i,1] >= 0) {
		
			// extract the data that's within the specified range for obs i
			Xsub = X[|indices[i,1],1 \ indices[i,2],.|]
			
			// replace with missing values if we are excluding data from obs i
			if (exself != "") {
				ix = i - indices[i,1] + 1
				if (ix > 0 & ix <= rows(Xsub)) {
					Xsub[ix,.] = J(1, cols(X), .)
				}
			}

			// if we are doing casewise deletion, select obs with no missings
			if (cw != "") Xsub = select(Xsub, rowmissing(Xsub) :== 0)

			// if we have obs, compute the statistic for obs i
			if (rows(Xsub)) Xstat[i,.] = (*p)(Xsub)

		}
			
	}
	
	st_store(., st_addvar("double", tokens(vstat)), touse, Xstat)

}


string scalar do_flex_stats(

	real matrix indices,		// index to start and last matching obs
	string scalar vx,			// variable names to use
	string scalar cw,			// casewide deletion
	string scalar exself,		// exclude self
	string scalar touse,
	pointer(function) scalar p	// pointer to the function that calculates the stat

)
{

	real matrix X,	// input data from the touse sample
		Xsub,		// input data that are within the range of the obs
		Xstat		// holds the computed statistics
	real scalar i, ix
	real rowvector xres
	string rowvector vnames
	
	
	// data from the touse sample, multiple variables allowed
	X = st_data(., vx, touse)
	
	// we don't know how many variables are returned, start with 1 col	
	Xstat = J(rows(X),1,.)
	
	// compute the flex statistic by obs
	for (i=1; i<=rows(X); i++) {
	
		// proceed only if there's at least 1 obs within specified range
		if (indices[i,2] - indices[i,1] >= 0) {
		
			// extract the data that's within the specified range for obs i
			Xsub = X[|indices[i,1],1 \ indices[i,2],.|]
			
			// replace with missing values if we are excluding data from obs i
			if (exself != "") {
				ix = i - indices[i,1] + 1
				if (ix > 0 & ix <= rows(Xsub)) {
					Xsub[ix,.] = J(1, cols(X), .)
				}
			}

			// if we are doing casewise deletion, select obs with no missings
			if (cw != "") Xsub = select(Xsub, rowmissing(Xsub) :== 0)
			
			// if we have obs, compute the statistic for obs i
			if (rows(Xsub)) {
			
				// flex-function must return a rowvector
				xres = (*p)(Xsub)
			
				// expand the number of columns if needed
				if (cols(xres) > cols(Xstat)) {
					Xstat = (Xstat,J(rows(X), cols(xres)-cols(Xstat),.))
				}

				Xstat[i,1..cols(xres)] = xres
				
			}
			

		}
			
	}
	
	// use tempvars to store the results
	vnames = st_tempname(cols(Xstat))
	st_store(., st_addvar("double", vnames), touse, Xstat)
	
	return(invtokens(vnames))

}


real rowvector rs_min(real matrix X)
{

	return(colmin(X))

}


real rowvector rs_max(real matrix X)
{

	return(colmax(X))

}


real rowvector rs_mean(real matrix X)
{
	real scalar j
	real rowvector xres

	// mata's mean() function does casewise deletion; do each column
	// separately if there are missing values in X
	if (hasmissing(X)) {
	
		xres = J(1,cols(X),.)
		for (j=1; j<=cols(X); j++) {
			xres[1,j] = mean(X[.,j])
		}
		return(xres)
		
	}
	else return(mean(X))

}


real rowvector rs_variance(real matrix X)
{
	real scalar j
	real rowvector xres

	// mata's variance() function does casewise deletion; do each column
	// separately if there are missing values in X
	if (hasmissing(X)) {
	
		xres = J(1,cols(X),.)
		for (j=1; j<=cols(X); j++) {
			xres[1,j] = quadvariance(X[.,j])
		}
		return(xres)
		
	}
	else return(diagonal(quadvariance(X))')

}


real rowvector rs_sd(real matrix X)
{
	real scalar j
	real rowvector xres
	
	// mata's variance() function does casewise deletion; do each column
	// separately if there are missing values in X
	if (hasmissing(X)) {
	
		xres = J(1,cols(X),.)
		for (j=1; j<=cols(X); j++) {
			xres[1,j] = quadvariance(X[.,j])
		}
		return(sqrt(xres))
		
	}
	else return(sqrt(diagonal(quadvariance(X))'))
	
}


real rowvector rs_count(real matrix X)
{

	return(colnonmissing(X))

}


real rowvector rs_missing(real matrix X)
{

	return(colmissing(X))

}


real rowvector rs_obs(real matrix X)
{

	return( J(1, cols(X),rows(X)) )

}


real rowvector rs_sum(real matrix X)
{

	return(colsum(X))

}


real rowvector rs_first(real matrix X)
{

	return(X[1,.])

}


real rowvector rs_last(real matrix X)
{

	return(X[rows(X),.])

}


real rowvector rs_firstnm(real matrix X)
{

	real scalar j
	real rowvector xres
	real colvector XJ
	
	// generate results by column
	xres = J(1,cols(X),.)
	
	for (j=1; j<=cols(X); j++) {
	
		XJ = select(X[.,j], X[.,j] :< .)
		if (rows(XJ)) xres[1,j] = XJ[1,1]
		
	}

	return(xres)
}


real rowvector rs_lastnm(real matrix X)
{

	real scalar j
	real rowvector xres
	real colvector XJ
	
	// generate results by column
	xres = J(1,cols(X),.)
	
	for (j=1; j<=cols(X); j++) {
	
		XJ = select(X[.,j], X[.,j] :< .)
		if (rows(XJ)) xres[1,j] = XJ[rows(XJ),1]
		
	}

	return(xres)

}


real rowvector rs_median(real matrix X)
{
	real scalar j, n
	real rowvector xres
	real colvector XJ
	
	// generate results by column
	xres = J(1,cols(X),.)
	
	for (j=1; j<=cols(X); j++) {
	
		// extract non-missing values colvector
		XJ = select(X[.,j], X[.,j] :< .)
		
		// if rows(XJ) == 0, sort() will throw a conformability error
		// no need to sort if there's 1 row
		if (rows(XJ) > 1) XJ = sort(XJ, 1)
		
		// special case if there's only one row
		if (rows(XJ) == 1) xres[1,j] = XJ[1,1]
		else if (rows(XJ) > 1) {
		
			// XJ midpoint index
			n = floor(rows(XJ)/2) + 1

			// return the average if the rows are even
			xres[1,j] = (mod(rows(XJ),2) ? XJ[n,1] : (XJ[n-1,1] + XJ[n,1]) / 2)
			
		}
		
	}

	return(xres)

}


real rowvector rs_cov(real matrix X)
{

	real matrix R
	
	R = variance(X)
	
	return(rows(X), R[1,2])
	
}


real rowvector rs_corr(real matrix X)
{

	real matrix R
	
	R = correlation(X)
	return(rows(X), R[1,2])
	
}

// http://blog.stata.com/2016/01/12/programming-an-estimation-command-in-stata-an-ols-command-using-mata/
real rowvector rs_reg(real matrix Xall)
{
	real colvector y, b, e, e2, se
	real matrix X, XpX, XpXi, V
	real scalar n, k, ymean, tss, mss, r2, r2a
	
	y = Xall[.,1]                // dependent var is first column of Xall
	X = Xall[.,2::cols(Xall)]    // the remaining cols are the independent variables
	n = rows(X)                  // the number of observations
	X = X,J(n,1,1)               // add a constant
	k = cols(X)				 	 // number of independent variables
	
	if (n > k) {	// need more than k obs to estimate model and standard errors
	
		// compute the OLS point estimates
		XpX  = quadcross(X, X)
		XpXi = invsym(XpX)
	
		// proceed only if no variable is omitted
		if (diag0cnt(XpXi)==0) {

			b    = XpXi*quadcross(X, y)
		
			// compute the standard errors
			e  = y - X*b
			e2 = e:^2
			V  = (quadsum(e2)/(n-k))*XpXi
			se = sqrt(diagonal(V))
		
			// r2 and adjusted r2
			ymean = mean(y)
			tss   = sum((y :- ymean) :^ 2)        // total sum of squares
			mss   = sum( (X * b :- ymean)  :^ 2)  // model sum of squares    
			r2    = mss / tss
			r2a   = 1 - (1 - r2) * (n - 1) / (n - k)
		
		}
	}
	
	return(rows(X), r2, r2a, b', se')
}


real rowvector rs_skewness(real matrix X)
{
	real matrix dev 
	dev = X :- mean(X) 
	return(mean(dev:^3) :/ (mean(dev:^2)):^(3/2)) 
}


real rowvector rs_kurtosis(real matrix X)
{
	real matrix dev 
	dev = X :- mean(X) 
	return(mean(dev:^4) :/ (mean(dev:^2)):^2)
}


end
