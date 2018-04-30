# -*- coding: utf-8 -*-
"""
Created on Thu Feb  8 18:17:00 2018

@author: CarlosABG
"""

# Importar bibliotecas

import pandas as pd
import numpy as np
import statsmodels.api as sm

# Definir paths

PATH_2009_2016 = r'H:\Notas Conceituais\SegPub-Drogas\Dados\Tribunais\JN17Set2017.csv'
PATH_2003_2008_estados = r'H:\Notas Conceituais\SegPub-Drogas\Dados\Tribunais\CNJ2003_2008_estados.csv'
PATH_2003_2008_federal = r'H:\Notas Conceituais\SegPub-Drogas\Dados\Tribunais\CNJ2003_2008_federal.csv'

DF = pd.read_csv(PATH_2009_2016, na_values='nd', encoding='latin1', sep=";", decimal=",")

##########################################
## 1. Consolidar base de dados 2009_2016 #
##########################################

SAMPLE = ['Estadual', 'Federal']

DF = DF[ DF['justica'].isin(SAMPLE) ]

VARS = [
        'ano',
        'justica',
        'sigla',
        'uf_sede',
        'dpe', #DPE - Despesa com Pessoal e Encargos
        'dpj',# Dpj - Despesa Total da Justiça Estadual
        'drh',	#DRH - Despesa com Recursos Humanos
        'sent',	#Sent - Total de Sentenças / Decisões
        'sentcrim',	#SentCrim - Total de Sentenças e Decisões Criminais      
        'serv',	#Total de servidores
        'magp',	#Número de cargos de Magistrado Providos
        'dpjio',	#Despesa total (Exceto gastos com inativos e obras)
        'tfaux', #TFAux - Total da Força de Trabalho Auxiliar
        'jg', #JG - Assistência Judiciária Gratuita
        'tbaixjudcrimpl1', #TBaixJudCrimPL1º - Total de Processos Baixados de Execução de Penas Privativas de Liberdade no 1º Grau
        'tbaixjudcrimnpl1', #TBaixJudCrimNPL1º - Total de Processos Baixados de Execução de Penas Não-Privativas de Liberdade no 1º Grau
        'tbaixjudcrimnplje', #TBaixJudCrimNPLJE - Total de Processos Baixados de Execução de Penas Não-Privativas de liberdade nos Juizados Especiais
        'tbaixccrim1', #TBaixCCrim1º - Processos de Conhecimento Baixados no 1º Grau Criminais
        ]

DF = DF[VARS]
DF['pcriminal'] = DF['sentcrim'] / DF['sent']
DF['tcriminal1º'] = DF[['tbaixjudcrimpl1', 'tbaixjudcrimnpl1', 'tbaixjudcrimnplje','tbaixccrim1']].sum(axis=1)
DF['aux'] = DF['serv'] + DF['tfaux']

ESTADUAL = DF[ (DF['justica'] == 'Estadual') & ~(DF['sigla'] == 'TJ')]
FEDERAL = DF[ (DF['justica'] == 'Federal') & ~(DF['sigla'] == 'TRF')]

ESTADUAL.to_csv(r'H:\Notas Conceituais\SegPub-Drogas\Dados\Tribunais\Estadual2003-2016.csv', sep=";", decimal=",")

####################################################
## 2. Agregar base de dados 2003-2008 ao DataFrame #
####################################################

# Estadual

TDF = pd.read_csv(PATH_2003_2008_estados, sep=";", decimal=",")
ESTADUAL_C = TDF.append(ESTADUAL[['uf_sede','ano', 'dpj', 'drh', 'magp', 'aux', 'jg']])
ESTADUAL_C = ESTADUAL_C.groupby('ano').sum().append(ESTADUAL.groupby(['ano']).sum()[['sent']])
ESTADUAL_C = ESTADUAL_C.groupby('ano').sum().join(ESTADUAL.groupby(['ano']).sum()[['sentcrim', 'tcriminal1º']])
ESTADUAL_C['pcriminal'] = ESTADUAL_C['sentcrim'] / ESTADUAL_C['sent']
ESTADUAL_C.to_csv(r'H:\Notas Conceituais\SegPub-Drogas\Dados\Tribunais\CNJ2003-2016.csv', sep=";", decimal=",")

# Federal

TDF = pd.read_csv(PATH_2003_2008_federal, sep=";", decimal=",")
FEDERAL_C = TDF.append(FEDERAL[['ano', 'dpj', 'drh', 'magp', 'aux','jg']])
FEDERAL_C = FEDERAL_C.groupby('ano').sum().join(FEDERAL.groupby(['ano']).sum()[['sent','sentcrim', 'tcriminal1º']])
FEDERAL_C['pcriminal'] = FEDERAL_C['sentcrim'] / FEDERAL_C['sent']
FEDERAL_C.to_csv(r'H:\Notas Conceituais\SegPub-Drogas\Dados\Tribunais\CNJ2003-2016_FEDERAL.csv', sep=";", decimal=",")

####################################################
## 3. Estender série de magistrados e pessoal auxiliar #
####################################################

def estender_anos(inicio, final, df):
    df.index = [int(i) for i in df.index]
        
    for i in range(inicio,final):
        df.loc[i] = np.nan
    
    df.sort_index(axis=0, inplace=True)
    
def estender_serie_anos(serie, df, grau_polinomio=2):
    mask = np.isfinite(df.index) & np.isfinite(df[serie])

    polinomio = np.array([np.array(np.power(df.index[mask],i)) for i in range(1,grau_polinomio+1)])
    polinomio = sm.add_constant(polinomio.T)
       
    reg = sm.OLS(df[serie][mask], polinomio).fit()
    
    polifit = np.array([np.array(np.power(df.index,i)) for i in range(1,grau_polinomio+1)])
    polifit = sm.add_constant(polifit.T)
          
    return reg.predict(polifit)

def estender_serie(x, y, df, grau_polinomio=2):
    mask = np.isfinite(df[x]) & np.isfinite(df[y])

    polinomio = np.array([np.array(np.power(df[x][mask],i)) for i in range(1,grau_polinomio+1)])
    polinomio = sm.add_constant(polinomio.T)
       
    reg = sm.OLS(df[y][mask], polinomio).fit()
    
    polifit = np.array([np.array(np.power(df[x],i)) for i in range(1,grau_polinomio+1)])
    polifit = sm.add_constant(polifit.T)
          
    return reg.predict(polifit)
    
        
for frame in [ESTADUAL_C, FEDERAL_C]:
    estender_anos(1996, 2003, frame)
    frame['aux_hat'] = estender_serie_anos('aux', frame)
    frame['sent_hat'] = estender_serie('aux','sent', frame, grau_polinomio=1)
    
ESTADUAL_C.to_csv(r'H:\Notas Conceituais\SegPub-Drogas\Dados\Tribunais\CNJ1996-2016.csv', sep=";", decimal=",")
    