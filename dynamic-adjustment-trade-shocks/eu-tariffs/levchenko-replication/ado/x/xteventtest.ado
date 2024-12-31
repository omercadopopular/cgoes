* xteventtest.ado 2.1.0 Aug 1 2022

version 11.2

cap program drop xteventtest
program define xteventtest, rclass
	#d;
	syntax, 
	[
	coefs(numlist) /*Coefficients to test */
	cumul /* Test sum of coefficients */
	LINpretrend /* Test for linear pre-trend */
	CONSTanteff /* Test for constant effects */
	TRend(numlist <0 integer min=1 max=1) /* Test significance of a linear trend from time a*/
	overidpre(numlist >0 integer min=1 max=1) /* Test the leftmost coefficients as overid restriction */
	overidpost(numlist >1 integer min=1 max=1) /* Test the rightmost coefficients as overid restriction */
	overid /* Test overid restrictions from xtevent command */
	allpre /* Test all pre-event coefficients */
	allpost /* Test all post-event coefficients */
	testopts(string) /* Options to be passed to -test- */	
	]
	;
	#d cr
	
	tempname dim est
	
	* Error checking
	
	if "`coefs'"!="" & ("`linpretrend'"!="" | "`constanteff'"!="" | "`trend'"!="" | "`overidpre'"!="" | "`overidpost'"!="" | "`overid'"!="" | "`allpre'"!="" | "`allpost'"!="" ) {
		di as err _n "option {bf:coefs} not allowed with options {bf:linpretrend}, {bf:constanteff}, {bf:trend}, {bf:overidpre}, {bf:overidpost}, {bf:overid}, {bf:allpre}, or {bf:allpost}"
		exit 301
	}
	
	if "`cumul'"!="" & ("`linpretrend'"!="" | "`constanteff'"!="" | "`trend'"!="" | "`overidpost'"!="" | "`overid'"!="") {
		di as err _n "option {bf:cumul} not allowed with options {bf:linpretrend}, {bf:constanteff}, {bf:trend}, {bf:overidpost}, or {bf:overid}"
		exit 301
	}
	
	if "`linpretrend'"!="" & ("`constanteff'"!="" | "`trend'"!="" | "`overidpre'"!="" | "`overidpost'"!="" | "`overid'"!="" | "`allpre'"!="" | "`allpost'"!="") {
		di as err _n "option {bf:linpretrend} not allowed with options {bf:constanteff}, {bf:trend}, {bf:overidpre}, {bf:overidpost}, {bf:overid}, {bf:allpre}, or {bf:allpost}"
		exit 301
	}
	
	if "`constanteff'"!="" & ("`trend'"!="" | "`overidpre'"!="" | "`overidpost'"!="" | "`overid'"!="" | "`allpre'"!="" | "`allpost'"!="" ) {
		di as err "option {bf:constanteff} not allowed with options {bf:trend}, {bf:overidpre}, {bf:overidpost}, {bf:overid}, {bf:allpre}, or {bf:allpost}"
		exit 301
	}
	
	if "`trend'"!="" & ("`overidpre'"!="" | "`overidpost'"!="" | "`overid'"!="" | "`allpre'"!="" | "`allpost'"!="") {
		di as err _n "option {bf:trend} not allowed with options {bf:overidpre}, {bf:overidpost}, {bf:overid}, {bf:allpre}, or {bf:allpost}"
		exit 301
	}	
	
	if "`overidpre'"!="" & ("`overid'"!="" | "`allpre'"!="" | "`allpost'"!="" ) {
		di as err _n "option {bf:overidpre} not allowed with options {bf:overid}, {bf:allpre}, or {bf:allpost}"
		exit 301
	}

	if "`overidpost'"!="" & ("`overid'"!="" | "`allpre'"!="" | "`allpost'"!="" ) {
		di as err _n "option {bf:overidpost} not allowed with options {bf:overid}, {bf:allpre}, or {bf:allpost}"
		exit 301
	}
		
	loc names = e(names)
	
	* Turn overid into overidpre and overidpost
	if "`overid'"!="" {
		if e(pre)==. {
			* Default: All pre, two last
			loc i=0
			foreach w in `names' {
				loc wordp: subinstr local w "_k_eq_p" "", all				
				if "`wordp'"!="`w'" continue
				loc ++i
			}			
			loc overidpre = `i'
			loc wordt: word count `names'			
			loc overidpost = 2
		}
		else {
			loc overidpre=e(overidpre)
			loc overidpost=e(overidpost)
		}
	}
		
	* If overidpre, take the earlier coefs
	if "`overidpre'"!="" {
		di as txt _n "Overidentification test for pretrends: `overidpre' pre-event coefficients are 0"
		loc c ""
		forv i=1(1)`overidpre' {
			loc cplus: word `i' of `names'
			loc c "`c' `cplus'"
			if "`overid'"!="" loc cpre "`c'"
		}
		loc cbreak: subinstr local c "_p" "", all
		if "`c'"!="`cbreak'" {
			di as err _n "Cannot test more pre-event coefficients than were estimated"
			exit 199
		}
		if "`c'"=="" {
			di as err _n "No pre-event coefficients to test"
			exit 199
		}
	}	
	
	* If overidpost, take the latter coefs and test equality
	if "`overidpost'"!="" {
		di as txt _n "Overidentification test for effects leveling off: `overidpost' last post-event coefficients are equal"
		* allow overidpre here
		if "`overidpre'"=="" loc c ""
		else loc c "(`c')"
		loc cplus ""
		loc wordt: word count `names'
		forv i=1(1)`overidpost' {
			loc cadd: word `=`wordt'-`i'+1' of `names'
			loc cplus "`cplus' `cadd'"
		}
		loc cplus = strltrim("`cplus'")
		loc cplus : subinstr local cplus " " "=", all
		if "`overid'"!="" loc cpost "`cplus'"
		if "`overidpre'"!="" loc cplus "(`cplus')"
		loc c "`c' `cplus'"
		loc cbreak: subinstr local cplus "_m" "", all
		if "`cplus'"!="`cbreak'" {
			di as err _n "Cannot test more post-event coefficients than were estimated"
			exit 199
		}
		if "`cplus'"=="" {
			di as err _n "No post-event coefficients to test"
			exit 199
		}		
	}					
	* Check that coefs were estimated and gather
	if "`coefs'"!="" {
		loc c ""
		foreach j in `coefs' {
			if `j'<0 {
				loc jj = abs(`j')
				loc cplus "_k_eq_m`jj'"
			}
			else if `j'>=0 loc cplus "_k_eq_p`j'"
			loc match = 0
			foreach name in `names' {
				if "`cplus'"=="`name'" loc ++ match
			}
			if `match'!=0 {
				loc c "`c' `cplus'"
			}
			else {
				di as err _n "Coefficient for event-time `j' not found"
				exit 301
			}
		}		
	}
	
	* Gather pre estimates if all pre
	if "`allpre'"=="allpre" {
		di as txt _n "Test for all pre-event coefficients = 0"
		loc c ""
		foreach j in `names' {
			loc sub : 	 subinstr local j "_k_eq_m" "", all
			if "`sub'"!="`j'" loc c "`c' `j'"
		}		
	}
	* Gather post estimates if all post
	if "`allpost'"=="allpost" {
		di as txt _n "Test for all post-event coefficients = 0"
		* Allow allpre combination
		if "`allpre'"!="allpre" loc c ""
		foreach j in `names' {
			loc sub : 	 subinstr local j "_k_eq_p" "", all
			if "`sub'"!="`j'" loc c "`c' `j'"
		}
	}
	
	* Gather post estimates with equal signs if constanteff
	if "`constanteff'"=="constanteff" {
		loc c ""
		di as txt _n "Test for constant post-event coefficients"
		foreach j in `names' {
			loc sub : 	 subinstr local j "_k_eq_p" "", all
			if "`sub'"!="`j'" loc c "`c' `j'"
		}
		loc c = strltrim("`c'")
		loc c : subinstr local c " " "=", all
	}
	
	* Accumulate if cumul
	if "`cumul'"=="cumul" {
		di as txt _n "Test sums of coefficients"
		loc c: subinstr local c " " "+",all
		loc c=substr("`c'",2,.)
		loc c = "`c' = 0"
	}
	
	
	
	* Linear pre-trend specification test
	
	if "`linpretrend'"!="" {
		loc tt ""
		foreach j in `names' {
			loc sub : 	 subinstr local j "_k_eq_m" "", all
			if "`sub'"!="`j'" loc tt "`tt' `j'"
		}
		loc d : word count `tt'
		scalar `dim' = `d'
		mata: trendtest("`dim'")
		* scalar li Q
		
		loc df = `dim' - 2
		loc p = chi2tail(`df',Q)
		
		loc df: di %3.0f `df'
		loc q : di %8.2f `=Q'
		loc p: di %8.4f `p'
		
		di as txt _n "Specification test for linear pre-trend"		
		di as txt _col(12) "chi2(`df') =" as res `q'
        di as txt _col(10) "Prob > chi2 =" as res `p'        
	}
	
	* Trend test
	if "`trend'"!="" {
		loc trend "trend(`trend', method(ols))"
		loc cmd = e(cmdline)
		loc cmd = regexr("`cmd'","trend\(.*\)","")	
		_estimates hold `est'
		*di as txt _n "Estimating trend using {cmd:xtevent, trend(, method(ols))}"
		di as txt _n "Estimating trend by OLS"
		qui `cmd' `trend'
		di as txt _n "Significance test for linear trend"	
		test _ttrend
		_estimates unhold `est'
	}
		
		
	* Test
	if "`overid'"!="" {
		di as txt _n "Overidentification test for pretrends: `overidpre' pre-event coefficients are 0"
		test `cpre', `testopts'	
		returntest pre
		return add
		di as txt _n "Overidentification test for effects leveling off: `overidpost' last post-event coefficients are equal"
		test `cpost', `testopts'
		returntest post
		return add
		di as txt _n "Joint overidentification test"
		test (`cpre') (`cpost'), `testopts'
		returntest prepost
		return add
	}
	else {
		if "`c'"!="" test `c', `testopts'
		return add
	}	
	
end

cap program drop returntest
program define returntest, rclass
	args stub
	foreach x in p F df_r chi2 ss rss drop {
		if r(`x')!=. return scalar `stub'_`x' = r(`x')
	}
end


mata:

mata clear

void trendtest(dim)
	{	real matrix b,V,Vinv,X,ab,eta
		real scalar Q
		
		dim=st_numscalar(dim)	
		b=st_matrix("e(b)")'[1..dim,1]
		V=st_matrix("e(V)")[1..dim,1..dim]
		Vinv=cholinv(V)
		X = (J(dim,1,1),range(1,dim,1))
		ab = cholinv(X'*Vinv*X)*(X'*Vinv*b)
		eta = b - (X*ab)
		Q = eta'*Vinv*eta
		st_numscalar("Q",Q)
	}

end

	
		
	
