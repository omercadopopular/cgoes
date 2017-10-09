# -*- coding: utf-8 -*-
"""

PROJETO: "Uma Estratégia De Antecipação Dos Impactos Regionais E Setoriais
Da Abertura Comercial Brasileira Sobre O Emprego E Requalificação Da População Afetada"

EQUIPE DO PROJETO: Carlos Góes (SAE), Eduardo Leoni (SAE),
Luís Montes (SAE) e Alexandre Messa (Núcleo Econômico da CAMEX).

AUTOR DESTE CÓDIGO: Carlos Góes, SAE/Presidência da República

DATA: 24/07/2017

"""

import pandas as pd
import matplotlib.pyplot as plt
import statsmodels.formula.api as smf
import numpy as np
import seaborn as sns
import scipy
import os


#####################################
# 1. Retrieve Databases 
#####################################

figspath = "K:\\Notas Técnicas\\Abertura\\data\\Econometria\\paper\\figs"
data_mun = "K:\\Notas Técnicas\\Abertura\\data\\Econometria\\results\\modelresult_mun.json"
data_micro = "K:\\Notas Técnicas\\Abertura\\data\\Econometria\\results\\modelresult_micro.json"
data_social = "K:\\Notas Técnicas\\Abertura\\data\\Econometria\\data\\atlas2013_dadosbrutos_pt.xlsx"
datartr_micro = "k:/Notas Técnicas/Abertura/data/Econometria/data/rtr.csv"

modelresult_mun = pd.read_json(path_or_buf=data_mun)
modelresult_micro = pd.read_json(path_or_buf=data_micro)
rtr_micro = pd.read_csv(open(datartr_micro, 'r'))

## Social Data merge

socialdata = pd.read_excel(data_social, sheetname="MUN 91-00-10")
socialdata = pd.merge(modelresult_mun[["municipio", "microrregiao", "n"]], socialdata, left_on="municipio", right_on="Codmun6")
socialdata = socialdata[socialdata['ANO'] == 2010]

# weighted mean

weightedmean = lambda x: np.average(x, weights=socialdata.loc[x.index, "n"])

group = list(socialdata.columns)[8:]

f = {}
for item in group:
    f.update({item: weightedmean})

socialdata_micro = socialdata.groupby("microrregiao").agg(f).reset_index(drop=False)

workdf = pd.merge(modelresult_micro, socialdata_micro, left_on="microrregiao", right_on="microrregiao")

workdf = pd.merge(rtr_micro, workdf, left_on="microrregiao", right_on="microrregiao")

# new vars

workdf['lrdpc'] = [np.log(item) for item in workdf['RDPC']]
workdf['ln'] = [np.log(item) for item in workdf['n']]
workdf['n_sq'] = [item ** 2 for item in workdf['n']]
workdf['rtr'] = [item * 100 for item in workdf['rtr']]

## Quantiles

labels = list(np.linspace(1,10, num=10))

workdf["quantiles_renda"] = pd.qcut(workdf['RDPC'],10, labels=labels)
workdf["quantiles_efeito"] = pd.qcut(workdf['pop_change_mun_final'],10, labels=labels)


## Summary Statistics

workdf.groupby("quantiles_renda").agg({"pop_change_mun_final": [np.mean, scipy.stats.sem]})


## Figure 1: Percentiles

modelresult_micro['pctile'] = modelresult_micro['pop_change_mun_final'].rank(pct=True) * 100

f, ax = plt.subplots(1, figsize=(10,5))

#for spine in ax.spines.values():
#    spine.set_edgecolor("white")

plt.axhline(y=0, color='black')
plt.axis([0,100,-3,3])
plt.xlabel("Percentil da microrregião em variação esperada de emprego", fontsize=14, fontname="Helvetica")
plt.ylabel("Variação esperada de emprego", fontsize=14, fontname="Helvetica")
plt.xticks(np.linspace(0,100,5), np.linspace(0,100,5))
ax.scatter(modelresult_micro['pctile'],
           modelresult_micro['pop_change_mun_final'],
           s=modelresult_micro['n'] * ( 10 ** -3 ),
           color='red',
           alpha=.5,
           label='Microrregião',)
plt.show()

f.savefig(figspath + "\\laborforce.pdf")

modelresult_micro[['microrregiao','pop_change_mun_final','pctile','n']].to_csv("K:/Notas Técnicas/Abertura/data/Econometria/results/microrpctile.csv", sep=";", decimal=",")

## Figure 2: Correlation RTR and effects

f, ax = plt.subplots(1, figsize=(10,5))

#for spine in ax.spines.values():
#    spine.set_edgecolor("white")

plt.axis([0,25,-1,1])
plt.xlabel("Tarifa regional ad valorem", fontsize=14, fontname="Helvetica")
plt.ylabel("Variação esperada de emprego", fontsize=14, fontname="Helvetica")
fit = np.polyfit(workdf['rtr'], workdf['pop_change_mun_final'], 1)
ax.plot(np.sort(workdf['rtr']), fit[0] * np.sort(workdf['rtr']) + fit[1], color='black')
ax.scatter('rtr',
           'pop_change_mun_final',
           data=workdf,
           s=workdf['n'] * ( 10 ** -3 ),
           color='red',
           alpha=.5,
           label='Microrregião',)
plt.show()

f.savefig(figspath + "\\rtr_effects.pdf")

reg = smf.ols(formula="pop_change_mun_final ~ rtr", data=workdf).fit(cov_type='HC3')

print(reg.summary())

## Residual

resid = reg.resid

f, ax = plt.subplots(1, figsize=(10,5))

#for spine in ax.spines.values():
#    spine.set_edgecolor("white")

plt.axis([40,80,-0.5,0.5])
plt.xlabel("T_ATIV", fontsize=14, fontname="Helvetica")
plt.ylabel("Resíduo", fontsize=14, fontname="Helvetica")
ax.scatter(workdf['T_ATIV'],
           resid,
           color='red',
           alpha=.5,
           label='Microrregião',)
plt.show()




"""

## Boxplot decil de renda

groups = np.sort(list(workdf["quantiles_renda"].unique()))
groups = [int(item) for item in groups]

qgroups = []
for group in groups:
    dfmin = workdf[ workdf['quantiles_renda'] == group ]
    qgroups.append(list(dfmin['pop_change_mun_final']))

fig, axes = plt.subplots(figsize=(12, 6))
axes.boxplot(qgroups,
             #labels=ministry_df.quantile(q=quantile_threshold, axis=0).sort_values().index,
             showfliers=False)
axes.axhline(0, color='black', label="Mean") 
axes.set_xticklabels(groups)
plt.ylabel('Variação esperada no emprego, após 20 anos da liberalização')  
plt.xlabel('Decil da renda familiar per capita média do município')  
#plt.title('Brasil: Distribuição da variação do emprego esperada após liberalização, por decil de renda do município')
plt.show()

fig.savefig(figspath + "\\boxplot_decil.pdf")




## Boxplot efeito

groups = np.sort(list(workdf["quantiles_efeito"].unique()))
groups = [int(item) for item in groups]

qgroups = []
for group in groups:
    dfmin = workdf[ workdf['quantiles_efeito'] == group ]
    qgroups.append(list(dfmin['pop_change_mun_final']))

fig, axes = plt.subplots(figsize=(13, 6))
axes.boxplot(qgroups,
             #labels=ministry_df.quantile(q=quantile_threshold, axis=0).sort_values().index,
             showfliers=False)
axes.axhline(0, color='black', label="Mean") 
axes.set_xticklabels(groups)
plt.ylabel('Variação esperada no emprego, após 20 anos da liberalização')  
plt.xlabel('Decil da dos efeitos')  
plt.title('Brasil: Distribuição da variação do emprego esperada após liberalização, por decil de renda do município')
plt.show()

## Boxplot estado

groups = workdf["UFSigla"].unique()

qgroups = []
for group in groups:
    dfmin = workdf[ workdf['UFSigla'] == group ]
    qgroups.append(list(dfmin['pop_change_mun_final']))

fig, axes = plt.subplots(figsize=(13, 6))
axes.boxplot(qgroups,
             labels=workdf.quantile(q=quantile_threshold, axis=0).sort_values().index,
             showfliers=False)
axes.axhline(0, color='black', label="Mean") 
axes.set_xticklabels(groups)
plt.ylabel('Variação esperada no emprego, após 20 anos da liberalização')  
plt.xlabel('Estado')  
plt.title('Brasil: Distribuição da variação do emprego esperada após liberalização, por Estado')
plt.show()

## Correlations

f, ax = plt.subplots(2,2, figsize=(30,30))

plt.title('Brasil: Correlações entre resultados e indústrias')
plt.xlabel("Percentil do município em variação esperada de emprego")
plt.ylabel("Variação esperada de emprego")

#plt.xticks(np.linspace(0,100,5), np.linspace(0,100,5))

sns.regplot('T_ATIV','pop_change_mun_final', data=workdf, ax=ax[0,0])
sns.regplot('ln','pop_change_mun_final', data=workdf, ax=ax[0,1])
sns.regplot('P_FORMAL','pop_change_mun_final', data=workdf, ax=ax[1,0])
sns.regplot('lrdpc','pop_change_mun_final', data=workdf, ax=ax[1,1])

ax[1,1].set_xlim(4,8)

plt.show()

f.savefig(figspath + "\\correlations.pdf")

"""