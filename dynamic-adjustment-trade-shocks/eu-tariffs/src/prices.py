# -*- coding: utf-8 -*-
"""
Created on Sat Dec 28 09:38:34 2024

@author: andre
"""

Path = r'C:\Users\andre\OneDrive\UCSD\Research\cgoes\dynamic-adjustment-trade-shocks\eu-tariffs\trottner\temp_files'
File = 'euenlarge_id_base.dta'

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
df = df[ df.dest_iso3.isin(nms) ]
initial = df.loc[df['horz'] == 1,['dest_iso3', 'dest_i32','lgP']]
df = df.merge( initial, how='left', on=['dest_iso3', 'dest_i32'], suffixes=['','0'])
df['dlgP'] = [(x - y)*100 for x,y in zip(df['lgP'],df['lgP0'])]


############33

eu_codes = ['AUT', 'BEL', 'CYP', 'CZE', 'DNK', 'EST', 'FIN', 'FRA', 'DEU', 'GRC', 'HUN', 'IRL', 'ITA', 'LVA', 'LTU', 'LUX', 'MLT', 'NLD', 'POL', 'PRT', 'SVK', 'SVN', 'ESP', 'SWE']
eu15 = list( set(eu_codes).difference(set(nms)) )

df2 = pd.read_stata(os.path.join(Path,File))
df2 = df2[ df2.horz < maxh ]
df2 = df2[ df2.dest_iso3.isin(eu15) ]
initial = df2.loc[df2['horz'] == 1,['dest_iso3', 'dest_i32','lgP']]
df2 = df2.merge( initial, how='left', on=['dest_iso3', 'dest_i32'], suffixes=['','0'])
df2['dlgP'] = [(x - y)*100 for x,y in zip(df2['lgP'],df2['lgP0'])]
# Create a figure with two subplots side by side

############33

# Create a figure with two subplots side by side
fig, axes = plt.subplots(1, 2, figsize=(16, 6), sharey=False)

# Plot for 'nms' countries
sns.boxplot(
    ax=axes[0],
    data=df,
    y='dlgP',
    x='horz',
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
    data=df2,
    y='dlgP',
    x='horz',
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
outpath = r'C:\Users\andre\OneDrive\UCSD\Research\cgoes\dynamic-adjustment-trade-shocks\eu-tariffs\trottner\figs'
plt.savefig(os.path.join(outpath,'eu-dlP.pdf'))
plt.show()
