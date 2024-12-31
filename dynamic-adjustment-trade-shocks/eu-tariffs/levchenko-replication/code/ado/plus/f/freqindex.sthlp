{smcl}
{* *! version 1.0  march2014}{...}
{vieweralsosee "matchit" "help matchit"}{...}
{viewerjumpto "Syntax" "freqindex##syntax"}{...}
{viewerjumpto "Description" "freqindex##description"}{...}
{viewerjumpto "Options" "freqindex##options"}{...}
{viewerjumpto "Examples" "freqindex##examples"}{...}
{viewerjumpto "Saved results" "freqindex##saved_results"}{...}
{marker Top}{...}
{title:Title}

{p2colset 5 18 20 2}{...}
{p2col :Freqindex {hline 2}}Generates an index of terms with their frequencies based on the current dataset{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{p 5 15}
{cmd:freqindex} {it:[idvar] txtvar} 
[{it:, options}]
{p_end}

{synoptset 20 tabbed}{...}
{synoptline}
{syntab :}
{synopthdr}
{synoptline}
{synopt :{opt sim:ilmethod(simfcn)}}
Specifies the method to decompose the string into {it:grams}. 
Default is {bf:token}. Other built-in {it:simfcn} are:
{bf:bigram, ngram, ngram_circ, soundex} and {bf:token_soundex}.
{p_end}

{synopt :{opt incm:ata(mata_array)}}
Increments an existing index in memory ({it:mata_array}) 
with the information from the current dataset.
{p_end}

{synopt :{opt keepm:ata}}
Keeps the Mata objects after conclusion (including {it:mata_array}). 
Default is dropping them. See list below.
{p_end}

{synopt :{opt nost:ata}}
Omits producing a Stata output with the results (which is the default). 
It only makes sense to be used in combination with {it:keepmata} 
and meant for programming purposes when indexing several files. 
{p_end}

{synoptline}

{marker description}{...}
{title:Description}

{pstd}
{cmd:freqindex} indexes each singular term in a given string variable ({it:txtvar})
from the current dataset and computes its frequencies. 
As such, it returns a new dataset containing a string variable listing the terms 
(named {it:grams}) and a numeric variable with the corresponding frequencies (named {it:freq}).
Please, note that {cmd:freqindex} is case-sensitive and  
it also takes into account any other symbol (as far as Stata does).
{p_end}

{pstd}
{cmd:freqindex} is also a required element of {help matchit}, which uses it to compute weights.
Moreover, {cmd:freqindex} can be used autonomously as a complementary tool for 
computing weights based on custom frequencies or frequencies found in other sources. 
When using it with {help matchit} you should always specify the same {it:simfcn} in both commands.
Check {help "matchit##table_examples":here} for an example of how each built-in {it:simfcn} 
treats strings.
{p_end}

{pstd}
The numeric variable {it:idvar} is optional and 
has limited use beyond programming purposes.
{p_end}

{marker options}{...}
{title:Options}

{dlgtab: Options}

{phang}
{opt txtvar}
is the required string {varname} from the current file to be indexed.

{phang}
{opt sim:ilmethod(simfcn)}
explicitly declares the method to parse the two string variables into {it:Grams}. 
Default is {bf:token}. Other built-in {it:simfcn} are: {bf:bigram, ngram, soundex} and {bf:token_soundex}.
{p_end}

{phang}
{opt sim:ilmethod(simfcn,arg)}
is the alternative syntax when {it:simfcn} requires an argument. 
This is the case of {bf:ngram} and {bf:ngram_circ}, 
which allows computing 1-gram, 2-gram, 3-gram, etc. by passing {bf:n} as an argument.
For instance, {cmd:sim}({bf:ngram,2}) is equivalent to {cmd: sim}({bf:bigram}).
{p_end}

{phang}
{opt keepm:ata}
keeps the Mata objects after conclusion (including {it:mata_array}). 
Default is dropping them. 
It is useful when indexing several columns and/or several files.
See an {help "freqindex##examples":example} below.
{p_end}

{phang}
{opt nost:ata}
omits producing a Stata output with the results (which is the default). 
It only makes sense to be used in combination with {bf:keepmata}. 
It is particularly useful when indexing several columns from the same file 
(see an {help "freqindex##examples":example} below). 
{p_end}

{phang}
{opt incm:ata(mata_array)}
Increments an existing index in the Mata associative array ({it:mata_array}) 
with the information from the current dataset.
Please explicitly set {bf:keepmata} if you want to keep {it:mata_array} 
after running {cmd:freqindex}. 
{p_end}

{phang}
{opt idvar} 
is a numeric {varname} from the current file identifying its observations.
It is optional and of no use beyond Mata programming. 
It only makes sense to be used in combination with {bf:keepmata}. 

{synoptline}

{marker examples}{...}
{title:Examples:}

{phang2}{cmd:. freqindex} {it:mystring} 

{pstd}Setting matching method{p_end}
{phang2}{cmd:. freqindex} {it:mystring}, {bf: sim(soundex)} {p_end}
{phang2}{cmd:. freqindex} {it:mystring}, {bf: sim(ngram,3)} {p_end}

{pstd}Incrementing an existing index{p_end}
{phang2}{cmd:. freqindex} {it:mystring1}, {bf: keepm nost}{p_end}
{phang2}{cmd:. freqindex} {it:mystring2}, {bf: incm(WGTARRAY) keepm nost}{p_end}
{phang2}{cmd:. freqindex} {it:mystring3}, {bf: incm(WGTARRAY) keepm nost}{p_end}
{phang2}{cmd:. freqindex} {it:mystring4}, {bf: incm(WGTARRAY) keepm nost}{p_end}
{phang2}{bf: ...} {p_end}
{phang2}{cmd:. freqindex} {it:mystringN}, {bf: incm(WGTARRAY)}{p_end}
{phang2}{cmd:. list}{p_end}
{synoptline}

{marker saved_results}{...}
{title:Saved results}

{pstd}
{cmd:freqindex} saves the following in {cmd:Mata}{p_end}
{pstd}
(only if keepmata option is included){p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Mata:}{p_end}
{synopt:{cmd:IDW}}colvector of idvar (only if specified){p_end}
{synopt:{cmd:TXTW}}colvector of txtvar{p_end}
{synopt:{cmd:WGTARRAY}}Array of grams->frequencies{p_end}
{p2colreset}{...}

{marker author}{...}
{title:Author}

{pstd}Julio D. Raffo{p_end}

