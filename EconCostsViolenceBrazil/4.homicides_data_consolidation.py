# -*- coding: utf-8 -*-
"""
Created on Wed Jan 10 15:38:37 2018

@author: CarlosABG
"""

#################
# USER SETTINGS #
#################

SUS_PATH = "H:/Notas Conceituais/SegPub-Drogas/Dados/Datasus/Arq_936829632/"

NPV_PATH = "H:/Notas Conceituais/SegPub-Drogas/Dados/results/"
NPV_FILE = NPV_PATH + "npv.csv"

RESULTS_PATH = "H:/Notas Conceituais/SegPub-Drogas/Dados/results/"

###################
# PYTHON PACKAGES #
###################

# Import packages

import pandas as pd
import numpy as np
from os import listdir
from os.path import isfile, join

##################
# GET FILES LIST #
##################


files = [f for f in listdir(SUS_PATH) \
         if (isfile(join(SUS_PATH, f))) and (join(SUS_PATH, f)[-4:] == '.csv')]

#####################
# CREATE DATAFRAMES #
#####################

# COMPLETE
SUSDF = pd.DataFrame()

# STATES
UFDF = pd.DataFrame()

# MUNICIPALITIES
MUNDF = pd.DataFrame()

########################
# ITERATE OVER FILES   # 
# TO CREATE DATAFRAMES #
########################

for file in files:
    WORK_FILE = SUS_PATH + file
    
    #####################
    # IMPORT DATAFRAMES #
    #####################
    
    try:
        DF = pd.read_csv(WORK_FILE, low_memory=False, sep=",", na_values="NA")
    except:
        DF = pd.read_csv(WORK_FILE, low_memory=False, sep=",", na_values="NA", encoding="latin-1")
    
    WORKDF = DF.copy()
    
    print("Processando: {}...".format(file))
    
    #####################
    # IMPOSE CONDITIONS #
    #####################
    
    WORKDF_CONDITIONS = {
            'ONLY_HOMICIDES': { 'AUTH': True, 'CONDITION': WORKDF['CIRCOBITO'] == 3 },
            'AGE_RESTRICTION': { 'AUTH': True, 'CONDITION': (WORKDF['IDADE'] > 400)
                                                            & (WORKDF['IDADE'] < 500) }
            }
    
    WORKDF['bool_vec'] = [True for i in range(len(WORKDF))]
    for CONDITION in WORKDF_CONDITIONS.keys():
        if WORKDF_CONDITIONS[CONDITION]['AUTH'] is False:
            continue 
        else:
            WORKDF['bool_vec'] = (WORKDF['bool_vec'] & WORKDF_CONDITIONS[CONDITION]['CONDITION'])
            print(CONDITION, sum(WORKDF['bool_vec']))
    
    WORKDF = (WORKDF[ WORKDF['bool_vec'] ]
              .drop('bool_vec', axis=1)
              .reset_index(drop=False)
              )
    
    WORKDF['IDADE'] = WORKDF['IDADE'] - 400
    WORKDF['ANO'] = np.mean([int(str(item)[-4:]) for item in WORKDF['DTOBITO']]).astype(int)
    WORKDF['NEGRO'] = ((WORKDF['RACACOR'] == 2) | (WORKDF['RACACOR'] == 4))
    WORKDF['RACA_CONSTA'] = (~np.isnan(WORKDF['RACACOR']))
    WORKDF['HOMEM'] = (WORKDF['SEXO'] == 1)
    WORKDF['SEXO_CONSTA'] = (WORKDF['SEXO'] != 0)
       
    #################
    # SUS DATAFRAME #
    #################
    
    NPVDF = pd.read_csv(NPV_FILE)
    
    COUNTDF = pd.DataFrame()
    COUNTDF['homicidios'] = WORKDF.groupby('IDADE')['CIRCOBITO'].describe()['count'].astype(int)
    COUNTDF['homicidios_negros'] = WORKDF.groupby('IDADE').sum()['NEGRO'].astype(int)
    COUNTDF['homicidios_raca_consta'] = WORKDF.groupby('IDADE').sum()['RACA_CONSTA'].astype(int)
    COUNTDF['homicidios_homens'] = WORKDF.groupby('IDADE').sum()['HOMEM'].astype(int)
    COUNTDF['homicidios_sexo_consta'] = WORKDF.groupby('IDADE').sum()['SEXO_CONSTA'].astype(int)
    COUNTDF['ano'] = int(np.mean(WORKDF['ANO']))
    COUNTDF = NPVDF.join(COUNTDF, how='left', on='idade')
    COUNTDF['custos_idade'] = COUNTDF['NPV'] * COUNTDF['homicidios']
    COUNTDF['custos_total'] = np.sum(COUNTDF['custos_idade'])
    
    SUSDF = SUSDF.append(COUNTDF[['idade', 'NPV', 'homicidios', 'homicidios_negros',
                                  'homicidios_raca_consta', 'homicidios_homens',  'homicidios_sexo_consta',
                                  'ano', 'custos_idade', 'custos_total']])

    #######################
    # MUNICIPAL DATAFRAME #
    #######################
    
    CODIGO_MUN = 'CODMUNRES'
    
    COUNTDF = pd.DataFrame()
    COUNTDF['homicidios'] = WORKDF.groupby(CODIGO_MUN)['CIRCOBITO'].describe()['count'].astype(int)
    COUNTDF['ano'] = int(np.mean(WORKDF['ANO']))
    COUNTDF['idade_media'] = WORKDF.groupby(CODIGO_MUN).mean()['IDADE']
    COUNTDF['negro_proporcao'] = WORKDF.groupby(CODIGO_MUN).sum()['NEGRO'].astype(int) / WORKDF.groupby(CODIGO_MUN).sum()['RACA_CONSTA'].astype(int)
    
    MUNDF = MUNDF.append(COUNTDF[['ano', 'homicidios', 'idade_media',
                                  'negro_proporcao']])

    #######################
    # STATE DATAFRAME #
    #######################
    
    WORKDF['UF'] = [int(str(item)[0:2]) for item in WORKDF[CODIGO_MUN]]
    
    COUNTDF = pd.DataFrame()
    COUNTDF['homicidios'] = WORKDF.groupby('UF')['CIRCOBITO'].describe()['count'].astype(int)
    COUNTDF['ano'] = int(np.mean(WORKDF['ANO']))
    COUNTDF['idade_media'] = WORKDF.groupby('UF').mean()['IDADE']
    COUNTDF['negro_proporcao'] = WORKDF.groupby('UF').sum()['NEGRO'].astype(int) / WORKDF.groupby('UF').sum()['RACA_CONSTA'].astype(int)
    
    UFDF = UFDF.append(COUNTDF[['ano', 'homicidios', 'idade_media',
                                  'negro_proporcao']])
    
SUSDF = SUSDF.sort_values(['ano','idade'])
MUNDF = MUNDF.reset_index(drop=False).sort_values(['ano',CODIGO_MUN])
UFDF = UFDF.reset_index(drop=False).sort_values(['ano','UF'])

SUSDF.to_csv(RESULTS_PATH + 'susdf.csv', sep=';', decimal=',')
MUNDF.to_csv(RESULTS_PATH + 'mundf.csv', sep=';', decimal=',')
UFDF.to_csv(RESULTS_PATH + 'ufdf.csv', sep=';', decimal=',')
