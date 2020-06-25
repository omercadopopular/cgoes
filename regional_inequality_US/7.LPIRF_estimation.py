# -*- coding: utf-8 -*-
"""
Created on Fri Nov 22 23:34:20 2019

@author: Carlos
"""

import pandas as pd
import matplotlib.pyplot as plt
from scipy import stats
import statsmodels.formula.api as smf

FOLDER = r'C:\Users\Carlos\OneDrive - UC San Diego\IRS\outfiles'
FILE = '\FINALDATABASE.xlsx'

SHOCK_YEARS = [1998, 2001, 2002, 2004, 2005, 2006, 2007,2008,2009,2010,2011,2012,2013]
RESPONSE_VARS = ['employmentpopratio']

DF = pd.read_excel(FOLDER + FILE, index_col=0)

def generate_vars(DF,RESPONSE_VARS,SHOCK_YEARS,PANEL_ID='cz',YEAR_ID='year',PREFIX='shock_'):
    for RESPONSE in RESPONSE_VARS:
        for YEAR in SHOCK_YEARS:
            TEMP = DF[ DF[YEAR_ID] == YEAR ][[PANEL_ID,RESPONSE]]
            TEMP = TEMP.rename(columns={RESPONSE: 'd' + RESPONSE + '_' + str(YEAR)})
            DF = pd.merge(DF, TEMP, on='cz', how='left')
            DF['d' + RESPONSE + '_' + str(YEAR)] = (DF[RESPONSE]/DF['d' + RESPONSE + '_' + str(YEAR)]-1)*100
    return DF

DF = generate_vars(DF, RESPONSE_VARS, SHOCK_YEARS)
DF['fcrisis'] = DF['year'] >= 2009 
DF.to_excel(FOLDER + '\FINALDATABASE_VARS.xlsx')

def irf(DF, RESPONSE_VARS, SHOCK_YEARS, PANEL_ID='cz',YEAR_ID='year',PREFIX='shock_'):
    import pandas as pd
    import numpy as np
    
    RESULTS = pd.DataFrame()
    for SHOCK in SHOCK_YEARS:
        for RESPONSE in RESPONSE_VARS:
            BETAS = []
            INTERCEPTS = []
            SE = []
            for YEAR in set(DF.year):
                try:
                    results = smf.ols(
                        ('d' + str(RESPONSE) + '_' + str(SHOCK) +
                                ' ~ 1 + shock_' + str(SHOCK) +
                                ' + avg_initial_income_' + str(SHOCK) +
                                ' + fcrisis'),
                                data=DF[DF[YEAR_ID] == YEAR]).fit()
                    INTERCEPTS.append(results.params[0])
                    BETAS.append(results.params[1])
                    SE.append(results.bse[1])
                except:
                    BETAS.append(np.nan)
                    SE.append(np.nan)
            BETAS = [np.nan] * (len(set(DF.year)) - len(BETAS)) + BETAS
            SE = [np.nan] * (len(set(DF.year)) - len(SE)) + SE
            RESULTS[str(RESPONSE) + str(SHOCK) + '_b'] = BETAS
            RESULTS[str(RESPONSE) + str(SHOCK) + '_se'] = SE
    RESULTS['year'] = set(DF.year)
    return RESULTS

RESULTS = irf(DF, RESPONSE_VARS, SHOCK_YEARS)
RESULTS.to_excel(FOLDER + '/resultscrisis.xls')
