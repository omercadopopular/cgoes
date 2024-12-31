{smcl}
{* *!version 2.3 2021-02-28}{...}
{viewerjumpto "Syntax" "rdrobust##syntax"}{...}
{viewerjumpto "Description" "rdrobust##description"}{...}
{viewerjumpto "Options" "rdrobust##options"}{...}
{viewerjumpto "Examples" "rdrobust##examples"}{...}
{viewerjumpto "Saved results" "rdrobust##saved_results"}{...}

{title:Title}

{p 4 8}{cmd:rdbwdensity} {hline 2} Bandwidth Selection for Manipulation Testing Using Local Polynomial Density Estimation.{p_end}

{marker syntax}{...}
{title:Syntax}

{p 4 8}{cmd:rdbwdensity} {it:Var} {ifin} 
[{cmd:,} {p_end}
{p 16 20}
{cmd:c(}{it:#}{cmd:)} 
{cmd:p(}{it:#}{cmd:)} 
{cmd:kernel(}{it:KernelFn}{cmd:)}
{cmd:fitselect(}{it:FitMethod}{cmd:)}
{cmd:vce(}{it:VceMethod}{cmd:)}
{cmd:nomasspoints}{p_end}
{p 16 20}
{cmd:nlocalmin(}{it:#}{cmd:)}
{cmd:nuniquemin(}{it:#}{cmd:)}
{cmd:noregularize}{p_end}
{p 16 20}]{p_end}

{marker description}{...}
{title:Description}

{p 4 8}{cmd:rdbwdensity} implements several data-driven bandwidth selection methods useful to construct manipulation testing procedures using the local polynomial density estimators proposed in
{browse "https://rdpackages.github.io/references/Cattaneo-Jansson-Ma_2020_JASA.pdf":Cattaneo, Jansson and Ma (2020)}.{p_end}

{p 4 8}A detailed introduction to this Stata command is given in {browse "https://rdpackages.github.io/references/Cattaneo-Jansson-Ma_2018_Stata.pdf":Cattaneo, Jansson and Ma (2018)}.{p_end}
{p 8 8}Companion {browse "www.r-project.org":R} functions are also available {browse "https://rdpackages.github.io/rddensity":here}.{p_end}

{p 4 8}Companion function is {help rddensity:rddensity}.
See also the 
{browse "https://nppackages.github.io/lpdensity":lpdensity}
package for other related bandwidth selection methods.{p_end}

{p 4 8}Related Stata and R packages useful for inference in regression discontinuity (RD) designs are described in the following website:{p_end}

{p 8 8}{browse "https://rdpackages.github.io/":https://rdpackages.github.io/}{p_end}

{marker options}{...}
{title:Options}

{dlgtab:Bandwidth Selection}

{p 4 8}{opt c:}{cmd:(}{it:#}{cmd:)} specifies the threshold or cutoff value in the support of {it:Var}, which determines the two samples (e.g., control and treatment units in RD settings).
Default is {cmd:c(0)}.{p_end}

{p 4 8}{opt p:}{cmd:(}{it:#}{cmd:)} specifies the local polynomial order used to construct the density estimators.
Default is {cmd:p(2)} (local quadratic approximation).{p_end}

{p 4 8}{opt fit:select}{cmd:(}{it:FitMethod}{cmd:)} specifies the density estimation method.{p_end}
{p 8 12}{opt unrestricted}{bind:} for density estimation without any restrictions (two-sample, unrestricted inference).
This is the default option.{p_end}
{p 8 12}{opt restricted}{bind:} for density estimation assuming equal distribution function and higher-order derivatives.{p_end}

{p 4 8}{opt ker:nel}{cmd:(}{it:KernelFn}{cmd:)} specifies the kernel function used to construct the local polynomial estimators.{p_end}
{p 8 12}{opt triangular}{bind:  } {it:K(u) = (1 - |u|) * (|u|<=1)}.
This is the default option.{p_end}
{p 8 12}{opt epanechnikov}{bind:}  {it:K(u) = 0.75 * (1 - u^2) * (|u|<=1)}.{p_end}
{p 8 12}{opt uniform}{bind:     }  {it:K(u) = 0.5 * (|u|<=1)}.{p_end}

{p 4 8}{opt vce:}{cmd:(}{it:VceMethod}{cmd:)} specifies the procedure used to compute the variance-covariance matrix estimator.{p_end}
{p 8 12}{opt plugin}{bind:   } for asymptotic plug-in standard errors.{p_end}
{p 8 12}{opt jackknife}{bind:} for jackknife standard errors.
This is the default option.{p_end}

{p 4 8}{opt nomass:points} will not adjust for mass points in the data.{p_end}

{dlgtab:Local Sample Size Checking}

{p 4 8}{opt nloc:almin}{cmd:(}{it:#}{cmd:)} specifies the minimum number of observations in each local neighborhood.
This option will be ignored if set to 0, or if {cmd:noregularize} is used.
The default value is {cmd:20+p(}{it:#}{cmd:)+1}.{p_end}

{p 4 8}{opt nuni:quemin}{cmd:(}{it:#}{cmd:)} specifies the minimum number of unique observations in each local neighborhood.
This option will be ignored if set to 0, or if {cmd:noregularize} is used.
The default value is {cmd:20+p(}{it:#}{cmd:)+1}.{p_end}

{p 4 8}{opt noreg:ularize} suppresses the local sample size checking feature.{p_end}

		
{marker examples}{...}
{title:Example: Cattaneo, Frandsen and Titiunik (2015) Incumbency Data}.

{p 4 8}Load dataset (cutoff is 0 in this dataset):{p_end}
{p 8 8}{cmd:. use rddensity_senate.dta}{p_end}

{p 4 8}Bandwidth selection for manipulation test using default options: {p_end}
{p 8 8}{cmd:. rdbwdensity margin}{p_end}

{p 4 8}Bandwidth selection for manipulation test using plug-in standard errors:{p_end}
{p 8 8}{cmd:. rdbwdensity margin, vce(plugin)}{p_end}


{marker saved_results}{...}
{title:Saved results}

{p 4 8}{cmd:rddensity} saves the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(c)}}cutoff value{p_end}
{synopt:{cmd:e(p)}}order of the polynomial used for density estimation{p_end}
{synopt:{cmd:e(N_l)}}sample size to the left of the cutoff{p_end}
{synopt:{cmd:e(N_r)}}sample size to the right of the cutoff{p_end}
{synopt:{cmd:e(h)}}matrix of estimated bandwidth (including underlying estimated constants){p_end}
{synopt:{cmd:e(runningvar)}}running variable used{p_end}
{synopt:{cmd:e(kernel)}}kernel used{p_end}
{synopt:{cmd:e(fitmethod)}}model used{p_end}
{synopt:{cmd:e(vce)}}standard errors estimator used{p_end}


{title:References}

{p 4 8}Cattaneo, M. D., B. Frandsen, and R. Titiunik. 2015.
{browse "https://rdpackages.github.io/references/Cattaneo-Frandsen-Titiunik_2015_JCI.pdf":Randomization Inference in the Regression Discontinuity Design: An Application to the Study of Party Advantages in the U.S. Senate}.{p_end}
{p 8 8}{it:Journal of Causal Inference} 3(1): 1-24.{p_end}

{p 4 8}Cattaneo, M. D., M. Jansson, and X. Ma. 2018.
{browse "https://rdpackages.github.io/references/Cattaneo-Jansson-Ma_2018_Stata.pdf": Manipulation Testing based on Density Discontinuity}.{p_end}
{p 8 8}{it:Stata Journal} 18(1): 234-261.{p_end}

{p 4 8}Cattaneo, M. D., M. Jansson, and X. Ma. 2020.
{browse "https://rdpackages.github.io/references/Cattaneo-Jansson-Ma_2020_JASA.pdf":Simple Local Polynomial Density Estimators}.{p_end}
{p 8 8}{it:Journal of the American Statistical Association} 115(531): 1449-1455.{p_end}

{title:Authors}

{p 4 8}Matias D. Cattaneo, Princeton University, Princeton, NJ.
{browse "mailto:cattaneo@princeton.edu":cattaneo@princeton.edu}.{p_end}

{p 4 8}Michael Jansson, University of California Berkeley, Berkeley, CA.
{browse "mailto:mjansson@econ.berkeley.edu":mjansson@econ.berkeley.edu}.{p_end}

{p 4 8}Xinwei Ma, University of California San Diego, La Jolla, CA.
{browse "mailto:x1ma@ucsd.edu":x1ma@ucsd.edu}.{p_end}


