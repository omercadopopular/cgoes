* NJC 1.0.1 28 Jan 2009
* NJC 1.0.0 7 Jan 2009
program _grownvals 
	version 9
	gettoken type 0 : 0
	gettoken h    0 : 0 
	gettoken eqs  0 : 0

	syntax varlist(numeric) [if] [in] [, BY(string) MISSing]
	if `"`by'"' != "" {
		_egennoby rownvals() `"`by'"'
		/* NOTREACHED */
	}

	marksample touse, novarlist 
	local miss = "`missing'" != "" 
	quietly { 
		mata : row_nvals("`varlist'", "`touse'", "`h'", "`type'", `miss') 
	}
end

mata : 

void row_nvals(string scalar varnames, 
		string scalar tousename,
		string scalar nvalsname,
		string scalar type, 
		real scalar miss)
{ 
	real matrix y 
	real colvector nvals, row

        st_view(y, ., tokens(varnames), tousename)    
	nvals = J(rows(y), 1, .) 

	if (miss) { 
		for(i = 1; i <= rows(y); i++) { 
			row = y[i,]'        
			nvals[i] = length(uniqrows(row))
	        }
	}
	else { 
		for(i = 1; i <= rows(y); i++) { 
			row = y[i,]'        
			nvals[i] = length(uniqrows(select(row, (row :< .))))
		}
        }

	st_addvar(type, nvalsname)
	st_store(., nvalsname, tousename, nvals) 
}	

end

