# -*- coding: utf-8 -*-
"""
Created on Sat Dec 28 09:38:34 2024

@author: andre
"""

Path = r'C:\Users\andre\OneDrive\research\cgoes\dynamic-adjustment-trade-shocks\eu-tariffs\trottner\temp_files'
File = 'euenlarge_d_base.dta'

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
df = df[ (df.dest_iso3.isin(nms)) ]
df['wLp'] = df['wL'] / df['Pf']
df['profitp'] = df['profit'] / df['Pf']
df['welfare'] = df['wLp'] + df['profitp']
initial = df.loc[df['horz'] == 1,['dest_iso3', 'wLp','profitp','welfare']]
df = df.merge( initial, how='left', on=['dest_iso3'], suffixes=['','0'])
df['dwLp'] = [(np.log(x) - np.log(y))*100 for x,y in zip(df['wLp'],df['wLp0'])]
df['dprofitp'] = [(np.log(x) - np.log(y))*100 for x,y in zip(df['profitp'],df['profitp0'])]

# Create a figure with two subplots side by side

cols = {
    'dwLp': r'Real Wages $\frac{w_{d,t}}{P_{d,t}}$',
    'dprofitp': r'Real Profits $\frac{\Pi_{d,t}}{P_{d,t}}$'
    }

mdf = pd.melt(df[['dwLp','dprofitp','horz']].rename(columns=cols), id_vars=['horz'])


###################3

# -*- coding: utf-8 -*-
"""
Created on Sat Dec 28 09:38:34 2024

@author: andre
"""

File = 'euenlarge_isd_base.dta'

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

mdf2 = pd.melt(df[['dlambda','horz']].rename(columns=cols), id_vars=['horz'])

#######################3


#######################3


outpath = r'C:\Users\andre\OneDrive\research\cgoes\dynamic-adjustment-trade-shocks\eu-tariffs\trottner\figs'

plt.figure(figsize=(8, 6))
sns.boxplot(
    data=mdf,
    y='value',
    x='horz',
    hue='variable',
    saturation=0.75,
    width=1,
    whis=0,
    showfliers=False
)
plt.axvline(x=9, color='red', linestyle='--', linewidth=2, alpha=0.75)
plt.title('Welfare', fontsize=14)
plt.ylabel('Cumulative percentage change', fontsize=14)
plt.xlabel('', fontsize=12)
plt.ylim([0, 2])  # Set y-axis range
plt.axhline(y=0, color='black', linewidth=1)
plt.xticks(range(maxh), range(1995, 1995 + maxh), rotation=45, fontsize=12)
plt.grid(visible=True, linestyle='--', alpha=0.6)
plt.tight_layout()
plt.savefig(os.path.join(outpath, 'nms_welfare_plot.pdf'))
plt.show()

plt.figure(figsize=(8, 6))
sns.boxplot(
    data=mdf2,
    y='value',
    x='horz',
    hue='variable',
    saturation=0.75,
    width=1,
    whis=0,
    showfliers=False
)
plt.axvline(x=9, color='red', linestyle='--', linewidth=2, alpha=0.75)
plt.title('Domestic Trade Shares', fontsize=14)
plt.ylabel('Cumulative percentage change', fontsize=14)
plt.xlabel('', fontsize=12)
plt.ylim([-2, 0])  # Set y-axis range
plt.axhline(y=0, color='black', linewidth=1)
plt.xticks(range(maxh), range(1995, 1995 + maxh), rotation=45, fontsize=12)
plt.grid(visible=True, linestyle='--', alpha=0.6)
plt.tight_layout()
plt.savefig(os.path.join(outpath, 'nms_trade_shares_plot.pdf'))
plt.show()
