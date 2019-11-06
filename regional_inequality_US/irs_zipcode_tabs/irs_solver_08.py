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
                'jointreturns',
                'paid_preparer_returns',
                'exemptions',
                'dependentex',
                'agi',
                'wages_value',
                'taxinterest_value',
                'dividends_value',
                'business_value',
                'cgains_value',
                'ira_value',
                'pensions_value',
                'unemployed_value',
                'SSA_value',
                'self_employed_value',
                'itemized_value',
                'statelocalincometax_value',
                'statelocalsalestax_value',
                'realestatetax_value',
                'taxespaid_value',                
                'mortgage_value',
                'contributions_value',
                'taxcredits_value',
                'energycredit_value',
                'childcredit_value',
                'childcare_value',
                'eitc_value',
                'excesseitc_value',
                'minimumtax_value',
                'incometax_value',
                'totaltaxliability_value',
                'taxdue_value',
                'refund_value']
    
    STATE = [FILE.split('.')[0][-2:].upper()]
    
    # return empty dataframe if code identifies excel is aggregate US data
    if STATE == ['US']:
        return pd.DataFrame()
    
    # perform zipcode extraction if state data
    else:   
        #import data
        DF = pd.read_excel(FILE, skiprows=SKIP_ROWS, names=COLNAMES, usecols=range(0,len(COLNAMES)))
        
        ## drop footnotes
        #DF = DF.iloc[:-FOOTNOTES]

        ## drop extra rows
        DF_BRACKETS = DF[ DF.id.notna() ]
            
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
    
FILES = irs_walker('/Users/cbezerra/Documents/IRS/2008/')
NBRACKETS = 7
SKIP_ROWS = 19
FOOTNOTES = 0

import pandas as pd
    
DF = pd.DataFrame()
for file in FILES:
    print(file)
    if file.split('.')[0][-2:].upper() == '':
        TEMP = irs_solver(file, NBRACKETS, SKIP_ROWS, FOOTNOTES-1)
    else:
        TEMP = irs_solver(file, NBRACKETS, SKIP_ROWS, FOOTNOTES)
    DF = DF.append(TEMP)
    
DF.to_csv('/Users/cbezerra/Documents/IRS/2008.csv', sep=',')