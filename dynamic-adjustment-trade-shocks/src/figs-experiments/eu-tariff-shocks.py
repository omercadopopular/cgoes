# -*- coding: utf-8 -*-
"""
Created on Fri Dec 27 16:05:33 2024

@author: cbezerradegoes
"""

path = r'C:\Users\andre\OneDrive\research\cgoes\dynamic-adjustment-trade-shocks'
file = path + r'\eu-tariffs\trottner\temp_files\out\icio_wits_bilateral_eu.dta'

import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np
import os

df = pd.read_stata(file)
df = df.drop(columns='index')

nms = ['CYP', 'CZE', 'EST', 'HUN', 'LVA', 'LTU', 'MLT', 'POL', 'SVK', 'SVN']
eu_codes = ['AUT', 'BEL', 'CYP', 'CZE', 'DNK', 'EST', 'FIN', 'FRA', 'DEU', 'GRC', 'HUN', 'IRL', 'ITA', 'LVA', 'LTU', 'LUX', 'MLT', 'NLD', 'POL', 'PRT', 'SVK', 'SVN', 'ESP', 'SWE']
eu15 = list( set(eu_codes).difference(set(nms)) )

# Create the figure and axis
plt.figure(figsize=(8, 6))
palette = sns.color_palette("tab10", n_colors=4)

counter = 0
frames = []
for exp in (nms, eu15):
    for imp in (nms, eu15):
        frame = df[ df.exporter.isin(exp) & df.importer.isin(imp) & (df.importer != df.exporter) ]
        frame = frame.merge( frame.groupby(['importer','exporter','icio']).min()['year'].reset_index() , how='left', on=['importer','exporter','icio'], suffixes=['', '_min'])
        frame['group'] = counter
        frame_min = frame[ frame.year == frame.year_min ]
        frames.append(frame_min)


        sns.boxplot(
            data=frame_min,
            x=np.ones(len(frame_min['ahs_st']))*counter,
            y=frame_min['ahs_st']*(-1),
            palette=palette,
            whis=0,
            width=0.6,  # Adjust box width
            showfliers=False  # Optional: Hide outliers for cleaner visuals
        )

        counter += 1

"""
        plt.scatter(
            np.ones(len(frame_min['ahs_st']))*counter,
            frame_min['ahs_st'],
            alpha=0.25,
            edgecolor='k',  # Add edge color for better distinction
            s=50  # Marker size
        )
"""

        
#create tables
table = path + r'\eu-tariffs\trottner\temp_files\out\data_min.dta'
frame = pd.concat(frames)
frame.to_stata( table, write_index=False )
frame.groupby('group')['ahs_st'].describe().to_latex()


secDict = {
    1: 'Agriculture, forestry and fishing',
    2: 'Mining and quarrying',
    3: 'Food products, beverages and tobacco',
    4: 'Textiles, textile products, leather and footwear',
    5: 'Wood and products of wood and cork',
    6: 'Paper products and printing',
    7: 'Coke and refined petroleum products',
    8: 'Chemical and chemical products',
    9: 'Pharmaceuticals, medicinal and botanical products',
    10: 'Rubber and plastics products',
    11: 'Other non-metallic mineral products',
    12: 'Basic metals',
    13: 'Fabricated metal products',
    14: 'Computer, electronic and optical equipment',
    15: 'Electrical equipment',
    16: 'Machinery and equipment, nec',
    17: 'Motor vehicles, trailers and semi-trailers',
    18: 'Other transport equipment',
    19: 'Furniture and other manufacturing'
    }

nmsdf = df[ df.exporter.isin(eu15) & df.importer.isin(nms) & (df.importer != df.exporter) ]
nmsdf = nmsdf.merge( frame.groupby(['importer','exporter','icio']).min()['year'].reset_index() , how='left', on=['importer','exporter','icio'], suffixes=['', '_min'])
nmsdfsector = nmsdf.groupby('icio')['ahs_st'].describe().to_latex()

eu15df = df[ df.exporter.isin(nms) & df.importer.isin(eu15) & (df.importer != df.exporter) ]

#plot charts

# Add titles and labels
#plt.title("Distribution of Tariff Rates across NMS and Trade Flows in 1995", fontsize=16, weight='bold')
plt.ylabel('Trade Weighted-Average Decrease in Tariff', fontsize=14)
    
# Format axes
custom_xticks = ['NMS to NMS', 'NMS to EU15', 'EU15 to NMS', 'EU15 to EU15']
plt.xticks(ticks=range(4), labels=custom_xticks, fontsize=16, rotation=45)
plt.xticks(fontsize=16)
plt.yticks(fontsize=16)
plt.grid(visible=True, linestyle='--', alpha=0.6)
    
# Add legend
    
# Tight layout for better spacing
plt.tight_layout()
    
# Save as a high-resolution image for publications (optional)
# plt.savefig("scatterplot.png", dpi=300)
    
plt.savefig(os.path.join(path, 'figs\\eu-shocks.pdf'))
plt.show()
