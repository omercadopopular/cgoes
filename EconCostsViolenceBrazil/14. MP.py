# -*- coding: utf-8 -*-
"""
Created on Thu Mar 29 16:18:32 2018

@author: CarlosABG
"""

PATH = r'H:\Notas Conceituais\SegPub-Drogas\Dados\MP\Atuacao Funcional'

class MPData:
    
    def walk(self):
        FILES = []
        for root, dirs, files in os.walk(self.path, topdown=False):
            for name in files:
                if name[-4:] == '.csv':
                  FILES.append(os.path.join(root, name))
        return FILES

    def loop(self, path, columns, guns_cid_list):
        self.files = MPData.walk(self.path)
        
        DF = pd.DataFrame()
        for file in FILES:
            tempframe = ChangeSIH.transform(file, columns, guns_cid_list)
            if len(tempframe) > 0:
                DF = DF.append(tempframe)
                

        return DF

    def __init__(self, path):
        self.path = path
        
    