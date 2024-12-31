{smcl}
{* *! version 2.9.0 28mar2017}{...}
{vieweralsosee "ftools" "help ftools"}{...}
{vieweralsosee "[R] sort" "help sort"}{...}
{vieweralsosee "[R] gsort" "help gsort"}{...}
{viewerjumpto "Syntax" "fsort##syntax"}{...}
{title:Title}

{p2colset 5 14 20 2}{...}
{p2col :{cmd:fsort} {hline 2}}Sort by categorical variables{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{p 8 13 2}
{cmd:fsort}
{varlist}
[{cmd:,} {opt v:erbose}]

{p 8 13 2}not implemented:
{cmd:fsort}
{varlist}
{ifin}

{p 8 14 2}not implemented:
{cmd:fsort}
[{cmd:+}|{cmd:-}]
{varname}
[[{cmd:+}|{cmd:-}]
{varname} {it:...}]

{marker description}{...}
{title:Description}

{pstd}
{opt fsort} is an alternative to {help sort} and {help gsort}, with some differences:

{synoptset 3 tabbed}{...}
{synopt:1)}It expects the variables to represent categories (it would be quite slow to use it to sort a normal random variable){p_end}
{synopt:2)}{varlist} cannot have both string and numeric variables{p_end}
{synopt:3)}The sort is always stable{p_end}
{synopt:3)}It is is faster than {cmd:sort} only with large datasets (above 200k obs.){p_end}
{synopt:4)}(wip) It allows {it:if} and {it:in} options{p_end}
{p2colreset}{...}


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
