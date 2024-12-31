*! outreg2 2.3.2  17aug2014 by roywada@hotmail.com
*! based on outreg 3.0.6/4.0.0 by john_gallup@alum.swarthmore.edu

prog define outreg2, by(onecall) sortpreserve
	versionSet
	version `version'

tempname coefActive
cap _estimates hold `coefActive', restore copy nullok /* capture for prior to Stata 8.2 */

local behind `"`0'"'
local 0 ""
gettoken front behind: behind, parse(" ,")
local 0 ""
local done 0
while `"`front'"'~="" & `done'==0 {
	if `"`front'"'=="using" {
		
		gettoken rest behind: behind, parse(" ,")
		* strip off quotes
		gettoken first second: rest, parse(" ")
		cap local rest: list clean local(rest)
		
		* take off colon at the end
		local goldfish ""
		if index(`"`rest'"',":")~=0 {
			local end=substr(`"`rest'"',length(`"`rest'"'),length(`"`rest'"'))
			if "`end'"==":" {
				local rest=substr(`"`rest'"',1,`=length(`"`rest'"')-1')
				local goldfish " : "
			}
		}
		* colon reattached with a space at the end
		* .txt attached here for seeout working with _pref.ado
		local rabbit `"""'
		if index(`"`rest'"', ".")==0 {
			local using `"`rabbit'`rest'.txt`rabbit'`goldfish'"'
		}
		else {
			local using `"`rabbit'`rest'`rabbit'`goldfish'"'
		}
		local 0 `"`0' using `using' `behind'"'
		local done 1
	}
	else {
		local 0 `"`0' `front'"'
		gettoken front behind: behind, parse(" ,")
	}
}

gettoken first second : 0, parse(":") `bind' match(par) quotes
local 0 `"`first'"'
while `"`first'"'~=":" & `"`first'"'~="" {
	gettoken first second : second, parse(":") `bind' match(par) quotes
}
if `"`0'"'==":" {
	* colon only when shorthand combined with prefix
	local 0
}
else {
	local _0 `"`0'"'
}

*** check for conflicts here due to drop(`_byvars')
syntax [anything] [using] [if] [in] [pweight fweight aweight iweight] [, drop(str) keep(str) * ]
if "`drop'"~="" & "`keep'"~="" {
	di in red "cannot specify both {opt keep( )} and {opt drop( )}"
	exit 198
}
if "`drop'"~="" & "`varlist'"~="" {
	di in red "cannot specify both {it:varlist} and {opt drop( )}"
	exit 198
}

*** shorthand syntax if [using] is missing
syntax [anything] [using] [if] [in] [pweight fweight aweight iweight] [, SEEout REPLACE NOSEEOUT NOREPLACE CROSStab AGAIN * CDOUT]

*** bys( ): by(onecall) indicated by `_byvars' only

* goes with `second'
if `"`second'"'~="" {
	local _colon ":"
}

if "`_byvars'"~="" {
	bys `_byvars' : outreg2_by `0' `_colon' `second'
}
else if "`crosstab'"~="" {
	outreg2_by `0' `_colon' `second'
}
else {
	* regular stuff
	if `"`using'"'~="" {
		* both prefix full syntax and regular non-prefix usage
		* `second' could contain " " only
		version `version' : `second'
		_outreg2 `0'
	}
	else {
		* prefix shorthand synatx
		syntax [anything] [, REPLACE SEEout APpend cdout]
		
		version `version' : `second'
		
		*** read the set preference if not out of date
		
		* NOTE: `0' is written over below
		
		cap quietly findfile outreg2.pref
		if _rc~=0 & "`Version7'"~="" {
			* create it if missing
			findfile outreg2.ado
			local place=substr(`"`r(fn)'"',1,`=length(`"`r(fn)'"')-11')
			
			tempname myplace
			cap file open `myplace' using `"`place'outreg2.pref"', write text replace
			cap file write `myplace' "" _n
			cap file write `myplace' "" _n
			cap file write `myplace' ""
			cap file close `myplace'
		}
		
		tempname myfile
		cap file open `myfile' using `"`r(fn)'"', read text
		cap file read `myfile' date
		cap file read `myfile' pref
		cap file read `myfile' options
		cap file close `myfile'
		
		* fix _comma
		local _comma ""
		if `"`macval(options)'"'~="" | "`replace'"~="" | "`seeout'"~="" | "`cdout'"~="" {
			local _comma ","
		}
		
		if "`date'"== "`c(current_date)'" {
			local seecommand "outreg2"
			local precommand "_outreg2"
			foreach var in anything  macval(pref) _comma macval(options) replace seeout cdout {
				if `"``var''"'~="" {
					if `"``var''"'=="," {
						local seecommand `"`seecommand'``var''"'
						local precommand `"`precommand'``var''"'
					}
					else {
						local seecommand `"`seecommand' ``var''"'
						local precommand `"`precommand' ``var''"'
					}
				}
			}
			*local cl `"{stata `"`seecommand'"':  `seecommand'}"'
			*di as txt `"`cl'"'
			di in white `"  `seecommand'"'
			`precommand'
		}
		else {
			di in red "must specify the full syntax (the last preference has expired)"
			exit 100
		}
	}
}


*** saving the current preferences
if `"`using'"'=="" {
	local _0 `"`seecommand'"'
}

local 0 `"`_0'"'

* take out sum/crosstab and
* take out [if] [in] [pweight fweight aweight iweight] 
* take out non-user specified options: replace/noreplace seeout/noseeout 
syntax [anything] [using] [if] [in] [pweight fweight aweight iweight] [, REPLACE NOREPLACE SUM SUM2(str) CROSStab SEEout /*
	*/ NOSEEOUT CTTOP CTBOT CDOUT *]

local pref `"`using'"'

* NOTE: `0' has been overwritten long ago
		
		cap quietly findfile outreg2.pref
		if _rc~=0 & "`Version7'"~="" {
			* create it if missing
			findfile outreg2.ado
			local place=substr(`"`r(fn)'"',1,`=length(`"`r(fn)'"')-11')
			
			tempname myplace
			cap file open `myplace' using `"`place'outreg2.pref"', write text replace
			cap file write `myplace' "" _n
			cap file write `myplace' "" _n
			cap file write `myplace' ""
			cap file close `myplace'
		}
		
cap quietly findfile outreg2.pref
tempname myfile

* capture for write protected files
cap file open `myfile' using `"`r(fn)'"', write text replace
cap file write `myfile' `"`c(current_date)'"' _n
cap file write `myfile' `"`pref'"' _n
cap file write `myfile' `"`options'"'
cap file close `myfile'

*** display clickables
foreach var in dta tex word excel xmlsave {
	if `"`cl_`var''"'~="" {
		noi di as txt `"`cl_`var''"' 
	}
}

*** cdout thing
if "`cdout'"=="cdout" {
	qui _cdout, 
}

noi _cdout, cont noopen

foreach var in see {
	if `"`cl_`var''"'~="" {
		noi di as txt `"`cl_`var''"' 
	}
}

* restoring the currently active estimate here
cap _estimates unhold `coefActive'

*** run requested
*if `"`c_request'"'~="" {
*	di " "
*	di in white `". `c_request'"'
*	`c_request'
*}

end /* end of outreg2 */


********************************************************************************************


prog define outreg2_by, by(recall, nohead)
	versionSet
	version `version'

preserve

gettoken first second : 0, parse(":") `bind' match(par) quotes
local 0 `"`first'"'
while `"`first'"'~=":" & `"`first'"'~="" {
	gettoken first second : second, parse(":") `bind' match(par) quotes

}

if `"`0'"'==":" {
	* colon only when shorthand combined with prefix
	local 0
}
else {
	local _0 `"`0'"'
}

*** shorthand syntax if [using] is missing
syntax [anything] [using] [if] [in] [pweight fweight aweight iweight] [, SEEout REPLACE NOSEEOUT NOREPLACE CROSStab AGAIN * ]

*** bys( ) clean up: touse, ctitle/cctop, replace/noreplace, seeout/noseeout
if `=_by()'==1 {
	
	marksample touse
	
	* generate column heading when -by- specified
	if `"`cttop'"'~="" {
		local cc=1
		
		tokenize `_byvars'
		while "``cc''"~="" {
			
			* should there be `touse' here?
			qui summarize ``cc'' if `_byindex' == `=_byindex()' & `touse', meanonly
			if r(N)<. {
				local actual`cc' =r(mean)
			}
			else {
				local actual`cc' =.
			}
			
			* place cttop in there
			local _comma
			if `cc'~=1 {
				local _comma ","
			}
			
			local cttop "`cttop'`_comma' ``cc'' `actual`cc'' "
			*local cttop "`cttop'`_comma' ``cc'', `actual`cc'' "
			local cc=`cc'+1
		}
	}
	else {
		local cc=1
		local cttop ""
		
		tokenize `_byvars'
		while "``cc''"~="" {
			
		* should there be `touse' here?
		qui summarize ``cc'' if `_byindex' == `=_byindex()' & `touse', meanonly
			if `r(N)'<. {
				local actual`cc' =r(mean)
			}
			else {
				local actual`cc' =.
			}
			
			* place cttop in there
			local _comma
			if `cc'~=1 {
				local _comma ","
			}
			
			local cttop "`cttop'`_comma' ``cc'' `actual`cc'' "
			*local cttop "`cttop'`_comma' ``cc'', `actual`cc'' "
			local cc=`cc'+1
		}
	}
	
	* lazy
	qui keep if `touse'==1
	
	local 0 `0' cttop(`cttop')
	
	* drop bys( ) from ctitles
	if "`drop'"=="" {
		local drop `"`_byvars'"'
		local 0 `0' drop(`drop')
	}
	
	* replace first when -by- specified
	if `=_byindex()'==1 {
		local noreplace ""
	}
	else {
		local noreplace "noreplace"
	}
	
	* seeout last when -by- specified
	if `=_bylastcall()'==0 {
		local noseeout "noseeout"
	}
	else {
		local noseeout ""
	}
	
	
	* pass an embedded indicator to the second runs
	if "`again'"=="" {
		local again "again"
	}
	
	* simplify by dropping them
	drop `touse' `_byindex'
}

* this will include the outputs from bys( ) routine above:
local 0 `0' `noreplace' `noseeout'

* for multiple tabs
local names `"`anything'"'
if "`crosstab'"=="crosstab" & `"`names'"'=="" {
	noi di in red "varlist required for {opt crosstab} option"
	exit 100
}

* separate the first variable from the rest, which are for the bys( )
gettoken first rest : names, parse(" ")
if "`crosstab'"=="crosstab" & "`first'"~="" & "`rest'"~="" {
	cap drop _fillin
	cap fillin `rest'
	if "`replace'"=="replace" {
		
	}
	*local 0 `first' `if' `in' [`weight'`exp'] `using', `seeout' `replace' `crosstab' nonotes `options' cttop(`cttop') ctbot(`ctbot')
	local 0 `first' `using', `seeout' `replace' `crosstab' nonotes `options' cttop(`cttop') ctbot(`ctbot')
	
	if `"`second'"'=="" {
		qui bys `rest' : outreg2_by `0'
	}
	else {
		noi bys `rest' : outreg2_by `0' : `second'
	}
}
else {
	* single tabs or no crosstab at all
	if (`"`second'"'=="" | `"`second'"'==" ") & `"`using'"'~="" {
		* non-prefix
		_outreg2 `0'
	}
	else {
		version `version' :	`second'
		_outreg2 `0'
	}
} /* no crosstab */


*** pass it forward
foreach var in dta tex word excel xmlsave see {
	c_local cl_`var' `"`cl_`var''"' 
}

end /* end of outreg2_by */


********************************************************************************************


prog define _outreg2
	* write formatted regression output to file
	
	versionSet
	version `version'
	
syntax [anything] using  [if] [in] [pweight fweight aweight iweight] [,			/*
*/ eqdrop(str) eqkeep(str) drop(str) keep(str) ADDvar(str) eqmatch(str)				/*
*/ INDDrop(str) indyes(str) indno(str)							/*
*/ matrix(str) eb(str) ev(str) noNOBS noOBS								/*
*/ COEfastr APpend REPLACE NOREPLACE SEEout NOSEEOUT CDOUT				/*
*/ EQuationsA(passthru)	Onecol LONG wide SIDEway COMma Quote noNOTes 		/*
*/ ADDNote(passthru) STats(str asis) stnum(str asis) ststr(str asis)		/*
*/ noSE TSTAT Pvalue CI BEta									/*
*/ Level(integer $S_level) 									/*
*/ noPAren PARenthesis(str asis) BRacket BRacketA(str) CTTOP(str)			*]

local usingTemp `"`using'"'
local ifTemp `"`if'"'
local inTemp `"`in'"'
local weightTemp `"`weight'"'
local expTemp `"`exp'"'

local cttop1 `"`cttop'"'
local cttop

local drop1 `"`drop'"'
local drop

* cascading options:
local 0 `", `options'"'
syntax [, noASter	2aster ALPHA(passthru) SYMbol(passthru) 10pct 			/*
*/ LABel LABelA(str asis) TItle(passthru) CTitle(str) CTBOT(str)		/*
*/ EXCEL EXCEL1(str) xmlsave TEX TEX1(passthru) WORD DTA DTAa(str asis) TEXT XPosea(str)		/*
*/ ASTERisk(passthru)										/*
*/ noCONs noNI noR2 ADJr2 E(str)								/*
*/ ADDStat(passthru) ADDText(str) 							/*
*/ EForm MFX Margin1 Margin2(str)							/*
*/ SUM SUM2(str) CROSStab TAB3(str)							/*
*/ sortcol(str) sortvar(str) groupvar(str)					/*
*/ CTTOP(str) drop(str)									/*
*/ again leave(str)										/*
*/ pivot slow(int 1) raw 									*] 

* cascading options:
local 0 `", `options'"'
syntax [, DEC(numlist int >=0 <=11 max=1) FMT(str) 				/*
*/ BDec(numlist int >=0 <=11) BFmt(str asis) 					/*
*/ SDec(numlist int >=0 <=11) SFmt(str asis) 					/*
*/ Tdec(numlist int >=0 <=11 max=1) TFmt(str asis)					/*
*/ PDec(numlist int >=0 <=11 max=1) PFmt(str asis) 				/*
*/ CDec(numlist int >=0 <=11 max=1) CFmt(str asis) 				/*
*/ ADec(numlist int >=0 <=11 max=1)	AFmt(str asis)					/*
*/ RDec(numlist int >=0 <=11 max=1) RFmt(str asis)					/*
*/ AUTO(integer 3) LESS(integer 0) NOAUTO	DECMark(str asis)			/*
*/ POLicy0(str asis) skip NOOMITted	NOBAse noDEPVARshow ]

local using `"`usingTemp'"'
local using `"`usingTemp'"'
local if `"`ifTemp'"'
local in `"`inTemp'"'
local weight `"`weightTemp'"'
local exp `"`expTemp'"'

* consolidate twice-mentioned options by double bys( )
if `"`cttop'"'=="" {
	local cttop `"`cttop1'"'
}
else if `"`cttop1'"'~="" {
	local cttop `"`cttop1', `cttop'"'
}

if `"`drop'"'=="" {
	local drop `"`drop1'"'
}
else if `"`drop1'"'~="" {
	local drop `"`drop1', `drop'"'
}

* name of 1st column containing variable names
local VARIABLES "VARIABLES"
local VARIABLES1 "VARIABLES"

***  a partial list of original macro names
* neq is the number of equation
* numi is e(N_g), the xt number of groups
* noNI is user request to not to report xt number of groups
* ivar is the e(ivar), the id for xt

*** the original ctitle
local ctitle0 `"`ctitle'"'

*** replace/noreplace seeout/noseeout
if "`noreplace'"=="noreplace" {
	local replace ""
	local noreplace ""
}
if "`noseeout'"=="noseeout" {
	local seeout ""
	local noseeout ""
}

*** default warnings
if "`replace'"=="replace" & "`append'"=="append" {
	di in green "replaced when both {opt replace} and {opt append} chosen"
	local replace "replace"
	local append ""
}

*** set default options
if "`replace'"=="" & "`append'"=="" {
	local append "append"
}

*** betaco option into beta
if "`betaco'"=="betaco" {
	local beta "beta" {
}

*** no observation
if "`nobs'"=="nonobs" {
	* recycling the original outreg option
	local obs "noobs"
	local nobs ""
}
* casewise and raw
if "`raw'"=="raw" & "`casewise'"=="casewise" {
	noi di in red "cannot choose {opt case:wise} and {opt raw} at the same time"
	exit 198
}

*** separate the varist from the estimates names
local open=index("`anything'","[")
local close=index("`anything'","]")

if `open'~=0 & `close'~=0 {
	local estimates=trim(substr("`anything'",`open'+1,`close'-`open'-1))
	local temp1=trim(substr("`anything'",1,`open'-1))
	local temp2=trim(substr("`anything'",`close'+1,length("`anything'")))
	local varlist=trim("`temp1' `temp2'")
}
else {
	local varlist "`anything'"
}

*** pre-clean
if "`varlist'"~="" {
	fvtsunab `varlist'
	local varlist "`fvtsunab_list'"
	macroUnique `varlist', names(varlist) number(tt) /* should be another name */
}

*** varlist, keep, drop, eqkeep, eqdrop
if "`varlist'"~="" & "`keep'"~="" {
	di in yellow "{opt keep( )} supersedes {opt varlist} when both specified"
}

*** pre-clean
if "`varlist'"=="" & "`keep'"~="" {
	local varlist `keep'
}

if "`eqdrop'"~="" & "`eqkeep'"~="" {
	di in red "cannot specify both {opt eqkeep( )} and {opt eqdrop( )}"
	exit 198
}

*** parse addstats new location 1 of 2
*** parse addstat to convert possible r(), e(), and s() macros to numbers
* (to avoid conflicts with r-class commands used in this program)
if `"`addstat'"'!="" {
	_addstat_parse, addstat(`addstat') adec(`adec') afmt(`afmt') auto(`auto') less(`less') `noauto'	decmark(`decmark')
	local addstat "addstat(`addstat')"
}

*** preclean drop & keep
*if "`drop'"~="_all" | "`drop'"~="*"{
*	stop
*}

* if _tab3 was accomodated
* one by one to accomodate MISSING from _tab3
if "`drop'"~="" {
	fvtsunab `drop', onebyone
	local drop "`fvtsunab_list'"
	macroUnique `drop', names(drop) /* should be dropList */
}

if "`keep'"~="" {
	fvtsunab `keep', onebyone
	macroUnique `fvtsunab_list', names(keepList)
}

if "`sortvar'"~="" {
/*	gettoken first second: sortvar, parse(" ")
	local sortvar
	while `"`first'"'~="" {
		cap tsunab temp : `sortvar'
		if !_rc {
			local sortvar `"`sortvar' `temp'"'
		}
		gettoken first second: second, parse(" ")
	}
*/
	tokenize `sortvar'
	local num 1
	local collect ""
	while "``num''"~="" {
		cap tsunab temp : ``num''
		if !_rc {
			local collect "`collect' `temp'" 
		}
		else {
			local collect "`collect' ``num''" 	
		}
		local num=`num'+1
	}
	local sortvar "`collect'"
	macroUnique `sortvar', names(sortvar)
}
if "`sortvar'"~="" & "`groupvar'"~="" {
	noi di in red "cannot choose both {opt sortvar} and {opt groupvar}"
	exit 198
}
if "`groupvar'"~="" {
	tokenize `groupvar'
	local num 1
	local collect ""
	while "``num''"~="" {
		cap tsunab temp : ``num''
		if !_rc {
			local collect "`collect' `temp'" 
		}
		else {
			local collect "`collect' ``num''" 	
		}
		local num=`num'+1
	}
	local groupvar "`collect'"
	macroUnique `groupvar', names(groupvar)
}

* unambiguate the names of stored estimates (wildcards)
if "`estimates'"~="" {
	local collect ""
	foreach var in `estimates' {
		local temp "_est_`var'"
		local collect "`collect' `temp'"
	}
	unab estimates : `collect'
	local collect ""
	foreach var in `estimates' {
		local temp=substr("`var'",6,length("`var'")-4)
		local collect "`collect'`temp' "
	}
	local estimates=trim("`collect'")
}

* or use est_expand


tempname estnameUnique
* a place holding name to the current estimates that has no name entered into the outreg

if "`estimates'"=="" {
	local estStored 0
	local estimates="`estnameUnique'"
}
else {
	if "`Version7'"=="" {
		* it is version 7
		noi di in red "version 7 cannot specify stored estimates: " in white "`estimates'"
		exit 198
	}
	local estStored 1
	macroUnique `estimates', names(estimates)
}

*** checking sum and crosstab
local check1 `=("`crosstab'"~="" | "`tab3'"~="")'
local check2 `=("`sum'"~="" | "`sum2'"~="")'
local check3 `=("`mfx'"~="")'
local checks=`check1'+`check2'+`check3'

if `checks'>=2 {
	di in yel "cannot specify more than one of {opt sum}, {opt crosstab}, or {opt mfx} options"
	exit 198
}


if "`sum'"=="sum" & "`sum2'"=="" {
	local sum2 "regress"
}

if "`sum'"=="" {
	* omit by default
	*local noomitted noomitted
	local nobase nobase
}


*** assign e(sample) if it exists
cap confirm matrix e(b)
local ifList `"`if'"'
if _rc==0 & "`raw'"~="raw" {
	if `"`ifList'"'=="" {
		local ifList if e(sample)
	}
	else {
		local ifList `if' & e(sample)
	}
}


*** assign weights if it exists, but override it if user specified
if `"`weight'`exp'"'=="" {
	if `"`e(wexp)'"'~="" & `"`e(wtype)'"'~="" {
		local weight `e(wtype)' `e(wexp)'
	}
}


*** pweight not compatible with sum option
if `"`weight'"'=="pweight" & "`sum'"=="sum" {
	noi di in red "cannot use pweight with sum option"
	exit 198
}

*** handle policy 1 of 3
if "`policy0'"~="" {
	fvunab policyList: `policy0'
	local cc: word count `policyList'
	if ("`label'"~="" | "`labelA'"~="") {
		local com
		forval num=1/`cc' {
			local tt : word `num' of `policy0'
			
			cap local thisname : var lab `tt'
			cap local thisname = subinstr(`"`thisname'"',"(","[",.)
			cap local thisname = subinstr(`"`thisname'"',")","]",.)
			cap local thisname = subinstr(`"`thisname'"',","," ",.)
			cap local thisname = subinstr(`"`thisname'"',":"," ",.)
			cap local thisname = subinstr(`"`thisname'"',`"""'," ",.)
			
			if `"`thisname'"' =="" {
				local thisname `"`tt'"'
			}
			
			if "`ctbot'"~="" {
				local ctbot `"`ctbot', `thisname'"'
			}
			else {
				local ctbot `"`ctbot'`com' `thisname'"'
				local com ,
			}
		}
	}
	else {
		local com
		forval num=1/`cc' {
			local tt : word `num' of `policy0'
			if "`ctbot'"~="" {
				local ctbot `"`ctbot', `tt'"'
			}
			else {
				local ctbot `"`ctbot'`comma' `tt'"'
				local com ,
			}
		}
	}
}

*** get crosstab
if "`crosstab'"=="crosstab" {
	qui _tab3 `varlist' `if' `in' [`weight'`exp']
	local eretrun eretrun
	
	local ebnames "e(freq)"
	local eVnames "e(percent)"
	local r2 "nor2"
	local sortcol "name"
	local obs "noobs"
	if `"`addstat'"'=="" {
		local addstat `"addstat("Total", e(total))"'
	}
	else {
		gettoken part rest: addstat, parse(" (")
		gettoken part rest: rest, parse(" (") /* strip off "addstat(" */
		local addstat `"addstat("Total", e(total), `rest'"'
	}
	
	* augment (usually has bys( ) variables in them)
	if `e(total)'==0 {
		local drop `"MISSING `drop'"'
	}
	
	if `"`ctitle0'"'=="" {
		local ctitle `"`varlist'"'
	}
	
	local VARIABLES `"`varlist'"'
	local notes "nonotes"
	
	local varlist ""
}
else if "`sum2'"~="" {
	local eretrun eretrun
	local r2 "nor2"
	
	* allowable: log regress noindep detail
	optionSyntax, valid(log regress noindep detail) name(sum2) nameShow(sum( )) content(`sum2')
	
	if "`noindep'"=="noindep" & "`detail'"=="" {
		local regress "regress"
	}
	
	if "`log'"=="log" & "`detail'"=="detail" {
		di in red "cannot use both {opt log} and {opt detail} for {opt sum( )} option"
		exit 198
	}
	if "`log'"=="log" {
		
		* always raw because e(sample) might be empty for version 11
		noi _sum2 `if' `in' [`weight'`exp'], `log' raw
		
		local r2 "nor2"
		local notes "nonotes"
		local aster "noaster"
		local stats "coef"
		local obs "noobs"
		if `"`ctitle0'"'=="" {
			local ctitle `"`cttop',  \`depvar'"'
		}
		di
	}
	if "`detail'"=="detail" {
		* always raw because e(sample) might be empty for version 11
		noi _sum2 `if' `in' [`weight'`exp'], `detail' raw
		
		local r2 "nor2"
		local notes "nonotes"
		local aster "noaster"
		local stats "coef"
		local obs "noobs"
		if `"`ctitle0'"'=="" {
			local ctitle `"`cttop',  \`depvar'"'
		}
		di
	}
	if "`regress'"=="regress" {
******************** take off the number in the front for reg3 dependent variables 2price 3price etc
******************** unab, tsuab
		
		if "`e(depvar)'"~="" | "`e(depvar)'"~="." {
			local sumVar1 `e(depvar)'
		}
			
			* borrowed from below (for multiple equations)
			* workaround for 8.0: e(b) must be converted to a regular matrix to get at it
			tempname tempMatrix
			mat `tempMatrix'=e(b)
			local sumVar2: colnames `tempMatrix'
			
			* workaround for 8.0: e(b) must be converted to a regular matrix to get at it
			local eqlist: coleq `tempMatrix'
			
			if "`Version7'"~="" {
				local eqlist: list clean local(eqlist)
				local eqlist: list uniq local(eqlist)
			}
			else {
				* probably needed for the first character
				local temp=index("`eqlist'","_")
				if `temp'==1 {
					local eqlist=subinstr("`eqlist'", "_", "", .)
				}
				* also make unique
				macroUnique `eqlist', names(eqlist7) number(eqcount7)
				local eqlist `eqlist7'
			}
			
			* counting the number of equation
			local eqcount: word count `eqlist'
			* local eqcount : list sizeof eqlist
		
		* redundant subtractions
		*local minus "_cons"
		*local sumVar2: list sumVar2 - minus
		* do it by hand:
		tokenize `sumVar2'
		local num 1
		local sumVar2 ""
		
		if "`sumomit'"=="" {
			while "``num''"~="" {
				gettoken one two: `num', parse(".")
				if "``num''"~="_cons" & "`one'"~="o" {
					local sumVar2 "`sumVar2' ``num''"
				}
				else if "``num''"~="_cons" {
					local two=substr("`two'",2,.)
					local sumVar2 "`sumVar2' `two'"
				}
				local num=`num'+1
			}
		}
		else {
			* manually take out o. prefix as well if requested (NOT IMPLEMENTED)
			while "``num''"~="" {
				gettoken one two: `num', parse(".")
				if "``num''"~="_cons" & "`one'"~="o" {
					local sumVar2 "`sumVar2' ``num''"
				}
				local num=`num'+1
			}
		}
		
		
		if "`noindep'"=="noindep" {
			noi _sum2 `sumVar2' `if' `in' [`weight'`exp'],  `raw'
		}
		else {
			noi _sum2 `sumVar1' `sumVar2' `if' `in' [`weight'`exp'],  `raw'
		}
		
		if 1<`eqcount' & `eqcount'<. {
			noi di in yel "Check your results; -sum- option not meant for multiple equation model"
		}
	}
	
	local ebnames "e(mean)"
	local eVnames "e(Var)"
	
	if `"`ctitle'"'=="" {
		if `"`cttop'"'=="" {
			local cttop `"mean, (sd)"'
			if `"`if'"'~="" {
				gettoken first second: if, parse(" ")
				local cttop `"`cttop',  `second'"'
			}
			if `"`in'"'~="" {
				local cttop `"`cttop',  `in'"'
			}
		}
		else {
			local cttop `"`cttop',  mean, (sd)"'
			if `"`if'"'~="" {
				gettoken first second: if, parse(" ")
				local cttop `"`cttop',  `second'"'
			}
			if `"`in'"'~="" {
				local cttop `"`cttop',  `in'"'				
			}
		}
	}
	
	loca sum_N
	local r2 "nor2"
	local notes "nonotes"
	local aster "noaster"
	local sortcol "later"
}
else {

if "`matrix'"~="" {
	* old and outdated, replaced with eb and ev options below
	*** matrix names
	local ebnames "`matrix'"
	local eVnames "e(V)"
	
	if "`stats'"=="" {
		local stats "coef"
	}
	if "`r2'"=="" {
		local r2 "nor2"
	}
	if "`aster'"=="" {
		local aster "noaster"
	}
	if "`notes'"=="" {
		local notes "nonotes"
	}
	if "`ctitle'"=="" {
		local ctitle "`matrix'"
	}
	if "`obs'"=="" {
		local obs "noobs"
	}
	if "`e(N)'"~="" {
		local obs
	}
}
else {
	*** ereturn matrix names
	local ebnames "e(b)"
	local eVnames "e(V)"	
	local eretrun eretrun
	
	if "`mfx'"~="mfx" {
		cap confirm matrix e(b)
		if _rc & "`Version7'"~="" & "`sum2'"=="" {
			if "`varlist'"~="" {
				local eretrun
				local raw raw
				
				*di in red "matrix e(b) not found; run/post a regression first"
				*exit 111
				
				* sets e(sample)
				*eretSet `varlist'
			}
			else {
				* it does not exist
				di in red "matrix e(b) not found; run/post a regression, or specify varlist for non-regression outputs"
				exit 111
			}
		}
	}
	else {
		* mfx option
		if "`Version7'"~="" {
			
			local stop 1
			
			cap confirm matrix e(Xmfx_dydx)
			if _rc==0 {
				local ebnames e(Xmfx_dydx)
				local eVnames e(Xmfx_se_dydx)
				local stop 0
				local mfx_ct mfx dydx
			}
			cap confirm matrix e(Xmfx_eyex)
			if _rc==0 {
				local ebnames e(Xmfx_eyex)
				local eVnames e(Xmfx_se_eyex)
				local stop 0
				local mfx_ct mfx eyex
			}
			cap confirm matrix e(Xmfx_eydx)
			if _rc==0 {
				local ebnames e(Xmfx_eydx)
				local eVnames e(Xmfx_se_eydx)
				local stop 0
				local mfx_ct mfx eydx
			}
			cap confirm matrix e(Xmfx_dyex)
			if _rc==0 {
				local ebnames e(Xmfx_dyex)
				local eVnames e(Xmfx_se_dyex)
				local stop 0
				local mfx_ct mfx dyex
			}
			
			if `stop'==1 {
				noi di in red "run {cmd mfx} first"
				exit 111
			}
			
			local eXnames e(Xmfx_X)
		}
		else {
			local ebnames e(Xmfx_eyex)
			local eVnames e(Xmfx_se_eyex)"
		}
		if "`ctitle'"=="" {
			if "`ctbot'"=="" {
				local ctbot `"`mfx_ct'"'
			}
			else {
				local ctbot  `"`mfx_ct', `ctbot'"'
			}
		}
	}

}
}


* noSE: because se indicates stn.err, convert noSE into something else
if "`se'"=="nose" {
	local se_skip "se_skip"
}


* stats( ) is not compatible with two-column options
if "`stats'"~="" {
	if "`se'"=="nose" {
		di in red "cannot specify both {opt st:ats( )} and {opt nose} options"
		exit 198
	}
	if "`ci'"=="ci" {
		di in red "cannot specify both {opt st:ats( )} and {opt ci} options"
		exit 198
	}
	if "`tstat'"=="tstat" {
		di in red "cannot specify both {opt st:ats( )} and {opt tstat} options"
		exit 198
	}
	if "`pvalue'"=="pvalue" {
		di in red "cannot specify both {opt st:ats( )} and {opt p:value} options"
		exit 198
	}
	if "`beta'"=="beta" {
		di in red "cannot specify both {opt st:ats( )} and {opt be:ta} options"
		exit 198
	}
}

* keep out depvar
if "`se'"=="nose" | "`ci'"=="ci" | "`tstat'"=="tstat" | "`pvalue'"=="pvalue" | "`beta'"=="beta" {
	local depvarshow nodepvarshow
}

if `"`eb'"'~="" | `"`ev'"'~="" {
	* replacement for matrix option
	local eretrun eretrun
	
	if `"`eb'"'~="" {
		local ebnames "`eb'"
	}
	if `"`ev'"'~="" {
		local eVnames "`ev'"
	}
	if "`stats'"=="" {
		local stats "coef se"
	}
	if "`r2'"=="" {
		local r2 "nor2"
	}
	if "`aster'"=="" {
		local aster "noaster"
	}
	if "`notes'"=="" {
		local notes "nonotes"
	}
	if "`ctitle'"=="" {
		local ctitle "`eb'"
	}
	if "`obs'"=="" {
		local obs "noobs"
	}
	if "`e(N)'"~="" {
		local obs
	}
}


* always se instead of tstat
if "`tstat'"~="tstat" & "`pvalue'"~="pvalue" & "`ci'"~="ci" & "`beta'"~="beta" {
	if "`stats'"=="" {
		local se "se"
	}
}
else {
	local se ""
}

if "`parenthesis'"=="" & "`paren'"~="noparen" {
	if "`ci'"~="" {
		local parenthesis "ci"
	}
	if "`pvalue'"~="" {
		local parenthesis "pval"
	}
	if "`tstat'"~="" {
		local parenthesis "tstat"
	}
	if "`beta'"~="" {
		local parenthesis "beta"
	}
	if "`se'"=="se" {
		local parenthesis "se"
	}
}

*** clean up file name, enclose .txt if no file type is specified
*** else take care of user-specified extension names for excel xmlsave word tex dta files
local rest "`using'"
* strip off "using"
gettoken part rest: rest, parse(" ")
* strip off quotes
gettoken first second: rest, parse(" ")
cap local rest: list clean local(rest)

local rabbit `"""'
if index(`"`using'"', ".")==0 {
	local file = `"`rabbit'`first'.txt`rabbit'"'
	local using = `"using `file'"'
}
else {
	local file = `"`rabbit'`first'`rabbit'"'
	local using = `"using `file'"'
	
	* strip off quotes and extension
	gettoken first second: file, parse(" ")
	local temp = `"`first'"'
	
	local next_dot = index(`"`temp'"',".")
	local next_strip = substr(`"`temp'"',1,`=`next_dot'-1')
	local strippedname = substr(`"`temp'"',1,`=`next_dot'-1')
	
	* check for more dots
	local change 0
	while `change'==0 {
		local temp = substr(`"`temp'"',`=`next_dot'+1',.)
		if index(`"`temp'"', ".")~=0 {
			local next_dot = index(`"`temp'"',".")
			local next_strip = substr(`"`temp'"',1,`=`next_dot'-1')
			local strippedname = `"`strippedname'.`next_strip'"'
		}
		else {
			* no change
			local last_strip = `"`temp'"'
			local change 1
		}
	}
	
	*** check for manual rtf doc docx xlm xls xlsx csv extensions
	if `"`last_strip'"'=="rtf" | `"`last_strip'"'=="doc" | `"`last_strip'"'=="docx" {
		local word "word"
		
		local file = `"`rabbit'`strippedname'.txt`rabbit'"'
		local using = `"using `file'"'
		local wordFile "`last_strip'"
	}
	if `"`last_strip'"'=="xls" | `"`last_strip'"'=="xlsx" | `"`last_strip'"'=="xml" | `"`last_strip'"'=="xlm" | `"`last_strip'"'=="csv" {
		if "`xmlsave'"=="" {
			local excel "excel"
		}
		
		local file = `"`rabbit'`strippedname'.txt`rabbit'"'
		local using = `"using `file'"'
		local excelFile "`last_strip'"
	}
	if `"`last_strip'"'=="tex" {
		if `"`tex1'"'=="" {
			local tex "tex"
		}
		
		local file = `"`rabbit'`strippedname'.txt`rabbit'"'
		local using = `"using `file'"'
		local texFile "`last_strip'"
	}
}

* put excel in
if `"`excel1'"'~="" {
	local excel "excel"
}

*** confirm the output file existance, to be adjusted later
cap confirm file `file'
if !_rc {
	* it exists
	local fileExist 1
}
else {
	local fileExist 0
}

*** mainfile
* cleaning the user provided inputs

if "`long'"=="long" & "`onecol'"=="onecol" {
	di in yellow "{opt long} implies {opt o:necol} (no need to specify both)"
}
if "`long'"=="long" & "`onecol'"~="onecol" {
	local onecol "onecol"
}

if ("`tstat'"!="")+("`pvalue'"!="")+("`ci'"!="")+("`beta'"!="")>1 {	
	di in red "choose only one of tstat, pvalue, ci, or beta"
	exit 198
}

if `level'<10 | `level'>99 {
	di in red "level() invalid"
	exit 198
}

if `"`paren'"'=="noparen" & `"`parenthesis'"'~="" {
	di in red "cannot choose both {opt nopa:ren} and {opt paren:thesis()} option"
	exit 198
}
if `"`paren'"'=="noparen" & `"`bracketA'"'~="" {
	di in red "cannot choose both {opt nopa:ren} and {opt br:acket()} option"
	exit 198
}
if  `"`bracket'"'~="" & `"`bracketA'"'~="" {
	di in red "cannot choose both {opt br:acket} and {opt br:acket()} option"
	exit 198
}

if "`symbol'"=="" & "`sigsymb'"~= "" {
	local symbol "`sigsymb'"
}
if `"`10pct'"'~="" & "`sigsymb'"~="" {
	di in red "cannot choose both {opt 10pct} and {opt sigsymb( )}"
	exit 198
}

if `"`10pct'"'~="" & "`symbol'"~="" {
	di in red "cannot choose both {opt 10pct} and {opt symbol( )}"
	exit 198
}
if `"`10pct'"'~="" & "`symbol'"=="" {
	local symbol `"symbol(**, *, +)"'
}
if "`aster'"=="noaster" & ("`asterisk'"~="" | "`symbol'"!="") {
	if "`asterisk'"~="" {
		di in red "cannot choose both {opt noaster} and {opt asterisk( )}"
	}
	else {
		di in red "cannot choose both {opt noaster} and {opt symbol( )}"
	}
	exit 198
}

if (`"`addnote'"'!="" & "`append'"=="append" & `fileExist'==1) {
	di in yellow "warning: addnote ignored in appended columns"
}

*** LaTeX options
local tex = ("`tex'"!="")
if "`tex1'"!="" {
	if `tex' {
		di in red "may not specify both {opt tex} and {opt tex()} options"
		exit 198
	}
	local tex 1
	
	gettoken part rest: tex1, parse(" (")
	gettoken texopts zilch: rest, parse(" (") match(parns) /* strip off "tex1()" */
}

_texout_parse, `texopts'

* insert nopretty
local check=index(`"`tex1'"',"nopretty")
if `check'==0 {
	local check=index(`"`tex1'"',"pretty")
	if `check'==0 {
		* neither
		local texopts "nopretty `texopts'"
	}
}


*** label options
if "`label'"=="label" & "`labelA'"~="" {
	di in red "cannot specify both {opt lab:el} and {opt lab:el()} options"
	exit 198
}
if "`labelA'"~="" {
	* pre-clean
	optionSyntax, valid(insert upper lower proper) name(labelA) nameShow(label( )) content(`labelA')
	local labelOption `"`optionList'"'
	if "`proper'"~="" & "`upper'"~="" {
		noi di in red "cannot specify together: label(proper upper)"
		exit 198
	}
	if "`proper'"~="" & "`lower'"~="" {
		noi di in red "cannot specify together: label(proper lower)"
		exit 198
	}
	if "`lower'"~="" & "`upper'"~="" {
		noi di in red "cannot specify together: label(lower upper)"
		exit 198
	}
}

*** equationsA options
if "`equationsA'"~="" {
	gettoken part rest: equationsA, parse(" (")
	gettoken equationsOption zilch: rest, parse(" (") match(parns) /* strip off "label()" */
	local equationsOption=trim("`equationsOption'")
	
	if "`equationsOption'"~="auto" {
		di in red "cannot specify any option other than {opt auto} for {opt eq:uation( )}"
		exit 198
	}
	else if "`equationsOption'"~="auto" {
		*local label "label"
	}
}


if (`"`addstat'"'=="" & "`adec'"!="" & "`e'"=="" ) {
	di in red "cannot choose adec option without addstat option"
	exit 198
}
if "`adec'"=="" {
	* disabled
	*local dec 3
	*local adec = `dec'
}

if "`quote'"!="quote" {
	local quote "noquote"
}

tempname df_r

if "`margin1'"~="" | "`margin2'"~="" {
	if "`mfx'"=="mfx" {
		di in red "cannot specify both {opt mfx} and {opt margin} options"
		exit 198
	}
	
	local margin = "margin"
	if "`margin2'"~="" {
		local margucp "margucp(_`margin2')"
		scalar `df_r' = .
		if "`margin1'"~="" {
			di in red "may not specify both margin and margin()"
			exit 198
		}
	}
	else {
		if "`e(cmd)''"=="tobit" {
			di in red "dtobit requires margin({u|c|p}) after dtobit command"
			exit 198
		}
	}
}


*** titlefile needs set out here
tempfile titlefile

*** logistic reports coeffients in exponentiated form (odds ratios)
if "`cmd'"=="logistic" {
	local eform "eform"
	
	* report no cons
	if "`eform'"=="eform" {
		local cons "nocons"
	}
}

* force them long
if "`e(cmd)'"=="oprobit" | "`e(cmd)'"=="ologit" {
	local long long
	local onecol onecol
}

if "`wide'"=="wide" {
	local long
	local onecol
}

*** stats( ) option cleanup : dealing with rows/stats to be reported per variable/coeff
local statsValid "eqname varname label label_pr label_up label_low test001 test01 test05 test10 coef se tstat pval ci aster blank beta ci_low ci_high N sum_w mean Var sd skewness kurtosis sum min max p1 p5 p10 p25 p50 p75 p90 p95 p99 cv range iqr semean median count covar corr pwcorr spearman pcorr semipcorr pcorrpval tau_a tau_b"

* level coef_eform se_eform coef_beta se_beta"

local asterAsked 0
local betaAsked ""

/*
if `"`estats'"'~="" {
	* the names of the available stats in e(matrices)
	local ematrices ""
	local var: e(matrices)
	
	*noi di in yellow "`var'"
	
	tokenize `var'
	local i=1
	while "``i''"~="" {
		*** di "e(``i'')" _col(25) "`e(``i'')'"
		local ematrices="`ematrices'``i'' "
		local i=`i'+1
	}
}
*/

if "`se_skip'"=="se_skip" {
	local statsMany 1
	local statsList "coef"
}
else if `"`stats'"'~="" {
	* take out commas
	gettoken one two: stats, `bind' parse(", ")
	gettoken comma rest: two, `bind' parse(", ")
	if "`comma'"=="," {
		local two `"`rest'"'
	}
	local tempList `"`one'"'
	while `"`two'"'~="" & `"`two'"'~=" " {
		gettoken one two: two, `bind' parse(", ")
		gettoken comma rest: two, `bind' parse(", ")
		if "`comma'"=="," {
			local two `"`rest'"'
		}
		local tempList `"`tempList' `one'"'
	}
	local stats `"`tempList'"'
	local tempList
	
	local matList
	
	
	* need to count using -gettoken, bind- instead of merely -local statsMany : word count `stats'-
	
	local num=0
	local statsMany 0
	local two `"`stats'"'
	
	while `"`two'"'~="" & `"`two'"'~=" " {
		local num=`num'+1
		local statsMany=`statsMany'+1
		
		gettoken one two: two, `bind' parse(", ")
		gettoken comma rest: two, `bind' parse(", ")
		if "`comma'"=="," {
			local two `"`rest'"'
		}
	
		local stats`num' `"`one'"'
		
		* it must be one of the list
		local test 0
		foreach var in `statsValid' {
			if "`var'"=="`stats`num''" & `test'==0 {
				local test 1
			}
			
			* checking if aster/beta specified
			if "`stats`num''"=="aster" {
				local asterAsked 1
			}
			if "`stats`num''"=="beta" {
				local betaAsked "betaAsked"
			}
		}
		if `test'==0 {
			* not on the list of valid ones
			capture confirm matrix `stats`num''
			if !_rc {
				* matrix exists
				local matList `"`matList' `stats`num''"'
               	}
			else {
				* send it to parser
				cap _stats_parse, `stats`num''
				if _rc~=0 {
					noi di in white "`stats`num''" in red " is not a valid stats, str( ), cmd( ), e( ), mat( ), etc. for {opt stats( )}"
					exit 198
				}
			}
		}
		
		* okay to add:
		local statsList "`statsList' `stats`num''"
	}
}
else {
	local statsMany 2
	
	if "`ci'"=="ci" {
		if "`eform'"=="eform" {
			local statsList "coefEform ciEform"
		}
		else {
			local statsList "coef ci"
		}
	}
	else if "`beta'"=="beta" {
		local statsList "coef beta"
	}
	
	* regular: tstat, pval, or se
	else if "`eform'"=="eform" {
		local statsList "coefEform seEform"
		
		if "`tstat'"=="tstat" {
			local statsList "coefEform tstat"
		}
		else if "`pvalue'"=="pvalue" {
			local statsList "coefEform pval"
		}
	}
	else {
		local statsList "coef se"
		
		if "`tstat'"=="tstat" {
			local statsList "coef tstat"
		}
		else if "`pvalue'"=="pvalue" {
			local statsList "coef pval"
		}
	}
}

* when stats(aster) specified, aster( ) should not be attached to coef unless asked
if `asterAsked'==1 & "`asterisk'"=="" {
	* the encased blank will trigger the parsing codes in makeFile
	local asterisk " "
}


* update when eform specified
if "`eform'"=="eform" {
	* blank at end
	local statsList "`statsList' "
	local statsList : subinstr local statsList "coef " "coefEform ", all
	local statsList : subinstr local statsList "ci " "ciEform ", all
	local statsList : subinstr local statsList "se " "seEform ", all
	
	local statsList : subinstr local statsList "ci_high " "ci_highEform ", all
	local statsList : subinstr local statsList "ci_low " "ci_lowEform ", all
}

* parenthesis locations moved to makeFile

* check that nothing appears in parenthesis( ) does not appear in stats( )
macroMinus `parenthesis', names(temp) subtract(`statsList' `stats')
if "`temp'"~="" & "`stats'"~="" {
	noi di in red "`temp' appears in parenthesis( ) but not in stats( )"
	exit 198
}

* clean up matList
if `"`matList'"'~="" {
	tokenize `matList'
	local rnum 1
	local num 1
	while `"``num''"'~="" {
		* take off the parenthesis crap
		local temp
		local temp = substr(`"``num''"',1,2)
		if "`temp'"=="r(" {
			* r( ) matrix
			local content = substr(`"``num''"',3,length("``num''")-3)
			* not currently accepting
			di in red "r-class matrix " in white "``num''" in red " not accepted by {opt stats( )}"
			exit 198
			local rnum=`rnum'+1
		}
		*if "`temp'"=="e(" {
		*	* r( ) matrix
		*	local content = substr(`"``num''"',3,length("``num''")-3)
		*	* not currently accepting
		*	di in red "e-class matrix " in white "``num''" in red " not accepted by {opt stats( )}"
		*	exit 198
		*	local rnum=`rnum'+1
		*}
		local num=`num'+1
	}
}

*** expand statsList and statsMany according to vector/nonvec matrices

* these two are collected, but not used here
local vectorList
local nonvecList

if "`matList'"~="" {
	tempname matdown
	foreach matname in `matList' {
		mat `matdown'=`matname'		/* NOT transposed */
		local temp= colsof(`matdown')
		
		if `temp'==1 {
			* it's a vector
			local vectorList "`vectorList' `matname'"
		}
		else {
			* it's a non-vector matrix
			local cc= colsof(`matdown')
			local temp0 : colnames(`matdown')
			local temp
			foreach var in `temp0' {
				local temp "`temp' `matname'_`var'"
			}
			local nonvecList "`nonvecList' `temp'"
			
			* add the empty space at end
			local statsList =`"`statsList' "'
			local statsList =subinstr("`statsList'"," `matname' "," `temp' ",.)
			local statsMany `=`statsMany'+`cc'-1'
		}
	}
}

*** run each estimates consecutively
local estmax: word count `estimates'
forval estnum=1/`estmax' {
	local estname: word `estnum' of `estimates'
	if "`estimates'"~="`estnameUnique'" {
		qui estimates restore `estname'
	}
	* to avoid overwriting after the first time, append from the second time around (1 of 3)
	if `estnum'==2 & "`replace'"=="replace" {
		local append "append"
		local replace ""
	}
	
	* the names of the available stats in e( )
	local result "scalars"
	* took out macros from the local result
	local elist=""
	foreach var in `result' {
		local var: e(`var')
		tokenize `var'
		local i=1
		while "``i''"~="" {
			*** di "e(``i'')" _col(25) "`e(``i'')'"
			local elist="`elist'``i'' "
			local i=`i'+1
		}
	}
	macroUnique `elist', names(elist)
	
	* take out N (because it is always reported)
	local subtract "N"
	*cap local elist : list elist - subtract
	macroMinus `elist', names(elist) subtract(`subtract')
	
	* r2 option
	* save the original for the first run and restore prior to each subsequent run
	if `estnum'==1 {
		local r2Save `"`r2'"'
	}
	else {
		local r2 `"`r2Save'"'
	}
	
	*** e(all) option
	* save the original for the first run and restore prior to each subsequent run
	if `estnum'==1 {
		local addstatSave `"`addstat'"'
	}
	else {
		local addstat `"`addstatSave'"'
	}
	
	*** dealing with e( ) option: put it through addstat( )
	* local = expression restricts the length
	*	requires a work-around to avoid subinstr/substr functions
	
	* looking for "all" anywhere
	if "`Version7'"=="" {
		local position=index("`e'","all")
	}
	else {
		local position: list posof "all" in e
	}
	
	if `"`addstat'"'~="" {
		if "`e'"~="" {
			local e: subinstr local e "," " ",all
			macroUnique `e', names(e)
			
			if `position'~=0 {
				local count: word count `elist'
				local addstat=substr("`addstat'",1,length("`addstat'")-1)
				forval num=1/`count' {
					local wordtemp: word `num' of `elist'
					local addstat "`addstat',`wordtemp',e(`wordtemp')"
				}
			}
			else { /* other than all */
				local count: word count `e'
				local addstat=substr("`addstat'",1,length("`addstat'")-1)
				forval num=1/`count' {
					local wordtemp: word `num' of `e'
					local addstat "`addstat',`wordtemp',e(`wordtemp')"
				}
			}
			local addstat "`addstat')"
		}
	}
	
	* if addstat was previously empty
	else if "`addstat'"=="" {
		if "`e'"~="" {
			local e: subinstr	local e "," " ",all
			macroUnique `e', names(e)
			if `position'~=0 {
				local count: word count `elist'
				local addstat "addstat("
				forval num=1/`count' {
					local wordtemp: word `num' of `elist'
					local addstat "`addstat'`wordtemp',e(`wordtemp')"
					if `num'<`count' {
						local addstat "`addstat',"
					}
				}
			}
			else {
				local count: word count `e'
				local addstat "addstat("
				forval num=1/`count' {
					local wordtemp: word `num' of `e'
					local addstat "`addstat'`wordtemp',e(`wordtemp')"
					if `num'<`count' {
						local addstat "`addstat',"
					}
				}
			}
			local addstat "`addstat')"
		}
	}
	
	*** dealing with single/multiple equations
	*** also dealing with non-vector matrices, i.e. multiple columns
	
	tempname regN rsq numi r2mat    b vc b_alone convert
	
	if "`eretrun'"=="" {
		scalar `df_r'=.
	}
	else {
		* getting equation names
		tempname mainMatrix
		mat `mainMatrix'=`ebnames'
		
		* workaround for 8.0: e(b) must be converted to a regular matrix to get at it
		local eqlist: coleq `mainMatrix'
		
		if "`Version7'"~="" {
			local eqlist: list clean local(eqlist)
			local eqlist: list uniq local(eqlist)
		}
		else {
			* probably needed for the first character
			local temp=index("`eqlist'","_")
			if `temp'==1 {
				local eqlist=subinstr("`eqlist'", "_", "", .)
			}
			* also make unique
			macroUnique `eqlist', names(eqlist7) number(eqcount7)
			local eqlist `eqlist7'
		}
	
		* counting before eqkeep/eqdrop
		local eqcount_original: word count `eqlist'
		
		* drop some of multiple equations: 1 of 2
		
		if "`eqdrop'"~="" {
			* may not be a variable
			cap tsunab eqdrop : `eqdrop'
			*cap local eqlist : list eqlist - eqdrop
			macroMinus `eqlist', names(eqlist) subtract(`eqdrop')
			macroUnique `eqlist', names(eqlist)
		}
		
		if "`eqkeep'"~="" {
			* may not be a variable
			cap tsunab eqkeep : `eqkeep'
			local eqlist `"`eqkeep'"'
			macroUnique `eqlist', names(eqlist)
		}
		
		* counting the number of equation
		local eqcount: word count `eqlist'
		* local eqcount : list sizeof eqlist
		
		if "`Version7'"=="" {
			local eqcount `eqcount7'
		}
		
		* 0 if it is multiple equations; 1 if it is a single
		*if 1<`eqcount' & `eqcount'<. {
		if 1<`eqcount_original' & `eqcount_original'<. {
			local univar=0
		}
		else {
			local univar=1
		}
		
		**** snipped portion moved here from above
		* for svy commands with subpop(), N_sub is # of obs used for estimation
		local cmd = e(cmd)
		
		local svy = substr("`cmd'",1,3)
		if "`svy'"=="svy" & e(N_sub) != . {
			scalar `regN' = e(N_sub)
		}  
		else {
			if "`sum2'"=="" {
				scalar `regN' = e(N)
			}
			else {
				scalar `regN' = e(sum_N)
			}
		}
		
		*** set up the usual stuff
		scalar `df_r' = e(df_r)
		local depvar = e(depvar)
		if "`depvar'"=="." {
			local depvar
		}
		
		mat `b'=`ebnames'
		mat `vc'=`eVnames'
		
		if "`mfx'"=="mfx" {
			mat `vc' = `vc'' * `vc'
		}
		
		local bcols=colsof(`b')	/* cols of b */
		local bocols=`bcols'	/* cols of b only, w/o other stats */
		
		* the work around for xtmixed
		if "`e(N_g)'"=="matrix" {
			mat `convert'=e(N_g)
			scalar `numi'=`convert'[1,1]
		}
		else {
			scalar `numi' = e(N_g)
		}
		
		local	robust = e(vcetype)
		if "`robust'"=="." {
			local robust "none"
		}
		local	ivar	 = e(ivar)
		* equals one if true	
		capture local fracpol = (e(fp_cmd)=="fracpoly")
	} /* eretrun */
	
	* parse addstat old location 2 of 2
	* run again to handle e(all)
	if `"`addstat'"'!="" {
		_addstat_parse, addstat(`addstat') adec(`adec') afmt(`afmt') auto(`auto') less(`less') `noauto'	decmark(`decmark')
	}
	
	if "`eretrun'"=="" {
		local univar 0
		local neq 1
	}
	else {
		* usual eret results
		
		*** to deal with eq(auto)
		if `univar'==0 & "`equationsOption'"=="auto" {
			* this means run once, as if it was a single equation
			local univar 1
		}
		
		/*
		*** to deal with eq(auto)
		if `univar'==0 & "`equationsOption'"=="auto" {
			
			forval count=1/`eqcount' {
				
				local temp_eqname: word `count' of `eqlist'
				tempname temp_eq
				mat `temp_eq' = `b'[.,"`temp_eqname':"]
				
				local these: coleq `temp_eq'
				
				
				* remove roweq for explicit varlist
				mat colnames `temp_eq' = _:
				
				local names: colnames `temp_eq'
				*noi di "colnames `colnames'"
				*local bocols = colsof(`b_eq')
			}
		}
		*/
		
	if "`crosstab'"=="" & "`sum2'"=="" {
		*** ad hoc fixes for various multi-equation models
		if "`cmd'"=="mvreg" | "`cmd'"=="sureg" | "`cmd'"=="reg3" {
			local univar = 0 /* multivariate regression (multiple equations) */
			if "`onecol'" != "onecol" {
				mat `r2mat' = `ebnames' /* get column labels */
				local neq = e(k_eq)
				local depvar = "`eqlist'"
				if "`cmd'"=="mvreg" {
					local r2list = e(r2)
				}
				local eq = 1
				while `eq' <= `neq' {
					if "`cmd'"=="mvreg" {
						local r2str: word `eq' of `r2list'
						scalar `rsq' = real("`r2str'")
					}
					else {
						scalar `rsq' = e(r2_`eq')
					}
					mat `r2mat'[1,`eq'] = `rsq'
					local eq = `eq' + 1
				}
			}
			else {
				/* if onecol */
				local r2 = "nor2"	
				scalar `rsq' = .
			}
		} /* `rsq' after `r2list' to avoid type mismatch */
		
		else if "`adjr2'"=="adjr2" {
			scalar `rsq' = e(r2_a)
			if `rsq' == . {
				di in red "Adjusted R-squared (e(r2_a)) not defined; cannot use adjr2 option"
				exit 198
			}
		}
		else {
			scalar `rsq' = e(r2)
		}
		
		if ("`cmd'"=="intreg" | "`cmd'"=="svyintrg" | "`cmd'"=="xtintreg") {
			local depvar : word 1 of `depvar' /* 2 depvars listed */
		}
		
		* nolabels for anova and fracpoly
		*if ("`cmd'"=="anova" | `fracpol' | "`cmd'"=="nl") {
		if ("`cmd'"=="anova" | `fracpol' ) {
			/* e(fp_cmd)!=. means fracpoly */
			local cons "nocons"
		}
		
		*** margin or dprobit: substitute marginal effects into b and vc
		else if ("`cmd'"=="dprobit" | "`margin'"=="margin") {
			if "`cmd'"=="dlogit2" | "`cmd'"=="dprobit2" | "`cmd'"=="dmlogit2" {
				di in yellow "warning: margin option not needed"
			}
			else {
				marginal2, b(`b') vc(`vc') `se' `margucp'
				local bcols = colsof(`b') /* cols of b */
				local bocols = `bcols' /* cols of b only, w/o other stats */
				if "`cmd'"=="dprobit" {
					local cons "nocons"
				}
			}
		}
	} /* not crosstab or sum */
		
		*** to handle single or multiple equations
		local neq = `eqcount'
		local eqlist "`eqlist'"
		if "`onecol'"=="onecol" | `univar'==1 {
			if "`depvar'"=="" {
				local depvar: rowname `ebnames'
				*local depvar: word 1 of `depvar'
			}
		}
	} /* eretrun */
		
		local ctitleList `"`ctitle'"'
		
		*** the column title:
		* save the original ctitle for the first run and restore prior to each subsequent run
		if `estnum'==1 {
			local ctitleSave `"`ctitleList'"'
		}
		else {
			local ctitleList `"`ctitleSave'"'
		}
		
		local cttop_comma `"`cttop',"'
		
		*** label for depvar (for ctitle reporting)
		local ct_depvar
		if "`depvar'"~="" {
			local ct_depvar `depvar'
			if "`label'"=="label" {
				cap local ct_depvar : var label `depvar'
				if `"`ct_depvar'"'=="" {
					local ct_depvar `depvar'
				}
			}
		}
		
		
		*** clean up column titles
		* from current, non-stored estimates
		if (`univar'==1 | "`onecol'"=="onecol") & `estStored'==0 {
			if `"`ctitle0'"'=="" & `"`ctitleList'"'=="" {
				if `"`cttop'"'~="" {
					local ctitleList `"`cttop'"'
				}
				if `"`cttop'"'~="" & "`sum'"=="" & "`sum2'"=="" & "`crosstab'"=="" & "`tab3'"=="" {
					local ctitleList `"`cttop_comma'  `ct_depvar'"'
				}
				
				if `"`cttop'"'=="" & "`sum'"=="" & "`sum2'"=="" & "`crosstab'"=="" & "`tab3'"=="" & "`onecol'"=="" {
					if "`sideway'"=="sideway" {
						local count: word count `statsList'
						if `count'>=1 & `count'<. & "`ctitle0'"=="" {
							local temp: word 1 of `statsList'
							local ctitleList `"`ct_depvar', `temp'"'
							forval num=2/`count' {
								local temp: word `num' of `statsList'
								local ctitleList `"`ctitleList'; `temp'"'
							}
						}
						else {
							local ctitleList `"`ct_depvar'"'
						}
					}
					else {
						* not a sideway
						local ctitleList `"`ct_depvar'"'
					}
				}
			}
		}
		else {
			if `"`ctitle0'"'=="" & `estStored'==0 {
				if "`eqname'"~="" {
					* sometimes multiple depvar, i.e. reg3
					local count: word count `depvar'
					if `count'>=1 & `count'<. & "`ctitle0'"=="" {
						local temp: word 1 of `depvar'
						local ctitleList `"`eqname', `temp'"'
						forval num=2/`count' {

*** needs to be label of depvar
							local temp: word `num' of `depvar'
							local ctitleList `"`ctitleList' ; `eqname', `temp'"'
						}
					}
				}
				else {
					* sometimes multiple depvar, i.e. reg3
					local count: word count `depvar'
					if `count'>=1 & `count'<. {
						local temp: word 1 of `depvar'
						local ctitleList `"`ctitleList' `temp'"'
						forval num=2/`count' {
							local temp: word `num' of `depvar'
							local ctitleList `"`ctitleList' ; `temp'"'
						}
					}
				}
			}
			else if `"`ctitle0'"'=="" {
				* when from stored estimates
				local ctitleList=`"`estname', `ct_depvar'"'
				if `"`eqname'"'~="" {
					local ctitleList=`"`estname', `eqname', `ct_depvar'"'
				}
			}
		}
		
		if `"ctitleList'"'=="" {
			local ctitleList `"`ct_depvar'"'					
		}
		
	*** when `ebnames' includes extra statistics (which don't have variable labels)
	capture mat `b_alone' = `b'[1,"`depvar':"]
	
	if _rc==0 {
		local bocols = colsof(`b_alone')
	}
	else if ("`cmd'"=="ologit" | "`cmd'"=="oprobit") {
		local bocols = e(df_m)
		mat `b_alone' = `b'[1,1..`bocols']
	}
	else if ("`cmd'"=="cnreg" | ("`cmd'"=="tobit" & "`margin'"~="margin")) {
		local bocols = `bocols'-1 /* last element of `ebnames' is not est coef */
		mat `b_alone' = `b'[1,1..`bocols']
	}
	else if ("`cmd'"=="intreg" | "`cmd'"=="svyintrg") {
		mat `b_alone' = `b'[1,"model:"]
		local bocols = colsof(`b_alone')
	}
	else if ("`cmd'"=="truncreg") {
		mat `b_alone' = `b'[1,"eq1:"]
		local bocols = colsof(`b_alone')
	}
	
	* keep these here for sideway option
	if "`statsListKeep'"=="" {
		local statsListKeep "`statsList'"
		local statsManyKeep "`statsMany'"
	}
	if "`ctitleListKeep'"=="" {
		local ctitleListKeep "`ctitleList'"
	}
	
	
	if "`Version7'"=="" {
		local eqlist "`eqlist7'"
	}
	
	*** fix for xtpoisson and version 11 probit etc
	if "`wide'"~="wide" & ("`e(cmd)'"=="xtpoisson" | "`e(cmd)'"=="oprobit" | "`e(cmd)'"=="ologit" | `eqcount'==1) {
		local eqsingle eqsingle
	}
	if (`eqcount'==1) {
		local eqsingle eqsingle
	}
	
	* dependent variable
	if "`sum2'"~="" {
		local depvarshow nodepvarshow
	}
	
	*** create table with makeFile and append to existing table
	* NOTE: makeFile command is rclass
	qui {
		
		* work around for weighted margins
		local makeFile_wt `weight'`exp'
		if "`e(cmd)'"=="margins" {
			local makeFile_wt
		}
		
		cap preserve
		
		*** make univariate regression table (single equation or single column)
		if `univar'==1 | "`onecol'"=="onecol" | "`eqsingle'"=="eqsingle" {
			
			* changing the equation name of univariate case for housekeeping purposes
			if `univar'==1 & "`onecol'"=="onecol" {
				* attach equation marker for onecol output; it sorts better
				* cap in case it already exists
				cap mat colnames `b'= "`depvar':"
			}
			
			*** sideway single equation
			
			if "`sideway'"=="sideway" {
				local sidewayRun "`statsManyKeep'"
				local statsMany 1
			}
			else {
				local sidewayRun 1
			}
			
			forval sidewayWave=1/`sidewayRun' {
				if "`sideway'"=="sideway" {
					* must do it by hand to handle cmd( ) - but "ad hoc" fix inside makeFile
					*local var: word `sidewayWave' of `statsListKeep'
					local statsTwo `"`statsListKeep'"'
					forval temp=1/`sidewayWave' {
						gettoken one statsTwo : statsTwo, `bind'
					}
					local var `"`one'"'
					local statsList `"`var'"'
					
					* parsing ctitleList contents (1.1 of 2), parsing by ";"
					local ctitleTwo `"`ctitleListKeep'"'
					
					forval temp=1/`=`sidewayWave'*2-1' {
						gettoken one ctitleTwo: ctitleTwo, `bind' parse(";")
					
					}
					local ctitleList `"`one'"'
					
					if "`onecol'"~="" {
						if `sidewayRun'==1 {
							*local ctitleList `"`cttop_comma'  Freq, (Percent)"'
						}
						else {
							if `sidewayWave'==1 {
								local ctitleList `" `ctitleList', `var'"'
							}
							else {
								local ctitleList `" `var'"'
							}
						}
					}
					if "`crosstab'"=="crosstab" {
						if `sidewayRun'==1 {
							local ctitleList `"`cttop_comma'  Freq, (Percent)"'
						}
						else {
							if `sidewayWave'==1 {
								local ctitleList `"`cttop_comma'  Freq"'
							}
							else {
								local ctitleList `"`cttop_comma'  Percent"'
							}
						}
					}
					else if `"`ctitleList'"'=="" & `"`cttop'"'~="" {
						if `sidewayWave'==1 {
							local ctitleList `"`cttop_comma'  `depvar', `var'"'
						}
						else {
							local ctitleList `"`var'"'
						}
					}
					else if `"`ctitleList'"'=="" {
						if `sidewayWave'==1 {
							local ctitleList "`depvar', `var'"
						}
						else {
							local ctitleList `"`var'"'
						}
					}
					if `"`ctitleList'"'=="" {
						local ctitleList `"`ctitleListKeep'"'
					}
				}
				else {
					* not sideway
					if "`crosstab'"=="crosstab" {
						local ctitleList `"`cttop_comma'  Freq, (Percent)"'
					}
				}
				
				* cover all eventuality
				if `"`ctitleList'"'=="" {
					local ctitleList `"`depvar'"'
				}
				
				* to avoid overwriting after the first time, append from the second time around (2 of 3)
				if `sidewayWave'==2 & "`replace'"=="replace" {
					local append "append"
					local replace ""
				}
			
		if "`Version7'"=="" {
		* it is version 7
			* b(`b') instead of b(`b_eq'), vc(`vc') instead of vc(`vc_eq')
			makeFile `varlist' `ifList' `in' [`makeFile_wt'], equationsOption(`equationsOption') keep(`keepList') drop(`drop') eqmatch(`eqmatch')					/*
				*/ eqkeep(`eqkeep') eqdrop(`eqdrop') eqlist(`eqlist') 								/*
				*/ `betaAsked' statsMany(`statsMany') statsList(`statsList') `se_skip' `beta' level(`level')		/*
				*/ dec(`dec') fmt(`fmt') bdec(`bdec') bfmt(`bfmt') sdec(`sdec') sfmt(`sfmt') 					/*
				*/ tdec(`tdec') 			pdec(`pdec') 										/*
				*/ rdec(`rdec') 			adec(`adec') 										/*
				*/ `paren' parenthesis(`parenthesis') `bracket'										/*
				*/ bracketA(`bracketA') `aster' `symbol' `cons' `eform' `obs' `ni' `r2' `adjr2' 				/*
				*/ ctitleList(`ctitleList') auto(`auto') `noauto'											/*
				*/ addstat(`addstat') addtext(`addtext') `notes'									/*
				*/ `addnote' `append' regN(`regN') df_r(`df_r') rsq(`rsq') numi(`numi') ivar(`ivar') depvar(`depvar')	/*
				*/ robust(`robust') borows(`bocols') b(`b') vc(`vc') 									/*
				*/ univar(`univar') `onecol' estname(`estname') estnameUnique(`estnameUnique')				/*
				*/ fileExist(`fileExist') less(`less') alpha(`alpha') asterisk(`asterisk') `2aster'				/*
				*/ variables(`VARIABLES') matList(`matList') leave(`leave') sidewayWave(`sidewayWave') `wide'
			* taken out: `se' `pvalue' `ci' `tstat'
		}
		else {
			* b(`b') instead of b(`b_eq'), vc(`vc') instead of vc(`vc_eq')
			makeFile `varlist' `ifList' `in' [`makeFile_wt'], equationsOption(`equationsOption') keep(`keepList') drop(`drop') eqmatch(`eqmatch')					/*
				*/ inddrop(`inddrop') indyes(`indyes') indno(`indno')									/*
				*/ eqkeep(`eqkeep') eqdrop(`eqdrop') eqlist(`eqlist') 								/*
				*/ `betaAsked' statsMany(`statsMany') statsList(`statsList') `se_skip' `beta' level(`level')		/*
				*/ dec(`dec') fmt(`fmt') bdec(`bdec') bfmt(`bfmt') sdec(`sdec') sfmt(`sfmt') 					/*
				*/ tdec(`tdec') tfmt(`tfmt') pdec(`pdec') pfmt(`pfmt') 								/*
				*/ rdec(`rdec') rfmt(`rfmt') adec(`adec')         								/*
				*/ `paren' parenthesis(`parenthesis') `bracket'										/*
				*/ bracketA(`bracketA') `aster' `symbol' `cons' `eform' `obs' `ni' `r2' `adjr2' 				/*
				*/ ctitleList(`ctitleList') auto(`auto') `noauto'											/*
				*/ addstat(`addstat') addtext(`addtext') `notes'									/*
				*/ `addnote' `append' regN(`regN') df_r(`df_r') rsq(`rsq') numi(`numi') ivar(`ivar') depvar(`depvar')	/*
				*/ robust(`robust') borows(`bocols') b(`b') vc(`vc') 									/*
				*/ univar(`univar') `onecol' estname(`estname') estnameUnique(`estnameUnique')				/*
				*/ fileExist(`fileExist') less(`less') alpha(`alpha') asterisk(`asterisk') `2aster'				/*
				*/ variables(`VARIABLES') matList(`matList') leave(`leave') sidewayWave(`sidewayWave') `wide' decmark(`decmark') /*
				*/ `eqsingle' stnum(`stnum') ststr(`ststr') `eretrun' ctbot(`ctbot') /*
				*/ policy0(`policy0') `noomitted' `nobase' `skip' addvar(`addvar') depvarshow(`depvarshow')
			* taken out: `se' `pvalue' `ci' `tstat'
		}
		
		*if "`append'"~="append" {
		if "`append'"~="append" & `sidewayWave'==1 {
				* replace
					outsheet2 report reportCol `using', nonames `quote' `comma' replace slow(`slow')
					local fileExist 1
				}
				
				else {
					*** appending
					* confirm the existence of the output file
					local rest "`using'"
					* strip off "using"
					gettoken part rest: rest, parse(" ")
					if `fileExist'==1 {
						appendFile `using',   titlefile(`"`titlefile'"') /*
							*/`sideway' `onecol' sortcol(`sortcol') sortvar(`sortvar') groupvar(`groupvar') `quote' `comma' slow(`slow')
						
						outsheet2 v* reportCol `using', nonames `quote' `comma' replace slow(`slow')
						*drop v*
					}
					else {
						* does not exist and therefore needs to be created
						outsheet2 report reportCol `using', nonames `quote' `comma' replace slow(`slow')
						local fileExist 1
					}
				}
				restore, preserve
			} /* sideway single equation */
		}
		
		*** make multiple equation regression table (wide format)
		else {
			
			tempname b_eq vc_eq
			
			* getting the depvar list from eqlist
			local eq = 1
			while `eq' <= `neq' {
				
				local eqname: word `eq' of `eqlist'
				local depvar: word `eq' of `eqlist'
				
				if `eq'==1 {
					if `estStored'==1 & "`estname'"~="" {
						if `"`ctitle0'"'=="" & `eq'==1 {
							local ctitleList "`estname', `depvar'"
						}
					}
					else if `"`ctitle0'"'=="" {
						if `"`cttop'"'~="" {
							local ctitleList "`cttop_comma'  `depvar'"
						}
						else {
							local ctitleList "`depvar'"
						}
					}
				}
				else if `"`ctitle0'"'=="" {
					* subsequent columns
					if `estStored'==1 & "`estname'"~="" {
						local ctitleList ", `depvar'"
					}
					else {
						local ctitleList "`depvar'"
					}
				}
				
				*** r2mat doesn't exist for mlogit ="capture", the rest for non-eretrun
				capture scalar `rsq' = `r2mat'[1,`eq']
				cap mat `b_eq' = `b'[.,"`eqname':"]
				
				* remove roweq from b_eq for explicit varlist
				cap matrix colnames `b_eq' = _:
				cap mat `vc_eq' = `vc'["`eqname':","`eqname':"]
				cap local bocols = colsof(`b_eq')
				
				*** sideway multiple equation
				
				if "`sideway'"=="sideway" {
					local sidewayRun "`statsManyKeep'"
					local statsMany 1
				}
				else {
					local sidewayRun 1
				}
				
				forval sidewayWave=1/`sidewayRun' {
					if "`sideway'"=="sideway" {
						* must do it by hand to handle cmd( ) - but "ad hoc" fix inside makeFile
						*local var: word `sidewayWave' of `statsListKeep'
						local statsTwo `"`statsListKeep'"'
						forval temp=1/`sidewayWave' {
							gettoken one statsTwo : statsTwo, `bind'
						}
						local var `"`one'"'
						local statsList "`var'"
						
						
						* parsing ctitleList contents (1.2 of 2), parsing by ";"
						local ctitleTwo `"`ctitleListKeep'"'
						forval temp=1/`=`sidewayWave'*2-1' {
							gettoken one ctitleTwo: ctitleTwo, `bind' parse(";")
						}
						local ctitleList1 `"`ctitleList', `one'"'
						
						
						local ctitleList1 `"`ctitleList'"'
						if `"`ctitleList1'"'=="" {
							local ctitleList1 "`var'"
						}
					}
					else {
						local ctitleList1 `"`ctitleList'"'
					}
					
					* to avoid overwriting after the first time, append from the second time around (3 of 3)
					if `sidewayWave'==2 & "`replace'"=="replace" {
						local append "append"
						local replace ""
					}
					
					if `eq'>1 & `sidewayWave'>1 {
						local addstat ""
					}
					
					if `eq' == 1 & "`append'"!="append" & `sidewayWave'==1 {
						local apptmp ""
					}
					else {
						local apptmp "append"
					}
					
				* cover all eventuality
				if `"`ctitleList'"'=="" {
					local ctitleList `"`depvar'"'
				}
				
				if "`Version7'"=="" {
					* it is version 7
					makeFile `varlist' `ifList' `in' [`makeFile_wt'], equationsOption(`equationsOption') keep(`keepList') drop(`drop') eqmatch(`eqmatch')					/*
						*/ eqkeep(`eqkeep') eqdrop(`eqdrop') eqlist(`eqlist')									/*
						*/ `betaAsked' statsMany(`statsMany') statsList(`statsList') `se_skip' `beta' level(`level')		/*
						*/ dec(`dec') fmt(`fmt') bdec(`bdec') bfmt(`bfmt') sdec(`sdec') sfmt(`sfmt') 					/*
						*/ tdec(`tdec') 			pdec(`pdec') 										/*
						*/ rdec(`rdec') 			adec(`adec') 										/*
						*/ `paren' parenthesis(`parenthesis') `bracket'										/*
						*/ bracketA(`bracketA') `aster' `symbol' `cons' `eform' `obs' `ni' `r2' `adjr2'				/*
						*/ ctitleList(`ctitleList1') auto(`auto') `noauto'											/*
						*/ addstat(`addstat') addtext(`addtext') `notes'									/*
						*/ `addnote' `apptmp' regN(`regN') df_r(`df_r') rsq(`rsq') numi(`numi') ivar(`ivar') depvar(`depvar')	/*
						*/ robust(`robust') borows(`bocols') b(`b_eq') vc(`vc_eq') 								/*
						*/ univar(`univar') `onecol' estname(`estname') estnameUnique(`estnameUnique')				/*
						*/ fileExist(`fileExist') less(`less') alpha(`alpha') asterisk(`asterisk') `2aster'				/*
						*/ variables(`VARIABLES') matList(`matList') leave(`leave') sidewayWave(`sidewayWave')  `wide'
					* taken out: `se' `pvalue' `ci' `tstat'
				}
				else {
					makeFile `varlist' `ifList' `in' [`makeFile_wt'], equationsOption(`equationsOption') keep(`keepList') drop(`drop') eqmatch(`eqmatch')					/*
						*/ inddrop(`inddrop') indyes(`indyes') indno(`indno')									/*
						*/ eqkeep(`eqkeep') eqdrop(`eqdrop') eqlist(`eqlist')									/*
						*/ `betaAsked' statsMany(`statsMany') statsList(`statsList') `se_skip' `beta' level(`level')		/*
						*/ dec(`dec') fmt(`fmt') bdec(`bdec') bfmt(`bfmt') sdec(`sdec') sfmt(`sfmt') 					/*
						*/ tdec(`tdec') tfmt(`tfmt') pdec(`pdec') pfmt(`pfmt') 								/*
						*/ rdec(`rdec') rfmt(`rfmt') adec(`adec')         								/*
						*/ `paren' parenthesis(`parenthesis') `bracket'										/*
						*/ bracketA(`bracketA') `aster' `symbol' `cons' `eform' `obs' `ni' `r2' `adjr2'				/*
						*/ ctitleList(`ctitleList1') auto(`auto') `noauto'											/*
						*/ addstat(`addstat') addtext(`addtext') `notes'									/*
						*/ `addnote' `apptmp' regN(`regN') df_r(`df_r') rsq(`rsq') numi(`numi') ivar(`ivar') depvar(`depvar')	/*
						*/ robust(`robust') borows(`bocols') b(`b_eq') vc(`vc_eq') 								/*
						*/ univar(`univar') `onecol' estname(`estname') estnameUnique(`estnameUnique')				/*
						*/ fileExist(`fileExist') less(`less') alpha(`alpha') asterisk(`asterisk') `2aster'				/*
						*/ variables(`VARIABLES') matList(`matList') leave(`leave') sidewayWave(`sidewayWave') decmark(`decmark')  /*
						*/ `eqsingle' stnum(`stnum')  ststr(`ststr') `eretrun' ctbot(`ctbot')  `wide' /*
						*/ policy0(`policy0') `noomitted' `nobase' `skip' addvar(`addvar') depvarshow(`depvarshow')
						* taken out: `se' `pvalue' `ci' `tstat'
				}
				
					* create new file: replace and the first equation		
					if `eq' == 1 & "`append'"!="append" & `sidewayWave'==1 {
						outsheet2 report reportCol `using', nonames `quote' `comma' `replace' slow(`slow')
						local fileExist 1
					}
					* appending here: another estimates or another equation
					else {
						* confirm the existence of the output file
						local rest "`using'"
					 	* strip off "using"
						gettoken part rest: rest, parse(" ")
						if `fileExist'==1 {
							* it exists: keep on appending even if it's the first equation
							appendFile `using', titlefile(`"`titlefile'"') `sideway' /*
								*/ `onecol' sortcol(`sortcol') sortvar(`sortvar') groupvar(`groupvar') `quote' `comma' slow(`slow')
							outsheet2 v* reportCol `using', nonames `quote' `comma' replace slow(`slow')
							*drop v*
						}
						else {
							* does not exist and specified append: need to be created for the first equation only
							*if `eq' == 1 & "`append'"=="append" {
							if `eq' == 1 & "`append'"=="append" & `sidewayWave'==1 {
								outsheet2 report reportCol `using', nonames `quote' `comma' `replace' slow(`slow')
								local fileExist 1
							}
						}
					}
					
					restore, preserve
				}  /* sideway multiple equation */
				
				local eq = `eq' + 1
				
				*restore, preserve /* to access var labels after first equation */
			}
		}	
	}		/* for quietly */
}		/* run each estimates consecutively */

quietly {
	*** pre-generate labels
	if "`label'"~="" | "`labelA'"~="" {
		local varname_list `varname_list1' `varname_list2'
		macroUnique `varname_list', names(varname_list)
		
		tempname labelsave
		tempfile label_file
		file open `labelsave' using `label_file', write replace
		foreach var in `varname_list' {
			if `"`var'"'~="_cons" & `"`var'"'~="Constant" {
				fvts_label `var'
				file write `labelsave' `"`var'"' _tab `"`fvts_label_list'"' _n
			}
		}
		
		* constant here
		file write `labelsave' `"_cons"' _tab `"Constant"' _n
		file write `labelsave' `"Constant"' _tab `"Constant"' _n
		
		file close `labelsave'
		insheet using `label_file', clear
	}
	
	
	*** clean the files to be prepared for output
	if "`pivot'"=="pivot" {
	
		*** pivot and xpose here
		_strxpose `using', `quote' `comma' title(`title') titlefile(`"`titlefile'"') `label' /*
			*/ labelOption(`labelOption')
		* c_locals titleWide headRow bottomRow
	}
	else {
		
		cleanFile `using', `quote' `comma' title(`title') titlefile(`"`titlefile'"') `label' /*
			*/ labelOption(`labelOption') slow(`slow') label_file(`label_file')
		* c_locals titleWide headRow bottomRow
	}
	
	*** preparing for outputs and seeout
	ren v1 coef
	cap ren v0 eq
	
	unab vlist : v*
	local count: word count `vlist'
	forval num=1/`count' {
		local vname: word `num' of `vlist'
		ren `vname' v`num'
	}
	
	* number of columns
	describe, short
	local numcol = `r(k)'
	
	tempvar blanks rowmiss
	gen int `blanks' = (trim(v1)=="")
	
	foreach var of varlist v* {
		replace `blanks' = `blanks' & (trim(`var')=="")
	}
	
	replace `blanks'=0 if coef==`"`VARIABLES'"' | coef[_n-1]==`"`VARIABLES'"'
	
	* fix blanks==1 for groupvar( )
	count if `blanks'==1
	local rN=`r(N)'+1
	forval num=1/`rN' {
		replace `blanks'=0 if `blanks'[_n+1]==0 & `blanks'==1
	}
	
	* headBorder & bottomBorder
	local headBorder=`headRow'+`titleWide'
	local bottomBorder=`bottomRow'+`titleWide' /* add eqAdded later */
	
	*** making alternative output files
	if "`long'"=="long" | "`excel'"=="excel" | "`xmlsave'"=="xmlsave" |"`word'"=="word" | `tex'==1 | "`dta'"=="dta" | "`dtaa'"~="" | "`text'"=="text" | "`pivot'"=="pivot" {
		
		if "`text'"=="text" | ("`long'"=="long" & "`onecol'"=="onecol") {
			local dot=index(`"`using'"',".")
			if `dot'~=0 {
				local before=substr(`"`using'"',1,`dot'-1)
				local after=substr(`"`using'"',`dot'+1,length(`"`using'"'))
				
				*local usingLong=`"`before'_long.`after'"'
				local usingLong=`"`before'_exact.`after'"'
			}
		}
		
		local eq_exist
		capture confirm variable eq
		*if _rc~=0 & "`long'"=="long" {
		*	noi di in yellow "equation not detected; {opt long} may not be needed"
		*}
		
		*** convert the data into long format (insert the equation names if they exist)
		if _rc==0 & "`long'"=="long" & "`onecol'"=="onecol" {		
			* a routine to insert equation names into coefficient column
			count if `blanks'==0 & eq~="" & eq~="EQUATION"
			
			gen float id5=_n
			local _firstN=_N
			set obs `=_N+`r(N)''
			local times 1
			forval num=2/`_firstN' {
				if eq[`num']~="" & eq[`num']~="EQUATION" {
					replace id5=`num'-.5 in `=`_firstN'+`times''
					local times=`times'+1
				}
			}
			* eqAdded here:
			local bottomBorder=`bottomBorder'+`r(N)'
			count if `blanks'==0 & eq~="" & eq~="EQUATION"
			local _firstN=_N
			set obs `=_N+`r(N)''
			local times 1
			forval num=2/`_firstN' {
				if eq[`num']~="" & eq[`num']~="EQUATION" {
					replace id5=`num'-.75 in `=`_firstN'+`times''
					replace coef=eq[`num'] in `=`_firstN'+`times'' 
					local times=`times'+1
				}
			}
			
			sort id5
			
			drop eq id5 `blanks'
			
			* change `bottomBorder' by the number of equations inserted
			local bottomBorder=`bottomBorder'+`r(N)'
			
			* v names
			unab vlist : *
			local count: word count `vlist'
			forval num=1/`count' {
				local vname: word `num' of `vlist'
				ren `vname' c`num'
			}
			forval num=1/`count' {
				local vname: word `num' of `vlist'
				ren c`num' v`num'
			}
			
			if "`text'"=="text" {
				outsheet2 v* `usingLong', nonames `quote' `comma' replace slow(`slow')
			}
			
		} /* long format */
		
		else {
			drop `blanks'
			
			* v names
			unab vlist : *
			local count: word count `vlist'
			forval num=1/`count' {
				local vname: word `num' of `vlist'
				ren `vname' c`num'
			}
			forval num=1/`count' {
				local vname: word `num' of `vlist'
				ren c`num' v`num'
			}
		}
		
		*** label replacement
		if "`label'"=="label" {
			if ("`long'"~="long" & "`onecol'"~="onecol") | ("`long'"=="long" & "`onecol'"=="onecol") {
				replace v2=v1 if v2==""
				drop v1
				describe, short
				forval num=1/`r(k)' {
					ren v`=`num'+1' v`num'
				}
				
				* change LABELS to VARIABLES in 1/3
				replace v1=`"`VARIABLES'"' if v1=="LABELS"
			}
			else if "`long'"~="long" & "`onecol'"=="onecol" {
				replace v3=v2 if v3==""
				drop v2
				describe, short
				forval num=2/`r(k)' {
					ren v`=`num'+1' v`num'
				}
				
				* change LABELS to VARIABLES
				replace v2=`"`VARIABLES'"' if v2=="LABELS"
			}
			
			* create new text file
			* do it for _long file as well
			if "`text'"=="text" {
				
			}
		}
		
		*** Pivot thing
		*if "`pivot'"=="pivot" {
		*	* produce verbatim text
		*	
		*}
		
		
		tempfile outing outing1
		save `"`outing1'"'
		save `"`outing'"'
		
		local e_headBorder `headBorder'
		local e_bottomBorder `bottomBorder'
		
		*** Transpose thing
		if "`xposea'"~="" {
			_xposea_parse, `xposea'
			if "`whole'"=="whole" {
				_strxpose, clear force
				local num 1
				foreach var of varlist _all {
					ren `var' v`num'
					local num=`num'+1
				}
				
				local N=_N
				if `N'<=2 {
					* insert if too small
					*gen temp=_n
					set obs `=`N'+1'
					*replace temp= 0 in `N'
					*sort temp
					*drop temp
					
					local N=_N
					local e_headBorder 1
					local e_bottomBorder 2
				}
				else {
					local N=_N
					local e_headBorder 1
					local e_bottomBorder `N'
				}
			}
			save `"`outing1'"', replace
		}
		
		use `"`outing'"', clear
		
		*** Text thing
		if "`text'"=="text" & "`label'"=="label" {
			* produce verbatim text
			outsheet2 v* `usingLong', nonames `quote' `comma' replace slow(`slow')
		}
		
		*** LaTeX thing
		if `tex' {
			
			* make certain `1' is not `using' (another context)
			
			_texout v* using `"`strippedname'"', texFile(`texFile') titleWide(`titleWide') headBorder(`headBorder') bottomBorder(`bottomBorder') `texopts' replace
			
			if `"`texFile'"'=="" {
				local endName "tex"
			}
			else {
				local endName "`texFile'"
			}
			
			local usingTerm `"`strippedname'.`endName'"'
			
			c_local cl_tex `"{stata `"shellout using `"`usingTerm'"'"':`usingTerm'}"'
			*noi di as txt `"`cl_tex'"'
		}
		
		*** Word rtf file thing
		if "`word'"=="word" {
			use `"`outing'"',clear
			
			* there must be varlist to avoid error
			*out2rtf2 v* `using',  titleWide(`titleWide') headBorder(`headBorder') bottomBorder(`bottomBorder') replace nopretty
			out2rtf2 v* using `"`strippedname'"', wordFile(`wordFile') titleWide(`titleWide') /*
				*/ headBorder(`headBorder') bottomBorder(`bottomBorder') replace nopretty
			local temp `r(documentname)'
			
			* strip off "using" and quotes
			gettoken part rest: temp, parse(" ")
			gettoken usingTerm second: rest, parse(" ")
			
			*local cl `"{stata shell winexec cmd /c tommy.rtf & exit `usingTerm' & EXIT :`usingTerm' }"'
			* these work but leaves the window open
			*local cl `"{stata winexec cmd /c "`usingTerm'" & EXIT :`usingTerm'}"'
			*local cl `"{stata shell "`usingTerm'" & EXIT :`usingTerm'}"'
			*local cl `"{stata shell cmd /c "`usingTerm'" & EXIT :`usingTerm'}"'
			
			c_local cl_word `"{stata `"shellout using `"`usingTerm'"'"':`usingTerm'}"'
			*noi di as txt `"`cl_word'"'
		}
		
		*** Excel xml file thing
		if "`excel'"=="excel" {
			use `"`outing1'"',clear
			
			*xmlsave `"`strippedname'.xml"',doctype(excel) replace legible
			_xmlout using `"`strippedname'"', excelFile(`excelFile') nonames titleWide(`titleWide') /*
				*/ headBorder(`e_headBorder') bottomBorder(`e_bottomBorder') outreg2 `insert' excel1(`excel1')
			
			if `"`excelFile'"'=="" {
				local endName "xml"
			}
			else {
				local endName "`excelFile'"
			}
			
			local usingTerm `"`strippedname'.`endName'"'
			
			*c_local cl_excel `"{stata `"shellout using `"`usingTerm'"'"':`usingTerm'}"'
			c_local cl_excel `"{browse `"`usingTerm'"'}"'
			*noi di as txt `"`cl_excel'"'
		}
		
		*** xmlsave xml file thing
		if "`xmlsave'"=="xmlsave" {
			use `"`outing1'"',clear
			
			xmlsave `"`strippedname'_xmlsave.xml"',doctype(excel) replace legible
			*_xmlout using `"`strippedname'"', excelFile(`excelFile') nonames titleWide(`titleWide') /*
			*	*/ headBorder(`e_headBorder') bottomBorder(`e_bottomBorder') outreg2 `insert'
			
			if `"`excelFile'"'=="" {
				local endName "xml"
			}
			else {
				local endName "`excelFile'"
			}
			
			local usingTerm `"`strippedname'.`endName'"'
			
			*c_local cl_excel `"{stata `"shellout using `"`usingTerm'"'"':`usingTerm'}"'
			c_local cl_xmlsave `"{browse `"`usingTerm'"'}"'
			*noi di as txt `"`cl_excel'"'
		}
		
		*** Stata dta file thing
		if "`dta'"=="dta" | "`dtaa'"~="" {
			use `"`outing1'"',clear
			if "`dtaa'"~="" {
				if "`dtaa'"=="saveold" {
					saveold "`strippedname'_dta", replace
				}
				else {
					noi di in red "`dtaa' is not a vaild sub-option for {opt dta( )}" 
					exit 198
				}
			}
			else {
				save "`strippedname'_dta", replace
			}
			*c_local cl_dta `"{stata "`strippedname'_dta.dta":dta}"'
			*c_local cl_dta `"{stata `"seeout using "`strippedname'_dta", dta"':dta}"'
		}
	} /* output files */
}  /* quietly */

* re-clean to get each options returned
optionSyntax, valid(insert upper lower proper) name(labelA) nameShow(label( )) content(`labelOption')

*** see the output
if "`label'"=="label" | "`insert'"=="insert" {
	if "`seeout'"=="seeout" {
		if "`label'"=="label" {
			seeing `using', label
		}
		else {
			seeing `using', label(`insert')
		}
	}
	if "`label'"=="label" {
		c_local cl_see `"{stata `"seeout using `file', label"':seeout}"'
	}
	else {
		c_local cl_see `"{stata `"seeout using `file', label(`insert')"':seeout}"'
	}
	*di as txt `"`cl'"'
}
else {
	if "`seeout'"=="seeout" {
		seeing `using'
	}
	c_local cl_see `"{stata `"seeout using `file'"':seeout}"'
	*di as txt `"`cl'"'
}


*** pass up the requested
if `"`c_request'"'~="" {
	c_local c_request `"`c_request'"'
}

end		/* end of _outreg2 */


********************************************************************************************


prog define appendFile
* previously appfile2

	versionSet
	version `version'

* append regression results to pre-existing file

syntax using/, titlefile(str) [sideway onecol sortcol(str) sortvar(str) groupvar(str) /*
	*/  noQUOte comma slow(numlist)]

*** take out VARIABLES as the column heading and restore later
*local VARIABLES2 "`variables'"

* first name is the VARIABLES
local content
local num 1
local N=_N
while `"`content'"'=="" & `num'<=`N' {
	local content=report[`num']
	local num=`num'+1
}
local VARIABLES2 `"`content'"'
replace report = "" if report==`"`VARIABLES2'"' & rowtype2==-1


* column number rows
* pre-create Vorder here
gen Vorder2=0 if rowtype2==0
while Vorder2[1]==. {
	replace Vorder2=Vorder2[_n+1]-1 if rowtype2==-1
}
egen min=min(Vorder2)
replace Vorder2=-99 if Vorder2==min
drop min

* Constant is now done as eqOrder0 + .5
*replace Vorder2=2 if report=="Constant" /* ok because equation names would still be attached if present */

* orders bottom row, Observations, r2, and else
replace Vorder2=3.8 if rowtype2>=2 
replace Vorder2=Vorder2[_n-1]+.0001 if Vorder2>=3.8 & rowtype2==3
replace Vorder2=2 if rowtype2==2
replace Vorder2=3.5 if report=="Observations"
replace Vorder2=3.6 if report=="R-squared"

replace Vorder2=1 if Vorder2==. & (Vorder2[_n-1]<1 | Vorder2[_n-1]==1)
replace Vorder2=2.5 if report=="" & (Vorder2[_n-1]==2 | Vorder2[_n-1]==2.5)


* genderate eq_order2 (handles Constant within each equation)
local N=_N
gen eq_order2=0 in 3/`N' if eqname~=""
replace eq_order2=1 in 3/`N' if eqname[_n]~=eqname[_n-1] & eqname~=""
replace eq_order2=eq_order2+eq_order2[_n-1] if eq_order2+eq_order2[_n-1]~=.


* sortvar within appendFile 1 of 2
* generating order within each coefficient, use sortvar( ) if available
gen Vorder2_0=.
local maxnum 1
if "`sortvar'"~="" {
	tokenize `policy0' `sortvar'
	local num 1
	while "``num''"~="" {
		replace Vorder2_0=`num' if varname=="``num''"
		local num=`num'+1
	}
	if `num'>`maxnum' {
		local maxnum `num'
	}
}

* the evil twin of sortvar that will insert blanks/groups as well as order the existing variables 
if "`groupvar'"~="" {
	* stats rows per variable
	count if report~="" & rowtype2==1
	local nom `r(N)'
	count if rowtype2==1
	if `nom'~=0 {
		local rN=`r(N)'
		*local many=int(round(`rN'/`nom'))
		local many=int(round(`rN'/`nom',1))
	}
	else {
		local many 2
	}
	
	* eqnames for multiple equation
	tab eqname if rowtype2==1
	local rr=`r(r)'
	local tempList
	local orderlist
	if `rr'> 0 {
		* get eq names
		
		gen str5 temp=""
		replace temp=eqname if eqname~=eqname[_n-1] & rowtype2==1
		sort temp
		local N=_N
		forval num=1/`rr' {
			local content=temp[`N'-`num'+1]
			local tempList="`tempList' `content'"
			local content=eq_order2[`N'-`num'+1]
			local orderlist="`orderlist' `content'"
		}
		drop temp
		sort mrgrow
		local times `rr'
	}
	else {
		* it's a single equation, run it once
		local times 1
	}
		
	tokenize `policy0' `groupvar'
	forval kk=1/`times' {
		local order: word `kk' of `orderlist'
		local temp: word `kk' of `tempList'
		
		local num 1
		local count0 0
		while "``num''"~="" & "``num''"~=" " {
			replace Vorder2_0=`num' if varname=="``num''" & eqname=="`temp'"
			count if Vorder2_0~=. & eqname=="`temp'"
			if `r(N)'==`count0' {
				forval cc=1/`many' {
					* insert this many blank var
					local N=_N
					set obs `=`N'+1'
					local N=_N
					if `cc'==1 {
						replace report="``num''" in `N'
					}
					replace varname="``num''" in `N'
					replace rowtype2=1 in `N'
					replace Vorder2=1 in `N'
					replace Vorder2_0=`num' in `N'
					
					* for multiple equation only
					if `rr'>0 {
						if `cc'==1 {
							replace report="`temp':" + report in `N'
						}
						replace eq_order2=`order' in `N'
						replace eqname="`temp'" in `N'
					}
				}
			}
			count if Vorder2_0~=. & eqname=="`temp'"
			local count0 `r(N)'
			local num=`num'+1
		}
		if `num'>`maxnum' {
			local maxnum `num'
		}
	}
}


* own column to handle sortvar (to handle in mutliple equation)
gen sortvarCol2=Vorder2_0

gen temp=_n
replace Vorder2_0 = temp+`maxnum' if Vorder2==1 & report~="" & Vorder2_0==.
replace Vorder2_0 = Vorder2_0[_n-1]     if Vorder2_0==. & Vorder2==1
drop temp

replace sortvarCol2=Vorder2_0 if sortvarCol2~=.

gen double Vorder2_1 = Vorder2_0 if Vorder2==1 & report~=""
replace Vorder2_1 = Vorder2_1[_n-1]+.01 if Vorder2_1==. & Vorder2==1

* for groupvar( ) above
sort Vorder2 eq_order2 Vorder2_1 mrgrow
replace mrgrow=_n

gen str8 mergeOn = ""
replace mergeOn = report				/* room for "!" at end */

gen str8 varsml=""
replace varsml = trim(mergeOn)

* fill the spaces between the names
local N=_N

replace mergeOn = mergeOn[_n-1]+"!" if varsml==""
replace mergeOn = "bottomRow" if rowtype2==2
replace mergeOn = "topRow" if rowtype2==0
replace mergeOn = "_000" if rowtype2==-1
gen varnum = Vorder2 if Vorder2<1

* add "!" to variable name to make it sort after previous variable name
* will cause bug if both "varname" and "varname!" already exist

count if (varsml=="" | (varsml[_n+1]=="" & _n!=_N))
local ncoeff2 = r(N)				/* number of estimated coefficients in file 2 */
local N2 = _N					/* number of lines in file 2 */
gen Vord2 = _n					/* ordering variable for file 2 */

ren varname VarName2
ren eqname eqName2

drop varsml

* eqname vs eqName2
keep report reportCol mergeOn varnum Vord2 Vorder2 Vorder2_0 Vorder2_1 VarName2 eqName2 eq_order2 rowtype2 sortvarCol2

tempfile mergeVarFile mergeEqFile
gen str8 mergeVar=""
gen str8 mergeEq=""

*** get all constant rows 1 of 2
gen constant2=0
replace constant2=1 if (report=="Constant" | report=="_cons" | VarName2=="Constant" | VarName2=="_cons")
replace constant2=1 if mergeOn==mergeOn[_n-1]+"!" & constant2[_n-1]==1

* two sorting/merging mechanism
local N=_N
count if eqName2=="" | eqName2=="EQUATION"
if `N'==`r(N)' {
	* single equation
	local usingSingle 1
	replace mergeVar=mergeOn
	
	sort mergeVar varnum
	save `"`mergeVarFile'"', replace
}
else {
	* multiple equations
	local usingSingle 0
	replace mergeEq=mergeOn
	
	replace mergeVar = mergeOn
	replace mergeVar = VarName2 if VarName2~="" & Vorder2==1
	replace mergeVar = "Constant" if VarName2=="_cons" &  Vorder2==1
	replace mergeVar = mergeVar[_n-1]+"!" if mergeVar==mergeVar[_n-1] & mergeVar~="" & Vorder2==1
	
	sort mergeVar varnum
	save `"`mergeVarFile'"', replace
	
	sort mergeEq varnum
	save `"`mergeEqFile'"', replace
}


*** prepare the original file for merging

if "`Version7'"=="" {
	* it is version 7
	insheet2 using `"`using'"', nonames clear slow(`slow')
}
else {
	* requires 8 or above
	_chewfile using `"`using'"', semiclear
	local num 1
	foreach var of varlist _all {
		ren `var' v`num'
		local num=`num'+1
	}
}

if "`sideway'"=="sideway" {
	* if sideway, need to split eqname and varname, no label or title here
	cleanFile using `"`using'"', `quote' `comma' notitle slow(`slow')
	
	* get ride of v0 in case of equation
	insheet2 using `"`using'"', nonames clear slow(`slow')
}

*** save equation column if it exists before dropping it
local exists_eq=0
count if v1=="EQUATION"
if `r(N)'~=0 {
	gen str8 v0=""
	replace v0=v1
	local exists_eq=1
	drop v1
	* count v0 as well
	describe, short
	forval num=2/`r(k)' {
		ren v`num' v`=`num'-1'
	}
}

*** strip labels columns
count if v2=="LABELS"
if `r(N)'~=0 {
	drop v2
	* count v0 as well
	* cap is added to avoid the last column v0 being misnamed
	describe, short
	forval num=2/`r(k)' {
		cap ren v`=`num'+1' v`num'
	}
}

*** save title first one only, before stripping coef columns
cap save `"`titlefile'"'

*** must drop title first
if `exists_eq'==1 {
	if v0[1]~="" {
		* there may be a title
		while v0[1]~="" & v2=="" {
			drop in 1
		}
	}
}
if v1[1]~="" {
	* there may be a title
	while v1[1]~="" & v2=="" {
		drop in 1
	}
}	


*local VARIABLES "`variables'"
* first name is the VARIABLES
local content
local num 1
local N=_N
while `"`content'"'=="" & `num'<=`N' {
	local content=v1[`num']
	local num=`num'+1
}
local VARIABLES1 `"`content'"'


*** drop titles and establish the top row
*egen `rowmiss'=rowmiss(_all)
* rowmiss option not available in 8.2 or 8.0, do it by hand
gen rowmiss=0
foreach var of varlist v* {
	replace rowmiss=rowmiss+1 if `var'~=""
}

* rowmiss will not catch if ctitles are blank for the first column (1), count down from the top (already done for VARIABLES1)
*replace rowmiss=1 if v1[_n-1]~="VARIABLES"
replace rowmiss=1 if v1[_n-1]~=`"`VARIABLES1'"'

* NOTE: "VARIABLES" is no longer taken off; it merely gets written over in the same spot later on
while v1[1]~="" & rowmiss==1 {
	drop in 1
}

*** finish cleaning the equation columns

gen str8 VarName1=""
gen str8 eqName1=""

gen rowtype1=-1
replace rowtype1=0 if rowmiss==0
replace rowtype1=999 if rowmiss[_n-1]==0 | rowtype1[_n-1]==999
replace rowtype1=. if rowtype1==999
drop rowmiss

*** establish the bottom row
local N=_N
local num = `N'
local temp=v1[`num']
while `"`temp'"'~="" & `num'>=1 {
	* keep counting until empty
	local num=`num'-1
	local temp=v1[`num']
}
else {
	* already empty
	local num=`num'-1
}

local num=`num' + 1
replace rowtype1= 1 if rowtype1==.
replace rowtype1= 2 if _n==`num'
replace rowtype1= 3 if _n>`num'

if "`exists_eq'"=="1" {
	*** Strip the equation names and slap it back onto the variable column
	local N=_N
	order v0
	
	replace v0=v0[_n-1] if v0=="" & v0[_n-1]~="" & rowtype1==1
	gen eq_order1=0 if rowtype1==1
	replace eq_order1=1 if v0[_n]~=v0[_n-1] & v0~="" & rowtype1==1
	replace eq_order1=1 if v0[_n]~=v0[_n-1] & v0~="" & rowtype1==1
	
	replace eq_order1=eq_order1+eq_order1[_n-1] if eq_order1+eq_order1[_n-1]~=.
	
	replace eqName1=v0
	replace VarName1=v1
	replace VarName1=VarName1[_n-1] if VarName1=="" & VarName1[_n-1]~="" & rowtype1==1
	replace v1=v0 + ":" + v1 if v0~="" & v1~="" & rowtype1==1
	
	drop v0
}

* not needed, replaced with colonSplit
/*else if "`sideway'"=="sideway" & "`onecol'"=="onecol" {
	* special case for sideway and onecol
	* because sideway loops internally, EQUATION and LABELS columns does not exist
	* eqname and varname are still joined, they need to separated
	* v1 is as it should be
	
	*** borrowed from:
	*** clean up equation names, title, label
	gen id1=_n
	gen str8 equation=""
	gen str8 variable=""
	
	local N=_N
	forval num=1/`N' {
		local name=trim(v1[`num'])
		local column=index("`name'",":")
		if `column'~=0 {
			local equation=trim(substr("`name'",1,`column'-1))
			local variable=trim(substr("`name'",`column'+1,length("`name'")))
			replace equation="`equation'" in `num'
			replace variable="`variable'" in `num'
		}
	}
	replace equation=equation[_n-1] if equation=="" & equation[_n-1]~="" & rowtype1~=2
	
	replace eqName1=equation if equation~=""
	replace VarName1=variable if variable~=""
	drop equation variable id1
	
	local N=_N
	gen eq_order1=0 in 3/`N' if eqName1~=""
	replace eq_order1=1 in 3/`N' if eqName1[_n]~=eqName1[_n-1] & eqName1~=""
	replace eq_order1=eq_order1+eq_order1[_n-1] if eq_order1+eq_order1[_n-1]~=.
}
*/
else {
	*** eq names not present
	gen eq_order1=1
	replace eq_order1=. if rowtype1==2
}

*** take out COEFFICIENT/VARIABLES as the column heading and restore later
replace v1 = "" if rowtype1==-1

* getting the characteristics
describe, short
*local numcol = `r(k)'				/* number of columns already in file 1 */

* subtract 4 to account for eq_order1, VarName1, eqName1, rowtype1
local numcol = `r(k)'-4				/* number of columns already in file 1 */

gen str8 mergeOn = ""
replace mergeOn=v1
local titleWide = (v1[1]!="")

* `titleWide'	is assumed to be zero
local frstrow = 1 + `titleWide'			/* first non-title row */

gen long Vord1 = _n
gen str8 v2plus = ""
replace v2plus=trim(v2)

local col = 3
if `col'<=`numcol' {
	replace v2plus = v2plus + trim(v`col')
	local col = `col'+1
}

gen topoff=1 if v1~=""
replace topoff=1 if topoff[_n-1]==1
replace topoff=sum(topoff)
count if (topoff==0 | (v1=="" & v2plus!="") | (v1[_n+1]=="" & (v2plus[_n+1]!=""|_n==1) & _n!=_N))
drop topoff

local ncoeff1 = r(N)

gen str8 varsml=""
replace varsml = trim(mergeOn)

summ Vord1 if Vord1>`ncoeff1' & v2plus!=""	/* v2plus for addstat */
local endsta1 = r(max)					/* calc last row of statistics before notes */

if `endsta1'==. {
	local endsta1 = `ncoeff1'
}

replace mergeOn = mergeOn[_n-1]+"!" if varsml==""
replace mergeOn = "bottomRow" if rowtype1==2
replace mergeOn = "topRow" if rowtype1==0
replace mergeOn = "_000" if rowtype1==-1

* pre-create Vorder here
*gen Vorder1 = _n/100 if rowtype1==-1
*replace Vorder1 = .99 if rowtype1==0
gen Vorder1=0 if rowtype1==0

local mm 1
while Vorder1[1]==. & `mm'<100 {
	local mm=`mm'+1
	replace Vorder1=Vorder1[_n+1]-1 if rowtype1==-1
}

egen min=min(Vorder1)
replace Vorder1=-99 if Vorder1==min
drop min

gen varnum = Vorder1 if Vorder1<1

* Constant is now done as eqOrder0 + .5
*replace Vorder1=2 if v1=="Constant" /* ok because equation names would still be attached if present */

* orders bottom row, Observations, r2, and else
replace Vorder1=3.7 if rowtype1>=2 
replace Vorder1=Vorder1[_n-1]+.0001 if Vorder1>=3.7 & rowtype1==3
replace Vorder1=2 if rowtype1==2
replace Vorder1=3.5 if v1=="Observations"
replace Vorder1=3.6 if v1=="R-squared"

replace Vorder1=1 if Vorder1==. & (Vorder1[_n-1]<1 | Vorder1[_n-1]==1)
* a fix for addstat sorting Jan 2009
*replace Vorder1=4 if v2=="" & Vorder1==3.5
replace Vorder1=4 if v2=="" & v2plus=="" & Vorder1>3.5

* Constant is now done as eqOrder0 + .5
*replace Vorder1=2.5 if v1=="" & (Vorder1[_n-1]==2 | Vorder1[_n-1]==2.5)

* sortvar within appendFile 2 of 2
* generating order within each coefficient, use sortvar( ) if available
gen Vorder1_0=.
local maxnum 1
if "`sortvar'"~="" {
	tokenize `policy0' `sortvar'
	local num 1
	while "``num''"~="" {
		replace Vorder1_0=`num' if v1=="``num''" | VarName1=="``num''" & Vorder1==1
		local num=`num'+1
	}
	if `num'>`maxnum' {
		local maxnum `num'
	}
}

* the evil twin of sortvar that will insert blanks/groups as well as order the existing variables 
if "`groupvar'"~="" {
	* stats rows per variable
	count if v1~="" & rowtype1==1
	local nom `r(N)'
	count if rowtype1==1
	if `nom'~=0 {
		local many=int(round(`r(N)'/`nom'),1)
	}
	else {
		local many 2
	}
	
	* eqnames for multiple equation
	tab eqName1 if rowtype1==1
	local rr=`r(r)'
	local tempList
	local orderlist
	if `rr'> 0 {
		* get eq names
		
		gen str5 temp=""
		replace temp=eqname if eqname~=eqname[_n-1] & rowtype1==1
		sort temp
		local N=_N
		forval num=1/`rr' {
			local content=temp[`N'-`num'+1]
			local tempList="`tempList' `content'"
			local content=eq_order1[`N'-`num'+1]
			local orderlist="`orderlist' `content'"
		}
		drop temp
		sort Vord1
		local times `rr'
	}
	else {
		* it's a single equation, run it once
		local times 1
	}
	
	tokenize `policy0' `groupvar'
	forval kk=1/`times' {
		local order: word `kk' of `orderlist'
		local temp: word `kk' of `tempList'
		
		local num 1
		local count0 0
		while "``num''"~="" {
			replace Vorder1_0=`num' if (v1=="``num''" | VarName1=="``num''" ) & eqName1=="`temp'"
			count if Vorder1_0~=. & eqName1=="`temp'"
			if `r(N)'==`count0' {
				forval cc=1/`many' {
					* insert this many blank var
					local N=_N
					set obs `=`N'+1'
					local N=_N
					if `cc'==1 {
						replace v1="``num''" in `N'
					}
					replace VarName1="``num''" in `N'
					replace rowtype1=1 in `N'
					replace Vorder1=1 in `N'
					replace Vorder1_0=`num' in `N'
					
					* for multiple equation only
					if `rr'>0 {
						if `cc'==1 {
							replace v1="`temp':" + v1 in `N'
						}
						replace eq_order1=`order' in `N'
						replace eqname="`temp'" in `N'
					}
				}
			}
			count if Vorder1_0~=. & eqName1=="`temp'"
			local count0 `r(N)'
			local num=`num'+1
		}
		if `num'>`maxnum' {
			local maxnum `num'
		}
	}
}


*** for labels generation 2 of 2
local varname_list2
forval num=1/`=_N' {
	cap local this=v1[`num']
	cap local place=rowtype1[`num']
	if `place'==1 {
		local varname_list2 `"`varname_list2' `this'"'
	}
}
macroUnique `varname_list2', names(varname_list2)
if "`varname_list2'"~="" {
	c_local varname_list2 `varname_list2'
}


* must be filled:
replace mergeOn=v1 if Vord1==.
replace mergeOn=mergeOn[_n-1]+"!" if Vord1==. & mergeOn==""

* own column to handle sortvar (to handle in mutliple equation)
gen sortvarCol1=Vorder1_0

gen temp=_n
replace Vorder1_0 = temp+`maxnum' if Vorder1==1 & varsml~="" & Vorder1_0==.
replace Vorder1_0 = Vorder1_0[_n-1]     if Vorder1_0==. & Vorder1==1
drop temp

replace sortvarCol1=Vorder1_0 if Vorder1_0<`maxnum' 

gen double Vorder1_1 =Vorder1_0 if Vorder1==1 & v1~=""
replace Vorder1_1=Vorder1_1[_n-1]+.01 if Vorder1_1==. & Vorder1==1

* for groupvar( ) above
sort Vorder1 eq_order1 Vorder1_1 Vord1
replace Vord1=_n

drop varsml

*** get all constant rows 2 of 2
gen constant1=0
replace constant1=1 if (v1=="Constant" | v1=="_cons" | VarName1=="Constant" | VarName1=="_cons")
replace constant1=1 if mergeOn==mergeOn[_n-1]+"!" & constant1[_n-1]==1

*** merging the two files
* two sorting/merging mechanism
local N=_N
count if eqName1=="" & eqName1=="EQUATION"
local rN=`r(N)'
if `N'==`rN' & `usingSingle'==1 {
	* single equation in both files
	gen str8 mergeVar=""
	replace mergeVar = mergeOn
	sort mergeVar varnum
	
	merge mergeVar varnum using `"`mergeVarFile'"'
	drop mergeEq mergeVar
}
else if `N'~=`rN' & `usingSingle'==1 {
	* this one's multiple merged to earlier single
	
	gen str8 mergeVar=""
	replace mergeVar = mergeOn
	replace mergeVar = VarName1 if VarName1~="" & Vorder1==1
	replace mergeVar = "Constant" if VarName1=="_cons" &  Vorder1==1
	replace mergeVar = mergeVar[_n-1]+"!" if mergeVar==mergeVar[_n-1] & mergeVar~="" & Vorder1==1
	sort mergeVar varnum
	
	merge mergeVar varnum using `"`mergeVarFile'"'
	drop mergeEq mergeVar
}
else if `N'==`rN' & `usingSingle'==0 {
	* this one's multiple merged to earlier single
	gen str8 mergeVar=""
	replace mergeVar = mergeOn
	replace mergeVar = VarName1 if VarName1~="" & Vorder1==1
	replace mergeVar = "Constant" if VarName1=="_cons" &  Vorder1==1
	replace mergeVar = mergeVar[_n-1]+"!" if mergeVar==mergeVar[_n-1] & mergeVar~="" & Vorder1==1
	sort mergeVar varnum
	
	merge mergeVar varnum using `"`mergeVarFile'"'
	drop mergeEq mergeVar
}
else {
	* both files are multiple equations
	ren mergeOn mergeEq
	sort mergeEq varnum
	
	merge mergeEq varnum using `"`mergeEqFile'"'
	drop mergeEq mergeVar
}

*** clean up and sort the merged files
* Vorder2 has the information for the top 0.01-0.03
* but Vorder1 has the bottom notes
gen Vorder=Vorder2
replace Vorder=Vorder1 if Vorder==. | (Vorder1>3.5 & Vorder1<4)

gen byte merge2 = _merge==2

* Notes and defintions:
* Vorder2    _n for master file
* Vorder1    _n for using file

* Vorder2_0  identifier for each coefficient (using _n for the top most stats)
* Vorder2_1  added 0.01 consequtively to bysort Vorder2_0

* Vorder1_0  identifier for each coefficient (using _n for the top most stats)
* Vorder1_1  added 0.01 consequtively to bysort Vorder1_0

*** this fills up the potential gaps in Vord1 and Vord2 if the number of stats( ) per coefficient is different
*order eq_order* Vorder Vord1 Vord2 Vord* 

sort eq_order2 Vorder2_1
replace Vord1=Vord1[_n-1]+.01 if (Vorder2_0==Vorder2_0[_n-1] & Vorder2_0~=.) & (Vord1==. & Vord1[_n-1]~=.) & Vorder==1

sort eq_order1 Vorder1_1
replace Vord2=Vord2[_n-1]+.01 if (Vorder1_0==Vorder1_0[_n-1] & Vorder1_0~=.) & (Vord2==. & Vord2[_n-1]~=.) & Vorder==1

* it's off by 1; replace them all
replace Vorder2_1=Vord2 if Vorder==1
replace Vorder1_1=Vord1 if Vorder==1

*** new sorting rules
*** June 2008 Version
gen str8 eqName0=""
replace eqName0=eqName2
replace eqName0=eqName1 if eqName0=="" & eqName1~=""

sort eqName0 Vorder1_1
gen eq_order0=.
gen eq_temp=1 if eqName0[_n]~=eqName0[_n-1] & Vorder1_1~=.

************ sort to the existing column?
sort eq_temp Vorder1_1

gen constant=constant1
replace constant=constant2 if constant==.
replace constant=constant2 if constant2==1
drop constant1 constant2

local count 0

************* needs beter levelsof code
if "`exists_eq'"=="1" | ("`sideway'"=="sideway" & "`onecol'"=="onecol") {
	count if eq_temp==1
	if r(N)~=0 {
		forval num=1/`=r(N)' {
			local temp=eqName0[`num']
			
			* collecting names
			*local eqOrderList "`temp' `eqOrderList'"
			replace eq_order0=`num' if eqName0=="`temp'"
		}
		replace eq_order0=eq_order0+.5 if constant==1
	}
}
else {
	* pushes _cons toward the bottom
	replace eq_order0=1
	replace eq_order0=eq_order0+.5 if constant==1
}


count if Vorder2_0>=1 & Vorder2_0<.
local countV2=r(N)

count if Vorder1_0>=1 & Vorder1_0<.
local countV1=r(N)

*** sort( ) takes "name later"
* sort according to varname for _tab3
if "`sortcol'"=="name" {
	* do this by replacing these:
	sort mergeOn
	replace Vorder2_1=_n if Vorder==1
	replace Vorder1_1=_n if Vorder==1
}

* consolidate sortvarCol info
gen sortvarCol=sortvarCol1
replace sortvarCol=sortvarCol2 if sortvarCol==.


* temporary fix for Partha Deb: Aug 2008 version
if `countV2'>`countV1' | "`sortcol'"=="later" {
	sort Vorder eq_order0 sortvarCol Vorder2_1 Vorder1_1 merge2 Vord2 Vord1
}
else {
	sort Vorder eq_order0 sortvarCol Vorder1_1 Vorder2_1 merge2 Vord1 Vord2
}



*** fill in if it was a single equation combining with a multiple equation
count if eqName0~="EQUATION" & eqName0~=""
if `r(N)'>0 {
	replace report = "SINGLE:"+report if Vorder==1 & eqName0=="" & report~=""
	replace v1 = "SINGLE:"+v1 if Vorder==1 & eqName0=="" & v1~=""
}

replace v1 = report if v1=="" & report!=""
*drop report mergeOn varsml Vorder Vord1 Vord2 merge2 _merge v2plus
drop report mergeOn varnum        Vorder Vord1 Vord2 merge2 _merge v2plus Vorder1* Vorder2* eq* *Name*
cap drop sort*
cap drop group*

* add the head column numbers
if (`numcol'==2) {
	replace v2 = "(1)" if _n==`frstrow'
	replace reportCol = "(2)" if _n==`frstrow'
}
else {
	replace reportCol = "(" + string(`numcol') + ")" if _n==`frstrow'
}

*** restore COEFFICIENT and 0 head
replace v1=`"`VARIABLES2'"' if rowtype1[_n+1]==0
replace v1=`"`VARIABLES2'"' if rowtype1==0 & v1[_n-1]~=`"`VARIABLES2'"'

drop rowtype1 rowtype2 constant

c_local VARIABLES `"`VARIABLES2'"'

* also c_local varname_list2 above

end /* appendFile */


********************************************************************************************


prog define marginal2
	versionSet
	version `version'

* put marginal effects (dfdx) into b and vc matrices 

syntax , b(str) vc(str) [se margucp(str)]

tempname dfdx se_dfdx new_vc dfdx_b2		
capture mat `dfdx' = e(dfdx`margucp')
if _rc==0 {
	local cnam_b : colnames `dfdx'
	local cnam_1 : word 1 of `cnam_b'
}
if _rc!=0 {
	if "`cnam_1'"=="c1" {
		di in yellow `"Update dprobit ado file: type "help update" in Stata"'
	}
		else {
		di in yellow "{opt margin} option invalid: no marginal effects matrix e(dfdx`margucp') exists"
	}
	exit
}

/* create matrix of diagonals for vc */
if "`se'"=="se" {
	if e(cmd)=="dprobit" | e(cmd)=="tobit" {
		if e(cmd)=="dprobit" {
			local margucp "_dfdx"
		}
		mat `se_dfdx' = e(se`margucp')
		mat `vc' = diag(`se_dfdx')
		mat `vc' = `vc' * `vc'
	}
	else {
		mat `vc' = e(V_dfdx)
	}
	mat colnames `vc' = `cnam_b'
}
else {
	/* if t or p stats reported then trick `cv' into giving the right t stat */
	local coldfdx = colsof(`dfdx')
	mat `new_vc' = J(`coldfdx',`coldfdx',0)
	local i = 1
	while `i' <= `coldfdx' {
		scalar `dfdx_b2' = (el(`dfdx',1,`i')/el(`b',1,`i'))^2
		mat `new_vc'[`i',`i'] = `dfdx_b2'*`vc'[`i',`i']
		local i = `i'+1
	}
	mat colnames `new_vc' = `cnam_b'
	mat `vc' = `new_vc'
}  
mat `b' = `dfdx'
end


********************************************************************************************


prog define partxtl2, rclass
	versionSet
	version `version'


*** parse text list to find number of text elements and return them
	local ntxt = 0
	gettoken part rest: 1, parse(" (") 
	gettoken part rest: rest, parse(" (")		/* strip off "option(" */
	while `"`rest'"' != "" {
		local ntxt = `ntxt'+1
		gettoken part rest: rest, parse(",)") 
		return local txt`ntxt' `"`part'"'
		gettoken part rest: rest, parse(",)")	/* strip off "," or "(" */
	}
	return local numtxt `ntxt'
end


********************************************************************************************


*** this one avoids stripping the wrong parenthesis
prog define partxtl3, rclass
	versionSet
	version `version'


*** parse text list to find number of text elements and return them
	local ntxt = 0

	* CANNOT use these functions because of string length limitation
	*local begin = index(`"`1'"',`"("')
	*local length : length local 1
	*local rest=substr(`"`1'"',`begin'+1,`length'-`begin'-1)

	local rest `"`1'"'
	
	gettoken part rest: 1, parse(" (") 
	gettoken part rest: rest, parse(" (")		/* strip off "option(" */
	while `"`rest'"' != "" {
		local ntxt = `ntxt'+1
		gettoken part rest: rest, parse(",") 
		return local txt`ntxt' `"`part'"'
		local last_part `"`part'"'
		gettoken part rest: rest, parse(",")
	}
	
	* fix the last one by stripping the ending parenthesis
	gettoken part last_part: last_part, parse(")")
	
	* takes off too much
	if "`last_part'"=="))" {
		local part `"`part')"'
	}
	return local txt`ntxt' `"`part'"'
	
	return local numtxt `ntxt'
end


********************************************************************************************


prog define makeFile
* previously coeftxt2
	versionSet
	version `version'

if `a_version'>=11 {
	local fv fv
}

* getting the coefficient name, values, and t-statistics
syntax [varlist(default=none ts `fv')] [if] [in] [pw aw fw iw] , 	/*
*/ variables(str) [equationsOption(str)				/*
*/ keep(str) drop(str)  ADDvar(str) eqmatch(str)				/*
*/ inddrop(str) indyes(str) indno(str)					/*
*/ eqkeep(str) eqdrop(str)						/*
*/ eqlist(str) betaAsked							/*
*/ statsMany(integer 2) statsList(str asis) se_skip			/*
*/ BEta Level(integer $S_level) 						/*
*/ DEC(numlist) FMT(str) 							/*
*/ BDec(numlist) BFmt(str) 						/*
*/ SDec(numlist) SFmt(str) 						/*
*/ Tdec(numlist) TFmt(str)							/*
*/ PDec(numlist) PFmt(str) 						/*
*/ CDec(numlist) CFmt(str) 						/*
*/ ADec(numlist) 							/*
*/ RDec(numlist) RFmt(str)							/*
*/ noASter SYMbol(passthru) noCONs EForm noobs noNI 			/*
*/ noR2 ADJr2 ctitleList(str) ctbot(str)						/*
*/ POLICY0(str asis) skip 	*]

local varlistTemp `"`varlist'"'
local ifTemp `"`if'"'
local inTemp `"`in'"'
local weightTemp `"`weight'"'
local expTemp `"`exp'"'

* cascading options:
local 0 `", `options'"'
syntax [, ADDStat(passthru) ADDText(passthru) noNOTes			/*
*/ AUTO(integer 3) LESS(integer 0) NOAUTO	DECMark(str asis)		/*
*/ noPAren parenthesis(str asis) BRacket BRacketA(passthru) 	/*
*/ ADDNote(passthru) APpend regN(str) df_r(str) rsq(str) /*
*/ numi(str) ivar(str) depvar(str) robust(str) 		/*
*/ BOROWS(str) b(str) vc(str) 					/*
*/ univar(str) Onecol estname(str) 					/*
*/ estnameUnique(str) fileExist(integer 1) 				/*
*/ ALPHA(str) asterisk(passthru) 2aster				/*
*/ matList(str) leave(str) sidewayWave(integer 1) eqsingle	/*
*/ stnum(str asis) ststr(str asis) eretrun wide NOOMITTED NOBASE DEPVARshow(str) ]

* options taken out: SE Pvalue CI Tstat

local varlist `"`varlistTemp'"'
local if `"`ifTemp'"'
local in `"`inTemp'"'
local weight `"`weightTemp'"'
local exp `"`expTemp'"'

local VARIABLES "`variables'"

tempvar b_fvts_type b_coefficient b_st_err 
tempname b_alone vc_alon b_xtra vc_xtra

* avoid re-transposing them later by giving distinct names
tempname b_transpose vc_diag_transpose

if "`skip'"=="skip" {
	drop _all
	cap drop in 1/`=_N'
	set obs 4
	
	gen report=""
	gen eqname=""
	gen varname	=""
	gen mrgrow=_n
	gen reportCol=""
	gen rowtype2=.
	keep report eqname varname mrgrow reportCol rowtype2
	replace report="VARIABLES" in 2
	replace reportCol="(1)" in 1
	
	replace rowtype2=-1 in 1/2
	replace rowtype2=0 in 3
	*replace rowtype2=1 in 4/5
	replace rowtype2=2 in 4
	*replace rowtype2=3 in 5
	*replace report="Notes" in 6
	
	exit
}

if "`eretrun'"~="" {
	mat `b_transpose' = `b''
	mat `vc_diag_transpose' = vecdiag(`vc')
	mat `vc_diag_transpose' = `vc_diag_transpose''
	
	local brows = rowsof(`b_transpose')
	
	*** xt options
	if (`numi'!=. & "`ni'"!="noni") {
		if `"`iname'"'=="" {
			local iname "`ivar'"
		}
		if `"`iname'"'=="." {
			local iname "groups"
		}
	}
}


* populate with values from e(b) and e(V), or from varlist
tempvar report firstCol secondCol varKeepDrop betcoef

*** fill in variables names column
gen str5 `report' = ""
gen str5 `firstCol' = ""
gen str5 `secondCol' = ""

if "`eretrun'"~="" {
	local Names : rowfullnames(`b_transpose')
	local Rows = rowsof(`b_transpose')
}
else {
	_explicit `varlist'
	local Names `varlist'
	local Rows: word count `varlist'
}


* extender making sure the obs > columns & obs > `Rows'
local N=_N
if `Rows'>`N'+1 & `Rows'<. {
	set obs `=`Rows'+1'
}
if `N'<1 {
	cap set obs 1
	cap set obs 11
}

* extender
local N=_N
version 7: describe, short
if `r(k)'>`N'+1 & `r(k)'<. {
	set obs `r(k)'
}


forval num=1/`Rows' {
	local temp : word `num' of `Names'
	
	tokenize "`temp'", parse(":")
	
	if "`2'"==":" {
		replace `firstCol' = "`1'" in `num'
		replace `secondCol' = "`3'" in `num'
	}
	else {
		replace `secondCol' = "`temp'" in `num'
		replace `report' = "`temp'" in `num'
	}
}
replace `report' = "Constant" if `firstCol'=="" & `secondCol'=="_cons"
replace `report' = `firstCol' + ":" + `secondCol' if `firstCol'~=""
replace `report' = `firstCol' + ":Constant" if `firstCol'~="" & `secondCol'=="_cons"

gen double `b_coefficient' =.
gen double `b_st_err' =.

if "`eretrun'"~="" {
	replace `b_coefficient' = matrix(`b_transpose'[_n, 1]) in 1/`brows'
	replace `b_st_err' = matrix(`vc_diag_transpose'[_n, 1]) in 1/`brows'
	replace `b_st_err' = sqrt(`b_st_err')
}

gen `betcoef'=.
if "`beta'"=="beta" | "`betaAsked'"=="betaAsked" | "`leave'"~="" {
	* always e(sample) for beta coefficient
	sum `depvar' if e(sample) [`weight'`exp']
	local betaSD `r(sd)'
	
	forval num=1/`Rows' {
		local temp=`secondCol'[`num']
		cap sum `temp' if e(sample) [`weight'`exp']
		replace `betcoef' = r(sd)/`betaSD' * `b_coefficient' if `num'==_n & `secondCol'~="_cons"
	}
	replace `betcoef' = . if `secondCol'=="_cons"
	
	if "`beta'"=="beta" | "`betaAsked'"=="betaAsked" {
		* set nocons
		*local cons "nocons"
	}
}

*** marksample, version 11 decouples of e(b) from e(sample)
if "`varlist'"=="" & "`casewise'"=="casewise" {
	noi di in red "{it:varlist} needs to be specified for use with {opt case:wise}"
	exit 198
}

tempvar touse
mark `touse' `if' `in' [`weight'`exp']

/*
count if e(sample)
if `r(N)'==0 {
	if "`raw'"=="raw" {
		mark `touse' `if' `in' [`weight'`exp']
	}
	else {
		noi di in red "zero e(sample) count; run a regression or specify {opt raw} or {opt case:wise}"
		exit 198
	}
}
else {
	cap confirm matrix e(b)
	if _rc==0 {
		* always esample restricted
		if `"`if'"'~="" {
			mark `touse' `if' & e(sample) `in' [`weight'`exp']
		}
		else {
			mark `touse' if e(sample) `in' [`weight'`exp']
		}
	}
	else if "`raw'"=="raw" | "`casewise'"=="casewise" {
		mark `touse' `if' `in' [`weight'`exp']
	}
	else {
		noi di in red "e(b) missing; post e-return matrices, run a regression, or specify {opt raw} or {opt case:wise}"
		exit 198
	}
}
*/

* may not always be e(b), may be margins
if "`eretrun'"=="" & "`depvar'"=="" {
	gettoken depvar junk: varlist, `bind'
}

if `"`e(cmd)'"'=="margins" {
	if `"`ctitleList'"'=="" | `"`ctitleList'"'=="." {
		local temp "`e(predict_label)'"
		*local temp = substr("`temp'",4,length(`"`temp'"')-1)
		*local temp = substr("`temp'",1,length(`"`temp'"')-1)
		local ctitleList `"margins, `temp'"'
		if `"`e(derivatives)'"'~="" {
			local ctitleList `"`e(derivatives)', `temp'"'
		}
	}
}

*** addvar
tempvar makelag eq_order var_order

* do not add depvar unless requested
local addvarList "`addvar'"
if ((`"`statsList'"'~="coef se" & `"`statsList'"'~=" coef se" & "`depvar'"~="" & "`depvar'"~=".") & "`depvarshow'"~="nodepvarshow" & "`e(cmd)'"~="margins") | "`depvarshow'"=="depvarshow" {
	local addvarList "`depvar' `addvar'"
}

if "`addvarList'"~="" {
	local tempCC -10
	local tempKK -10
	
	gen `eq_order'=1 if `report'~="" & `firstCol'~=`firstCol'[_n-1]
	replace `eq_order'=0 if `report'~="" & `eq_order'==.
	replace `eq_order'=sum(`eq_order') if `report'~=""
	qui sum `eq_order', meanonly
	if `r(mean)'==0 {
		replace `eq_order'=`eq_order'+1 /* single equation */
	}
	
	gen `var_order'=1 if `report'~="" & `firstCol'~=`firstCol'[_n-1]
	replace `var_order'=`var_order'[_n-1]+1 if `var_order'==. & `report'~=""
	qui sum `var_order', meanonly
	if "`r(mean)'"=="" {
		replace `var_order'=_n if `report'~=""  /* single equation */
	}
	
	* reverse
	local addvarList1
	foreach temp in `addvarList' {
		local addvarList1 "`temp' `addvarList1'"
	
	}
	
	foreach this in `addvarList1' {
		* down by 1 to insert
		foreach var in `report' `firstCol' `secondCol' `b_coefficient' `b_st_err' `betcoef' `eq_order' `var_order' {
			gen `makelag'=`var'[_n-1]
			replace `var'=`makelag'
			cap drop `makelag'
		}
		replace `secondCol'="`this'" in 1
		replace `report'="`this'" in 1
		
		* unfinished for multiple eq
		count if `firstCol'~=""
		if `r(N)'~=0 {
			replace `report'=`report'+":"+`report' in 1
			replace `firstCol'="`this'" in 1
			* match to existing
			qui sum `eq_order' if `firstCol'=="`this'" , meanonly
			if "`r(mean)'"~="" {
				replace `eq_order'=`r(mean)' in 1 /* multi */
				replace `var_order'=`tempCC' in 1 /* multi */
				local tempCC=`tempCC'+0.01
			}
			* new vars
			levelsof `firstCol' if `eq_order'==.
			foreach temp in `r(levels)' {
				replace `eq_order'=`tempKK' if `firstCol'==`"`temp'"' /* multiple */
				local tempKK=`tempKK'+0.01
			}
		}
		else {
			replace `eq_order'=1 in 1 /* single */
			replace `var_order'=`tempCC' in 1 /* single */
			local tempCC=`tempCC'+0.01
		}
	}
	sort `eq_order' `var_order'
	cap drop `eq_order' `var_order'
}

*** combine addvar here
local varlist `varlist' `addvarList'
macroUnique `varlist' `addvarList', names(varlist)

*** pre-clean (again)
if "`varlist'"~="" {
	if `a_version'>=11 {
		cap fvunab temp : `anything'
		cap fvexpand `temp'
		cap local varlist `r(varlist)'
	}
	else {
		tsunab varlist : `varlist'
	}
	macroUnique `varlist', names(varlist)
}


*** extra stats

******************* all of these may not work well with -long- and multiple equations; problems with reg3 depvar names
count if `secondCol'~=""
local varMany=`r(N)'

if `varMany'>0 & `varMany'<. {
	
	local depvarTot 0
	cap local depvarTot: word count `depvar'
	if `depvarTot'==. | `depvarTot'==0 {
		local depvarTot 1
	}
	
	* needs to be lowered
	*local temp=lower(`"`statsList'"')
	local temp
	foreach var in `statsList' {
		local lowered=lower(`"`var'"')
		local temp `"`temp' `lowered'"'
	}
	
	_stats_check, `temp'
	
	*** summary from stats( ) here
	if "`sumAsked'"~="" {
		local tempL0
		
		if "`sumAsked'"=="regular" {
			* summary
			local sumList "N sum_w mean Var sd min max sum"
			local detail
		}
		
		if "`sumAsked'"=="detail" { 
			* detail
			local sumList "N sum_w mean Var sd skewness kurtosis sum min max p1 p5 p10 p25 p50 p75 p90 p95 p99"
			local detail detail
		}
		
		if "`sumAsked'"=="extra" {
			* detail & extra
			local extraList "cv range iqr semean median count"
			local sumList "N sum_w mean Var sd skewness kurtosis sum min max p1 p5 p10 p25 p50 p75 p90 p95 p99 `extraList'"
			local detail detail
		}
		
		tempvar `sumList'
		foreach stuff in `sumList' {
			gen ``stuff'' = .
		}
		
		forval num=1/`varMany' {
			local content=`secondCol'[`num']
			cap summarize `content' if `touse' [`weight'`exp'], `detail'
			if _rc==101 {
				noi di in red "pweight not allowed"
				exit 101
			}
			if _rc==0 & `r(N)'>0 & `r(N)'<. {
				foreach stuff in `sumList' {
					if "`stuff'"~="cv" & "`stuff'"~="range" & "`stuff'"~="iqr" & "`stuff'"~="semean" & "`stuff'"~="median" & "`stuff'"~="count" {
						cap replace ``stuff'' = `r(`stuff')' in `num'
						local tempL0 "`tempL0' ``stuff''"
					}
					else {
						* extra
						foreach tt in `extraList' {
							local `tt'0
						}
						cap local cv0 `=`r(sd)'/`r(mean)''
						cap local range0 `=`r(max)'-`r(min)''
						cap local iqr0 `=`r(p75)'-`r(p25)''
						cap local semean0 `=`r(sd)'/(`r(N)'^.5)'
						cap local median0 `r(p50)'
						cap local count0 `r(N)'
						cap replace ``stuff'' = ``stuff'0' in `num'
						local tempL0 "`tempL0' ``stuff''"
					}
				}
			}
		}
	}


local tempL1
	
*** stats( ) correlations
forval wave=1/`depvarTot' {
	local depvarUse: word `wave' of `depvar'
	foreach cmd in corr pwcorr spearman {
		if "``cmd'Asked'"=="`cmd'" {
			tempvar `cmd'
			gen ``cmd'' = .
			forval num=1/`varMany' {
				local content=`secondCol'[`num']
*********************** if no depvar, then use the varlist
				cap `cmd' `depvarUse' `content' if `touse' [`weight'`exp']
				if _rc==0 {
					cap replace ``cmd'' = `r(rho)' in `num'
				}
			}
			local tempL1 "`tempL1' ``cmd''"
		}
	}
}



*** independent commands at the bottom 1 (numerical)
forval wave=1/`depvarTot' {
	local depvarUse: word `wave' of `depvar'
	foreach cmd in covar pcorr semipcorr pcorrpval tau_a tau_b {
		if "``cmd'Asked'"=="`cmd'" {
			tempvar `cmd'
			gen ``cmd'' = .
			forval num=1/`varMany' {
				local content=`secondCol'[`num']
*********************** if no depvar, then use the varlist
				cap `cmd' `depvarUse' `content' if `touse' [`weight'`exp']
				if _rc==0 {
					cap replace ``cmd'' = `r(`cmd')' in `num'
				}
			}
			local tempL1 "`tempL1' ``cmd''"
		}
	}
}


*** independent commands at the bottom 2 (str)
forval wave=1/`depvarTot' {
	local depvarUse: word `wave' of `depvar'
	foreach cmd in label label_pr label_up label_low {
		if "``cmd'Asked'"=="`cmd'" {
			tempvar `cmd'
			gen str7 ``cmd'' = ""
			forval num=1/`varMany' {
				local content=`secondCol'[`num']
*********************** if no depvar, then use the varlist
				
				* workaround for label only
				if "`cmd'"=="label" {
					cap label0 `depvarUse' `content' if `touse' [`weight'`exp']
				}
				else {
					cap `cmd' `depvarUse' `content' if `touse' [`weight'`exp']
				}
				
				if _rc==0 {
					replace ``cmd'' = `"`r(`cmd')'"' in `num'
				}
				else {
					******** not proper/upper/lower applied
					if "`content'"=="_cons" {
						replace ``cmd'' = `"Constant"' in `num'
					}
				}
			}
			local tempL1 "`tempL1' ``cmd''"
		}
	}
}

	*** stats( ) cmd( )
	* take out cmd( ) from statsList and replace with cmd1 cmd2 ...
	* also run the cmd( ) and get r( ) back out
	
	* `regVal1' `regVal2' ... tempvar name for the column containing the values
	* cmd1 cmd2 ... name that appears in statsList and the column variable names
	* cmd1 cmd2 ... also contain what each cmd are
	
	local tempL2
	local cmdList 
	
	local tempList
	local num 0
	local cc 0
	
	local one
	local two `statsList'
	
	while `"`two'"'~="" & `"`two'"'~=" " {
		local num=`num'+1
		
		gettoken one two: two, `bind'
		
		* if okay to add:
		local check=substr(trim("`one'"),1,4)
		if `"`check'"'=="cmd(" {
			
			* it's a cmd( )
			local cc=`cc'+1
			local cmd`cc'=`"`one'"'
			
			tempvar regVal`cc'
			gen str7 `regVal`cc'' = ""
			
			* separate reporting from cmd requested inside: cmd( r( ) cmd)
			gettoken reporting cmd: one, `bind' parse("(")
			gettoken reporting cmd: cmd, `bind' parse("(")
			gettoken reporting cmd: cmd, `bind' parse(":")
			gettoken colon cmd: cmd, `bind' parse(":")
			
			local cmd=substr("`cmd'",1,length("`cmd'")-1)
			gettoken cmd suboption: cmd , parse(",")
			
			local reg`cc'=`"`cmd'"'
			
			forval num=1/`varMany' {
				local content=`secondCol'[`num']
				
	************************* disable varlist
	********************** if no depvar, then use the varlist
				
				cap `cmd' `depvar' `content' if `touse' [`weight'`exp'] `suboption'
				if _rc==0 {
					cap replace `regVal`cc'' = `"``reporting''"' in `num'
				}
			}
			local cmdList "`cmdList' cmd`cc'"
			local tempL2 "`tempL2' `regVal`cc''"
			local tempList "`tempList' cmd`cc'"
		}
		else {
			local tempList "`tempList' `one'"
		}
	}
	local statsList `"`tempList'"'
	
	
	
	*** stats( ) str( )
	* take out str( ) from statsList and replace with str1 str2 ...
	
	* `strVal1' `strVal2' ... tempvar name for the column containing the values
	*  string1 string2 ... name that appears in statsList and the column variable names
	*  string1 string2 ... also contain what each strings are
	
	local tempL3
	local strList 
	
	local tempList
	local num 0
	local cc 0
	
	local one
	local two `statsList'
	
	while `"`two'"'~="" & `"`two'"'~=" " {
		local num=`num'+1
		
		gettoken one two: two, `bind'
		
		* if okay to add:
		local check=substr(trim("`one'"),1,4)
		if `"`check'"'=="str(" {
			
			* it's a str( )
			local cc=`cc'+1
			local string`cc'=`"`one'"'
			
			tempvar strVal`cc'
			gen str7 `strVal`cc'' = ""
			
			* separate reporting from str requested inside: str( r( ) str)
			gettoken junk str: one, `bind' parse("(")
			gettoken junk str: str, `bind' parse("(")
			local str=substr("`str'",1,length("`str'")-1)
			
			forval num=1/`varMany' {
				local content=`secondCol'[`num']
				replace `strVal`cc'' = `"`str'"' in `num'
			}
			local strList "`strList' string`cc'"
			local tempL3 "`tempL3' `strVal`cc''"
			local tempList "`tempList' string`cc'"
		}
		else {
			local tempList "`tempList' `one'"
		}
	}
	local statsList `"`tempList'"'
	
	/*
	*** stats( ) e( )
	* take out e( ) from statsList and replace with e1 e2 ...
	
	* `strVal1' `strVal2' ... tempvar name for the column containing the values
	*  string1 string2 ... name that appears in statsList and the column variable names
	*  string1 string2 ... also contain what each strings are
	
	local tempL4
	local eList 
	
	local tempList
	local num 0
	local cc 0
	
	local one
	local two `statsList'
	
	while `"`two'"'~="" & `"`two'"'~=" " {
		local num=`num'+1
		
		gettoken one two: two, `bind'
		
		* if okay to add:
		local check=substr(trim("`one'"),1,4)
		if `"`check'"'=="e(" {
			
			* it's a e( )
			local cc=`cc'+1
			local string`cc'=`"`one'"'
			
			tempvar eVal`cc'
			gen str7 `eVal`cc'' = ""
			
			* separate reporting from e requested inside: e( r( ) e)
			gettoken junk str: one, `bind' parse("(")
			gettoken junk str: str, `bind' parse("(")
			local str=substr("`str'",1,length("`str'")-1)
			
			forval num=1/`varMany' {
				local content=`secondCol'[`num']
				replace `strVal`cc'' = `"`str'"' in `num'
			}
			local strList "`strList' string`cc'"
			local tempL3 "`tempL3' `strVal`cc''"
			local tempList "`tempList' string`cc'"
		}
		else {
			local tempList "`tempList' `one'"
		}
	}
	local statsList `"`tempList'"'
	*/

}


* inddrop last right before dropping the main data
* because easier than to pass the arguments to after dropping them

local inddropList `inddrop'

************************** needs to be unambiguated
if "`inddrop'"~="" {
	if "`indno'"=="" {
		local indno "No"
	}
	if "`indyes'"=="" {
		local indyes "Yes"
	}
		
		* any must be present
		noi di in red "`addstat'"
		* first phrase
		local two `inddropList'
		while `"`two'"'~="" & `"`two'"'~=" " {
			
			gettoken one two: two, `bind' parse(",")
			local one=trim(`"`one'"')
			local two=trim(`"`two'"')
			
			if `"`one'"'=="," {
				gettoken one two: two, `bind' parse(",")
				local one=trim(`"`one'"')
				local two=trim(`"`two'"')
			}
			
			unab one1: `one'
			local N0=_N
			foreach var in `one1' {
				drop if `secondCol'=="`var'" & `secondCol'~=""
			}
			local N=_N
			if `N0'>`N' {
				* indicate Yes
				if `"`addstat'"'!="" {
					* take off
					gettoken junk addstat: addstat, `bind' parse(" (")
					gettoken junk addstat: addstat, `bind' parse(" (")
					local addstat `"addstat(`"`one' included"', `indyes',`addstat'"'
				}
				else {
					local addstat `"addstat(`"`one' included"', `indyes')"'
				}
			}
			else {
				* indicate No
				if `"`addstat'"'!="" {
					* take off
					gettoken junk addstat: addstat, `bind' parse(" (")
					gettoken junk addstat: addstat, `bind' parse(" (")
					local addstat `"addstat(`"`one' included"', `indno',`addstat'"'
				}
				else {
					local addstat `"addstat(`"`one' included"', `indno')"'
				}
			}
		
	}
}

*** handle policy 2 of 3
if "`policy0'"~="" {
	fvunab policyList: `policy0'
}


*** handle fvts 1 of 2
gen str7 `b_fvts_type' =""
local this this
local cc 1
while `"`this'"'~="" {
	cap local this=`secondCol'[`cc']
	cap fvts_label `this'
	replace `b_fvts_type'="`basesuffix'" in `cc'
	*replace varlabel = `"`fvts_label_list'"'  in `cc'
	local ++cc
}

*** get rid of original data & rename
keep `report' `b_fvts_type' `b_coefficient' `b_st_err' `betcoef' `firstCol' `secondCol' `tempL0' `tempL1' `tempL2' `tempL3'

ren `b_fvts_type' fvts_type
ren `b_coefficient' coef
ren `b_st_err' se
ren `report' report
ren `betcoef' beta

ren `firstCol' eqname
ren `secondCol' varname
keep if varname~=""


*** make unique
gen n0=_n
bys eqname varname coef: gen n=_n
keep if n==1
sort n0
drop n n0


*** for labels generation 1 of 2
local varname_list1
forval num=1/`=_N' {
	cap local this=varname[`num']
	local varname_list1 `"`varname_list1' `this'"'
}
macroUnique `varname_list1', names(varname_list1)
if "`varname_list1'"~="" {
	c_local varname_list1 `varname_list1'
}


* special case
if "`wide'"~="wide" & ("`e(cmd)'"=="xtpoisson" | "`e(cmd)'"=="oprobit" | "`e(cmd)'"=="ologit") {
	replace report=varname
	replace report="Constant " + eqname if varname=="_cons"
	replace eqname=""
}
else if "`eqsingle'"=="eqsingle" {
	* treat as single equation (xtpoisson version 11 probit etc)
	replace report=varname
	replace report="Constant" if varname=="_cons"
	replace eqname=""
}


if `varMany'>0 & `varMany'<. {
	if "`sumAsked'"~="" {
		foreach var in `sumList' {
			ren ``var'' `var'
		}
	}
	foreach var in label label_pr label_up label_low {
		if "``var'Asked'"~="" {
			ren ``var'' `var'
		}
	}
	foreach var in covar corr pwcorr spearman pcorr semipcorr pcorrpval tau_a tau_b {
		if "``var'Asked'"~="" {
			ren ``var'' `var'
		}
	}
	local cc 1
	foreach var in `cmdList' {
		ren `regVal`cc'' cmd`cc'
		local cc=`cc'+1
	}
	local cc 1
	foreach var in `strList' {
		ren `strVal`cc'' string`cc'
		local cc=`cc'+1
	}
}


*** continue keep/drop here
if "`keep'"~="" {
	local varlist "`keep'"
}

* varlist
if "`varlist'"~="" {
	gen str5 `varKeepDrop'=""
	
	* add the constant unless "nocons" is chosen
	if "`cons'"~="nocons" {
		local varlist "`varlist' _cons"
	}
	
	local count: word count `varlist'
	forval num=1/`count' {
		local temp : word `num' of `varlist'
		replace `varKeepDrop'="`temp'" if "`temp'"==varname
	}
	
	count if `varKeepDrop'=="" & varname~=""
	local brows=`brows'-r(N)
	local borows=`borows'-r(N)
	drop if `varKeepDrop'=="" & varname~=""
	drop `varKeepDrop'
}

* drop
if "`drop'"~="" {
	gen str5 `varKeepDrop'=""
	
	local count: word count `drop'
	forval num=1/`count' {
		local temp : word `num' of `drop'
		replace `varKeepDrop'="`temp'" if "`temp'"==varname
	}
	
	count if `varKeepDrop'~=""
	local brows=`brows'-r(N)
	local borows=`borows'-r(N)
	
	drop if `varKeepDrop'~=""
	drop `varKeepDrop'
}

if "`cons'"=="nocons" {
	gen count=1 if varname=="_cons"
	count if count==1
	local brows=`brows'-r(N)
	local borows=`borows'-r(N)
	drop if count==1
	drop count
}


* drop some of multiple equations: 2 of 2
* (in case only one equation kept but `b' was passed thru inputed instead of `b_eq')

************* technically this should be fixed (get the eqname non-empty, and use indicator if multi-equation called for)
if "`eqdrop'"~="" & "`long'"=="long" {
	gen str5 `varKeepDrop'=""
	
	local count: word count `eqdrop'
	forval num=1/`count' {
		local temp : word `num' of `eqdrop'
		replace `varKeepDrop'="`temp'" if "`temp'"==eqname
	}
	
	count if `varKeepDrop'~=""
	local brows=`brows'-r(N)
	local borows=`borows'-r(N)
	
	drop if `varKeepDrop'~=""
	drop `varKeepDrop'
}

if "`noomitted'"=="noomitted" {
	drop if fvts_type=="o"
}
if "`nobase'"=="nobase" {
	drop if fvts_type=="b"
}

************* technically this should be fixed (get the eqname non-empty, and use indicator if multi-equation called for)
if "`eqkeep'"~="" & "`long'"=="long" {
	gen str5 `varKeepDrop'=""
	
	local count: word count `eqkeep'
	forval num=1/`count' {
		local temp : word `num' of `eqkeep'
		replace `varKeepDrop'="`temp'" if "`temp'"==eqname
	}
	
	count if `varKeepDrop'~=""
	local brows=`brows'-r(N)
	local borows=`borows'-r(N)
	
	keep if `varKeepDrop'~=""
	drop `varKeepDrop'
}

* reset brows after dropping
count if report~=""
local brows = `r(N)'


/*
matrix matrix1=level'

*** enhancing with outside matrix
*** fill in variables names column
tempname matrix1 first1 second1

*gen str5 `matrix1' = ""
*gen str5 `first1' = ""
*gen str5 `second1' = ""

*local Names : rowfullnames(`b_transpose')
*local Rows = rowsof(`b_transpose')

gen str5 matrix1 = ""
gen str5 first1 = ""
gen str5 second1 = ""
gen str5 varname1 = ""
local Names : rowfullnames(matrix1)
local Rows = rowsof(matrix1)

forval num=1/`Rows' {
	local temp : word `num' of `Names'
	
	tokenize "`temp'", parse(":")
	
	if "`2'"==":" {
		replace first1 = "`1'" in `num'
		replace second1 = "`3'" in `num'
	}
	else {
		replace second1 = "`temp'" in `num'
		replace varname1 = "`temp'" in `num'
	}
}
replace varname1 = "Constant" if first=="" & second=="_cons"
replace varname1 = first + ":" + second if first~=""
replace varname1 = first + ":Constant" if first~="" & second=="_cons"

gen double b = matrix(matrix1[_n, 1]) in 1/`brows'
gen double s = matrix(matrix1[_n, 1]) in 1/`brows'
replace s = sqrt(s)
*/

/*
*** rename variables for forced row matching
if `"`samevar'"'~="" {
	gettoken first second: samevar, parse(",")
}
*/


*** obtain the statistics of interest

* tstat
gen double tstat = (coef/se)

* T_alpha for the Ci
if `df_r'==. {
	gen double T_alpha = invnorm( 1-(1-`level' /100)/2 )
}
else {
	* replacement for invt( ) function under version 6
	* note the absolute sign: invttail is flipped from invnorm
	gen double T_alpha = abs(invttail(`df_r', (1-`level' /100)/2))
}

* ci
gen double ci_low=coef-T_alpha*se
gen double ci_high=coef+T_alpha*se
	
	* exponentiate beta and st_err
	gen double coefEform = exp(coef)
	gen double seEform = coefEform * se
	gen double ci_lowEform = exp(coef - seEform * T_alpha / coefEform)
	gen double ci_highEform = exp(coef + seEform * T_alpha / coefEform)

* pval
if `df_r'==. {
	gen double pval = 2*(1-normprob(abs(tstat)))
}
else {
	gen double pval = tprob(`df_r', abs(tstat))
}


* calculate asterisks for t-stats (or standard errors)
local titleWide=0
if "`append'"=="append" & `fileExist'==1 {
	local appottl = 1
}
else {
	local appottl = `titleWide'
}

* either an appended column (not the first regression) or has a title
* i.e. need an extra line above the coefficients
* added a second extra line above the coefficients: place 1 of 2
gen mrgrow = 2*_n + 1 + `appottl' + 1

*** dealing with the asterisks
if "`aster'"!="noaster" {
	
	if "`alpha'"~="" {
		* parse ALPHA
		partxtl2 `"`alpha'"'
		local alphaCount = r(numtxt)
		local num=1
		while `num'<=`alphaCount' {
			local alpha`num' `r(txt`num')'
			capture confirm number `alpha`num''
			if _rc!=0 {
				noi di in red `"`alpha`num'' found where number expected in {opt alpha()} option"'
				exit 7
			}
		local num = `num'+1
		}
	}
	else {
		if "`2aster'"=="2aster" {
			local alpha1=.01
			local alpha2=.05
			local alphaCount=2
		}
		else {
			local alpha1=.01
			local alpha2=.05
			local alpha3=.10
			local alphaCount=3
		}
	}
	
	if `"`symbol'"'!="" {
		* parse SYMBOL
		partxtl2 `"`symbol'"'
		local symbolCount = r(numtxt)
		local num=1
		while `num'<=`symbolCount' {
			local symbol`num' `r(txt`num')'
			capture confirm number `symbol`num''
			if _rc==0{
				noi di in red `"`symbol`num'' found where non-number expected in {opt sym:bol()}"'
				exit 7
			}
		local num = `num'+1
		}
	}
	else {
		*** assume 2aster when only two alpha was given
		if "`2aster'"=="2aster" | `alphaCount'==2 {
			* 1 and 5 %
			local symbol1 "**"
			local symbol2 "*"
			local symbolCount=2
		}
		else {
			* 1, 5, and 10%
			local symbol1 "***"
			local symbol2 "**"
			local symbol3 "*"
			local symbolCount=3
		}
		* when only SYMBOL was given
		if "`alpha'"=="" {
			
		}
	}
	
	if "`alpha'"~="" & `"`symbol'"'~="" {
		if `symbolCount'~=`alphaCount' {
			di in red "{opt alpha()} and {opt sym:bol()} must have the same number of elements"
			exit 198
		}
	}
	
	if "`alpha'"=="" & `"`symbol'"'~="" {
		if `symbolCount'>=4 {
			di in red "{opt alpha()} must be specified when more than 3 symbols are specified with {opt sym:bol()}"
			exit 198
		}
	}
	
	if "`alpha'"~="" & `"`symbol'"'=="" {
		local symbolCount=`alphaCount'
		if `alphaCount'>=4 {
			di in red "{opt sym:bol()} must be specified when more than 3 levels are specified with {opt alpha()}"
			exit 198
		}
	}
	
	* fix the leading zero
	local num=1
	while `num'<=`alphaCount' {
		if index(trim("`alpha`num''"),".")==1 {
			local alpha`num'="0`alpha`num''"
		}
		local num=`num'+1
	}
	
	* creating the notes for the alpha significance
	local astrtxt `"`symbol1' p<`alpha1'"'
	local num=2
	while `num'<=`symbolCount' {
		local astrtxt `"`astrtxt', `symbol`num'' p<`alpha`num''"'
		local num=`num'+1
	}
	
	* assign the SYMBOL
	gen str12 astrix = `"`symbol1'"' if (abs(pval)<`alpha1' & abs(pval)!=.)
	
	local num=2
	while `num'<=`symbolCount' {
		replace astrix = `"`symbol`num''"' if astrix=="" & (abs(pval)<`alpha`num'' & abs(pval)!=.)
		local num=`num'+1
	}
}
else {
	gen str2 astrix = ""
}



* add in matrix/vectors names if provided in stats( )
* the values are to be autodigit later
* splits matList into vectorList and nonvecList

local vectorList
local nonvecList


if "`matList'"~="" {
	tempname matdown
	foreach matname in `matList' {
		mat `matdown'=`matname'		/* NOT transposed */
		local temp= colsof(`matdown')
		
		* pre-save
		count if eqname~=""
		local masterEqExist=`r(N)'
		
		tempfile masterMultiFile masterSingleFile
		
		* original file is single equations
		sort varname
		save `"`masterSingleFile'"', replace
		
		* original file is multiple equations
		sort eqname varname
		save `"`masterMultiFile'"', replace
		
		* empties
		drop *
		
		cap gen str5 report = ""
		cap gen str5 eqname = ""
		cap gen str5 varname= ""
		
		if `temp'==1 {
			* it's a vector
			local vectorList "`vectorList' `matname'"
			
			*** borrowed from: *** fill in variables names column
			
			local Names : rowfullnames(`matdown')
			local Rows = rowsof(`matdown')
			set obs `Rows'
			
			forval num=1/`Rows' {
				local temp : word `num' of `Names'
				
				tokenize "`temp'", parse(":")
				
				if "`2'"==":" {
					replace eqname = "`1'" in `num'
					replace varname= "`3'" in `num'
				}
				else {
					replace varname= "`temp'" in `num'
					replace report = "`temp'" in `num'
				}
			}
			replace varname= "_cons" if varname=="Constant"
			
			replace report = "Constant" if eqname=="" & varname=="_cons"
			replace report = eqname + ":" + varname if eqname~=""
			replace report = eqname + ":Constant" if eqname~="" & varname=="_cons"
			
			svmat double `matdown', name(`matname')
			
			* take off 1's that's been slapped on
			cap ren `matname'1 `matname'
		}
		else {
			* it's a non-vector matrix
			local cc= colsof(`matdown')
			local temp0 : colnames(`matdown')
			local temp
			foreach var in `temp0' {
				local temp "`temp' `matname'_`var'"
			}
			local nonvecList "`nonvecList' `temp'"
			
			*** borrowed from: *** fill in variables names column
			
			local Names : rowfullnames(`matdown')
			local Rows = rowsof(`matdown')
			set obs `Rows'
			
			forval num=1/`Rows' {
				local temp : word `num' of `Names'
				
				tokenize "`temp'", parse(":")
				
				if "`2'"==":" {
					replace eqname = "`1'" in `num'
					replace varname= "`3'" in `num'
				}
				else {
					replace varname= "`temp'" in `num'
					replace report = "`temp'" in `num'
				}
			}
			replace varname= "_cons" if varname=="Constant"
			
			replace report = "Constant" if eqname=="" & varname=="_cons"
			replace report = eqname + ":" + varname if eqname~=""
			replace report = eqname + ":Constant" if eqname~="" & varname=="_cons"
			
			svmat double `matdown', name(col)
			
			* make it unique name
			foreach var in `temp0' {
				ren `var' `matname'_`var'
			}
			
			* take off 1's that's been slapped on
			*cap ren `matname'1 `matname'
		}
		
		count if eqname~=""
		local usingEqExist=`r(N)'
		
		* slap back to the original master files
		if `masterEqExist'==0 | `usingEqExist'==0 {
			* at least one single equation
			sort varname
			merge varname using `"`masterSingleFile'"'
		}
		else {
			* both are multiple equations
			sort eqname varname
			merge eqname varname using `"`masterMultiFile'"'
		}
		sort mrgrow
		cap drop _m
	}
	
	tempvar order constCol
	gen `order'=_n
	gen `constCol'=0
	replace `constCol'=1 if varname=="_cons"
	sort `constCol' `order'
	drop `constCol' `order'
	
	* slap on SINGLE if only some are missing equation names
	local N=_N
	count if eqname==""
	if `r(N)'~=`N' {
		replace report="SINGLE:"+varname if eqname==""
		replace eqname="SINGLE" if eqname==""
	}
	
	* update
	count if mrgrow==.
	local brows=`brows'+`r(N)'
	replace mrgrow = 2*_n + 1 + `appottl' + 1
	sort eqname varname
}

	
* leave matrices if user-provided suffix available
if "`leave'"~="" {
	count if varname~=""
	local rN=r(N)
	loca name
	forval num=1/`rN' {
		local temp=report[`num']
		local name "`name' `temp'"
	}
	
	foreach var in ci_highEform ci_lowEform seEform beta coefEform ci_high ci_low pval tstat se coef {
****************************** Val must come off due to renaming
		mkmat `var'Val in 1/`rN', matrix(`var'`leave')
		mat colnames `var'`leave'=`var'`leave'
		mat rownames `var'`leave'=`name'
	}
}


*** putting together
* list of current column names other than user specified matrix:
* coef se report (beta) tstat T_alpha ci_low ci_high pval mrgrow astrix


gen str12 reportCol = ""

* first prepare ancillary stats (tstat | se | ci | pvalue | beta)

foreach var in varname coef coefEform beta							/*
		*/ pval tstat se seEform 						/*
		*/ ci ciEform ci_low ci_lowEform ci_high ci_highEform		/*
		*/ aster blank 								{
	gen str12 `var'String = ""
}

if `varMany'>0 & `varMany'<. & "`sumAsked'"~="" {
	foreach var in `sumList' {
		gen str12 `var'String = ""
	}
}
foreach var in covar corr pwcorr spearman pcorr semipcorr pcorrpval tau_a tau_b {
	if `varMany'>0 & `varMany'<. & "``var'Asked'"~="" {
		gen str12 `var'String = ""
	}
}
foreach var in eqname         label label_pr label_up label_low test001 test01 test05 test10 {
	if `varMany'>0 & `varMany'<. & "``var'Asked'"~="" {
		gen str12 `var'String = ""
	}
}

if `varMany'>0 & `varMany'<. {
	foreach var in `cmdList' {
		gen str12 `var'String = ""
	}
	foreach var in `strList' {
		gen str12 `var'String = ""
	}
}

*** string
replace varnameString=report

foreach var in eqname varname label label_pr label_up label_low {
	if `varMany'>0 & `varMany'<. & "``var'Asked'"~="" {
		replace `var'String = `var'
	}
}


*** string that needs numericals
	foreach cmd in test001 {
		if "``cmd'Asked'"=="`cmd'" {
			gen str7 `cmd' = ""
			local temp_p=subinstr("`cmd'","test","",.)
			replace `cmd'="+" if coef<. & pval<.
			replace `cmd'="-" if coef<0 & pval<.
			replace `cmd'="?" if pval>`temp_p'/1000 & pval<.
			* get it reported
			replace `cmd'String=`cmd'
		}
	}
	foreach cmd in test01 test05 test10  {
		if "``cmd'Asked'"=="`cmd'" {
			gen str7 `cmd' = ""
			local temp_p=subinstr("`cmd'","test","",.)
			replace `cmd'="+" if coef<. & pval<.
			replace `cmd'="-" if coef<0 & pval<.
			replace `cmd'="?" if pval>`temp_p'/100 & pval<.
			* get it reported
			replace `cmd'String=`cmd'
		}
	}
	
local N=_N
* autodigit matrix columns
if `"`vectorList'"'~="" {
	foreach var in `vectorList' {
		gen str12 `var'String = ""
	}
	
	* autoformat all user-defined matrices
	foreach name in `vectorList' {
		autogen `name', replace(`name'String)  auto(`auto') less(`less') fmt(`fmt') width(12) decmark(`decmark')
	}
}
if `"`nonvecList'"'~="" {
	foreach var in `nonvecList' {
		gen str12 `var'String = ""
	}
	
	* autoformat all user-defined matrices
	foreach name in `nonvecList' {
		autogen `name', replace(`name'String)  auto(`auto') less(`less') fmt(`fmt') width(12) decmark(`decmark')
	}
}

replace asterString = astrix if astrix~=""


/* not effective b/c drop/keep done above, yet tstat is not define up there
*** set nocons if Constant row is empty
tempvar test1 test2
gen `test1'=.
foreach var in `statsList' {
	* capture 'cause might not exist
	cap replace `test1'=1 if `var'~=.
}
gen `test2'=1 if `test1'==. & varname=="_cons"
qui summarize `test2', meanonly
			if _rc==101 {
				noi di in red "pweight not allowed"
				exit 101
			}

if `r(N)'>0 {
	local cons nocons
}
drop `test1' `test2'
*/


*** decimals and formats (old)

/*	* parse bfmt
	local fmttxt "e f g fc gc"
	partxtl2 `"`bfmt'"'
	local bfmtcnt = r(numtxt)
	local b = 1
	while `b'<=`bfmtcnt' {
		local bfmt`b' `r(txt`b')'
		if index("`fmttxt'","`bfmt`b''")==0 {
			di in red `"bfmt element "`bfmt`b''" is not a valid number format (f,fc,e,g or gc)"'
			exit 198
		}
	local b = `b'+1
	}
	
	*** fill in bdec(#) & bfmt(txt)
	local b = 1
	while `b'<=_N {
		local bdec`b' : word `b' of `bdec'
		if "`bdec`b''"=="" {
			local bdec`b' = `prvbdec'
		}
		local prvbdec "`bdec`b''"
		local b = `b'+1
	}
	* bfmt1 is already set above
	local b = `bfmtcnt'+1
	while `b'<=_N {
		local b_1 = `b'-1
		local bfmt`b' "`bfmt`b_1''"
		local b = `b'+1
	}
*/

*** could possibly be empty
local N=_N
if `N'==0 {
	set obs 1
}

*** ad hoc eqmatch codes
if "`eqmatch'"~="" {
	while "`eqmatch'"~="" {
		local eqmatch=trim(`"`eqmatch'"')
		gettoken one eqmatch: eqmatch
		gettoken two eqmatch: eqmatch
		_eqmatch `one' `two'
	}
}

*** stnum( ) transformations of stats( ) contents
if `"`stnum'"'~="" {
	gettoken one two: stnum, parse(,)
	while `"`one'"'~="" {
		if `"`one'"'~="," {
			`one'
		}
		gettoken one two: two, parse(,)
	}
}

*** decimals and formats

* originals
foreach thing in dec sdec bdec tdec pdec cdec rdec 			fmt sfmt bfmt tfmt pfmt cfmt rfmt {
	local `thing'0 ``thing''
}

* decimlas
if "`dec'"=="" {
	foreach stuff in dec sdec bdec tdec pdec cdec rdec {
		if "``stuff''"=="" {
			local `stuff' 3
		}
	}
}
else {
	foreach stuff in bdec sdec tdec pdec cdec rdec {
		if "``stuff''"=="" {
			local `stuff' `dec'
		}
	}
}

* formats
if "`fmt'"=="" {
	foreach stuff in fmt sfmt bfmt tfmt pfmt cfmt rfmt {
		if "``stuff''"=="" {
			local `stuff' fc
		}
	}
}
else {
	foreach stuff in bfmt sfmt tfmt pfmt cfmt rfmt {
		if "``stuff''"=="" {
			local `stuff' `fmt'
		}
	}
}

* disable autofmt if dec or bdec given
if "`dec0'"~="" | "`bdec0'"~="" {
	local noauto noauto
}

*** for the (parenthesis) numbers
	local N=_N
	if "`tdec0'"=="" & "`noauto'"~="noauto" {
		autogen tstat, replace(tstatString) auto(`auto') less(`less') fmt(`tfmt') width(12) decmark(`decmark')
		
		
		/* use autodigits
		forval num=1/`N' {
			autodigits2 tstat[`num'] `auto' `less'
			replace tstatString = string(tstat,"%12.`r(valstr)'") in `num'
			
			*autofmt, input(`=tstat[`num']') auto(`auto') less(`less')
			*replace tstatString = `"`r(output1)'"' in `num'
		}
		*/
	}
	else {
		fmtgen tstat, replace(tstatString) dec(`tdec') fmt(`tfmt') width(12) decmark(`decmark')
	}
	
	if "`sdec0'"=="" & "`noauto'"~="noauto" {
		autogen se, replace(seString) auto(`auto') less(`less') fmt(`sfmt') width(12) decmark(`decmark')
		autogen seEform, replace(seEformString) auto(`auto') less(`less') fmt(`sfmt') width(12) decmark(`decmark')
	}
	else {
		fmtgen se, replace(seString ) dec(`sdec') fmt(`sfmt') width(12) decmark(`decmark')
		fmtgen seEform, replace(seEformString ) dec(`sdec') fmt(`sfmt') width(12) decmark(`decmark')
	}
	
	if "`pdec0'"==""  & "`noauto'"~="noauto" {
		autogen pval, replace(pvalString) auto(`auto') less(`less') fmt(`pfmt') width(12) decmark(`decmark')
	}
	else {
		fmtgen pval, replace(pvalString ) dec(`pdec') fmt(`pfmt') width(12) decmark(`decmark')
	}
	
	if "`cdec0'"=="" & "`noauto'"~="noauto" {
		autogen ci_low, replace(ci_lowString) auto(`auto') less(`less') fmt(`cfmt') width(12) decmark(`decmark')
		autogen ci_high, replace(ci_highString) auto(`auto') less(`less') fmt(`cfmt') width(12) decmark(`decmark')
		replace ciString = ci_lowString + " - " + ci_highString
		
		autogen ci_lowEform, replace(ci_lowEformString) auto(`auto') less(`less') fmt(`cfmt') width(12) decmark(`decmark')
		autogen ci_highEform, replace(ci_highEformString) auto(`auto') less(`less') fmt(`cfmt') width(12) decmark(`decmark')
		replace ciEformString = ci_lowEformString + " - " + ci_highEformString
	}
	else {
		fmtgen ci_low, replace(ci_lowString) dec(`cdec') fmt(`cfmt') width(12) decmark(`decmark')
		fmtgen ci_high, replace(ci_highString) dec(`cdec') fmt(`cfmt') width(12) decmark(`decmark')
		replace ciString = ci_lowString + " - " + ci_highString
		
		fmtgen ci_lowEform, replace(ci_lowEformString) dec(`cdec') fmt(`cfmt') width(12) decmark(`decmark')
		fmtgen ci_highEform, replace(ci_highEformString) dec(`cdec') fmt(`cfmt') width(12) decmark(`decmark')
		replace ciEformString = ci_lowEformString + " - " + ci_highEformString
	}
	
	if "`beta'"=="beta" | "`betaAsked'"=="betaAsked" {
		fmtgen beta, replace(betaString) dec(`cdec') fmt(`cfmt') width(12) decmark(`decmark')
	}
	
	*** prepare coefSring
	if "`bdec0'"=="" & "`noauto'"~="noauto" {
		autogen coef, replace(coefString) auto(`auto') less(`less') fmt(`bfmt') width(12) decmark(`decmark')
		autogen coefEform, replace(coefEformString) auto(`auto') less(`less') fmt(`bfmt') width(12) decmark(`decmark')
		
		* beta here (with coef)
		if "`beta'"=="beta" | "`betaAsked'"=="betaAsked" {
			autogen beta, replace(betaString) auto(`auto') less(`less') fmt(`bfmt') width(12) decmark(`decmark')

		}
	}
	else {

		fmtgen coef, replace(coefString) dec(`bdec') fmt(`bfmt') width(12) decmark(`decmark')
		fmtgen coefEform, replace(coefEformString) dec(`bdec') fmt(`bfmt') width(12) decmark(`decmark')
		
		* beta here (with coef)
		if "`beta'"=="beta" | "`betaAsked'"=="betaAsked" {
			fmtgen beta, replace(betaString) dec(`bdec') fmt(`bfmt') width(12) decmark(`decmark')
		}
	}
	
local N=_N
if `varMany'>0 & `varMany'<. & "`sumAsked'"~="" {
	
	*** digits and formats for sumAsked:
	if "`dec0'"=="" & "`noauto'"~="noauto" {
		foreach var in `sumList' {
			autogen `var', replace(`var'String) auto(`auto') less(`less') fmt(`fmt') width(12) decmark(`decmark')
		}
		else {
			fmtgen `var', replace(`var'String) dec(`dec') fmt(`fmt') width(12) decmark(`decmark')
		}
	}
}
foreach var in covar corr pwcorr spearman pcorr semipcorr pcorrpval tau_a tau_b {
	if `varMany'>0 & `varMany'<. & "``var'Asked'"~="" {
		
		*** digits and formats for stats( ) correlations:
		if "`dec0'"=="" & "`noauto'"~="noauto" {
			autogen `var', replace(`var'String) auto(`auto') less(`less') fmt(`fmt') width(12) decmark(`decmark')
		}
		else {
			fmtgen `var', replace(`var'String) dec(`dec') fmt(`fmt') width(12) decmark(`decmark')
		}
	}
}
if `varMany'>0 & `varMany'<. {
	foreach var in `cmdList' {
		*** digits and formats for stats( ) cmd( ):
		if "`dec0'"=="" & "`noauto'"~="noauto" {
			autogen `var', replace(`var'String) auto(`auto') less(`less') fmt(`fmt') width(12) decmark(`decmark')
		}
		else {
			fmtgen `var', replace(`var'String) dec(`dec') fmt(`fmt') width(12) decmark(`decmark')
		}
	}
	foreach var in `strList' {
		*** digits and formats for stats( ) str( ):
		if "`dec0'"=="" & "`noauto'"~="noauto" {
			autogen `var', replace(`var'String) auto(`auto') less(`less') fmt(`fmt') width(12) decmark(`decmark')
		}
		else {
			fmtgen `var', replace(`var'String) dec(`dec') fmt(`fmt') width(12) decmark(`decmark')
		}
	}
	foreach var in `sigList' {
		*** digits and formats for stats( ) sig( ):
		if "`dec0'"=="" & "`noauto'"~="noauto" {
			autogen `var', replace(`var'String) auto(`auto') less(`less') fmt(`fmt') width(12) decmark(`decmark')
		}
		else {
			fmtgen `var', replace(`var'String) dec(`dec') fmt(`fmt') width(12) decmark(`decmark')
		}
	}
}

order report eq* var* 

*** ststr( ) transformations of stats( ) contents
if `"`ststr'"'~="" {
	* convert non-string into string of the same name if possible
	local strList
	foreach var of varlist *String {
		local temp=substr("`var'",1,length(trim("`var'"))-6)
		cap confirm string variable `temp, exact
		if _rc~=0 {
			* not a string
			tempvar `temp'numer
			cap gen ``temp'numer'=`temp'
			cap tostring `temp', replace force
			cap replace `temp'=`temp'String
			if _rc==0 {
				local tempvarList `"`tempvarList' `temp'numer"'
			}
		}
	}
	
	gettoken one two: ststr, parse(,)
	while `"`one'"'~="" {
		if `"`one'"'~="," {
			`one'
		}
		gettoken one two: two, parse(,)
	}
	
	* convert back to numeral format if available
	foreach var in `tempvarList' {
		local temp=substr("`var'",1,length(trim("`var'"))-5)
		cap replace `temp'String=`temp'
			* work around for varabbrev on
		cap confirm variable `temp', exact
		if _rc==0 {
			drop `temp'
		}
		cap gen `temp'=`temp'numer
	}
}

*** handle fvts 2 of 2
* ad hoc fix for zeros - may have trouble with summary and tabulations
	foreach thing in coef coefEform beta pval tstat se seEform ci ciEform ci_low ci_lowEform ci_high ci_highEform {
		cap replace `thing'String="-" if coef==0 & se==0 & (fvts_type=="o"| fvts_type=="b")
		*cap replace `thing'String="base" if coef==0 & se==0 & (fvts_type=="b")
		*cap replace `thing'String="omitted" if coef==0 & se==0 & (fvts_type=="o")
	}
	
	
	* slap parenthesis for non-blank, even rows (as in parity)
	* do not work well with sideway
	* this might be violated by -sideway- but -cap replace- prevents error
	if `"`bracketA'"'=="" & `"`bracket'"'=="" & `"`parenthesis'"'=="" & "`paren'"~="noparen" {
		gettoken one two: statsList
		local odd 1
		while `"`two'"'~="" {
			if `odd'==0 {
				local parenthesis	"`parenthesis' `one'"
				local odd 1
			}
			else {
				local odd 0
			}
			gettoken one two: two
		}
		if `odd'==0 {
			local parenthesis	"`parenthesis' `one'"
			local odd 1
		}
		else {
			local odd 0
		}
	}

************ ad hoc fix
* take out Eform and put it back in
local parenthesis `"`parenthesis' "'
local parenthesis : subinstr local parenthesis "Eform " " ", all
local parenthesis =trim("`parenthesis'")

if `"`paren'"'~="noparen" {
	if `"`bracketA'"'=="" & `"`bracket'"'=="" & `"`parenthesis'"'=="" {
		local parenthesis "se"
	}
	
	if `"`parenthesis'"'~="" {
		* other possible valid: level coef_eform se_eform coef_beta se_beta
		* also added: seEform, etc
		optionSyntax, valid(eqname varname label label_pr label_up label_low test001 test01 test05 test10  coef se tstat pval ci aster blank beta ci_low ci_high N sum_w mean Var /*
			*/ sd skewness kurtosis sum min max p1 p5 p10 p25 p50 p75 p90 p95 p99 cv range iqr semean median count corr covar pwcorr spearman /*
			*/ pcorr semipcorr pcorrpval tau_a tau_b `cmdList' `strList' `matList') /*
			*/ name(parenthesis) nameShow(paren:thesis( )) content(`parenthesis') passthru noreturn
		local parenList `"`optionList'"'
		local parenPerCoef `optionCount'
	}
	
	* update when eform specified
	if "`eform'"=="eform" {
		local parenList "`parenList' "
		* may be redundant
		local parenList : subinstr local parenList "coef " "coefEform ", all
		local parenList : subinstr local parenList "ci " "ciEform ", all
		local parenList : subinstr local parenList "se " "seEform ", all
		
		local parenList : subinstr local parenList "ci_high " "ci_highEform ", all
		local parenList : subinstr local parenList "ci_low " "ci_lowEform ", all
	}
	
	if `"`bracketA'"'~="" {
		*** bracketA( ) option cleanup
		* other possible valid: level coef_eform se_eform coef_beta se_beta
		optionSyntax, valid(eqname varname label label_pr label_up label_low test001 test01 test05 test10  coef se tstat pval ci aster blank beta ci_low ci_high N sum_w mean Var /*
			*/ sd skewness kurtosis sum min max p1 p5 p10 p25 p50 p75 p90 p95 p99 cv range iqr semean median count covar corr pwcorr spearman /*
			*/ pcorr semipcorr pcorrpval tau_a tau_b `cmdList' `strList' `matList' ) /*
			*/ name(bracketA) nameShow(br:acket( )) content(`bracketA') passthru noreturn
		local bracketList `"`optionList'"'
		local bracketPerCoef `optionCount'
	}
	
	* update when eform specified
	if "`eform'"=="eform" {
		local bracketList "`bracketList' "
		* may be redundant
		local bracketList : subinstr local bracketList "coef " "coefEform ", all
		local bracketList : subinstr local bracketList "ci " "ciEform ", all
		local bracketList : subinstr local bracketList "se " "seEform ", all
	}
	
	if "`bracket'"=="bracket" & "`parenthesis'"=="" {
		replace tstatString = "[" + tstatString + "]" if tstatString ~=""
		replace pvalString = "[" + pvalString + "]" if pvalString  ~=""
		replace ciString = "[" + ciString + "]" if ciString ~=""
		replace ciEformString = "[" + ciEformString + "]" if ciEformString ~=""
		
		replace ci_lowString = "[" + ci_lowString + "]" if ci_lowString ~=""
		replace ci_highString = "[" + ci_highString + "]" if ci_highString ~=""
		replace ci_lowEformString = "[" + ci_lowEformString + "]" if ci_lowEformString ~=""
		replace ci_highEformString = "[" + ci_highEformString + "]" if ci_highEformString ~=""
		
		replace betaString= "[" + betaString+ "]" if betaString ~=""
		replace seString = "[" + seString + "]" if seString ~=""
		replace seEformString = "[" + seEformString + "]" if seEformString ~=""
		replace betaString= "[" + betaString+ "]" if betaString ~=""
	}
	else if "`bracket'"=="bracket" & "`parenthesis'"~="" {
		local num 1
		while `num'<=`parenPerCoef' {
			local temp : word `num' of `parenList'
			replace `temp'String = "[" + `temp'String + "]" if `temp'String ~=""
			local num=`num'+1
		}
	}	
	else {
		if "`parenthesis'"~="" {
			local num 1
			while `num'<=`parenPerCoef' {
				local temp : word `num' of `parenList'
				cap replace `temp'String = "(" + `temp'String + ")" if `temp'String ~=""
				local num=`num'+1
			}
		}
		if "`bracketA'"~="" {
			local num 1
			while `num'<=`bracketPerCoef' {
				local temp : word `num' of `bracketList'
				cap replace `temp'String = "[" + `temp'String + "]" if `temp'String ~=""
				local num=`num'+1
			}
		}
	}
} /* if `"`paren'"'~="noparen" */

* when no coefficient/cons are present (prevent subid from going undefined)
local N=_N
if `N'==0 {
	set obs 1
}

gen id=_n
expand `statsMany'
bys id: gen subid=_n

replace report = "" if subid~=1 /* no variable names next to tstats */
if `"`asterisk'"'~="" {
	
	*** asterisk( ) option cleanup
	local asterValid "coef se tstat pval ci        blank beta ci_low ci_high"
	* no aster here
	* level coef_eform se_eform coef_beta se_beta"
	
	* take comma out
	local asterisk : subinstr local asterisk "asterisk(" " ", all
	local asterisk : subinstr local asterisk ")" " ", all
	local asterisk : subinstr local asterisk "," " ", all
	
	local asterPerCoef : word count `asterisk'
	local num=1
	local asterList ""
	
	while `num'<=`asterPerCoef' {
		local aster`num' : word `num' of `asterisk'
		
		* it must be one of the list
		local test 0
		foreach var in `asterValid' {
			if "`var'"=="`aster`num''" & `test'==0 {
				local test 1
			}
		}
	* no longer test for asterValid
	*	if `test'==0 {
	*		noi di in red "{opt `aster`num''} is neither a valid option or matrix for {opt aster:isk( )}"
	*		exit 198
	*	}
		local asterList "`asterList' `aster`num''"
		local num=`num'+1
	}
}
* update when eform specified
if "`eform'"=="eform" {
	local asterList "`asterList' "
	local asterList : subinstr local asterList "coef " "coefEform ", all
	local asterList : subinstr local asterList "ci " "ciEform ", all
	local asterList : subinstr local asterList "se " "seEform ", all
	
	local asterList : subinstr local asterList "ci_high " "ci_highEform ", all
	local asterList : subinstr local asterList "ci_low " "ci_lowEform ", all
}

*** combining them into one column

if "`asterisk'" == "" {
	forval num=1/`statsMany' {
		local var : word `num' of `statsList'
		replace reportCol=`var'String if subid==`num'
		
		* attach asterString
		replace reportCol=`var'String + asterString if subid==`num' & ("`var'"=="coef" | "`var'"=="coefEform")
	}
}
else {
	forval num=1/`statsMany' {
		local var : word `num' of `statsList'
		replace reportCol=`var'String if subid==`num'
		
		* attach asterString
		forval nn=1/`asterPerCoef' {
			replace reportCol=`var'String + asterString if subid==`num' & ("`var'"=="`aster`nn''" | "`var'"=="`aster`nn''Eform")
		}
	}
}

* drops vector/matrices as well:
keep report eqname varname mrgrow reportCol

local num=mrgrow[1]-2
replace mrgrow=`num'+_n

* first find number of new rows for addstat()
if `"`addstat'"'!="" {
	partxtl3 `"`addstat'"'
	local naddst = int((real(r(numtxt))+1)/2)
	
	local n = 1
	while `n'<=`naddst' {
		local t = (`n'-1)*2+1
		local astnam`n' `r(txt`t')'
		local t = `t'+1
		local astval`n' `r(txt`t')' /* pair: stat name & value */
		local n = `n'+1
	}
}
else {
	local naddst=0
}

* find number of new rows for addnote()
if (`"`addnote'"'!="" & "`append'"!="append") | (`"`addnote'"'!="" & `fileExist'==0) {
	partxtl2 `"`addnote'"'
	local naddnt = r(numtxt)
	local n = 1
	while `n'<=`naddnt' {
		local anote`n' `r(txt`n')'
		local n = `n'+1
	}
}
else {
	local naddnt=0
}

* calculate total number of rows in table
* added a second extra line above the coefficients: place 2 of 2
*local coefrow = 2*`brows'+1+`appottl' + 1
local coefrow = `statsMany'*`brows'+1+`appottl' + 1
*local totrows =     `coefrow' + ("`nobs'"!="nonobs") + (`numi'!=.) + ("`r2'"!="nor2"&`rsq'!=.&`df_r'!=.) + `naddst' + ("`notes'"!="nonotes"&"`append'"!="append")*(1+("`aster'"!="noaster")) + `naddnt'
cap local totrows = 2 + 20 + `coefrow' + ("`nobs'"!="nonobs") + (`numi'!=.) + ("`r2'"!="nor2")                    + `naddst' + ("`notes'"!="nonotes"&"`append'"!="append")*(1+("`aster'"!="noaster")) + `naddnt' + ("`notes'"!="nonotes" & `fileExist'==0)*(1+("`aster'"!="noaster"))
*                2 added for the top and bottom row (empty), 20 added for the heck of it
* totrows calculation is apparently no longer accurate when no file exists; merely add 20, drop the extra row at the end

* cap here because could be lower due to drop/nocons
cap set obs `totrows'
if _rc~=0 {
	local N20=_N+20
	set obs `N20'
}

* insert the top row (empty), rowtype2==0
local N=_N
set obs `=`N'+1'
local N=_N
replace mrgrow = 1 in `N'

gen rowtype2=0 in `N'

local N=_N

*** always add the head column numbers
if "`append'"=="append" & `fileExist'==1 {
	replace mrgrow = 0.001 in `=`N'-2'
	replace reportCol = "(1)" in `=`N'-2'
}
else {
	replace mrgrow = 0.001 in `=`N'-2'
	replace reportCol = "(1)" in `=`N'-2'
	* add one back to make up for it
	local coefrow = `coefrow'+1
}

local coefrow = `coefrow'-1

if "`eretrun'"=="" & `"`ctitleList'"'=="" {
	* because they are empty:
	local comma
	foreach var in `statsList' {
		local ctitleList `"`ctitleList'`comma'`var'"'
		local comma ","
	}
	local comma
}

if "`eretrun'"=="" {
	local obs noobs
}

* there must be at least one ctitleList
if `"`ctitleList'"'=="" {
	local ctitleList " "
}

*** ad hoc fix for ctitleList, which is assigned by the main program from stats( ) contents
********* ctitleList needs to fixed for -sideway- and str( ) or cmd( ) invoked
if `"`cmd1'"'==`"`ctitleList'"' & "`statsMany'"=="1" {
	local ctitleList `"`reg1'"'
}
if `"`string1'"'==`"`ctitleList'"' & "`statsMany'"=="1" {
	local ctitleList "string"
}

* add to the end
if `"`ctbot'"'~="" {
	local ctitleList `"`ctitleList', `ctbot'"'
}

* parsing ctitleList contents (2 of 2), counts the first and the last comma and the consecutive commas
local rest `"`ctitleList'"'
local count 0
while `"`rest'"'~="" {
	gettoken first rest: rest, parse(",")
	if `"`first'"'=="," & `count'==0 {
		local count=`count'+1
		local txt`count'
	}
	if `"`first'"'~="," {
		local count=`count'+1
		local txt`count' `"`first'"'
	}
	if `"`first'"'=="," & `"`previous'"'=="," {
		local count=`count'+1
		local txt`count'
	}
	local previous `"`first'"'
}
if `"`first'"'=="," & `count'~=0 {
	local count=`count'+1
	local txt`count'
}

local numtxt `count'

* adding more rows for ctitles
if `numtxt'>0 {
	set obs `=`N'+`numtxt''
	local N=_N
	forval num=1/`numtxt' {
		replace mrgrow = `num'/100 in `=`N'-`num'+1'
		
		* insert ctitles
		replace reportCol=`"`txt`num''"' in `=`N'-`num'+1'
		
		replace rowtype2=-1 in `=`N'-`num'+1'
		local coefrow = `coefrow'+1
	}
}

sort mrgrow
replace mrgrow = _n

* the bottom row (empty), rowtype2==2
local coefrow = `coefrow'+1

replace rowtype2=-1 if rowtype2[_n+1]==0 | rowtype2[_n+1]==-1

replace rowtype2=1 if _n<`coefrow' & rowtype2==.
replace rowtype2=2 if _n==`coefrow'
replace rowtype2=3 if _n>`coefrow'

* only if it's not sideway runons
if `sidewayWave'==1 {
	
	* number of observations
	if "`obs'"!="noobs" {
		local coefrow = `coefrow'+1
		replace report = "Observations" if _n==`coefrow'
		*replace reportCol = string(`regN') if _n==`coefrow'
		cap replace reportCol = string(`regN',"%12.0fc") if _n==`coefrow'
	}
	
	if "`eretrun'"~="" {
		if (`numi'!=. & "`ni'"!="noni") {
			local coefrow = `coefrow'+1
			replace report = "Number of " + rtrim(`"`iname'"') if _n==`coefrow'
			*replace reportCol = string(`numi') if _n==`coefrow'
			cap replace reportCol = string(`numi',"%12.0fc") if _n==`coefrow'
		}
		
		* scalar crap, no rsq if it's a dot
		if "`r2'"~="nor2" {
			if `=`rsq''==. {
				local r2 "nor2"
			}
		}
		
		if "`r2'"!="nor2" {
			/* if df_r=., not true r2 */
			local coefrow = `coefrow'+1
			replace reportCol = string(`rsq',"%12.`rdec'`rfmt'") if _n==`coefrow'
			if `"`decmark'"'~="" {
				replace reportCol = subinstr(reportCol,".",`"`decmark'"',.) if _n==`coefrow'
			}
			replace report = "R-squared" if _n==`coefrow'
			if "`adjr2'"=="adjr2" {
				replace report = "Adjusted " + report if _n==`coefrow'
			}
		}
	} /* eretrun */
	
	*** addtext here
	if `"`addtext'"'!="" {
		partxtl2 `"`addtext'"'
		local temp = int((real(r(numtxt))+1)/2)
		
		local n = 1
		while `n'<=`temp' {
			local t = (`n'-1)*2+1
			local textName`n' `r(txt`t')'
			local t = `t'+1
			local textValue`n' `r(txt`t')' /* pair: stat name & value */
			local n = `n'+1
		}
		
		local i 1
		while `i'<=`temp' {
			* increase
			local coefrow = `coefrow'+1
			local N=_N
			set obs `=`N'+1'
			
			if `"`textValue`i''"'!="" {
				replace reportCol = "`textValue`i''" if _n==`coefrow'
			}
			replace report = trim(`"`textName`i''"') if _n==`coefrow'
			local i = `i'+1
		}
		
		* cleanup counting
		replace mrgrow=_n
	}
	
	*** addstat here
	if `"`addstat'"'!="" {
		local i 1
		local adeccnt : word count `adec'
		while `i'<=`naddst' {
			local coefrow = `coefrow'+1
			local aadec : word `i' of `adec'
			if "`aadec'"=="" {
				local aadec `prvadec'
			}
			if `"`astval`i''"'!="" {
				replace reportCol = "`astval`i''" if _n==`coefrow'
				if `"`decmark'"'~="" {
					replace reportCol = subinstr(reportCol,".",`"`decmark'"',.) if _n==`coefrow'
				}
			}
			replace report = trim(`"`astnam`i''"') if _n==`coefrow'
			local i = `i'+1
			local prvadec `aadec'
		}
	}
}


local parenList=trim(`"`parenList'"')

if "`eretrun'"~="" & ("`notes'"!="nonotes" & "`append'"!="append") | ("`notes'"!="nonotes" & `fileExist'==0) {
	if "`bracket'"=="bracket" | "`bracketA'" ~= "" {
		local par_bra "brackets"
	}
	else {
		local par_bra "parentheses"
	}
	
	* notes
	if "`statsList'"=="coef pval" {
		local statxt "p-values"
	}
	else if "`statsList'"=="coef se" {
		local statxt "Standard errors"
	}
	else if "`statsList'"=="coef pi" {
		local statxt "`level'% confidence intervals"
	}
	else if "`beta'"=="beta" {
		local statxt "Normalized beta coefficients"
	}
	else if "`parenList'"=="se" {
		local statxt "Standard errors"
	}
	else if "`parenList'"=="tstat" {
		if `df_r'!=. {
			local t_or_z "t"
		}
		else {
			local t_or_z "z"
		}
		local statxt "`t_or_z'-statistics"
	}
	else {
		local statxt `"`parenList'"'
	}
	
	if "`robust'"=="Robust" {
		local statxt = "Robust " + lower("`statxt'")
	}
	
	* actually inserting	
	if ("`parenList'"~="" | "`bracketList'"~="" ) & "`statsList'"~="coef" {
		if `"`paren'"'~="noparen" {
			local coefrow = `coefrow'+1
			replace report = "`statxt' in `par_bra'" if _n==`coefrow'
		}
	}
	if "`aster'"!="noaster" {
		local coefrow = `coefrow'+1
		replace report = "`astrtxt'" if _n==`coefrow'
	}
}

if (`"`addnote'"'!="" & "`append'"!="append") | (`"`addnote'"'!="" & `fileExist'==0) {
	local i 1
	while `i'<=`naddnt' {
		local coefrow = `coefrow'+1
		replace report = `"`anote`i''"' if _n==`coefrow'
		local i = `i'+1
	}
}

* attach the column name
replace report=`"`VARIABLES'"' if rowtype2[_n+1]==0
replace report=`"`VARIABLES'"' if rowtype2==0 & report[_n-1]~=`"`VARIABLES'"'


*** drop the extra rows at the end, if still exist, unless it is the bottom row
local N=_N
local temp=report[`N']
local check=rowtype2[`N']
while "`temp'"=="" & `check'>2 {
	drop in `N'
	local N=_N
	local temp=report[`N']
	local check=rowtype2[`N']
}

*** handle equationsA(auto)
if "`equationsOption'"=="auto" {
		
	*******************************cap set unabbr off
	local N=_N
	forval num=1/`N' {
		local temp=eqname[`num']
		if "`temp'"~="" {
			* check if this variable exists
			cap summarize `temp', meanonly
			if _rc==101 {
				noi di in red "pweight not allowed"
				exit 101
			}
			if _rc~=0 {
				count if eqname=="`temp'"
				local thisMany=r(N)/`statsMany'
				if `thisMany'>1 & `thisMany'<. {
					replace report ="Constant" if	eqname=="`temp'" & varname=="_cons" & report~=""
					replace report =varname if		eqname=="`temp'" & varname~="_cons" & report~=""
					replace eqname="" if eqname=="`temp'"
				}
				else {
					replace report =eqname if	eqname=="`temp'" & varname=="_cons" & report~=""
					replace eqname="" if eqname=="`temp'"
				}
			}
		}
	}
}

*** handle policy 3 of 3
if "`policy0'"~="" {
	local cc: word count `policyList'
	if `cc'>0 & `cc'<. {
		if `cc'==1 {
			replace report="Policy" if report=="`policyList'"
			replace varname="Policy" if varname=="`policyList'"
		}
		else {
			local num 1
			foreach var in `policyList' {
				replace report="Policy `num'" if report=="`var'"
				replace varname="Policy `num'" if varname=="`var'"
				local ++num
			}
		}
	}
}



qui replace reportCol="" if (reportCol=="(-)" | reportCol=="[-]" | reportCol=="(omitted)" | reportCol=="[omitted]" | reportCol=="(base)" | reportCol=="[base]") & rowtype2==1

* also c_local varname_list1 above

end		/* makeFile */


********************************************************************************************


prog define seeing
	versionSet
	version `version'

quietly {
	
	* syntax using/[, Clear]
	syntax using [, LABel LABelA(str) ]
	
	preserve
	
	insheet2 `using', nonames clear
	describe, short
	
	
	* number of columns
	local numcol = `r(k)'
	
	tempvar blanks rowmiss
	count if v1=="EQUATION"
	if `r(N)'~=0 {
		local eqPlace 1
		local varPlace 2
		count if v3=="LABELS"
		if `r(N)'~=0 {
			local labPlace 3
			local num=4
		}
		else {
			local labPlace 0
			local num=3
		}
	}
	else {
		local eqPlace 0
		local varPlace 1
		
		count if v2=="LABELS"
		if `r(N)'~=0 {
			local labPlace 2
			local num=3
		}
		else {
			local labPlace 0
			local num=2
		}
	}
	
	gen int `blanks' = (trim(v`num')=="")
	forvalues col = `num'/`numcol' {
		replace `blanks' = `blanks' & (trim(v`col')=="")
	}
	
	
	* title rows
	local titleWide = 0
	if v1[1]~="" | v2[1]~="" {
		* there may be a title
		if `labPlace'==0 & `varPlace'==1 {
		      while v1[`=`titleWide'+1']~="" &  v2[`=`titleWide'+1']=="" {
				local titleWide = `titleWide'+1
		}
			}
		if `labPlace'==0 & `varPlace'==2 {
		      while v2[`=`titleWide'+1']~="" &  v3[`=`titleWide'+1']=="" {
				local titleWide = `titleWide'+1
			}
		}
		if `labPlace'~=0 & `varPlace'==1 {
		      while v1[`=`titleWide'+1']~="" &  v3[`=`titleWide'+1']=="" {
				local titleWide = `titleWide'+1
			}
		}
		if `labPlace'~=0 & `varPlace'==2 {
	      while v2[`=`titleWide'+1']~="" &  v4[`=`titleWide'+1']=="" {
				local titleWide = `titleWide'+1
			}
		}
	}
	
	*local VARIABLES "VARIABLES"
	* first name AFTER titles is the VARIABLES
	local content
	local num=`titleWide'+1
	local N=_N
	while `"`content'"'=="" & `num'<=`N' {
		local content=v`varPlace'[`num']
		local num=`num'+1
	}
	local VARIABLES `"`content'"'
	
	replace `blanks'=0 if  v1==`"`VARIABLES'"' | v1[_n-1]==`"`VARIABLES'"' | v2==`"`VARIABLES'"' | v2[_n-1]==`"`VARIABLES'"'
	
		
	* getting bottomBorder (the bottom border), count up
	gen rowmiss=0
	foreach var of varlist v* {
		replace rowmiss=rowmiss+1 if `var'~=""
	}
	local N=_N
	local content 1
	local num 0
	while `content'==1 & `num'<`N' {
		local content rowmiss[`=`N'-`num'']
		local num=`num'+1
	}
	* do not have to add to titleWide
	local bottomRow = `N'-`num'+1
	local bottomBorder=`bottomRow'
	
	* getting halfway to headBorder (the top border), count down
	local content
	local num=`titleWide'+1
	local N=_N
	while `"`content'"'=="" & `num'<=`N' {
		local content=v`varPlace'[`num']
		local num=`num'+1
	}
	* do not have to add to titleWide
	local headRow `num'
	local headBorder=`headRow'
	
	drop rowmiss
	
	
	* avoid counting space within each statistics row as missing
	replace `blanks'=0 if `blanks'[_n+1]==0 & `blanks'==1 & _n >`titleWide'
	
	
	* statistics rows
	*count if `blanks'==0
	*local bottomBorder = `r(N)'+`titleWide'
	
	
	* move the notes and titles to the top of a new column
	gen str5 Notes_Titles=""
	format Notes_Titles %-20s 
	count if v1=="EQUATION"
	if `r(N)'==0 {
		* EQUATION column does not exist
		if `titleWide'>0 {
			forval num=1/`titleWide' {
				replace Notes_Titles=v1[`num'] in `num'
				replace v1="" in `num'
			}
		}
		
		local one = 1
		local legend = v1[`bottomBorder'+`one']
		
		
		local place 1
		*while "`legend'"~="" {
		local N=_N
		while `place' <= `N' {
			local place=`bottomBorder'+`one'
			local legend = v1[`place']
			replace Notes_Titles="`legend'" in `=`one'+`titleWide'+1'
			if "`legend'"~="" {
				replace v1="" in `place'
			}
			local one = `one'+1
		}
		
		* insert label changes here, minus 2 from c(k) for `blanks' & Notes_Titles column
		if "`label'"=="label" {
				*if ("`long'"~="long" & "`onecol'"~="onecol") | ("`long'"=="long" & "`onecol'"=="onecol") {
					replace v2=v1 if v2==""
					drop v1
					describe, short
					forval num=1/`=`r(k)'-2' {
						ren v`=`num'+1' v`num'
					}
					
					* change LABELS to VARIABLES
					replace v1=`"`VARIABLES'"' if v1=="LABELS"
				*}
				local label_adjust "-1"
		}
		
		* change the string length
		gen str5 temp=""
		replace temp=v1
		drop v1
		ren temp v1
		order v1
		* format
		foreach var of varlist v1 {
			local _format= "`: format `var''"
			local _widths=substr("`_format'",2,length(trim("`_format'"))-2)
			format `var' %-`_widths's
		}
	}
	else {
		* equation column exists
		if `titleWide'>0 {
			forval num=1/`titleWide' {
				replace Notes_Titles=v2[`num'] in `num'
				replace v2="" in `num'
			}
		}
		
		local one = 1
		local legend = v2[`bottomBorder'+`one']
		while "`legend'"~="" {
			local place=`bottomBorder'+`one'
			local legend = v2[`place']
			replace Notes_Titles="`legend'" in `=`one'+`titleWide'+1'
			if "`legend'"~="" {
				replace v2="" in `place'
			}
			local one = `one'+1
		}
		
		* insert label changes here, minus 2 from c(k) for `blanks' & Notes_Titles column
		if "`label'"=="label" {
				*else if "`long'"~="long" & "`onecol'"=="onecol" {
					replace v3=v2 if v3==""
					drop v2
					describe, short
					forval num=2/`=`r(k)'-2' {
						ren v`=`num'+1' v`num'
					}
					
					* change LABELS to VARIABLES
					replace v2=`"`VARIABLES'"' if v2=="LABELS"
				*}
				local label_adjust "-1"
		}
		
		
		* change the string length
		gen str5 temp=""
		replace temp=v2
		drop v2
		ren temp v2
		order v1 v2
		* format
		foreach var of varlist v1 v2 {
			local _format= "`: format `var''"
			local _widths=substr("`_format'",2,length(trim("`_format'"))-2)
			format `var' %-`_widths's
		}
	}
	
	* clean up
	*egen `rowmiss'=rowmiss(_all)
	* rowmiss option not available in 8.2 or 8.0, do it by hand
	
	gen `rowmiss'=0
	foreach var of varlist _all {
		if "`var'"~="`rowmiss'" & "`var'"~="`blanks'" {
			replace `rowmiss'=1+`rowmiss' if `var'==""
		}
	}
	
	*drop if `rowmiss'==`numcol'+1
	
	* adjust to handle label column droppings
	*drop if `rowmiss'==`numcol'+1 & `blanks'==1
	
	* fix blanks==1 for groupvar( )
	count if `blanks'==1
	local rN=`r(N)'+1
	forval num=1/`rN' {
		replace `blanks'=0 if `blanks'[_n+1]==0 & `blanks'==1
	}
	
	drop if `rowmiss'==`numcol'+1 `label_adjust' & `blanks'==1
	drop `blanks' `rowmiss'
	
	browse
	
	if "`Version7'"=="" {
		* it is version 7
	}
	else if `Version7'>=11.0 {
		noi di in yel "Hit Enter to continue" _request(c_request)
		if `"$c_request"'~="" {
			c_local c_request $c_request
			global c_request
		}
	}
}
end  /* end of seeing */


********************************************************************************************


* 02nov2009 to handle strings
* 15dec2009 to decmark( ) added
prog define fmtgen
	
	syntax [varlist(default=none)] [in], replace(str asis) fmt(str asis) [dec(int 3) auto(int 3) less(int 0) /*
		*/ width(int 12) gen(str asis) decmark(str asis)]

if "`varlist'"~="" {
	local varname `varlist'
	replace `replace' = string(`varname',"%12.`dec'`fmt'") `in'
	
	if "`decmark'"~="" {
		replace `replace' = subinstr(`replace',".",`"`decmark'"',.) `in'
	}
}

end


********************************************************************************************


* 02nov2009 to handle strings and variables in addition to numbers
* 09nov2009 also accomodates various user-specified formats, including e
* 15dec2009 to decmark( ) added

prog define autogen
	versionSet
	version `version'
	
	syntax [varlist(default=none)] [in], replace(str asis) [dec(int 3) fmt(str asis) auto(int 3) less(int 0) /*
		*/ width(int 12) gen(str asis) decmark(str asis)]

if "`fmt'"=="" {
	local fmt f
}

if "`varlist'"~="" {
	local varname `varlist'
	
	if "`in'"~="" {
		gettoken junk begin: in, parse(" ")
		gettoken begin end: begin, parse("/")
		gettoken slash end: end, parse("/")
	}
	else {
		local begin 1
		local end=_N
		local in "in 1/`=_N'"
	}
	
	cap confirm numeric var `varname'
	
	if _rc==0 {
		tempvar whole times left aadec aadecString valstr format
		*gen `whole'=1 if round((`varname' - int(`varname')),0.0000000001)==0 
		*gen `whole'=1 if float(`varname') - int(`varname')==0
		gen `whole'=1 if round(`varname' - int(round(`varname',0.0000000001)),0.0000000001)==0
		replace `whole'=0 if `whole'==.
		
		* digits that need to be moved if it were only decimals: take the ceiling of log 10 of absolute value of decimals
		gen `times'=abs(int(ln(abs(`varname'-int(`varname')))/ln(10)-1)) if `whole'==0
		
		* the whole number: take the ceiling of log 10 of absolute value
		gen `left'=int(ln(abs(`varname'))/ln(10)+1) if `whole'==0
		
		* assign the fixed decimal values into aadec
		gen `aadec'=0 if `whole'==1
			
			* reduce the left by one if more than zero to accept one extra digit
			replace `aadec'=`auto'-`left'+1 if .>`left' & `left'>0 & `left'<=`auto' & `whole'==0
			replace `aadec'=`auto'-`left'-1 if .>`left' & `left'>0 & `left'>`auto' & `whole'==0
			
			* else
			replace `aadec'=`times'+`auto'-1 if (.<=`left' | `left'<=0) & `whole'==0
			
			* needs to between 0 and 11
			replace `aadec'=`aadec'-`less'
			replace `aadec'=0 if `aadec'<0
			
			gen str12 `aadecString'=string(`aadec')
			gen str12 `valstr'=""
			
			replace `valstr'=`aadecString'+"`fmt'" if `aadec'<7 & `aadec'~=.
			if "`fmt'"=="e" {
				replace `valstr'="`=`auto'-0'e"
			}

			replace `valstr'="`=`auto'-1'e" if `aadec'>=7 & `aadec'~=.
			
			* make it exponential if too big or too negative (small)
			replace `valstr' = "`=`auto'+0'e" if `varname'>1000000 & `varname'<.
			replace `valstr' = "`=`auto'+0'e" if `varname'<-1000000 & `varname'<.
			
			gen str12 `format'= "%`width'." + `valstr' if `valstr'~=""
			
		forval num=`begin'/`end' {
			local content=`format'[`num']
			replace `replace' = string(`varname',"`content'") in `num'
		}
	}
	else {
		* string variable, do it old-fashioned way
		replace `replace'=`varname'
		forval num=`begin'/`end' {
			capture confirm number `=`varname'[`num']'
			if _rc==0 {
				autofmt, input(`=`varname'[`num']') dec(`auto') less(`less')
				if "`=`varname'[`num']'"~="" {
					replace `replace' = string(`=`varname'[`num']',"%`width'.`r(deci1)'`fmt'") if _n==`num' & "`r(deci1)'"~="."
				}
				/*
				autodigits2 `=`varname'[`num']' `auto' `less'
				if "`=`varname'[`num']'"~="" {
					replace `replace' = string(`=`varname'[`num']',"%`width'.`r(valstr)'") if _n==`num' & "`r(valstr)'"~="."
				}
				*/
				*autodigits2 tstat[`num'] `auto' `less'
				*replace tstatString = string(tstat,"%12.`r(valstr)'") in `num'
			}
		}
	}
}
else {
	* not a variable

}

if "`decmark'"~="" {
	replace `replace' = subinstr(`replace',".",`"`decmark'"',.) `in'
}


end


********************************************************************************************


* 03nov2009 integer check upgraded to handle more indeterminancy coming from string numerals
* 15dec2009 to decmark( ) added

prog define autodigits2, rclass
	versionSet
	version `version'

* getting the significant digits
args input auto less decmark

if `input'~=. {
	local times=0
	local left=0
	
	* integer checked by modified mod function
	*if round((`input' - int(`input')),0.0000000001)==0 {
	if round(`input' - int(round(`input',0.0000000001)),0.0000000001)==0 {
		local whole=1
	}
	else {
		local whole=0
		* non-interger
		 if `input'<. {
			
			* digits that need to be moved if it were only decimals: take the ceiling of log 10 of absolute value of decimals
			local times=abs(int(ln(abs(`input'-int(`input')))/ln(10)-1))	
			
			* the whole number: take the ceiling of log 10 of absolute value
			local left=int(ln(abs(`input'))/ln(10)+1)
		}
	}
	
	
	* assign the fixed decimal values into aadec
	if `whole'==1 {
		local aadec=0
	}
	else if .>`left' & `left'>0 {
		* reduce the left by one if more than zero to accept one extra digit
		if `left'<=`auto' {
			local aadec=`auto'-`left'+1
		}
		else {
			local aadec=0
		}
	}
	else {
		local aadec=`times'+`auto'-1
	}
	
	if "`less'"=="" {
		* needs to between 0 and 11
		if `aadec'<0 {
			local aadec=0
		}
		*if `aadec'<11 {
		if `aadec'<7 {
			* use fixed
			local valstr "`aadec'f"
		}
		else {
			* use exponential
			local valstr "`=`auto'-1'e"
		}
	}
	else {
		* needs to between 0 and 11
		local aadec=`aadec'-`less'
		if `aadec'<0 {
			local aadec=0
		}
		*if `aadec'<10 {
		if `aadec'<7 {
			* use fixed
			local valstr "`aadec'f"
		}
		else {
			* use exponential
			local valstr "`=`auto'-1'e"
		}
	}
	
	* make it exponential if too big
	if `input'>1000000 & `input'<. {
		local valstr "`=`auto'-0'e"		
	}
	
	* make it exponential if too negative (small)
	if `input'<-1000000 & `input'<. {
		local valstr "`=`auto'-0'e"		
	}
	
	if "`decmark'"~="" {
		local valstr : subinstr local valstr "." `"`decmark'"', all
	}
	return scalar value=`aadec'
	return local valstr="`valstr'"
}
else {
	* it is a missing value
	return scalar value=.
	return local valstr="missing"
}
end


********************************************************************************************

* ripped from autofmt on 09nov2009
* autofmt 1.0.1 03nov2009 roywada@hotmail.com
* automatic formating of a significant number of digits
* 15dec2009 to decmark( ) added

prog define autofmt, rclass
version 7.0

syntax, input(str) [dec(integer 3) less(integer 0) parse(str) strict]
* parse( ) takes only one character; " " is always included as a parse

if `"`parse'"'=="" {
        local parse " "
}

local rest `"`input'"'
local count 0

if "`rest'"~="" {
        * handles the possibility the first token is empty
        gettoken first rest: rest, parse("`parse'")
        local first=trim(`"`first'"')
        if `"`first'"'==`"`parse'"' {
                local count=`count'+1
                local input`count' ""
        }
        else {
                local count=`count'+1
                local input`count' `"`first'"'
        }
}
while "`rest'"~="" {
        gettoken first rest: rest, parse("`parse'")
        local first=trim(`"`first'"')
        if `"`first'"'~=`"`parse'"' {
                local count=`count'+1
                local input`count' `"`first'"'
        }
}

if `count'==0 {
        * input( ) was left empty
        exit
}

if "`strict'"=="strict" {
	local one 0
}
else {
	local one 1
}


*** run as many times

forval num=1/`count' {

        * confirm a number
        capture confirm number `input`num''
        local rc=_rc
        
        * run if not missing and is a number
        if "`input`num''"~="." & "`input`num''"~="" & `rc'==0 {
                local times=0
                local left=0
                
                * integer checked by modified mod function
                *if round((`input`num'' - int(`input`num'')),0.0000000001)==0 {
			if round(`input' - int(round(`input',0.0000000001)),0.0000000001)==0 {
				local whole=1
			}
                else {
                        local whole=0
                        * non-interger
                         if `input`num''<. {
                                
                                * digits that need to be moved if it were only decimals: take the ceiling of log 10 of absolute value of decimals
                                local times=abs(int(ln(abs(`input`num''-int(`input`num'')))/ln(10)-1))  
                                
                                * the whole number: take the ceiling of log 10 of absolute value
                                local left=int(ln(abs(`input`num''))/ln(10)+1)
                        }
                }
                
                
                * assign the fixed decimal values into aadec
                if `whole'==1 {
                        local aadec=0
                }
                else if .>`left' & `left'>0 {
                        * reduce the left by one if more than zero to accept one extra digit
                        if `left'<=`dec' {
                                local aadec=`dec'-`left'+`one'
                        }
                        else {
                                local aadec=0
                        }
                }
                else {
                        local aadec=`times'+`dec'-1
                }
                
                if "`less'"=="" {
                        * needs to between 0 and 11
                        if `aadec'<0 {
                                local aadec=0
                        }
                        *if `aadec'<11 {
                        if `aadec'<7 {
                                * use fixed
                                local fmt "`aadec'f"
                        }
                        else {
                                * use exponential
                                local fmt "`=`dec'-1'e"
                        }
                }
                else {
                        * needs to between 0 and 11
                        local aadec=`aadec'-`less'
                        if `aadec'<0 {
                                local aadec=0
                        }
                        *if `aadec'<10 {
                        if `aadec'<7 {
                                * use fixed
                                local fmt "`aadec'f"
                        }
                        else {
                                * use exponential
                                local fmt "`=`dec'-1'e"
                        }
                }
                
                * make it exponential if too big
                if `input`num''>1000000 & `input`num''<. {
                        local fmt "`=`dec'-0'e"                
                }
                
                * make it exponential if too negative (small)
                if `input`num''<-1000000 & `input`num''<. {
                        local fmt "`=`dec'-0'e"                
                }
                
                local fmt`num' `fmt'
                local aadec`num' `aadec'
                
                local output`num'=string(`input`num'',"%12.`fmt'")
                
			if "`decmark'"~="" {
				local valstr : subinstr local aadec "." `"`decmark'"', all
			}
                return scalar deci`num'=`aadec'
                return local fmt`num'="`fmt'"
                return local input`num'="`input`num''"
                
                return local output`num'=`"`output`num''"'

        }
        else {
                * it is a missing value, empty, or non-number
                local output`num'=trim(`"`input`num''"')
                
                return scalar deci`num'=.
                return local fmt`num'="."
                if "`input`num''"=="" {
                        * return a dot when empty
                        return local input`num'="."
                }
                else {
                        return local input`num'="`input`num''"
                }
                
                return local output`num'=`"`output`num''"'

        }
}
end


********************************************************************************************


prog define _texout, sortpreserve
* based on out2tex version 0.9 4oct01 by john_gallup@alum.swarthmore.edu
* 2013 04 set version 8 and moved versionSet to bottom
	
	version 8
	
	* add one if only one v* column exists
	unab list: v*
	local count: word count `list'
	if `count'==1 {
		gen str v2=""
		order v*
	}
	if `count'==0 {
		exit
	}
	
	syntax varlist using/, titleWide(int) headBorder(int) bottomBorder(int)			/*
		*/	[texFile(str) TOtrows(int 0) Landscape Fragment NOPRetty PRetty	/*
		*/	Fontsize(numlist integer max=1 >=10 <=12) noBorder Cellborder		/*
		*/	Appendpage noPAgenum a4 a5 b5 LETter LEGal EXecutive replace		]
	if `totrows'==0 {
		local totrows = _N
	}
	local numcols : word count `varlist'
	gettoken varname statvars : varlist
	local fast 1
	
	if "`pretty'"=="pretty" {
		local pretty ""
	}
	else {
		local pretty "NOT PRETTY AT ALL"
	}
	
	local colhead1 = `titleWide' + 1
	local strow1 = `headBorder' + 1
	
	* insert $<$ to be handled in LaTeX conversion
	local N=_N
	forval num=`bottomBorder'/`N' {
		local temp=v1[`num']
		tokenize `"`temp'"', parse (" <")
		local count 1
		local newTex ""
		local noSpace 0
		while `"``count''"'~="" {
			if `"``count''"'=="<" {
				local `count' "$<$"
				local newTex `"`newTex'``count''"'
				local noSpace 1
			}
			else {
				if `noSpace'~=1 {
					local newTex `"`newTex' ``count''"'
				}
				else {
					local newTex `"`newTex'``count''"'					
					local noSpace 0
				}
			}
			local count=`count'+1
		}
		replace v1=`"`newTex'"' in `num'
	}
	
	*** replace if equation column present
	count if v1=="EQUATION"
	if `r(N)'~=0 {
		tempvar myvar
		* use v2 instead
		replace v1 = v2 in `=`bottomBorder'+1'/`totrows'
		replace v2 = "" in `=`bottomBorder'+1'/`totrows'
		
		* change the string length
		gen str5 `myvar' =""
		replace `myvar' =v2
		drop v2
		ren `myvar' v2
		order v1 v2
	}
	
	/* if file extension specified in `"`using'"', replace it with ".tex" for output
	local next_dot = index(`"`using'"', ".")
	if `next_dot' {
		local using = substr("`using'",1,`=`next_dot'-1')
	}
	*/
	
	if `"`texFile'"'=="" {
		local endName "tex"
	}
	else {
		local endName "`texFile'"
	}
	
	local using `"using "`using'.`endName'""'
	local fsize = ("`fontsize'" != "")
	if `fsize' {
		local fontsize "`fontsize'pt"
	}
	local lscp = ("`landscape'" != "") 
	if (`lscp' & `fsize') {
		local landscape ",landscape"
	}
	local pretty	= ("`pretty'" == "")
	local cborder = ("`cellborder'" != "")
	local noborder = ("`border'" != "")
	local nopagen = ("`pagenum'" != "")
	local nofrag	= ("`fragment'" == "")
	
	if `cborder' & `noborder' {
		di in red "may not specify both cellborder and noborder options"
		exit 198
	}
	
	local nopt : word count `a4' `a5' `b5' `letter' `legal' `executive'
	if `nopt' > 1 {
		di in red "choose only one of a4, a5, b5, letter, legal, executive"
		exit 198 
	}
	local pagesize "`a4'`a5'`b5'`letter'`legal'`executive'"
	if "`pagesize'"=="" | "`letter'"!="" {
		local pwidth  "8.5in"
		local pheight "11in"
	}
	else if "`legal'"!="" {
		local pwidth  "8.5in"
		local pheight "14in"
	}
	else if "`executive'"!="" {
		local pwidth  "7.25in"
		local pheight "10.5in"
	}
	else if "`a4'"!="" {
		local pwidth  "210mm"
		local pheight "297mm"
	}
	else if "`a5'"!="" {
		local pwidth  "148mm"
		local pheight "210mm"
	}
	else if "`b5'"!="" {
		local pwidth  "176mm"
		local pheight "250mm"
	}
	if `lscp' {
		local temp	 "`pwidth'"
		local pwidth  "`pheight'"
		local pheight "`temp'"
	}
	if "`pagesize'"!="" {
		local pagesize "`pagesize'paper"
		if (`lscp' | `fsize') {
			local pagesize ",`pagesize'"
		}
	}
	if `cborder' & `noborder' {
		di in red "may not specify both cellborder and noborder options"
		exit 198
	}
	
	quietly {
		tempvar has_eqn st2_row last_st pad0 pad1 pad2_n padN order
		
		* replace % with \%, and _ with \_ if <2 $'s (i.e. not an inline equation: $...$
		* has_eqn indicates that varname has 2+ $'s
		
		gen byte `has_eqn' = index(`varname',"$")
		
		* make sure there are 2+ "$" in varname
		replace `has_eqn' = index(substr(`varname',`has_eqn'+1,.),"$")>0 if `has_eqn'>0
		replace `varname'= subinstr(`varname',"_", "\_", .) if !`has_eqn'
		replace `varname'= subinstr(`varname',"%", "\%", .)
		replace `varname'= subinstr(`varname',"#", "\#", .)
		
		if `pretty' {
			replace `varname'= subinword(`varname',"R-squared", "\$R^2$", 1) in `strow1'/`bottomBorder'
			replace `varname'= subinstr(`varname'," t stat", " \em t \em stat", 1) in `bottomBorder'/`totrows'
			replace `varname'= subinstr(`varname'," z stat", " \em z \em stat", 1) in `bottomBorder'/`totrows'
		}
		
		foreach svar of local statvars { /* make replacements for column headings rows of statvars */
			replace `has_eqn' = index(`svar',"$") in `colhead1'/`headBorder'
			replace `has_eqn' = index(substr(`svar',`has_eqn'+1,.),"$")>0 in `colhead1'/`headBorder' if `has_eqn'>0
			replace `svar'= subinstr(`svar',"_", "\_", .) in `colhead1'/`headBorder' if !`has_eqn'
			replace `svar'= subinstr(`svar',"%", "\%", .) in `colhead1'/`headBorder'
			replace `svar'= subinstr(`svar',"#", "\#", .) in `colhead1'/`headBorder'
			
			/* replace <, >, {, }, | with $<$, $>$, \{, \}, and $|$ in stats rows */
			/* which can be used as brackets by outstat */
			replace `svar'= subinstr(`svar',"<", "$<$", .) in `strow1'/`bottomBorder'
			replace `svar'= subinstr(`svar',">", "$>$", .) in `strow1'/`bottomBorder'
			replace `svar'= subinstr(`svar',"{", "\{", .)  in `strow1'/`bottomBorder'
			replace `svar'= subinstr(`svar',"}", "\}", .)  in `strow1'/`bottomBorder'
			replace `svar'= subinstr(`svar',"|", "$|$", .) in `strow1'/`bottomBorder'
			
			replace `svar'= subinstr(`svar',"_", "\_", .)  in `strow1'/`bottomBorder'
			replace `svar'= subinstr(`svar',"%", "\$", .)  in `strow1'/`bottomBorder'
			replace `svar'= subinstr(`svar',"#", "\#", .) in `strow1'/`bottomBorder'
		}
		
		if `pretty' {  /* make title fonts large; notes & t stats small */
			local blarge "\begin{large}"
			local elarge "\end{large}"
			local bfnsize "\begin{footnotesize}"
			local efnsize "\end{footnotesize}"
		}
		if `cborder' {
			local vline "|"
		}
		gen str20 `pad0' = ""
		gen str20 `padN' = ""
		if `titleWide' {
			replace `pad0' = "\multicolumn{`numcols'}{`vline'c`vline'}{`blarge'" in 1 / `titleWide'
			replace `padN' = "`elarge'} \\\" in 1 / `titleWide'
		}
		if `bottomBorder' < `totrows' {
			local noterow1 = `bottomBorder' + 1
			replace `pad0' = "\multicolumn{`numcols'}{`vline'c`vline'}{`bfnsize'" in `noterow1' / l
			replace `padN' = "`efnsize'} \\\" in `noterow1' / l
		}
		
		gen str3 `pad1' = " & " in `colhead1' / `bottomBorder'
		if `numcols' > 2 {
			gen str3 `pad2_n' = `pad1'
		}
		if `pretty' { /* make stats 2-N small font */
			local strow1 = `headBorder' + 1
			gen byte `st2_row' = 0
			replace `st2_row' = (trim(`varname') == "") in `strow1' / `bottomBorder'	 /* only stats 2+ */
			gen byte `last_st' = (`st2_row' & `varname'[_n+1] != "")			 /* last stats row */
			if !`cborder' {
				replace `pad0'	= "\vspace{4pt}" if `last_st'
			}
				replace `pad1'	= `pad1' + "`bfnsize'" if `st2_row'
				if `numcols' > 2 {
					replace `pad2_n' = "`efnsize'" + `pad2_n' + "`bfnsize'" if `st2_row'
				}
				replace `padN'	= "`efnsize'" if `st2_row'
			}
		
			replace `padN' = `padN' + " \\\" in `colhead1' / `bottomBorder'
			if `cborder' {
				replace `padN' = `padN' + " \hline"
			}
			else {
			if !`noborder' {
				if `headBorder' {
					if `titleWide' {
						replace `padN' = `padN' + " \hline" in `titleWide'
					}
					replace `padN' = `padN' + " \hline" in `headBorder'
				}
				replace `padN' = `padN' + " \hline" in `bottomBorder'
			}
		}
		
		local vlist "`pad0' `varname' `pad1'"
		tokenize `statvars'
		local ncols_1 = `numcols' - 1
		local ncols_2 = `ncols_1' - 1
		forvalues v = 1/`ncols_2' {
			local vlist "`vlist' ``v'' `pad2_n'"
		}
		local vlist "`vlist' ``ncols_1'' `padN'"
		
		local texheadfootrows = `nofrag' + `pretty' + 1	/* in both headers and footers */ 
		local texheadrow = 2 * `nofrag' + `nopagen' + `texheadfootrows'
		local texfootrow = `texheadfootrows'
		local newtotrows = `totrows' + `texheadrow' + `texfootrow'
		if `newtotrows' > _N {
			local oldN = _N
			set obs `newtotrows'
		}
		else {
			local oldN = 0
		}
		gen long `order' = _n + `texheadrow' in 1 / `totrows'
		local newtexhrow1 = `totrows' + 1
		local newtexhrowN = `totrows' + `texheadrow'
		replace `order' = _n - `totrows' in `newtexhrow1' / `newtexhrowN'
		sort `order'
		
		
		* insert TeX header lines
		local ccc : display _dup(`ncols_1') "`vline'c"
		if `nofrag' {
			replace `pad0' = "\documentclass[`fontsize'`landscape'`pagesize']{article}" in 1
			replace `pad0' = "\setlength{\pdfpagewidth}{`pwidth'} \setlength{\pdfpageheight}{`pheight'}" in 2
			replace `pad0' = "\begin{document}" in 3
			replace `pad0' = "\end{document}" in `newtotrows'  
		}
		if `nopagen' {
			local row = `texheadrow' - 1 - `pretty'
			replace `pad0' = "\thispagestyle{empty}" in `row'
		}
		if `pretty' {
			local row = `texheadrow' - 1
			replace `pad0' = "\begin{center}" in `row'
			local row = `newtotrows' - `texfootrow' + 2
			replace `pad0' = "\end{center}"	in `row'
		}
		local row = `texheadrow'
		replace `pad0' = "\begin{tabular}{`vline'l`ccc'`vline'}" in `row'
		if (!`titleWide' | `cborder') & !`noborder' {
			replace `pad0' = `pad0' + " \hline" in `row'
		}
		local row = `newtotrows' - `texfootrow' + 1
		replace `pad0' = "\end{tabular}" in `row'
		
		outfile `vlist' `using' in 1/`newtotrows', `replace' runtogether
		
		* delete new rows created for TeX table, if any
		if `oldN' {
			keep in 1/`totrows'
		}
	} /* quietly */
	
	versionSet
	version `version'
	
end  /* end _texout */


********************************************************************************************


prog define out2rtf2, sortpreserve rclass

	versionSet
	version `version'

* based on version 0.9 4oct01 by john_gallup@alum.swarthmore.edu
	syntax varlist using/, titleWide(int) headBorder(int) bottomBorder(int)		/*
		*/	[wordFile(str) TOtrows(int 0) Landscape Fragment noPRetty	/*
		*/	Fontsize(numlist max=1 >0) noBorder Cellborder				/*
		*/	Appendpage PAgesize(str)							/*
		*/	Lmargin(numlist max=1 >=0.5) Rmargin(numlist max=1 >=0.5)		/*
		*/	Tmargin(numlist max=1 >=0.5) Bmargin(numlist max=1 >=0.5)		/*
		*/	replace]
		if `totrows'==0 {
			local totrows = _N
		}
	local numcols : word count `varlist'
	gettoken varname statvars : varlist
	local fast 1
	
	local colhead1 = `titleWide' + 1
	local strow1 = `headBorder' + 1
	
	
	*** replace if equation column present
	local hack 0
	count if v1=="EQUATION"
	if `r(N)'~=0 {
		* use v2 instead
		replace v1 = v2 in `=`bottomBorder'+1'/`totrows'
		replace v2 = "" in `=`bottomBorder'+1'/`totrows'
		
		* change the string length
		gen str5 myvar =""
		replace myvar =v2
		drop v2
		ren myvar v2
		order v1 v2
		
		local hack 1
	}
	
	/* if file extension specified in `using', replace it with ".rtf" for output
	local next_dot = index("`using'", ".")
	if `next_dot' {
		local using = substr("`using'",1,`=`next_dot'-1')
	}
	*/
	
	if `"`wordFile'"'=="" {
		local endName "rtf"
	}
	else {
		local endName "`wordFile'"
	}
	
	local using `"using "`using'.`endName'""'
	return local documentname `"`using'"'
	
	if "`fontsize'" == "" {
		local fontsize "12"
	}
	
	local lscp = ("`landscape'" != "") 
	local pretty	= ("`pretty'" == "")
	local cborder = ("`cellborder'" != "")
	local noborder = ("`border'" != "")
	local stdborder = (!`noborder' & !`cborder')
	local nopagen = ("`pagenum'" != "")
	local nofrag	= ("`fragment'" == "")
	
	
	if `cborder' & !`noborder' {
		di in red "may not specify both cellborder and noborder options"
		exit 198
	}
	
	* reformat "R-squared" and italicize "t" or "z"
	if `pretty' {
		quietly {
			replace `varname'= subinword(`varname',"R-squared", "{\i R{\super 2}}", 1) in `strow1'/`bottomBorder'
			replace `varname'= subinstr(`varname'," t stat", " {\i t} stat", 1) in `bottomBorder'/`totrows'
			replace `varname'= subinstr(`varname'," z stat", " {\i z} stat", 1) in `bottomBorder'/`totrows'
		}
	}
	
	* font sizes in points*2
	local font2 = int(`fontsize'*2)
	if `pretty' {
		/* make title fonts large; notes & t stats small */
		local fslarge = "\fs" + string(int(`font2' * 1.2))
		local fsmed	= "\fs" + string(`font2')
		local fssmall = "\fs" + string(int(`font2' * 0.8))
		local sa0 "\sa0"	/* put space after t stats rows */
		local gapsize = int(`fontsize'*0.4*20)  /* 40% of point size converted to twips */
		local sa_gap "\sa`gapsize'"
	}
	else {
		local fs0 = "\fs" + string(`font2')
	}
	
	local onecolhead = (`headBorder' - `titleWide' == 1)
			/* onecolhead = true if only one row of column headings */
	if `stdborder' {
		if !`onecolhead' {
			* runs here
			*local trbrdrt "\clbrdrt\brdrs"	/* table top is overlined */
			*local trbrdrt "\trbrdrt\brdrs"	/* table top is overlined */
			
			local clbrdr_uo "\clbrdrt\brdrs"	/* cells are overlined */
			local clbrdr_ul "\clbrdrb\brdrs"	/* cells are underlined */
		}
		else {
			/* cells are over- and underlined */
			local clbrdr_ul "\clbrdrt\brdrs\clbrdrb\brdrs"
		
		}
		local trbrdrb "\trbrdrb\brdrs"
	}
	if `cborder' {
		/* if !cborder then clbrdr is blank */
		local clbrdr "\clbrdrt\brdrs\clbrdrb\brdrs\clbrdrl\brdrs\clbrdrr\brdrs"
	}
	
	* figure out max str widths to make cell boundaries
	* cell width in twips = (max str width) * (pt size) * 12
	* (12 found by trial and error)
	local twipconst = int(`fontsize' * 12 )
	tempvar newvarname
	qui gen str80 `newvarname' = `varname' in `strow1'/`bottomBorder'
	
	local newvarlist "`newvarname' `statvars'"
	qui compress `newvarlist'
	local cellpos = 0
	foreach avar of local newvarlist {
		local strwidth : type `avar'
		local strwidth = subinstr("`strwidth'", "str", "", .)
		local strwidth = `strwidth' + 1  /* add buffer */
		local cellpos = `cellpos' + `strwidth'*`twipconst'

		* hacking
		if `hack'==1 & "`avar'"=="`newvarname'" & `cellpos'<1350 {
			local cellpos=1350 
		}
		local clwidths "`clwidths'`clbrdr'\cellx`cellpos'"
		
		* put in underline at bottom of header in clwidth_ul
		local clwidth_ul "`clwidth_ul'`clbrdr_ul'\cellx`cellpos'"
		
		* put in overline
		local clwidth_ol "`clwidth_ol'`clbrdr_uo'\cellx`cellpos'"
	}
	
	if `stdborder' {
		if `onecolhead' {
			local clwidth1 "`clwidth_ul'"
		}
		else {
			local clwidth1 "`clwidths'"
			local clwidth2 "`clwidth_ul'"
		}
		local clwidth3 "`clwidths'"
	}
	else{
		local clwidth1 "`clwidths'"
	}
	
	* statistics row formatting
	tempvar prettyfmt
	qui gen str12 `prettyfmt' = ""  /* empty unless `pretty' */
	if `pretty' {
		* make stats 2-N small font
		tempvar st2_row last_st
		quietly {
			gen byte `st2_row' = 0
			replace `st2_row' = (trim(`varname') == "") in `strow1' / `bottomBorder'	 /* only stats 2+ */
			gen byte `last_st' = (`st2_row' & `varname'[_n+1] != "")			 /* last stats row */
			replace `prettyfmt' = "`sa0'" in `strow1' / `bottomBorder'
			replace `prettyfmt' = "`sa_gap'"  if `last_st' in `strow1' / `bottomBorder'
			replace `prettyfmt' = `prettyfmt' + "`fsmed'" if !`st2_row' in `strow1' / `bottomBorder'
			replace `prettyfmt' = `prettyfmt' + "`fssmall'"  if `st2_row' in `strow1' / `bottomBorder'
		}
	}
	
	* create macros with file write contents
	
	forvalues row = `colhead1'/`bottomBorder' { 
		local svarfmt`row' `"(`prettyfmt'[`row']) "\ql " (`varname'[`row']) "\cell""'
		foreach avar of local statvars {
			local svarfmt`row' `"`svarfmt`row''"\qc " (`avar'[`row']) "\cell""' 
		}
		local svarfmt`row' `"`svarfmt`row''"\row" _n"'
	}
	
	* write file
	tempname rtfile
	cap file open `rtfile' `using', write `replace'
	if _rc==608 {
		noi di in red `"file `using' is read-only; cannot be modified or erased"'
		noi di in red `"The file needs to be closed if being used by another software such as Word."'
		exit 608
	}
	
	file write `rtfile' "{\rtf1`fs0'" _n  /* change if not roman: \deff0{\fonttbl{\f0\froman}} */
	
	* title
	if `titleWide' {
		file write `rtfile' "\pard\qc`fslarge'" _n
		forvalues row = 1/`titleWide' {
			file write `rtfile' (`varname'[`row']) "\par" _n
		}
	}
	
	* The top line
	file write `rtfile' "\trowd\trgaph75\trleft-75\intbl\trqc`fsmed'`trbrdrt'`clwidth_ol'" _n
	*file write `rtfile' "\trowd\trgaph75\trleft-75\intbl\trqc`fsmed'`trbrdrt'`clwidth1'" _n
	
	local headBorder_1 = `headBorder' - 1
	* write header rows 1 to N-1
	
	forvalues row = `colhead1'/`headBorder_1' {
		file write `rtfile' `svarfmt`row''
		* turn off the overlining the first time it's run
		file write `rtfile' "\trowd\trgaph75\trleft-75\trqc`clwidth3'" _n
	}
	file write `rtfile' "\trowd\trgaph75\trleft-75\trqc`clwidth2'" _n
	
	* write last header row
	file write `rtfile' `svarfmt`headBorder''

	local bottomBorder_1 = `bottomBorder' - 1
	/* turn off cell underlining */
	file write `rtfile' "\trowd\trgaph75\trleft-75\trqc`clwidth3'" _n
	
	* table contents
	forvalues row = `strow1'/`bottomBorder_1' {
		file write `rtfile' `svarfmt`row''
	}
	
	if `stdborder' {
		/* write last row */
		*file write `rtfile' "\trowd\trgaph75\trleft-75\trqc`trbrdrb'`clwidths'" _n
		* make it underline
		file write `rtfile' "\trowd\trgaph75\trleft-75\trqc`trbrdrb'`clwidth_ul'" _n
		file write `rtfile' `svarfmt`bottomBorder''
	}
	
	/* write notes rows */
	if `bottomBorder' < `totrows' {
		local noterow1 = `bottomBorder' + 1
		file write `rtfile' "\pard\qc`fssmall'" _n
		forvalues row = `noterow1'/`totrows' {
			file write `rtfile' (`varname'[`row']) "\par" _n
		}
	}
	
	* write closing curly bracket
	file write `rtfile' "}"
end  /* end out2rtf2 */



********************************************************************************************


prog define _xmlout
	versionSet
	version `version'

* 02 08 2011 title/notes no longer gets truncated in excel display with outreg2 option
*            wider first column
* 03 30 font Calibri
*       fontsize 10
*       colwidth

* emulates the output produced by xmlsave:
* xmlsave myfile, replace doctype(excel) legible

syntax using/ [, excelFile(str) LEGible noNAMes titleWide(integer 0) /*
	*/ headBorder(integer 10) bottomBorder(integer 10) outreg2 labeloption(str) insert excel1(str)]

if `"`excel1'"'~="" {
	* excel specific options
	_excel_parse, `excel1'
}


* the c_locals returned:
if "`excelfont'"=="" {
	local excelfont Calibri
}
if "`excelfontsize'"=="" {
	local excelfontsize 10
}
* leave excelcolwidth alone
if "`excelcellnumeric'"=="numeric" {
	local defaultcellstyle Number
}
else {
	local defaultcellstyle String
}


* assumes all columns are string; if numbers, then the format needs to be checked

*local legible legible

if "`legible'"=="legible" {
	local _n "_n"
}

tempname source saving

if `"`excelFile'"'=="" {
	local endName "xml"
}
else {
	local endName "`excelFile'"
}
	
local save `"`using'.`endName'"'

*file open `source' using `"`using'"', read
cap file open `saving' using `"`save'"', write text replace

if _rc==608 {
	noi di in red `"file `save' is read-only; cannot be modified or erased"'
	noi di in red `"The file needs to be closed if being used by another software such as Excel."'
	exit 608
}

*file write `saving' `"`macval(line)'"'
file write `saving' `"<?xml version="1.0" encoding="US-ASCII" standalone="yes"?>"' `_n'
file write `saving' `"<?mso-application progid="Excel.Sheet"?>"' `_n'
file write `saving' `"<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet""' `_n'
file write `saving' `" xmlns:o="urn:schemas-microsoft-com:office:office""' `_n'
file write `saving' `" xmlns:x="urn:schemas-microsoft-com:office:excel""' `_n'
file write `saving' `" xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet""' `_n'
file write `saving' `" xmlns:html="http://www.w3.org/TR/REC-html40">"' `_n'
file write `saving' `"<DocumentProperties xmlns="urn:schemas-microsoft-com:office:office">"' `_n'
file write `saving' `"<Author></Author>"' `_n'
file write `saving' `"<LastAuthor></LastAuthor>"' `_n'
file write `saving' `"<Created></Created>"' `_n'
file write `saving' `"<LastSaved></LastSaved>"' `_n'
file write `saving' `"<Company></Company>"' `_n'
file write `saving' `"<Version></Version>"' `_n'
file write `saving' `"</DocumentProperties>"' `_n'
file write `saving' `"<ExcelWorkbook  xmlns="urn:schemas-microsoft-com:office:excel">"' `_n'
file write `saving' `"<ProtectStructure>False</ProtectStructure>"' `_n'
file write `saving' `"<ProtectWindows>False</ProtectWindows>"' `_n'
file write `saving' `"</ExcelWorkbook>"' `_n'
file write `saving' `"<Styles>"' `_n'

* styles
file write `saving' `"<Style ss:ID="Default" ss:Name="Normal">"' `_n'
file write `saving' `"<Alignment ss:Vertical="Bottom"/>"' `_n'
file write `saving' `"<Borders/>"' `_n'
file write `saving' `"<Font ss:FontName="`excelfont'" ss:Size="`excelfontsize'"/>"' `_n'
file write `saving' `"<Interior/>"' `_n'
file write `saving' `"<NumberFormat/>"' `_n'
file write `saving' `"<Protection/>"' `_n'
file write `saving' `"</Style>"' `_n'

* bold & (center)
local temp=`excelfontsize'+2 /* extra size for title */
file write `saving' `"<Style ss:ID="s1">"' `_n'
*file write `saving' `"<Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>"' `_n'
file write `saving' `"<Font ss:FontName="`excelfont'" ss:Bold="1" ss:Size="`temp'"/>"' `_n'
file write `saving' `"<NumberFormat/>"' `_n'
file write `saving' `"</Style>"' `_n'

* top border & center
file write `saving' `"<Style ss:ID="s21">"' `_n'
file write `saving' `"<Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>"' `_n'
file write `saving' `"<NumberFormat/>"' `_n'
file write `saving' `"<Font ss:FontName="`excelfont'" ss:Size="`excelfontsize'"/>"' `_n'
file write `saving' `"<Borders>"' `_n'
file write `saving' `"<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>"' `_n'
file write `saving' `"</Borders>"' `_n'
file write `saving' `"</Style>"' `_n'

* http://www.devguru.com/technologies/html/quickref/color_chart.html
* http://www.w3schools.com/HTML/html_colornames.asp
* http://msdn.microsoft.com/en-us/library/aa140066(v=office.10).aspx

* main body (no border) & center
file write `saving' `"<Style ss:ID="s22">"' `_n'
file write `saving' `"<Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>"' `_n'
file write `saving' `"<Font ss:FontName="`excelfont'" ss:Size="`excelfontsize'"/>"' `_n'
*file write `saving' `"<Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#9C6500"/>"' `_n'
*file write `saving' `"<Interior ss:Color="#C6EFCE" ss:Pattern="Solid"/>"' `_n'
*file write `saving' `"<Interior ss:Color="#FFFFFF" ss:Pattern="None"/>"' `_n'
file write `saving' `"<NumberFormat/>"' `_n'
file write `saving' `"</Style>"' `_n'

* bottom border & center
file write `saving' `"<Style ss:ID="s23">"' `_n'
file write `saving' `"<Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>"' `_n'
file write `saving' `"<NumberFormat/>"' `_n'
file write `saving' `"<Font ss:FontName="`excelfont'" ss:Size="`excelfontsize'"/>"' `_n'
file write `saving' `"<Borders>"' `_n'
file write `saving' `"<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>"' `_n'
file write `saving' `"</Borders>"' `_n'
file write `saving' `"</Style>"' `_n'

* goldfish (no border, left-justified)
file write `saving' `"<Style ss:ID="s24">"' `_n'
file write `saving' `"<Font ss:FontName="`excelfont'" ss:Size="`excelfontsize'"/>"' `_n'
file write `saving' `"<NumberFormat/>"' `_n'
file write `saving' `"</Style>"' `_n'

* top border
file write `saving' `"<Style ss:ID="s31">"' `_n'
file write `saving' `"<Font ss:FontName="`excelfont'" ss:Size="`excelfontsize'"/>"' `_n'
file write `saving' `"<Borders>"' `_n'
file write `saving' `"<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>"' `_n'
file write `saving' `"</Borders>"' `_n'
file write `saving' `"</Style>"' `_n'

* main body (no border)
file write `saving' `"<Style ss:ID="s32">"' `_n'
file write `saving' `"<Font ss:FontName="`excelfont'" ss:Size="`excelfontsize'"/>"' `_n'
file write `saving' `"<Borders/>"' `_n'
file write `saving' `"</Style>"' `_n'

* bottom border & center
file write `saving' `"<Style ss:ID="s33">"' `_n'
file write `saving' `"<Font ss:FontName="`excelfont'" ss:Size="`excelfontsize'"/>"' `_n'
file write `saving' `"<Borders>"' `_n'
file write `saving' `"<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>"' `_n'
file write `saving' `"</Borders>"' `_n'
file write `saving' `"</Style>"' `_n'

file write `saving' `"</Styles>"' `_n'
file write `saving' `"<Names>"' `_n'
file write `saving' `"</Names>"' `_n'
file write `saving' `"<Worksheet ss:Name="Sheet1">"' `_n'

* set up file size
qui describe, short

local N=_N
local tableN `N'

if "`names'"~="nonames" {
	* add one if variable names are to be inserted
	local tableN=`N'+1
}
else {
	* add one for the look
	local tableN=`N'+1
}

file write `saving' `"<Table ss:ExpandedColumnCount="`r(k)'" ss:ExpandedRowCount="`tableN'""' `_n'
file write `saving' `" x:FullColumns="1" x:FullRows="1">"' `_n'

*** column length (assume at least 2 columns)
local temp1 58
local temp2 58

if `"`outreg2'"'=="outreg2" & `version'>=10 {
	local column1 v1
	local column2 v2
	if `version'>=11 {
		qui ds_util
		local column1: word 1 of `r(varlist)'
		local column2: word 2 of `r(varlist)'
	}
	
	* note getting the correct size by excluding the notes and titles
	tempvar getsize
	gen `getsize'= `column1' in `headBorder'/`bottomBorder'
	
	*local tempformat1: format `column1'
	local tempformat1: format `getsize'
	cap drop `getsize'
	
	local tempsize=trim(substr("`tempformat1'",2,length(`"`tempformat1'"')-2))
	if `tempsize'>10 {
		local temp1=int(`tempsize'*6)
	}
	else {
		local temp1 100
	}
	
	* usually not necessary since variable names are not this long
	if `tempsize'>40 {
		local temp1=`temp1'-int(`tempsize'*.2)
	}
	if `tempsize'>60 {
		local temp1 220
	}
	
	if "`insert'"~="" {
		local tempformat2: format `column2'
		local tempsize=trim(substr("`tempformat2'",2,length(`"`tempformat2'"')-2))
		if `tempsize'>10 {
			local temp2=int(`tempsize'*3.6)
		}
		else {
			local temp2 58
		}
		if `tempsize'>40 {
			local temp2=`temp2'-int(`tempsize'*.2)
		}
		if `tempsize'>60 {
			local temp2 220
		}
	}
	else {
		local temp2 58
	}
}

dsCol


if "`excelcolwidth'"=="" {
	forval num=1/`ck' {
		local temp : word `num' of `temp1' `temp2' 58
		if "`temp'"~="" {
			file write `saving' `"<Column ss:AutoFitWidth="0" ss:Width="`temp'"/>"' `_n'
			local lasttemp `temp'
		}
		else {
			file write `saving' `"<Column ss:AutoFitWidth="0" ss:Width="`lasttemp'"/>"' `_n'
		}
	}
}
else {
	* user specified values
	forval num=1/`ck' {
		local temp : word `num' of `excelcolwidth'
		if "`temp'"~="" {
			file write `saving' `"<Column ss:AutoFitWidth="0" ss:Width="`temp'"/>"' `_n'
			local lasttemp `temp'
		}
		else {
			file write `saving' `"<Column ss:AutoFitWidth="0" ss:Width="`lasttemp'"/>"' `_n'
		}
	}
}


* should be tostring and format here if dealing with numbers
	
	ds8
	
	* write the variable names at the top or empty row
	if "`names'"~="nonames" {
		file write `saving' `"<Row>"' `_n'
		foreach var in  `dsVarlist' {
			if "`Version7'"~="" {
				file write `saving' `"<Cell ss:StyleID="s1"><Data ss:Type="String">`macval(var)'</Data></Cell>"' _n
			}
			else {
				local celltype String
				capture confirm number `macval(var)'
		        if _rc==0 {
					local celltype `defaultcellstyle'
				}
				file write `saving' `"<Cell`STYLE'><Data ss:Type="`celltype'">`macval(var)'</Data></Cell>"' `_n'
			}
		}
		file write `saving' `"</Row>"' `_n'
	}
	else {
		file write `saving' `"<Row>"' `_n'
		file write `saving' `"</Row>"' `_n'
	}


* title
local count `titleWide'
local total 1
while `count'~=0 {
	*xmlstack, saving(`saving') dsVarlist(`dsVarlist') num(`total') n(`N') style(`" ss:StyleID="s1""') style1(`" ss:StyleID="s1""')
	xmlstack, saving(`saving') dsVarlist(v1) num(`total') n(`N') style(`" ss:StyleID="s1""') style1(`" ss:StyleID="s1""') defaultcellstyle(`defaultcellstyle')
	local count=`count'-1
	local total=`total'+1
}

* top border
local count=`total'
forval num=`count'/`count' {
	xmlstack, saving(`saving') dsVarlist(`dsVarlist') num(`num') n(`N') style(`" ss:StyleID="s21""') style1(`" ss:StyleID="s31""') defaultcellstyle(`defaultcellstyle')
	local total=`total'+1
}

* ctitle
local count=`total'
forval num=`count'/`headBorder' {
	xmlstack, saving(`saving') dsVarlist(`dsVarlist') num(`num') n(`N') style(`" ss:StyleID="s22""') style1(`" ss:StyleID="s32""') defaultcellstyle(`defaultcellstyle')
	local total=`total'+1
}

* top border (closes ctitle)
local count=`total'
forval num=`count'/`count' {
	xmlstack, saving(`saving') dsVarlist(`dsVarlist') num(`num') n(`N') style(`" ss:StyleID="s21""') style1(`" ss:StyleID="s31""') defaultcellstyle(`defaultcellstyle')
	local total=`total'+1
}

* body
local count=`total'
forval num=`count'/`=`bottomBorder'-1' {
	xmlstack, saving(`saving') dsVarlist(`dsVarlist') num(`num') n(`N') style(`" ss:StyleID="s22""') style1(`" ss:StyleID="s32""') defaultcellstyle(`defaultcellstyle')
	local total=`total'+1
}

* bottom border (closes body)
local count=`total'
forval num=`count'/`count' {
	xmlstack, saving(`saving') dsVarlist(`dsVarlist') num(`num') n(`N') style(`" ss:StyleID="s23""') style1(`" ss:StyleID="s33""') defaultcellstyle(`defaultcellstyle')
	local total=`total'+1
}

* goldfish
if `N'>`total' {
	local count=`total'
	forval num=`count'/`N' {
		*xmlstack, saving(`saving') dsVarlist(`dsVarlist') num(`num') n(`N') style(`" ss:StyleID="s24""') style1(`" ss:StyleID="s24""') 
		xmlstack, saving(`saving') dsVarlist(v1) num(`num') n(`N') style(`" ss:StyleID="s24""') style1(`" ss:StyleID="s24""') defaultcellstyle(`defaultcellstyle')
		local total=`total'+1
	}
}

/*
forval num=1/`N' {
	
	file write `saving' `"<Row>"' `_n'
	
	*foreach var in  `=r(varlist)' {
	foreach var in  `dsVarlist' {
		
		*local stuff `=`var'[`num']'
		local stuff=`var' in `num'
		
		local stuff : subinstr local stuff "<" "&lt;", all
		local stuff : subinstr local stuff ">" "&gt;", all
		
		* the main body
		if "`Version7'"~="" {
			file write `saving' `"<Cell`style'><Data ss:Type="String">`macval(stuff)'</Data></Cell>"' `_n'
		}
		else {
			local celltype String
			*local tempstuff: subinstr local stuff "," ""
			capture confirm number `stuff'
		    if _rc==0 {
				local celltype `defaultcellstyle'
			}
			file write `saving' `"<Cell`STYLE'><Data ss:Type="`celltype'">`stuff'</Data></Cell>"' `_n'
		}
	}
	file write `saving' `"</Row>"' `_n'
}
*/

file write `saving' `"</Table>"' `_n'
file write `saving' `"<WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">"' `_n'
file write `saving' `"<ProtectedObjects>False</ProtectedObjects>"' `_n'
file write `saving' `"<ProtectedScenarios>False</ProtectedScenarios>"' `_n'
file write `saving' `"</WorksheetOptions>"' `_n'
file write `saving' `"</Worksheet>"' `_n'
file write `saving' `"</Workbook>"' `_n'

* close out with the last line
*file write `saving' _n
*file close `source'

file close `saving'

end /* _xmlout */


********************************************************************************************


prog define xmlstack

syntax, saving(str) dsVarlist(str) num(numlist) n(numlist) style(str) style1(str) defaultcellstyle(str)

local N `n'

*forval num=1/`N' {
	
	file write `saving' `"<Row>"' `_n'
	
	local count 0
	
	*foreach var in  `=r(varlist)' {
	foreach var in  `dsVarlist' {
		
		if `count'==0 {
			local STYLE `"`style1'"'
		}
		else {
			local STYLE `"`style'"'
		}
		
		*local stuff `=`var'[`num']'
		local stuff=`var' in `num'
		
		local stuff : subinstr local stuff "<" "&lt;", all
		local stuff : subinstr local stuff ">" "&gt;", all
		
		* the main body
		if "`Version7'"~="" {
			file write `saving' `"<Cell`STYLE'><Data ss:Type="String">`macval(stuff)'</Data></Cell>"' `_n'
		}
		else {
			local celltype String
			*local tempstuff: subinstr local stuff "," ""
			capture confirm number `stuff'
	        if _rc==0 {
				local celltype `defaultcellstyle'
			}
			file write `saving' `"<Cell`STYLE'><Data ss:Type="`celltype'">`stuff'</Data></Cell>"' `_n'
		}
		
		local count=`count'+1
	}
	file write `saving' `"</Row>"' `_n'
*}

end /* xmlstack */


********************************************************************************************


prog define dsCol
	* gets you the number of columns like cret does for version 8
	* alternatively use -describe, short- and r(k)
	
	version 7.0
	cap local ck `c(k)'
	
	if "`ck'"=="" {
		local ck 0
		foreach var of varlist _all {
			local ck=`ck'+1
		}
	}
	c_local ck `ck'
end


********************************************************************************************


prog define ds8
	* get you the list of variable like -ds- does for version 8
	version 7.0
	qui ds
	if "`r(varlist)'"=="" {
		local dsVarlist ""
		foreach var of varlist _all {
			local dsVarlist "`dsVarlist' `var'"
		}
		c_local dsVarlist `dsVarlist'
	}
	else {
		c_local dsVarlist `r(varlist)'
	}
end


********************************************************************************************


prog define _tab3, eclass
	* get you tabulations
	versionSet
	version `version'
	
syntax varlist 							/*
	*/ [if] [in] [using] [,					/*
	*/ APpend REPLACE esample drop(str) 		/*
	*/ DISplay log regress]
	
	
qui {

if "`drop'"~="" {
	ds `drop'
	local drop `r(varlist)'
	*cap local varlist: list varlist - drop
	macroMinus `varlist', names(varlist) subtract(`drop')
}

* checking the height
local varCount: word count `varlist'
if `=`varCount'*100'>=`=_N' {
	preserve
	set obs `=`varCount'*100+2'
}



if `=_by()'==1 {
	* eliminate -by- variables from varlist
	local drop `_byvars'
	*cap local varlist: list varlist - drop
	macroMinus `varlist', names(varlist) subtract(`drop')
}

*marksample touse
*marksample alluse, noby

tempvar touse alluse

mark `touse' `if' `in' [`weight'`exp']
mark `alluse'  `if' `in' [`weight'`exp'], noby

** restricting to e(sample)
if "`noesample'"=="noesample" {
	replace `touse'=0 if e(sample)~=1
	replace `alluse'=0 if e(sample)~=1
}

tempvar stacker name label frequency percent cumulative total
tempname val_mat freq_mat ebmat eVmat 
	
gen `stacker'=.
gen str5 `name'=""
gen `label'=.
gen `frequency'=.
gen `percent'=.
gen `cumulative'=.
gen `total'=.

local varname ""

noi tabulate `varlist' [`weight'`exp'] if `touse', matrow(`val_mat') matcell(`freq_mat')

if r(N)~=0 {
	noi tabulate `varlist' [`weight'`exp'] if `touse', matrow(`val_mat') matcell(`freq_mat')
	
	local stuff `r(r)'
	forval row=1/`stuff' {
		*replace `name' = "r`row'" in `row'
		
		local content = `val_mat'[`row',1]
		replace `label' =`content' in `row'
		
		replace `name' = string(`val_mat'[`row',1]) in `row'
		local varname "`varname' `content'"
		
		local content = `freq_mat'[`row',1]
		replace `frequency' =`content' in `row'
	}
	replace `total'=sum(`frequency')
	qui summarize `varlist', meanonly
				if _rc==101 {
				noi di in red "pweight not allowed"
				exit 101
			}
	replace `percent'=100*`frequency'/`r(N)'
	replace `cumulative'=sum(`percent') if `label'~=.
}

*mat list `val_mat'
*mat list `freq_mat'
	
	local colVarname ""
	foreach col in obs mean sd min max {
		foreach var in `varname' {
			local colVarname "`colVarname' `col':`var'"
		}
	}
	
	count if `name'~=""
	
	replace `stacker'=`label'
	forval num=1/`=r(N)' {
		replace `stacker'=`frequency'[`num'] in `=r(N)+`num''
		replace `stacker'=`percent'[`num'] in `=r(N)*2+`num''
		replace `stacker'=`cumulative'[`num'] in `=r(N)*3+`num''
	}
	
	if "`display'"=="display" {
	noi tabulate `varlist' [`weight'`exp'] if `touse'
}
if `=_by()'==1 {
	* generate column heading when -by- specified
	local cc=1
	local ctitleList ""
	
	tokenize `_byvars'
	while "``cc''"~="" {
		
		* should there be `touse' here?
		qui summarize ``cc'' if `_byindex' == `=_byindex()' & `touse'
		if _rc==101 {
			noi di in red "pweight not allowed"
			exit 101
		}
		if r(N)<. {
			local actual`cc' =r(mean)
		}
		else {
			local actual`cc' =.			
		}
		
		* place ctitle in there
		local ctitleList "`ctitleList' ``cc'' `actual`cc'' "
		local cc=`cc'+1
	}
	
	* replace last if -by- specified
	if `=_byindex()'~=1 & "`replace'"=="replace" {
		local replace ""
	}
}

count if `stacker'~=.

if r(N)>0 {
	* recycling name: they exist in variables and matrix
	
	if "`log'"=="log" {
		

		
		mkmat `stacker' in 1/`=r(N)', matrix(`ebmat')
		mkmat `empty' in 1/`=r(N)', matrix(`eVmat')
		
		mat rownames `ebmat'=`colVarname'
		mat rownames `eVmat'=`colVarname'
		
		mat colnames `ebmat'=y1
		mat colnames `eVmat'=y1
		
		mat `ebmat'=`ebmat''
		mat `eVmat'=(`eVmat'*`eVmat'')
	}
	else {
		count if `name'~=""
		
		* `=r(N)' gets wiped out in version 7
		local rN=r(N)
		
		mkmat `frequency' in 1/`rN', matrix(`ebmat')
		mkmat `percent' in 1/`rN', matrix(`eVmat')
		
		mat rownames `ebmat'=`varname'
		mat rownames `eVmat'=`varname'
		
		mat colnames `ebmat'=y1
		mat colnames `eVmat'=y1
		
		mat `ebmat'=`ebmat''
		mat `eVmat'=(`eVmat'*`eVmat'')
	}
	
	if "`replace'"=="replace" {
		if "`Version7'"=="" {
			est mat freq `ebmat'
			est mat percent `eVmat'
			
			count if `touse'==1
			est scalar total = `total'[_N]
		}
		else {
			eret clear
			*eret mat b=`ebmat'
			*eret mat V=`eVmat'
			
			eret post b V
			if `"`if'"'~="" {
				eret local depvar `"`if'"'
			}
			else {
				eret local depvar `"Tabulate"'
			}
			eret local cmd "tab3"
			
			count if `touse'==1
			eret scalar total = `total'[_N]
		}
	}
	else {
		if "`Version7'"=="" {
			est mat freq `ebmat'
			est mat percent `eVmat'
			
			count if `touse'==1
			est scalar total = `total'[_N]
		}
		else {
			eret mat freq=`ebmat'
			eret mat percent=`eVmat'
			
			count if `touse'==1
			eret scalar total = `total'[_N]
		}
	}
}
else {
	* no observation
	if "`Version7'"=="" {
		mat def `ebmat'=(0)
		mat def `eVmat'=(0)
		mat colnames `ebmat'="MISSING"
		mat colnames `eVmat'="MISSING"
		est mat freq `ebmat'
		est mat percent `eVmat'
		est scalar total=0
	}
	else {
		mat def `ebmat'=(0)
		mat def `eVmat'=(0)
		mat colnames `ebmat'="MISSING"
		mat colnames `eVmat'="MISSING"
		eret mat freq=`ebmat'
		eret mat percent=`eVmat'
		eret scalar total=0
	}
}
} /* qui */
noi di

end /* _tab3 */


********************************************************************************************


* Jan2009 by roywada@hotmail.com
* 24mar2010 content( ) is no longer required

prog define optionSyntax
	* cleans the options within parenthetical options of the form -option( )-
	* clean c_locals of those content names as if they were the options
	
	* valid: allowed contents in parenthesis
	* name: name of the option
	* content: actual user input into the option
	* passthru: if it was passtru rather than string
	* nameShow: mesaage to user when invalid
	
	syntax, valid(str) name(str) nameShow(str) [content(str) PASSthru NORETURN]
	
	if "`content'"=="" {
		local content
	}
	
	* take comma out
	if "`passthru'"=="passthru" {
		local content : subinstr local content "`name'(" " ", all
		local content : subinstr local content ")" " ", all
		local content : subinstr local content "," " ", all
	}
	else {
		* just string
		local content : subinstr local content "," " ", all
	}
	
	local thisMany : word count `content'
	local num=1
	local optionList ""
	
	while `num'<=`thisMany' {
		local option`num' : word `num' of `content'
		
		* it must be one of the list
		local test 0
		foreach var in `valid' {
			if "`var'"=="`option`num''" & `test'==0 {
				local test 1
			}
		}
		
		if `test'==0 {
			noi di in white "`option`num''" in red " is not a valid option or matrix for {opt `nameShow'}"
			exit 198
		}
		local optionList "`optionList' `option`num''"
		local num=`num'+1
	}
	
	if "`noreturn'"~="noreturn" {
		foreach var in `valid' {
			* clears the c_locals
			c_local `var' ""
		}
		
		foreach var in `optionList' {
			* inserts the c_locals
			c_local `var' "`var'"
		}
	}
	
	c_local optionList `"`optionList'"'
	c_local optionCount : word count `optionList'

end


********************************************************************************************


* sum2 1.0.0 Jan2009 by roywada@hotmail.com
* sum2 1.0.1 21oct2009 : gets the entire varlist if no e(b) exists
*				raw option
* sum2 1.0.2 28apr2014 : factor variables
* sum2 1.0.3 20may2014 : summarize baselevels

prog define _sum2, eclass
*prog define sum2, eclass by(recall) sortpreserve
	versionSet
	version `version'

if `a_version'>=11 {
	local fv fv
}

syntax [varlist(ts `fv')] [using] [if] [in] [pweight fweight aweight iweight] [,	/*
	*/ APpend REPLACE esample drop(str) 				/*
	*/ noDISplay log REGress DETail NODEPendent raw]

fvtsunab `varlist'
local varlist `fvtsunab_list'

local varlist `varlist'
local _0 `"`0'"'


qui {

if "`log'"=="log" & "`detail'"=="detail" {
	noi di in red "cannot choose both {opt det:ail} and {opt log}"
	exit 198
}

if "`log'"~="log" & "`detail'"~="detail" {
	local regress "regress"
}


/* not needed for _sum2, which exists within outreg2

if "`regress'"=="regress" {
	* check for prior sum2, replace
	foreach var in eqlist {
		if "`e(cmd)'"=="sum2, log" {
			if "`Version7"~="" {
				*eret list
			}
			else {
				*est list
			}
			noi di in red "no regression detected; already replaced with summary"
			exit 198
		}
	}
	
	*** replace varlist with e(b) names
	regList `_0'
	
	local varlist `r(varlist)'
	local eqlist `r(eqlist)'
	
	local varnum `r(varnum)'
	local eqcount `r(eqcount)'
}
else {
	local varnum: word count `varlist'
	local eqcount 0

}

local varlist `"`eqlist' `varlist'"'
*/

	
* take tempvars out
tsunab stuff : __00*

macroMinus `varlist', names(varlist) subtract(`stuff')
local varnum: word count `varlist'

* extender
local N=_N
version 7: describe, short
if `r(k)'>`N'+1 & `r(k)'<. {
	set obs `r(k)'
}


if "`drop'"~="" {
	ds `drop'
	local drop `r(varlist)'
	*cap local varlist: list varlist - drop
	macroMinus `varlist', names(varlist) subtract(`drop')
}



if `=_by()'==1 {
	* eliminate -by- variables from varlist
	local drop `_byvars'
	*cap local varlist: list varlist - drop
	macroMinus `varlist', names(varlist) subtract(`drop')
}


*marksample touse
*marksample alluse, noby
*tempvar touse alluse

tempvar touse
*mark `alluse'  `if' `in', noby

cap confirm matrix e(b)
if _rc | "`raw'"=="raw" {
	mark `touse' `if' `in' [`weight'`exp']
}
else {
	* always esample restricted
	if `"`if'"'~="" {
		mark `touse' `if' & e(sample) `in' [`weight'`exp']
	}
	else {
		mark `touse' if e(sample) `in' [`weight'`exp']
	}
}

count if `touse'==1
if `r(N)'==0 {
	noi di in red "no observation left; check your if/in conditionals"
	exit 198
}

*** must take out string variables prior to marking them
local stringList ""
local noobsList ""
local anyObs 0

foreach var in `varlist' {
	local var0 `var'
	if `a_version'>=11 {
		fvts_label `var'
		if `"`basesuffix'"'=="b" {
			local var `basevalue'.`baseonly'
		}
	}
	noi summarize `var' if `touse' [`weight'`exp'], meanonly
	
	if _rc==101 {
		noi di in red "pweight not allowed"
		exit 101
	}
	if r(N)==0 {
		local minus "`var'"
		*cap local varlist: list varlist - minus
		macroMinus `varlist', names(varlist) subtract(`minus')
		
		if "`Version7'"=="" {
			local varlist=subinstr("`varlist'","`minus'","",.)
		}
		
		local type: type `var'
		local check= substr("`type'",1,3)
		
		* display later
		if "`check'"=="str" {
			*noi di in yellow "`var' is string, not included"
			local stringList "`stringList' `var'"
		}
		else {
			*noi di in yellow "`var' has no observation, not included"
			local noobsList "`noobsList' `var'"
		}
	}
	else {
		local anyObs 1
	}
	local varnum: word count `varlist'
}

tempvar name N mean sd min max zeros
tempname ebmat eVmat 
tempvar sum_w Var skewness kurtosis sum p1 p5 p10 p25 p50 p75 p90 p95 p99

local varname ""



foreach var in `varlist' {
	local var0 `var'
	if `a_version'>=11 {
		fvts_label `var'
		if `"`basesuffix'"'=="b" {
			local var `basevalue'.`baseonly'
		}
	}
	qui summarize `var' if `touse' [`weight'`exp'], `detail'
			if _rc==101 {
				noi di in red "pweight not allowed"
				exit 101
			}
	if r(N)~=0 {
		* put in the non-cleaned original name in var0
		local varname "`varname' `var0'"
		local row=`row'+1
		
		foreach var in mean sd N min max {
			mat ``var'' = nullmat(``var'') \ r(`var')
		}
		mat `zeros' = nullmat(`zeros') \ 0
	}
	if "`detail'"=="detail" & r(N)~=0 {
		foreach var in sum_w Var skewness kurtosis sum p1 p5 p10 p25 p50 p75 p90 p95 p99 {
			mat ``var'' = nullmat(``var'') \ r(`var')
		}
	}
}

* rename them
if "`regress'"=="regress" {
	foreach var in mean sd N min max {
	mat rownames ``var''=`varname'
	mat colnames ``var''=`var'
	}
}
if "`log'"=="log" {
	foreach var in N mean sd min max {
		mat rownames ``var''=`varname'
		mat roweq ``var''=`var'
		mat colnames ``var''=`var'
	}
}
if "`detail'"=="detail" {
	foreach var in N mean sd min max sum_w Var skewness kurtosis sum p1 p5 p10 p25 p50 p75 p90 p95 p99 {
		mat rownames ``var''=`varname'
		mat roweq ``var''=`var'
		mat colnames ``var''=`var'
	}
}

if "`display'"~="nodisplay" & `anyObs'==1 {
	noi summarize `varlist' if `touse' [`weight'`exp'], `detail'
}

if `=_by()'==1 {
	* generate column heading when -by- specified
	local cc=1
	local ctitleList ""
	
	tokenize `_byvars'
	while "``cc''"~="" {
		
		* should there be `touse' here?
		qui summarize ``cc'' if `_byindex' == `=_byindex()' & `touse'
		if r(N)<. {
			local actual`cc' =r(mean)
		}
		else {
			local actual`cc' =.			
		}
		
		* place ctitle in there
		local ctitleList "`ctitleList' ``cc'' `actual`cc'' "
		local cc=`cc'+1
	}
	
	* replace last if -by- specified
	if `=_byindex()'~=1 & "`replace'"=="replace" {
		local replace ""
	}
}
	
	* exporting temp matrices	
	if "`regress'"=="regress" {
		mat `ebmat' = `mean'
		mat `eVmat' = `sd'
		
		mat `ebmat'=`ebmat''
		mat `eVmat'=(`eVmat'*`eVmat'')
	}
	else if "`log'"=="log" {
		foreach var in N mean sd min max {
			mat `ebmat' = nullmat(`ebmat') \ ``var'' 
			mat `eVmat' = nullmat(`eVmat') \ `zeros'
		}
		
		* rename eVmat after ebmat
		local colnames: colnames `ebmat'
		local roweq: roweq `ebmat'
		local rownames: rownames `ebmat'
		
		mat colnames `eVmat'=`colnames'		
		mat roweq `eVmat'=`roweq'
		mat rownames `eVmat'=`rownames'
		
		mat `ebmat'=`ebmat''
		mat `eVmat'=(`eVmat'*`eVmat'')
	}
	else if "`detail'"=="detail" {
		foreach var in N mean sd min max sum_w Var skewness kurtosis sum p1 p5 p10 p25 p50 p75 p90 p95 p99 {
			mat `ebmat' = nullmat(`ebmat') \ ``var''
			mat `eVmat' = nullmat(`eVmat') \ `zeros'
		}
		
		* rename eVmat after ebmat
		local colnames: colnames `ebmat'
		local roweq: roweq `ebmat'
		local rownames: rownames `ebmat'
		
		mat colnames `eVmat'=`colnames'		
		mat roweq `eVmat'=`roweq'
		mat rownames `eVmat'=`rownames'
		
		mat `ebmat'=`ebmat''
		mat `eVmat'=(`eVmat'*`eVmat'')
	}
	
	if "`replace'"=="replace" {
		if "`Version7'"=="" {
			est mat mean `ebmat'
			est mat Var `eVmat'
			
			count if `touse'==1
			est scalar N = r(N)
		}
		else {
			eret clear
			mat b=`ebmat'
			mat V=`eVmat'
			mat list b
			eret post b V
			if `"`if'"'~="" {
				gettoken first second: if, parse(" ")
				eret local depvar `"`second'"'
			}
			else {
				eret local depvar `"Summary"'
			}
			eret local cmd "sum2, log"
			
			if "`regress'"=="regress" {
				count if `touse'==1
				eret scalar N = r(N)
			}
		}
	}
	else {
		if "`Version7'"=="" {
			est mat mean `ebmat'
			est mat Var `eVmat'
			
			if "`regress'"=="regress" {
				count if `touse'==1
				est scalar sum_N = r(N)
			}
		}
		else {
			eret mat mean=`ebmat'
			eret mat Var=`eVmat'
			
			if "`regress'"=="regress" {
				count if `touse'==1
				eret scalar sum_N = r(N)
			}
		}
	}

/*
else {
	if `=_by()'==1 {
		noi di in yellow "no observations when variable = something"
	}
	else {
		* `=_by()'~=1, not running by( )
		*noi di in red "no observations"
		error 2000
	}
}
*/

noi di
if `"`stringList'"'~="" {
	noi di in yellow "Following variable is string, not included:  "
	foreach var in `stringList' {
		noi di in yellow "`var'  " _c
	}
	di
}
if `"`noobsList'"'~="" {
	noi di in yellow "Following variable has no observation, not included:  "
	foreach var in `noobsList' {
		noi di in yellow "`var'  " _c
	}
	di
}

} /* qui */
end /* sum2 */


********************************************************************************************


* regList Jan2009 by roywada@hotmail.com
* regList Jun2009 by roywada@hotmail.com verion 7 added
* 28mar2010 [pw aw fw iw] added but ignored

prog define regList, rclass
* get the name of equations and variables used in e(b)
	versionSet
	version `version'
	
	* [if] [in] ignored:
	syntax [varlist(default=none)] [if] [in] [pw aw fw iw] [, NODEPendent *]
	
	* separate potential equation names from variable names
	tempname b b_transpose
	mat `b'=e(b)
	mat `b_transpose' = `b''
	local varnames : rownames(`b_transpose')
	
if "`nodependent'"~="nodependent" {
	* indep variables, but the equations names are actually dep variables
	* plus the dep var
	local eqlist "`e(depvar)' `eqlist'"
	macroUnique `eqlist', names(eqlist) number(eqcount)
	
/* not reliable because not always a dependent variable, i.e. sqreg slaps on q10, q20, etc.
	* take off numbers from the front (reg3 sometimes slaps them on)
	foreach v in `eqlist' {
		local first = substr(`"`v'"',1,1)
		local test
		cap local test = `first' * 1
		if "`test'"=="`first'" {
			* a number
			local wanted = substr(`"`v'"',2,.)
			local collect "`collect' `wanted'"
		}
		else {
			local collect "`collect' `v'"
		}
	}
	local eqlist `collect'
	macroUnique `eqlist', names(eqlist) number(eqcount)
	
	* repeat
	foreach v in `eqlist' {
		local first = substr(`"`v'"',1,1)
		local test
		cap local test = `first' * 1
		if "`test'"=="`first'" {
			* a number
			local wanted = substr(`"`v'"',2,.)
			local collect "`collect' `wanted'"
		}
		else {
			local collect "`collect' `v'"
		}
	}
	local eqlist `collect'
*/
	
	macroUnique `eqlist', names(eqlist) number(eqcount)
}
	macroUnique `eqlist', names(eqlist) number(eqcount)
	macroMinus `varnames', names(varlist) number(varnum) subtract(_cons)
	macroUnique `varlist', names(varlist) number(varnum)
	
	return local eqlist `eqlist'
	return local eqcount `eqcount'
	return local varlist `varlist'
	return local varnum `varnum'
	
end /* regList */


********************************************************************************************


* macroUnique Jan2009 by roywada@hotmail.com
* macroUnique Jun2009 by roywada@hotmail.com version 7 added
* 2014 07 02 version 13 update

prog define macroUnique

* gets you unique macro names & number of them (both c_locals)
* could be empty

syntax [anything], names(str) [number(str)]

if `c(stata_version)'<10.1 {
	version 7.0
	local collect ""
	* just holding the place until the loop
	local temp1: word 1 of `anything' 
	local temp2: word 2 of `anything'

	local total: word count `anything'
	local cc 1
	local same ""
	while "`temp1'"~="" {
		local temp1: word `cc' of `anything'
		local same ""
		*di "try `temp1' at `cc'"
		local kk=`cc'+1
		local temp2: word `kk' of `anything'
		while "`temp2'"~="" & "`same'"=="" {
			if "`temp1'"=="`temp2'" {
					*di "`cc' is same as `kk'"
				local same same
			}
			else {
				local kk=`kk'+1
			}
			local temp2: word `kk' of `anything'
		}
		if "`temp1'"~="" & "`temp2'"=="" & "`same'"~="same" {
			*di "accept `temp1' at `cc' before " _c
			local collect "`collect' `temp1'"
		}
		*di "reject `temp1' at `cc'"
		local cc=`cc'+1
	}
		
	c_local `names' `collect'
	if "`number'"~="" {
		c_local `number' : word count `collect'
	}
}
else {
	c_local `names' : list uniq anything
	if "`number'"~="" {
		c_local `number' : word count `:list uniq anything'
	}
}
end


********************************************************************************************


* macroMinus Jan2009 by roywada@hotmail.com
* macroMinus Jun2009 by roywada@hotmail.com version 7 added
prog define macroMinus

version 7.0

* gets you macro names subtracted & number of them (both c_locals)
* could be empty

syntax [anything], names(str) [number(str asis) subtract(str)]
	local collect ""
	* just holding until the loop
	local temp1: word 1 of `anything' 
	local temp2: word 1 of `subtract'
	
	local total: word count `anything'
	local cc 1
	local same ""
	while "`temp1'"~="" {
		local temp1: word `cc' of `anything'
		local same ""
		*di "try `temp1' at `cc'"
		local kk=1
		local temp2: word `kk' of `subtract'
		while "`temp2'"~="" & "`same'"=="" {
			if "`temp1'"=="`temp2'" {
 				*di "`temp1' is same as `temp2'"
				local same same
			}
			else {
				local kk=`kk'+1
			}
			local temp2: word `kk' of `subtract'
		}
		if "`temp1'"~="" & "`temp2'"=="" & "`same'"~="same" {
			*di "accept `temp1' at `cc' before " _c
			local collect "`collect' `temp1'"
		}
		*di "reject `temp1' at `cc'"
		local cc=`cc'+1
	}
	
	c_local `names' `collect'
	if "`number'"~="" {
		c_local `number' : word count `collect'
	}

end


********************************************************************************************


* Jun2009 version 7 added
* 23mar2010 labelA(insert upper lower proper)

prog define cleanFile
* split possible eqnames from varnames
* gets labels
* get titles
* c_locals titleWide headRow bottomRow

	versionSet
	version `version'

syntax using [, noQUOte comma title(str) label labelOption(str) /*
	*/ titlefile(str) NOTITLE slow(numlist) label_file(str)]
		
		* get c_locals returned from labelOption
		optionSyntax, valid(insert upper lower proper) name(labelA) nameShow(label( )) content(`labelOption')
		
		*** get the label names
		if "`label'"=="label" | "`insert'"=="insert" {
			
			tempfile labelfile
			
			/* old label file generationd
			* extender making sure the obs > columns
			local N=_N
			describe, short
			if `r(k)'>`N'+1 & `r(k)'<. {
				set obs `r(k)'
			}
			
			gen str8 var1=""
			gen str8 labels=""
			unab varlist_all : *
			cap unab subtract: _est_*
			*cap local varlist_only : list varlist_all - subtract
			macroMinus `varlist_all', names(varlist_only) subtract(`subtract')
			local count=1
			foreach var in `varlist_only' {
				local lab ""
				cap local lab: var label `var'
				local lab=trim("`lab'")
				if "`lab'"~="" {
					replace var1="`var'" in `count'
					replace labels="`lab'" in `count'
					local count=`count'+1
				}
			}
			keep var1 labels
			
			
			drop if var1==""
			
			* indicate no label contained
			local N=_N
			if `N'==0 {
				local emptyLabel=1
			}
			else {
				local emptyLabel=0
			}
			
			* add constant
			local newN=_N+1
			set obs `newN'
			
			local N=_N
			replace labels="Constant" in `N'
			replace var1="Constant" in `N'
			
			* letter cases
			if "`upper'"=="upper" {
				replace labels=upper(labels)
			}
			if "`lower'"=="lower" {
				replace labels=lower(labels)
			}
			if "`proper'"=="proper" {
				replace labels=proper(labels)
			}
			*/
			
			insheet using `label_file', clear
			ren v1 var1
			ren v2 labels
			
			save `"`labelfile'"'
		}
		
		
		
		*** clean up equation names, title, label
		insheet2 `using', nonames clear slow(`slow')
		tempvar id1 id2 id3 id4
		
		
		*** bottom row (the bottom border), count up
		gen rowmiss=0
		foreach var of varlist v* {
			replace rowmiss=rowmiss+1 if `var'~=""
		}
		local N=_N
		local content 1
		local num 0
		while `content'==1 & `num'<`N' {
			local content rowmiss[`=`N'-`num'']
			local num=`num'+1
		}
		* add titleWide and eqAdded later to get bottomBorder
		local bottomRow = `N'-`num'+1
		
		
		*** head row (the head border), count down
		local content
		local num 1
		local N=_N
		while `"`content'"'=="" & `num'<=`N' {
			local content=v1[`num']
			local num=`num'+1
		}
		* add titleWide later to get headBorder
		local headRow=`num'-1
		drop rowmiss
		
		
		gen id1=_n
		gen str8 equation=""
		gen str8 variable=""
		
		* find the top & bottom empty row
		gen rowmiss=0
		foreach var of varlist v* {
			replace rowmiss=rowmiss+1 if `var'~=""
		}
		
		
		* take care if colon (:) that may appears in the notes by limiting the search to the above
		local N=_N
		local stuff=rowmiss[`N']
		local cc 0
		while `stuff'~=0 {
			local stuff=rowmiss[`N'-`cc']
			local cc=`cc'+1
		}
		
		********** this should be made faster in version 10
		forval num=1/`=`N'-`cc'' {
			local name=trim(v1[`num'])
			local column=index("`name'",":")
			if `column'~=0 {
				local equation=trim(substr("`name'",1,`column'-1))
				local variable=trim(substr("`name'",`column'+1,length("`name'")))
				replace equation="`equation'" in `num'
				replace variable="`variable'" in `num'
			}
		}
				
		replace equation=equation[_n-1] if equation=="" & equation[_n-1]~="" & rowmiss~=0
		*replace equation=equation[_n-1] if equation=="" & equation[_n-1]~="" & v1~="Observations"
		
		* needs a workaround for blank inserted by user
		gen str8 temp=""
		replace temp=equation
		replace temp=temp[_n-1] if temp[_n-1]~="" & temp[_n-1]~="." & temp==""
		gen str8 top="1" if temp[_n]~=temp[_n-1] & temp[_n]~=""
		drop temp
		
		
		* now only the top empty row
		replace rowmiss=0 if rowmiss[_n-1]==0
		
		count if equation~=""
		if `r(N)'~=0 {
			* move equation names, instead of inserting them
			count if v1=="EQUATION"
			if `r(N)'==0 {
				gen str8 v0=""
				replace v0=equation
				replace v0="EQUATION" in `headRow'
				order v0
				replace v1=variable if variable~=""
			}
			else {
				replace v1=equation
				replace v1="EQUATION" in `headRow'
			}
		}
		drop rowmiss
		
		* strips the redundant equation names
		* must be undone at the insheet that recall this file in appendFile
		
		count if equation~=""
		if `r(N)'~=0 {
			*** for one column option
			replace v0="" if top=="" & v0~="EQUATION"
		}
		
		drop id1 equation variable        top
		outsheet2 `using', nonames `quote' `comma' replace slow(`slow')
		
		
		
		
		
		*** clean up labels
		if "`label'"=="label" | "`insert'"=="insert" {
			
			ren v1 var1
			gen `id2'=_n
			
			* skip merging process if no label was contained
			*if `emptyLabel'==1 {
			*	gen str8 labels=""
			*}
			*else {
				joinby var1 using `"`labelfile'"', unmatched(master)
				drop _merge
			*}
			
			sort `id2'
			drop `id2'
			order var1 labels
			cap order v0 var1 labels
			
			replace labels="LABELS" in `headRow'
			ren var1 v1
		}
		
		
		
		
		
		*** (re)attaches titles
	if "`notitle'"=="" {
		if `"`title'"'=="" {
			* NOTE: v0- saved here
			tempfile appending
			tempvar tomato potato
			gen `tomato' =_n+10000
			save `"`appending'"',replace
			
			*** Clean up titles
			* just coef, no label, no equation
			cap confirm file `"`titlefile'"'
			if !_rc {
				use `"`titlefile'"',clear
				
				*gen `id3'=1 if v1=="VARIABLES"
				*gen `id3'=1 if v1==`"`VARIABLES1'"'
				* find the top empty row
				gen rowmiss=0
				foreach var of varlist v* {
					replace rowmiss=rowmiss+1 if `var'~=""
				}
				replace rowmiss=0 if rowmiss[_n-1]==0
				
				gen `id3'=1 if rowmiss[_n+1]==0
				replace `id3'=1 if `id3'[_n-1]==1
				
				drop rowmiss
				drop if `id3'==1
				keep if v1~=""
				
				local N=_N
				if `N'~=0 {
					keep v1
					gen `potato'=_n
					local titleWide=_N
					joinby v1 using `"`appending'"', unmatched(both)
					sort `potato' `tomato'
					drop _merge `potato' `tomato'
					aorder
				}
				else {
					use `"`appending'"',replace
					drop `tomato'
				}
			}
			cap drop `tomato'
			
			* reorder again
			cap order v1 labels
			cap order v0 v1 labels
		}
		else {
			* parse title
			partxtl2 `"`title'"'
			local titleWide = `r(numtxt)'
			local t = 1
			while `t'<=`titleWide' {
				local titl`t' `r(txt`t')'
				local t = `t'+1
			}
			
			local oldN=_N
			set obs `=`r(numtxt)'+_N'
			gen `id4'=_n+10000
			forval num=1/`r(numtxt)' {
				replace v1="`r(txt`num')'" in `=`oldN'+`num''
				replace `id4'=`num' in `=`oldN'+`num''
			}
			sort `id4'
			drop `id4'
		}
		
		if "`titleWide'"=="" {
			local titleWide=0
		}
	}
		
		* problem spot
		outsheet2 `using', nonames `quote' `comma' replace slow(`slow')
		
		c_local bottomRow `bottomRow'
		c_local headRow `headRow'
		c_local titleWide `titleWide'
		
end /* cleanFile */


********************************************************************************************


* chewfile version 1.0.1 17Aug2009 by roywada@hotmail.com
* borrowed on 17Aug2009
prog define _chewfile
version 8.0

syntax using/, [save(str) begin(numlist max=1) end(str) clear parse(str) replace semiclear]

if `"`parse'"'=="" {
	local parse `"`=char(9)'"'
}

if "`begin'"=="" {
	local begin 1
}

if "`end'"=="" {
	local end .
}

if "`clear'"=="" & `"`save'"'=="" {
	if "`semiclear'"=="" {
		noi di in red "must specify {opt clear} or {opt save( )}
		exit 198
	}
}

if "`semiclear'"=="semiclear" {
	qui drop *
	qui set obs 0
}
else if "`clear'"=="clear" {
	clear
	qui set obs 0
}

if `"`save'"'=="" {
	tempfile dump
	local save `dump'
}

tempname fh outout
local linenum = 0
file open `fh' using `"`using'"', read

qui file open `outout' using `"`save'"', write `replace'

file read `fh' line

while r(eof)==0 {
	local linenum = `linenum' + 1
	local addedRow 0
	if `linenum'>=`begin' & `linenum'<=`end' {
		if `addedRow'==0 {
			qui set obs `=`=_N'+1'
		}
		
		*display %4.0f `linenum' _asis `"`macval(line)'"'
		file write `outout' `"`macval(line)'"' _n
		
		if "`clear'"=="clear" | "`semiclear'"=="semiclear" {
			tokenize `"`macval(line)'"', parse(`"`parse'"')
			local num 1
			local colnum 1
			while "``num''"~="" {
				local needOneMore 0
				if `"``num''"'~=`"`parse'"' {
					cap gen str3 var`colnum'=""
					cap replace var`colnum'="``num''" in `linenum'
					if _rc~=0 {
						qui set obs `=`=_N'+1'
						cap replace var`colnum'="``num''" in `linenum'
						local addedRow 1
					}
					*local colnum=`colnum'+1
				}
				else {
					cap gen str3 var`colnum'=""
					local colnum=`colnum'+1
				}
				local num=`num'+1
			}
		}
	}
	file read `fh' line
}

file close `fh'
file close `outout'
end


********************************************************************************************


* cdout 1.0.1 Apr2009 by roywada@hotmail.com
* opens the current directory for your viewing pleasure

* the following disabled 14oct2009: cap winexec cmd /c start .
* modified on 21oct2009:
*	displays "dir" instead of cdout or the folder location
*	cont option
* modified on 23mar2001 un-disabled: cap winexec cmd /c start .
* 04apr2011 for version 8 (original cdout needs this fix)

prog define _cdout
cap version 7.0

syntax, [cont NOOPEN]

if "`cont'"=="cont" {
	local _c "_c"
}

if "`noopen'"~="noopen" {
	cap winexec cmd /c start .
	cap !start cmd /c start .
}

if _rc~=0 {
        * version 6 or earlier
        di `"{stata `"cdout"':dir}"' `_c'
}
else {
        * invisible to Stata 7
        local Version7
        local Version7 `c(stata_version)'
	
	* for version 8
	c_local version 8.0

        
        if "`Version7'"=="" {
                * it is version 7 or earlier
                di `"{stata `"cdout"':dir}"' `_c'
        }
        else if `Version7'>=8.0 {
                version 8.0
                di `"{browse `"`c(pwd)'"' :dir}"' `_c'
        }
}

if "`cont'"=="cont" {
	di in white `" : "' _c
}

end


********************************************************************************************


*** parse various options

* oct2009
* parse tex( ) options
prog define _texout_parse
	version 7
	syntax, [FRagment NOPRetty PRetty Landscape]
	c_local texopts "`fragment' `nopretty' `pretty' `landscape'"
end


* 20may2010
* parse xposea( ) options
prog define _xposea_parse
	version 7
	syntax, [WHole]
	c_local whole `whole'
end


********************************************************************************************

* mar2011
* parse excel( ) options
prog define _excel_parse
	version 7
	syntax, [font(str) FONTSize(int 10) COLWidth(numlist) NUMeric]
	c_local excelfont "`font'"
	c_local excelfontsize "`fontsize'"
	c_local excelcolwidth "`colwidth'"
	c_local excelcellnumeric "`numeric'"
end


********************************************************************************************

* oct2009
* parse stats( ) options
prog define _stats_check
	
	* note: it will not prevent illegal options from entering (dumped into * `options') & allows multiple entry to be handled
	* note: must be all lower case
	
	version 7
	
	syntax, [eqname varname label label_pr label_up label_low test001 test01 test05 test10  coef se tstat pval ci aster blank beta ci_low ci_high /*
		*/ n sum_w mean var sd SKEWness KURTosis sum min max p1 p5 p10 p25 p50 p75 p90 p95 p99 cv range iqr semean median count covar corr pwcorr spearman pcorr semipcorr pcorrpval tau_a tau_b *]
	
	c_local sumAsked ""
	if `"`n'`sum_w'`mean'`var'`sd'`min'`max'`sum'"'~="" {
		c_local sumAsked regular
	}
	if `"`skewness'`kurtosis'`p1'`p5'`p10'`p25'`p50'`p75'`p90'`p95'`p99'`range'`cv'`semean'`median'`count'"'~="" {
		c_local sumAsked detail
	}
	if `"`cv'`range'`iqr'`semean'`median'`count'"'~="" {
		c_local sumAsked extra
	}
	
	foreach var in covar corr pwcorr spearman pcorr semipcorr pcorrpval tau_a tau_b {
		c_local `var'Asked ""
		if `"``var''"'~="" {
			c_local `var'Asked `var'
		}
	}
	
	foreach var in eqname varname label label_pr label_up label_low test001 test01 test05 test10  {
		c_local `var'Asked ""
		if `"``var''"'~="" {
			c_local `var'Asked `var'
		}
	}
end


********************************************************************************************


* oct2009
* 05apr2010 added mat( ) and e( )
* parse cmd( ), str( ), and r( ) from the contents of stats( ) option
prog define _stats_parse
	
	version 7
	
	syntax, [cmd(str asis) str(str asis) r(str asis) Mat(str asis) e(str asis)]
	
end


********************************************************************************************


* 03nov2009
* 28jan2010 for version 11 fv
* 04apr2011 for version 8

prog define versionSet
	* sends back the version as c_local
	version 7.0
	
	* invisible to Stata 7
	cap local Version7 `c(stata_version)'
	c_local Version7 `Version7'
	
	* a_version is the actual version number with a floor of 7
	if "`Version7'"=="" {
		* it is version 7
		c_local version 7
		c_local a_version 7
	}
	else {
		c_local a_version `Version7'
		
		* for version 8
		c_local version 8.0
		
		if `Version7'>=8.2 {
			* version 8.2
			c_local version 8.2
		}
		if `Version7'>=10.1 {
			* version 10.1 or higher
			c_local version `Version7'
		}
	}
	
	if "`Version7'"=="" {
		c_local bind ""
	}
	else {
		c_local bind "bind"
	}
end


********************************************************************************************


* 15nov2009
* not used
prog define eretSet, eclass
	versionSet
	version `version'
	
	syntax varlist
	cap reg `varlist'
	if _rc==0 {
		marksample touse
		tempname ebmat eVmat
		
		mat `ebmat'=e(b)
		mat `eVmat'=e(V)
		
		gettoken depvar rest: varlist
		
		if "`Version7'"=="" {
			est mat b `ebmat'
			est mat V `eVmat'
			
			count if `touse'==1
			est scalar N = r(N)
		}
		else {
			tempvar sample
			local N=e(N)
			local depvar=e(depvar)
			gen `sample'=e(sample)
			eret clear
			eret post `ebmat' `eVmat', e(`sample')
			eret local depvar `"`depvar'"'
			eret scalar N = `N'
		}
	}
end


********************************************************************************************


* cloned 20nov2009
* pcorr2 version 1.1
* Adapted by Richard Williams from pcorr2 version 2.2.8  08sep2000
* Last Modified 14Feb2004
prog define pcorr, rclass
        version 6
        syntax varlist(min=2) [pweight fweight aweight iweight] [if] [in]
        marksample touse
	gettoken dep indep: varlist
	regList
	* will be redundant
	macroMinus `r(varlist)', names(temp) subtract(`dep' `indep')
        local weight "[`weight'`exp']"
        quietly reg `dep' `indep' `temp' `weight' if `touse'
        if (e(N)==0 | e(N)==.) { error 2000 }
        local NmK = e(df_r)
                quietly test `indep'
                local s "1"
                if (_b[`indep']<0) { local s "-1" }
                ret scalar pcorr=`=`s'*sqrt(r(F)/(r(F)+`NmK'))'
                ret scalar semipcorr=`=`s'*sqrt(r(F)* ((1-e(r2))/`NmK'))'
                *ret scalar pcorr2=`=(r(F)/(r(F)+`NmK'))'
                *ret scalar semipcorr2=`=(r(F)* ((1-e(r2))/`NmK'))'
                ret scalar pcorrpval=`=tprob(`NmK',sqrt(r(F)))'
end

prog define semipcorr, rclass
        version 6
        syntax varlist(min=2) [aw fw] [if] [in]
        marksample touse
	gettoken dep indep: varlist
	regList
	* will be redundant
	macroMinus `r(varlist)', names(temp) subtract(`dep' `indep')
        local weight "[`weight'`exp']"
        qui reg `dep' `indep' `temp' `weight' if `touse'
        if (e(N)==0 | e(N)==.) { error 2000 }
        local NmK = e(df_r)
                quietly test `indep'
                local s "1"
                if (_b[`indep']<0) { local s "-1" }
                ret scalar pcorr=`=`s'*sqrt(r(F)/(r(F)+`NmK'))'
                ret scalar semipcorr=`=`s'*sqrt(r(F)* ((1-e(r2))/`NmK'))'
                *ret scalar pcorr2=`=(r(F)/(r(F)+`NmK'))'
                *ret scalar semipcorr2=`=(r(F)* ((1-e(r2))/`NmK'))'
                ret scalar pcorrpval=`=tprob(`NmK',sqrt(r(F)))'
end

prog define pcorrpval, rclass
        version 6
        syntax varlist(min=2) [aw fw] [if] [in]
        marksample touse
	gettoken dep indep: varlist
	regList
	* will be redundant
	macroMinus `r(varlist)', names(temp) subtract(`dep' `indep')
        local weight "[`weight'`exp']"
        quietly reg `dep' `indep' `temp' `weight' if `touse'
        if (e(N)==0 | e(N)==.) { error 2000 }
        local NmK = e(df_r)
                quietly test `indep'
                local s "1"
                if (_b[`indep']<0) { local s "-1" }
                ret scalar pcorr=`=`s'*sqrt(r(F)/(r(F)+`NmK'))'
                ret scalar semipcorr=`=`s'*sqrt(r(F)* ((1-e(r2))/`NmK'))'
                *ret scalar pcorr2=`=(r(F)/(r(F)+`NmK'))'
                *ret scalar semipcorr2=`=(r(F)* ((1-e(r2))/`NmK'))'
                ret scalar pcorrpval=`=tprob(`NmK',sqrt(r(F)))'
end


********************************************************************************************


* 27nov2009
prog define tau_a, rclass
        version 6
	* weight ignored
        syntax varlist(min=2) [pw aw fw iw] [if] [in]
        marksample touse
	gettoken dep indep: varlist
	ktau `dep' `indep'
	ret scalar tau_a=`r(tau_a)'
end

prog define tau_b, rclass
        version 6
	* weight ignored
        syntax varlist(min=2) [pw aw fw iw] [if] [in]
        marksample touse
	gettoken dep indep: varlist
	ktau `dep' `indep'
	ret scalar tau_b=`r(tau_b)'
end


********************************************************************************************


* 29mar2010
*************** cap to avoid constant, could use equation name as the label for constant
prog define label0, rclass /* cannot be named label */
	* weight ignored, no need for touse
        syntax varlist(min=2) [pw aw fw iw] [if] [in]
	gettoken dep indep: varlist
	cap local temp : var label `indep'
	ret local label=`"`temp'"'
end

prog define label_pr, rclass
	* weight ignored, no need for touse
        syntax varlist(min=2) [pw aw fw iw] [if] [in]
	gettoken dep indep: varlist
	cap local temp : var label `indep'
	local temp=proper(`"`temp'"')
	ret local label_pr=`"`temp'"'
end

prog define label_up, rclass
	* weight ignored, no need for touse
        syntax varlist(min=2) [pw aw fw iw] [if] [in]
	gettoken dep indep: varlist
	cap local temp : var label `indep'
	local temp=upper(`"`temp'"')
	ret local label_up=`"`temp'"'
end

prog define label_low, rclass
	* weight ignored, no need for touse
        syntax varlist(min=2) [pw aw fw iw] [if] [in]
	gettoken dep indep: varlist
	cap local temp : var label `indep'
	local temp=lower(`"`temp'"')
	ret local label_low=`"`temp'"'
end


********************************************************************************************


* 21nov2009
* concatenate variables into one string variable
prog define concat
	version 7
	syntax, input(str)
	givetoken, input(`input') clocal(concat) parse(",")
	local num 1
	tempvar temp1
	while "`concat`num''"~="" {
		givetoken, input(`concat`=`num'+1'') clocal(varname) parse("+")
		local nn 1
		while "`varname`nn''"~="" {
			*di `"`varname`nn''"'
			*di `"`varname`=`nn'+1''"'
			cap gen str7 `temp1'=""
			cap replace `temp1'=string(`varname`nn'')
			if _rc==0 {
				move `temp1' `varname`nn''
				drop `varname`nn''
				ren `temp1' `varname`nn''
			}
			local nn=`nn'+1
		}
		*di
		gen str7 `concat`num''=""
		replace `concat`num''=`concat`=`num'+1''
		local num=`num'+2
	}
end


********************************************************************************************


* 21nov2009
* gettoken-based parser
prog define givetoken
	* parse will take only one character
	version 7
	syntax, input(str) clocal(str) [parse(str)]
	local num 1
	if `"`parse'"'=="" {
		local parse " "
		gettoken one two : input, parse("`parse'")
		c_local `clocal'`num' `"`one'"'
		while `"`two'"'~="" {
			local num=`num'+1
			*gettoken one two : two, parse("`parse'")
			gettoken one two : two, parse("`parse'")
			c_local `clocal'`num' `"`one'"'
		}
	}
	else {
		gettoken one two : input, parse("`parse'")
		c_local `clocal'`num' `"`one'"'
		while `"`two'"'~="" {
			local num=`num'+1
			gettoken one two : two, parse("`parse'")
			gettoken one two : two, parse("`parse'")
			c_local `clocal'`num' `"`one'"'
		}
	}
end


********************************************************************************************


* 25nov2009 calculates covariance
prog define covar, rclass
	syntax varlist(max=2) [if]
	gettoken dep indep : varlist
	qui summarize `dep' `if'
	local sdy `r(sd)'
	qui summarize `indep' `if'
	local sdx `r(sd)'
	corr `dep' `indep' `if'
	*c_local covar `=`r(rho)'*`sdy'*`sdx''
	ret local covar `=`r(rho)'*`sdy'*`sdx''
end


********************************************************************************************


* 16may2010 borrowed from regdis.ado
* 04apr2011 minor changes for version 7

prog define _explicit
        cap syntax varlist(default=none ts fv)
        if _rc~=0 {
                * yes I know this is a workaround
                cap syntax varlist(default=none ts)
				if _rc~=0 {
					* version 7
					c_local _varlist `0'
				}
        }
        else {
                syntax varlist(default=none ts fv)
                _rmcoll `varlist'
        }
        c_local _varlist `varlist'
end


********************************************************************************************


program def _thisthat 

end 



********************************************************************************************


* 25july2010
prog define _eqmatch
syntax anything
	gettoken one two: anything
	local one=trim("`one'")
	local two=trim("`two'")
	*split varname, parse(":") gen(_varname)
	split report, parse(":") gen(_temp)
	replace eqname="`one'" if eqname=="`two'"
	replace report=eqname+":"+_temp2
	cap drop _temp1
	cap drop _temp2
end




********************************************************************************************


* 27july2011
* handles the non-existant or non-accessible files

prog define outsheet2
	
	syntax [anything] using, [slow(int 1) *] 
	
	/* wait 1000 ms = 1 second before trying again */
	
	cap outsheet `anything' `using', `options'
	
	
	if _rc~=0 {
		sleep 250
		cap outsheet `anything' `using', `options'
	}
	if _rc~=0 {
		sleep 250
		cap outsheet `anything' `using', `options'
	}
	if _rc~=0 {
		sleep 250
		cap outsheet `anything' `using', `options'
	}
	if _rc~=0 {
		sleep `=250+`slow''
		outsheet `anything' `using', `options'
	}
end


prog define insheet2
	
	syntax [anything] using, [slow(int 1) *] 
	
	/* wait 1000 ms = 1 second before trying again */
	
	cap insheet `anything' `using', `options'
	
	
	if _rc~=0 {
		sleep 250
		cap insheet `anything' `using', `options'
	}
	if _rc~=0 {
		sleep 250
		cap insheet `anything' `using', `options'
	}
	if _rc~=0 {
		sleep 250
		cap insheet `anything' `using', `options'
	}
	if _rc~=0 {
		sleep `=250+`slow''
		insheet `anything' `using', `options'
	}
end




* 27apr2014
* handles the mess created by fvunab tsunab unab

prog define fvtsunab
	syntax [anything], [onebyone poundsign]
	* onebyone does it by each tokens
	* poundsign will parse by # also
	
	versionSet
	version `version'
	
	if "`onebyone'"~="" {
		* one by one version
		if `a_version'>=11 {
			foreach var in `anything' {
				cap fvunab temp : `var'
				cap fvexpand `temp'
				local tempList "`tempList' `r(varlist)'"
			}
		}
		else {
			foreach var in `anything' {
				cap tsunab temp : `var'
				local tempList "`tempList' `temp'"
			}
		}
	}
	else {
		* together
		if `a_version'>=11 {
			cap fvunab temp : `anything'
			cap fvexpand `temp'
			cap local tempList `r(varlist)'
		}
		else {
			foreach var in `anything' {
				cap tsunab tempList : `anything'
			}
		}
	}
	
	c_local fvtsunab_list `tempList'
	
	* separate by poundsign (#) if need be
	if "`poundsign'"=="poundsign" & index("`tempList'","#")~=0 {
		local rest `"`tempList'"'
		local num 1
		gettoken first rest: rest, parse("#")
		local pounded_list "`first'"
		
		while "`rest'"~="" {
			local num=`num'+1
			gettoken second rest: rest, parse("#")
			gettoken second rest: rest, parse("#")
			
			local pounded_list "`pounded_list' `second'"
		}
		c_local fvtsunab_list `pounded_list'
	}

end




* 2014 04 28
* determine fv, ts, base, omitted, and extract labels
prog fvts_label
	cap version 12
	syntax anything
	
	fvtsunab `anything', poundsign
	
	local candidate `fvtsunab_list'
	gettoken first rest: candidate, parse(".")
	gettoken second rest: rest, parse(".")
	gettoken third rest: rest, parse(".")
	
	if "`first'"~="" & "`second'"=="" {
		cap confirm new variable `first'
		if _rc==110 {
			* first is regular varname and exists
			cap local varlabel: var label `first'
			cap local varlabel=trim("`varlabel'")
			if "`varlabel'"=="" {
				local varlabel =trim("`first'")
			}
			local output `"`varlabel'"'
		}
	}
	else if "`first'"~="" & "`second'"=="." & "`third'"~="" & "`rest'"=="" {
		
		cap confirm new variable `third'
		if _rc==110 {
			* third is a regular varname and exists
			cap local varlabel: var label `third'
			cap local varlabel=trim("`varlabel'")
			if "`varlabel'"=="" {
				local varlabel =trim("`third'")
			}
			
			local end
			
			* handle what is in first
			cap confirm number `first'
			if _rc==0 {
				* first is regular number
				local end
			}
			else {
				* first is fv
				if "`first'"=="co" {
					local base_or_omitted "continuous omitted"
				}
				else {
					* separate number and suffix
					local bare=substr("`first'",1,length("`first'")-1)
					local basesuffix=substr("`first'",length("`first'"),length("`first'"))
					
					cap confirm number `bare'
					if _rc==0 {
						if "`basesuffix'"=="o" {
							local base_or_omitted omitted
						}
						else if "`basesuffix'"=="b" {
							local base_or_omitted base
						}
						else if "`basesuffix'"=="n" {
							* 1b 0b etc (not 1bn or 0bn) - not tested
							local bare=substr("`first'",1,length("`first'")-2)
							local basesuffix=substr("`first'",length("`first'")-1,length("`first'"))
							local base_or_omitted base
						}
					}
					local end `", `base_or_omitted'"'
				}
			}
			* time series
			* lagged, etc
			
			cap local varlabelname : value label `third'
			cap local labelofvalue : label `varlabelname' `first' 
			
			if `"`labelofvalue'"'=="" & "`bare'"~="" {
				local output `"`varlabel' = `bare'`end'"'
			}
			else if `"`labelofvalue'"'=="" {
				local output `"`varlabel' = `first'`end'"'
			}
			else if "`first'"~="" {
				local output `"`varlabel' = `first', `labelofvalue'`end'"'
			}
			else {
				local output `"`varlabel' = `bare', `labelofvalue'`end'"'
			}
		}
	}
	c_local basevalue `"`bare'"'
	c_local basesuffix `"`basesuffix'"'
	c_local baseonly `"`third'"'
	c_local fvts_label_list `"`output'"'
end /* fvts_label */



* 2014 04 28
* double parse addstat contents
prog _addstat_parse
	cap version 12
	syntax, addstat(str asis) [ADec(numlist int >=0 <=11 max=1) AFmt(str asis) AUTO(integer 3) LESS(integer 0) NOAUTO	DECMark(str asis)]
	
	local afmt_value `afmt'
	if "`afmt'"=="" {
		local afmt_value fc
	}
		*** PRE-PARSE with autodigit disabled because r( ) needs to be evaluated before r-class autodigit
		local newadd=""
		
		gettoken part rest: addstat, parse(" (")
		gettoken part rest: rest, parse(" (") /* strip off "addstat(" */
		local i = 1
		while `"`rest'"' != "" {
			gettoken name rest : rest, parse(",") quote
			if `"`name'"'=="" {
				di in red "empty strings not allowed in addstat() option"
				exit 6
			}
			gettoken acomma rest : rest, parse(",")
			gettoken valstr rest : rest, parse(",")
			if `"`rest'"' == "" { /* strip off trailing parenthesis */
				local valstr = substr(`"`valstr'"',1,length(`"`valstr'"')-1)
				local comma2 ""
			}
			else {
				gettoken comma2 rest: rest, parse(",")
			}
			
			* creating e(p) if missing
			if ("`valstr'"=="e(p)" | trim("`valstr'")=="e(p)") & "`e(p)'"=="" {
				if "`e(df_m)'"~="" & "`e(df_r)'"~="" & "`e(F)'"~="" {
					local valstr = Ftail(`e(df_m)',`e(df_r)',`e(F)')
				}
				else if "`e(df_m)'"~="" & "`e(chi2)'"~="" {
					local valstr = chi2tail(`e(df_m)',`e(chi2)')
				}
				* update if xtreg, fe is messing with it
				if "`e(df_m)'"~="" & "`e(df_b)'"~="" & "`e(F)'"~="" {
					local valstr = Ftail(`e(df_b)',`e(df_r)',`e(F)')
				}
				else if "`e(df_b)'"~="" & "`e(chi2)'"~="" {
					local valstr = chi2tail(`e(df_b)',`e(chi2)')
				}
			}
			
			local value=`valstr'
			capture confirm number `value'
			
			if _rc==0 {
				* it's a number
				
				local value = `valstr'
				
				local count: word count `adec'
				local aadec : word `i' of `adec'
				
				* runs only if the user defined adec is absent for that number
				* now runs only if adec is present at all
				if "`adec'"=="" {
					* auto-digits: auto( ), cannot check for decmark (decimal separator) because comma is used for parsing						*autodigits2 `value' `auto'
					* needs to be less than 11
					*local valstr = string(`value',"%12.`r(valstr)'")
					local valstr = string(`value')
					if "`valstr'"=="" {
						local valstr .
					}
					local newadd `"`newadd'`name'`acomma'`valstr'`comma2'"'
				}
				else {
					* using previous ones if no other option
					if "`aadec'"=="" {
					local aadec `prvadec'
						if "`prvadec'"=="" {
							local aadec 2
						}
					}
					local valstr = string(`value',"%12.`aadec'`afmt_value'")
					local newadd `"`newadd'`name'`acomma'`valstr'`comma2'"'
					local prvadec = `aadec'
				}
			}
			else {
				* it's a non-number
				local index=index(`"`valstr'"',"e(")
				if `index'~=0 {
					if `"``valstr''"'=="" {
						* put a dot in there
						local value `"`valstr'"'
						local newadd `"`newadd'`name'`acomma'.`comma2'"'
						noi di in yel `"check {stata eret list} for the existence of `valstr'"'
					}
					else {
						* passthru `valstr'
						local value `"`valstr'"'
						local newadd `"`newadd'`name'`acomma'`valstr'`comma2'"'
					}
				}
				else {
					* evaluate ``valstr''
					local value `"`valstr'"'
					local newadd `"`newadd'`name'`acomma'``valstr''`comma2'"'
				}
			}
			
			local i = `i'+1
		}
		local addstat `"`newadd'"'
		
		
	if "`adec'"=="" {	
		*** do it again with autodigit enabled
		local addstat `"addstat(`addstat')"'
		
		local newadd=""
		gettoken part rest: addstat, parse(" (")
		gettoken part rest: rest, parse(" (") /* strip off "addstat(" */
		local i = 1
		while `"`rest'"' != "" {
			gettoken name rest : rest, parse(",") quote
			if `"`name'"'=="" {
				di in red "empty strings not allowed in addstat() option"
				exit 6
			}
			gettoken acomma rest : rest, parse(",")
			gettoken valstr rest : rest, parse(",")
			if `"`rest'"' == "" { /* strip off trailing parenthesis */
				local valstr = substr(`"`valstr'"',1,length(`"`valstr'"')-1)
				local comma2 ""
			}
			else {
				gettoken comma2 rest: rest, parse(",")
			}
			
			* creating e(p) if missing
			if ("`valstr'"=="e(p)" | trim("`valstr'")=="e(p)") & "`e(p)'"=="" {
				if "`e(df_m)'"~="" & "`e(df_r)'"~="" & "`e(F)'"~="" {
					local valstr = Ftail(`e(df_m)',`e(df_r)',`e(F)')
				}
				else if "`e(df_m)'"~="" & "`e(chi2)'"~="" {
					local valstr = chi2tail(`e(df_m)',`e(chi2)')
				}
				* update if xtreg, fe is messing with it
				if "`e(df_m)'"~="" & "`e(df_b)'"~="" & "`e(F)'"~="" {
					local valstr = Ftail(`e(df_b)',`e(df_r)',`e(F)')
				}
				else if "`e(df_b)'"~="" & "`e(chi2)'"~="" {
					local valstr = chi2tail(`e(df_b)',`e(chi2)')
				}
			}
			
			*local value = `valstr'
			*capture confirm number `value'
			*if _rc!=0 {
			* 	* di in red `"`valstr' found where number expected in addstat() option"'
			* 	* exit 7
			*}
			
			local value=`valstr'
			capture confirm number `value'
			
			if _rc==0 {
				* it's a number
				
				local value = `valstr'
				
				local count: word count `adec'
				local aadec : word `i' of `adec'
				
				* runs only if the user defined adec is absent for that number
				*if `i'>`count' & `i'<. {
				* now runs only if adec is present at all
				
				if "`adec'"=="" {
					* auto-digits: auto( ), cannot check for decmark (decimal separator) because comma is used for parsing
					
					****** different than above
					autodigits2 `value' `auto' `less'
					* needs to be less than 11
					if "`afmt'"~="" {
						local valstr = string(`value',"%12.`r(value)'`afmt_value'")
					}
					else {
						local valstr = string(`value',"%12.`r(valstr)'")
					}
					
					
					if "`valstr'"=="" {
						local valstr .
					}
					local newadd `"`newadd'`name'`acomma'`valstr'`comma2'"'
				}
				else {
					* using previous ones if no other option
					if "`aadec'"=="" {
						local aadec `prvadec'
						if "`prvadec'"=="" {
							local aadec 2
						}
					}
					local valstr = string(`value',"%12.`aadec'`afmt_value'")
					local newadd `"`newadd'`name'`acomma'`valstr'`comma2'"'
					local prvadec = `aadec'
				}
			}
			else {
				* it's a non-number
				local index=index(`"`valstr'"',"e(")
				if `index'~=0 {
					if `"``valstr''"'=="" {
						* put a dot in there
						local value `"`valstr'"'
						local newadd `"`newadd'`name'`acomma'.`comma2'"'
						noi di in yel `"`valstr' does not exist; check {stata eret list}"'
					}
					else {
						* passthru `valstr'
						local value `"`valstr'"'
						local newadd `"`newadd'`name'`acomma'``valstr''`comma2'"'
					}
				}
				else {
					* evaluate ``valstr''
					local value `"`valstr'"'
					local newadd `"`newadd'`name'`acomma'`valstr'`comma2'"'
				}
			}
			
			local i = `i'+1
		}
		local addstat `"`newadd'"'
	}
	c_local addstat `"`addstat'"'
end
exit


