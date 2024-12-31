*! 1.0.1 NJC 20 February 2003 
* 1.0.0 NJC 24 January 2003 
program _gminutes
	version 8 
	
	gettoken type 0 : 0
	gettoken g 0 : 0
	gettoken eqs 0 : 0			/* "=" */
	gettoken paren 0 : 0, parse("() ")	/* "(" */
	gettoken time 0 : 0, parse("() ")
	gettoken paren 0 : 0, parse("(), ")	/* ")" */
	if `"`paren'"' != ")" { 
		error 198
	}

	confirm str var `time' 
	syntax [if] [in] [ , maxhour(int 24) ] 

	quietly {
		tempvar touse shour hour smin min 
		mark `touse' `if' `in'
		markout `touse' `time', strok  

		capture assert index(`time',":") if `touse' 
		if _rc { 
			di as err "missing colon(s) in `time'"
			exit 459 
		} 	
		else { 
			gen `shour' = ///
			substr(`time',1,index(`time',":")-1) if `touse' 
			gen `hour' = real(`shour') 
			
			count if mi(`hour') & `touse'
			if r(N) { 
				di as err "problematic characters in `time'" 
				exit 459
			} 	
			
			gen `smin' = substr(`time',index(`time',":")+1,.) 
		} 

		capture assert !index(`smin',":") if `touse' 
		if _rc { 
			di as err "too many colons in `time'"
			exit 459 
		} 	
		else { 
			gen `min' = real(`smin')
			
			count if mi(`min') & `touse' 
			if r(N) { 
				di as err "problematic characters in `time'" 
				exit 459
			} 	
		} 	

		capture assert `hour' >= 0 & `hour' < `maxhour' if `touse' 
		if _rc { 
			di as err "hour value(s) not 0 to `--maxhour'" 
			exit 459 
		} 

		capture assert `hour' == int(`hour') if `touse' 
		if _rc { 
			di as err "hours contain non-integer value(s)" 
			exit 459 
		} 	
		
		capture assert `min' >= 0 & `min' < 60 if `touse' 
		if _rc { 
			di as err "minute value(s) not 0 to 59" 
			exit 459 
		} 

		capture assert `min' == int(`min') if `touse' 
		if _rc { 
			di as err "minutes contain non-integer value(s)" 
			exit 459 
		}
		
		gen long `g' = `min' + `hour' * 60 if `touse' 	
	}	
end

