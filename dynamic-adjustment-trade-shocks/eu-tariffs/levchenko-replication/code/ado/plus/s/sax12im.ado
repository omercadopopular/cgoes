*!version 1.1 2010-Sep-27, Q. Wang, brynewqy@nankai.edu.cn
program sax12im, rclass
version 11
syntax anything , [ ext(string) noFTVar tunit(string) update clear ]

`clear'
local rep = -1
if "`update'"!="" local rep = 0
// if "`replace'"!="" local rep = 1  // dropped in new version

// error checking
qui des
local n = r(N)
if `n'<=0 {  // no data in memory
	if "`tunit'"=="" {
		dis as err "You should specify the frequency by tunit() option if no data in memory!"
		exit 
	}
}

if "`ext'" == "" local ext "d10 d11 d12 d13"
// extract the prefix
foreach fi of local anything {
	local fip = subinstr("`fi'", ".out", "", .)
	tokenize "`fip'", parse("\")
	local i=1
	while "``i''"!="" {
		local ++i
	}
	local --i
	if `i'>1 {  // including path 
		local len = length("`fip'") - length("``i''") -1 
		local path = substr("`fip'",1,`len')
	}
	else {
		local path = "`c(pwd)'"
	}
	local f = trim("``i''")
	local files `files' `f'
	*local path = subinstr("`path'", "\", "`sep'", .)
	local sep = "\"
	if "`ftvar'"=="" {  // import as variable
		if `n'<=0 {  // no data in memory
			local k=1
			foreach e of local ext {
				capture confirm file "`path'`sep'`f'.`e'"
				if _rc!=0 {  // file not exist
					local dext `"`dext' "`path'`sep'`f'.`e'" "'
					continue
				}
				if `k'==1 {
					mata: sax12im("`path'`sep'`f'.`e'", "`tvar'", "`tunit'")
					qui tsset sdate, `tunit'
					local tdelta = r(tdelta)
				}
				else {
					mata: sax12im("`path'`sep'`f'.`e'", "sdate", "`tunit'", `tdelta', `rep')
				}
				local varlist "`varlist' `vall'"
				local varnew "`varnew' `vnew'"
				local k = `k'+1
			}
		}
		else {
			foreach e of local ext {
				qui tsset
				local tunit = "`r(unit)'"
				local tvar = "`r(timevar)'"
				local tdelta = r(tdelta)
				capture confirm file "`path'`sep'`f'.`e'"
				if _rc!=0 {
					local dext `"`dext' "`path'`sep'`f'.`e'" "'
					continue
				}
				mata: sax12im("`path'`sep'`f'.`e'", "`tvar'", "`tunit'", `tdelta', `rep')
				local varlist "`varlist' `vall'"
				local varnew "`varnew' `vnew'"
			}
		}
	}
	else {
		foreach e of local ext {
			capture confirm file "`path'`sep'`f'.`e'"
			if _rc!=0 {
				local dext `"`dext' "`path'`sep'`f'.`e'" "'
				continue
			}
			mata: sax12im("`path'`sep'`f'.`e'")
			local mats "`mats' `mat'"
		}
	}
}
if "`ftvar'" == "" {
	local varlist = trim(`"`varlist'"')
	local varnew = trim(`"`varnew'"')
	local varexist: list varlist - varnew
	local varexist = trim(`"`varexist'"')
	local nn: word count `varnew'
	if `nn'>0 {
		dis in gr "Variable(s) (" in ye "`varnew'" in gr ") imported"  
	}
	local ne: word count `varexist'
	if `ne'>0 {
		if "`update'"=="" {
			dis in gr "Variable(s) (" in ye "`varexist'" in gr ") already exist, no imported, use" in ye " update " in gr "option" 
		}
		else {
			dis in gr "Variable(s) (" in ye "`varexist'" in gr ") updated." 
		}
	}
	return local varlist `"`varlist'"'
	return local varnew `"`varnew'"'
	return local varexist `"`varexist'"'
}
else {
	return local mats `"`mats'"'
}
local nf: word count `dext'
if `nf'>0 {
	dis in gr "files(" in ye `"`dext'"' in gr ") not exist."
}
return local dext `"`dext'"'
end
