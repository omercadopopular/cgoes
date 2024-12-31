*! -spmap-: Visualization of spatial data                                      
*! Version 1.3.2 - 09 January 2018 - StataCorp edit for stroke align           
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

program spmap, sortpreserve
version 9.2




*  ----------------------------------------------------------------------------
*  2. Define syntax                                                            
*  ----------------------------------------------------------------------------

syntax [varname(numeric default=none)] [if] [in] using/ ,   ///
        ID(varname numeric)                                 ///
                                                            ///
       [Area(varname numeric)]                              ///
       [SPLIT]                                              ///
       [MAP(string)]                                        ///
       [MFColor(string asis)]                               ///
       [MOColor(string asis)]                               ///
       [MOSize(string)]                                     ///
       [MOPattern(string asis)]                             ///
       [MOAlign(string asis)]                               ///
                                                            ///
       [CLMethod(name)]                                     /// 1.3.0 Bug fix
       [CLNumber(numlist max=1 >=2)]                        ///
       [CLBreaks(numlist min=3 ascending)]                  ///
       [EIRange(numlist min=1 max=2 sort)]                  ///
       [KMIter(numlist max=1 >0)]                           ///
       [NDFcolor(string asis)]                              ///
       [NDOcolor(string asis)]                              ///
       [NDSize(string asis)]                                ///
       [NDPattern(string asis)]                             /// 1.3.0
       [NDAlign(string asis)]                               ///
       [NDLabel(string)]                                    ///
                                                            ///
       [FColor(string asis)]                                ///
       [OColor(string asis)]                                ///
       [OSize(string)]                                      ///
       [OPattern(string)]                                   /// 1.3.0
       [OAlign(string)]                                     ///
                                                            ///
       [LEGENDA(string)]                                    ///
       [LEGTitle(string asis)]                              ///
       [LEGLabel(string)]                                   ///
       [LEGOrder(string)]                                   ///
       [LEGStyle(numlist max=1 >=0 <=3)]                    ///
       [LEGJunction(string)]                                ///
       [LEGCount]                                           ///
                                                            ///
       [POLygon(string asis)]                               ///
       [LINe(string asis)]                                  ///
       [POInt(string asis)]                                 ///
       [DIAgram(string asis)]                               ///
       [ARRow(string asis)]                                 ///
       [LABel(string asis)]                                 ///
       [SCAlebar(string asis)]                              ///
                                                            ///
       [POLYFIRST]                                          /// 1.2.0
       [GSize(numlist max=1 >=1)]                           /// 1.1.0
       [FREEstyle ]                                         /// 1.2.0
                                                            ///
       [*]




*  ----------------------------------------------------------------------------
*  3. Check syntax                                                             
*  ----------------------------------------------------------------------------

/* Check using file */
if (substr(reverse("`using'"),1,4) != "atd.") local using "`using'.dta"
capture confirm file "`using'"
if _rc {
   di as err "{p}File {bf:`using'} not found{p_end}"
   exit 601
}
preserve
qui use "`using'", clear
cap confirm numeric variable _ID _X _Y
if _rc {
   di as err "{p}File {bf:`using'} is not a valid "     ///
             "{help spmap##sd_basemap:{it:basemap}} "   ///
             "dataset {p_end}"
   exit 198
}
restore


/* Check option id() */
preserve
marksample TOUSE, novarlist
markout `TOUSE' `id'
qui keep if `TOUSE'
capture isid `id'
if _rc {
   restore
   di as err "{p}Variable {bf:`id'} specified in option {bf:{ul:id}()} "   ///
             "does not uniquely identify the observations{p_end}"
   exit 459
}
restore


/* Check option map() */
if ("`area'" != "") & ("`map'" != "") {
   local MAP "`map'"
   if ("`MAP'" == "using") local map `"`using'"'
   if (substr(reverse("`map'"),1,4) != "atd.") {
      local map "`map'.dta"
   }
   capture confirm file "`map'"
   if _rc {
      di as err "{p}File {bf:`map'} specified in option "   ///
                "{bf:{ul:map}()} not found{p_end}"
      exit 601
   }
   preserve
   qui use "`map'", clear
   cap confirm numeric variable _ID _X _Y
   if _rc {
      di as err "{p}File {bf:`map'} specified in option "              ///
                "{bf:{ul:map}()} is not a valid "                      ///
                "{help spmap##sd_backgroundmap:{it:backgroundmap}} "   ///
                "dataset {p_end}"
      exit 198
   }
   restore
}


/* Check options relevant only when attribute variable is specified */
if ("`varlist'" != "") {

   /* Check option clmethod() */
   if ("`clmethod'" != "") {
      local LIST "quantile boxplot eqint stdev kmeans custom unique"
      local LEN = length("`clmethod'")
      local OK = 0
      foreach W of local LIST { 
         if ("`clmethod'" == substr("`W'", 1, `LEN')) {
  	         local OK = 1
  	         local clmethod "`W'"
            continue, break
         }
      }
      if !`OK' {
         di as err "{p}Option {bf:{ul:clm}ethod()} accepts only "   ///
                   "one of the following keywords: "                ///
                   "{bf:{ul:q}uantile} "                            ///
                   "{bf:{ul:b}oxplot} "                             ///
                   "{bf:{ul:e}qint} "                               ///
                   "{bf:{ul:s}tdev} "                               ///
                   "{bf:{ul:k}means} "                              ///
                   "{bf:{ul:c}ustom} "                              ///
                   "{bf:{ul:u}nique} "                              ///
                   "{p_end}"
         exit 198
      }
   }

   /* Check option clnumber() */
   if ("`clmethod'" == "stdev") & ("`clnumber'" != "") {
      if (`clnumber' > 9) {
         di as err "{p}When you specify option "                 ///
                   "{bf:{ul:clm}ethod({ul:s}tdev)}, option "     ///
                   "{bf:{ul:cln}umber()} accepts only values "   ///
                   "between 2 and 9{p_end}"
         exit 198
      }
   }

   /* Check option clbreaks() */
   if ("`clmethod'" == "custom") & ("`clbreaks'" == "") {
      di as err "{p}If you specify option "               ///
                "{bf:{ul:clm}ethod({ul:c}ustom)}, you "   ///
                "are requested to specify also option "   ///
                "{bf:{ul:clb}reaks()}{p_end}"
      exit 198 
   }

   /* Set clnumber */
   if ("`clmethod'" == "boxplot") {
      local clnumber = 6
   }
   if ("`clmethod'" == "custom") {
      local NCLB : word count `clbreaks'
      local clnumber = `NCLB' - 1
   }
   if ("`clmethod'" == "unique") {
      marksample TEMP
      markout `TEMP' `id'
      qui tab `varlist' if `TEMP'
      local clnumber = r(r)
   }
   if ("`clnumber'" == "") {
      local clnumber = 4
   }

   /* Check option legorder() */
   if ("`legenda'" == "") local legenda "on"
   if ("`legenda'" == "on") & ("`legorder'" != "") {
      local LIST "hilo lohi"
      local EXIST : list posof "`legorder'" in LIST
      if !`EXIST' {
         di as err "{p}Option {bf:{ul:lego}rder()} accepts only one "   ///
                   "of the following keywords: {bf:`LIST'}{p_end}"
         exit 198 
      }
   }

/* End condition */
}


/* Check option legenda() */
if ("`legenda'" != "") {
   local LIST "on off"
   local EXIST : list posof "`legenda'" in LIST
   if !`EXIST' {
      di as err "{p}Option {bf:{ul:legenda}()} accepts only one "   ///
                "of the following keywords: {bf:`LIST'}{p_end}"
      exit 198 
   }
}

/* Check option leglabel() */
if ("`legenda'" == "on") & ("`varlist'" == "") & (`"`leglabel'"' == "") {
   di as err "{p}Since you have specified option "       ///
             "{bf:{ul:legenda}(on)} but you have not "   ///
             "specified any {it:attribute} variable, "   ///
             "you are requested to specify option "      ///
             "{bf:{ul:legl}abel()}{p_end}"
   exit 198 
}




*  ----------------------------------------------------------------------------
*  4. Execute option area()                                                    
*  ----------------------------------------------------------------------------

if ("`area'" != "") {
   quietly {
      preserve
      marksample TOUSE, novarlist
      markout `TOUSE' `id' `area'
      count if `TOUSE'
      if (r(N) == 0) error 2000
      keep if `TOUSE'
      keep `id' `area'
      tempvar ID V
      gen `ID' = `id'
      gen `V' = `area'
      keep `ID' `V'
      gen _ID = `ID'
      keep _ID `V'
      sort _ID
      tempfile CTG
      save `"`CTG'"', replace
      if ("`MAP'" == "using") {
         tempfile _ID
         keep _ID
         save `"`_ID'"', replace
      }
      use `"`using'"', clear
      cap drop _ID2
      if ("`split'" == "") gen _ID2 = _ID
      else {
         gen _ID2 = (_X == .)
         replace _ID2 = sum(_ID2)
      }
      sort _ID2, stable
      recast double _X _Y
      tempvar TEMP TEMPx TEMPy AREA CX CY
		by _ID2 : gen double `TEMP' = (_X * _Y[_n+1]) - (_X[_n+1] * _Y)   ///
		         if _n>1 & _n<_N
		by _ID2 : gen double `AREA' = sum(`TEMP')
		by _ID2 : replace `AREA' = `AREA'[_N] / 2
		by _ID2 : gen double `TEMPx' = (_X + _X[_n+1]) * (_X * _Y[_n+1] -   ///
		          _X[_n+1] * _Y) if _n>1 & _n<_N
		by _ID2 : gen double `CX' = sum(`TEMPx')
		by _ID2 : replace `CX' = `CX'[_N] / (6 * `AREA')
		by _ID2 : gen double `TEMPy' = (_Y + _Y[_n+1]) * (_X * _Y[_n+1] -   ///
		          _X[_n+1] * _Y) if _n>1 & _n<_N
		by _ID2 : gen double `CY' = sum(`TEMPy')
		by _ID2 : replace `CY' = `CY'[_N] / (6 * `AREA')
		replace `AREA' = abs(`AREA')
		collapse `AREA' `CX' `CY', by(_ID _ID2)
      merge _ID using `"`CTG'"'
      keep if _merge == 3
      sort _ID _ID2
      by _ID : replace `AREA' = sum(`AREA')
      by _ID : replace `AREA' = `AREA'[_N]
      tempvar DENS AREA2 BETA
      gen `DENS' = `V' / `AREA'
      sort `DENS'
      gen `AREA2' = `V' / `DENS'[_N]
      gen `BETA' = sqrt(`AREA2' / `AREA')
      keep _ID2 `CX' `CY' `BETA'
      sort _ID2
      save `"`CTG'"', replace
      use `"`using'"', clear
      cap drop _ID2 _ID0
      gen _ID0 = _ID
      if ("`split'" == "") gen _ID2 = _ID
      else {
         gen _ID2 = (_X == .)
         replace _ID2 = sum(_ID2)
      }
      sort _ID2, stable
      merge _ID2 using `"`CTG'"'
      keep if _merge == 3
      cap drop __CTG_*
      gen __CTG_X = `CX' + (_X - `CX') * `BETA'
      gen __CTG_Y = `CY' + (_Y - `CY') * `BETA'
      keep _ID0 _ID2 __CTG_*
      ren _ID2 _ID
      ren __CTG_X _X
      ren __CTG_Y _Y
      sort _ID0 _ID, stable
      save `"`CTG'"', replace
      if (`"`map'"' != "") {
         use `"`map'"', clear
         if ("`MAP'" == "using") {
            merge _ID using `"`_ID'"'
            keep if _merge == 3
         }
         ren _X __MAP_X
         ren _Y __MAP_Y
         keep __MAP_*
         tempfile BMAP
         save `"`BMAP'"', replace
         su __MAP_X
         local MAP_XMIN = r(min)
         local MAP_XMAX = r(max)
         su __MAP_Y
         local MAP_YMIN = r(min)
         local MAP_YMAX = r(max)
      }
      restore
   }
}




*  ----------------------------------------------------------------------------
*  5. Execute option polygon()                                                 
*  ----------------------------------------------------------------------------

if (`"`polygon'"' != "") {
   preserve
   spmap_polygon, `polygon'
   local POL_C `"`r(command)'"'
   local POL_XMIN = r(xmin)
   local POL_XMAX = r(xmax)
   local POL_YMIN = r(ymin)
   local POL_YMAX = r(ymax)
   local TITLE1 `"`r(title)'"'
   local KEY1   `"`r(key)'"'
   local LABEL1 `"`r(label)'"'
   local NK1 = r(nk)
   restore
}




*  ----------------------------------------------------------------------------
*  6. Execute option line()                                                    
*  ----------------------------------------------------------------------------

if (`"`line'"' != "") {
   preserve
   spmap_line, `line'
   local LIN_C `"`r(command)'"'
   local LIN_XMIN = r(xmin)
   local LIN_XMAX = r(xmax)
   local LIN_YMIN = r(ymin)
   local LIN_YMAX = r(ymax)
   local TITLE2 `"`r(title)'"'
   local KEY2   `"`r(key)'"'
   local LABEL2 `"`r(label)'"'
   local NK2 = r(nk)
   restore
}




*  ----------------------------------------------------------------------------
*  7. Execute option point()                                                   
*  ----------------------------------------------------------------------------

if (`"`point'"' != "") {
   preserve
   spmap_point, `point'
   local POI_C `"`r(command)'"'
   local POI_XMIN = r(xmin)
   local POI_XMAX = r(xmax)
   local POI_YMIN = r(ymin)
   local POI_YMAX = r(ymax)
   local TITLE3 `"`r(title)'"'
   local KEY3   `"`r(key)'"'
   local LABEL3 `"`r(label)'"'
   local NK3 = r(nk)
   restore
}




*  ----------------------------------------------------------------------------
*  8. Execute option diagram()                                                 
*  ----------------------------------------------------------------------------

if (`"`diagram'"' != "") {
   preserve
   spmap_diagram, `diagram'
   local DIA_C `"`r(command)'"'
   local DIA_XMIN = r(xmin)
   local DIA_XMAX = r(xmax)
   local DIA_YMIN = r(ymin)
   local DIA_YMAX = r(ymax)
   local TITLE4 `"`r(title)'"'
   local KEY4   `"`r(key)'"'
   local LABEL4 `"`r(label)'"'
   local NK4 = r(nk)
   restore
}




*  ----------------------------------------------------------------------------
*  9. Execute option arrow()                                                   
*  ----------------------------------------------------------------------------

if (`"`arrow'"' != "") {
   preserve
   spmap_arrow, `arrow'
   local ARR_C `"`r(command)'"'
   local ARR_XMIN = r(xmin)
   local ARR_XMAX = r(xmax)
   local ARR_YMIN = r(ymin)
   local ARR_YMAX = r(ymax)
   local TITLE5 `"`r(title)'"'
   local KEY5   `"`r(key)'"'
   local LABEL5 `"`r(label)'"'
   local NK5 = r(nk)
   restore
}




*  ----------------------------------------------------------------------------
*  10. Execute option label()                                                  
*  ----------------------------------------------------------------------------

if (`"`label'"' != "") {
   preserve
   spmap_label, `label'
   local LAB_C `"`r(command)'"'
   local LAB_XMIN = r(xmin)
   local LAB_XMAX = r(xmax)
   local LAB_YMIN = r(ymin)
   local LAB_YMAX = r(ymax)
   restore
}




*  ----------------------------------------------------------------------------
*  11. Define basic objects                                                    
*  ----------------------------------------------------------------------------

/* Marksample */
marksample TOUSE, novarlist
markout `TOUSE' `id'
qui count if `TOUSE'
if (r(N) == 0) error 2000

/* Preserve data */
preserve

/* Select relevant observations */
qui keep if `TOUSE'


/* Set defaults relevant only when area() & map() != "" */
if ("`area'" != "") & ("`map'" != "") {

   /* Set default background map fill color */
   if (`"`mfcolor'"' == "") local mfcolor "none"

   /* Set default background map outline color */
   if (`"`mocolor'"' == "") local mocolor "black"

   /* Set default background map outline size */
   if ("`mosize'" == "") local mosize "thin"

   /* Set default background map outline pattern */
   if ("`mopattern'" == "") local mopattern "solid"

   /* Set default background map outline alignment */
   if ("`moalign'" == "") local moalign "center"

/* End */
}


/* Set defaults relevant only when varlist != "" */
if ("`varlist'" != "") {

   /* Set default classification method */
   if ("`clmethod'" == "") local clmethod "quantile"

   /* Set default kmeans iterations */
   if ("`clmethod'" == "kmeans" & "`kmiter'" == "") local kmiter = 20

   /* Set default fill color for empty polygons */
   if (`"`ndfcolor'"' == "") local ndfcolor "white"

   /* Set default outline color for empty polygons */
   if (`"`ndocolor'"' == "") local ndocolor "black"

   /* Set default outline thickness for empty polygons */
   if (`"`ndsize'"' == "") local ndsize "thin"

   /* Set default outline pattern for empty polygons */
   if (`"`ndpattern'"' == "") local ndpattern "solid"

   /* Set default outline alignment for empty polygons */
   if (`"`ndalign'"' == "") local ndalign "center"

   /* Set default label for empty polygons */
   if (`"`ndlabel'"' == "") local ndlabel "No data"

/* End */
}


/* Set default fill color */
local fcolor_d "none"
if (`"`fcolor'"' == "") {
   if ("`varlist'" == "") local fcolor "`fcolor_d'"
   else {
      if ("`clmethod'" == "quantile") local fcolor "Greys"
      if ("`clmethod'" == "boxplot")  local fcolor "BuRd"
      if ("`clmethod'" == "eqint")    local fcolor "Greys"
      if ("`clmethod'" == "stdev")    local fcolor "BuRd"
      if ("`clmethod'" == "kmeans")   local fcolor "Greys"
      if ("`clmethod'" == "custom")   local fcolor "Greys"
      if ("`clmethod'" == "unique")   local fcolor "Paired"
   }
}

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
if ("`legenda'" == "") {
   if ("`varlist'" == "") local legenda "off"
   else local legenda "on"
}


/* Set defaults relevant only when legenda(on) & varlist != "" */
if ("`legenda'" == "on") & ("`varlist'" != "") {

   /* Set legend title when legtitle(varlab) */
   if (`"`legtitle'"' == "varlab") {
      local legtitle : variable label `varlist'
      if (`"`legtitle'"' == "") local legtitle "`varlist'"
   }

   /* Set default legend order */
   if ("`legorder'" == "") {
      if ("`clmethod'" == "unique") local legorder "lohi"
      else local legorder "hilo"
   }

   /* Set default legend style */
   if ("`legstyle'" == "") local legstyle = 1

   /* Set default legend junction when legstyle(2) */
   if ("`legstyle'" == "2" & "`legjunction'" == "") local legjunction " - "

   /* Get attribute variable format */
   local FMT : format `varlist'

/* End */
}




*  ----------------------------------------------------------------------------
*  12. Create classification variable for choropleth map                       
*  ----------------------------------------------------------------------------

/* Start condition */
if ("`varlist'" != "") {


/* Prepare working dataset */
keep `id' `varlist'
cap drop __CHO_*
qui clonevar __CHO_ID = `id'
qui clonevar __CHO_V = `varlist'
keep __CHO_*

/* Define attribute range */
su __CHO_V, meanonly 
local VMIN = r(min)
local VMAX = r(max)
if ("`clmethod'" == "eqint") & ("`eirange'" != "") {
   local VMIN : word 1 of `eirange'
   local NI : word count `eirange'
   if (`NI' == 2) local VMAX : word 2 of `eirange'
}
if ("`clmethod'" == "custom") {
   local VMIN : word 1 of `clbreaks'
   local VMAX : word `NCLB' of `clbreaks'
}
local VMIN = `VMIN' - 0.000001
local VMAX = `VMAX' + 0.000001

/* Set number of classes */
local NC = `clnumber'

/* Create classification matrix */
tempname CLASS
matrix `CLASS' = J(`NC', 4, .)
matrix colnames `CLASS' = class lower upper obs

/* Quantile method */
if ("`clmethod'" == "quantile") {
   qui pctile _clbreaks = __CHO_V, nq(`NC')
   forval i = 2/`NC' {
      if (_clbreaks[`i'] == _clbreaks[`i'-1]) {
         qui replace _clbreaks = . in `=`i'-1'
      }
   }
   sort _clbreaks
   qui xtile _class = __CHO_V, cutpoints(_clbreaks)
   qui tab _class
   if (r(r) != `NC') {
      local NC = r(r)
      tempname CLASS
      matrix `CLASS' = J(`NC', 4, .)
      matrix colnames `CLASS' = class lower upper obs
   }
   matrix `CLASS'[1,1] = 1
   matrix `CLASS'[1,2] = `VMIN'
   matrix `CLASS'[1,3] = _clbreaks[1]
   qui count if _class == 1
   matrix `CLASS'[1,4] = r(N)
   forval i = 2/`=`NC'-1' {
      matrix `CLASS'[`i',1] = `i'
      matrix `CLASS'[`i',2] = _clbreaks[`i'-1]
      matrix `CLASS'[`i',3] = _clbreaks[`i']
      qui count if _class == `i'
      matrix `CLASS'[`i',4] = r(N)
   }
   matrix `CLASS'[`NC',1] = `NC'
   matrix `CLASS'[`NC',2] = _clbreaks[`NC'-1]
   matrix `CLASS'[`NC',3] = `VMAX'
   qui count if _class == `NC'
   matrix `CLASS'[`NC',4] = r(N)
}

/* Boxplot method */
if ("`clmethod'" == "boxplot") {
   qui su __CHO_V, detail
   local LF = r(p25) - 1.5 * (r(p75) - r(p25))
   local UF = r(p75) + 1.5 * (r(p75) - r(p25))
   if (`LF' < `VMIN') {
      local VMIN = `VMIN' - 0.000001
      local LF = `VMIN'
   }
   if (`UF' > `VMAX') {
      local VMAX = `VMAX' + 0.000001
      local UF = `VMAX'
   }
   local CBREAKS "`VMIN' `LF' `r(p25)' `r(p50)' `r(p75)' `UF' `VMAX'"
   local IRECODE "`VMIN',`LF',`r(p25)',`r(p50)',`r(p75)',`UF',`VMAX'"
   qui gen _class = irecode(__CHO_V,`IRECODE')
   forval i = 1/`NC' {
      matrix `CLASS'[`i',1] = `i'
      matrix `CLASS'[`i',2] = `: word `i' of `CBREAKS''
      matrix `CLASS'[`i',3] = `: word `=`i'+1' of `CBREAKS''
      qui count if _class == `i'
      matrix `CLASS'[`i',4] = r(N)
   }
}

/* Equal interval method */
if ("`clmethod'" == "eqint") {
   local INT = (`VMAX' - `VMIN') / `NC'
   local CBREAKS "`VMIN' "
   local IRECODE "`VMIN',"
   forval i = 1/`=`NC'-1' {
      local CB = `VMIN' + `INT' * `i'
      local CBREAKS "`CBREAKS'`CB' "
      local IRECODE "`IRECODE'`CB',"
   }
   local CBREAKS "`CBREAKS'`VMAX'"
   local IRECODE "`IRECODE'`VMAX'"
   qui gen _class = irecode(__CHO_V,`IRECODE')
   forval i = 1/`NC' {
      matrix `CLASS'[`i',1] = `i'
      matrix `CLASS'[`i',2] = `: word `i' of `CBREAKS''
      matrix `CLASS'[`i',3] = `: word `=`i'+1' of `CBREAKS''
      qui count if _class == `i'
      matrix `CLASS'[`i',4] = r(N)
   }
}

/* Standard deviation method */
if ("`clmethod'"=="stdev") {
   qui su __CHO_V
   local VMEAN = r(mean)
   local VSD   = r(sd)
   if (`NC' == 2) {
      local CBREAKS "`VMIN' `VMEAN' `VMAX'"
      local IRECODE "`VMIN',`VMEAN',`VMAX'"
   }
   if (`NC' > 2) {
      local LIM  "0.6 1.0 1.2 1.6 2.0 1.8 2.1"
      local WID "1.2 1.0 0.8 0.8 0.8 0.6 0.6"
      local K = `NC' - 2
      local L : word `K' of `LIM'
      local W : word `K' of `WID'
      numlist "-`L'(`W')`L'"
      local NLIST "`r(numlist)'"
      local CBREAKS "`VMIN' "
      local IRECODE "`VMIN',"
      forval i = 1/`=`NC'-1' {
         local CB = `: word `i' of `NLIST'' * `VSD' + `VMEAN'
         local CBREAKS "`CBREAKS'`CB' "
         local IRECODE "`IRECODE'`CB',"
      }
      local CBREAKS "`CBREAKS'`VMAX'"
      local IRECODE "`IRECODE'`VMAX'"
   }
   qui gen _class = irecode(__CHO_V,`IRECODE')
   qui tab _class
   if (r(N) == 0) {
      di as err "{p}Problem with option {bf:{ul:clm}ethod({ul:s}tdev)} "   ///
                "-- Try to decrease the number of classes specified "      ///
                "in option {bf:{ul:cln}umber()}{p_end}"
      exit 198
   }
   forval i = 1/`NC' {
      matrix `CLASS'[`i',1] = `i'
      matrix `CLASS'[`i',2] = `: word `i' of `CBREAKS''
      matrix `CLASS'[`i',3] = `: word `=`i'+1' of `CBREAKS''
      qui count if _class == `i'
      matrix `CLASS'[`i',4] = r(N)
   }
}

/* kmeans method */
if ("`clmethod'" == "kmeans") {
   qui gen _class = .
   qui su __CHO_V
   local SDAM = r(Var) * (r(N)-1)
   local MAX = 0
   forval i = 1/`kmiter' {
      qui cluster kmeans __CHO_V, k(`NC') name(__KMEANS)
      local SDCM = 0
      forval j = 1/`NC' {
         qui summ __CHO_V if __KMEANS == `j'
         local TEMP = r(Var) * (r(N)-1)
         if (`TEMP' == .) local TEMP = 0
         local SDCM = `SDCM' + `TEMP'
      }
      local GVF = (`SDAM' - `SDCM') / `SDAM'
      if `GVF' > `MAX' {
         local MAX = `GVF'
         qui replace _class = __KMEANS
      }
      qui cluster drop _all
   }
   sort __CHO_V
   tempvar TEMP
   qui gen `TEMP' = 0
   qui replace `TEMP' = _class[_n] != _class[_n-1] 
   qui replace `TEMP' = sum(`TEMP')
   qui replace _class = `TEMP'
   forval i = 1/`NC' {
      matrix `CLASS'[`i',1] = `i'
      qui su __CHO_V if _class == `i'
      matrix `CLASS'[`i',2] = r(min)
      matrix `CLASS'[`i',3] = r(max)
      matrix `CLASS'[`i',4] = r(N)
   }
}

/* Custom  method */
if ("`clmethod'" == "custom") {
   local CBREAKS "`VMIN' "
   local IRECODE "`VMIN',"
   forval i = 2/`NC' {
      local CB : word `i' of `clbreaks'
      local CBREAKS "`CBREAKS'`CB' "
      local IRECODE "`IRECODE'`CB',"
   }
   local CBREAKS "`CBREAKS'`VMAX'"
   local IRECODE "`IRECODE'`VMAX'"
   qui gen _class = irecode(__CHO_V,`IRECODE')
   forval i = 1/`NC' {
      matrix `CLASS'[`i',1] = `i'
      matrix `CLASS'[`i',2] = `: word `i' of `CBREAKS''
      matrix `CLASS'[`i',3] = `: word `=`i'+1' of `CBREAKS''
      qui count if _class == `i'
      matrix `CLASS'[`i',4] = r(N)
   }
}

/* Unique method */
if ("`clmethod'" == "unique") {
   matrix `CLASS' = J(`NC', 2, .)
   matrix colnames `CLASS' = class obs
   qui egen _class = group(__CHO_V), label lname(_class)
   forval i = 1/`NC' {
      matrix `CLASS'[`i',1] = `i'
      qui count if _class == `i'
      matrix `CLASS'[`i',2] = r(N)
   }
}

/* Create no data class */
qui recode _class (. = 999)

/* Create and assign class labels */
if ("`legenda'" == "on") {
   if (`legstyle' == 0) {
      forval i = 1/`NC' {
         if ("`legcount'" != "") {
            if ("`clmethod'" != "unique") local OBS = `CLASS'[`i',4]
            else  local OBS = `CLASS'[`i',2]
            local OBS "(`OBS')"
         }
         local CLAB `"`CLAB'`i' "`OBS'" "'
      }
   }
   if (`legstyle' == 1 & "`clmethod'" != "unique") {
      forval i = 1/`NC' {
         local LL = `CLASS'[`i',2]
         if (`i' == 1) local LL = `LL' + 0.000001
         local LL = string(`LL', "`FMT'")
         if (c(dp) == "comma") local LL = subinstr("`LL'",".",",",.)
         local UL = `CLASS'[`i',3]
         if (`i' == `NC') local UL = `UL' - 0.000001
         local UL = string(`UL', "`FMT'")
         if (c(dp) == "comma") local UL = subinstr("`UL'",".",",",.)
         if ("`legcount'" != "") {
            local OBS = `CLASS'[`i',4]
            local OBS " (`OBS')"
         }
         if (`i' == 1) local CLAB `"`CLAB'`i' "[`LL',`UL']`OBS'" "'
         else local CLAB `"`CLAB'`i' "(`LL',`UL']`OBS'" "'
      }
   }
   if (`legstyle' == 2 & "`clmethod'" != "unique") {
      local LJ `"`legjunction'"'
      forval i = 1/`NC' {
         local LL = `CLASS'[`i',2]
         if (`i' == 1) local LL = `LL' + 0.000001
         local LL = string(`LL', "`FMT'")
         if (c(dp) == "comma") local LL = subinstr("`LL'",".",",",.)
         local UL = `CLASS'[`i',3]
         if (`i' == `NC') local UL = `UL' - 0.000001
         local UL = string(`UL', "`FMT'")
         if (c(dp) == "comma") local UL = subinstr("`UL'",".",",",.)
         if ("`legcount'" != "") {
            local OBS = `CLASS'[`i',4]
            local OBS " (`OBS')"
         }
         local CLAB `"`CLAB'`i' "`LL'`LJ'`UL'`OBS'" "'
      }
   }
   if (`legstyle' == 3 & "`clmethod'" != "unique") {
      forval i = 1/`NC' {
         local LBL ""
         if (`i' == 1) local LBL = `CLASS'[`i',2] + 0.000001
         if (`i' == `NC') local LBL = `CLASS'[`i',3] - 0.000001
         if ("`LBL'" != "") {
            local LBL = string(`LBL', "`FMT'")
            if (c(dp) == "comma") local LBL = subinstr("`LBL'",".",",",.)
         }
         if ("`legcount'" != "") {
            local OBS = `CLASS'[`i',4]
            if ("`LBL'" != "") local OBS " (`OBS')"
            else local OBS "(`OBS')"
            local CLAB `"`CLAB'`i' "`LBL'`OBS'" "'
         }
         else local CLAB `"`CLAB'`i' "`LBL' " "'
      }
   }
   if (`legstyle' > 0 & "`clmethod'" == "unique") {
      forval i = 1/`NC' {
         local LBL : label _class `i'
         if ("`legcount'" != "") {
            local OBS = `CLASS'[`i',2]
            local OBS " (`OBS')"
         }
         local CLAB `"`CLAB'`i' "`LBL'`OBS' " "'
      }
   }
   cap lab drop _class
   lab def _class `CLAB', modify
   lab val _class _class
   qui count if _class == 999
   if r(N) > 0 {
      if ("`legcount'" != "") lab def _class 999 `"`ndlabel' (`r(N)')"', add
      else lab def _class 999 "`ndlabel'", add
   }
}


/* End condition */
}




*  ----------------------------------------------------------------------------
*  13. Parse style lists                                                       
*  ----------------------------------------------------------------------------

/* Set max number of list items */
if ("`varlist'" == "") local MAX = 1
else local MAX = `NC'

/* Set list of available color palettes */
local PALETTE "`PALETTE' Accent Blues BrBG BuGn BuPu Dark2 GnBu Greens Greys"
local PALETTE "`PALETTE' OrRd Oranges PRGn Paired Pastel1 Pastel2 PiYG PuBu"
local PALETTE "`PALETTE' PuBuGn PuOr PuRd Purples RdBu RdGy RdPu RdYlBu"
local PALETTE "`PALETTE' RdYlGn Reds Set1 Set2 Set3 Spectral YlGn YlGnBu"
local PALETTE "`PALETTE' YlOrBr YlOrRd"
local PALETTE "`PALETTE' BuRd BuYlRd Heat Terrain Topological"
local PALETTE "`PALETTE' Blues2 Greens2 Greys2 Reds2 Rainbow"


/* Parse options relevant only when area() & map() != "" */
if ("`area'" != "") & ("`map'" != "") {

   /* Parse option mfcolor() */
   local mfcolor : word 1 of `mfcolor'

   /* Parse option mocolor() */
   local mocolor : word 1 of `mocolor'

   /* Parse option mosize() */
   local mosize : word 1 of `mosize'

   /* Parse option mopattern() */
   local mopattern : word 1 of `mopattern'

   /* Parse option moalign() */
   local moalign : word 1 of `moalign'

/* End */
}


/* Parse option ndfcolor() */
if ("`varlist'" != "") local ndfcolor : word 1 of `ndfcolor'

/* Parse option ndocolor() */
if ("`varlist'" != "") local ndocolor : word 1 of `ndocolor'

/* Parse option ndsize() */
if ("`varlist'" != "") local ndsize : word 1 of `ndsize'

/* Parse option ndpattern() */
if ("`varlist'" != "") local ndpattern : word 1 of `ndpattern'

/* Parse option ndalign() */
if ("`varlist'" != "") local ndalign : word 1 of `ndalign'


/* Parse option fcolor() */
local EXIST : list posof `"`fcolor'"' in PALETTE
if `EXIST' {
   if (`MAX' > 1) {
      spmap_color "`fcolor'" `MAX'
      local fcolor `"`s(colors)'"'
   }
   else {
      di as err "{p}When no {it:attribute} variable is "   ///
                "specified, option {bf:{ul:fc}olor()} "    ///
                "does not accept palette names{p_end}"
      exit 198 
   }
}
else {
   spmap_psl, l(`fcolor') m(`MAX') o({bf:{ul:fc}olor()}) d(`fcolor_d')
   local fcolor `"`s(pl)'"'
}

/* Parse option ocolor() */
local EXIST : list posof `"`ocolor'"' in PALETTE
if `EXIST' {
   if (`MAX' > 1) {
      spmap_color "`ocolor'" `MAX'
      local ocolor `"`s(colors)'"'
   }
   else {
      di as err "{p}When no attribute {it:variable} is "   ///
                "specified, option {bf:{ul:oc}olor()} "    ///
                "does not accept palette names{p_end}"
      exit 198 
   }
}
else {
   spmap_psl, l(`ocolor') m(`MAX') o({bf:{ul:oc}olor()}) d(`ocolor_d')
   local ocolor `"`s(pl)'"'
}

/* Parse option osize() */
spmap_psl, l(`osize') m(`MAX') o({bf:{ul:os}ize()}) d(`osize_d')
local osize `"`s(pl)'"'

/* Parse option opattern() */
spmap_psl, l(`opattern') m(`MAX') o({bf:{ul:op}attern()}) d(`opattern_d')
local opattern `"`s(pl)'"'

/* Parse option oalign() */
spmap_psl, l(`oalign') m(`MAX') o({bf:{ul:oa}lign()}) d(`oalign_d')
local oalign `"`s(pl)'"'




*  ----------------------------------------------------------------------------
*  14. Prepare working dataset                                                 
*  ----------------------------------------------------------------------------

/* No attribute variable*/
if ("`varlist'" == "") {
   quietly {
      tempfile IDFILE
      cap rename `id' _ID
      cap drop _class
      gen _class = 1
      keep _ID _class
      local NC = 1
      local NODATA = 0
      if ("`area'" != "") gen _ID0 = _ID
      keep _ID* _class
      if ("`area'" != "") sort _ID0 _ID
      else sort _ID
      save `"`IDFILE'"'
      if ("`area'" != "") use `"`CTG'"', clear
      else use `"`using'"', clear
      if ("`area'" != "") merge _ID0 using `"`IDFILE'"'
      else merge _ID using `"`IDFILE'"'
      keep if _merge == 3
      drop _merge
   }
}

/* Attribute variable */
if ("`varlist'" != "") {
   quietly {
      tempfile IDFILE
      rename __CHO_ID _ID
      if ("`area'" != "") gen _ID0 = _ID
      keep _ID* _class
      if ("`area'" != "") sort _ID0 _ID
      else sort _ID
      save `"`IDFILE'"'
      if ("`area'" != "") use `"`CTG'"', clear
      else use `"`using'"', clear
      if ("`area'" != "") merge _ID0 using `"`IDFILE'"'
      else merge _ID using `"`IDFILE'"'
      keep if _merge == 3
      drop _merge
      count if _class == 999
      local NODATA = r(N)
   }
}




*  ----------------------------------------------------------------------------
*  15. Compose main graph twoway command                                       
*  ----------------------------------------------------------------------------

/* Calculate x|ymin & x|ymax */
qui su _X, meanonly
local xmin = r(min)
local xmax = r(max)
qui su _Y, meanonly
local ymin = r(min)
local ymax = r(max)
if (`"`map'"' != "") {
   local xmin = min(`xmin' , `MAP_XMIN')
   local xmax = max(`xmax' , `MAP_XMAX')
   local ymin = min(`ymin' , `MAP_YMIN')
   local ymax = max(`ymax' , `MAP_YMAX')
}
if (`"`polygon'"' != "") {
   local xmin = min(`xmin' , `POL_XMIN')
   local xmax = max(`xmax' , `POL_XMAX')
   local ymin = min(`ymin' , `POL_YMIN')
   local ymax = max(`ymax' , `POL_YMAX')
}
if (`"`line'"' != "") {
   local xmin = min(`xmin' , `LIN_XMIN')
   local xmax = max(`xmax' , `LIN_XMAX')
   local ymin = min(`ymin' , `LIN_YMIN')
   local ymax = max(`ymax' , `LIN_YMAX')
}
if (`"`point'"' != "") {
   local xmin = min(`xmin' , `POI_XMIN')
   local xmax = max(`xmax' , `POI_XMAX')
   local ymin = min(`ymin' , `POI_YMIN')
   local ymax = max(`ymax' , `POI_YMAX')
}
if (`"`diagram'"' != "") {
   local xmin = min(`xmin' , `DIA_XMIN')
   local xmax = max(`xmax' , `DIA_XMAX')
   local ymin = min(`ymin' , `DIA_YMIN')
   local ymax = max(`ymax' , `DIA_YMAX')
}
if (`"`arrow'"' != "") {
   local xmin = min(`xmin' , `ARR_XMIN')
   local xmax = max(`xmax' , `ARR_XMAX')
   local ymin = min(`ymin' , `ARR_YMIN')
   local ymax = max(`ymax' , `ARR_YMAX')
}
if (`"`label'"' != "") {
   local xmin = min(`xmin' , `LAB_XMIN')
   local xmax = max(`xmax' , `LAB_XMAX')
   local ymin = min(`ymin' , `LAB_YMIN')
   local ymax = max(`ymax' , `LAB_YMAX')
}

/* Execute option scalebar() */
if (`"`scalebar'"' != "") {
   qui spmap_scalebar, `scalebar' xmin(`xmin') xmax(`xmax')   ///
                                  ymin(`ymin') ymax(`ymax')
   local SCA_C `"`r(command)'"'
   local SCA_XMIN = r(xmin)
   local SCA_XMAX = r(xmax)
   local SCA_YMIN = r(ymin)
   local SCA_YMAX = r(ymax)
   local xmin = min(`xmin' , `SCA_XMIN')
   local xmax = max(`xmax' , `SCA_XMAX')
   local ymin = min(`ymin' , `SCA_YMIN')
   local ymax = max(`ymax' , `SCA_YMAX')
}

/* Calculate aspect ratio of plot region*/
local JX = (`xmax'-`xmin') * 0.01
local JY = (`ymax' - `ymin') * 0.01
local xmin = `xmin' - `JX'
local xmax = `xmax' + `JX'
local ymin = `ymin' - `JY'
local ymax = `ymax' + `JY'
local AR = (`ymax' - `ymin') / (`xmax' - `xmin')

/* Set default xsize() and ysize() */
if ("`gsize'" != "") {
   if (`AR' >= 1) {
      local XS = `gsize'
      local YS = `AR' * `XS'
   }
   else {
      local YS = `gsize'
      local XS = (1 / `AR') * `YS'
   }
}
if ("`gsize'" == "") {
   if (`AR' >= 1) {
      if (`AR' <= 5) local gsize = 4
      else local gsize = 20 / `AR'
      local XS = `gsize'
      local YS = `AR' * `XS'
   }
   else {
      if (1 /`AR' <= 5) local gsize = 4
      else local gsize = 20 * `AR'
      local YS = `gsize'
      local XS = (1 / `AR') * `YS'
   }
}
local XSIZE "xsize(`XS')"
local YSIZE "ysize(`YS')"

/* Get xsize() and ysize() if specified */
if `"`options'"' !=  "" {
   tokenize `"`options'"'
   while `"`1'"' != "" {
      if (substr(`"`1'"',1,4) == "xsiz") {
         local XSIZE `"`1'"'
         local OPTLIST `"`OPTLIST'`1' "'
      }
      if (substr(`"`1'"',1,4) == "ysiz") {
         local YSIZE `"`1'"'
         local OPTLIST `"`OPTLIST'`1' "'
      }
      macro shift
   }
   foreach OPT of local OPTLIST {
      local options : subinstr local options "`OPT'" "", all
   }
}

/* Polygon */
if (`"`POL_C'"' != "") & ("`polyfirst'" != "") {
   cap drop _merge
   qui merge using "__POL.dta"
   local GRAPH `"`GRAPH'`POL_C' "'
}

/* Base map */
if ("`area'" != "") & (`"`map'"' != "") {
   cap drop _merge
   qui merge using `"`BMAP'"'
  	local FC "`mfcolor'"
   local OC "`mocolor'"
   if ("`OC'" == "none") local OC "`FC'"
   local OS "`mosize'"
   local OP "`mopattern'"
   local OA "`moalign'"
   if c(stata_version) >= 15 {
	local LA `"la("`OA'")"'
   }
   local GRAPH `"`GRAPH'(area __MAP_Y __MAP_X, nodropbase cmissing(n)"'
  	local GRAPH `"`GRAPH' fc("`FC'") fi(100) lc("`OC'") lw("`OS'")"'
  	local GRAPH `"`GRAPH' lp("`OP'") `LA') "'
}
local EMBPOL = 0
cap confirm variable _EMBEDDED
if (_rc == 0) {
   qui summ _EMBEDDED
   local EMIN = r(min)
   local EMAX = r(max)
   qui tab _EMBEDDED
   local ECAT = r(r)
   if (`EMIN' == 0 & `EMAX' == 1 & `ECAT' == 2) local EMBPOL = 1
}
if `EMBPOL' {
   local FC "`ndfcolor'"
   local OC "`ndocolor'"
   if ("`OC'" == "none") local OC "`FC'"
   local OS "`ndsize'"
   local OP "`ndpattern'"
   local OA "`ndalign'"
   if c(stata_version) >= 15 {
	local LA `"la("`OA'")"'
   }
   local GRAPH `"`GRAPH'(area _Y _X if _class == 999 & _EMBEDDED == 0,"'
   local GRAPH `"`GRAPH' nodropbase cmissing(n) fc("`FC'") fi(100)"'
   local GRAPH `"`GRAPH' lc("`OC'") lw("`OS'") lp("`OP'") `LA') "'
   forval i = 1/`NC' {
      local FC : word `i' of `fcolor'
      local OC : word `i' of `ocolor'
      if ("`OC'" == "none") local OC "`FC'"
      local OS : word `i' of `osize'
      local OP : word `i' of `opattern'
      local OA : word `i' of `oalign'
      if c(stata_version) >= 15 {
	local LA `"la("`OA'")"'
      }
      local GRAPH `"`GRAPH'(area _Y _X if _class == `i' & _EMBEDDED == 0,"'
      local GRAPH `"`GRAPH' nodropbase cmissing(n) fc("`FC'") fi(100)"'
      local GRAPH `"`GRAPH' lc("`OC'") lw("`OS'") lp("`OP'") `LA') "'
   }
   local FC "`ndfcolor'"
   local OC "`ndocolor'"
   if ("`OC'" == "none") local OC "`FC'"
   local OS "`ndsize'"
   local OP "`ndpattern'"
   local OA "`ndalign'"
   if c(stata_version) >= 15 {
	local LA `"la("`OA'")"'
   }
   local GRAPH `"`GRAPH'(area _Y _X if _class == 999 & _EMBEDDED == 1,"'
   local GRAPH `"`GRAPH' nodropbase cmissing(n) fc("`FC'") fi(100)"'
   local GRAPH `"`GRAPH' lc("`OC'") lw("`OS'") lp("`OP'") `LA') "'
   forval i = 1/`NC' {
      local FC : word `i' of `fcolor'
      local OC : word `i' of `ocolor'
      if ("`OC'" == "none") local OC "`FC'"
      local OS : word `i' of `osize'
      local OP : word `i' of `opattern'
      local OA : word `i' of `oalign'
      if c(stata_version) >= 15 {
	local LA `"la("`OA'")"'
      }
      local GRAPH `"`GRAPH'(area _Y _X if _class == `i' & _EMBEDDED == 1,"'
      local GRAPH `"`GRAPH' nodropbase cmissing(n) fc("`FC'") fi(100)"'
      local GRAPH `"`GRAPH' lc("`OC'") lw("`OS'") lp("`OP'") `LA') "'
   }
}
else {
   local FC "`ndfcolor'"
   local OC "`ndocolor'"
   if ("`OC'" == "none") local OC "`FC'"
   local OS "`ndsize'"
   local OP "`ndpattern'"
   local OA "`ndalign'"
   if c(stata_version) >= 15 {
	local LA `"la("`OA'")"'
   }
   local GRAPH `"`GRAPH'(area _Y _X if _class == 999, nodropbase cmissing(n)"'
   local GRAPH `"`GRAPH' fc("`FC'") fi(100) lc("`OC'") lw("`OS'")"'
   local GRAPH `"`GRAPH' lp("`OP'") `LA') "'
   forval i = 1/`NC' {
      local FC : word `i' of `fcolor'
      local OC : word `i' of `ocolor'
      if ("`OC'" == "none") local OC "`FC'"
      local OS : word `i' of `osize'
      local OP : word `i' of `opattern'
      local OA : word `i' of `oalign'
      if c(stata_version) >= 15 {
	local LA `"la("`OA'")"'
      }
      local GRAPH `"`GRAPH'(area _Y _X if _class == `i', nodropbase"'
      local GRAPH `"`GRAPH' cmissing(n) fc("`FC'") fi(100) lc("`OC'")"'
      local GRAPH `"`GRAPH' lw("`OS'") lp("`OP'") `LA') "'
   }
}

/* Polygon */
if (`"`POL_C'"' != "") & ("`polyfirst'" == "") {
   cap drop _merge
   qui merge using "__POL.dta"
   local GRAPH `"`GRAPH'`POL_C' "'
}

/* Line */
if (`"`LIN_C'"' != "") {
   cap drop _merge
   qui merge using "__LIN.dta"
   local GRAPH `"`GRAPH'`LIN_C' "'
}

/* Point */
if (`"`POI_C'"' != "") {
   cap drop _merge
   qui merge using "__POI.dta"
   local GRAPH `"`GRAPH'`POI_C' "'
}

/* Diagram */
if (`"`DIA_C'"' != "") {
   cap drop _merge
   qui merge using "__DIA.dta"
   local GRAPH `"`GRAPH'`DIA_C' "'
}

/* Arrow */
if (`"`ARR_C'"' != "") {
   cap drop _merge
   qui merge using "__ARR.dta"
   local GRAPH `"`GRAPH'`ARR_C' "'
}

/* Label */
if (`"`LAB_C'"' != "") {
   cap drop _merge
   qui merge using "__LAB.dta"
   local GRAPH `"`GRAPH'`LAB_C' "'
}

/* Scalebar */
if (`"`SCA_C'"' != "") {
   local GRAPH `"`GRAPH'`SCA_C' "'
}




*  ----------------------------------------------------------------------------
*  16. Set local legend keys and labels                                        
*  ----------------------------------------------------------------------------

/* Set number of keys */
local NK = `NC' + 1
local FV = 2
local ND = 1
if ("`area'" != "") & (`"`map'"' != "") {
   local NK = `NK' + 1
   local FV = `FV' + 1
   local ND = `ND' + 1
}
if (`"`POL_C'"' != "") & ("`polyfirst'" != "") {
   local NK = `NK' + `NK1'
   local FV = `FV' + `NK1'
   local ND = `ND' + `NK1'
}
local LV = `NK'
if (`NODATA' == 0) local ND ""
if `EMBPOL' local NK = `NK' + (`NC' + 1) 


/* legenda(off) */
if ("`legenda'" == "off") {
   local TITLE ""
   local KEY   ""
   local LABEL ""
}


/* legenda(on) & varlist == "" */
if ("`legenda'" == "on") & ("`varlist'" == "")  {

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
   local KEY "`FV' "

   /* Labels */
   local LABEL `"`"`leglabel'"' "'

/* End */
}


/* legenda(on) & varlist != "" */
if ("`legenda'" == "on") & ("`varlist'" != "")  {

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
   if ("`legorder'" == "hilo") numlist "`LV'/`FV'"
   else numlist "`FV'/`LV'"
   local KEY "`r(numlist)' "
   local KEY "`KEY'`ND' "

   /* Labels */
   if ("`legorder'" == "hilo") local SEQ "`NC'(-1)1"
   else local SEQ "1/`NC'"
   forval i = `SEQ' {
      local LBL : label (_class) `i'
      local LABEL `"`LABEL'`"`LBL'"' "'
   }
   if (`NODATA' > 0) {
      local LBL : label (_class) 999
      local LABEL `"`LABEL'`"`LBL'"' "'
   }

/* End */
}




*  ----------------------------------------------------------------------------
*  17. Set global legend                                                       
*  ----------------------------------------------------------------------------

/* Keys */
local ORDER `"`TITLE' `KEY' "'
forval i = 1/5 {
   if ("`NK`i''" != "") {
      local ORDER `"`ORDER'`TITLE`i'' "'
      foreach K in `KEY`i'' {
         local V = `NK' + `K'
         if (`i'==1) & ("`polyfirst'"!="") {
            local V = `K'
         }
         local ORDER `"`ORDER'`V' "'
         local KEY `"`KEY'`V' "'
      }
      local LABEL `"`LABEL'`LABEL`i'' "'
      local NK = `NK' + `NK`i''
      if (`i'==1) & ("`polyfirst'"!="") {
         local NK = `NK'
      }
   }
}

/* Labels */
local NVK : word count `KEY'
forval i = 1/`NVK' {
   local K : word `i' of `KEY'
   local L : word `i' of `LABEL'
   local LAB `"`LAB'lab(`K' `"`L'"') "'
}

/* Legend */
if (trim(`"`ORDER'"') == "") local LEGEND "legend(off)"
else {
   local ROWGAP "*0.50"
   if ("`clmethod'" != "unique") local ROWGAP "0"
   local LEGEND `"legend("'
   local LEGEND `"`LEGEND' order(`ORDER') `LAB'"'
   local LEGEND `"`LEGEND' symy(*0.70) symx(*0.25) keygap(*0.50)"'
   local LEGEND `"`LEGEND' col(1) rowgap(`ROWGAP')"'
   local LEGEND `"`LEGEND' size(*0.60)"'
   local LEGEND `"`LEGEND' region(lstyle(none) fcolor(none))"'
   local LEGEND `"`LEGEND' ring(0) position(7)"'
   local LEGEND `"`LEGEND' )"'
}




*  ----------------------------------------------------------------------------
*  18. Draw graph                                                              
*  ----------------------------------------------------------------------------

/* Draw graph */
if ("`freestyle'" == "") {
   graph twoway `GRAPH', `YSIZE' `XSIZE'  aspect(`AR')            ///
      yscale(r(`ymin' `ymax') off) xscale(r(`xmin' `xmax') off)   ///
      ylabel(`ymin' `ymax') xlabel(`xmin' `xmax')                 ///
      ytitle("") xtitle("")                                       ///
      `LEGEND'                                                    ///
      plotregion(margin(zero) style(none))                        ///
      graphregion(margin(zero) style(none))                       ///
      scheme(s1mono)                                              ///
      `options'
   }
else graph twoway `GRAPH', `LEGEND' `options'




*  ----------------------------------------------------------------------------
*  19. Housekeeping                                                            
*  ----------------------------------------------------------------------------

if (`"`polygon'"' != "") qui erase "__POL.dta"
if (`"`line'"' != "")    qui erase "__LIN.dta"
if (`"`point'"' != "")   qui erase "__POI.dta"
if (`"`diagram'"' != "") qui erase "__DIA.dta"
if (`"`arrow'"' != "")   qui erase "__ARR.dta"
if (`"`label'"' != "")   qui erase "__LAB.dta"




*  ----------------------------------------------------------------------------
*  20. End program                                                             
*  ----------------------------------------------------------------------------

restore
end



