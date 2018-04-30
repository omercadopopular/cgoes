# -*- coding: utf-8 -*-
"""
Created on Tue Mar 27 16:06:26 2018

@author: CarlosABG
"""

import pandas as pd
import os

# FUNCTION   
        
class ChangeSIH:
    
    def walk(path):
        FILES = []
        for root, dirs, files in os.walk(path, topdown=False):
            for name in files:
                if name[-4:] == '.csv':
                  FILES.append(os.path.join(root, name))
        return FILES
        
    def transform(path, cid_list):
        DF = pd.read_csv(path, encoding='latin', low_memory=False)
        
        LIST = [col for col in DF.columns if col.startswith('DIAG')]        
        
        for group in LIST:
            try:
                DF[group] = [str(item) for item in DF[group]]
                vec = []
                for item in DF[group]:
                    if len(item) < 3:
                        vec.append(item)
                    else:
                        vec.append(item[0:3])
                DF['CID_' + group] = vec
            except:
                continue
                
        MASK = [col for col in DF if col.startswith('CID_')]
        DF_MASK = DF[MASK]
        
        DF['CID'] = (DF_MASK[MASK].isin(guns_cid_list).sum(axis=1) > 0)
        
        DF = DF[DF['CID'] == True]
        
        return DF
    
    def loop(path, cid_list):
        FILES = ChangeSIH.walk(path)
        
        DF = pd.DataFrame()
        for file in FILES:
            print('Processando: ' + os.path.basename(file) + '...')
            tempframe = ChangeSIH.transform(file, cid_list)
            if len(tempframe) > 0:
                DF = DF.append(tempframe)
                
        return DF
    
    def consolidate(path):
        files = ChangeSIH.walk(path)

        df = pd.DataFrame()
        for file in files:
            print('Processando: ' + os.path.basename(file) + '...')
            tdf = pd.read_csv(file, sep=";", decimal=",", low_memory=False, encoding='latin1')
            tdf = tdf.groupby('ESTADO').agg({
                    'VAL_TOT': 'sum',
                    'CID': 'count',
                    'ANO_CMPT': 'mean',
                    'IDADE': 'mean'
                    }
                    )
            df = df.append(tdf)        
        return df


METHOD = 'CONSOLIDATE'

if METHOD == 'TRANSFORM':
    PATH = r'H:\Notas Conceituais\SegPub-Drogas\Dados\Datasus\sih\csv 1996-2015\99'
    RESULT = r'H:\Notas Conceituais\SegPub-Drogas\Dados\Datasus\sih\results'    
    CID_SAMPLE = [
            'Y24',
            'W34',
            ] + \
            ['X' + str(i) for i in range(85,100)] + \
            ['Y0' + str(i) for i in range(0,10)]

    DF = ChangeSIH.loop(PATH, CID_SAMPLE)
    DF['ESTADO'] = [int(str(item)[0:2]) for item in DF['UF_ZI']]
    DF.to_csv(RESULT + '\consolidado96.csv', sep=";", decimal=",")
    ESTADOS = DF.groupby('ESTADO').sum()['VAL_TOT']

elif METHOD == 'CONSOLIDATE':
    PATH = r'H:\Notas Conceituais\SegPub-Drogas\Dados\Datasus\sih\results'
    RESULT = r'H:\Notas Conceituais\SegPub-Drogas\Dados\Datasus\sih\results'    
    
    ESTADOS = ChangeSIH.consolidate(PATH)
    BRASIL = ESTADOS.groupby('ANO_CMPT').agg({
            'CID': 'sum',
            'VAL_TOT': 'sum',
            'IDADE': 'mean'
            }).reset_index(drop=False)
    BRASIL.to_csv(RESULT + '\consolidado_nacional.csv', decimal=",", sep=";")

    ESTADOS = ESTADOS.reset_index(drop=False).sort_values(['ANO_CMPT','ESTADO'])
    ESTADOS.to_csv(RESULT + '\consolidado_estadual.csv', decimal=",", sep=";")
    

    