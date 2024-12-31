*! 1.0.0 NJC 20 Oct 1999  (STB-56: dm79)
program define matcorr
    version 6.0
    syntax varlist(numeric min=2) [if] [in] /* 
    */ [aweight fweight iweight pweight] , Matrix(str) [Covariance]
    marksample touse 
    qui count if `touse' 
    if r(N) == 0 { error 2000 } 
    local Nm1 = r(N) - 1

    mat ac `matrix' = `varlist' [`weight' `exp'] if `touse', noc d 
    mat `matrix' = `matrix' / `Nm1' 
    if "`covariance'" == "" { mat `matrix' = corr(`matrix') } 

    mat li `matrix', f(%10.4f) 
end

