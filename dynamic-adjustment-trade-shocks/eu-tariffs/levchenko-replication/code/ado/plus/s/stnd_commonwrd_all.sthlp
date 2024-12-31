{smcl}
{* 13 August 2014}{...}
{cmd:help stnd_commonwrd_all}{right: ({browse "http://www.stata-journal.com/article.html?article=dm0082":SJ15-3: dm0082})}
{hline}

{title:Title}

{p2colset 5 27 29 2}{...}
{p2col :{cmd:stnd_commonwrd_all} {hline 2}}Standardize a string variable containing words that commonly appear in company names and addresses{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 26 2}
{cmd:stnd_commonwrd_all} {it:varname} {ifin} [{cmd:,} {cmdab:p:atpath(}{it:directory_of_pattern_files}{cmd:)} {cmdab:warn:ingmsg(on}|{cmd:off)}]


{title:Description}

{pstd}
{cmd:stnd_commonwrd_all} standardizes words that commonly appear in company
names and addresses for a string variable.  It is used together with other
commands to standardize and parse company names and addresses (see 
{helpb stnd_compname}, {helpb stnd_address}).  The sequence of these commands
is important because some commands rely on standardization procedures being
done in earlier stages.  While advanced users may apply this command directly,
it is not recommended without first carefully inspecting the associated
pattern file.{p_end}


{title:Options}

{phang}
{opt patpath(directory_of_pattern_files)} specifies an alternative location
for the pattern file to be used in the standardizing process.  The
{cmd:stnd_commonwrd_all} command is based on a pattern file listing strings to
be standardized.  The pattern file is called {cmd:P50_std_commonwrd_all.csv}.
By default, the program looks for this pattern file in the default directory,
{cmd:ado/plus/p/}.  Specifying {cmd:patpath()} tells the program to look for
this file in a different directory.

{phang}
{cmd:warningmsg(on}|{cmd:off)} is set to {cmd:warningmsg(on)} by default, and
the program displays a warning message when the
{cmd:P50_std_commonwrd_all.csv} is not found and skips the remaining steps.
Specifying {cmd:warningmsg(off)} will suppress the warning message.


{title:Example}

{pstd}
Standardize common words for a string variable {cmd:firm_name}{p_end}

{phang2}
{cmd:. stnd_commonwrd_all firm_name}

{pstd}
Applied to {cmd:"MAINE MEDICAL CENTER"}, the command will replace with {cmd:"MAINE MEDICAL CTR"}.{p_end}

{pstd}
Applied to {cmd:"HONEYWELL INTERNATIONAL INC."}, the command will replace with {cmd:"HONEYWELL INTL INC."}{p_end}


{title:Author}

{pstd}Nada Wasi{p_end}
{pstd}Survey Research Center{p_end}
{pstd}Institute for Social Research{p_end}
{pstd}University of Michigan{p_end}
{pstd}Ann Arbor, MI{p_end}
{pstd}{browse "mailto:nwasi@umich.edu":nwasi@umich.edu}


{title:Also see}

{p 4 14 2}Article:  {it:Stata Journal}, volume 15, number 3: {browse "http://www.stata-journal.com/article.html?article=dm0082":dm0082}{p_end}
