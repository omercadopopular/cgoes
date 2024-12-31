# -*- coding: utf-8 -*-
"""
Created on Wed Feb  1 23:46:29 2023

@author: wb592068
"""

import pandas as pd
import os

class comtrade:

# Import Requirements
   
    def __init__(self, readComtrade, outPath):
        self.readComtrade, self.outPath = readComtrade, outPath
    
    def process(self):
        readComtrade, outPath = self.readComtrade, self.outPath

        isoCodes = ['CYP', 'CZE', 'EST', 'HUN', 'LVA', 'LTU', 'MLT', 'POL', 'SVK', 'SVN']
        eu15Codes = ['AUT', 'BEL', 'DNK', 'FIN', 'FRA', 'DEU', 'GRC', 'IRL', 'ITA', 'LUX', 'NLD', 'PRT', 'ESP', 'SWE', 'GBR']
        baseYear = 1995
        
        for partner in isoCodes:
            fileName = os.path.join(readComtrade, str(baseYear) + '.csv' )
            cSize = 10 ** 10
            
            egyFrame = pd.DataFrame()  
            for chunk in pd.read_csv(fileName, chunksize = cSize):
                Frame = chunk[ (chunk['Reporter ISO'].isin(eu15Codes) ) & (chunk['Partner ISO'] == partner) ]
                egyFrame = pd.concat([egyFrame, Frame])
            egyFrame.to_csv(os.path.join(outPath, str(partner) + str(baseYear) + '.csv'))
        
        for partner in isoCodes:
            frame = pd.read_csv(os.path.join(outPath, str(partner) + str(baseYear) + '.csv'))
            frame = frame[ frame['Aggregate Level'] == 6 ]
            consolidatedFrame = frame.groupby(['Partner ISO', 'Commodity Code', 'Commodity']).agg( {'Netweight (kg)': 'sum', 'Trade Value (US$)': 'sum' } )
            consolidatedFrame.to_csv(os.path.join(outPath, 'consolidated_' + str(partner) + str(baseYear) + '.csv'))
