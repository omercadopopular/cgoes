# -*- coding: utf-8 -*-
"""
Created on Wed Dec 27 17:11:50 2017

@author: CarlosABG
"""

#################
# USER SETTINGS #
#################

RESULTS_PATH = "H:/Notas Conceituais/SegPub-Drogas/Dados/results/"

SUS_PATH = RESULTS_PATH + 'susdf.csv'

IMG_PATH = "H:/Notas Conceituais/SegPub-Drogas/Dados/img/"

###################
# PYTHON PACKAGES #
###################

# Import packages

import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt

#####################
# CREATE DATAFRAMES #
#####################

SUSDF = pd.read_csv(SUS_PATH, sep=";", decimal=",")

####################
# AGE DISTRIBUTION #
####################

AGEDF = SUSDF.groupby('idade').sum().reset_index(drop=False)

FIG, AX = plt.subplots()

plt.plot('idade','homicidios', data=AGEDF)
AX.set_xlabel('Idade')
AX.set_ylabel('Número de homicídios')
plt.show()

FIG.savefig(IMG_PATH + 'age_dist.png')

####################
# RACE DISTRIBUTION #
####################


####################
# COSTS PER YEAR #
####################

CUSTOS_ANO = pd.DataFrame(data=SUSDF.groupby('ano').mean()['custos_total'])

presente = 2016

tx_cresc = {
1996: 0.0214835122321382 ,
1997: 0.0208417998905412 ,
1998: 0.0219922664113175 ,
1999: 0.0231481534206399 ,
2000: 0.0219162455581923 ,
2001: 0.0225046172927006 ,
2002: 0.0222140714554804 ,
2003: 0.0230455460244481 ,
2004: 0.020255846494261 ,
2005: 0.0192310595331471 ,
2006: 0.0172191468082552 ,
2007: 0.0124766220479076 ,
2008: 0.00767578159857663 ,
2009: 0.00925319164787286 ,
2010: -0.00135899025883102 ,
2011: -0.00699954724389029 ,
2012: -0.0112804825529736 ,
2013: -0.0230637828617715 ,
2014: -0.0368004204735137 ,
2015: -0.0359 ,
2016: 0 
        }

tx_desc = 0.03

vec = []
for ano in list(CUSTOS_ANO.index):
    k = ano - presente
    beta = ((1 + tx_cresc[ano])/(1 + tx_desc)) ** k 
    adj = CUSTOS_ANO.loc[ano, 'custos_total'] * beta
    vec.append(adj)
    
CUSTOS_ANO['custo_adj'] = vec

CUSTOS_ANO = CUSTOS_ANO.join(SUSDF.groupby('ano').sum()[['homicidios', 'homicidios_negros',
                                  'homicidios_raca_consta', 'homicidios_homens', 'homicidios_sexo_consta']])

CUSTOS_ANO.to_csv(RESULTS_PATH + 'custos_results.csv', sep=";", decimal=",")

