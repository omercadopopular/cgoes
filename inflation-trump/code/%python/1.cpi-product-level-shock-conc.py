# -*- coding: utf-8 -*-
"""
Created on Mon Dec  9 16:07:46 2024

@author: cbezerradegoes
"""

import pandas as pd
import numpy as np
import os

# Define file paths
#path = r'C:\Users\andre\OneDrive\research\cgoes\inflation-trump'
path = r'C:\Users\cbezerradegoes\OneDrive\research\cgoes\inflation-trump'
files_inflation = ['cu.data.11.USFoodBeverage', 'cu.data.12.USHousing',
	'cu.data.13.USApparel', 'cu.data.14.USTransportation', 'cu.data.15.USMedical',
    'cu.data.16.USRecreation', 'cu.data.17.USEducationAndCommunication',
	'cu.data.18.USOtherGoodsAndServices']
file_conc = r'conc\cex\ce-cpi-concordance-2020.xlsx'


#############################
# 1. Calculate cumulative pct change for each CPI product 
#############################

def process_bls(path, file_input):
    file = file_input + '.txt'

    # Import file
    df = pd.read_table(os.path.join(path,file), low_memory=False)
    df = df.drop_duplicates()

    # Adjust columns
    df.columns = [x.replace(' ','') for x in df.columns]
    
    # Adjust series_id
    df.series_id = [x.replace(' ','') for x in df.series_id]
    
    # Convert values to numeric
    df['value'] = pd.to_numeric(df['value'], errors='coerce')
    
    # Convert to datetime, sort values
    months = ['M01', 'M02', 'M03', 'M04', 'M05', 'M06', 'M07', 'M08', 'M09', 'M10', 'M11', 'M12']
    df = df[df['period'].isin(months)]
    df.loc[:,'month'] = df['period'].str[1:].astype(int)
    df['date'] = pd.to_datetime(df[['year', 'month']].assign(day=1))
    
    """
    halves = ['S01', 'S02']
    df = df[df['period'].isin(halves)]
    df['half'] = df['period'].str[1:].astype(int)
    
    # Map halves to quarters (Q1 for S01, Q3 for S02)
    df['quarter'] = df['half'].map({1: 1, 2: 3})
    df.loc[:,'date'] = pd.to_datetime(df['year'].astype(str) + 'Q' + df['quarter'].astype(str))
    """
    
    # Define the base period explicitly
    base = df.loc[(df['year'] == 2018) & (df['month'] == 1), ['series_id', 'value']]
    base = base.rename(columns={'value': 'base_value'})
    df = df.merge(base, on='series_id', how='left')
    
    # Calculate percentage change
    df['cumulative_pct_change'] = (df['value'] / df['base_value'] - 1) * 100
    
    # Extract final cumulative change
    df_shock = df.loc[(df['year'] == 2024) & (df['month'] == 10), ['series_id', 'cumulative_pct_change']]
    
    return df_shock

# Loop over input files
frames = []
for file in files_inflation:
    file_input = os.path.join(r'data\CPI', file)
    print('processing {}'.format(file))
    frames.append(process_bls(path, file_input))
df_shock = pd.concat(frames)

#############################
# 2. Use concordance to merge shocks and UCC
#############################

# Define file paths

# Load concordance table
df_conc = pd.read_excel(os.path.join(path, file_conc), skiprows=1, skipfooter=3)
df_conc.loc[:,'series_id'] = ['CUSR0000SE' + x[:-1] for x in df_conc['ELI']]

# Merge files
df_merge = df_conc.merge(df_shock, on='series_id', how='left').dropna()

# Export to feather
df_merge.to_feather(os.path.join(path, r'data\temp_files\shock-ucc.feather'))
