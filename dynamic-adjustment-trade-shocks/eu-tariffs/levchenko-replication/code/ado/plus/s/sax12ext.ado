*! version 2011-Nov-22, brynewqy@nankai.edu.cn
program sax12ext
	version 11.0
	syntax [anything]
	if `"`anything'"'!=`""' {
		sapath "`anything'"
		local path = "`r(path1)'"
		local file = "`r(file1)'"
		tokenize "`file'", parse(".")
		local f "`1'"
		local ext ""
		mata: sax12ext("`path'", "`f'", "ext")
		.sax12del_dlg.extlist.Arrdropall
		foreach v of local ext {
			.sax12del_dlg.extlist.Arrpush "`v'"
		}
	}
end
