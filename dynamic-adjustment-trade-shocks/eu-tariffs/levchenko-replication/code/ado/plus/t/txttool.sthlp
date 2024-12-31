{smcl}
{cmd:help txttool}{right: ({browse "http://www.stata-journal.com/":SJX-X: dmXXXX})}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col:{hi:txttool} {hline 2}}Utilities for text analysis{p_end}
{p2colreset}{...}


{title:Description}

{pstd}{cmd:txttool} provides a set of tools for managing and analyzing free-form text. The program integrates several built-in Stata functions with new text capabilities, including a utility to create a bag-of-words representation of text and an implementation of Porter’s word stemming algorithm.


{title:Syntax}

{p 8 16 2}
{cmd:txttool} {it:varname} {ifin} [{cmd:,} 
{cmd:stem}
{cmdab:stop:words(}{it:filename}{cmd:)}
{cmdab:sub:words(}{it:filename}{cmd:)}
{cmdab:gen:erate(}{it:newvarname}{cmd:)}
{cmd:replace}
{cmdab:bag:words}
{cmdab:pre:fix(}{it:string}{cmd:)}
{cmd:noclean}
{cmdab:noout:put}]

{pstd}{it:varname} is the string variable containing the text to be processed.{p_end}


{title:Options}

{phang}{opt stem} calls the Porter stemmer implementation to stem all of the words in {it:varname}.

{phang}{opt stopwords(filename)} indicates that the program should remove all instances of words contained in {it:filename}. The filename is simply a list of words in text file. Although a list of frequently used English words is supplied with txttool, users can use different lists of stopwords in different applications by specifying different filenames. Stopword lists without punctuation are recommended.

{phang}{opt subwords(filename)} indicates that the program should substitute instances of words in {it:filename} with another word in {it:filename}.  The filename is a tab-delimited text file, where the first column is the word to be replaced and the second word is the text to substitute in. Users can use different lists of words to substitute in different applications by specifying different filenames. Subword lists without punctuation are recommended.

{phang}{opt generate(newvarname)} creates a new string variable {it:newvarname} containing the processed text of {it:varname}. The {it:newvarname} will be a copy of varname that has been stemmed, had the stopwords removed, words substituted, and/or cleaned, depending on the other options selected.  Either {opt generate} or {opt replace} is required.

{phang}{opt replace} replaces the original text in {it:varname} with text that has been stemmed, had the stopwords removed, words substituted, and/or cleaned, depending on the other options selected.  Either {opt generate} or {opt replace} is required.

{phang}{opt bagwords} tells {cmd:txttool} to create a bag of words representation of the text in {it:varname}. The bag of words representation consists of new variables, one for each unique word in {it:varname}, and populated with the count of the occurrences of each word. The new variables are named with the convention {it:prefix_word}, where {it:prefix} is optionally supplied by the user, and {it:word} is the unique word in the text. The options generate and bagwords can be used together to represent the processed text as a single column and counts of words.

{phang}{opt prefix(string)} supplies a prefix for the variables created in {opt bagwords}. If no prefix is supplied, the default is “w_”. Supplying a prefix will automatically invoke the {opt bagwords} option. Note that {cmd:txttool} does not know what variables will be created before processing the text, and so cannot confirm the absence of variables already named with the selected prefix. Errors will therefore result if the prefix chosen matches an existing variable.

{phang}{opt noclean} specifies that the program should not remove punctuation, extra white spaces, and special characters from varname. By default, {cmd:txttool} will clean and lowercase {it:varname}. The {opt noclean} option is not allowed with bagwords. In addition, because the Porter stemmer does not stem punctuation, and because the stopwords and subwords lists should not include punctuation, {cmd:noclean} should be used with caution.

{phang}{opt nooutput} suppresses the default output. By default, {cmd:txttool} reports the total number of words and the count of unique words before and after processing, as well as the time elapsed during processing. The {cmd:nooutput} option suppresses this output, which can save some time with large processing tasks.


{title:Remarks}

{pstd}{cmd:txttool} options are process in the following order: cleaning, subwords, stopwords, stem, generate and bagwords.

{pstd}By default, {cmd:txttool} will lowercase {it:varname} and clean the text by removing all characters except whitespace (ASCII code 32), numerals (ASCII codes 48-57) and letters (ASCII codes 97-122).  To preserve any other characters, select the {opt noclean}.  Note that the Porter stemmer stems only English words without punctuation, and may not function as expected with the {opt noclean} option.  In addition, Stata does not allow any other characters to appear in variable names, so {opt bagwords} is not allowed with {opt noclean}.


{title:Examples}

{phang}{cmd:. txtttol(exampletext), replace}

{phang}{cmd:. txtttol(exampletext), generate(newtext) noclean}

{phang}{cmd:. txtttol(exampletext), stem generate(newtext) subwords("C:\sublist.txt") stopwords("C:\stoplist.txt")}

{phang}{cmd:. txtttol(exampletext), stem generate(newtext) bagwords prefix("w_")}


{title:Author}

{phang}Unislawa Williams, Spelman College{p_end}
{phang}{browse "mailto:uwilliams@spelman.edu":uwilliams@spelman.edu}{p_end}


{title:Also see}

{p 4 14 2}
Article:  {it:Stata Journal}, volume XX, number XX: {browse "http://www.stata-journal.com/article.html?article=dm00XX":dm00XX}

{p 4 14 2}{space 3}Help:  {manhelp replace D}, {manhelp generate D}, {manhelp regexm() D}
