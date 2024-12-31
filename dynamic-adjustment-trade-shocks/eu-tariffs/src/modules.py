"""
Comtrade Data Processor

This module processes trade data files for specific ISO countries and generates
consolidated reports based on specified partner countries and commodity data.

"""

import pandas as pd
import os

class Comtrade:
    def __init__(self, input_dir='data/comtrade-raw', output_dir='data/comtrade-out', base_year=1995):
        """
        Initializes the Comtrade processor with specified directories and base year.

        Args:
            input_dir (str): Path to the directory containing raw data files.
            output_dir (str): Path to the directory where processed files will be saved.
            base_year (int): Base year for processing data files.
        """
        self.input_dir = input_dir
        self.output_dir = output_dir
        self.base_year = base_year

        # Ensure the output directory exists
        os.makedirs(self.output_dir, exist_ok=True)

        # Define ISO country codes
        self.iso_codes = ['CYP', 'CZE', 'EST', 'HUN', 'LVA', 'LTU', 'MLT', 'POL', 'SVK', 'SVN']
        self.eu15_codes = ['AUT', 'BEL', 'DNK', 'FIN', 'FRA', 'DEU', 'GRC', 'IRL', 'ITA', 'LUX', 'NLD', 'PRT', 'ESP', 'SWE', 'GBR']

    def process(self):
        """
        Processes the raw data files for each partner country and consolidates
        trade data at the specified aggregation level.
        """
        for partner in self.iso_codes:
            try:
                input_file = os.path.join(self.input_dir, f"{self.base_year}.csv")
                output_file = os.path.join(self.output_dir, f"{partner}_{self.base_year}.csv")
                
                # Read and filter data by chunks
                consolidated_data = pd.DataFrame()
                chunk_size = 10 ** 6  # Adjust chunk size based on memory

                for chunk in pd.read_csv(input_file, chunksize=chunk_size):
                    filtered_chunk = chunk[(chunk['Reporter ISO'].isin(self.eu15_codes)) & (chunk['Partner ISO'] == partner)]
                    consolidated_data = pd.concat([consolidated_data, filtered_chunk])

                # Save filtered data
                consolidated_data.to_csv(output_file, index=False)
                
            except FileNotFoundError:
                print(f"File not found: {input_file}")
            except Exception as e:
                print(f"Error processing {partner} for {self.base_year}: {e}")

        # Consolidate data based on 'Aggregate Level'
        for partner in self.iso_codes:
            try:
                input_file = os.path.join(self.output_dir, f"{partner}_{self.base_year}.csv")
                output_file = os.path.join(self.output_dir, f"consolidated_{partner}_{self.base_year}.csv")
                
                data_frame = pd.read_csv(input_file)
                level_6_data = data_frame[data_frame['Aggregate Level'] == 6]
                aggregated_data = level_6_data.groupby(['Partner ISO', 'Commodity Code', 'Commodity']).agg(
                    {'Netweight (kg)': 'sum', 'Trade Value (US$)': 'sum'}
                )
                
                # Save consolidated data
                aggregated_data.to_csv(output_file)
            
            except FileNotFoundError:
                print(f"File not found: {input_file}")
            except Exception as e:
                print(f"Error consolidating data for {partner} in {self.base_year}: {e}")

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
    
        

