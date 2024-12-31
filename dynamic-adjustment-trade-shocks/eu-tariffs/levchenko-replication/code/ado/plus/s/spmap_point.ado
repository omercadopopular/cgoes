*! -spmap_point-: Auxiliary program for -spmap-                                
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

program spmap_point, rclass
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
                                  ///
        [PROPortional(string)]    ///
        [PRange(string)]          ///
        [PSize(string)]           ///
                                  ///
        [DEViation(string)]       ///
        [DMax(string)]            ///
        [REFVal(string)]          ///
        [REFWeight(string)]       ///
                                  ///
        [SIze(string)]            /// 1.3.0 Bug fix
        [SHape(string)]           ///
        [FColor(string asis)]     ///
        [OColor(string asis)]     ///
        [OSize(string)]           ///
                                  ///
        [LEGENDA(string)]         ///
        [LEGTitle(string asis)]   ///
        [LEGLabel(string)]        ///
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
      di as err "{p}Problem with option {bf:{ul:poi}nt()}: file "        ///
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
      di as err "{p}Problem with option {bf:{ul:poi}nt()}: suboption "   ///
                "{bf:{ul:s}elect()} specified incorrectly{p_end}"
      exit 198
   }
}

/* Check option by() */
if ("`by'" != "") {
   cap unab by : `by'
   if (_rc == 111) {
      di as err "{p}Problem with option {bf:{ul:poi}nt()}: "   ///
                "variable {bf:`by'} specified in suboption "   ///
                "{bf:{ul:by}()} not found{p_end}"
      exit 111
   }
   if (_rc == 198) {
      di as err "{p}Problem with option {bf:{ul:poi}nt()}: "   ///
                "string {bf:`by'} specified in suboption "     ///
                "{bf:{ul:by}()} is not a valid variable "      ///
                "name{p_end}"
      exit 198
   }
   local NW : word count `by'
   if (`NW' > 1) {
      di as err "{p}Problem with option {bf:{ul:poi}nt()}: "   ///
                "suboption {bf:{ul:by}()} accepts only one "   ///
                "variable{p_end}"
      exit 198 
   }
}

/* Check option xcoord() */
if ("`xcoord'" == "") {
   di as err "{p}Problem with option {bf:{ul:poi}nt()}: suboption "   ///
             "{bf:{ul:x}coord()} is required{p_end}"
   exit 198 
}
cap unab xcoord : `xcoord'
if (_rc == 111) {
   di as err "{p}Problem with option {bf:{ul:poi}nt()}: "       ///
             "variable {bf:`xcoord'} specified in suboption "   ///
             "{bf:{ul:x}coord()} not found{p_end}"
   exit 111
}
if (_rc == 198) {
   di as err "{p}Problem with option {bf:{ul:poi}nt()}: "     ///
             "string {bf:`xcoord'} specified in suboption "   ///
             "{bf:{ul:x}coord()} is not a valid variable "    ///
             "name{p_end}"
   exit 198
}
local NW : word count `xcoord'
if (`NW' > 1) {
   di as err "{p}Problem with option {bf:{ul:poi}nt()}: "       ///
             "suboption {bf:{ul:x}coord()} accepts only one "   ///
             "variable{p_end}"
   exit 198 
}
cap confirm numeric variable `xcoord', exact
if _rc {
   di as err "{p}Problem with option {bf:{ul:poi}nt()}: "   ///
             "suboption {bf:{ul:x}coord()} accepts only "   ///
             "numeric variables{p_end}"
   exit 7 
}

/* Check option ycoord() */
if ("`ycoord'" == "") {
   di as err "{p}Problem with option {bf:{ul:poi}nt()}: suboption "   ///
             "{bf:{ul:y}coord()} is required{p_end}"
   exit 198 
}
cap unab ycoord : `ycoord'
if (_rc == 111) {
   di as err "{p}Problem with option {bf:{ul:poi}nt()}: "       ///
             "variable {bf:`ycoord'} specified in suboption "   ///
             "{bf:{ul:y}coord()} not found{p_end}"
   exit 111
}
if (_rc == 198) {
   di as err "{p}Problem with option {bf:{ul:poi}nt()}: "     ///
             "string {bf:`ycoord'} specified in suboption "   ///
             "{bf:{ul:y}coord()} is not a valid variable "    ///
             "name{p_end}"
   exit 198
}
local NW : word count `ycoord'
if (`NW' > 1) {
   di as err "{p}Problem with option {bf:{ul:poi}nt()}: "       ///
             "suboption {bf:{ul:y}coord()} accepts only one "   ///
             "variable{p_end}"
   exit 198 
}
cap confirm numeric variable `ycoord', exact
if _rc {
   di as err "{p}Problem with option {bf:{ul:poi}nt()}: "   ///
             "suboption {bf:{ul:y}coord()} accepts only "   ///
             "numeric variables{p_end}"
   exit 7 
}

/* Check option proportional() */
if ("`proportional'" != "") {
   cap unab proportional : `proportional'
   if (_rc == 111) {
      di as err "{p}Problem with option {bf:{ul:poi}nt()}: "   ///
                "variable {bf:`proportional'} specified in "   ///
                "suboption {bf:{ul:prop}ortional()} not "      ///
                "found{p_end}"
      exit 111
   }
   if (_rc == 198) {
      di as err "{p}Problem with option {bf:{ul:poi}nt()}: "   ///
                "string {bf:`proportional'} specified in "     ///
                "suboption {bf:{ul:prop}ortional()} is not "   ///
                "a valid variable name{p_end}"
      exit 198
   }
   local NW : word count `proportional'
   if (`NW' > 1) {
      di as err "{p}Problem with option {bf:{ul:poi}nt()}: "    ///
                "suboption {bf:{ul:prop}ortional()} accepts "   ///
                "only one variable{p_end}"
      exit 198 
   }
   cap confirm numeric variable `proportional', exact
   if _rc {
      di as err "{p}Problem with option {bf:{ul:poi}nt()}: "    ///
                "suboption {bf:{ul:prop}ortional()} accepts "   ///
                "only numeric variables{p_end}"
      exit 7 
   }
}

/* Check option prange() */
if ("`prange'" != "") & ("`proportional'" != "") {
   local NW : word count `prange'
   if (`NW' != 2) {
      di as err "{p}Problem with option {bf:{ul:poi}nt()}: "       ///
                "suboption {bf:{ul:pr}ange()} requires exactly "   ///
                "2 arguments{p_end}"
      exit 198
   }
   foreach W in `prange' {
      cap confirm number `W'
      if _rc {
         di as err "{p}Problem with option {bf:{ul:poi}nt()}: "   ///
                   "suboption {bf:{ul:pr}ange()} accepts only "   ///
                   "numbers{p_end}"
         exit 7 
      }
   }
   local N1 : word 1 of `prange'
   local N2 : word 2 of `prange'
   if (`N1' == `N2') {
         di as err "{p}Problem with option {bf:{ul:poi}nt()}: "    ///
                   "the two numbers specified in suboption "       ///
                   "{bf:{ul:pr}ange()} must be different{p_end}"
         exit 198
   }
   local MIN = min(`N1', `N2')
   local MAX = max(`N1', `N2')
   local prange "`MIN' `MAX'"
}

/* Check option psize() */
if ("`psize'" != "") & ("`proportional'" != "") {
   local LIST "absolute relative"
   local EXIST : list posof "`psize'" in LIST
   if !`EXIST' {
      di as err "{p}Problem with option {bf:{ul:poi}nt()}: suboption "   ///
                "{bf:{ul:ps}ize()} accepts only one of the following "   ///
                "keywords: {bf:`LIST'}{p_end}"
      exit 198 
   }
}

/* Check option deviation() */
if ("`deviation'" != "") {
   if ("`proportional'" != "") {
      di as err "{p}Problem with option {bf:{ul:poi}nt()}: suboptions "   ///
                "{bf:{ul:prop}ortional()} and {bf:{ul:dev}iation()} "     ///
                "cannot be specified together{p_end}"
	   exit 198 
   }
   cap unab deviation : `deviation'
   if (_rc == 111) {
      di as err "{p}Problem with option {bf:{ul:poi}nt()}: "   ///
                "variable {bf:`deviation'} specified in "      ///
                "suboption {bf:{ul:dev}iation()} not "         ///
                "found{p_end}"
      exit 111
   }
   if (_rc == 198) {
      di as err "{p}Problem with option {bf:{ul:poi}nt()}: "   ///
                "string {bf:`deviation'} specified in "        ///
                "suboption {bf:{ul:dev}iation()} is not "      ///
                "a valid variable name{p_end}"
      exit 198
   }
   local NW : word count `deviation'
   if (`NW' > 1) {
      di as err "{p}Problem with option {bf:{ul:poi}nt()}: "    ///
                "suboption {bf:{ul:dev}iation()} accepts "      ///
                "only one variable{p_end}"
      exit 198 
   }
   cap confirm numeric variable `deviation', exact
   if _rc {
      di as err "{p}Problem with option {bf:{ul:poi}nt()}: "    ///
                "suboption {bf:{ul:dev}iation()} accepts "      ///
                "only numeric variables{p_end}"
      exit 7 
   }
}

/* Check option dmax() */
if ("`deviation'" != "") & ("`dmax'" != "") {
   local NW : word count `dmax'
   if (`NW' != 1) {
      di as err "{p}Problem with option {bf:{ul:dia}gram()}: "   ///
                "suboption {bf:{ul:dm}ax()} accepts only 1 "     ///
                "argument{p_end}"
      exit 198
   }
   cap confirm number `dmax'
   if _rc {
      di as err "{p}Problem with option {bf:{ul:dia}gram()}: "   ///
                "suboption {bf:{ul:dm}ax()} accepts only "       ///
                "numbers{p_end}"
      exit 7 
   }
   if (`dmax' <= 0) {
         di as err "{p}Problem with option {bf:{ul:dia}gram()}: "   ///
                   "the argument of suboption {bf:{ul:dm}ax()} "    ///
                   "must be >0{p_end}"
         exit 198
   }
}

/* Check option refval() */
if ("`deviation'" != "") & ("`refval'" != "") {
   cap confirm number `refval'
   if _rc {
   	local LIST "mean median"
	   local EXIST : list posof "`refval'" in LIST
	   if !`EXIST' {
         di as err "{p}Problem with option {bf:{ul:poi}nt()}: suboption "   ///
                   "{bf:{ul:refv}al()} accepts only numbers or one of "     ///
                   "the following keywords: {bf:`LIST'}{p_end}"
		   exit 198 
	   }
	}
	else local RVTYPE "NUM"
}

/* Check option refweight() */
if ("`refweight'" != "") & ("`deviation'" != "") {
   cap unab refweight : `refweight'
   if (_rc == 111) {
      di as err "{p}Problem with option {bf:{ul:poi}nt()}: "   ///
                "variable {bf:`refweight'} specified in "      ///
                "suboption {bf:{ul:refw}eight()} not "         ///
                "found{p_end}"
      exit 111
   }
   if (_rc == 198) {
      di as err "{p}Problem with option {bf:{ul:poi}nt()}: "   ///
                "string {bf:`refweight'} specified in "        ///
                "suboption {bf:{ul:refw}eight()} is not "      ///
                "a valid variable name{p_end}"
      exit 198
   }
   local NW : word count `refweight'
   if (`NW' > 1) {
      di as err "{p}Problem with option {bf:{ul:poi}nt()}: "      ///
                "suboption {bf:{ul:refw}eight()} accepts only "   ///
                "one variable{p_end}"
      exit 198 
   }
   cap confirm numeric variable `refweight', exact
   if _rc {
      di as err "{p}Problem with option {bf:{ul:poi}nt()}: "   ///
                "suboption {bf:{ul:refw}eight()} accepts "     ///
                "only numeric variables{p_end}"
      exit 7 
   }
}

/* Check option shape() */
if ("`shape'" != "") & ("`deviation'" != "") {
	local LIST "O D T S o d t s"
   local NL : word count `shape'
   forval i = 1/`NL' {
      local SHP : word `i' of `shape'
      if (!inlist("`SHP'",".","=","..","...")) {
      	local EXIST : list posof "`SHP'" in LIST
	      if !`EXIST' {
            di as err "{p}Problem with option {bf:{ul:poi}nt()}: when "   ///
                      "suboption {bf:{ul:dev}iation()} is specified, "    ///
                      "suboption {bf:{ul:sh}ape()} accepts only solid "   ///
                      "symbol styles written in short form: "             ///
                      "{bf:`LIST'}{p_end}"
		      exit 198
	      }
	   }
	}
}

/* Check option legenda() */
if ("`legenda'" != "") {
   local LIST "on off"
   local EXIST : list posof "`legenda'" in LIST
   if !`EXIST' {
      di as err "{p}Problem with option {bf:{ul:poi}nt()}: "        ///
                "suboption {bf:{ul:legenda}()} accepts only one "   ///
                "of the following keywords: {bf:`LIST'}{p_end}"
      exit 198 
   }
}

/* Check options relevant only when legenda(on) */
if ("`legenda'" == "on") {
   
   /* Check option leglabel() */
   if (`"`leglabel'"' == "") & ("`by'" == "") {
      di as err "{p}Problem with option {bf:{ul:poi}nt()}: since "      ///
                "you have specified suboption {bf:{ul:legenda}(on)} "   ///
                "but you have not specified any group variable in "     ///
                "suboption {bf:{ul:by}()}, you are requested to "       ///
                "specify suboption {bf:{ul:legl}abel()}{p_end}"
      exit 198
   }

   /* Check option legshow() */
   if ("`legshow'" != "") {
      cap numlist "`legshow'"
      if _rc {
         di as err "{p}Problem with option {bf:{ul:poi}nt()}: "   ///
                   "invalid numlist in suboption "                ///
                   "{bf:{ul:legs}how()}{p_end}"
         exit 121
      }
   }
   
/* End */
}

/* Marksample */
marksample TOUSE
markout `TOUSE' `xcoord' `ycoord'
if ("`by'" != "") markout `TOUSE' `by'
if ("`proportional'" != "") markout `TOUSE' `proportional'
if ("`deviation'" != "") markout `TOUSE' `deviation'
if ("`refweight'" != "" & "`deviation'" != "") markout `TOUSE' `refweight'
qui count if `TOUSE' 
if (r(N) == 0) error 2000




*  ----------------------------------------------------------------------------
*  4. Define basic objects                                                     
*  ----------------------------------------------------------------------------

/* Select relevant observations */
qui keep if `TOUSE'


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

   /* Set default reference system for weighting */
   if ("`psize'" == "") local psize "relative"

/* End */
}


/* Set defaults relevant only when deviation != "" */
if ("`deviation'" != "") {

   /* Set default reference value */
   if ("`refval'" == "") local refval "mean"

   /* Set STAT corresponding to specified reference value */
   if ("`refval'" == "mean") local STAT "mean"
   if ("`refval'" == "median") local STAT "p50"

   /* Set reference weight */
   if ("`refweight'" != "") local REFWEIGHT "[aweight = `refweight']"

/* End */
}


/* Set default symbol size */
local size_d "*1"
if ("`size'" == "") local size "`size_d' ..."

/* Set default symbol shape */
local shape_d "o"
if ("`shape'" == "") local shape "`shape_d' ..."

/* Set default symbol fill color */
local fcolor_d "black"
if (`"`fcolor'"' == "") local fcolor "`fcolor_d' ..."

/* Set default outline color */
local ocolor_d "none"
if (`"`ocolor'"' == "") local ocolor "`ocolor_d' ..."

/* Set default outline thickness */
local osize_d "thin"
if ("`osize'" == "") local osize "`osize_d' ..."


/* Set default legend */
if ("`legenda'" == "") local legenda "off"

/* Set legend title when legtitle(varlab) */
if ("`legenda'" == "on") & ("`by'" != "") & (`"`legtitle'"' == "varlab") {
   local legtitle : variable label `by'
   if (`"`legtitle'"' == "") local legtitle "`by'"
}




*  ----------------------------------------------------------------------------
*  5. Create working dataset                                                   
*  ----------------------------------------------------------------------------

/* Housekeeping */
cap drop __POI*

/* Generate weighting variable */
if ("`proportional'" == "") qui gen __POI_W = 1
if ("`proportional'" != "") {
   qui gen __POI_W = (`proportional' - `PMIN') / (`PMAX' - `PMIN')
   gsort -__POI_W
}

/* Generate sign and weighting variables if deviation != "" */
if ("`deviation'" != "") {
   if ("`RVTYPE'" == "NUM") local RV = `refval'
   else {
      qui su `deviation' `REFWEIGHT', detail
      local RV = r(`STAT')
   }
   qui gen __POI_S = sign(`deviation' - `RV')
   qui recode __POI_S (0=1)
   qui replace __POI_W = abs(`deviation' - `RV')
   gsort -__POI_S -__POI_W
}

/* Generate group variable */
if ("`by'" == "") qui gen  __POI_G = 1
if ("`by'" != "") qui egen __POI_G = group(`by'), lname(__POI_G)
qui tab __POI_G
local NG = r(r)

/* Generate dummy cases */
qui count
local NOBS = r(N)
if ("`proportional'" != "") {
   local NOBS2 = `NOBS' + `NG' * 2
   qui set obs `NOBS2'
   if ("`psize'" == "absolute") {
      local WMIN = 0
      local WMAX = 1
   }
   else {
      qui su __POI_W
      local WMIN = r(min)
      local WMAX = r(max)
   }
   local ROW = `NOBS' + 1
   forval i = 1/`NG' {
      qui replace __POI_G = `i' in `ROW'
      qui replace __POI_W = `WMIN' in `ROW'
      local ROW = `ROW' + 1
      qui replace __POI_G = `i' in `ROW'
      qui replace __POI_W = `WMAX' in `ROW'
      local ROW = `ROW' + 1
   }
   gsort __POI_G -__POI_W
}
if ("`deviation'" != "") {
   local NOBS2 = `NOBS' + `NG' * 2 * 2
   qui set obs `NOBS2'
   if ("`dmax'" != "") local WMAX = `dmax'
   else {
      qui su __POI_W
      local WMAX = r(max)
   }
   local ROW = `NOBS' + 1
   forval i = 1/`NG' {
      qui replace __POI_G = `i' in `ROW'
      qui replace __POI_S = -1 in `ROW'
      qui replace __POI_W = 0 in `ROW'
      local ROW = `ROW' + 1
      qui replace __POI_G = `i' in `ROW'
      qui replace __POI_S = -1 in `ROW'
      qui replace __POI_W = `WMAX' in `ROW'
      local ROW = `ROW' + 1
      qui replace __POI_G = `i' in `ROW'
      qui replace __POI_S = 1 in `ROW'
      qui replace __POI_W = 0 in `ROW'
      local ROW = `ROW' + 1
      qui replace __POI_G = `i' in `ROW'
      qui replace __POI_S = 1 in `ROW'
      qui replace __POI_W = `WMAX' in `ROW'
      local ROW = `ROW' + 1
   }
   gsort -__POI_S __POI_G -__POI_W
}

/* Generate coordinate variables */
qui gen __POI_X = `xcoord'
qui gen __POI_Y = `ycoord'

/* Set number of keys */
if ("`deviation'" == "") local NK = `NG'
else local NK = `NG' * 2

/* Count points */
if ("`legenda'" == "on") & ("`legcount'" != "") {
   if ("`deviation'" == "") {
      forval i = 1/`NG' {
         qui count if __POI_G == `i' & __POI_X != .
         if (r(N) > 0) local COUNT "`COUNT'`r(N)' "
      }
   }
   else {
      forval j = 1(-2)-1 {
         forval i = 1/`NG' {
            qui count if __POI_S == `j' & __POI_G == `i' & __POI_X != .
            if (r(N) > 0) local COUNT "`COUNT'`r(N)' "
         }
      }
   }
}

/* Save dataset */
keep __POI*
qui save "__POI.dta", replace




*  ----------------------------------------------------------------------------
*  6. Parse style lists                                                        
*  ----------------------------------------------------------------------------

/* Set list of available color palettes */
local PALETTE "`PALETTE' Accent Blues BrBG BuGn BuPu Dark2 GnBu Greens Greys"
local PALETTE "`PALETTE' OrRd Oranges PRGn Paired Pastel1 Pastel2 PiYG PuBu"
local PALETTE "`PALETTE' PuBuGn PuOr PuRd Purples RdBu RdGy RdPu RdYlBu"
local PALETTE "`PALETTE' RdYlGn Reds Set1 Set2 Set3 Spectral YlGn YlGnBu"
local PALETTE "`PALETTE' YlOrBr YlOrRd"
local PALETTE "`PALETTE' BuRd BuYlRd Heat Terrain Topological"
local PALETTE "`PALETTE' Blues2 Greens2 Greys2 Reds2 Rainbow"

/* Parse option size() */
spmap_psl, l(`size') m(`NG') o({bf:{ul:si}ze()}) d(`size_d')
local size `"`s(pl)'"'

/* Parse option shape() */
spmap_psl, l(`shape') m(`NG') o({bf:{ul:sh}ape()}) d(`shape_d')
local shape `"`s(pl)'"'

/* Parse option fcolor() */
local EXIST : list posof `"`fcolor'"' in PALETTE
if `EXIST' {
   if (`NG' > 1) {
      spmap_color "`fcolor'" `NG'
      local fcolor `"`s(colors)'"'
   }
   else {
      di as err "{p}Problem with option {bf:{ul:poi}nt()}: "          ///
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

/* Parse option ocolor() */
local EXIST : list posof `"`ocolor'"' in PALETTE
if `EXIST' {
   if (`NG' > 1) {
      spmap_color "`ocolor'" `NG'
      local ocolor `"`s(colors)'"'
   }
   else {
      di as err "{p}Problem with option {bf:{ul:poi}nt()}: "          ///
                "when no group variable is specified in suboption "   ///
                "{bf:{ul:by}()}, suboption {bf:{ul:oc}olor()} "       ///
                "does not accept palette names{p_end}"
      exit 198 
   }
}
else {
   spmap_psl, l(`ocolor') m(`NG') o({bf:{ul:oc}olor()}) d(`ocolor_d')
   local ocolor `"`s(pl)'"'
}

/* Parse option osize() */
spmap_psl, l(`osize') m(`NG') o({bf:{ul:os}ize()}) d(`osize_d')
local osize `"`s(pl)'"'




*  ----------------------------------------------------------------------------
*  7. Compose command                                                          
*  ----------------------------------------------------------------------------

/* Compose command */
if ("`proportional'" != "") {
   forval i = 1/`NG' {
      local SI : word 1 of `size'
      local SH : word `i' of `shape'
      local FC : word `i' of `fcolor'
      local OC : word `i' of `ocolor'
      if ("`OC'" == "none") local OC "`FC'"
      local OS : word `i' of `osize'
      local GRAPH `"`GRAPH'(scatter __POI_Y __POI_X [aw = __POI_W]"'
      local GRAPH `"`GRAPH' if __POI_G == `i', ms("`SH'") mc("`FC'")"'
      local GRAPH `"`GRAPH' msize("`SI'") mlw("`OS'") mlc("`OC'") ) "'
   }
}

if ("`deviation'" != "") {
   forval i = 1/`NG' {
      local SI : word 1 of `size'
      local SH : word `i' of `shape'
      local FC : word `i' of `fcolor'
      local OC : word `i' of `ocolor'
      if ("`OC'" == "none") local OC "`FC'"
      local OS : word `i' of `osize'
      local GRAPH `"`GRAPH'(scatter __POI_Y __POI_X [aw = __POI_W]"'
      local GRAPH `"`GRAPH' if __POI_G == `i' & __POI_S == 1,"'
      local GRAPH `"`GRAPH' ms("`SH'") mc("`FC'") msize("`SI'")"'
      local GRAPH `"`GRAPH' mlw("`OS'") mlc("`OC'") ) "'
   }
   forval i = 1/`NG' {
      local SI : word 1 of `size'
      local SH : word `i' of `shape'
      local FC "none"
      local OC : word `i' of `fcolor'
      local OS : word `i' of `osize'
      local GRAPH `"`GRAPH'(scatter __POI_Y __POI_X [aw = __POI_W]"'
      local GRAPH `"`GRAPH' if __POI_G == `i' & __POI_S == -1,"'
      local GRAPH `"`GRAPH' ms("`SH'h") mc("`FC'") msize("`SI'")"'
      local GRAPH `"`GRAPH' mlw("`OS'") mlc("`OC'") ) "'
   }
}

if ("`proportional'" == "") & ("`deviation'" == "") {
   forval i = 1/`NG' {
      local SI : word `i' of `size'
	   local SH : word `i' of `shape'
	   local FC : word `i' of `fcolor'
	   local OC : word `i' of `ocolor'
      if ("`OC'" == "none") local OC "`FC'"
	   local OS : word `i' of `osize'
	   local GRAPH `"`GRAPH'(scatter __POI_Y __POI_X [aw = __POI_W]"'
	   local GRAPH `"`GRAPH' if __POI_G == `i', ms("`SH'") mc("`FC'")"'
	   local GRAPH `"`GRAPH' msize("`SI'") mlw("`OS'") mlc("`OC'") ) "'
	}
}




*  ----------------------------------------------------------------------------
*  8. Set legend order and labels                                              
*  ----------------------------------------------------------------------------

/* legenda(off) */
if ("`legenda'" == "off") {
   local TITLE ""
   local KEY   ""
   local LABEL ""
}


/* legenda(on) & by == "" & deviation == "" */
if ("`legenda'" == "on") & ("`by'" == "") & ("`deviation'" == "") {

   /* Title */
   if (`"`legtitle'"' != "") {
      local Q = strpos(`"`legtitle'"',`"""') /* " */
      if (`Q' == 0) local TITLE `"- "`legtitle'""'
      else local TITLE `"- `legtitle'"'
   }
   else {
      local TITLE ""
   }

   /* Keys */
   local KEY "1 "

   /* Labels */
   if ("`legcount'" == "") {
      local LABEL `"`"`leglabel'"' "'
   }
   else {
      local OBS : word 1 of `COUNT'
      local LABEL `"`"`leglabel' (`OBS')"' "'
   }

/* End */
}


/* legenda(on) & by != "" & deviation == "" */
if ("`legenda'" == "on") & ("`by'" != "") & ("`deviation'" == "") {

   /* Title */
   if (`"`legtitle'"' != "") {
      local Q = strpos(`"`legtitle'"',`"""') /* " */
      if (`Q' == 0) local TITLE `"- "`legtitle'""'
      else local TITLE `"- `legtitle'"'
   }
   else {
      local TITLE ""
   }

   /* Keys */
   numlist "1/`NK'"
   local KEY "`r(numlist)'"
   if ("`legshow'" != "") {
      local CHECK : list legshow in KEY
      if !`CHECK' {
         di as err "{p}Problem with option {bf:{ul:poi}nt()}: "      ///
                   "one or more keys specified in suboption "        ///
                   "{bf:{ul:legs}how()} do not exist. Valid keys "   ///
                   " are: `KEY'{p_end}"
         exit 198
      }
      else local KEY "`legshow'"
   }

   /* Labels */
   foreach K in `KEY' {
      local LBL : label (__POI_G) `K'
      if ("`legcount'" == "") {
         local LABEL `"`LABEL'`"`LBL'"' "'
      }
      else {
         local OBS : word `K' of `COUNT'
         local LABEL `"`LABEL'`"`LBL' (`OBS')"' "'
      }
   }

/* End */
}


/* legenda(on) & deviation != "" */
if ("`legenda'" == "on") & ("`deviation'" != "") {

   /* Title */
   if (`"`legtitle'"' != "") {
      local Q = strpos(`"`legtitle'"',`"""') /* " */
      if (`Q' == 0) local TITLE `"- "`legtitle'""'
      else local TITLE `"- `legtitle'"'
   }
   else {
      local TITLE ""
   }

   /* Keys */
   local K = 1
   forval j = 1(-2)-1 {
      forval i = 1/`NG' {
         qui count if __POI_S == `j' & __POI_G == `i' & __POI_X != .
         if (r(N) > 0) {
            local KEY "`KEY'`K' "
            local VAL "`VAL'`i' "
            local SGN "`SGN'`j' "
         }
      local K = `K' + 1
      }
   }
   if ("`legshow'" != "") {
      local CHECK : list legshow in KEY
      if !`CHECK' {
         di as err "{p}Problem with option {bf:{ul:poi}nt()}: "      ///
                   "one or more keys specified in suboption "        ///
                   "{bf:{ul:legs}how()} do not exist. Valid keys "   ///
                   " are: `KEY'{p_end}"
         exit 198
      }
      else local KEY "`legshow'"
   }

   /* Labels */
   local NW : word count `KEY'
   forval i = 1/`NW' {
      local V : word `i' of `VAL'
      local S : word `i' of `SGN'
      if ("`S'" == "1") local S "[+]"
      if ("`S'" == "-1") local S "[-]"
      if ("`by'" != "") local LBL : label (__POI_G) `V'
      else local LBL `"`leglabel'"'
      if ("`legcount'" == "") {
         local LABEL `"`LABEL'`"`LBL'`S'"' "'
      }
      else {
         local OBS : word `i' of `COUNT'
         local LABEL `"`LABEL'`"`LBL'`S' (`OBS')"' "'
      }
   }

/* End */
}




*  ----------------------------------------------------------------------------
*  9. Return info of interest                                                  
*  ----------------------------------------------------------------------------

/* Return command */
return local command `"`GRAPH'"'

/* Return min/max coordinates */
qui summ __POI_X
return local xmin = r(min)
return local xmax = r(max)
qui summ __POI_Y
return local ymin = r(min)
return local ymax = r(max)

/* Return legend info */
return local title `"`TITLE'"'
return local key   `"`KEY'"'
return local label `"`LABEL'"'
return local nk = `NK'




*  ----------------------------------------------------------------------------
*  10. End program                                                             
*  ----------------------------------------------------------------------------

restore
end



