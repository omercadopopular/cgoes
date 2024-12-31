{smcl}
{* *! version 0.0.1  12dec2017}{...}
{findalias asfradohelp}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] help" "help help"}{...}
{viewerjumpto "Syntax" "examplehelpfile##syntax"}{...}
{viewerjumpto "Description" "examplehelpfile##description"}{...}
{viewerjumpto "Options" "examplehelpfile##options"}{...}
{viewerjumpto "Remarks" "examplehelpfile##remarks"}{...}
{viewerjumpto "Examples" "examplehelpfile##examples"}{...}

{title:Title}
{phang}
{bf:scfses} {hline 2} Calculate a given percentile (or mean) of the unconditional distribution of a variable in the Survey of Consumer Finances (SCF).

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:scfses}
{it:varname} [if] {weight} [{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt p(#, mean)}} the desired percentile.  The default is {cmd:p(50)}, which is the median (50th percentile).  If "p(mean)" is specified, then the program computes the average value of the variable.  {p_end}
{synopt:{opt number:draws(#)}} number of replicates for imputation (within) variability.  {p_end}
{synopt:{opt imp(#)}} number of implicates for sampling (between) variability.  The default is {cmd:imp(5)}, which means the command uses all five implicates.{p_end}
{synopt:{opt ci(#)}} the confidence interval returned in {cmd:r(table)}.  The default is a 95% CI.{p_end}
{synopt:{opt impnm(string)}} name for variables containing the name of the implicate.  The default name is {cmd:rep}. {p_end}
{synopt:{opt repnm(string)}} name for variables containing the number of draws in the i-th replicate.  The default name is {cmd:mm}.  {p_end}
{synopt:{opt repwt(string)}} name for variables containing the weights for draws in the i-th replicate.  {cmd:wt1b} is the default and is not invoked unless the program is already weighted.  {p_end}
{synopt:{opt nodfcorr}} turns off the degrees-of-freedom correction.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
{cmd:pweight}s are allowed; see {help weight}.

{marker description}{...}
{title:Description}

{pstd}
{cmd:scfses} calculates a given percentile of the distribution 
of the variable in {varlist}, the standard error on the 
variable, and a confidence interval, accounting for the data
structure in the Survey of Consumer Finances.  For example, 
using {cmd:scfses}, one could compute the 25th percentile
 of a given asset or debt variable for some population in 
the SCF, as well as the standard error of that parameter.

{pstd} 
{cmd:scfses} can also compute the mean of the variable, by specifying {cmd:p(mean)}.  

{pstd}
To generate point estimates and standard errors, the command follows guidance given by the Survey of Consumer Finances (with details below).  
The program also implements a degrees-of-freedom correction for confidence intervals, following Barnard and Rubin (1999).  
This degrees-of-freedom correction takes into account that some
 of the SCF data are imputed when computing confidence intervals from the t distribution.  The option {cmd:nodfcorr} turns off this correction and just
 conducts testing against the normal distribution.  Note that the t test, while incorporated by default (and conservative), is only exact for variables that are 
 approximately normally distributed, which may or may not be the case depending on the SCF variable of interest. 

{pstd}
It is recommended to use the survey weights contained in the SCF to obtain accurate estimates.  

{pstd}
To invoke the command, one must specify: {p_end}
{pstd}
- the desired variable{p_end}
{pstd}
- the desired percentile {p_end}
{pstd}
- the name of the variable containing the implicate number (the default is rep) {p_end}
{pstd}
- the name of variables containing the replicate draws for each observation (the default is mm, e.g. 
mm50 contains the number of draws for each observation in the 50th replicate){p_end}

{pstd}
- (technically optional) the variable containing the weights, using standard Stata syntax {p_end}
{pstd}
- (technically optional) the name of variables containing the weights for the replicate draws (the default is wt1b, 
e.g. wt1b50 contains the weights for each observation in the 50th replicate).  {p_end}

{marker options}{...}
{title:Options}

{phang}
{opt p(#, mean)} specifies the desired percentile for the distribution of the variable.  The desired percentile need not be an integer.  The default percentile is 50, which means that if the option isn't invoked,
 the program will generate the median.  If you wish to obtain the mean of the distribution, you can specify {cmd:p(mean)} instead.  
Specifying any number outside the range 0-100, or any string other than "mean," will yield an error.  

{phang}
{opt number:draws(#)} specifies the the number of replicate draws to be used for computation of "within" variability. 
The default number is 200, which means that if the option is not invoked, the command will 
compute the within variability using 200 replicate draws.

{phang}
{opt imp(#)} specifies the number of implicates used for the computation for between variability.
The default number is 5, which means that if the option is not invoked, the command will compute
 the within variability using all 5 implicates.

{phang}
{opt ci(#)} specifies the desired confidence interval for the parameter that {cmd:scfses} obtains.  
The default is 95; in other words, {cmd:scfses} will deliver the 95% confidence interval of the specified parameter.

{phang}
{opt repnm(string)} specifies the prefix for all variables containing the number of replicate draws for each observation.  
The dataset on which {cmd:scfses} acts must have a vector of variables, titled in a consistent way, that contain the number of draws of each observation for a given replicate.  
The default name is mm, since that is the default name for these variables in the SCF replicate weights file downloadable from the SCF website.  
In that case, the command searches for variables titled mm1, mm2, mm3, mm4, ...  , where each variable contains the number of draws in a given replicate. 

{phang}
{opt repwt(string)} specifies the prefix for all variables containing the weight for each observation in a given replicate.  
The dataset on which {cmd:scfses} must have a vector of variables, titled in a consistent way, that contain the weight of draws of each observation for a given replicate.  
The default name is wt1b, since that is the default name for these variables in the SCF replicate weights file downloadable from the SCF website.  
In that case, the command searches for variables titled wt1b1, wt1b2, wt1b3, wt1b4, ...  , where each variable contains the number of draws in a given replicate.  
These weights are not used in computation unless pweights are already specified.  

{phang}
{opt nodfcorr} omits the degrees-of-freedom correction as described below. If invoked, the program tests against the normal distribution (or, to be precise, the t distribution with a very large number of degrees of freedom).

{marker remarks}{...}

{title:Stored Results} 

{pstd} 
{cmd:scfses} stores the following in {cmd:r(table)}


{pstd}
{cmd:r(table)} contains the following information for each coefficient:

{synoptset 16 tabbed}{...}
{synopt:{cmd:b}}coefficient value{p_end}
{synopt:{cmd:se}}standard error{p_end}
{synopt:{cmd:pvalue}}observed significance level for {cmd:t/z}{p_end}
{synopt:{cmd:ll}}lower limit of confidence interval{p_end}
{synopt:{cmd:ul}}upper limit of confidence interval{p_end}
{synopt:{cmd:df}}degrees of freedom associated with coefficient (incorporating the Barnard and Rubin (1999) correction, unless invoked) {p_end}
{synopt:{cmd:crit}}critical value associated with {cmd:t/z}{p_end}
{p2colreset}{...}

{pstd} 
{cmd:e(b)} also contains the coefficient.  

{pstd}
{cmd:e(V)} contains the variability.  

{title:Remarks}

{dlgtab:Point Estimates and Variability}
{pstd} 
The Federal Reserve imputes some responses in the Survey of Consumer Finances using a procedure called Multiple Imputation.  Ignoring the SCF's structure will yield errors when computing parameters.

{pstd}
The SCF contains five copies (implicates) of every observation; each implicate may have different values for any variable.  
To obtain the point estimate of any given parameter, one must compute the average point estimate across each implicate.
For instance, the median of a variable is the average of the median of the five implicates.  

{pstd} 
To compute the variability of a parameter, one must account for both between  and within variability.  
Between variability is the variance contributed across implicates.  
Within variability is the sampling variance within implicate.  
The total variance of a parameter is 
T = (m+1)/m * B + W, 
where T is the total variance, B is between variability, W is within variability, and m is the number of implicates.  

{pstd}
To compute between variability, simply take the sample variance of the five parameters computed within each implicate.  
For example, to obtain the between variability of the median, compute the median within each implicate, and obtain the variance of those five objects.  

{pstd}
To compute within variability, obtain the sample variance within just the first implicate, using the replicate weights.  
This requires use of the replicate variables. 

{pstd} 
The Federal Reserve provides replicates to simulate the complex sampling scheme of the SCF.  
The vector of replicate variables contains the number of times an observation was drawn for each replicate.  
The Fed provides 999 replicates in all.  

{pstd} 
The bootstrap serves as a useful analog to the replicate process.  
Each replicate variable contains the number of times that an observation was sampled.  
For the first replicate, keep only the first implicate, and create a dataset with as many copies of each observation as are contained in the replicate variable.  
Then compute and store the desired parameter, using the newly expanded dataset.  Repeat with another replicate variable. 

{pstd}
To compute within variability, obtain the distribution of the parameter using a large number of replicates.  
Then obtain the variance of the distribution.

{pstd}
The replicate variables must be named consistently, with a prefix string and a suffix number ranging from 1 to the desired number of replicates.  
For example, the variables mm1, mm2, mm3, and mm4, could correspond to the first four replicate variables.  

{pstd} 
Finally, one can obtain the total variance of the parameter using the expression above.  

{pstd}
For more detailed information on multiple imputation in the Survey of Consumer Finances, please see guidance on the Federal Reserve's website, Monalto (1996) and Kennickell (2000).  

{dlgtab:Weights}
{pstd}
It is recommended to use weights to obtain accurate parameter estimates.  One can use pweights in the usual way.  

{pstd} 
If one invokes a pweight, one should also include the vector of replicate weights.  
These weight variables contain the weight of the observation in the replicate draw.  
The estimate obtained from each replicate draw will be weighted accordingly.

{pstd}
The replicate variables must be named consistently, with a prefix string and a suffix number ranging from 1 to the desired number of replicates.  
For example, the variables wt1b1, wt1b2, wt1b3, and wt1b4, could correspond to the first four replicate weight variables.  

{dlgtab:Degrees of Freedom Correction}
{pstd}
When generating a confidence interval using the t distribution, one must account for the data's degrees of freedom.  
The imputation procedure can affect the degrees of freedom, and ignoring the imputation could yield inaccurate confidence intervals.  

{pstd} 
Barnard and Rubin (1999) provide a degrees-of-freedom correction to generate confidence intervals that account for multiple imputation. 
The correction is conservative; it will always increase the size of confidence intervals.  The program implements the correction by default.  

{pstd}
Note that Stata's confidence intervals reported on, e.g., regression coefficients test against the t distribution.  
But that test is only exact if the variable's data generating process is approximately normal.  
Otherwise, these confidence intervals are conservative with respect to testing against the normal distribution.  

{pstd}
SCF variables may or may not be normally distributed.  
While the degrees-of-freedom correction is incorporated by default, the user may wish simply to generate confidence intervals from the normal distribution.  
The user can do so by invoking the option that turns off the correction.  

{marker examples}{...}
{title:Examples}
{phang}{cmd:.  scfses DEBT [pw=WGT], numberdraws(200)}{p_end}

{pstd}
Obtains the point estimate and standard error of median debt using all five implicates and 200 replicate draws.  
Weights by WGT.  Since the impnm, repnm, and repwt options are not invoked, there is a variable imp containing the implicate number, at least 200 replicate draw variables named mm1, mm2, mm3, ..., and at least 200 replicate weight variables named wt1b1, wt1b2, wt1b3, ...  .  (These are the default names for these variables.) 

{phang}{cmd:.  scfses DEBT [pw=WGT] , p(25) numberdraws(200) impnm(implicate) repnm(rep) repwt(repwt) }{p_end}

{pstd}
Obtains the point estimate and standard error of the 25th percentile of debt using 200 replicate draws.  
Weights by WGT.  The impnm, repnm, and repwt options give the name of the variables containing the implicate, replicate, and replicate weight names.  

{phang}{cmd:.  scfses DEBT if inrange(AGE,50,54) & YEAR == 2016 [pw=WGT] , p(mean) numberdraws(999) imp(5)}{p_end}

{pstd}
Obtains mean debt among people ages 50-54 in the 2016 SCF.  Uses 999 replicates and five implicates for computing point estimates and imputation variability.  

{title:References}
{phang} Barnard, John, and Donald B. Rubin.  1999.  "Small-Sample Degrees of Freedom with Multiple Imputation." {it:Biometrica}
 86 (4): 948-955.  {p_end}
{phang} Kennickell, Arthur B.  1998.  "Multiple Imputation in the Survey of Consumer Finances."  {it:Statistical Journal of the IAOS} 33 (1): 143-151.  {p_end} 
{phang} Kennickell, Arthur B.  2000.  "Wealth Measurement in the Survey of Consumer Finances: Methodology and Directions for Future Research."  {p_end}
{phang} Kennickel, Arthur B., and R. L. Woodburn.  1999.  "Consistent Weight Design for the 1989, 1992, and 1995 SCFs, and the Distribution of Wealth."  {it:Review of Income and Wealth} 45 (2): 193-215.  {p_end} 
{phang} Monalto, Catherine Phillips, and Jaimie Sung.  1996.  "Multiple Imputation in the 1992 Survey of Consumer Finances." {it:Financial Counseling and Planning} 7 (1): 133-146.  {p_end}

Code from Jane Brittingham's command {cmd:scfcombo}, which also can be used to summarize the SCF, inspired some ideas for {cmd:scfses}. 

{title:Author}
{pstd}
Charlie Rafkin 

{pstd}
National Bureau of Economic Research

{pstd}
crafkin@nber.org 


