*! 2.0.0 NJC 21 March 2006 
* 1.1.0 NJC 24 August 2005 
* 1.0.0 NJC 9 April 2002 
program _gfoy
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
		
		local limits mdy(`m', `d', `y'), mdy(`m',`d', `y' + 1) - 1
		local leap inrange(mdy(2, 29, `y'), `limits') 
		local leap (`leap' | inrange(mdy(2, 29, `y' + 1), `limits')) 
		
		cap assert `v' == int(`v') if `touse'  

		if _rc replace `g' = (`g' - 1) / (365 + `leap')
		else replace `g' = (`g' - 0.5) / (365 + `leap') 
	}			
end

/* 

   days are integers: 
   
   fraction of year = (day of year - 0.5) / # days in year 
   day of year      = 1 on 1 January, ... ,365 or 366 on 31 December 
   # days in year   = day of year of December 31 in same year 

   days are not integers: 

   fractional part = time after midnight as fraction of day 
   integer part gives day 
   
*/ 
   
