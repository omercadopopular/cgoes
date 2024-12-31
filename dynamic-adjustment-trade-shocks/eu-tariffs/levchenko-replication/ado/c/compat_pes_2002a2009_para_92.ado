************************************************************
**************compat_pess_2002a2009_para_92.ado*************
************************************************************
program define compat_pes_2002a2009_para_92

/* A.1 RECODE: ANO */
* nada a fazer

/* A.2 NÚMERO DE CONTROLE E SÉRIE */

drop v0102 v0103
destring uf, replace

/* B. DATA DE NASCIMENTO */
recode v3031 v3032 (99 =.)
recode v3032 (20 = .)
recode v3033 (min/98 9999 = .)
recode v3031 (0 = .)
cap drop v0408

/* B.2 CARACTERISTICAS DE MIGRACAO */
* OBS: v5062 v0507 v5122: a partir de 2007, nao possui codigo para "ignorado"
recode v5030 v5080 v5090 (99 =.)
recode v0501 v0502 v0504 v0505 v5062 v0507 v0510 v0511 v5122 (9 = .)
recode v5062 v5122 (8 = .)
recode v5064 v5124 (0 = .)

foreach var in v5126 {
	cap drop `var'
}

/* C. VARIÁVEIS DE EDUCAÇÃO */
recode v0601 v0602 v0611 (0 9 = .)

/* C.1 RECODE: ANOS DE ESTUDO */

/* VARIÁVEIS UTILIZADAS PARA 2002 A 2006*/
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

generate byte anoest = .
quietly summarize v0101
loc min = r(min)
loc max = r(max)

if `min' <= 2006 {
/* 2002 a 2006 */
/* pessoas que ainda freqüentam escola */
	replace anoest =0 if v0602==2 & v0603==1 & v0605==1 & v0101 <= 2006
	replace anoest =1 if v0602==2 & v0603==1 & v0605==2 & v0101 <= 2006
	replace anoest =2 if v0602==2 & v0603==1 & v0605==3 & v0101 <= 2006
	replace anoest =3 if v0602==2 & v0603==1 & v0605==4 & v0101 <= 2006
	replace anoest =4 if v0602==2 & v0603==1 & v0605==5 & v0101 <= 2006
	replace anoest =5 if v0602==2 & v0603==1 & v0605==6 & v0101 <= 2006
	replace anoest =6 if v0602==2 & v0603==1 & v0605==7 & v0101 <= 2006
	replace anoest =7 if v0602==2 & v0603==1 & v0605==8 & v0101 <= 2006

	replace anoest =8 if v0602==2 & v0603==2 & v0605==1 & v0101 <= 2006
	replace anoest =9 if v0602==2 & v0603==2 & v0605==2 & v0101 <= 2006
	replace anoest =10 if v0602==2 & v0603==2 & v0605==3 & v0101 <= 2006
	replace anoest =11 if v0602==2 & v0603==2 & v0605==4 & v0101 <= 2006

	replace anoest =0 if v0602==2 & v0603==3 & v0604==2 & v0605==1 & v0101 <= 2006
	replace anoest =1 if v0602==2 & v0603==3 & v0604==2 & v0605==2 & v0101 <= 2006
	replace anoest =2 if v0602==2 & v0603==3 & v0604==2 & v0605==3 & v0101 <= 2006
	replace anoest =3 if v0602==2 & v0603==3 & v0604==2 & v0605==4 & v0101 <= 2006
	replace anoest =4 if v0602==2 & v0603==3 & v0604==2 & v0605==5 & v0101 <= 2006
	replace anoest =5 if v0602==2 & v0603==3 & v0604==2 & v0605==6 & v0101 <= 2006
	replace anoest =6 if v0602==2 & v0603==3 & v0604==2 & v0605==7 & v0101 <= 2006
	replace anoest =7 if v0602==2 & v0603==3 & v0604==2 & v0605==8 & v0101 <= 2006

	replace anoest =0 if v0602==2 & v0603==3 & v0604==4  & v0101 <= 2006

	replace anoest =8 if v0602==2 & v0603==4 & v0604==2 & v0605==1 & v0101 <= 2006
	replace anoest =9 if v0602==2 & v0603==4 & v0604==2 & v0605==2 & v0101 <= 2006
	replace anoest =10 if v0602==2 & v0603==4 & v0604==2 & v0605==3 & v0101 <= 2006
	replace anoest =11 if v0602==2 & v0603==4 & v0604==2 & v0605==4 & v0101 <= 2006

	replace anoest =8 if v0602==2 & v0603==4 & v0604==4  & v0101 <= 2006

	replace anoest =11 if v0602==2 & v0603==5 & v0605==1 & v0101 <= 2006
	replace anoest =12 if v0602==2 & v0603==5 & v0605==2 & v0101 <= 2006
	replace anoest =13 if v0602==2 & v0603==5 & v0605==3 & v0101 <= 2006
	replace anoest =14 if v0602==2 & v0603==5 & v0605==4 & v0101 <= 2006
	replace anoest =15 if v0602==2 & v0603==5 & v0605==5 & v0101 <= 2006
	replace anoest =16 if v0602==2 & v0603==5 & v0605==6 & v0101 <= 2006

	replace anoest =0 if v0602==2 & v0603==6 & v0101 <= 2006
	replace anoest =0 if v0602==2 & v0603==7 & v0101 <= 2006
	replace anoest =0 if v0602==2 & v0603==8 & v0101 <= 2006
	replace anoest =11 if v0602==2 & v0603==9 & v0101 <= 2006
	replace anoest =15 if v0602==2 & v0603==10 & v0101 <= 2006

/* pessoas que não freqüentam */

	replace anoest =1 if v0602==4 & v0606==2 & v0607==1 & v0609==1 & v0610==1 & v0101 <= 2006
	replace anoest =2 if v0602==4 & v0606==2 & v0607==1 & v0609==1 & v0610==2 & v0101 <= 2006
	replace anoest =3 if v0602==4 & v0606==2 & v0607==1 & v0609==1 & v0610==3 & v0101 <= 2006
	replace anoest =4 if v0602==4 & v0606==2 & v0607==1 & v0609==1 & v0610==4 & v0101 <= 2006
	replace anoest =4 if v0602==4 & v0606==2 & v0607==1 & v0609==1 & v0610==5 & v0101 <= 2006
	replace anoest =4 if v0602==4 & v0606==2 & v0607==1 & v0609==1 & v0610==6 & v0101 <= 2006

	replace anoest =0 if v0602==4 & v0606==2 & v0607==1 & v0609==3 & v0101 <= 2006

	replace anoest =5 if v0602==4 & v0606==2 & v0607==2 & v0608==2 & v0609==1 & v0610==1 & v0101 <= 2006
	replace anoest =6 if v0602==4 & v0606==2 & v0607==2 & v0608==2 & v0609==1 & v0610==2 & v0101 <= 2006
	replace anoest =7 if v0602==4 & v0606==2 & v0607==2 & v0608==2 & v0609==1 & v0610==3 & v0101 <= 2006
	replace anoest =8 if v0602==4 & v0606==2 & v0607==2 & v0608==2 & v0609==1 & v0610==4 & v0101 <= 2006
	replace anoest =8 if v0602==4 & v0606==2 & v0607==2 & v0608==2 & v0609==1 & v0610==5 & v0101 <= 2006

	replace anoest =4 if v0602==4 & v0606==2 & v0607==2 & v0608==2 & v0609==3 & v0101 <= 2006

	replace anoest =8 if v0602==4 & v0606==2 & v0607==2 & v0608==4 & v0611==1 & v0101 <= 2006
	replace anoest =4 if v0602==4 & v0606==2 & v0607==2 & v0608==4 & v0611==3 & v0101 <= 2006

	replace anoest =9 if v0602==4 & v0606==2 & v0607==3 & v0608==2 & v0609==1 & v0610==1 & v0101 <= 2006
	replace anoest =10 if v0602==4 & v0606==2 & v0607==3 & v0608==2 & v0609==1 & v0610==2 & v0101 <= 2006
	replace anoest =11 if v0602==4 & v0606==2 & v0607==3 & v0608==2 & v0609==1 & v0610==3 & v0101 <= 2006
	replace anoest =11 if v0602==4 & v0606==2 & v0607==3 & v0608==2 & v0609==1 & v0610==4 & v0101 <= 2006

	replace anoest =8 if v0602==4 & v0606==2 & v0607==3 & v0608==2 & v0609==3 & v0101 <= 2006

	replace anoest =11 if v0602==4 & v0606==2 & v0607==3 & v0608==4 & v0611==1 & v0101 <= 2006
	replace anoest =8 if v0602==4 & v0606==2 & v0607==3 & v0608==4 & v0611==3 & v0101 <= 2006

	replace anoest =1 if v0602==4 & v0606==2 & v0607==4 & v0608==2 & v0609==1 & v0610==1 & v0101 <= 2006
	replace anoest =2 if v0602==4 & v0606==2 & v0607==4 & v0608==2 & v0609==1 & v0610==2 & v0101 <= 2006
	replace anoest =3 if v0602==4 & v0606==2 & v0607==4 & v0608==2 & v0609==1 & v0610==3 & v0101 <= 2006
	replace anoest =4 if v0602==4 & v0606==2 & v0607==4 & v0608==2 & v0609==1 & v0610==4 & v0101 <= 2006
	replace anoest =5 if v0602==4 & v0606==2 & v0607==4 & v0608==2 & v0609==1 & v0610==5 & v0101 <= 2006
	replace anoest =6 if v0602==4 & v0606==2 & v0607==4 & v0608==2 & v0609==1 & v0610==6 & v0101 <= 2006
	replace anoest =7 if v0602==4 & v0606==2 & v0607==4 & v0608==2 & v0609==1 & v0610==7 & v0101 <= 2006
	replace anoest =8 if v0602==4 & v0606==2 & v0607==4 & v0608==2 & v0609==1 & v0610==8 & v0101 <= 2006

	replace anoest =0 if v0602==4 & v0606==2 & v0607==4 & v0608==2 & v0609==3 & v0101 <= 2006

	replace anoest =8 if v0602==4 & v0606==2 & v0607==4 & v0608==4 & v0611==1 & v0101 <= 2006
	replace anoest =0 if v0602==4 & v0606==2 & v0607==4 & v0608==4 & v0611==3 & v0101 <= 2006

	replace anoest =9 if v0602==4 & v0606==2 & v0607==5 & v0608==2 & v0609==1 & v0610==1 & v0101 <= 2006
	replace anoest =10 if v0602==4 & v0606==2 & v0607==5 & v0608==2 & v0609==1 & v0610==2 & v0101 <= 2006
	replace anoest =11 if v0602==4 & v0606==2 & v0607==5 & v0608==2 & v0609==1 & v0610==3 & v0101 <= 2006
	replace anoest =11 if v0602==4 & v0606==2 & v0607==5 & v0608==2 & v0609==1 & v0610==4 & v0101 <= 2006

	replace anoest =8 if v0602==4 & v0606==2 & v0607==5 & v0608==2 & v0609==3 & v0101 <= 2006

	replace anoest =11 if v0602==4 & v0606==2 & v0607==5 & v0608==4 & v0611==1 & v0101 <= 2006
	replace anoest =8 if v0602==4 & v0606==2 & v0607==5 & v0608==4 & v0611==3 & v0101 <= 2006

	replace anoest =12 if v0602==4 & v0606==2 & v0607==6 & v0609==1 & v0610==1 & v0101 <= 2006
	replace anoest =13 if v0602==4 & v0606==2 & v0607==6 & v0609==1 & v0610==2 & v0101 <= 2006
	replace anoest =14 if v0602==4 & v0606==2 & v0607==6 & v0609==1 & v0610==3 & v0101 <= 2006

	replace anoest =15 if v0602==4 & v0606==2 & v0607==6 & v0609==1 & v0610==4 & v0101 <= 2006
	replace anoest =16 if v0602==4 & v0606==2 & v0607==6 & v0609==1 & v0610==5 & v0101 <= 2006
	replace anoest =17 if v0602==4 & v0606==2 & v0607==6 & v0609==1 & v0610==6 & v0101 <= 2006

	replace anoest =11 if v0602==4 & v0606==2 & v0607==6 & v0609==3 & v0101 <= 2006

	replace anoest =17 if v0602==4 & v0606==2 & v0607==7 & v0611==1 & v0101 <= 2006
	replace anoest =15 if v0602==4 & v0606==2 & v0607==7 & v0611==3 & v0101 <= 2006

	replace anoest =0 if v0602==4 & v0606==2 & v0607==8 & v0101 <= 2006
	replace anoest =0 if v0602==4 & v0606==2 & v0607==9 & v0101 <= 2006
	replace anoest =0 if v0602==4 & v0606==2 & v0607==10 & v0101 <= 2006

	replace anoest =0 if v0602==4 & v0606==4 & v0101 <= 2006
}

if `max' >= 2007 {
/* 2007 a 2009 */
/* pessoas que ainda freqüentam escola */
	replace anoest =0 if v0602==2 & v6003==1 & v6030==1 & v0605==1 & v0101 >= 2007
	replace anoest =1 if v0602==2 & v6003==1 & v6030==1 & v0605==2 & v0101 >= 2007
	replace anoest =2 if v0602==2 & v6003==1 & v6030==1 & v0605==3 & v0101 >= 2007
	replace anoest =3 if v0602==2 & v6003==1 & v6030==1 & v0605==4 & v0101 >= 2007
	replace anoest =4 if v0602==2 & v6003==1 & v6030==1 & v0605==5 & v0101 >= 2007
	replace anoest =5 if v0602==2 & v6003==1 & v6030==1 & v0605==6 & v0101 >= 2007
	replace anoest =6 if v0602==2 & v6003==1 & v6030==1 & v0605==7 & v0101 >= 2007
	replace anoest =7 if v0602==2 & v6003==1 & v6030==1 & v0605==8 & v0101 >= 2007

	replace anoest =0 if v0602==2 & v6003==1 & v6030==3 & v0605==1 & v0101 >= 2007
	replace anoest =0 if v0602==2 & v6003==1 & v6030==3 & v0605==2 & v0101 >= 2007
	replace anoest =1 if v0602==2 & v6003==1 & v6030==3 & v0605==3 & v0101 >= 2007
	replace anoest =2 if v0602==2 & v6003==1 & v6030==3 & v0605==4 & v0101 >= 2007
	replace anoest =3 if v0602==2 & v6003==1 & v6030==3 & v0605==5 & v0101 >= 2007
	replace anoest =4 if v0602==2 & v6003==1 & v6030==3 & v0605==6 & v0101 >= 2007
	replace anoest =5 if v0602==2 & v6003==1 & v6030==3 & v0605==7 & v0101 >= 2007
	replace anoest =6 if v0602==2 & v6003==1 & v6030==3 & v0605==8 & v0101 >= 2007
	replace anoest =7 if v0602==2 & v6003==1 & v6030==3 & v0605==0 & v0101 >= 2007

	replace anoest =8 if v0602==2 & v6003==2 & v0605==1 & v0101 >= 2007
	replace anoest =9 if v0602==2 & v6003==2 & v0605==2 & v0101 >= 2007
	replace anoest =10 if v0602==2 & v6003==2 & v0605==3 & v0101 >= 2007
	replace anoest =11 if v0602==2 & v6003==2 & v0605==4 & v0101 >= 2007

	replace anoest =0 if v0602==2 & v6003==3 & v0604==2 & v0605==1 & v0101 >= 2007
	replace anoest =1 if v0602==2 & v6003==3 & v0604==2 & v0605==2 & v0101 >= 2007
	replace anoest =2 if v0602==2 & v6003==3 & v0604==2 & v0605==3 & v0101 >= 2007
	replace anoest =3 if v0602==2 & v6003==3 & v0604==2 & v0605==4 & v0101 >= 2007
	replace anoest =4 if v0602==2 & v6003==3 & v0604==2 & v0605==5 & v0101 >= 2007
	replace anoest =5 if v0602==2 & v6003==3 & v0604==2 & v0605==6 & v0101 >= 2007
	replace anoest =6 if v0602==2 & v6003==3 & v0604==2 & v0605==7 & v0101 >= 2007
	replace anoest =7 if v0602==2 & v6003==3 & v0604==2 & v0605==8 & v0101 >= 2007

	replace anoest =0 if v0602==2 & v6003==3 & v0604==4  & v0101 >= 2007

	replace anoest =8 if v0602==2 & v6003==4 & v0604==2 & v0605==1 & v0101 >= 2007
	replace anoest =9 if v0602==2 & v6003==4 & v0604==2 & v0605==2 & v0101 >= 2007
	replace anoest =10 if v0602==2 & v6003==4 & v0604==2 & v0605==3 & v0101 >= 2007
	replace anoest =11 if v0602==2 & v6003==4 & v0604==2 & v0605==4 & v0101 >= 2007

	replace anoest =8 if v0602==2 & v6003==4 & v0604==4  & v0101 >= 2007

	replace anoest =11 if v0602==2 & v6003==5 & v0605==1 & v0101 >= 2007
	replace anoest =12 if v0602==2 & v6003==5 & v0605==2 & v0101 >= 2007
	replace anoest =13 if v0602==2 & v6003==5 & v0605==3 & v0101 >= 2007
	replace anoest =14 if v0602==2 & v6003==5 & v0605==4 & v0101 >= 2007
	replace anoest =15 if v0602==2 & v6003==5 & v0605==5 & v0101 >= 2007
	replace anoest =16 if v0602==2 & v6003==5 & v0605==6 & v0101 >= 2007

	replace anoest =0 if v0602==2 & v6003==6 & v0101 >= 2007
	replace anoest =0 if v0602==2 & v6003==7 & v0101 >= 2007
	replace anoest =0 if v0602==2 & v6003==8 & v0101 >= 2007
	replace anoest =0 if v0602==2 & v6003==9 & v0101 >= 2007
	replace anoest =11 if v0602==2 & v6003==10 & v0101 >= 2007
	replace anoest =15 if v0602==2 & v6003==11 & v0101 >= 2007

/* pessoas que não freqüentam */

	replace anoest =1 if v0602==4 & v0606==2 & v6007==1 & v0609==1 & v0610==1 & v0101 >= 2007
	replace anoest =2 if v0602==4 & v0606==2 & v6007==1 & v0609==1 & v0610==2 & v0101 >= 2007
	replace anoest =3 if v0602==4 & v0606==2 & v6007==1 & v0609==1 & v0610==3 & v0101 >= 2007
	replace anoest =4 if v0602==4 & v0606==2 & v6007==1 & v0609==1 & v0610==4 & v0101 >= 2007
	replace anoest =4 if v0602==4 & v0606==2 & v6007==1 & v0609==1 & v0610==5 & v0101 >= 2007
	replace anoest =4 if v0602==4 & v0606==2 & v6007==1 & v0609==1 & v0610==6 & v0101 >= 2007

	replace anoest =0 if v0602==4 & v0606==2 & v6007==1 & v0609==3 & v0101 >= 2007

	replace anoest =5 if v0602==4 & v0606==2 & v6007==2 & v0608==2 & v0609==1 & v0610==1 & v0101 >= 2007
	replace anoest =6 if v0602==4 & v0606==2 & v6007==2 & v0608==2 & v0609==1 & v0610==2 & v0101 >= 2007
	replace anoest =7 if v0602==4 & v0606==2 & v6007==2 & v0608==2 & v0609==1 & v0610==3 & v0101 >= 2007
	replace anoest =8 if v0602==4 & v0606==2 & v6007==2 & v0608==2 & v0609==1 & v0610==4 & v0101 >= 2007
	replace anoest =8 if v0602==4 & v0606==2 & v6007==2 & v0608==2 & v0609==1 & v0610==5 & v0101 >= 2007

	replace anoest =4 if v0602==4 & v0606==2 & v6007==2 & v0608==2 & v0609==3 & v0101 >= 2007

	replace anoest =8 if v0602==4 & v0606==2 & v6007==2 & v0608==4 & v0611==1 & v0101 >= 2007
	replace anoest =4 if v0602==4 & v0606==2 & v6007==2 & v0608==4 & v0611==3 & v0101 >= 2007

	replace anoest =9 if v0602==4 & v0606==2 & v6007==3 & v0608==2 & v0609==1 & v0610==1 & v0101 >= 2007
	replace anoest =10 if v0602==4 & v0606==2 & v6007==3 & v0608==2 & v0609==1 & v0610==2 & v0101 >= 2007
	replace anoest =11 if v0602==4 & v0606==2 & v6007==3 & v0608==2 & v0609==1 & v0610==3 & v0101 >= 2007
	replace anoest =11 if v0602==4 & v0606==2 & v6007==3 & v0608==2 & v0609==1 & v0610==4 & v0101 >= 2007

	replace anoest =8 if v0602==4 & v0606==2 & v6007==3 & v0608==2 & v0609==3 & v0101 >= 2007

	replace anoest =11 if v0602==4 & v0606==2 & v6007==3 & v0608==4 & v0611==1 & v0101 >= 2007
	replace anoest =8 if v0602==4 & v0606==2 & v6007==3 & v0608==4 & v0611==3 & v0101 >= 2007

	replace anoest =1 if v0602==4 & v0606==2 & v6007==4 & v6070==1 & v0609==1 & v0610==1 & v0101 >= 2007
	replace anoest =2 if v0602==4 & v0606==2 & v6007==4 & v6070==1 & v0609==1 & v0610==2 & v0101 >= 2007
	replace anoest =3 if v0602==4 & v0606==2 & v6007==4 & v6070==1 & v0609==1 & v0610==3 & v0101 >= 2007
	replace anoest =4 if v0602==4 & v0606==2 & v6007==4 & v6070==1 & v0609==1 & v0610==4 & v0101 >= 2007
	replace anoest =5 if v0602==4 & v0606==2 & v6007==4 & v6070==1 & v0609==1 & v0610==5 & v0101 >= 2007
	replace anoest =6 if v0602==4 & v0606==2 & v6007==4 & v6070==1 & v0609==1 & v0610==6 & v0101 >= 2007
	replace anoest =7 if v0602==4 & v0606==2 & v6007==4 & v6070==1 & v0609==1 & v0610==7 & v0101 >= 2007
	replace anoest =8 if v0602==4 & v0606==2 & v6007==4 & v6070==1 & v0609==1 & v0610==8 & v0101 >= 2007

	replace anoest =0 if v0602==4 & v0606==2 & v6007==4 & v6070==1 & v0609==3 & v0101 >= 2007

	replace anoest =0 if v0602==4 & v0606==2 & v6007==4 & v6070==3 & v0609==1 & v0610==1 & v0101 >= 2007
	replace anoest =1 if v0602==4 & v0606==2 & v6007==4 & v6070==3 & v0609==1 & v0610==2 & v0101 >= 2007
	replace anoest =2 if v0602==4 & v0606==2 & v6007==4 & v6070==3 & v0609==1 & v0610==3 & v0101 >= 2007
	replace anoest =3 if v0602==4 & v0606==2 & v6007==4 & v6070==3 & v0609==1 & v0610==4 & v0101 >= 2007
	replace anoest =4 if v0602==4 & v0606==2 & v6007==4 & v6070==3 & v0609==1 & v0610==5 & v0101 >= 2007
	replace anoest =5 if v0602==4 & v0606==2 & v6007==4 & v6070==3 & v0609==1 & v0610==6 & v0101 >= 2007
	replace anoest =6 if v0602==4 & v0606==2 & v6007==4 & v6070==3 & v0609==1 & v0610==7 & v0101 >= 2007
	replace anoest =7 if v0602==4 & v0606==2 & v6007==4 & v6070==3 & v0609==1 & v0610==8 & v0101 >= 2007
	replace anoest =8 if v0602==4 & v0606==2 & v6007==4 & v6070==3 & v0609==1 & v0610==0 & v0101 >= 2007

	replace anoest =0 if v0602==4 & v0606==2 & v6007==4 & v6070==3 & v0609==3 & v0101 >= 2007

	replace anoest =9 if v0602==4 & v0606==2 & v6007==5 & v0609==1 & v0610==1 & v0101 >= 2007
	replace anoest =10 if v0602==4 & v0606==2 & v6007==5 & v0609==1 & v0610==2 & v0101 >= 2007
	replace anoest =11 if v0602==4 & v0606==2 & v6007==5 & v0609==1 & v0610==3 & v0101 >= 2007
	replace anoest =11 if v0602==4 & v0606==2 & v6007==5 & v0609==1 & v0610==4 & v0101 >= 2007

	replace anoest =8 if v0602==4 & v0606==2 & v6007==5 & v0609==3 & v0101 >= 2007

	replace anoest =1 if v0602==4 & v0606==2 & v6007==6 & v0608==2 & v0609==1 & v0610==1 & v0101 >= 2007
	replace anoest =2 if v0602==4 & v0606==2 & v6007==6 & v0608==2 & v0609==1 & v0610==2 & v0101 >= 2007
	replace anoest =3 if v0602==4 & v0606==2 & v6007==6 & v0608==2 & v0609==1 & v0610==3 & v0101 >= 2007
	replace anoest =4 if v0602==4 & v0606==2 & v6007==6 & v0608==2 & v0609==1 & v0610==4 & v0101 >= 2007
	replace anoest =5 if v0602==4 & v0606==2 & v6007==6 & v0608==2 & v0609==1 & v0610==5 & v0101 >= 2007
	replace anoest =6 if v0602==4 & v0606==2 & v6007==6 & v0608==2 & v0609==1 & v0610==6 & v0101 >= 2007
	replace anoest =7 if v0602==4 & v0606==2 & v6007==6 & v0608==2 & v0609==1 & v0610==7 & v0101 >= 2007
	replace anoest =8 if v0602==4 & v0606==2 & v6007==6 & v0608==2 & v0609==1 & v0610==8 & v0101 >= 2007

	replace anoest =0 if v0602==4 & v0606==2 & v6007==6 & v0608==2 & v0609==3 & v0101 >= 2007

	replace anoest =8 if v0602==4 & v0606==2 & v6007==6 & v0608==4 & v0611==1 & v0101 >= 2007
	replace anoest =0 if v0602==4 & v0606==2 & v6007==6 & v0608==4 & v0611==3 & v0101 >= 2007

	replace anoest =9 if v0602==4 & v0606==2 & v6007==7 & v0608==2 & v0609==1 & v0610==1 & v0101 >= 2007
	replace anoest =10 if v0602==4 & v0606==2 & v6007==7 & v0608==2 & v0609==1 & v0610==2 & v0101 >= 2007
	replace anoest =11 if v0602==4 & v0606==2 & v6007==7 & v0608==2 & v0609==1 & v0610==3 & v0101 >= 2007
	replace anoest =11 if v0602==4 & v0606==2 & v6007==7 & v0608==2 & v0609==1 & v0610==4 & v0101 >= 2007

	replace anoest =8 if v0602==4 & v0606==2 & v6007==7 & v0608==2 & v0609==3 & v0101 >= 2007

	replace anoest =11 if v0602==4 & v0606==2 & v6007==7 & v0608==4 & v0611==1 & v0101 >= 2007
	replace anoest =8 if v0602==4 & v0606==2 & v6007==7 & v0608==4 & v0611==3 & v0101 >= 2007

	replace anoest =12 if v0602==4 & v0606==2 & v6007==8 & v0609==1 & v0610==1 & v0101 >= 2007
	replace anoest =13 if v0602==4 & v0606==2 & v6007==8 & v0609==1 & v0610==2 & v0101 >= 2007
	replace anoest =14 if v0602==4 & v0606==2 & v6007==8 & v0609==1 & v0610==3 & v0101 >= 2007
	replace anoest =15 if v0602==4 & v0606==2 & v6007==8 & v0609==1 & v0610==4 & v0101 >= 2007
	replace anoest =16 if v0602==4 & v0606==2 & v6007==8 & v0609==1 & v0610==5 & v0101 >= 2007
	replace anoest =17 if v0602==4 & v0606==2 & v6007==8 & v0609==1 & v0610==6 & v0101 >= 2007

	replace anoest =11 if v0602==4 & v0606==2 & v6007==8 & v0609==3 & v0101 >= 2007

	replace anoest =17 if v0602==4 & v0606==2 & v6007==9 & v0611==1 & v0101 >= 2007
	replace anoest =15 if v0602==4 & v0606==2 & v6007==9 & v0611==3 & v0101 >= 2007

	replace anoest =0 if v0602==4 & v0606==2 & v6007==10 & v0101 >= 2007
	replace anoest =0 if v0602==4 & v0606==2 & v6007==11 & v0101 >= 2007
	replace anoest =0 if v0602==4 & v0606==2 & v6007==12 & v0101 >= 2007
	replace anoest =0 if v0602==4 & v0606==2 & v6007==13 & v0101 >= 2007

	replace anoest =0 if v0602==4 & v0606==4 & v0101 >= 2007
}
label var anoest "anos de estudo"



/* C.2 RECODE: SÉRIE QUE FREQÜENTA NA ESCOLA */

if `max' >= 2007 {
* A PARTIR DE 2007, HÁ A POSSIBILIDADE DE O ENSINO FUNDAMENTAL SER EM 9 ANOS
* NESSE CASO, O "PRIMEIRO ANO" EQUIVALE À "CLASSE DE ALFABETIZAÇÃO".
	recode v6003 (1=8) if v6030 == 3 & v0605 == 1
	recode v6007 (4=12) if v6070 == 3 & v0610 == 1
	recode v0605 (1=.) (2=1) (3=2) (4=3) (5=4) (6=5) (7=6) (8=7) (0=8) if v6030 == 3
	recode v0610 (1=.) (2=1) (3=2) (4=3) (5=4) (6=5) (7=6) (8=7) (0=8) if v6070 == 3
}
recode v0605 (9=.)
rename v0605 serie_freq
label var serie_freq "série - frequenta escola"

/* C.3 RECODE: CURSO QUE FREQÜENTA NA ESCOLA */
generate byte curso_freq = .

if `max' <= 2006 {
	recode v0603 (0=.) 
	recode v0603 (8=7) (9=8) (10=9)
	replace curso_freq = v0603 if v0101 <= 2006
}

if `max' >= 2007 {
* EM 2007, SURGIU A CATEGORIA "CLASSE DE ALFABETIZAÇÃO"
* ANTERIORMENTE ELA SE INCLUÍA EM "PRÉ-ESCOLAR OU CRECHE"
	recode v6003 (8 9=7) (10=8) (11=9)
	replace curso_freq = v6003 if v0101 >= 2007
}

label var curso_freq "curso - frequenta escola"
* curso_freq = 1 regular primeiro grau
*           = 2 regular segundo grau
*           = 3 supl primeiro grau
*           = 4 supl segundo grau
*           = 5 superior
*           = 6 alfab de adultos
*           = 7 pré-escolar ou creche
*           = 8 pré-vestibular
*           = 9 mestrado/doutorado


/* C.4 RECODE: SÉRIE - NÃO FREQUENTA ESCOLA */
recode v0610 (9=.)
rename v0610 serie_nao_freq
label var serie_nao_freq "série - não frequenta escola"
* Observação: no primário - v0607==1 - podem existir até 6 séries, e não apenas 4.
*             no médio, primeiro ciclo - v0607==2 - até 5 séries, não apenas 4.
*             no médio, segundo ciclo - v0607==3 - 4 séries, não apenas 3.
*             no segundo grau - v0607==5 - 4 séries, não apenas 3.


/* C.5 RECODE: curso NÃO FREQÜENTA NA ESCOLA */
generate byte curso_nao_freq = .

if `max' <= 2006 {
	recode v0607 (0=.) 
	recode v0607 (8=7) (9=8) (10=9)
	replace curso_nao_freq = v0607 if v0101 <= 2006
	drop v0603 v0607
}

if `max' >= 2007 {
	recode v6007 (6=4) (7=5) (8=6) (9=7) (10=8) (11/13=9)
	replace curso_nao_freq = v6007 if v0101 >= 2007
	drop v6003 v6030 v6007 v6070
}

label var curso_nao_freq "curso - não frequenta"
* curso_nao_freq = 1 elementar (primário)
*               = 2 médio primeiro ciclo (ginasial)
*               = 3 médio segundo ciclo (científico, clássico etc.)
*               = 4 primeiro grau
*               = 5 segundo grau
*               = 6 superior
*               = 7 mestrado/doutorado
*               = 8 alfab de adultos
*               = 9 pré-escolar ou creche


foreach var in v0604 v0606 v0608 v0609 v6002 v6020 v06111 v061111 v06112 v0612 ///
	v4701 v4702 v4801 v4802 {
	cap drop `var'
}


/* D. Valores -1 */
* nada a fazer aqui


/* D. TRABALHO INFANTIL - APENAS PARA 2001 */
replace v0701 = . if v0701==0
replace v0713 = . if v0713 ==99
recode v0711 (9 = .)

rename v7060 v7060_novo
rename v7070 v7070_novo
rename v7090 v7090_novo
rename v7100 v7100_novo

foreach var in v7121 v7123 v7124 v7126 v7127 v7128 v0714 v0715 v0716 {
	cap drop `var'
}


/* E. CARACTERISTICAS DE TRABALHO */

* Recodes
recode v9152 v9154 v9202 v9204 (9000000/max = .)
recode v9008 v9058 v9611 v9612 v9064 v9073 v9861 v9862 v9892 v9101 v9105 ///
	v1091 v1092 (99 =.)
recode v9008 v9073 (88 = .)
recode v9009-v9014 v9016-v9019 v9021-v9052 v9054-v9057 v9059 v9060 v9062 v9063 v9065-v9070 ///
	v9074-v9085 v9087 v9088 v9891 v9092-v9097 v9099 v9100 v9103 v9104 v9106 v9107 v9108 ///
	v9112-v9124 (9 = .)
recode v9001 (0 = .)

drop v9152 v9157 v9162 v9202 v9207 v9212 

cap drop v9921	// horas de afazeres domesticos

/* MUDANÇA NA ORDEM DAS QUESTÕES INICIAIS DA SEÇÃO */
* A partir de 2001, foram invertidas das questoes v9002, v9003 e v9004.
* Antes, perguntava-se primeiro se o individuo havia trabalhado na producao
* para o proprio consumo ou na construcao para o proprio uso. Agora, pergunta-se
* primeiro se o individuo estava afastado de algum trabalho na semana de ref.
* Isso pode alterar quem responde as questoes dependendo dos saltos.

/* E.1 - Trabalhou na produção para próprio consumo */
recode v9003 (3 = 0), g(trab_consumo)
lab var trab_consumo "trab. producao p/ proprio consumo"
* 1 = sim; 0 = nao

/* E.2 - Trabalhou na construção para próprio uso */
recode v9004 (2 = 1) (4 = 0), g(trab_uso)
lab var trab_uso "trab. construcao p/ proprio uso"
* 1 = sim; 0 = nao

/* E.3 - Esteve afastado do trabalho */
recode v9002 (2 = 1) (4 = 0), g(trab_afast)
lab var trab_afast "esteve afastado do trabalho na s.r."
* 1 = sim; 0 = nao

drop v9002-v9004


/* E.4.1 e E.4.2 CONDIÇÃO DE OCUPAÇÃO (na semana e no ano) */
* até 2007, essas variáveis derivadas incluíam crianças menores de 10 anos
* na categoria "ocupados", com exceção de 1996 e 1997, quando não houve
* seção de trabalho com crianças menores de 10 anos. Com isso, 
* a partir de 2007, essa variáveis possuem nomes ligeiramente diferentes.

g cond_ocup_s = .
g cond_ocup_a = .

qui sum v0101
loc min = r(min)
loc max = r(max)

if `max' <= 2006 {
	replace cond_ocup_s = v4705 if v8005>=10
	replace cond_ocup_a = v4714 if v8005>=10
	drop v4714 v4705
}

if `min' < 2007 & `max' > =2007 {
	replace cond_ocup_s = v4805 if v0101>=2007
	replace cond_ocup_a = v4814 if v0101>=2007
	replace cond_ocup_s = v4705 if v8005>=10 & v0101<2007
	replace cond_ocup_a = v4714 if v8005>=10 & v0101<2007
	drop v4714 v4705 v4805 v4814
}

if `min' >= 2007 {
	replace cond_ocup_s = v4805 
	replace cond_ocup_a = v4814 
	drop v4805 v4814
}
recode cond_ocup_s cond_ocup_a (2 = 0)
* 1 = ocupadas; 0 = desocupadas
lab var cond_ocup_s "condicao de ocupação na semana"
lab var cond_ocup_a "condicao de ocupação no ano"


/* E.5 POSICAO NA OCUPACAO */
* A partir de 2007, as 'posicoes' foram encerradas: o 'empregado sem declaracao 
* de carteira' de trabalho, e o 'trabalhador domestico sem declaracao de carteira',
* provavelmente incorporados aos empregados e trabalhadores domesticos sem carteira,
* respectivamente; as demais posicoes permaneceram inalteradas

recode v4706 (5 = 4) (8 = 7) (14=.)
recode v4715 (5 = 4) (8 = 7) (14=.)

/* E.6 ATIVIDADE PRINCIPAL DO EMPREENDIMENTO do trab principal */
* A partir de 2001, essas variáveis incluem criancas menores de 10 anos

g ativ_semana = v4808 if v8005>=10
g ativ_ano = v4812 if v8005>=10

lab var ativ_semana "tipo de atividade na semana"
lab var ativ_ano "tipo de atividade no ano"

drop v4808 v4812

/* E.7 CODIGOS DE OCUPACAO E ATIVIDADE */ 
* codigos de ocupacao e atividade: a partir de 2002, sao usados CBO e CNAE

rename v9906 v9906_novo 
rename v9971 v9971_novo
rename v9907 v9907_novo 
rename v9972 v9972_novo 
rename v9910 v9910_novo 
rename v9911 v9911_novo
rename v9990 v9990_novo 
rename v9991 v9991_novo

foreach var in v9151 v9153 v9155 v9156 v9158 v9160 v9161 v9163 v9165 v9201 v9203 ///
	v9205 v9206 v9208 v9210 v9211 v9213 v9215 v9531 v9533 v9534 v90531 v90532 v90533 v9536 v9537 v9981 ///
	v9983 v9984 v9986 v9987 v1021 v1023 v1024 v1026 v1027 v1028 v1251 v1253 v1254 ///
	v1256 v1257 v1259 v1260 v1262 v1263 v1265 v1266 v1268 v1269 v1271 v1272 v1274 ///
	v1275 v9126 {
	cap drop `var'
}


/* F. FECUNDIDADE */
foreach var in v1101 v1141 v1142 v1151 v1152 v1153 v1154 v1161 v1162 ///
		v1163 v1164 v1107 v1181 v1182 v1109 v1110 v1111 v1112 v1113 v1114 {
	replace `var' = . if v8005<15
	rename `var' `var'c
}
recode v1182c (999 9999 = .)
recode v1141c v1142c v1151c v1152c v1161c v1162c v1181c v1182c ///
	v1111c v1112c (99 =.)
recode v1107c v1109c v1110c (9 = .)
recode v1101c (0 = .)

foreach var in v1115 {
	cap drop `var'
}

/* DEFLACIONANDO E CONVERTENDO UNIDADES MONETÁRIAS PARA REAIS */

/* CONVERTENDO OS VALORES NOMINAIS PARA REAIS (UNIDADE MONETÁRIA) */
/* 	E DEFLACIONANDO : 1 = out/2012                                */
gen double deflator = 1  if v0101 == 2012
format deflator %26.25f
replace deflator    = 0.945350  if v0101 == 2011
replace deflator    = 0.841309  if v0101 == 2009
replace deflator    = 0.806540  if v0101 == 2008
replace deflator    = 0.752722  if v0101 == 2007
replace deflator    = 0.717917  if v0101 == 2006
replace deflator    = 0.698447  if v0101 == 2005
replace deflator    = 0.663870  if v0101 == 2004
replace deflator    = 0.627251  if v0101 == 2003
replace deflator    = 0.536898  if v0101 == 2002
replace deflator    = 1.056364  if v0101 == 2013
replace deflator    = 1.124668  if v0101 == 2014
replace deflator    = .  if v0101 == 2015


label var deflator "deflator - base:out/2012"  

gen double conversor = 1

label var conversor "conversor de moedas"

foreach name in v9532 v9535 v9982 v9985 v1022 v1025 v1252 v1255 v1258 v1261 ///
		v1264 v1267 v1270 v1273 v7122 v7125 v4718 v4719 v4720 v4721 v4722 v4726 {
	cap replace `name' = . if `name'>10^10
	cap g `name'def = (`name'/conversor)/deflator
	cap lab var `name'def "`name' deflacionada"
}


/* OUTROS RECODES */

cap recode v4703 (17 = .)
cap recode v4803 (17 = .)
cap rename v4803 v4703

recode /* cor */ v0404 /* mãe */ v0405 v0406 (9 = .)

recode /* idade */ v8005 (999 =.)

/* grupos de anos de estudo */ 
cap rename v4838 v4738
replace v4738 = . if v8005<10

/* Condição de atividade na semana - não se aplica ou não declarado */
replace v4704 = . if v4704 == 3
/* Horas trabalhadas - não se aplica ou não declarado */
replace v4707 = . if v4707 == 6
/* Horas trabalhadas - não se aplica ou não declarado */
replace v4711 = . if v4711 == 3
/* Horas trabalhadas - não se aplica ou não declarado */
replace v4713 = . if v4713 == 3


/* OUTROS DROPS */ 

foreach var in v4111 v4112 v0408 v0409 v0410 v4011 v0411 v0412 v4735 v6502 v4740 ///
	v4741 v4742 v4743 v4744 v4745 v4746 v4747 v9993 v9993b v4748 v4749 v4750 {
	cap drop `var'
}


/* K. SUPLEMENTOS */
cap drop /* programas sociais */ v1801 -v1804 /* saude/ mobilidade fisica */ v1701-v1409 // 2003
cap drop /* educacao */ v1901 -v1910 // 2004
cap drop /* internet */ v2201 -v2223 // 2005
cap drop /* educacao */ v1901-v1912 /* trabalho 5-17 */  v2301-v2312	// 2006
cap drop /* EJA e educ profissional */ v2500-v2656	// 2007
cap drop /* tabagismo */ v2701-v2791 SELEC PESPET v2801-v2814 /* internet */ v2201-v22006 /* saude, mobilidade */ v1701-v1417 // 2008
cap drop /* vitimizacao */ v2901-v2929

end
