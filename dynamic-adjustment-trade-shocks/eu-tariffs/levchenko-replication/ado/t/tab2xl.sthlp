{smcl}
{* *! version 1.0.2  16may2018}{...}
{* *! version 1.0.3  20jun2018}{...}
{* *! version 1.0.4  12jul2018}{...}
{vieweralsosee "[D] export" "help export"}{...}
{vieweralsosee "[D] import" "help import"}{...}
{vieweralsosee "[P] postfile" "help postfile"}{...}
{vieweralsosee "[P] return" "help return"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[M-5] xl()" "help mf_xl"}{...}
{viewerjumpto "Syntax" "tab2xl##syntax"}{...}
{title:Title}

{p2colset 5 13 23 2}{...}
{p2col :{cmd:tab2xl}} {hline 2} Export one-way or two-way tabulate table to an Excel file{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 4 8 2}
{title:Basic syntax}

{p 8 32 2}
{cmd:tab2xl} {it:{help varlist:varname1}} [{it:{help varlist:varname2}}]
[{it:{help if:if}}] 
[{it:{help in:in}}] 
{cmd:using} {it:{help filename}}
[{it:{help weight:weight}}]{cmd:,} {cmd:col(}{it:integer}{cmd:)} {cmd:row(}{it:integer}{cmd:)} [{it:{help putexcel##options_tbl:options}}]
{p_end} 
{p 8 32 2}

{marker options_tbl}{...}
{synoptset 30}{...}
{synopthdr}
{synoptline}
{synopt :{opt replace}}overwrite Excel file{p_end}
{synopt :{cmdab:sh:eet("}{it:sheetname}{cmd:"} [{cmd:, replace}]{cmd:)}}write to Excel worksheet {it:sheetname}{p_end}
{synopt :{cmd:missing}}Create a new row/column for missing values{p_end}
{synopt :{cmd:summarize(}{it:{help varlist:varname}}{cmd:)}}Export a summary table of means
 and standard deviations. See {help tabulate_summarize:tabulate_summarize} for
 more information on the results.{p_end}
{synopt :{cmdab:perc:entage}}Export a table of relative frequencies, emulating
 the output of the row and col option in {help tabulate twoway:tabulate-twoway}
 .{p_end}
{synoptline}
{p 4 8 2}
{cmd:fweight}s, {cmd:aweight}s, and {cmd:iweight}s are allowed; see {help weight}.
{p2colreset}{...}

{marker description}{...}
{title:Description}

{pstd}
{cmd:tab2xl} will perform both one-way and two-way tabulation replicas with default formatting and labeling based on the data given. This command does not support string variables in two-way form. {...}

{pstd}
{cmd:tab2xl} was written for the Stata blog.  You can view the blog at {browse "https://blog.stata.com/2018/06/07/export-tabulation-results-to-excel-update/"}
{p_end}

{marker examples}{...}
{title:Remarks/Examples}

{pstd}
To demonstrate the use of tab2xl, we will load {cmd:auto.dta} and export a one-way tabulation of mpg to row one, column one of a file named auto.xlsx: {...}

{pstd}
{cmd:. webuse auto} {p_end}

{pstd}
(1978 Automobile Data) {...}

{pstd}
{cmd:. tab2xl mpg using auto, row(1) col(1)} {...}

{pstd}
A tabulation table will be written to the current document. It will simply modify the document, meaning that the file itself will not be overwritten, but any cells that previously had data will be overwritten if the table spans across it. {p_end}

{pstd}
If you want to rewrite the file from scratch, you will need to type {cmd:, replace} as an option. This is written as: {...}

{pstd}
{cmd:. tab2xl mpg using auto, row(1) col(1) replace} {...}

{pstd}
A two-way tabulation is also available. To create a table where mpg spans across the rows of the table and the car's origin(given the variable name foreign) spans across the columns, you might type: {...}

{pstd}
{cmd:. tab2xl mpg foreign using auto, row(1) col(1) replace} {...}


{pstd}
Note: Tab2xl does not support strings in two-way form, and will return an error code before opening or altering the file, leaving it untouched.
