# -*- coding: utf-8 -*-
"""
Created on Mon Nov 25 22:24:05 2019

@author: Carlos
"""

import pandas as pd
import geopandas as gpd
import matplotlib.pyplot as plt
import os

DATAFOLDER = r'C:\Users\cbezerra\Downloads\files\outfiles'
DATAFILE = '\FINALDATABASE.xlsx'
MAPFOLDER = r'C:\Users\cbezerra\Downloads\files\shapefiles'
MAPFILE = '\cz1990.shp'

SFCZ = gpd.read_file(MAPFOLDER + MAPFILE)
DFCZ = pd.read_excel(DATAFOLDER + DATAFILE, index_col=0)

FRAME = DFCZ[ DFCZ.year == 2001][['cz','shock_2001']]
SFCZ = SFCZ.merge(FRAME, how='left', on='cz')

FRAME = DFCZ[ DFCZ.year == 2013][['cz','shock_2013']]
SFCZ = SFCZ.merge(FRAME, how='left', on='cz')

#simplifytolerance = 0.05
#SFCZ.geometry = SFCZ.geometry.simplify(simplifytolerance)
FRAME = SFCZ[ ~SFCZ.shock_2001.isna() ]

fig = plt.figure(figsize=(15,15))
axes = fig.add_axes([0, 0, 1, 1])
axes.axis('off')

    
mymap = FRAME.plot(ax=axes,
                     column='shock_2001',
                     linewidth=1,
                     edgecolor='black',
                     cmap="YlOrBr_r",
                     scheme='quantiles',
                     legend=True,
                     legend_kwds={'loc': 'lower left'})
    
#plt.tight_layout()
plt.show()

fig.savefig(MAPFOLDER + "\\shocks_2002.pdf")
fig.savefig(MAPFOLDER + "\\shocks_2002.svg")
fig.savefig(MAPFOLDER + "\\shocks_2002.png", dpi=600, transparent=False)


FRAME = SFCZ[ ~SFCZ.shock_2013.isna() ]

fig = plt.figure(figsize=(15,15))
axes = fig.add_axes([0, 0, 1, 1])
axes.axis('off')

    
mymap = FRAME.plot(ax=axes,
                     column='shock_2013',
                     linewidth=1,
                     edgecolor='black',
                     cmap="YlOrBr_r",
                     scheme='quantiles',
                     legend=True,
                     legend_kwds={'loc': 'lower left'})
    
#plt.tight_layout()
plt.show()

fig.savefig(MAPFOLDER + "\\shocks_2013.pdf")
fig.savefig(MAPFOLDER + "\\shocks_2013.svg")
fig.savefig(MAPFOLDER + "\\shocks_2013.png", dpi=600, transparent=False)
