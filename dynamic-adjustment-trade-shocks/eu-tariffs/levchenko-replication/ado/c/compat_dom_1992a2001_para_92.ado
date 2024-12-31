************************************************************
**************compat_dom_1992a2001_para_92.ado**************
************************************************************

program define compat_dom_1992a2001_para_92


/* A. RECODE: ANO */
recode v0101 (92=1992) (93=1993) (95=1995) (96=1996) (97=1997) (98=1998) (99=1999)

/* B. NÚMERO DE CONTROLE E SÉRIE */
destring uf, replace
drop v0102 v0103

/* C. NÚMERO DE MORADORES */
* obs: para 2001, v0106 indica numero de moradores com 5 anos ou mais
* -1 deve ser missing
replace v0106=. if v0101==2001

recode v0105 v0106 (-1 =.)

/* D. TELEFONE */
* A partir de 2001, pergunta-se sobre telefone celular e fixo
* em contrapartida com anos anteriores, que só perguntava por 
* telefone.
qui sum v0101
local max = r(max)
local min = r(min)

g telefone = v0220
if `max'==2001 {
	replace telefone = 2 if v2020==2 & telefone>2
	replace telefone = 4 if v2020==4 & telefone>4
	replace telefone = 9 if v2020==9 & telefone>9
	drop v2020
}
drop v0220 
recode telefone (2 =1) (4=0) (9=.)
lab var telefone "tem telefone (de 2001 em diante, fixo ou celular)"
* 1 = sim; 0 = nao

/* RECODE */

/* NUMERO DE CÔMODOS/DORMITÓRIOS */
recode v0205 v0206 (99 -1 =.)

/* VALOR DO ALUGUEL/PRESTAÇÃO */
recode v0208 v0209 (-1 =.)
replace v0208 = . if v0208>10^11
replace v0209 = . if v0209>10^11

/* RENDA MENSAL DOMICILIAR */
recode v4614 (-1 =.)
replace v4614 = . if v4614>10^11

/* PESOS */
* ENTRE 92 E 2001, "-1" PARECE SER == MISSING 
recode v4611 (-1=.)

/* RECODES: IGNORADO PARA MISSING */
recode v0202 v0203 v0204 v0207 v2081 v2091 v0210 v0211 v0212 v0213 v0214 v0215 ///
	v0216 v0217 v0218 v0219 v0221 v0222 v0223 v0224 v0225 v0226 ///
	v0227 v0228 v0229 v0230 (9=.)

/* DEFLACIONANDO E CONVERTENDO UNIDADES MONETÁRIAS PARA REAIS */

/* CONVERTENDO OS VALORES NOMINAIS PARA REAIS (UNIDADE MONETÁRIA) */
/* 	E DEFLACIONANDO: 1 = out/2012                                 */

gen double deflator = 0.488438 if v0101 == 2001
format deflator %26.25f
replace deflator    = 0.425376 if v0101 == 1999
replace deflator    = 0.399657 if v0101 == 1998
replace deflator    = 0.387748 if v0101 == 1997
replace deflator    = 0.371635 if v0101 == 1996
replace deflator    = 0.330617 if v0101 == 1995
replace deflator    = 0.103168/10 if v0101 == 1993
replace deflator    = 0.498848/1000 if v0101 == 1992

label var deflator "deflator - base:out/2012"  

gen double conversor = 1             if v0101 >= 1995
replace conversor    = 2750          if v0101 == 1993
replace conversor    = 2750000       if v0101 == 1992

label var conversor "conversor de moedas"

foreach valor in v0208 v0209 v4614 {
	g `valor'def = (`valor'/conversor)/deflator
	lab var `valor'def "`valor' deflacionada"
}


/* E. KEEPING */

order v0101 uf id_dom v0104 v0105 v0106 v0201 v0202 v0203 v0204 v0205 ///
	v0206 v0207 v0208 v2081 v0209 v2091 v0210 v0211 v0212 v0213 v0214 v0215 ///
	v0216 v0217 v0218 v0219 telefone v0221 v0222 v0223 v0224 v0225 v0226 v0227 ///
	v0228 v0229 v0230 v4105 v4106 v4107 v4600 v4601 v4602 v4604 v4605 v4606 ///
	v4607 v4608 v4609 v4610 v4611 v4614 *def deflator conversor

keep v0101-conversor

compress

end
