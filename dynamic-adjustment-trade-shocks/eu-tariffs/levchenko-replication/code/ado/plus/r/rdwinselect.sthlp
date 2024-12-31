{smcl}
{* *! version 1.0 07Jul2021}{...}
{viewerjumpto "Syntax" "rdwinselect##syntax"}{...}
{viewerjumpto "Description" "rdwinselect##description"}{...}
{viewerjumpto "Options" "rdwinselect##options"}{...}
{viewerjumpto "Examples" "rdwinselect##examples"}{...}
{viewerjumpto "Saved results" "rdwinselect##saved_results"}{...}
{viewerjumpto "References" "rdwinselect##references"}{...}
{viewerjumpto "Authors" "rdwinselect##authors"}{...}

{title:Title}

{p 4 8}{cmd:rdwinselect} {hline 2} Window selection procedure for RD designs under local randomization.{p_end}


{marker syntax}{...}
{title:Syntax}

{p 4 8}{cmd:rdwinselect} {it:runvar} [{it:covariates}] {ifin} 
[{cmd:,} 
{cmd:{opt c:utoff}(}{it:#}{cmd:)}
{cmd:obsmin(}{it:#}{cmd:)}
{cmd:wmin(}{it:# #}{cmd:)}
{cmd:wobs(}{it:#}{cmd:)}
{cmd:wstep(}{it:#}{cmd:)}
{cmd:{opt wasym:metric}}
{cmd:{opt wmass:points}}
{cmd:{opt nw:indows}(}{it:#}{cmd:)}
{cmd:{opt dropmiss:ing}}
{cmd:{opt stat:istic}(}{it:stat_name}{cmd:)} 
{cmd:p(}{it:#}{cmd:)}
{cmd:evalat(}{it:point}{cmd:)}
{cmd:kernel(}{it:kerneltype}{cmd:)}
{cmd:{opt approx:imate}}
{cmd:level(}{it:#}{cmd:)}
{cmd:reps(}{it:#}{cmd:)}
{cmd:seed(}{it:#}{cmd:)}
{cmd:plot}
{cmd:graph_options(}{it:graphopts}{cmd:)}
{cmd:genvars}
{cmd:obsstep(}{it:#}{cmd:)}
]

{synoptset 28 tabbed}{...}

{marker description}{...}
{title:Description}

{p 4 8}{cmd:rdwinselect} implements window selection procedure based balance tests for regression discontinuity (RD) designs under local randomization. Specifically, it constructs a sequence of nested windows around the RD cutoff and reports binomial tests for running variable {it:runvar} and covariate balance tests for covariates {it:covariates} (if specified). The recommended window is the largest window around the cutoff such that the minimum p-values of the balance tests is larger than a pre-specified level for all nested (smaller) windows. By default, the p-values are calculated employing randomization inference methods. See
{browse "https://rdpackages.github.io/references/Cattaneo-Frandsen-Titiunik_2015_JCI.pdf":Cattaneo, Frandsen and Titiunik (2015)}
and
{browse "https://rdpackages.github.io/references/Cattaneo-Titiunik-VazquezBare_2017_JPAM.pdf":Cattaneo, Titiunik and Vazquez-Bare (2017)}
for an introduction to this methodology.{p_end}

{p 4 8}A detailed introduction to this command is given in
{browse "https://rdpackages.github.io/references/Cattaneo-Titiunik-VazquezBare_2016_Stata.pdf":Cattaneo, Titiunik and Vazquez-Bare (2016)}.{p_end}
{p 8 8}Companion {browse "www.r-project.org":R} functions are also available {browse "https://rdpackages.github.io/rdlocrand":here}.{p_end}

{p 4 8}Companion functions are {help rdrandinf:rdrandinf}, {help rdsensitivity:rdsensitivity} and {help rdrbounds:rdrbounds}.{p_end}

{p 4 8}Related Stata and R packages useful for inference in RD designs are described in the following website:{p_end}

{p 8 8}{browse "https://rdpackages.github.io/":https://rdpackages.github.io/}{p_end}


{marker options}{...}
{title:Options}

{p 4 8}{cmd:{opt c:utoff}(}{it:#}{cmd:)} specifies the RD cutoff for the running variable {it:runvar}.
Default is {cmd:cutoff(0)}.{p_end}

{dlgtab:Window selection}

{p 4 8}{cmd:obsmin(}{it:#}{cmd:)} specifies the minimum number of observations above and below the cutoff in the smallest window.
Default is {cmd:obsmin(10)}.{p_end}

{p 4 8}{cmd:wmin(}{it:# #}{cmd:)} specifies the initial window to be used (if {cmd: obsmin(}{it:#}{cmd:)} is not specified).
Can be a single number to specify the length of the (symmetric) initial window, or two numbers to specify the left and right limits of the initial window.
Specifying both {cmd:wmin(}{it:#}{cmd:)} and {cmd:obsmin(}{it:#}{cmd:)} returns an error.{p_end}

{p 4 8}{cmd:wobs(}{it:#}{cmd:)} specifies the number of observations to be added at each side of the cutoff at each step.
Default is {cmd:wobs(5)}.{p_end}

{p 4 8}{cmd:wstep(}{it:#}{cmd:)} specifies the increment in window length.
Specifying both {cmd:wobs(}{it:#}{cmd:)} and {cmd:wstep(}{it:#}{cmd:)} returns an error.{p_end}

{p 4 8}{cmd:{opt wasym:metric}} allows for asymmetric windows around the cutoff (when {cmd:wobs(}{it:#}{cmd:)} is specified).{p_end}

{p 4 8}{cmd:{opt wmass:points}} specifies that the running variable is discrete and each masspoint should be used as a window.{p_end}

{p 4 8}{cmd:{opt nw:indows}(}{it:#}{cmd:)} specifies the number of windows to be used.
Default is {cmd:nwindows(10)}.{p_end}

{p 4 8}{cmd:{opt dropmiss:ing}} drop rows with missing values in covariates when calculating windows.{p_end}

{dlgtab:Statistic}

{p 4 8}{cmd:{opt stat:istic}(}{it:stat_name}{cmd:)} specifies the statistic to be used. Options are:{p_end}
{p 8 12}{opt diffmeans} for difference in means statistic. This is the default option.{p_end}
{p 8 12}{opt ksmirnov} for Kolmogorov-Smirnov statistic.{p_end}
{p 8 12}{opt ranksum} for Wilcoxon-Mann-Whitney studentized statistic.{p_end}
{p 8 12}{opt hotelling} for Hotelling's T-squared statistic.{p_end}
{p 8 12} The option {opt ttest} is equivalent to {opt diffmeans} and included for backward compatibility. {p_end}

{p 4 8}{cmd:p(}{it:#}{cmd:)} specifies the order of the polynomial for outcome adjustment model.
Default is {cmd:p(0)}.{p_end}

{p 4 8}{cmd:evalat(}{it:point}{cmd:)} specifies the point at which the adjusted variable is evaluated. Allowed options are {cmd:cutoff} and {cmd:means}. Default is {cmd:evalat(cutoff)}.

{p 4 8}{cmd:kernel(}{it:kerneltype}{cmd:)}  specifies the type of kernel to use as weighting scheme. Allowed kernel types are {cmd:uniform} (uniform kernel), {cmd:triangular} (triangular kernel) and {cmd:epan} (Epanechnikov kernel). 
Default is {cmd:kernel(uniform)}.

{dlgtab:Inference}

{p 4 8}{cmd:{opt approx:imate}} specifies that covariate balance tests should use a large-sample approximation instead of finite-sample exact randomization inference methods.{p_end}

{p 4 8}{cmd:level(}{it:#}{cmd:)} specifies the minimum accepted value of the p-value from the covariate balance tests to be used.
Default is {cmd:level(.15)}.{p_end}

{p 4 8}{cmd:reps(}{it:#}{cmd:)} specifies the number of replications to be used.
Default is {cmd:reps(1000)}.{p_end}

{p 4 8}{cmd:seed(}{it:#}{cmd:)} sets the seed for the randomization test. With this option, the user can manually set the desired seed, or can enter the value -1 to use the system seed.
Default is {cmd:seed(666)}.{p_end}

{dlgtab:Generate plots and variables}

{p 4 8}{cmd:plot} draws a scatter plot of the minimum p-value from the covariate balance test against window length implemented by the command.{p_end}

{p 4 8}{cmd:graph_options(}{it:graphopts}{cmd:)} graph options for plot generated by the command.{p_end}

{p 4 8}{cmd:genvars} generates a variable indicating the window number corresponding to each observation and a variable indicating the corresponding window length.{p_end}

{dlgtab:Backward compatibility}

{p 4 8}{cmd:obsstep(}{it:#}{cmd:)} specifies the minimum number of observations to be added on each side of the cutoff.
This option is deprecated and only included for backward compatibility. We recommend the use of {cmd:wstep} or {cmd:wobs} instead.{p_end}


    {hline}
	
		
{marker examples}{...}
{title:Example: Cattaneo, Frandsen and Titiunik (2015) Incumbency Data}

{p 4 8}Setup{p_end}
{p 8 8}{cmd:. use rdlocrand_senate.dta}{p_end}

{p 4 8}Window selection with three covariates and default options{p_end}
{p 8 8}{cmd:. rdwinselect demmv dopen population demvoteshlag1}{p_end}

{p 4 8}Window selection using Kolmogorov-Smirnov statistic{p_end}
{p 8 8}{cmd:. rdwinselect demmv dopen population demvoteshlag1, stat(ksmirnov)}{p_end}

{p 4 8}Window selection with smallest window including at least 10 observations in each group and adding 3 observations in each step{p_end}
{p 8 8}{cmd:. rdwinselect demmv dopen population demvoteshlag1, obsmin(10) wobs(3)}{p_end}

{p 4 8}Window selection setting smallest window at .5 and with .125 length increments{p_end}
{p 8 8}{cmd:. rdwinselect demmv dopen population demvoteshlag1, wmin(.5) wstep(.125)}{p_end}

{p 4 8}Window selection with asymptotic p-values using 40 windows with scatter plot{p_end}
{p 8 8}{cmd:. rdwinselect demmv dopen population demvoteshlag1, nwindows(40) approximate plot}{p_end}

{p 4 8}Modify graph options: add title and x-axis label{p_end}
{p 8 8}{cmd:. rdwinselect demmv dopen population demvoteshlag1, nwindows(40) approx plot graph_options(title(Main title) xtitle(x-axis title))}{p_end}


{marker saved_results}{...}
{title:Saved results}

{p 4 8}{cmd:rdwinselect} saves the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(minp)}} minimum p-value from covariate test{p_end}
{synopt:{cmd:r(N)}} sample size in recommended window {p_end}
{synopt:{cmd:r(N_left)}} sample size in recommended window to the left of the cutoff{p_end}
{synopt:{cmd:r(N_right)}} sample size in recommended window to the right of the cutoff{p_end}
{synopt:{cmd:r(w_left)}} left end of recommended window{p_end}
{synopt:{cmd:r(w_right)}} right end of recommended window{p_end}
{synopt:{cmd:r(wobs)}} when specified, increment (in observations) in each window{p_end}
{synopt:{cmd:r(wmin)}} initial window{p_end}
{synopt:{cmd:r(wstep)}} when specified, increment (in window length) in each window{p_end}
{synopt:{cmd:r(nwindows)}} total number of windows evaluated{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Locals}{p_end}
{synopt:{cmd:r(seed)}} seed used in permutations {p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(wlist)}} matrix with window lenghts{p_end}
{synopt:{cmd:r(results)}} stores the minimum p-value from covariate balance test, p-value from binomial test, sample sizes and window length in each window{p_end}

		
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

