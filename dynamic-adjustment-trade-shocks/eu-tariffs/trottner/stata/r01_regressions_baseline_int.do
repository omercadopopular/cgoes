clear all
set more off

mata
	mata mlib index
end

cap log close
log using "./output/logs/log_r01.smcl", append

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

*Open database.
use "./temp_files/FillDataregW_did.dta",clear
xtset panel_id year
/*
//////////////
///Baseline///
//////////////
foreach iv of local iv_opts{

	foreach lhs of local outcomes{
		
		*Define matrix to store results.
		matrix elasticity_`lhs' = J(`post'+1,8,.)
		matrix colnames elasticity_`lhs' = horizon b se blag selag F1 F2 obs
		
		forvalues h = 0 (1) `post'{
			
			*Display step.
			dis("IV2 Actual Trade Elasticity, h=`h'") as text
			
			*Run regression.
			ivreghdfe D`h'`lhs' ( D`h'ln_tariff = `iv'), absorb(`fe') first cluster(`clustvar')

			*Store results.
			mat elasticity_`lhs'[`h'+1,1]= `h'
			mat elasticity_`lhs'[`h'+1,2]=_b[D`h'ln_tariff]
			mat elasticity_`lhs'[`h'+1,3]=_se[D`h'ln_tariff]
			mat temp=e(first)
			mat elasticity_`lhs'[`h'+1,6]=temp[8,1]
			mat elasticity_`lhs'[`h'+1,7]=temp[8,2]
			mat elasticity_`lhs'[`h'+1,8]=e(N)
			mat V_`lhs'_`h' = e(V)
			
			*Save results.
			xsvmat elasticity_`lhs', name(col) saving("./output/temp_files/f`iv'_elasticity_`lhs'.dta", replace)
			xsvmat elasticity_`lhs', name(col) list(,)

			xsvmat V_`lhs'_`h', name(col) saving("./output/temp_files/fV_`lhs'_`h'.dta", replace)
			xsvmat V_`lhs'_`h', name(col) list(,)

			

		} 
		
	}	

}

*/
////////////////////////////////////////////
///Baseline with lags (pretrend controls)///
////////////////////////////////////////////

*Number of lags.
local lags 1 5

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
				ivreghdfe D`h'`lhs' L(1/`l').D0`lhs' ( D`h'ln_tariff L(1/`l').D0ln_tariff = `iv' L(1/`l').`iv'), absorb(`fe') first cluster(`clustvar')

				*Store results.
				mat elasticity_`lhs'[`h'+1,1]= `h'
				mat elasticity_`lhs'[`h'+1,2]=_b[D`h'ln_tariff]
				mat elasticity_`lhs'[`h'+1,3]=_se[D`h'ln_tariff]
				mat elasticity_`lhs'[`h'+1,4]=_b[L1.D0ln_tariff]
				mat elasticity_`lhs'[`h'+1,5]=_se[L1.D0ln_tariff]	
				mat temp=e(first)
				mat elasticity_`lhs'[`h'+1,6]=temp[8,1]
				mat elasticity_`lhs'[`h'+1,7]=temp[8,2]
				mat elasticity_`lhs'[`h'+1,8]=e(N)
				mat V_`lhs'_`h'_l`l' = e(V)
				
				*Save results.
				xsvmat elasticity_`lhs', name(col) saving("./output/temp_files/f`iv'_elasticity_`lhs'_l`l'.dta", replace)
				xsvmat elasticity_`lhs', name(col) list(,)

				xsvmat V_`lhs'_`h'_l`l', rownames(X) saving("./output/temp_files/fV_`lhs'_`h'_l`l'.dta", replace)
				xsvmat V_`lhs'_`h'_l`l', rownames(X) list(,)

			

			} 
			
		}	

	}

}

log close
