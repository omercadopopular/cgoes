# -*- coding: utf-8 -*-
"""
Created on Sat Nov 16 14:00:59 2019

@author: Carlos
"""

def destring(DF, COLUMN, YEAR, STRINGS=[' ', '*', ',','-','.','nan']):
    import numpy as np
    import pandas as pd
    
    if float(YEAR) < 2010:
        for STRING in STRINGS:
            DF[COLUMN] = DF[COLUMN].astype('str').str.replace(STRING, '')
        DF[COLUMN] = pd.to_numeric(DF[COLUMN])    

def zip_to_county(FILE, MAP_FILE):
    import pandas as pd
    ZIPMAP =  pd.read_excel(MAP_FILE, dtype={'zipcode': float, 'county': str})
    DF = pd.read_csv(os.path.join(ROOT, FILE), dtype={'zipcode': float}, na_values='.')
#    if type(DF.zipcode.iloc[0] == 'float'):
 #       DF.zipcode = DF.zipcode.astype('int').astype('str')
    JOIN = pd.merge(DF,ZIPMAP, how='inner').drop('Unnamed: 0', axis=1)
    return JOIN    
    
def irs_walker(FOLDER):
        
        import os
        import pandas as pd
        
        # crawl through folder    
        NAMES = []
        for root, dirs, files in os.walk(FOLDER, topdown=False):
            for name in files:
                if name[-3:] == 'csv':
                  NAMES.append(name)
                else:
                    continue
    
        return NAMES, root


#####
        
import os

FOLDER = r'C:\Users\Carlos\OneDrive - UC San Diego\IRS\infiles'
MAP_FILE = r'C:\Users\Carlos\OneDrive - UC San Diego\IRS\infiles\HUD_ZIP_COUNTY_092019.xlsx'
VARS = ['agi','returns']

NAMES, ROOT = irs_walker(FOLDER)

for NAME in NAMES:
    YEAR = NAME.split('.')[0]
    DF = zip_to_county(os.path.join(ROOT, NAME), MAP_FILE)
    for VAR in VARS:
        destring(DF, VAR, YEAR)
    DF.to_csv(os.path.join(r'C:\Users\Carlos\OneDrive - UC San Diego\IRS\outfiles', YEAR + '_zip.csv'), sep=',')
    print(NAME)


