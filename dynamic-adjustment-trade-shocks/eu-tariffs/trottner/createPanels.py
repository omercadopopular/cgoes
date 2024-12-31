# -*- coding: utf-8 -*-
"""
Created on Mon Nov 18 01:42:36 2024

@author: andre
"""

import os
import sys
import pandas as pd

class createPanels():
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
        
    def create_base_panel(self, reporter):
        first_year = self.first_year
        last_year = self.last_year
        
        if not hasattr(self, 'setc'):
            self.sets()
        
        if not hasattr(self, 'seths'):
            self.sets()

        setc = self.setc
        seths = self.seths
        
        rframe = pd.DataFrame()
        for year in range(first_year, last_year):
            frame = pd.DataFrame(seths, columns=['hs6'])
            frame.loc[:,'importer'] = reporter
            frame.loc[:,'year'] = year
            
            yearframe = pd.DataFrame()
            for partner in setc:
                partnerframe = frame.copy()
                partnerframe.loc[:,'exporter'] = partner              
                yearframe = pd.concat([yearframe, partnerframe])
            
            rframe = pd.concat([rframe, yearframe])
        
        path = os.path.join(self.outfolder, 'base_' + reporter + '.csv')
        rframe.to_csv(path, index=False)
        
        return rframe
    
    def import_lev_data(self, reporter):
        first_year = self.first_year
        last_year = self.last_year
        
        print(f'Creating base panel for country {reporter}.')
        bpath = os.path.join(self.outfolder, 'base_' + reporter + '.csv')            
        if not os.path.isfile(bpath):
            base_panel = self.create_base_panel(reporter)
        else:
            base_panel = pd.read_csv(bpath, low_memory=False)
        print(f'Base panel for country {reporter} created.')
            
        year_panel = pd.DataFrame()            
        for year in range(first_year, last_year):
            print(f'Merging data for {reporter} in {year}.')
            
            # check if annual file exist
            path = os.path.join(self.temp_folder, 'fullT' + str(year) + '.csv')
    
            if not os.path.isfile(path):
                print(f'File {path} does not exist.')
                sys.exit(f'File {path} does not exist.')
    
            else:
                yframe = pd.read_csv(path, dtype=self.dtype_dict)
                yframe = yframe[ yframe.importer == reporter ]
                year_panel = pd.concat([year_panel, yframe])
                
        mergeconditions = ['year', 'importer', 'exporter', 'hs6']
        reporter_panel = base_panel.merge(year_panel, how='left', on=mergeconditions)
            
        path_out = os.path.join(self.outfolder, 'full_' + reporter + '.csv')
        reporter_panel.to_csv(path_out, index=False)
        
        return reporter_panel

    def lev_full(self):

        if not hasattr(self, 'setc'):
            self.sets()
        
        setc = self.setc

        for reporter in setc:
            fpath = os.path.join(self.outfolder, 'full_' + reporter + '.csv')            
    
            if not os.path.isfile(fpath):
                print(f'Creating full panel for country {reporter}.')
                self.import_lev_data(reporter)
                print(f'Full panel for country {reporter} created.')
            
            else:
                print(f'Full panel for country {reporter} already exists.')
                
if __name__ == "__main__":
    path = r'/u/main/tradeadj/lev'
    panel = createPanels(path)
    panel.lev_full()
