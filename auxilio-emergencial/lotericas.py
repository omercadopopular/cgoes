# -*- coding: utf-8 -*-
"""
Created on Sun Jun 13 02:27:14 2021

@author: Carlos
"""

import pandas as pd

Path = r'C:\Users\Carlos\OneDrive - UC San Diego\UCSD\Research\cgoes\auxilio-emergencial\caixa\Loterica.xlsx'
ReadPath = r'C:\Users\Carlos\OneDrive - UC San Diego\UCSD\Research\cgoes\auxilio-emergencial\outfiles\anual.csv'

Frame = pd.read_excel(Path)

cols = { 'UF': 'uf',
        'MUNICÍPIO': 'nome_mun',
        'NOME DO PONTO': 'quant'
        }

Frame = Frame.rename(columns=cols)[cols.values()]

Frame = Frame.groupby(['uf','nome_mun']).count().reset_index(drop=False)

FrameCod = pd.read_csv(ReadPath)

Frame = Frame.merge(FrameCod, on=['uf','nome_mun'], how='right').fillna(0)

Frame.to_csv(r'C:\Users\Carlos\OneDrive - UC San Diego\UCSD\Research\cgoes\auxilio-emergencial\outfiles\anual_loterica.csv')