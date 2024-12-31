{smcl}
{hline}
help for {hi:scfcombo}{right: {hi:}}
{hline}

{title: Incorporating imputation uncertainty and bootstrapping standard errors with the Survey of Consumer Finances}

{p 8 27}
{cmd:scfcombo}
[{it:varlist}]
[{it:weight}]
[{cmd:if}{it:exp}]
[{cmd:in}{it:range}]
[{cmd:,}
    {cmd:reps}
    {cmd:imps}
    {cmd:command}
    {cmd:title}
]

{p}
{cmd:by} {it:...}{cmd::} may be used with {cmd:scfcombo}; see help {help by}.

{cmd:aweight}s are allowed; see help {help weights}.

{title: Description}
{p}
{cmd:scfcombo} calculates and combines the imputation uncertainty and bootstrapped 
standard errors for estimation commands run on the Survey of Consumer Finances (SCF).  

{p}
The SCF handles missing values using repeated-imputation inference (see Little, Roderick J.A., "Regression with
Missing X's: A Review," Journal of the American Statistical Association, December 1992, 87(420), pp. 1227-1237).   
To estimate each missing value, the SCF draws five times from the conditional distribution of that variable.  
As a result, there are five copies of each data set, with five different values for each missing value. 

{p}
Under RII, coefficients are calculated by running the estimation command separately 
over each replicate, and taking the average of the five estimates. To calculate the imputation uncertainty, the 
user estimates the variance of the five sets of coefficients.  

{p}
The SCF data includes 999 bootstrap replicates, drawn in accordance with the SCF sample design. 
A set of sampling weights, created using the same weighting algorithm as the main sample, is available for the first replicate. 
This command allows the user to incorporate the sample design into the standard error calculation.  
For more information see {browse "http://www.federalreserve.gov/pubs/oss/oss2/scfindex.html"}. 

{p}
This program is designed to be used with a data set including observations from all five imputation replicates.  
In addition, the data set should include a variable called "rep" which takes on values from 1 to 5, depending on the 
replicate corresponding to each observation. The bootstrap errors are calculated using only the first implicate.
In addition, the data set should include the mm999-mm1 (the number of times each observation is drawn for
a given bootstrapping replicate).  Note that the program expects the mm variables to be in the mm999-mm1 order, following the SCF convention.  If you
use weights in the estimation, include wt1b1-wt1b999 (the weights for each bootstrapping replicate) on the data file as well.

{p}
This program gives coefficients and standard errors only.  Other statistics that are common to STATA commands are omitted.

{title:Options}

{p 0 4}
{cmd:weight} To get weighted point estimates, specify the appropriate weight from the
SCF (usually x42000 or x42001, in most cases  x42001 is preferred).  If you specify weighted point estimates, the program uses wt1b1-wt1b999 as 
the weights for calculating the standard errors.  Do not change the names of these weights on your dataset, since
they are hard-coded into the program.

{p 0 4}
{cmd:reps} Specify the desired number of bootstrapped replicates.  The
default is 200, as statistical theory suggests that a minimum of 200 replicates is desirable for estimating standard errors.

{p 0 4}
{cmd:imps} Specify the number of implicates.  The default is 5.  

{p 0 4}
{cmd:command} Specify the desired STATA estimation command.  {cmd:scfcombo} should work for
any STATA estimation (e-class) command.  However, note that {cmd:scfcombo} is not flexible enough to 
incorporate any options that are idiosyncratic to a given estimation command.

{p 0 4}
{cmd:title} Specify a title for the command if desired.

{title:Examples}
{inp:. scfcombo netw k401 age [aw=x42001], command(probit) reps(200) imps(5) title("Test")}

{title: Author}
{p}
Adapted in 2015 by Jane Brittingham at the University of Wisconsin Center for Financial Security from scfimp and scfboot by Karen Pence (formerly of Wisconsin, Currently Federal Reserve Board)


