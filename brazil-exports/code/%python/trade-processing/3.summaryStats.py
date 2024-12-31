# -*- coding: utf-8 -*-
"""
Created on Thu Jan 11 22:26:45 2024

@author: wb592068
"""

import polars as pl
import os


Path =  r'C:\Users\wb592068\OneDrive - WBG\Brazil\data\trade-processed'
expPathOld = 'EXP_1989-1996.csv'
expPathNew = 'EXP_1997-2023.csv'
impPathOld = 'IMP_1989-1996.csv'
impPathNew = 'IMP_1997-2023.csv'

ncm2HSPath = r'C:\Users\wb592068\OneDrive - WBG\Brazil\conc\ncmhsconc.csv'
ncm2ISICPath = r'C:\Users\wb592068\OneDrive - WBG\Brazil\conc\ncmisicconc.csv'

fredPath = r'C:\Users\wb592068\OneDrive - WBG\Brazil\data\fred\PCE-year.xlsx'

outPath = r'C:\Users\wb592068\OneDrive - WBG\Brazil\data\trade-processed'

########## exports

## import dataframe

FrameNew = pl.read_csv(os.path.join(Path,expPathNew))

## collapse by two-digit industry and state, by year

FrameUFSum = FrameNew.groupby(['CO_ANO','SG_UF_NCM','CO_ISIC_SECAO','CO_ISIC_DIVISAO']).agg( pl.col('VL_FOB').sum() )

concISICFrame = pl.read_csv(ncm2ISICPath, separator=',')
concISICFrame = concISICFrame.groupby(['CO_ISIC_DIVISAO']).agg( pl.col('NO_ISIC_DIVISAO_ING').first() )

FrameUFSum2digit = FrameUFSum.join( concISICFrame , on = 'CO_ISIC_DIVISAO')

FrameUFSum2digit.write_csv(os.path.join(outPath, 'UFISIC2Digit.csv'))
FrameUFSum2digit.write_excel(os.path.join(outPath, 'UFISIC2Digit.xlsx'))

## collapse by one-digit industry and state, by year


concISICFrame = pl.read_csv(ncm2ISICPath, separator=',')
concISICFrame = concISICFrame.groupby(['CO_ISIC_SECAO']).agg( pl.col('NO_ISIC_SECAO_ING').first() )

FrameUFSum1digit = FrameUFSum.join( concISICFrame , on = 'CO_ISIC_SECAO')

FrameUFSum1digit = FrameUFSum1digit.groupby(['CO_ANO','SG_UF_NCM','CO_ISIC_SECAO','NO_ISIC_SECAO_ING']).agg( pl.col('VL_FOB').sum() )

FrameUFSum1digit.write_csv(os.path.join(outPath, 'UFISIC1Digit.csv'))
FrameUFSum1digit.write_excel(os.path.join(outPath, 'UFISIC1Digit.xlsx'))


## collapse by two-digit industry, by year

FrameSum2digit = FrameUFSum2digit.groupby(['CO_ANO','CO_ISIC_DIVISAO','NO_ISIC_DIVISAO_ING']).agg( pl.col('VL_FOB').sum() )

FrameSum2digit.write_csv(os.path.join(outPath, 'ISIC2Digit.csv'))
FrameSum2digit.write_excel(os.path.join(outPath, 'ISIC2Digit.xlsx'))

## collapse by one-digit industry, by year

FrameSum1digit = FrameUFSum1digit.groupby(['CO_ANO','CO_ISIC_SECAO','NO_ISIC_SECAO_ING']).agg( pl.col('VL_FOB').sum() )
FrameSum1digit = FrameSum1digit.sort('CO_ANO', 'NO_ISIC_SECAO_ING')

FrameSum1digit.write_csv(os.path.join(outPath, 'ISIC1Digit.csv'))
FrameSum1digit.write_excel(os.path.join(outPath, 'ISIC1Digit.xlsx'))


#### Transform to real values

fredFrame = pl.read_excel(fredPath, sheet_name='INDEX')
basevalue = fredFrame.filter( pl.col('CO_ANO') == 2022 )['PCE'][0]
fredFrame = fredFrame.with_columns( PCE_base = basevalue ) 
fredFrame = fredFrame.with_columns( adj = pl.col('PCE') / pl.col('PCE_base') )


## collapse by one-digit industry and state, by year, real

FrameUFSum1digitreal = FrameUFSum1digit.join( fredFrame , on = 'CO_ANO')
FrameUFSum1digitreal = FrameUFSum1digitreal.with_columns( VL_FOBr = pl.col('VL_FOB') / pl.col('adj') )
FrameUFSum1digitreal.write_csv(os.path.join(outPath, 'UFISIC1Digitreal.csv'))
FrameUFSum1digitreal.write_excel(os.path.join(outPath, 'UFISIC1Digitreal.xlsx'))

## collapse by one-digit industry, by year, real

FrameSum1digitreal = FrameSum1digit.join( fredFrame , on = 'CO_ANO')
FrameSum1digitreal = FrameSum1digitreal.with_columns( VL_FOBr = pl.col('VL_FOB') / pl.col('adj') )
FrameSum1digitreal.write_csv(os.path.join(outPath, 'ISIC1Digitreal.csv'))
FrameSum1digitreal.write_excel(os.path.join(outPath, 'ISIC1Digitreal.xlsx'))

