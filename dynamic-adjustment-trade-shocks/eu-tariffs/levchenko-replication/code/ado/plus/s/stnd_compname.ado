capture program drop stnd_compname
program define stnd_compname
version 9.2

*!written by N Wasi: nwasi@umich.edu
*!last modified August 28, 2015: modified stnd_NESW to stnd_nesw (and also for the pattern file)

syntax varlist(max=1) [if] [in], Generate(str) [Patpath(str)]
di "stnd_compname version p1.3"

confirm new var `generate'

if "`patpath'"~="" {
	local mypath "`patpath'"
}
else {
	local dir : sysdir PLUS
	local mypath "`dir'p/"
}


checkpatternfiles, mypath(`mypath')

if `r(found)'==0 {
	di as error "No pattern file found in `mypath'"
	exit
}
else di "pattern files from `mypath'"


confirm new var `generate'	
//output 5 new variables: officialname dbaname fkaname entitytype attn_name

tempvar empname_stn name1 dba_name fka_name attn_name entitytype aggname  
tempvar name11 dba_name1 fka_name1 name1_entitytype dba_name_entitytype fka_name_entitytype stn_name

marksample touse, strok

//1: basic clean up
qui gen `empname_stn' = upper(`varlist') if `touse'
qui replace `empname_stn' = trim(itrim(`empname_stn')) if `touse'


local msg1 = "on"
//2: parse name component 
//input = name, output = {name removing other components, dba_name, fka_name, attn_name}
parsing_namefield `empname_stn' if `touse', gen(`name1' `dba_name' `fka_name' `attn_name') patpath(`mypath') warningmsg(`msg1')

//3: standardizing words in each type of names
foreach k of varlist `name1' `dba_name' `fka_name' {
	
	// remove/replace special characters
	stnd_specialchar `k' if `touse', type(name) patpath(`mypath') warningmsg(`msg1')	
	// substitute a word by its standardized form
	stnd_entitytype `k' if `touse', patpath(`mypath') warningmsg(`msg1')	
	stnd_commonwrd_name `k' if `touse', patpath(`mypath') warningmsg(`msg1')	
	stnd_commonwrd_all `k' if `touse', patpath(`mypath') warningmsg(`msg1')	
	stnd_numbers `k' if `touse', patpath(`mypath') warningmsg(`msg1')	
	stnd_nesw `k' if `touse', patpath(`mypath') warningmsg(`msg1')	
		
	// standardizing by replacing words conditional on it's not a stand-alone word 
	// e.g., "THE" could be an abbreviation; or "AND" could be a typo from "RAND"
	stnd_smallwords `k' if `touse', patpath(`mypath') warningmsg(`msg1')	
	local msg1 = "off"
}


local msg1 = "on"

//parse entitytype to separate fields and aggregate acronyms in both fields
parsing_entitytype `name1' if `touse', gen(`name11' `name1_entitytype') patpath(`mypath') warningmsg(`msg1')
agg_acronym `name11' if `touse', gen(`aggname') 
qui replace `name11' = `aggname' if `aggname'~=`name11' & `touse'
drop `aggname'	

agg_acronym `name1_entitytype' if `touse', gen(`aggname') 
qui replace `name1_entitytype' = `aggname' if `aggname'~=`name1_entitytype' & `touse'
drop `aggname'

local msg1 = "off"	
qui count if `touse'== 1 & `dba_name' != "" 

if r(N)~= 0 {
	parsing_entitytype `dba_name' if `touse' & `dba_name'!="", gen(`dba_name1' `dba_name_entitytype') patpath(`mypath') warningmsg(`msg1')
	agg_acronym `dba_name1' if `touse', gen(`aggname') 	
	qui replace `dba_name1' = `aggname' if `aggname'~=`dba_name1' & `touse' & `dba_name'!=""
	drop `aggname'	
	
    qui count if `touse' & `dba_name_entitytype' !=""
	if r(N)!=0 {
	agg_acronym `dba_name_entitytype' if `touse' , gen(`aggname') 
	qui replace `dba_name_entitytype' = `aggname' if `aggname'~=`dba_name_entitytype' & `touse' 
	drop `aggname'
	}

}
else {
	qui gen `dba_name1' = `dba_name'
	qui gen `dba_name_entitytype' = ""
}

//use entity type from dba_name if entity type from official name does not exist
qui gen `entitytype' = `name1_entitytype' if `touse'
qui replace `entitytype' = `dba_name_entitytype' if `entitytype'=="" & `dba_name_entitytype'~="" & `touse'

tokenize `generate'
local num_output : word count `generate'

if `num_output' >=1 qui gen `1'=`name11' if `touse'
if `num_output' >=2 qui gen `2'=`dba_name1' if `touse'
if `num_output' >=3 qui gen `3'=`fka_name' if `touse'
if `num_output' >=4 qui gen `4'=`entitytype' if `touse'
if `num_output' ==5 qui gen `5'=`attn_name' if `touse'

label var `1' "official name"
capture label var `2' "trade name"
capture label var `3' "former name"
capture label var `4' "entity type"
capture label var `5' "attention person"


end

*-----------------a helper to check pattern file-----------------*
capture program drop checkpatternfiles
program define checkpatternfiles, rclass

syntax , mypath(str)

//check if there is any pattern at all, exit if no pattern
local anypatternfile = 0
capture qui findfile P10_namecomp_patterns.csv, path(`mypath')
	if _rc==0 local anypatternfile = 1
	else capture qui findfile P21_spchar_specialcases.csv, path(`mypath')
		if _rc==0 local anypatternfile = 1
		else capture qui findfile P22_spchar_remove.csv, path(`mypath')
			if _rc==0 local anypatternfile = 1			
			else capture qui findfile P23_spchar_rplcwithspace.csv, path(`mypath')
				if _rc==0 local anypatternfile = 1			
				else capture qui findfile P30_std_entity.csv, path(`mypath')
					if _rc==0 local anypatternfile = 1			
					else capture qui findfile P40_std_commonwrd_name.csv, path(`mypath')
						if _rc==0 local anypatternfile = 1			
						else capture qui findfile P50_std_commonwrd_all.csv, path(`mypath')
							if _rc==0 local anypatternfile = 1			
							else capture qui findfile P60_std_numbers.csv, path(`mypath')
								if _rc==0 local anypatternfile = 1			
								else capture qui findfile P70_std_nesw.csv, path(`mypath')
									if _rc==0 local anypatternfile = 1								
									else capture qui findfile P81_std_smallwords_all.csv, path(`mypath')
										if _rc==0 local anypatternfile = 1							
										else capture qui findfile P90_entity_patterns.csv, path(`mypath')
											if _rc==0 local anypatternfile = 1								
	
return scalar found = `anypatternfile'

end

