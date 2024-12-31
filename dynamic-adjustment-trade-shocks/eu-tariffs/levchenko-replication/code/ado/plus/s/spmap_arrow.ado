*! -spmap_arrow-: Auxiliary program for -spmap-                                
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

program spmap_arrow, rclass
version 9.2




*  ----------------------------------------------------------------------------
*  2. Define syntax                                                            
*  ----------------------------------------------------------------------------

syntax, [Data(string)]            ///
        [Select(string asis)]     ///
        [BY(string)]              ///
                                  ///
        [DIRection(string)]       ///
        [HSIze(string)]           ///
        [HANgle(string)]          ///
        [HBArbsize(string)]       ///
        [HFColor(string asis)]    ///
        [HOColor(string asis)]    ///
        [HOSize(string)]          ///
        [LCOlor(string asis)]     ///
        [LSIze(string)]           ///
        [LPAttern(string asis)]   ///
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
   di as err "{p}Problem with option {bf:{ul:arr}ow()}: suboption "   ///
             "{bf:{ul:d}ata()} is required{p_end}"
   exit 198 
}
if (substr(reverse("`data'"),1,4) != "atd.") {
   local data "`data'.dta"
}
capture confirm file "`data'"
if _rc {
   di as err "{p}Problem with option {bf:{ul:arr}ow()}: file "        ///
             "{bf:`data'} specified in suboption {bf:{ul:d}ata()} "   ///
             "not found{p_end}"
   exit 601
}
use "`data'", clear
cap confirm numeric variable _ID _X1 _Y1 _X2 _Y2
if _rc {
   di as err "{p}Problem with option {bf:{ul:arr}ow()}: file "        ///
             "{bf:`data'} specified in suboption {bf:{ul:d}ata()} "   ///
             "is not a valid {help spmap##sd_arrow:{it:arrow}} "      ///
             "dataset {p_end}"
   exit 198
}

/* Select relevant records */
if (`"`select'"' != "") {
   cap `select'
   if _rc {
      di as err "{p}Problem with option {bf:{ul:arr}ow()}: suboption "   ///
                "{bf:{ul:s}elect()} specified incorrectly{p_end}"
      exit 198
   }
}

/* Check option by() */
if ("`by'" != "") {
   cap unab by : `by'
   if (_rc == 111) {
      di as err "{p}Problem with option {bf:{ul:arr}ow()}: "   ///
                "variable {bf:`by'} specified in suboption "   ///
                "{bf:{ul:by}()} not found{p_end}"
      exit 111
   }
   if (_rc == 198) {
      di as err "{p}Problem with option {bf:{ul:arr}ow()}: "   ///
                "string {bf:`by'} specified in suboption "     ///
                "{bf:{ul:by}()} is not a valid variable "      ///
                "name{p_end}"
      exit 198
   }
   local NW : word count `by'
   if (`NW' > 1) {
      di as err "{p}Problem with option {bf:{ul:arr}ow()}: "   ///
                "suboption {bf:{ul:by}()} accepts only one "   ///
                "variable{p_end}"
      exit 198 
   }
}

/* Check option direction() */
if ("`direction'" != "") {
   local NW : word count `direction'
   forval i = 1/`NW' {
      local W : word `i' of `direction'
      if (!inlist("`W'",".","=","..","...")) {
         cap confirm number `W'
         if _rc {
            di as err "{p}Problem with option {bf:{ul:dia}gram()}: "    ///
                      "suboption {bf:{ul:dir}ection()} accepts only "   ///
                      "numbers{p_end}"
            exit 7 
         }
         if (`W' < 1 | `W' > 2) {
            di as err "{p}Problem with option {bf:{ul:dia}gram()}: "   ///
                      "suboption {bf:{ul:dir}ection()} accepts only "   ///
                      "one of the following arguments:{p_end}"
            di as err "1 = Directional arrows"
            di as err "2 = Bidirectional arrows"
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
      di as err "{p}Problem with option {bf:{ul:arr}ow()}: "        ///
                "suboption {bf:{ul:legenda}()} accepts only one "   ///
                "of the following keywords: {bf:`LIST'}{p_end}"
      exit 198 
   }
}

/* Check options relevant only when legenda(on) */
if ("`legenda'" == "on") {
   
   /* Check option leglabel() */
   if (`"`leglabel'"' == "") & ("`by'" == "") {
      di as err "{p}Problem with option {bf:{ul:arr}ow()}: since "      ///
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
         di as err "{p}Problem with option {bf:{ul:arr}ow()}: "   ///
                   "invalid numlist in suboption "                ///
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

/* Select relevant observations */
qui keep if `TOUSE'

/* Set default arrow direction */
local direction_d "1"
if ("`direction'" == "") local direction "`direction_d' ..."

/* Set default arrowhead size */
local hsize_d "1.5"
if ("`hsize'" == "") local hsize "`hsize_d' ..."

/* Set default arrowhead angle */
local hangle_d "28.64"
if ("`hangle'" == "") local hangle "`hangle_d' ..."

/* Set default arrowhead barbsize (size of portion to be filled) */
local hbarbsize_d "1.5"
if ("`hbarbsize'" == "") local hbarbsize "`hbarbsize_d' ..."

/* Set default arrowhead fill color */
local hfcolor_d "black"
if (`"`hfcolor'"' == "") local hfcolor "`hfcolor_d' ..."

/* Set default arrowhead outline color */
local hocolor_d "black"
if (`"`hocolor'"' == "") local hocolor "`hocolor_d' ..."

/* Set default arrowhead outline thickness */
local hosize_d "thin"
if ("`hosize'" == "") local hosize "`hosize_d' ..."

/* Set default arrowline color */
local lcolor_d "black"
if (`"`lcolor'"' == "") local lcolor "`lcolor_d' ..."

/* Set default arrowline thickness */
local lsize_d "thin"
if ("`lsize'" == "") local lsize "`lsize_d' ..."

/* Set default arrowline pattern */
local lpattern_d "solid"
if (`"`lpattern'"' == "") local lpattern "`lpattern_d' ..."

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
cap drop __ARR*

/* Generate group variable */
if ("`by'" == "") qui gen  __ARR_G = 1
if ("`by'" != "") qui egen __ARR_G = group(`by'), lname(__ARR_G)
qui tab __ARR_G
local NG = r(r)

/* Generate coordinate variables */
qui gen __ARR_X1 = _X1
qui gen __ARR_Y1 = _Y1
qui gen __ARR_X2 = _X2
qui gen __ARR_Y2 = _Y2

/* Count objects */
if ("`legenda'" == "on") & ("`legcount'" != "") {
   forval i = 1/`NG' {
      qui tab _ID if __ARR_G == `i'
      local COUNT "`COUNT'`r(r)' "
   }
}

/* Save dataset */
keep __ARR*
qui save "__ARR.dta", replace




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

/* Parse option direction() */
spmap_psl, l(`direction') m(`NG') o({bf:{ul:d}irection()}) d(`direction_d')
local direction `"`s(pl)'"'

/* Parse option hsize() */
spmap_psl, l(`hsize') m(`NG') o({bf:{ul:hsi}ze()}) d(`hsize_d')
local hsize `"`s(pl)'"'

/* Parse option hangle() */
spmap_psl, l(`hangle') m(`NG') o({bf:{ul:han}gle()}) d(`hangle_d')
local hangle `"`s(pl)'"'

/* Parse option hbarbsize() */
spmap_psl, l(`hbarbsize') m(`NG') o({bf:{ul:hba}rbsize()}) d(`hbarbsize_d')
local hbarbsize `"`s(pl)'"'

/* Parse option hfcolor() */
local EXIST : list posof `"`hfcolor'"' in PALETTE
if `EXIST' {
   if (`NG' > 1) {
      spmap_color "`hfcolor'" `NG'
      local hfcolor `"`s(colors)'"'
   }
   else {
      di as err "{p}Problem with option {bf:{ul:arr}ow()}: "          ///
                "when no group variable is specified in suboption "   ///
                "{bf:{ul:by}()}, suboption {bf:{ul:hfc}olor()} "      ///
                "does not accept palette names{p_end}"
      exit 198 
   }
}
else {
   spmap_psl, l(`hfcolor') m(`NG') o({bf:{ul:hfc}olor()}) d(`hfcolor_d')
   local hfcolor `"`s(pl)'"'
}

/* Parse option hocolor() */
local EXIST : list posof `"`hocolor'"' in PALETTE
if `EXIST' {
   if (`NG' > 1) {
      spmap_color "`hocolor'" `NG'
      local hocolor `"`s(colors)'"'
   }
   else {
      di as err "{p}Problem with option {bf:{ul:arr}ow()}: "          ///
                "when no group variable is specified in suboption "   ///
                "{bf:{ul:by}()}, suboption {bf:{ul:hoc}olor()} "      ///
                "does not accept palette names{p_end}"
      exit 198 
   }
}
else {
   spmap_psl, l(`hocolor') m(`NG') o({bf:{ul:hoc}olor()}) d(`hocolor_d')
   local hocolor `"`s(pl)'"'
}

/* Parse option hosize() */
spmap_psl, l(`hosize') m(`NG') o({bf:{ul:hos}ize()}) d(`hosize_d')
local hosize `"`s(pl)'"'

/* Parse option lcolor() */
local EXIST : list posof `"`lcolor'"' in PALETTE
if `EXIST' {
   if (`NG' > 1) {
      spmap_color "`lcolor'" `NG'
      local lcolor `"`s(colors)'"'
   }
   else {
      di as err "{p}Problem with option {bf:{ul:arr}ow()}: "          ///
                "when no group variable is specified in suboption "   ///
                "{bf:{ul:by}()}, suboption {bf:{ul:lco}lor()} "       ///
                "does not accept palette names{p_end}"
      exit 198 
   }
}
else {
   spmap_psl, l(`lcolor') m(`NG') o({bf:{ul:lco}lor()}) d(`lcolor_d')
   local lcolor `"`s(pl)'"'
}

/* Parse option lsize() */
spmap_psl, l(`lsize') m(`NG') o({bf:{ul:lsi}ze()}) d(`lsize_d')
local lsize `"`s(pl)'"'

/* Parse option lpattern() */
spmap_psl, l(`lpattern') m(`NG') o({bf:{ul:lpa}ttern()}) d(`lpattern_d')
local lpattern `"`s(pl)'"'




*  ----------------------------------------------------------------------------
*  7. Compose command                                                          
*  ----------------------------------------------------------------------------

/* Compose command */
forval i = 1/`NG' {
	local DIR : word `i' of `direction'
   if (`DIR' == 1) local ARROW "pcarrow"
   if (`DIR' == 2) local ARROW "pcbarrow"
	local HSI : word `i' of `hsize'
	local HAN : word `i' of `hangle'
	local HBA : word `i' of `hbarbsize'
	local HFC : word `i' of `hfcolor'
	local HOC : word `i' of `hocolor'
   if ("`HOC'" == "none") local HOC "`HFC'"
	local HOS : word `i' of `hosize'
   local LCO : word `i' of `lcolor'
	local LSI : word `i' of `lsize'
	local LPA : word `i' of `lpattern'
   local GRAPH `"`GRAPH'(`ARROW' __ARR_Y1 __ARR_X1 __ARR_Y2 __ARR_X2"'
   local GRAPH `"`GRAPH' if __ARR_G == `i', msize("`HSI'") mangle("`HAN'")"'
   local GRAPH `"`GRAPH' barbsize("`HBA'") mfcolor("`HFC'") mlcolor("`HOC'")"'
   local GRAPH `"`GRAPH' mlwidth("`HOS'") lcolor("`LCO'") lwidth("`LSI'")"'
   local GRAPH `"`GRAPH' lpattern("`LPA'")) "'
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
      qui levelsof __ARR_G, local (VL)
      local CHECK : list legshow in VL
      if !`CHECK' {
         di as err "{p}Problem with option {bf:{ul:arr}ow()}: "      ///
                   "one or more keys specified in suboption     "    ///
                   "{bf:{ul:legs}how()} do not exist. Valid keys "   ///
                   " are: `VL'{p_end}"
         exit 198
      }
      else local KEY "`legshow'"
   }

   /* Labels */
   foreach K in `KEY' {
      local LBL : label (__ARR_G) `K'
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
qui summ __ARR_X1
local xmin1 = r(min)
local xmax1 = r(max)
qui summ __ARR_X2
local xmin2 = r(min)
local xmax2 = r(max)
qui summ __ARR_Y1
local ymin1 = r(min)
local ymax1 = r(max)
qui summ __ARR_Y2
local ymin2 = r(min)
local ymax2 = r(max)
return local xmin = min(`xmin1' , `xmin2')
return local xmax = max(`xmax1' , `xmax2')
return local ymin = min(`ymin1' , `ymin2')
return local ymax = max(`ymax1' , `ymax2')

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



