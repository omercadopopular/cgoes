import modin.pandas as pd
import numpy as np
import os

os.chdir(r'C:\Users\andre\OneDrive\UCSD\Research\cgoes\dynamic-adjustment-trade-shocks\eu-tariffs\trottner')

from tariff_filling_functions import (load_processed_rta_data, process_tariffs)

# Configuration dictionary - users can modify this directly in the code
column_mapping = {
    # 'your_column_name': 'required_column_name'
    'importer': 'Reporter',      # Example: if your reporter column is called 'reporting_country'
    'exporter': 'Partner',         # Example: if your partner column is called 'partner_country'
    'hs6': 'Product',                 # Example: if your product column is called 'hs_code'
    'year': 'Tariff Year',               # Example: if your year column is called 'year'
    'mfn_st': 'MFN',                   # Example: if your MFN column is called 'mfn_rate'
    'prf_st': 'PRF'                   # Example: if your preferential rate column is called 'pref_rate'
}

# File paths configuration - users can modify these
FILE_PATHS = {
    'tariff_data': r'C:\Users\andre\OneDrive\UCSD\Research\cgoes\dynamic-adjustment-trade-shocks\eu-tariffs\data\wits-out\full_ARE.csv',
    'output_file': r'C:\Users\andre\OneDrive\UCSD\Research\cgoes\dynamic-adjustment-trade-shocks\eu-tariffs\data\wits-out\full_ARET.csv',
    'rta_files': [
        r'C:\Users\andre\OneDrive\UCSD\Research\cgoes\dynamic-adjustment-trade-shocks\eu-tariffs\trottner\rta_processed_WTO.csv',
        r'C:\Users\andre\OneDrive\UCSD\Research\cgoes\dynamic-adjustment-trade-shocks\eu-tariffs\trottner\rta_processed_DESIS.csv',
    ]
}

def prepare_tariff_data(input_df, column_mapping=column_mapping):
    """
    Prepare  tariff data to match required format
    """
    df = input_df.copy()
    
    # Rename columns according to mapping
    df = df.rename(columns=column_mapping)
    
    # Verify required columns exist
    required_columns = {
        'Reporter': 'Country code reporting the tariff',
        'Partner': 'Country code facing the tariff',
        'Product': 'Product code (HS classification)',
        'Tariff Year': 'Year of the tariff',
        'MFN': 'Most Favored Nation tariff rate',
        'PRF': 'Preferential tariff rate'
    }
    
    missing_cols = [col for col in required_columns if col not in df.columns]
    if missing_cols:
        print("\nMissing required columns:")
        for col in missing_cols:
            print(f"- {col}: {required_columns[col]}")
        raise ValueError("Please update COLUMN_MAPPING at the top of the script to include all required columns")
    
    return df

def main(interactive=False):
    """
    Main function to process tariff data
    Parameters:
    -----------
    interactive : bool
        If True, prompts user for inputs
        If False, uses configurations from top of script
    """
    if interactive:
        # [Previous interactive code remains the same]
        pass
    else:
        try:
            print("Loading your tariff data...")
            raw_tariff_data = pd.read_csv(FILE_PATHS['tariff_data'])
            print(f"Loaded {len(raw_tariff_data):,} rows")
            
            print("\nPreparing your tariff data...")
            prepared_data = prepare_tariff_data(raw_tariff_data, column_mapping)
            
            print("\nLoading RTA data...")
            rta_data = load_processed_rta_data(FILE_PATHS['rta_files'])
            
            print("\nProcessing tariffs...")
            final_data = process_tariffs(
                prepared_data,
                concordance_dict_by_nomen=None,
                rta_data=rta_data,
                output_path=FILE_PATHS['output_file']
            )
            
            # Print summary statistics
            print("\nProcessing complete! Summary:")
            print(f"Original rows: {len(raw_tariff_data):,}")
            print(f"Processed rows: {len(final_data):,}")
            print(f"\nRTA coverage by year:")
            coverage = final_data.groupby('year')['rta_covered'].mean() * 100
            print(coverage)
            
            print(f"\nProcessed data saved to: {FILE_PATHS['output_file']}")
            
        except Exception as e:
            print(f"\nError during processing: {str(e)}")
            print("Please check your configuration and data and try again.")

if __name__ == "__main__":
    # Choose whether to run in interactive mode or use configuration from script
    USE_INTERACTIVE_MODE = False  # Set to True if you want interactive prompts
    
    # Example usage of your data:
    """
    # If  data looks like this:
    data = {
        'reporting_country': ['840', '840', ...],  # USA
        'partner_country': ['124', '484', ...],    # CAN, MEX
        'hs_code': ['010120', '010120', ...],
        'year': [2018, 2018, ...],
        'mfn_rate': [2.5, 2.5, ...],
        'pref_rate': [0.0, 0.0, ...]
    }
    
    # Then  COLUMN_MAPPING should look like:
    COLUMN_MAPPING = {
        'reporting_country': 'Reporter',
        'partner_country': 'Partner',
        'hs_code': 'Product',
        'year': 'Tariff Year',
        'mfn_rate': 'MFN',
        'pref_rate': 'PRF'
    }
    """
    
    main(interactive=USE_INTERACTIVE_MODE)