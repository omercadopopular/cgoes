{smcl}
{* 13 August 2014}{...}
{cmd:help stnd_streettype}{right: ({browse "http://www.stata-journal.com/article.html?article=dm0082":SJ15-3: dm0082})}
{hline}

{title:Title}

{p2colset 5 24 26 2}{...}
{p2col :{cmd:stnd_streettype} {hline 2}}Standardize a string variable
containing street types{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 23 2}
{cmd:stnd_streettype} {it:varname} {ifin} [{cmd:,} {cmdab:p:atpath(}{it:directory_of_pattern_files}{cmd:)} {cmdab:warn:ingmsg(on}|{cmd:off)}]


{title:Description}

{pstd}
{cmd:stnd_streettype} standardizes street types appearing in a string
variable.  It is used together with other commands to standardize addresses
(see {helpb stnd_address}).  The sequence of these commands is important
because some commands rely on standardization procedures being done in earlier
stages.  While advanced users may apply this command directly, it is not
recommended without first carefully inspecting the associated pattern
file.{p_end}


{title:Options}

{phang}
{opt patpath(directory_of_pattern_files)} specifies an alternative location
for the pattern file to be used in the standardizing process.  The
{cmd:stnd_streettype} command is based on a pattern file listing strings to be
standardized.  The pattern file is called {cmd:P110_std_streettypes.csv}.  By
default, the program looks for this pattern file in the default directory,
{cmd:ado/plus/p/}.  Specifying {cmd:patpath()} tells the program to look for
this file in a different directory.{p_end}

{phang}
{cmd:warningmsg(on}|{cmd:off)} is set to {cmd:warningmsg(on)} by default, and
the program displays a warning message when the {cmd:P110_std_streettypes.csv}
is not found and skips the remaining steps.  Specifying {cmd:warningmsg(off)}
will suppress the warning message.{p_end}


{title:Example}

{pstd}
Standardize street type in a string variable {cmd:add}{p_end}

{phang2}{cmd:. stnd_streettype add}

{pstd}
Applied to {cmd:"1722 ROUTH STREET"}, the command will replace with {cmd:"1722 ROUTH ST"}.

{pstd}
Applied to {cmd:"175 BROADHOLLOW ROAD"}, the command will replace with {cmd:"175 BROADHOLLOW RD"}.{p_end}


{title:Author}

{pstd}Nada Wasi{p_end}
{pstd}Survey Research Center{p_end}
{pstd}Institute for Social Research{p_end}
{pstd}University of Michigan{p_end}
{pstd}Ann Arbor, MI{p_end}
{pstd}{browse "mailto:nwasi@umich.edu":nwasi@umich.edu}


{title:Also see}

{p 4 14 2}Article:  {it:Stata Journal}, volume 15, number 3: {browse "http://www.stata-journal.com/article.html?article=dm0082":dm0082}{p_end}
