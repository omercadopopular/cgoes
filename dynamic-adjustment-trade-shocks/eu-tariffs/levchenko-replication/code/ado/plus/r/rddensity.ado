********************************************************************************
* RDDENSITY STATA PACKAGE -- rddensity
* Authors: Matias D. Cattaneo, Michael Jansson, Xinwei Ma
********************************************************************************
*!version 2.3 2021-02-28

capture program drop rddensityEST

program define rddensityEST, eclass
syntax varlist(max=1) [if] [in] [, 	///
c(real 0) 							///
p(integer 2) 						///
q(integer 0) 						///
fitselect(string) 					///
kernel(string) 						///
h(string) 							///
bwselect(string) 					///
vce(string) 						///
all									///
noMASSpoints						///
noREGularize 			    		///
NLOCalmin (integer -1)				///
NUNIquemin (integer -1)				///
]

	marksample touse

	if (`q'==0) local q = `p' + 1
	if ("`fitselect'"=="") local fitselect = "unrestricted"
	local fitselect = lower("`fitselect'")
	if ("`kernel'"=="") local kernel = "triangular"
	local kernel = lower("`kernel'")
	if ("`bwselect'"=="") local bwselect = "comb"
	local bwselect = lower("`bwselect'")
	if ("`vce'"=="") local vce = "jackknife"
	local vce = lower("`vce'")
	
	tokenize `h'	
	local w : word count `h'
	if `w' == 0 {
		local hl 0
		local hr 0
	}
	if `w' == 1 {
		local hl `"`1'"'
		local hr `"`1'"'
	}
	if `w' == 2 {
		local hl `"`1'"'
		local hr `"`2'"'
	}
	if `w' >= 3 {
		di as error  "{err}{cmd:h()} only accepts two inputs."  
		exit 125
	}

	preserve
	qui keep if `touse'

	local x "`varlist'"

	qui drop if `x'==.
	
	qui su `x'
	local x_min = r(min)
	local x_max = r(max)
	local N = r(N)

	qui count if `x'<`c'
	local Nl = r(N)
	qui count if `x'>=`c'
	local Nr = r(N)

	****************************************************************************
	*** BEGIN ERROR HANDLING *************************************************** 
	if (`c'<=`x_min' | `c'>=`x_max'){
		di "{err}{cmd:c()} should be set within the range of `x'."  
		exit 125
	}
	
	if (`Nl'<10 | `Nr'<10){
		di "{err}Not enough observations to perform calculations."  
		exit 2001
	}
	
	if (`p'!=1 & `p'!=2 & `p'!=3 & `p'!=4 & `p'!=5 & `p'!=6 & `p'!=7){
		di "{err}{cmd:p()} should be an integer value less or equal than 7."  
		exit 125
	}
	
	if (`p'>`q'){
		di "{err}{cmd:p()} should be an integer value no larger than {cmd:q()}."  
		exit 125
	}

	if ("`kernel'"!="uniform" & "`kernel'"!="triangular" & "`kernel'"!="epanechnikov"){
		di "{err}{cmd:kernel()} incorrectly specified."  
		exit 7
	}

	if ("`fitselect'"!="restricted" & "`fitselect'"!="unrestricted"){
		di "{err}{cmd:fitselect()} incorrectly specified."  
		exit 7
	}

	if (`hl'<0){
		di "{err}{cmd:hl()} must be a positive real number."  
		exit 411
	}

	if (`hr'<0){
		di "{err}{cmd:hr()} must be a positive real number."  
		exit 411
	}

	if ("`fitselect'"=="restricted" & `hl'!=`hr'){
		di "{err}{{cmd:hl()} and {cmd:hr()} must be equal in the restricted model."  
		exit 7
	}

	if ("`bwselect'"!="each" & "`bwselect'"!="diff" & "`bwselect'"!="sum" & "`bwselect'"!="comb"){
		di "{err}{cmd:bwselect()} incorrectly specified."  
		exit 7
	}

	if ("`fitselect'"=="restricted" & "`bwselect'"=="each"){
		di "{err}{cmd:bwselect(each)} is not available in the restricted model."  
		exit 7
	}

	if ("`vce'"!="jackknife" & "`vce'"!="plugin"){ 
		di "{err}{cmd:vce()} incorrectly specified."  
		exit 7
	}
	
	if ("`regularize'" == "") {
		local regularize = 1
		local Tempregularize = "regularize"
	}
	else {
		local regularize = 0
		local Tempregularize = "noregularize"
	}

	if ("`masspoints'" == "") {
		local masspoints = 1
		local Tempmasspoints = "masspoints"
	}
	else {
		local masspoints = 0
		local Tempmasspoints = "nomasspoints"
	}

	if (`nlocalmin' < 0) {
		local nlocalmin = 20 + `p' + 1
	}

	if (`nuniquemin' < 0) {
		local nuniquemin = 20 + `p' + 1
	}
	*** END ERROR HANDLING ***************************************************** 
	****************************************************************************

	****************************************************************************
	*** BEGIN BANDWIDTH SELECTION ********************************************** 
	if ("`h'"!="") {
        local bwmethod = "manual"
	}
		
	if (`hl'==0 | `hr'==0) {
	    local bwmethod = "`bwselect'"
		disp in ye "Computing data-driven bandwidth selectors."
		qui rdbwdensity `x', c(`c') p(`p') kernel(`kernel') fitselect(`fitselect') vce(`vce') ///
			nlocalmin(`nlocalmin') nuniquemin(`nuniquemin') `Tempregularize' `Tempmasspoints'
		mat out = e(h)
		if ("`fitselect'"=="unrestricted" & "`bwselect'"=="each" & `hl'==0) local hl = out[1,1]
		if ("`fitselect'"=="unrestricted" & "`bwselect'"=="each" & `hr'==0) local hr = out[2,1]
		if ("`fitselect'"=="unrestricted" & "`bwselect'"=="diff" & `hl'==0) local hl = out[3,1]
		if ("`fitselect'"=="unrestricted" & "`bwselect'"=="diff" & `hr'==0) local hr = out[3,1]
		if ("`fitselect'"=="unrestricted" & "`bwselect'"=="sum"  & `hl'==0) local hl = out[4,1]
		if ("`fitselect'"=="unrestricted" & "`bwselect'"=="sum"  & `hr'==0) local hr = out[4,1]
		if ("`fitselect'"=="unrestricted" & "`bwselect'"=="comb" & `hl'==0) local hl = out[1,1]+out[3,1]+out[4,1] - min(out[1,1],out[3,1],out[4,1]) - max(out[1,1],out[3,1],out[4,1])
		if ("`fitselect'"=="unrestricted" & "`bwselect'"=="comb" & `hr'==0) local hr = out[2,1]+out[3,1]+out[4,1] - min(out[2,1],out[3,1],out[4,1]) - max(out[2,1],out[3,1],out[4,1])

		if ("`fitselect'"=="restricted" & "`bwselect'"=="diff" & `hl'==0) local hl = out[3,1]
		if ("`fitselect'"=="restricted" & "`bwselect'"=="diff" & `hr'==0) local hr = out[3,1]
		if ("`fitselect'"=="restricted" & "`bwselect'"=="sum"  & `hl'==0) local hl = out[4,1]
		if ("`fitselect'"=="restricted" & "`bwselect'"=="sum"  & `hr'==0) local hr = out[4,1]
		if ("`fitselect'"=="restricted" & "`bwselect'"=="comb" & `hl'==0) local hl = min(out[3,1],out[4,1])
		if ("`fitselect'"=="restricted" & "`bwselect'"=="comb" & `hr'==0) local hr = min(out[3,1],out[4,1])
	}
	*** END BANDWIDTH SELECTION ************************************************ 
	****************************************************************************
	qui replace `x' = `x'-`c'
	
	qui count if `x'<0 & `x'>= -`hl'
	if (`r(N)'<5){
	 display("{err}Not enough observations on the left to perform calculations.")
	 exit(1)
	}
	local Nlh = r(N)

	qui count if `x'>=0 & `x'<=`hr'
	if (`r(N)'<5){
	 display("{err}Not enough observations on the right to perform calculations.")
	 exit(1)
	}
	local Nrh = r(N)
	local Nh = `Nlh' + `Nrh'

	qui sort `x'

	****************************************************************************
	*** BEGIN MATA ESTIMATION ************************************************** 
	mata{
	X = st_data(.,("`x'"), 0)
	
	XUnique   	= rddensity_unique(X)
	freqUnique  = XUnique[., 2]
	indexUnique = XUnique[., 4]
	XUnique     = XUnique[., 1]
	NUnique     = length(XUnique)
	NlUnique    = sum(XUnique :<  0)
	NrUnique    = sum(XUnique :>= 0)
	
	Y = (0..(`N'-1))' :/ (`N'-1)
	if (`masspoints') {
		Y = rddensity_rep(Y[indexUnique], freqUnique)
	}
	masspoints_flag = sum(freqUnique :!= 1) > 0 & `masspoints'

	Y = select(Y, X :>= -`hl' :& X :<= `hr')
	X = select(X, X :>= -`hl' :& X :<= `hr')
	fV_q = rddensity_fv(Y, X, `Nl', `Nr', `Nlh', `Nrh', `hl', `hr', `q', 1, "`kernel'", "`fitselect'", "`vce'", `masspoints')
	T_q  = fV_q[3,1] / sqrt(fV_q[3,2])
	st_numscalar("f_ql", fV_q[1,1]); st_numscalar("f_qr", fV_q[2,1])
	st_numscalar("se_ql", sqrt(fV_q[1,2])); st_numscalar("se_qr", sqrt(fV_q[2,2]))
	st_numscalar("se_q", sqrt(fV_q[3,2]))
	st_numscalar("T_q", T_q); st_numscalar("pval_q", 2*normal(-abs(T_q)))

	if ("`all'"!=""){
		fV_p = rddensity_fv(Y, X, `Nl', `Nr', `Nlh', `Nrh', `hl', `hr', `p', 1, "`kernel'", "`fitselect'", "`vce'", `masspoints')
		T_p  = fV_p[3,1] / sqrt(fV_p[3,2])
		st_numscalar("f_pl", fV_p[1,1]); st_numscalar("f_pr", fV_p[2,1])
		st_numscalar("se_pl", sqrt(fV_p[1,2])); st_numscalar("se_pr", sqrt(fV_p[2,2]))
		st_numscalar("se_p", sqrt(fV_p[3,2]))
		st_numscalar("T_p", T_p); st_numscalar("pval_p", 2*normal(-abs(T_p)))
	}
	st_numscalar("masspoints_flag", masspoints_flag)
	*display("Estimation completed.") 
	}
	*** END MATA ESTIMATION **************************************************** 
	****************************************************************************

	****************************************************************************
	*** BEGIN OUTPUT TABLE ***************************************************** 
	
	if (`hl' > `c'-`x_min') {
		disp ""
		disp "Bandwidth {it:hl} greater than the range of the data."
	} 
	if (`hr' > `x_max'-`c') {
		disp ""
		disp "Bandwidth {it:hr} greater than the range of the data."
	}
	if (`Nlh'<20 | `Nrh'<20) disp in red "Bandwidth {it:h} may be too small."
	if (masspoints_flag == 1) {
		disp ""
		disp "Point estimates and standard errors have been adjusted for repeated observations."
		disp "(Use option {it:nomasspoints} to suppress this adjustment.)"
	}
	
	disp ""
	disp "RD Manipulation test using local polynomial density estimation." 

	disp ""
	disp in smcl in gr "{ralign 9: c = }" in ye %9.3f `c'			_col(19) " {c |}" 	_col(22) in gr "Left of c"  		_col(33) in gr "Right of c" 	_col(53) in gr "Number of obs = "  in ye %12.0f `N'
	disp in smcl in gr "{hline 19}{c +}{hline 22}"                                                                                                     					_col(53) in gr "Model         = "  in ye "{ralign 12:`fitselect'}"
	disp in smcl in gr "{ralign 18:Number of obs}"        		_col(19) " {c |} " 	_col(21) as result %9.0f `Nl'      			_col(34) %9.0f  `Nr'                   	_col(53) in gr "BW method     = "  in ye "{ralign 12:`bwmethod'}" 
	disp in smcl in gr "{ralign 18:Eff. Number of obs}"   		_col(19) " {c |} " 	_col(21) as result %9.0f `Nlh'     			_col(34) %9.0f  `Nrh'                  	_col(53) in gr "Kernel        = "  in ye "{ralign 12:`kernel'}"
	disp in smcl in gr "{ralign 18:Order est. (p)}" 			_col(19) " {c |} " 	_col(21) as result %9.0f `p'       			_col(34) %9.0f  `p'                    	_col(53) in gr "VCE method    = "  in ye "{ralign 12:`vce'}"
	disp in smcl in gr "{ralign 18:Order bias (q)}"         	_col(19) " {c |} " 	_col(21) as result %9.0f `q'       			_col(34) %9.0f  `q'                             
	disp in smcl in gr "{ralign 18:BW est. (h)}"				_col(19) " {c |} " 	_col(21) as result %9.3f `hl'      			_col(34) %9.3f  `hr'

	disp ""
	disp "Running variable: `x'."
	disp in smcl in gr "{hline 19}{c TT}{hline 22}"
	disp in smcl in gr "{ralign 18:Method}"                		_col(19) " {c |} " _col(23) "    T"          _col(38) "P>|T|" 
	disp in smcl in gr "{hline 19}{c +}{hline 22}"
	if ("`all'"!="" & `q'>`p'){
		disp in smcl in gr "{ralign 18:Conventional}"      		_col(19) " {c |} " _col(21) in ye %9.4f T_p  _col(34) %9.4f pval_p
	}
	if (`q'>`p') {
		disp in smcl in gr "{ralign 18:Robust}" 			    _col(19) " {c |} " _col(21) in ye %9.4f T_q  _col(34) %9.4f pval_q
	}
	else {
		disp in smcl in gr "{ralign 18:Conventional}" 			_col(19) " {c |} " _col(21) in ye %9.4f T_q  _col(34) %9.4f pval_q
	}
	

	disp in smcl in gr "{hline 19}{c BT}{hline 22}"
	disp ""

	*** END OUTPUT TABLE ******************************************************* 
	****************************************************************************

	restore

	ereturn clear
	ereturn scalar c = `c'
	ereturn scalar p = `p'
	ereturn scalar q = `q'
	ereturn scalar N_l = `Nl'
	ereturn scalar N_r = `Nr'
	ereturn scalar N_h_l = `Nlh'
	ereturn scalar N_h_r = `Nrh'
	ereturn scalar h_l = `hl'
	ereturn scalar h_r = `hr'
	ereturn scalar f_ql = f_ql
	ereturn scalar f_qr = f_qr
	ereturn scalar se_ql = se_ql
	ereturn scalar se_qr = se_qr
	ereturn scalar se_q = se_q
	ereturn scalar pv_q = pval_q
	ereturn scalar T_q = T_q

	if ("`all'"!=""){
		ereturn scalar f_pl = f_pl
		ereturn scalar f_pr = f_pr
		ereturn scalar se_pl = se_pl
		ereturn scalar se_pr = se_pr
		ereturn scalar se_p = se_p
		ereturn scalar pv_p = pval_p
		ereturn scalar T_p = T_p
	}
	
	ereturn local runningvar "`x'"
	ereturn local kernel = "`kernel'"
	ereturn local bwmethod = "`bwmethod'"
	ereturn local vce = "`vce'"

	mata: mata clear
	
end
	
********************************************************************************
* MAIN PROGRAM
********************************************************************************

capture program drop rddensity

program define rddensity, eclass
	syntax 	varlist(max=1) 					///
			[if] [in] [, 					///
			/* Estimation */				///
			C(real 0) 						///
			P(integer 2) 					///
			Q(integer 0) 					///
			FITselect(string) 				///
			KERnel(string) 					///
			VCE(string) 					///
			noMASSpoints					///
			/* Bandwidth selection */		///
			H(string) 						///
			BWselect(string) 				///
			noREGularize 			    	///
			  NLOCalmin (integer -1)		///
			  NUNIquemin (integer -1)		///
			/* Binomial test */				///
			noBINOmial 						///
			bino_n(integer 0)				///
			bino_nstep(integer 0)  			///
			bino_w(string)					///
			bino_wstep(string)				///
			bino_nw(integer 10)				///
			bino_p(real 0.5)				///
			/* Plot */						///
			PLot							///
			plot_range(string)				///
			plot_n(string)					///
			plot_grid(string)				///
			plot_bwselect(string) 			///
			plot_ciuniform					///
			  plot_cisimul(integer 2000)	///
			plotl_estype(string)			///
			  esll_opt(string)				///
			  espl_opt(string)				///
			plotr_estype(string)			///
			  eslr_opt(string)				///
			  espr_opt(string)				///
			plotl_citype(string)			///
			  cirl_opt(string)				///
			  cill_opt(string)				///
			  cibl_opt(string)				///
			plotr_citype(string)			///
			  cirr_opt(string)				///
			  cilr_opt(string)				///
			  cibr_opt(string)				///
			/* Histogram */					///
			noHISTogram		 				///
			hist_range(string)				///
			hist_n(string)					///
			hist_width(string)				///
			  histl_opt(string)				///
			  histr_opt(string)				///
			/* Additional grph options */	///
			graph_opt(string)				///
			GENVars(string)					///
			/* Reporting */					///
			LEVel(real 95) 					///
			ALL 							///
			]

	marksample touse
	
	local x "`varlist'"
	
	****************************************************************************
	*** CALL: RDDENSITYEST ********************************************************

	if ("`regularize'" == "") {
		local regularize = "regularize"
	}
	else {
		local regularize = "noregularize"
	}

	if ("`masspoints'" == "") {
		local masspoints = "masspoints"
	}
	else {
		local masspoints = "nomasspoints"
	}
	
	if ("`all'" != "") {
		local all = "all"
	}
	else {
		local all = ""
	}
	
	rddensityEST `x' if `touse', ///
			c(`c') p(`p') q(`q') fitselect(`fitselect') kernel(`kernel') h(`h') bwselect(`bwselect') vce(`vce') ///
			`regularize' `masspoints' `all' nlocalmin(`nlocalmin') nuniquemin(`nuniquemin')
	
	/// save ereturn results
	local c 			= e(c)
    local p 			= e(p)
	local q 			= e(q)
	local N_l 			= e(N_l)
	local N_r 			= e(N_r)
    local N_h_l 		= e(N_h_l)
    local N_h_r 		= e(N_h_r)
    local h_l 			= e(h_l)
    local h_r 			= e(h_r)
    local f_ql 			= e(f_ql)
    local f_qr 			= e(f_qr)
    local se_ql 		= e(se_ql)
    local se_qr 		= e(se_qr)
    local se_q 			= e(se_q)
    local pv_q 			= e(pv_q)
	local T_q 			= e(T_q)
	
	if ("`all'" != ""){
    local f_pl 			= e(f_pl)
    local f_pr 			= e(f_pr)
	local se_pl 		= e(se_pl)
    local se_pr 		= e(se_pr)
    local se_p 			= e(se_p)
    local pv_p 			= e(pv_p)
	local T_p 			= e(T_p)
	}
	
	local vce 			= e(vce)
	local bwmethod 		= e(bwmethod)
    local kernel 		= e(kernel)
    local runningvar 	= e(runningvar)
	
	****************************************************************************
	*** BINOMIAL TEST **********************************************************
	
	// determine initial window width
	if ("`bino_w'" != "") {
		local flag_ini_window = "w_provided"
	} 
	else if (`bino_n' != 0) {
		local flag_ini_window = "n_provided"
	}
	else {
		local flag_ini_window = "automatic"
	}
	
	// determine window increment
	if ("`bino_wstep'" != "") {
		local flag_step_window = "w_provided"
	}
	else if (`bino_nstep' != 0) {
		local flag_step_window = "n_provided"
	}
	else {
		local flag_step_window = "automatic"
	}
	
	// bino_w check
	tokenize `bino_w'	
	local w : word count `bino_w'
	if (`w' == 0) {
		local bino_w_l = 0
		local bino_w_r = 0
	}
	else if (`w' == 1) {
		local bino_w_l `"`1'"'
		local bino_w_r `"`1'"'
		if (`bino_w_l' <= 0) {
			di as err `"{err}{cmd:bino_w()}: incorrectly specified (should be a positive number)"'
			exit 198
		} 
	}
	else if (`w' == 2) {
		local bino_w_l `"`1'"'
		local bino_w_r `"`2'"'
		if (`bino_w_l' <= 0 | `bino_w_r' <= 0) {
			di as err `"{err}{cmd:bino_w()}: incorrectly specified (should be positive numbers)"'
			exit 198
		}
	}
	else {
		di as error  "{err}{cmd:bino_w()} takes at most two inputs."  
		exit 125
	}
	
	// bino_n check
	if (`bino_n' > 0) {
		// do nothing
	}
	else if (`bino_n' < 0) {
		di as err `"{err}{cmd:bino_n()}: incorrectly specified (should be a positive integer)"'
		exit 198
	}
	else {
		local bino_n = 20
	}
	
	// bino_wstep check
	tokenize `bino_wstep'	
	local w : word count `bino_wstep'
	if (`w' == 0) {
		local bino_wstep_l = 0
		local bino_wstep_r = 0
	}
	else if (`w' == 1) {
		local bino_wstep_l `"`1'"'
		local bino_wstep_r `"`1'"'
		if (`bino_wstep_l' <= 0) {
			di as err `"{err}{cmd:bino_wstep()}: incorrectly specified (should be a positive number)"'
			exit 198
		} 
	}
	else if (`w' == 2) {
		local bino_wstep_l `"`1'"'
		local bino_wstep_r `"`2'"'
		if (`bino_wstep_l' <= 0 | `bino_wstep_r' <= 0) {
			di as err `"{err}{cmd:bino_wstep()}: incorrectly specified (should be positive numbers)"'
			exit 198
		}
	}
	else {
		di as error  "{err}{cmd:bino_wstep()} takes at most two inputs."  
		exit 125
	}
	
	// bino_nstep check
	if (`bino_nstep' > 0) {
		// do nothing
	}
	else if (`bino_nstep' < 0) {
		di as err `"{err}{cmd:bino_nstep()}: incorrectly specified (should be a positive integer)"'
		exit 198
	}
	else {
		// do nothing
	}
	
	// bino_nw check
	if (`bino_nw' <= 0) {
		di as err `"{err}{cmd:bino_nw()}: incorrectly specified (should be a positive integer)"'
		exit 198
	}
	
	// bino_p check
	if (`bino_p'<=0 | `bino_p'>=1) {
		di as err `"{err}{cmd:bino_p()}: incorrectly specified (should be between 0 and 1)"'
		exit 198
	}

	// calculate windows
	mata {
	if ("`binomial'" == "") {

	X = st_data(.,("`x'"), 0)
	XL = sort(abs(select(X, X :< `c') :- `c'), 1)
	XR = sort(select(X, X :>= `c') :- `c', 1)
	Y = sort(abs(X :- `c'), 1)
	binomTempLWindow = J(`bino_nw', 1, .)
	binomTempRWindow = J(`bino_nw', 1, .)

	// initial window width
	if ("`flag_ini_window'" == "w_provided") {
		binomTempLWindow[1] = `bino_w_l'
		binomTempRWindow[1] = `bino_w_r'
	} 
	else {
		binomTempLWindow[1] = Y[min((`bino_n', `N_l'+`N_r'))]
		binomTempRWindow[1] = binomTempLWindow[1]
	}
	
	// window increment
	if (`bino_nw' > 1) {
	if ("`flag_step_window'" == "w_provided") {
		binomTempLWindow[2..`bino_nw', 1] = (1..(`bino_nw'-1))' :* `bino_wstep_l' :+ binomTempLWindow[1]
		binomTempRWindow[2..`bino_nw', 1] = (1..(`bino_nw'-1))' :* `bino_wstep_r' :+ binomTempRWindow[1]
	}
	else if ("`flag_step_window'" == "n_provided") {
		for (jj=2; jj<=`bino_nw'; jj++) {
			if ("`flag_ini_window'" == "w_provided") {
				binomTempLWindow[jj] = Y[min((sum(XL :<= binomTempLWindow[1]) + sum(XR :<= binomTempRWindow[1]) + (jj-1) * `bino_nstep', `N_l'+`N_r'))]
				binomTempRWindow[jj] = binomTempLWindow[jj]
			}
			else {
				binomTempLWindow[jj] = Y[min((`bino_n' + (jj-1) * `bino_nstep', `N_l'+`N_r'))]
				binomTempRWindow[jj] = binomTempLWindow[jj]
			}
		}
	}
	else {
		if (binomTempLWindow[1] >= `h_l' | binomTempRWindow[1] >= `h_r') {
			// exceed bandwidth on either side
			binomTempLWindow = binomTempLWindow[1]
			binomTempRWindow = binomTempRWindow[1]
		}
		else {
			if (binomTempLWindow[1]*`bino_nw' > `h_l') {
				binomTempLWindow[2..`bino_nw', 1] = (1..(`bino_nw'-1))' :* ((`h_l'-binomTempLWindow[1])/(`bino_nw'-1)) :+ binomTempLWindow[1]
			}
			else {
				binomTempLWindow[2..`bino_nw', 1] = (1..(`bino_nw'-1))' :* binomTempLWindow[1] :+ binomTempLWindow[1]
			}
			
			if (binomTempRWindow[1]*`bino_nw' > `h_r') {
				binomTempRWindow[2..`bino_nw', 1] = (1..(`bino_nw'-1))' :* ((`h_r'-binomTempRWindow[1])/(`bino_nw'-1)) :+ binomTempRWindow[1]
			}
			else {
				binomTempRWindow[2..`bino_nw', 1] = (1..(`bino_nw'-1))' :* binomTempRWindow[1] :+ binomTempRWindow[1]
			}
		}
	}
	}
	
	// window sample size
	binomTempLN	     = J(rows(binomTempLWindow), 1, .)
	binomTempRN      = J(rows(binomTempLWindow), 1, .)
	
	for (jj=1; jj<=rows(binomTempLWindow); jj++) {
		binomTempLN[jj] = sum(XL :<= binomTempLWindow[jj])
		binomTempRN[jj] = sum(XR :<= binomTempRWindow[jj])
	}
	
	// binomTempLWindow
	// binomTempRWindow
	// binomTempLN
	// binomTempRN
	// rows(binomTempLWindow)

	st_matrix("binomTempLeftWindow" , binomTempLWindow)
	st_matrix("binomTempRightWindow", binomTempRWindow)
	st_matrix("binomTempLeftN" , binomTempLN)
	st_matrix("binomTempRightN", binomTempRN)
	st_matrix("binomTempNumber", rows(binomTempLWindow))
	st_matrix("binomTempEqualWindow", sum(binomTempLWindow != binomTempRWindow) == 0)

	}
	}

	local binomTempNumber = binomTempNumber[1,1]
	local binomTempEqualWindow = binomTempEqualWindow[1,1]

	if ("`binomial'" == "") {
		disp in ye "P-values of binomial tests." in gr " (H0: prob = `bino_p')"
		disp in smcl in gr "{hline 19}{c TT}{hline 22}{c TT}{hline 10}"
		
		

	if (`binomTempEqualWindow' == 1) {
		disp in smcl in gr "{ralign 18: Window Length / 2}"            			_col(20) "{c |}"  "{ralign 9: <c}" 		_col(33)	"{ralign 9: >=c}"		_col(43) "{c |}" _col(49) "P>|T|"
	}
	else {
		disp in smcl in gr "{ralign 18: Window Length}"            				_col(20) "{c |}"  "{ralign 9: <c}" 		_col(33)	"{ralign 9: >=c}"		_col(43) "{c |}" _col(49) "P>|T|"
	}
	
	disp in smcl in gr "{hline 19}{c +}{hline 22}{c +}{hline 10}"
	
	forvalues i = 1(1)`binomTempNumber' {
			local binomTempTotal   = binomTempLeftN[`i', 1] + binomTempRightN[`i', 1]
			local binomTempSuccess = binomTempLeftN[`i', 1]
			if (`binomTempTotal' > 0) {
				qui bitesti `binomTempTotal' `binomTempSuccess' `bino_p'
				if (`binomTempEqualWindow' == 1) {
					disp in smcl in ye _col(10) %9.3f binomTempLeftWindow[`i',1] 	_col(20) "{c |}"  %9.0f binomTempLeftN[`i',1] 	_col(33) %9.0f binomTempRightN[`i',1] 	_col(43) "{c |}" _col(45) %9.4f r(p)
				}
				else {
					disp in smcl in ye %8.3f binomTempLeftWindow[`i',1] _col(10) "+" %8.3f binomTempRightWindow[`i',1] _col(20) "{c |}"  %9.0f binomTempLeftN[`i',1] _col(33) %9.0f binomTempRightN[`i',1] _col(43) "{c |}" _col(45) %9.4f r(p)
				}
			}
			else {
				if (`binomTempEqualWindow' == 1) {
					disp in smcl in ye _col(10) %9.3f binomTempLeftWindow[`i',1] 	_col(20) "{c |}"  %9.0f 0 						_col(33) %9.0f  0 						_col(43) "{c |}" _col(45) %9.4f 1.0000
				}
				else {
					disp in smcl in ye %8.3f binomTempLeftWindow[`i',1] _col(10) "+" %8.3f binomTempRightWindow[`i',1] _col(20) "{c |}"  %9.0f 0 _col(33) %9.0f 0 _col(43) "{c |}" _col(45) %9.4f 1.0000
				}
			}
	}
	
	disp in smcl in gr "{hline 19}{c BT}{hline 22}{c BT}{hline 10}"
	
	}
	
	****************************************************************************
	*** LPDENSITY **************************************************************
	
	// plot_range
	tokenize `plot_range'	
	local w : word count `plot_range'
	if `w' == 0 {
		qui sum `x'
		if (`c' - 3 * `h_l' < r(min)) {
			local plot_range_l = r(min)
		} 
		else {
			local plot_range_l = `c' - 3 * `h_l'
		}
		if (`c' + 3 * `h_r' > r(max)) {
			local plot_range_r = r(max)
		} 
		else {
			local plot_range_r = `c' + 3 * `h_r'
		}
	}
	if `w' == 1 {
		di as error  "{err}{cmd:plot_range()} takes two inputs."  
		exit 125
	}
	if `w' == 2 {
		local plot_range_l `"`1'"'
		local plot_range_r `"`2'"'
	}
	if `w' >= 3 {
		di as error  "{err}{cmd:plot_range()} takes two inputs."  
		exit 125
	}
	
	// plot_n
	tokenize `plot_n'	
	local w : word count `plot_n'
	if `w' == 0 {
		local plot_n_l = 10
		local plot_n_r = 10
	}
	if `w' == 1 {
		local plot_n_l `"`1'"'
		local plot_n_r `"`1'"'
		if (`plot_n_l' <= 0) {
			di as err `"{err}{cmd:plot_n()}: incorrectly specified (should be a positive integer)"'
			exit 198
		}
	}
	if `w' == 2 {
		local plot_n_l `"`1'"'
		local plot_n_r `"`2'"'
		if (`plot_n_l' <= 0 | `plot_n_r' <= 0) {
			di as err `"{err}{cmd:plot_n()}: incorrectly specified (should be positive integers)"'
			exit 198
		}
	}
	if `w' >= 3 {
		di as error  "{err}{cmd:plot_n()} takes two inputs."  
		exit 125
	}
	
	// plot_grid
	if ("`plot_grid'" == "") {
		local plot_grid "es"
	}
	else {
		if ("`plot_grid'" != "es" & "`plot_grid'" != "qs") {
			di as error  "{err}{cmd:plot_grid()} incorrectly specified."  
			exit 125
		}
	}
	
	// level
	if (`level' <= 0 | `level' >= 100) {
	di as err `"{err}{cmd:level()}: incorrectly specified"'
	exit 198
	}
	
	// plot
	if ("`plot'" != "") {
		local plot = 1
		capture which lpdensity
		if (_rc == 111) {
			di as error  `"{err}plotting feature requires command {cmd:lpdensity}, install with"'
			di as error  `"{err}net install lpdensity, from(https://raw.githubusercontent.com/nppackages/lpdensity/master/stata) replace"'
			exit 111
		}
	}
	else {
		local plot = 0
	}

	if (`plot' == 1) {
		
		if (`plot_n_l' + `plot_n_r' > _N) {
			local newN = `plot_n_l' + `plot_n_r'
			set obs `newN'
		}
		tempvar temp_grid
		qui gen `temp_grid' = .
		tempvar temp_bw
		qui gen `temp_bw' = .
		tempvar temp_f
		qui gen `temp_f' = .
		tempvar temp_cil
		qui gen `temp_cil' = .
		tempvar temp_cir
		qui gen `temp_cir' = .
		tempvar temp_group
		qui gen `temp_group' = .
		
	}

	// MATA
	mata{	
	ng = `plot_n_l' + `plot_n_r'
	if (`plot' == 1) {
		// generate grid
		if ("`plot_grid'" == "es") {
			grid = ( rangen(`plot_range_l', `c' - ( (`c' - `plot_range_l') / (`plot_n_l' - 1) ), `plot_n_l' - 1) \ `c' \ `c' \ rangen(`c' + ( (`plot_range_r' - `c') / (`plot_n_r' - 1) ), `plot_range_r', `plot_n_r' - 1) )
		} else {
			x = st_data(., "`x'", "`touse'")
			temp1 = mean(x :<= `plot_range_l')
			temp2 = mean(x :<= `c')
			temp3 = mean(x :<= `plot_range_r')
			grid = ( rangen(temp1, temp2 - ( (temp2 - temp1) / (`plot_n_l' - 1) ), `plot_n_l' - 1) \ temp2 \ temp2 \ rangen(temp2 + ( (temp3 - temp2) / (`plot_n_r' - 1) ), temp3, `plot_n_r' - 1) )
			for (j=1; j<=length(grid); j++) {
				grid[j] = rddensity_quantile(x, grid[j])
			}
			grid[`plot_n_l'] = `c'
			grid[`plot_n_l' + 1] = `c'
		}
		
		// generate group
		group = ( J(`plot_n_l', 1, 0) \ J(`plot_n_r', 1, 1) )
		// generate bandwidth
		bw = ( J(`plot_n_l', 1, `h_l') \ J(`plot_n_r', 1, `h_r') )

		st_store((1..ng)', "`temp_grid'", grid)
		st_store((1..ng)', "`temp_group'", group)
		st_store((1..ng)', "`temp_bw'", bw)
	}
	}
	
	if (`plot' == 1) {
	local scale_l = (`N_l' - 1) / (`N_l' + `N_r' - 1)
	local scale_r = (`N_r' - 1) / (`N_l' + `N_r' - 1)
	
	// left estimation
	tempvar temp_grid_l
		qui gen `temp_grid_l' = `temp_grid' if `temp_group' == 0
	tempvar temp_bw_l
		qui gen `temp_bw_l' = `temp_bw' if `temp_group' == 0
	
	// bandwidth selection
	if ("`plot_bwselect'" == "") {
		local plot_bwselect_l = `"bw(`temp_bw_l')"'
	}
	else {
		local plot_bwselect_l = `"bwselect(`plot_bwselect')"'
	}

	// uniform confidence band
	if ("`plot_ciuniform'" != "") {
		local plot_ciuniform = `"ciuniform cisimul(`plot_cisimul')"'
	}
	else {
		local plot_ciuniform = ""
	}

	capture lpdensity `x' if `touse' & `x' <= `c', /// 
		grid(`temp_grid_l') `plot_bwselect_l' p(`p') q(`q') v(1) kernel(`kernel') scale(`scale_l') level(`level') ///
		`regularize' `masspoints' nlocalmin(`nlocalmin') nuniquemin(`nuniquemin') ///
		`plot_ciuniform' 
	if (_rc != 0) {
		di as error  `"{err}{cmd:lpdensity} failed. Please try to install the latest version using"'
		di as error  `"{err}net install lpdensity, from(https://raw.githubusercontent.com/nppackages/lpdensity/master/stata) replace"'
		di as error  `"{err}If error persists, please contact the authors."'
		di as error  `"{err}{cmd:lpdensity} error message:"'
		lpdensity `x' if `touse' & `x' <= `c', /// 
			grid(`temp_grid_l') `plot_bwselect_l' p(`p') q(`q') v(1) kernel(`kernel') scale(`scale_l') level(`level') ///
			`regularize' `masspoints' nlocalmin(`nlocalmin') nuniquemin(`nuniquemin') ///
			`plot_ciuniform' 
		exit 111
	}
	}
		
	mata{
	if (`plot' == 1) {
		left = st_matrix("e(result)")
		st_store((1..`plot_n_l')', "`temp_bw'",  left[., 2])
		st_store((1..`plot_n_l')', "`temp_f'", 	 left[., 4])
		st_store((1..`plot_n_l')', "`temp_cil'", left[., 8])
		st_store((1..`plot_n_l')', "`temp_cir'", left[., 9])
	}
	}
	
	if (`plot' == 1) {
	// right estimation
	tempvar temp_grid_r
		qui gen `temp_grid_r' = `temp_grid' if `temp_group' == 1
	tempvar temp_bw_r
		qui gen `temp_bw_r' = `temp_bw' if `temp_group' == 1
		
	if ("`plot_bwselect'" == "") {
		local plot_bwselect_r = `"bw(`temp_bw_r')"'
	}
	else {
		local plot_bwselect_r = `"bwselect(`plot_bwselect')"'
	}

	capture lpdensity `x' if `touse' & `x' >= `c', /// 
		grid(`temp_grid_r') `plot_bwselect_r' p(`p') q(`q') v(1) kernel(`kernel') scale(`scale_r') level(`level') ///
		`regularize' `masspoints' nlocalmin(`nlocalmin') nuniquemin(`nuniquemin') ///
		`plot_ciuniform'
	if (_rc != 0) {
		di as error  `"{err}{cmd:lpdensity} failed. Please try to install the latest version using"'
		di as error  `"{err}net install lpdensity, from(https://raw.githubusercontent.com/nppackages/lpdensity/master/stata) replace"'
		di as error  `"{err}If error persists, please contact the authors."'
		di as error  `"{err}{cmd:lpdensity} error message:"'
		lpdensity `x' if `touse' & `x' >= `c', /// 
			grid(`temp_grid_r') `plot_bwselect_r' p(`p') q(`q') v(1) kernel(`kernel') scale(`scale_r') level(`level') ///
			`regularize' `masspoints' nlocalmin(`nlocalmin') nuniquemin(`nuniquemin') ///
			`plot_ciuniform'
		exit 111
	}
	}
	
	mata{
	if (`plot' == 1) {
		right = st_matrix("e(result)")
		st_store(((`plot_n_l'+1)..(`plot_n_l'+`plot_n_r'))', "`temp_bw'",  right[., 2])
		st_store(((`plot_n_l'+1)..(`plot_n_l'+`plot_n_r'))', "`temp_f'",   right[., 4])
		st_store(((`plot_n_l'+1)..(`plot_n_l'+`plot_n_r'))', "`temp_cil'", right[., 8])
		st_store(((`plot_n_l'+1)..(`plot_n_l'+`plot_n_r'))', "`temp_cir'", right[., 9])
	}
	}
		
	if ("`genvars'" != "" & `plot' == 1) {
		qui gen `genvars'_grid 	= `temp_grid'
		qui gen `genvars'_bw 	= `temp_bw'
		qui gen `genvars'_f 	= `temp_f'
		qui gen `genvars'_cil 	= `temp_cil'
		qui gen `genvars'_cir 	= `temp_cir'
		qui gen `genvars'_group = `temp_group'
		label variable `genvars'_grid	"rddensity plot: grid"
		label variable `genvars'_bw		"rddensity plot: bandwidth"
		label variable `genvars'_f		"rddensity plot: point estimate"
		label variable `genvars'_cil	"rddensity plot: `level'% CI, left"
		label variable `genvars'_cir	"rddensity plot: `level'% CI, right"
		label variable `genvars'_group	"rddensity plot: =1 if grid >= `c'"
	}
	
	
	****************************************************************************
	*** DEFAULT OPTIONS: HISTOGRAM *********************************************
	
	// hist_range
	tokenize `hist_range'	
	local w : word count `hist_range'
	if `w' == 0 {
		qui sum `x'
		if (`c' - 3 * `h_l' < r(min)) {
			local hist_range_l = r(min)
		} 
		else {
			local hist_range_l = `c' - 3 * `h_l'
		}
		if (`c' + 3 * `h_r' > r(max)) {
			local hist_range_r = r(max)
		} 
		else {
			local hist_range_r = `c' + 3 * `h_r'
		}
	}
	if `w' == 1 {
		di as error  "{err}{cmd:hist_range()} takes two inputs."  
		exit 125
	}
	if `w' == 2 {
		local hist_range_l `"`1'"'
		local hist_range_r `"`2'"'
	}
	if `w' >= 3 {
		di as error  "{err}{cmd:hist_range()} takes two inputs."  
		exit 125
	}
	
	// hist_n
	tokenize `hist_n'
	local w : word count `hist_n'
	if `w' == 0 {
		// check if hist_width is provided
		if ("`hist_width'" == "") {
			// do shonething
			qui count if `x' < `c' & `x' >= `hist_range_l'
			local hist_n_l = ceil(min( sqrt(r(N)) , 10 * log(r(N)) / log(10) ))
			qui count if `x' >= `c' & `x' <= `hist_range_r'
			local hist_n_r = ceil(min( sqrt(r(N)) , 10 * log(r(N)) / log(10) ))
		}
		else {
			// do nothing. wait until hist_width
		}
		
	}
	if `w' == 1 {
		local hist_n_l `"`1'"'
		local hist_n_r `"`1'"'
		if (`hist_n_l' <= 0) {
			di as err `"{err}{cmd:hist_n()}: incorrectly specified (should be a positive integer)"'
			exit 198
		}
	}
	if `w' == 2 {
		local hist_n_l `"`1'"'
		local hist_n_r `"`2'"'
		if (`hist_n_l' <= 0 | `hist_n_r' <= 0) {
			di as err `"{err}{cmd:hist_n()}: incorrectly specified (should be positive integers)"'
			exit 198
		}
	}
	if `w' >= 3 {
		di as error  "{err}{cmd:hist_n()} takes at most two inputs."  
		exit 125
	}
	
	// hist_width
	tokenize `hist_width'
	local w : word count `hist_width'
	if `w' == 0 {
		local hist_width_l = (`c' - `hist_range_l') / `hist_n_l'
		local hist_width_r = (`hist_range_r' - `c') / `hist_n_r'
	}
	if `w' == 1 {
		if ("`hist_n'" == "") {
			// only hist_width is provided
			local hist_width_l `"`1'"'
			local hist_width_r `"`1'"'
			if (`hist_width_l' <= 0) {
				di as err `"{err}{cmd:hist_width()}: incorrectly specified (should be a positive number)"'
				exit 198
			}
			local hist_n_l = ceil((`c' - `hist_range_l') / `hist_width_l')
			local hist_n_r = ceil((`hist_range_r' - `c') / `hist_width_r')
		}
		else {
			// ignore hist_width input, because hist_n is provided
			local hist_width_l = (`c' - `hist_range_l') / `hist_n_l'
			local hist_width_r = (`hist_range_r' - `c') / `hist_n_r'
		}
	}
	if `w' == 2 {
		if ("`hist_n'" == "") {
			// only hist_width is provided
			local hist_width_l `"`1'"'
			local hist_width_r `"`2'"'
			if (`hist_width_l' <= 0 | `hist_width_r' <= 0) {
				di as err `"{err}{cmd:hist_width()}: incorrectly specified (should be positive numbers)"'
				exit 198
			}
			local hist_n_l = ceil((`c' - `hist_range_l') / `hist_width_l')
			local hist_n_r = ceil((`hist_range_r' - `c') / `hist_width_r')
		}
		else {
			// ignore hist_width input, because hist_n is provided
			local hist_width_l = (`c' - `hist_range_l') / `hist_n_l'
			local hist_width_r = (`hist_range_r' - `c') / `hist_n_r'
		}
	}
	if `w' >= 3 {
		di as error  "{err}{cmd:hist_width()} takes two inputs."  
		exit 125
	}

	// histogram
	if ("`histogram'" != "") {
		local histogram = 0
	}
	else {
		local histogram = 1
	}
	
	if (`histogram' == 1) {
		if (`hist_n_l' + `hist_n_r' > _N) {
			local newN = `hist_n_l' + `hist_n_r'
			set obs `newN'
		}
		
		tempvar temp_hist_center
		qui gen `temp_hist_center' = .
		tempvar temp_hist_end_l
		qui gen `temp_hist_end_l' = .
		tempvar temp_hist_end_r
		qui gen `temp_hist_end_r' = .
		tempvar temp_hist_width
		qui gen `temp_hist_width' = .
		tempvar temp_hist_height
		qui gen `temp_hist_height' = .	
		tempvar temp_hist_group
		qui gen `temp_hist_group' = .
	}
	
	// MATA
	mata{	
		
	if (`histogram' == 1) {
		ng = `hist_n_l' + `hist_n_r'
		temp_hist_width = (J(`hist_n_l', 1, `hist_width_l') \ J(`hist_n_r', 1, `hist_width_r'))
		temp_hist_center = (`c' :- (((`hist_n_l'..1) :- 0.5)' :* `hist_width_l') \ `c' :+ (((1..`hist_n_r') :- 0.5)' :* `hist_width_r'))
		temp_hist_end_l = (`c' :- (((`hist_n_l'..1))' :* `hist_width_l') \ `c' :+ (((1..`hist_n_r') :- 1)' :* `hist_width_r'))
		temp_hist_end_r = (`c' :- (((`hist_n_l'..1) :- 1)' :* `hist_width_l') \ `c' :+ (((1..`hist_n_r'))' :* `hist_width_r'))
		temp_hist_group = (J(`hist_n_l', 1, 0) \ J(`hist_n_r', 1, 1))
		temp_hist_height = J(ng, 1, .)
	
		x = st_data(., "`x'", "`touse'")
	
		for (jj=1; jj<=ng; jj++) {
			temp_hist_height[jj] = sum(x :>= temp_hist_end_l[jj] :& x :< temp_hist_end_r[jj]) / (`N_l' + `N_r') / temp_hist_width[jj]
		}
	
		st_store((1..ng)', "`temp_hist_width'",  temp_hist_width)
		st_store((1..ng)', "`temp_hist_center'", temp_hist_center)
		st_store((1..ng)', "`temp_hist_end_l'", temp_hist_end_l)
		st_store((1..ng)', "`temp_hist_end_r'", temp_hist_end_r)
		st_store((1..ng)', "`temp_hist_height'", temp_hist_height)
		st_store((1..ng)', "`temp_hist_group'", temp_hist_group)
	}
	}
	
	if ("`genvars'" != "" & `plot' == 1 & `histogram' == 1) {
		qui gen `genvars'_hist_width 	= `temp_hist_width'
		qui gen `genvars'_hist_center 	= `temp_hist_center'
		qui gen `genvars'_hist_height 	= `temp_hist_height'
		qui gen `genvars'_hist_group 	= `temp_hist_group'
		qui gen `genvars'_hist_endl 	= `temp_hist_end_l'
		qui gen `genvars'_hist_endr 	= `temp_hist_end_r'
		label variable `genvars'_hist_width		"histogram plot: histogram bar width"
		label variable `genvars'_hist_center	"histogram plot: histogram bar center"
		label variable `genvars'_hist_endl		"histogram plot: histogram bar left end"
		label variable `genvars'_hist_endr		"histogram plot: histogram bar right end"
		label variable `genvars'_hist_height	"histogram plot: histogram bar height"
		label variable `genvars'_hist_group		"histogram plot: =1 if cell center > `c'"
	}
	
	****************************************************************************
	*** PLOT *******************************************************************

	if (`plot' == 1) {
		
		// ci type check, left
		if ("`plotl_citype'" == "") {
			local plotl_citype = "region"
		}
		else if ("`plotl_citype'" != "all" & "`plotl_citype'" != "region" & "`plotl_citype'" != "line" & "`plotl_citype'" != "ebar" & "`plotl_citype'" != "none") {
			di as err `"plotl_citype(): incorrectly specified: options(region, line, ebar, all, none)"'
			exit 198
		}

		if ("`plotl_citype'" == "region" | "`plotl_citype'" == "all") {
			if ("`cirl_opt'" == "") {
				local ci_plot_region_l = `"(rarea `temp_cil' `temp_cir' `temp_grid' if `temp_group' == 0, sort lcolor(white%0) color(red%30))"'
			} 
			else {
				local ci_plot_region_l = `"(rarea `temp_cil' `temp_cir' `temp_grid' if `temp_group' == 0, sort `cirl_opt')"'
			}
		} 
		else {
			local ci_plot_region_l = `""'
		}
		if ("`plotl_citype'" == "line" | "`plotl_citype'" == "all") {
			if ("`cill_opt'" == "") {
				local ci_plot_line_l = `"(rline `temp_cil' `temp_cir' `temp_grid' if `temp_group' == 0, sort color(red%70))"'
			} 
			else {
				local ci_plot_line_l = `"(rline `temp_cil' `temp_cir' `temp_grid' if `temp_group' == 0, sort `cill_opt')"'
			}
		}
		else {
			local ci_plot_line_l = `""'
		}
		if ("`plotl_citype'" == "ebar" | "`plotl_citype'" == "all") {
			if ("`cibl_opt'" == "") {
				local ci_plot_ebar_l = `"(rcap `temp_cil' `temp_cir' `temp_grid' if `temp_group' == 0, sort color(red%70))"'
			} 
			else {
				local ci_plot_ebar_l = `"(rcap `temp_cil' `temp_cir' `temp_grid' if `temp_group' == 0, sort `cibl_opt')"'
			}
		}
		else {
			local ci_plot_ebar_l = `""'
		}
		
		// ci type check, right
		if ("`plotr_citype'" == "") {
			local plotr_citype = "region"
		}
		else if ("`plotr_citype'" != "all" & "`plotr_citype'" != "region" & "`plotr_citype'" != "line" & "`plotr_citype'" != "ebar" & "`plotr_citype'" != "none") {
			di as err `"plotr_citype(): incorrectly specified: options(region, line, ebar, all, none)"'
			exit 198
		}

		if ("`plotr_citype'" == "region" | "`plotr_citype'" == "all") {
			if ("`cirr_opt'" == "") {
				local ci_plot_region_r = `"(rarea `temp_cil' `temp_cir' `temp_grid' if `temp_group' == 1, sort lcolor(white%0) color(blue%30))"'
			} 
			else {
				local ci_plot_region_r = `"(rarea `temp_cil' `temp_cir' `temp_grid' if `temp_group' == 1, sort `cirr_opt')"'
			}
		} 
		else {
			local ci_plot_region_r = `""'
		}
		if ("`plotr_citype'" == "line" | "`plotr_citype'" == "all") {
			if ("`cilr_opt'" == "") {
				local ci_plot_line_r = `"(rline `temp_cil' `temp_cir' `temp_grid' if `temp_group' == 1, sort color(blue%70))"'
			} 
			else {
				local ci_plot_line_r = `"(rline `temp_cil' `temp_cir' `temp_grid' if `temp_group' == 1, sort `cilr_opt')"'
			}
		}
		else {
			local ci_plot_line_r = `""'
		}
		if ("`plotr_citype'" == "ebar" | "`plotr_citype'" == "all") {
			if ("`cibr_opt'" == "") {
				local ci_plot_ebar_r = `"(rcap `temp_cil' `temp_cir' `temp_grid' if `temp_group' == 1, sort color(blue%70))"'
			} 
			else {
				local ci_plot_ebar_r = `"(rcap `temp_cil' `temp_cir' `temp_grid' if `temp_group' == 1, sort `cibr_opt')"'
			}
		}
		else {
			local ci_plot_ebar_r = `""'
		}
		
		// point est type check, left
		
		if ("`plotl_estype'" == "") {
			local plotl_estype = "line"
		}
		else if ("`plotl_estype'" != "both" & "`plotl_estype'" != "line" & "`plotl_estype'" != "point" & "`plotl_estype'" != "none") {
			di as err `"plotl_estype(): incorrectly specified: options(line, point, both, none)"'
			exit 198
		}

		if ("`plotl_estype'" == "line" | "`plotl_estype'" == "both") {
			if ("`esll_opt'" == "") {
				local es_plot_line_l = `"(line `temp_f' `temp_grid' if `temp_group' == 0, sort lcolor(red) lwidth("medthin") lpattern(solid))"'
			} 
			else {
				local es_plot_line_l = `"(line `temp_f' `temp_grid' if `temp_group' == 0, sort `esll_opt')"'
			}
		} 
		else {
			local es_plot_line_l = `""'
		}
		if ("`plotl_estype'" == "point" | "`plotl_estype'" == "both") {
			if ("`espl_opt'" == "") {
				local es_plot_point_l = `"(scatter `temp_f' `temp_grid' if `temp_group' == 0, sort color(red))"'
			} 
			else {
				local es_plot_point_l = `"(scatter `temp_f' `temp_grid' if `temp_group' == 0, sort `espl_opt')"'
			}
		} 
		else {
			local es_plot_point_l = `""'
		}
		
		// point est type check, right
		
		if ("`plotr_estype'" == "") {
			local plotr_estype = "line"
		}
		else if ("`plotr_estype'" != "both" & "`plotr_estype'" != "line" & "`plotr_estype'" != "point" & "`plotr_estype'" != "none") {
			di as err `"plotr_estype(): incorrectly specified: options(line, point, both, none)"'
			exit 198
		}

		if ("`plotr_estype'" == "line" | "`plotr_estype'" == "both") {
			if ("`eslr_opt'" == "") {
				local es_plot_line_r = `"(line `temp_f' `temp_grid' if `temp_group' == 1, sort lcolor(blue) lwidth("medthin") lpattern(solid))"'
			} 
			else {
				local es_plot_line_r = `"(line `temp_f' `temp_grid' if `temp_group' == 1, sort `eslr_opt')"'
			}
		} 
		else {
			local es_plot_line_r = `""'
		}
		if ("`plotr_estype'" == "point" | "`plotr_estype'" == "both") {
			if ("`espr_opt'" == "") {
				local es_plot_point_r = `"(scatter `temp_f' `temp_grid' if `temp_group' == 1, sort color(blue))"'
			} 
			else {
				local es_plot_point_r = `"(scatter `temp_f' `temp_grid' if `temp_group' == 1, sort `espr_opt')"'
			}
		} 
		else {
			local es_plot_point_r = `""'
		}
	
		if (`histogram' == 1) {
			if ("`histl_opt'" == "") {
				local plot_histogram_l = `"(bar `temp_hist_height' `temp_hist_center' if `temp_hist_center' < `c', barwidth(`hist_width_l') color(red%20))"'
			} 
			else {
				local plot_histogram_l = `"(bar `temp_hist_height' `temp_hist_center' if `temp_hist_center' < `c', `histl_opt')"'
			}
			if ("`histr_opt'" == "") {
				local plot_histogram_r = `"(bar `temp_hist_height' `temp_hist_center' if `temp_hist_center' >= `c', barwidth(`hist_width_r') color(blue%20))"'
			} 
			else {
				local plot_histogram_r = `"(bar `temp_hist_height' `temp_hist_center' if `temp_hist_center' >= `c', `histr_opt')"'
			}
		}
		else {
			local plot_histogram_l = ""
			local plot_histogram_r = ""
		}
		
		// graph option check
		if (`"`graph_opt'"' == "" ) {
			local graph_opt = `"xline(`c', lcolor(black) lwidth(medthin) lpattern(solid)) legend(off) title("Manipulation Testing Plot", color(gs0)) xtitle("`x'") ytitle("")"'
		}
		
		twoway 	`plot_histogram_l' 	/// 
				`plot_histogram_r' 	/// 
				`ci_plot_region_l' 	///
				`ci_plot_line_l'   	///
				`ci_plot_ebar_l'   	///
				`ci_plot_region_r' 	///
				`ci_plot_line_r'   	///
				`ci_plot_ebar_r'   	///
				`es_plot_line_l' 	///
				`es_plot_point_l' 	///
				`es_plot_line_r' 	///
				`es_plot_point_r' 	///
				,					///
				`graph_opt'
	}
	
	ereturn clear 
	ereturn scalar c = `c' 
	ereturn scalar p = `p' 
	ereturn scalar q = `q' 
	ereturn scalar N_l = `N_l' 
	ereturn scalar N_r = `N_r'
	ereturn scalar N_h_l = `N_h_l' 
	ereturn scalar N_h_r = `N_h_r'
	ereturn scalar h_l = `h_l'
	ereturn scalar h_r = `h_r'
	ereturn scalar f_ql = `f_ql'
	ereturn scalar f_qr = `f_qr'
	ereturn scalar se_ql = `se_ql'
	ereturn scalar se_qr = `se_qr'
	ereturn scalar se_q = `se_q'
	ereturn scalar pv_q = `pv_q'
	ereturn scalar T_q = `T_q'

	if ("`all'"!=""){
	ereturn scalar f_pl = `f_pl'
	ereturn scalar f_pr = `f_pr'
	ereturn scalar se_pl = `se_pl'
	ereturn scalar se_pr = `se_pr'
	ereturn scalar se_p = `se_p'
	ereturn scalar pv_p = `pv_p'
	ereturn scalar T_p = `T_p'
	}
	
	ereturn local runningvar  "`runningvar'"
	ereturn local kernel  "`kernel'"
	ereturn local bwmethod  "`bwmethod'"
	ereturn local vce  "`vce'"
	
	mata: mata clear
	
end
	
