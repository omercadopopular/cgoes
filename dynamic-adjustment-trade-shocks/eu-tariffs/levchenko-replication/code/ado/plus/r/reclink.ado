program define reclink
version 8.2
*! v 1.7 14-Jan-2010 M. Blasnik:  Record Linkage
*! 1.7 fixes typo in winkler adjustment to bigram calculation that prevented the adjustment
*! 1.6 fixes file paths with spaces -- encloses all file references in double quotes
*! 1.5 fixes bug introduced in second release and orblock none bug
syntax varlist using/ ,  IDMaster(str) IDUsing(str) Gen(str) [WMatch(str) WNOMatch(str) EXClude(str) /* 
*/   UVarlist(str) MINScore(real 0.6) MINBigram(real 0.6) ORBLock(str) REQuired(str) /*
*/ _Merge(str) UPRefix(str) EXActstr(str) DEBug(str) ]

if "`_merge'"=="" local _merge "_merge"
cap confirm variable `_merge'
if _rc==0 {
	di as err "`_merge' already exists"
	exit 198
}

local nvars: word count `varlist'
if "`wmatch'"=="" local wmatch: di _dup(`nvars')  " 1 "
if "`wnomatch'"=="" local wnomatch "`wmatch'"
if "`uprefix'"=="" local uprefix "U"
foreach val in `wmatch' `wmnomatch'  {
	if `val'<1 {
		di as error " weights must be >=1"
		exit 198
	}
}

local nwms:  word count `wmatch'
local nwnms: word count `wnomatch'
if `nvars'!=`nwnms' | `nvars'!=`nwms'  {
	di as error "wmatch and wnomatch must each have the same # of elements as varlist"
	exit 198
}

if "`uvarlist'"=="" local uvarlist "`varlist'"
local nuvars: word count `uvarlist'
if `nvars'!=`nuvars' {
	di as error "uvarlist must have the same # of elements as varlist"
	exit 198
}

if `:list required in varlist'==0 {
		di as error "all variables in required() option must also be in the main varlist"
		exit 198
}
	
if "`orblock'"!="none" & `:list orblock in varlist'==0 {
		di as error "all variables in orblock() option must also be in the main varlist"
		exit 198
}

if "`orblock'"=="" & `nvars'>3 local orblock "`varlist'"

local i=1
foreach var of local varlist {
	local v`i' "`var'"
  local wm`i': word `i' of `wmatch'
	local wnm`i': word `i' of `wnomatch'
	local uv`i': word `i' of `uvarlist'
	cap confirm string var `var'
	local string`i'=(_rc==0)
	local bigram`i': list var in exactstr
	local bigram`i'=1-`bigram`i''
	local inreq`i': list var in required
	local i=`i'+1
}

* scaling factor for bigram score mapping to matchscore 
local biscale=.5/(1-`minbigram')^(1/3)

preserve

quietly {
isid `idmaster'
gen `gen'=0
label var `gen' "reclink matching score"
local mobs=c(N)
tempfile m u matched  idusingmatched idmastermatched 
if "`debug'"=="" tempfile results
else local results "`debug'"

keep `idmaster' `gen' `varlist'
sort `idmaster'
local idmtype: type `idmaster'
save "`m'"

if "`exclude'"!="" {
	tempfile midexclude uidexclude using2
	tempvar mrgtmp
	use `idmaster' `idusing' using "`exclude'"
	drop if missing(`idmaster') | missing(`idusing')
	save "`midexclude'"
	
	bysort `idusing': keep if _n==1
	keep `idusing'
	sort `idusing'
	save "`uidexclude'"
	
	use "`midexclude'"
	bysort `idmaster': keep if _n==1
	keep `idmaster'
	sort `idmaster'
	merge `idmaster' using "`m'", _merge(`mrgtmp')
	keep if `mrgtmp'==2
	drop `mrgtmp'	
	sort `idmaster'
	local mobs2match=c(N)
	save "`m'", replace

	use "`using'"
	local uobs=c(N)
	sort `idusing'
	merge `idusing' using "`uidexclude'", _merge(`mrgtmp') nokeep
	keep if `mrgtmp'==1
	drop `mrgtmp'
	save "`using2'"
}
else {
	local using2 "`using'"
}

use "`using2'"
local uobs2match=c(N)
if "`uobs'"=="" local uobs=c(N)
isid `idusing'
keep `idusing' `uvarlist'
local i=1
foreach var of varlist `uvarlist' {
	if "`var'"!="`v`i''" {
		cap rename `var' `v`i''
	}
	local i=`i'+1
}
sort `varlist'
local idutype: type `idusing'
tempvar uidtmp
egen `uidtmp'=group(`varlist'), missing
save "`u'"

* create lookup table back to original id variable in using dataset
keep `uidtmp' `idusing'
tempfile uids
sort `uidtmp'
save "`uids'"

* now collapse the using dataset down to unique combinations of varlist
use "`u'"
drop `idusing'
bysort `uidtmp' : keep if _n==1
sort `varlist' 
save "`u'", replace
local uniqusingn=c(N)

* identify perfect matches
use "`m'"
sort `varlist'
merge `varlist' using "`u'", nokeep
keep if _merge==3
local perfectn=c(N)
noi di as result _n "`perfectn' perfect matches found" _n

if `perfectn'>0 {
	replace `gen'=1
	keep `idmaster' `uidtmp' `gen'
	sort `idmaster'
	save "`matched'"

	* save using ids for perfect matches
	keep `uidtmp'  
	sort `uidtmp'
	save "`idusingmatched'"

	* save master ids for perfect matches	
	use "`matched'"
	keep `idmaster'
	sort `idmaster'
	save "`idmastermatched'"

	* get rid of perfect matches from using datafile 
	use "`u'"
	sort `uidtmp'
	merge `uidtmp' using  "`idusingmatched'"
	keep if _merge==1
	drop _merge
	save "`u'", replace

	* get rid of perfect matches from master data file
	use "`m'"
	sort `idmaster'
	merge `idmaster' using  "`idmastermatched'"
	keep if _merge==1
	drop _merge
	save "`m'", replace
	
}
	
else {
	use "`m'", replace
}

local tomatch=c(N)
tempname post
postfile `post' `idmtype' `idmaster' long `uidtmp' float `gen' using "`results'"
if `tomatch'>1000 {
noi di as text "Going through `tomatch' observation to assess fuzzy matches, each .=5% complete"
}
forvalues obs=1(1)`tomatch' {
		use "`m'" in `obs', replace

  if int(20*`obs'/`tomatch')!=int(20*(`obs'-1)/`tomatch') & (`tomatch'>1000) noi di "." _c
	local ifall
	local ifany
	local ifreq

* OR blocking
	local orblock : list orblock - required
	if lower("`orblock'")!="none" & "`orblock'"!="" {
		local i=1
		foreach v of local orblock {
			local thisval=`v'[1]
			if "`thisval'"!="" {
				if `"`ifany'"'!="" {
					local ifany `" `ifany' | "'
				}
				cap confirm string var `v'
				if _rc==0 {
					local ifany `" `ifany' `v'=="`thisval'" "'
				}
				else {
					local ifany `" `ifany' `v'==`thisval' "'
				}
			}
			local i=`i'+1
		}
	local ifall `" if (`ifany') "'
	} /* end of OR blocking */
	
	* now add required matches
	if "`required'"!="" {
		local i=1
		foreach v of local required {
			local thisval=`v'[1]
			if `"`ifreq'"'!="" {
				local ifreq `" `ifreq' & "'
			}
			cap confirm string var `v'
			if _rc==0 {
				local ifreq `" `ifreq' `v'=="`thisval'" "'
			}
			 else {
			 	local ifreq `" `ifreq' `v'==`thisval' "'
			}
			local i=`i'+1
		}
		if `"`ifall'"'!="" local ifall `" `ifall' & (`ifreq') "'
		 else local ifall `" if (`ifreq') "'
	} /* end of required matches */
		
	local thisidmaster=`idmaster'[1]
	local i=1
	foreach v of local varlist {
			local thisv`i'=`v'[1]
			local i=`i'+1
	}
		
* still need to go thru varlist to drop single quotes that cause macro problems?

	* load using data which meets required and orblock 
	use "`u'"  `ifall', replace
	local upossn=c(N)
	if `upossn'>0 {

* scale bigram matches from minscore to 1 into 0->1
		tempvar M NM score bi
		gen `M'=0
		gen `NM'=0
		local i=1
		foreach v of local varlist {
				if "`thisv`i''"!="" {
					if `inreq`i''!=1 {
						if `string`i''==1 & `bigram`i''==1 {
							bigram1 `v', match(`thisv`i'') gen(`bi') 
						}
						else {
							cap drop `bi'
							if `string`i''==1 gen `bi'=(`v'=="`thisv`i''")
							else gen `bi'=(`v'==`thisv`i'')
						}
					replace `M'=`M'+`wm`i''*(.5*`bi'^2+cond(`bi'>`minbigram',`biscale'*(`bi'-`minbigram')^(1/3),0))
					replace `NM'=`NM'+`wnm`i''*cond(`bi'<(`minbigram'-.2),1,cond(`bi'<`minbigram',1-`bi'^2,(1-`bi')^2)) if !missing(`v') 
					}
					else {
						replace `M'=`M'+`wm`i''
					}
			}
				* missing in one, not other = 30% non-match
				 replace `NM'=`NM'+`wnm`i''*0.3 if (missing("`thisv`i''") + missing(`v')) ==1
			local i=`i'+1
		} 
		
		gen `score'=`M'/(`M'+`NM')
		
		replace `score'=0 if `score'==.
		sort `score'
		* now keep the cases with the highest score and post them
		keep if `score'==`score'[_N] & `score'>`minscore'
		local matches=c(N)
		if `matches'>0 {
			local scoreval=`score'[1]
			forval j=1(1)`matches' {
				local thisidusing = `uidtmp'[`j']
				post `post' (`thisidmaster') (`thisidusing') (`scoreval') 
			}
		}
	} 
}
postclose `post'

* now merge the matching back into master 
use "`results'", replace
local resobs=c(N)
if `perfectn'>0 {
	append using "`matched'"
}
tempvar tmrg
sort `uidtmp'
merge `uidtmp' using "`uids'", nokeep _merge(`tmrg')
assert `tmrg'==3
drop `tmrg' `uidtmp'
sort `idmaster'
save, replace

* clean up using data -- make sure no varnames in common so mismatches can be examined
use "`using'", replace
forvalues i=1(1)`nvars' {
	cap confirm var `v`i'' 
	if _rc==0 rename `v`i'' `uprefix'`v`i'' 
}
tempfile u2
sort `idusing'
save "`u2'"

* now back to original dataset and merge results into that, then using dataset into that
restore
sort `idmaster'
merge `idmaster' using "`results'", _merge(`tmrg')
assert `tmrg'!=2
sort `idusing'
merge `idusing' using "`u2'" , nokeep _merge(`_merge')
local fobs=c(N)
qui count if missing(`idusing')
local nomatch=r(N)
forvalues i=1(1)`nvars' {
	cap move  `uprefix'`v`i'' `v`i''  
	cap move  `v`i'' `uprefix'`v`i''   
}
} /* end of quietly block */

format `gen' %5.4f
noi di _n "Added: `idusing'= identifier from `using'   `gen' = matching score"
noi di as res "Observations:  Master N = `mobs'    `using' N= `uobs' "
if "`exclude'"!="" {
	noi di as res "  # Obs after excluding matches in `exclude':  Master = `mobs2match'    `using': `uobs2match' "
}
noi di as res "  Unique Master Cases: matched = " `mobs'-`nomatch'   " (exact = `perfectn'), unmatched = `nomatch'"
end


program define bigram1
version 8.2
*! version 2.2 M Blasnik 19-Sep-2005
syntax varlist (max=1) , gen(str) match(str) 
tempvar slen wink
cap confirm var `gen'
if _rc==0 replace `gen'=0
else gen `gen'=0
local mlen=length("`match'")
gen `slen'=length(`varlist')
local poss=`mlen'-1
if `mlen'>2 {
	forval i=1(1)`poss' {
			qui replace `gen'=`gen'+1 if index(`varlist',substr("`match'",`i',2))>0
	}
	qui replace `gen'=`gen'*2/(`slen'+`mlen'-2)
}

* deal with strings <3 characters
	qui replace `gen'=0 if (`mlen'<3 | `slen'<3) & !index("`match'",`varlist') & !index(`varlist',"`match'") 
  qui replace `gen'=min(`mlen',`slen')/(`mlen'+`slen'-1)  if (`mlen'<3 | `slen'<3) & ( index("`match'",`varlist') | index(`varlist',"`match'") )  	

	* Winkler adjustment: adjusts score upward based on first 1,2,3, or 4 characters matching
	gen byte `wink'=0
	forval i=1(1)4 {
			qui replace `wink'=`wink'+1 if substr(`varlist',1,`i')==substr("`match'",1,`i')
	}
	qui replace `gen'=`gen'+`wink'*(1-`gen')/10
  * make sure exact matches =1 and missing =0 
  qui replace `gen'=1 if `varlist'=="`match'"
	qui replace `gen'=0 if `slen'==0
end
