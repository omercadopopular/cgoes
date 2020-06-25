# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""

def irs_solver(FILE, NBRACKETS, SKIP_ROWS=13, FOOTNOTES=1):

    import pandas as pd    
    
    COLNAMES = ['id',
                'returns',
                'exemptions',
                'dependentex',
                'agi',
                'wages_returns',
                'wages_income',
                'taxinterest_returns',
                'taxinterest_income',
                'totaltax_returns',
                'totaltax_income',
                'contributions_returns',
                'contributions_income',
                'schedule_c_returns',
                'schedule_f_returns',
                'schedule_a_returns']
    
    STATE = [FILE.split('.')[0][-2:].upper()]
    
    # return empty dataframe if code identifies excel is aggregate US data
    if STATE == ['US']:
        return pd.DataFrame()
    
    # perform zipcode extraction if state data
    else:   
        #import data
        DF = pd.read_excel(FILE, skiprows=SKIP_ROWS, names=COLNAMES, usecols=range(0,len(COLNAMES)))
        
        ## drop footnotes
        DF = DF.iloc[:-FOOTNOTES]
        
        ## select zipcodes
        ZIPCODES = list(DF.iloc[0 :: NBRACKETS + 2, :].id)
        ZIPCODES = [str(i).replace(' ','') for i in ZIPCODES]
        
        #organize brackets
        DF_BRACKETS = pd.DataFrame(columns=COLNAMES + ['zipcode', 'state'])
        
        for i in range(1,NBRACKETS+1):
            TEMP = DF.iloc[0+i :: NBRACKETS + 2, :]
            TEMP['zipcode'] = ZIPCODES
            TEMP['state'] = STATE * len(ZIPCODES)
            DF_BRACKETS = DF_BRACKETS.append(TEMP)
            
        DF_BRACKETS = DF_BRACKETS.sort_values(by=['zipcode','id'])
        
        return DF_BRACKETS
        
def irs_walker(FOLDER):
        
        import os
        
        # crawl through folder    
        FILES = []
        for root, dirs, files in os.walk(FOLDER, topdown=False):
            for name in files:
                if name[-3:] == 'xls' or name[-4:] == 'xlsx':
                  FILES.append(os.path.join(root, name))
                else:
                    continue
    
        return FILES

####
    
FILES = irs_walker('/Users/cbezerra/Documents/IRS/2002/')
NBRACKETS = 4
SKIP_ROWS = 13
FOOTNOTES = 1

import pandas as pd
    
DF = pd.DataFrame()
for file in FILES:
    print(file)
    if file.split('.')[0][-2:].upper() == 'DE':
        TEMP = irs_solver(file, NBRACKETS, SKIP_ROWS, FOOTNOTES-1)
    else:
        TEMP = irs_solver(file, NBRACKETS, SKIP_ROWS, FOOTNOTES)
    DF = DF.append(TEMP)

DF.to_csv('/Users/cbezerra/Documents/IRS/2002.csv', sep=',')