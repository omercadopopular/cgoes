{smcl}
{* *! version 2.10.0 3apr2017}{...}
{vieweralsosee "ftools" "help ftools"}{...}
{vieweralsosee "join" "help join"}{...}
{vieweralsosee "[R] merge" "help merge"}{...}
{viewerjumpto "Syntax" "fmerge##syntax"}{...}
{title:Title}

{p2colset 5 15 20 2}{...}
{p2col :{cmd:fmerge} {hline 2}}Merge datasets{p_end}
{p2colreset}{...}

{pstd}
{cmd:fmerge} is a wrapper for {help join},
supporting {it:m:1} and {it:1:1} joins.

{pstd}
The syntax is identical to {help merge}, except for the extra option
{cmd:verbose}, that will show debug information and the underlying {cmd:join}
command.
{p_end}

{marker syntax}{...}
{title:Syntax}

{pstd}
One-to-one merge on specified key variables

{p 8 15 2}
{opt fmer:ge} {cmd:1:1} {varlist} 
{cmd:using} {it:{help filename}} [{cmd:,} {it:options}]


{pstd}
Many-to-one merge on specified key variables

{p 8 15 2}
{opt fmer:ge} {cmd:m:1} {varlist} 
{cmd:using} {it:{help filename}} [{cmd:,} {it:options}]


{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :Options}
{synopt :{opth keepus:ing(varlist)}}variables to keep from using data;
     default is all
{p_end}
{...}
{synopt :{opth gen:erate(newvar)}}name of new variable to mark merge
      results; default is {cmd:_merge}
{p_end}
{...}
{synopt :{opt nogen:erate}}do not create {cmd:_merge} variable
{p_end}
{...}
{synopt :{opt nol:abel}}do not copy value-label definitions from using{p_end}
{...}
{synopt :{opt nonote:s}}do not copy notes from using{p_end}
{...}
{synopt :{opt update}}update missing values of same-named variables in master
     with values from using {it:(not allowed)}
{p_end}
{...}
{synopt :{opt replace}}replace all values of same-named variables in master
     with nonmissing values from using (requires {cmd:update}) {it:(not allowed)}
{p_end}
{...}
{synopt :{opt norep:ort}}do not display match result summary table
{p_end}
{synopt :{opt force}}allow string/numeric variable type mismatch without error {it:(ignored)}
{p_end}
{synopt :{opt verbose}}show debug information and the {cmd:join} command used {it:(new)}
{p_end}

{syntab: Results}
{synopt :{cmd:assert(}{help merge##results:{it:results}}{cmd:)}}specify required match results
{p_end}
{...}
{synopt :{cmd:keep(}{help merge##results:{it:results}}{cmd:)}}specify which match results to keep
{p_end}
{...}

{synopt :{opt sorted}}do not sort; datasets already sorted {it:(ignored)}
{p_end}
{...}
{synoptline}
{p2colreset}{...}
{p 4 6 2}


{marker about}{...}
{title:Author}

{pstd}Sergio Correia{break}
Board of Governors of the Federal Reserve System, USA{break}
{browse "mailto:sergio.correia@gmail.com":sergio.correia@gmail.com}{break}
{p_end}


{title:More Information}

{pstd}{break}
To report bugs, contribute, ask for help, etc. please see the project URL in Github:{break}
{browse "https://github.com/sergiocorreia/ftools"}{break}
{p_end}
