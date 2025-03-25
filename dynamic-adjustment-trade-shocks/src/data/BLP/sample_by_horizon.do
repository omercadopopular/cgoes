* Cut full sample by horizons for the ease of use
version 14
clear

capture log close
log using log/sample_by_horizon.smcl, replace

global raw "lev/temp_files"
global work "data/work/BLP"
*global inputfile "DataregW_did.dta"
global inputfile "FillDataregW_did_N.dta"
global suf "_teti2"

local fe fe_imp_hs4_yr fe_exp_hs4_yr fe_imp_exp_hs4

forvalues h=0/10 {
    di "Reading data for horizon `h'"
    use panel_id year D`h'ln_trade_val D`h'ln_tariff iv_0_baseline `fe' ///
        if iv_0_baseline!=. & D`h'ln_trade_val!=. using $raw/$inputfile, clear

    save $work/data_horz`h'$suf.dta, replace
}

* Generate lags as in BLP
local D0vars D0ln_trade_val D0ln_tariff iv_0_baseline
use panel_id year `D0vars' if iv_0_baseline!=. using $raw/$inputfile, clear

xtset panel_id year
foreach v of local D0vars {
    gen L1`v' = L1.`v'
}
drop if L1D0ln_trade_val == .
drop `D0vars'

save $work/data_lag$suf.dta, replace

log close
