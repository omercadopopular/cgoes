# -*- coding: utf-8 -*-
"""
Created on Mon Dec  9 16:07:46 2024

@author: cbezerradegoes
"""

import pandas as pd
import numpy as np
import os



# Define file paths (update these to the actual paths of your downloaded files)
year = 2020
yy = str(year)[-2:]
path_intrvw = r'C:\Users\andre\OneDrive\UCSD\Research\cgoes\inflation-trump\data\cex\intrvw' + yy

# Stack fmli and mtbi files
fmli_data, mtbi_data = [], []
for quarter in range(2,6):

    if quarter == 5:
        yy = str(int(yy) + 1)
        quarter = 1
        
    fmli_file = "fmli" + yy + str(quarter) + ".csv"  # Family characteristics and income file
    fmli = pd.read_csv(os.path.join(path_intrvw,fmli_file))
    fmli_data.append(fmli)
    mtbi_file = "mtbi" + yy + str(quarter) + ".csv"  # Family characteristics and income file
    mtbi = pd.read_csv(os.path.join(path_intrvw,mtbi_file))
    mtbi_data.append(mtbi)
fmli = pd.concat(fmli_data)
fmli.columns = [x.lower() for x in fmli.columns]
mtbi = pd.concat(mtbi_data)
mtbi.columns = [x.lower() for x in mtbi.columns]

# Restric sample to relevant variables (from Jake's file)
fmli = fmli[['newid', 'cuid', 'finlwt21', 'hhid', 'liqudyrx', 'liquidx', 'creditb', 'creditx', 'credtyrx', 'irax', 'irayrx', 'num_auto', 'num_tvan', 'othastx', 'othfinx', 'othlnyrx', 'othlonx', 'othstyrx', 'owndwecq', 'othvehcq', 'stdntyrx', 'stockx', 'stockyrx', 'studntx', 'vehq', 'whlfyrx', 'wholifx', 'finatxem', 'fincbtax', 'fincbtxm', 'inc_rnkm', 'intrdvx', 'etotacx4', 'etotalc', 'etotalp', 'totex4cq', 'totex4pq', 'totexpcq', 'totexppq', 'age_ref', 'age2', 'educ_ref', 'educa2', 'fam_size', 'fam_type', 'high_edu', 'hisp_ref', 'horref1', 'horref2', 'marital1', 'perslt18', 'persot64', 'popsize', 'race2', 'ref_race', 'region', 'sex_ref', 'no_earnr', 'bls_urbn', 'lumpsumx', 'healthcq', 'healthpq', 'retpencq', 'retpenpq', 'lifinscq', 'lifinspq', 'cashcocq', 'cashcopq', 'misccq', 'miscpq', 'qintrvmo', 'qintrvyr', 'renteqvx', 'rendwecq', 'rendwepq']] 

#Keeps only households age 25-64
fmli['sample'] = [(25 <= x <= 64) for x in fmli['age_ref']]

############################
#Adjust income variables ###
############################

fmli.loc[ fmli['fincbtax'] < 0 , 'fincbtax'] = np.nan # Total amount of family income before taxes in the last 12 months (Collected data)
fmli.loc[ fmli['fincbtxm'] < 0 , 'fincbtxm'] = np.nan # Total amount of family income before taxes (Imputed or collected data)
fmli['income'] = fmli['fincbtax'].copy()
fmli.loc[ fmli['income'].isnull() , 'income'] = fmli.loc[ fmli['income'].isnull() , 'fincbtxm'].copy()

# Missing data for lump sum transfers
fmli.loc[ fmli['lumpsumx'].isnull() , 'lumpsumx'] = 0 # Amount of lump sum payments from estates, trusts, royalties, alimony, prizes, or games of chance or from persons outside CU
fmli['income'] = fmli['income'] + fmli['lumpsumx']
fmli.loc[fmli['income'] > 0, 'income_ln'] = np.log(fmli.loc[fmli['income'] > 0, 'income'])

# Exclude hh with missing income
fmli.loc[fmli['income'].isnull(), 'sample'] = False

############################
#Adjust expenditure variables ###
############################

# contributions
fmli.loc[ fmli['cashcocq'].isnull() ,  'cashcocq' ] = 0 #
fmli.loc[ fmli['cashcopq'].isnull(),  'cashcopq' ] = 0 #
fmli['total_contribution'] = fmli['cashcocq'] + fmli['cashcopq']

# miscellaneous
fmli.loc[ fmli['misccq'].isnull() ,  'misccq' ] = 0 #
fmli.loc[ fmli['miscpq'].isnull(),  'miscpq' ] = 0 #
fmli['misc_outlay'] = fmli['misccq'] + fmli['miscpq']

# life insurance
fmli.loc[ fmli['lifinspq'].isnull() ,  'lifinspq' ] = 0 #
fmli.loc[ fmli['lifinscq'].isnull(),  'lifinscq' ] = 0 #
fmli['life'] = fmli['lifinspq'] + fmli['lifinscq']

# life insurance
fmli.loc[ fmli['lifinspq'].isnull() ,  'lifinspq' ] = 0 #
fmli.loc[ fmli['lifinscq'].isnull(),  'lifinscq' ] = 0 #
fmli['life'] = fmli['lifinspq'] + fmli['lifinscq']

# pension and social security
fmli.loc[ fmli['retpenpq'].isnull() ,  'retpenpq' ] = 0 #
fmli.loc[ fmli['retpencq'].isnull(),  'retpencq' ] = 0 #
fmli['pension'] = fmli['retpencq'] + fmli['retpenpq']

# healthcare care expenditure is sometimes negative
fmli[ 'neghealthpq' ] =  [np.minimum(0,x) for x in fmli[ 'healthpq' ]]
fmli[ 'neghealthcq' ] = [np.minimum(0,x) for x in fmli[ 'healthcq' ]]
fmli['neghealth'] = fmli['neghealthpq'] + fmli['neghealthcq']

# rent 
fmli['rent'] = fmli['rendwecq'] + fmli['rendwepq']

# expenditure
fmli['total_spending'] = fmli['totexppq'] + fmli['totexpcq'] - fmli['total_contribution'] - fmli['neghealth'] - fmli['pension'] - fmli['life']

# sample
fmli.loc[fmli['total_spending'] < 0, 'sample'] = False





# Step 1: Load the data

# Important variables:
"""    
    C - CU id
    NEWID - CU id
    FINLWT21 - weight
    FAM_SIZE - Number of Members in CU
    FINCBTAX - income before taxes
    FINCATXM - income after taxes
    TOTEXPCQ - Total expenditures this quarter
    INC_RANK - Weighted cumulative percent ranking based on total current income before taxes
"""

# A. CU Characteristics file (fmli)

# Define income groups (replicate CEX income intervals)
# Use the FINCBTAX variable to group by income before taxes.
income_bins = [
    0, 15000, 30000, 40000, 50000, 70000, 100000, 150000, 200000, float("inf")
]
income_labels = [
    "<15,000", "15,000-29,999", "30,000-39,999", "40,000-49,999",
    "50,000-69,999", "70,000-99,999", "100,000-149,999", "150,000-199,999", "200,000+"
]

fmli["income_group"] = pd.cut(
    fmli["FINCBTAX"], bins=income_bins, labels=income_labels, right=False
)

# B. MERGE FILES

# merge variables
frame = pd.merge(fmli, mtbi, how='right', on='NEWID', suffixes=['_f','_m'])

# C. CREATE EXPENDITURE SHARES BY NEWID


mergedata = []
for name, group in frame.groupby(['NEWID','UCC']):
    group['COST_SHR'] = (group['COST'] / group['TOTEXPCQ'])
    group['CHECK'] = (group['COST'] / group['TOTEXPCQ']).sum()
    mergedata.append(group[['NEWID','UCC','COST_SHR','CHECK']])
mergeframe = pd.concat(mergedata).sort_values('NEWID')

frame = pd.join(frame.sort_values('NEWID'),mergeframe, on='NEWID', how='left')
    
# Step 2: Filter Midwest region
# REGION codes are explained in the FMLI codebook: Midwest is typically coded as 2.
midwest_fmli = fmli[fmli["REGION"] == 2]



# Step 4: Merge expenditure data (MTBI) with filtered Midwest FMLI
# Use CU_ID (Consumer Unit ID) to merge datasets.
merged_data = pd.merge(midwest_fmli, mtbi, on="CU_ID", how="inner")

# Step 5: Calculate average expenditures by income group
# Specify the list of expenditure variables based on the CEX codebook
expenditure_columns = [
    "FOOD", "HOUSING", "TRANSPORTATION", "HEALTHCARE", "ENTERTAINMENT"
    # Add all relevant categories from Table 3114
]

# Group by income group and calculate mean for each category
average_expenditures = merged_data.groupby("income_group")[expenditure_columns].mean()

# Step 6: Add additional characteristics (e.g., CU_SIZE, AGE_REF, etc.)
# Example: Average number of consumer unit members
additional_characteristics = ["CU_SIZE", "AGE_REF"]
additional_stats = midwest_fmli.groupby("income_group")[additional_characteristics].mean()

# Step 7: Combine results and save to Excel
final_table = pd.concat([average_expenditures, additional_stats], axis=1)
final_table.to_excel("Midwest_Expenditures_Table_3114.xlsx")

print("Table replicated and saved as 'Midwest_Expenditures_Table_3114.xlsx'")
