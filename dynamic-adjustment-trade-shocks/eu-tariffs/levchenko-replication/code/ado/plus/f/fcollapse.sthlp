2.27.1 23apr2018{smcl}
{* *! version 2.27.0 20apr2018}{...}
{vieweralsosee "ftools" "help ftools"}{...}
{vieweralsosee "[R] collapse" "help collapse"}{...}
{vieweralsosee "[R] contract" "help contract"}{...}
{viewerjumpto "Syntax" "fcollapse##syntax"}{...}
{viewerjumpto "Description" "fcollapse##description"}{...}
{viewerjumpto "Options" "fcollapse##options"}{...}
{title:Title}

{p2colset 5 18 23 2}{...}
{p2col :{cmd:fcollapse} {hline 2}}Efficiently
make dataset of summary statistics{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:fcollapse}
{it:clist}
{ifin}
[{cmd:,} {it:{help fcollapse##table_options:options}}]

{pstd}where {it:clist} is either

{p 8 17 2}
[{opt (stat)}]
{varlist}
[ [{opt (stat)}] {it:...} ]{p_end}

{p 8 17 2}
[{opt (stat)}] {it:target_var}{cmd:=}{varname}
        [{it:target_var}{cmd:=}{varname} {it:...}]
        [ [{opt (stat)}] {it:...}]

{p 4 4 2}or any combination of the {it:varlist} or {it:target_var} forms, and
{it:stat} is one of{p_end}

{p2colset 9 22 24 2}{...}
{p2col :{opt mean}}means (default){p_end}
{p2col :{opt median}}medians{p_end}
{p2col :{opt p1}}1st percentile{p_end}
{p2col :{opt p2}}2nd percentile{p_end}
{p2col :{it:...}}3rd{hline 1}49th percentiles{p_end}
{p2col :{opt p50}}50th percentile (same as {cmd:median}){p_end}
{p2col :{it:...}}51st{hline 1}97th percentiles{p_end}
{p2col :{opt p98}}98th percentile{p_end}
{p2col :{opt p99}}99th percentile{p_end}
{p2col :{opt sum}}sums{p_end}
{p2col :{opt count}}number of nonmissing observations{p_end}
{p2col :{opt percent}}percentage of nonmissing observations{p_end}
{p2col :{opt max}}maximums{p_end}
{p2col :{opt min}}minimums{p_end}
{p2col :{opt iqr}}interquartile range{p_end}
{p2col :{opt first}}first value{p_end}
{p2col :{opt last}}last value{p_end}
{p2col :{opt firstnm}}first nonmissing value{p_end}
{p2col :{opt lastnm}}last nonmissing value{p_end}
{p2col :{opt nansum}}same as sum, but if all obs. in the group are missing it will also be missing (instead of zero){p_end}
{p2col :{opt raw}{inp:{bf:{it:stat}}}}compute stats while ignoring weights (a generalization of {it:rawsum}){p_end}
{p2colreset}{...}

{pstd}
If {it:stat} is not specified, {opt mean} is assumed.

{pstd}
Technical limitation: Both normal stats and {it:raw} stats will ignore zero weights

{synoptset 15 tabbed}{...}
{marker table_options}{...}
{synopthdr}
{synoptline}
{syntab :Options}
{synopt :{opth by(varlist)}}groups over which {it:stat} is to be calculated
{p_end}
{synopt :{opt merge}}merge collapsed dataset back into the original one;
if the dataset is unsorted or sorted by something different than {opt by()},
it is much more efficient than {cmd:egen} and that combining {cmd:collapse} with {cmd:merge}
{p_end}
{synopt :{opt append}}append collapsed dataset at the end of the original one;
this is useful to create rows of totals
{p_end}
{synopt :{opt cw}}casewise deletion instead of all possible observations
{p_end}
{synopt :{opt fast}}do not preserve and restore the original dataset;
saves speed but leaves the data in an unusable state shall the
user press {hi:Break}
{p_end}
{synopt :{opt smart}}invoke {cmd:collapse} if the data is already sorted (in which case {cmd:collapse} might be faster)
{p_end}
{synopt :{cmd:freq}[{cmd:(}{newvar}{cmd:)}]}store
the raw observation count (similar to {help contract}).
If not indicated, the name of the new variable will be {it:_freq}
{p_end}
{synopt :{opt reg:ister(keys)}}add new stat functions.
For each key, a corresponding Mata function should exist.
See example at the end
{p_end}
{synopt :{opt pool(#)}}load the data into stata in blocks of # variables
Default is {it:pool(.)}, select a low value ({it:pool(5)})
or very low value ({it:pool(1)}) to save memory at the cost of speed
{p_end}
{synopt :{opt nocompress}}{it:compress} chooses the most compact variable type, at a small speed cost
(on by default)
{p_end}
{synopt :{opt v:erbose}}display misc. debug messages
{p_end}

{synoptline}
{p2colreset}{...}
{p 4 6 2}


{marker description}{...}
{title:Description}

{pstd}
{opt fcollapse} converts the dataset in memory into a dataset of means, sums,
medians, etc.  {it:clist} can refer to numeric and string variables
although string variables are only supported by a few functions
(first, last, firstnm, lastnm).

{pstd}
Weights are only partially supported.

{pstd}
You can implement your own Mata functions to easily extend the fcollapse command.


{marker options}{...}
{title:Options}

{dlgtab:Options}

{phang}
{opth by(varlist)} specifies the groups over which the means, etc., are to be
calculated.  If this option is not specified, the resulting dataset will
contain 1 observation.  If it is specified, {it:varlist} may refer to either
string or numeric variables.

{phang}
{opt merge} works similarly to {cmd:egen}.
It will collapse the data in Mata and then add it back to the original dataset.
If the dataset is not sorted by the groups set in {opt by()}, this is much faster than {cmd:egen} and {cmd:collapse} followed by {cmd:merge}.

{phang}
{opt cw} specifies casewise deletion.  If {opt cw} is not specified, all
possible observations are used for each calculated statistic.

{phang}
{opt fast} specifies that {opt fcollapse} not restore the original dataset
should the user press {hi:Break}.

{phang}
{opt freq} stores frequencies on a new variable {it:_freq}.
To choose the name of the variable, use {opth freq(newvar)}

{phang}
{opt reg:ister(fun1 ...)} registers Mata functions {it:fun1}, etc. so 
to extend {cmd fcollapse}; see example below.

{phang}
{opt pool(#)} load the data into Stata in blocks of # variables Default is pool(.),
select a low value (pool(5)) or very low value (pool(1)) to save memory at the cost of speed.

{phang}
{opt compress} will fit variables into more compact types, such as {it:byte},
{it:int}, and {it:long}, without losing information when compared to more accurate types
such as {it:double}.
The cost is a slight reduction in speed, due to the extra checks involved.

{marker example}{...}
{title:Example: Adding your own aggregation functions}

The following code adds the stat. {it:variance}:


{inp}    sysuse auto, clear

    cap mata: mata drop aggregate_variance()
    
    mata:
    mata set matastrict on
    transmorphic colvector aggregate_variance(
        class Factor F,
        transmorphic colvector data,
        real colvector weights)
    {
        real scalar i
        transmorphic colvector results
        results = J(F.num_levels, 1, missingof(data))
        for (i = 1; i <= F.num_levels; i++) {
            results[i] = quadvariance(panelsubmatrix(data, i, F.info))
        }
        return(results)
    }
    end
    
    fcollapse (mean) price (variance) weight foreign, by(turn) register(variance) freq
    li
{text}

Note that the to create a new stat {it:variance} we created a Mata function
called {it:aggregate_variance}. To avoid overlap with other Mata functions,
your function must start with {it:aggregate_}.


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


{marker acknowledgment}{...}
{title:Acknowledgment}

{pstd}
This help file was based on StataCorp's own help file
for {it:collapse}.
{p_end}

{pstd}
This project was largely inspired by the works of
{browse "http://wesmckinney.com/blog/nycpython-1102012-a-look-inside-pandas-design-and-development/":Wes McKinney}, 
{browse "http://www.stata.com/meeting/uk15/abstracts/":Andrew Maurer}
and
{browse "https://ideas.repec.org/c/boc/bocode/s455001.html":Benn Jann}.
{p_end}

