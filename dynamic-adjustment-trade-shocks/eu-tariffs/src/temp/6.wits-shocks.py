# -*- coding: utf-8 -*-
"""
Created by Carlos Góes
cgoes@ucsd.edu
www.carlosgoes.com

Version 0.1
December 2022
"""

from wits.src import wits
import pandas as pd
import os

### User inputs
FirstYear = 1990
LastYear = 2020
EU = 1

# Base Paths
Folder = r'C:\Users\wb592068\OneDrive - UC San Diego\UCSD\Research\product-innovation-trade\data\wits'
FolderLocal = r'C:\Users\Carlos\OneDrive - UC San Diego\UCSD\Research\product-innovation-trade\data'

# Concordance Paths
ConcordancePath = r'C:\Users\wb592068\OneDrive - UC San Diego\UCSD\Research\product-innovation-trade\data\wits\concordance'
PrefGroupsFile = r'TRAINSPreferenceBenficiaries.xls'

# Country Codes
CountryCodes = r'https://wits.worldbank.org/wits/wits/witshelp/content/codes/country_codes.htm'
CountryCodesTable = pd.read_html(CountryCodes, header=1)[0]

if (EU == 1):
    
    ISOCodes = ['AUT', 'BEL', 'BGR', 'HRV', 'CYP', 'CZE', 'DNK',
                'EST', 'FIN', 'FRA', 'DEU', 'GRC', 'HUN', 'IRL',
                'ITA', 'LVA', 'LTU', 'LUX', 'MLT', 'NLD', 'POL',
                'PRT', 'ROU', 'SVK', 'SVN', 'ESP', 'SWE']
    EuTable = CountryCodesTable[ CountryCodesTable.ISO3.isin(ISOCodes) ]
    Codes = EuTable.Code.unique()
