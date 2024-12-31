{smcl}
{* *! version 1.0 01aug2014}{...}

{title:Title}
{phang}
{bf:xtine} {hline 2} Calculate percentile and quantile for a numeric variable.


{title:Syntax}
{p 8 17 2}
{cmd:xtine} varlist [if] [in], nq(integer) 

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt nq}} number of quantiles (integer)
{synoptline}
{p2colreset}{...}

{cmd:by} is not allowed
{cmd:fweight}s are not allowed
{pstd}


{title:Description}
{pstd}
{cmd:xtine} is used to generate  two variables, one containing percentile and the other containing quantile. The new percentile variables end with the suffix *_pctile, and the quantile variables end with the suffix *_[nq]. Xtine is similar to STATA's xtile command, but is able to make more evenly distributed quantiles.


{title:Remarks}
{pstd}
The number of quantiles must be specified.

The formula used to calculate percentile is as follows:
percentile=(([count below]+(.5*[count equal]))/[count])*100


{title:Examples}
{phang}
{cmd:. xtine gre_score satm, nq(5)}{p_end}
{phang}
{cmd:. xtine gre_score satm if gender==”M”, nq(3)}


{title:Author}
{pstd}
Christine Cook. West Point, NY

