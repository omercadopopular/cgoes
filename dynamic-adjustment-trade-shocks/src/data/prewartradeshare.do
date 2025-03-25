* Prepare weights used for aggregating average tariff changes
version 14
clear

capture log close
log using log/prewartradeshare.smcl, replace

global iciodir = "data/work/ICIO"
global rtpdir = "data/Fajgelbaum"
global outdir = "data/work/shock"

use "$rtpdir/rtp/data/analysis/m_flow_hs10_fm_new.dta"

keep if year == 2017 & cty_code>0
collapse (sum) m_val (first) naics=naics_str, by(cty_code hs10)

save "$outdir/importweight.dta", replace

use "$rtpdir/rtp/data/analysis/x_flow_hs10_fm_new.dta", clear

keep if year == 2017 & cty_code>0
* The retaliatory tariffs are only at the HS8 level
collapse (sum) x_val (first) naics=naics_str, by(cty_code hs8)

save "$outdir/exportweight.dta", replace

log close
