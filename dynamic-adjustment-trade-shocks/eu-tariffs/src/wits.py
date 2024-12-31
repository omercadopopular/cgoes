# -*- coding: utf-8 -*-

import pandas as pd
import os

class Wits:
    
    def __init__(self,
                 Folder='/',
                 Year=2020,
                 MFNFolder = 'AVMFN',
                 PrefFolder = 'AVPREF',
                 ImgFolder = 'out-img',
                 CountryFolder = 'out\\country',
                 CountryPrefFolder = 'out\\country-pref',
                 YearFolder= 'out\\yearly',
                 YearPrefFolder = 'out\\yearly-pref',
                 BilateralFolder='out\\bilateral',
                 AverageNonEUTariffFolder='out\\av-non-eu'):
        
        self.Folder = Folder
        self.Year = Year
        self.ImgFolder = os.path.join(Folder, ImgFolder)
        self.MFNFolder = os.path.join(Folder, MFNFolder)
        self.PrefFolder = os.path.join(Folder, PrefFolder)
        self.CountryFolder = os.path.join(Folder, CountryFolder)
        self.CountryPrefFolder = os.path.join(Folder, CountryPrefFolder)
        self.YearFolder = os.path.join(Folder, YearFolder)
        self.YearPrefFolder = os.path.join(Folder, YearPrefFolder)
        self.BilateralFolder = os.path.join(Folder, BilateralFolder)
        self.AverageNonEUTariffFolder = os.path.join(Folder, AverageNonEUTariffFolder)
                
    def Walker(self, WalkFolder='/', YearCheck=True):      
        ''' 
        Walks through raw files folder and returns a list of all CSV 
        file paths that match the specified year.

        Returns
        -------
        Files : List of CSV  file paths 

        '''
        Files = []
        for root, dirs, files in os.walk(WalkFolder, topdown=False):
            for name in files:
                if name[-3:] == 'CSV' or name[-3:] == 'csv':
                    if YearCheck == True:
                        if name.split('.')[0][-4:] == str(self.Year):
                            Files.append(os.path.join(root, name))
                        elif name.split('_U2')[0][-4:] == str(self.Year):
                            Files.append(os.path.join(root, name))                       
                        else:
                            continue
                    else:
                        Files.append(os.path.join(root, name))
                else:
                    continue
        
        return Files

    def PanelBuild(self, List):
        ''' 
        Uses a list of CSV  file paths and build a panel CSV that
        stacks those datasets into a single DataFrame.
        
        Returns
        -------
        Files : Pandas Datafrane
        
        '''
        Frame = pd.DataFrame()
        for File in List:
            Frame = Frame.append(pd.read_csv(File))
    
        return Frame
    
    def CountryWalker(self,WalkFolder='/'):
        ''' 
        Walks through processed files folder and returns a list of all CSV 
        file paths.

        Returns
        -------
        Files : List of CSV  file paths 

        '''
        Files = []
        for root, dirs, files in os.walk(WalkFolder, topdown=False):
            for name in files:
                if name[-3:] == 'CSV' or name[-3:] == 'csv':
                    Files.append(os.path.join(root, name))
                else:
                    continue
        
        return Files

    def CountryStacker(self, Files, Code):
        ''' 
        Uses a list of CSV  file paths of processed files, extracts
        data for a given country code for all years, and returns the country
        specific data into a single DataFrame.

        Returns
        -------
        Files : pandas DataFrame

        '''
        Frame = pd.DataFrame()
        for File in Files:
            TempFrame = pd.read_csv(File)
            TempFrame = TempFrame[ TempFrame.Reporter_ISO_N == Code ]
            Frame = Frame.append(TempFrame)
            
        return Frame
    
    def BilateralMFNPanel(self, Code, Year=0):
        ''' 
        Uses a Code for a specific country and creates a dataset with
        all bilateral tariffs for that particular country for a specified
        year. 

        Returns
        -------
        Files : pandas DataFrame

        '''
        if Year == 0:
            Year = self.Year
                
        Frame = pd.read_csv(os.path.join(self.YearFolder, 'wits_mfn_'  + str(Year) + '.csv'))
        Frame['Partner'] = Code
        SubFrame = Frame.query("Reporter_ISO_N == " + str(Code))
        Columns = [ 'Sum_Of_Rates', 'Min_Rate', 'Max_Rate', 'SimpleAverage']
        
        if len(SubFrame) > 0:
            
            # Make sure tariffs are zero for own country
            for Column in Columns:
                Frame.loc[SubFrame.index, Column] = [0.0 for x in SubFrame[Column]]
                       
        return Frame
    
    def BilateralMFNPanelRestricted(self, Code, Year=0):
        ''' 
        Uses a Code for a specific country and creates a dataset with
        all bilateral tariffs for that particular country for a specified
        year. 

        Returns
        -------
        Files : pandas DataFrame

        '''
        if Year == 0:
            Year = self.Year
                
        Frame = pd.read_csv(os.path.join(self.YearFolder, 'wits_mfn_'  + str(Year) + '.csv'))
        Frame['Partner'] = Code
        SubFrame = Frame.query("Reporter_ISO_N == " + str(Code))
        Columns = [ 'Sum_Of_Rates', 'Min_Rate', 'Max_Rate', 'SimpleAverage']
        
        if len(SubFrame) > 0:
            
            # Make sure tariffs are zero for own country
            for Column in Columns:
                Frame.loc[SubFrame.index, Column] = [0.0 for x in SubFrame[Column]]
                       
        return Frame
    
        

