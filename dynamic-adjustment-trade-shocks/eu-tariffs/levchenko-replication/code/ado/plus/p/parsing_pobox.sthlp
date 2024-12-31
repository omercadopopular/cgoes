{smcl}
{* 13 August 2014}{...}
{cmd:help parsing_pobox}{right: ({browse "http://www.stata-journal.com/article.html?article=dm0082":SJ15-3: dm0082})}
{hline}

{title:Title}

{p2colset 5 22 24 2}{...}
{p2col :{cmd:parsing_pobox} {hline 2}}Parse post office (P.O.) box information into a separate field{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 21 2}
{cmd:parsing_pobox} {it:varname} {ifin}{cmd:,} {cmdab:g:en(}{it:newvarnames}{cmd:)} [{cmdab:p:atpath(}{it:directory_of_pattern_files}{cmd:)} {cmdab:warn:ingmsg(on}|{cmd:off)}]


{title:Description}

{pstd}
The {cmd:parsing_pobox} command parses a string variable that may contain 
P.O. box information into two components. The {bf:gen()} option is required.
The first generated output is non-P.O. box information, while the second
generated output contains the P.O. box information, if present.  The P.O. box
output is also standardized.  The {cmd:parsing_pobox} command is used together
with other commands to standardize and parse address fields (see 
{helpb stnd_address}).  The sequence of these commands is important because
some commands rely on standardization procedures being done in earlier stages.
While advanced users may apply this command directly, it is not recommended
without first carefully inspecting the associated pattern file.{p_end}


{title:Options}

{phang}
{opt gen(newvarnames)} specifies the names of two new variables.  {cmd:gen()} is
required.

{phang}
{opt patpath(directory_of_pattern_files)} specifies an alternative location
for the pattern file to be used in the parsing process.  The
{cmd:parsing_pobox} command is based on a pattern file listing keywords to
parse the P.O. box component of the string.  The pattern file is called
{cmd:P120_pobox_patterns.csv}.  By default, the program looks for this pattern
file in the default directory, {cmd:ado/plus/p/}.  Specifying {cmd:patpath()}
tells the program to look for this file in a different directory.{p_end}

{phang}
{cmd:warningmsg(on}|{cmd:off)} is set to {cmd:warningmsg(on)} by default, and
the program displays a warning message when {cmd:P120_pobox_patterns.csv} is
not found and skips the remaining steps.  Specifying {cmd:warningmsg(off)}
will suppress the warning message.{p_end}


{title:Example}

{pstd}
Parse a variable {cmd:firm_add} into two new variables{p_end}

{phang2}{cmd:. parsing_pobox firm_add, gen(add1 pobox)}{p_end}

{pstd}
Applied to {cmd:"233 SOUTH PATTERSON PO BOX 1156"}, the command creates {cmd:add1 = "233 SOUTH PATTERSON"} and {cmd:pobox} = {cmd:"BOX 1156"}.{p_end}

{pstd}
Applied to {cmd:"POST OFFICE BOX 343910"}, the command creates {cmd:add1} = {cmd:""} and {cmd:pobox} = {cmd:"BOX 343910"}.{p_end}


{title:Author}

{pstd}Nada Wasi{p_end}
{pstd}Survey Research Center{p_end}
{pstd}Institute for Social Research{p_end}
{pstd}University of Michigan{p_end}
{pstd}Ann Arbor, MI{p_end}
{pstd}{browse "mailto:nwasi@umich.edu":nwasi@umich.edu}


{title:Also see}

{p 4 14 2}Article:  {it:Stata Journal}, volume 15, number 3: {browse "http://www.stata-journal.com/article.html?article=dm0082":dm0082}{p_end}
