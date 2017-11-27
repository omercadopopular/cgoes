# -*- coding: utf-8 -*-
"""
Created on Mon Nov 27 20:41:59 2017

@author: CarlosABG
"""

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import statsmodels.formula.api as smf

### Simulação

x = np.linspace(0,100,100)

# y = função de x mais um erro aleatório.
y = x * 10 + np.random.normal(0,50,len(x))

## Plotar correlação

fig1 = plt.figure()
plt.scatter(x,y)
plt.show()

## Retas possíveis

#linear = lambda constante, parametro, x: constante + parametro * x

y_1 = x * 5 + 200
y_2 = x * 8 + 100
y_3 = x * 12 - 100
y_4 = x * 15 - 200
y_5 = x * 10

fig2 = plt.figure()
plt.scatter(x,y)
plt.plot(x, y_1, color='black', linewidth=0.75)
plt.plot(x, y_2, color='black', linewidth=0.75)
plt.plot(x, y_3, color='black', linewidth=0.75)
plt.plot(x, y_4, color='black', linewidth=0.75)
plt.plot(x, y_5, color='black', linewidth=0.75)
plt.show()

### Dataset

file = 'https://github.com/omercadopopular/cgoes/blob/master/StatsPython/data/wooldridge/airfare.dta?raw=true'
df = pd.read_stata(file)

df = df.drop(['ldist', 'y98', 'y99', 'y00', 'lfare',
             'ldistsq', 'concen', 'lpassen'], axis=1)

df = df.rename(columns = {'fare':'preco'})

plt.scatter('dist', 'preco',
           data=df, alpha=0.25)
plt.xlabel('Distância (milhas)')
plt.ylabel('Preço (dólares)')
plt.title('Passagens aéreas: relação entre distância e preço')
plt.show()


