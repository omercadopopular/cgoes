************************************************************
**************compat_dom_1992a2001_para_81.ado**************
************************************************************

program define compat_dom_1992a2001_para_81

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
recode v0101 (92=1992) (93=1993) (95=1995) (96=1996) (97=1997) (98=1998) (99=1999)
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
* NO ANO DE 2001 NÃO HÁ A VARIÁVEL TOTAL DE PESSOAS DE 10 ANOS OU MAIS,
* MAS TOTAL DE PESSOAS DE 5 ANOS OU MAIS
replace v0106 = . if ano==2001

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
drop v0207

/* C.16 VALOR DO ALUGUEL/PRESTAÇÃO */
recode v0208 v0209 (-1=.) 
recode v0208 v0209 (99999999/max=.)
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
cap drop v0220 
cap drop v2020

/* D. KEEPING */
order ano regiao uf id_dom urbana area_censit tot_pess tot_pess_10_mais especie_dom ///
	tipo_dom parede cobertura agua_rede esgoto sanit_excl lixo ilum_eletr comodos dormit ///
		sanit posse_dom filtro fogao geladeira radio tv renda_domB peso aluguel prestacao

keep ano-prestacao


compress


/* D. DEFLACIONANDO E CONVERTENDO UNIDADES MONETÁRIAS PARA REAIS */

/* CONVERTENDO OS VALORES NOMINAIS PARA REAIS (UNIDADE MONETÁRIA) */
/* 	E DEFLACIONANDO: 1 = out/2012                                 */

gen double deflator = 0.488438 if ano == 2001
format deflator %26.25f
replace deflator    = 0.425376 if ano == 1999
replace deflator    = 0.399657 if ano == 1998
replace deflator    = 0.387748 if ano == 1997
replace deflator    = 0.371635 if ano == 1996
replace deflator    = 0.330617 if ano == 1995
replace deflator    = 0.103168/10 if ano == 1993
replace deflator    = 0.498848/1000 if ano == 1992

label var deflator "deflator - base:out/2012"  

gen double conversor = 1             if ano >= 1995
replace conversor    = 2750          if ano == 1993
replace conversor    = 2750000       if ano == 1992

label var conversor "conversor de moedas"

foreach valor in renda_domB aluguel prestacao {
	g `valor'_def = (`valor'/conversor)/deflator
	lab var `valor'_def "`valor' deflacionada"
}

end
