{smcl}
{* *! version Oktober 26, 2017 @ 12:04:00}{...}
{* link to other help files which could be of use}{...}
{vieweralsosee "soepuse" "help soepuse "}{...}
{vieweralsosee "psiduse" "help soepuse "}{...}
{viewerjumpto "Syntax" "psid##syntax"}{...}
{viewerjumpto "psid install" "psid##install"}{...}
{viewerjumpto "psid use" "psid##use"}{...}
{viewerjumpto "psid add" "psid##use"}{...}
{viewerjumpto "psid long" "psid##long"}{...}
{viewerjumpto "psid vardoc" "psid##vardoc"}{...}
{viewerjumpto "Examples" "psid##examples"}{...}
{viewerjumpto "Acknowledgements" "psid##acknowledgements"}{...}
{viewerjumpto "Author" "psid##author"}{...}
{viewerjumpto "References" "psid##references"}{...}
{...}
{title:Title}

{phang}
{cmd:psid} {hline 2}  Create and retrieve PSID data
{p_end}

{marker syntax}{...}
{title:Syntax}

{* put the syntax in what follows. Don't forget to use [ ] around optional items}{...}


{p 8 17 2}
   {cmd:psid install} 
   [ {help numlist:wavelist} ]
   [ {help using} ] 
   [ {cmd:, }
     {it:install_options}  
   ]
{p_end}

{p 8 17 2}
   {cmd:psid install} 
    {help using} 
   [ {cmd:, cnef }
     {it:install_options}  
   ]
{p_end}

{p 8 17 2}
   {cmd: psid use || }
   {it: newstub} {it:varspecs}
   {help using}
   [{cmd:,}
   {it:options use_options}
   ]
{p_end}

{p 8 17 2}
   {cmd: psid add || }
   {it: newstub} {it:varspecs}
   [{help using}]
   [{cmd:,}
   {it:options}
   ]
{p_end}

{p 8 17 2}
   {cmd:psid long} 
{p_end}

{p 8 17 2}
   {cmd:psid vardoc} 
    {help varname} 
   [ {cmd:, }
     {it:vardoc_options}  
   ]
{p_end}


{* the new Stata help format of putting detail before generality}{...}
{synoptset 26 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt do:file(filename, ...)}} Document retrival in a do-file{p_end}
{synopt:{opt f:type(cnef|wealth)}} Access simplified syntax{p_end}
{synopt:{opt k:eepnotes}} Keep notes of orig. varnames{p_end}
{synopt:{opt l:ower}} Varnames of PSID files are lower case{p_end}
{synopt:{opt w:aves(wavelist)}} Waves to be retrived{p_end}

{syntab:Use options}
{synopt:{opt d:esign(designtype)}} Design; default: {cmd:design(balanced)}{p_end}
{synopt:{opt clear}} Replace data in memory{p_end}

{syntab:Install options}
{synopt:{opt to(dirname)}} dta-directory; default: {cmd:to(.)}{p_end}
{synopt:{opt cnef}} Install CNEF instead of PSID{p_end}
{synopt:{opt replace}} Rebuild dta-files already installed{p_end}
{synopt:{opt upgrade}} Download new CNEF delivery from the Internet{p_end}
{synopt:{opt l:ower}} Make varnames in dta-files lower case{p_end}
{synopt:{opt clean}} Erase downloaded CNEF zip-file after installation{p_end}
{synopt:{opt replacelong}} Overwrites existing CNEF_long data{p_end}
{synopt:{opt replacesingle}} Overwrites existing single year CNEF data{p_end}
{synopt:{opt longonly}} Do not creat single year CNEF data{p_end}

{syntab:Vardoc options}
{synopt:{opt add:valuelabel(lblname)}} Retrieve value labels from the Internet{p_end}
{synopt:{opt s:how}} Show description in presence of option addvaluelabel{p_end}
{synoptline}
{p2colreset}{...}

{pstd} {help using} points to the PSID-directory for {cmd: psid use}
and {cmd: psid add}. It defaults to the directory specified in
{cmd:psid use} for {cmd:psid add}. For {cmd:psid install},
{help using} specifies the directory holding the downloaded zip-files of
PSID data. It defaults to the working directory.  {help using} is
compulsory for {cmd:psid install} with option {cmd:cnef}; see the {help psid##install}.
{it:newstub} and {it:varspecs} are described in detail {help psid##use:below}.

{marker description}{...}
{title:Description}

{pstd} {cmd:psid} is an interface to the "Panel Study of Income
Dynamics" (PSID) and to the American branch of the "Cross National
Equivalence File" (CNEF). It performs the following tasks:
{p_end}

{p2colset 8 22 22 10}
{p2col: command} task {p_end}
{p2line}
{p2col: {help psid##install:psid install}}Create Stata datasets from the zip-files
downloadable at {browse "http://simba.isr.umich.edu/Zips/ZipMain.aspx"} without any user
intervention.{p_end}
{p2col: {help psid##use:psid use}}Load items from several waves of the PSID or CNEF into memory{p_end}
{p2col: {help psid##use:psid add}}Merges items from several waves of the PSID/CNEF to a
PSID/CNEF file in memory{p_end}
{p2col: {help psid##long:psid long}}Make data long (and keep the labels)  
{p_end}
{p2col: {help psid##vardoc:psid vardoc}}Displays "official" Online variable description in a browser window   
{p_end}
{p2line}

{pstd}The order in the table above reflects the order of typical use
and the order of the descriptions in this help file. {p_end}

{pstd} {cmd: psid use} and {cmd: psid add} are new versions of
{help psiduse} and {help psidadd} that have been available on SSC for years.
These older programs are bundled with the present program for
compatibility reasons. However, {cmd:psiduse} is no longer maintained
and should not be used for new projects. {p_end}

{marker install}{...}

{title:Syntax of psid install}

{p 8 17 2}
   {cmd:psid install} 
   [ {help numlist:wavelist} ]
    {help using} 
   [ {cmd:, }
     {it:install_options}  
   ]
{p_end}

{* the new Stata help format of putting detail before generality}{...}
{synoptset 26 tabbed}{...}
{synopthdr}
{synoptline}

{syntab:Install options}
{synopt:{opt to(dirname)}} dta-directory; default: {cmd:to(.)}{p_end}
{synopt:{opt cnef}} Install CNEF instead of PSID{p_end}
{synopt:{opt replace}} Rebuild dta-files already installed{p_end}
{synopt:{opt upgrade}} Download new CNEF delivery from the Internet{p_end}
{synopt:{opt l:ower}} Make varnames in dta-files lower case{p_end}
{synopt:{opt clean}} Erase downloaded CNEF zip-file after installation{p_end}
{synopt:{opt replacelong}} Overwrites existing CNEF_long data{p_end}
{synopt:{opt replacesingle}} Overwrites existing single year CNEF data{p_end}
{synopt:{opt longonly}} Do not create single year CNEF data{p_end}

{title:Description of psid install}

{pstd}{cmd:psid install} is used to install the various datasets of
the PSID or the CNEF to the specified directory. While the
installation is fully automatic for the CNEF, some pre-requites must
be met for the PSID. The following first describes the procedure for
PSID.{p_end}

{pstd}{cmd:psid install} without the option {cmd:cnef} creates Stata
datasets of the PSID and stores them into a specified directory. This
sounds somewhat easier than it is, because the PSID data base is
spread into numerous files, which are distributed as ASCII text files
bundled together with batch jobs to create datasets in various
formats. By and large there is one zip-file for each year since 1968,
and some further files of interest. {cmd: psid install}, as it stands,
works for the files downloadable for registered PSID users from the
{browse "http://simba.isr.umich.edu/Zips/ZipMain.aspx":PSID's main interview download site}, and for selected
{browse "http://simba.isr.umich.edu/Zips/zipSupp.aspx":supplemental files}.
Note that researchers need to register on {browse "http://simba.isr.umich.edu/U/ca.aspx":psid.org} to download the zip
files.{p_end}

{p2colset 8 40 41 10}
{p2col: type} filenames {p_end}
{p2line}
{p2col: {it: Main interview data}}{p_end}
{p2col: Family } fam1968.zip, fam1969.zip ... famCCYY.zip{p_end}
{p2col: Cross-year individual } indCCYY.zip{p_end}
{p2col: Parent identification } pidYY.zip{p_end}
{p2col: Marriage history } mh85_YY.zip, and{p_end}
{p2col: Childbirth and adaption history} cah85_YY.zip{p_end}

{p2col: {it: Supplemental files}}{p_end}
{p2col: Wealth} wlth1984.zip, wlth1989.zip, ..., wlth2007.zip{p_end}
{p2line}

{pstd}{bf:Aside but very important:} You need to install the cross year
individual file (indCCYY.dta), to be able to use the other programs of
{cmd: psidtools}{p_end}

{pstd} The idea of {cmd:psid install} is that the user downloads the
zip-files and lets {cmd:psid install} do the rest. For an example
consider a user who downloaded some (or all) PSID zip-files into the
directory "c:/data/downloads". In this case, the command {p_end}

{p 4 4 0}{cmd:. psid install using c:/data/downloads}{p_end}

{pstd}would ... {p_end}

{p 8 10 0}o unpack the downloaded PSID zip-files,{p_end}
{p 8 10 0}o make some necessary edits in the unpacked Stata do-files,{p_end}
{p 8 10 0}o run the do-files that create the Stata datasets,{p_end}
{p 8 10 0}o change the variable labels of the Stata datasets to have the first
  letter capitalized, and all other letters converted to lowercase,{p_end}
{p 8 10 0}o compress the created Stata data sets,{p_end}
{p 8 10 0}o save the Stata file into the current working directory, and{p_end}
{p 8 10 0}o erase all files generated on the fly.{p_end}

{pstd}The usage of the program in the above example is reasonable for
those who wish to install the Stata datasets of the PSID the first
time. However, more experienced users of the PSID can customize the
installation of PSID datasets by specifing a {help numlist:wavelist} of years
that should be installed (see below) and/or by specifying the
directory into which the Stata datasets are installed; see option
{cmd:to()}. It is also possible to downcase the names of the variables
in the Stata datasets using the option {cmd: lower}.{p_end}

{pstd} By default, {cmd:psid install} creates Stata datasets for all
PSID zip-files found in the using directory unless a specific dataset
has been already installed. Datasets that have been already installed
are ignored. Due to this functionality, installing the datasets for a
new data delivery will only install the new files, while leaving the
old files untouched; however see option {opt replace}, below.{p_end}

{pstd}It is also possible to specify a {cmd:wavelist}, i.e, a
{help numlist} of waves to be added. For example, the command
{p_end}

{p 4 4 0}{cmd:. psid install 1974(1)1980 using c:/data/downloads}{p_end}

{pstd} only installs files for the years 1974 to 1980, regardless of
other PSID zip-files in the using directory.{p_end}

{pstd}{cmd:psid install} with the option {cmd:cnef} installs the CNEF
to be accessible for {cmd:psid use} and {cmd:psid add}. Users have to
downlaod a ZIP-file of the CNEF data on
{browse "http://cnef.ehe.osu.edu/cnef-data-files/"}. The downloaded file
must be specified in with {help using}, Thus,{p_end}

{p 4 4 0}{cmd:. psid install using c:/downloads/foo.zip, cnef}{p_end}

{pstd}unpacks the downloaded file zoo.zip, and, installs CNEF file(s) in the
current working directory. {help using} is required with option CNEF. {p_end}

{marker installopt}{...}
{title:Options of psid install}

{phang}{opt to(dirname)} specifies the name of the directory in which
the Stata datasets should be stored. If not specified, the current
working directory will be used; see help {help pwd}. {p_end}

{phang}{opt replace} is used to replace Stata datasets that have been
created by a previous run of the program with newly created
dataset. By default, {cmd:psid install} ignores datasets that have
been created already. If one wishes to update an existing Stata
dataset with, say, a corrected delivery, the option {cmd:replace} must
be used. Option {cmd:replace} with option {cmd:cnef} implies options
{cmd:replacelong} and {cmd:replacesingle}.{p_end}

{phang}{opt l:ower} The "original" PSID data delivery do-files create
upper cased variable names. For Stata users upper cased variable names
are a bit clumsy, so it is reasonable to use the option {cmd:lower} to
downcase the variable names in all generated datasets. However, if the
PSID datasets are accessed through {cmd:psid use} and/or {cmd:psid add}
the usage of this option is not recommended.  Option {cmd:lower}
cannot be used togehter with option {cmd:cnef}{p_end}

{phang}{opt upgrade} can be only used with option {cmd:cnef}. By
default, {cmd:psid install, cnef} does not unpack a newly download zip-file if
if a CNEF delivery is already present in the
installation directory. With option {cmd:upgrade} that delivery 
will be replaced by the newly downloaded one.{p_end}

{phang}{opt longonly} Starting with the data delivery 2009, the CNEF is being delivered in
long format, i.e. the data of all waves are being stored in one single Stata dataset. However,
the PSID-Tools expect data stored in one dataset for each wave. {cmd:psid intall, cnef} thus creates
single year datasets by default. The creation of single year dataset can be turned off with
option {cmd:longonly}.{p_end}

{phang}{opt clean} was used in older versions {cmd:psid install, cnef}. The option is still allowed but
does nothing.
{p_end}

{phang}{opt replacelong} was used in older versions {cmd:psid install, cnef}. The option is still allowed but
does nothing.
{p_end}

{phang}{opt replacesingle} can be only used with option {cmd:cnef}. By
default, {cmd:psid install, cnef} does not create a datasets for a single year, if the
dataset for that year already exists. With option {cmd:replacesingle} existing single year datasets
will be overwritten. Option {cmd:replace} implies {cmd:replacesingle}.{p_end}

{marker use}{...}

{title:Syntax of psid use and psid add}

{p 8 17 2}
   {cmd: psid use || }
   {it: newstub} {it:varspecs}
   {help using}
   [{cmd:,}
   {it:options use_options}
   ]
{p_end}

{p 8 17 2}
   {cmd: psid add || }
   {it: newstub} {it:varspecs}
   [{help using}]
   [{cmd:,}
   {it:options}
   ]
{p_end}

{* the new Stata help format of putting detail before generality}{...}
{synoptset 26 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt do:file(filename, ...)}} Document retrival in a do-file{p_end}
{synopt:{opt f:type(cnef|wealth)}} Access simplified syntax{p_end}
{synopt:{opt k:eepnotes}} Keep notes of orig. varnames{p_end}
{synopt:{opt l:ower}} Varnames of PSID files are lower case{p_end}
{synopt:{opt w:aves(wavelist)}} Waves to be retrived{p_end}

{syntab:Use options}
{synopt:{opt d:esign(designtype)}} Design; default: {cmd:design(balanced)}{p_end}
{synopt:{opt clear}} Replace data in memory{p_end}

{title:Description of psid use and psid add}

{pstd} To load data from the PSID, {cmd:psid use} and {cmd:psid add}
allow the user to copy-paste output of the {browse "http://simba.isr.umich.edu/VS/s.aspx":PSID Data Center}
into Stata. The pasted output will be processed by the commands to
create a Stata dataset that corresponds to the the pasted output.  The
difference between {cmd:psid use} and {cmd:psid add} is that the
former creates a new dataset, while the latter merges variables to a
file already generated with {cmd:psid use}. 
{p_end}

{pstd}The way the commands work is best explained with an
example. Consider you have been using the PSID Data Center to search
the PSID data base for items concerning health. After founding a
candidate that might suit your needs you requested further information
to that that item by clicking on the respective button. This brought
up an extract of the codebook of the item which also lists the years
in which the item is available. This so called {it: item correspondence list}
looks as follows:{p_end}

{p 12 12 0}
  [84]V10877 [85]V11991 [86]V13417 [87]V14513 [88]V15993 [89]V17390 [90]V18721 [91]V20021 [92]V21321 [93]V23180 [94]ER3853 [95]ER6723 [96]ER8969 [97]ER11723 [99]ER15447 [01]ER19612 [03]ER23009 [05]ER26990 [07]ER38202 [09]ER44175 [11]ER49494
{p_end}

{pstd}The item correspondence list shows the variable names of the
selected item in the various waves of the PSID. It resembles the format
of the {it:varspecs}
required by {cmd:psid use} and {cmd:psid add}, and can thus be copied
as is into those commands. Once you did this, you only need to add a
name for the item. This name must be typed behind "||" in front of the
item correspondence list. The {cmd:psid use} command to create a
longitudinal dataset with all variables of the example above will then
become{p_end}

{p 8 8 0}{cmd:. psid use || health}{p_end}
{p 12 12 0}{cmd:[84]V10877 [85]V11991 [86]V13417 [87]V14513 [88]V15993 [89]V17390 [90]V18721 [91]V20021 [92]V21321 [93]V23180 [94]ER3853 [95]ER6723 [96]ER8969 [97]ER11723 [99]ER15447 [01]ER19612 [03]ER23009 [05]ER26990[07]ER38202 [09]ER44175}
{cmd: [11]ER49494}{p_end}
{p 10 10 0}{cmd:using ~/data/psid}{p_end}

{pstd} whereby the variables will be renamed to {it:health1984, health1984 ... health2011}.{p_end}

{pstd}{bf:Aside but very important:} You must have installed the cross year
individual file (indCCYY.dta), to be able apply {cmd:psid use}{p_end}

{pstd}In general, the programs {cmd:psid use} and {cmd:psid add}
create datasets with all the variables identified by the {it:varspecs}
renamed to names using a {it:newstub-year} convention. Several item
correspondence lists can be specified in one command, and the default
"balanced" panel design can be changed to various other designs; see
option {opt d:esign()}.  A simplified syntax for
variables from the Wealth files and the Cross National Equivalence
files is also available (see {help psid##simplifies:below}).{p_end}

{pstd} {cmd:psid use} and {cmd: psid add} work for item correspondence
lists that contain variables from the following files: 

{p2colset 8 45 47 10}
{p2col: type} filenames {p_end}
{p2line}
{p2col: {it: Main interview data}}{p_end}
{p2col: Family}fam1968.dta, fam1969.dta ... famCCYY.dta{p_end}
{p2col: Cross-year individual}indCCYY.dta{p_end}
{p2col: Parent identification}pidYY.dta{p_end}
{p2col: Marriage history}mh85_YY.dta, and{p_end}
{p2col: Childbirth and adaption history}cah85_YY.dta{p_end}

{p2col: {it: Supplemental files}}{p_end}
{p2col: Wealth}wlth1984.dta, wlth1989.dta, ..., wlth2007.dta{p_end}
{p2col: Cross National Equivalence (CNEF)}pequiv1968.dta, pequiv1969.dta, ..., pequivCCYY.dta{p_end}
{p2line}

{pstd} While this file list resembles the file list that can be
installed with {help psid##install:psid install} it is not required
that {cmd:psid install} has been actually used to install the
files. It is however necessary that the installed files follow the
file naming conventions shown above. It is also necessary that all
files (except the CNEF-files) are stored in the same directory,
i.e. the PSID directory. These requirements will be met automatically if
the PSID is installed with {cmd:psid install}.  {p_end}

{pstd}Note that the Stata datasets for
the CNEF can be downloaded directly from the  {browse "http://www.human.cornell.edu/che/PAM/Research/Centers-Programs/German-Panel/cnef.cfm":CNEF website}. It is thus  neither necessary nor possible to install these files with {cmd:psid install}. 
Moreover, as the CNEF is not part of the "official" PSID, the CNEF
variables are not listed in the PSID Data Center. In order to access the CNEF variables {cmd:psid use} and {cmd:psid add} offer a simplified syntax, which will
be described {help psid##simplified:below}. As a consequence of the simplified
syntax it is however not allowed to list both, CNEF and PSID variables in one single
command. Instead, one should first {cmd:psid use} the PSID variables and
then {cmd:psid add}ing the CNEF variables, or the other way around.{p_end}

{pstd}Finally note the following peculiarities of 
{it:varspecs}:{p_end}

{p 6 8 8 0}o you must add a set of empty brackets in front of items
that appear only once in the database (i.e. variables that are
constant over time). This is always the case for variables of the
parent identification file, the childhood and adaption history file,
and the marriage history file, but also for some variables of the
cross year individual file. {p_end}

{p 6 8 8 0}o you must not specify any person of family identifiers in
the {it:varspecs}. These identifiers are retained automatically and
renamed using the convention of the CNEF. The renamed identifiers are
always the first variables of the created dataset.  {p_end}

{marker simplified}{...}
{title:Simplified Syntax (CNEF and Wealth files)}

{pstd} {cmd:psid use} and {cmd:psid add} require the user to specify
variables of the PSID database in the format of the output of the PSID
Data Center. This is fine for variables that are listed in the PSID
Data Center, but awfully complicated for variables not listed there
and unnecessary in case of file types with a harmonized variable
naming convention. {cmd:psid use} and {cmd:psid add} therefore offers a
simplified syntax for the CNEF files and the Wealth files. The
simplified syntax is mandatory for loading CNEF variables. 

{p 8 17 2}
   {cmd: psid use || }
   {it: newstub} {it:varstub}
   {help using}
   {cmd:,} {opt f:type(cnef|wlth)} {opt w:aves(numlist)}
   [{it:options use_options}
   ]
{p_end}

{p 8 17 2}
   {cmd: psid add || }
   {it: newstub} {it:varstub}
   [{help using}]
   {cmd:,} {opt f:type(cnef|wlth)} {opt w:aves(numlist)}
   [ {it:options use_options}
   ]
{p_end}

{pstd} The meanings of all terms are equal to the standard syntax. The
difference to the standard syntax is the use of {it: varstub} instead
of {it: varspecs}. In order to access the simplified syntax, the
specification of {opt f:type()} and {opt w:aves()} is required, which
implies that the standard and simplified syntax cannot be mixed in one
command.{p_end}

{pstd} The {it:varstub} is the part of the variable name that is
identical in all files of the CNEF and Wealth files, respectively. For
the CNEF the {it:varstub}s are the first 6 characters of the variable
names, i.e. the variable names without the year.  For the Wealth files
the {it:varstub}s are the variable names without the first two digits,
i.e. the variable names with out the "S" and the number that
identifies the round of the data delivery. {p_end}

{pstd} The description of the simplified syntax sounds a bit more
complicated than it actually is. For example, to load the pre- and
post government incomes of all waves of the CNEF from, say, 1984 to 2007 one
would use{p_end}

{p 8 8 0}{cmd:. psid use || pre i11102 || post i11104 using ~/data/cnef, ftype(cnef) waves(1984/2007)}{p_end}

{pstd}Likewise, to load the imputed and actual value of vehicles of
all wealth files available between 1984 and 2007 one would use{p_end}

{p 8 8 0}{cmd:. psid use || impvehic 13 || impvehicA 13A using ~/data/PSID, ftype(wlth) waves(1984/2007)}{p_end}

{pstd}In order to extend or shorten the observation period one only
needs to change option {opt w:ave()}, whereby the missing years of
data collection are handled automatically.
{p_end}

{marker useopt}{...}
{title:Options for psid use/add}

{phang}{opt do:file(filename [, replace|append force])} specifies the
{help filename} of a do-file that documents the retrival. This can be
helpful if you wish to sent your retrival to colleagues that do not
want to install this command, or to change settings that could not be
changed with the syntax of {cmd:psid use} and {cmd:psid add}. The
sub-options {cmd:replace} and {cmd:append} have the usual meaning,
i.e. the former overwrites an existing file and the latter appends
content to an existing file. The sub-option {cmd:replace} is
considered as pointless for {cmd:psid add} and therefore only possible
if specified with {cmd:force}.  {p_end}

{phang}{opt f:type(cnef|wealth)} is used to access variables from the
Cross National Equivalence Files or the Wealth files using the
simplified syntax described {help psid##simplified:above}. Option
{opt w:ave()} is mandatory if {opt f:type()} is specified. {p_end}

{phang}{opt k:eepnotes} helps to keep track of the original variable
names. {cmd:psid use} and {cmd:psid add} automatically rename all
variables using the {it:newstub-year} convention. While this renaming
substantially eases the data management of the generated file, it
makes it harder to look up the underlying questions in the
questionnaire or other details in the PSID Data Center. With the option
{opt k:eepnotes} the original variable name is stored as
characteristic of the renamed variable and can be thus looked up with
{cmd:char list}; see help {help char}.
The specification of this option is also a pre-requisite for using {help psid##vardoc:psid vardoc}.
 {p_end}

{phang}{opt l:ower} The "original" PSID data delivery do-files create
upper cased variable names. For Stata users, upper cased variable names
are a bit clumsy, so that the files might have been stored with all
variable names changed to lower case. {cmd:psid use} and
{cmd:psid add} expects variable names to be upper cased, but this can be
changed using the option {opt l:ower}. If {cmd:psid install} have been used
with option {opt lower}, you must specify the option for {cmd:psid use} and {cmd:psid add}, too. {p_end}

{phang}{opt w:aves(numlist)} is used to specify a {help numlist} for
the waves from which variables should be retrieved. The option is mandatory
if the {help psid##simplified:simplified syntax} is requested through
{opt f:type()}. For the standard syntax the
waves are implied by the {it:varspecs}, and any settings of
{opt w:aves()} will be therefore ignored.{p_end}

{title:Options for psid use}

{phang}{cmd:design(designtype)} specifies the design of the panel data
to be created. {cmd:design(balanced)} is used to create a balanced
panel design, i.e. the data will contain only observations interviewed
in all requested waves. {cmd:design(any)} will keep all available
observations in the data set. {cmd:design(#)} with # being an integer
positive number creates data sets with households interviewed # times
or more. {p_end}

{pmore} It is important to understand the design of the files created
by {cmd:psid use}. The program always creates a design that uses
individual records. That is to say that the file being created has
observations for each head of the household and observations for the
partners of the heads of the household. An observation is counted as
being interviewed in as specific wave if the "sequence number" of that
wave is either between 1 and 20 or between 81 and 89. The sequence
variable is retained in the dataset in order to allow further
fine-tuning of the design.{p_end}

{pmore} It is also important to understand that the longitudinal design of a retrival is fixed by {cmd:psid use}. It is possible to add further waves to an existing dataset with {cmd:psid add} but this will not delete or add any observations to the dataset. It is thus not recommended to use {cmd:psid add} for adding variables of further waves to a dataset. Instead those requested variables should be listed among the {it:varspecs} of {cmd:psid use} already.{p_end}

{pmore} The numbers of observation of the dataset created by
{cmd:psid use} changes only if a user {cmd:psid add}s variables from one of the
three history files to a file that did not contain variable of any of
those files so far. This is because the history files are actually spell data, so that the unit of analysis changes from individuals to spells.{p_end} 

{phang}{cmd:clear} specifies that it is okay to replace the data in
memory, even though the current data have not been saved to disk.
{p_end}


{marker long}{...}
{title:Syntax of psid long}

{p 8 17 2}
   {cmd:psid long} 
{p_end}

{title:Description of psid long}

{pstd}{cmd:psid long} reshapes a dataset created by
{cmd:psid use}/{cmd:psid add} into the long data format
(see help {help reshape}).
However, unlike standard reshape, variable labels of time
varying variables do not get lost. {cmd:psid long} also automatically creates
the varname stubs requested by reshape. Finally, it is neither necessary,
nor possible to specify any of the options requested by reshape.
{cmd:psid long} provides all necessary settings as defaults.{p_end}

{pstd}{cmd:psid long} selects the first variable label of an item
correspondance list as the variable label in the long data
set. Moreover it uses the individual identifier for the option
{cmd:i()} of reshape and {cmd:wave} as the variable name for the
PSID's time dimension. Finally it stores the item correspondance list
of as a characteristic in the dataset, if these information has been
retained by the option {cmd:keepnotes} of {cmd:psid use} and/or
{cmd:psid add}.

{pstd}{cmd:psid long} is a convenience program which relives the PSID user
to think about the reshape process. It thus makes certain settings and
does not allow the user to change them. Users who want more flexibility
are requested to use {help reshape} instead.{p_end}

{marker vardoc}{...}
{title:Syntax of psid vardoc}

{p 8 17 2}
   {cmd:psid vardoc} 
    {help varname} 
   [ {cmd:, }
     {it:vardoc_options}  
   ]
{p_end}

{syntab:Vardoc options}
{synopt:{opt add:valuelabel(lblname)}} Retrieve value labels from the Internet{p_end}
{synopt:{opt s:how}} Show description in presence of option addvaluelabel{p_end}
{synoptline}
{p2colreset}{...}

{title:Description of psid vardoc}

{pstd}{cmd:psid vardoc} displays the official variable description of
the PSID Data Center in a browser window. The command is invoked by
specifying the name of the variable for which the discription should
be displayed.  The command only works for datasets created
with {cmd:psid use}/{cmd:psid add} and the option {cmd:keepnotes}. The
command can be used in long datasets only if the long dataset was
created with {cmd:psid long}. {p_end}

{pstd}Note that the command loads the variable description from the
Internet. The command therefore only works if it is invoked on a
computer with connection to the Internet.{p_end}

{title:Options for psid vardoc}

{phang}{cmd:addvaluelabel(lblname)} retrieves the value label
definition of a variable from the official description of the PSID
Data Center. This is helpful because PSID data is being delivered
without value labels. The option {cmd:addvaluelabel(lblname)} of
{cmd:psid vardoc varname} defines the value label
{cmd:lblname} according to the information found in the PSID data
center and attaches this value label to {cmd:varname}.{p_end}

{phang}{cmd:show} The PSID Data Centers variable description will not
being displayed in a Browser-Window if option {cmd:addvaluelabel} is
present. The option {cmd:show} overwrites this behavior. {p_end}

{marker examples}{...}
{title:Examples}{* Be sure to change Example(s) to either Example or Examples}

{pstd}Create Stata dataset from zip file in the directory
"~/Downloaded" and store them into the directory "~/data/PSID":{p_end}

{phang2}{cmd:. psid install using "~/Downloaded", to("~/data/PSID")}{p_end}

{pstd}Add the wave 1985 to already installed PSID data.{p_end}

{phang2}{cmd:. psid install 1985 using "~/Downloaded", to("~/data/PSID")}{p_end}

{pstd}Create a longitudinal file with health status of the household head{p_end}
{phang2}{cmd:. psid use || health [84]V10877 [85]V11991 [86]V13417 using ~/data/PSID}{p_end}

{pstd}Constructing Longitudinal Records of the CNEF 1980-2007 {p_end}
{phang2}{cmd:. psid use || pregov i11101 || postgov i11102 using ~/data/PSID/cnef07, ftype(cnef) waves(1980/2007)}{p_end}

{pstd}Include a variable that is constant across waves{p_end}
{phang2}{cmd:. psid use || health [84]V10877 || age [84]ER30432 || deathyr []ER32050 using ~/data/PSID}}{p_end}

{pstd}A more practical example for a longitudinal data set with several items from the PSID and the CNEF.
{p_end}

{p 4 4 0}{cmd:. psid use}{p_end}
{p 8 4 0}{cmd:|| shealth [84]V10877 [85]V11991 [86]V13417 [87]V14513} {p_end}
{p 8 4 0}{cmd:[88]V15993 [89]V17390 [90]V18721 [91]V20021 [92]V21321} {p_end}
{p 8 4 0}{cmd:[93]V23180 [94]ER3853 [95]ER6723 [96]ER8969 [97]ER11723} {p_end}
{p 8 4 0}{cmd:[99]ER15447 [01]ER19612 [03]ER23009 [05]ER26990} {p_end}
{p 8 4 0}{cmd:|| age [68]ER30004 [69]ER30023 [70]ER30046 [71]ER30070} {p_end}
{p 8 4 0}{cmd:[72]ER30094 [73]ER30120 [74]ER30141 [75]ER30163 [76]ER30191} {p_end}
{p 8 4 0}{cmd:[77]ER30220 [78]ER30249 [79]ER30286 [80]ER30316 [81]ER30346} {p_end}
{p 8 4 0}{cmd:[82]ER30376 [83]ER30402 [84]ER30432 [85]ER30466 [86]ER30501} {p_end}
{p 8 4 0}{cmd:[87]ER30538 [88]ER30573 [89]ER30609 [90]ER30645 [91]ER30692} {p_end}
{p 8 4 0}{cmd:[92]ER30736 [93]ER30809 [94]ER33104 [95]ER33204 [96]ER33304} {p_end}
{p 8 4 0}{cmd:[97]ER33404 [99]ER33504 [01]ER33604 [03]ER33704 [05]ER33804} {p_end}
{p 8 4 0}{cmd:|| disable [72]V2718 [73]V3244 [74]V3666 [75]V4145 [76]V4625} {p_end}
{p 8 4 0}{cmd:[77]V5560 [78]V6102 [79]V6710 [80]V7343 [81]V7974 [82]V8616} {p_end}
{p 8 4 0}{cmd:[83]V9290 [84]V10879 [85]V11993 [86]V13427 [87]V14515} {p_end}
{p 8 4 0}{cmd:[88]V15994 [89]V17391 [90]V18722 [91]V20022 [92]V21322} {p_end}
{p 8 4 0}{cmd:[93]V23181 [94]ER3854 [95]ER6724 [96]ER8970 [97]ER11724} {p_end}
{p 8 4 0}{cmd:[99]ER15449 [01]ER19614 [03]ER23014 [05]ER26995} {p_end}
{p 8 4 0}{cmd:using ~/data/PSID} , clear design(10)}{p_end}
{p 4 4 0}{cmd:. psid add || pregov i11101 || postgov i11102, cnef(~/data/PSID/cnef07)}{p_end}

{pstd}Make the data of the previous retrival long{p_end}

{phang2}{cmd:. psid long}{p_end}

{pstd}Label the variable disable from the last retrival with a value label defined according to the variable descritpion of the PSID Data Center. {p_end}

{phang2}{cmd:. psid vardoc disable, addvaluelabel(yesno)}{p_end}

{marker acknowledgments}{...}
{title:Acknowledgements}

{pstd}I whish to thank the PSID Management Team for allowing me to use
the name {cmd:psid} for the program. Jan Paul Heisig, Martin Ehlert
and Anke Radenacker, my former colleagues at the Social Science
Research Center (WZB) have thoroughly tested a previous version of
this command. I owe them much. David Brady (WZB) encouraged me --
without even knowing -- to transform {cmd:psiduse} to {cmd:psid use}.
Josephine Matysiak, Adrian Rolf (University of Potsdam) and Lai
Xiongchuan (National University Singapore) volunteered as pre-alpha,
alpha, and beta tester. John Haisken-DeNew (Melbourne Institue of
Applied Economic and Social Research) gave me a first version of the
code for the do-file option. Thanks a lot to all of them.

{marker author}{...}
{title:Author}

{pstd}Ulrich Kohler, University of Potsdam, Germany{p_end}
{pstd}email: {browse "mailto:ukohler@uni-potsdam.de":ukohler@uni-potsdam.de}{p_end}

