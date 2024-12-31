{smcl}
{* *! version 2.37.0 16aug2019}{...}
{vieweralsosee "fegen" "help fegen"}{...}
{vieweralsosee "fcollapse" "help fcollapse"}{...}
{vieweralsosee "join" "help join"}{...}
{vieweralsosee "fmerge" "help fmerge"}{...}
{vieweralsosee "flevelsof" "help flevelsof"}{...}
{vieweralsosee "fisid" "help fisid"}{...}
{vieweralsosee "fsort" "help fsort"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] egen" "help egen"}{...}
{vieweralsosee "[R] collapse" "help collapse"}{...}
{vieweralsosee "[R] contract" "help contract"}{...}
{vieweralsosee "[R] merge" "help merge"}{...}
{vieweralsosee "[R] levelsof" "help levelsof"}{...}
{vieweralsosee "[R] sort" "help sort"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "moremata" "help moremata"}{...}
{vieweralsosee "reghdfe" "help reghdfe"}{...}
{viewerjumpto "Syntax" "ftools##syntax"}{...}
{viewerjumpto "Creation" "ftools##creation"}{...}
{viewerjumpto "Properties and methods" "ftools##properties"}{...}
{viewerjumpto "Description" "ftools##description"}{...}
{viewerjumpto "Usage" "ftools##usage"}{...}
{viewerjumpto "Example" "ftools##example"}{...}
{viewerjumpto "Remarks" "ftools##remarks"}{...}
{viewerjumpto "Using functions from collapse" "ftools##collapse"}{...}
{viewerjumpto "Experimental/advanced" "ftools##experimental"}{...}
{viewerjumpto "Source code" "ftools##source"}{...}
{viewerjumpto "Author" "ftools##contact"}{...}

{title:Title}

{p2colset 5 15 20 2}{...}
{p2col :{cmd:FTOOLS} {hline 2}}Mata commands for factor variables{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{p 8 16 2}
{it:class Factor scalar}
{bind: }{cmd:factor(}{space 3}{it:varnames} [{space 1}
{cmd:,}
{it:touse}{cmd:,} 
{it:verbose}{cmd:,} 
{it:method}{cmd:,} 
{it:sort_levels}{cmd:,} 
{it:count_levels}{cmd:,} 
{it:hash_ratio}{cmd:,}
{it:save_keys}]{cmd:)}

{p 8 16 2}
{it:class Factor scalar}
{bind: }{cmd:_factor(}{it:data} [{cmd:,}
{it:integers_only}{cmd:,} 
{it:verbose}{cmd:,} 
{it:method}{cmd:,} 
{it:sort_levels}{cmd:,} 
{it:count_levels}{cmd:,} 
{it:hash_ratio}{cmd:,}
{it:save_keys}]{cmd:)}

{p 8 16 2}
{it:class Factor scalar}
{bind: }{cmd:join_factors(}{it:F1}{cmd:,}
{it:F2} [{cmd:,}
{it:count_levels}{cmd:,} 
{it:save_keys}{cmd:,}
{it:levels_as_keys}]{cmd:)}


{marker arguments}{...}
{synoptset 38 tabbed}{...}
{synopthdr}
{synoptline}
{p2coldent:* {it:string} varnames}names of variables that identify the factors{p_end}
{synopt:{it:string} touse}name of dummy {help mark:touse} variable{p_end}
{p2coldent:}{bf:note:} you can also pass a vector with the obs. index (i.e. the first argument of {cmd:st_data()}){p_end}
{synopt:{it:string} data}transmorphic matrix with the group identifiers{p_end}

{synopt:{bf:Advanced options:}}{p_end}
{synopt:{it:real} verbose}1 to display debug information{p_end}
{synopt:{it:string} method}hashing method: mata, hash0, hash1, hash2; default is {it:mata} (auto-choose){p_end}
{synopt:{it:real} sort_levels}set to 0 under {it:hash1} to increase speed, but the new levels will not match the order of the varlist{p_end}
{synopt:{it:real} count_levels}set to 0 under {it:hash0} to increase speed, but the {it:F.counts} vector will not be generated
so F{cmd:.panelsetup()}, F{cmd:.drop_obs()}, and related methods will not be available{p_end}
{synopt:{it:real} hash_ratio}size of the hash vector compared to the maximum number of keys (often num. obs.){p_end}
{synopt:{it:real} save_keys}set to 0 to increase speed and save memory,
but the matrix {it:F.keys} with the original values of the factors
won't be created{p_end}
{synopt:{it:string} integers_only}whether {it:data} is numeric and takes only {it:integers} or not (unless you are sure of the former, set it to 0){p_end}
{synopt:{it:real} levels_as_keys}if set to 1,
{cmd:join_factors()} will use the levels of F1 and F2
as the keys (as the data) when creating F12{p_end}
{p2colreset}{...}


{marker creation}{...}
{title:Creating factor objects}

{pstd}(optional) First, you can declare the Factor object:

{p 8 8 2}
{cmd:class Factor scalar}{it: F}{break}

{pstd}Then, you can create a factor from one or more categorical variables:

{p 8 8 2}
{it:F }{cmd:=}{bind: }{cmd:factor(}{it:varnames}{cmd:)}

{pstd}
If the categories are already in Mata
({cmd:data = st_data(., varnames)}), you can do:

{p 8 8 2}
{it:F }{cmd:=}{bind: }{cmd:_factor(}{it:data}{cmd:)}

{pstd}
You can also combine two factors ({it:F1} and {it:F2}):

{p 8 8 2}
{it:F }{cmd:=}{bind: }{cmd:join_factors(}{it:F1}{cmd:,} {it:F2}{cmd:)}

{pstd}
Note that the above is exactly equivalent (but faster) than:

{p 8 8 2}
{it: varnames} {cmd:= invtokens((}{it:F1.varnames}{cmd:,} {it:F2.varnames}{cmd:))}{break}
{it:F} {cmd:=} {cmd:factor(}{it:varnames}{cmd:)}

{pstd}
If {it:levels_as_keys==1}, it is equivalent to:

{p 8 8 2}
{it:F }{cmd:=}{bind: }{cmd:_factor((}{it:F1.levels}{cmd:,} {it:F2.levels}{cmd:))}


{marker properties}{...}
{title:Properties and Methods}

{marker arguments}{...}
{synoptset 38 tabbed}{...}

{synopthdr:properties}
{synoptline}
{synopt:{it:real} F{cmd:.num_levels}}number of levels (distinct values) of the factor{p_end}
{synopt:{it:real} F{cmd:.num_obs}}number of observations of the sample used to create the factor ({cmd:c(N)} if touse was empty){p_end}
{synopt:{it:real colvector} F{cmd:.levels}}levels of the factor; dimension {cmd:F.num_obs x 1}; range: {cmd:{1, ..., F.num_levels}}{p_end}
{synopt:{it:transmorphic matrix} F{cmd:.keys}}values of the input varlist that correspond to the factor levels;
dimension {cmd:F.num_levels x 1}; not created if save_keys==0; unordered if sort_levels==0{p_end}
{synopt:{it:real vector} F{cmd:.counts}}frequencies of each level (in the sample set by touse);
dimension {cmd:F.num_levels x 1}; will be empty if count_levels==0{p_end}

{synopt:{it:string rowvector} F{cmd:.varlist}}name of variables used to create the factor{p_end}
{synopt:{it:string rowvector} F{cmd:.varformats}}formats of the input variables{p_end}
{synopt:{it:string rowvector} F{cmd:.varlabels}}labels of the input variables{p_end}
{synopt:{it:string rowvector} F{cmd:.varvaluelabels}}value labels attached to the input variables{p_end}
{synopt:{it:string rowvector} F{cmd:.vartypes}}types of the input variables{p_end}
{synopt:{it:string rowvector} F{cmd:.vl}}value label definitions used by the input variables{p_end}
{synopt:{it:string} F{cmd:.touse}}name of touse variable{p_end}
{synopt:{it:string} F{cmd:.is_sorted}}1 if the dataset is sorted by F{cmd:.varlist}{p_end}


{synopthdr:main methods}
{synoptline}
{synopt:{it:void} F{cmd:.store_levels(}{newvar}{cmd:)}}save
the levels back into the dataset (using the same {it:touse}){p_end}
{synopt:{it:void} F{cmd:.store_keys(}[{it:sort}]{cmd:)}}save
the original key variables into a reduced dataset, including formatting and labels. If {it:sort} is 1, Stata will report the dataset as sorted{p_end}
{synopt:{it:void} F{cmd:.panelsetup()}}compute auxiliary vectors {it:F.info}
and {it:F.p} (see below); used in panel computations{p_end}


{synopthdr:ancilliary methods}
{synoptline}
{synopt:{it:real scalar} F{cmd:.equals(}F2{cmd:)}}1
if {it:F} represents the same data as {it:F2}
(i.e. if .num_obs .num_levels .levels .keys and .counts are equal)
{p_end}
{synopt:{it:real scalar} F{opt .nested_within(vec)}}1
if the factor {it:F} is
{browse "http://scorreia.com/software/reghdfe/faq.html#what-does-fixed-effect-nested-within-cluster-means":nested within}
the column vector {it:vec}
(i.e. if any two obs. with the same factor level also have the same value of {it:vec}).
For instance, it is true if the factor {it:F} represents counties and {it:vec} represents states.
{p_end}
{synopt:{it:void} F{cmd:.drop_obs(}{it:idx}{cmd:)}}update
{it:F} to reflect a change in the underlying dataset, where
the observations listed in the column vector {it:idx} are dropped
(see example below)
{p_end}
{synopt:{it:void} F{cmd:.keep_obs(}{it:idx}{cmd:)}}equivalent
to keeping only the obs. enumerated by {it:idx} and recreating {it:F};
uses {cmd:.drop_obs()}
{p_end}
{synopt:{it:void} F{cmd:.drop_if(}{it:vec}{cmd:)}}equivalent
to dropping the obs. where {it:vec==0} and recreating {it:F};
uses {cmd:.drop_obs()}
{p_end}
{synopt:{it:void} F{cmd:.keep_if(}{it:vec}{cmd:)}}equivalent
to keeping the obs. where {it:vec!=0} and recreating {it:F};
uses {cmd:.drop_obs()}
{p_end}
{synopt:{it:real colvector} F{cmd:.drop_singletons()}}equivalent
to dropping the levels that only appear once,
and their corresponding observations.
The colvector returned contains the observations that need to be excluded
(note: see the source code for some advanced optional arguments).
{p_end}
{synopt:{it:real scalar} F{opt .is_id()}}1
if {it:F.counts} is always 1
(i.e. if {it:F.levels} has no duplicates)
{p_end}
{synopt:{it:real vector} F{cmd:.intersect(}{it:vec}{cmd:)}}return
a mask vector equal to 1 if the row of {it:vec} is also on F.keys.
Also accepts the integers_only and verbose options: {it:mask = F.intersect(y, 1, 1)}
{p_end}


{synopthdr:available after F.panelsetup()}
{synoptline}
{synopt:{it:transmorphic matrix} F{cmd:.sort(}{it:data}{cmd:)}}equivalent to
{cmd:data[F.p, .]}
but calls {cmd:F.panelsetup()} if required; {it:data} is a {it:transmorphic matrix}{p_end}
{synopt:{it:transmorphic matrix} F{cmd:.invsort(}{it:data}{cmd:)}}equivalent to
{cmd:data[invorder(F.p), .]}, so it undoes a previous sort operation. Note that {cmd:F.invsort(F.sort(x))==x}. Also, after used it fills the vector {cmd:F.inv_p = invorder(F.p)} so the operation can be repeated easily.
{p_end}
{synopt:{it:void} F{cmd:._sort(}{it:data}{cmd:)}}in-place version of
{cmd:.sort()};
slower but uses less memory, as it's based on {cmd:_collate()}{p_end}
{synopt:{it:real vector} F{cmd:.info}}equivalent to {help mf_panelsetup:panelsetup()}
(returns a {it:(num_levels X 2)} matrix with start and end positions of each level/panel).{p_end}
{p2coldent:}{bf:note:} instead of using {cmd:F.info} directly, use panelsubmatrix():
{cmd:x = panelsubmatrix(X, i, F.info)} and {cmd:panelsum()}(see example at the end){p_end}
{synopt:{it:real vector} F{cmd:.p}}equivalent to {cmd:order(F.levels)}
but implemented with a counting sort that is asymptotically
faster ({it:O(N)} instead of {it:O(N log N)}.{p_end}
{p2coldent:}{bf:note:} do not use {cmd:F.p} directly, as it will be missing if the data is already sorted by the varnames.{p_end}
{p2colreset}{...}


{pstd}Notes:

{synoptset 3 tabbed}{...}
{synopt:- }If you just downloaded the package and want to use the Mata functions directly (instead of the Stata commands), run {stata ftools} once to, which creates the Mata library if needed.{p_end}
{synopt:- }To force compilation of the Mata library, type {stata ftools, compile}{p_end}
{synopt:- }{cmd:F.extra} is an undocumented {help mf_asarray:asarray}
that can be used to store additional information: {cmd:asarray(f.extra, "lorem", "ipsum")};
and retrieve it: {cmd:ipsum = asarray(f.extra, "lorem")}{p_end}
{synopt:- }{cmd:join_factors()} is particularly fast if the dataset is sorted in the same order as the factors{p_end}
{synopt:- }{cmd:factor()} will call {cmd:join_factors()} if appropriate
(2+ integer variables; 10,000+ obs; and method=hash1)
{p_end}


{marker description}{...}
{title:Description}

{pstd}
The {it:Factor} object is a key component of several commands that
manipulate data without having to sort it beforehand:

{pmore}- {help fcollapse} (alternative to collapse, contract, collapse+merge and some egen functions){p_end}
{pmore}- {help fegen:fegen group}{p_end}
{pmore}- {help fisid}{p_end}
{pmore}- {help join} and {help fmerge} (alternative to m:1 and 1:1 merges){p_end}
{pmore}- {help flevelsof} plug-in alternative to {help levelsof}{p_end}
{pmore}- {help fsort} (note: this is O(N) but with a high constant term){p_end}
{pmore}- freshape{p_end}

Ancilliary commands include:

{pmore}- {help local_inlist} return local {it:inlist} based on a variable and a list of values or labels{p_end}

{pstd}
It rearranges one or more categorical variables into a new variable that takes values from 1 to F.num_levels. You can then efficiently sort any other variable by this, in order to compute groups statistics and other manipulations.

{pstd}
For technical information, see
{browse "http://stackoverflow.com/questions/8991709/why-are-pandas-merges-in-python-faster-than-data-table-merges-in-r/8992714#8992714":[1]}
{browse "http://wesmckinney.com/blog/nycpython-1102012-a-look-inside-pandas-design-and-development/":[2]},
and to a lesser degree
{browse "https://my.vertica.com/docs/7.1.x/HTML/Content/Authoring/AnalyzingData/Optimizations/AvoidingGROUPBYHASHWithProjectionDesign.htm":[3]}.


{marker usage}{...}
{title:Usage}

{pstd}
If you only want to create identifiers based on one or more variables,
run something like:

{inp}
    {hline 60}
    sysuse auto, clear
    mata: F = factor("foreign turn")
    mata: F.store_levels("id")
    mata: mata drop F
    {hline 60}
{txt}

{pstd}
More complex scenarios would involve some of the following:

{inp}
    {hline 60}
    sysuse auto, clear

    * Create factors for foreign data only
    mata: F = factor("turn", "foreign")

    * Report number of levels, obs. in sample, and keys
    mata: F.num_levels
    mata: F.num_obs
    mata: F.keys, F.counts

    * View new levels
    mata: F.levels[1::10]
    
    * Store back new levels (on the same sample)
    mata: F.store_levels("id")
    
    * Verify that the results are correct
    sort id
    li turn foreign id in 1/10
    {hline 60}
{txt}


{marker example}{...}
{title:Example: operating on levels of each factor}

{pstd}
This example shows how to process data for each level of the factor (like {help bysort}). It does so by combining {cmd:F.sort()} with {help mf_panelsetup:panelsubmatrix()}.
{p_end}

{pstd}
In particular, this code runs a regression for each category of {it:turn}:
{p_end}

{inp}
    {hline 60}
    clear all
    mata:
    real matrix reg_by_group(string depvar, string indepvars, string byvar)
    {
    	class Factor scalar			F
    	real scalar				i
    	real matrix				X, Y, x, y, betas
    
    	F = factor(byvar)
    	Y = F.sort(st_data(., depvar))
    	X = F.sort(st_data(., tokens(indepvars)))
    	betas = J(F.num_levels, 1 + cols(X), .)
    	
    	for (i = 1; i <= F.num_levels; i++) {
    		y = panelsubmatrix(Y, i, F.info)
    		x = panelsubmatrix(X, i, F.info) , J(rows(y), 1, 1)
    		betas[i, .] = qrsolve(x, y)'
    	}
    	return(betas)
    }
    end
    sysuse auto
    mata: reg_by_group("price", "weight length", "foreign")
    {hline 60}
{text}


{marker example2}{...}
{title:Example: Factors nested within another variable}

{pstd}
You might be interested in knowing if a categorical variable is nested within another, more coarser, variable.
For instance, a variable containing months ("Jan2017") is nested within another containing years ("2017")),
a variable containing counties ("Durham County, NC") is nested within another containing states ("North Carolina"), and so on.
{p_end}

{pstd}
To check for this, you can follow this example:
{p_end}

{inp}
    {hline 60}
    sysuse auto
    gen turn10 = int(turn/10)
    
    mata:
        F = factor("turn")
        F.nested_within(st_data(., "trunk")) // False
        F.nested_within(st_data(., "turn")) // Trivially true
        F.nested_within(st_data(., "turn10")) // True
    end
    {hline 60}
{txt}

{pstd}
You can also compare two factors directly:
{p_end}

{inp}
    {hline 60}
    mata:
        F1 = factor("turn")
        F2 = factor("turn10")
        F1.nested_within(F2.levels) // True
    end
    {hline 60}
{txt}


{marker example3}{...}
{title:Example: Updating a factor after dropping variables}

{pstd}
If you change the underlying dataset you have to recreate the factor, which is costly. As an alternative, you can use {cmd:.keep_obs()} and related methods:
{p_end}

{inp}
    {hline 60}
    * Benchmark
    sysuse auto, clear
    drop if price > 4500
    mata: F1 = factor("turn")
    // Quickly inspect results
    mata: F1.num_obs, F1.num_levels, hash1(F1.levels)
    
    * Using F.drop_obs()
    sysuse auto, clear
    mata
        price = st_data(., "price")
        F2 = factor("turn")
        idx = selectindex(price :> 4500)
        mata: F2.num_obs, F2.num_levels, hash1(F2.levels)
        F2.drop_obs(idx)
        mata: F2.num_obs, F2.num_levels, hash1(F2.levels)
        assert(F1.equals(F2))
    end
    
    * Using the other methods
    mata
        F2 = factor("turn")
        idx = selectindex(price :<= 4500)
        F2.keep_obs(idx)
        assert(F1.equals(F2))
    
        F2 = factor("turn")
        F2.drop_if(price :> 4500)
        assert(F1.equals(F2))
    
        F2 = factor("turn")
        F2.keep_if(price :<= 4500)
        assert(F1.equals(F2))
    end
    {hline 60}
{txt}


{marker remarks}{...}
{title:Remarks}

{pstd}
All-numeric and all-string varlists are allowed, but
hybrid varlists (where some but not all variables are strings) are not possible
due to Mata limitations.
As a workaround, first convert the string variables to numeric (e.g. using {cmd:fegen group()}) and then run your intended command.

{pstd}
You can pass as {varlist} a string like "turn trunk"
or a tokenized string like ("turn", "trunk").

{pstd}
To generate a group identifier, most commands first sort the data by a list of keys (such as {it:gvkey, year}) and then ask if the keys differ from one observation to the other.
Instead, {cmd:ftools} exploits the insights that sorting the data is not required to create an identifier,
and that once an identifier is created, we can then use a {it:counting sort} to sort the data in {it:O(N)} time instead of {it:O log(N)}.

{pstd}
To create an identifier (that takes a value in {1, {it:#keys}}) we first match each key (composed by one or more numbers and strings) into a unique integer.
 For instance, the key {it:gvkey=123, year=2010} is assigned the integer {it:4268248869} with the Mata function {cmd:hash1}.
 This identifier can then be used as an index when accessing vectors, bypassing the need for sorts.

{pstd}
The program tries to pick the hash function that best matches the dataset and input variables.
For instance, if the input variables have a small range of possible values (e.g. if they are of {it:byte} type), we select the {it:hash0} method, which uses a (non-minimal) perfect hashing but might consume a lot of memory.
Alternatively, {it:hash1} is used, which adds {browse "https://www.wikiwand.com/en/Open_addressing":open addressing} to Mata's
{help mf_hash1:hash1} function to create a form of open addressing (that is more efficient than Mata's {help mf_asarray:asarray}).


{marker collapse}{...}
{title:Using the functions from {it:fcollapse}}

{pstd}
You can access the {cmd:aggregate_*()} functions so you can collapse information without resorting to Stata. Example:

{inp}
    {hline 60}
    sysuse auto, clear
    mata: F = factor("turn")
    mata: F.panelsetup()
    mata: y = st_data(., "price")
    mata: sum_y = aggregate_sum(F, F.sort(y), ., "")
    mata: F.keys, F.counts, sum_y
    
    * Benchmark
    collapse (sum) price, by(turn)
    list
    {hline 60}
{txt}

Functions start with {cmd:aggregate_*()}, and are listed {view fcollapse_functions.mata, adopath asis:here}


{marker experimental}{...}
{title:Experimental/advanced functions}

{p 8 16 2}
{it:real scalar}
{bind: }{cmd:init_zigzag(}{it:F1}{cmd:,}
{it:F2}{cmd:,}
{it:F12}{cmd:,}
{it:F12_1}{cmd:,}
{it:F12_2}{cmd:,}
{it:queue}{cmd:,} 
{it:stack}{cmd:,}
{it:subgraph_id}{cmd:,}
{it:verbose}{cmd:)}

{pstd}Notes:

{synoptset 3 tabbed}{...}
{synopt:- }Given the bipartite graph formed by F1 and F2,
the function returns the number of disjoin subgraphs (mobility groups){p_end}
{synopt:- }F12 must be set with levels_as_keys==1{p_end}
{synopt:- }For F12_1 and F12_2, you can set save_keys==0{p_end}
{synopt:- }The function fills three useful vectors: queue, stack and subgraph_id{p_end}
{synopt:- }If subgraph_id==0, it the id vector will not be created{p_end}


{marker source}{...}
{title:Source code}

{pstd}
{view ftools.mata, adopath asis:ftools.mata};
{view ftools_type_aliases.mata, adopath asis:ftools_type_aliases.mata};
{view ftools_main.mata, adopath asis:ftools_main.mata};
{view ftools_bipartite.mata, adopath asis:ftools_bipartite.mata}
{view fcollapse_functions.mata, adopath asis:fcollapse_functions.mata}
{p_end}

{pstd}
Also, the latest version is available online: {browse "https://github.com/sergiocorreia/ftools/source"}


{marker author}{...}
{title:Author}

{pstd}Sergio Correia{break}
{break}
{browse "http://scorreia.com"}{break}
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
This project was largely inspired by the works of
{browse "http://wesmckinney.com/blog/nycpython-1102012-a-look-inside-pandas-design-and-development/":Wes McKinney}, 
{browse "http://www.stata.com/meeting/uk15/abstracts/":Andrew Maurer}
and
{browse "https://ideas.repec.org/c/boc/bocode/s455001.html":Benn Jann}.
{p_end}

