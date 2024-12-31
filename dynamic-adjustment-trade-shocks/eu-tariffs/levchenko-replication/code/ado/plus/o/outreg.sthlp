{smcl}
{* *! version 4.03 6may2014}{...}
{cmd:help outreg (basic options)}
{hline}

{title:Title}

    {hi:outreg} {c -} reformat and write regression tables to a document file

{pstd}
This is {it:simplified} help for {hi:outreg} with a subset of options for a typical regression table. For complete documentation, see {help outreg_complete:complete outreg}.{p_end}

{pstd}
For an explanation of the large changes to {cmd:outreg} since the last version, see {help outreg_update:outreg updates}.

{title:Syntax}

{p 8 17 2}
{cmd:outreg}
[{opt using} {it:filename}]
[{cmd:,} {it:options}]

{synoptset 22 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:{help outreg##basic_options:Basic options}}
{synopt:{opt se}}standard errors, not t stats, below coefficients{p_end}
{synopt:{opt bd:ec(numlist)}}decimal places for estimates b; default is bdec(3){p_end}
{synopt:{opt summs:tat(evaluegrid)}}place additional summary statistics below coefficient estimates{p_end}
{synopt:{opt starlev:els(numlist)}}significance levels for stars{p_end}
{synopt:{opt eq:_merge}}create separate columns for each equation after a multi-equation estimation{p_end}

{synopt:{opt va:rlabels}}use variable labels as row headings{p_end}
{synopt:{opt t:itle(textcolumn)}}put title above table{p_end}
{synopt:{opt ct:itles(textgrid)}}specify column headings{p_end}
{synopt:{opt rt:itles(textgrid)}}specify row headings{p_end}
{synopt:{opt not:e(textcolumn)}}put note below table{p_end}
{synopt:{opt sq:uarebrack}}square brackets instead of parentheses{p_end}

{synopt:{opt tex}}write TeX file instead of default MS Word file{p_end}
{synopt:{opt m:erge}}merge table with a previous table{p_end}
{synopt:{opt replace}}overwrite existing file{p_end}
{synoptline}
{p2colreset}{...}
{marker textcolumn}{marker textrow}{marker textgrid}{...}
{phang}where the syntax of{p_end}
{phang2}
{it:textcolumn} is  "{it:string}" [\"{it:string}"...]{p_end}
{phang2}
{it:textrow} is  "{it:string}" [,"{it:string}"...]{p_end}
{phang2}
{it:textgrid} is  "{it:string}" [,"{it:string}"...] [\ "{it:string}"[,"{it:string}"...] [\ [...]]] or a {it:textrow} or a {it:textcolumn} as a special case{p_end}

{phang2}
"{it:string}" ["{it:string}" ...] will often work in place of a {it:textrow} or a {it:textcolumn} when the user's intent is clear, but if in doubt use the proper {it:textrow} or {it:textcolumn} syntax above.{p_end}

{p}
There are {it:many} other options available; see {help outreg_complete:complete outreg}.{p_end}


{title:Description}

{pstd}
{cmd:outreg} formats the results of Stata estimation commands in tables as they are typically presented in journal articles, rather than as they are presented in the Stata Results window. 
By default, {it:t} statistics appear in parentheses below the coefficient estimates with asterisks for significance levels, with the number of observations and R-squared (no pseudo R-squareds) below all the estimates.
{cmd:outreg} automates the process of converting estimation results to standard tables by creating a Microsoft Word or TeX document containing a formatted table.  
Almost every aspect of the table's structure and formatting (including fonts) can be specified with options.{p_end}

{pstd}
{cmd:outreg} works after any estimation command in Stata (see {help estimation commands} for a complete list). Like {help predict}, {cmd:outreg} makes use of internally saved estimation results, 
so it should be invoked after the estimation.{p_end}

{pstd}
The table created by {cmd:outreg} is displayed in the Results window, minus the fancy font specifications, unless the {help outreg_complete##nodisplay:nodisplay} option is employed. If {opt using} {it:filename} is specified, {cmd:outreg} creates a Microsoft Word file by default, or a TeX file using the {help outreg##tex:tex} option.  

{pstd}
Successive estimation results, which may use different variables, can be combined by {cmd:outreg} in a single table with the variable coefficients lined
up properly using the {help outreg##merge:merge} option. (n.b. In previous versions of {cmd:outreg}, the {cmd:merge} option was called "append".) 

{marker basic_options}
{title:Options}

{dlgtab:Basic}
{marker se}
{phang}
{opt se} specifies that standard errors rather than {it:t} statistics
are reported in parentheses below the coefficient estimates. The decimal places displayed are those set by {cmd:bdec}.{p_end}
{marker bdec}{...}

{phang}
{opt bdec(numlist)} specifies the number of decimal places
reported for coefficient estimates (the b's).  It also specifies the decimal
places reported for standard errors if {cmd:se}.  The default value for {cmd:bdec} is 3. The minimum value is 0 and the maximum value is 15.  
If one number is specified in {cmd:bdec}, it will apply to all coefficients.  If multiple numbers are specified in {cmd:bdec}, the first number will determine the decimals reported for the first coefficient, 
the second number, the decimals for the second coefficient, etc. If there are fewer numbers in {cmd:bdec} than coefficients, the last number in {cmd:bdec} will apply to all the remaining coefficients.{p_end}
{marker tdec}{...}

{phang}
{opt summstat(evaluegrid)} places additional summary statistics below the coefficient estimates.  {it:evaluegrid} is a grid of the names of different e() return values already calculated by the estimation command.  
The syntax of the {it:evaluegrid} is the same as the other grids used in {cmd:outreg} like the {it:{help outreg##textcolumn:textgrid}}.  Elements within a row are separated with commas (","), and rows are separated by backslashes ("\").  
The default value of summstat is {opt summstat(r2 \ N)} (when e(r2) is defined), which places the R-squared statistic e(r2) below the coefficient estimates, and the number of observations e(N) below that.  

{pmore}
To replace the R-squared with the adjusted R-squared stored in e(r2_a), you can use the options {opt summstat(r2_a \ N)} and {opt summtitle("Adjusted R2" \ "N")}.  
You can also specify the decimal places for the summary statistics with the {help outreg_complete##summdec:summdec} option.  To see a complete list of the e() macro values available after each estimation command, type {cmd:ereturn list}.

{pmore}
Statistics not included in the e() return values can be added to the table with the {help outreg_complete##addrows:addrows} option.{p_end}
{marker starlevels}{...}

{phang}
{opt starlevels(numlist)} indicates significance levels for stars in percent.  
By default, one star is placed next to coefficients which pass the test for significant difference from zero at the 5% level, 
and two stars next to coefficients that pass the test for significance at the 1% level, which is equivalent to {opt starlevels(5 1)}.  
To place one star for the 10% level, 2 for the 5% level, and 3 for the 1% level, you would specify {opt starlevels(10 5 1)}.  
To place one star for the 5% level, 2 for the 1% level, and 3 for the 0.1% level, you would specify {opt starlevels(5 1 .1)}.  {p_end}
{marker summdec}{...}

{phang}
{opt eq_merge} creates separate columns for each equation after a multi-equation estimation.  
The entries in each column are merged according to the variable names, similarly to the {help outreg#merge:merge} option for combining separate estimation results.  
This option is useful after estimation commands like {help reg3}, {help sureg}, {help mlogit}, {help mprobit}, etc. where many of the same variables occur in different equations. {p_end}

{phang}
{opt varlabels} causes {cmd:outreg} to use variable labels (rather than variable names) as row titles for each coefficient. See {cmd:little} to specify row titles manually.{p_end}
{marker title}{...}

{phang}
{cmd:title(}{it:{help outreg##textcolumn:textcolumn}}{cmd:)} specifies a title or titles above the regression table.
Subtitles should be separated from the primary titles by backslashes ("\"), like this: {opt title("Main Title" \ "First Sub-Title" \ "Second Sub-Title").  
By default, titles are set in a larger font than the body of the table.{p_end}
{marker ctitles}{...}

{phang}
{cmd:ctitles(}{it:{help outreg##textgrid:textgrid}}{cmd:)} specifies the column titles above the estimates.  By default if no {cmd:ctitles} are specified, the name of the dependent variable is displayed. A simple form of {cmd:ctitles} is, for example,
{cmd:ctitles(}{it:"Variables","First Regression"}{cmd:)}.  Note that the first title in {cmd:ctitles} goes above the variable name column and the second title goes above the estimates column. 
If you want no heading above the variable name  column, specify {cmd:ctitles(}{it:"","First Regression"}{cmd:)}. Fancier titles in {cmd:ctitles} can have multiple rows.  See {help outreg_complete##ctitles:ctitles} for details.{p_end}
{marker rtitles}{...}

{phang}
{cmd:rtitles(}{it:{help outreg##textgrid:textgrid}}{cmd:)} replaces the leftmost column of the table with new row titles for the coefficient estimates. By default (with no rtitles option), the row titles are variable names. 
Multiple titles in {cmd:rtitles} should be separated by "\" since they are placed below one another (if the titles are separated with commas, they will all be placed in the first row of the estimates).  
An example of {cmd:rtitles} is {cmd:rtitles(}{it:"Variable 1" \ "" \ "Variable 2" \ "" \ "Constant"}{cmd:)}. The empty titles "" are to account for the {it:t} statistics below the coefficients.{p_end}
{marker squarebrack}{...}

{phang}
{cmd:note(}{it:{help outreg##textcolumn:textcolumn}}{cmd:)} specifies a note to be displayed below the {cmd:outreg} table.
Multiple lines of a note should be separated by backslashes ("\"), like this: {opt note("First note line."\"Second note line."\"Third note line.")}.  
Notes are centered immediately below the table. By default, they are set in a smaller font than the body of the table.{p_end}
{marker tex}{...}

{phang}
{opt squarebrack} substitutes square brackets for parentheses around the statistics placed below the first statistic.  
This means that square brackets, rather than parentheses, are placed around {it:t} statistics below the coefficient estimates (when using the default statistics).
See {help complete_outreg##brackets:brackets} for more complete control of bracket symbols around statistics.
{marker note}{...}

{phang}
{opt tex} specifies that {cmd:outreg} writes a TeX output file rather than a Word file.  
The output is suitable for including in a TeX document (see the {help outreg_complete##fragment:fragment} option) or loading into a TeX typesetting program such as Scientific Word.{p_end}
{marker merge}{...}

{phang}
{opt merge} specifies that new estimation output be merged with an existing  table. The coefficient estimates are lined up matching the text in the left-most columns by the appropriate variable name or {help outreg##rtitles:rtitles}, 
with the coefficients for new variables placed below the original variables, but above the constant term. 
Note that in previous versions of {cmd:outreg}, the {cmd:merge} option was called {it:append}. Users will usually want to specify {help outreg##ctitles:ctitles} when using {cmd:merge}.{p_end}
{marker replace}{...}

{phang}
{opt replace} specifies that it is okay to overwrite an existing file.


{title:Remarks}

{pstd}
For information on many other options, see {help outreg_complete:complete outreg}.{p_end}
{marker examples}{...}


{title:Examples}

1. Basic usage and variable labels.

{pstd}
{cmd:outreg} is used after an estimation command because it needs the saved estimation results to construct a formatted table.
Consider a regression using Stata's auto.dta dataset:

	{cmd}. sysuse auto, clear
	{txt}(1978 Automobile Data)

	{cmd}. reg mpg foreign weight 

	      {txt}Source {c |}       SS       df       MS              Number of obs ={res}      74
	{txt}{hline 13}{char +}{hline 30}           F(  2,    71) ={res}   69.75
	    {txt}   Model {char |} {res}  1619.2877     2  809.643849           {txt}Prob > F      = {res} 0.0000
	    {txt}Residual {char |} {res} 824.171761    71   11.608053           {txt}R-squared     = {res} 0.6627
	{txt}{hline 13}{char +}{hline 30}           Adj R-squared = {res} 0.6532
	    {txt}   Total {char |} {res} 2443.45946    73  33.4720474           {txt}Root MSE      = {res} 3.4071

	{txt}{hline 13}{c TT}{hline 64}
	         mpg {c |}      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
	{hline 13}{char +}{hline 64}
	     foreign {c |}  {res}-1.650029   1.075994    -1.53   0.130      -3.7955    .4954422
	{txt}      weight {c |}  {res}-.0065879   .0006371   -10.34   0.000    -.0078583   -.0053175
	{txt}       _cons {c |}  {res}  41.6797   2.165547    19.25   0.000     37.36172    45.99768
	{txt}{hline 13}{c BT}{hline 64}

{pstd}
The simplest form of {cmd:outreg} displays a reformatted estimation table in the Stata Results window.

	{cmd}. outreg

	{txt}{center:{hline 22}}
	{center:{txt}{lalign 9:}{txt}{center 11:mpg}}
	{txt}{center:{hline 22}}
	{center:{txt}{lalign 9:foreign}{res}{center 11:-1.650}}
	{center:{txt}{lalign 9:}{res}{center 11:(1.53)}}
	{center:{txt}{lalign 9:weight}{res}{center 11:-0.007}}
	{center:{txt}{lalign 9:}{res}{center 11:(10.34)**}}
	{center:{txt}{lalign 9:_cons}{res}{center 11:41.680}}
	{center:{txt}{lalign 9:}{res}{center 11:(19.25)**}}
	{center:{txt}{lalign 9:R2}{res}{center 11:0.66}}
	{center:{txt}{lalign 9:N}{res}{center 11:74}}
	{txt}{center:{hline 22}}
	{txt}{center:* p<0.05; ** p<0.01}

{pstd}
The command {cmd:outreg using auto} creates a new Word file named auto.doc as well as displaying the table in the Results window (which can be turned off with {help complete_outreg##nodisplay:nodisplay}).

{pstd}
{cmd:outreg} can also create tables in TeX format with the {help outreg##tex:tex} option.

{pstd}
The option {opt varlabels} replaces variable names with their labels, so
that the independent variable mpg listed above the column of regression
coefficients uses the label "Mileage (mpg)", the variable foreign uses its
label "Car type", etc.  The user can change the variable labels before invoking
{cmd:outreg} to provide the desired captions in the {cmd:outreg} 
table.  Alternatively, the user can specify column and row titles directly with {help outreg##ctitles:ctitles} and {help outreg##rtitles:rtitles}.

{pstd}
If the file auto.doc already exists from
a previous {cmd:outreg using auto} command, we must include the {cmd:replace} option as
well.

	{cmd}. outreg using auto, varlabels replace
	{res}
	{txt}{center:{hline 32}}
	{center:{txt}{lalign 15:}{txt}{center 15:Mileage (mpg)}}
	{txt}{center:{hline 32}}
	{center:{txt}{lalign 15:Car type}{res}{center 15:-1.650}}
	{center:{txt}{lalign 15:}{res}{center 15:(1.53)}}
	{center:{txt}{lalign 15:Weight (lbs.)}{res}{center 15:-0.007}}
	{center:{txt}{lalign 15:}{res}{center 15:(10.34)**}}
	{center:{txt}{lalign 15:Constant}{res}{center 15:41.680}}
	{center:{txt}{lalign 15:}{res}{center 15:(19.25)**}}
	{center:{txt}{lalign 15:R2}{res}{center 15:0.66}}
	{center:{txt}{lalign 15:N}{res}{center 15:74}}
	{txt}{center:{hline 32}}
	{txt}{center:* p<0.05; ** p<0.01}
{marker xmpl2}

{title:Example 2. Decimal places for coefficients and titles} 

{pstd}
The regression table in the previous example would be improved by formatting
the coefficient values and adding informative titles.  By default the
regression coefficients are shown with three decimal places in {cmd:outreg}
tables, but this isn't very satisfactory for the {hi:weight} variable in the
regression above. The weight coefficient is statistically significant, but only
one non-zero digit is displayed.  We could use the option {cmd:bdec(5)} to
display 5 decimal places for all the coefficients, but we can do better. To
display five decimal places of the weight coefficient only and two decimal
places of the other coefficients, we use {bind:{opt bdec(2 5 2)}}.

{pstd}We can add a title to the table with the {cmd:title} option.  
As long as the title text contains no backspaces (which indicate multiple lines of title), no quotation marks are required, so we add the option {opt title(What kind of cars have low mileage?)}.  
We also change the column heading of the estimates from the name of the independent variable to "Base case" with {opt ctitle("",Base case)}.  
We need the "" to indicate that there is no {opt ctitle} in the left-most column of the table.  We can get away with no quotes around "Base case" because
there is no "," or "\" in the title, which are interpreted by {opt ctitles} as
column and row delimiters.

	{cmd}. outreg using auto, bdec(2 5 2) varlabels replace ///
		title(What cars have low mileage?) ctitle("", Base case)
	{res}
	{txt}{center:What cars have low mileage?}
	{txt}{center:{hline 28}}
	{center:{txt}{lalign 15:}{txt}{center 11:Base case}}
	{txt}{center:{hline 28}}
	{center:{txt}{lalign 15:Car type}{res}{center 11:-1.65}}
	{center:{txt}{lalign 15:}{res}{center 11:(1.53)}}
	{center:{txt}{lalign 15:Weight (lbs.)}{res}{center 11:-0.00659}}
	{center:{txt}{lalign 15:}{res}{center 11:(10.34)**}}
	{center:{txt}{lalign 15:Constant}{res}{center 11:41.68}}
	{center:{txt}{lalign 15:}{res}{center 11:(19.25)**}}
	{center:{txt}{lalign 15:R2}{res}{center 11:0.66}}
	{center:{txt}{lalign 15:N}{res}{center 11:74}}
	{txt}{center:{hline 28}}
	{txt}{center:* p<0.05; ** p<0.01}

{pstd}
If you run the commands above and open the resulting file auto.doc in Word or most other word-processing software, you can see the formatted table created by {cmd:outreg}.
{marker xmpl3}


{title:Example 3. Merging estimation tables together.}

{pstd}
Users often want to include several related estimations in the same 
table.  {cmd:outreg} automatically combines results with the {cmd:merge} 
option. 

{pstd}
We create a new variable {hi:weightsq} for the second regression.

	{cmd}. gen weightsq = weight^2
	{cmd}. label var weightsq "Weight squared"
{txt}
{pstd}
Then we run the second regression with the quadratic {hi:weightsq} term.

	{cmd}. regress mpg foreign weight weightsq
	{txt}  ({it:output omitted})

{pstd}
We add the second regression results to the regression table in Example 2 with the {cmd:merge} option.  In the second regression, the {hi:weightsq} term is statistically significant but very small due to the small units used for weight (pounds).  We can avoid displaying a large number of decimal places by formatting the {hi:weightsq} coefficient in scientific notation with the option {help outreg_complete##bfmt:bfmt(f f e f)}.  
We also specify the number of decimal places for each coefficient as in the first regression, and add an informative column title with the options 
{opt bdec(2 5 2)} and {opt ctitle("", Quadratic mpg)}.  Note that although
there are four coefficients (counting the constant), there are only three
numbers in {opt bdec(2 5 2)}.  The last number in {opt bdec}, 2, applies
to all the remaining coefficients.

	{cmd}. outreg using auto, bdec(2 5 2) bfmt(f f e f) ctitle("", Quadratic mpg) ///
	          varlabels merge
	{res}
	{txt}{center:What cars have low mileage?}
	{txt}{center:{hline 44}}
	{center:{txt}{lalign 16:}{txt}{center 11:Base case}{txt}{center 15:Quadratic mpg}}
	{txt}{center:{hline 44}}
	{center:{txt}{lalign 16:Car type}{res}{center 11:-1.65}{res}{center 15:-2.20}}
	{center:{txt}{lalign 16:}{res}{center 11:(1.53)}{res}{center 15:(2.08)*}}
	{center:{txt}{lalign 16:Weight (lbs.)}{res}{center 11:-0.00659}{res}{center 15:-0.01657}}
	{center:{txt}{lalign 16:}{res}{center 11:(10.34)**}{res}{center 15:(4.18)**}}
	{center:{txt}{lalign 16:Weight squared}{res}{center 11:}{res}{center 15:1.59e-06}}
	{center:{txt}{lalign 16:}{res}{center 11:}{res}{center 15:(2.55)*}}
	{center:{txt}{lalign 16:Constant}{res}{center 11:41.68}{res}{center 15:56.54}}
	{center:{txt}{lalign 16:}{res}{center 11:(19.25)**}{res}{center 15:(9.12)**}}
	{center:{txt}{lalign 16:R2}{res}{center 11:0.66}{res}{center 15:0.69}}
	{center:{txt}{lalign 16:N}{res}{center 11:74}{res}{center 15:74}}
	{txt}{center:{hline 44}}
	{txt}{center:* p<0.05; ** p<0.01}

{pstd}
The coefficients and {it:t} statistics for the variables are aligned correctly in the merged table.  

{pstd}
Note that since the first {cmd:outreg} table from Example 2 used {opt varlabels}, we need to use {opt varlabels} in the {cmd:outreg} command that merges the second regression. 
If not, the {help outreg##rtitles:rtitles} would differ between the original table and the new results being merged and the coefficients would not be aligned correctly.  
For example, the label for the first coefficient in the original table is "Car type".  
Without the {opt varlabels} option in the {cmd:outreg} commmand above merging the new results, the first coefficient of the second regression would be labeled "foreign" 
and would be treated as new variable instead of being aligned in the first row with "Car type".
{marker xmpl4}


{title:Example 4. Standard errors, brackets, and no asterisks in a TeX table}

{pstd}
Economics journals often prefer standard errors to {it:t} statistics and don't
use asterisks to denote statistical significance.  
The {cmd:se} option replaces
{it:t} statistics with standard errors, and the {cmd:nostar} option suppresses asterisks.  
We will also replace the parentheses around the standard errors with square brackets using the {opt squarebrack} option, and save the document as a TeX file with the {opt tex} option.
Note that the decimal places specified by the {opt bdec} option apply to both the coefficients and the standard errors.

	{cmd}. regress mpg foreign weight 
	({it:output omitted})

	{cmd}. outreg using auto, se bdec(2 5 2) squarebrack nostars replace tex ///
	          varlabels title(No t statistics, please - we're economists)
	{res}
	{txt}{center:No t statistics, please - we're economists}
	{txt}{center:{hline 32}}
	{center:{txt}{lalign 15:}{txt}{center 15:Mileage (mpg)}}
	{txt}{center:{hline 32}}
	{center:{txt}{lalign 15:Car type}{res}{center 15:-1.65}}
	{center:{txt}{lalign 15:}{res}{center 15:[1.08]}}
	{center:{txt}{lalign 15:Weight (lbs.)}{res}{center 15:-0.00659}}
	{center:{txt}{lalign 15:}{res}{center 15:[0.00064]}}
	{center:{txt}{lalign 15:Constant}{res}{center 15:41.68}}
	{center:{txt}{lalign 15:}{res}{center 15:[2.17]}}
	{center:{txt}{lalign 15:R2}{res}{center 15:0.66}}
	{center:{txt}{lalign 15:N}{res}{center 15:74}}
	{txt}{center:{hline 32}}
{marker xmpl5}

{title:Example 5. 10% significance level and summary statistics.}

{pstd}
The cutoff levels for stars indicating statistical significance can be modified with the {help outreg##starlevels:starlevels} option.  
The default levels are one star for 5% significance and two stars for  1% significance (i.e. {opt starlevels(5 1)}).  
To add a symbol for 10% significance, we use the option {opt starlevels(10 5 1)}. This would display 1 star for 10%, 2 for 5%, and 3 for 1%.  
To retain the original number of stars for 5% and 1% levels, but add a cross for the 10% level, we can use the option {help outreg_complete##sigsymbols:sigsymbols(+,*,**)} 
with the symbols corresponding to the significance levels in {opt starlevels}.  The legend at the bottom of the {cmd:outreg} table is modified to reflect these options.

{pstd}
The default summary statistics are the R-squared (if it's defined) and the number of observations.  
Instead, we display the {it:F} statistic and the adjusted R-squared using the {help outreg##summstat:summstat} option.  
The symbols used for these statistics in the estimates return values are "F" and "r2_a".  
All available return values after an estimation can be seen with the command {help ereturn list}.  
The {opt summstat(F \ r2_a)} option is specified with a backslash separating the statistics because we want them to be on different rows in the same column 
(if we used a comma to separate the values, they would be on the same row in different columns, making the table one column wider).  
We also specify the names of the statistics in {opt summtitle(F statistic \ Adjusted R-squared)}, similarly to {help outreg##rtitles:rtitles}.  
To give the {it:F} statistic one decimal place and the adjusted R-squared two decimal places, we use the option {opt summdec(1 2)}.


	{cmd}. reg mpg foreign weight turn
	({it:output omitted})

	{com}. outreg using auto, bdec(2 5 3 2) varlabels replace              ///
	          starlevels(10 5 1) sigsymbols(+,*,**) summstat(F \ r2_a)  ///
	          summtitle(F statistic \ Adjusted R-squared) summdec(1 2)
	{res}
	{txt}{center:{hline 37}}
	{center:{txt}{lalign 20:}{txt}{center 15:Mileage (mpg)}}
	{txt}{center:{hline 37}}
	{center:{txt}{lalign 20:Car type}{res}{center 15:-2.08}}
	{center:{txt}{lalign 20:}{res}{center 15:(1.85)+}}
	{center:{txt}{lalign 20:Weight (lbs.)}{res}{center 15:-0.00560}}
	{center:{txt}{lalign 20:}{res}{center 15:(5.59)**}}
	{center:{txt}{lalign 20:Turn Circle (ft.) }{res}{center 15:-0.235}}
	{center:{txt}{lalign 20:}{res}{center 15:(1.28)}}
	{center:{txt}{lalign 20:Constant}{res}{center 15:48.13}}
	{center:{txt}{lalign 20:}{res}{center 15:(8.78)**}}
	{center:{txt}{lalign 20:F statistic}{res}{center 15:47.5}}
	{center:{txt}{lalign 20:Adjusted R-squared}{res}{center 15:0.66}}
	{txt}{center:{hline 37}}
	{txt}{center:+ p<0.1; * p<0.05; ** p<0.01}


{pstd}
For additional examples of the use of {cmd:outreg}, see the {help outreg_complete##examples:examples} in the {help outreg_complete:complete outreg} documentation.


{title:Also see}

{psee}
{help outreg_complete:complete outreg}
