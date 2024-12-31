*! survlsl v1.2.0 Long Hong 15Oct2017
	* This version only contains left censoring and left truncation
	* Arguments: income, threshold, model, censor/trunc, percentage (only for censor)
capture program drop survlsl
program define survlsl, rclass
version 12

syntax varlist(max=1 numeric), THREShold(real) CENSORPCT(real) MODEL(string asis)

marksample touse
qui count if `touse'
if `r(N)' == 0 {
	error 2000
}

*** Assert

capture assert `varlist' > 0 		// Varlist
if c(rc) {
	display in red "Observations must be > 0"
	exit 9
}

capture assert `varlist' != .
if c(rc) {
	display in red "No missing observation is allowed"
	exit 9
}


capture assert `threshold' > 0 		// Threshold
if c(rc) {
	display in red "Observations must be > 0"
	exit 9
}

qui sum `varlist'
local min = r(min)
capture assert `threshold' <= `min' 
if c(rc) {
	display in red "Threshold must be no larger than the smallest obversation"
	exit 9
}


capture assert "`model'" == "lognormal" | "`model'" == "weibull" | "`model'" == "loglogistic"   // Models
if c(rc) {
	display in red "Please select a proper model using the exact names:"
	display in blue "(1) lognormal (2) weibull (3) loglogistic "
	exit 9
}


capture assert `censorpct' >= 0 & `censorpct' < 1 	// Censor Percent
if c(rc) {
	display in red "Percentage of censoring must be in (0, 1)"
	display in blue "Value 0 implies 'truncated data' "
	exit 9
}



*** Programme

tempname k censor

if `censorpct' == 0 {
	
	qui gen `k' = `threshold'
	qui ml model lf `model'_lefttrunc (alpha: `varlist' = ) (beta: `k' = )
	ml maximize
	
	display " "
	display in yellow "Left Truncated Model"

}
else { 

	preserve 
	
	local newobs = round(_N/(1-`censorpct'), 1)
	qui set obs `newobs'
	qui gen `censor' = (`varlist' != .)
	qui replace `varlist' = `threshold' if `varlist' == .
	
	qui ml model lf `model'_leftcensor (alpha: `varlist' = ) (beta: `censor' = ) 
	ml maximize 
	
	restore
	
	display " "
	display in yellow "Left Censored Model"
}


*** Gini

local alpha_mle = [alpha]_cons
local beta_mle  = [beta]_cons

local gini_lognormal 	"2*normal(`beta_mle'/(sqrt(2)))-1"
local gini_weibull  	"1 - 2^(-1/`beta_mle')"
local gini_loglogistic 	"1/`beta_mle'"


*** Confidence Intervals

tempname table
mat `table' = r(table)
local beta_sd  = `table'[2,2]	// S.D. for beta

local lognormal_fd 		"sqrt(2)*normalden(`beta_mle'/(sqrt(2)))"
local weibull_fd 		"`beta_mle'^(-2) * 2^(-(1/`beta_mle')) * ln(2)"
local loglogistic_fd	"-`beta_mle'^(-2)"

local IC1_low  = `gini_`model'' - invnormal(0.975) * ``model'_fd' * `beta_sd'
local IC1_high = `gini_`model'' + invnormal(0.975) * ``model'_fd' * `beta_sd'

local IC2_high_lognormal 	= 2*normal((`beta_mle' + invnormal(0.975)*`beta_sd')/sqrt(2)) - 1
local IC2_low_lognormal  	= 2*normal((`beta_mle' - invnormal(0.975)*`beta_sd')/sqrt(2)) - 1
local IC2_low_weibull  		= 1 - 2^(-(1/(`beta_mle' - invnormal(0.975)*`beta_sd')))
local IC2_high_weibull 		= 1 - 2^(-(1/(`beta_mle' + invnormal(0.975)*`beta_sd')))
local IC2_low_loglogistic  	= 1/(`beta_mle' - invnormal(0.975)*`beta_sd')
local IC2_high_loglogistic 	= 1/(`beta_mle' + invnormal(0.975)*`beta_sd')

tempname ic

mat `ic' = (round(`IC1_low', 0.00001), round(`IC1_high', 0.00001) \ round(`IC2_low_`model'', 0.00001), round(`IC2_high_`model'', 0.00001))
matrix rownames `ic' = "Conf Interval 1" "Conf Interval 2"
matrix colnames `ic' = "Lower" "Upper"


*** Display 

display " "
display in blue "Estimated Parameters: "

if "`model'" == "lognormal" {
	display in blue " MLE location  = " round(`alpha_mle', 0.00001)
	display in blue " MLE scale     = " round(`beta_mle', 0.00001)
}
else {
	display in blue " MLE scale  = " round(`alpha_mle', 0.00001)
	display in blue " MLE shape  = " round(`beta_mle', 0.00001)
}
display ""

display in yellow "Parametric Gini = " round(`gini_`model'', 0.00001)

display " "
display in blue "Parametric Gini 95% Confidence Interval: "
display in blue "C.I. 1 is derived from the delta method;" 
display in blue "C.I. 2 is derived from a direct approach."
matlist `ic', twidth(15) border(rows) rowtitle("")


*** Saved Estimates
tempname b V 

return scalar beta  = [beta]_cons
return scalar alpha = [alpha]_cons
return scalar gini  = `gini_`model''

mat `b' = (`alpha_mle', `beta_mle')
matrix rownames `b' = "MLE" 
matrix colnames `b' = alpha beta

local alpha_sd   = `table'[2,1]
local beta_sd    = `table'[2,2]

mat `V' = (`alpha_sd', `beta_sd')
matrix rownames `V' = Std_Dev
matrix colnames `V' = alpha beta

return matrix conf_interval = `ic'
return matrix variances = `V'
return matrix estimates = `b'


end

