# -*- coding: utf-8 -*-
"""
Created by Carlos Góes
cgoes@ucsd.edu
www.carlosgoes.com

Version 0.1
December 2022
"""

from src.wits import wits
import pandas as pd
import os

### User inputs
FirstYear = 1991
LastYear = 1995

# Base Paths
Folder = r'C:\Users\wb592068\OneDrive - UC San Diego\UCSD\Research\product-innovation-trade\data\wits'
# Concordance Paths
ConcordancePath = r'C:\Users\wb592068\OneDrive - UC San Diego\UCSD\Research\product-innovation-trade\data\wits\concordance'
PrefGroupsFile = r'TRAINSPreferenceBenficiaries.xls'

# Country Codes
CountryCodes = r'https://wits.worldbank.org/wits/wits/witshelp/content/codes/country_codes.htm'
CountryCodesTable = pd.read_html(CountryCodes, header=1)[0]
Codes = CountryCodesTable.Code.unique()

for Year in range(FirstYear, LastYear + 1):
    ConsolidatedTable = pd.DataFrame()

    for Code in Codes:
        CountryName = CountryCodesTable.query("Code == {}".format(Code))['Country Name'].iloc[0]
        print('Processing Year: {}, Country: {}...'.format(Year, CountryName))
        
        # Retrieve MFN Matrix
        Query = wits(Year=Year,
                     Folder=Folder)
        
        Frame = Query.BilateralMFNPanel(Year=Year, Code=Code)
        
        # Search for which areas have the country as the beneficiary
        Benef = pd.read_excel(os.path.join(ConcordancePath, PrefGroupsFile))
        Benef = Benef.query("Partner ==" + str(Code))
        BenefList = list(Benef.RegionCode.unique())
        
        # Retrieve Preferential Yearly Database
        FramePref = pd.read_csv(os.path.join(Query.YearPrefFolder, 'wits_pref_'  + str(Year) + '.csv'))
        CountryFramePref = FramePref.query("Reporter_ISO_N !=" + str(Code))
        CountryFramePref = CountryFramePref[ CountryFramePref.Partner.isin(BenefList) ]
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
        
        # Append Table
        ConsolidatedTable = ConsolidatedTable.append(ConsolidatedFrame)
        
    
    ConsolidatedTable.to_csv(os.path.join(Query.BilateralFolder, 'wits_bilateral_' + str(Year) + '.csv'), index=False)