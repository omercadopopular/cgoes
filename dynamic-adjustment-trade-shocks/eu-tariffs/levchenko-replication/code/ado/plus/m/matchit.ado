*! 1.5.2 J.D. Raffo May 2020
program matchit
 version 12
 syntax varlist(min=2 max=2) ///
  [using/] ///
   [, IDUsing(name) TXTUsing(name)] ///
   [SIMilmethod(string asis)] ///
   [Weights(string)] [WGTFile(string)] ///
   [Score(string)] ///
   [Threshold(real .5)] ///
   [Flag(real 20)] [DIagnose] [STOPWordsauto] [SWThreshold(real .2)] ///
   [OVERride] ///
   [Generate(string)] [KEEPMata] [TIme]

 // freqindex check
 cap which freqindex
 if (_rc!=0){
  di "freqindex not found."
  di "matchit requires freqindex to be installed. You can get it in SSC."
  error _rc
 }
 // version check
 local mystr=cond(_caller()>=13,"str2045", "str244")

 // setup //////////////////////////////////////
 if ("`using'"=="") {
  local match "columns"
  tokenize `varlist'
  local str1 `1'
  local str2 `2'
  di "Matching columns `str1' and `str2'"
  confirm string variable `str1'
  confirm string variable `str2'
  local curtype1:type `str1'
  local curtype2:type `str2'
 }
 else {
  local match "index"
  tokenize `varlist'
  local idmaster `1'
  local txtmaster `2'
  di "Matching current dataset with `using'"
  confirm numeric variable `idmaster'
  confirm string variable `txtmaster'
  local curtype1:type `txtmaster'
  confirm file "`using'"

  // checks if ok to wipe master dataset
  qui describe
  if (r(changed)>0 & "`override'"=="") {
   di " "
   di "(!) Unsaved changes will be destroyed after running matching procedure."
   di "    (note: use OVERRIDE option to bypass warning)"
   error 4
  }
  capture mata: THRESHOLD=`threshold'
  if (_rc!=0) {
   di "`threshold' does not seem a valid threshold."
   error _rc
  }
 }
 local wgtloaded=0
 if ("`weights'"=="") local weights "noweights"
 if ("`weights'"!="noweights") {
   capture mata: weightfunc_p=&weight_`weights'()
   if (_rc!=0) {
    di "`weights' not found as a weights function. Check spelling."
    error _rc
   }
   di "Applying weights function: `weights'"
   if ("`wgtfile'"!=""){
    confirm file "`wgtfile'"
	di "Loading `wgtfile' as weights file..." _continue
	preserve
	use "`wgtfile'", clear
	mata: WFREQ=st_data(.,"freq"); WGRAM=st_sdata(.,"grams"); WGTARRAY=asarray_create()
	mata: load_weights_to_array(WGTARRAY, WGRAM, WFREQ)
	local wgtloaded=1
	restore
	di "Done!"
   }
 }
 //
 if (`"`similmethod'"'=="") local similmethod "bigram"
 gettoken similfunc similargs : similmethod , parse(",") quotes
 if (`"`similfunc'"'=="") local similfunc "bigram"

 capture mata: similfunc_p=&simf_`similfunc'()
 if (_rc!=0) {
  di "`similfunc' not found as a similarity function. Check spelling."
  error _rc
 }
  di "Similarity function: `similfunc'"
  if (`"`similargs'"'!=`""') {
  local testtxt `""This is just a test""'
  local args_plugin `"`similargs'"'
  capture mata: TEST=(*similfunc_p)(`testtxt'`args_plugin')
  if (_rc!=0) {
   di `"There seems to be an error with the chosen optional argument(s): `similargs'"'
   di "(note: break is recommended. Press any key to ignore this and continue."
   set more on
   more
   set more off
  }
  cap mata: mata drop TEST
 }
 if ("`score'"=="") local score "jaccard"
 capture mata: scorefunc_p=&score_`score'()
 if (_rc!=0) {
  di "`score' not found as a score computing function. Check spelling."
  error _rc
 }
 mata: TIME=0
 if ("`time'"!="") {
  di c(current_date) " " c(current_time)
  mata: TIME=1
 }
 capture mata: FLAG=`flag'
 if (_rc!=0) {
   di "`flag' does not seem a valid flag value."
   error _rc
 }
 if (`flag'<=0) {
   di "Flag cannot equal or lower than zero."
   exit
  }
  // setup ends ///////////////

 // matching columns
 if ("`match'"=="columns") {
  preserve
  if ("`generate'"=="") local similscore "similscore"
 else local similscore "`generate'"
 cap gen double `similscore'=.
  if (_rc!=0) {
   di "`similscore' does not seem a valid name for the score variable."
  error _rc
  }
  if ("`weights'"!="noweights") {
   if (`wgtloaded'==0){
	mata: WGTARRAY=asarray_create()
	freqindex `str1', keepm incm(WGTARRAY) sim(`similmethod') nost
	freqindex `str2', keepm incm(WGTARRAY) sim(`similmethod') nost
   }
   mata: col_core_computing_wgt("`str1' `str2'","`similscore'",scorefunc_p, weightfunc_p, WGTARRAY, TIME, FLAG, similfunc_p`args_plugin')
  }
  else {
   mata: col_core_computing("`str1' `str2'","`similscore'",scorefunc_p, TIME, FLAG, similfunc_p`args_plugin')
  }
  if ("`keepmata'"==""){
   cap mata: mata drop TXTW
   cap mata: mata drop WGTARRAY P_WGTARRAY weightfunc_p
   cap mata: mata drop IDM
   cap mata: mata drop IDU
   cap mata: mata drop INDEXU
   cap mata: mata drop THRESHOLD
   cap mata: mata drop TXTM
   cap mata: mata drop TXTU
   cap mata: mata drop WGTU
   cap mata: mata drop newvars
   cap mata: mata drop scorefunc_p
   cap mata: mata drop similfunc_p
   cap mata: mata drop TIME
   cap mata: mata drop FLAG
   cap mata: mata drop STOPWARRAY
  }
  restore, not
  if ("`time'"!="") di c(current_date) " " c(current_time)

  exit
 }
 // Diagnose module
 if("`diagnose'"=="diagnose"){
   di " "
   di "Performing preliminary diagnosis"
   di "--------------------------------"
   preserve
   tempfile diagfile1
   local mN=_N
   di " "
   di "Analyzing Master file"
   freqindex `txtmaster' , sim(`similmethod') keepm
   mata: mata drop TXTW P_WGTARRAY
   qui ren freq freqm
   qui gen sharem=freqm/`mN'
   local curtype:type grams
   if ("`curtype'"=="strL") qui recast `mystr' grams, force
   qui save `diagfile1', replace
   gsort -freqm
   qui drop if _n>20
   qui ren (freqm sharem) (freq grams_per_obs)
   format %9.4f grams_per_obs
   format %9.0f freq
   di "List of most frequent grams in Master file:"
   cap list grams freq grams_per_obs, t clean compress ab(50) str(50)
   if _rc!=0 list grams freq grams_per_obs, t clean compress ab(33) str(33)
   else list grams freq grams_per_obs, t clean compress ab(50) str(50)
   di " "
   di "Analyzing Using file"
   use "`using'", clear
   local uN=_N
   freqindex `txtusing', sim(`similmethod') keepm
   mata: mata drop TXTW P_WGTARRAY
   gen share=freq/`uN'
   gen grams_per_obs=share
   gsort -freq
   format %9.4f grams_per_obs
   format %9.0f freq
   local upb=cond(_N>20, 20, _N)
   di "List of most frequent grams in Using file:"
   cap list grams freq grams_per_obs in 1/`upb', t clean compress ab(50) str(50)
   if _rc!=0 list grams freq grams_per_obs in 1/`upb', t clean compress ab(33) str(33)
   else list grams freq grams_per_obs in 1/`upb', t clean compress ab(50) str(50)
   drop grams_per_obs
   local curtype:type grams
   if ("`curtype'"=="strL") qui recast `mystr' grams, force
   qui merge m:m grams using `diagfile1'
   qui gen max_common_space=sharem*share*100
   qui replace max_common_space=0 if max_common_space==.
   qui replace max_common_space=100 if max_common_space>100
   qui gen crosspairs=freqm*freq
   qui gen grams_per_obs=(freqm+freq)/(`mN'+`uN')
   format %9.4f grams_per_obs
   format %9.2f max_common_space
   format %9.0f crosspairs
   qui sum max_common_space
   local psMax=round(100-`r(max)',.01)
   if (`r(max)'>100) local psMax=0
   di " "
   di "Overall diagnosis"
   di "Pairs being compared: Master(`mN') x Using(`uN') = " `mN'*`uN'
   di "Estimated maximum reduction by indexation (%):" round(`psMax',.01)
   di "(note: this is an indication, final results may differ)"
   di " "
   di "List of grams with greater negative impact to indexation:"
   di "(note: values are estimated, final results may differ)"
   gsort -crosspairs
   local upb=cond(_N>20, 20, _N)
   cap list grams crosspairs max_common_space grams_per_obs in 1/`upb', t clean compress ab(50) str(50)
   if _rc!=0 list grams crosspairs max_common_space grams_per_obs in 1/`upb', t clean compress ab(33) str(33)
   else list grams crosspairs max_common_space grams_per_obs in 1/`upb', t clean compress ab(50) str(50)
   di " "
   restore
 }

 // Matching datasets
 // Loading data to mata
 preserve
 if ("`weights'"!="noweights" & `wgtloaded'==0){
   capture mata: WGTARRAY=asarray_create()
   freqindex `idmaster' `txtmaster', keepm incm(WGTARRAY) sim(`similmethod') nost
   mata: IDM=IDW; TXTM=TXTW
   mata: mata drop IDW TXTW
  }
 else if ("`stopwordsauto'"=="stopwordsauto") {
   capture mata: WGTARRAY=asarray_create()
   freqindex `idmaster' `txtmaster', keepm incm(WGTARRAY) sim(`similmethod') nost
   mata: IDM=IDW; TXTM=TXTW
   mata: mata drop IDW TXTW
  }
 else {
   mata: IDM=st_data(.,"`idmaster'"); TXTM=st_sdata(.,"`txtmaster'")
  }
 di "Loading USING file: `using'"
 use "`using'", clear
 confirm numeric variable `idusing'
 confirm string variable `txtusing'
 local curtype2:type `txtusing'
 if ("`weights'"!="noweights" & `wgtloaded'==0) {
  freqindex `idusing' `txtusing', keepm incm(WGTARRAY) sim(`similmethod') nost
  mata: IDU=IDW; TXTU=TXTW
  mata: mata drop IDW TXTW
  mata: STOPWARRAY=asarray_create()
  if ("`stopwordsauto'"=="stopwordsauto") mata: autostopwords(`swthreshold', IDM, IDU, WGTARRAY, STOPWARRAY)
 }
 else if ("`stopwordsauto'"=="stopwordsauto") {
  freqindex `idusing' `txtusing', keepm incm(WGTARRAY) sim(`similmethod') nost
  mata: IDU=IDW; TXTU=TXTW
  mata: mata drop IDW TXTW
  mata: STOPWARRAY=asarray_create()
  mata: autostopwords(`swthreshold', IDM, IDU, WGTARRAY, STOPWARRAY)
 }
 else {
  mata: IDU=st_data(.,"`idusing'"); TXTU=st_sdata(.,"`txtusing'"); STOPWARRAY=asarray_create()
 }
 clear

// Creating index for USING
 di "Indexing USING file."
 mata: INDEXU=asarray_create()
 mata: WGTU=asarray_create("real")
 if ("`weights'"!="noweights") mata: index_array_wgt(INDEXU, STOPWARRAY, IDU, TXTU, WGTU, weightfunc_p, WGTARRAY, TIME, FLAG,similfunc_p`args_plugin')
 else mata: index_array(INDEXU, STOPWARRAY, IDU, TXTU, WGTU, TIME, FLAG,similfunc_p`args_plugin')

 di "Computing results"
 // checks vars naming
 if ("`generate'"=="") local similscore "similscore"
 else local similscore "`generate'"
 local i =1
 local vartemp = "`idusing'"
 while ("`vartemp'"=="`idmaster'"| "`vartemp'"=="`txtmaster'"){
  local vartemp "`idusing'`i'"
  local i = `i'+1
  }
 local idusing = "`vartemp'"
 local i =1
 local vartemp = "`txtusing'"
 while ("`vartemp'"=="`idmaster'"| "`vartemp'"=="`txtmaster'" | "`vartemp'"=="`idusing'"){
  local vartemp "`txtusing'`i'"
  local i = `i'+1
 }
 local txtusing = "`vartemp'"
 local i =1
 local vartemp = "`similscore'"
 while ("`vartemp'"=="`idmaster'"| "`vartemp'"=="`txtmaster'" | "`vartemp'"=="`idusing'" | "`similscore'"=="`txtusing'"  ){
  local vartemp "`similscore'`i'"
  local i = `i'+1
 }
 local similscore = "`vartemp'"
 mata: newvars=st_addvar(("double", "`curtype1'","double", "`curtype2'","double"),("`idmaster'", "`txtmaster'", "`idusing'", "`txtusing'", "`similscore'"))

 if ("`weights'"!="noweights")  mata: core_computing_wgt(THRESHOLD,IDM,TXTM,IDU,TXTU,INDEXU,WGTU,WGTARRAY,STOPWARRAY,scorefunc_p, weightfunc_p, TIME, FLAG,similfunc_p`args_plugin')
 else  mata: core_computing(THRESHOLD,IDM,TXTM,IDU,TXTU,INDEXU,WGTU,STOPWARRAY,scorefunc_p,TIME, FLAG,similfunc_p`args_plugin')

 qui compress
 if ("`keepmata'"==""){
   cap mata: mata drop WGTARRAY
   cap mata: mata drop P_WGTARRAY
   cap mata: mata drop weightfunc_p
   cap mata: mata drop STOPWARRAY
   cap mata: mata drop TXTW
   cap mata: mata drop IDM
   cap mata: mata drop IDU
   cap mata: mata drop INDEXU
   cap mata: mata drop THRESHOLD
   cap mata: mata drop TXTM
   cap mata: mata drop TXTU
   cap mata: mata drop WGTU
   cap mata: mata drop newvars
   cap mata: mata drop scorefunc_p
   cap mata: mata drop similfunc_p
   cap mata: mata drop TIME
   cap mata: mata drop FLAG
  }
 restore, not
if ("`time'"!="") di c(current_date) " " c(current_time)
end

// computing scores columns
mata:
void autostopwords(stopwordthreshold, idvar, usingidvar, weightarray, stopwordarray)
{
  stata(`"di "Generating stopwords automatically, threshold set at:"'+strofreal(stopwordthreshold)+`"""')
  Q2rows=rows(idvar)+rows(usingidvar)
  stopwordlimit=stopwordthreshold*Q2rows
  for (loc=asarray_first(weightarray); loc!=NULL; loc=asarray_next(weightarray,loc)) {
	 if(asarray_contents(weightarray,loc)>stopwordlimit) asarray(stopwordarray,asarray_key(weightarray,loc),1)
  }
  stata(`"di "Done!" "')
}
void col_core_computing_wgt(string scalar textvars, string scalar scorevar, pointer(function) scalar score_func,
pointer(function) scalar wgt_func, weightarray, stamptime,  flagstep, pointer(function) scalar token_func, | arg_token_func, arg_token_func2)
{
 textvar=tokens(textvars)
 if(st_vartype(textvar[1,1])=="strL" | st_vartype(textvar[1,2])=="strL") TXT=st_sdata(.,(textvars))
 else st_sview(TXT=.,.,textvars)
 st_view(RESNUM=.,.,scorevar)
 Qrows=rows(TXT); flag=flagstep;
 if(stamptime==1) stata(`"di c(current_date) " " c(current_time) "-> " _continue"')
 stata(`"di "0%""')
 for (i=1; i<=Qrows; i++)
 {
  counter=i*100/Qrows
  if (counter>flag)
  {
   if(stamptime==1) stata(`"di c(current_date) " " c(current_time) "-> " _continue"')
   stata(`"di ""'+strofreal(round(counter, flagstep))+`"%""')
   flag=flag+flagstep
  }
  T1=asarray_create()
  if (arg_token_func2!=J(0, 0, .)) T1=(*token_func)(TXT[i,1], arg_token_func, arg_token_func2)
  else if (arg_token_func!=J(0, 0, .)) T1=(*token_func)(TXT[i,1], arg_token_func)
  else T1=(*token_func)(TXT[i,1])
  D1=asarray_sumw(T1, weightarray, wgt_func)
  T2=asarray_create()
  if (arg_token_func2!=J(0, 0, .)) T2=(*token_func)(TXT[i,2], arg_token_func, arg_token_func2)
  else if (arg_token_func!=J(0, 0, .)) T2=(*token_func)(TXT[i,2], arg_token_func)
  else T2=(*token_func)(TXT[i,2])
  D2=asarray_sumw(T2, weightarray, wgt_func)
  Num=asarray_vecprod_wgt(T1,T2, weightarray, wgt_func)
  RESNUM[i,1]= (*score_func)(Num,D1,D2)
 }
 if(stamptime==1) stata(`"di c(current_date) " " c(current_time) "-> " _continue"')
 stata(`"di "Done!"')
}
void col_core_computing(string scalar textvars, string scalar scorevar, pointer(function) scalar score_func, stamptime,  flagstep,
 pointer(function) scalar token_func, | arg_token_func, arg_token_func2)
{
 textvar=tokens(textvars)
 if(st_vartype(textvar[1,1])=="strL" | st_vartype(textvar[1,2])=="strL") TXT=st_sdata(.,(textvars))
 else st_sview(TXT=.,.,textvars)
 st_view(RESNUM=.,.,scorevar)
 Qrows=rows(TXT); flag=flagstep;
 if(stamptime==1) stata(`"di c(current_date) " " c(current_time) "-> " _continue"')
 stata(`"di "0%""')
 for (i=1; i<=Qrows; i++)
 {
  counter=i*100/Qrows
  if (counter>flag)
  {
   if(stamptime==1) stata(`"di c(current_date) " " c(current_time) "-> " _continue"')
   stata(`"di ""'+strofreal(round(counter, flagstep))+`"%""')
   flag=flag+flagstep
  }
  T1=asarray_create()
  if (arg_token_func2!=J(0, 0, .)) T1=(*token_func)(TXT[i,1], arg_token_func, arg_token_func2)
  else if (arg_token_func!=J(0, 0, .)) T1=(*token_func)(TXT[i,1], arg_token_func)
  else T1=(*token_func)(TXT[i,1])
  D1=asarray_sumsq(T1)
  T2=asarray_create()
  if (arg_token_func2!=J(0, 0, .)) T2=(*token_func)(TXT[i,2], arg_token_func, arg_token_func2)
  else if (arg_token_func!=J(0, 0, .)) T2=(*token_func)(TXT[i,2], arg_token_func)
  else T2=(*token_func)(TXT[i,2])
  D2=asarray_sumsq(T2)
  Num=asarray_vecprod(T1,T2)
  RESNUM[i,1]= (*score_func)(Num,D1,D2)
 }
 if(stamptime==1) stata(`"di c(current_date) " " c(current_time) "-> " _continue"')
 stata(`"di "Done!"')
}
function asarray_sumsq(myarray, | stopwordarray)
{
 myscore=0
 if (stopwordarray==J(0, 0, .))
 {
  for (loc=asarray_first(myarray); loc!=NULL; loc=asarray_next(myarray,loc)) myscore=myscore+asarray_contents(myarray,loc)^2
 }
 else
 {
  for (loc=asarray_first(myarray); loc!=NULL; loc=asarray_next(myarray,loc))
  {
   curkey=asarray_key(myarray,loc)
   if (asarray_contains(stopwordarray, curkey)==0) myscore=myscore+asarray_contents(myarray,loc)^2
  }
 }
 return (myscore)
}
function asarray_sumw(shortarray, weights, pointer(function) scalar wgt_func , | stopwordarray)
{
 asarray_notfound(weights,1)
 Sumw=0
 for (loc=asarray_first(shortarray); loc!=NULL; loc=asarray_next(shortarray,loc))
 {
  curkey=asarray_key(shortarray,loc)
  if (stopwordarray==J(0, 0, .))
  {
   A = asarray_contents(shortarray,loc) * ((*wgt_func)(asarray(weights,curkey)))
   Sumw = Sumw + A^2
  }
  else if (asarray_contains(stopwordarray, curkey)==0)
  {
   A = asarray_contents(shortarray,loc) * ((*wgt_func)(asarray(weights,curkey)))
   Sumw = Sumw + A^2
  }
 }
 return (Sumw)
}
function asarray_vecprod_wgt(myarray1, myarray2, weights, pointer(function) scalar wgt_func)
{
 curscore=0
 for (loc=asarray_first(myarray1); loc!=NULL; loc=asarray_next(myarray1,loc))
  {
   mykey=asarray_key(myarray1,loc)
   if (asarray_contains(myarray2,mykey)==1)
   {
    w = ((*wgt_func)(asarray(weights, mykey)))^2
	curscore = curscore + asarray(myarray1,mykey)*asarray(myarray2,mykey)*w
   }
  }
 return (curscore)
}
function asarray_vecprod(myarray1, myarray2)
{
 curscore=0
 for (loc=asarray_first(myarray1); loc!=NULL; loc=asarray_next(myarray1,loc))
  {
   mykey=asarray_key(myarray1,loc)
   if (asarray_contains(myarray2,mykey)==1) curscore = curscore + asarray(myarray1,mykey)*asarray(myarray2,mykey)
  }
 return (curscore)
}
// computing scores index
void core_computing(threshold, idvar, textvar, usingidvar, usingtextvar, indexarray, weightusing, stopwordarray,
pointer(function) scalar score_func, stamptime,  flagstep, pointer(function) scalar token_func, | arg_token_func, arg_token_func2)
{
 Qrows=rows(idvar); flag=flagstep; spacecount=0; UROWS=rows(usingidvar); curobs=0
 if(stamptime==1) stata(`"di c(current_date) " " c(current_time) "->" _continue"')
 stata(`"di "{tab}Percent completed ...{tab}(search space saved by index so far)""')
 for (i=1; i<=Qrows; i++)
 {
  if (arg_token_func2!=J(0, 0, .)) Curgrams=(*token_func)(textvar[i,1], arg_token_func, arg_token_func2)
  else if (arg_token_func!=J(0, 0, .)) Curgrams=(*token_func)(textvar[i,1], arg_token_func)
  else Curgrams=(*token_func)(textvar[i,1])
  Curdenom=asarray_sumsq(Curgrams, stopwordarray)
  Numerator=asarray_index_intersect(Curgrams,indexarray, stopwordarray)
  spacecount=spacecount+asarray_elements(Numerator)
  for (loc=asarray_first(Numerator); loc!=NULL; loc=asarray_next(Numerator,loc))
  {
   usingkey=asarray_key(Numerator,loc)
   Similscore=(*score_func)(asarray_contents(Numerator,loc), Curdenom, asarray(weightusing, usingkey))
   if (Similscore>=threshold)
   {
     curobs++
     st_addobs(1)
	 st_store(curobs,(1,3,5), (idvar[i,1], usingidvar[usingkey,1], Similscore))
	 st_sstore(curobs,(2,4), (textvar[i,1], usingtextvar[usingkey,1]))
	}
  }
  counter=i*100/Qrows
  if (counter>flag)
  {
   if(stamptime==1) stata(`"di c(current_date) " " c(current_time) "->" _continue"')
   stata(`"di "{tab}"'+strofreal(round(counter, flagstep))+`"%{tab}{tab}  ...{tab}("'+strofreal(100-trunc(spacecount*100/UROWS/i))+`"%)""')
   flag=flag+flagstep
  }
 }
 if(stamptime==1) stata(`"di c(current_date) " " c(current_time) "->" _continue"')
 stata(`"di "{tab}Done!""')
 stata(`"di "Total search space saved by index: "'+strofreal(100-trunc(spacecount*100/UROWS/Qrows))+`"%""')
}
void core_computing_wgt(threshold, idvar, textvar, usingidvar, usingtextvar, indexarray, weightusing, weightarray, stopwordarray,
pointer(function) scalar score_func, pointer(function) scalar wgt_func, stamptime, flagstep, pointer(function) scalar token_func, | arg_token_func, arg_token_func2)
{
 Qrows=rows(idvar); flag=flagstep; spacecount=0; UROWS=rows(usingidvar); curobs=0
 if(stamptime==1) stata(`"di c(current_date) " " c(current_time) "->" _continue"')
 stata(`"di "{tab}Percent completed ...{tab}(search space saved by index so far)""')
 for (i=1; i<=Qrows; i++)
 {
  if (arg_token_func2!=J(0, 0, .)) Curgrams=(*token_func)(textvar[i,1], arg_token_func, arg_token_func2)
  else if (arg_token_func!=J(0, 0, .)) Curgrams=(*token_func)(textvar[i,1], arg_token_func)
  else Curgrams=(*token_func)(textvar[i,1])
  Curdenom=asarray_sumw(Curgrams,weightarray, wgt_func, stopwordarray)
  Numerator=asarray_index_intersect_wgt(Curgrams,indexarray,weightarray,wgt_func,stopwordarray)
  spacecount=spacecount+asarray_elements(Numerator)
  for (loc=asarray_first(Numerator); loc!=NULL; loc=asarray_next(Numerator,loc))
  {
   usingkey=asarray_key(Numerator,loc)
   Similscore=(*score_func)(asarray_contents(Numerator,loc), Curdenom, asarray(weightusing, usingkey))
   if (Similscore>=threshold)
   {
    curobs++
	st_addobs(1)
	st_store(curobs,(1,3,5), (idvar[i,1], usingidvar[usingkey,1], Similscore))
	st_sstore(curobs,(2,4), (textvar[i,1], usingtextvar[usingkey,1]))
   }
  }
  counter=i*100/Qrows
  if (counter>flag)
  {
   if(stamptime==1) stata(`"di c(current_date) " " c(current_time) "->" _continue"')
   stata(`"di "{tab}"'+strofreal(round(counter, flagstep))+`"%{tab}{tab}  ...{tab}("'+strofreal(100-trunc(spacecount*100/UROWS/i))+`"%)""')
   flag=flag+flagstep
  }
 }
  if(stamptime==1) stata(`"di c(current_date) " " c(current_time) "->" _continue"')
 stata(`"di "{tab}Done!""')
 stata(`"di "Total search space saved by index: "'+strofreal(100-trunc(spacecount*100/UROWS/Qrows))+`"%""')
}
void index_array(myindex, stopwordarray, colvector idvar, colvector textvar, wgtusing, stamptime, flagstep, pointer(function) scalar token_func, | arg_token_func, arg_token_func2)
{
 Qrows=rows(idvar); flag=flagstep;
 if(stamptime==1) stata(`"di c(current_date) " " c(current_time) "-> " _continue"')
 stata(`"di "0%""')
 for (i=1; i<=Qrows; i++)
 {
  counter=i*100/Qrows
  if (counter>flag)
  {
   if(stamptime==1) stata(`"di c(current_date) " " c(current_time) "-> " _continue"')
   stata(`"di ""'+strofreal(round(counter, flagstep))+`"%""')
   flag=flag+flagstep
  }
  T=asarray_create()
  if (arg_token_func2!=J(0, 0, .)) T=(*token_func)(textvar[i,1], arg_token_func, arg_token_func2)
  else if (arg_token_func!=J(0, 0, .)) T=(*token_func)(textvar[i,1], arg_token_func)
  else T=(*token_func)(textvar[i,1])
  array_to_index_vecadd(T, myindex, i, stopwordarray)
  asarray(wgtusing,i,asarray_sumsq(T, stopwordarray))
 }
 if(stamptime==1) stata(`"di c(current_date) " " c(current_time) "-> " _continue"')
 stata(`"di "Done!"')
}
void array_to_index_vecadd (myarray, myindex, mynum, stopwordarray)
{
 for (loc=asarray_first(myarray); loc!=NULL; loc=asarray_next(myarray,loc))
 {
  curkey = asarray_key(myarray,loc)
  if (asarray_contains(stopwordarray, curkey)==0)
  {
   curvalue = asarray_contents(myarray, loc)
   if (asarray_contains(myindex, curkey)==1)
   {
    A=asarray(myindex, curkey)\(mynum, curvalue)
    asarray(myindex, curkey, A)
   }
   else
    asarray(myindex, curkey, (mynum, curvalue))
  }
 }
}
void index_array_wgt(myindex, stopwordarray, colvector idvar, colvector textvar, wgtusing, pointer(function) scalar weight_func, weights,
stamptime, flagstep, pointer(function) scalar token_func, | arg_token_func, arg_token_func2)
{
 Qrows=rows(idvar); flag=flagstep;
 if(stamptime==1) stata(`"di c(current_date) " " c(current_time) "-> " _continue"')
 stata(`"di "0%""')
 for (i=1; i<=Qrows; i++)
 {
  counter=i*100/Qrows
  if (counter>flag)
  {
   if(stamptime==1) stata(`"di c(current_date) " " c(current_time) "-> " _continue"')
   stata(`"di ""'+strofreal(round(counter, flagstep))+`"%""')
   flag=flag+flagstep
  }
  T=asarray_create()
  if (arg_token_func2!=J(0, 0, .)) T=(*token_func)(textvar[i,1], arg_token_func, arg_token_func2)
  else if (arg_token_func!=J(0, 0, .)) T=(*token_func)(textvar[i,1], arg_token_func)
  else T=(*token_func)(textvar[i,1])
  array_to_index_vecadd_wgt(T, myindex, i, wgtusing, weight_func, weights, stopwordarray)
 }
 stata(`"di "Done!"')
}
void array_to_index_vecadd_wgt(myarray, myindex, mynum, wgtusing, pointer(function) scalar weight_func, weights, stopwordarray)
{
 W=0
 for (loc=asarray_first(myarray); loc!=NULL; loc=asarray_next(myarray,loc))
 {
  curkey = asarray_key(myarray,loc)
  if (asarray_contains(stopwordarray, curkey)==0)
  {
   curvalue = asarray_contents(myarray, loc)
   if (asarray_contains(myindex, curkey)==1)
   {
    A=asarray(myindex, curkey)\(mynum, curvalue)
    asarray(myindex, curkey, A)
   }
   else
    asarray(myindex, curkey, (mynum, curvalue))

   W=W+(curvalue * ((*weight_func)(asarray(weights, curkey))))^2
  }
 }
 asarray(wgtusing,mynum,W)
}
function asarray_index_intersect(shortarray, longindex, stopwordarray)
{
 Matched=asarray_create("real")
 shortkeys=asarray_keys(shortarray)
 for (i=1; i<=rows(shortkeys); i++)
 {
  curkey=shortkeys[i,1]
  if (asarray_contains(stopwordarray, curkey)==0)
   if (asarray_contains(longindex, curkey))
   {
    A=asarray(longindex, curkey)
    for (j=1; j<=rows(A); j++)
    {
     if (asarray_contains(Matched, A[j,1]))
     {
      asarray(Matched, A[j,1], (asarray(Matched, A[j,1]) + asarray(shortarray, curkey)*A[j,2]))
     }
     else
     {
      asarray(Matched, A[j,1],asarray(shortarray, curkey)*A[j,2])
     }
    }
   }
 }
 return (Matched)
}
function asarray_index_intersect_wgt(shortarray, longindex, weights, pointer(function) scalar weight_func, stopwordarray)
{
 asarray_notfound(weights,1)
 Matched=asarray_create("real")
 shortkeys=asarray_keys(shortarray)
 for (i=1; i<=rows(shortkeys); i++)
 {
  curkey=shortkeys[i,1]
  if (asarray_contains(stopwordarray, curkey)==0)
   if (asarray_contains(longindex, curkey))
   {
    A=asarray(longindex, curkey)
    for (j=1; j<=rows(A); j++)
    {
     curwgt=(*weight_func)(asarray(weights,curkey))
     curnum = asarray(shortarray, curkey) * A[j,2] * (curwgt^2)
     if (asarray_contains(Matched, A[j,1]))
      asarray(Matched, A[j,1], (asarray(Matched, A[j,1]) + curnum))
     else
      asarray(Matched, A[j,1],curnum)
    }
   }
 }
 return (Matched)
}
void load_weights_to_array(myarray,mygram, myfreq) {
 for (i=1; i<=rows(mygram); i++)
  asarray(myarray,mygram[i,1], myfreq[i,1])
}
// GRAM weighting functions
function weight_simple(real scalar gramfreq) {
  return (1/gramfreq)
 }
function weight_root(real scalar gramfreq) {
  return (1/sqrt(gramfreq))
 }
function weight_log(real scalar gramfreq)  {
  return (1/(log(gramfreq)+1))
 }

// Score functions
// score_* = functions to compute similarity score
function score_jaccard(real scalar numerator, real scalar denom1, real scalar denom2)
{
 denom=denom1*denom2
 if (denom<=0) return (0)
 else return (numerator/sqrt(denom))
}
function score_simple(real scalar numerator, real scalar denom1, real scalar denom2)
{
 denom=denom1+denom2
 if (denom<=0) return (0)
 else return (2*numerator/denom)
}
function score_minsimple(real scalar numerator, real scalar denom1, real scalar denom2)
{
 denom=denom1*denom2
 vecdenom = denom1, denom2
 if (denom<=0) return (0)
 else if (numerator>min(vecdenom)) return (1)
 else return (numerator/min(vecdenom))
}
// Similarity functions
// simf_* = similarity function (e.g. simf_bigram, simf_token)
function simf_token(string scalar parse_string, | real scalar unitflag)
{
 A=asarray_create()
 T=tokens(parse_string)
 if (unitflag==1)
  for (i=1; i<=cols(T); i++)
   asarray(A, T[1,i], 1)
 else
  for (i=1; i<=cols(T); i++)
  {
   if (asarray_contains(A, T[1,i])!=1) asarray(A, T[1,i], 1)
   else asarray(A, T[1,i], asarray(A, T[1,i])+1)
  }
 return (A)
}
function simf_cotoken(string scalar parse_string)
{
 A=asarray_create()
 T=tokens(parse_string)
 for (i=2; i<=cols(T); i++)
 {
  tok1=T[1,i-1]
  tok2=T[1,i]
  if (tok1<tok2)
   cotoken=invtokens((tok1, tok2))
  else
   cotoken=invtokens((tok2, tok1))
  if (asarray_contains(A, cotoken)!=1) asarray(A, cotoken, 1)
  else asarray(A, cotoken, asarray(A, cotoken)+1)
 }
 return (A)
}
function simf_scotoken(string scalar parse_string)
{
 A=asarray_create()
 T=tokens(parse_string)
 mycols=cols(T)
 if (mycols==1){
  asarray(A, T[1,1], 1)
  return(A)
 }
 for (i=2; i<=mycols; i++)
 {
  tok1=T[1,i-1]
  if (asarray_contains(A, tok1)!=1) asarray(A, tok1, 1)
  else asarray(A, tok1, asarray(A, tok1)+1)
  tok2=T[1,i]
  if (asarray_contains(A, tok2)!=1) asarray(A, tok2, 1)
  else asarray(A, tok2, asarray(A, tok2)+1)
  if (tok1<tok2)
   cotoken=invtokens((tok1, tok2))
  else
   cotoken=invtokens((tok2, tok1))
  if (asarray_contains(A, cotoken)!=1) asarray(A, cotoken, 1)
  else asarray(A, cotoken, asarray(A, cotoken)+1)
 }
 return (A)
}
function simf_bigram(string scalar parse_string, | real scalar unitflag)
{
 T=asarray_create()
 Tlen=strlen(parse_string)-1
 if (Tlen>1)
 {
  for (j=1; j<=Tlen; j++)
  {
   gram=substr(parse_string,j,2)
   if (unitflag==1) asarray(T, gram, 1)
   else
   {
    if (asarray_contains(T, gram)!=1) asarray(T, gram, 1)
    else asarray(T, gram, asarray(T, gram)+1)
   }
  }
  return(T)
 }
 else
 {
  asarray(T, parse_string, 1)
  return (T)
 }
}
function simf_ngram(string scalar parse_string, real scalar nsize, | real scalar unitflag)
{
 T=asarray_create()
 Tlen=strlen(parse_string)-(nsize-1)
 if (Tlen>1)
 {
  for (j=1; j<=Tlen; j++)
  {
   gram=substr(parse_string,j,nsize)
   if (unitflag==1) asarray(T, gram, 1)
   else
   {
    if (asarray_contains(T, gram)!=1) asarray(T, gram, 1)
    else asarray(T, gram, asarray(T, gram)+1)
   }
  }
  return(T)
 }
 else
 {
  asarray(T, parse_string, 1)
  return (T)
 }
}
function simf_ngram_circ(string scalar parse_string, real scalar nsize, | real scalar unitflag)
{
 T=asarray_create()
 Tlen=strlen(parse_string)-(nsize-1)
 if (Tlen>1)
 {
  firstgram=substr(parse_string,1,nsize-1)
  new_parse_string = parse_string+" "+firstgram
  Tlen=Tlen+nsize
  for (j=1; j<=Tlen; j++)
  {
   gram=substr(new_parse_string,j,nsize)
   if (unitflag==1) asarray(T, gram, 1)
   else
   {
    if (asarray_contains(T, gram)!=1) asarray(T, gram, 1)
    else asarray(T, gram, asarray(T, gram)+1)
   }
  }
  return(T)
 }
 else
 {
  asarray(T, parse_string, 1)
  return (T)
 }
}
function simf_token_soundex(string scalar parse_string, | real scalar unitflag)
{
 A=asarray_create()
 T=soundex(tokens(parse_string))
 for (i=1; i<=cols(T); i++)
 {
  if (unitflag==1) asarray(A, T[1,i], 1)
  else
  {
   if (asarray_contains(A, T[1,i])!=1) asarray(A, T[1,i], 1)
   else asarray(A, T[1,i], asarray(A, T[1,i])+1)
  }
 }
 return (A)
}
function simf_soundex(string scalar parse_string)
{
 A=asarray_create()
 T=soundex(parse_string)
 asarray(A, T[1,1], 1)
 return (A)
}
function simf_firstgram(string scalar parse_string, real scalar nsize)
{
 A=asarray_create()
 T=tokens(parse_string)
 for (i=1; i<=cols(T); i++)
 {
  gram=substr(T[1,i],1,nsize)
  if (asarray_contains(A, gram)!=1) asarray(A, gram, 1)
  else asarray(A, gram, asarray(A, gram)+1)
 }
 return(A)
}
function simf_soundex_nara(string scalar parse_string)
 {
   A=asarray_create()
   T=soundex_nara(parse_string)
   asarray(A, T[1,1], 1)
   return (A)
 }
function simf_soundex_fk(string scalar parse_string) {
 T=asarray_create()
 new_string=strupper(strtrim(parse_string))
 Tlen=strlen(new_string)
 if (Tlen>0) {
  result=substr(new_string,1,1)
  new_string=substr(new_string,2,.)
  prevletter=""
  for (j=1; j<=Tlen-1; j++) {
   curletter=substr(new_string,j,1)
   if (curletter!=prevletter) {
    curdigit=0
	if (strpos("BFPV",curletter)>0) curdigit=1
    if (strpos("CGJKQSXZ",curletter)>0) curdigit=2
    if (strpos("DT",curletter)>0) curdigit=3
	if (curletter=="L") curdigit=4
	if (strpos("MN",curletter)>0) curdigit=5
    if (curletter=="R") curdigit=6
	if (curdigit>0) result=result+strofreal(curdigit)
   }
   prevletter=curletter
  }
  asarray(T, result, 1)
 }
  return(T)
 }
function simf_soundex_ext(string scalar parse_string) {
 T=asarray_create()
 new_string=strupper(strtrim(parse_string))
 Tlen=strlen(new_string)
 if (Tlen>0) {
  result=substr(new_string,1,1)
  new_string=substr(new_string,2,.)
  prevletter=""
  for (j=1; j<=Tlen-1; j++) {
   curletter=substr(new_string,j,1)
   if (curletter!=prevletter) {
    curdigit=0
	if (strpos("BFPV",curletter)>0) curdigit=1
    if (strpos("CGJKQSXZ",curletter)>0) curdigit=2
    if (strpos("DT",curletter)>0) curdigit=3
	if (curletter=="L") curdigit=4
	if (strpos("MN",curletter)>0) curdigit=5
    if (curletter=="R") curdigit=6
	if (curdigit>0){
	 result=result+strofreal(curdigit)
	 asarray(T, result, 1)
	}
   }
   prevletter=curletter
  }
 }
 return(T)
}
function simf_nysiis_fk(string scalar parse_string)
{
 T=asarray_create()
 new_string=strupper(strtrim(parse_string))
 Tlen=strlen(new_string)
 if (Tlen>0) {
  firstkey=""
  if(substr(new_string,1,3)=="MAC"){
   firstkey="MC"
   elsestring=substr(new_string,4,.)
  }
  else if(substr(new_string,1,2)=="KN"){
   firstkey="N"
   elsestring=substr(new_string,3,.)
  }
  else if(substr(new_string,1,1)=="K"){
   firstkey="C"
   elsestring=substr(new_string,2,.)
  }
  else if(substr(new_string,1,2)=="PH"){
   firstkey="FF"
   elsestring=substr(new_string,3,.)
  }
  else if(substr(new_string,1,2)=="PF"){
   firstkey="FF"
   elsestring=substr(new_string,3,.)
  }
  else if(substr(new_string,1,3)=="SCH"){
   firstkey="SS"
   elsestring=substr(new_string,4,.)
  }
  else elsestring=new_string
  lastletters=substr(elsestring,-2,2)
  lastkey=""
  if (lastletters=="EE") {
   lastkey="Y"
   elsestring=substr(elsestring,1,strlen(elsestring)-2)
  }
  else if (lastletters=="IE") {
   lastkey="Y"
   elsestring=substr(elsestring,1,strlen(elsestring)-2)
  }
  else if (lastletters=="DT") {
   lastkey="D"
   elsestring=substr(elsestring,1,strlen(elsestring)-2)
  }
  else if (lastletters=="RT") {
   lastkey="D"
   elsestring=substr(elsestring,1,strlen(elsestring)-2)
  }
  else if (lastletters=="RD") {
   lastkey="D"
   elsestring=substr(elsestring,1,strlen(elsestring)-2)
  }
  else if (lastletters=="NT") {
   lastkey="D"
   elsestring=substr(elsestring,1,strlen(elsestring)-2)
  }
  else if (lastletters=="ND") {
   lastkey="D"
   elsestring=substr(elsestring,1,strlen(elsestring)-2)
  }
  if (firstkey=="") {
   firstkey=substr(elsestring,1,1)
   elsestring=substr(elsestring,2,.)
  }
  elselen=strlen(elsestring)
  prevkey=firstkey
  finalkey=firstkey
  curkey=""
  for (j=1; j<=elselen; j++) {
   curletter=substr(elsestring,j,1)
   if (curletter=="E" & substr(elsestring,j+1,1)=="V") {
    curkey="AF"
	j=j+1
   }
   else if (strpos("AEIOU",curletter)>0) curkey="A"
   else if (curletter=="Q") curkey="G"
   else if (curletter=="Z") curkey="S"
   else if (curletter=="M") curkey="N"
   else if (curletter=="K") {
    if (substr(elsestring,j+1,1)=="N") {
     curkey="N"
	 j=j+1
    }
    else curkey="C"
   }
   else if (curletter=="S" & substr(elsestring,j+1,2)=="CH") {
    curkey="S"
	j=j+2
   }
   else if (curletter=="P" & substr(elsestring,j+1,1)=="H") {
    curkey="FF"
	j=j+1
   }
   else if (curletter=="H") {
    curkey=""
	if (j>1) curkey=substr(elsestring,j-1,1)
	if (strpos("AEIOU", substr(elsestring,j+1,1))>0) curkey=""
	if (j>1 & strpos("AEIOU", substr(elsestring,j-1,1))>0) curkey=""
   }
   else if (curletter=="W") {
    curkey="W"
   	if (j>1 & strpos("AEIOU", substr(elsestring,j-1,1))>0) curkey=""
   }
   else if (strpos("ABCDEFGHIJKLMNOPQRSTUVWXYZ",curletter)>0) curkey=curletter
   if (curkey!="") {
    if (curkey!=prevkey) finalkey=finalkey+curkey
    prevkey=curkey
   }
  }
  if (prevkey!=lastkey) finalkey=finalkey+lastkey
  if (substr(finalkey,-1,1)=="S") finalkey=substr(finalkey,1,strlen(finalkey)-1)
  if (substr(finalkey,-2,2)=="AY") finalkey=substr(finalkey,1,strlen(finalkey)-2)+"Y"
  if (substr(finalkey,-1,1)=="A") finalkey=substr(finalkey,1,strlen(finalkey)-1)
  asarray(T, finalkey, 1)
 }
return(T)
}
function simf_tokenwrap(string scalar parse_string, string scalar myfunc) {
 if (myfunc=="nysiis_fk") p=&simf_nysiis_fk()
 else if (myfunc=="soundex_fk") p=&simf_soundex_fk()
 else if (myfunc=="soundex_ext") p=&simf_soundex_ext()
 else if (myfunc=="soundex_nara") p=&simf_soundex_nara()
 else if (myfunc=="soundex") p=&simf_soundex()
 A=asarray_create()
 T=tokens(parse_string)
 for (i=1; i<=cols(T); i++){
  B=(*p)(T[1,i])
  for (loc=asarray_first(B); loc!=NULL; loc=asarray_next(B,loc)) {
   curkey=asarray_key(B,loc)
   if (asarray_contains(A, curkey)!=1) asarray(A, curkey, 1)
   else asarray(A, curkey, asarray(A, curkey)+1)
  }
 }
 return (A)
}
function simf_tkngram(string scalar parse_string, real scalar nsize, | real scalar unitflag)
{
 T=asarray_create()
 B=tokens(parse_string)
 if (unitflag==1)
  for (i=1; i<=cols(B); i++)
   asarray(T, B[1,i], 1)
 else
  for (i=1; i<=cols(B); i++)
  {
   if (asarray_contains(T, B[1,i])!=1) asarray(T, B[1,i], 1)
   else asarray(T, B[1,i], asarray(T, B[1,i])+1)
  }
 Tlen=strlen(parse_string)-(nsize-1)
 if (Tlen>1)
 {
  for (j=1; j<=Tlen; j++)
  {
   gram=substr(parse_string,j,nsize)
   if (unitflag==1) asarray(T, gram, 1)
   else
   {
    if (asarray_contains(T, gram)!=1) asarray(T, gram, 1)
    else asarray(T, gram, asarray(T, gram)+1)
   }
  }
  return(T)
 }
 else
 {
  return (T)
 }
}

end
