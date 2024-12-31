# -*- coding: utf-8 -*-
"""
Created on Thu Jan 11 22:26:45 2024

@author: wb592068
"""

import polars as pl
import os

Path = r'C:\Users\andre\OneDrive\UCSD\Research\cgoes\brazil-exports'
ExpPath = os.path.join(Path, r'data\trade-mdic\EXP_COMPLETA.csv')
ImpPath = os.path.join(Path, r'data\trade-mdic\IMP_COMPLETA.csv')
ncm2HSPath = os.path.join(Path, r'conc\ncmhsconc.csv') 
ncm2ISICPath = os.path.join(Path, r'conc\ncmisicconc.csv')
outPath = os.path.join(Path, r'data\trade-processed') 

########## exports

## import dataframe

Frame = pl.read_csv(ExpPath, separator=';')

## collapse by state, NCM and year

FrameSum = Frame.group_by(['CO_ANO','SG_UF_NCM','CO_PAIS', 'CO_NCM']).agg( pl.col('VL_FOB').sum() )

## import NCM to HS concordance

concHSFrame = pl.read_csv(ncm2HSPath, separator=',')
concHSFrame = concHSFrame[['CO_NCM', 'NO_NCM_POR', 'CO_SH6', 'NO_SH6_POR' ]]

## import ISIC to HS concordance

concISICFrame = pl.read_csv(ncm2ISICPath, separator=',')
concISICFrame  = concISICFrame [['CO_NCM',  'CO_ISIC_CLASSE',  'CO_ISIC_GRUPO',  'CO_ISIC_DIVISAO',  'CO_ISIC_SECAO'] ] 

## merge

FrameSum = FrameSum.join( concHSFrame , on = 'CO_NCM')
FrameSum = FrameSum.join( concISICFrame , on = 'CO_NCM')

## csv exports

FrameSum.write_csv(os.path.join(outPath, 'EXP_1997-2023.csv'))


## define tradeables and nontradeables by state
tradeableFrame = FrameSum.group_by(['CO_ANO', 'SG_UF_NCM',  'CO_ISIC_GRUPO'] ).agg( pl.col('VL_FOB').sum() )
quantileFrame = FrameSum.group_by(['CO_ANO', 'SG_UF_NCM'] ).agg( pl.col('VL_FOB').quantile(0.25).name.suffix('_p25'), pl.col('VL_FOB').quantile(.5).name.suffix('_p50'), pl.col('VL_FOB').quantile(.75).name.suffix('_p75') )
tradeableFrame = tradeableFrame.join( quantileFrame , on = ['CO_ANO', 'SG_UF_NCM'])
tradeableFrame = tradeableFrame.with_columns(
    ( pl.when( pl.col('VL_FOB') < pl.col('VL_FOB_p25') ).then(1).otherwise(0).alias('q1') ),
    ( pl.when( (pl.col('VL_FOB') >= pl.col('VL_FOB_p25')) & (pl.col('VL_FOB') < pl.col('VL_FOB_p50')) ).then(1).otherwise(0).alias('q2') ),
    ( pl.when( (pl.col('VL_FOB') >= pl.col('VL_FOB_p50')) & (pl.col('VL_FOB') < pl.col('VL_FOB_p75')) ).then(1).otherwise(0).alias('q3') ),
    ( pl.when( (pl.col('VL_FOB') >= pl.col('VL_FOB_p75')) ).then(1).otherwise(0).alias('q4') ),
    )[['CO_ANO', 'SG_UF_NCM', 'CO_ISIC_GRUPO', 'q1','q2','q3','q4']]

tradeableFrame.write_csv(os.path.join(outPath, 'EXP_quartiles.csv'))

########## imports

## import dataframe

Frame = pl.read_csv(ImpPath, separator=';')

## collapse by state, NCM and year

FrameSum = Frame.group_by(['CO_ANO','SG_UF_NCM','CO_PAIS', 'CO_NCM']).agg( pl.col('VL_FOB').sum() )

## import NCM to HS concordance

concHSFrame = pl.read_csv(ncm2HSPath, separator=',')
concHSFrame = concHSFrame[['CO_NCM', 'NO_NCM_POR', 'CO_SH6', 'NO_SH6_POR' ]]

## import ISIC to HS concordance

concISICFrame = pl.read_csv(ncm2ISICPath, separator=',')
concISICFrame  = concISICFrame [['CO_NCM',  'CO_ISIC_CLASSE',  'CO_ISIC_GRUPO',  'CO_ISIC_DIVISAO',  'CO_ISIC_SECAO'] ] 

## merge

FrameSum = FrameSum.join( concHSFrame , on = 'CO_NCM')
FrameSum = FrameSum.join( concISICFrame , on = 'CO_NCM')


## csv exports

FrameSum.write_csv(os.path.join(outPath, 'IMP_1997-2023.csv'))

### export 