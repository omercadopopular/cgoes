clear all
set more off

cap log close
log using "./output/logs/log_d13.smcl", append

/////////////////////////
///HS-ISIC Concordance///
/////////////////////////

*Import database.
import excel using "./data/OECD_ICIO/ConversionKeyBTDIxE4PUB.xlsx", sheet(FromHSToISICToEC) first clear

*Use latest classification.
keep if HS==4

*Drop others.
drop if Desci4 == "Unallocated"
drop if Desci4 == "Others"
drop if Desci4 == "Wastes"
drop if HS2digit=="AD"

*Keep HS and ISIC codes.
keep HS2digit Desci4

*Generate counter (number of HS6 digit within each HS2digit - Desci4 pairs).
gen counter = 1

*Collapse.
replace Desci4=subinstr(Desci4," used","",.)
collapse (sum) counter, by(HS2digit Desci4)

*Destring HS code.
destring HS2digit,  replace
rename HS2digit hs2_num

*Generate HS section.
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

*Collapse.
collapse (sum) counter, by(Desci4 hs_section)
sort Desci4 hs_section
bys hs_section: egen tot_count = total(counter)
gen sh_count = counter/tot_count

*Drop first letter of ISIC code.
replace Desci4=substr(Desci4,2,.)

*Drop ISIC codes with small shares.
drop if Desci4=="10T33" // only small portions
drop if Desci4=="241T31" 
drop if Desci4=="242T32"

gen sector = ""
replace sector = "01T03" if inlist(Desci4,"01","02","03","01T02")
replace sector = "05T06" if inlist(Desci4,"05","06")
replace sector = "07T08" if inlist(Desci4,"07","08","071","072")
replace sector = "10T12" if inlist(Desci4,"10","11","12")
replace sector = "13T15" if inlist(Desci4,"13","14","15","13T15")
replace sector = "16" if inlist(Desci4,"16")
replace sector = "17T18" if inlist(Desci4,"17","18","181","182")
replace sector = "19" if inlist(Desci4,"19")
replace sector = "20T21" if inlist(Desci4,"20","21")
replace sector = "22" if inlist(Desci4,"22")
replace sector = "23" if inlist(Desci4,"23")
replace sector = "24" if inlist(Desci4,"24","24T25")
replace sector = "25" if inlist(Desci4,"25","25X","252")
replace sector = "26" if substr(Desci4,1,2)=="26"
replace sector = "27" if substr(Desci4,1,2)=="27"
replace sector = "28" if Desci4=="28"
replace sector = "29" if inlist(Desci4,"29","29T30")
replace sector = "30" if inlist(Desci4,"30","301","302A9","303","304")
replace sector = "31T33" if inlist(Desci4,"31","32","325","32X")
replace sector = "35T39" if inlist(Desci4,"35","38")
*replace sector = "41T43" 
*replace sector = "45T47" 
*replace sector = "49T53" 
*replace sector = "55T56" 
replace sector = "58T60" if inlist(Desci4,"58","581","59")
*replace sector = "61" 
*replace sector = "62T63" 
*replace sector = "54T66" 
*replace sector = "68"
*replace sector = "69T82" 
*replace sector = "84"
*replace sector = "85"  
*replace sector = "86T88" 
*replace sector = "90T96" 
*replace sector = "97T98" 

*Collapse.
collapse (sum) counter, by(sector hs_section)

*Save database.
save "./temp_files/conc_sector_hssection.dta", replace

//////////
///WIOD///
//////////

*Import dataset.
import delimited "./data/WIOD/WIOT2006_Nov16_ROW.csv", clear 

*Drop rows and variables.
drop in 1/4
drop v1 v2 v4

*Rename variables.
replace v3="v3" if v3==""
replace v5="v5" if v5==""
replace v6="v6" if v6==""
foreach v of varlist _all {
    local newname = "_" + `v'[1] + "_" + `v'[2]
    rename `v' `newname'
}
drop in 1/2

*Generate source country and sector.
rename _v3_v3 source_sw  //this is "row_name"
rename _v5_v5 source_c
gen row_item = substr(_v6_v6,2,3)  //this is "row_item" (which is just a sector number)
drop _v6_v6
order source_sw source_c row_item
drop source_sw

*Rename total.
*rename _TOT_c62 TOT

*Destring variables.
foreach var of varlist _all{
	qui destring `var',replace
}

*Only keep final goods.
forvalues c=1(1)56{
    drop _*_c`c'
}

*Generate total consumption by country. NP -- this is total consumption by the column country of the source_c (row country)'s output in the row sector
levelsof source_c, local(country)
foreach c of local country{
	egen _`c'_tot=rowtotal(_`c'_c*)
	drop _`c'_c*
}

*Generate aggregate ISIC code.
gen sector = ""
replace sector = "01T03" 	if row_item>=1 & row_item<=3
replace sector = "05T06" 	if row_item==4
replace sector = "07T08" 	if row_item==4
replace sector = "10T12" 	if row_item==5
replace sector = "13T15" 	if row_item==6
replace sector = "16" 	 	if row_item==7
replace sector = "17T18" 	if row_item>=8 & row_item<=9
replace sector = "19" 	 	if row_item==10
replace sector = "20T21" 	if row_item>=11 & row_item<=12
replace sector = "22" 		if row_item==13
replace sector = "23" 		if row_item==14
replace sector = "24" 		if row_item==15
replace sector = "25" 		if row_item==16
replace sector = "26" 		if row_item==17
replace sector = "27" 		if row_item==18
replace sector = "28" 		if row_item==19
replace sector = "29" 		if row_item==20
replace sector = "30" 		if row_item==21
replace sector = "31T33" 	if row_item>=22 & row_item<=23
replace sector = "35T39" 	if row_item>=24 & row_item<=26
replace sector = "41T43" 	if row_item==27
replace sector = "45T47" 	if row_item>=28 & row_item<=30
replace sector = "49T53" 	if row_item>=31 & row_item<=35
*replace sector = "55T56" 	if row_item==36
*replace sector = "58T60" 	if row_item>=37 & row_item<=38
*replace sector = "61" 		if row_item==39
*replace sector = "62T63" 	if row_item==40
replace sector = "54T66" 	if row_item>=36 & row_item<=43
replace sector = "68" 		if row_item==44
replace sector = "69T82" 	if row_item>=45 & row_item<=50
replace sector = "84" 		if row_item==51
replace sector = "85"  		if row_item==52
replace sector = "86T88" 	if row_item==53
replace sector = "90T96" 	if row_item==54
replace sector = "97T98" 	if row_item==55

*Drop variable.
drop row_item
drop if sector==""

*Drop total.
drop _TOT_tot

*Reshape database.
rename _*_tot tot_*
collapse (sum) tot_*, by(source_c sector)
reshape long tot_, i(source_c sector) j(dest_c, str)

*Generate imports.
gen value_0=.
replace value_0=tot_ if source_c!=dest_c

*Generate own production.
gen value_1=.
replace value_1=tot_ if source_c==dest_c

*Collapse database.
collapse (sum) value_0 value_1, by(dest_c sector)

*Save intermediate database.
save "./temp_files/wiod_int.dta", replace

/////////////////////
///WIOD + HS Codes///
/////////////////////

/*

A. Agriculture; forestry and fishing

01 – Crop and animal production, hunting and related service activities

02 – Forestry and logging

03 – Fishing and aquaculture
B. Mining and quarrying

05 – Mining of coal and lignite

06 – Extraction of crude petroleum and natural gas

07 – Mining of metal ores

08 – Other mining and quarrying

09 – Mining support service activities
C. Manufacturing

10 – Manufacture of food products

11 – Manufacture of beverages

12 – Manufacture of tobacco products

13 – Manufacture of textiles

14 – Manufacture of wearing apparel

15 – Manufacture of leather and related products

16 – Manufacture of wood and of products of wood and cork, except furniture; manufacture of articles of straw and plaiting materials

17 – Manufacture of paper and paper products

18 – Printing and reproduction of recorded media

19 – Manufacture of coke and refined petroleum products

20 – Manufacture of chemicals and chemical products

21 – Manufacture of pharmaceuticals, medicinal chemical and botanical products

22 – Manufacture of rubber and plastics products

23 – Manufacture of other non-metallic mineral products

24 – Manufacture of basic metals

25 – Manufacture of fabricated metal products, except machinery and equipment

26 – Manufacture of computer, electronic and optical products

27 – Manufacture of electrical equipment

28 – Manufacture of machinery and equipment n.e.c.

29 – Manufacture of motor vehicles, trailers and semi-trailers

30 – Manufacture of other transport equipment

31 – Manufacture of furniture

32 – Other manufacturing

33 – Repair and installation of machinery and equipment
D. Electricity; gas, steam and air conditioning supply

35 – Electricity, gas, steam and air conditioning supply
E. Water supply; sewerage, waste management and remediation activities

36 – Water collection, treatment and supply

37 – Sewerage

38 – Waste collection, treatment and disposal activities; materials recovery

39 – Remediation activities and other waste management services
F. Construction

41 – Construction of buildings

42 – Civil engineering

43 – Specialized construction activities
G. Wholesale and retail trade; repair of motor vehicles and motorcycles

45 – Wholesale and retail trade and repair of motor vehicles and motorcycles

46 – Wholesale trade, except of motor vehicles and motorcycles

47 – Retail trade, except of motor vehicles and motorcycles
H. Transportation and storage

49 – Land transport and transport via pipelines

50 – Water transport

51 – Air transport

52 – Warehousing and support activities for transportation

53 – Postal and courier activities
I. Accommodation and food service activities

55 – Accommodation

56 – Food and beverage service activities
J. Information and communication

58 – Publishing activities

59 – Motion picture, video and television programme production, sound recording and music publishing activities

60 – Programming and broadcasting activities

61 – Telecommunications

62 – Computer programming, consultancy and related activities

63 – Information service activities
K. Financial and insurance activities

64 – Financial service activities, except insurance and pension funding

65 – Insurance, reinsurance and pension funding, except compulsory social security

66 – Activities auxiliary to financial service and insurance activities
L. Real estate activities

68 – Real estate activities
M. Professional, scientific and technical activities

69 – Legal and accounting activities

70 – Activities of head offices; management consultancy activities

71 – Architectural and engineering activities; technical testing and analysis

72 – Scientific research and development

73 – Advertising and market research

74 – Other professional, scientific and technical activities

75 – Veterinary activities
N. Administrative and support service activities

77 – Rental and leasing activities

78 – Employment activities

79 – Travel agency, tour operator, reservation service and related activities

80 – Security and investigation activities

81 – Services to buildings and landscape activities

82 – Office administrative, office support and other business support activities
O. Public administration and defence; compulsory social security

84 – Public administration and defence; compulsory social security
P. Education

85 – Education
Q. Human health and social work activities

86 – Human health activities

87 – Residential care activities

88 – Social work activities without accommodation
R. Arts, entertainment and recreation

90 – Creative, arts and entertainment activities

91 – Libraries, archives, museums and other cultural activities

92 – Gambling and betting activities

93 – Sports activities and amusement and recreation activities
S. Other service activities

94 – Activities of membership organizations

95 – Repair of computers and personal and household goods

96 – Other personal service activities
T. Activities of households as employers; undifferentiated goods- and services-producing activities of households for own use

97 – Activities of households as employers of domestic personnel

98 – Undifferentiated goods- and services-producing activities of private households for own use
U. Activities of extraterritorial organizations and bodies

99 – Activities of extraterritorial organizations and bodies
Not elsewhere classified
X. Not elsewhere classified

*/

*Open intermediate WIOD database.
use "./temp_files/wiod_int.dta", clear

*Merge with HS section.
joinby sector using "./temp_files/conc_sector_hssection.dta", unm(both)
replace hs_section=99 if _m!=3

*Generate total imports and shares.
bys dest_c sector: egen tot_val_0 = total(value_0)
gen sh_val0 = value_0/tot_val_0

*Generate total own consumption and shares.
bys dest_c sector: egen tot_val_1 = total(value_1)
gen sh_val1 = value_1/tot_val_1

*Generate weighted values.
replace value_0=sh_val0*value_0
replace value_1=sh_val1*value_1

*Replace section.
replace hs_section=99 if !inlist(hs_section,4,6,7,8,10,11,12,13,16)

*Collapse.
collapse (sum) value_0 value_1, by(hs_section dest_c)

*Generate total value.
gen value = value_0+value_1

*Generate own consumption share.
gen lambda = value_1/(value_0+value_1)

*Generate consumption share.
bys dest_c: egen totval = total(value)
gen cons_sh = value/totval

*Save database.
sort dest_c hs_section
drop if dest_c==""
save "./temp_files/lambda_conssh_section.dta", replace

preserve
keep dest_c hs_section lambda cons_sh
reshape wide lambda cons_sh, i(dest_c) j(hs_section)

export excel dest_c lambda* using "./temp_files/WIOD_shares.xlsx", sheet(lambda) firstrow(vari) sheetreplace
export excel dest_c cons_sh* using "./temp_files/WIOD_shares.xlsx", sheet(cons_sh) firstrow(vari) sheetreplace
restore

collapse (sum) value*, by(dest_c)
gen lambda = value_1/(value_0+value_1)
export excel dest_c lambda using "./temp_files/WIOD_shares.xlsx", sheet(lambda_agg) firstrow(vari) sheetreplace

