*! NJC 1.0.0 10 July 2002 
* _ggroup 2.0.4  19oct2000
program define _gegroup
	version 7
	gettoken type 0 : 0
	gettoken g    0 : 0
	gettoken eqs  0 : 0

	syntax varlist [if] [in] [, Missing BY(string) Label Label2(varlist) /*
		*/ Truncate(numlist max=1 int >= 1)]

	if `"`by'"' != "" {
		_egennoby egroup() `"`by'"'
		/* NOTREACHED */
	}

	if "`label'" != "" & "`label2'" != "" { 
		di as err "may not combine label and label() options" 
		exit 198 
	} 	

	if "`truncate'" != "" & "`label'`label2'" == "" {
		di as err "truncate() option requires a label option"
		exit 198
	}

	tempvar touse
	quietly {
		mark `touse' `if' `in'
		if "`missing'" == "" { 
			markout `touse' `varlist', strok
		}

		sort `touse' `varlist'
		quietly by `touse' `varlist': /*
			*/ gen `type' `g' = 1 if _n == 1 & `touse'
		replace `g' = sum(`g')
		replace `g' = . if `touse' != 1

		if "`label2'" != "" { 
			local label "label" 
			local varlist "`label2'" 
		} 
		
		if "`label'" != "" {
			local dfltfmt : set dp 
			local dfltfmt = /*
			*/ cond("`dfltfmt'" == "period","%9.0g","%9,0g")
			local truncate=cond("`truncate'" == "","80","`truncate'")

			count if !`touse'
			local j = 1 + r(N)
			sum `g', meanonly
			local max `r(max)'
			forval i = 1 / `max' {
				tokenize `varlist'
				local vtmp " "
				local x 1
				while "`1'" != "" {
					local vallab : value label `1'
					local val = `1'[`j']
					if "`vallab'" != "" {
local vtmp2 : label `vallab' `val' `truncate'
					}
					else {
						cap confirm numeric var `1' 
						if _rc == 0 {
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
			}
			label val `g' $EGEN_Varname
			if "`over'" != "" {
				noi di as txt _n /*
*/ "note: value labels exceed 80 characters and were truncated;" _n /* 
*/ "      use the truncate() option to control this"
			}
		}
	}

	if length("group(`varlist')") > 80 {
		note `g' : group(`varlist')
		label var `g' "see notes"
	}
	else 	label var `g' "group(`varlist')"
end
