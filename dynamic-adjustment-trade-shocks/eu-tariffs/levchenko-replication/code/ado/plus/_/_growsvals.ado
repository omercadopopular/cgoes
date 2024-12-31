* NJC 1.0.1 28 Jan 2009
* NJC 1.0.0 7 Jan 2009
program _growsvals 
	version 9
	gettoken type 0 : 0
	gettoken h    0 : 0 
	gettoken eqs  0 : 0

	syntax varlist(string) [if] [in] [, BY(string) MISSing]
	if `"`by'"' != "" {
		_egennoby rowsvals() `"`by'"'
		/* NOTREACHED */
	}

	marksample touse, novarlist 
	local miss = "`missing'" != "" 
	quietly { 
		mata : row_svals("`varlist'", "`touse'", "`h'", "`type'", `miss') 
	}
end

mata : 

void row_svals(string scalar varnames, 
		string scalar tousename,
		string scalar svalsname,
		string scalar type,
		real scalar miss)
{ 
	string matrix y 
	string colvector row
	real colvector nvals

        st_sview(y, ., tokens(varnames), tousename)    
	svals = J(rows(y), 1, .) 

	if (miss) { 
		for(i = 1; i <= rows(y); i++) { 
			row = y[i,]'        
			svals[i] = length(uniqrows(row))
        	}
	}
	else { 
		for(i = 1; i <= rows(y); i++) { 
			row = y[i,]'        
			svals[i] = length(uniqrows(select(row, (row :!= ""))))
        	}
	}

	st_addvar(type, svalsname)
	st_store(., svalsname, tousename, svals) 
}	

end

