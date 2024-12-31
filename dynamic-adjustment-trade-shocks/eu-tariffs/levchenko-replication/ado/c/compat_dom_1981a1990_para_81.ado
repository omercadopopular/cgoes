************************************************************
**************compat_dom_1981a1990_para_81.ado**************
************************************************************

program define compat_dom_1981a1990_para_81

label var ano "ano da pesquisa"
lab var id_dom "identificador do domicílio"

/* CRIANDO VARIÁVEL TEMPORÁRIA PARA VERIFICAR PRESENÇA 
   DE ANOS NOS QUAIS EM VEZ DA VAR v0101 HAVIA AS
   VARIÁVEIS v0102 E v0103                          */
tempvar anos_v0102
gen byte `anos_v0102' = (ano==1983)|(ano==1990)

/* A. ACERTA CÓDIGO DOS ESTADOS */

/* A.1 NA VARIÁVEL UF E CRIA VARIÁVEL DE REGIÃO */
destring uf, replace
recode uf (11/14=33) (20/29=35) (30/31 37=41) (32=42) (33/35=43) ///
(41/42=31) (43=32) (51=21) (52=22) (53=23) (54=24) (55=25) ///
(56=26) (57=27) (58=28) (59/60=29) (61=53) (71=11) (72=12) ///
(73=13) (74=14) (75=15) (76=16) (81=50) (82=51) (83=52) 
gen regiao = int(uf/10)
label var regiao "região"
tostring uf, replace

/* C. RECODE E RENAME DAS VARIÁVEIS */

/* C.1 DUMMY: ZONA URBANA */
recode v0003 (5=0)
rename v0003 urbana
label var urbana "zona urbana"
* urbana = 1 urbana
*        = 0 rural

/* C.2 AREA CENSITARIA  */
rename v0005 area_censit

/* C.3 REPLACE: PESOS */
generate int peso =.
lab var peso "peso amostral"

quietly summ ano
* Verifica se há o ano de 1990,
* quando o peso era dado por v1091
loc max = r(max)
loc min = r(min)

if `max' == 1990 {
   replace peso = v1091 
   drop v1091 v1080						/* v1080 peso censo 1980 */
}

* Verifica se há anos da déc. de 80,
* quando o peso era dado por v9981
else {
   replace peso = v9981 
   drop v9981
}

/* C.4 RENAME: TOTAL DE PESSOAS E TOTAL DE PESSOAS +10 ANOS */
rename v0107 tot_pess
rename v0108 tot_pess_10_mais

/* C.5 RECODE: ESPÉCIE DE DOMICÍLIO */
recode v0201 (2=1) (4=3) (6=5) (9=.)
rename v0201 especie_dom
* especie_dom = 1 particular permanente
*             = 3 particular improvisado
*             = 5 coletivo

/* C.6 RECODE: TIPO DO DOMICÍLIO */
* A OPÇÃO "RÚSTICO" FOI SOMADA À "CASA", POIS PARECE SER A MELHOR SOLUÇÃO 
* AS PROPORÇÕES DE "APTO" E "COMODO" NÃO AUMENTAM EM 1992;
* AO CONTRÁRIO, ATÉ DIMINUEM.
recode v0202 (1 5=2) (3=4) (7=6) (9=.)
rename v0202 tipo_dom
* tipo_dom = 2 casa
*          = 4 apto.
*          = 6 cômodo

/* C.7 RECODE: PAREDES */
recode v0203 (0=1) (4=3) (6=4) (8=5) (9=.)
rename v0203 parede
* parede = 1 alvenaria
*        = 2 madeira aparelhada
*        = 3 taipa não revestida
*        = 4 madeira aproveitada
*        = 5 outra

/* C.8 RECODE: COBERTURA */
recode v0205 (0=2) (2=1) (6=3) (7=5) (8=6) (9=.)
rename v0205 cobertura
* cobertura = 1 telha
*           = 2 laje concreto
*           = 3 mad. apar.
*           = 4 zinco
*           = 5 mad. aprov.
*           = 6 outro

/* C.9 DUMMY: ABAST ÁGUA */
recode v0206 (4=1) (2 3 5 6=0) (9=.)
rename v0206 agua_rede
label var agua_rede "água provém de rede"
* agua_rede = 1 sim
*           = 0 não

/* C.10 RECODE: ESGOTO */
recode v0207 (8 9 =.)
replace v0207 = . if v0208>1
rename v0207 esgoto  
* esgoto = 0 rede geral
*        = 2 fossa séptica
*        = 4 fossa rudimentar
*        = 6 outro

/* C.11 SANITÁRIO */

* C.11.1 DUMMY: EXISTE SANITÁRIO
gen sanit = 1 if v0208 == 1 | v0208 == 3
replace sanit = 0 if v0208 == 5
replace sanit = . if v0208 == 9 
label var sanit "possui sanitário"
* sanit = 1 sim
*       = 0 não

* C.11.2 DUMMY: SANITÁRIO EXCLUSIVO
recode v0208 (3=0) (5 9=.)
rename v0208 sanit_excl
label var sanit_excl "sanit excl do domicílio"
* sanit_excl = 1 sim
*            = 0 não

/* C.12 DUMMY: LIXO */
recode v0209 (0=1) (2 4 6 8=0) (9=.)
rename v0209 lixo
label var lixo "lixo é coletado"
* lixo = 1 sim
*      = 0 não

/* C.13 DUMMY: ILUMINAÇÃO ELÉTRICA */
recode v0210 (3=0) (9=.)
rename v0210 ilum_eletr
label var ilum_eletr "possui iluminação elétrica"
* ilum_eletr = 1 sim
*            = 0 não

/* C.14 RECODE: NÚMERO DE CÔMODOS E DORMITÓRIOS */
recode v0211 (99=.)
recode v0231 (99=.)
rename v0211 comodos
rename v0231 dormit

/* C.15 DUMMY: CONDIÇÃO DE OCUPAÇÃO */
recode v0212 (0 2=1) (4 6 8=0) (9=.)
rename v0212 posse_dom
label var posse_dom "posse do domicílio"
* posse_dom = 1 sim
*           = 0 não

/* C.16 RECODE: ALUGUEL/PRESTAÇÃO */
replace v0213 = . if v0213>=888888 & (ano<=1984 | ano==1987 | ano==1988)
replace v0213 = . if v0213>=88000000 & (ano==1985 | ano==1986 | ano>=1989)

generate aluguel = v0213 if posse_dom == 0
lab var aluguel "aluguel pago"
generate prestacao = v0213 if posse_dom == 1
lab var prestacao "prestacao"
drop v0213

/* C.17 DUMMY: FILTRO */
recode v0214 (3=0) (9=.)
rename v0214 filtro
* filtro = 1 sim
*        = 0 não

/* C.18 DUMMY: FOGÃO */
recode v0215 (2=1) (4=0) (9=.)
rename v0215 fogao
* fogao = 1 sim
*       = 0 não

/* C.19 DUMMY: GELADEIRA */
recode v0216 (3=0) (9=.)
rename v0216 geladeira
* geladeira = 1 sim
*           = 0 não

tempvar rtv
g `rtv' = ano==1982 | ano==1988 | ano==1989 | ano==1990
qui sum `rtv'
loc max = r(max)

if `max' == 1 {
/* C.20 DUMMY: RÁDIO */
	recode v0217 (2=1) (4=0) (9=.)
	rename v0217 radio
	* radio = 1 sim
	*       = 0 não

/* C.21 DUMMY: TELEVISÃO */
	recode v0218 (3=0) (9=.)
	rename v0218 tv
	* tv = 1 sim
	*    = 0 não
}
if `max' == 0 {
	g radio = .
	g tv = .
	lab var radio "radio (nao existe p/alguns anos da década 1980)"
	lab var tv "TV (nao existe p/alguns anos da década 1980)"
}


/* C.22 RENAME: RENDA MENSAL DOMICILIAR */
recode v0410 (9999999=.) if ano <= 1984
recode v0410 (999999999=.) if ano >= 1985 
recode v0410 (999999998=.) if ano >= 1985 
rename v0410 renda_dom

/* C.23 OUTROS */
drop v0100 v0204 v0409

/* D. KEEPING */ 
order ano regiao uf id_dom urbana area_censit tot_pess tot_pess_10_mais especie_dom ///
	tipo_dom parede cobertura agua_rede esgoto sanit_excl lixo ilum_eletr comodos dormit ///
		sanit posse_dom filtro fogao geladeira radio tv renda_dom* peso aluguel prestacao

keep ano-prestacao id

compress


/* E. DEFLACIONANDO E CONVERTENDO UNIDADES MONETÁRIAS PARA REAIS */

/* CONVERTENDO OS VALORES NOMINAIS PARA REAIS (UNIDADE MONETÁRIA) */
/* 	E DEFLACIONANDO (OUT/2012)                                            */
gen double deflator = 0.807544/100000 if ano == 1990
format deflator %26.25f
replace deflator    = 0.269888/1000000 if ano == 1989
replace deflator    = 0.196307/10000000    	 	if ano == 1988
replace deflator    = 0.241162/100000000	   	if ano == 1987
replace deflator    = 0.602708/1000000000   	if ano == 1986
replace deflator    = 0.304402/1000000000	  	if ano == 1985
replace deflator    = 0.962506/10000000000   	if ano == 1984
replace deflator    = 0.330205/10000000000		if ano == 1983
replace deflator    = 0.133929/10000000000 		if ano == 1982
replace deflator    = 0.636330/100000000000		if ano == 1981

label var deflator "deflator - base: out/2012"
  
gen double conversor = 2750000       if ano >= 1989
replace conversor    = 2750000000    if ano >= 1986 & ano <= 1988
replace conversor    = 2750000000000 if ano <= 1985

label var conversor "conversor de moedas"

foreach valor in renda_dom renda_domB aluguel prestacao {
	g `valor'_def = (`valor'/conversor)/deflator
	lab var `valor'_def "`valor' deflacionada"
}

lab var renda_domB "renda domiciliar - compativel com 1992"

end
