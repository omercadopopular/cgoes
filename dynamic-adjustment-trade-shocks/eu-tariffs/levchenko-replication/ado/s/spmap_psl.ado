*! -spmap_psl-: Auxiliary program for -spmap-                                  
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

program spmap_psl, sclass
version 9.2




*  ----------------------------------------------------------------------------
*  2. Define syntax                                                            
*  ----------------------------------------------------------------------------

syntax, List(string asis) Max(numlist min=1 max=1 >0 integer)   ///
        Option(string asis) [Default(string)]




*  ----------------------------------------------------------------------------
*  3. Parse list                                                               
*  ----------------------------------------------------------------------------

local FIRST : word 1 of `list'
if (inlist("`FIRST'","=","..","...")) {
   di as err `"{p}Option `option' does not accept symbol "`FIRST'" "'   ///
             "as its first argument{p_end}"
   exit 198
}
local NL : word count `list'
forval i = 1/`NL' {
   local ITEM : word `i' of `list'
   if ("`ITEM'" == ".") {
      if ("`default'" != "") {
         local EL "`default'"
         local PL `"`PL'"`EL'" "'
      }
      else {
         di as err `"{p}Option `option' does not accept symbol ".", "'   ///
                   `"since no default value exists for this "'           ///
                   `"option{p_end}"'
         exit 198
      }
   }
   else if ("`ITEM'" == "=") {
      local EL `"`: word `=`i'-1' of `PL''"'
      local PL `"`PL'"`EL'" "'
   }
   else if ("`ITEM'" == ".." | "`ITEM'" == "...") {
      local EL `"`: word `=`i'-1' of `PL''"'
      forval j = `i'/`max' {
         local PL `"`PL'"`EL'" "'
      }
      continue, break
   }
   else {
      local PL `"`PL'"`ITEM'" "'
   }
}
local NL : word count `PL'
if (`NL' < `max') {
   if ("`default'" != "") {
      forval i = `=`NL'+1'/`max' {
         local PL `"`PL'"`default'" "'
      }
   }
   else {
      di as err "{p}Option `option' requires exactly `max' arguments{p_end}"
      exit 198
   }
}
sreturn local pl `"`PL'"'




*  ----------------------------------------------------------------------------
*  4. End program                                                              
*  ----------------------------------------------------------------------------

end



