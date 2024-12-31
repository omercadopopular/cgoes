*! version 2.10.0 3apr2017
* wrapper for join.ado, parsing code based on merge.ado

program define fmerge 
    gettoken mtype 0 : 0, parse(" ,")

    _assert inlist("`mtype'", "1:1", "1:m", "m:1", "m:m"), msg("invalid merge type: `mtype'")
    _assert "`mtype'"!="m:m", msg("have you read the disclaimer about m:m merges? (this merge type is dangerous and not supported)")
    _assert "`mtype'"!="1:m", msg("1:m merges not supported, use join with the into() option")

    gettoken token : 0, parse(" ,")
    _assert ("`token'"!="_n"), msg("_n not supported as a merge key")

    syntax [varlist(default=none)] using/ [,        ///
              ASSERT(string)                        ///
              GENerate(passthru)                        ///
              FORCE                                 ///
              KEEP(string)                          ///
              KEEPUSing(string)                     ///
            noLabel                                 ///
              NOGENerate                            ///
            noNOTEs                                 ///
              REPLACE                               ///
              DEBUG                                 ///
            noREPort                                ///     
              SORTED                                ///
              UPDATE                                ///
              Verbose                               ///
            ]

    if ("`debug'" != "") di as error "warning: -debug- option does nothing"
    if ("`force'" != "") di as error "warning: -force- option does nothing"
    if ("`sorted'" != "") di as error "warning: -sorted- option does nothing"
    _assert ("`replace'" == ""), msg("-replace- option not allowed")
    _assert ("`update'" == ""), msg("-update- option not allowed")

    loc uniquemaster = cond("`mtype'" == "1:1", "uniquemaster", "")

    loc check = "`keepusing'"!=""
    loc keepusing : list keepusing - varlist
    if ("`keepusing'"=="" & `check') {
      loc keepnone keepnone // don't keep any variable from using
    }

    loc cmd join `keepusing', ///
    	from(`"`using'"') ///
    	by(`varlist') ///
    	keep(`keep') ///
    	assert(`assert') ///
      `keepnone' ///
    	`generate' ///
    	`nogenerate' ///
    	`uniquemaster' ///
    	`label' ///
    	`notes' ///
    	`report'

    if ("`verbose'" != "") di as text `"{bf:[cmd]} {res}`cmd'{txt}"'
    `cmd'
end
