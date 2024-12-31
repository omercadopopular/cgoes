{smcl}
{* *! version 0.4  20May2019}{...}
{cmd:help rforest}{right: ({browse "https://doi.org/10.1177/1536867X20909688":SJ20-1: st0587})}
{hline}

{title:Title}

{p2colset 5 16 18 2}{...}
{p2col :{cmd:rforest} {hline 2}}Random forest algorithm{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 15 2}
{cmd:rforest} {depvar} {indepvars} {ifin} [{cmd:,} {it:options}]

{synoptset 20}{...}
{synopthdr}
{synoptline}
{synopt :{opt type(string)}}type of decision tree; must be one of {cmd:class}
(classification) or {cmd:reg} (regression){p_end}
{synopt :{opt iter:ations(int)}}set the number of iterations (trees); default
is {cmd:iterations(100)}{p_end}
{synopt: {opt numv:ars(int)}}set the number of variables to randomly
investigate; default is {cmd:numvars(sqrt(}{it:number_of_indepvars}{cmd:))}{p_end}
{synopt :{opt d:epth(int)}}set the maximum depth of the random forest; default
is {cmd:depth(0)} (unlimited){p_end}
{synopt :{opt ls:ize(int)}}set the minimum number of observations per leaf;
default is {cmd:lsize(1)}{p_end}
{synopt :{opt v:ariance(real)}}set the minimum proportion of the variance at a
node to perform splitting in regression trees; default is
{cmd:variance(1e^(-3))}; applicable only to regression{p_end}
{synopt :{opt s:eed(int)}}set the seed value; default is {cmd:seed(1)}{p_end}
{synopt :{opt numdec:imalplaces(int)}}set the precision for computation;
default is {cmd:numdecimalplaces(5)}{p_end}
{synoptline}


{title:Predict syntax}

{phang}
{cmd:predict} {{newvar}|{it:newvarlist}|{it:stub}{cmd:*}} {ifin} [{cmd:,} {cmd:pr}]{p_end}

{phang}
If option {opt pr} is specified, the postestimation command returns the class
probabilities.  This option is applicable only to classification problems.


{marker description}{...}
{title:Description}

{pstd}
{cmd:rforest} is a plugin for random forest classification and regression
algorithms.  It is built on a Java backend that acts as an interface to the
RandomForest Java class presented in the Weka project, which was developed at
the University of Waikato and distributed under the GNU Public License.{p_end}


{marker optionsForRandomForest}{...}
{title:Options for rforest}

{phang}
{opt type(string)} specifies whether the prediction is categorical or
continuous.  {cmd:type(class)} builds a classification tree, and
{cmd:type(reg)} builds a regression tree.

{phang}
{opt iterations(int)} sets the number of trees to be generated when
constructing the model.  The default is {cmd:iterations(100)}.

{phang}
{opt numvars(int)} sets the number of independent variables to randomly
investigate at each split.  The default is
{cmd:numvars(sqrt(}{it:number_of_indepvars}{cmd:))}.

{phang}
{opt depth(int)} sets the maximum depth of the random forest model, which is
the length of the longest path from the root node to a leaf node.  The default
is {cmd:depth(0)}, which indicates that the maximum height is unlimited.

{phang}
{opt lsize(int)} sets the minimum number of observations to include at each
leaf node.  The default is {cmd:lsize(1)}.

{phang}
{opt variance(real)} sets the minimum proportion of the variance on all the
data that need to be present at a node to perform splitting in regression
trees.  If the variance of the dependent variable is {cmd:a} on the full
dataset and this parameter is set to {cmd:b}, then a node will be considered
for splitting only if the variance of the dependent variable at this node is
at least {cmd:a * b}.

{phang}
{opt seed(int)} sets the seed value for reproducible results.

{phang}
{opt numdecimalplaces(int)} sets the number of decimal places to be retained
during random forest model building and postestimation.


{marker optionsForPredict}{...}
{title:Options for predict}

{phang}
Options must be the same as those specified for {cmd:rforest} in {cmd:type()}.

{pstd}
For regression models, a single {newvar} needs to be supplied.  This is also
true for classification models where class assignments are desired rather than
the probabilities for each class.  For classification models with class
probabilities ({opt pr}), one variable needs to be supplied for each class of
the dependent variable.  For example, two variables need to be specified for
binary outcomes.  This can be accomplished either by specifying all variable
names in {it:newvarlist} or by specifying a {it:stub}{cmd:*} that creates
variables by substituting {cmd:*} with integers ranging from 1 to the number
of classes.  The order of the variable names corresponds to the order of the
class values from lowest to highest.

{pstd}
In the regression case, {cmd:predict} {it:newvar} computes the expected values
of the dependent variable, which is a set of continuous real numbers, based on
the previously computed model and the current set of observations.

{pstd}
In the classification case, {cmd:predict} {it:newvar} computes the expected
values of the dependent variable, which is a set of discrete positive
integers, based on the previously computed model and the current set of
observations.

{pstd}
In the classification case, {cmd:predict} {it:varlist}|{it:stub}{cmd:*, pr}
computes the expected probability distributions of the dependent variable,
which is a set of continuous real numbers between 0 and 1, based on the
previously computed model and the current set of observations.  To use this
command, you must specify the individual classes that you want to predict in
the same order as the results of {cmd:levelsof} {it:depvar}.  For an example,
please refer to the {it:Classification} section of {it:Examples}.


{marker details}{...}
{title:Details}

{pstd}
Missing values:{p_end}
{pstd}
The independent variables may contain missing values.  Splits at any node can
occur even if some independent variables are missing.  If the independent
variable is missing from an observation, it will be ignored for estimation,
but predictions can still be made on the observation.  If the dependent
variable for the training data contains missing values, the function will exit
with an error message.  In other words, any missing values in the dependent
(response) variable in the training set need to be imputed or excluded prior
to executing the {cmd:rforest} command.{p_end}

{pstd}
Class values:{p_end}
{pstd}
For classification problems, the class values must be nonnegative integers.

{pstd}
Out-of-bag (OOB) error:{p_end}
{pstd}
An OOB error is computed against the samples not included in the subtrees of
the random forest during the training stage.  For regression problems, this
value represents the root mean squared error. For classification problems,
this value represents the classification error.  Typically, a scatterplot of
the OOB error versus the number of iterations monitors the convergence of the
OOB error. If convergence is not reached, the number of iterations is
increased.  It is not possible to produce such a plot in a single run, because
Weka computes the OOB estimates only once, when the entire ensemble has been
built.  In practice, this means {cmd:rforest} needs to be run at least twice
with two different iterations (for example, 1,000 and 1,100).  If the OOB
error is roughly the same, either run is satisfactory; otherwise, the number
of iterations needs to be increased.

{pstd}
Splitting criterion:{p_end}
{pstd}
Random forest uses entropy for split selection in the classification case.

{pstd}
For more information on the Weka library, please visit
{browse "http://www.cs.waikato.ac.nz/~ml/index.html"}.

{pstd}
Installation:{p_end}
{pstd}
Installation details are not relevant to most users.  This plugin requires Java
Runtime Environment 1.8.0, which comes with your Stata download.  If you cannot
find a folder titled {cmd:jre1.8.0_121.jre} or if you encounter a Java
runtime error when calling functions from the {cmd:rforest} plugin, try
downloading and installing JDK v.8 from Oracle's website at 
{browse "http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html"}.
You can verify that all the {cmd:.jar} files are in the right paths and that
Java has been initialized by typing {cmd:query java} in the Stata Command
window.


{marker runexamples}{...}
{title:Examples}
INCLUDE help rforest_examples


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:rforest} stores the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(depvar)}}name of the dependent variable{p_end}
{synopt:{cmd:e(Observations)}}number of observations{p_end}
{synopt:{cmd:e(features)}}number of attributes used in building the random forest{p_end}
{synopt:{cmd:e(Iterations)}}number of iterations used in building the random forest{p_end}
{synopt:{cmd:e(OOB_Error)}}OOB error calculated when building the random forest{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:rforest}{p_end}
{synopt:{cmd:e(predict)}}program used to implement {cmd:predict}{p_end}
{synopt:{cmd:e(model_type)}}indicates whether model is a classification or
regression model{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(importance)}}the matrix of variable importance for each variable used when building the classifier; the values are scaled proportional to the largest value in the set{p_end}

{pstd}
{cmd:predict} stores the following in {cmd:e()}:

{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(MAE)}}mean absolute error (applicable only to regression problems){p_end}
{synopt:{cmd:e(RMSE)}}root mean squared error (applicable only to regression problems){p_end}
{synopt:{cmd:e(correct_class)}}number of correctly classified observations
(applicable only to classification problems){p_end}
{synopt:{cmd:e(incorrect_class)}}number of incorrectly classified observations
(applicable only to classification problems){p_end}
{synopt:{cmd:e(error_rate)}}error rate (applicable only to classification problems){p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(fMeasure)}}the matrix of f-measures for each class (applicable
only to classification problems){p_end}


{pstd}
All results from the {cmd:predict} statement refer to the observations as
specified by {cmd:if} or {cmd:in} qualifiers in the {cmd:predict} command.
The {cmd:rforest} command may have used a different {cmd:if} or {cmd:in}
qualifier for training.

{pstd}
If the dependent variable of the observations (as specified by {cmd:if} or
{cmd:in} in the {cmd:predict} statement) contains missing values, these
statistics are not computed.


{title:Copyright}

{pstd}
{cmd:Wrapper}

{pstd}
Copyright 2017 Matthias Schonlau{p_end}

{pstd}
This program is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later
version.

{pstd}
This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
details.

{pstd}
For the GNU General Public License, please visit
{browse "http://www.gnu.org/licenses/"}.{p_end}

{pstd}
{cmd:Weka}{p_end}
{pstd}
GNU GENERAL PUBLIC LICENSE, Version 3, 29 June 2007{p_end}
{pstd}
For a full copy of the license, please visit
{browse "http://weka.sourceforge.net/"}.


{marker technical}{...}
{title:Technical notes}

{pstd}
At its current stage, this plugin is not designed for large-scale parallel
computing.  Performance may vary between different machines.  For 64-bit Mac
OS with 16 GB of RAM, the maximum matrix size tested is around 40,000 by 403,
or 16,120,000 entries in total.


{marker authors}{...}
{title:Authors}

{pstd}
Matthias Schonlau{break}
University of Waterloo{break}
Waterloo, Canada{break}
schonlau@uwaterloo.ca

{pstd}
Rosie Yuyan Zou{break}
University of Waterloo{break}
Waterloo, Canada{break}
y53zou@uwaterloo.ca


{marker alsosee}{...}
{title:Also see}

{p 4 14 2}
Article:  {it:Stata Journal}, volume 20, number 1: {browse "https://doi.org/10.1177/1536867X20909688":st0587}{p_end}
