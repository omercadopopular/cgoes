
capture program drop lsemantica

program lsemantica
	syntax varlist(max=1) [, COMPonents(integer 300) TFidf  MIn_char(integer 0)  min_freq(integer 0)   max_freq(real 1) NAme_new_var(string) STOPwords(string) MAt_save  PAth(string)]



	display "*************************************"
	display "***** Latent Semantic Analysis ******"
	display "*************************************"
	display "Number of Components: " `components',
	display "Minimal Word Length: "`min_char'
	display "Minimal Word Frequency: "`min_freq'
	display "Maximal Word Frequency: "`max_freq'
	display "*************************************"
	display "                                     "
	
	
	if `"`tfidf'"' == `""' { 
		local tf_idf = 0
	}
	else {
		local tf_idf = 1
	}	
	
	if `"`mat_save'"' == `""' { 
		local mat_s = 0
	}
	else {
		local mat_s = 1
	}	
	
	mata:lsemantica_mata( "`varlist'",  `components', `tf_idf',  `min_char', `min_freq', `max_freq', "`name_new_var'",  "`stopwords'", `mat_s', "`path'")	
	
end


capture mata mata drop lsemantica_mata()
mata:
function lsemantica_mata(string scalar varlist, real scalar C,  real scalar tf_idf , real scalar min_char, real scalar min_freq, real scalar max_freq, string scalar name_new_var , string scalar stopwords, real scalar mat_save,  string scalar path ) {
	/* 1) Import Text Strings from Stata and first tokenize them into matrix */
	/*    Afterwards the code loops over all documents and tokens in the matrix and creates a word list.*/
	/*    This word list contains first a number and the word associate with that number. */
	/*   Using this word list a vector containing the number for the word tokens and */
	/*   a vector containing the document assignments for the word tokens is created.	*/
	
		
	"*************************************"
	"******** Preparing Documents ********"
	"*************************************"  
	"                                     "


	data = st_sdata(. , varlist)

	words = J(length(data), 0 ,"")
	docs = J(length(data),0,.)

	for (v=1 ; v<=rows(data) ; v++){
		tok = tokens(data[v])
		if (length(tok) > cols(words)){
			words  = words, J(rows(words), length(tok) - cols(words), "")
			docs = docs, J(rows(words), length(tok) - cols(docs), .)
		}
		
		if (length(tok)!=0){
			words[v,1..length(tok)] = tok
			docs[v,1..length(tok)] = J(1,length(tok), v)
		}	
		
	}

	
	num_docs = rows(data)
	
	/*"*** Generating Vocabulary ***"*/
	docs = colshape(docs ,1)
	words = colshape(words ,1)
	
	docs = select(docs, (words:!=""))	
	words = select(words, (words:!=""))	
	
	voc = uniqrows( words )
	
	if (stopwords!="") {
		stopwords = tokens(strlower(stopwords))
		for (w=1 ; w<=length(stopwords) ; w++){
			voc = select(voc, (voc:!=stopwords[w]))
		}
	}

	voc = select(voc, (strlen(voc):>=min_char))
	size_voc = rows(voc)
	ints_size_voc = round((0.1*size_voc , 0.2*size_voc, 0.3*size_voc, 0.4*size_voc, 0.5*size_voc, 0.6*size_voc, 0.7*size_voc, 0.8*size_voc, 0.9*size_voc, size_voc))
	"*** Creating Document-Word-Matrix ***"

	doc_word_mat = J(num_docs,size_voc,0) /* create DxV document word matrix*/
	
	p = 1
	for (v=1 ; v<=size_voc ; v++){
		if ( mod( v, ints_size_voc[p])==0)  {
			"Processing Vocabulary:" 
			strofreal(p*10) + "% done"  	
			p = p +1
		}

		doc_tokens = select(docs,  words:==voc[v] )
		doc_count = rows(uniqrows( doc_tokens ))
		
		if (doc_count>=min_freq){
		
			if (doc_count/num_docs<=max_freq){
			
				for (d=1 ; d<=rows(doc_tokens); d++){
					doc_word_mat[doc_tokens[d] , v ] =  doc_word_mat[doc_tokens[d] , v ] + 1
				
				}
			}	
		}
	}
	
	
	/********* Filter Words ********/	

	/* drop voc that was not included*/
	voc = select(voc', (colsum(doc_word_mat):!=0))'
	doc_word_mat = select(doc_word_mat, (colsum(doc_word_mat):!=0))
	
	/* drop observation from Stata Data */
	st_dropobsif(rowsum(doc_word_mat):==0)	
	drop_obs = selectindex((rowsum(doc_word_mat):==0)) 
	
	/* drop observation from doc_word_mat */
	doc_word_mat = select(doc_word_mat, (rowsum(doc_word_mat):!=0))
	
	

	/* display observation that where dropped */
	"The following observation where removed from the data, since they did not have any remaining words:"
	drop_obs

	"                                     "
	"Size of Vocabulary:" 
	cols(doc_word_mat)
	"                                     "

	

	"                                     "
	"Now moving to SVD: this may take a while!"
	"                                     "
	

	if (tf_idf == 1) {
		/* calculate tf-idf */
		doc_word_mat = J(rows(doc_word_mat), cols(doc_word_mat) , 1) + log(doc_word_mat)
		doc_word_mat = editmissing(doc_word_mat,0) 
		for (i=1 ; i<=cols(doc_word_mat) ; i++){
			doc_freq = length( selectindex(doc_word_mat[.,i]) )/* get document frequency for word i */
			/* replace word frequency by tf-idf */
			doc_word_mat[.,i] = doc_word_mat[.,i] :* J( rows(doc_word_mat),1, (1 + log((rows(doc_word_mat) +1 )/(doc_freq + 1))))
		}
		/* normalize by L2 norm */
		row_sum = sqrt (rowsum( doc_word_mat :* doc_word_mat))
		doc_word_mat = doc_word_mat :/ row_sum	
	}
	
	
	
	"*************************************"
	"******* Running Truncated SVD *******"
	"*************************************"

	U = 0
	s=0
 	V=0
	
	if ( rows(doc_word_mat) > cols(doc_word_mat) ) 	svd(doc_word_mat, U, s, V)


	if ( rows(doc_word_mat) <= cols(doc_word_mat) ) fullsvd(doc_word_mat, U, s, V)


	
	S = fullsdiag(s, rows(x)-cols(x))
	/*y = U *S * V */

	/* truncate matrix */
	S_t = S[(1::C),(1::C)]
	V_t = V[(1::C) ,.]


	U_t = U[., (1::C)]
	U_t = U_t*S_t
	/*x_t = U_t * S_t * V_t*/
	
	if (name_new_var=="") name_new_var="component_"	  
	/*Store the Components in Stata*/
	for (t=1; t<=C; t++){
		var = st_addvar("double", name_new_var + strofreal(t))  
		st_store(., name_new_var + strofreal(t) ,U_t[.,t])
	}	
	
	/* take care of possible slash at the end of path */
	if (substr(path,-1)!="/" & substr(path,-1)!="\") path = path + "/"
	if (path=="/") path = ""
	/* stores word matrix */
	if (mat_save == 1) {
		file_out = fopen(path + "word_comp.mata", "rw")
		fputmatrix( file_out, V_t)
		fputmatrix( file_out, voc)
		fclose(file_out)
	}
	
	
}	


end


