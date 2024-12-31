{smcl}
{* *! version 2.1 07jan2012}{...}
{cmd:help scls} 

{hline}

{title:Title}

{p2colset 8 17 19 2}{...}
{p2col :{cmd: scls} {hline 2}}Symmetrically censored least squares estimator{p_end}
{p2colreset}{...}


{title:Syntax}

{phang}

{p 8 13 2}
{cmd:scls} {depvar} [{indepvars}] {ifin} 
	[{cmd:,} {it:{help scls##options:scls_options}}]


{synoptset 25 tabbed}{...}
{marker options}{...}
{synopthdr :options}
{synoptline}

{synopt :{opt s:tart(estimator)}}method used to compute the starting values{p_end}

{synopt :{opt p:owell}}use Powell's (1986) original optimization algorithm; the default is 
Santos Silva's (2001) algorithm{p_end}

{synopt:{opt tol:erance(#)}}tolerance for the coefficient vector; default is tolerance(1e-6){p_end}

{synopt :{opt iter:ate(#)}}perform a maximum of {it:#} iterations; default is iterate(16000){p_end}

{synopt :{opt no:log}}suppresses the iterations log{p_end}

{synoptline}
{p2colreset}{...}


{phang}{cmd:scls} does not allow {cmd:weight}s.{p_end}


{title:Description}

{pstd}
{cmd:scls} implements Powell's (1986) symmetrically censored least squares estimator and reports standard 
errors and t-statistics that are asymptotically valid under heteroskedasticity. The robust covariance matrix 
is computed following Powell (1986). Additionally, {cmd:scls} reports the value of the objective function 
(see equation 2.10 in Powell, 1986, p. 1439), the size of the sample and the number of observations effectively 
used. Two optimization algorithms are available. By default, estimation is performed using Santos Silva's (2001) 
algorithm, but Powell's (1986) original algorithm can be chosen with the option {opt powell}. It is also possible 
to choose how the starting values are computed using {opt start(estimator)}. 


{marker options}
{title:Options}

{phang}
{opt s:tart(estimator)} specifies how the initial values are computed. The following methods are available:

{pmore}
        {cmd:start(ols)} specifies that the starting values are obtained by OLS as in Powell (1986).

{pmore}
        {cmd:start(tobit)} specifies that the starting values are obtained by Tobit.

{pmore}
        {cmd:start(clad)} specifies that the starting values are obtained by performing the first two
        steps of the Chernozhukov and Hong (2002) estimator for censored median regression.

{pmore}The default is {cmd:start(clad)} because these starting values are consistent under the maintained 
assumptions and this method appears to provide faster convergence.

{phang}{opt p:owell} specifies that Powell's (1986) algorithm is used in the optimization. By default, the 
algorithm proposed by Santos Silva's (2001) is used because it tends to be much faster. Using {opt powell} 
can be useful if convergence cannot be achieved with the default options or as a check (especially useful 
if censoring is severe).

{phang}{opt tol:erance(#)} specifies the tolerance for the coefficient vector. Convergence is achieved when
the change in the coefficient vector is smaller than {it:#}.

{phang}{opt iter:ate(#)} specifies the maximum number of iterations that is performed; default is 
iterate(16000).

{phang}{opt no:log} suppresses the iterations log.



{title:Remarks}

{pstd}
{cmd: scls} was written by J.M.C. Santos Silva and it is not an official Stata command. For further help 
and support, please contact jmcss@essex.ac.uk. Please notice that this software is provided as is, without 
warranty of any kind, express or implied, including but not limited to the warranties of merchantability, 
fitness for a particular purpose and noninfringement. In no event shall the author be liable for any claim, 
damages or other liability, whether in an action of contract, tort or otherwise, arising from, out of or in 
connection with the software or the use or other dealings in the software.



{title:Examples}

    {hline}
{pstd}Setup{p_end}
{phang2}{cmd:. webuse womenwk}{p_end}
{phang2}{cmd:. replace wage=0 if wage==.}{p_end}

{pstd}SCLS with default options{p_end}
{phang2}{cmd:. scls wage educ age married children}{p_end}

{pstd}SCLS using Powell's algorithm{p_end}
{phang2}{cmd:. scls wage educ age married children, p}{p_end}

{pstd}SCLS using Powell's algorithm and Tobit starting values{p_end}
{phang2}{cmd:. scls wage educ age married children, p s(tobit)}{p_end}

    {hline}


{title:Saved results}

{pstd}
{cmd:scls} saves the following in {cmd:e()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}sample size{p_end}
{synopt:{cmd:e(N)}}number of observations effectively used{p_end}
{synopt:{cmd:e(obj_func)}}value of the objective function{p_end}
{synopt:{cmd:e(crit)}}convergence criterion{p_end}
{synopt:{cmd:e(rank)}}number of linearly independent regressors{p_end}
{synopt:{cmd:e(iter)}}number of iterations performed{p_end}
{synopt:{cmd:e(converged)}}{cmd:1} if converged; {cmd:0} otherwise{p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Macros}{p_end}
{synopt:{cmd:e(vcetype)}}Robust{p_end}
{synopt:{cmd:e(title)}}Symmetrically Censored Least Squares{p_end}
{synopt:{cmd:e(marginsok)}}predictions allowed by {cmd:margins}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:scls}{p_end}
{synopt:{cmd:e(predict)}}program used to implement {cmd:predict}{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}{p_end}
{synopt:{cmd:e(depvar)}}name of dependent variable{p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix{p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}


{title:References}

{phang} Chernozhukov, V. and Hong, H. (2002), Three-Step Censored Quantile Regression and Extramarital Affairs, 
{it:Journal of American Statistical Association}, 97, 872-882.{p_end} 
{phang} Powell, J. L. (1986), Symmetrically Trimmed Least Squares Estimation for Tobit Models, 
{it:Econometrica}, 54, 1235-1460. {p_end} 
{phang} Santos Silva, J.M.C. (2001), Influence Diagnostics and Estimation Algorithms for Powell's SCLS, 
{it:Journal of Business and Economics Statistics}, 19, 55-62.{p_end}
