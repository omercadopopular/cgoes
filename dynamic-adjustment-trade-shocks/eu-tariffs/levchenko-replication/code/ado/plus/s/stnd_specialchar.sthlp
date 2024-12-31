{smcl}
{* 13 August 2014}{...}
{cmd:help stnd_specialchar}{right: ({browse "http://www.stata-journal.com/article.html?article=dm0082":SJ15-3: dm0082})}
{hline}

{title:Title}

{p2colset 5 25 27 2}{...}
{p2col :{cmd:stnd_specialchar} {hline 2}}Standardize a string variable containing special characters (for example, ~, !, @, and #){p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 24 2}
{cmd:stnd_specialchar} {it:varname} {ifin} [{cmd:,} {cmdab:excl:ude(}{it:characters}{cmd:)} {opt type(name)} {cmdab:p:atpath(}{it:directory_of_pattern_files}{cmd:)} {cmdab:warn:ingmsg(on}|{cmd:off)}]


{title:Description}

{pstd}
{cmd:stnd_specialchar} standardizes special characters (for example, ~, !, @,
and #) for a string variable containing company names and street addresses.
Characters that tend to be typographical errors are removed.  Characters that
are intended to split words are replaced with a white space.  This command is
used together with other commands to standardize and parse company names and
addresses (see {helpb stnd_compname}, {helpb stnd_address}).  The sequence of
these commands is important because some commands rely on standardization
procedures being done in earlier stages.  While advanced users may apply this
command directly, it is not recommended without first carefully inspecting the
associated pattern file.{p_end}


{title:Options}

{phang}
{opt exclude(characters)} specifies characters to be ignored.

{phang}
{opt type(name)} calls a set of specific actions applicable only to a string
variable containing company names.

{phang}
{opt patpath(directory_of_pattern_files)} specifies an alternative location for
the pattern file to be used in the standardizing process.  The
{cmd:stnd_specialchar} command is based on three associated pattern files:
{cmd:P21_spchar_specialcases.csv} contains a list of actions when the option
{opt type(name)} is specified, {cmd:P22_spchar_remove.csv} contains a list of
characters to be removed, and {cmd:P23_spchar_rplcwithspace.csv} contains a
list of characters to be replaced with a white space.  By default, the program
looks for these pattern files in the default directory, {cmd:ado/plus/p/}.
Specifying {cmd:patpath()} tells the program to look for these files in a
different directory.

{phang}
{cmd:warningmsg(on}|{cmd:off)} is set to {cmd:warningmsg(on)} by default, and
the program displays a warning message when {cmd:P21_spchar_specialcases.csv},
{cmd:P22_spchar_remove.csv}, or {cmd:P23_spchar_rplcwithspace.csv} is not
found and skips the remaining steps.  Specifying {cmd:warningmsg(off)} will
suppress the warning message.


{title:Examples}

{pstd}
Standardize special characters in a string variable {cmd:"firm_name"}{p_end}

{phang2}{cmd:. stnd_specialchar firm_name}{p_end}

{pstd}
Applied to {cmd:"L.L.BEAN, INC."}, the command will replace with {cmd:"LL BEAN INC"}.{p_end}

{pstd}
{txt}Standardize special characters in a string variable {cmd:"firm_add"}{p_end}

{phang2}{cmd:. stnd_specialchar firm_add}{p_end}

{pstd}
Applied to {cmd:"3630 S GEYER RD, SUITE #100"}, the command will replace with {cmd:"3630 S GEYER RD SUITE 100"}.{p_end}

{pstd}
Remove {cmd:","} but keep {cmd:"#"}{p_end}

{phang2}{cmd:. stnd_specialchar firm_add, exclude(#)}{p_end}

{pstd}
Applied to {cmd:"3630 S GEYER RD, SUITE #100"}, the command will replace with {cmd:"3630 S GEYER RD SUITE #100"}.{p_end}

{pstd}
Some special characters may be meaningful for company names.  Specifying {cmd:type(name)} takes specific actions for these cases.{p_end}

{phang2}
{cmd:. stnd_specialchar firm_name, type(name)}{p_end}

{pstd}
Applied to {cmd:"@WORK GROUP"}, the command will replace with {cmd:"ATWORK GROUP"}.{p_end}


{title:Author}

{pstd}Nada Wasi{p_end}
{pstd}Survey Research Center{p_end}
{pstd}Institute for Social Research{p_end}
{pstd}University of Michigan{p_end}
{pstd}Ann Arbor, MI{p_end}
{pstd}{browse "mailto:nwasi@umich.edu":nwasi@umich.edu}


{title:Also see}

{p 4 14 2}Article:  {it:Stata Journal}, volume 15, number 3: {browse "http://www.stata-journal.com/article.html?article=dm0082":dm0082}{p_end}
