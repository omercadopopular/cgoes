{smcl}
{* *! version 2.0 Jun 24 2022}{...}
{cmd:help xtevent}
{hline}

{title:Title}

{phang}
{bf:xtevent} {hline 2} Estimation of Panel Event Study


{marker syntax}{...}
{title:Syntax}

{pstd}

{p 8 17 2}
{cmd:xtevent}
{depvar} [{indepvars}]
{ifin}
{cmd:,}
{opth pol:icyvar(varname)}
{opth p:anelvar(varname)}
{opth t:imevar(varname)}
[{it:options}]

{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{p2coldent:* {opth pol:icyvar(varname)}} policy variable{p_end}
{synopt: {opth p:anelvar(varname)}} variable that identifies the panels{p_end}
{synopt: {opth t:imevar(varname)}} variable that identifies the time periods{p_end}
{synopt: {opth w:indow(numlist)}} # of periods in the estimation window{p_end}
{synopt: {opth pre(integer)}} # of periods with anticipation effects{p_end}
{synopt: {opth post(integer)}} # of periods with policy effects{p_end}
{synopt: {opth overidpre(integer)}} # of periods to test pre-trends{p_end}
{synopt: {opth overidpost(integer)}} # of periods to test effects leveling off
{p_end}
{synopt:{opth norm(integer)}} event-time coefficient to normalize to 0{p_end}
{synopt:{opth proxy(varname)}} proxy for the confound{p_end}
{synopt:{opt proxyiv(string)}} instruments for the proxy variable{p_end}
{synopt:{opt nofe}} omit panel fixed effects {p_end}
{synopt:{opt note}} omit time fixed effects {p_end}
{synopt: {opt impute(type, [saveimp])}} impute missing values in policyvar{p_end}
{synopt:{opt st:atic}} estimate static model {p_end}
{synopt:{opt diffavg}} estimate the difference in averages between the post and pre-periods {p_end}
{synopt:{opt tr:end(#1, [subopt])}} extrapolate linear trend from time period #1 before treatment{p_end}
{synopt:{opt sav:ek(stub)}} save time-to-event, event-time and trend variables{p_end}
{synopt: {opt kvars(stub)}} use previously generated even-time variables{p_end}
{synopt:{opt reghdfe}} use {help reghdfe} for estimation{p_end}
{synopt:{opt addabsorb(varlist)}} absorb additional variables in {help reghdfe}{p_end}
{synopt:{opt plot}} display plot. See {help xteventplot}.{p_end} 
{synopt:{it: additional_options}} additional options to be passed to estimation command{p_end}
{synoptline}
{p2colreset}{...}

{p 4 6 2} {it: depvar} and {it:indepvars} may contain time-series operators; see{help tsvarlist}.{p_end}
{p 4 6 2} {it: depvar} and {it:indepvars} may contain factor variables; see{help fvvarlist}.{p_end}

{p 4 6 2}* {opt policyvar(varname)} is required. {opt window(integer)} is required unless {opt static}, or {opt pre}, {opt post},
{opt overidpre} and {opt overidpost} are specified. {opt panelvar(varname)} and {opt timevar(varname)} are required if the data 
have not been {cmd:xtset}, otherwise they are optional. See {help xtset}. {p_end}
{p 4 6 2}
See {help xteventtest} for hypothesis testing after estimation and {help xteventplot} for plotting after estimation.{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd: xtevent} estimates the effect of a policy variable of interest on a dependent variable using a panel event
study design. Additional control variables can be included in {it:varlist}. The command allows for estimation when a pre-trend is present using
the instrumental variables estimator of Freyaldenhoven et al. (2019). {p_end}


{marker options}{...}
{title:Options}
 
{dlgtab:Main}

{phang}
{opth policyvar(varname)} specifies the policy variable of interest. {opt policyvar()} is required.

{dlgtab:Estimation}

{phang}
{opth panelvar(varname)} specifies the cross-sectional identifier variable that identifies the panels. {cmd:panelvar()} is required if the data
have not been previously {cmd:xtset}. See {help xtset}.

{phang}
{opth timevar(varname)} specifies the time variable. {cmd:timevar()} is required if the data have not been previously {cmd:xtset}. See
{help xtset}.

{phang}
{opth window(numlist)} specifies the window around the policy change event to estimate dynamic effects. If a single positive integer {it:k}>0 
is specified, the estimation will use a symmetric window of {it:k} periods around the event. For example, if {it:k} = 2, there will be five 
coefficients in the window (-2,-1,0,1,2) and two endpoints (-3+, 3+). If two distinct integers {it:k1}<=0 and {it:k2}>=0 are specified, the 
estimation will use an asymmetric window with {it:k1} periods before the event and {it:k2} periods after the event. For example, with {it:k1} = -1 
and {it:k2} = 2, there will be four coefficients in the window (-1,0,1,2) and two endpoints (-2+,3+). {opt window()} is required unless 
{opt static} is specified, or if the estimation window is specified using  options {opt pre()}, {opt post()}, {opt overidpre()} 
and {opt overidpost()} (See below).

{phang}
{opt pre},
{opt post}, 
{opt overidpre} and 
{opt overidpost} offer an alternative way to specify the estimation window:

{phang2} {opt pre} is the number of pre-event periods where anticipation effects are allowed. With {opt window}, {opt pre} is 0.

{phang2} {opt post} is the number of post-event periods where policy effects are allowed. With {opt window}, {opt post} is the number
of periods after the event minus 2.

{phang2} {opt overidpre} is the number of pre-event periods for an overidentification test of pre-trends. With {opt window}, {opt overidpre}
is the number of periods before the event.

{phang2} {opt overidpost} is the number of post-event periods for an overidentification test of effects leveling off. With {opt window},
{opt overidpost} is 2.

{phang} You can specify either {opt window}  or 
{opt pre},
{opt post}, 
{opt overidpre} and 
{opt overidpost}. 

{phang} {opth norm(integer)} specifies the event-time coefficient to be normalized to 0.
The default is to normalize the coefficient on -1.

{phang}
{opth proxy(varlist)} specifies proxy variables for the confound to be included.

{phang}
{opth proxyiv(string)} specifies instruments for the proxy variable for the policy. {opth proxyiv()} admits three syntaxes to use 
either leads of the policy variable or aditional variables as instruments. The default is to use leads of the difference of the
policy variable as instruments, selecting the lead with the strongest first stage. 

{phang2}
{cmd:proxyiv(select)} selects the lead with the strongest first stage among all possible leads of the differenced policy variable to 
be used as an instrument.
{cmd:proxyiv(select)} is the default for the one proxy, one instrument case, and it is only available in this case. 

{phang2}
{cmd:proxyiv(# ...)} specifies a numlist with the leads of the differenced policy variable as instruments. For example, 
{cmd:proxyiv(1 2)} specifies that the two first leads of the difference of the policy variable will be used as instruments.

{phang2}
{cmd:proxyiv(varlist)} specifies a {it:varlist} with the additional variables to be used as instruments.

{phang}
{opt nofe} excludes panel fixed effects.

{phang}
{opt note} excludes time fixed effects.

{phang}
{opt impute(type, [saveimp])} imputes missing values in {it:policyvar} and uses this new variable as the actual {it:policyvar}. 
{cmd:type} determines the imputation rule. The suboption {cmd:saveimp} adds the new variable to the database as 
{it:policyvar_imputed}. The following imputation types ca be implemented:

{phang2}
{cmd:impute(nuchange)} imputes missing values in {it:policyvar} according to {it:no-unobserved change}: it assumes that, 
for each unit: i) in periods before the first observed value, the policy value is the same as the first observed value; and
 ii) in periods after the last observed value, the policy value is the same as the last observed value.

{phang2}
{cmd:impute(stag)} applies {it:no-unobserved change} if {it:policyvar} satisfies staggered-adoption assumptions for all units: i) {it:policyvar} must be binary; and ii) once {it:policyvar} reaches the adopted-policy state, 
it never reverts to the unadopted-policy state. See Freyaldenhoven et al. (2019) for detailed explanation of the staggered case. Additionally in the {it:policyvar}, for each unit: i) the first-observed value must be 
the unadopted-policy-state value, and the last-observed value must be the adopted-policy-state value; or ii) all policy values in the observed data range must be either adopted-policy-state values or unadopted-policy-state values.  

{phang2}
{cmd:impute(instag)} applies {opt impute(stag)} and additionally imputes missing values inside the observed data range: a missing value or a group of them will be imputed only if they are both preceded and followed by the unadopted-policy state 
or by the adopted-policy state. 

{phang}
{opt static} estimates a static panel data model and does not generate or plot event-time dummies. {opt static} is not allowed with {opt window} or {opt diffavg}.

{phang}
{opt diffavg} calculates the difference in averages between the post-event estimated coefficients and the pre-event estimated coefficients periods. It also
calculates its standard error with {help lincom}. {opt diffavg} is not allowed with {opt static}.

{phang}
{opt tr:end(#1, [subopt])} extrapolates a linear trend between time periods from period #1 before the policy change, as in Dobkin et al. (2018). The estimated
effect of the policy is the deviation from the extrapolated linear trend. #1 must be less than -1. The following can be passed as suboptions:

{phang2}
{opt method(string)} sets the method to estimate the linear trend. It can be Ordinary Least Squares {opt (ols)} or Generalized Method of Moments {opt (gmm)}. {opt (ols)} omits the event-time dummies from {opt trend(#1)} to -1 and adds a linear 
trend (_ttrend) to the regression. {opt (gmm)} uses the GMM to compute the trend for the event-time dummy coefficients. The default is {opt method(gmm)}.

{phang2}
{opt saveov:erlay} saves estimations for the overlay plot produced by {opt xteventplot, overlay(trend)}.

{phang}
{opt savek(stub)} saves variables for event-time dummies, event-time and trends. Event-time dummies are stored as {it: stub}_eq_m# for the dummy
variable # periods before the policy change, and {it:stub}_p# for the dummy variable # periods after the policy change. The dummy variable for
the policy change time is {it:stub}_p0. Event time is stored as {it:stub}_evtime. The trend is stored as {it:stub}_trend.

{phang}
{opt usek(stub)} uses previously used event-time dummies saved with prefix {it:stub}. This can be used to speed up estimation.

{phang}
{opt reghdfe} uses {help reghdfe} for estimation, instead of {help areg}, {help ivregress} and {help xtivreg}. {opt reghdfe} is useful for large 
datasets. By default, it absorbs the panel fixed effects and the time fixed effects. For OLS estimation, the {opt reghdfe}
option requires {help reghdfe} and {help ftools} to be installed. For IV estimation, it also requires {help ivreghdfe} and {help ivreg2} to be installed.
Note that standard errors may be different and singleton clusters may be dropped using {help reghdfe}. See Correia (2017).

{phang}
{opt addabsorb(varlist)} specifies additional fixed effects to be absorbed when using {help reghdfe}. By default, {cmd xtevent} includes time and
unit fixed effects. {opt addabsorb} requires {opt reghdfe}.

{phang}
{opt plot} displays a default event study plot with 95% and sup-t confidence intervals (Montiel Olea and Plagborg-Møller 2019).
Additional options are available with the postestimation command {help xteventplot}.

{phang}
{it: additional_options}: Additional options to be passed to the estimation command. When {opt proxy} is specified, these options are passed
to {help ivregress}. When {opt reghdfe} is specified, these options are passed to {help reghdfe}. Otherwise, they are passed to {help areg} or
to {help regress} if {opt nofe} is specified. This is useful to calculate clustered standard errors or to change regression reporting. Note
that two-way clustering is allowed with {help reghdfe}.  



{title:Examples}

{hline}
{pstd}Setup{p_end}
{phang2}{cmd:. webuse nlswork}{p_end}
{phang2}{cmd:. xtset idcode year}{p_end}

{hline}
{pstd}Basic event study with clustered standard errors{p_end}
{phang2}{cmd:. xtevent ln_w age c.age#c.age ttl_exp c.ttl_exp#c.ttl_exp}
   {cmd: tenure , pol(union) w(3) cluster(idcode)}
{p_end}

{pstd}Omit fixed effects{p_end}
{phang2}{cmd:. xtevent ln_w age c.age#c.age ttl_exp c.ttl_exp#c.ttl_exp}
   {cmd: tenure , pol(union) w(3) cluster(idcode) nofe}
{p_end}
{phang2}{cmd:. xtevent ln_w age c.age#c.age ttl_exp c.ttl_exp#c.ttl_exp}
   {cmd: tenure , pol(union) w(3) cluster(idcode) nofe note}
{p_end}

{pstd}Save event-time dummies{p_end}
{phang2}{cmd:. xtevent ln_w age c.age#c.age ttl_exp c.ttl_exp#c.ttl_exp}
   {cmd: tenure , pol(union) w(3) cluster(idcode) savek(a)}
{p_end}

{pstd}Change normalization, asymmetric window{p_end}
{phang2}{cmd:. xtevent ln_w age c.age#c.age ttl_exp c.ttl_exp#c.ttl_exp}
   {cmd: tenure , pol(union) w(-3 1) norm(-2) cluster(idcode)}
{p_end}

{pstd}Adjust by estimating a linear trend with gmm method {p_end}
{phang2}{cmd:. xtevent ln_w age c.age#c.age ttl_exp c.ttl_exp#c.ttl_exp}
   {cmd: tenure , pol(union) w(2) trend(-2, method(gmm)) cluster(idcode)}
{p_end}

{pstd}Impute the policy variable without verifying staggered adoption{p_end}
{phang2}{cmd:. xtevent ln_w age c.age#c.age ttl_exp c.ttl_exp#c.ttl_exp}
   {cmd: tenure , pol(union) w(3) cluster(idcode) impute(nuchange)}
{p_end}

{pstd}Impute outer and inner missing values in the policy variable verifying staggered adoption:{p_end}
{pstd}
Based on the original policy variable, generate a policy variable that follows staggered-adoption
{p_end}
{phang2}
{cmd:. by idcode (year): egen maxval= max(union)}
{p_end}
{phang2}
{cmd:. by idcode (year): gen union2=sum(union) if !missing(union)}
{p_end}
{phang2}
{cmd:. replace union2=1 if union2>1 & !missing(union2)}
{p_end}
{phang2}
{cmd:. by idcode (year): egen pmean=mean(union2)}
{p_end}
{phang2}
{cmd:. by idcode (year): replace union2=union2[_n-1] if missing(union2)}
{cmd: & inlist(pmean,0,1)}
{p_end}
{pstd}
Run the regression using the new policy variable
{p_end}
{phang2}{cmd:. xtevent ln_w age c.age#c.age ttl_exp c.ttl_exp#c.ttl_exp}
   {cmd: tenure if inlist(maxval,0,1), pol(union2) w(3) cluster(idcode) impute(instag, saveimp)}
{p_end}
{pstd}
Compare the imputed and original values for a unit
{p_end}
{phang2}
{cmd:. list idcode year union2 union2_imputed if idcode==6}
{p_end}


{hline}

{pstd}FHS estimator with proxy variables{p_end}
{phang2}{cmd:. xtevent ln_w age c.age#c.age ttl_exp c.ttl_exp#c.ttl_exp}
   {cmd: tenure , pol(union) w(3) vce(cluster idcode) proxy(wks_work)}
{p_end}

{pstd}Additional lags and proxys{p_end}
{phang2}{cmd:. xtevent ln_w age c.age#c.age ttl_exp c.ttl_exp#c.ttl_exp}
   {cmd: tenure , pol(union) w(3) vce(cluster idcode) proxy(wks_work hours) proxyiv(1 2)}
{p_end}

{pstd}{help reghdfe} and two-way clustering {p_end}
{phang2}{cmd:. xtevent ln_w age c.age#c.age ttl_exp c.ttl_exp#c.ttl_exp}
   {cmd: tenure , pol(union) w(3) cluster(idcode year) reghdfe proxy(wks_work)}
{p_end}


{marker saved}{...}
{title:Saved Results}

{pstd}
{cmd:xtevent} saves the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(lwindow)}}left endpoint for estimation window{p_end}
{synopt:{cmd:e(rwindow)}}right endpoint for estimation window{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(names)}}names of the variables for the event-time dummies{p_end}
{synopt:{cmd:e(y1)}}mean of dependent variable et event-time = -1{p_end}
{synopt:{cmd:e(x1)}}mean of proxy variable et event-time = -1, when only one proxy is specified{p_end}
{synopt:{cmd:e(trend)}}"trend" if estimation included extrapolation of a linear trend{p_end}
{synopt:{cmd:e(cmd)}}estimation command: can be {help regress}, {help areg}, {help ivregress}, {help xtivreg}, or {help reghdfe}
{p_end}
{synopt:{cmd:e(df)}}degrees of freedom{p_end}
{synopt:{cmd:e(komit)}}list of lags/leads omitted from regression{p_end}
{synopt:{cmd:e(kmiss)}}list of lags/leads to be omitted from plot{p_end}
{synopt:{cmd:e(method)}}"ols" or "iv"{p_end}
{synopt:{cmd:e(cmd2)}}"xtevent"{p_end}
{synopt:{cmd:e(depvar)}}dependent variable{p_end}
{synopt:{cmd:e(pre)}}number of periods with anticipation effects{p_end}
{synopt:{cmd:e(post)}}number of periods with policy effects{p_end}
{synopt:{cmd:e(overidpre)}}number of periods to test for pre-trends{p_end}
{synopt:{cmd:e(overidpost)}}number of periods to test for effects leveling off{p_end}
{synopt:{cmd:e(stub)}}prefix for saved event-time dummy variables{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix{p_end}
{synopt:{cmd:e(delta)}}coefficient vector of event-time dummies{p_end}
{synopt:{cmd:e(Vdelta)}}variance-covariance matrix of the event-time dummies coefficients{p_end}
{synopt:{cmd:e(deltax)}} coefficients for proxy event study to be used in overlay plot{p_end}
{synopt:{cmd:e(deltaxsc)}}scaled coefficients for proxy event study to be used in overlay plot{p_end}
{synopt:{cmd:e(deltaov)}}coefficients for event study to be used in overlay plot{p_end}
{synopt:{cmd:e(Vdeltax)}} variance-covariance matrix of proxy event study coefficients for overlay plot{p_end}
{synopt:{cmd:e(Vdeltax)}} variance-covariance matrix of event study coefficients for overlay plot{p_end}
{synopt:{cmd:e(mattrendy)}} matrix with y-axis values of trend for overlay plot, only when {opt trend(#1)} is specified{p_end}
{synopt:{cmd:e(mattrendx)}} matrix with x-axis values of trend for overlay plot, only when {opt trend(#1)} is specified{p_end}


{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}

{title:Authors}

{pstd}Simon Freyaldenhoven, Federal Reserve Bank of Philadelphia.{p_end}
       simon.freyaldenhoven@phil.frb.org
{pstd}Christian Hansen, University of Chicago, Booth School of Business.{p_end}
       chansen1@chicagobooth.edu
{pstd}Jorge Pérez Pérez, Banco de México{p_end}
       jorgepp@banxico.org.mx
{pstd}Jesse Shapiro, Brown University{p_end}
       jesse_shapiro_1@brown.edu	   
           
{title:Support}    
           
{pstd}For support and to report bugs please email Jorge Pérez Pérez, Banco de México.{break} 
       jorgepp@banxico.org.mx   
       
{title:References}

{pstd}Correia, S. (2017) . "Linear Models with High-Dimensional Fixed Effects: An Efficient and Feasible Estimator" Working Paper. {browse "http://scorreia.com/research/hdfe.pdf"} 

{pstd}Dobkin, C., Finkelstein A., Kluender. R., and Notowidigdo, M. J. (2018) "The Economic Consequences of Hospital Admissions."
{it:American Economic Review}, 108 (2): 308-52.

{pstd}Freyaldenhoven, S., Hansen, C. and Shapiro, J. (2019) "Pre-event Trends in the Panel Event-study Design" {it:American Economic Review}, 109 (9):
3307-38.

{pstd}Freyaldenhoven, S., Hansen, C., Pérez Pérez, J. and Shapiro, J. (2021) "Visualization, Identification, 
and Estimation in the Linear Panel Event-study Design". Working paper.

{pstd}Montiel Olea, J.L.  and Plagborg-Møller, M. (2019) "Simultaneous confidence bands: Theory, implementation, and an application to SVARs".
{it:Journal of Applied Econometrics}, 34: 1– 17.

{title:Acknowledgements}
{pstd}We are grateful to Veli Andirin, Mauricio Cáceres, Constantino Carreto, Ángel Espinoza, Samuele Giambra, Ray Huang, Diego
Mayorga, Stefano Molina, Asjad Naqvi, Anna Pasnau, Nathan Schor, and Matthias Weigand  for testing early versions of this 
command.


