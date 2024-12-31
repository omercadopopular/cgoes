{smcl}
{* 2018-10-05 Trenton D Mize}{...}
{title:Title}

{p2colset 5 16 16 1}{...}
{p2col:{cmd:cleanplots} {hline 2}}Graphics scheme that implements best 
data visualization practices. Default color choices are effective in both 
color and when printed in grayscale. {p_end}
{p2colreset}{...}

{title:Overview}

{pstd}
{cmd:cleanplots} changes the default look and feel of Stata graphics. 
The choices of colors, markers, gridlines, and other aspects of the figure 
follow best data visualization practices. 

{pstd}
The choices for colors and markers allow for graphics that are effective when 
used in color but that can also be easily distinguished when printed in 
grayscale. 

{pstd}
For more information and to see examples, see the 
{browse "https://www.trentonmize.com/software/cleanplots": cleanplots website here}.

{pstd}
Many of the features of cleanplots are adapted from the excellent black and 
white colorscheme plotplain 
{browse "https://www.dropbox.com/s/m5viis9oybgkept/FigureScheme.pdf?dl=0": which you can read about here}.

{title:Using cleanplots}

{pstd}
To change your graphics scheme to {cmd:cleanplots} use the command: 

{phang2} {stata set scheme cleanplots, perm: set scheme cleanplots, perm}

{pstd}
Stata's default graphic scheme is {cmd:s2color}. To change back to the default: 

{phang2} {stata set scheme s2color, perm: set scheme s2color, perm}

{title:Authorship}

{pstd} {cmd:cleanplots} is written by Trenton D Mize (Department of Sociology, 
Purdue University). Questions can be sent to tmize@purdue.edu {p_end}

