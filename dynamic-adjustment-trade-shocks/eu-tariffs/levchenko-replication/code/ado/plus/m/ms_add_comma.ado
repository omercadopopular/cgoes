*! version 2.32.0 25jan2019
* Sometimes we want to add an option to a command, but it's hard to know if it already has a comma or not

/* EG:
sysuse auto, clear
ms_add_comma, loc(cmd) cmd("tab turn") opt("sort") -> stores "tab turn, sort" in local -cmd-
ms_add_comma, loc(cmd) cmd("tab turn, nolabel") opt("sort") -> stores "tab turn, nolabel sort" in local -cmd-
*/

program define ms_add_comma
	syntax, [cmd(string)] [opt(string)] LOCal(name local)
	cap TryWithComma `cmd' , `opt'
	loc comma = cond(c(rc) | (`"`opt'"'== ""), "", ",")
	if ("`cmd'" == "") & ("`opt'" != "") loc comma ","
	c_local `local' `cmd'`comma' `opt'
end

program define TryWithComma
	syntax anything(everything equalok), [*]
end
