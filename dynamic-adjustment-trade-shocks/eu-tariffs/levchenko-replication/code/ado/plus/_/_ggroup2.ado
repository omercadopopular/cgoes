*! NJC 20 Sept 2001  
*! version 2.0.4  19oct2000
program define _ggroup2
	version 7
	gettoken type 0 : 0
	gettoken g    0 : 0
	gettoken eqs  0 : 0

	syntax varlist [if] [in] [, Missing BY(string) Label /*
		*/ Truncate(numlist max=1 int >= 1) SOrt(str) ]

	if `"`by'"' != "" {
		_egennoby group() `"`by'"'
		/* NOTREACHED */
	}

	if "`truncate'" != "" & "`label'" == "" {
		di as err "truncate() option requires the label option"
		exit 198
	}

	tempvar touse
	quietly {
		mark `touse' `if' `in'
		if "`missing'"=="" { 
			markout `touse' `varlist', strok
		}

		if "`sort'" != "" { 
			tempvar sresult
			local hold "$EGEN_Varname"
			capture egen `sresult' = `sort', by(`touse' `varlist')  
			global EGEN_Varname `hold' 
			if _rc { 
				di as err "invalid sort(`sort')" 
				exit 198 
			}
			local stext " by `sort'" 
		}
		* `sresult' will be blank if -sort()- not used
		* `stext' ditto 
				
		sort `touse' `sresult' `varlist'
		quietly by `touse' `sresult' `varlist': /*
			*/ gen `type' `g'=1 if _n==1 & `touse'
		replace `g'=sum(`g')
		replace `g'=. if `touse'!=1
		
		if "`label'"!="" {
			local dfltfmt : set dp 
			local dfltfmt = /*
				*/ cond("`dfltfmt'"=="period","%9.0g","%9,0g")
			local truncate=cond("`truncate'"=="","80","`truncate'")

			count if !`touse'
			local j = 1 + r(N)
			sum `g', meanonly
			local max `r(max)'
			local i 1
			while `i' <= `max' {
				tokenize `varlist'
				local vtmp " "
				local x 1
				while "`1'"!="" {
					local vallab : value label `1'
					local val = `1'[`j']
					if "`vallab'" != "" {
local vtmp2 : label `vallab' `val' `truncate'
					}
					else {
						cap confirm numeric var `1' 
						if _rc==0 {
local vtmp2 = string(`1'[`j'],"`dfltfmt'") 
						}
						else {
local vtmp2 = trim(substr(trim(`1'[`j']),1,`truncate'))
						}
					}
					local x = `x' + length("`vtmp2'") + 1
					local vtmp "`vtmp' `vtmp2'"
					mac shift
				}

				if `x' >= 80 {
					local over = "over"
				}
				local val `vtmp'
				label def $EGEN_Varname `i' "`val'", modify
				count if `g' == `i'
				local j = `j' + r(N)
				local i = `i' + 1
			}
			label val `g' $EGEN_Varname
			if "`over'" != "" {
				noi di as txt _n /*
*/ "note: value labels exceed 80 characters and were truncated;" _n /* 
*/ "      use the truncate() option to control this"
			}
		}
	}

	if length("group(`varlist'`stext')") > 80 {
		note `g' : group(`varlist'`stext')
		label var `g' "see notes"
	}
	else 	label var `g' "group(`varlist'`stext')"
end
