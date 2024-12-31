*! version 1.0.0  17may2021
program _gmm_dripw, sortpreserve
	version 17
	syntax varlist if [fweight iweight pweight],			///
						at(name)                            ///
						ty(string)							///
						y(string)							///
						timevar(string)						///					
						groupvar(string)					///
						[									///
						pscore(string)						///
						t0(string)							///	
						reg(string)							///
						csdid								///
						keq(integer 1)						///
						condall(string)						///
						kappa(string)						///
						*                                   ///
						]

	tempvar mup mub muw1 muw0 muatt Fx Fxc fx dy w0var tif wimp	///
			timenew ty2 watt gcount mumt        

	tokenize `varlist'
	
	if ("`reg'"=="aipw") {
		local bat  `1'
		local bt   `2'	
	    local bmt  `3'
	}
	else {
	    if ("`csdid'"=="") {
			local bat  `1'
			local bt   `2'
			local by   `3'
			local bw0  `4'
			local bw1  `5'
		}
		else {
		    local j = 1
		    local j = 2
			local bwatt `1'
			quietly matrix score double					///
					`watt' = `at' `if', eq(#1)
		    forvalues i=1/`keq' {
			    tempvar mup`i' mub`i' muw1`i' muw0`i' muatt`i'
				local condnew: word `i' of  `condall'
			    local uno    = `j'
				local dos    = `j' + 1 
				local tres   = `j' + 2
				local cuatro = `j' + 3 
				local cinco  = `j' + 4 
				local bat`i'  ``uno''
				local bt`i'   ``dos''
				local by`i'   ``tres''
				local bw0`i'  ``cuatro''
				local bw1`i'  ``cinco''
				*local if`i' "`if' & `condnew'"
				quietly matrix score double					///
					`muatt`i'' = `at' `if', eq(#`uno') 
				quietly matrix score double					///
					`mup`i''  = `at' `if', eq(#`dos') 
				quietly matrix score double					///
					`mub`i''  = `at' `if', eq(#`tres')
				quietly matrix score double					///
					`muw0`i''  = `at' `if', eq(#`cuatro')
				quietly matrix score double					///
					`muw1`i''  = `at' `if', eq(#`cinco')
			    local j = `cinco' + 1 
			}
			forvalues i=1/`keq' {
			    tempvar wgt`i'
				local wb`i' ``j''
				quietly matrix score double `wgt`i'' = `at' `if', eq(#`j')
				local j = `j' + 1
				local nombres "`nombres' wgt`i' `wgt`i''"
				local nombres "`nombress' `wgt`i''"
			}
		}
	}
	if ("`reg'"=="imp") {
			    local pscore imp
	}
	quietly {
	    if ("`csdid'"=="") {
			if ("`reg'"=="aipw") {
				matrix score double `muatt'  = `at' `if', eq(#1) 
				matrix score double `mup'    = `at' `if', eq(#2) 		
				matrix score double `mumt'   = `at' `if', eq(#3) 
			}
			else {
				matrix score double `muatt'  = `at' `if', eq(#1) 
				matrix score double `mup'    = `at' `if', eq(#2) 
				matrix score double `mub'    = `at' `if', eq(#3) 
				matrix score double `muw0'   = `at' `if', eq(#4) 
				matrix score double `muw1'   = `at' `if', eq(#5) 
			}
		}
		// Generating ancillary variables 
		
		generate double `ty2' = `ty' 
		replace `ty2' = 1 if `ty'>0 & `ty'!=.
		
		if ("`csdid'"=="") {
		    tempvar if0 ift0
			generate `timenew' = `timevar' `if'
			summarize `timenew' `if'
			local t0c = r(min)
			bysort `groupvar' (`timenew'): generate double `dy'=	///
				`y'[2]-`y'[1] `if'
			quietly generate `if0' = 0 
			quietly replace `if0'  = 1 if `dy'!=. & `timenew'==`t0c'
			generate double `ift0' = 0 
			replace `ift0' = 1 if  `timenew'==`t0c'
			*local if "`if' & `if0'"
			local suma = 0 
		}
		else {
		    tempname ng 
			quietly egen double `gcount' = group(`groupvar')	///
					`if'
			quietly summarize `gcount' `if'
			scalar `ng' = r(max)
		}
	
		if ("`csdid'"=="") {
			if ("`pscore'"=="") {
				generate double `Fx'  = logistic(`mup')
				generate double `Fxc' = logistic(-`mup')
				generate double `fx'  = `Fx'/(1 + exp(`mup'))	
			}
			else if ("`pscore'"=="probit") {
				generate double `Fx'  = normal(`mup')
				generate double `Fxc' = normal(-`mup')
				generate double `fx'  = normalden(`mup') 
			}
			else if ("`pscore'"=="imp") {
				/*replace `bt' = `ty2' - (`ty2'==0)*exp(`mup')	///
					`if'  & `timenew'==`t0c'*/
				replace `bt' = (`ty2' - (`ty2'==0)*exp(`mup'))*`ift0' `if'	
				generate double `Fx'    = logistic(`mup')
				generate double `Fxc'   = logistic(-`mup')	
			}
		}
		else {
		    forvalues i=1/`keq' {
			    tempvar Fx`i' Fxc`i' fx`i'
				if ("`pscore'"=="") {
					generate double `Fx`i''  = logistic(`mup`i'')
					generate double `Fxc`i'' = logistic(-`mup`i'')
					generate double `fx`i''  = `Fx`i''/(1 + exp(`mup`i''))	
				}
				else if ("`pscore'"=="probit") {
					generate double `Fx`i''  = normal(`mup`i'')
					generate double `Fxc`i'' = normal(-`mup`i'')
					generate double `fx`i''  = normalden(`mup`i'') 
				}
		    }
		}
		
		if ("`csdid'"=="") {
			local tmd = 1 
			if ("`reg'"=="aipw") {
				*summarize `ty2' `if' & `timenew'==`t0c', meanonly 
				*local tmd = r(mean)
				replace `bmt'       = (`ty2' - `mumt')*`ift0' `if'
				local tmd "`mumt'"
			}
			generate double `w0var' = (`Fx' * (1-`ty2')/(`Fxc'))/`tmd' 
			generate double `wimp' = `w0var'
		}
		else {
			tempname selw pesosf atetmat watet0 watets watetm suma
			scalar `suma' = 0 
			matrix `selw'   = `kappa'
			if ("`reg'"=="aipw") {
				summarize `ty2' `if' & `timenew'==`t0c', meanonly 
				local tmd = r(mean)
			}
			forvalues i=1/`keq' {
				tempvar dy`i' touse3 touse0 touse4 timenew`i'	///
						if0 peso`i' sume cuenta`i' muattw`i' 	///
						otro`i'  otro2`i' w0var`i' wimp`i'
					local condtwo: word `i' of `condall'
					_Dy_Touse_Dripw, touse0(`touse0')			///
							   touse3(`touse3') 				///
							   condtwo(`condtwo')				///
							   timevar(`timevar')				///
							   timenew(`timenew`i'')			///
							   touse4(`touse4')					///
							   y(`y')							///
							   dy(`dy`i'')						///
							   if(`if')							///
							   groupvar(`groupvar')				///
							   if0(`if0')							   
					local if4 "`r(if4)'"
					local t0c = r(t0c)
					
				if ("`pscore'"=="imp") {
					replace `bt`i'' = 	///
					(`ty2' - (`ty2'==0)*exp(`mup`i''))*`touse4'
					generate double `Fx`i''    = logistic(`mup`i'') 
					generate double `Fxc`i''   = logistic(-`mup`i'') 	 
				}
				generate double `w0var`i'' =	///
						(`Fx`i'' * (1-`ty2')/(`Fxc`i''))*`touse4'
				generate double `wimp`i'' = `w0var`i''
				if ("`pscore'"!="imp") {
					replace `bt`i''    = (`ty2'*`fx`i''/`Fx`i''-		///
									  (1-`ty2')*`fx`i''/`Fxc`i'')*`touse4'  
					replace `wimp`i''  = 1 
				}
				replace `by`i''    = `wimp`i''*(1-`ty2')*(`dy`i''		///
									 -`mub`i'')*`touse4'
				replace `bw0`i''   = (`w0var`i'' - `muw0`i'')*`touse4'
				replace `bw1`i''   = (`ty2'   - `muw1`i'')*`touse4'
				replace `bat`i''   = ((`ty2'/`muw1`i''- 					///
									 `w0var`i''/`muw0`i'')*(`dy`i''		///
									 -`mub`i'') - `muatt`i'')*`touse4'
				generate `cuenta`i''  = (`if0')*(`ty2'>0)*`touse4' 
				summarize `cuenta`i'' `if4' & `cuenta`i'', meanonly
				replace `cuenta`i'' = `cuenta`i''*r(N)/`ng'
				count `if4' & `ty2'>0  & `timenew`i''==`t0c'
				scalar `sume'    = r(N)/`ng'
				scalar `suma'    = `suma' + `sume'
				scalar `peso`i'' = `sume'
				sum `muatt`i'' `if', meanonly
				matrix `atetmat' = nullmat(`atetmat'), r(mean)
			}
			forvalues i=1/`keq' {
				tempname n1 n2 
				replace `cuenta`i'' = `cuenta`i''/`suma' 
				summarize `cuenta`i'' `if', meanonly 
				scalar `n1' = r(N)
				summarize `cuenta`i'' `if' &  `cuenta`i''>0, meanonly 
				scalar `n2' = r(N)
				replace `cuenta`i'' = (`cuenta`i'')*(`n1'/`n2') `if'
				summarize  `cuenta`i'' `if', meanonly
				summarize  `wgt`i'' `if', meanonly	
				replace `wb`i'' = ( `cuenta`i'' -  `wgt`i'') `if' 				
				matrix `pesosf' = nullmat(`pesosf'), r(mean)	
				summarize  `wgt`i''  `cuenta`i'' `if'
			}
			matrix `watet0' = . 
			mata: st_matrix("`watet0'", sum((st_matrix("`pesosf'")'):* ///
			(st_matrix("`selw'")'):*(st_matrix("`atetmat'")'))/	///
			sum((st_matrix("`pesosf'")'):*(st_matrix("`selw'")')))	
			scalar `watets' = `watet0'[1,1]
			generate double `watetm' =  `watets' `if'
			replace `bwatt' = (`watetm' - `watt') `if'
		}
		
		// Compute scores 
		if ("`csdid'"=="") {
			if ("`pscore'"!="imp") {
				replace `bt'    = 	///
				(`ty2'*`fx'/`Fx'- (1-`ty2')*`fx'/`Fxc')*`ift0' `if' 
				replace `wimp'  = 1 
			}
			if ("`reg'"=="aipw") {
				replace `bat'   = 										///
					((`ty2'/`tmd'- `w0var')*(`dy') - `muatt')*`ift0'	///
					`if'    
			}
			else {
				replace `by'    = `wimp'*(1-`ty2')*(`dy'-`mub')*`ift0' `if'
				replace `bw0'   = (`w0var' - `muw0')*`ift0' `if'
				replace `bw1'   = (`ty2'    - `muw1')*`ift0' `if'
				replace `bat'   = 	///
					((`ty2'/`muw1'- `w0var'/`muw0')*(`dy'-`mub') 	///
						- `muatt')*`ift0' `if'   
			}
		}
	}

end

program define _Dy_Touse_Dripw, rclass
	syntax [anything],	[touse0(string)		///
						touse3(string) 		///
						condtwo(string)		///
						timevar(string)		///
						timenew(string)		///
						touse4(string)		///
						y(string)			///
						dy(string)			///
						if(string)			///
						groupvar(string)	///
						if0(string)			///
						]
								  	
	/*generate `touse0' = 0  
	replace `touse0'  = 1 `if'
	generate double `touse3' = .
	quietly replace `touse3' = `touse0' if `condtwo'
	local if3 "`if' & `condtwo'"
	generate `timenew' = `timevar' `if3'
	summarize `timenew' `if', meanonly 
	local t0c = r(min)
	bysort `groupvar' (`timenew'): egen `touse4' = ///
		min(`touse3')
	replace `touse3' = `touse4'*`touse3'
		bysort `groupvar' (`timenew'): ///
	generate double `dy'=`y'[2]-`y'[1]  if `touse3'==1
	generate `if0' = 0 
	replace  `if0'  = 1 `if' & `dy`i''!=. & `timenew'==`t0c'
	local if4 "`if3' & `if0'" 
	return local if4 "`if4'"
	return scalar t0c = `t0c'*/
		tempvar dytemp touse5 dyorig
	generate `touse0' = 0  
	replace `touse0'  = 1 `if'
	generate double `touse3' = .
	quietly replace `touse3' = `touse0' if `condtwo'
	local if3 "`if' & `condtwo'"
	generate `timenew' = `timevar' `if3'
	summarize `timenew' `if', meanonly 
	local t0c = r(min)
	bysort `groupvar' (`timenew'): egen `touse4' = ///
		min(`touse3')
	replace `touse3' = `touse4'*`touse3'
		bysort `groupvar' (`timenew'): ///
	generate double `dy'=`y'[2]-`y'[1]  if `touse3'==1
	generate `touse5' = 0 
	replace  `touse5' = 1 if `dy'!=.
	generate double `dyorig' = `dy'
	generate double `dytemp' = 0 
	replace `dytemp'         = `dy' if `dy'!=.
	generate `if0' = 0 
	replace  `if0'  = 1 `if' & `dy'!=. & `timenew'==`t0c'
	replace `dy'    = `dytemp'
	local if4 "`if3' & `if0'" 
	quietly replace `touse4'  = 0 
	quietly replace `touse4'  = 1 `if4'
	replace `touse3' = `touse5'
	return local if4 "`if4'"
	return scalar t0c = `t0c'
end
