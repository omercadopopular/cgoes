******************************************************
*                   datazoom_pnad.ado                  *
******************************************************
* version 1.3
program define datazoom_pnad

syntax, years(numlist) original(str) saving(str) [pes dom both ncomp comp81 comp92]

if "`pes'"~="" & "`dom'"=="" {
	display as result _newline "Obtendo arquivo de pessoas da PNAD"
	loc register = "pes"
}
if "`dom'"~="" & "`pes'"=="" {
	display as result _newline "Obtendo arquivo de domic�lios da PNAD"
	loc register = "dom"
}
if ("`pes'"~="" & "`dom'"~="") | "`both'"~="" {
	display as result _newline "Obtendo arquivos de domic�lios e pessoas da PNAD"
	loc both = "both"
	loc pes = "pes"
	loc dom = "dom"
	loc register = "pes dom"
}
if "`pes'"=="" & "`dom'"=="" & "`both'"=="" {
	display as result _newline "Nenhum tipo de registro escolhido: obtendo arquivo de pessoas da PNAD"
	loc register = "pes"
}

/*	Opcoes de compatibilizacao */

if "`ncomp'"~="" {
	display as result _newline "Obtendo microdados n�o compatibilizados"
}


* se n�o escolheu nenhuma compatibiliza��o, default = noncompatible
if "`ncomp'"=="" & "`comp81'"=="" & "`comp92'"=="" {
	local ncomp = "ncomp"
	display as result _newline "Nenhuma op��o de compatibiliza��o escolhida: obtendo microdados n�o compatibilizados"
}

/* Faz o matching entre os anos escolhidos e as bases de dados originais */
qui foreach ano in `years' {
	tokenize `"`original'"'
	while "`*'" ~= "" {

		/* se formato anos 1980 */
		loc base = substr("`1'",-8,2)
		loc base = "19`base'"
		if "`base'" == "`ano'" {
			loc base`ano'pes = "`1'"
			loc base`ano'dom = "`1'"
			noi di "`base`ano'pes'"
			noi di "`base`ano'dom'"
			macro shift
			continue
		}

		/* se formato at� 1995 */
		loc base = substr("`1'",-6,2)
		loc base = "19`base'"
		if "`base'" == "`ano'" {
			loc tipo = substr("`1'",-9,3)
			loc tipo = lower("`tipo'")
			if "`tipo'" == "pes" & "`pes'"~="" {
				loc base`ano'pes = "`1'"
				noi di "`base`ano'pes'"
				macro shift
				continue
			}
			if "`tipo'" == "dom" & "`dom'"~="" {
				loc base`ano'dom = "`1'"
				noi di "`base`ano'dom'"
				macro shift
				continue
			}
		}
		
		/* se formato 1996 */
		loc base = substr("`1'",-4,2)
		loc base = "19`base'"
		if "`base'" == "`ano'" {
			loc tipo = substr("`1'",-5,1)
			if "`tipo'" == "d" loc tipo = "dom"
			else if "`tipo'" == "p" loc tipo = "pes"
			else loc tipo = ""
			if "`tipo'" == "pes" & "`pes'"~="" {
				loc base`ano'pes = "`1'."
				noi di "`base`ano'pes'"
				macro shift
				continue
			}
			if "`tipo'" == "dom" & "`dom'"~="" {
				loc base`ano'dom = "`1'."
				noi di "`base`ano'dom'"
				macro shift
				continue
			}
		}

		/* se formato 1997 */
		loc base = substr("`1'",-2,2)
		loc base = "19`base'"
		if "`base'" == "`ano'" {
			loc tipo = substr("`1'",-4,1)
			if "`tipo'" == "o" loc tipo = "dom"
			else if "`tipo'" == "a" loc tipo = "pes"
			else loc tipo = ""
			if "`tipo'" == "pes" & "`pes'"~="" {
				loc base`ano'pes = "`1'."
				noi di "`base`ano'pes'"
				macro shift
				continue
			}
			if "`tipo'" == "dom" & "`dom'"~="" {
				loc base`ano'dom = "`1'."
				noi di "`base`ano'dom'"
				macro shift
				continue
			}
		}

		/* se formato 1998 e 1999 */
		loc base = substr("`1'",-6,2)
		loc base = "19`base'"
		if "`base'" == "`ano'" {
			loc tipo = substr("`1'",-7,1)
			if "`tipo'" == "o" loc tipo = "dom"
			else if "`tipo'" == "a" loc tipo = "pes"
			else loc tipo = ""
			if "`tipo'" == "pes" & "`pes'"~="" {
				loc base`ano'pes = "`1'"
				noi di "`base`ano'pes'"
				macro shift
				continue
			}
			if "`tipo'" == "dom" & "`dom'"~="" {
				loc base`ano'dom = "`1'"
				noi di "`base`ano'dom'"
				macro shift
				continue
			}
		}

		/* se anos 2000 */
		loc base = substr("`1'",-8,4)
		if "`base'" == "`ano'" {
			loc tipo = substr("`1'",-11,3)
			loc tipo = lower("`tipo'")
			if "`tipo'" == "pes" & "`pes'"~="" {
				loc base`ano'pes = "`1'"
				noi di "`base`ano'pes'"
				macro shift
				continue
			}
			if "`tipo'" == "dom" & "`dom'"~="" {
				loc base`ano'dom = "`1'"
				noi di "`base`ano'dom'"
				macro shift
				continue
			}
		}
		macro shift
	}
}

/* Pastas para guardar arquivos da sess�o */
cd `"`saving'"'


loc q = 0 // vai indicar se pes j� foi realizado
foreach name of local register {
	if "`name'"=="pes" di _newline as result "Gerando bases de pessoas ..."
	else {
		di _newline as result "Gerando bases de domic�lios ..."
		loc q = 1
	}
	
	tokenize `years'                            // converte `anos' em `*' = `1', `2', `3', ...
	/* Abrindo bases no Stata e salvando em arquivos tempor�rios com formato ".dta" */
	display as input "Anos selecionados: `*'"

	while "`*'" != "" {
		if `1' <= 1990 & "`comp92'"~="" {
			display as error "Op��o 'comp92' n�o se aplica � decada de 1980"
			exit, clear
		}
		if `1' <= 1990 {                                     // Se tem ano at� 1990
			display as input "Extraindo `1'..."
			cap findfile pnad`1'`name'.dct
			if _rc==601 findfile pnad`1'`name'_en.dct
			loc dic = r(fn)
			qui cap infile using `"`r(fn)'"', using("`base`1'`name''") clear
			
			/* Parte espec�fica ao per�odo de 1981 a 1990:
			 At� 1990 domic�lios e pessoas s�o registrados no mesmo arquivo.
			 Nesse mesmo per�odo, n�o h� vari�vel de ano da pesquisa         */

			gen int ano = `1'                                 // gera vari�vel de ano
			lab var ano "ano da pesquisa"

			* variavel de identificacao do domicilio
			if `1'==1983 | `1'==1990 egen id_dom = concat(ano v0102 v0103)
			else egen id_dom = concat(ano v0101)
			lab var id_dom "identifica��o do domic�lio"

			if "`name'"=="pes" {
				keep if v0100 == 3                  // mant�m somente pessoas
				sort id_dom v0305 v0306, stable
				by id_dom: gen ordem = _n
				lab var ordem "n�mero de ordem do morador"
			}
			else keep if v0100 == 1                                // mant�m somente domic�lios

			/* Fim da parte espec�fica a 1981-90 */

			if "`ncomp'" ~= "" {
				tempfile pnad`1'`name'
				if "`both'"=="" save pnad`1'`name', replace				// salva base final sem compatibilizar e sem merge
				else { 
					if "`name'"=="pes" save `pnad`1'`name'', replace	// salva base tempor�ria de pessoas p/ merge posterior
					else {
						merge 1:m id_dom using `pnad`1'pes', nogen	keep(match)	
						save pnad`1', replace								// salva base final com merge
					}
				}
			}
			else {
				if "`comp81'"~="" {

					/* contr�i renda domiciliar compat�vel com anos 90 e 2000 */
					if "`name'"=="dom" {
						preserve
						cap findfile pnad`1'pes.dct
						if _rc==601 findfile pnad`1'pes_en.dct
						qui cap infile using `"`r(fn)'"', using("`base`1'pes'") clear
						keep if v0100 == 3                  // mant�m somente pessoas
						g ano = `1'
						if `1'==1983 | `1'==1990 egen id_dom = concat(ano v0102 v0103)
						else egen id_dom = concat(ano v0101)	

						tempvar aux1 aux2
						g `aux2' = v0602 if v0305<6
						if `1'<=1984 bys id_dom: egen `aux1' = total(`aux2'==9999999)						// identifica se alguma renda � ignorada, pois
						else bys id_dom: egen `aux1' = total(`aux2'>=999999998 & `aux2'~=.)					// nesse caso, a renda domiciliar ser� missing
						bys id_dom: egen renda_domB = total(`aux2')
						replace renda_domB = . if `aux1'>0
						bys id_dom: keep if _n==1
						keep id_dom renda_domB
						tempfile rdom
						save `rdom', replace

						restore
						merge 1:1 id_dom using `rdom', nogen
					}
					cap drop v0101

					compat_`name'_1981a1990_para_81		// compatibiliza

					tempfile pnad`1'`name'
					if "`both'"=="" save pnad`1'`name'_comp81, replace				// salva base final ap�s compatibilizar mas sem merge
					else {
						if "`name'"=="pes" save `pnad`1'`name'', replace	// salva base tempor�ria de pessoas p/ merge posterior
						else {
							merge 1:m id_dom using `pnad`1'pes', nogen keep(match)	
							save pnad`1'_comp81, replace								// salva base final com merge
						}
					}
				}
			}
			clear
			macro shift                                       // vai para o pr�ximo ano.
		}
		else {                                               // Se n�o tem ano at� 1990...
			if `1' <= 2001 {                                  // ... e tem ano at� 2001
				display as input "Extraindo `1'..."
				cap findfile pnad`1'`name'.dct
				if _rc==601 findfile pnad`1'`name'_en.dct
				qui cap infile using `"`r(fn)'"', using("`base`1'`name''") clear

				if `1'==2001 egen id_dom = concat(v0101 v0102 v0103)
				else egen id_dom = concat(v0101 uf v0102 v0103)
				lab var id_dom "identifica��o do domic�lio"
				
				if "`ncomp'" ~= "" {
					tempfile pnad`1'`name'
					if "`both'"=="" save pnad`1'`name', replace				// salva base final sem compatibilizar e sem merge
					else {
						if "`name'"=="pes" save `pnad`1'`name'', replace	// salva base tempor�ria de pessoas p/ merge posterior
						else {
							merge 1:m id_dom using `pnad`1'pes', nogen	keep(match)	
							save pnad`1', replace								// salva base final com merge
						}
					}
				}
				else { 
					if "`comp81'"~="" compat_`name'_1992a2001_para_81
					else compat_`name'_1992a2001_para_92
					
					tempfile pnad`1'`name'
					if "`both'"=="" {
						if "`comp81'"~="" save pnad`1'`name'_comp81, replace				// salva base final ap�s compatibilizar mas sem merge
						else save pnad`1'`name'_comp92, replace
					}
					else {
						if "`name'"=="pes" save `pnad`1'`name'', replace	// salva base tempor�ria de pessoas p/ merge posterior
						else {
							merge 1:m id_dom using `pnad`1'pes', nogen keep(match)	
							if "`comp81'"~="" save pnad`1'_comp81, replace								// salva base final com merge
							else save pnad`1'_comp92, replace
						}
					}
				}
				clear
				macro shift
			}
			else {                                            // Se s� restam anos >= 2002
				display as input "Extraindo `1'..."
				cap findfile pnad`1'`name'.dct
				if _rc==601 findfile pnad`1'`name'_en.dct
				qui cap infile using `"`r(fn)'"', using("`base`1'`name''") clear
			
				egen id_dom = concat(v0101 v0102 v0103)
				lab var id_dom "identifica��o do domic�lio"
				
				if "`ncomp'" ~= "" 	{ 
					tempfile pnad`1'`name'
					if "`both'"=="" save pnad`1'`name', replace				// salva base final sem compatibilizar e sem merge
					else {
						if "`name'"=="pes" save `pnad`1'`name'', replace	// salva base tempor�ria de pessoas p/ merge posterior
						else {
							merge 1:m id_dom using `pnad`1'pes', nogen keep(match)	
							save pnad`1', replace								// salva base final com merge
						}
					}
				}
				else {
					if "`comp81'"~="" compat_`name'_2002a2009_para_81
					else compat_`name'_2002a2009_para_92
					
					tempfile pnad`1'`name'
					if "`both'"=="" {
						if "`comp81'"~="" save pnad`1'`name'_comp81, replace				// salva base final ap�s compatibilizar mas sem merge
						else save pnad`1'`name'_comp92, replace
					}
					else {
						if "`name'"=="pes" save `pnad`1'`name'', replace	// salva base tempor�ria de pessoas p/ merge posterior
						else {
							merge 1:m id_dom using `pnad`1'pes', nogen keep(match)	
							if "`comp81'"~="" save pnad`1'_comp81, replace								// salva base final com merge
							else save pnad`1'_comp92, replace
						}
					}
				}
				clear
				macro shift
			}
		}
	}
}
display as result "As bases de dados foram salvas na pasta `c(pwd)' - compat�vel com a �ltima vers�o dos microdados divulgados em 04/07/2018"

end

