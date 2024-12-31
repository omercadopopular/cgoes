{smcl}
{* *! version 2.0 05-Jul-2021}{...}
{viewerjumpto "Syntax" "rdmde##syntax"}{...}
{viewerjumpto "Description" "rdmde##description"}{...}
{viewerjumpto "Options" "rdmde##options"}{...}
{viewerjumpto "Examples" "rdmde##examples"}{...}
{viewerjumpto "Saved results" "rdmde##saved_results"}{...}
{viewerjumpto "References" "rdmde##references"}{...}
{viewerjumpto "Authors" "rdmde##authors"}{...}


{title:Title}

{p 4 8}{cmd:rdmde} {hline 2} Minimum Detectable Effect calculation for Regression Discontinuity designs using robust bias-corrected local polynomial inference.{p_end}


{marker syntax}{...}
{title:Syntax}

{p 4 8}{cmd:rdmde} {it:depvar} {it:runvar} {ifin} 
[{cmd:,} 
{cmd:c(}{it:#}{cmd:)} 
{cmd:alpha(}{it:#}{cmd:)} 
{cmd:beta(}{it:#}{cmd:)} 
{cmd:{opt ns:amples}(}{it:# # # #}{cmd:)} 
{cmd:sampsi(}{it:# #}{cmd:)} 
{cmd:samph(}{it:# #}{cmd:)}
{cmd:all}
{cmd:bias(}{it:# #}{cmd:)}
{cmd:{opt var:iance}(}{it:# #}{cmd:)}
{cmd:init_cond(}{it:#}{cmd:)}
{cmd:covs(}{it:covars}{cmd:)}
{cmd:covs_drop(}{it:covsdropoption}{cmd:)}
{cmd:deriv(}{it:#}{cmd:)}
{cmd:p(}{it:#}{cmd:)} 
{cmd:q(}{it:#}{cmd:)}
{cmd:h(}{it:# #}{cmd:)} 
{cmd:b(}{it:# #}{cmd:)}
{cmd:rho(}{it:#}{cmd:)}
{cmd:fuzzy(}{it:fuzzyvar [sharpbw]}{cmd:)}
{cmd:kernel(}{it:kernelfn}{cmd:)}
{cmd:bwselect(}{it:bwmethod}{cmd:)}
{cmd:vce(}{it:vcetype [vceopt1 vceopt2]}{cmd:)}
{cmd:weights(}{it:weightsvar}{cmd:)}
{cmd:scalepar(}{it:#}{cmd:)}
{cmd:scaleregul(}{it:#}{cmd:)}
{cmd:masspoints(}{it:masspointsoption}{cmd:)}
{cmd:bwcheck(}{it:#}{cmd:)}
{cmd:bwrestrict(}{it:bwropt}{cmd:)}
{cmd:stdvars(}{it:stdopt}{cmd:)}
]{p_end}

{synoptset 28 tabbed}{...}

{marker description}{...}
{title:Description}

{p 4 8}{cmd:rdmde} provides MDE calculations in Regression Discontinuity designs using conventional and robust bias-corrected local polynomial methods.
Companion commands are: {help rdpow:rdpow} for power calculations and {help rdsampsi:rdsampsi} for sample size calculations.{p_end}

{p 8 8}A detailed introduction to this command is given in
{browse "https://rdpackages.github.io/references/Cattaneo-Titiunik-VazquezBare_2019_Stata.pdf": Cattaneo, Titiunik and Vazquez-Bare (2019)}.{p_end}

{p 8 8}Companion {browse "www.r-project.org":R} functions are also available {browse "https://rdpackages.github.io/rdpower":here}.{p_end}

{p 8 8}This command employs the Stata (and R) package {help rdrobust:rdrobust} for underlying calculations. See
{browse "https://rdpackages.github.io/references/Calonico-Cattaneo-Titiunik_2014_Stata.pdf":Calonico, Cattaneo and Titiunik (2014)}
and
{browse "https://rdpackages.github.io/references/Calonico-Cattaneo-Farrell-Titiunik_2017_Stata.pdf":Calonico, Cattaneo, Farrell and Titiunik (2017)}
for more details.{p_end}

{p 4 8}Related Stata and R packages useful for inference in RD designs are described in the following website:{p_end}

{p 8 8}{browse "https://rdpackages.github.io/":https://rdpackages.github.io/}{p_end}


{marker options}{...}
{title:Options}

{dlgtab:rdmde options}

{p 4 8}{cmd:c(}{it:#}{cmd:)} specifies the RD cutoff for {it:indepvar}.
Default is {cmd:c(0)}.{p_end}

{p 4 8}{cmd:alpha(}{it:#}{cmd:)} specifies the significance level for the power function.
Default is {cmd:alpha(.05)}.{p_end}

{p 4 8}{cmd:beta(}{it:#}{cmd:)} specifies the desired power.
Default is {cmd:beta(.8)}.{p_end}

{p 4 8}{cmd:{opt ns:amples}(}{it:# # # #}{cmd:)}  sets the total sample size to the left, sample size to the left inside the bandwidth, total sample size to the right and sample size to the right of the cutoff inside the bandwidth 
to calculate the variance when the running variable is not specified.
When this option is not specified, the values are calculated using the running variable.{p_end}

{p 4 8}{cmd:sampsi(}{it:# #}{cmd:)} sets the sample size at each side of the cutoff for power calculation. The first number is the sample size to the left of the cutoff and the second number is the sample size to the right.
Default values are the sample sizes inside the chosen bandwidth.{p_end}

{p 4 8}{cmd:samph(}{it:# #}{cmd:)} sets the bandwidths at each side of the cutoff for power calculation. The first number is the bandwidth to the left of the cutoff and the second number is the bandwidth to the right. 
Default values are the bandwidths used by {cmd:rdrobust}.{p_end}

{p 4 8}{cmd:all} displays the power using the conventional variance estimator, in addition to the robust bias corrected one.{p_end}

{p 4 8}{cmd:bias(}{it:# #}{cmd:)} allows the user to set bias to the left and right of the cutoff. If not specified, the biases are estimated using {cmd:rdrobust}.{p_end}

{p 4 8}{cmd:{opt var:iance}(}{it:# #}{cmd:)} allows the user to set variance to the left and right of the cutoff. If not specified, the variances are estimated using {cmd:rdrobust}.{p_end}

{p 4 8}{cmd:init_cond(}{it:#}{cmd:)} sets the initial condition for the Newton-Raphson algorithm that finds the MDE.
Default is 0.2 times the standard deviation of the outcome below the cutoff.{p_end}


{dlgtab:rdrobust options}

{p 4 8 }The following options are passed directly to {cmd:rdrobust}:

{p 4 8}{cmd:covs(}{it:covars}{cmd:)} specifies additional covariates to be used for estimation and inference.{p_end}

{p 4 8}{cmd:covs_drop(}{it:covsdropoption}{cmd:)} specifies options to assess collinearity in covariates to be used for estimation and inference. Option {opt on} drops collinear additional covariates (default choice). Option {opt off} only checks collinear additional covariates but does not drop them.{p_end}

{p 4 8}{cmd:deriv(}{it:#}{cmd:)} specifies the order of the derivative of the regression functions to be estimated.
Default is {cmd:deriv(0)}. Setting {cmd:deriv(1)} results in estimation of a Kink RD design (up to scale).{p_end}

{p 4 8}{cmd:p(}{it:#}{cmd:)} specifies the order of the local polynomial used to construct the point estimator.
Default is {cmd:p(1)} (local linear regression).{p_end}

{p 4 8}{cmd:q(}{it:#}{cmd:)} specifies the order of the local polynomial used to construct the bias correction.
Default is {cmd:q(2)} (local quadratic regression).{p_end}

{p 4 8}{cmd:h(}{it:# #}{cmd:)} specifies the main bandwidth ({it:h}) used to construct the RD point estimator. If not specified, bandwidth {it:h} is computed by the companion command {help rdbwselect:rdbwselect}.
If two bandwidths are specified, the first bandwidth is used for the data below the cutoff and the second bandwidth is used for the data above the cutoff.{p_end}

{p 4 8}{cmd:b(}{it:# #}{cmd:)} specifies the bias bandwidth ({it:b}) used to construct the bias-correction estimator. If not specified, bandwidth {it:b} is computed by the companion command {help rdbwselect:rdbwselect}.
If two bandwidths are specified, the first bandwidth is used for the data below the cutoff and the second bandwidth is used for the data above the cutoff.{p_end}

{p 4 8}{cmd:rho(}{it:#}{cmd:)} specifies the value of {it:rho}, so that the bias bandwidth {it:b} equals {it:b}={it:h}/{it:rho}.
Default is {cmd:rho(1)} if {it:h} is specified but {it:b} is not.{p_end}

{p 4 8}{cmd:fuzzy(}{it:fuzzyvar [sharpbw]}{cmd:)} specifies the treatment status variable used to implement fuzzy RD estimation (or Fuzzy Kink RD if {cmd:deriv(1)} is also specified).
Default is Sharp RD design and hence this option is not used.
If the option {it:sharpbw} is set, the fuzzy RD estimation is performed using a bandwidth selection procedure for the sharp RD model. This option is automatically selected if there is perfect compliance at either side of the threshold.{p_end}

{p 4 8}{cmd:kernel(}{it:kernelfn}{cmd:)} specifies the kernel function used to construct the local-polynomial estimator(s). Options are: {opt tri:angular}, {opt epa:nechnikov}, and {opt uni:form}.
Default is {cmd:kernel(triangular)}.{p_end}

{p 4 8}{cmd:bwselect(}{it:bwmethod}{cmd:)} specifies the bandwidth selection procedure to be used. By default it computes both {it:h} and {it:b}, unless {it:rho} is specified, in which case it only computes {it:h} and sets {it:b}={it:h}/{it:rho}.
Options are:{p_end}
{p 8 12}{opt mserd} one common MSE-optimal bandwidth selector for the RD treatment effect estimator.{p_end}
{p 8 12}{opt msetwo} two different MSE-optimal bandwidth selectors (below and above the cutoff) for the RD treatment effect estimator.{p_end}
{p 8 12}{opt msesum} one common MSE-optimal bandwidth selector for the sum of regression estimates (as opposed to difference thereof).{p_end}
{p 8 12}{opt msecomb1} for min({opt mserd},{opt msesum}).{p_end}
{p 8 12}{opt msecomb2} for median({opt msetwo},{opt mserd},{opt msesum}), for each side of the cutoff separately.{p_end}
{p 8 12}{opt cerrd} one common CER-optimal bandwidth selector for the RD treatment effect estimator.{p_end}
{p 8 12}{opt certwo} two different CER-optimal bandwidth selectors (below and above the cutoff) for the RD treatment effect estimator.{p_end}
{p 8 12}{opt cersum} one common CER-optimal bandwidth selector for the sum of regression estimates (as opposed to difference thereof).{p_end}
{p 8 12}{opt cercomb1} for min({opt cerrd},{opt cersum}).{p_end}
{p 8 12}{opt cercomb2} for median({opt certwo},{opt cerrd},{opt cersum}), for each side of the cutoff separately.{p_end}
{p 8 12}Note: MSE = Mean Square Error; CER = Coverage Error Rate.{p_end}
{p 8 12}Default is {cmd:bwselect(mserd)}. For details on implementation, see {help rdbwselect:rdbwselect} and references therein.{p_end}

{p 4 8}{cmd:vce(}{it:vcetype [vceopt1 vceopt2]}{cmd:)} specifies the procedure used to compute the variance-covariance matrix estimator.
Options are:{p_end}
{p 8 12}{cmd:vce(nn }{it:[nnmatch]}{cmd:)} for heteroskedasticity-robust nearest neighbor variance estimator with {it:nnmatch} indicating the minimum number of neighbors to be used.{p_end}
{p 8 12}{cmd:vce(hc0)} for heteroskedasticity-robust plug-in residuals variance estimator without weights.{p_end}
{p 8 12}{cmd:vce(hc1)} for heteroskedasticity-robust plug-in residuals variance estimator with {it:hc1} weights.{p_end}
{p 8 12}{cmd:vce(hc2)} for heteroskedasticity-robust plug-in residuals variance estimator with {it:hc2} weights.{p_end}
{p 8 12}{cmd:vce(hc3)} for heteroskedasticity-robust plug-in residuals variance estimator with {it:hc3} weights.{p_end}
{p 8 12}{cmd:vce(nncluster }{it:clustervar [nnmatch]}{cmd:)} for cluster-robust nearest neighbor variance estimation using with {it:clustervar} indicating the cluster ID variable and {it: nnmatch} matches indicating the minimum number of neighbors to be used.{p_end}
{p 8 12}{cmd:vce(cluster }{it:clustervar}{cmd:)} for cluster-robust plug-in residuals variance estimation with degrees-of-freedom weights and {it:clustervar} indicating the cluster ID variable.{p_end}
{p 8 12}Default is {cmd:vce(nn 3)}.{p_end}

{p 4 8}{cmd:weights(}{it:weightsvar}{cmd:)} is the variable used for optional weighting of the estimation procedure. The unit-specific weights multiply the kernel function.{p_end}

{p 4 8}{cmd:scalepar(}{it:#}{cmd:)} specifies scaling factor for RD parameter of interest. This option is useful when the estimator of interest requires a known multiplicative factor rescaling (e.g., Sharp Kink RD).
Default is {cmd:scalepar(1)} (no rescaling).{p_end}

{p 4 8}{cmd:scaleregul(}{it:#}{cmd:)} specifies scaling factor for the regularization term added to the denominator of the bandwidth selectors. Setting {cmd:scaleregul(0)} removes the regularization term from the bandwidth selectors.
Default is {cmd:scaleregul(1)}.{p_end}

{p 4 8}{cmd:masspoints(}{it:masspointsoption}{cmd:)} checks and controls for repeated observations in the running variable. 
Options are:{p_end}
{p 8 12}{opt off}  ignores the presence of mass points. {p_end}
{p 8 12}{opt check}  looks for and reports the number of unique observations at each side of the cutoff.   {p_end}
{p 8 12}{opt adjust}  controls that the preliminary bandwidths used in the calculations contain a minimal number of unique observations. By default it uses 10 observations, but it can be manually adjusted with the option {cmd:bwcheck}.{p_end}
{p 8 12} Default option is {cmd:masspoints(adjust)}.{p_end}
		
{p 4 8}{cmd:bwcheck(}{it:bwcheck}{cmd:)} if a positive integer is provided, the preliminary bandwidth used in the calculations is enlarged so that at least {it:bwcheck} unique observations are used. {p_end}
  
{p 4 8}{cmd:bwrestrict(}{it:bwropt}{cmd:)} if set {opt on}, computed bandwidths are restricted to lie within the range of {it:runvar}. Default is {opt on}.{p_end}

{p 4 8}{cmd:stdvars(}{it:stdopt}{cmd:)} if set {opt on}, {it:depvar} and {it:runvar} are standardized before computing the bandwidths. Default is {opt off}.{p_end}

    {hline}
	
		
{marker examples}{...}
{title:Example: Cattaneo, Frandsen and Titiunik (2015) Incumbency Data}

{p 4 8}Setup{p_end}
{p 8 8}{cmd:. use rdpower_senate.dta}{p_end}

{p 4 8}MDE calculation with default values{p_end}
{p 8 8}{cmd:. rdmde demvoteshfor2 demmv}{p_end}

{p 4 8}MDE calculation with user-specified bandwidths{p_end}
{p 8 8}{cmd:. rdmde demvoteshfor2 demmv, samph(12 13)}{p_end}

{p 4 8}MDE calculation with user-specified sample sizes{p_end}
{p 8 8}{cmd:. rdmde demvoteshfor2 demmv, sampsi(350 320)}{p_end}

{p 4 8}Power function plot with default options{p_end}
{p 8 8}{cmd:. rdpow demvoteshfor2 demmv, tau(5) plot}{p_end}

{p 4 8}Power function plot with user-specified range and step{p_end}
{p 8 8}{cmd:. rdpow demvoteshfor2 demmv, tau(5) plot graph_range(-9 9) graph_step(2)}{p_end}

{p 4 8}Power function plot with user-specified options{p_end}
{p 8 8}{cmd:. rdpow demvoteshfor2 demmv, tau(5) plot graph_range(-9 9) graph_step(2) graph_options(title(Power function) xline(0, lcolor(black) lpattern(dash))  xtitle(tau) ytitle(power) graphregion(fcolor(white)))}{p_end}

{marker saved_results}{...}
{title:Saved results}

{p 4 8}{cmd:rdpow} saves the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(alpha)}}significance level used in power function{p_end}
{synopt:{cmd:r(beta)}}desired power{p_end}
{synopt:{cmd:r(mde)}}calculated MDE{p_end}
{synopt:{cmd:r(N_h_l)}}sample size in bandwidth to the left used to calculate variance{p_end}
{synopt:{cmd:r(N_h_r)}}sample size in bandwidth to the right used to calculate variance{p_end}
{synopt:{cmd:r(N_l)}}sample size to the left used to calculate variance{p_end}
{synopt:{cmd:r(N_r)}}sample size to the right used to calculate variance{p_end}
{synopt:{cmd:r(samph_l)}}bandwidth to the left of the cutoff{p_end}
{synopt:{cmd:r(samph_r)}}bandwidth to the right of the cutoff{p_end}
{synopt:{cmd:r(sampsi_l)}}number of observations inside the window to the left of the cutoff{p_end}
{synopt:{cmd:r(sampsi_r)}}number of observations inside the window to the right of the cutoff{p_end}
{synopt:{cmd:r(se_rbc)}}robust bias corrected standard error{p_end}
{synopt:{cmd:r(power_rbc)}}power against tau using robust bias corrected standard error{p_end}
{synopt:{cmd:r(se_conv)}}conventional standard error{p_end}
{synopt:{cmd:r(power_conv)}}power against tau using conventional standard error{p_end}
{synopt:{cmd:r(Vl_rb)}}robust variance to the left of the cutoff{p_end}
{synopt:{cmd:r(Vr_rb)}}robust variance to the left of the cutoff{p_end}
{synopt:{cmd:r(bias_l)}}bias to the left of the cutoff{p_end}
{synopt:{cmd:r(bias_r)}}bias to the left of the cutoff{p_end}
{synopt:{cmd:r(init_cond)}}initial condition of the Newton-Raphson algorithm{p_end}


{marker references}{...}
{title:References}

{p 4 8}Calonico, S., M. D. Cattaneo, M. H. Farrell, and R. Titiunik. 2017.
{browse "https://rdpackages.github.io/references/Calonico-Cattaneo-Farrell-Titiunik_2017_Stata.pdf":rdrobust: Software for Regression Discontinuity Designs}.{p_end}
{p 8 8}{it:Stata Journal} 17(2): 372-404.{p_end}

{p 4 8}Calonico, S., M. D. Cattaneo, and R. Titiunik. 2014.
{browse "https://rdpackages.github.io/references/Calonico-Cattaneo-Titiunik_2014_Stata.pdf":Robust Data-Driven Inference in the Regression-Discontinuity Design}.{p_end}
{p 8 8}{it:Stata Journal} 14(4): 909-946.{p_end}

{p 4 8}Cattaneo, M. D., Frandsen, B., and R. Titiunik. 2015.
{browse "https://rdpackages.github.io/references/Cattaneo-Frandsen-Titiunik_2015_JCI.pdf":Randomization Inference in the Regression Discontinuity Design: An Application to Party Advantages in the U.S. Senate}.{p_end}
{p 8 8}{it:Journal of Causal Inference} 3(1): 1-24.{p_end}

{p 4 8}Cattaneo, M. D., R. Titiunik, and G. Vazquez-Bare. 2019.
{browse "https://rdpackages.github.io/references/Cattaneo-Titiunik-VazquezBare_2019_Stata.pdf":Power Calculations for Regression Discontinuity Designs}.{p_end}
{p 8 8}{it:Stata Journal} 19(1): 210-245.{p_end}


{marker authors}{...}
{title:Authors}

{p 4 8}Matias D. Cattaneo, Princeton University, Princeton, NJ.
{browse "mailto:cattaneo@princeton.edu":cattaneo@princeton.edu}.{p_end}

{p 4 8}Rocio Titiunik, Princeton University, Princeton, NJ.
{browse "mailto:titiunik@princeton.edu":titiunik@princeton.edu}.{p_end}

{p 4 8}Gonzalo Vazquez-Bare, UC Santa Barbara, Santa Barbara, CA.
{browse "mailto:gvazquez@econ.ucsb.edu":gvazquez@econ.ucsb.edu}.{p_end}


