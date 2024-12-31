{smcl}
{* *! version 2.0 Jun 24 2022}{...}
{cmd:help xteventtest}
{hline}

{title:Title}

{phang}
{bf:xteventtest} {hline 2} Hypothesis Testing after Estimation of Panel Event Study


{marker syntax}{...}
{title:Syntax}

{pstd}

{p 8 17 2}
{cmd:xteventtest}
{cmd:,}
[{it:options}]

{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{p2coldent: {opth coefs(numlist)}} coefficients to be tested{p_end}
{p2coldent: {opt cumul}} test sum of coefficients{p_end}
{p2coldent: {opt allpre}} test all pre-event coefficients{p_end}
{p2coldent: {opt allpost}} test all post-event coefficients{p_end}
{p2coldent: {opt lin:pretrend}} test for a linear pre-trend{p_end}
{p2coldent: {opt tr:end(#1)}} tests for a linear trend from time period #1 before treatment{p_end}
{p2coldent: {opt const:anteff}} test for constant post-event coefficients{p_end}
{p2coldent: {opt overid}} test overidentifyng restrictions for pretrends and effects leveling off{p_end}
{p2coldent: {opth overidpre(integer)}} test overidentifyng restriction for pretrends{p_end}
{p2coldent: {opth overidpost(integer)}} test overidentifyng restriction for effects leveling off{p_end}
{p2coldent: {opt testopts(string)}} options to be passed to {cmd:test}{p_end}
{synoptline}
{p2colreset}{...}

{marker description}{...}
{title:Description}

{pstd}
{cmd: xteventtest} tests common hypotheses after {cmd:xtevent}. {p_end}


{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opth coefs(numlist)} specifies a numeric list of event-times to be tested. These are tested to be equal to 0 jointly, unless otherwise requested in {cmd:testopts()}.

{phang}
{opt cumul} requests a test of equality to 0 for the sum of every coefficient for each event-time in {cmd:coefs()}.

{phang}
{opt allpre} tests that all pre-event coefficients are equal to 0. With {cmd:cumul}, it tests that the sum of all pre-event coefficients is equal to 0.

{phang}
{opt allpost} tests that all post-event coefficients are equal to 0. With {cmd:cumul}, it tests that the sum of all post-event coefficients is equal to 0.

{phang}
{opt linpretrend} requests a specification test to see if the coefficients before the event follow a linear trend.

{phang}
{opt trend(#1)} tests for a linear trend from time period #1 before the policy change. It uses {opt xtevent, trend(#1, method(ols))} to estimate the trend. #1 must be less than 0.

{phang}
{opt constanteff} tests that all post-event coefficients are equal.

{phang}
{opt overid} tests overidentifying restrictions: a test for pre-trends and a test for events leveling-off. The periods to be tested are those
used in the {cmd xtevent} call. See {help xtevent}.

{phang}
{opth overidpre(#1)} tests the pre-trends overidentifying restriction. It tests that the coefficients for the earliest #1 periods before the event
are equal to 0. #1 must be greater than 0.

{phang}
{opth overidpost(#1)} tests the effects leveling off overidentifying restriction. It tests that the coefficients for the latest #1 periods after  
the event are equal. #1 must be greater than 0.

{phang}
{opt testopts(string)} specifies options to be passed to {cmd:test}. See {help test}.

{title:Examples}

{marker saved}{...}
{title:Saved Results}

{pstd}
{cmd:xteventtest} stores the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(p)}}two-sided p-value{p_end}
{synopt:{cmd:r(F)}}F statistic{p_end}
{synopt:{cmd:r(df)}}test constraints degrees of freedom{p_end}
{synopt:{cmd:r(df_r)}}residual degrees of freedom{p_end}
{synopt:{cmd:r(dropped_i)}}index of {it:i}th constraint dropped{p_end}
{synopt:{cmd:r(chi2)}}chi-squared{p_end}
{synopt:{cmd:r(drop)}}{cmd:1} if constraints were dropped, {cmd:0} otherwise{p_end}


{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Macros}{p_end}
{synopt:{cmd:r(mtmethod)}}method of adjustment for multiple testing{p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:r(mtest)}}multiple test results{p_end}


{title:Authors}

{pstd}Simon Freyaldenhoven, Federal Reserve Bank of Philadelphia.{p_end}
       simon.freyaldenhoven@phil.frb.org
{pstd}Christian Hansen, University of Chicago, Booth School of Business.{p_end}
       chansen1@chicagobooth.edu
{pstd}Jorge Pérez Pérez, Banco de México{p_end}
       jorgepp@banxico.org.mx
{pstd}Jesse Shapiro, Brown University{p_end}
       jesse_shapiro_1@brown.edu	   
           
{title:Support}    
           
{pstd}For support and to report bugs please email Jorge Perez Perez, Banco de México.{break} 
       jorgepp@banxico.org.mx   
      
