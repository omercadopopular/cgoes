*! Write formatted regression output to a text file
*! version 4.32  18sep2015 by John Luke Gallup (jlgallup@pdx.edu)

* version 4.32: - bugfix in frmttable.ado version 1.32
* version 4.31: - bugfix in frmttable.ado version 1.31
* version 4.30: - bugfix in frmttable.ado version 1.30
* version 4.29: - bugfix in frmttable.ado version 1.29
* version 4.28: - bugfix in frmttable.ado version 1.28
* version 4.27: - bugfix in frmttable.ado version 1.27
* version 4.26: - bugfix in frmttable.ado version 1.26
* version 4.25: - retain order for -keep- w/ -eq_merge- in outreg
*						bugfix in frmttable.ado version 1.25
* version 4.24: - noBLankrows in frmttable vs. BLankrows in outreg
* version 4.23: - fixed bug in MakeStat for b_nocons
* version 4.22: - bugfix in frmttable.ado version 1.22
* version 4.21: - fixed bug so that marginal effects r(b) not overwritten
*							by _ms_omit_info
* version 4.20: - fixed bug so that omitted coefficients and factor variables
*							not used for Stata versions <11
* version 4.19: - bugfix in frmttable.ado version 1.19
* version 4.18: - remove equation names from e(b) when only one
*					 - remove omitted coefficients from estimates
*					 - fix -keep- and -drop- for multi-equation estimates
* version 4.17: - add support for factor variables
* version 4.16: - revised help file for -frmttable-
* version 4.15: - fixed bug w/-addrtc- when -clear-
* version 4.14: - fixed bug w/-addrows- when -nosubstat-
* version 4.13: - recompiled l_cfrmt.mlib in Stata 10 for compatibility
* version 4.12: - make table w/o -statmat- or -replay- in frmttable.ado
* version 4.11: - allow -merge- and -append- with -replay-
* version 4.10: - bugfix in frmttable.ado version 1.10
* version 4.09: - bugfix in frmttable.ado version 1.09
* version 4.08: - bugfix in frmttable.ado version 1.08
* version 4.07: - added help documentation for -landscape- and -a4-
* version 4.06: - bugfix in frmttable.ado version 1.06
* version 4.05: - bugfix in frmttable.ado version 1.05
* version 4.04: - fixed -note()- option w/ -replay-
*					 - added landscape and a4 option in frmttable.ado, version 1.04
* version 4.03: - changes in frmttable.ado, version 1.03
* version 4.02: - changes in frmttable.ado, version 1.02
*					 - put _cons terms in -keep()- below other coefficients, 
*							unless using -nofindcons- option
* version 4.01: -	made compatible with Stata 11 margins command
*					 -	added -replay-, -clear-, -store-, -merge(tblname)-, and 
*							-append(tblname)- options for loops and complex tables
*					 - fixed bug that caused blank varnames w/varlabels option when
*							labels missing
*					 - allow merging of tables when left columns are different width
*					 - fixed bug that the e_ci wasn't a double statistic
*

program outreg
   version 10.1
   syntax [using], [Stats(string)		/// statistics in table
   			se									/// standard errors, not t stats
				MArginal							/// marginal effects, not coefficients
				or									/// odds ratios, i.e. exp(b) not b
   			IRr								/// incidence-rate ratio (=or)
   			hr									/// hazard rate (=or)
   			rrr								/// relative risk ratio (=or)
   			BDec(numlist >=0 <=15)		/// decimal places for coefficients
   			BFmt(string) 					/// numerical format for coefficients
   			TDec(numlist >=0 <=15 max=1) /// decimal places for t statistics
   			SDec(string)					/// decimal places for all statistics
   			SFmt(string) 					/// numerical format for all statistics
   			Note(string asis)				/// put note below the table
   			SUMMStat(string)				/// summary statistics below coefficients
   			SUMMDec(numlist >=0 <=15)	/// decimal places for summary statistics
   			SUMMTitles(string asis)		/// row titles for summary statistics
   			noAUtosumm						/// no automatic summary stats (R^2, N)
   			noCONS							/// don't report constant term (_cons)
				KEep(string)					/// include coefficients for these vars
				DRop(string)					/// exclude coefficient for these vars
   			Eq_merge							/// merge multi-equation coefficients
   			noSUBstat						/// don't put t-stats below coefficients
   			Level(cilevel)					/// significance level (for conf.int.s)
   			STARLEVels(numlist >0 <100 descending)	/// sig. levels for stars
   			STARLOC(int 2)	 				/// put stars on which substat (def=2)
   			MARGStars						/// calc sig. stars from marginal effects
   			noSTARs							/// no significance stars
   			noLEgend							/// no legend showing significance levels
   			SIgsymbols(string asis)		/// symbols for signif.(instead of stars)
   			ANnotate(string)				/// for compatibility with frmttable.ado
   			ASymbol(string asis)			/// for compatibility with frmttable.ado
   			ADDRows(string asis)			/// add rows of data on bottom of tbl
   			ADDRTc(int 0)					/// number of left columns in addrows
   			noFIndcons						/// for compatibility with frmttable.ado
   			BLankrows						/// for compatibility with frmttable.ado
   			MErge								/// merge regression to previous table
   			MErge1(string)					/// merge to table "tblname"
				REplay							/// use table in Mata struct "tblname"
				REplay1(string)				/// write existing table to file
   			CLear								/// clears _FrmtT - for loops w/merge					
   			CLear1(string asis)			/// clears tblname - for loops w/merge					
   			*]									 // pass along frmttable.ado options

// future improvements?
//		- value labels for factor variables
// 	- user menus
//		- use Stata stored estimates				
				
	if (`"`replay'`replay1'`clear'`clear1'"'=="") { // create statmat
		tempname statmat dblmat sdecmat anno_mat
		
		// logistic same as logit, but displays odds ratio
		if "`e(cmd)'"=="logistic" local or "or"
	
		// create statmat matrix and make "_ORstats", "_ORsmat", and "_ORt_abs"
		//		 available to other Mata functions
		mata: _ORstats = CalcStats("`stats'",("`se'"!=""),("`marginal'"!=""), ///
								"`or'`irr'`hr'`rrr'",("`substat'"==""),				///
								("`cons'"!=""),"`statmat'","`dblmat'",`level',		///
								("`margstars'"!=""),"`keep'","`drop'",					///
								("`eq_merge'"!=""),("`findcons'"!=""),					///
								_ORsmat=J(0,0,.),_ORt_abs=.)
		local numst = r(numst)									
		local subs "substat(`r(subs)')"
		if (`r(dbls)') local doubles "doubles(`dblmat')"
	
		// convert format options to sdec and sfmt
		mata: FillFmt("`bdec'","`tdec'","`sdec'","`bfmt'",`"`sfmt'"',_ORstats,	/// "
			"`statmat'",rows(_ORsmat),`r(subs)')
		if ("`sdec'"!="") local sdec = "sdec(`sdec')"
		if ("`sfmt'"!="") local sfmt = "sfmt(`sfmt')"
	
		// create stars for significance levels
		if ("`stars'"=="" & !(`numst'==1 & `starloc'==2)) {  // i.e. not "nostar" & not only one statistic
			mata: MakeStars(_ORstats,`starloc',"`starlevels'",`"`sigsymbols'"', ///
						"`legend'","`annotate'",`"`asymbol'"',`"`note'"', 		/// "
						_ORt_abs,_ORsmat,`numst')
			mat `anno_mat' = r(annotate)
			local annotate "`anno_mat'"
			local asymbol `"`r(asymbol)'"'
			if ("`legend'"=="") { // i.e. not NOLegend
				if (`"`note'"'!="") local note `"`r(legend)'\ `note'"'
				else if ("`merge'`merge1'"=="") local note `"`r(legend)'"'
			}
		}
	
		// create summary statistics and add to addrows()
		if ("`autosumm'"=="" & ("`summstat'"!=""|("`eq_merge'"==""&"`substat'"==""))) { 
			// i.e. not noautosumm & (summstat!="" or (not eq_merge and not nosubstat))
			// no summ stats if multi-column multi-equation model or substats in separate columns
			mata: SummStat("`summstat'", "`summdec'", `"`summtitles'"', /// 
				`"`addrows'"', `addrtc')	
			local addrows `"`r(addrows)'"'  //"
			local addrtc = `r(addrtc)'
		}
		
		if ("`findcons'"!="") local findcons  // reverse noFIndcons option
		else local findcons "findcons"
		if ("`blankrows'"!="") local blankrows  // reverse noBLankrows option
		else local blankrows "noblankrows"
		mata: mata drop _ORstats _ORsmat _ORt_abs // clean out mata matrices
		local statmat = "statmat(`statmat')"
	}
	else {
		if (`"`clear'`clear1'"'!="") {
			local addrtc
			if (`"`clear1'"'!="") local clear1 `"clear(`clear1')"'
		}
		if (`"`replay1'"'!="") local replay1 `"replay(`replay1')"'
	}
	if (`"`merge1'"'!="") local merge1 `"merge1(`merge1')"'
	if (`"`addrows'"'!="") local addrows `"addrows(`addrows')"'
	if ("`addrtc'"!="") local addrtc = "addrtc(`addrtc')"
	if ("`annotate'"!="") local annotate "annotate(`annotate')" 
	if (`"`asymbol'"'!="") local asymbol `"asymbol(`asymbol')"'
	if (`"`note'"'!="") local note `"note(`note')"'

	frmttable `using', `statmat' `subs' `sdec' `sfmt' `doubles' `annotate' 	///
		`asymbol' `addrows' `addrtc' `note' `findcons' 	`blankrows'	///
		`eq_merge' `merge' `merge1' `replay1' `clear' `clear1' `options'
end  // outreg


version 10.1
capture version 11 // so callersversion() returns 11+ if true
mata:

string matrix CalcStats(string scalar stats,
								real scalar se,
								real scalar marg,
								string scalar eform,
								real scalar substat,
								real scalar nocons,
								string scalar statmat,
								string scalar dblmat,
								real scalar level,
								real scalar margstars,
								string scalar keep,
								string scalar drop,
								real scalar eq_merge,
								real scalar no_fcons,  // no find cons
								real matrix smat,
								real matrix t_abs)
{  // calculate statistics listed in stats for outreg table.
	//    put in Stata statmat matrix and Mata smat matrix
	//		return stats as string matrix.

	// input default statistics
	if (stats=="") {
		if (eform=="") {
			se_stats = ("mean","proportion","ratio","total")
			cmd = st_global("e(cmd)")
			if (anyof(se_stats,cmd)) se = 1
			if ((cmd!="dprobit")&!marg) {
				if (se) stats = "b se"
				else stats = "b t_abs"
			}
			else {
				if (se) stats = "b_dfdx se_dfdx"
				else stats = "b_dfdx t_abs_dfdx"
			}
		}
		else {
			if (se) stats = "e_b e_se"
			else stats = "e_b t_abs"		
		}
	}
	else if (marg | se | (eform!="") ) {
		errprintf("options {bf:stats()} and {bf:%s} may not be combined\n",	///
			strtrim(marg*"marginal"+" "+se*"se"+" "+eform))
		exit(198)
	}
	// create mata statistics matrix smat
	bnames = st_matrixcolstripe("e(b)")
	if (marg) margstars = 1
	smat = MakeSmat(stats,dblmat,dbls=.,nocons,bnames,keep,drop,eq_merge,
		no_fcons,t_abs,level,margstars)  
	blanks = (rownonmissing(smat):==0)		// eliminate blank rows
	if (sum(blanks)) {
		smat = select(smat,!blanks); bnames = select(bnames,!blanks)
	}
	st_matrix(statmat,smat)  // put smat in Stata space as "statmat"
	st_matrixrowstripe(statmat,bnames) // add row names to statmat
	if (allof(bnames[,1],"") & substat) {  // if single equation (no eqn names)
		cstr = J(cols(smat),2,"")
		cstr[,2] = J(cols(smat),1,st_global("e(depvar)")) // put depvar in colstripe
		if (!allof(cstr[,2],"")) st_matrixcolstripe(statmat,cstr) // e(depvar) may be missing
	}
	numst = cols(stats)	
	st_numscalar("r(numst)",numst)
	st_numscalar("r(subs)",substat*(numst-1))
	st_numscalar("r(dbls)",dbls) // stats has double-column statistics
	return(stats)  // return stats as string matrix
}

real matrix MakeSmat(string matrix stats,
							string scalar dblmat,
							real scalar dbls,
							real scalar nocons,
							string matrix bnames,
							string scalar keep,
							string scalar drop,
							real scalar eq_merge,
							real scalar no_fcons,  // no find cons
							real matrix t_abs,
							real scalar level,
							real scalar margstars)
{  // calculate statistics in smat							
	b = st_matrix("e(b)")'
	if (cols(b)==0) {
		errprintf("last estimates e(b) not found\n"); exit(301)
	}
	V = st_matrix("e(V)")
	if (cols(V)==0) {
		errprintf("last estimates e(V) not found\n"); exit(301)
	}
	
	df = st_numscalar("e(df_r)")
	if (strpos(stats,"ci")) {  // stats is still a string
		if (level==.) level = strtoreal(st_global("c(level)"))
		sig = (1-level/100)/2
		t_a = (cols(df) ? invttail(df, sig) : -invnormal(sig))
	}		// need t_a for ci* stats
	stats = VetStats(stats,dblmat,dbls,nocons_st=0,nocons,
		m_stats="",nonmarg=0,marg=0,margsuff="")  // stats becomes string matrix

	// handle marg first to get r(b) values before wiped out by _ms_omit_info
	if (marg) {		// marg=some statistics are marginal estimates
		if (st_global("r(cmd)")=="margins") {
			e_dfdx = "r(b)"
			se_dfdx = sqrt(diagonal(st_matrix("r(V)")))
		}
		else {
			if (st_global("e(cmd)")=="dprobit") {  // dprobit uses different names
				e_dfdx = "e(dfdx)"
				se_dfdx = st_matrix("e(se_dfdx)")'
			}
			else {
				suff = st_global("e(Xmfx_type)")
				e_dfdx = "e(Xmfx_"+suff+")"
				se_dfdx = st_matrix("e(Xmfx_se_"+suff+")")'
			}
		}
		b_dfdx = st_matrix(e_dfdx)'
		if (cols(b_dfdx)==0) {
			errprintf("marginal estimates not found; see -help margins-\n")
			exit(301)
		}
		mnames = st_matrixcolstripe(e_dfdx)
		if (keep!="") { 
			klist = KeepDrop(keep,"",mnames,eq_merge,no_fcons)
			b_dfdx  = b_dfdx[klist,.]
			se_dfdx = se_dfdx[klist,.]
			if (!nonmarg) mnames  = mnames[klist,.] // remove mnames rows if not using bnames
		}
		else if (drop!="") { 
			dropvec = KeepDrop("",drop,mnames,eq_merge,no_fcons)
			b_dfdx  = select(b_dfdx,dropvec)
			se_dfdx = select(se_dfdx,dropvec)
			if (!nonmarg) mnames  = select(mnames,dropvec) // remove mnames rows if not using bnames
		}
		if (min(strmatch(mnames[,1],mnames[1,1])))	/// remove eq name if unique
			mnames[,1]=J(rows(mnames),1,"")	//  (single equation estimation)		
		t_abs_dfdx = abs(b_dfdx:/se_dfdx) 
	}

	// eliminate "omitted" variables due to collinearity
	if (callersversion()>=11) {  // version 11+
		stata("_ms_omit_info e(b)")
		omit = st_matrix("r(omit)")'
		if (st_numscalar("r(k_omit)")>0) {
			b = select(b,!omit)
			bnames = select(bnames,!omit)
			V = select(select(V,!omit),!omit')
		}
	}
	if (nocons_st) {  // n.b. if b contains _cons, b_nocons has a "." in that row
		b_nocons = b
		for (i=1;i<=rows(b);i++) if (bnames[i,2]=="_cons") b_nocons[i] = .
	}
	if (nonmarg) {  // nonmarg=some statistics are not marginal estimates
		se = sqrt(diagonal(V))
		if (keep!="") {  
			klist = KeepDrop(keep,"",bnames,eq_merge,no_fcons)
			b = b[klist,.]; b_nocons = b
			se = se[klist,.]
			bnames = bnames[klist,.]
		}
		else { // nocons or drop
			dropvec = 0
			if (nocons) dropvec = (bnames[.,2]:!="_cons")
			if (drop!="") {  
				if (nocons) dropvec = dropvec:&KeepDrop("",drop,bnames,eq_merge,
					no_fcons)
				else dropvec = KeepDrop("",drop,bnames,eq_merge,no_fcons)
			}
			if (sum(dropvec)) {
				b = select(b,dropvec); b_nocons = b
				se = select(se,dropvec)
				bnames = select(bnames,dropvec)
			}
		}
		if (min(strmatch(bnames[,1],bnames[1,1])))	/// remove eq name if unique
			bnames[,1]=J(rows(bnames),1,"")	//  (single equation estimation)
		t_abs = abs(b:/se)
	}
	
	// calculate stats not calculated yet
	for (i=1;i<=cols(stats);i++) {
		s = stats[i]
		if (s=="b") 				  st = b
		else if (s=="se")			  st = se
		else if (s=="t")			  st = b:/se
		else if (s=="t_abs")		  st = t_abs
		else if (s=="p") 					/// two-sided p statistic
			st = (cols(df) ? 2*ttail(df,t_abs) : 2*normal(-t_abs))
		else if (s=="ci")    	  st = (b,b) + t_a*(-se,se)
		else if (s=="ci_l")  	  st = b - t_a*se
		else if (s=="ci_u")  	  st = b + t_a*se
		else if (s=="e_b")   	  st = exp(b_nocons)
		else if (s=="e_se")  	  st = exp(b_nocons):*se
		else if (s=="e_ci")  	  st = exp((b_nocons,b_nocons) + t_a*(-se,se))
		else if (s=="e_ci_l")	  st = exp(b_nocons - t_a*se)
		else if (s=="e_ci_u")	  st = exp(b_nocons + t_a*se)
		else if (s=="beta")  	  st = MakeBeta(b,bnames)
		else {  // marginal statistics
			if (s=="b_dfdx") 		  	  st = b_dfdx
			else if (s=="se_dfdx")	  st = se_dfdx
			else if (s=="t_dfdx")	  st = b_dfdx:/se_dfdx
			else if (s=="t_abs_dfdx") st = t_abs_dfdx
			else if (s=="p_dfdx") 	///
						st = (cols(df) ? 2*ttail(df,t_abs_dfdx) : 2*normal(-t_abs_dfdx))
			else if (s=="ci_l_dfdx")  st = b_dfdx - t_a*se_dfdx
			else if (s=="ci_u_dfdx")  st = b_dfdx + t_a*se_dfdx
			else if (s=="ci_dfdx") 	  st = (b_dfdx,b_dfdx) + t_a*(-se_dfdx,se_dfdx)
			/// match up variable names with bnames
			if (nonmarg) st = MatchMarg(st,bnames,mnames) 
		}
		smat = _CColJoin(smat,st) // beta has fewer rows
	}
	if (!nonmarg) {
		bnames = mnames		// use row names from marginal stats
		t_abs = t_abs_dfdx   // make stars from marginal t
	}
	else if (margstars) t_abs = MatchMarg(t_abs_dfdx,bnames,mnames) 
	return(smat)
}

string matrix VetStats(string scalar stats, 
								string scalar dblmat,
								real scalar dbls,
								real scalar nocons_st,
								real scalar nocons,
								string matrix m_stats,
								real scalar nonmarg,
								real scalar marg,
								string scalar margsuff)
{ // make stats a string matrix  & verify stats names are allowed
	stats = tokens(subinstr(stats,","," "))
	noc_stats = ("e_b","e_se","e_ci","e_ci_l","e_ci_u","beta") // stats w/o _cons term
	c_stats = ("b","se","ci","ci_l","ci_u")  // stats w/ _cons term 
	m_stats = ("b_dfdx","se_dfdx","t_dfdx","t_abs_dfdx","p_dfdx","ci_dfdx","ci_l_dfdx",
		"ci_u_dfdx")	// marginal statistics (after mfx command)
	allstats = ("t","t_abs","p",c_stats,noc_stats,m_stats)
	d_stats = ("ci","e_ci","ci_dfdx")  // double column statistics
	dbl = J(1,0,.)
	c_st = 0  //nocons_st=(>=1 stat w/o _cons);c_st=(>=1 stat w/ _cons)
	for (i=1;i<=cols(stats);i++) {
		s = stats[i]
		if (!anyof(allstats,s)) {
			errprintf(`""%s" not allowed in stats option\n"', stats[i])
			exit(198)
		}
		if (anyof(noc_stats,s)) nocons_st = 1
		else if (anyof(c_stats,s)) c_st = 1
		else if (anyof(m_stats,s)) marg++
		if (anyof(d_stats,s)) dbl = dbl,0,1
		else dbl = dbl,0
	}
	if (!c_st) nocons = 1
	nonmarg = (marg<cols(stats))  // some non-marginal statistics
	st_matrix(dblmat,dbl)  // put dblmat in Stata space
	dbls = sum(dbl)
	return(stats)
}

real matrix KeepDrop(string scalar keep,
							string scalar drop,
							string matrix bnames,
							real scalar noreorder,
							real scalar no_fcons)	// no find constant
{  // make indicator of kept rows of bname according to keep and drop
	if (keep!=""&drop!="") {
		errprintf("only one of options keep and drop are allowed\n")
		exit(198)
	}
	
	t = tokeninit(" ",(":", "_cons"))
	tokenset(t,keep+drop)
	vlist = tokengetall(t)
	if (cols(vlist)>1) {
		colon = vlist:==":"
		eqloc = select((colon[2..cols(vlist)],0),!colon)
		vlist = select(vlist,!colon)
	}
	else eqloc = 0
	eqn = ""; eqlast = 0
	kdnames = J(0,2,"")
	for (v=1;v<=cols(vlist);v++) {
		if (eqloc[v]) { // equation name w/ no variable name
			if (eqlast) kdnames = kdnames \ (vlist[v-1],"")
			eqn = vlist[v]
			eqlast = 1
		}
		else { // equation name w/variable name
			if (vlist[v]!="_cons") {
				if (callersversion()>=11) {  // version 11+
					rc = _stata("fvexpand "+vlist[v])  // unabbreviate varname
					if (rc==0) {
						vars = tokens(st_global("r(varlist)"))'	// may be more than one varname
						nt = rows(vars)
					}
					else{
						errprintf(`"in keep() or drop() option\n"')
						exit(rc)
					}
				}
				else {
					stata("tsunab var : "+vlist[v])  // unabbreviate varname
					vars = tokens(st_local("var"))'	// may be more than one varname
					nt = rows(vars)
				}
			}
			else { // i.e. "_cons" 
				vars = vlist[v]; nt = 1
			}
			eqnv = J(nt,1,eqn)
			kdnames = kdnames \ (eqnv,vars); eqlast = 0
		}
	}
	if (eqlast) kdnames = kdnames \ (vlist[v-1],"")  // if last of vlist is eqn

	// match bnames to kdnames 
	br = rows(bnames)
	bsel = J(br,1,0)  // name already selected
	klist = J(0,1,.)  // indicator for keep list order (except _cons)
	kcons = J(0,1,.)	// indicator for keep _cons
	for (k=1;k<=rows(kdnames);k++) {
		kn = kdnames[k,]; foundb = 0
		if (kn[2]!="") { // has varname
			if (kn[1]=="") {
				kn = kn[2]; b2 = 2
			}
			else b2 = .
			for (i=1;i<=br;i++) {
				if (bnames[i,b2]==kn&!bsel[i]) { // match
					bsel[i] = 1
					if (bnames[i,2]!="_cons" | no_fcons) klist = klist\i
					else kcons = kcons\i
					foundb = 1
				}
			}
		}
		else {  // only eqname, no varname
			kn = kn[1]
			for (i=1;i<=br;i++) {
				if (bnames[i,1]==kn) {
					bsel[i] = 1; klist = klist\i; foundb = 1
				}
			}
		}
		if (!foundb) {
			if (kdnames[k,1]=="") kstr = kn
			else kstr = strtrim(kdnames[k,1]+": "+kdnames[k,2])
			if (keep!="") keepdrop = "keep"
			else keepdrop = "drop"
			errprintf(`""%s" in %s() not found in estimates\n"',	///
				kstr,keepdrop)
			exit(198)
		}
	}
	if (keep!="") {
		if (noreorder) klist = select(range(1,rows(bsel),1),bsel) // keep order
		else klist = klist\kcons  // put _cons terms last (unless no_fcons)
		return(klist)  // vector of rows to keep
	}
	else return(!bsel) // if drop, return vector to select nondrop elements
}

real matrix MakeBeta(real matrix b,
							string matrix bnames)
{  // calculate beta statistics after regress
	if (st_global("e(cmd)")!="regress"|st_global("e(clustvar)")!="") {
		errprintf("stats(beta) only allowed after regress command w/o cluster option\n")
		exit(198)
	}
	esampv = st_nvar()+1  // get e(sample) variable index #
	if (st_global("e(wexp)")=="") w = 1
	else st_view(w=.,.,subinstr(st_global("e(wexp)"),"= ",""),esampv)
	vnames = select(bnames[,2]',bnames[,2]':!="_cons")  // get rid of "_cons"
	vc = cols(vnames) 
	v = _st_varindex((st_global("e(depvar)"),vnames))
	if (missing(v)) {
		missv = invtokens(select((st_global("e(depvar)"),vnames),v:==.))
		errprintf("variable %s not found for calculating beta coefficients\n",missv)
		exit(198)
	}
	st_view(y=.,.,v[1],esampv)
	Vyb = variance(y,w)
	vc = cols(v)
	for (bv=2;bv<=vc;bv++) {
		st_view(ab=.,.,v[bv],esampv)
		Vyb = Vyb\variance(ab,w)
	}  // b w/o _cons row times s.d. of b / s.d. of y:
	return(select(b,bnames[.,2]:!="_cons"):*sqrt(Vyb[2..vc]:/Vyb[1]))
}


real matrix MatchMarg(real matrix st,
							string matrix bnames,
							string matrix mnames)
{  // retrieve marginal statistics after mfx
	br = rows(bnames); mr = rows(mnames)
	newst = J(br,cols(st),.); k = 1
	for (i=1;i<=br;i++) {
		if (mnames[k,2]==bnames[i,2]) {
			newst[i,] = st[k,]
			k++; if (k>mr) break // stop if at end of mnames
		}
	}
	return(newst)
}


transmorphic matrix _CColFill(transmorphic matrix A, transmorphic matrix B)
{	// join matrices by column, making them conform by repeating last rows
	rA = rows(A); rB = rows(B)
	if (rA==0) A = A \ J(rB-rA,cols(A),missingof(A))
	else if (rA<rB) {
		last = A[rA,]
		for (i=1;i<=rB-rA;i++) A = A \ last
	}
	else if (rA>rB) {
		last = B[rB,]
		for (i=1;i<=rA-rB;i++) B = B \ last
	}
	return(A,B)
}


transmorphic matrix _CConformB(transmorphic matrix A, transmorphic matrix B)
{	// make matrix A conform to dimensions of matrix B, by repeating last rows
	//		then columns of A if necessary
	rA=rows(A); cA=cols(A); rB=rows(B); cB=cols(B)
	if (rA!=rB | cA!=cB) {
		if (rA==0 | cA==0) A = J(rB,cB,missingof(A))
		else {
			if (rA<rB) {
				last = A[rA,]
				for (i=1;i<=rB-rA;i++) A = A\last
			}
			else if (rA>rB) A = A[1..rB,]
			if (cA<cB) {
				last = A[,cA]
				for (j=1;j<=cB-cA;j++) A = A,last
			}
			else if (cA>cB) A = A[,1..cB]
		}
	}
	return(A)
}


void _CConfMax(transmorphic matrix A, transmorphic matrix B)
{	// make two matrices conform (match the dimensions using
	// the largest of each, adding rows or columns of missing
	rA = rows(A); cA = cols(A); rB = rows(B); cB = cols(B)
	if (rA<rB) A = A \ J(rB-rA,cA,missingof(A))
	else if (rA>rB) B = B \ J(rA-rB,cB,missingof(B))
	if (cA<cB) A = A , J(rows(A),cB-cA,missingof(A))
	else if (cA>cB) B = B , J(rows(B),cA-cB,missingof(B))
}

string matrix ResizeFmt(string scalar bdf,			// bdec or bfmt string
								string scalar tdf,			// tdec or tfmt string
								string scalar statmat,
								real scalar sr,
								real rowvector tstat,
								real scalar subs)
{	// combine bdec & tdec to form sdec (or convert bfmt & tfmt to sfmt)
	bdf = tokens(subinstr(bdf,","," "))' // convert to colvector
	br = rows(bdf)
	
	if (br>1) {
		// calculate length of each equation in statmat			
		eqnames = st_matrixrowstripe(statmat)[,1] // row names from statmat
		if (allof(eqnames,"")) eqlen = sr //1 equation
		else { 	// multi-equation
			eqlen = J(1,0,.); eqr = 1
			for (i=2;i<=sr;i++) {
				if (eqnames[i]!=eqnames[i-1]) {
					eqlen = eqlen,eqr; eqr = 1
				}
				else eqr++
			}
			eqlen = eqlen,eqr
		}
		ec = cols(eqlen)
	
		if (br>sr) bdf = bdf[1..sr]
		else if (br>1 & br<sr) { // fill in bdec pattern to end of smat rows
			if (ec==1) bdf = bdf\J(sr-br,1,bdf[br]) //1 equation
			else { 	// multi-equation
				maxlen = max(eqlen)
				if (br>maxlen) bdf = bdf\J(sr-br,1,bdf[br])
				else {  // if br<=maxlen, repeat for each equation
					eqdec = bdf\J(maxlen-br,1,bdf[br])
					bdf = J(0,1,"")
					for (e=1;e<=ec;e++) bdf = bdf\eqdec[1..eqlen[e]]
				}
			}
		}
	}
	sdfm = J(0,0,"") // sdec or sfmt in matrix form
	for (i=1;i<=cols(tstat);i++) {
		if (tstat[i]) sdfm = _CColFill(sdfm,tdf) // n.b. tdf is scalar
		else sdfm = _CColFill(sdfm,bdf)
	}
	if (subs) sdfm = vec(sdfm')			// convert to colvector
	sdf = ""; sdr = rows(sdfm); sdc = cols(sdfm)
	for (i=1;i<=sdr-1;i++) {		// convert sdfm to a string sdf
		for (j=1;j<=sdc-1;j++) sdf = sdf + sdfm[i,j] + ","
		sdf = sdf + sdfm[i,j] + "\"
	}
	for (j=1;j<=sdc-1;j++) sdf = sdf + sdfm[sdr,j] + ","
	sdf = sdf + sdfm[sdr,sdc]  // no "\" on last row
	return(sdf)	
}

void FillFmt(string scalar bdec,
				string scalar tdec,
				string scalar sdec,
				string scalar bfmt,
				string scalar sfmt,
				string rowvector stats,
				string scalar statmat,
				real scalar sr,
				real scalar subs)
{	// parse bdec and tdec into sdec; parse bfmt into sfmt				
	alltstat = ("t","t_abs","p","t_dfdx","t_abs_dfdx","p_dfdx")
	ns = cols(stats)
	tstat = J(1,ns,0)
	for (i=1;i<=ns;i++) if (anyof(alltstat,stats[i])) tstat[i] = 1

	if (sdec!="") {
		if (bdec!="" | tdec!="") {
			errprintf("Cannot specify option sdec with options bdec or tdec\n")
			exit(198)
		}
	}
	else {
		if (bdec=="") bdec = "3"
		if (tdec=="") tdec = "2"
		sdec = ResizeFmt(bdec,tdec,statmat,sr,tstat,subs)
	}
	st_local("sdec",sdec)  // return sdec

	if (sfmt!="") {
		if (bfmt!= "") { 
			errprintf("Cannot specify option sfmt with option bfmt\n")
			exit(198)
		}
	}
	else if (bfmt!="") sfmt = ResizeFmt(bfmt,"fc",statmat,sr,tstat,subs)
	st_local("sfmt",sfmt)  // put sfmt in Stata space
}


void MakeStars(string rowvector stats,
					real scalar starloc,
					string scalar starlevels,
					string scalar sigsymbols,
					string scalar legend,
					string scalar annotate,
					string scalar asymbol,
					string scalar note,
					real colvector t,
					real matrix smat,
					real scalar numst) 
{ // returns codes for t stat stars (e.g. 0= none, 1 = 5% sig, 2 = 1% sig)
	if (!starloc) starloc=2  	// default: stars on substat 2
	if (starloc>numst) {  // quit if starloc > number of statistics
		printf("{txt}warning: option starloc (=%f) larger than number of ")
		printf("statistics\n",starloc)
	}
	else {
		if (starlevels=="") starlevels = ("5 1")
		starlvls = strtoreal(tokens(subinstr(starlevels,","," ")))/100 // turn into vector

		sc = cols(starlvls)
		if (sigsymbols=="") sigsymb = range(1,sc,1)':*"*"	// default is *'s
		else sigsymb = tokens(subinstr(sigsymbols,","," "))  // turn into vector
		sigc = cols(sigsymb)
		sl = min((sc,sigc))  // in case fewer of either
		if (sl<sigc) sigsymb = sigsymb[(1..sl)]

		//	create star legend (e.g. "* p<0.05; ** p<0.01")
		if (legend == "") { // i.e. not "NOlegend"
			fmt = "%8"+(st_strscalar("c(dp)")=="comma" ? "," : ".")+"4g" // account for -set dp-
			for (s=1;s<sl;s++) legend = legend+sigsymb[s]+" p<0"	///
				+strofreal(starlvls[s],fmt)+"; "
			legend = char((96,34))+legend+sigsymb[sl]+" p<0"+	// no semi-colon on last p
				strofreal(starlvls[sl],fmt)+char((34,39)) 		// char() is for `" and "'
		}
		else legend = ""
		df = st_numscalar("e(df_r)")
		sr = rows(smat)

		stcol = J(sr,1,0)
		if (sr<rows(t)) t = t[(1..sr)]
		t = editmissing(t,0)
		for (s=1;s<=sl;s++) {
			// if e(df_r) defined, use inverse t stat, otherwise inverse normal
			t_a = (cols(df) ? invttail(df,starlvls[s]/2) : -invnormal(starlvls[s]/2))
			stcol = stcol + (t:>t_a)
		}
		if (starloc>1) annote = J(sr,starloc-1,0)
		else annote = J(sr,0,.)
		annote = annote,stcol
		if (starloc<numst) annote = annote,J(sr,numst-starloc,0)

		if (annotate!="") {  // combine annotate matrix with annote
			// add asymbol to sigsymbols
			sigsymb = sigsymb,tokens(subinstr(asymbol,","," "))

			annote = editvalue(annote,0,.) // convert 0 to missing
			ann2 = editvalue(st_matrix(annotate),0,.)
			if (ann2!=trunc(ann2) | min(ann2)<0) {
				errprintf("the matrix in annotate() can only contain non-negative integers")
				exit(198)
			}
			ann2 = ann2 :+ max(annote)  // increment ann2 values
			_CConfMax(annote,ann2) // match dimensions using max of each
			cross = annote + ann2  // find cells with codes in both matrices
			if (nonmissing(cross)) {  // recode double code cells + add to sigsymb
				maxc = max(ann2) + 1
				for (i=1;i<=rows(cross);i++) {
					for (j=1;j<=cols(cross);j++) {
						if (nonmissing(cross[i,j])) {
							sigsymb = sigsymb,(sigsymb[annote[i,j]] + sigsymb[ann2[i,j]])
							annote[i,j] = maxc++
						}
					}
				}
			}
			_editmissing(annote,0) 	// missing values -> 0
			_editmissing(ann2,0)
			annote = annote + ann2:*(cross:==.) // last term so no duplicates
		}
		asymbol = `"""' + sigsymb[1] + `"""'
		for (s=2;s<=cols(sigsymb);s++) asymbol = asymbol + " " + `"""' + sigsymb[s] + `"""'

		st_matrix("r(annotate)", annote)
		st_global("r(asymbol)", asymbol)
		st_global("r(legend)", legend)
	}
}


void SummStat(string scalar summstat,
				string scalar summdec,
				string scalar summtitles,
				string scalar addrows,		
				real scalar addrtc) 		
{ // returns string with summary statistics prepended to addrows
	if (summstat=="") 	///
		summstat = (cols(st_numscalar("e(r2)")) ? "r2\N" : "N")
	st = StrToMat(summstat,"summstat")
	cs = cols(st)
	// default # of decimals is 2 unless 0 for "N*" or "df*"
	if (summdec!="") dec = _CConformB(tokens(subinstr(summdec,","," "))',st)
	else dec = strofreal(2*!(substr(st,1,1):=="N" :| substr(st,1,2):=="df"))
	if (summtitles!="") title = StrToMat(summtitles,"summtitles")
	else title = strproper(st[,1])
		if (addrtc>cols(title)) title = title,J(rows(title),cols(title)-addrtc,"")
	else if (addrtc<cols(title) & addrtc>0) {
		errprintf("addrtc option (=%f) less than columns of summtitles\n",addrtc)
		exit(198)
	}
	else addrtc = cols(title)
	sr = rows(st); sc = cols(st); s = J(sr,sc,.)
	for (i=1;i<=sr;i++) {
		for (j=1;j<=sc;j++) {
			an_s = st_numscalar("e("+st[i,j]+")")
			if (cols(an_s)==0) s[i,j] = .  // in case e() value doesn't exist
			else s[i,j] = an_s
		}
	}

	dp = (st_strscalar("c(dp)")=="comma" ? "," : ".") // account for -set dp-
	summmat = strofreal(s,"%16"+dp:+dec:+"fc")
	summmat = _CColJoin(title,summmat)

	summrows = char((96,34)):+summmat[,1]:+char((34,39))  // char() is for `" & "'
	for (j=2;j<=cols(summmat);j++) 	///
		summrows = summrows:+char((44,96,34)):+summmat[,j]:+char((34,39))
	summstr = summrows[1,]
	for (i=2;i<=rows(summmat);i++) summstr = summstr+" \ "+summrows[i,]

	// combine with existing addrows
	if (addrows!="") summstr = summstr + "\" + addrows
	st_global("r(addrows)", summstr)
	st_numscalar("r(addrtc)", addrtc)
}

end
