# -*- coding: utf-8 -*-
"""
Created on Wed Jan 10 15:43:42 2018

@author: CarlosABG
"""

#################
# USER SETTINGS #
#################

RESULTS_PATH = "H:/Notas Conceituais/SegPub-Drogas/Dados/results/"

UF_PATH = RESULTS_PATH + 'ufdf.csv'
MUN_PATH = RESULTS_PATH + 'mundf.csv'

POP_PATH = "H:/Notas Conceituais/SegPub-Drogas/Dados/ibge_populacao/estimativa_dou_2017.xls"
UFPOP_PATH = "H:/Notas Conceituais/SegPub-Drogas/Dados/ibge_populacao/uf_populacao.xlsx"

SHP_PATH = "H:/Notas Conceituais/SegPub-Drogas/Dados/ibge_mapas/BRMIE250GC_SIR.shp"

IMG_PATH = "H:/Notas Conceituais/SegPub-Drogas/Dados/img/"

###################
# PYTHON PACKAGES #
###################

# Import packages

import pandas as pd
import geopandas as gpd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

#####################
# CREATE DATAFRAMES #
#####################

UFDF = pd.read_csv(UF_PATH, sep=";", decimal=",")
MUNDF = pd.read_csv(MUN_PATH, sep=";", decimal=",")
POPDF = pd.read_excel(POP_PATH, sheetname="export")
UFPOP = pd.read_excel(UFPOP_PATH, sheetname="export")

POPDF['codigo_mun'] = [int(item) for item in POPDF['codigo_mun']]

###########################
# MUNICIPALITIES ANALYSIS #
###########################

# 2005

MUNDF_05 = MUNDF[ MUNDF['ano'] == 2005 ]

MUNDF_05 = (MUNDF_05
         .set_index('CODMUNRES')
         .join(POPDF.set_index('codigo_mun_7'), how='left')
         .reset_index(drop=False)
         )

MICRODF_05 = MUNDF_05.groupby('codigo_micro').agg({
                        'ano': np.mean,
                        'homicidios': np.sum,
                        'uf': np.mean,
                        'pop_mun_05': np.sum,
                        'pop_uf': np.mean,
                        }).reset_index(drop=False)

MICRODF_05['tx_hom'] = MICRODF_05['homicidios'] / ( MICRODF_05['pop_mun_05'] / 100000 )
MICRODF_05['tx_hom_pct'] = MICRODF_05['tx_hom'].rank(pct=True) * 100
MICRODF_05 = MICRODF_05.sort_values('tx_hom_pct')

# 2015

MUNDF_15 = MUNDF[ MUNDF['ano'] == 2015 ]

MUNDF_15 = (MUNDF_15
         .set_index('CODMUNRES')
         .join(POPDF.set_index('codigo_mun'), how='left')
         .reset_index(drop=False)
         )

MICRODF_15 = MUNDF_15.groupby('codigo_micro').agg({
                        'ano': np.mean,
                        'homicidios': np.sum,
                        'uf': np.mean,
                        'pop_mun_15': np.sum,
                        'pop_uf': np.mean,
                        }).reset_index(drop=False)

MICRODF_15['tx_hom'] = MICRODF_15['homicidios'] / ( MICRODF_15['pop_mun_15'] / 100000 )
MICRODF_15['tx_hom_pct'] = MICRODF_15['tx_hom'].rank(pct=True) * 100
MICRODF_15 = MICRODF_15.sort_values('tx_hom_pct')

# Consolidation

MICRODF = MICRODF_05[['codigo_micro','homicidios','tx_hom','tx_hom_pct','pop_mun_05']]

MICRODF = MICRODF.rename(columns={
        'homicidios': 'homicidios_05',
        'tx_hom': 'tx_hom_05',
        'tx_hom_pct': 'tx_hom_pct_05',
        'pop_mun_05': 'pop_05'
        })

MICRO_T = MICRODF_15[['codigo_micro','homicidios','tx_hom','tx_hom_pct','pop_mun_15']]

MICRO_T = MICRO_T.rename(columns={
        'homicidios': 'homicidios_15',
        'tx_hom': 'tx_hom_15',
        'tx_hom_pct': 'tx_hom_pct_15',
        'pop_mun_15': 'pop_15'
        })

MICRODF = pd.merge(MICRO_T, MICRODF, on='codigo_micro', how='left')

MICRODF['delta'] = MICRODF['tx_hom_15'] - MICRODF['tx_hom_05']

MICRODF.to_csv(RESULTS_PATH + 'micro_tx_hom.csv', sep=";", decimal=",")

###############
# CHART: 2015 #
###############

# USER SETTINGS

LEFT = -1
RIGHT = 101
BOTTOM = -1
TOP = 81

X_LABEL = 'Porcentagem de microrregiões com tx de homicídios até esse limite'
Y_LABEL = 'Tx de homicídios por 100 mil habitantes'

## Plot

plt.style.use('fivethirtyeight')

# Declare figure
fig, ax = plt.subplots(figsize=(12,7))

# Plot chart
plt.scatter('tx_hom_pct_15', 'tx_hom_15', data=MICRODF,
            label="Taxa de Homicídio",
            color='brown',
            alpha=0.5, s=MICRODF['pop_15'] / 7500)

# Configure axes
ax.yaxis.grid(which="major", color='grey', linewidth=2)
ax.xaxis.grid(which="major", linewidth=0)
ax.tick_params(axis='both', which='major', labelsize=15)
ax.set_xlim(left = LEFT, right = RIGHT)
ax.set_ylim(bottom = BOTTOM, top = TOP)


# Set axis labels
ax.set_xlabel(X_LABEL, fontsize=19)
ax.set_ylabel(Y_LABEL, fontsize=19)

plt.show()

fig.savefig(IMG_PATH + 'micro_tx_hom.png')
fig.savefig(IMG_PATH + 'micro_tx_hom.pdf')

#############
# MAP MICRO #
#############

MICROSF = gpd.read_file(SHP_PATH)
MICROSF['CD_GEOCMI'] = [int(item) for item in MICROSF['CD_GEOCMI']]
MICROSF['geometry'] = MICROSF['geometry'].simplify(0.05)

MICROSF = MICROSF.set_index("CD_GEOCMI").join(MICRODF.set_index("codigo_micro"), how="left").reset_index(drop=False)

fig, axes = plt.subplots(figsize=(10, 10), facecolor='white')
    
mymap = MICROSF.plot(ax=axes,
                     column="delta",
                     linewidth=0.1,
                     cmap="seismic",
                     vmin = -40,
                     vmax = 40)
    
plt.axis('off')
plt.tight_layout()
cax = fig.add_axes([0.9, 0.1, 0.03, 0.8])
sm = plt.cm.ScalarMappable(cmap="seismic", norm=plt.Normalize(vmin = -40, vmax = 40))
sm._A = []
fig.colorbar(sm, cax=cax)
    
plt.show()

fig.savefig(IMG_PATH + 'mapa.png')
fig.savefig(IMG_PATH + 'mapa.pdf')


###################
# STATES ANALYSIS #
###################

UFDF = UFDF[ UFDF['ano'] > 2000]

UFDF = pd.merge(UFDF, UFPOP, left_on=['UF','ano'], right_on=['uf','ano'])

UFDF['tx_hom'] = UFDF['homicidios'] / ( UFDF['uf_pop'] / 100000 )

UFDF.to_csv(RESULTS_PATH + 'uf_tx_hom.csv')

## Boxplot

sns.boxplot(x='ano', y='tx_hom', data=UFDF)

## Map

UFDF_delta = UFDF[ UFDF['ano'] == 2015].copy()
UFDF_delta['tx_inicial'] = ([ UFDF.set_index(['UF','ano']).loc[uf,2005]['tx_hom'] for uf in list(UFDF_delta['UF']) ])
UFDF_delta['tx_final'] = ([ UFDF.set_index(['UF','ano']).loc[uf,2015]['tx_hom'] for uf in list(UFDF_delta['UF']) ])
UFDF_delta['tx_delta'] = (UFDF_delta['tx_final'] - UFDF_delta['tx_inicial'])

UFSF = gpd.read_file(SHP_PATH)
UFSF['CD_GEOCUF'] = [int(item) for item in UFSF['CD_GEOCUF']]

UFSF = UFSF.set_index("CD_GEOCUF").join(UFDF_delta.set_index("UF"), how="left").reset_index(drop=False)

fig, axes = plt.subplots(figsize=(10, 10))
    
mymap = UFSF.plot(ax=axes,
                     column="tx_delta",
                     linewidth=0.25,
                     cmap="seismic",
                     vmin = -35,
                     vmax = 35)
    
plt.axis('off')
plt.tight_layout()
plt.title('Brasil: Variação na taxa de homicídio estadual (2005-2015)')
cax = fig.add_axes([0.9, 0.1, 0.03, 0.8])
sm = plt.cm.ScalarMappable(cmap="seismic", norm=plt.Normalize(vmin = -35, vmax = 35))
sm._A = []
fig.colorbar(sm, cax=cax)
    
plt.show()

