*! -spmap_polygon-: Auxiliary program for -spmap-                              
*! Version 1.3.1 - 09 January 2018 - StataCorp edit for stroke align           
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

program spmap_polygon, rclass
version 9.2




*  ----------------------------------------------------------------------------
*  2. Define syntax                                                            
*  ----------------------------------------------------------------------------

syntax, [Data(string)]            ///
        [Select(string asis)]     ///
        [BY(string)]              ///
                                  ///
        [FColor(string asis)]     ///
        [OColor(string asis)]     ///
        [OSize(string)]           ///
        [OPattern(string)]        /// 1.3.0
        [OAlign(string)]          ///
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
if ("`data'" == "") {
   di as err "{p}Problem with option {bf:{ul:pol}ygon()}: suboption "   ///
             "{bf:{ul:d}ata()} is required{p_end}"
   exit 198 
}
if (substr(reverse("`data'"),1,4) != "atd.") {
   local data "`data'.dta"
}
capture confirm file "`data'"
if _rc {
   di as err "{p}Problem with option {bf:{ul:pol}ygon()}: file "      ///
             "{bf:`data'} specified in suboption {bf:{ul:d}ata()} "   ///
             "not found{p_end}"
   exit 601
}
use "`data'", clear
cap confirm numeric variable _ID _X _Y
if _rc {
   di as err "{p}Problem with option {bf:{ul:pol}ygon()}: file "       ///
             "{bf:`data'} specified in suboption {bf:{ul:d}ata()} "    ///
             "is not a valid {help spmap##sd_polygon:{it:polygon}} "   ///
             "dataset {p_end}"
   exit 198
}

/* Select relevant records */
if (`"`select'"' != "") {
   cap `select'
   if _rc {
      di as err "{p}Problem with option {bf:{ul:pol}ygon()}: suboption "   ///
                "{bf:{ul:s}elect()} specified incorrectly{p_end}"
      exit 198
   }
}

/* Check option by() */
if ("`by'" != "") {
   cap unab by : `by'
   if (_rc == 111) {
      di as err "{p}Problem with option {bf:{ul:pol}ygon()}: "   ///
                "variable {bf:`by'} specified in suboption "     ///
                "{bf:{ul:by}()} not found{p_end}"
      exit 111
   }
   if (_rc == 198) {
      di as err "{p}Problem with option {bf:{ul:pol}ygon()}: "   ///
                "string {bf:`by'} specified in suboption "       ///
                "{bf:{ul:by}()} is not a valid variable "        ///
                "name{p_end}"
      exit 198
   }
   local NW : word count `by'
   if (`NW' > 1) {
      di as err "{p}Problem with option {bf:{ul:pol}ygon()}: "   ///
                "suboption {bf:{ul:by}()} accepts only one "     ///
                "variable{p_end}"
      exit 198 
   }
}

/* Check option legenda() */
if ("`legenda'" != "") {
   local LIST "on off"
   local EXIST : list posof "`legenda'" in LIST
   if !`EXIST' {
      di as err "{p}Problem with option {bf:{ul:pol}ygon()}: "      ///
                "suboption {bf:{ul:legenda}()} accepts only one "   ///
                "of the following keywords: {bf:`LIST'}{p_end}"
      exit 198 
   }
}

/* Check options relevant only when legenda(on) */
if ("`legenda'" == "on") {
   
   /* Check option leglabel() */
   if (`"`leglabel'"' == "") & ("`by'" == "") {
      di as err "{p}Problem with option {bf:{ul:pol}ygon()}: since "    ///
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
         di as err "{p}Problem with option {bf:{ul:pol}ygon()}: "   ///
                   "invalid numlist in suboption "                  ///
                   "{bf:{ul:legs}how()}{p_end}"
         exit 121
      }
   }
   
/* End */
}

/* Marksample */
marksample TOUSE
if ("`by'" != "") markout `TOUSE' `by', strok
qui count if `TOUSE'
if (r(N) == 0) error 2000




*  ----------------------------------------------------------------------------
*  4. Define basic objects                                                     
*  ----------------------------------------------------------------------------

/* Select relevant records */
qui keep if `TOUSE'

/* Set default fill color */
local fcolor_d "none"
if (`"`fcolor'"' == "") local fcolor "`fcolor_d' ..."

/* Set default outline color */
local ocolor_d "black"
if (`"`ocolor'"' == "") local ocolor "`ocolor_d' ..."

/* Set default outline thickness */
local osize_d "thin"
if ("`osize'" == "") local osize "`osize_d' ..."

/* Set default outline pattern */
local opattern_d "solid"
if ("`opattern'" == "") local opattern "`opattern_d' ..."

/* Set default outline alignment */
local oalign_d "center"
if ("`oalign'" == "") local oalign "`oalign_d' ..."

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
cap drop __POL*

/* Generate group variable */
if ("`by'" == "") qui gen  __POL_G = 1
if ("`by'" != "") qui egen __POL_G = group(`by'), lname(__POL_G)
qui tab __POL_G
local NG = r(r)

/* Generate coordinate variables */
qui gen __POL_X = _X
qui gen __POL_Y = _Y

/* Count objects */
if ("`legenda'" == "on") & ("`legcount'" != "") {
   forval i = 1/`NG' {
      qui tab _ID if __POL_G == `i'
      local COUNT "`COUNT'`r(r)' "
   }
}

/* Save dataset */
keep __POL*
qui save "__POL.dta", replace




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

/* Parse option fcolor() */
local EXIST : list posof `"`fcolor'"' in PALETTE
if `EXIST' {
   if (`NG' > 1) {
      spmap_color "`fcolor'" `NG'
      local fcolor `"`s(colors)'"'
   }
   else {
      di as err "{p}Problem with option {bf:{ul:pol}ygon()}: "        ///
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
      di as err "{p}Problem with option {bf:{ul:pol}ygon()}: "        ///
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

/* Parse option opattern() */
spmap_psl, l(`opattern') m(`NG') o({bf:{ul:op}attern()}) d(`opattern_d')
local opattern `"`s(pl)'"'

/* Parse option oalign() */
spmap_psl, l(`oalign') m(`NG') o({bf:{ul:op}attern()}) d(`oalign_d')
local oalign `"`s(pl)'"'




*  ----------------------------------------------------------------------------
*  7. Compose command                                                          
*  ----------------------------------------------------------------------------

/* Compose command */
forval i = 1/`NG' {
   local FC : word `i' of `fcolor'
   local OC : word `i' of `ocolor'
   if ("`OC'" == "none") local OC "`FC'"
	local OS : word `i' of `osize'
   local OP : word `i' of `opattern'
   local OA : word `i' of `oalign'
   if c(stata_version) >= 15 {
	local LA `"la("`OA'")"'
   }
   local GRAPH `"`GRAPH'(area __POL_Y __POL_X if __POL_G == `i', nodropbase"'
   local GRAPH `"`GRAPH' cmissing(n) fc("`FC'") fi(100) lc("`OC'")"'
   local GRAPH `"`GRAPH' lw("`OS'") lp("`OP'") `LA') "'
}




*  ----------------------------------------------------------------------------
*  8. Set legend order and labels                                              
*  ----------------------------------------------------------------------------

/* Set number of keys */
local NK = `NG'


/* legenda(off) */
if ("`legenda'" == "off") {
   local TITLE ""
   local KEY   ""
   local LABEL ""
}


/* legenda(on) & by == "" */
if ("`legenda'" == "on") & ("`by'" == "") {

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


/* legenda(on) & by == !" */
if ("`legenda'" == "on") & ("`by'" != "") {

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
   if ("`legshow'" == "") {
      numlist "1/`NK'"
      local KEY "`r(numlist)'"
   }
   else {
      qui levelsof __POL_G, local (VL)
      local CHECK : list legshow in VL
      if !`CHECK' {
         di as err "{p}Problem with option {bf:{ul:pol}ygon()}: "    ///
                   "one or more keys specified in suboption     "    ///
                   "{bf:{ul:legs}how()} do not exist. Valid keys "   ///
                   " are: `VL'{p_end}"
         exit 198
      }
      else local KEY "`legshow'"
   }

   /* Labels */
   foreach K in `KEY' {
      local LBL : label (__POL_G) `K'
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




*  ----------------------------------------------------------------------------
*  9. Return info of interest                                                  
*  ----------------------------------------------------------------------------

/* Return command */
return local command `"`GRAPH'"'

/* Return min/max coordinates */
qui summ __POL_X
return local xmin = r(min)
return local xmax = r(max)
qui summ __POL_Y
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



