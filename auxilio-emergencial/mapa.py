# -*- coding: utf-8 -*-
"""
Created on Sun Jun 13 09:53:09 2021

@author: goes
"""

GeoPath = r'C:\Users\Carlos\OneDrive - UC San Diego\Globo\censo-bonus-imigracao\BR_Municipios_2021\BR_Municipios_2021.shp'
ReadPath = r'C:\Users\Carlos\OneDrive - UC San Diego\Globo\censo-bonus-imigracao\dados-censo.xlsx'

Path = r''

import pandas as pd
import geopandas
import matplotlib.pyplot as plt

cols = { 'CD_MUN': 'codigo_ibge',
        'NM_MUN': 'nome_mun_ac',
        'SIGLA': 'uf',
        'AREA_KM2': 'area'
        }

Brazil = geopandas.read_file(GeoPath, dtype={'CD_MUN': int})
Brazil = Brazil.rename(columns=cols)
Brazil.codigo_ibge = pd.to_numeric(Brazil.codigo_ibge)

Frame = pd.read_excel(ReadPath)

Complete = Brazil.merge(Frame, on=['codigo_ibge','uf'])

fig = plt.figure(figsize=(15,15))
axes = fig.add_axes([0, 0, 1, 1])
axes.axis('off')

mymap = Complete.plot(ax=axes,
                     column='var',
                     linewidth=0.1,
                     edgecolor='black',
                     cmap="seismic_r",
                     vmin = -20,
                     vmax = 20)

plt.title('Variação Percentual na População do Município (2010-2022)', fontsize=25)  

#cax = fig.add_axes([0.9, 0.1, 0.03, 0.8])
#sm = plt.cm.ScalarMappable(cmap="seismic_r", norm=plt.Normalize(vmin = -20, vmax = 20))
#sm._A = []
#fig.colorbar(sm, cax=cax)
plt.tight_layout()

    
plt.show()

fig.savefig(r'C:\Users\Carlos\OneDrive - UC San Diego\Globo\censo-bonus-imigracao\mapa.pdf')
