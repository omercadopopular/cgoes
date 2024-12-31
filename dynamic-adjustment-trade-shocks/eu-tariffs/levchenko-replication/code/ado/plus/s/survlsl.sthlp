{smcl}
{* *! version 1.0.0 15Apr2017 Long Hong}
{cmd: help survlsl}
{hline}{hline}

{title: Title}

{phang}
{bf: survlsl} - Estimation of the Gini index for log-scale-location parametric models


{title: Syntax}

{phang}
{cmd: survlsl} {it:varname}{cmd:,} {cmdab:thres:hold(}{it:real}{cmd:)} 
{cmd:censorpct(}{it:real}{cmd:)} {cmd:model(}{it:string}{cmd:)}


{synoptset 16 tabbed}{...}
{synopthdr: Options}
{synoptline}
{synopt:{it:threshold}} Threshold. Exact values below threshold are unknown due to 
						left- censoring or truncation. The value should not be
						larger than the minimum value of the observations. {p_end}
{synopt:{it:censorpct}} Left-censoring percentage. Input {bf: 0} if the data are  
                        left-{it:truncated}; input a value in {bf:(0,1)} if the 
						data are left-{it:censored}. {p_end}
{synopt:{it:model}} Three models are available: {it:lognormal}, {it:weibull}, 
					and {it:loglogistic}. Please type the exact name in full. {p_end}
{synoptline}


{title: Description}

{pstd}{cmd:survlsl} estimates the Gini index using log-scale-location 
parametric models for left- censored or truncated data with a fixed threshold.
The current version contains {it:Log-normal}, {it:Weibull}, and {it:log-logistic} models. 


{title: Example}

{pstd} We illustrate by using the historical household income in England 
(Alfani and Garcia Montero, 2017). 
Since the income data are tax-based, 30% of the household's incomes are 
not documented because their incomes are below the tax-paying threshold, 10 
shilings. Assuming that the incomes follow a log-normal distribution, we can use 
{cmd:survlsl} to estimate the Gini index as follows. {p_end}

    {com}. survlsl income, thres(10) censorpct(0.30) model(lognormal)
    
      {txt}(...MLE inerations omitted...)
      {txt}(...Estimated parameters omitted...)

      {res}Left Censored Model
    
      {txt}Estimated Parameters: 
        MLE location  = 2.94
        MLE scale     = .9912

      {res}Parametric Gini = .5166
 
      {txt}Parametric Gini 95% Confidence Interval: 
        C.I. 1 is derived from the delta method;
        C.I. 2 is derived from a direct approach.
      {res}
      {txt}{space 0}{hline 16}{c  TT}{hline 11}{hline 11}
      {space 0}{space 0}{ralign 15:}{space 1}{c |}{space 1}{ralign 9:Lower}{space 1}{space 1}{ralign 9:Upper}{space 1}
      {space 0}{hline 16}{c   +}{hline 11}{hline 11}
      {space 0}{space 0}{ralign 15:Conf Interval 1}{space 1}{c |}{space 1}{ralign 9:{res:{sf:    .5079}}}{space 1}{space 1}{ralign 9:{res:{sf:    .5253}}}{space 1}
      {space 0}{space 0}{ralign 15:Conf Interval 2}{space 1}{c |}{space 1}{ralign 9:{res:{sf:    .5079}}}{space 1}{space 1}{ralign 9:{res:{sf:    .5253}}}{space 1}
      {space 0}{hline 16}{c  BT}{hline 11}{hline 11}

{pstd}If the data were instead truncated, please use {cmd:censorpct(0)} to flag this case.{p_end}


{title: Saved Results}

{pstd}{cmd:survlsl} saves the following in {cmd: r()}{p_end}

{pstd}Scalars{p_end}
{synoptset 16 tabbed}
{synopt: {cmdab:r(gini)}} Gini index calculated using parametric models {p_end}
{synopt: {cmdab:r(alpha)}} Location estimate for log-normal; scale estimate 
							for Wellbull or log-logistic{p_end}
{synopt: {cmdab:r(beta)}} Scale estimate for log-normal; shape estimate for 
							Wellbull or log-logistic {p_end}

{pstd}Matrices{p_end}
{synoptset 18 tabbed}
{synopt: {cmdab:r(estimates)}} maximum likelihood estimates {p_end}
{synopt: {cmdab:r(variances)}} Variance-covariance matrix {p_end}
{synopt: {cmdab:r(conf_interval)}} Confidence intervals {p_end}


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

{pstd}Bonetti, M., Gigliarano, C. and Basellini U. (2015). Longevity and 
concentration in survival times: the log-scale-location family of failure 
time models {it: Lifetime Data Analysis}{p_end}



