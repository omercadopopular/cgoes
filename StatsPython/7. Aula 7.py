# -*- coding: utf-8 -*-
"""
Created on Thu Oct 26 16:56:57 2017

@author: CarlosABG
"""

## Dados, n = 100

import numpy as np
import random
import matplotlib.pyplot as plt
from scipy import stats

amostra_dados = lambda tamanho: [random.randint(1,6) for i in range(0,tamanho)]

tamanho, n_amostras = 100, 1000

medias = sorted([np.mean(amostra_dados(tamanho)) for i in range(0,n_amostras)])
pdf = list(stats.norm.pdf(medias, loc=np.mean(medias), scale=np.std(medias)))

plt.hist(medias, bins=50,
         color='brown', 
         label='histograma',
         normed=True)

plt.plot(medias, pdf,
         color='black',
         linewidth=2,
         label='função de densidade')

plt.legend(loc="upper left")
plt.xlabel('Valores') 
plt.ylabel('Probabilidade de cada valor')  
plt.axis([3, 4, 0, 10])  # set range of axes
plt.title(r'Distribuição das médias de diferentes amostras ($n={}$)'.format(tamanho))
plt.show()  # plot chart

##################

## Dados, n = 1000

amostra_dados = lambda tamanho: [random.randint(1,6) for i in range(0,tamanho)]

tamanho, n_amostras = 1000, 1000

medias = sorted([np.mean(amostra_dados(tamanho)) for i in range(0,n_amostras)])
pdf = list(stats.norm.pdf(medias, loc=np.mean(medias), scale=np.std(medias)))

plt.hist(medias, bins=50,
         color='brown', 
         label='histograma',
         normed=True)

plt.plot(medias, pdf,
         color='black',
         linewidth=2,
         label='função de densidade')

plt.legend(loc="upper left")
plt.xlabel('Valores') 
plt.ylabel('Probabilidade de cada valor')  
plt.axis([3, 4, 0, 10])  # set range of axes
plt.title(r'Distribuição das médias de diferentes amostras ($n={}$)'.format(tamanho))
plt.show()  # plot chart

##################

## Barras

mu, sigma, = 0, 10, 
n_amostras, amostra_tam, pop_tam = 10, 500, 100
erros_padrao = 2
        
pop = np.random.normal(mu, sigma, pop_tam)
        
amostra = np.matrix([[0 for x in range(n_amostras)] 
for y in range(amostra_tam)])
        
erros, medias = [], []
for i in range(n_amostras):
    s = np.random.choice(pop, size=amostra_tam)
    amostra[:,i] = np.transpose(np.matrix(s))
    media = s.mean()
    medias.append(media)
    erro = erros_padrao * (np.std(s) / np.sqrt(amostra_tam))
    erros.append(erro)
    print("Amostra " + str(i+1) + ", média: {:0.2f}; erro-padrão: {:0.2f}".format(media, erro) )
    
barras = plt.figure()
        
plt.bar(range(n_amostras), medias, color='red', label='Médias estimadas', yerr=erros)
        
plt.legend(loc=1)
plt.xlabel('Amostra') 
plt.ylabel('Média estimadas')  
plt.title('Médias de diferentes amostras')
        
plt.show()

##################

## student-t (rever)

amostra_dados = lambda tamanho: [random.randint(1,6) for i in range(0,tamanho)]

x1 = 30

n_medias = 1000

m1 = sorted([np.mean(amostra_dados(x1)) for i in range(0,1000)])
pdf1 = list(stats.t.pdf(m1, df=(x1-1), loc=np.mean(m1), scale=np.std(m1)))

pdf = list(stats.norm.pdf(m1, loc=np.mean(m1), scale=np.std(m1)))

plt.plot(m1, pdf,
         color='black',
         linewidth=2,
         label='normal')

plt.plot(m1, pdf1,
         color='grey',
         linewidth=1,
         label='student-t')

plt.legend(loc="upper left")
plt.xlabel('Valores') 
plt.ylabel('Probabilidade de cada valor')  
plt.title(r'Distribuição das médias de diferentes amostras $n={}$'.format(x1))
plt.show()  # plot chart

          
##################
            

import pandas as pd

dfiq = pd.read_excel('https://github.com/omercadopopular/cgoes/blob/master/StatsPython/data/brain_size.xlsx?raw=true')

print(dfiq)

dfiq = pd.read_excel('https://github.com/omercadopopular/cgoes/blob/master/StatsPython/data/brain_size.xlsx?raw=true',
                     na_values=".")


dfiq.columns = ['sexo', 'FSIQ', 'VIQ', 'PIQ', 'peso', 'altura', 'MRI_Count']

lb_para_kg = lambda x: x / 2.2
in_para_cm = lambda x: x * 2.54

dfiq['peso'] = [lb_para_kg(pes) for pes in dfiq['peso']]
dfiq['altura'] = [in_para_cm(alt) for alt in dfiq['altura']]
dfiq['sexo'] = [string.replace("Female", "Feminino").replace("Male", "Masculino") for string in dfiq['sexo']]

grupos = dfiq.groupby('sexo')

print(grupos.mean(), grupos.median())

print(grupos.describe().T)

grupos.boxplot(column=['peso'])

diff = grupos['peso'].mean()['Masculino'] - grupos['peso'].mean()['Feminino']

erro_padrao = ( (grupos['peso'].std()['Masculino'] / (grupos['peso'].count()['Masculino']) ** (1/2)) + 
                (grupos['peso'].std()['Feminino'] / (grupos['peso'].count()['Feminino']) ** (1/2)) )

t_stat = diff / erro_padrao


count = np.mean(grupos['peso'].count())

p_value = stats.t.pdf(t_stat, df=(count - 1) )

print("Diferença: {:.2f}".format(diff))
print("Estatística-t: {:.2f}".format(t_stat))
print("p-value: {:.2f}".format(p_value))
