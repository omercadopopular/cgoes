# -*- coding: utf-8 -*-
"""
Created on Wed Oct 30 18:06:20 2024

@author: cbezerradegoes
"""

import os

# Set Paths
basePath = r'C:\Users\cbezerradegoes\OneDrive\UCSD\Research\cgoes\dynamic-adjustment-trade-shocks\eu-tariffs'
readComtrade = r'C:\Users\cbezerradegoes\OneDrive - WBG\Poverty_DIOT\2 Data\Comtrade\bulk'
outPath = r'data\comtrade-out'

os.chdir(basePath)

from src.wits import wits
from src.comtrade import comtrade

dataProcess = comtrade(readComtrade, outPath)
dataProcess.process()
