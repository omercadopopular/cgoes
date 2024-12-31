# -*- coding: utf-8 -*-
"""
Created on Sun Feb 18 21:22:52 2024

@author: wb592068

- merge NCM to ISIC/ concordance
- create tradeShares for each isic sector, by state and year


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
nbm2ncmPath = r'C:\Users\wb592068\OneDrive - WBG\Brazil\conc\nbmncmconc.csv'
nbm2ncmPath = r'C:\Users\wb592068\OneDrive - WBG\Brazil\conc\nbmncmconc.csv'

countryPath = r'C:\Users\wb592068\OneDrive - WBG\Brazil\conc\countrycodes.xlsx'

fredPath = r'C:\Users\wb592068\OneDrive - WBG\Brazil\data\fred\PCE-year.xlsx'

outPath = r'C:\Users\wb592068\OneDrive - WBG\Brazil\data\trade-processed'

########## exports

types = {'CO_ISIC_SECAO': str,
         'CO_ISIC_DIVISAO': str,
         'CO_ISIC_GRUPO': str
    }

def addzeros(df, y, dim):
    vlist = ['0' * (dim-len(x)) + x for x in df[y]]
    df = df.drop(y).with_columns( [pl.Series(y, vlist)] )
    return df
    

## import dataframe

FrameNew = pl.read_csv(os.path.join(Path,expPathNew), dtypes=types).rename({'SG_UF_NCM': 'SG_UF'})
FrameNew = addzeros(FrameNew, 'CO_ISIC_DIVISAO', 2)
FrameNew = addzeros(FrameNew, 'CO_ISIC_GRUPO', 3)

FrameOld = pl.read_csv(os.path.join(Path,expPathOld), dtypes=types)
FrameOld = addzeros(FrameOld, 'CO_ISIC_DIVISAO', 2)
FrameOld = addzeros(FrameOld, 'CO_ISIC_GRUPO', 3)

## collapse recent dataset by two-digit industry and destination, by year

FrameDestSum = FrameNew.groupby(['CO_ANO','CO_PAIS','SG_UF','CO_ISIC_SECAO','CO_ISIC_DIVISAO', 'CO_ISIC_GRUPO']).agg( pl.col('VL_FOB').sum() ) 
FrameDestSumOld = FrameOld.groupby(['CO_ANO','CO_PAIS','SG_UF','CO_ISIC_SECAO','CO_ISIC_DIVISAO', 'CO_ISIC_GRUPO']).agg( pl.col('VL_FOB').sum() )

# Join complete frame
FrameDest = FrameDestSumOld.extend( FrameDestSum  ).sort(['SG_UF','CO_ANO','CO_PAIS','CO_ISIC_SECAO','CO_ISIC_DIVISAO', 'CO_ISIC_GRUPO'])

# Import and join country concordance
FrameConc = pl.read_excel(countryPath)[['CO_PAIS', 'CO_PAIS_ISOA3']]
FrameDest = FrameDest.join(FrameConc, on=['CO_PAIS'], how='left')

FrameDest = FrameDest.groupby(['SG_UF','CO_ANO','CO_PAIS_ISOA3','CO_ISIC_SECAO','CO_ISIC_DIVISAO', 'CO_ISIC_GRUPO']).agg( pl.col('VL_FOB').sum() )

#### Transform to real values

fredFrame = pl.read_excel(fredPath, sheet_name='INDEX')
basevalue = fredFrame.filter( pl.col('CO_ANO') == 2022 )['PCE'][0]
fredFrame = fredFrame.with_columns( PCE_base = basevalue ) 
fredFrame = fredFrame.with_columns( adj = pl.col('PCE') / pl.col('PCE_base') )

FrameDest = FrameDest.join( fredFrame , on = 'CO_ANO')
FrameDest = FrameDest.with_columns( VL_FOBr = pl.col('VL_FOB') / pl.col('adj') )

FrameDest = FrameDest.rename({'CO_ANO': 'year',
         'SG_UF': 'UF',
         'CO_PAIS_ISOA3': 'iso3code',
         'CO_ISIC_SECAO': 'isic3code1d',
         'CO_ISIC_DIVISAO': 'isic3code2d',
         'CO_ISIC_GRUPO': 'isic3code3d'})

FrameDest.write_csv(os.path.join(outPath, 'tradeDest19892023-3digit.csv'))

#### Collapse to 2 digits

FrameDest2digits = FrameDest.groupby(['year','UF','iso3code','isic3code1d','isic3code2d']).agg( [pl.col('VL_FOB').sum(),
                                                                                   pl.col('VL_FOBr').sum()] )



FrameDest2digits.write_csv(os.path.join(outPath, 'tradeDest19892023-2digit.csv'))

