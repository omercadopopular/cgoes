*! -spmap_scalebar-: Auxiliary program for -spmap-                             
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

program spmap_scalebar, rclass
version 9.2




*  ----------------------------------------------------------------------------
*  2. Define syntax                                                            
*  ----------------------------------------------------------------------------

syntax, [Units(string)]         ///
        [Scale(string)]         ///
        [Xpos(string)]          ///
        [Ypos(string)]          ///
                                ///
        [SIze(string)]          ///
        [FColor(string asis)]   ///
        [OColor(string asis)]   ///
        [OSize(string)]         ///
        [OAlign(string)]        ///
        [LAbel(string)]         ///
        [TColor(string asis)]   ///
        [TSize(string)]         ///
        [TAlign(string)]        ///
                                ///
         XMIN(string)           ///
         XMAX(string)           ///
         YMIN(string)           ///
         YMAX(string)




*  ----------------------------------------------------------------------------
*  3. Check syntax                                                             
*  ----------------------------------------------------------------------------

/* Check option units() */
if ("`units'" == "") {
   di as err "{p}Problem with option {bf:{ul:sca}lebar()}: suboption "   ///
             "{bf:{ul:u}nits()} is required{p_end}"
   exit 198 
}
cap confirm number `units'
if _rc {
   di as err "{p}Problem with option {bf:{ul:sca}lebar()}: "   ///
             "suboption {bf:{ul:u}nits()} accepts only "       ///
             "numbers{p_end}"
   exit 7
}
if (`units' <= 0) {
      di as err "{p}Problem with option {bf:{ul:sca}lebar()}: "   ///
                "suboption {bf:{ul:u}nits()} accepts only "       ///
                "positive numbers{p_end}"
      exit 198
}

/* Check option scale() */
if ("`scale'" != "") {
   local scale = `scale'
   cap confirm number `scale'
   if _rc {
      di as err "{p}Problem with option {bf:{ul:sca}lebar()}: "   ///
                "suboption {bf:{ul:s}cale()} accepts only "       ///
                "numbers{p_end}"
      exit 7
   }
   if (`scale' <= 0) {
         di as err "{p}Problem with option {bf:{ul:sca}lebar()}: "   ///
                   "suboption {bf:{ul:s}cale()} accepts only "       ///
                   "positive numbers{p_end}"
         exit 198
   }
}

/* Check option xpos() */
if ("`xpos'" != "") {
   cap confirm number `xpos'
   if _rc {
      di as err "{p}Problem with option {bf:{ul:sca}lebar()}: "   ///
                "suboption {bf:{ul:x}pos()} accepts only "        ///
                "numbers{p_end}"
      exit 7
   }
}

/* Check option ypos() */
if ("`ypos'" != "") {
   cap confirm number `ypos'
   if _rc {
      di as err "{p}Problem with option {bf:{ul:sca}lebar()}: "   ///
                "suboption {bf:{ul:y}pos()} accepts only "        ///
                "numbers{p_end}"
      exit 7
   }
}

/* Check option size() */
if ("`size'" != "") {
   cap confirm number `size'
   if _rc {
      di as err "{p}Problem with option {bf:{ul:sca}lebar()}: "   ///
                "suboption {bf:{ul:si}ze()} accepts only "        ///
                "numbers{p_end}"
      exit 7
   }
   if (`size' <= 0) {
         di as err "{p}Problem with option {bf:{ul:sca}lebar()}: "   ///
                   "suboption {bf:{ul:si}ze()} accepts only "        ///
                   "positive numbers{p_end}"
         exit 198
   }
}




*  ----------------------------------------------------------------------------
*  4. Define basic objects                                                     
*  ----------------------------------------------------------------------------

/* Set mapregion half-length */
local XL = (`xmax' - `xmin') / 2

/* Set mapregion half-height */
local YL = (`ymax' - `ymin') / 2

/* Set mapregion center */
local XC = `xmin' + `XL'
local YC = `ymin' + `YL'

/* Set default scale */
if ("`scale'" == "") local scale = 1

/* Set default xpos */
if ("`xpos'" == "") local xpos = 0

/* Set default ypos */
if ("`ypos'" == "") local ypos = -110

/* Set default bar height multiplier */
if ("`size'" == "") local size = 1

/* Set default fill color */
if (`"`fcolor'"' == "") local fcolor "black"

/* Set default outline color */
if (`"`ocolor'"' == "") local ocolor "black"

/* Set default outline size */
if ("`osize'" == "") local osize "vthin"

/* Set default outline alignment */
if ("`oalign'" == "") local oalign "center"

/* Set default label */
if (`"`label'"' == "") local label "Units"

/* Set default text color */
if (`"`tcolor'"' == "") local tcolor "black"

/* Set default text size */
if ("`tsize'" == "") local tsize "*1"

/* Set default text alignment */
if ("`talign'" == "") local talign "center"

/* Set total bar length */
local BLEN = `units' / `scale'

/* Set partial bar length */
local PLEN = `BLEN' / 5

/* Set bar height */
local BHEI = min(`xmax' - `xmin', `ymax' - `ymin') / 70 * 0.7 * `size'

/* Set bar coordinates */
if (`xpos' == 0) {
   local X1 = `XC' - `BLEN' / 2
   local X2 = `XC' + `BLEN' / 2
}
if (`xpos' < 0) {
   local X1 = `XC' + `xpos' / 100 * `XL'
   local X2 = `X1' + `BLEN'
}
if (`xpos' > 0) {
   local X2 = `XC' + `xpos' / 100 * `XL'
   local X1 = `X2' - `BLEN'
}
local Y1 = `YC' + `ypos' / 100 * `YL' - `BHEI' / 2
local Y2 = `YC' + `ypos' / 100 * `YL' + `BHEI' / 2
local X1a = `X1' + `PLEN'
local X2a = `X1' + `PLEN' * 2
local X1b = `X1' + `PLEN' * 3
local X2b = `X1' + `PLEN' * 4

/* Set label x-coordinate */
local XLBL = `X1' + `BLEN' / 2

/* Set text size */
local Q = strpos("`tsize'","*")
if (`Q' != 0) {
   local tsize = subinstr("`tsize'","*","",.)
   local tsize = `tsize' * 0.75
   local tsize "*`tsize'"
}




*  ----------------------------------------------------------------------------
*  5. Parse style lists                                                        
*  ----------------------------------------------------------------------------

/* Parse option fcolor() */
local fcolor : word 1 of `fcolor'

/* Parse option ocolor() */
local ocolor : word 1 of `ocolor'

/* Parse option osize() */
local osize : word 1 of `osize'

/* Parse option oalign() */
local oalign : word 1 of `oalign'

/* Parse option tcolor() */
local tcolor : word 1 of `tcolor'

/* Parse option tsize() */
local tsize : word 1 of `tsize'

/* Parse option talign() */
local talign : word 1 of `talign'




*  ----------------------------------------------------------------------------
*  6. Compose command                                                          
*  ----------------------------------------------------------------------------

if c(stata_version) >= 15 {
	local LA `"la("`oalign'")"'
	local TA `"la("`talign'")"'
}

/* Compose command */
local GRAPH `"(scatteri `Y1' `X1' `Y2' `X1' `Y2' `X2' `Y1' `X2',"'
local GRAPH `"`GRAPH' recast(area) nodropbase cmissing(n) fc(`fcolor')"'
local GRAPH `"`GRAPH' fi(100) lc(`ocolor') lw(`osize') `LA') "'
local GRAPH `"`GRAPH'(scatteri `Y1' `X1a' `Y2' `X1a' `Y2' `X2a'"'
local GRAPH `"`GRAPH' `Y1' `X2a' . . `Y1' `X1b' `Y2' `X1b'"'
local GRAPH `"`GRAPH' `Y2' `X2b' `Y1' `X2b', recast(area) nodropbase"'
local GRAPH `"`GRAPH' cmissing(n) fc(white) lc(`ocolor') lw(`osize') `LA') "'
local GRAPH `"`GRAPH'(scatteri `Y1' `XLBL' (6) "`label'""'
local GRAPH `"`GRAPH' `Y2' `X1' (12) "0" `Y2' `X2' (12) "`units'","'
local GRAPH `"`GRAPH' msymbol(i) mlabsize(`tsize') mlabcolor(`tcolor')"'
local GRAPH `"`GRAPH' mlabgap(*0.1) `TA') "'




*  ----------------------------------------------------------------------------
*  7. Return info of interest                                                  
*  ----------------------------------------------------------------------------

/* Return command */
return local command `"`GRAPH'"'

/* Return min/max coordinates */
return local xmin = `X1' - `BLEN' * 0.05
return local xmax = `X2' + `BLEN' * 0.05
return local ymin = `Y1' - `BHEI' * 4
return local ymax = `Y2' + `BHEI' * 4




*  ----------------------------------------------------------------------------
*  8. End program                                                              
*  ----------------------------------------------------------------------------

end



