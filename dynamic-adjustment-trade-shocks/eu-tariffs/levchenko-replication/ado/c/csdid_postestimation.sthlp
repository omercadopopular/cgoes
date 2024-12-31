{smcl}
{* *! version 2  8/4/2022 Finally A version}{...}
{title:{cmd:csdid postestimation}: Post-estimation utilities for CSDID}

{it:{bf:Aggregations and Pretrend testing}}

{p}There are two commands that can be used as post estimation tools. These are {cmd:csdid_estat} and {cmd:csdid_stats}.
Both can be used to obtain similar statistics. The first one, {cmd:csdid_estat}, works when using 
{cmd: estat}, after the model estimation via {help csdid}. {p_end}

{p}The second one {cmd:csdid_stats} works similarly but when using the "saved" RIF file. It can be used to produce 
wild Bootstrap SE.{p_end}

Below the syntax for both commands is discussed.

{marker syntax}{...}
{title:Syntax}

{cmd:estat} [subcommand], [options]
 
{cmd:csdid_stats} [subcommand], [options]

{marker subcommands}{...}
{title:Subcommands}
{synoptset 20 tabbed}{...}

{synopthdr:Subcommands}
{synoptline}
{synopt :{opt pretrend}}Estimates the chi2 statistic of the null hypothesis that ALL pretreatment ATTGT's are 
statistically equal to zero.{p_end}

{synopt :{opt pretrend, window(#1 #2)}}Estimates the chi2 statistic of the null hypothesis that ALL pretreatment ATTGT's within window are 
statistically equal to zero.{p_end}
 
Aggregation subcommands.
 
{synopt:{opt simple}}Estimates the ATT for all groups across all periods. {p_end}

{synopt:{opt group}}Estimates the ATT for each group or cohort, over all periods {p_end}

{synopt:{opt calendar}}Estimates the ATT for each period, across all groups or cohorts {p_end}

{synopt:{opt event}}Estimates the dynamic ATT's. ATT's are estimated using all periods relative to the 
period of the first treatment, across all cohorts.{p_end}

{synopt:{opt event, window(#1 #2)}}Same as above, but request only events between #1 and #2 to be estimated. {p_end}

{synopt:{opt cevent, window(#1 #2)}}Estimates Censored Event averages. It estimates the average across all ATTGT's that correspond 
to periods between T#1 and T#2, inclusive. For example estat cevent , window(0 0) simply reproduces the effect at T+0.{p_end}

{synopt:{opt all}}Produces all aggregations. Not available with csdid_stats. And cannot be combined with estore() nor esave() {p_end}

{synopt:{opt attgt}}Produces the ATTGT's. {p_end}

{synopthdr:options}
{synoptline}
{synopt:{opt estore(name)}}When using any of the 4 types of aggregations, request storing the outcome in memory as {it:name}{p_end}

{synopt:{opt esave(name)}}When using any of the 4 types of aggregations, request saving the outcome in disk. {p_end}

{synopt:{opt replace}}Request to replace {it:ster} file, if the a file already exists.{p_end}
{synoptline}

{synopt:{opt post}}Request posting the results in e().{p_end}

{synopt:{opt save}}Request saving the RIF associated with the requested aggregation as a variable in the file. They can be used to produce other aggregations based on the RIFs See example.{p_end}
{synoptline}

{syntab:{bf: Standard Error Options}}

{phang}By default, {cmd:csdid_estat} and {cmd:csdid_stats} produce asymptotic standard errors. {p_end}

{phang}Using {cmd:csdid_estat} or {cmd: estat} {it:subcommand} always produces asymptotic standard errors, even if {help csdid} 
was estimated requesting Wbootstrap standard errors. {p_end}
{phang}To produce Wbootstrap Standard errors, for other aggregations, you need to use the saved RIF-file, and {cmd:csdid_stats} {p_end}

{phang}{cmd:csdid_stats} can produce Wbootstrap standard if requested, using the following options:

{synopthdr:SE options}
{synoptline}

{synopt:wboot}Request Estimation of Standard errors using a multiplicative WildBootstrap procedure.
The default uses 999 repetitions using mammen approach. {p_end}

{synopt:wboot(reps(#))}Specifies the number of repetitions to be used for the Estimation of the WBoot SE. Default is 999 {p_end}

{synopt:wboot(wtype(type))}Specifies the type of Wildbootstrap procedure. The default is "mammen", but "rademacher" is also 
avilable.{p_end}


{synopt:rseed(#)}Specifies the seed for the WB procedure. Use for replication purposes.{p_end}

{synoptline}
 
{title:{cmd:csdid_plot}: Plots after csdid, csdid_estat and csdid_stats}

{cmd:csdid} also comes with its own command to produce simple plots for all aggregations. It automatically recognizes last 
estimated results left by {cmd: csdid}, {cmd: csdid_estat} and {cmd: csdid_stats}, to produce the corresponding plots.

{marker syntax}{...}
{title:Syntax}

{phang}{cmd:csdid_plot}, [options]

{synopthdr:Plot options}
{synoptline}

{synopt:style(styleoption)} Allows you to change the style of the plot. The options are rspike (default), rarea, rcap and rbar.{p_end}

{synopt:title(str)}Sets title for the constructed graph{p_end}

{synopt:xtitle(str)}Sets title for horizontal axis{p_end}

{synopt:ytitle(str)}Sets title for vertical axis axis{p_end}

{synopt:name(str)}Request storing a graph in memory under {it:name}{p_end}
 
{synopt:group(#)}When using {cmd:csdid_plot} after {cmd:csdid} or after {cmd:csdid_stats attgt}, one can produce dynamic type
plots for each group/cohort. In that case, one needs to indicate which {it:group(#)} to plot.

{pstd}Other {cmd:twoway graph} options are allowed.

{marker remarks}{...}
{title:Remarks}

{pstd}
The command {cmd:csdid_plot} is an easy-to-use command to plot different ATT aggregations, either across groups,
across time, or dynamic effects, (event plot). It has, however, limited flexibility{p_end}
{pstd}
If you want to further modify this figure, I suggest using the community contributed command {help addplot} by Benn Jan.
If you do, please cite his software. See references section.

 
{title:{cmd:csdid_rif}: Module to create table results based on the var}

{pstd}{cmd:csdid_rif} is a command that can be used to create further tables based on RIF-variables in your dataset. For example, using {cmd:csdid_stats event}, one can save the event related RIF variables, as well as the simple Average ATT RIF. One can then use {cmd:csdid_rif} to create a table based on all these information.{p_end}

{marker syntax}{...}
{title:Syntax}

{phang}{cmd:csdid_rif} [varlist] [if in], [options]

{synopthdr:Options}
{synoptline}

{synopt:cluster(varname)}Request estimating Clustered Standard errors. Default is Robust Standard errors{it:name}{p_end}

{synopt:level(#)}Indicates the CI level to be used. Default 95{p_end}

{synopt:wboot}Request the estimation of Wildbootstrap SE with Uniform Confidence Intervals. Can be combined with Cluster option{p_end}

{synopt:reps(#)}Requests # replications used for the Bootstrap. Default 999.{p_end}

{synopt:seed(#)}Provides a Seed for replication purposes{p_end}

{marker remarks}{...}
{title:Remarks}

{pstd}This command can also be used with any other output that provides the RIF functions. After the command is run, it will leave behind information in e(){p_end}
   
 
{marker examples}{...}
{title:Examples}

{phang}
{stata "use https://friosavila.github.io/playingwithstata/drdid/mpdta.dta, clear"}

{pstd}Estimation of all ATTGT's using Doubly Robust IPW (DRIPW) estimation method. Saving RIF in disk {p_end}

{phang}
{stata csdid  lemp lpop , ivar(countyreal) time(year) gvar(first_treat) method(dripw) saverif(_rif_) replace}

{pstd}Estimation of all ATT aggregations{p_end}

{phang}
{stata estat all}

{pstd}Estimation of all events between periods -2 to +2 {p_end}

{phang}
{stata estat event, window(-2 2)}

{pstd}Producing a simple Plot for last results. Two different styles{p_end}

{phang}
{stata csdid_plot}

{phang}
{stata estat event, window(-2 2)}

{phang}
{stata csdid_plot, style(rarea)}

{pstd}Dynamic effects for group treated in 2006{p_end}

{phang}
{stata csdid  lemp lpop , ivar(countyreal) time(year) gvar(first_treat) method(dripw) }

{phang}
{stata csdid_plot, group(2006)}

{pstd}Estimation of aggregations using RIF file. Using Asymptotic Standard errors and WBootstrap Standard errors{p_end}

{phang}{stata use _rif_, clear}

{pstd}Dynamic Effects with Asymptotic Standard errors{p_end}
{phang}
{stata csdid_stats event}

{pstd}Dynamic Effects with Wbootstrap Std Err{p_end}
{phang}
{stata csdid_stats event, wboot}

{pstd}Saving RIFs for all aggregations{p_end}

{phang}
{stata csdid_stats event, save}

{phang}
{stata csdid_stats calendar, save}

{phang}
{stata csdid_stats group, save}

{pstd}Producing Tables Avg ATTs, using asymptotic Std Err{p_end}
{phang}
{stata csdid_rif Pre_avg Post_avg CAverage GAverage}

{pstd}Producing Tables Avg ATTs, using Wboot Std Err and uniform Confidence Intervals{p_end}
{phang}
{stata csdid_rif Pre_avg Post_avg CAverage GAverage, wboot}
{p_end}

{marker authors}{...}
{title:Authors}


{pstd}
Fernando Rios-Avila{break}
Levy Economics Institute of Bard College{break}
Annandale-on-Hudson, NY{break}
friosavi@levy.org

{pstd}Pedro H. C. Sant'Anna {break}
Vanderbilt University{p_end}

{pstd}Brantly Callaway {break}
University of Georgia{p_end}

{marker references}{...}
{title:References}

{phang2}Abadie, Alberto. 2005. 
"Semiparametric Difference-in-Differences Estimators." 
{it:The Review of Economic Studies} 72 (1): 1–19.{p_end}

{phang2}Callaway, Brantly and Sant'Anna, Pedro H. C. 2021. 
"Difference-in-Differences with multiple time periods." , 225(2):200-230.
{it:Journal of Econometrics}.{p_end}

{phang2}Sant’Anna, Pedro H. C., and Jun Zhao. 2020. 
"Doubly Robust Difference-in-Differences Estimators." 
{it:Journal of Econometrics} 219 (1): 101–22.{p_end}

{phang2}Rios-Avila, Fernando, 
Pedro H. C. Sant'Anna, 
and Brantly Callaway, 2021.
 “CSDID: Difference-in-Differences with Multiple periods.” 
{p_end}

{phang2}
 Jann, B. (2014). addplot: Stata module to add twoway plot objects to an existing twoway graph. Available from 
        http://ideas.repec.org/c/boc/bocode/s457917.html.
{p_end}
		
{marker aknowledgement}{...}
{title:Aknowledgement}

{pstd}This command was built using the DID command from R as benchmark, originally written by Pedro Sant'Anna and Brantly Callaway. {p_end}

{pstd} Some of the additional tools and options are my attempt to provide things R version doesnt have yet. {p_end}

{pstd}Many thanks to Pedro for helping me understand the inner workings of the estimator.{p_end}

{pstd}Thanks also to Enrique, who helped with the display set up, plus other questions that pop up while working on this{p_end}

{title:Also see}

{p 7 14 2}
Help:  {help drdid}, {help csdid}, {help csdid postestimation}, {help xtdidregress} {p_end}

