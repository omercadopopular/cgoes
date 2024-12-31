# -*- coding: utf-8 -*-
"""
Created on Wed Nov 20 22:51:05 2024

@author: andre
"""
import time
import warnings
warnings.simplefilter(action='ignore', category=FutureWarning)


import numpy as np
from datetime import datetime
import os
import glob
import modin.pandas as pd
import pandas

import ray
import modin.config as cfg
ray.init(num_cpus=24)
cfg.Engine.put("ray") # Modin will use Ray engine
cfg.CpuCount.put(24)

class tariffFill():
    def __init__(self, folder, file, column_mapping = {}, first_year=1995, last_year=2018):
        self.folder = folder
        self.file = file
        self.first_year = first_year
        self.last_year = last_year+1
        self.rtadata_folder = os.path.join(self.folder, 'data/rta-data/')
        self.temp_folder = os.path.join(self.folder, 'temp_files/out/')
        self.outfolder = os.path.join(self.folder, 'temp_files/out/')
        self.column_mapping = column_mapping
        
        print("Downloading country codes and storing WTO membership references")
        self.get_country_codes()
        self.load_wto_membership()
        
        print("Loading tariff dataframe")
        self.input_df = pd.read_csv(os.path.join(self.temp_folder, file))
        print("Pre-processing tariff dataframe")
        self.prepare_tariff_data()
        
        print("Loading RTA data")
        self.load_processed_rta_data()

    def prepare_tariff_data(self):
        """
        Prepare  tariff data to match required format
        """
        
        df = self.input_df.copy()

        if self.column_mapping != {}:            
            # Rename columns according to mapping
            df = df.rename(columns=self.column_mapping)
            
            
        required_columns = {'Reporter', 'Partner', 'Product', 'Tariff Year', 'MFN', 'PRF'}
        if not required_columns.issubset(df.columns):
            missing_cols = required_columns - set(df.columns)
            raise ValueError(f"Missing required columns: {missing_cols}")
        
        self.full_prepared_data = df

        # Drop empty groups without manually iterating
        outFrame = df.groupby(['Reporter', 'Partner', 'Product']).filter(
            lambda g: g['MFN'].any() or g['PRF'].any()
        )

        self.prepared_data = outFrame

    def get_country_codes(self):
        storage_options = {'User-Agent': 'Mozilla/5.0'}
        url = r'https://wits.worldbank.org/wits/wits/witshelp/content/codes/country_codes.htm'
        country_codes_table = pandas.read_html(url, storage_options=storage_options, header=1)[0]
        country_codes_table.loc[:,'Code'] = country_codes_table.Code.astype(str).str.zfill(3)
        self.country_codes_table = country_codes_table

    def load_wto_membership(self):
        """
        Create a dictionary of WTO membership dates 
        Data source: World Trade Organization (https://www.wto.org/english/thewto_e/whatis_e/tif_e/org6_e.htm)
        """
    
        setc = set(self.country_codes_table.Code)
        
        cctable = self.country_codes_table.set_index('Code')

        # Format: 'country_code': 'YYYY-MM-DD'
        membership = {
            # GATT/WTO Original members (joined 1 January 1995)
            '032': '1995-01-01',  # Argentina
            '036': '1995-01-01',  # Australia
            '040': '1995-01-01',  # Austria
            '050': '1995-01-01',  # Bangladesh
            '051': '1995-01-01',  # Armenia
            '056': '1995-01-01',  # Belgium
            '076': '1995-01-01',  # Brazil
            '124': '1995-01-01',  # Canada
            '152': '1995-01-01',  # Chile
            '156': '2001-12-11',  # China
            '170': '1995-01-01',  # Colombia
            '188': '1995-01-01',  # Costa Rica
            '203': '1995-01-01',  # Czech Republic
            '208': '1995-01-01',  # Denmark
            '218': '1995-01-01',  # Ecuador
            '246': '1995-01-01',  # Finland
            '251': '1995-01-01',  # France
            '276': '1995-01-01',  # Germany
            '300': '1995-01-01',  # Greece
            '348': '1995-01-01',  # Hungary
            '352': '1995-01-01',  # Iceland
            '356': '1995-01-01',  # India
            '360': '1995-01-01',  # Indonesia
            '372': '1995-01-01',  # Ireland
            '376': '1995-01-01',  # Israel
            '380': '1995-01-01',  # Italy
            '381': '2000-11-13',  # Kosovo
            '392': '1995-01-01',  # Japan
            '400': '1995-01-01',  # Jordan
            '404': '1995-01-01',  # Kenya
            '410': '1995-01-01',  # Korea, Republic of
            '428': '1995-01-01',  # Latvia
            '440': '1995-01-01',  # Lithuania
            '442': '1995-01-01',  # Luxembourg
            '458': '1995-01-01',  # Malaysia
            '484': '1995-01-01',  # Mexico
            '504': '1995-01-01',  # Morocco
            '528': '1995-01-01',  # Netherlands
            '554': '1995-01-01',  # New Zealand
            '578': '1995-01-01',  # Norway
            '586': '1995-01-01',  # Pakistan
            '604': '1995-01-01',  # Peru
            '608': '1995-01-01',  # Philippines
            '616': '1995-01-01',  # Poland
            '620': '1995-01-01',  # Portugal
            '642': '2012-08-22',  # Romania
            '643': '2012-08-22',  # Russian Federation
            '702': '1995-01-01',  # Singapore
            '703': '1995-01-01',  # Slovakia
            '705': '1995-01-01',  # Slovenia
            '710': '1995-01-01',  # South Africa
            '724': '1995-01-01',  # Spain
            '752': '1995-01-01',  # Sweden
            '756': '1995-01-01',  # Switzerland
            '764': '1995-01-01',  # Thailand
            '792': '1995-01-01',  # Turkey
            '804': '1995-01-01',  # Ukraine
            '818': '1995-01-01',  # Egypt
            '826': '1995-01-01',  # United Kingdom
            '840': '1995-01-01',  # United States
            '858': '1995-01-01',  # Uruguay
            '862': '1995-01-01',  # Venezuela
            '894': '1995-01-01',  # Zambia    
            # Members that joined after 1995
            '008': '2000-09-08',  # Albania
            '024': '2000-11-23',  # Angola
            '031': '1999-02-05',  # Azerbaijan
            '048': '2005-12-13',  # Bahrain
            '072': '1996-09-12',  # Botswana
            '100': '1996-10-01',  # Bulgaria
            '116': '1997-07-23',  # Cambodia
            '144': '1996-10-09',  # Sri Lanka
            '178': '1997-10-14',  # Congo
            '262': '1996-05-31',  # Djibouti
            '268': '1996-10-16',  # Georgia
            '320': '1996-02-22',  # Guatemala
            '324': '1995-10-25',  # Guinea
            '328': '1995-03-31',  # Guyana
            '332': '1996-01-30',  # Haiti
            '340': '1995-12-13',  # Honduras
            '364': '1997-01-13',  # Iran
            '368': '1995-01-01',  # Iraq
            '388': '1995-12-20',  # Jamaica
            '398': '1995-11-30',  # Kazakhstan
            '414': '1995-12-20',  # Kuwait
            '417': '1998-12-14',  # Kyrgyzstan
            '422': '1995-02-14',  # Lebanon
            '426': '1995-12-21',  # Lesotho
            '450': '1995-05-31',  # Madagascar
            '454': '1995-05-31',  # Malawi
            '466': '1995-05-31',  # Mali
            '470': '1995-11-30',  # Malta
            '478': '1995-05-31',  # Mauritania
            '480': '1995-01-01',  # Mauritius
            '496': '1997-05-26',  # Mongolia
            '508': '1995-08-29',  # Mozambique
            '516': '1995-09-03',  # Namibia
            '524': '2004-04-23',  # Nepal
            '562': '1996-05-31',  # Niger
            '566': '1995-01-01',  # Nigeria
            '512': '2007-01-11',  # Oman
            '598': '1996-09-12',  # Papua New Guinea
            '600': '1995-01-01',  # Paraguay
            '634': '1996-01-13',  # Qatar
            '646': '1995-05-06',  # Rwanda
            '678': '1995-07-23',  # Sao Tome and Principe
            '682': '2005-12-11',  # Saudi Arabia
            '686': '1995-01-01',  # Senegal
            '690': '1995-07-23',  # Seychelles
            '694': '1995-07-23',  # Sierra Leone
            '704': '1995-07-30',  # Vietnam
            '706': '1995-07-30',  # Somalia
            '729': '1995-07-30',  # Sudan
            '740': '1995-07-30',  # Suriname
            '748': '1995-01-01',  # Eswatini (formerly Swaziland)
            '762': '1995-07-30',  # Tajikistan
            '768': '1995-05-31',  # Togo
            '780': '1995-03-02',  # Trinidad and Tobago
            '788': '1995-03-29',  # Tunisia
            '795': '1995-03-29',  # Turkmenistan
            '800': '1995-12-20',  # Uganda
            '807': '1995-04-27',  # North Macedonia
            '834': '1995-12-17',  # Tanzania
            '887': '1995-12-17',  # Yemen
            '891': '1995-03-05',  # Serbia and Montenegro
        }
        
        self.wto_membership = {cctable.loc[k,'ISO3']: datetime.strptime(v, '%Y-%m-%d') for k, v in membership.items() if k in setc}
    
    def check_wto_membership(self, reporter, partner, year):
        """
        Check if both reporter and partner are WTO members in a given year.
        """
        if reporter not in self.wto_membership or partner not in self.wto_membership:
            return False
        
        check_date = datetime(year, 1, 1)
        return (self.wto_membership[reporter] <= check_date and 
                self.wto_membership[partner] <= check_date)
    
    def load_processed_rta_data(self):
        """
        Load and combine multiple RTA databases with  duplicate handling
        
        Parameters:
        file_paths (list): List of paths to RTA data files
        
        Returns:
        pandas.DataFrame: Combined RTA data
        """
        
        folder_path = self.rtadata_folder

        if not os.path.isdir(folder_path):
            raise ValueError(f"The folder path '{folder_path}' does not exist or is not a directory.")
        
        # Use glob to find all .csv files in the folder
        dataframes = glob.glob(os.path.join(folder_path, "*.csv"))

        
        if not dataframes:
            return None
        
        # Before combining, analyze overlaps
        if len(dataframes) > 1:
            print("\nAnalyzing RTA database overlaps:")
            overlap_stats = self.analyze_rta_overlaps(dataframes)
            print(f"Unique agreements: {overlap_stats[0]}")
            print(f"Redundant Agreements: {overlap_stats[1]}")
            
        
        # Combine dataframes
        combined_rta = pd.DataFrame()
        for frame_path in dataframes:
            frame = pd.read_csv(frame_path)
            combined_rta = pd.concat([combined_rta,frame], ignore_index=True)
        print(f"\nTotal records after concatenation: {len(combined_rta)}")
        
        # Process and standardize key columns
        combined_rta['Expanded_Signatories'] = combined_rta['Expanded_Signatories'].str.strip()
        combined_rta['Start_Year'] = pd.to_numeric(combined_rta['Start_Year'], errors='coerce')
        
        # Create a sorting key for signatories to ensure consistent comparison
        combined_rta['sorted_signatories'] = combined_rta['Expanded_Signatories'].apply(
            lambda x: ';'.join(sorted(str(x).split(';')))
        )
        
        # Identify duplicates based on key columns
        duplicate_mask = combined_rta.duplicated(
            subset=['sorted_signatories', 'Start_Year', 'End_Implementation_Year_G'],
            keep='first'
        )
        
        # Remove duplicates but keep track of them
        duplicates = combined_rta[duplicate_mask].copy()
        combined_rta = combined_rta[~duplicate_mask]
        
        print(f"\nDuplicate entries removed: {len(duplicates)}")
        
        if len(duplicates) > 0:
            print("\nExample duplicate entries (first 3):")
            for _, dup in duplicates.head(3).iterrows():
                print(f"Signatories: {dup['Expanded_Signatories']}")
                print(f"Start Year: {dup['Start_Year']}")
                print(f"End Implementation Year: {dup['End_Implementation_Year_G']}")
                print("---")
        
        # Drop the temporary sorting column
        combined_rta = combined_rta.drop(columns=['sorted_signatories'])
        
        print(f"\nFinal number of unique RTAs: {len(combined_rta)}")
        
        # Additional validation checks
        invalid_starts = combined_rta[pd.isna(combined_rta['Start_Year'])]
        if len(invalid_starts) > 0:
            print(f"\nWarning: {len(invalid_starts)} RTAs have invalid start years")
        
        invalid_sigs = combined_rta[combined_rta['Expanded_Signatories'].isna()]
        if len(invalid_sigs) > 0:
            print(f"Warning: {len(invalid_sigs)} RTAs have invalid signatory lists")
        
        self.combined_rta = combined_rta
    
    # load processed RTA data
    def analyze_rta_overlaps(self, dataframes):
        """
        Analyze overlapping RTAs between a group of datasets
        Parameters:
        df1, df2 (pandas.DataFrame): RTA dataframes to compare
        Returns:
        dict: Statistics about overlapping agreements
        """
        # Create sets of unique agreements based on key identifying columns
        def create_agreement_set(df):
            return {
                (tuple(sorted(str(x).split(';'))),  # Sort signatories for consistent comparison
                 int(start_year) if pd.notna(start_year) else None)
                for x, start_year in zip(df['Expanded_Signatories'], df['Start_Year'])
            }
        
        set_agreement = set()
        set_redundant = set()
        
        for frame_path in dataframes:
            frame = pd.read_csv(frame_path)
            sframe = set(create_agreement_set(frame))
            set_agreement = set_agreement.union(sframe)
            set_redundant = set_redundant.intersection(sframe)
            
        # Find overlaps and unique agreements
        unique_agreements = len(set_agreement)
        redundant_agreements = len(set_redundant)
        
        return (unique_agreements, redundant_agreements)
    
    # Ensure year columns are converted to integer
    def convert_year_to_int(self, df, column):
        df[column] = pd.to_numeric(df[column], errors='coerce').fillna(np.nan).astype('Int64')  # Handle NaNs safely
        return df
    
    # Convert product codes to integers and strip spaces
    def clean_product_codes(self, df, column):
        df[column] = df[column].astype(str).str.strip()
        df[column] = pd.to_numeric(df[column], errors='coerce').fillna(np.nan).astype('Int64')  # Convert to integer safely
        return df
    
    def create_rta_lookup_table(self):
        """
        Pre-compute RTA coverage for all reporter-partner-year combinations,
        tracking both begin dates and phase-end dates.
        Process newer agreements first to ensure proper handling of overlaps.
        """
        years = range(1970, 2023)  # Extended to include 2022
        lookup_dict = {}
        
        rta_data = self.combined_rta        
        # Convert RTA years to integers
        rta_data = self.convert_year_to_int(rta_data, 'Start_Year')
        rta_data = self.convert_year_to_int(rta_data, 'End_Implementation_Year_G')
        
        # Pre-process expanded signatories
        cctable = self.country_codes_table.set_index('Code')
        def ccfilter(k):
            try:
                return cctable.loc[k,'ISO3']
            except:
                return None
        rta_data['processed_signatories'] = rta_data['Expanded_Signatories'].apply(
        lambda x: set(ccfilter(s.strip().zfill(3)) for s in x.split(';') if s.strip())
        )
        
        # Sort RTA data by Start_Year in descending order to process newer agreements first
        rta_data = rta_data.sort_values('Start_Year', ascending=False)
        
        for _, rta in rta_data.iterrows():
            signatories = rta['processed_signatories']
            begin_date = rta['Start_Year']
            phase_end = rta['End_Implementation_Year_G']
            
            if pd.isna(begin_date):
                continue
                
            for reporter in signatories:
                for partner in signatories:
                    if reporter != partner:
                        for year in years:
                            if year >= begin_date:
                                year_key = (str(reporter), str(partner), year)
                                # Always update with the latest RTA information
                                lookup_dict[year_key] = (1, begin_date, phase_end)
        
        return lookup_dict
    
    
    def fill_missing_mfn_tariffs(self):
        """
        Fills missing MFN  tariffsfor WTO-eligible partners by the closest preceding observation within each product-year group,
        """
        # Load WTO membership data
        wto_years = {k: v.year for k, v in self.wto_membership.items()}
        
        tariff_data = self.prepared_data
        
        # Ensure WTO eligibility using vectorized comparison for performance
        #tariff_data['Partner'] = tariff_data['Partner'].astype(str).str.zfill(3)
        tariff_data['Tariff Year'] = tariff_data['Tariff Year'].astype(int)
        
        tariff_data['wto_eligible'] = tariff_data['Partner'].map(wto_years).le(tariff_data['Tariff Year'])
    
        # Filter to only WTO-eligible rows 
        wto_data = tariff_data[tariff_data['wto_eligible']].copy()
        
        # Sort only as needed and apply forward fill within each Product-Year group
        wto_data.sort_values(['Product', 'Tariff Year', 'Partner'], inplace=True)
        wto_data['MFN'] = wto_data.groupby(['Product', 'Tariff Year'])['MFN'].ffill()
    
        # Update WTO-eligible rows in the main data with filled values
        tariff_data.loc[tariff_data['wto_eligible'], 'MFN'] = wto_data['MFN']
        
        return tariff_data  # Return without dropping `wto_eligible` to retain it in `filled_mfn_data`
    
    def fill_preferential_tariffs(self, tariff_data, rta_lookup_dict):
        """
        Processes by country pair and product, using most recent RTA's phase-end.
        After phase-in periods, forward fills tariffs when missing, updating with new observed values.
        """
        tariff_data = tariff_data.copy()
        tariff_data['pref_filled'] = tariff_data['PRF'].copy()
        tariff_data['rta_covered'] = 0
        tariff_data['start_year'] = np.nan
        tariff_data['end_year'] = np.nan
    
        for (reporter, partner), group in tariff_data.groupby(['Reporter', 'Partner']):
            print(f"Filling preferential tariffs for: Reporter {reporter}; Partner {partner}")
            # Get RTA periods for this country pair
            periods = []
            for year in sorted(group['Tariff Year'].unique()):
                year_key = (str(reporter), str(partner), year)
                if year_key in rta_lookup_dict:
                    rta_info = rta_lookup_dict[year_key]
                    if rta_info[0] == 1 and (not periods or rta_info[1] != periods[-1]['begin_date']):
                        periods.append({
                            'begin_date': rta_info[1],
                            'phase_end': rta_info[2]
                        })
    
            if not periods:
                continue
    
            # Sort by begin_date to ensure we get most recent RTA
            periods.sort(key=lambda x: x['begin_date'])
    
            for period in periods:
                begin_date = period['begin_date']
                phase_end = period['phase_end']
    
                # Get data for this period
                period_mask = (group['Tariff Year'] >= begin_date)
                period_data = group[period_mask]
                
                if period_data.empty:
                    continue
    
                # Mark RTA coverage
                idx = period_data.index
                tariff_data.loc[idx, ['rta_covered', 'start_year', 'end_year']] = (
                    1, begin_date, phase_end
                )
                
                pcounter = 0   
                # Process each product within period
                for product, prod_data in period_data.groupby('Product'):
                    pcounter += 1
                    if pcounter % 250 == 0:
                        print(f"Filling preferential tariffs for: Reporter {reporter}; Partner {partner}; Processed {pcounter} products so far.")
                    # Phase-in period
                    phase_mask = prod_data['Tariff Year'] <= phase_end
                    
                    if phase_mask.any():
                        phase_data = prod_data[phase_mask]
                        if phase_data['PRF'].notna().sum() >= 2:
                            # Interpolate within phase-in period
                            filled = phase_data['PRF'].interpolate(method='linear')
                            missing = phase_data['PRF'].isna()
                            tariff_data.loc[phase_data[missing].index, 'pref_filled'] = filled[missing]
    
                    # Post phase-in period -  forward fill
                    if not phase_mask.all():
                        post_data = prod_data[~phase_mask].sort_values('Tariff Year')
                        
                        # Get the last phase value if it exists
                        last_phase_value = prod_data[phase_mask]['PRF'].dropna().iloc[-1] if prod_data[phase_mask]['PRF'].notna().any() else np.nan
                        filled_values = post_data['PRF']
                        if not np.isnan(last_phase_value):
                            filled_values.iloc[0] = filled_values
                        filled_values = post_data['PRF'].ffill()

                        # Update only the missing values in post period
                        missing_mask = post_data['PRF'].isna()
                        if missing_mask.any():
                            tariff_data.loc[post_data[missing_mask].index, 'pref_filled'] = filled_values[missing_mask]
    
        return tariff_data
    
    
    
    def process_tariffs(self):
        print(f"Starting tariff processing for {self.file}")
        
        # Initial data loading and preprocessing
        tariff_data = self.prepared_data
        tariff_data.columns = tariff_data.columns.str.strip()
                
        tariff_data = self.convert_year_to_int(tariff_data, 'Tariff Year')
        tariff_data = tariff_data[(tariff_data['Tariff Year'] >= 1995) & (tariff_data['Tariff Year'] <= 2022)]
        
        # Store original values
        tariff_data.loc[:,'MFN_original'] = tariff_data['MFN'].copy()
        tariff_data.loc[:,'PRF_original'] = tariff_data['PRF'].copy()
        
        # Fill missing MFN tariffs and get WTO eligibility
        print("Filling missing MFN tariffs...")
        filled_mfn_data = self.fill_missing_mfn_tariffs()
        
        # Keep track of wto_eligible separately
        wto_eligible = filled_mfn_data['wto_eligible'].copy()
        mfn_fill = filled_mfn_data['MFN'].copy()
        
        # Fill preferential tariffs 
        # Create RTA lookup table
        print("Creating RTA lookup table...")
        rta_lookup_dict = self.create_rta_lookup_table()
        print("Filling preferential tariffs...")
        tariff_data = self.fill_preferential_tariffs(tariff_data, rta_lookup_dict)
    
        # Add back WTO eligibility
        tariff_data['wto_eligible'] = wto_eligible
        tariff_data.loc[mfn_fill.index,'MFN'] = mfn_fill
        
        # Select and rename columns for final output
        final_columns = [
            'Reporter', 'Partner', 'Product', 'Tariff Year',
            'MFN_original', 'PRF_original',
            'MFN', 'pref_filled'
        ]
        
        output_data = tariff_data[final_columns].rename(columns={
            'MFN_original': 'MFN_pre',
            'PRF_original': 'PRF_pre',
            'pref_filled': 'PRF_post',
            'MFN': 'MFN_post',
            'Tariff Year': 'year'
        })
       
         #  drop rows with missing MFN data or PRF data post-filling
        to_drop = output_data['MFN_post'].isna() & output_data['PRF_post'].isna()    
        output_data = output_data[~to_drop]
        
        outpath = os.path.join(self.outfolder, 'fill_' + self.file)
        output_data.to_csv(outpath, index=False)
        print(f"Processed data saved to {self.outfolder}")
        
        self.processed_tariffs = output_data

if __name__ == "__main__":
    path = r'/u/main/tradeadj/lev'
    file = 'sfull_ARG.csv'
    
    start = time.time()

    column_mapping = {
        # 'your_column_name': 'required_column_name'
        'importer': 'Reporter',      # Example: if your reporter column is called 'reporting_country'
        'exporter': 'Partner',         # Example: if your partner column is called 'partner_country'
        'hs6': 'Product',                 # Example: if your product column is called 'hs_code'
        'year': 'Tariff Year',               # Example: if your year column is called 'year'
        'mfn_st': 'MFN',                   # Example: if your MFN column is called 'mfn_rate'
        'prf_st': 'PRF'                   # Example: if your preferential rate column is called 'pref_rate'
    }

    tariff = tariffFill(path, file, column_mapping=column_mapping)
    
    print("Processing Tariffs")
    tariff.process_tariffs()

    end = time.time()

    total = (end-start)/60
    
    print(f"Total time {total}")