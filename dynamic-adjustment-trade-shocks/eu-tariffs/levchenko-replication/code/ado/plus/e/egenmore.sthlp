{smcl}
{* 21mar2006/1feb2007/21feb2007/24may2007/9jan2009/8feb2010/29feb2012/14feb2014/20nov2016}{...}
{hline}
help for {cmd:egenmore}
{hline}

{title:Extensions to generate (more extras)}

{p 8 17 2}{cmd:egen}
[{it:type}]
{it:newvar}
{cmd:=}
{it:fcn}{cmd:(}{it:arguments}{cmd:)}
[{cmd:if} {it:exp}]
[{cmd:in} {it:range}]
[{cmd:,} {it:options}]


{title:Description}

{p 4 4 2}
{help egen} creates {it:newvar} of the optionally specified storage type
equal to {it:fcn}{cmd:(}{it:arguments}{cmd:)}.  Depending on 
{it:fcn}{cmd:()}, {it:arguments} refers to an expression, a 
{help varlist}, a {help numlist}, or an empty string. The options are
similarly function dependent.


{title:Functions}

{p 4 4 2}
(The option {cmd:by(}{it:byvarlist}{cmd:)} means that computations are
performed separately for each group defined by {it:byvarlist}.)

{p 4 4 2}
Functions are grouped thematically as follows:{p_end}
{space 8}Grouping and graphing
{space 8}Strings, numbers and conversions
{space 8}Dates, times and time series
{space 8}Summaries and estimates
{space 8}First and last
{space 8}Random numbers
{space 8}Row operations


{title:Grouping and graphing} 

{p 4 8 2} 
{cmd:axis(}{it:varlist}{cmd:)}
[
{cmd:, gap}
{cmd:label(}{it:lblvarlist}{cmd:)}
{cmdab:miss:ing}
{cmdab:rev:erse}
]
resembles {help egen}'s {cmd:group()}, but is specifically designed for
constructing categorical axis variables for graphs, hence the name. It
creates a single variable taking on values 1, 2, ...  for the groups
formed by {it:varlist}.  {it:varlist} may contain string, numeric, or
both string and numeric variables.  The order of the groups is that of
the sort order of {it:varlist}.  {cmd:gap} overrides the default
numbering of 1 up by adding a gap of 1 whenever a variable changes.
{cmd:label()} specifies that labels are to be assigned based on the
value labels or values of {it:lblvarlist}; if not specified,
{it:lblvarlist} defaults to {it:varlist}.  {cmd:missing} indicates that
missing values in {it:varlist} (either numeric missing or {cmd:""}) are to be
treated like any other value when assigning groups, instead of missing
values being assigned to the group missing. {cmd:reverse} reverses
labelling so that groups that would have been assigned values of 1 ...
whatever are instead assigned values of whatever ... 1. (Stata 8
required.) 

{p 4 4 2}
To order groups of a categorical variable according
to their values of another variable, in preparation
for a graph or table: 

{p 4 8 2}{cmd:. egen meanmpg = mean(-mpg), by(rep78)}{p_end}
{p 4 8 2}{cmd:. egen Rep78 = axis(meanmpg rep78), label(rep78)}{p_end}
{p 4 8 2}{cmd:. tabstat mpg, by(Rep78) s(min mean max)} 

{p 4 4 2}Note: the function author considers this approach superseded by 
his {cmd:seqvar} and {cmd:labmask} (Cox 2008). 

{p 4 8 2}
{cmd:clsst(}{it:varname}{cmd:)}
{cmd:,}
{cmdab:v:alues(}{it:numlist}{cmd:)}
[
{cmdab:l:ater}
]
returns whichever of the {it:numlist} in {cmd:values()} is closest
(differs by least, disregarding sign) to the numeric variable
{it:varname}. {cmd:later} specifies that in the event of ties values
specified later in the list overwrite values specified earlier. If
varname is 15 then 10 and 20 specified by {cmd:values(10 20)} are
equally close. For any observation containing 15 the default is that 10
is reported, whereas with {cmd:later} 20 is reported. For a {it:numlist}
containing an increasing sequence, {cmd:later} implies choosing the
higher of two equally close values. (Stata 6 required.) 

{p 4 8 2}{cmd:. egen mpgclass = clsst(mpg), v(10(5)40)}

{p 4 8 2} 
{cmd:egroup(}{it:varlist}{cmd:)} is a extension of {help egen}'s 
{cmd:group()} function with the extra option
{cmd:label(}{it:lblvarlist}{cmd:)}, which will attach the original
values (or value labels if they exist) of {it:lblvarlist} as value
labels.  This option may not be combined with the {cmd:label} option.
(Stata 7 required; superseded by {cmd:axis()} above.) 

{p 4 8 2} 
{cmdab:group2(}{it:varlist}{cmd:)} is a generalisation of 
{help egen}'s {cmd:group()} with the extra option
{cmd:sort(}{it:egen_call}{cmd:)}.  Groups of {it:varlist} will have
values 1 upwards according to their values on the results of a specified
{it:egen_call}. For example, {cmd:group2(rep78) sort(mean(mpg))} will
produce a variable such that the group of {cmd:rep78} with the lowest
mean of {cmd:mpg} will have value 1, that with the second lowest mean
will have value 2, and so forth.  As with {cmd:group()}, the
{cmd:label} option will attach the original values of {it:varlist} (or
value labels if they exist) as value labels. The argument of
{cmd:sort()} must be a valid call to an {cmd:egen} function, official or
otherwise. (Stata 7 required; use of {cmd:egroup()} or 
{cmd:axis()} above is now considered better style.) 

{p 4 8 2}{cmd:mlabvpos(}{it:yvar xvar}{cmd:)} 
[
{cmd:,}
{cmd:log}
{cmdab:poly:nomial(}{it:#}{cmd:)}
{cmdab:mat:rix(}{it:5x5 matrix}{cmd:)}
]
automatically generates a variable giving clock positions of marker labels
given names of variables {it:yvar} and {it:xvar} defining the axes of a scatter
plot. Thus the command generates a variable to be used in the {help scatter}
option {cmd:mlabvpos()}.

{p 8 8 2}
The general idea is to pull marker labels away from the 
data region. So, marker labels in the lower left of the  
region are at clock positions 7 or 8, and those in the upper right 
are at clock-position 1 or 2, etc.
More precisely, considering the following rectangle as the data region,
then marker labels are placed as follows:

{col 9}{c TLC}{hline 14}{c TRC}
{col 9}{c |}11 12 12 12  1{c |}
{col 9}{c |}10 11 12  1  2{c |} 
{col 9}{c |} 9  9 12  3  3{c |} 
{col 9}{c |} 8  7  6  5  4{c |} 
{col 9}{c |} 7  6  6  6  5{c |} 
{col 9}{c BLC}{hline 14}{c BRC} 

{p 8 8 2}
Note that there is no attempt to prevent marker labels from overplotting, 
which is likely in any dataset with many observations. In such situations 
you might be better off simply randomizing clock positions with say 
{cmd:ceil(uniform() * 12)}. 

{p 8 8 2}
If {it:yvar} and {it:xvar} are highly correlated, than the clock-positions are generated
as follows (which is however the same general idea):

{col 9}{c TLC}{hline 14}{c TRC}
{col 9}{c |}      12  1  3{c |}
{col 9}{c |}   12 12  3  4{c |} 
{col 9}{c |}11 11 12  5  5{c |} 
{col 9}{c |}10  9  6  6   {c |} 
{col 9}{c |} 9  7  6      {c |} 
{col 9}{c BLC}{hline 14}{c BRC} 

{p 8 8 2}
To calculate the positions, the x axis is first categorized into  5 equal
intervals around the mean of {it:xvar}. Afterwards the residuals from regression of 
{it:yvar} on {it:xvar} are categorized into 5 equal intervals. Both categorized 
variables are then used to calculate the positions according to the first 
table above.  The rule can be changed with the option {cmd:matrix()}.

{p 8 8 2}
{cmd:log} indicates that residuals from regression are to be calculated 
using the logarithms of {it:xvar}. This might be useful if the scatter
shows a strong curvilinear relationship.

{p 8 8 2}
{cmd:polynomial(}{it:#}{cmd:)} indicates that residuals are to be calculated 
from a regression of {it:yvar} on a polynomial of {it:xvar}. For example, use 
{cmd:poly(2)} if the scatter shows a U-shaped relationship.

{p 8 8 2}
{cmd:matrix(}{it:#}{cmd:)} is used to change the general rule for the plot positions. 
The positions are specified by a 5 x 5 matrix, in which cell [1,1] gives the clock 
position of marker labels in the upper left part of the data region, and so forth.
(Stata 8.2 required.)

{p 4 8 2}{cmd:. egen clock = mlabvpos(mpg weight)}{p_end}
{p 4 8 2}{cmd:. scatter mpg weight, mlab(make) mlabvpos(clock)}{p_end}
{p 4 8 2}{cmd:. egen clock2 = mlabvpos(mpg weight), matrix(11 1 12 11 1 \\ 10 2 12 10 2 \\ 9 3 12 9 3 \\ 8 4 6 8 4 \\ 7 5 6 7 5)}{p_end}
{p 4 8 2}{cmd:. sc mpg weight, mlab(make) mlabvpos(clock2)}

{title:Strings, numbers and conversions} 

{p 4 8 2}
{cmd:base(}{it:varname}{cmd:)}
[
{cmd:,} 
{cmdab:b:ase(}{it:#}{cmd:)} 
] 
produces a string variable containing the digits of a base {it:#}
(default 2, possible values 2(1)9) representation of {it:varname}, which
must contain integers. Thus if {it:varname} contains values 0, 1, 2, 3,
4, and the default base is used, then the result will contain the
strings {cmd:"000"}, {cmd:"001"}, {cmd:"010"}, {cmd:"011"}, {cmd:"100"}.
If any integer values are negative, all string values will start with
{cmd:-} if negative and {cmd:+} otherwise. See also {cmd:decimal()}. The
examples show how to unpack this string into individual digits if
desired. (Stata 6 required.) 

{p 4 8 2}{cmd:. egen binary = base(code)}

{p 4 4 2}Suppose {cmd:binary} is {cmd:str5}. 
To get individual {cmd:str1} variables, 

{p 4 8 2}{cmd:. forval i = 1/5 {c -(}}{p_end}
{p 4 8 2}{cmd:. {space 8}gen str1 code`i' = substr(binary, `i',1)}{p_end}
{p 4 8 2}{cmd:. {c )-}} 

{p 4 4 2}and to get individual numeric variables, 

{p 4 8 2}{cmd:. forval i = 1/5 {c -(}}{p_end}
{p 4 8 2}{cmd:. {space 8}gen byte code`i' = real(substr(binary, `i', 1))}{p_end}
{p 4 8 2}{cmd:. {c )-}} 

{p 4 8 2}
{cmd:decimal(}{it:varlist}{cmd:)}
[
{cmd:,}
{cmdab:b:ase(}{it:#}{cmd:)} 
] 
treats the values of {it:varlist} as indicating digits in a base {it:#}
(default 2, possible values integers >=2) representation of a number and
produces the decimal equivalent. Thus if three variables are given with
values in a single observation of 1 1 0, and the default base is used,
the decimal result is 1 * 2^2 + 1 * 2^1 + 0 * 2^0 = 4 + 2 + 0 = 6.
Similarly if base 5 is used, the decimal equivalent of 2 3 4 is 2 * 5^2
+ 3 * 5^1 + 4 * 5^0 = 50 + 15 + 4 = 59. Note that the order of variables
in {it:varlist} is crucial. (Stata 7 required.)
   
{p 4 8 2}{cmd:. egen decimal = decimal(q1-q8)}

{p 4 8 2} 
{cmd:incss(}{it:strvarlist}{cmd:)}
{cmd:,}
{cmdab:s:ubstr(}{it:substring}{cmd:)} 
[
{cmdab:i:nsensitive}
] 
indicates occurrences of {it:substring} within any of the variables in a list
of string variables by 1 and other observations by 0. {cmd:insensitive}
makes comparison case-insensitive. (Stata 6 required; an alternative is
now just to use {help foreach}.) 

{p 4 8 2}{cmd:. egen buick = incss(make), sub(buick) i}

{p 4 8 2} 
{cmd:iso3166(}{it:varname}{cmd:)}
[{cmd:,}
{cmdab:o:rigin(}{cmd:codes}|{cmd:names}{cmd:)}
{cmdab:l:anguage(}{cmd:en}|{cmd:fr}{cmd:)}
{cmdab:v:erbose}
{cmdab:u:pdate}]
maps {it:varname} containing "official short country names" into
a new variable containing the ISO 3166-1-alpha-2 code elements
(e.g. DE for "Germany", GB for "United Kingdom" and HM for "Heard
Island and McDonald Islands") and vice versa. The official short
country names can be in English (default) or French. Correspondingly
the function produces country names from ISO 3166-1-alpha-2 codes in
English or French. (Version 9.2 required.) 

{p 8 8 2}{cmdab:o:rigin(}{cmd:codes}|{cmd:names}{cmd:)} declares the 
character of
the country variable that is already in the data. The default is
{cmd:names}, meaning that {it:varname} holds the "official short country
names". This information may be stored as a string variable or as a
numeric variable that is labeled accordingly. This default setting
produces ISO 3166-1-alpha-2 codes from the country names. If country
names should be produced from the two letter codes, use
{cmd:egen} {it:newvar} {cmd:= iso3166(}{it:varname}{cmd:), origin(codes)}.

{p 8 8 2}{cmdab:l:anguage(}{cmd:en}|{cmd:fr}{cmd:)} defines the language in
which the country names are stored, or should be
produced. {cmd:language(en)} is for English names (default);
{cmd:language(fr)} is for French names.

{p 8 8 2}{cmdab:v:erbose} For the mapping from country names to
ISO 3166-1-alpha2 codes the program expects official short
country names. It cannot handle unofficial country names such as
"Great Britain", "Taiwan" or "Russia". Such unofficial country names
result in the generation of missing values for the respective
countries. By default {cmd:iso3166()} only returns the number of
missing values it has produced. With {cmd:verbose} Stata also provides
the list of unofficial country names in {it:varname} and a clickable
link to the list of official country names. This is convenient
if one wants to correct the information stored in {it:varname} before
using {cmd:iso3166()}. For the transformation of ISO 3166-1-alpha2
codes into country names, {cmd:verbose} does something
equivalent.

{p 8 8 2}{cmdab:u:pdate} The ISO 3166-1-alpha2 codes are automaticaly
looked up in information provided by the ISO 3166 Maintenance
Agency of the International Organization for Standardization. The
information is automatically downloaded from the internet when the user
specifies {cmd:iso3166()} the first time, or
whenever {cmd:update} is specified. Note: Updating the matching list
regularly will guarantee that {cmd:iso3166()} always produces
up-to-date country names. However, updating the match list may also
produce missing values when running older do-files for data sets with
countries that no longer exist (for example, Yugoslavia). 

{p 8 8 2}Note the implications: This function will only work if your copy of
Stata can access the internet, at least for the first time it is called.
The results of the function might be not fully reproducible in the
future.

{p 4 8 2}
{cmd:msub(}{it:strvar}{cmd:)}
{cmd:,}
{cmdab:f:ind(}{it:findstr}{cmd:)} 
[ 
{cmdab:r:eplace(}{it:replacestr}{cmd:)} 
{cmd:n(}{it:#}{cmd:)}
{cmdab:w:ord}
]
replaces occurrences of the words of {it:findstr} by the words of
{it:replacestr} in the string variable {it:strvar}. The words of
{it:findstr} and of {it:replacestr} are separated by spaces or bound by
{cmd:" "}: thus {cmd:find(a b "c d")} includes three words, in turn
{cmd:"a"}, {cmd:"b"} and {cmd:"c d"}, and double quotation marks 
{cmd:" "} should be used to delimit any word including one or more spaces. The
number of words in {it:findstr} should equal that in {it:replacestr},
except that (1) an empty {it:replacestr} is taken to specify deletion;
(2) a single word in {it:replacestr} is taken to mean that each word of
{it:findstr} is to be replaced by that word. As quotation marks are used
for delimiting, literal quotation marks should be included in
compound double quotation marks, as in {cmd:`"""'}.  By default all occurrences
are changed. {cmd:n(}{it:#}{cmd:)} specifies that the first {it:#}
occurrences only should be changed. {cmd:word} specifies that words in
{it:findstr} are to be replaced only if they occur as separate words in
{it:strvar}. The substitutions of {cmd:msub()} are made in sequence. 
(Stata 6 required; {cmd:msub()} depends on the built-in functions 
{help subinstr()} and {help subinword()}.)  

{p 4 8 2}{cmd:. egen newstr = msub(strvar), f(A B C) r(1 2 3)}{p_end}
{p 4 4 2}(replaces {cmd:"A"} by {cmd:"1"}, {cmd:"B"} by {cmd:"2"}, {cmd:"C"} by {cmd:"3"})
    
{p 4 8 2}{cmd:. egen newstr = msub(strvar), f(A B C) r(1 2 3) n(1)}{p_end}
{p 4 4 2}(replaces {cmd:"A"} by {cmd:"1"}, {cmd:"B"} by {cmd:"2"}, {cmd:"C"} by {cmd:"3"}, first occurrence only)

{p 4 8 2}{cmd:. egen newstr = msub(strvar), f(A B C) r(1)}{p_end}
{p 4 4 2}(replaces {cmd:"A"} by {cmd:"1"}, {cmd:"B"} by {cmd:"1"}, {cmd:"C"} by {cmd:"1"})

{p 4 8 2}{cmd:. egen newstr = msub(strvar), f(A B C)}{p_end}
{p 4 4 2}(deletes {cmd:"A"}, {cmd:"B"}, {cmd:"C"}) 

{p 4 8 2}{cmd:. egen newstr = msub(strvar), f(" ")}{p_end}
{p 4 4 2}(deletes spaces)

{p 4 8 2}{cmd:. egen newstr = msub(strvar), f(`"""')}{p_end}
{p 4 4 2}(deletes quotation mark {cmd:"}) 

{p 4 8 2}{cmd:. egen newstr = msub(strvar) f(frog) w}{p_end}
{p 4 4 2}(deletes {cmd:"frog"} only if occurring as single word) 

{p 4 8 2} 
{cmd:noccur(}{it:strvar}{cmd:)}
{cmd:,}
{cmdab:s:tring(}{it:substr}{cmd:)} 
creates a variable containing the number of occurrences of the string
{it:substr}  in string variable {it:strvar}.  Note that occurrences must
be disjoint (non-overlapping): thus there are two occurrences of
{cmd:"aa"} within {cmd:"aaaaa"}. (Stata 7 required.) 

{p 4 8 2}
{cmd:nss(}{it:strvar}{cmd:)}
{cmd:,}
{cmdab:f:ind(}{it:substr}{cmd:)} 
[ 
{cmdab:i:nsensitive}
] 
returns the number 
of occurrences of {it:substr} within the string variable {it:strvar}. 
{cmd:insensitive} makes counting case-insensitive. (Stata 6 required.) 

{p 4 4 2}The inclusion of {cmd:noccur()} and {cmd:nss()}, two almost
identical functions, was an act of sheer inadvertence by the maintainer. 

{p 4 8 2} 
{cmd:ntos(}{it:numvar}{cmd:)}
{cmd:,}
{cmdab:f:rom(}{it:numlist}{cmd:)}
{cmdab:t:o(}{it:list of string values}{cmd:)} 
generates a string variable from a numeric variable {it:numvar}, mapping
each numeric value in {it:numlist} to the corresponding string value.
The number of elements in each list must be the same. String values
containing blanks should be delimited by doube quotation marks 
{cmd:" "}. Values not defined by the mapping are generated as missing. The type
of the string variable is determined automatically. (Stata 6 required.) 

{p 4 8 2}{cmd:. egen grade = ntos(Grade), from(1/5) to(Poor Fair Good "Very good" Excellent)}

{p 4 8 2}     
{cmd:nwords(}{it:strvar}{cmd:)} returns the number of words within the string
variable {it:strvar}. Words are separated by spaces, unless bound by double
quotation marks {cmd:" "}. (Stata 6 required; superseded by 
{help wordcount()}). 

{p 4 8 2}
{cmd:repeat()}
{cmd:,}
{cmdab:v:alues(}{it:value_list}{cmd:)}
[
{cmd:by(}{it:byvarlist}{cmd:)}
{cmdab:b:lock(}{it:#}{cmd:)}
]
produces a repeated sequence of {it:value_list}. The items of {it:value_list},
which may be a {it:numlist} or a set of string values, are assigned cyclically to
successive observations. The order of observations is determined (1) after
noting any {cmd:if} or {cmd:in} restrictions; (2) within groups specified by
{cmd:by()}, if issued; (3) by the current sort order. {cmd:block()} specifies
that values should be repeated in blocks of the specified size: the default is
1. The variable type is determined smartly, and need not be specified. (Stata 8
required.) 

{p 4 8 2}{cmd:. egen quarter = repeat(), v(1/4) block(3)}{p_end}
{p 4 8 2}{cmd:. egen months = repeat(), v(`c(Months)')}{p_end}
{p 4 8 2}{cmd:. egen levels = repeat(), v(10 50 200 500)}

{p 4 8 2} 
{cmd:sieve(}{it:strvar}{cmd:)} 
{cmd:,}
{c -(}
{cmd:keep(}{it:classes}{cmd:)}
{c |}
{cmd:char(}{it:chars}{cmd:)} 
{c |}
{cmd:omit(}{it:chars}{cmd:)} 
{c )-} 
selects characters from {it:strvar} according to a specified criterion and
generates a new string variable containing only those characters.  This may be
done in three ways. First, characters are classified using the keywords
{cmd:alphabetic} (any of {cmd:a-z} or {cmd:A-Z}), {cmd:numeric} (any of
{cmd:0-9}), {cmd:space} or {cmd:other}. {cmd:keep()} specifies one or more of
those classes: keywords may be abbreviated by as little as one letter.  Thus
{cmd:keep(a n)} selects alphabetic and numeric characters and omits spaces and
other characters. Note that keywords must be separated by spaces.
Alternatively, {cmd:char()} specifies each character to be selected or
{cmd:omit()} specifies each character to be omitted. Thus
{cmd:char(0123456789.)} selects numeric characters and the stop (presumably as
decimal point); {cmd:omit(" ")} strips spaces and {cmd:omit(`"""')} strips
double quotation marks.  (Stata 7 required.) 

{p 4 8 2}
{cmd:ston(}{it:strvar}{cmd:)}
{cmd:,}
{cmdab:f:rom(}{it:list of string values}{cmd:)}
{cmdab:t:o(}{it:numlist}{cmd:)}  
generates a numeric variable from a string variable {it:strvar}, mapping each
string value to the corresponding numeric value in {it:numlist}. The number of
elements in each list must be the same. String values containing blanks should
be delimited by {cmd:" "}. Values not defined by the mapping are generated as
missing. (Stata 6 required.)  

{p 4 8 2}{cmd:. egen Grade = ston(grade), to(1/5) from(Poor Fair Good "Very good" Excellent)}

{p 4 8 2} 
{cmd:truncdig(}{it:varname}{cmd:), dig(}{it:#}{cmd:)}
truncates a numeric variable at the specified number of decimal digits.
It applies the {cmd:trunc()} or {cmd:int()} function to the variable
times 10^{cmd:dig}, then divides by 10^{cmd:dig}. The {cmd:dig()}
argument may be positive, zero or negative. If negative, it creates a
binned variable: for instance, with income in dollars, 
{cmd:egen inck = truncdig(income), dig(-3)} creates a measure of income
expressed in whole thousands of dollars. (Stata 12 required.) 

{p 4 8 2}
{cmd:wordof(}{it:strvar}{cmd:)}
{cmd:,}
{cmdab:w:ord(}{it:#}{cmd:)} returns the {it:#}th word of string variable
{it:strvar}. {cmd:word(1)} is the first word, {cmd:word(2)} the second word,
{cmd:word(-1)} the last word, and so forth. Words are separated by spaces,
unless bound by quotation marks {cmd:" "}. (Stata 6 required; superseded
by {help word()}.) 


{title:Dates, times and time series} 

{p 4 8 2} 
{cmd:bom(}{it:m y}{cmd:)}
[ 
{cmd:,}
{cmdab:l:ag(}{it:lag}{cmd:)}
{cmdab:f:ormat(}{it:format}{cmd:)}
{cmdab:w:ork} 
] 
creates an elapsed date variable containing the date of the beginning of
month {it:m} and year {it:y}. {it:m} can be a variable containing
integers between 1 and 12 inclusive or a single integer in that range.
{it:y} can be a variable containing integers within the range covered by
elapsed dates or a single integer within that range. Optionally
{cmd:lag()} specifies a lag: the beginning of the month will be given
for {cmd:lag} months before the current date. {cmd:lag(1)} refers to the
previous month, {cmd:lag(3)} to 3 months ago and {cmd:lag(-3)} to 3
months hence. The {cmd:lag} may also be specified by a variable
containing integers. Optionally a format, usually but not necessarily a
date format, can be specified.  {cmd:work} specifies that the first day
must also be one of Monday to Friday. (Stata 6 required.) 

{p 4 8 2}{cmd:. egen bom = bom(month year), f(%dd_m_y)}{p_end}

{p 4 8 2} 
{cmd:bomd(}{it:datevar}{cmd:)}
[
{cmd:,}
{cmdab:l:ag}{cmd:(}{it:lag}{cmd:)}
{cmdab:f:ormat}{cmd:(}{it:format}{cmd:)}
{cmdab:w:ork}
] 
creates an elapsed date variable containing the date of the beginning of
the month containing the date in an elapsed date variable {it:datevar}.
Optionally {cmd:lag()} specifies a lag: the beginning of the month will
be given for {cmd:lag} months before the current date. {cmd:lag(1)}
refers to the previous month, {cmd:lag(3)} to 3 months ago and
{cmd:lag(-3)} to 3 months hence. The {cmd:lag} may also be specified by
a variable containing integers. Optionally a format, usually but not
necessarily a date format, can be specified.  {cmd:work} specifies that
the first day must also be one of Monday to Friday. (Stata 6 required.) 

{p 4 8 2}{cmd:. egen bomd = bomd(date), f(%dd_m_y)}

{p 4 4 2} 
Note that {cmd:work} knows nothing about holidays or any special days. 

{p 4 8 2} 
{cmd:dayofyear(}{it:daily_date_variable}{cmd:)} 
[
{cmd:,}
{cmdab:m:onth(}{it:#}{cmd:)} 
{cmdab:d:ay(}{it:#}{cmd:)} 
]
generates the day of the year, counting from the 
start of the year, from a daily date variable. The 
start of the year is 1 January by default: {cmd:month()} 
and/or {cmd:day()} may be used to specify an alternative. 
This function thus is a generalisation of the date 
function {help doy()}. 
(Stata 8 required.) 

{p 4 8 2}{cmd:. egen dayofyear = dayofyear(date), m(10)} 

{p 4 8 2} 
{cmd:dhms(}{it:d h m s}{cmd:)} 
[
{cmd:,}
{cmdab:f:ormat(}{it:format}{cmd:)}
]
creates a date variable from Stata date variable or date {it:d} with a
fractional part reflecting the number of hours, minutes and seconds past
midnight.  {it:h} can be a variable containing integers between 0 and 23
inclusive or a single integer in that range. {it:m} and {it:s} can be
variables containing integers between 0 and 59 or single integer(s) in
that range.  Optionally a format, usually but not necessarily a date
format, can be specified. The resulting variable, which is by default
stored as a double, may be used in date and time arithmetic in which the
time of day is taken into account. (Stata 6 required.) 

{p 4 8 2} 
{cmd:elap(}{it:time}{cmd:)}
[ 
{cmd:,}
{cmdab:f:ormat(}{it:format}{cmd:)}  
] 
creates a string variable which contains the number of days, hours,
minutes and seconds associated with an integer variable containing a
number of elapsed seconds. Such a variable might be the result of
date/time arithmetic, where a time interval between two timestamps has
been expressed in terms of elapsed seconds. Leading zeroes are included
in the hours, minutes, and seconds fields. Optionally, a format can be
specified. (Stata 6 required.) 

{p 4 8 2} 
{cmd:elap2(}{it:time1 time2}{cmd:)} 
[ 
{cmd:,}
{cmdab:f:ormat(}{it:format}{cmd:)} 
] 
creates a string variable which contains the number of days, hours,
minutes and seconds associated with a pair of time values, expressed as
fractional days, where {it:time1} is no greater than {it:time2}.  Such
time values may be generated by function {cmd:dhms()}. {cmd:elap2()}
expresses the interval between these time values in readable form.
Leading zeroes are included in the hours, minutes, and seconds fields.
Optionally, a format can be specified. (Stata 6 required.) 

{p 4 8 2}
{cmd:eom(}{it:m y}{cmd:)} 
[
{cmd:,}
{cmdab:l:ag(}{it:lag}{cmd:)}
{cmdab:f:ormat(}{it:format}{cmd:)}
{cmdab:w:ork}
] 
creates an elapsed date variable containing the date of the end of month
{it:m} and year {it:y}. {it:m} can be a variable containing integers between 1 and 12
inclusive or a single integer in that range. {it:y} can be a variable
containing integers within the range covered by elapsed dates or a
single integer within that range. Optionally {cmd:lag()} specifies a
lag: the end of the month will be given for {cmd:lag} months before the
current date. {cmd:lag(1)} refers to the previous month, {cmd:lag(3)} to
3 months ago and {cmd:lag(-3)} to 3 months hence. The {cmd:lag} may also
be specified by a variable containing integers. Optionally a format,
usually but not necessarily a date format, can be specified.  {cmd:work}
specifies that the last day must also be one of Monday to Friday. 
(Stata 6 required.) 

{p 4 8 2}{cmd:. egen eom = eom(month year), f(%dd_m_y)}

{p 4 8 2}
{cmd:eomd(}{it:datevar}{cmd:)} 
[ 
{cmd:,}
{cmdab:l:ag(}{it:lag}{cmd:)}
{cmdab:f:ormat(}{it:format}{cmd:)}
{cmdab:w:ork}
] 
creates an elapsed date variable containing the date of the end of the
month containing the date in an elapsed date variable {it:datevar}.
Optionally {cmd:lag()} specifies a lag: the end of the month will be
given for {cmd:lag} months before the current date. {cmd:lag(1)} refers
to the previous month, {cmd:lag(3)} to 3 months ago and {cmd:lag(-3)} to
3 months hence. The {cmd:lag} may also be specified by a variable
containing integers. Optionally a format, usually but not necessarily a
date format, can be specified.  {cmd:work} specifies that the last day
must also be one of Monday to Friday. (Stata 6 required.) 

{p 4 4 2}Note that {cmd:work} knows nothing about holidays
or any special days.

{p 4 8 2}{cmd:. egen eom = eomd(date), f(%dd_m_y)}{p_end}
{p 4 8 2}{cmd:. egen eopm = eomd(date), f(%dd_m_y) lag(1)} 

{p 4 8 2} 
{cmd:ewma(}{it:timeseriesvar}{cmd:)}
{cmd:,}
{cmd:a(}{it:#}{cmd:)} 
calculates the exponentially weighted moving average, which is 

{p 8 8 2}
{it:ewma} = {it:timeseriesvar} for the first observation 

{p 13 8 2}
= {cmd:a * }{it:timeseriesvar} + {cmd:(1 - a) * L.}{it:ewma} otherwise 

{p 8 8 2} 
The data must have been declared time series data by {help tsset}.
Calculations start afresh after any gap with missing values.
(Stata 6 required; superseded by {help tssmooth}.) 

{p 4 8 2} 
{cmd:filter(}{it:timeseriesvar}{cmd:) ,}
{cmdab:l:ags(}{it:numlist}{cmd:)} 
[
{cmdab:c:oef(}{it:numlist}{cmd:)} 
{c -(}
{cmdab:n:ormalise}
{c |}
{cmdab:n:ormalize}
{c )-} 
] 
calculates the linear filter which is the sum of terms   

{p 8 8 2} 
{it:coef_i} {cmd:* L}{it:i.timeseriesvar}   or   {it:coef_i} {cmd:* F}{it:i.timeseriesvar}

{p 8 8 2} 
{cmd:coef()} defaults to a vector the same length as {cmd:lags()} with each 
element 1. 

{p 8 8 2}
{cmd:filter(y), l(0/3) c(0.4(0.1)0.1)} calculates 

{p 8 8 2}
{cmd:0.4 * y + 0.3 * L1.y + 0.2 * L2.y + 0.1 * L3.y} 

{p 8 8 2}
{cmd:filter(y), l(0/3)} calculates 

{p 8 8 2} 
{cmd:1 * y + 1 * L1.y + 1 * L2.y + 1 * L3.y} or {cmd:y + L1.y + L2.y + L3.y} 

{p 8 8 2}
Leads are specified as negative lags.  {cmd:normalise} (or {cmd:normalize}, 
according to taste) specifies that coefficients are to be divided by 
their sum so that they add to 1 and thus specify a weighted mean. 

{p 8 8 2}
{cmd:filter(y), l(-2/2) c(1 4 6 4 1) n} calculates 

{p 8 8 2}
{cmd:(1/16) * F2.y + (4/16) * F1.y + (6/16) * y} 
{cmd:+ (4/16) * L1.y + (1/16) * L2.y} 

{p 8 8 2}
The data must have been declared time series data by {help tsset}. 
Note that this may include panel data, which are automatically 
filtered separately within each panel. 

{p 8 8 2}
The order of terms in {cmd:coef()} is taken to be the same as that in 
{cmd:lags}. (Stata 8 required; see also {help tssmooth}.) 

{p 4 8 2}{cmd:. egen f2y = filter(y), l(-1/1) c(0.25 0.5 0.25)}{p_end}
{p 4 8 2}{cmd:. egen f2y = filter(y), l(-1/1) c(1 2 1) n} 
 
{p 4 8 2}
{cmd:filter7(}{it:timeseriesvar}{cmd:) ,}
{cmdab:l:ags(}{it:numlist}{cmd:)}
{cmdab:c:oef(}{it:numlist}{cmd:)} 
[
{c -(}  
{cmdab:n:ormalise}
{c |}
{cmdab:n:ormalize} 
{c )-} 
] 
calculates the linear filter which is the sum of terms   

{p 8 8 2}
{it:coef_i} {cmd:* L}{it:i.timeseriesvar}   or   {it:coef_i }{cmd:* F}{it:i.timeseriesvar} 

{p 8 8 2} 
{cmd:filter7(y), l(0/3) c(0.4(0.1)0.1)} calculates 

{p 8 8 2}
{cmd:0.4 * y + 0.3 * L1.y + 0.2 * L2.y + 0.1 * L3.y} 

{p 8 8 2} 
Leads are specified as negative lags.  {cmd:normalise} (or {cmd:normalize}, 
according to taste) specifies that coefficients are to be divided by 
their sum so that they add to 1 and thus specify a weighted mean. 
    
{p 8 8 2}     
{cmd:filter7(y), l(-2/2) c(1 4 6 4 1) n} calculates 

{p 8 8 2}
{cmd:(1/16) * F2.y + (4/16) * F1.y + (6/16) * y}
{cmd:+ (4/16) * L1.y + (1/16) * L2.y}
       
{p 8 8 2}
The data must have been declared time series data by {help tsset}. 
Note that this may include panel data, which are automatically 
filtered separately within each panel. 

{p 8 8 2} 
The order of terms in {cmd:coef()} is taken to be the same as that in 
{cmd:lags()}. (Stata 7 required; see also {help tssmooth}.)

{p 4 8 2} 
{cmd:foy(}{it:daily_date_variable}{cmd:)} 
[
{cmd:,}
{cmdab:m:onth(}{it:#}{cmd:)} 
{cmdab:d:ay(}{it:#}{cmd:)} 
]
generates the fraction of the year elapsed since the 
start of the year from a daily date variable. The 
start of the year is 1 January by default: {cmd:month()} 
and/or {cmd:day()} may be used to specify an alternative. 
If {it:daily_date_variable} 
is all integers, then the result is {bind:(day of year - 0.5)} / 
number of days in year. If {it:daily_date_variable} 
contains non-integers, then the result is 
{bind:(day of year - 1)} / number of days in year. 
(Stata 8 required.) 

{p 4 8 2}{cmd:. egen frac = foy(date), m(10)} 

{p 4 8 2}
{cmd:hmm(}{it:timevar}{cmd:)}
[
{cmd:,} 
{cmdab:r:ound(}{it:#}{cmd:)} 
{cmdab:t:rim}
]
generates a string variable showing {it:timevar}, interpreted as
indicating time in minutes, represented as hours and minutes in the form
{cmd:"}[...{it:h}]{it:h}{cmd::}{it:mm}{cmd:"}.  For example, times of
{cmd:9}, {cmd:90}, {cmd:900} and {cmd:9000} minutes would be represented
as {cmd:"0:09"},{cmd:"1:30"}, {cmd:"15:00"} and {cmd:"150:00"}. The
option {cmd:round(}{it:#}{cmd:)} rounds the result: {cmd:round(1)}
rounds the time to the nearest minute. The option {cmd:trim} trims the
result of leading zeros and colons, except that an isolated {cmd:0} is
not trimmed. With {cmd:trim} {cmd:"0:09"} is trimmed to {cmd:"9"} and
{cmd:"0:00"} is trimmed to {cmd:"0"}.

{p 8 8 2}
{cmd:hmm()} serves equally well for representing times in seconds in
minutes and seconds in the form
{cmd:"}[...{it:m}]{it:m}{cmd::}{it:ss}{cmd:"}. (Stata 6 required.) 

{p 4 8 2} 
{cmd:hmmss(}{it:timevar}{cmd:)} 
[
{cmd:,} 
{cmdab:r:ound(}{it:#}{cmd:)} 
{cmdab:t:rim}
]
generates a string variable showing {it:timevar}, interpreted as
indicating time in seconds, represented as hours, minutes and seconds in
the form {cmd:"}[...{it:h}{cmd::}]{it:mm}{cmd::}{it:ss}{cmd:"}. For
example, times of {cmd:9}, {cmd:90}, {cmd:900} and {cmd:9000} seconds
would be represented as {cmd:"00:09"},{cmd:"01:30"}, {cmd:"15:00"} and
{cmd:"2:30:00"}. The option {cmd:round(}{it:#}{cmd:)} rounds the result:
{cmd:round(1)} rounds the time to the nearest second. The option
{cmd:trim} trims the result of leading zeros and colons, except that an
isolated {cmd:0} is not trimmed. With {cmd:trim} {cmd:"00:09"} is
trimmed to {cmd:"9"} and {cmd:"00:00"} is trimmed to {cmd:"0"}. (Stata 6 
required.) 

{p 4 8 2}
{cmd:hms(}{it:h m s}{cmd:)} 
[ 
{cmd:,}
{cmdab:f:ormat(}{it:format}{cmd:)}  
] 
creates an elapsed time variable containing the number of seconds past
midnight. {it:h} can be a variable containing integers between 0 and 23
inclusive or a single integer in that range. {it:m} and {it:s} can be variables
containing integers between 0 and 59 or single integer(s) in that range.
Optionally a format can be specified. (Stata 6 required.) 

{p 4 8 2} 
{cmd:minutes(}{it:strvar}{cmd:)} 
[ 
{cmd:,}
{cmd:maxhour(}{it:#}{cmd:)} 
] 
returns time in minutes given a string variable {it:strvar} containing a
time in hours and minutes in the form
{cmd:"}[..{it:h}]{it:hh}:{it:mm}{cmd:"}.  In particular, minutes are
given as two digits between 00 and 59 and hours by default are given as
two digits between 00 and 23. The {cmd:maxhour()} option may be used to
change the (unreachable) limit: its default is 24. Note that, strange
though it may seem, this function rather than {cmd:seconds()} is
appropriate for converting times in the form
{cmd:"}{it:mm}:{it:ss}{cmd:"} to seconds.  The maximum number of minutes
acceptable may need then to be specified by {cmd:maxhour()} [sic].
(Stata 8 required.) 

{p 4 8 2} 
{cmd:ncyear(}{it:datevar}{cmd:)}
{cmd:,}
{cmdab:m:onth(}{it:#}{cmd:)} 
[ 
{cmdab:d:ay(}{it:#}{cmd:)} 
] 
returns an integer variable labelled with labels such as {cmd:"1952/53"}
for non-calendar years starting on the specified month and day.  The day
defaults to 1.  {it:datevar} is treated as indicating elapsed dates. For
more on dates, see help on {help dates}. (Stata 6 required.)  

{p 4 8 2}{cmd:. egen wtryear = ncyear(date), m(10)}{p_end}
{p 4 4 2}(years starting on 1 October)
    
{p 4 8 2}{cmd:. egen wwgyear = ncyear(date), m(1) d(21)}{p_end}
{p 4 4 2}(years starting on 21 January) 

{p 4 8 2}
{cmd:record(}{it:exp}{cmd:)} 
[
{cmd:,}
{cmd:by(}{it:byvarlist}{cmd:)}
{cmd:min}
{cmd:order(}{it:varlist}{cmd:)} 
] 
produces the maximum (with {cmd:min} the minimum) value observed "to date" of
the specified {it:exp}.  Thus {cmd:record(wage), by(id) order(year)} produces
the maximum wage so far in a worker's career, calculations being separate for
each {cmd:id} and records being determined within each {cmd:id} in {cmd:year}
order. Although explanation and example here refer to dates, nothing in
{cmd:record()} restricts its use to data ordered in time. If not otherwise
specified with {cmd:by()} and/or {cmd:order()}, records are determined with
respect to the current order of observations. No special action is required for
missing values, as internally {cmd:record()} uses either the {cmd:max()} or the
{cmd:min()} function, both of which return results of missing only if all
values are missing. (Stata 6 required.) 

{p 4 8 2}{cmd:. egen hiwage = record(exp(lwage)), by(id) order(year)}{p_end}
{p 4 8 2}{cmd:. egen lowage = record(exp(lwage)), by(id) order(year) min}
 
{p 4 8 2}
{cmd:seconds(}{it:strvar}{cmd:)} 
[ 
{cmd:,}
{cmd:maxhour(}{it:#}{cmd:)} 
] 
returns time in seconds given a string variable containing a time in hours,
minutes and seconds in the form
{cmd:"}[..{it:h}]{it:hh}{cmd::}{it:mm}{cmd::}{it:ss}{cmd:"}.  
In particular, minutes and seconds are each given as two digits between
00 and 59 and hours by default are given as two digits between 00 and
23. The {cmd:maxhour()} option may be used to change the (unreachable)
limit: its default is 24.         (Stata 8 required.)  

{p 4 8 2} 
{cmd:tod(}{it:time}{cmd:)} 
[ 
{cmd:,}
{cmdab:f:ormat(}{it:format}{cmd:)} 
] 
creates a string variable which contains the number of hours, minutes and
seconds associated with an integer in the range 0 to 86399, one less than the
number of seconds in a day. Such a variable is produced by {cmd:hms()}, which
see above. Leading zeroes are included in the hours, minutes, and seconds
fields. Colons are used as separators.  Optionally a format can be specified.
(Stata 6 required.) 
  

{title:Summaries and estimates} 

{p 4 8 2}
{cmd:adjl(}{it:varname}{cmd:)} 
[
{cmd:,} 
{cmd:by(}{it:byvarlist}{cmd:)} 
{cmdab:fact:or(}{it:#}{cmd:)} 
]
calculates adjacent lower values. These are the smallest values within 
{cmd:factor()} times the interquartile range of the lower quartile. 
By default {cmd:factor()} is 1.5, defining the default lower value 
of a so-called whisker on a Stata box plot. (Stata 8 required.) 

{p 4 8 2}
{cmd:adju(}{it:varname}{cmd:)} 
[
{cmd:,} 
{cmd:by(}{it:byvarlist}{cmd:)} 
{cmdab:fact:or(}{it:#}{cmd:)} 
]
calculates adjacent upper values. These are the largest values within 
{cmd:factor()} times the interquartile range of the upper quartile. 
By default {cmd:factor()} is 1.5, defining the default upper value 
of a so-called whisker on a Stata box plot. (Stata 8 required.) 

{p 4 8 2}{cmd:. egen adjl = adjl(mpg), by(foreign)}{p_end}
{p 4 8 2}{cmd:. egen adju = adju(mpg), by(foreign)}

{p 4 8 2} 
{cmd:corr(}{it:varname1 varname2}{cmd:)}
[
{cmd:,}
{cmdab:c:ovariance}
{cmdab:s:pearman}
{cmd:taua}
{cmd:taub} 
{cmd:by(}{it:byvarlist}{cmd:)} 
] 
returns the correlation of {it:varname1} with {it:varname2}.  By
default, this returns the Pearson correlation coefficient.  {cmd:covariance}
indicates that covariances should be calculated; {cmd:spearman}
indicates that Spearman's rank correlation coefficient should be
calculated; {cmd:taua} and {cmd:taub} return Kendall's tau-A and tau-B,
respectively. (Stata 8 required.)

{p 4 8 2}
{cmd:d2(}{it:exp}{cmd:)}
[
{cmd:,}
{cmdab:w:eights(}{it:exp}{cmd:)}
{cmd:by(}{it:byvarlist}{cmd:)}
]
returns the mean absolute deviation from the median (within varlist) of {it:exp}, 
allowing specification of weights. The function creates a constant (within {it:byvarlist})
containing the mean of abs({it:exp} - median({it:exp})). (Stata 10.1 required.) 

{p 4 8 2}
{cmd:density(}{it:varname}{cmd:)} 
[
{cmd:,} 
{cmdab:w:idth(}{it:#}{cmd:)}
{cmdab:st:art(}{it:#}{cmd:)}
{cmdab:freq:uency}
{cmd:percent}
{cmdab:frac:tion}
{cmd:by(}{it:byvarlist}{cmd:)} 
] 
calculates the density (or optionally the {cmd:frequency},
{cmd:fraction} or {cmd:percent}) of values in bins of width
{cmd:width()} (default 1) starting at {cmd:start()} (default minimum of
the data). Note that each value produced will be identical for all
observations in the same bin. Commonly for further use it will be
desired to select one value from each bin, say by using {help egen}'s
{cmd:tag()} function. (Stata 8 required.) 

{p 4 8 2} 
{cmd:gmean(}{it:exp}{cmd:)} 
[ 
{cmd:,}
{cmd:by(}{it:byvarlist}{cmd:)} 
] 
returns the geometric mean of {it:exp}. (Stata 6 required.) 

{p 4 8 2}{cmd:. egen gmean = gmean(mpg), by(rep78)} 

{p 4 8 2} 
{cmd:hmean(}{it:exp}{cmd:)} 
[ 
{cmd:, by(}{it:byvarlist}{cmd:)}
] 
returns the harmonic mean of {it:exp}. (Stata 6 required.) 

{p 4 8 2}{cmd:. egen hmean = hmean(mpg), by(rep78)}

{p 4 8 2}
{cmd:nmiss(}{it:exp}{cmd:)} 
[ 
{cmd:,}
{cmd:by(}{it:byvarlist}{cmd:)} 
] 
returns the number of missing values in {it:exp}. (Stata 6 required.) 
Remark: Why this was written is a mystery. The one-line command 
{cmd:egen nmiss = sum(missing(}{it:exp}{cmd:)} 
(in Stata 9 {cmd:egen nmiss = total(missing(}{it:exp}{cmd:)}) 
shows that it is unnecessary. 

{p 4 8 2}{cmd:. egen nmiss = nmiss(rep78), by(foreign)}

{p 4 8 2} 
{cmd:nvals(}{it:varname}{cmd:)}
[ 
{cmd:,}
{cmd:by(}{it:byvarlist}{cmd:)}
{cmdab:miss:ing}
] 
returns the number of distinct values in {it:varname}. Missing values
are ignored unless {cmd:missing} is specified. 
Remark: Much can be done by using {help egen} function {cmd:tag()} 
and then summing values as desired. See also {cmd:distinct} (Cox and Longton 2008). 
(Stata 6 required.)

{p 4 8 2} 
{cmd:outside(}{it:varname}{cmd:)} 
[
{cmd:,} 
{cmd:by(}{it:byvarlist}{cmd:)} 
{cmdab:fact:or(}{it:#}{cmd:)} 
]
calculates outside values. These are any values more than {cmd:factor()}
times the interquartile range from the nearer quartile, that is above
the upper quartile or below the lower quartile.  By default
{cmd:factor()} is 1.5, defining the default outside values, those
plotted separately, on a Stata box plot.  
Values not outside are returned as missing. 
(Stata 8 required.) 

{p 4 8 2}
{cmd:ridit(}{it:varname}{cmd:)} 
[ 
{cmd:,}
{cmd:by(}{it:byvarlist}{cmd:)}
{cmdab:miss:ing}
{cmdab:perc:ent}
{cmdab:rev:erse}
] 
calculates the ridit for {it:varname}, which is
    
{space 8}(1/2) count at this value + SUM counts in values below 
{space 8}{hline 54}
{space 23}SUM counts of all values               

{p 8 8 2} 
With terminology from Tukey (1977, pp.496-497), this could be called a 
`split fraction below'. The name `ridit' was used by Bross (1958): 
see also Fleiss (1981, pp.150-7) or Flora (1988). The numerator is a 
`split count'.

{p 8 8 2}
{cmd:missing} specifies that observations for which values of {it:byvarlist}
are missing will be included in calculations if {cmd:by()} is specified. The
default is to exclude them. {cmd:percent} scales the numbers to percents by
multiplying by 100.  {cmd:reverse} specifies the use of reverse cumulative
probabilities (1 - fraction above). (Stata 6 required.) 

{p 4 8 2}
{cmd:semean(}{it:exp}{cmd:)} 
[ 
{cmd:,} 
{cmd:by(}{it:byvarlist}{cmd:)} 
] 
calculates the standard error of the mean of {it:exp}. (Stata 6
required.) 

{p 4 8 2} 
{cmd:sumoth(}{it:exp}{cmd:)} 
[
{cmd:,} 
{cmd:by(}{it:byvarlist}{cmd:)} 
] 
returns the sum of the other values of {it:exp} in the same group. If
{cmd:by()} is specified, distinct combinations of {it:byvarlist} define groups;
otherwise all observations define one group. (Stata 6 required.) 

{p 4 8 2} 
{cmd:var(}{it:exp}{cmd:)}
[
{cmd:,} 
{cmd:by(}{it:byvarlist}{cmd:)} 
] 
creates a constant (within {it:byvarlist}) containing the variance of {it:exp}.
Note also the {help egen} function {cmd:sd()}. (Stata 6 required.) 

{p 4 8 2}
{cmd:wpctile(}{it:varname}{cmd:)}
[
{cmd:,}
{cmd:p(}{it:#}{cmd:)}
{cmdab:w:eights(}{it:varname}{cmd:)}
{cmdab:alt:def}
{cmd:by(}{it:byvarlist}{cmd:)}
]
is a hack on official Stata's {cmd:egen} function {cmd:pctile()}
allowing specification of weights in the calculation of percentiles. By
default, the function creates a constant (within {it:byvarlist})
containing the {it:#}th percentile of {it:varname}. If {cmd:p()} is not
specified, 50 is assumed, meaning medians. {cmd:weights()} requests
weighted calculation of percentiles. {cmd:altdef} uses an alternative
formula for calculating percentiles, which is not applicable with
weights present. {cmd:by()} requests calculation by groups.  You may
also use the {cmd:by:} construct. (Stata 8.2 required.)

{p 4 8 2} 
{cmd:wtfreq(}{it:exp}{cmd:)} 
[ 
{cmd:,} 
{cmd:by(}{it:byvarlist}{cmd:)}
] 
creates a constant (within {it:byvarlist}) 
containing the weighted frequency using {it:exp} as weights. (Such 
frequencies sum to {cmd:_N}.) (Stata 6 required.) 

{p 4 8 2}
{cmd:xtile(}{it:varname}{cmd:)}
[
{cmd:,}
{cmdab:p:ercentiles(}{it:numlist}{cmd:)}
{cmdab:n:quantiles(}{it:#}{cmd:)}
{cmdab:w:eights(}{it:varname}{cmd:)}
{cmdab:alt:def}
{cmd:by(}{it:byvarlist}{cmd:)}
]
categorizes {it:varname} by specific percentiles. The function works
like {help xtile}. By default {it:varname} is dichotomized at the
median. {cmd:percentiles()} requests percentiles corresponding to
{it:numlist}: for example, {cmd:p(25(25)75)} is used to create a
variable according to quartiles. Alternatively you also may have
specified {cmd:n(4)}: to create a variable according to quartiles.
{cmd:weights()} requests weighted calculation of percentiles.
{cmd:altdef} uses an alternative formula for calculating percentiles.
See {help xtile}. {cmd:by()} requests calculation by groups.  You may
also use the {cmd:by:} construct. (Stata 8.2 required.) 

{p 4 8 2}{cmd:. egen mpg4 = xtile(mpg), by(foreign) p(25(25)75)}{p_end}
{p 4 8 2}{cmd:. egen mpg10 = xtile(mpg), by(foreign) nq(10)}


{title:First and last} 

{p 4 8 2} 
{cmd:first(}{it:varname}{cmd:)} 
[ 
{cmd:,}
{cmd:by(}{it:byvarlist}{cmd:)} 
] 
returns the first non-missing value of {it:varname}. `First' depends on the
existing order of observations. {it:varname} may be numeric or string.
(Stata 6 required.) 

{p 4 8 2}
{cmd:ifirst(}{it:numvar}{cmd:)}
{cmd:,}
{cmdab:v:alue(}{it:#}{cmd:)} 
[ 
{c -(}  
{cmdab:be:fore}
{c |}
{cmdab:a:fter}
{c )-} 
{cmd:by(}{it:byvarlist}{cmd:)} 
]     
indicates the first occurrence of integer {it:#} within {it:numvar}
by 1 and other observations by 0. 
    
{p 8 8 2}     
{cmd:before} indicates observations before the first occurrence by 1 
and other observations by 0. 
{cmd:after} indicates observations after the first occurrence by 1 
and other observations by 0.  
The default, the value {cmd:before} and the value {cmd:after}
always sum to 1 for observations analysed.  
    
{p 8 8 2}     
First occurrence is determined as follows: (1) if {cmd:if} or {cmd:in} is 
specified, any observations excluded are ignored; (2) if {cmd:by()} is
specified, first is determined separately for each distinct group of
observations; (3) first is first in current sort order. 
If {it:#} does not occur, all observations 
are before the first occurrence. (Stata 6 required.)  

{p 4 8 2}{cmd:. gen warm = celstemp > 20}{p_end}
{p 4 8 2}{cmd:. egen fwarm  = ifirst(warm), v(1) by(year)}

{p 4 8 2} 
{cmd:ilast(}{it:numvar}{cmd:)}
{cmd:,}
{cmdab:v:alue(}{it:#}{cmd:)} 
[ 
{c -(}  
{cmdab:be:fore}
{c |}
{cmdab:a:fter}
{c )-} 
{cmd:by(}{it:byvarlist}{cmd:)} 
]    
indicates the last occurrence of integer {it:#} within {it:numvar} by 1 and 
other observations by 0. 

{p 8 8 2}
{cmd:before} indicates observations before the last occurrence by 1 
and other observations by 0.
{cmd:after} indicates observations after the last occurrence by 1 
and other observations by 0.  
The default, the value {cmd:before} and the value {cmd:after}
always sum to 1 for observations analysed.  

{p 8 8 2} 
Last occurrence is determined as follows: (1) if {cmd:if} or {cmd:in} is
specified, any observations excluded are ignored; (2) if {cmd:by()} is
specified, last is determined separately for each distinct group of
observations; (3) last is last in current sort order. 
If {it:#} does not occur, all
observations are before the last occurrence. (Stata 6 required.) 
    
{p 4 8 2}     
{cmd:lastnm(}{it:varname}{cmd:)} 
[ 
{cmd:,}
{cmd:by(}{it:byvarlist}{cmd:)} 
] 
returns the last non-missing value of {it:varname}. `Last' depends on
the existing order of observations.  {it:varname} may be numeric or
string. Remark: {cmd:lastnm()} would have been better called
{cmd:last()}, except that an {cmd:egen} program with that name for
selecting the last `word' in a string was published in STB-50. 
(Stata 6 required.) 


{title:Random numbers} 
    
{p 4 8 2}
{cmd:mixnorm()}
[ 
{cmd:,} 
{cmd:frac(}{it:#}{cmd:)}
{cmd:mu1(}{it:#}{cmd:)}
{cmd:mu2(}{it:#}{cmd:)}
{cmd:var1(}{it:#}{cmd:)}
{cmd:var2(}{it:#}{cmd:)} 
] 
generates a new variable of specified type as
a mixture of two Normal distributions, with the fraction
{cmd:frac(}{it:#}{cmd:)} of the observations defined by the first
distribution.  Both options for means {cmd:mu1(}{it:#}{cmd:)} and
{cmd:mu2(}{it:#}{cmd:)} default to 0; both options for variances
{cmd:var1(}{it:#}{cmd:)} and {cmd:var2(}{it:#}{cmd:)} default to 1,
while {cmd:frac(}{it:#}{cmd:)} defaults to 0.5. Only non-default
parameters of the desired mixture need be specified. (Stata 8 required.) 

{p 4 8 2}{cmd:. egen mixture = mixnorm(), frac(0.9) mu2(10) var2(4)}

{p 4 8 2}
{cmd:rndint()}
{cmd:,}
{cmdab:ma:x(}{it:#}{cmd:)}
[
{cmdab:mi:n(}{it:#}{cmd:)} 
] 
generates random integers from a uniform distribution on {cmd:min()} to
{cmd:max()}, inclusive. {cmd:min(1)} is the default. 
Remark: Note that {cmd:ceil(uniform() * }{it:#}{cmd:)} is a direct way
to get random integers from 1 to {it:#}. (Stata 6 required.)  

{p 4 8 2}{cmd:. egen integ = rndint(), min(100) max(199)}{p_end}

{p 4 8 2} 
{cmd:rndsub()}
[
{cmd:,}
{cmdab:ng:roup(}{it:#}{cmd:)}
{c -(}
{cmdab:f:rac(}{it:#}{cmd:)}
{c |}
{cmdab:p:ercent(}{it:#}{cmd:)}
{c )-} 
{cmd:by(}{it:byvarlist}{cmd:)}
] 
randomly splits observations into groups or subsamples. The result is a
categorical variable taking values from 1 upward labelling distinct groups. 

{p 8 8 2} 
{cmd:ngroup(}{it:#}{cmd:)} (default 2) defines the number of groups. 

{p 8 8 2} 
{cmd:frac(}{it:#}{cmd:)}, which is only allowed with {cmd:ngroup(2)}, specifies that 
the first group should contain 1 / {it:#} of the observations and thus that 
the second group should contain the remaining observations. 

{p 8 8 2}
{cmd:percent(}{it:#}{cmd:)}, which is only allowed with {cmd:ngroup(2)}, 
specifies that the first group should contain {it:#}% of the observations and thus that 
    the second group should contain the remaining observations.  

{p 8 8 2}
{cmd:frac()} and {cmd:percent()} may not be specified together. 
(Stata 6 required.) 

{p 4 8 2}{cmd:. egen group = rndsub(), by(foreign)}{p_end}

{p 4 8 2}{cmd:. egen group = rndsub(), by(foreign) f(3)}{p_end}
{p 4 4 2}(first group contains 1/3 of observations, second group contains 2/3) 

{p 4 8 2}{cmd:. egen group = rndsub(), by(foreign) p(25)}{p_end}
{p 4 8 2}(first group contains 25% of observations, second group contains 75%)

{p 4 4 2}
For reproducible results, set the seed of the random number generator 
beforehand and document your choice.

{p 4 4 2}
Note that to generate {it:#} random numbers the number of observations must be 
at least {it:#}. If there are no data in memory and you want 100 random 
numbers, type {cmd:set obs 100} before using these functions.


{title:Row operations} 
    
{p 4 8 2} 
{cmd:rall(}{it:varlist}{cmd:)}
{cmd:,}
{cmdab:c:ond(}{it:condition}{cmd:)} 
[
{cmdab:sy:mbol(}{it:symbol}{cmd:)} 
]
returns 1 for observations for which the condition specified is true for
all variables in {it:varlist} and 0 otherwise. The condition should be
specified using {cmd:symbol()}, by default {cmd:@}, as a placeholder for each
variable.  Thus, for example, 
{cmd:rall(}{it:varlist}{cmd:), c(@ > 0 & @ < .)}
tests whether all variables in {it:varlist} are positive and
non-missing. Note that conditions typically make sense only if variables
are either all numeric or all string: one exception is {cmd:missing(@)}.
(Stata 6 required.) 

{p 4 8 2}
{cmd:rany(}{it:varlist}{cmd:)}
{cmd:,}
{cmdab:c:ond(}{it:condition}{cmd:)} 
[
{cmdab:sy:mbol(}{it:symbol}{cmd:)} 
]
returns 1 for observations for which the condition specified is true for
any variable in {it:varlist} and 0 otherwise. The condition should be
specified using {cmd:symbol()}, by default {cmd:@}, as a placeholder for each
variable.  Thus, for example, {cmd:rany(}{it:varlist}{cmd:), c(@ > 0 & @ < .)}
tests whether any variable in {it:varlist} is positive and non-missing.
Note that conditions typically make sense only if variables are either
all numeric or all string: one exception is {cmd:missing(@)}.
(Stata 6 required.) 

{p 4 8 2} 
{cmd:rcount(}{it:varlist}{cmd:)}
{cmd:,}
{cmdab:c:ond(}{it:condition}{cmd:)}
[
{cmdab:sy:mbol(}{it:symbol}{cmd:)} 
]
returns     the number of variables in {it:varlist} for which the condition
specified is true. The condition should be specified using {cmd:symbol()}, by
default {cmd:@}, as a placeholder for each variable. Thus, for example,
{cmd:rcount(}{it:varlist}{cmd:), c(@ > 0 & @ < .)} counts for each observation how
many variables in {it:varlist} are positive and non-missing. Note that
conditions typically make sense only if variables are either all numeric or all
string: one exception is {cmd:missing(@)}.  More precisely, {cmd:rcount()}
gives the sum across {it:varlist} of condition, evaluated in turn for each
variable. (Stata 6 required.) 

{p 4 4 2}
For {cmd:rall()}, {cmd:rany()}, and {cmd:rcount()}, the {cmd:symbol()} option
may be used to set an alternative to {cmd:@} whenever the latter is
inappropriate. For example, if string variables were being searched for literal
occurrences of {cmd:"@"}, some other symbol not appearing in text or in
variable names should be used. 

{p 4 8 2}{cmd:. egen any = rany(b c d e f) , c(@ == a)}{p_end}
{p 4 8 2}{cmd:. egen all = rall(b c d e f) , c(@ == a)}{p_end}
{p 4 8 2}{cmd:. egen count = rcount(b c d e f) , c(@ == a)}{p_end}
{p 4 4 2}(values of {cmd:b c d e f} matched by (equal to) those of {cmd:a}?)

{p 4 8 2}{cmd:. egen anyw1 = rany(b c d e f) , c(abs(@ - a) <= 1)}{p_end}
{p 4 8 2}{cmd:. egen allw1 = rall(b c d e f) , c(abs(@ - a) <= 1)}{p_end}
{p 4 8 2}{cmd:. egen countw1 = rcount(b c d e f) , c(abs(@ - a) <= 1)}{p_end}
{p 4 4 2}(values of {cmd:b c d e f} within 1 of those of {cmd:a}?) 

{p 4 4 2} 
From Stata 7, {help foreach} provides an alternative that would now be 
considered better style: 

{p 4 8 2}{cmd:. gen any = 0}{p_end}
{p 4 8 2}{cmd:. gen all = 1}{p_end}
{p 4 8 2}{cmd:. gen count = 0}{p_end}
{p 4 8 2}{cmd:. foreach v of var a b c d e f {c -(}}{p_end}
{p 4 8 2}{cmd:. {space 8}replace any = max(any, inrange(`v', 0, .))}{p_end}
{p 4 8 2}{cmd:. {space 8}replace all = min(all, inrange(`v', 0, .))}{p_end}
{p 4 8 2}{cmd:. {space 8}replace count = count + inrange(`v', 0, .)}{p_end}
{p 4 8 2}{cmd:. {c )-}}{p_end}

{p 4 8 2} 
{cmd:rowmedian(}{it:varlist}{cmd:)}
returns the median across observations of the variables in {it:varlist}.
(Stata 9 required.) (Note: official Stata added a {cmd:rowmedian()} 
function in Stata 11, which always trumps this one.) 

{p 4 8 2}
{cmd:rownvals(}{it:numvarlist}{cmd:)} [ {cmd:,} {cmdab:miss:ing} ] 
returns the number of distinct values in each observation for a set of 
numeric variables {it:numvarlist}. Thus if the values in one observation for 
five numeric variables are 1, 1, 2, 2, 3 the function returns 3 for 
that observation. Missing values, i.e. any of . .a ... .z, are ignored
unless the {cmd:missing} option is specified. (Stata 9 required.)  

{p 4 8 2}
{cmd:rowsvals(}{it:strvarlist}{cmd:)} [ {cmd:,} {cmdab:miss:ing} ] 
returns the number of distinct values in each observation for a set of 
string variables {it:strvarlist}. Thus if the values in one observation for 
five string variables are "frog", "frog", "toad", "toad", "newt" the function returns 3 for 
that observation. Missing values, i.e. empty strings "", are ignored
unless the {cmd:missing} option is specified. (Stata 9 required.) 

{p 4 8 2}
{cmd:rsum2(}{it:varlist}{cmd:)} is a generalisation of {help egen}'s
{cmd:rsum()} (from Stata 9: {cmd:rowtotal()}) function with the extra 
options {cmdab:allm:iss} and {cmdab:anym:iss}.
As with {cmd:rsum()}, it creates the (row) sum of the variables in {it:varlist},
treating missing as 0.  However, if the option {cmd:allmiss} is selected, the
(row) sum for any observation for which all variables in {it:varlist} are
missing is set equal to missing. Similarly, if the option {cmd:anymiss} is
selected the (row) sum for any observation for which any variable in
{it:varlist} is missing is set equal to missing. (Stata 6 required.) 


{title:References}

{p 4 8 2}
Bross, I.D.J. 1958. How to use ridit analysis. {it:Biometrics} 14: 18{c -}38.

{p 4 8 2} 
Cox, N.J. 2008. Speaking Stata: Between tables and graphs. 
{it:Stata Journal} 8(2): 269{c -}289. 

{p 4 8 2} 
Cox, N.J. and G. M. Longton. 2008. 
Speaking Stata: Distinct observations. 
{it:Stata Journal} 8(4): 557{c -}568. 
   
{p 4 8 2}
Fleiss, J.L. 1981. {it:Statistical Methods for Rates and Proportions.}
New York: John Wiley.

{p 4 8 2}
Flora, J.D. 1988. Ridit analysis. In Kotz, S. and Johnson, N.L. (eds) 
{it:Encyclopedia of Statistical Sciences.} New York: John Wiley. 8: 136{c -}139. 

{p 4 8 2}
Tukey, J.W. 1977. {it:Exploratory Data Analysis.} Reading, MA: Addison-Wesley. 


{title:Maintainer} 

{p 4 4 2}Nicholas J. Cox, Durham University, U.K.{break} 
         n.j.cox@durham.ac.uk


{title:Acknowledgements}

{p 4 4 2}
Kit Baum (baum@bc.edu) is the first author of {cmd:record()} and the
author of {cmd:dhms()}, {cmd:elap()}, {cmd:elap2()}, {cmd:hms()},
{cmd:tod()}, {cmd:mixnorm()} and {cmd:truncdig()}. 

{p 4 4 2}
Ulrich Kohler (kohler@wzb.eu) is the author of {cmd:xtile()}, 
{cmd:mlabvpos()}, {cmd:iso3166()} and {cmd:wpctile()}. 

{p 4 4 2}
Pablo A. Mitnik (pmitnik@stanford.edu) is the author of {cmd:d2()}. 

{p 4 4 2}
Steven Stillman (s.stillman@verizon.net) is the author of {cmd:rsum2()}. 

{p 4 4 2}
Nick Winter (njw3x@virginia.edu) is the author of {cmd:corr()} and
{cmd:noccur()}. 

{p 4 4 2}
Kit Baum, Sascha Becker, Ron{c a'}n Conroy, William Gould, Syed Islam, 
Ariel Linden, 
John Moran,  
Stephen Soldz, Richard Williams, Fred Wolfe and Gerald Wright 
provided stimulating and helpful comments. 


{title:Also see}

{p 4 13 2}STB: STB-50 dm70 for {cmd:atan2()}, {cmd:pp()}, {cmd:rev()}, {cmd:rindex()}, {cmd:rmed()}, {cmd:rotate()}

{p 4 13 2}Manual: [D] egen (before Stata 9 [R] egen) 

{p 4 13 2}On-line: help for 
{help egen}, 
{help dates}, 
{help functions}, 
{help means}, 
{help numlist}, 
{help seed}, 
{help tsset}, 
{help varlist} (timeseries operators), 
{help circular} (if installed), 
{help ntimeofday} (if installed), 
{help stimeofday} (if installed) 

