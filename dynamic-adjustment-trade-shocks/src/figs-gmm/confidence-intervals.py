# -*- coding: utf-8 -*-
"""
Created on Thu Feb  6 19:46:59 2025

@author: andre
"""

path = r'C:\Users\andre\OneDrive\research\cgoes\dynamic-adjustment-trade-shocks\data\work\gmm'
file = r'panelests3_10.dta'

import os
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

frame = pd.read_stata(os.path.join(path, file))

sample = [ '1, 2, 3, 6, 7, 8, 9, 10',
          '1, 4, 5, 10']

frame = frame[(frame.ivthres == 0)]

frame = frame[frame.horzs.isin(sample) & (frame.nstep == 1) & (frame.ivthres == 0)]
frame.horzs = frame.horzs.astype("category")
frame.horzs = frame.horzs.cat.set_categories(sample)
frame = frame.sort_values(["horzs"])

frame["1-zeta"] = 1 - frame["zeta"]
frame["se1-zeta"] = frame["sezeta"]

# Define x positions for each variable
variables = ["theta", "sigma", "1-zeta"]
x_positions = {var: i for i, var in enumerate(variables)}

# Define colors for specifications
specifications = frame["horzs"].unique()
colors = {specifications[0]: "blue",
          specifications[1]: "red"}

# Adjust x positions to avoid overlap
offset = 0.15  # Controls spacing between specifications

fig, axes = plt.subplots(1, 3, figsize=(12, 5), sharey=False)  # 3 subplots side-by-side

x_pos = list(np.linspace(1,len(specifications),len(specifications)))

for i, var in enumerate(variables):
    ax = axes[i]
    
    for j, spec in enumerate(specifications):
        sub_frame = frame[frame["horzs"] == spec]
        y = float(sub_frame[var])
        y_se = float(sub_frame['se' + var]) * 1.96
        x = x_pos[j]  # Positioning each spec separately within the subplot
        ax.errorbar(
            x, y, y_se, fmt='o', color=colors[spec], capsize=5
        )

    ax.set_xticks(x_pos)
    ax.set_xticklabels(["All but 4,5", "h=1,4,5,10"], rotation=45)
    ax.set_title(var.capitalize())
    ax.axhline(0, color='black')
    ax.set_xlim(0, 3)

axes[0].set_ylabel("Point estimate w/ 95% Confidence Interval")
plt.tight_layout()
plt.show()
