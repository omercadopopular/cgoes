{smcl}
{* *!version 2.3 2021-02-28}{...}
{viewerjumpto "Syntax" "rdrobust##syntax"}{...}
{viewerjumpto "Description" "rdrobust##description"}{...}
{viewerjumpto "Options" "rdrobust##options"}{...}
{viewerjumpto "Examples" "rdrobust##examples"}{...}
{viewerjumpto "Saved results" "rdrobust##saved_results"}{...}

{title:Title}

{p 4 8}{cmd:rddensity} {hline 2} Manipulation Testing Using Local Polynomial Density Estimation.{p_end}

{marker syntax}{...}
{title:Syntax}

{p 4 8}{cmd:rddensity} {it:Var} {ifin} 
[{cmd:,} 
{p_end}
{p 14 18}
{cmd:c(}{it:#}{cmd:)} 
{cmd:p(}{it:#}{cmd:)} 
{cmd:q(}{it:#}{cmd:)}
{cmd:fitselect(}{it:FitMethod}{cmd:)}
{cmd:kernel(}{it:KernelFn}{cmd:)}
{cmd:vce(}{it:VceMethod}{cmd:)}
{cmd:nomasspoints}
{cmd:level(}{it:#}{cmd:)}
{cmd:all}
{p_end}
{p 14 18}
{cmd:h(}{it:# #}{cmd:)} 
{cmd:bwselect(}{it:BwMethod}{cmd:)}
{cmd:nlocalmin(}{it:#}{cmd:)}
{cmd:nuniquemin(}{it:#}{cmd:)}
{cmd:noregularize}
{p_end}
{p 14 18}
{cmd:bino_n(}{it:#}{cmd:)} 
{cmd:bino_nstep(}{it:#}{cmd:)} 
{cmd:bino_w(}{it:# #}{cmd:)} 
{cmd:bino_wstep(}{it:# #}{cmd:)} 
{cmd:bino_nw(}{it:#}{cmd:)} 
{cmd:bino_p(}{it:#}{cmd:)}
{cmd:nobinomial}
{p_end}
{p 14 18}
{cmd:plot}  
{cmd:plot_range(}{it:# #}{cmd:)} 
{cmd:plot_n(}{it:# #}{cmd:)} 
{cmd:plot_grid(}{it:GridMethod}{cmd:)}
{cmd:plot_bwselect(}{it:BwMethod}{cmd:)}
{p_end}
{p 14 18}
{cmd:plot_ciuniform}
{cmd:plot_cisimul(}{it:# #}{cmd:)} 
{p_end}
{p 14 18}
{cmd:graph_opt(}{it:GraphOpt}{cmd:)}
{cmd:genvars(}{it:NewVarName}{cmd:)}
{p_end}
{p 14 18}
{cmd:plotl_estype(}{it:EstType}{cmd:)}
{cmd:esll_opt(}{it:LineOpt}{cmd:)}
{cmd:espl_opt(}{it:PtOpt}{cmd:)}
{p_end}
{p 14 18}
{cmd:plotr_estype(}{it:EstType}{cmd:)}
{cmd:eslr_opt(}{it:LineOpt}{cmd:)}
{cmd:espr_opt(}{it:PtOpt}{cmd:)}
{p_end}
{p 14 18}
{cmd:plotl_citype(}{it:CIType}{cmd:)}
{cmd: cirl_opt(}{it:AreaOpt}{cmd:)}
{cmd: cill_opt(}{it:LineOpt}{cmd:)}
{cmd: cibl_opt(}{it:EbarOpt}{cmd:)}
{p_end}
{p 14 18}
{cmd:plotr_citype(}{it:CIType}{cmd:)}
{cmd:cirr_opt(}{it:AreaOpt}{cmd:)}
{cmd:cilr_opt(}{it:LineOpt}{cmd:)}
{cmd:cibr_opt(}{it:EbarOpt}{cmd:)}
{p_end}
{p 14 18}
{cmd:hist_range(}{it:# #}{cmd:)} 
{cmd:hist_n(}{it:# #}{cmd:)} 
{cmd:hist_width(}{it:# #}{cmd:)} 
{cmd:histl_opt(}{it:BarOpt}{cmd:)}
{cmd:histr_opt(}{it:BarOpt}{cmd:)}
{cmd:nohistogram}
{p_end}
{p 14 18}
]{p_end}

{synoptset 28 tabbed}{...}

{marker description}{...}
{title:Description}

{p 4 8}{cmd:rddensity} implements manipulation testing procedures using the local polynomial density estimators proposed in
{browse "https://rdpackages.github.io/references/Cattaneo-Jansson-Ma_2020_JASA.pdf":Cattaneo, Jansson and Ma (2020)},
and implements graphical procedures with valid confidence bands using the results in
{browse "https://rdpackages.github.io/references/Cattaneo-Jansson-Ma_2021_JoE.pdf":Cattaneo, Jansson and Ma (2021)}.
In addition, the command provides complementary manipulation testing based on finite sample exact binomial testing following the results in
{browse "https://rdpackages.github.io/references/Cattaneo-Frandsen-Titiunik_2015_JCI.pdf":Cattaneo, Frandsen and Titiunik (2015)}
and
{browse "https://rdpackages.github.io/references/Cattaneo-Titiunik-VazquezBare_2017_JPAM.pdf":Cattaneo, Frandsen and Vazquez-Bare (2017)}.
For an introduction to manipulation testing see McCrary (2008).{p_end}

{p 4 8}A detailed introduction to this Stata command is given in {browse "https://rdpackages.github.io/references/Cattaneo-Jansson-Ma_2018_Stata.pdf":Cattaneo, Jansson and Ma (2018)}.{p_end}
{p 8 8}Companion {browse "www.r-project.org":R} functions are also available {browse "https://rdpackages.github.io/rddensity":here}.{p_end}

{p 4 8}Companion function is {help rdbwdensity:rdbwdensity}.
For graphical procedures, the 
{browse "https://nppackages.github.io/lpdensity":lpdensity}
package is required.{p_end}

{p 4 8}Related Stata and R packages useful for inference in regression discontinuity (RD) designs are described in the following website:{p_end}

{p 8 8}{browse "https://rdpackages.github.io/":https://rdpackages.github.io/}{p_end}

{marker options}{...}
{title:Options}

{dlgtab:Density Estimation}

{p 4 8}{opt c:}{cmd:(}{it:#}{cmd:)} specifies the threshold or cutoff value in the support of {it:Var}, which determines the two samples (e.g., control and treatment units in RD settings).
Default is {cmd:c(0)}.{p_end}

{p 4 8}{opt p:}{cmd:(}{it:#}{cmd:)} specifies the local polynomial order used to construct the density estimators.
Default is {cmd:p(2)} (local quadratic approximation).{p_end}

{p 4 8}{opt q:}{cmd:(}{it:#}{cmd:)} specifies the local polynomial order used to construct the bias-corrected density estimators.
Default is {cmd:q(p(}{it:#}{cmd:)+1)} (local cubic approximation for default {cmd:p(2)}).{p_end}

{p 4 8}{opt fit:select}{cmd:(}{it:FitMethod}{cmd:)} specifies the density estimation method.{p_end}
{p 8 12}{opt unrestricted}{bind:} for density estimation without any restrictions (two-sample, unrestricted inference).
This is the default option.{p_end}
{p 8 12}{opt restricted}{bind:  } for density estimation assuming equal distribution function and higher-order derivatives.{p_end}

{p 4 8}{opt ker:nel}{cmd:(}{it:KernelFn}{cmd:)} specifies the kernel function used to construct the local polynomial estimators.{p_end}
{p 8 12}{opt triangular}{bind:  } {it:K(u) = (1 - |u|) * (|u|<=1)}.
This is the default option.{p_end}
{p 8 12}{opt epanechnikov}{bind:}  {it:K(u) = 0.75 * (1 - u^2) * (|u|<=1)}.{p_end}
{p 8 12}{opt uniform}{bind:     }  {it:K(u) = 0.5 * (|u|<=1)}.{p_end}

{p 4 8}{opt vce:}{cmd:(}{it:VceMethod}{cmd:)} specifies the procedure used to compute the variance-covariance matrix estimator.{p_end}
{p 8 12}{opt plugin}{bind:   } for asymptotic plug-in standard errors.{p_end}
{p 8 12}{opt jackknife}{bind:} for jackknife standard errors.
This is the default option.{p_end}

{p 4 8}{opt nomass:points} will not adjust for mass points in the data.{p_end}

{p 4 8}{opt lev:el}{cmd:(}{it:#}{cmd:)} specifies the level of the confidence interval, which should be between 0 and 100.
Default is {cmd:level(95)}.{p_end}

{p 4 8}{opt all} if specified, {cmd:rddensity} reports two testing procedures:{p_end}
{p 8 12}Conventional test statistic (not valid when using MSE-optimal bandwidth choice).{p_end}
{p 8 12}Robust bias-corrected statistic.
This is the default option.{p_end}


{dlgtab:Bandwidth Selection}

{p 4 8}{opt h:}{cmd:(}{it:#} {it:#}{cmd:)} specifies the bandwidth ({it:h}) used to construct the density estimators on the two sides of the cutoff.
If not specified, the bandwidth {it:h} is computed by the companion command
{help rdbwdensity:rdbwdensity}.
If two bandwidths are specified, the first bandwidth is used for the data below the cutoff and the second bandwidth is used for the data above the cutoff.{p_end}

{p 4 8}{opt bw:select}{cmd:(}{it:BwMethod}{cmd:)} specifies the bandwidth selection procedure to be used.{p_end}
{p 8 12}{opt each}{bind:} based on MSE of each density estimator separately (two distinct bandwidths, {it:hl} and {it:hr}).{p_end}
{p 8 12}{opt diff}{bind:} based on MSE of difference of two density estimators (one common bandwidth, {it:hl}={it:hr}).{p_end}
{p 8 12}{opt sum}{bind: } based on MSE of sum of two density estimators (one common bandwidth, {it:hl}={it:hr}).{p_end}
{p 8 12}{opt comb}{bind:} bandwidth is selected as a combination of the alternatives above.
This is the default option.{p_end}
{p 13 17}For {cmd:fitselect(}{opt unrestricted}{cmd:)}, it selects median({opt each},{opt diff},{opt sum}).{p_end}
{p 13 17}For {cmd:fitselect(}{opt restricted}{cmd:)}, it selects min({opt diff},{opt sum}).{p_end}

{p 4 8}{opt nloc:almin}{cmd:(}{it:#}{cmd:)} specifies the minimum number of observations in each local neighborhood.
This option will be ignored if set to 0, or if {cmd:noregularize} is used.
Default is {cmd:20+p(}{it:#}{cmd:)+1}.{p_end}

{p 4 8}{opt nuni:quemin}{cmd:(}{it:#}{cmd:)} specifies the minimum number of unique observations in each local neighborhood.
This option will be ignored if set to 0, or if {cmd:noregularize} is used.
Default is {cmd:20+p(}{it:#}{cmd:)+1}.{p_end}

{p 4 8}{opt noreg:ularize} suppresses local sample size checking.{p_end}


{dlgtab:Binomial Test}

{p 4 8}{opt bino_w:}{cmd:(}{it:# #}{cmd:)} specifies the half length(s) of the initial window.
If two values are provided, they will be used for the data below and above the cutoff separately.{p_end}

{p 4 8}{opt bino_n:}{cmd:(}{it:#}{cmd:)} specifies the sample size in the initial window.
This option will be ignored if {opt bino_w:}{cmd:(}{it:# #}{cmd:)} is provided.{p_end}

{p 4 8}{opt bino_wstep:}{cmd:(}{it:# #}{cmd:)} specifies the increment in half length(s).{p_end}

{p 4 8}{opt bino_nstep:}{cmd:(}{it:#}{cmd:)} specifies the increment in sample size.
This option will be ignored if {opt bino_wstep:}{cmd:(}{it:# #}{cmd:)} is provided.{p_end}

{p 4 8}{opt bino_nw:}{cmd:(}{it:#}{cmd:)} specifies the total number of windows.
Default is {cmd:10}.{p_end}

{p 4 8}{opt bino_p}{cmd:(}{it:#}{cmd:)} specifies the null hypothesis of the binomial test.
Default is 0.5.{p_end}

{p 4 8}{opt nobino:mial} suppresses the binomial test.
By default, the initial (smallest) window contains 20 observations, and its length is also used as the increment for subsequent windows.{p_end}


{dlgtab:Plotting}

{p 4 8}{opt pl:ot} if specified, {cmd:rddensity} plots density estimates and confidence intervals/bands around the cutoff (this feature depends on a companion package {help lpdensity:lpdensity}).
Note that additional estimation (computing time) is needed.{p_end}

{p 4 8}{opt plot_range}{cmd:(}{it:#} {it:#}{cmd:)} specifies the lower and upper bound of the plotting region.
Default is {it:[c-3*hl,c+3*hr]} (three bandwidths around the cutoff).{p_end}

{p 4 8}{opt plot_n}{cmd:(}{it:#} {it:#}{cmd:)} specifies the number of grid points used for plotting on the two sides of the cutoff.
Default is {cmd:plot_n(10 10)} (i.e., 10 points are used on each side).{p_end}

{p 4 8}{opt plot_grid}{cmd:(}{it:GridMethod}{cmd:)} specifies how the grid points are positioned.
Options are {opt es} (evenly spaced) and {opt qs} (quantile spaced).{p_end}

{p 4 8}{opt plot_bwselect}{cmd:(}{it:BwMwthod}{cmd:)} specifies the method for data-driven bandwidth selection.
Options are {cmd:mse-dpi}, {cmd:imse-dpi}, {cmd:mse-rot}, and {cmd:imse-rot}.
See {help lpdensity:lpdensity} for additional details.
If this option is omitted, the same bandwidth(s) used for manipulation testing will be employed.{p_end}

{p 4 8}{opt plot_ciuniform} plots uniform confidence bands instead of pointwise confidence intervals.
The companion option, {opt plot_cisimul}({it:#}), specifies the number of simulations used to construct critical values.
Default is 2000.{p_end}

{p 4 8}{opt graph_opt}({it:GraphOpt}) specifies additional options for plotting, such as legends and labels.{p_end}

{p 4 8}{opt genv:ars}({it:NewVarName}) specifies if new variables should be generated to store estimation results.{p_end}

{p 4 8}{bf: Remark}. Bias correction is only used for the construction of confidence intervals/bands, but not for point estimation. The point estimates, denoted by f_p, are constructed using local polynomial estimates of order
{cmd:p(}{it:#}{cmd:)},
while the centering of the confidence intervals/bands, denoted by f_q, are constructed using local polynomial estimates of order
{cmd:q(}{it:#}{cmd:)}.
The confidence intervals/bands take the form:
[f_q - cv * SE(f_q) , f_q + cv * SE(f_q)],
where cv denotes the appropriate critical value and SE(f_q) denotes a standard error estimate for the centering of the confidence interval/band.
As a result, the confidence intervals/bands may not be centered at the point estimates because they have been bias-corrected. Setting
{cmd:q(}{it:#}{cmd:)}
and
{cmd:p(}{it:#}{cmd:)}
to be equal results on centered at the point estimate confidence intervals/bands, but requires undersmoothing for valid inference (i.e., (I)MSE-optimal bandwdith for the density point estimator cannot be used). 
Hence the bandwidth would need to be specified manually when
{cmd:q(}{it:#}{cmd:)} = {cmd:p(}{it:#}{cmd:)},
and the point estimates will not be (I)MSE optimal. See Cattaneo, Jansson and Ma
({browse "https://rdpackages.github.io/references/Cattaneo-Jansson-Ma_2020_JoE.pdf":2020b}, {browse "https://rdpackages.github.io/references/Cattaneo-Jansson-Ma_2020_JSS.pdf":2020c})
for details, and also Calonico, Cattaneo, and Farrell
({browse "https://rdpackages.github.io/references/Calonico-Cattaneo-Farrell_2018_JASA.pdf":2018},
{browse "https://rdpackages.github.io/references/Calonico-Cattaneo-Farrell_2020_CEopt.pdf":2020}) 
for robust bias correction methods.{p_end}

{p 8 8} Sometimes the density point estimates may lie outside of the confidence intervals/bands, which can happen if the underlying distribution exhibits high curvature at some evaluation point(s). 
One possible solution in this case is to increase the polynomial order {cmd:p(}{it:#}{cmd:)} or to employ a smaller bandwidth.{p_end}


{dlgtab:Additional Plotting Options: Histogram}

{p 4 8}{opt hist_range}{cmd:(}{it:#} {it:#}{cmd:)} specifies the lower and upper bound of the histogram plot.
Default is {it:[c-3*hl,c+3*hr]} (three bandwidths around the cutoff).{p_end}

{p 4 8}{opt hist_n}{cmd:(}{it:#} {it:#}{cmd:)} specifies the number of histogram bars.
Default is {it:min[sqrt(N),10*log(N)/log(10)]}, where {it:N} is the number of observations within the range specified by {opt hist_range}{cmd:(}{it:#} {it:#}{cmd:)}.{p_end}

{p 4 8}{opt hist_width}{cmd:(}{it:#} {it:#}{cmd:)} specifies the width of histogram bars.
This option will be ignored if {opt hist_range}{cmd:(}{it:#} {it:#}{cmd:)} is provided.{p_end}

{p 4 8}{opt nohist:ogram} suppresses the histogram in the background of the plot.{p_end}


{dlgtab:Additional Plotting Options: Below the Cutoff}

{p 4 8}{opt plotl_estype}{cmd:(}{it:EstType}{cmd:)} specifies the plotting style of point estimates.{p_end}
{p 8 12}{opt line}{bind:  } a curve.
This is the default option.{p_end}
{p 8 12}{opt points}{bind:} individual points.{p_end}
{p 8 12}{opt both}{bind:  } both of the above.{p_end}
{p 8 12}{opt none}{bind:  } will not plot point estimates.{p_end}

{p 4 8}{opt esll_opt}{cmd:(}{it:LineOpt}{cmd:)}{bind:} specifies additional {cmd:twoway line}{bind:   } options for plotting point estimates.{p_end}

{p 4 8}{opt espl_opt}{cmd:(}{it:PtOpt}{cmd:)}{bind:  } specifies additional {cmd:twoway scatter}{bind:} options for plotting point estimates.{p_end}

{p 4 8}{opt plotl_citype}{cmd:(}{it:EstType}{cmd:)} specifies the plotting style of confidence intervals/bands.{p_end}
{p 8 12}{opt region}{bind:} shaded region.
This is the default option.{p_end}
{p 8 12}{opt line}{bind:  } upper and lower bounds.{p_end}
{p 8 12}{opt ebar}{bind:  } error bars.{p_end}
{p 8 12}{opt all}{bind:   } all of the above.{p_end}
{p 8 12}{opt none}{bind:  } will not plot confidence intervals/bands.{p_end}

{p 4 8}{opt cirl_opt}{cmd:(}{it:AreaOpt}{cmd:)}{bind:} specifies additional {cmd:twoway rarea}{bind:} options for plotting confidence intervals/regions.{p_end}

{p 4 8}{opt cill_opt}{cmd:(}{it:LineOpt}{cmd:)}{bind:} specifies additional {cmd:twoway rline}{bind:} options for plotting confidence intervals/regions.{p_end}

{p 4 8}{opt cibl_opt}{cmd:(}{it:EbarOpt}{cmd:)}{bind:} specifies additional {cmd:twoway rcap}{bind:} options for plotting confidence intervals/regions.{p_end}

{p 4 8}{opt histl_opt}{cmd:(}{it:BarOpt}{cmd:)}{bind:} specifies additional {cmd:twoway bar}{bind:} options for histogram.{p_end}


{dlgtab:Additional Plotting Options: Above the Cutoff}

{p 4 8}{opt plotr_estype}{cmd:(}{it:EstType}{cmd:)} specifies the plotting style of point estimates.{p_end}
{p 8 12}{opt line}{bind:  } a curve.
This is the default option.{p_end}
{p 8 12}{opt points}{bind:} individual points.{p_end}
{p 8 12}{opt both}{bind:  } both of the above.{p_end}
{p 8 12}{opt none}{bind:  } will not plot point estimates.{p_end}

{p 4 8}{opt eslr_opt}{cmd:(}{it:LineOpt}{cmd:)}{bind:} specifies additional {cmd:twoway line}{bind:} options for plotting point estimates.{p_end}

{p 4 8}{opt espr_opt}{cmd:(}{it:PtOpt}{cmd:)}{bind:} specifies additional {cmd:twoway scatter}{bind:} options for plotting point estimates.{p_end}

{p 4 8}{opt plotr_citype}{cmd:(}{it:EstType}{cmd:)} specifies the plotting style of confidence intervals/bands.{p_end}
{p 8 12}{opt region}{bind:} shaded region.
This is the default option.{p_end}
{p 8 12}{opt line}{bind:  } upper and lower bounds.{p_end}
{p 8 12}{opt ebar}{bind:  } error bars.{p_end}
{p 8 12}{opt all}{bind:   } all of the above.{p_end}
{p 8 12}{opt none}{bind:  } will not plot confidence intervals/bands.{p_end}

{p 4 8}{opt cirr_opt}{cmd:(}{it:AreaOpt}{cmd:)}{bind:} specifies additional {cmd:twoway rarea}{bind:} options for plotting confidence intervals/regions.{p_end}

{p 4 8}{opt cilr_opt}{cmd:(}{it:LineOpt}{cmd:)}{bind:} specifies additional {cmd:twoway rline}{bind:} options for plotting confidence intervals/regions.{p_end}

{p 4 8}{opt cibr_opt}{cmd:(}{it:EbarOpt}{cmd:)}{bind:} specifies additional {cmd:twoway rcap}{bind:} options for plotting confidence intervals/regions.{p_end}
 
{p 4 8}{opt histr_opt}{cmd:(}{it:BarOpt}{cmd:)}{bind:} specifies additional {cmd:twoway bar}{bind:} options for histogram.{p_end}


{marker examples}{...}
{title:Example: Cattaneo, Frandsen and Titiunik (2015) Incumbency Data}.

{p 4 8}Load dataset (cutoff is 0 in this dataset):{p_end}
{p 8 8}{cmd:. use rddensity_senate.dta}{p_end}

{p 4 8}Manipulation test using default options: {p_end}
{p 8 8}{cmd:. rddensity margin}{p_end}

{p 4 8}Reporting both conventional and robust bias-corrected statistics:{p_end}
{p 8 8}{cmd:. rddensity margin, all}{p_end}

{p 4 8}Manipulation test using manual bandwidths choices and plug-in standard errors:{p_end}
{p 8 8}{cmd:. rddensity margin, h(10 20) vce(plugin)}{p_end}

{p 4 8}Plot density and save results to variables:{p_end}
{p 8 8}{cmd:. capture drop temp_*}{p_end}
{p 8 8}{cmd:. rddensity margin, pl plot_range(-50 50) plot_n(100 100) genvars(temp) }{p_end}


{marker saved_results}{...}
{title:Saved results}

{p 4 8}{cmd:rddensity} saves the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(c)}}cutoff value{p_end}
{synopt:{cmd:e(p)}}order of the polynomial used for density estimation{p_end}
{synopt:{cmd:e(q)}}order of the polynomial used for bias-correction estimation{p_end}

{synopt:{cmd:e(N_l)}}sample size to the left of the cutoff{p_end}
{synopt:{cmd:e(N_r)}}sample size to the right of the cutoff{p_end}
{synopt:{cmd:e(N_h_l)}}effective sample size (within bandwidth) to the left of the cutoff{p_end}
{synopt:{cmd:e(N_h_r)}}effective sample size (within bandwidth) to the right of the cutoff{p_end}
{synopt:{cmd:e(h_l)}}bandwidth used to the left of the cutoff{p_end}
{synopt:{cmd:e(h_r)}}bandwidth used to the right of the cutoff{p_end}

{synopt:{cmd:e(f_ql)}}bias-corrected density estimate to the left of the cutoff{p_end}
{synopt:{cmd:e(f_qr)}}bias-corrected density estimate to the right of the cutoff{p_end}
{synopt:{cmd:e(se_ql)}}standard error for bias-corrected density estimate to the left of the cutoff{p_end}
{synopt:{cmd:e(se_qr)}}standard error for bias-corrected density estimate to the right of the cutoff{p_end}
{synopt:{cmd:e(se_q)}}standard error for bias-corrected density test{p_end}
{synopt:{cmd:e(T_q)}}bias-corrected t-statistic{p_end}
{synopt:{cmd:e(pv_q)}}p-value for bias-corrected density test{p_end}

{synopt:{cmd:e(runningvar)}}running variable used{p_end}
{synopt:{cmd:e(kernel)}}kernel used{p_end}
{synopt:{cmd:e(fitmethod)}}model used{p_end}
{synopt:{cmd:e(bwmethod)}}bandwidth selection method used{p_end}
{synopt:{cmd:e(vce)}}standard errors estimator used{p_end}

{p2col 5 20 24 2: Only available if {cmd:all} is specified:}{p_end}
{synopt:{cmd:e(f_pl)}}density estimate to the left of the cutoff without bias correction {p_end}
{synopt:{cmd:e(f_pr)}}density estimate to the right of the cutoff without bias correction{p_end}
{synopt:{cmd:e(se_pl)}}standard error for density estimate to the left of the cutoff without bias correction{p_end}
{synopt:{cmd:e(se_pr)}}standard error for density estimate to the right of the cutoff without bias correction{p_end}
{synopt:{cmd:e(se_p)}}standard error for density test without bias correction{p_end}
{synopt:{cmd:e(T_p)}}t-statistic without bias correction{p_end}
{synopt:{cmd:e(pv_p)}}p-value for density test without bias correction{p_end}


{title:References}

{p 4 8}Calonico, S., M. D. Cattaneo, and M. H. Farrell. 2018.
{browse "https://rdpackages.github.io/references/Calonico-Cattaneo-Farrell_2018_JASA.pdf":On the Effect of Bias Estimation on Coverage Accuracy in Nonparametric Inference}.{p_end}
{p 8 8}{it:Journal of the American Statistical Association} 113(522): 767-779.{p_end}

{p 4 8}Calonico, S., M. D. Cattaneo, and M. H. Farrell. 2020.
{browse "https://rdpackages.github.io/references/Calonico-Cattaneo-Farrell_2020_CEopt.pdf":Coverage Error Optimal Confidence Intervals for Local Polynomial Regression}.{p_end}
{p 8 8}Working paper.{p_end}

{p 4 8}Cattaneo, M. D., B. Frandsen, and R. Titiunik. 2015.
{browse "https://rdpackages.github.io/references/Cattaneo-Frandsen-Titiunik_2015_JCI.pdf":Randomization Inference in the Regression Discontinuity Design: An Application to the Study of Party Advantages in the U.S. Senate}.{p_end}
{p 8 8}{it:Journal of Causal Inference} 3(1): 1-24.{p_end}

{p 4 8}Cattaneo, M. D., M. Jansson, and X. Ma. 2018.
{browse "https://rdpackages.github.io/references/Cattaneo-Jansson-Ma_2018_Stata.pdf": Manipulation Testing based on Density Discontinuity}.{p_end}
{p 8 8}{it:Stata Journal} 18(1): 234-261.{p_end}

{p 4 8}Cattaneo, M. D., M. Jansson, and X. Ma. 2020.
{browse "https://rdpackages.github.io/references/Cattaneo-Jansson-Ma_2020_JASA.pdf":Simple Local Polynomial Density Estimators}.{p_end}
{p 8 8}{it:Journal of the American Statistical Association} 115(531): 1449-1455.{p_end}

{p 4 8}Cattaneo, M. D., M. Jansson, and X. Ma. 2021a.
{browse "https://rdpackages.github.io/references/Cattaneo-Jansson-Ma_2021_JoE.pdf":Local Regression Distribution Estimators}.{p_end}
{p 8 8}{it:Journal of Econometrics}, forthcoming.{p_end}

{p 4 8}Cattaneo, M. D., Michael Jansson, and Xinwei Ma. 2021b.
{browse "https://rdpackages.github.io/references/Cattaneo-Jansson-Ma_2021_JSS.pdf":lpdensity: Local Polynomial Density Estimation and Inference}.{p_end}
{p 8 8}{it:Journal of Statistical Software}, forthcoming.{p_end}

{p 4 8}Cattaneo, M. D., Titiunik, R. and G. Vazquez-Bare. 2017.
{browse "https://rdpackages.github.io/references/Cattaneo-Titiunik-VazquezBare_2017_JPAM.pdf":Comparing Inference Approaches for RD Designs: A Reexamination of the Effect of Head Start on Child Mortality}.{p_end}
{p 8 8}{it:Journal of Policy Analysis and Management} 36(3): 643-681.{p_end}

{p 4 8}McCrary, J. 2008. Manipulation of the Running Variable in the Regression Discontinuity Design: A Density Test.{p_end}
{p 8 8}{it:Journal of Econometrics} 142(2): 698-714.{p_end}


{title:Authors}

{p 4 8}Matias D. Cattaneo, Princeton University, Princeton, NJ.
{browse "mailto:cattaneo@princeton.edu":cattaneo@princeton.edu}.{p_end}

{p 4 8}Michael Jansson, University of California Berkeley, Berkeley, CA.
{browse "mailto:mjansson@econ.berkeley.edu":mjansson@econ.berkeley.edu}.{p_end}

{p 4 8}Xinwei Ma, University of California San Diego, La Jolla, CA.
{browse "mailto:x1ma@ucsd.edu":x1ma@ucsd.edu}.{p_end}



