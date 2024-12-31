*! version 0.8 Oktober 11, 2013 @ 09:42:31
* 0.2 Functionality for constants in IND-Files added
* 0.3 Bug for constants vars in CNEF -> fixed
* 0.4 Some 2007 varnames interfere with IND varnames -> fixed
* 0.5 Adaptions to CNEF 2007
* 0.6 Adaptions to PSID 2009
* 0.7 Adaptions to PSID 2011
* 0.8 Bug-fix: Program doesn't automatically found PSID delivery -> fixed
program psidadd
version 10.0

	// Parse Commandline 
	// ------------------
	
	syntax anything [, CNEFfrom(string) PSIDfrom(string) correct lower ]  ///


	// Hard coded list of identifiers
	// (Update these lists for each data delivery)

	local er ER
	local v  V
	if "`lower'"!="" {
		local er er
		local v  v
	}

	// Hard coded list of identifiers
	// (Update these lists for each data delivery)

	// I try to find the users delivery by myself ...
	local stop 2011
	while `stop' > 1968 {
		capture confirm file `_dta[psidusedir]'/ind`stop'er.dta
		if !_rc {
			local IND ind`stop'er
			local stop = 1968
		}
		local stop = `stop' - 1
	}

	local IDind ///
	  [68] `er'30001 [69] `er'30020 [70] `er'30043 [71] `er'30067  /// 
	  [72] `er'30091 [73] `er'30117 [74] `er'30138 [75] `er'30160  /// 
	  [76] `er'30188 [77] `er'30217 [78] `er'30246 [79] `er'30283  /// 
	  [80] `er'30313 [81] `er'30343 [82] `er'30373 [83] `er'30399  /// 
	  [84] `er'30429 [85] `er'30463 [86] `er'30498 [87] `er'30535  /// 
	  [88] `er'30570 [89] `er'30606 [90] `er'30642 [91] `er'30689  /// 
	  [92] `er'30733 [93] `er'30806 [94] `er'33101 [95] `er'33201  /// 
	  [96] `er'33301 [97] `er'33401 [99] `er'33501 [01] `er'33601  /// 
	  [03] `er'33701 [05] `er'33801 [07] `er'33901 [09] `er'34001  ///
	  [11] `er'34101 

	local IDfam ///
	  [68] `v'3      [69] `v'442    [70] `v'1102   [71] `v'1802   [72] `v'2402  [73] `v'3002    ///  
	  [74] `v'3402   [75] `v'3802   [76] `v'4302   [77] `v'5202   [78] `v'5702    ///  
	  [79] `v'6302   [80] `v'6902   [81] `v'7502   [82] `v'8202   [83] `v'8802    ///  
	  [84] `v'10002  [85] `v'11102  [86] `v'12502  [87] `v'13702  [88] `v'14802   /// 
	  [89] `v'16302  [90] `v'17702  [91] `v'19002  [92] `v'20302  [93] `v'21602   /// 
	  [94] `er'2002  [95] `er'5002  [96] `er'7002  [97] `er'10002 [99] `er'13002  /// 
	  [01] `er'17002 [03] `er'21002 [05] `er'25002 [07] `er'36002 [09] `er'42002  ///
	  [11] `er'47302

	local SQind ///
	  [69] `er'30021 [70] `er'30044 [71] `er'30068 [72] `er'30092 [73] `er'30118 [74] `er'30139  ///
	  [75] `er'30161 [76] `er'30189 [77] `er'30218 [78] `er'30247 [79] `er'30284 [80] `er'30314  /// 
	  [81] `er'30344 [82] `er'30374 [83] `er'30400 [84] `er'30430 [85] `er'30464 [86] `er'30499  /// 
	  [87] `er'30536 [88] `er'30571 [89] `er'30607 [90] `er'30643 [91] `er'30690 [92] `er'30734  /// 
	  [93] `er'30807 [94] `er'33102 [95] `er'33202 [96] `er'33302 [97] `er'33402 [99] `er'33502  /// 
	  [01] `er'33602 [03] `er'33702 [05] `er'33802 [07] `er'33902 [09] `er'34002 [11] `er'34102


	// Catch dirname from psiduse of options 
	// -------------------------------------

	// Catch version of data generating program
	if "`_dta[psidusedir]'" != "" local usetyp psid
	else local usetyp cnef

	// Catch version of this program
	if "`_dta[psidusedir]'" != "" & "`cneffrom'" == "" local addtyp psid
	else if "`_dta[psidusedir]'" != "" & "`cneffrom'" != "" local addtyp cnef
	else if "`_dta[cnefusedir]'" != "" & "`psidfrom'" == "" local addtyp cnef
	else if "`_dta[cnefusedir]'" != "" & "`psidfrom'" != "" local addtyp psid
	
	if "`addtyp'" == "cnef" {
		local using = cond("`cneffrom'"=="","`_dta[cnefusedir]'","`cneffrom'")
		_CNEF `anything' using "`using'", `correct'
		exit
	}

	local using = cond("`psidfrom'"=="","`_dta[psidusedir]'","`psidfrom'")
	tokenize `anything', parse("||")
	while "`1'" != "" {
		if "`1'" == "|" mac shift
		else {
			gettoken newname pairlist :1
			local newnamelist `newnamelist' `newname'
			foreach pair of local pairlist {
				gettoken year var : pair, parse(`"]"') 
				local year `:subinstr local year `"["' `""''  
				local yearlist "`yearlist' `year'"
				local var  `:subinstr local var `"]"' `""''
		
				// Extract vars from ind files
				if inlist(substr("`var'",1,4),"`er'30","`er'31","`er'32","`er'33","`er'34","`er'35")  ///
				  & length("`var'")==7 {
					capture d `var' using "`using'/`IND'"
					if !_rc local keepvars `keepvars' `var'
				}
				else {
					local `year'vars "``year'vars' `var'"
					local famfiles 1
				}
				local `newname' ``newname'' [`year']`var'
			}
			mac shift
		}
	}

	// Uniquify yearlist
	local yearlist: list uniq yearlist

	// Prepare and merge Fam files
	// ---------------------------

	if "`famfiles'" == "1" {
		preserve
		drop _all

		foreach wave of local yearlist {
			
			// Create local for Century
			if `wave' >= 68 local CC 19
			else if  `wave' > 00 & `wave' < 68 local CC 20
			
			// Letters "er" in filenames of years 1994 and later
			local er = cond(`CC'`wave'>=1994,"er","")
			
			// Extract idenifier for wave
			local IDpos: list posof `"[`wave']"' in IDfam
			local ID: word `++IDpos' of `IDfam'
			
			use `ID' ``wave'vars' using "`using'/fam`CC'`wave'`er'"
			
			// Generate CNEF Idenifiers
			if `wave' >= 68 local CC 19
			else if  `wave' > 00 & `wave' < 68 local CC 20
			ren `ID' x11102_`CC'`wave'

			// Save for merging
			sort x11102_`CC'`wave'
			tempfile f`wave'
			quietly save `f`wave''
		}

		// Merge Family Files
		restore
		
		foreach wave of local yearlist {
			if `wave' >= 68 local CC 19
			else if  `wave' > 00 & `wave' < 68 local CC 20
			sort x11102_`CC'`wave'
			quietly merge x11102_`CC'`wave' using `f`wave''  ///
			  , nokeep uniqusing 
			drop _merge
		}

	}

	// Prepare and merge IND file
	// --------------------------

	if "`keepvars'" != "" {
		preserve
		drop _all

		use `er'30002 `er'30001 `keepvars' using "`using'/`IND'"
		
		// Generate CNEF Idenifier
		gen long x11101ll = `er'30001*1000 + `er'30002
		lab var x11101ll "Person idenification number"
		drop `er'30002 `er'30001
		sort x11101ll

		tempfile find
		quietly save `find'
		
		restore
		sort x11101ll
		quietly merge x11101ll using `find', nokeep unique
		drop _merge
	}

	// Rename variables
	// ----------------

	foreach newname of local newnamelist {
		foreach pair of local `newname' {
			gettoken year var : pair, parse(`"]"') 
			local year `:subinstr local year `"["' `""''  
			local var  `:subinstr local var `"]"' `""''
			
			if "`year'" != "" {
				if `year' >= 68 local CC 19
				else if  `year' > 00 & `year' < 68 local CC 20
			}
			else macro drop _CC
			
			ren `var' `newname'`CC'`year'
		}
	}


	// Clean up
	// --------

	foreach newname of local newnamelist {
		local orderlist `orderlist' `newname'*
	}
	quietly ds `orderlist', not
	order `r(varlist)' `orderlist'
	
end


program _CNEF
	syntax anything using/ [, correct] ///

	// CHECK 
	// (This is necessary because 1st data-delivery for 2007
	// introduced ugly inconsitancies. We correct them automatically, here

	forv i = 2005(2)2007 {
		capture d *LL using "`using'/pequiv_`i'"
		if !_rc & "`correct'"=="" {
			di "{err}Found known inconsistency. Consider option correct"
		}
		if !_rc & "`correct'"!="" {
			
			use "`using'/pequiv_`i'.dta", replace
			
			foreach var of varlist *LL {
				ren `var' `=lower("`var'")'
			}
			qui bys x11101ll: keep if _n==1 
			qui save "`using'/pequiv_`i'.dta", replace
		}
	}

	// Create waveslist
	// ----------------

	foreach var of varlist x11102_* {
		local waves `waves' 			/// 
		  `=cond(`=substr(`"`var'"',-4,.)'>=1980,`"`=substr("`var'",-4,.)'"',`""')'
	}

	// Create necessary Lists
	// ----------------------
	
	tokenize `anything', parse("||")
	while "`1'" != "" {
		if "`1'" == "|" mac shift
		else {
			gettoken newname item :1
			local item = trim("`item'")
			local newnamelist `newnamelist' `newname'
			local itemlist `itemlist' `item'
			if `"`=substr(`"`item'"',-2,.)'"' == `"ll"' {
				local consitems `consitems' `item'
			}
			else {
				foreach wave of local waves {
					local `wave'items ``wave'items' `item'_`wave' 
				}
			}
			mac shift
		}
	}

	preserve

	// Prepare files for merging
	// -------------------------
	
	foreach wave of local waves {
	
		use x11101ll x11102_`wave' `consitems' ``wave'items'  /// 
		  using "`using'/pequiv_`wave'", clear

		// Save for merging
		sort x11101ll x11102_`CC'`wave'
		tempfile f`wave'
		quietly save `f`wave''
	}

	// Return to master
	// ----------------

	restore

	// Merge Files
	// ------------

	foreach wave of local waves {
		sort x11101ll 
		quietly merge x11101ll using `f`wave'', unique nokeep update
		drop _merge
	}

	// Rename variables
	// ----------------

	local i 1
	foreach newname of local newnamelist {
		local oldprefix: word `i++' of `itemlist'

		if `"`=substr(`"`oldprefix'"',-2,.)'"' == `"ll"' {
			ren `oldprefix' `newname'
		}
		else {
			foreach wave of local waves {
				ren `oldprefix'_`wave' `newname'`wave'
			}
		}
	}

	// Clean up
	// --------

	foreach newname of local newnamelist {
		local orderlist `orderlist' `newname'*
	}
	quietly ds `orderlist', not
	order `r(varlist)' `orderlist'


end

exit

Author: Ulrich Kohler
Tel +49 (0)30 25491 361
Fax +49 (0)30 25491 360
Email kohler@wzb.eu


