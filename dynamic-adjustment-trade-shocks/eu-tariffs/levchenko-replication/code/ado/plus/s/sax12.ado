*!version 1.0.1, 2010-Sep-27, Qunyong. Wang, brynewqy@nankai.edu.cn
*!modified: 2012-Mar-14.
*!modified by D.M. (23/08/2018) The forecast-related part of the core has been deactivated, so to allow the .d11 .d10 etc files to be generated correctly
program sax12, rclass
version 11.0
syntax [varlist(numeric default=none)] [if] [in] [,  ///
	satype(string) ///
	inpref(string) outpref(string) comptype(string) ///
	dtafile(string) ///
	mtaspc(string) mtafile(string) compsa compsadir ///
	transfunc(string) transpower(real 1)  stock ///
	prioradj(string) priorvar(varlist) priormode(string) priortype(string) ///
	regpre(string) regaic(string) ///
		reguser(varlist) regusertype(string) regusercent(string) ///
	outauto(string) outcrit(string) outmethod(string) outspan(string)  ///
		outlsrun(numlist integer min=0 max=5) outao(string) outls(string) outtc(string) ///
	ammodel(string) ///
		ammaxlag(numlist >=0 <=36) ammaxdiff(numlist >=0 <=3) amfixdiff(numlist >=0 <=3) ///
		amfile(string)  /// 
		ammaxback(integer 0) amlevel(real 0.95) ///
		amspan(string) ///
	x11mode(string) x11trend(string) x11seas(string) ///
		x11final(string) x11hol  ///
		x11sig(string) sanone ///
	sliding history justspc ///
	dsa dsaspc(string) noVIew ///
		dsadtaspc(string) dsadta(string) ///
		dsamta(string) ] 
	
// find the x12a.exe program
capture findfile "x12a.exe"
if _rc != 0 {
	dis as err "x12a.exe not found, please make sure it is under the adopath!"
	exit
}
local sasoft=`"`r(fn)'"'
local path=trim(`"`c(pwd)'"')

if (substr(`"`sasoft'"',1,2) == "./") {
	local sasoft = substr(`"`sasoft'"',3,.)
}

// error checking
* check conflict between options
if (!inlist("`transfunc'", "log","auto") & `transpower'!=0 ) & inlist("`x11mode'", "mult", "logadd") {
	dis as err "Multiplicative or log additive seasonal adjustment cannot be performed for data which have not been log transformed!"
	exit
}
* transformation vs prior
if (!inlist("`transfunc'", "log","auto") & `transpower'!=0 ) & (strmatch("`priormode'", "*ratio*") | strmatch("`priormode'", "*percent*") ) {
	dis as err "Ratio or percent factors can only be used with log-transformed data!"
	exit
}
if (!inlist("`transfunc'", "none","auto") & `transpower'!=1 )  & strmatch("`priormode'", "*diff*") {
	dis as err "subtracted factors can only be used with no transformation!"
	exit
}
* seasonal adjustment type
if ("`satype'"!="single" & "`satype'"!="dta" & "`satype'"!="mta") {
	dis as err `"seasonal adjustment type must be one of: single, dta, mta, check satype() option! "'
	exit
}
* transformation with seasonal adjustment mode 
if "`transfunc'"=="auto" & "`x11mode'"!="" {
	dis as err "Cannot set seasonal adjustment mode when automatic transformation selection is done, check transfunc() and x11mode() options!"
	exit
}

* conflict between predefined regression variables
local i=0
foreach v in td td1coef lom loq lpyear {
	local a: list v in regpre
	local i = `i'+`a'
}
if `i'>1 {
	dis as err "Conflicts between elements in regpre(): td, td1coef, lom, loq, lpyear"
	exit
}

local i=0
foreach v in tdnolpyear td1nolpyear lom loq {
	local a: list v in regpre
	local i = `i'+`a'
}
if `i'>1 {
	dis as err "Conflicts between elements in regpre(): tdnolpyear, td1nolpyear, lom, loq, lpyear"
	exit
}

local a = 0
local b = 0
local c = 0
if ("`prioradj'"=="lom" | "`prioradj'"=="loq") local a = 1
if ("`prioradj'"=="lpyear") local b = 1
if (strmatch("`regpre'", "*td*") | strmatch("`regpre'", "*td1*"))  local c = 1
if `a' & `c' {
	dis as err `"prioradj() cann't be specified when trading day already set in regpre()!"'
	exit
}
if (strmatch("`regpre'", "*lom*") | strmatch("`regpre'", "*loq*"))  local c = 1
if `a' & `c' {
	dis as err `"prioradj() cann't be specified when length of month(quarter) already set in regpre()!"'
	exit
}
local c = cond(strmatch("`regpre'", "*td*") & !strmatch("`regpre'", "*nolpyear*"), 1, 0)
if (`a' | `b') & `c' {
	dis as err `"prioradj() cann't be specified when leap year already set in regpre()!"'
	exit
}
if ("`prioradj'"=="lpyear") & (!inlist("`transfunc'","log") & `transpower'!=0 ) {
	dis as err `"prioradj(lpyear) is only allowed when a log transformation is specified by transpower() or transfunc()!"'
	exit
}

marksample touse
* check frequency
qui tsset
local tvar="`r(timevar)'" 
local unit="`r(unit)'"
local unit = "`r(unit)'"
local freq = cond("`unit'" == "quarterly", 4, 12)
if ("`unit'" != "quarterly" & "`unit'" != "monthly") {
	dis as err `"Only quarterly and monthly time series are allowed!"'
	exit
}

* used only for monthly data
if "`stock'"=="" { // flow 
	if `freq'==4 { // quarterly
		local i = 0
		foreach v in lom labor thank {
			local i = `i' + strmatch("`regpre'", "*`v'*")
		}
		if `i'>0 {
			dis as err "lom tdstock labor thank in regpre() are used only for monthly flow data"
			exit
		}
	}
	if `freq'==12 {
		if strmatch("`regpre'", "*loq*") {
			dis as err "loq in regpre() is used only for quarterly flow data"
			exit
		}
	}
	if strmatch("`regpre'", "*tdstock*") {
		dis as err "tdstock[] in regpre() is used only for monthly stock data"
		exit
	}
}
else { // stock
	local i = 0
	foreach v in td tdnolpyear td1coef td1nolpyear lom loq easter sceaster labor thank {
		local a: list v in regpre
		local i = `i'+`a'
	}
	if `i'>0 {
		dis as err "td tdnolpyear td1coef td1nolpyear lom tdstock easter sceaster labor thank in regpre() are used only for flow data"
		exit
	}
}
* check time gaps
qui tsreport if `touse'
local ngap = r(N_gaps)
if `ngap'>0 {
	dis as err `"Time gaps not allowed, use 'tsreport' to check it!"'
	exit
}
* maximum length of time series
qui count if `touse'
local n = r(N)
if `n'> 600 {
	dis as err "maximum length of time series allowed is 600!"
	exit
}
* maximum number of forecast
// if `ammaxlead'>60 {
// 	dis as err "maximum number of forecast allowed is 60!"
// 	exit
// }
if `ammaxback'>60 {
	dis as err "maximum number of backcast allowed is 60!"
	exit
}
// * maximum number of years in extended series
// if (`n'+`ammaxlead'+`ammaxback')/`freq'>70 {
// 	dis as err "maximum number of year in the forecast and backcast extended series allowed is 70!"
// 	exit
// }
* maximum number of user-defined variable
local n: word count `reguser' `outao' `outls' `outtc'
if `n'>52 {
	dis as err "maximum number of user-defined variable allowed is 52!"
	exit
}
* maximum number of meta files
if inlist("`satype'", "dta", "mta") {
	local n: word count `dtafile' `mtaspc'
	if `n'>500 {
		dis as err "maximum number of files by a metafile allowed is 500!"
		exit
	}
}
* trendma must be odd integer 
if "`x11trend'"!="" {
	if !mod(`x11trend', 2) {
		dis as err "trend filter must be odd integer, check x11trend() option!"
		// local x11trend = `x11trend'-1
		exit
	}
}
if `amlevel'>1 {
	local amlevel = `amlevel'/100
}
* check spelling
foreach v in ao lc tc {
	tokenize `"`out`v''"'
	local nn: word count `out`v''
	forvalues i = 1/`nn' {
		local ni: word `i' of `out`v''
		if lower(substr(trim("`ni'"),1,2)) != "`v'" {
			local `i' "`v'`ni'"
		}
	}
	local out`v' = "`*'"
}

// main part
if "`dsa'"!="" {  // SA based on already existing spc(dta, mta) file(s)
	if "`satype'"=="single" {	
		if "`dsaspc'"=="" {
			dis as err `"dsaspc() option is required for 'satype(single) dsa'"'
			exit
		}
		local dsaspc = subinstr("`dsaspc'", ".spc", "", .) 
		shell "`sasoft'" "`dsaspc'" -g "`c(pwd)'" -s -q 
	}
	else if "`satype'"=="dta" {
		if "`dsadtaspc'"=="" {
			dis as err `"dsadtaspc() option is required for 'satype(dta) dsa'"'
			exit
		}
		if "`dsadta'"=="" {
			dis as err `"dsadta() option is required for 'satype(dta) dsa'"'
			exit
		}
		local dsadtaspc = subinstr("`dsadtaspc'", ".spc", "", .) 
		local dsadta = subinstr("`dsadta'", ".dta", "", .) 
		shell "`sasoft'" "`dsadtaspc'" -d "`dsadta'" -g "`c(pwd)'" -s -q
	}
	else if "`satype'"=="mta" {
		if "`dsamta'"=="" {
			dis as err `"dsamta() option is required for 'satype(mta) dsa'"'
			exit
		}
		local dsamta = subinstr("`dsamta'", ".mta", "", .) 
		shell "`sasoft'" -m "`dsamta'" -g "`c(pwd)'" -s -q
	}
}
else {   // create spc(dta, mta) file(s) to perfom SA 
	local workdir=c(pwd)
	*local sep=c(dirsep)
	local sep = "\"
	if "`satype'" != "mta" {
		// extract time information
		tempvar year seas
		if `freq'==12 {
			qui gen `seas'=month(dofm(`tvar'))
			qui gen `year'=year(dofm(`tvar'))
			local adjust="lom"
			local tfmt="%tmCY.m"
		}
		if `freq'==4 {
			qui gen `seas'=quarter(dofq(`tvar'))
			qui gen `year'=year(dofq(`tvar'))
			local adjust="loq" 
			local tfmt="%tqCY.q"
		}
	}
	tempname sa
	if "`satype'"=="single" { 
			if "`inpref'"=="" {
				local inpref = "`path'`sep'`varlist'.spc"
			}
			if substr(trim("`inpref'"), -4, 4) != ".spc" {  // no extension case
				local inpref = "`inpref'.spc"
			}
			tokenize `inpref', parse("\")
			if "`2'" == "" {
				local inpref = "`path'`sep'`inpref'"
			}
			qui file open `sa' using `"`inpref'"', write replace text 
			qui outsheet `year' `seas' `varlist' using "`path'`sep'`varlist'.dat" if `touse', nonames replace
			file write `sa' _column(1) ("# `c(current_date)', `c(current_time)'; generated by Stata program sax12 ") _newline 
			file write `sa' _column(1) (`"series { "') _newline
			file write `sa' _column(4) (`"title = "`varlist'" "') _newline 
			file write `sa' _column(4) (`"file = "`path'`sep'`varlist'.dat" "') _newline 
			file write `sa' _column(4) (`"Period = `freq' "') _newline 
			file write `sa' _column(4) (`"format = "datevalue" "') _newline  
			if "`comptype'"!="" {
				file write `sa' _column(4) (`"comptype = `comptype' "') _newline 
			}
			if "`amspan'"!="" {
				file write `sa' _column(4) (`"modelspan = (`amspan') "') _newline 
			}
			file write `sa' _column(1) ("} ") _newline(2) 
	}
	else if "`satype'"=="dta" {
		if "`inpref'"=="" {
			local inpref = "`path'`sep'mvss.spc"
		}
		if substr(trim("`inpref'"), -4, 4) != ".spc" {  // no extension case
			local inpref = "`inpref'.spc"
		}
		tokenize `inpref', parse("\")
		if "`2'" == "" {
			local inpref = "`path'`sep'`inpref'"
		}
		qui file open `sa' using `"`inpref'"', write replace text 
		file write `sa' _column(1) ("# `c(current_date)', `c(current_time)'; generated by Stata program sax12 ") _newline 
		file write `sa' _column(1) ("series { ") _newline 
		file write `sa' _column(4) (`"Period = `freq' "') _newline 
		file write `sa' _column(4) (`"format = "datevalue" "') _newline  
		file write `sa' _column(4) (`"save = (a1 sp0 a18 a19 b1) "') _newline  
		file write `sa' _column(1) ("} ") _newline 

		tempname dta
		if "`dtafile'"=="" local dtafile = "`path'`sep'mvss.dta"
		if substr(trim("`dtafile'"), -4, 4) != ".dta" {  // no extension case
			local dtafile = "`dtafile'.dta"
		}
		tokenize `dtafile', parse("\")
		if "`2'" == "" {
			local dtafile = "`path'`sep'`dtafile'"
		}
		qui file open `dta' using `"`dtafile'"', write replace text 
		// output dat file
		local i=1
		foreach v of varlist `varlist' {
			qui outsheet `year' `seas' `v' using "`path'`sep'`v'.dat" if `touse', nonames replace
			if "`outpref'" != "" {
				local dou: word `i' of `outpref'
			}
			file write `dta' (`""`path'`sep'`v'.dat"  `dou'"') _newline 
			local ++i
		}
		file close `dta'
	}
	else if "`satype'"=="mta" { 
		if "`mtaspc'"=="" {
			dis as err "mtaspc() option shouldn't be blank for satype(mta) option, check it!"
			exit
		}
		// generate mta file
		tempname mta
		if "`mtafile'"=="" local mtafile = "`path'`sep'mvms.mta"
		if substr(trim("`mtafile'"), -4, 4) != ".mta" {  // no extension case
			local mtafile = "`mtafile'.mta"
		}
		tokenize `mtafile', parse("\")
		if "`2'" == "" {
			local mtafile = "`path'`sep'`mtafile'"
		}
		qui file open `mta' using `"`mtafile'"', write replace text 
		local i=1
		foreach v of local mtaspc {
			local v2 = subinstr("`v'",".spc","",.)
			if "`outpref'" != "" {
				local dou: word `i' of `outpref'
			}
			file write `mta' (`""`v2'" `dou'"') _newline 
			local ++i
		}
		if "`compsa'" != "" { 
			if "`inpref'" == "" {
				local inpref = "`path'`sep'mvms.spc"
			}
			if substr(trim("`inpref'"), -4, 4) != ".spc" {  // no extension case
				local inpref = "`inpref'.spc"
			}
			/*
			tokenize `inpref', parse("\")
			if "`2'" == "" {
				local inpref = "`path'`sep'`inpref'"
			}
			*/
			qui file open `sa' using `"`inpref'"', write replace text 
			file write `sa'  _column(1) ("composite { ") _newline 
			file write `sa'  _column(4) (`"title = "indirect adjustment for composite series" "') _newline 
			file write `sa'  _column(4) ("save = (isa isf itn iir iaf ica iao ils ip6 ip7 ip8)") _newline 
			file write `sa'  _column(1) ("} ") _newline 
			if "`outpref'"!="" {
				local dou: word `i' of `outpref'
			}

			local v2 = subinstr("`inpref'",".spc","",.)
			file write `mta' (`""`v2'" `dou'"') _newline 
		}
		file close `mta'
	}

	if ("`satype'"!="mta" | (("`satype'"=="mta") & "`compsadir'"!="") )  { 
		// Transform Part
		if ("`transfunc'`priorvar'`prioradj'"!="" | `transpower'!=1) {
			file write `sa' _column(1) ("transform { ") _newline 
			if "`transfunc'"!="" {
				file write `sa' _column(4) ("function=`transfunc' ") _newline 
			} 
			else if `transpower'!=1 {
				file write `sa' _column(4) ("power = `transpower' ") _newline 
			}
			if ("`prioradj'"!="" & "`prioradj'"!="none") {
				file write `sa' _column(4) (`"adjust = `prioradj' "') _newline
			}
			if "`priorvar'"!="" {
				tempfile pfile
				qui outsheet `year' `seas' `priorvar' using `pfile' if `touse', nonames replace
				file write `sa' _column(4) (`"file = ("`pfile'") "') _newline
				if "`priormode'"!="" {
					file write `sa' _column(4) (`"mode = (`priormode') "') _newline
				}
				if "`priortype'"!="" {
					file write `sa' _column(4) (`"type = (`priortype') "') _newline
				}
			}
			file write `sa' _column(4) ("save = (a2 a3 trn) ") _newline
			file write `sa' _column(1) ("} ") _newline(2)
		} 

		// Regression Part
		local regout "`outao' `outls' `outtc'"
		if (trim("`regpre'`reguser'`regout'")!= "" )  {
			file write `sa'  _column(1) ("regression  { "  ) _newline
			if ("`regpre'`regout'"!="") {
				file write `sa'  _column(4) ("variables = (`regpre' `regout') ") _newline 		 
			} 
			if "`reguser'" != "" { 
				/*
				if "`reguser'" != "" {
					local i = 1
					local vs ""
					foreach v of varlist `reguser' {
						tempvar v`i'
						if "`regusercent'" == "mean" {
							qui summ `v' if `touse', meanonly
						}
						if "`regusercent'" == "seasonal" {
							qui by(`seas'),sort: egen `v`i'' = mean(`v') 
						}
						qui replace `v`i'' = `v' - r(mean)
						local vs "`vs' `v`i'' "
						local ++i
					}
				}
				*/
				tempvar touse2
				mark `touse2'
				markout `touse2' `reguser'
				tempfile duser
				qui outsheet `year' `seas' `reguser' if `touse2' using `duser', nonames replace
				file write `sa' _column(4) ("user = (`reguser')") _newline 
				file write `sa' _column(4) ("usertype = (`regusertype') ") _newline 
				file write `sa' _column(4) (`"file = "`duser'" "') _newline 
				file write `sa' _column(4) (`"format = "datevalue" "') _newline 
				if ("`regusercent'"=="center" | "`regusercent'"=="seasonal") {
					file write `sa' _column(4) ("centeruser = `regusercent'") _newline 
				}
			}
			if "`regaic'" != "" {
				file write `sa' _column(4) ("aictest = (`regaic')") _newline 
			}
			file write `sa' _column(4) ("save = ( td hol usr otl ao ls tc )") _newline 
			file write `sa' _column(1) ("}  ") _newline(2)
		} 

		// outlier 
		if ("`outauto'" != "none" & "`outauto'" != "")  {
			file write `sa' _column(1) ("outlier { ") _newline
			file write `sa' _column(4) ("types = ( `outauto' )  ") _newline  
			if "`outcrit'" != "" {
				file write `sa' _column(4) ("critical = (`outcrit')  ") _newline
			}
			if "`outmethod'" != "" {
				file write `sa' _column(4) (`"method = `outmethod'  "') _newline
			}
			if "`outspan'" != "" {
				file write `sa' _column(4) ("span = (`outspan')  ") _newline
			} 
			if trim("`outlsrun'") != "" {
				file write `sa' _column(4) ("lsrun = `outlsrun'  ") _newline
			}
			file write `sa' _column(4) ("save=( fts oit ) ") _newline
			file write `sa' _column(1) ("} ") _newline(2)
		}

	   // ARIMA
		if "`ammodel'" != "" {
			file write `sa' _column(1) ("arima { ") _newline
			file write `sa' _column(4) ("model = `ammodel' ") _newline
			file write `sa' _column(1) ("}") _newline(2)
		}
		if "`ammaxlag'" != "" {
			file write `sa' ("automdl { ") _newline
			file write `sa' _column(4) ("maxorder = (`ammaxlag') ") _newline
			if "`ammaxdiff'" != "" {
				file write `sa' _column(4) ("maxdiff = (`ammaxdiff') ") _newline
			}
			if "`amfixdiff'" != "" {
				file write `sa' _column(4) ("diff = (`amfixdiff') ") _newline
			}
			file write `sa' _column(1) ("}") _newline
		}
		if "`amfile'" != "" {
			file write `sa' (`"pickmdl { file = "`amfile'"  "') _newline  
			if "`ammode'" != "" {
				file write `sa' ("	mode = `ammode'  ") _newline  
			} 
			if "`ammethod'" != "" {
				file write `sa' ("	method = `ammethod'  ") _newline  
			} 
			if "`fcstlim'" != "" {
				file write `sa' ("	fcstlim = `fcstlim'  ") _newline  
			} 
			if "`bcstlim'" != "" {
				file write `sa' ("	bcstlim = `bcstlim'  ") _newline  
				} 
			if "`qlim'" != "" {
				file write `sa' ("	qlim = `qlim'  ") _newline  
			} 
			if "`overdiff'" != "" {
				file write `sa' ("	overdiff = `overdiff'  ") _newline  
			} 
			if "`identify'" != "" {
				file write `sa' ("	identify = `identify'  ") _newline  
			} 
			file write `sa' ("	}  ")  _newline(2)  
		}

// 		// Forecast
// 		file write `sa' ("forecast {  ") _newline 
// 		if "``ammaxlead'"!="" {
// 			file write `sa' _column(4) ("maxlead = `ammaxlead' ") _newline 
// 		}
// 		if "``ammaxback'"!="" {
// 			file write `sa' _column(4) ("maxback = `ammaxback' ") _newline 
// 		}
// 		if "``amlevel'"!="" {
// 			file write `sa' _column(4) ("probability = `amlevel' ") _newline 
// 		}
// 		file write `sa' _column(4) ("save=(ftr fct btr bct) ") _newline 
// 		file write `sa' ("} ") _newline(2) 
//		
// 		file write `sa' ("estimate {  }") _newline(2)  

		// X11 Part
		if "`sanone'"=="" {
			file write `sa' ("x11 {  ") _newline 
			if ("`x11mode'" != "") {
				file write `sa' _column(4) ("mode = `x11mode' ") _newline 
			}
			if ("`x11trend'" != "x11default" & "`x11trend'" != "") {
				file write `sa' _column(4) ("trendma = `x11trend' ") _newline 
			}
			if (lower("`x11seas'") == "x11default"  | "`x11seas'" == "") {
				file write `sa' _column(4) ("seasonalma = msr ") _newline 
			}
			else {
				file write `sa' _column(4) ("seasonalma = `x11seas' ") _newline 
			}
			if "`x11final'" != "" {
				file write `sa' _column(4) ("final = (`x11final') ") _newline
			}
			if "`x11sig'" != "" {
				file write `sa' _column(4) ("sigmalim = (`x11sig') ") _newline
			}
			file write `sa' _column(4) ("save = (d10 d11 d12 d13 pe5 pe6 pe7 d16 d18 chl d8b)") _newline 
			file write `sa' ("} ") _newline(2) 
		}

		// stability
		if "`sliding'"!="" {
			file write `sa' ("slidingspans {  ") _newline		
			file write `sa' _column(4) ("save = (sfs ads tds chs ycs) ") _newline
			file write `sa' ("} ") _newline(2)
		}
		if "`history'"!="" {
			file write `sa' ("history { ") _newline
			file write `sa' _column(4) ("save = (sar sae trr tre tcr tce sfr sfe chr che ) ") _newline
			file write `sa' ("} ") _newline(2)
		}
	}
	file close _all  // "`satype'"=="msa" & "`compsa'"=="", we have no file read using `sa'
	/* erase `outpref'.* file
	local i=1
	foreach v of varlist `varlist' {
		if "`outpref'"!="" {
			local dou: word `i' of `outpref'
		}
		else {
			local dou = "`v'"
		}
		local m: dir . files "`dou'.*"
		foreach f of local m {
			erase `f'
		}
	}
	*/
	 
	if "`justspc'"=="" {
		if "`satype'"=="single" {
			local inpref = subinstr("`inpref'", ".spc", "", .) 
			if "`outpref'"=="" local outpref = "`varlist'"
			shell "`sasoft'" "`inpref'" -g "`c(pwd)'" -s -o `outpref' -q 
			if "`view'"=="" view `"`outpref'.out"' // modified 2011-Oct-30
		}
		else if "`satype'"=="dta" {
			local inpref = subinstr("`inpref'", ".spc", "", .) 
			local dtafile = subinstr("`dtafile'", ".dta", "", .) 
			shell "`sasoft'" "`inpref'" -d "`dtafile'" -g "`c(pwd)'" -q -s
		}
		else if "`satype'"=="mta" {
			local mtafile = subinstr("`mtafile'", ".mta", "", .) 
			shell "`sasoft'" -m "`mtafile'" -g "`c(pwd)'" -q -s
		}
	}
	else {
		if "`view'"=="" view `"`inpref'"' // modified 2011-Oct-30
	}
}
if "`satype'"=="single" | "`satype'"=="dta" | ("`satype'"=="mta" & "`compsa'"!="") {
	return local spcfile "`inpref'"
}
if "`satype'"=="dta" {
	return local dtafile "`dtafile'.dta"
}
if "`satype'"=="mta" {
	return local mtafile "`mtafile'.mta"
}
return local outpref "`outpref'"
end
