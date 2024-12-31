capture program drop clrevmatch
program define clrevmatch
version 9.2

*!written by N Wasi: nwasi@umich.edu
*!last modified August 12, 2014

syntax using/ , IDMaster(str) IDUsing(str) varM(str) varU(str) clrev_result(str) clrev_note(str) /*
				*/[reclinkscore(str) rlscoremin(real 0) rlscoremax(real 1) rlscoredisp(str) fast clrev_label(str asis) nobssave(real 5) /*
				*/ replace newfilename(str) saveold]
 
use "`using'"

capture drop __0*

//check if required input variables exist in this dataset
capture confirm variable `idmaster'
if _rc!=0 display "variable `idmaster' not found"

capture confirm variable `idusing'
if _rc!=0 display "variable `idusing' not found"


foreach i of varlist `varM' `varU' {
	capture confirm variable `i'
 	if _rc!=0 display "variable " "`i'" " not found"
}

//check if replace or newfilename is specified
if "`replace'"=="" & "`newfilename'"=="" {
	di as error "Warning: output file will be replaced, add option replace or newfilename"		
	exit
}
else if "`replace'" != "" & "`newfilename'"!= "" {
	di as error "Cannot specify both replace and newfilename options" 
	exit
}
else if "`replace'" =="" & "`newfilename'"!="" {
	capture confirm new file "`newfilename'.dta"
	if _rc!=0 {
		di as error "file `newfilename'.dta already exists."
		exit
	}
	local fname2review "`newfilename'"
}
else local fname2review "`using'"

if "`reclinkscore'" != "" {
	capture confirm variable `reclinkscore'
	if _rc!=0 {
		di as error "variable `reclinkscore' not found"
		exit
	}	
	qui su `reclinkscore'
	local actualmaxrl = `r(max)'
	if "`rlscoredisp'"=="" local rlscoredisp = "on"	
	else if inlist("`rlscoredisp'","on","off")==0 {
		di as error "a valid value for rlscoredisp is on or off"
	exit
	}
}
// if reclinkscore not specified, make sure other score-related options are not specified
else {
	di _newline(2) "Warning: reclinkscore is not specified."
	di "Options related to reclinkscore are disabled."
	local rlscoredisp = "off"
}
	
*default label
local default_label "0 "not a match" 1 "maybe a match" 2 "very likely a match" 3 "definitely a match""
tempvar obsdone
qui gen `obsdone' = 0	
capture confirm variable `clrev_result'
//if variable `clrev_result' exists, check if users want to continue to review or exit?
if _rc==0 {
	di "variable clrev_result exists with the following label"	
	label list `clrev_result'lbl
	
	local ansinvalid = 1
	while `ansinvalid' !=0 {
		di `"press 1 to continue reviewing using this variable"' 	
		di `"press 2 to exit and enter a new variable name for clrev_result"' _request(_ans1)	
		capture assert `ans1'==1|`ans1'==2
		local ansinvalid = _rc
		if `ansinvalid' !=0 di "`ans1' is invalid"
	}
	
	//if continue, extract the saved label
	if `ans1'==1 local clrev_label `"``clrev_result'[strlbl]'"'			
	else if `ans1'==2 exit
	
}

//first time reviewing this dataset
else {
	qui gen `clrev_result' =.
	//use the default label
	if `"`clrev_label'"'=="" {
		label define `clrev_result'lbl `default_label', replace	
		local clrev_label `default_label'	
	}
	//use user's specified label
	else {	
		label define `clrev_result'lbl `clrev_label', replace	
		//check if label is valid
		local nwords : word count `clrev_label'
		if mod(`nwords',2)~=0 {
			di as error "misspecified label values"
			exit
		}
	}
	//label is attached to the variable `clrev_result' as label and character
	label values `clrev_result' `clrev_result'lbl
	char `clrev_result'[strlbl] `"`clrev_label'"'	
}

local nwords : word count `clrev_label'
//make a list of valid label values
foreach j of numlist 1(2)`nwords' {
	local ind`j' : word `j' of `clrev_label'    
	if `j'==1 local labelval `ind`j''
	else local labelval  "`labelval',`ind`j''"
}


if "`ans1'"!="" {
	capture confirm variable _skip`clrev_result'
	if _rc!=0 	qui replace `obsdone' = (inlist(`clrev_result',`labelval')==1)
	else qui replace `obsdone' = (inlist(`clrev_result',`labelval')==1|_skip`clrev_result'==1)
}

//if not specify "fast", check if variable clrev_note exist
if "`fast'"=="" {
	capture confirm variable `clrev_note'	
	if _rc==0 {	
		di _newline(2)"variable clrev_note exists"		
		local ansinvalid = 1
		while `ansinvalid' !=0 {
			di `"press 1 to continue reviewing using this variable to save note"' 
			di `"press 2 to exit and enter a new variable name for clrev_note"' _request(_ans2)
		
			capture assert `ans2'==1|`ans2'==2
			local ansinvalid = _rc
			if `ansinvalid' !=0 di "`ans2' is invalid"
		}
		if `ans2'==2 exit
	}
	else qui gen `clrev_note' =""
} /*end if fast block */


//check if either idmaster or idusing is missing
tempvar invalidrec
local type1: type `idmaster'
local type2: type `idusing'
if strpos("`type1'","str")==1 & strpos("`type2'","str")==1 {
	qui gen `invalidrec' = (`idmaster'=="" | `idusing'=="")
}
else if strpos("`type1'","str")==0 & strpos("`type2'","str")==0 {
	qui gen `invalidrec' = (`idmaster'==. | `idusing'==.)
}
else if strpos("`type1'","str")==0 & strpos("`type2'","str")==1 {
	qui gen `invalidrec' = (`idmaster'==. | `idusing'=="")
}
else {
	qui gen `invalidrec' = (`idmaster'=="" | `idusing'==.)
}

qui count if `invalidrec'==1
if `r(N)' >0 di "`r(N)'" " records with idmaster or idusing missing are ignored."

//check if there exists records with a special situation
//special situation: some obs with score >= rlscoremax and some with score between rlscoremin & rlscoremax
tempvar obs2rev0 obs2rev obsMdone npairs_M npairs_M2rev dforcematch0
tempvar dNotRev0 Anyforcematch Anytorev mmatchcase dRev0

if "`reclinkscore'"!="" {
	if `actualmaxrl' > `rlscoremax' {
		qui gen `obs2rev0' = (`reclinkscore'>= `rlscoremin' & `reclinkscore'<=`rlscoremax') if `invalidrec'==0
		qui gen `dforcematch0' = (`reclinkscore'>`rlscoremax') if `invalidrec'==0
		gsort `idmaster' -`dforcematch0'
		bysort `idmaster': gen `Anyforcematch' = `dforcematch0'[1]
		qui gen `dRev0' = 1-(`obsdone'==1|`obs2rev0' ==0)
		qui gen `dNotRev0' = 1-`dRev0'
		bysort `idmaster': egen `Anytorev' = max(`dRev0')
		qui gen `mmatchcase' = (`Anyforcematch'==1 & `Anytorev'==1)
		drop  `Anytorev'
	}
	*if rlscoremax is not binding, nothing to do with the special situation
	else {
		qui gen `obs2rev0' = (`reclinkscore'>= `rlscoremin' & `reclinkscore'<=`rlscoremax') if `invalidrec'==0
		qui gen `dNotRev0' = (`obsdone'==1|`obs2rev0' ==0)
		qui gen `mmatchcase'=0
		qui gen `dforcematch0'=0	
	}
}
*case where no rlscore specified, review all
else {	
	qui gen `obs2rev0' = 1 if `invalidrec'==0
	qui gen `dNotRev0' = (`obsdone'==1|`obs2rev0' ==0)
	qui gen `mmatchcase'=0
	qui gen `dforcematch0'=0	
}
	
qui count if `obs2rev0'==1 & `invalidrec'==0 
if `r(N)' == 0 {
	if "`reclinkscore'" != "" di "no pairs met specified score criteria"
	else di "no record to review"
	exit
}

sort `idmaster' `dNotRev0'
bysort `idmaster': gen `obsMdone' = `dNotRev0'[1]
	
//check variables' lengths for proper display
local nvarM : word count `varM'
local nvarU : word count `varU'
local nvarmax = max(`nvarM',`nvarU')
getmaxwidth `varM' `varU'

local maxwidthval= r(maxwidthval)
local maxwidthname= r(maxwidthname)
local start_col1 = 2
local start_col2 = `start_col1'+`maxwidthname'+2
local start_col3 = `start_col2'+30

qui count if `mmatchcase'==1
//check # of candidates from each record of the master dataset
bysort `invalidrec' `idmaster': gen `npairs_M' = _N

tempvar npairs_Mforcem  npairs_M2rev
//no special situation
if r(N) ==0 {
	qui gen `obs2rev' = (`obs2rev0'==1 & `obsMdone'~=1 & `invalidrec'==0)	
	local ansMcase = 0
	local dispforcematch =0 	
}

//special situation exists
else {
	tempvar ntmp
	quietly {
		//count number of pairs with score higher than rlscoremax
		bysort `idmaster': egen `npairs_Mforcem' = total(`dforcematch0')
		//count number of pairs with score between rlscoremin &  rlscoremax
		qui gen `obs2rev' = (`obs2rev0'==1 & `obsMdone'~=1 & `invalidrec'==0)
		bysort `idmaster': egen `npairs_M2rev' = total(`obs2rev') 
		bysort `idmaster' : gen `ntmp' = _n if `mmatchcase'==1 
		count if `ntmp'==1 & `mmatchcase'==1
		local n_mmatchcase = r(N)
	}
	
	di _newline(3) "For `n_mmatchcase' master record(s), there are multiple candidates."
	di "Some candidate(s) have scores above " "`rlscoremax'."
	di "Other candidate(s) have scores between `rlscoremin' and `rlscoremax'."
	di "Consider the following record"
	
	tempvar idmcase
	*create id for this first record
	gsort `invalidrec' `idmaster' `mmatchcase' -`dforcematch0' -`reclinkscore'
	qui gen `idmcase' = _n if `mmatchcase'==1
	qui su `idmcase'
	local j = `r(min)'
	drop `idmcase'

	di as text _dup(70) "-"
	di as text _col(`start_col1')"File 1"
	di as text _col(`start_col1')_dup(6) "-"

	displayprofile `varM', start_col1(`start_col1') start_col2(`start_col2') obs(`j')  rlscoredisp(off)

	di as text _dup(70) "-"			
	
	if `npairs_Mforcem'[`j']==1 di "The following candidate has a score higher than `rlscoremax'."
	else if `npairs_Mforcem'[`j']>1 di "The following candidates have scores higher than `rlscoremax'."
	di _col(`start_col1')"File 2"
	local k 0
	while `k'<= `npairs_Mforcem'[`j']-1 {
			di as text _col(`start_col1')_dup(6) "-"
			local thisobs = `j'+`k'
			displayprofile `varU', start_col1(`start_col1') start_col2(`start_col2') obs(`thisobs') rlscoredisp(`rlscoredisp') reclinkscore(`reclinkscore') start_col3(`start_col3')
			local k =`k'+1
	}
	di as text _dup(70) "-"	
	
	if `npairs_M2rev'[`j']==1 di "There is another candidate with a score between `rlscoremin' and `rlscoremax'."	
	else di "There are " `npairs_M2rev'[`j'] " candidates with scores between `rlscoremin' and `rlscoremax'."

	di "Would you like to review such candidate(s)?"
	local ansinvalid = 1
	while `ansinvalid' !=0 {
		di "Please enter:" 
		di "      1 for yes"
		di "      2 for no"_request(_revMcase)
		capture assert `revMcase'==1|`revMcase'==2
		local ansinvalid = _rc
		if `ansinvalid' !=0 di "answer is invalid"
	}
	tempvar skiprev
	qui gen `skiprev'=0
	if `revMcase'==1 {
		di as text _newline(3)
		if `npairs_M2rev'[`j'] > 1 {
			di as text _col(`start_col1')"All candidate profiles will be first displayed."
			di as text _col(`start_col1')"We will then ask you to describe the match quality of each candidate." 
		}
		di as text _dup(70) "-"
		di as text _col(`start_col1')"File 1"
		di as text _col(`start_col1')_dup(6) "-"
			
		displayprofile `varM', start_col1(`start_col1') start_col2(`start_col2') obs(`j')  rlscoredisp(off)

		di as text _dup(70) "-"	
		local k =`npairs_Mforcem'[`j']
		while `k'<= `npairs_Mforcem'[`j']+`npairs_M2rev'[`j']-1 {
			di _col(`start_col1')"File 2"
			di as text _col(`start_col1')_dup(6) "-"
			local thisobs = `j'+`k'								
			displayprofile `varU', start_col1(`start_col1') start_col2(`start_col2') obs(`thisobs') rlscoredisp(`rlscoredisp') reclinkscore(`reclinkscore') start_col3(`start_col3')
			local k =`k'+1			
		}
		di as text _dup(70) "-"	

		local kk=0
		local k =`npairs_Mforcem'[`j']		
		while `k'<= `npairs_Mforcem'[`j']+`npairs_M2rev'[`j']-1 {
			local kk = `kk'+1
			if `npairs_M2rev'[`j']==1 di "How would you describe the pair?" 
			else if `npairs_M2rev'[`j']> 1 {
				di _newline(2) "How would you describe candidate # " `kk' "?" 
				if `npairs_M2rev'[`j']>=4 {
					di as text _col(`start_col1')"File 1"
					di as text _col(`start_col1')_dup(6) "-"
					
					displayprofile `varM', start_col1(`start_col1') start_col2(`start_col2') obs(`j')  rlscoredisp(off)

					di as text _dup(70) "-"
					di as text _col(`start_col1')"File 2"
					di as text _col(`start_col1')_dup(6) "-"
					di as text _col(`start_col1')"candidate # " `k'+1
					local thisobs = `j'+`k'
					displayprofile `varU', start_col1(`start_col1') start_col2(`start_col2') obs(`thisobs') rlscoredisp(`rlscoredisp') reclinkscore(`reclinkscore') start_col3(`start_col3')

				di as text _dup(70) "-"
				} /*end redisplay block*/
			}
			label list `clrev_result'lbl 
			di "please enter a clerical review indicator:" _request(_ans)
				
			local ansinvalid = 1
			while `ansinvalid' !=0 {
				capture assert inlist(`ans',`labelval')
				local ansinvalid = _rc
				if `ansinvalid' !=0 {
					di "`ans' is invalid"
					di "Please enter a valid clerical review indicator:" _request(_ans)
				}	
			}
			local thisobs = `j'+`k'
			qui replace `clrev_result' = `ans' in `thisobs'
			local k =`k'+1		
		} /*end while describe*/
	} /*end if revMcase = 1*/

	else {
		//gen a new variable to indicate that these pairs are skipped b/c a candidate with a higher score is found
		local j1 = `j'+`Npairs_Mforcem'[`j']
		local j2 = `j'+`Npairs_Mforcem'[`j']+`Npairs_M2rev'[`j']-1
		qui gen _skip`clrev_result' = 1 in `j1'/`j2'
		label var _skip`clrev_result' "skip after showing a candidate with score > `rlscmax'"
		qui replace `skiprev' = 1 in `j1'/`j2'
	}
	tempvar djustrev
	local j2 = `j'+`npairs_M'[`j']-1
	qui gen `djustrev' = 1 in `j'/`j2'
	
	//now count if there is any other similar cases; if there is one or more, ask what to do	
	if `n_mmatchcase'>1 {
		di _newline(3) "For future cases with multiple candidates, what would you like to do?"
		di "Please enter:" 
		di "      1 show all candidates with score >= `rlscoremax' and decide whether to review the rest;"
		di "      2 only show candidates with scores between `rlscoremin' and `rlscoremax';"
		di "      3 skip other candidates if a candidate with score > `rlscoremax' is found"_request(_ansMcase)
		
		if `ansMcase'==1 {
			local dispforcematch = 1
			qui replace `obs2rev' = 0 if `djustrev'==1
		}
		else if `ansMcase'==2 {
			local dispforcematch = 0
			qui replace `obs2rev' = 0 if `djustrev'==1
		}
		else if `ansMcase'==3 {
			local dispforcematch = 0	
			qui replace `obs2rev' = 0 if `djustrev'==1|`Anyforcematch'==1
		}
	}
	
	else {
		qui replace `obs2rev' = 0 if `djustrev'==1
		local ansMcase = 0
		local dispforcematch =0 
	}
	capture drop `dRev0' `dNotRev0'	
} //end else mmatchcase==1

qui count if `obs2rev'==1 
if `r(N)' == 0 {
	di "all pairs met criteria have been reviewed."
	exit
}
di _newline(2) "Total # pairs to be reviewed = " r(N)
local npairs2rev = r(N)

//redefine npairs_M2rev based on obs2rev
capture drop `npairs_M2rev'
bysort `idmaster': egen `npairs_M2rev' = total(`obs2rev')
tempvar tmpid
if `ansMcase'==1 {
	//valid record, case force match, case to review to the top
	gsort `invalidrec' `idmaster' `mmatchcase' -`dforcematch0' -`obs2rev' -`reclinkscore'
	//find which obs is the last record	
	qui gen `tmpid' = _n if (`obs2rev'==1|(`mmatchcase'==1 & `djustrev'!=1))
	qui su `tmpid'
	local lastobs = `r(max)'
	local firstobs = `r(min)'	
}
else {
    if "`reclinkscore'"!=""  gsort `invalidrec' `idmaster' -`obs2rev' -`reclinkscore'
	else gsort `invalidrec' `idmaster' -`obs2rev'
	qui gen `tmpid' = _n if `obs2rev'==1
	qui su `tmpid'
	local lastobs = `r(max)'
	local firstobs = `r(min)'
}
drop `tmpid'

//starting review loop
local jj = 0
local j = `firstobs'

tempvar obsleft
qui gen `obsleft' = `obs2rev'

local first = 1
local rev = 0

while `j'<= `lastobs'  {

	if (`obs2rev'[`j'] ==1 | (`mmatchcase'[`j']==1 & `ansMcase'==1 )) {
		
		if `rev'==1 & `first'==0 {
			qui count if `obsleft' == 1
			di _newline(2) "# pairs left to be reviewed = " r(N) "/" "`npairs2rev'"
			local rev = 0
		} /*end if rev, first*/
		
		
		*typical situation; don't display cases with score > rlscmax
		if `dispforcematch'!=1 | `mmatchcase'[`j']==0 {
			if `npairs_M2rev'[`j'] > 1 {
				di as text _col(`start_col1')"There are " `npairs_M2rev'[`j'] " potential candidates for this record."
				di as text _col(`start_col1')"All candidate profiles will be first displayed."
				di as text _col(`start_col1')"We will then ask you to describe the match quality of each candidate." 
			}
			di as text _dup(70) "-"
			di as text _col(`start_col1')"File 1"
			di as text _col(`start_col1')_dup(6) "-"
				
			displayprofile `varM', start_col1(`start_col1') start_col2(`start_col2') obs(`j')  rlscoredisp(off)

			di as text _dup(70) "-"	
			*display all candidates first
			local k = 0
			local kmax = `npairs_M2rev'[`j']-1
			di _col(`start_col1')"File 2"
			while `k'<= `kmax' {		
				di as text _col(`start_col1')_dup(6) "-"
				*if `npairs_M2rev'[`j']==1 di ""
				*else if `npairs_M2rev'[`j']>1 di as text _col(`start_col1')"candidate # " `k'+1
				if `npairs_M2rev'[`j']>1 di as text _col(`start_col1')"candidate # " `k'+1
				local thisobs = `j'+`k'						
				displayprofile `varU', start_col1(`start_col1') start_col2(`start_col2') obs(`thisobs') rlscoredisp(`rlscoredisp') reclinkscore(`reclinkscore') start_col3(`start_col3')
				local k =`k'+1			
			}
			
			di as text _dup(70) "-"	
			*ask to evaluate each candidate
		    local k = 0
			while `k'<= `kmax' {
				local kk = `k'+1
				if `npairs_M2rev'[`j']==1 di "How would you describe the pair?" 
				else if `npairs_M2rev'[`j']> 1 	di _newline(2) "How would you describe candidate # " `kk' "?" 
				/*redisplay if #candidate = 4 or more*/
				if `npairs_M2rev'[`j']>=4 {
					di as text _col(`start_col1')"File 1"
					di as text _col(`start_col1')_dup(6) "-"
					displayprofile `varM', start_col1(`start_col1') start_col2(`start_col2') obs(`j')  rlscoredisp(off)
			
					di as text _dup(70) "-"
					di as text _col(`start_col1')"File 2"
					di as text _col(`start_col1')_dup(6) "-"
					di as text _col(`start_col1')"candidate # " `k'+1
					local thisobs = `j'+`k'
				
					displayprofile `varU', start_col1(`start_col1') start_col2(`start_col2') obs(`thisobs') rlscoredisp(`rlscoredisp') reclinkscore(`reclinkscore') start_col3(`start_col3')
					di as text _dup(70) "-"
				} /*end redisplay block*/
					
				label list `clrev_result'lbl 
				di "please enter a clerical review indicator:" _request(_ans)
				
				local ansinvalid = 1
				while `ansinvalid' !=0 {
					capture assert inlist(`ans',`labelval')
					local ansinvalid = _rc
					if `ansinvalid' !=0 {
						di "`ans' is invalid"
						di "Please enter a valid clerical review indicator:" _request(_ans)
					}	
				}
				local thisobs = `j'+`k'
				qui replace `clrev_result' = `ans' in `thisobs'
				local k =`k'+1		
			} /*end while k*/

		} /*end if not display dforcematch*/
		
		*special case - also display cases with score>rlscmax, but don't ask to review	
		else if `dispforcematch'==1 & `mmatchcase'[`j']==1 {
			di as text _dup(70) "-"
			di as text _col(`start_col1')"File 1"
			di as text _col(`start_col1')_dup(6) "-"
			
			displayprofile `varM', start_col1(`start_col1') start_col2(`start_col2') obs(`j')  rlscoredisp(off)

			local k 0
			di as text _dup(70) "-"
			
			if `npairs_Mforcem'[`j']==1 di "The following candidate has a score higher than `rlscoremax'."
			else if `npairs_Mforcem'[`j']>1 di "The following candidates have scores higher than `rlscoremax'."

			di _col(`start_col1')"File 2"			
			while `k'<= `npairs_Mforcem'[`j']-1 {
								
				di as text _col(`start_col1')_dup(6) "-"
				local thisobs = `j'+`k'
				displayprofile `varU', start_col1(`start_col1') start_col2(`start_col2') obs(`thisobs') rlscoredisp(`rlscoredisp') reclinkscore(`reclinkscore') start_col3(`start_col3')

				local k =`k'+1
			} /*end while k*/
			di as text _dup(70) "-"
			if `npairs_M2rev'[`j']==1 di "There is another candidate with a score between `rlscoremin' and `rlscoremax'."	
			else di "There are " `npairs_M2rev'[`j'] " candidates with scores between `rlscoremin' and `rlscoremax'."
			di "Would you like to review such candidate(s)?"
			
			local ansinvalid = 1
			while `ansinvalid' !=0 {
				di "Please enter:" 
				di "      1 for yes"
				di "      2 for no"_request(_revMcase)
				capture assert `revMcase'==1|`revMcase'==2
				local ansinvalid = _rc
				if `ansinvalid' !=0 di "answer is invalid"
			}
			
			if `revMcase'==1 {
				di as text "{hline 70}"	
				di _col(`start_col1')"File 1"
				di as text _col(`start_col1')_dup(6) "-"
				displayprofile `varM', start_col1(`start_col1') start_col2(`start_col2') obs(`j')  rlscoredisp(off)
				di as text _dup(70) "-"
				
				local k =`npairs_Mforcem'[`j']				
				
				while `k'<= `npairs_Mforcem'[`j']+`npairs_M2rev'[`j']-1 {
					di _col(`start_col1')"File 2"
					di as text _col(`start_col1')_dup(6) "-"
					local thisobs = `j'+`k'							
					displayprofile `varU', start_col1(`start_col1') start_col2(`start_col2') obs(`thisobs') rlscoredisp(`rlscoredisp') reclinkscore(`reclinkscore') start_col3(`start_col3')
					local k =`k'+1			
				}
				di as text _dup(70) "-"	

				local kk=0
				local k =`npairs_Mforcem'[`j']		
				while `k'<= `npairs_Mforcem'[`j']+`npairs_M2rev'[`j']-1 {
					local kk = `kk'+1
					if `npairs_M2rev'[`j']==1 di "How would you describe the pair?" 
					//redisplay when Npairs_M2rev>=4
					else if `Npairs_M2rev'[`j']> 1 di _newline(2) "How would you describe candidate # " `kk' "?" 

					label list `clrev_result'lbl 
					di "please enter a clerical review indicator:" _request(_ans)
				
					local ansinvalid = 1
					while `ansinvalid' !=0 {
						capture assert inlist(`ans',`labelval')
						local ansinvalid = _rc
						if `ansinvalid' !=0 {
							di "`ans' is invalid"
							di "Please enter a valid clerical review indicator:" _request(_ans)
						}	
					} /*end while ansinvalid*/
					
					local thisobs = `j'+`k'
					qui replace `clrev_result' = `ans' in `thisobs'
				
					local k =`k'+1		
				} /*end while describe*/
				
			}/*end if revMcase=1*/
			else {
				local j1 = `j'+`npairs_Mforcem'[`j']
				local j2 = `j'+`npairs_Mforcem'[`j']+`npairs_M2rev'[`j']-1
				capture qui gen _skip`clrev_result' = 1 in `j1'/`j2'
				if _rc!=0  qui replace _skip`clrev_result' = 1 in `j1'/`j2'
				qui replace `skiprev' = 1 in `j1'/`j2'
			}
		} /*end else if `dispforcematch'==1 & `mmmatchcase'==1*/
		//------------------------------------------------------------------------------------------------//	
			
		if "`fast'"=="" {
			di `"Press c if need to go back and change your answer"' 
			di `"      n if any note to enter? "' 
			di `"otherwise, press enter to continue"' _request(_ans2)
		
			if "`ans2'"=="n" {
				di `"please enter note"'_request(_revnote)
				qui replace `clrev_note' = "`revnote'" in `j'
			}
		
			if "`ans2'"!="c" {
				local ++jj	
					if mod(`jj',`nobssave')==0 {
						di `"press q to save and quit"' 
						di `"press any other key to save and continue"' _request(cont)
						if "`saveold'"=="" 	save `fname2review', replace
						else saveold `fname2review', replace
						if "$cont"=="q" exit		
					} //if mod
			
					if `j'== `lastobs' {
					save `fname2review', replace
					}	
			} 
		} 		
		// if fast is specified, skip the confirmation/go back step
		else {
				local ++jj	
					if mod(`jj',`nobssave')==0 {
						di `"press q to save and quit"' 
						di `"press any other key to save and continue"' _request(cont)
						if "`saveold'"=="" 	save `fname2review', replace
						else saveold `fname2review', replace
						if "$cont"=="q" exit		
					} //if mod
					
					if `j'== `lastobs' {
						if "`saveold'"=="" 	save `fname2review', replace
						else saveold `fname2review', replace
					}	
		}		
		
		if "`ans2'"!="c" {
			if `ansMcase'==1 local j1 = `j'+`npairs_Mforcem'[`j']
			else local j1 = `j'
			local jk = `j1'+`npairs_M2rev'[`j']-1
			qui replace `obsleft' = 0  in `j1'/`jk'
			
			local rev = 1
			local first = 0
		}
		
	} //if obs2rev==1|mmatchcase==1
	
	//move to the next idmaster (include cases not being reviewed)
	if "`ans2'"!="c" {
		local j = `j'+`npairs_M'[`j']	
	} 
	
} //while loop

end

//-----------end main program-------------//
//getmaxwidth : a helper program

capture program drop getmaxwidth
program define getmaxwidth, rclass
syntax varlist

tempvar widthold namelengthold
qui gen `widthold' = 0
qui gen `namelengthold'=0

foreach j of varlist `varlist' {
   tempvar width_`j' namelength_`j' tmp`j'
   
   cap confirm string var `j'
		
   if _rc==0 {
		qui egen `width_`j'' = max(length(`j')) 
   }
   else {
		qui egen `tmp`j''= max(`j')
		qui gen `width_`j'' = mod(`tmp`j'',10)
   }
   
   qui gen `namelength_`j'' = length("`j'")
   qui replace `widthold' = `width_`j'' if `width_`j'' > `widthold'
   qui replace `namelengthold' = `namelength_`j'' if `namelength_`j'' > `namelengthold'
   
}

return scalar maxwidthval = `widthold'
return scalar maxwidthname = `namelengthold'

end

//------------------------------------------//
//displayprofile: a help program
capture program drop displayprofile
program define displayprofile
syntax varlist, start_col1(real) start_col2(real) obs(real) [rlscoredisp(str) reclinkscore(str) start_col3(real 0)]

local nvar = wordcount("`varlist'")
local i 1

if "`rlscoredisp'"=="off" {
	while `i' <= `nvar' {
		local x: word `i' of `varlist'
		di as text _col(`start_col1')"`x':" as result _col(`start_col2')`x'[`obs']  		
		local i = `i'+1
	}
}

else if "`rlscoredisp'"=="on" {
	while `i' <= `nvar' {
		local x: word `i' of `varlist'	
		if `i'<`nvar' {
			di as text _col(`start_col1')"`x':" as result _col(`start_col2')`x'[`obs']
		}
		else {
			di as text _col(`start_col1')"`x':" as result _col(`start_col2')`x'[`obs']
			di as text _col(`start_col3')"match score: "round(`reclinkscore'[`obs'],.001)
		}
		local i = `i'+1
	}			
}
	
end


