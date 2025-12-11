# -*- coding: utf-8 -*-
"""
Created on Sat Dec  6 13:51:48 2025

@author: andre
"""

file = r'C:\Users\andre\OneDrive\research\cgoes\dynamic-adjustment-trade-shocks\eu-tariffs\trottner\temp_files\out\icio_wits_bilateral_eu.dta'

import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np

df = pd.read_stata(file)
df = df.drop(columns='index')

nms = ['CYP', 'CZE', 'EST', 'HUN', 'LVA', 'LTU', 'MLT', 'POL', 'SVK', 'SVN']
eu_codes = ['AUT', 'BEL', 'CYP', 'CZE', 'DNK', 'EST', 'FIN', 'FRA', 'DEU', 'GRC', 'HUN', 'IRL', 'ITA', 'LVA', 'LTU', 'LUX', 'MLT', 'NLD', 'POL', 'PRT', 'SVK', 'SVN', 'ESP', 'SWE','GBR' ]
eu15 = list( set(eu_codes).difference(set(nms)) )


# -----------------------------
# Load + clean
# -----------------------------
df = pd.read_stata(file)
df = df.drop(columns='index')

# Ensure exporter/importer columns are named consistently
# Replace these names if your dataset uses different ones:
exp_col = 'exporter'      # exporter
imp_col = 'importer'      # importer
tar_col = 'ahs_st'     # tariff variable
year_col = 'year'      # year variable

# -----------------------------
# Assign partner group: NMS vs EU-15
# -----------------------------
def classify_group(code):
    if code in nms:
        return 'nms'
    elif code in eu15:
        return 'eu15'
    else:
        return 'other_eu'  # e.g., newer EU members not in NMS or EU15

df['exp_group'] = df[exp_col].apply(classify_group)
df['imp_group'] = df[imp_col].apply(classify_group)

# -----------------------------
# Optionally: construct mean tariff time series per NMS × group
# -----------------------------
tariff_ts = (
    df.groupby([imp_col, 'exp_group', year_col]).agg({
        tar_col: 'mean',
        'imp_group': 'first'
         }).reset_index()
           .sort_values([imp_col, 'exp_group', year_col])
)

print(tariff_ts.head())

# convenience alias
ts = tariff_ts.copy()

# ---- 2x2 subplots ----
fig, axes = plt.subplots(2, 2, figsize=(14, 10), sharey=True)

pairs = [
    ('nms',  'nms'),
    ('nms',  'eu15'),
    ('eu15', 'nms'),
    ('eu15', 'eu15'),
]

for ax, (exp, imp) in zip(axes.flat, pairs):

    table = ts[(ts['exp_group'] == exp) & (ts['imp_group'] == imp)]

    if table.empty:
        ax.set_title(f'{exp} → {imp} (no data)')
        ax.grid(True, alpha=0.3)
        continue

    stats = (
        table.groupby('year')['ahs_st']
             .agg(
                 q25=lambda x: x.quantile(0.25),
                 median='median',
                 q75=lambda x: x.quantile(0.75)
             )
             .reset_index()
             .sort_values('year')
    )

    # median line
    ax.plot(stats['year'], stats['median'], marker='o', label='Median')

    # IQR band
    ax.fill_between(
        stats['year'],
        stats['q25'],
        stats['q75'],
        alpha=0.3,
        label='IQR (25–75%)'
    )

    ax.set_title(f'{exp} exporter → {imp} importer')
    ax.set_xlabel('Year')
    ax.grid(True, alpha=0.3)

# Left column gets y-label
axes[0,0].set_ylabel("Tariff (ahs_st)")
axes[1,0].set_ylabel("Tariff (ahs_st)")

# Show legend only once
axes[0,0].legend(loc='best')

plt.tight_layout()
plt.show()
