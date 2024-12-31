# -*- coding: utf-8 -*-
"""
1/13/24
@author: goes

"""

PopPath = r'C:\Users\wb592068\OneDrive - WBG\Brazil\data\ibge-pop\tabela6579.xlsx'
ReadPath = r'C:\Users\wb592068\OneDrive - WBG\Brazil\data\trade-mdic\EXP_COMPLETA_MUN.csv'
MunPath =  r'C:\Users\wb592068\OneDrive - WBG\Brazil\data\trade-mdic\UF_MUN.csv'
OutPath = r'C:\Users\wb592068\OneDrive - WBG\Brazil\geo\figs'

import os
import pandas as pd
import numpy as np
import geopandas
import matplotlib.pyplot as plt

Frame = pd.read_csv(ReadPath, sep=';')
Frame = Frame[ Frame['CO_ANO'] == 2012 ]
FrameName = pd.read_csv(MunPath, sep=';', encoding='latin')
FrameName = FrameName.rename(columns={'CO_MUN_GEO': 'CO_MUN'})
Frame = pd.merge( Frame, FrameName, on='CO_MUN', how='left' )
GeoPath = r'C:\Users\wb592068\OneDrive - WBG\Brazil\geo\shp\BR_Municipios_2022\BR_Municipios_2022.shp'

Frame.loc[ (Frame['SG_UF'] == 'SP') , 'CO_MUN'] += 100000  
Frame.loc[ (Frame['SG_UF'] == 'GO') , 'CO_MUN'] -= 100000  
Frame.loc[ (Frame['SG_UF'] == 'DF') , 'CO_MUN'] -= 100000  
Frame.loc[ (Frame['SG_UF'] == 'MS') , 'CO_MUN'] -= 200000  

FrameSum = Frame.groupby(['CO_MUN']).sum()['VL_FOB'].reset_index(drop=False)

PopFrame = pd.read_excel(PopPath, sheet_name='INDEX')

Complete = pd.merge( PopFrame, FrameSum, on='CO_MUN', how='left' )

Complete['VL_FOB'] = Complete['VL_FOB'].fillna(0)
Complete['VL_FOBpc'] = Complete['VL_FOB'] / Complete['POP2012']
Complete['VL_FOBpc'] = Complete['VL_FOBpc'].replace(np.inf, np.nan)
Complete = Complete[ ~Complete['VL_FOBpc'].isna() ]

Complete = Complete.sort_values('VL_FOBpc')
Complete['n'] = [x+1 for x in range(len(Complete))]
Complete['shr'] = Complete['n'] / len(Complete) * 100


fighist = plt.figure(figsize=(15,15))
plt.hist(Complete['VL_FOBpc'].dropna(), bins=100, density=True)
plt.show()


figplot = plt.figure(figsize=(15,15))
ax = plt.gca()
ax.tick_params(axis='both', which='major', labelsize=22)
ax.tick_params(axis='both', which='minor', labelsize=16)
plt.plot(list(Complete['shr']) , list(Complete['VL_FOBpc']), linewidth=3)
plt.xlabel('Share of Brazilian Municipalities', fontsize=22)
plt.ylabel('Exports per person (US$ FOB)', fontsize=22)
plt.title('Brazil: Distribution of Exports per Person, in US$, 2012', fontsize=22)
plt.show()

figscatter = plt.figure(figsize=(15,15))
ax = plt.gca()
ax.tick_params(axis='both', which='major', labelsize=22)
ax.tick_params(axis='both', which='minor', labelsize=16)
plt.scatter(list(Complete['shr']) , list(Complete['VL_FOBpc']), s=Complete['VL_FOB']/10000000)
plt.xlabel('Share of Brazilian Municipalities', fontsize=22)
plt.ylabel('Exports per person (US$ FOB)', fontsize=22)
plt.suptitle('Brazil: Distribution of Exports per Person, 2012', fontsize=32)
plt.title('(In US$, FOB per person; bubbles portional to total municipal exports)', fontsize=22)
plt.show()


Complete.to_csv(r'C:\Users\wb592068\OneDrive - WBG\Brazil\data\trade-processed\munExportsperCapita2012.csv')


Brazil = geopandas.read_file(GeoPath)
Brazil['CO_MUN'] = Brazil.CD_MUN.astype(int)

CompleteMap = pd.merge( Brazil, Complete, on='CO_MUN', how='left' )

CompleteMap['VL_FOBpcCen'] = CompleteMap['VL_FOBpc']
CompleteMap.loc[ (CompleteMap['VL_FOBpc'] >= 2500) , 'VL_FOBpcCen'] = 2500

fig = plt.figure(figsize=(15,15))
axes = fig.add_axes([0, 0, 1, 1])
plt.axis('off')

cax = fig.add_axes([0.9, 0.1, 0.03, 0.8])
sm = plt.cm.ScalarMappable(cmap="YlOrBr", norm=plt.Normalize(vmin = 0, vmax = 2500))
sm._A = []
cax.tick_params(labelsize=22)

fig.colorbar(sm, cax=cax)


mymap = CompleteMap.plot(ax=axes,
                     column='VL_FOBpcCen',
                     linewidth=.1,
                     edgecolor='black',
                     cmap="YlOrBr")

plt.tight_layout()
plt.savefig(os.path.join(OutPath, 'mappc2012.png'))
plt.savefig(os.path.join(OutPath, 'mappc2012.pdf'))
plt.savefig(os.path.join(OutPath, 'mappc2012.eps'))
plt.show()

