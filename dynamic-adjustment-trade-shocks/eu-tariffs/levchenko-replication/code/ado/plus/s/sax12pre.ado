*! version 2011-Nov-22, brynewqy@nankai.edu.cn
program sax12pre
	version 11.0
	syntax [varlist]
	if "`varlist'" != "" {
		unab varlist : `varlist'
		.sax12_dlg.variables.Arrdropall
		foreach v of local varlist {
			capture confirm numeric variable  `v'
			if ! _rc {
				.sax12_dlg.variables.Arrpush "`v'"
			}
		}
	}

	// save time unit in global
	capture qui tsset
	global tunit = "`r(unit)'"
end
