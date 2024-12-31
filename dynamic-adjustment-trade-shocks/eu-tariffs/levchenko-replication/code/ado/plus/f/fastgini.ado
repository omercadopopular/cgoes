*! version 1.0  15feb2007 Z. Sajaia

program define fastgini, rclass
	syntax varname [if] [in] [pweight fweight], ///
						[bin(numlist integer min=1 max=1 >0) noCHeck jk Level(cilevel)]
	version 9.2

if missing("`check'") {
	tempvar goodx

	marksample touse
	quietly count if `varlist' <= 0 & `touse'
	local ct = r(N)
	if `ct' > 0 {
		display
		display as text "Warning: `varlist' has `ct' values <= 0. Not used in calculations"
		}
	quietly generate `goodx' = 1 if (`varlist' > 0)
	markout `touse'  `goodx' `varlist'
	quietly count if `touse'
	local ct = r(N)
	if `ct'==0 error 2000
}

	if ~missing("`exp'") {
		tempvar w
		generate double `w' `exp'
	}
	local vlist "`varlist' `w'"

	tempname gini gini_jk se mse


	mata: mata_callfastgini()

	if missing("`jk'") display as text _n "Gini coefficient = " as result %9.7f `gini'
	else {
		display _newline
		display as text "Gini coefficient" _c
  		display as text _col(56) "Number of obs"    _col(70) "= " as res %7.0f `ct'
  		display ""

		tempname Tab t p ll ul z

	 	.`Tab' = ._tab.new, col(7) lmargin(0) ignore(.b)
		// column        1      2     3     4     5     6     7
		.`Tab'.width	13    |11    11     9     9    12    12
		.`Tab'.titlefmt  .   %11s  %12s   %7s     .  %24s     .
		.`Tab'.strfmt    .   %11s     .     .     .     .     .
		.`Tab'.pad       .      2     2     1     3     3     3
		.`Tab'.numfmt    .  %9.0g %9.0g %8.2f %5.3f %9.0g %9.0g
		.`Tab'.strcolor  . result    .     .     .     .     .

    	.`Tab'.sep, top
 		.`Tab'.titles	"`varlist'"	/// 1
						"Gini"	/// 2
						"Std. Err."	/// 3
						"t"	/// 4
						"P>|t|"			/// 5
						`"[`=strsubdp("`level'")'% Conf. Interval]"' ""	//  6 7


	 	scalar `t'  = `gini'/`se'
	  	scalar `p'  = 2*norm(-abs(`t'))
		scalar `z'  = invnorm((100+`level')/200)
		scalar `ll' = `gini' - `se'*`z'
		scalar `ul' = `gini' + `se'*`z'

		.`Tab'.sep
		.`Tab'.row "" `gini' `se' `t' `p' `ll' `ul'
		.`Tab'.sep, bottom

		return scalar mse = `mse'
		return scalar gini_jk = `gini_jk'
		return scalar se = `se'
   	}
	return scalar gini = `gini'
end

mata:

void function mata_callfastgini()
{
	RET = fastgini(st_data( .,tokens(st_local("vlist")),
				   st_local("touse")), st_local("weight"),
				   (st_local("jk")!=""),
				   strtoreal(st_local("bin")))

	st_numscalar(st_local("gini"), RET[1,1])
	st_numscalar(st_local("se"),  RET[2,1])
	st_numscalar(st_local("gini_jk"), RET[3,1])
	st_numscalar(st_local("mse"), RET[4,1])
}

real matrix function fastgini(real matrix X, | string scalar weight, real scalar jk, real scalar bin)
{
	colvector Xi, WX

  	N = rows(X)

	if (missing(bin)) {          // do 'regular' gini
		R = X[order(X,1),]
		M = N
	}
	else {                       // 'fast' gini, do aggregation
		M     = bin
		MM    = minmax(X[.,1])
  		bsize = (MM[1,2] - MM[1,1])/M
  		R     = ((1::M):*bsize:+MM[1, 1], J(M, 1, 0))
		Xi    = trunc((X[.,1]:-MM[1,1]):/bsize:-0.01):+1

		if (cols(X)==1) {
			for (i=1; i<=N; ++i) {     // no weights
				R[Xi[i], 2] = R[Xi[i], 2] + 1
			}
		}
		else {
			for (i=1; i<=N; ++i) {
			 	R[Xi[i], 2] = R[Xi[i], 2] + X[i,2]
			}
		}
	}
   	Xi=.
	C = cols(R)
	R = R \ J(1, C, .)

	if (C == 1) {
		sumW=N
	}
	else {
		WX  =R[., 1]:*R[., 2]
 		sumW=quadcolsum(R)[1,2]
	}

	sumWX=0
    if (missing(jk)) { //----------------- JUST GINI ---------------------------------
		if (C == 1) {
			sumWX=quadcross(R, ((M::1):*2:-1) \ .)*0.5
			sumX=quadcolsum(R)
		}
		else {
			sumX =0
   			for (i=1; i<=M; ++i) {
 			 	sumWX = sumWX + R[i, 2]*(sumX+WX[i]*0.5)
 				sumX  = sumX  + WX[i]
 			}
		}
	   	g = 1- 2*sumWX/sumW/sumX
		RET = g
	}
	else { // ---------------------- GINI PLUS JACKKNIFE STANDARD ERRORS -------------------

		SUM = J(M+1, 2, 0) // W x*W

		if (C == 1) {
			sumWX=quadcross(R, ((M::1):*2:-1) \ .)*0.5
			SUM[., 1] = (0::M)
 			for (i=1; i<=M; ++i) {
			   	SUM[i+1, 2] = SUM[i, 2] + R[i,1]
 			}
		}
		else {
 			for (i=1; i<=M; ++i) {
				sumWX = sumWX + R[i, 2]*(SUM[i, 2]+WX[i]*0.5)
 				SUM[i+1, 1] = SUM[i, 1] + R[i, 2]
 	  			SUM[i+1, 2] = SUM[i, 2] + WX[i]
 			}
		}
		sumW=SUM[M+1, 1]
		sumX=SUM[M+1, 2]
 		g = 1- 2*sumWX/sumW/sumX
		RET = g

	   	if (weight == "pweight") {
	   	 	G= 1:-2:*(sumWX:-(sumW:-R[.,2]:*0.5:-SUM[.,1]):*WX:-R[.,2]:*SUM[.,2]):/(sumW:-R[.,2]):/(sumX:-WX)

		  	MV=quadmeanvariance(G)
	   		V1=MV[2,1]+M/(M-1)*(MV[1,1]-g)^2

			RET = RET \ sqrt(MV[2,1]*(M-1)^2/M)
			RET = RET \ MV[1,1]
			RET = RET \ sqrt(V1*(M-1)^2/M)
		}
		else {
  	  		G= (- SUM[.,2]-R[.,1]:*(-SUM[.,1]:+(sumW-0.5)):+sumWX):/(R[.,1]:-SUM[M+1, 2]):*(2/(sumW - 1)):+1
			if (C == 1) MV=quadmeanvariance(G)
			else 		MV=quadmeanvariance(G, R[.,2])
	   		V1=MV[2,1]+sumW/(sumW-1)*(MV[1,1]-g)^2

			RET = RET \ sqrt(MV[2,1]*(sumW-1)^2/sumW)
			RET = RET \ MV[1,1]
			RET = RET \ sqrt(V1*(sumW-1)^2/sumW)
		}
	}
	return(RET)
}

end
