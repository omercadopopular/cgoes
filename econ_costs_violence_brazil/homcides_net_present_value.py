# -*- coding: utf-8 -*-
"""
Created on Wed Dec 27 17:11:50 2017

@author: CarlosABG
"""

#################
# USER SETTINGS #
#################

PATH = "H:/Notas Conceituais/SegPub-Drogas/Dados/results/"
RENDA_FILE = PATH + "renda_hat.csv"
PARTICIPACAO_FILE = PATH + "participacao_hat.csv"

###################
# PYTHON PACKAGES #
###################

# Import packages

import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt

#####################
# IMPORT DATAFRAMES #
#####################

WORKDF = (pd.merge(pd.read_csv(RENDA_FILE), pd.read_csv(PARTICIPACAO_FILE))
        .rename(columns={'Unnamed: 0': 'idade'})
        .set_index('idade'))

WORKDF['renda_ajustado'] = WORKDF['renda_hat'] * WORKDF['participacao_hat']

###################
# CUSTOM FORMULAS #
###################

##############
# YEARLY NPV #
##############


def present_value_year(idade_inicial, idade_horizonte,
                       renda_idade, participacao_idade,
                       tx_cresc, tx_desc):
    k = idade_horizonte - idade_inicial
    beta = ( ( 1 + tx_cresc ) / ( 1 + tx_desc ) ) ** k
    renda_ajustado = participacao_idade * renda_idade
    renda_descontado = beta * renda_ajustado
    return renda_descontado

#############
# TOTAL NPV #
#############

def total_present_value(idade_inicial, expectativa_vida,
                        renda_var, participacao_var,
                        dataframe, tx_cresc=0.02, tx_desc=0.03):
    
    total_valor_desc = []
    for idade_horizonte in range(idade_inicial, expectativa_vida+1):
        valor_desc = present_value_year(idade_inicial, idade_horizonte,
                                        dataframe.loc[idade_horizonte, renda_var],
                                        dataframe.loc[idade_horizonte, participacao_var],
                                        tx_cresc, tx_desc)
        total_valor_desc.append(valor_desc)
        
    return sum(total_valor_desc)

#################################
# TOTAL NPV CONFIDENCE INTERVAL #
#################################

def pv_confidence_interval(idade_inicial, expectativa_vida,
                           renda_var, participacao_var,
                           dataframe,
                           tx_cresc_media=0.02, tx_cresc_sigma=0.01,
                           tx_desc_media=0.03, tx_desc_sigma=0.01,
                           n_iter=10000):
    
    pv_dist = []
    
    counter = 0
    while counter <= n_iter:
        tx_cresc = np.random.normal(tx_cresc_media, tx_cresc_sigma)
        tx_desc = np.random.normal(tx_desc_media, tx_desc_sigma)
        pv = total_present_value(idade_inicial, expectativa_vida,
                                renda_var, participacao_var,
                                dataframe, tx_cresc, tx_desc)
        pv_dist.append(pv)
        counter += 1 
        
    return np.mean(pv_dist), np.median(pv_dist), np.std(pv_dist), pv_dist

###############
# NPV PER AGE #
###############
    
EXP_VIDA = 75

WORKDF['NPV'] = [total_present_value(int(idade), EXP_VIDA,
                                   'renda_hat', 'participacao_hat', WORKDF) \
                for idade in WORKDF.index]

## Chart

fig, ax = plt.subplots()

plt.plot(WORKDF.index, WORKDF['NPV'])
plt.axhline(0,color='black')

ax.set_title('Valor Presente da Perda de Capacidade Produtiva de Homicídios, por idade da vítima')        
ax.set_ylabel('Valor Presente da Perda de Capacidade Produtiva de Homicídios')        
ax.set_xlabel('Idade da Vítima')        
plt.show()

#############
# NPV AT 18 #
#############

media, mediana, ep, dist = pv_confidence_interval(18, EXP_VIDA,
                                                  'renda_hat',
                                                  'participacao_hat',
                                                  WORKDF)

DISTPLOT = sns.distplot(dist)



