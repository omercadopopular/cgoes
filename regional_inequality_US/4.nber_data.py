# -*- coding: utf-8 -*-
"""
Created on Sun Nov 17 16:23:04 2019

@author: Carlos
"""

def early_transform(DF):
    BLABEL = {1: '$1 under $25,000',
              2: '$25,000 under $50,000',
              3: '$50,000 under $75,000',
              4: '$75,000 under $100,000',
              5: '$100,000 under $200,000',
              6: '$200,000 or more'
                  }

    DF['id'] = [BLABEL[x] for x in DF['id']]
    return DF

def label_transform(DF):
    BLABEL = {'$1 under $25,000': 1,
                  '$25,000 under $50,000': 2,
                  '$50,000 under $75,000': 3,
                  '$75,000 under $100,000': 4,
                  '$100,000 under $200,000': 5,
                  '$200,000 or more': 6
                  }

    BMIN = {'$1 under $25,000': 1,
                  '$10,000 under $25,000': 10000,
                  '$25,000 under $50,000': 25000,
                  '$50,000 under $75,000': 50000,
                  '$75,000 under $100,000': 75000,
                  '$100,000 under $200,000': 100000,
                  '$200,000 or more':200000
                  }        

    BMAX = {'$1 under $25,000': 24999,
                  '$25,000 under $50,000': 49999,
                  '$50,000 under $75,000': 74999,
                  '$75,000 under $100,000': 99999,
                  '$100,000 under $200,000': 199999,
                  '$200,000 or more': 10**16
                  }        
        
    DF['bracket_label'] = [BLABEL[x] for x in DF['id'].astype('str')]
    DF['bracket_min'] = [BMIN[x] for x in DF['id'].astype('str')]
    DF['bracket_max'] = [BMAX[x] for x in DF['id'].astype('str')]
    return DF

def zip_to_county(DF, MAP_FILE):
    import pandas as pd
    ZIPMAP =  pd.read_excel(MAP_FILE, dtype={'zipcode': str, 'county': str})
    JOIN = pd.merge(DF,ZIPMAP, how='left')
    JOIN = JOIN[ ~JOIN['county'].isna() ]
    return JOIN

def cz_consolidation(JOIN, CZFILE):
    DS = pd.read_stata(CZFILE)
    DS['county'] = DS.geofips.astype(int)
    DS = DS.drop('geofips', axis=1)
    
    JOIN['county'] = JOIN['county'].astype(float)

    CZDF = JOIN.merge(DS).groupby(['CZ','bracket_label']).agg({
        'agi': 'sum',
        'returns': 'sum',
        'bracket_min': 'mean',
        'bracket_max': 'mean',
        'year': 'mean',
        'state': 'first'
        })

    return CZDF
    

########

import pandas as pd
import time

FIRST = 2006
LAST = 2016
YEARS = list(range(FIRST, LAST+1))
FOLDER = r'C:\Users\Carlos\OneDrive - UC San Diego\IRS\outfiles'
LINK = 'https://www.nber.org/tax-stats/zipcode/'
MAP_FILE = r'C:\Users\Carlos\OneDrive - UC San Diego\IRS\infiles\HUD_ZIP_COUNTY_092019.xlsx'
CZFILE = r'C:\Users\Carlos\OneDrive - UC San Diego\IRS\outfiles\Reg_Rec_Dorn_Crosswalk_Modified.dta'

DOWNLOAD = True

if DOWNLOAD == True:
    CZDF = pd.DataFrame()
    for YEAR in YEARS:
        print(YEAR)
        URL = LINK + str(YEAR) + '/zipcode' + str(YEAR) + '.dta'
        DF = pd.read_stata(URL)
        
        if YEAR <= 2008:
            DF = DF.rename(columns={'agi_class': 'agi_stub'})
            DF = DF[ DF['agi_stub'] < 7]
            DF['year'] = [YEAR] * DF.shape[0]
            DF = DF[ DF['zipcode'] != 00000]
            DF = DF[ DF['zipcode'] != 99999]
            DF = DF[ ~DF.zipcode.isna() ]
            DF.zipcode = DF.zipcode.astype('int').astype('str')
            DF.zipcode = [('0'*(5-len(x))) + str(x) for x in DF.zipcode]

        else:
            DF = pd.read_stata(URL)
            DF = DF[ DF['zipcode'] != '00000']
            DF = DF[ DF['zipcode'] != '99999']
            DF = DF[ ~DF.zipcode.isna() ]
        
        DF.state = [x.upper() for x in DF.state]
        DF = DF[ ['state','zipcode','agi_stub','n1','a00100', 'year'] ]
        DF = DF.rename(columns={'agi_stub': 'id', 'n1': 'returns', 'a00100': 'agi'})

        if YEAR <= 2008:
            DF = early_transform(DF)

        DF = label_transform(DF)
        JOIN = zip_to_county(DF, MAP_FILE)
        JOIN['year'] = [YEAR] * JOIN.shape[0]
        DFT = cz_consolidation(JOIN, CZFILE)
        CZDF = CZDF.append(DFT)
        time.sleep(1)
    
    frame = CZDF.reset_index().groupby(['CZ','year']).sum().reset_index()
    frame = frame.drop(['bracket_label','bracket_min', 'bracket_max'], axis=1).rename(columns={'agi': 'agi_sum', 'returns': 'returns_sum'})
    CZDF = CZDF.merge(frame, how='left', on=['CZ','year'])
    
    CZDF.to_csv(FOLDER + '\cz_2006-2016.csv', sep=',')

CZDF = pd.read_csv(FOLDER + '\cz_2006-2016.csv', sep=',', index_col=0)
DF = pd.read_csv(FOLDER + '\cz_1998-2005.csv', index_col=0)
TOTAL = DF.append(CZDF)

TOTAL['agi_mean_bracket'] = TOTAL['agi'] * 1000 / TOTAL['returns']
TOTAL.to_csv(FOLDER + '\CZ_DATABASE.csv', sep=',')
TOTAL.to_excel(FOLDER + '\CZ_DATABASE.xlsx')

TOTAL = pd.read_csv(FOLDER + '\CZ_DATABASE.csv', index_col=0)

TOTAL['check'] = (TOTAL['agi_mean_bracket'] < TOTAL['bracket_min']) | (TOTAL['agi_mean_bracket'] > TOTAL['bracket_max'])

for YEAR in set(TOTAL.year):
    print(str(YEAR) + ': ' + str(sum(TOTAL[ TOTAL.year == YEAR ].check) / TOTAL[ TOTAL.year == YEAR ].shape[0]))