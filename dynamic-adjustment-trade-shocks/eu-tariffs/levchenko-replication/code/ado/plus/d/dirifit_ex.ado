program define dirifit_ex
	Msg preserve
	preserve
	Xeq use http://fmwww.bc.edu/repec/bocode/c/citybudget.dta, clear
	Xeq dirifit governing safety education recreation social urbanplanning, ///
    mu(minorityleft noleft houseval popdens)
	Xeq ddirifit, at(minorityleft 0 noleft 0 )
	Msg restore 
	restore
end

program Msg
        di as txt
        di as txt "-> " as res `"`0'"'
end

program Xeq, rclass
        di as txt
        di as txt `"-> "' as res `"`0'"'
        `0'
end
