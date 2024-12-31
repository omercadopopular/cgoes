# -*- coding: utf-8 -*-
"""
Created on Thu Dec 19 16:00:40 2024

@author: andre
"""

import pandas as pd
import os

path = '/u/main/tradeadj/lev/temp_files/out'

eu_codes = ['AUT', 'BEL', 'CYP', 'CZE', 'DNK', 'EST', 'FIN', 'FRA', 'DEU', 'GRC', 'HUN', 'IRL', 'ITA', 'LVA', 'LTU', 'LUX', 'MLT', 'NLD', 'POL', 'PRT', 'SVK', 'SVN', 'ESP', 'SWE']

frames = []
varmask = ['importer','exporter','hs6','nomen','year','ahs_st']
for year in range(1995,2018+1):
    print(f'Processing year {year}')
    df = pd.read_stata(os.path.join(path, 'TF' + str(year) + '.dta'))
    
    # restrict variables
    df = df[varmask]
    
    # drop missing
    df = df[ ~df['ahs_st'].isnull() ]
    
    # restrict
    df = df[ df['importer'].isin(eu_codes) & df['exporter'].isin(eu_codes)  ]
    
    # append
    frames.append(df)

frame = pd.concat(frames)
frame.to_stata(os.path.join(path,'fill-eu-bilateral-tariffs.dta'), write_index=False)