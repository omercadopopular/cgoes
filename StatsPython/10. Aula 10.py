# -*- coding: utf-8 -*-
"""
Created on Wed Oct 18 07:03:57 2017

@author: CarlosABG
"""

import numpy as np
from scipy.misc import derivative
import matplotlib.pyplot as plt

#################
## Criar dados ##
#################

# Sequência de x
x = np.linspace(0,100,100)

# y = função de x mais um erro aleatório.
y = x * 10 + np.random.normal(0,50,len(x))

## Plotar correlação

fig1 = plt.figure()
plt.scatter(x,y)

#######################
## Mínimos quadrados ##
#######################

## Cálculo da soma dos quadrados dos resíduos

def sum_sq_resid(beta, x, y, scale=1/10000):
    vec = [(y_i - beta * x_i) ** 2 for (y_i, x_i) in zip(y,x)]
    return scale * sum(vec)

## Estimação da soma dos quadrados dos resíduos com parâmetros diferentes

sample = range(-50,50)

results = []
for i in sample:
    results.append(sum_sq_resid(i, x, y))

# Plotar função    
fig2 = plt.figure()
plt.plot(sample, results)
plt.axhline(np.min(results), color='black')
plt.title('Soma dos quadrados dos resíduos com parâmetros diferentes')
plt.xlabel(r'Parâmetro ($\beta$)')
plt.ylabel('Soma do quadrado dos resíduos')
plt.show()

##############################
## Algoritmo de minimização ##
##############################

## Definir algoritmo
def minimize(x, y, alpha=0.001, num_inters=250):
    beta = 0
    f = lambda beta: sum_sq_resid(beta, x, y)
    
    path = []    
    betas = []
    for i in range(0,num_inters):
        beta = beta - alpha * derivative(f, x0=beta, dx=1e-10)
        betas.append(beta)
        path.append(sum_sq_resid(beta, x, y))
        
    return(beta, betas, path)
    
# Rodar função   
beta_algoritmo, betas, path = minimize(x,y)

# Imprimir beta
print(beta_algoritmo)

# Plotar convergência
f, ax = plt.subplots(1,2)
ax[0].plot(betas)
ax[0].set_title(r'$\beta$')
ax[0].set_xlabel('Iterações')
ax[1].plot(path)
ax[1].set_title('Soma dos Quadrados')
ax[1].set_xlabel('Iterações')

# Statsmodels

import statsmodels.formula.api as smf
import pandas as pd

df = pd.DataFrame({'x': x, 'y': y})

reg_sem_constante = smf.ols('y ~ x - 1', data=df).fit()

print(reg_sem_constante.summary())

# Gif da convergência
save_path = r'C:\Users\CarlosABG\Documents\IESB\otimizacao\figs'

filenames = []

for i in np.linspace(0,99,100, dtype=int):
    fig3 = plt.figure()
    plt.plot(sample, results)
    plt.plot(betas[i],path[i], 'ro')
    plt.axis([0,15,0,2000])
    plt.axhline(np.min(results), color='black')
    plt.title('Soma dos quadrados dos resíduos com parâmetros diferentes')
    plt.xlabel(r'Parâmetro ($\beta$)')
    plt.ylabel('Soma do quadrado dos resíduos')
    plt.savefig(save_path + '\\fig{}.png'.format(i))
    plt.close()
    filenames.append(save_path + '\\fig{}.png'.format(i))

# Vai tentar fazer o gif. Se der erro, vai continuar o programa.
gif = True
if gif == True:
    try:
        import imageio
        images = []
        for filename in filenames:
            images.append(imageio.imread(filename))
        imageio.mimsave(save_path + '\\movie.gif', images)
    except:
     pass


##################################
## Solução numérica por cálculo ##
##################################

def regressao(x, y):
    beta = (np.cov(x,y, ddof=1) / np.var(x, ddof=1))[0,1]
    alpha = np.mean(y) - np.mean(x) * beta
    return alpha, beta

alpha_regressao, beta_regressao = regressao(x,y)

print(alpha_regressao, beta_regressao)

reg_completa = smf.ols('y ~ x ', data=df).fit()

print(reg_completa.summary())

###############
## Aplicação ##
###############


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

reg = smf.ols('preco ~ dist', data=df).fit()

print(reg.summary())

print(reg.params)

preco_hat = reg.params[0] + reg.params[1] * df['preco']
preco_hat = reg.predict()
df['preco_hat'] = preco_hat

plt.scatter('dist', 'preco',
           data=df, alpha=0.25)
plt.plot('dist',
         'preco_hat',
         data=df,
         color='black')
plt.xlabel('Distância (milhas)')
plt.ylabel('Preço (dólares)')
plt.title('Passagens aéreas: relação entre distância e preço')
plt.show()
