{smcl}
{* *! version 2.2.2  03sep2019}{...}
{* *! Sebastian Kripfganz, www.kripfganz.de}{...}
{vieweralsosee "xtdpdgmm postestimation" "help xtdpdgmm_postestimation"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] regress" "help regress"}{...}
{vieweralsosee "[R] ivregress" "help ivregress"}{...}
{vieweralsosee "[R] gmm" "help gmm"}{...}
{vieweralsosee "[XT] xtreg" "help xtreg"}{...}
{vieweralsosee "[XT] xtivreg" "help xtivreg"}{...}
{vieweralsosee "[XT] xtabond" "help xtabond"}{...}
{vieweralsosee "[XT] xtdpd" "help xtdpd"}{...}
{vieweralsosee "[XT] xtdpdsys" "help xtdpdsys"}{...}
{vieweralsosee "[XT] xtset" "help xtset"}{...}
{viewerjumpto "Syntax" "xtdpdgmm##syntax"}{...}
{viewerjumpto "Description" "xtdpdgmm##description"}{...}
{viewerjumpto "Options" "xtdpdgmm##options"}{...}
{viewerjumpto "Remarks" "xtdpdgmm##remarks"}{...}
{viewerjumpto "Example" "xtdpdgmm##example"}{...}
{viewerjumpto "Saved results" "xtdpdgmm##results"}{...}
{viewerjumpto "Version history and updates" "xtdpdgmm##update"}{...}
{viewerjumpto "Author" "xtdpdgmm##author"}{...}
{viewerjumpto "References" "xtdpdgmm##references"}{...}
{title:Title}

{p2colset 5 17 19 2}{...}
{p2col :{bf:xtdpdgmm} {hline 2}}GMM linear dynamic panel data estimation{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 16 2}{cmd:xtdpdgmm} {depvar} [{indepvars}] {ifin} [{cmd:,} {it:options}]


{synoptset 20 tabbed}{...}
{synopthdr:options}
{synoptline}
{syntab:Model}
{synopt:{opt iv}{cmd:(}{it:{help xtdpdgmm##options_spec:iv_spec}}{cmd:)}}standard instruments; can be specified more than once{p_end}
{synopt:{opt gmm:iv}{cmd:(}{it:{help xtdpdgmm##options_spec:gmmiv_spec}}{cmd:)}}GMM-type instruments; can be specified more than once{p_end}
{synopt:{opt nl}{cmd:(}{it:{help xtdpdgmm##options_spec:nl_spec}}{cmd:)}}add nonlinear moment conditions derived from error covariance structure{p_end}
{synopt:{opt c:ollapse}}collapse GMM-type into standard instruments{p_end}
{synopt:{opt m:odel}{cmd:(}{it:{help xtdpdgmm##options_spec:model_spec}}{cmd:)}}set the default model for the instruments and VCE{p_end}
{synopt:{opt nores:cale}}do not rescale the transformed moment conditions{p_end}
{synopt:{opt w:matrix}{cmd:(}{it:{help xtdpdgmm##options_spec:wmat_spec}}{cmd:)}}specify initial weighting matrix{p_end}
{p2coldent :* {opt one:step}|{opt two:step}}use the one-step or two-step estimator{p_end}
{p2coldent :* {opt igmm}}use the iterated GMM estimator{p_end}
{synopt:{opt te:ffects}}add time effects to the model{p_end}
{synopt:{opt over:id}}compute overidentification statistics for reduced models{p_end}
{synopt:{opt nocons:tant}}suppress constant term{p_end}

{syntab:SE/Robust}
{synopt :{opt vce}{cmd:(}{it:{help xtdpdgmm##options_spec:vce_spec}}{cmd:)}}specify the {help xtdpdgmm##vcetype:{it:vcetype}} for the SE estimation{p_end}

{syntab:Reporting}
{synopt:{opt aux:iliary}}display all coefficients as auxiliary parameters{p_end}
{synopt:{opt l:evel(#)}}set confidence level; default is {cmd:level(95)}{p_end}
{synopt:{opt sm:all}}make degrees-of-freedom adjustment and report small-sample statistics{p_end}
INCLUDE help shortdes-coeflegend
{synopt:{opt nohe:ader}}suppress output header{p_end}
{synopt:{opt notab:le}}suppress coefficient table{p_end}
{synopt:{opt nofoot:note}}suppress footnote below the coefficient table{p_end}
{synopt:{it:{help xtdpdgmm##display_options:display_options}}}control
INCLUDE help shortdes-displayoptall

{syntab:Minimization}
{synopt:{opt noan:alytic}}do not use analytical closed-form solutions{p_end}
{synopt:{opt from}{cmd:(}{it:{help xtdpdgmm##options_spec:init_spec}}{cmd:)}}initial values for the coefficients{p_end}
{synopt:{opt nodot:s}}display an iteration log instead of dots for each step of the iterated GMM estimator{p_end}
{synopt:{it:{help xtdpdgmm##igmm_options:igmm_options}}}control the iterated GMM process; seldom used{p_end}
{synopt:{it:{help xtdpdgmm##minimize_options:minimize_options}}}control the minimization process; seldom used{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}* You can specify at most one of these options. {cmd:onestep} is the default unless option {opt nl(nl_spec)} is specified, in which case {cmd:twostep} is the default.{p_end}

{marker options_spec}{...}
{p 4 6 2}
{it:iv_spec} is

{p 8 8 2}
{varlist} [{cmd:,} {opt l:agrange(#_1 [#_2])} {opt d:ifference} {opt bod:ev} {opt m:odel(model_spec)} [{cmdab:no:}]{opt res:cale}]

{p 4 6 2}
{it:gmmiv_spec} is

{p 8 8 2}
{varlist} [{cmd:,} {opt l:agrange(#_1 [#_2])} [{cmdab:no:}]{opt c:ollapse} {opt d:ifference} {opt bod:ev} {opt m:odel(model_spec)} [{cmdab:no:}]{opt res:cale} {opt iid}]

{p 4 6 2}
{it:nl_spec} is

{p 8 8 2}
{opt noser:ial}|{opt iid} [{cmd:,} [{cmdab:no:}]{opt c:ollapse} [{cmdab:no:}]{opt res:cale} {opt w:eight(#)}]

{p 4 6 2}
{it:wmat_spec} is

{p 8 8 2}
[{opt un:adjusted}|{opt ind:ependent}|{opt sep:arate}] [{cmd:,} {opt r:atio(#)}]

{p 4 6 2}
{it:vce_spec} is

{p 8 8 2}
[{opt conventional}|{opt r:obust}|{opt cl:uster} {it:clustvar}] [{cmd:,} {opt m:odel(model_spec)}]

{p 4 6 2}
{it:model_spec} is

{p 8 8 2}
{opt l:evel}|{opt d:ifference}|{opt md:ev}|{opt fod:ev}

{p 4 6 2}
{it:init_specs} is one of

{p 8 20 2}{it:matname} [{cmd:,} {cmd:skip} {cmd:copy}]{p_end}

{p 8 20 2}{it:#} [{it:#} {it:...}]{cmd:,} {cmd:copy}{p_end}

{p 4 6 2}
You must {cmd:xtset} your data before using {cmd:xtdpdgmm}; see {helpb xtset:[XT] xtset}.{p_end}
{p 4 6 2}
All {it:varlists} may contain factor variables; see {help fvvarlist}.{p_end}
{p 4 6 2}
{it:depvar} and all {it:varlists} may contain time-series operators; see {help tsvarlist}.{p_end}
{p 4 6 2}
See {helpb xtdpdgmm postestimation} for features available after estimation.{p_end}
{p 4 6 2}
{cmd:xtdpdgmm} is a community-contributed program. The current version requires Stata version 13 or higher; see {help xtdpdgmm##update:version history and updates}.{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:xtdpdgmm} implements generalized method of moments (GMM) estimators for linear dynamic panel data models. GMM estimators can be specified with linear moment conditions in the spirit of Arellano and Bond (1991), Arellano and Bover (1995),
Blundell and Bond (1998), and Hayakawa, Qi, and Breitung (2019). {cmd:xtdpdgmm} can also incorporate the nonlinear moment conditions suggested by Ahn and Schmidt (1995).
The latter yield efficiency gains and more robust results for highly persistent data. The Windmeijer (2005) finite-sample standard error correction is implemented for estimators with and without nonlinear moment conditions.

{pstd}
The model can be estimated with the one-step or two-step GMM estimator, or the iterated GMM estimator. The two-step estimator uses an optimal weighting matrix that is estimated based on the one-step residuals.
The iterated GMM estimator, suggested by Hansen, Heaton, and Yaron (1996), further updates the weighting matrix until convergence.

{pstd}
Possible model transformations include first differences, deviations from within-group means, and forward-orthogonal deviations. With the latter, backward-orthogonal deviations of the instrumental variables are possible.
Instruments for different model transformations can be combined to form a 'system GMM' estimator.


{marker options}{...}
{title:Options}

{dlgtab:Model}

{phang}
{cmd:iv(}{varlist} [{cmd:,} {it:suboptions}]{cmd:)} and {cmd:gmmiv(}{varlist} [{cmd:,} {it:suboptions}]{cmd:)} specify standard and GMM-type instruments, respectively. You may specify as many sets of standard instruments as you need.
Allowed {it:suboptions} for both type of instruments are {opt l:agrange(#_1 [#_2])}, {opt d:ifference}, {opt bod:ev}, {opt m:odel}{cmd:(}{opt l:evel}|{opt d:ifference}|{opt md:ev}|{opt fod:ev}{cmd:)}, and [{cmdab:no:}]{opt res:cale}.
GMM-type instruments allow the additional {it:suboptions} [{cmdab:no:}]{opt c:ollapse} and {opt iid}.

{pmore}
{opt lagrange(#_1 [#_2])} specifies the range of lags of {it:varlist} to be used as instruments. Negative integers are allowed to include leads. The default depends on the type of instruments.

{pmore2}
Used with option {cmd:iv()}, the default is {cmd:lagrange(0 0)}. Specifying {cmd:iv(}{it:varlist}{cmd:,} {opt lagrange(#_1 #_2)}{cmd:)} is equivalent to specifying {cmd:iv(L(}{it:#_1}{cmd:/}{it:#_2}{cmd:).(}{it:varlist}{cmd:))}
unless suboption {cmd:bodev} is specified; see {help tsvarlist}. {opt lagrange(#_1)} with only one argument is equivalent to {opt lagrange(#_1 #_1)} with two identical arguments.

{pmore2}
Used with option {cmd:gmmiv()}, the default is {cmd:lagrange(1 .)} in combination with {cmd:model(difference)}, and {cmd:lagrange(0 .)} otherwise. A missing value for {it:#_1} requests all available leads to be used until {it:#_2},
while a missing value for {it:#_2} requests all available lags to be used starting with {it:#_1}. Thus, {cmd:lagrange(. .)} uses all available observations.
{opt lagrange(#_1)} with only one argument is equivalent to {cmd:lagrange(}{it:#_1}{cmd: .)}.

{pmore}
{opt collapse} and {opt nocollapse} used with option {cmd:gmmiv()} request to either collapse or to not collapse the GMM-type instruments into standard instruments. The suboption {cmd:collapse} is useful to reduce the number of instruments,
in particular if all available lags are used. With a limited number of lags, {cmd:gmmiv(}{it:varlist}{cmd:,} {cmd:lagrange(}{it:#_1 #_2}{cmd:) {cmd:collapse)}} is equivalent to {cmd:iv(}{it:varlist}{cmd:, lagrange(}{it:#_1 #_2}{cmd:))}.
The suboption {cmd:nocollapse} can be used to override the default set by the global option {cmd:collapse}.

{pmore}
{opt difference} requests a first-difference transformation of {it:varlist}. This is equivalent to specifying {cmd:iv(D.(}{it:varlist}{cmd:))}; see {help tsvarlist}.

{pmore}
{opt bodev} requests a backward-orthogonal deviations transformation of {it:varlist}. This is only possible in combination with {cmd:model(fodev)}.

{pmore}
{opt model(model)} specifies if the instruments apply to the model in levels, {cmd:model(level)}, in first differences, {cmd:model(difference)}, in deviations from within-group means, {cmd:model(mdev)},
or in forward-orthogonal deviations, {cmd:model(fodev)}. The default is {cmd:model(level)} unless otherwise specified with the global option {opt model(model)}.

{pmore}
{opt rescale} and {opt norescale} request to either rescale or to not rescale the moment conditions such that the transformed error term retains the same variance
under the assumption that the untransformed idiosyncratic error term is independent and identically distributed. These suboptions are seldom used and only have an effect in combination with {cmd:model(mdev)} or {cmd:model(fodev)}.
They similarly affect the transformation of {it:varlist} when suboption {cmd:bodev} is specified. {cmd:rescale} is the default unless otherwise specified with the global option {cmd:norescale}.

{pmore}
{opt iid} used with option {cmd:gmmiv()} specifies instruments valid under an error-components structure with an independent and identically distributed idiosyncratic error component.
These are the additional instruments implied by the linear moment conditions derived by Ahn and Schmidt (1995) under the assumption of homoskedastic errors if specified as {cmd:gmmiv(L.}{it:depvar}{cmd:,} {cmd:iid)}.
This suboption is seldom used and it implies the other suboptions {cmd:model(difference)} and {cmd:lagrange(0 0)}.

{phang}
{cmd:nl(}{opt noser:ial}|{opt iid} [, {it:suboptions}]{cmd:)} adds nonlinear moment conditions that are valid under an error-components structure with specific assumptions on the idiosyncratic error component.
Allowed {it:suboptions} are [{cmdab:no:}]{opt c:ollapse}, [{cmdab:no:}]{opt res:cale}, and {opt w:eight(#)}.

{pmore}
{cmd:nl(noserial)} adds the nonlinear moment conditions suggested by Ahn and Schmidt (1995) under the absence of serial correlation in the idiosyncratic error component.

{pmore}
{cmd:nl(iid)} adds the nonlinear moment conditions suggested by Ahn and Schmidt (1995) under homoskedasticity and the absence of serial correlation in the idiosyncratic error component.
It further adds linear moment conditions of the form {cmd:gmmiv(L.}{it:depvar}{cmd:, iid} [{cmd:collapse}]{cmd:)} that are valid under this assumption.

{pmore}
{opt collapse} requests to add up the moment conditions to form a single moment condition. {cmd:nocollapse} can be used to override the default set by the global option {cmd:collapse}.

{pmore}
{opt rescale} and {opt norescale} request to either rescale or to not rescale the moment conditions such that the transformed error term retains the same variance
under the assumption that the untransformed idiosyncratic error term is independent and identically distributed. These suboptions are seldom used and only have an effect in combination with {cmd:nl(iid)}.
{cmd:rescale} is the default unless otherwise specified with the global option {cmd:norescale}.

{pmore}
{opt weight(#)} specifies the weight of the nonlinear moment conditions in the initial weighting matrix relative to the linear moment conditions. The default is {cmd:weight(1)}.
Specifying {cmd:weight(0)} implies that the nonlinear moment conditions are ignored in the first estimation step.

{phang}
{opt collapse} requests to collapse all GMM-type instruments into standard instruments and to collapse the nonlinear moment conditions into a single moment condition.

{phang}
{opt model(model)} sets the default model used to generate the instruments specified with options {cmd:iv()} and {cmd:gmmiv()} and the default model for the conventional variance estimator specified with option {cmd:vce()}.
{it:model} is allowed to be {opt l:evel}, {opt d:ifference}, {opt md:ev}, or {opt fod:ev}. The default is {cmd:model(level)}.

{phang}
{opt norescale} requests not to rescale the moment conditions. By default, the moment conditions for the model in deviations from within-group means or forward-orthogonal deviations are rescaled by a group-specific factor
such that the transformed error term retains the same variance under the assumption that the untransformed idiosyncratic error term is independent and identically distributed.
A similar transformation is applied to the nonlinear moment conditions added with option {cmd:nl(iid)}. This option is seldom used.

{phang}
{cmd:wmatrix(}[{it:wmat_type}] [{cmd:,} {opt r:atio(#)}]{cmd:)} specifies the weighting matrix to be used to obtain one-step GMM estimates or initial estimates for two-step GMM estimation.
{it:wmat_type} is either {opt un:adjusted}, {opt ind:ependent}, or {opt sep:arate}.

{pmore}
{cmd:wmatrix(unadjusted)}, the default, is optimal for an error-components structure with a unit-specific component and an independent and identically distributed idiosyncratic component
if all instruments refer to the models in first differences and deviations from within-group means, or if the variance ratio of the unit-specific error component to the idiosyncratic error component is known,
and only if there are no nonlinear moment conditions. The variance ratio can be specified with the suboption {opt ratio(#)}. The default is {cmd:ratio(0)}.
Nonlinear moment conditions are always treated as independent in the initial weighting matrix.

{pmore}
{cmd:wmatrix(independent)} is the same as {cmd:wmatrix(unadjusted)} but treats the model in levels and the transformed models as independent, thus ignoring the covariance between the respective error terms.

{pmore}
{cmd:wmatrix(separate)} is the same as {cmd:wmatrix(unadjusted)} but treats the model in levels and the transformed models as separate models with an independent and identically distributed error term for the transformed models,
thus ignoring the covariance between the respective error terms and the serial correlation of the transformed error terms.

{phang}
{opt onestep}, {opt twostep}, and {opt igmm} specify which estimator is to be used. At most one of these options can be specified.

{pmore}
{opt onestep} requests the one-step GMM estimator to be computed that is based on the initial weighting matrix specified with option {opt wmatrix(wmat_spec)}. This is the default unless option {opt nl(nl_spec)} is specified.
In a model without nonlinear moment conditions and with weighting matrix {cmd:wmatrix(unadjusted)}, the one-step estimator corresponds to the two-stage least squares estimator.

{pmore}
{opt twostep} requests the two-step GMM estimator to be computed that is based on an optimal weighting matrix. This is the default if option {opt nl(nl_spec)} is specified.
An unrestricted (cluster-robust) optimal weighting matrix is computed using one-step GMM estimates. The unrestricted weighting matrix allows for intragroup correlation at the level specified with {cmd:vce(cluster} {it:clustvar}{cmd:)}.
By default, {it:clustvar} equals {it:panelvar}.

{pmore}
{opt igmm} requests the iterated GMM estimator to be computed. At each iteration step, an unrestricted (cluster-robust) optimal weighting matrix is computed using the GMM estimates from the previous step.
Iterations continue until convergence is achieved for the coefficient vector or the weighting matrix, or the maximum number of iterations is reached; see {it:{help xtdpdgmm##igmm_options:igmm_options}}.

{phang}
{opt teffects} requests that time-specific effects are added to the model. The first time period in the estimation sample is treated as the base period.

{phang}
{opt overid} requests to compute the overidentification statistics for the reduced models, leaving out one subset of moment conditions at a time.
These statistics can subsequently be used to compute Sargan-Hansen difference tests of the overidentifying restrictions with the postestimation command {cmd:estat overid}; see {helpb xtdpdgmm postestimation##estat:xtdpdgmm postestimation}.
This option is not needed to compute the Sargan-Hansen test for the full model.

{phang}
{opt noconstant}; see {helpb estimation options##noconstant:[R] estimation options}.

{marker vcetype}{...}
{dlgtab:SE/Robust}

{phang}
{opt vce}{cmd:(}{it:vcetype} [{cmd:,} {opt m:odel(model)}]{cmd:)} specifies the type of standard error reported, which includes types that are derived from asymptotic theory ({opt conventional}),
that are robust to some kinds of misspecification ({opt r:obust}), and that allow for intragroup correlation ({opt cl:uster} {it:clustvar}). {it:model} is allowed to be {opt l:evel}, {opt d:ifference}, {opt md:ev}, or {opt fod:ev}.

{pmore}
{cmd:vce(conventional)} uses the conventionally derived variance estimator. It is robust to some kinds of misspecification if the two-step GMM estimator is used or if nonlinear moment conditions are employed.
After one-step estimation, the error variance is by default computed from the level residuals, {cmd:model(level)}, unless it is specified that it is to be computed from the residuals in first differences, {cmd:model(difference)},
the residuals in deviations from within-group means, {cmd:model(mdev)}, or the residuals in forward-orthogonal deviations, {cmd:model(fodev)}. The sandwich estimator is used for one-step GMM estimation with nonlinear moment conditions,
but without the Windmeijer (2005) correction. {cmd:vce(conventional)} is the default, although in most cases {cmd:vce(robust)} would be recommended.

{pmore}
{cmd:vce(robust)} and {cmd:vce(cluster} {it:clustvar}{cmd:)} use the sandwich estimator for one-step GMM estimation with only linear moment conditions. For the corresponding two-step GMM estimation,
they compute the conventional estimator with the Windmeijer (2005) correction. For GMM estimation with nonlinear moment conditions, the sandwich estimator with the respective Windmeijer (2005) correction is computed
for both one-step and two-step estimation. {cmd:vce(robust)} is equivalent to {cmd:vce(cluster} {it:panelvar}{cmd:)}.

{dlgtab:Reporting}

{phang}
{opt auxiliary} displays all coefficients as auxiliary parameters and suppresses display of the {it:vcetype}. This option is seldom used.
It allows the subsequent use of postestimation commands that require equation-level scores; see {helpb suest:[R] suest}.

{phang}
{opt level(#)}; see {helpb estimation options##level():[R] estimation options}.

{phang}
{opt small} requests that a degrees-of-freedom adjustment be made to the variance-covariance matrix and that small-sample t and F statistics be reported.
The adjustment factor is (N-1)/(N-K) * M/(M-1), where N is the number of observations, M the number of clusters specified with {cmd:vce(cluster} {it:clustvar}{cmd:)}, and K the number of coefficients.
By default, no degrees-of-freedom adjustment is made and z and Wald statistics are reported. This option does not affect the computation of the optimal weighting matrix.

{phang}
{opt coeflegend}; see {helpb estimation options##coeflegend:[R] estimation options}.

{phang}
{opt noheader} suppresses display of the header above the coefficient table that displays the number of observations and moment conditions.

{phang}
{opt notable} suppresses display of the coefficient table.

{phang}
{opt nofootnote} suppresses display of the footnote below the coefficient table that displays the instruments corresponding to the linear moment conditions.

{marker display_options}{...}
{phang}
{it:display_options}: {opt noci}, {opt nopv:alues}, {opt noomit:ted}, {opt vsquish}, {opt noempty:cells}, {opt base:levels}, {opt allbase:levels}, {opt nofvlab:el}, {opt fvwrap(#)}, {opt fvwrapon(style)}, {opth cformat(%fmt)},
{opt pformat(%fmt)}, {opt sformat(%fmt)}, and {opt nolstretch}; see {helpb estimation options##display_options:[R] estimation options}.

{dlgtab:Minimization}

{phang}
{opt noanalytic} requests that the coefficient estimates are obtained numerically instead of using analytical closed-form solutions. This option is seldom used.
It is implied when the model contains nonlinear moment conditions under the option {opt nl(nl_spec)} because closed-form solutions do not exist in this case.

{phang}
{opt from(init_specs)} specifies initial values for the coefficients; see {helpb maximize:[R] maximize}. By default, initial values are set to zero.

{phang}
{opt nodots} specifies that an iteration log is displayed instead of dots. By default, one dot character is displayed for each step of the iterated GMM estimator.
For the one-step and two-step estimator, display of an iteration log is the default.

{phang}{marker igmm_options}
{it:igmm_options}: {opt igmmit:erate(#)}, {opt igmmeps(#)}, and {opt igmmweps(#)}; see {helpb gmm:[R] gmm}. These options are seldom used and only have an effect if the iterated GMM estimator is used.

{phang}{marker minimize_options}
{it:minimize_options}: {opt iter:ate(#)}, {opt nolo:g}, {opt showstep}, {opt showtol:erance}, {opt tol:erance(#)}, {opt ltol:erance(#)}, {opt nrtol:erance(#)}, and {opt nonrtol:erance}; see {helpb maximize:[R] maximize}.
These options are seldom used.


{marker remarks}{...}
{title:Remarks}

{pstd}
{cmd:xtdpdgmm} minimizes the GMM criterion function numerically with the Gauss-Newton technique if some of the moment conditions are nonlinear or the option {cmd:noanalytic} is specified.
Otherwise, the estimates are obtained from the analytical closed-form solutions of the first-order conditions.

{pstd}
Serially uncorrelated idiosyncratic error terms in the model in levels are a necessary condition for the validity of the instruments in most dynamic panel data models.
In that case, the nonlinear moment conditions added by the option {cmd:nl(noserial)} do not require any additional assumption. Those moment conditions added by the option {cmd:nl(iid)}, however, require an additional homoskedasticity assumption.

{pstd}
Depending on the specification, the number of GMM-type instruments grows linearly or quadratically in the number of time periods. The total number of moment conditions thus easily becomes large relative to the number of groups in the sample.
As summarized by Roodman (2009), such an instrument proliferation can have severe consequences including biased coefficient and standard error estimates and weakened specification tests.
The most common approaches to reduce the number of instruments, as discussed again by Roodman (2009), are restricting the lags used to form GMM-type instruments with the {cmd:lagrange()} suboption,
or collapsing the GMM-type into standard instruments with the {cmd:collapse} suboption. The latter approach can also be applied to the nonlinear moment conditions which effectively creates a sum over all time-specific moment conditions.

{pstd}
Unbalanced panel data is supported by {cmd:xtdpdgmm}. The moment conditions under deviations from within-group means with suboption {cmd:model(mdev)} are rescaled by the factor {it:sqrt(T_i/(T_i-1))},
where {it:T_i} is the number of observations for group {it:i}, unless the option {cmd:norescale} is specified. This ensures that the variance of the error term is left unchanged by the transformation under the assumption that the untransformed
error term is independent and identically distributed. The transformation has no effect with balanced panel data.

{pstd}
For the moment conditions under forward-orthogonal deviations with suboption {cmd:model(fodev)}, such a scaling factor was suggested by Arellano and Bover (1995).
A similar factor is used to rescale the instrumental variables under backward-orthogonal deviations with suboption {cmd:bodev} and to rescale the nonlinear moment conditions specified with option {cmd:nl(iid)}.
This rescaling can be switched off again with the option {cmd:norescale}.

{pstd}
Taking lags and first differences of a variable is interchangeable such that the specifications {cmd:iv(L}{it:#}{cmd:D.(}{it:varlist}{cmd:))}, {cmd:iv(L}{it:#}{cmd:.(}{it:varlist}{cmd:), d)}, {cmd:iv(D.(}{it:varlist}{cmd:), l(}{it:#}{cmd:))},
and {cmd:iv(}{it:varlist}{cmd:, d l(}{it:#}{cmd:))} all create identical instruments. This is not true for the combination of lags and backward-orthogonal deviations.
The specification {cmd:iv(L}{it:#}{cmd:.(}{it:varlist}{cmd:), bod m(fod))} creates backward-orthogonal deviations of the {it:#}-th lag of {it:varlist}, as suggested by Hayakawa, Qi, and Breitung (2019),
while {cmd:iv(}{it:varlist}{cmd:, bod l(}{it:#}{cmd:) m(fod))} creates the {it:#}-th lag of the backward-orthogonal deviations of {it:varlist}.


{marker example}{...}
{title:Example}

{pstd}Setup{p_end}
{phang2}. {stata webuse abdata}{p_end}

{pstd}Anderson-Hsiao IV estimators with strictly exogenous covariates{p_end}
{phang2}. {stata xtdpdgmm L(0/1).n w k, iv(L2.n w k, d) m(d) nocons}{p_end}
{phang2}. {stata xtdpdgmm L(0/1).n w k, iv(L2.n) iv(w k, d) m(d) nocons}{p_end}

{pstd}Arellano-Bond one-step GMM estimator with strictly exogenous covariates and instrument reduction{p_end}
{phang2}. {stata xtdpdgmm L(0/1).n w k, gmm(L.n, l(1 4) c) iv(w k, d) m(d) nocons}{p_end}

{pstd}Arellano-Bover two-step GMM estimator with predetermined covariates and instrument reduction{p_end}
{phang2}. {stata xtdpdgmm L(0/1).n w k, gmm(L.n w k, l(0 3) c) m(fod) two vce(r)}{p_end}

{pstd}Ahn-Schmidt two-step GMM estimators with predetermined covariates and instrument reduction{p_end}
{phang2}. {stata xtdpdgmm L(0/1).n w k, gmm(L.n w k, l(1 4) c) m(d) nl(noser) two vce(r)}{p_end}
{phang2}. {stata xtdpdgmm L(0/1).n w k, gmm(L.n w k, l(1 4) c) m(d) nl(iid) two vce(r)}{p_end}

{pstd}Blundell-Bond two-step GMM estimator with predetermined covariates and instrument reduction{p_end}
{phang2}. {stata xtdpdgmm L(0/1).n w k, gmm(L.n w k, l(1 4) c m(d)) iv(L.n w k, d) two vce(r)}{p_end}

{pstd}Hayakawa-Qi-Breitung IV estimator with predetermined covariates{p_end}
{phang2}. {stata xtdpdgmm L(0/1).n w k, iv(L.n w k, bod) m(fod) nocons}{p_end}

{pstd}Replication of a static (weighted) fixed-effects estimator{p_end}
{phang2}. {stata xtdpdgmm n w k, iv(w k) m(md)}{p_end}
{phang2}. {stata "by id: egen weight = count(e(sample))"}{p_end}
{phang2}. {stata replace weight = sqrt(weight/(weight-1))}{p_end}
{phang2}. {stata xtreg n w k [aw=weight], fe}{p_end}

{pstd}Replication of a static (unweighted) fixed-effects estimator{p_end}
{phang2}. {stata xtdpdgmm n w k, iv(w k) m(md) nores}{p_end}
{phang2}. {stata xtreg n w k, fe}{p_end}


{marker results}{...}
{title:Saved results}

{pstd}
{cmd:xtdpdgmm} saves the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(df_r)}}residual degrees of freedom; not always saved{p_end}
{synopt:{cmd:e(N_g)}}number of groups{p_end}
{synopt:{cmd:e(N_clust)}}number of clusters{p_end}
{synopt:{cmd:e(g_min)}}smallest group size{p_end}
{synopt:{cmd:e(g_avg)}}average group size{p_end}
{synopt:{cmd:e(g_max)}}largest group size{p_end}
{synopt:{cmd:e(f)}}value of the objective function{p_end}
{synopt:{cmd:e(chi2_J)}}Hansen's J-statistic{p_end}
{synopt:{cmd:e(chi2_J_u)}}Hansen's J-statistic with updated weighting matrix{p_end}
{synopt:{cmd:e(rank)}}rank of {cmd:e(V)}{p_end}
{synopt:{cmd:e(zrank)}}number of linear moment functions{p_end}
{synopt:{cmd:e(zrank_nl)}}number of nonlinear moment functions{p_end}
{synopt:{cmd:e(sigma2e)}}estimate of sigma_e^2; not always saved{p_end}
{synopt:{cmd:e(steps)}}number of steps{p_end}
{synopt:{cmd:e(ic)}}number of iterations in final step{p_end}
{synopt:{cmd:e(converged)}}= {cmd:1} if converged in final step, {cmd:0} otherwise{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:xtdpdgmm}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(ivar)}}variable denoting groups{p_end}
{synopt:{cmd:e(tvar)}}variable denoting time{p_end}
{synopt:{cmd:e(estat_cmd)}}{cmd:xtdpdgmm_estat}{p_end}
{synopt:{cmd:e(predict)}}{cmd:xtdpdgmm_p}{p_end}
{synopt:{cmd:e(teffects)}}time effects created with option {cmd:teffects}{p_end}
{synopt:{cmd:e(wmatrix)}}{it:wmat_spec} specified with option {cmd:wmatrix()}{p_end}
{synopt:{cmd:e(estimator)}}{cmd:onestep}, {cmd:twostep}, or {cmd:igmm}{p_end}
{synopt:{cmd:e(vce)}}{cmd:conventional} or {cmd:robust}{p_end}
{synopt:{cmd:e(vcetype)}}title used to label Std. Err.{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}{p_end}
{synopt:{cmd:e(depvar)}}name of dependent variable{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators{p_end}
{synopt:{cmd:e(V_modelbased)}}model-based variance; not always saved{p_end}
{synopt:{cmd:e(W)}}weighting matrix{p_end}
{synopt:{cmd:e(ilog)}}iteration log (up to 20 iterations){p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}
{p2colreset}{...}


{marker update}{...}
{title:Version history and updates}

{pstd}{cmd:xtdpdgmm} is a community-contributed program. To determine the currently installed version, type{p_end}
{phang2}. {stata which xtdpdgmm, all}{p_end}

{pstd}To update the {cmd:xtdpdgmm} package to the latest version, type{p_end}
{phang2}. {stata `"net install xtdpdgmm, from("http://www.kripfganz.de/stata/") replace"'}{p_end}

{pstd}If the connection to the previous website fails, alternatively type{p_end}
{phang2}. {stata ssc install xtdpdgmm, replace}{p_end}

{pstd}
The SSC version is less frequently updated and may not be the latest available version. The current version of the {cmd:xtdpdgmm} package requires Stata version 13 or higher.
For backward compatibility and replicability of results obtained with earlier versions, the following older versions can be installed as well. Note that these versions may use different syntax and may still contain bugs
that were fixed in subsequent versions. If you intend to install different versions alongside each other, you can set different installation paths with {cmd:net set ado} {it:dirname}; see {helpb net:[R] net}.

{pstd}To install the {cmd:xtdpdgmm} version 1.1.3 as of 24sep2018, requiring Stata version 12.1 or higher, type{p_end}
{phang2}. {stata `"net install xtdpdgmm, from("http://www.kripfganz.de/stata/xtdpdgmm_v1/")"'}{p_end}


{marker author}{...}
{title:Author}

{pstd}
Sebastian Kripfganz, University of Exeter, {browse "http://www.kripfganz.de"}


{title:Acknowledgement}

{pstd}
The development of this program benefited from discussions with Mark E. Schaffer.


{marker references}{...}
{title:References}

{phang}
Ahn, S. C., and P. Schmidt. 1995.
Efficient estimation of models for dynamic panel data.
{it:Journal of Econometrics} 68: 5-27.

{phang}
Anderson, T. W., and C. Hsiao. 1981.
Estimation of dynamic models with error components.
{it:Journal of the American Statistical Association} 76: 598-606.

{phang}
Arellano, M., and S. R. Bond. 1991.
Some tests of specification for panel data: Monte Carlo evidence and an application to employment equations.
{it:Review of Economic Studies} 58: 277-297.

{phang}
Arellano, M., and O. Bover. 1995.
Another look at the instrumental variable estimation of error-components models.
{it:Journal of Econometrics} 68: 29-51.

{phang}
Blundell, R., and S. R. Bond. 1998.
Initial conditions and moment restrictions in dynamic panel data models.
{it:Journal of Econometrics} 87: 115-143.

{phang}
Hansen, L. P., J. Heaton, and A. Yaron. 1996.
Finite-sample properties of some alternative GMM estimators.
{it:Journal of Business & Economic Statistics} 14: 262-280.

{phang}
Hayakawa, K., M. Qi, and J. Breitung. 2019.
Double filter instrumental variable estimation of panel data models with weakly exogenous variables.
{it:Econometric Reviews} 38: 1055-1088.

{phang}
Roodman, D. 2009.
A note on the theme of too many instruments.
{it:Oxford Bulletin of Economics and Statistics} 71: 135-158.

{phang}
Windmeijer, F. 2005.
A finite sample correction for the variance of linear efficient two-step GMM estimators.
{it:Journal of Econometrics} 126: 25-51.
