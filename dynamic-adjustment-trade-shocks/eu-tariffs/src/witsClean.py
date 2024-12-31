# -*- coding: utf-8 -*-
"""
Created on Mon Dec 23 15:06:10 2024

@author: cbezerradegoes
"""

# -*- coding: utf-8 -*-

import pandas as pd
import os
import numpy as np

class wits:
    def __init__(self, folder,
                 mfnFolder='data\\AVMFN',
                 prefFolder='data\\AVPREF',
                 concFolder='concordance',
                 firstYear=1995,
                 lastYear=2019):
        self.mfnFolder = os.path.join(folder, mfnFolder)
        self.prefFolder = os.path.join(folder, prefFolder)
        self.concFolder = os.path.join(folder, concFolder)
        self.firstYear = 1995
        self.lastYear = 2019
        self.isoFrame()
        
    def isoFrame(self):
        
        concFolder = self.concFolder

        cols = {'Country Name': 'reporter_name',
                'ISO3': 'reporter_iso',
                'Code': 'reporter'}

        dtypes = {'Country Name': str,
                'ISO3': str,
                'Code': str}
        concFrame = pd.read_csv(os.path.join(concFolder,'witscodes.csv'), dtype=dtypes).rename(columns=cols)
        
        addZeros = lambda x: '0' * (3-len(str(x))) + str(x)
        concFrame.loc[:,'reporter'] = [addZeros(y) for y in concFrame['reporter']]
        
        self.isoTable = concFrame

        
    def walker(self, reporterIso, folder):      
        ''' 
        Walks through raw files folder and returns a list of all CSV 
        file paths that match the specified year.

        Inputs
        -------
        reporter : ISO

        Returns
        -------
        file : List of CSV  file paths 

        '''
        outfiles = []
        for root, dirs, files in os.walk(folder, topdown=True):
            for name in files:
                if (name[-3:] == 'CSV' or name[-3:] == 'csv') and (str(reporterIso) in name):
                    outfiles.append(os.path.join(folder,name))
        
        return outfiles
 
    """    
    def expandMfnPanel(self, frame):        
        vintages = set(frame['NomenCode'])
        
        frames = []
        for vintage in vintages:
            frameVintage = frame[ frame['NomenCode'] == vintage ]            
            
            products = set(frameVintage['ProductCode'])
            vintageFrames = []
            for product in products:
                miniFrame = frameVintage[ frameVintage['ProductCode'] == product ]
                year_min = np.min( miniFrame['Year'] )
                year_max = np.max( miniFrame['Year'] )
                year_range = range(year_min, year_max+1)
                
                unique_combinations = miniFrame[ ["Reporter_ISO_N", "ProductCode"] ].drop_duplicates()
                
                idx = pd.MultiIndex.from_product(
                    [[vintage],
                     unique_combinations["Reporter_ISO_N"],
                     unique_combinations["ProductCode"],
                     year_range],
                    names=['NomenCode','Reporter_ISO_N', 'ProductCode', 'Year']
                    )
                
                miniFrame = miniFrame.set_index(['NomenCode', 'Reporter_ISO_N', 'ProductCode', 'Year'])
                fullFrame = miniFrame.reindex(idx)
                vintageFrames.append(fullFrame.reset_index(drop=False))
        
        return pd.concat(frames)
        """
        
    def harmonizeHS(self, frame):
        correlationsHS = pd.read_excel(os.path.join(self.concFolder,'CompleteCorrelationsOfHS-SITC-BEC_20170606.xlsx'), dtype=str)
    
        outFrame = pd.DataFrame()
        
        vintages = set(frame.NomenCode)
        
        for vintage in vintages:
            
            tempFrame = frame[frame.NomenCode == vintage].dropna()
            
            if vintage == 'H3':
                tempFrame['ProductCodeH3'] = [int(x) for x in tempFrame.ProductCode]
            
            else:
                correlFrame = correlationsHS[[vintage, 'H3']].dropna()
                correlFrame = correlFrame.rename(columns={vintage: 'ProductCode',
                                                          'H3': 'ProductCodeH3'})
                                
                # select mode of each ProductCode as H3 code
                correlFrame = correlFrame.groupby('ProductCode')['ProductCodeH3'].agg(lambda x: pd.Series.mode(x)[0]).reset_index(drop=False)
                
                tempFrame = pd.merge(tempFrame, correlFrame, how='left', on='ProductCode')
                
            outFrame = pd.concat((outFrame,tempFrame))
            
            addZeros = lambda x: '0' * (6-len(str(int(x)))) + str(int(x))
            outFrame.loc[:,'ProductCodeH3'] = [addZeros(y) for y in outFrame.loc[:,'ProductCodeH3']]
        
        return outFrame

    def expandPanel(self, frame): 
        frame = frame.sort_values(['Reporter_ISO_N', 'NomenCode', 'ProductCode', 'Year'])
        frame = frame.drop_duplicates(subset=["Reporter_ISO_N", "ProductCodeH3", "Year"], keep = 'last')
        
        products = set(frame['ProductCodeH3'])
        
        frames = []
        for product in products:
            miniFrame = frame[ frame['ProductCodeH3'] == product ]
            year_min = np.min( miniFrame['Year'] )
            year_max = np.max( miniFrame['Year'] )
            year_range = range(year_min, year_max+1)
                
            unique_combinations = miniFrame[ ["Reporter_ISO_N", "ProductCodeH3"] ].drop_duplicates()
                
            idx = pd.MultiIndex.from_product(
                     [unique_combinations["Reporter_ISO_N"],
                     unique_combinations["ProductCodeH3"],
                     year_range],
                    names=['Reporter_ISO_N', 'ProductCodeH3', 'Year']
                    )
                
            miniFrame = miniFrame.set_index(['Reporter_ISO_N', 'ProductCodeH3', 'Year'])
            fullFrame = miniFrame.reindex(idx).reset_index(drop=False)
            fullFrame.loc[:,'SimpleAverage'] = fullFrame.loc[:,'SimpleAverage'].ffill()
            frames.append(fullFrame)

        return pd.concat(frames)

    
    def mfnPanel(self, reporterIso):
        ''' 
        Creates a reporter specific panel of MFN tariffs based on stored WITS data

        Returns
        -------
        fullFrame : Pandas dataframe

        '''

        # retrieve ISO to WITS table        
        if not hasattr(self, 'isoTable'):
            self.isoFrame()

        # Collect Wits Code and Files
        mfnFolder = self.mfnFolder
        mfnFiles = self.walker(reporterIso, mfnFolder)

        dtypes = {'Reporter_ISO_N': str,
                'ProductCode': str}
        frames = []
        for file in mfnFiles:
            frame = pd.read_csv(file, dtype=dtypes)
            frames.append(frame)
        
        fullFrame = pd.concat(frames)
        
        mask = ['NomenCode', 'Reporter_ISO_N', 'Year', 'ProductCode', 'Sum_Of_Rates', 'Min_Rate', 'Max_Rate', 'SimpleAverage']
        
        fullFrame = fullFrame[mask].sort_values(['NomenCode', 'Reporter_ISO_N', 'ProductCode', 'Year'])
        
        h_fullFrame = self.harmonizeHS(fullFrame)

        # Expand Panel        
        exp_fullFrame = self.expandPanel(h_fullFrame)
                        
        return exp_fullFrame
    
    def mfnBilateralPanel(self, reporter, partners):
        ''' 
        Given a list of partners, returns a panel that copies all MFN tariffs of a unique reporter to each partner

        Returns
        -------
        Pandas dataframe

        '''
        
        # retrieve ISO to WITS table        
        if not hasattr(self, 'isoTable'):
            self.isoFrame()

        # retrieve ISO code for the reporter and the MFN panel
        reporterIso = self.isoTable.set_index('reporter').loc[reporter,'reporter_iso']
        print(f'Retrieving MFN panel for {reporter}...')
        frame = self.mfnPanel(reporterIso)
        
        frames = []
        for partner in partners:
            partnerFrame = frame.copy()
            partnerFrame.loc[:,'Partner_ISO_N'] = partner
            frames.append(partnerFrame)
            
        return pd.concat(frames)
    
    def prefPanel(self, reporterIso):
        ''' 
        Creates a reporter specific panel of PRF tariffs based on stored WITS data

        Returns
        -------
        fullFrame : Pandas dataframe

        '''

        # Collect Wits Code and Files
        prefFolder = self.prefFolder
        prefFiles = self.walker(reporterIso, prefFolder)
        
        dtypes = {'Reporter_ISO_N': str,
                'ProductCode': str}
        frames = []
        for file in prefFiles:
            frame = pd.read_csv(file, dtype=dtypes)
            frames.append(frame)
        
        fullFrame = pd.concat(frames)
        
        mask = ['NomenCode', 'Reporter_ISO_N', 'Year', 'ProductCode', 'Partner', 'Sum_Of_Rates', 'Min_Rate', 'Max_Rate', 'SimpleAverage']
        
        fullFrame = fullFrame[mask].sort_values(['NomenCode', 'Reporter_ISO_N', 'Partner', 'ProductCode', 'Year'])
        
        # Harmonize HS Codes
        h_fullFrame = self.harmonizeHS(fullFrame)

        return h_fullFrame 

    def benefPref(self, partners):
        
        # Search for which areas have the country as the beneficiary
        benefFrame = pd.read_excel(os.path.join(self.concFolder, 'TRAINSPreferenceBenficiaries.xls'), dtype=str)
        addZeros = lambda x: '0' * (3-len(str(x))) + str(x)
        benefFrame.loc[:,'Partner'] = [addZeros(y) for y in benefFrame['Partner']]
        benefFrame = benefFrame[benefFrame['Partner'].isin(partners)]
        benefList = list(benefFrame.RegionCode.unique())
        
        return list(set(benefList + partners))


    def prefBilateralPanel(self, reporter, partners):
        ''' 
        Given a list of partners, returns a panel that copies all MFN tariffs of a unique reporter to each partner

        Returns
        -------
        Pandas dataframe

        '''
        
        # retrieve ISO code for the reporter and the PRF panel
        reporterIso = self.isoTable.set_index('reporter').loc[reporter,'reporter_iso']
        print(f'Retrieving PRF panel for {reporter}...')
        frame = self.prefPanel(reporterIso)
                
        frames = []
        for partner in partners:
            # retrieve list of partners
            benefList = self.benefPref([partner])
            partnerFrame = frame[ frame['Partner'].isin(benefList) ]
            partnerFrame.loc[:,'Partner_ISO_N'] = partner
            frames.append(partnerFrame)
            
        return pd.concat(frames)
        
    def mergeFrames(self, reporter, partners):
        
        # Import mfn and bilateral panels
        mfnBilateralPanel = self.mfnBilateralPanel(reporter, partners)
        prefBilateralPanel = self.prefBilateralPanel(reporter, partners)
                
        # merge them
        mergePanel = mfnBilateralPanel.merge(prefBilateralPanel, on=['Reporter_ISO_N', 'Partner_ISO_N', 'ProductCodeH3', 'Year'], suffixes=['_mfn','_pref'], how='left')
        mergePanel.loc[mergePanel.Year >= 2004, 'ahs'] = 0
        
        # interpolate
        mergePanel.loc[:,'SimpleAverage_pref'] = mergePanel.groupby(['Reporter_ISO_N', 'Partner_ISO_N', 'ProductCodeH3']).agg({'SimpleAverage_pref': lambda group: group.interpolate(method='index', limit_area='inside') })
        
        # create ahs tariff
        mergePanel['ahs'] = np.nanmin(mergePanel[['SimpleAverage_pref','SimpleAverage_mfn']] , axis=1)
        mergePanel['flag'] = (mergePanel['ahs']  == mergePanel['SimpleAverage_pref']) & (mergePanel['SimpleAverage_pref'] < mergePanel['SimpleAverage_mfn'])


        return mergePanel             

folder = r'C:\Users\cbezerradegoes\OneDrive\UCSD\Research\cgoes\dynamic-adjustment-trade-shocks\eu-tariffs'
query = wits(folder)

"""
query.isoFrame()
reporterIso = query.isoTable.set_index('reporter').loc['918','reporter_iso']
x = query.walker(reporterIso, query.mfnFolder)
"""

nms = ['CYP', 'CZE', 'EST', 'HUN', 'LVA', 'LTU', 'MLT', 'POL', 'SVK', 'SVN']
nms_wits = []
for country in nms:
    code = query.isoTable.set_index('reporter_iso').loc[country,'reporter']
    nms_wits.append(code)
    
eun = ['EUN']
eun_wits = []
for country in eun:
    code = query.isoTable.set_index('reporter_iso').loc[country,'reporter']
    eun_wits.append(code)

outFrame = query.mergeFrames(eun_wits[0], nms_wits)


import matplotlib.pyplot as plt
import seaborn as sns

counter = 0
for partner in nms_wits:
    plotFrame =  outFrame[ (outFrame['Partner_ISO_N'] == partner) & (outFrame['Year'] > 1994)]
    country = nms[counter]
    
    fig, axes = plt.subplots(figsize=(12, 6))
    sns.boxplot(data=plotFrame, color='grey', x='Year', y='ahs', showfliers=False, whis=0)
    plt.title(f'Tariffs the EU imposes on {country}')
    plt.show()
    
    counter += 1
