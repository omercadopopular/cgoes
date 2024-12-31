{smcl}
{* *! version 3.0.3 17feb2017}{...}
{cmd:help probitfe} 
{hline}

{title:Title}

{p2colset 5 19 21 2}{...}
{p2col :{bf:probitfe} {hline 2}}Analytical and Jackknife bias 
corrections for fixed effects estimators of panel probit models
with individual and time effects{p_end}
{p2colreset}{...}


{title:Syntax}

{phang}
Uncorrected (NC) estimator

{p 8 16 2}{cmd:probitfe} {depvar} [{indepvars}] {ifin}
{cmd:, {opt noc:orrection}} [{it:{help fvw13##ncoptions:NC_options}}]


{phang}
Analytical-corrected (AC) estimator

{p 8 16 2}{cmd:probitfe} {depvar} [{indepvars}] {ifin}
[{cmd:, {opt an:alytical}} {it:{help fvw13##acoptions:AC_options}}]


{phang}
Jackknife-corrected (JC) estimator

{p 8 16 2}{cmd:probitfe} {depvar} [{indepvars}] {ifin}
{cmd:, {opt jack:knife}} [{it:{help fvw13##jcoptions:JC_options}}]


{marker ncoptions}{...}
{synoptset 20 tabbed}{...}
{synopthdr :NC_options}
{synoptline}
{syntab:Estimator}
{synopt :{opt noc:orrection}}compute the uncorrected 
estimator{p_end}

{syntab:Type of Included Effects}
{synopt :{opt ieffects(string)}}select whether the uncorrected
estimator includes individual effects; {cmd:yes} (the default) 
or {cmd:no}{p_end}
{synopt :{opt teffects(string)}}select whether the uncorrected
estimator includes time effects; {cmd:yes} (the default) or 
{cmd:no}{p_end}

{syntab:Finite Population Correction}
{synopt :{opt pop:ulation(integer)}}adjust the variance of 
the Average Partial Effects by a finite population correction 
using the population size declared by the user{p_end}


{marker acoptions}{...}
{synoptset 20 tabbed}{...}
{synopthdr :AC_options}
{synoptline}
{syntab:Estimator}
{synopt :{opt an:alytical}}the default, use analytical bias 
correction{p_end}

{syntab:Trimming Parameter}
{synopt :{opt lags(integer)}}specifies the value of the trimming parameter to estimate spectral 
expectations. The default is {cmd:lags(0)}{p_end}

{syntab:Type of Included Effects}
{synopt :{opt ieffects(string)}}select whether the uncorrected
estimator includes individual effects; {cmd:yes} (the default) 
or {cmd:no}{p_end}
{synopt :{opt teffects(string)}}select whether the uncorrected
estimator includes time effects; {cmd:yes} (the default) or 
{cmd:no}{p_end}

{syntab:Type of Correction}
{synopt :{opt ibias(string)}}select whether the analytical 
correction accounts for individual effects; {cmd:yes} (the default) 
or {cmd:no}{p_end}
{synopt :{opt tbias(string)}}select whether the analytical 
correction accounts for time effects; {cmd:yes} (the default) or 
{cmd:no}{p_end}

{syntab:Finite Population Correction}
{synopt :{opt pop:ulation(integer)}}adjust the variance of 
the Average Partial Effects by a finite population correction 
using the population size declared by the user{p_end}


{marker jcoptions}{...}
{synoptset 20 tabbed}{...}
{synopthdr :JC_options}
{synoptline}
{syntab:Estimator}
{synopt :{opt jack:knife}}use a panel jackknife technique
to correct the bias{p_end}

{syntab:# of Partitions}
{synopt :{opt ss1}}split jackknife in four subpanels, leaving half 
individuals and half time periods out in each subpanel{p_end}
{synopt :{opt ss2}}the default, split jackknife in both dimensions,
leaving half panel out and including either all time periods or all individuals{p_end}
{synopt :{opt js}}delete-one jackknife in cross-section, split 
panel jackknife in time-series{p_end}
{synopt :{opt sj}}split panel jackknife in cross-section, delete-one
jackknife in time-series{p_end}
{synopt :{opt jj}}delete-one jackknife in both cross-section and 
time-series{p_end}
{synopt :{opt double}}delete-one jackknife for observations with the
same index in the cross-section and the time-series (see options below for details){p_end}

{syntab:ss1 Suboptions}
{synopt :{opt mul:tiple(integer)}}allow for multiple partitions, 
each one made on a randomization of the observations in the 
panel; the default is zero (the partitions are made on the original order in the data set){p_end}
{synopt :{opt i:ndividuals}}select whether the multiple partitions are 
made only on the cross-sectional dimension{p_end}
{synopt :{opt t:ime}}select whether the multiple partitions are made 
only on the time dimension{p_end}

{syntab:ss2 Suboptions}
{synopt :{opt mul:tiple(integer)}}allow for multiple partitions, 
each one made on a randomization of the observations in the 
panel; the default is zero (the partitions are made on the original order in the data set){p_end}
{synopt :{opt i:ndividuals}}select whether the multiple partitions are 
made only on the cross-sectional dimension{p_end}
{synopt :{opt t:ime}}select whether the multiple partitions are made 
only on the time dimension{p_end}

{syntab:Type of Included Effects}
{synopt :{opt ieffects(string)}}select whether the uncorrected
estimator includes individual effects; {cmd:yes} (the default) 
or {cmd:no}{p_end}
{synopt :{opt teffects(string)}}select whether the uncorrected
estimator includes time effects; {cmd:yes} (the default) or 
{cmd:no}{p_end}

{syntab:Type of Correction}
{synopt :{opt ibias(string)}}select whether the split jackknife correction 
accounts for individual effects; {cmd:yes} (the default) or {cmd:no}{p_end}
{synopt :{opt tbias(string)}}select whether the split jackknife correction 
accounts for time effects; {cmd:yes} (the default) or {cmd:no}{p_end}

{syntab:Finite Population Correction}
{synopt :{opt pop:ulation(integer)}}adjust the variance of 
the Average Partial Effects by a finite population correction 
using the population size declared by the user{p_end}

{synoptline}
{p2colreset}{...}

{p 4 6 2}
Both, a panel variable and a time variable must be specified. 
Use {helpb tsset}.{p_end}
{p 4 6 2}{it:indepvars} may contain factor variables; see {help fvvarlist}.
{p_end}
{p 4 6 2}
{it:depvar} and {it:indepvars} may contain time-series operators; see {help tsvarlist}.{p_end}


{title:Description}

{pstd}
{cmd:probitfe} fits a probit fixed-effects estimator that can include individual
and/or time effects, and account for both the bias arising from the inclusion
of individual fixed-effects and/or the bias arising from the inclusion of
time fixed-effects.
{cmd:probitfe} with the {cmd: {opt noc:orrection}} option does not correct 
for the incidental parameter bias problem (Neyman and Scott, 1948).

{pstd}
{cmd:probitfe} with the {cmd: {opt an:alytical}} option removes an analytical estimate
of the bias from the probit fixed-effects estimator using the 
expressions derived in Fernandez-Val and Weidner (2013). The
trimming parameter can be set to any value between 0 and (T-1), where
T is the number of time periods.

{pstd}
{cmd:probitfe} with the {cmd: {opt jack:knife}} option removes a jackknife estimate
of the bias from the fixed effects estimator. This method is based on the delete-one
panel jackknife of Hahn and Newey (2004) and split panel jackknife of 
Dhaene and Jochmans (2010) as described in Fernandez-Val and Weidner (2013).

{pstd}
{cmd:probitfe} displays estimates of Index Coefficients 
and Average Partial Effects.


{title:Options for NC estimator}

{dlgtab:Estimator}

{phang}
{opt noc:orrection} computes the probit fixed-effects estimator
without correcting for the bias
due to the incidental parameter problem.

{dlgtab:Type of Included Effects}

{phang}
{opt ieffects(string)} specifies whether the uncorrected estimator
includes individual effects.

{phang2}
{opt ieffects(yes)}, the default, includes
individual fixed-effects.

{phang2}
{opt ieffects(no)} omits the individual fixed-effects.

{phang}
{opt teffects(string)} specifies whether the uncorrected estimator
includes time effects.

{phang2}
{opt teffects(yes)}, the default, includes
time fixed-effects.

{phang2}
{opt teffects(no)} omits the time fixed-effects.

{phang}
If the {cmd: {opt noc:orrection}} option without type of included effects is specified then 
the model will include both individual and 
time effects. {cmd: {opt ieffects(no)}} and {cmd: {opt teffects(no)}} is an invalid
option.

{dlgtab:Finite Population Correction}

{phang}
{opt pop:ulation(integer)} adjusts the estimation of the variance of the Average
Partial Effects (APE's) by a finite population correction. Let m be the number of original
observations included in {cmd:probitfe}, and M>=m the number of observations
for the entire population declared by the user. The computation of the variance 
of the APE's is corrected by the factor fpc=(M-m)/(M-1). The default is fpc=1, corresponding to an infinity population. 
Notice that M makes reference to the total number of observations and not the total 
number of individuals. If, for example, the population has 100 individuals followed 
over 10 time periods, the user must use {cmd: {opt pop:ulation(1000)}} instead of 
{cmd: {opt pop:ulation(100)}}.


{title:Options for AC estimator}

{dlgtab:Estimator}

{phang}
{opt an:alytical}, the default, computes the probit fixed-effects estimator 
using the analytical bias correction derived in Fernandez-Val and Weidner (2013).

{dlgtab:Trimming Parameter}

{phang}
{opt lags(integer)} specifies the value of the trimming parameter to estimate spectral 
expectations, see Fernandez-Val and Weidner (2013) for the details. 
The default if {cmd: lags(0)}. This option should be used when the model is 
static with strictly exogeneous regressors.
The trimming parameter can be set to any value between 0 and (T-1), where T
denotes the number of time periods. A trimming parameter higher than 0 should be 
used when the model is dynamic or some of the regressors is weakly exogenous or predetermined.
We do not recommend to set the value of the trimming parameter to a value
higher than 4.

{dlgtab:Type of Included Effects}

{phang}
{opt ieffects(string)} specifies whether the estimator
includes individual effects.

{phang2}
{opt ieffects(yes)}, the default, includes
individual fixed-effects.

{phang2}
{opt ieffects(no)} omits the individual fixed-effects.

{phang}
{opt teffects(string)} specifies whether the estimator
includes time effects.

{phang2}
{opt teffects(yes)}, the default, includes
time fixed-effects.

{phang2}
{opt teffects(no)} omits the time fixed-effects.

{phang}
If the {opt an:alytical} option without type of included effects is specified then 
the model will include both individual and 
time effects. {opt ieffects(no)} and {opt teffects(no)} is an invalid
option.

{dlgtab:Type of Correction}

{phang}
{opt ibias(string)} specifies whether the analytical correction accounts 
for individual effects.

{phang2}
{opt ibias(yes)}, the default, corrects for the bias coming from the 
individual fixed-effects.

{phang2}
{opt ibias(no)} omits the individual fixed-effects analytical bias 
correction.

{phang}
{opt tbias(string)} specifies whether the analytical correction accounts 
for time effects.

{phang2}
{opt tbias(yes)}, the default, corrects for the bias coming from the 
time fixed-effects.

{phang2}
{opt tbias(no)} omits the time fixed-effects analytical bias correction.

{phang}
If the {opt an:alytical} option without type of correction is specified then 
the model will include analytical bias correction for both individual and 
time effects. {opt ibias(no)} and {opt tbias(no)} is an invalid
option.

{dlgtab:Finite Population Correction}

{phang}
{opt pop:ulation(integer)} adjusts the estimation of the variance of the Average
Partial Effects (APE's) by a finite population correction. Let m be the number of original
observations included in {cmd:probitfe}, and M>=m the number of observations
for the entire population declared by the user. The computation of the variance 
of the APE's is corrected by the factor fpc=(M-m)/(M-1). The default is fpc=1, corresponding to an infinity population. 
Notice that M makes reference to the total number of observations and not the total 
number of individuals. If, for example, the population has 100 individuals followed 
over 10 time periods, the user must use {cmd: {opt pop:ulation(1000)}} instead of 
{cmd: {opt pop:ulation(100)}}.


{title:Options for JC estimator}

{dlgtab:Estimator}

{phang}
{opt jack:knife} computes the probit fixed effects estimator using the jackknife bias corrections described
in Fernandez-Val and Weidner (2013).

{dlgtab:# of Partitions}

{phang}
{opt ss1} specifies split panel jackknife in four nonoverlapping subpanels; in each subpanel 
half of the individuals and half of the time periods are left out and 
the uncorrected fixed effects estimator is computed in each subpanel. Let {it:b} be the 
uncorrected estimator using the whole sample, and {it:b1},...,{it:b4} 
be the uncorrected estimators in each subpanel. The {cmd:ss1} estimator 
is given by 2*b - (b1 + b2 + b3 + b4)/4.

{phang2}
{opt mul:tiple(integer)} is a {cmd:ss1} suboption that allows for different 
multiple partitions, each one made on a randomization of the 
observations in the panel; the default is zero, i.e. the partitions are made on the
original order in the data set. If {cmd:multiple(10)}
is specified, for example, then the {cmd:ss1} estimator is computed 10 times 
on 10 different randomizations of the observations in the panel; the 
resulting estimator is the mean of these 10 split panel jackknife corrections.
This option can be used if there is a dimension of the panel where there is no
natural ordering of the observations.

{phang2}
{opt i:ndividuals} specifies the multiple partitions to be made only on the 
cross-sectional dimension.

{phang2}
{opt t:ime} specifies the multiple partitions to be made only on the time 
dimension.

{phang2}
If neither {opt i:ndividuals} nor {opt t:ime} options are specified, the multiple 
partitions are made on both the cross-sectional and the time dimensions.

{phang}
{opt ss2}, the default, specifies split jackknife in both dimensions. 
As in {cmd:ss1}, there are four subpanels: in {it:subpanel 1} and 
{it:subpanel 2} half of the individuals are left out but all time periods 
are included in the fixed-effects estimations; in {it:subpanel 3} and 
{it:subpanel 4} half of the time periods are left out but all the 
individuals are included in the fixed-effects estimations. Let {it:b} 
be the uncorrected estimator using the whole sample, {it:b1} the mean 
of the uncorrected estimator in subpanels 1 and 2, and {it:b2} the mean 
of the uncorrected estimator in subpanels 3 and 4. The {cmd:ss2} estimator 
is given by 3*b - b1 - b2.

{phang2}
{opt mul:tiple(integer)} is a {cmd:ss2} suboption that allows for different 
multiple partitions, each one made on a randomization of the 
observations in the panel; the default is zero, i.e. the partitions are made on the
original order in the data set. If {cmd:multiple(10)}
is specified, for example, then the {cmd:ss2} estimator is computed 10 times 
on 10 different randomizations of the observations in the panel; the 
resulting estimator is the mean of these 10 split panel jackknife corrections.
This option can be used if there is a dimension of the panel where there is no
natural ordering of the observations.

{phang2}
{opt i:ndividuals} specifies the multiple partitions to be made only on the 
cross-sectional dimension, that is the randomization affects only subpanels 
1 and 2.

{phang2}
{opt t:ime} specifies the multiple partitions to be made only on the time 
dimension, that is the randomization affects only subpanels 3 and 4.

{phang2}
If neither {opt i:ndividuals} nor {opt t:ime} options are specified, the multiple 
partitions are made on both the cross-sectional and the time dimensions.

{phang}
{opt js} uses delete-one panel jackknife in the cross-section and split panel jackknife 
in the time series. There are N + 2 subpanels, one for each of the 
N-individuals and two subpanels in which half of the time periods are left out.
Let {it:b} be the uncorrected fixed effects estimator that uses the whole 
sample, {it:b1} be the mean of the N uncorrected fixed effects estimators 
for each of the N subpanels in which one individual is left out, and {it:b2}
be the mean of the two subpanels in which half of the time periods are left out. 
The {cmd:js} estimator is given by (N+1)*b-(N-1)*b1-b2. When N is  
large, this estimator might be computationally intensive.

{phang}
{opt sj} uses split panel jackknife in the cross-section and delete-one panel jackknife 
in the time series. There are T + 2 subpanels, one for each of the 
T-time periods and two subpanels in which half of the individuals are left out.
Let {it:b} be the uncorrected fixed effects estimator that uses the whole 
sample, {it:b1} be the mean of the T uncorrected fixed effects estimators 
for each of the T subpanels in which one time period is left out, and {it:b2}
be the mean of the two subpanels in which half of the individuals are left out. 
The {cmd:sj} estimator is given by (T+1)*b-(T-1)*b1-b2. When T is  
large, this estimator might be computationally intensive.

{phang}
{opt jj} uses delete-one jackknife in both the cross-section and the time 
series. There are N + T subpanels, one for each of the N-individuals and one 
for each of the T time periods. Let {it:b} be the uncorrected fixed effects 
estimator that uses the whole sample, {it:b1} be the mean of the N uncorrected 
fixed-effects estimators for each of the N subpanels in which one individual 
is left out, and {it:b2} be the mean of the T uncorrected fixed effects 
estimators for each of the T subpanels in which one time period
is left out. The {cmd:jj} estimator is given by (N+T-1)*b-(N-1)*b1-(T-1)*b2.
When either N or T are large, this estimator might be 
computationally intensive.

{phang}
{opt double} uses delete-one jackknife for observations with the same cross-section 
and the time-series indexes. This type of correction makes sense for panels where
i and t index the same entities. For example, in country trade data, the cross-section dimension
represents each country as an importer, and the time-series dimension represents each 
country as an exporter. In this case, {opt double} constructs each subpanel by dropping one country
(both as an importer and as an exporter).  Let i=1,...,N denote one dimension of the panel 
and let t=1,...,N denote the other dimension. {opt double} uses delete-one 
jackknife for the M<=N subpanels for which i=t. Let {it:b} be the uncorrected fixed 
effects estimator that uses the whole sample, and {it:b1} be the mean of the M uncorrected
fixed-effects estimators for each of the M<=N subpanels in which i=t. 
The {opt double} estimator is given by M*b-(M-1)*b1. 
When M is large, this estimator can be computationally intensive.

{dlgtab:Type of Included Effects}

{phang}
{opt ieffects(string)} specifies whether the estimator
includes individual effects.

{phang2}
{opt ieffects(yes)}, the default, includes
individual fixed-effects.

{phang2}
{opt ieffects(no)} omits the individual fixed-effects.

{phang}
{opt teffects(string)} specifies whether the estimator
includes time effects.

{phang2}
{opt teffects(yes)}, the default, includes
time fixed-effects.

{phang2}
{opt teffects(no)} omits the time fixed-effects.

{phang}
If the {opt jack:knife} option without type of included effects is specified 
then the model will include both individual and 
time effects. {opt ieffects(no)} and {opt teffects(no)} is an invalid
option.

{dlgtab:Type of Correction}

{phang}
{opt ibias(string)} specifies whether the jackknife correction accounts 
for the individual effects.

{phang2}
{opt ibias(yes)}, the default, corrects for the bias coming from the 
individual fixed-effects.

{phang2}
{opt ibias(no)} omits the individual fixed-effects jackknife correction.
If this option and multiple partitions only in the time-dimension are
specified togeteher (for the jackknife {cmd:ss1/ss2} corrections), the
resulting estimator is equivalent to the one without multiple partitions.

{phang}
{opt tbias(string)} specifies whether the jackknife correction accounts 
for the time effects.

{phang2}
{opt tbias(yes)}, the default, corrects for the bias coming from the time 
fixed-effects.

{phang2}
{opt tbias(no)} omits the time fixed-effects jackknife correction.
If this option and multiple partitions only in the cross-section are
specified togeteher (for the jackknife {cmd:ss1/ss2} corrections), the
resulting estimator is equivalent to the one without multiple partitions.

{phang}
If the {opt jack:knife} option without type of correction is specified 
then the model will include jackknife correction for both individual and 
time effects. {opt ibias(no)} and {opt tbias(no)} is an invalid
option.

{dlgtab:Finite Population Correction}

{phang}
{opt pop:ulation(integer)} adjusts the estimation of the variance of the Average
Partial Effects (APE's) by a finite population correction. Let m be the number of original
observations included in {cmd:probitfe}, and M>=m the number of observations
for the entire population declared by the user. The computation of the variance 
of the APE's is corrected by the factor fpc=(M-m)/(M-1). The default is fpc=1, corresponding to an infinite population. 
Notice that M makes reference to the total number of observations and not the total 
number of individuals. If, for example, the population has 100 individuals followed 
over 10 time periods, the user must use {cmd: {opt pop:ulation(1000)}} instead of 
{cmd: {opt pop:ulation(100)}}.


{title:Examples}

{pstd}Setup{p_end}
{phang2}{cmd:. webuse lfp_psid}{p_end}
{phang2}{cmd:. tsset ID1979 year}{p_end}

{pstd}Uncorrected estimator: static model with individual and time effects{p_end}
{phang2}{cmd:. probitfe lfp kids0_2 kids3_5 kids6_17 loghusbandincome age age2, noc}{p_end}

{pstd}Uncorrected estimator: static model with individual effects{p_end}
{phang2}{cmd:. probitfe lfp kids0_2 kids3_5 kids6_17 loghusbandincome age age2, noc teffects(no)}{p_end}

{pstd}Uncorrected estimator: static model with time effects{p_end}
{phang2}{cmd:. probitfe lfp kids0_2 kids3_5 kids6_17 loghusbandincome age age2, noc ieffects(no)}{p_end}

{pstd}Uncorrected estimator: dynamic model with individual and time effects{p_end}
{phang2}{cmd:. probitfe lfp L.lfp kids0_2 kids3_5 kids6_17 loghusbandincome age age2, noc}{p_end}

{pstd}Analytcal-corrected estimator: static model with individual and time effects and trimming parameter set to zero{p_end}
{phang2}{cmd:. probitfe lfp kids0_2 kids3_5 kids6_17 loghusbandincome age age2, an l0}{p_end}

{pstd}Analytcal-corrected estimator: dynamic model with individual and time effects and trimming parameter set to one (the default){p_end}
{phang2}{cmd:. probitfe lfp L.lfp kids0_2 kids3_5 kids6_17 loghusbandincome age age2}{p_end}
{phang2}{cmd:. probitfe lfp L.lfp kids0_2 kids3_5 kids6_17 loghusbandincome age age2, an l1}{p_end}

{pstd}Analytcal-corrected estimator: dynamic model with individual and time effects and trimming parameter set to one. Use finite population
correction asuming population equal to number of observations in the data set{p_end}
{phang2}{cmd:. probitfe lfp L.lfp kids0_2 kids3_5 kids6_17 loghusbandincome age age2}{p_end}
{phang2}{cmd:. local N = e(N) + e(N_drop)}{p_end}
{phang2}{cmd:. probitfe lfp L.lfp kids0_2 kids3_5 kids6_17 loghusbandincome age age2, pop(`N')}{p_end}

{pstd}Jackknife-corrected estimator: static model with individual and time effects using option {cmd: ss1}{p_end}
{phang2}{cmd:. probitfe lfp kids0_2 kids3_5 kids6_17 loghusbandincome age age2, jack ss1}{p_end}

{pstd}Jackknife-corrected estimator: static model with individual and time effects using option {cmd: ss2}{p_end}
{phang2}{cmd:. probitfe lfp kids0_2 kids3_5 kids6_17 loghusbandincome age age2, jack ss2}{p_end}

{pstd}Jackknife-corrected estimator: static model with individual and time effects using option {cmd: ss2}. Five
multiple partitions in both the cross-section and the time dimension{p_end}
{phang2}{cmd:. probitfe lfp kids0_2 kids3_5 kids6_17 loghusbandincome age age2, jack ss2 mul(5)}{p_end}

{pstd}Jackknife-corrected estimator: static model with individual and time effects using option {cmd: ss2}. Five
multiple partitions in the cross-section only{p_end}
{phang2}{cmd:. probitfe lfp kids0_2 kids3_5 kids6_17 loghusbandincome age age2, jack ss2 mul(5) i}{p_end}

{pstd}Jackknife-corrected estimator: static model with individual and time effects using option {cmd: ss2}. Five
multiple partitions in the time dimension only{p_end}
{phang2}{cmd:. probitfe lfp kids0_2 kids3_5 kids6_17 loghusbandincome age age2, jack ss2 mul(5) t}{p_end}

{pstd}Jackknife-corrected estimator: static model with individual and time effects using option {cmd: js}{p_end}
{phang2}{cmd:. probitfe lfp kids0_2 kids3_5 kids6_17 loghusbandincome age age2, jack js}{p_end}

{pstd}Jackknife-corrected estimator: static model with individual and time effects using option {cmd: jj}{p_end}
{phang2}{cmd:. probitfe lfp kids0_2 kids3_5 kids6_17 loghusbandincome age age2, jack jj}{p_end}

{pstd}Jackknife-corrected estimator: static model with individual and time effects using option {cmd: double}{p_end}
{phang2}{cmd:. webuse trade}{p_end}
{phang2}{cmd:. tsset id jd}{p_end}
{phang2}{cmd:. g islands2 = islands==2}{p_end}
{phang2}{cmd:. g landlock2 = landlock==2}{p_end}
{phang2}{cmd:. probitfe trade ldist border legal language colony currency fta islands2 religion landlock2, jack double}{p_end}


{title:Saved results}

{pstd}
{cmd:probitfe} saves the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(N_drop)}}number of observations dropped because of all positive or all zero outcomes{p_end}
{synopt:{cmd:e(N_group_drop)}}number of groups dropped because of all positive or all zero outcomes{p_end}
{synopt:{cmd:e(N_time_drop)}}number of time periods dropped because of all positive or all zero outcomes{p_end}
{synopt:{cmd:e(N_group)}}number of groups{p_end}
{synopt:{cmd:e(T_min)}}smallest group size{p_end}
{synopt:{cmd:e(T_avg)}}average group size{p_end}
{synopt:{cmd:e(T_max)}}largest group size{p_end}
{synopt:{cmd:e(k)}}number of parameters excluding individual and/or time effects{p_end}
{synopt:{cmd:e(df_m)}}model degrees of freedom{p_end}
{synopt:{cmd:e(r2_p)}}pseudo R-squared{p_end}
{synopt:{cmd:e(chi2)}}likelihood-ratio chi-squared model test{p_end}
{synopt:{cmd:e(p)}}significance of model test{p_end}
{synopt:{cmd:e(rankV)}}rank of {cmd:e(V)}{p_end}
{synopt:{cmd:e(rankV2)}}rank of {cmd:e(V2)}{p_end}
{synopt:{cmd:e(ll)}}log-likelihood{p_end}
{synopt:{cmd:e(ll_0)}}log-likelihood, constant-only model{p_end}
{synopt:{cmd:e(fpc)}}finite population correction factor{p_end}


{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:probitfe}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(depvar)}}name of dependent variable{p_end}
{synopt:{cmd:e(title)}}title in estimation output{p_end}
{synopt:{cmd:e(title1)}}type of included effects{p_end}
{synopt:{cmd:e(title2)}}type of correction{p_end}
{synopt:{cmd:e(title3)}}lags for trimming parameter/number of multiple partitions{p_end}
{synopt:{cmd:e(chi2type)}}{cmd:LR}; type of model chi-squared test{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}{p_end}
{synopt:{cmd:e(id)}}name of cross-section variable{p_end}
{synopt:{cmd:e(time)}}name of time variable{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(b2)}}average partial effects{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of coefficient vector{p_end}
{synopt:{cmd:e(V2)}}variance-covariance matrix of average partial effects{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}


{title:Reference}

{phang}
Ivan Fernandez-Val and Martin Weidner. Individual and time effects in nonlinear panel models with large N, T.
November 28, 2013.

{phang}
Neyman, J. and Scott, E.L., 1948. Consistent estimation from partially consistent observations. Econometrica
16, 1-32.

{phang}
Dhaene, Geert and Jochmans, Koen, 2010. Split-panel jackknife estimation of fixed-effect models. 
Forthcoming in Review of Economic Studies.

{phang}
Jinyong Hahn and Whitney Newey, 2004. Jackknife and Analytical Bias Reduction for Nonlinear Panel Models.
Econometrica 72, 4, 1295-1319.



{title:Remarks}

{p 4 4}This is a first and preliminary version. Please feel free to share your comments, reports of bugs and
propositions for extensions.

{p 4 4}If you use this command in your work, please cite Ivan Fernandez-Val and Martin Weidner (2013).


{title:Disclaimer}

{p 4 4 2}THIS SOFTWARE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED 
OR IMPLIED. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU. 
SHOULD THE PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR OR CORRECTION.

{p 4 4 2}IN NO EVENT WILL THE COPYRIGHT HOLDERS OR THEIR EMPLOYERS, OR ANY OTHER PARTY WHO
MAY MODIFY AND/OR REDISTRIBUTE THIS SOFTWARE, BE LIABLE TO YOU FOR DAMAGES, INCLUDING ANY 
GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE THE PROGRAM.


{title:Authors}

{p 4 6}Mario Cruz Gonzalez, Ivan Fernandez-Val and Martin Weidner{p_end}
{p 4 6}Boston University, Boston University and University College London{p_end}
{p 4 6}mgonza@bu.edu{p_end}

