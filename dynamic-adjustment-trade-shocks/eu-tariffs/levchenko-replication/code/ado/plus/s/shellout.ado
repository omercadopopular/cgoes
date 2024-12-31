*! shellout 1.4 04Aug2008
*! by roywada@hotmail.com
*! originally written to accompany -outreg2-
*
* version history
* 1.0 Oct2005   beta
* 1.1 Nov2007   opens an application without document name
*                       opens a document with or without "using"
* 1.2   Jan2008 cd option
* 1.3   Aug2008 version 7.0
* 1.4 04Aug2008 version 7.0 fiddling (was 1.3 Aug2008); fiddling with non-.txt suffix being recognized

program define shellout
version 7.0

syntax [anything] [using/] [,cd]

* does the shelling
if "`c(os)'"=="Windows" | "$S_MACH"=="PC" {
        if "`using'"~="" {
                winexec cmd /c start ""  "`using'"
        }
        else {
                if "`cd'"~="cd" {
                        cap winexec `anything'
                        if _rc==193 {
                                winexec cmd /c start ""  "`anything'"
                        }
                        if _rc==601 {
                                noi di in yel "Cannot find `anything'. Make sure typed the name correctly."
                        }
                }
                else {
                        winexec cmd /c cd `c(pwd)'\ &  `anything'
                }
        }
}
else {
        * invisible to Stata 7
        local Version7 ""
        cap local Version7 `c(stata_version)'
        
        if "`Version7'"=="" {
                * stata 7
        }
        else {
                * non-PC systems
                di "{opt shellout} probably will not work with `c(os)'"
                shell `using'
        }
}
end


/* Old codes
* shellout
* version 1.0
* October 2005
* by roywada@hotmail.com
*
* (to accompany -outreg2-)
*


program define shelling
version 8.2
syntax using/
* does the shelling
*if c(machine_type)=="PC" {
if "`c(os)'"=="Windows" {
        winexec cmd /c start ""  "`using'"
}
else {
        di "{opt shellout} probably will not work with `c(os)'"
        shell `using'
}
end


