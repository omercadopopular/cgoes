#delim ;
prog def xsvmat;
version 16.0;
/*
  Extended version of svmat
  producing a resultssset and (optionally) extra variables.
*!Author: Roger B. Newson
*!Date: 11 April 2020
*/

syntax [ anything(id="input matrix specification") ]  [ ,
  FRom(string asis)
  LIst(string asis)
  FRAme(string asis)
  SAving(string asis)  
  noREstore FAST FList(string)
  IDNum(string) NIDNum(name) IDStr(string) NIDStr(name)
  ROWEq(name) ROWNames(name) ROWEQNames(name) ROWLabels(name)
  COLEq(name) COLNames(name) COLEQNames(name) COLLabels(name)
  REName(string)
  FOrmat(string)
  *
  ];
/*

Input-source options:

-from- specifies a matrix expression,
  from which the source matrix is to be calculated.

Output-destination options:

-list()- contains a varlist of variables to be listed,
  expected to be present in the output data set
  and referred to by the new names if REName is specified,
  together with optional if and/or in subsetting clauses and/or list_options
  as allowed by the list command.
-frame()- specifies a frame to contain the output dataset.
-saving()- specifies a data set in which to save the output data set.
-norestore- specifies that the pre-existing data set
  is not restored after the output data set has been produced
  (set to norestore if FAST is present).
-fast- specifies that -xsvmat- will not preserve the original data set
  so that it can be restored if the user presses Break
  (intended for use by programmers).
  The user must specify at least one of the four options
  list, saving, norestore and fast,
  because they specify whether the output data set
  is listed to the log, saved to a disk file,
  written to the memory (destroying any pre-existing data set),
  or multiple combinations of these possibilities.
-flist- is a global macro name,
  belonging to a macro containing a filename list (possibly empty),
  to which -xsvmat- will append the name of the data set
  specified in the SAving() option.
  This enables the user to build a list of filenames
  in a global macro,
  containing the output of a sequence of model fits,
  which may later be concatenated using dsconcat (if installed) or append.

Output-variable options:

-idnum()- is an ID number for the output data set,
  used to create a numeric variable idnum in the output data set
  with the same value for all observations.
  This is useful if the output data set is concatenated
  with other output data sets using -dsconcat- (if installed) or -append-.
-nidnum()- specifies a name for the numeric ID variable (defaulting to -idnum-).
-idstr()- is an ID string for the output data set,
  used to create a string variable (defaulting to -idstr-) in the output data set
  with the same value for all observations.
-nidstr{}- specifies a name for the numeric ID variable (defaulting to -idstr-).
-roweq()- specifies a name for a new variable containing row equations.
-rownames()- specifies the name of a new variable containing row names.
-roweqnames()- specifies the name of a new variable
  containing row equations and names,
  separated with semicolons if necessary.
-rowlabels()- specifies the name of a new variable containing row labels.
-coleq()- specifies a name for a variable characteristic
  containing column equations.
-colnames- specifies the name of a variable characteristic
  containing column names.
-coleqnames()- specifies the name of a variable characteristic
  containing column equations and names,
  separated with semicolons if necessary.
-collabels()- specifies the name of a variable characteristic
 containing column labels.
-rename()- specifies a paired list of old and new variable names for renaming,
 similar to the option of the same name for -parmest-.
-format()- contains a list of the form varlist1 format1 ... varlistn formatn,
  where the varlists are lists of variables in the output data set
  and the formats are formats to be used for these variables
  in the output data sets.

*/


*
 Extract type and input matrix name
*;
local nargs: word count `anything';
if `nargs'>2 {;
  error 198;
};
else if `nargs'==0 {;
  local type "float";
  local A "";
};
else if `nargs'==1 {;
  local word1: word 1 of `anything';
  if inlist(`"`word1'"',"byte","float","int","long","double") {;
    local type "`word1'";
    local A "";
  };
  else {;
    local type "float";
    local A `"`word1'"';
  };
};
else if `nargs'==2 {;
  local type: word 1 of `anything';
  local A: word 2 of `anything';
};
if !inlist(`"`type'"',"byte","float","int","long","double") {;
  disp as error `"Invalid numeric type: `type'"';
  error 498;
};
if `"`A'"'!="" {;
  cap conf matr `A';
  if _rc {;
    disp as error `"Matrix `A' not found"';
    error 211;
  };
};


*
 Check that either matrix name or -from()- option is present
 (but not both),
 and compute input matrix if -from()- option is present
*;
if `"`A'"'=="" & `"`from'"'=="" {;
  disp as error "Either matrix name or from() option must be present";
  error 498;
};
else if `"`A'"'!="" & `"`from'"'!="" {;
  disp as error "Matrix name and from() option cannot both be present";
  error 498;
};
else if `"`A'"'=="" {;
  tempname A;
  cap matr def `A'=`from';
  if _rc {;
    disp as error "Invalid matrix expression in from() option:"
      _n `"`from'"';
    error 498;
  };
};


*
 Set restore to norestore if fast is present
 and check that the user has specified one of the five options:
 list and/or frame and/or saving and/or norestore and/or fast.
*;
if "`fast'"!="" {;
    local restore="norestore";
};
if (`"`list'"'=="")&(`"`frame'"'=="")&(`"`saving'"'=="")&("`restore'"!="norestore")&("`fast'"=="") {;
    disp as error "You must specify at least one of the five options:"
      _n "list(), frame(), saving(), norestore, and fast."
      _n "If you specify list(), then the output variables specified are listed."
      _n "If you specify frame()(), then the new data set is output to a ddat frame."
      _n "If you specify saving(), then the new data set is output to a disk file."
      _n "If you specify norestore and/or fast, then the new data set is created in the memory,"
      _n "and any existing data set in the memory is destroyed."
      _n "For more details, see {help xsvmat:on-line help for xsvmat}.";
    error 498;
};


*
 Parse frame() option if present
*;
if `"`frame'"'!="" {;
  cap frameoption `frame';
  if _rc {;
    disp as error `"Illegal frame option: `frame'"';
    error 498;
  };
  local framename "`r(namelist)'";
  local framereplace "`r(replace)'";
  local framechange "`r(change)'";
  if `"`framename'"'=="`c(frame)'" {;
    disp as error "frame() option may not specify current frame."
      _n "Use norestore or fast instead.";
    error 498;
  };
  if "`framereplace'"=="" {;
    cap noi conf new frame `framename';
    if _rc {;
      error 498;
    };
  };
};


*
 Store row variable labels in macros with names of form labi1
 if rowlabels() requested.
*;
if "`rowlabels'" != "" {;
        local xvlist : rownames(`A');
        local nxv : word count `xvlist';
        local i1 = 0;
        while `i1' < `nxv' {;
                local i1 = `i1' + 1;
                local xvcur : word `i1' of `xvlist';
                local lab`i1' "";
                if `"`xvcur'"'=="_cons" {;
                    local lab`i1' "Constant";
                };
                else {;
                    capture local lab`i1' : variable label `xvcur';
                };
        };
};


*
 Store column variable labels in macros with names of form clabi1
 if rowlabels() requested.
*;
if "`collabels'" != "" {;
        local yvlist : colnames(`A');
        local nyv : word count `yvlist';
        local i1 = 0;
        while `i1' < `nyv' {;
                local i1 = `i1' + 1;
                local yvcur : word `i1' of `yvlist';
                local clab`i1' "";
                if `"`yvcur'"'=="_cons" {;
                    local clab`i1' "Constant";
                };
                else {;
                    capture local clab`i1' : variable label `yvcur';
                };
        };
};


*
 Beginning of frame block (NOT INDENTED)
*;
local oldframe=c(frame);
tempname tempframe;
frame create `tempframe';
frame `tempframe' {;


*
 Create new dataset
 with 1 obs per matrix row
*;
local nrowsA=rowsof(`A');
qui set obs `nrowsA';
local exmore=c(more);
set more off;
qui svmat `type' `A', `options';
set more `exmore';


*
 Add characteristics identifying columns
*;
unab matcolvars: *;
if "`collabels'" != "" {;
  local i1=0;
  foreach Y of var `matcolvars' {;
    local i1=`i1'+1;
    char def `Y'[`collabels'] `"`clab`i1''"';
  };
};
if "`coleqnames'"!="" {;
  local charvals: colfullnames `A';
  local i1=0;
  foreach Y of var `matcolvars' {;
    local i1=`i1'+1;
    local charcur: word `i1' of `charvals';
    char def `Y'[`coleqnames'] `"`charcur'"';
  };
};
if "`coleq'"!="" {;
  local charvals: coleq `A';
  local i1=0;
  foreach Y of var `matcolvars' {;
    local i1=`i1'+1;
    local charcur: word `i1' of `charvals';
    char def `Y'[`coleq'] `"`charcur'"';
  };
};
if "`colnames'"!="" {;
  local charvals: colnames `A';
  local i1=0;
  foreach Y of var `matcolvars' {;
    local i1=`i1'+1;
    local charcur: word `i1' of `charvals';
    char def `Y'[`colnames'] `"`charcur'"';
  };
};


*
 Add variables identifying rows
 and move them to the beginning of the variable order
*;
if "`rowlabels'" != "" {;
        qui gene str1 `rowlabels' = "";
        local i1 = 0;
        while `i1' < `nxv' {;
                local i1 = `i1' + 1;
                qui replace `rowlabels' = `"`lab`i1''"' in `i1';
        };
        order `rowlabels';
        label variable `rowlabels' "Row variable label";
};
if "`roweqnames'"!="" {;
  tempvar teqnames;
  svroweq `A' `teqnames';
  svrown `A' `roweqnames';
  qui replace `roweqnames'=`teqnames'+":"+`roweqnames' if !missing(`teqnames') & `teqnames'!="_";
  drop `teqnames';
  order `roweqnames';
  lab var `roweqnames' "Equation and row name";
};
if "`rownames'"!="" {;
  svrown `A' `rownames';
  order `rownames';
  label variable `rownames' "Row name";
};
if "`roweq'"!="" {;
  svroweq `A' `roweq';
  order `roweq';
  label variable `roweq' "Equation name";
};


*
 Create numeric and/or string ID variables if requested
 and move them to the beginning of the variable order
*;
if ("`nidstr'"=="") local nidstr "idstr";
if("`idstr'"!=""){;
    qui gene str1 `nidstr'="";
    qui replace `nidstr'=`"`idstr'"';
    qui compress `nidstr';
    qui order `nidstr';
    lab var `nidstr' "String ID";
};
if ("`nidnum'"=="") local nidnum "idnum";
if("`idnum'"!=""){;
    qui gene double `nidnum'=real("`idnum'");
    qui compress `nidnum';
    qui order `nidnum';
    lab var `nidnum' "Numeric ID";
};


*
 Rename variables if requested
*;
if "`rename'"!="" {;
    local nrename:word count `rename';
    if mod(`nrename',2) {;
        disp as text "Warning: odd number of variable names in rename list - last one ignored";
        local nrename=`nrename'-1;
    };
    local nrenp=`nrename'/2;
    local i1=0;
    while `i1'<`nrenp' {;
        local i1=`i1'+1;
        local i3=`i1'+`i1';
        local i2=`i3'-1;
        local oldname:word `i2' of `rename';
        local newname:word `i3' of `rename';
        cap{;
            confirm var `oldname';
            confirm new var `newname';
        };
        if _rc!=0 {;
            disp as text "Warning: it is not possible to rename `oldname' to `newname'";
        };
        else {;
            rename `oldname' `newname';
        };
    };
};


*
 Format variables if requested
*;
if `"`format'"'!="" {;
    local vlcur "";
    foreach X in `format' {;
        if index(`"`X'"',"%")!=1 {;
            * varlist item *;
            local vlcur `"`vlcur' `X'"';
        };
        else {;
            * Format item *;
            unab Y : `vlcur';
            conf var `Y';
            cap format `Y' `X';
            local vlcur "";
        };
    };
};


*
 List variables if requested
*;
if `"`list'"'!="" {;
    list `list';
};


*
 Save data set if requested
*;
if(`"`saving'"'!=""){;
    capture noisily save `saving';
    if(_rc!=0){;
        disp in red `"saving(`saving') invalid"';
        exit 498;
    };
    tokenize `"`saving'"',parse(" ,");
    local fname `"`1'"';
    if(index(`"`fname'"'," ")>0){;
        local fname `""`fname'""';
    };
    * Add filename to file list in FList if requested *;
    if(`"`flist'"'!=""){;
        if(`"$`flist'"'==""){;
            global `flist' `"`fname'"';
        };
        else{;
            global `flist' `"$`flist' `fname'"';
        };
    };
};


*
 Copy new frame to old frame if requested
*;
if "`restore'"=="norestore" {;
  frame copy `tempframe' `oldframe', replace;
};


};
*
 End of frame block (NOT INDENTED)
*;


*
 Rename temporary frame to frame name (if frame is specified)
 and change current frame to frame name (if requested)
*;
if "`framename'"!="" {;
  if "`framereplace'"=="replace" {;
    cap frame drop `framename';
  };
  frame rename `tempframe' `framename';
  if "`framechange'"!="" {;
    frame change `framename';
  };
};


end;


program define svroweq;
version 10.0;
/*
 Save row equation names from `matrix' in string variable `roweq'.
 (This routine is designed to be used with svmat.)
*/
args matrix roweq;

if "`matrix'" == "" {;
        di in r "No matrix specified";
        error 498;
};
if "`roweq'" == "" {;
        di in r "No variable name specified";
        error 498;
};
local nrow = rowsof(`matrix');

* Create variable `roweq' *;
tempname tempmat;
qui set obs `nrow';
qui gen str1 `roweq' = "";
local rowind = 0;
while `rowind' < `nrow'{;
        local rowind = `rowind' + 1;
        matr def `tempmat'=`matrix'[`rowind'..`rowind',1..1];
        local namec : roweq(`tempmat');
        qui replace `roweq' = "`namec'" in `rowind';
};

end;


program define svrown;
version 10.0;
/*
 Save row names from `matrix' in string variable `rowname'.
 (This routine is designed to be used with svmat.)
*/
args matrix rowname;

if "`matrix'" == "" {;
        di in r "No matrix specified";
        error 498;
};
if "`rowname'" == "" {;
        di in r "No variable name specified";
        error 498;
};
local nrow = rowsof(`matrix');

* Create variable `rowname' *;
tempname tempmat;
qui set obs `nrow';
qui gene str1 `rowname' = "";
local rowind = 0;
while  `rowind' < `nrow' {;
        local rowind = `rowind' + 1;
        matr def `tempmat'=`matrix'[`rowind'..`rowind',1..1];
        local namec : rownames(`tempmat');
        qui replace `rowname' = "`namec'" in `rowind';
};

end;

prog def frameoption, rclass;
version 16.0;
*
 Parse frame() option
*;

syntax name [, replace CHange ];

return local change "`change'";
return local replace "`replace'";
return local namelist "`namelist'";

end;
