{smcl}
{* 13Jan2014}{...}
{* Program written by Alberto A. Gaggero alberto.gaggero@unipv.it}
{hi:help csvconvert}
{hline}

{title:Title}

{p2colset 5 20 22 2}{...}
{p 8 16 2}
{cmd:csvconvert} {hline 1} module for gathering multiple comma-separated values (.csv) files into one single Stata (.dta) dataset.{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 16 2}
{opt csvconvert}
{it:input_directory}
{cmd:,} {cmd:replace} [{it:options}]

{p 8 16 2}
Note: all .csv files must be placed in the same directory;
{it:input_directory} is the directory where the .csv files must be stored.


{synoptset 31 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt replace}} overwrites the existing output file (if it already exists). 
This option is mandatory and must be specified in order to complete the conversion process.{p_end}
{synopt :{opt output_file(file_name)}}{it:file_name} is the name of the .dta file; default is "output.dta".{p_end}
{synopt :{opt output_dir(output_directory)}}{it:output_directory} is the directory where the output file is saved; default is {it:input_directory}.{p_end}
{synopt :{opt input_file(.csv file list)}}names of the .csv files placed in {it:input_directory} to be converted;
you must specify the extension .csv for each file name included in the list (see examples below). 
If this option is not specified, csvconvert takes into the process all the .csv files stored in {it:input_directory}.{p_end}
{synoptline}
{pstd}Double quotes must NOT be used to enclose {it:input_directory} nor {it:output_directory}, even if the directory path contains spaces.


{title:Description}

{p 8 8 2}
{cmd:csvconvert} appends a set of .csv files into one single file, 
which is saved in the .dta format, immediately readable into Stata.
{break}
This command suits the case in which the researcher holds multiple data files 
differing by - for example - a period variable, typically year.

{p 8 8 2}
By default, {cmd:csvconvert} creates a new variable, _csvfile, containing the name of the .csv file from which the observation originates. {break}
At the end of the process {cmd:csvconvert} displays a message with the number of the original .csv files that have been included in the .dta file. 
{break} 
(this information can become useful to double check that all the .csv files have been converted into the .dta file).

{p 8 8 2}
Once the process has been completed, type {cmd:note} to read the full list of .csv files included in the .dta file.

{title:Examples}

{pstd}Download the trail sample from {browse "https://sites.google.com/site/albertogaggero/research/software":my webpage} 
and store it in a directory you created - for example C:\Data\worldbank.

{pstd}Display the list of .csv files contained in the directory {p_end}
{phang2}{cmd:. dir C:\Data\worldbank\*.csv}

{pstd}The following command creates the file output.dta and saves it in the directory C:\Data\worldbank {p_end}
{phang2}{cmd:. csvconvert C:\Data\worldbank, replace}

{pstd}Display the full list of .csv files that have been converted and that are contained in output.dta {p_end}
{phang2}{cmd:. note}

{pstd}The following command creates the file wb_data.dta and saves it in the directory C:\Data\wb dataset{p_end}
{phang2}{cmd:. csvconvert C:\Data\worldbank, replace output_file(wb_data.dta) output_dir(C:\Data\wb dataset)}

{pstd}The following command includes in output.dta only the selected .csv files wb2008.csv and wb2009.csv{p_end}
{phang2}{cmd:. csvconvert C:\Data\worldbank, replace input_file(wb2008.csv wb2009.csv)}

{pstd} Similar to the commands above: the files wb2008.csv and wb2009.csv are contained in wb_data.dta, which is saved in C:\Data\wb dataset{p_end}
{phang2}{cmd:. csvconvert C:\Data\worldbank, replace input_file(wb2008.csv wb2009.csv) output_file(wb_data.dta) output_dir(C:\Data\wb dataset)}

{title:Reference}

{pstd}Gaggero A. (2014) {browse "http://www.stata-journal.com/article.html?article=dm0076":csvconvert: A simple command to gather comma-separated value files into Stata}, Stata Journal, Vol. 14(3), pp. 662-669.

{title:Author}

	Alberto A. Gaggero, University of Pavia, Italy
	alberto.gaggero@unipv.it

{title:Also see}

{psee}
Manual:  {manlink D append}, {manlink D insheet}

{psee}
{space 2}Help:  {manhelp append D: append}, {manhelp insheet D: insheet}
{p_end}

