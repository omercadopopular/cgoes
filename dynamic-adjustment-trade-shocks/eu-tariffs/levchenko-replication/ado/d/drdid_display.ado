program adde, eclass
	ereturn `0'
end

program drdid_display, rclass
	syntax, bmatrix(name) vmatrix(name)
	tempname bb vv
	matrix `bb'=e(`bmatrix')
	matrix `vv'=e(`vmatrix')
	tempname lastreg
	capture:est store `lastreg'
    ereturn clear
	*matrix list `bb'
	*matrix list `vv'
    adde post `bb' `vv'
    _coef_table
	matrix rtb=r(table)
	qui:est restore `lastreg'
	return matrix table = rtb
end
