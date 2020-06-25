# -*- coding: utf-8 -*-
"""
Spyder Editor

Este é um arquivo de script temporário.
"""

import pandas as pd

### USER INPUTS

FOLDER = r'C:\Users\Carlos\OneDrive - UC San Diego\IRS\outfiles'
SHOCKSFILE = '\CZ_DATABASE_SHOCKS.xlsx'
BEAFILE = '\CZ_masterfile.dta'

FIRST_YEAR = 1995
LAST_YEAR = 2018

RESPONSE_VARS = ['EMPLOYMENTPOPRATIO']

DF = pd.read_excel(FOLDER + SHOCKSFILE, index_col=0)
DF['avg_initial_income'] = DF.agi_sum / DF.returns_sum * 1000
DF.Tax_shock = DF.Tax_shock*100
DFCZ = DF.groupby(['CZ','year']).first()[['Tax_shock','avg_initial_income']].reset_index()

DFSHOCKS = pd.DataFrame()
DFSHOCKS['CZ'] = DFCZ.groupby('CZ').first().reset_index().CZ
for YEAR in set(DFCZ.year):
    FRAME = DFCZ[ DFCZ.year == YEAR ][['CZ','Tax_shock','avg_initial_income']]
    FRAME = FRAME.rename(columns={'Tax_shock': 'shock_' + str(YEAR),
                                  'avg_initial_income': 'avg_initial_income_' + str(YEAR)})
    DFSHOCKS = pd.merge(DFSHOCKS, FRAME, on='CZ', how='left')
       
DFBEA = pd.read_stata(FOLDER + BEAFILE)

DFBEA = DFBEA[[
         'Year',
         'CZ',
   #      'PInc',
         'Pop',
         'Pinc',
         'NfarmPinc',
         'FarmInc',
         'Earnings_work',
         'Employment',
         'EmploymentPopRatio',
         'statefip',
         'SNAP'
         ]]

DFWORK = pd.merge(DFBEA[ DFBEA.Year >= FIRST_YEAR ], DFSHOCKS, on='CZ', how='left')
DFWORK.columns = [x.lower() for x in list(DFWORK.columns)]

DFWORK.to_excel(FOLDER + '\FINALDATABASE.xlsx')