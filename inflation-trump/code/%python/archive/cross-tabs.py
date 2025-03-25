# -*- coding: utf-8 -*-
"""
Created on Sat Dec 14 23:47:27 2024

@author: andre
"""

import os
import pandas as pd
import time
import matplotlib.pyplot as plt

path = r'C:\Users\andre\OneDrive\UCSD\Research\cgoes\inflation-trump\data\yougov'
file = 'download.xlsx'

groups = ['HS or less', 'Some college', 'College grad', 'Postgrad']

dictfill = {
    'HS or less': '1 HS or less',
    'Some college': '2 Some college',
    'College grad': '3 College grad',
    'Postgrad': '4 Postgrad'
    }

frames = []
for group in groups:
    df = pd.read_excel(os.path.join(path,file), sheet_name=group)
    df.columns = ['Issue'] + list(df.columns[1:])
    cols = df['Issue']
    df = df.T.drop('Issue')
    df.columns = cols
    df['group'] = dictfill[group]
    df['year'] = [int(x[:4]) for x in df.index]
    frames.append(df)
    
frame = pd.concat(frames)
frame = frame[ frame['year'] >= 2022 ]

frame = frame.groupby(['group','year']).mean().reset_index()

# Plot the time series
plt.figure(figsize=(10, 6))
for group in frame.group.unique():
    miniframe = frame[frame['group'] == group]
    plt.plot(miniframe.year, miniframe['Inflation/prices'], label=f'{group}')

# Customize the plot
plt.title('Share of group stating inflation is most important issue (yougov)')
plt.xlabel('Date')
plt.ylabel('Value')
plt.legend(title='Group')
plt.grid(True)
plt.tight_layout()
