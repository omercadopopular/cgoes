{smcl}
{* 29mar2004/5jul2021/30oct2021}{...}
{hline}
help for {hi:tsspell}
{hline}

{title:Identification of spells or runs in time series} 


{p 4 10 2}{cmd:tsspell}
[{it:varname}]
[{cmd:if} {it:exp}]
[{cmd:in} {it:range}]
[{cmd:,}
{c -(} 
{cmdab:f:cond(}{it:fcondstr}{cmd:)} 
{c |}
{cmdab:c:ond(}{it:condstr}{cmd:)} 
{c |}
{cmdab:p:cond(}{it:pcondstr}{cmd:)} 
{c )-} 
{cmd:spell(}{it:spellvar}{cmd:)}
{cmd:seq(}{it:seqvar}{cmd:)}
{cmd:end(}{it:endvar}{cmd:)}
{cmd:replace}
]


{title:Description}

{p 4 4 2}{cmd:tsspell} examines the data, which must be {help tsset} time
series, to identify spells or runs, which are contiguous sequences 
defined by some condition. {cmd:tsspell} generates new variables: 
 
{p 8 8 2}(1) indicating distinct spells (0 for not in spell, or integers 1 up); 

{p 8 8 2}(2) giving sequence in spell (0 for not in spell, or integers 1 up);
and 
 
{p 8 8 2}(3) indicating whether observations occur at the end of spells (0 or
1). 

{p 4 4 2}By default, these variables will be called 
{cmd:_spell}, {cmd:_seq} and {cmd:_end}. 

{p 4 4 2}If the data are panel data, all operations are automatically 
performed separately within panels. 


{title:Remarks} 

{p 4 4 2}There are four ways of defining spells in {cmd:tsspell}. 

{p 4 4 2}First, given 

{p 8 8 2}{cmd:tsspell} {it:varname} 

{p 4 4 2}a new spell starts whenever {it:varname} changes. 
Strictly, the condition is {bind:{cmd:(}{it:varname} {cmd:!= L.}{it:varname}{cmd:)}}  
{bind:{cmd: | (_n == 1)}.} (The condition {cmd:_n == 1} is protection 
against the possibility that the first value is missing.) 

{p 4 4 2}Second, a new spell starts whenever some condition defining the first
observation in a spell is true. A spell ends just before a new spell 
starts. Such a condition may be specified by the {cmd:fcond()} option. 
For example, suppose we wish to divide time into spells of consecutive values. 
A new spell starts whenever {cmd:L.}{it:varname} is missing, 
which works for the first observation as well because the expression 
{it:varname}{cmd:[0]} is evaluated as missing. 
Spells started by earthquakes, eruptions, accidents, revolutions, elections, 
births or other traumatic events may often be defined in this way. 
 
{p 4 4 2}Third, spells are defined by some condition being true for every
observation in the spell. A spell ends when that condition becomes false. Such
a condition may be specified by the {cmd:cond()} option. 
 
{p 4 4 2}Fourth, a special but useful case of the previous kind is
{cmd:cond(}{it:varname}{cmd: > 0 & }{it:varname}{cmd: < .)}; that is, values of
{it:varname} are positive (but not missing).  Given daily data, spells of rain
are defined by there being some rainfall every day. As a convenience, such
conditions may be specified by {cmd:pcond(}{it:varname}{cmd:)}, or more
generally, {cmd:pcond(}{it:expression}{cmd:)}. 
 
{p 4 4 2}Spells are deemed to end at the last observation.  

{p 4 4 2}Specifying {cmd:if} and/or {cmd:in} adds extra conditions
and does not override the rule that spells consist of sequences
of values. 

{p 4 4 2}Missing values may be ignored by using {cmd:if} to exclude them. They
are not ignored by default, as a convenience to users wishing to explore
patterns of missing values. Recall that numeric missing {cmd:.} is treated as
larger than any positive number. Thus be careful to exclude missing values
where appropriate.
 

{title:Options}

{p 4 8 2}{cmd:fcond(}{it:fcondstr}{cmd:)} specifies a true or false condition
that defines the start of a spell: to be precise, the first observation in a
spell.  A new spell starts whenever this condition is true.
    
{p 8 8 2}If {it:varname} is specified, 
and neither {cmd:fcond()} nor {cmd:cond()} is specified,
{cmd:fcond()} defaults to 
{cmd:(}{it:varname} {cmd:!= L.}{it:varname}{cmd:) | (_n == 1)}. 
To span gaps, use 
{cmd:(}{it:varname} {cmd:!= }{it:varname}{cmd:[_n-1]) | (_n == 1)}.

{p 4 8 2}{cmd:cond(}{it:condstr}{cmd:)} specifies a true or false condition 
that defines a spell. 

{p 4 8 2}{cmd:pcond(}{it:pcondstr}{cmd:)} is equivalent to 

{p 8 8 2}{cmd:cond((}{it:pcondstr}{cmd:) > 0 & (}{it:pcondstr}{cmd:) < .))} 

{p 8 8 2}That is, some expression {it:pcondstr} evaluates to a positive number 
(but not missing).  Commonly, the expression is just the name of 
a numeric variable. 

{p 4 4 2}Only one of {cmd:fcond()}, {cmd:cond()} and 
{cmd:pcond()} may be specified.     

{p 4 8 2}{cmd:end(}{it:endvar}{cmd:)} defines a new variable that is 1 at the
end of each spell and 0 otherwise. {cmd:_end} is tried as a variable name if
this option is not specified.
 
{p 4 8 2}{cmd:seq(}{it:seqvar}{cmd:)} defines a new variable that is the number 
of observations so far in the spell. {cmd:_seq} is tried as a variable name
if this option is not specified.

{p 4 8 2}{cmd:spell(}{it:spellvar}{cmd:)} defines a new variable that is the
number of spells so far. All observations in the first spell are tagged with 1,
all in the second with 2, and so on. {cmd:_spell} is tried as a variable name
if this option is not specified. With panel data, a separate count is kept
for each panel.

{p 4 8 2}{cmd:replace} indicates that any variables created by {cmd:tsspell} may
overwrite existing variables with the same names. 
 
 
{title:Examples}

{p 4 4 2}Who is in office: 

{p 12 16 2}{cmd:. tsspell party}

{p 4 4 2}Spells are distinct jobs (panel data): 

{p 12 16 2}{cmd:. tsspell job}

{p 4 4 2}Number of spells (panel data): 

{p 12 16 2}{cmd:. egen nspells = max(_spell), by(id)}

{p 4 4 2}Spells of consecutive values of {cmd:time}: 
    
{p 12 16 2}{cmd:. tsspell, f(L.time == .)}

{p 4 4 2}Rainfall spells: 

{p 12 16 2}{cmd:. tsspell, p(rain)}

{p 4 4 2}Spells in which rainfall was at least 10 mm every day: 
    
{p 12 16 2}{cmd:. tsspell, c(rain >= 10 & rain < .) end(hrend) seq(hrseq)}

{p 4 4 2}To get information on spell lengths (# observations):

{p 12 12 2}{cmd:. su hrseq if hrend}{break}
{cmd:. tab hrseq if hrend}

{p 4 4 2}Length of each spell in a new variable, non-panel and panel data:

{p 12 16 2}{cmd:. egen length = max(_seq), by(_spell)}
    
{p 12 16 2}{cmd:. egen length = max(_seq), by(id _spell)} 

{p 4 4 2}Duration (length in time) of each spell in a new variable, panel data: 
    
{p 12 12 2}{cmd:. egen tmax = max(time), by(id _spell)}{break} 
{cmd:. egen tmin = min(time), by(id _spell)}{break} 
{cmd:. gen duration = tmax - tmin} 

{p 4 4 2}Cumulative totals of {it:varname}: 
    
{p 12 16 2}{cmd:. bysort _spell (_seq) : gen total = sum(}{it:varname}{cmd:) if _seq} 

{p 4 4 2}Sums of {it:varname}: 

{p 12 16 2}{cmd:. egen total = sum(}{it:varname}{cmd:), by(_spell)} 

{p 4 4 2}Spells of growth, stability, decline: 

{p 12 12 2}{cmd:. gen sign = sign(D.}{it:varname}{cmd:)}{break} 
{cmd:. tsspell sign} 

{p 4 4 2}Define a recession as at least two quarters' decline in real GDP: 

{p 12 12 2}{cmd:. gen sign = sign(D.realGDP)}{break} 
{cmd:. tsspell sign}{break}  
{cmd:. egen qtrs = max(_seq), by(_spell)}{break} 
{cmd:. gen recession =  D.realGDP < 0 & qtrs >= 2}

{p 4 4 2}One observation per spell: 

{p 12 16 2}{cmd:.} ...{cmd: if _end}

{p 4 4 2}Suppose we have hourly barometric pressure data for many days and we
wish to generate a new variable containing the maximum fall within a day, from
a peak to a trough. This is not the same as the daily range. If the pressure is
falling, then the next hour's pressure is lower, thus defining a spell.
However, this definition would exclude the last value, for which the next
hour's pressure is the same or higher, so that needs to be added. Once the
spells are defined, the task can be passed to {cmd:egen}. However, note 
the perhaps surprising device (used temporarily if necessary) of declaring 
panels to be separate days. 

{p 12 12 2} 
{cmd:. tsset day hour}{break}
{cmd:. tsspell, cond(F.pressure < pressure)}{break}
{cmd:. replace _spell = L._spell if L._end == 1}{break}
{cmd:. egen max = max(pressure) if _spell, by(day _spell)}{break}
{cmd:. egen min = min(pressure) if _spell, by(day _spell)}{break}
{cmd:. egen range = max(max - min), by(day)} 

{p 4 4 2}A left-censored
spell starts at the first relevant observation (so it might have
started earlier, except that we have no data to determine that). A
right-censored spell ends at the last relevant observation (so it
might have ended later, except that we have no data to determine
that). Indicator variables: 

{p 12 12 2}{cmd:. by id : gen byte censoredleft = _seq == 1 & _n == 1}{break}
{cmd:. by id : gen byte censoredright = _end == 1 & _n == _N} 

{p 4 4 2}A liberal definition of a spell might allow inclusion of
periods that were no longer than some specified number of observations,
even though they do not fit the strict definition of that spell. For
example, two spells of heavy rain separated by a brief period might be
regarded, meteorologically, as part of the same spell. More generally,
we might consider including any part of the data that is not part of a
strictly identified spell, i.e. before the first spell, between two spells,
or after the last spell. One approach to this is a two-pass process. In
the second pass, periods omitted from spells on the first pass are
themselves treated as another kind of spell. Then once the length of
each gap has been calculated, the new definition is just the old
definition {cmd:or} the fact that gap lengths are acceptable: 

{p 12 12 2}{cmd:. tsspell, cond(_spell == 0) spell(_gap) seq(_gapseq) end(_gapend)}{break}
{cmd:. bysort id _gap: gen _gaplength = _N if _gap}{break}
{cmd:. tsset}{break}
{cmd:. tsspell, cond(_spell | _gaplength <= 2) spell(_spell2) seq(_seq2) end(_end2)}

{p 4 4 2}We want to number observations in periods between spells (for which 
{cmd:_seq} is 0) in sequences 1 up: 

{p 12 12 2}{cmd:. gen _seq2 = (_seq == 0) *  cond(L._end, 1, L._seq2 + 1)}

{p 4 4 2}We want to number observations in periods between spells (for which 
{cmd:_seq} is 0) in sequences up to -1: 

{p 12 12 2}{cmd:. tsspell , cond(_seq == 0) spell(_gap) seq(_gapseq) end(_gapend)}{break}
{cmd:. bysort id _gap (_gapseq) : gen _seq3 = (_gap > 0) * (_n - _N - 1)}{break}
{cmd:. tsset} 


{title:Author}

{p 4 4 2}Nicholas J. Cox, University of Durham, U.K.{break} 
n.j.cox@durham.ac.uk


{title:Acknowledgements} 

{p 4 4 2}Richard Goldstein was the co-author of an earlier program,
{cmd:spell}, which did not assume {cmd:tsset} data. Kit Baum, Jan Dehn, Stephen
Jenkins, Philippe Van Kerm and Fred Wolfe made very helpful direct or indirect
contributions. Chris Wallace posed an interesting problem. 


{title:References} 

{p 4 8 2}
Cox, N. J. 2007. Identifying spells. {it:Stata Journal} 7: 249{c -}265.
{browse "https://www.stata-journal.com/article.html?article=dm0029":https://www.stata-journal.com/article.html?article=dm0029} 

{p 4 8 2}
Cox, N. J. 2015. Spell boundaries. {it:Stata Journal} 15:  319{c -}323. 
{browse "https://www.stata-journal.com/article.html?article=dm0079":https://www.stata-journal.com/article.html?article=dm0079} 


{title:Also see}
 
{p 4 4 2}On-line: help for {help tsset}, {help varlist} (time series operators){p_end}
{p 4 4 2}Manual: {hi:[TS] tsset}, {hi:[U] 11.4.4 Time-series varlists}

