{smcl}
{* *! version 4.09  20aug2012}{...}
{cmd:help outreg_complete}
{hline}

{title:Title}

    {hi:outreg} {c -} reformat and write regression tables to a document file

{pstd}
{it:n.b.} {hi:outreg} has many options. For basic options only, see {help outreg:basic outreg}.

{pstd}
For an explanation of the large changes to {cmd:outreg} since the previous version, see {help outreg_update:outreg updates}.


{title:Syntax}

{p 8 17 2}
{cmd:outreg}
[{cmd:using} {it:filename}]
[{cmd:,} {it:options}]

{title:Description}

{pstd}
{cmd:outreg} can arrange the results of Stata estimation commands in tables as they are typically presented in journal articles, rather than as they are presented in the Stata Results window. 
By default, {it:t} statistics appear in parentheses below the coefficient estimates with asterisks for significance levels.

{pstd}
{cmd:outreg} provides as complete control of the layout and formatting of estimation tables as possible, both in Word and TeX files.  
Almost every aspect of the table's structure and format (including fonts) can be specified with options.  Multiple tables can be written to the same document, with paragraphs of text in between, creating a whole statistical appendix.

{pstd}
{cmd:outreg} works after any estimation command in Stata (see {help estimation commands} for a complete list*). 
Like {help predict}, {cmd:outreg} makes use of internally saved estimation results, so it should be invoked after the estimation.

{pstd}
{cmd:outreg} creates a Microsoft Word file by default, or a TeX file using the {help frmt_opts##tex:tex} option.  
In addition, the table created by {cmd:outreg} is displayed in the Results window, minus some of the finer formatting destined for the Word or TeX file.

{pstd}
Successive estimation results, which may use different variables, can be combined by {cmd:outreg} into a single table using the {help frmt_opts##merge:merge} option.  
(n.b. In previous versions of {cmd:outreg}, the {cmd:merge} option was called "append".){p_end}

{phang2}
* To be precise, {cmd:outreg} can display results after every {help estimation commands:estimation command} which saves both e(b) and e(V) values.  
Estimation commands which do not save both e(b) and e(V) are {help ca}, {help candisc}, {help discrim}, {help exlogistic}, {help expoisson}, {help factor},  {help mca}, {help mds}, {help mfp}, {help pca}, {help procrustes}, 
{help svy tabulate:svy:tabulate}.  
The estimates from these estimation commands (in the e() matrices) can be turned into a Word or TeX table with the {help frmttable:{bf:frmttable}} command.
{cmd:outreg} {it:can} display the results of the commands {help mean}, {help ratio}, {help proportion}, and {help total} which may not be thought of as estimation commands, and these commands accept the {help svy:svy:} prefix.


{p2colset 5 30 30 0}{...}
{p2col:{it:options categories}}Description{p_end}
{p2line}
{p2col:{it:{help outreg_complete##est_opts:estimates selection}}}
which statistics are displayed in table{p_end}
{p2col:{it:{help outreg_complete##est_for_opts:estimates formatting}}}
numerical formatting & arrangement of estimates{p_end}
{p2col:{it:{help outreg_complete##text_add_opts:text additions}}}
titles, notes, added rows and columns{p_end}
{p2col:{it:{help outreg_complete##col_form_opts:text formatting:}}}
{p2colset 8 30 30 0}{p_end}
{p2col:{it:{help outreg_complete##col_form_opts:column formatting}}}
column widths, justification, etc.{p_end}
{p2col:{it:{help outreg_complete##font_opts:fonts}}}
font specifications for table{p_end}
{p2col:{it:{help outreg_complete##lines_spaces_opts:lines & spaces}}}
horizontal and vertical lines, cell spacing{p_end}
{p2col:{it:{help outreg_complete##page_fmt_opts:page formatting}}}
page orientation and size
{p2colset 5 30 30 0}{p_end}
{p2col:{it:{help outreg_complete##file_opts:file & display options}}}
TeX files, merge, replace, etc.{p_end}
{p2col:{it:{help outreg_complete##stars_opts:stars options}}}
change stars for statistical significance{p_end}
{p2col:{it:{help outreg_complete##brack_opts:brackets options}}}
change brackets around, e.g., {it:t} stats{p_end}
{p2col:{it:{help outreg_complete##summstat_opts:summary stats options}}}
summary statistics below estimates{p_end}
{p2col:{it:{help outreg_complete##frmttable_opts:frmttable options}}}
technical options passed to {help frmttable}{p_end}
{p2line}

{pstd}
{help frmt_opts##greek:Inline text formatting: superscripts, italics, Greek characters, etc.}{p_end}
{pstd}
{help outreg_complete##spec_notes:Notes about specific estimation commands}{p_end}
{pstd}
{help outreg_complete##examples:Examples of outreg in use}{p_end}
{marker est_opts}{...}

{p2colset 5 30 30 0}{...}
{p2col:{it:{help outreg_complete##estimates_select:estimates selection}}}Description{p_end}
{p2line}
{p2col:{help outreg_complete##se:{bf:se}}}report standard errors rather than {it:t} statistics{p_end}
{p2col:{help outreg_complete##marginal:{bf:{ul:ma}rginal}}}report marginal effects instead of coefficients{p_end}
{p2col:{help outreg_complete##or:{bf:or} | {bf:hr} | {bf:irr} | {bf:rrr}}}odds ratios, that is, exp(b) instead of b{p_end}
{p2col:{help outreg_complete##stats:{bf:{ul:s}tats(}{it:statname} [{it:...}]{bf:)}}}report statistics other than b and {it:t} statistics{p_end}
{p2col:{help outreg_complete##nocons:{bf:nocons}}}drop constant estimate (don't include _cons coefficient){p_end}
{p2col:{help outreg_complete##keep:{bf:{ul:ke}ep(}{it:eqlist} | {it:varlist}{bf:)}}}include only specified coefficients{p_end}
{p2col:{help outreg_complete##drop:{bf:{ul:dr}op(}{it:eqlist} | {it:varlist}{bf:)}}}exclude specified coefficients{p_end}
{p2col:{help outreg_complete##level:{bf:{ul:l}evel(}{it:#}{bf:)}}}set level for confidence intervals; default is {bf:level(}95{bf:)}{p_end}
{p2line}
{marker est_for_opts}{...}

{p2colset 5 30 30 0}{...}
{p2col:{it:{help frmt_opts##estimates_formatting:estimates formatting}}}Description{p_end}
{p2line}
{p2col:{help outreg_complete##bdec:{bf:{ul:bd}ec(}{it:numlist}{bf:)}}}decimal places for coefficients{p_end}
{p2col:{help outreg_complete##tdec:{bf:{ul:td}ec(}{it:#}{bf:)}}}decimal places for {it:t} statistics{p_end}
{p2col:{help outreg_complete##sdec:{bf:{ul:sd}ec(}{it:numgrid}{bf:)}}}decimal places for all statistics{p_end}
{p2col:{help outreg_complete##bfmt:{bf:{ul:bf}mt(}{it:fmtlist}{bf:)}}}numerical format for coefficients{p_end}
{p2col:{help outreg_complete##sfmt:{bf:{ul:sf}mt(}{it:fmtgrid}{bf:)}}}numerical format for all statistics{p_end}
{p2col:{help outreg_complete##nosubstat:{bf:{ul:nosub}stat}}}don't put {it:t} statistics (or others) below coefficients{p_end}
{p2col:{help outreg_complete##eq_merge:{bf:{ul:e}q_merge}}}merge multi-equation coefficients into multiple columns{p_end}
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
{p2col:{help frmt_opts##table_sections:{it:table sections}}}explanation of {cmd:outreg} table sections{p_end}
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
{p2col:{help frmt_opts##a4:{bf:{ul:a4}}}}A4 size paper (instead of 8 1/2Ó x 11Ó){p_end}
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
{marker stars_opts}{...}

{p2colset 5 30 30 0}{...}
{p2col:{it:{help outreg_complete##stars_options:stars options}}}Description{p_end}
{p2line}
{p2col:{help outreg_complete##starlevels:{bf:{ul:starlev}els(}{it:numlist}{bf:)}}}significance levels for stars{p_end}
{p2col:{help outreg_complete##starloc:{bf:{ul:starloc}(}{it:#}{bf:)}}}locate stars next to which statistic (def=2){p_end}
{p2col:{help outreg_complete##margstars:{bf:{ul:margs}tars}}}calculate stars from marginal effects, not coefficients{p_end}
{p2col:{help outreg_complete##nostars:{bf:{ul:nostar}s}}}no stars for significance{p_end}
{p2col:{help outreg_complete##nolegend:{bf:{ul:nole}gend}}}no legend explaining significance levels{p_end}
{p2col:{help outreg_complete##sigsymbols:{bf:{ul:si}gsymbols(}{it:textrow}{bf:)}}}symbols for significance (in place of stars){p_end}
{p2line}
{marker brack_opts}{...}

{p2colset 5 43 43 0}{...}
{p2col:{it:{help frmt_opts##brack_options:brackets options}}}Description{p_end}
{p2line}
{p2col:{help frmt_opts##squarebrack:{bf:{ul:sq}uarebrack}}}square brackets instead of parentheses{p_end}
{p2col:{help frmt_opts##brackets:{bf:{ul:br}ackets(}{it:textpair} [ \ {it:textpair} ...]{bf:)}}}symbols with which to bracket substatistics{p_end}
{p2col:{help frmt_opts##nobrket:{bf:{ul:nobrk}et}}}put no brackets on substatistics{p_end}
{p2col:{help frmt_opts##dbldiv:{bf:{ul:dbl}div(}{it:text}{bf:)}}}symbol dividing double statistics ("-"){p_end}
{p2line}
{marker summstat_opts}{...}

{p2colset 5 33 33 0}{...}
{p2col:{it:{help outreg_complete##summstat_options:summary statistics options}}}Description{p_end}
{p2line}
{p2col:{help outreg_complete##summstat:{bf:{ul:summs}tat(}{it:e_values}{bf:)}}}additional summary statistics below coefficients{p_end}
{p2col:{help outreg_complete##summdec:{bf:{ul:summd}ec(}{it:numlist}{bf:)}}}decimal places for summary statistics{p_end}
{p2col:{help outreg_complete##summtitles:{bf:{ul:summt}itles(}{it:textgrid}{bf:)}}}row titles for summary statistics{p_end}
{p2col:{help outreg_complete##noautosumm:{bf:{ul:noau}tosumm}}}no automatic summary stats (R^2, N){p_end}
{p2line}
{marker frmttable_opts}{...}

{p2colset 5 30 30 0}{...}
{p2col:{help outreg_complete##frmttable_options:{it:frmttable options}}}Description{p_end}
{p2line}
{p2col:{help outreg_complete##blankrows:{bf:{ul:bl}ankrows}}}allow (don't drop) blank rows in table{p_end}
{p2col:{help outreg_complete##nofindcons:{bf:{ul:nofi}ndcons}}}don't assign _cons to separate section of table{p_end}
{p2line}


{marker estimates_select}{...}
{dlgtab:Estimates selection}
{marker se}{...}

{phang}
{opt se} specifies that standard errors rather than {it:t} statistics
are reported in parentheses below the coefficient estimates. The decimal places displayed are those set by {help outreg_complete##bdec:bdec}.{p_end}
{marker marginal}{...}

{phang}
{opt marginal} specifies that marginal effects rather than coefficients are reported.  
The {it:t} statistics are for the hypothesis that the marginal effects, not the coefficients, are equal to zero, and the asterisks report the significance of this hypothesis test.  
{opt marginal} is equivalent to {help outreg_complete##stats:stats(b_dfdx t_abs_dfdx)} (or {bf:stats(}b_dfdx se_dfdx{bf:)} if the {opt se} option is used) combined with the {help outreg_complete##margstars:margstars} option.{p_end}
{marker or}{marker hr}{marker irr}{marker rrr}{...}

{phang}
{opt or | hr | irr | rrr} cause the coefficients to be displayed in exponentiated form: for each coefficient, exp(b) rather than b is displayed.  Standard errors and confidence intervals are also transformed.  
Display of the intercept, if any, is suppressed. These options are identical, but by convention different estimation methods use different names.

{p2colset 11 35 37 30}{...}
{p2col:exponentiation option}name{p_end}
{p2line}
{p2colset 13 35 37 30}{...}
{p2col:{opt or}}odds ratio{p_end}
{p2col:{opt hr}}hazard ratio{p_end}
{p2col:{opt irr}}incidence-rate ratio{p_end}
{p2col:{opt rrr}}relative-risk ratio{p_end}
{p2colset 11 35 37 30}{...}
{p2line}

{pmore}
Note that after commands such as {help stcox}, which report coefficients in exponentiated form by default, you must use one of the exponentiation options for the {cmd:outreg} 
table to display exponentiated coefficients and standard errors as they are displayed in the Results window after {cmd:stcox} command.

{pmore}
The exponentiation options are equivalent to the option {opt stats(e_b t)} (or {opt stats(e_b e_se)} if the {opt se} option is in effect).

{pmore}
These options correspond to the {opt or} option used for {help logit}, {help clogit}, and {help glogit} estimation, {opt irr} for {help poisson} estimation, {opt rrr} for {help mlogit}, {opt hr} for {help stcox} hazard models, 
and {opt eform} for {help xtgee}, but they can be used to exponentiate the coefficients after any estimation. 
Exponentiation of coefficients is explained in {bf:[R] maximize - methods and formulas}.{p_end}
{marker stats}{...}

{phang}
{cmd:stats(}{it:{help outreg_complete##statname:statname}} [{it:...}]{cmd:)}    specifies the statistics to be displayed; the default is equivalent to    specifying {opt stats(b t_abs)}.
Multiple statistics are arranged below each other (unless you use the {help outreg_complete##nosubstat:nosubstat} option), with varying {help frmt_opts##brackets:brackets}.  Available statistics are: {p_end}
{marker statname}{...}

{p2colset 11 23 37 3}{...}
{p2col:statname}definition{p_end}
{p2line}
{p2colset 13 25 37 3}{...}
{p2col:{opt b}} coefficient estimates{p_end}
{p2col:{opt se}} standard errors of estimate{p_end}
{p2col:{opt t}} {it:t} statistics for the test of b=0{p_end}
{p2col:{opt t_abs}} absolute value of {it:t} statistics{p_end}
{p2col:{opt p}} {it:p} value of {it:t} statistics{p_end}
{p2col:{opt ci}} confidence interval of estimates{p_end}
{p2col:{opt ci_l}} lower confidence interval of estimates{p_end}
{p2col:{opt ci_u}} upper confidence interval of estimates{p_end}
{p2col:{opt beta}} normalized beta coefficients (see the beta option of {help regress}){p_end}
{p2col:{opt e_b}} exponentiated form of the coefficients.{p_end}
{p2col:{opt e_se}} exponentiated standard errors{p_end}
{p2col:{opt e_ci}} exponentiated confidence interval{p_end}
{p2col:{opt e_ci_l}} exponentiated lower confidence interval{p_end}
{p2col:{opt e_ci_u}} exponentiated upper confidence interval{p_end}
{p2col:{opt b_dfdx}} marginal effect of the coefficients (requires {help margins}){p_end}
{p2col:{opt se_dfdx}} standard errors of marginal effects{p_end}
{p2col:{opt t_dfdx}} {it:t} statistics of marginal effects{p_end}
{p2col:{opt t_abs_dfdx}} absolute value of {it:t} statistics of marginal effects {p_end}
{p2col:{opt p_dfdx}} {it:p} values of {it:t} statistics of marginal effects{p_end}
{p2col:{opt ci_dfdx}} confidence interval of marginal effects{p_end}
{p2col:{opt ci_l_dfdx}} lower confidence interval of marginal effects{p_end}
{p2col:{opt ci_u_dfdx}} upper confidence interval of marginal effects{p_end}
{p2col:{opt at}} values around which marginal effects were estimated{p_end}
{p2colset 11 23 37 3}{...}
{p2line}
{p2colreset}{...}
{marker nocons}{...}

{phang}
{opt nocons} drops the constant estimate from the table.{p_end}
{marker keep}{marker drop}{...}

{phang}
{cmd:keep(}{it:{help outreg_complete##eqlist:eqlist}} | {it:{help outreg_complete##coeflist:coeflist}}{cmd:)} includes only the specified coefficients (and potentially reorders included coefficients).{p_end}
{phang}
{cmd:drop(}{it:{help outreg_complete##eqlist:eqlist}} | {it:{help outreg_complete##coeflist:coeflist}}{cmd:)} excludes the specified coefficients.{p_end}

{pmore}
{marker eqlist}{...}
{it:eqlist} (equation list) consists of {it:eqname:} [{it:coeflist}] [{it:eqname}: [{it:coeflist}] ...].{p_end}

{pmore}
{marker coeflist}{...}
{it:coeflist} (coefficient list) is like a {it:varlist} but can include "{bf:_cons}" for the constant coefficient, or other parameter names.  
{help fvvarlist:Factor variable} notation can be included.
The {it:coeflist} can include any of the simple column names of the {bf:e(b)} coefficient vector, which forms the basis of the table created by {cmd:outreg}.
You can see the contents of the {bf:e(b)} vector after an estimation command by typing {cmd:matrix list e(b)}.  If using marginal effects (after the {help margins} command) rather than coefficient estimates, the relevant vector is {bf:r(b)}.

{pmore}
{it:eqname} is a second level column name of the {bf:e(b)} vector used for multi-equation estimation commands, such as {help reg3} or {help mlogit}.  
Many Stata estimation commands attach additional parameters to the coefficient vector {bf:e(b)} with a distinct equation name.  
For instance, the {help xtreg:xtreg,fe} command includes two parameters in {bf:e(b)} with {it:eqnames} "{bf:sigma_u:}" and "{bf:sigma_e:}".
The {it:coeflist} for each of these {it:eqnames} is "{bf:_cons}".    

{pmore}
To report only the coefficient estimates without additional parameters in the {bf:e(b)} vector, it usually works to use the {cmd:keep(}{it:depvar}:{cmd:)} option, since the coefficients are given an {it:eqname} of the dependent variable.

{pmore}
You can use the {opt keep} option to reorder variables for the formatted {cmd:outreg} table.  The estimation coefficients will be displayed in the order specified in {opt keep}.  
Don't forget to include "{bf:_cons}" in the reordered {it:coeflist} if you want the constant coefficient term to be included in the formatted table.  
By default, the "{bf:_cons}" term is always displayed last in {cmd:outreg} even if it is not listed last in the {opt keep} {it:coeflist}.  
To display the "{bf:_cons}" coefficient other than last, combine the {opt keep} option with the {help outreg_complete##nofindcons:nofindcons} option.
If you want the "{bf:_cons}" coefficient not to be last and are merging multiple tables, you must specify the {opt nofindcons} option with all the tables being merged, whether you employ the {opt keep} option for them or not, 
to insure that the coefficients merge properly.

{pmore}
If in doubt about what variable names, or especially equation names, to include in keep or drop, use {cmd:matrix list e(b)} (or {cmd:matrix list r(b)} for marginal effects) to see what names are assigned to saved estimation results.

{pmore}
You may have problems with {opt keep} and {opt drop} if you have chosen both coefficients and marginal effects as statistics, 
since they usually do not have the same {it:coeflist} in both cases due to the absence of a constant coefficient estimate in the marginal effects.  
A {opt keep} option that included "{opt _cons}" would result in an error message because no constant could be found in the marginal effects.  
In this case, you could only {opt keep} or {opt drop} variables occurring in both vectors.  However, if you are using {opt drop}, you can still eliminate the constant term with the {opt nocons} option.{p_end}
{marker level}{...}

{phang}
{opt level(#)} sets the significance level for confidence intervals, which are included in the {cmd:outreg} table using the {opt stats(ci)} option.  
The default is level(95) for a 95% confidence level. Note that {opt level} has no impact on the asterisks for the statistical significance of coefficients (for this, see {help outreg_complete##starlevels:starlevels}). 
For more information about {opt level} see {helpb estimation options##level():[R] estimation options - level}.  The default {opt level} can be set for all Stata commands, including {cmd:outreg} using the {help set level} command.{p_end}

{marker estimates_formatting}{...}
{dlgtab:Estimates formatting}
{marker bdec}{...}

{phang}
{cmd:bdec(}{it:{help numlist}}{cmd:)} specifies the number of decimal places reported for coefficient estimates (the b's).  
It also specifies the decimal places reported for standard errors if the {cmd:se} option is in effect.  
The default value for {cmd:bdec} is 3. 
The minimum value is 0 and the maximum value is 15.  If one number is specified in {cmd:bdec}, it will apply to all coefficients.  If multiple numbers are specified in {cmd:bdec}, 
the first number will determine the decimals reported for the first coefficient, the second number, the decimals for the second coefficient, etc. 
If there are fewer numbers in {cmd:bdec} than coefficients, the last number in {cmd:bdec} will apply to all the remaining coefficients.

{pmore}
The decimal places applied to each coefficient are also applied to the corresponding standard errors, confidence intervals, beta coefficients, and marginal effects, if they are included with the {opt se} or {opt stats} options.{p_end}
{marker tdec}{...}

{phang}
{opt tdec(#)} specifies the number of decimal places reported for {it:t} statistics.  The default value for {cmd:tdec} is 2. The minimum value is 0 and the maximum value is 15.{p_end}
{marker sdec}{...}

{phang}
{opt sdec(numgrid)} is for finer control of the decimal places of estimates than is possible with {opt bdec} and {opt tdec}, but is rarely needed.  
The {opt sdec} {it:numgrid} corresponds to the decimal places for each of the statistics in the table.  
It can be used, for instance, to specify different decimal places for coefficients versus standard errors ({opt bdec} applies to both), or to allow varying decimal places for {it:t} statistics.{p_end}

{pmore}
{it:numgrid} is a grid of intergers 0-15 in the form used by {bf:{help matrix define}}.  Commas separate elements along a row, and backslashes ("\") separate rows: {it:numgrid} has the form #[,#...] [\ #[,#...] [...]].  
For example, if the table of statistics has three rows and two columns, the {opt sdec(numgrid)} could be {bf:sdec(}1,2 \ 2,2 \ 1,3{bf:)}.  If you specify a grid smaller than the table of statistics created by {cmd:outreg}, 
the last rows and columns of the {opt sdec} {it:numgrid} will be repeated to cover the whole table.  Unbalanced rows or columns will not cause an error.  They will be filled in, and {cmd:outreg} will display a warning message.{p_end}
{marker bfmt}{...}

{phang}
{opt bfmt(fmtlist)} specifies the numerical format for coefficients.  

{pmore}
{it:fmtlist} consists of {it:fmt} [{it:fmt} ...]] where {it:fmt} is either e, f, fc, g, or gc:

{p2colset 11 22 37 20}{...}
{p2col:fmt code}format type{p_end}
{p2line}
{p2colset 13 22 37 20}{...}
{p2col:{opt e}}exponential (scientific) notation{p_end}
{p2col:{opt f}}fixed number of decimals{p_end}
{p2col:{opt fc}}fixed with commas for thousands, etc. -  the default for {cmd:outreg}{p_end}
{p2col:{opt g}}"general" format (see {help format}){p_end}
{p2col:{opt gc}}"general" format with commas for thousands, etc.{p_end}
{p2colset 11 22 37 20}{...}
{p2line}

{pmore}
The {cmd:g} formats do not allow the user to control the number of decimal places displayed.

{pmore}
Like {opt bdec}, if one format is specified in {cmd:bfmt}, it will apply to all coefficients.  
If multiple format codes are specified in {cmd:bfmt}, 
the first format will apply to the first coefficient, the second format, the second coefficient, etc. 
If there are fewer formats in {it:fmt} than coefficients, the last format in {cmd:bfmt} will apply to all the remaining coefficients. 
The format applied to each coefficient is also applied to the corresponding standard errors, confidence intervals, beta coefficients, and marginal effects, if they are specified in {opt se} or {opt stats}.{p_end}
{marker sfmt}{...}

{phang}
{opt sfmt(fmtgrid)} is for finer control of the numerical formats of estimates than is possible with {help outreg_complete##bfmt:bfmt}, but is rarely needed. 
The {opt sfmt} {it:fmtgrid} is a grid of the format types (e, f, g, fc, or gc) for each statistic in the table.  
For example, {opt sfmt} could be used to assign different numerical formats for the coefficients in different columns of a multi-equation estimation, or to change the format for {it:t} statistics.

{pmore}
The {it:fmtgrid} in {opt sfmt} has the same form as the {it:numgrid} of the {help outreg_complete##sdec:sdec} option above.
{p_end}
{marker nosubstat}{...}

{phang}
{opt nosubstat} puts additional statistics, like {it:t} statistics or other "sub-statistics", in columns to the right of coefficients, rather than below them.  
Applying the {opt nosubstat} with the default statistics of {opt b} and {opt t_abs}, the {cmd:outreg} table would have one only row, but two columns, for each coefficient.  
For example, the command {cmd:outreg using test, nosubstat stats(}b se t p ci_l ci_u{cmd:)} will arrange regression output the way it is displayed in the Stata Results window after the {help regress} command, 
with each statistic in a separate column.  
In this case, for each variable in the regression, there is one row of results, but six columns, of statistics (see {help outreg_complete##xmpl15:Example 15}).{p_end}
{marker eq_merge}{...}

{phang}
{opt eq_merge} merges multi-equation estimation results into multiple columns, one column per equation.  By default, {cmd:outreg} displays the equations one below the other in a single column.  
{opt eq_merge} is most useful after estimation commands like {help reg3}, {help sureg}, {help mlogit}, and {help mprobit}, where many or all of the variables recur in each equation.  
The coefficients are merged as if the equations were estimated one at a time, and the results were sequentially combined with the {opt merge} option.{p_end}

{marker stars_options}{...}
{dlgtab:Stars options}
{marker starlevels}{...}

{phang}
{cmd:starlevels(}{it:{help numlist}}{cmd:)} indicates significance levels for stars in percent.  
By default, one star is placed next to coefficients which pass the test for significant difference from zero at the 5% level, 
and two stars are placed next to coefficients that pass the test for significance at the 1% level, which is equivalent to specifying {opt starlevels(5 1)}.  
To place one star for the 10% level, 2 for the 5% level, and 3 for the 1% level, you would specify {opt starlevels(10 5 1)}.  
To place one star for the 5% level, 2 for the 1% level, and 3 for the 0.1% level, you would specify {opt starlevels(5 1 .1)}.

{pmore}
{help outreg##xmpl5:Example 5} applies the {opt starlevels} option.{p_end}
{marker starloc}{...}

{phang}
{opt starloc(#)} put stars next to the statistic indicated.  
By default, stars are displayed next to the second statistic ({opt starloc(2)}), but they can be placed next to the first statistic (usually the coefficient estimate) 
or next to third or higher statistic if they have been specified in {help outreg_complete##stats:stats}.{p_end}
{marker margstars}{...}

{phang}
{opt margstars} calculates stars for significance from marginal effects (and their standard errors), rather than from the coefficients themselves, which is the default.{p_end}
{marker nostars}{...}

{phang}
{opt nostars} suppresses the stars indicating significance levels.{p_end}
{marker nolegend}{...}

{phang}
{opt nolegend} indicates that there will be no legend explaining the stars for  significance levels below the table (by default, the legend is "* {it:p}<0.05; ** {it:p}<0.01").  
To replace the legend, use the {opt nolegend} option, and put your own legend in a {help frmt_opts##note:note}.{p_end}
{marker sigsymbols}{...}

{phang}
{cmd:sigsymbols(}{it:{help frmt_opts##textrow:textrow}}{cmd:)} replaces the stars used to indicate statistical significance with other symbols of your choice.  
For example, to use a plus sign "+" to indicate a 10% significance level, you could apply {opt sigsymbols(+,*,**)} along with {opt starlevels(10 5 1)}.  
By default, {cmd:outreg} uses one star for the first significance level, and adds an additional star for each additional significance level displayed.

{pmore}
The argument {it:textrow} consists of text separated by commas.

{pmore}
{help outreg##xmpl5:Example 5} applies the {opt sigsymbols} option.{p_end}

{marker summstat_options}{...}
{dlgtab:Summary statistics options}
{marker summstat}{...}

{phang}
{opt summstat(evaluegrid)} places summary statistics below the coefficient estimates.  {it:evaluegrid} is a grid of the names of different e() return values already calculated by the estimation command.  
The syntax of the {it:evaluegrid} is the same as the other grids in {cmd:outreg}.  Elements within a row are separated with commas (","), and rows are separated by backslashes ("\").  
The default value of {opt summstat} is {opt summstat(r2 \ N)} (when e(r2) is defined), which places the R-squared statistic e(r2) below the coefficient estimates, and the number of observations e(N) below that.  

{pmore}
To replace the R-squared with the adjusted R-squared stored in e(r2_a), you could use the options {opt summstat(r2_a \ N)} and {opt summtitle("Adjusted R2" \ "N")}.  
You can also specify the decimal places for the summary statistics with the {help outreg_complete##summdec:summdec} option.  
To see a complete list of the e() macro values available after each estimation command, type {cmd:ereturn list}.

{pmore}
Statistics not included in the e() return values can be added to the table with the {help frmt_opts##addrows:addrows} option as in {help outreg##xmpl7:Example 7}.

{pmore}
See an application of {opt summstat} in {help outreg##xmpl5:Example 5}.{p_end}
{marker summdec}{...}

{phang}
{cmd:summdec(}{it:{help numlist}}{cmd:)} designates the decimal places displayed for summary statistics in the manner of {help outreg_complete##bdec:bdec}.{p_end}
{marker summtitles}{...}

{phang}
{cmd:summtitles(}{it:{help frmt_opts##textgrid:textgrid}}{cmd:)} designates row titles for summary statistics in the same manner as {help frmt_opts##rtitles:rtitles}.{p_end}
{marker noautosumm}{...}

{phang}
{opt noautosumm} eliminates the automatically generated summary stats (R-squared, if there is one, and the number of observations) from the {cmd:outreg} table.{p_end}

{marker frmttable_options}{...}
{dlgtab:frmttable options}
{marker blankrows}{...}

{phang}
{opt blankrows} allows blank rows (across all columns) in the body of the {cmd:outreg} table to remain blank without being deleted.  
By default, {cmd:outreg} sweeps out any completely blank rows.  
This option is useful if you want to use blank rows to separate different parts of the table.{p_end}
{marker nofindcons}{...}

{phang}
{opt findcons} is a technical option that finds rows of {bf:statmat} with row titles "_cons" and puts them in a separate row section.  
Usually finding the constant is needed to ensure that new variables coefficients are {help frmt_opts##merge:merge}d in correctly, above the constant term, when multiple estimations are merged together.  
This option is most likely to be useful when you don't want the "_cons" term to be last when using the {help outreg_complete##keep:keep} option, or when merging with a non-{cmd:outreg} table that treats constants differently.{p_end}
{marker greek}{...}

{title: Notes about specific estimation commands}

{phang}
{help rocfit} reports a {it:t} statistic for the null hypothesis that the slope is equal to 1.  {cmd:outreg} reports the {it:t} statistic for the null hypothesis that the slope is equal to 0.

{phang}
{help stcox} and {help streg} report hazard ratios by default, and the coefficients only if the {opt nohr} option is employed.  {cmd:outreg} does the reverse. 
To show the hazard rates in the {cmd:outreg} table, use the {help outreg_complete##hr:hr} option.{p_end}

{phang}
{help mim} is a user-written command that makes multiple imputations (see also the Stata command {help mi}).  
{cmd:mim} does not store the estimation results in the {opt e(b)} and {opt e(V)} matrices, so it is necessary to repost them to these matrices before {cmd:outreg} can access the {cmd:mim} results.  
This is accomplished with the following commands:

	{cmd}. mat b = e(MIM_Q)
	{cmd}. mat V = e(MIM_V)
	{cmd}. ereturn post b V, depname(`e(MIM_depvar)') obs(`e(MIM_Nmin)') ///
	     dof(`e(MIM_dfmin)')
{txt}
{pmore}
After these commands, {cmd:outreg} can be used in the usual manner.{p_end}
{marker examples}{...}


{title:Examples}

1.  {help outreg##examples:Basic usage and variable labels}
2.  {help outreg##xmpl2:Decimal places for coefficients and titles}
3.  {help outreg##xmpl3:Merging estimation tables together}
4.  {help outreg##xmpl4:Standard errors, no stars, and square brackets in a TeX file}
5.  {help outreg##xmpl5:10% significance level and summary statistics}
6.  {help outreg_complete##xmpl6:Display some but not all coefficients}
7.  {help outreg_complete##xmpl7:Add statistics not in summstat}
8.  {help outreg_complete##xmpl8:Multi-equation models}
9.  {help outreg_complete##xmpl9:Marginal effects and star options}
10. {help outreg_complete##xmpl10:Multi-column ctitles; merge variable means to estimation results}
11. {help outreg_complete##xmpl11:Specifying fonts}
12. {help outreg_complete##xmpl12:Superscripts, italics, and Greek characters}
13. {help outreg_complete##xmpl13:Place additional tables in same document}
14. {help outreg_complete##xmpl14:Place footnotes among coefficients}
15. {help outreg_complete##xmpl15:Show statistics side-by-side, like Stata estimation results}
16. {help outreg_complete##xmpl16:Merge multiple estimations in a loop}
{marker xmpl6}

{title:Example 6.  Display some but not all coefficients}

{pstd}
The options {help outreg_complete##keep:keep} and {help outreg_complete##drop:drop} allow you to display some but not all coefficients in the estimation.  
{opt keep} also allows you to change the order in which the coefficient estimates are displayed.  
To {opt keep} or {opt drop} the constant term, include "_cons" in the list of coefficients.

{pstd}
The first example removes dummy variable coefficients and reorders the coefficients with {opt keep(weight foreign)}:

	{cmd}. tab rep78, gen(repair)
	{txt}({it:output omitted})
	
	{cmd}. regress mpg foreign weight repair1-repair4
	{txt}({it:output omitted})
	
	{cmd}. outreg using auto, keep(weight foreign) varlabels replace ///
	     note(Coefficients for repair dummy variables not shown)
	{res}
	{txt}{center:{hline 32}}
	{center:{txt}{lalign 15:}{txt}{center 15:Mileage (mpg)}}
	{txt}{center:{hline 32}}
	{center:{txt}{lalign 15:Weight (lbs.)}{res}{center 15:-0.006}}
	{center:{txt}{lalign 15:}{res}{center 15:(9.16)**}}
	{center:{txt}{lalign 15:Car type}{res}{center 15:-2.923}}
	{center:{txt}{lalign 15:}{res}{center 15:(2.18)*}}
	{center:{txt}{lalign 15:R2}{res}{center 15:0.69}}
	{center:{txt}{lalign 15:N}{res}{center 15:69}}
	{txt}{center:{hline 32}}
	{txt}{center:* p<0.05; ** p<0.01}
	{txt}{center:Coefficients for repair dummy variables not shown}

{pstd} 
The {opt keep} and {opt drop} options can use the wildcard characters *, ?, and ~.  
They can also use {help factor variable} notation.

{pstd}
The second example uses {opt keep} to remove from the table the auxiliary parameters included in e(b) by Stata.  
The {help tobit} command estimates a sigma parameter.  
The main coefficient estimates are included in the e(b) vector with the equation name "model" and the sigma parameter is given the equation name "sigma".  
When in doubt about which equation names are included in the e(b) vector after an estimation, you can view the matrix and its names with the {help matrix list:matrix list e(b)} command.
{cmd:outreg} includes the sigma parameter and the equation names in the estimates table.

	{cmd}. gen wgt = weight/100
	{cmd}. label var wgt "Weight (lbs/100)"
	{cmd}. tobit mpg wgt, ll(17)
	{txt}({it:output omitted})
	
	{cmd}. outreg using auto, replace 
	{res}
	{txt}{center:{hline 27}}
	{center:{txt}{lalign 7:model}{txt}{lalign 7:wgt}{res}{center 11:-0.687}}
	{center:{txt}{lalign 7:}{txt}{lalign 7:}{res}{center 11:(9.82)**}}
	{center:{txt}{lalign 7:}{txt}{lalign 7:_cons}{res}{center 11:41.499}}
	{center:{txt}{lalign 7:}{txt}{lalign 7:}{res}{center 11:(20.16)**}}
	{center:{txt}{lalign 7:sigma}{txt}{lalign 7:_cons}{res}{center 11:3.846}}
	{center:{txt}{lalign 7:}{txt}{lalign 7:}{res}{center 11:(10.50)**}}
	{center:{txt}{lalign 7:N}{txt}{lalign 7:}{res}{center 11:74}}
	{txt}{center:{hline 27}}
	{txt}{center:* p<0.05; ** p<0.01}

{pstd}
To limit the table to the coefficient estimates alone, we can use the option {cmd:keep(}{it:model:}{cmd:)}. 
The colon after "model" indicates that it is an equation name, not a coefficient name, and all estimates in the "model" equation are kept.

	{cmd}. outreg using auto, keep(model:) varlabel replace
	{res}
	{txt}{center:{hline 35}}
	{center:{txt}{lalign 18:}{txt}{center 15:Mileage (mpg)}}
	{txt}{center:{hline 35}}
	{center:{txt}{lalign 18:Weight (lbs/100)}{res}{center 15:-0.687}}
	{center:{txt}{lalign 18:}{res}{center 15:(9.82)**}}
	{center:{txt}{lalign 18:Constant}{res}{center 15:41.499}}
	{center:{txt}{lalign 18:}{res}{center 15:(20.16)**}}
	{center:{txt}{lalign 18:N}{res}{center 15:74}}
	{txt}{center:{hline 35}}
	{txt}{center:* p<0.05; ** p<0.01}
{marker xmpl7}

{title:Example 7.  Add statistics not in summstat}

{pstd}
There are many statistics, particularly test statistics, which we may want to report in estimation tables but are not available in the {help outreg_complete##summstat:summstat} option.  
The statistics available in {opt summstat} are limited to the e( ) scalar values that can be viewed after an estimation command with {cmd:ereturn list}.

{pstd}
The {help frmt_opts##addrows:addrows} option can add additional rows of text below the coefficient estimates and summary statistics.  
This example shows how to display the results of the {help test} command as addeds rows of the {cmd:outreg} table.

{pstd}
Below we test whether the coefficient on the variable {cmd:foreign} is equal to the negative of the coefficient on {cmd:goodrep} with {cmd:test foreign = -goodrep}.  
The command {help test} saves the {it:F} statistic in the return value r(F) and its {it:p} value in the return value r(p).  
If we include r(F) and r(p) in {opt addrows} directly, they are reported with seven or eight decimal places.  
To control the numerical formatting of the return values F and p, we use the local macro directive {cmd:display}.  
{cmd:local F : display %5.2f `r(F)'} takes the value in r(F) and puts it in the local macro "F" displayed with two decimal places and a width of 5.  
Similarly, the local macro "p" has three decimal places.

	{cmd}. gen goodrep = rep78==5
	{cmd}. reg mpg weight foreign goodrep
	{txt}({it:output omitted})
	
	{cmd}. test foreign = -goodrep
	{txt}({it:output omitted})
	
	{cmd}. local F : display %5.2f `r(F)'
	{cmd}. local p : display %4.3f `r(p)'
{txt}
{pstd}
We are now ready to add the test statistics to the {cmd:outreg} table.  
The {opt addrows} option below adds two rows, one for the {it:F} test and one for its {it:p} value, and two columns, one for the text in the left column and one for the test values.  
As usual, columns of text are separated with a comma, and rows of text are separated with the backslash.

	{cmd}. outreg using auto, replace ///
	     addrows("F test: foreign = -goodrep", "`F'" \ "p value", "`p'")
	{res}
	{txt}{center:{hline 41}}
	{center:{txt}{lalign 28:}{txt}{center 11:mpg}}
	{txt}{center:{hline 41}}
	{center:{txt}{lalign 28:weight}{res}{center 11:-0.006}}
	{center:{txt}{lalign 28:}{res}{center 11:(10.40)**}}
	{center:{txt}{lalign 28:foreign}{res}{center 11:-2.745}}
	{center:{txt}{lalign 28:}{res}{center 11:(2.53)*}}
	{center:{txt}{lalign 28:goodrep}{res}{center 11:3.613}}
	{center:{txt}{lalign 28:}{res}{center 11:(2.98)**}}
	{center:{txt}{lalign 28:_cons}{res}{center 11:40.733}}
	{center:{txt}{lalign 28:}{res}{center 11:(19.59)**}}
	{center:{txt}{lalign 28:R2}{res}{center 11:0.70}}
	{center:{txt}{lalign 28:N}{res}{center 11:74}}
	{center:{txt}{lalign 28:F test: foreign = -goodrep}{res}{center 11: 0.43}}
	{center:{txt}{lalign 28:p value}{res}{center 11:0.515}}
	{txt}{center:{hline 41}}
	{txt}{center:* p<0.05; ** p<0.01}

{pstd}
If we wanted to report the {it:F} test statistics above the summary statistics (R2 and N), then we would need to use the option {opt noautosumm} to suppress the default summary statistics, 
and instead include them in the {opt addrows} option below the {it:F} test statistics. 
The values of R2 and N are available in the scalars e(r2) and e(N).{p_end}
{marker xmpl8}

{title:Example 8.  Multi-equation models}

{pstd}
{cmd:outreg} displays estimation results in a single column even for multi-equation models unless the user chooses the {help frmt_opts##eq_merge:eq_merge} option (for "equation merge").  
When different equations in the estimation model share many of the same covariates, users may prefer to display the results like the merged results of separate estimations.  
{opt eq_merge} puts each equation is a separate column and any common variables are displayed the same row.  
Using an example of seemingly unrelated regression estimation with the three equations each sharing two covariates, {cmd:outreg} organizes the table as shown below.

	{cmd}. sureg (price foreign weight length) (mpg displ = foreign weight)
	{txt}({it:output omitted})
	
	{cmd}. outreg using auto, varlabels eq_merge replace ///
	     ctitles("", Price Equation, Mileage Equation, Engine Size Equation) ///
	     summstat(r2_1, r2_2, r2_3 \ N, N, N) summtitle(R2 \ N)
	{res}
	{txt}{center:{hline 73}}
	{center:{txt}{lalign 15:}{txt}{center 16:Price Equation}{txt}{center 18:Mileage Equation}{txt}{center 22:Engine Size Equation}}
	{txt}{center:{hline 73}}
	{center:{txt}{lalign 15:Car type}{res}{center 16:3,575.260}{res}{center 18:-1.650}{res}{center 22:-25.613}}
	{center:{txt}{lalign 15:}{res}{center 16:(5.75)**}{res}{center 18:(1.57)}{res}{center 22:(2.05)*}}
	{center:{txt}{lalign 15:Weight (lbs.)}{res}{center 16:5.691}{res}{center 18:-0.007}{res}{center 22:0.097}}
	{center:{txt}{lalign 15:}{res}{center 16:(6.18)**}{res}{center 18:(10.56)**}{res}{center 22:(13.07)**}}
	{center:{txt}{lalign 15:Length (in.)}{res}{center 16:-88.271}{res}{center 18:}{res}{center 22:}}
	{center:{txt}{lalign 15:}{res}{center 16:(2.81)**}{res}{center 18:}{res}{center 22:}}
	{center:{txt}{lalign 15:Constant}{res}{center 16:4,506.212}{res}{center 18:41.680}{res}{center 22:-87.235}}
	{center:{txt}{lalign 15:}{res}{center 16:(1.26)}{res}{center 18:(19.65)**}{res}{center 22:(3.47)**}}
	{center:{txt}{lalign 15:R2}{res}{center 16:0.55}{res}{center 18:0.66}{res}{center 22:0.81}}
	{center:{txt}{lalign 15:N}{res}{center 16:74}{res}{center 18:74}{res}{center 22:74}}
	{txt}{center:{hline 73}}
	{txt}{center:* p<0.05; ** p<0.01}

{pstd}
Each of the equations in {cmd:sureg} has an R-squared statistic, so the {opt summstat} option places them below the coefficient estimates along with the number of observations.  
The {opt summstat} option has three columns and two rows.{p_end}
{marker xmpl9}

{title:Example 9.  Marginal effects and star options}

{pstd}
{cmd:outreg} can display marginal effects estimates calculated by the {help margins} command instead of coefficient estimates.  {cmd:outreg} can also display marginal effects calculated by the {help mfx} and {help dprobit} commands that were part of Stata 10 and earlier.
Displaying marginal effects requires that the user run {cmd:margins, dydx(*)} or a similar command after the estimation in question before using {cmd:outreg}.  

{pstd}
The simplest way to substitute marginal effects for coefficient estimates is with the {help outreg_complete##marginal:marginal} option.  
This replaces the {help outreg_complete##statname:statistic} {opt b_dfdx} for {opt b} and {opt t_abs_dfdx} for {opt t_abs} (or {opt se_dfdx} for {opt se} if the {it:option} {opt se} is in effect).  
The asterisks for significance now refer to the marginal effects rather than the underlying coefficients.

	{cmd}. logit foreign wgt mpg
	{txt}({it:output omitted})
	
	{cmd}. margins, dydx(*)
	{txt}({it:output omitted})
	
	{cmd}. outreg using auto, marginal replace
	{res}
	{txt}{center:{hline 17}}
	{center:{txt}{lalign 5:}{txt}{center 10:foreign}}
	{txt}{center:{hline 17}}
	{center:{txt}{lalign 5:wgt}{res}{center 10:-0.046}}
	{center:{txt}{lalign 5:}{res}{center 10:(8.01)**}}
	{center:{txt}{lalign 5:mpg}{res}{center 10:-0.020}}
	{center:{txt}{lalign 5:}{res}{center 10:(2.03)*}}
	{center:{txt}{lalign 5:N}{res}{center 10:74}}
	{txt}{center:{hline 17}}
	{txt}{center:* p<0.05; ** p<0.01}

{pstd}
Marginal effects can also be combined with regression coefficients or other statistics in the {cmd:outreg} table.  
Below, the table displays each coefficient estimate with the marginal effect below it, and the 95% confidence interval of the marginal effect below that, because of the {help outreg_complete##stats:{bf:stats(}b b_dfdx ci_dfdx{bf:)}} option.  Note that the statistics {opt b_dfdx} and {opt ci_dfdx} refer to whichever marginal effects were specified in the {help margins} command.  This could be from the {opt dydx()}, {opt eydx()}, {opt dyex()}, or {opt eyex()} option.

{pstd}
The {help outreg_complete##margstar:margstar} option specifies that the asterisks refer to the significance of the hypothesis that the marginal effects are zero, rather than the coefficients being zero.  
The {help outreg_complete##starloc:starloc(3)} option places the asterisks next to the third statistic (the marginal effect confidence intervals) instead of the default, next to the second statistic.

	{cmd}. outreg using auto, stat(b b_dfdx ci_dfdx) replace     ///
	     title("Marginal Effects & Confidence Intervals" \   ///
	           "Below Coefficients") margstar starloc(3) 
	{res}
	{txt}{center:Marginal Effects & Confidence Intervals}
	{txt}{center:Below Coefficients}
	{txt}{center:{hline 30}}
	{center:{txt}{lalign 7:}{txt}{center 21:foreign}}
	{txt}{center:{hline 30}}
	{center:{txt}{lalign 7:wgt}{res}{center 21:-0.391}}
	{center:{txt}{lalign 7:}{res}{center 21:(-0.046)}}
	{center:{txt}{lalign 7:}{res}{center 21:[-0.057 - -0.035]**}}
	{center:{txt}{lalign 7:mpg}{res}{center 21:-0.169}}
	{center:{txt}{lalign 7:}{res}{center 21:(-0.020)}}
	{center:{txt}{lalign 7:}{res}{center 21:[-0.039 - 0.001]}}
	{center:{txt}{lalign 7:_cons}{res}{center 21:13.708}}
	{center:{txt}{lalign 7:N}{res}{center 21:74}}
	{txt}{center:{hline 30}}
	{txt}{center:* p<0.05; ** p<0.01}
{marker xmpl10}

{title:Example 10.  Multi-column ctitles; merge variable means with estimation results}

{pstd}
The summary statistics for the variables used in estimations, usually their means and standard deviations, are commonly reported in empirical papers.  
This example shows how to merge variable means onto an estimation table.

{pstd}
First we create an {cmd:outreg} table which merges two simple regressions as was done in {help outreg##xmpl3:Example 3}.  
The {opt nodisplay} option suppresses display of the {cmd:outreg} tables we are creating, which normally appears in the Stata results window.  
The {help frmt_opts##ctitles:ctitles} have been specified to have two rows, with a supertitle on the first two columns of "Regressions". 

{pstd}
Notice that the two {cmd:outreg} commands below do not include a {cmd:using} statement.  
This means that the results are not written as Word files.  
This is not necessary because we will merge more estimation results below, and don't need to save the intermediate files.  
The contents of the table are saved in Stata's memory in the mean time.

	{cmd}. reg mpg foreign weight
	{txt}({it:output omitted})
	{cmd}. outreg, bdec(2 5 2) varlabels nodisplay    ///
	     ctitles("", "Regressions" \ "", "Base case") 
	{cmd}. reg mpg foreign weight weightsq
	{txt}({it:output omitted})
	{cmd}. outreg, bdec(2 5 2) bfmt(f f e f) varlabels merge ///
	     ctitles("", "" \ "", "Quadratic mpg") nodisplay
{txt}
{pstd}
Then we run the {help mean} command, which calculates variable means and their standard errors.  
{cmd:mean} is an estimation command, so it stores its results in e(b) and e(V) and they can be displayed and merged using {cmd:outreg}.  
We {opt merge} the variable means to the {cmd:outreg} table already created above.  
The {opt ctitles} in this {cmd:outreg} command have two rows, aligning them with the previous {opt ctitles}.  
The {help frmt_opts##multicol:multicol(1,2,2)} option causes the cell in the first row, 
second column, to span two cells horizontally so that the title "Regressions" is centered over both the "Base case" and "Quadratic mpg" columns.  
The effect of the {opt multicol} option can not be seen in the Stata results window (shown below), but does appear in the Word or TeX document created by {cmd:outreg}.  
Note that the {opt multicol} option must be used in the third and last {cmd:outreg} command, because it is a formatting characteristic that is not retained from an earlier {cmd:outreg} table that is {opt merged} with a new one.

	{cmd}. mean mpg foreign weight
	{txt}({it:output omitted})
	{cmd}. outreg using auto, bdec(1 3 0) nostar merge replace      ///
	     ctitles("", "Means &" \ "", "Std Errors") multicol(1,2,2)
	{res}
	{txt}{center:{hline 52}}
	{center:{txt}{lalign 10:}{txt}{center 13:Regressions}{txt}{center 15:}{txt}{center 12:Means &}}
	{center:{txt}{lalign 10:}{txt}{center 13:Base case}{txt}{center 15:Quadratic mpg}{txt}{center 12:Std Errors}}
	{txt}{center:{hline 52}}
	{center:{txt}{lalign 10:foreign}{res}{center 13:-1.65}{res}{center 15:-2.20}{res}{center 12:0.297}}
	{center:{txt}{lalign 10:}{res}{center 13:(1.53)}{res}{center 15:(2.08)*}{res}{center 12:(0.053)}}
	{center:{txt}{lalign 10:weight}{res}{center 13:-0.00659}{res}{center 15:-0.01657}{res}{center 12:3,019}}
	{center:{txt}{lalign 10:}{res}{center 13:(10.34)**}{res}{center 15:(4.18)**}{res}{center 12:(90)}}
	{center:{txt}{lalign 10:weightsq}{res}{center 13:}{res}{center 15:1.59e-06}{res}{center 12:}}
	{center:{txt}{lalign 10:}{res}{center 13:}{res}{center 15:(2.55)*}{res}{center 12:}}
	{center:{txt}{lalign 10:mpg}{res}{center 13:}{res}{center 15:}{res}{center 12:21.3}}
	{center:{txt}{lalign 10:}{res}{center 13:}{res}{center 15:}{res}{center 12:(0.7)}}
	{center:{txt}{lalign 10:_cons}{res}{center 13:41.68}{res}{center 15:56.54}{res}{center 12:}}
	{center:{txt}{lalign 10:}{res}{center 13:(19.25)**}{res}{center 15:(9.12)**}{res}{center 12:}}
	{center:{txt}{lalign 10:R2}{res}{center 13:0.66}{res}{center 15:0.69}{res}{center 12:}}
	{center:{txt}{lalign 10:N}{res}{center 13:74}{res}{center 15:74}{res}{center 12:74}}
	{txt}{center:{hline 52}}
	{txt}{center:* p<0.05; ** p<0.01}

{pstd}
We could embellish the "Regressions" supertitle by underlining it.  
In Word files, this is accomplished with the formatting code "{\ul Regressions}".  
If we want the underline to span more widely than the word "Regressions", one approach is to place tab characters before and after the word.  
Spaces do not do the job, because Word does not underline spaces.  
To place one tab character on either side of the supertitle, we would use "{\ul\tab Regressions\tab}" in the {opt ctitles} option.  
Another option is to use underscore characters, although the line they create is offset slightly below the underlining.  
See {help frmt_opts##greek:Inline formatting} for more information about underlining and other within-string formatting issues.

{pstd}
The {help mean} command calculates the variable means and their standard {it:errors}.  
More typically, summary statistic tables report the variable means and their standard deviations (which differ from the standard errors of the mean by a factor of the square root of {it:N}).  
To report the standard deviations of the variables, I use the as yet unreleased command {cmd:outstat} which, since it is also based on the underlying formatting engine {cmd:frmttable}, can be appended to an {cmd:outreg} table:

	{cmd}. reg mpg foreign weight
	{txt}({it:output omitted})
	{cmd}. outreg
	{txt}({it:output omitted})
	{cmd}. outstat mpg foreign weight using auto, merge replace       ///
	     title(Merge summary statistics with regression results) ///
	     sdec(2\2\4\4\0\0) varlabels basefont(fs10)
	{res}{txt}(note: tables being merged have different numbers of row sections)
	{res}
	{txt}{center:{hline 32}}
	{center:{txt}{lalign 9:}{txt}{center 11:mpg}{txt}{center 10:Means}}
	{txt}{center:{hline 32}}
	{center:{txt}{lalign 9:foreign}{res}{center 11:-1.650}{res}{center 10:0.2973}}
	{center:{txt}{lalign 9:}{res}{center 11:(1.53)}{res}{center 10:(0.4602)}}
	{center:{txt}{lalign 9:weight}{res}{center 11:-0.007}{res}{center 10:3,019}}
	{center:{txt}{lalign 9:}{res}{center 11:(10.34)**}{res}{center 10:(777)}}
	{center:{txt}{lalign 9:mpg}{res}{center 11:}{res}{center 10:21.30}}
	{center:{txt}{lalign 9:}{res}{center 11:}{res}{center 10:(5.79)}}
	{center:{txt}{lalign 9:_cons}{res}{center 11:41.680}{res}{center 10:}}
	{center:{txt}{lalign 9:}{res}{center 11:(19.25)**}{res}{center 10:}}
	{center:{txt}{lalign 9:R2}{res}{center 11:0.66}{res}{center 10:}}
	{center:{txt}{lalign 9:N}{res}{center 11:74}{res}{center 10:}}
	{txt}{center:{hline 32}}
	{txt}{center:* p<0.05; ** p<0.01}

{pstd}
The warning message "tables being merged have different numbers of row sections" is displayed because the differing structure of the {cmd:outreg} table 
and the {cmd:outstat} table mean that the {opt merge} process may not align rows the way the user intended, but in this case there is no problem.{p_end}
{marker xmpl11}

{title:Example 11. Specifying fonts}

{pstd}
One of the objectives of this version of {cmd:outreg} is to have as complete control of the layout and appearance of estimates tables as possible.  
An important element of this is fine control of fonts.  
{cmd:outreg} now enables users to specify fonts down to the table cell level, although this is needed only rarely.  
Users can specify font sizes, font types (such as Times Roman or Arial), and font styles (such as bold or italic).  
For Word files, users can apply any font type installed on their computers by adding the font name in the {help frmt_opts##addfont:addfont} option.

{pstd}
This example prepares a table for a presentation as an overhead slide with special fonts that are displayed much larger than usual.  
Two specialized fonts are added to the document with the {opt addfont(Futura,Didot Bold)} command.  
These fonts can then be applied to different parts of the table as "fnew1" for the first added font, or "fnew2", the second added font.  
We set the default font of the table to be Futura ("fnew1") in the {opt basefont(fs32 fnew1)}.  
This {opt basefont} option also sets the font size to 32 points to make the table fill the whole overhead slide.  
The title is assigned the second added font, Didot Bold, with a 40 point size in {opt titlfont(fs40 fnew2)}.  
The statistics in the table are displayed in the Arial font for readability with the {opt statfont(arial)} option.  (Times Roman, Arial, and Courier fonts are predefined in Word and TeX documents and don't need to be added.) 
The {opt basefont} font characteristics apply to all parts of the table, unless otherwise specified, so the Arial font in {opt statfont} has a point size of 32.

{pstd}
Font specifications do not change the appearance of the table displayed in the Stata results window (only in the Word document written to auto.doc), so the output is omitted.

	{cmd}. reg mpg foreign weight
	{txt}({it:output omitted})
	{cmd}. outreg using auto, addfont(Futura, Didot Bold)                ///
	     basefont(fs32 fnew1) titlfont(fs40 fnew2) statfont(arial) ///
	     title(New Fonts for Overhead Slides) varlabels replace
	{txt}({it:output omitted})
{marker xmpl12}

{title:Example 12. Superscripts, italics, and Greek characters}

{pstd}
This example uses some of the methods of {help frmt_opts##greek:inline formatting} explained above to apply superscripts, italic text, and Greek characters.  
It is helpful to review those methods to understand the codes used here.

{pstd}
This example is similar to {help outreg_complete##xmpl7:Example 7} in that the results of a test of coefficient equality are displayed in the estimation table.  
However, since the estimation is nonlinear, the test statistic is a chi-squared rather than an {it:F} statistic.  
We will write the chi-squared with the Greek character chi and a superscripted "2" in the Word table generated by {cmd:outreg}.  
A different set of codes can produce the same formatting in TeX files, as  discussed in {help frmt_opts##greek:Inline formatting}.

{pstd}
The Word code for the Unicode representation of the Greek lower-case letter chi is "\u0966?" (see all Word Greek letter codes {help greek_in_word:here}).  
The code for chi needs to be placed in quotes in the {opt addrows} option because otherwise the backslash would be interpreted as a row divider.  
The superscripted 2 is encoded as "{\super 2}".  
Note the space between the formatting code ("\super") and the regular text ("2").  
Without it, Word would try to interpret the code "\super2", which doesn't exist.  
Finally, we italicize the "p" in {it:p} value like this: "{\i p}".  
The full {opt addrows} option becomes {opt addrows("\u0966{\super 2} test", "`chi2'" \ "{\i p} value", "`p'")}.  
As in Example 7, `chi2' and `p' are the value of local macros containing the numerically formatted values of the chi-squared statistic and its {it:p} value.

{pstd}
The {opt note} option in the {cmd:outreg} command below has a couple of tricks in it.  The first is a blank row ("") to separate the {opt note} text from the legend for asterisks above it.  
We also add Stata system macro values for the current time, date, and dataset file name from predefined Stata macros {c S|}S_TIME, {c S|}S_DATE, and {c S|}S_FN, respectively.

	{cmd}. logit foreign wgt mpg
	{txt}({it:output omitted})
	{cmd}. test wgt = mpg
	{txt}({it:output omitted})
	{cmd}. local chi2 : display %5.2f `r(chi2)'
	{cmd}. local p : display %4.3f `r(p)'
	{cmd}. outreg using auto, replace ///
	     addrows("\u0966?{\super 2} test", "`chi2'" \ "{\i p} value", "`p'") ///
	     note("" \ "Run at $S_TIME, $S_DATE" \ "Using data from $S_FN") 
	{res}
	{txt}{center:{hline 48}}
	{center:{txt}{lalign 36:}{txt}{center 10:foreign}}
	{txt}{center:{hline 48}}
	{center:{txt}{lalign 36:wgt}{res}{center 10:-0.391}}
	{center:{txt}{lalign 36:}{res}{center 10:(3.86)**}}
	{center:{txt}{lalign 36:mpg}{res}{center 10:-0.169}}
	{center:{txt}{lalign 36:}{res}{center 10:(1.83)}}
	{center:{txt}{lalign 36:_cons}{res}{center 10:13.708}}
	{center:{txt}{lalign 36:}{res}{center 10:(3.03)**}}
	{center:{txt}{lalign 36:N}{res}{center 10:74}}
	{center:{txt}{lalign 36:\u0966?{\super 2}(1) test: wgt=mpg}{res}{center 10:10.84}}
	{center:{txt}{lalign 36:{\i p} value}{res}{center 10:0.001}}
	{txt}{center:{hline 48}}
	{txt}{center:* p<0.05; ** p<0.01}
	{txt}{center:}
	{txt}{center:Run at 16:51:44, 27 Aug 2010}
	{txt}{center:Using data from /Applications/Stata/ado/base/a/auto.dta}
{marker xmpl13}

{title:Example 13. Place additional tables in same document}

{pstd}
One of the goals for {cmd:outreg} is to create whole documents, such as  statistical appendices, from a Stata {cmd:.do} file.  
To do this, one must be able to write multiple tables to the same document, which is possible with the {opt addtable} option.  

{pstd}
Below, the {help mean} command creates summary statistics for the variables.
{cmd:outreg} with the {help frmt_opts##addtable:addtable} option places summary statistics table below the table just created in {help outreg_complete##xmpl12:Example 12} in the Word file {cmd:auto.doc}. 
The option {help outreg_complete##nostars:nostars} turns off asterisks for significance tests, and {help outreg_complete##nosubstat:nosubstat} 
puts  the standard errors side-by-side with the means, as explained in {help outreg_complete##xmpl15:Example 15}
below.{p_end}
	{com}. mean foreign wgt mpg
	{res}
	{txt}Mean estimation{col 37}Number of obs{col 54}= {res}     74

	{txt}{hline 13}{c TT}{hline 11}{hline 11}{hline 14}{hline 12}
	             {c |}       Mean{col 26}   Std. Err.{col 38}     [95% Con{col 51}f. Interval]
	{hline 13}{c +}{hline 11}{hline 11}{hline 14}{hline 12}
	{space 5}foreign {c |}{col 14}{res}{space 2} .2972973{col 26}{space 2} .0534958{col 37}{space 5} .1906803{col 51}{space 3} .4039143
	{txt}{space 9}wgt {c |}{col 14}{res}{space 2} 30.19459{col 26}{space 2} .9034692{col 37}{space 5} 28.39398{col 51}{space 3} 31.99521
	{txt}{space 9}mpg {c |}{col 14}{res}{space 2}  21.2973{col 26}{space 2} .6725511{col 37}{space 5}  19.9569{col 51}{space 3} 22.63769
	{txt}{hline 13}{c BT}{hline 11}{hline 11}{hline 14}{hline 12}

	{com}. outreg using auto, addtable ctitle(Variables, Means, Std Errors) ///
		  nostars nosubstat title("Summary Statistics") basefont(fs6)
	{res}
	{txt}{center:Summary Statistics}
	{txt}{center:{hline 33}}
	{center:{txt}{lalign 11:Variables}{txt}{center 8:Means}{txt}{center 12:Std Errors}}
	{txt}{center:{hline 33}}
	{center:{txt}{lalign 11:foreign}{res}{center 8:0.297}{res}{center 12:0.053}}
	{center:{txt}{lalign 11:wgt}{res}{center 8:30.195}{res}{center 12:0.903}}
	{center:{txt}{lalign 11:mpg}{res}{center 8:21.297}{res}{center 12:0.673}}
	{txt}{center:{hline 33}}
{pstd}
The user can add paragraphs of regular text before and after each table with the {help frmt_opts##pretext:pretext} and {help frmt_opts##posttext:posttext} options.{p_end}
{marker xmpl14}

{title:Example 14. Place footnotes among coefficients}

{pstd}
Placing footnotes in any of the text elements of a {cmd:outreg} table is straightforward, such as in {help frmt_opts##title:title}, 
{help frmt_opts##ctitles:ctitles}, {help frmt_opts##rtitles:rtitles}, or {help frmt_opts##note:note}.  
You can place a footnote number in the text, using a superscript as in {help outreg_complete##xmpl12:Example 12} if you want, and place the footnote text in the {opt note} or {opt posttext}.  

{pstd}
Placing a footnote in the body of the {cmd:outreg} table is not as straightforward as in the text elements, because the table body is made up of numeric statistics.  
For this, we use the {opt annotate} option.  First we create a Stata matrix with the footnote locations used by {opt annotate}, and put the footnote symbols in the text string of {opt asymbol}.  
It is helpful to review the entry for the {help frmt_opts##annotate:annotate} option for details.

{pstd}
Below, we place superscripted footnotes in a regression table.  
The first footnote is added to the label of the variable {cmd:foreign}, which is used by {cmd:outreg} because of the {opt varlabels} option.  
The next two footnotes are placed among the regression statistics.  
For this we create a Stata matrix with the {cmd:matrix annotmat = J(3,2,0)} command.  This creates a 3 by 2 matrix of zeros.  
The matrix should have the dimension of the number of coefficients (3, including the constant) by the number of statistics (by default, 2: {cmd:b} and {cmd:t_abs}).  
All elements of the matrix {it:annotmat} which are zero are ignored.  
The locations with a "1" have the first {opt asymbol} appended, "2" have the second {opt asymbol}, etc.  
Since we want to place a footnote next to the first {it:t} statistic, we place a 1 at position (1,2) of {it:annotmat} for the first coefficient, second statistic of the table.  
We place another footnote next to the third coefficient estimate, so we place a 2 at position (3,1) of {it:annotmat}.  
The 1 and 2 in {it:annotmat} correspond to the first and second strings in {opt asymbol}, which are "{\super 2}" and "{\super 3}" since these should be footnotes number 2 and 3.

{pstd} 
The final footnote, 4, is placed in the text labeling the summary statistic, {it:N}, using the {opt summtitle("{\i N}{super 4}")} which gives us an italicized {it:N} and a superscripted 4.

{pstd}
It is not possible to position a footnote next to the summary statistic in {opt summstat}.  
To accomplish this, it is necessary to turn off the automatic summary statistics with {opt noautosumm} (which {opt summstat} does by default), and place the statistic and the footnote symbol in {opt addrows}, 
which was described in {help outreg_complete##xmpl7:Example 7} and {help outreg_complete##xmpl12:Example 12}.

{pstd}
The footnote text is added below the table in the {opt note} option, with superscripts for the footnote numbers.

	{cmd}. reg mpg foreign weight
	{cmd}. label var foreign "Car Type{\super 1}"
	{cmd}. matrix annotmat = J(3,2,0)
	{cmd}. matrix annotmat[1,2] = 1
	{cmd}. matrix annotmat[3,1] = 2
	{cmd}. outreg using auto, varlabels replace colwidth(10 10)        ///
	     annotate(annotmat) asymbol("{\super 2}","{\super 3}")    ///
	     basefont(fs10) summstat(N) summtitle("{\i N}{\super 4}") ///
	     note("{\super 1}First footnote." \                       ///
	          "{\super 2}Second footnote." \                      ///
	          "{\super 3}Third footnote." \                       ///
	          "{\super 4}Fourth footnote.")
	{res}
	{txt}{center:{hline 40}}
	{center:{txt}{lalign 20:}{txt}{center 18:Mileage (mpg)}}
	{txt}{center:{hline 40}}
	{center:{txt}{lalign 20:Car Type{\super 1}}{res}{center 18:-1.650}}
	{center:{txt}{lalign 20:}{res}{center 18:(1.53){\super 2}}}
	{center:{txt}{lalign 20:Weight (lbs.)}{res}{center 18:-0.007}}
	{center:{txt}{lalign 20:}{res}{center 18:(10.34)**}}
	{center:{txt}{lalign 20:Constant}{res}{center 18:41.680{\super 3}}}
	{center:{txt}{lalign 20:}{res}{center 18:(19.25)**}}
	{center:{txt}{lalign 20:{\i N}{\super 4}}{res}{center 18:74}}
	{txt}{center:{hline 40}}
	{txt}{center:* p<0.05; ** p<0.01}
	{txt}{center:{\super 1}First footnote.}
	{txt}{center:{\super 2}Second footnote.}
	{txt}{center:{\super 3}Third footnote.}
	{txt}{center:{\super 4}Fourth footnote.}
{marker xmpl15}

{title:Example 15. Show statistics side-by-side, like Stata estimation results}

{pstd}
To show statistics side-by-side, such as {it:t} statistics next to the coefficients rather than below them, use the {opt nosubstat} option.  
The following example creates a table similar to Stata's display of regression results, reporting six statistics using the {opt stats} option.  
Asterisks for significance have been turned off with the {opt nostars} option.

	{cmd}. outreg using auto, nosubstat stats(b se t p ci_l ci_u) nostar    ///
	     ctitles("mpg", "Coef.", "Std. Err.", "t", "P>|t|", "[95% Conf.",  ///
	     "Interval]") bdec(7) replace                                  ///
	     title("Horizontal Output like Stata's -estimates post-")
	     
	{res}
	{txt}{center:Horizontal Output like Stata's -estimates post-}
	{txt}{center:{hline 73}}
	{center:{txt}{lalign 9:mpg}{txt}{center 12:Coef.}{txt}{center 11:Std. Err.}{txt}{center 8:t}{txt}{center 7:P>|t|}{txt}{center 12:[95% Conf.}{txt}{center 12:Interval]}}
	{txt}{center:{hline 73}}
	{center:{txt}{lalign 9:foreign}{res}{center 12:-1.6500291}{res}{center 11:1.0759941}{res}{center 8:-1.53}{res}{center 7:0.13}{res}{center 12:-3.7955004}{res}{center 12:0.4954422}}
	{center:{txt}{lalign 9:weight}{res}{center 12:-0.0065879}{res}{center 11:0.0006371}{res}{center 8:-10.34}{res}{center 7:0.00}{res}{center 12:-0.0078583}{res}{center 12:-0.0053175}}
	{center:{txt}{lalign 9:_cons}{res}{center 12:41.6797023}{res}{center 11:2.1655472}{res}{center 8:19.25}{res}{center 7:0.00}{res}{center 12:37.3617239}{res}{center 12:45.9976808}}
	{txt}{center:{hline 73}}
{marker xmpl16}

{title:Example 16. Merge multiple estimation results in a loop}

{pstd}
If you want to run the same estimation on different datasets or on different groups within a dataset, it is often efficient to create a loop using the {help forvalues} or {help foreach} commands.  
This example shows how to merge the results of each estimation in the loop into a single {cmd:outreg} table, and secondly, how to merge sequential estimations in a loop into two separate tables.

{pstd}
Say we want to run separate regressions by groups which are indexed by the categorical variable {cmd:rep78} in the {cmd:auto.dta} dataset.  
We use the {help forvalues} command to create a loop that steps through the values of {cmd:rep78} from 2 to 5. 
For each value of {cmd:rep78}, we run a regression of the variable {cmd:mpg} on covariates, restricting the sample to the current value of {cmd:rep78} with the statement {cmd:if rep78==`r'}.  
{cmd:r} is a local macro containing the current value of the loop indicator.

{pstd}
Following each regression, the {cmd:outreg, merge} command merges successive regression results into a single table.  
The first time that {cmd:outreg, merge} is executed after the first regression, we actually don't want it to merge with anything.  
The {opt merge} option allows merging without an existing table precisely to enable its use in loops, although {cmd:outreg} does produce the warning message below, that no existing {cmd:outreg} table was found.  

{pstd}
To ensure that there is no preexisting table before the first {cmd:outreg, merge} command in the loop that would be merged to the first regression coefficients, we preceed the {cmd: forvalues} loop with a {cmd:outreg, clear} command.  
The {opt clear} option removes any {cmd:outreg} table in memory, since {cmd:outreg} tables persist until cleared or replaced by a new table.  
Even if no previous {cmd:outreg} command has been run, if the commands in this example are rerun, the {cmd:outreg, clear} command is necessary to clear out the previous version of the table.

	{cmd}. outreg, clear
	{cmd}. forvalues r = 2/5 {
	  2.   quietly reg mpg price weight if rep78==`r'
	  3.   outreg, merge varlabels ctitle("", "`r'") nodisplay
	  4. }
	{txt}warning: no existing table found for merge or append

{pstd}
The {cmd:outreg} command in the loop does not need any {opt using} statement because we don't need to save the table as a Word document (or TeX document) until we have merged all the regressions together.  
Once we have, and the loop is complete, we save the table as a Word document with the {cmd:outreg using auto, replay} command.  

	{cmd}. outreg using auto, replay replace title(Regressions by Repair Record)
{res}
{txt}{center:Regressions by Repair Record}
{txt}{center:{hline 60}}
{center:{txt}{lalign 15:}{txt}{center 11:2}{txt}{center 11:3}{txt}{center 11:4}{txt}{center 10:5}}
{txt}{center:{hline 60}}
{center:{txt}{lalign 15:Price}{res}{center 11:-0.000}{res}{center 11:0.000}{res}{center 11:0.000}{res}{center 10:0.001}}
{center:{txt}{lalign 15:}{res}{center 11:(0.61)}{res}{center 11:(0.07)}{res}{center 11:(0.71)}{res}{center 10:(0.98)}}
{center:{txt}{lalign 15:Weight (lbs.)}{res}{center 11:-0.008}{res}{center 11:-0.004}{res}{center 11:-0.005}{res}{center 10:-0.025}}
{center:{txt}{lalign 15:}{res}{center 11:(5.40)**}{res}{center 11:(4.74)**}{res}{center 11:(8.47)**}{res}{center 10:(3.10)*}}
{center:{txt}{lalign 15:Constant}{res}{center 11:44.953}{res}{center 11:34.052}{res}{center 11:34.918}{res}{center 10:78.648}}
{center:{txt}{lalign 15:}{res}{center 11:(10.91)**}{res}{center 11:(14.40)**}{res}{center 11:(15.96)**}{res}{center 10:(6.17)**}}
{center:{txt}{lalign 15:R2}{res}{center 11:0.92}{res}{center 11:0.64}{res}{center 11:0.84}{res}{center 10:0.76}}
{center:{txt}{lalign 15:N}{res}{center 11:8}{res}{center 11:30}{res}{center 11:18}{res}{center 10:11}}
{txt}{center:{hline 60}}

{pstd}
The {opt replay} option tells {cmd:outreg} to use the existing {cmd:outreg} table in memory instead of creating a new one. 
If we had left out the {opt replay} option, we would have created a new table from the existing {cmd:e(b)} matrix, which holds just the results of the last regression in the loop, so the {opt replay} option is important.  
With the {opt replay} option, it is possible to make {help frmt_opts##text_add_opts:text additions} (except for {help frmt_opts##varlabels:varlabels}) such as new titles or even {help frmt_opts##addrows:addrows}, 
but it is not possible to change the numerical contents or numerical formatting of the statistics in the table 
(options for {help outreg_complete##est_opts:estimate selection}, {help outreg_complete##est_for_opts:estimates formatting}, {help outreg_complete##stars_opts:star options}, {help frmt_opts##brack_opts:brackets options}, 
and {help outreg_complete##summstat_opts:summary statistics} will be ignored).  
When using the {cmd:replay} option, it {it:is} possible to specify all the text formatting options such as {help frmt_opts##font_opts:fonts}, {help frmt_opts##lines_spaces_opts:lines, and spacing}, 
and the relevant {help frmt_opts##file_opts:file options} such as {help frmt_opts##replace:replace} or {help frmt_opts##tex:tex}. 

{pstd}
Since the {cmd:outreg} command in the loop above used the {opt merge} option, no legend was created at the bottom of the table for the asterisks.
This can be rectified with the option {opt note(* p<0.05; ** p<0.01)} in the {cmd: outreg, replay} command.

{pstd}
There are some contexts in which it is helpful to merge the estimation results in a loop into two separate {cmd:outreg} tables, 
such as when for each iteration of the loop, the results of the first estimation are used in the second estimation, and we want to record the results of both estimations.  
In this example, we run instrumental variables estimation in a loop, and record both the first and second stage regressions.  
In order to merge the regressions results to two separate tables, we need to  give the tables separate names.  
Each time the {opt merge} option is used, it will refer to either the "first" table (for the first stage regression results) or the "iv" table (for the second stage results).  
These table-specific {cmd:merge} options become {cmd:merge(first)} and {cmd:merge(iv)}.

{pstd}
As before, we preceed the {cmd:forvalues} loop with {cmd:outreg, clear} to clear out any {cmd:outreg} table in memory, but in this case we need to refer to the named tables, 
so we have two commands {opt outreg, clear(first)} and {opt outreg, clear(iv)}.  
The built-in Stata command for instrumental variables estimation, {help ivregress} does not have the capability of saving the first stage results (although they can be displayed).  
Instead we use the excellent user-written command {search ivreg2}, which saves the first stage results with the {cmd:savefirst} option.  
The {cmd:ivreg2} command is preceded by the {help quietly} command to suppress the display of its output.  
We then add the instrumental variables estimates to the "iv" table with the {cmd:outreg, merge(iv)} command. 
The {cmd:estimates restore _ivreg2_hsngval} command puts the first stage estimates into the {cmd:e(b)} and {cmd:e(V)} vectors, 
so the second {cmd:outreg} command {cmd:outreg, merge(first)} saves the first stage regression results in the "first" table.

	{com}. webuse hsng2, clear
	{txt}(1980 Census housing data)

	{com}. outreg, clear(iv)
	{com}. outreg, clear(first)
	{com}. forvalues r = 1/4 {c -(}
	{txt}  2{com}.   quietly ivreg2 rent pcturban (hsngval = faminc) if reg`r', savefirst
	{txt}  3{com}.   outreg, merge(iv) varlabels ctitle("","Region `r'") nodisplay
	{txt}  4{com}.   quietly estimates restore _ivreg2_hsngval
	{txt}  5{com}.   outreg, merge(first) varlabels ctitle("","Region `r'") nodisplay
	{txt}  6{com}. {c )-}
	{res}{txt}warning: no existing table found for merge or append
	{res}{txt}warning: no existing table found for merge or append

{pstd}
We now save the two tables with two {cmd:outreg, replay} commands.  
To replay the table of first stage estimates, we use the {opt replay(first)} option, and the second stage estimates with the {opt replay(iv)} option.  
By using the {cmd:addtable} option in the second {cmd:outreg, replay} command (and {cmd:using} the same file name) we combine both tables into the file {cmd:iv.doc}. 

	{com}. outreg using iv, replay(first) replace ///
	    title(First Stage Regressions by Region)
	{txt}({it:output omitted})
	{com}. outreg using iv, replay(iv) addtable /// 
	    title(Instrumental Variables Regression by Region)
	{txt}({it:output omitted})

{title:Author}

	John Luke Gallup, Portland State University, USA
	jlgallup@pdx.edu


{title:Also see}

{psee}
{help outreg:basic outreg}


