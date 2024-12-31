{smcl}


{marker drdid-doubly-robust-difference-in-differences-estimators}{...}
{title:{cmd:drdid} Doubly Robust Difference-in-Differences Estimator}


{marker syntax}{...}
{title:Syntax}

{text}{phang2}{cmd:drdid}
  {depvar} [{indepvars}]
 [{it:if}] [{it:in}] [{weights}], 
 [{opt i:var}({it:varname})] 
 {opt t:ime} ({it:varname}) {opt tr:eatment}({it:varname}) 
 [{it: options} ]{p_end}

{marker options}{...}
{title:Options}

{synoptset 20 tabbed}{...}

{syntab:{bf: Model Specification}}
{synopthdr}
{synoptline}
{synopt :{opt depvar}} Declares the dependent variable of outcome of interest. {p_end}
{synopt :{opt indepvar}} Declares the independent variable or controls. Depending
on the estimation method, all declared variables will be used for the outcome regression model, 
the propensity score estimator, or both. {p_end}

{syntab:{bf: DiD Model Specification}}
{synopthdr}
{synoptline}
{synopt:{opt i:var}} Variable used as panel identifier. e.g., {it:country}. When declared, the model assumes the data 
has a panel structure, and will apply panel estimators. When no variable is declared the command assumes data are
 repeated crosssection (RC), and applies RC estimators. {p_end}
{synopt:{opt t:ime}} Variable to identify time. e.g., {it:year}. Periods do not need to be consecutive, but
it is expected to be strictly positive. It is also recommended periods have regular gaps. {p_end}
{synopt:{opt tr:eatment}} Categorical variable identifying the control and treated group. It does not 
required to be coded as 0 and 1. However, lower value is assumed to be the control group, whereas
 the higher one is the treated group, given the effective sample. 
e.g., 1 control 3 treated group. {p_end}

{syntab:{bf: Estimation Method}:  }

{synopthdr}
{synoptline}
{synopt:drimp (default)} Sant’Anna and Zhao (2020) Improved doubly robust DiD estimator based on 
inverse probability of tilting and weighted least squares. {p_end}
{synopt:} Available for both Panel and Repeated Crossection {p_end}

{synopt:dripw} Sant’Anna and Zhao (2020) doubly robust DiD estimator based on stabilized 
inverse probability weighting and ordinary least squares{p_end}
{synopt:} Available for both Panel and Repeated Crossection {p_end}

{synopt:reg} Outcome regression DiD estimator based on ordinary least squares {p_end}

{synopt:} Available for both Panel and Repeated Crossection {p_end}

{synopt:stdipw} Inverse probability weighting DiD estimator with stabilized weights{p_end}
{synopt:} Available for both Panel and Repeated Crossection {p_end}

{synopt:ipw}Abadie (2005) inverse probability weighting DiD estimator{p_end}
{synopt:} Available for both Panel and Repeated Crossection {p_end}

{synopt:ipwra}Inverse-probability-weighted regression adjustment (via teffects){p_end}
{synopt:} Available for Panel data only{p_end}

{synopt:rc1} In combination with the methods {cmd drimp} and {cmd dripw}, this option request the doubly robust
but not locally efficient repeated crossection estimtors. Not available when using panel data. 

{synopt:{bf:all}}Request the computation of all Estimators available for the data structure.{p_end}
{synopt:}This option is only for robusness purposes. One cannot use them to make test across estimations{p_end}
{synoptline}

{syntab:{bf: Standard Error Options}}

{phang}By default, robust and asymptotic standard errors are estimated, using Influence Functions.
 However other options are available. {p_end}

{synopthdr}
{synoptline}

{synopt:wboot}Request estimation of Standard errors using a multiplicative WildBootstrap procedure.
The default uses 999 repetitions using mammen approach{p_end}

{synopt:wboot(options)}Request estimation of Standard errors using a multiplicative WildBootstrap procedure.
allowing to change default options. {p_end}
{synopt:  reps(#)}Specifies the number of repetitions to be used for the Estimaton of the WBoot SE. Default is 999 {p_end}
{synopt:  wtype(type)}Specifies the type of Wildbootstrap procedure. The default is "mammen", but "rademacher" is also 
avilable.{p_end}

{synopt:rseed(#)}Specifies the seed for the WB procedure. Use for replication purposes.{p_end}

{synopt:gmm}Request the estimation of the DID ATT's using generalized method of moments. {p_end}

{synopt:vce(opt)}When the model is estimated via {help gmm}, one can also request alternative Standard Errors. 
See -gmm- for details. The default Standard errors should the the same as default standard errors. {p_end}

{synopt:cluster(clust var)}Request the estimation of Clustered Standard errors. This option is for asymptotic Standard errors,
Wbootstrap Standard errors, and GMM.{p_end}
{synopt:}Remark 1. When Panel estimators are used, asymptotic and Wbootstrap Standard errors are already clustered at the panel level.
When using cluster, one is effectively requesting a two-way cluster estimation.{p_end}
{synopt:}Remark 2. When Panel estimators are used, The panel id (ivar) should be nested within cluster{p_end}

{synopt:level(#)}Sets the confidence levels for the estimation of confidence intervals. Default is 95 {p_end}

{syntab:{bf: Other Options}}

{synopthdr}
{synoptline}

{synopt:stub(str)}Request the command to save a variable in the dataset under the neame {it:stub}att. This 
variable contains the Recentered Influence function associated with the DID ATT. {p_end}

{synopt:}This option is not available when estination methods {it:ipwra} or {it:all} are requested. {p_end}

{synopt:replace}If the variable {it:stub}att already exists. This option requests replacing it.{p_end}

{synopt:noisily}Request displaying all intermediate steps for the estimators. Not available with -ipwra-{p_end}

{phang}While the estimator is recorded as importance weights (iweights), weights are treated as pweights internally.{p_end}

{marker description}{...}
{title:Description}

{pstd}{cmd:drdid} implements the locally efficient doubly robust difference-in-differences (DiD) estimators
 for the average treatment effect proposed by Sant'Anna and Zhao (2020). It also implements the IPW and Outcome
 regression estimators for the DiD ATT.{p_end}
 
{pstd}{cmd:drdid} Doubly robust estimators combines inverse probability weighting and 
 outcome regression estimators to form estimators with more attractive statistical properties.
 Namely, it the estimator is appropriate if either the propensity of treatment, or the outcome regression
 is correctly specified.  {p_end}
 
{pstd}
It is also important to consider that the Panel data estimators assume that you are using time invariant variables.
Even if those variables are time variant, only the pretreatment values are used for the outcome model estimator or
the probability model estimation.
{p_end}

{pstd}
When repeated crosssection data is used, it is possible to use controls that vary across time are. 
The underlying assumption is that control variables should be time constant. Sant'Anna and Zhao (2020) describes this 
as stationarity assumption. 
{p_end}

{pstd}
It is possible to add time varying covariates with panel data estimators, adding covariate changes as controls, in addition to the 
pretreatment covariates. However, unless the controls are strictly exogenous (strong assumption), this may produce 
inconsistent results, because the changes that would otherwise be capture in the ATT would be absorbed by the varying covariates. 

{marker Postestimation}{...}
{title:Postestimation}

{pstd}It is possible to show the contents of the intermediate results, using the command:

{phang2}{cmd: drdid_display}, bmatrix(name) vmatrix(name) {p_end}

{pstd}For all estimation metods except -ipwra-, it is also possible request the generation
of the IPW weights, or the propensity score using the following command:{p_end}

{phang2}{cmd: drdid_predict} {it:newvarname}, [weight pscore] {p_end}


{marker remarks}{...}
{title:Remarks}

{pstd}In addition to the ATT and standard errors, the command also returns, 
as part of {cmd:e()}, the coefficients and variance covariance matrixes associated with all intermediate sets. 
See {cmd:ereturn list} after running the command. {p_end}




{marker examples}{...}
{title:Examples}

{phang}
{stata "use https://friosavila.github.io/playingwithstata/drdid/lalonde.dta, clear"}

{pstd}Panel estimator with default {bf:drimp} method{p_end}

{phang}
{stata drdid re age educ black married nodegree hisp re74 if treated==0 | sample==2, ivar(id) time(year) tr(experimental) }

{pstd}Panel estimator using all estimators {p_end}

{phang}
{stata drdid re age educ black married nodegree hisp re74 if treated==0 | sample==2, ivar(id) time(year) tr(experimental) all}

{pstd}Repeated crosssection using all estimators {p_end}

{phang}
{stata drdid re age educ black married nodegree hisp re74 if treated==0 | sample==2,  time(year) tr(experimental) all}

{pstd}Requesting Repeated crosssection estimators with cluster SE using ID{p_end}

{phang}
{stata drdid re age educ black married nodegree hisp re74 if treated==0 | sample==2, cluster(id) time(year) tr(experimental) dripw}

{pstd}Requesting Panel estimators with wild bootstrap standard errors {p_end}

{phang}
{stata drdid re age educ black married nodegree hisp re74 if treated==0 | sample==2, ivar(id) time(year) tr(experimental) dripw wboot }

{marker authors}{...}
{title:Authors}

{pstd}
Fernando Rios-Avila{break}
Levy Economics Institute of Bard College{break}
Annandale-on-Hudson, NY{break}
friosavi@levy.org

{pstd}Pedro H. C. Sant'Anna {break}
Vanderbilt University{p_end}

{pstd}Asjad Naqvi {break}
International Institute for Applied Systems Analysis


{marker references}{...}
{title:References}

{phang2}Abadie, Alberto. 2005. 
"Semiparametric Difference-in-Differences Estimators." 
{it:The Review of Economic Studies} 72 (1): 1–19.{p_end}

{phang2}Sant’Anna, Pedro H. C., and Jun Zhao. 2020. 
"Doubly Robust Difference-in-Differences Estimators." 
{it:Journal of Econometrics} 219 (1): 101–22.{p_end}

{phang2}Rios-Avila, Fernando, 
Pedro H. C. Sant'Anna, and Asjad Naqvi 2021.
 “DRDID: Doubly Robust Difference-in-Differences Estimators for Stata.” SSC
{p_end}

{marker aknowledgement}{...}
{title:Aknowledgement}

{pstd}This command was built using the DRDID command from R as benchmark, originally written by Pedro Sant'Anna. 
Many thanks to Pedro for helping understanding the inner workings on the estimator.{p_end}

{pstd}Thanks to Asjad for starting this small project challenge.{p_end}

{pstd}Further thanks to Enrique, who helped with the gmm estimator and displaying set up{p_end}

{pstd}Also thank you to Miklos Koren, for helping setting up the original helpfile and github repository {p_end}

{pstd}If you use this package, please cite:{p_end}

{phang2}Sant'Anna, Pedro H. C., and Jun Zhao. 2020. 
"Doubly Robust Difference-in-Differences Estimators." 
{it:Journal of Econometrics} 219 (1): 101–22.{p_end}


{title:Also see}

{p 7 14 2}
Help:  {help csdid}, {help didregress}, {help xtdidregress} {p_end}


