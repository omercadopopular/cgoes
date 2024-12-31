*! version 1.3.0  16 June 1997
* Nicholas J. Cox, University of Durham
* creates sequences of integers
program define seq
	version 4.0
	local varlist "req new max(1)"
	local if "opt"
	local in "opt"
	local options "by(string) Block(int 1) From(int 1) To(int 0)"
	parse "`*'"
    if `to' == 0 { local to = _N }
    if `block' < 1 {
        qui drop `varlist'
        di in r "block should be at least 1"
        exit 498
    }
    if `from' > `to' {
        local temp = `from'
        local from = `to'
        local to = `temp'
    }
	tempvar touse
	quietly {
		gen byte `touse' = 1 `if' `in'
		sort `touse' `by'
        #delimit ;
		by `touse' `by':
		replace `varlist'
		= `from' + int(mod((_n - 1) / `block', `to' - `from' + 1))
		if `touse' ;
		#delimit cr
        if "`temp'" != "" {
            replace `varlist' = `to' + `from' - `varlist'
        }
        compress `varlist'
    }
end
