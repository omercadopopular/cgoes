# -*- coding: utf-8 -*-
"""
Created on Mon Dec  9 16:07:46 2024

@author: cbezerradegoes
"""

import pandas as pd
import numpy as np
import os

# Define file paths (update these to the actual paths of your downloaded files)
year = 2019
yy = str(year)[-2:]
path_intrvw = r'C:\Users\andre\OneDrive\UCSD\Research\cgoes\inflation-trump\data\cex\intrvw' + yy

# Stack fmli and mtbi files
fmli_data, mtbi_data = [], []
for quarter in range(2,6):

    if quarter == 5:
        yy = str(int(yy) + 1)
        quarter = 1
        
    print(yy, quarter)        
    fmli_file = "fmli" + yy + str(quarter) + ".csv"  # Family characteristics and income file
    df = pd.read_csv(os.path.join(path_intrvw,fmli_file))
    df['qintrvq'] = quarter
    df['year'] = year
    fmli_data.append(df)
fmli = pd.concat(fmli_data)
fmli.columns = [x.lower() for x in fmli.columns]

# Restric sample to relevant variables (from Jake's file)
fmli = fmli[['newid', 'cuid', 'finlwt21', 'hhid', 'liqudyrx', 'liquidx', 'creditb', 'creditx', 'credtyrx', 'irax', 'irayrx', 'num_auto', 'num_tvan', 'othastx', 'othfinx', 'othlnyrx', 'othlonx', 'othstyrx', 'owndwecq', 'othvehcq', 'stdntyrx', 'stockx', 'stockyrx', 'studntx', 'vehq', 'whlfyrx', 'wholifx', 'finatxem', 'fincbtax', 'fincbtxm', 'inc_rnkm', 'intrdvx', 'etotacx4', 'etotalc', 'etotalp', 'totex4cq', 'totex4pq', 'totexpcq', 'totexppq', 'age_ref', 'age2', 'educ_ref', 'educa2', 'fam_size', 'fam_type', 'high_edu', 'hisp_ref', 'horref1', 'horref2', 'marital1', 'perslt18', 'persot64', 'popsize', 'race2', 'ref_race', 'sex_ref', 'no_earnr', 'bls_urbn', 'lumpsumx', 'healthcq', 'healthpq', 'retpencq', 'retpenpq', 'lifinscq', 'lifinspq', 'cashcocq', 'cashcopq', 'misccq', 'miscpq', 'qintrvmo', 'qintrvyr', 'renteqvx', 'rendwecq', 'rendwepq','qintrvq','fftaxowe','fsalaryx','fsalarym','year','division','region','state','psu']] 

# check weights 
fullsamplewt = fmli.groupby('newid').first().finlwt21.sum()

#Keeps only households age 25-64 and households that are in all surveys
#fmli['age_sample'] = [(25 <= x <= 64) for x in fmli['age_ref']]
#fmli = fmli[ fmli['age_sample'] == True]
share = fmli.groupby('newid').first().finlwt21.sum() / fullsamplewt * 100
print(f"sample coverage: {share}")

############################
#Adjust income variables ###
############################

# Total amount of family income after taxes in the last 12 months (Collected data), including imputed data: fincbtxm
# Total amount of income received from salary or wages before deduction by family grouping, mean of imputation iterations - FSALARYM

# Exclude hh with missing income
fmli = fmli[~fmli['fincbtxm'].isnull()]
share = fmli.groupby('newid').first().finlwt21.sum() / fullsamplewt * 100
print(f"sample coverage: {share}")

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
fmli['total_spending'] = (fmli['totexpcq'] - fmli['total_contribution'] - fmli['neghealth'] - fmli['pension'] - fmli['life'])*4

# sample
fmli = fmli[~fmli['total_spending'].isnull()]
share = fmli.groupby('newid').first().finlwt21.sum() / fullsamplewt * 100
print(f"sample coverage: {share}")

##############3
# MTBI
############

yy = str(year)[-2:]
# Stack fmli and mtbi files
mtbi_data = []
for quarter in range(2,5):

    if quarter == 5:
        yy = str(int(yy) + 1)
        quarter = 1
        
    mtbi_file = "mtbi" + yy + str(quarter) + ".csv"  # Family characteristics and income file
    dtypes = {'UCC': str}
    mtbi = pd.read_csv(os.path.join(path_intrvw,mtbi_file), dtype=dtypes)
    mtbi['qintrvq'] = quarter
    mtbi['year'] = year
    mtbi_data.append(mtbi)
mtbi = pd.concat(mtbi_data)
mtbi.columns = [x.lower() for x in mtbi.columns]
# only include expenditures in diary survey to avoid double counting
mtbi = mtbi[ mtbi.cost_.isin(['D','I']) ]

group = ['year', 'qintrvq', 'newid', 'ucc']
mtbi = mtbi.groupby(group).agg({'cost': 'sum'}).reset_index(drop=False)

##############
# COMBINED FRAME
############

merge = pd.merge(mtbi, fmli, how='left', on=['year', 'qintrvq','newid'])

merge['cost_pos'] = [np.maximum(0,x) for x in merge['cost']]

consolidated = merge.groupby(['newid', 'region']).agg({'cost_pos': 'sum',
                                              'total_spending': 'sum',
                                              'fsalarym': 'mean', 
                                              'fincbtxm': 'mean', 
                                              'finlwt21': 'mean'}).reset_index(drop=False)

######### Summary Statistics:
    
def wt_sum(df, var, wt):
    w_total = df[wt].sum()
    w_sum = (df[var] * df[wt]).sum()
    
    w_mean = w_sum / w_total   
    w_se = ( ( ((df[var] * df[wt] - w_mean)**2 ).sum() ) / (w_total)**2 - 1 )**(1/2)
    
    return w_mean, w_se

output = dict()

agg = dict()
for var in ['cost_pos','fincbtxm','fsalarym']:
    print(f'{var}')
    mean, se = wt_sum(consolidated, var, 'finlwt21')
    print(f'weighted mean: {mean}, se: {se}\n')
    agg.update({var + '_mean': mean, var + '_se': se})
output.update({'agg': agg})

for name, group in consolidated.groupby(['region']):
    group_dict = dict()
    print(f'Region: {name}')
    for var in ['cost_pos','fincbtxm','fsalarym']:
        print(f'{var}')
        mean, se = wt_sum(group, var, 'finlwt21')    
        print(f'weighted mean: {mean}, se: {se}\n')
        group_dict.update({var + '_mean': mean, var + '_se': se})
    output.update({name: group_dict})

out_path = r'C:\Users\andre\OneDrive\UCSD\Research\cgoes\inflation-trump\temp_files'
output_frame = pd.DataFrame.from_dict(output)
output_frame.to_csv(os.path.join(out_path,'check.csv'))


############# cross income table

# Define income groups (replicate CEX income intervals)
# Use the FINCBTAX variable to group by income before taxes.
income_bins = [
    0, 15000, 30000, 40000, 50000, 70000, 100000, 150000, 200000, float("inf")
]
income_labels = [
    "<15,000", "15,000-29,999", "30,000-39,999", "40,000-49,999",
    "50,000-69,999", "70,000-99,999", "100,000-149,999", "150,000-199,999", "200,000+"
]

merge["bracket"] = pd.cut(
    merge["fincbtax"], bins=income_bins, labels=income_labels, right=False
)

mergedata = []
for name, group in merge.groupby(['bracket','ucc']):
    group['total_cost_b'] = group['cost'].sum()
    group['cost_shr_b'] = (group['cost'] / group['total_cost_b'])
    group['check_b'] = (group['cost'] /  group['total_cost_b']).sum()
    mergedata.append(group[['bracket','ucc','cost_shr_b','check_b']])
mergeframe = pd.concat(mergedata)

pd.merge(merge, mergeframe, how='left', on=['bracket','ucc'])
