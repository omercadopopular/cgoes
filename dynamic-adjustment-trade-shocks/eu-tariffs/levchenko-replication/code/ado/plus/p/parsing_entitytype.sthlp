{smcl}
{* 13 August 2014}{...}
{cmd:help parsing_entitytype}{right: ({browse "http://www.stata-journal.com/article.html?article=dm0082":SJ15-3: dm0082})}
{hline}

{title:Title}

{p2colset 5 27 29 2}{...}
{p2col :{cmd:parsing_entitytype} {hline 2}}Parse a string variable containing business names and entity types (if any){p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 26 2}
{cmd:parsing_entitytype} {it:varname}{cmd:,} {cmdab:g:en(}{it:newvarnames}{cmd:)} [{cmdab:p:atpath(}{it:directory_of_pattern_files}{cmd:)} {cmdab:warn:ingmsg(on}|{cmd:off)}]


{title:Description}

{pstd}
{cmd:parsing_entitytype} parses a string containing company names and entity
types (if any) into two components.  The first generated output is a name
without entity type, and the second generated output is an entity type, if
found.  This parsing is done after entity types have been standardized.  It is
used together with other commands to standardize and parse company names (see
{helpb stnd_compname}).  The sequence of these commands is important because
some commands rely on standardization procedures being done in earlier stages.
While advanced users may apply this command directly, it is not recommended
without first carefully inspecting the associated pattern file.{p_end}


{title:Options}

{phang}
{opt gen(newvarnames)} specifies two new variable names.  {cmd:gen()} is
required.{p_end}

{phang}
{opt patpath(directory_of_pattern_files)} specifies an alternative location
for the pattern file to be used in the parsing process.  The
{cmd:parsing_entitytype} command is based on a pattern file listing keywords
to parse the entity-type component.  The pattern file is called
{cmd:P90_entity_patterns.csv}.  By default, the program looks for this pattern
file in the default directory, {cmd:ado/plus/p/}.  Specifying {cmd:patpath()}
tells the program to look for this file in a different directory.{p_end}

{phang}
{cmd:warningmsg(on}|{cmd:off)} is set to {cmd:warningmsg(on)} by default, and
the program displays a warning message when the {cmd:P90_entity_patterns.csv}
is not found and skips the remaining steps.  Specifying {cmd:warningmsg(off)}
will suppress the warning message.{p_end}


{title:Example}

{pstd}
Parse a variable {cmd:firm_name} into two new variables{p_end}

{phang2}{cmd:. parsing_entitytype firm_name, gen(name entitytype)}{p_end}

{pstd}
Applied to {cmd:"PROFESSIONAL PHARMACIES INC"}, the command creates {cmd:name} = {cmd:"PROFESSIONAL PHARMACIES"} and {cmd:entitytype} = {cmd:"INC"}.


{title:Author}

{pstd}Nada Wasi{p_end}
{pstd}Survey Research Center{p_end}
{pstd}Institute for Social Research{p_end}
{pstd}University of Michigan{p_end}
{pstd}Ann Arbor, MI{p_end}
{pstd}{browse "mailto:nwasi@umich.edu":nwasi@umich.edu}


{title:Also see}

{p 4 14 2}Article:  {it:Stata Journal}, volume 15, number 3: {browse "http://www.stata-journal.com/article.html?article=dm0082":dm0082}{p_end}
