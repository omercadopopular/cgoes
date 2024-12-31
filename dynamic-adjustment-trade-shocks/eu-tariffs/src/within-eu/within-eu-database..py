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
#Folder = r'C:\Users\wb592068\OneDrive - UC San Diego\UCSD\Research\product-innovation-trade\data\wits'
Folder = r'C:\Users\cbezerradegoes\OneDrive\UCSD\Research\product-innovation-trade\data\wits'
#Folder = r'C:\Users\andre\OneDrive\UCSD\Research\product-innovation-trade\data\wits'

os.chdir(Folder)

# Import base packages
from src.wits import wits
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np

### User inputs
FirstYear = 1995
LastYear = 2010

# Concordance Paths
ConcordancePath = Folder + r'\concordance'
PrefGroupsFile = r'TRAINSPreferenceBenficiaries.xls'

# Country Codes
storage_options = {'User-Agent': 'Mozilla/5.0'}
CountryCodes = r'https://wits.worldbank.org/wits/wits/witshelp/content/codes/country_codes.htm'
CountryCodesTable = pd.read_html(CountryCodes, storage_options=storage_options, header=1)[0]

"""
Calculate 
""" 
NewISOCodes = ['CYP', 'CZE', 'EST', 
            'HUN', 'LVA', 'LTU', 'MLT', 'POL', 'SVK', 'SVN']
NewTable = CountryCodesTable[ CountryCodesTable.ISO3.isin(NewISOCodes) ]
NewCodes = NewTable.Code.unique()

EUCode = CountryCodesTable[ CountryCodesTable.ISO3 == 'EUN' ].Code.iloc[0]


for Code in NewCodes:
    ConsolidatedTable = pd.DataFrame()
    for Year in range(FirstYear, LastYear + 1):
    
        CountryName = CountryCodesTable.query("Code == {}".format(Code))['Country Name'].iloc[0]
        print('Processing Year: {}, Country: {}...'.format(Year, CountryName))
            
        # Retrieve MFN Matrix
        Query = wits(Year=Year,
                         Folder=Folder)
            
        Frame = Query.BilateralMFNPanel(Year=Year, Code=Code)
        Frame = Frame[ Frame.Reporter_ISO_N == EUCode]
        
        if Year < 2004:
                    
            # Search for which areas have the country as the beneficiary
            Benef = pd.read_excel(os.path.join(ConcordancePath, PrefGroupsFile))
            Benef = Benef.query("Partner ==" + str(Code))
            BenefList = list(Benef.RegionCode.unique())
                
            # Retrieve Preferential Yearly Database
            FramePref = pd.read_csv(os.path.join(Query.YearPrefFolder, 'wits_pref_'  + str(Year) + '.csv'))
            CountryFramePref = FramePref.query("Reporter_ISO_N ==" + str(EUCode))
            CountryFramePref = CountryFramePref[ (CountryFramePref.Partner == Code) | CountryFramePref.Partner.isin(BenefList) ]
            CountryFramePref['Partner'] = [Code for x in CountryFramePref['Partner']]
                
            # Merge Datasets
            MergeConditions = ['NomenCode','Reporter_ISO_N', 'Year', 'ProductCode', 'Partner']
            FullFrame = Frame.merge(CountryFramePref, how='left', on=MergeConditions, suffixes=['_mfn','_pref'])
                
            #Flag preferential tariffs
            FullFrame['PrefFlag'] = ~FullFrame.SimpleAverage_pref.isna()
            TempFrame = FullFrame[ FullFrame['PrefFlag'] == True ]
                
            # Create merged columns
            Columns =  ['Sum_Of_Rates', 'Min_Rate', 'Max_Rate', 'SimpleAverage']
            for Column in Columns:
                FullFrame[Column] = FullFrame[Column + '_mfn']
                FullFrame.loc[TempFrame.index, Column] = TempFrame.loc[TempFrame.index, Column + '_pref']
                
            # Create consolidated dataset
            Columns.append('PrefFlag')
            ConsolidatedFrame = FullFrame[ MergeConditions + Columns ]
            
                
        else:
            
            ConsolidatedFrame = Frame.copy()
            
            Columns =  ['Sum_Of_Rates', 'Min_Rate', 'Max_Rate', 'SimpleAverage']
            
            for column in Columns:
                ConsolidatedFrame[column] = [0 for x in ConsolidatedFrame[column]]
            
            ConsolidatedFrame['PrefFlag'] = [1 for x in ConsolidatedFrame['SimpleAverage']]
    
        print("Total Preferential Flags: {}".format(ConsolidatedFrame.PrefFlag.sum()))
        
        # Append Table
        ConsolidatedTable = pd.concat([ConsolidatedTable, ConsolidatedFrame], ignore_index=True)            
        
        print("\n")
        
    ConsolidatedTable.to_csv(os.path.join(Query.BilateralFolder, 'wits_bilateral_eu_' + str(Code) + '.csv'), index=False)
    
   
    
    # Create Plots
    fig, axes = plt.subplots(figsize=(12, 6))
    sns.boxplot(data=ConsolidatedTable, color='grey', x='Year', y='SimpleAverage', showfliers=False, whis=0)
    plt.title('Bilateral tariffs between the EU and {}'.format(CountryName))
    FigPath = os.path.join(Query.ImgFolder, str(Code) + '_eu_tariff_dist.pdf')
    plt.show()
    fig.savefig(FigPath)

# combine frames
totalFrame = pd.DataFrame()
for Code in NewCodes:
    tempFrame = pd.read_csv(os.path.join(Query.BilateralFolder, 'wits_bilateral_eu_' + str(Code) + '.csv'))
    totalFrame = pd.concat([totalFrame, tempFrame], ignore_index=True)
    
# take averages across products
avgFrame = totalFrame.groupby(['Reporter_ISO_N', 'Year', 'ProductCode']).agg(
            { 'SimpleAverage': 'mean'}
            ).reset_index(drop=False)


fig, axes = plt.subplots(figsize=(12, 6))
sns.boxplot(data=avgFrame, color='grey', x='Year', y='SimpleAverage', showfliers=False, whis=0)
plt.title('Bilateral tariffs between the EU and 2004-NMS')
FigPath = os.path.join(Query.ImgFolder, 'nms_eu_tariff_dist.pdf')
plt.show()
fig.savefig(FigPath)


avgFrameY = totalFrame.groupby(['Reporter_ISO_N', 'Year']).agg(
            { 'SimpleAverage': 'mean'}
            ).reset_index(drop=False)

fig, axes = plt.subplots(figsize=(12, 6))
plt.plot(avgFrameY.Year, avgFrameY.SimpleAverage, color='grey')
plt.title('Bilateral tariffs between the EU and 2004-NMS: Average')
FigPath = os.path.join(Query.ImgFolder, 'nms_eu_tariff_dist_avg.pdf')
plt.show()
fig.savefig(FigPath)

    