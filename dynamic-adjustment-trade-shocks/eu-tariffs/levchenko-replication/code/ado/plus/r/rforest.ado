capture program drop rforest

program define rforest, eclass
*! version 1.6  September, 2019
	version 15.0
	
	syntax varlist(min=2) [if] [in] [,type(string) ITERations(int 100) ///
							Seed(int 1) Depth(int 0) LSize(int 1) ///
							Variance(real 0.049787) NUMDECimalplaces(int 5) ///
							NUMVars(int 1)]
	
	ereturn clear
	return clear
	sreturn clear
	
    local flag = 0

    foreach v of varlist `varlist' {
        capture confirm numeric variable `v'
		if _rc {
		    di as error "Error: Variable `v' is not numeric"
			local flag = 1
	    }
	}

	if (`flag'==1) {
	    exit 108
    }	
	
	if (`variance' < 0){
		di as error "Error: variance incorrectly specified"
		exit 198
	}
	
	if (`iterations' <= 0 | `depth' < 0 | ///
	    `lsize' < 1 | `numdecimalplaces' < 1 | `numvars' < 1){
		di as error "Error: iterations, depth or numvars incorrectly specified"
		exit 198
	}
	
	// varlist includes y
	local count: word count `varlist'
	if (`numvars'> `count'-1) {
		di as error "Error: numvars argument specifies more x-variables than are available"
		exit 198
	}
	
	quietly count
	local obs = r(N)
	if (`obs' <= 1) {
		di as error "Error: number of observations cannot be less than 2"
		exit 198
	}
	
	if ("`type'" != "reg" && "`type'" != "class"){
		di as error "Specify one of 'type(class)' or 'type(reg)'"
		exit 198
	}
	
	// check that y does not have missing values
	local y=word("`varlist'",1)
	qui count if missing(`y')
	if (r(N)>0) {
		di as error "The dependent variable `y' contains missing values"
		exit 416  // missing value encountered in variable
	}
											 						 
	marksample touse , novarlist
	qui count if `touse'
	if (r(N)<1) {
		di as error "There are no observations"
		exit 2000
	}
	
	if ("`type'" == "class"){
		quietly count
		local obs = r(N)
		forvalues i = 1/`obs'{
			if (`1'[`i'] < 0){
				di as error "Error: Class values cannot be negative."
				exit 107
			}
		}
		quietly levelsof `1', c
		local classlist = r(levels)
		scalar numClasses = 0
		javacall RF initUniqueClasses, args(classlist) jars(randomforest.jar weka.jar)
		foreach value of local classlist {
			scalar numClasses = numClasses + 1
			local t : label (`1') `value'
			javacall RF parseClassesString, args(t) jars(randomforest.jar weka.jar)
		}
	}
	
	javacall RF RFModel `varlist' `if' `in', args(`iterations' `seed' `depth' `lsize' `variance' `numdecimalplaces' `numvars' `type') jars(randomforest.jar weka.jar)
	ereturn scalar Observations = observations
	ereturn scalar features = attributes
	ereturn scalar Iterations = `iterations'
	if ("`type'" == "reg"){
		ereturn local model_type = "random forest regression"
	} 
	else {
		ereturn local model_type = "random forest classification"
	}
	ereturn local depvar "`1'"
	ereturn local predict "randomforest_predict"
	ereturn local cmd "rforest"
	ereturn scalar OOB_Error = OOB
	ereturn matrix importance = VariableImportance
	
end
