{smcl}
{* *! version 1.0.1 24aug2016}{...}
{vieweralsosee "[R] xtpoisson" "help xtpoisson"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "ppml" "help ppml"}{...}
{vieweralsosee "xtpqml" "help xtpqml"}{...}
{vieweralsosee "poi2hdfe" "help poi2hdfe"}{...}
{vieweralsosee "reghdfe" "help reghdfe"}{...}
{viewerjumpto "Syntax" "ppml_panel_sg##syntax"}{...}
{viewerjumpto "Description" "ppml_panel_sg##description"}{...}
{viewerjumpto "Main Options" "ppml_panel_sg##main_options"}{...}
{viewerjumpto "Guessing and Storing Values" "ppml_panel_sg##guess_store"}{...}
{viewerjumpto "Background" "ppml_panel_sg##backgroup"}{...}
{viewerjumpto "Postestimation Syntax" "ppml_panel_sg##postestimation"}{...}
{viewerjumpto "Examples" "ppml_panel_sg##examples"}{...}
{viewerjumpto "Stored results" "ppml_panel_sg##results"}{...}
{viewerjumpto "Author" "ppml_panel_sg##contact"}{...}
{viewerjumpto "Advisory" "ppml_panel_sg##advisory"}{...}
{viewerjumpto "Updates" "ppml_panel_sg##updates"}{...}
{viewerjumpto "Acknowledgements" "ppml_panel_sg##acknowledgements"}{...}
{viewerjumpto "References" "ppml_panel_sg##references"}{...}
{title:Title}

{p2colset 5 22 23 2}{...}
{p2col :{cmd:ppml_panel_sg} {hline 2}} Fast PPML panel structural gravity estimation.{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{p 8 15 2}{cmd:ppml_panel_sg}
{depvar} [{indepvars}] 
{ifin}{cmd:,} {opt ex:porter(exp_id)} {opt im:porter(imp_id)} {opt y:ear(time_id)} [{help ppml_panel_sg##options:options}] {p_end}

{p 8 8 2}{it: exp_id}, {it: imp_id}, and {it: time_id} are variables that respectively identify 
the origin, destination, and time period associated with each observation.{p_end}

{marker description}{...}
{title:Description}

{pstd}
{cmd:ppml_panel_sg}  enables faster computation of the many fixed effects required for panel PPML structural gravity
estimation. In particular, it addresses the large number of “pair-wise” FEs needed to consistently identify the
effects of time-varying trade policies such as regional trade agreements (see, e.g., Baier & Bergstrand, 2007; Dai,
Yotov, & Zylkin, 2014). It also simultaneously absorbs the origin-by-time and destination-by-time FEs implied
by theory.{p_end}

{pstd}Some options and features of interest:{p_end}

{p2col 8 12 12 2: 1.}Programmed to run in Mata, making it much faster than existing Stata Poisson commands for estimating the
effects of trade policies.{p_end}
{p2col 8 12 12 2: 2.}Can store the estimated fixed effects in Stata’s memory (but as a single column each, rather than as a large
matrix with many zeroes).{p_end}
{p2col 8 12 12 2: 3.}In addition to the pair fixed effects, also readily allows for specifications with additional pair-specific linear
time trends.{p_end}
{p2col 8 12 12 2: 4.}Supports multi-way clustering of standard errors.{p_end}
{p2col 8 12 12 2: 5.}All fixed effects are also allowed to vary by industry, in case you wish to examine industry-level variation
in trade flows.{p_end}
{p2col 8 12 12 2: 6.}Can be used with strictly cross-sectional regressions (i.e., without pair fixed effects).{p_end}
{p2col 8 12 12 2: 7.}Performs Santos Silva & Tenreyro (2010)'s recommended check for possible non-existence 
of estimates.{p_end}

{marker main_options}{...}
{title:Main Options}

{synoptset 20 tabbed}{...}
{synopt: {opt nopair}}Use origin-time and destination-time fixed effects only (do not include pair fixed effects).{p_end}

{synopt: {opt trend}}Add linear, pair-specific time trends.{p_end}

{synopt: {opt sym:metric}}Assume pair fixed effects apply symmetrically to flows in both directions, as in, e.g., Anderson
& Yotov (2016). Time trends, if specified, will also be symmetric.{p_end}

{synopt: {opt ind:ustry(ind_id)}}{it:ind_id} is a varname identifying the industry associated with each observation. When an {it:ind_id}
is provided, the origin-time fixed effects become origin-industry-time effects, the destination-time
fixed effects become destination-industry-time effects, and pair-specific terms become
origin-destination-industry-specific.{p_end}

{synopt: {opt off:set(varname)}}Include {it:varname} as a regressor with coefficient constrained to be equal to 1.{p_end}

{synopt: {opt clus:ter(clus_id)}}Specifies clustered standard errors, clustered by {it:clus_id}. The default is clustering by
{it:exp_id-imp_id}, unless nopair is enabled. For multi-way clustering, {it:clus_id} may be a varlist (max length is 4.){p_end}

{synopt: {opt ro:bust}}Use robust standard errors. This is the default if {opt nopair} is enabled.{p_end}

{synopt: {opt dropsing:letons}}Drop “singletons” beforehad à la {browse "https://ideas.repec.org/c/boc/bocode/s457874.html":reghdfe}.{p_end}

{synopt: {opt multi:way}}Automatic three-way clustering by {it:exp_id}, {it:imp_id}, 
and {it:time_id}. {p_end}

{synopt: {opt no:sterr}}Do not compute standard errors (saves time if you only care about point estimates).{p_end}

{synopt: {opth tol:erance(#)}}The default tolerance is 1e-12.{p_end}

{synopt: {opth max:iter(#)}}The default maximum number of iterations is 10,000.{p_end}

{synopt: {opt noacc:el}}Do not use “acceleration” when computing estimates.{p_end}

{synopt: {opth verb:ose(#)}}Show iterative output for every #th iteration. Default is 0 (no output).{p_end}

{marker guess_store}{...}
{title:Guessing and Storing Values}

{pstd}These options allow you to store results for fixed effects in memory as well as use information from memory to
set up initial guesses. You may also utilize the “multilateral resistances” of Anderson & van Wincoop (2003).{p_end}

{synopt: {opt ols:guess}}Use {browse "https://ideas.repec.org/c/boc/bocode/s457874.html":reghdfe} to initialize guesses for coefficient values.{p_end}

{synopt: {opt guessB(str)}}Supply the name of a row vector with guesses for coefficient values.{p_end}

{synopt: {opt guessD(varname)}}Guess initial values for the (exponentiated) set of pair fixed effects. Default is all 1s.{p_end}

{synopt: {opt guessS(varname)}}Guess initial values for the (exponentiated) set of origin-time fixed effects. Default is the
share of {depvar} within each {it:[ind_id-]time-id} associated with each {it:exp-id.}{p_end}

{synopt: {opt guessM(varname)}}Guess initial values for the (exponentiated) set of destination-time fixed effects. Default is the
share of {depvar} within each {it:[ind_id-]time-id} associated with each {it:imp-id.}{p_end}

{synopt: {opt guessO(varname)}}Guess initial values for the set of “outward” multilateral resistances. Default is all 1s. Overrides 
{opt genS}.{p_end}

{synopt: {opt guessI(varname)}}Guess initial values for the set of “inward” multilateral resistances. Default is all 1s. Overrides {opt genM}.{p_end}

{synopt: {opt guessTT(varname)}}Guess initial values for pair time trends. These are not exponentiated. Default is all 0s.{p_end}

{pstd}{opth genD(newvar)}, {opth genS(newvar)}, {opth genM(newvar)}, {opth genO(newvar)}, {opth genI(newvar)}, and {opth genTT(newvar)}: 
These options store fixed effects and/or time trend parameters in memory as new variables.{p_end} 
{pstd}To store predicted values, use {opth pred:ict(varname)}.{p_end}

{marker guess_store}{...}
{title:Check for Existence}

{pstd}As with {browse "https://ideas.repec.org/c/boc/bocode/s458102.html":ppml}, {cmd:ppml_panel_sg} checks your specification beforehand to ensure that valid estimates will indeed exist. 
These options affect how this check is performed.{p_end}

{synopt: {opt nocheck}}Do not check for existence.{p_end}

{synopt: {opt strict}}Applies a more conservative set of exclusion conditions when checking whether each 
regressor may be including; mimics “strict” option from {browse "https://ideas.repec.org/c/boc/bocode/s458102.html":ppml}.{p_end}

{synopt: {opt keep}}Keeps observations that are perfectly predicted by excluded regressors; mimics “keep” 
option from {browse "https://ideas.repec.org/c/boc/bocode/s458102.html":ppml}.{p_end}


{marker background}{...}
{title:Background}

{pstd}
As a typical application, consider the following PPML regression:{p_end}

{p 8 15 2}X_ijt = exp[ln S_it + ln M_jt + ln D_ij + b×RTA_ijt] + e_ijt.  (1){p_end} 
{pstd}X_ijt are international trade flows. i, j, and t are indices for origin, destination, and time. The goal is to consistently
estimate the average effect of RTA, a dummy variable for the presence of a regional trade agreement on trade
flows, using a “structural gravity” specification. The origin-time and destination-time fixed effects—S_it and M_jt—ensure 
the theoretical restrictions implied by structural gravity are satisfied. The pair fixed effect—D ij—then
absorbs all time-invariant pair characteristics that may be correlated with the likelihood of forming an RTA.{p_end}

{pstd}Computationally, the biggest obstacle to estimating (1) is the pair fixed effect term D_ij. Because a unique D_ij must
be computed for each pair, the number of D_ij’s increases rapidly with the number of locations. For a balanced
international trade data set with 75 countries trading with each other over 10 years (not an especially large sample
for trade data), there will be on the order of 75^2 = 5,625 pair fixed effects that must be computed. In addition
(ignoring collinearity), we will also require 75×2×10 = 1,500 origin-time and destination-time effects. The
total number of parameters needed to estimate (1) (around 7,000) would normally require a long computing time
in Stata, likely several hours at least. If we push the number of locations and/or years further, we will quickly
approach Stata’s matsize limits, beyond which estimation becomes infeasible.{p_end}

{pstd}To date, this is the only available Stata command that will perform “fast” estimation of specifications such as (1)
using PPML. It works by manipulating the first order conditions of the Poisson to produce analytical expressions
for each of the fixed effects that can be computed via simple iteration. In this way, it both adapts and extends
existing procedures described in Guimarães & Portugal (2010) and Figueiredo, Guimarães, & Woodward (2015)
for estimating Poisson models with high dimensional fixed effects. These works and others are recommended
below for further reading.{p_end}

{marker examples}{...}
{title:Examples}

{pstd}To perform a basic panel estimation such as (1):{p_end}

{p 8 15 2}{cmd:ppml_panel_sg trade rta, ex(iso_o) im(iso_d) y(year)}{p_end}

{pstd}To add pair-specific time trends, i.e.,{p_end}

{p 8 15 2}X_ijt = exp[ln S_it + ln M_jt + ln D_ij + a_ij×t + b×RTA_ijt] + e_ijt,  (2){p_end} 
{pstd}you would input:{p_end}

{p 8 15 2}{cmd:ppml_panel_sg trade rta, ex(iso_o) im(iso_d) y(year) trend}{p_end}

{pstd}If you want your pair fixed effects to be symmetric (i.e., D_ij = D_ji),
the syntax is:{p_end}

{p 8 15 2}{cmd:ppml_panel_sg trade rta, ex(iso_o) im(iso_d) y(year) sym}{p_end}

{pstd}To estimate coefficients of more traditional, time-invariant gravity variables, such as bilateral distance, use the
{opt nopair} option:{p_end}

{p 8 15 2}{cmd:ppml_panel_sg trade ln_dist colony language contiguity rta, ex(iso_o) im(iso_d) y(year) nopair}{p_end}

{pstd}Unlike the regressions with pair fixed effects, however, obtaining estimates for time-invariant regressors may not
be noticeably faster than existing methods (e.g., {manlink R glm}, {browse "https://ideas.repec.org/c/boc/bocode/s458102.html":ppml}) unless the number of origin-time and destination-time
effects is sufficiently large. You may also exclude the year ID in this last specification if your data includes only 1 year. An example data set and .do file is available from the the repec page for this command.{p_end}

{marker advisory}{...}
{title:Advisory}

{pstd}This estimation command is strictly intended for settings where the dependent variable is spatial flows from one
set of locations to another (such as international trade or migration flows). It is not a generalized Poisson fixed
effects command. For more general problems that require Poisson estimation, you may try: {manlink R poisson}, {manlink R glm}, {manlink R xtpoisson},
{browse "https://ideas.repec.org/c/boc/bocode/s458102.html":ppml},
 {browse "https://ideas.repec.org/c/boc/bocode/s456821.html":xtpqml}, and/or {browse "https://ideas.repec.org/c/boc/bocode/s457777.html":poi2hdfe}. For 
 an OLS command that can compute similar “gravity” specifications using
OLS, I recommend {browse "https://ideas.repec.org/c/boc/bocode/s457874.html":reghdfe}.{p_end}

{pstd}As noted above, a useful feature of this command is that it will automatically drop any of your main covariates which 
do not satisfy the condition for guaranteeing the existence of estimates in Santos Silva & Tenreyro (2010). This should
ensure convergence in most cases. However, you may still encounter convergence issues in cases where linear time trends are 
specified and when the data contains many zeroes. Future versions will seek to address this latter issue.

{pstd}This is version 1.1 of this command. If you believe you have found an error that can be replicated, or have other
suggestions for improvements, please feel free to contact the author.{p_end}

{marker contact}{...}
{title:Author}

{pstd}Thomas Zylkin{break}
Department of Economics, Robins School of Business{break}
University of Richmond{break}
Email: {browse "mailto:tomzylkin@gmail.com":tomzylkin@gmail.com}
{p_end}

{marker citation}{...}
{title:Suggested Citation}

If you are using this command in your research I would appreciate if you would cite

{pstd}• Larch, Mario, Wanner, Joschka, Yotov, Yoto V., Zylkin Thomas (2018), “Currency Unions and Trade: A
PPML Re-assessment with High-dimensional Fixed Effects”, {it:Oxford Bulletin of Economics and Statistics} (forthcoming).{p_end}

The appendix of this paper provides a technical companion for those interested in understanding how the command works. Note that it replaces an older working paper from 2017 entitled “The Currency Union Effect: A PPML Re-assessment with High-dimensional Fixed Effects”.

{marker acknowledgements}{...}
{title:Acknowledgements}

{pstd}I have adapted parts of my code from several other related commands. These include: {browse "https://ideas.repec.org/c/boc/bocode/s457777.html":poi2hdfe}, by Paulo
Guimarães, {browse "https://sites.google.com/site/hiegravity/stata-programs":SILS}, by Keith Head and Thierry Mayer, and {browse "https://ideas.repec.org/c/boc/bocode/s457874.html":reghdfe} by Sergio Correia. I give the utmost credit to
each of these authors for creating these programs and making their code available. The inclusion of multi-way clustering
in more recent versions of {cmd:ppml_panel_sg} (from v.1.1 onward) is thanks to contributions by Joschka Wanner and Mario Larch.{p_end}

{pstd}I also thank Yoto Yotov, Davin Chor, Sergio Correia, Paulo Guimarães, and João Santos Silva for kindly taking the time to 
offer feedback and suggest improvements.{p_end}

{marker further_reading}{...}
{title:Further Reading}

{pstd}• Structural gravity: Anderson & van Wincoop (2003); Head & Mayer (2014){p_end}

{pstd}• On the use of PPML to estimate gravity equations: Santos Silva & Tenreyro (2006); Fally (2015){p_end}

{pstd}• Possible non-existence of Poisson MLE estimates: Santos Silva & Tenreyro (2010){p_end}

{pstd}• Consistently estimating the effects of trade policies: Baier & Bergstrand (2007); Dai, Yotov, & Zylkin
(2014); Anderson & Yotov (2016); Piermartini & Yotov (2016){p_end}

{pstd}• Estimating models with high dimensional fixed effects: Guimarães & Portugal (2010);
Figueiredo, Guimarães, & Woodward (2015); Correia (2016){p_end}

{pstd}• Multi-way clustering: Cameron, Gelbach, & Miller (2011); Egger & Tarlea (2015) {p_end}

{pstd}• Singletons: Correia (2015) {p_end}


{marker references}{...}
{title:References}

{phang}
Anderson, J. E. & van Wincoop, E. (2003),
"Gravity with Gravitas: A Solution to the Border Puzzle",
{it: American Economic Review}  93(1), 170-192.
{p_end}

{phang}
Anderson, J. E. & Yotov, Y. V. (2016), “Terms of Trade and Global Efficiency Effects of Free Trade Agreements,
1990-2002”, {it:Journal of International Economics} 99(1), 279-298.
{p_end}

{phang}
Baier, S. L. & Bergstrand, J. H. (2007), “Do free trade agreements actually increase members’ international
trade?”, {it:Journal of International Economics} 71(1), 72-95.
{p_end}

{phang}
Cameron, A. C., Gelbach, J. B., & Miller, D. L. (2011), “Robust Inference With Multiway Clustering”, 
{it: Journal of Business & Economic Statistics} 29(2), 238–249.
{p_end}

{phang}
Correia, S. (2015), “Singletons, Cluster-Robust Standard Errors and Fixed Effects: A Bad Mix”.{p_end}

{phang}
Correia, S. (2016), “A Feasible Estimator for Linear Models with
Multi-Way Fixed Effects”.{p_end}

{phang}
Dai, M., Yotov, Y. V., & Zylkin, T. (2014), “On the trade-diversion effects of free trade agreements”,
{it:Economics Letters} 122(2), 321-325.{p_end}

{phang}
Egger, P.H., & Tarlea, F. (2015), “Multi-way clustering of standard errors in gravity models”,
{it:Economics Letters} 134, 144-147.{p_end}

{phang}
Fally, T. (2015), “Structural gravity and fixed effects”, {it:Journal of International Economics} 97(1), 76-85.{p_end}

{phang}
Figueiredo, O., Guimarães, P., & Woodward, D. (2015), “Industry localization, distance decay, and knowledge
spillovers: Following the patent paper trail”, {it:Journal of Urban Economics} 89(C), 21-31{p_end}

{phang}
Guimarães, P. & Portugal, P. (2010), “A simple feasible procedure to fit models with high-dimensional fixed
effects”, {it:Stata Journal} 10(4), 628-649.{p_end}

{phang}
Head, K. & Mayer, T. (2014), “Gravity equations: Workhorse, toolkit, and cookbook”, 
{it:Handbook of International Economics} 4, 131-196.{p_end}

{phang}
Piermartini, R. & Yotov, Y. (2016), “Estimating Trade Policy Effects with Structural Gravity”, WTO Working Paper ERSD-2016-10.

{phang}
Santos Silva, J. M. C. & Tenreyro, S. (2006), “The Log of Gravity”, {it:Review of Economics and Statistics} 88(4),
641–658.
{p_end}

{phang}
Santos Silva, J. M. C. & Tenreyro, S. (2010), “On the existence of the maximum likelihood estimates in Poisson
regression”, {it:Economics Letters} 107(2), 310–312.
{p_end}
