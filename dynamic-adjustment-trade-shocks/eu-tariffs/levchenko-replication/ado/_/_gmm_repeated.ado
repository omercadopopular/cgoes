*! version 1.0.0  17may2021
program _gmm_repeated, sortpreserve
	version 17
	syntax varlist if [fweight iweight pweight],			///
						at(name)                            ///
						ty(string)							///
						y(string)							///
						timevar(string)						///					
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

	tempvar  mup muatt Fx Fxc fx timenew ty2 w11 w10 w01 w00 	///
			 y11 y10 y00 y01 tmt mupi muld muy00 muy01 muy10 	///
			 muy11 muw11 muw10 muw01 muw00 muw1
			 
	tempname pi lambda 

	tokenize `varlist'
	
	if ("`reg'"=="aipw") {
		local bat  `1'
		local bt   `2'		
		local bpi  `3'
		local bld  `4'
	}
	if ("`reg'"=="reg") {
		local bat  `1'
		local b00  `2'		
		local b01  `3'
		local bw10 `4'
		local bw11 `5'
		local bw1  `6'
	}
	if ("`reg'"=="dripw"|"`reg'"=="imp") {
		local bat  `1'
		local bt   `2'	
		local b00  `3'
		local b01  `4'
		local b10  `5'
		local b11  `6'
		local bw00 `7'
		local bw01 `8'
		local bw10 `9'
		local bw11 `10'
		local bw1  `11'
	}
	if ("`reg'"=="stdipw") {
		local bat  `1'
		local bt   `2'	
		local bw00 `3'
		local bw01 `4'
		local bw10 `5'
		local bw11 `6'
	}

	quietly {
		if ("`reg'"=="aipw") {
			matrix score double `muatt'  = `at' `if', eq(#1) 
			matrix score double `mup'    = `at' `if', eq(#2) 	
			matrix score double `mupi'   = `at' `if', eq(#3) 
			matrix score double `muld'   = `at' `if', eq(#4) 
		}
		
		if ("`reg'"=="dripw"|"`reg'"=="imp") {
			matrix score double `muatt'  = `at' `if', eq(#1) 
			matrix score double `mup'    = `at' `if', eq(#2) 	
			matrix score double `muy00'  = `at' `if', eq(#3) 
			matrix score double `muy01'  = `at' `if', eq(#4) 
			matrix score double `muy10'  = `at' `if', eq(#5) 
			matrix score double `muy11'  = `at' `if', eq(#6) 
			matrix score double `muw00'  = `at' `if', eq(#7) 
			matrix score double `muw01'  = `at' `if', eq(#8) 
			matrix score double `muw10'  = `at' `if', eq(#9) 
			matrix score double `muw11'  = `at' `if', eq(#10) 
			matrix score double `muw1'   = `at' `if', eq(#11) 
		}
		if ("`reg'"=="stdipw") {
			matrix score double `muatt'  = `at' `if', eq(#1) 
			matrix score double `mup'    = `at' `if', eq(#2) 	
			matrix score double `muw00'  = `at' `if', eq(#3) 
			matrix score double `muw01'  = `at' `if', eq(#4) 
			matrix score double `muw10'  = `at' `if', eq(#5) 
			matrix score double `muw11'  = `at' `if', eq(#6) 
		}		
		if ("`reg'"=="reg") {
			matrix score double `muatt'  = `at' `if', eq(#1) 	
			matrix score double `muy00'  = `at' `if', eq(#2) 
			matrix score double `muy01'  = `at' `if', eq(#3) 
			matrix score double `muw10'  = `at' `if', eq(#4) 
			matrix score double `muw11'  = `at' `if', eq(#5) 
			matrix score double `muw1'   = `at' `if',  eq(#6) 
		}
		
		// Generating ancillary variables 
		
		generate double `ty2' = `ty' 
		replace `ty2' = 1 if `ty'>0 & `ty'!=.
		generate `timenew' = `timevar' `if'
		quietly summarize `timenew' `if'
		local ttrt = r(max)
		generate double `tmt' = `timenew'==`ttrt' `if'
		
		if ("`reg'"!="reg") {
			if ("`pscore'"==""|"`pscore'"=="logit") {
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
				replace `bt' = (`ty2' - (`ty2'==0)*exp(`mup')) `if'	
				generate double `Fx'    = logistic(`mup')
				generate double `Fxc'   = logistic(-`mup')	
			}
		}
		
		if ("`reg'"=="aipw") {
				generate double `w11' = `ty2'*(`tmt')
				generate double `w10' = `ty2'*(1-`tmt')
				generate double `w01' = `Fx'*(1-`ty2')*(`tmt')/(`Fxc')
				generate double `w00' = `Fx'*(1-`ty2')*(1-`tmt')/(`Fxc')
				
				mean  `ty2' `if'
				scalar `pi'         =  e(b)[1,1]
				replace `bpi'   = `ty2' - `mupi' `if'  
				mean   `tmt' `if'
				scalar `lambda'		=  e(b)[1,1]
				replace `bld'       = `tmt' - `muld' `if'

				generate double `y11' = `w11'*`y'/(`mupi'*`muld')
				generate double `y10' = `w10'*`y'/(`mupi'* (1-`muld') )
				generate double `y01' = `w01'*`y'/(`mupi'*`muld' )
				generate double `y00' = `w00'*`y'/(`mupi'* (1-`muld') )
		}
		
		// Compute scores 
			if ("`pscore'"!="imp" & "`reg'"!="reg") {
				replace `bt'    = 	///
				(`ty2'*`fx'/`Fx'- (1-`ty2')*`fx'/`Fxc') `if' 
			}
			if ("`reg'"=="aipw") {
				replace `bat'   = (`y11'-`y10')-(`y01'-`y00') - `muatt' `if'  
			}
			if ("`reg'"=="dripw") {
				tempvar if00 if01 if10 if11 yh0 w1 y_1c y11c y_0c y10c
				
				generate `if00' = 0 
				replace  `if00' = 1 if `ty2'==0 & `tmt'==0
				generate `if01' = 0 
				replace  `if01' = 1 if `ty2'==0 & `tmt'==1
				generate `if10' = 0 
				replace  `if10' = 1 if `ty2'==1 & `tmt'==0
				generate `if11' = 0 
				replace  `if11' = 1 if `ty2'==1 & `tmt'==1

				replace `b00' = (`y' - `muy00')*`if00' `if'
				replace `b01' = (`y' - `muy01')*`if01' `if'
				replace `b10' = (`y' - `muy10')*`if10' `if'
				replace `b11' = (`y' - `muy11')*`if11' `if'
				
				generate double `yh0' = `muy00'*(1-`tmt')+ `muy01'*`tmt' `if'
				generate double `w11' = `ty2'*(`tmt') `if'
				generate double `w10' = `ty2'*(1-`tmt') `if'
				generate double `w01' = `Fx'*(1-`ty2')*(`tmt')/(`Fxc') `if'
				generate double `w00' = `Fx'*(1-`ty2')*(1-`tmt')/(`Fxc') `if'
				generate double `w1'  = `ty2' `if'
		
				replace `bw00' = `w00' - `muw00' `if'
				replace `bw01' = `w01' - `muw01' `if'
				replace `bw10' = `w10' - `muw10' `if'
				replace `bw11' = `w11' - `muw11' `if'
				replace `bw1'  = `w1'  - `muw1'  `if'

				generate double `y10' = (`w10'/`muw10')*(`y' - `yh0') `if'
				generate double `y11' = (`w11'/`muw11')*(`y' - `yh0') `if'
				generate double `y00' = (`w00'/`muw00')*(`y' - `yh0') `if'
				generate double `y01' = (`w01'/`muw01')*(`y' - `yh0') `if'
		
				generate double `y_1c' = (`w1'/`muw1')*(`muy11'-`muy01')   `if'
				generate double `y11c' = (`w11'/`muw11')*(`muy11'-`muy01') `if'
				generate double `y_0c' = (`w1'/`muw1')*(`muy10'- `muy00')  `if'
				generate double `y10c' = (`w10'/`muw10')*(`muy10'-`muy00') `if'
				
				replace `bat'   =  (`y11' - `y10')   - (`y01' - `y00')		///
								 + (`y_1c' - `y11c') - (`y_0c' - `y10c') 	///
								 - `muatt'
			}
			if ("`reg'"=="imp") {
				tempvar if00 if01 if10 if11 yh0 w1 y_1c y11c y_0c y10c w0

				generate double `w11' = `ty2'*(`tmt') `if'
				generate double `w10' = `ty2'*(1-`tmt') `if'
				generate double `w01' = `Fx'*(1-`ty2')*(`tmt')/(`Fxc') `if'
				generate double `w00' = `Fx'*(1-`ty2')*(1-`tmt')/(`Fxc') `if'
				generate double `w1'  = `ty2' `if'
				generate double `w0' = `Fx'*(1-`ty2')/(`Fxc') `if'
				
				generate `if00' = 0 
				replace  `if00' = 1 if `ty2'==0 & `tmt'==0
				generate `if01' = 0 
				replace  `if01' = 1 if `ty2'==0 & `tmt'==1
				generate `if10' = 0 
				replace  `if10' = 1 if `ty2'==1 & `tmt'==0
				generate `if11' = 0 
				replace  `if11' = 1 if `ty2'==1 & `tmt'==1

				replace `b00' = `w0'*(`y' - `muy00')*`if00' `if'
				replace `b01' = `w0'*(`y' - `muy01')*`if01' `if'
				replace `b10' = (`y' - `muy10')*`if10' `if'
				replace `b11' = (`y' - `muy11')*`if11' `if'
				
				generate double `yh0' = `muy00'*(1-`tmt')+ `muy01'*`tmt' `if'
		
				replace `bw00' = `w00' - `muw00' `if'
				replace `bw01' = `w01' - `muw01' `if'
				replace `bw10' = `w10' - `muw10' `if'
				replace `bw11' = `w11' - `muw11' `if'
				replace `bw1'  = `w1'  - `muw1'  `if'

				generate double `y10' = (`w10'/`muw10')*(`y' - `yh0') `if'
				generate double `y11' = (`w11'/`muw11')*(`y' - `yh0') `if'
				generate double `y00' = (`w00'/`muw00')*(`y' - `yh0') `if'
				generate double `y01' = (`w01'/`muw01')*(`y' - `yh0') `if'
		
				generate double `y_1c' = (`w1'/`muw1')*(`muy11'-`muy01')   `if'
				generate double `y11c' = (`w11'/`muw11')*(`muy11'-`muy01') `if'
				generate double `y_0c' = (`w1'/`muw1')*(`muy10'- `muy00')  `if'
				generate double `y10c' = (`w10'/`muw10')*(`muy10'-`muy00') `if'
				
				replace `bat'   =  (`y11' - `y10')   - (`y01' - `y00')		///
								 + (`y_1c' - `y11c') - (`y_0c' - `y10c') 	///
								 - `muatt'
			}
			if ("`reg'"=="stdipw") {
				generate double `w11' = `ty2'*(`tmt') `if'
				generate double `w10' = `ty2'*(1-`tmt') `if'
				generate double `w01' = `Fx'*(1-`ty2')*(`tmt')/(`Fxc') `if'
				generate double `w00' = `Fx'*(1-`ty2')*(1-`tmt')/(`Fxc') `if'
		
				replace `bw00' = `w00' - `muw00' `if'
				replace `bw01' = `w01' - `muw01' `if'
				replace `bw10' = `w10' - `muw10' `if'
				replace `bw11' = `w11' - `muw11' `if'
				replace `bat'  = ((`w11'/`muw11')*`y' - 		///
								(`w10'/`muw10')*`y')  -			///
								((`w01'/`muw01')*`y'  -			///
								(`w00'/`muw00')*`y')  - `muatt'
			}
			if ("`reg'"=="reg") {
				tempvar if00 if01 if10 if11 yh0 w1 y_1c y11c y_0c y10c
				
				generate `if00' = 0 
				replace  `if00' = 1 if `ty2'==0 & `tmt'==0
				generate `if01' = 0 
				replace  `if01' = 1 if `ty2'==0 & `tmt'==1

				replace `b00' = (`y' - `muy00')*`if00' `if'
				replace `b01' = (`y' - `muy01')*`if01' `if'
				
				generate double `w11' = `ty2'*(`tmt') `if'
				generate double `w10' = `ty2'*(1-`tmt') `if'
				generate double `w1'  = `ty2' `if'
		
				replace `bw10' = `w10' - `muw10' `if'
				replace `bw11' = `w11' - `muw11' `if'
				replace `bw1'  = `w1'  - `muw1'  `if'

				generate double `y10' = (`w10'/`muw10')*(`y') `if'
				generate double `y11' = (`w11'/`muw11')*(`y') `if'
				generate double `y00' = (`w1'/`muw1')*(`muy00') `if'
				generate double `y01' = (`w1'/`muw1')*(`muy01')   `if'		
				
				replace `bat'   =  (`y11' - `y10')-(`y01' - `y00')	///
									-`muatt' `if'				
			}
	}

end
