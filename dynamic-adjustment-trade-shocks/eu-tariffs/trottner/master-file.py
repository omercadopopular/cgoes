from tariffFillServerBase import tariffFill
import time
import os

def walker(folder_path):
    """
    Walks through a given folder and lists all CSV files starting with 'full_'.

    Args:
        folder_path (str): The folder path to search.

    Returns:
        list: A list of full paths to the matching CSV files.
    """
    csv_files = []
    
    # Walk through directory structure
    for root, _, files in os.walk(folder_path):
        for file in files:
            if file.startswith("full_") and file.endswith(".csv"):
                csv_files.append(os.path.join(root, file))
    
    return csv_files

if __name__ == "__main__":
    path = r'/u/main/tradeadj/lev'
    inpath = r'/u/main/tradeadj/lev/temp_files/out'
    
    files = walker(inpath)
       
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
    
    for file in files:
        tariff = tariffFill(path, file, column_mapping=column_mapping)    
        print(f"Processing {file}")
        tariff.process_tariffs()

    end = time.time()

    total = (end-start)/60
    
    print(f"Total time {total}")