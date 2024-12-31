{smcl}
{* *! version .0 Jun 24 2022}{...}
{cmd:help xteventplot}
{hline}

{title:Title}

{phang}
{bf:xteventplot} {hline 2} Plots After Estimation of Panel Event Study


{marker syntax}{...}
{title:Syntax}

{pstd}

{p 8 17 2}
{cmd:xteventplot}
{cmd:,}
[{it:options}]

{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opth suptreps(integer)}} number of repetitions for sup-t confidence intervals{p_end}
{synopt:{opt overlay(string)}} generate overlay plots{p_end}
{synopt:{opt y}} generate event study plot for dependent variable in IV setting{p_end}
{synopt:{opt proxy}} generate event study plot for proxy variable in IV setting{p_end}
{synopt:{opt lev:els(numlist)}} customize confidence levels for plot{p_end}
{synopt:{opt sm:path([type, subopt])}} smoothest path through confidence region{p_end}
{synopt:{opt overidpre(integer)}} change pre-event coefficients to be tested{p_end}
{synopt:{opt overidpost(integer)}} change post-event coefficients to be tested{p_end}

{syntab:Appearance}
{synopt: {opt noci}} omit all confidence intervals{p_end}
{synopt:{opt nosupt}} omit sup-t confidence intervals{p_end}
{synopt:{opt nozero:line}} omit reference line at 0{p_end}
{synopt:{opt nomin:us1label}} omit label for value of dependent variable at event-time = -2 {p_end}
{synopt:{opt noprepval}} omit p-vale for pre-trends test{p_end}
{synopt:{opt nopostpval}} omit p-vale for leveling-off test{p_end}
{synopt:{opt scatterplot:opts(string)}} graphics options for coefficient scatter plot{p_end}
{synopt:{opt ciplot:opts(string)}} graphics options for confidence interval plot{p_end}
{synopt:{opt suptciplot:opts(string)}} graphics options for sup-t confidence interval plot{p_end}
{synopt:{opt smplot:opts(string)}} graphics options for smoothest path plot{p_end}
{synopt:{opt trendplot:opts(string)}} graphics options for extrapolated trend plot{p_end}
{synopt:{opt staticovplot:opts(string)}} graphics options for the static effect overlay plot {p_end}
{synopt:{opt textboxoption(string)}} textbox options for displaying the p-values of the pre-trend and leveling-off tests{p_end}
{synopt:{opt addplots(string)}} plot to be overlaid on event-study plot{p_end}
{synopt:{it: additional_options}} additional options to be passed to {cmd:twoway}{p_end}

{synoptline}
{p2colreset}{...}

{marker description}{...}
{title:Description}

{pstd}
{cmd: xteventplot} produces event-study plots after {cmd:xtevent}. {p_end}

{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opth suptreps(integer)} specifies the number of repetitions to calculate Montiel Olea and Plagborg-Møller (2019) sup-t confidence intervals for
the dynamic effects. The default is 1000. See {help xtevent}.

{phang}
{opt overlay(string)} creates overlay plots for trend extrapolation, instrumental variables estimation in presence of pre-trends, and constant 
policy effects over time.

{phang2} {opt overlay(trend)} Overlays the event-time coefficients for the trajectory of the dependent variable and the extrapolated linear trend.

{phang2} {opt overlay(iv)} Overlays the event-time coefficients trajectory of the dependent variable and the proxy variable used to infer the 
trend of the confounder.

{phang2} {opt overlay(static)} Overlays the event-time coefficients from the estimated model and the coefficients implied by a constant policy
effect over time.

{phang}
{opt y} creates an event-study plot of the dependent variable in instrumental variables estimation.

{phang}
{opt proxy} creates an event-study plot of the proxy variable in instrumental variables estimation.

{phang}
{opt levels(numlist)} customizes the confidence level for the confidence intervals in the event-study plot. By default, two confidence
intervals -- a standard confidence interval and a sup-t confidence interval -- are drawn for the confidence interval stored in c(level).
{opt levels} allows different confidence levels for standard confidence intervals. For example, {opt levels(90 95)} draws both 90% and 95% level
confidence intervals, along with a sup-t confidence interval for the confidence level stored in c(level).

{phang}
{opt smpath([type , subopt])}} displays values on the smoothest line through the sup-t confidence region. {opt type} determines the line type, which may be {opt scatter} or {opt line}.  {opt smpath} is not allowed with {opt noci}. 

{phang} The following suboptions for {opt smpath} control the optimization process. Because of the nature of the 
optimization problem, optimization error messages 4 and 5 (missing derivatives) or 8 (flat regions) may be
 frequent. Nevertheless, the approximate results from the optimization should be close to the results that 
 would be obtained with convergence of the optimization process. Modifying these optimization suboptions may improve optimization behavior.

{phang2}
{opt , postwindow(scalar > 0)} sets the number of post event coefficient estimates to use for calculating the 
smoothest line. The default is to use
all the estimates in the post event window.

{phang2}
{opt , maxiter(integer)} sets the maximum number of inner iterations for optimization. The default is 100.

{phang2}
{opt , maxorder(integer)} sets the maximum order for the polynomial smoothest line. Maxorder must be between 1 and 10. The default is 10.

{phang2} 
{opt , technique(string)} sets the optimization technique for the inner iterations of the quadratic program.
"nr", "bfgs", "dfp", and combinations are allowed. See {help maximize}. The default is "dfp". 

{phang}
{opt overidpre} changes the coefficients to be tested for the pre-trends overidentification test. 
The default is to test all pre-event coefficients. {opt overidpre(#1)} tests if the coefficients 
for the earliest #1 periods before the event are equal to 0. #1 must be greater than 0.  See 
 {help xteventtest}.

{phang}
{opt overidpost} changes the coefficients to be tested for the leveling-off overidentification
 test. The default is to test that the rightmost coefficient and the previous coefficient are
 equal. {opt overidpost(#1)} tests if the coefficients for the latest #1 periods after the event
 are equal to each other. See {help xteventtest}.

{dlgtab:Appearance}

{phang}
{opt noci} omits the display and calculation of both Wald and sup-t confidence intervals. {opt noci} overrides {opt suptreps} if it is specified.
{opt noci} is not allowed with {opt smpath}.

{phang}
{opt nosupt} omits the display and calculation of sup-t confidence intervals. {opt nosupt} overrides {opt suptreps} if it is specified.

{phang}
{opt nozeroline} omits the display of the reference line at 0. Note that reference lines with different styles can be obtained by removing the 
default line with {opt nozeroline} and adding other lines with {opt yline}. See {help added_line_options}. 

{phang}
{opt nominus1label} omits the display of the label for the value of the dependent variable at 
event-time = -1.

{phang}
{opt noprepval} omits the display of the p-value for a test for pre-trends. The test is a Wald test 
for all the pre-event coefficients being equal to 0.

{phang}
{opt nopostpval} omits the display of the p-value for a test for effects leveling off. The test is
a Wald test for the last post-event coefficients being equal.

{phang}
{opt scatterplotopts} specifies options to be passed to {cmd:scatter} for the coefficients plot.

{phang}
{opt ciplotopts} specifies options to be passed to {cmd:rcap} for the confidence interval 
plot. These options are disabled if {opt noci} is specified.

{phang}
{opt suptciplotopts} specifies options to be passed to {cmd:rcap} for the sup-t confidence
 interval plot. These options are disabled if {opt nosupt} is specified.
 
{phang}
{opt smplotopts} specifies options to be passed to {cmd:line} for the smoothest path through 
the confidence region plot. These options are only active if {opt smpath} is specified.

{phang}
{opt trendplotopts} specifies options to be passed to {cmd:line} for the extrapolated trend
overlay plot. These options are only active if {opt overlay(trend)} is specified.

{phang}
{opt staticovplotopts} specifies options to be passed to {cmd:line} for the static effect overlay
 plot. These options are only active if {opt overlay(static)} is specified.

{phang}
{opt addplots} specifies additional plots to be overlaid to the event-study plot.

{phang}
{opt textboxoption} specifies options to be passed to the textbox of the pre-trend and leveling-off tests. These options are disabled if {opt noprepval} and {opt nopostval} are specified. See {help textbox_options}.

{phang}
{it: additional_options}: Additional options to be passed to {cmd:twoway}. See {help twoway}.

{title:Examples}

{hline}
{pstd}Setup{p_end}
{phang2}{cmd:. webuse nlswork}{p_end}
{phang2}{cmd:. xtset idcode year}{p_end}

{hline}
{pstd}Basic event study with clustered standard errors{p_end}
{phang2}{cmd:. xtevent ln_w age c.age#c.age ttl_exp c.ttl_exp#c.ttl_exp tenure , pol(union) w(3) cluster(idcode)}
{p_end}

{pstd}Plot{p_end}
{phang2}{cmd:. xteventplot}{p_end}

{pstd}Supress confidence intervals or sup-t confidence intervals{p_end}
{phang2}{cmd:. xteventplot, noci}{p_end}
{phang2}{cmd:. xteventplot, nosupt}{p_end}

{pstd}Plot smoothest path in confidence region{p_end}
{phang2}{cmd:. xteventplot, smpath(line)}{p_end}
{phang2}{cmd:. xteventplot, smpath(line, technique(nr 10 bfgs 10))}{p_end}

{pstd}Adjust textbox options for the p-values of the pre-trend and leveling-off tests{p_end}
{phang2}{cmd:. xteventplot, textboxoption(color(blue) size(large))}{p_end}

{hline}

{pstd}FHS estimator with proxy variables{p_end}
{phang2}{cmd:. xtevent ln_w age c.age#c.age ttl_exp c.ttl_exp#c.ttl_exp tenure , pol(union) w(3) vce(cluster idcode) proxy(wks_work)}{p_end}

{pstd}Dependent variable, proxy variable, and overlay plots{p_end}
{phang2}{cmd:. xteventplot, y}{p_end}
{phang2}{cmd:. xteventplot, proxy}{p_end}
{phang2}{cmd:. xteventplot, overlay(iv)}{p_end}
{phang2}{cmd:. xteventplot}{p_end}

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
           
{pstd}For support and to report bugs please email Jorge Pérez Pérez, Banco de México.{break} 
       jorgepp@banxico.org.mx  
	   
