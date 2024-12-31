clear all
set more off

mata
	mata mlib index
end

cap log close
log using "./output/logs/log_f03.smcl", append

///////////////////////////////////
///Average fraction of importers///
///////////////////////////////////

*Open database.
use "./temp_files/DataregW_did.dta", clear

*Drop variables.
keep importer imports_baci panel_id mfn_binding year

*Collapse database.
collapse (sum) imports_baci, by(importer year)

*Sort database.
bysort year: egen world_imports = sum(imports_baci)

*Generate fraction.
gen im_sh = imports_baci / world_imports

*Generate mean and total.
bysort importer: egen mean_im_sh = mean(im_sh)
bysort importer: egen tot_im = sum(imports_baci)

*Drop duplicates.
duplicates drop importer, force

*Sort database.
gsort -tot_im 
gen rank = _n 

*Replace countries at the bottom.
replace importer = "RoW" if rank >= 31
replace rank = 31 if importer == "RoW"
collapse (mean) mean_im_sh, by(importer rank)

*Multiply by 100.
replace mean_im_sh = 100 * mean_im_sh

*Graph.
graph bar mean_im_sh, over(rank, label(labsize(vsmall) angle(45) ) relabel(1 "USA" 2 "DEU" 3 "CHN" 4 "JPN" 5 "GBR" 6 "FRA" 7 "ITA" 8 "NLD" 9 "HKG" 10 "CAN" 11 "BEL" 12 "KOR" 13 "ESP" 14 "MEX" 15 "IND" 16 "SGP" 17 "CHE" 18 "AUS" 19 "RUS" 20 "POL" 21 "AUT" 22 "BRA" 23 "SWE" 24 "TUR" 25 "MYS" 26 "THA" 27 "CZE" 28 "ARE" 29 "DNK" 30 "IDN" 31 "RoW")) graphregion(color(white)) bgcolor(white) ytitle("") title("Fraction of World Imports (Average, %)") bar(1, blwidth(thin) bcolor(green)) intensity(50)
graph export "./output/graphs/final_files/all.png", replace
graph export "./output/graphs/final_files/all.eps", replace
graph export "./output/graphs/final_files/all.pdf", replace

////////////////////
///Sectoral trade///
////////////////////

*Open database.
use year ln_trade_val hs_section using "./temp_files/DataregW_did.dta", clear

*Generate variable in levels.
gen trade_val = exp(ln_trade_val)
drop ln_trade_val

*Generate totals.
bysort year: egen tot_trade_val = sum(trade_val)
bysort year hs_section: egen sec_trade_val = sum(trade_val)
drop trade_val

*Generate ratio.
replace sec_trade_val = sec_trade_val/ tot_trade_val
drop tot_trade_val

*Generate mean.
bysort hs_section: egen avg_trade_sh = mean(sec_trade_val)

*Drop duplicates.
duplicates drop hs_section, force

*Multiply by 100.
replace avg_trade_sh = 100 * avg_trade_sh
 
*Sort database.
*duplicates drop avg_trade_sh, force
gsort -avg_trade_sh
gen rank = _n 

*Generate description.
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

keep avg_trade_sh rank hs_section hsDesc_short

graph bar avg_trade_sh,	over(hsDesc_short, sort(hs_section) label(angle(45) labsize(small)) ) ///
	graphregion(color(white)) bgcolor(white) ytitle("") title("") bar(1, blwidth(thin) bcolor(orange))  intensity(75)
graph export "./output/graphs/final_files/sectoral_trade_sh.png", replace
graph export "./output/graphs/final_files/sectoral_trade_sh.eps", replace
graph export "./output/graphs/final_files/sectoral_trade_sh.pdf", replace

///////////////////////////////
///Fraction of world imports///
///////////////////////////////

*Open database.
use importer imports_baci panel_id mfn_binding year using "./temp_files/DataregW_did.dta", clear

*Declare panel.
xtset panel_id year

*Generate indicator for MFN.
gen ind = 1 if mfn_binding == 1 & L.mfn_binding == 1
replace ind = 0 if ind == .

*Drop early years.
keep if year>= 1996

*Generate counter for MFN.
gen count_mfn = 1

*Collapse database.
collapse (sum) imports_baci count_mfn, by(ind year)

*Generate sums.
bysort year: egen world_imports = sum(imports_baci)
bys year: egen tot_trade_obs = sum(count_mfn)

*Generate shares.
gen im_sh = imports_baci / world_imports
gen mfn_obs_sh = count_mfn/tot_trade_obs

*Generate decade variable.
gen decade = 1 if year>=1990 & year < 2000
replace decade = 2 if year>=2000 & year<2010
replace decade = 3  if year >=2010

*Generate mean by decade.
bysort ind decade: egen mean_im_sh = mean(im_sh)
bysort ind decade: egen mean_count_mfn_sh = mean(mfn_obs_sh)

*Drop duplicates.
duplicates drop ind decade, force

*Drop years.
drop year 

*Sort database.
sort decade ind

*Replace percentages.
replace mean_im_sh = 100 * mean_im_sh
replace mean_count_mfn_sh = 100*mean_count_mfn_sh

*Generate auxiliary datasets.
preserve
	keep if ind == 0
	keep decade mean_im_sh mean_count_mfn_sh
	rename mean_im_sh non_mfn_im_sh
	rename mean_count_mfn_sh non_mfn_obs_sh
	save "./output/graphs/temp_files/temp1.dta", replace
restore
preserve
	keep if ind == 1
	keep decade mean_im_sh mean_count_mfn_sh
	rename mean_im_sh mfn_im_sh 
	rename mean_count_mfn_sh mfn_obs_sh
	save "./output/graphs/temp_files/temp2.dta", replace
restore 

*Merge datasets.
use "./output/graphs/temp_files/temp1.dta", clear
merge 1:1 decade using "./output/graphs/temp_files/temp2.dta"

*Graph.
graph bar  mfn_im_sh mfn_obs_sh, over(decade, label(labsize(medium)) relabel(1 "1990s" 2 "2000s" 3 "2010s")) graphregion(color(white)) bgcolor(white) ytitle("") title("")	///
	bar(1, blwidth(vthin) bcolor(red)) bar(1, blwidth(vthin) bcolor(blue)) intensity(60) legend(order(1 "MFN share of trade value" 2 "MFN share of observations") col(1))
graph export "./output/graphs/final_files/mfn_import_summary.eps", replace
graph export "./output/graphs/final_files/mfn_import_summary.png", replace
graph export "./output/graphs/final_files/mfn_import_summary.pdf", replace

*Erase auxiliary datasets.
erase "./output/graphs/temp_files/temp1.dta"
erase "./output/graphs/temp_files/temp2.dta"

log close
