*! version 1.1 Dezember 8, 2016 @ 14:13:57
*! Show variable documentation from the Internet
program psid_vardoc
version 13
	syntax varname [, ADDvaluelabel(string) Show itemnum(int 0)]
	
	local item : word 1 of `: char `varlist'[items1]'
	if strpos("`item'","CNEF") | "`item'" == "" {
		di "{txt}`varlist' not in the PSID Data Center"
		exit
		}
	
	// Check Internet connection
	capture net 
	if _rc == 631 {
		di `"{err} Internet connection required"'
		exit 631
		}

	// Check Information present
	if `_dta[psid_keepnotes]' != 1 {
		di `"{err} Requires variable to be retrived with option -keepnotes-"'
		exit 189
		}
	
	// OS dependent settings
	if c(os)=="Unix" {								
		local open xdg-open
		local back ">& /dev/null &"
		}
	else if c(os)=="Windows" {
		local open start
		}
	else if c(os)=="MacOSX" {
		local open open
		}

	// Option show
	local show = cond(`"`addvaluelabel'"' == `""' | `"`show'"' != `""',1,0)  
	
	// Main code
	local lastitem: word count `: char `varlist'[items1]'
	if !`itemnum' local itemnum `lastitem'
	local CNEF = "`: word 1 of `: char `varlist'[items1]''" == "CNEF"

	local item : word `itemnum' of `: char `varlist'[items1]'
	if !strpos("`item'","CNEF") & `show' {
		! `open' http://simba.isr.umich.edu/cb.aspx?vList=`item' `back'
		}

	// Addvaluelabel
	if "`addvaluelabel'" != "" {
		tempfile htmlfile cleaned
		tempname html 
		copy `"http://simba.isr.umich.edu/cb.aspx?vList=`item'"' `htmlfile'
		filefilter `htmlfile' `cleaned', from(`""\RQ"') to(`"""')
		
		file open `html' using `cleaned', read
		file read `html' line
		while r(eof)==0 {
			if regexm(`"`macval(line)'"',`".+"codeValue".+>([0-9]+)+<"') {
				local num = real(regexs(1))
				file read `html' line
				if regexm(`"`macval(line)'"',`".+"codeText".+>(.+)<"') {
					local label = regexs(1)
					label define `addvaluelabel' `num' `"`label'"', modify
					file read `html' line
					}
				}
			else {
				file read `html' line
				}
			}
		file close `html'

		capture label list `addvaluelabel' 
		if !_rc {
			label value `varlist' `addvaluelabel'
			di `"{txt}Label {res}`addvaluelabel'{txt} attached to {res}`varlist'{txt} and defined as:"'
			label list `addvaluelabel'
			}
		else {
			di "{txt}Value label `addvaluelabel' could not be defined"
			}
		}
		
	end
	exit
