# -*- coding: utf-8 -*-
"""
Created on Fri Jan 17 15:00:03 2025

@author: cbezerradegoes
"""

basePath = r'C:\Users\cbezerradegoes\OneDrive\research\cgoes\inflation-trump'

cpiPath = basePath + r'\data\cpi'
cpiSeries = 'cu.data.0.Current.txt'
cpiArea = 'cu.area'
cbsa2Cpi = 'cbsa2cpi.xlsx'

fipsPath = basePath + r'\data\fips-msa'
fipsConc = 'cbsa2fipsxw.dta'

electionPath = basePath + r'\data\election-online'
election2020 = '2020_US_County_Level_Presidential_Results.txt'
election2024 = '2024_US_County_Level_Presidential_Results.txt'

import pandas as pd
import os
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt

areaFrame = pd.read_csv(os.path.join(cpiPath, cpiArea), sep='\t')
seriesFrame = pd.read_csv(os.path.join(cpiPath, cpiSeries), sep='\t')
seriesFrame.columns = [x.replace(' ','') for x in seriesFrame.columns]
seriesFrame['series_id'] = [x.replace(' ','') for x in seriesFrame['series_id']]

"""

Calculate CPI by each MSA that the BEA
calculates regional prices for

"""


# Extract MSA
mask = [x[0] == 'S' for x in areaFrame['area_code']]
csaFrame = areaFrame[mask]
msaSet = set(csaFrame['area_code'])

# Extract CPI by MSA
seriesSet = [f'CUUS{x}SA0' for x in msaSet]
csaCpiFrame = seriesFrame[ seriesFrame[seriesFrame.columns[0]].isin(seriesSet) ]
csaCpiFrame['area_code'] = [x[4:8] for x in csaCpiFrame['series_id']]
cbsa2cpiFrame = pd.read_excel(os.path.join(cpiPath, cbsa2Cpi))
csaCpiFrame = pd.merge(csaCpiFrame, cbsa2cpiFrame, on='area_code', how='left').dropna(subset=['cbsa_code'])
csaCpiFrame['cbsa_code'] = [str(int(x)) for x in csaCpiFrame['cbsa_code']]

# Keep only 2019 and 2024, calculate cumulative change
csaCpiFrame = csaCpiFrame.groupby(['series_id','year'], as_index=False).first()
csaCpiFrame = csaCpiFrame[ (csaCpiFrame['year'] == 2021) | (csaCpiFrame['year'] == 2024)  ]
csaCpiFrame['value_base'] = csaCpiFrame.groupby(['series_id']).shift()['value']
csaCpiFrame['value_g'] = (csaCpiFrame['value'] / csaCpiFrame['value_base'] - 1) * 100
csaCpiFrame = csaCpiFrame[ csaCpiFrame['year'] == 2024 ]

"""

Consolidate election data for those MSA,
calculate percentage swing in republican share

"""

dtypes = {'county_fips': 'str'}
cols = ['state_name', 'county_fips', 'county_name', 'votes_gop', 'votes_dem',
       'total_votes']

# Import 2024 election data
election24Frame = pd.read_csv(os.path.join(electionPath, election2024), dtype=dtypes)
election24Frame = election24Frame[cols]

# Import 2020 election data
election20Frame = pd.read_csv(os.path.join(electionPath, election2020), dtype=dtypes)
election20Frame = election20Frame[cols]

# Merge both elections data
electionFrame = pd.merge(election24Frame, election20Frame, on=['state_name', 'county_fips', 'county_name'],
         suffixes=['_24','_20'], how='left')

# Import FIPS to CBSA concordance
fipsFrame = pd.read_stata(os.path.join(fipsPath, fipsConc))
fipsFrame['county_fips']= fipsFrame['fipsstatecode'] + fipsFrame['fipscountycode']
fipsFrame = fipsFrame.rename(columns={'cbsacode': 'cbsa_code'})
fipsFrame = fipsFrame[['cbsa_code','county_fips']]

# Merge with elections data
mergeFrame = pd.merge(electionFrame, fipsFrame, on='county_fips', how='left')
mergeFrame = mergeFrame.groupby(['cbsa_code'], as_index=False).sum()[['cbsa_code','votes_gop_24',
       'votes_dem_24', 'total_votes_24', 'votes_gop_20', 'votes_dem_20',
       'total_votes_20']]

# Calculate votes growth
mergeFrame['votes_gop_g'] = (mergeFrame['votes_gop_24'] / mergeFrame['total_votes_24'] - mergeFrame['votes_gop_20'] / mergeFrame['total_votes_20'])*100
mergeFrame['votes_dem_g'] = (mergeFrame['votes_dem_24'] / mergeFrame['total_votes_24'] - mergeFrame['votes_dem_20'] / mergeFrame['total_votes_20'])*100

"""
Consolidate election data for those MSA,
calculate percentage swing in republican share
"""

finalFrame = pd.merge(csaCpiFrame, mergeFrame, how='left', on='cbsa_code')
finalFrame.replace([np.inf, -np.inf], np.nan, inplace=True)
finalFrame.dropna(subset=['votes_gop_g'], inplace=True)

"""

Plot correlations

"""

# Plot
plt.figure(figsize=(8, 6))
sns.regplot(data=finalFrame, x='value_g', y='votes_gop_g', color='red')  # ci=None disables confidence interval if not needed

# Adding labels to the data points
#for i in range(len(finalFrame)):
#    plt.text(y=finalFrame['votes_gop_g'][i], x=finalFrame['value_g'][i], s=finalFrame['area_name'][i], 
#             fontsize=10, color='red', ha='right', va='bottom')

plt.title('Regression Plot with Data Labels', fontsize=16)
plt.xlabel('x', fontsize=14)
plt.ylabel('y', fontsize=14)
plt.grid(True, alpha=0.5)
plt.tight_layout()

# Show plot
plt.show()


# Plot
plt.figure(figsize=(8, 6))
sns.regplot(data=finalFrame, x='value_g', y='votes_dem_g', color='blue')  # ci=None disables confidence interval if not needed

# Adding labels to the data points
#for i in range(len(finalFrame)):
#    plt.text(y=finalFrame['votes_gop_g'][i], x=finalFrame['value_g'][i], s=finalFrame['area_name'][i], 
#             fontsize=10, color='red', ha='right', va='bottom')

plt.title('Regression Plot with Data Labels', fontsize=16)
plt.xlabel('x', fontsize=14)
plt.ylabel('y', fontsize=14)
plt.grid(True, alpha=0.5)
plt.tight_layout()

# Show plot
plt.show()

