{smcl}
{* 16aug2016}{...}
{cmd:help lsemantica}{right: ({browse "https://doi.org/10.1177/1536867X19830910":SJ19-1: st0552})}
{hline}

{title:Title}

{p2colset 5 19 21 2}{...}
{p2col :{hi:lsemantica} {hline 2}}Latent semantic analysis in Stata{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 17 2}
{cmd:lsemantica} {varname} [{cmd:,} {it:options}]

{synoptset 27}{...}
{synopthdr}
{synoptline}
{synopt :{opt comp:onents(integer)}}number of components{p_end}
{synopt :{opt tf:idf}}reweight by term-frequency-inverse-document-frequency{p_end}
{synopt :{opt mi:n_char(integer)}}minimal number of characters in word{p_end}
{synopt :{opth stop:words(strings:string)}}list of stop words{p_end}
{synopt :{opt min_freq(integer)}}minimal document frequency for words{p_end}
{synopt :{opt max_freq(real)}}maximal document frequency for words{p_end}
{synopt :{opth na:me_new_var(strings:string)}}name of new variables{p_end}
{synopt :{opt ma:t_save}}save word-component matrix{p_end}
{synopt :{opth pa:th(strings:string)}}path in which to save word-component matrix{p_end}
{synoptline}

 
{title:Description} 

{p 4 4 2}
{cmd:lsemantica} implements latent semantic analysis (LSA) into Stata.

{p 4 4 2}
The {cmd:lsemantica} command generates new variables equal to the number of
components chosen by the user.  Each of these variables contains the result
from the truncated singular value decomposition.


{marker Options}{...}
{title:Options}

{phang}
{cmd:components(}{it:integer}{cmd:)} specifies the number of components the
semantic space should be reduced to by {cmd:lsemantica}.  The number of
components is usually chosen based on the size of the vocabulary.  The default
is {cmd:components(300)}.

{phang}
{cmd:tfidf} specifies whether term-frequency-inverse-document-frequency
reweighting should be used before applying the truncated singular value
decomposition.  In most cases term-frequency-inverse-document-frequency
reweighting will improve the results.

{phang}
{cmd:min_char(}{it:integer}{cmd:)} allows the removal of short words from the
texts.  Words with fewer characters than {cmd:min_char(}{it:integer}{cmd:)}
will be excluded from LSA.  The default is {cmd:min_char(0)}.

{phang}
{cmd:stopwords(}{it:string}{cmd:)} specifies a list of words to exclude from
{cmd:lsemantica}.  Usually, highly frequent words such as "I", "you", etc.,
are removed from the text because these words contribute little to the meaning
of documents.  Predefined stop word lists for different languages are
available online.

{phang}
{cmd:min_freq(}{it:integer}{cmd:)} allows the removal of words that appear in
fewer documents.  Words that appear in fewer documents than
{cmd:min_freq(}{it:integer}{cmd:)} will be excluded from LSA.  The default is
{cmd:min_freq(0)}.

{phang}
{cmd:max_freq(}{it:real}{cmd:)} allows the removal of words that appear
frequently in documents.  Words that appear in a share of more than
{cmd:max_freq(}{it:real}{cmd:)} documents will be excluded from LSA.  The
default is {cmd:max_freq(1)}.

{phang}
{cmd:name_new_var(}{it:string}{cmd:)} specifies the name of the output
variable created by {cmd:lsemantica}.  These variables contain the topic
assignments for each document.  The user should ensure that
{cmd:name_new_var(}{it:string}{cmd:)} is unique in the dataset.  By default,
the name of the variable is {cmd:component_}, so the names of the new
variables will be {cmd:component_1}-{cmd:component_}{it:C}, where {it:C} is
the number of components.

{phang}
{cmd:mat_save} specifies whether the word-component matrix should be saved.
This matrix describes semantic relationships between words.  By default, the
matrix will not be saved.

{phang}
{cmd:path(}{it:string}{cmd:)} sets the path where the word-component matrix
is saved.


{title:Remarks}

{pstd}
To run {cmd:lsemantica}, the user needs to specify the variables containing
the text for the truncated singular value decomposition.  The options
allow one to adjust the results of LSA.


{title:How to interpret the output}

{p 4 4 2}
{cmd:lsemantica} generates C new variables.  These variables describe the LSA
components.

{p 4 4 2}
To save the word component matrix, one must specify the {cmd:mat_save} option.
A Mata matrix file with the name {cmd:word_comp.mata} is then
stored in {cmd:path(}{it:string}{cmd:)}.

{p 4 4 2}
The file contains the components associated which each word in the vocabulary.
{cmd:lsemantica} also provides the {cmd:lsemantica_word_comp} command, which
imports the stored word-component matrix into Stata.  The syntax for
{cmd:lsemantica_word_comp} is simply

{p 8 17 2}
{cmd:lsemantica_word_comp using} {it:filename}{p_end}


{title:Examples}

{pstd}
To run LSA, type{p_end}
{phang2}
{cmd:. lsemantica title, components(200) tfidf min_char(3) min_freq(5) max_freq(0.5) name_new_var("component_") stopwords("I you she he")}{p_end}

{pstd}
To import the word-component matrix, type{p_end}
{phang2}
{cmd:. lsemantica_word_comp using "word_comp.mata"}


{title:Author}

{pstd}Carlo Schwarz{p_end}
{pstd}University of Warwick{p_end}
{pstd}Coventry, UK{p_end}
{pstd}c.r.schwarz@warwick.ac.uk{p_end}
{pstd}{browse "http://www.carloschwarz.eu"}{p_end}


{marker alsosee}{...}
{title:Also see}

{p 4 14 2}
Article:  {it:Stata Journal}, volume 19, number 1: {browse "https://doi.org/10.1177/1536867X19830910":st0552}{p_end}
