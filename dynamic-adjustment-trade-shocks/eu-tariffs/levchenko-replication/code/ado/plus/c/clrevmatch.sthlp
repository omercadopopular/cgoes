{smcl}
{* 12 August 2014}{...}
{cmd:help clrevmatch}{right: ({browse "http://www.stata-journal.com/article.html?article=dm0082":SJ15-3: dm0082})}
{hline}

{title:Title}

{p2colset 5 19 21 2}{...}
{p2col:{cmd:clrevmatch} {hline 2}}Interactive clerical review utility for use after probabilistic record linkage between two datasets
{p2colreset}{...}


{title:Syntax}

{p 8 18 2}
{cmd:clrevmatch} {cmd:using} {it:filename}{cmd:,}
{cmdab:idm:aster(}{it:varname}{cmd:)}
{cmdab:idu:sing(}{it:varname}{cmd:)} {cmd:varM(}{it:varlist}{cmd:)}
{cmd:varU(}{it:varlist}{cmd:)} {cmd:clrev_result(}{it:newvarname}{cmd:)}
{cmd:clrev_note(}{it:newvarname}{cmd:)} [{cmd:reclinkscore(}{it:varname}{cmd:)}
{cmd:rlscoremin(}{it:#}{cmd:)} {cmd:rlscoremax(}{it:#}{cmd:)}
{cmd:rlscoredisp(on}|{cmd:off)} {cmd:fast}
{cmd:clrev_label(}{it:label}{cmd:)} {cmd:nobssave(}{it:#}{cmd:)} {cmd:replace}
{cmd:newfilename(}{it:newfilename}{cmd:)} {cmd:saveold}]{p_end}


{title:Description}

{pstd}
{cmd:clrevmatch} provides an interactive tool to assist in the clerical review
of matched pairs generated from a record-linkage program (for example, 
{helpb reclink}, {helpb reclink2}).  The program displays a potential match
such that the pair of records constituting the match are easily assessed by
the user.  The user then inputs a clerical review indicator on whether the
matched pair is accepted, rejected, or left as uncertain.  Alternative labels
can be specified.  The {cmd:clrevmatch} program also checks for multiple
matches for a given record in the master dataset.  If multiple matches exist,
the program indicates how many matches exist for that record and then displays
all potential candidates.  The user can then assign a clerical decision for
each candidate.  Some of the required inputs are explained below.{p_end}

{pstd}
{cmd:using} {it:filename} specifies the name of the dataset to be reviewed.
This dataset must contain machine-generated matched pairs from two datasets
(called the master and using datasets) along with their record identifiers,
{cmd:idmaster()} and {cmd:idusing()}.  The user must either specify
{cmd:replace} to save the clerical decisions into the existing dataset or
{cmd:newfilename()} to generate results in a new file.{p_end}


{title:Options}

{phang}
{cmd:idmaster(}{it:varname}{cmd:)} specifies the record identifiers
from the master dataset.  {cmd:idmaster()} is required.

{phang}
{cmd:idusing(}{it:varname}{cmd:)} specifies the record identifiers
from the using dataset.  {cmd:idusing()} is required.

{phang}
{cmdab:varM(}{it:varlist}{cmd:)} and {cmdab:varU(}{it:varlist}{cmd:)} specify
the set of variables in the master and using datasets, respectively, that will
be displayed during the review.  The user can specify not only the set of
variables used when matching but also other existing variables in the dataset
that may help assess the candidates.  {cmd:varM()} and {cmd:varU()} are
required.

{phang}
{cmdab:clrev_result(}{it:newvarname}{cmd:)} specifies a new variable name to
record the user's clerical review input.  {cmd:clrev_result()} is required.

{phang}
{cmdab:clrev_note(}{it:newvarname}{cmd:)} specifies a new variable name for
the user to enter a note associated with each pair of records.  Because
clerical review is often a lengthy and time-consuming component of record
linking, this program periodically saves the results as the user progresses.
If the reviewer does not finish reviewing the whole dataset in one session, he
or she can continue to work in the next session by entering the same
{cmd:clrev_result()} and {cmd:clrev_note()} variables.  A different reviewer
may want to use different variable names for these two variables.
{cmd:clrev_note()} is required.

{phang}
{cmdab:reclinkscore(}{it:varname}{cmd:)} specifies the variable containing the
machine-generated score from the matching step.  If this option is not
specified, all other score-related options are disabled.
 
{phang} {cmdab:rlscoremin(}{it:#}{cmd:)} and {cmdab:rlscoremax(}{it:#}{cmd:)}
allow the user to specify the range of machine-generated scores so that only
those pairs matching the specified criteria will appear for clerical review.
The default is {cmd:rlscoremin(0)} and {cmd:rlscoremax(1)}.

{phang}
{cmdab:rlscoredisp(on}|{cmd:off)} is set to {cmd:rlscoredisp(on)} by default,
such that the display includes the machine-generated score from the
{cmd:reclinkscore()} option.  If the user does not want the score to influence
the clerical review decision, specify {cmd:rlscoredisp(off)} so that the score
will not be displayed.

{phang}
{cmdab:fast} speeds up the review process.  By default, the reviewer is asked
to confirm the clerical input, and then the program allows the reviewer to
enter any additional notes for later review or editing.  Specifying
{cmdab:fast} will cause the program to skip these steps.

{phang}
{cmdab:clrev_label(}{it:label}{cmd:)} allows the user to specify the labels
for the clerical review results.  By default, the program asks for the
reviewer to enter {cmd:0} for {cmd:"not a match"}, {cmd:1} for 
{cmd:"maybe a match"}, {cmd:2} for {cmd:"very likely a match"}, and {cmd:3}
for {cmd:"definitely a match"}.  The label can be user specified using Stata's
label format. For example, an alternative label could be a simpler one like
{cmd:clrev_label(0 "not match" 1 "match")} or a more specific one like
{cmd:clrev_label(1 "only names matched" 2 "only addresses matched" 3 "both}
{cmd:matched" 4 "neither matched")}.  The program will attach the specified
label to the {cmd:clrev_result()} variable.

{phang}
{cmdab:nobssave(}{it:#}{cmd:)} specifies how often the program will save the
results.  By default, the program will save the file after every five records.

{phang}
{cmdab:replace} overwrites the dataset specified in {it:filename}.

{phang}
{cmd:newfilename(}{it:newfilename}{cmd:)} outputs results as a new dataset, as
specified by {cmd:newfilename(}{it:newfilename}{cmd:)}.  Note that either
{cmd:replace} or {cmdab:newfilename()} must be chosen for the program to
proceed.

{phang}
{cmdab:saveold} saves the dataset in an older Stata format.


{title:Examples}

{phang2}
{cmd:. clrevmatch using reclinking_forreview,  idm(rid) idu(firm_id) varM(stn_name add1 pobox city state) varU(Ustn_name Uadd1 Upobox Ucity Ustate) reclinkscore(rlsc) clrev_result(crev) clrev_note(crnote) replace} 

{pstd}
The above code starts the clerical review by using the default review labels.
The display will include the variables {cmd:stn_name}, {cmd:add1},
{cmd:pobox}, {cmd:city}, and {cmd:state} from the master dataset and the
variables {cmd:Ustn_name}, {cmd:Uadd1}, {cmd:Upobox}, {cmd:Ucity}, and
{cmd:Ustate} from the using dataset.  The user's inputs will be saved in the
variables {cmd:crev} and {cmd:crnote}.

{phang2}
{cmd:. local mylabel `"0 "not match" 1 "match""'}{p_end}
{phang2}
{cmd:. clrevmatch using reclinking_forreview,  idm(rid) idu(firm_id) varM(stn_name add1 city county MSA state) varU(Ustn_name Uadd1 Ucity Ustate) reclinkscore(rlsc) clrev_result(crev2) clrev_note(crnote2) clrev_label(`mylabel') replace}{p_end}

{pstd}
The above code asks the reviewer to enter {cmd:0} for {cmd:"not match"} and
{cmd:1} for {cmd:"match"}. The display will include the variables
{cmd:stn_name}, {cmd:add1}, {cmd:city}, {cmd:county}, {cmd:MSA}, and
{cmd:state} from the master dataset and the variables {cmd:Ustn_name},
{cmd:Uadd1}, {cmd:Ucity}, and {cmd:Ustate} from the using dataset. The user's
inputs will be saved in the variables {cmd:crev2} and {cmd:crnote2}.{p_end}


{title:Author}

{pstd}Nada Wasi{p_end}
{pstd}Survey Research Center{p_end}
{pstd}Institute for Social Research{p_end}
{pstd}University of Michigan{p_end}
{pstd}Ann Arbor, MI{p_end}
{pstd}{browse "mailto:nwasi@umich.edu":nwasi@umich.edu}


{title:Also see}

{p 4 14 2}Article:  {it:Stata Journal}, volume 15, number 3: {browse "http://www.stata-journal.com/article.html?article=dm0082":dm0082}{p_end}
