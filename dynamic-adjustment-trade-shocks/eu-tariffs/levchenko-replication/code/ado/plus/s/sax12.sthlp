{smcl}
{* *! version 1.1 11jan2010}{...}
{cmd:help sax12}{right:({browse "http://www.stata-journal.com/article.html?article=st0255":SJ12-2: st0255})}
{right:dialog:  {dialog sax12}}
{hline}

{title:Title}

{p2colset 5 14 16 2}{...}
{p2col :{hi:sax12} {hline 2}}X-12-ARIMA seasonal adjustment{p_end}
{p2colreset}{...}


{marker s_head}{title:Contents}

{p 10}{help sax12##s_syntax:Syntax}{p_end}
{p 10}{help sax12##s_syndes:Options}{p_end}
{p 10}{help sax12##s_outline:Introduction of X-12-ARIMA}{p_end}
{p 15}{help sax12##s_types:Types of seasonal adjustment}{p_end}
{p 15}{help sax12##s_reg:Regression effect}{p_end}
{p 15}{help sax12##s_outlier:Outliers}{p_end}
{p 15}{help sax12##s_arima:ARIMA error}{p_end}
{p 15}{help sax12##s_trans:Transformation and prior adjustment}{p_end}
{p 15}{help sax12##s_x11:X-11 seasonal adjustment}{p_end}
{p 15}{help sax12##s_stab:Stability analysis}{p_end}
{p 10}{help sax12##s_examples:Examples}{p_end}
{p 10}{help sax12##s_saved:Saved results}{p_end}
{p 10}{help sax12##s_reference:References}{p_end}
{p 10}{help sax12##s_official:Official website of X-12-ARIMA}{p_end}


{marker s_syntax}{title:Syntax}

{p 8 13 2}
{cmd:sax12} {varlist} {ifin} [{cmd:,} {it:options}]

{synoptset 23 tabbed}
{synopthdr}
{synoptline}
{marker s_syntype}{syntab:Main}
{synopt:{opt satype(string)}} type of seasonal adjustment: {cmd:single},
{cmd:dta}, or {cmd:mta}{p_end}
{synopt:{opt comptype(string)}} type of composite ({varlist} is part of 
composite series): {cmd:add}, {cmd:mult}, {cmd:sub}, {cmd:div}, or {cmd:none}
(default){p_end}
{synopt:{opt inpref(filename)}} {cmd:.spc} file to save{p_end}
{synopt:{opt outpref(files prefix)}} output files to save; number of files should equal number of adjusted series{p_end}
{synopt:{opt dtafile(filename)}} {cmd:.dta} file to save; used for {cmd:satype(dta)}{p_end}
{synopt:{opt mtaspc(filenames)}} {cmd:.spc} files to perform type III adjustment; used for {cmd:satype(mta)}{p_end}
{synopt:{opt mtafile(filename)}} {cmd:.mta} file to save; used for {cmd:satype(mta)}{p_end}
{synopt:{opt compsa}} make composite adjustment{p_end}
{synopt:{opt compsadir}} perform direct seasonal adjustment for composite series; used for {cmd:satype(mta)}{p_end}

{marker s_synprior}{syntab:Prior}
{synopt:{opt transfunc(string)}} transformation method: {cmd:auto}, {cmd:log},
{cmd:sqrt}, {cmd:inverse}, or {cmd:logistic}{p_end}
{synopt:{opt transpower(real)}} power transformation method; default is {cmd:transpower(0)} (no transformation){p_end}
{synopt:{opt prioradj(string)}} predefined prior-adjustment variables{p_end}
{synopt:{opt priorvar(string)}} user-defined prior-adjustment variables{p_end}
{synopt:{opt priormode(string)}} mode of prior adjustment: {cmd:ratio},
{cmd:diff}, or {cmd:percent}{p_end}
{synopt:{opt priortype(string)}} whether prior adjustment is {cmd:permanent} or {cmd:temporary}{p_end}

{marker s_synreg}{syntab:Regression}
{synopt:{opt regpre(string)}} predefined variables{p_end}
{synopt:{opt regaic(string)}} variables' types to test significance{p_end}
{synopt:{opt reguser(varlist)}} user-defined variables{p_end}
{synopt:{opt regusertype(string)}} specify type of user-defined variables; if you specify only one type, it applies to all variables{p_end}
{synopt:{opt regusercent(string)}} centering method for user-defined
variables: {cmd:mean} or {cmd:seasonal}{p_end}

{marker s_synout}{syntab:Outlier}
{synopt:{opt outauto(string)}} types of automatically identified outliers:
{cmd:ao}, {cmd:ls}, {cmd:tc}, {cmd:all}, or {cmd:none}{p_end}
{synopt:{opt outcrit(string)}} critical values for outliers, e.g.,
{cmd:outcrit(3.0, ,4)} or {cmd:outcrit(3.0,4.5,4)}; missing means default
values; if you specify only one value, it applies to all types of outliers{p_end}
{synopt:{opt outspan(string)}} sample to search outliers, e.g., {cmd:outspan(1998.jan, 2008.dec)}{p_end}
{synopt:{opt outlsrun(integer)}} number of period to construct temporary level shift; must lie in 0-5{p_end}
{synopt:{opt outmethod(string)}} method to detect outliers: {cmd:addone} or
{cmd:addall}{p_end}
{synopt:{opt outao(string)}} user-defined AO outliers, e.g., {cmd:outao(ao2003.5 ao1997.dec)}{p_end}
{synopt:{opt outls(string)}} user-defined LS outliers, e.g., {cmd:outls(ls2003.5 LS2007.nov)}{p_end}
{synopt:{opt outtc(string)}} user-defined TC outliers, e.g., {cmd:outtc(tc2003.5 TC2007.nov)}{p_end}

{marker s_synarima}{syntab:ARIMA}
{synopt:{opt ammodel(string)}} specify ARIMA model by hand, e.g., {cmd:ammodel((0,1,1)(0,1,1))}{p_end}
{synopt:{opt ammaxlag(numlist)}} maximum ARMA lag to search optimal model,
e.g., {cmd:ammaxlag(3,1)}{p_end}
{synopt:{opt ammaxdiff(numlist)}} maximum difference order to search optimal
model, e.g., {cmd:ammaxdiff(1,1)}{p_end}
{synopt:{opt amfixdiff(numlist)}} fixed difference order to search optimal
model, e.g., {cmd:amfixdiff(1,1)}{p_end}
{synopt:{opt amfile(filename)}} file that stores ARIMA model to estimate{p_end}
{synopt:{opt ammaxlead(integer)}} maximum period for forecast{p_end}
{synopt:{opt ammaxback(integer)}} maximum period for backcast{p_end}
{synopt:{opt amlevel(real)}} confidence interval for regARIMA model; default is {cmd:amlevel(95)}{p_end}
{synopt:{opt amspan(string)}} sample of regARIMA model, e.g., {cmd:amspan(1990.1, 2009.12)}{p_end}

{marker s_synx11}{syntab:Adjustment}
{synopt:{opt x11mode(string)}} X-11 mode: {cmd:add}, {cmd:mult}, {cmd:logadd},
or {cmd:pseudoadd}{p_end}
{synopt:{opt x11trend(string)}} trend filter, e.g., {cmd:x11trend(23)}{p_end}
{synopt:{opt x11seas(string)}} seasonal filter, e.g., {cmd:x11seas(s3x5)}{p_end}
{synopt:{opt x11final(string)}} exclude outliers or user-defined variables
from seasonally adjusted series, e.g., {cmd:x11final(ao ls user)}{p_end}
{synopt:{opt x11hol}} keep holidays in seasonally adjusted series{p_end}
{synopt:{opt x11sig(string)}} sigma limits to downweight extreme values in
X-11 adjustment{p_end}

{marker s_synstab}{syntab:Others}
{synopt:{opt history}} revision history analysis{p_end}
{synopt:{opt sliding}} sliding span analysis{p_end}
{synopt:{opt justspc}} view created {cmd:.spc} file but do not perform seasonal adjustment{p_end}
{synopt:{opt noview}} do not view seasonally adjusted result file ({cmd:.out})
nor specification file ({cmd:.spc}, {cmd:.dta}, or {cmd:.mta}){p_end}
{synopt:{opt dsa}} make seasonal adjustment based on existing {cmd:.spc},
{cmd:.dta}, or {cmd:.mta} files; only one category of files may be specified
at once{p_end}
{synopt:{opt dsaspc(filename)}} {cmd:.spc} file, used for {cmd:satype(single)}{p_end}
{synopt:{opt dsadtaspc(filename)}} {cmd:.spc} file, used for {cmd:satype(dta)}{p_end}
{synopt:{opt dsadta(filename)}} {cmd:.dta} file, used for {cmd:satype(dta)}{p_end}
{synopt:{opt dsamta(filename)}} {cmd:.mta} file, used for {cmd:satype(mta)}{p_end}
{synoptline}


{marker s_syndes}{title:Options}

{marker s_syntype}{dlgtab:Main}

{phang}{opt satype(string)} specifies the type of seasonal adjustment
and can be {cmd:single}, {cmd:dta}, or {cmd:mta}.  {cmd:satype(single)}
makes a type I seasonal adjustment for a single series.  {cmd:satype()}
will create one {cmd:.spc} file, which is the specification file for the
seasonal adjustment.

{pmore}{cmd:satype(dta)} makes a type II seasonal adjustment for
multiple series based on the same specifications.  Two files will be
created: an {cmd:.spc} file and a {cmd:.dta} file.  The {cmd:.dta} file
contains the names of all the variables and the output information.

{pmore}{cmd:satype(mta)} makes a type III seasonal adjustment for
multiple series based on the same specifications.  {cmd:satype(mta)}
will create one {cmd:.mta} file, which contains the names of all the
{cmd:.spc} files.

{phang}{opt comptype(string)} specifies how a component series of a
composite (also called an aggregate) series is incorporated into the
composite; {it:string} can be one of {cmd:add}, {cmd:mult}, {cmd:sub},
{cmd:div}, or {cmd:none}.  These component series can be added into the
(partially formed) composite series ({cmd:add}), subtracted from the
composite series ({cmd:sub}), multiplied by the composite series
({cmd:mult}), or divided into the composite series ({cmd:div}).  The
default is no aggregation ({cmd:none}).

{phang}{opt inpref(filename)} specifies the name of the {cmd:.spc} file
to save.  This option may only be used with {cmd:satype(single)} or
{cmd:satype(dta)} because only type I and type II will generate an
{cmd:.spc} file.  The default name is {varlist}{cmd:.spc} if used with
{cmd:satype(single)} and {cmd:dta.spc} if used with {cmd:satype(dta)}.

{phang}{opt outpref(string)} specifies the output files to save and
should contain the same number of names as the number of adjusted
series.  For example, we make a seasonal adjustment for two series, x
and y.  We want to store the results in {cmd:ux.}* and {cmd:uy.}*, so we
specify {cmd:outpref(ux uy)}.  The default prefix of the output files
is {varlist} if used with {cmd:satype(single)} or {cmd:satype(dta)} and
is the name of the {cmd:.spc} file in the {cmd:mtaspc()} option if used
with {cmd:satype(dta)}.  Note: If you make a direct adjustment to the
composite series, you need to add the name of the composite series at
the end.

{phang}{opt dtafile(filename)} specifies the {cmd:.dta} file to save and
may be used only with {cmd:satype(dta)}.  The default is
{cmd:dtafile(mydta.dta)}.

{phang}{opt mtaspc(filenames)} specifies the {cmd:.spc} files on which
to perform type III adjustment and may be used only with
{cmd:satype(mta)}.

{phang}{opt mtafile(filename)} specifies the {cmd:.mta} file to save and
may be used only with {cmd:satype(mta)}.  The default is
{cmd:mtafile(mymta.mta)}.

{phang}{opt compsa} specifies composite adjustment, that is, where
{varlist} is part of the composite series.  {cmd:compsa} may be used only
with {cmd:satype(single)}.

{phang}{opt compsadir} specifies direct seasonal adjustment for the
composite series and may be used only with {cmd:satype(mta)}.

{marker s_synprior}{dlgtab:Prior}

{phang}{opt transfunc(string)} specifies the transformation method and
can be one of {cmd:auto}, {cmd:log}, {cmd:sqrt}, {cmd:inverse}, or
{cmd:logistic}.  The default is {cmd:transfunc(auto)}, which specifies
to perform an Akaike's information criterion (AIC)-based selection to
decide between a log transformation and no transformation with the
specified regARIMA model.

{phang}{opt transpower(real)} specifies the power in the Box-Cox power
transformation.  The default is {cmd:transpower(1)}, which means no
transformation.  This option is ignored if {cmd:transfunc()} is also
specified.

{phang}{opt prioradj(string)} specifies the predefined prior-adjustment
variables.  {it:string} may be one of {cmd:lom} (length of month),
{cmd:loq} (length of quarter), or {cmd:lpyear} (leap-year effect).

{phang}{opt priorvar(string)} specifies the user-defined
prior-adjustment variables.  An example is 
{cmd:priorvar(sprb sprm spra)}.

{phang}{opt priormode(string)} specifies the way in which the
user-defined prior-adjustment factors will be applied to the time
series.  If prior-adjustment factors that are to be divided into the
series are not given as percentages (for example, 100 100 50 ...) but
rather as ratios (for example, 1.0 1.0 .5 ...), then set
{cmd:priormode(ratio)}.  If the prior adjustments are to be subtracted
from the original series, set {cmd:priormode(diff)}.  If
{cmd:priormode(diff)} is used when the mode of the seasonal adjustment
is set to {cmd:x11mode(mult)} or {cmd:x11mode(logadd)}, then the factors
are assumed to be on the log scale.  The factors will be exponentiated
to put them on the same basis as the original series.  If this argument
is not specified, then the prior-adjustment factors are assumed to be
percentages {cmd:priodmode(percent)}.

{phang}{opt priortype(string)} specifies whether the user-defined
prior-adjustment factors are permanent factors (removed from the final
seasonally adjusted series as well as the original series) or temporary
factors (removed from the original series for the purposes of generating
seasonal factors but not from the final seasonally adjusted series).  In
the current version, only one value is allowed.  An example is
{cmd:priortype(temporary)}.

{marker s_synreg}{dlgtab:Regression}

{phang}{opt regpre(string)} specifies the predefined variables.  Table
4.1 of the U.S. Census Bureau (2011) lists all the predefined variables.
An example is {cmd:regpre(td lpyear)}.

{phang}{opt regaic(string)} specifies that an AIC-based selection be
used to determine if a given set of regression variables will be
included with the regARIMA model specified.  The only entries allowed
for this variable are {cmd:td}, {cmd:tdnolpyear}, {cmd:tdstock},
{cmd:td1coef}, {cmd:td1nolpyear}, {cmd:easter}, and {cmd:user}.  If a
trading day model selection is specified, for example, then AIC values
(with a correction for the length of the series, henceforth referred to
as AICC) are derived for models with and without the specified trading
day variable.  By default, the model with smaller AICC is used to
generate forecasts, identify outliers, etc.  If more than one type of
regressor is specified, the AIC tests are performed sequentially in this
order: a) trading day regressors, b) Easter regressors, c) user-defined
regressors.  If there are several variables of the same type (for
example, several trading day regressors), then the AIC test procedure is
applied to them as a group.  That is, either all variables of this type
will be included in the final model or none will be included.  If this
option is not specified, no automatic AIC-based selection is performed,
and those insignificant variables will be dropped from the model.

{phang}{opt reguser(varlist)} specifies the user-defined variables.  It
must also cover the time frame of forecasts and backcasts specified in
the {cmd:ammaxback()} and {cmd:ammaxlead()} options.

{phang}{opt regusertype(string)} assigns a type of model-estimated
regression effect to each user-defined regression variable.  It causes
the variable and its estimated effects to be used and to be output in
the same way as a predefined regressor of the same type.  This option is
useful when trying out alternatives to the regression effects provided
by the program.  The type of the user-defined regression effects can be
defined as a constant ({cmd:constant}), seasonal ({cmd:seasonal}),
trading day ({cmd:td}), stock trading day ({cmd:tdstock}), length of
month ({cmd:lom}), length of quarter ({cmd:loq}), leap year
({cmd:lpyear}), holiday ({cmd:holiday}, {cmd:easter}, {cmd:thanks}, or
{cmd:labor}), outlier ({cmd:ao}, {cmd:ls}, or {cmd:tc}), or other
user-defined ({cmd:user}) regression effects.  If you specify only one
type, it applies to all variables.

{phang}{opt regusercent(string)} specifies the removal of the (sample)
mean or the seasonal means from the user-defined regression variables.
{cmd:regusercent(mean)} means that the mean of each user-defined
regressor is subtracted from the regressor.  {cmd:regusercent(seasonal)}
means that the mean for each calendar month (or quarter) is subtracted
from each of the user-defined regressors.  If this option is not
specified, the user-defined regressors are assumed to already be in an
appropriately centered form and are not modified.

{marker s_synout}{dlgtab:Outlier}

{phang}{opt outauto(string)} specifies the types of outliers to detect.
{it:string} can be one of {cmd:ao} (additive outliers), {cmd:ls} (level
shift outliers), {cmd:tc} (temporary change outliers), {cmd:all}
({cmd:ao}, {cmd:ls}, and {cmd:tc} outliers simultaneously), or
{cmd:none} (turn off outlier detection).  Examples are 
{cmd:outauto(ao ls)} and {cmd:outauto(all)}.

{phang}{opt outcrit(string)} sets the value to which the absolute values
of the outlier t statistics are compared to detect outliers.  The
default critical value is determined by the number of observations in
the interval searched for outliers.  The values are set for AO, LS, and
TC outliers sequentially; for example, {cmd:outcrit(3.0,4.5,4)} means
that the critical value for AO outliers is 3.0, the critical value for
LS outliers is 4.5, and the critical value for TC outliers is 4.  A
missing value, for example, {cmd:outcrit(3, ,4)}, means to use the
default values.  If only one value is specified, for example,
{cmd:outcrit(4)}, it applies to all types of outliers.

{phang}{opt outspan(string)} specifies the start and end dates of a span
of the time series to be searched for outliers.  The start and end dates
of the span must both lie within the series and within the model span
specified by the {cmd:amspan()} option.  The start date must precede the
end date, for example, {cmd:outspan(1998.jan, 2008.dec)}.  A missing
value, for example, {cmd:outspan(1976.jan, )}, defaults to the start
date or end date of the series, as appropriate.

{phang}{opt outlsrun(integer)} computes t statistics to test the null
hypotheses that each run of 2, . . . , {it:lsrun} successive LSs cancels
to form a temporary LS.  The t statistics are computed as the sum of the
estimated parameters for the LSs in each run divided by the appropriate
standard error.  Both automatically identified and user-defined LSs are
used in the tests.  The values should be from 0 to 5; 0 and 1 request no
computation of temporary LS t statistics.  If the value specified
exceeds the total number of LSs in the model following outlier
detection, then it is reset to this total.  The default is
{cmd:outlsrun(0)}, that is, no temporary LS t statistics are computed.

{phang}{opt outmethod(string)} specifies the method in which to detect
outliers.  {it:string} may be {cmd:addone} or {cmd:addall}.

{phang}{opt outao(string)} specifies the user-defined AO outliers, for
example, {cmd:outao(ao2003.5 ao1997.dec)}.

{phang}{opt outls(string)} specifies the user-defined LS outliers, for
example, {cmd:outls(ls2003.5 LS2007.nov)}.

{phang}{opt outtc(string)} specifies the user-defined TC outliers, for
example, {cmd:outtc(tc2003.5 TC2007.nov)}.

{marker s_synarima}{dlgtab:ARIMA}

{phang}{opt ammodel(string)} specifies the ARIMA model.  An example is
{cmd:ammodel((0,1,1)(0,1,1))}.

{phang}{opt ammaxlag(numlist)} specifies the maximum orders of the
regular and seasonal ARMA polynomials to be examined during the
automatic ARIMA model identification procedure.  {it:numlist} has two
input values: the maximum order of the regular ARMA model to be tested
and the maximum order of the seasonal ARMA model to be tested.  The
maximum order for the regular ARMA model must be greater than zero and
can be at most 4; the maximum order for the seasonal ARMA model can be
either 1 or 2.  The default is {cmd:ammaxlag(2 1)}.

{phang}{opt ammaxdiff(numlist)} specifies the maximum orders of the
regular and seasonal differencing for the automatic identification of
differencing orders.  {it:numlist} has two input values: the maximum
regular differencing order and the maximum seasonal differencing order.
Acceptable values for the maximum order of regular differencing are 1 or
2, and the acceptable value for the maximum order of seasonal
differencing is 1.  The default is {cmd:ammaxdiff(2 1)}.

{phang}{opt amfixdiff(numlist)} fixes the orders of differencing to be
used in the automatic ARIMA model identification procedure.  {it:numlist}
has two input values: the regular differencing order and the seasonal
differencing order.  Both values must be specified; there is no default
value.  Acceptable values for the regular differencing order are 0, 1,
and 2; acceptable values for the seasonal differencing order are 0 and
1.  An example is {cmd:amfixdiff(1 1)}.  If {cmd:ammaxdiff()} is
specified, then the {cmd:amfixdiff()} option is ignored.

{phang}{opt amfile(filename)} specifies the file that stores the ARIMA
models to estimate.

{phang}{opt ammaxlead(integer)} specifies the number of forecasts
produced.  The default is {cmd:ammaxlead(12)} and the maximum is 60.

{phang}{opt ammaxback(integer)} specifies the number of backcasts
produced.  The default is {cmd:ammaxback(0)} and the maximum is 60.

{phang}{opt amlevel(real)} specifies the confidence interval for the
forecast (backcast) of the regARIMA model.  The default is
{cmd:amlevel(95)}.

{phang}{opt amspan(string)} specifies the sample of the regARIMA model.
For example, this could be {cmd:amspan(1990.1, 2009.dec)} (the sample
spans from January 1990 to December 2009), {cmd:amspan(, 2009.12)} (the
sample spans from the first observation of the data to December 2009),
or {cmd:amspan(1990.jan, )} the sample spans from January 1990 to the
last observation of the data).  For some time series that have irregular
variation in the first or last part, this option will be appropriate.

{marker s_synx11}{dlgtab:Adjustment}

{phang}{opt x11mode(string)} specifies the mode of X-11 seasonal
adjustment.  {it:string} may be one of {cmd:add}, {cmd:mult},
{cmd:logadd}, or {cmd:pseudoadd}.  {cmd:x11mode()} determines how the
adjusted series is decomposed into three basic components:  trend cycle,
seasonal, and irregular.  The default is {cmd:x11mode(mult)} unless the
automatic transformation selection procedure ({cmd:transfunc(auto)}) is
invoked, in which case the mode will match the transformation selected
for the series ({cmd:mult} for the log transformation and {cmd:add} for
no transformation).

{phang}{opt x11trend(string)} specifies the trend filter.  Any odd
number greater than 1 and less than or equal to 101 may be specified.
If no selection is made, the program will select a trend moving average
based on statistical characteristics of the data.  For monthly series,
either a 9-, 13-, or 23-term Henderson moving average will be selected.
For quarterly series, the program will choose either a 5- or 7-term
Henderson moving average.

{phang}{opt x11seas(string)} specifies the seasonal filter.  Table 7.43
of U.S. Census Bureau (2011) lists the available seasonal filters.  An
example is {cmd:x11seas(s3x5)}.  If no selection is made, then
X-12-ARIMA will select a seasonal filter automatically.

{phang}{opt x11final(string)} excludes the outliers from the seasonally
adjusted series.  An example is {cmd:x11final(ao ls)}.  By default, the
final seasonally adjusted series will contain the effects of outliers
and user-defined regressors.

{phang}{opt x11hol} keeps the holiday effect in the seasonally adjusted
series.  A series is adjusted for both seasonal and holiday effects by
default.

{phang}{opt x11sig(string)} specifies the lower and upper sigma limits
used to downweight extreme irregular values in the internal
seasonal-adjustment iterations.  An example is {cmd:sasig(1.5, 2.5)}.

{marker s_synstab}{dlgtab:Others} 

{phang}{opt history} generates revisions between the initial estimate
and the most recent estimate for several quantities derived from
seasonally adjusting a time series.  X-12-ARIMA can also generate
historical out-of-sample forecast errors and likelihood statistics
derived from regARIMA model estimation.

{phang}{opt sliding} specifies a sliding span analysis.  These analyses
compare different features of seasonal-adjustment output by overlapping
subspans of the time series data.

{phang}{opt justspc} specifies to show the created {cmd:.spc} file but
to not perform seasonal adjustment.

{phang}{opt noview} specifies to not show the seasonally adjusted result
file ({cmd:.out} file) nor the specification file ({cmd:.spc},
{cmd:.dta}, or {cmd:.mta} file).

{phang}{opt dsa} specifies to perform seasonal adjustment based on
already created {cmd:.spc}, {cmd:.dta}, or {cmd:.mta} files.  Only one
category of files may be specified at once.

{phang}{opt dsaspc(filename)} specifies the {cmd:.spc} file and may be
used only with {cmd:satype(single)}.

{phang}{opt dsadtaspc(filename)} specifies the {cmd:.spc} file and may
be used only with {cmd:satype(dta)}.

{phang}{opt dsadta(filename)} specifies the {cmd:.dta} file and may be
used only with {cmd:satype(dta)}.

{phang}{opt dsamta(filename)} specifies the {cmd:.mta} file and may be
used only with {cmd:satype(mta)}.{p_end}
{right: {help sax12##s_head:Return to Contents}}


{marker s_outline}{title:Introduction of X-12-ARIMA}

{pstd}The X-12-ARIMA seasonal-adjustment program is an enhanced version
of the X-11 variant of the Census Method II (Shiskin, Young, and
Musgrave 1967).  We outline the framework of X-12-ARIMA in this section.
A more detailed explanation can be found in U.S. Census Bureau (2011).
X-12-ARIMA includes two modules: regARIMA (linear regression model with
ARIMA time series errors) and X-11.  Three stages are needed to complete
the seasonal adjustment: model building, seasonal adjustment, and
diagnostic checking.

{marker s_types}{dlgtab:Types of seasonal adjustment}

{phang}{bind:(1) Type I} is adjustment for a single series based on a
single input file that specifies the entire adjustment process and has
the extension {cmd:.spc}.{p_end}

{phang}{bind:(2) Type II} is adjustment for a multiseries based on the
same specification.  Type II adjustment needs one data metafile with the
extension {cmd:.dta} and one input file.  Note that though the data
metafile has the same extension as a Stata data file, they have
completely different formats.  The data metafile stores the path and
filename of the time series.{p_end}

{phang}{bind:(3) Type III} is adjustment for a multiseries based on
different specifications.  Type III adjustment needs one input metafile
with the extension {cmd:.mta}.  This metafile stores the path and
filename of the input file for each time series.{p_end}

{pstd}If an aggregate time series is a sum (or other composite) of
component series that are seasonally adjusted, then the sum of the
adjusted component series provides a seasonal adjustment of the
aggregate series that is called the indirect adjustment.  This
adjustment is usually different from the direct adjustment that is
obtained by applying the seasonal adjustment program to the aggregate
(or composite) series.  The indirect adjustment is usually appropriate
when the component series have very different seasonal patterns.  If you
make a composite adjustment, you must specify the {cmd:compsa} option in
the {cmd:.spc} file of each series.

{pstd}Example 1: Adjustment for a single series y; save the {cmd:.spc}
file as {cmd:y.spc} and output files as {cmd:y.*}{break}
{cmd:. satype(single)} {break}
or{break}
{cmd:. satype(single) inpref(y) outpref(y)}

{pstd}Example 2: Adjustment for a single series y; save the {cmd:.spc}
file as {cmd:y2.spc} and output files as {cmd:y2.*}{break}
{cmd:. satype(single) inpref(y2) outpref(y2)} 

{pstd}Example 3: Adjustment for series y x; save the {cmd:.spc} files as
{cmd:y.spc} and {cmd:x.spc}, and the output files as {cmd:y.*} and
{cmd:x.*}{break}
{cmd:. satype(dta)} or {cmd:satype(dta) inpref(y x) outpref(y x)}

{pstd}Example 4: Adjustment for series y x; save the {cmd:.spc} files as
{cmd:y2.spc} and {cmd:x2.spc}, and the output files as {cmd:y2.*} and
{cmd:x2.*}{break}
{cmd:. satype(dta) inpref(y2 x2) outpref(y2 x2)}

{pstd}Example 5: Adjustment based on {cmd:.spc} files {cmd:y.spc} and
{cmd:x.spc}; save {cmd:.mta} file as {cmd:yx.mta} and output files as
{cmd:y.*} and {cmd:x.*}{break}
{cmd:. satype(mta) mtaspc(y x) mtafile(yx)} or {cmd:satype(mta) mtaspc(y x) mtafile(yx) outpref(y x)}{p_end}

{pstd}Example 6: Adjustment for series y x; save the {cmd:.spc} files as
{cmd:y2.spc} and {cmd:x2.spc}, and the output files as {cmd:y2.*} and
{cmd:x2.*}{break}
{cmd:. satype(mta) mtaspc(y x) mtafile(yx) outpref(y2 x2)}{p_end}
{right: {help sax12##s_head:Return to Contents}}

{marker s_reg}{dlgtab:Regression effect}

{pstd}In the first stage, regARIMA performs a prior adjustment for
various effects (such as trading day effects, seasonal effects, moving
holiday effects, and outliers) and forecasts or backcasts the time
series.  The general regARIMA model can be written as

{space 10}Phi(B)Phi(B^s)(1-B)^d(1-B^s)^D(y - beta*x) = theta(B)Theta(B^s)u{break}
{space 10}phi(B) = 1-phi(1) B - ... - phi(p) B^p {break}
{space 10}Phi(B^s) = 1- Phi(1) B^s - ... - Phi(P) B^(Ps) {break}
{space 10}theta(B) = 1-theta(1) B - ... - theta(q) B^q {break}
{space 10}Theta(B^s) = 1- Theta(1) B^s - ... - Theta_Q B^(Qs) {break}

{pstd}where B is the backshift operator, s is the seasonal period,
phi(B) is the nonseasonal autoregressive operator, Phi(B) is the
seasonal autoregressive operator, theta(B) is the nonseasonal
moving-average operator, Theta(B) is the seasonal moving-average
operator, d is the nonseasonal differencing order, and D is the seasonal
differencing order.  y is the original series or its prior-adjusted
series, or some type of transformation, including log, square root,
inverse, logistic, and Box-Cox power transformations.  See 
{it:{help sax12##s_trans:Transformation and prior adjustment}}.

{pstd}x are regression variables.  x include the predefined variables
(such as a trading day effects), the automatically added variables (such
as outliers), and the user-defined variables.  So in the regARIMA model,
the trading day, holiday, outlier, and other regression effects can be
fit and used to adjust the original series prior to seasonal adjustment.
The predefined variables are specified in the same way as those in table
4.1 of U.S. Census Bureau (2011).  For example, the length of month and
seasonal dummy variables can be specified as {cmd:regpre(lom seasonal)}.
The user-defined variables are assumed to be of type {cmd:user} and
already centered.  Of course, you can change these options.  For
example, we add two holiday variables ({cmd:mb} and {cmd:ma}) in the
regression model.  We can specify these as 
{cmd:reguser(mb ma) regusertype(holiday holiday)}.{p_end}
{right: {help sax12##s_head:Return to Contents}}

{marker s_outlier}{dlgtab:Outliers}

{pstd}X-12-ARIMA allows three types of outliers: additive outliers
(AOs), temporary change outliers (TCs), and level shifts (LSs).  You can
specify the outliers by hand or let the program automatically detect the
outliers.  You can specify outliers with {cmd:outao()}, {cmd:outls()},
and {cmd:outtc()}.  For example, you could type 
{cmd:outao(ao2003.may 2008.10) outls(LS1997.6 ls2008.6) outtc(tc2001.9)}.

{pstd}The automatic detection can be performed with the {cmd:outauto()}
option, for example, {cmd:outauto(ao ls)} or {cmd:outauto(ao ls tc)}.
X-12-ARIMA has an automatic model-selection procedure based largely on
the automatic model selection of TRAMO (Gomez and Maravall 2000).  In
brief, this approach involves computing t statistics for the
significance of each outlier type at each time point, searching through
these t statistics for significant outliers, and adding the
corresponding AO, LS, or TC regression variables to the model.
X-12-ARIMA provides two variations on this general theme.  The
{cmd:addone} method provides full-model reestimation after each single
outlier is added to the model, while the {cmd:addall} method reestimates
the model only after a set of detected outliers is added to the model.
The method can be chosen by including the {cmd:outmethod(addone)} or
{cmd:outmethod(addall)} option.

{pstd}During outlier detection, a robust estimate of the residual
standard deviation -- 1.48 times the median absolute deviation of the
residuals -- is used .  The default critical value is determined by the
number of observations in the interval searched for outliers.  You set
the critical values with {cmd:outcrit()}, and the values are set for AO,
LS, and TC outliers sequentially.  For example, {cmd:outcrit(3.5,4,4)}
means that the critical value for AO is 3.5, for LS is 4, and for TC is
4.  {cmd:outcrit(4,,4.5)} means that the critical value for AO is 4, for
LS is determined by the program, and for TC is 4.5.  {cmd:outcrit(4)}
means that the critical values for AO, LS, and TC are all set to 4.

{pstd}When a model contains two or more LSs, including those obtained
from outlier detection as well as any LSs specified in the regression
specification, X-12-ARIMA will optionally produce t statistics for
testing null hypotheses that each run of two, three, ...  successive LSs
actually cancels to form a temporary LS.  Two successive LSs cancel to
form a temporary LS if the effect of one offsets the effect of the
other, which implies that the sum of the two corresponding regression
parameters is zero.  Similarly, three successive LSs cancel to a
temporary LS if the sum of their three regression parameters is zero,
and so on.  This is specified using {cmd:outlsrun(}{it:integer}{cmd:)}.
The number must lie between 0 and 5, for example, {cmd:outlsrun(2)}.

{pstd}You can restrict the detection to within a specific sample by
using {cmd:outspan()}.  The start and end dates of the span must both
lie within the series and within the model span (specified by
{cmd:amspan()}).  A missing value defaults to the start date or end date
of the series, as appropriate.  Here are some examples:
{cmd:outspan(1992.1,2007.12)}, {cmd:outspan(,2007.12)}, and
{cmd:outspan(1992.1,)}.{p_end}
{right: {help sax12##s_head:Return to Contents}}

{marker s_arima}{dlgtab:ARIMA error}

{pstd}X-12-ARIMA provides capabilities of identification, estimation,
and diagnostic checking.  Identification of the ARIMA model for the
regression errors is based on sample autocorrelation and partial
autocorrelation.

{pstd} You can specify the ARIMA model by hand, for example,
{cmd:ammodel((0,1,1)(0,1,1))}.  You can also let the program
automatically select the optimal model from among a set of models.
X-12-ARIMA has an automatic model-selection procedure based largely on
the automatic model selection of TRAMO.  X-12-ARIMA will select the
optimal model given the maximum difference order and ARMA order or given
only the maximum ARMA order at a fixed difference order.  Here are two
examples:  {cmd:ammaxdiff(2 1) ammaxlag(3 1)} and 
{cmd:amfixdiff(2 1) ammaxlag(3 1)}.

{pstd}You can also let X-12-ARIMA automatically select the optimal ARIMA
model from among a set of models stored in one file, for example,
{cmd:amfile(mymodels.mdl)}.

{pstd}Once a regARIMA model has been specified, X-12-ARIMA will
estimate its parameters by maximum likelihood with an iterated
generalized least-squares algorithm.  Diagnostic checking involves the
examination of residuals from the fitted model for signs of model
inadequacy, including outlier detection, normality testing, and
Ljung-Box Q testing.{p_end}
{right: {help sax12##s_head:Return to Contents}}

{marker s_trans}{dlgtab:Transformation and prior adjustment}

{pstd}The dependent variable in a regARIMA model is the original series
or it is some type of transformation, including log, square root,
inverse, logistic, and Box-Cox power transformations, which are listed
in table 7.36 of U.S. Census Bureau (2011, 175).

{pstd}A predefined prior adjustment includes the length of month (or
quarter) and a leap year effect.  Length of month (or quarter)
adjustment means that each observation of a monthly series is divided by
the corresponding length of month (or length of quarter for quarterly
series) and is then rescaled by the average length of month (or
quarter).  Here are two examples: {cmd:prioradj(lom)} and
{cmd:prioradj(lpyear)}.

{pstd}You can define your own prior-adjustment variables for division
into or subtraction from the original time series.  Here are two
examples: {cmd:priortype(diff)} or {cmd:priortype(ratio)}.

{pstd}You can also specify whether the prior-adjustment factors
are permanent (removed from both the original series and the seasonally
adjusted series) or temporary (removed from the original series but not
from the seasonally adjusted series) by using {cmd:priortype(permanent)} or
{cmd:priortype(temporary)}.{p_end}
{right: {help sax12##s_head:Return to Contents}}

{marker s_x11}{dlgtab:X-11 seasonal adjustment}

{pstd}The original series is adjusted using the trading day, holiday,
outlier, and other regression effects derived from the regression
coefficients.  Then the adjusted series O is decomposed into three basic
components: trend cycle (C), seasonal (S), and irregular (I).
X-12-ARIMA provides four different decomposition modes: multiplicative
({cmd:x11mode(mult)}), additive ({cmd:x11mode(add)}), pseudo-additive
({cmd:x11mode(pseudoadd)}), and log-additive ({cmd:x11mode(logadd)}).

{pstd}X-12-ARIMA uses a seasonal moving average (filter) to estimate the
seasonal factor.  Table 7.43 of U.S. Census Bureau (2011) lists the
seasonal filters.  Here is an example: {cmd:x11seas(s3x5)}.  If no
selection is made, then X-12-ARIMA will select a seasonal filter
automatically.

{pstd}The Henderson moving average is used to estimate the final trend
cycle.  Any odd number greater than 1 and less than or equal to 101 may
be specified, or example, {cmd:x11trend(23)}.  If no selection is made,
the program will select a trend moving average based on statistical
characteristics of the data.  For monthly series, either a 9-, 13-, or
23-term Henderson moving average will be selected.  For quarterly
series, the program will choose either a 5- or 7-term Henderson moving
average.

{pstd}A series is adjusted for both seasonal and holiday effects by
default.  The holiday-adjustment factors derived from the program can be
kept in the final seasonally adjusted series by using the {cmd:sahol}
option.

{pstd}The effects of outliers and user-defined regressors can be removed
using the {cmd:x11final()} option, for example, {cmd:x11final(tc user)}.

{pstd}The lower and upper sigma limits used to downweight extreme
irregular values in the internal seasonal-adjustment iterations are
specified using the {cmd:sasig()} option, for example,
{cmd:sasig(1.5,2.5)}.{p_end}
{right: {help sax12##s_head:Return to Contents}}

{marker s_stab}{dlgtab:Stability analysis}

{pstd}X-12-ARIMA contains several diagnostics for modeling, model
selection, and adjustment stability.  Spectral plots of the original
series, the regARIMA residuals, the final seasonal adjustment, and the
final irregular component help you check whether seasonal or trading day
variation still remains.

{pstd}The sliding spans analysis and history revision analysis are two
important stability diagnostics.  The sliding spans diagnostics compare
seasonal adjustment from overlapping spans of given series.  This
analysis is requested with the {cmd:sliding} option.

{pstd}The revision history diagnostics compare the concurrent and final
adjustment.  These diagnostics are requested with the {cmd:history}
option.{p_end}
{right: {help sax12##s_head:Return to Contents}}


{marker s_examples}{title:Examples}

    {title:Example 1: Seasonal adjustment for a single series}

{phang}{cmd:. cd d:\sam}{p_end}
{phang}{cmd:. use retail, clear}{p_end}
{phang}{cmd:. tsset}{p_end}
{phang}{cmd:. des}{p_end}
{phang}{cmd:. tsline retail}{p_end}

{phang}{cmd:. sax12 retail, satype(single) transfunc(auto) regpre(const td) reguser(sprb sprm spra) regusertype(holiday) outao(ao2003.5) outauto(ao ls tc) outlsrun(0) ammaxlag(3 1) ammaxdiff(2 1) ammaxlead(12) x11seas(x11default) sliding history}

{phang}{cmd:. sax12im "retail.out", ext(d10)}

{phang}{cmd:. sax12im "retail.out", ext(sp2) noftvar}

{phang}{cmd:. gen year = year(dofm(mdate))}{p_end}
{phang}{cmd:. gen month = month(dofm(mdate))}{p_end}
{phang}{cmd:. cycleplot retail_d10 month year, summary(mean) lpattern(dash) xtitle("")}

{phang}{cmd:. _matplot retail_sp2, columns(3,2) xline(0.348 0.432, lpattern(dash) lcolor(brown) lwidth(thick))} {cmd:xline(0.08333 0.16667 0.25 0.33333 0.41667 0.5, lpattern(dash)} {cmd:lcolor(red) lwidth(medium)) connect(direct)} 
{cmd:msize(small)} {cmd:mlabp(0)} {cmd:mlabs(zero) ysize(3) xsize(5) ytitle("Density") xtitle("Frequency")}

    {title:Example 2: Seasonal adjustment for a multiseries}

{phang}{cmd:. cd d:\saq}{p_end}
{phang}{cmd:. use gdpcn, clear}{p_end}
{phang}{cmd:. tsset}{p_end}
{phang}{cmd:. foreach v of varlist agri - other {c -(}}{p_end}
{phang}{cmd:. sax12 `v', satype(single) comptype(add) transfunc(auto) regpre(const) outauto(ao ls) outlsrun(2) ammaxlag(2 1) ammaxdiff(1 1) ammaxlead(12) x11seas(x11default) sliding history justspc noview}{p_end}
{phang}{cmd:. {c )-}}{p_end}

{phang}{cmd:. sax12, satype(mta) mtaspc("agri const finance house indus other retail service trans")} {cmd:mtafile(gdp.mta) compsa inpref(gdp.spc)} {cmd:compsadir transfunc(log)} {cmd:regpre(const lpyear) outauto(ao ls) outlsrun(0)} 
{cmd:x11mode(mult) x11seas(x11default) sliding history}{p_end}

{phang}{cmd:. sax12diag gdp.udg using mydiag.txt}

{phang}{cmd:. sax12im gdp, ext(d10 d11 d12 d13 isf isa itn iir)}

{phang}{cmd:. foreach f in "agri const finance house indus other retail service trans gdp" {c -(}}{p_end}
{phang}{cmd:.	sax12del `f', keep(d10 d11 d12 d13 spc)}{p_end}
{phang}{cmd:. {c )-}}{p_end}
{phang}{cmd:. dir gdp.*}{p_end}


{marker s_saved}{title:Saved results}

{synoptset 14 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(spcfile)}}names of {cmd:.spc} files{p_end}
{synopt:{cmd:r(dtafile)}}names of {cmd:.dta} files (only for type II
adjustment){p_end}
{synopt:{cmd:r(mtafile)}}names of {cmd:.mta} files (only for type III
adjustment){p_end}


{marker s_reference}{title:References}

{phang}Shiskin, J., A. H. Young, and J. C. Musgrave.  1967.  The X-11
variant of the Census Method II seasonal adjustment program.  Technical Paper
15, U.S. Department of Commerce, Bureau of the Census.

{phang}U.S. Census Bureau.  2011.  {it:X-12-ARIMA Reference Manual (Version 0.3)}.
{browse "http://www.census.gov/ts/x12a/v03/x12adocV03.pdf":http://www.census.gov/ts/x12a/v03/x12adocV03.pdf}.


{marker s_official}{title:Official website of X-12-ARIMA}

{pstd} {browse "http://www.census.gov/srd/www/x12a/":http://www.census.gov/srd/www/x12a/}


{marker s_author}{title:Author}

{pstd}Qunyong Wang{p_end}
{pstd}Institute of Statistics and Econometrics{p_end}
{pstd}Nankai University{p_end}
{pstd}brynewqy@nankai.edu.cn{p_end}


{title:Also see}

{p 4 14 2}Article:  {it:Stata Journal}, volume 12, number 2: {browse "http://www.stata-journal.com/article.html?article=st0255":st0255}

{p 7 14 2}Help:  {helpb sax12diag}, {helpb sax12im}, {helpb sax12del}
(if installed){p_end}
