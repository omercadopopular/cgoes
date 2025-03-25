# -*- coding: utf-8 -*-
"""
Created on Tue Dec 10 11:26:46 2024

@author: andre
"""

"""

Column	Content	Start position	Options1

Type of information in the line	1	1: First line of name
2: Second line of name
*: Comment line
2

Level of aggregation	4	Highest level of aggregation is 1 and lowest 9.
3

Name of the UCC	7	
4

UCC lists the identifier of the UCC	70	
5

Source or purpose of the UCC	83	I: Interview survey
D: Diary survey
G and T: Titles
S: Statistical UCCs
6

Factor by which the mean has to be multiplied to match the annualized data in the published tables	86	1: Multiply times 1
4: Multiply times 4
7

Data sections	89	CUCHARS: CU characteristics
FOOD: Food expenditures
EXPEND: Non-food expenditures
INCOME: Income types
ASSETS: Asset types
ADDENDA: Other financial information and gifts


"""

cols = {'line': "line sequence of the item (1 for first, etc)",
        'agg': "level of aggregation",
        'ucc_desc': "name/description of ucc",
        'ucc': "ucc code",
        'source': "source of information",
        'annual_factor': "factor for annualization",
        'section': "data sections"        
        }

path = r'C:\Users\andre\OneDrive\UCSD\Research\cgoes\inflation-trump\data\cex\stubs'
file = 'CE-HG-Inter-2020.txt'
concpath = r'C:\Users\andre\OneDrive\UCSD\Research\cgoes\inflation-trump\conc\cex'
concfile = 'ce-cpi-concordance-2020.xlsx'

import pandas as pd
import os

# import base frame
df = pd.read_fwf(os.path.join(path,file), header=1, names=cols.keys())
df = df[df['line'] == 1]

# import concordance frame and make adjustments
concdf = pd.read_excel(  os.path.join(concpath, concfile), skiprows=1, skipfooter=3)
concdf.columns = [x.lower() for x in concdf.columns]
uccadj = lambda x: '0' * (6-len(str(x))) + str(x)
concdf.loc[:,'ucc'] = [uccadj(x) for x in concdf.loc[:,'ucc']]

# merge frame where concordance uccs are present
df = df.merge(concdf, how='left', on='ucc')

# check the missing concordances
dfna = df[ df['eli'].isna() ]
