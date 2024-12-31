# -*- coding: utf-8 -*-
"""
Created on Sun May 10 18:55:32 2020

@author: Carlos
"""

"""
This script uses the UNCOMTRADE
API to retrieve international trade
data into a Pandas DataFrame
Author: Carlos Góes
www.carlosgoes.com
"""

# import libraries
import os
import logging
import pandas as pd

# file paths
wdpath = r'/cube/u/cube/world/comtrade/%python'
path = r'/cube/u/cube/world/comtrade/data'
logpath = '/cube/u/cube/world/comtrade/logs/downloads'

# import pycomtrade
os.chdir(wdpath)
from pycomtrade import pycomtrade

## define variables
year = str(input('Which year (YYYY)? '))
partner = 'all'
freq = 'A'
commoditycode = 'AG6'
flow = 'all'
token = ''

## log configuration
logfile = os.path.join(logpath, str(year) + '.log')
log_format = "%(asctime)s :: %(levelname)s :: %(filename)s :: Line %(lineno)d :: %(message)s"
logging.basicConfig(filename=logfile, level='DEBUG', format=log_format, filemode='w')

logging.info('Start program. Year: {}'.format(year))

## retrieve countries
countries = pycomtrade.code_retriever()
logging.info('Year: {}, Retrieved Country Codes'.format(year))

## retrieve data for year
logging.info('Year: {}, Starting Downloading Routing'.format(year))
pycomtrade.year_retriever(path, partner, year, freq, flow, commoditycode, token)
logging.info('Year: {}, Finished Downloading Routing'.format(year))

## check which countries hit the data threshold
threshold = 250000
check = pycomtrade.size_checker(path, year, threshold)
checkdf = pd.DataFrame.from_dict(check, orient='index')
checkdf.to_csv(os.path.join(path, str(year), '_size_checker.csv'), sep=';')
logging.info('Save countries with size > {} in file _size_checker.csv'.format(threshold))


countries = list(check.keys())

## update data for those countries, downloading first imports then exports
logging.info('Year: {}, Starting Re-Downloading Routing'.format(year))
pycomtrade.size_updater(path, countries, partner, year, freq, commoditycode, threshold, token)
logging.info('Year: {}, Finished Re-Downloading Routing'.format(year))
