{smcl}
{* 23jan2013}{...}
{cmd:help ivregress2}

{hline}

{title:Title}

{p2colset 5 19 33 2}{...}
{p2col :{hi:  ivregress2} {hline 2}}Exports first and second-stage results similar to ivregress.{p_end}

{marker s_Syntax}
{title:Syntax}

{p 4 10 6}
{cmdab:ivregress2} estimator depvar [varlist1] (varlist2 = varlist_iv) [if] [in] [weight] [, options]

{marker s_Description}
{title:Description}

{p 4 4 6}
{cmd:ivregress2} provides a fast and easy way to export both the first-stage and the second-stage results similar to {helpb ivregress}, on which it is based.

{marker s_Options}
{title:Options}

{p 4 12 6}ivregress2 accepts the syntax and the options for {helpb ivregress} (circa Stata 11) with the following change:{p_end}


{dlgtab:Changed option}

{p 4 12 6}{opt first} saves the estimates "first" and "second". {p_end}


{title:Examples}

* export them (with table-making programs of your choice)

{p 4 10 6}ivregress2 2sls mpg weight (length=displacement), first{p_end}
{p 4 10 6}est restore first{p_end}
{p 4 10 6}outreg2 using myfile, cttop(first) replace{p_end}
{p 4 10 6}est restore second{p_end}
{p 4 10 6}estat firststage{p_end}
{p 4 10 6}local fstat `r(mineig)'{p_end}
{p 4 10 6}estat endogenous{p_end}
{p 4 10 6}local p_durbin `r(p_durbin)'{p_end}
{p 4 10 6}outreg2 using myfile, cttop(second) excel adds(IV F-stat, `fstat', Durbin pval, `p_durbin'){p_end}

* You may fit 2SLS, LIML, GMM, etc. See {helpb ivregress}.

{p 4 10 6}webuse hsng2, clear{p_end}
{p 4 10 6}ivregress2 2sls rent pcturban (hsngval = faminc i.region), small{p_end}
{p 4 10 6}ivregress2 liml rent pcturban (hsngval = faminc i.region){p_end}
{p 4 10 6}ivregress2 gmm rent pcturban (hsngval = faminc i.region){p_end}

* use version control to make it future-proof against Stata 13 and beyond

{p 4 10 6}version 12: ivregress2 2sls mpg weight (length=displacement), first{p_end}


{title:Resources}

{p 4 10 6}{helpb ivregress postestimation}{p_end}
{p 4 10 6}{helpb ivregress postestimation##estatendog:estat endogenous} perform tests of endogeneity{p_end}
{p 4 10 6}{helpb ivregress postestimation##estatfirst:estat firststage} report "first-stage" regression statistics{p_end}
{p 4 10 6}{helpb ivregress postestimation##estatoverid:estat overid} perform tests of overidentifying restrictions{p_end}


{title:Remarks}

{p 4 10 6}This is actually an old program that I used personally. I hope this will put this issue to rest.{p_end}

{p 4 10 6}Alternatively, hit the BREAK button or the red X button on Stata after the first-stage appears. 
This solution should work with xtivreg and xtivreg2 also. See below for the original posting.{p_end}

{p 4 10 6}http://www.stata.com/statalist/archive/2012-05/msg00885.html{p_end}


{title:Acknowledgements}

{p 4 10 6}ivregress2 was cloned from the official ivregress. This is meant to be a supplement, not a replacement. 
Thanks to Stata Corporation for their open-source programming.{p_end}

    Etiology:
       2010/03/16 2:35PM CST   : ivregress2.ado prepared for personal use
       2012/05/21 6:15PM CST   : ivregress2.hlp prepared for public use
       2012/05/21 23:22:45 UTC : emailed to SSC
       2012/06/17 Unkown hour  : uploaded to SSC 27 days later, don't ask me
       2013/01/23 6:53PM CST   : ivregress2.hlp modified in response to inquiry
       2013/01/24 8:50AM CST   : ivregress2.hlp modified in response to Kit Baum
	
    Incidentally, the difference between CST and UTC is 5 hours during DST.


{title:Author}

{p 4 10 6}Roy Wada{p_end}
{p 4 10 6}roywada@hotmail.com{p_end}

