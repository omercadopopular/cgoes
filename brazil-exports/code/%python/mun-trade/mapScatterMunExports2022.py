# -*- coding: utf-8 -*-
"""
1/13/24
@author: goes

"""

PopPath = r'C:\Users\wb592068\OneDrive - WBG\Brazil\data\ibge-pop\POP2022_Municipios_20230622.xls'
ReadPath = r'C:\Users\wb592068\OneDrive - WBG\Brazil\data\trade-mdic\EXP_COMPLETA_MUN.csv'
FredPath = r'C:\Users\wb592068\OneDrive - WBG\Brazil\data\fred\PCE-year.xlsx'
MunPath =  r'C:\Users\wb592068\OneDrive - WBG\Brazil\data\trade-mdic\UF_MUN.csv'
OutPath = r'C:\Users\wb592068\OneDrive - WBG\Brazil\geo\figs'

## Import packages

import os
import pandas as pd
import numpy as np
import geopandas
import matplotlib.pyplot as plt

## Read Trade Data
Frame = pd.read_csv(ReadPath, sep=';')
Frame = Frame[ Frame['CO_ANO'] == 2022 ]

## Read municipality names and codes, merge and make adjustment in coding
FrameName = pd.read_csv(MunPath, sep=';', encoding='latin')
FrameName = FrameName.rename(columns={'CO_MUN_GEO': 'CO_MUN'})
Frame = pd.merge( Frame, FrameName, on='CO_MUN', how='left' )

Frame.loc[ (Frame['SG_UF'] == 'SP') , 'CO_MUN'] += 100000  
Frame.loc[ (Frame['SG_UF'] == 'GO') , 'CO_MUN'] -= 100000  
Frame.loc[ (Frame['SG_UF'] == 'DF') , 'CO_MUN'] -= 100000  
Frame.loc[ (Frame['SG_UF'] == 'MS') , 'CO_MUN'] -= 200000  

## Collapse by municipality
FrameSum = Frame.groupby(['CO_MUN']).sum()['VL_FOB'].reset_index(drop=False)

## Adjust by inflation
PCEFrame = pd.read_excel(FredPath, sheet_name='INDEX')

PCEbase = PCEFrame.loc[ PCEFrame['CO_ANO'] == 2022 , 'PCE' ]
PCEnom = PCEFrame.loc[ PCEFrame['CO_ANO'] == 2022 , 'PCE' ]

adj = float(1 / ( PCEnom.iloc[0] / PCEbase.iloc[0] ))

FrameSum['VL_FOBr'] = FrameSum['VL_FOB'].astype(float) * adj

## Import population data
PopFrame = pd.read_excel(PopPath, sheet_name='INDEX')

Complete = pd.merge( PopFrame, FrameSum, on='CO_MUN', how='left' )

Complete['VL_FOBr'] = Complete['VL_FOBr'].fillna(0)
Complete['VL_FOBrpc'] = Complete['VL_FOBr'] / Complete['POP']
Complete['VL_FOBrpc'] = Complete['VL_FOBrpc'].replace(np.inf, np.nan)
Complete = Complete[ ~Complete['VL_FOBrpc'].isna() ]

Complete = Complete.sort_values('VL_FOBrpc')
Complete['n'] = [x+1 for x in range(len(Complete))]
Complete['shr'] = Complete['n'] / len(Complete) * 100

# Plot Scatter

figscatter = plt.figure(figsize=(15,15))
ax = plt.gca()
ax.tick_params(axis='both', which='major', labelsize=22)
ax.tick_params(axis='both', which='minor', labelsize=16)
plt.scatter(list(Complete['shr']) , list(Complete['VL_FOBrpc']), s=Complete['VL_FOBr']/10000000)
plt.xlabel('Share of Brazilian Municipalities', fontsize=22)
plt.ylabel('Exports per person (US$2022 FOB)', fontsize=22)
#plt.suptitle('Brazil: Distribution of Exports per Person, 2022', fontsize=32)
#plt.title('(In US$2022, FOB per person; bubbles portional to total municipal exports)', fontsize=22)
plt.axhline(0, color='grey')
plt.ylim(-5000,135000)

plt.savefig(os.path.join(OutPath, 'mun_scatter2022.png'))
plt.savefig(os.path.join(OutPath, 'mun_scatter2022.pdf'))
plt.savefig(os.path.join(OutPath, 'mun_scatter2022.eps'))
plt.show()


# Plot Scatter Zoom

figscatter = plt.figure(figsize=(15,15))
ax = plt.gca()
ax.tick_params(axis='both', which='major', labelsize=22)
ax.tick_params(axis='both', which='minor', labelsize=16)
plt.scatter(list(Complete['shr']) , list(Complete['VL_FOBrpc']), s=Complete['VL_FOBr']/10000000)
plt.xlabel('Share of Brazilian Municipalities', fontsize=22)
plt.ylabel('Exports per person (US$2022 FOB)', fontsize=22)
#plt.suptitle('Brazil: Distribution of Exports per Person, 2022', fontsize=32)
#plt.title('(In US$2022, FOB per person; bubbles portional to total municipal exports)', fontsize=22)
plt.axhline(0, color='grey')
plt.ylim(0,10000)

plt.savefig(os.path.join(OutPath, 'mun_scatter2022zoom.png'))
plt.savefig(os.path.join(OutPath, 'mun_scatter2022zoom.pdf'))
plt.savefig(os.path.join(OutPath, 'mun_scatter2022zoom.eps'))
plt.show()


Complete.to_csv(r'C:\Users\wb592068\OneDrive - WBG\Brazil\data\trade-processed\munExportsperCapita2022.csv')

# Plot Map

GeoPath = r'C:\Users\wb592068\OneDrive - WBG\Brazil\geo\shp\BR_Municipios_2022\BR_Municipios_2022.shp'
Brazil = geopandas.read_file(GeoPath)
Brazil['CO_MUN'] = Brazil.CD_MUN.astype(int)

CompleteMap = pd.merge( Brazil, Complete, on='CO_MUN', how='left' )

CompleteMap['VL_FOBrpcCen'] = CompleteMap['VL_FOBrpc']
CompleteMap.loc[ (CompleteMap['VL_FOBrpc'] >= 2500) , 'VL_FOBrpcCen'] = 2500

fig = plt.figure(figsize=(15,15))
axes = fig.add_axes([0, 0, 1, 1])
plt.axis('off')

cax = fig.add_axes([0.9, 0.1, 0.03, 0.8])
sm = plt.cm.ScalarMappable(cmap="YlOrBr", norm=plt.Normalize(vmin = 0, vmax = 2500))
sm._A = []
cax.tick_params(labelsize=22)

fig.colorbar(sm, cax=cax)


mymap = CompleteMap.plot(ax=axes,
                     column='VL_FOBrpcCen',
                     linewidth=.1,
                     edgecolor='black',
                     cmap="YlOrBr")

plt.tight_layout()
plt.savefig(os.path.join(OutPath, 'mun_mappc2022.png'))
plt.savefig(os.path.join(OutPath, 'mun_mappc2022.pdf'))
plt.savefig(os.path.join(OutPath, 'mun_mappc2022.eps'))
plt.show()

