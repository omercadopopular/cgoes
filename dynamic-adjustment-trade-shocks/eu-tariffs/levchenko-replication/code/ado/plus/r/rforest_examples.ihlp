{marker examples}{...}

{dlgtab:Regression}

{pstd}
Setup{p_end}
{phang2}{cmd:. sysuse auto}{p_end}

{pstd}
Randomize the dataset{p_end}
{phang2}{cmd:. set seed 1}{p_end}
{phang2}{cmd:. generate u = uniform()}{p_end}
{phang2}{cmd:. sort u}

{pstd}
Fit a random forest regression model{p_end}
{phang2}{cmd:. rforest price weight length, type(reg) iterations(500)}{p_end}

{pstd}
Output the statistics computed so far (note that the OOB error is computed at
this stage){p_end}
{phang2}{cmd:. ereturn list}{p_end}

{pstd}
Compute expected values of variable {cmd:price}{p_end}
{phang2}{cmd:. predict p1}{p_end}

{pstd}
List the first five entries for predicted prices and actual prices{p_end}
{phang2}{cmd:. list p1 price in 1/5}{p_end}

{pstd}
Output the statistics computed so far (note that the mean absolute error and
root mean squared error are computed at this stage){p_end}
{phang2}{cmd:. ereturn list}{p_end}

{pstd}{it:({stata rforest_examples reg:click to run})}{p_end}


{dlgtab:Classification}

{pstd}
Clear previous data{p_end}
{phang2}{cmd:. clear}{p_end}

{pstd}
Setup{p_end}
{phang2}{cmd:. sysuse auto}{p_end}

{pstd}
Randomize the dataset{p_end}
{phang2}{cmd:. set seed 1}{p_end}
{phang2}{cmd:. generate u = uniform()}{p_end}
{phang2}{cmd:. sort u}

{pstd}
Fit a random-forest classification model{p_end}
{phang2}{cmd:. rforest foreign weight length, type(class) iterations(500)}{p_end}

{pstd}
Output the statistics computed so far (note that the OOB error is computed at
this stage){p_end}
{phang2}{cmd:. ereturn list}{p_end}

{pstd}
Compute expected classes of variable {cmd:foreign}{p_end}
{phang2}{cmd:. predict p1}{p_end}

{pstd}
Compute expected class probabilities of variable {cmd:foreign}{p_end}
{phang2}{cmd:. predict c1 c2, pr}{p_end}

{pstd}
List the first five entries for predicted classes, actual classes, class
probabilities for {cmd:foreign} = 0, and class probabilities for {cmd:foreign}
= 1{p_end}
{phang2}{cmd:. list p1 foreign c1 c2 in 1/5}{p_end}

{pstd}
Output the statistics computed so far (note that the error rate and fMeasure
has been computed at this point){p_end}
{phang2}{cmd:. ereturn list}{p_end}

{pstd}{it:({stata rforest_examples class:click to run})}{p_end}


{dlgtab:Variable Importance}

{pstd}
Clear previous data{p_end}
{phang2}{cmd:. clear}{p_end}

{pstd}
Setup{p_end}
{phang2}{cmd:. sysuse auto}{p_end}

{pstd}
Randomize the dataset{p_end}
{phang2}{cmd:. set seed 1}{p_end}
{phang2}{cmd:. generate u = uniform()}{p_end}
{phang2}{cmd:. sort u}

{pstd}
Fit a random forest classification model{p_end}
{phang2}{cmd:. rforest weight foreign trunk length mpg price, type(reg)}{p_end}

{pstd}
Output the statistics computed so far (note that the OOB error is computed at
this stage){p_end}
{phang2}{cmd:. ereturn list}{p_end}

{pstd}
Compute expected values for variable {cmd:weight}{p_end}
{phang2}{cmd:. predict pred}{p_end}

{pstd}
List the first five entries of variables {cmd:trunk}, {cmd:pred},
{cmd:foreign}, and {cmd:weight}{p_end}
{phang2}{cmd:. list trunk pred foreign weight in 1/5}{p_end}

{pstd}
Create a copy of the variable-importance matrix stored in {cmd:e()}{p_end}
{phang2}{cmd:. matrix importance = e(importance)}{p_end}

{pstd}
Convert the matrix to a variable{p_end}
{phang2}{cmd:. svmat importance}{p_end}

{pstd}
List the first five entries in the variable {cmd:importance}{p_end}
{phang2}{cmd:. list importance in 1/5}{p_end}

{pstd}
Generate new variable {cmd:id} to be used for labeling{p_end}
{phang2}{cmd:. generate id=""}{p_end}

{pstd}
Attach unique labels to individual columns in the chart{p_end}
{phang2}{hi: local mynames : rownames importance}{p_end}
{phang2}{hi: local k : word count `mynames'}{p_end}
{phang3}// If there are more variables than observations{p_end}
{phang3}{hi: if `k'>_N} {cmd:{c -(}} {p_end}
{pmore3}{hi: set obs `k'} {p_end}
{phang3} {cmd:{c )-}}{p_end}
{phang3}{hi: forvalues i = 1(1)`k'} {cmd:{c -(}} 	{p_end}
{pmore3}{hi: local aword : word `i' of `mynames'} {p_end}
{pmore3}{hi: local alabel : variable label `aword'} {p_end}
{pmore3}{hi: if ("`alabel'"!="")     quietly replace id= "`alabel'" in `i'} {p_end}
{pmore3}{hi: else                    quietly replace id= "`aword'" in `i'} {p_end}
{phang3} {cmd:{c )-}} {p_end}

{pstd}
Graph the results{p_end}
{phang2}{cmd:. graph hbar (mean) importance, over(id, sort(1)) ytitle(Importance)}{p_end}

{pstd}{it:({stata rforest_examples varimport:click to run})}{p_end}
