{smcl}
{* *! version 2.37.0 16aug2019}{...}
{vieweralsosee "ftools" "help ftools"}{...}
{vieweralsosee "fmerge" "help fmerge"}{...}
{vieweralsosee "[R] merge" "help merge"}{...}
{viewerjumpto "Syntax" "join##syntax"}{...}
{viewerjumpto "description" "join##description"}{...}
{viewerjumpto "options" "join##options"}{...}
{viewerjumpto "examples" "join##examples"}{...}
{viewerjumpto "about" "join##about"}{...}
{title:Title}

{p2colset 5 13 20 2}{...}
{p2col :{cmd:join} {hline 2}}Join/merge datasets{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{pstd}
Many-to-one join/merge on specified key variables

{p 8 13 2}
{cmd:join}
[{varlist}]{cmd:,}
{opth from(filename)}
{opth by(varlist)}
[{it:options}]

{pstd}
As above, but with the "using" dataset currently open instead of the "master"

{p 8 13 2}
{cmd:join}
[{varlist}]{cmd:,}
{opth into(filename)}
{opth by(varlist)}
[{it:options}]

{pstd}
(Note: if {it:varlist} is specified, only a subset of the variables will be added)



{synoptset 24 tabbed}{...}
{synopthdr}
{synoptline}
{p2coldent:+ {cmd:from(}{help filename} [{help if}]{cmd:)}}filename of the {it:using} dataset, where the keys are unique{p_end}
{...}
{p2coldent:+ {cmd:into(}{help filename} [{help if}]{cmd:)}}filename of the {it:master} dataset{p_end}
{...}
{p2coldent:* {opth by(varlist)}}key variables; {it:master_var=using_var} is also allowed in case the variable names differ between datasets{p_end}
{...}
{synopt :{opt uniq:uemaster}}assert that the merge will be 1:1
{p_end}
{...}
{synopt :{cmd:keep(}{help join##results:{it:results}}{cmd:)}}specify which match results to keep
{p_end}
{...}
{synopt :{cmd:assert(}{help join##results:{it:results}}{cmd:)}}specify required match results
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
{synopt :{opt keepn:one}}don't add any variables from using (overrides default of {it:_all}){p_end}
{...}
{synopt :{opt v:erbose}}show internal debug info
{...}
{p_end}
{synopt :{opt method(string)}}(advanced) set method used internally for hashing
{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}+ you must include either {opt from()} or {opt from()} but not both.{p_end}
{p 4 6 2}* {opt by(varlist)} is required.{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:join} is an alternative for {help merge},
supporting {it:m:1} and {it:1:1} joins.
{p_end}

{pstd}{bf:Advantages:}

{pmore}- Increasingly faster above 100,000 obs (it is O(N) instead of O(N log N)){p_end}
{pmore}- Does not sort the data by the keys{p_end}
{pmore}- Keys can have different names in master and using{p_end}

{pstd}{bf:Technical notes:}

{pstd}
{cmd:join} works by hashing the keys, instead of sorting the data like {cmd:merge} does
(see 
{browse "https://my.vertica.com/docs/7.1.x/HTML/Content/Authoring/AnalyzingData/Optimizations/HashJoinsVs.MergeJoins.htm":[1]}
and
{browse "http://support.sas.com/resources/papers/proceedings09/071-2009.pdf":[2]}
for a comparison of the hash+join and sort+merge algorithms).
As a result, {cmd:join} performs better if the datasets are not
already sorted by the {it:by()} variables, and for datasets
above 100,000 observations (due to Mata's overhead).
{p_end}


{marker options}{...}
{title:Options}

{dlgtab:Options}

{phang}
{opth from(filename)}
    specifies the {it:using} filename.
    This dataset is typically smaller than the master dataset
    (the one currently active)
    and the key variables set with {cmd:by()} must uniquely
    identify the dataset (see {cmd:isid} and {cmd:fisid}).

{pmore}
    If {cmd:by()} does not identify the {it:using} dataset
    but a subset of it, you can add use {if} within {cmd:from}

{pmore}
    EG: Suppose master has country-level data for a the year 2016,
    and {xyz} has country-year GDP data, then you can do
    {it:using(xyz if year==2016)}

{phang}
    {opth into(filename)} is useful if you are currently in the
    {it:using} dataset. This is faster than the alternative of
    saving, loading the master dataset, and then calling {it:join}
    (which would then have to open the using dataset again)

{phang}
{opth by(varlist)}
    specifies the key variables 
    that will be used to join both datasets.
    If the names of the variables differ, you can use
    {it:master_var=using_var} (e.g. {cmd:by(year=yr)})

{phang}
{opt uniquemaster}
    ensures that the match is 1:1 instead of m:1.
    Since a 1:m merge can be replicated with the {opt into()} option,
    this means that all merges except m:m (not recommended),
    and update/replace merges (less useful) are supported.

{phang}
{opth generate(newvar)}
    specifies that the variable containing match
    {help merge##results:results} information should be named {it:newvar}
    rather than {cmd:_merge}.

{phang}
{cmd:nogenerate} specifies that {cmd:_merge} not be created.  This
    would be useful if you also specified {cmd:keep(match)}, because
    {cmd:keep(match)} ensures that all values of {cmd:_merge} would be 3.

{phang}
{cmd:nolabel}
    specifies that value-label definitions from the using file be ignored.
    This option should be rare, because definitions from the master are
    already used.

{phang}
{cmd:nonotes}
    specifies that notes in the using dataset not be added to the 
    merged dataset; see {manhelp notes D:notes}.

{phang}
{cmd:keepnone}
    specifies that no variables from using will be added. Use this in combination
    with {cmd:keep(match)} if you just want to keep a group of observations
    from the master dataset.

{phang}
{cmd:noreport}
    specifies that {cmd:join} not present its summary table of
    match results.

{phang}
{cmd:assert(}{it:results}{cmd:)}
    specifies the required match results.  The possible
    {it:results} are 

{marker results}{...}
           numeric    equivalent
            code      word ({it:results})     description
           {hline 67}
              {cmd:1}       {cmdab:mas:ter}             observation appeared in master only
              {cmd:2}       {cmdab:us:ing}              observation appeared in using only
              {cmd:3}       {cmdab:mat:ch}              observation appeared in both

{pmore}
Numeric codes and words are equivalent when used in the {cmd:assert()}
or {cmd:keep()} options.

{pmore}
The following synonyms are allowed:
{cmd:masters} for {cmd:master}, 
{cmd:usings} for {cmd:using},
{cmd:matches} and {cmd:matched} for {cmd:match},
{cmd:match_updates} for {cmd:match_update}, 
and 
{cmd:match_conflicts} for {cmd:match_conflict}. 

{pmore}
    Using {cmd:assert(match master)} specifies that the merged file is
    required to include only matched master or using 
    observations and unmatched master observations, and may not 
    include unmatched using observations.  Specifying {cmd:assert()}
    results in {cmd:join} issuing an error if there are match results
    among those observations you allowed.

{pmore}
The order of the words or codes is not important, so all the following
{cmd:assert()} specifications would be the same:

{pmore2}
{cmd:assert(match master)}

{pmore2}
{cmd:assert(master matches)}

{pmore2}
{cmd:assert(1 3)}

{pmore}
    When the match results contain codes other than those allowed,
    return code 9 is returned, and the 
    merged dataset with the unanticipated results is left in memory
    to allow you to investigate.

{phang}
{cmd:keep(}{help join##results:{it:results}}{cmd:)}
    specifies which observations are to be kept from the merged dataset.
    Using {cmd:keep(match master)} specifies keeping only
    matched observations and unmatched master observations after merging.

{pmore}
    {cmd:keep()} differs from {cmd:assert()} because it selects
    observations from the merged dataset rather than enforcing requirements.
    {cmd:keep()}
    is used to pare the merged dataset to a given set of observations when
    you do not care if there are other observations in the merged dataset.
    {cmd:assert()} is used to verify that only a given set of observations
    is in the merged dataset.

{pmore}
   You can specify both {cmd:assert()} and {cmd:keep()}.  If you require 
   matched observations and unmatched master observations
   but you want only the matched observations, then you could specify
   {cmd:assert(match master)} {cmd:keep(match)}.


{phang}
{cmd:verbose}
    is a programmer command that will report Mata debug information


{marker examples}{...}
{title:Examples}

{pstd}Perform m:1 merge{p_end}

{inp}
    {hline 60}
    webuse nlswork
    replace year = 1900 + year
    join xrate, by(year) from(http://www.stata-press.com/data/r14/pennxrate.dta if country=="JPN")
    {hline 60}
{txt}


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
