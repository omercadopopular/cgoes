{smcl}
{* September 13, 2014 @ 12:11:14}{...}
{hi:help psid} {hi:help psiduse}, {hi:help psidadd}
{hline}

{title:Disclaimer}

{pstd} This program is superseded by {help psid}. It is no longer
maintained and only delivered to allow replication of older
projects. Please use {help psid} If you start a new project. The new program
provides all facilities of psiduse and offers more.
{p_end}  


{title:Title}

{phang}
 Makes retrievals from PSID real easy
{p_end}

{title:Syntax}
{phang2}
   {cmd:psiduse }
   || {it: new_stub} {it:varname identifers} 
   {cmd:[}
   || {it: new_stub} {it:varname identifers}
   {cmd:]}
   {cmd: using} {it:dirname}
   {cmd:[}
   {cmd:, }
   {it:use_options}  
   {cmd:]}

{phang2}
   {cmd:psidadd }
   || {it: new_stub} {it:varname identifers} 
   {cmd:[}
   || {it: new_stub} {it:varname identifers}
   {cmd:]}
   {cmd:[}
   {cmd:, }
   {it:add_options}  
   {cmd:]}

{pstd} {it:dirname} is the name of the directory in which the PSID
files are stored. The term {it: varname identifier} refers to PSID
variables. You cannot specify the PSID variable names in terms of a
{help varlist} but have to use the syntax specified below.  Finally
{it: new_stub} is the prefix of new names for variables that belong
together. 

{synoptset 24 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:use_options}
{synopt:{opt d:esign(designtype)}} Design; default: {cmd:design(balanced)}{p_end}
{synopt:{opt cnef(numlist)}} Waves to be used for CNEF data {p_end}
{synopt:{opt clear}} Replace data in memory{p_end}
{synopt:{opt correct}} Correct inconsistent 2005/2007 data delivery{p_end}


{syntab:add_options}
{synopt:{opt cnef:from(path)}} Path to CNEF data{p_end}
{synopt:{opt psid:from(path)}} Path to PSID data{p_end}
{synopt:{opt correct}} Correct inconsistent 2005/2007 data delivery{p_end}
{synoptline}
{p2colreset}{...}

{title:Description}

{pstd} {cmd:psiduse} and {cmd:psidadd} perform data retrievals from the
Panel Study of Income Dynamics (PSID) and for the American part of the
Cross National Equivalence File (CNEF). The programs are companions
of {cmd:soepuse} and {cmd:soepadd} which provide a similar
functionality for the German Socio Economic Panel. {p_end}

{pstd}The programs create PSID data sets holding the variables
identified by the {it:variable identifiers} with names prefixed by
{it:new_stub}. {cmd:psiduse} generates a new file and
{cmd:psidadd} merges further variables to a file generated with
{cmd:psiduse}.  By default, the created files will have a balanced
panel design, but various other designs could be specified.{p_end}

{pstd} To load data from the PSID, {cmd:psiduse} and {cmd:psidadd}
require that the variables are specified very similar to the variable listing
produced by the {browse "http://simba.isr.umich.edu/VS/s.aspx":PSID Data Center}.
Here is an example: To create a longitudinal file with
individual ages and subjective health evaluations of the household head
of waves 1991 and 1992 you would specify {p_end}

{phang2}{cmd:. psiduse || age [91]ER30692 [92]ER30736 || shealth  [91]V20021 [92]V21321 using ~/data/psid05}{p_end}

{pstd} or in a format that highlights better the requested format of
the variable identifiers:
{p_end}

{p 8 8 0}{cmd:. psiduse }{p_end}
{p 12 12 0}{cmd:|| age [91]ER30692 [92]ER30736  }{p_end}
{p 12 12 0}{cmd:|| shealth [91]V20021 [92]V21321 }{p_end}
{p 10 10 0}{cmd:using ~/data/psid05}{p_end}

{pstd} This command will produce a longitudinal data set in a balanced
panel design with variable names "age1991" and "age1992" for the age
variables, and "shealth1991" and "shealth1992" for the health
evaluations. The new data set will also contain person and housholds
identifiers using the name conventions of the {browse "http://www.human.cornell.edu/che/PAM/Research/Centers-Programs/German-Panel/cnef.cfm":Cross National Equivalence File}.

{pstd}{cmd:psiduse} and {cmd:psidadd} are constructed for using them
in connection with the
{browse "http://simba.isr.umich.edu/VS/s.aspx":PSID Data Center}.  Consider
you have been using the PSID Data Center to search the PSID data base
for items concerning health. After founding an item that suits your needs
you have clicked on that item which brought up an item correspondence
list that looks like this {p_end}

    [84]V10877 [85]V11991 [86]V13417 [87]V14513 [88]V15993	
   	[89]V17390 [90]V18721 [91]V20021 [92]V21321 [93]V23180	
   	[94]ER3853 [95]ER6723 [96]ER8969 [97]ER11723 [99]ER15447	
   	[01]ER19612 [03]ER23009 [05]ER26990                      

{pstd}This list almost completely resembles the format of the variable
identifiers to be used in {cmd:psiduse}. It can be therefore copied
into the command. Once you did this, you only need to add a name for
the item. This name will be used as a prefix for all variable names
created for that item in the new data set.

{pstd}The entire {cmd:psiduse} command to load all variables of
the example above will then become{p_end}

{p 8 8 0}{cmd:. psiduse }{p_end}
{p 12 12 0}{cmd:|| health [84]V10877 [85]V11991 [86]V13417 [87]V14513 [88]V15993	}{p_end}
{p 12 12 0}{cmd:[89]V17390 [90]V18721 [91]V20021 [92]V21321 [93]V23180	}{p_end}
{p 12 12 0}{cmd:[94]ER3853 [95]ER6723 [96]ER8969 [97]ER11723 [99]ER15447}{p_end}
{p 12 12 0}{cmd:[01]ER19612 [03]ER23009 [05]ER26990                    }{p_end}
{p 10 10 0}{cmd:using ~/data/psid05}{p_end}

{pstd} To load data from the CNEF, {cmd:psiduse} and {cmd:psidadd}
require that the prefixes of variable names are listed as variable
identifier, and that the option {cmd:cnef()} is specified. To load,
for example, the pre- and post government incomes of waves 1980 to
1990 one would use{p_end}

{p 8 8 0}{cmd:. psiduse || pre i11102 || post i11104 using ~/data/cnef, cnef(1980/1990)}{p_end}

{pstd}Note that you cannot load CNEF variables and PSID variables with
the same command. Either you use {cmd:psiduse} to load the CNEF
variables and use {cmd:psidadd} to add variables from the PSID, or you
do it the other way around.{p_end}

{pstd}Note also that you must not add variables from waves that are
not already included in the file created by {cmd:psiduse}. If you use
{cmd:psidadd} for adding CNEF data to an existing PSID data file, all
waves that are included in the existing file are retained
automatically.{p_end}

{pstd}Finnaly note that you must add a set of empty brackets in front
of items that appear only once in the database (i.e. constants).
{p_end}


{title:Options}

{phang}{cmd:design(designtype)} specifies the design of the panel data
to be created. {cmd:design(balanced)} is used to create a balanced
panel design, i.e. the data will contain only observations interviewed
in all requested waves. {cmd:design(any)} will keep all available
observations in the data set. {cmd:design(#)} with # being an integer
positive number creates data sets with households interviewed # times
or more.  {p_end}

{phang}{cmd:clear} specifies that it is okay to replace the data in
memory, even though the current data have not been saved to disk.
{p_end}

{phang}{cmd:cnef(numlist)} must be used to load data from the American part of the 
{browse "http://www.human.cornell.edu/che/PAM/Research/Centers-Programs/German-Panel/cnef.cfm":Cross National Equivalence File} (CNEF). 
Specify the waves for which data should be retained inside the parentheses.
The CNEF uses a standardized scheme for variable names which allows
a simplified syntax for the specification of variable identifiers. The
CNEF option lets you access this simplified syntax.
 {p_end}

{phang}{cmd:cneffrom(path)} By default {cmd:psidadd} assumes that the
data is stored in the directory specified by {cmd:psiduse}. If you
want to add CNEF variables to a PSID data set you must specify the path
to the CNEF data. You have to specify {cmd:cneffrom()} even if the
CNEF data is stored in the PSID directory.  {p_end}

{phang}{cmd:psidfrom(path)} By default {cmd:psidadd} assumes that the
data is stored in the directory specified by {cmd:psiduse}. If you
want to add PSID variables to a CNEF data set you must specify the
path to the PSID data. You have to specify {cmd:psidfrom()} even if the
PSID data is stored in the CNEF directory. {p_end}

{phang}{cmd:correct} An early version of the CNEF delivery for 2007
introduced upper cased "LL" in the variable names of three variables
in the files for years 2005 and 2007. Moreover, the data file of 2005
contained 9 dublicate observations. Option correct changes "LL" to
"ll" and removes the dublicates. I hope that this option becomes
superfluos with updated data deliveries. {p_end}

{title:Example(s)}

{pstd}Constructing Longitudinal Family Records (PSID) {p_end}
{phang2}{cmd:. psiduse || health [84]V10877 [85]V11991 [86]V13417 using . }{p_end}

{pstd}Constructing Longitudinal Records (CNEF 1984-2005) {p_end}
{phang2}{cmd:. psiduse || pregov i11101 || postgov i11102 using . , cnef(1980(1)1995 1997(2)2005)}{p_end}

{pstd}Linking Family and Individual Data (PSID) {p_end}
{phang2}{cmd:. psiduse || health [84]V10877 || age [84]ER30432 using .}{p_end}

{pstd}A more practical example for a longitudinal data set with several items (PSID and CNEF)
{p_end}

{p 4 4 0}{cmd:. psiduse}{p_end}
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
{p 8 4 0}{cmd:using . , clear design(10)}{p_end}
{p 4 4 0}{cmd:. psidadd || pregov i11101 || postgov i11102, cnef(~/data/cnef)}{p_end}

{title:Note}

{pstd}{cmd:psiduse} and {cmd:psidadd} are two little unambitious
helper programs. A far more advanced Stata program for working with
large panel data sets is {browse "http://www.panelwhiz.eu":PanelWhiz}
by John Haisken DeNew.  {p_end}


{title:Author}

{pstd}Ulrich Kohler, WZB, kohler@wzb.eu{p_end}

{title:Also see}

{psee} Online: {help soepuse} (if installed), {help rgroup} (if
installed) {p_end}

