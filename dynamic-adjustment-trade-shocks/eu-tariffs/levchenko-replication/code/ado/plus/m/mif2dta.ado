*! -mif2dta-: Converts MapInfo Interchange Format files to Stata datasets      
*! Version 2.0.0 - 14 March 2008                                               
*! Author: Maurizio Pisati                                                     
*! Department of Sociology and Social Research                                 
*! University of Milano Bicocca (Italy)                                        
*! maurizio.pisati@unimib.it                                                   




*  ----------------------------------------------------------------------------
*  1. Define program                                                           
*  ----------------------------------------------------------------------------

program mif2dta
version 9.2




*  ----------------------------------------------------------------------------
*  2. Define syntax                                                            
*  ----------------------------------------------------------------------------

syntax using/,                ///
       Type(string)           ///
		[GENID(name)]           ///
      [GENCentroids(name)]    ///
                              ///
		 Attributes(string)     ///
		[Coordinates(string)]   ///
		[REPLACE]




*  ----------------------------------------------------------------------------
*  3. Check syntax                                                             
*  ----------------------------------------------------------------------------

/* Preserve data */
preserve

/* Check using file */
if (substr(reverse("`using'"),1,4) != "fim.") local MIF_FILE "`using'.mif"
capture confirm file "`using'"
local MID_FILE : subinstr local MIF_FILE ".mif" ".mid"
cap confirm file `"`MID_FILE'"'
if (_rc) local MID "No"
else local MID "Yes"

/* Check option type() */
local LIST "polygon polyline point"
local EXIST : list posof "`type'" in LIST
if !`EXIST' {
   di as err "{p}Option {bf:{ul:t}ype()} accepts only one of "   ///
             "the following keywords: {bf:`LIST'}{p_end}"
   exit 198
}

/* Check option gencentroids() */
if ("`type'" == "polygon") & ("`gencentroids'" != "") & ("`genid'" == "") {
   di as err "{p}If you specify option {bf:{ul:genc}entroids()}, you "    ///
             "are requested to specify also option {bf:genid()}{p_end}"
   exit 198 
}

/* Check option attributes() */
if (substr(reverse("`attributes'"),1,4) != "atd.") {
   local attributes "`attributes'.dta"
}
cap confirm file "`attributes'"
if (_rc == 0) & ("`replace'" == "") {
   di as err "{p}File {bf:`attributes'} specified in option "   ///
             "{bf:{ul:a}ttributes()} already exists{p_end}"
   exit 602
}

/* Check option coordinates() */
if ("`type'" != "point") {
   if ("`coordinates'" == "") {
      di as err "{p}If you specify option {bf:{ul:t}ype(polygon)} or " ///
                "{bf:{ul:t}ype(polyline)}, you are requested to "      ///
                "specify also option {bf:{ul:c}oordinates()}{p_end}"
      exit 198 
   }
   else {
      if (substr(reverse("`coordinates'"),1,4) != "atd.") {
         local coordinates "`coordinates'.dta"
      }
      cap confirm file "`coordinates'"
      if (_rc == 0) & ("`replace'" == "") {
         di as err "{p}File {bf:`coordinates'} specified in option "   ///
                   "{bf:{ul:c}oordinates()} already exists{p_end}"
         exit 602
      }
      if ("`coordinates'" == "`attributes'") {
         di as err "{p}Options {bf:{ul:a}ttributes()} and "            ///
                   "{bf:{ul:c}oordinates()} cannot accept the same "   ///
                   "argument{p_end}"
         exit 198
      }
   }
}




*  ----------------------------------------------------------------------------
*  4. Read polygon files                                                       
*  ----------------------------------------------------------------------------

/* Start condition */
if ("`type'" == "polygon" ) {

/* Read and save coordinates */
quietly {
   insheet using "`MIF_FILE'", clear
   gen _ID = (lower(word(v1,1)) == "region")
   replace _ID = sum(_ID)
   drop if _ID == 0
   drop if (lower(word(v1,1)) == "region")
   gen _X = word(v1,1)
   gen _Y = word(v1,2)
   replace _X = "" if (_Y == "")
   destring _X, replace
   destring _Y, replace
   sort _ID, stable
   keep _ID _X _Y
   lab var _ID "Polygon ID"
   lab var _X "x-coordinates"
   lab var _Y "y-coordinates"
   tempvar UNIQUE
   by _ID : gen `UNIQUE' = _n==1
   count if `UNIQUE'
   local NREC = r(N)
   drop `UNIQUE'
   compress
}
save "`coordinates'", `replace'

/* Read and save attributes */
clear
if ("`MID'" == "Yes") {
   qui insheet using "`MIF_FILE'", clear
   qui gen TEMP = (lower(word(v1,1)) == "columns") * _n
   su TEMP, mean
   local START = r(max) + 1
   local NVAR = word(v1,2) in `r(max)'
   local END = `START' + `NVAR' - 1
   forval i = `START'/`END' {
	   local VAR = lower(word(v1,1)) in `i'
	   local VARLIST "`VARLIST'`VAR' "
   }
   qui insheet `VARLIST' using "`MID_FILE'", clear nonames
}
if ("`genid'" != "") {
   if ("`MID'" == "No") qui set obs `NREC'
   qui gen long `genid' = _n
   lab var `genid' "Polygon ID"
   order `genid'
   sort `genid'
}
if ("`MID'" == "Yes") | ("`genid'" != "") {
   qui compress
   save "`attributes'", `replace'
}

/* Compute polygon centroids and add them to attributes dataset */
if "`gencentroids'"!="" {
	quietly {
		use "`coordinates'", clear
		bys _ID : gen double TEMPa = (_X * _Y[_n+1]) - (_X[_n+1] * _Y)   ///
		          if _n>1 & _n<_N	
		bys _ID : gen double _AREA = sum(TEMPa)
		bys _ID : replace _AREA = _AREA[_N] / 2
		bys _ID : gen double TEMPx = (_X + _X[_n+1]) * (_X * _Y[_n+1] -   ///
		          _X[_n+1] * _Y) if _n>1 & _n<_N
		bys _ID : gen double _CX = sum(TEMPx)
		bys _ID : replace _CX = _CX[_N] / (6 * _AREA)
		bys _ID : gen double TEMPy = (_Y + _Y[_n+1]) * (_X * _Y[_n+1] -   ///
		          _X[_n+1] * _Y) if _n>1 & _n<_N
		bys _ID : gen double _CY = sum(TEMPy)
		bys _ID : replace _CY = _CY[_N] / (6 * _AREA)
		collapse _CX _CY, by(_ID)
		rename _ID `genid'
		rename _CX x`gencentroids'
		rename _CY y`gencentroids'
		lab var `genid' "Polygon ID"
		lab var x`gencentroids' "x-coordinate of polygon centroid"
		lab var y`gencentroids' "y-coordinate of polygon centroid"
		merge `genid' using "`attributes'"
		drop _merge
		sort `genid'
		compress
		save "`attributes'", replace
	}
}

/* End condition */
}




*  ----------------------------------------------------------------------------
*  5. Read polyline files                                                      
*  ----------------------------------------------------------------------------

/* Start condition */
if ("`type'" == "polyline" ) {

/* Read and save coordinates */
quietly {
   insheet using "`MIF_FILE'", clear
   gen _ID = (lower(word(v1,1)) == "pline")
   replace _ID = sum(_ID)
   drop if _ID == 0
   drop if (lower(word(v1,1)) == "pline")
   gen _X = word(v1,1)
   gen _Y = word(v1,2)
   replace _X = "" if (_Y == "")
   destring _X, replace
   destring _Y, replace
   sort _ID, stable
   keep _ID _X _Y
   lab var _ID "Polyline ID"
   lab var _X "x-coordinates"
   lab var _Y "y-coordinates"
   tempvar UNIQUE
   by _ID : gen `UNIQUE' = _n==1
   count if `UNIQUE'
   local NREC = r(N)
   drop `UNIQUE'
   compress
}
save "`coordinates'", `replace'

/* Read and save attributes */
clear
if ("`MID'" == "Yes") {
   qui insheet using "`MIF_FILE'", clear
   qui gen TEMP = (lower(word(v1,1)) == "columns") * _n
   su TEMP, mean
   local START = r(max) + 1
   local NVAR = word(v1,2) in `r(max)'
   local END = `START' + `NVAR' - 1
   forval i = `START'/`END' {
	   local VAR = lower(word(v1,1)) in `i'
	   local VARLIST "`VARLIST'`VAR' "
   }
   qui insheet `VARLIST' using "`MID_FILE'", clear nonames
}
if ("`genid'" != "") {
   if ("`MID'" == "No") qui set obs `NREC'
   qui gen long `genid' = _n
   lab var `genid' "Polyline ID"
   order `genid'
   sort `genid'
}
if ("`MID'" == "Yes") | ("`genid'" != "") {
   qui compress
   save "`attributes'", `replace'
}

/* End condition */
}




*  ----------------------------------------------------------------------------
*  6. Read point files                                                         
*  ----------------------------------------------------------------------------

/* Start condition */
if ("`type'" == "point" ) {


/* Read and save coordinates */
quietly {
   insheet using "`MIF_FILE'", clear
   keep if (lower(word(v1,1)) == "point")
   gen _ID = _n
   gen _X = word(v1,2)
   gen _Y = word(v1,3)
   destring _X, replace
   destring _Y, replace
   sort _ID
   keep _ID _X _Y
   lab var _ID "Point ID"
   lab var _X "x-coordinate"
   lab var _Y "y-coordinate"
   tempfile COORD
   save `COORD', replace
}

/* Read and save attributes */
if ("`MID'" == "Yes") {
   qui insheet using "`MIF_FILE'", clear
   qui gen TEMP = (lower(word(v1,1)) == "columns") * _n
   su TEMP, mean
   local START = r(max) + 1
   local NVAR = word(v1,2) in `r(max)'
   local END = `START' + `NVAR' - 1
   forval i = `START'/`END' {
	   local VAR = lower(word(v1,1)) in `i'
	   local VARLIST "`VARLIST'`VAR' "
   }
   qui insheet `VARLIST' using "`MID_FILE'", clear nonames
   tempfile DATA
   qui save `DATA', replace
}

/* Merge info and save attributes dataset */
use `COORD', clear
if ("`MID'" == "Yes") {
   qui merge using `DATA'
   qui drop _merge
}
sort _ID
qui compress
save "`attributes'", `replace'

/* End condition */
}




*  ----------------------------------------------------------------------------
*  7. End program                                                              
*  ----------------------------------------------------------------------------

restore
end



