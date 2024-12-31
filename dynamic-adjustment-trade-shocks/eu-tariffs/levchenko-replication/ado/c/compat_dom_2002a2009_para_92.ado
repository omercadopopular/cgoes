************************************************************
**************compat_dom_2002a2009_para_92.ado**************
************************************************************

program define compat_dom_2002a2009_para_92

/* A. Ano */
* nada a fazer nesta variável nesta década

/* B. NÚMERO DE CONTROLE E SÉRIE */
drop v0102 v0103
destring uf, replace

/* C. NÚMERO DE MORADORES */
* nada a fazer nesta variável nesta década


/* D. TELEFONE */
* A partir de 2001, pergunta-se sobre telefone celular e fixo,
* diferentemente de anos anteriores, que só perguntava por 
* telefone.
g telefone = v0220
replace telefone = v2020 if telefone==.
recode telefone (2 =1) (4=0) (9=.)
* 1 = sim; 0 = nao
lab var telefone "has telephone"
drop v0220 v2020

/* RECODES */

/* NÚMERO DE CÔMODOS/DORMITÓRIOS */
recode v0205 v0206 (99 -1 =.)

/* VALOR DO ALUGUEL/PRESTAÇÃO */
replace v0208 = . if v0208>10^11
replace v0209 = . if v0209>10^11

/* RENDA MENSAL DOMICILIAR */
replace v4614 = . if v4614>10^11

/* PESOS */
* nada a fazer aqui

/* RECODES: IGNORADO PARA MISSING */
recode v0202 v0203 v0204 v0207 v0210 v0211 v0212 v0213 v0214 v0215 ///
	v0216 v0217 v0218 v0219 v0221 v0222 v0223 v0224 v0225 v0226 ///
	v0227 v0228 v0229 v0230 (9=.)

cap recode v2081 v2091 (9=.) 	// essas variáveis nao existem de 2007 em diante

/* DEFLACIONANDO E CONVERTENDO UNIDADES MONETÁRIAS PARA REAIS */

/* CONVERTENDO OS VALORES NOMINAIS PARA REAIS (UNIDADE MONETÁRIA) */
/* 	E DEFLACIONANDO : 1 = out/2012                                */
gen double deflator = 1  if v0101 == 2012
format deflator %26.25f

replace deflator = 	0.536842105	if v0101==	2002
replace deflator = 	0.627244582	if v0101==	2003
replace deflator = 	0.66377709	if v0101==	2004
replace deflator = 	0.698452012	if v0101==	2005
replace deflator = 	0.717894737	if v0101==	2006
replace deflator = 	0.752693498	if v0101==	2007
replace deflator = 	0.806439628	if v0101==	2008
replace deflator = 	0.84123839	if v0101==	2009
replace deflator = 	0.945263158	if v0101==	2011
replace deflator = 	1.056346749	if v0101==	2013
replace deflator = 	1.124582043	if v0101==	2014
replace deflator = 	1.238390093	if v0101==	2015



label var deflator "income deflator - reference: oct/2012"  

gen double conversor = 1

label var conversor "currency converter"

foreach valor in v0208 v0209 v4614 {
	g `valor'def = (`valor'/conversor)/deflator
	lab var `valor'def "`valor' deflated"
}


/* KEEPING */

order v0101 uf id_dom v0104 v0105 v0106 
	
foreach var in v2006 v2010 v2210 v2016 v2027 v0231 v0232 v2032 v4617 v4618 ///
	v4619 v4620 v4621 v4622 v4624 v9992 UPA {
	cap drop `var'
}

compress

end
