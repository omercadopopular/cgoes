# -*- coding: utf-8 -*-
"""
This script uses the UNCOMTRADE
API to retrieve international trade
data into a Pandas DataFrame

Author: Carlos Góes
www.carlosgoes.com
"""

def comtrade(reporter,partner,year,freq,commoditycode):
    #Import your libraries
    import json
    import urllib
    import pandas as pd
    import ssl
    
    #Import the index of countries
    partnerurl = 'https://comtrade.un.org/data/cache/partnerAreas.json'
    ctx = ssl.create_default_context()
    ctx.check_hostname = False
    ctx.verify_mode = ssl.CERT_NONE
    areas = urllib.request.urlopen(partnerurl, context=ctx)
    data = json.loads(areas.read())
    data = data['results']
    index = {}
    for i in range(len(data)):
        upper = data[i]['text']
        lower = upper.lower()
        index.update({lower: data[i]['id']})
    
    #Retrieve numeric codes for reporter and partner
    reporter = index[str(reporter)]
    partner =  index[str(partner)]
    
    #Set the URL API
    url = 'http://comtrade.un.org/api/get?' + \
        'max=50000&' + \
        'type=C&' + \
        'freq=' + str(freq) + '&' + \
        'px=HS&' + \
        'ps=' + str(year) + '&' + \
        'r=' + reporter + '&' + \
        'p=' + partner + '&' + \
        'rg=all&' + \
        'cc=' + commoditycode + '&' + \
        'fmt=json'
    
    #Import data with the API, transform JSON into a frame
    urlopen = urllib.request.urlopen(url, context=ctx)
    data = json.loads(urlopen.read())
    data = pd.io.json.json_normalize(data['dataset'])
    
    #Return the data
    return data

#Import data from 2000 through 2014
first = 2014
last = 2014

reporter = 'brazil'
partner = 'usa'
freq = 'A'
ccode = 'ALL'

for year in list(range(first,last)):
    if year == first:
        frame = comtrade(reporter, partner, year, freq, ccode)
    else:
        framet = comtrade(reporter, partner, year, freq, ccode)
        frame = frame.append(framet)

print(frame)
