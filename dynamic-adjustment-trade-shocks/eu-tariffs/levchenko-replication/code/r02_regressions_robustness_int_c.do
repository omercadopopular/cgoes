clear all
set more off

mata
	mata mlib index
end

cap log close
log using "./output/logs/log_r02c.smcl", append

//////////////
///Weighted///
//////////////

*Instrument.
local iv_opts iv_0_baseline

*Fixed effects.
local fe fe_imp_hs4_yr fe_exp_hs4_yr fe_imp_exp_hs4

*Cluster variables.
local clustvar fe_imp_exp_hs4

*Number of post horizons -- max 10.
local post 10

*Outcomes.
local outcomes ln_trade_val

*Number of lags for pretrend controls.
local lags 1

*Open database.
use "./temp_files/DataregW_did.dta",clear
xtset panel_id year

foreach l of local lags{

	foreach iv of local iv_opts{

		foreach lhs of local outcomes{
			
			*Define matrix to store results.
			matrix elasticity_`lhs' = J(`post'+1,8,.)
			matrix colnames elasticity_`lhs' = horizon b se blag selag F1 F2 obs
			
			forvalues h = 0 (1) `post'{
				
				*Display step.
				dis("IV2 Actual Trade Elasticity, h=`h'") as text
				
				*Run regression.
				if `l'==0{
					ivreghdfe D`h'`lhs' ( D`h'ln_tariff = `iv') [aw=L2.ln_trade_val], absorb(`fe') first cluster(`clustvar')
				}
				else {
					ivreghdfe D`h'`lhs' L(1/`l').D0`lhs' ( D`h'ln_tariff L(1/`l').D0ln_tariff = `iv' L(1/`l').`iv') [aw=L2.ln_trade_val], absorb(`fe') first cluster(`clustvar')
				}

				*Store results.
				mat elasticity_`lhs'[`h'+1,1]= `h'
				mat elasticity_`lhs'[`h'+1,2]=_b[D`h'ln_tariff]
				mat elasticity_`lhs'[`h'+1,3]=_se[D`h'ln_tariff]
				mat temp=e(first)
				mat elasticity_`lhs'[`h'+1,6]=temp[8,1]
				mat elasticity_`lhs'[`h'+1,7]=temp[8,2]
				mat elasticity_`lhs'[`h'+1,8]=e(N)
				
				*Save results.
				xsvmat elasticity_`lhs', name(col) saving("./output/temp_files/`iv'_elasticity_`lhs'_lnwt_lags`l'.dta", replace)
				xsvmat elasticity_`lhs', name(col) list(,)

			} 
			
		}	

	}

}

/////////
///SD1///
/////////

*Instrument.
local iv_opts iv_0_baseline

*Fixed effects.
local fe fe_imp_hs4_yr fe_exp_hs4_yr fe_imp_exp_hs4

*Cluster variables.
local clustvar fe_imp_exp_hs4

*Number of post horizons -- max 10.
local post 10

*Outcomes.
local outcomes ln_trade_val

*Number of lags for pretrend controls.
local lags 1

*Open database.
use "./temp_files/DataregW_did.dta",clear
keep if sd_ahst==0
xtset panel_id year

foreach l of local lags{

	foreach iv of local iv_opts{

		foreach lhs of local outcomes{
			
			*Define matrix to store results.
			matrix elasticity_`lhs' = J(`post'+1,8,.)
			matrix colnames elasticity_`lhs' = horizon b se blag selag F1 F2 obs
			
			forvalues h = 0 (1) `post'{
				
				*Display step.
				dis("IV2 Actual Trade Elasticity, h=`h'") as text
				
				*Run regression.
				if `l'==0{
					ivreghdfe D`h'`lhs' ( D`h'ln_tariff = `iv'), absorb(`fe') first cluster(`clustvar')
				}
				else {
					ivreghdfe D`h'`lhs' L(1/`l').D0`lhs' ( D`h'ln_tariff L(1/`l').D0ln_tariff = `iv' L(1/`l').`iv'), absorb(`fe') first cluster(`clustvar')
				}

				*Store results.
				mat elasticity_`lhs'[`h'+1,1]= `h'
				mat elasticity_`lhs'[`h'+1,2]=_b[D`h'ln_tariff]
				mat elasticity_`lhs'[`h'+1,3]=_se[D`h'ln_tariff]
				mat temp=e(first)
				mat elasticity_`lhs'[`h'+1,6]=temp[8,1]
				mat elasticity_`lhs'[`h'+1,7]=temp[8,2]
				mat elasticity_`lhs'[`h'+1,8]=e(N)
				
				*Save results.
				xsvmat elasticity_`lhs', name(col) saving("./output/temp_files/`iv'_elasticity_`lhs'_SD0_lags`l'.dta", replace)
				xsvmat elasticity_`lhs', name(col) list(,)

			} 
			
		}	

	}

}

/////////
///PTA///
/////////

*Instrument.
local iv_opts iv_0_PTA

*Fixed effects.
local fe fe_imp_hs4_yr fe_exp_hs4_yr fe_imp_exp_hs4

*Cluster variables.
local clustvar fe_imp_exp_hs4

*Number of post horizons -- max 10.
local post 10

*Outcomes.
local outcomes ln_trade_val

*Number of lags for pretrend controls.
local lags 1

*Open database.
use "./temp_files/DataregW_did.dta",clear
xtset panel_id year

foreach l of local lags{

	foreach iv of local iv_opts{

		foreach lhs of local outcomes{
			
			*Define matrix to store results.
			matrix elasticity_`lhs' = J(`post'+1,8,.)
			matrix colnames elasticity_`lhs' = horizon b se blag selag F1 F2 obs
			
			forvalues h = 0 (1) `post'{
				
				*Display step.
				dis("IV2 Actual Trade Elasticity, h=`h'") as text
				
				*Run regression.
				if `l'==0{
					ivreghdfe D`h'`lhs' ( D`h'ln_tariff = `iv'), absorb(`fe') first cluster(`clustvar')
				}
				else {
					ivreghdfe D`h'`lhs' L(1/`l').D0`lhs' ( D`h'ln_tariff L(1/`l').D0ln_tariff = `iv' L(1/`l').`iv'), absorb(`fe') first cluster(`clustvar')
				}

				*Store results.
				mat elasticity_`lhs'[`h'+1,1]= `h'
				mat elasticity_`lhs'[`h'+1,2]=_b[D`h'ln_tariff]
				mat elasticity_`lhs'[`h'+1,3]=_se[D`h'ln_tariff]
				mat temp=e(first)
				mat elasticity_`lhs'[`h'+1,6]=temp[8,1]
				mat elasticity_`lhs'[`h'+1,7]=temp[8,2]
				mat elasticity_`lhs'[`h'+1,8]=e(N)
				
				*Save results.
				xsvmat elasticity_`lhs', name(col) saving("./output/temp_files/`iv'_elasticity_`lhs'_PTA_lags`l'.dta", replace)
				xsvmat elasticity_`lhs', name(col) list(,)

			} 
			
		}	

	}

}

/////////
///TTB///
/////////

*Instrument.
local iv_opts iv_0_baseline

*Fixed effects.
local fe fe_imp_hs4_yr fe_exp_hs4_yr fe_imp_exp_hs4

*Cluster variables.
local clustvar fe_imp_exp_hs4

*Number of post horizons -- max 10.
local post 10

*Outcomes.
local outcomes ln_trade_val

*Number of lags for pretrend controls.
local lags 1

*Open database.
use "./temp_files/DataregW_did.dta",clear
xtset panel_id year

foreach l of local lags{

	foreach iv of local iv_opts{

		foreach lhs of local outcomes{
			
			*Define matrix to store results.
			matrix elasticity_`lhs' = J(`post'+1,8,.)
			matrix colnames elasticity_`lhs' = horizon b se blag selag F1 F2 obs
			
			forvalues h = 0 (1) `post'{
				
				*Display step.
				dis("IV2 Actual Trade Elasticity, h=`h'") as text
				
				*Run regression.
				if `l'==0{
					ivreghdfe D`h'`lhs' ( D`h'ln_tariff = `iv') if TTB!=1, absorb(`fe') first cluster(`clustvar')
				}
				else {
					ivreghdfe D`h'`lhs' L(1/`l').D0`lhs' ( D`h'ln_tariff L(1/`l').D0ln_tariff = `iv' L(1/`l').`iv')  if TTB!=1, absorb(`fe') first cluster(`clustvar')
				}

				*Store results.
				mat elasticity_`lhs'[`h'+1,1]= `h'
				mat elasticity_`lhs'[`h'+1,2]=_b[D`h'ln_tariff]
				mat elasticity_`lhs'[`h'+1,3]=_se[D`h'ln_tariff]
				mat temp=e(first)
				mat elasticity_`lhs'[`h'+1,6]=temp[8,1]
				mat elasticity_`lhs'[`h'+1,7]=temp[8,2]
				mat elasticity_`lhs'[`h'+1,8]=e(N)
				
				*Save results.
				xsvmat elasticity_`lhs', name(col) saving("./output/temp_files/`iv'_TTB_elasticity_`lhs'_lags`l'.dta", replace)
				xsvmat elasticity_`lhs', name(col) list(,)

			} 
			
		}	

	}

}

log close
