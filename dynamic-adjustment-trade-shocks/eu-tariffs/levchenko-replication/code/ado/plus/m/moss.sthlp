{smcl}
{* revised 22apr2016}{...}
{cmd:help moss}
{hline}

{title:Title}

{phang}
{bf:moss} {hline 2} Find multiple occurrences of substrings


{title:Syntax}

{p 8 17 2}{cmd:moss} 
	{it:strvar} 
	{ifin}
	{cmd:,}
	{cmdab:m:atch(}[{cmd:"}]{it:pattern}[{cmd:"}]{cmd:)} 
	[
	{cmdab:r:egex} 
	{cmdab:p:refix(}{it:prefix}{cmd:)}
	{cmdab:s:uffix(}{it:suffix}{cmd:)}
	{cmdab:max:imum(}{it:#}{cmd:)} 
	{cmdab:u:nicode} 
	]


{title:Description}

{pstd}
{cmd:moss} finds occurrences of substrings matching a pattern
in a given string variable. Depending on what is sought and what is
found, variables are created giving the count of occurrences (always);
the positions of occurrences (whenever any are found); and the exact
substrings found (when a regular expression defines a
subexpression to be returned). The default names are
respectively {cmd:_count}, {cmd:_pos1} up, and {cmd:_match1} up. 


{title:Remarks} 

{pstd}
By default, {cmd:moss} finds repeated occurrences
of the string specified in {cmd:match()} using Stata's {help strpos()}
string function (in older versions of Stata, {help strpos()} was named
{help index()}). A {cmd:_count} variable is created to indicate
the number of occurrences per observation. The position, per observation, of the
first instance will be recorded in {cmd:_pos1}, the second in {cmd:_pos2},
and so on.

{pstd}
With the {cmd:regex} option, {cmd:moss} can be used to repeatedly find more
complex patterns of text. The specification of the search pattern must
follow {help regexm()} syntax and include one and only one subexpression
to be matched. When using 
regular expressions, subexpressions are identified using parentheses.
For example, {cmd:match("AMC ([A-Za-z]+)")} will match {cmd:"AMC Concord"},
{cmd:"AMC Pacer"}, and {cmd:"AMC AMC Spirit"} but {cmd:moss} will put
in {cmd:_match1} the matched subexpressions {cmd:"Concord"}, {cmd:"Pacer"}, 
and {cmd:"AMC Spirit"}. 

{pstd}
{cmd:moss} follows the principle that occurrences must be disjoint and
may not overlap. That is, it finds just one occurrence of {cmd:"ana"} in
{cmd:"banana"}, not two. 


{title:Options} 

{phang}{cmd:match()} is required and the pattern can be either
literal text or a regular expression. 

{phang}{cmd:regex} specifies that the pattern is to be interpreted as a
regular expression. Such a pattern must contain precisely one
subexpression to be extracted. See Examples. 

{phang}{cmd:prefix()} specifies an alternative prefix for new variable
names to be created by {cmd:moss}. Such a prefix must start either with
a letter or with an underscore. 

{phang}{cmd:suffix()} specifies a suffix for new variable
names to be created. 

{phang}{cmd:prefix()} and {cmd:suffix()} may not be combined. 

{phang}{cmd:maximum()} specifies an upper limit to the number of
position and match variables to be created. That is, specify
{cmd:max(3)} if you want to see details of at most the first 3
occurrences of your pattern. 

{phang}{cmd:unicode} specifies that the Unicode versions of
Stata's string functions are to be used. This requires Stata
version 14 or higher.
 

{title:Examples}

{phang}{cmd:. moss make, match(",")}{p_end}

{phang}{cmd:. moss make, match("([0-9]+)") regex}{p_end}

{phang}{cmd:. moss history, match("(X+)") regex}{p_end}

{phang}{cmd:. moss s, match("([^ ]+)") prefix(s_) regex}{p_end} 


{title:Authors}

{pstd}Robert Picard{p_end}
{pstd}picard@netbox.com{p_end}

{pstd}Nicholas J. Cox, Durham University{p_end}
{pstd}n.j.cox@durham.ac.uk{p_end}


{title:Acknowledgments}

{pstd}A question on Statalist from Rebecca A. Pope was the stimulus for
writing this program. 


{title:Also see}

{psee}
Help:  {manhelp strpos() D}, {manhelp regexm() D}, {manhelp split D} 
{p_end}

{psee}
FAQs:  {browse "http://www.stata.com/support/faqs/data/regex.html":What are regular expressions and how can I use them in Stata?}
{p_end}
