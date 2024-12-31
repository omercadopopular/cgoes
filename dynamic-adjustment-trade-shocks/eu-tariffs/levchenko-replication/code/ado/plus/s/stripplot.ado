*! 2.9.0 NJC 10 July 2021     
* 2.8.1 NJC 11 October 2020 
* 2.8.0 NJC 4 July 2018 
* 2.7.2 NJC 8 June 2017 
* 2.7.1 NJC 27 March 2017 
* 2.7.0 NJC 2 March 2017 
* 2.6.0 NJC 21 February 2017 
* 2.5.3 NJC 20 December 2016 
* 2.5.2 NJC 23 September 2014 
* 2.5.1 NJC 9 September 2014 
* 2.5.0 NJC 14 August 2014 
* 2.4.7 NJC 28 June 2012 
* 2.4.6 NJC 30 August 2011 
* 2.4.5 NJC 2 December 2010 
* 2.4.4 NJC 10 March 2010 
* 2.4.3 NJC 16 February 2010 
* 2.4.2 NJC 4 February 2010 
* 2.4.1 NJC 30 November 2009 
* 2.4.0 NJC 21 April 2009 
* 2.3.3 NJC 8 November 2007 
* 2.3.2 NJC 2 November 2007 
* 2.3.1 NJC 17 July 2007 
* 2.3.0 NJC 21 June 2007 
* 2.2.0 NJC 28 November 2005
* onewayplot 2.1.3 NJC 27 October 2004
* 2.1.2 NJC 11 August 2004
* 2.1.1 NJC 21 July 2004
* 2.1.0 NJC 13 February 2004
* 2.0.3 NJC 17 July 2003 
* 2.0.2 NJC 7 July 2003 
* 2.0.1 NJC 6 July 2003 
* 2.0.0 NJC 3 July 2003 
* 1.2.1 NJC 18 October 1999 
* 1.1.0 NJC 27 April 1999 
* 1.0.0 NJC 23 April 1999 
program stripplot, sort  
	version 8.2
	syntax varlist(numeric) [if] [in]                                  ///
	[, CEnter CEntre VERTical Height(real 0.8) Fraction(str) STack     ///
	over(varname) by(str asis) Width(numlist max=1 >0)                 ///
	floor CEILing box BOX2(str asis) bar BAR2(str asis) boffset(str)   /// 
    tufte TUFTE2(str asis)                                             ///
	iqr IQR2(numlist >0 max=1) PCTile(numlist >=0 <=100 max=1)         ///
    WHiskers(str asis) medianbar(str asis) OUTside OUTside2(str asis)  ///
    CUMULate CUMULative CUMPRob                                        ///
	PLOT(str asis) ADDPLOT(str asis) variablelabels SEParate(varname)  ///
	REFline REFline2(str) reflevel(str) reflinestretch(real 0.05)      ///
	refvar(varname) * ] 

	// parse options 
	if "`fraction'" != "" {
		di as inp "fraction()" as txt ": please use " as inp "height()"
		capture confirm num `fraction' 
		if _rc { 
			di as err "fraction() invalid {c -} invalid number"
			exit 198 
		}
		local height = `fraction' 
	} 	
	
	if "`floor'" != "" & "`ceiling'" != "" { 
		di as err "must choose between floor and ceiling"
		exit 198 
	}	

	if `"`box'`box2'"' != "" & `"`bar'`bar2'"' != "" { 
		di as err "may not combine bar and box"
		exit 198 
	}	

	if `"`box'`box2'"' != "" & `"`tufte'`tufte2'"' != "" { 
		di as err "may not combine box and tufte"
		exit 198 
	}	

	if `"`tufte'`tufte2'"' != "" & `"`bar'`bar2'"' != "" { 
		di as err "may not combine bar and tufte"
		exit 198 
	}	

	if `"`box'`box2'"' != "" & `"`bar'`bar2'"' != "" & `"`tufte'`tufte2'"' != "" { 
		di as err "may not combine bar, box, and tufte"
		exit 198 
	}	

	if `"`bar2'"' != "" { 
		local 0 , `bar2' 
		local opts `options'
		local vars `varlist' 
		local ifspec `if' 
		local inspec `in' 

		syntax [ , Level(int `c(level)') Poisson Binomial    ///
		EXAct WAld Agresti Wilson Jeffreys Exposure(varname) ///
		mean(str asis) * ]

		local ciopts level(`level') `poisson' `binomial' `exact' ///
		`wald' `agresti' `wilson' `jeffreys' 
		local baropts `options' 
		local meanopts `mean' 
		local options `opts'
		local varlist `vars' 
		local if `ifspec' 
		local in `inspec' 
	}

	if "`cumulative'" != "" local cumulate "cumulate" 

	if "`cumulate'" != "" & "`stack'" != "" { 
		di as err "may not combine cumulate and stack options" 
		exit 198 
	} 

	if `"`outside'`outside2'"' != "" { 
		if `"`iqr'`iqr2'"' == "" & "`pctile'" == "" { 
			di as err "may not specify outside options without iqr or pctile options" 
			exit 198 
		}
	}
	
	if "`iqr'`iqr2'" != "" { 
		if "`pctile'" != "" {
			local which = cond("`iqr2'", "iqr()", "iqr") 
			di as err "may not combine `which' and pctile() options" 			exit 198
		} 

		if  "`iqr2'" != "" { 
			local mult = `iqr2' 
		} 
		else local mult = 1.5
	} 

	local nprev = 0

	if `"`refline'`refline2'"' != "" {
		if "`reflevel'" != "" { 
			capture which _g`reflevel' 
			if _rc { 
				di as err "`reflevel'() not known as egen function" 
				exit 198 
			}
		}
		else local reflevel "mean" 
	}  

	tokenize `varlist' 
	local nvars : word count `varlist' 

	if `"`by'"' != "" { 
		gettoken by opts : by, parse(",") 
		gettoken comma opts : opts, parse(",") 

		local total "total" 
		if `: list total in opts' & `"`bar'`bar2'`box'`box2'`tufte'`tufte2'"' != "" { 
			di as err "by(, total) not supported with bar or box or tufte" 
			exit 198 
		}	
	}

	// data to use, including by() over() separate() options 
	if `nvars' == 1 marksample touse
	else marksample touse, novarlist 

	if "`by'`over'`separate'" != "" markout `touse' `by' `over' `separate', strok 
	quietly count if `touse' 
	if r(N) == 0 error 2000 
	
	local noover = "`over'" == ""
		
	quietly if `nvars' > 1 { 
		if "`over'" != "" { 
			di as err ///
			"over() may not be combined with more than one variable"
			exit 198
		}	
		else {
			// several variables are stacked into one
			// x axis shows `data' 
			// y axis shows _stack 
			preserve
			if "`variablelabels'" != "" { 
				forval i = 1/`nvars' { 
					local l : variable label ``i''
					local labels `"`labels' `i' `"`l'"'"'
				}
			} 	
			else forval i = 1/`nvars' {
           		local labels "`labels'`i' ``i'' "
	        }
			
			if "`by'" != "" { 
				local bylbl : value label `by' 
				if "`bylbl'" != "" { 
					tempfile bylabel 
					label save `bylbl' using `bylabel' 
				}
			}	

			if "`separate'" != "" { 
				local seplbl : value label `separate' 
				if "`seplbl'" != "" { 
					tempfile seplabel 
					label save `seplbl' using `seplabel'
				}
			}
		
			tempvar data copystack  
			foreach v of local varlist { 
				local stacklist "`stacklist' `v' `by' `exposure' `separate'" 
			}	
			stack `stacklist' if `touse', into(`data' `by' `exposure' `separate') clear
			drop if missing(`data')
			gen `copystack' = _stack  

			if `"`box'`box2'`tufte'`tufte2'"' != "" { 
				tempvar median loq upq yshow2 upper upper2 lower lower2 outer 
				egen `median' = median(`data'), by(`by' _stack) 
				egen `loq' = pctile(`data'), p(25) by(`by' _stack) 
				egen `upq' = pctile(`data'), p(75) by(`by' _stack) 
				if `"`tufte'`tufte2'"' != local pctile = 0 
	
				if "`iqr'`iqr2'" != "" { 
					egen `upper' = max(cond(`data' <= `upq' + `mult' * (`upq' - `loq'), `data', .)), by(`by' _stack) 
					egen `lower' = min(cond(`data' >= `loq' - `mult' * (`upq' - `loq'), `data', .)), by(`by' _stack) 
				}
				else if "`pctile'" != "" {
					if `pctile' == 0 | `pctile' == 100 { 
						egen `lower' = min(`data'), by(`by' _stack) 
						egen `upper' = max(`data'), by(`by' _stack) 
					} 
					else { 
						local high = max(100 - `pctile', `pctile') 
						local low = 100 - `high'  
						egen `lower' = pctile(`data'), p(`low') by(`by' _stack) 
						egen `upper' = pctile(`data'), p(`high') by(`by' _stack) 
					}
				}

				if `"`outside'`outside2'"' != "" { 
					gen `outer' = `data' if `data' < `lower' | `data' > `upper' 
				} 
	
				if "`iqr'`iqr2'`pctile'" != ""  { 
					replace `upper' = . if `upper' == `upq' 
					replace `lower' = . if `lower' == `loq' 
				}
			} 

			if `"`bar'`bar2'"' != "" { 
				tempvar mean group ul ll yshow2 
				gen `mean' = . 
				gen `ul'   = . 
				gen `ll'   = . 
				egen `group' = group(`by' _stack) 
				su `group', meanonly
				forval i = 1/`r(max)' { 
					ci `data' if `group' == `i', `ciopts' 
					replace `mean' = r(mean) if `group' == `i' 
					replace `ul' = r(ub) if `group' == `i' 
					replace `ll' = r(lb) if `group' == `i' 
				}
			}

			if `"`refline'`refline2'"' != "" { 
				if "`refvar'" != "" local ref "`refvar'"
				else { 
					tempvar ref 
					egen `ref' = `reflevel'(`data'), by(`by' _stack)
 				}

				tempvar left right 
				gen `left' = . 
				gen `right' = . 
			}
							
			if "`width'" != "" {
				if "`floor'" != "" {
					replace `data' = `width' * floor(`data'/`width')
				}
				else if "`ceiling'" != "" { 
					replace `data' = `width' * ceil(`data'/`width')
				}	
				else replace `data' = round(`data', `width') 
			}	
			
			label var `data' "`varlist'"
			label var _stack `" "' 

			if "`bylbl'" != "" { 
				do `bylabel' 
				label val `by' `bylbl' 
			}	

			if "`seplbl'" != "" { 
				do `seplabel' 
				label val `separate' `seplbl' 
			}	

			tempname stlbl
			label def `stlbl' `labels' 
	        label val _stack `stlbl'
			su _stack, meanonly 
			local range "`r(min)'/`r(max)'" 
			if "`stack'" != "" { 
				tempvar count
				sort `by' _stack `data' `separate', stable 
				by `by' _stack `data' : gen `count' = _n - 1  
				su `count', meanonly
				if "`centre'`center'" != "" { 
					by `by' _stack `data' : ///
					replace `count' = _n - (_N + 1)/2
				} 
				if r(max) > 0 { 
					replace _stack = _stack + `height' * `count' / r(max) 
				} 	
			}	

			if "`cumulate'" != "" { 
				tempvar count negstack 
				gen `negstack' = -_stack 
				sort `by' `negstack' `data' `separate', stable 

				if "`cumprob'" != "" { 
					by `by' `negstack' : gen `count' = (_n - 0.5)/_N 
				} 
				else by `by' `negstack' : gen `count' = _n  

				su `count', meanonly 

				if "`centre'`center'" != "" { 
					if "`cumprob'" != "" { 
						by `by' `negstack' : replace `count' = `count' - 0.5 
					}
					else by `by' `negstack' : replace `count' = _n - (_N + 1)/2
				} 

				replace _stack = _stack + `height' * `count' / r(max) 
			} 

			local which "`copystack'" 
		}
	}	
	else quietly {
		preserve 
		keep if `touse' 

		if "`over'" == "" {
			// a single variable, no over()
			// x axis shows `varlist' 
			// y axis shows `over' = 1  
			tempvar over
			gen byte `over' = 1 
			tempname overlbl 
			label def `overlbl' 1 "`varlist'"
			label val `over' `overlbl' 
		}
		else {
			// a single variable with over()
			// x axis shows `varlist' 
			// y axis shows `over' (or `overcount' if stack option)
			tempvar over2
			capture confirm numeric variable `over'
			if _rc == 7 { 
				encode `over', gen(`over2')
			}	
			else { 
				gen `over2' = `over' 
				label val `over2' `: value label `over'' 
			} 	
			_crcslbl `over2' `over' 
			local over "`over2'"

			capture levelsof `over' 
			if _rc { 
				su `over', meanonly 
				local range "`r(min)'/`r(max)'" 
			} 
			else local range "`r(levels)'" 
		}

		if `"`box'`box2'`tufte'`tufte2'"' != "" { 
			tempvar median loq upq yshow2 upper lower outer 
			egen `median' = median(`varlist'), by(`by' `over') 
			egen `loq' = pctile(`varlist'), p(25) by(`by' `over') 
			egen `upq' = pctile(`varlist'), p(75) by(`by' `over') 
			if `"`tufte'`tufte2'"' != "" local pctile = 0 

			if "`iqr'`iqr2'" != "" { 
				egen `upper' = max(cond(`varlist' <= `upq' + `mult' * (`upq' - `loq'), `varlist', .)), by(`by' `over') 
				egen `lower' = min(cond(`varlist' >= `loq' - `mult' * (`upq' - `loq'), `varlist', .)), by(`by' `over') 
			}
			else if "`pctile'" != "" {
				if `pctile' == 0 | `pctile' == 100 { 
					egen `lower' = min(`varlist'), by(`by' `over') 
					egen `upper' = max(`varlist'), by(`by' `over') 
				} 
				else { 
					local high = max(100 - `pctile', `pctile') 
					local low = 100 - `high'  
					egen `lower' = pctile(`varlist'), p(`low') by(`by' `over') 
					egen `upper' = pctile(`varlist'), p(`high') by(`by' `over') 
				}
			}

			if `"`outside'`outside2'"' != "" { 
				gen `outer' = `varlist' if `varlist' < `lower' | `varlist' > `upper' 
			} 

			if "`iqr'`iqr2'`pctile'" != "" { 
				replace `upper' = . if `upper' == `upq' 
				replace `lower' = . if `lower' == `loq' 
			}
		} 

		if `"`bar'`bar2'"' != "" { 
			tempvar mean group ul ll yshow2
			gen `mean' = . 
			gen `ul'   = . 
			gen `ll'   = . 
			egen `group' = group(`by' `over') 
			su `group', meanonly
			forval i = 1/`r(max)' { 
				ci `varlist' if `group' == `i', `ciopts' 
				replace `mean' = r(mean) if `group' == `i' 
				replace `ul' = r(ub) if `group' == `i' 
				replace `ll' = r(lb) if `group' == `i' 
			}
		}

		if `"`refline'`refline2'"' != "" {
			if "`refvar'" != "" local ref "`refvar'" 
			else {  
				tempvar ref 
				egen `ref' = `reflevel'(`varlist'), by(`by' `over') 
			}

			tempvar left right 
			gen `left' = . 
			gen `right' = . 
		}
	
		if "`width'" != "" { 
			tempvar rounded
			if "`floor'" != "" {
				gen `rounded' = `width' * floor(`varlist'/`width')
			}
			else if "`ceiling'" != "" { 
				gen `rounded' = `width' * ceil(`varlist'/`width')
			}	
			else gen `rounded' = round(`varlist', `width') 

			_crcslbl `rounded' `varlist' 
			local varlist "`rounded'" 
		} 	
	
		if "`stack'" != "" { 
			tempvar count overcount 
			sort `by' `over' `varlist' `separate', stable 
			by `by' `over' `varlist': gen `count' = _n - 1 
			su `count', meanonly
			if "`centre'`center'" != "" { 
				by `by' `over' `varlist' : ///
				replace `count' = _n - (_N + 1)/2 
			} 
			gen `overcount' = `over' 
			if r(max) > 0 { 
				replace `overcount' = `overcount' + `height' * `count' / r(max) 
			} 	
			_crcslbl `overcount' `over'
			label val `overcount' `: value label `over'' 
		} 

		if "`cumulate'" != "" { 
			tempvar count overcount negover 
			gen `negover' = -`over' 
			sort `by' `negover' `varlist' `separate', stable 

			if "`cumprob'" != "" {
				by `by' `negover': gen `count' = (_n - 0.5)/_N 
			}
			else by `by' `negover': gen `count' = _n  

			su `count', meanonly

			if "`centre'`center'" != "" { 
				if "`cumprob'" != "" { 
					by `by' `negover' : replace `count' = `count' - 0.5 
				} 
				else by `by' `negover': replace `count' = _n - (_N + 1)/2 
			} 

			gen `overcount' = `over' 
			if r(max) > 0 { 
				replace `overcount' = `overcount' + `height' * `count' / r(max) 
			} 	
			_crcslbl `overcount' `over'
			label val `overcount' `: value label `over'' 
		}
		
		local which "`over'" 
	}	

	// plot details 
	if "`boffset'" == "" { 
		if `"`bar'`bar2'"' != ""          local boffset = -0.2 
		else if `"`tufte'`tufte2'"' != "" local boffset = -0.1  
		else                              local boffset = 0 
	}	

	if `noover' local axtitle `" "' 
	else { 
		local axtitle : variable label `over' 
		if `"`axtitle'"' == "" local axtitle "`over'" 
	} 	

	if `nvars' > 1 local axtitle2 "`varlist'"
	else { 
		local axtitle2 `"`: var label `varlist''"' 
		if `"`axtitle2'"' == "" local axtitle2 "`varlist'" 
	}	

	if "`over'" != "" { 
		if "`stack'`cumulate'" != "" { 
			local yshow "`overcount'" 
			local xshow "`varlist'" 
		} 	
		else { 
			local yshow "`over'" 
			local xshow "`varlist'" 
		} 	
	}
	else {
		local yshow "_stack" 
		local xshow "`data'" 
	}

	local y = cond("`over'" != "", "`over'", "_stack") 
	local Y = cond("`over'" != "", "`over'", "`copystack'") 

	if `noover' & `nvars' == 1 local axlabel ", nolabels noticks nogrid" 
	else { 
		foreach r of num `range' { 
			local axlabel `axlabel' `r' `"`: label (`y') `r''"'  
		}	
		local axlabel `axlabel', ang(h)  
	}	
	
	su `yshow', meanonly
	local margin = cond(r(max) == r(min), 0.1, 0.05 * (r(max) - r(min)))
	local stretch "r(`= r(min) - `margin'' `= r(max) + `margin'')" 
	if "`vertical'" != "" local stretch "xsc(`stretch')" 
	else local stretch "ysc(`stretch')" 


	quietly if "`vertical'" != "" { 
		if `"`box'`box2'"' != "" { 
			gen `yshow2' = `Y' + `boffset' 
			if "`medianbar'" != "" { 
				local medianbar ///
		rbar `median' `median' `yshow2', barw(0.4) bcolor(none) blcolor(black) `medianbar' 
				local nprev = `nprev' + 1 
			}
			if "`iqr'`iqr2'`pctile'" != "" { 
				local whisk1 rspike `upq' `upper' `yshow2', lcolor(black) `whiskers' 
				local whisk2 rspike `loq' `lower' `yshow2', lcolor(black) `whiskers' 
				local nprev = `nprev' + 2 
			} 
			if `"`outside'`outside2'"' != "" { 
				local out scatter `outer' `yshow2', mcolor(black) `outside2' 
			} 

			local boxbar ///
		rbar `median' `loq' `yshow2', bfcolor(none) blcolor(black) barw(0.4) blwidth(medthin) `box2' ///
		|| rbar `median' `upq' `yshow2', bfcolor(none) blcolor(black) barw(0.4) blwidth(medthin) `box2' ///
		|| `medianbar' || `whisk1' || `whisk2' || `out' 
			local nprev = `nprev' + 2 
		}

		if `"`tufte'`tufte2'"' != "" { 
			gen `yshow2' = `Y' + `boffset' 

			local whisk1 rspike `upq' `upper' `yshow2', lcolor(black) `whiskers' 
			local whisk2 rspike `loq' `lower' `yshow2', lcolor(black) `whiskers' 
			local nprev = `nprev' + 2 

			local boxbar ///
			|| scatter `median' `yshow2', mcolor(black) ms(Dh) `tufte2' ///
		    || `whisk1' || `whisk2' 
			local nprev = `nprev' + 1 
		}

		if `"`bar'`bar2'"' != "" { 
			gen `yshow2' = `Y' + `boffset' 
			local boxbar rcap `ul' `ll' `yshow2', `baropts' || ///
			scatter `mean' `yshow2', `meanopts'   
			local nprev = `nprev' + 2 
		}

		if `"`refline'`refline2'"' != "" { 
			tempvar group 
			egen `group' = group(`by' `which') 
			su `group', meanonly 
			forval j = 1/`r(max)' { 
				su `yshow' if `group' == `j', meanonly 
				if "`stack'" != "" & "`center'`centre'" == "" { 
					local xmin = r(min) 
				} 
				else local xmin = r(min) - `reflinestretch' 
				local xmax = r(max) + `reflinestretch' 
				replace `left' = `xmin' if `group' == `j' 
				replace `right' = `xmax' if `group' == `j' 
			}

			local refcall pcspike `ref' `left' `ref' `right' ///
			, pstyle(p2) lc(gs8) lw(thin) `refline2' 
			local nprev = `nprev' + 1 
		}

		if "`separate'" != "" { 
			tempname stub 
			separate `xshow', by(`separate') gen(`stub') veryshortlabel 
			local xshow "`r(varlist)'" 
			local first = `nprev' + 1 
			local last = `first' + `: word count `xshow'' - 1 
			numlist "`first'/`last'" 
			local separate legend(order(`r(numlist)')) 
		}
		else local separate "legend(off)" 

		if "`by'" != "" { 
			if "`separate'" == "" local separate "legend(off)" 

			local legoff 0 
			foreach o in leg lege legen legend { 
				local legoff = max(`legoff', strpos(`"`opts'"', "`o'(off)")) 
			} 
			if `legoff' local separate   

			if `noover' & `nvars' == 1 { 
				local byby by(`by', noixla noixtic `separate' `opts') xla(none)
			}
			else local byby by(`by', noixtic `separate' `opts')
			* local separate 
		}

		noisily twoway `refcall' || ///
		`boxbar' || ///     
		scatter `xshow' `yshow', pstyle(p1)    ///
		ms(Oh) xti(`"`axtitle'"') yti(`"`axtitle2'"')              /// 
		xla(`axlabel') `stretch' `byby' `separate' `options'      ///
		|| `plot' || `addplot' 
		// blank
 
		exit 0  
	} 	
	else quietly { 
		if `"`box'`box2'"' != "" { 
			gen `yshow2' = `Y' + `boffset' 
			if "`medianbar'" != "" { 
				local medianbar ///
		rbar `median' `median' `yshow2', barw(0.4) bcolor(none) blcolor(black) hor `medianbar' 
				local nprev = `nprev' + 1 
			}
			if "`iqr'`iqr2'`pctile'" != "" { 
				local whisk1 rspike `upq' `upper' `yshow2', lcolor(black) hor `whiskers' 
				local whisk2 rspike `loq' `lower' `yshow2', lcolor(black) hor `whiskers' 
				local nprev = `nprev' + 2 
			} 
			if `"`outside'`outside2'"' != "" { 
				local out scatter `yshow2' `outer', mcolor(black) `outside2' 
			} 

			local boxbar ///
			rbar `median' `upq' `yshow2', bfcolor(none) blcolor(black) barw(0.4) hor blwidth(medthin) `box2' ///
			|| rbar `median' `loq' `yshow2', bfcolor(none) blcolor(black) barw(0.4) hor blwidth(medthin) `box2' ///
			|| `medianbar' || `whisk1' || `whisk2' || `out' 
			local nprev = `nprev' + 2 
		}
 	
		if `"`tufte'`tufte2'"' != "" { 
			gen `yshow2' = `Y' + `boffset' 

			local whisk1 rspike `upq' `upper' `yshow2', lcolor(black) hor `whiskers' 
			local whisk2 rspike `loq' `lower' `yshow2', lcolor(black) hor `whiskers' 
			local nprev = `nprev' + 2 

			local boxbar ///
			|| scatter `yshow2' `median', mcolor(black) ms(Dh) `tufte2' ///
		    || `whisk1' || `whisk2' 
			local nprev = `nprev' + 1 
		}

		if `"`bar'`bar2'"' != "" { 
			gen `yshow2' = `Y' + `boffset' 
			local boxbar rcap `ul' `ll' `yshow2', hor `baropts' ///
			|| scatter `yshow2' `mean', `meanopts'
			local nprev = `nprev' + 2 
		}

		if `"`refline'`refline2'"' != "" { 
			tempvar group 
			egen `group' = group(`by' `over') 
			su `group', meanonly 
			forval j = 1/`r(max)' { 
				su `yshow' if `group' == `j', meanonly 
				if "`stack'" != "" & "`center'`centre'" == "" { 
					local xmin = r(min) 
				} 
				else local xmin = r(min) - `reflinestretch' 
				local xmax = r(max) + `reflinestretch' 
				replace `left' = `xmin' if `group' == `j' 
				replace `right' = `xmax' if `group' == `j' 
			}

			local refcall pcspike `left' `ref' `right' `ref' ///
			, lc(gs8) lw(thin) pstyle(p2) `refline2' 
			local nprev = `nprev' + 1 
		}

		if "`separate'" != "" { 
			tempname stub 
			separate `yshow', by(`separate') gen(`stub') veryshortlabel 
			local yshow "`r(varlist)'" 
			local first = `nprev' + 1 
			local last = `first' + `: word count `yshow'' - 1 
			numlist "`first'/`last'" 
			local separate legend(order(`r(numlist)')) 
		}
		else local separate "legend(off)"

		if "`by'" != "" {
			if "`separate'" == "" local separate "legend(off)"   

			local legoff 0 
			foreach o in leg lege legen legend { 
				local legoff = max(`legoff', strpos(`"`opts'"', "`o'(off)")) 
			} 
			if `legoff' local separate  

			if `noover' & `nvars' == 1 { 
				local byby ///
				"by(`by', noiyla noiytic `separate' `opts') yla(none)"
			} 
			else local byby "by(`by', noiytic `separate' `opts')" 

			* local separate 
		} 

		noisily twoway `refcall' || ///
		`boxbar' ||  ///
		scatter `yshow' `xshow', pstyle(p1)  ///
		ms(Oh) yti(`"`axtitle'"') xti(`"`axtitle2'"')             /// 
		yla(`axlabel') `stretch' `byby' `separate' `options'     /// 
		|| `plot' || `addplot'  
		// blank 
	} 	
end 	

/* 

	2.1.3 The -sort-s were all made -, stable-. This is important  
	when you want to add -mlabel()- and -mlabel()- contains 
	order-sensitive information e.g. on time of observation. 

*/ 

