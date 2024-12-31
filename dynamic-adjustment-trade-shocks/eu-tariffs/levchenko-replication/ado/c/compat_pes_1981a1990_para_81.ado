************************************************************
**************compat_pess_1981a1990_para_81.ado*************
************************************************************

program define compat_pes_1981a1990_para_81

/* CRIANDO VARI�VEL TEMPOR�RIA PARA VERIFICAR PRESEN�A 
   DE ANOS NOS QUAIS EM VEZ DA VAR v0101 HAVIA AS
   VARI�VEIS v0102 E v0103                          */

tempvar anos_v0102
gen byte `anos_v0102' = (ano==1983)|(ano==1990)

qui sum ano
if r(mean)==1981 drop v62* v63* v64* v65* v66* v0820 v76* v86* v96* v67* v68*
if r(mean)==1982 drop v6301 v6303-v6309 v64* v65* v66* v67* v68* v69* v71*
if r(mean)==1983 drop v2201 -v1638
if r(mean)==1984 drop v2301- v6125
if r(mean)==1985 drop v2301- v3108
if r(mean)==1986 drop v2202- v2920 
if r(mean)==1988 drop v2301- v3425 
if r(mean)==1989 drop v2401- v3804 					
if r(mean)==1990 drop v0810- v3804 					

cap drop v0102 v0103

/* A. ACERTA C�DIGO DOS ESTADOS */

destring uf, replace
recode uf (11/14=33) (20/29=35) (30/31 37=41) (32=42) (33/35=43) ///
(41/42=31) (43=32) (51=21) (52=22) (53=23) (54=24) (55=25) ///
(56=26) (57=27) (58=28) (59/60=29) (61=53) (71=11) (72=12) ///
(73=13) (74=14) (75=15) (76=16) (81=50) (82=51) (83=52) 
gen regiao = int(uf/10)
label var regiao "regi�o"
tostring uf, replace

/* B. N�MERO DE CONTROLE, S�RIE E ORDEM */
* variavel "ordem" criada no ado principal

/* C. RECODE E RENAME DAS VARI�VEIS */

/* C.1 DUMMY: ZONA URBANA */
recode v0003 (5=0)
rename v0003 urbana
label var urbana "zona urbana"
* urbana = 1 urbana
*        = 0 rural

/* C.2 DUMMY: REGI�O METROPOLITANA */
recode v0005 (2/3=0), g(metropol)
label var metropol "regi�o metropolitana"
* reg_metro = 1 regi�o metropolitana
*           = 0 n�o

rename v0005 area_censit

/* C.3 REPLACE: PESOS */
generate int peso =.
lab var peso "peso amostral"

quietly summ ano
loc min = r(min)
loc max = r(max)
* Verifica se h� o ano de 1990,
* quando o peso era dado por v3091
if `max' == 1990 {
   replace peso = v3091
   drop v3091
}

* Verifica se h� anos da d�c. de 80,
* quando o peso era dado por v9991
else {
   replace peso = v9991
   drop v9991
}

cap drop v9981 // peso do chefe dom

/* C.4 DUMMY: SEXO */
recode v0303 (3=0)
rename v0303 sexo
label var sexo "0-mulher 1-homem"
* sexo = 1 homem
*      = 0 mulher

/* C.5 DATA DE NASCIMENTO */
* O ano de nascimento reporta a idade quando a idade � presumida.
* Substituindo por missing.
recode v0310 (0/98=.) if v0309 == 20 | v0309 == 30

* Em alguns casos, o ano de nascimento e a idade est�o trocados.
gen x1 = v0310 if v0310 < 800
gen x2 = v0805 if v0805 > 800
replace v0310 = x2 if x1 ~= .
replace v0805 = x1 if x2 ~= .
drop x1 x2
recode v0310 (999=.)

* Acrescentando o 1 no ano de nascimento
* Pessoas com idade presumida n�o tem ano de nascimento
gen x1 = 1
egen ano_nasc = concat(x1 v0310) if v0310 ~= .
drop x1 v0310
destring ano_nasc, replace
label var ano_nasc "ano de nascimento"

recode v0308 (0 99=.) 
rename v0308 dia_nasc
* 0(zero) seria idade presumida, 99 sem declara��o

recode v0309 (20 30 99 =.)
rename v0309 mes_nasc
* 20 e 30 seriam idade presumida, 99 sem declara��o

/* C.6 RENAME: IDADE */
rename v0805 idade

/* C.7 RENAME: CONDI��O NO DOMIC�LIO */
rename v0305 cond_dom
label var cond_dom "condi��o no domic�lio"
* cond_dom = 1 chefe
*          = 2 c�njuge
*          = 3 filho
*          = 4 outro parente
*          = 5 agregado
*          = 6 pensionista
*          = 7 empregado dom�stico
*          = 8 parente do empregado dom�stico

/* C.8 RENAME: CONDI��O NA FAM�LIA */
rename v0306 cond_fam
label var cond_fam "condi��o na fam�lia"
* cond_fam = 1 chefe
*          = 2 c�njuge
*          = 3 filho
*          = 4 outro parente
*          = 5 agregado
*          = 6 pensionista
*          = 7 empregado dom�stico
*          = 8 parente do empregado dom�stico

/* C.9 RENAME: N�MERO DA FAM�LIA */
rename v0307 num_fam
rename v9329 num_pes_fam


/* C.10 RECODE: COR OU RA�A */
* obs: em 1984, esta vari�vel n�o existe para todas as pessoas

g cor = .
tempvar ano_cor
g `ano_cor' = ano
qui sum `ano_cor'
loc min = r(min)
if `min'==1982 {
	replace cor = 2 if v6302==1
	replace cor = 4 if v6302==3
	replace cor = 6 if v6302==7
	replace cor = 8 if v6302==5
	replace `ano_cor' = . if ano==`min'
	drop v6302
}
if `min'==1986 {
	replace cor = 2 if v2201==2
	replace cor = 4 if v2201==4
	replace cor = 6 if v2201==8
	replace cor = 8 if v2201==6
	replace `ano_cor' = . if ano==`min'
	drop v2201
}
if `min'>1986 & `min'~=. {
	replace cor = 2 if v0304==2
	replace cor = 4 if v0304==4
	replace cor = 6 if v0304==8
	replace cor = 8 if v0304==6
}
label var cor "2-branca 4-preta 6-amarela 8-parda"

cap drop v0304
cap drop v2301

* cor = 2 branca
*     = 4 preta
*     = 6 amarela
*     = 8 parda
* A op��o "0 ind�gena" somente apareceu a partir de 92.


/* C.11 VARI�VEIS DE EDUCA��O */

/* C.11.1 RECODE: ANOS DE ESTUDO */
/* EDUCA��O */
/* VARI�VEIS UTILIZADAS */
/* v0314=QUAL E O CURSO QUE FREQUENTA? */
/* v0312=QUAL E A SERIE QUE FREQUENTA? */
/* v0317=QUAL FOI O CURSO MAIS ELEVADO QUE FREQUENTOU ANTERIORMENTE? */
/* v0315=ESTE CURSO QUE FREQUENTOU ANTERIORMENTE ERA SERIADO? */

/* pessoas que ainda freq�entam escola */
gen educa =0 if   v0314==1 & v0312==1
lab var educa "anos de escolaridade - compat�vel c/ anos 1980"

replace educa =1 if   v0314==1 & v0312==2
replace educa =2 if   v0314==1 & v0312==3
replace educa =3 if   v0314==1 & v0312==4

replace educa =4 if   v0314==2 & v0312==1
replace educa =5 if   v0314==2 & v0312==2
replace educa =6 if   v0314==2 & v0312==3
replace educa =7 if   v0314==2 & v0312==4

replace educa =8 if   v0314==3 &  v0312==1
replace educa =9 if   v0314==3 &  v0312==2
replace educa =10 if   v0314==3 &  v0312==3

replace educa =0 if   v0314==4 & v0312==1
replace educa =1 if   v0314==4 & v0312==2
replace educa =2 if   v0314==4 & v0312==3
replace educa =3 if   v0314==4 & v0312==4
replace educa =4 if   v0314==4 & v0312==5
replace educa =5 if   v0314==4 & v0312==6
replace educa =6 if   v0314==4 & v0312==7
replace educa =7 if   v0314==4 & v0312==8 

replace educa =8 if   v0314==5 &  v0312==1
replace educa =9 if   v0314==5 &  v0312==2
replace educa =10 if   v0314==5 &  v0312==3
replace educa =11 if   v0314==5 &  v0312==4

replace educa =11 if   v0314==6 & v0312==1
replace educa =12 if   v0314==6 & v0312==2
replace educa =13 if   v0314==6 & v0312==3
replace educa =14 if   v0314==6 & v0312==4
replace educa =15 if   v0314==6 & v0312==5
replace educa =16 if   v0314==6 & v0312==6

replace educa =0 if   v0314==7  

replace educa =0 if   v0314==8

replace educa =0 if   v0314==9 &  v0312==1
replace educa =1 if   v0314==9 &  v0312==2
replace educa =2 if   v0314==9 &  v0312==3
replace educa =3 if   v0314==9 &  v0312==4
replace educa =4 if   v0314==9 &  v0312==5
replace educa =5 if   v0314==9 &  v0312==6
replace educa =6 if   v0314==9 &  v0312==7
replace educa =7 if   v0314==9 &  v0312==8

replace educa =8 if   v0314==10 &  v0312==1
replace educa =9 if   v0314==10 &  v0312==2
replace educa =10 if   v0314==10 &  v0312==3

replace educa =0 if   v0314==11 &  v0312==1
replace educa =1 if   v0314==11 &  v0312==2
replace educa =2 if   v0314==11 &  v0312==3
replace educa =3 if   v0314==11 &  v0312==4
replace educa =4 if   v0314==11 &  v0312==5
replace educa =5 if   v0314==11 &  v0312==6
replace educa =6 if   v0314==11 &  v0312==7
replace educa =7 if   v0314==11 &  v0312==8

replace educa =8 if   v0314==12 &  v0312==1
replace educa =9 if   v0314==12 &  v0312==2
replace educa =10 if   v0314==12 &  v0312==3

replace educa =11 if   v0314==14 

replace educa =15 if   v0314==15

/* pessoas que n�o freq�entam */
replace educa =1 if   v0317==1 & v0315==1
replace educa =2 if   v0317==1 & v0315==2
replace educa =3 if   v0317==1 & v0315==3
replace educa =4 if   v0317==1 & v0315==4
replace educa =4 if   v0317==1 & v0315==5

replace educa =5 if   v0317==2 & v0315==1 
replace educa =6 if   v0317==2 & v0315==2 
replace educa =7 if   v0317==2 & v0315==3 
replace educa =8 if   v0317==2 & v0315==4 
replace educa =8 if   v0317==2 & v0315==5 

replace educa =9 if   v0317==3 & v0315==1 
replace educa =10 if   v0317==3 & v0315==2 
replace educa =11 if   v0317==3 & v0315==3 
replace educa =11 if   v0317==3 & v0315==4 

replace educa =1 if   v0317==4 & v0315==1 
replace educa =2 if   v0317==4 & v0315==2 
replace educa =3 if   v0317==4 & v0315==3 
replace educa =4 if   v0317==4 & v0315==4 
replace educa =5 if   v0317==4 & v0315==5 
replace educa =6 if   v0317==4 & v0315==6 
replace educa =7 if   v0317==4 & v0315==7 
replace educa =8 if   v0317==4 & v0315==8 

replace educa =9 if   v0317==5 & v0315==1 
replace educa =10 if   v0317==5 & v0315==2 
replace educa =11 if   v0317==5 & v0315==3 
replace educa =11 if   v0317==5 & v0315==4 

replace educa =12 if   v0317==6 & v0315==1
replace educa =13 if   v0317==6 & v0315==2
replace educa =14 if   v0317==6 & v0315==3
replace educa =15 if   v0317==6 & v0315==4
replace educa =16 if   v0317==6 & v0315==5
replace educa =17 if   v0317==6 & v0315==6

replace educa =17 if   v0317==7 
replace educa =0 if   v0312==0 & v0314==0 & v0315==0 & v0317==0

lab var educa "anos de estudo - compat�vel c/ anos 1980"

drop v0318

/* C.11.2 RENAME: FREQUENTA ESCOLA */
gen freq_escola = 1 if (v0312>=1 & v0312<=8) | (v0314>=1 & v0314<=15)
recode freq_escola (.=-1) if v0312==. & v0314==.
recode freq_escola (.=0)
recode freq_escola (-1=.)
label var freq_escola "0-n�o freq 1-frequenta"
* freq_escola = 1 se frequenta alguma s�rie ou algum grau
*             = 0 caso contr�rio

/* C.11.3 DUMMY: LER E ESCREVER */
recode v0311 (3=0) (9=.)
rename v0311 ler_escrever
* ler_escrever = 1 sim
*              = 0 n�o

/* C.11.4 RECODE: S�RIE QUE FREQ�ENTA NA ESCOLA */
recode v0312 (0 9=.)
recode v0312 (1=5) (2=6) (3=7) (4=8) if v0314 == 2
rename v0312 serie_freq
* A partir de 92, a pergunta inclui se frequenta creche.

/* C.11.5 RECODE: GRAU QUE FREQ�ENTA NA ESCOLA */
recode v0314 (0 13 99=.) 
recode v0314 (2 4=1) (3 5=2) (6=5) (8=6) (9 11=3) (10 12=4) (14=8) (15=9) 
rename v0314 grau_freq
* grau_freq = 1 regular primeiro grau
*           = 2 regular segundo grau
*           = 3 supl primeiro grau
*           = 4 supl segundo grau
*           = 5 superior
*           = 6 alfab de adultos
*           = 7 pr�-escolar ou creche
*           = 8 pr�-vestibular
*           = 9 mestrado/doutorado

/* C.11.6 RECODE: S�RIE - N�O FREQUENTA ESCOLA */
recode v0315 (0 9=.)
rename v0315 serie_nao_freq
* Observa��o: no prim�rio - v0317==1 - podem existir at� 6 s�ries, e n�o apenas 4.

/* C.11.7 RECODE: GRAU N�O FREQ�ENTA NA ESCOLA */
recode v0317 (0 99=.)
rename v0317 grau_nao_freq
* grau_nao_freq = 1 elementar (prim�rio)
*               = 2 m�dio primeiro ciclo (ginasial)
*               = 3 m�dio segundo ciclo (cient�fico, cl�ssico etc.)
*               = 4 primeiro grau
*               = 5 segundo grau
*               = 6 superior
*               = 7 mestrado/doutorado
*               = 8 alfab de adultos
*               = 9 pr�-escolar ou creche
* O c�digo 9 s� existe a partir de 1992.
* O c�digo 8 s� existe em 1981 e depois a partir de 1992.
* O dicion�rio de 1981 n�o explicita que 8 � alfab. de adultos;
* entretanto s� h� pessoas com mais de 16 anos nessa categoria e,
* al�m disso, s� t�m 1 ano de estudo.

drop v0319

/* C.12 CARACTER�STICAS DO TRABALHO PRINCIPAL NA SEMANA */
/* C.12.0 DUMMY: TRABALHOU NA SEMANA */
gen trabalhou_semana = 1 if v0501 == 1
replace trabalhou_semana = 0 if  v0501 >= 2 & v0501 <9  
label var trabalhou_semana "trabalhou na semana?"
* trabalhou_semana = 1 sim
*                  = 0 n�o

/* C.12.1 DUMMY: tinha TRABALHO NA SEMANA */
gen tinha_trab_sem = v0501 == 2 if trabalhou_semana==0
label var tinha_trab_sem "tinha trabalho na semana?"
* tinha_trab_sem = 1 sim
*               = 0 n�o

drop v0501


/* C.12.2 RENAME: OCUPA��O NA SEMANA */
rename v0503 ocup_sem
label var ocup_sem "ocupa��o na semana"

recode v5030 (9=.)
rename v5030 grupos_ocup_sem 
label var grupos_ocup_sem "occupation groups - week"
* grupos_ocup_sem = 1 t�cnica, cient�fica, art�stica e assemelhada
*             = 2 administrativa
*             = 3 agrop. e prod. extrat. vegetal e animal
*             = 4 ind. de transf.
*             = 5 com�rcio e ativ. auxiliares
*             = 6 transp. e comunica��o
*             = 7 presta��o de servi�os
*             = 8 outras ou n�o declaradas

/* C.12.3 RENAME: ATIVIDADE/RAMOS DO NEG�CIO */
* v0504 � mais desagregado - c�digos variam ao longo do tempo
* v5040 � mais agregado e comum entre os anos das PNAD's

rename v0504 ramo_negocio_sem
label var ramo_negocio_sem "ativ/ramo do neg�cio na semana"

rename v5040 ramo_negocio_agreg
label var ramo_negocio_agreg "ativ/ramo do neg�cio na semana - agregado"
* ramo_negocio_agreg = 1 agr�cola
*                    = 2 ind. transf.
*                    = 3 ind. constr.
*                    = 4 out. ativ. industr.
*                    = 5 com�rcio mercadorias
*                    = 6 presta��o de servi�os
*                    = 7 serv. aux. ativ. econom.
*                    = 8 transporte e comunica��o
*                    = 9 social
*                    = 10 administr. p�blica
*                    = 11 outras atividades ou n�o declarada


/* C.12.4 RECODE: POSI��O NA OCUPA��O NA SEMANA */
* v0505 � mais detalhado, mas de dif�cil compatibiliza��o com as PNAD's dos anos 90
* foi eliminada
drop v0505
* v5050 � mais agregado, mas tem correspondente nas PNAD's dos anos 90
recode v5050 (5=.) 
rename v5050 pos_ocup_sem
label var pos_ocup_sem "posi��o na ocupa��o na semana"
* pos_ocup_sem = 1 empregado 
*              = 2 conta pr�pria
*              = 3 empregador
*              = 4 n�o remunerado


/* C.12.5 RECODE: TEM CARTEIRA ASSINADA */
recode v0506 (2=1) (4=0) (9=.)
rename v0506 tem_carteira_assinada
label var tem_carteira_assinada "0-n�o 1-sim"
* tem_carteira_assinada = 0 n�o
*                       = 1 sim

/* NOS ANOS 80, NAS QUEST�ES SOBRE HORAS TRABALHADAS, RESPONDIA APENAS QUEM */
/* DECLARAVA tinha_trab_sem == 1                                             */

/* C.12.6 HORAS TRABALHADAS */

/* RENAME: HORAS NORMALMENTE TRABALHADAS SEMANA */
recode v0508 (99=.) (0=.)
rename v0508 horas_trab_sem 
label var horas_trab_sem "horas normal. trab. sem - ocup. princ"

/* RENAME: HORAS NORMALMENTE TRABALHADAS - OUTRO TRABALHO */
recode v0510 (99=.) (0=.)
rename v0510 horas_trab_sem_outro
label var horas_trab_sem_outro "work hours second job - week"

/* RENAME: HORAS NORMALMENTE TRABALHADAS TODOS TRABALHOS */
recode v5100 (999=.)
rename v5100 horas_trab_todos_trab
label var horas_trab_todos_trab "horas normal. trab sem - todos trabalhos"
cap drop v5101


/* C.13 - RENDIMENTOS */

/* C.13.1 RECODE: RENDA MENSAL EM DINHEIRO */
recode v0537 (9999999=.) if ano >= 1981 & ano <= 1984
recode v0537 (999999999=.) if ano >= 1985 & ano <= 1990
rename v0537 renda_mensal_din

/* C.13.2 RECODE: RENDA MENSAL EM PRODUTOS/MERCADORIAS */
recode v0538 (9999999=.) if ano >= 1981 & ano <= 1984
recode v0538 (999999999=.) if ano >= 1985 & ano <= 1990
rename v0538 renda_mensal_prod

/* C.13.3 RECODE: RENDA MENSAL EM DINHEIRO OUTRA */
recode v0549 (9999999=.) if ano >= 1981 & ano <= 1984
recode v0549 (999999999=.) if ano >= 1985 & ano <= 1990
rename v0549 renda_mensal_din_outra

/* C.13.4 RECODE: RENDA MENSAL EM PRODUTOS/MERCADORIAS OUTRA */
recode v0550 (9999999=.) if ano >= 1981 & ano <= 1984
recode v0550 (999999999=.) if ano >= 1985 & ano <= 1990
rename v0550 renda_mensal_prod_outra

/* C.13.5 RECODE: VALOR APOSENTADORIA */
recode v0578 (9999999=.) if ano >= 1981 & ano <= 1984
recode v0578 (999999999=.) if ano >= 1985 & ano <= 1990
rename v0578 renda_aposentadoria

/* C.13.6 RECODE: VALOR PENS�O */
recode v0579 (9999999=.) if ano >= 1981 & ano <= 1984
recode v0579 (999999999=.) if ano >= 1985 & ano <= 1990
rename v0579 renda_pensao

/* C.13.7 RECODE: VALOR ABONO PERMANENTE */
recode v0580 (9999999=.) if ano >= 1981 & ano <= 1984
recode v0580 (999999999=.) if ano >= 1985 & ano <= 1990
rename v0580 renda_abono

/* C.13.8 RECODE: VALOR ALUGUEL RECEBIDO */
recode v0581 (9999999=.) if ano >= 1981 & ano <= 1984
recode v0581 (999999999=.) if ano >= 1985 & ano <= 1990
rename v0581 renda_aluguel

/* C.13.9 RECODE: VALOR OUTRAS */
recode v0582 (9999999=.) if ano >= 1981 & ano <= 1984
recode v0582 (999999999=.) if ano >= 1985 & ano <= 1990
rename v0582 renda_outras

/* C.13.10 RECODE: REND MENSAL OCUP PRINCIPAL */
recode v0600 (9999999=.) if ano >= 1981 & ano <= 1984
recode v0600 (999999999=.) if ano >= 1985 & ano <= 1990
rename v0600 renda_mensal_ocup_prin

/* C.13.11 RECODE: REND MENSAL TODOS TRABALHOS */
recode v0601 (9999999=.) if ano >= 1981 & ano <= 1984
recode v0601 (999999999=.) if ano >= 1985 & ano <= 1990
rename v0601 renda_mensal_todos_trab

/* C.13.12 RECODE: REND MENSAL TODAS FONTES */
recode v0602 (9999999=.) if ano >= 1981 & ano <= 1984
recode v0602 (999999999=.) if ano >= 1985 & ano <= 1990
rename v0602 renda_mensal_todas_fontes

foreach name in v5070 v5071 v5072 v5090 v5091 v5092 v5093 {
	cap drop `name'
}

replace v5010 =. if v5010>=9999999
rename v5010 renda_mensal_fam

/* C.14.1 RECODE: CONTRIBUI INST. PREVID. */
recode v0511 (3=0) (9=.)
rename v0511 contr_inst_prev

/* C.14.2 RENAME: QUAL INST. PREVID. */
recode v0512 (9=.)
rename v0512 qual_inst_prev
* qual_inst_prev = 2 federal
*                = 4 estadual
*                = 6 municipal

/* C.15 RECODE: TINHA OUTRO TRABALHO? */
* Apenas para quem tinha trabalho na semana de refer�ncia
recode v0502 (3=0) (9=.)
rename v0502 tinha_outro_trab

/* C.16 PESSOAS QUE N�O TINHAM TRABALHO NA SEMANA DE REFER�NCIA               */
/*      MAS TIVERAM OCUPA��O NO PER�ODO DE 12 MESES ANTERIORES                */
* As quest�es sobre o trabalho anterior s�o pesquisadas, de 1981 a 90, para os
* indiv�duos que n�o tinham trabalho na semana de refer�ncia
* A partir da PNAD de 92, foram pesquisados tamb�m os indiv�duos empregados na semana
* de refer�ncia, mas cujo trabalho na sem de ref n�o era o principal do ano.
* Al�m disso desde 1992 s� foram pesquisados detalhes do trabalho anterior nos 358 dias
* anteriores � semana de refer�ncia.
* Assim, nos anos 80, foram mantidas as informa��es apenas para quem teve trabalho
* anterior nos �ltimos 12 meses.

/* RECODE: TEMPO SEM TRABALHO */
* Esta informa��o n�o pode mais ser aferida com precis�o a partir dos anos 90.
* Logo, as vari�veis abaixo ser�o usadas como auxiliares (v. se��o C.18.3) e ent�o eliminadas.
recode v0519 (99=.)
rename v0519 anos_nao_trab
recode v0569 (99=.)
rename v0569 meses_nao_trab

/* RECODE: TEMPO NA OCUPA��O ANTERIOR, NO ANO */
* A partir de 1992, esta informa��o n�o pode ser obtida para todos os indiv�duos.
drop v0523 v0573

/* INFORMA��ES SOBRE O EMPREGO ANTERIOR */
* COMO AQUI � SIMPLESMENTE O �LTIMO TRABALHO
* (DE QUEM N�O TRABALHOU NA SEMANA DE REFE�NCIA),
* ENQUANTO DE 92 EM DIANTE � O PRINCIPAL TRABALHO
* DO QUAL O INDIV�DUO SAIU NO ANO, AS INFORMA��ES
* SOBRE O TRABALHO ANTERIOR DOS ANOS 80 E 90 N�O
* S�O PERFEITAMENTE COMPAT�VEIS.

/* DUMMY: N�O TRABALHA E DEIXOU �LTIMO EMPREGO NO �LTIMO ANO - 12 MESES OU MENOS */
/* VARI�VEL TEMPOR�RIA                                                                    */
gen tag = 1 if tinha_trab_sem == 0 & anos_nao_trab == 0 & meses_nao_trab ~= .
replace tag = 1 if tinha_trab_sem == 0 & anos_nao_trab == 1 & meses_nao_trab == 0

/* C.16.1. GEN: OCUPA��O ANTERIOR, NO ANO */
gen ocup_ant_ano = v0520 if tag == 1
label var ocup_ant_ano "ocupa��o anterior - no ano"

/* C.16.2. GEN: RAMO ANTERIOR, NO ANO */
gen ramo_negocio_ant_ano = v0521 if tag == 1
label var ramo_negocio_ant_ano "ativ/ramo do neg�cio anterior - no ano"

/* C.16.3. RECODE: TINHA CARTEIRA ASSINADA NA OCUPA��O ANTERIOR, NO ANO */
recode v0525 (2=1) (4=0) (9=.) 
replace v0525 = . if tag ~= 1
rename v0525 tinha_cart_assin_ant_ano
label var tinha_cart_assin_ant_ano "�lt emprego - no ano - cart assin"

drop tag anos_nao_trab meses_nao_trab

/* C.18.3.6 RECODE: RECEBEU FGTS OCUPA��O ANTERIOR, NO ANO */
* ESSA PERGUNTA N�O CONSTA DAS PNAD'S DOS ANOS 90
drop v0526

/* C.17 RECODE: TOMOU PROV. PARA CONSEGUIR TRABALHO */
/* NA SEMANA DE REFER�NCIA: APENAS QUEM N�O TINHA TRABALHO NA SEMANA */
replace v0513=. if tinha_trab_sem == 1
recode v0513 (3=0) (9=.) 
rename v0513 tomou_prov_semana
* tomou_prov_semana = 1 sim
*                   = 0 n�o

/* C.18 RECODE: TOMOU PROV. CONSEGUIR PARA TRABALHO 2 MESES */
replace v0514=. if tinha_trab_sem == 1
recode v0514 (2=1) (4=0) (9=.)
rename v0514 tomou_prov_2meses
* tomou_prov_2meses = 1 sim
*                   = 0 n�o

/* C.19 RECODE: QUE PROV. TOMOU PARA CONSEGUIR TRABALHO */
recode v0515 (9=.)
rename v0515 que_prov_tomou
* que_prov_tomou = 1 consultou empregador
*                         = 2 fez concurso
*                         = 3 consultou ag�ncia/sindicato
*                         = 4 colocou an�ncio
*                         = 5 consultou parente
*                         = 6 outra
*                         = 7 nada fez

* As vari�veis sobre ocupa��o anterior
drop v0520 v0521 

drop v0516 v0566 v0517 v0518 v0522 v0524 v9330

/* D. DEFLACIONANDO E CONVERTENDO UNIDADES MONET�RIAS PARA REAIS */

/* CONVERTENDO OS VALORES NOMINAIS PARA REAIS (UNIDADE MONET�RIA) */
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

foreach i in din prod din_outra prod_outra ocup_prin todos_trab todas_fontes fam {
	g renda_`i'_def = (renda_mensal_`i'/conversor)/deflator 
	lab var renda_`i'_def "renda_mensal_`i' deflacionada"
}

foreach i in aposentadoria pensao abono aluguel outras {
	g renda_`i'_def = (renda_`i'/conversor)/deflator
	lab var renda_`i'_def "renda_`i' deflacionada"
}

order ano uf id_dom num_fam regiao urbana metropol area_censit peso ///
	sexo cond_dom cond_fam dia_nasc mes_nasc ano_nasc idade 

drop v0100
compress

end
