{smcl}
{* *! version 1.0.4  7apr2020}{...}
{title:Title}

{phang}
{bf:wid} {hline 2} Download data from WID.world

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:wid}
[{cmd:,} {it:options}]

{synoptset 50 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt ind:icators(list of 6-letter codes|_all)}}codes names of the indicators in the database; default is {it:_all} for all indicators; see {help wid##options:options} for details{p_end}
{synopt:{opt ar:eas(list of area codes|_all)}}area code names of the database; {it:XX} for countries/regions, {it:XX-YY} for subregions; default is {it:_all} for all areas; see {help wid##options:options} for details{p_end}
{synopt:{opth y:ears(numlist)}}years; default is all{p_end}
{synopt:{opt p:erc(list of percentiles|_all)}}list of percentiles; either {it:pXXpYY} or {it:pXX}; default is {it:all_} for all percentiles; see {help wid##options:options} for details{p_end}
{synopt:{opt ag:es(list of age codes|_all)}}age category codes in the database; {it:999} for all ages, {it:992} for adults; default is {it:_all} for all age categories; see {help wid##options:options} for more{p_end}
{synopt:{opt pop:ulation(list of population codes|_all)}}type of population; one-letter code, {it:t} for tax units, {it:i} for individuals; default is {it:_all} for all population types; see {help wid##options:options} for more{p_end}
{synopt:{opt meta:data}}retrieve metadata (ie. variable descriptions, sources, methodological notes, etc.){p_end}
{synopt:{opt ex:clude}}exclude interpolations and extrapolations from the results{p_end}
{synopt:{opt clear}}replace data in memory{p_end}
{synoptline}

{marker description}{...}
{title:Description}

{pstd}
{cmd:wid} imports data from the World Inequality Database (WID.world) directly into Stata.

{marker options}{...}
{title:Options}

{phang}
{opt ind:icators(list of 6-letter codes|_all)} specify indicators to retrieve.
Default is {it:_all} for all indicators.
You have to specify this option if you select all areas.
Indicators are 6-letter codes that corresponds to a given series type for a given income or wealth concept.
The first letter correspond to the type of series.
Some of the most common possibilities include:

{p2colset 15 36 38 16}{...}
{p2col :{bf:one-letter code}}{bf:description}{p_end}
{p2line}
{p2col :a}average{p_end}
{p2col :s}share{p_end}
{p2col :t}threshold{p_end}
{p2col :m}macroeconomic total{p_end}
{p2col :w}wealth/income ratio{p_end}
{p2line}
{space 14}See {browse "wid.world/codes-dictionary"} (section "ONE-LETTER CODE FOR SERIES TYPE")
{space 14}for the complete list.
{p2colreset}{...}

{p 8 8}The next five letters correspond a concept (usually of income and wealth). Some of the most common possibilities include:{p_end}

{p2colset 15 36 38 16}{...}
{p2col :{bf:five-letter code}}{bf:description}{p_end}
{p2line}
{p2col :ptinc}pre-tax national income{p_end}
{p2col :pllin}pre-tax labor income{p_end}
{p2col :pkkin}pre-tax capital income{p_end}
{p2col :fiinc}fiscal income{p_end}
{p2col :hweal}net personal wealth{p_end}
{p2line}
{space 14}See {browse "wid.world/codes-dictionary"} (section "FIVE-LETTER CODE FOR SERIES CONCEPT")
{space 14}for the complete list.
{p2colreset}{...}

{p 8 8}For example, {it:sfiinc} corresponds to the share of fiscal income, {it:ahweal} corresponds to average personal wealth.{p_end}

{phang}
{opt ar:eas(list of area codes|_all)} specify areas for which to retrieve data.
Default is {it:_all} for all areas.
You have to specify this option if you select all indicators.
Countries are coded using 2-letter ISO codes.
Country subregions are coded as {it:XX-YY} where {it:XX} is the country 2-letter code.
Regions at PPP use custom 2-letter codes. Regions at market exchange rates use the same codes with the suffix {it:-MER} added.
See {browse "wid.world/codes-dictionary"} (section "COUNTRY CODES") for the complete list of area codes.

{phang}
{opth y:ears(numlist)} specify years for which to retrieve data. Default is all years.

{phang}
{opt p:erc(list of percentiles|_all)} specify which percentiles of the distribution to retrieve.
For share and average variables, percentiles correspond to percentile ranges and take the form {it:pXXpYY}.
For example the top 1% share correspond to {it:p99p100}. The top 10% share excluding the top 1% is {it:p90p99}.
Thresholds associated to the percentile group {it:pXXpYY} correspond to the minimal income or wealth level that gets you into the group.
For example, the threshold of the percentile group {it:p90p100} or {it:p90p91} correspond to the 90% quantile.
Variables with no distributional meaning use the percentile {it:p0p100}.
See {browse "wid.world/codes-dictionary"} (section "PERCENTILE CODES") for more details.

{phang}
{opt ag:es(list of age codes|_all)} specify which age categories to retrieve.
Ages are coded using 3-digit codes.
Some of the most common possibilities include:

{p2colset 15 36 38 16}{...}
{p2col :{bf:3-digit code}}{bf:description}{p_end}
{p2line}
{p2col :999}all ages{p_end}
{p2col :992}adults, including elderly (20+){p_end}
{p2col :996}adults, excluding elderly (20-65){p_end}
{p2line}
{space 14}See {browse "wid.world/codes-dictionary"} (section "THREE-DIGIT CODE FOR AGE GROUP")
{space 14}for the complete list.
{p2colreset}{...}

{phang}
{opt pop:ulation(list of population codes|_all)} specify which population categories to retrieve.
Population categories are coded using one-letter codes.
Some of the most common possibilities include:

{p2colset 15 36 38 16}{...}
{p2col :{bf:one-letter code}}{bf:description}{p_end}
{p2line}
{p2col :i}individuals{p_end}
{p2col :t}tax units{p_end}
{p2col :j}equal-split adults (ie. income or wealth divided equally among spouses){p_end}
{p2line}
{space 14}See {browse "wid.world/codes-dictionary"} (section "ONE-LETTER CODE FOR POPULATION UNIT")
{space 14}for the complete list.
{p2colreset}{...}

{phang}
{opt metadata} also retrieve metadata. Metadata provide, for each observation, the name and short description of the variable, of the age category, of the population category, the source of the data, and methodological notes.

{phang}
{opt exclude} exclude interpolation/extrapolations from the results. Some of the data on WID.world is the result of interpolations (when data is only available for a few years) or extrapolations (when data is not available for the most recent years) that are based on much more limited information that other data points. We include these interpolations/extrapolation by default as a convenience, and also because these values are used to perform regional aggregations. Yet we stress that these estimates, especially at the level of individual countries, can be fragile. For many purposes, it can be preferable to exclude these data points.

{phang}
{opt clear} replace data in memory, if any; if dataset is not empty and that option is not specified, the command will refuse to execute to avoid data losses.

{marker remarks}{...}
{title:Remarks}

{pstd}
Data is presented in long format (one observation per value).

{pstd}
The complete and up-to-date description of the database is available online at {browse wid.world/codes-dictionary}.

{pstd}
All monetary amounts are in local currency at constant prices for countries and country subregions.
Monetary amounts for world regions are in EUR PPP.
Series are at last year's prices, the database being usually updated every year in the summer.
To check the year of reference, look at when the price index {it:inyixx} is equal to 1.
You can access the price index using the indicator {it:inyixx}, the PPP exchange rates using {it:xlcusp} (USD), {it:xlceup} (EUR), {it:xlcyup} (CNY), and the market exchange rates using {it:xlcusx} (USD), {it:xlceux} (EUR), {it:xlcyux} (CNY).

{pstd}
Shares and wealth/income ratios are given as a fraction of 1.
That is, a top 1% share of 20% is given as 0.2.
A wealth/income ratio of 300% is given as 3.

{marker examples}{...}
{title:Examples}

{pstd}
The following examples only illustrate graphing, and do not leave any data in memory.

{pstd}
Plot wealth inequality share in France:

        {cmd:wid, indicators(shweal) areas(FR) perc(p90p100 p99p100) ages(992) pop(j) clear}

        {cmd:// Reshape and plot}
        {cmd:reshape wide value, i(year) j(percentile) string}
        {cmd:label variable valuep90p100 "Top 10% share"}
        {cmd:label variable valuep99p100 "Top 1% share"}

        {cmd:graph twoway line value* year, title("Wealth inequality in France") ///}
        {cmd:    ylabel(0.2 "20%" 0.4 "40%" 0.6 "60%" 0.8 "80%") ///}
        {cmd:    subtitle("equal-split adults") ///}
        {cmd:    note("Source: WID.world")}

        {it:({stata wid_example1:click to run})}

{pstd}
Plot the evolution of the pre-tax national income of the bottom 50% of the population in China, France and the United States since 1978 (in log scale):

        {cmd:// Download and store the 2017 USD PPP exchange rate}
        {cmd:wid, indicators(xlcusp) areas(FR US CN) year(2017) clear}
        {cmd:rename value ppp}
        {cmd:tempfile ppp}
        {cmd:save "`ppp'"}

        {cmd:wid, indicators(aptinc) areas(FR US CN) perc(p0p50) year(1978/2017) ages(992) pop(j) clear}
        {cmd:merge n:1 country using "`ppp'", nogenerate}

        {cmd:// Convert to 2017 USD PPP (thousands)}
        {cmd:replace value = value/ppp/1000}

        {cmd:// Reshape and plot}
        {cmd:keep country year value}
        {cmd:reshape wide value, i(year) j(country) string}
        {cmd:label variable valueFR "France"}
        {cmd:label variable valueUS "United States"}
        {cmd:label variable valueCN "China"}

        {cmd:graph twoway line value* year, yscale(log) ylabel(1 2 5 10 20) ///}
        {cmd:    ytitle("2017 PPP USD (000's)") ///}
        {cmd:    title("Average pre-tax national income of the bottom 50%") subtitle("equal-split adults") ///}
        {cmd:    note("Source: WID.world") legend(rows(1))}

        {it:({stata wid_example2:click to run})}

{pstd}
Plot the long-run evolution of average net national income per adult in France, Germany, the United Kingdom and the United States (in log scale):

        {cmd:// Download and store the 2017 USD PPP exchange rate}
        {cmd:wid, indicators(xlcusp) areas(FR US DE GB) year(2017) clear}
        {cmd:rename value ppp}
        {cmd:tempfile ppp}
        {cmd:save "`ppp'"}

        {cmd:// Download net national income in constant 2017 local currency}
        {cmd:wid, indicators(anninc) areas(FR US DE GB) age(992) clear}
        {cmd:merge n:1 country using "`ppp'", nogenerate}

        {cmd:// Convert to 2017 USD PPP (thousands)}
        {cmd:replace value = value/ppp/1000}

        {cmd:// Reshape and plot}
        {cmd:keep country year value}
        {cmd:reshape wide value, i(year) j(country) string}
        {cmd:label variable valueFR "France"}
        {cmd:label variable valueUS "United States"}
        {cmd:label variable valueDE "Germany"}
        {cmd:label variable valueGB "United Kingdom"}

        {cmd:graph twoway line value* year, yscale(log) ///}
        {cmd:    ytitle("2017 PPP USD (000's)") ylabel(2 5 10 20 50 100) ///}
        {cmd:    title("Average net national income") subtitle("per adult") ///}
        {cmd:    note("Source: WID.world")}

        {it:({stata wid_example3:click to run})}

{title:Contact}

{pstd}
If you have comments, suggestions, or experience any problem with this command, please contact <thomas.blanchet@wid.world>.

