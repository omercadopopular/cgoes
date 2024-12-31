*! Write a matrix of statistics to a formatted table
*! version 1.32  18sep2015 by John Luke Gallup jlgallup@pdx.edu

* version 1.32: - rewrite selectindex() command to work in Stata 10
* version 1.31: - rewrote Merge algorithm (for fewer stats in initial table)
* version 1.30: - put "\" before "#" in -tex- documents
* version 1.29: - fixed bug when new -rtitle- in -replay-
* version 1.28: - fixed bug when new -rtitle- in -replay-
* version 1.27: - cleaned up text in -brackets-
* version 1.26: - allow -brackets- when -nosubstat-
* version 1.25: - fixed -addrows- when no -statmat-
*						bugfix in outreg.ado version 4.25
* version 1.24: - noBLankrows in frmttable vs. BLankrows in outreg
* version 1.23: - changed version to keep in sync w/-outreg- 4.23
* version 1.22: - fixed bug w/endspaces in BegDoc() 
* version 1.21: - changed version to keep in sync w/-outreg- 4.21
* version 1.20: - changed version to keep in sync w/-outreg- 4.20
* version 1.19: - fixed bug w/ -plain- in MakesSpaces()
* version 1.18: - changed version to keep in sync w/-outreg- 4.18
* version 1.17: - changed version to keep in sync w/-outreg- 4.17
* version 1.16: - revised help file
* version 1.15: - changed version to keep in sync w/-outreg- 4.15
* version 1.14: - changed version to keep in sync w/-outreg- 4.14
* version 1.13: - recompiled l_cfrmt.mlib in Stata 10 for compatibility
* version 1.12: - make table w/o -statmat- or -replay- (e.g. using -addrows-)
* version 1.11: - allow -merge- and -append- with -replay-
* version 1.10: - fixed bug when -ctitles- or -rtitles- too big in -replay-
* version 1.09: - fixed bug where I forgot I had commented out BegTex() 
* version 1.08: - fixed bug in AddTitle to reset rows for ctitles or rtitles 
* version 1.07: - added help documentation for -landscape- and -a4- options  
* version 1.06: - fixed bug in MakeRCodes() 
*							(maxdecpos was undefined if no decimal justification)
* version 1.05: - fixed bug in BegTex() 
* version 1.04: - added -landscape- and -a4- options 
* version 1.03: - fixed bug to allow overwriting of file w/merge option 
* version 1.02: - fixed bug in Merge() when more than 1 column of new statistics
*					 - removed typo in syntax statement for -vlstyle- & -spacebef-
*							options (in v1.01 only)

program define frmttable
   version 10.1
   syntax [using/], [Statmat(string)  		/// matrix of data for table
   					  SUBstat(int 0)      	/// # cols statmat that are substats 
   					  Doubles(string) 		/// cols of statmat that're dbl stats
   					  DBLdiv(string) 			/// symbol dividing double stats ("-")
   					  SDec(string) 			/// decimal places of stats
   					  SFmt(string asis) 		/// numerical format of stats
   					  SQuarebrack				/// square brackets, not parentheses
   					  BRackets(string asis)	/// symbols to bracket substats
   					  noBRKet					/// put no brackets on substats
   					  ANnotate(string) 		/// matrix of annotation locations
   					  ASymbol(string asis)	/// symbols for annotations
   					  CTitles(string asis)	/// headings at top of columns
   					  noCOltitl					/// no ctitles
   					  RTitles(string asis)	/// headings on left of each row
   					  noROwtitl					/// no rtitles
   					  noBLankrows				/// remove blank rows of T.Body
   					  FIndcons					/// put _cons in separate sect. of tbl
   					  VArlabels					/// use variable labels as rtitles
   					  Title(string asis)		/// put title above table
   					  Note(string asis)		/// put note below table
   					  PRetext(string asis) 	/// text placed before the table
   					  POsttext(string asis)	/// text placed after the table
   					  ADdrows(string asis)	/// add rows of data on bottom of tbl
   					  ADDRTc(int 0)			/// no. of rtitle columns in addrows
   					  ADDCols(string asis)	/// add cols of data to right of tbl
   					  Plain 						/// plain text: 1 font size, no just.
   					  noCEnter 					/// don't center table within page
   					  COLJust(string) 		/// column justification: left, center, or right
   					  HLines(string) 			/// horizontal lines between rows
   					  VLines(string)			/// verticle lines between columns
   					  BAsefont(string asis) /// change the base font for all text
   					  TITLFont(string asis) /// change font for table title
   					  CTITLFont(string asis) /// change font for column titles
   					  RTITLFont(string asis) /// change font for row titles
   					  STATFont(string asis) /// change font for stats in table
   					  NOTEFont(string asis)	/// change font for notes below table
   					  ADDTable					/// place table below existing table
   					  MUlticol(string)		/// ctitles span multiple columns
   					  ADDFont(string) 		/// add a new font type (word only)
   					  HLStyle(string)			/// change style of horizontal lines
   					  VLStyle(string)			/// change style of verticle lines
   					  SPACEBef(string) 		/// put space above cell*
   					  SPACEAft(string) 		/// put space below cell*
   					  SPACEHt(real 1)			/// change space height
   					  COLWidth(numlist)		/// change column widths (word only)
   					  LAndscape					/// landscape page orientation
   					  A4							/// A4 paper size
   					  TEX							/// write TeX format file
   					  FRagment					/// create TeX fragment (tex only)
   					  Eq_merge					/// merge rows w/same rtitles (eqns)
   					  Merge						/// merge to previous frmttable
   					  Merge1(string)			/// merge to frmttable `tblname'
   					  APpend						/// append below previous frmttable
   					  APpend1(string)			/// append below frmttable `tblname'
   					  STOre(string)			/// store in Mata struct "tblname"
   					  REplay						/// replay previous _FrmtT table
   					  REplay1(string)			/// replay _FrmtT"tblname" table
   					  CLear						/// clears _FrmtT - for loops w/merge					
   					  CLear1(string asis)	/// clears tblname - for loops w/merge					
   					  replace					/// replace previous file
   					  noDisplay					/// no display tbl in results window
   					  DWide]						//  display all cols however wide
* (word only)
// add suboption to sdec & sfmt to block copy
// add value labels for factor variables as equation names
// make -coljust- customizable by cell
// -rowjust- option for top, middle, bottom of cell
// cellborder option
// colors for .docx
// -addrow- and -addcol- in specified rows
// suboption on text inputs (e.g. titles)
// add text on left or right of whole table (alternative to -asymbol-
//		(specify cell addresses?)
// -multirow-
// make slanted column/row titles?
// repeated title("a title", add) options?
// write to .docx files
// write to .csv & .txt files
// write to .xlsx files
// move pretext and posttext options to separate program
// add user menus
// get rid of selectindex10 for tmformat

	if ("`clear'`clear1'"!="") {
		if (`"`clear1'"'!="") local clear1 `"clear(`clear1')"'
		Clear `0'    // clear _FrmtT
	}
	else {
		if (`"`merge'`merge1'`append'`append1'"') != "" {
			if ("`merge1'"!="") local merge = "merge"
			if ("`append1'"!="") local append = "append"
			if (("`merge'"!="") & ("`append'"!="")) { 
				di as err "can specify either merge or append options, not both"
				exit 198
			}
			if (`"`merge'`append'"'!="") local replace = "replace"
		}

		local wordoptv = `"`addfont'`colwidth'`hlstyle'`vlstyle'"'
		if ("`tex'"!="" & `"`wordoptv'"'!="") { 	//
			if (`"`addfont'`colwidth'"'!="") 		///
				local wordopts = "addfont and/or colwidth"
			if (`"`hlstyle'`vlstyle'"'!="") 			///
				local wordopts = "`wordopts' hlstyle and/or vlstyle"
			di as err `"option `wordopts' not allowed with tex option"'  //
			exit 198
		}
		if ("`tex'"=="" & "`fragment'"!="") { 		//
			di as err `"option fragment not allowed without tex option"' //
			exit 198
		}
	
		// check table names for illegal characters
		local mrgappname = `"`merge1'`append1'"'
		foreach tbl in `store' `merge1' `append1' `replay1' {
			if (indexnot(`"`tbl'"',	///
				"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_")| ///
				length(`"`tbl'"')>24) {
				di as err `"tblname `tbl' in option merge, replay, store, or append may only contain up to 24 letters, numbers, or "_""'
				exit 198
			}
		}

		mata: _pFrmtTold = findexternal("_FrmtT`mrgappname'") // before FrmtFill 
			// or AdjTitl creates pointer

		if ("`statmat'"!="") {	
			if ("`store'"!="") local tblname "_FrmtT`store'"
			else local tblname "_FrmtT`mrgappname'"
			mata: `tblname' = FrmtFill("`statmat'",`substat',"`doubles'", 		///
				"`dbldiv'",`"`sdec'"',`"`sfmt'"',("`squarebrack'"!=""),			///
				`"`brackets'"',("`brket'"!=""),`"`annotate'"',`"`asymbol'"',	///
				`"`ctitles'"',("`coltitl'"!=""),`"`rtitles'"',("`rowtitl'"!=""), ///
				("`findcons'"!=""),("`varlabels'"!=""),`"`title'"',`"`note'"',	///
				`"`pretext'"',`"`posttext'"',`"`addrows'"',`addrtc', 				///
				`"`addcols'"',("`eq_merge'"!=""),_pFrmtTold,("`merge'"!=""),	///
				("`append'"!=""),("`tex'"!=""))
		}
		else {  // i.e. replay or non-statmat content
			mata: _pFrmtT = findexternal("_FrmtT`replay1'")
			if ("`store'"!="") local tblname "_FrmtT`store'"
			else local tblname "_FrmtT`replay1'"
			mata: `tblname' = Replay(_pFrmtT,("`replay'"!=""),"`replay1'", 	///
				`"`title'"',`"`note'"',`"`ctitles'"',("`coltitl'"!=""),	  		///
				`"`rtitles'"',("`rowtitl'"!=""),`"`annotate'"',`"`asymbol'"',  ///
				`"`pretext'"',`"`posttext'"',`"`addrows'"',`addrtc', 				///
				`"`addcols'"',_pFrmtTold,("`merge'"!=""),("`append'"!=""),		///
				"`mrgappname'")
			mata: mata drop _pFrmtT
		}		
		mata: mata drop _pFrmtTold

		if (`"`using'"'!="") mata: FrmtOut(`tblname',("`tex'"!=""),				///
			`"`using'"',("`replace'"!=""),("`plain'"!=""),("`center'"==""),	///
			`"`coljust'"',"`colwidth'",`"`multicol'"',("`blankrows'"!=""),		///
			`"`hlines'"',`"`vlines'"',`"`hlstyle'"',`"`vlstyle'"',				///
			`"`spacebef'"',`"`spaceaft'"',`spaceht',`"`addfont'"',				///
			`"`basefont'"',`"`titlfont'"',`"`ctitlfont'"',`"`rtitlfont'"',		///
			`"`statfont'"',`"`notefont'"',("`landscape'"!=""),("`a4'"!=""),	///
			("`addtable'"!=""),("`fragment'"!=""))
		// display table in Stata results window
		if ("`display'"=="") mata: FrmtDisplay(`tblname',("`dwide'"!=""),		///
			("`blankrows'"!=""))
	}
end  // end of frmttable

program define Clear
   version 10.1
	// clear _FrmtT (for use with merge in loops)
	syntax , [CLear CLear1(string)]
	local tblname = "_FrmtT`clear1'"	
	mata: _pFrmtT = findexternal("`tblname'")
	mata: st_local("nonull", strofreal(_pFrmtT!=NULL))
	if `nonull' mata: mata drop `tblname'
end  // end of Clear

version 10.1
mata:

struct FrmtTabl {  					// structure holding table data
	string colvector Pretext
	string colvector Title
	string matrix Body
	real rowvector SectRows 		// # of rows in each (row) section of Body
	real rowvector SectSubstats 	// # of substats in (row) Sections
	real scalar ConsSect				// has a (row) section for "_cons" from regressions
	real rowvector SectCols			// # of columns in each (col) section of Body
	string colvector Note
	string colvector Posttext
}

/*
struct FrmtBegEnd {	// structure holding formatting codes (TeX, doc, etc)
	string colvector Title
	string matrix Body
	real rowvector SectRows 		// last row of sections in Body
	real rowvector SectCols			// last column of sections in Body
	string colvector Note
	string colvector Top				// codes before table text
	string colvector Tabular		// codes for tabular structure
	string colvector EndTabular	// codes at end of tabular structure
	string colvector Bottom			// codes after table text
}
*/

struct FrmtTabl scalar FrmtFill(string  scalar statmat,
				  							real   scalar substat,
				  							string scalar doubles,
				  							string scalar dbldiv,
				  							string scalar sdec,
				  							string scalar sfmt,
				  							real 	 scalar squarebrack,
				  							string scalar brackets,
				  							real	 scalar nobrcket,
				  							string scalar annotate,
				  							string scalar asymbol,
				  							string scalar ctitles,
				  							real   scalar noctitl,
				  							string scalar rtitles,
				  							real   scalar nortitl,
				  							real 	 scalar findcons,
				  							real   scalar vlabels,
				  							string scalar title,
				  							string scalar note,
				  							string scalar pretext,
				  							string scalar posttext,
				  							string scalar addrows,
				  							real	 scalar addrtc,
				  							string scalar addcols,
				  							real 	 scalar eq_merge,
				  							pointer(struct FrmtTabl scalar) scalar pTold,
				  							real 	 scalar merge,
				  							real 	 scalar append,
				  							real 	 scalar tex)
{  // fill in FrmtTabl structure with data and text (returned as _FrmtT)
	struct FrmtTabl scalar T
	smat = st_matrix(statmat)
	if (allof(smat,.)) {
		errprintf(`"matrix "%s" contains only missing values\n"',statmat)
		exit(198)
	}
	sr = rows(smat); scd = cols(smat) // including double columns
	ns = substat+1
	if (doubles!="") {
		dblmat = st_matrix(doubles); notdbl = !dblmat
		dbls = sum(dblmat)
		if (cols(dblmat)==0) {
			errprintf(`"matrix "%s" not found in doubles option\n"',doubles)
			exit(198)
		}
		if (cols(dblmat)!=scd) {
			errprintf(`"number of columns in "%s" not equal to columns in "%s"\n"',	///
				doubles,statmat)
			exit(198)
		}
	}
	else dbls = 0
	sc = scd-dbls		// without double columns
	tc = sc/ns  		// number of data columns in formatted table

	if (mod(sc,ns)>0) { // check that substat consistent with cols of statmat
		errprintf("number of statmat columns (ignoring doubles) not divisible")
		errprintf(" by 1+substat\n")
		exit(198)
	}
	// apply sdec and sfmt and convert smat to string matrix smatstr
	smatstr = strofreal(smat, FmtStr(sdec, sfmt, sr, sc, ns, dblmat))

	// combine doubles columns, so smatstr becomes sr x sc
	if (dbls) smatstr = JoinDbl(smatstr, dblmat, dbldiv, sr, scd)
	
	// add brackets
	empty = J(sr,sc,".") // get rid of missing: "."
	if (!nobrcket & (ns>1 | brackets!="")) {
		MakeBrac(squarebrack,brackets, sr, sc, ns, tex, lbracket="", rbracket="")
		smatstr = lbracket+smatstr+rbracket
		empty = lbracket+empty+rbracket  
	}
	smatstr = subinword(smatstr,empty,J(sr,sc,""))

	// add annotation symbols (e.g. asterisks for confidence levels)
	if (annotate!="") 	///
		smatstr = smatstr + MakeSymb(annotate, asymbol, sr, sc)
	// rearrange multiequation results into multiple columns
	L=""; H="" // L & H may be filled by Eq_Merge
	if (eq_merge) smatstr = Eq_Merge(smatstr, statmat, findcons, L, H)
	
	// make left and column titles; findcons returned w/# rows of _cons
	T.ConsSect = findcons
	MakeRCTitles(rtitles, nortitl, ctitles, noctitl, 	///
					statmat, vlabels, substat, findcons, dbls, notdbl, ///
					L,H,lc=0,hr=0)

	// fill T.Body with H, L, smatstr, addrows, and addcols
	FillBody(T,smatstr,substat,findcons,L,H,lc,hr,
		addrows,addrtc,addcols)

	if (pretext!="") T.Pretext = StrToCVec(pretext, "pretext")
	if (title!="") T.Title = StrToCVec(title, "title")
	if (note!="")  T.Note  = StrToCVec(note, "note")
	if (posttext!="")  T.Posttext  = StrToCVec(posttext, "posttext")
	if (merge | append) {
		if (pTold==NULL) 
			printf("{txt}warning: no existing table found for merge or append\n")
		else if (merge) T = Merge((*pTold),T)
		else T = Append((*pTold),T)
	}
	return(T)
}

struct FrmtTabl scalar Replay(pointer(struct FrmtTabl scalar) scalar pT,
										real   scalar replay,
										string scalar rpyname,
			  							string scalar title,
			  							string scalar note,
										string scalar ctitles,
			  							real   scalar noctitl,
			  							string scalar rtitles,
			  							real   scalar nortitl,
							  			string scalar annotate,
							  			string scalar asymbol,
			  							string scalar pretext,
			  							string scalar posttext,
			  							string scalar addrows,
			  							real	 scalar addrtc,
			  							string scalar addcols,
			  							pointer(struct FrmtTabl scalar) scalar pTmrgapp,
			  							real 	 scalar merge,
			  							real 	 scalar append,
			  							string scalar mrgappname)
{  // change titles in FrmtTabl for -replay- option,
	// merge or append with named table, and/or store w/ new name
	struct FrmtTabl scalar T

	if (mrgappname=="") mrgappname = "existing table"
	else mrgappname = "table named "+mrgappname
	if (pT==NULL) {
		if (pTmrgapp==NULL) {
			if (replay) {
				if (rpyname=="") ///
					printf(`"{err}error: no table exists for replay option\n"')
				else printf(`"{err}error: no table named "%s" exists for replay option\n"', ///
					rpyname)
				exit(198)
			}
		}
		else {
			printf("{txt}warning: no %s found with which to merge or append\n", ///
				mrgappname)
			T = *pTmrgapp
		}
	}
	else {
		T = *pT
		if (merge | append) {
			if (pTmrgapp==NULL) {
				printf("{err}error: no %s found to merge or append\n",mrgappname)
				exit(198)
			}
			else if (merge) T = Merge(T,(*pTmrgapp))
			else T = Append(T,(*pTmrgapp))
		}
	}

	if (pretext!="") T.Pretext = StrToCVec(pretext, "pretext")
	if (title!="") T.Title = StrToCVec(title, "title")
	if (note!="")  T.Note  = StrToCVec(note, "note")
	if (posttext!="")  T.Posttext  = StrToCVec(posttext, "posttext")
	if (ctitles!="" | rtitles!="" | noctitl | nortitl | annotate!="") {
		if (length(T.Body)==0) { // if _FrtmT is empty
			if (rtitles!="") L = StrToMat(rtitles, "rtitles")
			else L = J(0,0,"")
			if (ctitles!="") H = StrToMat(ctitles, "ctitles")
			else H = J(0,0,"")
			T.Body = _CRowJoin(H,L)
			Hr = rows(H)
			sr = rows(T.Body)-Hr
			if (sr>0) {
				T.SectRows = (Hr,sr)
				T.SectSubstats = (0,0)
			}
			else {
				T.SectRows = Hr
				T.SectSubstats = 0
			}
			bc = cols(T.Body)
			if (bc-addrtc>0) T.SectCols = (addrtc,bc-addrtc)
			else T.SectCols = addrtc
			if (annotate!="" & cols(T.SectRows)>1 & cols(T.SectCols)>1) /// 
					T.Body = T.Body + (J(T.SectRows[1],bc,"") \  ///
					(J(T.SectRows[2],T.SectCols[1],""), ///
					MakeSymb(annotate,asymbol,T.SectRows[2],T.SectCols[2])))
		}
		else {
			nul = J(0,0,"")		
			SplitT(T,H=nul,L=nul,Stat=nul,s=.,fr=.,lr=.)
			lco = cols(L)  // lco = old left columns
			if (rtitles!="") L = StrToMat(rtitles, "rtitles")
			else if (nortitl) L = ""
			lcn = cols(L)  // lcn = new left columns
			T.SectCols[1] = lcn
			if (ctitles!="") {
				H = StrToMat(ctitles, "ctitles")
				T.SectRows[1] = rows(H)
			}
			else if (noctitl) {
				H = ""; T.SectRows[1] = 0
			}
			else if (lcn!=lco & H!="") {  // if old H, but more L cols than before
				hc = cols(H); hr = rows(H)
				if (lcn>lco) {
					if (lco>0) UL = H[1..lco],J(hr,lcn,"")
					else UL = J(hr,lcn,"")
				}
				else if (lcn>0) UL = H[1..lcn]
				H = UL,H[lco+1..hc]
				T.SectRows[1] = hr
			}
			if (annotate!="") Stat = Stat + ///
				MakeSymb(annotate,asymbol,rows(Stat),cols(Stat))
			T.Body = _CColJoin(L,Stat)
			if (rows(L)>rows(Stat)) { // if too many rtitles
				ls = cols(T.SectRows)
				T.SectRows[ls] = T.SectRows[ls] + (rows(L)-rows(Stat))
			}
			if (cols(H)>cols(T.Body)) { // if too many ctitles
				ls = cols(T.SectCols)
				T.SectCols[ls] = T.SectCols[ls] + (cols(H)-cols(T.Body))
			}
			T.Body = _CRowJoin(H,T.Body)
		}
	}
	if (addrows!="" | addcols!="") AddRowsCols(T,addrows,addrtc,addcols)
	return(T)
}


void _CRedim(real matrix A, real scalar r, real scalar c)
{	// redimension A to r rows & c columns, adding 0's if needed
	rA = rows(A); cA = cols(A)
	if (cA!=c) {
		if (cA<c) A = A, J(rA,c-cA,0)
		else A = A[,(1..c)]
	}
	if (rA!=r) {
		if (rA<r) A = A \ J(r-rA,cols(A),0)
		else A = A[(1..r),]
	}
}


string matrix StrToCVec(string scalar s,
								string scalar opt)
{  // convert string to column vector; transpose if row vector
	sm = StrToMat(s, opt)
	sr=rows(sm); sc=cols(sm)
	if (min((sr,sc))>1) {
		errprintf("option %s should specify a vector, not a %fx%f matrix\n", ///
			opt,sr,sc)
		exit(198)
	}
	else if (sc>1) sm = sm'  //transpose to make column vector
	return(sm)
}


string matrix FmtStr(string scalar sdec,
							string scalar sfmt,
							real scalar sr,
							real scalar sc,
							real scalar ns,
							real matrix dblmat)
{	// vet, resize, and combine sdec and sfmt
	// process sdec into dec
	if (sdec=="") dec = 2
	else {
		dec = strtoreal(editvalue(StrToMat(sdec,"sdec"),"","0"))
		if (dec!=trunc(dec)| any(dec:<0) | any(dec:>15)) {
			errprintf(`"sdec contains elements other than 0,1,..,15\n"')
			exit(198)
		}
	}

	// process sfmt into fmt
	if (sfmt=="") fmt = ("fc")
	else {
		fmt = StrToMat(sfmt,"sfmt")
		legal_fmt = ("e","f","g","fc","gc")
		leg = 0
		for (i=1;i<=cols(legal_fmt);i++) leg = leg + sum(fmt:==legal_fmt[i])
		if (leg<rows(fmt)*cols(fmt)) {
			errprintf(`"sfmt contains elements other than "e","f","g","fc", and "gc"\n"')
			exit(198)
		}
	}
	
	tr = sr*ns; tc = sc/ns // dimensions of final stats table
	if (length(dec)*length(fmt)>1) { // both 1x1 is OK
		ExpandFmt(dec,tr,tc,ns)
		ExpandFmt(fmt,tr,tc,ns)
	}

	dp = (st_strscalar("c(dp)")=="comma" ? "," : ".")
	decfmt = J(rows(dec),cols(dec),"%16"+dp) + strofreal(dec) + fmt
	if (ns>1 & length(decfmt)>1) { // reshape decfmt for sr x sc statmat
		newf = J(0,sc,"")
		for (i=1;i<=tr;i=i+ns) newf = newf\(vec(decfmt[i..i+ns-1,])')
		decfmt = newf
	}
	if (sum(dblmat) & length(decfmt)>1) {  // duplicate columns for double stats
		maxindex(dblmat,1,mi=.,w=.) // column locations of 1's put in "mi"
		lc = cols(decfmt)
		for (i=1;i<=rows(mi);i++) {
			dc = mi[i]
			if (dc<=lc) decfmt = decfmt[,1..dc-1],decfmt[,dc-1],decfmt[,dc..lc]
			else decfmt = decfmt[,1..dc-1],decfmt[,dc-1]  // repeat column
			lc++
		}
	}
	return(decfmt)
}


void ExpandFmt(transmorphic matrix fmt,
					real scalar tr,
					real scalar tc,
					real scalar ns)
{	// resize either fmt to size of tr x tc
	fr = rows(fmt); fc = cols(fmt)
	if (fr>tr) {
		if (tr==0) fmt = J(0,fc,"")
		else fmt=fmt[(1..tr),] 	// delete rows if fmt has more than tr rows
	}
	else {  								// add rows if needed
		if (fr<=ns) {  // fill in fmt rows w/ repeats up to ns, then copy to tr
			if (fr<ns) fmt = fmt\J(ns-fr,1,fmt[fr,])
			fmt = J(trunc(tr/ns),1,fmt)
			// may be rows(fmt)<tr if tr/ns is not integer
			if (rows(fmt)<tr) fmt = fmt\fmt[(1..tr-rows(fmt)),] 
		}
		else if (fr<tr) fmt = fmt\J(tr-fr,1,fmt[fr,])  // fill in fmt rows w/ last row repeat
	}
	if (fc>tc) {
		if (tc==0) fmt = J(fr,0,"")
		else fmt=fmt[,(1..tc)] // delete cols if fmt has more than tc cols
	}
	else if (fc<tc) fmt = fmt,J(1,tc-fc,fmt[,fc]) // repeat last column of fmt  
}


string matrix JoinDbl(string matrix smatstr,
							real matrix dblmat,
							string scalar dbldiv,
							real scalar sr,
							real scalar sc)
{  // combine double columns of statistics							
	if (dbldiv=="") dbldiv = " - "

	if (rows(dblmat)>1) {
		errprintf("doubles (%fx%f) in not a row vector\n", ///
			rows(dblmat), cols(dblmat))
		exit(198)
	}
	if (cols(dblmat)!=sc) {
		errprintf("option doubles (1x%f) has fewer columns than statmat (%fx%f)\n", ///
			cols(dblmat), sr, sc)
		exit(198)
	}
	for (j=1;j<=sc;j++) { // combine double columns
		if (dblmat[j]) {  // don't include dbldiv or j column if ci estimate missing
			smatstr[,j-1] = smatstr[,j-1] + (dbldiv:+smatstr[,j]):*(smatstr[,j-1]:!=".")
		}
	}
	return(select(smatstr,!dblmat))  // delete double columns
}


void MakeBrac(real scalar squarebrack,
					string scalar brackets,
					real scalar sr,
					real scalar sc,
					real scalar ns,
					real scalar tex,
					string matrix lbracket,
					string matrix rbracket)
{	// vet and resize brackets; return results in lbracket and rbracket
   if (squarebrack) brack23 = "[","]"\"(",")"
   else brack23 = "(",")"\"[","]"
   if (brackets=="") {
   	if (tex) brack4_ = "$<$","$>$"\"$|$","$|$"
   	else brack4_ = "<",">"\"|","|"
   	brackets = ("",""\brack23\brack4_)
   }
   else brackets = StrToMat(brackets, "brackets")  // convert to string matrix
   br = rows(brackets)
   bc = cols(brackets)

   // pare down brackets if too many
   if (br>ns) brackets = brackets[(1..ns),]
   // fill in blank rows of brackstr if fewer brackets than statistics (ns)
   if (br<ns) brackets = brackets\J(ns-br,2,"")
   if (bc>2) {
		errprintf(`"option "brackets" (%fx%f) has more than two columns\n"', ///
			br,bc)
		exit(198)
   }

	// fill all columns
	brackcol = brackets'
   for (j=2;j<=sc/ns;j++) brackcol = brackcol,brackets'
   // split into left and right brackets and replicate for all rows
   lbrack = brackcol[1,]
   rbrack = brackcol[2,]
	lbracket = lbrack
	rbracket = rbrack
   for (i=2;i<=sr;i++) {
   	lbracket = lbracket\lbrack
   	rbracket = rbracket\rbrack
   }
}


string matrix MakeSymb(string scalar annotate,
							 	string scalar asymbol,
								real scalar sr,
								real scalar sc)
{	// convert annotation codes to symbols and return as string matrix
	annote = st_matrix(annotate)
	if (annote!=trunc(annote) | min(annote)<0) {
		errprintf("the matrix in annotate() can only contain non-negative integers\n")
		exit(198)
	}
	if (rows(annote)!=sr | cols(annote)!=sc) _CRedim(annote,sr,sc)

	symb = tokens(subinstr(asymbol,","," "))
	// fill in enough of symb for # of values in annote
	if (cols(symb)<max(annote)) {
		errprintf("warning: fewer asymbol() than values in annotate()\n")
		symb = symb,J(1,max(annote)-cols(symb),"")
   } 
	symb = J(1,1,""),symb 	// add blank for annote value 0

	symbmat = J(rows(annote),cols(annote),"")
	for (i=1;i<=rows(annote);i++) {
		for (j=1;j<=cols(annote);j++) {
			symbmat[i,j] = symb[annote[i,j]+1]
		}
	}
	return(symbmat)
}


void MakeRCTitles(string scalar rtitles,
								real scalar nortitl,
								string scalar ctitles, 
								real scalar noctitl,
								string scalar statmat, 
								real scalar vlabels, 
								real scalar substat,
								real scalar findcons,
								real scalar dbls,
								real matrix notdbl,
								string matrix L,		// from Eq_Merge if not ""
								string matrix H,		// from Eq_Merge if not ""
								real scalar lc,
								real scalar hr)
{  // make L=left titles and H=headers (column titles)
	if (!nortitl) L = MakeRtitl(rtitles,statmat,vlabels,substat,findcons,L)
	else if (rtitles!="") {
		errprintf("cannot choose both nortitl and rtitles options\n")
		exit(198)
	}
	if (L!="") lc = cols(L)
	else lc = 0
	if (!noctitl) ///
		H = MakeCtitl(ctitles,statmat,vlabels,substat,dbls,notdbl,H,lc)
	else if (ctitles!="") {
		errprintf("cannot choose both noctitl and ctitles options\n")
		exit(198)
	}
	if (H!="") hr = rows(H)
}


string matrix MakeRtitl(string scalar rtitles, 
								string scalar statmat, 
								real scalar vlabels, 
								real scalar subs,			// = substats
								real scalar findcons,
								string matrix L)			// from Eq_Merge if not ""
{  // take row names from statmat, or use rtitles to make 
	// Left Row titles.  Return findcons w/# of _cons rows.
	if (L=="") {
		L = st_matrixrowstripe(statmat)  
		L2 = L[,2] // for finding findcons even if rtitle!=""
		noeq = allof(L[,1],"")
	}
	else {  // i.e. L sent from Eq_Merge
		L2 = L; noeq = 1
	}
	lr = rows(L)
	if (rtitles=="") {
		if (noeq & L2[1]=="r1") L = ""
		else {
			// eliminate blank equation names
			if (noeq) L = L2
			else {
				L1 = L[,1]
				for (i=2;i<=lr;i++) if (L1[i]==L1[i-1]) L[i,1]="" // elim. repeats
			}
			lc = cols(L)
			if (vlabels) {  // get variable name labels
				for (i=1;i<=lr;i++) {
					if (L2[i]=="_cons") L[i,lc] = "Constant"
					else if (_st_varindex(L2[i])!=.) {
						vl = st_varlabel(L2[i])
						if (vl!="") L[i,lc] = vl
					}
				}
				if (lc==2) {
					for (i=1;i<=lr;i++) {
						if (_st_varindex(L[i,1])!=.)  {
							vl = st_varlabel(L[i,1])
							if (vl!="") L[i,1] = vl
						}
					}
				}
			}
			// add in blank rows for substats (subs)
			if (subs) {
				if (lc==1) L = vec((L[,1],J(lr,subs,""))')
				else L = vec((L[,1],J(lr,subs,""))'),vec((L[,2],J(lr,subs,""))')
			}
		}
	}
	else L = StrToMat(rtitles, "rtitles")

	// find _cons row and return its value in findcons
	if (findcons & L!="") {
		cr=0; i=1
		do {
			if (L2[i]=="_cons") cr++; i++ 
		} while (cr==0 & i<=lr)
		if (subs & cr>0) cr = cr*(subs+1)
		findcons = cr
	}
	return(L)
}


string matrix MakeCtitl(string scalar ctitles, 
								string scalar statmat, 
								real scalar vlabels, 
								real scalar substat,
								real scalar dbls,
								real matrix notdbl,
								string matrix H,			// from Eq_Merge if not ""
								real scalar Lcols)
{  // take column names from statmat, or use ctitles to make column titles.
	if (ctitles=="") {
		if (H=="") {
			H = st_matrixcolstripe(statmat)'  // transpose to a row vector
			if (allof(H[1,],"")) {
				if (H[2,1]=="c1") H = ""  // "c1" is the default column name
				else {
					H = H[2,]	// eliminate blank equation names
					// eliminate column headings for double & substat columns
					if (dbls) H = select(H,notdbl)
					if (substat) H = H[,range(1,cols(H)-substat,substat+1)]
				}
			}
		}
		else if (!substat) {  // H from Eq_Merge; redim H for substat columns
			hr = rows(H)
			ns_1 = cols(st_matrix(statmat))-1  // number of statistics - 1
			Hnew = J(hr,0,"")
			for (j=1;j<=cols(H);j++) Hnew = Hnew,H[,j],J(hr,ns_1,"")
			H = Hnew
		}
		if (H!="") { // could be "" if was "c1"
			if (vlabels) {  // get variable name labels
				lastrow = rows(H)
				for (j=1;j<=cols(H);j++) {
					if (_st_varindex(H[lastrow,j])!=.) { // check if var exists
						vl = st_varlabel(H[lastrow,j])
						if (vl!="") H[lastrow,j] = vl  // check if varlabel empty
					}
				}
			}
			H = J(rows(H),Lcols,""),H   // add blanks above leftcols
		}
	}
	else H = StrToMat(ctitles, "ctitles")
	return(H)
}

string matrix Eq_Merge(string matrix smat,
								string scalar statmat,
				  				real 	 scalar findcons,
								string matrix L,
								string matrix H)
{ // merge multiequation results into separate columns for each equation
	L = st_matrixrowstripe(statmat)
	lr = rows(L)
	sc = cols(smat)
	eqnames = L[,1]
	vnames = L[,2]
	H = eqnames[1]	// keep only unique names in H
	for (i=2;i<=lr;i++) if (eqnames[i]!=eqnames[i-1]) H = H,eqnames[i]
	eqnum = cols(H)
	if (eqnum==1) {
		errprintf("option eq_merge: no multiple equations to merge\n")
		exit(198)
	}
	pb = J(1,eqnum,NULL)  // pointer array for name vectors for each equation
	ps = pb					// pointer array for stat vectors for each equation
	for (e=1;e<=eqnum;e++) {
		pb[e] = &(J(0,1,""))
		ps[e] = &(J(0,sc,""))
		for (i=1;i<=lr;i++) {
			if(eqnames[i]==H[e]) {
				*pb[e] = *pb[e]\vnames[i]
				*ps[e] = *ps[e]\smat[i,]
			}
		}
	}
	L = *pb[1]
	smat = *ps[1]
	for (e=2;e<=eqnum;e++) { // merge multiple equations
		if (L==*pb[e]) smat = smat,*ps[e]
		else {
			L = MergeL(L,*pb[e],sortor=.,sortnr=.)
			if (sortor!=.) {
				smat = (smat\J(1,cols(smat),""))[sortor,]
				nsmat = ((*ps[e])\J(1,cols((*ps[e])),""))[sortnr,]
			}
			smat = _CColJoin(smat,nsmat)
			if (findcons) {
				minindex((L:=="_cons"),rows(L),in=.,w=.)  // put "_cons" rows last
				L = L[in]; smat = smat[in,]
			}
		}
	}
	return(smat)
}


void AddRowsCols(struct FrmtTabl scalar T,
					string matrix addrows,
					real	 scalar atc,		/// = addrtc
					string matrix addcols)
{  // attach addrows and addcols to T.Body
	if (addrows!="") {
		addrowm = StrToMat(addrows,"addrows")
		ac = cols(addrowm)
		if (length(T.Body)==0) { // if no _FrmtT yet
			T.Body = addrowm
			if (atc) T.SectCols = (atc,ac-atc)
			else T.SectCols = (0,ac)
			T.SectRows = (0,rows(addrowm))
		}
		else {
			lc = T.SectCols[1]
			if (atc) { //join left columns separately (to accommodate outreg summstat)
				if (lc) L = T.Body[.,1..lc]
				else L = J(rows(T.Body),0,"")
				T.Body = _CRowJoin(L,addrowm[.,1..atc]),		///
					_CRowJoin(T.Body[.,lc+1..cols(T.Body)],addrowm[.,atc+1..ac])
				if (atc>lc) T.SectCols[1] = atc
			}
			else {
				T.Body = _CRowJoin(T.Body,addrowm)
				atc = T.SectCols[1]
			}
			if (ac-atc>T.SectCols[2]) T.SectCols[2] = ac-atc
			T.SectRows = (T.SectRows,rows(addrowm))
			T.SectSubstats = (T.SectSubstats,0)
		}
	}
	if (addcols!="") {
		if (length(T.Body)==0) { // if no _FrmtT yet
			T.Body = addcolm
			T.SectCols = (0,cols(addcolm))
			T.SectRows = (0,rows(addcolm))
		}
		else {
			addcolm = StrToMat(addcols,"addcols")
			if (rows(addcolm)>rows(T.Body)) T.SectRows[rows(T.SectRows)] = ///
				T.SectRows[rows(T.SectRows)]+rows(addcolm)-rows(T.Body)
			T.SectCols[2] = T.SectCols[2]+cols(addcolm)
			T.Body = _CColJoin(T.Body,addcolm)
		}
	}
}


void FillBody(struct FrmtTabl scalar T,
					string matrix smatstr,
					real 	 scalar substat,
				  	real 	 scalar findcons,
					string matrix L,			/// Left (Row Titles)
					string matrix H,			/// Headers (Column Titles)
					real 	 scalar lc,			/// left columns
					real 	 scalar hr,			/// header rows
					string matrix addrows,
					real	 scalar atc,		/// = addrtc
					string matrix addcols)
{ // fill T.Body with H, L, smatstr, addrows, and addcols

	// reorganize rows of smatstr (within each ns) to put substats
	// below first statistics (e.g. t-stats below regression coefficients)
	ns = substat+1
	tc = cols(smatstr)/ns  // number of data columns in formatted table
	if (ns>1) {
		T.Body = vec(smatstr[,(1..ns)]')
		for (t=2;t<=tc;t++) {
			c1 = (t-1)*ns+1
			c2 = c1+ns-1
			T.Body = T.Body,vec(smatstr[.,(c1..c2)]')
		}
	}
	else T.Body = smatstr

	// attach L and H to T.Body and set section rows and columns 
	if (L!="") T.Body = _CColJoin(L,T.Body)
	if (T.ConsSect) {
		T.SectRows = (hr,rows(T.Body)-findcons,findcons)
		T.SectSubstats = (0,substat,findcons-1)
	}
	else {
		T.SectRows = (hr,rows(T.Body))
		T.SectSubstats = (0,substat)
	}
	if (H!="") T.Body = _CRowJoin(H,T.Body)
	T.SectCols = (lc,cols(T.Body)-lc)

	if (addrows!="" | addcols!="") AddRowsCols(T,addrows,atc,addcols)
}


void FillL(string matrix m)
{ // fill in blank rows with row above
  // for use by MergeL
	r = rows(m); c = cols(m)
	blank = (m:=="")
	for (i=2;i<=r;i++) {
		if (blank[i,1]) {
			m[i,1] = m[i-1,1]  // use text of previous row 
			if (c>1) { // fill in other blank columns
				j = 2
				while (blank[i,j]) {  // as long as columns to left are blank
					m[i,j] = m[i-1,j]  // use text of previous row 
					if (j==c) break
					j++
				}
			}
		}
	}
}


real vector selectindex10(real vector v)
{  // replacement for selectindex() so that code will run in Stata 10
// from Hua Peng of Statacorp at http://www.statalist.org/forums/forum/
//			general-stata-discussion/general/1305770-outreg-error
    real scalar row, col, cnt, i
    vector res
    
    row = rows(v)
    col = cols(v)
    
    cnt = 1
    res = J(1, row*col, 0)
    for(i=1; i<=row*col; i++) {
        if(v[i] != 0) {
            res[cnt] = i ;
            cnt++ ;
        }
    }
    
    if(cnt>1) res = res[1, 1..cnt-1]
    else res = J(1, 0, 0)
    if(row>1) res = res'
    return(res)
}

	
string matrix MergeL(string matrix Lo,
							string matrix Ln,
							real matrix sortor,
							real matrix sortnr)
{ // return merged L matrix and row sort order for Ln after merge in sortr							
	or = rows(Lo); nr = rows(Ln)
	or1 = or+1; nr1 = nr+1
	oc = cols(Lo); nc = cols(Ln)
	Lof = Lo; Lnf = Ln  // "f" for filled in
	if (oc!=nc) {
		if (oc>nc) { 
			Lof = Lof[,oc-nc+1..oc]  // only use matching columns for merge
			if (Lof=="") Lof = Lo[,1..oc-nc]  // match may be leading columns
			Ln = J(nr,oc-nc,""),Ln	// add columns of spaces to conform w/Lo
		}
		else { 
			Lnf = Lnf[.,nc-oc+1..nc]
			if (Lnf=="") Lnf = Ln[.,1..nc-oc]
			Lo = J(or,nc-oc,""),Lo
		}
	}
	if (any(Lo:=="") | any(Ln:=="")) { // if blank cells in either
		FillL(Lof); FillL(Lnf)
	}
	sortor = J(0,1,.); sortnr = sortor // sort order of old & new data rows
	LnfRest = Lnf 	// remaining Lnf
	Restid = range(1,nr,1)  // row numbers of unmatched Ln
	i = 1
	while (i<=or) { // loop through rows of Lo
		orow = Lof[i,]; oid = i++
		if (i<=or) 
			while (orow==Lof[i,]) {
				oid = oid\i++
				if (i>or) break
			}
		nid = selectindex10(rowmin(orow:==Lnf))
		not_nid = selectindex10(!rowmin(orow:==LnfRest))
		LnfRest = LnfRest[not_nid,]
		Restid = Restid[not_nid,]
		// add in blank rows to sort sequences
		if ((oidr=rows(oid)) != (nidr=rows(nid))) {
			if (oidr<nidr) oid = oid\J(nidr-oidr,1,or1)
			else nid = nid\J(oidr-nidr,1,nr1)
		}
		sortor = sortor\oid; sortnr = sortnr\nid
	}
	sortnr = sortnr\Restid
	Lo = (Lo\J(1,nc,""))[sortor,] \ // add blanks to Lo
		Ln[Restid,]  // and unmatched rows of Ln
	return(Lo)
}


void SplitT(struct FrmtTabl scalar T,
				string matrix Upper,
				string matrix L,
				string matrix Stat,
				real scalar s,
				real matrix fr,
				real matrix lr)
{ // separate out parts of T
	hr = T.SectRows[1]
	lc = T.SectCols[1]
	if (hr) Upper = T.Body[1..hr,]
	Lower = T.Body[hr+1..rows(T.Body),]
	if (lc) L = Lower[,1..T.SectCols[1]]
	Stat = Lower[,T.SectCols[1]+1..cols(T.Body)]

	s = cols(T.SectRows)-1  // number of non-header (stat) sections
	sr =  T.SectRows[2..s+1]; lr = sr
	for (i=2;i<=s;i++) lr[i] = lr[i-1]+lr[i] // last section row
	fr = lr-sr:+1 // first section row
}


struct FrmtTabl scalar Merge(struct FrmtTabl scalar To,
										struct FrmtTabl scalar Tn)
{ // merge old T (To) and new T (Tn) by rtitles
  // test with zero row SectRows

	nul = J(0,0,"")
	SplitT(To,Uppero=nul,Lo=nul,Stato=nul,so=.,fro=.,lro=.)
	SplitT(Tn,Uppern=nul,Ln=nul,Statn=nul,sn=.,frn=.,lrn=.)
	if (Uppern!=nul & Lo!=nul) Uppern = Uppern[,Tn.SectCols[1]+1..cols(Tn.Body)]

	sm = so
	if (Lo==Ln | Ln==nul) { // left titles the same or new left titles missing
		if (Lo!="") Statm = _CColJoin(Lo,_CColJoin(Stato,Statn))
		else Statm = _CColJoin(Stato,Statn) // Lo=Ln="", i.e. no left titles
	}  // no old left titles, but new ones:
	else if (Lo==nul) Statm = _CColJoin(Ln,_CColJoin(Stato,Statn))
	else {  // different, non-missing, left titles
		// warn if rtitles columns have different dimensions in old and new tables
		if (To.SectCols[1]!=Tn.SectCols[1]) ///
				printf("{txt}(note: tables being merged have different numbers of rtitle columns)\n")
		if (so!=sn) { // if different number of SectRows
			if (so>sn) {
				frn = frn,J(1,so-sn,1)  // make last row (lr) < first row (fr)
				lrn = lrn,J(1,so-sn,0)	// as a flag for not rows in section
			}
			else {
				fro = fro,J(1,sn-so,1)
				lro = lro,J(1,sn-so,0)
				sm = sn
			}
			printf("{txt}(note: tables being merged have different numbers of row sections)\n")
		}
		Statm = J(0,1,"")
		for (s=1;s<=sm;s++) {  // loop over sections
			if (lro[s]>=fro[s]) { // rows of old section
				Los = Lo[fro[s]..lro[s],]; Statos = Stato[fro[s]..lro[s],]
			}
			if (lrn[s]>=frn[s]) { // rows of new section
				Lns = Ln[frn[s]..lrn[s],]; Statns = Statn[frn[s]..lrn[s],]
			}
			if (lro[s]<fro[s]) { // no old rows in section
				if (lrn[s]<frn[s]) Stats = J(0,1,"") // no rows in either section
				else Stats = Lns,J(rows(Statns),cols(Stato),""),Statns  // some new
			}
			else if (lrn[s]<frn[s]) Stats = Los,Statos // no rows in new section
			else if (Los==Lns) Stats = Los,Statos,Statns // identical left titles
			else {
				Lm = MergeL(Los,Lns,sortor=.,sortnr=.)
				if (sortor!=.) {
					Statos = (Statos\J(1,cols(Statos),""))[sortor,]
					Statns = (Statns\J(1,cols(Statns),""))[sortnr,]
				}
				Stats = (Lm,_CColJoin(Statos,Statns))
			}
			if (s<=so) To.SectRows[s+1] = rows(Stats)
			else {  // add new row section
				To.SectRows = To.SectRows,rows(Stats)
				To.SectSubstats = To.SectSubstats,Tn.SectSubstats[s+1]
			}
			Statm = _CRowJoin(Statm,Stats)
		}
	}
	if (Uppero!=nul | Uppern!=nul) {
		if (Uppero==nul) Upper = J(rows(Uppern),cols(To.Body),""),Uppern
		else {
		   if (cols(Ln)>cols(Lo)) ///
		   	Uppero = J(rows(Uppero),cols(Ln)-cols(Lo),""),Uppero
			Upper = _CColJoin(Uppero,Uppern)
		}
		To.SectRows[1] = rows(Upper)
		To.Body = _CRowJoin(Upper,Statm)
	}
	else To.Body = Statm  // no headers
	
	// update cols of Col Sections
	if (Tn.SectCols[1]>To.SectCols[1]) To.SectCols[1] = Tn.SectCols[1]
	lco = cols(To.SectCols); lcn = cols(Tn.SectCols)
	To.SectCols[lco] = To.SectCols[lco] + Tn.SectCols[lcn] 
	if (rows(Tn.Title)) To.Title = Tn.Title  	// use new Title and Note
	if (rows(Tn.Note)) To.Note = Tn.Note		// if they exist
	return(To)
}


struct FrmtTabl scalar Append(struct FrmtTabl scalar To,
										struct FrmtTabl scalar Tn)
{ // append new T (Tn) below old T (To)
	bro = rows(To.Body); brn = rows(Tn.Body)
	bco = cols(To.Body); bcn = cols(Tn.Body)
	lco = To.SectCols[1]; lcn = Tn.SectCols[1]
	sr1n = Tn.SectRows[1]+1  // first Stats row in Tn

	To.SectCols[1] = max((lco,lcn))
	To.SectCols[2] = max((bco-lco,bcn-lcn)) // only allow 2 column sections
	if (!To.SectCols[1]) L = J(0,0,"") // no row titles
	else if (!lcn) L = To.Body[,1..lco] // old row titles only
	else if (!lco) L = J(bro,lcn,"")\Tn.Body[sr1n..brn,1..lcn] // new rtitles only 
	else L = _CRowJoin(To.Body[,1..lco],Tn.Body[sr1n..brn,1..lcn])
	Stat = _CRowJoin(To.Body[,lco+1..bco],Tn.Body[sr1n..brn,lcn+1..bcn])
	To.Body = _CColJoin(L,Stat)

	ls = cols(To.SectRows)
	To.SectRows[ls] = To.SectRows[ls]+brn-sr1n+1
	if (rows(Tn.Title)) To.Title = Tn.Title  // use new Title and Note
	if (rows(Tn.Note)) To.Note = Tn.Note	  // if they exist
	return(To)
}


struct Page_Width {
	real scalar firstcol
	real scalar lastcol
	real scalar width
}


void FrmtDisplay(struct FrmtTabl scalar T,
						real scalar wide,
						real scalar noblankrows)
{  // display table to Stata output screen
	real scalar colpad
	struct Page_Width colvector page
	struct Page_Width scalar apage
	real rowvector tablwidth
	string scalar line
	
	colpad = 2  // spaces between columns displayed

	bod = T.Body
	// eliminate completely blank rows
	if (noblankrows) bod = select(bod,rowsum(bod:==""):!=cols(bod))

	// calculate column widths of left columns and stat columns
	tablwidth = colmax(strlen(bod)) :+ colpad
	totwidth = sum(tablwidth) + colpad
	lc = T.SectCols[1]  // left columns
	if (lc) totleft  = sum(tablwidth[,1..lc]) + colpad
	else totleft = 0
	winwidth = c("linesize")  // "linesize" is width of user's result window

	// split up table into multiple pages if table too wide for result window
	// and !wide and left columns won't take up whole result window width
	if ((totwidth>winwidth) & !wide & (totleft+max(tablwidth)<winwidth)) {
		p = 1
		page = Page_Width(1,1)
		totcols = cols(bod)
		for (j=lc+1;j<=totcols;j++) {
			page[p].firstcol = j
			wdth = totleft + tablwidth[j]
			while (wdth<=winwidth & j<totcols) wdth = wdth + tablwidth[++j]
			if (wdth>winwidth | j<totcols) wdth = wdth - tablwidth[j--]
			page[p].width = wdth
			page[p].lastcol = j
			if (j<totcols) {
				page = page\apage
				p++
			}
		}
	}
	else {
		page = Page_Width(1,1)
		page[1].firstcol = lc+1
		page[1].lastcol  = cols(T.Body)
		page[1].width 	  = totwidth
	}

	// display table
	pr = rows(T.Pretext); por = rows(T.Posttext)
	tr = rows(T.Title); br = rows(bod); nr = rows(T.Note)
	// subinstr() because printf() cannot digest "%":
	if (pr) Pretext = J(pr,1,"{txt}") + 
		subinstr(subinstr(subinstr(subinstr(T.Pretext,"%","%%"),"\n","\\n"),	///
		"\r","\\r"),"\t","\\t") + J(pr,1,"\n")
	if (tr) Titltext = J(tr,1,"{txt}{center:") + 
		subinstr(subinstr(subinstr(subinstr(T.Title,"%","%%"),"\n","\\n"),	///
		"\r","\\r"),"\t","\\t") + J(tr,1,"}\n")
	Widthcol = strofreal(tablwidth)
	Widthmat = J(0,cols(tablwidth),"")
	for (i=1;i<=br;i++) Widthmat = Widthmat \ Widthcol
	Lefttext = J(br,1,"")

	BodyPrint = subinstr(subinstr(subinstr(subinstr(bod,"%","%%"),"\n","\\n"),	///
		"\r","\\r"),"\t","\\t")
	for (j=1;j<=lc;j++) Lefttext = Lefttext :+ "{txt}{lalign " ///
					:+ Widthmat[,j] :+ ":" :+ BodyPrint[,j] :+ "}"
	hr = T.SectRows[1]  // header rows					

	Lbrace = J(hr,1,"{txt}{center ") \ J(br-hr,1,"{res}{center ")
	if (nr) Notetext = J(nr,1,"{txt}{center:") + 
		subinstr(subinstr(subinstr(subinstr(T.Note,"%","%%"),"\n","\\n"),	///
		"\r","\\r"),"\t","\\t") + J(nr,1,"}\n")
	if (por) Posttext = J(por,1,"{txt}") + 
		subinstr(subinstr(subinstr(subinstr(T.Posttext,"%","%%"),"\n","\\n"), ///
		"\r","\\r"),"\t","\\t") + J(por,1,"\n")

	if (pr) {
		printf("\n")
		for (i=1;i<=pr;i++) printf(Pretext[i])
	}
	for (p=1;p<=rows(page);p++) {
		hline = sprintf("{txt}{center:{hline %f}}\n", page[p].width)
		bf = page[p].firstcol; bl = page[p].lastcol
		Bodytext = Lefttext
		for (j=page[p].firstcol;j<=page[p].lastcol;j++) Bodytext = Bodytext + ///
				Lbrace + Widthmat[,j] :+ ":" :+ BodyPrint[,j] :+ "}"
		Bodytext = "{center:" :+ Bodytext :+ "}\n"		
		if (hr) Bodytext[hr] = Bodytext[hr] + hline 	// horiz. line below header

		printf("\n") // blank line above table
		for (i=1;i<=tr;i++) printf(Titltext[i])
		printf(hline) 	// horiz. line above table
		for (i=1;i<=br;i++) printf(Bodytext[i])
		printf(hline) 	// horiz. line below table
		for (i=1;i<=nr;i++) printf(Notetext[i])
		printf("\n") // blank line below table
	}
	if (por) for (i=1;i<=por;i++) printf(Posttext[i])
}

/* ----- output file functions (for Word and TeX files) ----- */
void FrmtOut(struct FrmtTabl scalar T,
					real scalar tex,
					string scalar fname,
					real scalar replace,
					real scalar plain,
					real scalar center,
					string scalar coljust,
					string scalar colwidth,
					string scalar multicol,
					real scalar noblankrows,
					string scalar hlines,
					string scalar vlines,
					string scalar hlstyle,
					string scalar vlstyle,
					string scalar spacebef,
					string scalar spaceaft,
					real scalar spaceht,
					string scalar addfont,
					string scalar basefont,
					string scalar titlfont,
					string scalar ctitlfont,
					string scalar rtitlfont,
					string scalar statfont,
					string scalar notefont,
					real scalar lscape,
					real scalar a4,
					real scalar addtable,
					real scalar fragment)
{	// write table to .doc or .tex file
	fh = OpenFile(fname, tex, replace, addtable, approws="")

	// write formatted parts of FrmtTable to file
	if (addtable) for (i=1;i<=rows(approws);i++) fput(fh,approws[i])
	if (!tex) {  // word file
		BegDoc(T,fh,addfont,basefont,lscape,a4,addtable,plain,center, 		///
			titlfont,spacebef,spaceaft,spaceht,bodyspaces="",endspaces="",	///
			deffs=.,nfcount=0)
		BodyDoc(T,fh,coljust,colwidth,hlines,vlines,plain,						///
			ctitlfont,rtitlfont,statfont,multicol,noblankrows,center,		///
			hlstyle,vlstyle,bodyspaces,deffs,nfcount)
		EndDoc(T,fh,plain,center,notefont,endspaces,deffs,nfcount)
	}
	else {  // tex file
		BegTex(T,fh,basefont,lscape,a4,addtable,plain,center,titlfont,		///
			spacebef,spaceaft,spaceht,bodyspaces="",endspaces="",fragment)
		BodyTex(T,fh,coljust,hlines,vlines,plain,ctitlfont,rtitlfont,		///
			statfont,multicol,noblankrows,bodyspaces)
		EndTex(T,fh,plain,center,notefont,endspaces,fragment)
	}
	fclose(fh)
}


real scalar OpenFile(string scalar fname,
							real scalar tex,
							real scalar replace,
							real scalar addtable,
							string matrix approws)
{	// open file returning file handle number
	if (pathsuffix(fname)=="") {
		if (!tex) fname = fname + ".doc"
		else fname = fname + ".tex"
	}
	fexist = fileexists(fname)
	if (replace & !addtable) {
		if (fexist) {
			unl_err = _unlink(fname)
			if (unl_err<0) {
				errprintf(`"file "%s" cannot be replaced: in use?\n"',fname)
				exit(-unl_err)
			}
		}
		else printf("{txt:(note: file %s not found)}", fname)
	}
	if (addtable) {
		if (fexist) fh = _fopen(fname, "rw")
		else {
			errprintf(`"file "%s" not found for addtable\n"',fname)
			exit(198)
		}
	}
	else fh = _fopen(fname, "w")  
	if (fh<0) {
		if (fh==-602) {
			errprintf("file %s already exists\n",fname)
			exit(602)
		}
		else exit(error(-fh))
	}
	if (addtable) { // read file into approws
		approws = J(0,1,"")
		while ((line=fget(fh))!=J(0,0,"")) approws = approws\line
		lr = rows(approws)
		if (lr) {  // i.e. there are lines from existing file
			if (!tex) approws[lr] = substr(approws[lr],1,strlen(approws[lr])-1) // word
			else approws[lr] = subinstr(approws[lr],"\end{document}","") // tex
		}
		fseek(fh,0,-1)
	}
	return(fh)
}

void BegDoc(struct FrmtTabl scalar T,
				real scalar fh,
				string scalar addfont,
				string scalar basefont,
				real scalar lscape,
				real scalar a4,
				real scalar addtable,
				real scalar plain,
				real scalar center,
				string scalar titlfont,
				string scalar spacebef,
				string scalar spaceaft,
				real scalar spaceht,
				string scalar bodyspaces,
				string scalar endspaces,
				real scalar deffs,
				real scalar nfcount)
{	// write docbeg and pretext to file
	if (addfont!="") {
		nf = StrToMat(addfont,"addfont")
		nfcount = cols(nf)
		nfseq = range(1,nfcount,1)'
		nf = "{\f":+strofreal(nfseq:+2):+"\fnew":+strofreal(nfseq):+" ":+nf:+";}"
		addfont = ""
		for (i=1;i<=nfcount;i++) addfont = addfont+nf[i]
	}
	if (basefont!="") fontvec = ParseFDoc(basefont,"basefont",nfcount,deffs)
	if (deffs==.) deffs = 24
	if (!addtable) {
		if (lscape) {
			if (a4) paperwh = "\paperw16834\paperh11909\psz9\lndscpsxn"
			else paperwh = "\paperw15840\paperh12240\lndscpsxn"
		}
		else {
			if (a4) paperwh = "\paperw11909\paperh16834\psz9"
			else paperwh = ""
		}
		docbeg = "{\rtf1\ansi\deff0{\fonttbl{\f0\froman Times New Roman;}"+
			"{\f1\fswiss Arial;}{\f2\fmodern Courier New;}"+addfont+"}"
		if (basefont!="") ///
			for (i=1;i<=cols(fontvec);i++) docbeg = docbeg+fontvec[i]
		docbeg = docbeg+paperwh
		fput(fh,docbeg)
	}
	if (rows(T.Pretext)) {
		pretext = "\pard\sb0\sa0\fs"+strofreal(deffs)+" ":+T.Pretext:+"\par"
		for (i=1;i<=rows(pretext);i++) fput(fh,pretext[i])
	}
	sht = strofreal(round(spaceht*deffs*3.3))
	spbefstr = ("\sb0","\sb"+sht):*J(3,2,1)
	spaftstr = subinstr(spbefstr,"sb","sa")
	MakeSpaces(T,spacebef,spaceaft,plain,spbefstr,spaftstr,	///
		titlspaces="",bodyspaces,endspaces)
	bodyspaces = bodyspaces[,1]+bodyspaces[,2]
	if (endspaces!="") endspaces = endspaces[,1]+endspaces[,2]

	if (rows(T.Title)) ///
		TitlNoteDoc(T.Title,fh,titlfont,"titlfont",plain,center,	///
			titlspaces[,1]+titlspaces[,2],deffs,nfcount)
}

void BodyDoc(struct FrmtTabl scalar T,
					real scalar fh,
					string scalar coljust,
					string scalar colwidth,
					string scalar hlines,
					string scalar vlines,
					real scalar plain,
					string scalar ctitlfont,
					string scalar rtitlfont,
					string scalar statfont,
					string scalar multicol,
					real scalar noblankrows,
					real scalar center,
					string scalar hlstyle,
					string scalar vlstyle,
					string matrix bodyspaces,
					real scalar deffs,
					real scalar nfcount)
{	// write T.Body to file w/ Tex formatting
	bod = T.Body  // should not alter T.Body itself
	br = rows(bod)
	bc = cols(bod)
	
	rowcodes = MakeRCodes(T,deffs,hlines,hlstyle,vlines,vlstyle,	///
		center,colwidth,multicol,coljust,bodyspaces)
	// n.b. MakeRCodes transforms coljust into matrix

	if (!plain) {
		for (i=1;i<=br;i++) {  // prettify R^2 & N
			if (bod[i,1]=="R2") bod[i,1] = "{\i R}{\super 2}"
			if (bod[i,1]=="N") bod[i,1] = "{\i N}"
		}
	}

	// n.b. ctbegm is ctitle font beginning matrix; ctendm is ctitle font ending matrix
	hr = T.SectRows[1]  // last ctitle (header) row
	if (ctitlfont!="") 	///
		ParseFMDoc(ctitlfont,"ctitlfont",ctbegm="",ctendm="",0,hr,bc,1,nfcount)
	else {
		ctbegm=J(hr,bc,""); ctendm=ctbegm
	}
	lc=T.SectCols[1]  // left columns
	if (rtitlfont!="") {
		FontSect(rtitlfont,T,lr=.,ns=.) // converts rtitlfont to colvector
		ltbegm = J(0,lc,""); ltendm=ltbegm
		for (i=1;i<=cols(rtitlfont);i++) {
			ParseFMDoc(rtitlfont[i],"rtitlfont",bm="",em="",0,lr[i],lc,ns[i],	///
				nfcount)
			ltbegm = (ltbegm\bm); ltendm = (ltendm\em)
		}
	}
	else {
		ltbegm=J(br-hr,lc,""); ltendm=ltbegm
	}
	StatFDoc(T,plain,statfont,stbegm="",stendm="",deffs,nfcount)

	begfont = coljust+(ctbegm\(ltbegm,stbegm))
	endfont = (ctendm\(ltendm,stendm))
	bod = begfont+bod+endfont:+"\cell"
	bod[,bc] = bod[,bc]:+"\row"
	bodrows = rowcodes
	for (j=1;j<=bc;j++) bodrows = bodrows:+" ":+bod[,j]
	// eliminate completely blank rows
	if (noblankrows) bodrows = select(bodrows,	///
		rowsum(T.Body:==""):!=cols(T.Body))
	for (i=1;i<=rows(bodrows);i++) fput(fh, bodrows[i])
}

void EndDoc(struct FrmtTabl scalar T,
				real scalar fh,
				real scalar plain,
				real scalar center,
				string scalar notefont,
				string matrix endspaces,
				real scalar deffs,
				real scalar nfcount)
{	// write posttext and docend to file
	if (rows(T.Note)) TitlNoteDoc(T.Note,fh,notefont,"notefont",plain,	///
		center,endspaces,deffs,nfcount)
	// even if posttext=="", still set \pard to normal
	if (rows(T.Posttext)) {
		posttext = "\pard\sb0\sa0\fs"+strofreal(deffs)+" ":+T.Posttext:+"\par"
		for (i=1;i<=rows(posttext);i++) fput(fh,posttext[i])
	}
	else fput(fh,"\pard\sb0\sa0\fs"+strofreal(deffs)+"\par")
	fput(fh,"}")
}

void MakeSpaces(struct FrmtTabl scalar T,
					string scalar spacebef,
					string scalar spaceaft,
					real   scalar plain,
					string matrix spbefstr,
					string matrix spaftstr,
					string matrix titlspaces,
					string matrix bodyspaces,
					string matrix endspaces)
{ // create spacing command strings	in titlspaces, bodyspaces, endspaces
	if (!plain) {  // set default spacebef and spaceaft
		if (spacebef=="") spacebef = "1{0};1{0};1{0};{0};{0};1{0}"
		if (spaceaft=="") {
			spaceaft = "{0}1;{0}1;"
			ns = cols(T.SectSubstats)
			for (i=2;i<=ns;i++) {
				if (T.SectSubstats[i]>0) spaceaft = spaceaft+"{"+	///
					T.SectSubstats[i]*"0"+"1};"
				else if (i==ns) spaceaft = spaceaft+"{0}1;"
				else spaceaft = spaceaft+"{0};"
			}
			spaceaft = spaceaft+"{0}1"
		}
	}
	tr = rows(T.Title)
	br = rows(T.Body)
	nr = rows(T.Note)
	trbr = tr+br
	trbrnr = trbr+nr
	sects = (tr,T.SectRows,nr)
	if (spacebef!="") ExpandSpace(tr,br,nr,sects,spacebef,spbefstr)
	else spbefstr = J(trbrnr,1,"")
	if (spaceaft!="") ExpandSpace(tr,br,nr,sects,spaceaft,spaftstr)
	else spaftstr = J(trbrnr,1,"")
	spaces = (spbefstr, spaftstr)
	if (tr) titlspaces = spaces[1..tr,]
	bodyspaces = spaces[tr+1..trbr,]
	if (nr) endspaces = spaces[trbr+1..trbrnr,]
}


void ExpandSpace(real scalar tr,
						real scalar br,
						real scalar nr,
						real rowvector sects,
						string scalar space,
						string matrix spstr)
{	// Parse and expand spaces to size of table rows
	spacev = strtoreal(ParseLines(space,"space",sects,"01"))'
	spstr = spstr[1,]:*J(tr,2,1)\	///  expand to size of table rows
			  spstr[2,]:*J(br,2,1)\	///
			  spstr[3,]:*J(nr,2,1)
	spstr = spstr[,1]:*!spacev + spstr[,2]:*spacev
}
									

void TitlNoteDoc(string matrix Ttitl_note,
						real scalar fh,
						string scalar fonts,
						string scalar opt,
						real scalar plain,
						real scalar center,
						string matrix spaces,
						real scalar deffs,
						real scalar nfcount)
{  // write T.Title or T.Note to file with Word formatting
	titl_note = Ttitl_note  // don't modify T.Title or T.Note
	r = rows(titl_note)
	if (center) qc = "\qc"
	else qc = ""
	if (fonts!="") ParseFMDoc(fonts,opt,begm="",endm="",1,r,1,1,nfcount)
	else {
		begm = J(r,1,""); endm = begm
		if (!plain) {
			if (opt=="titlfont") {
				begm = "\fs"+strofreal(round(deffs*1.2))
				if (r>1) begm = begm\J(r-1,1,"\fs"+strofreal(round(deffs*1.125)))
			}
			else begm=J(r,1,"\fs"+strofreal(round(deffs*0.79)))  // for T.Note
		}
	}
	if (!plain) pard = "\pard"+qc:+spaces
	else pard = "\pard"+qc
	begm = pard:+begm:+" "
	if (!plain&opt=="notefont") ///  make "p" italic
		titl_note[1] = subinstr(titl_note[1]," p<0."," {\i p}<0.")
	titl_note = begm:+titl_note:+endm:+"\par"
	for (i=1;i<=r;i++) fput(fh,titl_note[i])
}


string matrix ParseFDoc(string scalar font,	// font info string
								string scalar opt,	// calling option name (for err message)
								real scalar nfcount,	// new font count
								|real scalar deffs)  // default font size
{ // check contents of font and convert fs values to points*2; 
	// return deffs if included in args
	allowf = ("roman","arial","courier")

	if (nfcount & nfcount!=.) /// add fnew# for user-specified fonts
		allowf = allowf,"fnew":+strofreal(range(1,nfcount,1)')
	fnum = range(0,cols(allowf)-1,1)
	allowch = ("plain","b","i","scaps","ul","uldb","ulw")
	fontvec = tokens(font)
	for (i=1;i<=cols(fontvec);i++) {  // check elements of font
		afont = fontvec[i]; err = 0
		if (substr(afont,1,2)=="fs") {
			fsN = strtoreal(substr(afont,3))
			if (fsN!=. & fsN>0) {
				deffs = round(fsN*2)  // return deffs if passed as parameter
				fontvec[i] = "fs"+strofreal(deffs)
			}
			else err = 1
		}
		else {
			an_f = allowf:==afont
			if (any(an_f)) fontvec[i] = "f"+strofreal(an_f*fnum)
			else if (!any(allowch:==afont)) err = 1
		}

		if (err) {
			errprintf(`"font "%s" not allowed in %s option\n"', ///
				fontvec[i], opt)
			exit(198)		
		}
	}
	return("\":+fontvec)
}


void ParseFMDoc(string scalar font,	// font string
					string scalar opt,	// name of calling option (for err message)
					string matrix begm,	// matrix of codes before
					string matrix endm,	// matrix of codes before
					real scalar colvec,	// colvector instead of matrix
					real scalar fr,		// font rows
					real scalar fc,		// font columns
					real scalar ns,		// number of substats
					real scalar nfcount)	// new font count	
{ // parse font options into a string matrix: titlfont, notefont, & statfont
	if (colvec) fontm = StrToCVec(font,opt)
	else fontm = StrToMat(font,opt)
	r = rows(fontm); c = cols(fontm)
	begm = J(r,c,""); endm = J(r,c,"")
	for (i=1;i<=r;i++) {
		for (j=1;j<=c;j++) {
			fontcell = ParseFDoc(fontm[i,j],opt,nfcount)
			begf = ""
			for (k=1;k<=cols(fontcell);k++) begf = begf+fontcell[k]
			if (begf!="") {
				begm[i,j] = "{"+begf+" "; endm[i,j] = "}"
			}
		}
	}
	ExpandFmt(begm,fr,fc,ns); ExpandFmt(endm,fr,fc,ns)
}


void StatFDoc(struct FrmtTabl scalar T,
					real scalar plain,
					string scalar statfont,
					string matrix begm,
					string matrix endm,
					real scalar deffs,
					real scalar nfcount)
{  // fill in font codes for statistics (not ctitles or rtitles)
	r = rows(T.Body)-T.SectRows[1] // subtract off header rows
	c = cols(T.Body)-T.SectCols[1] // subtract off left columns
	if (statfont!="") {
		FontSect(statfont,T,sr=.,ns=.)  // sr is # rows in each stat row section
		begm=J(0,c,""); endm=begm			// ns = # substats in each stat row section
		for (i=1;i<=cols(statfont);i++) {
			ParseFMDoc(statfont[i],"statfont",bm="",em="",0,sr[i],c,ns[i],nfcount)
			begm = (begm\bm); endm = (endm\em)
		}
	}
	else if (!plain & T.SectSubstats[2]) {
		rs = cols(T.SectRows)	// rs = row sections
		if (rs>=3) er = sum(T.SectRows[2..3])  // er = estimates rows
		else if (T.ConsSect) er = r  		// no addrow
		else er = T.SectRows[2]				// no ConsSect
		xr = r - er
		font = "fs"+strofreal(deffs/2)+"\fs"+strofreal(round(deffs/2*0.85))
		ParseFMDoc(font,"statfont",begm,endm,0,er,c,T.SectSubstats[2]+1,nfcount)
		begm = (begm\J(xr,c,"")); endm = (endm\J(xr,c,""))
	}
	else {
		begm=J(r,c,""); endm=begm
	}
}

string matrix MakeRCodes(struct FrmtTabl scalar T,
								real scalar deffs,
								string matrix hlines,
								string scalar hlstyle,
								string matrix vlines,
								string scalar vlstyle,
								real scalar center,
								string scalar colwidth, 
								string scalar multicol,
								string scalar coljust,
								string matrix bodyspaces)
{  // parse hlines, vlines, & coljust and create table row codes for RTF document
	br = rows(T.Body); bc = cols(T.Body)
	hr = T.SectRows[1]  // last ctitle (header) row

	if (coljust=="") coljust = "l;."
	coljust = ParseLines(coljust,"coljust",T.SectCols,"lcr.")
	calcwidth = colmax(strlen(T.Body))
	deccol = (coljust:==".")
	if (any(deccol)) { // calculate width of cols w/ decimal justification
		dp = (st_strscalar("c(dp)")=="comma" ? "," : ".")
		decpos = strpos(T.Body[hr+1..br,],dp):-1 // location of decimal point in column
		maxdecpos = colmax(decpos)  
		// max width to left of decimal + max width to right of decimal
		maxdecwidth = maxdecpos + 	///
			(colmax((strlen(T.Body[hr+1..br,])-decpos):*(decpos:>0)))
		// add in padding if calcwidth>maxdecwidth (e.g. wide ctitles)
		maxdecpos = maxdecpos + 0.5:*(colmax((maxdecwidth\calcwidth))-maxdecwidth)
		calcwidth = (calcwidth:*deccol) + (colmax((maxdecwidth\calcwidth)):*!deccol)
	}
	else maxdecpos = calcwidth

	if (colwidth!="") {
		cwidth = strtoreal(tokens(colwidth))  // convert to real matrix
		// if cwidth not long enough, fill in with calcwidth
		if (cols(cwidth)<bc) cwidth = cwidth,calcwidth[cols(cwidth)+1..bc]
		else cwidth = cwidth[1..bc]  // might be longer than # of columns
		maxdecpos = maxdecpos:*(cwidth:/(calcwidth*1.2))  // rescale for user colwidth
	}
	else cwidth = calcwidth

	hcoljust = "\q":+subinstr(coljust,".","c"):+" " // make coljust c for header
	// factor of 5.7*maxdecpos:+11 works to convert decimal point position 
	//    to tab stop "\tx"
	bcoljust = ("\pard\intbl\tqdec\tx":+strofreal(round((5.7*maxdecpos:+11)*deffs)):+" ")	///
		:*deccol + ("\pard\intbl\q":+coljust:+" "):*!deccol
	coljust = (hcoljust:*J(hr,bc,1)) \ (bcoljust:*J(br-hr,bc,1))

	// factor of 7 seems to work to convert # of characters to cell width
	cellx = J(br,bc,"\cellx"):+strofreal(round(runningsum(cwidth)*deffs*7))  
	if (multicol!="") {
		mc = VetMulti(multicol,br,bc)
		for(r=1;r<=rows(mc);r++) {
			i = mc[r,1]; c1 = mc[r,2]; c2 = mc[r,2]+mc[r,3]-1
			cellx[i,c1] = "\clmgf"+cellx[i,c1]
			for (j=c1+1;j<=c2;j++) cellx[i,j] = "\clmrg"+cellx[i,j]
		}
	}

	if (vlines=="") vlines = "0"
	vlines = HVLines(T.SectCols,vlines,vlstyle,"v")  // parse vlines
	if (hlines=="") hlines = "1{0};1{0}1"
	hlines = HVLines(T.SectRows,hlines,hlstyle,"h")'  // parse hlines
	if (center) trqc = "\trqc"
	else trqc = ""
	rowcodes = "\trowd\intbl\trautofit1\trgaph144":+bodyspaces:+trqc
	for (j=1;j<=bc;j++) rowcodes = rowcodes:+vlines[j]:+hlines:+cellx[,j]
	rowcodes = rowcodes:+"\fs"+strofreal(deffs)
	return(rowcodes)
}

void FontSect(string scalar font,
					struct FrmtTabl scalar T,
					real scalar fr,
					real matrix ns)
{ // split font into multiple row sections; put rows in fr;
  // split ns (# stats) into sections
	font = tokens(font,";")
	font = select(font,font:!=";")  // remove ";"
	fs = cols(font)       	// font sections
	if (fs>1) {
		rs = cols(T.SectRows)-1		// row sections, not including header
		fr = T.SectRows[2..rs+1]  // remove header row section
		if (fs>rs) {
			font = font[1..rs]
			fs = rs
		}
		else if (fs<rs) {
			fr[fs] = sum(fr[fs..rs]); fr = fr[1..fs]
		}
	}
	else fr = rows(T.Body)-T.SectRows[1]
	ns = T.SectSubstats[2..fs+1]:+1 // split off headrow substats
}


string matrix HVLines(real matrix Tsects,
				string scalar lines,
				string scalar lstyle,
				string scalar optpref)
{	// parse vlines or hlines creating "\clbrdr" code
	sects = Tsects
	sects[cols(sects)] = sects[cols(sects)]+1 // add column or row for end line
	lines = ParseLines(lines,optpref+"lines",sects,"01")
	c = cols(lines); c_1 = c-1			
	if (lstyle=="") brdr = J(1,cols(lines),"\brdrs")
	else {  // parse lstyle
		brdr = ParseLines(lstyle,optpref+"lstyle",sects,"sdoaSDOA")
		lowbrdr = strlower(brdr)
		brdr = (brdr:!=lowbrdr):*"\brdrw25"  // greater line weight for uppercase
		brdr = "\brdr":+subinstr(subinstr(subinstr(	///
			lowbrdr,"d","db"),"o","dot"),"a","dash"):+brdr
	}
	for (i=1;i<=c;i++) if (lines[i]=="0") brdr[i] = ""
	// convert 1's to "\clbrdr" and add brdr
	if (optpref=="v") {
		clbrdr1 = "\clbrdrl"; clbrdr2 = "\clbrdrr"
	}
	else {
		clbrdr1 = "\clbrdrt"; clbrdr2 = "\clbrdrb"
	}
	lastline = lines[c]=="1"			
	lines = subinstr(subinstr(lines[1..c_1],"0",""),"1",clbrdr1)	///
		+brdr[1..c_1]
	if (lastline) lines[c_1] = lines[c_1]+clbrdr2+brdr[c]
	return(lines)
}


string rowvector ParseLines(string scalar l,
							string scalar opt,
							real rowvector sectr,  /// section rows (or cols)
							string scalar pchars)
{	// fill out hlines or vlines to dimensions of T.Body
	sr = sectr  // put in new variable so that sectr not changed
	l = subinstr(l," ","")  // get rid of blank spaces
	inot = indexnot(l, pchars+"{};") 
	if (inot) {
		errprintf(`"character "%s" not allowed in %s option\n"', ///
			substr(l,inot,1), opt)
		exit(198)		
	}
	lvec = tokens(l,";")
	lvec = select(lvec,lvec:!=";")  // strip out ;
	lc = cols(lvec); sc = cols(sr)
	if (lc==1) sr = sum(sr)		// make lvec and sr conformable
	else if (lc>sc) lvec = lvec[1..sc]  
	else if (sc>lc) sr = sr[1..lc-1],sum(sr[lc..sc])
	newl = ""
	for (i=1;i<=cols(lvec);i++) {
		if (sr[i]>0) {  // if no rows (or columns) in section, ignore
			lsec = tokens(lvec[i],"{}")
			lsc = cols(lsec)
			strp = select(lsec, lsec:!="{"); strp = select(strp, strp:!="}")
			if (lsc - cols(strp) > 2) {
				errprintf("more than one {} per section of %s: %s\n", ///
						opt, lvec[i])	
				exit(198)		
			}
			if (lsc==1) {
				slen = strlen(lsec[1])
				if (slen>1) begl = substr(lsec[1],1,slen-1)
				else begl = ""
				midl = substr(lsec[1],slen)
				endl = ""
			}
			else {
				if (lsec[1]=="{") {
					begl = ""
					midl = lsec[2]
					gap = 1
				}
				else {
					begl = lsec[1]
					gap = sr[i]-strlen(begl)  // if length(begl)>sr[i], pare down
					if (gap<0) begl = substr(begl,1,sr[i]) 
					midl = lsec[3]
				}
				if (lsec[lsc]!="}" & gap>0) { // if length(begl)>sr[i], no endl
					endl = lsec[lsc]
					sp = sr[i] - strlen(begl)  
					gap =  sp - strlen(endl)  	// if len(endl)>sr[i]-len(begl),
					if (gap<0) endl = substr(endl,-sp,sp) //	take from end back
				}
				else endl = ""
			}
			gap = sr[i] - strlen(begl) - strlen(endl)
			midl = substr(ceil(gap/strlen(midl))*midl,1,gap)
			newl = newl + begl + midl + endl
		}
	}
	nlvec = J(1,0,"")
	for (i=1;i<=strlen(newl);i++) nlvec = nlvec,substr(newl,i,1)
	return(nlvec)
}


real matrix VetMulti(string scalar multicol,
							real scalar br,
							real scalar bc)
{ // vet multicolumn coordinates and convert to real matrix
	mcol = tokens(multicol,";")
	mcol = select(mcol,mcol:!=";")  // remove ";"
	msm = J(0,3,"")
	maxb = max((br,bc))
	allowed = strofreal(range(1,maxb,1))
	for (i=1;i<=cols(mcol);i++) {
		ms = tokens(mcol[i],",")
		ms = select(ms,ms:!=",")  // remove "," 
		if (cols(ms)!=3) {
			errprintf("option multicol requires three coordinates per cell\n")
			exit(198)
		}
		if (any(colmin(indexnot(ms,allowed)))) {
			errprintf("option multicol coordinates have characters other than 1,..,%f\n", ///
				maxb)
			exit(198)
		}
		if (ms[3]=="1") {
			errprintf("option multicol(r,c,numcol) needs more than 1 column (numcol>1) to combine\n")
			exit(198)
		}
		msm = msm\ms
	}
	m = strtoreal(msm)	// convert to real
	if (br<bc) { // otherwise checked above already
		minindex(m[,1],-1,i,w); i = i[1]  // get rid of dupes
		if (m[i,1]>br) {
			errprintf("option multicol row coordinate (%f) is out of table range\n", ///
				m[i,1])
			exit(198)
		}
	}
	mc = m[,2]+m[,3]:-1
	minindex(mc,-1,i,w); i = i[1]  // get rid of dupes
	if (mc[i]>bc) {
		errprintf("option multicol column coordinates (%f..%f) are out of table range (1..%f)\n", ///
			m[i,2],mc[i],bc)
		exit(198)
	}
 	return(m)
}


void BegTex(struct FrmtTabl scalar T,
				real scalar fh,
				string scalar basefont,
				real scalar lscape,
				real scalar a4,
				real scalar addtable,
				real scalar plain,
				real scalar center,
				string scalar titlfont,
				string scalar spacebef,
				string scalar spaceaft,
				real scalar spaceht,
				string scalar bodyspaces,
				string scalar endspaces,
				real scalar fragment)
{	// write docbeg, pretext, center, Title to file
	if (!addtable & !fragment) {
		docbeg = ""
		setlength = ""
		if (basefont!="") { // ParseFTex also puts font size back in basefont
			fontvec = ParseFTex(basefont, "basefont", 0)
			if (cols(fontvec)>0) docbeg = "\"+subinstr(invtokens(fontvec)," ","\")
			if (lscape | a4) basefont = basefont+","
		}
		if (lscape) {
			if (a4) {
				basefont = basefont+"landscape,a4paper"
				setlength = "\setlength{\pdfpagewidth}{297mm}"+	///
					"\setlength{\pdfpageheight}{210mm}"
			}
			else {
				basefont = basefont+"landscape"
				setlength = "\setlength{\pdfpagewidth}{11in}"+	///
					"\setlength{\pdfpageheight}{8.5in}"
			}
		}
		else if (a4) {
			basefont = basefont+"a4paper"
			setlength = ""
		}
		
		dp = (st_strscalar("c(dp)")=="comma" ? "," : ".")
		docbeg = "\documentclass["+basefont+"]{article}\pagestyle{empty}" ///
			+setlength+"\begin{document}"+docbeg
		fput(fh,docbeg)
	}
	for (i=1;i<=rows(T.Pretext);i++) {
		fput(fh,""); fput(fh,T.Pretext[i])	// insert blank line to end paragraph
	}
	if (center) fput(fh,"\begin{center}")
	
	if (!anyof((1,2,3),spaceht)) {
		errprintf(`"spaceht option must = 2 or 3 with tex option\n"')
		exit(198)		
	}
	sht = ("\smallskip","\medskip","\bigskip")[spaceht]
	spbefstr = ("",sht\"","\noalign{"+sht+"}"\"",sht)
	spaftstr = spbefstr
	MakeSpaces(T,spacebef,spaceaft,plain,spbefstr,spaftstr,	///
		titlspaces="",bodyspaces,endspaces)
	if (rows(T.Title)) TitlNoteTex(T.Title,fh,titlfont,"titlfont",plain,titlspaces)
}

void BodyTex(struct FrmtTabl scalar T,
					real scalar fh,
					string scalar coljust,
					string matrix hlines,
					string scalar vlines,
					real scalar plain,
					string scalar ctitlfont,
					string scalar rtitlfont,
					string scalar statfont,
					string matrix multicol,
					real scalar noblankrows,
					string matrix spaces)
{	// write T.Body to file w/ Tex formatting
	bod = subinstr(T.Body,"#","\#")  // don't alter T.Body itself; put "\" before "#" for factor variables
	bod = subinstr(bod,"_cons","\_cons")  // put "\" before "_cons"
	br = rows(bod)
	bc = cols(bod)

	fput(fh,"\begin{tabular}{"+TabularCols(vlines,coljust,T)+"}") // table begin
	lastspace = spaces[br,2]			// separate last aft space
	frstcol = (""\spaces[1..br-1,2])+ParseHLines(hlines,T)+spaces[,1] // offset bef & aft spaces
	
	if (!plain) {
		for (i=1;i<=br;i++) {  // prettify R^2 & N
			if (bod[i,1]=="R2") bod[i,1] = "\$R^2$"
			if (bod[i,1]=="N") bod[i,1] = "\$N$"
		}
	}
	
	hr=T.SectRows[1]  // last ctitle (header) row
	if (ctitlfont!="") ParseFMTex(ctitlfont,"ctitlfont",	///
			ctbegm="",ctendm="",0,hr,bc,1)
	else {
		ctbegm=J(hr,bc,""); ctendm=ctbegm
	}

	lc=T.SectCols[1]  // left columns
	if (rtitlfont!="") {
		FontSect(rtitlfont,T,lr=.,ns=.) // converts rtitlfont to colvector
		ltbegm = J(0,lc,""); ltendm=ltbegm
		for (i=1;i<=cols(rtitlfont);i++) {
			ParseFMTex(rtitlfont[i],"rtitlfont",bm="",em="",0,lr[i],lc,ns[i])
			ltbegm = (ltbegm\bm); ltendm = (ltendm\em)
		}
	}
	else {
		ltbegm=J(br-hr,lc,""); ltendm=ltbegm
	}

	StatFTex(T,plain,statfont,stbegm="",stendm="")

	begfont = (ctbegm\(ltbegm,stbegm))
	endfont = (ctendm\(ltendm,stendm))
	bod = begfont+bod+endfont
	// add spacer characters for tabular
	delim = (J(br,bc-1," & "),J(br,1,"\\"))
	if (multicol!="") {
		mc = VetMulti(multicol,br,bc)
		for(r=1;r<=rows(mc);r++) {
			i = mc[r,1]; c1 = mc[r,2]; c2 = mc[r,2]+mc[r,3]-1
			bod[i,c1] = "\multicolumn{"+strofreal(mc[r,3])+"}{c}{"+bod[i,c1]+"}"
			for (j=c1+1;j<=c2;j++) {
				bod[i,j] = ""; delim[i,j] = ""
			}
			if (c2==bc) delim[i,c1] = "\\"
		}
	}
	bod = bod+delim

	bodrows = frstcol
	for (j=1;j<=bc;j++) bodrows = bodrows+bod[,j]
	// eliminate completely blank rows
	if (noblankrows) bodrows = select(bodrows,	///
		rowsum(T.Body:==""):!=cols(T.Body))
	for (i=1;i<=rows(bodrows);i++) fput(fh, bodrows[i])
	lastline = lastspace + (hlines[br+1]=="1")*"\hline" + "\end{tabular}\\"
	fput(fh,lastline)		// table end
}


void EndTex(struct FrmtTabl scalar T,
				real scalar fh,
				real scalar plain,
				real scalar center,
				string scalar notefont,
				string matrix endspaces,
				real scalar fragment)
{	// write Note, center, posttext, and \end to file
	if (rows(T.Note)) TitlNoteTex(T.Note,fh,notefont,"notefont",plain,endspaces)
	if (center) fput(fh,"\end{center}")
	for (i=1;i<=rows(T.Posttext);i++) {
		fput(fh,""); fput(fh,T.Posttext[i]) // insert blank line to end paragraph
	}
	if (!fragment) fput(fh,"\end{document}")
}

void TitlNoteTex(string matrix Ttitl_note,
						real scalar fh,
						string scalar fonts,
						string scalar opt,
						real scalar plain,
						string matrix spaces)
{  // write T.Title or T.Note to file with TeX formatting
	titl_note = Ttitl_note  // don't modify T.Title or T.Note
	if (opt=="notefont") {  // avoid initial "*" and make "<" appear properly
		if (substr(titl_note[1],1,1)=="*") titl_note[1] = "\ "+titl_note[1]   
		titl_note[1] = subinstr(titl_note[1]," p<0"," \$p<0$")
	}
// 	pseudocode for default values of formatting (not set up yet)
//		else if _FrmtTexBegTitl _FrmtTexEndTitl _FrmtTexTitlFont (use ExpandFmt)
// 		check if default TeX formatting exists; if not, create it
//			pLeft = findexternal("_FrmtTeXLeft")
//				if (pLeft!=NULL) {
//					Left = *pLeft
//     go through *pLeft and fill in empty parts
//				}
	r = rows(titl_note)
	if (fonts!="") ParseFMTex(fonts,opt,begm="",endm="",1,r,1,1)
	else if (!plain) {
		if (opt=="titlfont") {
			begm="\begin{large}"; endm="\end{large}"
			if (r>1){
				begm=(begm\J(r-1,1,"")); endm=(endm\J(r-1,1,""))
			}
		}
		else {  // for T.Note
			begm=J(r,1,"\begin{footnotesize}")
			endm=J(r,1,"\end{footnotesize}") 
		}
	}
	else {
		begm=J(r,1,""); endm=begm
	}
	titl_note = titl_note + (strtrim(titl_note):==""):*"\hfil"  // make blank lines appear
	lastspace = spaces[r,2]							// separate last aft space
	offset = ""
	if (r>1) offset = offset\spaces[1..r-1,2]
	spaces = spaces[,1]+offset	// offset bef & aft spaces
	titl_note = spaces+begm+titl_note+endm:+"\\"
	for (i=1;i<=r;i++) fput(fh,titl_note[i])
	if (lastspace!="") fput(fh,lastspace)
}

string scalar TabularCols(string scalar vlines,
									string scalar coljust,
									struct FrmtTabl scalar T)
{ // convert vlines and coljust into column code for Tex {tabular} command
	if (vlines=="") vlines = "0"
	if (coljust=="") coljust = "l;c"
	sects = T.SectCols
	sects[cols(sects)] = sects[cols(sects)]+1 // vline after last column
	vlines = ParseLines(vlines,"vlines",sects,"01")
	vlines = subinstr(subinstr(vlines,"0",""),"1","|")  // convert 1's to "|"
	coljust = ParseLines(coljust,"coljust",T.SectCols,"lcr.")
	tabcol = vlines[1]
	for (i=2;i<=cols(vlines);i++) tabcol = tabcol+coljust[i-1]+vlines[i]
	return(tabcol)
}


string colvector ParseHLines(string matrix hlines,
										struct FrmtTabl scalar T)
{	// convert hlines to hlcol column vector
	if (hlines=="") hlines = "1{0};1{0}1"
	sects = T.SectRows
	sects[cols(sects)] = sects[cols(sects)]+1 // hline after last row
	hlines = ParseLines(hlines,"hlines",sects,"01")
	return((subinstr(subinstr(hlines,"0",""),"1","\hline ")[1..cols(hlines)-1])')
}


string matrix ParseFTex(string scalar font,
								string scalar opt,
								real scalar none)
{ // check contents of font and change font "none" to ""
	retfont = ("fs11", "fs12", "a4paper") // characteristics returned in "font"
	if (none) retfont = (retfont, "none")
	allowed = (retfont, "Huge", "huge", "LARGE", "Large", "large",		///
		"normalsize", 	"small", "footnotesize", "scriptsize", "tiny", 	///
		"rm", "it", "em", "bf", "sl", "sf", "sc", "tt", "underline")
	fontvec = tokens(font)
	font = ""; fsel = J(1,cols(fontvec),1)
	for (i=1;i<=cols(fontvec);i++) {  // check elements of font
		if (!anyof(allowed,fontvec[i])) {
			errprintf(`"font "%s" not allowed in %s option\n"',fontvec[i],opt)
			exit(198)		
		}
		if (anyof(retfont,fontvec[i])) {
			fsel[i] = 0
			if (substr(fontvec[i],1,2)=="fs") {	// return font size value in font
				if (font=="a4paper") font = font+","+substr(fontvec[i],3,.)+"pt"
				else font = substr(fontvec[i],3,.)+"pt" 
			}
			else if (fontvec[i]=="a4paper") {	// return a4paper size in font
				if (substr(font,-2,.)=="pt") font = font+","+fontvec[i]
				else font = fontvec[i]	
			}
		}
	}
	fontvec = select(fontvec,fsel)
	return(fontvec)
}


void ParseFMTex(string scalar font,
				string scalar opt,
				string matrix begm,
				string matrix endm,
				real scalar colvec,
				real scalar fr,
				real scalar fc,
				real scalar ns)
{ // parse font options into a string matrix: titlfont, notefont, & statfont
	if (colvec) fontm = StrToCVec(font,opt)
	else fontm = StrToMat(font,opt)
	r = rows(fontm); c = cols(fontm)
	begm = J(r,c,""); endm = J(r,c,"")
	for (i=1;i<=r;i++) {
		for (j=1;j<=c;j++) {
			fontcell = ParseFTex(fontm[i,j], opt, 1)
			begf = ""; endf = ""
			for (k=1;k<=cols(fontcell);k++) {
				if (fontcell[k]!="") {
					if (fontcell[k]=="underline") {
						begf = begf + "\underline{"
						endf = "}" + endf
					}
					else {
						begf = begf + "\begin{" + fontcell[k] + "}"
						endf = "\end{" + fontcell[k] + "}" + endf
					}
				}
			}
			begm[i,j] = begf; endm[i,j] = endf
		}
	}
	ExpandFmt(begm,fr,fc,ns); ExpandFmt(endm,fr,fc,ns)
}

void StatFTex(struct FrmtTabl scalar T,
					real scalar plain,
					string scalar statfont,
					string matrix begm,
					string matrix endm)
{  // fill in font codes for statistics (not ctitles or rtitles)
	r = rows(T.Body)-T.SectRows[1] // subtract off header rows
	c = cols(T.Body)-T.SectCols[1] // subtract off left columns
	if (statfont!="") {
		FontSect(statfont,T,sr=.,ns=.)
		begm=J(0,c,""); endm=begm
		for (i=1;i<=cols(statfont);i++) {
			ParseFMTex(statfont[i],"statfont",bm="",em="",0,sr[i],c,ns[i])
			begm = (begm\bm); endm = (endm\em)
		}
	}
	else if (!plain & T.SectSubstats[2]) {
		rs = cols(T.SectRows)	// rs = row sections
		if (rs>=3) er = sum(T.SectRows[2..3])  // er = estimate rows
		else if (T.ConsSect) er = r  		// no addrow
		else er = T.SectRows[2]				// no ConsSect
		xr = r - er
		ParseFMTex("none\footnotesize","statfont",	///
			begm,endm,0,er,c,T.SectSubstats[2]+1)
		begm = (begm\J(xr,c,"")); endm = (endm\J(xr,c,""))
	}
	else {
		begm=J(r,c,""); endm=begm
	}
}

end  // end mata:
