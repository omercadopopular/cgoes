{smcl}
{* 13 August 2014}{...}
{cmd:help stnd_secondaryadd}{right: ({browse "http://www.stata-journal.com/article.html?article=dm0082":SJ15-3: dm0082})}
{hline}

{title:Title}

{p2colset 5 26 28 2}{...}
{p2col:{cmd:stnd_secondaryadd} {hline 2}}Standardize a string variable containing secondary address information{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 25 2} 
{cmd:stnd_secondaryadd} {it:varname} {ifin} [{cmd:,} {cmdab:p:atpath(}{it:directory_of_pattern_files}{cmd:)} {cmdab:warn:ingmsg(on}|{cmd:off)}]


{title:Description}

{pstd}
{cmd:stnd_secondaryadd} standardizes secondary address information for a
string variable.  It is used together with other commands to standardize and
parse addresses (see {helpb stnd_address}).  The sequence of these commands is
important because some commands rely on standardization procedures being done
in earlier stages.  While advanced users may apply this command directly, it
is not recommended without first carefully inspecting the associated pattern
file.{p_end}


{title:Options}

{phang}
{opt patpath(directory_of_pattern_files)} specifies an alternative location
for the pattern file to be used in the standardizing process.  The
{cmd:stnd_secondaryadd} command is based on a pattern file listing strings to
be standardized.  The pattern file is called {cmd:P131_std_secondaryadd.csv}.
By default, the program looks for this pattern file in the default directory,
{cmd:ado/plus/p/}.  Specifying {cmd:patpath()} tells the program to look for
this file in a different directory.{p_end}

{phang}
{cmd:warningmsg(on}|{cmd:off)} is set to {cmd:warningmsg(on)} by default, and
the program displays a warning message when {cmd:P131_std_secondaryadd.csv} is
not found and skips the remaining steps.  Specifying {cmd:warningmsg(off)}
will suppress the warning message.{p_end}


{title:Example}

{pstd}
Standardize secondary address information in a string variable {cmd:add}{p_end}

{phang2}{cmd:. stnd_secondaryadd add}{p_end}

{pstd}
Applied to {cmd:"600 N MARKET BOULEVARD SUITE 5"}, the command will replace
with {cmd:"600 N MARKET BOULEVARD STE 5"}.


{title:Author}

{pstd}Nada Wasi{p_end}
{pstd}Survey Research Center{p_end}
{pstd}Institute for Social Research{p_end}
{pstd}University of Michigan{p_end}
{pstd}Ann Arbor, MI{p_end}
{pstd}{browse "mailto:nwasi@umich.edu":nwasi@umich.edu}


{title:Also see}

{p 4 14 2}Article:  {it:Stata Journal}, volume 15, number 3: {browse "http://www.stata-journal.com/article.html?article=dm0082":dm0082}{p_end}
