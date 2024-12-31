clear all
set more off

cap log close
log using "./output/logs/log_t02.smcl", append

//////////////////////////////////////////////
///Fraction of HS codes with unique mapping///
//////////////////////////////////////////////

preserve
	
	*Define matrix.
	matrix matres = J(5,5,.)
	local c=1
	foreach i in "92" "96" "02" "07" "12" { 
		local r=1
		foreach j in "96" "02" "07" "12" "17"{ 
			
			*Check if file exists.
			capture confirm file "./data/HS_concordances/HS`j'HS`i'.xls" 
			
			if _rc==0 {
				
				dis("HS`j'HS`i'")
				
				*Import file.
				import excel "./data/HS_concordances/HS`j'HS`i'.xls", firstrow allstring clear
				
				*Generate relationship variable.
				g byte rel=(Relationship=="1 to 1")
				replace rel=1 if Relationship=="'1:1" 
				replace rel=1 if Relationship=="1:1" 
				qui sum rel
				
				*Drop duplicates.
				bys hs`j': gen dup=_n
				drop if dup!=1
				drop dup
				qui sum rel
				dis("`r' and `c'")
				
				*Save matrix.
				mat matres[`r'+`c'-1,`c']=`r(mean)'
				local r=`r'+1
			}
			else {
				dis("File does not exist")
			}
		}
		local c = `c'+1
	}

	matrix rownames matres = H96 H02 H07 H12 H17
	matrix colnames matres = H92 H96 H02 H07 H12
	putexcel set "./output/tables/matrix_concordances.xlsx", sheet(concordances) modify
	putexcel A1 = matrix(matres*100), names nformat(number_d2)
	
restore 
