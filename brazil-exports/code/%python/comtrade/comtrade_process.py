# -*- coding: utf-8 -*-
"""
Created on Wed Feb  1 23:46:29 2023

@author: wb592068
"""

# Set Paths
path = r'C:\Users\wb592068\OneDrive - WBG\Poverty_DIOT\2 Data\Comtrade\bulk'
comtradeFile = r'C:\Users\wb592068\OneDrive - WBG\Poverty_DIOT\Services-IO\out\comtradeIDN'

# Import Requirements
import pandas as pd
import os
    
# read by chuncks
start = 1989
stop = 2018
for year in range(start,stop+1):
    print('Processing year {}'.format(year))
    fileName = os.path.join(path, str(year) + '.csv' )
    cSize = 10 ** 10
    
    egyFrame = pd.DataFrame()  
    for chunk in pd.read_csv(fileName, chunksize = cSize):
        Frame = chunk[ (chunk['Reporter ISO'] == 'IDN') | (chunk['Partner ISO'] == 'IDN') ]
        egyFrame = egyFrame.append(Frame)
    egyFrame.to_csv(comtradeFile + str(year) + '.csv')