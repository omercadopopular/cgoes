*! 2.1.2 NJC 30 October 2021 
*! 2.1.1 NJC 2 July 2021 
*! 2.1.0 NJC 11 May 2014 
*! 2.0.1 NJC 4 June 2013 
*! 2.0.0 NJC 13 August 2002 
* 1.8.0 spell NJC 18 October 2001 
* 1.3.1 spell NJC & RG 25 June 1998
* 1.0.0 spell NJC 14 August 1997
program define tsspell, sort   
	version 7.0
	#delimit ; 
	syntax [varname(default=none ts)] [if] [in] 
	[, Cond(str asis) Fcond(str asis) Pcond(str asis) 
	end(str) seq(str) spell(str) replace ] ;
	#delimit cr
	
	* tsset and set up for doing stuff by panel
	qui tsset 
	local id "`r(panelvar)'"
	local time "`r(timevar)'" 
	if "`id'" != "" { 
		local byid "by `id':"
	} 

	* observations to use 
	marksample touse, novarlist 
	qui count if `touse' 
	if r(N) == 0 { 
		error 2000 
	} 
	
	* code modified from -tsset- 
	* see if we have gaps 
	local delta : char _dta[_TSdelta]
	if "`id'" == "" {
		qui count if `time' - `time'[_n-1] != `delta' & `time' < . & `touse' in 2/l   
	}
	else {
		qui count if `time' - `time'[_n-1] != `delta' &	`time' < . & `id' == `id'[_n-1]	in 2/l  
	}

	if r(N) > 0 { 
		di as err "warning: data contain gaps; see help on tsspell" 
	} 

	* conditions defining spells
	local nopts = /* 
	*/ (`"`cond'"' != "") + (`"`fcond'"' != "") + (`"`pcond'"' != "") 
	if `nopts' > 1 { 
		di as err /* 
		*/ "must specify at most one of cond(), fcond(), pcond()" 
		exit 198 
	}

	if `"`pcond'"' != "" { 
		local cond `"((`pcond') > 0 & (`pcond') < .)"' 
	} 	

	if `"`cond'"' == "" & `"`fcond'"' == "" {
		if "`varlist'" != "" {
			local fcond "(`varlist' != L.`varlist') | (_n == 1)"
		}
		else {
			di as err "insufficient information"
			exit 198
		}
	}

	* generation of new variables 
	foreach what in end seq spell { 
		local `what' = cond("``what''" == "", "_`what'", "``what''")
		if "`replace'" != "" { 
			capture confirm new variable ``what''
			if _rc { drop ``what'' } 
		} 
		else confirm new variable ``what'' 
	} 

	* we're in business 
	quietly {
		if `"`fcond'"' != "" { 
			`byid' gen long `spell' = cond(`touse', sum((`fcond') & `touse'), 0)  
			bysort `id' `spell' (`time') : /* 
			*/ gen long `seq' = _n * (`spell' > 0) 
	    	} 	
	    	else {
			`byid' gen long `seq' = `cond' & `touse'
			`byid' replace `seq' = `seq'[_n-1] + 1 if _n > 1 & `seq'
			`byid' gen long `spell' = cond(`seq', sum(`touse' & `seq' == 1), 0)
		} 
	    
	    	`byid' gen byte `end' = /*
          	*/ cond(_n != _N, (`seq' >= `seq'[_n+1]) & `seq', `seq'[_N] > 0)
	    	compress `seq' `spell'
	}
end

