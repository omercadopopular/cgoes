# -*- coding: utf-8 -*-
"""
Created on Thu Jul 30 23:35:32 2020

@author: Carlos
"""

import requests
import os

path = '/cube/u/cube/world/comtrade/data/bulk'
os.chdir(path)

years = range(1988,2020)
token = 'PbDbsnZ/i550gENTN+U7C44S/vuZyfmmv7ae79tSmBhCssBk7LPijpjJ7JK8i9edu7Q+l38MGUtqUAMFvcEjRBytPlCO5S8mG0OK2V51dhOEuKNLG3dfhtqwzik7XRFu'

for year in years:
    print('Downloading year {}'.format(year))
    data = requests.get('http://comtrade.un.org/api/get/bulk/C/A/' + str(year) + '/ALL/HS?token=' + str(token), stream=True)
    with open(os.path.join(path, 'bulk_' + str(year) + '.zip'), 'wb') as fd:
        for chunk in data.iter_content(chunk_size=512):
            fd.write(chunk)

