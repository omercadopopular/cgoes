*! version 1.0,  Christine Cook, 1aug2014  

*define  program name and syntax
program define xtine
version 12.1
syntax varlist [if] [in], nq(integer) 

*generate if/in loop
marksample touse
quietly{
*gen percentile variables (using if/in statements)
if `touse'{
foreach var of local varlist{
tempvar `var'_count `var'_rank `var'_equal `var'_below
egen ``var'_count'=count(`var')
gsort `var' 
gen ``var'_rank'=_n
count  if `var'!=.
forvalues y=1/`r(N)'{
gsort -``var'_rank'
replace ``var'_rank'=``var'_rank'[_n-1] if `var'==`var'[_n-1] 
}
by ``var'_rank', sort: gen ``var'_equal'=_N if ``var'_rank'!=. 
gen ``var'_below'=(``var'_rank'-``var'_equal') 
gen `var'_pctile=(((``var'_below'+(.5*``var'_equal'))/``var'_count')*100) 
}
}

else{
foreach var of local varlist{
tempvar `var'_count `var'_rank `var'_equal `var'_below
egen ``var'_count'=count(`var')
gsort `var' 
gen ``var'_rank'=_n
count if `var'!=.
forvalues y=1/`r(N)'{
gsort -``var'_rank'
replace ``var'_rank'=``var'_rank'[_n-1] if `var'==`var'[_n-1] 
}
by ``var'_rank', sort: gen ``var'_equal'=_N if ``var'_rank'!=. 
gen ``var'_below'=(``var'_rank'-``var'_equal') 
gen `var'_pctile=(((``var'_below'+(.5*``var'_equal'))/``var'_count')*100) 
}
}

*gen quantiles
foreach var of local varlist{
gen `var'_pctile_`nq'=.
local range=(100/`nq')
local i=`nq'
forvalues x =1/`nq'{
replace `var'_pctile_`nq'=1 if (`var'_pctile==0 & `nq'==1) 
local j=(`i'-1)
replace `var'_pctile_`nq'=`x' if (`var'_pctile>(100-(`range'*`i'))) &  (`var'_pctile<= (100- (`range'*`j'))) 
local i=(`i'-1)
}
rename `var'_pctile_`nq' `var'_`nq'
}
}

end


















