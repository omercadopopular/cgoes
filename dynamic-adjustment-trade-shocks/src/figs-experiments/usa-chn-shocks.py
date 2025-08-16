# -*- coding: utf-8 -*-
"""
Created on Fri Dec 27 16:05:33 2024

@author: cbezerradegoes
"""

path = r'/u/main/tradeadj/'

data = r'data/work/ICIO'
infile_x = 'xtau.dta'
infile_m = 'mtau.dta'


import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np
import os

df_usa = pd.read_stata(os.path.join(path, data + '\\' + infile_x))
df_usa['dtau'] = (df_usa['taumax19'] - 1)*100
df_usa_chn = df_usa[df_usa['iso3'] == 'CHN']
df_usa_row = df_usa[df_usa['iso3'] != 'CHN']

df_r = pd.read_stata(os.path.join(path, data + '\\' + infile_m))
df_r['dtau'] = (df_r['taumax19'] - 1)*100
df_r_chn = df_r[df_r['iso3'] == 'CHN']
df_r_row = df_r[df_r['iso3'] != 'CHN']

# Create the figure and axis
plt.figure(figsize=(8, 6))
palette = sns.color_palette("tab10", n_colors=4)

counter = 0
frames = [df_usa_chn, df_usa_row, df_r_chn, df_r_row]
for frame in frames:
    sns.boxplot(
            x=counter,
            y=frame['dtau'],
            palette=palette,
            whis=0,
            width=0.6,  # Adjust box width
            showfliers=False  # Optional: Hide outliers for cleaner visuals
        )
    counter += 1
    frame['group'] = counter

plt.ylabel('Trade Weighted-Average Increase in Tariff', fontsize=14)
    
# Format axes
custom_xticks = ['CHN to USA', 'ROW to USA', 'USA to CHN', 'USA to ROW']
plt.xticks(ticks=range(4), labels=custom_xticks, fontsize=16, rotation=45)
plt.xticks(fontsize=16)
plt.yticks(fontsize=12)
plt.grid(visible=True, linestyle='--', alpha=0.6)
    
# Add legend
    
# Tight layout for better spacing
plt.tight_layout()
    
# Save as a high-resolution image for publications (optional)
# plt.savefig("scatterplot.png", dpi=300)
    
plt.savefig(r'C:\Users\andre\OneDrive\research\cgoes\dynamic-adjustment-trade-shocks\figs\usa-chn-shock.pdf')
plt.show()


frame_tex = pd.concat(frames)
frame_tex.groupby('group')['ahs_st'].describe().to_latex()

frame.to_stata( path, write_index=False )
