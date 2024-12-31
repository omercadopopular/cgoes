* ===========================================================================
* Parallel do-file
* ===========================================================================
	cap noi cls
	args task_id
	clear all


// --------------------------------------------------------------------------
// Programs
// --------------------------------------------------------------------------

@include_programs
	
capture program drop ViewInfo
program define ViewInfo
	args caller_id
	loc flavor = cond(c(MP), "MP", cond(c(SE), "SE", c(flavor)))
	loc column 16
	di as text "{hline 64}"
	di as text `"Date      {col `column'}: `c(current_date)' - `c(current_time)'"'
	di as text `"Stata     {col `column'}: `c(stata_version)' `flavor' x`c(bit)' (build `c(born_date)')"'
	di as text `"Processors{col `column'}: `c(processors)'/`c(processors_max)'"'
	di as text `"System    {col `column'}: `c(os)' `c(osdtl)' `c(machine_type)'"'
	di as text `"Host      {col `column'}: `c(hostname)' (user: `c(username)')"'
	di as text `"Caller ID {col `column'}: `caller_id'"'
	di as text `"Task   ID {col `column'}: ${padded_task_id}"'
	di as text ""
	di as text "Folders:"
	di as text `" - Temp     {col `column'}: `c(tmpdir)'"'
	di as text `" - Parallel {col `column'}: ${parallel_dir}"'
	di as text `" - Working  {col `column'}: `c(pwd)'"'
	di as text "{hline 64}"
end


// --------------------------------------------------------------------------
// Main code
// --------------------------------------------------------------------------

	* Setup parallel instance
	cap noi set processors @num_processors
	cd @working_path
	sysdir set PERSONAL "@personal"
	sysdir set PLUS "@plus"
	loc caller_id "@caller_id"
	global task_id `task_id'
	global padded_task_id = string(`task_id', "%08.0f")
	global parallel_dir "@parallel_dir"
	set rngstream `=10*`task_id'' // https://www.stata.com/manuals/rsetrngstream.pdf

	* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	loc fn "${parallel_dir}`c(dirsep)'${padded_task_id}.log"
	log using "`fn'", replace text nomsg

	ViewInfo `caller_id'

	cap noi {
	@command
	}
	loc rc = c(rc)
	
	log close _all
	* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

	* Write sentinel file
	loc fn "$parallel_dir/${padded_task_id}.txt"
	file open f using "`fn'", write text replace
	file write f "`rc'"
	file close _all

	* Done!
	exit, clear STATA
