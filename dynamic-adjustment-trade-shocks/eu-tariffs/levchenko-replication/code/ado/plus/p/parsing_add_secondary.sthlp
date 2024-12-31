{smcl}
{* 13 August 2014}{...}
{cmd:help parsing_add_secondary}{right: ({browse "http://www.stata-journal.com/article.html?article=dm0082":SJ15-3: dm0082})}
{hline}

{title:Title}

{p2colset 5 30 32 2}{...}
{p2col:{cmd:parsing_add_secondary} {hline 2}}Parse secondary information in a string variable containing a street address into separate fields
{p2colreset}{...}


{title:Syntax}

{p 8 29 2}
{cmd:parsing_add_secondary} {it:varname} {ifin}{cmd:,} {cmdab:g:en(}{it:newvarnames}{cmd:)}
[{cmdab:p:atpath(}{it:directory_of_pattern_files}{cmd:)} {cmdab:warn:ingmsg(on}|{cmd:off)}]


{title:Description}

{pstd}
{cmd:parsing_add_secondary} parses secondary information in a string variable
containing a street address into four components.  The {bf:gen()} option is
required.  The new generated outputs are in the following order: 1) street
address or other nonunit number, building, or floor information; 2) unit or
apartment number; 3) building information; and 4) floor or level information.
This parsing is done without standardization.  {cmd:parsing_add_secondary} is
used together with other commands to standardize and parse addresses (see
{helpb stnd_address}).  The sequence of these commands is important because
some commands rely on standardization procedures being done in earlier stages.
While advanced users may apply this command directly, it is not recommended
without first carefully inspecting the associated pattern file.{p_end}


{title:Options}

{phang}
{opt gen(newvarnames)} specifies the names of four new variables.  {cmd:gen()}
is required.

{phang}
{opt patpath(directory_of_pattern_files)} specifies an alternative location
for the pattern file to be used in the parsing process.  The
{cmd:parsing_add_secondary} command relies on a pattern file listing keywords
to parse different types of components.  The pattern file is called
{cmd:P132_secondaryadd_patterns.csv}.  By default, the program looks for this
pattern file in the default directory, {cmd:ado/plus/p/}.  Specifying
{cmd:patpath()} tells the program to look for this file in a different
directory.{p_end}

{phang} 
{cmd:warningmsg(on}|{cmd:off)} is set to {cmd:warningmsg(on)} by default, and
the program displays a warning message when the
{cmd:P132_secondaryadd_patterns.csv} file is not found and skips the remaining
steps.  Specifying {cmd:warningmsg(off)} will suppress the warning
message.{p_end}


{title:Example}

{pstd}Parse a variable {cmd:streetadd} into four new variables{p_end}

{phang2}{cmd:. parsing_add_secondary streetadd, gen(add1 unit bldg floor)}{p_end}

{pstd}Applied to {cmd:"1100 ABERNATHY RD NE STE 1400"}, the command
creates {cmd:add1} = {cmd:"1100 ABERNATHY RD NE"}, {cmd:unit} = {cmd:"STE 1400"}. {cmd:bldg} and
{cmd:floor} are blank.  Applied to {cmd:"2401 UTAH AVENUE SO., 8TH FL"}, the command creates {cmd:add1} = {cmd:"2401 UTAH AVENUE SO.,"}, {cmd:floor} = {cmd:"FL 8"}. {cmd:unit} and {cmd:bldg} are blank.{break}


{title:Author}

{pstd}Nada Wasi{p_end}
{pstd}Survey Research Center{p_end}
{pstd}Institute for Social Research{p_end}
{pstd}University of Michigan{p_end}
{pstd}Ann Arbor, MI{p_end}
{pstd}{browse "mailto:nwasi@umich.edu":nwasi@umich.edu}


{title:Also see}

{p 4 14 2}Article:  {it:Stata Journal}, volume 15, number 3: {browse "http://www.stata-journal.com/article.html?article=dm0082":dm0082}{p_end}
