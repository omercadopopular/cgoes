*! version 2.12  Juli 19, 2019 @ 21:00:11 UK
* 2.11 Better error messages for missing files and wealth vars ..
* 2.10 Main release for SSC and Stata User Meeting
* 1.01 Re-design - psiduse/psidadd -> -psid use- -psid add-/alpha tester version
* 1.02 Various Bug fixes, subprograms vardoc and long added -> First published on SSC
* 1.03 CNEF LL upercase/lowercase problem soved
* 1.04 CNEF LL upercase/lowercase removed in the new data delivery
* 2.00 Updated to PSID delivery 2013
* 2.10 Updated to PSID delivery 2015
* 2.11 Updated to PSID delivery 2017
* 2.12 Bug fix. 

* Selector Program
program psid
version 13.0
	
	syntax anything [using] [, *]
	gettoken subcommand uservars: anything

	if "`subcommand'" == "install" {
		psid_install `uservars' `using', `options'
	}

	else if "`subcommand'" == "vardoc" {
		psid_vardoc `uservars', `options' 
	}

	else if "`subcommand'" == "long" {
		psid_long 
	}
	
	else {
		psid_main `0'
	}
end

* Main psid use/add-
program psid_main
	syntax anything(name=uservars)  ///
	  [using/]  ///
	  [,  ///
	  DOfile(string)  ///
	  Design(string)  ///
	  Ftype(string)  ///
	  Keepnotes  ///
	  Lower  ///
	  Waves(numlist) ///
	  LEVel(string) ///
	  clear ///
	  ]
	gettoken subcommand uservars: uservars
	if "`ftype'" == "" local ftype psid

	// Catch some early errors
	if "`subcommand'" == "add" & "`clear'" != "" {
		display "{txt}Note: option -clear- ignored for -psid add-"
	}
	if "`ftype'" != "psid" & "`waves'" == "" {
		display "{err}Option -waves(numlist)- required for -ftype(`ftype')-"
		exit 198
	}

	if "`using'" == "" local using: char _dta[`ftype'_dir]
	if "`using'" == "" {
		display "{err}`=upper("`ftype'")'-directory unknown: Using required"
		exit 198
	}

	// Update the identifer list in this subprogram for each data delivery
	_SET_DELIVERY `lower' using `"`using'"'
	foreach macname in er v s indfile idind idfam sqind delivery {
		local `macname' `r(`macname')'
	}
	
	// Document a Do-File
	if "`dofile'" != "" {
		_DOC_OPEN `subcommand' `dofile'
		local doc _DOC
	}
	
	// Redesign user list, i.e. [84] varname -> 84:varname
	if "`ftype'" == "psid" {
		local uservars: subinstr local uservars `"["' `""', all
		local uservars: subinstr local uservars `"]"' `":"', all
	
		if `"`:list uservars & sqind'"'  != `""' {
			display ///
			  "{err}Sequence number retained automatically. Remove from input"
			exit 198
		}
	}

	// Design
	if "`subcommand'" == "add" & "`design'" != "" {
		di "{err} design() not allowed for psid add"
		exit 198
	}
	else if "`subcommand'" == "use" & "`design'" == "" local design balanced

	// Create the list of waves to be used
	if "`ftype'" == "cnef" {
		local nonwaves 1998 2000 2002 2004 2006 2008 2010 2012 2014 2016 2018
		local wavelist: list waves - nonwaves
	}
	else if "`ftype'" == "wlth" {
		local availablewaves 1984 1989 1994 1999 2001 2003 2005 2007 2009 2011 2013 2015 2017
		local wavelist: list availablewaves & waves
	}
	else if "`ftype'" == "psid" & "`waves'" != "" {
		di {txt} Waves implied by varname identifiers. Option -waves()- ignored
	}
	else {
		_CREATE_WAVELIST `uservars'
		local wavelist `r(wavelist)'
	}

	// Create variable lists to be retained from year specific files
	_CREATE_VARLISTS_`ftype' `uservars' ///
	  using `"`using'/`indfile'"', wavelist(`wavelist') `lower' 

	if "`ftype'" == "psid" {
		local indvars `r(indvars)'

		local typelist `r(psidftypes)'
		local typ1 fam wlth
		local typ2 cah mh pid
		local vtypes: list typelist & typ1
		local ctypes: list typelist & typ2
		
		foreach psidtype in `vtypes' {
			foreach wave of local wavelist {
				local `psidtype'`wave' `r(`psidtype'`wave')'
			}
		}

		foreach psidtype in `ctypes' {
			local `psidtype'vars `r(`psidtype'vars)'
		}
	}

	else {
		local vtypes `ftype'
		foreach wave of local wavelist {
			local `ftype'`wave' `r(`ftype'`wave')'
		}
	}

	quietly {

		// We now start loading data, so it is time to clear or preserve
		if "`subcommand'" == "use" {
			`doc' `clear'
		}
		else if "`subcommand'" == "add" {
			tempfile master
			`doc' save `master', replace
			`doc' clear
		}
		
		// Retain datasets from yearly files
		foreach filetype of local vtypes {
			foreach wave of local wavelist {
				if "``filetype'`wave''" != "" {
					noi _PROCESS_WAVEFILES_`filetype' ``filetype'`wave'' using `"`using'"' ///
					  , wave(`wave') doc(`doc') idfam(`idfam') `lower'
					tempfile x`filetype'`wave'
					`doc' save `x`filetype'`wave'', replace
					local `filetype'years ``filetype'years' `wave' 
					local mergefiles `mergefiles' x`filetype'`wave'
				}
			}
		}
		
		// Retain datasets from constant files 
		foreach filetype of local ctypes {
			noi _PROCESS_`filetype' ``filetype'vars'  ///
			  using `"`using'"', doc(`doc') `lower' indfile(`indfile') delivery(`delivery') 
			tempfile x`filetype'
			`doc' save `x`filetype'', replace
			local mergefiles `mergefiles' x`filetype'
		}
		
		// I load the indfile to set the design of the dataset. I also retain
		// variables from the indfile if the user asked for them. For CNEF
		// I use the first wave so that users don't have to download
		// the PSID.
		
		// Process indfile
		if "`ftype'" != "cnef" {
			
			if "`ctypes'" != "" {
				local specialyear = substr("`indfile'",4,4)
				local specialyearincluded: list wavelist & specialyear
				if "`specialyearincluded'" == "" local wavelist `wavelist' `specialyear'
			}
			noi _PROCESS_INDFILE `indvars' using `"`using'"' ///
			  , wavelist(`wavelist') design(`design')  ///
			  indfile(`indfile') idind(`idind') sqind(`sqind')  ///
			  doc(`doc') `lower'
		}
		else {

			if "`doc'" != "" {
				file write fout _n _n "// == [ First CNEF file ] == "
			}
			
			gettoken first rest: wavelist

			local ll = cond(inlist(`first',2005,2007),"ll","ll") /// -> Not necessary anymore

			`doc'  use x11101`ll' x11102_`first' `cnef`first'' 	/// 
			  using `"`using'/pequiv_`first'"', clear

			capture d *LL
			if _rc != 111 `doc' rename *LL *ll
 			`doc'  sort x11101ll 
		}
		
		
		// IV Merge Files
		// --------------
		
		// Merge requested files
		if "`dofile'" != "" {
			file write fout _n _n "// == [ Merge files] == "
		}
		
		local i 1

		local mflist     cnef fam wlth pid  cah   mh
		local mtlist     1:1 m:1 m:1  m:1  1:m  1:m
		local mklist `" `" "'   `"1 3 4 5"'  `"1 3 4 5"' `"1 3 4 5"' `"1 3 4 5"' `"1 3 4 5"' "'
		local mvlist    01ll  02  02 01ll 01ll 01ll
		
		foreach file of local mergefiles {
			foreach typ in cnef fam wlth pid cah mh {
				if strpos("`file'","`typ'")  ///
				  local listpos: list posof "`typ'" in mflist
			}
			local mergevar: word `listpos'  of `mvlist'
			local mergetype: word `listpos' of `mtlist'
			local keeptype: word `listpos'  of `mklist'
			local suffix = cond( ///
			  strpos("`file'","fam") | strpos("`file'","wlth"),  ///
			  `"_`=substr(`"`file'"',-4,.)'"',"")
				
			
			`doc' merge `mergetype' x111`mergevar'`suffix' using ``file'' ///
			  , keep(`keeptype') update
			`doc' drop _merge
		}
		
		if "`subcommand'" == "use" & "`ftype'" == "cnef" & "`design'" != "any" {
			_CNEF_DESIGN `design', wavelist(`wavelist') doc(`doc')
		}
		
		// V Rename Variables
		_RENAME_`ftype' `uservars' , doc(`doc') `keepnotes' `lower' ///
		  wavelist(`wavelist') 
		
		// Merge file to previous master file
		if "`subcommand'" == "add" {
			tempfile addfile
			`doc' save `addfile', replace
			`doc' use `master'
			`doc' merge 1:1 x11101ll using `addfile', update keep(1 3 4 5)
			capture assert _merge != 5
			if _rc {
				count if _merge==5
				local explanation In the data you added are {res}`r(N)'{txt}  ///
				  observations with different values in one of the overlapping  ///
				  variables. This is odd and indicates  ///
				  a serious problem. However, if you added CNEF data to   ///
				  PSID data, or vice versa, there is a known mismatch of the  ///
				  household identification numbers for very few observations  ///
				  In this case you may proceed, but be aware that values of  ///
				  the household number for at least one survey year of  ///
				  {res}`r(N)'{txt} observations would be different  ///
				  if you had interchanged -psid use- and -psid add-.

				noi display  `"{txt}Note: Merge conflict in overlapping variables."' 
			   noi display in smcl `"{p 4 4 8}{txt}`explanation'"'
			
				gen byte _MERGECONFLICT = _merge>=5
				noi display  _n ///
				  `"{txt}Variable {res}_MERGECONFLICT{txt} added to investigate the problem"'
			}
			drop _merge
		}
	}
	
	// VI Clean up
	// -----------
	
	if "`dofile'" != "" _DOC_CLOSE `dofile'

	char define _dta[psid_keepnotes] `=cond("`keepnotes'" == "",0,1)' 
	
	if "`subcommand'" == "use" {
		char _dta[`ftype'_dir] `"`using'"'
	}	
end


* Subprograms Section

** Extract the waves involved in the retrival
program _CREATE_WAVELIST, rclass
	syntax anything(name=uservars)

	local uservars: subinstr local uservars ":" ": ", all
	local uservars: list uniq uservars 
	forv hypowave=1968/2030 {
		local hypowavelist `hypowavelist' `=substr("`hypowave'",-2,2)':
	}

	local wavestamp: list uservars & hypowavelist
	local wavestamp: subinstr local wavestamp ":" "", all
	
	foreach wave of local wavestamp {
		local wavelist `wavelist' `=cond(`wave'>=68,19`wave',20`wave')'
	}
	return local wavelist `wavelist'
end

** 2. Extract the list of Identifiers to be used
program _CREATE_IDENTIFIERS, rclass
	syntax anything(name=wavelist), idind(string) sqind(string)

	local idind: subinstr local idind ":" ": ", all
	local sqind: subinstr local sqind ":" ": ", all
	
	foreach wave of local wavelist {
		
		local indpos: list posof `"`=substr("`wave'",3,2)':"' in idind
		local idused `idused' `: word `++indpos' of `idind''
		if "`wave'" != "1968" {
			local sqpos: list posof `"`=substr("`wave'",3,2)':"' in sqind
			local sqused `sqused' `: word `++sqpos' of `sqind''
		}
	}
	return local idused `idused'
	return local sqused `sqused'
end

** 3. Create variable lists from different file types of Data Center
program _CREATE_VARLISTS_psid, rclass
	syntax anything(name=uservars) using ///
	  ,  [ wavelist(numlist) lower * ]
	
	foreach stub in er s mh cah pid {
		local `stub' = cond(`"`lower'"' == `""' ///
		  ,`"`=upper(`"`stub'"')'"' ///
		  ,`"`=lower(`"`stub'"')'"')
	}
	
	local uservars : subinstr local uservars "|| " "||", all
	local uservars : list sort uservars
	gettoken uservars: uservars, parse("||")

	local wavelist " `wavelist'"
	local yeartags: subinstr local wavelist " 19" " ", all
	local yeartags: subinstr local yeartags " 20" " ", all
	local yeartags: list sort yeartags
	local yeartags `"`yeartags' `" "' "' 
	
	local psidwlth 0
	local psidmh 0
	local psidcah 0
	local psidpid 0
	local psidfam 0

	foreach tag in `yeartags' {

		local tag = trim(`"`tag'"')
		if "`tag'" != "" local wave = cond(`tag'>=68,"19`tag'","20`tag'")
		
		local uservars: subinstr local uservars " `tag':" "`tag':", all
		gettoken proposed uservars: uservars 
		local proposed: subinstr local proposed "`tag':" " ", all

		// Extract  vars from fyle types
		foreach var of local proposed {

			// Indfiles
			if  inlist(substr("`var'",1,4),"`er'30","`er'31","`er'32","`er'33","`er'34","`er'35")  ///
			  & ( length("`var'")==7 | length("`var'")==8 ) {
				local indvars `indvars' `var'
			}
			
			// Marriage History files 
			else if  substr("`var'",1,2) == "`mh'" {
				if `psidmh' == 0 {
					local psidmh 1
					local psidftypes `psidftypes' mh
				}
				local mhvars `mhvars' `var'
			}

			// Childhood and Adoption history files 
			else if  substr("`var'",1,3) == "`cah'" {
				if `psidcah' == 0 {
					local psidcah 1
					local psidftypes `psidftypes' cah
				}
				local cahvars `cahvars' `var'
			}

			// Parent Identification files  
			else if  substr("`var'",1,3) == "`pid'" {
				if `psidpid' == 0 {
					local psidpid 1
					local psidftypes `psidftypes' pid
				}
				local pidvars `pidvars' `var'
			}

			// Wealth files
			else if  substr("`var'",1,1) == "`s'" {
				if `psidwlth' == 0 {
					local psidwlth 1
					local psidftypes `psidftypes' wlth
				}
				local wlth`wave' `wlth`wave'' `var'
			}

			// Fam files
			else {
				if `psidfam' == 0 {
					local psidfam 1
					local psidftypes `psidftypes' fam
				}
				local fam`wave' `fam`wave'' `var'
			}
		}
		return local fam`wave' `fam`wave''
		return local wlth`wave' `wlth`wave''
	}
	return local indvars `indvars'
	return local pidvars `pidvars'
	return local cahvars `cahvars'
	return local mhvars `mhvars'
	return local psidftypes `psidftypes'
end

** Create CNEF varlists
program _CREATE_VARLISTS_cnef, rclass
	syntax anything(name=uservars) [using], wavelist(numlist) * 

	local uservars: subinstr local uservars "||" "", all

	tokenize `uservars'
	while "`1'" != "" {
		local item `2'
		if `"`=substr(`"`item'"',-2,.)'"' == `"ll"' |  /// 
			  `"`=substr(`"`item'"',-2,.)'"' == `"LL"' {
			local indvars `indvars' `item'
		}
		else {
			foreach wave of local wavelist {
				local cnef`wave' `cnef`wave'' `item'_`wave' 
			}
		}
		mac shift 2
	}

	foreach wave of local wavelist {

		// Indvars LL/ll is upper case in waves 2005 and 2007, but lower case in other years
*		if inlist(`wave',2005,2007) local indvars: subinstr local indvars "ll" "LL", all
*		else local indvars: subinstr local indvars "LL" "ll", all
		return local cnef`wave' `indvars' `cnef`wave''
	}
end


** 10. Wealthvars -> symplified syntax only
program _CREATE_VARLISTS_wlth, rclass
	syntax anything(name=uservars) [using], wavelist(string) [ lower *]

	local s =cond("`lower'" == "","S","s")
	
	// Create a list of Prefixes used
	local years 1984 1989 1994 1999 2001 2003 2005 2007
	local prefixes 1 2 3 4 5 6 7 8
	
	local uservars: subinstr local uservars "||" "", all
	tokenize `uservars'

	while "`1'" != "" {
		foreach wave of local wavelist {
			local pos: list posof "`wave'" in years
			local prefix :word `pos' of `prefixes'
			local wlth`wave' `wlth`wave'' `s'`prefix'`2'
		}
		mac shift 2
	}
	
	foreach wave of local wavelist {
		local pos: list posof "`wave'" in years
		local prefix :word `pos' of `prefixes'
		return local wlth`wave' `s'`prefix'01 `wlth`wave''
	}
end


** 4. Load variables of famfily file and prepare for merging
program _PROCESS_WAVEFILES_fam
	syntax anything(name=wavevars)  ///
	  using/ ///
	  , wave(integer) idfam(string) [doc(string) *]

	// Letters "er" in filenames of years 1994 and later
	local ER = cond(`wave'>=1994,"er","")
	
	// Extract idenifier for wave
	local yeartag = substr("`wave'",-2,2)
	
	local idfam: subinstr local idfam `":"' `": "', all
	local idusedpos: list posof `"`yeartag':"' in idfam
	local idused: word `++idusedpos' of `idfam'
	
	// Heading for Do-File, if any
	if "`doc'" != "" {
		file write fout _n _n "// == [ Family file `wave' ] == "
	}
	
	`doc' use `idused' `wavevars' using `"`using'/fam`wave'`ER'"', clear
		`doc' ren `idused' x11102_`wave'
		`doc' replace x11102_`wave' = . if x11102_`wave'==0
	`doc' sort x11102_`wave'
end

** 5. Load variables of wealth file and prepare for merging
program _PROCESS_WAVEFILES_wlth
	syntax anything(name=wavevars) using/,  wave(integer) [ lower doc(string) *]

	local s =cond("`lower'" == "","S","s")

	capture confirm file `"`using'/wlth`wave'.dta"'
	if _rc {
		noi di `"{err}Variable list requires wlth`wave', but wlth`wave' is not installed"'
		exit 601
	}

	// Heading for Do-File, if any
	if "`doc'" != "" {
		file write fout _n _n "// == [ Wealth file `wave' ] == "
	}
	
	`doc' use `s'?01 `wavevars' using `"`using'/wlth`wave'"', clear
	`doc' ren `s'?01 x11102_`wave'
	`doc' replace x11102_`wave' = . if x11102_`wave' == 0
		`doc' sort x11102_`wave'
	
end

** 6. Load variables from Childhood and Adaption History and prepare for merging
program _PROCESS_cah
	syntax anything(name=wavevars) using/, indfile(string)  [lower doc(string) *]

	local cah = cond("`lower'"=="","CAH","cah")	
	local cahfile cah85_`=substr("`indfile'",6,2)'.dta

	capture confirm file `"`using'/`cahfile'"'
	if _rc {
		di `"{err}Variable list requires `cahfile', but `cahhfile' is not installed."'
		exit 601
	}
	
	// Heading for Do-File, if any
	if "`doc'" != "" {
		file write fout _n _n "// == [ Marriage history] == "
	}
	
	`doc' use `cah'1 `cah'2 `cah'3 `wavevars'  ///
	  using `"`using'/`cahfile'"', clear
	`doc' gen long x11101ll =`cah'2*1000 + `cah'3
	`doc' drop `cah'2 `cah'3
	`doc' lab var x11101ll "Person identification number"
end

** 6. Load variables of Marriage Histories and prepare for merging
program _PROCESS_mh
	syntax anything(name=wavevars) using/, indfile(string) [lower doc(string) *]

	local mh = cond("`lower'"=="","MH","mh")
	local mhfile mh85_`=substr("`indfile'",6,2)'.dta

	capture confirm file `"`using'/`mhfile'"'
	if _rc {
		di `"{err}Variable list requires `mhfile', but `mhfile' is not installed"'
		exit 601
	}
	
	// Heading for Do-File, if any
	if "`doc'" != "" {
		file write fout _n _n "// == [ Marriage history] == "
	}
	
	`doc' use `mh'1 `mh'2 `wavevars' using `"`using'/`mhfile'"', clear
	`doc' gen long x11101ll =`mh'1*1000 + `mh'2
	`doc' drop `mh'1 `mh'2
	`doc' lab var x11101ll "Person identification number"
end

** 6. Load variables from Parent Identification file and prepare for merging
program _PROCESS_pid
	syntax anything(name=wavevars) using/,  ///
	  indfile(string) delivery(string) [lower doc(string) *]

	local pid = cond("`lower'"=="","PID","pid")
	local pidfile pid`=substr("`indfile'",6,2)'.dta

	capture confirm file `"`using'/`pidfile'"'
	if _rc {
		di `"{err}Variable list requires `pidfile', but `pidhfile' does  not exist."'
		exit 601
	}
	
	// Heading for Do-File, if any
	if "`doc'" != "" {
		file write fout _n _n "// == [ Marriage history] == "
	}

	local intnr = cond(`delivery' < 2013,"`pid'1","`pid'2")
	local persnr = cond(`delivery' < 2013,"`pid'2","`pid'3")
	
	`doc' use `intnr' `persnr' `wavevars' using `"`using'/`pidfile'"', clear
	`doc' gen long x11101ll =`intnr'*1000 + `persnr'
	`doc' drop `intnr' `persnr'
	`doc' lab var x11101ll "Person identification number"
end

** 6. Load variables of CNEF file and prepare for merging
program _PROCESS_WAVEFILES_cnef
	syntax anything(name=wavevars) using/ , wave(integer) [doc(string) *]

	// Heading for Do-File, if any
	if "`doc'" != "" {
		file write fout _n _n "// == [ CNEF file `wave' ] == "
	}
	
	local ll = cond(inlist(`first',2005,2007),"LL","ll") 

	`doc' use x11101`ll' x11102_`wave' `wavevars' /// 
	  using `"`using'/pequiv_`wave'"'

	capture d *LL
	if _rc != 111 `doc' rename *LL *ll

	// I drop the known dublicates from x11101ll
	if `wave' == 2005 duplicates drop x11101ll, force
	
	`doc' sort x11101ll x11102_`wave'
end


** 5. Create design and autogenerated Standard variables
program _PROCESS_INDFILE
	syntax [anything(name=indvars)] using/ ///
	  ,  [ design(string) wavelist(string)   ///
	  idind(string) sqind(string) indfile(string) lower doc(string)]

	local er =cond("`lower'" == "","ER","er")
	
	// Extract the list of identifiers
	_CREATE_IDENTIFIERS `wavelist', idind(`idind') sqind(`sqind')
	local idused `r(idused)'
	local sqused `r(sqused)'

	if "`doc'" != "" {
		file write fout _n _n "// == [ Individual file ] == "
	}

	`doc' use `er'30002 `er'30001 `idused' `sqused' `indvars'  ///
	  using `"`using'/`indfile'"'
	
	// CNEF Idenifier
	`doc' gen long x11101ll = `er'30001*1000 + `er'30002
	`doc' lab var x11101ll "Person identification number"
	
	local i 1
	local j 1
	foreach wave of local wavelist {
			`doc' ren `: word `i++' of `idused'' x11102_`wave'
			`doc' replace x11102_`wave' = . if x11102_`wave' == 0
		if `wave' > 1968 {
			`doc' ren `: word `j++' of `sqused'' xsqnr_`wave'
		}
	}
	
	// Design
	tempvar g
	`doc' gen byte `g' = 0
	foreach wave of local wavelist {
		
		if "`wave'" == "1968" {
			`doc' replace `g' = `g' + 1  ///
			  if inrange(x11102_1968,1,2930) | inrange(x11102_1968,5001,6872)
		}
		else {
			`doc' replace `g' = `g' + 1  ///
			  if inrange(xsqnr_`wave',1,20) | inrange(xsqnr_`wave',81,89)
		}
	}
	
	capture confirm integer number `design'
	if !_rc {
		`doc' keep if `g' >= `design'
		noi di as text _n "Kept households interviewed " ///
		  as result `design' as text " times or more"
	}
	else if "`design'"=="balanced" | "`design'" == "" {
		local wavecount: word count `wavelist'
		`doc' keep if `g' == `wavecount'
		noi di as text "Balanced panel design"
	}
	else noi di as text _n "All observations kept"
	`doc' drop `g'

	`doc' capture drop `er'30002
	`doc' capture drop `er'30001
	
	
end


** 6. Program to Document a command in a Do-File
program _DOC
	`0'
	file write fout _n `"`0'"'
end

** 7. Rename Variable and Order them according to user Input
program _RENAME_cnef
	
	syntax anything [, doc(string) keepnotes  ///
	  wavelist(numlist) *]
		
	if "`doc'" != "" {
		file write fout _n _n "// == [ Rename Variables ] == "
	}
	
	local pairlist: subinstr local anything "||" "", all 
		
	tokenize `pairlist'
	while "`1'" != "" {
		if `"`=substr(`"`2'"',-2,.)'"' == `"ll"' {
			`doc' ren `2' `1'
			if "`keepnotes'" != "" {
				`doc' char define `1'`wave'[items1] CNEF `2'
			}
			local orderlist `orderlist' `1'
		}
		else {
			foreach wave of local wavelist {
				`doc' ren `2'_`wave' `1'`wave'
				if "`keepnotes'" != "" {
				`doc' char define `1'`wave'[items1] CNEF `2'
				}
			}
			local orderlist `orderlist' `1'*
		}
		mac shift 2
	}
		
	if "`doc'" != "" file write fout _n _n  ///
	  "// == [ Make nice order ]== "
	
	`doc' order x11101ll x11102*  `orderlist'
end

** Rename Wlth
program _RENAME_wlth

	syntax anything [, doc(string) keepnotes  ///
	  wavelist(numlist) lower]

	local s =cond("`lower'" == "","S","s")
	
	if "`doc'" != "" {
		file write fout _n _n "// == [ Rename Variables ] == "
	}

	// Create a list of Prefixes used
	local years 1984 1989 1994 1999 2001 2003 2005 2007
	local prefixes 1 2 3 4 5 6 7 8
		
	local pairlist: subinstr local anything "||" "", all 
		
	tokenize `pairlist'
	while "`1'" != "" {
		local orderlist `orderlist' `1'*

		foreach wave of local wavelist  {
			local pos: list posof "`wave'" in years
			local prefix :word `pos' of `prefixes'
			
			`doc' ren `s'`prefix'`2' `1'`wave'
			if "`keepnotes'" != "" {
				`doc' char define `1'`wave'[items1] `s'`prefix'`2'
			}
		}
		mac shift 2
	}

	if "`doc'" != "" file write fout _n _n  ///
	  "// ===[ Make nice order ]====================="
	
	`doc' order x11101ll x11102* xsqnr* `orderlist'
end

** Rename PSID
program _RENAME_psid
	syntax anything [, doc(string) keepnotes  ///
	  wavelist(numlist) *]

	if "`doc'" != "" {
		file write fout _n _n "// == [ Rename Variables ] == "
	}

	tokenize `anything', parse("||")
	while "`1'" != "" {
		if "`1'" == "|" mac shift
		
		else {
			gettoken newname pairlist :1
			local orderlist `orderlist' `newname'*
			
			foreach pair of local pairlist {
				
				gettoken year var : pair, parse(`":"') 
				if "`year'" == ":" macro drop _year
				else gettoken colon var : var, parse(":")
				
				if "`year'"!=""  ///
				  local wave = cond(inrange(`year',68,99),19`year',20`year')
				else macro drop _wave
				`doc' ren `var' `newname'`wave'
				if "`keepnotes'" != ""  ///
				`doc' char define `newname'`wave'[items1] `var'
			}
		}
		mac shift
	}
	
	`doc' order x11101ll x11102*  xsqnr_* `orderlist'
end
	

** 8. Design for cnef is different
program _CNEF_DESIGN

	syntax anything(name = design), wavelist(string) [doc(string)]

	if "`doc'" != "" {
		local _DOC `doc'
		file write fout _n _n "// [ Define Design ]"
	}

	capture confirm integer number `design'

 	if !_rc {
		tempvar g
		`doc' gen byte `g' = 0
		foreach var of varlist x11102* {
			`doc' replace `g' = `g' + 1 if !mi(`var') 
		}
		`doc' keep if `g' >= `design'
	}
	
	else if "`design'"=="balanced" {
		tempvar g
		local wavecount: word count `wavelist'
		`doc' gen byte `g' = 0
		foreach var of varlist x11102*  {
			`doc' replace `g' = `g' + 1 if !mi(`var')
		}
		`doc' keep if `g' == `wavecount'
	}
	`doc' drop `g'
end


** Initialize documentation
program _DOC_OPEN
	syntax anything(name=dofile) [, replace append force add use]

	gettoken add dofile: dofile
	
	if "`add'" == "add" & "`replace'" != "" & "`force'" == "" {
		di  ///
		  "{err} No; -dofile(foo, replace)- is pointless for -psid add-; use -dofile(foo, replace force)- to do it anyway."
		exit 198
	}
	
	gettoken url option: dofile, parse(",")
	gettoken comma option: option
	local ext = cond(substr(`"`url'"',-2,2)==".do","",".do")

	capture file close fout
	
	file open fout using `"`url'`ext'"', `replace' `append' write text
	if "`option'" == "append" file write fout _n
	file write fout _n ///
	  "// == Generated by -psid- on `c(current_date)'@`c(current_time)' ==" _n 
end

** Close documentation
program _DOC_CLOSE
	syntax anything(name=dofile) [, *]

	local tempfiles: dir `"`c(tmpdir)'"' files `"St*"'
	foreach file of local tempfiles {
		_DOC capture erase `"`c(tmpdir)'/`file'"'
	}
	file write fout _n _n
	file close fout
	
	gettoken url option: dofile, parse(",")
	gettoken comma option: option
	local ext = cond(substr(`"`url'"',-2,2)==".do","",".do")
	
	noi display ///
	  `"Retrieval do-file is {stata view `url'`ext':`url'`ext'}"' 
end
	

** Define Delivery
program _SET_DELIVERY, rclass
	
	syntax [anything(name=lower)] using/ 
	
	local er =cond("`lower'" == "","ER","er")
	local v =cond("`lower'" == "","V","v")
	local s =cond("`lower'" == "","S","s")

	// I try to find the users delivery by myself ...
	local stop 2017
	while `stop' > 1968 {
		capture confirm file `"`using'/ind`stop'er.dta"'
		if !_rc {
			local delivery `stop'
			local indfile ind`delivery'er
			local stop = 1968
		}
		local stop = `stop' - 1
	}

	local idind ///
	  [68] `er'30001 [69] `er'30020 [70] `er'30043 [71] `er'30067  /// 
	  [72] `er'30091 [73] `er'30117 [74] `er'30138 [75] `er'30160  /// 
	  [76] `er'30188 [77] `er'30217 [78] `er'30246 [79] `er'30283  /// 
	  [80] `er'30313 [81] `er'30343 [82] `er'30373 [83] `er'30399  /// 
	  [84] `er'30429 [85] `er'30463 [86] `er'30498 [87] `er'30535  /// 
	  [88] `er'30570 [89] `er'30606 [90] `er'30642 [91] `er'30689  /// 
	  [92] `er'30733 [93] `er'30806 [94] `er'33101 [95] `er'33201  /// 
	  [96] `er'33301 [97] `er'33401 [99] `er'33501 [01] `er'33601  /// 
	  [03] `er'33701 [05] `er'33801 [07] `er'33901 [09] `er'34001  ///
	  [11] `er'34101 [13] `er'34201 [15] `er'34301 [17] `er'34501  

	
	local idfam ///
	  [68] `v'3      [69] `v'442    [70] `v'1102   [71] `v'1802   [72] `v'2402  [73] `v'3002    ///  
	  [74] `v'3402   [75] `v'3802   [76] `v'4302   [77] `v'5202   [78] `v'5702    ///  
	  [79] `v'6302   [80] `v'6902   [81] `v'7502   [82] `v'8202   [83] `v'8802    ///  
	  [84] `v'10002  [85] `v'11102  [86] `v'12502  [87] `v'13702  [88] `v'14802   /// 
	  [89] `v'16302  [90] `v'17702  [91] `v'19002  [92] `v'20302  [93] `v'21602   /// 
	  [94] `er'2002  [95] `er'5002  [96] `er'7002  [97] `er'10002 [99] `er'13002  /// 
	  [01] `er'17002 [03] `er'21002 [05] `er'25002 [07] `er'36002 [09] `er'42002  ///
	  [11] `er'47302 [13] `er'53002 [15] `er'60002 [17] `er'66002

	local sqind ///
	  [69] `er'30021 [70] `er'30044 [71] `er'30068 [72] `er'30092 [73] `er'30118 [74] `er'30139  ///
	  [75] `er'30161 [76] `er'30189 [77] `er'30218 [78] `er'30247 [79] `er'30284 [80] `er'30314  /// 
	  [81] `er'30344 [82] `er'30374 [83] `er'30400 [84] `er'30430 [85] `er'30464 [86] `er'30499  /// 
	  [87] `er'30536 [88] `er'30571 [89] `er'30607 [90] `er'30643 [91] `er'30690 [92] `er'30734  /// 
	  [93] `er'30807 [94] `er'33102 [95] `er'33202 [96] `er'33302 [97] `er'33402 [99] `er'33502  /// 
	  [01] `er'33602 [03] `er'33702 [05] `er'33802 [07] `er'33902 [09] `er'34002 [11] `er'34102  ///
	  [13] `er'34202 [15] `er'34302 [17] `er'34502
	
	foreach macname in indfile idfam idind sqind delivery {

		local `macname': subinstr local `macname' "[" "", all
		local `macname': subinstr local `macname' "] " ":", all

		return local `macname' ``macname''
	}
	
	
end

exit


Author: Ulrich Kohler
Email: ukohler@uni-potsdam.de

