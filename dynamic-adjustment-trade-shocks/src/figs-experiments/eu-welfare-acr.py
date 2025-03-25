# -*- coding: utf-8 -*-
"""
Created on Sat Dec 28 09:38:34 2024

@author: andre
"""

Path = r'C:\Users\andre\OneDrive\UCSD\Research\cgoes\dynamic-adjustment-trade-shocks\eu-tariffs\trottner\temp_files'
File = 'euenlarge_welfarei_base.dta'

import pandas as pd
import os
import seaborn as sns
import matplotlib.pyplot as plt
import numpy as np

nms = ['CYP', 'CZE', 'EST', 
            'HUN', 'LVA', 'LTU', 'MLT', 'POL', 'SVK', 'SVN']

maxh = 25

df = pd.read_stata(os.path.join(Path,File))
df = df[ df.h < maxh ]
df = df[ (df.iso3.isin(nms)) ]
df.flexi = df.flexi*100
df.disti = df.disti*100



dfm = df.groupby('h').agg( {
    'flexi': 'mean',
    'disti': 'mean'
    } ).reset_index(drop=False)

dfm['wp'] = dfm.flexi + dfm.disti 
dfm["flexib"] = 0
dfm.loc[dfm["disti"] > 0, "flexib"] = dfm.loc[dfm["disti"] > 0, "flexi"]

# Plot a stacked bar chart
plt.figure(figsize=(8, 6))  # Set figure size
plt.bar(dfm["h"], dfm["flexi"], label="Observed expenditure shares contributions")
plt.bar(dfm["h"], dfm["disti"], bottom=dfm["flexib"],label="Adjustment factor contribution")
plt.plot(dfm["h"], dfm["wp"], label="Welfare", color='black', linewidth=3)

# Add labels and title
plt.axvline(x=9, color='red', linestyle='--', linewidth=2, alpha=0.75)  # Add red vertical line
    # Add titles and labels
plt.ylabel('Cumulative Percentage Points Change', fontsize=14)
    
    # Format x-axis with custom tick labels
plt.xlabel('')
plt.xticks(ticks=range(maxh), labels=range(1995,1995+maxh), fontsize=12, rotation=45)
plt.yticks(fontsize=12)
plt.grid(visible=True, linestyle='--', alpha=0.6)
plt.legend()

    # Tight layout for better spacing
plt.tight_layout()

outpath = r'C:\Users\andre\OneDrive\UCSD\Research\cgoes\dynamic-adjustment-trade-shocks\eu-tariffs\trottner\figs'
plt.savefig(os.path.join(outpath,'welfaredecomp.pdf'))
plt.show()






###############################3


Path = r'C:\Users\andre\OneDrive\UCSD\Research\cgoes\dynamic-adjustment-trade-shocks\eu-tariffs\trottner\temp_files'
File = 'euenlarge_welfarei_base.dta'

import pandas as pd
import os
import seaborn as sns
import matplotlib.pyplot as plt
import numpy as np

nms = ['CYP', 'CZE', 'EST', 
            'HUN', 'LVA', 'LTU', 'MLT', 'POL', 'SVK', 'SVN']

maxh = 25

df = pd.read_stata(os.path.join(Path,File))
df = df[ df.h < maxh ]
df = df[ (df.iso3.isin(nms)) ]
df.flexi = df.flexi*100
df.disti = df.disti*100
df['wp'] = df.flexi + df.disti 

    
fig, axes = plt.subplots(1, 1, figsize=(8, 6))  # Share y-axis for consistency
    
boxplot_colors = ["#1f77b4", "#ff7f0e"]
    
    # First boxplot
sns.boxplot(
        data=df,
        y='wp',
        x='h',
        width=0.8,  # Adjust box width
        whis=0,
        showfliers=False
    )
plt.axhline(y=0, color='black', linewidth=1)  # Add red vertical line
plt.axvline(x=9, color='red', linestyle='--', linewidth=2, alpha=0.75)  # Add red vertical line
        # Add titles and labels
plt.ylabel('Cumulative Percentage Points', fontsize=14)
        
        # Format x-axis with custom tick labels
plt.xlabel('')
plt.xticks(ticks=range(maxh), labels=range(1995,1995+maxh), fontsize=12, rotation=45)
plt.yticks(fontsize=12)
plt.grid(visible=True, linestyle='--', alpha=0.6)
            
        # Tight layout for better spacing
plt.tight_layout()
    
plt.savefig(os.path.join(outpath,'eu-welfare-dist.pdf'))
plt.show()

