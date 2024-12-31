clear all
set more off

mata
	mata mlib index
end

cap log close
log using "./output/logs/log_r07a.smcl", append

///////////////////
///Preliminaries///
///////////////////

*Instrument.
local iv_opts iv_0_baseline

*Fixed effects.
local fe fe_imp_hs4_yr fe_exp_hs4_yr fe_imp_exp_hs4

*Cluster variables.
local clustvar fe_imp_exp_hs4

*Number of pretrend horizons -- max 6.
local pret 6

*Number of post horizons -- max 10.
local post 10

*Outcomes.
local outcomes ln_trade_val

*Number of lags.
local lags 1

*Open database.
use "./temp_files/DataregW_did.dta",clear
xtset panel_id year

//////////////////
///Baseline OLS///
//////////////////

*OLS.
foreach l of local lags{

	foreach lhs of local outcomes{
		
		*Define matrix to store results.
		matrix elasticity_ols_`lhs' = J(`post'+1,4,.)
		matrix colnames elasticity_ols_`lhs' = horizon b se obs		
		
		local h 0
		
		*Display step.
		dis("OLS Actual Trade Elasticity, h=`h'") as text
		
		*Run regression.
		if `l'==0{
			ivreghdfe D`h'`lhs' D`h'ln_tariff, absorb(`fe') cluster(`clustvar')
		}
		else {
			ivreghdfe D`h'`lhs' L(1/`l').D0`lhs' D`h'ln_tariff L(1/`l').D0ln_tariff, absorb(`fe') cluster(`clustvar')
		}
		
		*Store results.
		mat elasticity_ols_`lhs'[`h'+1,1]=`h'
		mat elasticity_ols_`lhs'[`h'+1,2]=_b[D`h'ln_tariff]
		mat elasticity_ols_`lhs'[`h'+1,3]=_se[D`h'ln_tariff]
		mat elasticity_ols_`lhs'[`h'+1,4]=e(N)

		*Save results.
		xsvmat elasticity_ols_`lhs', name(col) saving("./output/temp_files/OLS_`lhs'_lags`l'.dta", replace)
		xsvmat elasticity_ols_`lhs', name(col) list(,)		
		
		forvalues h=  1(1)`post'{
			
		*Display step.
		dis("OLS Actual Trade Elasticity, h=`h'") as text
		
		*Run regression.
		ivreghdfe D`h'`lhs' L(1/`l').D0`lhs' L(1/`l').D0ln_tariff (D`h'ln_tariff = D0ln_tariff), absorb(`fe') cluster(`clustvar')
		

		*Store results.
		mat elasticity_ols_`lhs'[`h'+1,1]=`h'
		mat elasticity_ols_`lhs'[`h'+1,2]=_b[D`h'ln_tariff]
		mat elasticity_ols_`lhs'[`h'+1,3]=_se[D`h'ln_tariff]
		mat elasticity_ols_`lhs'[`h'+1,4]=e(N)
		
		*Save results.
		xsvmat elasticity_ols_`lhs', name(col) saving("./output/temp_files/OLS_`lhs'_lags`l'.dta", replace)
		xsvmat elasticity_ols_`lhs', name(col) list(,)	

		}
		
	}	

}

log close
