{smcl}
{* *! version 1.1  11jan2010}{...}
{cmd:help sax12diag}{right:({browse "http://www.stata-journal.com/article.html?article=st0255":SJ12-2: st0255})}
{right:dialog:  {dialog sax12diag}}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col :{hi:sax12diag} {hline 2}}Diagnostics table for X-12-ARIMA seasonal adjustment{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 13 2}
{cmd:sax12diag} {it:adjusted_results} {helpb using} {it:filenames} [{cmd:,} {opt noprint}]

{pstd}where the {it:adjusted_results} are the diagnostics files with the
extension {cmd:.udg}; see the examples below.{p_end}


{marker s_descrip}{title:Description}

{pstd}The diagnostics table contains the following information.
Refer to {browse "http://www.census.gov/srd/www/winx12/winx12doc.html#DiagnosticsTableOutput":http://www.census.gov/srd/www/winx12/winx12doc.html#DiagnosticsTableOutput} for more information.

{synoptset 26}
{synopthdr:diagnostics}
{synoptline}
{synopt:General information:}{p_end}
{synopt:{opt {space 2}Series name}} name of series{p_end}
{synopt:{opt {space 2}Frequency}} 4 or 12{p_end}
{synopt:{opt {space 2}Sample}} span of data adjusted{p_end}
{synopt:{opt {space 2}Transformation}} data transformation; includes "**" if transformation was automatically selected{p_end}
{synopt:{opt {space 2}Adjustment mode}} seasonal adjustment mode; includes "**" if mode was automatically selected{p_end}
{synopt:{opt {space 2}Seasonal peak}} indicate whether spectrum of seasonally adjusted series, irregular, or residuals have visually significant seasonal peak{p_end}
{synopt:{opt {space 2}Trading day peak}} indicate whether spectrum of seasonally adjusted series, irregular, or residuals have visually significant trading day peak{p_end}
{synopt:{opt {space 2}Peak of TD in adj}} indicate visually significant trading day peaks in spectrum of seasonally adjusted series{p_end}
{synopt:{opt {space 2}Peak of Seas. in adj}} indicate visually significant seasonal peaks in spectrum of seasonally adjusted series{p_end}
{synopt:{opt {space 2}Peak of TD in res}} indicate visually significant trading day peaks in spectrum of residuals{p_end}
{synopt:{opt {space 2}Peak of Seas. in res}} indicate visually significant seasonal peaks in spectrum of residuals{p_end}
{synopt:{opt {space 2}Peak of TD in irr}} indicate visually significant trading day peaks in spectrum of irregular{p_end}
{synopt:{opt {space 2}Peak of Seas. in irr}} indicate visually significant seasonal peaks in spectrum of irregular{p_end}
{synopt:{opt {space 2}Peak of TD in ori}} indicate visually significant trading day peaks in spectrum of (possibly differenced, transformed, prior-adjusted) original series{p_end}
{synopt:{opt {space 2}Peak of Seas. in ori}} indicate visually significant seasonal peaks in spectrum of (possibly differenced, transformed, prior-adjusted) original series{p_end}

{synopt:Diagnostic statistics:}{p_end}
{synopt:{opt {space 2}M1}} relative contribution of irregular over 3-month span{p_end}
{synopt:{opt {space 2}M2}} relative contribution of irregular component to stationary portion of variance{p_end}
{synopt:{opt {space 2}M3}} amount of period-to-period change in irregular
component as compared with amount of period-to-period change in trend cycle{p_end}
{synopt:{opt {space 2}M4}} amount of autocorrelation in irregular as described by average duration of run{p_end}
{synopt:{opt {space 2}M5}} number of months it takes change in trend cycle to surpass amount of change in irregular{p_end}
{synopt:{opt {space 2}M6}} amount of year-to-year change in irregular as
compared with amount of year-to-year change in seasonal{p_end}
{synopt:{opt {space 2}M7}} amount of moving seasonality present relative to amount of stable seasonality{p_end}
{synopt:{opt {space 2}M8}} size of fluctuations in seasonal component throughout whole series{p_end}
{synopt:{opt {space 2}M9}} average linear movement in seasonal component{p_end}
{synopt:{opt {space 2}M10}} same as M8 but calculated for recent years only{p_end}
{synopt:{opt {space 2}M11}} same as M9 but calculated for recent years only{p_end}
{synopt:{opt {space 2}Q}} weighted average of M1-M11{p_end}
{synopt:{opt {space 2}Q without M2}} weighted average of M1-M11 without M2{p_end}
{synopt:{opt {space 2}Moving seas. test(%)}} F statistic and its p-value of test for seasonality assuming stability from D8 table{p_end}
{synopt:{opt {space 2}Seasonality KW test(%)}} KW statistic and its p-value of test for seasonality assuming stability{p_end}
{synopt:{opt {space 2}Seasonality F test(%)}} F statistic and its p-value for test for moving seasonality{p_end}

{synopt:regARIMA model:}{p_end}
{synopt:{opt {space 2}Model span}} span of data used to estimate regARIMA model coefficients{p_end}
{synopt:{opt {space 2}Model}} ARIMA model; "**" indicates model was selected automatically by program{p_end}
{synopt:{opt {space 2}Num. of regressors}} number of regressors included in model{p_end}
{synopt:{opt {space 2}Num. of sig. AC}} number of significant autocorrelation in residuals{p_end}
{synopt:{opt {space 2}Num. of sig. PAC}} number of significant seasonal
autocorrelation in residuals{p_end}
{synopt:{opt {space 2}Normal}} indicate whether residuals pass normality tests{p_end}
{synopt:{opt {space 2}Skewness}} skewness of residual{p_end}
{synopt:{opt {space 2}Kurtosis}} kurtosis of residual{p_end}
{synopt:{opt {space 2}AICC}} F-adjusted Akaike's information criterion{p_end}

{synopt:Outliers:}{p_end}
{synopt:{opt {space 2}Outlier span}} span of data checked for outliers{p_end}
{synopt:{opt {space 2}Total outliers}} number of all outliers{p_end}
{synopt:{opt {space 2}Auto detected outliers}} number of outliers automatically selected{p_end}
{synopt:{opt {space 2}AO critical}} critical |t| for additive outliers; "*" indicates it was chosen by X-12-ARIMA{p_end}
{synopt:{opt {space 2}LS critical}} critical |t| for level shifts; "*" indicates it was chosen by X-12-ARIMA{p_end}
{synopt:{opt {space 2}TC critical}} critical |t| for temporary change outliers; "*" indicates it was chosen by X-12-ARIMA{p_end}
{synopt:{opt {space 2}Outliers}} all outliers, including user-defined and automatically detected outliers{p_end}

{synopt:Stability analysis:}{p_end}
{synopt:{opt {space 2}Revision span}} span of data of revision history analysis{p_end}
{synopt:{opt {space 2}Span num.,length, start}} number of spans for sliding
spans analysis, length of each span, start month (quarter), and start year{p_end}
{synopt:{opt {space 2}Unstable SF}} months (quarters) with maximum absolute
percent change of seasonal factors greater than threshold, total months, and percent{p_end}
{synopt:{opt {space 2}Unstable MM change in SA}} months (quarters) with
maximum absolute difference of period-to-period change in seasonally adjusted
series greater than threshold, total months, and percent{p_end}
{synopt:{opt {space 2}Unstable YY change in SA}} months (quarters) with
maximum absolute difference of year-to-year change in seasonally adjusted
series greater than threshold, total months, and percent{p_end}
{synopt:{opt {space 2}Ave. abs. perc. rev.}} average absolute percent revisions of seasonal adjustments{p_end}
{synoptline}


{title:Option}

{phang}{opt noprint} indicates not to print the diagnostics table on the
screen.


{title:Examples}

{phang}{bf:{stata `". sax12diag "retail.udg" "'}}

{phang}{bf:{stata `". sax12diag "agri.udg" "gdp.udg" using mydiag.txt"'}}


{title:Author}

{pstd}Qunyong Wang{p_end}
{pstd}Institute of Statistics and Econometrics{p_end}
{pstd}Nankai University{p_end}
{pstd}brynewqy@nankai.edu.cn{p_end}


{title:Also see}

{p 4 14 2}Article:  {it:Stata Journal}, volume 12, number 2: {browse "http://www.stata-journal.com/article.html?article=st0255":st0255}

{p 7 14 2}Help:  {helpb sax12}, {helpb sax12im}, {helpb sax12del} (if
installed){p_end}
