# -*- coding: utf-8 -*-
"""
Created on Mon Nov 18 01:42:36 2024

@author: andre
"""

import os
import sys
import pandas as pd
import numpy as np
import warnings
warnings.simplefilter(action='ignore', category=RuntimeWarning)

class rebuildPanels():
    def __init__(self, folder, first_year=1995, last_year=2018):
        self.folder = folder
        self.first_year = first_year
        self.last_year = last_year+1
        self.temp_folder = os.path.join(self.folder, 'temp_files/')
        self.outfolder = os.path.join(self.folder, 'temp_files/out/')

        self.dtype_dict = {
            "hs6": "int64",   
            "hs6_old": "int64"
        }
        
        self.fill_rename = {
        'Reporter': 'importer',
        'Partner': 'exporter',
        'Product': 'hs6',
        'PRF_post': 'prf_st',
        'MFN_post': 'mfn_st',
        'PRF_pre': 'prf_pre',
        'MFN_pre': 'mfn_pre',
        }

        for folder in [self.outfolder, self.temp_folder]:
            if not os.path.exists(folder):
                os.makedirs(folder)  
                
    def sets(self):
        first_year = self.first_year
        last_year = self.last_year
        
        
        setc = set()
        seths = set()
        for year in range(first_year, last_year):
            print(f'Set of countries and products, processing {year}.')
        
            # check if annual file exist
            path = os.path.join(self.temp_folder, 'fullT' + str(year) + '.csv')

            if not os.path.isfile(path):
                print(f'File {path} does not exist.')
                sys.exit(f'File {path} does not exist.')

            else:
                frame = pd.read_csv(path, usecols=['importer', 'hs6'], dtype=self.dtype_dict)
                
            setc = setc.union( set(frame['importer']) )
            seths = seths.union( set(frame['hs6']) )
            
        self.setc = sorted(setc)
        print(f'Countries in the database {len(list(setc))}')
        self.seths = sorted(seths)
        print(f'HS6 codes in the database {len(list(seths))}')
        
    def mergeFilled(self, reporter):
        baseFile = r'full_' + str(reporter) + '.csv'
        fillFile = r'fill_full_' + str(reporter) + '.csv'
        
        # import fill frame and adjust hs6 codes
        fillFrame = pd.read_csv(os.path.join(self.outfolder, fillFile), dtype={"Product": str}).rename(columns=self.fill_rename)
        fillFrame = fillFrame.sort_values(['importer','exporter','hs6','year'])
        hsString = lambda x: '0'*(6-len(str(x))) + str(x)       
        fillFrame.loc[:,'hs6'] = [hsString(y) for y in fillFrame.loc[:,'hs6']]
        
        # create variables for effective applied tariff
        fillFrame.loc[:,'ahs_st'] = np.nanmin([fillFrame.loc[:,'prf_st'],fillFrame.loc[:,'mfn_st']], axis=0)
        fillFrame.loc[:,'ahs_pre'] = np.nanmin([fillFrame.loc[:,'prf_pre'],fillFrame.loc[:,'mfn_pre']], axis=0)
        
        # load baseframe and adjust hs6 codes
        baseFrame = pd.read_csv(os.path.join(self.outfolder, baseFile), dtype={"hs6": str}, low_memory=False)
        baseFrame.loc[:,'hs6'] = [hsString(y) for y in baseFrame.loc[:,'hs6']]
        
        # drop duplicates and merge ensuring one-to-one merge
        def dropDups(frame, subset=['importer','exporter','hs6','year']):
            dup = frame.duplicated(subset=subset, keep='first')
            return frame[~dup]
        
        baseFrame = dropDups(baseFrame)
        fillFrame = dropDups(fillFrame)
        
        mergeFrame = baseFrame.merge(fillFrame, how='left', on=['importer','exporter','hs6','year'], suffixes=['_old', ''], validate='one_to_one')
        
        flag = (~mergeFrame.ahs_st_old.isna()) | (~mergeFrame.mfn_st_old.isna()) | (~mergeFrame.mfn_st.isna()) | (~mergeFrame.ahs_st.isna() ) | (~mergeFrame.prf_st.isna()) | (~mergeFrame.prf_st.isna() ) 
        return mergeFrame[flag]
    
    def tfYear(self):
        first_year = self.first_year
        last_year = self.last_year

        if not hasattr(self, 'setc'):
            self.sets()
        
        setc = self.setc
        
        print('Processing Full Panel.')
        fpath = os.path.join(self.outfolder, 'full_panel.csv')            

        if not os.path.isfile(fpath):
            fullPanel = pd.DataFrame()
            fullData = []
            for reporter in setc:           
                filled_panel = self.mergeFilled(reporter)
                fullData.append(filled_panel)        
            fullPanel = pd.concat(fullData, ignore_index=True)
            fullPanel.to_csv(fpath, index=False)
        else:
            fullPanel = pd.read_csv(fpath)

        print('Processed Full Panel.')
        
        for year in range(first_year, last_year):
            yearPanel = fullPanel[ fullPanel['year'] == year ]
            print(f'Processing year {year}.')
            opath = os.path.join(self.outfolder, 'TF' + str(year) + '.csv')
            yearPanel.to_csv(opath, index=False)
            print(f"Processed year {year}.")
            
        return None


                
if __name__ == "__main__":
    path = r'/u/main/tradeadj/lev'
    panel = rebuildPanels(path)
    panel.tfYear()
