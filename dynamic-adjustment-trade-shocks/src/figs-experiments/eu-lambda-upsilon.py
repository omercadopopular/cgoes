# -*- coding: utf-8 -*-
"""
Created on Sat Dec 28 09:38:34 2024

@author: andre
"""

path = r'C:\Users\andre\OneDrive\research\cgoes\dynamic-adjustment-trade-shocks'

data = r'data\work\model\euenlarge'
infile = 'isd_nhorz5.dta'

data_0 = r'data\work\ICIO'
infile_0 = 'paraisd_i32_1995.dta'

import pandas as pd
import os
import seaborn as sns
import matplotlib.pyplot as plt
import numpy as np

nms = ['CYP', 'CZE', 'EST', 
            'HUN', 'LVA', 'LTU', 'MLT', 'POL', 'SVK', 'SVN']

maxh = 20
zeta = .12

df = pd.read_stata(os.path.join(path,data + '/' + infile), convert_categoricals=False).rename(columns={'upsilon': 'upsilon0'})
df = df[ df.horz < maxh ]
df = df[ (df.sorc_iso3 == df.dest_iso3) & (df.sorc_iso3.isin(nms)) ]

initial = pd.read_stata(os.path.join(path,data_0 + '/' + infile_0), convert_categoricals=False)
initial['lambda'] = initial['inshare']
initial = initial[ (initial.sorc_iso3 == initial.dest_iso3) & (initial.sorc_iso3.isin(nms)) ]
initial = initial[['sorc_i32', 'dest_iso3', 'lambda']]

df = df.merge(initial, how='left', on=['sorc_i32', 'dest_iso3'], suffixes=['','_ss'])
df['upsilon'] = df['lambda_ss']
df['upsilon_ss'] = df['lambda_ss']

for group, frame in df.groupby(['sorc_i32', 'sorc_iso3', 'dest_iso3']):
    for i in range(len(frame.index)):
        if i == 0:
            df.loc[frame.index[i],'upsilon'] = zeta*df.loc[frame.index[i],'upsilon0'] + (1-zeta)*df.loc[frame.index[i],'upsilon_ss']
        else:
            df.loc[frame.index[i],'upsilon'] = zeta*df.loc[frame.index[i],'upsilon0'] + (1-zeta)*df.loc[frame.index[i-1],'upsilon']


df['dlambda'] = [(x - y)*100 for x,y in zip(df['lambda'],df['lambda_ss'])]
df['dupsilon'] = [(x - y)*100 for x,y in zip(df['upsilon'],df['upsilon_ss'])]
# Create a figure with two subplots side by side


cols = {
    'dlambda': r'Domestic Expenditure Share $\lambda_{ddi}$',
    'dupsilon': r'Domestic Procurement Share $\upsilon_{ddi}$'
    }

mdf = pd.melt(df[['dlambda','dupsilon','horz']].rename(columns=cols), id_vars=['horz'])

#######################3


eu_codes = ['AUT', 'BEL', 'CYP', 'CZE', 'DNK', 'EST', 'FIN', 'FRA', 'DEU', 'GRC', 'HUN', 'IRL', 'ITA', 'LVA', 'LTU', 'LUX', 'MLT', 'NLD', 'POL', 'PRT', 'SVK', 'SVN', 'ESP', 'SWE']
eu15 = list( set(eu_codes).difference(set(nms)) )

df = pd.read_stata(os.path.join(path,data + '/' + infile), convert_categoricals=False).rename(columns={'upsilon': 'upsilon0'})
df = df[ df.horz < maxh ]
df = df[ (df.sorc_iso3 == df.dest_iso3) & (df.sorc_iso3.isin(eu15)) ]

initial = pd.read_stata(os.path.join(path,data_0 + '/' + infile_0), convert_categoricals=False)
initial['lambda'] = initial['inshare']
initial = initial[ (initial.sorc_iso3 == initial.dest_iso3) & (initial.sorc_iso3.isin(eu15)) ]
initial['i32'] = initial.groupby(['sorc_i32']).ngroup()
initial = initial[['sorc_i32', 'dest_iso3', 'lambda']]

df = df.merge(initial, how='left', on=['sorc_i32', 'dest_iso3'], suffixes=['','_ss'])
df['upsilon'] = df['lambda_ss']
df['upsilon_ss'] = df['lambda_ss']

for group, frame in df.groupby(['sorc_i32', 'sorc_iso3', 'dest_iso3']):
    for i in range(len(frame.index)):
        if i == 0:
            df.loc[frame.index[i],'upsilon'] = zeta*df.loc[frame.index[i],'upsilon0'] + (1-zeta)*df.loc[frame.index[i-1],'upsilon_ss']
        else:
            df.loc[frame.index[i],'upsilon'] = zeta*df.loc[frame.index[i],'upsilon0'] + (1-zeta)*df.loc[frame.index[i-1],'upsilon']


df['dlambda'] = [(x - y)*100 for x,y in zip(df['lambda'],df['lambda_ss'])]
df['dupsilon'] = [(x - y)*100 for x,y in zip(df['upsilon'],df['upsilon_ss'])]
# Create a figure with two subplots side by side


mdf2 = pd.melt(df[['dlambda','dupsilon','horz']].rename(columns=cols), id_vars=['horz'])


#######################3


# Create a figure with two subplots side by side
fig, axes = plt.subplots(1, 2, figsize=(16, 6), sharey=False)

# Define common boxplot styling parameters
boxplot_kwargs = {
    'saturation': 0.75,
    'width': 0.8,
    'whis': 0,
    'showfliers': False
}

# Plot for 'nms' countries
sns.boxplot(ax=axes[0], data=mdf, y='value', x='horz', hue='variable', **boxplot_kwargs)
axes[0].axvline(x=9, color='red', linestyle='--', linewidth=2, alpha=0.75)
axes[0].set_title('NMS Countries', fontsize=18, fontweight='bold')
axes[0].set_ylabel('Cumulative Percentage Change', fontsize=14)
axes[0].set_xlabel('', fontsize=12)
axes[0].tick_params(axis='both', which='major', labelsize=14)
axes[0].get_legend().remove()

# Plot for 'eu15' countries
sns.boxplot(ax=axes[1], data=mdf2, y='value', x='horz', hue='variable', **boxplot_kwargs)
axes[1].axvline(x=9, color='red', linestyle='--', linewidth=2, alpha=0.75)
axes[1].set_title('EU15 Countries', fontsize=18, fontweight='bold')
axes[1].set_xlabel('', fontsize=12)
axes[1].set_ylabel('Cumulative Percentage Change', fontsize=14)
axes[1].tick_params(axis='both', which='major', labelsize=14)
axes[1].get_legend().remove()

# Shared settings for x-axis across both plots
for ax in axes:
    ax.axhline(y=0, color='black', linewidth=1)
    ax.set_xticks(range(maxh))
    ax.set_xticklabels(range(1995, 1995 + maxh), rotation=45, fontsize=14)
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
plt.savefig(os.path.join(path,'figs/eu-lambdaupsilon.pdf'), bbox_inches='tight')
plt.show()