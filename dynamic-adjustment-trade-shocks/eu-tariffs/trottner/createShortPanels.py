# -*- coding: utf-8 -*-
"""
Created on Mon Nov 18 01:42:36 2024

@author: andre
"""

import os
import sys
import pandas as pd

class createPanels():
    def __init__(self, folder, first_year=2017, last_year=2018):
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

    def setc_reporter(self, rpanel):

        rsetc = sorted(set(rpanel['exporter']))
        
        return rsetc
            
    def seths_reporter(self, rppanel):

        rseths = sorted(set(rppanel['hs6']))
        
        return rseths

    def create_base_panel(self, reporter, rpanel):
        first_year = self.first_year
        last_year = self.last_year        
        
        rsetc = self.setc_reporter(rpanel)
        print(f'Countries in {reporter} panel: {len(list(rsetc))}')
        
        rframe = pd.DataFrame()
        for partner in rsetc:
            rppanel = rpanel[ rpanel['exporter'] == partner ]
            rseths = self.seths_reporter(rppanel)
            print(f'HS6 codes b/w {reporter} and {partner} panel: {len(list(rseths))}')
            
            ppanel = pd.DataFrame()
            for year in range(first_year, last_year):
                frame = pd.DataFrame(rseths, columns=['hs6'])
                frame.loc[:,'importer'] = reporter
                frame.loc[:,'exporter'] = partner
                frame.loc[:,'year'] = year
                ppanel = pd.concat([ppanel, frame])
                        
            rframe = pd.concat([rframe, ppanel])
        
        return rframe

    def prepare_lev_panel(self, reporter):
        first_year = self.first_year
        last_year = self.last_year
                   
        lev_panel = pd.DataFrame()            
        for year in range(first_year, last_year):
            
            # check if annual file exist
            path = os.path.join(self.temp_folder, 'fullT' + str(year) + '.csv')
    
            if not os.path.isfile(path):
                print(f'File {path} does not exist.')
                sys.exit(f'File {path} does not exist.')
             
            else:
                chunk = pd.read_csv(path, dtype=self.dtype_dict)
                filtered_chunk = chunk[chunk.importer == reporter]
                lev_panel = pd.concat([lev_panel, filtered_chunk], ignore_index=True)
    
        return lev_panel
    
    def filter_nomen(self, panel):
        panel = panel.sort_values(['importer', 'exporter', 'nomen', 'hs6', 'year']).reset_index(drop=True)
        count = panel.groupby(['importer', 'exporter', 'year']).filter( lambda g: g['nomen'].count() > 1 )
        count_multiple = count[count.nomen > 1]
        count_simple = count[count.nomen == 1]
        panel_multiple = rpanel
    
    def import_lev_data(self, reporter):
        
        rpanel = self.prepare_lev_panel(reporter)
        base_panel = self.create_base_panel(reporter, rpanel)
                            
        mergeconditions = ['year', 'importer', 'exporter', 'hs6']
        reporter_panel = base_panel.merge(rpanel, how='left', on=mergeconditions)
        
        cols = ['importer', 'exporter', 'hs6', 'year']        
        return reporter_panel.sort_values(cols).reset_index(drop=True)

    def lev_full(self):

        if not hasattr(self, 'setc'):
            self.sets()
        
        setc = self.setc
        
        for reporter in setc:
            fpath = os.path.join(self.outfolder, 'sfull_' + reporter + '.csv')            

            if not os.path.isfile(fpath):
                print(f'Creating panel for country {reporter}.')
                rpanel = self.import_lev_data(reporter)
                path_out = os.path.join(self.outfolder, 'sfull_' + reporter + '.csv')
                rpanel.to_csv(path_out, index=False)
                print(f'Panel for country {reporter} created.')

                
if __name__ == "__main__":
    path = r'/u/main/tradeadj/lev'
    panel = createPanels(path)
    panel.lev_full()


path = r'C:\Users\andre\OneDrive\UCSD\Research\cgoes\dynamic-adjustment-trade-shocks\eu-tariffs\trottner'
panel = createPanels(path)

x = rpanel.groupby(['importer', 'exporter', 'hs6', 'year']).agg({'nomen': 'count'})