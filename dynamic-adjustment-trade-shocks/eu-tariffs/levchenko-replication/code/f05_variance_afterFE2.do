clear all
set more off

mata
	mata mlib index
end

cap log close
log using "./output/logs/log_f05.smcl", append

///////////////////
///Preliminaries///
///////////////////

*Open database.
use importer exporter year hs6 ahs_st imports_baci mfn_binding D0ln_trade_val ln_trade_val ln_ahs_st iv_0_baseline  D0ln_tariff fe_imp_hs4_yr fe_exp_hs4_yr fe_imp_exp_hs4 using "./temp_files/DataregW_did.dta", clear

*Drop missings.
drop if mi(D0ln_trade_val)

*Generate control, treatment and excluded indicators.
gen byte control = mfn_binding==0
gen byte treat = (mfn_binding==1 & iv_0_baseline!=.)
gen byte excluded = missing(iv_0_baseline)

foreach v in  D0ln_tariff   {
	
	*Run regression.
	reghdfe `v', absorb(fe_imp_hs4_yr fe_exp_hs4_yr fe_imp_exp_hs4) resid
	
	*Predict residual.
	predict `v'_res if e(sample), res
	
	*Dummy if observation not dropped after FE.
	gen `v'_FEkeep = e(sample)
	
	*Run regression if not excluded.
	reghdfe `v' if excluded==0, a(fe_imp_hs4_yr fe_exp_hs4_yr fe_imp_exp_hs4) resid
	
	*Predict residual.
	predict `v'_resNoExcl if excluded==0 & e(sample), res
	
	*Dummy if observation not dropped after FE in the actual regression (that doesnt use excluded).
	gen `v'_NoExclFEkeep = e(sample)
	
	*Drop "close to zero" observations.
	replace `v'_NoExclFEkeep = 0 if (`v'_NoExclFEkeep==1) & (`v'_resNoExcl> - 0.00001 & `v'_resNoExcl< 0.00001)

}

*Generate importer x HS4 x year indicator and check variation.
gen mfn_change = (mfn_binding==1 & D0ln_tariff!=0) if !mi(D0ln_tariff) & !mi(mfn_binding)
bys fe_imp_hs4_yr: egen tot_mfn_change = total(mfn_change)

*Generate indicator of available variance: there is some MFN change within imprter x HS4 x year, and the observations have survived the full set of FE. 
gen avail_variance = (tot_mfn_change>0 & D0ln_tariff_NoExclFEkeep==1) if !mi(tot_mfn_change)

*Generate indicator of available variance for excluded observations.
gen avail_var_excluded= (tot_mfn_change>0 & D0ln_tariff_FEkeep==1) if !mi(tot_mfn_change)

*Save database.
save "./temp_files/temp_var.dta", replace

///////////////
///Exporters///
///////////////

foreach i in exporter {
	
	*Open database.
	use "./temp_files/temp_var.dta", clear
	
	*Drop excluded observations.
	drop if excluded==1
	
	*Count number of times you are used as treatment and control.
	collapse (sum) avail_variance imports_baci, by(`i' control)
	
	*Generate log in base 10.
	gen ln_count = log10(avail_variance)
	
	*Reshape dataset.
	reshape wide ln_count avail_variance imports_baci, i(`i') j(control)
	
	*Rename variable.
	rename `i' countrycode
	
	*Merge with PWT.
	gen year=2006
	merge 1:1 countrycode year using "./data/PWT/pwt91.dta", keepusing(rgdpo pop)
	keep if _m==3
	
	*Generate GDP per capita.
	gen gdp_cap = rgdpo/pop
	
	*Rename variable.
	rename countrycode `i'
	
	*Generate total imports.
	gen tot_imports = imports_baci1+imports_baci0
	gen mtot_imports = -tot_imports
	sort mtot_imports
	forvalues j=1/5 {
		sum ln_count1 in `j'
		local y = `=r(mean)'
		sum ln_count0 in `j'
		local x = `=r(mean)'
		local iso = exporter[`j']
		local text `text' text(`y' `x' "`iso'")
	} 
	
	*Graph.
	scatter ln_count1  ln_count0 [w=rgdpo], msize(0.35) `text' ///
		ytitle("Count of `i' observations" "in control group (in log10)", size(small)) xtitle("Count of `i' observations" "in treatment group (in log10)", size(small)) graphregion(color(white))
	graph export "./output/graphs/final_files/count_`i'_keptFE_scatter.eps", replace  
	graph export "./output/graphs/final_files/count_`i'_keptFE_scatter.png", replace  
	graph export "./output/graphs/final_files/count_`i'_keptFE_scatter.pdf", replace  
	gen ln_gdp_cap = log10(gdp_cap)
	twoway (scatter ln_count1 ln_gdp_cap, msize(0.35)) (lfit ln_count1 ln_gdp_cap),  ///
		ytitle("Count of `i' observations" "in control group (in log10)", size(small)) xtitle("Real GDP per capita (in log)",size(small)) graphregion(color(white)) legend(off)
	graph export "./output/graphs/final_files/count_`i'_keptFE_scatter_control_gdpcap.eps", replace  
	graph export "./output/graphs/final_files/count_`i'_keptFE_scatter_control_gdpcap.png", replace  
	graph export "./output/graphs/final_files/count_`i'_keptFE_scatter_control_gdpcap.pdf", replace  
	twoway (scatter ln_count0 ln_gdp_cap, msize(0.35)) (lfit ln_count1 ln_gdp_cap),  ///
		ytitle("Count of `i' observations" "in treatment group (in log10)", size(small)) xtitle("Real GDP per capita (in log)", size(small)) graphregion(color(white)) legend(off)
	graph export "./output/graphs/final_files/count_`i'_keptFE_scatter_treat_gdpcap.eps", replace  
	graph export "./output/graphs/final_files/count_`i'_keptFE_scatter_treat_gdpcap.png", replace  
	graph export "./output/graphs/final_files/count_`i'_keptFE_scatter_treat_gdpcap.pdf", replace  
	
}

foreach i in hs6 {
	
	*Open database.
	use "./temp_files/temp_var.dta", clear
	
	*Drop excluded observations.
	drop if excluded==1
	
	*Generate count.
	gen count_preFE = 1
	collapse (sum) avail_variance count_preFE, by(`i')
	
}
	
	*Generate HS2 code.
	gen hs2 = substr(hs6,1,2)
	
	*Collapse by HS2.
	collapse (sum) avail_variance count_preFE, by(hs2)
	
	*Generate totals and shares.
	egen tot_postFE = total(avail_variance)
	gen share_postFE=avail_variance/tot_postFE
	egen tot_preFE = total(count_preFE)
	gen share_preFE = count_preFE/tot_preFE
	
	*Graph.
	gen avail_variance_=avail_variance/1000000
	graph bar avail_variance_, over(hs2, sort(hs2) label(angle(90) labsize(tiny)) ) ///
		ytitle("Observation counts by HS2 groups in available variation" "(millions)", size(small)) ylabel(,labsize(small))  ///
		  graphregion(color(white)) 
	graph export "./output/graphs/final_files/count_hs2_keptFE_bar.eps", replace 
	graph export "./output/graphs/final_files/count_hs2_keptFE_bar.png", replace 
	graph export "./output/graphs/final_files/count_hs2_keptFE_bar.pdf", replace 
	
	destring hs2, gen(hs2_num)
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
	
	*Collapse by sections.
	collapse (sum) avail_variance count_preFE, by(hs_section)

	gen hsDesc = ""
	replace hsDesc = "Live animals" if hs_section==1
	replace hsDesc = "Vegetable products" if hs_section==2
	replace hsDesc = "Animal or vegetable fats" if hs_section==3
	replace hsDesc = "Prepared foodstuffs" if hs_section==4
	replace hsDesc = "Mineral products" if hs_section==5
	replace hsDesc = "Product of the chemical industries" if hs_section==6
	replace hsDesc = "Plastics and articles thereof" if hs_section==7
	replace hsDesc = "Raw hides and skins, leather" if hs_section==8
	replace hsDesc = "Wood and articles of wood" if hs_section==9
	replace hsDesc = "Pulp of wood or of other fibrous material" if hs_section==10
	replace hsDesc = "Textiles and textile articles" if hs_section==11
	replace hsDesc = "Footwear, headgear, umbrellas" if hs_section==12
	replace hsDesc = "Articles of stone, plaster" if hs_section==13
	replace hsDesc = "Natural or cultural pearls" if hs_section==14
	replace hsDesc = "Base metals and articles" if hs_section==15
	replace hsDesc = "Machinery and mechanical appliances" if hs_section==16
	replace hsDesc = "Vehicles, aircraft, vessels" if hs_section==17
	replace hsDesc = "Optical, photographic, cinematographic instruments" if hs_section==18
	replace hsDesc = "Arms and ammunition" if hs_section==19
	replace hsDesc = "Misc manufactured articles" if hs_section==20
	replace hsDesc = "Work of art" if hs_section==21
	gen hsDesc_short = substr(hsDesc,1,25)
	replace hsDesc_short=hsDesc_short+"~" if length(hsDesc_short)<length(hsDesc)
	
	*Generate totals and shares.
	egen tot_postFE = total(avail_variance)
	gen share_postFE=avail_variance/tot_postFE
	egen tot_preFE = total(count_preFE)
	gen share_preFE = count_preFE/tot_preFE
		
	*Graph.
	graph bar share_postFE share_preFE, over(hsDesc_short, sort(hs_section) label(angle(45) labsize(small)) ) ///
	ytitle("Share of total observations") legend(order(1 "All data" 2 "Available variation") col(1)) ///
		 graphregion(color(white)) 
	graph export "./output/graphs/final_files/share_hsSection_keptFE_bar.eps", replace  
	graph export "./output/graphs/final_files/share_hsSection_keptFE_bar.png", replace  
	graph export "./output/graphs/final_files/share_hsSection_keptFE_bar.pdf", replace  

log close



