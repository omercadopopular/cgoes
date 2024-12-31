# -*- coding: utf-8 -*-
"""
Created on Sun Jun 13 09:53:09 2021

@author: goes

"""

GeoPath = r'C:\Users\wb592068\OneDrive - WBG\Brazil\geo\shp\BR_Municipios_2022\BR_Municipios_2022.shp'
ReadPath = r'C:\Users\wb592068\OneDrive - WBG\Brazil\data\trade-mdic\EXP_COMPLETA_MUN.csv'
MunPath =  r'C:\Users\wb592068\OneDrive - WBG\Brazil\data\trade-mdic\UF_MUN.csv'
OutPath = r'C:\Users\wb592068\OneDrive - WBG\Brazil\geo\figs'

import os
import pandas as pd
import geopandas
import matplotlib.pyplot as plt

Frame = pd.read_csv(ReadPath, sep=';')
Frame = Frame[ Frame['CO_ANO'] == 2022 ]
FrameName = pd.read_csv(MunPath, sep=';', encoding='latin')
FrameName = FrameName.rename(columns={'CO_MUN_GEO': 'CO_MUN'})
Frame = pd.merge( Frame, FrameName, on='CO_MUN', how='left' )

Frame.loc[ (Frame['SG_UF'] == 'SP') , 'CO_MUN'] += 100000  
Frame.loc[ (Frame['SG_UF'] == 'GO') , 'CO_MUN'] -= 100000  
Frame.loc[ (Frame['SG_UF'] == 'DF') , 'CO_MUN'] -= 100000  
Frame.loc[ (Frame['SG_UF'] == 'MS') , 'CO_MUN'] -= 200000  

FrameSum = Frame.groupby(['CO_MUN']).sum()['VL_FOB'].reset_index(drop=False)
FrameSum['VL_FOB'] /= 1000000 
#FrameSum = FrameSum.rename(columns={'CO_MUN': 'CD_MUN'})

Brazil = geopandas.read_file(GeoPath)
Brazil['CO_MUN'] = Brazil.CD_MUN.astype(int)

Complete = pd.merge( Brazil, FrameSum, on='CO_MUN', how='left' )

fig = plt.figure(figsize=(15,15))
axes = fig.add_axes([0, 0, 1, 1])
axes.axis('off')

mymap = Complete.plot(ax=axes,
                     column='VL_FOB',
                     scheme='QUANTILES',
                     linewidth=.5,
                     edgecolor='black',
                     cmap="YlOrBr",
                     legend=True,
                     legend_kwds={'loc': 'center right',
                                  'bbox_to_anchor':(0.5,0),
                                  'fmt':'{:.1f}',
                                  'interval': True,
                                  'fontsize': 25})

plt.tight_layout()
plt.savefig(os.path.join(OutPath, 'map.png'))
plt.savefig(os.path.join(OutPath, 'map.pdf'))
plt.savefig(os.path.join(OutPath, 'map.eps'))
plt.show()


FrameSum.to_csv()