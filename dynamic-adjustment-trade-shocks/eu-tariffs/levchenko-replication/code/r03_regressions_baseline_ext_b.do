clear all
set more off

mata
	mata mlib index
end

cap log close
log using "./output/logs/log_r03b.smcl", append

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
use "./temp_files/DataregW_all.dta",clear
xtset panel_id year

*Approach: drop country-pair-products that NEVER trade to speed things up. Then, in the code, only run on non-zero LHS. 
bys panel_id: egen max_imports = max(imports_baci) if imports_baci!=.
drop if max_imports ==0 | max_imports==.
drop max_imports 

*Number of lags.
local lags 0

/////////////////////////////////////
///Extensive margin with selection///
/////////////////////////////////////

foreach l of local lags{

	foreach iv of local iv_opts{

		foreach lhs of local outcomes{
			
			*Define matrix to store results.
			matrix elasticity_`lhs' = J(`post'+1,8,.)
			matrix colnames elasticity_`lhs' = horizon b se blag selag F1 F2 obs
			
			forvalues h = 0 (1) `post'{
				
				*Display step.
				dis("IV2 Actual Trade Elasticity, h=`h'") as text
				
				*Run regression and store results.
				if `l'==0{
					ivreghdfe D`h'`lhs' ( D`h'ln_tariff = `iv')   if D`h'`lhs'!=0, absorb(`fe') first cluster(`clustvar')
					mat elasticity_`lhs'[`h'+1,1]= `h'
					mat elasticity_`lhs'[`h'+1,2]=_b[D`h'ln_tariff]
					mat elasticity_`lhs'[`h'+1,3]=_se[D`h'ln_tariff]
					mat temp=e(first)
					mat elasticity_`lhs'[`h'+1,6]=temp[8,1]
					mat elasticity_`lhs'[`h'+1,7]=temp[8,2]
					mat elasticity_`lhs'[`h'+1,8]=e(N)	
				}
				else{
					ivreghdfe D`h'`lhs' L(1/`l').D0`lhs' ( D`h'ln_tariff L(1/`l').D0ln_tariff = `iv' L(1/`l').`iv')   if D`h'`lhs'!=0, absorb(`fe') first cluster(`clustvar')
					mat elasticity_`lhs'[`h'+1,1]= `h'
					mat elasticity_`lhs'[`h'+1,2]=_b[D`h'ln_tariff]
					mat elasticity_`lhs'[`h'+1,3]=_se[D`h'ln_tariff]
					mat elasticity_`lhs'[`h'+1,4]=_b[L1.D0ln_tariff]
					mat elasticity_`lhs'[`h'+1,5]=_se[L1.D0ln_tariff]	
					mat temp=e(first)
					mat elasticity_`lhs'[`h'+1,6]=temp[8,1]
					mat elasticity_`lhs'[`h'+1,7]=temp[8,2]
					mat elasticity_`lhs'[`h'+1,8]=e(N)	
				}
				
				*Save results.
				xsvmat elasticity_`lhs', name(col) saving("./output/temp_files/`iv'_elasticity_`lhs'_ext_sel_lags`l'.dta", replace)
				xsvmat elasticity_`lhs', name(col) list(,)

			} 
			
		}	

	}

}

log close