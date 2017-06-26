"""
PROJETO: "Identificação de Redundâncias no Setor Público com Modelos de Espaços Vetoriais e
Análises de Componentes Principais: o Caso Brasileiro"

EQUIPE DO PROJETO: Carlos Góes (SAE) e Eduardo Leoni (SAE).

AUTOR DESTE CÓDIGO: Carlos Góes, SAE/Presidência da República

OBJETIVO DESTE CÓDIGO: .

DATA: 16/06/2017
"""

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.mlab as mlab
from tabulate import tabulate

#####################################
# 1. Read Data 
#####################################

workdata = pd.read_json(path_or_buf="K://Notas Técnicas//Redundacias no Setor Publico//results//finaldata.json")

#####################################
# 2. Describe Variables
#####################################

wordsperbureau = workdata['wordsperbureau']
uniquewordsperbureau = workdata['uniquewordsperbureau'] 

#####################################
# 3. Chart: Histogram of Stems per Bureau
#####################################
 
lwordsperbureau = [np.log(item) for item in wordsperbureau]

# Plot histogram

fig, ax = plt.subplots()

# Grafica histograma das elasticidades
n, bins, patches = plt.hist(wordsperbureau,
                            bins=250,
                            normed=True,
                            facecolor='grey', 
                            alpha=0.75,
                            cumulative=True) 
       
#plt.axhline(0.5, color='black', label="50%", linestyle="dashed") 
#plt.axvline(70, color='black', label="Median",) 

# Formatação
ax.axis([0,500,0,1])
#ax.legend(loc='upper left')
plt.xlabel('Stems') 
plt.ylabel('Share of bureaus')  
plt.title('Cumulative Distribution: Stems per Bureau')
plt.show()
fig.savefig("K://Notas Técnicas//Redundacias no Setor Publico//imgs//stemsperbureau.pdf")
