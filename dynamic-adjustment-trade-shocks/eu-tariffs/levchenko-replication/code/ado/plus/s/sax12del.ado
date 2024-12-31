*! version 2011-Oct-31, brynewqy@nankai.edu.cn

program sax12del
version 11.0
syntax anything, [ drop(string) keep(string) ]
foreach fi of local anything {
	sapath "`fi'"
	local path = "`r(path1)'"
	local file = "`r(file1)'"
	tokenize "`file'", parse(".")
	local f "`1'"
	mata: sax12del("`path'", "`f'", "`drop'", "`keep'")
}
end
