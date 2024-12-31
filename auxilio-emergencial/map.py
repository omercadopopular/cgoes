# -*- coding: utf-8 -*-
"""
Created on Sun Jun 13 09:53:09 2021

@author: goes
"""

GeoPath = r'C:\Users\Carlos\OneDrive - UC San Diego\World Bank\Tunisia\geo\stanford-pw239pk4311-shapefile\pw239pk4311.shp'
ReadPath = r'C:\Users\Carlos\OneDrive - UC San Diego\World Bank\Tunisia\data\out\laborforce_district_aggindustry.csv'

Path = r''

import pandas as pd
import geopandas
import matplotlib.pyplot as plt

cols = { 'CD_MUN': 'codigo_ibge',
        'NM_MUN': 'nome_mun_ac',
        'SIGLA_UF': 'uf',
        'AREA_KM2': 'area'
        }

Brazil = geopandas.read_file(GeoPath, dtype={'CD_MUN': int})
Brazil = Brazil.rename(columns=cols)
Brazil.codigo_ibge = pd.to_numeric(Brazil.codigo_ibge)

Frame = pd.read_csv(ReadPath)

cols = {'Ano': 'ano',
       'Sigla da Unidade da Federação': 'uf',
       'Código do Município': 'codigo_ibge',
       'Produto Interno Bruto, \na preços correntes\n(R$ 1.000)': 'pib',
       'Produto Interno Bruto per capita, \na preços correntes\n(R$ 1,00)': 'pibpc'
       }

GDP = pd.read_excel(GDPPath).rename(columns=cols)[cols.values()]
GDP = GDP[ GDP.ano == 2018 ].drop(['ano'], axis=1)
GDP['population'] = (GDP.pib * 1000) / GDP.pibpc

Complete = Brazil.merge(Frame, on=['codigo_ibge','uf']).merge(GDP, on=['codigo_ibge','uf'])
Complete['valor_pib'] = Complete.valor / (Complete.pib*1000*1.012) * 100
Complete['quantpc'] = Complete.quant / Complete.population * 10000

fig = plt.figure(figsize=(15,15))
axes = fig.add_axes([0, 0, 1, 1])
axes.axis('off')

mymap = Complete.plot(ax=axes,
                     column='valor_pib',
                     linewidth=0.05,
                     edgecolor='black',
                     cmap="YlOrBr",
                     vmin = 0,
                     vmax = 35)

plt.title('Auxílio Emergencial como Proporção do PIB do Município')  

cax = fig.add_axes([0.9, 0.1, 0.03, 0.8])
sm = plt.cm.ScalarMappable(cmap="YlOrBr", norm=plt.Normalize(vmin = 0, vmax = 35))
sm._A = []
fig.colorbar(sm, cax=cax)

    
plt.tight_layout()
plt.show()


fig = plt.figure(figsize=(15,15))
axes = fig.add_axes([0, 0, 1, 1])
axes.axis('off')

mymap = Complete.plot(ax=axes,
                     column='valor_pib',
                     linewidth=0.05,
                     edgecolor='black',
                     cmap="YlOrBr",
                     scheme='quantiles',
                     legend=True,
                     legend_kwds={'fontsize': 20, 'loc': 'lower left'})

plt.title('Auxílio Emergencial como Proporção do PIB do Município', fontsize=30)  

#plt.tight_layout()
plt.show()
