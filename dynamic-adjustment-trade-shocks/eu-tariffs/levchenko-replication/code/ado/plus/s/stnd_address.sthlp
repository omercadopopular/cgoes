{smcl}
{* 13 August 2014}{...}
{cmd:help stnd_address}{right: ({browse "http://www.stata-journal.com/article.html?article=dm0082":SJ15-3: dm0082})}
{hline}

{title:Title}

{p2colset 5 21 23 2}{...}
{p2col:{cmd:stnd_address} {hline 2}}Standardize and parse a string variable containing a street address
{p2colreset}{...}


{title:Syntax}

{p 8 20 2} 
{cmdab:stnd_address} {it:varname} {ifin}{cmd:,} {cmdab:g:en(}{it:newvarnames}{cmd:)} [{cmdab:p:atpath(}{it:directory_of_pattern_files}{cmd:)}]{p_end}


{title:Description}

{pstd}
{cmd:stnd_address} standardizes and parses a string variable specified as a
street address into five components.  The {cmd:gen()} option is required.  The
generated outputs are in the following order: 1) street number and street; 2)
PO Box; 3) unit, apartment, or suite number; 4) building information; and 5)
floor or level information.  If a given input cannot be parsed, the original
value is recorded in the first field.{p_end}

{pstd}
{cmd:stnd_address} relies on several subcommands and ancillary rule-based
pattern files being installed.  The default directory of the pattern files is
{cmd:ado/plus/p/}.  If the pattern files are installed in a different
directory, the user must specify the directory in the {cmd:patpath()}
option.{p_end}


{title:Options}

{phang}
{opt gen(newvarnames)} generates five variables corresponding to components of
{it:varname}.  {cmd:gen()} is required.

{phang}
{opt patpath(directory_of_pattern_files)} specifies the directory of the
pattern files.


{title:Options for advanced users}

{pstd}
{cmd:stnd_address} is constructed from the following commands and their
associated pattern files.  Users may use their own pattern files by
setting {bf:patpath()} to the directory where alternative pattern files
are located.  See help for each subcommand.{p_end}

{synoptset 21}{...}
{p2coldent :Command}Description{p_end}
{synoptline}
{synopt :{helpb stnd_specialchar}}standardizes special characters{p_end}
{synopt :{helpb stnd_streettype}}standardizes street types{p_end}
{synopt :{helpb stnd_commonwrd_all}}standardizes words commonly appearing in company names and addresses{p_end}
{synopt :{helpb stnd_nesw}}standardizes directional words{p_end}
{synopt :{helpb stnd_numbers}}standardizes numerals and their number equivalent{p_end}
{synopt :{helpb parsing_pobox}}parses PO Box information from other information{p_end}
{synopt :{helpb stnd_secondaryadd}}standardizes secondary address information{p_end}
{synopt :{helpb parsing_add_secondary}}parses secondary address information{p_end}
{synopt :{helpb stnd_smallwords}}standardizes small words (for example, conjunctions){p_end}
{synoptline}


{title:Example}

{pstd}The string variable {cmd:streetadd} contains the address variable we wish to standardize.{p_end}

      {cmd:. list streetadd}
      {txt}
           {c TLC}{hline 33}{c TRC}
           {c |} {res}                      streetadd {txt}{c |}
           {c LT}{hline 33}{c RT}
        1. {txt}{c |}               1722 ROUTH STREET {txt}{c |}
        2. {txt}{c |}                 P.O. BOX 132160 {txt}{c |}
        3. {txt}{c |}   9601 SOUTH MERIDIAN BOULEVARD {txt}{c |}
        4. {txt}{c |}   11525 N. COMMUNITY HOUSE ROAD {txt}{c |}
        5. {txt}{c |}   1100 ABERNATHY RD NE STE 1400 {txt}{c |}
           {c LT}{hline 33}{c RT}
        6. {txt}{c |} 2401 UTAH AVENUE SO., 8TH FLOOR {txt}{c |}
        7. {txt}{c |}                    1014 VINE ST {txt}{c |}
        8. {txt}{c |}               508 SW 8TH STREET {txt}{c |}
        9. {txt}{c |}               3333 BEVERLY ROAD {txt}{c |}
       10. {txt}{c |}              11 BRIDGEWAY PLAZA {txt}{c |}
           {c LT}{hline 33}{c RT}
       11. {txt}{c |}     270 PARK AVENUE, SUITE 1503 {txt}{c |}
       12. {txt}{c |}               18 W. JIMMIE ROAD {txt}{c |}
       13. {txt}{c |}                     PO BOX 2706 {txt}{c |}
       14. {txt}{c |}                         POB 345 {txt}{c |}
           {c BLC}{hline 33}{c BRC}
	 
   {txt}Standardize street address and create five new components
      {cmd:. stnd_address streetadd, gen("add1 pobox unit bldg floor")}
   {txt}
      {cmd:. list add1-floor}
   {txt}
           {c TLC}{hline 25}{c -}{hline 15}{c -}{hline 10}{c -}{hline 6}{c -}{hline 7}{c TRC}
           {c |} {res}                      add1        pobox       unit   bldg   floor {txt}{c |}
           {c LT}{hline 25}{c -}{hline 15}{c -}{hline 10}{c -}{hline 6}{c -}{hline 7}{c RT}
        1. {txt}{c |}              1722 ROUTH ST                                        {txt}{c |}
        2. {txt}{c |}                              BOX 132160                           {txt}{c |}
        3. {txt}{c |}       9601 S MERIDIAN BLVD                                        {txt}{c |}
        4. {txt}{c |} 11525 N COMMUNITY HOUSE RD                                        {txt}{c |}
        5. {txt}{c |}       1100 ABERNATHY RD NE                STE 1400                {txt}{c |}
           {c LT}{hline 25}{c -}{hline 15}{c -}{hline 10}{c -}{hline 6}{c -}{hline 7}{c RT}
        6. {txt}{c |}            2401 UTAH AVE S                                   FL 8 {txt}{c |}
        7. {txt}{c |}               1014 VINE ST                                        {txt}{c |}
        8. {txt}{c |}              508 SW 8TH ST                                        {txt}{c |}
        9. {txt}{c |}            3333 BEVERLY RD                                        {txt}{c |}
       10. {txt}{c |}           11 BRIDGEWAY PLZ                                        {txt}{c |}
           {c LT}{hline 25}{c -}{hline 15}{c -}{hline 10}{c -}{hline 6}{c -}{hline 7}{c RT}
       11. {txt}{c |}                 270 PK AVE                STE 1503                {txt}{c |}
       12. {txt}{c |}             18 W JIMMIE RD                                        {txt}{c |}
       13. {txt}{c |}                                BOX 2706                           {txt}{c |}
       14. {txt}{c |}                                 BOX 345                           {txt}{c |}
           {c BLC}{hline 25}{c -}{hline 15}{c -}{hline 10}{c -}{hline 6}{c -}{hline 7}{c BRC}


{title:Author}

{pstd}Nada Wasi{p_end}
{pstd}Survey Research Center{p_end}
{pstd}Institute for Social Research{p_end}
{pstd} University of Michigan{p_end}
{pstd}{browse "mailto:nwasi@umich.edu":nwasi@umich.edu}


{title:Also see}

{p 4 14 2}Article:  {it:Stata Journal}, volume 15, number 3: {browse "http://www.stata-journal.com/article.html?article=dm0082":dm0082}{p_end}
