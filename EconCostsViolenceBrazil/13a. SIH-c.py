# -*- coding: utf-8 -*-
"""
Created on Thu Apr 19 09:36:06 2018

@author: CarlosABG
"""

import os
import pandas as pd

PATH = r'H:\Notas Conceituais\SegPub-Drogas\Dados\Datasus\sih\results'

class SIHConsolidation:
    
    def walk(path):
        FILES = []
        for root, dirs, files in os.walk(path, topdown=False):
            for name in files:
                if name[-4:] == '.csv':
                  FILES.append(os.path.join(root, name))
        return FILES

    def __init__(self, path):
        files = SIHConsolidation.walk(path)

        df = pd.DataFrame()
        for file in files:
            tdf = pd.read_csv(file)
            df = df.append(tdf)
        
        return tdf