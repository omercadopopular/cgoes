"""

PROJETO: "Identificação de Redundâncias no Setor Público com Modelos de Espaços Vetoriais e
Análises de Componentes Principais: o Caso Brasileiro"

EQUIPE DO PROJETO: Carlos Góes (SAE) e Eduardo Leoni (SAE).

AUTOR DESTE CÓDIGO: Carlos Góes e Eduardo Leoni, SAE/Presidência da República

OBJETIVO DESTE CÓDIGO: Importar a base de dados do MPOG de finalidades e competências de diversas agências,
e limpar palavras irrelevantes para análise.

DATA: 16/06/2017

"""


import json
import urllib
import ssl
import pandas as pd
import numpy as np
import re
import nltk

#####################################
# 1. Retrieve Databases 
#####################################

readdata = False

if readdata == True:
    #Import JSON from dados.gov.br   
    url = "http://estruturaorganizacional.dados.gov.br/doc/estrutura-organizacional/completa.json"
    ctx = ssl.create_default_context()
    ctx.check_hostname = False
    ctx.verify_mode = ssl.CERT_NONE
    urlopen = urllib.request.urlopen(url, context=ctx)
    data = json.loads(urlopen.read())
    
    # Transform JSON file into pandas dataframe, save it   
    data = pd.io.json.json_normalize(data['unidades'])
    data.to_json(path_or_buf="K://Notas Técnicas//Redundacias no Setor Publico//data//data.json")

#####################################
# 2. Read Data 
#####################################

data = pd.read_json(path_or_buf="K://Notas Técnicas//Redundacias no Setor Publico//data//data.json")

#####################################
# 3. Adjust missing values 
#####################################

# Set missing values to blank strings

data['competencia'] = data['competencia'].replace(to_replace=["",".",".\n\n"], value=np.nan)
data['finalidade'] = data['finalidade'].replace(to_replace=["",".",".\n\n"], value=np.nan)
data['missao'] = data['missao'].replace(to_replace=["",".",".\n\n"], value=np.nan)
data['competencia'] = data['competencia'].fillna("")
data['finalidade'] = data['finalidade'].fillna("")
data['missao'] = data['missao'].fillna("")

# Build concatenated column

data['texto'] = data['competencia'] + " " + data['finalidade'] 
data['texto'] = data['texto'].replace(to_replace=" ", value=np.nan)
data['texto'] = data['texto'].replace(to_replace="  ", value=np.nan)

#####################################
# 4. Track hierarchy
#####################################
  
### Find which ministry (if nor under a ministry, the presidency) of each organization

## Strip url out

data['codigoUnidadePai'] = [re.sub('[^0-9]', '', row) for row in data['codigoUnidadePai']]

data['codigoUnidade'] = [re.sub('[^0-9]', '', row) for row in data['codigoUnidade']]

## dataL holds the data that has not been matched to a ministry
dataL = data[['codigoUnidade', 'codigoUnidadePai']]
dataL = dataL.rename(columns={"codigoUnidadePai":"codigoUnidade0"})

## dataL1 holds the original data
dataL1 = data[['codigoUnidadePai', 'codigoUnidade']]
dataL1 = dataL1.assign(PrPai0=(dataL1.codigoUnidadePai=='26'))
dataL1 = dataL1.rename(columns={"codigoUnidadePai":"codigoUnidadePai0", "codigoUnidade":"codigoUnidade0"})

## empty data frame to hold results with code of the ministry
dataL0 = pd.DataFrame( )

while ((dataL.shape[0])>0): 
  print((dataL.shape[0]))
  ## merge with original data by (grand)parent
  dataL = pd.merge(dataL, dataL1, on='codigoUnidade0', how='left')
  ## check if the new (grand) parent is the presidency or a ministry
  if (pd.isnull(dataL.PrPai0).sum()>0):
      dataL.PrPai0[pd.isnull(dataL.PrPai0)]=True
  ## only data with a parent that is a ministry                   
  dnow = dataL.query("PrPai0==1")
  ## concat to results
  dataL0=pd.concat([dataL0, dnow])
  ## anti join to get unmatched data
  dataL = pd.merge(dataL,dataL0, how='outer', indicator=True)
  dataL = dataL.query("_merge=='left_only'")
  dataL = dataL[['codigoUnidade', 'codigoUnidadePai0']]
  dataL = dataL.rename(columns={"codigoUnidadePai0":"codigoUnidade0"})

## holds codigoUnidade and associated ministry code in codigoUnidade0
dataL0 = dataL0[['codigoUnidade', 'codigoUnidade0']]
dataL0 = dataL0.rename(columns={"codigoUnidade0":"codigoUnidadeMestre"})


# merge dataframes
data = pd.merge(data,dataL0, on='codigoUnidade', how='left')
"""

#set in
data = data.set_index('codigoUnidade')

data['nomeUnidadeMestre'] = [data['nome'].loc[item] for item in data['codigoUnidadeMestre']]
"""

#####################################
# 5. Keep only bureaus in Brasilia-DF
#####################################

# Drop missing valuables

data = data.dropna(subset=["texto"])
data = data.dropna(subset=["endereco"])
data['uf'] = [row[0]['uf'] for row in data['endereco']]
workdata = data[ data['uf'] == 'DF'].copy()  

#####################################
# 6. Drop duplicates and irrelevant columns
#####################################

workdata = workdata.drop([
       'competencia', 'contato',
       'dataFinalVersaoConsulta', 'dataInicialVersaoConsulta',
       'descricaoAtoNormativo', 'endereco', 'finalidade', 'missao',
       'nivelNormatizacao', 'versaoConsulta', 'operacao'
       ], axis=1)

workdata = workdata.drop_duplicates(subset=['codigoUnidadePai','nome'], keep='first')

#####################################
# 7. Drop bureaus related to:
#   (a) military and police;
#   (b) transport facilities (airports, ports, etc.);
#   (c) universities, museums, and schools;
#   (d) purely administrativetasks (human resources, security, cleaning, procurement, IT, etc.);
#   (e) generic advisory and public  relations  roles;
#   (f) foreign  affairs.
#####################################

## universities

workdata = workdata[ workdata['codigoSubNaturezaJuridica'] != "http://estruturaorganizacional.dados.gov.br/id/subnatureza-juridica/17" ]
workdata = workdata[ workdata['codigoSubNaturezaJuridica'] != "http://estruturaorganizacional.dados.gov.br/id/subnatureza-juridica/18" ]
workdata = workdata[ workdata['codigoSubNaturezaJuridica'] != "http://estruturaorganizacional.dados.gov.br/id/subnatureza-juridica/20" ]

## other bureaus

ldrop = [
        # Foreign Affairs
        'embaixada','Embaixada',
        'consulado',"Consulado",
        'internacional',"Internacional",
        "internacionais","Internacionais",
        "cerimonial", "Cerimonial",
        
        # Military, Judiciary, and Police
        "delegacia", "Delegacia",
        "batalhão","Batalhão",
        "regimento","Regimento",
        "esquadrão","Esquadrão",
        "grupamento","Grupamento"
        "combate","Combate",
        "cavalaria","Cavalaria",
        "infantaria","Infantaria",
        "artilharia", "Artilharia",
        "ajudância", "Ajudância",
        "comando", "Comando",
        "congregação", "Congregação",
        "ala", "Ala",
        "brigada", "Brigada",
        "Centro de Preparação de Oficiais"
        "destacamento", "Destacamento",
        "Grupamento de Apoio",
        "núcleo", "Núcleo",
        "Parque de Material"
        "Prefeitura de Aeronáutica",
        "procuradoria", "Procuradoria",
        
        # Transport
        "base", "Base",
        "Administração da Hidrovia",
        "Administração das Hidrovias",
        "aeroporto", "Aeroporto",
        "Capitania", "capitania",
        "Companhia Docas",
        
        # Local Agencies
        "alfândega", "Alfândega",
        "Agência da Receita Federal",
        "Agência da Previdência Social",
        "Agência Regional",
        "Agência Fluvial",
        "biblioteca", "Biblioteca"
        "Casa de Saúde Indígena",
        "Centro Cultural",
        "Centro Estadual",
        "Centro Regional",
        "Centro de Atendimento ao Contribuinte"
        "campus", "Campus",
        "câmpus", "Câmpus",
        "colégio", "Colégio",
        "Comissao de Analise de Defesa Previa",
        "Comissão de Analise de Defesa Previa",
        "Comitê de Integração Lavoura Pecuária",
        "Conselho Consultivo da Reserva Biológica",
        "Conselho Consultivo do Parque Nacional",
        "Conselho de Previdência Social",
        "Controladoria Regional da União",
        "Comitê de Decisão Regional",
        "Conselho Escolar",
        "Companhia de Pesquisa de  Recursos Minerais",
        "Centro de Atendimento ao Contribuinte",
        "Coordenação Regional",
        "Coordenação da Frente de Proteção Etnoambiental",
        "Distrito Sanitário Especial Indígena",
        "Escritório Especial",
        "Escritório Regional",
        "Escritório Técnico",
        "Escritório de Corregedoria",
        "Escritório de Pesquisa e Investigação",
        "Escritório de Representação",
        "Estação Ecológica",
        "Estação de Piscicultura",
        "Floresta Nacional",
        "Gerência Administrativa em",
        "Gerência Executiva  do IBAMA",
        "Gerência Jurídica Regional",
        "Gerência Regional do Trabalho e Emprego",
        "Gerência Técnica Regional",
        "Gerência-Executiva",
        "Hospital", "hospital",
        "Inspetoria da Receita Federal",
        "museu", "Museu",
        "junta", "Junta",
        "Nucleo de Apoio Tecnico",
        "Nucleo de Comunicacao Social",
        "Nucleo de Inteligencia",
        "Núcleo Administrativo",
        "Núcleo Administrativo e Financeiro",
        "Núcleo Estadual",
        "Núcleo Júridico",
        "Núcleo Regional", 
        "Núcleo da ANS",
        "Núcleo da Procuradoria Federal",
        "Núcleo de Administração Aduaneira",
        "PVAPF",
        "Parque Nacional", "Parque Histórico",
        "Posto", "posto",
        "Regional", "regional",
        "Reserva Biológica",
        "Reserva Extrativista",
        "Serviço de Orientação e Análise Tributária",
        "Serviço de Procedimentos Arrecadatórios e de Desenvolvimento da Mineração"
        "Serviço de Programação e Logística",
        "Serviço de Recursos Humanos",
        "Serviço de Recursos Logísticos e Informática",
        "Serviço de Representação Judicial",
        "Serviço de Saúde do Trabalhador",
        "Setor de Administração e Logistica Policial",
        "Setor de Atendimento na Área de Trabalho, Emprego e Renda",
        "Setor de Fiscalização e de Controle Aduaneiro",
        "Seção Especial de Tecnologia da Informação",
        "Seção Laboratorial Avançada",
        "Seção Operacional  de Gestão de Pessoas",
        "Seção Operacional da Gestão de Pessoas",
        "Seção de Administração Aduaneira",
        "Seção de Administração de Informações de Segurados",
        "Seção de Apoio Administrativo",
        "Seção de Atendimento",
        "Seção de Benefícios",
        "Seção de Cadastro",
        "Seção de Controle e Acompanhamento Tributário",
        "Seção de Despacho Aduaneiro",
        "Seção de Fiscalização Aduaneira",
        "Seção de Fomento e Cooperação Técnica",
        "Seção de Gerenciamento de Benefícios por Incapacidade",
        "Seção de Inspeção do Trabalho",
        "Seção de Manutenção de Direitos",
        "Seção de Matéria de Benefícios",
        "Seção de Multas e Recursos",
        "Seção de Orientação e Análise Tributária",
        "Seção de Policiamento e Fiscalização",
        "Seção de Politicas de Trabalho, Emprego e Renda",
        "Seção de Políticas de Trabalho, Emprego, Renda e Economia Solidária",
        "Seção de Programação, Avaliação e Controle da Atividade Fiscal",
        "Seção de Reconhecimento Inicial de Direitos",
        "Seção de Reconhecimento de Direitos",
        "Seção de Relações do Trabalho",
        "Seção de Revisão de Direitos",
        "Seção de Saúde do Trabalhador",
        "Superintendência Estadual",
        "Superintendência Federal de Agricultura, Pecuária e Abastecimento",
        "Superintendência de Administração do Ministério da Fazenda",
        "Superintendência de Administração",
        "Superintendência do DNPM",
        "Superintendência do IBAMA",
        "Superintendência do Patrimônio da União",
        "Supervisão Operacional de Benefícios",
        "Unidade Armazenadora",
        "Unidade Avançada em",
        "Unidade Estadual do IBGE",
        "Unidade Local em",
        "Unidade de Campo",
        "Unidade de Vigilância Agropecuária"
        "Área de Proteção Ambiental"
       
        # Councils
        "Comissão de Ética",
        "Comitê de Segurança da Informação e Comunicações",
        "Comitê de Segurança da Informação e das Comunicações",
        "Comitê de TIC",
        "Comitê de Tecnologia da Informação"
        "Conselho Deliberativo",
        "Conselho Diretor",
        "Conselho Fiscal",
        "Conselho Superior",
        "Conselho Técnico-Científico",
        "Conselho Técnico-Profissional",      
        "Conselho Técnico",
        "Conselho Técnico Científico",
        "Conselho Técnico-Operacional"
        "Conselho de Administração",
        "Conselho de Curadores",
        "colegiado", "Colegiado",      
        
        # Misc
        "ouvidoria","Ouvidoria",
        "Assembleia Geral", "Assembléia Geral", "Assembléia-Geral",
        "assessoria", "Assessoria",
        "assistente", "Assistente",
        "assistência", "Assistência",
        "auditoria", "Auditoria",
        "Consultoria Jurídica",
        "Coordenação Administrativa",
        "Coordenação de Administração",
        "Coordenação de Apoio Administrativo"
        "Coordenação Técnica",
        "Coordenação de Administração de Pessoal",
        "Coordenação de Administração do Pessoal Ativo"
        "Coordenação de Administração de Pessoal e Pagamento",
        "Coordenação de Administração de Pessoas",
        "Coordenação de Administração de Recursos Humanos",
        "Coordenação de Administração e Finanças",
        "Coordenação de Contabilidade",
        "Coordenação de Contratos",
        "Coordenação de Convênios",
        "Coordenação de Engenharia",
        "Coordenação de Execução Orçamentária",
        "Coordenação de Exploração da Infraestrutura Rodoviária",
        "Coordenação de Finanças",
        "Coordenação de Fiscalização",
        "Coordenação de Gestão de Pessoas",
        "Coordenação de Infraestrutura",
        "Coordenação de Licitações",
        "Coordenação de Logística",
        "Coordenação de Orçamento",
        "Coordenação de Planejamento",
        "Coordenação de Recursos Humanos",
        "Coordenação de Recursos Logísticos",
        "Coordenação-Geral Administrativa",
        "Coordenação-Geral de Administração",
        "Coordenação-Geral de Apoio Administrativo",
        "Coordenação-Geral Técnica"	,
        "Coordenação-Geral de Administração de Pessoal"	,
        "Coordenação-Geral de Administração do Pessoal Ativo"	,
        "Coordenação-Geral de Administração de Pessoal e Pagamento"	,
        "Coordenação-Geral de Administração de Pessoas"	,
        "Coordenação-Geral de Administração de Recursos Humanos"	,
        "Coordenação-Geral de Administração e Finanças"	,
        "Coordenação-Geral de Contabilidade"	,
        "Coordenação-Geral de Contratos"	,
        "Coordenação-Geral de Convênios"	,
        "Coordenação-Geral de Engenharia"	,
        "Coordenação-Geral de Execução Orçamentária"	,
        "Coordenação-Geral de Exploração da Infraestrutura Rodoviária"	,
        "Coordenação-Geral de Finanças"	,
        "Coordenação-Geral de Fiscalização",	
        "Coordenação-Geral de Gestão de Pessoas"	,
        "Coordenação-Geral de Infraestrutura"	,
        "Coordenação-Geral de Licitações"	,
        "Coordenação-Geral de Logística"	,
        "Coordenação-Geral de Orçamento"	,
        "Coordenação-Geral de Planejamento",	
        "Coordenação-Geral de Recursos Humanos"	,
        "Coordenação-Geral de Recursos Logísticos",
        "Corregedoria",
        "Divisão de Apoio",
        "Divisão de Aposentadoria",
        "Divisão de Arrecadação e Cobrança",
        "Divisão de Cadastro",
        "Divisão de Caracterização e Incorporação",
        "Divisão de Compras",
        "Divisão de Comunicação Social",
        "Divisão de Contabilidade",
        "Divisão de Contratos",
        "Divisão de Convênios",
        "Divisão de Execução Financeira",
        "Divisão de Execução Orçamentária",
        "Divisão de Finanças",
        "Divisão de Fiscalização",
        "Divisão de Gestão Administrativa",
        "Divisão de Gestão de Pessoas",
        "Divisão de Licitações",
        "Divisão de Logística",
        "Divisão de Material",
        "Divisão de Pagamento de Pessoal",
        "Divisão de Patrimônio",
        "Divisão de Pessoal",
        "Divisão do Pessoal",
        "Divisão de Planejamento",
        "Divisão de Programação Financeira",
        "Divisão de Programação Orçamentária"
        "Divisão de Programação e Logística",
        "Divisão de Receitas Patrimoniais",
        "Divisão de Recursos Humanos",
        "Divisão de Recursos Logísticos",
        "Divisão de Relações Públicas",
        "Divisão de Serviços Gerais",
        "Divisão de Suprimentos",
        "Divisão de Tecnologia",
        "Gerência de Finanças",
        "Gerência de Operações",
        "Núcleo de Administração de Pessoal",
        "Núcleo de Administração, Planejamento e Gestão",
        "Núcleo de Almoxarifado",
        "Núcleo de Almoxarifado e Patrimônio",
        "Núcleo de Apoio Administrativo",
        "Núcleo de Assuntos Internos",
        "Núcleo de Atividades Auxiliares",
        "Núcleo de Cartório",
        "Núcleo de Cobrança e Recuperação de Crédito",
        "Núcleo de Comunicação Social",
        "Serviço Administrativo",
        "Serviço de Acompanhamento dos Maiores Contribuintes",
        "Serviço de Administração",
        "Serviço de Administração de Informações de Segurados",
        "Serviço de Apoio Administrativo",
        "Serviço de Benefícios",
        "Serviço de Cadastro e Licitações",
        "Serviço de Comunicação Social",
        "Serviço de Construção",
        "Serviço de Contabilidade e Finanças",
        "Serviço de Controle e Acompanhamento Tributário",
        "Serviço de Desaprorpiação, Reassentamento e Meio Ambiente",
        "Serviço de Desenvolvimento da Mineração",
        "Serviço de Execução Orçamentária e Financeira",
        "Serviço de Fiscalização",
        "Serviço de Gestão de Pessoas",
        "Serviço de Gestão de Títulos Minerários",
        "Serviço de Inativos e Pensionistas",
        "Serviço de Manutenção",
        "Serviço de Operações",
        "Serviço de Orçamento e Finanças",
        "Serviço de Pagamento de Pessoal",
        "Serviço de Patrimônio",
        "Serviço de Planejamento e Projetos",
        "Serviço de Suprimentos",
        "Serviço de Tecnologia da Informação",
        "Setor Administrativo",
        "Setor Administrativo, de Desenvolvimento e de Recursos Humanos",
        "Setor Contábil e Financeiro",
        "Setor Financeiro",
        "Setor Orçamentário",
        "Setor Técnico Administrativo",
        "Setor Técnico-Científico",
        "Setor de Apoio Administrativo",
        "Setor de Apoio à Logística e Gestão da Oferta",
        "Setor de Arrecadação e Cobrança",
        "Setor de Atividades Auxiliares",
        "Setor de Benefícios",
        "Setor de Capacitação",
        "Setor de Compras e Contratos",
        "Setor de Comunicação",
        "Setor de Controle de Áreas",
        "Setor de Contábil e Financeiro"
        "Setor de Cálculos e Pagamentos Judiciais",
        "Setor de Execução Orçamentária e Financeira",
        "Setor de Fiscalização do Trabalho",
        "Setor de Identificação e Registro Profissional",
        "Setor de Inspeção do Trabalho",
        "Setor de Material",
        "Setor de Patrimônio"
        "Setor de Pessoal"
        "Setor de Protocolo",
        "Setor de Recursos Humanos",
        "Setor de Relações do Trabalho",
        "Setor de Segurança e Saúde no Trabalho",
        "Setor de Serviços Gerais",
        "Setor de Tecnologia da Informação e Logística",
        "Setor de Transporte",
        "Setor do Fundo de Garantia do Tempo de Serviço",
        "Seção Administrativa",
        "Seção de Apoio Administrativo e de Patrimônio",
        "Seção de Apoio Operacional",
        "Seção de Comunicação Social",
        "Seção de Consultoria e Assessoramento",
        "Seção de Execução Orçamentária e FInanceira",
        "Seção de Fiscalização",
        "Seção de Informática",
        "Seção de Logística, Licitação e Contratos e Engenharia",
        "Seção de Manutenção",
        "Seção de Orçamento, Finanças e Contabilidade",
        "Seção de Pagamento",
        "Seção de Pessoal",
        "Seção de Programação e Logística",
        "Seção de Recursos Humanos",
        "Seção de Recursos Logísticos",
        "Seção de Tecnologia da Informação",
        "Subseção Auxiliar",
        "Seção do Pessoal",
        "Unidade de Apoio Administrativo",      

        ]

for name in ldrop:
    workdata = workdata[~workdata['nome'].str.contains(name)]

#####################################
# 8. Clean word dataset
#####################################

# Reset index

workdata = workdata.reset_index()

# Iterate through relevant text data and trim irrelevant strings

trimmed = []
for row in workdata['texto']:
    text = row
    text = re.sub(r'\xa0\xa0\xa0\xa0\xa0', ' ', text)
    text = re.sub(r'\r\n', ' ', text)
    text = re.sub(r"\d", ' ', text)    
    text = re.sub(r'-', ' ', text)
    text = re.sub(r'\tI', ' ', text)
    text = re.sub(r'I\t', ' ', text)
    text = re.sub(r'I ', ' ', text)
    text = re.sub(r'II', ' ', text)
    text = re.sub(r'III', ' ', text)    
    text = re.sub(r'IV', ' ', text)    
    text = re.sub(r'V', ' ', text)    
    text = re.sub(r'VI', ' ', text)    
    text = re.sub(r'VII', ' ', text)    
    text = re.sub(r'VIII', ' ', text)    
    text = re.sub(r'IX', ' ', text)    
    text = re.sub(r'X', ' ', text)    
    text = re.sub(r'XI', ' ', text)    
    text = re.sub(r'XII', ' ', text)    
    text = re.sub(r'XIII', ' ', text)    
    text = re.sub(r'XIV', ' ', text)    
    text = re.sub(r'XV', ' ', text)    
    text = re.sub(r'XVI', ' ', text)    
    text = re.sub(r'XVII', ' ', text)    
    text = re.sub(r'XVIII', ' ', text)    
    text = re.sub(r'XIX', ' ', text)    
    text = re.sub(r"a\)", ' ', text)    
    text = re.sub(r"b\)", ' ', text)    
    text = re.sub(r"c\)", ' ', text)    
    text = re.sub(r"d\)", ' ', text)    
    text = re.sub(r"e\)", ' ', text)    
    text = re.sub(r"f\)", ' ', text)    
    text = re.sub(r"g\)", ' ', text)    
    text = re.sub(r"h\)", ' ', text)    
    text = re.sub(r"i\)", ' ', text)    
    text = re.sub(r"j\)", ' ', text)    
    text = re.sub(r"k\)", ' ', text)    
    text = re.sub(r"l\)", ' ', text)    
    text = re.sub(r"m\)", ' ', text)    
    text = re.sub(r"n\)", ' ', text)    
    text = re.sub(r"o\)", ' ', text)    
    text = re.sub(r"p\)", ' ', text)    
    text = re.sub(r"q\)", ' ', text)    
    text = re.sub(r"r\)", ' ', text)    
    text = re.sub(r"s\)", ' ', text)    
    text = re.sub(r"t\)", ' ', text)    
    text = re.sub(r"u\)", ' ', text)    
    text = re.sub(r"v\)", ' ', text)    
    text = re.sub(r"x\)", ' ', text)    
    text = re.sub(r"z\)", ' ', text)    
    text = re.sub(r"janeiro", ' ', text)    
    text = re.sub(r"fevereiro", ' ', text)    
    text = re.sub(r"março", ' ', text)    
    text = re.sub(r"abril", ' ', text)    
    text = re.sub(r"maio", ' ', text)    
    text = re.sub(r"junho", ' ', text)    
    text = re.sub(r"julho", ' ', text)    
    text = re.sub(r"agosto", ' ', text)    
    text = re.sub(r"setembro", ' ', text)    
    text = re.sub(r"outubro", ' ', text)    
    text = re.sub(r"novembro", ' ', text)    
    text = re.sub(r"dezembro", ' ', text)    
    text = re.sub(r"1º    ", ' ', text)    
    text = re.sub(r"2º    ", ' ', text)    
    text = re.sub(r"3º    ", ' ', text)    
    text = re.sub(r"4º    ", ' ', text)    
    text = re.sub(r"5º    ", ' ', text)    
    text = re.sub(r"6º    ", ' ', text)    
    text = re.sub(r"7º    ", ' ', text)    
    text = re.sub(r"8º    ", ' ', text)    
    text = re.sub(r"9º    ", ' ', text)    
    text = re.sub(r"Art.", ' ', text)    
    text = re.sub(r"artigo ", ' ', text)    
    text = re.sub(r"art ", ' ', text)    
    text = re.sub(r"parágrafo ", ' ', text)    
    text = re.sub(r'nº', ' ', text)
    text = re.sub(r'º', ' ', text)
    text = re.sub(r'ª', ' ', text)
    text = re.sub(r'Dec ', ' ', text)
    text = re.sub(r'decreto ', ' ', text)
    text = re.sub(r'Lei ', ' ', text)
    text = re.sub(r'lei ', ' ', text)
    text = re.sub(r'\/', ' ', text)
    text = re.sub(r'\(', ' ', text)
    text = re.sub(r'\)', ' ', text)
    text = re.sub(r'\u201d', '', text)
    text = re.sub(r'\u201c', '', text)
    text = re.sub(r'\.', ' ', text)
    text = re.sub(r'\;', ' ', text)
    text = re.sub(r'\:', ' ', text)
    text = re.sub(r'\,', ' ', text)
    text = re.sub(r'\n', ' ', text)
    trimmed.append(text)

workdata['trimmed'] = trimmed

# Import stopwords

stopwords = nltk.corpus.stopwords.words('portuguese')
sappend = ['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','x','y','z',
                  'y','x','www','vvvvvvvvvvvvvvvvvvv','ttransmitir','ttac','sss','ssm','ssistir','ssigamd','ssessoria',
                  'ssessorar','ssentamentos','ssecretaria','sse','ssans','rrps','rrp','rreo','rregimentos','ppsec','ppsa',
                  'pps','ppra','ppp','ppoa','ppo','ppm','ppif','ppi','ppho','ppgs','ppgq','ppgep','ppg','ppfs','ppf','ppcor',
                  'ppci','ppcerrado','ppcdam','ppc','ppb','ppap','ppaer','ppaa','ppa','oordenar','ooc','nnas','mmobnm',
                  'mministério','mme','mmds','mma','jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj','jjjjjjjjjjjjjjjjjjjjjjjjjj',
                  'jjjjjjjjjjjjjjj','jjjjjjjj','iintermediar','iinstituição','iincentivar','ggsan','ggrin','ggrep','ggras',
                  'ggof','ggmed','ggiss','ggfis','gges','ggeop','ggatp','ggart','ggafi','ggaf','ffixar','ffie','ffe','eexterno',
                  'eexpedientes','eexército','eexecução','eexaminar','eetec','eestabelecer','eesec','eeletrônica','eel','eee',
                  'eed','eeb','eear','ddte','ddp','ddoc','ddg','ddfem','dde','ddddddddddddddddddd','ddd','ddc','dda','cczee',
                  'ccta','cct','ccs','ccr','ccpi','ccp','ccont','cconj','cconf','ccon','ccogi','ccof','ccoat','ccoad','ccne',
                  'ccn','ccm','ccim','ccie','cci','ccg','ccfgts','ccfex','ccem','ccee','cce','ccca','ccc','ccbs','ccb','ccasj',
                  'ccaf','ccade','ccab','cca','aavaliação','aassistência','aaprovar','aaliar','aagricultura','aagência','aae',
                  'aadministração', 'zee','www','wff','webapp','vvvvvvvvvvvvvvvvvvv','voo','vii','tss','trr','trainee','tmpp',
                  'terr','tcc','sss','spp','spaa','sobrevoo','small','sisredd','sispp','sicofaa','siass','segall','see','seaa',
                  'sdpp','sdee','scc','saa','rpp','redd','realizaçãoo','rcc','raa','qss','qaa','pss','propp','propostaa','ppp',
                  'ppaa','pnss','pndrss','pee','pecc','pdd','pcc','pass','paaa','paa','omm','off','occ','nuepp','mrcc','mcc',
                  'marshall','lncc','kdkdkdkdkdkdkdkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk','jurídicaass',
                  'ipcc','inss','ifrr','icc','hall','gtt','grr','gmm','ggiss','gff','gee','gecc','fmm','fcc','estress',
                  'estabelecendoo','especificaçõess','eppgg','eee','dtt','drr','dpp','dpmm','dosaa','docentee','dll','diss',
                  'diaa','dhaa','dgmm','ddddddddddddddddddd','ddd','dcc','czee','ctaa','cpp','copp','coo','conaredd','comumm',
                  'comress','coacc','cnpaa','cnmm','cndrss','cmm','ciaa','cgrr','cgaa','cfacc','cdfmm','cczee','ccee','ccc',
                  'capp','camss','call','business','araguaiafaecc','appcc','antt','anee','afrmm','aee','acpp'
                  ]

for word in sappend:
    stopwords.append(word)

# Trim stopwords

def remove_accents(data):   
    # fuction from: https://stackoverflow.com/questions/8694815/removing-accent-and-special-characters
    import unicodedata
    import string
    return ''.join(x for x in unicodedata.normalize('NFKD', data) if x in string.ascii_letters).lower()

worddata = []
stemmer = nltk.stem.RSLPStemmer()
for row in workdata['trimmed']:
    rowvector = []
    tokenizer = nltk.tokenize.RegexpTokenizer(r'\w+') 
    for word in tokenizer.tokenize(row):
        wordlower = word.lower()
        if (wordlower and stemmer.stem(wordlower)) not in stopwords:
            rowvector.append(
                    remove_accents(stemmer.stem(wordlower))
                    )
        else:
            continue      
    worddata.append(rowvector)

# Store data in column

workdata['worddata'] = worddata

#####################################
# 9. Drop empty rows
#####################################

workdata = workdata[ [len(row) > 10 for row in workdata['worddata']] ]

#####################################
# 10. Save data in a new JSON file
#####################################

workdata.to_json("K://Notas Técnicas//Redundacias no Setor Publico//results//workdata.json")
