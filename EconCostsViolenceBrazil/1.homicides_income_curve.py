# -*- coding: utf-8 -*-
"""
Created on Fri Dec 22 17:11:21 2017

@author: CarlosABG
"""

#################
# USER SETTINGS #
#################

# Pre-processing
DOWNLOAD_pyPNAD = False # Download pyPNAD extension?
IMPORTRAW = False # Import raw IBGE data

# Files path
PATH = "H:/Notas Conceituais/SegPub-Drogas/Dados/Pnad/PNADC_032017_20171117/"
CSVFILE = PATH + 'PNADC_032017.csv'

# Results
RESULTS_PATH = "H:/Notas Conceituais/SegPub-Drogas/Dados/results/"
RESULTS_FILE = RESULTS_PATH + "renda_hat.csv"

# Images
IMG_PATH = "H:/Notas Conceituais/SegPub-Drogas/Dados/img/"

###################
# PYTHON PACKAGES #
###################

# Import packages

import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt

###################
# PRE-PROCESSING #
###################

# Download pyPNAD

if DOWNLOAD_pyPNAD is True:
    import urllib.request
    urllib.request.urlretrieve("https://raw.githubusercontent.com/omercadopopular/cgoes/master/tinyapps/pyPNAD/pyPNAD.py",
                               "pyPNAD.py")

# Import pyPNAD, load PNAD Contínua data from raw text file and SAS dictionary

if IMPORTRAW is True:
    from pyPNAD import pyPNAD
      
    DATAFILE = PATH + 'PNADC_032017.txt'
    INPUTFILE = PATH + 'Input_PNADC_trimestral.txt'
    CSVFILE = PATH + 'PNADC_032017.csv'
    
    DF = pyPNAD.load(DATAFILE, INPUTFILE)
    
    DF.to_csv(CSVFILE)

###############
# IMPORT DATA #
###############

# Import from csv
    
DF = pd.read_csv(CSVFILE)

###################
# PREPARE DATASET #
###################

# Select variables 

VAR_LABELS = {
        # Identifiers
        'Ano': 'Ano',
        'Trimestre': 'Trimestre',
        'UF': 'UF',
        'Capital': 'Capital',
        'RM_RIDE': 'RM_RIDE',
        'UPA': 'UPA',
        'Estrato': 'Estrato',
        'V1008': 'Número de seleção do domicílio',
        
        # Demographics
        'V2007': 'Sexo',
                   # 1 == Male; 2 == Female
        'V2009': 'Idade do morador na data de referência',
        
        # Schooling
        'VD3001': 'Nível de instrução mais elevado alcançado (pessoas de 5 anos ou \
                   mais de idade)',
                   # 1 == less than 1 year; 2 == incomplete primary ed
                   # 3 == complete primary ed; 4 == incomplete secondary ed
                   # 5 == complete secondary ed; 6 == incomplete tertiary ed
                   # 7 == complete tertiary ed
        
        # Workforce participation and employment
        'VD4001': 'Condição em relação à força de trabalho na semana de referência \
                   para pessoas de 14 anos ou mais de idade',
                   # 1 == LABOR FORCE; 2 == OUTSIDE OF LABOR FORCE
        'VD4002': 'Condição de ocupação na semana de referência para pessoas de \
                   14 anos ou mais de idade',
                   # 1 == EMPLOYED; 2 == UNEMPLOYED
                   
        # Income
        'VD4016': 'Rendimento mensal habitual do trabalho principal para pessoas \
                   de 14 anos ou mais de idade (apenas para pessoas que receberam \
                   em dinheiro, produtos ou mercadorias em qualquer trabalho)',
        'VD4017': 'Rendimento mensal efetivo do trabalho principal para pessoas \
                   de 14 anos ou mais de idade (apenas para pessoas que receberam \
                   em dinheiro, produtos ou mercadorias em qualquer trabalho)',   
        'VD4019': 'Rendimento mensal habitual de todos os trabalhos para pessoas \
                   de 14 anos ou mais de idade (apenas para pessoas que receberam \
                   em dinheiro, produtos ou mercadorias em qualquer trabalho)',
        'VD4020': 'Rendimento mensal efetivo de todos os trabalhos para pessoas \
                   de 14 anos ou mais de idade (apenas para pessoas que receberam \
                   em dinheiro, produtos ou mercadorias em qualquer trabalho)'
            }

# Create work DataFrame
WORKDF = DF[list(VAR_LABELS.keys())]

#####################
# IMPOSE CONDITIONS #
#####################

WORKDF_CONDITIONS = {
        # Exclude those who are not in metro areas
        'ONLY_METRO': { 'AUTH': True, 'CONDITION': ~np.isnan(WORKDF['RM_RIDE']) },
        # Keep only males
        'ONLY_MALES': { 'AUTH': True, 'CONDITION': WORKDF['V2007'] == 1 },
        # Keep only those who didn't finish high-school
        'ONLY_LOW_SKILLED': { 'AUTH': True, 'CONDITION': WORKDF['VD3001'] <= 4 },
        # Exclude income outliers
        'EXCLUDE_OUTLIERS': { 'AUTH': True, 'CONDITION': WORKDF['VD4016'] < 20000 },
        # Exclude zero income
        'EXCLUDE_ZERO_INCOME': { 'AUTH': True, 'CONDITION': WORKDF['VD4016'] > 0 },
        # Exclude zero income
        'SET_AGES': { 'AUTH': True, 'CONDITION': (WORKDF['V2009'] >= 13) & (WORKDF['V2009'] <= 90) }
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

# Create Youth DataFrane
YOUTHDF = WORKDF[ (WORKDF['V2009'] >= 16) & (WORKDF['V2009'] <= 24) ]   

##########
# CHARTS #
##########

## Scatterplot age vs income

POLY_ORDER = 2

SCATTER_AGE_INCOME = plt.figure()
ax = SCATTER_AGE_INCOME.add_axes([0,0,1,1])

REGPLOT = sns.regplot('V2009','VD4016', data=WORKDF, order=POLY_ORDER,
            scatter_kws={'alpha': 0.1, 'color': 'grey'},
            line_kws={'color': 'black'}, x_bins=90-13, label='Amostra considerada')

ax.set(ylabel='Rendimento mensal', xlabel='Idade', ylim=[0,2000])
plt.show()
SCATTER_AGE_INCOME.savefig(IMG_PATH + 'SCATTER_AGE_INCOME.png')

## Distribution of overall income and youth income

DIST_INCOME = plt.figure()
sns.distplot(np.log(WORKDF['VD4016']), hist=False, label='População Geral')
sns.distplot(np.log(YOUTHDF['VD4016']), hist=False, label='Jovens', axlabel='Log Natural da Renda do Trabalho Habitual')
plt.show()
DIST_INCOME.savefig(IMG_PATH + 'DIST_INCOME.png')

################
# LINEAR MODEL #
################

MODELO = np.polyfit(WORKDF['V2009'], WORKDF['VD4016'], POLY_ORDER)
FITTED = np.poly1d(MODELO)

IDADES = np.linspace(13,90, 90-13+1).astype(int)
RENDA_HAT = {}
for idade in IDADES:
    renda = FITTED(idade)
    RENDA_HAT.update({idade: renda * 13})
    
RENDA_MODELO = {idade: MODELO for idade in IDADES}

results = pd.DataFrame(data={'renda_hat': RENDA_HAT, 'renda_modelo': RENDA_MODELO})
results.to_csv(RESULTS_FILE) 