# -*- coding: utf-8 -*-
"""
Created by Carlos Góes
cgoes@ucsd.edu
www.carlosgoes.com

Version 0.1
December 2022
"""

import os
# Base Paths
Folder = r'C:\Users\wb592068\OneDrive - UC San Diego\UCSD\Research\product-innovation-trade\data\wits'
os.chdir(Folder)


from src.wits import wits
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
        
### User inputs
FirstYear = 2003
LastYear = 2004


# Initiate Local Routine
Query = wits(Folder=Folder)

# Dictionary of Enlargement Waves
Enlargement = {
        2004: ['CYP', 'CZE', 'EST', 'HUN', 'LVA', 'LTU', 'MLT', 'SVK', 'SVN'],
}

# Country Codes
CountryCodes = r'https://wits.worldbank.org/wits/wits/witshelp/content/codes/country_codes.htm'
CountryCodesTable = pd.read_html(CountryCodes, header=1)[0]

# ISO Codes and WITS Codes of EU Countries
# I will use this to isolate the sets of non EU countries as our shocks
ISOPartners = ['CHE', 'ISL', 'NOR', 'TUR', 'TUN', 'ISR', 'MEX',
               'MAR', 'JOR', 'EGY', 'MKD', 'CHL', 'ZAF']
PartnersTable = CountryCodesTable[ CountryCodesTable.ISO3.isin(ISOPartners) ]
PartnersCodes = PartnersTable.Code.unique()

BigFrame = pd.DataFrame()
for Wave in Enlargement:
    for CountryIso in Enlargement[Wave]:
        Code = CountryCodesTable[ CountryCodesTable.ISO3 == CountryIso ].Code.iloc[0]
        Country = CountryCodesTable[ CountryCodesTable.Code == Code ]['Country Name'].iloc[0]
        print('Processing {}, Code: {}...'.format(Country, Code))
        

        FramePath = os.path.join(Query.BilateralFolder, 'wits_bilateral_partner_' + str(Code) + '.csv')
        Frame = pd.read_csv(FramePath)
        
        # Restrict Sample to Countries that had Trade Agreements with EU
        # Before 2004
        PartnerFrame = Frame[ Frame['Reporter_ISO_N'].isin(PartnersCodes) ]
        PartnerFrame = PartnerFrame[ (PartnerFrame.Year >= FirstYear) & (PartnerFrame.Year <= LastYear) ]
        
        #Split DataFrame into Two Years
        PFrame2003 = PartnerFrame[ PartnerFrame.Year == 2003 ][['NomenCode','Reporter_ISO_N', 'ProductCode', 'Partner', 'SimpleAverage']]
        PFrame2004 = PartnerFrame[ PartnerFrame.Year == 2004 ][['NomenCode','Reporter_ISO_N', 'ProductCode', 'Partner', 'SimpleAverage']]
        
        DeltaFrame = pd.merge(PFrame2003, PFrame2004, on=['NomenCode','Reporter_ISO_N', 'ProductCode', 'Partner'], suffixes=['_03','_04'])
        DeltaFrame = DeltaFrame.rename(columns = { 'SimpleAverage_03': 'Tau_03', 'SimpleAverage_04': 'Tau_04' } )
        DeltaFrame['DeltaTau_04'] = [ x - y for (x,y) in zip(DeltaFrame.Tau_04, DeltaFrame.Tau_03) ]
        
        BigFrame = BigFrame.append(DeltaFrame)
        
BigFrame = BigFrame.rename(columns={'Reporter_ISO_N': 'Importer Code',
                                            'Partner': 'Exporter Code'})
# Include ISO Codes
ImporterSet = BigFrame['Importer Code'].unique()
ImporterDict = {x: CountryCodesTable[ CountryCodesTable.Code == x ].ISO3.iloc[0] for x in ImporterSet}
ExporterSet = BigFrame['Exporter Code'].unique()
ExporterDict = {x: CountryCodesTable[ CountryCodesTable.Code == x ].ISO3.iloc[0] for x in ExporterSet}

BigFrame['Importer ISO'] = [ ImporterDict[x] for x in BigFrame['Importer Code']]
BigFrame['Exporter ISO'] = [ ExporterDict[x] for x in BigFrame['Exporter Code']]
        
BigFrame.to_csv(os.path.join(Folder, 'out/shock/2004_bilateral_database.csv'), index=False)

Condition = (BigFrame['DeltaTau_04'] != 0.0) & (BigFrame['DeltaTau_04'] > - 75) & (BigFrame['DeltaTau_04'] < 75)

HistFrame = BigFrame[ Condition ]

# Set up the plot
fig, ax = plt.subplots(1,1, figsize=(12,12))
    
    # Draw the plot
ax.hist(HistFrame['DeltaTau_04'], bins = 100,
             color = 'grey', density=True)
    
    # Title and labels
ax.set_title('Distribution of Tariff Changes in 2004 \n (non-zero changes)', size = 18)
ax.set_xlabel('percentage points', size = 18)
plt.axvline(0, color='black')

plt.tight_layout()
plt.show()
        
