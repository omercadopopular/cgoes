/*

This program generates a percentile (and its standard error) from the uncondtional distribution of a variable
from the Survey of Consumer Finances. The program can also generate the mean. 

In the SCF, an unbiased estimator for the parameter of interest is the average of
each of the five parameters within implicate.

Then the parameter's variance is the (implicate-weighted) combination of the
variability between implicates and the within-implicate variability given by the weighted bootstrap,
given by:
V = (m+1) / m * (implicate variance) + (replicate variance).

The program also report the degree of freedom for the t-test, following Barnard and Rubin (1999).
The stored confidence intervals also incorporate the correction for the degrees of freedom. 

Author: Charlie Rafkin, crafkin@nber.org
First Posted: January 2018
Last Updated: March 2018

*/

capture pr drop scfses 
pr define scfses, eclass
syntax varlist [if/] [pweight],  [p(string) NUMberdraws(integer 200) imp(int 5) impnm(string) repnm(string) repwt(string) ci(int 95) noDfcorr ]
     
    * p: percentile desired (must be a number between 0-100 or the string "mean". default is p(50), the median.                         
    * numberdraws: number of replicate draws, default is 200. 
    * imp: number of implicates, default is 5 (recommended). 
    * repnm: name of replicates, default is "mm."
    * repwt: name of replicate weight, default is "wt1b."
    * ci: desired confidence interval, default is 95%.

    qui {

        /***************************************/
        /* /\* set defaults if not invoked *\/ */
        /***************************************/
        if ("`impnm'" == "") local impnm = "rep"
        if ("`repnm'" == "") local repnm = "mm"
        if ("`repwt'" == "") local repwt = "wt1b"
        if ("`p'" == "") local p = 50

        /* determine the type of regression you are running */ 
        if ("`p'" != "mean") {
          local pctlstring = "q(`p')"
          local reg = "qreg" 
        }
        
        if ("`p'" == "mean") local reg = "reg"
        

        /*************************************************/
        /*       error checking + options implementation */
        /*************************************************/

        /********* print warnings  ********/          
        if ("`weight'" == "") di "WARNING: NO WEIGHTS INVOKED! THEY ARE HIGHLY RECOMMENDED!"
        if (`imp' != 5) di "WARNING: YOU SHOULD USE ALL 5 IMPLICATES!"
        
        /********* ensure that the requisite variables are all present ***********/ 
        foreach var in impnm repnm {
            capture d ``var''*
            local impnmname "implicate"
            local repnmname "replicate"

            if _rc > 0 {
              noisily display as error "ERROR: you didn't specify the ``var'name' variable properly!"
              exit 111
            }
          }

        if "`weight'" != "" { 
            capture d `repwt'*
            local repwtname "replicate weights"

            if _rc > 0 {
              noisily display as error "ERROR: you didn't specify the ``var'name' variable properly!"
              exit 111
            }
          }

        
        /********* ensure that the percentile option is specified correctly ********/
        capture confirm number `p'
        if _rc > 0 {

          if "`p'" != "mean" {
             noisily display as error `" ERROR: the percentile was not specified correctly. It must either be a number between 0 or 100, or the string "mean." "'
             exit 111 
          }
        }
          else {
            if (`p' <= 0 | `p' >= 100) == 1 {
              noisily display as error `" ERROR: the percentile was not specified correctly. It must either be a number between 0 or 100, or the string "mean." `p' does not lie between 0 and 100. "'
              exit 111             
            }

          }          

        /***********************************/
        /* ready the data for analysis ****/ 
        /**********************************/

          /******** store the data for later: need two copies *********/
          noisily di "preparing the dataset"        
          preserve
        
          if "`if'" == "" { 
            tempfile predata
            save `predata' 
          }
        
        
        /******* implement the "if" condition *********/
        /* hack: pull the if into a convenient new macro for the end of the conditionals we have to apply already */
        if "`if'" != "" {
         
          /* note: because the bootstraps requires reloading the dataset 
          it is more efficient to drop variables and then reload the dataset. */            
              keep if `if'
          
              tempfile predata 
              save `predata', replace
          
          /* set up the local macros for later use */ 
          local ifcondition = " & `if'"
          local ifconditiondof = "if `if'" 
        }
        
        /**********************************************/
        /* /\*       generate imputation variability *\/ */
        /**********************************************/

        /* display */ 
        noisily display "obtaining point estimates and imputation variability"
        
        /* /\* get the total number of degrees of freedom in the dataset *\/  */
        count `ifconditiondof'
        local vcom = `r(N)'/5 - 2 

        /* initialize the average */ 
        local conssum = 0
        local depvar: word 1 of `varlist'
        
        /********** compute the regression for each implicate ********/
        forv i = 1/`imp' { 

             `reg' `depvar' [`weight'`exp'] if `impnm' == `i' `ifcondition', `pctlstring'

             /* get the point estimate */ 
               local cons`i' = _b[_cons]
               local conssum = `conssum' + `cons`i'' 
        }

        /* generate the mean constant and imputatoin  */
        local meancons = (`conssum') / `imp'

        /************ generate the imputation variability **************/

        /* initialize the imputation variability */ 
        local imputsum = 0 

        /* loop over all the implicates */
        forv i = 1/`imp' {

            local imputsum = `imputsum' + (`cons`i'' - `meancons')^2

        }

        /* store the imputation variability */ 
        local imputvar = `imputsum' / (`imp'-1)   // imp-1 is the denominator for the sample variance

        /***********************************************************/
        /* /\* generate the sampling variability of implicate #1 *\/  */
        /***********************************************************/

        noisily di "bootstrapping `numberdraws' draws to obtain sampling variability"
        
        /* initialize the average */
        local drawsum = 0       
        
        /******* conduct the bootstrap for the sampling variability ********/
        forv boot = 1/`numberdraws' {

                use `predata', clear 

                noisily _dots `boot' 0 

                        qui {
                          
                                /* drop observations if replicats are not drawn, and
                                simultaneously implement the same optional if condition */ 
                                keep if `repnm'`boot' < 1000 `ifcondition' & `impnm' == 1 

                                /* expand each observation as many times as it was drawn in the boostrap */ 
                                expand `repnm'`boot'

                                /* just keep the variable you want */
                                  if "`weight'" != "" {                                   
                                    local keepvars `depvar' `repwt'`boot'
                                  }
                                  else {
                                    local keepvars `depvar'
                                  }
                                
                                keep `keepvars' 

                                /* only invoke weights if it is called */
                                if "`weight'" != "" {
                                   local weightexp = "[`weight' = `repwt'`boot']"
                                }
                                else {
                                  local weightexp = ""                                
                                }
                                
                                /* generate the variable you want */
                                `reg' `depvar' `weightexp', `pctlstring' 

                                /* store the local variable */
                                local drawscons`boot' = _b[_cons]
                                local drawsum = `drawsum' + `drawscons`boot''

                        }

                
        }

        /******** compute and store the sampling variability **********/

        /* generate the mean of all the bootstraps */
        local numberdrawsmean = `drawsum'/`numberdraws'
        local imputsum = 0

        /* loop over all the repliccates */
        forv boot = 1/`numberdraws' {
                local imputsum = `imputsum' + (`drawscons`boot'' - `numberdrawsmean')^2
        }


        /* determine the within variability */
        local bootvar = `imputsum' / (`numberdraws' - 1) // `numberdraws' - 1 is the denominator for sample variance 

        /* add the two */
        local totalvar = ((`imp'+1) / `imp') * `imputvar' + `bootvar' // note that the "between" variance REQUIRES multiplying by (m + 1) / m

        /********************************************/
        /* /\* set-up post-estimation results *\/ */
        /********************************************/
        tempname mean variance

        /* set these up as matrices */
        mat `mean' = `meancons'
        matrix colnames `mean' = _cons
        mat rownames `mean' = `depvar' 

        mat `variance' = `totalvar'
        mat rownames `variance' = _cons 
        mat colnames `variance' = _cons

        /*******************************************************/
        /* /\* generate the degrees of freedom correction *\/  */
        /*******************************************************/          
        /********** see: Barnard and Rubin, Biometrika 1999, equation 3 for the full expression ********/

        /* recall that we obtained the total degrees of freedom in the complete data above, stored as vcom */
        /* gamma is the degrees of freedom if the sample were infinite */ 
        local gamma = (1 + `imp'^(-1)) * `imputvar'/`totalvar'

        /* now we combine this with the total degrees of freedom in the complete data */ 
        local lambda = (`vcom' + 1)/(`vcom'+3) * (1-`gamma') 
        local quotient = `vcom' /(`imp'-1)*(`gamma'^(2)) 
        local degrees = (`lambda'^(-1) + `quotient')^(-1) * `vcom'

        /************************************************/
        /* Prepare post-estimation results for user use */
        /************************************************/         
        /* if the DOF correction is turned off, just assume we have a large sample */ 
        if "`dfcorr'" != "" {
          local degrees = 10000000000
        }

        /* put into post-estimation results */ 
        ereturn post `mean' `variance', depname(`depvar') dof(`degrees')
        noisily di ""
        noisily ereturn display , level(`ci')

    }

end
