*! survbound v1.1.0 Long Hong 16Oct2016
capture program drop survbound
program define survbound, rclass
version 12
syntax varlist(max=1 numeric), THREShold(real) CENSORPCT(real) [GRID(integer 0)]


capture assert `varlist' > 0 
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

capture assert `censorpct' > 0 & `censorpct' < 1 
if c(rc) {
	display in red "Percentage of censoring must be in (0, 1)"
	exit 9
}

capture assert `grid' >= 0 
if c(rc) {
	display in red "Grid size must in a non-negative integer"
	display in yellow "A value 0 implies switching off grid-search function."
	exit 9
}

capture qui ssc install fastgini	// Install fastgini


*** Known parameters
local pi1 = `censorpct'
local pi2 = 1 - `censorpct'

qui sum `varlist' 
local mu2 = r(mean)

qui fastgini `varlist'
local G2 = r(gini)


****************** Analytic Gini Boundaries *******************************

tempname bound

local lower = (`mu2'*`pi2'*`pi2'*`G2' + `pi1'*`pi2'*(`mu2' - `threshold'))/(`threshold'*`pi1' + `mu2'*`pi2')
local upper = min(((`pi1'*`pi1'*`threshold')/(`threshold'*`pi1'+`mu2'*`pi2')) + `pi2'*`G2' + `pi1' , 1)

mat `bound' = (round(`lower', 0.00001), round(`upper', 0.00001))
matrix rownames `bound' = "Non-Parametric Gini"
matrix colnames `bound' = Lower(A) Upper(A) 

return scalar upper_a = `upper'
return scalar lower_a = `lower'

if `grid' == 0 {

display " "
display in yellow "Non-Parametric Gini Numeric Boundaries: "
matlist `bound', twidth(20) border(rows) rowtitle("")
display in blue "Lower(A): Analytic lower bound"
display in blue "Upper(A): Analytic upper bound"

}

****************** Grid-Search Gini Boundaries *****************************
else {

tempname gini_grid bound_grid max_grid upper_g 


local G1_increment  = (1-0)/(`grid') 
local G1_min = `G1_increment'
local G1_max = 1 - `G1_increment'
local mu1_increment = (`threshold' - 0)/(`grid')
local mu1_min = `mu1_increment'
local mu1_max = `threshold'


forvalues G1 = `G1_min'(`G1_increment')`G1_max' {
forvalues mu1 = `mu1_min'(`mu1_increment')`mu1_max' {
	
	local s1   = `mu1'*`pi1'/(`mu1'*`pi1'+`mu2'*`pi2')
	local s2   = `mu2'*`pi2'/(`mu1'*`pi1'+`mu2'*`pi2')
	local mu   = `mu1'*`pi1' + `mu2'*`pi2'
	local G_ks = `s1'*`pi1'*`G1'
	local G_kb = `s2'*`pi2'*`G2'
	local GB   = (`pi1'*`pi2'*(`mu2' - `mu1'))/`mu'
	local gini_total  = `G_ks' + `G_kb' + `GB'
	matrix `gini_grid' = (nullmat(`gini_grid') \ `gini_total')
	
  }
}

mata: st_matrix("`max_grid'", colmax(st_matrix("`gini_grid'")))
scalar `upper_g' = `max_grid'[1,1]
mat `bound_grid' = (round(`lower', 0.00001), round(`upper', 0.00001), round(`upper_g', 0.00001))
matrix rownames `bound_grid' = "Non-Parametric Gini" 
matrix colnames `bound_grid' = Lower(A) Upper(A) Upper(G) 

display " "
display in blue "Non-Parametric Gini Numeric Boundaries: "
matlist `bound_grid', twidth(20) border(rows) rowtitle("")

display in blue "Lower(A): Analytic lower bound"
display in blue "Upper(A): Analytic upper bound"
display in blue "Upper(G): Upper bound approximation by Grid-search"

return scalar upper_g  = `max_grid'[1,1]
return scalar upper_a = `upper'
return scalar lower_a = `lower'

}


end

