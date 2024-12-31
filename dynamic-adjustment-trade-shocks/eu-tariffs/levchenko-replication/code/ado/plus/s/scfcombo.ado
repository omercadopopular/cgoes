/*The data set should include the mm999-mm1 (the number of times each 
	observation is drawn for a given bootstrapping replicate).  Note that the 
	program expects the mm variables to be in the mm999-mm1 order, following the 
	SCF convention.  If you use weights in the estimation, include wt1b1-wt1b999 
	(the weights for each bootstrapping replicate) on the data file as well.
	The data set should include a variable called "rep" which takes on values 
	from 1 to 5, depending on the replicate corresponding to each observation.*/
	
program define scfcombo, eclass byable(recall) sort 
version 7.0
*set trace on

/*parse arguments*/
syntax varlist [if] [in] [aweight], [reps(integer 200) imps(integer 5) command(string) title(string)] 

/*The first part gives coefficients and imputation uncertainty*/
marksample touse
estimates clear

if "`title'" ~= "" {
             display "`title'"
}
display "Command: `command'"

tempname coefs VCE adj
tempvar e bcons
tempfile REPMST REPRES

parse "`varlist'", parse(" ")

local depv "`1'"
macro shift 1
local vl "`*'"

local vle "_cons"
local vli "`bcons'"

preserve 

quietly {
           		keep if `touse'
	      		save "`REPMST'" 
 			drop _all
			set obs 1
			gen byte `e'=.
			save "`REPRES'"
 
		}
		di in gr "(bootstrapping " _c
            parse "`vl'", parse(" ")

/*J indexes the number of imps; i indexes the number of independent variables.*/
		local j 1

		while `j'<=`imps' {
			capture quietly use "`REPMST'", clear 

                  cap quietly `command' `varlist' [`weight'`exp'] if rep==`j'
			local rc = _rc
			drop _all 
 			if (`rc'==0) {
				quietly set obs 1
				local i 1
				while "``i''"!="" {
					gen ``i''=_b[``i'']
					local i=`i'+1
				}
				gen `bcons'=_b[_cons]

                        quietly {

					append using "`REPRES'" 
                              save "`REPRES'", replace 
				}
				display "." _c
 				local j=`j'+1
			}
			else {
				display "*" _c
                        local j=`j'+1
			}
		}
	
            quietly mat accum `VCE' = `vl' `vli', dev nocons means(`coefs')
            mat colnames `coefs' = `vl' `vle'
 		mat rownames `VCE' = `vl' `vle'
		mat colnames `VCE' = `vl' `vle'
                        scalar `adj' = 1/(`imps'-1)
		mat `VCE' = `VCE' * `adj'

		 
		 
		noi di in gr ")"
		
        restore
		capture erase "`REPMST'"
		capture erase "`REPRES'"

	     
		  
*This part calculates the sampling variance;
marksample touse

display "Command: `command'"


tempname VCE2 adj adj2
tempvar e bcons
tempfile BOOTMST BOOTRES

parse "`varlist'", parse(" ")

local depv "`1'"
macro shift 1
local vl "`*'"

display "Estimating base model"
`command' `depv' `vl' [`weight'`exp'] if `touse' & rep == 1
local vle "_cons"
local vli "`bcons'"

preserve 

quietly {
/* adding weights and replicate indicators to keep statement.  Note that mm variables on weight dataset run from mm999-mm1, thus the backwards order. */
			keep if `touse' & rep == 1
                  keep `depv' `vl' wt1b1-wt1b`reps' mm`reps'-mm1
	      		save "`BOOTMST'" 
 			drop _all
			set obs 1
			gen byte `e'=.
			save "`BOOTRES'"
 
		}
		di in gr "(bootstrapping " _c
            parse "`vl'", parse(" ")

/*J indexes the number of reps; i indexes the number of independent variables.*/
		local j 1
		while `j'<=`reps' {
			quietly use "`BOOTMST'", clear 

/* next two statements create the bootstrap replicate from SCF values */

                   quietly keep if mm`j' < 1000 /*miss val are pos. infinity*/
 			 quietly expand mm`j'
                   quietly keep `depv' `vl' wt1b`j' 

                  if ("`weight'"=="aweight") {
                  cap quietly `command' `depv' `vl' [aw=wt1b`j']}
                  else { cap quietly `command' `depv' `vl'}

		      local rc = _rc 
			drop _all 
 			if (`rc'==0) {
				quietly set obs 1
				local i 1
				while "``i''"!="" {
					gen ``i''=_b[``i'']
					local i=`i'+1
				}
				gen `bcons'=_b[_cons]

                        quietly {

					append using "`BOOTRES'" 
					save "`BOOTRES'", replace
                            				}
				display ". mm`j' " _c
 				local j=`j'+1
			}
			else {
				display "*" _c
                        local j=`j'+1
			}
		}
	
        quietly mat accum `VCE2' = `vl' `vli', dev nocons 
		mat rownames `VCE2' = `vl' `vle'
		mat colnames `VCE2' = `vl' `vle'
		scalar `adj' = 1/(`reps'-1)
		mat `VCE2'=`VCE2'*`adj'
		
		*Combine the imputation and sampling variance
                        scalar `adj2'=(`imps'+1)/`imps'
		mat `VCE' =`adj2'*`VCE'
                        mat `VCE' = `VCE' + `VCE2'
		estimates post `coefs' `VCE', depname(`depv')

		noi di in gr ")"
		
            restore
		est repost, esample(`touse')
		

		capture erase "`BOOTMST'"
		capture erase "`BOOTRES'"

	      estimates display


end

*test;
*scfcombo netw age [aw = x42000], reps(200) imps(5) command(probit) 
*program drop scfcombo
