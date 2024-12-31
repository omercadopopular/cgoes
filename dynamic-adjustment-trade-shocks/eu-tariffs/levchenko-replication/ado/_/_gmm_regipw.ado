*! version 1.0.0  17may2021
program _gmm_regipw, sortpreserve
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

	tempvar mup mub mub1 mub0 muw1 muw0 muatt Fx Fxc fx dy w0var	///
			tif wimp timenew gcount watt ty2
			
	tokenize `varlist'

	quietly generate double `ty2' = `ty'>0 `if' & `ty'!=.

	if ("`reg'"=="reg") {
	     local pscore "none"
	    if ("`csdid'"=="") {
			local bat  `1'
			local by1  `2'
			local by0  `3'
			quietly matrix score double `muatt'  = `at' `if', eq(#1) 
			quietly matrix score double `mub1'   = `at' `if', eq(#2) 
			quietly matrix score double `mub0'   = `at' `if', eq(#3) 
		}
		else {
		    local j = 1
		    local j = 2
			local bwatt `1'
			quietly matrix score double					///
					`watt' = `at' `if', eq(#1) 
		    forvalues i=1/`keq' {
			    tempvar muatt`i' mub1`i' mub0`i' if`i'
				local condnew: word `i' of  `condall'
			    local uno  = `j'
				local dos  = `j' + 1 
				local tres = `j' + 2
				local bat`i'  ``uno''
				local by1`i'  ``dos'' 
				local by0`i'  ``tres''
				quietly matrix score double					///
					`muatt`i'' = `at' `if', eq(#`uno') 
				quietly matrix score double					///
					`mub1`i''  = `at' `if', eq(#`dos') 
				quietly matrix score double					///
					`mub0`i''  = `at' `if', eq(#`tres')
			    local j = `tres' + 1 
				generate double `if`i'' = 0 
				replace `if`i'' = 1 `if' & `condnew'
			}
			forvalues i=1/`keq' {
			    tempvar wgt`i'
				local wb`i' ``j''
				quietly matrix score double `wgt`i'' = `at' `if', eq(#`j')
				local j = `j' + 1
			}
		}
	}
	else if ("`reg'"=="stdipw"|"`reg'"=="ipwra") {
		local bat  `1'
		local bt   `2'
		local by1  `3'
		local by0  `4'
		quietly matrix score double `muatt'  = `at' `if', eq(#1) 
		quietly matrix score double `mup'    = `at' `if', eq(#2) 
		quietly matrix score double `mub1'   = `at' `if', eq(#3) 
		quietly matrix score double `mub0'   = `at' `if', eq(#4) 
	}
	
	quietly {

		// Generating ancillary variables 
		
		if ("`csdid'"=="") {
			tempvar if0
			generate `timenew' = `timevar' `if'
			quietly summarize `timenew' `if'
			local t0c = r(min)
			bysort `groupvar' (`timenew'): ///
				generate double `dy'=`y'[2]-`y'[1] `if'
			quietly generate double `if0' = 0 
			quietly replace `if0'  = 1 if `dy'!=. & `timenew'==`t0c'
			local suma = 0 
		}
		else {
		    tempname ng 
			quietly egen double `gcount' = group(`groupvar')	///
					`if'
			quietly summarize `gcount' `if'
			scalar `ng' = r(max)
		}

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
			replace `bt' = `ty' - (`ty'==0)*exp(`mup') `if'
			generate double `Fx'    = logistic(`mup')
			generate double `Fxc'   = logistic(-`mup')	
		}
		
		if ("`pscore'"!="imp" & "`reg'"!="reg") {
			replace `bt'    =	///
				(`ty2'*`fx'/`Fx'- (1-`ty')*`fx'/`Fxc')*`if0' `if' 
		}
				
		if ("`reg'"==""|"`reg'"=="reg")  {
		    if ("`csdid'"=="") {
				replace `by1'   = (`ty2')*(`dy'-`mub1')*`if0' `if'
				replace `by0'   = (1-`ty2')*(`dy'-`mub0')*`if0' `if'
				replace `bat'   = ((`mub1' - `mub0') - `muatt')*`ty2'*`if0' `if'
			}
			else { 
			    tempname selw pesosf atetmat watet0 watets watetm suma
				scalar `suma' = 0 
				matrix `selw'   = `kappa'
			    forvalues i=1/`keq' {
				    tempvar dy`i' touse3 touse0 touse4 timenew`i'	///
						if0 peso`i' sume cuenta`i' muattw`i' otro`i'  otro2`i'
					local condtwo: word `i' of `condall'
					_Dy_Touse, touse0(`touse0')			///
							   touse3(`touse3') 		///
							   condtwo(`condtwo')		///
							   timevar(`timevar')		///
							   timenew(`timenew`i'')	///
							   touse4(`touse4')			///
							   y(`y')					///
							   dy(`dy`i'')				///
							   if(`if')					///
							   groupvar(`groupvar')		///
							   if0(`if0')							   
					local if4 "`r(if4)'"
					local t0c = r(t0c)

					replace `by1`i''   = (`ty2')*(`dy`i''-`mub1`i'')*`touse4'
					replace `by0`i''   = (1-`ty2')*(`dy`i''-`mub0`i'')*`touse4'
					generate double `muattw`i'' = 	///
						(`mub1`i'' - `mub0`i'')*`ty2'*`touse4'
					replace `bat`i''   = `muattw`i'' - `muatt`i''*`ty2'*`touse4'
					generate `cuenta`i''  = (`if0')*(`ty'>0)*`touse4'  
					summarize `cuenta`i'' `if4' & `cuenta`i'', meanonly
					replace `cuenta`i'' = `cuenta`i''*r(N)/`ng'
					count `if4' & `ty'>0  & `timenew`i''==`t0c'
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
					replace `wb`i'' = ( `cuenta`i'' -  `wgt`i'') `if' 				
					matrix `pesosf' = nullmat(`pesosf'), r(mean)						
				}
				matrix `watet0' = . 
				mata: st_matrix("`watet0'", sum((st_matrix("`pesosf'")'):* ///
				(st_matrix("`selw'")'):*(st_matrix("`atetmat'")'))/	///
				sum((st_matrix("`pesosf'")'):*(st_matrix("`selw'")')))	
				scalar `watets' = `watet0'[1,1]
				generate double `watetm' =  `watets' `if'
				replace `bwatt' = (`watetm' - `watt') `if'
			}
		}
		else {
				generate double `muw0' = (1-`ty2')*`if0'*`Fx'/`Fxc' `if'
				replace `by1'          = (`ty2')*`if0'*(`dy'-`mub1') `if'
				replace `by0'          = (`muw0')*`if0'*(`dy'-`mub0') `if'
				replace `bat'          = ///
					((`mub1' - `mub0') - `muatt')*`if0'*`ty2' `if'
		}
	}

end

program define _Dy_Touse, rclass
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
