*!version 1.0 2011-Jan-9, Qunyong Wang, brynewqy@nankai.edu.cn
program sax12diag
version 11.1
syntax anything [using/], [noPRINT]
local prt = cond("`print'"=="noprint", 0, 1)
if `"`using'"'=="" {
	mata: sax12diag(tokens(`" `anything' "'), `prt')
}
else {
	tokenize `"`using'"', parse("\/")
	local i=1
	while ("``i''"!="") {
		local i=`i'+1
	}
	local i=`i'-1
	local fn = "``i''"
	capture findfile `"`fn'"'
	if _rc==0 {
		window stopbox rusure `" `using' alreay exist, continue will replace it. Are your sure?"'
	}
	if _rc {
		capture erase `"`using'"'
	}
	mata: sax12diag(tokens(`" `anything' "'), `prt', `"`using'"')
}

end
