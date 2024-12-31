{smcl}
{* *! version 1.0 28 Jul 2020}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install command2" "ssc install command2"}{...}
{vieweralsosee "Help command2 (if installed)" "help command2"}{...}
{viewerjumpto "Syntax" "stackedcount##syntax"}{...}
{viewerjumpto "Description" "stackedcount##description"}{...}
{viewerjumpto "Options" "stackedcount##options"}{...}
{viewerjumpto "Remarks" "stackedcount##remarks"}{...}
{viewerjumpto "Examples" "stackedcount##examples"}{...}
{title:Title}
{phang}
{bf:stackedcount} {hline 2} produce a stacked area graph

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:stackedcount}
{it:varlist}
(min=2
max=2
numeric)
[{help if}]
[{help in}]
[{cmd:,}
{it:options}]

{tab}{tab}where {it:varlist} is

{tab}{tab}{it:y x}

{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Optional}
{synopt:{opt xlabel(rule_or_values)}} see {help axis_label_options}{p_end}
{synopt:{opt xtick(rule_or_values)}} see {help axis_label_options}{p_end}
{synopt:{opt xmtick(rule_or_values)}} see {help axis_label_options}{p_end}
{synopt:{opt xtitle(string)}} see {help axis_title_options}{p_end}
{synopt:{opt xrange(numlist)}} see {help axis_scale_options}{p_end}
{synopt:{opt ylabel(rule_or_values)}} see {help axis_label_options}{p_end}
{synopt:{opt ytick(rule_or_values)}} see {help axis_label_options}{p_end}
{synopt:{opt ymtick(rule_or_values)}} see {help axis_label_options}{p_end}
{synopt:{opt ytitle(string)}} see {help axis_title_options}{p_end}
{synopt:{opt yscale(numlist)}} see {help axis_scale_options}{p_end}
{synopt:{opt caption(string)}} see {help title_options}{p_end}
{synopt:{opt caption(string)}} see {help title_options}{p_end}
{synopt:{opt note(string)}} see {help scheme_option}{p_end}
{synopt:{opt legend(string)}} see {help legend_options}{p_end}

{marker description}{...}
{title:Description}
{pstd}

{pstd}
{cmd:stackedcount} produces a stacked area graph for the frequencies (y-axis) of the categories in a labeled numeric categorical
variable as a function of a discrete numeric variable (x-axis).

{pstd}
{it:varlist} is 

{pstd}
{it:y x}

{pstd}
x is a numeric variable that takes on discrete values, for example calendar year, or age in years. The values of x do not need to be integers. The program will not round x or otherwise bin observations according to values of x.    

{pstd}
y is a categorical numeric variable for which the frequencies at each value of x are to be plotted. There must be at least two distinct values. If y takes on only one value, you should just use {help twoway_area}.

{pstd}
Categories will be stacked in order of the original numeric values of y, from bottom to top in order of ascending values of y. 

{pstd}
The values of the categorical variable that is the basis of y must be labelled. If any values are unlabelled, the program will exit with error code 182.

{pstd}
If the categorical variable you want to plot is a string variable, encode beforehand to create a labeled numeric categorical variable.

Please see {browse "https://camerondcampbell.blog/stacked-area-graphs-in-stata/": https://camerondcampbell.blog/stacked-area-graphs-in-stata/} for examples.

{pstd}

{marker options}{...}
{title:Options}
{dlgtab:Main}
{phang}
{opt xlabel(string)} see {help axis_label_options}{p_end}
{phang}
{opt xtick(rule_or_values)} see {help axis_label_options}{p_end}
{phang}
{opt xmtick(rule_or_values)} see {help axis_label_options}{p_end}
{phang}
{opt xtitle(string)} see {help axis_title_options}{p_end}
{phang}
{opt xrange(numlist)} see {help axis_scale_options}{p_end}
{phang}
{opt ylabel(rule_or_values)} see {help axis_label_options}{p_end}
{phang}
{opt ytick(rule_or_values)} see {help axis_label_options}{p_end}
{phang}
{opt ymtick(rule_or_values)} see {help axis_label_options}{p_end}
{phang}
{opt ytitle(string)} see {help axis_title_options}{p_end}
{phang}
{opt yscale(numlist)} see {help axis_scale_options}{p_end}
{phang}
{opt caption(string)} see {help title_options}{p_end}
{phang}
{opt caption(string)} see {help title_options}{p_end}
{phang}
{opt note(string)} see {help scheme_option}{p_end}
{phang}
{opt legend(string)} see {help legend_options}{p_end}

{pstd}
{p_end}

{marker examples}{...}
{title:Examples}
{pstd}

{pstd}
stacked_percent guanzhi_js gap if gap >= 0.5 & gap <= 20 & (甲第 == 1 | 甲第 == 2) & !qiren, 
legend(size(small) cols(4)) xtitle("Years since exam") ytitle("Percent") 
caption("Positions held by jinshi since years since exam 甲第 1 2 - non-Banner") 
note("")


{title:Author}
{p}

Cameron Campbell, HKUST.

Email {browse "mailto:camcam@ust.hk":camcam@ust.hk}



