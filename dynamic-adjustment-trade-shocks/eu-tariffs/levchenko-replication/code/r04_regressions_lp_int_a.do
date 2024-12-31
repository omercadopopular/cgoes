clear all
set more off

mata
	mata mlib index
end

cap log close
log using "./output/logs/log_r04a.smcl", append

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
use "./temp_files/DataregW_did.dta",clear
xtset panel_id year

foreach iv of local iv_opts{

	//////////////////////////
	///Pretrends on tariffs///
	//////////////////////////
	
	*Define matrix to store results.
	matrix pretrend_tariff = J(`pret',8,.)
	matrix colnames pretrend_tariff = horizon b se blag selag F1 F2 obs
 
    forvalues h = `pret'(-1)1 {
	
		*Run regression.
		ivreghdfe L`h'.D0ln_tariff (D0ln_tariff  = `iv'), absorb(`fe') first cluster(`clustvar')
		
		*Store results.
		mat pretrend_tariff[`h',1]= -1*`h'
		mat pretrend_tariff[`h',2]=_b[D0ln_tariff]
		mat pretrend_tariff[`h',3]=_se[D0ln_tariff]
		mat temp=e(first)
		mat pretrend_tariff[`h',6]=temp[8,1]
		mat pretrend_tariff[`h',7]=temp[8,2]
		mat pretrend_tariff[`h',8]=e(N)
		
		*Save results.
		xsvmat pretrend_tariff, name(col) saving("./output/temp_files/`iv'_lp_tariffs_pre.dta", replace)
		xsvmat pretrend_tariff, name(col) list(,)	
	
	}
	
	
	////////////////////
	///LPs on tariffs///
	////////////////////

	*Define matrix to store results.
	matrix post_tariff = J(`post',8,.)
	matrix colnames post_tariff = horizon b se blag selag F1 F2 obs

	forvalues h = 1(1) `post' {
	
		*Run regression.
		ivreghdfe D`h'ln_tariff (D0ln_tariff = `iv'), absorb(`fe') first cluster(`clustvar')
		
		*Store results.
		mat post_tariff[`h',1]= `h'
		mat post_tariff[`h',2]=_b[D0ln_tariff]
		mat post_tariff[`h',3]=_se[D0ln_tariff]
		mat temp=e(first)
		mat post_tariff[`h',6]=temp[8,1]
		mat post_tariff[`h',7]=temp[8,2]
		mat post_tariff[`h',8]=e(N)
		
		*Save results.
		xsvmat post_tariff, name(col) saving("./output/temp_files/`iv'_lp_tariffs.dta", replace)
		xsvmat post_tariff, name(col) list(,)	
	
	}
	
	
	foreach lhs of local outcomes{

		///////////////////////////
		///Pretrends on outcomes///
		///////////////////////////

		*Define matrix to store results.
		matrix pretrend_`lhs' = J(`pret',8,.)
		matrix colnames pretrend_`lhs' = horizon b se blag selag F1 F2 obs

		forvalues h = `pret'(-1)1 {
			
			*Run regression.
			ivreghdfe L`h'.D0`lhs' (D0ln_tariff = `iv'), absorb(`fe') first cluster(`clustvar')

			*Store results.
			mat pretrend_`lhs'[`h',1]= -1*`h'
			mat pretrend_`lhs'[`h',2]=_b[D0ln_tariff]
			mat pretrend_`lhs'[`h',3]=_se[D0ln_tariff]
			mat temp=e(first)
			mat pretrend_`lhs'[`h',6]=temp[8,1]
			mat pretrend_`lhs'[`h',7]=temp[8,2]
			mat pretrend_`lhs'[`h',8]=e(N)
			
			*Save results.
			xsvmat pretrend_`lhs', name(col) saving("./output/temp_files/`iv'_lp_`lhs'_pre.dta", replace)
			xsvmat pretrend_`lhs', name(col) list(,)	
		
		}
	
	
		/////////////////////
		///LPs on outcomes///
		/////////////////////
	
		*Define matrix to store results.
		matrix post_`lhs' = J(`post'+1,8,.)
		matrix colnames post_`lhs' = horizon b se blag selag F1 F2 obs
	
		forvalues h = 0 (1) `post'{
			
			*Run regression.
			ivreghdfe D`h'`lhs' (D0ln_tariff = `iv'), absorb(`fe') first cluster(`clustvar')

			*Store results.
			mat post_`lhs'[`h'+1,1]= `h'
			mat post_`lhs'[`h'+1,2]=_b[D0ln_tariff]
			mat post_`lhs'[`h'+1,3]=_se[D0ln_tariff]
			mat temp=e(first)
			mat post_`lhs'[`h'+1,6]=temp[8,1]
			mat post_`lhs'[`h'+1,7]=temp[8,2]
			mat post_`lhs'[`h'+1,8]=e(N)
			
			*Save results.
			xsvmat post_`lhs', name(col) saving("./output/temp_files/`iv'_lp_`lhs'.dta", replace)
			xsvmat post_`lhs', name(col) list(,)	
			
		}	
			
	}

}

log close
