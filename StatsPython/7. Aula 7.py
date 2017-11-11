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

         
