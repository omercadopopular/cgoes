# -*- coding: utf-8 -*-
"""
Created on Thu Jan 11 22:26:45 2024

@author: wb592068
"""

import pandas as pd
import os

inPath = r'C:\Users\wb592068\OneDrive - WBG\Brazil\data\trade-mdic'
outPath = r'C:\Users\wb592068\OneDrive - WBG\Brazil\data\trade-processed'
ncm2HSPath = r'C:\Users\wb592068\OneDrive - WBG\Brazil\conc\ncmhsconc.csv'
ncm2ISICPath = r'C:\Users\wb592068\OneDrive - WBG\Brazil\conc\ncmisicconc.csv'

firstYear = 1989
lastYear = 1996

## import concordance dataframe

concFrame = pd.read_csv(os.path.join(inPath, 'NBM_NCM.csv'), sep=';')

## iterate over imports

importsFrame = pd.DataFrame()
for year in range(firstYear, lastYear + 1):
    print('Processing year {}...'.format(year))

    yearFrame = pd.read_csv(os.path.join(inPath, 'IMP_' + str(year) + '_NBM.csv'), sep=';')
    yearFrame = pd.merge( yearFrame, concFrame, on='CO_NBM', how='left' )
    
    importsFrame = pd.concat([importsFrame,yearFrame] )

## import NCM to HS concordance

concHSFrame = pd.read_csv(ncm2HSPath, sep=',')
concHSFrame = concHSFrame[['CO_NCM', 'NO_NCM_POR', 'CO_SH6', 'NO_SH6_POR' ]]

## import ISIC to HS concordance

concISICFrame = pd.read_csv(ncm2ISICPath, sep=',')
concISICFrame  = concISICFrame [['CO_NCM',  'CO_ISIC_CLASSE',  'CO_ISIC_GRUPO',  'CO_ISIC_DIVISAO',  'CO_ISIC_SECAO'] ] 

## merge

importsFrame = pd.merge( importsFrame, concHSFrame , on = 'CO_NCM', how='left')
importsFrame = pd.merge( importsFrame, concISICFrame , on = 'CO_NCM', how='left')
    

importsFrame.reset_index(drop=True).to_csv( os.path.join(outPath, 'IMP_1989-1996.csv') )

## iterate over exports

exportsFrame = pd.DataFrame()
for year in range(firstYear, lastYear + 1):
    print('Processing year {}...'.format(year))

    yearFrame = pd.read_csv(os.path.join(inPath, 'EXP_' + str(year) + '_NBM.csv'), sep=';')
    yearFrame = pd.merge( yearFrame, concFrame, on='CO_NBM', how='left' )
    
    exportsFrame = pd.concat([exportsFrame,yearFrame] )
    
## import NCM to HS concordance

concHSFrame = pd.read_csv(ncm2HSPath, sep=',')
concHSFrame = concHSFrame[['CO_NCM', 'NO_NCM_POR', 'CO_SH6', 'NO_SH6_POR' ]]

## import ISIC to HS concordance

concISICFrame = pd.read_csv(ncm2ISICPath, sep=',')
concISICFrame  = concISICFrame [['CO_NCM',  'CO_ISIC_CLASSE',  'CO_ISIC_GRUPO',  'CO_ISIC_DIVISAO',  'CO_ISIC_SECAO'] ] 

## merge

exportsFrame = pd.merge( exportsFrame, concHSFrame , on = 'CO_NCM', how='left')
exportsFrame = pd.merge( exportsFrame, concISICFrame , on = 'CO_NCM', how='left')


exportsFrame.reset_index(drop=True).to_csv( os.path.join(outPath, 'EXP_1989-1996.csv') )
