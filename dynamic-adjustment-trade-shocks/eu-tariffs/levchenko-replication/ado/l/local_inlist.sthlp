{smcl}
{* *! version 2.11.0 08jun2017}{...}
{vieweralsosee "ftools" "help ftools"}{...}
{vieweralsosee "inlist" "help inlist"}{...}
{viewerjumpto "Syntax" "local_inlist##syntax"}{...}
{title:Title}

{p2colset 5 21 23 2}{...}
{p2col :{cmd:local_inlist} {hline 2}}Construct inlist() expressions{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:local_inlist}
{varname}
{it:val1 val2 ...}
[{cmd:,} {opt lab:els}]

{synoptset 21}{...}
{synopthdr}
{synoptline}
{synopt:{opt lab:els}}treat the values as {help label:labels}, which will then be automatically
transformed to numbers{p_end}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
{cmd:local_inlist} constructs a string of the form {it:inlist(variable, val, val, ...)}
and stores it in the local {it:inlist}

{marker examples}{...}
{title:Examples}

{phang}{cmd:. sysuse auto}{p_end}
{phang}{cmd:. gen _brand = word(make, 1)}{p_end}
{phang}{cmd:. encode _brand, gen(brand)}

{phang}{cmd:. local_inlist turn 40 41 42 43}{p_end}
{phang}{cmd:. keep if `inlist'}

{phang}{cmd:. local_inlist brand Fiat BMW Toyota Datsun}{p_end}
{phang}{cmd:. tab brand if `inlist'}
