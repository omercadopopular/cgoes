*! egen truncdig()  cfb 3nov2016
capt prog drop _gtruncdig
prog def _gtruncdig
	version 12
	syntax newvarname =/exp [if] [in] , DIG(integer)
	tempvar touse
	tempname pwr
	qui{
		gen byte `touse'=1 `if' `in'
		sca `pwr' = 10^`dig' 
		gen `varlist' = 1/`pwr' * trunc(`exp' * `pwr') if `touse' == 1
		}
end
