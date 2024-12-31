* 1.0.2 UK 31 Aug 2007 (new url of codelist)
* 1.0.1 NJC 1 Feb 2007               
*! version 1.0.0 January 31, 2007 @ 11:36:16
*! Generates ISO 3166 country codes and country names
program  _giso3166
version 9.2
	
	gettoken type 0 : 0
	gettoken h    0 : 0 
	gettoken eqs  0 : 0

	syntax varname [, Origin(string) Update Language(string) Verbose]

	// Default Settings etc.
	if "`origin'" == "" local origin "names"
	local destination = cond("`origin'" == "names","codes","names")
	local language = cond("`language'"=="","en","`language'")


	// Error-Checks
	if "`origin'" != "codes" & "`origin'" != "names" {
		di `"{err}origin(`origin') invalid: use -origin(names)- or -origin(codes)-"'
		exit 198
	}

	if "`language'" != "fr" & "`language'" != "en" {
		di `"{err}language(`language') invalid: use -language(fr)- or -language(en)-"'
		exit 198
	}

	// Declarations
	tempvar _iso`origin'

	// Take care the Code-lists exist
	local url `"http://www.iso.org/iso"'
	
	if `"update"' != "" {
		capture mkdir `c(sysdir_personal)'
		copy `url'/iso3166_`language'_code_lists.txt `c(sysdir_personal)'/iso3166`language'.txt, replace text public
	}
	
	capture confirm file `c(sysdir_personal)'/iso3166`language'.txt
	if _rc {
		capture mkdir `c(sysdir_personal)'
		copy `url'//iso3166_`language'_code_lists.txt `c(sysdir_personal)'/iso3166`language'.txt, replace text public
	}
	
	quietly {
		
		preserve
		
		// Prepare ISO codelist
		insheet _isonames _isocodes using `c(sysdir_personal)'/iso3166`language'.txt, clear delimit(";")
		drop in 1
		compress
		ren  _iso`origin'  `_iso`origin''
		sort `_iso`origin''
		tempfile isocodes
		save `isocodes'
		
		// Prepare user file
		restore
		capture confirm string variable `varlist'
		if _rc {
			decode `varlist', gen(`_iso`origin'')
			replace `_iso`origin'' = trim(upper(`_iso`origin''))
		}
		else gen `_iso`origin'' = trim(upper(`varlist'))

		// Correct some frequent user errors (is this a good idea?)
		//	capture assert `_iso`origin'' != "RUSSIA"
		// 	if _rc {
		// 		noi di `"{txt}`varlist' contains "{res}Russia{txt}". "{res}Russian Federation{txt}" assumed."'
		// 		replace `_iso`origin'' = "RUSSIAN FEDERATION" if `_iso`origin''=="RUSSIA"
		// 	}
		// 	capture assert `_iso`origin'' != "GREAT BRITAIN"
		// 	if _rc {
		// 		noi di `"{txt}`varlist' contains "{res}Great Britain{txt}". "{res}United Kingdom{txt}" assumed ."'
		// 		replace `_iso`origin'' = "UNITED KINGDOM" if `_iso`origin''=="GREAT BRITAIN"
		// 	}
		// 	if _rc {
		// 		noi di `"{txt}`varlist' contains "{res}Taiwan{txt}". "{res}Taiwan, Province of China{txt}" assumed ."'
		// 		replace `_iso`origin'' = "TAIWAN" if `_iso`origin''=="TAIWAN, PROVINCE OF CHINA"
		// 	}
		
		// Merge ISO codes to user file
		sort `_iso`origin''
		merge `_iso`origin'' using `isocodes', nokeep
		ren  _iso`destination' `h'
		if "`origin'" == "codes" {
			replace `h' = trim(itrim(proper(`h')))
			compress `h'
		}

		// Produce verbose output
		capture assert _merge == 3
		if "`verbose'" != "" & _rc {
			noi di _n "{txt}note: could not find ISO 3166 information for "
			tempvar marker
			by `varlist', sort: gen `marker' = _n==1 & _merge==1
			noi list `varlist' if `marker' , noobs
			noi di `"{txt}check spelling ({view `c(sysdir_personal)'/iso3166`language'.txt:show codelist})"'
		}
		drop _merge
	}
end
