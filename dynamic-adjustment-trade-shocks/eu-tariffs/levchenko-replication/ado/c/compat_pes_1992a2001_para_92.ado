************************************************************
**************compat_pess_1992a2001_para_92.ado*************
************************************************************
program define compat_pes_1992a2001_para_92

/* A.1 RECODE: ANO */
recode v0101 (92=1992) (93=1993) (95=1995) (96=1996) (97=1997) (98=1998) (99=1999)

* VERIFICANDO SE ANOS 1996, 1997 E 2001 FORAM SELECIONADOS
tempvar t
g `t' = v0101==1996 | v0101==1997 | v0101==2001
qui sum `t'
loc max = r(max)

/* A.2 NÚMERO DE CONTROLE E SÉRIE */
drop v0102 v0103
destring uf, replace


/* B. DATA DE NASCIMENTO */
recode v3031 (0 = .)
recode v3031 v3032 (99 =.)
recode v3032 (20 = .)
recode v3033 (min/98 9999 = .)
replace v3033 = v3033 + 1000 if v3033>99 & v3033<9999 & v0101<=1999


/* B.2 CARACTERISTICAS DE MIGRACAO */
recode v5030 v5080 v5090 (99 =.)
recode v0501 v0502 v0504 v0505 ///
	v5062 v0507 v0510 v0511 v5122 (9 = .)
recode v5062 v5122 (8 = .)
recode v5064 v5124 (0 = .)
cap drop v0503 v0508 v0509

/* C. VARIÁVEIS DE EDUCAÇÃO */
recode v0601 v0602 v0611 (0 9 = .)

/* C.1 RECODE: ANOS DE ESTUDO */
/* VARIÁVEIS UTILIZADAS */
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

* Código do grau ligeiramente diferente em 2001, devido à separação entre pré-escolar e creche:
* 1992 a 99:                        2001:
* v0603                             v0603
* 7 = pré-escolar ou creche         7 = creche
* 8 = pré-vestibular                8 = pré-escolar
* 9 = mestrado/doutorado            9 = pré-vestibular
*                                   10 = mestrado/doutorado
* v0607                             v0607
* 9 = pré-escolar ou creche		9 = creche
*                                   10 = pré-escolar
* Homogeneizando:
recode v0603 (8=7) (9=8) (10=9) if v0101 == 2001
recode v0607 (10=9) if v0101 == 2001

/* pessoas que ainda freqüentam escola */
gen anoest =0 if v0602==2 & v0603==1 & v0605==1
replace anoest =1 if v0602==2 & v0603==1 & v0605==2
replace anoest =2 if v0602==2 & v0603==1 & v0605==3
replace anoest =3 if v0602==2 & v0603==1 & v0605==4
replace anoest =4 if v0602==2 & v0603==1 & v0605==5
replace anoest =5 if v0602==2 & v0603==1 & v0605==6
replace anoest =6 if v0602==2 & v0603==1 & v0605==7
replace anoest =7 if v0602==2 & v0603==1 & v0605==8

replace anoest =8 if v0602==2 & v0603==2 & v0605==1
replace anoest =9 if v0602==2 & v0603==2 & v0605==2
replace anoest =10 if v0602==2 & v0603==2 & v0605==3
replace anoest =11 if v0602==2 & v0603==2 & v0605==4

replace anoest =0 if v0602==2 & v0603==3 & v0604==2 & v0605==1
replace anoest =1 if v0602==2 & v0603==3 & v0604==2 & v0605==2
replace anoest =2 if v0602==2 & v0603==3 & v0604==2 & v0605==3
replace anoest =3 if v0602==2 & v0603==3 & v0604==2 & v0605==4
replace anoest =4 if v0602==2 & v0603==3 & v0604==2 & v0605==5
replace anoest =5 if v0602==2 & v0603==3 & v0604==2 & v0605==6
replace anoest =6 if v0602==2 & v0603==3 & v0604==2 & v0605==7
replace anoest =7 if v0602==2 & v0603==3 & v0604==2 & v0605==8

replace anoest =0 if v0602==2 & v0603==3 & v0604==4 

replace anoest =8 if v0602==2 & v0603==4 & v0604==2 & v0605==1
replace anoest =9 if v0602==2 & v0603==4 & v0604==2 & v0605==2
replace anoest =10 if v0602==2 & v0603==4 & v0604==2 & v0605==3
replace anoest =11 if v0602==2 & v0603==4 & v0604==2 & v0605==4

replace anoest =8 if v0602==2 & v0603==4 & v0604==4 

replace anoest =11 if v0602==2 & v0603==5 & v0605==1
replace anoest =12 if v0602==2 & v0603==5 & v0605==2
replace anoest =13 if v0602==2 & v0603==5 & v0605==3
replace anoest =14 if v0602==2 & v0603==5 & v0605==4
replace anoest =15 if v0602==2 & v0603==5 & v0605==5
replace anoest =16 if v0602==2 & v0603==5 & v0605==6

replace anoest =0 if v0602==2 & v0603==6
replace anoest =0 if v0602==2 & v0603==7
replace anoest =11 if v0602==2 & v0603==8
replace anoest =15 if v0602==2 & v0603==9

/* pessoas que não freqüentam */

replace anoest =1 if v0602==4 & v0606==2 & v0607==1 & v0609==1 & v0610==1
replace anoest =2 if v0602==4 & v0606==2 & v0607==1 & v0609==1 & v0610==2
replace anoest =3 if v0602==4 & v0606==2 & v0607==1 & v0609==1 & v0610==3
replace anoest =4 if v0602==4 & v0606==2 & v0607==1 & v0609==1 & v0610==4
replace anoest =4 if v0602==4 & v0606==2 & v0607==1 & v0609==1 & v0610==5
replace anoest =4 if v0602==4 & v0606==2 & v0607==1 & v0609==1 & v0610==6

replace anoest =0 if v0602==4 & v0606==2 & v0607==1 & v0609==3

replace anoest =5 if v0602==4 & v0606==2 & v0607==2 & v0608==2 & v0609==1 & v0610==1
replace anoest =6 if v0602==4 & v0606==2 & v0607==2 & v0608==2 & v0609==1 & v0610==2
replace anoest =7 if v0602==4 & v0606==2 & v0607==2 & v0608==2 & v0609==1 & v0610==3
replace anoest =8 if v0602==4 & v0606==2 & v0607==2 & v0608==2 & v0609==1 & v0610==4
replace anoest =8 if v0602==4 & v0606==2 & v0607==2 & v0608==2 & v0609==1 & v0610==5

replace anoest =4 if v0602==4 & v0606==2 & v0607==2 & v0608==2 & v0609==3

replace anoest =8 if v0602==4 & v0606==2 & v0607==2 & v0608==4 & v0611==1
replace anoest =4 if v0602==4 & v0606==2 & v0607==2 & v0608==4 & v0611==3

replace anoest =9 if v0602==4 & v0606==2 & v0607==3 & v0608==2 & v0609==1 & v0610==1
replace anoest =10 if v0602==4 & v0606==2 & v0607==3 & v0608==2 & v0609==1 & v0610==2
replace anoest =11 if v0602==4 & v0606==2 & v0607==3 & v0608==2 & v0609==1 & v0610==3
replace anoest =11 if v0602==4 & v0606==2 & v0607==3 & v0608==2 & v0609==1 & v0610==4

replace anoest =8 if v0602==4 & v0606==2 & v0607==3 & v0608==2 & v0609==3

replace anoest =11 if v0602==4 & v0606==2 & v0607==3 & v0608==4 & v0611==1
replace anoest =8 if v0602==4 & v0606==2 & v0607==3 & v0608==4 & v0611==3

replace anoest =1 if v0602==4 & v0606==2 & v0607==4 & v0608==2 & v0609==1 & v0610==1
replace anoest =2 if v0602==4 & v0606==2 & v0607==4 & v0608==2 & v0609==1 & v0610==2
replace anoest =3 if v0602==4 & v0606==2 & v0607==4 & v0608==2 & v0609==1 & v0610==3
replace anoest =4 if v0602==4 & v0606==2 & v0607==4 & v0608==2 & v0609==1 & v0610==4
replace anoest =5 if v0602==4 & v0606==2 & v0607==4 & v0608==2 & v0609==1 & v0610==5
replace anoest =6 if v0602==4 & v0606==2 & v0607==4 & v0608==2 & v0609==1 & v0610==6
replace anoest =7 if v0602==4 & v0606==2 & v0607==4 & v0608==2 & v0609==1 & v0610==7
replace anoest =8 if v0602==4 & v0606==2 & v0607==4 & v0608==2 & v0609==1 & v0610==8

replace anoest =0 if v0602==4 & v0606==2 & v0607==4 & v0608==2 & v0609==3

replace anoest =8 if v0602==4 & v0606==2 & v0607==4 & v0608==4 & v0611==1
replace anoest =0 if v0602==4 & v0606==2 & v0607==4 & v0608==4 & v0611==3

replace anoest =9 if v0602==4 & v0606==2 & v0607==5 & v0608==2 & v0609==1 & v0610==1
replace anoest =10 if v0602==4 & v0606==2 & v0607==5 & v0608==2 & v0609==1 & v0610==2
replace anoest =11 if v0602==4 & v0606==2 & v0607==5 & v0608==2 & v0609==1 & v0610==3
replace anoest =11 if v0602==4 & v0606==2 & v0607==5 & v0608==2 & v0609==1 & v0610==4

replace anoest =8 if v0602==4 & v0606==2 & v0607==5 & v0608==2 & v0609==3

replace anoest =11 if v0602==4 & v0606==2 & v0607==5 & v0608==4 & v0611==1
replace anoest =8 if v0602==4 & v0606==2 & v0607==5 & v0608==4 & v0611==3

replace anoest =12 if v0602==4 & v0606==2 & v0607==6 & v0609==1 & v0610==1
replace anoest =13 if v0602==4 & v0606==2 & v0607==6 & v0609==1 & v0610==2
replace anoest =14 if v0602==4 & v0606==2 & v0607==6 & v0609==1 & v0610==3

replace anoest =15 if v0602==4 & v0606==2 & v0607==6 & v0609==1 & v0610==4
replace anoest =16 if v0602==4 & v0606==2 & v0607==6 & v0609==1 & v0610==5
replace anoest =17 if v0602==4 & v0606==2 & v0607==6 & v0609==1 & v0610==6

replace anoest =11 if v0602==4 & v0606==2 & v0607==6 & v0609==3

replace anoest =17 if v0602==4 & v0606==2 & v0607==7 & v0611==1
replace anoest =15 if v0602==4 & v0606==2 & v0607==7 & v0611==3

replace anoest =0 if v0602==4 & v0606==2 & v0607==8
replace anoest =0 if v0602==4 & v0606==2 & v0607==9

replace anoest =0 if v0602==4 & v0606==4

label var anoest "years of schooling"

/* C.2 RECODE: SÉRIE QUE FREQÜENTA NA ESCOLA */
recode v0605 (9=.)
rename v0605 serie_freq
label var serie_freq "grade (if attends school)"

/* C.3 RECODE: CURSO QUE FREQÜENTA NA ESCOLA */
recode v0603 (0=.)
rename v0603 curso_freq
label var curso_freq "course (if attends school)"
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

/* C.5 RECODE: curso NÃO FREQÜENTA NA ESCOLA */
recode v0607 (0=.) 
rename v0607 curso_nao_freq
label var curso_nao_freq "course (if does not attends school)"
* curso_nao_freq = 1 elementar (primário)
*               = 2 médio primeiro ciclo (ginasial)
*               = 3 médio segundo ciclo (científico, clássico etc.)
*               = 4 primeiro grau
*               = 5 segundo grau
*               = 6 superior
*               = 7 mestrado/doutorado
*               = 8 alfab de adultos
*               = 9 pré-escolar ou creche

/* C.6 CONCLUSAO CURSO FREQUENTDO ANTERIORMENTE */
* v0611

drop v0604 v0606 v0608 v0609 v4701 v4702
cap drop v6002

/* D. VALORES = -1 E 999.999.999.999 E OUTROS MISSINGS E INDETERMINADOS */

/* D. TRABALHO INFANTIL */
	
if `max'==0 {
	recode v0713 v7122 v7125 (-1 = .)
	replace v7122 = . if v7122>10^10
	replace v7125 = . if v7125>10^10
}
	
/* D.1 - APENAS PARA 2001 */
/* Esta seção não é totalmente compativel com as seções específicas de 
	trabalho infantil nos outros anos da PNAD. Isso porque, em 2001, primeiro
	se fazem as perguntas referentes à semanda de referência, enquanto nos
	demais, as primeiras perguntas se referem à condição de trabalho no ano.
	Isso afeta o encadeamento das questões. */
	
sum v0101
loc min = r(min)
qui reg v0101 if v8005>=5 & v8005<=9

if `min' == 2001 {

	* trabalho no ano
	g v0701 = 1 if (v9067==1 | v9001==1 | v9002==2) & e(sample)
	replace v0701 = 3 if (v9067==3 | v9002==4) & e(sample)
	lab var v0701 "worked in the last 365 days"

	* producao para consumo
	g v0702 = 2 if (v9068==2 | v9003==1) & e(sample) 
	replace v0702 = 4 if v9068==4 & e(sample) 
	lab var v0702 "worked - own consumption - last year"
	
	* construcao para uso
	g v0703 = 1 if (v9069==1 | v9004==2) & e(sample)
	replace v0703 = 3 if v9069==3 & e(sample)
	lab var v0703 "worked with construction last year"
	
	* trabalhou na semama
	g v0704 = v9001 if (v0701==1 | v0702==2 | v0703==1) & e(sample) 
	lab var v0704 "worked on reference week"

	* esteve afastado  
	g v0705 = v9002 if v0704==3 & e(sample)
	lab var v0705 "employed taking time-off ref week"
	
	* cod ocupacao/atividade - 358 dias
	g v7060 = v9971 if v9001~=1 & v9002~=2 & e(sample)
	g v7070 = v9972 if v9001~=1 & v9002~=2 & e(sample)
	lab var v7060 "occupation codes on the job - 358 days"
	lab var v7070 "main activity codes - 358 days"
	
	* posicao na ocupacao - 358 dias
	g v0708 = v9077 if                          v9001~=1 & v9002~=2 & e(sample)
	replace v0708 = 8 if v0708==7 &             v9001~=1 & v9002~=2 & e(sample)
	replace v0708 = 1 if v9073<=4 &             v9001~=1 & v9002~=2 & e(sample)
	replace v0708 = 3 if v9073>=5 & v9073<=7 &  v9001~=1 & v9002~=2 & e(sample)
	replace v0708 = 4 if v9073>=8 & v9073<=10 & v9001~=1 & v9002~=2 & e(sample)
	replace v0708 = 5 if v9073==11 &            v9001~=1 & v9002~=2 & e(sample)
	replace v0708 = 6 if v9073==12 &            v9001~=1 & v9002~=2 & e(sample)
	replace v0708 = 7 if v9073==13 &            v9001~=1 & v9002~=2 & e(sample)
	lab var v0708 "position in the ocupation - 358 days"
	
	* cod ocupacao/atividade - semana
	g v7090 = v9906 if (v9001==1 | v9002==2) & e(sample)
	g v7100 = v9907 if (v9001==1 | v9002==2) & e(sample)
	lab var v7090 "occupation codes on the job - ref week"
	lab var v7100 "main activity codes - ref week"
	
	* posicao na ocupacao - semana
	g v0711 = v9029 if 							(v9001==1 | v9002==2) & e(sample)
	replace v0711 = 8 if v9029==7 &             (v9001==1 | v9002==2) & e(sample)
	replace v0711 = 1 if v9008<=4 &             (v9001==1 | v9002==2) & e(sample)
	replace v0711 = 3 if v9008>=5 & v9008<=7 &  (v9001==1 | v9002==2) & e(sample)
	replace v0711 = 4 if v9008>=8 & v9008<=10 & (v9001==1 | v9002==2) & e(sample)
	replace v0711 = 5 if v9008==11 &            (v9001==1 | v9002==2) & e(sample)
	replace v0711 = 6 if v9008==12 &            (v9001==1 | v9002==2) & e(sample)
	replace v0711 = 7 if v9008==13 &            (v9001==1 | v9002==2) & e(sample)
	lab var v0711 "position in occupation ref week"
	
	* renda em dinheiro?
	g v7122 = v9532 if v0711~=.
	lab var v7122 "value monthly income cash ref week"
	
	* renda em mercadoria?
	g v7125 = v9535 if v0711~=.
	lab var v7125 "value income in merchandise"
	
	* horas trabalhadas
	g v0713 = v9058 if v0711~=.
	lab var v0713 "hours worked per week"
	recode v0711 (9 = .)
	replace v0701 = . if v0701==0
	replace v0713 = . if v0713==99
}
cap replace v0701 = . if v0701==0

cap drop v0706 v0707 v0709 v0710

/* E. CARACTERISTICAS DE TRABALHO */

/* E.0 ESPECIFICIDADES DA PNAD 2001 */
* Neste ano, a seção sobre trabalho e rendimento foi realizada para 5 anos 
* ou mais, em contraste com as demais, onde a idade mínima foi de 10 anos

* Variaveis derivadas: apenas restringir a 10 anos ou mais

if `min'==2001 {
	g v4704 = v4754 if v8005>9
	g v4705 = v4755 if v8005>9
	g v4706 = v4756 if v8005>9
	g v4707 = v4757 if v8005>9
	g v4709 = v4759 if v8005>9
	g v4710 = v4760 if v8005>9
	g v4711 = v4761 if v8005>9
	g v4713 = v4763 if v8005>9
	g v4714 = v4764 if v8005>9
	g v4715 = v4765 if v8005>9
	g v4716 = v4766 if v8005>9
	g v4717 = v4767 if v8005>9
	g v4718 = v4768 if v8005>9
	g v4719 = v4769 if v8005>9
	g v4720 = v4770 if v8005>9
	replace v4704 = . if v4704 == 3
	replace v4707 = . if v4707 == 6
	replace v4711 = . if v4711 == 3
	replace v4713 = . if v4713 == 3
	replace v4713 = . if v4713 == 0
	replace v4723 = . if v4723 == 0
	


	lab var v4704 "activity condition ref week, 10 or +"
	lab var v4705 "occupation condition ref week, 10 or +"
	lab var v4706 "position in occupation main job ref week, 10 or +"
	lab var v4707 "hours worked per week all jobs, 10 or +"
	lab var v4709 "worked in which sector of the firm - ref week"
	lab var v4710 "type of occupation in the job held - ref week"
	lab var v4711 "contributed social security, 10 or +"
	lab var v4713 "activity condition job 365 days, 10 or +"
	lab var v4714 "occupation condition 365 days, 10 or +"
	lab var v4715 "position in occupation 365 days, 10 or +"
	lab var v4716 "worked in which sector of the firm - 365 days"
	lab var v4717 "type of occupation in the job held - 365 days"
	lab var v4718 "monthly income main job, 10 or +"
	lab var v4719 "monthly income all jobs, 10 or +"
	lab var v4720 "monthly income all sources, 10 or +"

	drop v4754 v4755 v4756 v4757 v4759 v4760 v4761 v4763 v4764 v4765 v4766 v4767 v4768 v4769 v4770
}

* drops
cap drop v9006 v9007 v9071 v9072 v9090 v9091 v9110 v9111	// nomes da ocupacao e atividade

* Recodes
recode v9008 v9058 v9611 v9612 v9064 v9073 v9861 v9862 v9892 v9101 v9105 v1091 v1092 (99 =.)
recode v9008 v9073 (88 = .)
recode v9009-v9014 v9016-v9019 v9021-v9052 v9054-v9057 v9059 v9060 v9062 v9063 v9065-v9070 ///
	v9074-v9085 v9087 v9088 v9891 v9092-v9097 v9099 v9100 v9103 v9104 v9106 v9107 v9108 ///
	v9112-v9124 (9 = .)
recode v9001 (0 = .)
foreach var in v9154 v9159 v9164 v9204 v9209 ///
		v9214 v9038 v9039 v9532 v9535 v9058 v9611 v9612 ///
		v9064 v9861 v9862 v9892 v9982 v9985 v9101 v1022 v1025 v9105 v1091 v1092 v1252 ///
		v1255 v1258 v1261 v1264 v1267 v1270 v1273 v1141 v1142 v1151 v1152 v1161 ///
		v1162 v1111 v1112  v4718 v4719 v4720 {
	replace `var' = . if `var'==-1 | `var'>10^11
}

drop v9152 v9157 v9162 v9202 v9207 v9212 // area da propriedade em medida diferentente de m2
recode v9154 v9159 v9164 v9204 (9999999=.)

cap drop v9921	// horas de afazeres domesticos (so 2001)

/* MUDANÇA NA ORDEM DAS QUESTÕES INICIAIS DA SEÇÃO */
* A partir de 2001, foram invertidas das questoes v9002, v9003 e v9004.
* Antes, perguntava-se primeiro se o individuo havia trabalhado na producao
* para o proprio consumo ou na construcao para o proprio uso. Agora, pergunta-se
* primeiro se o individuo estaava afastado de algum trabalho na semana de ref.
* Isso pode alterar quem responde as questoes dependendo dos saltos.

/* E.1 - Trabalhou na produção para próprio consumo */
/* E.2 - Trabalhou na construção para próprio uso */
/* E.3 - Esteve afastado do trabalho */

g trab_consumo = .
g trab_uso = .
g trab_afast = .

if `min' < 2001 {
	replace trab_consumo = v9002
	replace trab_uso = v9003
	replace trab_afast = v9004
}
if `min' == 2001 {
	replace trab_consumo = 2 if v9003 == 1
	replace trab_consumo = 4 if v9003 == 3
	replace trab_uso = v9004 - 1
	replace trab_afast = v9002
}

recode trab_consumo trab_afast (2 = 1) (4 = 0)
recode trab_uso (3 = 0)
lab var trab_consumo "worked in agriculture to feed hh residents"
	* 1 = sim; 0 = nao
lab var trab_uso "worked in contruction within hh"
	* 1 = sim; 0 = nao
lab var trab_afast "was taking time-off"
	* 1 = sim; 0 = nao

drop v9002-v9004	

/* E.4.1 e E.4.2 CONDIÇÃO DE OCUPAÇÃO (na semana e no ano) */ 
* Até 2007, essas variáveis derivadas incluíam crianças menores de 10 anos
* na categoria "ocupados", com exceção de 1996 e 1997, quando não houve
* seção de trabalho com crianças menores de 10 anos

g cond_ocup_s = v4705 if v8005>=10
lab var cond_ocup_s "occupation condition - ref week"

g cond_ocup_a = v4714 if v8005>=10
lab var cond_ocup_a "occupation condition - year"

recode cond_ocup_s cond_ocup_a (2 = 0)
* 1 = ocupadas; 0 = desocupadas

drop v4705 v4714

/* E.5 POSICAO NA OCUPACAO */
* A partir de 2007, as 'posicoes' foram encerradas: o 'empregado sem declaracao 
* de carteira' de trabalho, e o 'trabalhador domestico sem declaracao de carteira',
* provavelmente incorporados aos empregados e trabalhadores domesticos sem carteira,
* respectivamente; as demais posicoes permaneceram inalteradas

recode v4706 (5 = 4) (8 = 7) (14=.)
recode v4715 (5 = 4) (8 = 7) (14=.)

/* E.6 ATIVIDADE PRINCIPAL DO EMPREENDIMENTO do trab principal */
* A partir de 2001, essas variáveis incluem criancas menores de 10 anos

g ativ_semana = v4708 if v8005>=10
lab var ativ_semana "activity/line of business - ref week"
g ativ_ano = v4712 if v8005>=10
lab var ativ_ano "activity/line of business - year"

drop v4708 v4712

/* E.7 CODIGOS DE OCUPACAO E ATIVIDADE */
* codigos de ocupacao e atividade: a partir de 2002, sao usados CBO e CNAE
* as variáveis são mantidas, mas não há comparabilidade das variáveis agredadas entre as décadas


/* F. FECUNDIDADE */
* a partir de 2001, esse quesito passou a ser aplicado também a mulheres entre 10 e 15 anos.

foreach var in v1101 v1141 v1142 v1151 v1152 v1153 v1154 v1161 v1162 ///
		v1163 v1164 v1107 v1181 v1182 v1109 v1110 v1111 v1112 v1113 v1114 {

		rename `var' `var'c
		replace `var'c = . if v8005<15
}

recode v1182c (999 9999 = .)
recode v1141c v1142c v1151c v1152c v1161c v1162c v1181c v1182c ///
	v1111c v1112c (99 =.)
recode v1107c v1109c v1110c (9 = .)
recode v1101c (0 = .)


/* F.1 - Recode ano de nascimento do ultimo filho */
replace v1182c = v1182c + 1000 if v1182c>99 & v1182c<1000
replace v1182c = v1182c + 1900 if v1182c<=99


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

label var deflator "income deflator - reference: oct/2012"  

gen double conversor = 1             if v0101 >= 1995
replace conversor    = 2750          if v0101 == 1993
replace conversor    = 2750000       if v0101 == 1992

label var conversor "currency converter"

foreach var in v9532 v9535 v9982 v9985 v1022 v1025 v1252 v1255 v1258 v1261 v1264 ///
		v1267 v1270 v1273 v7122 v7125 v4718 v4719 v4720 v4721 v4722 v4726 {
	cap replace `var' = . if `var'==-1 | `var'>10^10
	cap g `var'def = (`var'/conversor)/deflator
	cap lab var `var'def "`var' deflated"
}


/* OUTROS RECODES */

recode v8005 (999 =.)
recode v4703 (17 = .)
recode /* cor */ v0404 /* mãe */ v0405 v0406 (9 = .)

if `min'==2001 {
	rename v4788 v4738
	replace v4738=. if v8005<=9
}
cap recode v4738 (7=.)

/* OUTROS DROPS */

if `min'==1996  drop v4739-v4743
if `min'==2001 drop v5005 v5505 v0513 v9151 v9153 v9155 v9156 v9158 v9160 v9161 v9163 ///
	v9165 v9201 v9203 v9205 v9206 v9208 v9210 v9211 v9213 v9215 v9531 v9533 v9534 ///
	v9536 v9537 v9981 v9983 v9984 v9986 v9987 v1021 v1023 v1024 v1026 v1027 v1028 ///
	v1251 v1253 v1254 v1256 v1257 v1259 v1260 v1262 v1263 v1265 v1266 v1268 v1269 ///
	v1271 v1272 v1274 v1275 v4785 v4776 v4739 v4740

/* K. SUPLEMENTOS */
cap drop /* supletivo */ v0801 -v0811 /* nupcialidade */ v1001- v1004 // 1995
cap drop /* mobilidade social */ v1201-v1219 // 1996
cap drop /* saude */ v1301-v7932 /* mobilidade fisica */ v1401-v1409 // 1998
cap drop /* migração dos filhos */ v8121-v8163 /* educacao*/ v1501-v1512  /* saude e seguranca */ v1601-v1630 // 2001

end

