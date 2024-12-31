# -*- coding: utf-8 -*-
"""
Created on Wed Feb  1 23:46:29 2023

@author: wb592068
"""

# Set Paths
path = r'C:\Users\wb592068\OneDrive - WBG\Poverty_DIOT\2 Data\Comtrade\bulk'
comtradeFile = r'C:\Users\wb592068\OneDrive - WBG\Brazil\data\comtrade'

# Import Requirements
import polars as pl
import os
    
# read by chuncks
for year in range(1999,2000):
    print('Processing year {}'.format(year))
    fileName = os.path.join(path, str(year) + '.csv' )
   
    types = {'Commodity Code': str }
   
    columnss = ['Classification',
     'Year',
     'Period',
     'Period Desc.',
     'Aggregate Level',
     'Is Leaf Code',
     'Trade Flow Code',
     'Trade Flow',
     'Reporter',
     'Partner Code',
     'Partner',
     'Partner ISO',
     'Commodity Code',
     'Commodity',
     'Trade Value (US$)']
    yrFrame = pl.read_csv(fileName, dtypes=types, columns=columnss, n_threads=2)
    
    expFrame = yrFrame.filter( (pl.col('Aggregate Level') == 6) & (pl.col('Trade Flow') == 'Export') & (pl.col('Partner Code') == 0)  & (pl.col('Reporter') != 'Brazil'))
    
    totalFrame = expFrame.groupby(['Classification',
     'Year',
     'Period',
     'Period Desc.',
     'Aggregate Level',
     'Is Leaf Code',
     'Trade Flow Code',
     'Trade Flow',
     'Partner Code',
     'Partner',
     'Partner ISO',
     'Commodity Code',
     'Commodity']).agg( pl.col('Trade Value (US$)').sum() ).sort('Commodity Code')

    totalFrame.write_csv(os.path.join(comtradeFile, str(year) + '-hs6.csv'))
