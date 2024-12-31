{smcl}
{* 25 March 2014}{...}
{cmd:help reclink2}{right: ({browse "http://www.stata-journal.com/article.html?article=dm0082":SJ15-3: dm0082})}
{hline}

{title:Title}

{p2colset 5 17 19 2}{...}
{p2col:{cmd:reclink2} {hline 2}}Record-linkage program -- a generalized version of reclink
{p2colreset}{...}


{title:Syntax}

{p 8 16 2}
{cmd:reclink2} {it:varlist} {cmd:using} {it:filename}{cmd:,}
{cmdab:idm:aster(}{it:varname}{cmd:)}
{cmdab:idu:sing(}{it:varname}{cmd:)} {cmdab:g:en(}{it:newvarname}{cmd:)}
[{cmdab:wm:atch(}{it:match_weight_list}{cmd:)}
{cmdab:wnom:atch(}{it:nonmatch_weight_list}{cmd:)}
{cmdab:orbl:ock(}{it:varlist}{cmd:)}
{cmdab:req:uired(}{it:varlist}{cmd:)}
{cmdab:exa:ctstr(}{it:varlist}{cmd:)}
{cmdab:exc:lude(}{it:filename}{cmd:)}
{cmdab:_m:erge(}{it:newvarname}{cmd:)}
{cmdab:uv:arlist(}{it:varlist}{cmd:)} {cmdab:upr:efix(}{it:text}{cmd:)}
{cmdab:mins:core(}{it:#}{cmd:)} {cmdab:minb:igram(}{it:#}{cmd:)} {cmdab:many:toone} {cmdab:np:airs(}{it:#}{cmd:)}]{p_end}


{title:Description}

{pstd}
{cmd:reclink2} performs probabilistic record linkage between two
datasets that have no joint identifier necessary for standard merging.
The command is an extension of the {helpb reclink} command originally
written by Blasnik (2010).  The two datasets are called the
"master" and "using" datasets, where the master dataset is the dataset
currently in use.  For each observation in the master dataset, the
program tries to find a best matched record from the using dataset
based on the specified list of variables, their associated match and
nonmatch weights, and their bigram score.  The {cmd:reclink2} command
introduces two new options, {cmd:manytoone} and {cmd:npairs()}.{p_end}


{title:Options}

{phang}
{cmd:idmaster(}{it:varname}{cmd:)} specifies the name of a variable in the
master dataset that uniquely identifies the observations.  This variable is
used to track observations.  If a unique identifier does not exist, one can be
created using {cmd:generate idmaster=_n}.  The {opt idmaster()} option is
required.

{phang}
{cmd:idusing(}{it:varname}{cmd:)} specifies the name of a
variable in the using dataset that uniquely identifies the observations
analogous to {opt idmaster()}.  {opt idusing()} is required.

{phang}
{cmd:gen(}{it:newvarname}{cmd:)} specifies the name of a new
variable created by {cmd:reclink2} to store the matching scores (scaled 0-1)
for the linked observations.  {opt gen()} is required.

{phang}
{cmd:wmatch(}{it:match_weight_list}{cmd:)} specifies the
{it:weight}s given to matches for each variable in {it:varlist}.  Each
variable requires a {it:weight}.  The default is {cmd:wmatch(1)}.
{it:weight}s must be >=1 and are typically integers from 1-20.  The
values should reflect the relative likelihood of a variable match
indicating a true observation match.  For example, a {cmd:name} variable
will often have a large {it:weight} such as 10, but a {cmd:city}
variable, where many duplicates are expected, may have a {it:weight} of
just 2.

{phang}
{cmd:wnomatch(}{it:nonmatch_weight_list}{cmd:)} specifies the
{it:weight}s given to mismatches for each variable in the {it:varlist}.
These {it:weight}s are analogous to {opt wmatch()}s but instead
reflect the relative likelihood that a mismatch on a variable indicates
that the observations do not match -- a small value indicates that
mismatches are expected even if the observations truly match.  A
variable such as telephone number may have a large {cmd:wmatch()} but a
small {cmd:wnomatch()}, because matches are unlikely to occur randomly,
but mismatches may be fairly common because of changes in phone numbers
over time or multiple phone numbers owned by the same person or entity.

{phang}
{cmd:orblock(}{it:varlist}{cmd:)} is used to speed up the record linkage by
providing a method for selecting only subsets of observations from the using
dataset to search for matches.  Only observations that match on at least one
variable in the or-block are examined.  Or-blocking on the full {it:varlist}
is the default behavior if four or more variables are specified.  This default
can be overridden by specifying {cmd:orblock(none)}, which is advised if all
variables are expected to be unique.  New variables are sometimes created in
the master and using datasets to assist with or-blocking, such as initials of
first and last names, street numbers extracted from addresses, and telephone
area codes.  Or-blocking can dramatically improve the speed of {cmd:reclink2}.

{phang}
{cmd:required(}{it:varlist}{cmd:)} specifies one or more variables that must
match exactly for the observation to be considered a match.  The variables
must also be in the main {it:varlist} and are included in the matching score.
{cmd:required()} could have been named {cmd:andblock()} to make its function
clear in relation to {cmd:orblock()}.

{phang}
{cmd:exactstr(}{it:varlist}{cmd:)} specifies one or more string variables
where the bigram string comparator is not used to assess the degree of
agreement, but instead, the agreement is simply 0 or 1.

{phang}
{cmd:exclude(}{it:filename}{cmd:)} specifies the name of a file that contains
previously matched observations, providing a convenient way to use
{cmd:reclink} repeatedly with different specifications.  The {cmd:exclude()}
file must include the variables specified in {cmd:idmaster()} and
{cmd:idusing()}.  Any observation with nonmissing values for both ID variables
is considered matched and is excluded from the datasets for the current
matching.  Results from each run of {cmd:reclink} can be appended together and
specified as the {cmd:exclude()} file.  This approach can speed up the
matching by starting with a more restrictive {cmd:orblock()} setting and
{cmd:required()} specifications that work quickly, followed by a more
exhaustive and slower search for the more difficult observations.

{phang}
{cmd:_merge(}{it:newvarname}{cmd:)} specifies the name of the
variable that will mark the source of each observation.  The default is
{cmd:_merge(_merge)}.

{phang}
{cmd:uvarlist(}{it:varlist}{cmd:)} allows the using dataset to
have different variable names than the master dataset for the variables
to be matched.  If specified, {cmd:uvarlist()} must have the same
number of variables in the same order as the master {it:varlist}.

{phang}
{cmd:uprefix(}{it:text}{cmd:)} changes the prefix used
for renaming the variables in the matching {it:varlist} that are added to the master dataset from the using dataset.  The default is
{cmd:uprefix(U)}. For example, if the matching variables are {cmd:name}
and {cmd:address}, then the resulting dataset will have variables
{cmd:Uname} and {cmd:Uaddress} added from the using dataset for the
matching observations.

{phang}
{cmd:minscore(}{it:#}{cmd:)} specifies the minimum overall
matching score value (0-1) used to declare two observations a match.
The default is {cmd:minscore(0.6)}.  Observations in the using dataset
are merged into the master dataset only if they have a match score >=
{cmd:minscore()} and are the highest match score in the using dataset.
Lower values of {cmd:minscore()} will expand the number of matches but
may lead to more false matches.

{phang}
{cmd:minbigram(}{it:#}{cmd:)} specifies the bigram value needed to
declare two strings as possibly matched.  The default is {cmd:minbigram(0.6)}.
Each raw bigram score is transformed into match and nonmatch weight
multipliers that vary from 0 to 1, with a sharp change at {cmd:minbigram()}.
A higher value of {cmd:minbigram()} may be useful when matching longer
strings.

{phang}
{cmd:manytoone} specifies that {cmd:reclink2} will allow records
from the using dataset to be matched to multiple records from the
master dataset (a many-to-one linking procedure).  In the base version
of {cmd:reclink}, the first step finds and removes perfectly matched
pairs from both datasets.  Hence, a record in the using dataset that is
perfectly matched to a record in the master dataset cannot be
subsequently linked to an additional record in the master dataset for
which it is an adequate, though not perfect, match.  This option
effectively allows for sampling with replacement from the using dataset.

{phang}
{cmd:npairs(}{it:#}{cmd:)} specifies that the program retains the top # of
potential matches (above the minimum-score threshold) from the using dataset
that correspond to a given record in the master dataset.  In the base version
of {cmd:reclink}, only the candidate with the highest match score is retained
as a match -- unless the top match scores are identical.  Because the
approximate string comparator is imperfect, an incorrect record sometimes
gets a higher score than a correct record and is selected by {cmd:reclink} as
the best match.  Typically, such matches must be removed during clerical
review; then, in subsequent passes, the {it:varlist} or weights are
altered to find the more appropriate match.  {cmd:npairs()} allows the user to
review and find additional matches that would have otherwise required multiple
"passes" and, hence, multiple stages of clerical review.  Because there is no
increase in computation time for {cmd:npairs()}, it should help improve
efficiency for large-scale matching problems that typically rely on multiple
passes for optimal accuracy and coverage.  Note, however, that while
{cmd:npairs(}{it:#}{cmd:)} can capture a correct match that does not yield the
highest score, incorrect matches that pass the minimum-score threshold will
also be included in the output.  Therefore, we recommend that users keep
{it:#} small (typically 2 or 3) and use {cmd:npairs()} in conjunction with
{cmd:minscore()}.


{title:Example}

{phang}
{cmd:. reclink2 stn_name stn_add1 city zip state using firm_data, gen(myscore) idm(rid) idu(fid) wmatch(10 8 5 5 5) wmnomatch(2 3 4 4 4) required(state) many npairs(2)}

{pstd}
will find matches between the dataset in memory and the
{cmd:firm_data} dataset based on {cmd:stn_name}, {cmd:stn_add1}, {cmd:city},
{cmd:zip}, and {cmd:state}.  The program searches for potential matches
that have an exact match with {cmd:state} only.  For each record in the master
dataset, the top two matches above the specified minimum score (here specified
to be above the default threshold) will be retained.  The {cmd:manytoone}
option indicates that the user wants to allow for one using record to
link to multiple records in the master dataset.{p_end}

{pstd}
If {cmd:manytoone} and {cmd:npairs()} are not specified, {cmd:reclink2}
produces exactly the same results as {cmd:reclink} in most cases.  (It also
corrects for several minor bugs.)  The existing set of options in
{cmd:reclink} is also retained.  The remainder of the description is taken
from {helpb reclink} documentation.{p_end}


{title:Reference}

{phang}
Blasnik, M.  2010. reclink: Stata module to probabilistically match
records.  Statistical Software Components S456876, Department of Economics,
Boston College. {browse "https://ideas.repec.org/c/boc/bocode/s456876.html"}.

{title:Author}

{pstd}Nada Wasi{p_end}
{pstd}Survey Research Center{p_end}
{pstd}Institute for Social Research{p_end}
{pstd}University of Michigan{p_end}
{pstd}Ann Arbor, MI{p_end}
{pstd}{browse "mailto:nwasi@umich.edu":nwasi@umich.edu}

 
{title:Also see}

{p 4 14 2}Article:  {it:Stata Journal}, volume 15, number 3: {browse "http://www.stata-journal.com/article.html?article=dm0082":dm0082}

{p 7 14 2}Help:  {helpb reclink}, {helpb stnd_compname}, {helpb stnd_address}, {helpb clrevmatch} (if installed){p_end}
