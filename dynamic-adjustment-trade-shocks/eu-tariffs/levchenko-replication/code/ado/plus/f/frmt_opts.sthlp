{smcl}
{* *! version 1.1  14mar2013}{...}
{cmd:help frmt_opts}
{hline}

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
{p2col:{help frmt_opts##vlines:{bf:{ul:vl}ines(}{it:linestring}{bf:)}}}verticle lines between columns{p_end}
{p2col:{help frmt_opts##hlstyle:{bf:{ul:hls}tyle(}{it:lstylelist}{bf:)}}*}change style of horizontal lines (e.g. double, dashed){p_end}
{p2col:{help frmt_opts##vlstyle:{bf:{ul:vls}tyle(}{it:lstylelist}{bf:)}}*}change style of verticle lines (e.g. double, dashed){p_end}
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

{pstd}
{help frmt_opts##greek:Inline text formatting: superscripts, italics, Greek characters, etc.}{p_end}


{marker text_additions}{...}
{dlgtab:Text additions}
{marker varlabels}{...}

{phang}
{bf:{ul:va}rlabels} replaces variable names with {help label:variable labels} in row and column titles, if the variable labels exist.  For example, if using the {opt auto.dta} data set, {opt varlabel} gives a coefficient for the {opt mpg} variable the row title "Mileage (mpg)" instead of "mpg". 
{opt varlabels} also replaces "_cons" with "Constant" for constant coefficients.{p_end}

{phang}
{it:{ul:Text structures used for titles}}{p_end}
{marker textcolumn}{...}
{phang2}
{it:textcolumn} is  "{it:string}" [\"{it:string}"...]{p_end}
{marker textrow}{...}
{phang2}
{it:textrow} is  "{it:string}" [,"{it:string}"...]{p_end}
{marker textgrid}{...}
{phang2}
{it:textgrid} is  "{it:string}" [,"{it:string}"...] [\ "{it:string}"[,"{it:string}"...] [\ [...]]] or a {it:textrow} or a {it:textcolumn} as a special case{p_end}
{phang2}
"{it:string}" ["{it:string}" ...] will often work in place of a {it:textrow} or a {it:textcolumn} when the user's intent is clear, but if in doubt use the proper {it:textrow} or {it:textcolumn} syntax above.{p_end}
{marker title}{...}

{phang}
{cmd:title(}{it:{help frmt_opts##textcolumn:textcolumn}}{cmd:)} specifies a title or titles above the table.  
Subtitles should be separated from the primary titles by backslashes ("\"), like this: {bf:title(}"Main Title" \ "First Sub-Title" \ "Second Sub-Title"{bf:)}.  
By default, titles are set in a larger font than the body of the table.  
If title text does not contain backslashes, you can dispense with the quotation marks, but if in doubt, include them.{p_end}
{marker ctitles}{...}

{phang}
{cmd:ctitles(}{it:{help frmt_opts##textgrid:textgrid}}{cmd:)} specifies the column titles above the statistics.
A simple form of {cmd:ctitles} is, for example, {cmd:ctitles(}{it:"Variables", "First Regression"}{cmd:)}.  Note that if there is a column of row titles, the first title in {cmd:ctitles} goes above this column and the second title goes above the first statistics column. 
If you want no heading above the row titles column, specify {cmd:ctitles(}{it:"", "First Regression"}{cmd:)}. 

{pmore}
Fancier titles in {cmd:ctitles} can have multiple rows.  These are specified as a {it:{help frmt_opts##textgrid:textgrid}}.  
For example, to put a number above the column title for the estimation method using {bf:{help outreg}} (in preparation for merging additional estimation results), 
one could use {bf: ctitles(}"", "Regression 1" \ "Independent Variables", "OLS"{bf:)}.  
The table would now have a first column title of "Regression 1" above the coefficients estimates, and a second column title of "OLS" in the row below.

{pmore}
See {help outreg_complete##xmpl10:{bf:outreg} Example 10} for an application of multi-row {opt ctitles}.  

{pmore}
The option {help frmt_opts##nocoltitl:{bf:nocoltitl}} removes even the default column titles.{p_end}
{marker rtitles}{...}

{phang}
{cmd:rtitles(}{it:{help frmt_opts##textgrid:textgrid}}{cmd:)} fills the leftmost column of the table with new row titles for the statistics. In {bf:outreg}, the default row titles (with no {opt rtitles} option) are variable names. 
Multiple titles for the leftmost column in {cmd:rtitles} should be separated by "\" since they are placed below one another (if the titles are separated with commas, they will all be placed in the first row of the estimates).  
An example of {cmd:rtitles} in {bf:{help outreg}} is {cmd:rtitles(}"Variable 1" \ "" \ "Variable 2" \ "" \ "Constant"{cmd:)}. The empty titles "" are to account for the {it:t} statistics below the coefficients.

{pmore}
Multicolumn {opt rtitles} are possible, and will be merged correctly with other estimation results.  Multicolumn {opt rtitles} occur by default, without a specified {opt rtitle}, after multi-equation estimations, where the first {opt rtitle} column is the equation name, and the second {opt rtitle} column is the variable name within the equation.  See the second part of {help outreg_complete##xmpl6:{bf:outreg} Example 6} for a table showing this.

{pmore}
The option {help frmt_opts##norowtitl:{bf:norowtitl}} removes even the default row titles.{p_end}
{marker note}{...}

{phang}
{cmd:note(}{it:{help frmt_opts##textcolumn:textcolumn}}{cmd:)} specifies a note to be displayed below the formatted table.  
Multiple lines of a note should be separated by backslashes ("\"), like this: {bf:note(}"First note line." \ "Second note line." \ "Third note line."{bf:)}.  
Notes are centered immediately below the table. By default, they are set in a smaller font than the body of the table.  Blank note lines ("") are possible to insert space between {opt note} rows.{p_end}
{marker pretext}{...}
{marker posttext}{...}

{phang}
{cmd:pretext(}{it:{help frmt_opts##textcolumn:textcolumn}}{cmd:)} regular text placed before the table.{p_end}
{phang}
{cmd:posttext(}{it:{help frmt_opts##textcolumn:textcolumn}}{cmd:)} regular text placed after the table.{p_end}
{pmore}
{opt pretext} and {opt posttext} contains regular paragraphs of text to be placed before or after the formatted table in the document created.  
This allows a document to be created with regular paragraphs between the tables.  
The default font is applied, which can be changed with the {help frmt_opts##basefont:{bf:basefont}} option.  
Text is left justified and spans the whole page.

{pmore}
Multiple paragraphs can be separated by the backslash character: {bf: pretext(}"Paragraph 1" \ "Paragraph 2"{bf:)}.  

{pmore} 
When creating a Word document, you can create blank lines with empty paragraphs: e.g. {bf:posttext(}"" \ "" \ "This is text"{bf:)} would create two blank lines before the paragraph "This is text".

{pmore}
For Word documents, you can also use the code "\line" for blank lines.  You can insert page breaks between tables with the Word code "\page" in {bf:pretext(}"\page"{bf:)}, 
which is useful when placing multiple tables within one document with the {help frmt_opts##addtable:{bf:addtable}} option.  
The page break or line break codes can be used within a text string, but they must have a space between the codes and the subsequent text: 
e.g. {bf:pretext(}"\page\line This is text"{bf:)}.  
Without the space, in {bf:pretext(}"\page\lineThis is text"{bf:)}, Word would try to interpret the code "\lineThis" which is not defined.

{pmore}
When creating a TeX document (using option {help frmt_opts##tex:{bf:tex}}), you can insert blank lines using the code "\bigskip" (the trick used above of inserting blank paragraphs does not work in TeX files).  
You can insert page breaks between tables with the code "\pagebreak", as in {bf:pretext(}"\pagebreak"{bf:)}, which is useful with the {help frmt_opts##addtable:{bf:addtable}} option to put each table on a separate page.  
The page break or line break codes must be in separate rows from text: 
e.g. {bf:pretext(}"\pagebreak\bigskip" \ "This is text"{bf:)}.{p_end}
{marker nocoltitl}{...}

{phang}
{opt nocoltitl} ensures that there are no column titles - the default column title of the dependent variable name is not used.  
To replace the column headings, instead of eliminate them, use {help frmt_opts##ctitles:{bf:ctitles}}.{p_end}
{marker norowtitl}{...}

{phang}
{opt norowtitl} ensures that there are no row titles at all - the default row titles not used.  
To replace the row headings, instead of eliminate them, use {help frmt_opts##rtitles:{bf:rtitles}}.{p_end}
{marker addrows}{...}

{phang}
{cmd:addrows(}{it:{help frmt_opts##textgrid:textgrid}}{cmd:)} adds rows of text to the bottom of the table (above the notes).  All elements of the rows must be converted from numbers to text before including in the {it:textgrid}.  
For example, to include the test results of coefficient equality, you could use {bf:addrows(}"t test of b1=b2", "`ttest' **"{bf:)} where "ttest" is the name of a {help macro:local macro} with the value of the {it:t} test of ceofficient equality.  
The asterisks are included because the {it:t} test was significant at the 5% level.

{pmore} See {help outreg_complete##xmpl7:{bf:outreg} Example 7} for an application of {opt addrows}.{p_end}
{marker addrtc}{...}

{phang}
{opt addrtc(#)} is a rarely used option to specify the number of rtitle columns in addrows.  
It is only needed when either {opt rtitles} or {opt addrows} has more than one column to ensure that the row titles are lined up correctly vis-a-vis the data.  By default, {opt addrtc} is equal to 1.{p_end}
{marker addcols}{...}

{phang}
{cmd:addcols(}{it:{help frmt_opts##textgrid:textgrid}}{cmd:)} adds columns to the right of table.  
The contents of the new columns are not merged - it is the user's responsibility to ensure that the new columns line up in the appropriate way.{p_end}
{marker annotate}{...}{marker asymbol}{...}

{phang}
{opt annotate(Stata matrix name)} passes a matrix of annotation locations.{p_end}
{phang}
{cmd:asymbol(}{it:{help frmt_opts##textrow:textrow}{bf:)}} provides symbols for each annotation location in {opt annotate}.{p_end}

{pmore}
{opt annotate} and {opt asymbol} (always specified together) are useful for placing footnotes or other annotations next to statistics in the formatted table, but they are not the most user-friendly.  
(Footnotes or annotations in any of the title regions, including row and column titles, can be included directly in the title text with options like {help frmt_opts##rtitles:{bf:rtitles}} and {help frmt_opts##ctitles:{bf:ctitles}}.)  

{pmore}
The values in {opt annotate} range from 0 to the number of symbols in {opt asymbols}.   
In the case of {bf:{help outreg}} the dimensions of the matrix in {opt annotate} has rows equal to the number of coefficients in the estimation, and columns equal to the number of statistics displayed (2, by default).
Whenever the {opt annotate} matrix has a value of zero, no symbol is appended to the statistic in the corresponding cell of the table.  
Where the {opt annotate} matrix has a value of 1, the first {opt asymbol} symbol is added on the left of the statistic, where there's a value of 2, the second symbol is added, etc.  

{pmore}
The {it:textrow} in {opt asymbols} has the syntax "{it:text}"[, "{it:text}" ...]]. 
If you want to have a space between the statistic in the table and the {opt asymbol} {it:text}, make sure to include it in the {it:text}, e.g. {bf:asymbols(}" 1"," 2"{bf:)}.  
Superscripts for the symbols in a Word file can be included as follows: enclose the symbol with curly brackets "{}" and prepend the superscript code "\super ".  
So for a superscript one, the {it:text} in {opt asymbols} would be "{\super 1}".  Make sure to include the space after "\super".  
For TeX files, "1" can be superscripted either with the code "$^1$" or "\textsuperscript{1}".  See the discussion about {help frmt_opts##greek:inline formatting}.

{pmore}
To understand the correspondence between the locations in the {opt annotate} matrix and the final formatted table, it helps to know how the {cmd:frmttable} program (called by {bf:{help outreg}} and other programs) creates tables.  
In the case of {cmd:outreg}, it  sends the different estimation statistics in separate columns, so for the default statistics of {bf:b} and {bf:t_abs}, {cmd:outreg} sends a K by 2 matrix to {cmd:frmttable}, where K is the number of coefficients.  
The nonzero locations of {opt annotate} that indicate a symbol should be added correspond to the locations of the K by 2 matrix passed to {cmd:frmttable}, not the 2K by 1 table of statistics created by {cmd:frmttable}.  
Perhaps a simpler way of saying this is that {opt annotate} positions correspond to the final table positions when you use the {help frmt_opts##nosubstat:{bf:nosubstat}} option.  
If there are S statistics (2 by default), the {opt annotate} matrix should be a K by S Stata matrix where K is the number of columns in e(b).  
This can be created in a Stata for a regression with 5 coefficients and the default of 2 statistics like this:{p_end}{...}
{pmore2}
	{cmd}. matrix annotmat = J(5,2,0){p_end}
{pmore2}
	{cmd}. matrix annotmat[1,1] = 1{p_end}
{pmore2}
	{cmd}. matrix annotmat[3,2] = 2{p_end}
{pmore2}
	{cmd}. outreg ... , annotate(annotmat) asymbol(" (1)"," (2)"){p_end}
{txt}{...}
{pmore}
This will assign the first {opt asymbol} (" (1)") to the first coefficient, and the second {opt asymbol} (" (2)") to the third {it:t} statistic.

{pmore}
In fact, the {opt annotate} matrix can be smaller than K by S if there are rows at the bottom of the table or columns on the right of the table that don't need any symbols.  
In other words, if the {opt annotate} matrix is not the same size as the statistics, the missing, or too large, parts of it are ignored. 

{pmore}
If {opt annotate} and {opt asymbol} are used to create footnote references, the footnotes themselves can be included in the {help frmt_opts##note:{bf:note}} option. 

{pmore}
See {help outreg_complete##xmpl14:{bf:outreg} Example 14} for an application of {opt annotate} and {opt asymbol}.{p_end}

{marker col_formats}{...}
{dlgtab:Column formatting}
{marker colwidth}{...}

{phang}
{cmd:colwidth(}{it:{help numlist}}{cmd:)} assigns column widths.  
By default, the program makes its best guess of the appropriate column width, but Word RTF files have no algorithm to ensure that the column width exactly fits the maximum width of the contents of its cells, the way TeX files do.  
In particular, when special non-printing formatting codes (such as superscript codes) are included in {opt ctitles} and {opt rtitles}, the program will probably get the width wrong, and {opt colwidth} will be needed.  
This option is only allowed for Word files, not TeX files, which automatically determine column widths.

{pmore}
If colwidth has fewer widths than the number of columns, the program will guess the best width for the remaining columns.
Specifying {bf:colwidth(}10{bf:)} will assign a width of 10 characters to the first column in the table, but not change the width of other columns. 
To assign a width of 10 to all columns in a five column table, use {bf:colwidth(}10 10 10 10 10{bf:)}.  
The width of the column using {bf:colwidth(}1{bf:)} is equal to the width of one "n" of the currently assigned point size, with the addition of the default buffers on either side of the cell.{p_end}
{marker multicol}{...}

{phang}
{cmd:multicol(}{it:{help frmt_opts##numtriple:numtriple}}[; {it:{help frmt_opts##numtriple:numtriple}} ...]{cmd:)} combines table cells into one cell that spans multiple columns.  
This is mainly used for column titles that apply to more than one column.{p_end}
{marker numtriple}{...}

{pmore}A {it:numtriple} means three numbers, separated by commas.  
Each {it:numtriple} consist of the row of the first cell to be combined, the column of the first cell, and the number of cells to be combined (>=2).  

{pmore}
For example, to combine the heading for the first two statistics columns in a table (with only one {help frmt_opts##rtitles:{bf:rtitles}} column), the option would be {bf:multicol(}1,2,2{bf:)}.  
That is, the combined cells start in the first row of the table (below the title) and the second column of the table (the start of the statistics columns), and two cells are to be combined.  
See an example of this in {help outreg_complete##xmpl10:{bf:outreg} Example 10}.

{pmore}
It often looks good to underline the {help frmt_opts##ctitles:{bf:ctitles}} in the combined cell to make clear that the column title applies to both columns below it.  
In Word RTF files, underlining does not apply to blank spaces, so to extend the underline to either side of the text in the {cmd:ctitle}, you can insert tab characters, which will be underlined.  
For example, for the {cmd:ctitle} text "First 2", you could apply codes for underlining and tabs like this: {bf:ctitle(}"", "{\ul\tab First 2\tab\tab}"{bf:)}.  
Note the obligatory space between RTF code ("\tab") and the text.  
Underscore characters "_" can also be used to extend underlining where there is no text, although they create a line that is slightly lower than the underlining line.{p_end}
{marker coljust}{...}

{phang}
{cmd:coljust(}{it:{help frmt_opts##cjstring:cjstring}}[; {it:{help frmt_opts##cjstring:cjstring}} ...]{cmd:)} specifies whether the table columns are left, center, or right justified 
(that is, the text in each row is flush with the left, center, or right side of the column) or centered on the decimal point (for Word files only).  
By default, the {help frmt_opts##rtitles:{bf:rtitles}} columns are left justified, and the rest of the columns are decimal justified for Word files.  
For TeX files, {help frmt_opts##rtitles:{bf:rtitles}} columns are left justified, and the rest of the columns are center justified.{p_end}
{marker cjstring}{...}

{pmore}
{it:cjstring} is a string made up of: {p_end}

{p2colset 11 35 37 30}{...}
{p2col:element}action{p_end}
{p2line}
{p2colset 13 35 37 30}{...}
{p2col:{opt l}}left justification{p_end}
{p2col:{opt c}}center justification{p_end}
{p2col:{opt r}}right justification{p_end}
{p2col:{opt .}}decimal justification (Word only){p_end}
{p2col:{cmd:{}}}repetition{p_end}
{p2colset 11 35 37 30}{...}
{p2line}

{pmore}
Left, center, and right justification are self-explanatory, but decimal justification requires some elaboration.  
Decimal justification lines up all of the numbers in the column so that the decimal points are in a verticle line.  
Whole numbers are justified to the left of the decimal point.  
Text in the {help frmt_opts##ctitles:{bf:ctitles}} is not decimal justified - otherwise the whole {opt ctitle} for the column would be to the left of the decimal point, like whole numbers.  
Instead, in columns with decimal justification {opt ctitles} are center justified.

{pmore}
Decimal justification works with comma decimal points used in many European languages (to set comma decimal points in Stata, see {help format:{bf:set dp} comma}).  
However, Microsoft Word will recognize the comma decimal points correctly only if the operating system has been changed to specify comma decimal points.  
In the Windows operating system, this can be done in the Control Panel under Regional and Language Options.  
In the OSX operating system, this is done in System Preferences under Language and Text: Formats.

{pmore}
Each letter in {it:cjstring} indicates the column justification for one column.  
For example, "lccr" left justifies the first column, center justifies the second and third column, and right justifies the fourth column.  
If there are more than four columns, the remaining columns will be right justified, since the last element in the string is applied repeatedly.  
If there are fewer than four columns, the extra justification characters are ignored.

{pmore}
The curly brackets "{}" repeat the middle of {it:cjstring}.  
For example, "l{c}rr" left justifies the first column, center justifies all the subsequent columns up to the next to last column, and right justifies the last two columns.

{pmore}
The semi-colon ";" applies column justification to separate {help frmt_opts##table_sections:sections} of the formatted table, but is not needed by most users.  
Formatted tables have two column sections: the columns of {help frmt_opts##rtitles:{bf:rtitles}} (typically one column), and the columns of statistics.

{pmore}
The section divider allows you to specify the column justification without knowing how many columns are in each section.  
Hence, the default {opt coljust} parameters for Word files are {bf:coljust(}l;.{bf:)}, 
which applies left justification to all the columns in the first ({opt rtitles}) section of the table and decimal justification to the remaining column sections of the table.

{pmore}
For example, {bf:coljust(}l{c}r;r{c}l{bf:)} would apply "l{c}r" only to the first column section, and "r{c}l" to the second (or more) column sections.{p_end}

{pmore}
{it:Technical Note:} TeX has the capability for decimal justification using the dcolumn package or the {r@{.}l} column justification syntax.  
However, both these methods conflict with other capabilities of formatted tables in ways that make them very difficult to implement.  
The dcolumn package imposes math mode for the decimal justified columns, which is inconsistent with the default formatting, and also interferes with the {opt multicol} option. 
The {r@{.}l} syntax splits the column in question into two columns, which would require workarounds for many options.
Users who do not care to have their {it:t} statstics displayed in a smaller font than the coefficient estimations (the default), 
can modify their TeX tables manually to implement decimal justification using the dcolumn package.{p_end}
{marker nocenter}{...}

{phang}
{opt nocenter}: Don't center the formatted table within the document page.  
{opt nocenter} also causes {opt title} and {opt note} text to be left justified.
{opt nocenter} does not apply to the display of the table in the Stata Results window, which is always centered.{p_end}

{marker fonts}{...}
{dlgtab:Font specification}
{marker basefont}{...}

{phang}
{cmd:basefont(}{it:{help frmt_opts##fontlist:fontlist}}{cmd:)} changes the base font for all text in the formatted table, as well as {help frmt_opts##pretext:{bf:pretext}} and {help frmt_opts##posttext:{bf:posttext}}.  
The default font specification is 12 point Times New Roman for Word documents, and is left unspecified for TeX documents (which normally means it is 10 point Times New Roman).{p_end}
{marker fontlist}{...}

{pmore}
The {it:fontlist} is made up of elements in the tables below (different for {help frmt_opts##fontlist_word:Word} and {help frmt_opts##fontlist_tex:TeX} files), separated by spaces.  
The elements of the {it:fontlist} can specify font size, font type (e.g. Times Roman, Arial, or a new font from {help frmt_opts##addfont:{bf:addfont}}), and font style (like italic or bold).

{pmore}
If you specify more than one font type (roman, arial, courier, and perhaps fnew#), only the last choice in the {it:fontlist} will be in effect.

{pmore}
See {help outreg_complete##xmpl11:{bf:outreg} Example 11} for an application of {opt basefont}.{p_end}
{marker fontlist_word}{...}

{pmore}
A {it:fontlist} for Word files is made up of:{p_end}

{p2colset 11 35 37 15}{...}
{p2col:element}action{p_end}
{p2line}
{p2colset 13 35 37 15}{...}
{p2col:{cmd:fs}{it:#}}font size in points{p_end}
{p2col:{opt arial}}Arial font{p_end}
{p2col:{opt roman}}Times New Roman font{p_end}
{p2col:{opt courier}}Courier New font{p_end}
{p2col:{cmd:fnew}{it:#}}font specified in {opt addfont}{p_end}
{p2col:{opt plain}}no special font effects{p_end}
{p2col:{opt b}}bold text{p_end}
{p2col:{opt i}}italize text{p_end}
{p2col:{opt scaps}}small caps: capitalize lower case letters{p_end}
{p2col:{opt ul}}underline text{p_end}
{p2col:{opt uldb}}underline text with a double line{p_end}
{p2col:{opt ulw}}underline words only (not spaces between words){p_end}
{p2colset 11 35 37 15}{...}
{p2line}
{marker fontlist_tex}{...}

{pmore}
A {it:fontlist} for TeX files is made up of:{p_end}

{p2colset 11 35 37 15}{...}
{p2col:element}action{p_end}
{p2line}
{p2colset 13 35 37 15}{...}
{p2col:{opt fs#}}font size in points (10, 11, or 12)*{p_end}
{p2col:{opt Huge}}bigger than huge{p_end}
{p2col:{opt huge}}bigger than LARGE{p_end}
{p2col:{opt LARGE}}bigger than Large{p_end}
{p2col:{opt Large}}bigger than large{p_end}
{p2col:{opt large}}bigger than normalsize{p_end}
{p2col:{opt normalsize}}default font size{p_end}
{p2col:{opt small}}smaller than normalsize{p_end}
{p2col:{opt footnotesize}}smaller than small{p_end}
{p2col:{opt scriptsize}}smaller than footnotesize{p_end}
{p2col:{opt tiny}}smaller than scriptsize{p_end}
{p2col:{opt rm}}Times Roman font{p_end}
{p2col:{opt it}}italic text{p_end}
{p2col:{opt bf}}bold face text{p_end}
{p2col:{opt em}}emphasize text (same as bf){p_end}
{p2col:{opt sl}}slanted text{p_end}
{p2col:{opt sf}}sans-serif font, i.e. Arial{p_end}
{p2col:{opt sc}}small caps{p_end}
{p2col:{opt tt}}teletype, i.e. Courier{p_end}
{p2col:{opt underline}}underline text{p_end}
{p2colset 11 35 37 15}{...}
{p2line}
{phang2}
* fs# can only be specified in the {opt basefont} option for TeX files, not in other font specification options.{p_end}
{marker titlfont}{...}

{phang}
{cmd:titlfont(}{it:{help frmt_opts##fontcolumn:fontcolumn}}{cmd:)} changes the font for the table's title.{p_end}
{marker notefont}{...}
{phang}
{cmd:notefont(}{it:{help frmt_opts##fontcolumn:fontcolumn}}{cmd:)} changes the font for notes below the table.{p_end}

{pmore}
{opt titlfont} and {opt notefont} take a {it:fontcolumn} rather than a {it:fontlist} to allow for different fonts on different rows of titles or notes, such as a smaller font for the subtitle than the main title.{p_end}
{marker fontcolumn}{...}

{pmore}
A {it:fontcolumn} consists of {it:fontlist} [ \ {it:fontlist} ... ], where {it:fontlist} is defined above for {help frmt_opts##fontlist_word:Word files} or for {help frmt_opts##fontlist_tex:TeX files}.

{pmore}
For example, to make the title font large and small caps, and the subtitles still larger than regular text, without small caps, you could use
{bf:titlfont(}fs17 scaps \ fs14{bf:)} for a Word file, or {bf:titlfont(}Large sc \ large{bf:)} for a TeX file.{p_end}
{marker ctitlfont}{marker rtitlfont}{marker statfont}{...}

{phang}
{cmd:ctitlfont(}{it:{help frmt_opts##fontgrid:fontgrid}} [; {it:{help frmt_opts##fontgrid:fontgrid}} ...]{cmd:)} changes the fonts for column titles.{p_end}{...}
{phang}
{cmd:rtitlfont(}{it:{help frmt_opts##fontgrid:fontgrid}} [; {it:{help frmt_opts##fontgrid:fontgrid}} ...]{cmd:)} changes the fonts for row titles.{p_end}{...}
{phang}
{cmd:statfont(}{it:{help frmt_opts##fontgrid:fontgrid}} [; {it:{help frmt_opts##fontgrid:fontgrid}} ...]{cmd:)} changes the fonts for statistics in the body of the table.{p_end}

{pmore}
{opt ctitlfont}'s, {opt rtitlfont}'s, and {opt statfont}'s arguments are {it:fontgrids} to allow a different font specification for each cell of the {help frmt_opts##ctitles:{bf:ctitles}}, 
{help frmt_opts##rtitles:{bf:rtitles}}, or the table statistics, respectively.  
By default, all of these areas of the table have the same font as the {help frmt_opts##basefont:{bf:basefont}}, which by default is Times Roman, 12 point for Word files.{p_end}
{marker fontgrid}{...}

{pmore}
A {it:fontgrid} consists of {it:fontrow} [ \ {it:fontrow} ... ], where {it:fontrow} is {it:fontlist} [ , {it:fontlist} ...] and where {it:fontlist} is defined above for {help frmt_opts##fontlist_word:Word files} 
and for {help frmt_opts##fontlist_tex:TeX files}.

{pmore}
For example, to make the font for the first row of {opt ctitles} bold and the second (and subsequent) rows of {opt ctitles} italic, you could use {bf:ctitlfont(}b \ i{bf:)} for a Word file, or {bf:ctitlfont(}bf \ it{bf:)} for a TeX file.

{pmore}
The semi-colon ";" in the argument list applies different fonts to separate {help frmt_opts##table_sections:sections} of the formatted table.  This is more likely to be useful for row sections than column sections.  
Formatted tables have two column sections: the columns of {help frmt_opts##rtitles:{bf:rtitles}} (typically one column), and the columns of  statistics.  
{bf:{help outreg}} tables, for example, have four row sections: the rows of {help frmt_opts##ctitles:{bf:ctitles}} (often one row), and three sections for the {help frmt_opts##rtitles:{bf:rtitles}} and statistics: 
the rows of regular coefficients, the rows of constant coefficients, and the rows of summary statistics below the coefficients.

{pmore}
The section divider allows you to specify the column or row fonts without knowing for a particular table how many columns or rows are in each section.  
To italicize the {it:t} statistics below coefficient estimates for the coefficients, but not italicize the summary statistics rows, 
you could use {bf:statfont(}plain \ i; plain \ i; plain{bf:)} for a Word file, or {bf:statfont(}rm \ it; rm \ it; rm{bf:)} for a TeX file.

{pmore}
Note that if you specify a new font type or a single font point size in {opt titlfont} or {opt statfont}, this is applied to all rows of the {opt title} or estimation statistics, removing the default behavior of making the subtitles smaller than the first row of {opt title}, and the "substatistics" like the {it:t} statistic smaller than the coefficient estimates.  To retain this behavior, specify two rows of font sizes in {opt titlfont} or {opt statfont}, with the second being smaller than the first.  Changing the {opt basefont} does not have any effect on the differing font sizes in the rows of {opt title} and estimation statistics.{p_end}
{marker addfont}{...}

{phang}
{cmd: addfont(}{help frmt_opts##textrow:textrow}{cmd:)} adds a new font type, making it available for use in the font specifications for various parts of the formatted table.  
This  option is available only for Word files, not TeX files.

{pmore}
By default, only Times Roman ("roman"), Arial ("arial"), and Courier New ("courier") are available for use in Word RTF documents. 
{opt addfont} makes it possible to make additional fonts available for use in the Word documents created.

{pmore}
{help frmt_opts##textrow:textrow} is a sequence of font names in quotation marks, separated by commas.

{pmore}
The new font in {opt addfont} can be referenced in the various font specification options, like {help frmt_opts##basefont:{bf:basefont}} and {help frmt_opts##titlfont:{bf:titlfont}} 
with the code "fnew1" for the first new font in {cmd:addfont} and increments of it ("fnew2", "fnew3", etc.) for each additional font.

{pmore}
If the font specified in {opt addfont} is not available on your computer when using the Word file created, the new font will not display correctly - another font will be substituted.  
You can find the correct name of each available font in Word by scrolling through the font selection window on the toolbar of the Word application.  Correct capitalization of the font name is necessary.

{pmore}
See {help outreg_complete##xmpl11:{bf:outreg} Example 11} for an application of {opt addfont}.{p_end}
{marker plain}{...}

{phang}
{opt plain} eliminates default formatting, reverting to plain text: only one font size for the whole table, no column justification, and no added space above and below the horizontal border lines.  
Instead of using {opt plain}, the default formatting can also be reversed feature by feature with {help frmt_opts##titlfont:{bf:titlfont}}, {help frmt_opts##notefont:{bf:notefont}}, 
{help frmt_opts##coljust:{bf:coljust}}, {help frmt_opts##spacebef:{bf:spacebef}}, and {help frmt_opts##spaceaft:{bf:spaceaft}}.  
The {opt plain} option does this all at once.

{pmore}
For TeX tables, {opt plain} eliminates italicization of {it N} and {it R2}, and superscripting the {it 2} in {it R2}.  

{pmore}
If you want to use the {it #} symbol as a TeX control code rather than as a displayed character, use the {opt plain} option.  
{p_end}


{marker table_sections}{...}

{phang}
{opt table sections}: It can be helpful for specifying fonts and other formatting to understand how {bf:{help outreg}} divides the table into sections.  The following diagram illustrates the section divisions:

		   {c TLC}{dup 56:{c -}}{c TRC}
		   {c |}                        title                           {c |}
		   {c BLC}{dup 56:{c -}}{c BRC}
		     column section 1		column section 2
		   {c TLC}{dup 18:{c -}}{c TT}{dup 37:{c -}}{c TRC}
		{c TLC}{c -} {c TLC}{dup 18:{c -}}{c TT}{dup 37:{c -}}{c TRC}
		{c |}  {c |}{dup 18: }{c |}{dup 37: }{c |}
 row section 1  {c |}  {c |}     ctitles      {c |}        ctitles{dup 22: }{c |}
		{c |}  {c |}{dup 18: }{c |}{dup 37: }{c |}
		{c LT}{c -} {c LT}{dup 18:{c -}}{c +}{dup 37:{c -}}{c RT}
		{c |}  {c |}{dup 18: }{c |}{dup 37: }{c |}
		{c |}  {c |}{dup 18: }{c |}{dup 37: }{c |}
		{c |}  {c |}{dup 18: }{c |}{dup 37: }{c |}
 row section 2  {c |}  {c |}     rtitles      {c |}        coefficient estimates{dup 8: }{c |}
		{c |}  {c |}{dup 18: }{c |}        (except for constants)       {c |}
		{c |}  {c |}{dup 18: }{c |}{dup 37: }{c |}
		{c |}  {c |}{dup 18: }{c |}{dup 37: }{c |}
		{c LT}{c -} {c LT}{dup 18:{c -}}{c +}{dup 37:{c -}}{c RT}
 row section 3  {c |}  {c |}     rtitles      {c |}        constant coefficients{dup 8: }{c |}
		{c LT}{c -} {c LT}{dup 18:{c -}}{c +}{dup 37:{c -}}{c RT}
 row section 4  {c |}  {c |}     summtitles   {c |}        summstats{dup 20: }{c |}
		{c BLC}{c -} {c BLC}{dup 18:{c -}}{c BT}{dup 37:{c -}}{c BRC}

		   {c TLC}{dup 56:{c -}}{c TRC}
		   {c |}                        note                            {c |}
		   {c BLC}{dup 56:{c -}}{c BRC}


{marker lines_spaces}{...}
{dlgtab:Border lines and spacing}
{marker hlines}{marker vlines}{...}

{phang}
{cmd:hlines(}{it:{help frmt_opts##linestring:linestring}} [; {it:{help frmt_opts##linestring:linestring}} ...]{cmd:)} draws horizontal lines between rows.{p_end}
{phang}
{cmd:vlines(}{it:{help frmt_opts##linestring:linestring}} [; {it:{help frmt_opts##linestring:linestring}} ...]{cmd:)} draws verticle lines between columns.{p_end}

{pmore}
{opt hlines} and {opt vlines} designate where horizontal and verticle lines will be placed to delineate parts of the table.  
By default the formatted table has horizontal lines above and below the {opt ctitle} header rows and at the bottom of the table above the notes, if any.  
There are no verticle lines by default.{p_end}
{marker linestring}{...}

{pmore}
{it:linestring} is a string made up of: {p_end}

{p2colset 11 35 37 30}{...}
{p2col:element}action{p_end}
{p2line}
{p2colset 13 35 37 30}{...}
{p2col:{opt 1}}add a line{p_end}
{p2col:{opt 0}}no line{p_end}
{p2col:{cmd:{}}}repetition{p_end}
{p2colset 11 35 37 30}{...}
{p2line}

{pmore}
Each "1" in {it:linestring} indicates a line and a 0 indicates no line.  
For example, {bf:hlines(}110001{bf:)} would draw a line above and below the first row of the table and below the fifth row (above the sixth row).  
There is one more possible horizontal line than row (and one more verticle line than column).  
That is, for a five row table, to put a line above and below every row one would specify six {opt hlines}: {bf:hlines(}111111{bf:)}.

{pmore}
{opt hlines} and {opt vlines} are not displayed correctly in the Stata Results window. 
They only apply to the final Word or TeX document.

{pmore}
Curly brackets "{}" repeat the middle of {it:linestring}.  
For example, {bf:hlines(}11{0}1{bf:)} puts a horizontal line above and below the first row, and another below the last row.

{pmore}
The semi-colon ";" applies line designations to separate {help frmt_opts##table_sections:sections} of the formatted table.  
{bf:{help outreg}} tables, for example, have two column sections and four row sections. 
The column sections are made up of the columns of {help frmt_opts##rtitles:{bf:rtitles}} (typically one column), and the columns of the estimation statistics.  
The row sections are made up of the rows of {help frmt_opts##ctitles:{bf:ctitles}} (often one row), the rows of the coefficient estimates (except the constant), 
the rows of the constant coefficients, and the rows of the summary statistics below the coefficients.

{pmore}
The section divider allows you to specify the {opt hlines} and {opt vlines}  without knowing how many rows and columns are in each section.  
Hence, the default {opt hlines} elements are {bf:hlines(}1{0};1{0}1{bf:)}, which puts a horizontal line above the header rows, a line above the statistics rows, and a line below the last statistics row.  
By default, there are no {opt vlines}, which some graphic designers think are best avoided.{p_end}
{marker hlstyle}{marker vlstyle}{...}

{phang}
{cmd:hlstyle(}{it:{help frmt_opts##lstylestring:lstylestring}} [; {it:{help frmt_opts##lstylestring:lstylestring}} ...]{cmd:)} changes the style of horizontal lines.{p_end}
{phang}
{cmd:vlstyle(}{it:{help frmt_opts##lstylestring:lstylestring}} [; {it:{help frmt_opts##lstylestring:lstylestring}} ...]{cmd:)} changes the style of verticle lines.{p_end}

{pmore}
{opt hlstyle} and {opt vlstyle} options are only available for Word files.  By default, all lines are solid single lines.{p_end}
{marker lstylestring}{...}

{pmore}
{it:lstylestring} is a string made up of: {p_end}

{p2colset 11 35 37 25}{...}
{p2col:element}action{p_end}
{p2line}
{p2colset 13 35 37 25}{...}
{p2col:{opt s}}Single line{p_end}
{p2col:{opt d}}Double line{p_end}
{p2col:{opt o}}Dotted line{p_end}
{p2col:{opt a}}Dashed line{p_end}
{p2col:{opt S}}Heavy weight single line{p_end}
{p2col:{opt D}}Heavy weight double line{p_end}
{p2col:{opt O}}Heavy weight dotted line{p_end}
{p2col:{opt A}}Heavy weight dashed line{p_end}
{p2col:{cmd:{}}}repetition{p_end}
{p2colset 11 35 37 25}{...}
{p2line}

{pmore}
Repetition using curly brackets "{}" and semi-colons ";" for section dividers are used in the same way they are for {help frmt_opts##hlines:{bf:hlines}} and {help frmt_opts##vlines:{bf:vlines}}.

{pmore}
Some word processing applications, like OpenOffice or Pages (for the Mac) do not display all Word RTF line styles correctly.{p_end}
{marker spacebef}{marker spaceaft}{marker spaceht}{...}

{phang}
{cmd:spacebef(}{it:{help frmt_opts##spacestring:spacestring}} [; {it:{help frmt_opts##spacestring:spacestring}} ...]{cmd:)} puts space above cell contents.{p_end}
{phang}
{cmd:spaceaft(}{it:{help frmt_opts##spacestring:spacestring}} [; {it:{help frmt_opts##spacestring:spacestring}} ...]{cmd:)} puts space below cell contents.{p_end}
{phang}
{opt spaceht(#)} changes the size of the space above & below cell contents in {opt spacebef} and {opt spaceaft}.{p_end}

{pmore}
{opt spacebef} and {opt spaceaft} are options to make picky changes in the appearance of the table.  
They increase the height of the cells in particular rows so that there is more space above and below the contents of the cell.  
They are used by default to put space between the horizontal line at the top of the table and the first header row, above and below the line separating the header row from the statistics, 
and put space below the last row of the table, above the horizontal line.{p_end}
{marker spacestring}{...}

{pmore}
{it:spacestring} has the same form as {it:{help frmt_opts##linestring:linestring}} above.  
A "1" indicates a extra space (above the cell if in {opt spacebef} and below the cell if in {opt spaceaft}), and a "0" indicates no extra space. 
"{}" repeats indicators and ";" separates row sections.

{pmore}
{opt spaceht} controls how big the extra space is in {opt spacebef} and {opt spaceaft}.  
Each one unit increase in {opt spaceht} increases the space by about a third of the height of a capital letter.  
The default is {bf:spaceht(}1{bf:)}.  
{opt spaceht} is scaled proportionally to the base font size for the table.
For example {bf:spaceht(}2{bf:)} makes the extra spacing 100% larger than it is by default.

{pmore}
For TeX files (using the {opt tex} option), {opt spaceht} can only take the values 2 or 3.  
The default corresponds to the LaTeX code \smallskip.

{pmore}
Values 2 and 3 for {opt spaceht} correspond to the LaTeX codes \medskip and \bigskip, respectively.{p_end}
{marker page_fmt}{...}

{dlgtab:Page formatting}
{marker landscape}{...}

{phang}
{opt landscape} puts the document page containing the formatted table in landscape orientation.
This makes the page wider than it is tall, in contrast to portrait orientation.  {opt landscape} is convenient for wide tables.  
An alternative way of fitting a table on the page is to use a smaller {help frmt_opts##basefont:{bf:basefont}}, without the need for the {opt landscape} option.{p_end}
{marker a4}{...}

{phang}
{opt a4} specifies A4 size paper (instead of the default 8 1/2” x 11”) for the Word or TeX document containing the formatted table.{p_end}
{marker file_options}{...}

{dlgtab:File and display options}
{marker tex}{...}

{phang}
{opt tex} writes a TeX output file rather than a Word file (as long as {opt using} {it:filename} is specified).  
The output is suitable for including in a TeX document (see the {help frmt_opts##fragment:{bf:fragment}} option) or loading into a TeX typesetting program such as Scientific Word.{p_end}
{marker merge}{...}

{phang}
{cmd:merge}[{cmd:(}{it:{help frmt_opts##tblname:tblname}}]{cmd:)} specifies that new statistics be merged to the most recently created formatted table.
The new statistics are combined with previous estimates, lined up according to the appropriate variable names (or {help frmt_opts##rtitles:{bf:rtitles}}), 
with the statistics corresponding to new row titles placed below the original statistics.  In the case of {bf:outreg}, coefficient estimates of new variables are placed below the estimates for existing coefficients, but above the constant term. 

{pmore}
Note that previous versions of the {bf:{help outreg}} command, the {cmd:merge} option was called {it:append}. 
Users will usually want to specify {help frmt_opts##ctitles:{bf:ctitles}} when using {cmd:merge}.

{pmore}
{opt merge} can be used even if a previous formatted table does not exist for merging.  
This is to enable {opt merge} to be used in loops, as in {help outreg_complete##xmpl16:{bf:outreg} Example 16}.  
Users will see a warning message if no existing table is found.

{pmore}
If a {it:tblname} is specified, the current estimates will be merged to an existing table named {it:tblname}, 
which could have been created with a previous command using the {opt store(tblname)}, {opt merge(tblname)} or {opt append(tblname)} options.{p_end}
{marker tblname}{...}

{pmore}
A {it:tblname} consists of the characters A-Z, a-z, 0-9, and "_", and can have a length of up to 25 characters.{p_end}
{marker replace}{...}

{phang}
{opt replace} specifies that it is okay to overwrite an existing file.{p_end}
{marker addtable}{...}

{phang}
{opt addtable} places the estimation results as a new table below an existing table in the same document (rather than combining the tables as with {help frmt_opts##merge:{bf:merge}}).  
This makes it possible to build up a document with multiple tables in it.

{pmore}
Options {opt pretext} and {opt posttext} can add accompanying text between the tables.  
To put a page break between successive tables, so that each table is on its own page, see the discussion for {help frmt_opts##pretext:{bf:pretext} and {bf:posttext}}.

{pmore}
See {help outreg_complete##xmpl13:{bf:outreg} Example 13} for an application of {opt addtable}.{p_end}
{marker append}{...}

{phang}
{cmd:append}[{cmd:(}{it:{help frmt_opts##tblname:tblname}}{cmd:)}] combines the statistics as new rows below an existing table.  
If a {it:tblname} is specified, the statistics will be appended to an existing formatted table named {it:tblname} (see the {help frmt_opts##store:{bf:store}} option).

{pmore}
{bf:Warning: this is not the append option from previous versions of {bf:{help outreg}} - use {help frmt_opts##merge:{bf:merge}}}.

{pmore}
{opt append} can be used even if no previous formatted table exists, which is useful in loops for the first invocation of the {opt append} option.

{pmore}
{opt append} does not match up column headings. 
The column headings of the new table being appended are ignored unless the new table has more columns than the original table, in which case only the headings of the new columns are used.{p_end}
{marker replay}{...}

{phang}
{cmd:replay}[{cmd:(}{it:{help frmt_opts##tblname:tblname}}{cmd:)}] is used to rewrite an existing formatted table to a file without including any new statistics (unless paired with {bf:merge} or {bf:append}).  
This can be used to rewrite the same table with different text formatting options. 
It is also useful for use after building a table in a loop to write the final table to a file.
If a {it:tblname} is specified, {cmd:replay} will use the table with that name.

{pmore}
{opt replay} is useful after running a loop that merges multiple estimation results together, to write the final merged table to a document file.  
See {help outreg_complete##xmpl16:{bf:outreg} Example 16}.

{pmore}
{bf:replay} changes the behavior of {bf:merge} and {bf:append} when they have table names, causing them to merge or append results {it:from} the table specified into the table specified by {bf:replay}. 
{p_end}
{marker store}{...}

{phang}
{cmd:store(}{it:{help frmt_opts##tblname:tblname}}{cmd:)} is used to assign a {it:tblname} to a formatted table.  
This is useful mainly for building more than one table simultaneously, by merging new estimation results to separate tables when the estimation commands must be run sequentially.{p_end}
{marker clear}{...}

{phang}
{cmd:clear}[{cmd:(}{it:{help frmt_opts##tblname:tblname}}{cmd:)}] removes the current formatted table from memory.  
This is helpful when using {opt merge} option in a loop so that the first time it is invoked, 
the estimation results is not merged to an existing formatted table (such as the one created the last time the {cmd:.do} file was run).  
{cmd:outreg, clear} clears the current table, allowing the user to start with a blank slate.

{pmore}
If a {it:tblname} is specified, the formatted table named {it:tblname} will be removed from memory.  
When using multiple {it:tblnames}, they must be {opt clear}ed one by one.  An alternative is to use {help mata clear:{bf:mata: mata clear}} to clear all of Mata's memory space, including the formatted tables.{p_end}
{marker fragment}{...}

{phang}
{opt fragment} creates a TeX code fragment for inclusion in a larger TeX document instead of a stand-along TeX document.  
A TeX fragment saved to the file auto.tex can then be included in the following TeX document with the TeX \input{auto} command:

{pmore2}
\documentclass[]{article}{p_end}
{pmore2}
\begin{document}{p_end}
{pmore2}
... text before inclusion of table auto.tex ...{p_end}
{pmore2}
\input{auto}{p_end}
{pmore2}
... text after inclusion of table auto.tex ...{p_end}
{pmore2}
\end{document}{p_end}

{pmore}
Including TeX fragments with the TeX \input{} command allows the formatted table to be updated without having to change the TeX code for the 
document itself.  This is convenient because estimation tables often require 
small modifications which can be made without having to reinsert a 
new table manually.  Creating TeX fragments for inclusion in larger TeX documents is 
especially useful when there are many tables in a single document (see also the {help frmt_opts##addtable:{bf:addtable}} option). 

{pmore}
An alternative to the TeX \input{} command is the TeX \include{} command which 
inserts page breaks before and after the included table.{p_end}
{marker nodisplay}{...}

{phang}
{opt nodisplay} suppresses displaying the table in the Stata Results window.{p_end}
{marker dwide}{...}

{phang}
{opt dwide} displays all columns in the Stata Results window, however wide the table is.  
This is mainly useful if you want to copy the table to paste it into another document (which hopefully is not necessary).
Without the {opt dwide} option, very wide tables are displayed in the Results window in sections containing as many columns as will fit given the current width of the Results window.{p_end}

{marker brack_options}{...}
{dlgtab:Brackets options}
{marker squarebrack}{...}

{phang}
{opt squarebrack} substitutes square brackets for parentheses around the statistics placed below the first statistic.  For the default statistics, this means that square brackets, rather than parentheses, are placed around {it:t} statistics below the coefficient estimates.

{pmore}
{opt squarebrack} is equivalent to {bf:brackets(}"","" \ [,] \ (,) \ <,> \ |,|{bf:)}.{p_end}
{marker brackets}{...}

{phang}
{cmd:brackets(}{it:{help frmt_opts##textpair:textpair}} [{cmd:\} {it:{help frmt_opts##textpair:textpair}} ...]{cmd:)} specifies the symbols used to bracket statistics.  
By default, the first statistic has no brackets and parentheses are placed around the second statistic, such as the {it:t} statistic below the estimated coefficient estimate when using {bf:{help outreg}}.{p_end}
{marker textpair}{...}

{pmore}
A {it:textpair} is made up of two elements of text separated by a comma.  The default brackets are {bf:brackets(}"","" \ (,) \ [,] \ <,> \ |,|{bf:)}.

{pmore}
If there are a sufficient number of statistics for the symbols <,> and |,| to be used with the {help frmt_opts##tex:{bf:tex}} option, they are replaced by $<$,$>$ and $|$,$|$ so that they show up correctly in TeX documents.

{pmore}
{opt brackets} has no effect when the {help frmt_opts##nosubstats:{bf:nosubstats}} option is in effect.{p_end}
{marker nobrket}{...}

{phang}
{opt nobrket} eliminates the application of {opt brackets}, so that there would be no brackets around the second or higher statistics.{p_end}
{marker dbldiv}{...}

{phang}
{opt dbldiv(text)} is a rather obscure option that allows you to change the symbol that divides double statistics.  Double statistics have both a lower and and upper statistic, like confidence intervals.  
The default is a dash "-" between the lower and upper statistics, but {opt dbldiv} allows you to substitute something else.  
For example, {cmd:dbldiv(}:{cmd:)} would put a colon between the lower and upper statistics.{p_end}
{marker greek}{...}


{title: Inline text formatting: superscripts, italics, Greek characters, etc.}

{pstd}
The {help frmt_opts##fonts:font specification options} allow users to control font characteristics at the table cell level, 
but users often want change the formatting of a word or just a character in text or a table cell.  
This is true for characteristics like superscripts, subscripts, italics, bold text, and special characters such as Greek letters.  

{pstd}
Text strings in the formatted table can include inline formatting codes that change the characteristics of just part of a string.  
These codes are distinct between Word and TeX files, since they are really just Word and TeX formatting codes that are passed directly to the output files.

{pstd}
See {help outreg_complete##xmpl12:outreg Example 12} for an application of inline formatting codes in a Word table.

{pstd}
{it:Word inline formatting}

{pstd}
The Word files are written in the Word Rich Text Format (RTF) specification.  
Most of the RTF specification codes can be included in the formatted text (find the full 210 page specification in the links of 
{browse "http://en.wikipedia.org/wiki/Rich_Text_Format":en.wikipedia.org/wiki/Rich_Text_Format}).  
This note will explain a subset of the most useful codes.

{pstd}
Word RTF codes at enclosed in curly braces "{" and "}".  
Codes start with a backslash character "\" and then the code word. 
There must be a space after the code word before the text begins so that the text is distinguished from the code. 
For example, the formatting to italicize the letter "F" is "{\i F}", because "i" is the RTF code for italics.  

{pstd}
Be very careful to match opening and closing curly brackets because the consistency of the nested curly brackets in a Word file is essential to the file's integrity.  
If one of the curly brackets is missing, the Word file may be corrupted and unreadable.  
You can trace problems of this kind by temporarily removing inline formatting that includes curly braces.

{p2colset 11 25 37 10}{...}
{p2col:RTF code}action{p_end}
{p2line}
{p2colset 13 25 37 10}{...}
{p2col:{opt \i}}italic{p_end}
{p2col:{opt \b}}bold{p_end}
{p2col:{opt \ul}}underline{p_end}
{p2col:{opt \scaps}}small capitals{p_end}
{p2col:{opt \sub}}subscript (and shrink point size){p_end}
{p2col:{opt \super}}superscript (and shrink point size){p_end}
{p2col:{opt \fs#}}font size (in points * 2; e.g. 12 point is \fs24){p_end}
{p2colset 11 25 37 10}{...}
{p2line}

{pstd}
Most of these codes are the same as those used in the {help frmt_opts##fonts:font formatting options}, but there are some  differences, such as the font size code \fs# using half points, not points.

{pstd}
{it:Greek and other Unicode characters in Word}

{pstd}
Word RTF files can display Greek letters and any other Unicode character (as long as it can be represented by the font type you are using).  
The codes are explained {help greek_in_word:here}.  
Unicode codes in Word are an exception to the rule that RTF formatting codes must be followed by a space before text.  
Text can follow immediately after the Unicode code.

{pstd}
{it:TeX inline formatting}

{pstd}
The discussion of TeX inline formatting is brief because TeX users are usually familiar with inserting their own formatting codes into text.  
Many online references explain how to use TeX formatting codes.  
A good place to start is the references section of {browse "http://en.wikipedia.org/wiki/TeX":en.wikipedia.org/wiki/TeX}.  

{pstd}
For many formatting effects, TeX can generate inline formatting in two alternative ways: in math mode, which surrounds the formatted text or equation with dollar signs ("$"), 
or in text mode which uses a backslash followed by formating code and text in curly brackets. 

{pstd}
For example, we can create a superscipted number 2 either as "$^2$" in math mode or "\textsuperscript{2}" in text mode.  
To display R-squared in a TeX document with the "R" italicized and a superscript "2", one can either use the code {bind:"$ R^2$"} or the code "\it{R}\textsuperscript{2}".  

{pstd}
Note the space between the "$" and "R" in "$ R^2$", which is a Stata, not a TeX, issue.  
If we had instead written "$R^2$", Stata would have interpreted the $R as a global macro, which is probably undefined and empty, so the TeX document would just contain "^2$".  
Whenever using TeX inline formatting in math mode which starts with a letter, make sure to place a space between the "$" and the first letter.

{pstd}
Math mode generally italicizes text and is designed for writing formulas.  
A detailed discussion of its capabilities is beyond the scope of this note.  
Below is a table of useful text mode formatting codes.

{p2colset 11 35 37 15}{...}
{p2col:TeX code}action{p_end}
{p2line}
{p2colset 13 35 37 15}{...}
{p2col:{opt \it}}italic{p_end}
{p2col:{opt \bf}}bold{p_end}
{p2col:{opt \underline}}underline{p_end}
{p2col:{opt \sc}}small capitals{p_end}
{p2col:{opt \textsubscript}}subscript (and shrink point size){p_end}
{p2col:{opt \textsuperscript}}superscript (and shrink point size){p_end}
{p2colset 11 35 37 15}{...}
{p2line}

{pstd}
Keep in mind that many of the non-alphanumeric characters have special meaning in TeX, namely _, %, #, $, &, ^, {, }, ~, and \.  
If you want these characters to be printed in TeX like any other character, include a \ in front of the character.  
The exceptions are the last two, ~ and \ itself.  ~ is represented by \textasciitilde, and \ is represented by either \textbackslash or $\backslash$ to render properly in TeX.

{pstd}
{it:Greek letters in TeX}

{pstd}
Greek letters can be coded in TeX documents with a backslash and the name of the letter written in English, surrounded by "$".  
For example, a lowercase delta can be inserted with the code "$\delta$".  
Upper case Greek letters use the name in English with an initial capital, so an uppercase delta is "$\Delta$".  
If you can't remember how to spell Greek letters in English, look at the table for Greek letter codes in Word {help greek_in_word:here}.{p_end}
{marker spec_notes}{...}

