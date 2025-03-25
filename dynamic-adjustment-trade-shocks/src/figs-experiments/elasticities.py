# -*- coding: utf-8 -*-
"""
Created on Fri Mar 14 10:43:51 2025

@author: andre
"""

path = r'C:\Users\andre\OneDrive\research\cgoes\dynamic-adjustment-trade-shocks'

data = r'figdata'
infile = 'gmmelasbase.dta'

out = r'figs'


import pandas as pd
import os
import seaborn as sns
import matplotlib.pyplot as plt
import numpy as np

df = pd.read_stata(os.path.join(path,data + '/' + infile))
idx = [x+1 for x in df.index]

# Create a figure with two subplots side by side
fig, axes = plt.subplots(1, 1, figsize=(8, 6), sharey=False)

axes.fill_between(df.index, df.lbnhorz5,df.ubnhorz5, color='#E3822C', alpha=0.2)
axes.plot(df.index, df.bnhorz5, label='Baseline structural (nonlinear, CUGMM with 5 horizons)', color='#E3822C', linewidth=3)

axes.plot(df.index, df.bnhorz10, label='Alternative structural (nonlinear, CUGMM with 10 horizons)', color='green', linewidth=3, linestyle='-.')

axes.scatter(df.index, df.blinear, label='Reduced form (linear, local projections by horizon)', color='#3274A1')
axes.errorbar(df.index, df.blinear, yerr=np.abs(df.blinear - df.lblinear), color='#3274A1', elinewidth=3, linewidth=0)

#axes.set_title('Mexico', fontsize=18, fontweight='bold')
axes.set_ylabel('Tariff inclusive trade elasticity $\epsilon^h$', fontsize=14)
axes.set_xlabel('Years after the shock', fontsize=14)
axes.tick_params(axis='both', which='major', labelsize=14)
axes.legend().set_visible(False)

# Shared settings for x-axis across both plots
axes.axhline(y=0, color='black', linewidth=1)
axes.set_xticks(range(len(idx)))
axes.set_xticklabels(idx, fontsize=12)
axes.grid(visible=True, linestyle='--', alpha=0.6)

# Extract legend handles and labels from the second plot
handles, labels = axes.get_legend_handles_labels()

# Adjust subplot layout
fig.subplots_adjust(bottom=0.85)

# Place legend **above the two subplots, centered**
fig.legend(
    handles, labels,
    loc='lower center', bbox_to_anchor=(0.43, 1),
    fontsize=14,
    frameon=False, ncol=1  # Legend in one row for compactness
)

# Tight layout for better spacing
plt.tight_layout(rect=[0, 0, 0.85, 1])  # Adjust rect to leave space for the legend

#Save or show the plot
plt.savefig(os.path.join(path, out +'/' + 'gmmelasbase_new.pdf'), bbox_inches='tight')
plt.show()
