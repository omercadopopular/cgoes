{smcl}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install command2" "ssc install command2"}{...}
{vieweralsosee "Help command2 (if installed)" "help command2"}{...}
{viewerjumpto "Syntax" "datazoom_pnad##syntax"}{...}
{viewerjumpto "Description" "datazoom_pnad##description"}{...}
{viewerjumpto "Options" "datazoom_pnad##options"}{...}
{viewerjumpto "Remarks" "datazoom_pnad##remarks"}{...}
{viewerjumpto "Examples" "datazoom_pnad##examples"}{...}
{title:Title}

{phang}
{bf:datazoom_pnad} {hline 2} Acesso aos microdados da PNAD em formato STATA - Vers�o 1.4

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:datazoom_pnad}
[{cmd:,}
{it:options}]

{phang}	OBS: digite 'db datazoom_pnad' na janela de comando para utilizar o programa via caixa de di�logo

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Inputs}
{synopt:{opt years(numlist)}} anos da PNAD {p_end}
{synopt:{opt original(str)}} caminho da pasta onde se localizam os arquivos de dados originais (.txt ou .dat) {p_end}
{synopt:{opt saving(str)}} caminho da pasta onde ser�o salvas as novas bases de dados {p_end}

{syntab:Tipos de Registro}
{synopt:{opt pes}} pessoas {p_end}
{synopt:{opt dom}} domic�lios {p_end}
{synopt:{opt both}} pessoas e domic�lios em um mesmo arquivo {p_end}

{syntab:Compatibilidade}
{synopt:{opt ncomp}} sem compatibiliza��o (default) {p_end}
{synopt:{opt comp81}} compat�vel com anos 1980 {p_end}
{synopt:{opt comp92}} compat�vel com anos 1990 {p_end}

{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Descri��o}

{phang}
{cmd:datazoom_pnad} extrai e constr�i bases de dados da PNAD em formato STATA (.dta) a partir dos microdados 
originais, os quais n�o s�o disponibilizados pelo Portal (para informa��es sobre como obter
os arquivos originais de dados, consulte o site do IBGE www.ibge.gov.br). O programa pode ser utilizado para
todos anos desde 1981 (exclusive os anos censit�rios e 1994).

{phang} Existe a op��o de compatibilizar vari�veis ao longo dos anos. Isso � feito para
as vari�veis mais frequentes na PNAD, ou seja, s�o desconsideraradas as vari�veis que aparecem poucas vezes 
nesses 30 anos. Al�m disso, � poss�vel que aspectos metodol�gicos impe�am a compatibiliza��o de algumas vari�veis. 
O processo de constru��o de vari�veis compatibilizadas est� documentado em "PNAD - Compatibiliza��o", dispon�vel para 
 download no site do Portal. Nesta op��o, somente as vari�veis compatibilizadas permanecem na base de dados final 
 (al�m das vari�veis de controle). Caso haja vari�veis monet�rias na base final, todas ser�o deflacionadas para setembro
  de 2011.
 
{phang} H� duas possibilidades de compatibiza��o, uma para os anos 1980 e outra para os
  1990. Isso ocorre devido a uma reformula��o da PNAD ocorrida em 1992, quando, entre outras mudan�as, houve separa��o
  dos arquivos de domic�lios e pessoas, amplia��o do question�rio, altera��o e sistematiza��o dos nomes
  das vari�veis e introdu��o de novos conceitos na se��o de trabalho. Assim, a compatibiliza��o para os anos
  1980, de certa forma, piora as PNADs de 1992 em diante. Mesmo as vari�veis das PNADs dos anos 
1980 sofrem alguma modifica��o no processo de compatibiliza��o ou mesmo s�o exclu�das por n�o serem frequentes na d�cada. Por 
  outro lado, como houve relativamente poucas mudan�as ap�s 1992, a compatibiliza��o para os anos 1990 mant�m a grande
  maioria das vari�veis na base de dados (excluindo os suplementos). Nesta segunda possibilidade de compatibiliza��o, 
  as PNAds dos anos 1980 n�o s�o consideradas.

{phang} A base final, compatibilizada ou n�o, pode conter somente as vari�veis de pessoas ou de domic�lios, 
ou dos dois tipos de registro conjuntamente. Ressalta-se que, para os anos 1980, somente os temas
 de educa��o, trabalho e rendimento foram investigados. Por conta
 disso, sob a op��o de compatibiliza��o para os anos 1980, todas as vari�veis relacionadas a outros temas
  s�o exclu�das, mesmo se elas existirem para o ano escolhido.

{phang}  O programa gera uma base de dados para cada ano escolhido. Se for o caso, use o comando 
{help append} para juntar todos os anos. Se a op��o {opt both} for escolhida, o programa gera uma base
de dados incluindo as vari�veis de domic�lios e pessoas no mesmo arquivo.

{phang} Inicialmente, recomenda-se fortemente a utiliza��o do programa via caixa de di�logo, pois facilita
a inser��o de informa��es necess�rias para o seu adequado funcionamento. Digite 'db datazoom_censo' na
janela de comando do STATA para acessar a caixa de di�logo.

{marker remarks}{...}
{title:Nota sobre os dados originais}

{phang}
Os nomes dos arquivos de microdados disponibilizados pelo IBGE foram uniformizados a partir de 2001. 
Os arquivos de pessoas possuem prefixo PES e os arquivos de domic�lios, prefixo DOM, ambos com sufixo
 igual ao ano com quatro d�gitos. Para os arquivos
 at� 1999, � poss�vel, no entanto, que haja diferen�as nos nomes dos arquivos que o usu�rio possui 
 e aqueles utilizados pelo {cmd:datazoom_pnad}.

{phang}
Abaixo, segue uma lista com os nomes de arquivos esperados pelo {cmd:datazoom_pnad} para cada 
ano at� 1999. De 2001 em diante, os nomes seguem o padr�o adotado pelo IBGE desde 2001.

{phang}
Caso haja diferen�as entre a lista abaixo e os arquivos do usu�rio, o programa deve funcionar 
corretamente somente ap�s o usu�rio renomear seus arquivos de dados adaptando-os � lista. 

{phang}
No entanto, � poss�vel que a estrutura dos dados utilizados pelo Data Zoom seja diferente da estrutura 
dos dados possu�dos pelo usu�rio mesmo no caso em que h� apenas diferen�as nos nomes aparentemente. Se isso ocorrer, 
o programa n�o ir� funcionar corretamente. Para verificar se h� diferen�as estruturais, confira o dicion�rio de 
vari�veis dispon�vel para download em www.econ.puc-rio.br/datazoom e compare com o dicion�rio em m�os.

{phang} - Lista dos nomes dos arquivos de microdados: 

{phang}
- Entre 1981 e 1990: pnadYYbr, onde YY � o ano da pesquisa, com dois d�gitos (81 a 90)

{phang}
- Entre 1992 e 1995: PESYY para pessoas e DOMYY para domic�lios

{phang}
- 1996: p96br para pessoas e d96br para domic�lios

{phang}
- 1997: pessoas97 para pessoas e domicilios97 para domic�lios

{phang}
- 1998 e 1999: pessoaYY para pessoas e domicilioYY para domic�lios

{marker options}{...}
{title:Op��es}
{dlgtab:Inputs}

{phang} {opt years(numlist)} especifica a lista de anos com os quais o usu�rio deseja trabalhar. Este programa pode
ser utilizado para os anos de 1981 a 2013, excluindo os anos censit�rios 1994.

{phang} {opt original(str)} indica o caminho dos arquivos de dados originais. � necess�rio incluir um caminho 
para cada arquivo com o qual o usu�rio deseja trabalhar.

{phang} {opt saving(str)} indica o caminho da pasta onde devem ser salvas as bases de dados produzidas pelo programa.

{dlgtab:Tipo de Registro}

{phang}
{opt pes}  especifica que o usu�rio deseja obter apenas o arquivo de pessoas. Se nenhum tipo de registro for escolhido, o programa
        automaticamente executa essa op��o. (N�o pode ser combinada com dom ou both).

{phang}
{opt dom}  especifica que o usu�rio deseja obter apenas o(s) arquivo(s) de domic�lios. (N�o pode ser combinada com {opt pes} 
ou {opt both}).

{phang}
{opt both}  especifica que o usu�rio deseja obter as vari�veis de pessoas e domic�lios em uma �nica base de dados, 
ou seja, o programa executa o comando {help merge} automaticamente para unir os
 dois tipos de registro. (N�o pode ser combinada com {opt dom} ou {opt pes}).


{dlgtab:Waves Compatibilidade}

{phang}
{opt ncomp}  comp solicita que a compatibiliza��o de vari�veis n�o seja executada. A base final cont�m todas
 as vari�veis do arquivo original.

{phang}
{opt comp81}  solicita que as vari�veis sejam compat�veis com os anos 1980. Mesmo as vari�veis das PNADs dos anos 
1980 sofrem alguma modifica��o no processo de compatibiliza��o.

{phang}
{opt comp92}  solicita que as vari�veis sejam compat�veis com os anos 1990. Esta op��o n�o � v�lida para as PNADs dos 
anos 1980.  

{marker examples}{...}
{title:Exemplos}

{pstd}  OBS: Recomenda-se a execu��o do programa por meio da caixa de di�logo. Digite "db datazoom_pnad" na janela 
de comando do STATA para iniciar.

{phang} Exemplo 1: arquivo de pessoas, sem compatibilizar.

{phang} datazoom_pnad, years(1984 1997 1999 2003) original("C:/pnadbases/pnad1984br.dat" "C:/pnadbases/pessoas97" 
"C:/pnadbases/pessoa99.txt" "C:/pnadbases/pes2003.txt") saving("C:/mydocuments") pes ncomp 

{pstd} Quatro bases de dados ser�o geradas, uma para cada ano selecionado.

{pstd} 

{phang} Exemplo 2: arquivo de domic�lios n�o compatibilizados.

{phang} datazoom_pnad, years(1990 2005) original("C:/pnadbases/pnad1990br.dat" "C:/pnadbases/dom2005.txt") 
saving(C:/mydocuments) dom ncomp

{pstd} Duas bases de dados ser�o geradas, uma para cada ano selecionado.

{pstd} 

{phang} Exemplo 3: arquivo de domic�lios, compat�vel com anos 1980.

{phang} datazoom_pnad, years(1990 2005) original("C:/pnadbases/pnad1990br.dat" "C:/pnadbases/dom2005.txt") 
saving("C:/mydocuments") dom comp81

{pstd} Duas bases de dados ser�o geradas, uma para cada ano selecionado, contendo somente as vari�veis
 pass�veis de compatibiliza��o.

{pstd} 

{phang} Exemplo 4: arquivo de pessoas, compat�vel com anos 1990.

{phang} datazoom_pnad, years(1997 2003) original("C:/pnadbases/pessoas97" "C:/pnadbases/pes2003.txt") 
saving(C:/mydocuments) pes comp92

{pstd} Duas bases de dados ser�o geradas, uma para cada ano selecionado, contendo somente as vari�veis
 pass�veis de compatibiliza��o. Note que n�o � poss�vel incluir
 um arquivo dos anos 1980 para compatibiliza��o nesta op��o. 

{pstd} 

{phang} Exemplo 5: arquivos de pessoas e domic�lios compatibilizados.

{phang} datazoom_pnad, years(1992 2005) original("C:/pnadbases/pes92.dat" "C:/pnadbases/dom92.dat" 
"C:/pnadbases/pes2005.txt" "C:/pnadbases/dom2005.txt") saving("C:/mydocuments") both comp92

{pstd} Duas bases de dados ser�o geradas, uma para cada ano selecionado, com as vari�veis de pessoas e
 domic�lios de cada ano em um �nico arquivo.
	

{title:Autor}
{p}

PUC-Rio - Departamento de Economia

Email {browse "mailto:datazoom@econ.puc-rio.br":datazoom@econ.puc-rio.br}


{title:Veja tamb�m}

Pacotes relacionados:

{help datazoom_censo} (se instalado)  
{help datazoom_pmenova} (se instalado)  
{help datazoom_pmeantiga} (se instalado)  
{help datazoom_pof2008} (se instalado)  
{help datazoom_pof2002} (se instalado)  
{help datazoom_pof1995} (se instalado)  
{help datazoom_ecinf} (se instalado) 


{p} Digite "net from http://www.econ.puc-rio.br/datazoom/portugues" para instalar a vers�o em portugu�s desses pacotes. 
For the english version, type "net from http://www.econ.puc-rio.br/datazoom/english".
