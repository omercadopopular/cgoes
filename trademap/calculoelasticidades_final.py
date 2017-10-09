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
import statsmodels.formula.api as smf
import matplotlib.mlab as mlab
import matplotlib.pyplot as plt
import numpy as np
import os


#####################################
# 1. Retrieve Databases 
#####################################

datapath = "K:\\Notas Técnicas\\Abertura\\data\\Econometria\\data\\gtap_mun.csv"
resultspath = "K:\\Notas Técnicas\\Abertura\\data\\Econometria\\results"
figspath = "K:\\Notas Técnicas\\Abertura\\data\\Econometria\\paper\\figs"
cgeinput = "K:\\Notas Técnicas\\Abertura\\data\\Econometria\\data\\cgeinput.csv"
cgeinput_comp = "K:\\Notas Técnicas\\Abertura\\data\\Econometria\\data\\cgeinput_comp.xlsx"
munmicro = "K:\\Notas Técnicas\\Abertura\\data\\Econometria\\data\\munmicro.csv"


pwd = os.getcwd()
os.chdir(os.path.dirname(datapath))
df = pd.read_csv(os.path.basename(datapath), low_memory=False)
cgedf = pd.read_csv(os.path.basename(cgeinput), decimal=",", sep=";")
cgedf_comp = pd.read_excel(os.path.basename(cgeinput_comp), sheetname="output")
munmicrodf = pd.read_csv(os.path.basename(munmicro), decimal=",", sep=";")
os.chdir(pwd)

#####################################
# 2. Prepare tables
#####################################

statelist = df['UFSigla'].unique()
munlist = df['municipio'].unique()
gtaplist = [i+1 for i in range(57)]

# Gerar tabela agregado por GTAP, nacionalmente, para cada ano

consolidate = (df
               .groupby(['AnoRais','gtap']).sum()
               .rename(columns={"n": "nacional"})
               )

# Gerar tabela agregado por GTAP, por estado

statesum = (df
           .groupby(['UFSigla','gtap']).sum()
           .reset_index(drop=False)
           .sort_values(by=['UFSigla','gtap'])
           .drop(['AnoRais', 'municipio', 'imputeGtap'], axis=1)
           )

# Gerar tabela agregado por GTAP, por estado, para cada ano

statedf = (df
           .groupby(['UFSigla','AnoRais','gtap']).sum()
           .reset_index(drop=False)
           .sort_values(by=['UFSigla','AnoRais','gtap'])
           )

#####################################
# 3. Estimate elasticities
#####################################

# Rodar loop para calcular elasticidades de cada setor GTAP para cada estado

## Criar lista vazia com elasticidades, r-quadrado, n
elasticities = []
rsquared = []
nobs = []
tvalues = []
nregset = []

# Loop
for state in statelist:
    # Reduzir base de dados para cada estado
    dfmin = statedf[statedf['UFSigla'] == state]
    # Adicionar dados nacionais consolidados por ano ao dataframe
    dfmin = (consolidate
             .drop(['municipio','imputeGtap'], axis=1)
             .join(dfmin.drop(['municipio','imputeGtap'], axis=1).set_index(['AnoRais','gtap']), how='inner')
             .reset_index(drop=False)            
            )

    # Criar lista de GTAPs disponíveis no estado
    gtaplistm = np.sort(dfmin['gtap'].unique())
        
    for gtap in gtaplistm:
        # Criar dataframe para a regressão
        regset = dfmin[ dfmin['gtap'] == gtap ]
        
        # Define o indexador temporal
        regset = regset.set_index('AnoRais')
        
        # Roda o modelo
        result = smf.ols(formula="np.log(n) ~ np.log(nacional)", data=regset).fit()
        
        # Armazena a elasticidade
        if result.nobs < 3:
            elasticities.append(1)
            rsquared.append(np.nan)        
            nobs.append(result.nobs)
            tvalues.append(np.abs(np.nan))
            nregset.append(np.log(sum(regset['n'])))
        
        else:       
            elasticities.append(result.params[1])
            rsquared.append(result.rsquared)        
            nobs.append(result.nobs)
            tvalues.append(np.abs(result.tvalues[1]))
            nregset.append(np.log(sum(regset['n'])))
        
# Adiciona as elasticidades e outras estatísticas à tabela agregado por GTAP, por estado      
statesum['elasticity'] = pd.Series(elasticities)
statesum['rsquared'] = pd.Series(rsquared)
statesum['nobs'] = pd.Series(nobs)
statesum['tvalue'] = pd.Series(tvalues)

# Salva base de statesum
statesumbase = statesum.copy()

# Exporta as elasticidades para um CVS
elasticitiesdf = (statesum
                  .drop('n', axis=1)
                  .set_index(['UFSigla','gtap'])
                  )

elasticitiesdf.to_csv(resultspath + "\\elasticities.csv", sep=";", decimal=",", header=True)



#####################################
# 4. Plot Charts
#####################################

# cria vetor que exclui elasticidades presumidas
elasticities_trimmed = [elasticity for elasticity in elasticities if elasticity != 1]

fig, ax = plt.subplots()

# Grafica histograma das elasticidades
n, bins, patches = plt.hist(elasticities_trimmed,
                            bins=250,
                            normed=True,
                            facecolor='grey', 
                            alpha=0.75,
                            label="Elasticidades") 


# Linha de distribuição normal
y = mlab.normpdf(bins, np.mean(elasticities), 1)
l = plt.plot(bins, y, 'r--', linewidth=2, label="Dist. Normal $(\mu, \sigma=1)$")

# Linha descrevendo a elasticidade média
plt.axvline(np.mean(elasticities_trimmed), color='black', label="Média") 
         
# Formatação
ax.axis([-10,10,0,0.5])
ax.legend(loc='upper left')
plt.xlabel('Elasticidade') 
plt.ylabel('Probabilidade de cada intervalo')  
plt.title('Histograma de elasticidades')
plt.show()
fig.savefig(figspath + "\\elastic_hist.pdf")

# Grafica elasticidades e t-values
fig, ax = plt.subplots()

ax.scatter(elasticities, tvalues, color='grey', alpha=0.25, label="Elasticidades") 

# Linha descrevendo a elasticidade média
ax.axvline(np.mean(elasticities), color='black', label="Média") 
         
# Formatação
ax.axis([-10,10,0,75])
ax.legend(loc='upper left')
plt.xlabel('Elasticidade') 
plt.ylabel('t-valor')  
plt.title('Elasticidades e t-valor')
plt.show()
fig.savefig(figspath + "\\elastic_scatter.pdf")

# Grafica elasticidades e t-values
fig, ax = plt.subplots()

ax.scatter(nregset, tvalues, color='grey', alpha=0.25, label="Elasticidades") 
        
# Formatação
ax.axis([0,20,0,75])
ax.legend(loc='upper left')
plt.xlabel('Log da força de trabalho no estado-setor') 
plt.ylabel('t-valor')  
plt.title('Amostra e t-valor')
plt.show()
fig.savefig(figspath + "\\amostra_scatter.pdf")


#####################################
# 5. Calculate error terms and adjustment factor
#####################################

# Junte os dados do modelo aos dados estaduais
statesum = (statesumbase
           .set_index(["UFSigla","gtap"])
           .join(cgedf.set_index("gtap"),
                 how="left")
           .reset_index(drop=False)
           )

# Calcular variação percentual esperada por estado
statesum['pop_change_state'] = (statesum['elasticity']) * statesum['pop_change']

# Calcular variação absoluta esperada por estado
statesum['n_pop_change_state'] = statesum['n'] * (statesum['pop_change_state'] / 100)

# Consolida dados por GTAP
gtapdf = statesum.groupby("gtap").sum().reset_index(drop=False).drop('pop_change', axis=1)

# Agrega dados do modelo
gtapdf = pd.merge(gtapdf, cgedf, left_on="gtap", right_on="gtap", how="left").reset_index()

# Calcula variação esperada do modelo
gtapdf['n_pop_change'] = gtapdf['n']  * ( gtapdf['pop_change']  / 100 )

# Calcula fator de ajuste
gtapdf['epsilon'] = ( 1 + (gtapdf['n_pop_change'] - gtapdf['n_pop_change_state']) / gtapdf['n_pop_change_state'])
epsilon = pd.Series(gtapdf.set_index('gtap')['epsilon'])

#####################################
# 6. Recalculate expected state changes, with adjustment factor
#####################################

statesum = (statesum
           .set_index(["UFSigla","gtap"])
           .join(epsilon,
                 how="left")
           .reset_index(drop=False)
           )

statesum['elasticity_adj'] = statesum['elasticity'] * statesum['epsilon']
statesum['pop_change_state_adj'] = (statesum['elasticity_adj']) * statesum['pop_change']
statesum['n_pop_change_state_adj'] = statesum['n'] * (statesum['pop_change_state_adj'] / 100)
gtapdf = statesum.groupby("gtap").sum().reset_index(drop=False).drop('pop_change', axis=1)
gtapdf = pd.merge(gtapdf, cgedf, left_on="gtap", right_on="gtap", how="left").reset_index()
gtapdf['n_pop_change'] = gtapdf['n']  * ( gtapdf['pop_change']  / 100 )

# Verifica se o novo erro é zero
gtapdf['epsilon_adj'] = round( ( ( gtapdf['n_pop_change'] - gtapdf['n_pop_change_state_adj']) / gtapdf['n_pop_change_state_adj']) , 5)


# Exporta as elasticidades para um CVS
adjustedchangesdf = (statesum
                  .set_index(['UFSigla','gtap'])
                  [['pop_change_state_adj','n_pop_change_state_adj']]
                  .reset_index(drop=False)
                  )

adjustedchangesdf.to_csv(resultspath + "\\expectedchanges.csv", sep=";", decimal=",", header=True)

#####################################
# 7. Consolidate results
#####################################

# Apensar microrregiao aos dados municipais

df = df.set_index("municipio").join(munmicrodf.set_index("municipio"), how="left").reset_index()

# Juntar dados dos municípios com elasticidades

modelresult = (df.copy()
                .set_index(['UFSigla', 'gtap'])
                .join(adjustedchangesdf.set_index(['UFSigla', 'gtap'])['pop_change_state_adj'], how='left')
                .reset_index(drop=False)
                )

# Calcular variação esperada por municipio-GTAP-ano

modelresult['n_pop_change_mun_adj'] = (modelresult['pop_change_state_adj'] / 100) * modelresult['n']

# Selecionar ano de analise

byear = 2011

modelresult = modelresult[ modelresult['AnoRais'] == byear]

#####################################
# 8. Exportar resultados municipais
#####################################

## Agregar no nível municipal

# Líquido

modelresult_mun = modelresult.groupby("municipio").agg({
        'microrregiao': 'first',
        'AnoRais': np.mean,
        'UFSigla': 'first',
        'n': np.sum,
        'n_pop_change_mun_adj': np.sum,
        }).reset_index(drop=False)

# Positivo
    
modelresult_mun_pos = modelresult[modelresult['n_pop_change_mun_adj'] > 0].groupby("municipio").agg({
        'microrregiao': 'first',
        'AnoRais': np.mean,
        'UFSigla': 'first',
        'n': np.sum,
        'n_pop_change_mun_adj': np.sum,
        }).reset_index(drop=False)    

# Negativo
    
modelresult_mun_neg = modelresult[modelresult['n_pop_change_mun_adj'] < 0].groupby("municipio").agg({
        'microrregiao': 'first',
        'AnoRais': np.mean,
        'UFSigla': 'first',
        'n': np.sum,
        'n_pop_change_mun_adj': np.sum,
        }).reset_index(drop=False)    

## Calcular variação

modelresult_mun['pop_change_mun_final'] = ( modelresult_mun['n_pop_change_mun_adj'] / modelresult_mun['n']) * 100
modelresult_mun['pop_change_mun_final_pos'] = ( modelresult_mun_pos['n_pop_change_mun_adj'] / modelresult_mun['n']) * 100
modelresult_mun['pop_change_mun_final_neg'] = ( modelresult_mun_neg['n_pop_change_mun_adj'] / modelresult_mun['n']) * 100

# Grafica histograma das variações municipais
fig, ax = plt.subplots()

n, bins, patches = plt.hist(modelresult_mun['pop_change_mun_final'].dropna(),
                            bins=100,
                            normed=True,
                            facecolor='grey', 
                            alpha=0.75,
                            label="Expected changes") 


# Linha descrevendo a média
plt.axvline(np.mean(modelresult_mun['pop_change_mun_final'].dropna()), color='black', label="Mean") 
         
# Formatação
ax.legend(loc='upper left')
plt.xlabel('Expected pct change') 
plt.ylabel('Probability of Each Value')  
plt.title('Histogram of municipal changes')
plt.show()
fig.savefig(figspath + "\\results_mun_hist.pdf")

# Salva base de dados
modelresult_mun.reset_index(drop=False).to_json(resultspath + "\\modelresult_mun.json")

#####################################
# 9. Exportar resultados microrregioes
#####################################

# Líquido

modelresult_micro = modelresult.groupby("microrregiao").agg({
        'AnoRais': np.mean,
        'UFSigla': 'first',
        'n': np.sum,
        'n_pop_change_mun_adj': np.sum,
        }).reset_index(drop=False)
    
# Positivo

modelresult_micro_pos = modelresult[modelresult['n_pop_change_mun_adj'] > 0].groupby("microrregiao").agg({
        'AnoRais': np.mean,
        'UFSigla': 'first',
        'n': np.sum,
        'n_pop_change_mun_adj': np.sum,
        }).reset_index(drop=False)    
    
# Negativo    
    
modelresult_micro_neg = modelresult[modelresult['n_pop_change_mun_adj'] < 0].groupby("microrregiao").agg({
        'AnoRais': np.mean,
        'UFSigla': 'first',
        'n': np.sum,
        'n_pop_change_mun_adj': np.sum,
        }).reset_index(drop=False)    
    

# Calcular variação

modelresult_micro['pop_change_mun_final'] = ( modelresult_micro['n_pop_change_mun_adj'] / modelresult_micro['n']) * 100
modelresult_micro['pop_change_mun_final_pos'] = ( modelresult_micro_pos['n_pop_change_mun_adj'] / modelresult_micro['n']) * 100
modelresult_micro['pop_change_mun_final_neg'] = ( modelresult_micro_neg['n_pop_change_mun_adj'] / modelresult_micro['n']) * 100

# Grafica histograma das variações municipais
fig, ax = plt.subplots()

n, bins, patches = plt.hist(modelresult_micro['pop_change_mun_final'].dropna(),
                            bins=75,
                            facecolor='grey', 
                            alpha=0.75,
                            label="Variação esperada",
                            normed=True) 

# Linha de distribuição normal
y = mlab.normpdf(bins, np.mean(modelresult_micro['pop_change_mun_final'].dropna()), np.std(modelresult_micro['pop_change_mun_final'].dropna()))
l = plt.plot(bins, y, 'r--', linewidth=2, label="Dist. Normal $(\mu, \sigma)$")

# Linha descrevendo a média
plt.axvline(np.mean(modelresult_micro['pop_change_mun_final'].dropna()), color='black', label="Média") 
         
# Formatação
ax.legend(loc='upper left')
plt.xlabel('Variação percentual esperada') 
plt.ylabel('Probabilidade de cada intervalo')  
plt.title('Histograma de variações esperadas, por microrregião')
plt.show()
fig.savefig(figspath + "\\results_micro_hist.pdf")

# Salva base de dados
modelresult_micro.reset_index(drop=False).to_json(resultspath + "\\modelresult_micro.json")


#####################################
# 10. Loop de cálculos anuais
#####################################

dynamicresults = pd.DataFrame()
totalpos = []
totalneg = []
totalliq = []

for year in range(1, 21):
    cgedf = cgedf_comp[ cgedf_comp['year'] == year ].drop("year", axis=1)
    
    #####################################
    # 10.1 Calculate error terms and adjustment factor
    #####################################
    
    # Junte os dados do modelo aos dados estaduais
    statesum = (statesumbase.copy()
               .set_index(["UFSigla","gtap"])
               .join(cgedf.set_index("gtap"),
                     how="left")
               .reset_index(drop=False)
               )
    
    # Calcular variação percentual esperada por estado
    statesum['pop_change_state'] = (statesum['elasticity']) * statesum['pop_change']
    
    # Calcular variação absoluta esperada por estado
    statesum['n_pop_change_state'] = statesum['n'] * (statesum['pop_change_state'] / 100)
    
    # Consolida dados por GTAP
    gtapdf = statesum.groupby("gtap").sum().reset_index(drop=False).drop('pop_change', axis=1)
    
    # Agrega dados do modelo
    gtapdf = pd.merge(gtapdf, cgedf, left_on="gtap", right_on="gtap", how="left").reset_index()
    
    # Calcula variação esperada do modelo
    gtapdf['n_pop_change'] = gtapdf['n']  * ( gtapdf['pop_change']  / 100 )
    
    # Calcula fator de ajuste
    gtapdf['epsilon'] = ( 1 + (gtapdf['n_pop_change'] - gtapdf['n_pop_change_state']) / gtapdf['n_pop_change_state'])
    epsilon = pd.Series(gtapdf.set_index('gtap')['epsilon'])
    
    #####################################
    # 10.2 Recalculate expected state changes, with adjustment factor
    #####################################
    
    statesum = (statesum
               .set_index(["UFSigla","gtap"])
               .join(epsilon,
                     how="left")
               .reset_index(drop=False)
               )
    
    statesum['elasticity_adj'] = statesum['elasticity'] * statesum['epsilon']
    statesum['pop_change_state_adj'] = (statesum['elasticity_adj']) * statesum['pop_change']
    statesum['n_pop_change_state_adj'] = statesum['n'] * (statesum['pop_change_state_adj'] / 100)
    gtapdf = statesum.groupby("gtap").sum().reset_index(drop=False).drop('pop_change', axis=1)
    gtapdf = pd.merge(gtapdf, cgedf, left_on="gtap", right_on="gtap", how="left").reset_index()
    gtapdf['n_pop_change'] = gtapdf['n']  * ( gtapdf['pop_change']  / 100 )
    
    # Verifica se o novo erro é zero
    gtapdf['epsilon_adj'] = round( ( ( gtapdf['n_pop_change'] - gtapdf['n_pop_change_state_adj']) / gtapdf['n_pop_change_state_adj']) , 5)
    
    # Exporta as elasticidades para um CVS
    adjustedchangesdf = (statesum
                      .set_index(['UFSigla','gtap'])
                      [['pop_change_state_adj','n_pop_change_state_adj']]
                      .reset_index(drop=False)
                      )
    
    #####################################
    # 10.3 Consolidate results
    #####################################
        
    # Juntar dados dos municípios com elasticidades
    
    modelresult = (df.copy()
                    .set_index(['UFSigla', 'gtap'])
                    .join(adjustedchangesdf.set_index(['UFSigla', 'gtap'])['pop_change_state_adj'], how='left')
                    .reset_index(drop=False)
                    )
    
    # Calcular variação esperada por municipio-GTAP-ano
    
    modelresult['n_pop_change_mun_adj'] = (modelresult['pop_change_state_adj'] / 100) * modelresult['n']
    
    # Selecionar ano de analise
    
    byear = 2011
    
    modelresult = modelresult[ modelresult['AnoRais'] == byear]
    
    #####################################
    # 10.4 Exportar resultados municipais
    #####################################
    
    ## Agregar no nível municipal
    
    # Líquido
    
    modelresult_mun = modelresult.groupby("municipio").agg({
            'microrregiao': 'first',
            'AnoRais': np.mean,
            'UFSigla': 'first',
            'n': np.sum,
            'n_pop_change_mun_adj': np.sum,
            }).reset_index(drop=False)
    
    # Positivo
        
    modelresult_mun_pos = modelresult[modelresult['n_pop_change_mun_adj'] > 0].groupby("municipio").agg({
            'microrregiao': 'first',
            'AnoRais': np.mean,
            'UFSigla': 'first',
            'n': np.sum,
            'n_pop_change_mun_adj': np.sum,
            }).reset_index(drop=False)    
    
    # Negativo
        
    modelresult_mun_neg = modelresult[modelresult['n_pop_change_mun_adj'] < 0].groupby("municipio").agg({
            'microrregiao': 'first',
            'AnoRais': np.mean,
            'UFSigla': 'first',
            'n': np.sum,
            'n_pop_change_mun_adj': np.sum,
            }).reset_index(drop=False)    
    
    ## Calcular variação
    
    modelresult_mun['pop_change_mun_final'] = ( modelresult_mun['n_pop_change_mun_adj'] / modelresult_mun['n']) * 100
    modelresult_mun['pop_change_mun_final_pos'] = ( modelresult_mun_pos['n_pop_change_mun_adj'] / modelresult_mun['n']) * 100
    modelresult_mun['pop_change_mun_final_neg'] = ( modelresult_mun_neg['n_pop_change_mun_adj'] / modelresult_mun['n']) * 100
        
    #####################################
    # 10.5 Exportar resultados microrregioes
    #####################################
    
    # Líquido
    
    modelresult_micro = modelresult.groupby("microrregiao").agg({
            'AnoRais': np.mean,
            'UFSigla': 'first',
            'n': np.sum,
            'n_pop_change_mun_adj': np.sum,
            }).reset_index(drop=False)
        
    # Positivo
    
    modelresult_micro_pos = modelresult[modelresult['n_pop_change_mun_adj'] > 0].groupby("microrregiao").agg({
            'AnoRais': np.mean,
            'UFSigla': 'first',
            'n': np.sum,
            'n_pop_change_mun_adj': np.sum,
            }).reset_index(drop=False)    
        
    # Negativo    
        
    modelresult_micro_neg = modelresult[modelresult['n_pop_change_mun_adj'] < 0].groupby("microrregiao").agg({
            'AnoRais': np.mean,
            'UFSigla': 'first',
            'n': np.sum,
            'n_pop_change_mun_adj': np.sum,
            }).reset_index(drop=False)    
        
    
    # Calcular variação
    
    modelresult_micro['pop_change_mun_final'] = ( modelresult_micro['n_pop_change_mun_adj'] / modelresult_micro['n']) * 100
    modelresult_micro['pop_change_mun_final_pos'] = ( modelresult_micro_pos['n_pop_change_mun_adj'] / modelresult_micro['n']) * 100
    modelresult_micro['pop_change_mun_final_neg'] = ( modelresult_micro_neg['n_pop_change_mun_adj'] / modelresult_micro['n']) * 100
    
    modelresult_micro['year'] = [year for i in range(len(modelresult_micro))]

    dynamicresults = dynamicresults.append(modelresult_micro)
    totalpos.append(modelresult_micro_pos['n_pop_change_mun_adj'].sum())
    totalneg.append(modelresult_micro_neg['n_pop_change_mun_adj'].sum())
    totalliq.append(modelresult_micro['n_pop_change_mun_adj'].sum())

# Salva base de dados
dynamicresults.reset_index(drop=False).to_json(resultspath + "\\dynamicresults.json")