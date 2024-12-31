# -*- coding: utf-8 -*-
"""
Created on Sun Feb 18 21:22:52 2024

@author: wb592068

- merge NCM to ISIC/ concordance
- create tradeShares for each isic sector, by state and year


"""

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
nbm2ncmPath = r'C:\Users\wb592068\OneDrive - WBG\Brazil\conc\nbmncmconc.csv'

fredPath = r'C:\Users\wb592068\OneDrive - WBG\Brazil\data\fred\PCE-year.xlsx'

outPath = r'C:\Users\wb592068\OneDrive - WBG\Brazil\data\trade-processed'

########## exports

## import dataframe

FrameNew = pl.read_csv(os.path.join(Path,expPathNew)).rename({'SG_UF_NCM': 'SG_UF'})
FrameOld = pl.read_csv(os.path.join(Path,expPathOld))

## collapse recent dataset by two-digit industry and state, by year

FrameUFSum = FrameNew.groupby(['CO_ANO','SG_UF','CO_ISIC_SECAO','CO_ISIC_DIVISAO', 'CO_ISIC_GRUPO']).agg( pl.col('VL_FOB').sum() ) 
FrameUFSumOld = FrameOld.groupby(['CO_ANO','SG_UF','CO_ISIC_SECAO','CO_ISIC_DIVISAO', 'CO_ISIC_GRUPO']).agg( pl.col('VL_FOB').sum() )

# Join complete frame
FrameUF = FrameUFSumOld.extend( FrameUFSum  ).sort(['SG_UF','CO_ANO','CO_ISIC_SECAO','CO_ISIC_DIVISAO', 'CO_ISIC_GRUPO'])

#### Transform to real values

fredFrame = pl.read_excel(fredPath, sheet_name='INDEX')
basevalue = fredFrame.filter( pl.col('CO_ANO') == 2022 )['PCE'][0]
fredFrame = fredFrame.with_columns( PCE_base = basevalue ) 
fredFrame = fredFrame.with_columns( adj = pl.col('PCE') / pl.col('PCE_base') )

FrameUF = FrameUF.join( fredFrame , on = 'CO_ANO')
FrameUF = FrameUF.with_columns( VL_FOBr = pl.col('VL_FOB') / pl.col('adj') )

FrameUF = FrameUF.rename({'CO_ANO': 'year',
         'SG_UF': 'UF',
         'CO_ISIC_SECAO': 'isic3code1d',
         'CO_ISIC_DIVISAO': 'isic3code2d',
         'CO_ISIC_GRUPO': 'isic3code3d'})

FrameUF.write_csv(os.path.join(outPath, 'tradeUF19892023-3digit.csv'))

#### Collapse to 2 digits

FrameUF2digits = FrameUF.groupby(['year','UF','isic3code1d','isic3code2d']).agg( [pl.col('VL_FOB').sum(),
                                                                                   pl.col('VL_FOBr').sum()] )


FrameUF2digits = FrameUF2digits.with_columns(pl.col("isic3code2d").cast(str) )

vlist = ['0' * (2-len(x)) + x for x in FrameUF2digits["isic3code2d"]]

FrameUF2digits = FrameUF2digits.drop("isic3code2d").with_columns( [pl.Series("isic3code2d", vlist)] )

FrameUF2digits.write_csv(os.path.join(outPath, 'tradeUF19892023-2digit.csv'))

