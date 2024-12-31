clear all
set more off

mata
	mata mlib index
end

cap log close
log using "./output/logs/log_r05.smcl", append

///////////////////
///Preliminaries///
///////////////////

*Instrument.
local iv_opts iv_0_baseline

*Fixed effects.
local fe fe_imp_hs4_yr fe_exp_hs4_yr fe_imp_exp_hs4

*Cluster variables.
local clustvar fe_imp_exp_hs4

*Number of post horizons -- max 10.
local post 10

*Number of lags.
local l 1

*Open database.
use hs_section using "./temp_files/DataregW_did.dta" ,clear

*List of sections.
levelsof hs_section, local(hs_sectionlevels)
*local not 11
*local hs_sectionlevels: list hs_sectionlevels- not

////////
///IV///
////////

foreach iv of local iv_opts{

	foreach s of local hs_sectionlevels {

		di "regressions for section`s'"
		di "ivoption: `iv'"
		
		*Open database using each section.
		use year ln_trade_val hs_section panel_id fe_imp_hs4_yr fe_exp_hs4_yr fe_imp_exp_hs4 fe_imp_exp D0ln_trade_val D0ln_quantity D0ln_tariff D1ln_trade_val D1ln_tariff D2ln_trade_val D2ln_tariff D3ln_trade_val D3ln_tariff D4ln_trade_val D4ln_tariff D5ln_trade_val D5ln_tariff D6ln_trade_val D6ln_tariff  D7ln_trade_val D7ln_tariff D8ln_trade_val D8ln_tariff D9ln_trade_val D9ln_tariff D10ln_trade_val D10ln_tariff `iv' if hs_section ==`s' using "./temp_files/DataregW_did.dta",clear
		xtset panel_id year

		*Define matrix to store results.
		matrix post_elasticity = J(`post'+1,8,.)
		matrix colnames post_elasticity = horizon b se blag selag F1 F2 obs

		forvalues h = 0 (1) `post'{
			
			*Display step.
			dis("IV2 Actual Trade Elasticity, h=`h', section=`s'") as text
		
			*Run regression.
			if `l'==0{
				ivreghdfe D`h'ln_trade_val ( D`h'ln_tariff = `iv'), absorb(`fe') first cluster(`clustvar')
			}
			else {
				ivreghdfe D`h'ln_trade_val L(1/`l').D0ln_trade_val ( D`h'ln_tariff L(1/`l').D0ln_tariff = `iv' L(1/`l').`iv'), absorb(`fe') first cluster(`clustvar')
			}
		
			*Store results.
			mat post_elasticity[`h'+1,1]= `h'
			mat post_elasticity[`h'+1,2]=_b[D`h'ln_tariff]
			mat post_elasticity[`h'+1,3]=_se[D`h'ln_tariff]
			mat temp=e(first)
			mat post_elasticity[`h'+1,6]=temp[8,1]
			mat post_elasticity[`h'+1,7]=temp[8,2]
			mat post_elasticity[`h'+1,8]=e(N)
			
			*Save results.
			xsvmat post_elasticity, name(col) saving("./output/temp_files/`iv'_section`s'_lags`l'.dta", replace)
			xsvmat post_elasticity, name(col) list(,)

		}
			
	}	

}

log close