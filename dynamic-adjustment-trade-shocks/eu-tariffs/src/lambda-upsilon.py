# -*- coding: utf-8 -*-
"""
Created on Sat Dec 28 09:38:34 2024

@author: andre
"""

Path = r'C:\Users\andre\OneDrive\UCSD\Research\cgoes\dynamic-adjustment-trade-shocks\eu-tariffs\trottner\temp_files'
File = 'euenlarge_isd_base.dta'

import pandas as pd
import os
import seaborn as sns
import matplotlib.pyplot as plt
import numpy as np

nms = ['CYP', 'CZE', 'EST', 
            'HUN', 'LVA', 'LTU', 'MLT', 'POL', 'SVK', 'SVN']

maxh = 20

df = pd.read_stata(os.path.join(Path,File))
df = df[ df.horz < maxh ]
df = df[ (df.sorc_iso3 == df.dest_iso3) & (df.sorc_iso3.isin(nms)) ]
initial = df.loc[df['horz'] == 1,['sorc_iso3', 'dest_iso3', 'sorc_i32','lambda','upsilon']]
df = df.merge( initial, how='left', on=['sorc_iso3', 'dest_iso3', 'sorc_i32'], suffixes=['','0'])
df['dlambda'] = [(x - y)*100 for x,y in zip(df['lambda'],df['lambda0'])]
df['dupsilon'] = [(x - y)*100 for x,y in zip(df['upsilon'],df['upsilon0'])]
# Create a figure with two subplots side by side

cols = {
    'dlambda': r'Domestic Expenditure Share $\lambda_{dd}$',
    'dupsilon': r'Domestic Procurement Share $\upsilon_{dd}$'
    }

mdf = pd.melt(df[['dlambda','dupsilon','horz']].rename(columns=cols), id_vars=['horz'])
outpath = r'C:\Users\andre\OneDrive\UCSD\Research\cgoes\dynamic-adjustment-trade-shocks\eu-tariffs\trottner\figs'

#######################3


eu_codes = ['AUT', 'BEL', 'CYP', 'CZE', 'DNK', 'EST', 'FIN', 'FRA', 'DEU', 'GRC', 'HUN', 'IRL', 'ITA', 'LVA', 'LTU', 'LUX', 'MLT', 'NLD', 'POL', 'PRT', 'SVK', 'SVN', 'ESP', 'SWE']
eu15 = list( set(eu_codes).difference(set(nms)) )

df = pd.read_stata(os.path.join(Path,File))
df = df[ df.horz < maxh ]
df = df[ (df.sorc_iso3 == df.dest_iso3) & (df.sorc_iso3.isin(eu15)) ]
initial = df.loc[df['horz'] == 1,['sorc_iso3', 'dest_iso3', 'sorc_i32','lambda','upsilon']]
df = df.merge( initial, how='left', on=['sorc_iso3', 'dest_iso3', 'sorc_i32'], suffixes=['','0'])
df['dlambda'] = [(x - y)*100 for x,y in zip(df['lambda'],df['lambda0'])]
df['dupsilon'] = [(x - y)*100 for x,y in zip(df['upsilon'],df['upsilon0'])]
# Create a figure with two subplots side by side

cols = {
    'dlambda': r'Domestic Expenditure Share $\lambda_{dd}$',
    'dupsilon': r'Domestic Procurement Share $\upsilon_{dd}$'
    }

mdf2 = pd.melt(df[['dlambda','dupsilon','horz']].rename(columns=cols), id_vars=['horz'])


#######################3


# Create a figure with two subplots side by side
fig, axes = plt.subplots(1, 2, figsize=(16, 6), sharey=False)

# Plot for 'nms' countries
sns.boxplot(
    ax=axes[0],
    data=mdf,
    y='value',
    x='horz',
    hue='variable',
    saturation=0.75,
    width=1,
    whis=0,
    showfliers=False
)
axes[0].axvline(x=9, color='red', linestyle='--', linewidth=2, alpha=0.75)
axes[0].set_title('NMS Countries', fontsize=14)
axes[0].set_ylabel('Cumulative percentage change', fontsize=14)
axes[0].set_xlabel('', fontsize=12)

# Plot for 'eu15' countries
sns.boxplot(
    ax=axes[1],
    data=mdf2,
    y='value',
    x='horz',
    hue='variable',
    saturation=0.75,
    width=1,
    whis=0,
    showfliers=False
)
axes[1].axvline(x=9, color='red', linestyle='--', linewidth=2, alpha=0.75)
axes[1].set_title('EU15 Countries', fontsize=14)
axes[1].set_xlabel('', fontsize=12)
axes[1].set_ylabel('Cumulative percentage change', fontsize=14)

# Shared settings for x-axis across both plots
for ax in axes:
    ax.axhline(y=0, color='black', linewidth=1)
    ax.set_xticks(range(maxh))
    ax.set_xticklabels(range(1995, 1995 + maxh), rotation=45, fontsize=12)
    ax.grid(visible=True, linestyle='--', alpha=0.6)

# Tight layout for better spacing
plt.tight_layout()

# Save or show the plot
plt.savefig(os.path.join(outpath,'lambdaupsilon.pdf'))
plt.show()