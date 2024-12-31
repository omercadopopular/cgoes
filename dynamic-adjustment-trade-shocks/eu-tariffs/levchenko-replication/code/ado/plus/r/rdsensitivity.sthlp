{smcl}
{* *! version 1.0 07Jul2021}{...}
{viewerjumpto "Syntax" "rdsensitivity##syntax"}{...}
{viewerjumpto "Description" "rdsensitivity##description"}{...}
{viewerjumpto "Options" "rdsensitivity##options"}{...}
{viewerjumpto "Examples" "rdsensitivity##examples"}{...}
{viewerjumpto "Saved results" "rdsensitivity##saved_results"}{...}
{viewerjumpto "References" "rdsensitivity##references"}{...}
{viewerjumpto "Authors" "rdsensitivity##authors"}{...}

{title:Title}

{p 4 8}{cmd:rdsensitivity} {hline 2} Sensitivity analysis for RD designs under local randomization.{p_end}


{marker syntax}{...}
{title:Syntax}

{p 4 8}{cmd:rdsensitivity} {it:outvar} {it:runvar} {ifin} 
[{cmd:,} 
{cmd:{opt c:utoff}(}{it:#}{cmd:)} 
{cmd:wlist(}{it:numlist}{cmd:)} 
{cmd:wlist_left(}{it:numlist}{cmd:)} 
{cmd:tlist(}{it:numlist}{cmd:)} 
{cmd:{opt stat:istic}(}{it:stat_name}{cmd:)} 
{cmd:p(}{it:#}{cmd:)} 
{cmd:evalat(}{it:point}{cmd:)}
{cmd:kernel(}{it:kerneltype}{cmd:)}
{cmd:fuzzy(}{it:fuzzy_var [fuzzy_stat]}{cmd:)}
{cmd:ci(}{it:# #}{cmd:)}
{cmd:ci_alpha(}{it:#}{cmd:)}
{cmd:reps(}{it:#}{cmd:)}
{cmd:seed(}{it:#}{cmd:)}
{cmd:saving(}{it:filename}{cmd:)} 
{cmd:nodots} 
{cmd:nodraw} 
{cmd:verbose}
]


{synoptset 28 tabbed}{...}

{marker description}{...}
{title:Description}

{p 4 8}{cmd:rdsensitivity} performs sensitivity analysis for regression discontinuity designs (RD) under local randomization. See
{browse "https://rdpackages.github.io/references/Cattaneo-Frandsen-Titiunik_2015_JCI.pdf":Cattaneo, Frandsen and Titiunik (2015)}
and
{browse "https://rdpackages.github.io/references/Cattaneo-Titiunik-VazquezBare_2017_JPAM.pdf":Cattaneo, Titiunik and Vazquez-Bare (2017)}
for an introduction to this methodology.{p_end}

{p 4 8}A detailed introduction to this command is given in
{browse "https://rdpackages.github.io/references/Cattaneo-Titiunik-VazquezBare_2016_Stata.pdf":Cattaneo, Titiunik and Vazquez-Bare (2016)}.{p_end}
{p 8 8}Companion {browse "www.r-project.org":R} functions are also available {browse "https://rdpackages.github.io/":here}.{p_end}

{p 4 8}Companion functions are {help rdrandinf:rdrandinf}, {help rdwinselect:rdwinselect} and {help rdrbounds:rdrbounds}.{p_end}

{p 4 8}Related Stata and R packages useful for inference in RD designs are described in the following website:{p_end}

{p 8 8}{browse "https://rdpackages.github.io/":https://rdpackages.github.io/}{p_end}


{marker options}{...}
{title:Options}

{p 4 8}{cmd:{opt c:utoff}(}{it:#}{cmd:)} specifies the RD cutoff for the running variable {it:runvar}.
Default is {cmd:cutoff(0)}.{p_end}

{dlgtab:Window and TE lists}

{p 4 8}{cmd:wlist(}{it:#}{cmd:)} specifies the list of window limits to the right of the cutoff.
By default the program constructs 10 symmetric windows around the cutoff, the first one including 10 treated and control observations and then adding 5 observations to each group in subsequent windows.{p_end}

{p 4 8}{cmd:wlist_left(}{it:#}{cmd:)} specifies the list of window limits to the left of the cutoff.
When not specified, the command uses symmetric windows around the cutoff based on {cmd:wlist()}.
{p_end}

{p 4 8}{cmd:tlist(}{it:#}{cmd:)} specifies the list of null values for the treatment effect.
By default the program employs ten evenly spaced points within the 
asymptotic confidence interval for a constant treatment effect in the smallest window to be employed.{p_end}

{dlgtab:Statistic}

{p 4 8}{cmd:{opt stat:istic}(}{it:stat_name}{cmd:)} specifies the statistic to be used. Options are:{p_end}
{p 8 12}{opt diffmeans} for difference in means statistic. This is the default option.{p_end}
{p 8 12}{opt ksmirnov} for Kolmogorov-Smirnov statistic.{p_end}
{p 8 12}{opt ranksum} for Wilcoxon-Mann-Whitney studentized statistic.{p_end}
{p 8 12} The option {opt ttest} is equivalent to {opt diffmeans} and included for backward compatibility. {p_end}

{p 4 8}{cmd:p(}{it:#}{cmd:)} specifies the order of the polynomial for outcome adjustment model.
Default is {cmd:p(0)}.{p_end}

{p 4 8}{cmd:evalat(}{it:point}{cmd:)} specifies the point at which the adjusted variable is evaluated. Allowed options are {cmd:cutoff} and {cmd:means}. Default is {cmd:evalat(cutoff)}.

{p 4 8}{cmd:kernel(}{it:kerneltype}{cmd:)}  specifies the type of kernel to use as weighting scheme. Allowed kernel types are {cmd:uniform} (uniform kernel), {cmd:triangular} (triangular kernel) and {cmd:epan} (Epanechnikov kernel). 
Default is {cmd:kernel(uniform)}.

{p 4 8}{cmd:fuzzy(}{it:fuzzy_var [fuzzy_stat]}{cmd:)} name of the endogenous treatment variable in fuzzy design. This option uses an Anderson-Rubin-type statistic.

{dlgtab:Inference}

{p 4 8}{cmd:ci(}{it:# #}{cmd:)} returns the confidence interval corresponding to the window indicated in {it:window}. 
First value is the left limit, second value if the right limit of the window.
The values in {it:window} need to coincide with one of the values in {cmd:wlist} and {cmd:wlist_left}. {p_end}

{p 4 8}{cmd:ci_alpha(}{it:#}{cmd:)} the value of alpha for the confidence interval. 
Default alpha is 0.05, corresponding to a 95 percent confidence interval.{p_end}

{p 4 8}{cmd:reps(}{it:#}{cmd:)} specifies the number of replications.
Default is {cmd: reps(1000)}.{p_end}

{p 4 8}{cmd:seed(}{it:#}{cmd:)} sets the seed for the randomization test. With this option, the user can manually set the desired seed, or can enter the value -1 to use the system seed.
Default is {cmd:seed(666)}.{p_end}

{dlgtab:Save and display output}

{p 4 8}{cmd:saving(}{it:filename}{cmd:)} saves the dataset containing the data for the contour plot in {it:filename}. This allows the user to replicate and modify the appearance of the plot, and also conduct further sensitivity analysis.{p_end}

{p 4 8}{cmd:nodots} suppresses replication dots.{p_end}

{p 4 8}{cmd:nodraw} suppresses contour plot.{p_end}

{p 4 8}{cmd:verbose} displays matrix of results.{p_end}


    {hline}
	
		
{marker examples}{...}
{title:Example: Cattaneo, Frandsen and Titiunik (2015) Incumbency Data}

{p 4 8}Setup{p_end}
{p 8 8}{cmd:. use rdlocrand_senate.dta, clear}{p_end}

{p 4 8}Sensitivity analysis using 1000 replications{p_end}
{p 8 8}{cmd:. rdsensitivity demvoteshfor2 demmv, wlist(.75(.25)2) tlist(0(1)20) reps(1000)}{p_end}

{p 4 8}Obtain confidence interval for window [-.75;.75]{p_end}
{p 8 8}{cmd:. rdsensitivity demvoteshfor2 demmv, wlist(.75(.25)2) tlist(0(1)20) reps(1000) ci(.75)}{p_end}

{p 4 8}Replicate contour graph using saved dataset {p_end}
{p 8 8}{cmd:. rdsensitivity demvoteshfor2 demmv, wlist(.75(.25)2) tlist(0(1)20) reps(1000) saving(graphdata)}{p_end}
{p 8 8}{cmd:. use graphdata, clear}{p_end}
{p 8 8}{cmd:. twoway contour pvalue t w, ccuts(0(0.05)1)}{p_end}



{marker saved_results}{...}
{title:Saved results}

{p 4 8}{cmd:rdsensitivity} saves the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(ci_lb)}} lower limit of confidence interval.{p_end}
{synopt:{cmd:r(ci_ub)}} upper limit of confidence interval.{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(results)}} matrix of p-values.{p_end}
		

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
