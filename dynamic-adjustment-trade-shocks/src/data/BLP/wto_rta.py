"""
Prepare WTO and RTA data required for imputing tariffs
"""

#%%
import numpy as np
from datetime import datetime
import os
import glob
import pandas as pd

#%%
class wtodata():
    def __init__(self, rtadata_folder):
        self.rtadata_folder = rtadata_folder
        print("Downloading country codes and storing WTO membership references")
        self.get_country_codes()
        self.load_wto_membership()

    def get_country_codes(self):
        storage_options = {'User-Agent': 'Mozilla/5.0'}
        url = r'https://wits.worldbank.org/wits/wits/witshelp/content/codes/country_codes.htm'
        country_codes_table = pd.read_html(url, storage_options=storage_options, header=1)[0]
        country_codes_table['Code'] = country_codes_table.Code.astype(str).str.zfill(3)
        self.country_codes_table = country_codes_table

    def load_wto_membership(self):
        """
        Create a dictionary of WTO membership dates 
        Data source: World Trade Organization (https://www.wto.org/english/thewto_e/whatis_e/tif_e/org6_e.htm)
        """

        setc = set(self.country_codes_table.Code)
        cctable = self.country_codes_table.set_index('Code')
        cctable.rename(columns={'Country Name':'Name'}, inplace=True)

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
        cctable['wto_mem_date'] = cctable['ISO3'].map(self.wto_membership)
        self.wto_df = cctable

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
        df[column] = pd.to_numeric(df[column], errors='coerce').fillna(np.nan).astype('Int16')  # Handle NaNs safely
        return df

    def create_rta_lookup_table(self):
        """
        Pre-compute RTA coverage for all reporter-partner-year combinations,
        tracking both begin dates and phase-end dates.
        Process newer agreements first to ensure proper handling of overlaps.
        """        
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
                return ""
        rta_data['processed_signatories'] = rta_data['Expanded_Signatories'].apply(
            lambda x: [ccfilter(s.strip().zfill(3)) for s in x.split(';') if s.strip()]
        )
        rta_data = rta_data.explode('processed_signatories')
        rta_data = rta_data[['RTA Name','Start_Year','End_Implementation_Year_G','processed_signatories']]
        rta_data.rename(columns={'RTA Name':'rta', 'Start_Year':'start_year',
            'End_Implementation_Year_G':'end_impl_year',
            'processed_signatories':'signatories'}, inplace=True)
        rta_data = rta_data[rta_data['signatories']!=""]
        # This allows saving rta names as value labels
        rta_data['rta'] = rta_data['rta'].astype('category')
        return rta_data


#%%
if __name__ == "__main__":
    outdir = r'data/work/WTO/'
    rtadata_folder = r'data/work/rta-data/'
    d = wtodata(rtadata_folder)
    df = d.wto_df
    df.to_stata(os.path.join(outdir, 'wto_mem_date.dta'), write_index=False,
                convert_dates={'wto_mem_date':'%td'})

    d.load_processed_rta_data()
    rta = d.create_rta_lookup_table()
    rta.to_stata(os.path.join(outdir, 'wto_rta.dta'), write_index=False, version=118)
