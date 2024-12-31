# -*- coding: utf-8 -*-
"""
Created on Sun Jun 13 08:58:11 2021

@author: goes
"""


ReadPath = r'C:\Users\goes\OneDrive - UC San Diego\UCSD\Research\cgoes\auxilio-emergencial\outfiles'

import os
import pandas as pd

Files = []
for root, dirs, files in os.walk(ReadPath, topdown=False):
    for name in files:
          Files.append(os.path.join(root, name))

Complete = pd.DataFrame()
for File in Files[0:-1]:
    Frame = pd.read_csv(File)
    Complete = Complete.append(Frame)

Anual = Complete.groupby(['uf','codigo_ibge','nome_mun']).sum().drop(['mes'], axis=1)
Anual.to_csv(os.path.join(ReadPath,'anual.csv'))