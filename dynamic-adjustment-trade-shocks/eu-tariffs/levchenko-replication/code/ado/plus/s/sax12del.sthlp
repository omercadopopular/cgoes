{smcl}
{* *! version 1.1  11nov2010}{...}
{cmd:help sax12del}{right:({browse "http://www.stata-journal.com/article.html?article=st0255":SJ12-2: st0255})}
 {right:dialog:  {dialog sax12del}}
{hline}

{title:Title}

{p2colset 5 17 19 2}{...}
{p2col :{hi:sax12del} {hline 2}}Delete the series after X-12-ARIMA seasonal adjustment{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 16 2}{cmd:sax12del} {it:adjusted_result} [{cmd:,} {opt drop(string)} {opt keep(string)}]

{pstd}where the {it: adjusted_result} is the filename of the seasonal
adjustment with the extension {hi:.out}.  The extension can be
omitted.{p_end}


{title:Description}

{pstd}The {cmd:sax12del} command automatically identifies and deletes
all files pertaining to the seasonal adjustment.


{title:Options}

{phang}{opt drop(string)} specifies the file extensions to drop. By
default, the program will delete all series if this option is not
specified.

{phang}{opt keep(string)} specifies the file extensions to keep.


{title:Examples}

{pstd}Delete all series except those with the extensions {cmd:d10},
{cmd:d11}, {cmd:d12}, and {cmd:d13}{p_end}
{phang2}{bf:{stata `". sax12del d:\sam\retail, keep(d10 d11 d12 d13)"'}}{p_end}
{phang2}{bf:{stata `". dir retail.*"'}}{p_end}

{pstd}Delete all series except those with the extensions {cmd:d10} and
{cmd:d11}{p_end}
{phang2}{bf:{stata `". sax12del agri const finance house indus other retail service trans gdp, keep(d10 d11)"'}}{p_end}
{phang2}{bf:{stata `". dir gdp.*"'}}{p_end}


{title:Author}

{pstd}Qunyong Wang{p_end}
{pstd}Institute of Statistics and Econometrics{p_end}
{pstd}Nankai University{p_end}
{pstd}brynewqy@nankai.edu.cn{p_end}


{title:Also see}

{p 4 14 2}Article:  {it:Stata Journal}, volume 12, number 2: {browse "http://www.stata-journal.com/article.html?article=st0255":st0255}

{p 7 14 2}Help:  {helpb sax12}, {helpb sax12diag}, {helpb sax12im} (if installed){p_end}
