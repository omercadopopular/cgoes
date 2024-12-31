{smcl}
{* *! version 1.0.0 10jul2015 Long Hong}
{cmd: help survgini}
{hline}


{title: Title}

{phang}
{bf: survgini} {hline 2} Non-parametric restricted Gini for survival data


{title: Syntax}

{phang}
{cmd: survgini} {it:time} {it:failure} {it:treatment} {ifin} [{cmd:,} 
{cmdab:nolast:event} {cmdab:nolin:earrank} {cmdab:noas:ymptotic}
{cmdab:noperm:utation} {cmd:m(}{it:integer}{cmd:)}]


{title: Variables}

{synoptset 16 tabbed}{...}
{synopthdr: Variables}
{synoptline}
{synopt:{it:time}}Time-to-event variable. {it:Note} that when there are 
zero-valued observations, the command will change 
those values to 1.0e-06 to ease computation during the execution. 
The original value will be restored after the execution.{p_end}
{synopt:{it:failure}}Censoring indicator; {it:failure}=0 if the observation 
is right-censored and {it:failure}=1 otherwise{p_end}
{synopt:{it:treatment}}Treatment group; please use {it:treat}=1 for 
the first group and {it:treat}=2 for the second group{p_end}
{synoptline}
{pstd}* Only {bf: three} numeric variables are allowed and the 
{bf: order} is fixed.


{title: Options}

{synoptset 16 tabbed}{...}
{synopthdr: Options}
{synoptline}
{synopt:{cmdab:nolast:event}}Represents the longest follow-up time until 
which we integrate in the computation of the restricted Gini index. 
Choosing {cmdab:nolast:event} means integrating until the last observation 
censored or not. Default setting allows integrating until the last event 
non-censored.{p_end}
{synopt:{cmdab:nolin:earrank}}Default setting computes the linear rank tests
(log-rank test and Wilcoxon test). This option inactivates the tests.{p_end}
{synopt:{cmdab:noas:ymptotic}}Default setting computes the asymptotic Gini 
test. This option inactivates the test.{p_end}
{synopt:{cmdab:noperm:utation}}Default setting computes the permutation Gini 
test. This option inactivates the test.{p_end}
{synopt:{cmd:m(}{it:integer}{cmd:)}}The number of replications for permutation 
sampling; the default is 500. The number cannot exceed your version of Stata's matrix size 
limit. See {help matsize} for more information.{p_end}
{synoptline}


{title: Description}

{pstd}{cmd:survgini} The Gini concentration test for survival data is a 
nonparametric test based on the Gini index for testing the equality of 
two survival distributions from the point of view of concentration. 
The package compares different nonparametric tests 
({it:asymptotic Gini test}, {it:permutation Gini test}, 
{it:log-rank test}, and {it:Wilcoxon test}) and computes their p-values 
and test statistics (Bonetti, et al., 2009; Gigliarano and Bonetti, 2011). 


{title: Example}
{pstd} We will use the survival data from the Eastern Cooperative Oncology Group 
(ECOG)'s phase III clinic trial E1690, which accrued patients from 1991 to 1995 
and was unblinded in 1998. This trial was aimed at comparing the effect of 
Interferon alpha-2b chemotherapy (IFN) to observation only in patients affected 
by high-risk melanoma. Trial E1690 was a randomized three-arm clinical trial 
that compared high dose IFN, low dose IFN, and control. To illustrate 
{cmd:survgini}, we use relapse-free survival (RFS) data from the treatment group 
with high dose IFN and that from the control group (215 and 212 patients, 
respectively). {p_end}

{pstd} One can use {cmd:survgini} by inputting the three variables of the 
interest {it: in orders} as shown below. Please note that when the sample size 
is relatively large, we shall inactive the permutation test, which is mainly 
for the case when the sample size is small. {p_end}

    {com}. survgini failtime failcens trt, noperm
      {res}
      {txt}Comparison among GiniAs Log-rank and Wilcoxon tests
      {res}
      {space 0}{space 0}{ralign 12:}{space 1}{c |}{space 1}{ralign 9:pGiniAs}{space 1}{space 1}{ralign 9:pLR}{space 1}{space 1}{ralign 9:pW}{space 1}
      {space 0}{hline 13}{c   +}{hline 11}{hline 11}{hline 11}
      {space 0}{space 0}{ralign 12:pval}{space 1}{c |}{space 1}{ralign 9:{res:{sf:    .0526}}}{space 1}{space 1}{ralign 9:{res:{sf:   .05391}}}{space 1}{space 1}{ralign 9:{res:{sf:   .03506}}}{space 1}
      {space 0}{space 0}{ralign 12:stat}{space 1}{c |}{space 1}{ralign 9:{res:{sf:   3.7565}}}{space 1}{space 1}{ralign 9:{res:{sf:   3.7154}}}{space 1}{space 1}{ralign 9:{res:{sf:   4.4421}}}{space 1}
      
	  
{pstd} {txt}It could also be argued that the sample size is not large enough to 
produce reliable asymptotic results from Asymptotic Gini, Log-rank, and Wilcoxon 
tests. One can use the permutation test instead by inactive the rest of the 
tests as shown below. {p_end} 

    {com}. set seed 20171121

    {com}. survgini failtime failcens trt, nolin noas
      {res}
      {txt}Gini Permutation Test
      {res}
      {space 0}{space 0}{ralign 12:}{space 1}{c |}{space 1}{ralign 9:pGiniPerm}{space 1}
      {space 0}{hline 13}{c   +}{hline 11}
      {space 0}{space 0}{ralign 12:pval}{space 1}{c |}{space 1}{ralign 9:{res:{sf:      .05}}}{space 1}
      {space 0}{space 0}{ralign 12:stat}{space 1}{c |}{space 1}{ralign 9:{res:{sf:    .0037}}}{space 1}

	  
{pstd} {txt}However, one may have to pay attention to the following three direct 
consequences of the fact that the permutation test involves replications of 
permutation sampling. First, it will significantly slow down the speed of the 
programming, especially when {id: m(integer)} is set to be large. Second, the 
result can change slightly every time it is executed. We strongly recommend 
users can use the {cmd: seed} function before using the permutation test for 
replication purpose. Finally, the test statistics is not comparable to the rest 
of the tests whose test statistic follows an asymptotic Chi-square 
distribution. {p_end} 

{title: Saved Results}

{pstd}{cmd:survgini} saves the following in {cmdab:r()}{p_end}

{pstd}Scalars{p_end}
{synoptset 16 tabbed}
{synopt: {cmdab:r(pGiniAs)}}p-value of the asymptotic Gini test{p_end}
{synopt: {cmdab:r(pGiniPerm)}}p-value of the permutation Gini test{p_end}
{synopt: {cmdab:r(pLR)}}p-value of the Log-Rank test{p_end}
{synopt: {cmdab:r(pW)}}p-value of the Wilcoxon test{p_end}

{synopt: {cmdab:r(statGiniAs)}}test statistic of the asymptotic Gini test{p_end}
{synopt: {cmdab:r(statGiniPerm)}}test statistic of the permutation Gini test{p_end}
{synopt: {cmdab:r(statLR)}}test statistic of the Log-Rank test{p_end}
{synopt: {cmdab:r(statW)}}test statistic of the Wilcoxon test{p_end}


{title: Author}

{pstd}Long Hong{p_end}
{pstd}Department of Economics{p_end}
{pstd}University of Wisconsin - Madison{p_end}
{pstd}Madison, WI, USA{p_end}
{pstd}{browse "mailto:long.hong@wisc.edu":long.hong@wisc.edu}


{title:References}

{pstd}Bonetti, M., Gigliarano, C. and Muliere, P. (2009). The Gini 
concentration test for survival data. {it: Lifetime Data Analysis}, 15, 
493-518.

{pstd}Gigliarano, C. and Bonetti, M. (2011). The Gini test for survival data 
in presence of small and unbalanced groups. In press, Biomedical Statistics 
and Clinical epidemiology.


