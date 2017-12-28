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
PATH = "H:/Notas Conceituais/SegPub-Drogas/Dados/Pnad/PNADC_032012_20171117/"
CSVFILE = PATH + 'PNADC_032012.csv'

# Results
RESULTS_PATH = "H:/Notas Conceituais/SegPub-Drogas/Dados/results/"
RESULTS_FILE = RESULTS_PATH + "participacao_hat.csv"

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
      
    DATAFILE = PATH + 'PNADC_032012.txt'
    INPUTFILE = PATH + 'Input_PNADC_trimestral.txt'
    CSVFILE = PATH + 'PNADC_032012.csv'
    
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
        'EXCLUDE_OUTLIERS': { 'AUTH': False, 'CONDITION': WORKDF['VD4016'] < 20000 },
        # Exclude zero income
        'EXCLUDE_ZERO_INCOME': { 'AUTH': False, 'CONDITION': WORKDF['VD4016'] > 0 },
        # Exclude zero income
        'SET_AGES': { 'AUTH': True, 'CONDITION': (WORKDF['V2009'] >= 16) & (WORKDF['V2009'] <= 80) }
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

# Create Dummy for Employment

WORKDF['empregado'] = [(item == 1) for item in WORKDF['VD4002']]

##########
# CHARTS #
##########

POLY_ORDER = 3

SCATTER_AGE_EMPLOYMENT = sns.regplot('V2009','empregado', data=WORKDF, order=POLY_ORDER,
                     scatter_kws={'alpha': 0.1, 'color': 'grey'},
                     line_kws={'color': 'black'}, x_bins=80-16, label='Amostra considerada')
SCATTER_AGE_EMPLOYMENT.set(ylabel='Portentagem empregados', xlabel='Idade', ylim=[0,1])
plt.show()

################
# LINEAR MODEL #
################

MODELO = np.polyfit(WORKDF['V2009'], WORKDF['empregado'], POLY_ORDER)
FITTED = np.poly1d(MODELO)

IDADES = np.linspace(16,80, 80-16+1)
PARTICIPACAO_HAT = {}
for idade in IDADES:
    PARTICIPACAO_HAT.update({idade: FITTED(idade)})

PARTICIPACAO_MODELO = {idade: MODELO for idade in IDADES}

results = pd.DataFrame(data={'participacao_hat': PARTICIPACAO_HAT, 'participacao_modelo': PARTICIPACAO_MODELO})
results.to_csv(RESULTS_FILE) 
