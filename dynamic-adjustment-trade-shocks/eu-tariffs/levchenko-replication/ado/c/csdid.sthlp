{smcl}


{title:{cmd:csdid}: Difference in Difference with Multiple periods estimator}


{marker syntax}{...}
{title:Syntax}

{text}{phang2}{cmd:csdid}
  {depvar} [{indepvars}]
 [{it:if}] [{it:in}] {weight}, 
 [{opt i:var}({it:varname})] 
 {opt t:ime}({it:varname}) {opt gvar}({it:varname}) 
 [{it: options} ]{p_end}

{marker options}{...}
{title:Options}

{synoptset 20 tabbed}{...}

{syntab:{bf: Model Specification}}
{synopthdr}
{synoptline}
{synopt :{opt depvar}} Declares the dependent variable or outcome of interest. {p_end}
{synopt :{opt indepvar}} Declares the independent variable or controls. Depending
on the estimation method, all declared variables will be used for the outcome regression model, 
the propensity score estimator, or both. {p_end}
{synopt :} One can use factor notation. Only base period values are used in the model estimation. {p_end}
{synoptline}

{syntab:{bf: DiD Model Specification}}
{synopthdr}
{synoptline}
{synopt:{opt i:var(varname)}} Variable used as panel identifier. e.g., {it:country}. When declared, the model assumes the data 
has a panel structure, and will apply panel estimators. When no variable is declared the command assumes data are
 repeated crosssection (RC), and applies RC estimators. {p_end}
 
{synopt:{opt t:ime(varname)}} Variable to identify time. e.g., {it:year}. Periods do not need to be consecutive, but
the variable is expected to be strictly positive, with regular gaps. {p_end}

{synopt:{opt gvar(varname)}} Variable identifying treatment groups or cohorts. Groups that are never treated should be coded as Zero. 
Any positive value indicates which year a group was initially treated. And once a group is treated, the underlying assumption
is that it always remains treated. {p_end}

{synopt:} e.g., 0 Never treated, 10 treat at t=10, 20 treated at time 20, 25 treated at time 25. {p_end}

{synopt:} If there are any groups treated before the first available period in the sample, those observations are 
considered always treated, and are excluded from the sample. {p_end}

{synopt:} For every cohort in {it:gvar} there should be a period in {it:time} otherwise, the command will produce an error. Also, you should have data for the period before treatment. For example, if data is annual, and observations were treated in 2010, you need to have data for this group in 2009. Otherwise ATTGT's cannot be identified.{p_end}

{synopt:} When using panel data, observations cannot change cohort across time. {p_end}

{synopt:{opt notyet}} Request using observations never treated and those not yet treated as control group. 
The default is using never treated only. If there are no {it:never treated} observations, notyet is used automatically.{p_end}

{synopt:{opt long}}For periods before treatment, this option requests the estimation of Long gaps, rather 
than short-gaps.{p_end}

{synopt:{opt long2}}For periods before treatment, this option requests the estimation of Long gaps, rather 
than short-gaps. This is similar to base universal. (inverse sign from long){p_end}

{synopt:{opt asinr}}In R's version (DID), pre-treatment ATTGT's using not-yet-treated groups are estimated using all cohorts not-yet treated. 
In Stata, the default is to use all cohorts that were not treated at time G. Both options are valid, but if one wants to replicate R results, -asinr- should be used.{p_end}

{synoptline}
{syntab:{bf: Estimation Method} }

{phang}
{cmd: csdid} is a generalization of {help drdid}, and as such it allows for various estimators.
It estimates every feasible 2x2 DiD design available in the selected sample. 
{p_end}

{phang}
In all cases, the earliest-period covariates are used for the estimation of the propensity score and outcome regressions. This is the base period for all post treatment ATTGTs and T for all pre-treatment ATTGTs.
{p_end}

{phang}
To specify a particular syntax, one should use the option {cmd: method({it:method})} using one of the following key words:
{p_end}


{synopthdr}
{synoptline}
{synopt:drimp}Sant’Anna and Zhao (2020) Improved doubly robust DiD estimator based on 
inverse probability of tilting and weighted least squares. {p_end}

{synopt:dripw (default)}Sant’Anna and Zhao (2020) doubly robust DiD estimator based on stabilized 
inverse probability weighting and ordinary least squares. {p_end}

{synopt:reg}Outcome regression DiD estimator based on ordinary least squares. When no covariates are specified, this 
method is used as default, because it provides the same point estimates and standard errors. {p_end}

{synopt:stdipw}Inverse probability weighting DiD estimator with stabilized weights{p_end}

{synopt:ipw}Abadie (2005) inverse probability weighting DiD estimator. May not perform well with unbalanced panel data{p_end}

{synopt:rc1}In combination with the methods {cmd drimp} and {cmd dripw}, this option request the doubly robust
but not locally efficient repeated crossection estimators. Not available when using panel data. 


{synoptline}

{syntab:{bf: Standard Error Options}}

{phang}By default, robust and asymptotic standard errors are estimated, which are obtained using Influence Functions.
 However other options are available. {p_end}

{synopthdr}
{synoptline}

{synopt:wboot}Request Estimation of Standard errors using a multiplicative WildBootstrap procedure.
The default uses 999 repetitions using mammen approach. {p_end}

{synopt:wboot(Options)} Request Estimation of Standard errors using a multiplicative WildBootstrap procedure, and allows to change default options {p_end}
{synopt:-   reps(#)}Specifies the number of repetitions to be used for the Estimation of the WBoot SE. Default is 999 {p_end}

{synopt:-   wtype(type)}Specifies the type of Wildbootstrap procedure. The default is "mammen", but "rademacher" is also 
avilable.{p_end}

{synopt:rseed(#)}Specifies the seed for the WB procedure. Use for replication purposes.{p_end}

{synopt:cluster(clust var)}Request the estimation of Clustered Standard errors. This option is valid for asymptotic Standard errors,
and Wbootstrap Standard errors.{p_end}

{synopt:}Remark 1. When Panel estimators are used, asymptotic and Wbootstrap Standard errors are already clustered at the panel level.
When using cluster, one is effectively requesting a two-way cluster estimation.{p_end}
{synopt:}Remark 2. When Panel estimators are used, The panel id should be nested within the cluster variable . (ivar) {p_end}

{synopt:level(#)}Request changing the confidence level (default 95) for the estimation of Confidence Intervals.{p_end}

{synopt:pointwise}Request producing pointwise CI, when requesting Wildbootstrap SE. The default is to request Uniform Confidence Intervals.{p_end}

{synoptline}

{syntab:{bf: Other Options}}

{synopthdr}
{synoptline}

{synopt:saverif(filename)}Request the command to save the RIFs for all the DID ATT into a dataset name {it:filename}. 
It requires a new dataset unless option {cmd: replace} is used. {p_end}
{synopt:}In addition to the ATT's RIFs, the file also contains the RIFs for the weights that are used for aggregations. {p_end}

{synopt:replace}In combination with {cmd:saverif()}, requests replacing the file if it already exists {p_end}

{synopt:}Remark 1: This option can be combined with wildbootstrap standard errors. {p_end}
{synopt:}Remark 2: This option is used as an alternative to -estimates save-, so you can request other aggregations
or SE after the model has been estimated. {p_end}

{synopt:agg(aggtype)}This option can be used to produce different aggregations as the command output. The default is 
{cmd: attgt}, which produces the ATT for a particular cohort, and a particular period. Other options are: {p_end}

{synopt:simple}Estimates the ATT for all groups across all periods {p_end}

{synopt:group}Estimates the ATT for each group or cohort, across all periods {p_end}

{synopt:calendar}Estimates the ATT for each period, across all groups or cohorts {p_end}

{synopt:event}Estimates the dynamic ATT's. ATT's are estimated for each period relative to the 
period first treated, across all cohorts.{p_end}

{synoptline}
{phang}While weights are taken as iweights, weights are treated as pweights internally.{p_end}

{marker description}{...}
{title:Description}

{pstd}{cmd:csdid} implements the DiD with multiple periods estimator proposed by Callaway and Sant'Anna (2021). {p_end}

{pstd}Internally, all 2x2 DiD estimates (ATTGT's) are obtained using -drdid-. Thus {cmd: csdid} works as a wrapper
that determines all relevant designs and aggregates them. {p_end}
 
{pstd}As in -drdid-, the underlying assumption is that all covariates are time constant. When using panel data, 
even if covariates are time-varying, only the base-period (earlier-period) values are used for the estimation. 
{p_end}
 
{pstd}
When using crossection data, while all characteristics can be considered time-varying, the underlying assumption is that 
within treated and untreated group, characteristics are stationary (time constant). In other words, 
be careful of controlling for characteristics that are either time constant (e.g. sex or race), or for 
pretreatment characteristics.
{p_end}
 
{pstd}
The intuition behind Callaway and Sant'Anna (2021) estimator is that in order to obtain consistent estimators for ATT's
one should only use never-treated or not-yet treated units as controls. Otherwise, under heterogeneous treatment effects, 
the parallel trends assumption will be violated, and the estimations of the effects could be severely biased.
{p_end}

{pstd}
For the command to work, you need to have at least one period in the data for each group/cohort in gvar. You also require 
at least one pre-treatment period for each cohort/group, in order to estimate the ATT for that group.
{p_end}

{pstd}
From the perspective of the treated observations, all ATTGT's are estimated using the last not treated period as "base-period", and
using current period as the post period. 
{p_end}

{pstd}
For ATT's before the treatment took place, the command uses T-1 as the base period (or Pre-period), and T as the post-period. This corresponds to the {cmd short} pre-treatment gap.
{p_end}
{pstd}
When {cmd: long} gaps are requested, the ATT's before treatment took place uses T-1 as base period, and G-1 as the post period. where G is the first period a unit received treatment. One can also use {cmd long2}, which provides the same estimates but flipped sign. This is the closest to standard event study effects. The usually ommited parameter (T-1) is not calculated with csdid.
{p_end}

 
{pstd}
For ATT's after the treatment took place, the command uses G-1 as the base period (pre-treatment period) and T as the post-period.
{p_end}

{pstd}
Because the estimator attempts to estimate all ATTGT's for all groups across all periods, the implementation of this estimator 
for cross-section data with long time spans and many treated groups may not be feasible. For example, using 30 periods, with 20 potential 
groups would require the estimation of 600 separate regressions, and the creation of at least the same number of new variables
containing the RIF's for all ATTGT's, rapidly consuming the memory resources of commonly used computers. 
{p_end}

{pstd}
The best advice on these cases is to refine the treatment groups or cohorts, because not all of them may be relevant for your analysis. 
Additionally, you may not need ALL periods, requiring only few periods before the first treatment year.


{marker remarks}{...}
{title:Remarks}

{pstd}
When using panel data, the estimator does not require data to be strongly balanced. However, when estimating each ATTGT,
only observations that are balanced within a specific 2x2 designed are used for the estimator. You will see a warning if something like this is detected in the data.
{p_end}
{pstd}
This approach is in contrast with the default approach in R's DID. When unbalanced data exists, the default is to 
estimate the model using Repeated Crossection estimators. See the example below contrasting both approaches.
{p_end}
{pstd}
Even if WBootstrap SE are requested, asymptotic SE are stored in e().
{p_end}
{pstd}
Each succesful iteration is represented by a ".", whereas an "x" indicates for some ATT(G,T), the estimation failed.

{marker post_estimation}{...}
{title:Post Estimaton}

{pstd}
{cmd: csdid} offers three post estimation utilities. See {help csdid_postestimation} for more details.
{p_end}

{phang}{cmd: csdid_estat} For the estimation of aggregations and pretreatment tests.
{p_end}

{phang}{cmd: csdid_stats} For the estimation of aggregations and pretreatment tests using RIF files.
{p_end}

{phang}{cmd: csdid_plot} For the creating plots of the results.
{p_end}

{phang}{cmd: csdid_rif} This is a multiuse command. It can be used to produce results, including wildbootstrap tables, based on RIFs.

{p_end}

{marker examples}{...}
{title:Examples}

{phang}
{stata "use https://friosavila.github.io/playingwithstata/drdid/mpdta.dta, clear"}

{pstd}Estimation of all ATTGT's using Doubly Robust IPW (DRIPW) estimation method {p_end}

{phang}
{stata csdid  lemp lpop , ivar(countyreal) time(year) gvar(first_treat) method(dripw)}

{pstd}Estimation of all ATTGT's using Doubly Robust IPW (DRIPW) estimation method, with Wildbootstrap SE {p_end}

{phang}
{stata csdid  lemp lpop , ivar(countyreal) time(year) gvar(first_treat) method(dripw) wboot rseed(1)}

{pstd}Repeated crosssection estimator with Wildbootstrap SE{p_end}

{phang}
{stata csdid  lemp lpop , time(year) gvar(first_treat) method(dripw) wboot rseed(1)}

{pstd}Estimation of all Dynamic effects using Doubly Robust IPW (DRIPW) estimation method, with Wildbootstrap SE {p_end}

{phang}
{stata csdid  lemp lpop , ivar(countyreal) time(year) gvar(first_treat) method(dripw) wboot rseed(1) agg(event)}

{pstd}Estimation of all Dynamic effects using Doubly Robust IPW (DRIPW) estimation method, with Wildbootstrap SE, 
and not-yet treated observations as controls {p_end}

{phang}
{stata csdid  lemp lpop , ivar(countyreal) time(year) gvar(first_treat) method(dripw) wboot rseed(1) agg(event) notyet}

{pstd}Estimation of ATTGT's assuming unbalance panel data, with panel estimators {p_end}

{phang}
{stata set seed 1}{p_end}
{phang}
{stata gen sample = runiform()<.9}{p_end}
{phang}
{stata csdid  lemp lpop  if sample==1, ivar(countyreal) time(year) gvar(first_treat) method(dripw) }{p_end}

{pstd}Estimation of ATTGT's assuming unbalance panel data, with repeated crosssection estimators, but clustered SE{p_end}

{phang}
{stata csdid  lemp lpop  if sample==1, cluster(countyreal) time(year) gvar(first_treat) method(dripw) }

{marker authors}{...}
{title:Authors}


{pstd}
Fernando Rios-Avila{break}
Levy Economics Institute of Bard College{break}
Annandale-on-Hudson, NY{break}
friosavi@levy.org

{pstd}Pedro H. C. Sant'Anna {break}
Vanderbilt University{p_end}

{pstd}Brantly Callaway {break}
University of Georgia{p_end}

{marker references}{...}
{title:References}

{phang2}Abadie, Alberto. 2005. 
"Semiparametric Difference-in-Differences Estimators." 
{it:The Review of Economic Studies} 72 (1): 1–19.{p_end}

{phang2}Callaway, Brantly and Sant'Anna, Pedro H. C. 2021. 
"Difference-in-Differences with multiple time periods." , 225(2):200-230.
{it:Journal of Econometrics}.{p_end}

{phang2}Sant’Anna, Pedro H. C., and Jun Zhao. 2020. 
"Doubly Robust Difference-in-Differences Estimators." 
{it:Journal of Econometrics} 219 (1): 101–22.{p_end}


{phang2}Rios-Avila, Fernando, 
Pedro H. C. Sant'Anna, 
and Brantly Callaway, 2021.
 “CSDID: Difference-in-Differences with Multiple periods.” 
{p_end}

{marker aknowledgement}{...}
{title:Aknowledgement}

{pstd}This command was built using the DID command from R as benchmark, originally written by Pedro Sant'Anna and Brantly Callaway. 
Many thanks to Pedro and Brantly Callaway for helping to understand the inner workings of the estimator, .{p_end}

{pstd}Thanks to Enrique, who helped with the display set up{p_end}

{pstd}If you use this package, please cite:{p_end}

{phang2}Callaway, Brantly and Sant'Anna, Pedro H. C. 2021. 
"Difference-in-Differences with multiple time periods.", 
{it:Journal of Econometrics}, 225(2):200-230. {p_end}

{phang2}Sant'Anna, Pedro H. C., and Jun Zhao. 2020. 
"Doubly Robust Difference-in-Differences Estimators." 
{it:Journal of Econometrics} 219 (1): 101–22.{p_end}

{title:Also see}

{p 7 14 2}
Help:  {help drdid}, {help csdid}, {help csdid postestimation}, {help xtdidregress} {p_end}

