{smcl}
{* *! version 1.2  03dec2012}{...}
{cmd:help frmttable}
{hline}

{title:Title}

{p2colset 5 21 23 2}{...}
{pstd}
{hi:frmttable } {hline 1}  A programmer's command to write formatted Word or TeX tables from a matrix of statistics{p_end}
{p2colreset}{...}
   

{title:Syntax}

{p 8 17 2}
{cmd:frmttable}
[{helpb using} {it:filename}]
[{cmd:,} {cmdab:s:tatmat(}{it:string}{cmd:)} {it:options}]

{title:Description}

{pstd}
{cmd:frmttable} is a programmer's command that takes a Stata matrix of statistics and creates a fully-formatted Word or TeX table which can be written to a file.  

{pstd}
The {cmd:frmttable} command normally either uses the {help frmttable##statmat:{bf:statmat}} option with the name of a Stata matrix of statistics to be displayed, or the {help frmt_opts##replay:{bf:replay}} option, 
which causes the existing table in memory to be redisplayed, and possibly written to disk.

{pstd}
{cmd:frmttable} makes available the capability to format Word or TeX tables of statistics in myriad ways without the programmer having to write the code necessary to do the formatting.  
The programmer just needs to write code that calculates statistics, and can leave the formatting chores to {cmd:frmttable}. 

{pstd}
Writing formatted tables directly to word processing files can save researchers a great deal of time.
What researcher has not found that they need to modify their sample in some way after they have already prepared the tables in their research paper?  
{bf:frmttable} provides the means to automatically create fully formatted tables within Stata, saving researchers laborious minutes or hours of manual reformatting each time they make modifications.  
Automatically formatted tables save time principally because researchers usually tweak their tables many times before they are ready in their final form.

{pstd}
{cmd:frmttable} gives the user as complete control of the final document as possible.  
Almost every aspect of the table's structure and formatting can be specified with options.  
Users can change fonts at the table cell level, as well as cell spacing and horizontal and vertical lines.  
{cmd:frmttable} can add various text around the table, including titles, notes below the table, and paragraphs of text above and below.  
Footnotes or other text can be interspersed within the statistics.  

{pstd}
{cmd:frmttable } is the main code behind the {bf:{help outreg}} command, which creates flexible tables of estimation results.

{pstd}
If a {helpb using} {it:filename} is specified, {cmd:frmttable} will create a Microsoft Word file, or a TeX file using the {bf:{help frmttable##tex:tex}} option.  
The table created by {cmd:frmttable} is displayed in the Results window (minus the fancy fonts) unless the {help frmttable##nodisplay:{bf:nodisplay}} option is employed.

{pstd}
Successive sets of statistics can be {help frmt_opts##merge:{bf:merge}}d or {help frmt_opts##append:{bf:append}}ed by {cmd:frmttable} into a single table.  
Additional tables can be written to the same file using the {help frmt_opts##addtable:{bf:addtable}} option, with paragraphs of text in between.  
This makes it possible to create a {cmd:.do} file which writes an entire statistical appendix in final form to a single Word or TeX file, with no subsequent editing required.

{pstd}
{bf:frmttable} converts the Stata matrix of statistics in {bf:statmat}, along with various text additions like titles, into a Mata {bf:{help [M-2] struct:struct}} of string matrices which persists in memory.  
The persistent table data can be reused to merge or append new results, or written to a Word or TeX file with new formatting directives.  
The persistent {bf:frmttable} data can be assigned names, so that multiple tables can be manipulated simultaneously.

{pstd}
This help file provides many {help frmttable##examples:examples of frmttable in use} below the description of the options.


{p2colset 5 30 30 16}{...}
{p2col:Options categories}description{p_end}
{p2line}
{p2col:{it:{help frmttable##stat_for_opts:statistics}}}
statistics and numerical formatting{p_end}
{p2col:{it:{help frmt_opts##text_add_opts:text additions}}}
titles, notes, added rows & columns{p_end}
{p2col:{it:text formatting:}}
{p2colset 7 30 30 16}{p_end}
{p2col:{it:{help frmt_opts##col_form_opts:column formatting}}}
column widths, justification, etc.{p_end}
{p2col:{it:{help frmt_opts##font_opts:fonts}}}
font specifications for table{p_end}
{p2col:{it:{help frmt_opts##lines_spaces_opts:lines & spaces}}}
horizontal and vertical lines, cell spacing{p_end}
{p2colset 5 30 30 16}{...}
{p2col:{it:{help frmt_opts##file_opts:file & display options}}}
tex files, merge, replace, etc.{p_end}
{p2col:{it:{help frmt_opts##brack_opts:brackets options}}}
change brackets around, e.g., {it:t} stats{p_end}
{p2line}

{pstd}
{help frmt_opts##greek:Inline text formatting: superscripts, italics, Greek characters, etc.}{p_end}
{pstd}
{help frmttable##examples:Examples of frmttable in use}{p_end}
{marker stat_for_opts}

{p2colset 5 34 34 0}{...}
{p2col:{it:{help frmttable##stats_formatting:statistics}}}Description{p_end}
{p2line}
{p2col:{help frmttable##statmat:{bf:{ul:s}tatmat(}Stata matrix name{bf:)}}}matrix of statistics for body of table{p_end}
{p2col:{help frmttable##substat:{bf:{ul:sub}stat(}#{bf:)}}}number of substatistics to place below first statistics{p_end}
{p2col:{help frmttable##doubles:{bf:{ul:d}oubles(}{it:Stata matrix name}{bf:)}}}matrix indicating double statistics{p_end}
{p2col:{help frmttable##sdec:{bf:{ul:sd}ec(}numgrid{bf:)}}}decimal places for all statistics{p_end}
{p2col:{help frmttable##sfmt:{bf:{ul:sf}mt(}fmtgrid{bf:)}}}numerical format for all statistics{p_end}
{p2col:{help frmttable##eq_merge:{bf:{ul:eq_merge}}}}merge multi-equation statistics into multiple columns{p_end}
{p2col:{help frmttable##noblankrows:{bf:{ul:nobl}ankrows}}}drop blank rows in table{p_end}
{p2col:{help frmttable##findcons:{bf:{ul:fi}ndconst}}}put _cons in separate section of table{p_end}
{p2line}
{marker text_add_opts}{...}

{p2colset 5 34 34 0}{...}
{p2col:{it:{help frmt_opts##text_additions:text additions}}}Description{p_end}
{p2line}
{p2col:{help frmt_opts##varlabels:{bf:{ul:va}rlabels}}}use variable labels as rtitles{p_end}
{p2col:{help frmt_opts##title:{bf:{ul:t}itle(}{it:textcolumn}{bf:)}}}put title above table{p_end}
{p2col:{help frmt_opts##ctitles:{bf:{ul:ct}itles(}{it:textgrid}{bf:)}}}headings at top of columns{p_end}
{p2col:{help frmt_opts##rtitles:{bf:{ul:rt}itles(}{it:textgrid}{bf:)}}}headings to the left of each row{p_end}
{p2col:{help frmt_opts##note:{bf:{ul:not}e(}{it:textcolumn}{bf:)}}}put note below table{p_end}
{p2col:{help frmt_opts##pretext:{bf:{ul:pr}etext(}{it:textcolumn}{bf:)}}}regular text placed before the table{p_end}
{p2col:{help frmt_opts##posttext:{bf:{ul:po}sttext(}{it:textcolumn}{bf:)}}}regular text placed after the table{p_end}
{p2col:{help frmt_opts##nocoltitl:{bf:{ul:noco}ltitl}}}no column titles{p_end}
{p2col:{help frmt_opts##norowtitl:{bf:{ul:noro}wtitl}}}no row titles{p_end}
{p2col:{help frmt_opts##addrows:{bf:{ul:ad}drows(}{it:textgrid}{bf:)}}}add rows at bottom of table{p_end}
{p2col:{help frmt_opts##addrtc:{bf:{ul:addrt}c(}{it:#}{bf:)}}}number of rtitles columns in addrows{p_end}
{p2col:{help frmt_opts##addcols:{bf:{ul:addc}ols(}{it:textgrid}{bf:)}}}add columns to right of table{p_end}
{p2col:{help frmt_opts##annotate:{bf:{ul:an}notate(}{it:Stata matrix name}{bf:)}}}grid of annotation locations{p_end}
{p2col:{help frmt_opts##asymbol:{bf:{ul:as}ymbol(}{it:textrow}{bf:)}}}symbols for annotations{p_end}
{p2line}
{marker col_form_opts}{...}

{p2colset 5 42 42 0}{...}
{p2col:{it:{help frmt_opts##col_formats:column formatting}}}Description{p_end}
{p2line}
{p2col:{help frmt_opts##colwidth:{bf:{ul:colw}idth(}{it:numlist}{bf:)}}*}change column widths{p_end}
{p2col:{help frmt_opts##multicol:{bf:{ul:mu}lticol(}{it:numtriple}[;{it:numtriple} ...]{bf:)}}}have column titles span multiple columns{p_end}
{p2col:{help frmt_opts##coljust:{bf:{ul:colj}ust(}{it:cjstring}[;{it:cjstring} ...]{bf:)}}}column justification: left, center, right, or decimal{p_end}
{p2col:{help frmt_opts##nocenter:{bf:{ul:noce}nter}}}Don't center table within page{p_end}
{p2line}
{syntab:* Word-only option}
{marker font_opts}{...}

{p2colset 5 40 40 0}{...}
{p2col:{it:{help frmt_opts##fonts:font specification}}}Description{p_end}
{p2line}
{p2col:{help frmt_opts##basefont:{bf:{ul:ba}sefont(}{it:fontlist}{bf:)}}}change the base font for all text{p_end}
{p2col:{help frmt_opts##titlfont:{bf:{ul:titlf}ont(}{it:fontcolumn}{bf:)}}}change font for table title{p_end}
{p2col:{help frmt_opts##ctitlfont:{bf:{ul:ctitlf}ont(}{it:fontgrid}[;{it:fontgrid}...]{bf:)}}}change font for column titles{p_end}
{p2col:{help frmt_opts##rtitlfont:{bf:{ul:rtitlf}ont(}{it:fontgrid}[;{it:fontgrid}...]{bf:)}}}change font for row titles{p_end}
{p2col:{help frmt_opts##statfont:{bf:{ul:statf}ont(}{it:fontgrid}[;{it:fontgrid}...]{bf:)}}}change font for statistics in body of table{p_end}
{p2col:{help frmt_opts##notefont:{bf:{ul:notef}ont(}{it:fontcolumn}{bf:)}}}change font for notes below table{p_end}
{p2col:{help frmt_opts##addfont:{bf:{ul:addf}ont(}{it:fontname}{bf:)}}*}add a new font type{p_end}
{p2col:{help frmt_opts##plain:{bf:{ul:p}lain}}}plain text - one font size, no justification{p_end}
{p2col:{help frmt_opts##table_sections:{it:table sections}}}explanation of formatted table sections{p_end}
{p2line}
{syntab:* Word-only option}
{marker lines_spaces_opts}{...}

{p2colset 5 32 32 0}{...}
{p2col:{it:{help frmt_opts##lines_spaces:border lines and spacing}}}Description{p_end}
{p2line}
{p2col:{help frmt_opts##hlines:{bf:{ul:hl}ines(}{it:linestring}{bf:)}}}horizontal lines between rows{p_end}
{p2col:{help frmt_opts##vlines:{bf:{ul:vl}ines(}{it:linestring}{bf:)}}}vertical lines between columns{p_end}
{p2col:{help frmt_opts##hlstyle:{bf:{ul:hls}tyle(}{it:lstylelist}{bf:)}}*}change style of horizontal lines (e.g. double, dashed){p_end}
{p2col:{help frmt_opts##vlstyle:{bf:{ul:vls}tyle(}{it:lstylelist}{bf:)}}*}change style of vertical lines (e.g. double, dashed){p_end}
{p2col:{help frmt_opts##spacebef:{bf:{ul:spaceb}ef(}{it:spacestring}{bf:)}}}put space above cell contents.{p_end}
{p2col:{help frmt_opts##spaceaft:{bf:{ul:spacea}ft(}{it:spacestring}{bf:)}}}put space below cell contents.{p_end}
{p2col:{help frmt_opts##spaceht:{bf:{ul:spaceht(}}{it:#}{bf:)}}}change size of {opt spacebef} & {opt spaceaft}.{p_end}
{p2line}
{syntab:* Word-only option}
{marker page_fmt_opts}{...}

{p2colset 5 30 30 0}{...}
{p2col:{it:{help frmt_opts##page_fmt:page formatting}}}Description{p_end}
{p2line}
{p2col:{help frmt_opts##landscape:{bf:{ul:la}ndscape}}}pages in landscape orientation{p_end}
{p2col:{help frmt_opts##a4:{bf:{ul:a4}}}}A4 size paper (instead of 8 1/2” x 11”){p_end}
{p2line}
{marker file_opts}{...}

{p2colset 5 32 32 0}{...}
{p2col:{it:{help frmt_opts##file_options:file and display options}}}Description{p_end}
{p2line}
{p2col:{help frmt_opts##tex:{bf:{ul:tex}}}}write a TeX file instead of the default Word file{p_end}
{p2col:{help frmt_opts##merge:{bf:{ul:m}erge}[{bf:(}{it:tblname}{bf:)}]}}merge as new columns to existing table{p_end}
{p2col:{help frmt_opts##replace:{bf:{ul:replace}}}}replace existing file{p_end}
{p2col:{help frmt_opts##addtable:{bf:{ul:addt}able}}}write a new table below an existing table{p_end}
{p2col:{help frmt_opts##append:{bf:{ul:ap}pend}[{bf:(}{it:tblname}{bf:)}]}}append as new rows below an existing table{p_end}
{p2col:{help frmt_opts##replay:{bf:{ul:re}play}[{bf:(}{it:tblname}{bf:)}]}}write preexisting table{p_end}
{p2col:{help frmt_opts##store:{bf:{ul:sto}re(}{it:tblname}{bf:)}}}store table with name "{it:tblname}"{p_end}
{p2col:{help frmt_opts##clear:{bf:{ul:clear}}[{bf:(}{it:tblname}{bf:)}]}}clear existing table from memory{p_end}
{p2col:{help frmt_opts##fragment:{bf:{ul:fr}agment}}**}create TeX code fragment to insert into TeX document{p_end}
{p2col:{help frmt_opts##nodisplay:{bf:{ul:nod}isplay}}}don't display table in results window{p_end}
{p2col:{help frmt_opts##dwide:{bf:{ul:dw}ide}}}display all columns however wide{p_end}
{p2line}
{syntab:** TeX-only option}
{marker brack_opts}{...}

{p2colset 5 43 43 0}{...}
{p2col:{it:{help frmt_opts##brack_options:brackets options}}}Description{p_end}
{p2line}
{p2col:{help frmt_opts##squarebrack:{bf:{ul:sq}uarebrack}}}square brackets instead of parentheses{p_end}
{p2col:{help frmt_opts##brackets:{bf:{ul:br}ackets(}{it:textpair} [ \ {it:textpair} ...]{bf:)}}}symbols with which to bracket substatistics{p_end}
{p2col:{help frmt_opts##nobrket:{bf:{ul:nobrk}et}}}put no brackets on substatistics{p_end}
{p2col:{help frmt_opts##dbldiv:{bf:{ul:dbl}div(}{it:text}{bf:)}}}symbol dividing double statistics ("-"){p_end}
{p2line}

{marker stats_formatting}{...}

{dlgtab:Statistics and numerical formatting}
{marker statmat}{...}

{phang}
{bf:{ul:s}tatmat(}{it:Stata matrix name}{bf:)} names the Stata matrix containing the statistics making up the body of the table.  

{pmore}
If the user has filled {help matrix rownames or colnames} for the Stata matrix, they become the row titles and column titles of the table 
(unless the {help frmt_opts##rtitles:{bf:rtitles}} or {help frmt_opts##ctitles:{bf:ctitles}} options are specified).  
If the rownames and colnames of the {cmd:statmat} matrix are {help varname:varnames}, the option {help frmt_opts##varlabels:{bf:varlabels}} will replace the variable names with their {help label:variable labels}, if they exist.

{pmore}
See an application of {cmd:statmat} in {help frmttable##xmpl1:Example 1}.{p_end}
{marker doubles}{...}

{phang}
{bf:{ul:d}oubles(}{it:Stata matrix name}{bf:)} names the Stata matrix indicating which statistics are "double statistics".  
Double statistics are statistics made up of two numbers like confidence intervals or minimum-maximum ranges.  
The {bf:doubles} option allows the lower and upper numbers to be placed in different columns of the {help frmttable##statmat:{bf:statmat}}, to be combined in the formatted table.

{pmore}
The {bf:doubles} matrix is a row vector with as many elements as columns in {help frmttable##statmat:{bf:statmat}}.  
A 0 specifies that the column is not a second double statistic, and a 1 indicates that it is.  
Thus if {bf:statmat} consists of a matrix with columns containing the means, lower confidence bounds, and upper confidence bounds, of some variables, 
a {bf:doubles} matrix of (0,0,1) would cause the lower and upper confidence bounds to be combined into a single confidence interval.  
The default symbol to separate the lower and upper statistic of double statistics is a dash, but this can be changed with the {help frmt_opts##dbldiv:{bf:dbldiv}} option.{p_end}
{marker sdec}{...}

{phang}
{bf:sdec(}{it:numgrid}{bf:)} specifies the decimal places for the statistics in {help frmttable##statmat:{bf:statmat}}.  
The {opt sdec} {it:numgrid} correponds to the decimal places for each of the statistics in the table. The default number of decimal places is 3.{p_end}

{pmore}
The {it:numgrid} can be a single integer applying to the whole table, or it can be a grid of integers specifying the decimal places for each cell in the table individually.  
A {it:numgrid} is a grid of intergers 0-15 in the form used by {help matrix define:{bf:matrix define}}.  
Commas separate elements along a row, and backslashes ("\") separate rows: {it:numgrid} has the form (#[,#...] [\ #[,#...] [...]]).  
For example, if the table of statistics has three rows and two columns, the {opt sdec(numgrid)} could be {bf:sdec(}1,2 \ 2,2 \ 1,3{bf:)}.  If you specify a grid smaller than the table of statistics, 
the last rows and columns of the {opt sdec} {it:numgrid} will be repeated to cover the whole table.  
So for a 3 by 2 {bf:statmat}, {bf:sdec(}1 \ 2{bf:)} would have the same effect as {bf:sdec(}1,1 \ 2,2 \ 2,2{bf:)}.  
Unbalanced rows or columns will not cause an error.
They will be filled in, and  {cmd:frmttable} will display a warning message.{p_end}
{marker sfmt}{...}

{phang}
{bf:sfmt(}{it:fmtgrid}{bf:)} specifies the numerical format for statistics in {help frmttable##statmat:{bf:statmat}}.  
The {opt sdec} {it:fmtgrid} is a grid of the format types (e, f, g, fc, or gc) for each  statistic in the table.  
The {it:fmtgrid} can be a single format applying to the whole table, or it can specify formats for each cell in the table individually.  

{pmore}
A {it:fmtgrid} is {it:fmt}[,{it:fmt}...] [\ {it:fmt}[,{it:fmt}...] ...]] where {it:fmt} is either e, f, fc, g, or gc:

{p2colset 11 22 37 20}{...}
{p2col:fmt code}format type{p_end}
{p2line}
{p2colset 13 22 37 20}{...}
{p2col:{opt e}}exponential (scientific) notation{p_end}
{p2col:{opt f}}fixed number of decimals{p_end}
{p2col:{opt fc}}fixed with commas for thousands, etc. -  the default{p_end}
{p2col:{opt g}}"general" format (see {bf:{help format}}){p_end}
{p2col:{opt gc}}"general" format with commas for thousands, etc.{p_end}
{p2colset 11 22 37 20}{...}
{p2line}

{pmore}
The "g" formats are not likely to be useful for {cmd:frmttable} tables because they do not allow the user to control the number of decimal places displayed.

{pmore}
If the {it:fmtgrid} has dimensions smaller or bigger than the {bf:statmat} matrix, 
the {it:fmtgrid} is adjusted just as the {it:numgrid} is for {help frmttable ##sdec:{bf:sdec}}.{p_end}
{marker substat}{...}

{phang}
{bf:{ul:sub}stat(}#{bf:)}} indicates the number of "sub"-statistics to be placed in separate rows below the principal statistic.  
For example, if the {bf:statmat} matrix has 3 rows and 4 columns, a {bf:substat(1)} option would interlace the statistics in {help frmttable##statmat:{bf:statmat}} column 2 below those of column 1, 
and statistics in column 4 below those of column 3, resulting in a final table with six rows and two statistics columns.  
This allows the programmer to create a {bf:statmat} with sub-statistics in separate columns from the principal statistics and rely on {bf:frmttable} 
to interlace them (such as {it:t} statistics below regression coefficients or standard deviations below means).

{pmore}
See applications of {cmd:substat} in {help frmttable##xmpl4:Example 4} and {help frmttable##xmpl5:Example 5}.{p_end}
{marker eq_merge}{...}

{phang}
{opt eq_merge} merges the columns of a multi-equation {help frmttable##statmat:{bf:statmat}} matrix into multiple columns, 
one column per equation.  
This option is used by {bf:{help outreg}}, for example, to put the coefficients of each {help sureg} equation side by side instead of stacked vertically.  
The equation statistics are merged as if each of the equations was sequentially combined with the {help fmrt_opts##merge:{bf:merge}} option.{p_end}

{pmore}
{bf:frmttable} identifies the equations in {bf:statmat} by {help matrix rownames:{bf:roweq}} names.  
All rows of {bf:stamat} with the same {bf:roweq} name is considered to be an equation.  
If no {bf:roweq}s are assigned, {bf:frmttable} takes all rows to belong to the same (unnamed) equation.
{opt eq_merge} is an option whose main purpose is to help {bf:{help outreg}} reorganize multi-equation estimation results.{p_end}
{marker noblankrows}{...}

{phang}
{bf:{ul:nobl}ankrows} deletes completely blank rows in the body of the formatted table. 
A blank row is one where the data are missing in every column.{p_end}
{marker findcons}{...}

{phang}
{bf:{ul:fi}ndcons} finds table rows with a row title of "_cons" and assigns them to a separate {help frmt_opts##table_sections:row section} which is kept below the other row sections.  
This option is useful for merging statistical results like regression coefficients, 
where you want to ensure that the constant coefficient estimates are reported below all other coefficients even when the user merges additional statistics containing new variables.  

{pmore}
This option is rarely used.{p_end}
{marker examples}{...}


{title:Examples}

   1.  {help frmttable ##xmpl1:Basic usage}.
   2.  {help frmttable ##xmpl2:Merge and append}.
   3.  {help frmttable ##xmpl3:Multi-column titles, border lines, fonts}.
   4.  {help frmttable ##xmpl4:Add stars for significance to regression output: substatistics and annotate}.
   5.  {help frmttable ##xmpl5:Make a table of summary statistics & merge it with a regression table}.
   6.  {help frmttable ##xmpl6:Create complex tables using merge and append}.
   7.  {help frmttable ##xmpl7:Double statistics}.
   {marker xmpl1}

{title:Example 1: basic usage}

{pstd}
The basic role of {bf:frmttable} is to take statistics in a Stata matrix and organize them in a table 
that is displayed in the Results window and can be written to a file as a Word table or a TeX table.

{pstd}
First, we create a 2x2 Stata matrix named A:

	{com}. mat A = (100,50\0,50)
	{com}. mat list A
	{res}
	{txt}A[2,2]
	     c1   c2
	r1 {res} 100   50
	{txt}r2 {res}   0   50
	{reset}
{pstd}
The simplest usage of the {bf:frmttable} command is to display the matrix A:

	{com}. frmttable, statmat(A)
	{res}
	{txt}{center:{hline 17}}
	{center:{res}{center 8:100.00}{res}{center 7:50.00}}
	{center:{res}{center 8:0.00}{res}{center 7:50.00}}
	{txt}{center:{hline 17}}

{pstd}
This doesn't get us very far.  
The reason {bf:frmttable} is useful is that it can make extensive adjustments to the formatting of the table, and write the result to a Word or TeX document.  

{pstd}
The {bf:frmttable} command below has a {bf:using} statement followed by a file name ("xmpl1").  
This causes the table to be written to a Word document "xmpl1.doc".  
Word documents are the default; the table would be written as a TeX document with the {bf:tex} option.

{pstd}
The {bf:frmttable} statement below adds a number of options.  
The first, {bf:sdec}, sets the number of decimal places displayed for the statistics in {bf:statmat} to 0. 
The next three options, {bf:title}, {bf:ctitle}, and {bf:rtitle} add an overall title to the table, titles above each column of the table, and titles on the left of each row of the table, respectively.  
The column and row titles are designated with the syntax used for matrices: commas separate columns, and backslashes separate rows.

	{com}. frmttable using xmpl1, statmat(A) sdec(0) title("Payoffs")   ///
	     ctitle("","Game 1","Game 2") rtitle("Player 1"\"Player 2")
	
	{txt}{center:Payoffs}
	{txt}{center:{hline 28}}
	{center:{txt}{lalign 10:}{txt}{center 8:Game 1}{txt}{center 8:Game 2}}
	{txt}{center:{hline 28}}
	{center:{txt}{lalign 10:Player 1}{res}{center 8:100}{res}{center 8:50}}
	{center:{txt}{lalign 10:Player 2}{res}{center 8:0}{res}{center 8:50}}
	{txt}{center:{hline 28}}
{marker xmpl2}{...}

{title:Example 2: merge and append}

{pstd}
Once {bf:frmttable} is run, the table created stays in memory (as a {bf:{help [M-2] struct:struct}} of Mata string matrices).  
Subsequent statistical results can be {bf:{help frmt_opts##merge:merge}}d as new columns of the table or {bf:{help frmt_opts##append:append}}ed as new rows.  
The merged columns are arranged so that the new row titles are matched with the existing table's row titles, 
and rows with unmatched titles are placed below the other statistics (similar to the way the Stata {bf:{help merge}} command matches observations of the merged dataset).   

{pstd}
The {bf:frmttable} command below merges a new column of statistics for players 1 and 3 to the existing {bf:frmttable} table, already created in the previous example.  

	. mat B = (25\75)
	{txt}
	{com}. frmttable, statmat(B) sdec(0)   ///
	     ctitle("","Game 3") rtitle("Player 1"\"Player 3") merge 
	{res}
	{txt}{center:Payoffs}
	{txt}{center:{hline 36}}
	{center:{txt}{lalign 10:}{txt}{center 8:Game 1}{txt}{center 8:Game 2}{txt}{center 8:Game 3}}
	{txt}{center:{hline 36}}
	{center:{txt}{lalign 10:Player 1}{res}{center 8:100}{res}{center 8:50}{res}{center 8:25}}
	{center:{txt}{lalign 10:Player 2}{res}{center 8:0}{res}{center 8:50}{res}{center 8:}}
	{center:{txt}{lalign 10:Player 3}{res}{center 8:}{res}{center 8:}{res}{center 8:75}}
	{txt}{center:{hline 36}}
	
{pstd}
In this case, the new statistics in matrix B are arranged according to the row titles in the {bf:rtitle} option.  
The statistics in the first row of B for "Player 1" are lined up with the statistics for "Player 1" in the existing table, while the statistics for "Player 3" are placed below "Player 2" because "Player 3" is a new row title.

{pstd}
The text of the row titles must match exactly for the merged results to be placed in the same row.  
Row titles of "Player 1" and "player 1" do not match, so they would be placed in different rows.

{pstd}
Next we add another column to the table for new game results.

	{com}. mat C = (90\10)
	{txt}
	{com}. frmttable, statmat(C) sdec(0) ///
	     ctitle("","Game 4") rtitle("Player 2"\"Player 4") merge 
	{res}
	{txt}{center:Payoffs}
	{txt}{center:{hline 44}}
	{center:{txt}{lalign 10:}{txt}{center 8:Game 1}{txt}{center 8:Game 2}{txt}{center 8:Game 3}{txt}{center 8:Game 4}}
	{txt}{center:{hline 44}}
	{center:{txt}{lalign 10:Player 1}{res}{center 8:100}{res}{center 8:50}{res}{center 8:25}{res}{center 8:}}
	{center:{txt}{lalign 10:Player 2}{res}{center 8:0}{res}{center 8:50}{res}{center 8:}{res}{center 8:90}}
	{center:{txt}{lalign 10:Player 3}{res}{center 8:}{res}{center 8:}{res}{center 8:75}{res}{center 8:}}
	{center:{txt}{lalign 10:Player 4}{res}{center 8:}{res}{center 8:}{res}{center 8:}{res}{center 8:10}}
	{txt}{center:{hline 44}}
	
{pstd}
The statistics for "Player 2" and "Player 4" are merged: the statistics for "Player 2" are lined up with previous results for "Player 2" and statistics for the new row title, "Player 4", are placed below the other rows.

{pstd}
Finally, we {bf:append} new {it:rows} to the table, for the total payoffs.

	{com}. mat D = (100,100,100,100)
	{txt}
	{com}. frmttable, statmat(D) sdec(0) rtitle("Total") append
	{res}
	{txt}{center:Payoffs}
	{txt}{center:{hline 44}}
	{center:{txt}{lalign 10:}{txt}{center 8:Game 1}{txt}{center 8:Game 2}{txt}{center 8:Game 3}{txt}{center 8:Game 4}}
	{txt}{center:{hline 44}}
	{center:{txt}{lalign 10:Player 1}{res}{center 8:100}{res}{center 8:50}{res}{center 8:25}{res}{center 8:}}
	{center:{txt}{lalign 10:Player 2}{res}{center 8:0}{res}{center 8:50}{res}{center 8:}{res}{center 8:90}}
	{center:{txt}{lalign 10:Player 3}{res}{center 8:}{res}{center 8:}{res}{center 8:75}{res}{center 8:}}
	{center:{txt}{lalign 10:Player 4}{res}{center 8:}{res}{center 8:}{res}{center 8:}{res}{center 8:10}}
	{center:{txt}{lalign 10:Total}{res}{center 8:100}{res}{center 8:100}{res}{center 8:100}{res}{center 8:100}}
	{txt}{center:{hline 44}}
	
{pstd}
Whereas the {bf:{help frmt_opts##merge:merge}} option created new table columns, the {bf:{help frmt_opts##append:append}} option places new statistics in rows below the existing table.  
If the matrix D had had more or less than 4 columns, it would still be appended below the existing results, but with a warning message.  
The arrangement of the {bf:append}ed results does not depend on the column titles (unlike the way {bf:merge} depends on the row titles).  
In fact, the {bf:ctitles} of the appended data are ignored if they are specified.

{pstd}
An alternative way of adding rows and columns is with the options {bf:{help frmt_opts##addrows:addrows}} and {bf:{help frmt_opts##addcols:addcols}}.  
{bf:merge} and {bf:append} add matrices of numbers to a previously created table; {bf:addrow} and {bf:addcol} add on rows and columns of text (which can include numbers) to the table currently being created.  

{pstd}
The following set of commands will create the same table as above, but uses the {bf:addrows} option to attach the column totals as text instead of {bf:append}ing a Stata matrix:

	{com}. mat E = (100,50,25,. \ 0,50,.,90 \ .,.,75,. \ .,.,.,10)
	{txt}
	{com}. frmttable, statmat(E) sdec(0) addrows("Total", "100", "100", "100", "100") ///
	     rtitles("Player 1" \ "Player 2" \ "Player 3" \ "Player 4")	///
	     ctitles("", "Game 1", "Game 2", "Game 3", "Game 4") 			///
	     title("Payoffs")
	{res}
	{txt}{center:Payoffs}
	{txt}{center:{hline 44}}
	{center:{txt}{lalign 10:}{txt}{center 8:Game 1}{txt}{center 8:Game 2}{txt}{center 8:Game 3}{txt}{center 8:Game 4}}
	{txt}{center:{hline 44}}
	{center:{txt}{lalign 10:Player 1}{res}{center 8:100}{res}{center 8:50}{res}{center 8:25}{res}{center 8:}}
	{center:{txt}{lalign 10:Player 2}{res}{center 8:0}{res}{center 8:50}{res}{center 8:}{res}{center 8:90}}
	{center:{txt}{lalign 10:Player 3}{res}{center 8:}{res}{center 8:}{res}{center 8:75}{res}{center 8:}}
	{center:{txt}{lalign 10:Player 4}{res}{center 8:}{res}{center 8:}{res}{center 8:}{res}{center 8:10}}
	{center:{txt}{lalign 10:Total}{res}{center 8:100}{res}{center 8:100}{res}{center 8:100}{res}{center 8:100}}
	{txt}{center:{hline 44}}
	{marker xmpl3}{...}

{title:Example 3: multi-column titles, border lines, fonts}

{pstd}
Many formatting options are available in {bf:frmttable}. 
This example makes some of the column titles span multiple columns, places a vertical line in the table, and changes the font size and typeface.

{pstd}
{bf:frmttable} can change many other aspects of the tables it creates, such as  footnotes and other annotations among the statistics, justification of columns, and spacing above and below table cells.  
You can find additional information of several {bf:frmttable} formatting options in examples of the {bf:outreg} command related to {help outreg_complete##xmpl11:fonts}, 
{help outreg_complete##xmpl12:special characters}, {help outreg_complete##xmpl13:multiple tables in the same document}, and {help outreg_complete##xmpl14:footnotes}.

{pstd}
In the Stata code below, the {bf:frmttable} table is created from data in the matrix F.  
Where F contains missing values, the table cells will be blank.  

{pstd}
The table's column titles in the {bf:ctitles} option have two rows and the first row of titles are meant to span two columns each.  
They are made to span multiple columns with the {help frmt_opts##multicol:{bf:multicol(}1,2,2;1,4,2{bf:)}} option.  
The two triples of numbers, 1,2,2 and 1,4,2, indicate which table cells span more than one column.  
1,2,2 indicates that the first row, second column of the table should span two columns, and the 1,4,2 indicates that the first row, fourth column of the table should span two columns.

{pstd}
A dashed vertical line is placed in the table separating the row titles from the statistics.  
The {help frmt_opts##vlines:{bf:vlines(}010{bf:)}} option where the vertical line or lines are placed.  
A 0 indicates no line, and a 1 indicates a line.  
The 010 means no line to the left of the first cell (or column), a vertical line between the first and second cell and no line between the second the third cell.  
Since the table has more than two columns, the "no line" specification is extended to all the rest of the columns.
The {help frmt_opts##vlstyle:{bf:vlstyle(}a{bf:)}} option changes the line style from the default of a solid line to a dashed line.

{pstd}
The last option, {bf:basefont(}arial fs10{bf:)}, changes the font of the Word table to be Arial font, with a base font size of 10 points (the table's title has larger text and the notes have smaller text).  

	{com}. mat F = (100,50,25,. \ 0,50,.,90 \ .,.,75,. \ .,.,.,10 \ 100,100,100,100)
	{txt}
	{com}. frmttable using xmpl3, statmat(F) sdec(0) title("Payoffs") replace     ///
	     ctitles("", "{c -(}\ul Day 1{c )-}", "", "{c -(}\ul Day 2{c )-}" ,"" \                  ///
	         "", "Game 1", "Game 2", "Game 3", "Game 4")                     ///
	     multicol(1,2,2;1,4,2)                                               ///
	     rtitles("Player 1" \ "Player 2" \ "Player 3" \ "Player 4" \ "Total") ///
	     vlines(010) vlstyle(a) basefont(arial fs10)
	{txt}({it:output omitted})

{pstd}
The table created in this example is not shown because most of its features (font, vertical lines, etc.) appear correctly only in the Word table created, not in the Stata Results window.{p_end}{...}
{marker xmpl4}
{title:Example 4: Add stars for significance to regression output: substatistics and annotate}

{pstd}
The following Stata commands create a matrix, {bf:b_se}, containing regression coefficients in the first column and standard errors of estimates in the second column:

	{com}. sysuse auto, clear
	{com}. regress mpg length weight headroom
	{txt}({it:output omitted})
	
	{com}. matrix b_se = get(_b)', vecdiag(cholesky(diag(vecdiag(get(VCE)))))'
	{com}. matrix colnames b_se = mpg mpg_se
	{com}. mat li b_se
	{res}
	{txt}b_se[4,2]
	                 mpg      mpg_se
	  length {res} -.07849725   .05699153
	{txt}  weight {res} -.00385412   .00159743
	{txt}headroom {res} -.05143046   .55543717
	{txt}   _cons {res}  47.840789   6.1492834
	{reset}

{pstd}
{bf:frmttable} will then convert this matrix into a formatted table.
The {bf:substat(1)} option informs {bf:frmttable} that the second column of statistics, the standard errors, should be place below the first column of statistics, the coefficients, in the table.  
If the option had been {bf:substat(2)}, the second and third columns of statistics would be interweaved below the statistics in the first column of {bf:statmat}.

{pstd}
In the absence of {bf:rtitles} and {bf:ctitles}, {bf:frmttable} uses the matrix rownames and colnames of {bf:b_se} as the row and column titles for the table.

	{com}. frmttable, statmat(b_se) substat(1) sdec(3)
	{res}
	{txt}{center:{hline 21}}
	{center:{txt}{lalign 10:}{txt}{center 9:mpg}}
	{txt}{center:{hline 21}}
	{center:{txt}{lalign 10:length}{res}{center 9:-0.078}}
	{center:{txt}{lalign 10:}{res}{center 9:(0.057)}}
	{center:{txt}{lalign 10:weight}{res}{center 9:-0.004}}
	{center:{txt}{lalign 10:}{res}{center 9:(0.002)}}
	{center:{txt}{lalign 10:headroom}{res}{center 9:-0.051}}
	{center:{txt}{lalign 10:}{res}{center 9:(0.555)}}
	{center:{txt}{lalign 10:_cons}{res}{center 9:47.841}}
	{center:{txt}{lalign 10:}{res}{center 9:(6.149)}}
	{txt}{center:{hline 21}}
	
{pstd}
Stars indicating significance levels can be placed next to the standard errors using the {bf:annotate} option.  
First it is necessary to create a Stata matrix indicating the cells to which the stars should be added. 
The matrix, named {bf:stars} below, has a 1 in the second row, second column, and a 2 in the fourth row, second column, since the second and fourth coefficients are statistically significant.
	
	{com}. local bc = rowsof(b_se)
	{com}. matrix stars = J(`bc',2,0)
	{com}. forvalues k = 1/`bc' {c -(}
	{com}.     matrix stars[`k',2] =   ///
	          (abs(b_se[`k',1]/b_se[`k',2]) > invttail(`e(df_r)',0.05/2)) +   ///
	          (abs(b_se[`k',1]/b_se[`k',2]) > invttail(`e(df_r)',0.01/2))
	{com}. {c )-}
	{com}. mat list stars
	{res}
	{txt}stars[4,2]
	    c1  c2
	r1 {res}  0   0
	{txt}r2 {res}  0   1
	{txt}r3 {res}  0   0
	{txt}r4 {res}  0   2
	{reset}
{pstd}
The entries of 1 and 2 in {bf:stars} correspond to the first and second entry of the {bf:asymbol(*,**)} option, adding a single star to the cell where the 1 is, and a double star in the cell where the 2 is.  
All the elements in {bf:stars} equal to 0 will have no symbols added.  
The dimensions of {bf:stars} (4x2) corresponds to the dimensions of the {bf:statmat} matrix, not the dimensions of the statistics in the final table (8x1), 
which has a single statistics column due to the {bf:substat(1)} option.

{pstd}
The option {bf:varlabels} causes the variable labels for the variables {bf:mpg}, {bf:length}, {bf:weight}, and {bf:headroom} to be substituted for their names.

	{com}. frmttable using xmpl4, statmat(b_se) substat(1) sdec(3) ///
	     annotate(stars) asymbol(*,**) varlabels
	{res}
	{txt}{center:{hline 33}}
	{center:{txt}{lalign 16:}{txt}{center 15:Mileage (mpg)}}
	{txt}{center:{hline 33}}
	{center:{txt}{lalign 16:Length (in.)}{res}{center 15:-0.078}}
	{center:{txt}{lalign 16:}{res}{center 15:(0.057)}}
	{center:{txt}{lalign 16:Weight (lbs.)}{res}{center 15:-0.004}}
	{center:{txt}{lalign 16:}{res}{center 15:(0.002)*}}
	{center:{txt}{lalign 16:Headroom (in.)}{res}{center 15:-0.051}}
	{center:{txt}{lalign 16:}{res}{center 15:(0.555)}}
	{center:{txt}{lalign 16:Constant}{res}{center 15:47.841}}
	{center:{txt}{lalign 16:}{res}{center 15:(6.149)**}}
	{txt}{center:{hline 33}}
	

{pstd}
The code above implements the most basic capabilities of {bf:{help outreg}}, so the same table can more easily be created by 
	
	{com}. outreg, se varlabels
	{reset}{marker xmpl5}
{title:Example 5: make a table of summary statistics & merge it with a regression table}

{pstd}
First we create a Stata matrix containing summary statistics for four variables, {bf:length}, {bf:weight}, {bf:headroom}, {bf:mpg}.  
The first column of the matrix {bf:mean_sd} contains the means and the second column contains the standard deviations.  
The statistics are calculated by the {bf:{help summarize}} command, looping over the variables using the {bf:{help foreach}} command.

	{com}. mat mean_sd = J(4,2,.)
	{com}. local i = 1
	{com}. foreach v in length weight headroom mpg {c -(}
	{com}.         summarize `v' 
	{com}.         mat mean_sd[`i',1] = r(mean)
	{com}.         mat mean_sd[`i',2] = r(sd)
	{com}.         local i = `i' + 1
	{com}. {c )-}
	{txt}({it:output omitted})

	{com}. matrix rownames mean_sd = length weight headroom mpg
	{com}. matrix list mean_sd
	{res}
	{txt}mean_sd[4,2]
	                 c1         c2
	  length {res} 187.93243   22.26634
	{txt}  weight {res} 3019.4595  777.19357
	{txt}headroom {res} 2.9932432  .84599477
	{txt}     mpg {res} 21.297297  5.7855032
	{reset}
{pstd}
We can create a formatted table with this matrix of statistics, and we can also merge these statistics into any other table created by {bf:frmttable} (or by commands which call {bf:frmttable}, like {bf:outreg}).  
The command below {bf:merge}s the summary statistics with the table of regression coefficients created in the previous example.

	{com}. frmttable, statmat(mean_sd) substat(1) varlabels ///
	     ctitles("", Summary statistics) merge
	{res}{txt}(note: tables being merged have different numbers of row sections)

	{txt}{center:A Regression}
	{txt}{center:{hline 53}}
	{center:{txt}{lalign 16:}{txt}{center 15:Mileage (mpg)}{txt}{center 20:Summary statistics}}
	{txt}{center:{hline 53}}
	{center:{txt}{lalign 16:Length (in.)}{res}{center 15:-0.078}{res}{center 20:187.93}}
	{center:{txt}{lalign 16:}{res}{center 15:(0.057)}{res}{center 20:(22.27)}}
	{center:{txt}{lalign 16:Weight (lbs.)}{res}{center 15:-0.004}{res}{center 20:3,019.46}}
	{center:{txt}{lalign 16:}{res}{center 15:(0.002)*}{res}{center 20:(777.19)}}
	{center:{txt}{lalign 16:Headroom (in.)}{res}{center 15:-0.051}{res}{center 20:2.99}}
	{center:{txt}{lalign 16:}{res}{center 15:(0.555)}{res}{center 20:(0.85)}}
	{center:{txt}{lalign 16:Mileage (mpg)}{res}{center 15:}{res}{center 20:21.30}}
	{center:{txt}{lalign 16:}{res}{center 15:}{res}{center 20:(5.79)}}
	{center:{txt}{lalign 16:Constant}{res}{center 15:47.841}{res}{center 20:}}
	{center:{txt}{lalign 16:}{res}{center 15:(6.149)**}{res}{center 20:}}
	{center:{txt}{lalign 16:R2}{res}{center 15:0.66}{res}{center 20:}}
	{center:{txt}{lalign 16:N}{res}{center 15:74}{res}{center 20:}}
	{txt}{center:{hline 53}}
	{txt}{center:* p<0.05; ** p<0.01}
	{reset}
	
{pstd}
This example shows how {bf:frmttable} works, but a user can already create a table similar to this with the following commands:

	{com}. regress mpg length weight headroom
	{com}. outreg, se varlabels
	{com}. mean length weight headroom mpg
	{com}. outreg, se varlabels merge
	{reset}{marker xmpl6}{...}
	
{title:Example 6: create complex tables using merge and append}

{pstd}
If you use {bf:frmttable} to handle the output from a new command you write, users of your command can build quite complex tables by repeatedly executing your command, 
along with {bf:frmttable}'s {bf:{help frmt_opts##merge:merge}} and {bf:{help frmt_opts##append:append}} options.  
In this exercise we use {bf:{help outreg}} as an example of a {bf:frmttable}-based command to build a table from parts.

{pstd}
Say we wanted to create a table showing how a car's weight affects its mileage.  We want the table to be broken down by foreign vs. domestic cars, and by three categories of headroom.
It is easy with a {bf:frmttable}-based command like {bf:outreg} to create six separate tables with all of these results.  
It is also easy to create a single table with six columns (or six rows) of coefficients using straightforward application of the {bf:merge} (or {bf:append}) options.

{pstd}
It is more complicated to create a table with three columns of foreign estimates above three columns of domestic estimates.  
The results for foreign cars must be merged across the headroom categories into one table, and the results for the domestic cars merged into a {it:separate} table.  The two tables must then be appended one below the other.  
Creating two separate {bf:frmttable} tables simultaneously requires the use of table names.  

{pstd}
The statistics for the table in this example are created in a double {bf:{help foreach}} loop, iterating first over foreign vs. domestic, and then over three categories of headroom.  
Using data from {bf:auto.dta}, we first recode the variable {bf:headroom} into a new variable {bf:hroom} with just 3 levels.

	{com}. sysuse auto, clear
	{txt}(1978 Automobile Data)

	{com}. recode headroom (1.5=2) (3.5/5=3), gen(hroom)
	{txt}(34 differences between headroom and hroom)

{pstd}
Ignore the {bf:outreg, clear} commands below for the moment:

	{com}. outreg, clear(row1)
	{com}. outreg, clear(row2)
	{reset}
{pstd}
The heart of the table building occurs with a double {bf:foreach} loop, iterating over {bf:foreign} and {bf:hroom} values.  
We estimate the correlation of {bf:mpg} with {bf:weight} using the {bf:{help regress}} command for each category in the double loop.  
The formatted table is built up using the {bf:outreg, merge} command repeatedly.  

	{com}. foreach f in 0 1 {c -(}
	{com}     foreach h in 2 2.5 3 {c -(}
	{com}        regress mpg weight if foreign==`f' & hroom==`h'
	{com}        outreg, nocons noautosumm merge(row`f')
	{com}     {c )-}
	{com}  {c )-}
	{txt}({it:output omitted})

{pstd}
The {bf:{help outreg}} command has options {bf:{help outreg_complete##nocons:nocons}} to suppress the constant coefficient and {bf:{help outreg_complete##noautosumm:noautosumm}} to suppress the R-squared and number of observations.  
The {bf:{help frmt_opts##merge:merge}(row`f')} option is the interesting part.  
This merges the coefficients into two separate tables, named {bf:row0} and {bf:row1}, each of which contains three columns of estimates for the categories of {bf:hroom}.

{pstd}
The first time the {bf:merge} option is invoked for each table, we want it to create the first column: to merge the results onto a table which doesn't yet exist.  
The {bf:merge} option allows merging onto a non-existent table, for convenience in loops like this.  
However, to make this work, it is important to clear out any pre-existing table of the same name.  
Particularly, we want to clear out the table from the previous time we ran the same {bf:.do} file.  
Otherwise, the table would get larger and larger each time the {bf:.do} file is run.  
That is the reason for the two {bf:{help frmt_opts##clear:outreg, clear}} commands just before the loop.  
An alternative to the {bf:outreg, clear} command, especially if one needs to clear many {bf:frmttable} tables, is {bf:{help mata clear:mata: mata clear}} which clears all Mata memory structures, including the tables.

{pstd}
Now that the tables for each row are created, we want to append them one below the other.  
We do this with a combination of the {bf:{help frmt_opts##replay:replay}} and {bf:{help frmt_opts##append:append}} options.  
The {bf:replay(row0)} option displays the named table (and can write it to a word processing document if {bf:using} is specified).  
{bf:append(row1)} option appends the table {bf:row1} containing the second row below the {bf:row0} results.  
The rest of the {bf:outreg} command below adds titles to the final table.  
Note that the combined table now has table name {bf:row0}.

	{com}. outreg, replay(row0) append(row1) replace ///
	     rtitle(Domestic \ "" \ Foreign) ///
	     ctitle("", "", "Headroom", "" \ "Origin", "<=2.0", "2.5", ">=3.0") ///
	     title(Effect of weight on MPG by origin and headroom)
	{res}
	{txt}{center:Effect of weight on MPG by origin and headroom}
	{txt}{center:{hline 43}}
	{center:{txt}{lalign 11:}{txt}{center 10:}{txt}{center 10:Headroom}{txt}{center 10:}}
	{center:{txt}{lalign 11:Origin}{txt}{center 10:<=2.0}{txt}{center 10:2.5}{txt}{center 10:>=3.0}}
	{txt}{center:{hline 43}}
	{center:{txt}{lalign 11:Domestic }{res}{center 10:-0.006}{res}{center 10:-0.007}{res}{center 10:-0.005}}
	{center:{txt}{lalign 11:}{res}{center 10:(3.62)**}{res}{center 10:(7.63)*}{res}{center 10:(8.00)**}}
	{center:{txt}{lalign 11:Foreign}{res}{center 10:-0.018}{res}{center 10:-0.008}{res}{center 10:-0.011}}
	{center:{txt}{lalign 11:}{res}{center 10:(1.87)}{res}{center 10:(2.14)}{res}{center 10:(2.64)*}}
	{txt}{center:{hline 43}}
	
{pstd}
This example shows how elaborate tables can be created by combining smaller parts using the {bf:merge} and {bf:append} options and table names.  
Other useful options for this purpose are {bf:addrows} and {bf:addcols}, which add columns of text (which may include numbers) rather than statistics from Stata matrices.{p_end}
{marker xmpl7}{...}

{title:Example 7: double statistics}

{pstd}
Double statistics are statistics showing two numbers, such as a minimum-maximum range, or a confidence interval.  
{bf:frmttable} has the {bf:doubles} option to make it easy to display them.  
The lower and upper value of double statistics are held in neighboring columns of {bf:statmat}, and the {bf:doubles} option indicates which columns are the second column of a double statistic.  
{bf:frmttable} automatically combines the two numbers into as single cell of the formatted table, with a dash in between them.  

{pstd}
The following code creates a Stata matrix {bf:conf_int}, containing the mean of several variables in the first column, and the lower and upper confidence intervals in the second and third columns, respectively.  
The details are similar to {help frmttable##xmpl5:Example 5} above.

	{com}. mat conf_int = J(4,3,.)
	{com}. local i = 1
	{com}. foreach v in length weight headroom mpg {c -(}
	{com}     summ `v' 
	{com}     mat conf_int[`i',1] = r(mean)
	{com}     mat conf_int[`i',2] = r(mean) - invttail(r(N)-1,0.05/2)*sqrt(r(Var)/r(N))
	{com}     mat conf_int[`i',3] = r(mean) + invttail(r(N)-1,0.05/2)*sqrt(r(Var)/r(N))
	{com}     local i = `i' + 1
	{com}  {c )-}
	{txt}({it:output omitted})

	{com}. matrix rownames conf_int = length weight headroom mpg
	{com}. mat li conf_int

	{txt}conf_int[4,3]
	                 c1         c2         c3
	  length {res} 187.93243  182.77374  193.09113
	{txt}  weight {res} 3019.4595  2839.3983  3199.5206
	{txt}headroom {res} 2.9932432  2.7972422  3.1892443
	{txt}     mpg {res} 21.297297  19.956905   22.63769
{reset}
{pstd}
For {bf:frmttable} to display double statisics, it requires a row vector indicating which columns contain the second numbers of double statistics.  
In this example, there are second values of a double statistic in column 3, so the third element of the {bf:doubles} option matrix {bf:dcols} is set to 1.
The {bf:doubles(dcols)} option causes the numbers in the second and third columns of {bf:conf_int} (the lower and upper confidence limits) to be combined in the final table.

	{com}. matrix dcols = (0,0,1)
	{com}. frmttable, statmat(conf_int) substat(1) doubles(dcols) varlabels ///
	    ctitles("",Summary statistics) sdec(0 \ 0 \ 0 \ 0 \ 2 \ 2 \ 1 \ 1)      
	{res}
	{txt}{center:{hline 38}}
	{center:{txt}{lalign 16:}{txt}{center 20:Summary statistics}}
	{txt}{center:{hline 38}}
	{center:{txt}{lalign 16:Length (in.)}{res}{center 20:188}}
	{center:{txt}{lalign 16:}{res}{center 20:(183 - 193)}}
	{center:{txt}{lalign 16:Weight (lbs.)}{res}{center 20:3,019}}
	{center:{txt}{lalign 16:}{res}{center 20:(2,839 - 3,200)}}
	{center:{txt}{lalign 16:Headroom (in.)}{res}{center 20:2.99}}
	{center:{txt}{lalign 16:}{res}{center 20:(2.80 - 3.19)}}
	{center:{txt}{lalign 16:Mileage (mpg)}{res}{center 20:21.3}}
	{center:{txt}{lalign 16:}{res}{center 20:(20.0 - 22.6)}}
	{txt}{center:{hline 38}}

{pstd}
Note that there is only one substatistic in {bf:substat(1)} since the second statistic is a double statistic.

{pstd}
Confidence intervals have been integrated into the {bf:outreg} command, making use of {bf:frmttable}'s {bf:doubles} option, so that the particular table in this example is easily created with the following commands:

	{com}. mean length weight headroom mpg
	{com}. outreg, stats(b,ci) nostars varlabels ctitles("",Summary statistics) bdec(0 0 2 1)
{reset}
{title:Author}

	John Luke Gallup, Portland State University, USA
	jlgallup@pdx.edu

{title:Also see}
{psee}
{bf:{help outreg}}, {bf:{search outtable,all:outtable}}
