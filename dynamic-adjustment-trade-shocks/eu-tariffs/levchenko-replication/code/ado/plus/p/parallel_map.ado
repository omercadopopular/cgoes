*! version 0.2.0  26feb2021
program define parallel_map
	
	* Intercept -clean- option
	cap syntax, clean [Verbose]
	if !c(rc) {
		parallel_map_clean, `verbose'
		exit
	}

	global pids // clean up
	cap noi parallel_map_inner `0'
	loc rc = c(rc)
	foreach pid of global pids {
		di as error " - closing process `pid'"
		cap noi prockill `pid'
		if (c(rc)) di as error "  could not close process (already closed?)"
	}
	error `rc'
end


capture program drop parallel_map_clean
program define parallel_map_clean
	syntax, [verbose]
	loc verbose = ("`verbose'" != "")
	if ("$LAST_PARALLEL_DIR" != "") {
		cap noi mata : unlink_folder("${LAST_PARALLEL_DIR}", `verbose')
	}
end


cap pr drop parallel_map_inner
program define parallel_map_inner

	_on_colon_parse `0'
	loc 0 `s(before)'
	loc cmd `s(after)'
	syntax, VALues(numlist integer min=1 max=1000 >=1 <100000000) ///
		[ ///
		MAXprocesses(integer 0) ///
		COREs_per_process(integer 0) ///
		FORCE ///
		ID(integer 0) ///
		METHOD(string) ///
		STATA_path(string) ///
		TMP_path(string) ///
		PRograms(string) ///
		Verbose ///
		CLEAN /// Clean-up entire folder at the end (else need to run parallel_map_inner, clean)
		noLOGtable /// Show table with links to log-files
		]

	loc verbose = ("`verbose'" != "")
	loc force = ("`force'" != "")
	loc clean = ("`clean'" != "")
	loc logtable = ("`logtable'" != "nologtable")
	loc max_processes `maxprocesses'
	if ("`method'" == "") {
		if (c(os)=="Windows") {
			loc method procexec
		}
		else {
			loc method shell
		}
	}
	_assert inlist("`method'", "shell", "procexec")
	loc method = strlower(c(os)) + "-" + "`method'"
	
	tempname f // File handle

	cap parallel
	_assert _rc!=199, msg(`"-parallel- is not installed; download it from {browse "http://github.com/gvegayon/parallel"}"')


	// --------------------------------------------------------------------------
	// Parameters
	// --------------------------------------------------------------------------

	* Delete last parallel instance ran
	parallel_map_clean

	* How many cores are available in total?
	loc total_cores : env SLURM_CPUS_ON_NODE
	if ("`total_cores'" == "") {
		qui parallel numprocessors
		loc total_cores = r(numprocessors)
	}

	* How many cores for each worker process?
	if (`cores_per_process' <= 0) loc cores_per_process = c(processors)

	* How many workers?
	if (`max_processes' <= 0) {
		loc max_processes = max(1, int(`total_cores' / `cores_per_process'))
	}


	* Adjust to available cores
	loc old_max_processes = `max_processes'
	if (`total_cores' < `max_processes' * `cores_per_process') & (!`force') {
		loc max_processes = max(1, int(`total_cores' / `cores_per_process'))
	}

	if (`verbose') di as text _n "{bf:Parallel information:}"
	if (`verbose') di as text " - Available cores     {col 24}: {res}`total_cores'"
	if (`verbose') di as text " - Cores per process   {col 24}: {res}`cores_per_process'"
	if (`verbose') di as text " - Number of processes {col 24}: {res}`max_processes'"
	if (`verbose' & `old_max_processes'>`max_processes') di as text "   - Reduced from {res}`old_max_processes'{txt} processes as there are not {res}`old_max_processes'*`cores_per_process'{txt} available cores"
	if (`verbose' & `old_max_processes'>`max_processes') di as text "   - To use more processes, use the {inp}force{txt} option, or adjust the {inp}cores(#){txt} option"
	if (`verbose') di as text " - Method {col 24}: {res}`method'"


	* Caller ID
	loc caller_id `id'
	if (`caller_id' <= 0) loc caller_id = runiformint(1, 1e9-1)
	loc padded_caller_id = string(`caller_id', "%09.0f")
	if (`verbose') di as text " - Caller ID {col 24}: {res}`padded_caller_id'"


	* Stata Path
	if ("`stata_path'" != "") {
		conf file "`stata_path'"
	}
	else {
		qui mata: st_local("error", strofreal(parallel_setstatapath("", 0)))
		_assert (!`error'), msg("Can not set Stata directory, try using -statapath()- option") rc(`error')
		loc stata_path = $PLL_STATA_PATH
		global PLL_STATA_PATH
	}
	if (`verbose') di as text " - Stata path {col 24}: {res}`stata_path'"


	* Temporary path
	if ("`tmp_path'" == "") loc tmp_path = c(tmpdir)
	* Workaround for inputs that don't end with "/"
	loc last_char = substr("`tmp_path'", strlen("`tmp_path'"), 1)
	if (!inlist("`last_char'", "/", "\")) loc tmp_path = "`tmp_path'`c(dirsep)'"
	if (`verbose') di as text " - Temporary folder {col 24}: {res}`tmp_path'"
	mata: st_local("ok", strofreal(direxists("`tmp_path'")))
	_assert `ok', msg(`"Temporary folder {res}"`tmp_path'" {txt}does not exist"')
	loc parallel_dir = "`tmp_path'PARALLEL_`padded_caller_id'"
	if (`verbose') di as text " - Parallel folder {col 24}: {res}`parallel_dir'"

	global LAST_PARALLEL_DIR = "`parallel_dir'"


// --------------------------------------------------------------------------
// Export programs
// --------------------------------------------------------------------------
	if ("`programs'" != "") {
		tempfile prog_log prog_include
		qui mata: parallel_export_programs("`prog_include'", "`programs'", "`prog_log'")
	}

// --------------------------------------------------------------------------
// Write base files
// --------------------------------------------------------------------------

	* Create parallel folder if it doesn't exist
	cap mata: mkdir("`parallel_dir'", 1) // 1 makes it readable by everyone with access to the root folder

	* Write do-file
	qui findfile "parallel_map_template.do.ado"
	loc source "`r(fn)'"
	loc destination "`parallel_dir'`c(dirsep)'parallel_code.do"
	if (`verbose') di as text " - Do-file {col 24}: {res}`destination'"

	loc include_programs `""""'
	if ("`programs'" != "") loc include_programs `"`"include "`prog_include'" // `programs'"'"'
	loc from `"@include_programs @num_processors @working_path @personal @plus @caller_id @parallel_dir @command"'
	loc to `"`include_programs' `cores_per_process' "`c(pwd)'" "`c(sysdir_personal)'" "`c(sysdir_plus)'" `padded_caller_id' `parallel_dir' `"`cmd'"'"' // "'
	mata: filefilter("`source'", "`destination'", tokens(`"`from'"'), tokens(`"`to'"'))
	loc do_file "`destination'"

	if ("`method'" == "windows-shell") {
		* Write batch file
		loc batch_fn "`parallel_dir'`c(dirsep)'parallel_code.bat"
		if (`verbose') di as text " - Batch-file {col 24}: {res}`batch_fn'"
		qui file open `f' using "`batch_fn'", write text replace
		file write `f' `"pushd "`c(pwd)'""' _n
		file write `f' `"start /MAX /HIGH set STATATMP=`tmp_path'"' _n
		*file write `f' `""`stata_path'" /e /q do "`do_file'" %1 ^&exit "' _n
		file write `f' `""`stata_path'" do "`do_file'" %1 ^&exit "' _n
		file write `f' `"popd"' _n
		file write `f' `"exit"' _n
		file close `f'
		conf file "`batch_fn'"
	}


// --------------------------------------------------------------------------
// Run processes
// --------------------------------------------------------------------------

	loc num_active 0 // Number of active worker processes
	assert (`num_active' < `max_processes')

	* PROCENV:
	* procenv get -> list all env vars
	* procenv get STATATMP
	* procenv set STATATMP=XYZ

	if ("`method'" == "windows-procexec") {
		scalar PROCEXEC_HIDDEN = 2 // >= 1 : Minimized ; ==2 : Completely hidden
		scalar PROCEXEC_ABOVE_NORMAL_PRIORITY = 0
		procenv set STATATMP=`tmp_path'
	}
	global pids

	loc num_tasks 0
	loc num_done 0
	loc global_rc 0

	foreach val of local values {
		loc ++num_tasks
		loc started`val' 0
		loc done`val' 0
	}
	if (`verbose') di as text " - Number of tasks{col 24}: {res}`num_tasks'"
	if (`verbose') di as text ""

	while (1) {

		* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		* Stop when all tasks have been started and completed
		* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		if (`num_done' == `num_tasks') continue, break

		* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		* Launch new processes until num_active==max_processes
		* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		foreach val of local values {
			if (`started`val'') continue
			if (`num_active' == `max_processes') continue, break

			if (`verbose') di as text "Starting task `val'"
			loc started`val' 1
			loc ++num_active
			loc rc`val' 0 // So it has a default in case it never launches/completes

			if ("`method'" == "windows-shell") {
				winexec "`batch_fn'" `val'
			}
			else if ("`method'" == "windows-procexec") {
				*di as error `"procexec "`do_file'" `val'"'
				*procexec "`do_file'" `val'
				procexec "`stata_path'" do "`do_file'" `val'
				loc pid`val' = r(pid)
				global pids $pids `pid`val''
			}
			else if ("`method'" == "unix-shell") {
				* PROBLEM:
				* The first tells Stata to run in batch mode. Stata will execute the commands in filename.do and will automatically save the output in filename.log.
				* https://www.stata.com/support/faqs/unix/batch-mode/
				shell "`stata_path'" -q do "`do_file'" `val' // & ????
				* OR JUST USE XSTATA??
			}
			else {
				di as error "Unsupported method: `method'"
				error 1000
			}
		}

		* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		* Check if some processes are done
		* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		foreach val of local values {

			if (!`started`val'' | `done`val'') continue
			
			* Check if the sentinel file exists
			loc padded_worker_id = string(`val', "%08.0f")
			loc sentinel "`parallel_dir'/`padded_worker_id'.txt"
			cap conf file "`sentinel'"
			
			if !c(rc) {

				loc ++num_done
				loc done`val' 1

				file open `f' using "`sentinel'", read text
				file read `f' rc`val'

				if (`rc`val'') {
					di as error " - Task `val' failed (error code `rc`val'')"
					loc global_rc `rc`val''
				}
				else {
					if (`verbose') di as text " - Task `val' completed (`num_done'/`num_tasks')"
					loc pid `pid`val''
					global pids : list global(pids) - local(pid)
				}
				loc --num_active
				file close `f'
				cap erase "`sentinel'"
				continue
			}

			* Check if the process is not running anymore
			_assert ("`pid`val''" != ""), msg("PID IS EMPTY?")
			cap procwait `pid`val'' // returns error if process does not exist
			if (!c(rc)) {
				* The process does not exist anymore but no sentinel file exists
				* Maybe the filesystem just needs a bit of time to update, so we'll give it ten tics
				if ("`tics`val''" == "") {
					loc tics`val' 20 // 20*50ms = 1sec
				}
				else if (`tics`val''>0) {
					loc --tics`val'
				}
				else {
					assert `tics`val'' == 0
					loc ++num_done
					loc done`val' 1
					di as error " - Task `val' does not exist anymore (process id was `pid`val'')"
					loc global_rc 9999
					loc --num_active

					* TODO: maybe move this to a separate routine/mata program to avoid duplication
					* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
					if (`logtable') {
						* TODO: Make it a proper table
						di as text _n "{hline 64}"
						foreach val of local values {
							loc padded_worker_id = string(`val', "%08.0f")
							loc log "`parallel_dir'/`padded_worker_id'.log"
							conf file "`log'"
							*ViewLog using "`log'"
							loc color = cond(`rc`val'', "err", "txt")
							di as text `"`padded_worker_id' |  {`color'}`rc`val''{txt} | {stata `"type "`log'""':type log} | {stata `"view "`log'""':view log}"'
						}
						di as text "{hline 64}" _n 
					}
					* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

					error 9999
				}
			}

		}

		* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		* Introduce some delay ...
		* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		sleep 50

	}

	* Cleanup
	if (`verbose') di as text "All tasks completed"
	if ("`method'" == "windows-procexec") {
		scalar drop PROCEXEC_HIDDEN
		scalar drop PROCEXEC_ABOVE_NORMAL_PRIORITY
		procenv set STATATMP=`c(tmpdir)'
	}
	if (`verbose') di


// --------------------------------------------------------------------------
// Output log
// --------------------------------------------------------------------------
	if (`logtable') {
		* TODO: Make it a proper table
		di as text _n "{hline 64}"
		foreach val of local values {
			loc padded_worker_id = string(`val', "%08.0f")
			loc log "`parallel_dir'/`padded_worker_id'.log"
			conf file "`log'"
			*ViewLog using "`log'"
			loc color = cond(`rc`val'', "err", "txt")
			di as text `"`padded_worker_id' |  {`color'}`rc`val''{txt} | {stata `"type "`log'""':type log} | {stata `"view "`log'""':view log}"'
		}
		di as text "{hline 64}" _n 
	}

	if (`clean') {
		cap noi mata : unlink_folder("`parallel_dir'", `verbose')
	}


// --------------------------------------------------------------------------
// Fail if there was at least one error
// --------------------------------------------------------------------------
	error `global_rc'

end


capture program drop ViewLog
program define ViewLog
	syntax using
	di as result "{hline 80}"
	di as result %~80s "beginning of file -`using'-"
	di as result "{hline 80}"
	type `"`using'"'
	di as result "{hline 80}"
	di as result %~80s "end of file -`using'-"
	di as result "{hline 80}"

end



// --------------------------------------------------------------------------
// Mata section
// --------------------------------------------------------------------------
include "ftools_type_aliases.mata", adopath

mata:

`Void' filefilter(`String' source, `String' dest, `StringRowVector' from, `StringRowVector' to)
{
	`Integer' 		i, n
	`Integer'		fh_in, fh_out
	`String' 		line, eol

	fh_in  = fopen(source, "r")
	fh_out = fopen(dest, "w")
	eol = ""
	n = cols(from)
	assert(n==cols(to))

	while ( (line = fget(fh_in) ) != J(0, 0, "") ) {
		for (i=1; i<=n; i++) {
			line = subinstr(line, from[i], to[i])
		}
	    fput(fh_out, line + eol)
	}

	fclose(fh_out)
	fclose(fh_in)
}

end
