{smcl}
{* *! version 1.0.01  29aug2015}{...}
{cmd:help ms_fvstrip}
{hline}

{title:Title}

{p2colset 5 16 18 2}{...}
{p2col:{hi: ms_fvstrip} {hline 2}}Stata utility for removing b/n/o factor variable operators from varlists{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{p 8 14 2}
{cmd:ms_fvstrip}
{it:(varlist)}
[{cmd:if} {it:exp}]
{bind:[{cmd:,} {it:dropomit} {it:expand}} {it:onebyone} {it:NOIsily} ]

{synoptset 20}{...}
{synopthdr:options}
{synoptline}
{synopt:{cmd:expand}}
expand varlist using {cmd:fvexpand} if not already expanded
{p_end}
{synopt:{cmd:onebyone}}
when used with {cmd:expand}, expands varlist by calling {cmd:fvexpand}
on each variable in varlist separately instead on the entire varlist at once
{p_end}
{synopt:{cmd:dropomit}}
drop any omitted variables, including factor variable base categories, from the returned varlist
{p_end}
{synopt:{cmdab:noi:sily}}
display stripped varlist
{p_end}
{synoptline}
{p2colreset}{...}


{marker saved_results}{...}
{title:Saved results}

{pstd}
{cmd:ms_fvstrip} saves the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Macros}{p_end}
{synopt:{cmd:r(varlist)}}stripped varlist{p_end}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
{opt ms_fvstrip} is a utility for removing the b/n/o factor variable operators from a varlist.
With the {cmd:expand} option, it will expand the varlist if not already expanded.

{pstd}
{opt ms_fvstrip} is intended for use by Stata programmers,
who may freely include it in their ado programs
and/or modify it as they wish for their own uses.


{title:Examples}

{phang2}. {stata "sysuse auto"}{p_end}

{pstd}Typical use in a program:{p_end}

{phang2}. {stata "fvexpand i.rep78"}{p_end}
{phang2}. {stata "ms_fvstrip `r(varlist)'"}{p_end}
{pstd}Or:{p_end}
{phang2}. {stata "fvexpand i.rep78"}{p_end}
{phang2}. {stata "ms_fvstrip `r(varlist)', dropomit"}{p_end}

{pstd}Illustrative examples:{p_end}

{phang2}. {stata "fvexpand i.rep78"}{p_end}

{phang2}. {stata "global vlist `r(varlist)'"}{p_end}

{phang2}. {stata `"di "$vlist""'}{p_end}

{phang2}. {stata "ms_fvstrip $vlist"}{p_end}

{phang2}. {stata "return list"}{p_end}

{phang2}. {stata "ms_fvstrip i.rep78, expand noi"}{p_end}

{phang2}. {stata "ms_fvstrip i.rep78 if rep78~=3, expand noi"}{p_end}

{phang2}. {stata "ms_fvstrip i.rep78, expand dropomit noi"}{p_end}

{phang2}. {stata "fvexpand i.rep78#i.foreign"}{p_end}

{phang2}. {stata `"di "`r(varlist)'""'}{p_end}

{phang2}. {stata "ms_fvstrip `r(varlist)', dropomit noi"}{p_end}

{pstd}{cmd:expand} option means an internal call to {cmd:fvexpand} so order changes:{p_end}

{phang2}. {stata "ms_fvstrip 2.rep78 1.rep78, noi"}{p_end}

{phang2}. {stata "ms_fvstrip 2.rep78 1.rep78, noi expand"}{p_end}

{pstd}Fails because i.foreign is unexpanded:{p_end}

{phang2}. {stata "ms_fvstrip i.foreign 2.rep78 1.rep78, noi"}{p_end}

{pstd}Fails because of base category conflict in internal {cmd:fvexpand} call:{p_end}

{phang2}. {stata "ms_fvstrip i.foreign 2b.rep78 1b.rep78, noi expand"}{p_end}

{pstd}Works:{p_end}

{phang2}. {stata "ms_fvstrip i.foreign 2.rep78 1.rep78, noi expand onebyone"}{p_end}

{title:Author}

	Mark E Schaffer, Heriot-Watt University, UK
	m.e.schaffer@hw.ac.uk


{title:Also see}

{p 7 14 2}
Help:  {helpb fvvarlist}; {helpb fvexpand}; {helpb varlist}{p_end}
