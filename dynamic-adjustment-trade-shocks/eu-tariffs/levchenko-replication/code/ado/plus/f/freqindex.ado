*! 1.3.1 J.D. Raffo April 2019
program freqindex
 version 12
 syntax varlist(min=1 max=2) ///
   [, SIMilmethod(string asis)] ///
   [INCMata(string)] ///
   [KEEPMata] [NOSTata] [STRMergefriendly]

// setup //////////////////////////////////////
 tokenize `varlist'
 if ("`2'"=="") {
  local txtvar `1'
  confirm string variable `txtvar'
  local myvars=1
 }
 else {
  local idvar `1'
  local txtvar `2'
  confirm numeric variable `idvar'
  confirm string variable `txtvar'
  local myvars=2
 }
 if ("`incmata'"=="") {
  local incmata WGTARRAY
  mata: WGTARRAY=asarray_create(); P_WGTARRAY=&`incmata'
 }
 else {
  capture mata: P_WGTARRAY=&`incmata'
  if (_rc!=0) {
   di "`incmata' not found in MATA. Check spelling."
   error _rc
  }
 }
 gettoken similfunc similargs : similmethod , parse(",") quotes
 if (`"`similfunc'"'=="") local similfunc "token"

 capture mata: similfunc_p=&simf_`similfunc'()
 if (_rc!=0) {
  di "`similfunc' not found as a similarity function. Check spelling."
  error _rc
 }
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
 // programs starts
 preserve
 if (`myvars'==2) mata: IDW=st_data(.,"`idvar'")
 mata: TXTW=st_sdata(.,"`txtvar'")
 mata: *P_WGTARRAY = compute_freq(TXTW, *P_WGTARRAY, similfunc_p`args_plugin')
 if ("`nostata'"==""){
  clear
  local mystr=cond(_caller()>=13,cond("`strmergefriendly'"=="", "strL", "str2045"), "str244")
  qui mata: st_addvar(("`mystr'", "double"),("grams", "freq"))
  mata: dump_wgtarray(*P_WGTARRAY)
  qui compress
 }
 if ("`keepmata'"=="") {
  mata: mata drop `incmata' TXTW P_WGTARRAY similfunc_p
  if (`myvars'==2) mata: mata drop IDW
 }
 restore, not
end

mata:
function compute_freq(colvector textvar, freqindex, pointer(function) scalar token_func, | arg_token_func, arg_token_func2)
{
 for (i=1; i<=rows(textvar); i++)
 {
  if (arg_token_func2!=J(0, 0, .)) T=(*token_func)(textvar[i,1], arg_token_func, arg_token_func2)
  else if (arg_token_func!=J(0, 0, .)) T=(*token_func)(textvar[i,1], arg_token_func)
  else T=(*token_func)(textvar[i,1])
  array_to_index_sum(T, freqindex)
 }
 return (freqindex)
}
void array_to_index_sum (myarray, myindex)
{
 for (loc=asarray_first(myarray); loc!=NULL; loc=asarray_next(myarray,loc))
 {
  if (asarray_contains(myindex, asarray_key(myarray,loc))==1)
  {
   A=asarray(myindex, asarray_key(myarray,loc))+asarray_contents(myarray, loc)
   asarray(myindex, asarray_key(myarray,loc), A)
  }
  else
   asarray(myindex, asarray_key(myarray,loc), asarray_contents(myarray, loc))
 }
}
void dump_wgtarray(myarray)
{
 curobs=0
 for (loc=asarray_first(myarray); loc!=NULL; loc=asarray_next(myarray,loc)) {
 curobs++
 st_addobs(1)
 st_sstore(curobs,("grams"),asarray_key(myarray, loc))
 st_store(curobs,("freq"),asarray_contents(myarray, loc))
 }
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
