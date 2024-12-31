
*! version 1.1 Unislawa Williams
program define txttool
version 10
	syntax varname [if] [in] [, STOPwords(string) SUBwords(string) STEM GENerate(string) BAGwords PREfix(string) REPLACE NOCLEAN NOOUTput]

	marksample touse, strok
	qui count if `touse'
	if r(N)==0 {
		di as err "No cases selected"
		exit 2000
	}

/// turn on timers
	timer clear
	timer on 1

/// verify that varname is string
	confirm string variable `varlist'

/// verify subword file
	if ("`subwords'" != "") {
		capture confirm file "`subwords'"
		if _rc {
			di as err "Subwords file `subwords' not found"
			exit 198
		}
	}

/// verify stopwords file
	if ("`stopwords'" != "") {
		capture confirm file "`stopwords'"
		if _rc {
			di as err "Stopwords file `stopwords' not found"
			exit 198
		}
	} 

/// check that noclean is not used with bagwords
	if ("`noclean'" == "noclean" & ("`bagwords'" !="" | "`prefix'" !="")) {
		di as err "NOCLEAN option not permitted with BAGWORDS or PREFIX option"
            exit 198
	}

/// confirm either generate or replace option is selected
	if ("`generate'" == "" & "`replace'" == "" ) {
		di as err "Either GENERATE or REPLACE option is required"
		exit 198
	}

/// confirm only one of generate or replace options is selected
	if ("`generate'" != "" & "`replace'" != "" ) {
		di as err "GENERATE and REPLACE options cannot be used together"
		exit 198
	}


/// confirm that if generate isn't empty that its a useable varname
	if ("`generate'" != "" ) {
		capture confirm new var `generate' 
		if _rc {
			di as err "Name `generate' for output text is not valid"
			exit 198
		}
	}


/// confirm that if prefix isn't empty that its a useable prefix
	if ("`prefix'" !="") {
		capture confirm new var `prefix' 
		if _rc {
			di as err "Prefix `prefix' for bagged words is not a valid variable name"
			exit 198
		}
	}


/// check that if bagwords is selected without a prefix and issue warning about conflicts
	if ("`bagwords'" != "" & "`prefix'" =="") {
		di in y "No prefix chosen for bagged words; default prefix w_ used"
		di in y "Note that errors will result if new prefix/word combinations match any existing variables"
	}

/// set prefix if bagwords selected
	if ("`bagwords'" != "" & "`prefix'" =="") {
		local prefix = "w_"
	}

/// set generate to varname if replace is selected
	if ("`replace'" != "" ) {
		local generate = "`varlist'" 
	}


/// call mata wrapper
	mata: mm_txttool("`varlist'", "`noclean'", "`stem'", "`stopwords'", "`subwords'", ///
	"`generate'", "`prefix'", "`noouput'", "`touse'" )

/// output
	timer off 1
	quietly timer list 1

	if ("`nooutput'" != "nooutput" ) {
		di as result "Input:   `ouwords' unique words, `ototwords' total words"
		di as result "Output:  `fuwords' unique words, `ftotwords' total words"
		di as result "Total time: " r(t1) " seconds"
	}

end


