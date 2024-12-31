{smcl}
{* *! version 1.0.0  25jun2020}{...}
{vieweralsosee "[if installed] underid" "help underid"}{...}
{viewerjumpto "Syntax" "ranktest##syntax"}{...}
{viewerjumpto "Description" "ranktest##description"}{...}
{viewerjumpto "Tests" "ranktest##tests"}{...}
{viewerjumpto "Notes on numerical methods" "ranktest##numerical"}{...}
{viewerjumpto "Examples" "ranktest##examples"}{...}
{viewerjumpto "Stored results" "ranktest##results"}{...}
{viewerjumpto "References" "ranktest##references"}{...}
{title:Title}

{p2colset 5 22 24 2}{...}
{p2col :{manlink R ranktest} {hline 2}}Module for testing the rank of a matrix{p_end}
{p2colreset}{...}

{pstd}
Note: {cmd:ranktest} was substantially rewritten and expanded starting with version 2.0.02,
and the version of Stata required was raised to Stata 12.
To run the previous version of {cmd:ranktest},
either use version control ({bind:{it:version 11: ranktest ...}})
or call {cmd:ranktest11} (included in the {cmd:ranktest} package).

{title:Contents}

{p 4}{help ranktest##syntax:Syntax}{p_end}
{p 4}{help ranktest##description:Description}{p_end}
{p 4}{help ranktest##summary:Tests (summary)}{p_end}
{p 4}{help ranktest##tests:Tests (detail)}{p_end}
{p 4}{help ranktest##numerical:Notes on numerical methods and options}{p_end}
{p 4}{help ranktest##examples:Examples}{p_end}
{p 4}{help ranktest##replication:Replication: Manresa et al. (2017)}{p_end}
{p 4}{help ranktest##results:Stored results}{p_end}
{p 4}{help ranktest##references:References}{p_end}

{marker syntax}{...}
{title:Syntax}

{p 8 14 2}
{cmd:ranktest}
[{it:{help ranktest##weight:weight}}]
{cmd:(}{it:varlist1}{cmd:)}
{cmd:(}{it:varlist2}{cmd:)}
[{it:weight}]
{ifin}
[{cmd:,} {it:options}]

{synoptset 22}{...}

{p2col 3 4 4 2:iid test options}{p_end}
{synopt :{opt lr}}report Anderson likelihood ratio statistic instead of default Anderson LM statistic{p_end}
{synopt :{opt wald}}report Cragg-Donald Wald statistic instead of default Anderson LM statistic{p_end}

{p2col 3 4 4 2:robust test options}{p_end}
{synopt :{opt kp}}(default robust test) Kleibergen-Paap LIML-based statistic{p_end}
{synopt :{opt jcue}}Cragg-Donald CUE-based J statistic{p_end}
{synopt :{opt jgmm2s}}use 2-step efficient GMM instead of GMM CUE to obtain J statistic{p_end}
{synopt :{opt wald}}report Wald instead of default LM statistic{p_end}

{p2col 3 4 4 2:Main options}{p_end}
{synopt :{opt partial(varlist3)}}partial out the variables in {it:varlist3} from {it:varlist1} and {it:varlist2}{p_end}
{synopt :{cmdab:noc:onstant}}suppress the constant term (intercept) in the list of partialled-out variables{p_end}
{synopt :{cmdab:all:rank}}(default) report test statistics for rank=0, rank=1, ..., rank=(K1-1) where K1=min(#varlist1,#varlist2){p_end}
{synopt :{opt rr(integer)}}report only the test statistic for H0: rank=(K1-rr){p_end}
{synopt :{cmdab:full:rank}}report only the test statistic for H0: rank=(K1-1); equivalent to specifying {opt rr(1)}{p_end}
{synopt :{cmdab:null:rank}}report only the test statistic for H0: rank=0; equivalent to specifying {opt rr(K1)}{p_end}
{synopt :{opt small}}use a small-sample adjustment: instead of N, for LM-type tests use N-K3, and for Wald-type tests use N-K2-K3,
where K2=max(#varlist1,#varlist2) and K3=#varlist3{p_end}

{p2col 3 4 4 2:VCE options}{p_end}
{synopt :{cmdab:rob:ust}}report tests that are robust to arbitrary heteroskedasticity{p_end}
{synopt :{opt cluster(varlist)}}report tets that are robust to heteroskedasticity and within-cluster correlation; 2-way clustering is supported{p_end}
{synopt :{opt bw(#)}}report tests that are autocorrelation-consistent (AC)
or (with the {opt robust} option) heteroskedasticity- and autocorrelation-consistent (HAC),
with bandwidth equal to #{p_end}
{synopt :{opt kernel(string)}}specifies the kernel to be used for AC and HAC covariance estimation (default=Bartlett a.k.a. Newey-West){p_end}
{synopt :{opt center}}specifies that the moments in the robust VCE are centered so that they have mean zero{p_end}

{p2col 3 4 4 2:Iterative algorithm and numerical optimization options for CUE J statistic}{p_end}
{synopt :{opt jtol(real)}}(default=1e-10) tolerance for change in J in iterative algorithm when calculating the CUE J statistic{p_end}
{synopt :{opt btol(real)}}(default=1e-5) tolerance for change in beta in iterative algorithm when calculating the CUE J statistic{p_end}
{synopt :{opt binit(estimator)}}(default=2sls) initial beta when calculating the CUE J statistic; can be {opt liml} or {opt 2sls}{p_end}
{synopt :{opt nodots}}do not display dots when iterating to obtain the CUE J statistic{p_end}
{synopt :{cmdab:NOITER:ate}}do not use iterative algorithm; use only numerical optimization (default=use both){p_end}
{synopt :{cmdab:NOCOMB:iter}}do not use numerical optimization; use only iterative algorithm (default=use both){p_end}
{synopt :{opt maxiter(real)}}(default=100) maximum number of iterations in iterative algorithm{p_end}
{synopt :{opt noevorder}}override default behavior of reordering the variables in {it:varlist1} by eigenvalues{p_end}
{synopt :{opt nosvd}}(KP test only) use LIML residuals algorithm instead of default SVD algorithm to obtain KP statistic{p_end}

{p2col 3 4 4 2:Other options}{p_end}
{synopt :{opt nostd}}override the default behavior of standardizing variables to unit variance{p_end}
{synopt :{opt version}}display the current version number of {opt ranktest}; cannot be used with other options{p_end}


{pstd}
{cmd:ranktest} requires the Stata module {cmd:avar}; click {stata ssc install avar :here} to install
or type "ssc install avar" from inside Stata.
{cmd:ranktest} allows all robust covariance estimators supported by {cmd:avar};
see {help avar:help avar} for details.

{pstd}
All varlists may contain time-series operators or factor variables; see {stata "help varlist"}.

{pstd}
{cmd:aweight}s, {cmd:fweight}s, {cmd:iweight}s and {cmd:pweight}s
are allowed; see help {help weights}.


{marker description}{...}
{title:Description}

{pstd}
{cmd:ranktest} implements tests for the rank of a matrix.
Tests of the rank of a matrix have many practical applications.
For example, in econometrics the requirement for identification is the rank condition,
which states that a particular matrix must be of full column rank.
Another example from econometrics concerns
cointegration in vector autoregressive (VAR) models;
the Johansen trace test is a test of a rank of a particular matrix.

{pstd}
Denote one list of K1 variables as Y and a second list of K2 variables as Z,
and assume here and below that {bind:K1 <= K2 < N}.
The null hypothesis of the tests implemented by {cmd:ranktest}
is that the matrix of correlations or regression parameters B between Y and Z has rank(B)=K1-rr,
where rr denotes the reduction in rank.
A large test statistic and rejection of the null
indicates that the matrix B has rank at least K1-rr+1.
The most commonly employed choice is rr=1,
in which case the null is that rank(B)=K1-1 (B is rank deficient)
and rejection of the null indicates rank(B)=K1 (B is full column rank).

{pstd}
The traditional test of the rank of a matrix for the standard iid case
is the Anderson (1951) canonical correlations test.
If we calculate the squared {help canon:canonical correlations} between Y and Z,
the LM form of the Anderson test
is N times the sum of the rr smallest squared canonical correlations.
Anderson's test also has a likelihood ratio version (see below).
The Cragg-Donald (1993, 1997) statistic for the iid case is essentially
a Wald version of Anderson's test.
Both the Anderson and Cragg-Donald tests require the iid assumption,
i.e., that the covariance matrix has a Kronecker form.
When this is not so,
e.g., when disturbances are heteroskedastic or autocorrelated,
the test statistics are no longer valid.

{pstd}
In the non-iid case, {cmd:ranktest} will report tests
that are robust to various forms of
heteroskedasticity, autocorrelation, and clustering.
The default is to report the Kleibergen-Paap (2006) test.
An alterative is to report a robust form of the Cragg-Donald (1993, 1997) test.
Windmeijer (2018) shows that the Cragg-Donald test can be interpreted,
and is implemented in {cmd:ranktest} as, a Hansen-Sargan J statistic
when estimating using GMM and the CUE (continuously-updated) estimator.
The robust form of the Cragg-Donald test is specifed by the {opt jcue} option.
All of these tests are discussed in more detail below.

{pstd}
The rank test is applied to Y and Z,
where Y={it:varlist1} and Z={it:varlist2}.
Optionally, a third set of variables X={it:varlist3}
can be partialled-out of Y and Z
with the {opt partial(varlist3)} option.
A constant is automatically partialled out,
unless the user specifies the {opt nocons} option.
The null hypothesis is H0: rank(B)=K1-rr,
a rank reduction of rr.
Rejection of the null indicates that the matrix
has at least rank=K1-rr+1.
The test statistic is distributed as chi-squared
with degrees of freedom = (K1-(K1-rr))*(K2-(K2-rr)),
where K1 is the number of Y variables,
K2 is the number of Z variables,
and rr is the rank reduction being tested in H0.
For example,
to test if the matrix is full column rank K1 where K1<=K2,
the null would be H0:rank(B)=K1-1 (a rank reduction of 1)
and the degrees of freedom of the test
would be {bind:(K1-(K1-1))*(K2-(K1-1)} = (K2-K1+1).
The default behavior of {cmd:ranktest} is to perform all possible tests of rank;
the {cmdab:full:rank} option causes only the test of whether the matrix is full rank
(H0:rank(B)=K1-1) to be reported;
the {cmdab:null:rank} option causes only the test of whether the matrix is zero rank
(H0:rank(B)=0) to be reported;
the {opt rr(integer)} option allows the user to test for the specified order of rank reduction.

{pstd}Note that {cmd:ranktest} separately checks the data matrices Y and X for collinearities
and if necessary drops collinear variables.
Also note that if the number of variables in {it:varlist1}
is greater than the number of variables in {it:varlist2},
{cmd:ranktest} will use {it:varlist2} for Y and {it:varlist1} for Z.
However, the macros {opt r(K1)} and {opt r(K2)} set by {cmd:ranktest}
always refer to the number of variables in {it:varlist1} and {it:varlist2}, respectively,
after any collinear variables are dropped.

{pstd}With the exception of the LR version of Anderson's canonical correlation test,
all the tests reported by {cmd:ranktest} are score (Lagrange multiplier, LM) tests.
The distinction between the "LM" and "Wald" versions of the tests
lies only in the type of residual used to construct an estimate of the variance.
See {help "ranktest##examples":below} for examples illustrating this point
and Windmeijer (2018) for explanation and discussion.

{pstd}The default behavior of {cmd:ranktest} is to report LM versions of the tests;
the {opt wald} option will cause it to report Wald versions.
In the iid case only, the {opt lr} option will report the LR version of the Anderson test.
Specifying {opt robust}, {opt bw(#)} (where # is the bandwidth) or {opt cluster(varname)}
will generate an rk statistic that is robust to
heteroskedasticity, autocorrelation or within-group clustering;
{opt robust} combined with {opt bw(#)} will generate a
heteroskedasticity and autocorrelation-consistent (HAC) statistic.
The implementation of an autocorrelation-consistent statistic
and the options available for various kernels
follow that in {help ivreg2};
for more details, see Baum et al. (2007) or {help help ivreg2} if installed.
If none of the above options is specified,
{cmd:ranktest} defaults to reporting the
LM version of the Anderson (1951) canonical correlations test,
or, if {opt wald} is specified, the Cragg-Donald (1993, 1997) Wald test.

{pstd}It is useful to note that in the special case of K1=1
(there is a single variable Y) and H0:rank=0,
all these tests reduce to statistics that are available from OLS estimation.
The iid version of the Cragg-Donald statistic can be calculated
by regressing the single Y on Z and X and testing the joint significance of Z
using a standard Wald test
and the traditional non-robust covariance estimator.
The Anderson LM statistic can be obtained by calculating an LM test
of the same joint hypothesis.
Also in the K1=1 case, the robust KP and CD statistics coincide,
and can be calculated using OLS and the desired robust covariance estimator.
If K1>1, test statistics for H0:rank=0 reported by {cmd:ranktest}
can be reproduced by testing the joint significance of the Z variables
across the K1 equations for the Y variables;
see the {help "ranktest##examples":examples} below.

{pstd}In certain settings the user may specify that some variables appear
in {it:both} Y ({it:varlist1}) and Z ({it:varlist2}).
In the iid case, and in the cases of the tests using KP and J using 2-step GMM,
the test statistics thus obtained will be identical
to when these shared variable are instead partialled-out from Y and Z.
The results will differ, however, in the non-robust case with tests based on the CUE GMM estimator.
The intuition can be seen by recognizing that these variables
correspond to exogenous regressors in a linear IV estimation.
In an equation estimated by CUE GMM,
the orthogonality conditions corresponding to the excluded instruments
also contribute to the estimation of the coefficients on the included exogenous regressors,
and hence estimation using CUE yields result different from when they are partialled-out.
The replication below using the paper by Manresa et al. (2017)
provides an example of the use of this feature.


{marker summary}{...}
{title:Test statistics (summary)}

{pstd}Note: {opt robust} below applies to all tests employing
a "robust" covariance estimator (heteroskedastic-robust, HAC, cluster-robust etc.).

{p2col 5 25 26 0: {it:Options}}
Test
{p_end}

{p2col 5 25 26 0: {cmd:(none)}}
Anderson canonical correlations test, LM version. Assumes iid.
{p_end}

{p2col 5 25 26 0: {opt lr}}
Anderson canonical correlations test, LR version. Assumes iid.
{p_end}

{p2col 5 25 26 0: {opt wald}}
Cragg-Donald test, iid version.
{p_end}

{p2col 5 25 26 0: {opt robust}}
Kleibergen-Paap LIML-based robust statistic, LM version.
Same as specifying {opt robust kp}.
{p_end}

{p2col 5 25 26 0: {opt robust wald}}
Kleibergen-Paap LIML-based robust statistic, Wald version.
Same as specifying {opt robust kp wald}.
{p_end}

{p2col 5 25 26 0: {opt robust jcue}}
Cragg-Donald robust CUE-based statistic, LM version.
{p_end}

{p2col 5 25 26 0: {opt robust jcue wald}}
Cragg-Donald robust CUE-based statistic, Wald version.
{p_end}


{marker tests}{...}
{title:Test statistics (detail)}

{pstd}Denote by Y and Z two lists of variables, with K1 and K2 columns respectively.
By convention, K1 <= K2.
For simplicity we assume no collinearities exist within Y and Z.
An optional third set of variables X has already been partialled out of Y and Z;
the default behavior of {cmd:ranktest} is to center Y and Z (partial out a constant).
Rank tests are tests of the rank of the matrix E(Z_i'Y_i),
where Z_i and Y_i correspond to rows of the data matrices Z and Y.
E(Z_i'Y_i) is full rank if rank(E(Z_i'Y_i))=K1.

{pstd}
Rank tests can also be presented in terms of linear regression.
Write the system of linear equations as {bind:Y = Z*B + V}.
The K2xK1 matrix of regression coefficients B
is defined as inv(E(Z_i'Z_i))*E(Z_i'Y_i),
and the OLS estimate of B is Bhat=inv(Z'Z))*Z'Y.
(In the context of instrumental variable estimation,
this is the set of first-stage equations.)
Rank tests are tests of the rank of the matrix B.

{pstd}
A test of whether B is full rank is a test of the null hypothesis H0:rank(B)=K1-1,
a rank reduction of 1;
rejection indicates B is full rank.
A test of whether B is null rank is a test of the null hypothesis H0:rank(B)=0,
a rank reduction of K1.
If K1=1 so that there is a single Y variable, only a single test is available, H0:rank(B)=0;
rejection indicates rejection of null rank in favor of full rank.
In the K1=1 case the rank test is equivalent to a test of
the significance of the variables Z in an OLS regression of Y on Z (and X);
see the {help "ranktest##examples":examples} below.

{marker CCiid}{...}
{bf:Anderson canonical correlations test}

{pstd}Denote by ev_1 < ev_2 < ... < ev_K
the eigenvalues of (Y'*P_z*Y)*inv(Y'Y) where P_z is the projection matrix Z*inv(Z'Z)*Z',
after partialling out X and ordering the eigenvalues from smallest to largest.
The eigenvalues correspond to the squared {help canon:canonical correlations} between Y and Z (Anderson 1951).
The LM version of Anderson's canonical correlations test is

	rk = N sum_p ev_p, p=1...rr

{pstd}where rr denotes the reduction in rank.
A test of whether B is full rank is obtained from rr=1 (i.e., using the smallest eigenvalue);
a test of whether it is null rank is obtained from rr=K1 (i.e., using the sum of all the eigenvalues).

{pstd}The likelihood-ratio version of Anderson's test is

	rk = -N sum_p ln(1-ev_p), p=1...rr

{marker CDiid}{...}
{bf:Cragg-Donald rank test (iid version)}

{pstd}In the iid case, the Cragg-Donald (1993, 1997) test is essentially a Wald version of Anderson's test:

	rk = N sum_p ev_p/(1-ev_p), p=1...rr

{marker KProbust}{...}
{bf:Kleibergen-Paap (LIML-based) rank test}

{pstd}Denote by Bhat the OLS estimator of B.
The Kleibergen-Paap (2006) test of the rank of B
is derived from applying the singular value decomposition (SVD)
to a normalized version of Bhat.
Kleibergen-Paap (2006) show that
the KP test statistic can be interpreted as
Anderson's canonical correlations test generalized to the non-iid case
(a non-Kronecker covariance matrix).
Windmeijer (2018) shows that the KP test statistic
can also be interpreted as a LIML-based robust score test.
He also shows that it can be obtained from an artificial regression
using the residuals from LIML estimation(s);
the LIML residuals are obtained from estimations
where the Y variables are partitioned into
some that are treated as dependent (LHS) variables
and the remainder are endogenous (RHS) regressors.
The default is for {cmd:ranktest} to use the SVD algorithm;
the {opt nosvd} option means {cmd:ranktest} uses the LIML residuals method.
Because it is a robust score test,
the test is invariant to how the Y variables are partitioned
when the LIML residuals method is used.
See the {help "ranktest##examples":examples} below.

{marker CDrobust}{...}
{bf:Cragg-Donald (CUE-based) rank test (robust version)}

{pstd}Cragg-Donald (1993, 1997) present a test for the rank of B for the non-iid case
that is based on the Generalized Method of Moments (GMM).
Windmeijer (2018) shows that their test statistic
is equal to a J statistic from a regression estimated using
GMM CUE (the continuously-updated GMM estimator),
where the Y variables are partitioned into
some that are treated as dependent (LHS) variables
and the remainder are endogenous (RHS) regressors.
Because it is a robust score test,
the test is invariant to how the Y variables are partitioned.
See the {help "ranktest##examples":examples} below.
The robust CD statistic is obtained from {cmd:ranktest} using the option {opt jcue}
in order to distinguish it from the CD statistic for the iid case
presented in the same 1993 paper.
(NB: 2-step efficient GMM can be used instead of GMM CUE with the {opt jgmm2s} option.
For more on variants of J- and LIML-based test statistics, see Windmeijer (2018).)

{marker numerical}{...}
{title:Notes on numerical methods and options}

{pstd}To help with numerical stability,
by default all variables are standardized to have unit variance
prior to calculation of the test statistics.
This can be turned off with the {opt nostd} option.
Returned results such as coefficient vectors and covariances
are unstandardized after estimation,
so this option affects only the numerical optimization and not the reported results.
In addition, prior to the calculation of the CUE-based tests,
the Y variables are reordered according to eigenvalues.
This can be turned off with the {opt noevorder} option.

{pstd}The default behavior of {cmd:ranktest}
is to use the iterative algorithm of Windmeijer (2018) for the GMM CUE estimator
until convergence (according to either {opt btol(real)} or {opt jtol(real)}),
followed by numerical minimization using Mata's {opt optimize(.)}
until convergence (again according to either {opt btol(real)} or {opt jtol(real)}).
The {opt nocombiter} option causes {cmd:ranktest} to rely only on the iterative algorithm;
the {opt noiterate} option causes it to rely only on numerical minimization.
Note that the CUE objective function is not guaranteed to have a unique minimum,
and hence the algorithm may converge to a local minimum;
see below for an example.

{pstd}
The coefficients for the GMM regression
behind the J-based test statistics (CUE and 2-step GMM)
for the test of the highest rank reported by {cmd:ranktest}
are saved in the macro {opt r(b)}.
The macro {opt r(b0)} has the initial coefficient vector used in the algorithm.
To obtain the coefficients and variance-covariance matrix
corresponding to a CUE or 2-step GMM estimation,
use the {opt noevorder} option and in {cmd:(}{it:varlist1}{cmd:)}
specify the dependent variable(s) followed by the endogenous regressors.
See the example(s) below.

{pstd}
The GMM CUE estimator corresponding to the LM form of the CUE-based J statistic
is not invariant to the partialling out
of the variables in X (including the constant).
The intuition is that the projection coefficients
used to partial out X are OLS coefficients,
whereas in a full CUE specification in which X are explicit exogenous regressors,
the orthogonality conditions in Z are also used when estimating the coefficients on X.
The test statistic corresponding to a full CUE specification
can be obtained by including the exogenous regressors including the constant
in both Y ({it:varlist1}) and Z ({it:varlist2}).
See the example below.
(NB: the Wald form of the CUE-based J statistic is invariant to partialling-out.)


{marker s_macros}{title:Stored results}

{pstd}{cmd:ranktest} stores the following results in {cmd:r()}:

{synoptset 19 tabbed}{...}
{p2col 5 19 23 2: scalars}{p_end}
{synopt:{cmd:r(N)}}Number of observations{p_end}
{synopt:{cmd:r(N_clust)}}Number of clusters{p_end}
{synopt:{cmd:r(K1)}}Rank of Y matrix (number of non-collinear variables in {it:varlist1}){p_end}
{synopt:{cmd:r(K2)}}Rank of Z matrix (number of non-collinear variables in {it:varlist2}){p_end}
{synopt:{cmd:r(K3)}}Rank of X matrix ({it:varlist3},
number of partialled-out non-collinear variables including the constant){p_end}
{synopt:{cmd:r(chi2)}}rk statistic for highest rank tested{p_end}
{synopt:{cmd:r(p)}}p-value of rk statistic{p_end}
{synopt:{cmd:r(rdf)}}dof of rk statistic{p_end}
{synopt:{cmd:r(rank)}}Rank of matrix under H0 for highest rank tested{p_end}
{synopt:{cmd:r(cons)}}=1 if constant present, =0 if not{p_end}

{synoptset 19 tabbed}{...}
{p2col 5 19 23 2: macros}{p_end}
{synopt:{cmd:r(version)}}Version number of {cmd:ranktest}{p_end}
{synopt:{cmd:r(varlist1)}}First (Y) varlist provided to {cmd:ranktest}{p_end}
{synopt:{cmd:r(varlist2)}}Second (Z) varlist provided to {cmd:ranktest}{p_end}
{synopt:{cmd:r(partial)}}Third (X) varlist of partialled-out variables (not including the constant){p_end}
{synopt:{cmd:r(collin)}}Dropped collinear variables in Y and/or Z{p_end}
{synopt:{cmd:r(testtype)}}LR, LM or Wald{p_end}
{synopt:{cmd:r(method)}}kp, jcue, jgmm2s, etc.{p_end}

{synoptset 19 tabbed}{...}
{p2col 5 19 23 2: matrices}{p_end}
{synopt:{cmd:r(rkmarix)}}Saved results of rank tests{p_end}
{synopt:{cmd:r(ccorr)}}Matrix of canonical correlations{p_end}
{synopt:{cmd:r(eval)}}Matrix of eigenvalues (=squared canonical correlations){p_end}
{p2col 5 19 23 2: (CUE- and 2-step GMM-based tests of a single order of rank reduction only)}{p_end}
{synopt:{cmd:r(b)}}Coefficient vector from CUE or 2-step GMM estimation{p_end}
{synopt:{cmd:r(b0)}}Initial coefficient vector for CUE or 2-step GMM estimation{p_end}
{synopt:{cmd:r(V)}}Covariance matrix of CUE or 2-step GMM estimator{p_end}
{synopt:{cmd:r(S)}}Covariance matrix of orthogonality conditions{p_end}
{p2col 5 19 23 2: (Canonical correlations or KP-based tests only)}{p_end}
{synopt:{cmd:r(S)}}Covariance matrix (asymptotic variance of Z'V){p_end}
{synopt:{cmd:r(V)}}Covariance matrix (Omega in Kleibergen-Paap (2006){p_end}


{marker examples}{title:Examples}

{col 0}{bf:Tests for underidentification of Klein consumption equation.}

{pstd}
Underidentification means endogenous regressors (profits wagetot) are not identified
by the excluded instruments (govt taxnetx year wagegovt capital1 L.totinc) after
partialling-out the included instruments (L.totinc _cons).
Test is equivalent to testing whether the matrix of reduced form coefficients for the endogenous regressors
is full rank (K1=2) vs. less than full rank (K1=1).
The test for underidentification should not be confused with a test for "weak identification";

{phang2}. {stata "webuse klein, clear"}{p_end}
{phang2}. {stata "tsset yr"}{p_end}

{pstd}
Klein consumption equation - for reference.

{phang2}. {stata "ivreg2 consump L.profits (profits wagetot = govt taxnetx year wagegovt capital1 L.totinc)"}{p_end}

{pstd}
IID case, LM => Anderson canonical correlations test; test all ranks.
H0 of rank=1 can be rejected, suggesting the model is identified.

{phang2}. {stata "ranktest (profits wagetot) (govt taxnetx year wagegovt capital1 L.totinc), partial(L.profits)"}{p_end}

{pstd}
IID case, Wald => Cragg-Donald (1993, 1997) test; test all ranks.
H0 of rank=1 can be rejected, suggesting model is identified.

{phang2}. {stata "ranktest (profits wagetot) (govt taxnetx year wagegovt capital1 L.totinc), partial(L.profits) wald"}{p_end}

{pstd}
Heteroskedastic-robust Kleibergen-Paap LIML-based LM statistic, test for full rank only.
H0 of rank=1 now cannot be rejected, suggesting model may be underidentified.

{phang2}. {stata "ranktest (profits wagetot) (govt taxnetx year wagegovt capital1 L.totinc), partial(L.profits) full robust"}{p_end}

{pstd}
Heteroskedastic-robust Cragg-Donald CUE-based LM statistic, test for full rank only.
H0 of rank=1 now cannot be rejected, suggesting model may be underidentified.

{phang2}. {stata "ranktest (profits wagetot) (govt taxnetx year wagegovt capital1 L.totinc), partial(L.profits) full robust jcue"}{p_end}

{pstd}
Heteroskedastic and autocorrelation robust, Cragg-Donald CUE-based LM statistic, test for full rank only.

{phang2}. {stata "ranktest (profits wagetot) (govt taxnetx year wagegovt capital1 L.totinc), partial(L.profits) full robust bw(2) jcue"}{p_end}


{bf:Testing for reduced rank in VAR models.}

{pstd}
Relationship of Johansen trace statistic and Anderson canonical correlations statistic.
Former is an LR test, {cmd:ranktest} reports LM version of latter,
but based on the same eigenvalues.
Note that the p-values reported by {cmd:ranktest} (unlike those reported by {cmd:vecrank})
are not valid in this application because they are for the standard stationary case.

{phang2}. {stata "vecrank consump profits wagetot, lags(1)"}{p_end}

{phang2}. {stata "ranktest (d.consump d.profits d.wagetot) (L1.consump L1.profits L1.wagetot), lr"}{p_end}
{phang2}. {stata "mat list r(eval)"}{p_end}

{pstd}
HAC (heteroskedastic- and autocorrelation-consistent) tests for reduced rank in a VAR model.
The Kleibergen-Paap robust test statistics reported by {cmd:ranktest} below
use a Barlett (Newey-West) kernel with bandwidth=3.
Kleibergen-Paap (2006) show that the distribution of the KP statistic
is the same as that of the Johansen trace statistic
and hence the critical values reported in the output of {cmd:vecrank} can be used
(and not the p-values in the {cmd:ranktest} output).

{phang2}. {stata "ranktest (d.consump d.profits d.wagetot) (L1.consump L1.profits L1.wagetot), rob bw(3)"}{p_end}


{col 0}{bf:Equivalences between rk statistic and other test statistics}

{pstd}
Examples use the Klein consumption equation,
shown immediately below for reference.
Stata variables Lprofits, Ltotinc and esample also created here.
These are used in the Mata examples below.

{phang2}. {stata "webuse klein, clear"}{p_end}
{phang2}. {stata "tsset yr"}{p_end}
{phang2}. {stata "ivreg2 consump L.profits (profits wagetot = govt taxnetx year wagegovt capital1 L.totinc)"}{p_end}
{phang2}. {stata "gen byte esample=e(sample)"}{p_end}
{phang2}. {stata "gen Lprofits=L.profits"}{p_end}
{phang2}. {stata "gen Ltotinc=L.totinc"}{p_end}

{pstd}
Equivalence of {cmd:ranktest} LM statistic and canonical correlations in the iid case.

{phang2}. {stata "canon (profits wagetot) (govt taxnetx year wagegovt)"}{p_end}
{phang2}. {stata "mat list e(ccorr)"}{p_end}

{phang2}. {stata "ranktest (profits wagetot) (govt taxnetx year wagegovt)"}{p_end}
{phang2}. {stata "mat list r(rkmatrix)"}{p_end}

{pstd}
Illustration of LM version vs Wald version of rk statistic in the iid case.
In the non-robust iid case, the Anderson and Cragg-Donald statistics can be obtained
as Sargan and Basmann J statistics from LIML estimation, respectively.
{cmd:ivreg2} is used instead of {cmd:regress}
in order to obtain a test statistic without a small-sample adjustment.

{pstd}
LM (Anderson, Sargan) version:

{phang2}. {stata "qui ivreg2 consump L.profits (profits wagetot = govt taxnetx year wagegovt capital1 L.totinc), partial(L.profits) liml"}{p_end}
{phang2}. {stata "di e(j)"}{p_end}
{phang2}. {stata "cap drop ehat"}{p_end}
{phang2}. {stata "predict double ehat, r"}{p_end}
{phang2}. {stata "qui ivreg2 ehat L.profits govt taxnetx year wagegovt capital1 L.totinc"}{p_end}
{phang2}(as an LM NR2 test statistic:){p_end}
{phang2}. {stata "di e(N)*e(r2)"}{p_end}

{phang2}. {stata "ranktest (consump profits wagetot) (govt taxnetx year wagegovt capital1 L.totinc), partial(L.profits) rr(1)"}{p_end}

{pstd}
Wald (Cragg-Donald, Basmann) version:

{phang2}. {stata "qui ivreg2 ehat L.profits govt taxnetx year wagegovt capital1 L.totinc"}{p_end}
{phang2}. {stata "test govt taxnetx year wagegovt capital1 L.totinc"}{p_end}

{phang2}. {stata "ranktest (consump profits wagetot) (govt taxnetx year wagegovt capital1 L.totinc), partial(L.profits) rr(1) wald"}{p_end}

{pstd}
Equality of Cragg-Donald CUE-based robust rk statistic for rank reduction=1
and J test statistic from GMM CUE estimation.

{phang2}. {stata "ivreg2 consump L.profits (profits wagetot = govt taxnetx year wagegovt capital1 L.totinc), partial(L.profits) rob cue"}{p_end}
{phang2}. {stata "di e(j)"}{p_end}
{phang2}. {stata "ranktest (consump profits wagetot) (govt taxnetx year wagegovt capital1 L.totinc), partial(L.profits) rob jcue rr(1)"}{p_end}
{phang2}. {stata "di r(chi2)"}{p_end}

{pstd}
Using {opt ranktest} as a GMM CUE estimator.
Use {opt noevorder} to control which is the dependent variable and which are the endogenous regressors.
Use the {opt rr(1)} option to specify that there is a single dependent variable (single-equation CUE estimation).
Use a HAC-covariance estimator.
NB: results differ slightly because of differences in numerical optimization.

{phang2}. {stata "ivreg2 consump L.profits (profits wagetot = govt taxnetx year wagegovt capital1 L.totinc), partial(L.profits) rob bw(3) cue"}{p_end}
{phang2}. {stata "mat list e(b)"}{p_end}
{phang2}. {stata "mat list e(V)"}{p_end}
{phang2}. {stata "ranktest (consump profits wagetot) (govt taxnetx year wagegovt capital1 L.totinc), partial(L.profits) rob bw(3) jcue rr(1) noevorder"}{p_end}
{phang2}. {stata "mat list r(b)"}{p_end}
{phang2}. {stata "mat list r(V)"}{p_end}

{pstd}
Invariance of the Cragg-Donald CUE-based robust test statistic:
switch wagetot and consump
so that wagetot is the dependent variable (was an endogenous regressor)
and consump is an endogenous regressor (was the dependent variable),
and the same J statistic is obtained.

{phang2}. {stata "qui ivreg2 consump L.profits (profits wagetot = govt taxnetx year wagegovt capital1 L.totinc), partial(L.profits) rob cue"}{p_end}
{phang2}. {stata "di e(j)"}{p_end}
{phang2}. {stata "qui ivreg2 wagetot L.profits (profits consump = govt taxnetx year wagegovt capital1 L.totinc), partial(L.profits) rob cue"}{p_end}
{phang2}. {stata "di e(j)"}{p_end}

{pstd}
CUE coefficients when partialling out vs not partialling out:
include the exogenous regressor L.profits and a constant in Y and X.
Also use the {opt noevorder} and {opt nocons} options.
Note this refers to the LM form of the CUE-based J test;
the Wald form is invariant to partialling out

{phang2}. {stata "qui ranktest (consump profits wagetot) (govt taxnetx year wagegovt capital1 L.totinc), partial(L.profits) rob jcue rr(1) noevorder"}{p_end}
{phang2}. {stata "mat list r(b)"}{p_end}
{phang2}. {stata "qui ivreg2 consump L.profits (profits wagetot = govt taxnetx year wagegovt capital1 L.totinc), partial(L.profits) rob cue"}{p_end}
{phang2}. {stata "mat list e(b)"}{p_end}

{phang2}. {stata "gen byte one=1"}{p_end}
{phang2}. {stata "qui ranktest (consump profits wagetot L.profits one) (govt taxnetx year wagegovt capital1 L.totinc L.profits one), rob jcue rr(1) noevorder nocons"}{p_end}
{phang2}. {stata "mat list r(b)"}{p_end}
{phang2}. {stata "qui ivreg2 consump L.profits (profits wagetot = govt taxnetx year wagegovt capital1 L.totinc), rob cue"}{p_end}
{phang2}. {stata "mat list e(b)"}{p_end}

{pstd}
Kleibergen-Paap LIML-based robust score test for rank reduction=1
as a J test in an artificial regression
using LIML residuals and a subset of the fitted values of Y.
Denoting profits as Y1 and wagetot as Y2,
the LIML residuals are obtained from a LIML estimation
with Y1 as the dependent variable and Y2 as the endogenous regressor.
First create LIML residuals and then create the fitted values of the subset of Y in Mata.
(NB: The Stata variables Lprofits, Ltotinc and esample were created above.)
The J statistic reported by {cmd:ivreg2} is an LM-type test
of the significance of the excluded instruments
with the LIML residuals as the dependent variable,
the fitted Y2 as an additional exogenous regressor,
and an arbitrary subset of instruments
(dropping one instrument since dim(Y2)=1).

{pstd}
First calculated the fitted values of the endogenous Y2 (wagetot):

{phang2}. {stata "qui ivreg2 profits L.profits (wagetot = govt taxnetx year wagegovt capital1 L.totinc), liml"}{p_end}
{phang2}. {stata "cap drop ehat"}{p_end}
{phang2}. {stata "predict double ehat, r"}{p_end}
{phang2}. {stata "putmata Y=(wagetot) Z=(govt taxnetx year wagegovt capital1 Ltotinc) U=(ehat Lprofits 1) yr if esample, replace"}{p_end}
{phang2}. {stata "mata: Ztilde = Z - U*invsym(U'U)*U'Z"}{p_end}
{phang2}. {stata "mata: Yhat = Ztilde*invsym(Ztilde'Ztilde)*Ztilde'Y"}{p_end}
{phang2}. {stata "getmata (wagetothat)=Yhat, id(yr) replace"}{p_end}

{pstd}
Now show the J statistic is identical to the {cmd:ranktest} LM version of the robust KP test statistic; L.totinc is the omitted instrument:

{phang2}. {stata "qui ivreg2 ehat wagetothat L.profits (=govt taxnetx year wagegovt capital1), rob"}{p_end}
{phang2}. {stata "di e(j)"}{p_end}

{phang2}. {stata "ranktest (profits wagetot) (govt taxnetx year wagegovt capital1 L.totinc), partial(L.profits) rr(1) rob"}{p_end}

{pstd}
LM version vs Wald version of the robust KP test statistic in an artificial regression.
LM version is obtained as above with Z variables as excluded instruments.
Wald version is obtained as a Wald test using OLS with the Z variables as regressors.
L.totinc is the dropped instrument.
{cmd:ivreg2} is used instead of {cmd:regress} to perform OLS
in order that no small-sample adjustments are applied and a chi-sq statistic is reported by {cmd:test}.

{phang2}. {stata "qui ivreg2 ehat wagetothat L.profits (=govt taxnetx year wagegovt capital1), rob"}{p_end}
{phang2}. {stata "di e(j)"}{p_end}
{phang2}. {stata "ranktest (profits wagetot) (govt taxnetx year wagegovt capital1 L.totinc), partial(L.profits) rr(1) rob"}{p_end}

{phang2}. {stata "qui ivreg2 ehat wagetothat govt taxnetx year wagegovt capital1 L.profits, rob"}{p_end}
{phang2}. {stata "test govt taxnetx year wagegovt capital1"}{p_end}
{phang2}. {stata "ranktest (profits wagetot) (govt taxnetx year wagegovt capital1 L.totinc), partial(L.profits) rr(1) rob wald"}{p_end}

{pstd}
Invariance of the Kleibergen-Paap LIML-based robust score test:
reverse Y1 and Y2 (profits and wagetot) and the same statistic is obtained:

{phang2}. {stata "qui ivreg2 profits L.profits (wagetot = govt taxnetx year wagegovt capital1 L.totinc), liml"}{p_end}
{phang2}. {stata "cap drop ehat"}{p_end}
{phang2}. {stata "predict double ehat, r"}{p_end}
{phang2}. {stata "putmata Y=(profits) U=(ehat Lprofits 1) yr if esample, replace"}{p_end}
{phang2}. {stata "mata: Ztilde = Z - U*invsym(U'U)*U'Z"}{p_end}
{phang2}. {stata "mata: Yhat = Ztilde*invsym(Ztilde'Ztilde)*Ztilde'Y"}{p_end}
{phang2}. {stata "getmata (profitshat)=Yhat, id(yr) replace"}{p_end}

{phang2}. {stata "qui ivreg2 ehat profitshat L.profits (=govt taxnetx year wagegovt capital1), rob"}{p_end}
{phang2}. {stata "di e(j)"}{p_end}

{pstd}
Invariance: drop govt (or any other instrument) instead of L.totinc and the same statistic is obtained: 

{phang2}. {stata "qui ivreg2 ehat profitshat L.profits (=taxnetx year wagegovt capital1 L.totinc), rob"}{p_end}
{phang2}. {stata "di e(j)"}{p_end}

{pstd}
Invariance: drop taxnetx (or any other instrument) instead of L.totinc and the same statistic is obtained: 

{phang2}. {stata "qui ivreg2 ehat profitshat govt year wagegovt capital1 L.totinc L.profits, rob"}{p_end}
{phang2}. {stata "test govt year wagegovt capital1 L.totinc"}{p_end}

{pstd}
Equality of robust rk statistic and Wald test from OLS regression in special case of single regressor.
Note that this is a test of H0:rank=0 and so applies to both the robust KP and robust CD tests.

{phang2}. {stata "qui ivreg2 profits govt taxnetx year wagegovt capital1 L.totinc L.profits, robust"}{p_end}
{phang2}. {stata "test govt taxnetx year wagegovt capital1 L.totinc"}{p_end}

{phang2}. {stata "ranktest (profits) (govt taxnetx year wagegovt capital1 L.totinc), partial(L.profits) wald robust"}{p_end}

{pstd}
Equality of rk statistic of null rank and Wald test from OLS regressions and a
Kronecker covariance matrix (independent and homoskedastic equations).
To show equality, estimate the equations using {cmd:reg3} specifying that all regressors are exogenous,
and then test joint significance of Z variables in both regressions.
L.profits is the partialled-out variable and is not tested.

{phang2}. {stata "global e1 (profits govt taxnetx year wagegovt capital1 L.totinc L.profits)"}{p_end}
{phang2}. {stata "global e2 (wagetot govt taxnetx year wagegovt capital1 L.totinc L.profits)"}{p_end}
{phang2}. {stata "reg3 $e1 $e2, allexog"}{p_end}
{phang2}. {stata "qui test [profits]govt [profits]taxnetx [profits]year [profits]wagegovt [profits]capital1 [profits]L.totinc"}{p_end}
{phang2}. {stata "test [wagetot]govt [wagetot]taxnetx [wagetot]year [wagetot]wagegovt [wagetot]capital1 [wagetot]L.totinc, accum"}{p_end}

{phang2}. {stata "ranktest (profits wagetot) (govt taxnetx year wagegovt capital1 L.totinc), partial(L.profits) wald null "}{p_end}

{pstd}
Equality of rk statistic of null rank and Wald test from OLS regressions and {cmd:suest}.
To show equality, use {cmd:suest} to test joint significance of Z variables in both regressions.
L.profits is the partialled-out variable and is not tested.
Note that {cmd:suest} introduces a finite sample adjustment of (N-1)/N.

{phang2}. {stata "qui regress profits govt taxnetx year wagegovt capital1 L.totinc L.profits"}{p_end}
{phang2}. {stata "est store e1"}{p_end}
{phang2}. {stata "qui regress wagetot govt taxnetx year wagegovt capital1 L.totinc L.profits"}{p_end}
{phang2}. {stata "est store e2"}{p_end}
{phang2}. {stata "qui suest e1 e2"}{p_end}
{phang2}. {stata "qui test [e1_mean]govt [e1_mean]taxnetx [e1_mean]year [e1_mean]wagegovt [e1_mean]capital1 [e1_mean]L.totinc"}{p_end}
{phang2}. {stata "test [e2_mean]govt [e2_mean]taxnetx [e2_mean]year [e2_mean]wagegovt [e2_mean]capital1 [e2_mean]L.totinc, accum"}{p_end}
{phang2}. {stata "di r(chi2)*e(N)/(e(N)-1)"}{p_end}

{phang2}. {stata "ranktest (profits wagetot) (govt taxnetx year wagegovt capital1 L.totinc), partial(L.profits) wald null robust"}{p_end}

{pstd}
The test for a rank reduction of 2 (rank=1)
is the Arellano-Hansen-Sentana (2012) I test for underidentification:

{phang2}. {stata "ranktest (consump profits wagetot) (govt taxnetx year wagegovt capital1 L.totinc), partial(L.profits) robust bw(2) jcue rr(2)"}{p_end}


{marker replication}{title:Replication: Manresa et al. (2017)}

{bf:Testing for reduced rank in an asset pricing model.}

{pstd}
Manresa et al. (2017) present an application using Yogo's (2006) data
with 3 observable risk factors
and quarterly returns on the Fama-French cross-section of 25 portfolios
for the period 1951-2001.
GMM CUE J-based tests below of rank 1, 2, and 3 correspond to
sets of stochastic discount factors (SDFs) of dimension 3, 2 and 1, respectively
and replicate the results they present in their Table 1.
A vector of ones (i.e., a constant) is explicitly included along with the 3 risk factors.
Note that in the last specification the vector of ones is included in {it:both} the Y and Z varlists.
Tests use a heteroskedastic- and autocorrelation-consistent VCE
with centered moments and a Bartlett kernel with bandwidth=2.
The {opt noevorder} option is used when replicating the coefficients
in order to control which variables are treated as dependent variables/endogenous regressors
in the underlying CUE GMM estimations.
The rejection of rank=1 (dimension=3)
and the failure to reject rank=2 (dimension=2)
at conventional levels
suggest the admissible SDFs lie in a two-dimensional subspace
(Manresa et al. 2017, p. 16).
The fact that the null of zero means of the SDFs is not rejected (p=0.494)
suggests the model is completely overspecified,
where "overspecified" means the model has "at least one non-zero SDF which is uncorrelated
with the excess returns on the vector of test assets" (Manresa et al. 2017, p. 1).

{pstd}
Note that although the first estimation replicates the Manresa et al. results,
the resulting test statistic for rank=1 (dimension 3) is actually a local minimum.
The second estimation uses the default initial 2SLS beta
instead of the optional LIML beta
and achieves a smaller value for the rank=1 test in this case.

{phang2}. {stata `"import excel "https://www.dropbox.com/s/roxp36yyzjw93kb/fr.xls?dl=1", first clear"'}{p_end}
{phang2}. {stata "gen int t = _n"}{p_end}
{phang2}. {stata "tsset t"}{p_end}
{phang2}. {stata "gen byte one = 1"}{p_end}

{pstd}Replicate J statistics reported in "Criterion" row of Table 1 of Manresa et al. (2017):{p_end}
{phang2}. {stata "ranktest (one f1-f3) (r1-r25), jcue noconstant rob bw(2) center nodots binit(liml)"}{p_end}

{pstd}Test statistic for rank=1 is smaller than that reported in Table 1 of Manresa et al. (2017):{p_end}
{phang2}. {stata "ranktest (one f1-f3) (r1-r25), jcue noconstant rob bw(2) center nodots"}{p_end}

{pstd}Replicate coefficients #1 and #2 in first column in "Two-dimensional Set" of Table 1:{p_end}
{phang2}. {stata "qui ranktest (one f3 f1 f2) (r1-r25), jcue rr(2) noconstant rob bw(2) center noevorder"}{p_end}
{phang2}. {stata "mat b_cf1f2 = r(b)"}{p_end}
{phang2}. {stata "mat b_cf1f2 = b_cf1f2[1,1..2]"}{p_end}
{phang2}. {stata "mat list b_cf1f2"}{p_end}

{pstd}Replicate coefficients #1 and #3 in second column in "Two-dimensional Set" of Table 1:{p_end}
{phang2}. {stata "qui ranktest (one f2 f1 f3) (r1-r25), jcue rr(2) noconstant rob bw(2) center noevorder"}{p_end}
{phang2}. {stata "mat b_cf1f3 = r(b)"}{p_end}
{phang2}. {stata "mat b_cf1f3 = b_cf1f3[1,1..2]"}{p_end}
{phang2}. {stata "mat list b_cf1f3"}{p_end}

{pstd}Replicate all 4 p-values in third column in "Two-dimensional Set" of Table 1,:{p_end}
{pstd}First obtain and save J statistic for full model.{p_end}
{phang2}. {stata "qui ranktest (one f3 f1 f2) (r1-r25), jcue rr(2) noconstant rob bw(2) center"}{p_end}
{phang2}. {stata "scalar jfull = r(chi2)"}{p_end}
{pstd}Report p-values from GMM distance tests for f1, f2, f3 and c_i (means of SDFs):{p_end}
{phang2}. {stata "qui ranktest (one f2 f3) (r1-r25), jcue rr(2) noconstant rob bw(2) center"}{p_end}
{phang2}. {stata "di chi2tail(2,r(chi2)-jfull)"}{p_end}
{phang2}. {stata "qui ranktest (one f1 f3) (r1-r25), jcue rr(2) noconstant rob bw(2) center"}{p_end}
{phang2}. {stata "di chi2tail(2,r(chi2)-jfull)"}{p_end}
{phang2}. {stata "qui ranktest (one f1 f2) (r1-r25), jcue rr(2) noconstant rob bw(2) center"}{p_end}
{phang2}. {stata "di chi2tail(2,r(chi2)-jfull)"}{p_end}
{phang2}. {stata "qui ranktest (one f1 f2 f3) (one r1-r25), jcue rr(2) noconstant rob bw(2) center"}{p_end}
{phang2}. {stata "di chi2tail(2,r(chi2)-jfull)"}{p_end}


{marker s_refs}{title:References}

{p 0 4}Anderson, T.W. 1951. Estimating linear restrictions on regression coefficients
for multivariate normal distributions. Annals of Mathematical Statistics, Vol. 22, pp. 327-51.

{p 0 4}Arellano, M., Hansen, L.P., and Sentana, E. 2012.
Underidentification? Journal of Econometrics, Vol. 170, pp. 256-280.

{p 0 4}Cragg, J.G. and Donald, S.G. 1993. Testing Identfiability and Specification in
Instrumental Variables Models. Econometric Theory, Vol. 9, pp. 222-240.

{p 0 4}Cragg, J.G. and Donald, S.G. 1997. Inferring the Rank of a Matrix.
Journal of Econometrics, Vol. 76, pp. 223-250.

{p 0 4}Kleibergen, F. and Paap, R.  2006.  Generalized Reduced Rank Tests Using the Singular Value Decomposition.
Journal of Econometrics, Vol. 133, pp. 97-126.

{p 0 4}Manresa, E., F. Penaranda and E. Sentana. 2017.
Empirical evaluation of overspecified asset pricing models.
{browse "https://ideas.repec.org/p/cmf/wpaper/wp2017_1711.html":CEMFI Working Papers 1711, CEMFI, Madrid},
and {browse "https://ideas.repec.org/p/cpr/ceprdp/12085.html":CEPR Discussion Paper Series No. DP12085, CEPR, London}.

{p 0 4}Windmeijer, F. 2018. Testing Over- and Underidentification in Linear Models,
with Applications to Dynamic Panel Data and Asset-Pricing Models.
{browse "https://ideas.repec.org/p/bri/uobdis/18-696.html":Bristol Economics Discussion Papers 18/696}.

{p 0 4}Yogo, M. 2006. A consumption-based explanation of expected stock returns.
Journal of Finance, Vol. 61, pp. 539-580.


{marker s_acknow}{title:Acknowledgements}

{p}We would like to thank Kit Baum and Austin Nichols for helpful suggestions and feedback
on the original version of {opt ranktest}.


{marker s_citation}{title:Citation of ranktest}

{p}{cmd:ranktest} is not an official Stata command. It is a free contribution
to the research community, like a paper. Please cite it as such: {p_end}

{phang}Kleibergen, F., Schaffer, M.E. 2020, Windmeijer, F.
ranktest: module for testing the rank of a matrix
{browse "http://ideas.repec.org/c/boc/bocode/s456865.html":http://ideas.repec.org/c/boc/bocode/s456865.html}{p_end}


{title:Authors}

	Frank Kleibergen, University of Amsterdam, Netherlands
	F.R.Kleibergen@uva.nl

	Mark E Schaffer, Heriot-Watt University, UK
	m.e.schaffer@hw.ac.uk
	
	Frank Windmeijer, Oxford University, UK
	frank.windmeijer@stats.ox.ac.uk


{title:Also see}

{p 1 14}Manual:  {hi:[R] canon}{p_end}

{p 1 10}On-line: help for {help canon}, {help vecrank}, {help avar}, {help ivreg2} (if installed){p_end}
