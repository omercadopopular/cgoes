# -*- coding: utf-8 -*-
"""
Created on Thu Jul 30 23:35:32 2020

@author: Carlos
"""

import requests
import os

path = r'C:\Users\wb592068\OneDrive - WBG\Poverty_DIOT\2 Data\Comtrade\bulk'
os.chdir(path)

years = range(2021,2023)

for year in years:
    print('Downloading year {}'.format(year))
    data = requests.get('http://comtrade.un.org/api/get/bulk/C/A/' + str(year) + '/ALL/', stream=True, verify=False)
    with open(os.path.join(path, 'bulk_' + str(year) + '.zip'), 'wb') as fd:
        for chunk in data.iter_content(chunk_size=512):
            fd.write(chunk)

