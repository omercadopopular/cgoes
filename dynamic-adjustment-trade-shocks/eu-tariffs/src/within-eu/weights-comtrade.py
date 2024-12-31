# -*- coding: utf-8 -*-
"""
Created on Mon Mar 27 14:32:17 2023

@author: wb592068
"""

import os
import pandas as pd


WalkFolder = r'C:\Users\wb592068\OneDrive - WBG\Poverty_DIOT\Indonesia\data\comtrade'
OutFolder = r'C:\Users\wb592068\OneDrive - WBG\Poverty_DIOT\Indonesia\data\comtrade-out'

"""
    Walk through folder and make a list of all CSV
    files in folde
"""

Files = []
for root, dirs, files in os.walk(WalkFolder, topdown=False):
    for name in files:
        if name[-3:] == 'CSV' or name[-3:] == 'csv':
            Files.append(os.path.join(root, name))

"""
    Create MasterFrame and Stack Yearly Frames
"""

MasterFrame = pd.DataFrame()

for File in Files:
    YearlyFrame = pd.read_csv(File)
    Year = set(YearlyFrame.Year)
    if (len(MasterFrame) == 0) or (Year not in set(MasterFrame.Year)):
        MasterFrame = MasterFrame.append(YearlyFrame)
        print('Appended year {}'.format(Year))
    

"""
    Sort by Year
"""

MasterFrame = MasterFrame.drop(columns=['Unnamed: 0'])

MasterFrame = MasterFrame.sort_values(['Year','Commodity Code'])

MasterFrame.to_csv(os.path.join(OutFolder, 'IDN_comtrade_master.csv'))

