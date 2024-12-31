# -*- coding: utf-8 -*-
"""
Crawls through all data files and checks size of dataset
"""

import os
import pandas as pd

Path = r'/cube/u/cube/world/comtrade/data'

Files = []
for Root, Dir, File in os.walk(Path):
    for Name in File:
          Files.append(os.path.join(Root, Name))

Archive = dict()
for File in Files:
    FileName = File.split('\\')[-1]
    FilePath = Files[0][:-len(FileName)]
    
    if (FileName.split('.')[-1] == 'csv'):
        print('Processing {}'.format(FileName))
        Data = os.path.join(FilePath,FileName)
        Len = len(open(Data).readlines())
        
        Year = File.split('\\')[-2]
        Country = FileName.split('.csv')[0]
        
        YearCountry = Year + '; ' + Country
        
        Archive.update({YearCountry: Len})

ArchiveDF = pd.DataFrame.from_dict(Archive, orient='index').reset_index()
ArchiveDF.to_csv(os.path.join(Path,'Line_Check.csv'))