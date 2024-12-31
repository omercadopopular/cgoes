{smcl}
{* *! NJC 20nov2016}{...}
{cmd:help entropyetc}
{hline}

{title:Title}

{p 8 8 2}Entropy and related measures for categories 


{title:Syntax}
 
{p 8 12 2}
{cmd:entropyetc} 
{varname} 
{ifin} 
{weight}  
[
{cmd:,}
{opt by(byvarlist)}
{opt g:enerate(newvar_spec)} 
{it:tabdisp_options} 
]

{p 4 6 2}
{cmd:aweight}s and {cmd:fweight}s are allowed; see {help weight}.


{title:Description} 

{pstd}
{cmd:entropyetc} treats {it:varname}, which may be numeric or string, as
a categorical variable, so that distinct values define distinct
categories, and calculates Shannon entropy {it:H}, exp {it:H}, Simpson's
sum of squared probabilities {it:R}, 1/{it:R}, and the dissimilarity
index {it:D}. Results are displayed and saved as a matrix. Optionally,
new variables may be generated containing results. 


{title:Remarks} 

{pstd} 
Given {it:S} categories of {it:varname}, calculate their relative
frequencies, applying any weights specified, as proportions {it:p} with
sum 1. In ecology at least, {it:S} is conventional for "number of
species". Then

{pstd} 
Shannon entropy is SUM {it:p} ln 1/{it:p} = {it:H}, say. It is often
written more concisely but more cryptically as - SUM {it:p} ln {it:p}.
If one value of {it:p} is 1, this index takes on a minimum value of 0.
If all {it:p} are equal at 1/{it:S}, it takes on a maximum value of ln
{it:S}. This behaviour motivates looking at exp {it:H} as a "numbers
equivalent". 

{pstd}
Those preferring to use logarithms to base 2 or 10 should divide results
by ln 2 or ln 10 respectively. 

{pstd} 
Simpson's index is SUM {it:p}^2 = {it:R}, say. If one value of {it:p} is
1, and the others thus all 0, this index takes on a maximum value of 1.
If all {it:p} are equal at 1/{it:S}, it takes on a minimum value of 
1/{it:S}. This behaviour motivates looking at 1/{it:R} as a "numbers
equivalent". 

{pstd}
Simpson's index has been discovered or invented many times, sometimes in
the form of its complement or its reciprocal. It is also named repeat
rate and match probability. In particular circumstances it measures
homozygosity or purity of classifications, so its complement measures
heterozygosity or impurity. It is also associated with (this is far from
a complete list) Gini, Turing, Hirschman and Herfindahl. 

{pstd}
Dissimilarity index is (1 / 2) SUM | {it:p} - 1/{it:S} | = {it:D},
say.  If one value of {it:p} is 1, this index takes on a maximum value
of ({it:S} - 1) / {it:S}.  If all {it:p} are equal at 1/{it:S},  it
takes on a minimum value of 0.

{pstd}
Note that the dissimilarity index, unlike the others, is affected by
categories with probabilities of zero. {cmd:entropyetc} always compares
groups according to the number of categories present in all the data
presented, thus allowing some zeros to be included in the calculation
for individual groups. 


{title:Options}

{phang} 
{opt by()} specifies that calculations should be performed separately
for groups defined by {it:byvarlist}.

{phang} 
{opt generate()} specifies the creation of between one and five new
variables from results in different columns of the display. The syntax
is exemplified by {cmd:generate(1=H 3=R)}. The elements of the
specification are {it:#}{cmd:=}{it:newvar}, where {it:#} is an integer
between 1 and 5 and {it:newvar} is a legal new variable name.  Elements
must not contain spaces and are separated by spaces. In this example,
values corresponding to the first displayed column, column 1, are saved
as {cmd:H} and values corresponding to column 3 as {cmd:R}. Values of 
new variables are copied to all observations used in their calculation. 

{phang}
{it:tabdisp_options} are options of {help tabdisp} controlling the
tabulation of results. The default display format is {cmd:%4.3f}.


{title:Examples} 

{phang2}{cmd:. sysuse auto}{p_end}
{phang2}{cmd:. entropyetc rep78}{p_end}
{phang2}{cmd:. entropyetc rep78, by(foreign)}

{phang2}{cmd:. webuse nlsw88}{p_end}
{phang2}{cmd:. entropyetc occupation, by(industry) gen(2=numeq)}{p_end}
{phang2}{cmd:. egen tag = tag(industry)}{p_end}
{phang2}{cmd:. graph dot (asis) numeq if tag, over(industry, sort(1) descending) linetype(line)}


{title:Author}

{pstd}Nicholas J. Cox, Durham University{break}
n.j.cox@durham.ac.uk


{title:Stored results}

{pstd}
{cmd:entropyetc} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(categories)}}number of categories{p_end}

{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(entropyetc)}}matrix of results{p_end}


{title:Also see}

{pstd}
{cmd:divcat} (SSC; if installed) 



