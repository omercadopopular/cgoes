*! NJC 1.1.0 23jan2004
*! NJC 1.0.0 28nov2003
program _gdensity 
	version 8
	gettoken type 0 : 0
	gettoken g 0 : 0
	gettoken eqs 0 : 0
	syntax varname(numeric) [if] [in] ///
	[, Width(numlist max=1 >0) BY(varlist) STart(numlist max=1) ///
	FREQuency PERCENT FRACtion DENsity]

	local opts `density' `fraction' `frequency' `percent' 
	local nopts : word count `opts'
	
	if `nopts' >= 2 { 
		di as err "options `opts' may not be combined" 
		exit 198 
	}	
	else if `nopts' == 1 local option `opts'
	else if `nopts' == 0 local option "density"
	
	if "`width'" == "" local width 1 
	
	tempvar ry sum      
	quietly {
		marksample touse
		if "`start'" == "" { 
			su `varlist' if `touse', meanonly 
			local start = r(min) 
		} 	
		gen double `ry' = ///
			`width' * floor((`varlist' - `start') / `width') 
		bysort `touse' `by' `ry' : gen `type' `g' = _N if `touse' 
		
		if "`option'" == "frequency" exit 0 
		else if "`option'" == "fraction" { 
			by `touse' `by' `ry' : gen double `sum' = `g' * (_n == 1) 
			by `touse' `by' : replace `sum' = sum(`sum')
			by `touse' `by' : replace `g' = `g' / `sum'[_N] 
			exit 0 
		} 	
		else if "`option'" == "percent" { 
			by `touse' `by' `ry' : gen double `sum' = `g' * (_n == 1) 
			by `touse' `by' : replace `sum' = sum(`sum')
			by `touse' `by' : replace `g' = 100 * `g' / `sum'[_N] 
			exit 0 
		}
		else if "`option'" == "density" { 
			by `touse' `by' : replace `g' = `g' / (`width' * _N)
			exit 0 
		}	
		// not reached 
	}
end
