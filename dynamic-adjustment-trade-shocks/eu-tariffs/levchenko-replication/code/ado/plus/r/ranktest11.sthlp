{smcl}
{* 9dec2018}{...}
{hline}
help for {hi:ranktest11}
{hline}

{title:ranktest11: module for testing the rank of a matrix using the Kleibergen-Paap rk statistic}

{p 4}Full syntax

{p 8 14}{cmd:ranktest11}
{cmd:(}{it:varlist1}{cmd:)}
{cmd:(}{it:varlist2}{cmd:)}
[{it:weight}]
[{cmd:if} {it:exp}] [{cmd:in} {it:range}]
{bind:[{cmd:, {cmd:partial(}{it:varlist3}{cmd:)}}}
{cmd:wald}
{cmdab:all:rank}
{cmdab:full:rank}
{cmdab:null:rank}
{cmdab:r:obust}
{cmd:bw(}{it:#}{cmd:)}
{cmd:kernel(}{it:string}{cmd:)}
{cmdab:cl:uster}{cmd:(}{it:varlist}{cmd:)}
{bind:{cmdab:noc:onstant} ]}

{p 4}Version syntax

{p 8 14}{cmd:ranktest11}, {cmd:version}

{p}{cmd:ranktest11} is a version of {cmd:ranktest} that works with Stata 11 or earlier.
The current version of {cmd:ranktest} has more features and reports a wider range of tests;
to install it, type or click on {stata "ssc install ranktest"}.

{p}{cmd:ranktest11} may be used with time-series or panel data,
in which case the data must be {cmd:tsset}
before using {cmd:ranktest11}; see help {help tsset}.

{p}All {it:varlists} may contain time-series operators;
see help {help varlist}.
If {cmd:(}{it:varlist1}{cmd:)} or {cmd:(}{it:varlist1}{cmd:)} contain a single variable,
the parentheses {cmd:()} may be omitted.

{p}{cmd:aweight}s, {cmd:fweight}s, {cmd:iweight}s and {cmd:pweight}s
are allowed; see help {help weights}.

{p}{cmd:ranktest11} is an r-class program.

{title:Contents}
{p 2}{help ranktest11##s_description:Description}{p_end}
{p 2}{help ranktest11##s_examples:Options}{p_end}
{p 2}{help ranktest11##s_examples:Examples}{p_end}
{p 2}{help ranktest11##s_refs:References}{p_end}
{p 2}{help ranktest11##s_acknow:Acknowledgements}{p_end}
{p 2}{help ranktest11##s_citation:Authors}{p_end}
{p 2}{help ranktest11##s_citation:Citation of ranktest11}{p_end}

{marker s_description}{title:Description}

{p}{cmd:ranktest11} implements the Kleibergen-Paap (2006)
rk test for the rank of a matrix.
Tests of the rank of a matrix have many practical applications.
For example, in econometrics the requirement for identification
is the rank condition,
which states that a particular matrix must be of full column rank.
Another example from econometrics concerns
cointegration in vector autoregressive (VAR) models;
the Johansen trace test is a test of a rank of a particular matrix.
The traditional test of the rank of a matrix for the standard (stationary) case
is the Anderson (1951) canonical correlations test.
If we denote one list of variables as Y and a second as Z,
and we calculate the squared canonical correlations between Y and Z,
the LM form of the Anderson test,
where the null hypothesis is that
the matrix of correlations or regression parameters B between Y and Z has rank(B)=r,
is N times the sum of the r+1 largest squared canonical correlations.
A large test statistic and
rejection of the null indicates that the matrix has rank at least r+1.
The Cragg-Donald (1993) statistic is a closely related Wald test
for the rank of a matrix.
Both the Anderson and Cragg-Donald tests require the assumption
that the covariance matrix has a Kronecker form;
when this is not so,
e.g., when disturbances are heteroskedastic or autocorrelated,
the test statistics are no longer valid.

{p}The Kleibergen-Paap (2006) rk statistic is a generalization
of the Anderson canonical correlation rank test
to the case of a non-Kronecker covariance matrix.
The implementation in {cmd:ranktest11}
will calculate rk statistics that are robust to various forms of
heteroskedasticity, autocorrelation, and clustering.
For a full discussion of the test statistic
and its relationship other test statistics for the rank of a matrix,
see Kleibergen-Paap (2006).

{p}The text is applied to Y and Z,
where Y={it:varlist1} and Z={it:varlist2}.
Optionally, a third set of variables X={it:varlist3}
can be partialled-out of Y and Z
with the {cmd:partial()} option.
A constant is automatically partialled out,
unless the user specifies the {cmd:nocons} option.
To test if a matrix is rank r+1,
the null hypothesis is Ho: rank(B)=r.
Rejection of the null indicates that the matrix
has at least rank=r+1.
In the standard (stationary) case,
the test statistic is distributed as chi-squared
with degrees of freedom = (K-r)*(L-r),
where K is the number of Y variables,
L is the number of Z variables,
and r is the rank being tested in Ho.
For example,
to test if the matrix is full column rank K where K<L,
the null would be Ho:rank(B)=K-1
and the degrees of freedom of the test
would be (K-r)*(L-r) = (K-(K-1))*(L-(K-1) = (L-K+1).
The default behavior of {cmd:ranktest11} is to perform all possible tests of rank;
the {cmdab:full:rank} option causes only the test of whether the matrix is full rank
(Ho:r=K-1) to be reported;
the {cmdab:null:rank} option causes only the test of whether the matrix is zero rank
(Ho:r=0) to be reported.

{p}The default behavior of {cmd:ranktest11} is to report LM tests;
the {cmd:wald} option will cause it to report Wald tests.
P-values are for the standard (stationary) case using the chi-squared distribution.
Specifying {cmd:robust}, {cmd:bw(#)} (where # is the bandwidth), or {cmd:cluster(varname)}
will generate an rk statistic that is robust to
heteroskedasticity, autocorrelation or within-group clustering;
{cmd:robust} combined with {cmd:bw(#)} will generate a
heteroskedasticity and autocorrelation-consistent (HAC) statistic.
The implementation of an autocorrelation-consistent statistic
and the options available for various kernels
follow that in {help ivreg2};
for more details, see Baum et al. (2007) or {help help ivreg2} if installed.
If none of the above options is specified,
{cmd:ranktest11} defaults to reporting the Anderson canonical correlations LM test,
or, if {cmd:wald} is specified, the Cragg-Donald (1993) Wald test.

{p}It is useful to note that in the special case of
a test for whether a matrix has rank=zero
(e.g., if there is a single variable Y),
the Anderson, Cragg-Donald, and Kleibergen-Paap statistics
reduce to familiar statistics available from OLS estimation.
Thus if K=1, the Cragg-Donald Wald statistic can be calculated
by regressing the single Y on Z and X and testing the joint significance of Z
using a standard Wald test
and a traditional non-robust covariance estimator.
The Anderson LM statistic can be obtained by calculating an LM test
of the same joint hypothesis.
The robust Kleibergen-Paap rk statistics can be obtained
by performing the same tests with the desired robust covariance estimator.
Similarly, if K>1 the test statistics for rank=0 reported by {cmd:ranktest11}
can be reproduced by testing the joint significance of the Z variables
across the K equations for the Y variables.
See the examples below.

{marker s_options}{title:Options summary}

{p 0 4}{cmd:partial(}{it:varlist3}{cmd:)}
requests that the variables in {cmd:(}{it:varlist3}{cmd:)}
are partialled out of the variables in
{cmd:(}{it:varlist1}{cmd:)} and {cmd:(}{it:varlist2}{cmd:)}.
A constant is automatically partialled out as well,
unless the option {cmd:noconstant} is specified. 

{p 0 4}{cmd:wald} requests the Wald instead of the LM version of the test.
The LM version is the default.

{p 0 4}{cmdab:all:rank} requests that test statistics
for rank=0, rank=1, ..., rank=(#cols-1) be reported,
where (#cols-1) is the number of columns
of the smaller of the two matrices (varlists).
{cmdab:all:rank} is the default.

{p 0 4}{cmdab:full:rank} requests that only the test statistic
for Ho: rank=(#cols-1) be reported,
where (#cols-1) is the number of columns
of the smaller of the two matrices (varlists).
Rejection of the null indicates that the matrix
is of full column rank.

{p 0 4}{cmdab:null:rank} requests that only the test statistic
for Ho: rank=0 be reported.
Rejection of the null indicates that the matrix has at least rank=1.

{p 0 4}{cmd:robust} specifies that the Eicker/Huber/White/sandwich
heteroskedastic-robust estimator of variance is to be used.
The reported rk statistic will be robust to heteroskedasticity.

{p 0 4}{cmd:cluster}{cmd:(}{it:varlist}{cmd:)} specifies that
observations are independent across groups (clusters)
but not necessarily independent within groups.
{it:varname} specifies to which group each observation belongs.
Specifying {cmd:cluster()} implies {cmd:robust},
i.e., the reported rk statistic will be robust to both
heteroskedasticity and within-cluster correlation.
If {cmd:ivreg2} version 3.0 or later is installed, 2-way clustering is supported;
see help {help ivreg2} for details.

{p 0 4}{cmd:bw(}{it:#}{cmd:)} impements
autocorrelation-consistent (AC)
or heteroskedasticity- and autocorrelation-consistent (HAC)
covariance estimation with bandwidth equal to {it:#},
where {it:#} is an integer greater than zero.
Specifying {cmd:robust} together with {cmd:bw(}{it:#}{cmd:)}
implements HAC covariance estimation;
omitting {cmd:robust} implements AC covariance estimation.

{p 0 4}{cmd:kernel(}{it:string)}{cmd:)} specifies the kernel
to be used for AC and HAC covariance estimation;
the default kernel is Bartlett
(also known in econometrics as Newey-West).
Kernels available are (abbreviations in parentheses):
Bartlett (bar); Truncated (tru); Parzen (par); Tukey-Hanning (thann); Tukey-Hamming (thamm);
Daniell (dan); Tent (ten); and Quadratic-Spectral (qua or qs).
Note that for some kernels (bar, par, thann and thamm)
the bandwidth must be at least 2
to obtain an autocorrelation-consistent estimator.

{p 0 4}{cmd:noconstant} suppresses the constant term (intercept) in the
list of partialled-out variables.

{p 0 4}{cmd:version} causes {cmd:ranktest11} to display its current version number
and to leave it in the macro {cmd:s(version)}.
It cannot be used with any other options.

{marker s_macros}{title:Saved results}

{p}{cmd:ranktest11} saves the following results in {cmd:r()}:

Scalars
{col 4}{cmd:r(N)}{col 18}Number of observations
{col 4}{cmd:r(N_clust)}{col 18}Number of clusters
{col 4}{cmd:r(chi2)}{col 18}rk statistic for highest rank tested
{col 4}{cmd:r(p)}{col 18}p-value of rk statistic
{col 4}{cmd:r(rdf)}{col 18}dof of rk statistic
{col 4}{cmd:r(rank)}{col 18}Rank of matrix under Ho for highest rank tested

Macros
{col 4}{cmd:r(version)}{col 18}Version number of {cmd:ranktest11}

Matrices
{col 4}{cmd:r(rkmarix)}{col 18}Saved results of rank tests
{col 4}{cmd:r(ccorr)}{col 18}Matrix of canonical correlations
{col 4}{cmd:r(eval)}{col 18}Matrix of eigenvalues (=squared canonical correlations)
{col 4}{cmd:r(V)}{col 18}Covariance matrix (W in Kleibergen-Paap (2006), p. 103)

{marker s_examples}{title:Examples}

{col 0}{bf:Tests for underidentification of Klein consumption equation.}

{col 0}(Underidentification means endogenous regressors (profits wagetot) are not identified
{col 0}by the excluded instruments (govt taxnetx year wagegovt capital1 L.totinc) after
{col 0}partialling-out the included instruments (L.totinc _cons).  Test is equivalent to
{col 0}testing whether the matrix of reduced form coefficients for the endogenous regressors
{col 0}is full rank (#cols=2) vs. less than full rank (#cols=1).  The test for underidentification
{col 0}should not be confused with a test for "weak identification"; see e.g. Stock and Yogo (2005)
{col 0}or Baum et al. (2007).)

{col 9}{stata "webuse klein, clear" :. webuse klein, clear}

{col 9}{stata "tsset yr" :. tsset yr}

{col 0}(Klein consumption equation - for reference)

{p 8 12}{stata "ivreg2 consump L.profits (profits wagetot = govt taxnetx year wagegovt capital1 L.totinc)" :. ivreg2 consump L.profits (profits wagetot = govt taxnetx year wagegovt capital1 L.totinc)}

{col 0}(Homoskedasticity, LM => Anderson canonical correlations test; test all ranks.  Ho of
{col 0}rank=1 can be rejected, suggesting the model is identified.)

{p 8 12}{stata "ranktest11 (profits wagetot) (govt taxnetx year wagegovt capital1 L.totinc), partial(L.profits)" :. ranktest11 (profits wagetot) (govt taxnetx year wagegovt capital1 L.totinc), partial(L.profits)}

{col 0}(Homoskedasticity, Wald => Cragg-Donald (1993) test; test all ranks.  Ho of rank=1 can
{col 0}be rejected, suggesting model is identified.)

{p 8 12}{stata "ranktest11 (profits wagetot) (govt taxnetx year wagegovt capital1 L.totinc), partial(L.profits) wald" :. ranktest11 (profits wagetot) (govt taxnetx year wagegovt capital1 L.totinc), partial(L.profits) wald}

{col 0}(Heteroskedastic robust, LM statistic, test for full rank only.  Ho of rank=1 now
{col 0}cannot be rejected, suggesting model may be underidentified.)

{p 8 12}{stata "ranktest11 (profits wagetot) (govt taxnetx year wagegovt capital1 L.totinc), partial(L.profits) full robust" :. ranktest11 (profits wagetot) (govt taxnetx year wagegovt capital1 L.totinc), partial(L.profits) full robust}

{col 0}(Heteroskedastic and autocorrelation robust, LM statistic, test for null rank only)

{p 8 12}{stata "ranktest11 (profits wagetot) (govt taxnetx year wagegovt capital1 L.totinc), partial(L.profits) null robust bw(2)":. ranktest11 (profits wagetot) (govt taxnetx year wagegovt capital1 L.totinc), partial(L.profits) null robust bw(2)}

{col 0}{bf:Testing for reduced rank in VAR models.}

{col 0}(Relationship of Johansen trace statistic and Anderson canonical correlations statistic.
{col 0}Former is an LR test, {cmd:ranktest11} reports LM version of latter, but based on the same
{col 0}eigenvalues.  Note that the p-values reported by {cmd:ranktest11} are not valid in this application
{col 0}because they are for the standard stationary case.)

{p 8 12}{stata "vecrank consump profits wagetot, lags(1)" :. vecrank consump profits wagetot, lags(1)}

{p 8 12}{stata "ranktest11 (d.consump d.profits d.wagetot) (L1.consump L1.profits L1.wagetot)" :. ranktest11 (d.consump d.profits d.wagetot) (L1.consump L1.profits L1.wagetot)}

{p 8 12}{stata "mat eval=r(eval)" :. mat eval=r(eval)}

{p 8 12}{stata "mat list eval" :. mat list eval}

{col 0}({cmd:vecrank} LR trace statistic for maximum rank=0 vs. {cmd:ranktest11} LM canonical correlations
{col 0}statistic for same.  Both statistics calculated using the same eigenvalues.)

{p 8 12}{stata "di -r(N)*(ln(1-eval[1,1]) + ln(1-eval[1,2]) + ln(1-eval[1,3]))" :. di -r(N)*(ln(1-eval[1,1]) + ln(1-eval[1,2]) + ln(1-eval[1,3]))}

{p 8 12}{stata "di r(N)*(eval[1,1] + eval[1,2] + eval[1,3])" :. di r(N)*(eval[1,1] + eval[1,2] + eval[1,3])}

{col 0}{bf:Equalities between rk statistic and other test statistics}

{col 0}(Equivalence of rk statistic and canonical correlations under homoskedasticity)

{p 8 12}{stata "canon (profits wagetot) (govt taxnetx year wagegovt)" :. canon (profits wagetot) (govt taxnetx year wagegovt)}

{p 8 12}{stata "mat list e(ccorr)" :. mat list e(ccorr)}

{p 8 12}{stata "ranktest11 (profits wagetot) (govt taxnetx year wagegovt)" :. ranktest11 (profits wagetot) (govt taxnetx year wagegovt)}

{p 8 12}{stata "mat list r(rkmatrix)" :. mat list r(rkmatrix)}

{col 0}(Equality of rk statistic and Wald test from OLS regression in special case
{col 0} of single regressor)

{p 8 12}{stata "ranktest11 (profits) (govt taxnetx year wagegovt capital1 L.totinc), partial(L.profits) wald robust" :. ranktest11 (profits) (govt taxnetx year wagegovt capital1 L.totinc), partial(L.profits) wald robust}

{p 8 12}{stata "regress profits govt taxnetx year wagegovt capital1 L.totinc L.profits, robust" :. regress profits govt taxnetx year wagegovt capital1 L.totinc L.profits, robust}

{p 8 12}{stata "testparm govt taxnetx year wagegovt capital1 L.totinc" :. testparm govt taxnetx year wagegovt capital1 L.totinc}

{p 8 12}{stata "di r(F)*r(df)*e(N)/e(df_r)" :. di r(F)*r(df)*e(N)/e(df_r)}

{col 0}(Equality of rk statistic and LM test from OLS regression in special case
{col 0} of single regressor. Generate a group variable to illustrate {cmd:cluster})

{p 8 12}{stata "gen clustvar = round(yr/2)" :. gen clustvar = round(yr/2)}

{p 8 12}{stata "ranktest11 (profits) (govt taxnetx year wagegovt capital1 L.totinc), partial(L.profits) cluster(clustvar)" :. ranktest11 (profits) (govt taxnetx year wagegovt capital1 L.totinc), partial(L.profits) cluster(clustvar)}

{p 8 12}{stata "ivreg2 profits L.profits (=govt taxnetx year wagegovt capital1 L.totinc), cluster(clustvar)" :. ivreg2 profits L.profits (=govt taxnetx year wagegovt capital1 L.totinc), cluster(clustvar)}

{p 8 12}{stata "di e(j)" :. di e(j)}

{col 0}(Equality of rk statistic of null rank and Wald test from OLS regressions and a
{col 0}Kronecker covariance matrix (independent and homoskedastic equations).  To show equality,
{col 0}estimate the equations using {cmd:reg3} specifying that all regressors are exogenous,
{col 0}and then test joint significance of Z variables in both regressions.  L.profits is the
{col 0}partialled-out variable and is not tested.)

{p 8 12}{stata "ranktest11 (profits wagetot) (govt taxnetx year wagegovt capital1 L.totinc), partial(L.profits) wald null ":. ranktest11 (profits wagetot) (govt taxnetx year wagegovt capital1 L.totinc), partial(L.profits) wald null}

{p 8 12}{stata "global e1 (profits govt taxnetx year wagegovt capital1 L.totinc L.profits)" :. global e1 (profits govt taxnetx year wagegovt capital1 L.totinc L.profits)}

{p 8 12}{stata "global e2 (wagetot govt taxnetx year wagegovt capital1 L.totinc L.profits)" :. global e2 (wagetot govt taxnetx year wagegovt capital1 L.totinc L.profits)}

{p 8 12}{stata "reg3 $e1 $e2, allexog" :. reg3 $e1 $e2, allexog}

{p 8 12}{stata "qui test [profits]govt [profits]taxnetx [profits]year [profits]wagegovt [profits]capital1 [profits]L.totinc": . qui test [profits]govt [profits]taxnetx [profits]year [profits]wagegovt [profits]capital1 [profits]L.totinc}

{p 8 12}{stata "test [wagetot]govt [wagetot]taxnetx [wagetot]year [wagetot]wagegovt [wagetot]capital1 [wagetot]L.totinc, accum": . test [wagetot]govt [wagetot]taxnetx [wagetot]year [wagetot]wagegovt [wagetot]capital1 [wagetot]L.totinc, accum}

{col 0}(Equality of rk statistic of null rank and Wald test from OLS regressions and {cmd:suest}.
{col 0}To show equality, use {cmd:suest} to test joint significance of Z variables in both
{col 0}regressions.  L.profits is the partialled-out variable and is not tested.   Note that
{col 0}{cmd:suest} introduces a finite sample adjustment of (N-1)/N.)

{p 8 12}{stata "ranktest11 (profits wagetot) (govt taxnetx year wagegovt capital1 L.totinc), partial(L.profits) wald null robust":. ranktest11 (profits wagetot) (govt taxnetx year wagegovt capital1 L.totinc), partial(L.profits) wald null robust}

{p 8 12}{stata "di r(chi2)*(r(N)-1)/r(N)": . di r(chi2)*(r(N)-1)/r(N)}

{p 8 12}{stata "qui regress profits govt taxnetx year wagegovt capital1 L.totinc L.profits":. qui regress profits govt taxnetx year wagegovt capital1 L.totinc L.profits}

{p 8 12}{stata "est store e1": . est store e1}

{p 8 12}{stata "qui regress wagetot govt taxnetx year wagegovt capital1 L.totinc L.profits":. qui regress wagetot govt taxnetx year wagegovt capital1 L.totinc L.profits}

{p 8 12}{stata "est store e2": . est store e2}

{p 8 12}{stata "qui suest e1 e2": . qui suest e1 e2}

{p 8 12}{stata "qui test [e1_mean]govt [e1_mean]taxnetx [e1_mean]year [e1_mean]wagegovt [e1_mean]capital1 [e1_mean]L.totinc": . qui test [e1_mean]govt [e1_mean]taxnetx [e1_mean]year [e1_mean]wagegovt [e1_mean]capital1 [e1_mean]L.totinc}

{p 8 12}{stata "test [e2_mean]govt [e2_mean]taxnetx [e2_mean]year [e2_mean]wagegovt [e2_mean]capital1 [e2_mean]L.totinc, accum": . test [e2_mean]govt [e2_mean]taxnetx [e2_mean]year [e2_mean]wagegovt [e2_mean]capital1 [e2_mean]L.totinc, accum}


{marker s_refs}{title:References}

{p 0 4}Anderson, T.W. 1951. Estimating linear restrictions on regression coefficients
for multivariate normal distributions. Annals of Mathematical Statistics, Vol. 22, pp. 327-51.

{p 0 4}Anderson, T.W. 1984. Introduction to Multivariate Statistical Analysis.
2d ed. New York: John Wiley & Sons.

{p 0 4}Baum, C. F., Schaffer, M.E., and Stillman, S. 2007. Enhanced routines for instrumental variables/GMM estimation and testing. Boston College Department of Economics Working Paper No. 667. 
{browse "http://ideas.repec.org/p/boc/bocoec/667.html":http://ideas.repec.org/p/boc/bocoec/667.html}

{p 0 4}Cragg, J.G. and Donald, S.G. 1993. Testing Identfiability and Specification in
Instrumental Variables Models. Econometric Theory, Vol. 9, pp. 222-240.

{p 0 4}Kleibergen, F. and Paap, R.  2006.  Generalized Reduced Rank Tests Using the Singular Value Decomposition.
Journal of Econometrics, Vol. 133, pp. 97-126.

{p 0 4}Stock, J.H. and Yogo, M.  2005.  Testing for Weak Instruments in Linear IV Regression. In D.W.K. Andrews and J.H. Stock, eds. Identification and Inference for Econometric Models: Essays in Honor of Thomas Rothenberg. Cambridge: Cambridge University Press, 2005, pp. 80–108.
Working paper version: NBER Technical Working Paper 284.
{browse "http://www.nber.org/papers/T0284":http://www.nber.org/papers/T0284}.

{marker s_acknow}{title:Acknowledgements}

{p}We would like to thank Kit Baum and Austin Nichols for helpful suggestions and feedback.

{marker s_citation}{title:Citation of ranktest11}

{p}{cmd:ranktest11} is not an official Stata command. It is a free contribution
to the research community, like a paper. Please cite it as such: {p_end}

{phang}Kleibergen, F., Schaffer, M.E. 2010.
ranktest11: module for testing the rank of a matrix using the Kleibergen-Paap rk statistic
{browse "http://ideas.repec.org/c/boc/bocode/s456865.html":http://ideas.repec.org/c/boc/bocode/s456865.html}{p_end}

{title:Authors}

	Frank Kleibergen, Brown University, US
	Frank_Kleibergen@brown.edu

	Mark E Schaffer, Heriot-Watt University, UK
	m.e.schaffer@hw.ac.uk

{title:Also see}

{p 1 14}Manual:  {hi:[R] canon}{p_end}

{p 1 10}On-line: help for {help canon}, {help vecrank}, {help ivreg2} (if installed){p_end}
