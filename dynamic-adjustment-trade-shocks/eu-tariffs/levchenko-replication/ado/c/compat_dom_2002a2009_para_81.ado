************************************************************
**************compat_dom_2002a2009_para_81.ado**************
************************************************************

program define compat_dom_2002a2009_para_81

/* A. ACERTA CÓDIGO DOS ESTADOS */
* AGREGA TOCANTINS COM GOIÁS

/* A.1 NA VARIÁVEL UF E CRIA VARIÁVEL DE REGIÃO */
destring uf, replace
recode uf (17=52)
gen regiao = int(uf/10)
label var regiao "região"
tostring uf, replace

/* B. NÚMERO DE CONTROLE E SÉRIE */
drop v0102 v0103

/* C. RECODE E RENAME DAS VARIÁVEIS */

/* C.0 RECODE: ANO */
rename v0101 ano
label var ano "ano da pesquisa"

/* C.1 DUMMY: ZONA URBANA */
recode v4105 (1 2 3=1) (4 5 6 7 8=0)
rename v4105 urbana
label var urbana "área urbana"

/* C.2 AREA CENSITARIA  */
rename v4107 area_censit

/* C.3 RECODE: PESOS */
* ENTRE 92 E 2001, "-1" PARECE SER == MISSING 
recode v4611 (-1=.)
rename v4611 peso

/* C.4 RECODE: TOTAL DE PESSOAS, TOTAL DE PESSOAS 10 ANOS OU MAIS E 5 ANOS OU MAIS */
* ENTRE 92 E 2001, "-1" PARECE SER == MISSING
recode v0105 (-1=.)
recode v0106 (-1=.)
rename v0105 tot_pess
rename v0106 tot_pess_10_mais

/* C.5 RENAME: ESPÉCIE DE DOMICÍLIO */
rename v0201 especie_dom

/* C.6 RENAME: TIPO DE DOMICÍLIO */
rename v0202 tipo_dom

/* C.7 RECODE: PAREDE */
recode v0203 (6=5) (9=.)
rename v0203 parede

/* C.8 RECODE: COBERTURA */
recode v0204 (7=6) (9=.)
rename v0204 cobertura

/* C.9 DUMMY: ABAST ÁGUA */
recode v0212 (2=1) (4 6=0) (9=.)
rename v0212 agua_rede 
replace agua_rede = 1 if v0213==1
replace agua_rede = 0 if v0213==3
label var agua_rede "água provém de rede"
* agua_rede - 1 rede
*			- 0 outra

/* C.10 RECODE: ESGOTO */
recode v0217 (1=0) (3=2) (5 7=6) (9=.)
rename v0217 esgoto
* esgoto = 0 rede geral
*        = 2 fossa séptica 
*        = 4 fossa rudimentar
*        = 6 outra

/* C.11 SANITÁRIO */

* C.11.1 DUMMY: EXISTE SANITÁRIO
recode v0215 (3=0) (9=.)
rename v0215 sanit
label var sanit "possui sanitario"
* sanitary 	- 1 possui
*			- 0 nao possui

/* C.11.2 DUMMY: SANITÁRIO EXCLUSIVO */
recode v0216 (2=1) (4=0) (9=.)
rename v0216 sanit_excl
label var sanit_excl "sanit excl do domicílio"

/* C.12 DUMMY: LIXO */
recode v0218 (2=1) (3/6=0) (9=.)
rename v0218 lixo
label var lixo "lixo é coletado"

/* C.13 DUMMY: ILUMINAÇÃO ELÉTRICA */
recode v0219 (3 5=0) (9=.)
rename v0219 ilum_eletr
label var ilum_eletr "possui ilum elétrica"

/* C.14 RECODE: NÚMERO DE CÔMODOS E DORMITÓRIOS */
recode v0205 (-1 99=.) 
rename v0205 comodos
recode v0206 (-1 99=.)
rename v0206 dormit

/* C.15 DUMMY: CONDIÇÃO DE OCUPAÇÃO */
recode v0207 (2 = 1) (3/6 = 0) (9 = .), gen(posse_dom)
label var posse_dom "posse do domicílio"
* posse_dom	- 1	proprio
*			- 0	alugado/cedido/outro
drop v0207

/* C.16 VALOR DO ALUGUEL/PRESTAÇÃO */
recode v0208 (-1=.) 
recode v0208 (999999999999=.)
recode v0208 (999999999998=.)
recode v0208 (888888888888=.)
recode v0209 (-1=.) 
recode v0209 (999999999999=.)
recode v0209 (999999999998=.)
recode v0209 (888888888888=.)
rename v0208 aluguel
rename v0209 prestacao 

/* C.17 DUMMY: FILTRO */
recode v0224 (2=1) (4=0) (9=.)
rename v0224 filtro

/* C.18 DUMMY: FOGÃO */
recode v0221 (3=0) (9=.)
recode v0222 (2=1) (4=0) (9=.)
gen fogao = 1 if v0221 == 1 | v0222 == 1
replace fogao = 0 if v0221 == 0 & v0222 == 0
replace fogao = . if v0221 == . & v0222 == .
label var fogao "possui fogao"
drop v0221 v0222

/* C.19 DUMMY: GELADEIRA */
recode v0228 (2 4=1) (6=0) (9=.)
rename v0228 geladeira

/* C.20 DUMMY: RÁDIO */
recode v0225 (3=0) (9=.)
rename v0225 radio

/* C.21 DUMMY: TELEVISÃO */
recode v0226 (2=1) (4=0) (9=.)
recode v0227 (3=0) (9=.)
gen tv = 1 if v0226 == 1 | v0227 == 1
replace tv = 0 if v0226 == 0 & v0227 == 0
replace tv = . if v0226 == . & v0227 == .
label var tv "possui televisão"
drop v0226 v0227

/* C.22 VALOR DA RENDA DOMICILIAR */
replace v4614 = . if v4614>=999999999
rename v4614 renda_domB 

/* C.23 OUTROS */
drop v0220

sum ano
if r(mean)==2003 rename v4615 UPA 
					

/* D. KEEPING */
order ano regiao uf id_dom urbana area_censit tot_pess tot_pess_10_mais especie_dom ///
	tipo_dom parede cobertura agua_rede esgoto sanit_excl lixo ilum_eletr comodos dormit ///
		sanit posse_dom filtro fogao geladeira radio tv renda_domB peso aluguel prestacao

keep ano-prestacao
compress


/* D. DEFLACIONANDO E CONVERTENDO UNIDADES MONETÁRIAS PARA REAIS */

/* CONVERTENDO OS VALORES NOMINAIS PARA REAIS (UNIDADE MONETÁRIA) */
/* 	E DEFLACIONANDO : 1 = out/2012                                */
gen double deflator = 1  if ano == 2012
format deflator %26.25f
replace deflator    = 0.945350  if ano == 2011
replace deflator    = 0.841309  if ano == 2009
replace deflator    = 0.806540  if ano == 2008
replace deflator    = 0.752722  if ano == 2007
replace deflator    = 0.717917  if ano == 2006
replace deflator    = 0.698447  if ano == 2005
replace deflator    = 0.663870  if ano == 2004
replace deflator    = 0.627251  if ano == 2003
replace deflator    = 0.536898  if ano == 2002
replace deflator    = 1.056364  if ano == 2013
replace deflator    = 1.124668  if ano == 2014
replace deflator    = .  if ano == 2015


label var deflator "deflator - base:out/2012"

gen double conversor = 1

label var conversor "conversor de moedas"

foreach var in renda_domB aluguel prestacao {
	g `var'_def = (`var'/conversor)/deflator
	lab var `var'_def "`var' deflacionada"
}

end
