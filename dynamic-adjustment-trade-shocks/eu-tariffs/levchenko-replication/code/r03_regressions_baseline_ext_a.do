clear all
set more off

mata
	mata mlib index
end

cap log close
log using "./output/logs/log_r03a.smcl", append

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

*Crude fix: drop country-pair-sections that NEVER trade.
gen hs2_num = hs2
destring hs2_num, replace
gen hs_section = .

* section 1 -- live animals
replace hs_section = 1 if inrange(hs2_num,1,5)
* section 2 -- vegetable products
replace hs_section = 2 if inrange(hs2_num,6,14)
* section 3 -- animal and veg fats, oils
replace hs_section = 3 if hs2_num == 15
* section 4 --  foodstuff, tabacco
replace hs_section = 4 if inrange(hs2_num,16,24)
* section 5 --  mineral products
replace hs_section = 5 if inrange(hs2_num,25,27)
* section 5 --  mineral products
replace hs_section = 5 if inrange(hs2_num,25,27)
* section 6 --  products of chemical and allied industries
replace hs_section = 6 if inrange(hs2_num,28,38)
* section 7 --  plastics, rubber
replace hs_section = 7 if inrange(hs2_num,39,40)
* section 8 --  skinds, leather, animal stuff articles
replace hs_section = 8 if inrange(hs2_num,41,43)
* section 9 --  woods
replace hs_section = 9 if inrange(hs2_num,44,46)
* section 10 --  pulp of wood, paper 
replace hs_section = 10 if inrange(hs2_num,47,49)
* section 11 --  textiles
replace hs_section = 11 if inrange(hs2_num,50,63)
* section 12 --  footwear, stuff, artifical flowers
replace hs_section = 12 if inrange(hs2_num,64,67)
* section 13 --  stone, cement, glass
replace hs_section = 13 if inrange(hs2_num,68,70)
* section 14 --  precious metal, jewelry
replace hs_section = 14 if hs2_num == 71
* section 15 --  base metals
replace hs_section = 15 if inrange(hs2_num,72,83)
* section 16 --  machinery and mechanical appliances
replace hs_section = 16 if inrange(hs2_num,84,85)
* section 17 --  vehicles, aircraft
replace hs_section = 17 if inrange(hs2_num,86,89)
* section 18 --  measuring instruments
replace hs_section = 18 if inrange(hs2_num,90,92)
* section 19 --  arms and ammunition
replace hs_section = 19 if hs2_num == 93
* section 20 --  miscellaneous manufacturing
replace hs_section = 20 if inrange(hs2_num,94,96)
* section 21 --  art
replace hs_section = 21 if hs2_num == 97

drop hs2_num
egen long panel_id_temp = group(importer exporter hs_section)
bys panel_id_temp: egen max_imports = max(imports_baci) if imports_baci!=.
drop if max_imports ==0 | max_imports==.
drop max_imports panel_id_temp

*Number of lags.
local lags 0

//////////////////////////////////////////////
///Extensive margin with inverse hyperbolic///
//////////////////////////////////////////////

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
				else{
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
				xsvmat elasticity_`lhs', name(col) saving("./output/temp_files/`iv'_elasticity_`lhs'_ext_lags`l'.dta", replace)
				xsvmat elasticity_`lhs', name(col) list(,)

			} 
			
		}	

	}

}

log close