*! NJC 1.2.0 17 Feb 2007
* NJC 1.1.0 16 Feb 2007
* NJC 1.0.0 15 Feb 2007
program _growmedian
	version 9
	gettoken type 0 : 0
	gettoken h    0 : 0 
	gettoken eqs  0 : 0

	syntax varlist(numeric) [if] [in] [, BY(string)]
	if `"`by'"' != "" {
		_egennoby rowmedian() `"`by'"'
		/* NOTREACHED */
	}

	marksample touse, novarlist 
	quietly { 
		mata : row_median("`varlist'", "`touse'", "`h'", "`type'") 
	}
end

mata : 

void row_median(string scalar varnames, 
		string scalar tousename,
		string scalar medianname,
		string scalar type)
{ 
	real matrix y 
	real colvector median, row
	real scalar n

        st_view(y, ., tokens(varnames), tousename)    
	median = J(rows(y), 1, .) 

	for(i = 1; i <= rows(y); i++) { 
		row = y[i,]'        
		if (n = colnonmissing(row)) { // sic 
			_sort(row, 1)
                        median[i] = 
				(row[ceil(n / 2)] + row[floor(n + 2) / 2]) / 2
                }
        }

	st_addvar(type, medianname)
	st_store(., medianname, tousename, median) 
}	

end

