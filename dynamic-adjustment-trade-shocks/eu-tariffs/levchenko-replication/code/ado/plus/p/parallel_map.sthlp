{smcl}
{* *! version 0.2.0  26feb2021}{...}
{title:Title}

{p2colset 5 21 21 2}{...}
{p2col :{cmd:parallel_map} {hline 2}}Run Stata commands in parallel (wrapper of {help parallel} package){p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{pstd}Run many parallel instances of a command, in separate Stata instances:{p_end}

{phang2}
{cmd:parallel_map}
{cmd:,}
{opth val:ues(numlist)}
[{opt max:processes(#)}]
[{it:options}]
{cmd::}
{it:cmd}

{synoptset 21 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Parallel:}
{p2coldent:* {opth val:ues(numlist)}}each of these values will end up as the $task_id global in its own Stata process (so we will launch in total as many processes as values here){p_end}
{synopt :{opt max:processes(#)}}maximum number of Stata processes that will be open {it:at the same time}. Default: {it:(total cores / cores per process)}{p_end}
{synopt :{opt core:s_per_process(#)}}number of CPU cores that each process will take. Default is {help "	creturn##values":{it:c(processors)}}{p_end}
{synopt :{opt force}}to avoid slowing down total execution, we reduce {it:maxproc} if {it:(maxprocesses X cores per process)} exceeds the total number of cores available in the computer. {it:force} disables this{p_end}

{syntab:Execution options:}
{synopt :{opt v:erbose}}show more information{p_end}
{synopt :{opt nolog:table}}supress table linking to log-files of all processes{p_end}
{synopt :{opth pr:ograms(namelist)}}list of programs that will be exported to the worker processes{p_end}

{syntab:Internals:}
{synopt :{opt id(#)}}identifier of the {it:boss} process. Used as part the temporary folder names. Default: a pseudo-random number based on {it:runiform()}{p_end}
{synopt :{opt stata:_path(string)}}path of the Stata binary to be used. Default is based on the {it:parallel} package{p_end}
{synopt :{opt tmp:_path(string)}}folder where temporary files will be stored (they are stored in a sub-folder of this). Default is {help "	creturn##directories":{it:c(tmpdir)}}{p_end}

{synoptline}
{p2colreset}{...}
{p 4 6 2}* {opth val:ues(numlist)} is required.{p_end}


{title:Description}

{pstd}
parallel_map is a wrapper of the {browse "https://github.com/gvegayon/parallel":parallel} package,
with a slightly different syntax.
{p_end}


{marker examples}{...}
{title:Examples}

{pstd}Compute three different random numbers (view them in the log):{p_end}

{phang2}{cmd:. parallel_map, val(1/3) verbose: di runiform()}{p_end}

{pstd}Run a program that accesses the three globals that we can use to load/save data from/to disk:{p_end}

{hline}
{phang2}{cmd: program define MyExample}{p_end}
{phang2}{cmd: 	di "$parallel_dir" // we can save load/stuff here and then delete it}{p_end}
{phang2}{cmd: 	di "The task ID we can use to save results is: $task_id"}{p_end}
{phang2}{cmd: 	di "Also useful: $padded_task_id"}{p_end}
{phang2}{cmd: end}{p_end}
{phang2}{space 4}{p_end}
{phang2}{cmd: parallel_map, val(1/3) verbose program(MyExample): MyExample}{p_end}
{hline}
