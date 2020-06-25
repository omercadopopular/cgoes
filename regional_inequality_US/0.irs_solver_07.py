# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""

def irs_solver(FILE, NBRACKETS, SKIP_ROWS=13, FOOTNOTES=5):

    import pandas as pd    
    
    COLNAMES = ['id',
                'zipcode',
                'returns',
                'exemptions',
                'dependentex',
                'agi',
                'wages_returns',
                'wages_value',
                'taxinterest_returns',
                'taxinterest_value',
                'dividends_returns',
                'dividends_value']
    
    STATE = [FILE.split('.')[0][-2:].upper()]
    
    # return empty dataframe if code identifies excel is aggregate US data
    if STATE == ['US']:
        return pd.DataFrame()
    
    # perform zipcode extraction if state data
    else:   
        #import data
        DF = pd.read_excel(FILE, skiprows=SKIP_ROWS, names=COLNAMES, usecols=range(0,len(COLNAMES)))
        
        ## drop footnotes
#        DF = DF.iloc[:-FOOTNOTES]
        
        DF_BRACKETS = pd.DataFrame(columns=COLNAMES + ['state'])

        #organize brackets
        for i in range(1,NBRACKETS+1):
            TEMP = DF.iloc[0+i :: NBRACKETS + 2, :]
            DF_BRACKETS = DF_BRACKETS.append(TEMP)

        DF_BRACKETS['state'] = STATE * DF_BRACKETS.shape[0]
        DF_BRACKETS = DF_BRACKETS[ DF_BRACKETS.id.notna() ]
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
    
FILES = irs_walker(r'C:\Users\Carlos\OneDrive - UC San Diego\IRS\2007')
NBRACKETS = 7
SKIP_ROWS = 19
FOOTNOTES = 10

import pandas as pd
    
DF = pd.DataFrame()
for file in FILES:
    print(file)
    if file.split('.')[0][-2:].upper() == 'VT':
        TEMP = irs_solver(file, NBRACKETS, SKIP_ROWS, FOOTNOTES-1)
    else:
        TEMP = irs_solver(file, NBRACKETS, SKIP_ROWS, FOOTNOTES)
    DF = DF.append(TEMP)
    
DF.to_csv(r'C:\Users\Carlos\OneDrive - UC San Diego\IRS\infiles\2007.csv', sep=',')