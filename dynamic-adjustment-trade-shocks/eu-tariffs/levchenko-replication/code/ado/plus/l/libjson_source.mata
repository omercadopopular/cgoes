version 11
clear mata
mata:	
/* class: libjson
 * Purpose: To parse JSON strings into a object tree, and to facilitate common web API calls which give JSON responses 
 * Author: Erik Lindsley
 * Date: January 28th, 2012
 * Version: 1.0.3
 * Change Log:
 *        20140119: Fixed space insertion issue when source has no end-of-lines.
 * Known Limitations: STATA/Mata does not currently support encrypted transport (https://) URLs.
 *                    The parser should really be fully static, but STATA/Mata doesn't support accessing static class variables from inside static functions.
 */
 
class libjson {
    /* NOTE: JSON = Java Script Object Notation, libjson = STATA/MATA libjson class */
	private:
		real scalar  mytype /* node Run-Time Type Identification (RTTI) field */
		string scalar pname /* Holds the key(label) for Artibute nodes */
		pointer (class libjson scalar) colvector vals /* Arry for holding json objects, either for Array or Objects */
		string scalar pval /* Holds string values for Scalar objects */
		pointer (class libjson scalar) scalar pval_c /* Holds libjson objects for Attribute objects */

		void addEntry() /* Adds the given libjson object to the end of the array */
		
    static real rowvector s /* Parse buffer */
    static real scalar idx /* current character being processed by the parser*/
    static real scalar last_error /* Last parser error */
    
    static string scalar quote /* quote character to be use by the pretty printer*/
    static string scalar vstop /* Used buy the pretty printer to keep track of the current indention level */
				
	public:
		void new() /* Constructor */
	real scalar arrayLength()    /* returns the number of objects in an Array */
	pointer (class libjson scalar) scalar getArrayValue() /* returns Nth array element */
	real scalar isArray() /* true if this libjson object is holding an Array?  */
	real scalar isObject() /* true if this libjson object is holding an Object?  */
	real scalar isAttribute() /* true if this libjson object is holding an Attribute (name/value pair)?  */
	real scalar isString() /* true if this libjson object is holding a string literal, or an attribute what holds a literal)?  */
	real scalar isScalar() /* true if this libjson object is holding a scalar value (=string)?  */
	
	string scalar getAttributeScalar() /* returns the named attribute as a scalar (string) value */
	pointer (class libjson scalar) scalar getAttribute() /* returns a pointer to the named attribute contained in this Object */
	string scalar getAttributeName() /* returns the name of an Attribute */
	void addArrayValue() /* Adds the libjson object to the end of the array */
	void addArrayScalar() /* Adds the string to the end of the array as a Scalar object*/
	void addAttributeScalar() /* Adds the key/value(string) to the end of the array as a Scalar Attribute object*/
	void addAttribute() /* Adds the libjson object  to the end of the array as a Scalar Attribute object*/
	void makeScalar() /* Force the libjson object to hold the given string */
	
	string rowvector listAttributeNames() /* Returns a list of the attributes of the Object */
	string scalar bracketArrayScalarValues() /* Returns all scalar values in the array in the familiar bracket notation */
	string matrix flattenToKV() /* Return the entire libjson object as a list of flattened object names and values. Useful for processing small libjson responses from web servers. */
	static string scalar getFlattenedValue() /*Scans the given flatten() resutls for the given key, and returns the scalar (string) value. A helper function for scanning the result of flatten() for particular key-value pairs */

	static string scalar urlencode() /* Returns the given string with certain unsafe characters escaped as necessary for use in a URL */
	static string scalar getrawcontents() /* Makes an http request using the given URL and extra arguments, and returns the results as a single string */
	
	
	pointer (class libjson scalar) scalar parse() /* parses the given JSON-formatted string into a libjson object tree, and returns the root node */
	void prettyPrint() /* Print to the console the libjson object tree in a human-readible form that is JSON compliant */
	string scalar toString() /* Reconstitutes the given libjson tree into a JSON string. Note that this will not be a perfect reproduction of the original input becuase all numbers and 'null' values get converted to strings */

	/* Tree selector helper functions */
	pointer (class libjson scalar) scalar getNode() /* Returns the node branch address by given selector */ 
	string scalar getString() /* Returns the Scalar addressed by given selector */ 
	real scalar getReal() /* Returns the real number (converted from the Scalar addressed by given selector) */ 
	static string rowvector parseSelector() /* converts a selector string into the vector format by breaking up the string at the colons */
	/* used for calling JSON-based REST APIs */
	static pointer (class libjson scalar) scalar webcall() /* Calls the REST API using the given URL and Args, parses the JSON response, and returns the root node of the libjson object tree */
	static string matrix webcall_flatten() /* Call the API, and pass the results though flatten() */
	static real rowvector getVersion() /* Returns a vector with the library version number, in form of (major, minor, build) */
	static real scalar checkVersion() /* true if the library version is the same or bettr than the given version */
private:	
	string colvector pretty_print() /* private helper function for prettyPrint() */
	string matrix flatten() /* Return the entire libjson object as a list of flattened object names and values. Useful for processing small libjson responses from web servers. */
	/* JSON top-down, recursive parser methods */
	string scalar parseQuotedString() /* parse and return the quoted string */
	void skipws() /* skip white space characters */
	string scalar parseAtom() /* parse a string of numeric characters,  stoping at a whitespace or other reserved character */
	pointer (class libjson scalar) scalar parseObject() /* Parse a JSON Object, returning a libjson node */
	pointer (class libjson scalar) scalar parseArray() /* Parse a JSON Array, returning a libjson node */

}

	real rowvector libjson::getVersion() { 
		return (1,0,2); 
	}
	real scalar libjson::checkVersion(real rowvector c) { 
		v=getVersion(); 
		return( ((v[1]==c[1]) && (v[2]>=c[2])) || (v[1]>c[1]) ); 
	}
	
	string matrix libjson::flattenToKV() { return(flatten(""));}
	string rowvector libjson::parseSelector(string scalar sel) {
			tok = tokens(sel,":")
			NC = ceil(cols(tok)/2)
			res=J(1,NC,"");
			for (kk=1; kk<=NC; kk++) res[kk]=tok[kk*2-1];
			return(res);
	}
	
	string scalar libjson::bracketArrayScalarValues() {
		if (!isArray()) return("");
		string scalar res
		res=""
		for (k=rows(vals); k>=1; k--) {
				if (vals[k]->isString()) res =  vals[k]->pval+", "+ res;
		}
		return("["+ substr(res,1,strlen(res)-2) + "]");
	}

	string rowvector libjson::listAttributeNames(real scalar one_string_flag) {
		if (!isObject()) return((""));
		string scalar quote
		quote = char(34);
		if (one_string_flag) {
			string scalar res
			res=""
			for (k=rows(vals); k>=1; k--) {
					res =  quote+(vals[k]->getAttributeName())+quote +" "+ res;
			}
			return((res));
		} else {
			string rowvector res2
			res2 = J(1,rows(vals), "")
			for (k=rows(vals); k>=1; k--) {
				res2[k]=vals[k]->getAttributeName();
			}
			return(res2);
		}
	}
	
	pointer (class libjson scalar) scalar libjson::webcall(string scalar url_base, string matrix args) {
		class libjson scalar res
		c = getrawcontents(url_base,args);
		if (strlen(c)>0) return(res.parse(c));  
		return(NULL);
	}
	string matrix libjson::webcall_flatten(string scalar url_base, string matrix args) {
		pointer (class libjson scalar) scalar root
		root = webcall(url_base,args);
		if (root) return(root->flatten(""));
		else return(J(0,0,""));
	}


	pointer (class libjson scalar) scalar libjson::getNode(string rowvector selector) {
		pointer (class libjson scalar) scalar nod
		NC=cols(selector)
		nod=&this
		if ((selector==.) || (selector=="") ) return(nod)
		for (k=1; k<=NC; k++) {
			if (nod->mytype == 4) {
				array_idx = strtoreal(selector[k]);
				if ((array_idx<1) || (array_idx>rows(nod->vals)) ) return(NULL);
				nod=nod->vals[array_idx];
			} else if (	nod->mytype == 3) {
			    key=selector[k];
			    match=0;
				for (r=rows(nod->vals); r>=1; r--) {
				 	if ((nod->vals[r])->pname == key) {
				 			match=1;
				 			if ((nod->vals[r])->mytype==2) {
				 				nod=nod->vals[r];
				 			} else nod=(nod->vals[r])->pval_c;
				 			break;
					}	
				}
				if (match==0) return(NULL);
			} else {
				return(NULL);
			}
		}
		return(nod);
	}
	
	string scalar libjson::getString(string rowvector selector, string scalar missing_val) {
		pointer (class libjson scalar) scalar nod
		nod = getNode(selector);
		if (nod) { if (nod->isString()) return(nod->pval); }
		return(missing_val);
	}
	real scalar libjson::getReal(string rowvector selector, real scalar missing_val) {
		pointer (class libjson scalar) scalar nod
		nod = getNode(selector);
		if (nod) { 
				if (nod->isString()) {
						return (strtoreal(nod->pval)); 
				}
			}
		return(missing_val);
	}


	void libjson::addAttributeScalar(string scalar key, string scalar val) {
		class libjson scalar a
		a.pname=key
		a.mytype=2
		a.pval=val
		addEntry(&a);
		mytype=3;		
	}
	void libjson::addAttribute(string scalar key, pointer (class libjson scalar) val) {
		class libjson scalar a
		a.pname=key
		a.mytype=2.5
		a.pval_c=val
		addEntry(&a);
		mytype=3;		
	}
	pointer (class libjson scalar) scalar libjson::getAttribute(string scalar key) {
		if (mytype==1) return(pval_c)
		if (mytype==3) {
			for (k=rows(vals); k>=1; k--) {
				if (vals[k]->pname == key) {
					if (vals[k]->mytype==2.5) return(vals[k]->pval_c)
					else return(vals[k]);
				}
			}			
		}
		return(NULL)
	}
	string scalar libjson::getAttributeScalar(string scalar key, string scalar missing_value) {
		if (mytype==1) return(pval)
		if (mytype==3) {
			for (k=rows(vals); k>=1; k--) {
				if (vals[k]->pname == key && vals[k]->mytype==2) return(vals[k]->pval)
			}			
		}
		return(missing_value)
	}
	string scalar libjson::getAttributeName() {
		return(pname);
	}


	void libjson::new() {
		mytype = 0
	}
	real scalar libjson::isArray()  {return((&this) && mytype ==4); }
	real scalar libjson::isObject() {return((&this) && mytype ==3); }
	real scalar libjson::isAttribute() {return((&this) && ((mytype ==2)||(mytype ==2.5))); }
	real scalar libjson::isScalar() {return((&this) && mytype==1); }
	real scalar libjson::isString() {return((&this) && ((mytype==1)||(mytype==2)) ); }

	void libjson::makeScalar( string scalar val) {
		mytype=1;
		pval = val;
	} 
	void libjson::addEntry(pointer (class libjson scalar) scalar p) {
		if (mytype==0) vals = J(0,1,NULL)
		vals = vals \ p;
	}
	void libjson::addArrayScalar(string scalar s) {
			class libjson scalar temp
			temp.makeScalar(s)
			addEntry(&temp)
			mytype=4;
	}
	void libjson::addArrayValue(pointer (class libjson scalar) scalar p) {
			addEntry(p)
			mytype=4;
	}
	real scalar libjson::arrayLength() {
		if (mytype==4) return(rows(vals))
		else return(0);
	}
	pointer (class libjson scalar) scalar libjson::getArrayValue(real scalar index) {
		if ((mytype==4) && (index<= rows(vals)) && (index>=1) ) return(vals[index])
		else return(NULL)
	}
	string matrix libjson::flatten(string scalar prefix) {
		string matrix res
		res = J(0,2,"")
		if (mytype==1) {
			res = res \ (substr(prefix,2,.), pval)
		} else if (mytype==2) {
			if (prefix!="") res = res \ (substr(prefix,2,.) + ":"+ pname, pval)
			else res = res \ (pname, pval)
		} else if (mytype==2.5) {
			res = res \ (pval_c->flatten(prefix+":"+ pname) )
		} else if (mytype==3) {
			for (k=1; k<=rows(vals); k++) {
				res = res \	(vals[k]->flatten(prefix))	
			}
		} else if (mytype==4) {
			for (k=1; k<=rows(vals); k++) {
				res = res \	(vals[k]->flatten(prefix+":"+strofreal(k))	)
			}
		}
		return(res)
	}
	
	void libjson::prettyPrint() {
		quote=char(34)
		vstop = " "
		pp=pretty_print("");
		if (orgtype(pp)=="scalar") {
			printf("%s\n",pp);
		} else {
			for (k=1; k<rows(pp); k++) printf("%s\n",pp[k]);
		}
	}
	string scalar libjson::toString() {
		quote=char(34)
		vstop = " "
		pp=pretty_print(" ");
		if (orgtype(pp)=="scalar") {
			return(pp);
		} else {
			res = "";
			for (k=1; k<rows(pp); k++) res = res + " "+ strltrim(pp[k]);
			return(res);
		}
	}
	string colvector libjson::pretty_print(string scalar lmargin) {
		res = J(0,1,"")
		if (mytype==1) { return((lmargin+quote+pval+quote)); }
		else if (mytype==2) { return((lmargin+quote+pname+quote+" : "+quote+pval+quote)); }
		else if (mytype==2.5) { return ((lmargin+quote+pname+quote+" :") \  (pval_c->pretty_print(lmargin+ vstop)) ); }
		else if (mytype==3) { 
				NR=rows(vals);
				res = res \ (lmargin + "{");
				for(k=1; k<=NR; k++) {
						res = res \ (vals[k]->pretty_print(lmargin+ vstop));
						lastrow = rows(res);
						if (k<NR) { res[lastrow,1]= res[lastrow,1]+","; }
						}
				res = res \ (lmargin + "}");
		}
		else if (mytype==4) { 
				NR=rows(vals);
				res = res \ (lmargin + "[");
				for(k=1; k<=NR; k++) {
						res = res \ vals[k]->pretty_print(lmargin+ vstop);
						lastrow = rows(res);
						if (k<NR) { res[lastrow,1]= res[lastrow,1]+","; }
						}
				res = res \ (lmargin + "]");
		}
		return(res);
	}

	string scalar libjson::urlencode(string scalar s) { res = J(1,0,.); a=ascii(s); for(c=1;c<=cols(a); c++) { if ((a[c]>=44 && a[c]<=59) || (a[c]>=64 && a[c]<=122)) { res=(res,a[c]);} else { h1 = floor(a[c]/16); h2 = mod(a[c],16); if (h1<10) {h1=h1+48;} else {h1=h1+55;}  if (h2<10) {h2=h2+48;} else {h2=h2+55;} res=(res, 37, h1,h2);} } return(char(res));}         
	void libjson::skipws() {
		while(s[idx]<=32) idx++;
	}
	string scalar libjson::parseQuotedString() {
		if (s[idx]!=34) return(""); 
		idx++; 
		start_idx = idx;
		while( (s[idx]!=34) || (s[idx-1]==92) ) idx++; 
		idx++; 
		return (char(s[(start_idx)..(idx-2)])); 
	}
	string scalar libjson::parseAtom() {start_idx = idx; while(((s[idx]>=48) && (s[idx]<=57)) ||  (s[idx]==45) || (s[idx]==43)|| (s[idx]==46)|| (s[idx]==69)|| ((s[idx]>=97)&& (s[idx]<=122))) idx++; return (char(s[start_idx..(idx-1)])); }
	string scalar libjson::getrawcontents(string scalar url_base, string matrix args) {
		a = "";
		if ((args!=.) && ((rows(args)>0) && (cols(args)==2)) ) {
			a = urlencode(args[1,1])+"="+urlencode(args[1,2]);
			for (r=2; r<=rows(args); r++) {
				a= a+"&"+ urlencode(args[r,1])+"="+urlencode(args[r,2]);
			}
		url = url_base + "?"+ a;		
		}
		else url= url_base;
		res = ""; 
		fh = _fopen(url, "r"); 
		if (fh!=0) {
			printf ("{err: Fatal Error %f, unable to open URL: %s}\n",fh,ferrortext(fh));
			return (res);
		}
		while ((line=fread(fh,4000))!=J(0,0,"")) { res=res+line; } /* changed 20140119,20140929 */
		fclose(fh);
		return(res);
	}
	pointer (class libjson scalar) scalar libjson::parse(string scalar libjson_string) { 
		pointer (class libjson scalar) scalar res
		if (strlen(libjson_string)<3) return(NULL);
		s=ascii(libjson_string)
/*		printf("DEBUG: libjson::parse(%f,%f)\n",strlen(libjson_string), cols(s)); */
		idx=1
		last_error=0
		skipws();
		if (s[idx]==123) res=parseObject();
		else res=parseArray();
		if (res && (last_error==0)) return(res);
		printf("libjson::parse: unexpected character '%s' at position %f forced error #%f\n",char(s[idx]),idx, last_error);
		printf("%s\n", substr(char(s[(idx-30)..(cols(s))]),1,60));
		printf("                              ^  parse error here!\n");		
		char(s[(idx-100)..(idx+29)])
		
		return(NULL)
		}	 
	pointer (class libjson scalar) scalar libjson::parseObject() { 
		class libjson scalar res	
/*		printf("DEBUG: libjson:: BEGIN parseObject(%f,%f)\n",cols(s),idx); */
		skipws(); 
		if (s[idx]!=123) { last_error = -1; return(NULL); }
		idx++; 
		skipws(); 
		if (s[idx]==125) return(&res);
		while (1) {
			skipws(); 
			k=parseQuotedString(); 
			skipws();  
			if (k==. || s[idx]!=58) { last_error = -3; return(NULL); } 
			idx++; skipws();
			if (s[idx]==34) { v = parseQuotedString(); res.addAttributeScalar(k,v);}
			else if (s[idx]==123) {v= parseObject(); if (v) res.addAttribute(k,v); else return(NULL);  }
			else if (s[idx]==91) { v= parseArray();if (v) res.addAttribute(k,v); else return(NULL); }
			else if ( ((s[idx]>=48) && (s[idx]<=57)) || (s[idx]==45) ||((s[idx]>=97)&& (s[idx]<=122)) ) { v= parseAtom(); res.addAttributeScalar(k,v); }
			else { last_error = -4; return(NULL); } 
			skipws();
			if (s[idx]==125) break;
			if (s[idx]!=44) { last_error=-22; return(NULL); } 
			idx++;
		}
		if (idx<cols(s)) idx++;
/*		printf("DEBUG: libjson:: END parseObject(%f,%f)\n",cols(s),idx); */
		return(&res);
	}
	pointer (class libjson scalar) scalar libjson::parseArray() {
		class libjson scalar res
/*		printf("DEBUG: libjson:: BEGIN parseArray(%f,%f)\n",cols(s),idx); */
		if (s[idx]!=91) { last_error = -10; return(NULL); } 
		idx++;
		count=0;
		while (1) {
			count++; 
			skipws();
			if (s[idx]==34) { v = parseQuotedString(); res.addArrayScalar(v);}
			else if (s[idx]==123)  {v= parseObject(); if (v) res.addArrayValue(v); else return(NULL);}
			else if (s[idx]==91) { v= parseArray();if (v) res.addArrayValue(v); else return(NULL); }
			else if ( ((s[idx]>=48) && (s[idx]<=57)) || (s[idx]==45) ||((s[idx]>=97)&& (s[idx]<=122)) ) { v= parseAtom();  res.addArrayScalar(v);}
			else if (s[idx]==93) break;
			else { last_error = -11; return(NULL); } 	
			skipws();
			if (s[idx]==93) break;
			if (s[idx]!=44) { last_error = -12; return(NULL); }
			idx++;
		}
		if (idx<cols(s)) idx++;
/*		printf("DEBUG: libjson:: END parseArray(%f,%f)\n",cols(s),idx); */
		return(&res);
	}

	string scalar libjson::getFlattenedValue(string matrix flattened_results, string scalar key, string scalar value_if_missing) {
		for (r=rows(flattened_results); r>=1; r--) {
			if (flattened_results[r,1]==key) return (flattened_results[r,2]);
		}
		return (value_if_missing);
	}
mata mlib create libjson, replace
mata mlib add libjson *(), complete
end
