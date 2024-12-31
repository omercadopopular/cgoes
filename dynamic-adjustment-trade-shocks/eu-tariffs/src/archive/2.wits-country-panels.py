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

Folder = r'C:\Users\wb592068\OneDrive - UC San Diego\UCSD\Research\product-innovation-trade\data\wits'

CountryCodes = r'https://wits.worldbank.org/wits/wits/witshelp/content/codes/country_codes.htm'
CountryCodesTable = pd.read_html(CountryCodes, header=1)[0]

Query = wits(Folder=Folder)

Files = Query.CountryWalker(WalkFolder=Query.YearFolder)

for Code in CountryCodesTable.Code:
    CountryName = CountryCodesTable.query("Code == {}".format(Code))['Country Name'].iloc[0]
    print('Processing {}...'.format(CountryName))
    
    CountryFrame = Query.CountryStacker(Files, Code)
    CodeString = '0' * (3-len(str(Code))) + str(Code)
    CountryFrame.to_csv(os.path.join(Query.CountryFolder, 'wits_mfn_' + CodeString + '.csv'), index=False)