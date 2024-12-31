
*******************************************
*** Function Cosine Similarity
*******************************************

capture program drop lsemantica_cosine

program lsemantica_cosine
	syntax varlist [,  mean_cosine min_cosine max_cosine find_similar(integer 0) find_similar_cosine(integer 0)]


	
	if `"`mean_cosine'"' == `""' { 
		local mean_cos = 0
	}
	else {
		local mean_cos = 1
	}	
	
	if `"`min_cosine'"' == `""' { 
		local min_cos = 0
	}
	else {
		local min_cos = 1
	}
	
	if `"`max_cosine'"' == `""' { 
		local max_cos = 0
	}
	else {
		local max_cos = 1
	}
	
		
	mata:cosine_sim = lsemantica_cosine_mata( "`varlist'" , `mean_cos' ,  `min_cos', `max_cos' , `find_similar' , `find_similar_cosine')
	
	
	
end


	

capture mata mata drop lsemantica_cosine_mata()
mata:
function lsemantica_cosine_mata(string scalar varlist, real scalar mean_cosine,  real scalar min_cosine , real scalar max_cosine, real scalar find_similar , real scalar find_similar_cosine) {


	variables = tokens(varlist)

	/*Load Components from Stata*/
	data = st_data(. , variables)

	/*Calculate Cosine Similarity*/
	cosine_sim = data*data'
	cosine_sim = (cosine_sim) :/ (diagonal(sqrt(cosine_sim) ) * diagonal(sqrt(cosine_sim))')

	if (mean_cosine==1){
		mean_similarity = mean(cosine_sim')'
		var = st_addvar("double", "mean_similarity")
		st_store(. , "mean_similarity" ,mean_similarity)
	}
	if (max_cosine==1){
		/*Set Diagonal to 0 to prevent max_similarity to be 1 for all documents */
		x = cosine_sim
		_diag(x, 0 )
		max_similarity = rowmax(x)
		var = st_addvar("double", "max_similarity")  
		st_store(. , "max_similarity" ,max_similarity)
	}
	if (min_cosine==1){
		min_similarity = rowmin(cosine_sim)
		var = st_addvar("double", "min_similarity")  
		st_store(. , "min_similarity" ,min_similarity)	
	}



	if (find_similar!=0){
		index_mat = J(0,find_similar,.)
		
		for (row=1 ; row<=cols(cosine_sim) ; row++){
			index = order(cosine_sim[row,.]',-1)'
			index_mat = index_mat \ index[2..find_similar+1]
		}

		for (t=1; t<=cols(index_mat); t++){
			var = st_addvar("double", "most_similar_" + strofreal(t))  
			st_store(., "most_similar_" + strofreal(t) ,index_mat[.,t])
		}	
	}		


	if (find_similar_cosine!=0){
		cos_mat = J(0,find_similar_cosine,.)
		
		for (row=1 ; row<=cols(cosine_sim) ; row++){
			row_sort = sort(cosine_sim[row,.]',-1)'
			cos_mat = cos_mat \ row_sort[2..find_similar_cosine+1]
		}

		for (t=1; t<=cols(index_mat); t++){
			var = st_addvar("double", "cosine_most_similar_" + strofreal(t))  
			st_store(., "cosine_most_similar_" + strofreal(t) ,cos_mat[.,t])
		}	
		
	}

	return(cosine_sim)
}

	end

