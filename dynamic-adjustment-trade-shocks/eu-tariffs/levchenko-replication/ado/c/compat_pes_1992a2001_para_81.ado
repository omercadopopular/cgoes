************************************************************
**************compat_pess_1992a2001_para_81.ado*************
************************************************************
program define compat_pes_1992a2001_para_81

/* C.0 RECODE: ANO */
recode v0101 (92=1992) (93=1993) (95=1995) (96=1996) (97=1997) (98=1998) (99=1999)
rename v0101 ano
label var ano "ano da pesquisa"

qui sum ano
if r(mean)==1993 | r(mean)==1995 drop v08* 
if r(mean)==1996 drop v1201-v1219 
if r(mean)==1998 drop v13* v14* v78* v79* 
if r(mean)==2001 drop v81* v15* v16* v22*

foreach var in v4725 v4726 v4732 v4738 v4741 v4742 v4743 v4838 v4788 v4785 v4776 v4739 v4740 v9993 {
	cap drop `var'
}

/* A. ACERTA C�DIGO DOS ESTADOS */
* AGREGA TOCANTINS COM GOI�S E CRIA VARI�VEL DE REGI�O */
destring uf, replace
recode uf (17=52)
gen regiao = int(uf/10)
label var regiao "regi�o"
tostring uf, replace

/* B. N�MERO DE CONTROLE, S�RIE E ORDEM */
rename v0301 ordem
drop v0102 v0103

/* C. RECODE E RENAME DAS VARI�VEIS */

/* C.1 DUMMY: ZONA URBANA */
recode v4728 (1 2 3=1) (4 5 6 7 8=0)
rename v4728 urbana
label var urbana "�rea urbana"
* urbana = 1 urbana
*        = 0 rural

/* C.2 DUMMY: REGI�O METROPOLITANA */
recode v4727 (2/3=0), g(metropol)
label var metropol "regi�o metropolitana"
* metropol = 1 regi�o metropolitana
*          = 0 n�o

rename v4727 area_censit

/* C.3 RENAME: PESOS */
rename v4729 peso

/* C.4 RECODE: SEXO */
recode v0302 (2=1) (4=0)
rename v0302 sexo
* sexo = 1 homem
*      = 0 mulher

/* C.5 DATA DE NASCIMENTO */
recode v3031 (0 99=.)
rename v3031 dia_nasc

recode v3032 (20 99=.)
rename v3032 mes_nasc

* O ano de nascimento reporta a idade quando a idade � presumida.
* Substitu�do por missing.
recode v3033 (0/98=.)
recode v3033 (999=.) if ano~=1999
* Se ano~=2001 Acrescentando o 1 no ano de nascimento
* Pessoas com idade presumida n�o tem ano de nascimento
sum ano
loc max = r(max)
loc min = r(min)
if `max'==2001 {
	replace v3033 =. if v3033==9999
	rename v3033 ano_nasc
}
else {
	gen x1 = 1
	egen ano_nasc = concat(x1 v3033) if v3033 ~= .
	destring ano_nasc, replace
	drop x1 v3033
}
label var ano_nasc "ano de nascimento"

/* C.6 RECODE: IDADE */
recode v8005 (999=.)
rename v8005 idade

/* C.7 RECODE: CONDI��O NO DOMIC�LIO */
rename v0401 cond_dom
label var cond_dom "1-chef 2-c�nj 3-filh 4-outr_parent 5-agreg 6-pens 7-empr_domes 8-parent_empr_dom"
* cond_dom = 1 chefe
*          = 2 c�njuge
*          = 3 filho
*          = 4 outro parente
*          = 5 agregado
*          = 6 pensionista
*          = 7 empregado dom�stico
*          = 8 parente do empregado dom�stico

/* C.8 RENAME: CONDI��O NA FAM�LIA */
rename v0402 cond_fam
label var cond_fam "1-chef 2-c�nj 3-filh 4-outr_parent 5-agreg 6-pens 7-empr_domes 8-parent_empr_dom"
* cond_fam = 1 chefe
*          = 2 c�njuge
*          = 3 filho
*          = 4 outro parente
*          = 5 agregado
*          = 6 pensionista
*          = 7 empregado dom�stico
*          = 8 parente do empregado dom�stico

/* C.9 RENAME: N�MERO DA FAM�LIA */
rename v0403 num_fam

/* C.10 RECODE: COR OU RA�A */
recode v0404 (9=.)
rename v0404 cor
label var cor "2-branca 4-preta 6-amarela 8-parda 0-ind�gena"
* cor = 2 branca
*     = 4 preta
*     = 6 amarela
*     = 8 parda
*     = 0 ind�gena
* A op��o "0 ind�gena" somente apareceu a partir de 92.

drop v0405 v0406 v0407 


/* C.11 VARI�VEIS DE EDUCA��O */

/* C.11.1 RECODE: ANOS DE ESTUDO */
/* VARI�VEIS UTILIZADAS */
/* v0602=FREQUENTA ESCOLA OU CRECHE? */
/* v0603=QUAL E O CURSO QUE FREQUENTA? */
/* v0604=ESTE CURSO QUE FREQUENTA E SERIADO? */
/* v0605=QUAL E A SERIE QUE FREQUENTA? */
/* v0606=ANTERIORMENTE FREQUENTOU ESCOLA OU CRECHE? */
/* v0607=QUAL FOI O CURSO MAIS ELEVADO QUE FREQUENTOU ANTERIORMENTE? */
/* v0608=ESTE CURSO QUE FREQUENTOU ANTERIORMENTE ERA SERIADO? */
/* v0609=CONCLUIU,COM APROVACAO,PELO MENOS A PRIMEIRA SERIE DESTE CURSO QUE FREQUENTOU ANTERIORMENTE? */
/* v0610=QUAL FOI A ULTIMA SERIE QUE CONCLUIU,COM APROVACAO,NESTE CURSO QUE FREQUENTOU ANTERIORMENTE? */
/* v0611=CONCLUIU ESTE CURSO QUE FREQUENTOU ANTERIORMENTE? */

* C�digo do grau ligeiramente diferente em 2001, devido � separa��o entre pr�-escolar e creche:
* 1992 a 99:                        2001:
* v0603                             v0603
* 7 = pr�-escolar ou creche         7 = creche
* 8 = pr�-vestibular                8 = pr�-escolar
* 9 = mestrado/doutorado            9 = pr�-vestibular
*                                   10 = mestrado/doutorado
* v0607                             v0607
* 9 = pr�-escolar ou creche		9 = creche
*                                   10 = pr�-escolar
* Homogeneizando:
recode v0603 (8=7) (9=8) (10=9) if ano == 2001
recode v0607 (10=9) if ano == 2001

/* pessoas que ainda freq�entam escola */
gen educa =0 if v0602==2 & v0603==1 & v0605==1
lab var educa "anos de estudo - compat�vel c/ anos 1980"
replace educa =1 if v0602==2 & v0603==1 & v0605==2
replace educa =2 if v0602==2 & v0603==1 & v0605==3
replace educa =3 if v0602==2 & v0603==1 & v0605==4
replace educa =4 if v0602==2 & v0603==1 & v0605==5
replace educa =5 if v0602==2 & v0603==1 & v0605==6
replace educa =6 if v0602==2 & v0603==1 & v0605==7
replace educa =7 if v0602==2 & v0603==1 & v0605==8

replace educa =8 if v0602==2 & v0603==2 & v0605==1
replace educa =9 if v0602==2 & v0603==2 & v0605==2
replace educa =10 if v0602==2 & v0603==2 & v0605==3
replace educa =11 if v0602==2 & v0603==2 & v0605==4

replace educa =0 if v0602==2 & v0603==3 & v0604==2 & v0605==1
replace educa =1 if v0602==2 & v0603==3 & v0604==2 & v0605==2
replace educa =2 if v0602==2 & v0603==3 & v0604==2 & v0605==3
replace educa =3 if v0602==2 & v0603==3 & v0604==2 & v0605==4
replace educa =4 if v0602==2 & v0603==3 & v0604==2 & v0605==5
replace educa =5 if v0602==2 & v0603==3 & v0604==2 & v0605==6
replace educa =6 if v0602==2 & v0603==3 & v0604==2 & v0605==7
replace educa =7 if v0602==2 & v0603==3 & v0604==2 & v0605==8

replace educa =0 if v0602==2 & v0603==3 & v0604==4 

replace educa =8 if v0602==2 & v0603==4 & v0604==2 & v0605==1
replace educa =9 if v0602==2 & v0603==4 & v0604==2 & v0605==2
replace educa =10 if v0602==2 & v0603==4 & v0604==2 & v0605==3
replace educa =11 if v0602==2 & v0603==4 & v0604==2 & v0605==4

replace educa =8 if v0602==2 & v0603==4 & v0604==4 

replace educa =11 if v0602==2 & v0603==5 & v0605==1
replace educa =12 if v0602==2 & v0603==5 & v0605==2
replace educa =13 if v0602==2 & v0603==5 & v0605==3
replace educa =14 if v0602==2 & v0603==5 & v0605==4
replace educa =15 if v0602==2 & v0603==5 & v0605==5
replace educa =16 if v0602==2 & v0603==5 & v0605==6

replace educa =0 if v0602==2 & v0603==6
replace educa =0 if v0602==2 & v0603==7
replace educa =11 if v0602==2 & v0603==8
replace educa =15 if v0602==2 & v0603==9

/* pessoas que n�o freq�entam */

replace educa =1 if v0602==4 & v0606==2 & v0607==1 & v0609==1 & v0610==1
replace educa =2 if v0602==4 & v0606==2 & v0607==1 & v0609==1 & v0610==2
replace educa =3 if v0602==4 & v0606==2 & v0607==1 & v0609==1 & v0610==3
replace educa =4 if v0602==4 & v0606==2 & v0607==1 & v0609==1 & v0610==4
replace educa =4 if v0602==4 & v0606==2 & v0607==1 & v0609==1 & v0610==5
replace educa =4 if v0602==4 & v0606==2 & v0607==1 & v0609==1 & v0610==6

replace educa =0 if v0602==4 & v0606==2 & v0607==1 & v0609==3

replace educa =5 if v0602==4 & v0606==2 & v0607==2 & v0608==2 & v0609==1 & v0610==1
replace educa =6 if v0602==4 & v0606==2 & v0607==2 & v0608==2 & v0609==1 & v0610==2
replace educa =7 if v0602==4 & v0606==2 & v0607==2 & v0608==2 & v0609==1 & v0610==3
replace educa =8 if v0602==4 & v0606==2 & v0607==2 & v0608==2 & v0609==1 & v0610==4
replace educa =8 if v0602==4 & v0606==2 & v0607==2 & v0608==2 & v0609==1 & v0610==5

replace educa =4 if v0602==4 & v0606==2 & v0607==2 & v0608==2 & v0609==3

replace educa =8 if v0602==4 & v0606==2 & v0607==2 & v0608==4 & v0611==1
replace educa =4 if v0602==4 & v0606==2 & v0607==2 & v0608==4 & v0611==3

replace educa =9 if v0602==4 & v0606==2 & v0607==3 & v0608==2 & v0609==1 & v0610==1
replace educa =10 if v0602==4 & v0606==2 & v0607==3 & v0608==2 & v0609==1 & v0610==2
replace educa =11 if v0602==4 & v0606==2 & v0607==3 & v0608==2 & v0609==1 & v0610==3
replace educa =11 if v0602==4 & v0606==2 & v0607==3 & v0608==2 & v0609==1 & v0610==4

replace educa =8 if v0602==4 & v0606==2 & v0607==3 & v0608==2 & v0609==3

replace educa =11 if v0602==4 & v0606==2 & v0607==3 & v0608==4 & v0611==1
replace educa =8 if v0602==4 & v0606==2 & v0607==3 & v0608==4 & v0611==3

replace educa =1 if v0602==4 & v0606==2 & v0607==4 & v0608==2 & v0609==1 & v0610==1
replace educa =2 if v0602==4 & v0606==2 & v0607==4 & v0608==2 & v0609==1 & v0610==2
replace educa =3 if v0602==4 & v0606==2 & v0607==4 & v0608==2 & v0609==1 & v0610==3
replace educa =4 if v0602==4 & v0606==2 & v0607==4 & v0608==2 & v0609==1 & v0610==4
replace educa =5 if v0602==4 & v0606==2 & v0607==4 & v0608==2 & v0609==1 & v0610==5
replace educa =6 if v0602==4 & v0606==2 & v0607==4 & v0608==2 & v0609==1 & v0610==6
replace educa =7 if v0602==4 & v0606==2 & v0607==4 & v0608==2 & v0609==1 & v0610==7
replace educa =8 if v0602==4 & v0606==2 & v0607==4 & v0608==2 & v0609==1 & v0610==8

replace educa =0 if v0602==4 & v0606==2 & v0607==4 & v0608==2 & v0609==3

replace educa =8 if v0602==4 & v0606==2 & v0607==4 & v0608==4 & v0611==1
replace educa =0 if v0602==4 & v0606==2 & v0607==4 & v0608==4 & v0611==3

replace educa =9 if v0602==4 & v0606==2 & v0607==5 & v0608==2 & v0609==1 & v0610==1
replace educa =10 if v0602==4 & v0606==2 & v0607==5 & v0608==2 & v0609==1 & v0610==2
replace educa =11 if v0602==4 & v0606==2 & v0607==5 & v0608==2 & v0609==1 & v0610==3
replace educa =11 if v0602==4 & v0606==2 & v0607==5 & v0608==2 & v0609==1 & v0610==4

replace educa =8 if v0602==4 & v0606==2 & v0607==5 & v0608==2 & v0609==3

replace educa =11 if v0602==4 & v0606==2 & v0607==5 & v0608==4 & v0611==1
replace educa =8 if v0602==4 & v0606==2 & v0607==5 & v0608==4 & v0611==3

replace educa =12 if v0602==4 & v0606==2 & v0607==6 & v0609==1 & v0610==1
replace educa =13 if v0602==4 & v0606==2 & v0607==6 & v0609==1 & v0610==2
replace educa =14 if v0602==4 & v0606==2 & v0607==6 & v0609==1 & v0610==3

replace educa =15 if v0602==4 & v0606==2 & v0607==6 & v0609==1 & v0610==4
replace educa =16 if v0602==4 & v0606==2 & v0607==6 & v0609==1 & v0610==5
replace educa =17 if v0602==4 & v0606==2 & v0607==6 & v0609==1 & v0610==6

replace educa =11 if v0602==4 & v0606==2 & v0607==6 & v0609==3

replace educa =17 if v0602==4 & v0606==2 & v0607==7 & v0611==1
replace educa =15 if v0602==4 & v0606==2 & v0607==7 & v0611==3

replace educa =0 if v0602==4 & v0606==2 & v0607==8
replace educa =0 if v0602==4 & v0606==2 & v0607==9

replace educa =0 if v0602==4 & v0606==4


/* C.11.2 RECODE: FREQUENTA ESCOLA */
recode v0602 (2=1) (4=0) (9=.)
rename v0602 freq_escola
label var freq_escola "0-n�o freq 1-frequenta"
* freq_escola = 1 se frequenta escola
*             = 0 caso contr�rio
* Desde 92, a pergunta inclui se frequenta creche.

/* C.11.3 DUMMY: LER E ESCREVER */
recode v0601 (3=0) (9=.)
rename v0601 ler_escrever
* ler_escrever = 1 sim
*              = 0 n�o

/* C.11.4 RECODE: S�RIE QUE FREQ�ENTA NA ESCOLA */
recode v0605 (9=.)
rename v0605 serie_freq
label var serie_freq "s�rie - frequenta escola"

/* C.11.5 RECODE: GRAU QUE FREQ�ENTA NA ESCOLA */
recode v0603 (0=.)
rename v0603 grau_freq
label var grau_freq "grau - frequenta escola"
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
recode v0610 (9=.)
rename v0610 serie_nao_freq
label var serie_nao_freq "s�rie - n�o frequenta escola"
* Observa��o: no prim�rio - v0607==1 - podem existir at� 6 s�ries, e n�o apenas 4.
*             no m�dio, primeiro ciclo - v0607==2 - at� 5 s�ries, n�o apenas 4.
*             no m�dio, segundo ciclo - v0607==3 - 4 s�ries, n�o apenas 3.
*             no segundo grau - v0607==5 - 4 s�ries, n�o apenas 3.

/* C.11.7 RECODE: GRAU N�O FREQ�ENTA NA ESCOLA */
recode v0607 (0=.) 
rename v0607 grau_nao_freq
label var grau_nao_freq "grau - n�o frequenta"
* grau_nao_freq = 1 elementar (prim�rio)
*               = 2 m�dio primeiro ciclo (ginasial)
*               = 3 m�dio segundo ciclo (cient�fico, cl�ssico etc.)
*               = 4 primeiro grau
*               = 5 segundo grau
*               = 6 superior
*               = 7 mestrado/doutorado
*               = 8 alfab de adultos
*               = 9 pr�-escolar ou creche
* Os c�digos 8 e 9 s� existem a partir de 1992.

drop v0604 v0606 v0608 v0609 v0611


/* C.12 CARACTER�STICAS DO TRABALHO PRINCIPAL NA SEMANA */

/* C.12.0 DUMMY: TRABALHOU NA SEMANA */
/* A partir de 1992, pergunta-se sobre trabalho na produ��o para o pr�prio 
consumo e trabalho na constru��o para o pr�prio uso. Por isso, a vari�vel a 
seguir n�o � perfeitamente compat�vel com a dos anos 1980 */
recode v9001 (0=.) (3=0), copy g(trabalhou_semana)
label var trabalhou_semana "trabalhou na semana?"
* trabalhou_semana = 1 sim
*               	= 0 n�o

/* C.12.1 DUMMY: tinha TRABALHO NA SEMANA */
* tinha trabalho na semana, mas estava afastado temporariamente (estava de f�rias etc.)
g tinha_trab_sem = 0 if trabalhou_semana==0
replace tinha_trab_sem = 1 if v9004 == 2 & ano<=1999
replace tinha_trab_sem = 1 if v9002 == 2 & ano==2001
label var tinha_trab_sem "tinha trabalho na semana?"
* tinha_trab_sem = 1 sim
*                = 0 n�o
drop v9001 v9004

/* C.12.2 RENAME: OCUPA��O NA SEMANA */
rename v9906 ocup_sem
label var ocup_sem "ocupa��o na semana"

generate grupos_ocup_sem =.
if `min' <= 1999 {
	recode v4710 (0=.)
	replace grupos_ocup_sem = v4710 if ano <= 1999
	drop v4710
}

if `max' == 2001 {
	recode v4760 (0=.)
	replace grupos_ocup_sem = v4760 if ano == 2001
	drop v4760
}

* grupos_ocup_sem = 1 t�cnica, cient�fica, art�stica e assemelhada
*             = 2 administrativa
*             = 3 agrop. e prod. extrat. vegetal e animal
*             = 4 ind. de transf.
*             = 5 com�rcio e ativ. auxiliares
*             = 6 transp. e comunica��o
*             = 7 presta��o de servi�os
*             = 8 outras ou n�o declaradas
/* C.12.3 RENAME: ATIVIDADE/RAMOS DO NEG�CIO */
* v9907 � mais desagregado - c�digos variam ao longo do tempo
* v4709 (e v4759) � mais agregado e comum entre os anos das PNAD's

rename v9907 ramo_negocio_sem
label var ramo_negocio_sem "ativ/ramo do neg�cio na semana"

generate ramo_negocio_agreg =.
quietly summarize ano
loc min = r(min)
loc max = r(max)

if `min' <= 1999 {
	recode v4709 (0=.)
	replace ramo_negocio_agreg = v4709 if ano <= 1999
	drop v4709
}

if `max' == 2001 {
	recode v4759 (0=.)
	replace ramo_negocio_agreg = v4759 if ano == 2001
	drop v4759
}

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
* v9008 e v9029 s�o mais detalhados, mas de dif�cil compatibiliza��o com as PNAD's dos anos 80
* foram dropadas	
drop v9008 v9029
* v4706 � mais agregado, e � mais f�cil compatibilizar com as PNAD's dos anos 80

generate pos_ocup_sem =.
if `min' <= 1999 {
	recode v4706 (0 14=.) (2/8=1) (9=2) (10=3) (11 12=.) (13=4)
	replace pos_ocup_sem = v4706 if ano <= 1999
	drop v4706
}

if `max' == 2001 {
	recode v4756 (0 14=.) (2/8=1) (9=2) (10=3) (11 12=.) (13=4)
	replace pos_ocup_sem = v4756 if ano == 2001
	drop v4756
}

label var pos_ocup_sem "posi��o na ocupa��o na semana"
* Trabalhadores na prod/constr para consumo/uso pr�prio foram exclu�dos
* da categoria "empregados" pois n�o eram considerados assim nas PNAD's dos aos 80.
* Se elas n�o forem eliminadas, haveria uma redu��o no n�mero de observa��es
* missing.
* pos_ocup_sem = 1 empregado 
*              = 2 conta pr�pria
*              = 3 empregador
*              = 4 n�o remunerado

/* C.12.5 RECODE: TEM CARTEIRA ASSINADA */
recode v9042 (2=1) (4=0) (9=.)
rename v9042 tem_carteira_assinada
label var tem_carteira_assinada "0-n�o 1-sim"
* tem_carteira_assinada = 0 n�o
*                       = 1 sim

/* C.12.6 HORAS TRABALHADAS */

/* HORAS NORMALMENTE TRABALHADAS SEMANA */
recode v9058 (-1 99 0=.)
replace v9058 = . if tinha_trab_sem == 0 & trabalhou_sem==0
rename v9058 horas_trab_sem
label var horas_trab_sem " horas normal. trab. sem - ocup. princ" 

/* HORAS NORMALMENTE TRABALHADAS - OUTRO TRABALHO */
recode v9101 (-1 99 0=.)
replace v9101 = . if tinha_trab_sem == 0 & trabalhou_sem==0
rename v9101 horas_trab_sem_outro
label var horas_trab_sem_outro "horas normal. sem. outro"

/* C.14.10 RENAME: HORAS NORMALMENTE TRABALHADAS TODOS TRABALHOS */
recode v9105 (-1 99=.)
egen horas_trab_todos_trab = rowtotal(horas_trab_sem horas_trab_sem_outro v9105), miss
replace horas_trab_todos_trab = . if tinha_trab_sem == 0 & trabalhou_sem==0
label var horas_trab_todos_trab "horas todos trab"

drop v9105

/* C.13 RENDIMENTOS */

/* C.13.1 RECODE: RENDA MENSAL EM DINHEIRO - TRABALHO PRINCIPAL */
recode v9532 (-1 999999999999=.)
rename v9532 renda_mensal_din 
label var renda_mensal_din "renda mensal dinheiro"

/* C.13.2 RECODE: RENDA MENSAL EM PRODUTOS/MERCADORIAS - TRABALHO PRINCIPAL */
recode v9535 (-1 999999999999=.)
rename v9535 renda_mensal_prod 
label var renda_mensal_prod "renda mensal prod/merc"

/* C.13.3 RECODE: RENDA MENSAL EM DINHEIRO - OUTROS TRABALHOS (SECUNDARIO E DEMAIS TRABALHOS) */
* SOMANDO: 
	* VALOR REND MENSAL EM DIN NO TRAB SECUND�RIO
	* VALOR REND MENSAL EM DIN EXCETO PRINC E SECUND
recode v9982 (-1 999999999999=.)
recode v1022 (-1 999999999999=.)
tempvar miss
egen `miss' = rowmiss(v9982 v1022)
egen double renda_mensal_din_outra = rowtotal(v9982 v1022)
replace  renda_mensal_din_outra  = . if `miss'==2
format renda_mensal_din_outra %12.0f
label var renda_mensal_din_outra "renda mensal em dinheiro em outros trabalhos"

/* C.13.4 RECODE: RENDA MENSAL EM PRODUTOS/MERCADORIAS OUTRA */
* SOMANDO:
	* VALOR REND MENSAL EM PROD NO TRAB SECUND
	* VALOR REND MENSAL EM PROD EXCETO PRINC E SECUND
recode v9985 (-1 999999999999=.)
recode v1025 (-1 999999999999=.)
tempvar miss
egen `miss' = rowmiss(v9985 v1025)
egen double renda_mensal_prod_outra = rowtotal(v9985 v1025)
replace  renda_mensal_prod_outra  = . if `miss'==2
format renda_mensal_prod_outra %12.0f
label var renda_mensal_prod_outra "renda mensal em produtos em outros trabalhos"

/* C.13.5 RECODE: VALOR APOSENTADORIA */
* SOMANDO:
	* VALOR APOSENT DE INST PREV OU DO GOVERNO NO MES
	* REND DE OUTRO TIPO DE APOSENT NO M�S
recode v1252 (-1 999999999999=.)
recode v1258 (-1 999999999999=.)
gen renda_aposentadoria = v1252+v1258 if v1252 ~= . & v1258 ~= .
replace renda_aposentadoria = v1252 if v1252 ~= . & v1258 == .
replace renda_aposentadoria = v1258 if v1252 == . & v1258 ~= .
label var renda_aposentadoria "rendimento de aposentadoria"

/* C.13.6 RECODE: VALOR PENS�O */
* SOMANDO:
	* VALOR PENS�O DE INST PREV OU DO GOVERNO NO MES
	* REND DE OUTRO TIPO DE PENS�O NO M�S
recode v1255 (-1 999999999999=.)
recode v1261 (-1 999999999999=.)
gen renda_pensao = v1255+v1261 if v1255 ~= . & v1261 ~= .
replace renda_pensao = v1255 if v1255 ~= . & v1261 == .
replace renda_pensao = v1261 if v1255 == . & v1261 ~= .
label var renda_pensao "rendimento de pens�o"

/* C.13.7 RECODE: VALOR ABONO PERMANENTE */
recode v1264 (-1 999999999999=.) 
rename v1264 renda_abono
label var renda_abono "rendimento de abono permanente"

/* C.13.8 RECODE: VALOR ALUGUEL RECEBIDO */
recode v1267 (-1 999999999999=.) 
rename v1267 renda_aluguel
label var renda_aluguel "rendimento de aluguel"

/* C.13.9 RECODE: VALOR OUTRAS */
* SOMANDO:
	* REND DE DOA��O RECEBIDA DE N�O MORADOR
	* REND DE JUROS E DIVIDENDOS E OUTROS REND
recode v1270 (-1 999999999999=.)
recode v1273 (-1 999999999999=.)
gen renda_outras = v1270+v1273 if v1270 ~= . & v1273 ~= .
replace renda_outras = v1270 if v1270 ~= . & v1273 == .
replace renda_outras = v1273 if v1270 == . & v1273 ~= .
label var renda_outras "rendimento de outras fontes"

/* C.13.10 RECODE: REND MENSAL OCUP PRINCIPAL */
generate double renda_mensal_ocup_prin =.
if `min' <= 1999 {
	recode v4718 (-1 999999999999=.)
	replace renda_mensal_ocup_prin = v4718 if ano <= 1999
	drop v4718
}

if `max' == 2001 {
	recode v4768 (-1 999999999999=.)
	replace renda_mensal_ocup_prin = v4768 if ano ==2001
	drop v4768
}

recode renda_mensal_ocup_prin (0=.) if renda_mensal_din == . & renda_mensal_prod == .
lab var renda_mensal_ocup_prin "renda mensal no trabalho principal"

/* C.13.11 RECODE: REND MENSAL TODOS TRABALHOS */
generate double renda_mensal_todos_trab =.
if `min' <= 1999 {
	recode v4719 (-1 999999999999=.)
	replace renda_mensal_todos_trab = v4719 if ano <= 1999
	drop v4719
}

if `max' == 2001 {
	recode v4769 (-1 999999999999=.)
	replace renda_mensal_todos_trab = v4769 if ano ==2001
	drop v4769
}

recode renda_mensal_todos_trab (0=.) if renda_mensal_din == . & renda_mensal_prod == . ///
& renda_mensal_din_outra == . & renda_mensal_prod_outra == . ///
& v1022 ==. & v1025 == .
lab var renda_mensal_todos_trab "renda mensal em todos os trabalhos"

/* C.13.12 RECODE: REND MENSAL TODAS FONTES */
generate double renda_mensal_todas_fontes =.
if `min' <= 1999 {
	recode v4720 (-1 999999999999=.)
	replace renda_mensal_todas_fontes = v4720 if ano <= 1999
	drop v4720
}

if `max' == 2001 {
	recode v4770 (-1 999999999999=.)
	replace renda_mensal_todas_fontes = v4770 if ano ==2001
	drop v4770
}

recode renda_mensal_todas_fontes (0=.) if renda_mensal_din == . ///
	& renda_mensal_prod == . & renda_aposentadoria == . ///
	& renda_pensao == . & renda_outras == . & renda_abono == . ///
	& renda_aluguel == . 
lab var renda_mensal_todas_fontes "renda mensal de todas as fontes" 
	
drop v1022 v1025 v1252 v1255 v1258 v1261 v1270 v1273

/* C.14.1 RECODE: CONTRIBUI INST. PREVID. */
* Apenas para quem tinha trabalho na semana
recode v9059 (3=0) (0 9=.)
replace v9059 = . if tinha_trab_sem == 0 & trabalhou_sem==0
rename v9059 contr_inst_prev
label var contr_inst_prev "contribui p/ instituto de previd�ncia"

/* C.14.2 RENAME: QUAL INST. PREVID. */
recode v9060 (0 9=.)
replace v9060 = . if tinha_trab_sem == 0 & trabalhou_sem==0
rename v9060 qual_inst_prev
* qual_inst_prev = 2 federal
*                = 4 estadual
*                = 6 municipal

/* C.15 RECODE: TINHA OUTRO TRABALHO? */
* Apenas para quem tinha trabalho na semana de refer�ncia
recode v9005 (1=0) (3 5=1)
replace v9005 = . if tinha_trab_sem == 0 & trabalhou==0
rename v9005 tinha_outro_trab
label var tinha_outro_trab "tinha outro trabalho/sem?"

/* C.16 PESSOAS QUE N�O TINHAM TRABALHO NA SEMANA DE REFER�NCIA */
/*	  MAS TIVERAM OCUPA��O NO PER�ODO DE 12 MESES             */
* A partir da PNAD de 1992, a quest�o sobre ocupa��o anterior passa a
* cobrir tanto as pessoas que n�o tinham trabalho na semana de refer�ncia
* quanto aquelas cujo trab na semana de ref n�o era o principal no per�odo
* de 365 dias.

/* RECODE: TEMPO SEM TRABALHO */
* Esta informa��o n�o pode mais ser aferida com precis�o a partir dos anos 90.

/* RECODE: TEMPO NA OCUPA��O ANTERIOR */
* A partir de 1992, esta informa��o n�o pode ser obtida para todos os indiv�duos.

/* INFORMA��ES SOBRE O EMPREGO ANTERIOR */
* COMO NOS ANOS 80 � SIMPLESMENTE O �LTIMO TRABALHO
* (DE QUEM N�O TRABALHOU NA SEMANA DE REFE�NCIA) 
* AS INFORMA��ES SOBRE O TRABALHO ANTERIOR
* DOS ANOS 80 E 90 N�O S�O PERFEITAMENTE COMPAT�VEIS.

/* DUMMY: N�O TRABALHOU NA SEMANA E DEIXOU �LTIMO EMPREGO NO �LTIMO ANO - 12 MESES OU MENOS */
/*		VARI�VEL TEMPOR�RIA                                                           */
recode v9067 (3=0) (0 9=.)
rename v9067 teve_algum_trab_ano
label var teve_algum_trab_ano "teve algum trab no ano"
                                                           
gen tag = 1 if tinha_trab_sem == 0 & teve_algum_trab_ano == 1 

/* C.16.1 GEN: OCUPA��O ANTERIOR, NO ANO */
gen ocup_ant_ano = v9971 if tag == 1
label var ocup_ant_ano "ocupa��o anterior - no ano"
drop v9971

/* C.16.2 GEN: RAMO ANTERIOR, NO ANO */
gen ramo_negocio_ant_ano = v9972 if tag == 1
label var ramo_negocio_ant_ano "ativ/ramo do neg�cio anterior - no ano"
drop v9972

/* C.16.3 RECODE: TINHA CARTEIRA ASSINADA NA OCUPA��O ANTERIOR, NO ANO */
gen tinha_cart_assin_ant_ano = v9083 if tag == 1
recode tinha_cart_assin_ant_ano (3=0) (9=.) 
label var tinha_cart_assin_ant_ano "�lt emprego - no ano - cart assin"
drop tag v9083

/* C.18.3.6 RECODE: RECEBEU FGTS OCUPA��O ANTERIOR, NO ANO */
* ESSA PERGUNTA N�O CONSTA DAS PNAD'S DOS ANOS 90

/* C.17 RECODE: TOMOU PROV. PARA CONSEGUIR TRABALHO */
/* NA SEMANA DE REFER�NCIA: APENAS QUEM N�O TINHA TRABALHO NA SEMANA */
replace v9115 = . if tinha_trab_sem == 1
recode v9115 (3=0) (9=.)
rename v9115 tomou_prov_semana
* tomou_prov_na_sem = 1 sim
*                   = 0 n�o

/* C.18 RECODE: TOMOU PROV. PARA CONSEGUIR TRABALHO 2 MESES */
/* APENAS QUEM N�O TINHA TRABALHO NA SEMANA */
replace v9116 = . if tinha_trab_sem == 1
replace v9117 = . if tinha_trab_sem == 1
recode v9116 (2=1) (4=0) (9=.)
recode v9117 (3=0) (9=.)
gen tomou_prov_2meses = 1 if v9116 == 1 | v9117 == 1
replace tomou_prov_2meses = 0 if v9116 == 0 & v9117 == 0
label var tomou_prov_2meses "tomou provid�ncia p/ conseguir trab nos �ltimos 2 meses"
* tomou_prov_2meses = 1 sim
*                   = 0 n�o
drop v9116 v9117

/* C.19 RECODE: QUE PROV. TOMOU PARA CONSEGUIR TRABALHO */
* Nas PNAD's dos anos 80, a pergunta � feita apenas para quem respondeu "sim"
* � pergunta anterior (tomou prov. cons. trab - 2 meses)
* Nas PNAD's dos anos 90, a pergunta � sobre a �ltima prov. que tomou, e se aplica a todos os indiv�duos.
* Isto � ajustado a seguir.
gen que_prov_tomou = v9119 if trabalhou_semana==0 & tinha_trab_sem==0
recode que_prov_tomou (0=7) (3=2) (7 8=6) (4=3) (5=4) (6=5) (9=.)
label var que_prov_tomou "que provid�ncia tomou para conseguir trabalho"
* que_prov_tomou = 1 consultou empregador
*                                 = 2 fez concurso
*                                 = 3 consultou ag�ncia/sindicato
*                                 = 4 colocou an�ncio
*                                 = 5 consultou parente
*                                 = 6 outra
*                                 = 7 nada fez

drop v9002 v9003 v9119 teve_algum_trab_ano

/* Para 2001, vari�veis de trabalho referem-se tamb�m a trabalho infantil 5-9 anos */
foreach var of varlist tinha_outro_trab ocup_sem ramo_negocio_sem tem_carteira_assinada ///
	renda_mensal_din renda_mensal_prod horas_trab_sem contr_inst_prev qual_inst_prev ///
	horas_trab_sem_outro tomou_prov_semana renda_abono renda_aluguel trabalhou_semana ///
	tinha_trab_sem grupos_ocup_sem ramo_negocio_agreg pos_ocup_sem horas_trab_todos_trab ///
	renda_mensal_din_outra renda_mensal_prod_outra renda_aposentadoria renda_pensao ///
	renda_outras renda_mensal_ocup_prin renda_mensal_todos_trab renda_mensal_todas_fontes ///
	ocup_ant_ano ramo_negocio_ant_ano tinha_cart_assin_ant_ano tomou_prov_2meses que_prov_tomou {
	
	replace `var' = . if idade<10
}

/* D. DEFLACIONANDO E CONVERTENDO UNIDADES MONET�RIAS PARA REAIS */

/* CONVERTENDO OS VALORES NOMINAIS PARA REAIS (UNIDADE MONET�RIA) */
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

foreach i in din_outra prod_outra ocup_prin todos_trab todas_fontes din prod {
	g renda_`i'_def = (renda_mensal_`i'/conversor)/deflator 
	lab var renda_`i'_def "renda_mensal_`i' deflacionada"
}

foreach i in aposentadoria pensao abono aluguel outras {
	g renda_`i'_def = (renda_`i'/conversor)/deflator
	lab var renda_`i'_def "renda_`i' deflacionada"
}

order ano uf id_dom ordem 

cap drop v1091 v1092 
cap drop v7101 v7102 

drop v*

compress

end
