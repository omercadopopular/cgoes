


*! mm_txttool (wrapper for text mining tools) 1.1 Unislawa Williams 24Dec2013
version 10
mata: 
function mm_txttool(string scalar txtdata, | string scalar noclean, string scalar stem, ///
	string scalar stopwordlist, string scalar subwordlist, string scalar genfield, ///
	string scalar prefix, string scalar nooutput, string scalar touse) {

	real scalar i
	string v, sentx, owordlist, vsform


/// create data from text field
	v = st_sdata(.,txtdata, touse)

/// original count of total words and unique words
	if (nooutput !="nooutput") {

		/// stack all the words in each case
		for (i=1;i<=rows(v);i++) {
			sentx=(tokens(v[i]))
			if (i==1) {
				owordlist = sentx'
			}
			else {
				owordlist = owordlist \ sentx'
			}
		}
		
		/// output the counts of the stacked words
		st_local("ototwords",strofreal(rows(owordlist)))
		st_local("ouwords",strofreal(rows(uniqrows(owordlist))))

	}
	
/// call clean, if requested
	if (noclean !="noclean") {
		v = cleantxt(v)
	}
/// call subwords, if requested
	if (subwordlist!="") {
		v = subwords(v,subwordlist)
	}
/// call stopwords, if requested
	if (stopwordlist!="") {
		v = stopwords(v,stopwordlist)
	}
/// call stemmer, if requested
	if (stem=="stem") {
		v = stemcolumn(v)
	}

/// generate new text field, if requested
	if (genfield !=txtdata) {

	/// create format for new txtfield with the length of the maximum line of text
		vsform = "str"+strofreal(colmax(strlen(v)))

	/// add variables with correct length and store the text field
		(void) st_addvar(vsform,genfield)
		st_sstore(.,genfield, touse, v)
	}


/// replace existing text field, if requested
	if (genfield ==txtdata) {

		st_sstore(.,genfield, touse, v)
	}


/// bag the words, if requested
	if (prefix != "") {
		wordbag(v,prefix,touse)
	}


/// final count of total words and unique words, if desired
	if (nooutput !="nooutput") {
		for (i=1;i<=rows(v);i++) {
			sentx=(tokens(v[i]))
			if (i==1) {
				owordlist = sentx'
			}
			else {
				owordlist = owordlist \ sentx'
			}
		}

		st_local("ftotwords",strofreal(rows(owordlist)))
		st_local("fuwords",strofreal(rows(uniqrows(owordlist))))

	}
}
end



*! cleantxt (removing special characters and white space) 1.0.1 Unisia Williams 08Sep2013
mata:
string cleantxt(string matrix txtfield ) {
	
real scalar i, q

/// start loop through rows of text

	for (i=1;i<=rows(txtfield);i++) {

/// make lower case and remove extra white space 

		txtfield[i] = strtrim(stritrim(strlower(txtfield[i])))

/// keep characters 32 (white space), 48-57 (numerals) and 97-122 (lower case letters)
/// chars 65-90 (capital letters) can be skipped after using strlower

		for (q=1;q<=31;q++) {
			txtfield[i] = subinstr(txtfield[i],char(q),"")
		}		
		for (q=33;q<=47;q++) {
			txtfield[i] = subinstr(txtfield[i],char(q),"")
		}
		for (q=58;q<=64;q++) {
			txtfield[i] = subinstr(txtfield[i],char(q),"")
		}
		for (q=91;q<=96;q++) {
			txtfield[i] = subinstr(txtfield[i],char(q),"")
		}
		for (q =123;q<=255;q++) {
			txtfield[i] = subinstr(txtfield[i],char(q),"")
		}
	}
	return(txtfield)	
}
end






*! subwords (substitution of words) 1.0.1 Unisia Williams 08Sep2013
mata:
string subwords(string vector txtfield, string scalar subwordfile) {
	
	real scalar i, j
	string subwordmat, subbedtxt

/// grab list of substitutions from file 
	subwordlist = cat(subwordfile)

/// parse the list of tab-delimited substitutions into Nx2 matrix called subwordmat

	t = tokeninit("", char(9), "", 0, 0)

	subwordmat= J(rows(subwordlist),2, "")

	for (i=1;i<=rows(subwordlist);i++) {
		tokenset(t,subwordlist[i])
		j=1
		while ((token = tokenget(t))!="") {
			if (token==char(9)) j++ 
			else subwordmat[i,j] = token
		}
	}

	subbedtxt = txtfield

/// loop through i rows of txtfield and substitute j subword 

	for (i=1;i<=rows(subbedtxt);i++) {
		for (j=1;j<=rows(subwordmat);j++) {
			subbedtxt[i] = strtrim(stritrim(subinword(subbedtxt[i],subwordmat[j,1],subwordmat[j,2])))
		}
	}	
	return(subbedtxt)
}
end






*! stopwords (removal of listed words) 1.0.1 Unisia Williams 08Sep2013
mata:
string stopwords(string vector txtfield, string scalar stopwordfile) {
	
	real scalar i, j
	string stopwordlist, stoppedtxt

/// grab list of stopwords from file 

	stopwordlist = cat(stopwordfile)

	stoppedtxt = txtfield

/// loop through i rows of txtfield and clean j stopword

	for (i=1;i<=rows(stoppedtxt);i++) {
		for (j=1;j<=rows(stopwordlist);j++) {
			stoppedtxt[i] = strtrim(stritrim(subinword(stoppedtxt[i],stopwordlist[j],"")))
		}
	}	

	return(stoppedtxt)
}
end





*! porterstem (implementing Porter's 1980 word stemming procedure) 1.8.1 Unisia Williams 08Sep2013
*! See Porter (1980) for explanation of steps
mata:
string scalar porterstem(string scalar word) {

	if (strlen(word)<3) {
		return(word)
	}
	else {


/// m meaures and conditions

		string scalar mgr0
		string scalar mgr1 
		string scalar hasvowel 
		string scalar cond_o 

		mgr0 = "^([^aeiou][^aeiouy]*)?([aeiouy][aeiou]*)([^aeiou][^aeiouy]*)"
		mgr1 = "^([^aeiou][^aeiouy]*)?([aeiouy][aeiou]*)([^aeiou][^aeiouy]*)([aeiouy][aeiou]*)([^aeiou][^aeiouy]*)"
		hasvowel = "([^aeiou][^aeiouy]*)?[aeiouy]"
		cond_o = "([^aeiou])([aeiouy])([^aeiouwxy])$"

/// replace y with Y to avoid any matching issues	
		if (substr(word,1,1)=="y") {
			 word = subinstr(word,"y","Y",1)
		}
		else { }

/// Porter's step 1a

		if (regexm(word, "sses$")) {
			word = regexr(word, "sses$", "ss")
		}
		else if (regexm(word, "ies$")) {
			word = regexr(word, "ies$", "i")
		}
		else if (regexm(word, "ss$")) {
		}
		else if (regexm(word, "s$") & !regexm(word,"ss$")) {
			word = strreverse(subinstr(strreverse(word),"s","",1))
/** this may be a bug - regexr won't replace a single character at the end of the string **/
		}
		else { }


/// Porter's step 1b 

		if (regexm(word, "eed$")) {
			if (regexm(regexr(word, "eed$", "ee"),mgr0)) {
				word = regexr(word, "eed$", "ee")
			}
			else { }
		}

		else if (regexm(word, "(ed|ing)$") & regexm(regexr(word,"(ed|ing)$", ""),hasvowel)) {
			word = regexr(word,"(ed|ing)$", "") 
		
			if (regexm(word, "(at|bl|iz)$")) {
				word = word + "e"
			}
			else if (regexm(word, "[^aeiouylsz]$") & (substr(word,-1,1)==substr(word,-2,1))) {
				word = substr(word,1,strlen(word)-1)  
			} 
			else if (regexm(word,mgr0) & !regexm(word,mgr1) & regexm(word,cond_o)) {
				word = word + "e"
			}
			else { }
		}
		else { }

/// Porter's step 1c 

		if (regexm(word, "y$")) {
			if (regexm(substr(word,1,strlen(word)-1),hasvowel)) {
				word = substr(word,1,strlen(word)-1) + "i"
			}
			else { }
		}
		else { }

/// Porter's step 2

		if (regexm(word,"(ational|tional|enci|anci|izer|bli|alli|entli|eli|ousli|ization|ation|ator|alism|iveness|fulness|ousness|aliti|iviti|biliti|logi)$")) {
	
			if (substr(word,strlen(word)-1,1) == "a") {
				step2list = "ational$","tional$"
				step2suf = "ate","tion"
			}
			else if (substr(word,strlen(word)-1,1) == "c") {
				step2list = "enci$","anci$"
				step2suf = "ence","ance"
			}
			else if (substr(word,strlen(word)-1,1) == "e") {
				step2list = "izer$"
				step2suf = "ize"
			}
			else if (substr(word,strlen(word)-1,1) == "l") {	
				step2list = "bli$","alli$","entli$","eli$","ousli$"
				step2suf = "ble","al","ent","e","ous"
			}
			else if (substr(word,strlen(word)-1,1) == "o") {
				step2list = "ization$","ation$","ator$"
				step2suf = "ize","ate","ate"
			}
			else if (substr(word,strlen(word)-1,1) == "s") {
				step2list = "alism$","iveness$","fulness$","ousness$"
				step2suf = "al","ive","ful","ous"
			}
			else if (substr(word,strlen(word)-1,1) == "t") {	
				step2list = "aliti$","iviti$","biliti$"
				step2suf = "al","ive","ble"
			}
			else {
				step2list = "logi$"
				step2suf = "log"
			}


			for (iter=1;iter<=cols(step2list);iter++) {
				if (regexm(word, step2list[iter])) {			
					if (regexm(regexr(word, step2list[iter], ""),mgr0)) {				
						word = regexr(word,step2list[iter],step2suf[iter])
					}
					else { }
					break
				}
				else { }
			}
		}
		else { }

/// Porter's step 3

		if (regexm(word,"(icate|ative|alize|iciti|ical|ful|ness)$")) {

			if (substr(word,strlen(word),1)=="e") {
				step3list = "icate$","ative$","alize$"
				step3suf = "ic","","al"
			}
			else {
				step3list = "iciti$","ical$","ful$","ness$"
				step3suf = "ic","ic","",""	
			}

			for (iter=1;iter<=cols(step3list);iter++) {
				if (regexm(word, step3list[iter])) {			
					if (regexm(regexr(word, step3list[iter], ""),mgr0)) {				
						word = regexr(word,step3list[iter],step3suf[iter])
					}
					else { }
					break
				}
				else { }
			}
		}
		else { }

/// Porter's step 4

		if (regexm(word,"(al|ance|ence|er|ic|able|ible|ant|ement|ment|ent|ion|ou|ism|ate|iti|ous|ive|ize)$")) {

			if (substr(word, -1,1)=="e") {
				step4list = "ance$","ence$","able$","ible$","ate$","ive$","ize$"
			}
			else if (substr(word, -1,1)=="t") {
				step4list = "ement$","ment$","ent$","ant$"
			}
			else {
				step4list = "al$","er$","ic$","ion$","ous$","ou$","ism$","iti$"
			}	


			for (iter=1;iter<=cols(step4list);iter++) {
				if (regexm(word, step4list[iter])) {
					if (step4list[iter] != "ion$") {			
						if (regexm(regexr(word, step4list[iter], ""),mgr1)) {				
							word = regexr(word,step4list[iter],"")
						}
						else { }
					}
					else {
						if (regexm(regexr(word, "ion$", ""),mgr1) & (regexm(regexr(word, "ion$", ""),"s$") | regexm(regexr(word, "ion$", ""),"t$"))) { 
							word = regexr(word, "ion$", "")
						}
						else { }
					}
					break
				}
				else { }
			}
		}
		else { }

/// Porter's step 5a 

		if (regexm(word, "e$") & regexm(strreverse(subinstr(strreverse(word),"e","",1)),mgr1)) {
			word = strreverse(subinstr(strreverse(word),"e","",1))
		}
		else if (regexm(word, "e$") & regexm(strreverse(subinstr(strreverse(word),"e","",1)),mgr0) & !regexm(strreverse(subinstr(strreverse(word),"e","",1)),mgr1) & !regexm(strreverse(subinstr(strreverse(word),"e","",1)),cond_o)) {
			word = strreverse(subinstr(strreverse(word),"e","",1))
		}
		else { }

/// Porter's step 5b

		if (regexm(word,mgr1) & regexm(word,"ll$")) {
			word = strreverse(subinstr(strreverse(word),"l","",1))
		}
		else { }


/// Replace Y with y	
		if (substr(word,1,1)=="Y") {
			 word = subinstr(word,"Y","y",1)
		}
		else { }

		return(word)
	}
}

end



*! stemcolumn (apply porterstem() to a column vector) 1.0.1 Unisia Williams 08Sep2013
mata:
string stemcolumn(string vector txtfield) {

	real i, j
	string stemtxtfield, temprow

/// loop through txt data
	stemtxtfield = J(rows(txtfield),1,"")
	for (i=1;i<=rows(txtfield);i++) {

		/// separate the tokens in each row and stem the tokens	
		temprow= tokens(txtfield[i])
		for (j=1;j<=cols(temprow);j++) {
			temprow[j] = porterstem(temprow[j])
		}
		
		/// recombine the stemmed tokens
		stemtxtfield[i] = invtokens(temprow)
	}
	return(stemtxtfield)
}
end



*! wordbag (represent text as bag-of-words) 1.0.1 Unisia Williams 08Sep2013
mata:
void wordbag(string txtfield , string prefix, string scalar touse) {
	
	string words, sent, words_vnames
	real scalar i, j, k, matched
	real matrix wordcounts


/// vector to store each unique word
	words = J(1,1, "")

/// matrix to store counts of each unique word
	wordcounts = J(rows(txtfield),1,0)

/// start loop through sentences and tokenize each sentence
	for (i=1;i<=rows(txtfield);i++) {
		sent = tokens(txtfield[i])
	
/// loop through tokens of sentences, set matched to 0 for each new token
		for (j=1;j<=cols(sent);j++) {
			matched = 0

/// loop through words vector, set matched to the count if the token matches an existing word
			for (k=1;k<=cols(words);k++) {
				if (sent[j]==words[k]) {
					matched = k
					break
				}
			}
/// if match found, increment count of word in wordcounts matrix at position given by matched
			if (matched>0) {
				wordcounts[i,matched] = wordcounts[i,matched] + 1
			}

/// if no match found, add word and set its count to 1 in wordcounts matrix
			else if (matched==0) {
				words = words,sent[j]
				wordcounts = wordcounts, J(rows(wordcounts),1,0)
				wordcounts[i,cols(wordcounts)] = 1
			}
		}
	}

/// trim off the empty first column of words and wordcounts 
	words = words[.,2::cols(words)]
	wordcounts = wordcounts[.,2::cols(wordcounts)]


/// add thew prefix to all the words, so that they are valid stata variables

	words_vnames = words
	for (i=1;i<=cols(words);i++) {
		words_vnames[i] = prefix + words[i]
	}

/// write vars (words) and data (wordcounts) to data

	(void) st_addvar("int",words_vnames)
	st_store(.,words_vnames, touse, wordcounts)

}
end

