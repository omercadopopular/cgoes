{smcl}
{* *! version 1.5.2  May 2020}{...}
{vieweralsosee "[D] merge" "mansection D merge"}{...}
{vieweralsosee "[D] append" "help append"}{...}
{vieweralsosee "[D] joinby" "help joinby"}{...}
{vieweralsosee "freqindex" "help freqindex"}{...}
{viewerjumpto "Syntax" "matchit##syntax"}{...}
{viewerjumpto "Description" "matchit##description"}{...}
{viewerjumpto "Options" "matchit##options"}{...}
{viewerjumpto "Examples" "matchit##examples"}{...}
{viewerjumpto "Remarks" "matchit##remarks"}{...}
{viewerjumpto "Algorithms" "matchit##algorithms"}{...}
{viewerjumpto "Tips" "matchit##tips"}{...}
{viewerjumpto "References" "matchit##references"}{...}
{marker Top}{...}
{title:Title}

{p2colset 5 18 20 2}{...}
{p2col :Matchit {hline 2}}Matches two columns or two datasets based on similar text patterns{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{p 2 15}
{it:Data in two columns in the same dataset}
{p_end}

{p 5 15}
{cmd:matchit} {it:varname1 varname2}
[{it:, options}]
{p_end}


{p 2 15}
{it:Data in two different datasets (with indexation)}
{p_end}

{p 5 15}
{cmd:matchit} {it:idmaster txtmaster}
{cmd:using} {it:{help filename}.dta} {cmd:,} {opth idu:sing(varname)} {opth txtu:sing(varname)} [{it:options}]
{p_end}


{synoptset 20 tabbed}{...}
{synoptline}
{syntab :}
{synopthdr}
{synoptline}
{synopt :{opt sim:ilmethod(simfcn)}}
String matching method. Default is {it:bigram}. Other built-in {it:simfcn} are:
{it:ngram, ngram_circ, firstgram, token, cotoken, scotoken, soundex, soundex_nara, soundex_fk, soundex_ext, token_soundex}
and {it:nysiis_fk}.
{p_end}

{synopt :{opt s:core(scrfcn)}}
Specifies similarity score. Default is {it:jaccard}. Other built-in options are {it:simple} and {it:minsimple}.
{p_end}

{synopt :{opt w:eights(wgtfcn)}}
Weighting transformation. Default is {it:noweights}. Built-in options are {it:simple, log} and {it:root}.
{p_end}

{synopt :{opt g:enerate(varname)}}
Specifies the name for the similarity score variable.
Default is {it:similscore}.
{p_end}

{marker reqopt}{...}
{synoptset 20 tabbed}{...}
{synoptline}
{syntab :{it:Two datasets setup:}}
{syntab :{it:Required}}
{synopthdr}
{synoptline}
{synopt :{it:idmaster}}Numeric {varname} from current file ({it:masterfile}).
Needs not to uniquely identify observations from {it:masterfile} (although recommended).
{p_end}

{synopt :{it:txtmaster}}String {varname} from current file ({it:masterfile}) which will be matched to {it:txtusing}.
{p_end}

{synopt : using {it:{help filename}}}Name (and path) of the Stata file to be matched ({it:usingfile}).
{p_end}

{synopt :{opth idu:sing(varname)}}Numeric {varname} from {it:usingfile}.
Needs not to uniquely identify observations from {it:usingfile} (although recommended).
{p_end}

{synopt :{opth txtu:sing(varname)}}String {varname} from {it:usingfile} which will be matched to {it:txtmaster}.
{p_end}

{synoptline}
{marker advopt}{...}
{synoptset 20 tabbed}{...}
{syntab :{it:Advanced}}
{synopthdr}
{synoptline}

{synopt :{opt wgtf:ile(filename)}}
Allows loading weights from a Stata file, instead of computing it from the current dataset
(and {it:using} dataset, in the case of two-dataset setup).
Default is not to load weights.
{p_end}

{synopt :{opt ti:me}}
Outputs time stamps during the execution.
To be used for benchmarking purposes.
{p_end}

{synopt :{opt f:lag(step)}}
Controls how often {cmd:matchit} reports back to the output screen.
Only really useful for optimizing indexation by trying different {it:simfcn}.
Default is {it:step} = 20 (percent).
{p_end}

{syntab :{it:Only for two datasets syntax:}}

{synopt :{opt t:hreshold(num)}}
Lowest similarity scores to be kept in final results.
Default is {it:num} = .5.
{p_end}

{synopt :{opt over:ride}}
Ignores unsaved data warning.
{p_end}

{synopt :{opt di:agnose}}
Reports a preliminary analysis about indexation.
To be used for optimizing indexation by cleaning original data and trying different {it:simfcn}.
{p_end}

{synopt :{opt stopw:ordsauto}}
Generates list of stopwords automatically.
It improves indexation speed but ignores potential matches.
{p_end}

{synopt :{opt swt:hreshold(grams-per-observation)}}
Only valid with {it:stopwordsauto}.
It sets the threshold of {it:grams} per observation to be included in the stopwords list.
Default is {it:grams-per-observation} = .2.
{p_end}


{synoptline}

{marker description}{...}
{title:Description}

{pstd}
{cmd:matchit} provides a similarity score between two different text strings
by performing many different string-based matching techniques.
It returns a new numeric variable ({it:similscore}) containing the similarity score, which ranges from 0 to 1.
A {it:similscore} of 1 implies a perfect similarity according to the string matching technique chosen
and decreases when the match is less similar.
{it:similscore}  is a relative measure which can (and often do) change depending on the technique chosen.
For more information on these techniques refer to Raffo & Lhuillery (2009).
{p_end}

{pstd}
These two variables can be from the same dataset or from two different ones.
This latter option makes {cmd:matchit} a convenient tool to join observations
when the string variables are not necessarily exactly the same.
In other terms, it allows for the dataset currently in memory (called the {it:master} dataset)
to be matched with {it:{help filename}}{it:.dta} (called the {it:using} dataset)
by means of a {it:fuzzy} similarity between string variables of each dataset.
In this case, {cmd:matchit} returns a new dataset containing five variables: two from the {it:master} dataset
({it:idmaster} and {it:txtmaster}), two from the {it:using} dataset ({it:idusing} and {it:txtusing})
and the already mentioned similarity score ({it:similscore}).
{p_end}

{pstd}
{cmd:matchit} is particularly useful in two cases:
(1) when the two columns/datasets have different patterns for the same string data (e.g. individual or firm names, addresses, etc.); and,
(2) when one of the datasets is considerably large and it was {it:feeded} by different sources,
making it not uniformly formatted (e.g. names or addresses in different orders).
Joining data in cases like these may lead to several false negatives when using {help merge} or similar commands.
{p_end}

{pstd}
{cmd:matchit} is intended for overcoming this kind of problems
without engaging into extensive data cleaning or correction efforts.
Take, for instance, a case like (1) where one dataset contains first and last names in separated fields,
while the other one has just a fullname field.
The use of {cmd:matchit} allows to join the two datasets by simply combining the two fields of the first dataset
without caring about the order of first and last names or about missing middle names.
Similarly, a typical example of (2) is a large dataset containing addresses entered as free-text by different people.
Using {cmd:matchit} you can join them with a more standardized source without caring
if the zip or state codes were added systematically or not.
{p_end}

{pstd}
Please, note that {cmd:matchit} is case-sensitive.
It also takes into account all other symbols (as far as Stata does).
While data cleaning is not needed for using {cmd:matchit},
it often implies an improvement of the similarity scores and,
in consequence, the overall quality of the matching exercise.
However, too much data cleaning might remove relevant information,
inducing a negative effect on quality due to false positives.
{p_end}

{pstd}
{cmd:matchit} requires {help freqindex} to be installed when computing weights.
{p_end}


{marker options}{...}
{title:Options}

{dlgtab: Options for both syntaxes}

{phang}
{opt sim:ilmethod(simfcn)}
explicitly declares the method to parse the two string variables into {it:Grams}.
Default is {it:bigram}. Other built-in {it:simfcn} are:
{it:ngram, ngram_circ, firstgram, token, cotoken, scotoken, soundex, soundex_nara, soundex_fk, soundex_ext, token_soundex}
and {it:nysiis_fk}.
{p_end}

{phang}
{opt sim:ilmethod(simfcn,arg)}
is the alternative syntax when {it:simfcn} requires an argument.
This is the case of {it:ngram} and {it:ngram_circ},
which allows computing 1-gram, 2-gram, 3-gram, etc. by passing {it:n} as an argument.
For instance, {cmd:sim}({it:ngram,2}) is equivalent to {cmd: sim}({it:bigram}).
{p_end}

{phang}Check {help "matchit##table_examples":here} for an example of how each built-in {it:simfcn}
treats strings. {p_end}

{phang}
{opt w:eights(wgtfcn)}
specifies an specific weighting transformation for {it:Grams}.
Default is no weights ({it:i.e.} each one weights 1).
Built-in options are {it:simple, log} and {it:root}.
Using weights is particularly recommended for large datasets where some {it:Grams} like {it:"Inc", "Jr", "Av"}
are frequently found, because if not they increase the false positive matches.

{phang}
{opt wgtf:ile(filename)}
allows loading {it:Grams'} frequencies directly from a Stata file.
{cmd:matchit} applies the weighting transformation ({it:wgtfcn})
selected at {it:weights()} after loading them.
Note that no file is loaded nor weights applied
if {it:weights()} is not explicitly stated.
If one or more {it:grams} are missing in the selected file,
a frequency equal to one is assumed for each of them.
See {help freqindex} (distributed with {cmd:matchit}) to built your own frequency file.

{phang}
{opt s:core(scrfcn)}
specifies the way to compute the similarity score.
Default is {it:jaccard}. Other built-in options are {it:simple} and {it:minsimple}.

{phang}
{opt g:enerate(varname)}
Specifies the name for the similarity score variable.
Default is {it:similscore}.
Please note that, in the case of two datasets, {cmd: matchit} renames variables
in the final dataset if there is any naming conflict.

{phang}
{opt f:lag(step)}
Controls how often {cmd:matchit} reports back to the output screen.
It affects the percent reported for both matching of columns or  datasets
Only really useful for optimizing indexation by trying different {it:simfcn}.
Default is {it:step} = 20 (percent)
{p_end}

{phang}
{opt ti:me}
Outputs time stamps during the execution.
To be used for benchmarking purposes.
{p_end}

{dlgtab:Required Options when matching two datasets}

{phang}
{opt idmaster}
is a numeric {varname} from the current file ({it:masterfile}) identifying its observations.
{cmd: matchit} will stop if it is not numeric.
It does not need to uniquely identify observations, although this is recommended.
A practical reason to avoid this suggestion is the case where there are alternative spellings for observations.

{phang}
{opt txtmaster}
is a string {varname} from the current file ({it:masterfile}) which will be matched to the string variable from the {it:usingfile} declared in {it:txtusing()}.
Duplicated values are allowed, although at the cost of losing some computational efficiency.

{phang}
{opt {help filename}.dta}
is the name (and path) of the Stata file to be matched ({it:usingfile}).

{phang}
{opth idu:sing(varname)}
declares the numeric {varname} from the {it:usingfile} identifying its observations.
It does not need to uniquely identify observations, although this is recommended.
A practical reason to avoid this suggestion is the case where there are alternative spellings for observations.

{phang}
{opth txtu:sing(varname)}
declares the string {varname} from the {it:usingfile} which will be matched to {it:txtmaster}.
Duplicated values are allowed, although at the cost of losing some computational efficiency.


{marker advoptions}{...}
{dlgtab: Additional options when matching two datasets}

{phang}
{opt t:hreshold(num)}
sets the limit of similarity score to keep in the final results.
Final results will have a score greater or equal to {it:num}.
Default is .5.
Note that: (1) this value relates to the chosen options for {it:similmethod}, {it:weights} and
{it:score};
 (2) even if 0 is specified, returned results are based on at least one matched term ({it:Gram}).
{p_end}

{phang}
{opt over:ride}
makes {cmd: matchit} ignore unsaved data warning. This is to be used with caution as {cmd:matchit} destroys the current data to return the matched combination of {it:masterfile} and {it:usingfile}.
{p_end}

{phang}
{opt di:agnose}
reports a preliminary analysis about indexation.
To be used for optimizing indexation by cleaning original data and trying different {it:simfcn}.
First, it reports a list of the top 20 most frequent {it:grams} (which depend on the chosen {it:simfcn}) from both the Master and Using files.
{it:Grams} scoring a higher {it:grams-per-observation} ratio will increase the likelihood of more strings being compared,
especially if they score high in both lists.
This list provides a good starting point for identifying {it:grams} that are less informative, making them good candidates for removal.
For instance, {it:Inc.}, {it:Corporation}, {it:University}, {it:Mr.}, {it:Ms.}, {it:Jr.}, {it:Street}, or {it:Avenue}
are terms frequently found in datasets which will be of limited use for the matching procedure.
Second, it performs an overall assessment of the matching procedure about to be used, reporting:
(a) total pairs being compared (observations in master file x those in the using file);
(b) a rough estimation of the maximum reduction (in percent) which could be obtained
by the {cmd:matchit} indexation (based on the underlying data and the chosen {it:simfcn}); and,
(c) a list of the top 20 {it:grams} which have the greatest negative impact to the indexation performance
({it:max_common_space}).
In order to increase the speed of {cmd:matchit} user should reduce the size of (a) or reduce the percent reported in (b).
The latter can be achieved by analyzing the results in (c) and removing those grams with higher scores manually or
by applying the option {it: stopwordsauto}.
It is worth noting that values from (b) are estimated and final results may differ.
Typically, they provide an upper bound, implying that final results should be lower
(although in some very particular cases it may actually get better).
{p_end}

{phang}
{opt stopw:ordsauto}
generates automatically a list of stopwords based on {it:grams} from both master and using files.
The selected stopwords are ignored in the indexation procedure and similarity score calculations.
For instance, a string composed only by {it:grams} in the stopwords list will always score zero
regardless to what is compared with.
Similarly, two strings differing only in {it:grams} from the stopwords list will score one,
regardless of how many these different {it:grams} are.
As such, it could improve indexation speed at the expense of ignoring potential matches and exarcebating similarity scores.
{p_end}

{phang}
{opt swt:hreshold(grams-per-observation)}
sets the threshold of {it:grams} per observation to be included in the stopwords list.
The values are the same than those reported in the {it:grams_per_obs} columns from the {it:diagnose} option.
Default is {it:grams-per-observation} = .2.
Only valid with {it:stopwordsauto}.
{p_end}

{synoptline}

{marker examples}{...}
{title:Examples:}

{pstd}Simple two-columns in one dataset syntax {p_end}
{phang2}{cmd:. matchit} {it:mystring1 mystring2}

{pstd}Setting matching method{p_end}
{phang2}{cmd:. matchit} {it:mystring1 mystring2}, {bf: sim(token)} {p_end}
{phang2}{cmd:. matchit} {it:mystring1 mystring2}, {bf: sim(ngram,3)} {p_end}

{pstd}Setting score function{p_end}
{phang2}{cmd:. matchit} {it:mystring1 mystring2}, {bf:s(simple)} {p_end}
{phang2}{cmd:. matchit} {it:mystring1 mystring2}, {bf:s(minsimple)} {p_end}

{pstd}Setting weight function{p_end}
{phang2}{cmd:. matchit} {it:mystring1 mystring2}, {bf:w(log)} {p_end}


{pstd}Simple two-datasets syntax{p_end}
{phang2}{cmd:. matchit} {it:myidvar mytextvar} {bf: using} {it:myusingfile.dta} {bf:, idu(}{it:usingidvar}{bf:) txtu(}{it:usingtextvar}{bf:)}

{pstd}Diagnosing problems{p_end}
{phang2}{cmd:. matchit} {it:myidvar mytextvar} using {it:myusingfile.dta}, idu({it:usingidvar}) txtu({it:usingtextvar}) {bf:di} {p_end}
{phang2}{cmd:. matchit} {it:myidvar mytextvar} using {it:myusingfile.dta}, idu({it:usingidvar}) txtu({it:usingtextvar}) {bf:di} {bf: sim(token)}{p_end}

{pstd}Applying automated stopwords list{p_end}
{phang2}{cmd:. matchit} {it:myidvar mytextvar} using {it:myusingfile.dta}, idu({it:usingidvar}) txtu({it:usingtextvar}) {bf:stopw} {p_end}
{phang2}{cmd:. matchit} {it:myidvar mytextvar} using {it:myusingfile.dta}, idu({it:usingidvar}) txtu({it:usingtextvar}) {bf:stopw} {bf: swt(.05)}{p_end}


{synoptline}

{marker remarks}{...}
{title:Remarks:}

{pstd}{bf:Notes on the different matching algorithms}{p_end}

{pstd}Matching algorithms can be categorized in three main families: Vectorial decomposition, Phonetic and Edit-distance algorithms.{p_end}

{pstd} {it:Vectorial decomposition algorithms} (such as N-Gram, Token, etc) basically compares the elements of two strings.
The N-gram algorithm decomposes the text string into elements of N characters ({it:grams}) using a moving-window
basis. As depicted as follows, a 3-gram decomposition of Smith, John and Smit, John have nine and eight 3-grams, respectively,
 but they share six of them: {p_end}

{phang2} {it: Smith, John} : {bf:Smi mit} {it:ith th, h,_ } {bf:,_J  _Jo Joh ohn} {p_end}
{phang2} {it: Smit, John} : {bf:Smi mit} {it: it, t,_ } {bf:,_J  _Jo Joh ohn}{p_end}

{pstd}Similarly,  a 3-gram decomposition of John Smith has eight 3-grams and shares five of them with Smith, John
({it:John Smith} : {bf:Joh ohn} {it:hn  n S  Sm} {bf:Smi mit ith}). This exemplifies how
{it:vectorial decomposition algorithms} are particularly suitable when facing permutation problems in the data. {p_end}

{pstd}However, {it:vectorial decomposition algorithms} do not need to have a moving-window strucutre. For instance,
the {it:token} algorithm splits a text string simply by its blank spaces.
In John Smith there are only two elements (or {it:grams}): John and Smith.
These match perfectly those {it:grams} from Smith John, but only one from either Smith, John or Smit John. {p_end}

{pstd} {it:Phonetic algorithms} (such as Soundex, Daitch-Mokotoff Soundex, NYSIIS, Double Metaphone, Caverphone, Phonix, Onca,
Fuzzy Soundex, etc) regroup by sound proximity the substrings ({it:phonemes}) of a given string.
For instance, the {it:soundex} algorithm converts both the strings Smith, John and Smit, John into S532,
but Smith, Peter into S531. {p_end}

{pstd} Finally, {it: Edit-distance algorithms} (such as Levenshtein, DamerauLevenshtein, Bitap, Hamming, Boyer-Moore, etc)
are based on the simple precept that any text string can be transformed into another by applying a given number of plain operations.
Transforming Smith, John into Smit, John requires one deletion and the reciproque one insertion.
While transforming Smith, John into Smith, Peter requires nine operations (four deletions and five insertions). {p_end}

{pstd}As today, {cmd:matchit} performs {it:Vectorial decomposition} and {it:phonetic algorithms}
but does not perform {it:edit-distance} ones as they are not indexable.{p_end}

{marker algorithms}{...}
{pstd}{it:Description of available algorithms}{p_end}

{pstd}{it:Vectorial decomposition}{p_end}

{phang2}sim(bigram) or sim(ngram, {bf:2}): Splits text into grams of 2 moving chars. e.g. "John Smith" splits to Jo oh hn n_ _S Sm mi it th {p_end}

{phang2}sim(ngram, {it:n}): Splits text into grams of {it:n} moving chars. e.g if {it:n=3} "John Smith" splits to Joh ohn hn_ n_S _Sm Smi mit ith {p_end}

{phang2}sim(ngram_circ, {it:n}): Splits text into grams of {it:n} moving chars circularly.
i.e. both "John Smith" and "Smith John" splits to exactly the same {it:grams}.
e.g. if {it:n=3} both split to Joh ohn hn_ n_S _Sm Smi mit ith th_ h_J _Jo {p_end}

{phang2}sim(token): Splits text into tokens (see {help mata tokens}). e.g. "John Smith" splits to John Smith {p_end}

{phang2}sim(firstgram, {it:n}): Keeps only the first {it:n} chars of each token.
e.g. if {it:n=3} "John Smith" splits to Joh Smi {p_end}

{phang2}sim(cotoken): Splits text into pairs of colocated tokens.
Better for establishing similarity scores between long texts.
Use with {it:stopwordsauto} recommended.{p_end}

{phang2}sim(scotoken): Splits text into single tokens and pairs of colocated tokens.
Better for establishing similarity scores between long texts.
Use with {it:stopwordsauto} recommended.{p_end}

{pstd}{it:Phonetic algorithms}{p_end}

{phang2}sim(soundex): Recodes text using the soundex algorithm (see {help mata soundex}).
e.g. "John Smith" recodes to J525 {p_end}

{phang2}sim(soundex_nara): Recodes text using the soundex NARA algorithm (see {help mata soundex_nara}).
e.g. "John Smith" recodes to J525 {p_end}

{phang2}sim(soundex_fk): Recodes text using the soundex algorithm but keeping the full key
(i.e. more than 4 digits allowed but ignore trailing zeros).
e.g. recodes to J5253 {p_end}

{phang2}sim(nysiis_fk): Recodes text using the NYSIIS algorithm but keeping the full key
(i.e. more than 6 digits allowed).
e.g. "John Smith" recodes to JANSNAT {p_end}

{pstd}{it:Hybrids}{p_end}

{phang2}sim(soundex_ext): Splits full soundex full key into {it:grams} of increasing size.
e.g. "John Smith" recodes and splits to J5 J52 J525 J5253{p_end}

{phang2}sim(token_soundex) or sim(tokenwrap, "soundex"): applies soundex algorithm to each token.
e.g. "John Smith" recodes and splits to J500 S530 {p_end}

{phang2}sim(tokenwrap, "soundex_nara"): applies soundex NARA algorithm to each token.
e.g. "John Smith" recodes and splits to J500 S530 {p_end}

{phang2}sim(tokenwrap, "soundex_fk"): applies soundex full key to each token.
e.g. "Johnatan Smithsonian" recodes and splits to J535 S532255{p_end}

{phang2}sim(tokenwrap, "soundex_ext"): applies soundex full key to each token and them into {it:grams} of increasing size.
e.g. "Johnatan Smithsonian" recodes and splits to J5 J53 J535 S5 S53 S532 S5322 S53225 S532255{p_end}

{phang2}sim(tokenwrap, "nysiis_fk"): applies NYSIIS full key to each token
e.g. "John Smith" recodes and splits to JAN SNAT {p_end}


{pstd}Each algorithm has its own merits.
For example, phonetic based algorithms are more efficient at managing similar sounds based on misspellings.
The Edit distance algorithm family manages typing or spelling errors effectively.
The N-gram algorithms work effectively on misspellings as well as large string permutations.
Several rankings of matching algorithms are already available in the literature on name matching
(See Pfeifer et al., 1996; Zobel and Dart, 1995; Phua et al., 2007).
Even though a clear hierarchy is hard to achieve for several reasons,
Phonex or 2-gram are found to be better performers than 3-gram, 4-gram, or Damerau-Levenshtein algorithms
(Pfeifer et al., 1996; Phua et al., 2007; Christen, 2006).
According to the surveyed literature, hybrid matching algorithms have even better results
(e.g. Zobel and Dart, 1995; Pfeifer et al., 1996; Hodge and Austin, 2003; Phua et al., 2007).
{p_end}


{pstd}{bf:Notes on the different weighting options}{p_end}

{pstd}
The different algorithms can be customized to improve their performance.
For example, a weighting procedure can be added to the Edit transformations
or to the N-grams and Token vector elements in order to give more relevance to
less likely pieces of information in a text string.
In N-gram or Token algorithms, some {it:grams} - e.g. street or road - may provide less useful
information than rare ones simply because they are too common.
{p_end}

{pstd}
The typical approach is just to weight {it:grams} according to their inverse number of occurrences
in the data.
Hence, based on the frequency of each {it:gram} ({it:f}),
{cmd:matchit} can compute weights in the following ways:
{p_end}

{phang2}{it:simple = 1/f}{p_end}
{phang2}{it:root = 1/sqrt(f)}{p_end}
{phang2}{it:log = 1/log(f)}{p_end}

{pstd}
As aparent from the formulas, all these assign less importance to those more frequent {it:grams}.
The main difference is how fast they "punish" high frequencies,
where {it:simple} does it faster than {it:root}, which does it faster than {it:log}.
However, in practice, there are more differences between using or not weights
than among the three computation strategies.
Note that {cmd:matchit} computes the weights based on frequencies found in both string variables,
regardless if they are found in the same or in two different datasets
(i.e. the {it:masterfile} and the {it:usingfile}).
{p_end}


{pstd}{bf:Notes on the different scoring options}{p_end}

{pstd}
Text similarity is typically computed using variations of the Jaccard index, which basically means the intersection
between the two strings over the union of them.
Taking {it:m} as the amount of {it:grams} matched and {it:s1} and {it:s2} as the amount of {it:grams}
in the first and second string, respectively, {cmd:matchit} computes three scoring variations:
{p_end}

{phang2}{it:jaccard = m/sqrt(s1*s2)} {p_end}
{phang2}{it:simple = 2*m/(s1+s2)} {p_end}
{phang2}{it:minsimple = m/min(s1,s2)} {p_end}

{pstd}
All these should range between 0 and 1, reflecting none to perfect similarity
(always relative to the similarity function chosen).
As apparent from the formulas, all these are exactly the same if {it:s1} and {it:s2} are equal.
In simple terms, the major difference among these is how they treat the dissimilar part of the longer string.
{it:Jaccard} and {it:simple} basically take a geometric and arimethic mean, respectively;
while {it:minsimple} considers only the shorter string.
If one of the two sources has unuseful information in the string
- e.g. address information embedded in the company name field -
{it:minsimple} might be preferred at the expense of increasing the false positive results.
{p_end}

{pstd}
In the case of using any weighting (or stopwords) option ,
the previous formulas still hold but {it:m}, {it:s1} and {it:s2} are weighted
(or ignored) instead of just counts of {it:grams}.
{p_end}

{marker tips}{...}
{title:Some useful tips when using matchit with two the datasets:}

{phang}1) While {cmd:matchit} replicates the most standard use of {help merge} command
(i.e. intersection _merge == 3),
it does it less efficiently when there is no risk of false negatives. {p_end}

{phang}2) After using {cmd:matchit}, the resulting dataset can be easily merged with
either the {it:master} or {it:using} datasets using the {help merge} or {help joinby} commands.{p_end}

{phang2}{cmd:. matchit} {it:myidvar mytextvar} {bf: using} {it:myusingfile.dta}
{bf:, idu(}{it:usingidvar}{bf:) txtu(}{it:usingtextvar}{bf:)} {p_end}
{phang2}{cmd:. merge} m:1 {it:myidvar} {bf: using} {it:mymasterfile.dta} {p_end}
{phang2}{cmd:. merge} m:1 {it:usingidvar} {bf: using} {it:myusingfile.dta} {p_end}

{phang}3)It does not matter in substance which file is used as {it:master} or {it:using} file.
It just matters in the order of the columns in the resulting dataset.
The computational time is likely to differ, but these differences are not found substantive (within 5%).
{p_end}

{phang}4)Observations in the resulting dataset are not sorted.
This can be easily done by making use of sorting commands such as
{help sort} or {help gsort} after running {cmd:matchit}.
Often, it is useful to sort the resulting dataset from the higher similarity score
to the lower one in order to manually establish the best threshold to keep.
{p_end}

{phang2}{cmd:. matchit} {it:myidvar mytextvar} {bf: using} {it:myusingfile.dta}
{bf:, idu(}{it:usingidvar}{bf:) txtu(}{it:usingtextvar}{bf:)} {p_end}
{phang2}{cmd:. gsort} {bf:-}{it:similscore}{p_end}

{phang}5)You can customize {cmd:matchit} by adding your own similarity, weighting or scoring functions
and benefit from its indexing and other features.
All these are coded in Mata as functions with relatively simple structure and naming conventions, which are described as follows:
{p_end}

{phang2} {it:Similarity functions} just receive a string scalar, parses it into {it:grams} and return them in an associative array.
Optionally, you can have an argument passed to the custom function (like {it:simf_ngram} or {it:simf_tokenwrap} do),
which has to be passed after the string and it is used only within your function.
The naming convention is to have {it:simf_} before the name of your function.{p_end}

{phang2} {it:Weighting functions} just receive a numeric scalar with the {it:gram} frequency
and return a numeric scalar transformation of it.
The naming convention is to have {it:weight_} before the name of your function.{p_end}

{phang2} {it:Scoring functions} receive three numeric scalars and return a single numeric scalar transformation of them.
The three numeric scalars are passed in the following order:
First, the amount of {it:grams} matched;
second, the amount of {it:grams} from the string in the master file (or first column);
and, third, the amount of {it:grams} from the string in the using file (or second column).
The naming convention is to have {it:score_} before the name of your function.{p_end}

{marker author}{...}
{title:Author}

{pstd}Julio D. Raffo{p_end}

{marker references}{...}
{title:References}

{pstd}
Christen, P., 2006.
A comparison of personal name matching: techniques and practical issues.
Proceedings of the Workshop on Mining Complex Data (MCD).
IEEE International Conference on Data Mining (ICDM), Hong Kong, December.
{p_end}

{pstd}
Hodge, V.J., Austin, J., 2003.
A comparison of standard spell checking algorithms and a novel binary neural approach.
IEEE Transactions on Knowledge and Data Engineering 15 (5), 10731081.
{p_end}

{pstd}
Pfeifer, U., Poersch, T., Fuhr, N., 1996.
Retrieval effectiveness of proper name search methods.
Information Processing & Management 32 (6), 667679.
{p_end}

{pstd}
Phua, C., Lee, V., Smith-Miles, K., 2007.
The personal name problem and a recommended data mining solution.
Encyclopedia of Data Warehousing and Mining, 2nd ed. IDEA Group Publishing.
{p_end}

{pstd}
Raffo, J., & Lhuillery, S. (2009).
How to play the Names Game: Patent retrieval comparing different heuristics.
Research Policy, 38(10), 16171627. doi:10.1016/j.respol.2009.08.001
{p_end}

{pstd}
Zobel, J., Dart, P., 1995.
Finding approximate matches in large lexicons.
SoftwarePractice and Experience 25 (3), 331345.
{p_end}



{marker table_examples}{...}
{title:Examples for "John Smith":}
{asis}
----------------------------------------------------------------
#                          token_                  ngram_ ngram_
grams bigram token soundex soundex ngram,1 ngram,3 circ,2 circ,3
----------------------------------------------------------------
 1    Jo     John  J525    J500    J       Joh     Jo     Joh
 2    oh     Smith         S530    o       ohn     oh     ohn
 3    hn                           h       hn_     hn     hn_
 4    n_                           n       n_S     n_     n_S
 5    _S                           _       _Sm     _S     _Sm
 6    Sm                           S       Smi     Sm     Smi
 7    mi                           m       mit     mi     mit
 8    it                           i       ith     it     ith
 9    th                           t               th     th_
10                                 h               h_     h_J
11                                                 _J     _Jo
----------------------------------------------------------------
Notes: "_" = a blank space.
       ngram, 2 is equivalent to bigram.
