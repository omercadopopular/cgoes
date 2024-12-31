// This is just a prototype

program define ftab
	syntax varlist [if] [in] , ///
		[SELect(str) Order(str)] ///
		[Missing] ///
		[Verbose]

	loc verbose = ("`verbose'" != "")
	
	// Trim data
	if ("`missing'" == "") {
		marksample touse, strok
	}
	else if ("`if'`in'" != "") {
		marksample touse, strok novarlist
	}

	//tempname table
	mata: ftab("`varlist'", "`touse'", "`table'", `verbose')
	ParseSelect, select(`select') order(`order')
	di as error "`select'-`Select'-`Selectint'-`order'"
	//Display, variable(`varlist') table(`table')
end


program ParseSelect
* Taken from groups.ado from njc (!!!)
	// select option 
	syntax, [select(str) order(str)]
	if "`select'" != "" {
	        if real("`select'") < . { 
	                capture confirm integer number `select' 
	                if _rc { 
	                        di as inp "`select' " ///
	                           as err "invalid argument for " /// 
	                           as inp "select()" 
	                        exit 198 
	                }       
	                local Selectint 1
	        } 
	        else {
	                tokenize "`select'", parse(" ><=") 
	                local w "`1'"  
	                local W : subinstr local select "`w'" ""
	                
	                if lower(substr("`w'",1,1)) == "r" { 
	                        local w = lower("`w'") 
	                }       

	                local OK 0 
	                foreach s in freq percent Freq Percent rfreq ///
	                        rpercent vpercent Vpercent rvpercent { 
	                        if "`w'" == substr("`s'",1,length("`w'")) { 
	                                local OK 1 
	                                local Select "``s''" 
	                                continue, break 
	                        }
	                }       
	                
	                // selection should specify an equality or inequality 
	                qui count if 1 `W' 
	                if _rc | !`OK' { 
	                        di as inp "`select' " ///
	                           as err "invalid argument for " /// 
	                           as inp "select()"
	                        exit 198 
	                }       

	                local Selectint 0 
	        }       
	}
	c_local Select `Select' 
	c_local Selectint `Selectint' 

	// order option 
	if "`order'" != "" { 
	        if `: word count `order'' > 1 { 
	                di as err "invalid " as inp "order()" as err "option"
	                exit 198 
	        } 
	        
	        local orderlist "h hi hig high l lo low" 
	        if !`: list order in orderlist' { 
	                di as inp "`order' " ///
	                   as err "invalid argument for " /// 
	                   as inp "order()"
	                exit 198    
	        }
	        local order = substr("`order'",1,1) 
	}
	c_local order `order'
end


program define Display
	syntax, variable(name) table(name)
	tempname mytab


	loc label : var label `variable'
	loc cols : rownames `table' , quoted
	loc rows : colnames `table' , quoted
	
	// Raw
	matrix list `table', title(`label') format(%8.2g)

	// More detailed
	// TODO: WRAP HEADER
	di
	.`mytab' = ._tab.new, col(4) lmargin(2) comma
	.`mytab'.width 		13	|	12			12			12
	.`mytab'.pad    	 .    	2			2 			2
	.`mytab'.numfmt    	 .    	%8.0g		%8.0g 		%4.2f
	.`mytab'.titlefmt   %12s 	    %8s			%8s			%8s
	.`mytab'.sep, top
	.`mytab'.titles "`label'" `rows'
	// .`mytab'.row "" `table'[1, 1] `table'[1, 2] `table'[1, 3]

end


findfile "ftools.mata"
include "`r(fn)'"

mata:
mata set matastrict on

void ftab(`Varname' var,
          `String' touse,
          `String' mat_name,
          `Boolean' verbose)
{
	`Factor' 		F
	`Vector' 		perc, smpl
	`Matrix' 		ans
	`StringMatrix' 	keys
	//`StringMatrix' 	rowstripe, colstripe

	F = factor(var, touse, verbose)
	smpl = F.counts :> 50
	perc = F.counts :/ colsum(F.counts) :* 100
	ans = F.counts, perc, runningsum(perc)
	//sums = runningsum(F.counts)
	//perc = sums :/ sums[rows(sums)] :* 100

	ans = select(ans, smpl)
	keys = select(isreal(F.keys) ? strofreal(F.keys) : F.keys, smpl)

	// Sort; recycle smpl vector
	smpl = order(ans, -1)
	ans = ans[smpl, .]
	keys = keys[smpl]

	mm_matlist(ans \ (colsum(ans[., 1..2]), 100),
	           ("%g", "%6.2f", "%6.2f"),
	           3,
	           keys \ "Total",
	           ("Freq.", "Percent", "Cum."), F.varlist) // we could use F.varlabels

	//st_matrix(mat_name, (F.counts, sums, perc))
	//rowstripe = J(rows(F.keys), 1, ""), (isreal(F.keys) ? strofreal(F.keys) : F.keys)
	//colstripe = ("", "", "" \ "Freq.", "Percent", "Cum.")'
	//st_matrixcolstripe(mat_name, colstripe)
	//st_matrixrowstripe(mat_name, rowstripe)
}
end

exit

* Tests
cap ado uninstall ftools
net install ftools, from("C:/git/ftools/src")

clear all
sysuse auto
//la var turn "this is a very very VERY long label"
tab turn
ftab turn

* Benchmark
