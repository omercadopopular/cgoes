capture program drop lsemantica_word_comp

program lsemantica_word_comp
syntax using/  
clear
mata: lsemantica_word_comp_mata( "`using'")
	
end




capture mata mata drop lsemantica_word_comp_mata()
mata:
void function lsemantica_word_comp_mata(string scalar file_name ) {

	fh = fopen(file_name , "r"  )
	doc_comp_mat = fgetmatrix(fh)
	word_list= fgetmatrix(fh)
	fclose(fh) 

	st_addobs(length(word_list))
	var = st_addvar("strL" , "words")
	st_sstore(., "words" , word_list)

	for (r=1; r<=rows(doc_comp_mat); r++){
		var = st_addvar("double", "component_" + strofreal(r))  
		st_store(., "component_" + strofreal(r) ,doc_comp_mat[r,.]')
		}

}
end
