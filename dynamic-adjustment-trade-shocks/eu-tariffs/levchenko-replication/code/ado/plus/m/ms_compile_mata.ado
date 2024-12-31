*! version 2.9.0 28mar2017
/*
MS_COMPILE_MATA: Compile a Mata library (.mlib), if needed

USAGE:

1) In xyz.ado:

	-------------------------------------------------------------------------
	*! version 1.2.3 31dec2017

	program xyz
		...
		ms_get_version xyz
		ms_compile_mata, package(xyz) version(`package_version')
		...
	end
	-------------------------------------------------------------------------


2) In xyz.mata:

	-------------------------------------------------------------------------
	ms_get_version xyz // stores version of the ado in local `package_version'
	assert("`package_version'" != "")
	mata: string scalar xyz_version() return("`package_version'")
	mata: string scalar xyz_stata_version() return("`c(stata_version)'")
	...
	-------------------------------------------------------------------------

ADVANCED SYNTAX:

	ms_compile_mata, PACKage(...) VERsion(...) [FUNctions(...) VERBOSE FORCE DEBUG]

		functions:	list of Mata functions from xyz.mata that will be added
					to the .mlib. Default is all functions: *()

		force:		always compile the package and create a new .mlib
					By default, this only happens if the mlib doesn't exist
					or if the package versions and Stata versions disagree
					with what the .mlib has stored


NOTE:	the names of the .mata and .ado files can be different
		(in fact, ms_compile_mata doesn't know the name of the .ado!)

ACKNOWLEDGEMENT: based on code from David Roodman's -boottest-

*/

program ms_compile_mata
	syntax, PACKage(string) VERsion(string) [FUNctions(string)] [VERBOSE] [FORCE] [DEBUG]
	loc force = ("`force'" != "")

	if (!`force') {
		Check, package(`package') version(`version') `verbose'
		loc force = s(needs_compile)
	}

	if (`force') {
		Compile, package(`package') version(`version') functions(`functions') `verbose' `debug'
	}
end


program Check, sclass
	syntax, PACKage(string) VERSion(string) [VERBOSE]
	loc verbose = ("`verbose'" != "")

	loc package_version = "`version'"
	loc stata_version = c(stata_version)
	loc joint_version = "`package_version'|`stata_version'"
	
	loc mlib_package_version = "???"
	loc mlib_stata_version = "???"
	loc mlib_joint_version = "???"


	// Jointly check if the package and Stata versions are the same

	cap mata: mata drop `package'_joint_version()
	cap mata: st_local("mlib_joint_version", `package'_joint_version())
	_assert inlist(`c(rc)', 0, 3499), msg("`package' check: unexpected error")

	if ("`mlib_joint_version'" == "`joint_version'") {
		sreturn local needs_compile = 0
		exit
	}

	 // Does the MLIB has the same version as the one stated in the ADO?

	cap mata: mata drop `package'_version()
	cap mata: st_local("mlib_stata_version", `package'_stata_version())
	_assert inlist(`c(rc)', 0, 3499), msg("`package' check: unexpected error")

	if ("`mlib_stata_version'" != "`stata_version'") {
		if (`verbose') di as text "(existing l`package'.mlib compiled with Stata `mlib_stata_version'; need to recompile for Stata `stata_version')"
		sreturn local needs_compile = 1
		exit
	}

	 // Was the MLIB compiled with the current version of Stata?

	cap mata: mata drop `package'_stata_version()
	cap mata: st_local("mlib_package_version", `package'_version())
	_assert inlist(`c(rc)', 0, 3499), msg("`package' check: unexpected error")

	if ("`mlib_package_version'" != "`package_version'") {
		if (`verbose') di as text `"(existing l`package'.mlib is version "`mlib_package_version'"; need to recompile for "`package_version'")"'
		sreturn local needs_compile = 1
		exit
	}
end


program Compile
	syntax, PACKage(string) VERSion(string) [FUNctions(string)] [VERBOSE] [DEBUG]
	loc verbose = ("`verbose'" != "")
	loc debug = ("`debug'" != "")
	if ("`functions'"=="") loc functions "*()"

	loc stata_version = c(stata_version)

	mata: mata clear
	
	* Delete any preexisting .mlib
	loc mlib "l`package'.mlib"
	cap findfile "`mlib'"
	while (c(rc)!=601) {
	        * Try to delete file
	        cap erase "`r(fn)'"
	        
	        * Catch exception when file is read-only
	        if c(rc)==608 {
	        	di as error "(warning: file `r(fn)' is read-only; skipping delete)"
	        	continue, break
	        }
	        * Abort in case of other errors
	        else if c(rc) {
	        	di as error "Cannot delete `r(fn)'; error `c(rc)'; aborting"
	        	error `c(rc)'
	        }

	        * Check if the mlib file still persists somewhere (error 601: file not found)
	        cap findfile "`mlib'"
	}

	* Run the .mata
	if (`verbose') di as text "(compiling l`package'.mlib for Stata `stata_version')"
	qui findfile "`package'.mata"
	loc fn "`r(fn)'"
	run "`fn'"

	if (`debug') di as error "Functions available for indexing:"
	if (`debug') mata: mata desc
	
	* Find out where can I save the .mlib
	* Try directories in order specified by S_ADO, skipping BASE/SITE/OLDPLACE/"."
	* If all fail, then try current working directory (".")
	tokenize `"$S_ADO"', parse(";")
	local ok 0
	while (!`ok') {

		local path `"`1'"'
		if `"`path'"'=="PLUS" local path `"`c(sysdir_plus)'"'
		else if `"`path'"'=="PERSONAL" local path `"`c(sysdir_personal)'"'
		
		* Skip directories in S_ADO that do no exist or are not accessible
		mata : st_local("dir_ok", strofreal(direxists(`"`path'"')))
		if `dir_ok'==0 & `"`1'"' != ""{
			macro shift
			continue
		}
		
		if !inlist(`"`path'"',".","") TrySave `"`path'"' "`1'" "`package'" "`functions'" `debug' `verbose'
		
		* Final effort after reaching end of S_ADO: try installing to current directory
		if(`"`1'"' == "" & !`ok') {
			TrySave "." "current path" "`package'" "`functions'" `debug' `verbose'
			
			if (!`ok') {
				di as error "Could not compile file; ftools will not work correctly"
				error 123
			}			
		}
		macro shift
	}

end


program TrySave
	args path name package functions debug verbose
	assert "`package'"!=""
	loc random_file = "`=int(runiform()*1e8)'"
	cap conf new file `"`path'/`random_file'"'
	if (c(rc)) {
		di as error `"cannot save compiled Mata file in `name' (`path')"'
		c_local ok 0
		exit
	}
	else {
		loc path "`path'/l/"
		cap conf new file "`path'`random_file'"
		if (c(rc)) {
			mkdir "`path'"
		}

		cap conf new file "`path'l`package'.mlib"

		* Create .mlib
		cap mata: mata mlib create l`package'  , dir("`path'") replace
		if c(rc)==608 {
			c_local ok 0
			exit
		}
		else if c(rc) {
			di as error "could not compile mlib file"
			error 608
		}
		qui mata: mata mlib add l`package' `functions', dir("`path'") complete
		//qui mata: mata mlib add l`package' HDFE() , dir("`path'") complete
		
		* Verify file exists and works correctly
		qui findfile l`package'.mlib
		loc fn `r(fn)'
		if (`verbose') di as text `"(library saved in `fn')"'
		qui mata: mata mlib index

		if (`debug') di as error "Functions indexed:"
		if (`debug') mata: mata describe using l`package'

		c_local ok 1
	}
end
