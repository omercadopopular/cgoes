*************************************************************
*			 compat_pess_2002a2009_para_81.ado 				*
*************************************************************

program define compat_pes_2002a2009_para_81

/* C.0 RECODE: ANO */
rename v0101 ano
label var ano "ano da pesquisa"
qui sum ano
if r(mean)==2003 drop v13* v14* v17* v18* v33* v7101 v7102 
if r(mean)==2004 drop v19* 
if r(mean)==2005 drop v22* 
if r(mean)==2006 drop v19* v23* v88* 
if r(mean)==2007 drop v25* v26* v66* v67* 
if r(mean)==2008 drop v27* v72* v13* v14* v33* v34* v36* v37* v22* v28* ///
	v82* v73* v77* SELEC PESPET v1701 v1702
if r(mean)==2009 drop v29* 

foreach var in v0408 v0409 v0410 v4011 v0412 v4732 v4735 v4838 v6502 v4740 v4741 v4742 v4743 ///
				v4744 v4745 v4746 v4747 v4748 v4749 v4750 v9993 {
	cap drop `var'
}

/* A. ACERTA C�DIGO DOS ESTADOS */
* AGREGA TOCANTINS COM GOI�S

/* A.1 NA VARI�VEL UF E CRIA VARI�VEL DE REGI�O */
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
replace v3033 = . if v3033 <= 150 | v3033==9999
rename v3033 ano_nasc

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


/* C.11 VARI�VEIS DE EDUCA��O */
/* C.11.1 RECODE: ANOS DE ESTUDO */
/* EDUCA��O */
/* VARI�VEIS UTILIZADAS PARA 2002 A 2006*/
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
/* PARA 2007, 2008 E 2009, EM VEZ DE v0603 E v0607 */
/* v6003=QUAL E O CURSO QUE FREQUENTA? */
/* v6030=QUAL A DURACAO DO ENSINO FUNDAMENTAL QUE FREQUENTA? */
/* v6007=QUAL FOI O CURSO MAIS ELEVADO QUE FREQUENTOU ANTERIORMENTE? */
/* v6070=QUAL A DURACAO DO ENSINO FUNDAMENTAL QUE FREQUENTOU ANTERIORMENTE? */

generate byte educa = .
lab var educa "anos de estudo - compat�vel c/ anos 1980"
quietly summarize ano
loc min = r(min)
loc max = r(max)

if `min' <= 2006 {
/* 2002 a 2006 */
/* pessoas que ainda freq�entam escola */
	replace educa =0 if v0602==2 & v0603==1 & v0605==1 & ano <= 2006
	replace educa =1 if v0602==2 & v0603==1 & v0605==2 & ano <= 2006
	replace educa =2 if v0602==2 & v0603==1 & v0605==3 & ano <= 2006
	replace educa =3 if v0602==2 & v0603==1 & v0605==4 & ano <= 2006
	replace educa =4 if v0602==2 & v0603==1 & v0605==5 & ano <= 2006
	replace educa =5 if v0602==2 & v0603==1 & v0605==6 & ano <= 2006
	replace educa =6 if v0602==2 & v0603==1 & v0605==7 & ano <= 2006
	replace educa =7 if v0602==2 & v0603==1 & v0605==8 & ano <= 2006

	replace educa =8 if v0602==2 & v0603==2 & v0605==1 & ano <= 2006
	replace educa =9 if v0602==2 & v0603==2 & v0605==2 & ano <= 2006
	replace educa =10 if v0602==2 & v0603==2 & v0605==3 & ano <= 2006
	replace educa =11 if v0602==2 & v0603==2 & v0605==4 & ano <= 2006

	replace educa =0 if v0602==2 & v0603==3 & v0604==2 & v0605==1 & ano <= 2006
	replace educa =1 if v0602==2 & v0603==3 & v0604==2 & v0605==2 & ano <= 2006
	replace educa =2 if v0602==2 & v0603==3 & v0604==2 & v0605==3 & ano <= 2006
	replace educa =3 if v0602==2 & v0603==3 & v0604==2 & v0605==4 & ano <= 2006
	replace educa =4 if v0602==2 & v0603==3 & v0604==2 & v0605==5 & ano <= 2006
	replace educa =5 if v0602==2 & v0603==3 & v0604==2 & v0605==6 & ano <= 2006
	replace educa =6 if v0602==2 & v0603==3 & v0604==2 & v0605==7 & ano <= 2006
	replace educa =7 if v0602==2 & v0603==3 & v0604==2 & v0605==8 & ano <= 2006

	replace educa =0 if v0602==2 & v0603==3 & v0604==4  & ano <= 2006

	replace educa =8 if v0602==2 & v0603==4 & v0604==2 & v0605==1 & ano <= 2006
	replace educa =9 if v0602==2 & v0603==4 & v0604==2 & v0605==2 & ano <= 2006
	replace educa =10 if v0602==2 & v0603==4 & v0604==2 & v0605==3 & ano <= 2006
	replace educa =11 if v0602==2 & v0603==4 & v0604==2 & v0605==4 & ano <= 2006

	replace educa =8 if v0602==2 & v0603==4 & v0604==4  & ano <= 2006

	replace educa =11 if v0602==2 & v0603==5 & v0605==1 & ano <= 2006
	replace educa =12 if v0602==2 & v0603==5 & v0605==2 & ano <= 2006
	replace educa =13 if v0602==2 & v0603==5 & v0605==3 & ano <= 2006
	replace educa =14 if v0602==2 & v0603==5 & v0605==4 & ano <= 2006
	replace educa =15 if v0602==2 & v0603==5 & v0605==5 & ano <= 2006
	replace educa =16 if v0602==2 & v0603==5 & v0605==6 & ano <= 2006

	replace educa =0 if v0602==2 & v0603==6 & ano <= 2006
	replace educa =0 if v0602==2 & v0603==7 & ano <= 2006
	replace educa =0 if v0602==2 & v0603==8 & ano <= 2006
	replace educa =11 if v0602==2 & v0603==9 & ano <= 2006
	replace educa =15 if v0602==2 & v0603==10 & ano <= 2006

/* pessoas que n�o freq�entam */

	replace educa =1 if v0602==4 & v0606==2 & v0607==1 & v0609==1 & v0610==1 & ano <= 2006
	replace educa =2 if v0602==4 & v0606==2 & v0607==1 & v0609==1 & v0610==2 & ano <= 2006
	replace educa =3 if v0602==4 & v0606==2 & v0607==1 & v0609==1 & v0610==3 & ano <= 2006
	replace educa =4 if v0602==4 & v0606==2 & v0607==1 & v0609==1 & v0610==4 & ano <= 2006
	replace educa =4 if v0602==4 & v0606==2 & v0607==1 & v0609==1 & v0610==5 & ano <= 2006
	replace educa =4 if v0602==4 & v0606==2 & v0607==1 & v0609==1 & v0610==6 & ano <= 2006

	replace educa =0 if v0602==4 & v0606==2 & v0607==1 & v0609==3 & ano <= 2006

	replace educa =5 if v0602==4 & v0606==2 & v0607==2 & v0608==2 & v0609==1 & v0610==1 & ano <= 2006
	replace educa =6 if v0602==4 & v0606==2 & v0607==2 & v0608==2 & v0609==1 & v0610==2 & ano <= 2006
	replace educa =7 if v0602==4 & v0606==2 & v0607==2 & v0608==2 & v0609==1 & v0610==3 & ano <= 2006
	replace educa =8 if v0602==4 & v0606==2 & v0607==2 & v0608==2 & v0609==1 & v0610==4 & ano <= 2006
	replace educa =8 if v0602==4 & v0606==2 & v0607==2 & v0608==2 & v0609==1 & v0610==5 & ano <= 2006

	replace educa =4 if v0602==4 & v0606==2 & v0607==2 & v0608==2 & v0609==3 & ano <= 2006

	replace educa =8 if v0602==4 & v0606==2 & v0607==2 & v0608==4 & v0611==1 & ano <= 2006
	replace educa =4 if v0602==4 & v0606==2 & v0607==2 & v0608==4 & v0611==3 & ano <= 2006

	replace educa =9 if v0602==4 & v0606==2 & v0607==3 & v0608==2 & v0609==1 & v0610==1 & ano <= 2006
	replace educa =10 if v0602==4 & v0606==2 & v0607==3 & v0608==2 & v0609==1 & v0610==2 & ano <= 2006
	replace educa =11 if v0602==4 & v0606==2 & v0607==3 & v0608==2 & v0609==1 & v0610==3 & ano <= 2006
	replace educa =11 if v0602==4 & v0606==2 & v0607==3 & v0608==2 & v0609==1 & v0610==4 & ano <= 2006

	replace educa =8 if v0602==4 & v0606==2 & v0607==3 & v0608==2 & v0609==3 & ano <= 2006

	replace educa =11 if v0602==4 & v0606==2 & v0607==3 & v0608==4 & v0611==1 & ano <= 2006
	replace educa =8 if v0602==4 & v0606==2 & v0607==3 & v0608==4 & v0611==3 & ano <= 2006

	replace educa =1 if v0602==4 & v0606==2 & v0607==4 & v0608==2 & v0609==1 & v0610==1 & ano <= 2006
	replace educa =2 if v0602==4 & v0606==2 & v0607==4 & v0608==2 & v0609==1 & v0610==2 & ano <= 2006
	replace educa =3 if v0602==4 & v0606==2 & v0607==4 & v0608==2 & v0609==1 & v0610==3 & ano <= 2006
	replace educa =4 if v0602==4 & v0606==2 & v0607==4 & v0608==2 & v0609==1 & v0610==4 & ano <= 2006
	replace educa =5 if v0602==4 & v0606==2 & v0607==4 & v0608==2 & v0609==1 & v0610==5 & ano <= 2006
	replace educa =6 if v0602==4 & v0606==2 & v0607==4 & v0608==2 & v0609==1 & v0610==6 & ano <= 2006
	replace educa =7 if v0602==4 & v0606==2 & v0607==4 & v0608==2 & v0609==1 & v0610==7 & ano <= 2006
	replace educa =8 if v0602==4 & v0606==2 & v0607==4 & v0608==2 & v0609==1 & v0610==8 & ano <= 2006

	replace educa =0 if v0602==4 & v0606==2 & v0607==4 & v0608==2 & v0609==3 & ano <= 2006

	replace educa =8 if v0602==4 & v0606==2 & v0607==4 & v0608==4 & v0611==1 & ano <= 2006
	replace educa =0 if v0602==4 & v0606==2 & v0607==4 & v0608==4 & v0611==3 & ano <= 2006

	replace educa =9 if v0602==4 & v0606==2 & v0607==5 & v0608==2 & v0609==1 & v0610==1 & ano <= 2006
	replace educa =10 if v0602==4 & v0606==2 & v0607==5 & v0608==2 & v0609==1 & v0610==2 & ano <= 2006
	replace educa =11 if v0602==4 & v0606==2 & v0607==5 & v0608==2 & v0609==1 & v0610==3 & ano <= 2006
	replace educa =11 if v0602==4 & v0606==2 & v0607==5 & v0608==2 & v0609==1 & v0610==4 & ano <= 2006

	replace educa =8 if v0602==4 & v0606==2 & v0607==5 & v0608==2 & v0609==3 & ano <= 2006

	replace educa =11 if v0602==4 & v0606==2 & v0607==5 & v0608==4 & v0611==1 & ano <= 2006
	replace educa =8 if v0602==4 & v0606==2 & v0607==5 & v0608==4 & v0611==3 & ano <= 2006

	replace educa =12 if v0602==4 & v0606==2 & v0607==6 & v0609==1 & v0610==1 & ano <= 2006
	replace educa =13 if v0602==4 & v0606==2 & v0607==6 & v0609==1 & v0610==2 & ano <= 2006
	replace educa =14 if v0602==4 & v0606==2 & v0607==6 & v0609==1 & v0610==3 & ano <= 2006

	replace educa =15 if v0602==4 & v0606==2 & v0607==6 & v0609==1 & v0610==4 & ano <= 2006
	replace educa =16 if v0602==4 & v0606==2 & v0607==6 & v0609==1 & v0610==5 & ano <= 2006
	replace educa =17 if v0602==4 & v0606==2 & v0607==6 & v0609==1 & v0610==6 & ano <= 2006

	replace educa =11 if v0602==4 & v0606==2 & v0607==6 & v0609==3 & ano <= 2006

	replace educa =17 if v0602==4 & v0606==2 & v0607==7 & v0611==1 & ano <= 2006
	replace educa =15 if v0602==4 & v0606==2 & v0607==7 & v0611==3 & ano <= 2006

	replace educa =0 if v0602==4 & v0606==2 & v0607==8 & ano <= 2006
	replace educa =0 if v0602==4 & v0606==2 & v0607==9 & ano <= 2006
	replace educa =0 if v0602==4 & v0606==2 & v0607==10 & ano <= 2006

	replace educa =0 if v0602==4 & v0606==4 & ano <= 2006
}
if `max' >= 2007 {
/* 2007 a 2009 */
/* pessoas que ainda freq�entam escola */
	replace educa =0 if v0602==2 & v6003==1 & v6030==1 & v0605==1 & ano >= 2007
	replace educa =1 if v0602==2 & v6003==1 & v6030==1 & v0605==2 & ano >= 2007
	replace educa =2 if v0602==2 & v6003==1 & v6030==1 & v0605==3 & ano >= 2007
	replace educa =3 if v0602==2 & v6003==1 & v6030==1 & v0605==4 & ano >= 2007
	replace educa =4 if v0602==2 & v6003==1 & v6030==1 & v0605==5 & ano >= 2007
	replace educa =5 if v0602==2 & v6003==1 & v6030==1 & v0605==6 & ano >= 2007
	replace educa =6 if v0602==2 & v6003==1 & v6030==1 & v0605==7 & ano >= 2007
	replace educa =7 if v0602==2 & v6003==1 & v6030==1 & v0605==8 & ano >= 2007

	replace educa =0 if v0602==2 & v6003==1 & v6030==3 & v0605==1 & ano >= 2007
	replace educa =0 if v0602==2 & v6003==1 & v6030==3 & v0605==2 & ano >= 2007
	replace educa =1 if v0602==2 & v6003==1 & v6030==3 & v0605==3 & ano >= 2007
	replace educa =2 if v0602==2 & v6003==1 & v6030==3 & v0605==4 & ano >= 2007
	replace educa =3 if v0602==2 & v6003==1 & v6030==3 & v0605==5 & ano >= 2007
	replace educa =4 if v0602==2 & v6003==1 & v6030==3 & v0605==6 & ano >= 2007
	replace educa =5 if v0602==2 & v6003==1 & v6030==3 & v0605==7 & ano >= 2007
	replace educa =6 if v0602==2 & v6003==1 & v6030==3 & v0605==8 & ano >= 2007
	replace educa =7 if v0602==2 & v6003==1 & v6030==3 & v0605==0 & ano >= 2007

	replace educa =8 if v0602==2 & v6003==2 & v0605==1 & ano >= 2007
	replace educa =9 if v0602==2 & v6003==2 & v0605==2 & ano >= 2007
	replace educa =10 if v0602==2 & v6003==2 & v0605==3 & ano >= 2007
	replace educa =11 if v0602==2 & v6003==2 & v0605==4 & ano >= 2007

	replace educa =0 if v0602==2 & v6003==3 & v0604==2 & v0605==1 & ano >= 2007
	replace educa =1 if v0602==2 & v6003==3 & v0604==2 & v0605==2 & ano >= 2007
	replace educa =2 if v0602==2 & v6003==3 & v0604==2 & v0605==3 & ano >= 2007
	replace educa =3 if v0602==2 & v6003==3 & v0604==2 & v0605==4 & ano >= 2007
	replace educa =4 if v0602==2 & v6003==3 & v0604==2 & v0605==5 & ano >= 2007
	replace educa =5 if v0602==2 & v6003==3 & v0604==2 & v0605==6 & ano >= 2007
	replace educa =6 if v0602==2 & v6003==3 & v0604==2 & v0605==7 & ano >= 2007
	replace educa =7 if v0602==2 & v6003==3 & v0604==2 & v0605==8 & ano >= 2007

	replace educa =0 if v0602==2 & v6003==3 & v0604==4  & ano >= 2007

	replace educa =8 if v0602==2 & v6003==4 & v0604==2 & v0605==1 & ano >= 2007
	replace educa =9 if v0602==2 & v6003==4 & v0604==2 & v0605==2 & ano >= 2007
	replace educa =10 if v0602==2 & v6003==4 & v0604==2 & v0605==3 & ano >= 2007
	replace educa =11 if v0602==2 & v6003==4 & v0604==2 & v0605==4 & ano >= 2007

	replace educa =8 if v0602==2 & v6003==4 & v0604==4  & ano >= 2007

	replace educa =11 if v0602==2 & v6003==5 & v0605==1 & ano >= 2007
	replace educa =12 if v0602==2 & v6003==5 & v0605==2 & ano >= 2007
	replace educa =13 if v0602==2 & v6003==5 & v0605==3 & ano >= 2007
	replace educa =14 if v0602==2 & v6003==5 & v0605==4 & ano >= 2007
	replace educa =15 if v0602==2 & v6003==5 & v0605==5 & ano >= 2007
	replace educa =16 if v0602==2 & v6003==5 & v0605==6 & ano >= 2007

	replace educa =0 if v0602==2 & v6003==6 & ano >= 2007
	replace educa =0 if v0602==2 & v6003==7 & ano >= 2007
	replace educa =0 if v0602==2 & v6003==8 & ano >= 2007
	replace educa =0 if v0602==2 & v6003==9 & ano >= 2007
	replace educa =11 if v0602==2 & v6003==10 & ano >= 2007
	replace educa =15 if v0602==2 & v6003==11 & ano >= 2007

/* pessoas que n�o freq�entam */

	replace educa =1 if v0602==4 & v0606==2 & v6007==1 & v0609==1 & v0610==1 & ano >= 2007
	replace educa =2 if v0602==4 & v0606==2 & v6007==1 & v0609==1 & v0610==2 & ano >= 2007
	replace educa =3 if v0602==4 & v0606==2 & v6007==1 & v0609==1 & v0610==3 & ano >= 2007
	replace educa =4 if v0602==4 & v0606==2 & v6007==1 & v0609==1 & v0610==4 & ano >= 2007
	replace educa =4 if v0602==4 & v0606==2 & v6007==1 & v0609==1 & v0610==5 & ano >= 2007
	replace educa =4 if v0602==4 & v0606==2 & v6007==1 & v0609==1 & v0610==6 & ano >= 2007

	replace educa =0 if v0602==4 & v0606==2 & v6007==1 & v0609==3 & ano >= 2007

	replace educa =5 if v0602==4 & v0606==2 & v6007==2 & v0608==2 & v0609==1 & v0610==1 & ano >= 2007
	replace educa =6 if v0602==4 & v0606==2 & v6007==2 & v0608==2 & v0609==1 & v0610==2 & ano >= 2007
	replace educa =7 if v0602==4 & v0606==2 & v6007==2 & v0608==2 & v0609==1 & v0610==3 & ano >= 2007
	replace educa =8 if v0602==4 & v0606==2 & v6007==2 & v0608==2 & v0609==1 & v0610==4 & ano >= 2007
	replace educa =8 if v0602==4 & v0606==2 & v6007==2 & v0608==2 & v0609==1 & v0610==5 & ano >= 2007

	replace educa =4 if v0602==4 & v0606==2 & v6007==2 & v0608==2 & v0609==3 & ano >= 2007

	replace educa =8 if v0602==4 & v0606==2 & v6007==2 & v0608==4 & v0611==1 & ano >= 2007
	replace educa =4 if v0602==4 & v0606==2 & v6007==2 & v0608==4 & v0611==3 & ano >= 2007

	replace educa =9 if v0602==4 & v0606==2 & v6007==3 & v0608==2 & v0609==1 & v0610==1 & ano >= 2007
	replace educa =10 if v0602==4 & v0606==2 & v6007==3 & v0608==2 & v0609==1 & v0610==2 & ano >= 2007
	replace educa =11 if v0602==4 & v0606==2 & v6007==3 & v0608==2 & v0609==1 & v0610==3 & ano >= 2007
	replace educa =11 if v0602==4 & v0606==2 & v6007==3 & v0608==2 & v0609==1 & v0610==4 & ano >= 2007

	replace educa =8 if v0602==4 & v0606==2 & v6007==3 & v0608==2 & v0609==3 & ano >= 2007

	replace educa =11 if v0602==4 & v0606==2 & v6007==3 & v0608==4 & v0611==1 & ano >= 2007
	replace educa =8 if v0602==4 & v0606==2 & v6007==3 & v0608==4 & v0611==3 & ano >= 2007

	replace educa =1 if v0602==4 & v0606==2 & v6007==4 & v6070==1 & v0609==1 & v0610==1 & ano >= 2007
	replace educa =2 if v0602==4 & v0606==2 & v6007==4 & v6070==1 & v0609==1 & v0610==2 & ano >= 2007
	replace educa =3 if v0602==4 & v0606==2 & v6007==4 & v6070==1 & v0609==1 & v0610==3 & ano >= 2007
	replace educa =4 if v0602==4 & v0606==2 & v6007==4 & v6070==1 & v0609==1 & v0610==4 & ano >= 2007
	replace educa =5 if v0602==4 & v0606==2 & v6007==4 & v6070==1 & v0609==1 & v0610==5 & ano >= 2007
	replace educa =6 if v0602==4 & v0606==2 & v6007==4 & v6070==1 & v0609==1 & v0610==6 & ano >= 2007
	replace educa =7 if v0602==4 & v0606==2 & v6007==4 & v6070==1 & v0609==1 & v0610==7 & ano >= 2007
	replace educa =8 if v0602==4 & v0606==2 & v6007==4 & v6070==1 & v0609==1 & v0610==8 & ano >= 2007

	replace educa =0 if v0602==4 & v0606==2 & v6007==4 & v6070==1 & v0609==3 & ano >= 2007

	replace educa =0 if v0602==4 & v0606==2 & v6007==4 & v6070==3 & v0609==1 & v0610==1 & ano >= 2007
	replace educa =1 if v0602==4 & v0606==2 & v6007==4 & v6070==3 & v0609==1 & v0610==2 & ano >= 2007
	replace educa =2 if v0602==4 & v0606==2 & v6007==4 & v6070==3 & v0609==1 & v0610==3 & ano >= 2007
	replace educa =3 if v0602==4 & v0606==2 & v6007==4 & v6070==3 & v0609==1 & v0610==4 & ano >= 2007
	replace educa =4 if v0602==4 & v0606==2 & v6007==4 & v6070==3 & v0609==1 & v0610==5 & ano >= 2007
	replace educa =5 if v0602==4 & v0606==2 & v6007==4 & v6070==3 & v0609==1 & v0610==6 & ano >= 2007
	replace educa =6 if v0602==4 & v0606==2 & v6007==4 & v6070==3 & v0609==1 & v0610==7 & ano >= 2007
	replace educa =7 if v0602==4 & v0606==2 & v6007==4 & v6070==3 & v0609==1 & v0610==8 & ano >= 2007
	replace educa =8 if v0602==4 & v0606==2 & v6007==4 & v6070==3 & v0609==1 & v0610==0 & ano >= 2007

	replace educa =0 if v0602==4 & v0606==2 & v6007==4 & v6070==3 & v0609==3 & ano >= 2007

	replace educa =9 if v0602==4 & v0606==2 & v6007==5 & v0609==1 & v0610==1 & ano >= 2007
	replace educa =10 if v0602==4 & v0606==2 & v6007==5 & v0609==1 & v0610==2 & ano >= 2007
	replace educa =11 if v0602==4 & v0606==2 & v6007==5 & v0609==1 & v0610==3 & ano >= 2007
	replace educa =11 if v0602==4 & v0606==2 & v6007==5 & v0609==1 & v0610==4 & ano >= 2007

	replace educa =8 if v0602==4 & v0606==2 & v6007==5 & v0609==3 & ano >= 2007

	replace educa =1 if v0602==4 & v0606==2 & v6007==6 & v0608==2 & v0609==1 & v0610==1 & ano >= 2007
	replace educa =2 if v0602==4 & v0606==2 & v6007==6 & v0608==2 & v0609==1 & v0610==2 & ano >= 2007
	replace educa =3 if v0602==4 & v0606==2 & v6007==6 & v0608==2 & v0609==1 & v0610==3 & ano >= 2007
	replace educa =4 if v0602==4 & v0606==2 & v6007==6 & v0608==2 & v0609==1 & v0610==4 & ano >= 2007
	replace educa =5 if v0602==4 & v0606==2 & v6007==6 & v0608==2 & v0609==1 & v0610==5 & ano >= 2007
	replace educa =6 if v0602==4 & v0606==2 & v6007==6 & v0608==2 & v0609==1 & v0610==6 & ano >= 2007
	replace educa =7 if v0602==4 & v0606==2 & v6007==6 & v0608==2 & v0609==1 & v0610==7 & ano >= 2007
	replace educa =8 if v0602==4 & v0606==2 & v6007==6 & v0608==2 & v0609==1 & v0610==8 & ano >= 2007

	replace educa =0 if v0602==4 & v0606==2 & v6007==6 & v0608==2 & v0609==3 & ano >= 2007

	replace educa =8 if v0602==4 & v0606==2 & v6007==6 & v0608==4 & v0611==1 & ano >= 2007
	replace educa =0 if v0602==4 & v0606==2 & v6007==6 & v0608==4 & v0611==3 & ano >= 2007

	replace educa =9 if v0602==4 & v0606==2 & v6007==7 & v0608==2 & v0609==1 & v0610==1 & ano >= 2007
	replace educa =10 if v0602==4 & v0606==2 & v6007==7 & v0608==2 & v0609==1 & v0610==2 & ano >= 2007
	replace educa =11 if v0602==4 & v0606==2 & v6007==7 & v0608==2 & v0609==1 & v0610==3 & ano >= 2007
	replace educa =11 if v0602==4 & v0606==2 & v6007==7 & v0608==2 & v0609==1 & v0610==4 & ano >= 2007

	replace educa =8 if v0602==4 & v0606==2 & v6007==7 & v0608==2 & v0609==3 & ano >= 2007

	replace educa =11 if v0602==4 & v0606==2 & v6007==7 & v0608==4 & v0611==1 & ano >= 2007
	replace educa =8 if v0602==4 & v0606==2 & v6007==7 & v0608==4 & v0611==3 & ano >= 2007

	replace educa =12 if v0602==4 & v0606==2 & v6007==8 & v0609==1 & v0610==1 & ano >= 2007
	replace educa =13 if v0602==4 & v0606==2 & v6007==8 & v0609==1 & v0610==2 & ano >= 2007
	replace educa =14 if v0602==4 & v0606==2 & v6007==8 & v0609==1 & v0610==3 & ano >= 2007
	replace educa =15 if v0602==4 & v0606==2 & v6007==8 & v0609==1 & v0610==4 & ano >= 2007
	replace educa =16 if v0602==4 & v0606==2 & v6007==8 & v0609==1 & v0610==5 & ano >= 2007
	replace educa =17 if v0602==4 & v0606==2 & v6007==8 & v0609==1 & v0610==6 & ano >= 2007

	replace educa =11 if v0602==4 & v0606==2 & v6007==8 & v0609==3 & ano >= 2007

	replace educa =17 if v0602==4 & v0606==2 & v6007==9 & v0611==1 & ano >= 2007
	replace educa =15 if v0602==4 & v0606==2 & v6007==9 & v0611==3 & ano >= 2007

	replace educa =0 if v0602==4 & v0606==2 & v6007==10 & ano >= 2007
	replace educa =0 if v0602==4 & v0606==2 & v6007==11 & ano >= 2007
	replace educa =0 if v0602==4 & v0606==2 & v6007==12 & ano >= 2007
	replace educa =0 if v0602==4 & v0606==2 & v6007==13 & ano >= 2007

	replace educa =0 if v0602==4 & v0606==4 & ano >= 2007
}

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

if `max' >= 2007 {
* A PARTIR DE 2007, H� A POSSIBILIDADE DE O ENSINO FUNDAMENTAL SER EM 9 ANOS
* NESSE CASO, O "PRIMEIRO ANO" EQUIVALE � "CLASSE DE ALFABETIZA��O".
	recode v6003 (1=8) if v6030 == 3 & v0605 == 1
	recode v6007 (4=12) if v6070 == 3 & v0610 == 1
	recode v0605 (1=.) (2=1) (3=2) (4=3) (5=4) (6=5) (7=6) (8=7) (0=8) if v6030 == 3
	recode v0610 (1=.) (2=1) (3=2) (4=3) (5=4) (6=5) (7=6) (8=7) (0=8) if v6070 == 3
}

/* C.11.4 RECODE: S�RIE QUE FREQ�ENTA NA ESCOLA */
recode v0605 (9=.)
rename v0605 serie_freq
label var serie_freq "s�rie - frequenta escola"

/* C.11.5 RECODE: GRAU QUE FREQ�ENTA NA ESCOLA */
generate byte grau_freq = .

if `max' <= 2006 {
	recode v0603 (0=.) 
	recode v0603 (8=7) (9=8) (10=9)
	replace grau_freq = v0603 if ano <= 2006
}

if `max' >= 2007 {
* EM 2007, SURGIU A CATEGORIA "CLASSE DE ALFABETIZA��O"
* ANTERIORMENTE ELA SE INCLU�A EM "PR�-ESCOLAR OU CRECHE"
	recode v6003 (8 9=7) (10=8) (11=9)
	replace grau_freq = v6003 if ano >= 2007
}

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
generate byte grau_nao_freq = .

if `max' <= 2006 {
	recode v0607 (0=.) 
	recode v0607 (8=7) (9=8) (10=9)
	replace grau_nao_freq = v0607 if ano <= 2006
	drop v0603 v0607
}

if `max' >= 2007 {
	recode v6007 (6=4) (7=5) (8=6) (9=7) (10=8) (11/13=9)
	replace grau_nao_freq = v6007 if ano >= 2007
	drop v6003 v6030 v6007 v6070
}

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
*                  = 0 n�o

/* C.12.1 DUMMY: tinha TRABALHO NA SEMANA */
* tinha trabalho na semana, mas estava afastado temporariamente (estava de f�rias etc.)
g tinha_trab_sem = 0 if trabalhou_semana==0
replace tinha_trab_sem = 1 if v9002 == 2
label var tinha_trab_sem "tinha trabalho na semana?"
* tinha_trab_sem = 1 sim
*               = 0 n�o
drop v9001 v9002

/* C.12.2 RENAME: OCUPA��O NA SEMANA */
rename v9906 ocup_sem_nova
label var ocup_sem_nova  "ocupa��o na semana - c�digos CBO-Domiciliar"


rename v4810 grupos_ocup_nova 
label var grupos_ocup_nova " ativ/ramo do neg�cio na semana - c�digos CNAE-Domiciliar"
* A partir de 2002, a classifica��o mudou totalmente. 
* grupos_ocup_nova = 1 dirigentes em geral
*			 = 2 profissionais das ci�ncias e das artes
*			 = 3 t�cnicos de n�vel m�dio
*			 = 4 trabalhadores de serv. administr.
*			 = 5 trabalhadores dos serv.
*			 = 6 vendedores e prestadores de serv. do com�rcio
*			 = 7 trabalhadores agr�colas
*			 = 8 trabalhadores da prod. de bens e serv. e de repara��o e manuten��o
*			 = 9 membros das for�as armadas e auxiliares
*			 = 10 ocupa��es mal-definidas ou n�o declaradas

/* C.12.3 RENAME: ATIVIDADE/RAMOS DO NEG�CIO */
* v9907 � mais desagregado - c�digos variam ao longo do tempo
* v4809 � mais agregado e comum entre os anos das PNAD's

rename v9907 ramo_negocio_sem_nova
label var ramo_negocio_sem "ativ/ramo do neg�cio na semana - c�d. CNAE-Dom"

rename v4809 ramo_negocio_agreg_nova
label var ramo_negocio_agreg_nova "grupos de ativ/ramo do neg�cio na semana"
* A partir de 2002, a classifica��o mudou totalmente. 
* ramo_negocio_agreg_nova = 1 agr�cola
*                         = 2 outras ativ
*                         = 3 ind. transf.
*                         = 4 constr.
*                         = 5 com�rcio e repara��o
*                         = 6 alojamento e alimenta��o
*                         = 7 transp., armazenagem e comunica��o
*                         = 8 administr. p�blica
*                         = 9 educa��o, sa�de e servi�os sociais
*                         = 10 serv. dom�sticos
*                         = 11 outros serv. coletivos, sociais e pessoais
*                         = 12 outras ativ.
*                         = 13 ativ. mal definidas ou n�o-declaradas


/* C.12.4 RECODE: POSI��O NA OCUPA��O NA SEMANA */
* v9008 e v9029 s�o mais detalhados, mas de dif�cil compatibiliza��o com as PNAD's dos anos 80
	* foram dropadas	
drop v9008 v9029
* v4706 � mais agregado, e � mais f�cil compatibilizar com as PNAD's dos anos 80

recode v4706 (0 14=.) (2/8=1) (9=2) (10=3) (11 12=.) (13=4)
rename v4706 pos_ocup_sem
label var pos_ocup_sem "posi��o na ocupa��o na semana"
* Trabalhadores na prod/constr para consumo/uso pr�prio foram exclu�dos
* da categoria "empregados", pois n�o eram considerados assim nas PNAD's dos aos 80.
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
recode v9058 (-1 99 0 =.)
replace v9058 = . if tinha_trab_sem == 0 & trabalhou==0
rename v9058 horas_trab_sem
label var horas_trab_sem  "horas normal. trab. sem - ocup. princ"

/* HORAS NORMALMENTE TRABALHADAS - OUTRO TRABALHO */
recode v9101 (-1 99 0 =.)
replace v9101 = . if tinha_trab_sem == 0 & trabalhou==0
rename v9101 horas_trab_sem_outro
label var horas_trab_sem_outro "work hours second job - week"

/* HORAS NORMALMENTE TRABALHADAS TODOS TRABALHOS */
recode v9105 (-1 99=.)
egen horas_trab_todos_trab = rowtotal(horas_trab_sem horas_trab_sem_outro v9105), miss
replace horas_trab_todos_trab = . if tinha_trab_sem == 0 & trabalhou==0
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
label var renda_mensal_prod_outra "renda mensal em produtos em outrs trabalhos"

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
label var renda_abono "rendimento de abono"

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
label var renda_outras "valor de outros rendimentos"

/* C.13.10 RECODE: REND MENSAL OCUP PRINCIPAL */
recode v4718 (-1 999999999999=.) 
rename v4718 renda_mensal_ocup_prin
recode renda_mensal_ocup_prin (0=.) if renda_mensal_din == . & renda_mensal_din == .

/* C.13.11 RECODE: REND MENSAL TODOS TRABALHOS */
recode v4719 (-1 999999999999=.) 
rename v4719 renda_mensal_todos_trab
recode renda_mensal_todos_trab (0=.) if renda_mensal_din == . & renda_mensal_din == . ///
& renda_mensal_din_outra == . & renda_mensal_prod_outra == . ///
& v1022 ==. & v1025 == .

/* C.13.12 RECODE: REND MENSAL TODAS FONTES */
recode v4720 (-1 999999999999=.) 
rename v4720 renda_mensal_todas_fontes
recode renda_mensal_todas_fontes (0=.) if renda_mensal_din == . ///
& renda_mensal_prod == . & renda_aposentadoria == . ///
& renda_pensao == . & renda_outras == . & renda_abono == . ///
& renda_aluguel == . 

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
* A partir da d�cada de 90, esta informa��o n�o pode ser obtida para todos os indiv�duos.

/* INFORMA��ES SOBRE O EMPREGO ANTERIOR */
* COMO NOS ANOS 80 � SIMPLESMENTE O �LTIMO TRABALHO
* (DE QUEM N�O TRABALHOU NA SEMANA DE REFE�NCIA) 
* AS INFORMA��ES SOBRE O TRABALHO ANTERIOR
* DOS ANOS 80 E 90 N�O S�O PERFEITAMENTE COMPAT�VEIS.

/* DUMMY: N�O TRABALHOU NA SEMANA E DEIXOU �LTIMO EMPREGO NO �LTIMO ANO - 12 MESES OU MENOS */
/*		VARI�VEL TEMPOR�RIA                                                                      */
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
/*	NA SEMANA DE REFER�NCIA: APENAS QUEM N�O TINHA TRABALHO NA SEMANA */
replace v9115 = . if tinha_trab_sem == 1
recode v9115 (3=0) (9=.)
rename v9115 tomou_prov_semana
* tomou_prov_semana = 1 sim
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
* tomou_prov = 1 sim
*            = 0 n�o
drop v9116 v9117

/* C.19 RECODE: QUE PROV. TOMOU PARA CONSEGUIR TRABALHO */
* Nas PNAD's dos anos 80, a pergunta � feita apenas para quem respondeu "sim"
* � pergunta anterior (tomou prov. cons. trab - 2 meses)
* Nas PNAD's dos anos 90, a pergunta � sobre a �ltima prov. que tomou, e se aplica a todos os indiv�duos.
* Isto � ajustado a seguir.
gen que_prov_tomou = v9119 if trabalhou_semana==0 & tinha_trab_sem==0
recode que_prov_tomou (0=7) (3=2) (7 8=6) (4=3) (5=4) (6=5) (9=.)
label var que_prov_tomou "que providencia tomou para conseguir trabalho"
* que_prov_tomou = 1 consultou empregador
*                                 = 2 fez concurso
*                                 = 3 consultou ag�ncia/sindicato
*                                 = 4 colocou an�ncio
*                                 = 5 consultou parente
*                                 = 6 outra
*                                 = 7 nada fez
drop v9003 v9004 v9119 teve_algum_trab_ano

/* D. DEFLACIONANDO E CONVERTENDO UNIDADES MONET�RIAS PARA REAIS */

/* CONVERTENDO OS VALORES NOMINAIS PARA REAIS (UNIDADE MONET�RIA) */
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
replace deflator    =.  if ano == 2015


label var deflator "deflator - base:out/2012"

gen double conversor = 1

label var conversor "conversor de moedas"

foreach i in din_outra prod_outra ocup_prin todos_trab todas_fontes din prod {
	g renda_`i'_def = (renda_mensal_`i'/conversor)/deflator 
	lab var renda_`i'_def "renda_mensal_`i' deflacionada"
}

foreach i in aposentadoria pensao abono aluguel outras {
	g renda_`i'_def = (renda_`i'/conversor)/deflator
	lab var renda_`i'_def "renda_`i' deflacionada"
}

drop v*
compress

end
