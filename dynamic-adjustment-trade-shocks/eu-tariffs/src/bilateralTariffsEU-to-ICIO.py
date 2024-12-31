# -*- coding: utf-8 -*-
"""
Created on Thu Dec 19 17:32:51 2024

@author: andre
"""

import pandas as pd
import os
import numpy as np


def harmonizeHS(inFrame, folder):
    
    dtypes = { 'H0': str,	'H1': str,	'H2': str,	'H3': str,	'H4': str,	'H5': str }
    
    correlationsHS = pd.read_excel(os.path.join(folder,'data/icio_concordances/CompleteCorrelationsOfHS-SITC-BEC_20170606.xlsx'), dtype=dtypes)

    outFrame = pd.DataFrame()
    
    vintages = set(inFrame.nomen)
    
    for vintage in vintages:
        
        tempFrame = inFrame[inFrame.nomen == vintage]
        
        if vintage == 'H3':
            tempFrame.loc[:,'hs6_h3'] = [int(x) for x in tempFrame.hs6]
        
        else:
            correlFrame = correlationsHS[[vintage, 'H3']]
            correlFrame = correlFrame.rename(columns={vintage: 'hs6',
                                                      'H3': 'hs6_h3'})
            
            correlFrame = correlFrame.dropna()
            
            # select mode of each ProductCode as H3 code
            correlFrame = correlFrame.groupby('hs6')['hs6_h3'].agg(lambda x: pd.Series.mode(x)[0]).reset_index(drop=False)
            
            tempFrame = pd.merge(tempFrame, correlFrame, how='left', on='hs6')
            
        outFrame = pd.concat((outFrame,tempFrame))
    
    return outFrame

def concIsic():
    dtypes = { 'HS 2007 Product Code': str,
               'ISIC Revision 3 Product Code': str } 

    concFrame = pd.read_csv(os.path.join(folder,'data/icio_concordances/JobID-48_Concordance_H3_to_I3.CSV'), encoding='unicode_escape', dtype=dtypes)
    
    concFrame = concFrame.rename(columns=
                     {'HS 2007 Product Code': 'hs6_h3',
                      'ISIC Revision 3 Product Code': 'Isic3'})
    
    dtypes = { 'Rev31': str,
               'Rev3': str } 

    tempframe31 = pd.read_csv(os.path.join(folder,'data/icio_concordances/ISIC_Rev_31-ISIC_Rev_3_correspondence.txt'), encoding='unicode_escape', dtype=dtypes)
    tempframe31 = tempframe31.rename(columns=
                     {'Rev31': 'Isic31',
                      'Rev3': 'Isic3'})

    # select mode of each Rev3 as Rev31 code
    tempframe31 = tempframe31.groupby('Isic3')['Isic31'].agg(lambda x: pd.Series.mode(x)[0]).reset_index(drop=False)

    concFrame = pd.merge(concFrame, tempframe31[['Isic31','Isic3']], how='left', on='Isic3')

    dtypes = { 'ISIC31code': str,
               'ISIC4code': str } 

    tempframe4 = pd.read_csv(os.path.join(folder,'data/icio_concordances/ISIC31_ISIC4.txt'), encoding='unicode_escape', dtype=dtypes)
    tempframe4 = tempframe4.rename(columns=
                     {'ISIC31code': 'Isic31',
                      'ISIC4code': 'Isic4'})

    # select mode of each Rev3 as Rev31 code
    tempframe4 = tempframe4.groupby('Isic31')['Isic4'].agg(lambda x: pd.Series.mode(x)[0]).reset_index(drop=False)

    concFrame = pd.merge(concFrame, tempframe4[['Isic31','Isic4']], how='left', on='Isic31')

    return concFrame.dropna()[['hs6_h3', 'Isic4']]

def retrieveIcioSector():
    
    # read file
    path = os.path.join(folder,'data/icio_concordances/sectorlist.dta')
    icioFrame = pd.read_stata(path).set_index('code')
    
    # collect isic4 descriptors in a list
    icioFrame = icioFrame[ icioFrame['isic4'] != '' ]
    icioFrame['isic4List'] = [x.split(",") for x in icioFrame['isic4']]
    
    # retrieve labels
    outDict = dict()
    codeDict = pd.io.stata.StataReader(path).value_labels()['code']   
    retrieveCode = lambda value, mydict: list(mydict.keys())[list(mydict.values()).index(value)]
    
    for code in icioFrame.index:
        numCode = retrieveCode(code, codeDict)

        iterList = icioFrame.loc[code, 'isic4List']
        if 'to' in iterList[0]:
            start, end = int(iterList[0][:2]), int(iterList[0][-2:])
            iterList = [str(x) for x in list(range(start, end))]

        for item in iterList:
            item = item.replace(' ', '')
            outDict.update({item: numCode})
    
    return outDict

folder = r'/u/main/tradeadj/lev/'
file = os.path.join(folder, 'temp_files/out/fill-eu-bilateral-tariffs.dta')

# Store dictionaries
dictNomen = {
    'H92': 'H0',
    'H96': 'H1',
    'H02': 'H2',
    'H07': 'H3',
    'H12': 'H4',
    'H17': 'H5'}

# Load file
frame = pd.read_stata(file)

# drop if missing hs or nomen
frame = frame[ ~((frame['hs6'] == '') | (frame['nomen'] == '')) ]

#adjust nomen
frame.loc[:,'nomen'] = [dictNomen[x] for x in frame['nomen']]

# harmonize hs codes
harm_frame = harmonizeHS(frame, folder)

# import isic4 codes and merge
conc_isic = concIsic()
out_frame = pd.merge(harm_frame,conc_isic, how='left', on='hs6_h3')
out_frame = out_frame[~out_frame['Isic4'].isna()]

# merge with icio codes from 2 digit codes
isic_dict = retrieveIcioSector()
out_frame['Isic4_2d'] = [x[0:2] for x in out_frame['Isic4']]
out_frame['icio'] = [isic_dict[x] for x in out_frame['Isic4_2d']]

# icio frame    
icio_frame = out_frame.groupby(['importer','exporter','icio','year']).agg(
        {'ahs_st': 'mean',
         }).reset_index(drop=False)

icio_frame.to_stata(os.path.join(folder, 'temp_files/out/icio_wits_bilateral_eu.dta'), write_index=False)


nms = ['CYP', 'CZE', 'EST', 'HUN', 'LVA', 'LTU', 'MLT', 'POL', 'SVK', 'SVN']
exporter_frame = icio_frame[ icio_frame.exporter.isin(nms) ]
exporter_frame = exporter_frame[ ~exporter_frame.importer.isin(nms) ]
importer_frame = icio_frame[ icio_frame.importer.isin(nms) ]
importer_frame = importer_frame[ ~importer_frame.exporter.isin(nms) ]

import matplotlib.pyplot as plt
import seaborn as sns

fig, axes = plt.subplots(figsize=(12, 6))
sns.boxplot(data=exporter_frame, color='grey', x='year', y='ahs_st', showfliers=False, whis=0)
plt.title('Bilateral tariffs NMS face from EU15')
plt.show()

fig, axes = plt.subplots(figsize=(12, 6))
sns.boxplot(data=importer_frame, color='grey', x='year', y='ahs_st', showfliers=False, whis=0)
plt.title('Bilateral tariffs NMS impose on EU15')
plt.show()
