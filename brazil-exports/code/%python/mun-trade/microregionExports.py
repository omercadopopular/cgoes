# -*- coding: utf-8 -*-
"""
1/13/24
@author: goes

"""

PopPath = r'C:\Users\wb592068\OneDrive - WBG\Brazil\data\ibge\POP2022_Municipios_20230622.xls'
ReadPath = r'C:\Users\wb592068\OneDrive - WBG\Brazil\data\trade-mdic\EXP_COMPLETA_MUN.csv'
FredPath = r'C:\Users\wb592068\OneDrive - WBG\Brazil\data\fred\PCE-year.xlsx'
MunPath =  r'C:\Users\wb592068\OneDrive - WBG\Brazil\data\trade-mdic\UF_MUN.csv'
ConcPath =  r'C:\Users\wb592068\OneDrive - WBG\Brazil\data\conc\RELATORIO_DTB_BRASIL_MUNICIPIO.xls'
outPath = r'C:\Users\wb592068\OneDrive - WBG\Brazil\data\trade-processed'

## Import packages

import os
import pandas as pd
import polars as pl
import numpy as np
import geopandas
import matplotlib.pyplot as plt

## Read Trade Data
Frame = pd.read_csv(ReadPath, sep=';')

## Read municipality names and codes, merge and make adjustment in coding
FrameName = pd.read_csv(MunPath, sep=';', encoding='latin1') 
FrameName = FrameName.rename(columns={'CO_MUN_GEO': 'CO_MUN'})

Frame = pd.merge(Frame, FrameName  , on='CO_MUN', how='left' )


Frame.loc[ (Frame['SG_UF'] == 'SP') , 'CO_MUN'] += 100000  
Frame.loc[ (Frame['SG_UF'] == 'GO') , 'CO_MUN'] -= 100000  
Frame.loc[ (Frame['SG_UF'] == 'DF') , 'CO_MUN'] -= 100000  
Frame.loc[ (Frame['SG_UF'] == 'MS') , 'CO_MUN'] -= 200000  

## Collapse by municipality
FrameSum = Frame.groupby(['CO_ANO', 'CO_MUN']).sum()['VL_FOB'].reset_index(drop=False)


#### Transform to real values

fredFrame = pd.read_excel(FredPath, sheet_name='INDEX')
basevalue = fredFrame[ fredFrame['CO_ANO'] == 2022 ]['PCE'].iloc[0]
fredFrame['PCE_base'] = basevalue  
fredFrame['adj'] = fredFrame['PCE'] / fredFrame['PCE_base'] 

FrameSum = pd.merge( FrameSum, fredFrame , on = 'CO_ANO', how='left')
FrameSum['VL_FOBr'] = FrameSum['VL_FOB'] / FrameSum['adj']

## Import population data
PopFrame = pd.read_excel(PopPath, sheet_name='INDEX')

Complete = pd.merge( PopFrame, FrameSum, on='CO_MUN', how='left' )
Complete['VL_FOBr'] = Complete['VL_FOBr'].fillna(0)

## Import Microregion code

microConc =  pd.read_excel(ConcPath).rename(
    columns={
        'Nome_Microrregião': 'NO_MR',
               'Código Município Completo': 'CO_MUN',
               'Nome_Município': 'NO_MUN'}
    ) 

microConc['CO_MR'] = [ str(y) + '0' * (2-len(str(x)))  + str(x) for (y,x) in zip(microConc['UF'],microConc['Microrregião Geográfica']) ]


Complete = pd.merge( Complete, microConc[['NO_MR','CO_MR','NO_MUN','CO_MUN']], on='CO_MUN', how='left' )

Complete.to_csv(os.path.join(outPath, 'munTradeExp19972023.csv'), index=False)

## Collapse by microregion

microFrame = Complete.groupby(['CO_ANO', 'NO_MR','CO_MR']).agg({
    'VL_FOBr': 'sum',
    'VL_FOB': 'sum',
    'POP': 'sum',
    'UF': 'first'
    }).reset_index(drop=False)

microFrame['CO_ANO'] = microFrame['CO_ANO'].astype('int')

microFrame.to_csv(os.path.join(outPath, 'microregionTradeExp19972023.csv'), index=False)
