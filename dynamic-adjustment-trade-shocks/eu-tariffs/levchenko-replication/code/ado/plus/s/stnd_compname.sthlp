{smcl}
{* 13 August 2014}{...}
{cmd:help stnd_compname}{right: ({browse "http://www.stata-journal.com/article.html?article=dm0082":SJ15-3: dm0082})}
{hline}

{title:Title}

{p2colset 5 22 24 2}{...}
{p2col:{cmd:stnd_compname} {hline 2}}Standardize and parse a string variable containing the company names
{p2colreset}{...}


{title:Syntax}

{p 8 21 2}
{cmd:stnd_compname} {it:varname} {ifin}{cmd:,} {cmdab:g:en(}{it:newvarnames}{cmd:)} [{cmdab:p:atpath(}{it:directory_of_pattern_files}{cmd:)}]

						
{title:Description}

{pstd}
{cmd:stnd_compname} standardizes and parses a string variable containing
company names into five components.  {bf:gen()} is required.  The generated
outputs are in the following order: 1) official name, 2) doing-business-as
name, 3) formerly-known-as name, 4) business entity type, and 5) attention
name.  Each component is standardized.  If a given name cannot be parsed, the
original value is recorded in the official name field.{p_end}

{pstd}
{cmd:stnd_compname} relies on several subcommands and ancillary rule-based
pattern files.  These subcommands and pattern files must also be installed.
The default directory of the pattern files is {cmd:ado/plus/p/}.  If the
pattern files are installed in a different directory, the user must specify
the directory in the {bf:patpath()} option.  If a particular pattern file is
not found, the program will display a warning message, and the standardizing
or parsing step associated with that file will be skipped.{p_end}


{title:Options}

{phang}
{opt gen(newvarnames)} generates five variables corresponding to components of
{it:varname}.  {cmd:gen()} is required.

{phang}
{opt patpath(directory_of_pattern_files)} specifies the directory of the
pattern files.


{title:Options for advanced users}

{pstd}
{cmd:stnd_compname} is constructed from the following commands and their
associated pattern files.  Users may use their own pattern files by
setting {bf:patpath()} to the directory where alternative pattern files
are located.  See help for each subcommand.{p_end}

{synoptset 21}{...}
{p2coldent :Command}Description{p_end}
{synoptline}
{synopt :{helpb parsing_namefield}}parses company name without standardization{p_end}
{synopt :{helpb stnd_specialchar}}standardizes special characters{p_end}
{synopt :{helpb stnd_entitytype}}standardizes business entity types{p_end}
{synopt :{helpb stnd_commonwrd_name}}standardizes words commonly appearing in company names{p_end}
{synopt :{helpb stnd_commonwrd_all}}standardizes words commonly appearing in company names and addresses{p_end}
{synopt :{helpb stnd_NESW}}standardizes directional words{p_end}
{synopt :{helpb stnd_numbers}}standardizes numerals and their number equivalent{p_end}
{synopt :{helpb stnd_smallwords}}standardizes small words (for example, conjunctions){p_end}
{synopt :{helpb parsing_entitytype}}parses entity type from company name{p_end}
{synopt :{helpb agg_acronym}}remove spaces between two or more one-letter words{p_end}
{synoptline}


{title:Example}

{pstd}
The string variable {cmd:firm_name} contains company names that we wish to
standardize.{p_end}
       {cmd:. list firm_name}
    {txt}
            {c TLC}{hline 57}{c TRC}
            {c |} {res}                                              firm_name {txt}{c |}
            {c LT}{hline 57}{c RT}
         1. {c |} {res}                                          7-ELEVEN, INC {txt}{c |}
         2. {c |} {res}                                              AT&T INC. {txt}{c |}
         3. {c |} {res}                               DISH NETWORK CORPORATION {txt}{c |}
         4. {c |} {res}                  HVM L.L.C. D/B/A EXTENDED STAY HOTELS {txt}{c |}
         5. {c |} {res}                            RHEEM MANUFACTURING COMPANY {txt}{c |}
            {c LT}{hline 57}{c RT}
         6. {c |} {res}                                  STARBUCKS CORPORATION {txt}{c |}
         7. {c |} {res}                                          THE KROGER CO {txt}{c |}
         8. {c |} {res}                                  WAL-MART STORES, INC. {txt}{c |}
         9. {c |} {res}                                      KMART CORPORATION {txt}{c |}
        10. {c |} {res}         PROFESSIONAL PHARMACIES INC DBA PLAZA PHARMACY {txt}{c |}
            {c LT}{hline 57}{c RT}
        11. {c |} {res}             MADISON HOLDINGS, INC. C/O WORLD FINANCIAL {txt}{c |}
        12. {c |} {res}                      RESORTS U.S.A. T/A SEASIDE RESORT {txt}{c |}
        13. {c |} {res}                          PG INDUSTRIES ATTN JOHN SMITH {txt}{c |}
        14. {c |} {res}                        BB & T FKA COASTAL FEDERAL BANK {txt}{c |}
            {c BLC}{hline 57}{c BRC}

{pstd}
Standardize {cmd:firm_name}, and create five new variables of name
components{p_end}
{phang2}{cmd:. stnd_compname firm_name, gen(stn_name stn_dbaname stn_fkaname entitytype attn_name)}{p_end}{phang2}{cmd:. list stn_name stn_dbaname stn_fkaname entitytype attn_name}{p_end}

           {c TLC}{hline 19}{c -}{hline 25}{c -}{hline 20}{c -}{hline 10}{c -}{hline 18}{c TRC}
           {c |} {res}           stn_name             stn_dbaname                stn_fk~e  entity~e        attn_name {txt}{c |}
           {c LT}{hline 20}{c -}{hline 25}{c -}{hline 20}{c -}{hline 10}{c -}{hline 17}{c RT}
        1. {c |} {res}             7 11                                                       INC                    {txt}{c |}
        2. {c |} {res}           AT & T                                                       INC                    {txt}{c |}
        3. {c |} {res}     DISH NETWORK                                                      CORP                    {txt}{c |}
        4. {c |} {res}              HVM    EXTENDED STAY HOTELS                               LLC                    {txt}{c |}
        5. {c |} {res}        RHEEM MFG                                                        CO                    {txt}{c |}
           {c LT}{hline 21}{c -}{hline 25}{c -}{hline 20}{c -}{hline 10}{c -}{hline 16}{c RT}
        6. {c |} {res}        STARBUCKS                                                      CORP                    {txt}{c |}
        7. {c |} {res}       THE KROGER                                                        CO                    {txt}{c |}
        8. {c |} {res}  WAL MART STORES                                                       INC                    {txt}{c |}
        9. {c |} {res}            KMART                                                      CORP                    {txt}{c |}
       10. {c |} {res}  PROF PHARMACIES            PLZ PHARMACY                               INC                    {txt}{c |}
           {c LT}{hline 19}{c -}{hline 25}{c -}{hline 20}{c -}{hline 10}{c -}{hline 18}{c RT}
       11. {c |} {res}  ADISON HOLDINGS                                                       INC     WORLD FINANCIAL{txt}{c |}
       12. {c |} {res}      RESORTS USA          SEASIDE RESORT                                                      {txt}{c |}
       13. {c |} {res}           PG IND                                                       INC          JOHN SMITH{txt}{c |}
       14. {c |} {res}           BB & T                        COASTAL FEDERAL BANKCORP                              {txt}{c |}
           {c BLC}{hline 19}{c -}{hline 25}{c -}{hline 20}{c -}{hline 10}{c -}{hline 18}{c BRC}


{title:Author}

{pstd}Nada Wasi{p_end}
{pstd}Survey Research Center{p_end}
{pstd}Institute for Social Research{p_end}
{pstd}University of Michigan{p_end}
{pstd}Ann Arbor, MI{p_end}
{pstd}{browse "mailto:nwasi@umich.edu":nwasi@umich.edu}


{title:Also see}

{p 4 14 2}Article:  {it:Stata Journal}, volume 15, number 3: {browse "http://www.stata-journal.com/article.html?article=dm0082":dm0082}

{p 7 14 2}Help: {helpb stnd_address}, {helpb reclink}, {helpb reclink2} (if
installed){p_end}
