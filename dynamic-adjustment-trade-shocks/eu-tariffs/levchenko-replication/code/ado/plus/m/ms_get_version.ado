*! version 2.9.0 28mar2017
program ms_get_version
	syntax anything(name=ado), [min_version(string) min_date(string)]
	mata: st_local("package_version", get_version("`ado'"))
	c_local package_version "`package_version'"

	loc _ `package_version'
	gettoken version_number _ : _
	gettoken version_date _ : _
	c_local version_number "`version_number'"
	c_local version_date "`version_date'"

	if ("`min_version'" != "") {
		* This is not very flexible; only accepts x.y.z versioning schemes
		loc ok 0
		cap mata: st_local("ok", strofreal(strtoreal(tokens(subinstr("`version_number'", ".", " "))) * (1e5, 1e3, 1)' >= strtoreal(tokens(subinstr("`min_version'", ".", " "))) * (1e5, 1e3, 1)'))
		_assert `ok', msg("you are using version `version_number' of `ado', but require version `min_version'")
	}
	
	if ("`min_date'" != "") {
		* This is not very flexible; only accepts 1jan2018/01Jan2018 versioning schemes
		loc ok = !mi(date("`version_date'", "DMY")) & (date("`version_date'", "DMY") >= date("`min_date'", "DMY"))
		_assert `ok', msg("you are using `ado' from `version_date', but require a version from at `min_date' or later")
	}
end

mata:
	string scalar get_version(string scalar ado)
	{
		real scalar fh
		string scalar line
		string scalar fn
		fn = findfile(ado + ".ado", c("adopath"))
		if (fn == "") {
			printf("{err}file not found: %s.ado\n", ado)
			exit(123)
		}
		fh = fopen(fn, "r")
		line = fget(fh)
		fclose(fh)
		line = strtrim(line)

		line = subinstr(line, "*!version ", "*! version ") // helps with rdrobust
		
		if (strpos(line, "*! version ")) {
			line = strtrim(substr(line, 1 + strlen("*! version "), .))
			return(line)
		}
		
		if (strpos(line, sprintf("*! %s ", ado) )) {
			line = strtrim(substr(line, 1 + strlen(sprintf("*! %s ", ado) ), .))
			return(line)
		}
		else {
			printf("{err}no version line found for %s\n", ado)
			return("")
		}
	}
end
