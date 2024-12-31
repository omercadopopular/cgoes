# -*- coding: utf-8 -*-
"""
Created on Sun Dec  8 13:21:38 2024

@author: andre
"""

import pandas as pd
import numpy as np
import os

Path = r'C:\Users\andre\OneDrive\UCSD\Research\cgoes\dynamic-adjustment-trade-shocks\eu-tariffs\trottner\temp_files\out'
baseFile = r'full_ARG.csv'
fillFile = r'fill_full_ARG.csv'

fill_rename = {
        'Reporter': 'importer',
        'Partner': 'exporter',
        'Product': 'hs6',
        'PRF_post': 'prf_st',
        'MFN_post': 'mfn_st',
        'PRF_pre': 'prf_pre',
        'MFN_pre': 'mfn_pre',
        }

fillFrame = pd.read_csv(os.path.join(Path, fillFile), dtype={"Product": str}).rename(columns=fill_rename)
fillFrame = fillFrame.sort_values(['importer','exporter','hs6','year'])
hsString = lambda x: '0'*(6-len(str(x))) + str(x)
fillFrame.loc[:,'hs6'] = [hsString(y) for y in fillFrame.loc[:,'hs6']]

fillFrame.loc[:,'ahs_st'] = np.nanmin([fillFrame.loc[:,'prf_st'],fillFrame.loc[:,'mfn_st']], axis=0)
fillFrame.loc[:,'ahs_pre'] = np.nanmin([fillFrame.loc[:,'prf_pre'],fillFrame.loc[:,'mfn_pre']], axis=0)


baseFrame = pd.read_csv(os.path.join(Path, baseFile), dtype={"hs6": str}, low_memory=False)
baseFrame.loc[:,'hs6'] = [hsString(y) for y in baseFrame.loc[:,'hs6']]

def dropDups(frame, subset=['importer','exporter','hs6','year']):
    dup = frame.duplicated(subset=subset, keep='first')
    return frame[~dup]

baseFrame = dropDups(baseFrame)
fillFrame = dropDups(fillFrame)

mergeFrame = baseFrame.merge(fillFrame, how='left', on=['importer','exporter','hs6','year'], suffixes=['_old', ''], indicator=True, validate='one_to_one')
fillFiltered = mergeFrame.dropna(subset=['ahs_st'])

avgprf = fillFiltered.groupby(['exporter','importer','year']).agg( { 'prf_st': 'mean',  'prf_pre': 'mean'} )
avgprf['diff'] = avgprf['prf_pre'] - avgprf['prf_st'] 

avgmfn = fillFiltered.groupby(['exporter','importer','year']).agg( { 'mfn_st': 'mean',  'mfn_pre': 'mean'} )

avgahs = fillFiltered.groupby(['exporter','importer','year']).agg( { 'ahs_st': 'mean',  'ahs_pre': 'mean'} )
avgahs['diff'] = avgahs['ahs_pre'] - avgahs['ahs_st'] 
miniframe = avgahs[(avgahs['diff'] != 0) & (~avgahs['diff'].isna())]

avgahs.loc[avgahs['diff'] != 0,'diff'].dropna().hist(density=True)

