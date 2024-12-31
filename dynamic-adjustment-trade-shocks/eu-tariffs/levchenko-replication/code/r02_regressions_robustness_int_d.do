clear all
set more off

mata
	mata mlib index
end

cap log close
log using "./output/logs/log_r02d.smcl", append

/////////////////////
///Distributed lag///
/////////////////////

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

*Open database.
use "./temp_files/DataregW_did.dta",clear
xtset panel_id year

foreach iv of local iv_opts{
	
	foreach lhs of local outcomes{
	
		*Define matrix to store results.
		matrix elasticity_`lhs' = J(`post'+1,7,.)
		matrix colnames elasticity_`lhs' = horizon b se bcum secum SWF obs
		
		*Run regression.
		ivreghdfe D0`lhs' ( L(0/`post').D0ln_tariff = L(0/`post').`iv'), absorb(`fe') first cluster(`clustvar')
		mat elasticity_`lhs'[1,7]=e(N)

		*Calculate cumulative coefficients.
		mat temp = e(first)
		dis("IV2 Actual Trade Elasticity, Long run H0") as text
		lincom L0.D0ln_tariff 
		mat elasticity_`lhs'[1,4]=r(estimate)
		mat elasticity_`lhs'[1,5]=r(se)
		mat elasticity_`lhs'[1,6]=temp[8,1]
		
		dis("IV2 Actual Trade Elasticity, Long run H1") as text
		lincom L0.D0ln_tariff + L1.D0ln_tariff 
		mat elasticity_`lhs'[2,4]=r(estimate)
		mat elasticity_`lhs'[2,5]=r(se)
		mat elasticity_`lhs'[2,6]=temp[8,2]

		dis("IV2 Actual Trade Elasticity, Long run H2") as text
		lincom L0.D0ln_tariff + L1.D0ln_tariff + L2.D0ln_tariff 
		mat elasticity_`lhs'[3,4]=r(estimate)
		mat elasticity_`lhs'[3,5]=r(se)
		mat elasticity_`lhs'[3,6]=temp[8,3]

		dis("IV2 Actual Trade Elasticity, Long run H3") as text
		lincom L0.D0ln_tariff + L1.D0ln_tariff + L2.D0ln_tariff + L3.D0ln_tariff 
		mat elasticity_`lhs'[4,4]=r(estimate)
		mat elasticity_`lhs'[4,5]=r(se)
		mat elasticity_`lhs'[4,6]=temp[8,4]

		dis("IV2 Actual Trade Elasticity, Long run H4") as text
		lincom L0.D0ln_tariff + L1.D0ln_tariff + L2.D0ln_tariff + L3.D0ln_tariff +L4.D0ln_tariff 
		mat elasticity_`lhs'[5,4]=r(estimate)
		mat elasticity_`lhs'[5,5]=r(se)
		mat elasticity_`lhs'[5,6]=temp[8,5]

		dis("IV2 Actual Trade Elasticity, Long run H5") as text
		lincom L0.D0ln_tariff + L1.D0ln_tariff + L2.D0ln_tariff + L3.D0ln_tariff +L4.D0ln_tariff + L5.D0ln_tariff
		mat elasticity_`lhs'[6,4]=r(estimate)
		mat elasticity_`lhs'[6,5]=r(se)
		mat elasticity_`lhs'[6,6]=temp[8,6]

		dis("IV2 Actual Trade Elasticity, Long run H6") as text
		lincom L0.D0ln_tariff + L1.D0ln_tariff + L2.D0ln_tariff + L3.D0ln_tariff +L4.D0ln_tariff + L5.D0ln_tariff +L6.D0ln_tariff 
		mat elasticity_`lhs'[7,4]=r(estimate)
		mat elasticity_`lhs'[7,5]=r(se)
		mat elasticity_`lhs'[7,6]=temp[8,7]

		dis("IV2 Actual Trade Elasticity, Long run H7") as text
		lincom L0.D0ln_tariff + L1.D0ln_tariff + L2.D0ln_tariff + L3.D0ln_tariff +L4.D0ln_tariff + L5.D0ln_tariff +L6.D0ln_tariff + L7.D0ln_tariff 
		mat elasticity_`lhs'[8,4]=r(estimate)
		mat elasticity_`lhs'[8,5]=r(se)
		mat elasticity_`lhs'[8,6]=temp[8,8]

		dis("IV2 Actual Trade Elasticity, Long run H8") as text
		lincom L0.D0ln_tariff + L1.D0ln_tariff + L2.D0ln_tariff + L3.D0ln_tariff +L4.D0ln_tariff + L5.D0ln_tariff +L6.D0ln_tariff + L7.D0ln_tariff + L8.D0ln_tariff 
		mat elasticity_`lhs'[9,4]=r(estimate)
		mat elasticity_`lhs'[9,5]=r(se)
		mat elasticity_`lhs'[9,6]=temp[8,9]


		dis("IV2 Actual Trade Elasticity, Long run H9") as text
		lincom L0.D0ln_tariff + L1.D0ln_tariff + L2.D0ln_tariff + L3.D0ln_tariff +L4.D0ln_tariff + L5.D0ln_tariff +L6.D0ln_tariff + L7.D0ln_tariff + L8.D0ln_tariff + L9.D0ln_tariff 
		mat elasticity_`lhs'[10,4]=r(estimate)
		mat elasticity_`lhs'[10,5]=r(se)
		mat elasticity_`lhs'[10,6]=temp[8,10]

		dis("IV2 Actual Trade Elasticity, Long run H10") as text
		lincom L0.D0ln_tariff + L1.D0ln_tariff + L2.D0ln_tariff + L3.D0ln_tariff +L4.D0ln_tariff + L5.D0ln_tariff +L6.D0ln_tariff + L7.D0ln_tariff + L8.D0ln_tariff + L9.D0ln_tariff +L10.D0ln_tariff
		mat elasticity_`lhs'[11,4]=r(estimate)
		mat elasticity_`lhs'[11,5]=r(se)
		mat elasticity_`lhs'[11,6]=temp[8,11]

		*Save results.
		svmat elasticity_`lhs', name(col) 
		save "./output/temp_files/`iv'_dl_elasticity_`lhs'.dta", replace
			
	}	

}

foreach iv of local iv_opts{
	
	foreach lhs of local outcomes{
		
		use "./output/temp_files/`iv'_dl_elasticity_`lhs'.dta", clear
		keep horizon b se bcum secum SWF obs
		drop if bcum==.
		save "./output/temp_files/`iv'_dl_elasticity_`lhs'.dta", replace
		
	}
	
}

//////////////////////////////
///HS6 Multilateral Effects///
//////////////////////////////

*Instrument.
local iv_opts iv_0_baseline

*Fixed effects.
local fe fe_imp_hs6_yr fe_exp_hs6_yr fe_imp_exp_hs6

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

*IV.
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
					ivreghdfe D`h'`lhs' L(1/`l').D0`lhs' ( D`h'ln_tariff L(1/`l').D0ln_tariff = `iv' L(1/`l').`iv'), absorb(fe_imp_hs6_yr fe_exp_hs6_yr) first cluster(`clustvar')
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
				xsvmat elasticity_`lhs', name(col) saving("./output/temp_files/`iv'_elasticity_`lhs'_lags`l'_MRT6_BIL0.dta", replace)
				xsvmat elasticity_`lhs', name(col) list(,)

			} 
			
		}	

	}

}

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
			xsvmat elasticity_ols_`lhs', name(col) saving("./output/temp_files/OLS_`lhs'_FE6_lags`l'.dta", replace)
			xsvmat elasticity_ols_`lhs', name(col) list(,)		
			
			forvalues h=  1(1)`post'{
				
			*Display step.
			dis("OLS Actual Trade Elasticity, h=`h'") as text
			
			*Run regression.
			ivreghdfe D`h'`lhs' (D`h'ln_tariff = D0ln_tariff), absorb(`fe') cluster(`clustvar')

			*Store results.
			mat elasticity_ols_`lhs'[`h'+1,1]=`h'
			mat elasticity_ols_`lhs'[`h'+1,2]=_b[D`h'ln_tariff]
			mat elasticity_ols_`lhs'[`h'+1,3]=_se[D`h'ln_tariff]
			mat elasticity_ols_`lhs'[`h'+1,4]=e(N)
			
			*Save results.
			xsvmat elasticity_ols_`lhs', name(col) saving("./output/temp_files/OLS_`lhs'_FE6_lags`l'.dta", replace)
			xsvmat elasticity_ols_`lhs', name(col) list(,)	

			}
			
		}	

}

///////////////////
///Uruguay Round///
///////////////////

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
use "./temp_files/DataregW_did.dta", clear
xtset panel_id year

*IV.
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
					ivreghdfe D`h'`lhs' ( D`h'ln_tariff = `iv') if year<=1997, absorb(`fe') first cluster(`clustvar')
				}
				else {
					ivreghdfe D`h'`lhs' L(1/`l').D0`lhs' ( D`h'ln_tariff L(1/`l').D0ln_tariff = `iv' L(1/`l').`iv') if year<=1997, absorb(`fe') first cluster(`clustvar')
					*ivreghdfe D`h'`lhs' L(1/`l').D0`lhs' ( D`h'ln_tariff L(1/`l').D0ln_tariff = `iv' L(1/`l').`iv') if year<=1996, absorb(`fe') first cluster(`clustvar')
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
				xsvmat elasticity_`lhs', name(col) saving("./output/temp_files/`iv'_elasticity_`lhs'_ur_lags`l'.dta", replace)
				xsvmat elasticity_`lhs', name(col) list(,)

			} 
			
		}	

	}

}

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
				ivreghdfe D`h'`lhs' D`h'ln_tariff if year<=1997, absorb(`fe') cluster(`clustvar')
			}
			else {
				ivreghdfe D`h'`lhs' L(1/`l').D0`lhs' D`h'ln_tariff L(1/`l').D0ln_tariff if year<=1997, absorb(`fe') cluster(`clustvar')
			}
			
			*Store results.
			mat elasticity_ols_`lhs'[`h'+1,1]=`h'
			mat elasticity_ols_`lhs'[`h'+1,2]=_b[D`h'ln_tariff]
			mat elasticity_ols_`lhs'[`h'+1,3]=_se[D`h'ln_tariff]
			mat elasticity_ols_`lhs'[`h'+1,4]=e(N)

			*Save results.
			xsvmat elasticity_ols_`lhs', name(col) saving("./output/temp_files/OLS_`lhs'_ur_lags`l'.dta", replace)
			xsvmat elasticity_ols_`lhs', name(col) list(,)	
			
			forvalues h=  1(1)`post'{
				
			*Display step.
			dis("OLS Actual Trade Elasticity, h=`h'") as text
			
			*Run regression.
			ivreghdfe D`h'`lhs' (D`h'ln_tariff = D0ln_tariff) L(1/`l').D0ln_tariff if year<=1997, absorb(`fe') cluster(`clustvar')

			*Store results.
			mat elasticity_ols_`lhs'[`h'+1,1]=`h'
			mat elasticity_ols_`lhs'[`h'+1,2]=_b[D`h'ln_tariff]
			mat elasticity_ols_`lhs'[`h'+1,3]=_se[D`h'ln_tariff]
			mat elasticity_ols_`lhs'[`h'+1,4]=e(N)
			
			*Save results.
			xsvmat elasticity_ols_`lhs', name(col) saving("./output/temp_files/OLS_`lhs'_ur_lags`l'.dta", replace)
			xsvmat elasticity_ols_`lhs', name(col) list(,)	

			}
			
		}	

}

log close
