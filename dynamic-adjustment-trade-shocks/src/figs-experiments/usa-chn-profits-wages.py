# -*- coding: utf-8 -*-
"""
Created on Sat Dec 28 09:38:34 2024

@author: andre
"""


path = r'C:\Users\andre\OneDrive\research\cgoes\dynamic-adjustment-trade-shocks'

data = r'data\work\model\tradewar'
infile = 'd_nhorz5.dta'
infile_w = 'welfare_nhorz5.dta'

out = r'figs'


import pandas as pd
import os
import seaborn as sns
import matplotlib.pyplot as plt
import numpy as np

maxh = 21

df = pd.read_stata(os.path.join(path,data + '/' + infile))
df = df[ df.horz < maxh ]
df.horz = df.horz - 1
df = df[ (df.dest_iso3.isin(['USA','CN1'])) ]

dfw = pd.read_stata(os.path.join(path,data + '/' + infile_w)).rename(
    columns={'h': 'horz', 'iso3': 'dest_iso3', 'wp': 'dwp'})
df = df.merge( dfw, how='left', on=['dest_iso3', 'horz'])


cols = {
    'dwp': r'Real Wages $\frac{w_{d,t}}{P_{d,t}}$',
    'dprofit': r'Real Profits $\frac{\Pi_{d,t}}{P_{d,t}}$',
    'drealincome': r'Real Income',
    }


for col in cols:
    df[col] *= 100 


df_usa = df[df.dest_iso3 == 'USA']
df_usa = pd.melt(df_usa[['dwp','dprofit','horz']].rename(columns=cols), id_vars=['horz'])
#df_usa = pd.melt(df_usa[['drealincome','dprofit','horz']].rename(columns=cols), id_vars=['horz'])

df_chn = df[df.dest_iso3 == 'CN1']
df_chn = pd.melt(df_chn[['dwp','dprofit','horz']].rename(columns=cols), id_vars=['horz'])
#df_chn = pd.melt(df_chn[['drealincome','dprofit','horz']].rename(columns=cols), id_vars=['horz'])



###################


# Create a figure with two subplots side by side
fig, axes = plt.subplots(1, 2, figsize=(16, 6), sharey=False)

for variable in df_usa['variable'].unique():
    mini_frame = df_usa[ df_usa['variable'] == variable ]
    axes[0].plot(mini_frame['horz'],mini_frame['value'],label=variable, linewidth=3)
axes[0].axvline(x=0, color='red', linestyle='--', linewidth=2, alpha=0.75)
axes[0].set_title('United States', fontsize=18, fontweight='bold')
axes[0].set_ylabel('Cumulative Percentage Change', fontsize=14)
axes[0].set_xlabel('', fontsize=12)
axes[0].tick_params(axis='both', which='major', labelsize=14)
axes[0].legend().set_visible(False)


# Plot for 'eu15' countries
for variable in df_chn['variable'].unique():
    mini_frame = df_chn[ df_usa['variable'] == variable ]
    axes[1].plot(mini_frame['horz'],mini_frame['value'],label=variable, linewidth=3)
axes[1].axvline(x=0, color='red', linestyle='--', linewidth=2, alpha=0.75)
axes[1].set_title('China', fontsize=18, fontweight='bold')
axes[1].set_xlabel('', fontsize=12)
axes[1].set_ylabel('Cumulative Percentage Change', fontsize=14)
axes[1].tick_params(axis='both', which='major', labelsize=14)

# Shared settings for x-axis across both plots
for ax in axes:
    ax.axhline(y=0, color='black', linewidth=1)
    ax.set_xticks(range(maxh))
    ax.set_xticklabels(range(2018, 2018 + maxh), rotation=45, fontsize=12)
    ax.grid(visible=True, linestyle='--', alpha=0.6)

# Extract legend handles and labels from the second plot
handles, labels = axes[1].get_legend_handles_labels()

# Adjust subplot layout
fig.subplots_adjust(bottom=0.85)

# Place legend **above the two subplots, centered**
fig.legend(
    handles, labels,
    loc='lower center', bbox_to_anchor=(0.43, 1),
    fontsize=14,
    frameon=False, ncol=3  # Legend in one row for compactness
)

# Tight layout for better spacing
plt.tight_layout(rect=[0, 0, 0.85, 1])  # Adjust rect to leave space for the legend

# Save or show the plot
plt.savefig(os.path.join(path, out +'/' + 'usa-chn-profits-wages.pdf'), bbox_inches='tight')
plt.show()