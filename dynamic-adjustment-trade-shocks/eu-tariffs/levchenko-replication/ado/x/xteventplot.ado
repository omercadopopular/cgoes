* xteventplot.ado 2.1.0 Aug 1 2022

version 11.2

cap program drop xteventplot
program define xteventplot
	#d;
	syntax [anything], 
	[	
	noci /* Supress confidence intervals */
	nosupt /* Omit sup-t CI */
	NOZEROline /* Supress line at 0 */
	NOMINus1label /* Supress label for value of dependent variable at event time = -1 */
	noprepval /* Supress p-value for pre-trends test */
	nopostpval /* Supress p-value for leveling-off test */
	suptreps(integer 1000) /* Draws from multivariate normal for sup-t CI calculations */
	overlay(string) /* Overlay plots: Trend, IV, or static */	
	y /* Plot for dependent variable in IV setting */
	proxy /* Plot for proxy variable in IV setting */	
	LEVels(numlist min=1 max=5) /* Levels for multiple CIs */
	SMpath(string) /* Options for smoothest path through confidence region */
	overidpre(numlist >0 integer min=1 max=1) /* Test the leftmost coefficients as overid restriction */
	overidpost(numlist >1 integer min=1 max=1) /* Test the rightmost coefficients as overid restriction */
	SCATTERPLOTopts(string)
	CIPLOTopts(string)
	SUPTCIPLOTopts(string)
	SMPLOTopts(string)
	TRENDPLOTopts(string)
	STATICOVPLOTopts(string)
	addplots(string asis) /* Plots to overlay on coefficients scatter */
	textboxoption(string) /* Option for adjusting text size of the test results */
	*
	]	
	;
	#d cr
	* Other options can be passed to graph
	
	*Add nodrawleftend and nodrawrightend
	
	* from eventols
	
	/*
	else if "`drawleftend'"=="nodrawleftend" | "`drawrightend'"=="nodrawrightend" {
			loc kmissadd ""
			if "`drawleftend'"=="nodrawleftend" loc kmissadd "`kmissadd' `kmin'"
			if "`drawrightend'"=="nodrawrightend" loc kmissadd "`kmissadd' `kmax'"
			loc kmiss "kmiss(`kmissadd')"
		}
	*/
	
	* Capture errors
	
	if "`=e(cmd2)'"!="xtevent" {
		di as err "{cmd:xteventplot} only available after {cmd:xtevent}"
		exit 301
	}
	
	if "`ci'"=="noci" & `"`smpath'"'!="" { 
		/* " */
		di as err "options {bf:noci} and {bf:smpath} not allowed simultaneously"
		exit 301
	}
	
	if "`overlay'"!="" & !inlist("`overlay'","trend","iv","static") {
		di as err "option {bf:overlay} can only be trend, iv, or static"
		exit 301
	}
	
	if "`overlay'"=="trend" & "`=e(trend)'"!="trend" { 
		di as err "option {bf:overlay(trend)} only allowed after {cmd:xtevent, trend(, saveoverlay)}"
		exit 301
	}
	
	if "`overlay'"=="iv" & "`=e(method)'"!="iv" {
		di as err "option {bf:overlay(iv)} only allowed after {cmd:xtevent, proxy() proxyiv()}"
		exit 301
	}
			
	* Get info from e
	loc df = e(df)
	tempname b V
	if inlist("`overlay'","trend","iv")  {
		mat `b' = e(deltaov)
		mat `V' = e(Vdeltaov)
	}
	else if "`y'" !="" {
		if "`=e(method)'"!="iv" {
			di as err "{cmd:xteventplot, y} only available after IV estimation with a proxy."
			exit 301
		}		
		mat `b' = e(deltaov)
		mat `V' = e(Vdeltaov)
	}
	else if "`proxy'"!="" {
		if "`=e(method)'"!="iv" {
			di as err "{cmd:xteventplot, y} only available after IV estimation with a proxy."
			exit 301
		}		
		mat `b' = e(deltax)
		mat `V' = e(Vdeltax)
	}
	else {
		mat `b' = e(delta)
		mat `V' = e(Vdelta)
		loc komit = e(komit)	
	}
	
	if "`ci'"=="noci" di as txt _n "option {bf:noci} has been specified. Confidence intervals won't be displayed"
	if "`supt'"=="nosupt" di as txt _n "option {bf:nosupt} has been specified. Sup-t confidence intervals won't be displayed or calculated"
	if "`zeroline'"=="nozeroline" di as txt _n "option {bf:nozeroline} has been specified. The reference line at 0 won't be displayed"
	if "`minus1label'"=="nominus1label" di as txt _n "option {bf:nominus1label} has been specified. The label for the value of the depedent variable at event-time = -1 won't be displayed"
	if "`prepval'"=="noprepval" di as txt _n "option {bf:noprepval} has been specified. The p-value for a pretrends test won't be displayed"
	if "`postpval'"=="nopostpval" di as txt _n "option {bf:nopostpval} has been specified. The p-value for a test of effects leveling-off won't be displayed"
	
	loc kmiss = e(kmiss)
	
	loc y1 = e(y1)
	
	* If user asks for plot options but the corresponding plot does not exist, ignore plot options
	if "`smplotopts'"!="" & `"`smpath'"'=="" {
		di as txt _n "option {bf:smplotopts} specified but option {bf:smpath} is missing. option {bf:smplotopts} ignored"
		loc smplotopts = ""
	}
	if "`ciplotopts'"!="" & "`ci'"=="noci" {
		di as txt _n "option {bf:ciplotopts} specified but option {bf:noci} is active. option {bf:ciplotopts} ignored"
		loc ciplotopts = ""
	}
	if "`suptciplotopts'"!="" & ("`supt'"=="nosupt" |  "`ci'"=="noci" ) {
		di as txt _n "option {bf:suptciplotopts} specified but options {bf:nosupt} or {bf:noci} are active. option {bf:suptciplotopts} ignored"
		loc suptciplotopts = ""
	}
	if "`staticovplotopts'"!="" & "`overlay'"!="static" {
		di as txt _n "option {bf:staticovplotopts} specified but option {bf:overlay} is not static. option {bf:staticovplotopts} ignored"
		loc staticovplotopts = ""
	}
	if "`trendplotopts'"!="" & "`overlay'"!="trend" {
		di as txt _n "option {bf:staticovplotopts} specified but option {bf:overlay} is not trend. option {bf:trendplotopts} ignored"
		loc trendplotopts = ""
	}
	
		
	* Get standard errors, omitted variables
		
	tempvar coef se kxaxis ul ll smline	post omitted fid fidget	
	
	mata st_matrix("`se'",sqrt(diagonal(st_matrix("`V'")))')	
	
	if "`komit'"=="" loc komit = -1
	loc komitcomma: subinstr local komit " " ",", all
	
	if "`kmiss'"!="" loc kmiss: subinstr local kmiss " " ",", all
	else loc kmiss=.
	
	loc kgs : colnames `b'
	loc kgso = "`kgs'"
	loc kgs : subinstr local kgs "_k_eq_" "", all
	loc kgs : subinstr local kgs "m" "-", all
	loc kgs : subinstr local kgs "p" "", all
	loc kgso : subinstr local kgs "o." "", all
	if "`kgso'"!="`kgs'" {
		di "Warning: Some event-time dummies were omitted in the regression. These coefficients will be shown as zero in the plot. Check the window and the instruments, if any."
	}
	loc kgs = "`kgso' `komit'"
	
	mata: kgs=st_local("kgs")
	mata: kgs=strtoreal(tokens(kgs))
	mata: kgs2=sort(kgs',1)'
	mata: kgs=invtokens(strofreal(sort(kgs',1)'))
	mata: st_local("kgs",kgs)
	
	loc kmin : word 1 of `kgs'
	loc ksize : list sizeof kgs
	loc kmax : word `ksize' of `kgs'

	* Omit right and left endpoints if trend
	
	if "`=e(trend)'"!="." { 
		if "`kmiss'"=="." loc kmiss "`kmax',`kmin'"
		else loc kmiss "`kmiss',`kmax',`kmin'"
	}
	
	
	* Estimate static overlay
	if "`overlay'"=="static" loc ovs = 1
	else loc ovs = 0
	if `ovs' {
		di as text "Estimating static model..."		
		tempname estimates bstatic Vstatic yhat samplevar
		
		gen byte `samplevar' = e(sample)
		
		loc cmdline = e(cmdline)
		parsecmdline `cmdline' samplevar(`samplevar	')
		loc cmdstatic = r(cmdstatic)
		loc cmdpredict = r(cmdpredict)
		loc depvar = e(depvar)
		
		*find name of policyvar 
		loc policyvarp = r(policyvarp)
		
		*parse impute option 
		loc impute = r(imputep)
		if  "`impute'"=="." loc impute=""
		parseimp `impute'
		loc imptype = r(imptype)
		if  "`imptype'"=="." loc imptype=""
		loc saveimp = r(saveimpl)
		if  "`saveimp'"=="." loc saveimp=""
		
		loc cmdpredict: subinstr local cmdpredict "`depvar'" "`yhat'", word	
		qui est store `estimates'
		
		*the user didn't specify impute option
		if "`impute'"==""{
			`cmdstatic'
		}
		*the user specified impute option 
		else{
			*the user indicated not to save the imputed policyvar
			if "`saveimp'"=="" {
				 
				* Check for a variable named as the imputed policyvar
				cap unab oldkvars : `policyvarp'_imputed
				if !_rc {
					di as err _n "{bf:xteventplot, overlay(static)} requieres to temporarily add the imputed policyvar to the database to estimate the static overlay, but you already have a variable named `policyvarp'_imputed."
					di as err _n "Please drop or rename this variable before proceeding."
					exit 110
				}				
				*change to save the imputed policyvar
				loc cmdstatic="`cmdstatic' impute(`imptype', saveimp)"
				`cmdstatic'
			}
			*the user indicated to save the imputed policyvar 
			else {
				loc cmdstatic=regexr("`cmdstatic'","policyvar\(*`policyvarp'*\)", "") 
				loc cmdstatic="`cmdstatic'" + " policyvar(`policyvarp'_imputed)"
				* Check id the user dropped or renamed the imputed policyvar
				cap unab oldkvars : `policyvarp'_imputed
				if _rc {
					di as err _n "When running {bf:xtevent} you had created the variable {bf:`policyvarp'_imputed}, and then it was dropped or renamed. This variable is necessary to estimate the static model."
					exit 110
				}
				`cmdstatic'		
			}
			*change to not to save the imputed policyvar for the prediction
			loc cmdpredict="`cmdpredict' impute(`imptype')"
		}
		
		qui predict `yhat'
		*had temporarily added the policyvar, drop it
		if "`impute'"!="" & "`saveimp'"=="" drop `policyvarp'_imputed
		qui `cmdpredict'
		mat `bstatic' = e(delta)
		mat `Vstatic' = e(Vdelta)		
		qui est restore `estimates'
		restoresample `samplevar'
	}
		
		
		
	
			
	* Get Wald CIs and place overlays in coef2
	
	loc i=1
	loc j=1	
	loc p=1
	qui {
		gen double `coef' = .
		gen int `post' = .
		gen byte `omitted' = .
		if "`overlay'"=="iv" loc oviv=1
		else loc oviv=0		
		if `oviv' | `ovs' {
			tempvar coef2
			gen double `coef2' = .
			if `oviv' {
				tempname ovcoef
				mat `ovcoef' = e(deltaxsc)
			}
		}
		gen double `se' = .
		gen int `kxaxis'=.
		foreach k in `kgs' {
			replace `kxaxis' = `k' in `i'			
			if inlist(`k',`komitcomma') {
				replace `coef' = 0 in `i'
				replace `se' = 0 in `i'
				replace `omitted' = 1 in `i'
				if `oviv' | `ovs' {
					replace `coef2' = 0 in `i'
				}
			}
			else if inlist(`k',`kmiss') {
				replace `coef' = . in `i'
				if `oviv' | `ovs' {
					replace `coef2' = . in `i'
				}
				replace `se' = . in `i'
				loc j=`j'+1
			}
			else {
				replace `coef' = `b'[1,`j'] in `i'
				if `oviv' {
					replace `coef2' = `ovcoef'[1,`j'] in `i'
				}
				else if `ovs' {
					replace `coef2' = `bstatic'[1,`j'] in `i'
				}
				replace `se' = `se'[1,`j'] in `i'
				loc j=`j'+1
			}
			if `k'>=0 {
				replace `post' = `p' in `i'
				loc ++ p
			}
			else {
				replace `post' = 0 in `i'
			}
			loc i=`i'+1
			
		}		
		
		* Define x axis labels, with plus at endpoints
		loc lbl ""				
		forv k=`kmin'(1)`kmax' {
			if (`k'==`kmin' | `k'==`kmax') loc lbl `"`lbl' `k' "`k'+""' /* " */			
			else loc lbl `" `lbl' `k' "`k'""' /* " */
		}
		loc xaxis=subinstr(`"`plotopts'"',"xlab","",.) /* " */
		if `"`xaxis'"' == `"`plotopts'"' loc xaxis "xlab(`lbl')" /* " */
		else loc xaxis ""
		
		
		* Confidence intervals
		if "`ci'"!="noci" {
			if `df'==. {
				* This should not happen
				di as err _n "Missing model degrees of freedom. Using t - value for large sample and 95% confidence to plot confidence intervals."
				loc ta2 = 1.96
				}
			else loc ta2 = invttail(`df',0.5*(1-c(level)/100))
			if "`levels'"=="" {	
				loc mcolor ""
				gen double `ul' = `coef' + `ta2'*`se'
				gen double `ll' = `coef' - `ta2'*`se'				
				loc cigraph "rcap `ul' `ll' `kxaxis', pstyle(ci)"
			}
			else if "`levels'"!="" {
				loc cigraph = ""		
				loc levels : list sort levels
				loc tot: list sizeof levels
				loc j=1
				foreach l in `levels' {
					loc ta2 = invttail(`df',0.5*(1-`l'/100))
					tempvar ul`l' ll`l'
					gen double `ul`l'' = `coef' + `ta2'*`se'
					gen double `ll`l'' = `coef' - `ta2'*`se'
					loc cigraph "`cigraph' rcap `ul`l'' `ll`l'' `kxaxis', pstyle(ci)"				
					if `j'!=`tot' loc cigraph "`cigraph' ||"
					loc ++j
				}				
			}
		}
		else loc cigraph ""
	}
	
	* Get sup-t CIs
	qui {
		if "`ci'"!="noci" {
			if "`supt'"!="nosupt" {
				if  "`levels'"!=""  {
					di _n "Note: Sup-t confidence interval drawn for system confidence level = `=c(level)'"
				}
				loc level=c(level)/100
				mata: supt(`suptreps',"`se'",`level')
				tempvar ulsupt llsupt
				gen double `ulsupt' = `coef' + q*`se'
				gen double `llsupt' = `coef' - q*`se'
				loc cigraphsupt "rspike `ulsupt' `llsupt' `kxaxis', pstyle(ci)"
			}
			else loc cigraphsupt ""
		}		
	}
	
	* Smoothest line through CI regions
	
	if `"`smpath'"'!="" {	
		* "
		di _n "Note: Smoothest line drawn for system confidence level = `=c(level)'"
		parsesmpath `smpath'
		loc postwindow = r(postwindow)	
		loc maxorderinput=r(maxorder) 
		loc plottype=r(plottype)		
		cap _return drop smpathparse
		_return hold smpathparse			
		qui count if `post'!=0 & `post'!=.
		if `=r(N)'<`postwindow' {
			mata: mata drop kgs kgs2
			di as err "Window for smoothest line must be smaller than window for the estimates. For a line on the entire window, omit the {bf:postwindow} option"
			exit 301
		}
		*error if user chooses order greater than 10
		if `maxorderinput'>10{
			di as err "The maximum allowed order is 10"
			exit 301
		} 
		
		if "`plottype'"=="." loc plottype "line"
				
		if !inlist("`plottype'","line","scatter","poly") {			
			di as err _n "Only scatter, line or poly allowed in  option {bf:linetype}"
			exit 301
		}
		
		tempname omitmat			
		matrix `omitmat' = (`komitcomma')			
		if `postwindow'!=0 | "`kmiss'"!="." {
			* Coefs													
			gen byte `fid' = !inlist(`kxaxis',`kmiss')
			if `postwindow'>0 qui replace `fid' = 0 if `post'>`postwindow'	
			qui replace `fid' = . if `kxaxis' ==.		
			qui putmata dhat=  `coef' if `fid', omitmissing			
			* Variance
			* strip beginning if nodrawleft				
			if `fid'[1]==0 {
				matrix `omitmat' = `omitmat' - 1
				mat `V' = `V'[2...,2...]
			}	
			* strip end if nodrawright
			if `fid'[`=`i'-1'] == 0 {
				loc Vr = rowsof(`V')-1
				loc Vc = colsof(`V')-1
				mat `V' = `V'[1..`Vr',1..`Vc']
			}				
			qui mata: Vhat = st_matrix("`V'")
			qui mata: Vhat0=Vadd0(Vhat,kgs2[1..rows(dhat)],st_matrix("`omitmat'"))							
		}
		else {				
			qui putmata dhat=  `coef', omitmissing					
			qui mata: Vhat= st_matrix("`V'")				
			qui mata: Vhat0=Vadd0(Vhat,kgs2,st_matrix("`omitmat'"))				
		}			
		
		_return restore smpathparse			
		cap qui mata:	polyline(1-st_numscalar("c(level)")/100,"r(maxiter)","r(technique)",dhat,Vhat0,"r(maxorder)",errorcodem=.,errorcodep=.,convergedm=.,convergedp=.,maxedout=.,param=.,WB=.)	
	
		mata: st_numscalar("maxedout",maxedout)		

		if !maxedout {
		
			mata: p=param
			if `postwindow'!=0 | "`kmiss'"!="." {
				getsm `fidget' `coef' `smline' p `fid'
				drop `fid'			
			}
			else getsm `fidget' `coef' `smline' p
		
			mata: st_numscalar("errorcodem",errorcodem)
			mata: st_numscalar("errorcodep",errorcodep)
			
			if (errorcodem!=. & errorcodem !=0) | (errorcodep!=. & errorcodep !=0) {				
				if (errorcodem == 8 | errorcodep ==8) {
					* This one is common so separate warning
					di "Warning: Smoothest path optimization found a flat region."
				}
				else {
					loc errorcodem = errorcodem
					loc errorcodep = errorcodep
					di "Warning: Smoothest path optimization returned an error code. Results for the smoothest path are approximate. Try changing the optimization options"
					di in smcl "Error code = `errorcodem'. See {help mf_optimize##r_error} to see what that means."
					di in smcl "Error code = `errorcodep'. See {help mf_optimize##r_error} to see what that means."
				}
			}
			mata: mata drop p `fidget'		
				
			if "`plottype'"=="scatter" {
				loc smgraph "scatter `smline' `kxaxis', pstyle(p2)"
			}
			else if  "`plottype'"=="line" {
				loc smgraph "line `smline' `kxaxis', pstyle(p1line)"
			}			
		}
		else { 
			di as txt _n "Could not find a polynomial with order<=maxorder through the Wald confidence region."
			loc smgraph ""			
		}		
			
		mata: mata drop dhat Vhat Vhat0 convergedm convergedp errorcodem errorcodep param maxedout 	
	}
	else {
		loc smgraph ""
	}
	
	* Textbox option
	if "`textboxoption'"!="" loc textbox ", `textboxoption'"
	
	* P-value for pre-trends test and value of y in label
	if "`overlay'"!="trend" {
		if "`y'"=="" & "`proxy'"=="" & "`overlay'"!="static" & "`overlay'"!="iv"& "`=e(trend)'"=="." {
			if ("`prepval'"!="noprepval") | ("`postpval'"!="nopostpval") {
				qui xteventtest, overid
				loc pvalpre : di %9.2f r(pre_p)
				loc pvalpost: di % 9.2f r(post_p)
				if "`overidpre'"!="" {
					qui xteventtest, overidpre(`overidpre')
					loc pvalpre : di %9.2f r(p)
				}
				if "`overidpost'"!="" {
					qui xteventtest, overidpost(`overidpost')
					loc pvalpost : di %9.2f r(p)
				}
			}
			if ("`prepval'"!="noprepval") loc notepre "Pretrends p-value = `pvalpre'"
			else loc notepre ""
			if ("`postpval'"!="nopostpval") {
				loc notepost "Leveling off p-value = `pvalpost'"
				if "`notepre'"!="" loc notepost "-- `notepost'"
			}
			else loc notepost ""
			loc note "`notepre' `notepost'"			
		}
		* P-value for constant effects test if overlay static 
		else if "`overlay'"=="static" {
			qui xteventtest, constanteff
			loc pval : di %9.2f r(p)
			loc note "Constant effects p-value = `pval'"
		}
		loc note "note(`note' `textbox')"
	}
	else loc note ""
	
	if "`proxy'"!="" {
		loc y1plot : di %9.4g `=e(x1)'
		loc y1plot=strtrim("`y1plot'")
		loc y1plot `""0 (`y1plot')" "'
	}
	else {
		loc y1plot : di %9.4g `=e(y1)'
		loc y1plot=strtrim("`y1plot'")
		loc y1plot `""0 (`y1plot')" "'
	}
	
	* Overlay plot for trend
	
	if "`=e(trend)'"=="trend" & "`overlay'"=="trend" { 
		mat mattrendy = e(mattrendy) 
		mat mattrendx = e(mattrendx)
		 
		tempname trendy trendx
		svmat mattrendy, names(`trendy')
		svmat mattrendx, names(`trendx')
		loc trendplot "lfit `trendy'1 `trendx'1, range(`=`kmin'+1' `=`kmax'-1')"
		
	}
		
	* Plot
	* coef2 is for overlay plots
	cap confirm var `coef2'
	if _rc loc coef2 ""	
	
	* Do not display legend unless user requires it
	loc haslegend : subinstr local options "legend" "", all
	if `"`options'"'==`"`haslegend'"' loc legend "legend(off)" /* " */
	else loc legend ""
	
	* Overlay static plots lines, other overlays plot scatter
	if "`overlay'"=="static" loc cmdov "line `coef2' `kxaxis', `staticovplotopts' || scatter `coef' `kxaxis'"
	else loc cmdov "scatter `coef' `coef2' `kxaxis'"
	
	* Line at zero by default, unless supressed
	
	if "`zeroline'"=="nozeroline" loc zeroline ""
	else loc zeroline "yline(0, lpattern(dash) lstyle(refline))"

	* Label for value of y at -1 by default, unless supressed
	if "`minus1label'"=="nominus1label" loc ylab ""
	else loc ylab "ylab(#5 0 `y1plot')"	

	tw  `smgraph' `smplotopts' || `cigraph' `ciplotopts' || `cigraphsupt' `suptciplotopts' || `cmdov' , xtitle("") ytitle("") `xaxis' pstyle(p1) `ylab' `note' msymbol(circle triangle_hollow) `scatterplotopts' || `addplots'	|| `trendplot' `trendplotopts' ||,`zeroline' `options' `legend'
	cap qui mata: mata drop kgs		
end

* Program to parse smpath options
cap program drop parsesmpath
program define parsesmpath, rclass

	syntax [anything] , [maxiter(integer 100) technique(string) postwindow(real 0) maxorder(integer 10)]
	
	return local plottype "`anything'"	
	return scalar maxiter=`maxiter'
	if `postwindow'<0 {
		mata: mata drop kgs kgs2
		di as err "option {bf:postwindow} cannot be negative."		
		exit 301
	}
	return scalar postwindow = `postwindow'
	if "`technique'"=="" loc technique "dfp"
	return local technique "`technique'"
	return scalar maxorder = `maxorder'
end	

* Program to get smline from mata
cap program drop getsm
program define getsm
	
	args fidget coef smline p fid
	
	gen long `fidget' = _n
	if "`fid'"!="" qui putmata `fidget' if !missing(`coef') & `fid' == 1
	else qui putmata `fidget' if !missing(`coef')
	qui getmata `smline'=`p', id(`fidget')
end

* Program to repost sample
cap program drop restoresample
program define restoresample, eclass
	ereturn repost, esample(`1')
end

* Program to parse cmdline and return commands for overlay static plot

cap program drop parsecmdline
program define parsecmdline, rclass
	syntax anything [aw fw pw] [if][in], samplevar(string) [Window(numlist min=1 max=2 integer) savek(string) plot proxy(string) POLicyvar(string) impute(string) *]
	
	if "`if'"=="" loc ifs "if `samplevar'"
	else loc ifs "`if' & `samplevar'"
	
	loc cmdstatic `anything' [`weight'`exp'] `ifs' `in', policyvar(`policyvar') `options' proxy(`proxy') static
	loc cmdpredict `anything' [`weight'`exp'] `if' `in', policyvar(`policyvar') window(`window') `options' proxy(`proxy')
	return local cmdstatic = "`cmdstatic'"
	return local cmdpredict = "`cmdpredict'"
	return local policyvarp = "`policyvar'"
	return local imputep = "`impute'"
	
end

*program to parse impute option
cap program drop parseimp
program define parseimp, rclass
	syntax [anything] , [saveimp]
	return local imptype "`anything'"
	return local saveimpl "`saveimp'"
end	


mata

	/* Function to add 0 to variance matrix */
	real matrix Vadd0(real matrix Vhat,
						real matrix k,
						real matrix komit)
	{
		real scalar k1, i, j, oi,oj
		real matrix kind, kindomit, V
		k1=k[1]
		kind=k:-k1:+1
		kindomit=komit:-k1:+1
		V=J(cols(k),cols(k),0)
		oi=0
		for (i=1; i<=cols(k);i++) {
			if (!anyof(kindomit,kind[i])) {
				oj=0
				for (j=1;j<=cols(k);j++) {				
					if (!anyof(kindomit,kind[j])) {				
						V[kind[i],kind[j]]=Vhat[kind[i-oi],kind[j-oj]]
					}
					else {
						oj++
					}
				}
			}
			else {
				oi++				
			}
		}	
		return(V)
	}
	
	/* Function to find the polynomial that minimizes Wald given a polynomial order, and return the polynomial and the Wald value */
	
	void polywaldmin(trfit,W,a,F,dhat,Vhatinv,normalization,r) {
		real scalar p, jj
		real matrix k, Anorm, XX, Xy, A, b, aL
		p=rows(dhat)
	
		if (r==0) {
			trfit = J(p,1,0)
			W = dhat'*Vhatinv*dhat
			a=0
		}	
		else {
			k = range(0,p-1,1)/(p-1)
			F = J(p,1,1)
			for (jj=1; jj<=r; jj++) {
				F = F, k:^jj
			}
			
			Anorm = F[normalization,.]

			XX = 2*F'*Vhatinv*F
			Xy = 2*F'*Vhatinv*dhat
			A = (XX, Anorm' \ Anorm, J(rows(normalization),rows(normalization),0))
			b = (Xy \ J(rows(normalization),rows(normalization),0))
			
			aL = qrsolve(A,b)
			a = aL[1..r+1]
			trfit = F*a
			W = (dhat-trfit)'*Vhatinv*(dhat-trfit)
			
			
		}		
	}
	
	/* Function to find minimum order to get Wald below critical value */
	
	void findorder(trfit,W0,order,F,a,dhat,Vhatinv,normalization,maxorder,Wcrit) {
		real scalar Wstart
		
		Wstart = 1e6
		
		r=0
		while (r<=maxorder & Wstart > Wcrit) {
			printf("Order %f\n",r)
			polywaldmin(trfit=.,W0=.,a=.,F=.,dhat,Vhatinv,normalization,r)
			printf("Wald value %f\n",W0)
			Wstart=W0
			r++			
		}
		order=r-1
	}
	
	/* Structure to hold inputs for optimization problem */
	
	struct inputs {
		real matrix Fb,F1,F2,Ab,A1,A2,Vhatinv,delta
		real scalar d0, Wcrit
	}
	
	/* Intermediate functions with inputs for functions to be optimized */
	
	real scalar d1(struct inputs scalar i,z) {		
		real scalar y		
		y = -2*(i.F2-i.F1*pinv(i.A1)*i.A2)'*i.Vhatinv*(i.delta-(i.Fb-i.F1*pinv(i.A1)*i.Ab)*z')
		return(y)
	}
	
	real scalar d2(struct inputs scalar i,z) {
		real scalar y
		y= (i.delta-(i.Fb-i.F1*pinv(i.A1)*i.Ab)*z')'*i.Vhatinv*(i.delta-(i.Fb-i.F1*pinv(i.A1)*i.Ab)*z') - i.Wcrit
		return(y)
	}
	
	/* Functions to be optimized */
	
	void b2m(todo,z,struct inputs scalar i,y,g,H) {		
		y = ((-d1(i,z)-sqrt(d1(i,z)^2-4*i.d0*d2(i,z)))/(2*i.d0))^2		
	}
	void b2p(todo,z,struct inputs scalar i,y,g,H) {
		y = ((-d1(i,z)+sqrt(d1(i,z)^2-4*i.d0*d2(i,z)))/(2*i.d0))^2
	}
	
	/* Optimization if number of normalized coefficients < polynomial order */
	
	void aresultless(Anorm,F,Vhatinv,delta,Wcrit,pn,a,order,errorcodem,errorcodep,convergedm,convergedp,maxiter,tech,aresult) {
		
		struct inputs scalar i
		real scalar a2m, a2p, a2, rc
		real matrix b2mp, b2pp, a1, b
		
		i.Vhatinv = Vhatinv
		i.delta = delta
		i.Wcrit = Wcrit
	
		i.Ab = Anorm[.,1..cols(Anorm)-pn-1]
		i.A1 = Anorm[.,cols(Anorm)-pn..cols(Anorm)-1]
		i.A2 = Anorm[.,cols(Anorm)]
		
		i.Fb = F[.,1..cols(F)-pn-1]
		i.F1 = F[.,cols(F)-pn..cols(F)-1]
		i.F2 = F[.,cols(F)]
		
		i.d0 = (i.F2-i.F1*pinv(i.A1)*i.A2)'*Vhatinv*(i.F2-i.F1*pinv(i.A1)*i.A2)
		
		S = optimize_init()
		optimize_init_evaluator(S,&b2m())
		optimize_init_which(S,"min")
		optimize_init_params(S,a[1..order-1,1]')
		optimize_init_argument(S,1,i)
		optimize_init_technique(S,tech)
		optimize_init_conv_maxiter(S,maxiter)
		optimize_init_conv_nrtol(S,1e-3)
		optimize_init_singularHmethod(S, "hybrid")
		(void) _optimize(S)
		rc = optimize_result_errorcode(S) 
		if (rc!=0 ) {
			errorcodem=rc		
		}		
		b2mp=optimize_result_params(S)
		convergedm=optimize_result_converged(S)
		
		
		S = optimize_init()
		optimize_init_evaluator(S,&b2p())
		optimize_init_which(S,"min")
		optimize_init_params(S,a[1..order-1,1]')
		optimize_init_argument(S,1,i)
		optimize_init_technique(S,tech)
		optimize_init_conv_maxiter(S,maxiter)
		optimize_init_singularHmethod(S, "hybrid")
		(void) _optimize(S)
		rc = optimize_result_errorcode(S) 
		if (rc!=0 ) {
			errorcodep=rc			
		}			
		b2pp=optimize_result_params(S)
		convergedp=optimize_result_converged(S)	
		
		
		a2m = (-d1(i,b2mp)-sqrt(d1(i,b2mp)^2-4*i.d0*d2(i,b2mp)))/(2*i.d0)
		a2p = (-d1(i,b2pp)+sqrt(d1(i,b2pp)^2-4*i.d0*d2(i,b2pp)))/(2*i.d0)
		
		
		if (abs(a2m) < abs(a2p)) {
			a2 = a2m
			b = b2mp'
		}
		else {
			a2 = a2p
			b = b2pp'
		}
		
		a1 = -pinv(i.A1)*(i.Ab*b+i.A2*a2)
		
		aresult = (b\a1\a2)
		
	}

	/* Solution if number of normalized coefficients = polynomial order */
	
	real matrix aresulteq(Anorm,F,Vhatinv,delta,Wcrit,pn) {
		
		real matrix A1,A2,F1,F2,a1,aresult
		real scalar d0,d1,d2,a2m,a2p,a2
		
		A1 = Anorm[.,cols(Anorm)-pn..cols(Anorm)-1]
		A2 = Anorm[.,cols(Anorm)]
		
		F1 = F[.,cols(Anorm)-pn..cols(Anorm)-1]
		F2 = F[.,cols(Anorm)]
		
		d0 = (F2-F1*pinv(A1)*A2)'*Vhatinv*(F2-F1*pinv(A1)*A2)
		d1 = -2*(F2-F1*pinv(A1)*A2)'*Vhatinv*delta
		d2 = delta'*Vhatinv*delta - Wcrit
			
		a2m = (-d1-sqrt(d1^2-4*d0*d2))/(2*d0)
		a2p = (-d1+sqrt(d1^2-4*d0*d2))/(2*d0)
		
		if (abs(a2m) < abs(a2p)) {
			a2 = a2m
		}
		else {
			a2 = a2p
		}
		
		a1 = -pinv(A1)*(A2*a2)
		
		aresult = (a1\a2)
		
		return(aresult)
	}		
	
	/* Main function */
	/* dhat, Vhat, Vhat0 are brought to mata in xteventplot.ado */
	
	void polyline(real scalar alpha,					
					string scalar Maxiter,
					string scalar Tech,					
					real matrix dhat,
					real matrix Vhat,
					string scalar Maxorder,					
					real scalar errorcodem,
					real scalar errorcodep,
					real scalar convergedm,					
					real scalar convergedp,
					real scalar maxedout,
					real matrix param,
					real matrix WB)
	{
		real matrix Vhatinv, F, a, delta, pos
		real scalar normalization, Wcrit, W0, order, maxiter, maxorder
		string scalar tech
		
		Vhatinv = pinv(Vhat)
		pos = dhat:==0
		normalization=selectindex(pos)
		maxorder = st_numscalar(Maxorder)
		
		Wcrit=invchi2(rows(dhat),1-alpha)		
		
		findorder(trfit=.,W0=.,order=.,F=.,a=.,dhat,Vhatinv,normalization,maxorder,Wcrit)
		if (order==0) {
			maxedout = 0
			param=J(rows(dhat),1,0)
		}
		else if (order==maxorder) {
			param=.
			maxedout=1
		}
		else {
			maxedout=0
			delta=dhat
		
			Anorm = F[normalization,.]
			pn = rows(normalization)
				
			maxiter = st_numscalar(Maxiter)
		
			tech = st_global(Tech)	
			
			if (pn<order) {		
				aresultless(Anorm,F,Vhatinv,delta,Wcrit,pn,a,order,errorcodem=.,errorcodep=.,convergedm=.,convergedp=.,maxiter,tech,aresult=.)
			}
			else if (pn==order) {
				aresult=aresulteq(Anorm,F,Vhatinv,delta,Wcrit,pn)	
			}
			else {
				aresult=.
			}
			
			param=F*aresult
			WB = (dhat-trfit)'*Vhatinv*(dhat-trfit)
		}
			
	}
		
	void supt(real scalar suptreps,
				string scalar se,
				real scalar level
	)
	{	real matrix senum,rmv,mv,means,var,sd,std,am
		real scalar q
	
		senum = st_matrix(se)
		rmv=rnormal(suptreps,1,J(1,cols(senum),0),senum)
		mv = meanvariance(rmv)
		means = mv[1,.]
		var   = mv[|2,1 \ .,.|]
		sd = sqrt(diagonal(var))'
		std = (rmv :- means):/sd
		am = rowmax(abs(std))
		q = mm_quantile(am,1,level)		
		st_numscalar("q",q)
	}

	real matrix mm_quantile(real matrix X, | real colvector w,
	 real matrix P, real scalar altdef)
	{
		real rowvector result
		real scalar c, cX, cP, r, i

		if (args()<2) w = 1
		if (args()<3) P = (0, .25, .50, .75, 1)'
		if (args()<4) altdef = 0
		if (cols(X)==1 & cols(P)!=1 & rows(P)==1)
		 return(mm_quantile(X, w, P', altdef)')
		if (missing(P) | missing(X) | missing(w)) _error(3351)
		if (rows(w)!=1 & rows(w)!=rows(X)) _error(3200)
		r = rows(P)
		c = max(((cX=cols(X)), (cP=cols(P))))
		if (cX!=1 & cX<c) _error(3200)
		if (cP!=1 & cP<c) _error(3200)
		if (rows(X)==0 | r==0 | c==0) return(J(r,c,.))
		if (c==1) return(_mm_quantile(X, w, P, altdef))
		result = J(r, c, .)
		if (cP==1) for (i=1; i<=c; i++)
		 result[,i] = _mm_quantile(X[,i], w, P, altdef)
		else if (cX==1) for (i=1; i<=c; i++)
		 result[,i] = _mm_quantile(X, w, P[,i], altdef)
		else for (i=1; i<=c; i++)
		 result[,i] = _mm_quantile(X[,i], w, P[,i], altdef)
		return(result)
	}

	real colvector _mm_quantile(
	 real colvector X,
	 real colvector w,
	 real colvector P,
	 real scalar altdef)
	{
		real colvector g, j, j1, p
		real scalar N

		if (w!=1) return(_mm_quantilew(X, w, P, altdef))
		N = rows(X)
		p = order(X,1)
		if (altdef) g = P*N + P
		else g = P*N
		j = floor(g)
		if (altdef) g = g - j
		else g = 0.5 :+ 0.5*((g - j):>0)
		j1 = j:+1
		j = j :* (j:>=1)
		_editvalue(j, 0, 1)
		j = j :* (j:<=N)
		_editvalue(j, 0, N)
		j1 = j1 :* (j1:>=1)
		_editvalue(j1, 0, 1)
		j1 = j1 :* (j1:<=N)
		_editvalue(j1, 0, N)
		return((1:-g):*X[p[j]] + g:*X[p[j1]])
	}

	real colvector _mm_quantilew(
	 real colvector X,
	 real colvector w,
	 real colvector P,
	 real scalar altdef)
	{
		real colvector Q, pi, pj
		real scalar i, I, j, jj, J, rsum, W
		pointer scalar ww

		I  = rows(X)
		ww = (rows(w)==1 ? &J(I,1,w) : &w)
		if (altdef) return(_mm_quantilewalt(X, *ww, P))
		W  = quadsum(*ww)
		pi = order(X, 1)
		if (anyof(*ww, 0)) {
			pi = select(pi,(*ww)[pi]:!=0)
			I = rows(pi)
		}
		pj = order(P, 1)
		J  = rows(P)
		Q  = J(J, 1, .)
		j  = 1
		jj = pj[1]
		rsum = 0
		for (i=1; i<=I; i++) {
			rsum = rsum + (*ww)[pi[i]]
			if (i<I) {
				if (rsum<P[jj]*W) continue
				if (X[pi[i]]==X[pi[i+1]]) continue
			}
			while (1) {
				if (rsum>P[jj]*W | i==I) Q[jj] = X[pi[i]]
				else Q[jj] = (X[pi[i]] + X[pi[i+1]])/2
				j++
				if (j>J) break
				jj = pj[j]
				if (i<I & rsum<P[jj]*W) break
			}
			if (j>J) break
		}
		return(Q)
	}

	real colvector _mm_quantilewalt(
	 real colvector X,
	 real colvector w,
	 real colvector P)
	{
		real colvector Q, pi, pj
		real scalar i, I, j, jj, J, rsum, rsum0, W, ub, g

		W  = quadsum(w) + 1
		pi = order(X, 1)
		if (anyof(w, 0)) pi = select(pi, w[pi]:!=0)
		I  = rows(pi)
		pj = order(P, 1)
		J  = rows(P)
		Q  = J(J, 1, .)
		rsum = w[pi[1]]
		for (j=1; j<=J; j++) {
			jj = pj[j]
			if (P[jj]*W <= rsum) Q[jj] = X[pi[1]]
			else break
		}
		for (i=2; i<=I; i++) {
			rsum0 = rsum
			rsum = rsum + w[pi[i]]
			if (i<I & rsum < P[jj]*W) continue
			while (1) {
				ub = rsum0+1
				if (P[jj]*W>=ub | X[pi[i]]==X[pi[i-1]]) Q[jj] = X[pi[i]]
				else {
					g = (ub - P[jj]*W) / (ub - rsum0)
					Q[jj] = X[pi[i-1]]*g + X[pi[i]]*(1-g)
				}
				j++
				if (j>J) break
				jj = pj[j]
				if (i<I & rsum < P[jj]*W) break
			}
			if (j>J) break
		}
		return(Q)
	}
end


		


