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
Folder = r'C:\Users\andre\OneDrive\UCSD\Research\product-innovation-trade\data\wits'

os.chdir(Folder)

# Import base packages
from src.wits import wits
import pandas as pd

### User inputs
FirstYear = 1998
LastYear = 2010

# Concordance Paths
ConcordancePath = r'C:\Users\wb592068\OneDrive - UC San Diego\UCSD\Research\product-innovation-trade\data\wits\concordance'
PrefGroupsFile = r'TRAINSPreferenceBenficiaries.xls'

# Country Codes
storage_options = {'User-Agent': 'Mozilla/5.0'}
CountryCodes = r'https://wits.worldbank.org/wits/wits/witshelp/content/codes/country_codes.htm'
CountryCodesTable = pd.read_html(CountryCodes, storage_options=storage_options, header=1)[0]

ISOCodes = ['BGR', 'HRV', 'CYP', 'CZE', 'EST', 
            'HUN', 'LVA', 'LTU', 'MLT', 'POL', 'ROM', 'SVK', 'SVN']
EuTable = CountryCodesTable[ CountryCodesTable.ISO3.isin(ISOCodes) ]
Codes = EuTable.Code.unique()

"""
These are ISO codes of Trade Partners for which the EU had signed a
trade agreement before 2004 and whose trade had been at least provisionally
applied before 2004
""" 
ISOPartners = ['CHE', 'ISL', 'NOR', 'TUR', 'TUN', 'ISR', 'MEX',
               'MAR', 'JOR', 'EGY', 'MKD', 'CHL', 'ZAF']
PartnersTable = CountryCodesTable[ CountryCodesTable.ISO3.isin(ISOPartners) ]
PartnersCodes = PartnersTable.Code.unique()


for Code in Codes:
    ConsolidatedTable = pd.DataFrame()
    for Year in range(FirstYear, LastYear + 1):
    
        CountryName = CountryCodesTable.query("Code == {}".format(Code))['Country Name'].iloc[0]
        print('Processing Year: {}, Country: {}...'.format(Year, CountryName))
            
        # Retrieve MFN Matrix
        Query = wits(Year=Year,
                         Folder=Folder)
            
        Frame = Query.BilateralMFNPanel(Year=Year, Code=Code)
        Frame = Frame[ Frame.Reporter_ISO_N.isin(PartnersCodes)]
        
            
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
            
        
    ConsolidatedTable.to_csv(os.path.join(Query.BilateralFolder, 'wits_bilateral_partner_' + str(Code) + '.csv'), index=False)