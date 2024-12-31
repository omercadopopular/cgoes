# -*- coding: utf-8 -*-
"""
Created by Carlos Góes
cgoes@ucsd.edu
www.carlosgoes.com

Version 0.1
December 2022
"""

from src.wits import wits
import os

Folder = r'C:\Users\wb592068\OneDrive - UC San Diego\UCSD\Research\product-innovation-trade\data\wits'
FolderLocal = r'C:\Users\Carlos\OneDrive - UC San Diego\UCSD\Research\product-innovation-trade\data\wits'

# Construct annual dataset of MFN tariffs

Years = range(1990, 2021)

for Year in Years:
    print('Processing year {}'.format(Year))
    
    Query = wits(Folder=Folder, Year=Year)
    
    # Retrieve Files
    List = Query.Walker(WalkFolder=Query.MFNFolder)
    
    # Build Panel
    Frame = Query.PanelBuild(List)
    
    # Save Output
    Frame.to_csv(os.path.join(Query.YearFolder, 'wits_mfn_' + str(Year) + '.csv'), index=False)