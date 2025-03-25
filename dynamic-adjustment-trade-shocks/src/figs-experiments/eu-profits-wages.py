# -*- coding: utf-8 -*-
"""
Created on Sat Dec 28 09:38:34 2024

@author: andre
"""

path = r'C:\Users\andre\OneDrive\research\cgoes\dynamic-adjustment-trade-shocks'

data = r'data\work\model\euenlarge'
infile = 'd_nhorz5.dta'
infile_w = 'welfare_nhorz5.dta'


import pandas as pd
import os
import seaborn as sns
import matplotlib.pyplot as plt
import numpy as np

maxh = 21

nms = ['CYP', 'CZE', 'EST', 
            'HUN', 'LVA', 'LTU', 'MLT', 'POL', 'SVK', 'SVN']


df = pd.read_stata(os.path.join(path,data + '/' + infile))
df = df[ df.horz <= maxh ]
df.horz = df.horz - 1
df = df[ (df.dest_iso3.isin(nms)) ]

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


mdf = pd.melt(df[['dwp','dprofit', 'horz']].rename(columns=cols), id_vars=['horz'])

#######################3


eu_codes = ['AUT', 'BEL', 'CYP', 'CZE', 'DNK', 'EST', 'FIN', 'FRA', 'DEU', 'GRC', 'HUN', 'IRL', 'ITA', 'LVA', 'LTU', 'LUX', 'MLT', 'NLD', 'POL', 'PRT', 'SVK', 'SVN', 'ESP', 'SWE']
eu15 = list( set(eu_codes).difference(set(nms)) )

df = pd.read_stata(os.path.join(path,data + '/' + infile))
df = df[ df.horz <= maxh ]
df.horz = df.horz - 1
df = df[ (df.dest_iso3.isin(eu15)) ]

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


mdf2 = pd.melt(df[['dwp','dprofit', 'horz']].rename(columns=cols), id_vars=['horz'])


###################3

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
plt.savefig(os.path.join(path, 'figs/eu-profits-wages.pdf'), bbox_inches='tight')
plt.show()
