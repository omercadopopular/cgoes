{smcl}
{* *! version 1.0.1  18jun2018}{...}
{vieweralsosee "[P] putdocx" "help putdocx"}{...}
{viewerjumpto "Syntax" "tab2docx##syntax"}{...}
{title:Title}

{p 4 8 2}
{cmd:tab2docx} {hline 2} Export tabulate table to a .docx file{p_end}
{...}


{marker syntax}{...}
{title:Syntax}

{p 4 8 2}
{title:Basic syntax}

{p 8 32 2}
{cmd:tab2docx} {it:{help varlist:varname}}
[{it:{help if:if}}] 
[{it:{help in:in}}] 
[{it:{help weight:weight}}]{cmd:,}
[{it:{help putexcel##options_tbl:options}}]


{marker options_tbl}{...}
{synoptset 30}{...}
{synopthdr}
{synoptline}
{synopt :{opt missing}}Create a new row for missing values, if available.{p_end}
{synopt :{cmd:filename("}{it:filename}{cmd:"} [{cmd:, replace}]{cmd:)}}Open, write to, and close the specified file before and after the tabulate is added. {it:sheetname}{p_end}
{synopt :{cmd:summarize(}{it:{help varlist:varname}}{cmd:)}}Exports a summary table of means and standard deviations.
See {help tabulate_summarize:tabulate_summarize} for more information on the results.{p_end}
{synoptline}
{p 4 8 2}
{cmd:fweight}s, {cmd:aweight}s, and {cmd:iweight}s are allowed; see {help weight}.
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
{cmd:tab2docx} will perform a one-way tabulation replica with default formatting and labeling based on the data given.
{cmd:tab2docx} was written for the Stata blog.  You can view the blog at {browse "http://blog.stata.com"}
{p_end}

{marker examples}{...}
{title:Remarks/Examples}

{pstd}
To demonstrate the use of tab2docx, we will load {cmd:auto.dta} and export a tabulation of mpg to a file named auto.docx: {...}

{pstd}
{cmd:. webuse auto} {p_end}

{pstd}
(1978 Automobile Data) {...}

{pstd}
{cmd:. putdocx begin} {p_end}
{pstd}
{cmd:. tab2docx mpg} {p_end}
{pstd} 
{cmd:. putdocx save auto} {p_end}

{pstd}
A tabulation table will now be appended to the current document, if it exists already. If not, you will need to type {cmd:, replace} as an option to generate a new file. This is written as: {...}

{pstd}
{cmd:. putdocx begin} {p_end}
{pstd}
{cmd:. tab2docx mpg} {p_end}
{pstd} 
{cmd:. putdocx save auto, replace} {p_end}

{pstd}
You may also use an option to open, write to, and then close a specific file all in this one command. To do so, you would write {p_end}

{pstd}
{cmd:. tab2docx mpg, filename(auto, replace)}
