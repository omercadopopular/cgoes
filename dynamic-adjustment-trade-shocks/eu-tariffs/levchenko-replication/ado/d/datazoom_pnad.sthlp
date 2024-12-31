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
{bf:datazoom_pnad} {hline 2} Acesso aos microdados da PNAD em formato STATA - Versão 1.4

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:datazoom_pnad}
[{cmd:,}
{it:options}]

{phang}	OBS: digite 'db datazoom_pnad' na janela de comando para utilizar o programa via caixa de diálogo

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Inputs}
{synopt:{opt years(numlist)}} anos da PNAD {p_end}
{synopt:{opt original(str)}} caminho da pasta onde se localizam os arquivos de dados originais (.txt ou .dat) {p_end}
{synopt:{opt saving(str)}} caminho da pasta onde serão salvas as novas bases de dados {p_end}

{syntab:Tipos de Registro}
{synopt:{opt pes}} pessoas {p_end}
{synopt:{opt dom}} domicílios {p_end}
{synopt:{opt both}} pessoas e domicílios em um mesmo arquivo {p_end}

{syntab:Compatibilidade}
{synopt:{opt ncomp}} sem compatibilização (default) {p_end}
{synopt:{opt comp81}} compatível com anos 1980 {p_end}
{synopt:{opt comp92}} compatível com anos 1990 {p_end}

{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Descrição}

{phang}
{cmd:datazoom_pnad} extrai e constrói bases de dados da PNAD em formato STATA (.dta) a partir dos microdados 
originais, os quais não são disponibilizados pelo Portal (para informações sobre como obter
os arquivos originais de dados, consulte o site do IBGE www.ibge.gov.br). O programa pode ser utilizado para
todos anos desde 1981 (exclusive os anos censitários e 1994).

{phang} Existe a opção de compatibilizar variáveis ao longo dos anos. Isso é feito para
as variáveis mais frequentes na PNAD, ou seja, são desconsideraradas as variáveis que aparecem poucas vezes 
nesses 30 anos. Além disso, é possível que aspectos metodológicos impeçam a compatibilização de algumas variáveis. 
O processo de construção de variáveis compatibilizadas está documentado em "PNAD - Compatibilização", disponível para 
 download no site do Portal. Nesta opção, somente as variáveis compatibilizadas permanecem na base de dados final 
 (além das variáveis de controle). Caso haja variáveis monetárias na base final, todas serão deflacionadas para setembro
  de 2011.
 
{phang} Há duas possibilidades de compatibização, uma para os anos 1980 e outra para os
  1990. Isso ocorre devido a uma reformulação da PNAD ocorrida em 1992, quando, entre outras mudanças, houve separação
  dos arquivos de domicílios e pessoas, ampliação do questionário, alteração e sistematização dos nomes
  das variáveis e introdução de novos conceitos na seção de trabalho. Assim, a compatibilização para os anos
  1980, de certa forma, piora as PNADs de 1992 em diante. Mesmo as variáveis das PNADs dos anos 
1980 sofrem alguma modificação no processo de compatibilização ou mesmo são excluídas por não serem frequentes na década. Por 
  outro lado, como houve relativamente poucas mudanças após 1992, a compatibilização para os anos 1990 mantém a grande
  maioria das variáveis na base de dados (excluindo os suplementos). Nesta segunda possibilidade de compatibilização, 
  as PNAds dos anos 1980 não são consideradas.

{phang} A base final, compatibilizada ou não, pode conter somente as variáveis de pessoas ou de domicílios, 
ou dos dois tipos de registro conjuntamente. Ressalta-se que, para os anos 1980, somente os temas
 de educação, trabalho e rendimento foram investigados. Por conta
 disso, sob a opção de compatibilização para os anos 1980, todas as variáveis relacionadas a outros temas
  são excluídas, mesmo se elas existirem para o ano escolhido.

{phang}  O programa gera uma base de dados para cada ano escolhido. Se for o caso, use o comando 
{help append} para juntar todos os anos. Se a opção {opt both} for escolhida, o programa gera uma base
de dados incluindo as variáveis de domicílios e pessoas no mesmo arquivo.

{phang} Inicialmente, recomenda-se fortemente a utilização do programa via caixa de diálogo, pois facilita
a inserção de informações necessárias para o seu adequado funcionamento. Digite 'db datazoom_censo' na
janela de comando do STATA para acessar a caixa de diálogo.

{marker remarks}{...}
{title:Nota sobre os dados originais}

{phang}
Os nomes dos arquivos de microdados disponibilizados pelo IBGE foram uniformizados a partir de 2001. 
Os arquivos de pessoas possuem prefixo PES e os arquivos de domicílios, prefixo DOM, ambos com sufixo
 igual ao ano com quatro dígitos. Para os arquivos
 até 1999, é possível, no entanto, que haja diferenças nos nomes dos arquivos que o usuário possui 
 e aqueles utilizados pelo {cmd:datazoom_pnad}.

{phang}
Abaixo, segue uma lista com os nomes de arquivos esperados pelo {cmd:datazoom_pnad} para cada 
ano até 1999. De 2001 em diante, os nomes seguem o padrão adotado pelo IBGE desde 2001.

{phang}
Caso haja diferenças entre a lista abaixo e os arquivos do usuário, o programa deve funcionar 
corretamente somente após o usuário renomear seus arquivos de dados adaptando-os à lista. 

{phang}
No entanto, é possível que a estrutura dos dados utilizados pelo Data Zoom seja diferente da estrutura 
dos dados possuídos pelo usuário mesmo no caso em que há apenas diferenças nos nomes aparentemente. Se isso ocorrer, 
o programa não irá funcionar corretamente. Para verificar se há diferenças estruturais, confira o dicionário de 
variáveis disponível para download em www.econ.puc-rio.br/datazoom e compare com o dicionário em mãos.

{phang} - Lista dos nomes dos arquivos de microdados: 

{phang}
- Entre 1981 e 1990: pnadYYbr, onde YY é o ano da pesquisa, com dois dígitos (81 a 90)

{phang}
- Entre 1992 e 1995: PESYY para pessoas e DOMYY para domicílios

{phang}
- 1996: p96br para pessoas e d96br para domicílios

{phang}
- 1997: pessoas97 para pessoas e domicilios97 para domicílios

{phang}
- 1998 e 1999: pessoaYY para pessoas e domicilioYY para domicílios

{marker options}{...}
{title:Opções}
{dlgtab:Inputs}

{phang} {opt years(numlist)} especifica a lista de anos com os quais o usuário deseja trabalhar. Este programa pode
ser utilizado para os anos de 1981 a 2013, excluindo os anos censitários 1994.

{phang} {opt original(str)} indica o caminho dos arquivos de dados originais. É necessário incluir um caminho 
para cada arquivo com o qual o usuário deseja trabalhar.

{phang} {opt saving(str)} indica o caminho da pasta onde devem ser salvas as bases de dados produzidas pelo programa.

{dlgtab:Tipo de Registro}

{phang}
{opt pes}  especifica que o usuário deseja obter apenas o arquivo de pessoas. Se nenhum tipo de registro for escolhido, o programa
        automaticamente executa essa opção. (Não pode ser combinada com dom ou both).

{phang}
{opt dom}  especifica que o usuário deseja obter apenas o(s) arquivo(s) de domicílios. (Não pode ser combinada com {opt pes} 
ou {opt both}).

{phang}
{opt both}  especifica que o usuário deseja obter as variáveis de pessoas e domicílios em uma única base de dados, 
ou seja, o programa executa o comando {help merge} automaticamente para unir os
 dois tipos de registro. (Não pode ser combinada com {opt dom} ou {opt pes}).


{dlgtab:Waves Compatibilidade}

{phang}
{opt ncomp}  comp solicita que a compatibilização de variáveis não seja executada. A base final contém todas
 as variáveis do arquivo original.

{phang}
{opt comp81}  solicita que as variáveis sejam compatíveis com os anos 1980. Mesmo as variáveis das PNADs dos anos 
1980 sofrem alguma modificação no processo de compatibilização.

{phang}
{opt comp92}  solicita que as variáveis sejam compatíveis com os anos 1990. Esta opção não é válida para as PNADs dos 
anos 1980.  

{marker examples}{...}
{title:Exemplos}

{pstd}  OBS: Recomenda-se a execução do programa por meio da caixa de diálogo. Digite "db datazoom_pnad" na janela 
de comando do STATA para iniciar.

{phang} Exemplo 1: arquivo de pessoas, sem compatibilizar.

{phang} datazoom_pnad, years(1984 1997 1999 2003) original("C:/pnadbases/pnad1984br.dat" "C:/pnadbases/pessoas97" 
"C:/pnadbases/pessoa99.txt" "C:/pnadbases/pes2003.txt") saving("C:/mydocuments") pes ncomp 

{pstd} Quatro bases de dados serão geradas, uma para cada ano selecionado.

{pstd} 

{phang} Exemplo 2: arquivo de domicílios não compatibilizados.

{phang} datazoom_pnad, years(1990 2005) original("C:/pnadbases/pnad1990br.dat" "C:/pnadbases/dom2005.txt") 
saving(C:/mydocuments) dom ncomp

{pstd} Duas bases de dados serão geradas, uma para cada ano selecionado.

{pstd} 

{phang} Exemplo 3: arquivo de domicílios, compatível com anos 1980.

{phang} datazoom_pnad, years(1990 2005) original("C:/pnadbases/pnad1990br.dat" "C:/pnadbases/dom2005.txt") 
saving("C:/mydocuments") dom comp81

{pstd} Duas bases de dados serão geradas, uma para cada ano selecionado, contendo somente as variáveis
 passíveis de compatibilização.

{pstd} 

{phang} Exemplo 4: arquivo de pessoas, compatível com anos 1990.

{phang} datazoom_pnad, years(1997 2003) original("C:/pnadbases/pessoas97" "C:/pnadbases/pes2003.txt") 
saving(C:/mydocuments) pes comp92

{pstd} Duas bases de dados serão geradas, uma para cada ano selecionado, contendo somente as variáveis
 passíveis de compatibilização. Note que não é possível incluir
 um arquivo dos anos 1980 para compatibilização nesta opção. 

{pstd} 

{phang} Exemplo 5: arquivos de pessoas e domicílios compatibilizados.

{phang} datazoom_pnad, years(1992 2005) original("C:/pnadbases/pes92.dat" "C:/pnadbases/dom92.dat" 
"C:/pnadbases/pes2005.txt" "C:/pnadbases/dom2005.txt") saving("C:/mydocuments") both comp92

{pstd} Duas bases de dados serão geradas, uma para cada ano selecionado, com as variáveis de pessoas e
 domicílios de cada ano em um único arquivo.
	

{title:Autor}
{p}

PUC-Rio - Departamento de Economia

Email {browse "mailto:datazoom@econ.puc-rio.br":datazoom@econ.puc-rio.br}


{title:Veja também}

Pacotes relacionados:

{help datazoom_censo} (se instalado)  
{help datazoom_pmenova} (se instalado)  
{help datazoom_pmeantiga} (se instalado)  
{help datazoom_pof2008} (se instalado)  
{help datazoom_pof2002} (se instalado)  
{help datazoom_pof1995} (se instalado)  
{help datazoom_ecinf} (se instalado) 


{p} Digite "net from http://www.econ.puc-rio.br/datazoom/portugues" para instalar a versão em português desses pacotes. 
For the english version, type "net from http://www.econ.puc-rio.br/datazoom/english".
