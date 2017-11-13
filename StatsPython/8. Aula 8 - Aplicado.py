# -*- coding: utf-8 -*-
"""
Created on Sun Nov 12 00:36:58 2017
@author: Carlos
"""

import pandas as pd
    
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

grupos.boxplot(column=['peso'], figsize=(16,8))
grupos.boxplot(column=['FSIQ'], figsize=(16,8))

# Teste-t (diferenças de médias)

from scipy import stats

masc = dfiq[ dfiq['sexo'] == 'Masculino'].dropna()
fem = dfiq[ dfiq['sexo'] == 'Feminino'].dropna()

t_stat, p_valor = stats.ttest_ind(masc['peso'], fem['peso'])
print("P-valor do teste-t de médias iguais de peso " +
      "para ambos os sexos: {:.2f}".format(p_valor))

t_stat, p_valor = stats.ttest_ind(masc['FSIQ'], fem['FSIQ'])
print("P-valor do teste-t de médias iguais de QI " +
      "para ambos os sexos: {:.2f}".format(p_valor))

# Teste-F (múltiplos grupos)

# Scipy

f_stat, f_pvalue = stats.f_oneway(masc['peso'], fem['peso'])
print("P-valor do F-teste de médias iguais de peso " +
      "para ambos os sexos: {:.2f}".format(f_pvalue))

f_stat, f_pvalue = stats.f_oneway(masc['FSIQ'], fem['FSIQ'])
print("P-valor do F-teste de médias iguais de peso " +
      "para ambos os sexos: {:.2f}".format(f_pvalue))

# Statsmodels

import statsmodels.formula.api as smf

model1 = smf.ols("peso ~ C(sexo)", data=dfiq.dropna()).fit()
print("P-valor do F-teste de médias iguais de peso " +
      "para ambos os sexos: {:.2f}".format(model1.f_pvalue))

model2 = smf.ols("FSIQ ~ C(sexo)", data=dfiq.dropna()).fit()
print("P-valor do F-teste de médias iguais de QI " +
      "para ambos os sexos: {:.2f}".format(model2.f_pvalue))

model1.summary()
model2.summary()
