{smcl}
{* 29mar2016/01apr2017/04apr2017/13apr2017}{...}
{cmd:help rangestat}
{hline}

{title:Title}

{phang}
{cmd:rangestat} {hline 2} Generate statistics using observations within range


{title:Syntax}

{p 8 17 2}
{cmd:rangestat} 
{it:slist} 
{ifin} 
{cmd:,} 
{opt i:nterval(keyvar low high)}
[
{it:{help rangestat##table_options:options}}
]

{pstd}
where {it:slist} is composed of one or more of the following

{p 8 17 2}
{opt (stat)}
{ {varlist} | {it:new_varname}{cmd:=}{varname} } [ { {varlist} | {it:new_varname}{cmd:=}{varname} } ...]

{p 8 17 2}
{opt (flex_stat)}
{varlist}

{pstd}
and {it:stat} is one of

{p2colset 9 22 24 2}{...}
{* 11apr2017 added skew, kurt; some new names; rearranged NJC}{...}
{p2col :{opt obs}}number of raw observations{p_end}
{p2col :{opt count}}number of non-missing observations{p_end}
{p2col :{opt missing}}number of missing observations{p_end}

{p2col :{opt mean}}{p_end}
{p2col :{opt sum}}{p_end}
{p2col :{opt sd}}standard deviation{p_end}
{p2col :{opt variance}}{p_end}
{p2col :{opt skewness}}see Cox (2010) for implementation details{p_end}
{p2col :{opt kurtosis}}see Cox (2010) for implementation details{p_end}

{p2col :{opt min}}minimum{p_end}
{p2col :{opt median}}{p_end}
{p2col :{opt max}}maximum{p_end}

{p2col :{opt first}}first value{p_end}
{p2col :{opt last}}last value{p_end}
{p2col :{opt firstnm}}first non-missing value{p_end}
{p2col :{opt lastnm}}last non-missing value{p_end}
{p2colreset}{...}

{pstd}
and {it:flex_stat} is one of

{p2colset 9 22 24 2}{...}
{p2col :{opt corr}}correlation, first and second variables{p_end}
{p2col :{opt cov}}covariance, first and second variables{p_end}
{p2col :{opt reg}}ordinary least squares regression with a constant{p_end}
{p2colreset}{...}

{pstd}
or the name of a user-supplied Mata function. 

{pstd}
If {it:slist} does not start with a {opt (stat)} or {opt (flex_stat)},
{it:slist} is prefixed by {cmd:(mean)}.

{synoptset 27 tabbed}{...}
{marker table_options}{...}
{synopthdr}
{synoptline}
{p2coldent :* {opt i:nterval(keyvar low high)}}use observations where {it:keyvar}
is within the bounds indicated by {it:low} and {it:high}
{p_end}
{synopt :{opth by(varlist)}}the set of observations to use is found within {it:by} group
{p_end}
{synopt :{opt excl:udeself}}set the input variables to missing for the current observation
{p_end}
{synopt :{opt casew:ise}}casewise deletion of observations within variable groups
{p_end}
{synopt :{opt d:escribe}}runs {help describe} to show the names of the new 
variables created
{p_end}
{synopt :{opt local(name)}}define a local macro {it:name} that contains the names of the variables created
{p_end}
{synoptline}
{phang}* {opt i:nterval(keyvar low high)} is required. 
{it:keyvar} is a numeric variable.
The lower and upper bound of the closed interval to use 
for each observation can be
specified using a numeric variable, a {it:#}, or a {help missing:system missing value}.
If a {it:#} is used, the bound for each observation is computed by adding {it:#} to {it:keyvar}.
If {it:low} is specified using a {help missing:system missing value}, {it:low} is set to 
missing for all observations. 
{cmd:rangestat} applies the same rules as {help inrange()} for missing bounds.
{p2colreset}{...}


{title:Description}

{pstd}
You can find various general and specific comments on
problems that require calculating statistics
based on other observations in Cox (2007, 2011, 2014). 
Typically, these types of problems require some
form of looping since the desired result is based on a set
of observations that may differ from the set used for the
previous or next observation.
{cmd:rangestat} offers a general solution to such problems
as long as the set of observations to use can be 
expressed using a range of {it:keyvar} values.

{pstd}
{cmd:rangestat} can do calculations based on a 
{it:{help rangestat##degenerate_interval:degenerate interval}} 
(where {bind:{it:low == high}}),
a {it:{help rangestat##rolling_window:rolling window}}, 
a {it:{help rangestat##recursive_window:recursive window}} 
(where the first period is fixed),
a {it:{help rangestat##reversed_recursive_window:reversed recursive window}} 
(where the last period is fixed),
or with 
{it:{help rangestat##observation_specific_windows:observation-specific windows}}, 
each independently specified using
interval bound variables.

{pstd}
{it:keyvar} can be any
numeric variable and may contain duplicates. 
If {it:keyvar} is a time variable, {cmd:tsset} or {cmd:xtset} settings are ignored.
When {it:keyvar} is missing, the observation is excluded from the sample 
(its results are set to missing and the observation is not used
to calculate statistics for other observations).

{pstd}
Variables (which should be numeric) are grouped and processed together for each {opt (stat)} or
{opt (flex_stat)} part of {it:slist}.  A new {opt (stat)} or 
{opt (flex_stat)} resets the list and starts a new variable group. 
Within a {opt (stat)} variable group, the statistic is calculated by variable,
ignoring missing values in other variables in the group.
You can use the {opt casew:ise} option to indicate
that a missing value in any variable in the group will exclude
the observation.
With a {opt (flex_stat)} variable group, all built-in functions
implement casewise deletion so there is no need to specify
the {opt casew:ise} option for them. 
If you provide your own Mata function, you need to specify
the {opt casew:ise} option if you want {cmd:rangestat}
to pass a matrix with no missing values.

{pstd}
With {opt (stat)} variable groups, {cmd:rangestat} creates one variable per
input variable to store the computed statistic.  If the form
{bind:{it:new_varname=varname}} was used in {it:slist}, the new variable
will be named using {it:new_varname}. Otherwise, the variable name will
be created by appending "_{it:stat}" to the name of the input variable.
A built-in {opt (flex_stat)} statistic creates variables using rules specific to
the function called. 
If {opt (flex_stat)} is an external Mata function, 
variables created to store the results are named 
using a combination of {it:flex_stat} and a sequence number. 

{pstd}
For convenience, {cmd:rangestat} checks for intervals with the
exact same bounds. In such cases, the results would be exactly the
same for repeats within the same bounds so calculations are done
only once per interval bound group and results are filled in for
repeats. Note that this does not apply if the {opt excl:udeself} option
is specified.


{marker options}{...}
{title:Options}

{dlgtab:Options}

{phang}{opt i:nterval(keyvar low high)} is required and defines the interval 
that selects the set of observations to use to calculate result for the 
current observation.
{it:keyvar} is a numeric variable.
Observations whose values for {it:keyvar} fall within the 
closed interval bounds are selected.
{it:low} and {it:high} can each be
specified using a numeric variable, a {it:#} (a number in Stata parlance), or a {help missing:system missing value}.
If a {it:#} is used, the bound for each observation is computed by adding {it:#} to {it:keyvar}.
If {it:low} is specified using a {help missing:system missing value}, {it:low} is set to missing
for all observations. 
{cmd:rangestat} applies the same rules as {help inrange()} for missing bounds:
if the lower bound is missing, observations will match up to and including
the value of {it:high}.
If both {it:low} and {it:high} are missing, all observations will match.
Note that the treatment of missing values for {it:low} and {it:high}
differs in version 1.1 up from the previous version of {cmd:rangestat} and
this may require that previous code be adapted. (Use {help which} to find out which version you are running if you do not know.) 

{phang}{opth by(varlist)} groups observations, so that statistics are
generated using only observations within the same group. For example, 
this option should be specified when you wish calculations to be 
restricted to given panels or given times for panel or longitudinal 
data. 

{phang}{opt excl:udeself} specifies that the input variables are set to
missing for the current observation for the purpose of calculating the
statistic. Note that the observation is still included if {it:keyvar} is
within range: this affects statistics that count observations. If you
really want to ignore the observation, use the {opt case:wise}
option. 

{phang}{opt casew:ise} specifies casewise deletion of observations within
variable groups. A variable group is the set of input variables
that follows a {opt (stat)} or {opt (flex_stat)} in {it:slist}.
The {cmd:(corr)}, {cmd:(cov)}, and {cmd:(reg)} {it:flex_stat} functions
implement casewise deletion so you do not have to specify this
option when using them.

{phang}{opt d:escribe} runs {help describe} to show the names of the new 
variables created. Each new variable is labelled to indicate its source.

{phang}{opt local(name)} specifies the name of a local macro
that {cmd:rangestat} will 
populate with the names of the variables it creates. The macro is
created within the scope of the calling do-file or program.


{title:Setting the interval}

{pstd}
In most cases, you will want to define interval bounds in relation
to the observation's current value for {it:keyvar}.
You can do that by specifying each bound using {it:#} (a number in Stata parlance).
The {it:#} is added to {it:keyvar} to set the bound.
{cmd:rangestat} uses a closed interval, which means that values
that match the bound are included.


{marker degenerate_interval}{...}
{pstd}
{ul:A degenerate interval:}

{pstd}
The simplest case is to calculate statistics using observations
with the same {it:keyvar} value. 
This requires that lower and upper bounds be the same as
the value of {it:keyvar}, so you specify {it:low} and {it:high}
using 0.
The example below calculates the mean and standard deviation of
the variables {cmd:price mpg} using observations with the same
value for {cmd:rep78}. 
The example is a bit silly because you can do
the same thing using {cmd:egen} functions:

{space 8}{hline 27} {it:example do-file content} {hline 27}
{cmd}{...}
{* example_start - interval_0_0}{...}
	sysuse auto, clear
	rangestat (min) price mpg (mean) price mpg, interval(rep78 0 0)
	
	* redo using egen functions
	sort rep78 make
	by rep78: egen min_price = min(price)
	by rep78: egen min_mpg   = min(mpg)
	by rep78: egen mean_price = mean(price)
	by rep78: egen mean_mpg   = mean(mpg)
	list rep78 *price* *mpg* if rep78 <= 2, sepby(rep78)
{* example_end}{...}
{txt}{...}
{space 8}{hline 80}
{space 8}{it:({stata rangestat_run interval_0_0 using rangestat.sthlp:click to run})}

{pstd}
Note that there is one important difference between the {cmd:rangestat}
results above and those computed using {cmd:egen} functions: a missing value
for {it:keyvar} (in this case {hi:rep78}) excludes the observation
from the sample and thus no results are computed.


{marker rolling_window}{...}
{pstd}
{ul:Rolling window interval:}

{pstd}
With {cmd:rangestat}, you can easily perform calculations on a rolling window. 
The following
example uses a window of 5 years that includes the current observation.
By specifying {bind:{cmd:interval(year -4 0)}}, the interval for an
observation in 1950 for example will amount to [1950-4, 1950] and evaluate to [1946, 1950].
Since this is panel data, we use the {cmd:by(company)} option
to restrict calculations to observations within the same company group. 

{space 8}{hline 27} {it:example do-file content} {hline 27}
{cmd}{...}
{* example_start - interval_rw}{...}
	webuse grunfeld, clear
	 
	* include some missing values and omit some random observations
	set seed 1234
	replace invest = . if uniform() < .1
	drop if uniform() < .1
	 
	rangestat (mean) invest (sd) invest (count) invest, ///
		interval(year -4 0) by(company)
{* example_end}{...}
{txt}{...}
{space 8}{hline 80}
{space 8}{it:({stata rangestat_run interval_rw using rangestat.sthlp:click to run})}

{pstd}
As with all rolling window problems, results may not be based on
the full window, in this example 5 years of observations. 
This will be true for the first 4 observations
of each panel in the example and for subsequent observations if there are missing
values or missing data years. You should always use the {cmd:(count)}
statistic to get the number of non-missing values and
use the count to reject results based on an insufficient sample size.


{marker recursive_window}{...}
{pstd}
{ul:Recursive window interval:}

{pstd}
You can also perform calculations on a recursive window
where the first period is fixed. 
The following example specifies {it:low} using a
{help missing:system missing value} and {it:high} using 0.
When a {help missing:system missing value} is used for the lower bound, 
{cmd:rangestat} assumes that you want the largest negative number
possible for all observations. Hence, for example, the bounds for an 
observation in 1950 will be [{cmd:c(mindouble)},1950].

{space 8}{hline 27} {it:example do-file content} {hline 27}
{cmd}{...}
{* example_start - interval_rec}{...}
	webuse grunfeld, clear
	 
	rangestat (sum) invest mvalue kstock, interval(year . 0) by(company)
	
	* the above is the same as performing a running sum
	by company (year): gen double rs_invest = sum(invest)
	by company (year): gen double rs_mvalue = sum(mvalue)
	by company (year): gen double rs_kstock = sum(kstock)
{* example_end}{...}
{txt}{...}
{space 8}{hline 80}
{space 8}{it:({stata rangestat_run interval_rec using rangestat.sthlp:click to run})}


{marker reversed_recursive_window}{...}
{pstd}
{ul:Reversed recursive window:}

{pstd}
Similarly, you can perform calculations on a reversed recursive window
where the last period is fixed. 
The following example specifies {it:low} using 0
and {it:high} using a {help missing:system missing value}.
In Stata, a {help missing:system missing value} is a value that
is higher than any non-missing value that can be stored.
So the bounds for an observation in 1950 for example will be {bind:[1950,.]}
and results will be calculated using all observations where {bind:year >= 1950}.

{space 8}{hline 27} {it:example do-file content} {hline 27}
{cmd}{...}
{* example_start - interval_rev}{...}
	webuse grunfeld, clear
	 
	rangestat (sum) invest, interval(year 0 .) by(company)
	
	* this above is the same as removing a running sum from the overall total
	by company (year): egen double invest_total = total(invest)
	by company (year): gen double rsum = sum(invest)
	by company (year): gen double match = invest_total - rsum + invest
{* example_end}{...}
{txt}{...}
{space 8}{hline 80}
{space 8}{it:({stata rangestat_run interval_rev using rangestat.sthlp:click to run})}


{marker observation_specific_windows}{...}
{pstd}
{ul:Observation-specific interval:}

{pstd}
You can also specify an interval that can't be computed
simply by adding a {it:#} to {it:low} or {it:high}. The following
example finds the average repair record of similarly priced cars,
as defined by cars within 10% of the price of the current car.

{space 8}{hline 27} {it:example do-file content} {hline 27}
{cmd}{...}
{* example_start - interval_10pc}{...}
	sysuse auto, clear
	
	gen low = .9 * price
	gen high = 1.1 * price
	rangestat (mean) rep78, interval(price low high)
	
	* spot check results for observation 15
	list make price rep78 low high rep78_mean in 15
	sum rep78 if inrange(price, low[15], high[15])
{* example_end}{...}
{txt}{...}
{space 8}{hline 80}
{space 8}{it:({stata rangestat_run interval_10pc using rangestat.sthlp:click to run})}

{pstd}
As a rule, you must specify both bounds but 
there is no obligation to specify {it:low} and {it:high} the same
way. You can use a variable for one bound and a {it:#}
or {help missing:system missing value} for the other. 

{space 8}{hline 27} {it:example do-file content} {hline 27}
{cmd}{...}
{* example_start - interval_low_.}{...}
	sysuse auto, clear
	
	gen low = .9 * price
	rangestat (mean) rep78, interval(price low .)
	
	* spot check results for observation 15
	list make price rep78 low rep78_mean in 15
	sum rep78 if inrange(price, low[15], .)
{* example_end}{...}
{txt}{...}
{space 8}{hline 80}
{space 8}{it:({stata rangestat_run interval_low_. using rangestat.sthlp:click to run})}


{title:Controlling the sample}

{pstd}
{cmd:rangestat} supports the standard Stata {cmd:if} and {cmd:in}
qualifiers to reduce the computations to those observations 
where the condition is true. In practice, you are not likely
to use these qualifiers because they restrict which observations
get results {it:AND} which observations fall into each observation's
interval. So for example you could be interested only in averages
for foreign cars with the same repair record, calculated using
data only from foreign cars:

{space 8}{hline 27} {it:example do-file content} {hline 27}
{cmd}{...}
{* example_start - control_if}{...}
	sysuse auto, clear
	rangestat (mean) price (count) price if foreign, interval(rep78 0 0)
	
	* spot check for a repair record of 3 for foreign cars only
	sum price if foreign & rep78 == 3
	list make price* if foreign & rep78 == 3
{* example_end}{...}
{txt}{...}
{space 8}{hline 80}
{space 8}{it:({stata rangestat_run control_if using rangestat.sthlp:click to run})}

{pstd}
If you browse the results, you can confirm that only foreign
cars have results and the example listing confirms that the results
are based only on data from foreign cars.


{pstd}
{ul:Calculate results for all observations using data only from some}

{pstd}
Let's say that we need the average price of foreign cars with the
same repair record and we need that for all cars in the data.
The solution is to create a copy of the price variable and
replace the prices of domestic cars with missing values. 

{space 8}{hline 27} {it:example do-file content} {hline 27}
{cmd}{...}
{* example_start - control_value}{...}
	sysuse auto, clear
	
	clonevar price_foreign = price if foreign
	
	rangestat (mean) price_foreign (count) price_foreign, interval(rep78 0 0)
	
	* spot check for a repair record of 3
	sum price_foreign if rep78 == 3
	list make price* foreign if rep78 == 3
{* example_end}{...}
{txt}{...}
{space 8}{hline 80}
{space 8}{it:({stata rangestat_run control_value using rangestat.sthlp:click to run})}


{pstd}
{ul:Calculate results for some observations using data from all}

{pstd}
Say you want to calculate the mean price per repair record
but you want results for a single observation per level of
repair record. 
To prevent {cmd:rangestat} from calculating results for the
other observations, simply use bounds where {it:low > high}.

{space 8}{hline 27} {it:example do-file content} {hline 27}
{cmd}{...}
{* example_start - control_sample}{...}
	sysuse auto, clear
	
	* tag the first observation per level of rep78
	bysort rep78 (make): gen first = _n == 1
	
	* create bounds for the first observation, use [1,0] for the rest
	by rep78: gen low  = cond(first, rep78, 1)
	by rep78: gen high = cond(first, rep78, 0)
	
	rangestat (mean) price (count) price, interval(rep78 low high)
	
	* show the results and confirm using summarize
	list rep78 price_* if first
	by rep78: sum price
{* example_end}{...}
{txt}{...}
{space 8}{hline 80}
{space 8}{it:({stata rangestat_run control_sample using rangestat.sthlp:click to run})}

{pstd}
Note again that {cmd:rangestat} does not generate results
when {cmd:rep78} is missing because those observations are
excluded from the sample.


{pstd}
{ul:Watch out for missing values for {it:keyvar}}

{pstd}
In the following example we have household data.
Each person in the data has their mother's
identifier if living in the same household. The mother's 
id is missing if the mother is deceased or living elsewhere.
You can use {cmd:rangestat} with an 
{bind:{cmd:interval(motherid personid personid)}}
to look up, for each observation,
how many persons in the household list the {hi:personid}
of the current observation as their mother.
This will not work, however, if there are missing values
in {hi:motherid} as {cmd:rangestat} will ignore all
observations where {it:keyvar} is missing. 
The solution is simple: make a copy of {hi:motherid}
and then replace the missing values
with an identifier that does not occur in the data.

{space 8}{hline 27} {it:example do-file content} {hline 27}
{cmd}{...}
{* example_start - control_missing}{...}
	* Example generated by -dataex-. To install: ssc install dataex
	clear
	input float(hhid personid motherid female age)
	123 111 888 1 12
	123 222 888 0 13
	123 333 888 1 14
	123 444 999 1 33
	123 555   . 0 40
	123 666   . 0 60
	123 888   . 1 35
	123 999   . 1 55
	end
	
	* since keyvar cannot be missing, replace motherid with a value that
	* is not in the data
	clonevar mid = motherid
	replace mid = 0 if mi(mid)
	
	rangestat (count) age (mean) age, interval(mid personid personid)
	list
{* example_end}{...}
{txt}{...}
{space 8}{hline 80}
{space 8}{it:({stata rangestat_run control_missing using rangestat.sthlp:click to run})}


{title:Validating your results}

{pstd}
As with all things in Stata, the code you use may 
run without error, but that is not a guarantee of correct results.

{pstd}
Before you even try {cmd:rangestat} on your problem, 
you should be able to
calculate what you want for any given observation 
using standard Stata commands. 
You should know that in Stata you can reference
the value of any variable for a particular observation using
{help subscripting:explicit subscripting}.
For example, the following code will list the fifth
observation in the data and then list all
observations in the data that have the same value
in the variable {hi:year} as that stored in the fifth observation.

{space 8}{hline 27} {it:example do-file content} {hline 27}
{cmd}{...}
{* example_start - validate_subscripting}{...}
	webuse grunfeld, clear
	list in 5
	list if year == year[5]
{* example_end}{...}
{txt}{...}
{space 8}{hline 80}
{space 8}{it:({stata rangestat_run validate_subscripting using rangestat.sthlp:click to run})}

{pstd}
Now let's say that you want to calculate 
the standard deviation of variable {hi:mvalue} by company
using a rolling window of 5 years. 
To make the problem a bit more complicated, we introduce missing
values for {hi:mvalue} and some years are also missing.
How would you calculate the measure for a single observation?
The simplest solution is to use Stata's {help inrange():inrange()}
function to target observations that are within the desired 5-year
window from the current observation.
And because this is panel data, you have to make sure that you
pick up only observations from the same {hi:company}.

{space 8}{hline 27} {it:example do-file content} {hline 27}
{cmd}{...}
{* example_start - validate_spot}{...}
	webuse grunfeld, clear
	 
	* include some missing values and omit some random observations
	set seed 1234
	replace mvalue = . if uniform() < .1
	drop if uniform() < .1
	
	* calculate expected results for observation 5
	sum mvalue if inrange(year, year[5]-4, year[5]) & company == company[5]
	
	* calculate expected results for observation 20
	sum mvalue if inrange(year, year[20]-4, year[20]) & company == company[20]
{* example_end}{...}
{txt}{...}
{space 8}{hline 80}
{space 8}{it:({stata rangestat_run validate_spot using rangestat.sthlp:click to run})}

{pstd}
Once you are satisfied with the set up of the problem for individual
observations, it's time to use {cmd:rangestat} to loop over all
observations in the data. If the results do not match your individual
test cases, then you did not set up the command correctly.

{space 8}{hline 27} {it:example do-file content} {hline 27}
{cmd}{...}
{* example_start - validate_full}{...}
	webuse grunfeld, clear
	 
	* include some missing values and omit some random observations
	set seed 1234
	replace mvalue = . if uniform() < .1
	drop if uniform() < .1
	
	* calculate over the whole sample and list results for test observations
	rangestat (sd) mvalue (count) mvalue, interval(year -4 0) by(company)
	
	list in 5
	list in 20
{* example_end}{...}
{txt}{...}
{space 8}{hline 80}
{space 8}{it:({stata rangestat_run validate_full using rangestat.sthlp:click to run})}


{title:Additional examples using built-in functions}


{pstd}
{ul:Mean wage of people of similar age}

{pstd}
Calculate the mean wage for everyone within 1 year of the age
for the current observation: 
      
{space 8}{hline 27} {it:example do-file content} {hline 27}
{cmd}{...}
{* example_start - mean_age}{...}
	sysuse nlsw88, clear
	 
	* calculate expected results for observation 10
	sum wage if inrange(age, age[10]-1, age[10]+1)
	
	* calculate expected results for observation 20
	sum wage if inrange(age, age[20]-1, age[20]+1)
	
	* calculate over the whole sample and list results for test observations
	rangestat wage, interval(age -1 1)
	list age wage* in 10
	list age wage* in 20
{* example_end}{...}
{txt}{...}
{space 8}{hline 80}
{space 8}{it:({stata rangestat_run mean_age using rangestat.sthlp:click to run})}

{pstd}
Repeat, but this time, do it by groups of people of the same race and in
the same industry. Also, exclude the wage from the current observation.
While we are at it, count the number of observations:

 {space 8}{hline 27} {it:example do-file content} {hline 27}
{cmd}{...}
{* example_start - mean_age2}{...}
	sysuse nlsw88, clear
	 
	* calculate expected results for observation 10
	sum wage if inrange(age, age[10]-1, age[10]+1) & race == race[10] & industry == industry[10] & _n != 10
	
	* calculate expected results for observation 20
	sum wage if inrange(age, age[20]-1, age[20]+1) & race == race[20] & industry == industry[20] & _n != 20
	
	* calculate over the whole sample and list results for test observations
	rangestat mwage = wage (count) wage, interval(age -1 1) excludeself by(race industry)
	list age *wage* in 10
	list age *wage* in 20
{* example_end}{...}
{txt}{...}
{space 8}{hline 80}
{space 8}{it:({stata rangestat_run mean_age2 using rangestat.sthlp:click to run})}


{pstd}
{ul:Median investment of other firms in a given year}

{pstd}
Some problems are hard to solve in Stata without a loop. You can easily
calculate the median investment from all firms in any given year using
a single {cmd:egen} call:

{space 8}{hline 27} {it:example do-file content} {hline 27}
{cmd}{...}
{* example_start - median_other}{...}
	webuse grunfeld, clear
	bysort year: egen m = median(invest)
{* example_end}{...}
{txt}{...}
{space 8}{hline 80}
{space 8}{it:({stata rangestat_run median_other using rangestat.sthlp:click to run})}

{pstd}
but there is no equally easy way to get an observation-specific median
calculated using all observations within the group {it:except} the one
from the current observation.  A naive brute force solution is to loop over
observations:

{space 8}{hline 27} {it:example do-file content} {hline 27}
{cmd}{...}
{* example_start - median_otherx}{...}
	webuse grunfeld, clear
	gen double mexclude = .
	quietly forvalues i=1/`=_N' {
	  sum invest if year == year[`i'] & company != company[`i'], detail
	  replace mexclude = r(p50) in `i'
	}
	list in 10/20
{* example_end}{...}
{txt}{...}
{space 8}{hline 80}
{space 8}{it:({stata rangestat_run median_otherx using rangestat.sthlp:click to run})}

{pstd}
However, this is much slower than the {cmd:egen} direct solution and
will become painfully slow as the number of observations increases. 

{pstd} 
With {cmd:rangestat}, all you need is 

{space 8}{hline 27} {it:example do-file content} {hline 27}
{cmd}{...}
{* example_start - median_otherx2}{...}
	webuse grunfeld, clear
	rangestat (median) invest, interval(year 0 0) excludeself
	list in 10/20
{* example_end}{...}
{txt}{...}
{space 8}{hline 80}
{space 8}{it:({stata rangestat_run median_otherx2 using rangestat.sthlp:click to run})}
        
{pstd}
Note that the {cmd:rangestat} interval can be degenerate, as is the case
above. Setting both {it:low} and {it:high} to zero will have the effect
of selecting, for the current observation, all (and only) observations
that have the same year. As the {opt excludeself} option is
specified, the value of the variable {cmd:invest} for each current
observation will be ignored. 

{pstd}
It is often possible to find solutions that reduce a problem like this to
something simpler that does not require looping over all observations.
Cox (2014) shows two such solutions using the example presented here.
Both solutions loop over companies instead of observations.  In this
case, {cmd:rangestat} is faster than either solution and its performance
advantage will increase as the number of groups (here companies) increases.


{pstd}
{ul:Looking up the education of a child's mother within a household}

{pstd}
{cmd:rangestat} can be used to look up the value of a variable in 
another observation. Suppose we have household data
where {cmd:hhid} and {cmd:personid} uniquely identify individuals
in the household and we want to look up the education of the mother 
for each child in the household.
To do an individual case by hand, you could use {cmd:summarize}
on the {hi:educ} variable subject to the condition that the
{hi:personid} code is the same as the {hi:motherid} for the child
and that the {hi:hhid} code is the same as the one for the child.

{pstd}
It would be tempting to specify the interval
using {hi:interval(personid motherid motherid)} to pick up 
the observation where the value in {hi:personid} is the same
as the value of {hi:motherid} for the current observation.
However, missing values are allowed when specifying
bounds and if both bounds are missing, all observations within
the group will be selected. One solution to this problem is
to use bounds where {it:low > high} when {hi:motherid} is missing.

{space 8}{hline 27} {it:example do-file content} {hline 27}
{cmd}{...}
{* example_start - mother_educ}{...}
	* Example generated by -dataex-. To install: ssc install dataex
	clear
	input float(hhid personid motherid educ)
	101 1 . 10
	101 3 1  8
	101 4 1  0
	101 5 3  0
	102 1 .  9
	102 2 1  .
	102 4 .  6
	102 5 4  2
	end

	* verify that hhid personid uniquely identify observations
	isid hhid personid, sort

	* look up education of mother for observation 3
	sum educ if personid == motherid[3] & hhid == hhid[3]
	
	* use [1,0] bounds if motherid is missing
	gen low = cond(mi(motherid),1, motherid)
	gen high = cond(mi(motherid),0, motherid)
	rangestat (min) educ, interval(personid low high) by(hhid)

	list, sepby(hhid)
{* example_end}{...}
{txt}{...}
{space 8}{hline 80}
{space 8}{it:({stata rangestat_run mother_educ using rangestat.sthlp:click to run})}

{pstd}
Since {cmd:hhid} and {cmd:personid} uniquely identify individuals,
there will be at most one observation that matches. Hence it does not matter
if we request the {cmd:(min)}, {cmd:(max)}, {cmd:(mean)}, or indeed any other 
statistic that yields the unique value. 
       
{pstd}
The example above was inspired by this 
{browse "http://www.statalist.org/forums/forum/general-stata-discussion/general/1323740-linking-mothers-education-with-child-in-individual-dataset-of-all-household":thread}
on Statalist.


{pstd}
{* NJC 22mar2017 new example/11apr2017 quite different example} 
{ul:Finding panels with runs of observations} 

{pstd}
A common problem in management of panel or longitudinal data is finding panels 
with long enough runs of observations, say successive years. 

{pstd} 
A first version of the problem is detecting whether long enough runs of 
observations exist at all: panels may start late, finish early or
contain gaps. 
The solution is pretty simple: count, for each observation, 
how many observations are within the desired window 
and flag panels if the highest count
is less than the target window length.

{pstd} 
A second version is to spell out further that 
they must be good in some sense, usually that variables of interest are not
missing. 
Here we use an indicator variable which is 1 if values of two variables
are present (not missing) and 0 otherwise. The indicator variable
approach has the advantage that it can be extended easily to accommodate
arbitrarily complicated criteria. We could add other conditions in
calculating the indicator, say that firms are in a particular industry
or in a certain size interval. When that is done, 
you simply sum the indicator variable within the desired window.
You then flag a panel if the highest count is less
than the  target window length.

{pstd}The Grunfeld data are balanced and contain no missing values. We 
wilfully wreak some havoc on the first panel
and drop odd years for the second.
We are looking for panels with at least one run of 3 successive years.

{space 8}{hline 27} {it:example do-file content} {hline 27}
{cmd}{...}
{* example_start - panel_runs}{...}
	webuse grunfeld, clear
	
	* sprinkle some missing values 
	replace invest = . if inlist(_n, 3, 6, 9, 12, 15) 
	replace mvalue = . if inlist(_n, 17, 18)
	drop if mod(year,2) & company == 2
	
	* first version, simple observation count
	rangestat (count) year, interval(year -2 0) by(company)
	bysort company (year_count): gen to_drop = year_count[_N] < 3

	* second version, sum good observations
	gen good_obs = !missing(invest, mvalue)
	rangestat (sum) good_obs, interval(year -2 0) by(company)
	bysort company (good_obs_sum): gen to_drop_mv = good_obs_sum[_N] < 3

	sort company year 
	list company-mvalue good_obs to_drop to_drop_mv if to_drop | to_drop_mv
{* example_end}{...}
{txt}{...}
{space 8}{hline 80}
{space 8}{it:({stata rangestat_run panel_runs using rangestat.sthlp:click to run})}


{pstd}
{ul:Running a regression over a rolling window of time}

{pstd}
You can use the built-in function {cmd:(reg)} to perform a basic
ordinary least squares linear regression (with a constant) over a
rolling window of time.

{pstd}
Before proceeding with a {cmd:rangestat} solution, you should
be able to set up the problem for individual observations using 
Stata's {help regress} commands.
Let's say you have panel data and you want a rolling regression
over a 7 years window.
You need to structure the {cmd:regress} command so that only observations
within the same panel group are used and include the current 
observation as well as those in the six preceding years.
You can do this using an {cmd:if} qualifier on the {cmd:regress} command.
You use {help subscripting:explicit subscripting} to get
the value of a variable for a particular observation. 
So to perform a regression for observation 15 in the example
below, we use {hi:year[15]} to refer to the value of 
variable {hi:year} for that observation and the 
{help inrange()} function will be true for
all observations in the data where 
{bind:{hi:year >= year[15]-6}} and
{bind:{hi:year <= year[15]}}.
Since we want to stick to observations within the panel group,
we also add the condition that the company identifier be the same
as the one in observation 15.
We redo this for observation 40.

{space 8}{hline 27} {it:example do-file content} {hline 27}
{cmd}{...}
{* example_start - user_reg}{...}
	webuse grunfeld, clear
	 	
	* calculate the expected results for observation 15
	regress invest mvalue kstock if inrange(year, year[15]-6, year[15]) ///
		& company == company[15]
	
	* calculate the expected results for observation 40
	regress invest mvalue kstock if inrange(year, year[40]-6, year[40]) ///
		& company == company[40]
{* example_end}{...}
{txt}{...}
{space 8}{hline 80}
{space 8}{it:({stata rangestat_run user_reg using rangestat.sthlp:click to run})}

{pstd}
Now you can use {cmd:rangestat}
to repeat the same regression for all observations.
The {cmd:(reg)} built-in function will create a number of variables
to store the results. 
The first three variables store
the number of observations, the R-squared, and the adjusted R-squared.
Then follow as many variables as there are predictors (plus the constant)
for the coefficients and another series for the standard errors.
If {cmd:rangestat} is used to replicate the results above, the variables created
will be:

{p2colset 9 22 24 2}{...}
{p2col :{hi:reg_nobs}}number of obs{p_end}
{p2col :{hi:reg_r2}}R-squared{p_end}
{p2col :{hi:reg_adj_r2}}adj. R-squared{p_end}
{p2col :{hi:b_mvalue}}coef of mvalue{p_end}
{p2col :{hi:b_kstock}}coef of kstock{p_end}
{p2col :{hi:b_cons}}coef of constant{p_end}
{p2col :{hi:se_mvalue}}standard error of mvalue{p_end}
{p2col :{hi:se_kstock}}standard error of kstock{p_end}
{p2col :{hi:se_cons}}standard error of constant{p_end}
{p2colreset}{...}

{pstd}
With {cmd:(reg)}, as with {help regress}, you specify the response (dependent variable) first, 
followed by the predictors.
The interval bounds
are set in relation to the value of the {hi:year} variable for 
the current observation. 
The {cmd:by(company)} indicates that the observations within
the interval range are to be found within the same panel group.

{pstd} 
Note that we are just showing Stata technique here. You might well think 
that seven observations is in practice rather few for a regression with
two predictors. 

{space 8}{hline 27} {it:example do-file content} {hline 27}
{cmd}{...}
{* example_start - user_reg2}{...}
	webuse grunfeld, clear
		
	rangestat (reg) invest mvalue kstock, interval(year -6 0) by(company)
	
	* check results for observation 15
	list in 15
	regress invest mvalue kstock if inrange(year, year[15]-6, year[15]) ///
		& company == company[15]
	
	* check results for observation 40
	list in 40
	regress invest mvalue kstock if inrange(year, year[40]-6, year[40]) ///
		& company == company[40]

{* example_end}{...}
{txt}{...}
{space 8}{hline 80}
{space 8}{it:({stata rangestat_run user_reg2 using rangestat.sthlp:click to run})}

{pstd}
As with all problems involving calculations over a rolling window,
the number of observations will be lower for the leading observations
for each group. Missing values will also reduce the number of observations
for individual regressions. 
{cmd:rangestat} will attempt to calculate results, regardless of sample size: 
it is up to the user to use the {cmd:reg_nobs} variable to reject
results if they are based on a sample size that is below an acceptable threshold.
Note that {cmd:(reg)} will return missing values for the current observation
in cases where
Stata's {help regress} would omit variable(s) due to collinearity
in the current observation's interval.


{pstd}
{ul:Calculating monthly covariances on daily data}

{pstd}
You can use the built-in function {cmd:(cov)} to get the covariance
of two variables. 

{pstd}
As with all {cmd:rangestat} problems, 
the first thing to do is to find a solution 
for individual observations using standard Stata commands. 
In this example, we create fake daily stock returns for a large
number of firms over a period of 50 months.
As with the rolling regression example above, 
we use {help subscripting:explicit subscripting} to get
the value of a variable for a particular observation. 

{space 8}{hline 27} {it:example do-file content} {hline 27}
{cmd}{...}
{* example_start - cov_solo}{...}
	* fake data on 100 firms for 50 months with 21 daily returns per month
	clear
	set seed 123123
	set obs 100
	gen long firm = _n
	expand 50
	bysort firm: gen month = _n
	expand 21
	bysort firm month: gen ret_day = _n
	gen return = runiform() if runiform() < .99
	gen weight = runiform()
	egen firm_month = group(firm month)
	 
	* calculate results using -correlate- for first and last observation
	corr return weight if firm_month == firm_month[1], covariance
	dis as res r(cov_12)
	corr return weight if firm_month == firm_month[_N], covariance
	dis as res r(cov_12)
{* example_end}{...}
{txt}{...}
{space 8}{hline 80}
{space 8}{it:({stata rangestat_run cov_solo using rangestat.sthlp:click to run})}

{pstd}
Now you can use {cmd:rangestat}'s {cmd:(cov)} option
to repeat the same covariance calculation for all observations in data.
While this appears inefficient because the results are the same for
every day in the month, {cmd:rangestat} is smart and will only perform calculations
once for all observations where the interval is the same and replicate
results for repeats with the same interval.

{space 8}{hline 27} {it:example do-file content} {hline 27}
{cmd}{...}
{* example_start - cov}{...}
	* fake data on 100 firms for 50 months with 21 daily returns per month
	clear
	set seed 123123
	set obs 100
	gen long firm = _n
	expand 50
	bysort firm: gen month = _n
	expand 21
	bysort firm month: gen ret_day = _n
	gen return = runiform() if runiform() < .99
	gen weight = runiform()
	egen firm_month = group(firm month)
	
	rangestat (cov) return weight, interval(firm_month 0 0) describe

	list in 1
	list in l
	
	* compare with results using -correlate- for first and last observation
	corr return weight if firm_month == firm_month[1], covariance
	dis as res r(cov_12)
	corr return weight if firm_month == firm_month[_N], covariance
	dis as res r(cov_12)
{* example_end}{...}
{txt}{...}
{space 8}{hline 80}
{space 8}{it:({stata rangestat_run cov using rangestat.sthlp:click to run})}

{pstd}
This example was adapted from
{browse "http://www.statalist.org/forums/forum/general-stata-discussion/general/1381867-calculating-monthly-covariances-based-on-daily-data":this thread}
on Statalist.


{title:Examples with a user-supplied Mata function}


{pstd}
{ul:Rowwise sorting}

{pstd}
Say you have data in wide layout and you need to sort
values across several variables.
You could use {help reshape} to convert the data
to long layout, sort observations, and then {help reshape}
the data back to wide layout, but that's a rather inefficient way to do this.
A better solution is to use {cmd:rowsort} 
(Cox 2009; {stata search rowsort} to locate), 
a computationally efficient solution implemented in Mata.

{pstd}
Since the sort order is observation specific, 
you can also use {cmd:rangestat} to target each observation
and use a simple Mata function to sort values.
For each observation, {cmd:rangestat} will call your Mata function with a
real matrix that contains the values of the specified variables 
for the set of observations
that fall within the interval bounds. 
In the following example, {hi:id} uniquely identifies observations
and the interval is defined using {hi:interval(id 0 0)}.
The only observation that will satisfy
this condition is the current observation and {hi:X}
will contain a real matrix with a single row. 
In Mata, the {cmd:sort()} function reorders rows so {hi:X}
must first be transposed, sorted according to the values
found in column 1, and then transposed
back before being returned to {cmd:rangestat}.

{space 8}{hline 27} {it:example do-file content} {hline 27}
{cmd}{...}
{* example_start - rowsort}{...}
	* Example generated by -dataex-. To install: ssc install dataex
	clear
	input float(id x1 x2 x3 x4 x5 x6)
	1 13 14 12  2 23 56
	2  2 34 56 43 21 12
	3  2  3 45  1 23 34
	4  4  6 13 14 22 45
	5  2  4 23 56 78 23
	end
	
	* make sure that id uniquely identifies each observation
	isid id

	* define a Mata function that sorts a rowvector
	mata:  
	    mata clear
	    real rowvector rsort(real matrix X) {
	        return(sort(X',1)')
	    }
	end 

	rangestat (rsort) x1-x6, interval(id 0 0)
	list, noobs compress
{* example_end}{...}
{txt}{...}
{space 8}{hline 80}
{space 8}{it:({stata rangestat_run rowsort using rangestat.sthlp:click to run})}

{pstd}
The example above was adapted from this 
{browse "http://www.statalist.org/forums/forum/general-stata-discussion/general/1383287-row-sorting":Statalist thread}.


{pstd}
{* NJC 22mar2017 new example}{...}
{ul: Moving quantiles using a user-supplied Mata function}

{pstd}
Given a response variable and a predictor variable,
we might be interested in plotting conditional quantiles, particular
quantiles for the response calculated within moving windows of the
predictor. The function {cmd:mm_quantile()} (Jann 2005) is a very
suitable general tool for calculating quantiles. All we need is to
decide which quantiles we want and specify those in a wrapper function.
 Then we call up a graph. 

{space 8}{hline 27} {it:example do-file content} {hline 27}
{cmd}{...}
{* example_start - moving_quantiles}{...}
	webuse nlswork, clear

	* ssc inst moremata needed for -mm_quantile()- 
	mata:  
	    mata clear
	    real rowvector myquantile(real colvector X) {
	        return(mm_quantile(X, 1, (0.1, 0.25, 0.5, 0.75, 0.9)))
	    }
	end 

	rangestat (myquantile) ln_wage, interval(age -2 2) 

	label var myquantile1 "p10"
	label var myquantile2 "p25"
	label var myquantile3 "p50"
	label var myquantile4 "p75"
	label var myquantile5 "p90"

	set scheme s1color 
	scatter ln_wage age, ms(oh) mc(gs8) || ///
	line myquantile? age, sort legend(order(6 5 4 3 2) col(1) pos(3)) ///
	    ytitle("`: var label ln_wage'") yla(, ang(h)) xla(15(5)45)
{* example_end}{...}
{txt}{...}
{space 8}{hline 80}
{space 8}{it:({stata rangestat_run moving_quantiles using rangestat.sthlp:click to run})}


{title:Comparison with tsegen (SSC)}

{pstd}
There is some overlap in functionality
between {stata "ssc des tsegen":tsegen} (SSC) and {cmd:rangestat}.
Both can calculate statistics over a rolling window of time. For example

{space 8}{hline 27} {it:example do-file content} {hline 27}
{cmd}{...}
{* example_start - compared_to_tsegen}{...}
	webuse grunfeld, clear
	 	
	tsegen double inv_m5b = rowmean(L(0/4).invest)
	
	rangestat (mean) invest, interval(year -4 0) by(company)
	
	assert inv_m5b == invest_mean
{* example_end}{...}
{txt}{...}
{space 8}{hline 80}
{space 8}{it:({stata rangestat_run compared_to_tsegen using rangestat.sthlp:click to run})}

{pstd}
In general, {stata "ssc des tsegen":tsegen} will be more efficient with time-series data 
because Stata is very efficient at expanding 
{help tsvarlist:time-series varlists} and
the {help egen} functions process all observations at the same time.

{pstd}
With {cmd:rangestat}, observations are processed one at a time. This
requires finding, for the current observation, which observations are
within the specified range and then computing and storing each statistic
for that observation.  {cmd:rangestat} is optimized for speed; it does
all its computations in Mata and has a very efficient algorithm to
identify the set of observations to use.  As the window of time
increases, {stata "ssc des tsegen":tsegen} will have to expand more
temporary variables and {cmd:rangestat} will eventually outperform
{stata "ssc des tsegen":tsegen}.  In minimal testing, the break-even
point appears to be around 50 periods, less if 
{stata "ssc des tsegen":tsegen} 
has to be repeatedly called to calculate additional statistics. 

{pstd}
The syntax of {cmd:rangestat} is more flexible (it's very similar to
that of {help collapse}) and {cmd:rangestat} can calculate multiple statistics
on multiple variables at the same time: 

{space 8}{hline 27} {it:example do-file content} {hline 27}
{cmd}{...}
{* example_start - compared_to_tsegen2}{...}
	webuse grunfeld, clear
	 	
	rangestat (sd) sd_inv=invest kstock (count) invest kstock, interval(year -4 0) by(company)
{* example_end}{...}
{txt}{...}
{space 8}{hline 80}
{space 8}{it:({stata rangestat_run compared_to_tsegen2 using rangestat.sthlp:click to run})}

{* NJC note 13apr2017 scope for future brief discussion comparing with egen} 

{title:Stored results}

{pstd}
{cmd:rangestat} stores the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Macros}{p_end}
{synopt:{cmd:r(newvars)}}list of variables created{p_end}
{p2colreset}{...}


{title:References}

{pstd}
Cox, N.J. 2007. {browse "http://www.stata-journal.com/sjpdf.html?articlenum=pr0033":Events in intervals.} 
{it:Stata Journal} 7: 440{c -}443. 

{pstd}
Cox, N.J. 2009. 
{browse "http://www.stata-journal.com/sjpdf.html?articlenum=pr0046":Rowwise.} 
{it:Stata Journal} 9: 137{c -}157. 

{pstd}
Cox, N.J. 2010. 
{browse "http://www.stata-journal.com/article.html?article=st0204":The limits of sample skewness and kurtosis.}
{it:Stata Journal} 10: 482{c -}495. 

{pstd}
Cox, N.J. 2011. 
{browse "http://www.stata-journal.com/sjpdf.html?articlenum=dm0055":Compared with ....} 
{it:Stata Journal} 11: 305{c -}314. 

{pstd}
Cox, N.J. 2014. 
{browse "http://www.stata-journal.com/article.html?article=dm0075":Self and others.} 
{it:Stata Journal} 14: 432{c -}444. 

{pstd} 
Jann, B. 2005 and later updates.  
moremata: Stata module (Mata) to provide various functions. 
{browse "https://ideas.repec.org/c/boc/bocode/s455001.html":https://ideas.repec.org/c/boc/bocode/s455001.html} 
(In Stata, install with {cmd: ssc inst moremata}) 


{title:Acknowledgements}

{pstd} 
Thanks to Clyde Schechter for kindly showing us an example 
where {cmd:rangestat} would generate an overflow when computing
interval bounds if {it:keyvar + #} could not be stored in a
variable of {it:keyvar}'s data type. 
This was most likely to bite when {it:keyvar} was a byte.
Observations with the overflow would be excluded from the sample.
This report led to a review of {cmd:rangestat}'s handling of missing
interval bounds and it was decided to follow the
same rules as {help inrange()} and allow missing bounds.

{pstd}
Several Statalist members helped indirectly by posting challenging 
real problems. 


{title:Authors}

{pstd}Robert Picard{p_end}
{pstd}picard@netbox.com{p_end}

{pstd}Nicholas J. Cox, Durham University, U.K.{p_end}
{pstd}n.j.cox@durham.ac.uk{p_end}

{pstd}Roberto Ferrer{p_end}
{pstd}refp16@gmail.com{p_end}


{title:Also see}

{psee}
Stata:  
{help egen}, 
{help rolling}, 
{help tssmooth}, 
{help tsvarlist}, 
{help tsrevar}
{p_end}

{psee}
SSC:  
{stata "ssc desc rangejoin":rangejoin}, 
{stata "ssc desc tsegen":tsegen}, 
{stata "ssc desc mvsumm":mvsumm}, 
{stata "ssc desc rollstat":rollstat}, 
{stata "ssc desc egenmore":egenmore}
{p_end}

{psee}
Others:  
{stata "search vlookup, all":vlookup}
{p_end}
