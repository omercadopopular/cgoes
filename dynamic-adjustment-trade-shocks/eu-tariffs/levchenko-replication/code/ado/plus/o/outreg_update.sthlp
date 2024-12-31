{smcl}
{* *! version 4.00  31aug2010}{...}
{cmd:help outreg_update}
{hline}

{title:Title}

    Changes to {hi:outreg} since version 3.  

{pstd}
This version is a complete rewrite of outreg, mostly programmed in Mata.  All it shares with the previous versions of outreg other than the name is part of the command syntax.

{pstd}
The objective of this version was as complete control of the layout and formatting of estimation tables as possible, creating both Word and TeX files.

{phang}
1. The most obvious change to {help outreg_complete:outreg} is that it now writes fully formatted Word or TeX files rather than flat text files.  
For this reason, there are a lot of new options relating to fonts, text justification, cell border lines, etc. that were not needed before.

{phang}
2. {cmd:outreg} can now display any number of statistics for each estimated coefficient (instead of just two), and these statistics can be displayed side-by-side as well as one above the other.  
One can choose from 26 different {help outreg_complete##statname:statistics} for inclusion in a table, including the full panoply of marginal effects and  confidence intervals.

{phang}
3. One can now selectively {help outreg_complete##keep:keep} or {help outreg_complete##drop:drop} coefficients or equations from the estimation results.

{phang}
4. Tables can be {help outreg_complete##merge:merge}d or {help outreg_complete##append:append}ed more flexibly than before.  
Multiple tables can also be written successively to the same file with regular paragraphs of text in between, so that it is possible to create a whole statistical appendix in a single document with a .do file.

{phang}
5. Text can include italic, bold, super and subscripts, and Greek characters.  It is possible to include user-specified fonts ({help outreg_complete##addfont:addfont}).  
Column titles can span multiple cells ({help outreg_complete##multicol:multicol}).  Footnotes can be added to any part of the table ({help outreg_complete##annotate:annotate}).

{phang}
6. The table created by {cmd:outreg} is displayed in the Stata results window, minus some of the finer formatting destined for the Word or TeX file.


{phang}
Some {cmd:outreg} syntax changes may cause confusion:

{phang}
1. Name of "append" option changed.{p_end}
{pmore} 
Successive estimation results are now combined with the {help outreg_complete##merge:merge} option, which was named the "append" option in previous versions of {cmd:outreg}.  
This makes the new {cmd:outreg} consistent with the way the Stata {cmd:merge} command works on datasets versus the Stata {cmd:append} command.

{phang}
2. By default, variable labels are not used.{p_end}
{pmore} 
In the new {cmd:outreg}, variable labels replace variable names only when the {help outreg_complete##varlabels:varlabels} option is chosen.

{phang}
2. By default, multiequation models are not merged into multiple columns.{p_end}
{pmore} 
Estimated coefficients from multiequation models like {help reg3:reg3} and {help mlogit:mlogit} are reported in one (long) column by default.  
To merge them into separate columns for each equation, one must use the option {help outreg_complete##eq_merge:eq_merge}.
