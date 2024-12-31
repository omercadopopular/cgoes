*! Date     : 20 Oct 2014
*! Version  : 1.0
*! Authors  : Robin Jessen, Davud Rostam-Afschar
*! Email    : robin.jessen@fu-berlin.de, davud.rostam-afschar@fu-berlin.de

program define graph3d
version 11.0

syntax varlist(min=3 max=4) [if] [in] [, XANGle(int 45) YANGle(int 45) ZANGle(int 0) XMove(int 0) YMove(int 0) ZMove(int 0) ///
ASpectratio(int 1) Scale(real 1) XPIV(string) YPIV(string) ZPIV(string) PERSPective XCAM(real 0) YCAM(real 0) ZCAM(real 300) ///
PIV CUBoid Format(string) XLabel(string) YLabel(string) ZLabel(string) COlorscheme(string) EQUIdistance MARK WIRE INNERGRID ///
XLPos(int 0) YLPos(int 0) ZLPos(int 0) XLANGle(int 0) YLANGle(int 0) ZLANGle(int 0) BLVertices ///
MARKEROPTIONS(string) COORDinates(string) ] 

marksample touse, novarlist
preserve
qui keep if `touse' 
tokenize `varlist'
tempname x y z 
local x_coor `1'
local y_coor `2'
local z_coor `3'
qui su `1'
local x_center = r(min)+(r(max) - r(min))/2
local dist=0-`x_center'
qui gen double `x'=`1'+`dist'

qui su `2'
local y_center = r(min)+(r(max) - r(min))/2
local dist=0-`y_center'
qui gen double `y'=`2'+`dist'

qui su `3'
local z_center = r(min)+(r(max) - r(min))/2
local dist=0-`z_center'
qui gen double `z'=`3'+`dist'

if "`markeroptions'"==""{
	local markeroptions "false"
}
else{
	local markeroptions `""`markeroptions'""'
}
if "`coordinates'"==""{
	local coordinates "false"
}
else{
	if "`coordinates'"=="all"{
		local coordinates "1 2 3 4 5 6 7 8"	
	}
	local coordinates `""`coordinates'""'
}

if "`xpiv'"~=""{
	capture confirm number `xpiv'
	if !_rc {
	} 
	else {
		display as error "please enter a number or nothing for xpiv"
		exit 0
	}
}
else {
	qui su `x'
	local xpiv = r(min)+(r(max) - r(min)) / 2
}
if "`ypiv'"~=""{
	capture confirm number `ypiv'
	if !_rc {
	} 
	else {
		display as error "please enter a number or nothing for ypiv"
		exit 0
	}
}
else {
	qui su `y'
	local ypiv = r(min)+(r(max) - r(min)) / 2
}
if "`zpiv'"~=""{
	capture confirm number `zpiv'
	if !_rc {
	} 
	else {
		display as error "please enter a number or nothing for zpiv"
		exit 0
	}
}
else {
	qui su `z'
	local zpiv = r(min)+(r(max) - r(min)) / 2
}

/*w is represented by the colorscheme*/
if "`4'"!=""{
	local w `4'
	if "`colorscheme'" == ""{
		local mark `mark'
	}
}
else{
	local w `2'
}

if "`colorscheme'"!="" & "`colorscheme'"!="bcgyr" & "`colorscheme'"!="cr" ///
& "`colorscheme'"!="fadetogrey" & "`colorscheme'"!="50shadesofgrey " & "`colorscheme'"!="fade"{
	display as error "colorscheme unknown, try bcgyr, cr, fade"
	exit 0
}

if (`xlpos'<0 | `xlpos'>12) | ///
   (`ylpos'<0 | `ylpos'>12) | ///
   (`zlpos'<0 | `zlpos'>12){
	display as error "only clock directions (1, 2, ..., 12) allowed"
	exit 0
}

tempname Scale
if "`persp'"~="" | "`perspective'"~="" {
	local perspective "true"
	if `zcam'!=0{
		scalar `Scale' = `scale'/`zcam'
	}
	else{
		scalar `Scale' = `scale'/0.00001
	}
}

else {
	local perspective "false"
	scalar `Scale' = `scale'
}

if "`format'"=="" local format "%04.2f"
local xlabel `""`xlabel'""'
local ylabel `""`ylabel'""'
 local zlabel `""`zlabel'""'
if "`piv'"~="" local piv "true"
else local piv "false"
if "`cuboid'"~="" local cuboid "true"
else local cuboid "false"
if scalar(`Scale')==0 {
	scalar `Scale' = (scalar(`Scale')+0.0000001)
}
if scalar(`Scale')~=0 {
	scalar `Scale' = scalar(`Scale')
}

/*generate temporary variables for programmes _move_scale_rotate and _draw*/
qui {
	tempvar x_temp y_temp z_temp  gx_temp gy_temp gz_temp
	gen double `x_temp'=.
	gen double `y_temp'=.
	gen double `z_temp'=.
	gen double `gx_temp'=.
	gen double `gy_temp'=.
	gen double `gz_temp'=.
}
tempvar gx gy gz
if "`cuboid'" == "true"{
	cap set obs 32
	tempname Xmax Xmin Ymax Ymin Zmax Zmin
	qui su `y'
	scalar `Ymax' = r(max)
	scalar `Ymin' = r(min)
	qui su `x'
	scalar `Xmax' = r(max)
	scalar `Xmin' = r(min)
	qui su `z'
	scalar `Zmax' = r(max)
	scalar `Zmin' = r(min)

	qui gen double `gx' = `Xmax' if _n==1
	qui replace `gx' = `Xmax' if inrange(_n,2,4)
	qui replace `gx' = `Xmin' if inrange(_n,5,9)

	qui gen double `gy' = `Ymax' if _n==1
	qui replace `gy' = `Ymax' if inlist(_n,2,5,6)
	qui replace `gy' = `Ymin' if inlist(_n,3,4,7,8)

	qui gen double `gz' = `Zmin' if _n==1
	qui replace `gz' = `Zmax' if inlist(_n,2,4,6,8)
	qui replace `gz' = `Zmin' if inlist(_n,3,5,7)

	if "`innergrid'"!=""{
		qui replace `gx' = `Xmin'+2*(`Xmax'-`Xmin')/3 if inrange(_n,25,28)
		qui replace `gx' = `Xmin'+(`Xmax'-`Xmin')/3 if inrange(_n,29,32)
		qui replace `gx' = `Xmax' if inrange(_n,13,16) | inrange(_n,21,24)
		qui replace `gx' = `Xmin' if inlist(_n,10,11,12,17,18,19,20)
		
		qui replace `gy' = `Ymin'+2*(`Ymax'-`Ymin')/3 if inlist(_n,19,20,23,24)
		qui replace `gy' = `Ymin'+(`Ymax'-`Ymin')/3 if inlist(_n,17,18,21,22)
		qui replace `gy' = `Ymax' if inlist(_n,9,10,13,14,25,26,29,30)
		qui replace `gy' = `Ymin' if inlist(_n,11,12,15,16,27,28,31,32)

		qui replace `gz' = `Zmin'+2*(`Zmax'-`Zmin')/3 if inlist(_n,10,12,14,16)
		qui replace `gz' = `Zmin'+(`Zmax'-`Zmin')/3 if inlist(_n,9,11,13,15)
		qui replace `gz' = `Zmax' if inlist(_n,18,20,22,24,26,28,30,32)
		qui replace `gz' = `Zmin' if inlist(_n,17,19,21,23,25,27,29,31)
	}
	_move_scale_rotate  `gx_temp' `gy_temp' `gz_temp' `xmove' `ymove' `zmove' scalar(`Scale') `xangle' `yangle' `zangle' `xpiv' `ypiv' `zpiv' `perspective' `xcam' `ycam' `zcam' `gx' `gy' `gz'
}
_move_scale_rotate `x_temp' `y_temp' `z_temp' `xmove' `ymove' `zmove' scalar(`Scale') `xangle' `yangle' `zangle' `xpiv' `ypiv' `zpiv' `perspective' `xcam' `ycam' `zcam' `x' `y' `z'

tempname Px Py	
scalar `Px' = ((`xpiv'+`xcam') / (`zpiv'+`zcam'))/`scale' + `xmove'
scalar `Py' = ((`ypiv'-`ycam') / (`zpiv'+`zcam'))/`scale' + `ymove'
if "`colorscheme'" == ""{
	local colorscheme false
}
local colors `colorscheme'

if "`equidistance'"!=""{
	local equidistance "true"
}
else{
	local equidistance "false"
}
if "`mark'"!=""{
	local mark "true"
}
else{
	local mark "false"
}
if "`wire'"!=""{
	local wire "true"
}
else{
	local wire "false"
}
if "`blvertices'"!=""{
	local blvertices "true"
}
else{
	local blvertices "false"
}

_draw `gx_temp' `gy_temp' `x_temp' `y_temp' `aspectratio' scalar(`Px') scalar(`Py') `piv' `cuboid' `gx' `gy' `gz' `xangle' `yangle' `zangle' ///
`format' `xlabel' `ylabel' `zlabel' `w' `colors' `equidistance' `mark' `x' `y' `z' `wire' `xlpos' `ylpos' `zlpos' `xlangle' `ylangle' `zlangle' ///
`blvertices' `markeroptions' `x_coor' `y_coor' `z_coor' `coordinates' 
restore
end

pr _draw
	args gvar1 gvar2 var1 var2 asratio px1 py1 piv cuboid x1 y1 z1 xangle yangle zangle format xlabel ylabel zlabel wdata colors equidistance ///
	mark x y z wire xlpos ylpos zlpos xlangle ylangle zlangle blvertices markeroptions x_coor y_coor z_coor coordinates	
	local draw ""
	if "`markeroptions'"=="false"{
		local markeroptions ""
	}

	/*pivot*/
	if "`piv'" == "true"{
		tempvar py px
		qui gen double `py' = `py1'
		qui gen double `px' = `px1'
		local draw "`draw' (scatter `py' `px' if _n==1, msize(5)) "
	}
	tempvar sorter nvals
	/*Draw cuboid*/
	if "`cuboid'" == "true"{
		if "`blvertices'" == "true"{
			local mlc "mc(black) mlabcolor(black)"
		}
		tempvar label pos gx gy gz xlab ylab zlab xlabelpos ylabelpos zlabelpos

		qui gen `xlab' = "`xlabel'"
		qui gen `ylab' = "`ylabel'"
		qui gen `zlab' = "`zlabel'"
		qui gen `xlabelpos' = `xlpos'
		qui gen `ylabelpos' = `ylpos'
		qui gen `zlabelpos' = `zlpos'

		/*rotation matrix*/
		/* x-axis */
		qui gen double `gx' = `x1'
		qui gen double `gy' = `y1'*cos(`xangle'*_pi/180)-`z1'*sin(`xangle'*_pi/180)
		qui gen double `gz' = `y1'*sin(`xangle'*_pi/180)+`z1'*cos(`xangle'*_pi/180)
		/* y-axis */
		qui replace `gx' = `gx'*cos(`yangle'*_pi/180)+`gz'*sin(`yangle'*_pi/180)
		qui replace `gy' = `gy'
		qui replace `gz' = -`gx'*sin(`yangle'*_pi/180)+`gz'*cos(`yangle'*_pi/180)
		/* z-axis */
		qui replace `gx' = `gx'*cos(`zangle'*_pi/180)-`gy'*sin(`zangle'*_pi/180)
		qui replace `gy' = `gx'*sin(`zangle'*_pi/180)+`gy'*cos(`zangle'*_pi/180)
		qui replace `gz' = `gz'
		qui su `x_coor' 
		local xlabel_max=string(r(max),"`format'")
		local xlabel_min=string(r(min),"`format'")
		qui su `y_coor'
		local ylabel_max=string(r(max),"`format'")
		local ylabel_min=string(r(min),"`format'")
		qui su `z_coor'
		local zlabel_max=string(r(max),"`format'")
		local zlabel_min=string(r(min),"`format'")  

		tempvar coordinate
		gen `coordinate'=0
		if "`coordinates'"!="false"{
			foreach coord of local coordinates{
				qui replace `coordinate'=1 if _n==`coord'
			}
		}
		qui gen  	`label' = "`xlabel_max', `ylabel_max', `zlabel_min'" if _n==1 & `coordinate'==1
		qui replace `label' = "`xlabel_max', `ylabel_max', `zlabel_max'" if _n==2 & `coordinate'==1
		qui replace `label' = "`xlabel_max', `ylabel_min', `zlabel_min'" if _n==3 & `coordinate'==1
		qui replace `label' = "`xlabel_max', `ylabel_min', `zlabel_max'" if _n==4 & `coordinate'==1
		qui replace `label' = "`xlabel_min', `ylabel_max', `zlabel_min'" if _n==5 & `coordinate'==1
		qui replace `label' = "`xlabel_min', `ylabel_max', `zlabel_max'" if _n==6 & `coordinate'==1
		qui replace `label' = "`xlabel_min', `ylabel_min', `zlabel_min'" if _n==7 & `coordinate'==1
		qui replace `label' = "`xlabel_min', `ylabel_min', `zlabel_max'" if _n==8 & `coordinate'==1
		
		qui gen int `pos' = 3 if _n==1
		qui replace `pos' = 9 if inlist(_n,3,5,7)
		qui replace `pos' = 9 if inlist(_n,2,4,6,8)
		
		local draw "`draw' (connected `gvar2' `gvar1' if _n==9 | _n==10, m(i) lc(ltbluishgray) lpattern(dash))"
		local draw "`draw' (connected `gvar2' `gvar1' if _n==9 | _n==11, m(i) lc(ltbluishgray) lpattern(dash)) "
		local draw "`draw' (connected `gvar2' `gvar1' if _n==10 | _n==12, m(i) lc(ltbluishgray) lpattern(dash)) "
		local draw "`draw' (connected `gvar2' `gvar1' if _n==11 | _n==12, m(i) lc(ltbluishgray) lpattern(dash)) "
		local draw "`draw' (connected `gvar2' `gvar1' if _n==13 | _n==14, m(i) lc(ltbluishgray) lpattern(dash)) "
		local draw "`draw' (connected `gvar2' `gvar1' if _n==13 | _n==15, m(i) lc(ltbluishgray) lpattern(dash)) "
		local draw "`draw' (connected `gvar2' `gvar1' if _n==14 | _n==16, m(i) lc(ltbluishgray) lpattern(dash)) "
		local draw "`draw' (connected `gvar2' `gvar1' if _n==15 | _n==16, m(i) lc(ltbluishgray) lpattern(dash)) "
		local draw "`draw' (connected `gvar2' `gvar1' if _n==17 | _n==18, m(i) lc(ltbluishgray) lpattern(dash))"
		local draw "`draw' (connected `gvar2' `gvar1' if _n==17 | _n==19, m(i) lc(ltbluishgray) lpattern(dash)) "
		local draw "`draw' (connected `gvar2' `gvar1' if _n==18 | _n==20, m(i) lc(ltbluishgray) lpattern(dash)) "
		local draw "`draw' (connected `gvar2' `gvar1' if _n==19 | _n==20, m(i) lc(ltbluishgray) lpattern(dash)) "
		local draw "`draw' (connected `gvar2' `gvar1' if _n==21 | _n==22, m(i) lc(ltbluishgray) lpattern(dash)) "
		local draw "`draw' (connected `gvar2' `gvar1' if _n==21 | _n==23, m(i) lc(ltbluishgray) lpattern(dash)) "
		local draw "`draw' (connected `gvar2' `gvar1' if _n==22 | _n==24, m(i) lc(ltbluishgray) lpattern(dash)) "
		local draw "`draw' (connected `gvar2' `gvar1' if _n==23 | _n==24, m(i) lc(ltbluishgray) lpattern(dash)) "
		local draw "`draw' (connected `gvar2' `gvar1' if _n==25 | _n==26, m(i) lc(ltbluishgray) lpattern(dash))"
		local draw "`draw' (connected `gvar2' `gvar1' if _n==25 | _n==27, m(i) lc(ltbluishgray) lpattern(dash)) "
		local draw "`draw' (connected `gvar2' `gvar1' if _n==26 | _n==28, m(i) lc(ltbluishgray) lpattern(dash)) "
		local draw "`draw' (connected `gvar2' `gvar1' if _n==27 | _n==28, m(i) lc(ltbluishgray) lpattern(dash)) "
		local draw "`draw' (connected `gvar2' `gvar1' if _n==29 | _n==30, m(i) lc(ltbluishgray) lpattern(dash)) "
		local draw "`draw' (connected `gvar2' `gvar1' if _n==29 | _n==31, m(i) lc(ltbluishgray) lpattern(dash)) "
		local draw "`draw' (connected `gvar2' `gvar1' if _n==30 | _n==32, m(i) lc(ltbluishgray) lpattern(dash)) "
		local draw "`draw' (connected `gvar2' `gvar1' if _n==31 | _n==32, m(i) lc(ltbluishgray) lpattern(dash)) "
		
		local draw "`draw' (connected `gvar2' `gvar1' if _n==9  | _n==13, m(i) lc(ltbluishgray) lpattern(dash)) "
		local draw "`draw' (connected `gvar2' `gvar1' if _n==12 | _n==16, m(i) lc(ltbluishgray) lpattern(dash)) "
		local draw "`draw' (connected `gvar2' `gvar1' if _n==11 | _n==15, m(i) lc(ltbluishgray) lpattern(dash)) "
		local draw "`draw' (connected `gvar2' `gvar1' if _n==10 | _n==14, m(i) lc(ltbluishgray) lpattern(dash)) "

		
		local draw "`draw' (connected `gvar2' `gvar1' if _n==17 | _n==21, m(i) lc(ltbluishgray) lpattern(dash)) "
		local draw "`draw' (connected `gvar2' `gvar1' if _n==20 | _n==24, m(i) lc(ltbluishgray) lpattern(dash)) "
		local draw "`draw' (connected `gvar2' `gvar1' if _n==19 | _n==23, m(i) lc(ltbluishgray) lpattern(dash)) "
		local draw "`draw' (connected `gvar2' `gvar1' if _n==18 | _n==22, m(i) lc(ltbluishgray) lpattern(dash)) "
		
		local draw "`draw' (connected `gvar2' `gvar1' if _n==25 | _n==29, m(i) lc(ltbluishgray) lpattern(dash)) "
		local draw "`draw' (connected `gvar2' `gvar1' if _n==28 | _n==32, m(i) lc(ltbluishgray) lpattern(dash)) "
		local draw "`draw' (connected `gvar2' `gvar1' if _n==27 | _n==31, m(i) lc(ltbluishgray) lpattern(dash)) "
		local draw "`draw' (connected `gvar2' `gvar1' if _n==26 | _n==30, m(i) lc(ltbluishgray) lpattern(dash)) "

		local draw "`draw' (connected `gvar2' `gvar1' if _n==1 , mlabgap(*3) m(i) mlabsize(medium) mlabcolor(black) mlabel(`xlab') mlabv(`xlabelpos') mlabangle(`xlangle') m(i) lc(ltbluishgray) lpattern(dash)) "
		local draw "`draw' (connected `gvar2' `gvar1' if _n==5,  mlabgap(*3) m(i) mlabsize(medium) mlabcolor(black) mlabel(`zlab') mlabv(`zlabelpos') mlabangle(`zlangle') m(i) lc(ltbluishgray) lpattern(dash)) "
		local draw "`draw' (connected `gvar2' `gvar1' if _n==7 , mlabgap(*3) m(i) mlabsize(medium) mlabcolor(black) mlabel(`ylab') mlabv(`ylabelpos') mlabangle(`ylangle') m(i) lc(ltbluishgray) lpattern(dash)) "

		/*coordinates*/
		local draw "`draw' (connected `gvar2' `gvar1' if _n==1 | _n==2, `mlc' mlabel(`label') mlabv(`pos') lc(edkblue))"
		local draw "`draw' (connected `gvar2' `gvar1' if _n==1 | _n==3, `mlc' mlabel(`label') mlabv(`pos') lc(edkblue)) "
		local draw "`draw' (connected `gvar2' `gvar1' if _n==2 | _n==4, `mlc' mlabel(`label') mlabv(`pos') lc(edkblue)) "
		local draw "`draw' (connected `gvar2' `gvar1' if _n==3 | _n==4, `mlc' mlabel(`label') mlabv(`pos') lc(edkblue)) "
		local draw "`draw' (connected `gvar2' `gvar1' if _n==5 | _n==6, `mlc' mlabel(`label') mlabv(`pos') lc(edkblue)) "
		local draw "`draw' (connected `gvar2' `gvar1' if _n==5 | _n==7, `mlc' mlabel(`label') mlabv(`pos') lc(edkblue)) "
		local draw "`draw' (connected `gvar2' `gvar1' if _n==6 | _n==8, `mlc' mlabel(`label') mlabv(`pos') lc(edkblue)) "
		local draw "`draw' (connected `gvar2' `gvar1' if _n==7 | _n==8, `mlc' mlabel(`label') mlabv(`pos') lc(edkblue)) "
		
		local draw "`draw' (connected `gvar2' `gvar1' if _n==1 | _n==5, `mlc' lc(edkblue)) "
		local draw "`draw' (connected `gvar2' `gvar1' if _n==4 | _n==8, `mlc' lc(edkblue)) "
		local draw "`draw' (connected `gvar2' `gvar1' if _n==3 | _n==7, `mlc' lc(edkblue)) "
		local draw "`draw' (connected `gvar2' `gvar1' if _n==2 | _n==6, `mlc' lc(edkblue)) "
	}	
	qui gen `sorter'=_n
	by `wdata', sort: gen `nvals' = _n ==1
	qui count if `nvals'==1
	local rnnvals=r(N)
	/*Markercolors and changing markerstyle*/
	if "`colors'"!="false" | "`mark'"=="true"{
		tempname Step Mstep
		local drawcolors ""
		local marker ""
		tempvar wstr
		qui gen `wstr'=string(`wdata')
		qui sum `wdata'
		local wmin=r(min)
		local wmax=r(max)
		local old_level=r(min)
		/*equidistance: colors according to position of w value in sample, 
		otherwise according to relative magnitude of w*/
		/*set starting colors and increments for color schemes*/
		if "`colors'"=="cr"{
			local red1 0
			local green1 255
			local blue1 255
			scalar `Step' = 255/`rnnvals'
		}
		if "`colors'"=="bcgyr"{
			local red1 0
			local green1 0
			local blue1 255
			
			tempname Bcgyr_step
			scalar `Bcgyr_step' = (`wmax'-`wmin')/4
			scalar `Step' = 255*4/`rnnvals'
			local count2=0
			local count3=0
			local count4=0
		}
		if "`colors'"=="fadetogrey" | "`colors'"=="fade" | "`colors'"=="50shadesofgrey" {
			local red1 51
			local green1 51
			local blue1 51
			scalar `Step' = (204-51)/`rnnvals'
		}
		if "`mark'"=="true"{
			if "`equidistance'"=="false"{
				scalar `Mstep' = (`wmax'-`wmin')/4
			}
			if "`equidistance'"=="true"{
				scalar `Mstep' = `rnnvals'/4
			}
		}	
		local ll ""
		qui levelsof `wdata', local(levels)
		local counter 0
		/*loop through all levels of w for markers and colors*/
		foreach l of local levels {
			local ll = string(`l')
			
			/* change marker style for different levels of w*/
			local m =`l'
			if "`mark'"=="true"{
				if "`equidistance'"=="false"{
					if `m'<=`wmin'+`Mstep' if `m' <=scalar(`Mstep') {
						local marker "smcircle"
					} 		
					if `wmin'+`Mstep'<`m' &`m'<=`wmin'+`Mstep'*2 {
						local marker "smdiamond"
					}
					if `wmin'+`Mstep'*2<`m' &`m'<=`wmin'+`Mstep'*3 {
						local marker "smsquare"
					}
					if `wmin'+`Mstep'*3<`m' &`m'<=`wmin'+`Mstep'*4 {
						local marker "smtriangle"
					}
				}
				if "`equidistance'"=="true"{
					if `counter'<=`rnnvals'/4 {
						local marker "smcircle"
					} 						
					if `counter'<=`rnnvals'/2 & `counter'>`rnnvals'/4 {
						local marker "smdiamond"
					}
					if `counter'<=3*`rnnvals'/4 & `counter'>`rnnvals'/2 {
						local marker "smsquare"
					}
					if `counter'>3*`rnnvals'/4 {
						local marker "smtriangle"
					}
				}
			}
			if `l'!=`wmin'{
				if "`colors'"=="cr"{
					if "`equidistance'"=="false"{
						local red1=`=`red1' + 255*(`l'-`old_level')/(`wmax'-`wmin')'
						local green1 `=`green1' - 255*(`l'-`old_level')/(`wmax'-`wmin')'
						local blue1 `=`blue1' - 255*(`l'-`old_level')/(`wmax'-`wmin')'
					}
					if "`equidistance'"=="true"{
						local red1 `=`red1' + scalar(`Step')'
						local green1 `=`green1' - scalar(`Step')'
						local blue1 `=`blue1' - scalar(`Step')'
					}
				}
				if "`colors'"=="bcgyr"{
					if "`equidistance'"=="false"{
						if `m'<=`wmin'+`Bcgyr_step'{
							local green1 `=`green1' + 4*255*(`l'-`old_level')/(`wmax'-`wmin')'
						}
						if `wmin'+`Bcgyr_step'<`m' &`m'<=`wmin'+`Bcgyr_step'*2{
							if `count2++'==0{
								local green1=255
								local blue1 `=`blue1' - 4*255*(`l'-(`wmin'+`Bcgyr_step'))/(`wmax'-`wmin')' 
							}
							else {
								local blue1 `=`blue1' - 4*255*(`l'-`old_level')/(`wmax'-`wmin')'
							}
						}
						if `wmin'+`Bcgyr_step'*2<`m' &`m'<=`wmin'+`Bcgyr_step'*3{
							if `count3++'==0{
								local blue1=0
								local red1 `=`red1' + 4*255*(`l'-(`wmin'+`Bcgyr_step'*2))/(`wmax'-`wmin')'
							}
							else{
								local red1 `=`red1' + 4*255*(`l'-`old_level')/(`wmax'-`wmin')'
							}
						}
						if `wmin'+`Bcgyr_step'*3<`m' &`m'<=`wmin'+`Bcgyr_step'*4{
							if `count4++'==0{
								local red1=255
								local green1 `=`green1' - 4*255*(`l'-(`wmin'+`Bcgyr_step'*3))/(`wmax'-`wmin')'
							}
							else{
								local green1 `=`green1' - 4*255*(`l'-`old_level')/(`wmax'-`wmin')'
							}
						}
					}
					if "`equidistance'"=="true"{
						if `counter'<=`rnnvals'/4{
							local green1 `=`green1' + scalar(`Step')'
						}
						if `counter'<=`rnnvals'/2 & `counter'>`rnnvals'/4 {
							if `count2++'==0{
								local green1=255
							}
							local blue1 `=`blue1' - scalar(`Step')'
						}
						if `counter'<=3*`rnnvals'/4 & `counter'>`rnnvals'/2{
							if `count3++'==0{
								local blue1=0
							}
							local red1 `=`red1' + scalar(`Step')'
						}
						if `counter'>3*`rnnvals'/4{
							if `count4++'==0{
								local red1=255
							}	
							local green1 `=`green1' - scalar(`Step')'
						}
					}
				}
				if "`colors'"=="fadetogrey" | "`colors'"=="fade" | "`colors'"=="50shadesofgrey" {
					if "`equidistance'"=="false" {
						local red1 `=`red1' + 204*(`l'-`old_level')/(`wmax'-`wmin')'
						local green1 `=`green1' + 204*(`l'-`old_level')/(`wmax'-`wmin')'
						local blue1 `=`blue1' + 204*(`l'-`old_level')/(`wmax'-`wmin')'
					}
					if "`equidistance'"=="true"{
						local red1 `=`red1' + scalar(`Step')'
						local green1 `=`green1' + scalar(`Step')'
						local blue1 `=`blue1' + scalar(`Step')'
					}	
				}
			}	
			if "`colors'"!="false"{
				local red `=int(`red1')'
				local green `=int(`green1')'
				local blue `=int(`blue1')' 
				local rgb "`red' `green' `blue'"
			}
			else {
				local rgb "0 0 0"
			}
			local drawcolors "`drawcolors' (scatter `var2' `var1' if `wstr'=="`ll'", m(`marker') mc("`rgb'") `markeroptions') "
			local old_level `l'
			local counter=`counter'+1
		}
		local draw "`draw' `drawcolors'"
	}
	if "`colors'"=="false" & "`mark'"=="false"{
		local draw "`draw' (scatter `var2' `var1', mc("0 0 0") `markeroptions')"
	}

	/*add the wires*/
	if "`wire'"=="true"{
		qui levelsof `x', local(levels)
		foreach l of local levels{
			local grlines "`grlines' (line `var2' `var1' if `x'==`l', lc(gs1))"
		}
		qui levelsof `z', local(levels)
		foreach l of local levels{
			local grlines "`grlines' (line `var2' `var1'  if `z'==`l', lc(gs1))"
		}
	}
	sort `sorter'
	tw  `draw' `grlines' /// 
	, aspect(`asratio') xlabel(-2(1)2, nogrid) ylabel(-2(1)2, nogrid) legend(off) yscale(off) xscale(off) plotr(c(none)) graphregion(color(white))
end

pr _move_scale_rotate
	args var1 var2 var3 xmove ymove zmove scale xangle yangle zangle xpiv ypiv zpiv persp xcam ycam zcam x y z 
	tempvar xoffset yoffset zoffset zx zy yx yz xy xz z1

	qui gen double `xoffset' = 0
	qui gen double `yoffset' = 0
	qui gen double `zoffset' = 0
	qui gen double `zx' = 0
	qui gen double `zy' = 0
	qui gen double `yx' = 0
	qui gen double `yz' = 0
	qui gen double `xy' = 0 
	qui gen double `xz' = 0 
	qui gen double `z1' = 0
	tempvar xd yd zd
	qui {
		gen double `xd'=.
		gen double `yd'=.
		gen double `zd'=.
	}
	qui replace `xd' = `x'-`xpiv' 
	qui replace `yd' = `y'-`ypiv' 
	qui replace `zd' = `z'-`zpiv' 
	qui replace `zx' = `xd'*cos(`zangle'*_pi/180) - `yd'*sin(`zangle'*_pi/180) - `xd' 
	qui replace `zy' = `xd'*sin(`zangle'*_pi/180) + `yd'*cos(`zangle'*_pi/180) - `yd' 
	qui replace `yx' = (`xd'+`zx')*cos(`yangle'*_pi/180) - `zd'*sin(`yangle'*_pi/180) - (`xd'+`zx') 
	qui replace `yz' = (`xd'+`zx')*sin(`yangle'*_pi/180) + `zd'*cos(`yangle'*_pi/180) - `zd' 
	qui replace `xy' = (`yd'+`zy')*cos(`xangle'*_pi/180) - (`zd'+`yz')*sin(`xangle'*_pi/180) - (`yd'+`zy') 
	qui replace `xz' = (`yd'+`zy')*sin(`zangle'*_pi/180) + (`zd'+`yz')*cos(`xangle'*_pi/180) - (`zd'+`yz') 
	qui replace `xoffset' = `yx'+`zx'
	qui replace `yoffset' = `zy'+`xy'
	qui replace `zoffset' = `xz'+`yz'

	if "`persp'" == "false" {
		qui replace `var2' = (`y' + `yoffset'- `ycam')/`scale'+`ymove' 
		qui replace `var1' = (`x' + `xoffset'+ `xcam')/`scale'+`xmove' 
	}
	if "`persp'" == "true" {
		qui replace `z1' = `z' + `zoffset' + `zcam'
		qui replace `var3' = (`z' + `zoffset'+ `zcam')/`scale'+`zmove'
		qui replace `var2' = (`y' + `yoffset'- `ycam')/`z1'/`scale'+`ymove' 
		qui replace `var1' = (`x' + `xoffset'+ `xcam')/`z1'/`scale'+`xmove' 
	}
end

/*End of file*/
