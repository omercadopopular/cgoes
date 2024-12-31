*! version 4.0.0 Oktober 26, 2017 @ 16:24:45
*! Unpacks PSID files and creates Stata dta files

* version 1.0.0 -> distributed on SSC
* version 2.0.0 -> CNEF install added
* version 3.0.0 -> CNEF_long added
* version 4.0.0 -> CNEF no longer publicly available

program psid_install
version 13
	
	syntax [anything] [using/] [, to(string) replace upgrade replacelong replacesingle clean lower cnef longonly ]
	
	local source = cond("`cnef'"=="","PSID","CNEF")

	INSTALL_`source' `0' 
end


program INSTALL_PSID

	syntax [anything] [using/] [, to(string) replace lower]
	
	// Create local with tokenized waves
	_CREATE_WAVELIST, wavelist(`anything')
	local wavelist `r(wavelist)'
	
	quietly {
		if "`using'" == "" | "`using'" == "." local using `c(pwd)'
		if "`to'" == "" | "`to'" == "." local to `c(pwd)'
		local previousfiles: dir `"`using'"' files `"*"'

		// Available PSID-zipfiles in the using directory
		if `"`wavelist'"' == `""' {
			local mh85zip: dir `"`using'"' files `"mh85*.zip"'
			local cah85zip: dir `"`using'"' files `"cah85*.zip"'
			local pidzip: dir `"`using'"' files `"pid*.zip"'
			local indzip: dir `"`using'"' files `"ind*er.zip"'
			local famzip: dir `"`using'"' files `"fam*.zip"'
			local wlthzip: dir `"`using'"' files `"wlth*.zip"'
		}

		// Requested PSID-zipfiles in the using directory
		else {
			foreach wave of local wavelist {
				local year2 = substr("`wave'",-2,2)
				local mh85zip `: dir `"`using'"' files `"mh85_`year2'.zip"''
				local cah85zip `: dir `"`using'"' files `"cah85_`year2'.zip"''
				local pidzip `: dir `"`using'"' files `"pid`year2'*.zip"''
				local indzip `: dir `"`using'"' files `"ind`wave'*.zip"''
				local famzip `famzip' `: dir `"`using'"' files `"fam`wave'*.zip"''
				local wlthzip `wlthzip' `: dir `"`using'"' files `"wlth`wave'*.zip"''
			}
		}

		// Clean and Check Zip-file lists
		foreach type in ind fam wlth pid cah85 mh85 {
			local `type'zip: list clean `type'zip
			local `type'zip: list sort `type'zip

			local zipfiles `zipfiles' ``type'zip' 
		}		

		// Something to do?
		if `"`zipfiles'"' == "" {
			noi di `"{err} Nothing to install"'
			exit 198
		}
	

		// Check existing PSID files in To directory
		foreach type in ind fam wlth pid cah85 mh85 {
			local `type'dta: dir `"`to'"' files `"`type'*.dta"'
		}

		// Clean and Check Dta-file lists
		foreach type in ind fam wlth pid cah85 mh85 {
			local `type'dta: list clean `type'dta
			local `type'dta: list sort `type'dta

			local dtafiles `dtafiles' ``type'dta'
		}		

		// Remove dta-files alread installed from zipfilelist
		local expectedfiles: subinstr local zipfiles ".zip" ".dta", all
		local alreadyinstalled: list expectedfiles & dtafiles
		
		if "`replace'" == "" {
			foreach file of local alreadyinstalled {
				noi di ///
				  `"{res}`file'{txt} already exists in {res}`to'{txt}. Do nothing"'
			}
			local zipfiles: list expectedfiles - alreadyinstalled
			local zipfiles: subinstr local zipfiles ".dta" ".zip", all
		}

		// Something to do?
		if `"`zipfiles'"' == "" {
			noi di `"{txt}Note: All files already installed. Do nothing"'
			exit
		}

		
		local pwd `"`c(pwd)'"'
		local existing_files : dir `"`using'"' files "*"
		
		cd `"`using'"'
		foreach file of local zipfiles {
			
			local upcasedfname = upper(`"`file'"')
			local dofile: subinstr local upcasedfname ".ZIP" ".do"
			local dtafile: subinstr local upcasedfname ".ZIP" ".dta"
			local dtafile = lower(`"`dtafile'"')
			
			local year = substr(`"`file'"',4,4)
			local typ = substr(`"`file'"',1,3)
			
			if "`typ'" == "fam" & "`year'" >= "2007" & !c(SE) {
				di "Stata SE or Stata MP required for `typ'`year'. I skip this"
			}
			else {
				if c(max_k_theory) < 6000 set maxvar 6000

				unzipfile `"`file'"', replace
				
				filefilter  `"`dofile'"' x.do, from([path]\BS) to(./) replace
				filefilter  x.do y.do, from(\Q\Q) to (-) replace
				filefilter  y.do x.do, from(\RQ) to (-) replace
				run x
			
				foreach var of varlist _all {
					lab var `var' `"`=proper(`"`:var lab `var''"')'"'
					if "`lower'" != "" ren `var' `=lower("`var'")'
				}
			}
			
			compress
			save `"`to'/`dtafile'"', replace

			noisily di `"{res}`dtafile'{txt} installed"'
		}
		_CLEANFILES using `"`using'"', to(`to') previousfiles(`previousfiles')
		noi di `"{txt}PSID directory is{res} `to'"'
		cd `"`pwd'"'
	}
end
	

program INSTALL_CNEF 
	syntax using/  [ , cnef to(string) replacelong replacesingle replace upgrade clean longonly ]

	// Define origin and to
	if `"`to'"' == `""' | `"`to'"' == `"."' local to `"`c(pwd)'"'
	local origin `"`c(pwd)'"'
	quietly cd `"`to'"'

	if "`replace'" != "" {
		local replacelong replacelong
		local replacesingle replacesingle
	}

	// Check what's there
	local pequivfiles: dir . files "pequiv*.dta" 
	local pequivlong: dir . files "pequiv_long.dta" 
	if strpos(`"`using'"',`".dta"') | strpos(`"`using'"',`".DTA"') local source long
	else if strpos(`"`using'"',`".zip"') | strpos(`"`using'"',`".ZIP"') local source zip
		
	if `"`source'"' == `"zip"' & `"`pequivlong'"' != `""' & "`upgrade'" == "" {
		display `"{txt}Note: CNEF-long already exist. Use Option -upgrade- to override with a newly downloaded delivery"'
		exit 9
	}

	// Unpack Zip and create pequiv_long.dta 
	else if "`source'" == "zip" {

		capture noisily _CNEF_UNPACK using `using'
		if _rc _CNEF_FAILSAVE, origin(`origin') to(`to') rc(`=_rc')
			
		capture noisily _CNEF_SEARCHSTATA, to(`to')
		if _rc _CNEF_FAILSAVE, origin(`origin') to(`to') rc(`=_rc')

*		capture noisily  _CNEF_CLEANUP
*		if _rc _CNEF_FAILSAVE, origin(`origin') to(`to') rc(`=_rc')
		
	}

	// Split CNEF-long into Files
	if "`longonly'" == "" {
		use pequiv_long.dta, clear
		quietly levelsof year, local(K)
		preserve
		foreach k of local K {
			capture confirm new file pequiv_`k'.dta
			if _rc & "`replacesingle'" == "" {
				noi di ///
				  `"{res}pequiv_`k'.dta{txt} already exists in {res}`to'{txt}. Do nothing"'
			}
			else {
				quietly keep if year == `k'
				quietly keep if !mi(x11102) 
				drop year
				ren *LL *ll

				unab renamevars: _all
				unab llvars: *ll
				local renamvars: list renamevars - llvars
				ren (`renamvars') =_`k'
				
				save pequiv_`k', replace
				restore, preserve
			}
		}
	}
	
	cd `"`origin'"'
end


program  _CLEANFILES
	syntax using/, to(string) previousfiles(string) 
	
	local allfiles : dir `"`using'"' files `"*"'
	if `"`to'"' ==  `"`c(pwd)'"' local dtafiles : dir `"`using'"' files `"*.dta"'

	local erasefiles: list allfiles - dtafiles
	local erasefiles: list erasefiles - previousfiles
	foreach file of local erasefiles {
		erase `"`file'"'
	}
end


program _CREATE_WAVELIST, rclass
	syntax [, wavelist(numlist)]
	return local wavelist `wavelist'
end


program _CNEF_UNPACK
	syntax using/
	capture mkdir __temp
	display "{txt}Copy `using' to temporary directory" _continue
	quietly cd __temp
		
	capture copy `"`using'"' pequiv_long.zip, replace
	if _rc {
		display `"{err} [failed]"' 
			exit _rc
	}
	else display  `"{res} [complete]"'
		
	display "{txt}Extract ZIP file " _continue
	capture unzipfile pequiv_long.zip
	if _rc {
		display `"{err} [failed]"' 
		exit _rc
	}
	else display  `"{res} [complete]"'
	cd ..
end


program _CNEF_FAILSAVE
	syntax , origin(string) to(string) rc(int)
	quietly cd `"`origin'"'
	display `"{err}Installation ended abnormally. Consider erasing directory `"`to'/__temp"' by hand"'
	exit `rc'
end


program _CNEF_SEARCHSTATA
	syntax, to(string)
	pwd
	display `"{txt}Search for CNEF-Long Stata dataset"'_continue
	local subdir: dir . dirs *
	local i 1
	foreach thisdir of local subdir {
		quietly cd `"`thisdir'"' 
		local longname: dir `"."' files `"*.dta"'
		if `"`longname'"' != `""' {
			quietly copy `longname' `"`to'/pequiv_long.dta"', replace
		}
		local erasefiles: dir . files *
		foreach file of local erasefiles {
			rm `"`file'"'
			}
			quietly cd ..
			rmdir `"`thisdir'"'
		}
		quietly cd `"`to'"'
		capture confirm file `"pequiv_long.dta"' 
		if _rc {
			display `"{err}[failed]"' _n `"CNEF-Long Stata dataset not found in Zip-file"'
			quietly cd `"`to'"'
			exit 601
		}
		else display  `"{res}[complete]"'
end

*program _CNEF_CLEANUP
*	pwd
*	display `"{txt}Clean up"' _continue
*	rm __temp/pequiv_long.zip
*	rmdir __temp
*	display  `"{res}[complete]"'
*end

exit
