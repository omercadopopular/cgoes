mport pandas as pd
import numpy as np
from pathlib import Path

def create_formats():
    """Create format dictionaries equivalent to SAS formats"""
    inc_format = {
        '01': ['01', '10'],
        '02': ['02', '10'],
        '03': ['03', '10'],
        '04': ['04', '10'],
        '05': ['05', '10'],
        '06': ['06', '10'],
        '07': ['07', '10'],
        '08': ['08', '10'],
        '09': ['09', '10']
    }
    return inc_format

def read_stub_file(year, drive_path):
    """Read and process the stub parameter file"""
    stub_df = pd.read_fwf(
        f"{drive_path}/CE-HG-Diary-{year}.TXT",
        colspecs=[(0, 1), (3, 4), (6, 66), (69, 75), (82, 83), (88, 95)],
        names=['TYPE', 'LEVEL', 'TITLE', 'UCC', 'SURVEY', 'GROUP']
    )
    
    # Filter and create LINE numbers
    stub_df = stub_df[stub_df['TYPE'] == '1']
    stub_df = stub_df[stub_df['GROUP'].isin(['CUCHARS', 'FOOD', 'EXPEND', 'INCOME'])]
    stub_df['COUNT'] = range(10000, 10000 + len(stub_df))
    stub_df['LINE'] = stub_df['COUNT'].astype(str) + stub_df['LEVEL']
    
    return stub_df

def process_fmld_files(year, drive_path):
    """Process FMLD (Family) files"""
    yr = str(year)[2:4]
    
    # Read all quarterly FMLD files
    dfs = []
    for quarter in range(1, 5):
        df = pd.read_sas(f"{drive_path}/DIARY{yr}/FMLD{yr}{quarter}.sas7bdat")
        dfs.append(df)
    
    fmly_df = pd.concat(dfs, ignore_index=True)

    income_bins = [
        0, 15000, 30000, 40000, 50000, 70000, 100000, 150000, 200000, float("inf")
    ]
    income_labels = [
        "<15,000", "15,000-29,999", "30,000-39,999", "40,000-49,999",
        "50,000-69,999", "70,000-99,999", "100,000-149,999", "150,000-199,999", "200,000+"
    ]
    
    fmly_df["INCLASS"] = pd.cut(
        fmly_df["FINCBEFM"], bins=income_bins, labels=income_labels, right=False
    )
    
    """
    FINCBEFM - Total amount of family income before taxes in the last 12 months (Imputed or collected data)
    
    Alternatively, use
    
    FINCBEFX -	Total amount of family income before taxes in the last 12 months (Collected data)
    """

    # Create INCLASS based on FINCBEFM
    conditions = [
        (fmly_df['FINCBEFM'] < 15000),
        (fmly_df['FINCBEFM'].between(15000, 29999)),
        (fmly_df['FINCBEFM'].between(30000, 39999)),
        (fmly_df['FINCBEFM'].between(40000, 49999)),
        (fmly_df['FINCBEFM'].between(50000, 69999)),
        (fmly_df['FINCBEFM'].between(70000, 99999)),
        (fmly_df['FINCBEFM'].between(100000, 149999)),
        (fmly_df['FINCBEFM'].between(150000, 199999)),
        (fmly_df['FINCBEFM'] >= 200000)
    ]
    
    values = ['01', '02', '03', '04', '05', '06', '07', '08', '09']
    fmly_df['INCLASS'] = np.select(conditions, values)
    
    # Adjust weights
    weight_cols = [f'WTREP{str(i).zfill(2)}' for i in range(1, 45)] + ['FINLWT21']
    rep_cols = [f'REPWT{i}' for i in range(1, 46)]
    
    for old_col, new_col in zip(weight_cols, rep_cols):
        fmly_df[new_col] = np.where(fmly_df[old_col] > 0, fmly_df[old_col] / 4, 0)
    
    return fmly_df[['NEWID', 'INCLASS'] + rep_cols]

def process_expenditure_files(year, drive_path):
    """Process expenditure files (EXPD and DTBD)"""
    yr = str(year)[2:4]
    
    dfs = []
    # Read EXPD files
    for quarter in range(1, 5):
        expd_df = pd.read_sas(f"{drive_path}/DIARY{yr}/EXPD{yr}{quarter}.sas7bdat")
        dfs.append(expd_df)
        
        # Read DTBD files and rename AMOUNT to COST
        dtbd_df = pd.read_sas(f"{drive_path}/DIARY{yr}/DTBD{yr}{quarter}.sas7bdat")
        dtbd_df = dtbd_df.rename(columns={'AMOUNT': 'COST'})
        dfs.append(dtbd_df)
    
    expend_df = pd.concat(dfs, ignore_index=True)
    return expend_df[['NEWID', 'UCC', 'COST']]

def calculate_weighted_expenditures(fmly_df, expend_df):
    """Calculate weighted expenditures"""
    merged_df = pd.merge(fmly_df, expend_df, on='NEWID', how='inner')
    merged_df['COST'] = merged_df['COST'].fillna(0)
    
    # Calculate weighted costs
    rep_cols = [f'REPWT{i}' for i in range(1, 46)]
    rcost_cols = [f'RCOST{i}' for i in range(1, 46)]
    
    for rep_col, rcost_col in zip(rep_cols, rcost_cols):
        merged_df[rcost_col] = np.where(
            merged_df[rep_col] > 0,
            merged_df[rep_col] * merged_df['COST'],
            0
        )
    
    return merged_df

def main(year=2018, drive_path="C:/2018_CEX"):
    # Create formats
    inc_format = create_formats()
    
    # Read stub file
    stub_df = read_stub_file(year, drive_path)
    
    # Process family files
    fmly_df = process_fmld_files(year, drive_path)
    
    # Process expenditure files
    expend_df = process_expenditure_files(year, drive_path)
    
    # Calculate weighted expenditures
    results_df = calculate_weighted_expenditures(fmly_df, expend_df)
    
    # Calculate populations and means
    pop_df = results_df.groupby('INCLASS', as_index=False).agg({
        f'REPWT{i}': 'sum' for i in range(1, 46)
    })
    
    # Calculate aggregates
    agg_df = results_df.groupby(['UCC', 'INCLASS'], as_index=False).agg({
        f'RCOST{i}': 'sum' for i in range(1, 46)
    })
    
    return {
        'populations': pop_df,
        'aggregates': agg_df,
        'stub': stub_df
    }

if __name__ == "__main__":
    results = main()