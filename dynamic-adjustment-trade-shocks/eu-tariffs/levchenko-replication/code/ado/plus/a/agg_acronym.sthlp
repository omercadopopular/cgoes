{smcl}
{* 13 August 2014}{...}
{cmd:help agg_acronym}{right: ({browse "http://www.stata-journal.com/article.html?article=dm0082":SJ15-3: dm0082})}
{hline}

{title:Title}

{p2colset 5 20 22 2}{...}
{p2col:{hi: agg_acronym} {hline 2}}Create a new variable by removing spaces between two or more one-letter words
{p2colreset}{...}


{title:Syntax}

{p 8 19 2}
{cmd:agg_acronym} {it:varname} {ifin}{cmd:,} {cmdab:g:en(}{it:newvarname}{cmd:)}


{title:Description}

{pstd}{cmd:agg_acronym} creates a new variable by removing spaces
between two or more one-letter words in the input string variable.  The
{cmd:gen()} option is required.  This command is used in conjunction
with other commands to standardize and parse company names and addresses
(see {helpb stnd_compname}, {helpb stnd_address}).{p_end}


{title:Option}

{phang}{opt gen(newvarname)} specifies the name of a new variable.
{cmd:gen()} is required.


{title:Example}

{phang}
{cmd:. agg_acronym firm_name, gen(newname)}{p_end}

{pstd}
Applied to {cmd:"A O SMITH CORP"}, the command creates {cmd:newname} = {cmd:"AO SMITH CORP"}.{p_end}

{pstd}
Applied to {cmd:"THE Y M C A"}, the command creates {cmd:newname} = {cmd:"THE YMCA"}.{p_end}


{title:Author}

{pstd}Nada Wasi{p_end}
{pstd}Survey Research Center{p_end}
{pstd}Institute for Social Research{p_end}
{pstd}University of Michigan{p_end}
{pstd}Ann Arbor, MI{p_end}
{pstd}{browse "mailto:nwasi@umich.edu":nwasi@umich.edu}


{title:Also see}

{p 4 14 2}Article:  {it:Stata Journal}, volume 15, number 3: {browse "http://www.stata-journal.com/article.html?article=dm0082":dm0082}{p_end}
