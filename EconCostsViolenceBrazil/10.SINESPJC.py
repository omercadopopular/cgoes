# -*- coding: utf-8 -*-
"""
Created on Fri Jan 26 12:30:37 2018

@author: CarlosABG
"""

import os
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import re

# Buscar todos os arquivos de determinado diretório
PATH = 'H:\\Notas Conceituais\\SegPub-Drogas\\Dados\\SINESPJC\\'

FILES = []
for root, dirs, files in os.walk(PATH, topdown=False):
    for name in files:
        if name[-4:] == '.csv':
            FILES.append(os.path.join(root, name))

ESTADOS_EXPORT, UNIAO_EXPORT = pd.DataFrame(), pd.DataFrame()

FILES = [re.match(".*(brasil).*", file).group(0) for file in FILES
         if re.match(".*(brasil).*", file) is not None]
for file in FILES:
    DF = pd.read_csv(file, sep=';', decimal=',', encoding='latin1',
                     skiprows=4, parse_dates=True)
    
    ANO = int(file.split('brasil')[1][0:4])
    DF['Ano'] = [ANO for i in range(len(DF))]
    
    DF['PC-Qtde Ocorrências'] = [int(item.replace('.','')) for item in DF['PC-Qtde Ocorrências']]
       
    ESTADOS = DF.groupby(['UF','Tipo Crime']).agg( {
            'Ano': np.mean,
            'PC-Qtde Ocorrências': np.sum
            })
        
    UNIAO = DF.groupby('Tipo Crime').agg( {
            'Ano': np.mean,
            'PC-Qtde Ocorrências': np.sum
            })
    
    ESTADOS_EXPORT = ESTADOS_EXPORT.append(ESTADOS)
    UNIAO_EXPORT = UNIAO_EXPORT.append(UNIAO)

UNIAO_EXPORT = UNIAO_EXPORT.reset_index(drop=False).sort_values(['Tipo Crime','Ano'])
UNIAO_EXPORT.to_csv('H:\\Notas Conceituais\\SegPub-Drogas\\Dados\\SINESPJC\\CRIMES.csv', sep=";", decimal=",")


######### Gráfico

# USER SETTINGS

LEFT = 2004
RIGHT = 2015
BOTTOM = -1
TOP = 302

TITLE = "Brasil: Ocorrências de Crimes no Brasil, 2004-2015"
SUBTITLE = "Em milhares de ocorrências, por tipo"

X_LABEL = "Ano"
Y_LABEL = "Milhares de ocorrências"

SOURCE = 'Sistema Nacional de Estatísticas de Segurança Pública e Justiça Criminal, MJ.'

# PARAMETERS

SCALE = (RIGHT - LEFT)/10

# CODE

plt.style.use('fivethirtyeight')

# Declare figure
fig, ax = plt.subplots(figsize=(12,7))

# Plot histogram
for key, grp in UNIAO_EXPORT.groupby('Tipo Crime'): 
    plt.plot(grp['Ano'], grp['PC-Qtde Ocorrências']/1000, label='{}'.format(key))
plt.legend(loc='best')    
# Configure axes
ax.yaxis.grid(which="major", color='grey', linewidth=3)
ax.xaxis.grid(which="major", linewidth=0)
ax.tick_params(axis='both', which='major', labelsize=15)
ax.set_xlim(left = LEFT, right = RIGHT)
ax.set_ylim(bottom = BOTTOM, top = TOP)

# Set line at zero
plt.axvline(0, color='grey', linewidth=3)
plt.axhline(0, color='grey', linewidth=3)

# Set titles
ax.text(x = LEFT-SCALE, y = TOP+SCALE*30, s = TITLE,
               fontsize = 26, weight = 'bold')
ax.text(x = LEFT-SCALE, y = TOP+SCALE*15, 
               s = SUBTITLE,
              fontsize = 19)

# Set axis labels
ax.set_xlabel(X_LABEL, fontsize=19)
ax.set_ylabel(Y_LABEL, fontsize=19)

# Set source:

ax.text(x =  LEFT-SCALE, y = BOTTOM-SCALE*40,
    s = 'Fonte: ' + SOURCE,
    fontsize = 14)

"""
# Set label below
ax.text(x = LEFT-SCALE, y = BOTTOM-SCALE*55,
    s = 'Instituto Mercado Popular' + ' '*105 + 'www.mercadopopular.org',
    fontsize = 14, color = '#f0f0f0', backgroundcolor = 'grey')
"""
plt.show()

    