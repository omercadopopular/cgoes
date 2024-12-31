*! -spmap_line-: Auxiliary program for -spmap-                                 
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

program spmap_line, rclass
version 9.2




*  ----------------------------------------------------------------------------
*  2. Define syntax                                                            
*  ----------------------------------------------------------------------------

syntax, [Data(string)]            ///
        [Select(string asis)]     ///
        [BY(string)]              ///
                                  ///
        [COlor(string asis)]      ///
        [SIze(string)]            ///
        [PAttern(string asis)]    ///
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
   di as err "{p}Problem with option {bf:{ul:lin}e()}: suboption "    ///
             "{bf:{ul:d}ata()} is required{p_end}"
   exit 198 
}
if (substr(reverse("`data'"),1,4) != "atd.") {
   local data "`data'.dta"
}
capture confirm file "`data'"
if _rc {
   di as err "{p}Problem with option {bf:{ul:lin}e()}: file "         ///
             "{bf:`data'} specified in suboption {bf:{ul:d}ata()} "   ///
             "not found{p_end}"
   exit 601
}
use "`data'", clear
cap confirm numeric variable _ID _X _Y
if _rc {
   di as err "{p}Problem with option {bf:{ul:lin}e()}: file "         ///
             "{bf:`data'} specified in suboption {bf:{ul:d}ata()} "   ///
             "is not a valid {help spmap##sd_line:{it:line}} "        ///
             "dataset {p_end}"
   exit 198
}

/* Select relevant records */
if (`"`select'"' != "") {
   cap `select'
   if _rc {
      di as err "{p}Problem with option {bf:{ul:lin}e()}: suboption "   ///
                "{bf:{ul:s}elect()} specified incorrectly{p_end}"
      exit 198
   }
}

/* Check option by() */
if ("`by'" != "") {
   cap unab by : `by'
   if (_rc == 111) {
      di as err "{p}Problem with option {bf:{ul:lin}e()}: "    ///
                "variable {bf:`by'} specified in suboption "   ///
                "{bf:{ul:by}()} not found{p_end}"
      exit 111
   }
   if (_rc == 198) {
      di as err "{p}Problem with option {bf:{ul:lin}e()}: "   ///
                "string {bf:`by'} specified in suboption "    ///
                "{bf:{ul:by}()} is not a valid variable "     ///
                "name{p_end}"
      exit 198
   }
   local NW : word count `by'
   if (`NW' > 1) {
      di as err "{p}Problem with option {bf:{ul:lin}e()}: "    ///
                "suboption {bf:{ul:by}()} accepts only one "   ///
                "variable{p_end}"
      exit 198 
   }
}

/* Check option legenda() */
if ("`legenda'" != "") {
   local LIST "on off"
   local EXIST : list posof "`legenda'" in LIST
   if !`EXIST' {
      di as err "{p}Problem with option {bf:{ul:lin}e()}: "         ///
                "suboption {bf:{ul:legenda}()} accepts only one "   ///
                "of the following keywords: {bf:`LIST'}{p_end}"
      exit 198 
   }
}

/* Check options relevant only when legenda(on) */
if ("`legenda'" == "on") {
   
   /* Check option leglabel() */
   if (`"`leglabel'"' == "") & ("`by'" == "") {
      di as err "{p}Problem with option {bf:{ul:lin}e()}: since "       ///
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
         di as err "{p}Problem with option {bf:{ul:lin}e()}: "   ///
                   "invalid numlist in suboption "               ///
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

/* Set default line color */
local color_d "black"
if (`"`color'"' == "") local color "`color_d' ..."

/* Set default line thickness */
local size_d "thin"
if ("`size'" == "") local size "`size_d' ..."

/* Set default line pattern */
local pattern_d "solid"
if (`"`pattern'"' == "") local pattern "`pattern_d' ..."

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
cap drop __LIN*

/* Generate group variable */
if ("`by'" == "") qui gen  __LIN_G = 1
if ("`by'" != "") qui egen __LIN_G = group(`by'), lname(__LIN_G)
qui tab __LIN_G
local NG = r(r)

/* Generate coordinate variables */
qui gen __LIN_X = _X
qui gen __LIN_Y = _Y

/* Count objects */
if ("`legenda'" == "on") & ("`legcount'" != "") {
   forval i = 1/`NG' {
      qui tab _ID if __LIN_G == `i'
      local COUNT "`COUNT'`r(r)' "
   }
}

/* Save dataset */
keep __LIN*
qui save "__LIN.dta", replace




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

/* Parse option color() */
local EXIST : list posof `"`color'"' in PALETTE
if `EXIST' {
   if (`NG' > 1) {
      spmap_color "`color'" `NG'
      local color `"`s(colors)'"'
   }
   else {
      di as err "{p}Problem with option {bf:{ul:lin}e()}: "           ///
                "when no group variable is specified in suboption "   ///
                "{bf:{ul:by}()}, suboption {bf:{ul:co}lor()} "        ///
                "does not accept palette names{p_end}"
      exit 198 
   }
}
else {
   spmap_psl, l(`color') m(`NG') o({bf:{ul:co}lor()}) d(`color_d')
   local color `"`s(pl)'"'
}

/* Parse option size() */
spmap_psl, l(`size') m(`NG') o({bf:{ul:si}ze()}) d(`size_d')
local size `"`s(pl)'"'

/* Parse option pattern() */
spmap_psl, l(`pattern') m(`NG') o({bf:{ul:pa}ttern()}) d(`pattern_d')
local pattern `"`s(pl)'"'




*  ----------------------------------------------------------------------------
*  7. Compose command                                                          
*  ----------------------------------------------------------------------------

/* Compose command */
forval i = 1/`NG' {
   local COL : word `i' of `color'
	local SIZ : word `i' of `size'
	local PAT : word `i' of `pattern'
   local GRAPH `"`GRAPH'(line __LIN_Y __LIN_X if __LIN_G == `i', nodropbase"'
   local GRAPH `"`GRAPH' cmissing(n) lc("`COL'") lw("`SIZ'") lp("`PAT'")) "'
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
      qui levelsof __LIN_G, local (VL)
      local CHECK : list legshow in VL
      if !`CHECK' {
         di as err "{p}Problem with option {bf:{ul:lin}e()}: "       ///
                   "one or more keys specified in suboption     "    ///
                   "{bf:{ul:legs}how()} do not exist. Valid keys "   ///
                   " are: `VL'{p_end}"
         exit 198
      }
      else local KEY "`legshow'"
   }

   /* Labels */
   foreach K in `KEY' {
      local LBL : label (__LIN_G) `K'
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
qui summ __LIN_X
return local xmin = r(min)
return local xmax = r(max)
qui summ __LIN_Y
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



