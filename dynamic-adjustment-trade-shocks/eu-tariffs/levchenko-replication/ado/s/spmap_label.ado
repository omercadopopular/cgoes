*! -spmap_label-: Auxiliary program for -spmap-                                
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

program spmap_label, rclass
version 9.2




*  ----------------------------------------------------------------------------
*  2. Define syntax                                                            
*  ----------------------------------------------------------------------------

syntax, [Data(string)]          ///
        [Select(string asis)]   ///
        [BY(string)]            ///
                                ///
        [Xcoord(string)]        ///
        [Ycoord(string)]        ///
        [Label(string)]         ///
                                ///
        [LEngth(string)]        ///
        [SIze(string)]          ///
        [COlor(string asis)]    ///
        [POsition(string)]      ///
        [GAp(string)]           ///
        [ANgle(string)]




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
      di as err "{p}Problem with option {bf:{ul:lab}el()}: file "        ///
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
      di as err "{p}Problem with option {bf:{ul:lab}el()}: suboption "   ///
                "{bf:{ul:s}elect()} specified incorrectly{p_end}"
      exit 198
   }
}

/* Check option by() */
if ("`by'" != "") {
   cap unab by : `by'
   if (_rc == 111) {
      di as err "{p}Problem with option {bf:{ul:lab}el()}: "   ///
                "variable {bf:`by'} specified in suboption "   ///
                "{bf:{ul:by}()} not found{p_end}"
      exit 111
   }
   if (_rc == 198) {
      di as err "{p}Problem with option {bf:{ul:lab}el()}: "   ///
                "string {bf:`by'} specified in suboption "     ///
                "{bf:{ul:by}()} is not a valid variable "      ///
                "name{p_end}"
      exit 198
   }
   local NW : word count `by'
   if (`NW' > 1) {
      di as err "{p}Problem with option {bf:{ul:lab}el()}: "   ///
                "suboption {bf:{ul:by}()} accepts only one "   ///
                "variable{p_end}"
      exit 198 
   }
}

/* Check option xcoord() */
if ("`xcoord'" == "") {
   di as err "{p}Problem with option {bf:{ul:lab}el()}: suboption "   ///
             "{bf:{ul:x}coord()} is required{p_end}"
   exit 198 
}
cap unab xcoord : `xcoord'
if (_rc == 111) {
   di as err "{p}Problem with option {bf:{ul:lab}el()}: "       ///
             "variable {bf:`xcoord'} specified in suboption "   ///
             "{bf:{ul:x}coord()} not found{p_end}"
   exit 111
}
if (_rc == 198) {
   di as err "{p}Problem with option {bf:{ul:lab}el()}: "     ///
             "string {bf:`xcoord'} specified in suboption "   ///
             "{bf:{ul:x}coord()} is not a valid variable "    ///
             "name{p_end}"
   exit 198
}
local NW : word count `xcoord'
if (`NW' > 1) {
   di as err "{p}Problem with option {bf:{ul:lab}el()}: "       ///
             "suboption {bf:{ul:x}coord()} accepts only one "   ///
             "variable{p_end}"
   exit 198 
}
cap confirm numeric variable `xcoord', exact
if _rc {
   di as err "{p}Problem with option {bf:{ul:lab}el()}: "   ///
             "suboption {bf:{ul:x}coord()} accepts only "   ///
             "numeric variables{p_end}"
   exit 7 
}

/* Check option ycoord() */
if ("`ycoord'" == "") {
   di as err "{p}Problem with option {bf:{ul:lab}el()}: suboption "   ///
             "{bf:{ul:y}coord()} is required{p_end}"
   exit 198 
}
cap unab ycoord : `ycoord'
if (_rc == 111) {
   di as err "{p}Problem with option {bf:{ul:lab}el()}: "       ///
             "variable {bf:`ycoord'} specified in suboption "   ///
             "{bf:{ul:y}coord()} not found{p_end}"
   exit 111
}
if (_rc == 198) {
   di as err "{p}Problem with option {bf:{ul:lab}el()}: "     ///
             "string {bf:`ycoord'} specified in suboption "   ///
             "{bf:{ul:y}coord()} is not a valid variable "    ///
             "name{p_end}"
   exit 198
}
local NW : word count `ycoord'
if (`NW' > 1) {
   di as err "{p}Problem with option {bf:{ul:lab}el()}: "       ///
             "suboption {bf:{ul:y}coord()} accepts only one "   ///
             "variable{p_end}"
   exit 198 
}
cap confirm numeric variable `ycoord', exact
if _rc {
   di as err "{p}Problem with option {bf:{ul:lab}el()}: "   ///
             "suboption {bf:{ul:y}coord()} accepts only "   ///
             "numeric variables{p_end}"
   exit 7 
}

/* Check option label() */
if ("`label'" == "") {
   di as err "{p}Problem with option {bf:{ul:lab}el()}: suboption "   ///
             "{bf:{ul:l}abel()} is required{p_end}"
   exit 198 
}
cap unab label : `label'
if (_rc == 111) {
   di as err "{p}Problem with option {bf:{ul:lab}el()}: "      ///
             "variable {bf:`label'} specified in suboption "   ///
             "{bf:{ul:l}abel()} not found{p_end}"
   exit 111
}
if (_rc == 198) {
   di as err "{p}Problem with option {bf:{ul:lab}el()}: "    ///
             "string {bf:`label'} specified in suboption "   ///
             "{bf:{ul:l}abel()} is not a valid variable "    ///
             "name{p_end}"
   exit 198
}
local NW : word count `label'
if (`NW' > 1) {
   di as err "{p}Problem with option {bf:{ul:lab}el()}: "      ///
             "suboption {bf:{ul:l}abel()} accepts only one "   ///
             "variable{p_end}"
   exit 198 
}

/* Check option length() */
if ("`length'" != "") {
   local NW : word count `length'
   forval i = 1/`NW' {
      local W : word `i' of `length'
      if (!inlist("`W'",".","=","..","...")) {
         cap confirm number `W'
         if _rc {
            di as err "{p}Problem with option {bf:{ul:lab}el()}: "   ///
                      "suboption {bf:{ul:le}ngth()} accepts only "   ///
                      "numbers{p_end}"
            exit 7 
         }
         if (`W' < 1) {
            di as err "{p}Problem with option {bf:{ul:lab}el()}: "   ///
                      "suboption {bf:{ul:le}ngth()} accepts only "   ///
                      "positive numbers{p_end}"
            exit 198
         }
      }
   }
}

/* Check option position() */
if ("`position'" != "") {
   local NW : word count `position'
   forval i = 1/`NW' {
      local W : word `i' of `position'
      if (!inlist("`W'",".","=","..","...")) {
         cap confirm number `W'
         if _rc {
            di as err "{p}Problem with option {bf:{ul:lab}el()}: "     ///
                      "suboption {bf:{ul:po}sition()} accepts only "   ///
                      "numbers{p_end}"
            exit 7 
         }
         if (`W' < 0 | `W' > 12) {
            di as err "{p}Problem with option {bf:{ul:lab}el()}: "     ///
                      "suboption {bf:{ul:po}sition()} accepts only "   ///
                      "numbers between 0 and 12{p_end}"
            exit 198
         }
      }
   }
}

/* Marksample */
marksample TOUSE
markout `TOUSE' `label' `xcoord' `ycoord', strok
if ("`by'" != "") markout `TOUSE' `by'
qui count if `TOUSE' 
if (r(N) == 0) error 2000




*  ----------------------------------------------------------------------------
*  4. Define basic objects                                                     
*  ----------------------------------------------------------------------------

/* Select relevant observations */
qui keep if `TOUSE'

/* Set default label length */
local length_d "12"
if ("`length'" == "") local length "`length_d' ..."

/* Set default label size */
local size_d "*1"
if ("`size'" == "") local size "`size_d' ..."

/* Set default label color */
local color_d "black"
if (`"`color'"' == "") local color "`color_d' ..."

/* Set default label position */
local position_d "0"
if ("`position'" == "") local position "`position_d' ..."

/* Set default label gap */
local gap_d "*1"
if ("`gap'" == "") local gap "`gap_d' ..."

/* Set default label angle */
local angle_d "horizontal"
if ("`angle'" == "") local angle "`angle_d' ..."




*  ----------------------------------------------------------------------------
*  5. Create working dataset                                                   
*  ----------------------------------------------------------------------------

/* Housekeeping */
cap drop __LAB*

/* Generate group variable */
if ("`by'" == "") qui gen  __LAB_G = 1
if ("`by'" != "") qui egen __LAB_G = group(`by'), lname(__LAB_G)
qui tab __LAB_G
local NG = r(r)

/* Parse option length() */
spmap_psl, l(`length') m(`NG') o({bf:{ul:le}ngth()}) d(`length_d')
local length `"`s(pl)'"'

/* Generate label variable */
local TYPE : type `label'
local TYPE = substr("`TYPE'",1,3)
if ("`TYPE'" != "str") {
	local VALLAB : value label `label'
	if ("`VALLAB'" == "") {
		qui tostring `label', gen(__LAB_L) force usedisplayformat
	}
	else {
		qui decode `label', gen(__LAB_L)
	}
}
else {
   ren `label' __LAB_L
}
forval i = 1/`NG' {
  	local LEN : word `i' of `length'
   qui replace __LAB_L = substr(__LAB_L , 1 , `LEN') if __LAB_G == `i'
}

/* Generate coordinate variables */
qui gen __LAB_X = `xcoord'
qui gen __LAB_Y = `ycoord'

/* Save dataset */
keep __LAB*
qui save "__LAB.dta", replace




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

/* Parse option color() */
local EXIST : list posof `"`color'"' in PALETTE
if `EXIST' {
   if (`NG' > 1) {
      spmap_color "`color'" `NG'
      local color `"`s(colors)'"'
   }
   else {
      di as err "{p}Problem with option {bf:{ul:lab}el()}: "          ///
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

/* Parse option position() */
spmap_psl, l(`position') m(`NG') o({bf:{ul:po}sition()}) d(`position_d')
local position `"`s(pl)'"'

/* Parse option gap() */
spmap_psl, l(`gap') m(`NG') o({bf:{ul:ga}p()}) d(`gap_d')
local gap `"`s(pl)'"'

/* Parse option angle() */
spmap_psl, l(`angle') m(`NG') o({bf:{ul:an}gle()}) d(`angle_d')
local angle `"`s(pl)'"'




*  ----------------------------------------------------------------------------
*  7. Compose command                                                          
*  ----------------------------------------------------------------------------

/* Compose command */
forval i = 1/`NG' {
	local SIZ : word `i' of `size'
	local COL : word `i' of `color'
	local POS : word `i' of `position'
	local GAP : word `i' of `gap'
	local ANG : word `i' of `angle'
   local GRAPH `"`GRAPH'(scatter __LAB_Y __LAB_X if __LAB_G == `i',"'
   local GRAPH `"`GRAPH' mlabel(__LAB_L) mlabsize("`SIZ'") mlabcol("`COL'")"'
   local GRAPH `"`GRAPH' mlabpos("`POS'") mlabgap("`GAP'") mlabang("`ANG'")"'
   local GRAPH `"`GRAPH' msymbol(i)) "'
}




*  ----------------------------------------------------------------------------
*  8. Return info of interest                                                  
*  ----------------------------------------------------------------------------

/* Return command */
return local command `"`GRAPH'"'

/* Return min/max coordinates */
qui summ __LAB_X
return local xmin = r(min)
return local xmax = r(max)
qui summ __LAB_Y
return local ymin = r(min)
return local ymax = r(max)




*  ----------------------------------------------------------------------------
*  9. End program                                                              
*  ----------------------------------------------------------------------------

restore
end



