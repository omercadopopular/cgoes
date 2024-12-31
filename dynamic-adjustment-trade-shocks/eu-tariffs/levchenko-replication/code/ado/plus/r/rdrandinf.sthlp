{smcl}
{* *! version 1.0 07Jul2021}{...}
{viewerjumpto "Syntax" "rdrandinf##syntax"}{...}
{viewerjumpto "Description" "rdrandinf##description"}{...}
{viewerjumpto "Options" "rdrandinf##options"}{...}
{viewerjumpto "Examples" "rdrandinf##examples"}{...}
{viewerjumpto "Saved results" "rdrandinf##saved_results"}{...}
{viewerjumpto "References" "rdrandinf##references"}{...}
{viewerjumpto "Authors" "rdrandinf##authors"}{...}

{title:Title}

{p 4 8}{cmd:rdrandinf} {hline 2} Randomization Inference for RD Designs under Local Randomization.{p_end}


{marker syntax}{...}
{title:Syntax}

{p 4 8}{cmd:rdrandinf} {it:outvar} {it:runvar} {ifin} 
[{cmd:,} 
{cmd:{opt c:utoff}(}{it:#}{cmd:)} 
{cmd:wl(}{it:#}{cmd:)} 
{cmd:wr(}{it:#}{cmd:)} 
{cmd:{opt stat:istic}(}{it:stat_name}{cmd:)} 
{cmd:p(}{it:#}{cmd:)} 
{cmd:evall(}{it:#}{cmd:)} 
{cmd:evalr(}{it:#}{cmd:)} 
{cmd:kernel(}{it:kerneltype}{cmd:)} 
{cmd:fuzzy(}{it:fuzzy_var [fuzzy_stat]}{cmd:)} 
{cmd:{opt null:tau}(}{it:#}{cmd:)}
{cmd:d(}{it:#}{cmd:)} 
{cmd:dscale(}{it:#}{cmd:)}
{cmd:ci(}{it:level [tlist]}{cmd:)} 
{cmd:{opt interf:ci}(}{it:#}{cmd:)} 
{cmd:{opt be:rnoulli}(}{it:varname}{cmd:)} 
{cmd:reps(}{it:#}{cmd:)} 
{cmd:seed(}{it:#}{cmd:)}
{cmd:{opt cov:ariates}(}{it:varlist}{cmd:)} 
{cmd:obsmin(}{it:#}{cmd:)}
{cmd:wmin(}{it:# #}{cmd:)}
{cmd:wobs(}{it:#}{cmd:)}
{cmd:wstep(}{it:#}{cmd:)}
{cmd:{opt wasym:metric}}
{cmd:{opt wmass:points}}
{cmd:{opt nw:indows}(}{it:#}{cmd:)}
{cmd:rdwstat(}{it:stat_name}{cmd:)}
{cmd:{opt dropmiss:ing}}
{cmd:{opt approx:imate}}
{cmd:rdwreps(}{it:#}{cmd:)}
{cmd:level(}{it:#}{cmd:)}
{cmd:plot}
{cmd:graph_options(}{it:graphopts}{cmd:)}
{cmd:obsstep(}{it:#}{cmd:)}
{cmd:{opt qui:etly}}
]{p_end}

{synoptset 28 tabbed}{...}

{marker description}{...}
{title:Description}

{p 4 8}{cmd:rdrandinf} implements randomization inference and related methods for regression discontinuity (RD) designs, employing observations in a specified or data-driven selected window around the cutoff where local randomization is assumed to hold. See
{browse "https://rdpackages.github.io/references/Cattaneo-Frandsen-Titiunik_2015_JCI.pdf":Cattaneo, Frandsen and Titiunik (2015)}
and
{browse "https://rdpackages.github.io/references/Cattaneo-Titiunik-VazquezBare_2017_JPAM.pdf":Cattaneo, Titiunik and Vazquez-Bare (2017)}
for an introduction to this methodology.{p_end}

{p 4 8}A detailed introduction to this command is given in
{browse "https://rdpackages.github.io/references/Cattaneo-Titiunik-VazquezBare_2016_Stata.pdf":Cattaneo, Titiunik and Vazquez-Bare (2016)}.{p_end}
{p 8 8}Companion {browse "www.r-project.org":R} functions are also available {browse "https://rdpackages.github.io/rdlocrand":here}.{p_end}

{p 4 8}Companion functions are {help rdrandinf:rdwinselect}, {help rdsensitivity:rdsensitivity} and {help rdrbounds:rdrbounds}.{p_end}

{p 4 8}Related Stata and R packages useful for inference in RD designs are described in the following website:{p_end}

{p 8 8}{browse "https://rdpackages.github.io/":https://rdpackages.github.io/}{p_end}


{marker options}{...}
{title:Options}

{p 4 8}{cmd:{opt c:utoff}(}{it:#}{cmd:)} specifies the RD cutoff for the running variable {it:runvar}.
Default is {cmd:cutoff(0)}.{p_end}

{dlgtab:Window selection}

{p 4 8}{cmd:wl(}{it:#}{cmd:)} specifies the left limit of the window. Default is the minimum value of the running variable. {p_end}

{p 4 8}{cmd:wr(}{it:#}{cmd:)} specifies the right limit of the window. Default is the maximum value of the running variable. {p_end}

{dlgtab:Statistic}

{p 4 8}{cmd:{opt stat:istic}(}{it:stat_name}{cmd:)} specifies the statistic to be used. Options are:{p_end}
{p 8 12}{opt diffmeans} for difference in means statistic. This is the default option.{p_end}
{p 8 12}{opt ksmirnov} for Kolmogorov-Smirnov statistic.{p_end}
{p 8 12}{opt ranksum} for Wilcoxon-Mann-Whitney studentized statistic.{p_end}
{p 8 12}{opt all} for all three statistics.{p_end}
{p 8 12} The option {opt ttest} is equivalent to {opt diffmeans} and included for backward compatibility. {p_end}

{p 4 8}{cmd:p(}{it:#}{cmd:)} specifies the order of the polynomial for outcome adjustment model.
Default is {cmd:p(0)} (constant treatment effect model).{p_end}

{p 4 8}{cmd:evall(}{it:#}{cmd:)} specifies the point at the left of the cutoff at which the adjusted outcome is evaluated. Default is the cutoff value.{p_end}

{p 4 8}{cmd:evalr(}{it:#}{cmd:)} specifies the point at the right of the cutoff at which the adjusted outcome is evaluated. Default is the cutoff value.{p_end}

{p 4 8}{cmd:kernel(}{it:kerneltype}{cmd:)}  specifies the type of kernel to use as weighting scheme. Allowed kernel types are {cmd:uniform} (uniform kernel), {cmd:triangular} (triangular kernel) and {cmd:epan} (Epanechnikov kernel). 
Default is {cmd:kernel(uniform)}.{p_end}

{p 4 8}{cmd:fuzzy(}{it:fuzzy_var [fuzzy_stat]}{cmd:)} name of the endogenous treatment variable in fuzzy design. Options for statistic in fuzzy designs are:{p_end}
{p 8 12}{cmd:itt} for the intention-to-treat (ITT) statistic (this is the default option),{p_end}
{p 8 12}{cmd:tsls} for the two-stage least squares (TSLS) statistic (asymptotic approximation only).{p_end}

{dlgtab:Inference}

{p 4 8}{cmd:{opt null:tau}(}{it:#}{cmd:)} sets the value of the treatment effect under the null hypothesis.
Default is {cmd:nulltau(0)}.{p_end}

{p 4 8}{cmd:d(}{it:#}{cmd:)} effect size for asymptotic power calculation. Default is 0.5 * standard deviation of outcome variable for the control group.{p_end}

{p 4 8}{cmd:dscale(}{it:#}{cmd:)} specifies fraction of the standard deviation of the outcome variable for the control group used as alternative hypothesis for asymptotic power calculation. Default is {cmd: dscale(.5)}.{p_end}

{p 4 8}{cmd:ci(}{it:alpha [tlist]}{cmd:)} calculates a confidence interval for the treatment effect by test inversion, where {it: alpha} specifies the significance level (typically 0.05 or 0.01)
and {it: tlist} indicates the grid of treatment effects to be evaluated.
This option uses {cmd:rdsensitivity} to calculate the confidence interval. See {help rdsensitivity:rdsensitivity} for details.
Note: the default tlist can be narrow in some cases, which may truncate the confidence interval. We recommend the user to manually set a large enough tlist.{p_end}

{p 4 8}{cmd:{opt interf:ci}(}{it:#}{cmd:)} sets the significance level (alpha) for Rosenbaum's confidence interval under arbitrary interference between units.{p_end}

{p 4 8}{cmd:{opt be:rnoulli}(}{it:varname}{cmd:)} specifies that the randomization mechanism is Bernoulli trials (instead of fixed margins randomization). 
The values of the probability of treatment for each unit must be provided in the variable {cmd: varname}.{p_end}

{p 4 8}{cmd:reps(}{it:#}{cmd:)} specifies the number of replications. Default is {cmd: reps(1000)}.{p_end}

{p 4 8}{cmd:seed(}{it:#}{cmd:)} sets the seed for the permutation test. With this option, the user can manually set the desired seed, or can enter the value -1 to use the system seed.
Default is {cmd:seed(666)}.{p_end}

{dlgtab:Options for rdwinselect}

{p 4 8}When the window around the cutoff is not specified, {cmd:rdrandinf} can select the window automatically using the companion command {help rdwinselect:rdwinselect}. The following options are available:{p_end}

{p 4 8}{cmd:{opt cov:ariates}(}{it:varlist}{cmd:)} specifies the covariates employed by the companion command {help rdwinselect:rdwinselect}.{p_end}

{p 4 8}{cmd:obsmin(}{it:#}{cmd:)} specifies the minimum number of observations above and below the cutoff in the smallest window employed by the companion command {help rdwinselect:rdwinselect}. Default is {cmd:obsmin(10)}.{p_end}

{p 4 8}{cmd:wmin(}{it:# #}{cmd:)} specifies the initial window to be used (if {cmd: obsmin(}{it:#}{cmd:)} is not specified).
Can be a single number to specify the length of the (symmetric) initial window, or two numbers to specify the left and right limits of the initial window.
Specifying both {cmd:wmin(}{it:#}{cmd:)} and {cmd:obsmin(}{it:#}{cmd:)} returns an error.{p_end}

{p 4 8}{cmd:wobs(}{it:#}{cmd:)} specifies the number of observations to be added at each side of the cutoff at each step.
Default is {cmd:wobs(5)}.{p_end}

{p 4 8}{cmd:wstep(}{it:#}{cmd:)} specifies the increment in window length (if {cmd:obsstep(}{it:#}{cmd:)} is not specified) by the companion command {help rdwinselect:rdwinselect}.
Specifying both {cmd:wobs(}{it:#}{cmd:)} and {cmd:wstep(}{it:#}{cmd:)} returns an error.{p_end}

{p 4 8}{cmd:{opt wasym:metric}} allows for asymmetric windows around the cutoff (when {cmd:wobs(}{it:#}{cmd:)} is specified).{p_end}

{p 4 8}{cmd:{opt wmass:points}} specifies that the running variable is discrete and each masspoint should be used as a window.{p_end}

{p 4 8}{cmd:{opt nw:indows}(}{it:#}{cmd:)} specifies the number of windows to be used by the companion command {help rdwinselect:rdwinselect}. Default is {cmd:nwindows(10)}.{p_end}

{p 4 8}{cmd:{opt dropmiss:ing}} drop rows with missing values in covariates when calculating windows.{p_end}

{p 4 8}{cmd:rdwstat(}{it:#}{cmd:)} specifies the statistic to be used by the companion command {help rdwinselect:rdwinselect} (see help file for options). Default option is {cmd:rdwstat(diffmeans)}.{p_end}

{p 4 8}{cmd:{opt approx:imate}} specifies that covariate balance tests should use a large-sample approximation instead of finite-sample exact randomization inference methods.{p_end}

{p 4 8}{cmd:rdwreps(}{it:#}{cmd:)} specifies the number of replications to be used by the companion command {help rdwinselect:rdwinselect}. Default is {cmd:rdwreps(1000)}.{p_end}

{p 4 8}{cmd:level(}{it:#}{cmd:)} specifies the minimum accepted value of the p-value from the covariate balance tests to be used by the companion command {help rdwinselect:rdwinselect}. Default is {cmd:level(.15)}.{p_end}

{p 4 8}{cmd:plot} draws a scatter plot of the minimum p-value from the covariate balance test against window length implemented by the companion command {help rdwinselect:rdwinselect}.{p_end}

{p 4 8}{cmd:graph_options(}{it:graphopts}{cmd:)} graph options for plot generated by the companion command {help rdwinselect:rdwinselect}.{p_end}

{p 4 8}{cmd:{opt qui:etly}} supress output from  the companion command {help rdwinselect:rdwinselect}.{p_end}

{p 4 8}{cmd:obsstep(}{it:#}{cmd:)} specifies the minimum number of observations to be added on each side of the cutoff by the companion command {help rdwinselect:rdwinselect}.
This option is deprecated and only included for backward compatibility.{p_end}

    {hline}
	
		
{marker examples}{...}
{title:Example: Cattaneo, Frandsen and Titiunik (2015) Incumbency Data}

{p 4 8}Setup{p_end}
{p 8 8}{cmd:. use rdlocrand_senate.dta, clear}{p_end}

{p 4 8}Randomization inference with user-specified window and default options{p_end}
{p 8 8}{cmd:. rdrandinf demvoteshfor2 demmv, cutoff(0) wl(-.75) wr(.75)}{p_end}

{p 4 8}Randomization inference with all statistics{p_end}
{p 8 8}{cmd:. rdrandinf demvoteshfor2 demmv, cutoff(0) wl(-.75) wr(.75) stat(all)}{p_end}

{p 4 8}Randomization inference with triangular weights{p_end}
{p 8 8}{cmd:. rdrandinf demvoteshfor2 demmv, cutoff(0) wl(-.75) wr(.75) kernel(triangular)}{p_end}

{p 4 8}Randomization inference on the Kolmogorov-Smirnov statistic with {cmd:rdwinselect} window options{p_end}
{p 8 8}{cmd:. rdrandinf demvoteshfor2 demmv, cutoff(0) statistic(ksmirnov) covariates(dopen population demvoteshlag1) wmin(.5) wstep(.125)}{p_end}

{p 4 8}Randomization inference with linear adjustment {p_end}
{p 8 8}{cmd:. rdrandinf demvoteshfor2 demmv, cutoff(0) wl(-.75) wr(.75) p(1)}{p_end}

{p 4 8}Randomization inference under Bernoulli trials with .5 probability of treatment{p_end}
{p 8 8}{cmd:. gen probs=.5}{p_end}
{p 8 8}{cmd:. rdrandinf demvoteshfor2 demmv, cutoff(0) wl(-.75) wr(.75) bernoulli(probs)}{p_end}

{p 4 8}Confidence interval under interference{p_end}
{p 8 8}{cmd:. rdrandinf demvoteshfor2 demmv, cutoff(0) wl(-.75) wr(.75) interfci(.05)}{p_end}

{p 4 8}Confidence interval for the treatment effect{p_end}
{p 8 8}{cmd:. rdrandinf demvoteshfor2 demmv, wl(-.75) wr(.75) ci(.05 3(1)20)}{p_end}

{p 4 8}Linear adjustment with effects evaluated at the mean of the running variable{p_end}
{p 8 8}{cmd:. qui sum demmv if abs(demmv)<=.75 & demmv>=0 & demmv!=. & demvoteshfor2!=.}{p_end}
{p 8 8}{cmd:. local mt=r(mean)}{p_end}
{p 8 8}{cmd:. qui sum demmv if abs(demmv)<=.75 & demmv<0  & demmv!=. & demvoteshfor2!=.}{p_end}
{p 8 8}{cmd:. local mc=r(mean)}{p_end}
{p 8 8}{cmd:. rdrandinf demvoteshfor2 demmv, wl(-.75) wr(.75) p(1) evall(`mc') evalr(`mt')}{p_end}

{marker saved_results}{...}
{title:Saved results}

{p 4 8}{cmd:rdrandinf} saves the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(wl)}} left end of window used{p_end}
{synopt:{cmd:r(wr)}} right end of window used{p_end}
{synopt:{cmd:r(N)}} sample size in used window{p_end}
{synopt:{cmd:r(N_left)}} sample size in used window to the left of the cutoff {p_end}
{synopt:{cmd:r(N_right)}} sample size in used window to the right of the cutoff {p_end}
{synopt:{cmd:r(p)}} order of polynomial in adjusted model{p_end}
{synopt:{cmd:r(obs_stat)}} observed statistic{p_end}
{synopt:{cmd:r(randpval)}} randomization p-value{p_end}
{synopt:{cmd:r(asy_pval)}} asymptotic p-value{p_end}
{synopt:{cmd:r(ci_lb)}} lower limit of confidence interval (if {cmd:ci} option is specified) {p_end}
{synopt:{cmd:r(ci_ub)}} upper limit of confidence interval (if {cmd:ci} option is specified) {p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Locals}{p_end}
{synopt:{cmd:r(seed)}} seed used in permutations {p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(obs_stat)}} matrix of observed statistics (when {cmd:all} is specified){p_end}
{synopt:{cmd:r(asy_pval)}} matrix of asymptotic p-values (when {cmd:all} is specified){p_end}
{synopt:{cmd:r(p_val)}} matrix of p-values (when {cmd:all} is specified){p_end}
		

{marker references}{...}
{title:References}

{p 4 8}Cattaneo, M. D., Frandsen, B., and R. Titiunik. 2015.
{browse "https://rdpackages.github.io/references/Cattaneo-Frandsen-Titiunik_2015_JCI.pdf":Randomization Inference in the Regression Discontinuity Design: An Application to Party Advantages in the U.S. Senate}.{p_end}
{p 8 8}{it:Journal of Causal Inference} 3(1): 1-24.{p_end}

{p 4 8}Cattaneo, M.D., Titiunik, R. and G. Vazquez-Bare. 2016.
{browse "https://rdpackages.github.io/references/Cattaneo-Titiunik-VazquezBare_2016_Stata.pdf":Inference in Regression Discontinuity Designs under Local Randomization}.{p_end}
{p 8 8}{it:Stata Journal} 16(2): 331-367.{p_end}

{p 4 8}Cattaneo, M. D., Titiunik, R. and G. Vazquez-Bare. 2017.
{browse "https://rdpackages.github.io/references/Cattaneo-Titiunik-VazquezBare_2017_JPAM.pdf":Comparing Inference Approaches for RD Designs: A Reexamination of the Effect of Head Start on Child Mortality}.{p_end}
{p 8 8}{it:Journal of Policy Analysis and Management} 36(3): 643-681.{p_end}


{marker authors}{...}
{title:Authors}

{p 4 8}Matias D. Cattaneo, Princeton University, Princeton, NJ.
{browse "mailto:cattaneo@princeton.edu":cattaneo@princeton.edu}.{p_end}

{p 4 8}Rocio Titiunik, Princeton University, Princeton, NJ.
{browse "mailto:titiunik@princeton.edu":titiunik@princeton.edu}.{p_end}

{p 4 8}Gonzalo Vazquez-Bare, UC Santa Barbara, Santa Barbara, CA.
{browse "mailto:gvazquez@econ.ucsb.edu":gvazquez@econ.ucsb.edu}.{p_end}


