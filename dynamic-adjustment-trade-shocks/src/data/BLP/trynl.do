* 
version 17
clear

capture log close
log using log/trynl.smcl, replace

global work "data/work/BLP"

use $work/resid_horz0.dta
gen byte horz = 0

local hmax = 10

forvalues h=1/`hmax' {
    append using $work/resid_horz`h'.dta
    replace horz = `h' if horz == .
}

forvalues h=0/`hmax' {
    gen double pD`h'tariff_1 = 0
    replace pD`h'tariff_1 = pDtariff_1 if horz==`h'
}

#delimit ;
nl (rDtrade_1 = -({theta}+1) * pDtariff_1 
	+({theta} - ({sigma}-1)) * (1 - {zeta})^(1 + 1) * pD0tariff_1 
	+({theta} - ({sigma}-1)) * (1 - {zeta})^(3 + 1) * pD1tariff_1 
	+({theta} - ({sigma}-1)) * (1 - {zeta})^(5 + 1) * pD2tariff_1 
	+({theta} - ({sigma}-1)) * (1 - {zeta})^(7 + 1) * pD3tariff_1 
	+({theta} - ({sigma}-1)) * (1 - {zeta})^(9 + 1) * pD4tariff_1 
	+({theta} - ({sigma}-1)) * (1 - {zeta})^(11 + 1) * pD5tariff_1 
	+({theta} - ({sigma}-1)) * (1 - {zeta})^(13 + 1) * pD6tariff_1 
	+({theta} - ({sigma}-1)) * (1 - {zeta})^(15 + 1) * pD7tariff_1 
	+({theta} - ({sigma}-1)) * (1 - {zeta})^(17 + 1) * pD8tariff_1 
	+({theta} - ({sigma}-1)) * (1 - {zeta})^(19 + 1) * pD9tariff_1 
	+({theta} - ({sigma}-1)) * (1 - {zeta})^(21 + 1) * pD10tariff_1 
	),
	variables(rDtrade_1 pDtariff_1
	pD0tariff_1 pD1tariff_1 pD2tariff_1
	pD3tariff_1 pD4tariff_1 pD5tariff_1
	pD6tariff_1 pD7tariff_1 pD8tariff_1
	pD9tariff_1 pD10tariff_1) 
	initial(theta 2 zeta 0.3 sigma 1.1);
#delimit cr


log close
