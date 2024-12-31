{smcl}
{* 12Sept2011}{...}
{hline}
help for {hi:ivreg210}
{hline}

{title:Extended instrumental variables/2SLS, GMM and AC/HAC, LIML and k-class regression}

{p 4}Full syntax

{p 8 14}{cmd:ivreg210} {it:depvar} [{it:varlist1}]
{cmd:(}{it:varlist2}{cmd:=}{it:varlist_iv}{cmd:)} [{it:weight}]
[{cmd:if} {it:exp}] [{cmd:in} {it:range}]
{bind:[{cmd:,} {cmd:gmm2s}}
{cmd:bw(}{it:#}{cmd:)}
{cmd:kernel(}{it:string}{cmd:)}
{cmd:dkraay(}{it:integer}{cmd:)}
{cmd:kiefer}
{cmd:liml}
{cmd:fuller(}{it:#}{cmd:)}
{cmd:kclass(}{it:#}{cmd:)}
{cmd:coviv}
{cmd:cue}
{cmd:b0}{cmd:(}{it:matrix}{cmd:)} 
{cmdab:r:obust}
{cmdab:cl:uster}{cmd:(}{it:varlist}{cmd:)}
{cmd:orthog(}{it:varlist_ex}{cmd:)}
{cmd:endog(}{it:varlist_en}{cmd:)}
{cmdab:red:undant(}{it:varlist_ex}{cmd:)}
{cmd:partial(}{it:varlist}{cmd:)}
{cmdab:sm:all}
{cmdab:noc:onstant} {cmdab:h}ascons
{cmd:smatrix}{cmd:(}{it:matrix}{cmd:)} 
{cmd:wmatrix}{cmd:(}{it:matrix}{cmd:)} 
{cmd:first} {cmd:ffirst} {cmd:savefirst} {cmdab:savefp:refix}{cmd:(}{it:prefix}{cmd:)} 
{cmd:rf} {cmd:saverf} {cmdab:saverfp:refix}{cmd:(}{it:prefix}{cmd:)} 
{cmd:nocollin} {cmd:noid}
{cmdab:l:evel}{cmd:(}{it:#}{cmd:)}
{cmdab:nohe:ader}
{cmdab:nofo:oter}
{cmdab:ef:orm}{cmd:(}{it:string}{cmd:)} 
{cmdab:dep:name}{cmd:(}{it:varname}{cmd:)}
{bind:{cmd:plus} ]}

{p 4}Replay syntax

{p 8 14}{cmd:ivreg210}
{bind:[{cmd:,} {cmd:first}}
{cmd:ffirst} {cmd:rf} 
{cmdab:l:evel}{cmd:(}{it:#}{cmd:)}
{cmdab:nohe:ader}
{cmdab:nofo:oter}
{cmdab:ef:orm}{cmd:(}{it:string}{cmd:)} 
{cmdab:dep:name}{cmd:(}{it:varname}{cmd:)}
{cmd:plus} ]}

{p 4}Version syntax

{p 8 14}{cmd:ivreg210}, {cmd:version}

{p}{cmd:ivreg210} is compatible with Stata version 10.1 or later.

{p}{cmd:ivreg210} may be used with time-series or panel data,
in which case the data must be {cmd:tsset}
before using {cmd:ivreg210}; see help {help tsset}.

{p}All {it:varlists} may contain time-series operators,
but factor variables are not currently supported;
see help {help varlist}.

{p}{cmd:by}, {cmd:rolling}, {cmd:statsby}, {cmd:xi},
{cmd:bootstrap} and {cmd:jackknife} are allowed; see help {help prefix}.

{p}{cmd:aweight}s, {cmd:fweight}s, {cmd:iweight}s and {cmd:pweight}s
are allowed; see help {help weights}.

{p}The syntax of {help predict} following {cmd:ivreg210} is

{p 8 16}{cmd:predict} [{it:type}] {it:newvarname} [{cmd:if} {it:exp}]
[{cmd:in} {it:range}] [{cmd:,} {it:statistic}]

{p}where {it:statistic} is

{p 8 23}{cmd:xb}{space 11}fitted values; the default{p_end}
{p 8 23}{cmdab:r:esiduals}{space 4}residuals{p_end}
{p 8 23}{cmd:stdp}{space 9}standard error of the prediction{p_end}

{p}These statistics are available both in and out of sample;
type "{cmd:predict} {it:...} {cmd:if e(sample)} {it:...}"
if wanted only for the estimation sample.

{title:Contents}
{p 2}{help ivreg2##s_description:Description}{p_end}
{p 2}{help ivreg2##s_robust:Robust, cluster and 2-way cluster, AC, HAC, and cluster+HAC SEs and statistics}{p_end}
{p 2}{help ivreg2##s_gmm:GMM estimation}{p_end}
{p 2}{help ivreg2##s_liml:LIML, k-class and GMM-CUE estimation}{p_end}
{p 2}{help ivreg2##s_sumopt:Summary of robust, HAC, AC, GMM, LIML and CUE options}{p_end}
{p 2}{help ivreg2##s_overid:Testing overidentifying restrictions}{p_end}
{p 2}{help ivreg2##s_endog:Testing subsets of regressors and instruments for endogeneity}{p_end}
{p 2}{help ivreg2##s_relevance:Tests of under- and weak identification}{p_end}
{p 2}{help ivreg2##s_redundancy:Testing instrument redundancy}{p_end}
{p 2}{help ivreg2##s_first:First-stage regressions, identification, and weak-id-robust inference}{p_end}
{p 2}{help ivreg2##s_rf:Reduced form estimates}{p_end}
{p 2}{help ivreg2##s_partial:Partialling-out exogenous regressors}{p_end}
{p 2}{help ivreg2##s_ols:OLS and Heteroskedastic OLS (HOLS) estimation}{p_end}
{p 2}{help ivreg2##s_collin:Collinearities}{p_end}
{p 2}{help ivreg2##s_speed:Speed options: nocollin and noid}{p_end}
{p 2}{help ivreg2##s_small:Small sample corrections}{p_end}
{p 2}{help ivreg2##s_options:Options summary}{p_end}
{p 2}{help ivreg2##s_macros:Remarks and saved results}{p_end}
{p 2}{help ivreg2##s_examples:Examples}{p_end}
{p 2}{help ivreg2##s_refs:References}{p_end}
{p 2}{help ivreg2##s_acknow:Acknowledgements}{p_end}
{p 2}{help ivreg2##s_citation:Authors}{p_end}
{p 2}{help ivreg2##s_citation:Citation of ivreg210}{p_end}

{marker s_description}{title:Description}

{p}{cmd:ivreg210} implements a range of single-equation estimation methods
for the linear regression model: OLS, instrumental
variables (IV, also known as two-stage least squares, 2SLS),
the generalized method of moments (GMM),
limited-information maximum likelihood (LIML), and k-class estimators.
In the language of IV/GMM, {it:varlist1} are the exogenous
regressors or "included instruments",
{it:varlist_iv} are the exogenous variables excluded
from the regression or "excluded instruments",
and {it:varlist2} the endogenous regressors that are being "instrumented".

{p}{cmd:ivreg210} will also estimate linear regression models using
robust (heteroskedastic-consistent),
autocorrelation-consistent (AC),
heteroskedastic and autocorrelation-consistent (HAC)
and cluster-robust variance estimates.

{p}{cmd:ivreg210} is an alternative to Stata's official {cmd:ivregress}.
Its features include:
two-step feasible GMM estimation ({cmd:gmm2s} option)
and continuously-updated GMM estimation ({cmd:cue} option);
LIML and k-class estimation;
automatic output of overidentification and underidentification test statistics;
C statistic test of exogeneity of subsets of instruments
({cmd:orthog()} option);
endogeneity tests of endogenous regressors
({cmd:endog()} option);
test of instrument redundancy
({cmd:redundant()} option);
kernel-based autocorrelation-consistent (AC)
and heteroskedastic and autocorrelation consistent (HAC) standard errors
and covariance estimation ({cmd:bw(}{it:#}{cmd:)} option),
with user-specified choice of kernel ({cmd:kernel()} option); 
two-level {cmd:cluster}-robust standard errors and statistics;
default reporting of large-sample statistics
(z and chi-squared rather than t and F);
{cmd:small} option to report small-sample statistics;
first-stage regressions reported with various tests and statistics for
identification and instrument relevance;
{cmd:ffirst} option to report only these identification statistics
and not the first-stage regression results themselves.
{cmd:ivreg210} can also be used for ordinary least squares (OLS) estimation
using the same command syntax as official {cmd:regress} and {cmd:newey}.

{marker s_robust}{dlgtab:Robust, cluster and 2-level cluster, AC, HAC, and cluster+HAC SEs and statistics}

{p}The standard errors and test statistics reported by {cmd:ivreg210} can be made consistent
to a variety of violations of the assumption of i.i.d. errors.
When these options are combined with
either the {cmd:gmm2s} or {cmd:cue} options (see below),
the parameter estimators reported are also efficient
in the presence of the same violation of i.i.d. errors.

{p}The options for SEs and statistics are:{break}
{bind:(1) {cmd:robust}} causes {cmd:ivreg210} to report SEs and statistics that are
robust to the presence of arbitrary heteroskedasticity.{break}
{bind:(2) {cmd:cluster}({it:varname})} SEs and statistics are robust to both
arbitrary heteroskedasticity and arbitrary intra-group correlation,
where {it:varname} identifies the group.
See the relevant Stata manual entries on obtaining robust covariance estimates
for further details.{break}
{bind:(3) {cmd:cluster}({it:varname1 varname2})} provides 2-way clustered SEs
and statistics (Cameron et al. 2006, Thompson 2009)
that are robust to arbitrary heteroskedasticity and intra-group correlation
with respect to 2 non-nested categories defined by {it:varname1} and {it:varname2}.
See below for a detailed description.{break}
{bind:(4) {cmd:bw(}{it:#}{cmd:)}} requests AC SEs and statistics that are
robust to arbitrary autocorrelation.{break}
{bind:(5) {cmd:bw(}{it:#}{cmd:)}} combined with {cmd:robust}
requests HAC SEs and statistics that are
robust to both arbitrary heteroskedasticity and arbitrary autocorrelation.{break}
{bind:(6) {cmd:bw(}{it:#}{cmd:)}} combined with {cmd:cluster}({it:varname})
is allowed with either 1- or 2-level clustering if the data are panel data
that are {cmd:tsset} on the time variable {it:varname}.
Following Driscoll and Kray (1998),
the SEs and statistics reported will be robust to disturbances
that are common to panel units and that are persistent, i.e., autocorrelated.{break}
{bind:(7) {cmd:dkraay(}{it:#}{cmd:)}} is a shortcut for the Driscoll-Kraay SEs
for panel data in (6).
It is equivalent to clustering on the {cmd:tsset} time variable
and the bandwidth supplied as {it:#}.
The default kernel Bartlett kernel can be overridden with the {cmd:kernel} option.{break}
{bind:(8) {cmd:kiefer}} implements SEs and statistics for panel data
that are robust to arbitrary intra-group autocorrelation
(but {it:not} heteroskedasticity) as per Kiefer (1980).
It is equivalent to to specifying the truncated kernel with {cmd:kernel(tru)}
and {cmd:bw(}{it:#}{cmd:)} where {it:#} is the full length of the panel.

{p}Details:

{p}{cmd:cluster}({it:varname1 varname2}) provides 2-way cluster-robust SEs
and statistics as proposed by Cameron, Gelbach and Miller (2006) and Thompson (2009).
"Two-way cluster-robust" means the SEs and statistics
are robust to arbitrary within-group correlation in two distinct non-nested categories
defined by {it:varname1} and {it:varname2}.
A typical application would be panel data where one "category" is the panel
and the other "category" is time;
the resulting SEs are robust
to arbitrary within-panel autocorrelation (clustering on panel id)
and to arbitrary contemporaneous cross-panel correlation (clustering on time). 
There is no point in using 2-way cluster-robust SEs if the categories are nested,
because the resulting SEs are equivalent to clustering on the larger category. 
{it:varname1} and {it:varname2} do not have to
uniquely identify observations.
The order of {it:varname1} and {it:varname2} does not matter for the results,
but processing may be faster if the category with the larger number of categories
(typically the panel dimension) is listed first.

{p}Cameron, Gelbach and Miller (2006) show how this approach can accommodate
multi-way clustering, where the number of different non-nested categories is arbitary.
Their Stata command {cmd:cgmreg} implements 2-way and multi-way clustering
for OLS estimation.
The two-way clustered variance-covariance estimator
is calculated using 3 different VCEs: one clustered on {it:varname1},
the second clustered on {it:varname2}, and the third clustered on the
intersection of {it:varname1} and {it:varname2}.
Cameron et al. (2006, pp. 8-9) discuss two possible small-sample adjustments
using the number of clusters in each category.
{cmd:cgmreg} uses one method (adjusting the 3 VCEs separately based on
the number of clusters in the categories VCE clusters on);
{cmd:ivreg210} uses the second (adjusting the final 2-way cluster-robust VCE
using the smaller of the two numbers of clusters).
For this reason, {cmd:ivreg210} and {cmd:cgmreg} will produce slightly different SEs. 
See also {help ivreg2##s_small:small sample corrections} below.

{p}{cmd:ivreg210} allows a variety of options for kernel-based HAC and AC estimation.
The {cmd:bw(}{it:#}{cmd:)} option sets the bandwidth used in the estimation
and {cmd:kernel(}{it:string}{cmd:)} is the kernel used;
the default kernel is the Bartlett kernel,
also known in econometrics as Newey-West (see help {help newey}).
The full list of kernels available is (abbreviations in parentheses):
Bartlett (bar); Truncated (tru); Parzen (par); Tukey-Hanning (thann);
Tukey-Hamming (thamm); Daniell (dan); Tent (ten); and Quadratic-Spectral (qua or qs).
When using the Bartlett, Parzen, or Quadratic spectral kernels, the automatic
bandwidth selection procedure of Newey and West (1994) can be chosen
by specifying {cmd:bw(}{it:auto}{cmd:)}.
{cmd:ivreg210} can also be used for kernel-based estimation
with panel data, i.e., a cross-section of time series.
Before using {cmd:ivreg210} for kernel-based estimation
of time series or panel data,
the data must be {cmd:tsset}; see help {help tsset}.

{p}Following Driscoll and Kraay (1998),
{cmd:bw(}{it:#}{cmd:)} combined with {cmd:cluster}({it:varname})
and applied to panel data produces SEs that are
robust to arbitary common autocorrelated disturbances.
The data must be {cmd:tsset} with the time variable specified as {it:varname}.
Driscoll-Kraay SEs also can be specified using the {cmd:dkraay(}{it:#}{cmd:)}} option,
where {it:#} is the bandwidth.
The default Bartlett kernel can be overridden with the {cmd:kernel} option.
Note that the Driscoll-Kraay variance-covariance estimator is a large-T estimator,
i.e., the panel should have a long-ish time-series dimension.

{p}Used with 2-way clustering as per Thompson (2009),
{cmd:bw(}{it:#}{cmd:)} combined with {cmd:cluster}({it:varname})
provides SEs and statistics that are robust
to autocorrelated within-panel disturbances (clustering on panel id)
and to autocorrelated across-panel disturbances (clustering on time
combined with kernel-based HAC).
The approach proposed by Thompson (2009) can be implemented in {cmd:ivreg210}
by choosing the truncated kernel {cmd:kernel(}{it:tru}{cmd:)}
and {cmd:bw(}{it:#}{cmd:)}, where the researcher knows or assumes
that the common autocorrelated disturbances can be ignored after {it:#} periods.

{p}{cmd:Important:} Users should be aware of the asymptotic requirements
for the consistency of the chosen VCE.
In particular: consistency of the 1-way cluster-robust VCE requires
the number of clusters to go off to infinity;
consistency of the 2-way cluster-robust VCE requires the numbers of
clusters in both categories to go off to infinity;
consistency of kernel-robust VCEs requires the numbers of
observations in the time dimension to go off to infinity.
See Angrist and Pischke (2009), Cameron et al. (2006) and Thompson (2009)
for detailed discussions of the performance of the cluster-robust VCE
when the numbers of clusters is small.

{marker s_gmm}{dlgtab:GMM estimation}

{p}When combined with the above options, the {cmd:gmm2s} option generates
efficient estimates of the coefficients as well as consistent
estimates of the standard errors.
The {cmd:gmm2s} option implements the two-step efficient
generalized method of moments (GMM) estimator.
The efficient GMM estimator minimizes the GMM criterion function
J=N*g'*W*g, where N is the sample size,
g are the orthogonality or moment conditions
(specifying that all the exogenous variables, or instruments,
in the equation are uncorrelated with the error term)
and W is a weighting matrix.
In two-step efficient GMM, the efficient or optimal weighting matrix
is the inverse of an estimate of the covariance matrix of orthogonality conditions.
The efficiency gains of this estimator relative to the
traditional IV/2SLS estimator derive from the use of the optimal
weighting matrix, the overidentifying restrictions of the model,
and the relaxation of the i.i.d. assumption.
For an exactly-identified model,
the efficient GMM and traditional IV/2SLS estimators coincide,
and under the assumptions of conditional homoskedasticity and independence,
the efficient GMM estimator is the traditional IV/2SLS estimator.
For further details, see Hayashi (2000), pp. 206-13 and 226-27.

{p}The {cmd:wmatrix} option allows the user to specify a weighting matrix
rather than computing the optimal weighting matrix.
Estimation with the {cmd:wmatrix} option yields a possibly inefficient GMM estimator.
{cmd:ivreg210} will use this inefficient estimator as the first-step GMM estimator
in two-step efficient GMM when combined with the {cmd:gmm2s} option;
otherwise, {cmd:ivreg210} reports the regression results
using this inefficient GMM estimator.

{p}The {cmd:smatrix} option allows the user to directly 
specify the matrix S, the covariance matrix of orthogonality conditions.
{cmd:ivreg210} will use this matrix in the calculation of the variance-covariance
matrix of the estimator, the J statistic,
and,  if the {cmd:gmm2s} option is specified,
the two-step efficient GMM coefficients.
The {cmd:smatrix} can be useful for guaranteeing a positive test statistic
in user-specified "GMM-distance tests" (see {help ivreg2##s_endog:below}).
For further details, see Hayashi (2000), pp. 220-24.

{marker s_liml}{dlgtab:LIML, k-class and GMM-CUE estimation}

{marker liml}{p} Maximum-likelihood estimation of a single equation of this form
(endogenous RHS variables and excluded instruments)
is known as limited-information maximum likelihood or LIML.
The overidentifying restrictions test
reported after LIML estimation is the Anderson-Rubin (1950) overidentification 
statistic in a homoskedastic context.
LIML, OLS and IV/2SLS are examples of k-class estimators.
LIML is a k-class estimator with k=the LIML eigenvalue lambda;
2SLS is a k-class estimator with k=1;
OLS is a k-class esimator with k=0.
Estimators based on other values of k have been proposed.
Fuller's modified LIML (available with the {cmd:fuller(}{it:#}{cmd:)} option)
sets k = lambda - alpha/(N-L), where lambda is the LIML eigenvalue,
L = number of instruments (L1 excluded and L2 included),
and the Fuller parameter alpha is a user-specified positive constant.
Nagar's bias-adjusted 2SLS estimator can be obtained with the
{cmd:kclass(}{it:#}{cmd:)} option by setting
k = 1 + (L-K)/N, where L-K = number of overidentifying restrictions,
K = number of regressors (K1 endogenous and K2=L2 exogenous)
and N = the sample size.
For a discussion of LIML and k-class estimators,
see Davidson and MacKinnon (1993, pp. 644-51).

{p} The GMM generalization of the LIML estimator
to the case of possibly heteroskedastic
and autocorrelated disturbances
is the "continuously-updated" GMM estimator or CUE
of Hansen, Heaton and Yaron (1996).
The CUE estimator directly maximizes the GMM objective function
J=N*g'*W(b_cue)*g, where W(b_cue) is an optimal weighting matrix
that depends on the estimated coefficients b_cue.
{cmd:cue}, combined with {cmd:robust}, {cmd:cluster}, and/or {cmd:bw},
generates coefficient estimates that are efficient in the presence
of the corresponding deviations from homoskedasticity.
Specifying {cmd:cue} with no other options
is equivalent to the combination of the options {cmd:liml} and {cmd:coviv}.
The CUE estimator requires numerical optimization methods,
and the implementation here uses Mata's {cmd:optimize} routine.
The starting values are either IV or two-step efficient GMM
coefficient estimates.
If the user wants to evaluate the CUE objective function at
an arbitrary user-defined coefficient vector instead of having {cmd:ivreg210}
find the coefficient vector that minimizes the objective function,
the {cmd:b0(}{it:matrix}{cmd:)} option can be used.
The value of the CUE objective function at {cmd:b0}
is the Sargan or Hansen J statistic reported in the output.

{marker s_sumopt}{dlgtab:Summary of robust, HAC, AC, GMM, LIML and CUE options}



Estimator {col 20}No VCE option specificed {col 65}VCE option
 option {col 60}{cmd:robust}, {cmd:cluster}, {cmd:bw}, {cmd:kernel}
{hline}
(none){col 15}IV/2SLS{col 60}IV/2SLS with
{col 15}SEs consistent under homoskedasticity{col 60}robust SEs

{cmd:liml}{col 15}LIML{col 60}LIML with
{col 15}SEs consistent under homoskedasticity{col 60}robust SEs

{cmd:gmm2s}{col 15}IV/2SLS{col 60}Two-step GMM with
{col 15}SEs consistent under homoskedasticity{col 60}robust SEs

{cmd:cue}{col 15}LIML{col 60}CUE GMM with
{col 15}SEs consistent under homoskedasticity{col 60}robust SEs

{cmd:kclass}{col 15}k-class estimator{col 60}k-class estimator with
{col 15}SEs consistent under homoskedasticity{col 60}robust SEs

{cmd:wmatrix}{col 15}Possibly inefficient GMM{col 60}Ineff GMM with
{col 15}SEs consistent under homoskedasticity{col 60}robust SEs

{cmd:gmm2s} + {col 15}Two-step GMM{col 60}Two-step GMM with
{cmd:wmatrix}{col 15}with user-specified first step{col 60}robust SEs
{col 15}SEs consistent under homoskedasticity


{p}With the {cmd:bw} or {cmd:bw} and {cmd:kernel} VCE options,
SEs are autocorrelation-robust (AC).
Combining the {cmd:robust} option with {cmd:bw}, SEs are heteroskedasticity- and 
autocorrelation-robust (HAC). 

{p}For further details, see Hayashi (2000), pp. 206-13 and 226-27
(on GMM estimation), Wooldridge (2002), p. 193 (on cluster-robust GMM),
and Hayashi (2000), pp. 406-10 or Cushing and McGarvey (1999)
(on kernel-based covariance estimation).

{marker s_overid}{marker overidtests}{dlgtab:Testing overidentifying restrictions}

{p}The Sargan-Hansen test is a test of overidentifying restrictions.
The joint null hypothesis is that the instruments are valid
instruments, i.e., uncorrelated with the error term,
and that the excluded instruments are correctly excluded from the estimated equation.
Under the null, the test statistic is distributed as chi-squared
in the number of (L-K) overidentifying restrictions.
A rejection casts doubt on the validity of the instruments.
For the efficient GMM estimator, the test statistic is
Hansen's J statistic, the minimized value of the GMM criterion function.
For the 2SLS estimator, the test statistic is Sargan's statistic,
typically calculated as N*R-squared from a regression of the IV residuals
on the full set of instruments.
Under the assumption of conditional homoskedasticity,
Hansen's J statistic becomes Sargan's statistic.
The J statistic is consistent in the presence of heteroskedasticity
and (for HAC-consistent estimation) autocorrelation;
Sargan's statistic is consistent if the disturbance is homoskedastic
and (for AC-consistent estimation) if it is also autocorrelated.
With {cmd:robust}, {cmd:bw} and/or {cmd:cluster},
Hansen's J statistic is reported.
In the latter case the statistic allows observations
to be correlated within groups.
For further discussion see e.g. Hayashi (2000, pp. 227-8, 407, 417).

{p}The Sargan statistic can also be calculated after
{cmd:ivreg} or {cmd:ivreg210} by the command {cmd:overid}.
The features of {cmd:ivreg210} that are unavailable in {cmd:overid}
are the J statistic and the C statistic;
the {cmd:overid} options unavailable in {cmd:ivreg210}
are various small-sample and pseudo-F versions of Sargan's statistic
and its close relative, Basmann's statistic.
See help {help overid} (if installed).

{marker s_endog}{dlgtab:Testing subsets of regressors and instruments for endogeneity}

{marker ctest}{p}The C statistic
(also known as a "GMM distance"
or "difference-in-Sargan" statistic)
implemented using the {cmd:orthog} option,
allows a test of a subset of the orthogonality conditions, i.e.,
it is a test of the exogeneity of one or more instruments.
It is defined as
the difference of the Sargan-Hansen statistic
of the equation with the smaller set of instruments
(valid under both the null and alternative hypotheses)
and the equation with the full set of instruments,
i.e., including the instruments whose validity is suspect.
Under the null hypothesis that
both the smaller set of instruments
and the additional, suspect instruments are valid,
the C statistic is distributed as chi-squared
in the number of instruments tested.
Note that failure to reject the null hypothesis
requires that the full set of orthogonality conditions be valid;
the C statistic and the Sargan-Hansen test statistics
for the equations with both the smaller and full set of instruments
should all be small.
The instruments tested may be either excluded or included exogenous variables.
If excluded exogenous variables are being tested,
the equation that does not use these orthogonality conditions
omits the suspect instruments from the excluded instruments.
If included exogenous variables are being tested,
the equation that does not use these orthogonality conditions
treats the suspect instruments as included endogenous variables.
To guarantee that the C statistic is non-negative in finite samples,
the estimated covariance matrix of the full set orthogonality conditions
is used to calculate both Sargan-Hansen statistics
(in the case of simple IV/2SLS, this amounts to using the MSE
from the unrestricted equation to calculate both Sargan statistics).
If estimation is by LIML, the C statistic reported
is now based on the Sargan-Hansen test statistics from
the restricted and unrestricted equation.
For further discussion, see Hayashi (2000), pp. 218-22 and pp. 232-34.

{marker endogtest}{p}Endogeneity tests of one or more endogenous regressors
can implemented using the {cmd:endog} option.
Under the null hypothesis that the specified endogenous regressors
can actually be treated as exogenous, the test statistic is distributed
as chi-squared with degrees of freedom equal to the number of regressors tested.
The endogeneity test implemented by {cmd:ivreg210}, is, like the C statistic,
defined as the difference of two Sargan-Hansen statistics:
one for the equation with the smaller set of instruments,
where the suspect regressor(s) are treated as endogenous,
and one for the equation with the larger set of instruments,
where the suspect regressors are treated as exogenous.
Also like the C statistic, the estimated covariance matrix used
guarantees a non-negative test statistic.
Under conditional homoskedasticity,
this endogeneity test statistic is numerically equal to
a Hausman test statistic; see Hayashi (2000, pp. 233-34).
The endogeneity test statistic can also be calculated after
{cmd:ivreg} or {cmd:ivreg210} by the command {cmd:ivendog}.
Unlike the Durbin-Wu-Hausman tests reported by {cmd:ivendog},
the {cmd:endog} option of {cmd:ivreg210} can report test statistics
that are robust to various violations of conditional homoskedasticity;
the {cmd:ivendog} option unavailable in {cmd:ivreg210}
is the Wu-Hausman F-test version of the endogeneity test.
See help {help ivendog} (if installed).

{marker s_relevance}{dlgtab:Tests of under- and weak identification}

{marker idtest}{p}{cmd:ivreg210} automatically reports tests of
both underidentification and weak identification.
The underidentification test is an LM test of whether the equation is identified,
i.e., that the excluded instruments are "relevant",
meaning correlated with the endogenous regressors.
The test is essentially the test of the rank of a matrix:
under the null hypothesis that the equation is underidentified,
the matrix of reduced form coefficients on the L1 excluded instruments
has rank=K1-1 where K1=number of endogenous regressors.
Under the null,
the statistic is distributed as chi-squared
with degrees of freedom=(L1-K1+1).
A rejection of the null indicates that the matrix is full column rank,
i.e., the model is identified.

{p}For a test of whether a particular endogenous regressor alone is identified,
see the discussion {help ivreg2##apstats:below} of the Angrist-Pischke (2009) procedure.

{p}When errors are assumed to be i.i.d.,
{cmd:ivreg210} automatically reports an LM version of
the Anderson (1951) canonical correlations test.
Denoting the minimum eigenvalue of the canonical correlations as CCEV,
the smallest canonical correlation between the K1 endogenous regressors
and the L1 excluded instruments
(after partialling out the K2=L2 exogenous regressors)
is sqrt(CCEV),
and the Anderson LM test statistic is N*CCEV,
i.e., N times the square of the smallest canonical correlation.
With the {cmd:first} or {cmd:ffirst} options,
{cmd:ivreg210} also reports the closely-related
Cragg-Donald (1993) Wald test statistic.
Again assuming i.i.d. errors,
and denoting the minimum eigenvalue of the Cragg-Donald statistic as CDEV,
CDEV=CCEV/(1-CCEV),
and the Cragg-Donald Wald statistic is N*CDEV.
Like the Anderson LM statistic, the Cragg-Donald Wald statistic
is distributed as chi-squred with (L1-K1+1) degrees of freedom.
Note that a result of rejection of the null
should be treated with caution,
because weak instrument problems may still be present.
See Hall et al. (1996) for a discussion of this test,
and below for discussion of testing for the presence of weak instruments.

{p}When the i.i.d. assumption is dropped
and {cmd:ivreg210} reports heteroskedastic, AC, HAC
or cluster-robust statistics,
the Anderson LM and Cragg-Donald Wald statistics are no longer valid.
In these cases, {cmd:ivreg210} reports the LM and Wald versions
of the Kleibergen-Paap (2006) rk statistic,
also distributed as chi-squared with (L1-K1+1) degrees of freedom.
The rk statistic can be seen as a generalization of these tests
to the case of non-i.i.d. errors;
see Kleibergen and Paap (2006) for discussion,
and Kleibergen and Schaffer (2007) for a Stata implementation, {cmd:ranktest}.
{cmd:ivreg210} requires {cmd:ranktest} to be installed,
and will prompt the user to install it if necessary.
If {cmd:ivreg210} is invoked with the {cmd:robust} option,
the rk underidentification test statistics will be heteroskedastic-robust,
and similarly with {cmd:bw} and {cmd:cluster}.

{marker widtest}{p}"Weak identification" arises when the excluded instruments are correlated
with the endogenous regressors, but only weakly.
Estimators can perform poorly when instruments are weak,
and different estimators are more robust to weak instruments (e.g., LIML)
than others (e.g., IV);
see, e.g., Stock and Yogo (2002, 2005) for further discussion.
When errors are assumed to be i.i.d.,
the test for weak identification automatically reported
by {cmd:ivreg210} is an F version of the Cragg-Donald Wald statistic, (N-L)/L1*CDEV,
where L is the number of instruments and L1 is the number of excluded instruments.
Stock and Yogo (2005) have compiled critical values
for the Cragg-Donald F statistic for
several different estimators (IV, LIML, Fuller-LIML),
several different definitions of "perform poorly" (based on bias and test size),
and a range of configurations (up to 100 excluded instruments
and up to 2 or 3 endogenous regressors,
depending on the estimator).
{cmd:ivreg210} will report the Stock-Yogo critical values
if these are available;
missing values mean that the critical values
haven't been tabulated or aren't applicable.
See Stock and Yogo (2002, 2005) for details.

{p}When the i.i.d. assumption is dropped
and {cmd:ivreg210} is invoked with the {cmd:robust}, {cmd:bw} or {cmd:cluster} options,
the Cragg-Donald-based weak instruments test is no longer valid.
{cmd:ivreg210} instead reports a correspondingly-robust
Kleibergen-Paap Wald rk F statistic.
The degrees of freedom adjustment for the rk statistic is (N-L)/L1,
as with the Cragg-Donald F statistic,
except in the cluster-robust case,
when the adjustment is N/(N-1) * (N_clust-1)/N_clust,
following the standard Stata small-sample adjustment for cluster-robust. In the case of two-way clustering, N_clust is the minimum of N_clust1 and N_clust2.
The critical values reported by {cmd:ivreg210} for the Kleibergen-Paap statistic
are the Stock-Yogo critical values for the Cragg-Donald i.i.d. case.
The critical values reported with 2-step GMM
are the Stock-Yogo IV critical values,
and the critical values reported with CUE
are the LIML critical values.

{marker s_redundancy}{dlgtab:Testing instrument redundancy}

{marker redtest}{p}The {cmd:redundant} option allows a test of
whether a subset of excluded instruments is "redundant".
Excluded instruments are redundant if the asymptotic efficiency
of the estimation is not improved by using them.
Breusch et al. (1999) show that the condition for the redundancy of a set of instruments
can be stated in several equivalent ways:
e.g., in the reduced form regressions of the endogenous regressors
on the full set of instruments,
the redundant instruments have statistically insignificant coefficients;
or the partial correlations between the endogenous regressors
and the instruments in question are zero.
{cmd:ivreg210} uses a formulation based on testing the rank
of the matrix cross-product between the endogenous regressors
and the possibly-redundant instruments after both have
all other instruments partialled-out;
{cmd:ranktest} is used to test whether the matrix has zero rank.
The test statistic is an LM test
and numerically equivalent to a regression-based LM test.
Under the null that the specified instruments are redundant,
the statistic is distributed as chi-squared
with degrees of freedom=(#endogenous regressors)*(#instruments tested).
Rejection of the null indicates that
the instruments are not redundant.
When the i.i.d. assumption is dropped
and {cmd:ivreg210} reports heteroskedastic, AC, HAC
or cluster-robust statistics,
the redundancy test statistic is similarly robust.
See Baum et al. (2007) for further discussion.

{p}Calculation and reporting of all underidentification
and weak identification statistics
can be supressed with the {cmd:noid} option.

{marker s_first}{dlgtab:First-stage regressions, identification, and weak-id-robust inference}

{marker apstats}{p}The {cmd:first} and {cmd:ffirst} options report
various first-stage results and identification statistics.
Tests of both underidentification and weak identification are reported
for each endogenous regressor separately,
using the method described by Angrist and Pischke (2009), pp. 217-18
(see also the note on their "Mostly Harmless Econometrics"
{browse "http://www.mostlyharmlesseconometrics.com/2009/10/multivariate-first-stage-f-not/" :blog}.

{p}The Angrist-Pischke (AP) first-stage chi-squared and F statistics
are tests of underidentification and weak identification, respectively,
of individual endogenous regressors.
They are constructed by "partialling-out" linear projections of the
remaining endogenous regressors.
The AP chi-squared Wald statistic is distributed as chi2(L1-K1+1))
under the null that the particular endogenous regressor
in question is unidentified.
In the special case of a single endogenous regressor,
the AP statistic reported is identical to underidentification statistics reported
in the {cmd:ffirst} output,
namely the Cragg-Donald Wald statistic (if i.i.d.)
or the Kleibergen-Paap rk Wald statistic (if robust, cluster-robust, AC or HAC
statistics have been requested);
see {help ivreg2##idtest:above}.
Note the difference in the null hypotheses if there are two or more endogenous regressors:
the AP test will fail to reject if a particular endogenous regressor is unidentified,
whereas the Anderson/Cragg-Donald/Kleibergen-Paap tests of underidentification
will fail to reject if {it:any} of the endogenous regressors is unidentified.

{p}The AP first-stage F statistic is the F form of the same test statistic.
It can be used as a diagnostic for whether a particular endogenous regressor
is "weakly identified" (see {help ivreg2##widtest:above}).
Critical values for the AP first-stage F as a test of weak identification are not available,
but the test statistic can be compared to the Stock-Yogo (2002, 2005) critical
values for the Cragg-Donald F statistic with K1=1.

{p}The first-stage results are always reported with small-sample statistics,
to be consistent with the recommended use of the first-stage F-test as a diagnostic.
If the estimated equation is reported with robust standard errors,
the first-stage F-test is also robust.

{p}A full set of first-stage statistics for each of the K1 endogenous regressors
is saved in the matrix e(first).
These include (a) the AP F and chi-squared statistics; (b) the "partial R-squared"
(squared partial correlation) corresponding to the AP statistics;
(c) Shea's (1997) partial R-squared measure (closely related to the AP statistic,
but not amenable to formal testing); (d) the simple F and partial R-squared
statistics for each of the first-stage equations,
with no adjustments if there is more than one endogenous regressor.
In the special case of a single endogenous regressor,
these F statistics and partial R-squareds are identical.

{marker wirobust}{p}The first-stage output also includes
two statistics that provide weak-instrument robust inference
for testing the significance of the endogenous regressors in the structural equation being estimated.
The first statistic is the Anderson-Rubin (1949) test
(not to be confused with the Anderson-Rubin overidentification test for LIML estimation;
see {help ivreg2##s_liml:above}).
The second is the closely related Stock-Wright (2000) S statistic.
The null hypothesis tested in both cases is that
the coefficients of the endogenous regressors in the structural equation are jointly equal to zero,
and, in addition, that the overidentifying restrictions are valid.
Both tests are robust to the presence of weak instruments.
The tests are equivalent to estimating the reduced form of the equation
(with the full set of instruments as regressors)
and testing that the coefficients of the excluded instruments are jointly equal to zero.
In the form reported by {cmd:ivreg210},the Anderson-Rubin statistic is a Wald test
and the Stock-Wright S statistic is a GMM-distance test.
Both statistics are distributed as chi-squared with L1 degrees of freedom,
where L1=number of excluded instruments.
The traditional F-stat version of the Anderson-Rubin test is also reported.
See Stock and Watson (2000), Dufour (2003), Chernozhukov and Hansen (2005) and Kleibergen (2007)
for further discussion.
For related alternative test statistics that are also robust to weak instruments,
see {help condivreg} and {help rivtest},
and the corresponding discussions
in Moreira and Poi (2003) and Mikusheva and Poi (2006),
and in Finlay and Magnusson (2009), respectively.

{p}The {cmd:savefirst} option requests that the individual first-stage regressions
be saved for later access using the {cmd:estimates} command.
If saved, they can also be displayed using {cmd:first} or {cmd:ffirst} and the {cmd:ivreg210} replay syntax.
The regressions are saved with the prefix "_ivreg2_",
unless the user specifies an alternative prefix with the
{cmdab:savefp:refix}{cmd:(}{it:prefix}{cmd:)} option.

{marker s_rf}{dlgtab:Reduced form estimates}

{p}The {cmd:rf} option requests that the reduced form estimation of the equation be displayed.
The {cmd:saverf} option requests that the reduced form estimation is saved
for later access using the {cmd:estimates} command.
If saved, it can also be displayed using the {cmd:rf} and the {cmd:ivreg210} replay syntax.
The regression is saved with the prefix "_ivreg2_",
unless the user specifies an alternative prefix with the
{cmdab:saverfp:refix}{cmd:(}{it:prefix}{cmd:)} option.

{marker s_partial}{dlgtab:Partialling-out exogenous regressors}

{marker partial}{p}The {cmd:partial(}{it:varlist}{cmd:)} option requests that
the exogenous regressors in {it:varlist} are "partialled out"
from all the other variables (other regressors and excluded instruments) in the estimation.
If the equation includes a constant, it is also automatically partialled out as well.
The coefficients corresponding to the regressors in {it:varlist} are not calculated.
By the Frisch-Waugh-Lovell (FWL) theorem, in IV,
two-step GMM and LIML estimation the coefficients for the remaining regressors
are the same as those that would be obtained if the variables were not partialled out.
(NB: this does not hold for CUE or GMM iterated more than two steps.)
The {cmd:partial} option is most useful when using {cmd:cluster}
and #clusters < (#exogenous regressors + #excluded instruments).
In these circumstances,
the covariance matrix of orthogonality conditions S is not of full rank,
and efficient GMM and overidentification tests are infeasible
since the optimal weighting matrix W = {bind:S^-1}
cannot be calculated.
The problem can be addressed by using {cmd:partial}
to partial out enough exogenous regressors for S to have full rank.
A similar problem arises when the regressors include a variable that is a singleton dummy,
i.e., a variable with one 1 and N-1 zeros or vice versa,
if a robust covariance matrix is requested.
The singleton dummy causes the robust covariance matrix estimator
to be less than full rank.
In this case, partialling-out the variable with the singleton dummy solves the problem.
Specifying {cmd:partial(_cons)} will cause just the constant to be partialled-out,
i.e., the equation will be estimated in deviations-from-means form.
When {cmd:ivreg210} is invoked with {cmd:partial},
it reports test statistics with the same small-sample adjustments
as if estimating without {cmd:partial}.
Note that after estimation using the {cmd:partial} option,
the post-estimation {cmd:predict} can be used only to generate residuals,
and that in the current implementation,
{cmd:partial} is not compatible with endogenous variables or instruments (included or excluded)
that use time-series operators.

{marker s_ols}{dlgtab:OLS and Heteroskedastic OLS (HOLS) estimation}

{p}{cmd:ivreg21-} also allows straightforward OLS estimation
by using the same syntax as {cmd:regress}, i.e.,
{it:ivreg210 depvar varlist1}.
This can be useful if the user wishes to use one of the
features of {cmd:ivreg210} in OLS regression, e.g., AC or
HAC standard errors.

{p}If the list of endogenous variables {it:varlist2} is empty
but the list of excluded instruments {it:varlist_iv} is not,
and the option {cmd:gmm2s} is specified,
{cmd:ivreg210} calculates Cragg's "heteroskedastic OLS" (HOLS) estimator,
an estimator that is more efficient than OLS
in the presence of heteroskedasticity of unknown form
(see Davidson and MacKinnon (1993), pp. 599-600).
If the option {cmd:bw(}{it:#}{cmd:)} is specified,
the HOLS estimator is efficient in the presence of
arbitrary autocorrelation;
if both {cmd:bw(}{it:#}{cmd:)} and {cmd:robust} are specified
the HOLS estimator is efficient in the presence of
arbitrary heteroskedasticity and autocorrelation;
and if {cmd:cluster(}{it:varlist}{cmd:)} is used,
the HOLS estimator is efficient in the presence of
arbitrary heteroskedasticity and within-group correlation.
The efficiency gains of HOLS derive from the orthogonality conditions
of the excluded instruments listed in {it:varlist_iv}.
If no endogenous variables are specified and {cmd:gmm2s} is not specified,
{cmd:ivreg210} reports standard OLS coefficients.
The Sargan-Hansen statistic reported
when the list of endogenous variables {it:varlist2} is empty
is a Lagrange multiplier (LM) test
of the hypothesis that the excluded instruments {it:varlist_iv} are
correctly excluded from the restricted model.
If the estimation is LIML, the LM statistic reported
is now based on the Sargan-Hansen test statistics from
the restricted and unrestricted equation.
For more on LM tests, see e.g. Wooldridge (2002), pp. 58-60.
Note that because the approach of the HOLS estimator
has applications beyond heteroskedastic disturbances,
and to avoid confusion concerning the robustness of the estimates,
the estimators presented above as "HOLS"
are described in the output of {cmd:ivreg210}
as "2-Step GMM", "CUE", etc., as appropriate.

{marker s_collin}{dlgtab:Collinearities}

{p}{cmd:ivreg210} checks the lists of included instruments,
excluded instruments, and endogenous regressors
for collinearities and duplicates. If an endogenous regressor is
collinear with the instruments, it is reclassified as exogenous. If any
endogenous regressors are collinear with each other, some are dropped.
If there are any collinearities among the instruments, some are dropped.
In Stata 9+, excluded instruments are dropped before included instruments.
If any variables are dropped, a list of their names are saved
in the macros {cmd:e(collin)} and/or {cmd:e(dups)}.
Lists of the included and excluded instruments
and the endogenous regressors with collinear variables and duplicates removed
are also saved in macros with "1" appended
to the corresponding macro names.

{p}Collinearity checks can be supressed with the {cmd:nocollin} option.

{marker s_speed}{dlgtab:Speed options: nocollin and noid}

{p}Two options are available for speeding execution.
{cmd:nocollin} specifies that the collinearity checks not be performed.
{cmd:noid} suspends calculation and reporting of
the underidentification and weak identification statistics
in the main output.

{marker s_small}{dlgtab:Small sample corrections}

{p}Mean square error = sqrt(RSS/(N-K)) if {cmd:small}, = sqrt(RSS/N) otherwise.

{p}If {cmd:robust} is chosen, the finite sample adjustment
(see {hi:[R] regress}) to the robust variance-covariance matrix
qc = N/(N-K) if {cmd:small}, qc = 1 otherwise.

{p}If {cmd:cluster} is chosen, the finite sample adjustment
qc = (N-1)/(N-K)*M/(M-1) if {cmd:small}, where M=number of clusters,
qc = 1 otherwise.
If 2-way clustering is used, M=min(M1,M2),
where M1=number of clusters in group 1
and M2=number of clusters in group 2.

{p}The Sargan and C (difference-in-Sargan) statistics use
error variance = RSS/N, i.e., there is no small sample correction.

{p}A full discussion of these computations and related topics
can be found in Baum, Schaffer, and Stillman (2003) and Baum, Schaffer and
Stillman (2007). Some features of the program postdate the former article and are described in the latter paper.
Some features, such as two-way  clustering, postdate the latter article as well.


{marker s_options}{title:Options summary}

{p 0 4}{cmd:gmm2s} requests the two-step efficient GMM estimator.
If no endogenous variables are specified, the estimator is Cragg's HOLS estimator.

{p 0 4}{cmd:liml} requests the limited-information maximum likelihood estimator.

{p 0 4}{cmd:fuller(}{it:#}{cmd:)} specifies that Fuller's modified LIML estimator
is calculated using the user-supplied Fuller parameter alpha,
a non-negative number.
Alpha=1 has been suggested as a good choice.

{p 0 4}{cmd:kclass(}{it:#}{cmd:)} specifies that a general k-class estimator is calculated
using the user-supplied #, a non-negative number.

{p 0 4}{cmd:coviv} specifies that the matrix used to calculate the
covariance matrix for the LIML or k-class estimator
is based on the 2SLS matrix, i.e., with k=1.
In this case the covariance matrix will differ from that calculated for the 2SLS
estimator only because the estimate of the error variance will differ.
The default is for the covariance matrix to be based on the LIML or k-class matrix.

{p 0 4}{cmd:cue} requests the GMM continuously-updated estimator (CUE).

{p 0 4}{cmd:b0(}{it:matrix}{cmd:)} specifies that the J statistic
(i.e., the value of the CUE objective function)
should be calculated for an arbitrary coefficient vector {cmd:b0}.
That vector must be provided as a matrix with appropriate row and column names.
Under- and weak-identification statistics are not reported
in the output.

{p 0 4}{cmd:robust} specifies that the Eicker/Huber/White/sandwich estimator of
variance is to be used in place of the traditional calculation.  {cmd:robust}
combined with {cmd:cluster()} further allows residuals which are not
independent within cluster (although they must be independent between
clusters).  See {hi:[U] Obtaining robust variance estimates}.

{p 0 4}{cmd:cluster}{cmd:(}{it:varlist}{cmd:)} specifies that the observations
are independent across groups (clusters) but not necessarily independent
within groups.
With 1-way clustering, {cmd:cluster}{cmd:(}{it:varname}{cmd:)}
specifies to which group each observation
belongs; e.g., {cmd:cluster(personid)} in data with repeated observations on
individuals.
With 2-way clustering, {cmd:cluster}{cmd:(}{it:varname1 varname2}{cmd:)}
specifies the two (non-nested) groups to which each observation belongs.
Specifying {cmd:cluster()} implies {cmd:robust}.

{p 0 4}{cmd:bw(}{it:#}{cmd:)} impements AC or HAC covariance estimation
with bandwidth equal to {it:#}, where {it:#} is an integer greater than zero.
Specifying {cmd:robust} implements HAC covariance estimation;
omitting it implements AC covariance estimation.
If the Bartlett (default), Parzen or Quadratic Spectral kernels are selected,
the value {cmd:auto} may be given (rather than an integer)
to invoke Newey and West's (1994) automatic bandwidth selection procedure.

{p 0 4}{cmd:kernel(}{it:string)}{cmd:)} specifies the kernel
to be used for AC and HAC covariance estimation;
the default kernel is Bartlett (also known in econometrics
as Newey-West).
The full list of kernels available is (abbreviations in parentheses):
Bartlett (bar); Truncated (tru); Parzen (par); Tukey-Hanning (thann);
Tukey-Hamming (thamm); Daniell (dan); Tent (ten); and Quadratic-Spectral (qua or qs).

{p 4 4}Note: in the cases of the Bartlett, Parzen,
and Tukey-Hanning/Hamming kernels, the number of lags used
to construct the kernel estimate equals the bandwidth minus one.
Stata's official {cmd:newey} implements
HAC standard errors based on the Bartlett kernel,
and requires the user to specify
the maximum number of lags used and not the bandwidth;
see help {help newey}.
If these kernels are used with {cmd:bw(1)},
no lags are used and {cmd:ivreg210} will report the usual
Eicker/Huber/White/sandwich variance estimates.

{p 0 4}{cmd:wmatrix(}{it:matrix}{cmd:)} specifies a user-supplied weighting matrix
in place of the computed optimal weighting matrix.
The matrix must be positive definite.
The user-supplied matrix must have the same row and column names
as the instrument variables in the regression model (or a subset thereof). 

{p 0 4}{cmd:smatrix(}{it:matrix}{cmd:)} specifies a user-supplied covariance matrix
of the orthogonality conditions to be used in calculating the covariance matrix of the estimator.
The matrix must be positive definite.
The user-supplied matrix must have the same row and column names
as the instrument variables in the regression model (or a subset thereof).  

{p 0 4}{cmd:orthog}{cmd:(}{it:varlist_ex}{cmd:)} requests that a C-statistic
be calculated as a test of the exogeneity of the instruments in {it:varlist_ex}.
These may be either included or excluded exogenous variables.
The standard order condition for identification applies:
the restricted equation that does not use these variables
as exogenous instruments must still be identified.

{p 0 4}{cmd:endog}{cmd:(}{it:varlist_en}{cmd:)} requests that a C-statistic
be calculated as a test of the endogeneity
of the endogenous regressors in {it:varlist_en}.

{p 0 4}{cmd:redundant}{cmd:(}{it:varlist_ex}{cmd:)} requests an LM test
of the redundancy of the instruments in {it:varlist_ex}.
These must be excluded exogenous variables.
The standard order condition for identification applies:
the restricted equation that does not use these variables
as exogenous instrumenst must still be identified.

{p 0 4}{cmd:small} requests that small-sample statistics (F and t-statistics)
be reported instead of large-sample statistics (chi-squared and z-statistics).
Large-sample statistics are the default.
The exception is the statistic for the significance of the regression,
which is always reported as a small-sample F statistic.

{p 0 4}{cmd:noconstant} suppresses the constant term (intercept) in the
regression.  If {cmd:noconstant} is specified, the constant term is excluded
from both the final regression and the first-stage regression.  To include a
constant in the first-stage when {cmd:noconstant} is specified, explicitly
include a variable containing all 1's in {it:varlist_iv}.

{p 0 4}{cmd:first} requests that the full first-stage regression results be displayed,
along with the associated diagnostic and identification statistics.

{p 0 4}{cmd:ffirst} requests the first-stage diagnostic and identification statistics.
The results are saved in various e() macros.

{p 0 4}{cmd:nocollin} suppresses the checks for collinearities
and duplicate variables.

{p 0 4}{cmd:noid} suppresses the calculation and reporting
of underidentification and weak identification statistics.

{p 0 4}{cmd:savefirst} requests that the first-stage regressions results
are saved for later access using the {cmd:estimates} command.
The names under which the first-stage regressions are saved
are the names of the endogenous regressors prefixed by "_ivreg2_".
If these use Stata's time-series operators,
the "." is replaced by a "_".
The maximum number of first-stage estimation results that can be saved
depends on how many other estimation results the user has already saved
and on the maximum supported by Stata.

{p 0 4}{cmdab:savefp:refix}{cmd:(}{it:prefix}{cmd:)} requests that
the first-stage regression results be saved using the user-specified prefix
instead of the default "_ivreg2_".

{p 0 4}{cmd:rf} requests that the reduced-form estimation of the equation
be displayed.

{p 0 4}{cmd:saverf} requests that the reduced-form estimation of the equation
be saved for later access using the {cmd:estimates} command.
The estimation is stored under the name of the dependent variable
prefixed by "_ivreg2_".
If this uses Stata's time-series operators,
the "." is replaced by a "_".

{p 0 4}{cmdab:saverfp:refix}{cmd:(}{it:prefix}{cmd:)} requests that
the reduced-form estimation be saved using the user-specified prefix
instead of the default "_ivreg2_".

{p 0 4}{cmd:partial(}{it:varlist}{cmd:)} requests that
the exogenous regressors in {it:varlist} be partialled out
from the other variables in the equation.
If the equation includes a constant,
it is automatically partialled out as well. 
The coefficients corresponding to the regressors in {it:varlist}
are not calculated.

{p 0 4}{cmd:level(}{it:#}{cmd:)} specifies the confidence level, in percent,
for confidence intervals of the coefficients; see help {help level}.

{p 0 4}{cmd:noheader}, {cmd:eform()}, {cmd:depname()} and {cmd:plus}
are for ado-file writers; see {hi:[R] ivreg} and {hi:[R] regress}.

{p 0 4}{cmd:nofooter} suppresses the display of the footer containing
identification and overidentification statistics,
exogeneity and endogeneity tests,
lists of endogenous variables and instruments, etc.

{p 0 4}{cmd:version} causes {cmd:ivreg210} to display its current version number
and to leave it in the macro {cmd:e(version)}.
It cannot be used with any other options.
and will clear any existing {cmd:e()} saved results.

{marker s_macros}{title:Remarks and saved results}

{p}{cmd:ivreg210} does not report an ANOVA table.
Instead, it reports the RSS and both the centered and uncentered TSS.
It also reports both the centered and uncentered R-squared.
NB: the TSS and R-squared reported by official {cmd:ivreg} is centered
if a constant is included in the regression, and uncentered otherwise.

{p}{cmd:ivreg210} saves the following results in {cmd:e()}:

Scalars
{col 4}{cmd:e(N)}{col 18}Number of observations
{col 4}{cmd:e(yy)}{col 18}Total sum of squares (SS), uncentered (y'y)
{col 4}{cmd:e(yyc)}{col 18}Total SS, centered (y'y - ((1'y)^2)/n)
{col 4}{cmd:e(rss)}{col 18}Residual SS
{col 4}{cmd:e(mss)}{col 18}Model SS =yyc-rss if the eqn has a constant, =yy-rss otherwise
{col 4}{cmd:e(df_m)}{col 18}Model degrees of freedom
{col 4}{cmd:e(df_r)}{col 18}Residual degrees of freedom
{col 4}{cmd:e(r2u)}{col 18}Uncentered R-squared, 1-rss/yy
{col 4}{cmd:e(r2c)}{col 18}Centered R-squared, 1-rss/yyc
{col 4}{cmd:e(r2)}{col 18}Centered R-squared if the eqn has a constant, uncentered otherwise
{col 4}{cmd:e(r2_a)}{col 18}Adjusted R-squared
{col 4}{cmd:e(ll)}{col 18}Log likelihood
{col 4}{cmd:e(rankxx)}{col 18}Rank of the matrix of observations on rhs variables=K
{col 4}{cmd:e(rankzz)}{col 18}Rank of the matrix of observations on instruments=L
{col 4}{cmd:e(rankV)}{col 18}Rank of covariance matrix V of coefficients
{col 4}{cmd:e(rankS)}{col 18}Rank of covariance matrix S of orthogonality conditions
{col 4}{cmd:e(rmse)}{col 18}root mean square error=sqrt(rss/(N-K)) if -small-, =sqrt(rss/N) if not
{col 4}{cmd:e(F)}{col 18}F statistic
{col 4}{cmd:e(N_clust)}{col 18}Number of clusters (or min(N_clust1,N_clust2) if 2-way clustering)
{col 4}{cmd:e(N_clust1)}{col 18}Number of clusters in dimension 1 (if 2-way clustering)
{col 4}{cmd:e(N_clust2)}{col 18}Number of clusters in dimension 2 (if 2-way clustering)
{col 4}{cmd:e(bw)}{col 18}Bandwidth
{col 4}{cmd:e(lambda)}{col 18}LIML eigenvalue
{col 4}{cmd:e(kclass)}{col 18}k in k-class estimation
{col 4}{cmd:e(fuller)}{col 18}Fuller parameter alpha
{col 4}{cmd:e(sargan)}{col 18}Sargan statistic
{col 4}{cmd:e(sarganp)}{col 18}p-value of Sargan statistic
{col 4}{cmd:e(sargandf)}{col 18}dof of Sargan statistic = degree of overidentification = L-K
{col 4}{cmd:e(j)}{col 18}Hansen J statistic
{col 4}{cmd:e(jp)}{col 18}p-value of Hansen J statistic
{col 4}{cmd:e(jdf)}{col 18}dof of Hansen J statistic = degree of overidentification = L-K
{col 4}{cmd:e(arubin)}{col 18}Anderson-Rubin overidentification LR statistic N*ln(lambda)
{col 4}{cmd:e(arubinp)}{col 18}p-value of Anderson-Rubin overidentification LR statistic
{col 4}{cmd:e(arubin_lin)}{col 18}Anderson-Rubin linearized overidentification statistic N*(lambda-1)
{col 4}{cmd:e(arubin_linp)}{col 18}p-value of Anderson-Rubin linearized overidentification statistic
{col 4}{cmd:e(arubindf)}{col 18}dof of A-R overid statistic = degree of overidentification = L-K
{col 4}{cmd:e(idstat)}{col 18}LM test statistic for underidentification (Anderson or Kleibergen-Paap)
{col 4}{cmd:e(idp)}{col 18}p-value of underidentification LM statistic
{col 4}{cmd:e(iddf)}{col 18}dof of underidentification LM statistic
{col 4}{cmd:e(widstat)}{col 18}F statistic for weak identification (Cragg-Donald or Kleibergen-Paap)
{col 4}{cmd:e(arf)}{col 18}Anderson-Rubin F-test of significance of endogenous regressors
{col 4}{cmd:e(arfp)}{col 18}p-value of Anderson-Rubin F-test of endogenous regressors
{col 4}{cmd:e(archi2)}{col 18}Anderson-Rubin chi-sq test of significance of endogenous regressors
{col 4}{cmd:e(archi2p)}{col 18}p-value of Anderson-Rubin chi-sq test of endogenous regressors
{col 4}{cmd:e(ardf)}{col 18}degrees of freedom of Anderson-Rubin tests of endogenous regressors
{col 4}{cmd:e(ardf_r)}{col 18}denominator degrees of freedom of AR F-test of endogenous regressors
{col 4}{cmd:e(redstat)}{col 18}LM statistic for instrument redundancy
{col 4}{cmd:e(redp)}{col 18}p-value of LM statistic for instrument redundancy
{col 4}{cmd:e(reddf)}{col 18}dof of LM statistic for instrument redundancy
{col 4}{cmd:e(cstat)}{col 18}C-statistic
{col 4}{cmd:e(cstatp)}{col 18}p-value of C-statistic
{col 4}{cmd:e(cstatdf)}{col 18}Degrees of freedom of C-statistic
{col 4}{cmd:e(cons)}{col 18}1 when equation has a Stata-supplied constant; 0 otherwise
{col 4}{cmd:e(partialcons)}{col 18}as above but prior to partialling-out (see {cmd:e(partial)})
{col 4}{cmd:e(partial_ct)}{col 18}Number of partialled-out variables (see {cmd:e(partial)})

Macros
{col 4}{cmd:e(cmd)}{col 18}ivreg210
{col 4}{cmd:e(cmdline)}{col 18}Command line invoking ivreg210
{col 4}{cmd:e(version)}{col 18}Version number of ivreg210
{col 4}{cmd:e(model)}{col 18}ols, iv, gmm, liml, or kclass
{col 4}{cmd:e(depvar)}{col 18}Name of dependent variable
{col 4}{cmd:e(instd)}{col 18}Instrumented (RHS endogenous) variables
{col 4}{cmd:e(insts)}{col 18}Instruments
{col 4}{cmd:e(inexog)}{col 18}Included instruments (regressors)
{col 4}{cmd:e(exexog)}{col 18}Excluded instruments
{col 4}{cmd:e(collin)}{col 18}Variables dropped because of collinearities
{col 4}{cmd:e(dups)}{col 18}Duplicate variables
{col 4}{cmd:e(ecollin)}{col 18}Endogenous variables reclassified as exogenous because of
{col 20}collinearities with instruments
{col 4}{cmd:e(clist)}{col 18}Instruments tested for orthogonality
{col 4}{cmd:e(redlist)}{col 18}Instruments tested for redundancy
{col 4}{cmd:e(partial)}{col 18}Partialled-out exogenous regressors
{col 4}{cmd:e(small)}{col 18}small
{col 4}{cmd:e(wtype)}{col 18}weight type
{col 4}{cmd:e(wexp)}{col 18}weight expression
{col 4}{cmd:e(clustvar)}{col 18}Name of cluster variable
{col 4}{cmd:e(vcetype)}{col 18}Covariance estimation method
{col 4}{cmd:e(kernel)}{col 18}Kernel
{col 4}{cmd:e(tvar)}{col 18}Time variable
{col 4}{cmd:e(ivar)}{col 18}Panel variable
{col 4}{cmd:e(firsteqs)}{col 18}Names of stored first-stage equations
{col 4}{cmd:e(rfeq)}{col 18}Name of stored reduced-form equation
{col 4}{cmd:e(predict)}{col 18}Program used to implement predict

Matrices
{col 4}{cmd:e(b)}{col 18}Coefficient vector
{col 4}{cmd:e(V)}{col 18}Variance-covariance matrix of the estimators
{col 4}{cmd:e(S)}{col 18}Covariance matrix of orthogonality conditions
{col 4}{cmd:e(W)}{col 18}GMM weighting matrix (=inverse of S if efficient GMM estimator)
{col 4}{cmd:e(first)}{col 18}First-stage regression results
{col 4}{cmd:e(ccev)}{col 18}Eigenvalues corresponding to the Anderson canonical correlations test
{col 4}{cmd:e(cdev)}{col 18}Eigenvalues corresponding to the Cragg-Donald test

Functions
{col 4}{cmd:e(sample)}{col 18}Marks estimation sample



{marker s_examples}{title:Examples}

{p 8 12}{stata "use http://fmwww.bc.edu/ec-p/data/hayashi/griliches76.dta" : . use http://fmwww.bc.edu/ec-p/data/hayashi/griliches76.dta }{p_end}
{p 8 12}(Wages of Very Young Men, Zvi Griliches, J.Pol.Ec. 1976)

{p 8 12}{stata "xi i.year" : . xi i.year}

{col 0}(Instrumental variables.  Examples follow Hayashi 2000, p. 255.)

{p 8 12}{stata "ivreg210 lw s expr tenure rns smsa _I* (iq=med kww age mrt)" : . ivreg210 lw s expr tenure rns smsa _I* (iq=med kww age mrt)}

{p 8 12}{stata "ivreg210 lw s expr tenure rns smsa _I* (iq=med kww age mrt), small ffirst" : . ivreg210 lw s expr tenure rns smsa _I* (iq=med kww age mrt), small ffirst}

{col 0}(Testing for the presence of heteroskedasticity in IV/GMM estimation)

{p 8 12}{stata "ivhettest, fitlev" : . ivhettest, fitlev}

{col 0}(Two-step GMM efficient in the presence of arbitrary heteroskedasticity)

{p 8 12}{stata "ivreg210 lw s expr tenure rns smsa _I* (iq=med kww age mrt), gmm2s robust" : . ivreg210 lw s expr tenure rns smsa _I* (iq=med kww age mrt), gmm2s robust}

{p 0}(GMM with user-specified first-step weighting matrix or matrix of orthogonality conditions)

{p 8 12}{stata "ivreg210 lw s expr tenure rns smsa _I* (iq=med kww age mrt), robust" : . ivreg210 lw s expr tenure rns smsa _I* (iq=med kww age mrt), robust}

{p 8 12}{stata "predict double uhat if e(sample), resid" : . predict double uhat if e(sample), resid}

{p 8 12}{stata "mat accum S =  `e(insts)' [iw=uhat^2]" : . mat accum S = `e(insts)' [iw=uhat^2]}

{p 8 12}{stata "mat S = 1/`e(N)' * S" : . mat S = 1/`e(N)' * S}

{p 8 12}{stata "ivreg210 lw s expr tenure rns smsa _I* (iq=med kww age mrt), gmm2s robust smatrix(S)" : . ivreg210 lw s expr tenure rns smsa _I* (iq=med kww age mrt), gmm2s robust smatrix(S)}

{p 8 12}{stata "mat W = invsym(S)" : . mat W = invsym(S)}

{p 8 12}{stata "ivreg210 lw s expr tenure rns smsa _I* (iq=med kww age mrt), gmm2s robust wmatrix(W)" : . ivreg210 lw s expr tenure rns smsa _I* (iq=med kww age mrt), gmm2s robust wmatrix(W)}

{p 0}(Equivalence of J statistic and Wald tests of included regressors, irrespective of instrument choice (Ahn, 1997))

{p 8 12}{stata "ivreg210 lw (iq=med kww age), gmm2s" : . ivreg210 lw (iq=med kww age), gmm2s}

{p 8 12}{stata "mat S0 = e(S)" : . mat S0 = e(S)}

{p 8 12}{stata "qui ivreg210 lw (iq=kww) med age, gmm2s smatrix(S0)" : . qui ivreg210 lw (iq=kww) med age, gmm2s smatrix(S0)}

{p 8 12}{stata "test med age" : . test med age}

{p 8 12}{stata "qui ivreg210 lw (iq=med) kww age, gmm2s smatrix(S0)" : . qui ivreg210 lw (iq=med) kww age, gmm2s smatrix(S0)}

{p 8 12}{stata "test kww age" : . test kww age}

{p 8 12}{stata "qui ivreg210 lw (iq=age) med kww, gmm2s smatrix(S0)" : . qui ivreg210 lw (iq=age) med kww, gmm2s smatrix(S0)}

{p 8 12}{stata "test med kww" : . test med kww}

{p 0}(Continuously-updated GMM (CUE) efficient in the presence of arbitrary heteroskedasticity.  NB: may require 30+ iterations.)

{p 8 12}{stata "ivreg210 lw s expr tenure rns smsa _I* (iq=med kww age mrt), cue robust" : . ivreg210 lw s expr tenure rns smsa _I* (iq=med kww age mrt), cue robust}

{col 0}(Sargan-Basmann tests of overidentifying restrictions for IV estimation)

{p 8 12}{stata "ivreg210 lw s expr tenure rns smsa _I* (iq=med kww age mrt)" : . ivreg210 lw s expr tenure rns smsa _I* (iq=med kww age mrt)}

{p 8 12}{stata "overid, all" : . overid, all}

{col 0}(Tests of exogeneity and endogeneity)

{col 0}(Test the exogeneity of one regressor)

{p 8 12}{stata "ivreg210 lw s expr tenure rns smsa _I* (iq=med kww age mrt), gmm2s orthog(s)" : . ivreg210 lw s expr tenure rns smsa _I* (iq=med kww age mrt), gmm2s orthog(s)}

{col 0}(Test the exogeneity of two excluded instruments)

{p 8 12}{stata "ivreg210 lw s expr tenure rns smsa _I* (iq=med kww age mrt), gmm2s orthog(age mrt)" : . ivreg210 lw s expr tenure rns smsa _I* (iq=med kww age mrt), gmm2s orthog(age mrt)}

{col 0}(Frisch-Waugh-Lovell (FWL): equivalence of estimations with and without partialling-out)

{p 8 12}{stata "ivreg210 lw s expr tenure rns _I* (iq=kww age), cluster(year)" : . ivreg210 lw s expr tenure rns smsa _I* (iq=med kww age), cluster(year)}

{p 8 12}{stata "ivreg210 lw s expr tenure rns _I* (iq=kww age), cluster(year) partial(_I*)" : . ivreg210 lw s expr tenure rns smsa _I* (iq=med kww age), cluster(year) partial(_I*)}

{col 0}({cmd:partial()}: efficient GMM with #clusters<#instruments feasible after partialling-out)

{p 8 12}{stata "ivreg210 lw s expr tenure rns _I* (iq=kww age), cluster(year) partial(_I*) gmm2s" : . ivreg210 lw s expr tenure rns smsa (iq=med kww age), cluster(year) partial(_I*) gmm2s}

{col 0}(Examples following Wooldridge 2002, pp.59, 61)

{p 8 12}{stata "use http://fmwww.bc.edu/ec-p/data/wooldridge/mroz.dta" : . use http://fmwww.bc.edu/ec-p/data/wooldridge/mroz.dta }

{col 0}(Equivalence of DWH endogeneity test when regressor is endogenous...)

{p 8 12}{stata "ivreg210 lwage exper expersq (educ=age kidslt6 kidsge6)" : . ivreg210 lwage exper expersq (educ=age kidslt6 kidsge6)}

{p 8 12}{stata "ivendog educ" :. ivendog educ}

{col 0}(... endogeneity test using the {cmd:endog} option)

{p 8 12}{stata "ivreg210 lwage exper expersq (educ=age kidslt6 kidsge6), endog(educ)" : . ivreg210 lwage exper expersq (educ=age kidslt6 kidsge6), endog(educ)}

{col 0}(...and C-test of exogeneity when regressor is exogenous, using the {cmd:orthog} option)

{p 8 12}{stata "ivreg210 lwage exper expersq educ (=age kidslt6 kidsge6), orthog(educ)" : . ivreg210 lwage exper expersq educ (=age kidslt6 kidsge6), orthog(educ)}

{col 0}(Heteroskedastic Ordinary Least Squares, HOLS)

{p 8 12}{stata "ivreg210 lwage exper expersq educ (=age kidslt6 kidsge6), gmm2s" : . ivreg210 lwage exper expersq educ (=age kidslt6 kidsge6), gmm2s}

{col 0}(Equivalence of Cragg-Donald Wald F statistic and F-test from first-stage regression
{col 0}in special case of single endogenous regressor.  Also illustrates {cmd:savefirst} option.)

{p 8 12}{stata "ivreg210 lwage exper expersq (educ=age kidslt6 kidsge6), savefirst" : . ivreg210 lwage exper expersq (educ=age kidslt6 kidsge6), savefirst}

{p 8 12}{stata "di e(widstat)" : . di e(widstat)}

{p 8 12}{stata "estimates restore _ivreg2_educ" : . estimates restore _ivreg2_educ}

{p 8 12}{stata "test age kidslt6 kidsge6" : . test age kidslt6 kidsge6}

{p 8 12}{stata "di r(F)" : . di r(F)}

{col 0}(Equivalence of Kleibergen-Paap robust rk Wald F statistic and F-test from first-stage
{col 0}regression in special case of single endogenous regressor.)

{p 8 12}{stata "ivreg210 lwage exper expersq (educ=age kidslt6 kidsge6), robust savefirst" : . ivreg210 lwage exper expersq (educ=age kidslt6 kidsge6), robust savefirst}

{p 8 12}{stata "di e(widstat)" : . di e(widstat)}

{p 8 12}{stata "estimates restore _ivreg2_educ" : . estimates restore _ivreg2_educ}

{p 8 12}{stata "test age kidslt6 kidsge6" : . test age kidslt6 kidsge6}

{p 8 12}{stata "di r(F)" : . di r(F)}

{col 0}(Equivalence of Kleibergen-Paap robust rk LM statistic for identification and LM test
{col 0}of joint significance of excluded instruments in first-stage regression in special
{col 0}case of single endogenous regressor.  Also illustrates use of {cmd:ivreg210} to perform an
{col 0}LM test in OLS estimation.)

{p 8 12}{stata "ivreg210 lwage exper expersq (educ=age kidslt6 kidsge6), robust" : . ivreg210 lwage exper expersq (educ=age kidslt6 kidsge6), robust}

{p 8 12}{stata "di e(idstat)" : . di e(idstat)}

{p 8 12}{stata "ivreg210 educ exper expersq (=age kidslt6 kidsge6) if e(sample), robust" : . ivreg210 educ exper expersq (=age kidslt6 kidsge6) if e(sample), robust}

{p 8 12}{stata "di e(j)" : . di e(j)}

{col 0}(Equivalence of an LM test of an excluded instrument for redundancy and an LM test of
{col 0}significance from first-stage regression in special case of single endogenous regressor.)

{p 8 12}{stata "ivreg210 lwage exper expersq (educ=age kidslt6 kidsge6), robust redundant(age)" : . ivreg210 lwage exper expersq (educ=age kidslt6 kidsge6), robust redundant(age)}

{p 8 12}{stata "di e(redstat)" : . di e(redstat)}

{p 8 12}{stata "ivreg210 educ exper expersq kidslt6 kidsge6 (=age) if e(sample), robust" : . ivreg210 educ exper expersq kidslt6 kidsge6 (=age) if e(sample), robust}

{p 8 12}{stata "di e(j)" : . di e(j)}

{col 0}(Weak-instrument robust inference: Anderson-Rubin Wald F and chi-sq and
{col 0}Stock-Wright S statistics.  Also illusrates use of {cmd:saverf} option.)

{p 8 12}{stata "ivreg210 lwage exper expersq (educ=age kidslt6 kidsge6), robust ffirst saverf" : . ivreg210 lwage exper expersq (educ=age kidslt6 kidsge6), robust ffirst saverf}

{p 8 12}{stata "di e(arf)" : . di e(arf)}

{p 8 12}{stata "di e(archi2)" : . di e(archi2)}

{p 8 12}{stata "di e(sstat)" : . di e(sstat)}

{col 0}(Obtaining the Anderson-Rubin Wald F statistic from the reduced-form estimation)

{p 8 12}{stata "estimates restore _ivreg2_lwage" : . estimates restore _ivreg2_lwage}

{p 8 12}{stata "test age kidslt6 kidsge6" : . test age kidslt6 kidsge6}

{p 8 12}{stata "di r(F)" : . di r(F)}

{col 0}(Obtaining the Anderson-Rubin Wald chi-sq statistic from the reduced-form estimation.
{col 0}Use {cmd:ivreg210} without {cmd:small} to obtain large-sample test statistic.)

{p 8 12}{stata "ivreg210 lwage exper expersq age kidslt6 kidsge6, robust" : . ivreg210 lwage exper expersq age kidslt6 kidsge6, robust}

{p 8 12}{stata "test age kidslt6 kidsge6" : . test age kidslt6 kidsge6}

{p 8 12}{stata "di r(chi2)" : . di r(chi2)}

{col 0}(Obtaining the Stock-Wright S statistic as the value of the GMM CUE objective function.
{col 0}Also illustrates use of {cmd:b0} option.  Coefficients on included exogenous regressors
{col 0}are OLS coefficients, which is equivalent to partialling them out before obtaining
{col 0}the value of the CUE objective function.)

{p 8 12}{stata "mat b = 0" : . mat b = 0}

{p 8 12}{stata "mat colnames b = educ" : . mat colnames b = educ}

{p 8 12}{stata "qui ivreg210 lwage exper expersq" : . qui ivreg210 lwage exper expersq}

{p 8 12}{stata "mat b = b, e(b)" : . mat b = b, e(b)}

{p 8 12}{stata "ivreg210 lwage exper expersq (educ=age kidslt6 kidsge6), robust b0(b)" : . ivreg210 lwage exper expersq (educ=age kidslt6 kidsge6), robust b0(b)}

{p 8 12}{stata "di e(j)" : . di e(j)}

{col 0}(LIML and k-class estimation using Klein data)

{col 9}{stata "webuse klein" :. webuse klein}
{col 9}{stata "tsset yr" :. tsset yr}

{col 0}(LIML estimates of Klein's consumption function)

{p 8 12}{stata "ivreg210 consump L.profits (profits wagetot = govt taxnetx year wagegovt capital1 L.totinc), liml" :. ivreg210 consump L.profits (profits wagetot = govt taxnetx year wagegovt capital1 L.totinc), liml}

{col 0}(Equivalence of LIML and CUE+homoskedasticity+independence)

{p 8 12}{stata "ivreg210 consump L.profits (profits wagetot = govt taxnetx year wagegovt capital1 L.totinc), liml coviv" :. ivreg210 consump L.profits (profits wagetot = govt taxnetx year wagegovt capital1 L.totinc), liml coviv}

{p 8 12}{stata "ivreg210 consump L.profits (profits wagetot = govt taxnetx year wagegovt capital1 L.totinc), cue" :. ivreg210 consump L.profits (profits wagetot = govt taxnetx year wagegovt capital1 L.totinc), cue}

{col 0}(Fuller's modified LIML with alpha=1)

{p 8 12}{stata "ivreg210 consump L.profits (profits wagetot = govt taxnetx year wagegovt capital1 L.totinc), fuller(1)" :. ivreg210 consump L.profits (profits wagetot = govt taxnetx year wagegovt capital1 L.totinc), fuller(1)}

{col 0}(k-class estimation with Nagar's bias-adjusted IV, k=1+(L-K)/N=1+4/21=1.19)

{p 8 12}{stata "ivreg210 consump L.profits (profits wagetot = govt taxnetx year wagegovt capital1 L.totinc), kclass(1.19)" :. ivreg210 consump L.profits (profits wagetot = govt taxnetx year wagegovt capital1 L.totinc), kclass(1.19)}

{col 0}(Kernel-based covariance estimation using time-series data)

{col 9}{stata "use http://fmwww.bc.edu/ec-p/data/wooldridge/phillips.dta" :. use http://fmwww.bc.edu/ec-p/data/wooldridge/phillips.dta}
{col 9}{stata "tsset year, yearly" :. tsset year, yearly}

{col 0}(Autocorrelation-consistent (AC) inference in an OLS Regression)

{p 8 12}{stata "ivreg210 cinf unem, bw(3)" :. ivreg210 cinf unem, bw(3)}

{p 8 12}{stata "ivreg210 cinf unem, kernel(qs) bw(auto)" :. ivreg210 cinf unem, kernel(qs) bw(auto)}

{col 0}(Heteroskedastic and autocorrelation-consistent (HAC) inference in an OLS regression)

{p 8 12}{stata "ivreg210 cinf unem, bw(3) kernel(bartlett) robust small" :. ivreg210 cinf unem, bw(3) kernel(bartlett) robust small}

{p 8 12}{stata "newey cinf unem, lag(2)" :. newey cinf unem, lag(2)}

{col 0}(AC and HAC in IV and GMM estimation)

{p 8 12}{stata "ivreg210 cinf (unem = l(1/3).unem), bw(3)" :. ivreg210 cinf (unem = l(1/3).unem), bw(3)}

{p 8 12}{stata "ivreg210 cinf (unem = l(1/3).unem), bw(3) gmm2s kernel(thann)" :. ivreg210 cinf (unem = l(1/3).unem), bw(3) gmm2s kernel(thann)}

{p 8 12}{stata "ivreg210 cinf (unem = l(1/3).unem), bw(3) gmm2s kernel(qs) robust orthog(l1.unem)" :. ivreg210 cinf (unem = l(1/3).unem), bw(3) gmm2s kernel(qs) robust orthog(l1.unem)}

{col 0}(Examples using Large N, Small T Panel Data)

{p 8 12}{stata "use http://fmwww.bc.edu/ec-p/data/macro/abdata.dta" : . use http://fmwww.bc.edu/ec-p/data/macro/abdata.dta }{p_end}
{p 8 12}{stata "tsset id year" :. tsset id year}

{col 0}(Two-step effic. GMM in the presence of arbitrary heteroskedasticity and autocorrelation)

{p 8 12}{stata "ivreg210 n (w k ys = d.w d.k d.ys d2.w d2.k d2.ys), gmm2s cluster(id)": . ivreg210 n (w k ys = d.w d.k d.ys d2.w d2.k d2.ys), gmm2s cluster(id)}

{col 0}(Kiefer (1980) SEs - robust to arbitrary serial correlation but not heteroskedasticity)

{p 8 12}{stata "ivreg210 n w k, kiefer": . ivreg210 n w k, kiefer}

{p 8 12}{stata "ivreg210 n w k, bw(9) kernel(tru)": . ivreg210 n w k, bw(9) kernel(tru)}

{col 0}(Equivalence of cluster-robust and kernel-robust with truncated kernel and max bandwidth)

{p 8 12}{stata "ivreg210 n w k, cluster(id)": . ivreg210 n w k, cluster(id)}

{p 8 12}{stata "ivreg210 n w k, bw(9) kernel(tru) robust)": . ivreg210 n w k, bw(9) kernel(tru) robust}

{col 0}(Examples using Small N, Large T Panel Data.  NB: T is actually not very large - only
{col 0}20 - so results should be interpreted with caution)

{p 8 12}{stata "webuse grunfeld" : . webuse grunfeld }{p_end}
{p 8 12}{stata "tsset" : . tsset }{p_end}

{col 0}(Autocorrelation-consistent (AC) inference)

{p 8 12}{stata "ivreg210 invest mvalue kstock, bw(1) kernel(tru)": . ivreg210 invest mvalue kstock, bw(1) kernel(tru)}

{col 0}(Heteroskedastic and autocorrelation-consistent (HAC) inference)

{p 8 12}{stata "ivreg210 invest mvalue kstock, robust bw(1) kernel(tru)": . ivreg210 invest mvalue kstock, robust bw(1) kernel(tru)}

{col 0}(HAC inference, SEs also robust to disturbances correlated across panels)

{p 8 12}{stata "ivreg210 invest mvalue kstock, robust cluster(year) bw(1) kernel(tru)": . ivreg210 invest mvalue kstock, robust cluster(year) bw(1) kernel(tru)}

{col 0}(Equivalence of Driscoll-Kraay SEs as implemented by {cmd:ivreg210} and {cmd:xtscc})
{col 0}(See Hoeschle (2007) for discussion of {cmd:xtscc})

{p 8 12}{stata "ivreg210 invest mvalue kstock, dkraay(2) small": . ivreg210 invest mvalue kstock, dkraay(2) small}

{p 8 12}{stata "ivreg210 invest mvalue kstock, cluster(year) bw(2) small": . ivreg210 invest mvalue kstock, cluster(year) bw(2) small}

{p 8 12}{stata "xtscc invest mvalue kstock, lag(1)": . xtscc invest mvalue kstock, lag(1)}

{col 0}(Examples using Large N, Large T Panel Data.  NB: T is again not very large - only
{col 0}20 - so results should be interpreted with caution)

{p 8 12}{stata "webuse nlswork" : . webuse nlswork }{p_end}
{p 8 12}{stata "tsset" : . tsset }{p_end}

{col 0}(One-way cluster-robust: SEs robust to arbitrary heteroskedasticity and within-panel
{col 0}autocorrelation)

{p 8 12}{stata "ivreg210 ln_w grade age ttl_exp tenure, cluster(idcode)": . ivreg210 ln_w grade age ttl_exp tenure, cluster(idcode) }{p_end}

{col 0}(Two-way cluster-robust: SEs robust to arbitrary heteroskedasticity and within-panel
{col 0}autocorrelation, and contemporaneous cross-panel correlation, i.e., the cross-panel
{col 0}correlation is not autocorrelated)

{p 8 12}{stata "ivreg210 ln_w grade age ttl_exp tenure, cluster(idcode year)": . ivreg210 ln_w grade age ttl_exp tenure, cluster(idcode year) }{p_end}

{col 0}(Two-way cluster-robust: SEs robust to arbitrary heteroskedasticity and within-panel
{col 0}autocorrelation and cross-panel autocorrelated disturbances that disappear after 2 lags)

{p 8 12}{stata "ivreg210 ln_w grade age ttl_exp tenure, cluster(idcode year) bw(2) kernel(tru) ": . ivreg210 ln_w grade age ttl_exp tenure, cluster(idcode year) bw(2) kernel(tru) }{p_end}



{marker s_refs}{title:References}

{p 0 4}Ahn, Seung C. 1997. Orthogonality tests in linear models. Oxford Bulletin
of Economics and Statistics, Vol. 59, pp. 183-186.

{p 0 4}Anderson, T.W. 1951. Estimating linear restrictions on regression coefficients
for multivariate normal distributions. Annals of Mathematical Statistics, Vol. 22, pp. 327-51.

{p 0 4}Anderson, T. W. and H. Rubin. 1949. Estimation of the parameters of a single equation 
in a complete system of stochastic equations. Annals of Mathematical Statistics, Vol. 20, 
pp. 46-63. 

{p 0 4}Anderson, T. W. and H. Rubin. 1950. The asymptotic properties of estimates of the parameters of a single 
equation in a complete system of stochastic equations. Annals of Mathematical Statistics,
Vol. 21, pp. 570-82. 

{p 0 4}Angrist, J.D. and Pischke, J.-S. 2009. Mostly Harmless Econometrics: An Empiricist's Companion.
Princeton: Princeton University Press.

{p 0 4}Baum, C.F., Schaffer, M.E., and Stillman, S. 2003. Instrumental Variables and GMM:
Estimation and Testing. The Stata Journal, Vol. 3, No. 1, pp. 1-31.
{browse "http://ideas.repec.org/a/tsj/stataj/v3y2003i1p1-31.html":http://ideas.repec.org/a/tsj/stataj/v3y2003i1p1-31.html}.
Working paper version: Boston College Department of Economics Working Paper No. 545.
{browse "http://ideas.repec.org/p/boc/bocoec/545.html":http://ideas.repec.org/p/boc/bocoec/545.html}. 
Citations in {browse "http://scholar.google.com/scholar?oi=bibs&hl=en&cites=9432785573549481148":published work}.

{p 0 4}Baum, C. F., Schaffer, M.E., and Stillman, S. 2007. Enhanced routines for instrumental variables/GMM estimation and testing.
The Stata Journal, Vol. 7, No. 4, pp. 465-506.
{browse "http://ideas.repec.org/a/tsj/stataj/v7y2007i4p465-506.html":http://ideas.repec.org/a/tsj/stataj/v7y2007i4p465-506.html}.
Working paper version: Boston College Department of Economics Working Paper No. 667. 
{browse "http://ideas.repec.org/p/boc/bocoec/667.html":http://ideas.repec.org/p/boc/bocoec/667.html}.
Citations in {browse "http://scholar.google.com/scholar?oi=bibs&hl=en&cites=1691909976816211536":published work}.

{p 0 4}Breusch, T., Qian, H., Schmidt, P. and Wyhowski, D. 1999.
Redundancy of moment conditions.
Journal of Econometrics, Vol. 9, pp. 89-111.

{p 0 4}Cameron, A.C., Gelbach, J.B. and Miller, D.L. 2006.
Robust Inference with Multi-Way Clustering.
NBER Technical Working paper 327.
{browse "http://www.nber.org/papers/t0327":http://www.nber.org/papers/t0327}.
Forthcoming in the Journal of Business and Economic Statistics.
{cmd:cgmreg} is available at
{browse "http://www.econ.ucdavis.edu/faculty/dlmiller/statafiles":http://www.econ.ucdavis.edu/faculty/dlmiller/statafiles}.

{p 0 4}Chernozhukov, V. and Hansen, C. 2005. The Reduced Form:
A Simple Approach to Inference with Weak Instruments.
Working paper, University of Chicago, Graduate School of Business.

{p 0 4}Cragg, J.G. and Donald, S.G. 1993. Testing Identfiability and Specification in
Instrumental Variables Models. Econometric Theory, Vol. 9, pp. 222-240.

{p 0 4}Cushing, M.J. and McGarvey, M.G. 1999. Covariance Matrix Estimation.
In L. Matyas (ed.), Generalized Methods of Moments Estimation.
Cambridge: Cambridge University Press.

{p 0 4}Davidson, R. and MacKinnon, J. 1993. Estimation and Inference in Econometrics.
1993. New York: Oxford University Press.

{p 0 4}Driscoll, J.C. and Kraay, A. 1998. Consistent Covariance Matrix Estimation With Spatially Dependent Panel Data.
Review of Economics and Statistics. Vol. 80, No. 4, pp. 549-560.

{p 0 4}Dufour, J.M.  2003.  Identification, Weak Instruments and Statistical Inference
in Econometrics. Canadian Journal of Economics, Vol. 36, No. 4, pp. 767-808.
Working paper version: CIRANO Working Paper 2003s-49.
{browse "http://www.cirano.qc.ca/pdf/publication/2003s-49.pdf":http://www.cirano.qc.ca/pdf/publication/2003s-49.pdf}.

{p 0 4}Finlay, K., and Magnusson, L.M.  2009.  Implementing Weak-Instrument Robust Tests
for a General Class of Instrumental-Variables Models.
The Stata Journal, Vol. 9, No. 3, pp. 398-421.
{browse "http://www.stata-journal.com/article.html?article=st0171":http://www.stata-journal.com/article.html?article=st0171}.

{p 0 4}Hall, A.R., Rudebusch, G.D. and Wilcox, D.W.  1996.  Judging Instrument Relevance in
Instrumental Variables Estimation.  International Economic Review, Vol. 37, No. 2, pp. 283-298.

{p 0 4}Hayashi, F. Econometrics. 2000. Princeton: Princeton University Press.

{p 0 4}Hansen, L.P., Heaton, J., and Yaron, A.  1996.  Finite Sample Properties
of Some Alternative GMM Estimators.  Journal of Business and Economic Statistics, Vol. 14, No. 3, pp. 262-280.

{p 0 4}Hoechle, D.  2007.  Robust Standard Errors for Panel Regressions with Crossñsectional Dependence.
Stata Journal, Vol. 7, No. 3, pp. 281-312.
{browse "http://www.stata-journal.com/article.html?article=st0128":http://www.stata-journal.com/article.html?article=st0128}.

{p 0 4}Kiefer, N.M.  1980.  Estimation of Fixed Effect Models for Time Series of Cross-Sections with
Arbitrary Intertemporal Covariance.  Journal of Econometrics, Vol. 14, No. 2, pp. 195-202.

{p 0 4}Kleibergen, F.  2007.  Generalizing Weak Instrument Robust Statistics Towards Multiple Parameters, Unrestricted Covariance Matrices and Identification Statistics. Journal of Econometrics, forthcoming.

{p 0 4}Kleibergen, F. and Paap, R.  2006.  Generalized Reduced Rank Tests Using the Singular Value Decomposition.
Journal of Econometrics, Vol. 133, pp. 97-126.

{p 0 4}Kleibergen, F. and Schaffer, M.E.  2007. ranktest: Stata module for testing the rank
of a matrix using the Kleibergen-Paap rk statistic.
{browse "http://ideas.repec.org/c/boc/bocode/s456865.html":http://ideas.repec.org/c/boc/bocode/s456865.html}.

{p 0 4}Mikusheva, A. and Poi, B.P.  2006.
Tests and Confidence Sets with Correct Size When Instruments are Potentially Weak. The Stata Journal, Vol. 6,  No. 3, pp. 335-347.

{p 0 4}Moreira, M.J. and Poi, B.P.  2003.  Implementing Tests with the Correct Size in the Simultaneous Equations Model.  The Stata Journal, Vol. 3, No. 1, pp. 57-70.

{p 0 4}Newey, W.K. and K.D. West, 1994. Automatic Lag Selection in Covariance Matrix Estimation. Review of Economic Studies, Vol. 61, No. 4, pp. 631-653.

{p 0 4}Shea, J. 1997.  Instrument Relevance in Multivariate Linear Models:
A Simple Measure.
Review of Economics and Statistics, Vol. 49, No. 2, pp. 348-352.

{p 0 4}Stock, J.H. and Wright, J.H.  2000.  GMM with Weak Identification.
Econometrica, Vol. 68, No. 5, September, pp. 1055-1096.

{p 0 4}Stock, J.H. and Yogo, M.  2005.  Testing for Weak Instruments in Linear IV Regression. In D.W.K. Andrews and J.H. Stock, eds. Identification and Inference for Econometric Models: Essays in Honor of Thomas Rothenberg. Cambridge: Cambridge University Press, 2005, pp. 80Ò108.
Working paper version: NBER Technical Working Paper 284.
{browse "http://www.nber.org/papers/T0284":http://www.nber.org/papers/T0284}.

{p 0 4}Thompson, S.B.  2009.  Simple Formulas for Standard Errors that Cluster by Both Firm and Time.
{browse "http://ssrn.com/abstract=914002":http://ssrn.com/abstract=914002}.

{p 0 4}Wooldridge, J.M. 2002. Econometric Analysis of Cross Section and Panel Data. Cambridge, MA: MIT Press.


{marker s_acknow}{title:Acknowledgements}

{p}We would like to thanks various colleagues who helped us along the way, including
David Drukker,
Frank Kleibergen,
Austin Nichols,
Brian Poi,
Vince Wiggins,
and, not least, the users of {cmd:ivreg2}
who have provided suggestions,
spotted bugs,
and helped test the package.
We are also grateful to Jim Stock and Moto Yogo for permission to reproduce
their critical values for the Cragg-Donald statistic.

{marker s_citation}{title:Citation of ivreg210}

{p}{cmd:ivreg210} is not an official Stata command. It is a free contribution
to the research community, like a paper. Please cite it as such: {p_end}

{phang}Baum, C.F., Schaffer, M.E., Stillman, S. 2015.
ivreg210: Stata module for extended instrumental variables/2SLS, GMM and AC/HAC, LIML and k-class regression.
{browse "http://ideas.repec.org/c/boc/bocode/sS457955.html":http://ideas.repec.org/c/boc/bocode/sS457955.html}{p_end}

{title:Authors}

	Christopher F Baum, Boston College, USA
	baum@bc.edu

	Mark E Schaffer, Heriot-Watt University, UK
	m.e.schaffer@hw.ac.uk

	Steven Stillman, Motu Economic and Public Policy Research
	stillman@motu.org.nz


{title:Also see}

{p 1 14}Articles:{it:Stata Journal}, volume 3, number 1: {browse "http://ideas.repec.org/a/tsj/stataj/v3y2003i1p1-31.html":st0030}{p_end}
{p 10 14}{it:Stata Journal}, volume 7, number 4: {browse "http://ideas.repec.org/a/tsj/stataj/v7y2007i4p465-506.html":st0030_3}{p_end}

{p 1 14}Manual:  {hi:[U] 23 Estimation and post-estimation commands}{p_end}
{p 10 14}{hi:[U] 29 Overview of model estimation in Stata}{p_end}
{p 10 14}{hi:[R] ivreg}{p_end}

{p 1 10}On-line: help for {help ivregress}, {help ivreg}, {help newey};
{help overid}, {help ivendog}, {help ivhettest}, {help ivreset},
{help xtivreg2}, {help xtoverid}, {help ranktest},
{help condivreg} (if installed);
{help rivtest} (if installed);
{help cgmreg} (if installed);
{help xtscc} (if installed);
{help est}, {help postest};
{help regress}{p_end}
