{smcl}
{* *! version 1.0 07Jul2021}{...}
{viewerjumpto "Syntax" "rdrbounds##syntax"}{...}
{viewerjumpto "Description" "rdrbounds##description"}{...}
{viewerjumpto "Options" "rdrbounds##options"}{...}
{viewerjumpto "Examples" "rdrbounds##examples"}{...}
{viewerjumpto "Saved results" "rdrbounds##saved_results"}{...}
{viewerjumpto "References" "rdrbounds##references"}{...}
{viewerjumpto "Authors" "rdrbounds##authors"}{...}

{title:Title}

{p 4 8}{cmd:rdrbounds} {hline 2} Rosenbaum bounds for inference in RD designs under local randomization.{p_end}


{marker syntax}{...}
{title:Syntax}

{p 4 8}{cmd:rdrbounds} {it:outvar} {it:runvar} {ifin} 
[{cmd:,} 
{cmd:{opt c:utoff}(}{it:#}{cmd:)} 
{cmd:ulist(}{it:numlist}{cmd:)} 
{cmd:wlist(}{it:numlist}{cmd:)} 
{cmd:{opt gamma:list}(}{it:numlist}{cmd:)} 
{cmd:expgamma(}{it:numlist}{cmd:)} 
{cmd:bound(}{it:string}{cmd:)} 
{cmd:{opt stat:istic}(}{it:stat_name}{cmd:)} 
{cmd:p(}{it:#}{cmd:)} 
{cmd:evalat(}{it:point}{cmd:)}
{cmd:kernel(}{it:kerneltype}{cmd:)}
{cmd:{opt null:tau}(}{it:#}{cmd:)}
{cmd:fuzzy(}{it:fuzzy_var [fuzzy_stat]}{cmd:)}
{cmd:prob(}{it:varname}{cmd:)} 
{cmd:{opt fm:pval}} 
{cmd:reps(}{it:#}{cmd:)}
{cmd:seed(}{it:#}{cmd:)}
]


{synoptset 28 tabbed}{...}

{marker description}{...}
{title:Description}

{p 4 8}{cmd:rdrbounds} computes Rosenbaum bounds for p-values in regression discontinuity (RD) designs under local randomization. See
{browse "https://rdpackages.github.io/references/Cattaneo-Frandsen-Titiunik_2015_JCI.pdf":Cattaneo, Frandsen and Titiunik (2015)}
and
{browse "https://rdpackages.github.io/references/Cattaneo-Titiunik-VazquezBare_2017_JPAM.pdf":Cattaneo, Titiunik and Vazquez-Bare (2017)}
for an introduction to this methodology. See also Rosenbaum (2002) for a background review.{p_end}

{p 4 8}A detailed introduction to this command is given in
{browse "https://rdpackages.github.io/references/Cattaneo-Titiunik-VazquezBare_2016_Stata.pdf":Cattaneo, Titiunik and Vazquez-Bare (2016)}.{p_end}
{p 8 8}Companion {browse "www.r-project.org":R} functions are also available {browse "https://rdpackages.github.io/rdlocrand":here}.{p_end}

{p 4 8}Companion functions are {help rdrandinf:rdrandinf}, {help rdsensitivity:rdwinselect} and {help rdrbounds:rdsensitivity}.{p_end}

{p 4 8}Related Stata and R packages useful for inference in RD designs are described in the following website:{p_end}

{p 8 8}{browse "https://rdpackages.github.io/":https://rdpackages.github.io/}{p_end}


{marker options}{...}
{title:Options}

{p 4 8}{cmd:{opt c:utoff}(}{it:#}{cmd:)} specifies the RD cutoff for the running variable {it:runvar}.
Default is {cmd:cutoff(0)}.{p_end}

{dlgtab:Bounds}

{p 4 8}{cmd:ulist(}{it:#}{cmd:)} specifies the list of vectors of the unobserved confounder to be evaluated.
Default is all vectors with ones in the first k positions and zeros in the remaining positions.{p_end}

{p 4 8}{cmd:wlist(}{it:#}{cmd:)} specifies the list of window lengths to be evaluated.
By default the program constructs 10 windows around the cutoff, the first one including 10 treated and control observations and then adding 5 observations to each group in subsequent windows.{p_end}

{p 4 8}{cmd:{opt gamma:list}(}{it:numlist}{cmd:)} specifies the list of values of gamma to be evaluated.{p_end}

{p 4 8}{cmd:expgamma(}{it:numlist}{cmd:)} specifies the list of values of exp(gamma) to be evaluated.
Default is {cmd:expgamma(1.5 2 2.5 3)}.{p_end}

{p 4 8}{cmd:bound(}{it:string}{cmd:)} specifies which bounds the command calculates. Options are {cmd: upper} for upper bound, {cmd:lower} for lower bound and {cmd:both} for both upper and lower bounds.
Default is {cmd:bound(both)}.{p_end}

{dlgtab:Statistic}

{p 4 8}{cmd:{opt stat:istic}(}{it:stat_name}{cmd:)} specifies the statistic to be used. Options are:{p_end}
{p 8 12}{opt diffmeans} for difference in means statistic. {p_end}
{p 8 12}{opt ksmirnov} for Kolmogorov-Smirnov statistic.{p_end}
{p 8 12}{opt ranksum} for Wilcoxon-Mann-Whitney studentized statistic. This is the default option.{p_end}
{p 8 12} The option {opt ttest} is equivalent to {opt diffmeans} and included for backward compatibility.{p_end}

{p 4 8}{cmd:p(}{it:#}{cmd:)} specifies the order of the polynomial for outcome adjustment model.
Default is {cmd:p(0)}.{p_end}

{p 4 8}{cmd:evalat(}{it:point}{cmd:)} specifies the point at which the adjusted variable is evaluated. Allowed options are {cmd:cutoff} and {cmd:means}. Default is {cmd:evalat(cutoff)}.

{p 4 8}{cmd:kernel(}{it:kerneltype}{cmd:)}  specifies the type of kernel to use as weighting scheme. Allowed kernel types are {cmd:uniform} (uniform kernel), {cmd:triangular} (triangular kernel) and {cmd:epan} (Epanechnikov kernel). 
Default is {cmd:kernel(uniform)}.

{p 4 8}{cmd:fuzzy(}{it:fuzzy_var [fuzzy_stat]}{cmd:)} name of the endogenous treatment variable in fuzzy design. This option employs an Anderson-Rubin-type statistic.

{dlgtab:Inference}

{p 4 8}{cmd:{opt null:tau}(}{it:#}{cmd:)} sets the value of the treatment effect under the null hypothesis.
Default is {cmd:nulltau(0)}.{p_end}

{p 4 8}{cmd:prob(}{it:varname}{cmd:)} specifies the name of the variable containing individual probabilities of treatment in a Bernoulli trial when the selection factor gamma is zero.
Default is the porportion of treated units in each window (assumed equal for all units).{p_end}

{p 4 8}{cmd:{opt fm:pval}} calculates the p-value under fixed margins randomization, in addition to the p-value under Bernoulli trials.{p_end}

{p 4 8}{cmd:reps(}{it:#}{cmd:)} specifies the number of replications.
Default is {cmd: reps(500)}.{p_end}

{p 4 8}{cmd:seed(}{it:#}{cmd:)} sets the seed for the randomization test. With this option, the user can manually set the desired seed, or can enter the value -1 to use the system seed.
Default is {cmd:seed(666)}.{p_end}


    {hline}
	
		
{marker examples}{...}
{title:Example: Cattaneo, Frandsen and Titiunik (2015) Incumbency Data}

{p 4 8}Setup{p_end}
{p 8 8}{cmd:. use rdlocrand_senate.dta, clear}{p_end}

{p 4 8}Bounds using 1000 replications specifying exp(gamma){p_end}
{p 8 8}{cmd:. rdrbounds demvoteshfor2 demmv, expgamma(1.2 1.5 2) wlist(.75 1) reps(1000)}{p_end}

{p 4 8}Bounds specifying gamma{p_end}
{p 8 8}{cmd:. rdrbounds demvoteshfor2 demmv, gamma(0.2 0.5 1) wlist(.75 1) reps(1000)}{p_end}

{p 4 8}Including fixed margins p-value {p_end}
{p 8 8}{cmd:. rdrbounds demvoteshfor2 demmv, expgamma(1.2 1.5 2) wlist(.75 1) reps(1000) fmpval}{p_end}

{p 4 8}Calculate upper bound only{p_end}
{p 8 8}{cmd:. rdrbounds demvoteshfor2 demmv,  expgamma(1.2 1.5 2) wlist(.75 1) reps(1000) bound(upper)}{p_end}



{marker saved_results}{...}
{title:Saved results}

{p 4 8}{cmd:rdrbounds} saves the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(lbounds)}} matrix of lower bounds{p_end}
{synopt:{cmd:r(ubounds)}} matrix of upper bounds{p_end}
{synopt:{cmd:r(pvals)}} matrix of p-values{p_end}
		

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

{p 4 8}Rosenbaum, P.R. 2002. {ul:Observational Studies}. New York: Springer.{p_end}


{marker authors}{...}
{title:Authors}

{p 4 8}Matias D. Cattaneo, Princeton University, Princeton, NJ.
{browse "mailto:cattaneo@princeton.edu":cattaneo@princeton.edu}.{p_end}

{p 4 8}Rocio Titiunik, Princeton University, Princeton, NJ.
{browse "mailto:titiunik@princeton.edu":titiunik@princeton.edu}.{p_end}

{p 4 8}Gonzalo Vazquez-Bare, UC Santa Barbara, Santa Barbara, CA.
{browse "mailto:gvazquez@econ.ucsb.edu":gvazquez@econ.ucsb.edu}.{p_end}

