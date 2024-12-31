{smcl}
{hline}
help for {hi:xsvmat}{right:(Roger Newson)}
{hline}

{title:Convert a matrix to variables in an output dataset (or resultsset)}

{p 8 17 2}{cmd:xsvmat}  {dtype} [ {it:A} ] [{cmd:,}
 {break}
 {cmdab:fr:om}{cmd:(}{help matrix:{it:matrix_expression}}{cmd:)}
 {break}
 {cmdab:li:st}{cmd:(} [{varlist}] {ifin} [ , [{it:list_options}] ] {cmd:)}
 {break}
 {cmdab:fra:me}{cmd:(} {it:framename} [ , replace {cmdab:ch:ange} ] {cmd:)}
 {break}
 {cmdab:sa:ving}{cmd:(}{it:filename}[{cmd:, replace}]{cmd:)}
 {break}
 {cmdab::no}{cmdab:re:store} {cmd:fast}
 {break}
 {cmdab:fl:ist}{cmd:(}{it:global_macro_name}{cmd:)}
 {break}
 {cmdab:n:ames:(col}|{cmd:eqcol}|{cmd:matcol}|{it:string}{cmd:)}
 {break}
 {cmdab:idn:um}{cmd:(}{it:#}{cmd:)} {cmdab:nidn:um}{cmd:(}{it:newvarname}{cmd:)}
 {cmdab:ids:tr}{cmd:(}{it:string}{cmd:)} {cmdab:nids:tr}{cmd:(}{it:newvarname}{cmd:)}
 {break}
 {opt rowe:q(newvarname)}
 {opt rown:ames(newvarname)}
 {opt roweqn:ames(newvarname)}
 {opt rowl:abels(newvarname)}
 {break}
 {opt cole:q(charname)}
 {opt coln:ames(charname)}
 {opt coleqn:ames(charname)}
 {opt coll:abels(charname)}
 {break}
 {opt ren:ame(renaming_list)}
 {cmdab:fo:rmat}{cmd:(}{it:varlist_1 format_1 ... varlist_n format_n}{cmd:)}
 {break}
 ]

{pstd}
where {it:A} is the name of an existing matrix, and {it:type} is a storage type for new variables,
and {it:renaming_list} is a list of {help varname:variable names} of form

{pstd}
{it:oldvarname_1 newvarname_1 ... oldvarname_n newvarname_n}


{title:Description}

{pstd}
{cmd:xsvmat} is an extended version of {helpb svmat}.
It creates an output dataset (or resultsset),
with one observation per row of either an existing matrix or the result of a matrix expression,
and data on the values of the column entries in that row,
and, optionally, extra variables specified by the user.
The output dataset created by {cmd:xsvmat}
may be listed to the Stata log,
or saved to a {help frame:data frame},
or saved to a disk file,
or written to the memory (overwriting any pre-existing dataset).


{title:Options for use with {cmd:xsvmat}}

{p}
{cmd:xsvmat} has a large number of options, which are listed in 3 groups:

{p 0 4}{bf:1.} Input-source options. (These specify the input matrix.)

{p 0 4}{bf:2.} Output-destination options.
(These specify where the output dataset will be written.){p_end}

{p 0 4}{bf:3.} Output-variable options. (These specify the variables in the output dataset.){p_end}


{title:Input-source options}

{phang}{cmd:from(}{help matrix:{it:matrix_expression}}{cmd:)} specifies a matrix expression,
which is used to generate the input matrix.
Either the {cmd:from()} option or the input matrix name {it:A} must be present,
but not both.


{title:Output-destination options}

{phang}{cmd:list(} [{varlist}] {ifin} [, {it:list_options} ] {cmd:)}
specifies a list of variables in the output
dataset, which will be listed to the Stata log by {cmd:xsvmat}.
The {cmd:list()} option can be used with the {cmd:format()} option (see below)
to produce a listing
with user-specified numbers of decimal places or significant figures.
The user may optionally also specify {helpb if} or {helpb in} qualifiers to list subsets of combinations
of variable values,
or change the display style using a list of {it:list_options} allowed as options by the {helpb list} command.

{phang}{cmd:frame(} {it:name}, [ {cmd:replace} {cmd:change} ] {cmd:)} specifies an output {help frame:data frame},
containing the output dataset.
If {cmd:replace} is specified, then any existing data frame of the same name is overwritten. 
If {cmd:change} is specified,
then the current data frame will be changed to the output data frame after the execution of {cmd:xsvmat}.
The {cmd:frame()} option may not specify the current data frame.
To do this, use one of the options {cmd:norestore} or {cmd:fast}.

{phang}{cmd:saving(}{it:filename}[{cmd:, replace}]{cmd:)} saves the output dataset to a disk file.
If {cmd:replace} is specified, and a file of that name already exists,
then the old file is overwritten.

{phang}{cmd:norestore} specifies that the output dataset will be written to the memory,
overwriting any pre-existing dataset.
This option is automatically set if {cmd:fast} is specified.
Otherwise, if {cmd:norestore} is not specified, then the pre-existing dataset is restored
in the memory after the execution of {cmd:xsvmat}.

{phang}{cmd:fast} is an alternative way of specifying {cmd:norestore}

{phang}Note that the user must specify at least one of the five options
{cmd:list()}, {cmd:frame()}, {cmd:saving()}, {cmd:norestore} and {cmd:fast}.
These five options specify whether the output dataset is listed to the Stata log,
saved to a data frame,
saved to a disk file, or written to the memory (overwriting any pre-existing dataset).
More than one of these options can be specified.

{phang}{cmd:flist(}{it:global_macro_name}{cmd:)} specifies the name of a {help macro:global macro},
containing a filename list (possibly empty).
If {cmd:saving()} is also specified, then
{cmd:xsvmat} will append the name of the dataset specified in the
{cmd:saving()} option to the value of the {help macro:global macro} specified in {cmd:flist()}.
This enables the user to build a list of filenames in a {help macro:global macro}, containing the
output of a sequence of output datasets.
These files may later be concatenated using {helpb append}.


{title:Output-variable options}

{phang}
{cmd:names(}{cmd:col}|{cmd:eqcol}|{cmd:matcol}|{it:string}{cmd:)}
specifies how the new variables created from the matrix columns are to be named.

{pmore}
{cmd:names(col)} uses the column names of the matrix to name the variables.

{pmore}
{cmd:names(eqcol)} uses the equation names prefixed to the column names.

{pmore}
{cmd:names(matcol)} uses the matrix name prefixed to the column names.

{pmore}
{cmd:names(}{it:string}{cmd:)} names the variables
    {it:string}{hi:1}, {it:string}{hi:2}, ..., {it:string}n, where {it:string}
    is a user-specified {it:string} and n is the number of columns of the
    matrix.

{pmore}
If {cmd:names()} is not specified, the variables are named
    {it:A}{hi:1}, {it:A}{hi:2}, ..., where {it:A} is the name of the matrix.

{phang}{cmd:idnum(}{it:#}{cmd:)} specifies an ID number for the output dataset.
It is used to create a numeric variable, with default name {hi:idnum}, in the output dataset,
with that value for all observations.
This is useful if the output dataset is concatenated with other {cmd:xsvmat} output datasets
using {helpb append}.

{phang}{cmd:nidnum(}{it:newvarname}{cmd:)} specifies a name for the numeric ID variable
evaluated by {cmd:idnum()}.
If {cmd:idnum()} is present and {cmd:nidnum()} is absent,
then the name of the numeric ID variable is set to {hi:idnum}.

{phang}{cmd:idstr(}{it:string}{cmd:)} specifies an ID string for the output dataset.
It is used to create a string variable, with default name {hi:idstr} in the output dataset,
with that value for all observations.
This is useful if the output dataset is concatenated with other {cmd:xsvmat} output datasets
using {helpb append}.

{phang}{cmd:nidstr(}{it:newvarname}{cmd:)} specifies a name for the string ID variable
evaluated by {cmd:idstr()}.
If {cmd:idstr()} is present and {cmd:nidstr()} is absent,
then the name of the string ID variable is set to {hi:idstr}.

{phang}
{opt roweq(newvarname)} specifies a name for a new variable to be created in the output dataset,
containing the matrix row equation name.

{phang}
{opt rownames(newvarname)} specifies a name for a new variable to be created in the output dataset,
containing the matrix row name.

{phang}
{opt roweqnames(newvarname)} specifies a name for a new variable to be created in the output dataset,
containing the matrix row name,
prefixed by the row equation name followed by a colon,
if the row equation name is present.

{phang}
{opt rowlabels(newvarname)} specifies a name for a new variable to be created in the output dataset,
containing, in the observation corresponding to each row,
the {help label:variable label} of the variable in the existing dataset whose name is the matrix row name
(if such a variable exists),
or "Constant" if the row name is {cmd:_cons}.

{phang}
{opt coleq(charname)} specifies a name for a {help char:variable characteristic}
to be set for each matrix column variable in the output dataset,
containing the matrix column equation name.

{phang}
{opt colnames(charname)} specifies a name for a {help char:variable characteristic}
to be set for each matrix column variable in the output dataset,
containing the matrix column name.

{phang}
{opt coleqnames(charname)} specifies a name for a {help char:variable characteristic}
to be set for each matrix column variable in the output dataset,
containing the matrix column name,
prefixed by the column equation name followed by a colon,
if the column equation name is present.

{phang}
{opt collabels(charname)} specifies a name for a {help char:variable characteristic}
to be set for each matrix column variable in the output dataset,
containing the {help label:variable label} of the variable in the existing dataset
whose name is the matrix column name
(if such a variable exists),
or "Constant" if the column name is {cmd:_cons}.

{p 4 8 2}
{cmd:rename(}{it:oldvarname_1 newvarname_1 ... oldvarname_n newvarname_n}{cmd:)}
specifies a list of pairs of variable names.
The first variable name of each pair specifies a
variable in the output dataset, which is renamed to the second
variable name of the pair.

{phang}{cmd:format(}{it:varlist_1 format_1 ... varlist_n format_n}{cmd:)}
specifies a list of pairs of {help varlist:variable lists} and {help format:display formats}.
The {help format:formats} will be allocated to
the variables in the output dataset specified by the corresponding {it:varlist_i} lists.
If {cmd:rename()} is specified, then
any variable names specified by the {cmd:format()} option must be the new names.


{title:Examples}

{pstd}
Set-up commands:

{phang}{cmd:. sysuse auto, clear}{p_end}
{phang}{cmd:. regress mpg weight length price foreign}{p_end}
{phang}{cmd:. matrix define covmat=e(V)}{p_end}
{phang}{cmd:. matrix list covmat}{p_end}

{pstd}
The following examples use the {cmd:list()} option to list the output dataset to the Stata log.
After these examples are executed, there is no new dataset either in the memory or on disk.

{phang}{cmd:. xsvmat covmat, list(,)}{p_end}
{phang}{cmd:. xsvmat covmat, rowname(xvar) rowlab(label) list(, abbr(32))}{p_end}

{pstd}
The following example uses the {cmd:rowlabel()}, {cmd:collabel()} and {cmd:list()} options
to list a matrix,
with its rows and columns labelled
with the corresponding {help label:variable labels} in the existing dataset.

{phang}{cmd:. xsvmat covmat, rowlabel(rowid) collabel(varname) list(, abbr(32) subvarname)}{p_end}

{pstd}
The following example uses the {cmd:norestore} option to create an output dataset in the memory,
overwriting any pre-existing dataset.

{phang}{cmd:. xsvmat double covmat, norestore rownames(param) rowlabels(varlab)}{p_end}
{phang}{cmd:. describe}{p_end}
{phang}{cmd:. list}{p_end}

{pstd}
The following example uses the {cmd:saving()} option to create an output dataset in a disk file.

{phang}{cmd:. xsvmat covmat, rowname(parm) rowlab(parmlab) name(matcol) saving(mycovs1.dta, replace)}{p_end}
{phang}{cmd:. describe using mycovs1}{p_end}

{pstd}
The following example uses the {cmd:from()} option to create and list an output dataset,
with 1 observation per parameter of a fitted model.

{phang}{cmd:. regress mpg weight length price foreign}{p_end}
{phang}{cmd:. xsvmat, from(r(table)') rowname(parm) names(col) rowlab(label) list(,)}{p_end}

{pstd}
The following example uses the {cmd:from()} option to create an output dataset
in a new data frame {cmd:outframe},
with 1 observation per parameter of a fitted model.
It then uses {helpb describe} and {helpb list}
to describe and list the output data set,
before dropping the output data frame.

{phang}{cmd:. regress mpg weight length price foreign}{p_end}
{phang}{cmd:. xsvmat, from(r(table)') rowname(parm) names(col) rowlab(label) frame(outframe, replace)}{p_end}
{phang}{cmd:. frame outframe {c -(}}{p_end}
{phang}{cmd:. describe, full}{p_end}
{phang}{cmd:. list, abbr(32)}{p_end}
{phang}{cmd:. {c )-}}{p_end}
{phang}{cmd:. frame drop outframe}{p_end}


{title:Author}

{pstd}
Roger Newson, Imperial College London, UK.
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:Also see}

{p 4 13 2}
Manual:  {hi:[P] matrix mkmat}, {hi:[D] append}, {hi:[D] format}
{p_end}

{p 4 13 2}
Online:  help for {helpb svmat}, {helpb mkmat}, {helpb append}, {helpb format}
{p_end}
