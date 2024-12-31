clear all
set more off

cap log close
log using "./output/logs/log_d12.smcl", append

*Import GTAP data.
import excel using "./data/OssaElasticities/concordanceGTAP_HS/8171.xls", first

*Generate HS2 code.
gen hs2 = substr(HS6code,1,2)
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
	
*Generate counter.
gen counter = 1

*Collapse by HS section.
collapse (sum) counter, by(hs_section GTAP)

*Label counter.
label var counter "Number of HS6 in the Section-GTAP pair"

*Save database.
rename GTAP GTAP
save "./temp_files/section_GTAP_concord.dta", replace

*Import Ossa elasticities.
import excel using "./data/OssaElasticities/ossa_elasticities.xlsx", first clear

*Split code.
split gtapcode, gen(stub) parse(",")

*Reshape database.
reshape long stub, i(gtapcode) j(id)
drop if stub==""
drop gtapcode id
rename stub GTAP

*Join with GTAP concordance.
joinby GTAP using "./temp_files/section_GTAP_concord.dta"
sort hs_section
sort GTAP

*Keep sections.
*7, 8, 9, 10, 11, 13, 15, 16, 18, 20, _agg
replace hs_section=99 if !inlist(hs_section,7,8,9,10,11,13,15,16,18,20)

*Collapse elasticities.
bys hs_section: egen tot_count_insection = total(counter)
gen w = counter/tot_count_insection
gen sigma_w = w*sigma
collapse (sum) sigma_w (mean) sigma, by(hs_section)

*Save Ossa elasticities database (converted to HS sections).
outsheet using "./temp_files/ossa_converted_hssections.csv", comma replace
