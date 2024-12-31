# -*- coding: utf-8 -*-
"""
Created on Sun Dec  8 23:44:41 2024

@author: andre
"""

import pandas as pd
import os
import seaborn as sns
import matplotlib.pyplot as plt

# Example function to plot histogram and density plot
def plotHistDensity(df, column_name, save_path, bins=30, kde=True):
    """
    Plots a histogram and density plot for a given column in a pandas DataFrame.
    
    Parameters:
        df (pd.DataFrame): The pandas DataFrame containing the data.
        column_name (str): The column to be plotted.
        bins (int): Number of bins for the histogram.
        kde (bool): Whether to include the density plot (kernel density estimation).
    """
    plt.figure(figsize=(10, 6))
    
    # Plot histogram with seaborn
    sns.histplot(data=df, x=column_name, bins=bins, kde=kde, color='skyblue', alpha=0.7, edgecolor='black', stat='percent')
    
    # Add labels and title
    plt.xlabel('', fontsize=18)
    plt.ylabel('Percent', fontsize=18)
#    plt.title(f'Histogram and Density Plot of {column_name}', fontsize=14)
    
    # Show the plot
    plt.grid(axis='y', linestyle='--', alpha=0.7)
    plt.tight_layout()
    plt.show()
    plt.savefig(save_path)

def filterFrame(df, tariff):
#    df = df.groupby(['exporter','importer','year']).agg( { tariff + '_st': 'mean',  tariff + '_pre': 'mean'} )
    df['diff'] = df[tariff + '_pre'] - df[tariff + '_st'] 
    df = df[(~df['diff'].isna())]
    minidf = df[(df['diff'] != 0)]
    return df, minidf

    
path = r'/u/main/tradeadj/lev'
temppath = path + '/temp_files/out'
frame = pd.read_csv(os.path.join(temppath, 'full_panel.csv'), low_memory=False)

print(frame.describe())

tariffs = ['mfn', 'prf', 'ahs']

for tariff in tariffs:
    print(f'Processing {tariff}...')
    df, minidf = filterFrame(frame, tariff)
    savepath = path + '/teti_code/figs'
    plotHistDensity(minidf, 'diff', os.path.join(savepath, tariff + '.pdf'), kde=False, bins=100)
    print(minidf['diff'].describe())
    plotHistDensity(df, 'diff', os.path.join(savepath, tariff + 'z.pdf'), kde=False, bins=100)
    print(df['diff'].describe())
    
print(frame.describe())