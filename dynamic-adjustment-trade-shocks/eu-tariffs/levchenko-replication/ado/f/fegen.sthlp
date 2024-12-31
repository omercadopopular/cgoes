{smcl}
{* *! version 1.9.0 10jan2017}{...}
{vieweralsosee "ftools" "help ftools"}{...}
{vieweralsosee "[R] egen" "help egen"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "egenmore" "help egenmore"}{...}
{viewerjumpto "Syntax" "sort##syntax"}{...}
{title:Title}

{p2colset 5 13 20 2}{...}
{p2col :{cmd:fegen} {hline 2}}Alternative to egen that optimizes speed{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{p 8 16 2}
{cmd:fegen}
{dtype}
{newvar}
{cmd:=}
{it:function}{cmd:(}{it:arguments}{cmd:)}
{ifin} 
[{cmd:,} {it:options}]

{title:Included functions}

{synoptset 32 tabbed}{...}
{synopt:{opth max(exp)}}{p_end}
{synopt:{opth group(varlist)}}note: {varlist} cannot have both string and numeric variables{p_end}
{p2colreset}{...}

{marker group}{...}
{title:Options for {cmd:group()}}

{synoptset 22 tabbed}{...}
{synopthdr}
{synoptline}
{synopt : {opt missing}}treat missing values in varlist (either . or "") as any other value when assigning groups,
instead of being assigned to the group missing{p_end}
{synopt : {opt method(str)}}the underlying method used; either {cmd:mata}
(default) or {cmd:stata} (often faster if the inputs are string or nonintegers){p_end}
{synopt : {opt nosort}}speeds up the {cmd:mata} method, but the new IDs will not respect the sort order of the inputs{p_end}
{synopt : {opt ratio(#)}}the same as the {it:hash_ratio} option from {help ftools}{p_end}
{synopt : {opt verbose}}see some internal details{p_end}



{title:How to add a new function}

First, create a file named _gf{it:NAME}.ado where {it:NAME} is the name of the function.
Then, inside the file, use the following scaffolding:

{tab}{input}{bf}program define _gf{sf:{it:NAME}}
{tab}syntax [if] [in], type(string) name(string) args(string) [by(varlist)] {it:...}
{tab}{tab}tempvar touse
{tab}{tab}qui {
{tab}{tab}{tab}{it:...}
{tab}{tab}{tab}gen `type' `name' = {it:...} if `touse'==1
{tab}{tab}{tab}{it:...}
{tab}{tab}}
{tab}end{text}{sf}


{marker author}{...}
{title:Author}

{pstd}Sergio Correia{break}
Board of Governors of the Federal Reserve System, USA{break}
{browse "mailto:sergio.correia@gmail.com":sergio.correia@gmail.com}{break}
{p_end}


{marker project}{...}
{title:More Information}

{pstd}{break}
To report bugs, contribute, ask for help, etc. please see the project URL in Github:{break}
{browse "https://github.com/sergiocorreia/ftools"}{break}
{p_end}
