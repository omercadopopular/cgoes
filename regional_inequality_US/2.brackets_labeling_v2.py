# -*- coding: utf-8 -*-
"""
Created on Sun Nov 17 01:26:11 2019

@author: Carlos
"""
def irs_walker(FOLDER):        
        import os
        
        # crawl through folder    
        NAMES = []
        for root, dirs, files in os.walk(FOLDER, topdown=False):
            for name in files:
                if name[-7:] == 'zip.csv':
                  NAMES.append(name)
                else:
                    continue
    
        return NAMES, root

def label_transform(DF, YEAR, LEN):
    DF['year'] = [YEAR] * LEN
    
    if (float(YEAR) >= 1998) & (float(YEAR) <= 2002):
        BLABEL = {'Under $10,000': 1,
                  '$10,000 under $25,000': 2,
                  '$25,000 under $50,000': 3,
                  '$50,000 or more': 4
                  }

        BMIN = {'Under $10,000': 0,
                  '$10,000 under $25,000': 10000,
                  '$25,000 under $50,000': 25000,
                  '$50,000 or more': 50000
                  }        

        BMAX = {'Under $10,000': 9999,
                  '$10,000 under $25,000': 24999,
                  '$25,000 under $50,000': 49999,
                  '$50,000 or more': 10**16
                  }        

        DF['id'] = DF['id'].str.strip().replace('10,000 under $25,000', '$10,000 under $25,000')
        
        DF['bracket_label'] = [BLABEL[x] for x in DF['id'].str.strip()]
        DF['bracket_min'] = [BMIN[x] for x in DF['id'].str.strip()]
        DF['bracket_max'] = [BMAX[x] for x in DF['id'].str.strip()]
        return DF

    elif (float(YEAR) >= 2003) & (float(YEAR) <= 2005):
        BLABEL = {'Under $10,000': 1,
                  '$10,000 under $25,000': 2,
                  '$25,000 under $50,000': 3,
                  '$50,000 under $75,000': 4,
                  '$75,000 under $100,000': 5,
                  '$100,000 or more': 6
                  }

        BMIN = {'Under $10,000': 0,
                  '$10,000 under $25,000': 10000,
                  '$25,000 under $50,000': 25000,
                  '$50,000 under $75,000': 50000,
                  '$75,000 under $100,000': 75000,
                  '$100,000 or more': 100000
                  }        

        BMAX = {'Under $10,000': 9999,
                  '$10,000 under $25,000': 24999,
                  '$25,000 under $50,000': 49999,
                  '$50,000 under $75,000': 74999,
                  '$75,000 under $100,000': 99999,
                  '$100,000 or more': 199999
                  }        

        DF['id'] = DF['id'].str.strip().replace('$75,000 under $100,00', '$75,000 under $100,000')
        
        DF['bracket_label'] = [BLABEL[x] for x in DF['id']]
        DF['bracket_min'] = [BMIN[x] for x in DF['id']]
        DF['bracket_max'] = [BMAX[x] for x in DF['id']]
        return DF

    elif (float(YEAR) >= 2006) & (float(YEAR) <= 2008):
        BLABEL = {'Under $10,000': 1,
                  '$10,000 under $25,000': 2,
                  '$25,000 under $50,000': 3,
                  '$50,000 under $75,000': 4,
                  '$75,000 under $100,000': 5,
                  '$100,000 under $200,000': 6,
                  '$200,000 or more': 7
                  }

        BMIN = {'Under $10,000': 0,
                  '$10,000 under $25,000': 10000,
                  '$25,000 under $50,000': 25000,
                  '$50,000 under $75,000': 50000,
                  '$75,000 under $100,000': 75000,
                  '$100,000 under $200,000': 100000,
                  '$200,000 or more':200000
                  }        

        BMAX = {'Under $10,000': 9999,
                  '$10,000 under $25,000': 24999,
                  '$25,000 under $50,000': 49999,
                  '$50,000 under $75,000': 74999,
                  '$75,000 under $100,000': 99999,
                  '$100,000 under $200,000': 199999,
                  '$200,000 or more': 10**16
                  }        
        
        DF['id'] = DF['id'].str.strip().replace('$75,000 under $100,00', '$75,000 under $100,000')

        DF['bracket_label'] = [BLABEL[x] for x in DF['id']]
        DF['bracket_min'] = [BMIN[x] for x in DF['id']]
        DF['bracket_max'] = [BMAX[x] for x in DF['id']]
        return DF

#####
        
import os
import pandas as pd

FOLDER = r'C:\Users\Carlos\OneDrive - UC San Diego\IRS\outfiles'

NAMES, ROOT = irs_walker(FOLDER)

for NAME in NAMES:
    print(NAME)
    YEAR = NAME.split('_')[0]
    DF = pd.read_csv(os.path.join(ROOT, NAME), index_col=0)
    LEN = DF.shape[0]
    DF = label_transform(DF, YEAR, LEN)
    DF.to_csv(os.path.join(r'C:\Users\Carlos\OneDrive - UC San Diego\IRS\outfiles', YEAR + 'zip_final.csv'), sep=',')

