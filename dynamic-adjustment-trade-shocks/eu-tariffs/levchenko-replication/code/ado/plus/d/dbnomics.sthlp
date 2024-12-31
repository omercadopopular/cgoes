{smcl}
{* *! version 1.1.2  30oct2018}{...}
{viewerjumpto "Syntax" "dbnomics##syntax"}{...}
{viewerjumpto "Description" "dbnomics##description"}{...}
{viewerjumpto "Options" "dbnomics##options"}{...}
{viewerjumpto "Remarks" "dbnomics##remarks"}{...}
{viewerjumpto "Examples" "dbnomics##examples"}{...}
{viewerjumpto "Stored results" "dbnomics##stored"}{...}
{viewerjumpto "Author" "dbnomics##author"}{...}

{title:Title}

{phang}
{bf:dbnomics} {hline 2} Stata client for DB.nomics, the world's economic database ({browse "https://db.nomics.world":https://db.nomics.world})

{marker description}{...}
{title:Description}

{pstd}
{cmd:dbnomics} provides a suite of tools to search, browse and import time series data from DB.nomics, the world's economic database ({browse "https://db.nomics.world":https://db.nomics.world}).
DB.nomics is a web-based platform that aggregates and maintains time series data from various statistical agencies across the world.
{cmd:dbnomics} only works with Stata 14.0 or higher.

{pstd}
{cmd:dbnomics} provides an interface between Stata and DB.nomics' API ({browse "https://api.db.nomics.world/apidocs":https://api.db.nomics.world/apidocs}). It enables creating custom queries through Stata's 
{help options:options} syntax (see {help dbnomics##examples:Examples}). To achieve this, the command relies on Erik Lindsley's libjson Mata library ({stata ssc install libjson:ssc install libjson}).

{marker syntax}{...}
{title:Syntax}

{p 8 8 2} {it: Load list of providers} {p_end}
{p 8 8 2} {cmdab:dbnomics} {cmdab:provider:s} [{cmd:,} {opt clear insecure}] {p_end}

{p 8 8 2} {it: Load content tree for a given provider} {p_end}
{p 8 8 2} {cmdab:dbnomics} {cmdab:tree} {cmd:,} {opt pr:ovider(PRcode)} [{opt clear insecure}] {p_end}

{p 8 8 2} {it: Load dataset structure given a provider and dataset} {p_end}
{p 8 8 2} {cmdab:dbnomics} {cmdab:data:structure} {cmd:,} {opt pr:ovider(PRcode)} {opt d:ataset(DScode)} [{opt clear} {opt insecure}] {p_end}

{p 8 8 2} {it: Load list of series for a given provider and dataset} {p_end}
{p 8 8 2} {cmdab:dbnomics} {cmdab:series} {cmd:,} {opt pr:ovider(PRcode)} {opt d:ataset(DScode)} [{it:dimensions_opt}|{opt sdmx(SDMX_mask)}] [{opt clear} {opt insecure} {opt limit(int)} {opt offset(int)}] {p_end}

{p 8 8 2} {it: Import series for a given provider and dataset} {p_end}
{p 8 8 2} {cmdab:dbnomics} {cmdab:import} {cmd:,} {opt pr:ovider(PRcode)} {opt d:ataset(DScode)} [{it:dimensions_opt}|{opt sdmx(SDMX_mask)}|{opt series:ids(SERIES_list)}] [{opt clear} {opt insecure} {opt limit(int)} {opt offset(int)}] {p_end}

{p 8 8 2} {it: Load a single series} {p_end}
{p 8 8 2} {cmdab:dbnomics} {cmdab:use} {it:series_id} {cmd:,} {opt pr:ovider(PRcode)} {opt d:ataset(DScode)} [{opt clear} {opt insecure}] {p_end}

{p 8 8 2} {it: Search for data across DB.nomics' providers} {p_end}
{p 8 8 2} {cmdab:dbnomics} {cmdab:find} {it:search_str} [{cmd:,} {opt clear} {opt insecure} {opt limit(int)} {opt offset(int)}] {p_end}

{p 8 8 2} {it: Load and display recently updated datasets} {p_end}
{p 8 8 2} {cmdab:dbnomics} {cmdab:news} [{cmd:,} {opt clear} {opt insecure} {opt limit(int)} {opt offset(int)}] {p_end}


{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{bf:provider(}{it:PRcode}{bf:)}}declare the reference data provider ({it:e.g.} AMECO, IMF, Eurostat) {p_end}
{synopt:{bf:dataset(}{it:DScode}{bf:)}}declare the reference dataset ({it:e.g.} PIGOT, BOP, ei_bsin_m) {p_end}
{synopt:{bf:clear}}replace data in memory {p_end}
{synopt:{bf:insecure}}connect via {it:http} instead of the default https.{p_end}

{syntab:For {cmd:series} and {cmd:import} only}
{synopt:{it:dimensions_opt}}provider- and dataset-specific options to filter series (see {help dbnomics##examples:Examples}){p_end}
{synopt:{bf:sdmx(}{it:SDMX_mask}{bf:)}}input an SDMX mask to select specific series ({bf:Note:} not all providers support this option){p_end}
{synopt:{bf:limit(}{it:int}{bf:)}}limit the number of series to load{p_end}
{synopt:{bf:offset(}{it:int}{bf:)}}skip the first {it:int} result(s){p_end}

{syntab:For {cmd:import} only}
{synopt:{bf:seriesids(}{it:SERIES_list}{bf:)}}input a comma-separated list to load specific time series{p_end}

{syntab:For {cmd:use} only}
{synopt:{it:series_id}}identifier of the series (see {help dbnomics##examples:Examples}){p_end}

{syntab:For {cmd:find} and {cmd:news} only}
{synopt:{bf:limit(}{it:int}{bf:)}}limit the number of results to display{p_end}
{synopt:{bf:offset(}{it:int}{bf:)}}skip the first {it:int} result(s){p_end}
{synoptline}
{p2colreset}{...}

{marker options}{...}
{title:Options}
{dlgtab:Main}

{phang}
{opt provider(PRcode)} sets the source with the data of interest. The list of data providers is regularly updated by the DB.nomics team. 
To get the list of available data providers, type {cmdab:dbnomics} {cmdab:provider:s} [{cmd:,} {opt clear}].{p_end}

{phang}
{opt dataset(DScode)} sets the dataset with the time series of interest. 
To get a hierarchy of all datasets linked to a particular {opt provider(PRcode)}, type {cmdab:dbnomics} {cmdab:tree}{cmd:,} {cmdab:pr:ovider(}{it:PRcode}{cmd:)} [{opt clear}]. 
({bf:Note:} some datasets in the category tree may not be accessible). {p_end}

{phang}
{opt clear} clears data in memory before loading data from DB.nomics. {p_end}

{phang}
{opt insecure} instructs dbnomics to access the DB.nomics platform via the {it:http} protocol, instead of the more secure {it:https}. {p_end}

{bf:{dlgtab:series}}

{marker dimensions_opt}{...}
{phang}
{opt dimensions_opt(dim_values)} are options that depend on the specific {opt provider(PRcode)} and {opt dataset(DScode)} and are used to identify a subset of series. 
A list of dimensions can be obtained using {cmd: dbnomics datastructure,} {opt provider(PRcode)} {opt dataset(DScode)}. 
For example, if the dimensions of {opt dataset(DScode)} are {cmd:freq.unit.geo}, accepted options for{cmd: dbnomics series,}{opt (...)} and {cmd: dbnomics import,}{opt (...)} 
are {opt freq(codelist)}, {opt unit(codelist)} and {opt geo(codelist)}. 
Each {opt dimension_opt(dim_values)} can contain one or more values in a space or comma-separated list, so as to select multiple dimensions at once ({it:e.g.}, a list of countries). 
{it:Note:} {cmd:dbnomics} is not able to validate user-inputted {opt dimension_opt(dim_values)}; 
if {opt dimension_opt(dim_values)} is incorrectly specified, {cmd:dbnomics} may throw an error or return the message {err: no series found}. See {help dbnomics##examples:Examples}. {p_end}

{marker sdmx}{...}
{phang}
{opt sdmx(SDMX_mask)} accepts an "SDMX mask" containing a list of dimensions separated with a dot "." character.
The dimensions are specific to each {opt provider(PRcode)} and {opt dataset(DScode)} and must be provided in the order specified by the {opt dataset(DScode)} data structure. 
The data structure can be obtained using {cmd: dbnomics datastructure,} {opt provider(PRcode)} {opt dataset(DScode)}. {it:Note:} some providers do not support this feature.
In such case {cmd: dbnomics} may throw an error or return the message {err:no series found}. {p_end}

{p 8 8 2}{it:Note}: {opt dimensions_opt(dim_values)} and {opt sdmx(SDMX_mask)} are mutually exclusive. {p_end}

{phang}
{opt limit(int)} sets a limit to the number of series to load via dbnomics. A {err:Warning} message is issued if the total number of series identified is larger than the inputted {opt limit(int)}. {p_end}

{phang}
{opt offset(int)} skips the first {it:int} series when loading data from dbnomics. This option can be combined with {opt limit(int)} to get a specific subset of series. {p_end}

{bf:{dlgtab:import}}

{phang}
{opt dimensions_opt(dim_values)} {help dbnomics##dimensions_opt:see above}.{p_end}

{phang}
{opt sdmx(SDMX_mask)} {help dbnomics##sdmx:see above}.{p_end}

{phang}
{opt seriesids(SERIES_list)} accepts a comma-separated list of series identifiers that belong to a {opt provider(PRcode)} and {opt dataset(DScode)}. {p_end}

{p 8 8 2}{it:Note}: {opt dimensions_opt(dim_values)}, {opt sdmx(SDMX_mask)} and {opt seriesids(SERIES_list)} are mutually exclusive. {p_end}

{phang}
{opt limit(int)} sets a limit to the number of series to load via dbnomics. A {err:Warning} message is issued if the total number of series identified is larger than the inputted {opt limit(int)}. {p_end}

{phang}
{opt offset(int)} skips the first {it:int} series when loading data from dbnomics. This option can be combined with {opt limit(int)} to get a specific subset of series. See {help dbnomics##examples:Examples}. {p_end}

{bf:{dlgtab:use}}

{phang}{it:series_id} is the unique identifier of a time series belonging to {opt provider(PRcode)} and {opt dataset(DScode)}.{p_end}

{bf:{dlgtab:find/news}}

{phang}{opt limit(int)} sets the maximum number of results to load and display. {p_end}

{phang}
{opt offset(int)} skips the first {it:int} results. May be combined with {opt limit(int)} to get a specific subset of results. {p_end}

{phang}


{marker remarks}{...}
{title:Remarks}
{*:{pstd} The DB.nomics data model is characterised by the following hiearchy: {it: provider -> datasets -> time series -> observations}.{p_end}}
{pstd} {cmd:dbnomics} has two main dependencies: {p_end}

{pstd} 1) The Mata json library {cmd:libjson} by Erik Lindsley, needed to parse JSON strings. It can be found on SSC: {stata ssc install libjson}. {p_end}
{pstd} 2) The routine {cmd:moss} by Robert Picard & Nicholas J. Cox, needed to clean some unicode sequences. It can be found on SSC: {stata ssc install moss}. {p_end}

{pstd} After each API call, {cmd:dbnomics} stores significant metadata in the form of {help char:dataset characteristics}. 
Type {cmd:{stata "char li _dta[]":char li _dta[]}} after {cmd:dbnomics} to obtain important info about the data, {it:e.g.}, the API endpoint. {p_end}

{marker examples}{...}
{title:Examples}

{pstd}{it:Search for producer price data on the DB.nomics platform:}{p_end}
{space 8}{cmd:. dbnomics find "producer price", clear}{space 4}{cmd:///}{space 2}{txt:({stata `"dbnomics find "producer price", clear "':click to run})}
{space 8}{it:(output omitted)}

{pstd}{it:Load the list of available providers with additional metadata:}{p_end}
{space 8}{cmd:. dbnomics }{cmdab:provider:s}{cmd:, clear}{space 4}{cmd:///}{space 2}{txt:({stata "dbnomics providers, clear":click to run})}

{pstd}{it:Show recently updated datasets:}{p_end}
{space 8}{cmd:. dbnomics news, clear}{space 4}{cmd:///}{space 2}{txt:({stata "dbnomics news, clear ":click to run})}
{space 8}{it:(output omitted)}

{pstd}{it:Load the dataset tree of of the {bf:AMECO} provider:}{p_end}
{space 8}{cmd:. dbnomics tree, }{cmdab:pr:ovider}{cmd:(AMECO) clear}{space 4}{cmd:///}{space 2}{txt:({stata "dbnomics tree, provider(AMECO) clear":click to run})}

{pstd}{it:Analyse the structure of dataset {bf:PIGOT} for provider {bf:AMECO}:}{p_end}
{space 8}{cmd:. dbnomics }{cmdab:data:structure}{cmd:, }{cmdab:pr:ovider}{cmd:(AMECO) {cmdab:d:ataset}{cmd:(PIGOT)} clear}{space 4}{cmd:///}{space 2}{txt:({stata "dbnomics datastructure, provider(AMECO) dataset(PIGOT) clear":click to run})}
{space 8}{cmd:Price deflator gross fixed capital formation: other investment}
{space 8}82 series found. Order of dimensions: (freq.unit.geo)

{pstd}{it:List all series in {bf:AMECO/}{bf:PIGOT} containing deflators in national currency:}{p_end}
{space 8}{cmd:. dbnomics }{cmdab:series}{cmd:, }{cmdab:pr:ovider}{cmd:(AMECO) {cmdab:d:ataset}{cmd:(PIGOT)} {cmd:unit(national-currency-2015-100)} clear}
{space 8}{txt:({stata "dbnomics series, provider(AMECO) dataset(PIGOT) unit(national-currency-2015-100) clear":click to run})}
{space 8}39 of 82 series selected. Order of dimensions: (freq.unit.geo)

{pstd}{it:Import all series in {bf:AMECO/}{bf:PIGOT} containing deflators in national currency:}{p_end}
{space 8}{cmd:. dbnomics }{cmdab:import}{cmd:, }{cmdab:pr:ovider}{cmd:(AMECO) {cmdab:d:ataset}{cmd:(PIGOT)} {cmd:unit(national-currency-2015-100)} clear}
{space 8}{txt:({stata "dbnomics import, provider(AMECO) dataset(PIGOT) unit(national-currency-2015-100) clear":click to run})}
{space 8}Processing 39 series
{space 8}........................................
{space 8}{bf:39 series found and imported}

{pstd}{it:Import a few {bf:AMECO/}{bf:PIGOT} series:}{p_end}
{space 8}{cmd:. dbnomics import, pr(AMECO) d(PIGOT) }{cmdab:series:ids}{cmd:(ESP.3.1.0.0.PIGOT,SVN.3.1.0.0.PIGOT,LVA.3.1.99.0.PIGOT) clear}
{space 8}{txt:({stata "dbnomics import, pr(AMECO) d(PIGOT) seriesids(ESP.3.1.0.0.PIGOT,SVN.3.1.0.0.PIGOT,LVA.3.1.99.0.PIGOT) clear":click to run})}
{space 8}Processing 3 series
{space 8}...
{space 8}{bf:3 series found and imported}

{pstd}{it:Import one specific series from {bf:AMECO/}{bf:PIGOT}:}{p_end}
{space 8}{cmd:. dbnomics use ESP.3.1.0.0.PIGOT, pr(AMECO) d(PIGOT)}{cmd: clear}
{space 8}{txt:({stata "dbnomics use ESP.3.1.0.0.PIGOT, pr(AMECO) d(PIGOT) clear":click to run})}
{space 8}Annually – (National currency: 2015 = 100) – Spain (AMECO/PIGOT/ESP.3.1.0.0.PIGOT)
{space 8}(62 observations read)

{pstd}{it:{bf:Eurostat} supports SMDX queries}. {it:Import all series in {bf:Eurostat/}{bf:ei_bsin_q_r2} related to Belgium:}{p_end}
{space 8}{cmd:. dbnomics }{cmdab:import}{cmd:, }{cmdab:pr:ovider}{cmd:(Eurostat) {cmdab:d:ataset}{cmd:(ei_bsin_q_r2)} {cmd:geo(BE) s_adj(NSA)} clear}
{space 8}{txt:({stata "dbnomics import, provider(Eurostat) dataset(ei_bsin_q_r2) geo(BE) s_adj(NSA) clear":click to run})}
{space 8}Processing 14 series
{space 8}..............
{space 8}{bf:14 series found and imported}

{pstd}{it:Do the same using {cmd:sdmx}:}{p_end}
{space 8}{cmd:. dbnomics }{cmdab:import}{cmd:, }{cmdab:pr:ovider}{cmd:(Eurostat) {cmdab:d:ataset}{cmd:(ei_bsin_q_r2)} {cmd:sdmx(Q..NSA.BE)} clear}
{space 8}{txt:({stata "dbnomics import, provider(Eurostat) dataset(ei_bsin_q_r2) sdmx(Q..NSA.BE) clear":click to run})}
{space 8}Processing 14 series
{space 8}..............
{space 8}{bf:14 series found and imported}

{pstd}{it:The {bf:Eurostat/}{bf:urb_ctran} dataset offers 12280 series, more than permitted at once by DB.nomics}:{p_end}
{space 8}{cmd:. dbnomics }{cmdab:series}{cmd:, }{cmdab:pr:ovider}{cmd:(Eurostat) {cmdab:d:ataset}{cmd:(urb_ctran)} clear}
{space 8}{txt:({stata "dbnomics series, pr(Eurostat) d(urb_ctran) clear":click to run})}
{space 8}{err:Warning: series set larger than dbnomics maximum provided items.}
{space 8}{err:Use the {cmd:offset} option to load series beyond the 1000th one.}
{space 8}{txt:12280 series selected. Order of dimensions: (FREQ.indic_ur.cities). {bf:Only #1 to #1000 retrieved}}

{pstd}{it:Using {cmd:limit} and {cmd:offset}, we can instruct {cmd:dbnomics} to only get series #1001 to #1100}:{p_end}
{space 8}{cmd:. dbnomics }{cmdab:import}{cmd:, }{cmdab:pr:ovider}{cmd:(Eurostat) {cmdab:d:ataset}{cmd:(urb_ctran)} {cmd:limit(100)} {cmd:offset(1000)} clear}
{space 8}{txt:({stata "dbnomics import, pr(Eurostat) d(urb_ctran) limit(100) offset(1000) clear":click to run})}
{space 8}Processing 100 series
{space 8}..................................................    50
{space 8}..................................................   100
{space 8}{bf:12280 series found and #1001 to #1100 loaded}

{marker results}{...}
{title:Stored results}

{pstd}
{cmd:dbnomics} stores the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Local}{p_end}
{synopt:{cmd:endpoint}}name of {cmd:dbnomics} subcommand{p_end}
{synopt:{cmd:cmd#}}command to load # result shown (For {cmd:find} and {cmd:news} only){p_end}
{p2colreset}{...}

{marker author}{...}
{title:Author}

{pstd}
	Simone Signore{break}
	signoresimone at yahoo [dot] it {p_end}
	https://dbnomics-stata.github.io/dbnomics/

