# -*- coding: utf-8 -*-
"""
Created by Carlos Góes
cgoes@ucsd.edu
www.carlosgoes.com

Version 0.1
December 2022
"""

from wits import wits
import pandas as pd
import os

### User inputs
FirstYear = 1990
LastYear = 2020
EU = 1

# Base Paths
Folder = r'C:\Users\wb592068\OneDrive - UC San Diego\UCSD\Research\product-innovation-trade\data\wits'

# Concordance Paths
ConcordancePath = r'C:\Users\wb592068\OneDrive - UC San Diego\UCSD\Research\product-innovation-trade\data\wits\concordance'
PrefGroupsFile = r'TRAINSPreferenceBenficiaries.xls'

# Country Codes
CountryCodes = r'https://wits.worldbank.org/wits/wits/witshelp/content/codes/country_codes.htm'
CountryCodesTable = pd.read_html(CountryCodes, header=1)[0]

if (EU == 1):
    
    EU15 = ['AUT', 'BEL', 'DNK', 'FIN', 'FRA', 'DEU', 'GRC', 'IRL',
            'ITA', 'LUX', 'NLD', 'GBR', 'PRT', 'ESP', 'SWE']

    EU2004 = ['CYP', 'CZE', 'EST', 'HUN', 'LVA', 'LTU', 'MLT',
              'POL', 'SVK']

    EU2007 = ['BGR', 'ROU']

    EU20013 = ['HRV']

    EuTable = CountryCodesTable[ CountryCodesTable.ISO3.isin(ISOCodes) ]
    Codes = EuTable.Code.unique()


dictWaves = {
    2004 = ['CYP', 'CZE', 'EST', ] }