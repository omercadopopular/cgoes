{smcl}
{* 01dec2017}{...}
{cmd:help xtscc}{right:version:  1.4{space 17}}
{right:also see:  {helpb xtscc postestimation}}
{hline}

{title:Title}

{p 4 8}{cmd:xtscc}  -  Regression with Driscoll-Kraay standard errors{p_end}


{title:Syntax}

{p 8 14 2}
{cmd:xtscc}
{depvar}
[{indepvars}]
{ifin}
{weight}
[, {it:options}]


{synoptset 14 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Model}
{synopt:{opt lag:(#)}}set maximum lag order of autocorrelation; default is m(T)=floor[4(T/100)^(2/9)]{p_end}
{synopt:{opt fe:}}perform fixed effects (within) regression{p_end}
{synopt:{opt re:}}perform GLS random effects regression{p_end}
{synopt:{opt pool:ed}}perform pooled OLS/WLS regression; default{p_end}
{synopt:{opt noc:onstant}}suppress regression constant in pooled OLS/WLS regressions{p_end}
{synopt:{opt ase}}return (asymptotic) Driscoll-Kraay SE without small sample adjustment{p_end}

{syntab:Reporting}
{synopt:{opt l:evel(#)}}set confidence level; default is {cmd:level(95)}{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
{p_end}
{p 4 6 2}
You must {helpb tsset} your data before using {opt xtscc}.{p_end}
{p 4 6 2}
{opt by}, {opt statsby}, and {opt xi} may be used with
{opt xtscc}; see {help prefix}.{p_end}
{p 4 6 2}{indepvars} may contain factor variables; see {help fvvarlist}.{p_end}
{p 4 6 2}{depvar} and {indepvars} may contain time-series operators; see {help tsvarlist}.{p_end}
{p 4 6 2}{opt aweight}s are allowed.{p_end}
{p 4 6 2}
See {help xtscc postestimation} for features available after estimation.{p_end}



{title:Description}

{p 4 4 2}
{opt xtscc} produces Driscoll and Kraay (1998) standard errors for coefficients 
estimated by pooled OLS/WLS, fixed-effects (within), or GLS random effects 
regression. {opt depvar} is the dependent variable and {opt varlist} is an 
(optional) list of explanatory variables.{p_end}

{p 4 4 2}
The error structure is assumed to be heteroskedastic, autocorrelated up to 
some lag, and possibly correlated between the groups (panels). Driscoll-Kraay 
standard errors are robust to very general forms of cross-sectional ("spatial") 
and temporal dependence when the time dimension becomes large. This nonparametric 
technique of estimating standard errors does not place any restrictions on the 
limiting behavior of the number of panels. Consequently, the size of the 
cross-sectional dimension in finite samples does not constitute a constraint on 
feasibility - even if the number of panels is much larger than T. However, note 
that the estimator is based on large T asymptotics. Therefore, one should 
be somewhat cautious with applying this estimator to panel datasets with a large
number of groups but a small number of observations over time.{p_end}

{p 4 4 2}
This implementation of Driscoll and Kraay's covariance estimator works for both, 
balanced and unbalanced panels, respectively. Furthermore, it is capable to handle
missing values.{p_end}


{title:Options}

{dlgtab:Model}

{phang}
{opt lag(#)} specifies the maximum lag to be considered in the autocorrelation
   structure.  If you do not specify this option, a lag length of
   m(T)=floor[4(T/100)^(2/9)] is chosen.

{phang}
{opt fe} performs fixed-effects (within) regression with Driscoll-Kraay standard errors. 

{phang}
{opt re} performs GLS random-effects (RE) regression with Driscoll-Kraay standard errors.
	 
{phang}
{opt pool:ed} performs pooled OLS/WLS regression with Driscoll-Kraay standard errors. 
   
{phang}
{opt noc:onstant}; see {help estimation options:[R] estimation options}.

{phang}
{opt ase} returns asymptotic Driscoll-Kraay standard errors. Standard errors that
are computed this way might be slightly overoptimistic as they abstract from 
a small sample adjustment.


{dlgtab:Reporting}

{phang}
{opt level(#)}; see {help estimation options##level():estimation options}.



{title:Examples}

{phang}{stata "sysuse grunfeld" : . sysuse grunfeld}

{p 4 4 2}{it:Pooled OLS estimation:}{p_end}

{phang}{stata "reg invest mvalue kstock, robust cluster(company)" : . reg invest mvalue kstock, robust cluster(company)}{p_end}
{phang}{stata "est store robust" : . est store robust}{p_end}

{phang}{stata "newey invest mvalue kstock, lag(4) force" : . newey invest mvalue kstock, lag(4) force}{p_end}
{phang}{stata "est store newey" : . est store newey}{p_end}

{phang}{stata "xtscc invest mvalue kstock, lag(4)" : . xtscc invest mvalue kstock, lag(4)}{p_end}
{phang}{stata "est store dris_kraay" : . est store dris_kraay}{p_end}

{phang}{stata "est table *, b se t" : . est table *, b se t}{p_end}

{p 4 4 2}{it:Fixed-effects (within) regression:}{p_end}

{phang}{stata "est clear" : . est clear}{p_end}
{phang}{stata "xtreg invest mvalue kstock, fe robust" : . xtreg invest mvalue kstock, fe robust}{p_end}
{phang}{stata "est store fe_robust" : . est store fe_robust}{p_end}

{phang}{stata "xtscc invest mvalue kstock, fe lag(4)" : . xtscc invest mvalue kstock, fe lag(4)}{p_end}
{phang}{stata "est store fe_dris_kraay" : . est store fe_dris_kraay}{p_end}

{phang}{stata "est table *, b se t" : . est table *, b se t}{p_end}


{p 4 4 2}{it:GLS random-effects regression:}{p_end}

{phang}{stata "est clear" : . est clear}{p_end}
{phang}{stata "xtreg invest mvalue kstock, re robust" : . xtreg invest mvalue kstock, re robust}{p_end}
{phang}{stata "est store re_robust" : . est store re_robust}{p_end}

{phang}{stata "xtscc invest mvalue kstock, re lag(4)" : . xtscc invest mvalue kstock, re lag(4)}{p_end}
{phang}{stata "est store re_dris_kraay" : . est store re_dris_kraay}{p_end}

{phang}{stata "est table *, b se t" : . est table *, b se t}{p_end}


{title:Reference}

{p 4 6 2}
 - Driscoll, John C. and Aart C. Kraay, 1998, Consistent Covariance Matrix
       Estimation with Spatially Dependent Panel Data, {it:Review of Economics and Statistics}
       80, 549-560.{p_end}


{title:Notes}

{p 4 6 2}
- The main procedure of {opt xtscc} is implemented in Mata and largely follows
Driscoll and Kraay's GAUSS program which is available from 
{browse www.johncdriscoll.net/:http://www.johncdriscoll.net/}.{p_end}
{p 4 6 2}
- The {cmd:xtscc} program uses functions from Ben Jann's {cmd:moremata} package.{p_end}
{p 4 6 2}
- Weighted estimation in the case of fixed effects and (feasible) GLS random effects estimation 
is based on a within transform similar to that of official Stata's -areg- command. Note 
that -xtreg, fe- currently cannot estimate fixed effects regressions with 
time-varying weights, and -xtreg, re- does not allow for weights at all.


{title:Acknowledgements}

{p 4 4}
I would like to thank Sergio Correia, David M. Drukker, Bill Gould, and Gustavo Sanchez
for their useful comments and suggestions.


{title:Author}

{p 4 4}Daniel Hoechle, FHNW School of Business, daniel.hoechle@fhnw.ch{p_end}



{title:Also see}

{psee}
Manual:  {bf:[R] regress}, {bf:[TS] newey}, {bf:[XT] xtreg}, {bf:[R] areg}

{psee}
Online:  {help xtscc postestimation};{break}
{helpb tsset}, {helpb regress}, {helpb newey}, {helpb xtreg}, {helpb areg}, {helpb _robust}
{p_end}

