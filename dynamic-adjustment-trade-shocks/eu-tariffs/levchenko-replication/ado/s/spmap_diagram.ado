*! -spmap_diagram-: Auxiliary program for -spmap-                              
*! Version 1.3.3 - 09 January 2018 - StataCorp edit for stroke align           
*! Version 1.3.2 - 19 June 2017 - StataCorp edit to plot line in diagram
*! Version 1.3.1 - 29 March 2017 - StataCorp edit to tempfile macros           
*! Version 1.3.0 - 13 March 2017                                               
*! Version 1.2.0 - 14 March 2008                                               
*! Version 1.1.0 - 7 May 2007                                                  
*! Version 1.0.0 - 7 December 2006                                             
*! Author: Maurizio Pisati                                                     
*! Department of Sociology and Social Research                                 
*! University of Milano Bicocca (Italy)                                        
*! maurizio.pisati@unimib.it                                                   




*  ----------------------------------------------------------------------------
*  1. Define program                                                           
*  ----------------------------------------------------------------------------

program spmap_diagram, rclass
version 9.2




*  ----------------------------------------------------------------------------
*  2. Define syntax                                                            
*  ----------------------------------------------------------------------------

syntax, [Data(string)]            ///
        [Select(string asis)]     ///
        [BY(string)]              ///
                                  ///
        [Xcoord(string)]          ///
        [Ycoord(string)]          ///
        [Variables(string)]       ///
        [Type(string)]            ///
                                  ///
        [PROPortional(string)]    ///
        [PRange(string)]          ///
                                  ///
        [Range(string)]           ///
        [REFVal(string)]          ///
        [REFWeight(string)]       ///
        [REFColor(string asis)]   ///
        [REFSize(string)]         ///
                                  ///
        [SIze(string)]            ///
        [FColor(string asis)]     ///
        [OColor(string asis)]     ///
        [OSize(string)]           ///
        [OAlign(string asis)]     ///
                                  ///
        [LEGENDA(string)]         ///
        [LEGTitle(string asis)]   ///
        [LEGShow(string)]         ///
        [LEGCount]
      



*  ----------------------------------------------------------------------------
*  3. Check syntax                                                             
*  ----------------------------------------------------------------------------

/* Preserve data */
preserve

/* Check and open dataset */
if ("`data'" != "") {
   if (substr(reverse("`data'"),1,4) != "atd.") {
      local data "`data'.dta"
   }
   capture confirm file "`data'"
   if _rc {
      di as err "{p}Problem with option {bf:{ul:dia}gram()}: file "      ///
                "{bf:`data'} specified in suboption {bf:{ul:d}ata()} "   ///
                "not found{p_end}"
      exit 601
   }
   use "`data'", clear
}

/* Select relevant records */
if (`"`select'"' != "") {
   cap `select'
   if _rc {
      di as err "{p}Problem with option {bf:{ul:dia}gram()}: suboption "   ///
                "{bf:{ul:s}elect()} specified incorrectly{p_end}"
      exit 198
   }
}

/* Check option by() */
if ("`by'" != "") {
   cap unab by : `by'
   if (_rc == 111) {
      di as err "{p}Problem with option {bf:{ul:dia}gram()}: "   ///
                "variable {bf:`by'} specified in suboption "     ///
                "{bf:{ul:by}()} not found{p_end}"
      exit 111
   }
   if (_rc == 198) {
      di as err "{p}Problem with option {bf:{ul:dia}gram()}: "   ///
                "string {bf:`by'} specified in suboption "       ///
                "{bf:{ul:by}()} is not a valid variable "        ///
                "name{p_end}"
      exit 198
   }
   local NW : word count `by'
   if (`NW' > 1) {
      di as err "{p}Problem with option {bf:{ul:dia}gram()}: "   ///
                "suboption {bf:{ul:by}()} accepts only one "     ///
                "variable{p_end}"
      exit 198 
   }
}

/* Check option xcoord() */
if ("`xcoord'" == "") {
   di as err "{p}Problem with option {bf:{ul:dia}gram()}: suboption "   ///
             "{bf:{ul:x}coord()} is required{p_end}"
   exit 198 
}
cap unab xcoord : `xcoord'
if (_rc == 111) {
   di as err "{p}Problem with option {bf:{ul:dia}gram()}: "     ///
             "variable {bf:`xcoord'} specified in suboption "   ///
             "{bf:{ul:x}coord()} not found{p_end}"
   exit 111
}
if (_rc == 198) {
   di as err "{p}Problem with option {bf:{ul:dia}gram()}: "   ///
             "string {bf:`xcoord'} specified in suboption "   ///
             "{bf:{ul:x}coord()} is not a valid variable "    ///
             "name{p_end}"
   exit 198
}
local NW : word count `xcoord'
if (`NW' > 1) {
   di as err "{p}Problem with option {bf:{ul:dia}gram()}: "     ///
             "suboption {bf:{ul:x}coord()} accepts only one "   ///
             "variable{p_end}"
   exit 198 
}
cap confirm numeric variable `xcoord', exact
if _rc {
   di as err "{p}Problem with option {bf:{ul:dia}gram()}: "   ///
             "suboption {bf:{ul:x}coord()} accepts only "     ///
             "numeric variables{p_end}"
   exit 7 
}

/* Check option ycoord() */
if ("`ycoord'" == "") {
   di as err "{p}Problem with option {bf:{ul:dia}gram()}: suboption "   ///
             "{bf:{ul:y}coord()} is required{p_end}"
   exit 198 
}
cap unab ycoord : `ycoord'
if (_rc == 111) {
   di as err "{p}Problem with option {bf:{ul:dia}gram()}: "     ///
             "variable {bf:`ycoord'} specified in suboption "   ///
             "{bf:{ul:y}coord()} not found{p_end}"
   exit 111
}
if (_rc == 198) {
   di as err "{p}Problem with option {bf:{ul:dia}gram()}: "   ///
             "string {bf:`ycoord'} specified in suboption "   ///
             "{bf:{ul:y}coord()} is not a valid variable "    ///
             "name{p_end}"
   exit 198
}
local NW : word count `ycoord'
if (`NW' > 1) {
   di as err "{p}Problem with option {bf:{ul:dia}gram()}: "     ///
             "suboption {bf:{ul:y}coord()} accepts only one "   ///
             "variable{p_end}"
   exit 198 
}
cap confirm numeric variable `ycoord', exact
if _rc {
   di as err "{p}Problem with option {bf:{ul:dia}gram()}: "   ///
             "suboption {bf:{ul:y}coord()} accepts only "     ///
             "numeric variables{p_end}"
   exit 7 
}

/* Check option variables() */
if ("`variables'" == "") {
   di as err "{p}Problem with option {bf:{ul:dia}gram()}: suboption "   ///
             "{bf:{ul:v}ariables()} is required{p_end}"
   exit 198 
}
cap unab variables : `variables'
if (_rc == 111) {
   di as err "{p}Problem with option {bf:{ul:dia}gram()}: "           ///
             "variable(s) {bf:`variables'} specified in suboption "   ///
             "{bf:{ul:v}ariables()} not found{p_end}"
   exit 111
}
if (_rc == 198) {
   di as err "{p}Problem with option {bf:{ul:dia}gram()}: "      ///
             "string {bf:`variables'} specified in suboption "   ///
             "{bf:{ul:v}ariables()} does not contain valid "     ///
             "variable names{p_end}"
   exit 198
}
local NVAR : word count `variables'
cap confirm numeric variable `variables', exact
if _rc {
   di as err "{p}Problem with option {bf:{ul:dia}gram()}: "    ///
             "suboption {bf:{ul:v}ariables()} accepts only "   ///
             "numeric variables{p_end}"
   exit 7 
}

/* Check option type() */
if (`NVAR' > 1) local type "pie"
else {
   if ("`type'" != "") {
	   local LIST "frect pie"
	   local EXIST : list posof "`type'" in LIST
	   if !`EXIST' {
         di as err "{p}Problem with option {bf:{ul:dia}gram()}: "   ///
                   "suboption {bf:{ul:t}ype()} accepts only one "   ///
                   "of the following keywords: {bf:`LIST'}{p_end}"
		   exit 198
      }
   }
   else {
      local type "frect"
   }
}

/* Check option proportional() */
if ("`proportional'" != "") {
   cap unab proportional : `proportional'
   if (_rc == 111) {
      di as err "{p}Problem with option {bf:{ul:dia}gram()}: "   ///
                "variable {bf:`proportional'} specified in "     ///
                "suboption {bf:{ul:prop}ortional()} not "        ///
                "found{p_end}"
      exit 111
   }
   if (_rc == 198) {
      di as err "{p}Problem with option {bf:{ul:dia}gram()}: "   ///
                "string {bf:`proportional'} specified in "       ///
                "suboption {bf:{ul:prop}ortional()} is not "     ///
                "a valid variable name{p_end}"
      exit 198
   }
   local NW : word count `proportional'
   if (`NW' > 1) {
      di as err "{p}Problem with option {bf:{ul:dia}gram()}: "   ///
                "suboption {bf:{ul:prop}ortional()} accepts "    ///
                "only one variable{p_end}"
      exit 198
   }
   cap confirm numeric variable `proportional', exact
   if _rc {
      di as err "{p}Problem with option {bf:{ul:dia}gram()}: "   ///
                "suboption {bf:{ul:prop}ortional()} accepts "    ///
                "only numeric variables{p_end}"
      exit 7 
   }
}

/* Check option prange() */
if ("`prange'" != "") & ("`proportional'" != "") {
   local NW : word count `prange'
   if (`NW' != 2) {
      di as err "{p}Problem with option {bf:{ul:dia}gram()}: "     ///
                "suboption {bf:{ul:pr}ange()} requires exactly "   ///
                "2 arguments{p_end}"
      exit 198
   }
   foreach W in `prange' {
      cap confirm number `W'
      if _rc {
         di as err "{p}Problem with option {bf:{ul:dia}gram()}: "   ///
                   "suboption {bf:{ul:pr}ange()} accepts only "     ///
                   "numbers{p_end}"
         exit 7 
      }
   }
   local N1 : word 1 of `prange'
   local N2 : word 2 of `prange'
   if (`N1' == `N2') {
         di as err "{p}Problem with option {bf:{ul:dia}gram()}: "   ///
                   "the two numbers specified in suboption      "   ///
                   "{bf:{ul:pr}ange()} must be different{p_end}"
         exit 198
   }
   local MIN = min(`N1', `N2')
   local MAX = max(`N1', `N2')
   local prange "`MIN' `MAX'"
}

/* Check option range() */
if ("`range'" != "") & ("`type'" == "frect") {
   local NW : word count `range'
   if (`NW' != 2) {
      di as err "{p}Problem with option {bf:{ul:dia}gram()}: "    ///
                "suboption {bf:{ul:r}ange()} requires exactly "   ///
                "2 arguments{p_end}"
      exit 198
   }
   foreach W in `range' {
      cap confirm number `W'
      if _rc {
         di as err "{p}Problem with option {bf:{ul:dia}gram()}: "   ///
                   "suboption {bf:{ul:r}ange()} accepts only "      ///
                   "numbers{p_end}"
         exit 7 
      }
   }
   local N1 : word 1 of `range'
   local N2 : word 2 of `range'
   if (`N1' == `N2') {
         di as err "{p}Problem with option {bf:{ul:dia}gram()}: "   ///
                   "the two numbers specified in suboption      "   ///
                   "{bf:{ul:r}ange()} must be different{p_end}"
         exit 198
   }
   local MIN = min(`N1', `N2')
   local MAX = max(`N1', `N2')
   local range "`MIN' `MAX'"
}

/* Check option refval() */
if ("`refval'" != "") & ("`type'" == "frect") {
   cap confirm number `refval'
   if _rc {
   	local LIST "mean median"
	   local EXIST : list posof "`refval'" in LIST
	   if !`EXIST' {
         di as err "{p}Problem with option {bf:{ul:dia}gram()}: "   ///
                   "suboption {bf:{ul:refv}al()} accepts only "     ///
                   "numbers or one of the following keywords: "     ///
                   "{bf:`LIST'}{p_end}"
		   exit 198 
	   }
	}
	else local RVTYPE "NUM"
}

/* Check option refweight() */
if ("`refweight'" != "") & ("`type'" == "frect") {
   cap unab refweight : `refweight'
   if (_rc == 111) {
      di as err "{p}Problem with option {bf:{ul:dia}gram()}: "   ///
                "variable {bf:`refweight'} specified in "        ///
                "suboption {bf:{ul:refw}eight()} not "           ///
                "found{p_end}"
      exit 111
   }
   if (_rc == 198) {
      di as err "{p}Problem with option {bf:{ul:dia}gram()}: "   ///
                "string {bf:`refweight'} specified in "          ///
                "suboption {bf:{ul:refw}eight()} is not "        ///
                "a valid variable name{p_end}"
      exit 198
   }
   local NW : word count `refweight'
   if (`NW' > 1) {
      di as err "{p}Problem with option {bf:{ul:dia}gram()}: "    ///
                "suboption {bf:{ul:refw}eight()} accepts only "   ///
                "one variable{p_end}"
      exit 198 
   }
   cap confirm numeric variable `refweight', exact
   if _rc {
      di as err "{p}Problem with option {bf:{ul:dia}gram()}: "   ///
                "suboption {bf:{ul:refw}eight()} accepts "       ///
                "only numeric variables{p_end}"
      exit 7 
   }
}

/* Check option size() */
if ("`size'" != "") {
   local NW : word count `size'
   if (`NW' != 1) {
      di as err "{p}Problem with option {bf:{ul:dia}gram()}: "   ///
                "suboption {bf:{ul:si}ze()} accepts only 1 "     ///
                "argument{p_end}"
      exit 198
   }
   cap confirm number `size'
   if _rc {
      di as err "{p}Problem with option {bf:{ul:dia}gram()}: "   ///
                "suboption {bf:{ul:si}ze()} accepts only "       ///
                "numbers{p_end}"
      exit 7 
   }
   if (`size' <= 0) {
         di as err "{p}Problem with option {bf:{ul:dia}gram()}: "   ///
                   "the argument of suboption {bf:{ul:si}ze()} "    ///
                   "must be >0{p_end}"
         exit 198
   }
}

/* Check option legenda() */
if ("`legenda'" != "") {
   local LIST "on off"
   local EXIST : list posof "`legenda'" in LIST
   if !`EXIST' {
      di as err "{p}Problem with option {bf:{ul:dia}gram()}: "      ///
                "suboption {bf:{ul:legenda}()} accepts only one "   ///
                "of the following keywords: {bf:`LIST'}{p_end}"
      exit 198 
   }
}

/* Check option legshow() */
if ("`legenda'" == "on") & ("`legshow'" != "") {
   cap numlist "`legshow'"
   if _rc {
      di as err "{p}Problem with option {bf:{ul:dia}gram()}: "   ///
                "invalid numlist in suboption "                  ///
                "{bf:{ul:legs}how()}{p_end}"
      exit 121
   }
}

/* Marksample */
marksample TOUSE
markout `TOUSE' `variables' `xcoord' `ycoord'
if ("`by'" != "") markout `TOUSE' `by'
if ("`proportional'" != "") markout `TOUSE' `proportional'
if ("`refweight'" != "" & "`type'" == "frect") {
   markout `TOUSE' `refweight'
}
qui count if `TOUSE' 
if (r(N) == 0) error 2000




*  ----------------------------------------------------------------------------
*  4. Define basic objects                                                     
*  ----------------------------------------------------------------------------

/* Select relevant observations */
qui keep if `TOUSE'

/* Count observations */
qui count
local OBS = r(N)


/* Set defaults relevant only when proportional != "" */
if ("`proportional'" != "") {

   /* Set default range for weighting variable normalization */
   if ("`prange'" == "") {
      qui su `proportional', meanonly
      local prange "0 `r(max)'"
   }

   /* Set min-max values for weighting variable normalization */
   local PMIN : word 1 of `prange'
   local PMAX : word 2 of `prange'

/* End */
}


/* Set defaults relevant only when type(frect) */
if ("`type'" == "frect") {

   /* Set default range for attribute variable normalization */
   if ("`range'" == "") {
      qui su `variables', meanonly
      local range "0 `r(max)'"
   }

   /* Set min-max values for attribute variable normalization */
   local VMIN : word 1 of `range'
   local VMAX : word 2 of `range'

   /* Set default reference value */
   if ("`refval'" == "") local refval "mean"

   /* Set STAT corresponding to specified reference value */
   if ("`refval'" == "mean") local STAT "mean"
   if ("`refval'" == "median") local STAT "p50"

   /* Set reference weight */
   if ("`refweight'" != "") local REFWEIGHT "[aweight = `refweight']"

   /* Set default reference line color */
   if (`"`refcolor'"' == "") local refcolor "black"

   /* Set default reference line thickness */
   if (`"`refsize'"' == "") local refsize "medium"

/* End */
}


/* Set default baseline size */
if ("`size'" == "") local size = 1

/* Set default fill color */
local fcolor_d "black"
if (`NVAR' == 1) {
   if (`"`fcolor'"' == "") local fcolor "`fcolor_d' ..."
}
else {
   if (`"`fcolor'"' == "") {
      local fcolor "red blue orange green lime navy sienna ltblue cranberry"
      local fcolor "`fcolor' emerald eggshell magenta olive brown yellow"
      local fcolor "`fcolor' dkgreen"
   }
}

/* Set default outline color */
local ocolor_d "black"
if (`"`ocolor'"' == "") local ocolor "`ocolor_d' ..."

/* Set default outline thickness */
local osize_d "thin"
if ("`osize'" == "") local osize "`osize_d' ..."

/* Set default outline thickness */
local oalign_d "center"
if ("`oalign'" == "") local oalign "`oalign_d' ..."


/* Set default legend */
if ("`legenda'" == "") local legenda "off"

/* Set legend title when legtitle(varlab) */
if ("`legenda'" == "on") & (`NVAR' == 1) & (`"`legtitle'"' == "varlab") {
   local legtitle : variable label `variables'
   if (`"`legtitle'"' == "") local legtitle "`variables'"
}




*  ----------------------------------------------------------------------------
*  5. Create working dataset and return info of interest: framed rect. chart   
*  ----------------------------------------------------------------------------

/* Start condition */
if ("`type'" == "frect") {


/* Housekeeping */
cap drop __DIA*

/* Compute reference value */
if ("`RVTYPE'" == "NUM") local RV = `refval'
else {
   qui su `variables' `REFWEIGHT', detail
   local RV = (r(`STAT') - `VMIN') / (`VMAX' - `VMIN')
}

/* Generate coordinate variables */
tempvar X Y
qui gen `X' = `xcoord'
qui gen `Y' = `ycoord'

/* Generate main variable (normalized) */
tempvar V
qui clonevar `V' = `variables'
qui replace `V' = (`V' - `VMIN') / (`VMAX' - `VMIN')
local VARLAB : variable label `V'
if (`"`VARLAB'"' == "") local VARLAB "`V'"

/* Generate group variable */
tempvar G
if ("`by'" == "") qui gen  `G' = 1
if ("`by'" != "") qui egen `G' = group(`by'), label
qui tab `G'
local NG = r(r)

/* Count objects */
if ("`legenda'" == "on") & ("`legcount'" != "") {
   forval i = 1/`NG' {
      qui count if `G' == `i'
      local COUNT "`COUNT'`r(N)' "
   }
}

/* Set list of available color palettes */
local PALETTE "`PALETTE' Accent Blues BrBG BuGn BuPu Dark2 GnBu Greens Greys"
local PALETTE "`PALETTE' OrRd Oranges PRGn Paired Pastel1 Pastel2 PiYG PuBu"
local PALETTE "`PALETTE' PuBuGn PuOr PuRd Purples RdBu RdGy RdPu RdYlBu"
local PALETTE "`PALETTE' RdYlGn Reds Set1 Set2 Set3 Spectral YlGn YlGnBu"
local PALETTE "`PALETTE' YlOrBr YlOrRd"
local PALETTE "`PALETTE' BuRd BuYlRd Heat Terrain Topological"
local PALETTE "`PALETTE' Blues2 Greens2 Greys2 Reds2 Rainbow"

/* Parse option fcolor() */
local EXIST : list posof `"`fcolor'"' in PALETTE
if `EXIST' {
   if (`NG' > 1) {
      spmap_color "`fcolor'" `NG'
      local fcolor `"`s(colors)'"'
   }
   else {
      di as err "{p}Problem with option {bf:{ul:dia}gram()}: "        ///
                "when no group variable is specified in suboption "   ///
                "{bf:{ul:by}()}, suboption {bf:{ul:fc}olor()} "       ///
                "does not accept palette names{p_end}"
      exit 198 
   }
}
else {
   spmap_psl, l(`fcolor') m(`NG') o({bf:{ul:fc}olor()}) d(`fcolor_d')
   local fcolor `"`s(pl)'"'
}

spmap_psl, l(`oalign') m(`NG') o({bf:{ul:oa}liagn()}) d(`oalign_d')
local oalign `"`s(pl)'"'

/* Parse option ocolor() */
local EXIST : list posof `"`ocolor'"' in PALETTE
if `EXIST' {
   di as err "{p}Problem with option {bf:{ul:dia}gram()}: "   ///
             "when suboption {bf:{ul:t}ype(frect)} is "       ///
             "specified, suboption {bf:{ul:oc}olor()} "       ///
             "does not accept palette names{p_end}"
   exit 198 
}
local ocolor : word 1 of `ocolor'

/* Parse option osize() */
local osize : word 1 of `osize'

/* Parse option refcolor() */
local refcolor : word 1 of `refcolor'

/* Parse option refsize() */
local refsize : word 1 of `refsize'

/* Generate weighting variable */
tempvar W
if ("`proportional'" == "") qui gen `W' = 1
if ("`proportional'" != "") {
   qui gen `W' = (`proportional' - `PMIN') / (`PMAX' - `PMIN')
}
gsort -`W'

/* Keep relevant variables */
keep `X' `Y' `V' `G' `W'

/* Set baseline rectangle dimension */
qui su `X', meanonly
local xd = `r(max)' - `r(min)'
qui su `Y', meanonly
local yd = `r(max)' - `r(min)'
local U = sqrt( (`xd' * `yd') / (`OBS' * 2) )
local XL = (`U' / 4) * `size'
local YL = (`U' / 2) * `size'

/* Expand dataset */
local NOBS = `OBS' * 18
qui set obs `NOBS'

/* Generate new variables */
qui gen __DIA_G = .
qui gen __DIA_X  = .
qui gen __DIA_Y  = .

/* Fill new variables */
local r = 1
forval i = 1/`OBS' {
   local Xi = `X'[`i']
   local Yi = `Y'[`i']
   local Vi = `V'[`i']
   local Gi = `G'[`i']
   local Wi = `W'[`i']
   local X0 = `Xi' - ((`XL'*`Wi') / 2)
   local Y0 = `Yi' - (`YL' / 2)

   qui replace __DIA_G = 0 in `r'
   local r = `r' + 1
   qui replace __DIA_G = 0 in `r'
   qui replace __DIA_X = `X0' in `r'
   qui replace __DIA_Y = (`Y0' + `YL'*`Vi') in `r'
   local r = `r' + 1
   qui replace __DIA_G = 0 in `r'
   qui replace __DIA_X = `X0' in `r'
   qui replace __DIA_Y = (`Y0' + `YL') in `r'
   local r = `r' + 1
   qui replace __DIA_G = 0 in `r'
   qui replace __DIA_X = (`X0' + `XL'*`Wi') in `r'
   qui replace __DIA_Y = (`Y0' + `YL') in `r'
   local r = `r' + 1
   qui replace __DIA_G = 0 in `r'
   qui replace __DIA_X = (`X0' + `XL'*`Wi') in `r'
   qui replace __DIA_Y = (`Y0' + `YL'*`Vi') in `r'
   local r = `r' + 1

   qui replace __DIA_G = `Gi' in `r'
   local r = `r' + 1
   qui replace __DIA_G = `Gi' in `r'
   qui replace __DIA_X = `X0' in `r'
   qui replace __DIA_Y = `Y0' in `r'
   local r = `r' + 1
   qui replace __DIA_G = `Gi' in `r'
   qui replace __DIA_X = `X0' in `r'
   qui replace __DIA_Y = (`Y0' + `YL'*`Vi') in `r'
   local r = `r' + 1
   qui replace __DIA_G = `Gi' in `r'
   qui replace __DIA_X = (`X0' + `XL'*`Wi') in `r'
   qui replace __DIA_Y = (`Y0' + `YL'*`Vi') in `r'
   local r = `r' + 1
   qui replace __DIA_G = `Gi' in `r'
   qui replace __DIA_X = (`X0' + `XL'*`Wi') in `r'
   qui replace __DIA_Y = `Y0' in `r'
   local r = `r' + 1

   qui replace __DIA_G = 998 in `r'
   local r = `r' + 1
   qui replace __DIA_G = 998 in `r'
   qui replace __DIA_X = `X0' in `r'
   qui replace __DIA_Y = `Y0' in `r'
   local r = `r' + 1
   qui replace __DIA_G = 998 in `r'
   qui replace __DIA_X = `X0' in `r'
   qui replace __DIA_Y = (`Y0' + `YL') in `r'
   local r = `r' + 1
   qui replace __DIA_G = 998 in `r'
   qui replace __DIA_X = (`X0' + `XL'*`Wi') in `r'
   qui replace __DIA_Y = (`Y0' + `YL') in `r'
   local r = `r' + 1
   qui replace __DIA_G = 998 in `r'
   qui replace __DIA_X = (`X0' + `XL'*`Wi') in `r'
   qui replace __DIA_Y = `Y0' in `r'
   local r = `r' + 1

   qui replace __DIA_G = 999 in `r'
   local r = `r' + 1
   qui replace __DIA_G = 999 in `r'
   qui replace __DIA_X = (`X0' - (`XL'*`Wi')/4) in `r'
   qui replace __DIA_Y = (`Y0' + `YL'*`RV') in `r'
   local r = `r' + 1
   qui replace __DIA_G = 999 in `r'
   qui replace __DIA_X = (`X0' + `XL'*`Wi'*1.25) in `r'
   qui replace __DIA_Y = (`Y0' + `YL'*`RV') in `r'
   local r = `r' + 1
}

/* Save dataset */
qui clonevar __DIA_LBL = `G'
keep __DIA*
qui save "__DIA.dta", replace

if c(stata_version) >= 15 {
	local LA la(center)
}

/* Compose command */
local GRAPH `"`GRAPH'(area __DIA_Y __DIA_X if __DIA_G == 0, nodropbase"'
local GRAPH `"`GRAPH' cmissing(n) fc("white") lc("white") lw("none") `LA') "'
forval i = 1/`NG' {
	local FC : word `i' of `fcolor'
	local OA : word `i' of `oalign'
   if c(stata_version) >= 15 {
	local LA `"la("`OA'")"'
   }
   local GRAPH `"`GRAPH'(area __DIA_Y __DIA_X if __DIA_G == `i', nodropbase"'
   local GRAPH `"`GRAPH' cmissing(n) fc("`FC'") fi(100) lc("`FC'")"'
   local GRAPH `"`GRAPH' lw("none") `LA') "'
}
local OC : word 1 of `ocolor'
local OS : word 1 of `osize'
local OA : word 1 of `oalign'
if c(stata_version) >= 15 {
	local LA `"la("`OA'")"'
}
local GRAPH `"`GRAPH'(area __DIA_Y __DIA_X if __DIA_G == 998, nodropbase"'
local GRAPH `"`GRAPH' cmissing(n) fc("none") lc("`OC'") lw("`OS'") `LA') "'
local RC : word 1 of `refcolor'
local RS : word 1 of `refsize'
local GRAPH `"`GRAPH'(line __DIA_Y __DIA_X if __DIA_G == 999, nodropbase"'
local GRAPH `"`GRAPH' cmissing(n) fc("none") lc("`RC'") lw("`RS'")) "'

/* Set number of keys */
local NK = 1 + `NG' + 2

/* Set legend when legenda(off) */
if ("`legenda'" == "off") {
   local TITLE ""
   local KEY   ""
   local LABEL ""
}

/* Set legend when legenda(on) */
if ("`legenda'" == "on") {
   if ("`by'" == "") {
      if (`"`legtitle'"' != "") {
         local Q = strpos(`"`legtitle'"',`"""') /* " */
         if (`Q' == 0) local TITLE `"- "`legtitle'""'
         else local TITLE `"- `legtitle'"'
      }
      else {
         local TITLE ""
      }
      local KEY   "2 "
      if ("`legcount'" == "") {
         local LABEL `"`LABEL'`"`VARLAB'"' "'
      }
      else {
         local OBS : word 1 of `COUNT'
         local LABEL `"`LABEL'`"`VARLAB' (`OBS')"' "'
      }
   }
   else {
      if (`"`legtitle'"' != "") {
         local Q = strpos(`"`legtitle'"',`"""') /* " */
         if (`Q' == 0) local TITLE `"- "`legtitle'""'
         else local TITLE `"- `legtitle'"'
      }
      else {
         local TITLE ""
      }
      numlist "2/`=`NG'+1'"
      local KEY "`r(numlist)'"
      if ("`legshow'" != "") {
         local CHECK : list legshow in KEY
         if !`CHECK' {
            di as err "{p}Problem with option {bf:{ul:dia}gram()}: "    ///
                      "one or more keys specified in suboption     "    ///
                      "{bf:{ul:legs}how()} do not exist. Valid keys "   ///
                      " are: `KEY'{p_end}"
            exit 198
         }
         else local KEY "`legshow'"
      }
      foreach K in `KEY' {
         local K = `K' - 1
         local LBL : label (__DIA_LBL) `K'
         if ("`legcount'" == "") {
            local LABEL `"`LABEL'`"`LBL'"' "'
         }
         else {
            local OBS : word `K' of `COUNT'
            local LABEL `"`LABEL'`"`LBL' (`OBS')"' "'
         }
      }
   }
}

/* Return command */
return local command `"`GRAPH'"'

/* Return min/max coordinates */
qui summ __DIA_X
return local xmin=r(min)
return local xmax=r(max)
qui summ __DIA_Y
return local ymin=r(min)
return local ymax=r(max)

/* Return legend info */
return local title `"`TITLE'"'
return local key   `"`KEY'"'
return local label `"`LABEL'"'
return local nk = `NK'


/* End condition */
}




*  ----------------------------------------------------------------------------
*  6. Create working dataset and return info of interest: pie chart            
*  ----------------------------------------------------------------------------

/* Start condition */
if ("`type'" == "pie") {


/* Housekeeping */
cap drop __DIA*

/* Generate coordinate variables */
tempvar X Y
qui gen `X' = `xcoord'
qui gen `Y' = `ycoord'

/* Generate main variables (percentage form) */
tempvar TOT
qui egen `TOT' = rsum(`variables')
forval i = 1/`NVAR' {
   local V : word `i' of `variables'
   tempvar V`i'
   qui clonevar `V`i'' = `V'
   qui replace  `V`i'' = round((`V`i'' / `TOT') * 100)
   local VARLIST "`VARLIST'`V`i'' "
   local VARLAB : variable label `V'
   if (`"`VARLAB'"' == "") local VARLAB "`V'"
   local LBLS `"`LBLS'`"`VARLAB'"' "'
}

/* Generate weighting variable */
tempvar W
if ("`proportional'" == "") qui gen `W' = 1
if ("`proportional'" != "") {
   qui gen `W' = (`proportional' - `PMIN') / (`PMAX' - `PMIN')
}
qui su `W'
local WMAX = r(max)
gsort -`W'

/* Create working matrices */
tempname DATA VARS
mkmat `X' `Y' `W', matrix(`DATA')
mkmat `VARLIST', matrix(`VARS')

/* Set baseline pie radius */
qui su `X', meanonly
local xd = `r(max)' - `r(min)'
qui su `Y', meanonly
local yd = `r(max)' - `r(min)'
local RAD = sqrt( (`xd' * `yd') / (`OBS' * 2) )
local RAD = (`RAD' / 4) * `size'

/* Create working dataset */
forval i = 1/`OBS' {
   drop _all
   qui set obs 101

   local Xi = `DATA'[`i',1]
   local Yi = `DATA'[`i',2]
   local Wi = `DATA'[`i',3]

   qui gen __DIA_X = sin(2 * _pi * (_n-1)/100)
   qui gen __DIA_Y = cos(2 * _pi * (_n-1)/100)
   qui replace __DIA_X = `Xi' + (__DIA_X * `RAD' * (`Wi'/`WMAX')^(0.57))
   qui replace __DIA_Y = `Yi' + (__DIA_Y * `RAD' * (`Wi'/`WMAX')^(0.57))
   tempfile PIE
   qui save `"`PIE'"', replace

   local INF ""
   local SUP ""
   local CUM = 1
   local NJ = 0
   local VJ ""
   forval j = 1/`NVAR' {
      local PCT = `VARS'[`i',`j']
      if (`PCT' > 0) {
         local INF "`INF'`CUM' "
         local CUM = `CUM' + `PCT'
         if (`j' == `NVAR') local CUM = "101"
         local SUP "`SUP'`CUM' "
         local NJ = `NJ' + 1
         local VJ "`VJ'`j' "
      }
   }

   forval j = 1/`NJ' {
      use `"`PIE'"', clear
      local FROM : word `j' of `INF'
      local TO : word `j' of `SUP'
      qui keep in `FROM'/`TO'
      qui gen SORT = _n + 2
      qui count
      local OBSj = r(N) + 3
      qui set obs `OBSj'
      qui replace SORT = 1 in `= r(N) + 1'
      qui replace SORT = 2 in `= r(N) + 2'
      qui replace SORT = `OBSj' in `= r(N) + 3'
      qui replace __DIA_X = `Xi' in `= r(N) + 2'
      qui replace __DIA_Y = `Yi' in `= r(N) + 2'
      qui replace __DIA_X = `Xi' in `= r(N) + 3'
      qui replace __DIA_Y = `Yi' in `= r(N) + 3'
      sort SORT
      local VAR : word `j' of `VJ'
      qui gen __DIA_G = `VAR'
      tempfile TEMP`j'
      qui save `"`TEMP`j''"', replace
   }

   use `"`TEMP1'"', clear
   forval j = 2/`NJ' {
      qui append using `"`TEMP`j''"' 
   }
   
   tempfile PIE`i'
   qui save `"`PIE`i''"', replace
}

use `"`PIE1'"', clear
forval i = 2/`OBS' {
   qui append using `"`PIE`i''"'
}

/* Save dataset */
keep __DIA*
qui save "__DIA.dta", replace

/* Set list of available color palettes */
local PALETTE "`PALETTE' Accent Blues BrBG BuGn BuPu Dark2 GnBu Greens Greys"
local PALETTE "`PALETTE' OrRd Oranges PRGn Paired Pastel1 Pastel2 PiYG PuBu"
local PALETTE "`PALETTE' PuBuGn PuOr PuRd Purples RdBu RdGy RdPu RdYlBu"
local PALETTE "`PALETTE' RdYlGn Reds Set1 Set2 Set3 Spectral YlGn YlGnBu"
local PALETTE "`PALETTE' YlOrBr YlOrRd"
local PALETTE "`PALETTE' BuRd BuYlRd Heat Terrain Topological"
local PALETTE "`PALETTE' Blues2 Greens2 Greys2 Reds2 Rainbow"

/* Parse option fcolor() */
local EXIST : list posof `"`fcolor'"' in PALETTE
if `EXIST' {
   if (`NVAR' > 1) {
      spmap_color "`fcolor'" `NVAR'
      local fcolor `"`s(colors)'"'
   }
   else {
      di as err "{p}Problem with option {bf:{ul:dia}gram()}: "           ///
                "when only one variable is specified in suboption "      ///
                "{bf:{ul:v}ariables()}, suboption {bf:{ul:fc}olor()} "   ///
                "does not accept palette names{p_end}"
      exit 198 
   }
}
else {
   spmap_psl, l(`fcolor') m(`NVAR') o({bf:{ul:fc}olor()}) d(`fcolor_d')
   local fcolor `"`s(pl)'"'
}

/* Parse option ocolor() */
local EXIST : list posof `"`ocolor'"' in PALETTE
if `EXIST' {
   if (`NVAR' > 1) {
      spmap_color "`ocolor'" `NVAR'
      local ocolor `"`s(colors)'"'
   }
   else {
      di as err "{p}Problem with option {bf:{ul:dia}gram()}: "           ///
                "when only one variable is specified in suboption "      ///
                "{bf:{ul:v}ariables()}, suboption {bf:{ul:oc}olor()} "   ///
                "does not accept palette names{p_end}"
      exit 198 
   }
}
else {
   spmap_psl, l(`ocolor') m(`NVAR') o({bf:{ul:oc}olor()}) d(`ocolor_d')
   local ocolor `"`s(pl)'"'
}

/* Parse option osize() */
spmap_psl, l(`osize') m(`NVAR') o({bf:{ul:os}ize()}) d(`osize_d')
local osize `"`s(pl)'"'

/* Parse option oalign() */
spmap_psl, l(`oalign') m(`NVAR') o({bf:{ul:os}ize()}) d(`oalign_d')
local oalign `"`s(pl)'"'

/* Compose command */
forval i = 1/`NVAR' {
   local FC : word `i' of `fcolor'
   local OC : word `i' of `ocolor'
   if ("`OC'" == "none") local OC "`FC'"
   local OS : word `i' of `osize'
   local OA : word `i' of `oalign'
   if c(stata_version) >= 15 {
	local LA `"la("`OA'")"'
   }
   local GRAPH `"`GRAPH'(area __DIA_Y __DIA_X if __DIA_G == `i', nodropbase"'
   local GRAPH `"`GRAPH' cmissing(n) fc("`FC'") fi(100) lc("`OC'")"'
   local GRAPH `"`GRAPH' lw("`OS'") `LA') "'
}

/* Set number of keys */
local NK = `NVAR'

/* Set legend when legenda(off) */
if ("`legenda'" == "off") {
   local TITLE ""
   local KEY   ""
   local LABEL ""
}

/* Set legend when legenda(on) */
if ("`legenda'" == "on") {
   if (`"`legtitle'"' != "") {
      local Q = strpos(`"`legtitle'"',`"""') /* " */
      if (`Q' == 0) local TITLE `"- "`legtitle'""'
      else local TITLE `"- `legtitle'"'
   }
   else {
      local TITLE ""
   }
   numlist "1/`NVAR'"
   local KEY "`r(numlist)'"
   if ("`legshow'" != "") {
      local CHECK : list legshow in KEY
      if !`CHECK' {
         di as err "{p}Problem with option {bf:{ul:dia}gram()}: "    ///
                   "one or more keys specified in suboption     "    ///
                   "{bf:{ul:legs}how()} do not exist. Valid keys "   ///
                   " are: `KEY'{p_end}"
         exit 198
      }
      else local KEY "`legshow'"
   }
   foreach K in `KEY' {
      local LBL : word `K' of `LBLS'
      local LABEL `"`LABEL'`"`LBL'"' "'
   }
}

/* Return command */
return local command `"`GRAPH'"'

/* Return min/max coordinates */
qui summ __DIA_X
return local xmin = r(min)
return local xmax = r(max)
qui summ __DIA_Y
return local ymin = r(min)
return local ymax = r(max)

/* Return legend info */
return local title `"`TITLE'"'
return local key   `"`KEY'"'
return local label `"`LABEL'"'
return local nk = `NK'


/* End condition */
}




*  ----------------------------------------------------------------------------
*  7. End program                                                              
*  ----------------------------------------------------------------------------

restore
end



