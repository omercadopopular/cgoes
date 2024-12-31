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
FolderLocal = r'C:\Users\andre\OneDrive\UCSD\Research\product-innovation-trade\data\wits'
os.chdir(FolderLocal)


from src.wits import wits
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
        
### User inputs
FirstYear = 2000
LastYear = 2010


# Initiate Local Routine
Query = wits(Folder=FolderLocal)

# Dictionary of Enlargement Waves
Enlargement = {
        2004: ['CYP', 'CZE', 'EST', 'HUN', 'LVA', 'LTU', 'MLT', 'SVK', 'SVN'],
        2007: ['BGR', 'ROM'],
        2013: ['HRV']
}

# Country Codes
CountryCodes = r'https://wits.worldbank.org/wits/wits/witshelp/content/codes/country_codes.htm'
storage_options = {'User-Agent': 'Mozilla/5.0'}
CountryCodesTable = pd.read_html(CountryCodes, storage_options=storage_options, header=1)[0]

# ISO Codes and WITS Codes of EU Countries
# I will use this to isolate the sets of non EU countries as our shocks
ISOCodes = ['AUT', 'BEL', 'BGR', 'HRV', 'CYP', 'CZE', 'DNK',
                'EST', 'FIN', 'FRA', 'DEU', 'GRC', 'HUN', 'IRL',
                'ITA', 'LVA', 'LTU', 'LUX', 'MLT', 'NLD', 'POL',
                'PRT', 'ROM', 'SVK', 'SVN', 'ESP', 'SWE', 'GBR']
EuTable = CountryCodesTable[ CountryCodesTable.ISO3.isin(ISOCodes) ]
Codes = EuTable.Code.unique()

# Initiate Frame to Store Summary Statistics
SummaryFrame = pd.DataFrame()

for Wave in Enlargement:
    for CountryIso in Enlargement[Wave]:
        Code = EuTable[ EuTable.ISO3 == CountryIso ].Code.iloc[0]
        Country = EuTable[ EuTable.Code == Code ]['Country Name'].iloc[0]
        print('Processing {}, Code: {}...'.format(Country, Code))
        

        FramePath = os.path.join(Query.BilateralFolder, 'wits_bilateral_partner_' + str(Code) + '.csv')
        Frame = pd.read_csv(FramePath)
        
        # Restrict Sample to NonEuro Countries
        NonEuroFrame = Frame[ ~Frame['Reporter_ISO_N'].isin(Codes) ]
        
        # Now take averages
        AverageNonEuroFrame = NonEuroFrame.groupby(['Year', 'ProductCode']).agg(
            {'Min_Rate': min,
             'Max_Rate': max,
             'SimpleAverage': np.mean,
             'PrefFlag': np.mean}
            ).reset_index(drop=False)
        
        ThresholdYear = Wave
        Window = 10
        MinYear = ThresholdYear - Window
        MaxYear = ThresholdYear + Window
        
        RAverageNonEuroFrame = AverageNonEuroFrame[ (AverageNonEuroFrame.Year >= MinYear) & (AverageNonEuroFrame.Year <= MaxYear) ]
        
        RAverageNonEuroFrame = RAverageNonEuroFrame.pivot_table(values=['Min_Rate', 'Max_Rate',
               'SimpleAverage', 'PrefFlag'], index=['ProductCode','Year']).reset_index(drop=False)
        
        print('Processed table, now creating plots...')
        
        fig, axes = plt.subplots(figsize=(12, 6))
        sns.boxplot(data=RAverageNonEuroFrame, color='grey', x='Year', y='SimpleAverage', showfliers=False, whis=0)
        plt.title(Country + ': Non-EU Partners, Distribution of Tariff Schedule')
        plt.show()
        FigPath = os.path.join(Query.ImgFolder, str(Code) + 'non_eu_tariff_dist.pdf')
        fig.savefig(FigPath)
        
        fig, axes = plt.subplots(figsize=(12, 6))
        sns.boxplot(data=RAverageNonEuroFrame, color='grey', x='Year', y='PrefFlag', showfliers=False, whis=0)
        plt.title(Country + ': Non-EU Partners, Distribution of Share of Preferential Beneficiaries')
        FigPath = os.path.join(Query.ImgFolder, str(Code) + 'non_eu_pref_dist.pdf')
        plt.show()
        fig.savefig(FigPath)
        
        # Save average tariffs        
        SavePath = os.path.join(Query.AverageNonEUTariffFolder, str(Wave) + '_' + str(Code) + '_non_eu_tariff.csv')
        RAverageNonEuroFrame.to_csv(SavePath, index=False)
        
        # Store Summary Statistics        
        Summary = RAverageNonEuroFrame.groupby('Year').SimpleAverage.describe()
        Summary['Country'] = Country
        SummaryFrame = SummaryFrame.append(Summary)

# Now create a general chart across all countries
# Walk through all of the average files we just created
List = Query.Walker(WalkFolder=Query.AverageNonEUTariffFolder, YearCheck = False)

NList = []
for File in List :
    if File.split('\\')[-1][:4] == '2004':
        NList.append(File)

# Build Panel
Frame = Query.PanelBuild(List)

# Restrict Window
ThresholdYear = 2004
MinYear = 2000
MaxYear = 2010
        
Frame = Frame[ (Frame.Year >= MinYear) & (Frame.Year <= MaxYear) ]
Frame = Frame.pivot_table(values=['Min_Rate', 'Max_Rate','SimpleAverage', 'PrefFlag'], index=['ProductCode','Year']).reset_index(drop=False)

# Create Plots
fig, axes = plt.subplots(figsize=(12, 6))
sns.boxplot(data=Frame, color='grey', x='Year', y='SimpleAverage', showfliers=False, whis=0)
plt.title('2004 EU Enlargement Wave Countries: Distribution across all HS-Codes of the Simple Average of Tariff Rates' +
          '\n imposed by Countries that had Trade Agreement with EU prior to 2004')
FigPath = os.path.join(Query.ImgFolder, 'overall_non_eu_tariff_dist.pdf')
plt.show()
fig.savefig(FigPath)

fig, axes = plt.subplots(figsize=(12, 6))
sns.boxplot(data=Frame, color='grey', x='Year', y='PrefFlag', showfliers=False, whis=0)
plt.title('2004 EU Enlargement Wave Countries: Non-EU Partners, Distribution of Share of Preferential Beneficiaries')
FigPath = os.path.join(Query.ImgFolder, 'non_eu_pref_dist.pdf')
plt.show()
fig.savefig(FigPath)

# Save Summary Statistics
Summary = Frame.groupby('Year').SimpleAverage.describe()
Summary['Country'] = 'Overall'
SummaryFrame = SummaryFrame.append(Summary)
#SummaryFrame.to_csv(r"C:\Users\wb592068\OneDrive - WBG", "SummaryStats.csv")
SummaryFrame.to_csv(os.path.join(Query.AverageNonEUTariffFolder, "SummaryStats.csv"))

