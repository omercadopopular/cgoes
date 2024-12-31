*! 1.0.0 NJC 21 March 2006 
program _gdayofyear 
	version 8 
	gettoken type 0 : 0
	gettoken g 0 : 0
	gettoken eqs 0 : 0			
	syntax varname(numeric) [if] [in] [, Month(int 1) Day(int 1) ] 
	local v "`varlist'" 
	local m = `month' 
	local d = `day' 
	marksample touse

	quietly { 
		tempvar y 
		gen `y' = year(`v') if `touse' 
		replace `y' = `y' - 1 if mdy(`m', `d', `y') > `v' 
		gen `g' = `v' - mdy(`m', `d', `y') + 1 if `touse' 
	}			
end

