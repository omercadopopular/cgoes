# -*- coding: utf-8 -*-
"""
Created on Thu Jan 11 19:02:47 2024

@author: wb592068
"""

import os
import requests
import urllib.request
import ssl
context = ssl._create_unverified_context()

originURL = 'https://balanca.economia.gov.br/balanca/bd/comexstat-bd/ncm/'
destinationPath = r'C:\Users\wb592068\OneDrive - WBG\Brazil\data\trade-mdic'

os.chdir(destinationPath)

firstYear = 1997
lastYear = 2023

for year in range(firstYear, lastYear + 1):
    print('Processing year {}...'.format(year))
    exp = 'EXP_' + str(year) + '.csv'
    urllib.request.urlretrieve(os.path.join('https://balanca.economia.gov.br/balanca/bd/comexstat-bd/ncm/', exp), exp)
    imp = 'IMP_' + str(year) + '.csv'
    urllib.request.urlretrieve(os.path.join('https://balanca.economia.gov.br/balanca/bd/comexstat-bd/ncm/', exp), exp)
