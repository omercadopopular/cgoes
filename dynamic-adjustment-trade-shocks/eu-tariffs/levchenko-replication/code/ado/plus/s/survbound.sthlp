{smcl}
{* *! version 1.0.0 17Oct2016 Long Hong}
{cmd: help survbound}
{hline}

{title: Title}

{phang}
{bf: survbound} - Non-parametric Gini index estimation for censored data


{title: Syntax}

{phang}
{cmd: survbound} {it:varname} {cmd:,} {cmdab:thres:hold(}{it:real}{cmd:)} 
{cmd:censorpct(}{it:real}{cmd:)} [{cmd:grid(}{it:integer}{cmd:)}]

{synoptset 16 tabbed}{...}
{synopthdr: Options}
{synoptline}
{synopt:{it:threshold}} Threshold. Exact values below the threshold are unknown due to 
						left-censoring; the value should {bf:not} be larger
						than the minimum value of the observation. {p_end}
{synopt:{it:censorpct}} Left-censoring percentage. Input a value in {bf:(0,1)} for 
                        the percentage of the left-censored observations. {p_end}
{synopt:{it:grid}(optional)} Allow "grid search". Input a positive integer. {p_end}
{synoptline}


{title: Description}

{pstd}{cmd:survbound} estimates the Gini index non-parametrically for 
left-censored data with a fixed threshold. {p_end}


{title: Example}

{pstd} We illustrate by using the historical household income in England 
(Alfani and Garcia Montero, 2017). 
Since the income data are tax-based, 30% of the household's incomes are 
not documented because their incomes are below the tax-paying threshold, 10 
shilings. Without knowing the distribution, we can use {cmd:survbound} to 
estimate the lower and upper bounds of the Gini index as follows. {p_end}

    {com}. survbound income, thres(10) censorpct(0.30) grid(10)
      {res} 
      {txt}Non-Parametric Gini Numeric Boundaries: 
      {res}
      {txt}{space 0}{hline 21}{c  TT}{hline 11}{hline 11}{hline 11}
      {space 0}{space 0}{ralign 20:}{space 1}{c |}{space 1}{ralign 9:Lower(A)}{space 1}{space 1}{ralign 9:Upper(A)}{space 1}{space 1}{ralign 9:Upper(G)}{space 1}
      {space 0}{hline 21}{c   +}{hline 11}{hline 11}{hline 11}
      {space 0}{space 0}{ralign 20:Non-Parametric Gini}{space 1}{c |}{space 1}{ralign 9:{res:{sf: .4275492}}}{space 1}{space 1}{ralign 9:{res:{sf: .5787303}}}{space 1}{space 1}{ralign 9:{res:{sf: .5389827}}}{space 1}
      {space 0}{hline 21}{c  BT}{hline 11}{hline 11}{hline 11}
      Lower(A): Analytic lower bound
      Upper(A): Analytic upper bound
      Upper(G): Upper bound approximation by Grid-search


{title: Saved Results}

{pstd}{cmd:survbound} saves the following in {cmd: r()}{p_end}

{pstd}Scalars{p_end}
{synoptset 16 tabbed}
{synopt: {cmdab:r(lower_a)}} Analytical lower bound {p_end}
{synopt: {cmdab:r(upper_a)}} Analytical upper bound {p_end}
{synopt: {cmdab:r(upper_g)}} Upper bound approximation by "grid search"{p_end}


{title: Author}

{pstd}Long Hong{p_end}
{pstd}Department of Economics{p_end}
{pstd}University of Wisconsin - Madison{p_end}
{pstd}Madison, WI, USA{p_end}
{pstd}{browse "mailto:long.hong@wisc.edu":long.hong@wisc.edu}


{title:References}

{pstd}Alfani, G. and Garcia Montero, H. (2017). 
Wealth Inequality in Preindustrial England:A Long-Term View 
(Thirteenth to Seventeenth Centuries), {it:forthcoming}.{p_end}

{pstd}Sajaia, Z. (2007). FASTGINI: Stata module to calculate Gini coefficient 
with jackknife standard errors, {it: Statistical Software Components S456814}, 
Boston College Department of Economics. {p_end}


