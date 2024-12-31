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
                aggregated_data = level_6_data.groupby(['Classification','Partner ISO', 'Commodity Code', 'Commodity']).agg(
                    {'Netweight (kg)': 'sum', 'Trade Value (US$)': 'sum'}
                )
                
                # Save consolidated data
                aggregated_data.to_csv(output_file)
            
            except FileNotFoundError:
                print(f"File not found: {input_file}")
            except Exception as e:
                print(f"Error consolidating data for {partner} in {self.base_year}: {e}")

run = Comtrade()
run.process()
