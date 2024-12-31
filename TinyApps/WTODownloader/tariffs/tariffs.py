# -*- coding: utf-8 -*-
"""
Created on Mon Aug 16 16:32:43 2021

@author: Carlos
"""

import os
import pandas as pd
import urllib
import json
import ssl
import datetime

Path = r'C:\Users\Carlos\OneDrive - UC San Diego\UCSD\Research\cgoes\TinyApps\WTODownloader\tariffs'
CodesFile = 'DatabaseCodesAndLabels.xlsx'

## Import Reporters
Frame = pd.read_excel(os.path.join(Path,CodesFile), sheet_name='Reporters')
Reporters = [x for x in Frame['Reporting Economy Code']]
Iso3 = [x for x in Frame['Iso3A Code']]

## Create Log File
log = open(os.path.join(Path,"logs/nonMFNlog.txt"),"w")
Date = datetime.datetime.now().strftime("%d/%m/%Y %H:%M:%S")
print('Script executed at {}'.format(Date))
log.write('Script executed at {} \n'.format(Date))


Period = '1996-2021'
for Reporter in Reporters:
    Country = Iso3[Reporters.index(Reporter)]

    url = 'https://api.wto.org/timeseries/v1/data?i=HS_P_0070' + \
          '&r=' + str(Reporter) + \
          '&pc=' + str('HS6') + \
          '&ps=' + str(Period) + \
          '&fmt=JSON&subscription-key=2c4cef8721c84573bc1fec24cfdf7750'

    #Import data with the API, transform JSON into a frame
    ctx = ssl.create_default_context()
    ctx.check_hostname = False
    ctx.verify_mode = ssl.CERT_NONE
    urlopen = urllib.request.urlopen(url, context=ctx)
    data = json.loads(urlopen.read().decode("utf-8","ignore"))
    
    if ('title' in data.keys()) == True:
        if data['title'] == 'No content':
            print('Could not process {}: no content available'.format(Country))
            log.write('Could not process {}: no content available'.format(Country) + ' \n')
            pass
    elif ('Dataset' in data.keys()) == True:
        Frame = pd.json_normalize(data['Dataset'])
        Frame.to_csv(os.path.join(Path, 'out/' + str(Country) + '.csv'))
        
        print('Processed {}...'.format(Country))
        log.write('Processed {}...'.format(Country) + ' \n')
    else:
        print('Could not process {}: no dataset found'.format(Country))
        log.write('Could not process {}: no dataset found'.format(Country) + ' \n')
        pass
    
log.close()
