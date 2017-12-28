# -*- coding: utf-8 -*-
"""
Created on Wed Dec 27 17:11:50 2017

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
import seaborn as sns
import matplotlib.pyplot as plt
from os import listdir
from os.path import isfile, join

##################
# GET FILES LIST #
##################


files = [f for f in listdir(SUS_PATH) \
         if (isfile(join(SUS_PATH, f))) and (join(SUS_PATH, f)[-4:] == '.csv')]

SUSDF = pd.DataFrame()
for file in files:
    WORK_FILE = SUS_PATH + file
    
    #####################
    # IMPORT DATAFRAMES #
    #####################
    
    DF = pd.read_csv(WORK_FILE, low_memory=False, sep=",", na_values="NA")
    
    WORKDF = DF.copy()
    
    #####################
    # IMPOSE CONDITIONS #
    #####################
    
    WORKDF_CONDITIONS = {
            'ONLY_HOMICIDES': { 'AUTH': True, 'CONDITION': WORKDF['CIRCOBITO'] == 3 },
            'AGE_RESTRICTION': { 'AUTH': True, 'CONDITION': (WORKDF['IDADE'] > 400) & (WORKDF['IDADE'] < 500) }
            }
    
    WORKDF['bool_vec'] = [True for i in range(len(WORKDF))]
    for CONDITION in WORKDF_CONDITIONS.keys():
        if WORKDF_CONDITIONS[CONDITION]['AUTH'] is False:
            continue 
        else:
            WORKDF['bool_vec'] = (WORKDF['bool_vec'] & WORKDF_CONDITIONS[CONDITION]['CONDITION'])
            print(CONDITION, sum(WORKDF['bool_vec']))
    
    WORKDF = WORKDF[ WORKDF['bool_vec'] ]
    WORKDF = WORKDF.drop('bool_vec', axis=1)
    
    WORKDF['IDADE'] = WORKDF['IDADE'] - 400
    WORKDF['ANO'] = np.mean([int(str(item)[-4:]) for item in WORKDF['DTOBITO']]).astype(int)
    
    ##########
    # CHARTS #
    ##########
    
    sns.distplot(WORKDF['IDADE'], hist=False, label=file)
    
    #############
    # DATAFRAME #
    #############
    
    NPVDF = pd.read_csv(NPV_FILE)
    
    COUNTDF = pd.DataFrame()
    COUNTDF['homicidios'] = WORKDF.groupby('IDADE')['CIRCOBITO'].describe()['count'].astype(int)
    COUNTDF['ano'] = int(np.mean(WORKDF['ANO']))
    COUNTDF = NPVDF.join(COUNTDF, how='left', on='idade')
    COUNTDF['custos_idade'] = COUNTDF['NPV'] * COUNTDF['homicidios']
    COUNTDF['custos_total'] = np.sum(COUNTDF['custos_idade'])
    
    SUSDF = SUSDF.append(COUNTDF[['idade', 'NPV', 'homicidios', 'ano',
       'custos_idade', 'custos_total']])

plt.legend(loc='upper right')
plt.show()

CUSTOS_ANO = SUSDF.groupby('ano').mean()['custos_total']