{smcl}
{* *! version 1.0.7  15mar2011}{...}
{cmd:help rivtest}{right: ({browse "http://www.stata-journal.com/article.html?article=up0032":SJ11-2: st0171_1})}
{hline}

{title:Title}

{p2colset 5 16 18 2}{...}
{p2col:{hi: rivtest} {hline 2}}Tests and confidence intervals after estimation
of instrumental-variables models ({opt ivregress}, {opt ivreg2}, {opt ivprobit}, and {opt ivtobit}) that are robust to weak instruments{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 14 2}
{cmd:rivtest}
[{cmd:,} {it:test_options} {it:ci_options}]

{synoptset 15}{...}
{synopthdr:test_options}
{synoptline}
{synopt:{opt null(#)}}
null hypothesis for test of coefficient on endogenous variable in IV model
{p_end}
{synopt:{opt lmwt(#)}}
weight on LM test statistic in LM-J test
{p_end}
{synopt:{opt small}}
makes small-sample adjustment; default is determined by IV command
{p_end}
{synoptline}
{p2colreset}{...}

{synoptset 15}{...}
{synopthdr:ci_options}
{synoptline}
{synopt:{opt ci}}
estimate confidence intervals
{p_end}
{synopt:{opt grid(numlist)}}
grid points for confidence-interval estimation
{p_end}
{synopt:{opt points(#)}}
number of grid points for confidence-interval estimation
{p_end}
{synopt:{opt gridmult(#)}}
multiplier of Wald confidence-interval for grid
{p_end}
{synopt:{opt usegrid}}
force grid-based confidence-interval estimation in homoskedastic linear IV
{p_end}
{synopt:{opt retmat}}
return matrix of test results over confidence-interval search grid
{p_end}
{synopt:{opt l:evel(#)}}
confidence level for confidence intervals
{p_end}
{synoptline}
{p2colreset}{...}


{title:Description}

{pstd}
{opt rivtest} performs a set of tests of the coefficient on the endogenous variable after
the most recently fit instrumental-variables (IV) model. These tests are robust to weak
instruments.

{pstd}
{opt rivtest} supports {opt ivregress}, {opt ivreg2}, {opt ivprobit}, and {opt ivtobit} commands with
only one endogenous variable. For
{opt ivregress}, {opt rivtest} supports limited-information maximum likelihood
and two-stage least-squares models (the {opt liml} and {opt 2sls} options to
{opt ivregress}, respectively), as well as {cmd:vce(robust)} and
{cmd:vce(cluster} {it:clustvar}{cmd:)} options for variance-covariance estimation. ({opt rivtest} also supports analogous 
options with {opt ivreg2} but does not support autocorrelation-robust variance-covariance estimation.)
For {opt ivprobit} and {opt ivtobit},
{opt rivtest} supports only variance-covariance estimation options that assume
homoskedasticity (that is, all variance-covariance options except
{cmd:vce(robust)} and {cmd:vce(cluster} {it:clustvar}{cmd:)}).
Weights that are supported by each IV command are also supported by {opt rivtest}.

{pstd}
{opt rivtest} calculates the minimum distance version of the Anderson-Rubin (AR) test statistic.
When the IV model contains more than one IV, {opt rivtest}
also conducts the minimum distance versions of the conditional likelihood ratio (CLR) test, the
Lagrange multiplier (LM) test, the J overidentification test, and a combination of the LM and overidentification tests (LM-J). As a reference, {opt rivtest} also presents the Wald
test.

{pstd}
The AR test is a joint test of the structural parameter and the overidentification restrictions.
The AR statistic can be decomposed into the LM statistic, which tests only the structural parameter,
and the J statistic, which tests only the overidentification restrictions. (This J statistic, evaluated
at the null hypotheses, is different from the Hansen J statistic, which is evaluated at the
parameter estimate.) The LM test loses power
in some regions of the parameter space when the likelihood function has a local extrema or inflection.
The CLR statistic
combines the LM statistic and the J statistic in the most efficient way, thereby testing both
the structural parameter and the overidentification restrictions simultaneously. The LM-J combination
test is another approach for testing the hypotheses simultaneously. It is more efficient than the AR test
and allows different weights to be put on the parameter and overidentification hypotheses. The CLR
test is the most powerful test for the linear model under homoskedasticity (within a class of 
invariant similar tests), but this result
has not been proven yet for other IV-type estimators, so we present all test results.

{pstd}
{opt rivtest} can also estimate confidence intervals based on the AR, CLR, LM, and LM-J tests.
With {opt ivregress}, there is a closed-form solution for these confidence intervals only when
homoskedasticity is assumed. More generally, {opt rivtest} estimates confidence intervals by grid search.
The default grid is twice the size of the confidence interval based on
the Wald test. As a reference, {opt rivtest} also presents the Wald confidence interval.


{title:Options}

{dlgtab:Testing}

{phang} {opt null(#)} specifies the null hypothesis for the coefficient on the
endogenous variable in the IV model. The default is
{cmd:null(0)}.

{phang} {opt lmwt(#)} is the weight put on the LM test statistic in the LM-J
test. The default is {cmd:lmwt(0.8)}.

{phang} {opt small} specifies that small-sample adjustments be made when test
statistics are calculated. The default is given by whatever small-sample
adjustment option was chosen in the IV command.

{dlgtab:Confidence interval}

{phang} {opt ci} requests that confidence intervals be estimated. By default,
these are
not estimated because grid-based test inversion can be
time intensive.

{phang} {opt grid(numlist)} specifies the grid points over which to calculate
the confidence sets. The default grid is centered around the point estimate
with a width equal to twice the Wald confidence interval. With weak
instruments, this is often too small of a grid to estimate the confidence
intervals.

{pmore} {opt grid(numlist)} may not be used with the other two grid options:
{opt points(#)} and {opt gridmult(#)}.  If one of the other options is used, only
input from {opt grid(numlist)} will be used to construct the grid.

{phang} {opt points(#)} specifies the number of equally spaced values over
which to calculate the confidence sets. The default is {cmd:points(100)}.
Increasing the number of grid points will increase the time required to
estimate the confidence intervals, but a greater number of grid points will
improve precision.

{phang} {opt gridmult(#)} is another way of specifying a grid to calculate
confidence sets. This option specifies that the grid be {it:#} times the size
of the Wald confidence interval. The default is {cmd:gridmult(2)}.

{phang} {opt usegrid} forces grid-based test inversion for confidence-interval
estimation under the homoskedastic linear IV model. The default is to use the
analytic solution. Under the other models, grid-based estimation is the only
method.

{phang} {opt retmat} returns a matrix of test results over the confidence-interval search grid. This matrix can be large if the number of grid points is
large, but it can be useful for graphing confidence sets.

{phang} {opt level(#)} specifies the confidence level, as a percentage, for
confidence intervals. The default is {cmd:level(95)} or as set by 
{cmd:set level}. Because the LM-J test has no p-value function, we report
whether the test is rejected. Changing {opt level(#)} also
changes the level of significance used to determine this result:
[100-{opt level(#)}]%.


{title:Examples after linear IV estimation}

{pstd}Setup{p_end}

{phang2}. {stata "use http://www.stata.com/data/jwooldridge/eacsap/mroz.dta"}{p_end}

{pstd}Test significance of {cmd:educ} in the {cmd:lwage} equation (homoskedastic VCE){p_end}

{phang2}. {stata ivregress 2sls lwage exper expersq (educ = fatheduc motheduc)}{p_end}
{phang2}. {stata rivtest}{p_end}

{pstd}Test significance of {cmd:educ} in the {cmd:lwage} equation and estimate confidence sets (robust VCE){p_end}

{phang2}. {stata ivregress 2sls lwage exper expersq (educ = fatheduc motheduc), vce(robust)}{p_end}
{phang2}. {stata rivtest, ci}{p_end}


{title:Examples after limited dependent variable estimation}

{pstd}Estimate confidence sets for {cmd:educ} parameter in the {cmd:hours} equation{p_end}

{phang2}. {stata ivtobit hours nwifeinc exper expersq age kidslt6 kidsge6 (educ = fatheduc motheduc), ll}{p_end}
{phang2}. {stata rivtest, ci}{p_end}

{pstd}Estimate the confidence sets over a grid of 500 points with a width equal to 3 times the Wald 
confidence interval, centered around the IV point estimate{p_end}

{phang2}. {stata rivtest, ci gridmult(3) points(500)}{p_end}


{title:Saved results}

{pstd}
{cmd:rivtest} saves the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(null)}}null hypothesis{p_end}
{synopt:{cmd:r(clr_p)}}CLR test p-value{p_end}
{synopt:{cmd:r(clr_stat)}}CLR test statistic{p_end}
{synopt:{cmd:r(ar_p)}}AR test p-value{p_end}
{synopt:{cmd:r(ar_chi2)}}AR test statistic{p_end}
{synopt:{cmd:r(lm_p)}}LM test p-value{p_end}
{synopt:{cmd:r(lm_chi2)}}LM test statistic{p_end}
{synopt:{cmd:r(j_p)}}J test p-value{p_end}
{synopt:{cmd:r(j_chi2)}}J test statistic{p_end}
{synopt:{cmd:r(lmj_r)}}LM-J test rejection indicator{p_end}
{synopt:{cmd:r(rk)}}rk statistic{p_end}
{synopt:{cmd:r(wald_p)}}Wald test p-value{p_end}
{synopt:{cmd:r(wald_chi2)}}Wald test statistic{p_end}
{synopt:{cmd:r(points)}}number of points in grid used to estimate confidence sets{p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Macros}{p_end}
{synopt:{cmd:r(clr_cset)}}confidence set based on CLR test{p_end}
{synopt:{cmd:r(ar_cset)}}confidence set based on AR test{p_end}
{synopt:{cmd:r(lm_cset)}}confidence set based on LM test{p_end}
{synopt:{cmd:r(lmj_cset)}}confidence set based on LM-J test{p_end}
{synopt:{cmd:r(inexog)}}list of instruments included in the second-stage equation{p_end}
{synopt:{cmd:r(exexog)}}list of instruments excluded from the second-stage equation{p_end}
{synopt:{cmd:r(endo)}}endogenous variable{p_end}
{synopt:{cmd:r(wald_cset)}}confidence set based on Wald test{p_end}
{synopt:{cmd:r(grid)}}range of grid used to estimate confidence sets{p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:r(citable)}}table with test statistics, p-values, and rejection
indicators for every grid point over which hypothesis was tested{p_end}
{p2colreset}{...}


{title:Also see}

{p 4 14 2}
Article:  {it:Stata Journal}, volume 11, number 2: {browse "http://www.stata-journal.com/article.html?article=up0032":st0171_1},{break}
          {it:Stata Journal}, volume 9, number 3: {browse "http://www.stata-journal.com/article.html?article=st0171":st0171}

{p 5 14 2}
Manual:  {manhelp ivregress R},{break}
{manhelp ivprobit R},{break}
{manhelp ivtobit R},{break}
{manhelp test R}{break}
{p_end}

{p 7 14 2}
Help:  {helpb condivreg}, {helpb ivreg2} {p_end}
