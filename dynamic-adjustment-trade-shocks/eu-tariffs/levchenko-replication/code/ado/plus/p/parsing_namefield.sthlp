{smcl}
{* 13 August 2014}{...}
{cmd:help parsing_namefield}{right: ({browse "http://www.stata-journal.com/article.html?article=dm0082":SJ15-3: dm0082})}
{hline}

{title:Title}

{p2colset 5 26 28 2}{...}
{p2col:{cmd:parsing_namefield} {hline 2}}Parse a string variable containing company name without standardization
{p2colreset}{...}


{title:Syntax}

{p 8 25 2}
{cmd:parsing_namefield} {it:varname} {ifin}{cmd:,} {cmdab:g:en(}{it:newvarnames}{cmd:)}
[{cmdab:p:atpath(}{it:directory_of_pattern_files}{cmd:)} {cmdab:warn:ingmsg(}{cmd:on}|{cmd:off)}]


{title:Description}

{pstd}
The {cmd:parsing_namefield} command parses a string variable specified as a
company name into four components. The {bf:gen()} option is required.  The new
generated outputs are in the following order: 1) official name, 2)
doing-business-as name, 3) formerly-known-as name, and 4) attention name. This
parsing is done without standardizing names.  The {cmd:parsing_namefield}
command is used together with other commands to standardize and parse company
names (see {helpb stnd_compname}).  The sequence of these commands is
important because some commands rely on standardization procedures being done
in earlier stages.  While advanced users may apply this command directly, it
is not recommended without first carefully inspecting the associated pattern
file.{p_end}


{title:Options}

{phang}
{opt gen(newvarnames)} specifies the names of four new variables.
{cmd:gen()} is required.

{phang}
{cmd:patpath(}{it:directory_of_pattern_files}{cmd:)} specifies
an alternative location for the pattern file to be used in the parsing
process.  The {cmd:parsing_namefield} command is based on a pattern file
listing keywords to parse different components of a company name. The
pattern file is called {cmd:P10_namecomp_patterns.csv}.  By default, the
program looks for this pattern file in the default directory,
{cmd:ado/plus/p/}.  Specifying {cmd:patpath()} tells the program to
look for this file in a different directory.{p_end}

{phang}
{cmd:warningmsg(on}|{cmd:off)} is set to {cmd:warningmsg(on)} by default, and
the program displays a warning message when {cmd:P10_namecomp_patterns.csv} is
not found and skips the remaining steps.  Specifying {cmd:warningmsg(off)}
will suppress the warning message.{p_end}


{title:Example}

{pstd}Parse a variable {cmd:firm_name} into four new variables{p_end}

{phang2}{cmd:. parsing_namefield firm_name, gen(name dba fka attn)}{p_end}

{pstd}
Applied to {cmd:"PROFESSIONAL PHARMACIES INC DBA PLAZA PHARMACY"},
the command creates name = {cmd:"PROFESSIONAL PHARMACIES INC", dba} = {cmd:"PLAZA PHARMACY"}, and {cmd:fka} and {cmd:attn} are blank.{p_end}

{pstd}
Applied to {cmd:"PG INDUSTRIES ATTN PRESTON E INSLEY"}, the command creates
{cmd:name} = {cmd:"PG INDUSTRIES"}, {cmd:attn} = {cmd:"PRESTON E INSLEY"}, and
{cmd:dba} and {cmd:fka} are blank.


{title:Author}

{pstd}Nada Wasi{p_end}
{pstd}Survey Research Center{p_end}
{pstd}Institute for Social Research{p_end}
{pstd}University of Michigan{p_end}
{pstd}Ann Arbor, MI{p_end}
{pstd}{browse "mailto:nwasi@umich.edu":nwasi@umich.edu}


{title:Also see}

{p 4 14 2}Article:  {it:Stata Journal}, volume 15, number 3: {browse "http://www.stata-journal.com/article.html?article=dm0082":dm0082}{p_end}
